# MIOTPL2 Internal Architecture & Mustache Inheritance Implementation Guide

This document is written as an **internal “how it actually works”** guide for humans and LLMs who need to:

1. Understand MIOTPL2’s current behavior and data structures.
2. Safely extend MIOTPL2 to fully match the official Mustache `_inheritance.json` spec.
3. Do so without breaking the existing passing test suite (scalar + ref modes, plus MIOTEST modes).

> Assumptions:
>
> * The current code passes all existing MIOTPL2 tests you run (including the Mustache spec tests you have enabled).
> * MIOTPLT runs **each spec test twice**: scalar path (`COMPILE` + `EVAL`) and reference path (`COMPREF` + `EVALREF`).
> * You have three runtime modes (`perf`, `big`, `min`) validated by `MIOTESTMODES^MIOTPL2`.

---

## 1. High-level engine model

MIOTPL2 is a two-phase engine:

* **Phase A: Compile** — parse a template into a compact token program (TOK array) with metadata.
* **Phase B: Eval** — execute that token program against a context stack and partial namespace to produce output.

Key design goals:

* **Fast scalar path** for “normal” template sizes.
* **GB-safe / MAXSTRING-safe path** using chunked inputs and/or chunked outputs.
* **Identical semantics** across scalar and ref paths.
* Mustache compliance for:

  * interpolation, sections, inverted sections
  * comments, delimiters
  * partials (+ indentation + delimiter scoping)
  * inheritance (parent tags `<` + block tags `$`, with substitution)

MIOTPL2 additionally supports **non-standard “block capture”** tags (e.g., `{{#block:title}}...{{/block:title}}`) used for layout/page patterns. These coexist with Mustache inheritance blocks but have different semantics.

---

## 2. Entry points & test harness expectations

### 2.1 Primary entry points

You should recognize these entry points as the “public API surface” that tests call:

* `START^MIOTPL2(.CONF)`

  * Initializes defaults in CONF and potentially sets up runtime behavior.

* `COMPILE^MIOTPL2(TPL,.TOK,.ERR)`

  * Scalar template input → tokens.

* `COMPILEA^MIOTPL2(.ARR,.TOK,.ERR)`

  * Array-of-chunks input → tokens.

* `COMPREF^MIOTPL2(INROOT,.TOK,.ERR)`

  * Global-reference input chunks → tokens.

* `EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)`

  * Token program → scalar output string.

* `EVALREF^MIOTPL2(.TOK,.CONF,.CTX,OUTROOT,.ERR)`

  * Token program → global-reference output chunks.

* `RENDER^MIOTPL2(NAME,.CONF,.CTX,.OUT,.ERR)`

  * Loads a template by name via CONF root/ext rules (and cache), compiles if needed, evals.

* `RENDERPAGE^MIOTPL2(PAGE,LAYOUT,.CONF,.CTX,.OUT,.ERR)`

  * Layout/page rendering pattern (non-standard); uses block capture.

### 2.2 How MIOTPLT validates correctness

`RUNTEST1` runs each test twice:

1. **Scalar path**

   * `COMPILE(template)` → `TOK`
   * `EVAL(TOK)` → `OUT` scalar string

2. **Reference path**

   * Input template is split into small chunks (CHSZ=17) into a global ref tree.
   * `COMPREF(inRoot)` → `TOKR`
   * `EVALREF(TOKR)` → output chunks
   * Those chunks are concatenated and compared to EXPECTED.

Implication:

* Any bug in **boundary handling** (CRLF split across chunks, delimiter scanning across chunk boundaries, tokenizing tags at boundaries, etc.) will show up in ref mode.

---

## 3. Data model: tokens, metadata, and runtime state

### 3.1 TOK structure (observed + typical)

Even without the full routine listing here, you can infer how MIOTPL2 represents tokens from debug dumps:

Example (from earlier failing logs):

* `TOK(1,"k")="parent"`

* `TOK(1,"t")="parS"` (likely “parent start”)

* `TOK(1,"raw")=...`

* `TOK(1,"bpos")=...`

* `TOK(2,"k")="block"`

* `TOK(2,"indent")=""` (computed indentation)

**Recommended mental model**:

* TOK is an **ordered program**: token #1, #2, #3… executed sequentially.
* Each token has:

  * a **kind** (`k`) like `text`, `var`, `secS`, `secE`, `invS`, `invE`, `partial`, `setdelim`, `parentS`, `parentE`, `blockS`, `blockE`, etc.
  * attributes needed at eval time.

### 3.2 Meta fields that strongly influence behavior

You should expect a `TOK("meta",...)` subtree that includes flags discovered at compile time.

Important meta fields already implied by tests:

* `TOK("meta","crlf")` — indicates the input template used CRLF newlines and output should preserve CRLF.

  * This is why a post-pass conversion `LF2CRLF` exists.

* Potential additional meta:

  * original delimiters
  * whether the input began with CRLF
  * tokenization mode or chunk strategy

### 3.3 Runtime state

At eval time, MIOTPL2 operates with:

* `CONF` (configuration)

  * `CONF("templates","root")` base directory
  * `CONF("templates","ext")` file extension
  * plus any caching strategy

* `CTX` (context) — a nested M structure

  * used for name resolution
  * also contains MIOTPL2-specific meta:

    * `CTX("meta","captureBlocks")` used for non-standard block capture
    * `CTX("blocks",name)` used to store captured blocks

* `Context stack` (often an internal structure)

  * Mustache requires resolution by walking stack from top → bottom.

* `Partial/parent namespace` (implemented via file system + cache)

  * Mustache inheritance uses the same namespace as partials.

---

## 4. Compile pipeline: how template text becomes tokens

### 4.1 Primary responsibilities of the compiler

The compiler must:

1. Scan the template left → right.

2. Detect tags using current delimiters.

3. Emit tokens for:

   * literal text chunks
   * interpolations (`{{name}}`, `{{{name}}}`, `{{&name}}`)
   * sections (`{{#name}}...{{/name}}`)
   * inverted sections (`{{^name}}...{{/name}}`)
   * comments (`{{! ... }}`)
   * set delimiters (`{{= <% %> =}}`)
   * partials (`{{> partial}}`)
   * parents (`{{< parent}}...{{/parent}}`)
   * blocks (`{{$block}}...{{/block}}`)

4. Track **standalone tag** rules:

   * Identify tags that may remove surrounding whitespace/newlines when standalone.
   * Record indentation where required (partials and parents).

5. Track newline style:

   * LF vs CRLF.
   * Detect CRLF even across chunk boundaries.

### 4.2 Standalone detection (core idea)

Mustache “standalone” applies when a tag appears on a line by itself (ignoring indentation and whitespace).

In MIOTPLT, standalone rules were exercised heavily:

* Sections / inverted sections / comments / delimiter tags
* Partials
* Parents
* Blocks

A correct standalone detector must consider:

* Pre-tag whitespace on the line (spaces/tabs)
* Whether the tag is one of the standalone-eligible kinds
* Post-tag whitespace until newline/end
* Newline detection for both LF and CRLF

If standalone:

* The entire line (indent + tag + trailing whitespace + newline) is removed from output.
* For **partials/parents**, indentation is captured and applied to injected content.
* For **blocks**, indentation can be influenced by either:

  * site of expansion (where the block is placed)
  * intrinsic indentation of the block default body (when opening tag is standalone)

### 4.3 CRLF handling

MIOTPL2 supports templates containing CRLF. The tests verify:

* Correct preservation of CRLF newlines in output
* Safety when interpolated values already contain CRLF (avoid `\r\r\n`)
* Correct detection across chunk boundary (CR at end of chunk, LF at beginning of next)

The current implementation likely does:

* During compile: detect whether any CRLF occurs and set `TOK("meta","crlf")`.
* During eval: if `TOK("meta","crlf")`, convert `\n` to `\r\n` at the end, or in streaming output.

**Known performance caveat** (from your note): a post-pass conversion requires scanning the entire output again.

---

## 5. Eval pipeline: executing the token program

### 5.1 Name resolution

Mustache name resolution:

* If name is `.` use top of stack.
* Otherwise split on dots and resolve left-to-right.
* For the first name:

  * Walk context stack top → bottom.
  * Find first context that has that key.
* For remaining dotted parts:

  * Resolve against a stack containing only the previously resolved value.
* If any step fails: result is falsey / empty.

### 5.2 Truthiness and sections

Sections (`#`) and inverted sections (`^`) depend on truthiness:

* Falsey: empty string, numeric 0? (depends on engine’s chosen mapping), explicit strings like "false"/"FALSE" treated falsey (your tests cover that).
* Lists (M arrays) are iterable.
* Non-list truthy values are treated like a 1-element list.

### 5.3 Output modes

MIOTPL2 supports at least these output strategies:

* **Scalar OUT** — fastest, but can hit MAXSTRING for very large renders.
* **Reference OUTROOT** — output into chunks stored in a global or local ref tree.

Your test harness forces both, so implementations must stay equivalent.

### 5.4 Partial loading and caching

Partials are loaded through:

* Filesystem root/ext rules in CONF
* Cache global: `^MIO("TPL","CACHE")`

Common caching patterns:

* Cache raw file contents
* Cache compiled token arrays
* Cache both (and detect invalidation / dev mode)

Critical Mustache rule:

* **Set Delimiter tags preceding a partial MUST NOT affect parsing of the partial**.

This usually means:

* When you compile a partial, start it with default delimiters `{{ }}` regardless of caller state.
* When you return from partial compilation, restore the caller’s delimiter state.

MIOTPL2 appears to respect this (partials tests pass).

---

## 6. Mustache inheritance: what it means semantically

Inheritance is the combination of:

* **Parent tags**: `{{<parent}} ... {{/parent}}`
* **Block tags**: `{{$name}} default {{/name}}`

### 6.1 Parent tags (“parametric partials”)

A Parent tag injects an external template (same namespace as partials).

Key rules:

1. Parent content is the template name.
2. Parent must have a matching `{{/parent}}`.
3. Parent is rendered against the current context stack.
4. If parent template missing → inject empty string.
5. Delimiters set before the parent tag do **not** affect the injected template.
6. Parent tags are standalone when appropriate:

   * indentation before the tag is prepended to each line of the injected parent output.

### 6.2 Block tags (two roles)

Block tags can occur:

* **In a normal template** (not inside a parent tag)

  * They define a parameter with default content.
  * If no override exists, render the default.

* **Inside a parent tag**

  * They define an argument to substitute into the parent template.
  * This argument content replaces the parent’s default content for that block.

Important namespace rule:

* Block names live in a namespace distinct from both partial names and context keys.

That means:

* `data.var` should not override `{{$var}}...{{/var}}` substitution.

Your tests cover this.

### 6.3 Scope rules (“Block scope” test)

This is subtle and critical:

> “Scope of a substituted block is evaluated in the context of the parent template.”

Meaning:

* When a parent template renders a block default body, the block body is evaluated where it appears in the parent.
* When a child overrides a block, that override body is evaluated **as if it were located in the parent** at that block site.

So:

* The override body uses the **parent’s local context stack** at the block position, not the child’s.

In practice:

* If parent template enters a section `{{#nested}}` before expanding `{{$block}}`, then `{{fruit}}` inside the override body should resolve to `nested.fruit`.

Your `Block scope` test verifies this.

### 6.4 Multi-level inheritance precedence

When inheritance chains:

* Child calls parent, parent calls older, older calls grandparent…

Rules:

* **Top-level substitutions take precedence**.
* Substitutions should “flow down” and override deeper defaults.

In other words:

* There is a single “argument environment” that should be passed through the chain, where outermost overrides win.

Your multi-level tests verify the precedence behavior.

---

## 7. What MIOTPL2 currently does for inheritance (based on passing tests)

Based on your enabled passing tests (TEST138–TEST162), MIOTPL2 already supports:

* Rendering of block defaults (`{{$x}}default{{/x}}`)
* Rendering variables/sections inside default bodies
* Parent injection (`{{<include}}{{/include}}`)
* Substitution overrides (`{{<super}}{{$title}}...{{/title}}{{/super}}`)
* “Data does not override block” semantics
* Multiple independent parent invocations with different override bodies
* Correct handling of newlines in overrides
* Parent indentation rules
* Parent behaves same as partial when no overrides
* Recursion behavior (including the "don’t recurse" scenario in test 154)
* Multi-level inheritance precedence
* Text inside parent tag is ignored except `$` tags are still parsed
* Block scope rule
* Standalone parent rule
* Standalone block rule
* Block reindentation rule (site-of-definition vs site-of-expansion)

This means the remaining spec work is likely concentrated in **intrinsic indentation** and **nested block reindentation** (the tests you currently commented out: TEST163 and TEST164).

---

## 8. The hard parts left: intrinsic indentation & nested block reindentation

### 8.1 Intrinsic indentation (spec test 163)

Spec statement:

> “When the block opening tag is standalone, indentation is determined by default content.”

Scenario:

* Parent defines a block like:

  ```
  Hi,
  {{$block}}
    default
  {{/block}}
  ```

* Child overrides with:

  ```
  {{$block}}
  one
  two
  {{/block}}
  ```

Expected output:

* The override content should adopt indentation that matches the parent’s default content indentation ("  ") even if the child content itself is not indented.

**Why this is hard**:

* The indentation is **not** coming from the expansion site line prefix (as in test 162).
* It is derived from analyzing the block default body (the lines inside default) to infer a baseline indent.

This requires:

1. Detect that the block opening tag is standalone in parent.
2. Compute intrinsic indent from the default body:

   * Typically: look at the first non-empty line in the default body and take its leading whitespace.
3. When substituting override body:

   * Remove override body’s own minimum indent (or treat it as raw) depending on rules.
   * Add the intrinsic indent.

### 8.2 Nested block reindentation (spec test 164)

Spec statement:

> “Nested blocks are reindented relative to the surrounding block.”

The parent has nested blocks inside a block:

* Outer block includes inner `{{$nested}}...{{/nested}}`.

When child overrides `nested` with content:

* That override must be reindented relative to the indent of the outer block expansion.

This requires a proper **indentation frame stack**:

* Each block expansion pushes a frame describing:

  * definition indent (where default body was defined)
  * expansion indent (where inserted)
  * intrinsic indent (optional)
  * current “base indent” for nested blocks

Then nested block expansion uses the composed indent.

---

## 9. Recommended internal mental model for indentation

To implement the remaining tests cleanly, treat indentation as a transform:

### 9.1 Two-step transform

When you expand any injected template content (partial/parent/block body), do:

1. **Deindent** relative to a definition indent
2. **Reindent** relative to an expansion indent

Formally:

* `out = reindent(deindent(content, defIndent), expIndent)`

Where:

* `defIndent` = indentation baseline determined at the definition site.
* `expIndent` = indentation baseline determined at the expansion site.

### 9.2 What counts as definition indent?

For blocks, definition indent can come from:

* The whitespace prefix before the block tag when standalone.
* Or the whitespace found inside the default body (intrinsic indent).

In test 162:

* Definition indent is the child’s default body indentation (4 spaces), which is removed.
* Expansion indent is the parent site indentation (2 spaces), which is added.

In test 163:

* Expansion indent is *not enough*.
* Definition indent of override body is *none*, but the parent default body has intrinsic indent (2 spaces).
* That intrinsic indent becomes the effective expansion indent for override lines.

### 9.3 Nested blocks require stacking

When a block is expanded inside another block, the **inner block’s expansion indent** is relative to the outer block’s expansion frame.

So you need:

* A stack of frames representing current indentation context.

Each frame may carry:

* `frame.expIndent` — indent applied to lines emitted in this frame.
* `frame.defIndent` — indent to strip from content before applying expIndent.
* `frame.intrinsicIndent` — indent derived from default body (optional).
* `frame.baseIndentForNested` — computed indent that nested blocks should inherit.

---

## 10. Approaches to finish inheritance spec (design options)

This section lists viable implementation approaches, with pros/cons. Choose one for Stage 2.

### Approach A — “Runtime string transform” (minimal compiler changes)

**Idea**:

* Keep current token program largely unchanged.
* At block expansion time, compute indentation transforms and apply them by string scanning.

How:

* When rendering a block body (default or override), call a helper:

  * `APPLYINDENT(body, stripIndent, addIndent, crlfMode)`

* For intrinsic indentation:

  * compute `stripIndent`/`addIndent` based on parent default body analysis.

* For nested blocks:

  * maintain a runtime indentation stack and pass effective indents into nested expansions.

Pros:

* Smallest compile changes.
* Easier to integrate with existing EVALREF chunking (apply transform chunk-by-chunk).

Cons:

* Risk of repeated scans (performance) if naïvely implemented.
* Harder to keep identical behavior across scalar/ref modes unless helper is carefully dual-mode.

### Approach B — “Compile-time indentation annotations” (preferred when feasible)

**Idea**:

* Compute and store indentation parameters during compile in the tokens.
* At runtime, indentation application becomes cheap and predictable.

Compile stores:

* whether a block start is standalone
* whitespace prefix
* for block defaults: intrinsic indent computed from default content
* for each block region: the exact start/end offsets and baseline indent

Runtime then:

* selects override or default
* applies a small, deterministic indentation transform

Pros:

* Fast runtime.
* Less dynamic guesswork.
* Easier to debug (tokens show indent values).

Cons:

* Compiler becomes more complex.
* Must be careful with ref input (content not contiguous).

### Approach C — “AST of nested templates” (heavy but robust)

**Idea**:

* Build a proper AST: nodes for Text, Var, Section, Parent, Block, etc.
* Evaluate AST recursively.
* Indentation is naturally modeled by passing an indent context down the tree.

Pros:

* Best correctness story.
* Easiest to reason about nested indentation.

Cons:

* Big rewrite risk.
* Might reduce performance unless optimized.
* Harder to maintain current token-program design.

### Approach D — “Hybrid: keep tokens but model blocks as mini-programs”

**Idea**:

* Keep TOK as a flat program, but for blocks store:

  * a sub-program for default body
  * a substitution table mapping block name → override sub-program

During parent expansion:

* Evaluate parent program but when encountering a block token, dispatch to the chosen sub-program under the **current parent context stack** and **current indent frame**.

Pros:

* Strong correctness and scope handling.
* Avoids raw string slicing of large spans.
* Works well with streaming output.

Cons:

* Requires token program to support nested sub-programs.
* More moving parts.

---

## 11. Practical implementation notes for Stage 2

### 11.1 Keep invariants that tests implicitly depend on

* No re-interpolation of interpolated values.
* Delimiter isolation:

  * partial and parent compile must start with default delimiters.
* Missing partial/parent renders as empty.
* Data context does not override block substitution.
* Block substitution scope is parent-local at expansion site.
* Scalar and ref paths are identical.

### 11.2 Avoid MAXSTRING traps

* Don’t build huge intermediate strings.
* Prefer streaming helpers that:

  * accept either a scalar string OR an output root
  * emit line-by-line or chunk-by-chunk

If you must transform indentation:

* Implement transform in a way compatible with `EVALREF` so it doesn’t require concatenating the entire body.

### 11.3 CRLF conversion refactor point

You noted this line (or equivalent):

* `I $G(TOK("meta","crlf")) S OUT=$$LF2CRLF^MIOTPL2(OUT)`

This is correct semantically but costs a second full pass.

When implementing indentation transforms, consider doing **newline-aware output** directly:

* If output mode is CRLF, emit `\r\n` as you go.
* If LF, emit `\n`.

That lets you remove (or reduce) the final conversion pass, especially in streaming (ref) mode.

### 11.4 Debugging instrumentation suggestions

When working on tests 163/164, add internal traces (guarded by a debug flag) that print:

* For each block expansion:

  * block name
  * chosen content: default vs override
  * defIndent, expIndent, intrinsicIndent
  * computed “strip” indent and “add” indent

Also dump the block’s raw body before/after transform.

---

## 12. What information a human/LLM needs to finish the spec

To complete `_inheritance.json` 100%, the implementer needs:

1. Where MIOTPL2 represents:

   * parent tags
   * block tags
   * standalone detection results
   * indentation fields
   * stored default body boundaries

2. Where MIOTPL2 executes:

   * parent expansion
   * block substitution selection
   * block body evaluation under parent scope

3. Where indentation transform is currently performed:

   * partial indentation
   * parent indentation
   * block reindentation

4. How EVALREF emits output:

   * chunk boundaries
   * newline normalization

5. How the code decides truthiness and resolves names.

This doc gives the conceptual framework. In Stage 2, you’ll map these concepts onto the actual MIOTPL2 labels/functions.

---

## 13. Checklist for Stage 2 implementation plan (suggested)

**Goal:** enable and pass TEST163 + TEST164 without regressing anything else.

1. Enable TEST163 first and make it pass.

* Implement intrinsic indentation detection:

  * Only when parent block opening tag is standalone.
  * Determine intrinsic indent from parent default body.
  * Apply that indent to override body when expanding.

2. Enable TEST164 next.

* Add indentation frame stack for nested expansions.
* Ensure inner block reindentation composes correctly.

3. Ensure both scalar and ref paths behave identically.

* Add a shared helper for indentation transform that can emit to scalar or ref.

4. Re-run:

* Full `MIOTEST^MIOTPL2`
* `MIOTESTMODES^MIOTPL2` (perf/big/min)
* The inheritance tests suite.

5. Then address performance refactors (optional third step):

* Move CRLF conversion into streaming output.
* Avoid double scans of long output.

---

## Appendix A: Quick mapping of spec tests to engine features

* TEST138–143: block defaults behave like normal templates (vars/sections/inverted).
* TEST144: parent injection equals partial injection.
* TEST145–152: substitution overrides + isolation from data context.
* TEST154–156: recursion + multi-level inheritance precedence.
* TEST157–158: ignore raw text inside parent body but still parse `$` blocks.
* TEST159: parent-scope evaluation of override bodies.
* TEST160: standalone parent indentation.
* TEST161–162: standalone blocks + deindent/reindent at expansion site.
* TEST163: intrinsic indentation.
* TEST164: nested block reindentation.

---

## Appendix B: Terminology used in this document

* **Parent template**: the template referenced by `{{<name}}...{{/name}}`.
* **Child template**: the template containing the parent tag.
* **Block default**: body between `{{$x}}` and `{{/x}}` in a defining template.
* **Block override**: body between `{{$x}}` and `{{/x}}` inside a parent tag.
* **Standalone**: tag on a line by itself (ignoring indentation) that triggers whitespace stripping and indentation capture.
* **Intrinsic indent**: indentation derived from default block content, used when opening tag is standalone.
* **Deindent/Reindent**: removing indentation from definition site, adding indentation at expansion site.
