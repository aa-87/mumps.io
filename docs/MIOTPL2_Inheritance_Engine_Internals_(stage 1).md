# MIOTPL2 – Internal Architecture & Mustache Inheritance Implementation Notes (Stage 1)

This document is meant to be a **drop-in “brain dump”** for a human (or an LLM) to quickly and accurately understand MIOTPL2’s current behavior and code shape, then complete the remaining Mustache inheritance edge-cases from the official `/_inheritance.json` spec.

It is written assuming:

* **All current MIOTPL2 tests pass** (including the inheritance tests currently enabled in `MIOTPLT`, i.e. up through `TEST162`).
* The remaining official inheritance behaviors are still pending or fragile (notably `Intrinsic indentation` and `Nested block reindentation`, i.e. `TEST163/TEST164`, which are currently commented out in `MIOTF206`).

---

## 1) Executive summary

MIOTPL2 is a Mustache-like engine implemented in M (YottaDB/GT.M), with two key design goals:

1. **Performance on normal-sized templates** (scalar template input → scalar output).
2. **Safety on very large templates** (GB-scale) by supporting:

   * **reference-mode input** (template text stored in chunks)
   * **reference-mode output** (rendered output stored in chunks)

The core pipeline:

1. **START^MIOTPL2(.CONF)**: prepares configuration defaults.
2. **COMPILE^MIOTPL2(TPL,.TOK,.ERR)**: tokenizes and builds a compiled token array.

   * Variants exist: `COMPILEA` (array-of-chunks input), `COMPREF` (global-ref input)
3. **EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)**: renders into a scalar string.

   * Variant: `EVALREF` renders into a reference (chunked) output.
4. **RENDER^MIOTPL2(name,.CONF,.CTX,.OUT,.ERR)**: loads template files (and partials) using CONF root/ext rules, with caching.
5. **RENDERPAGE^MIOTPL2(page,layout,.CONF,.CTX,.OUT,.ERR)**: MIOTPL2’s “layout/page” helper that uses a separate “block:” feature (distinct from Mustache inheritance blocks).

### Current inheritance support status (based on MIOTPLT)

`MIOTF206` describes Mustache inheritance and runs tests `TEST138` through `TEST162` (and leaves `TEST163/TEST164` commented out). The official `_inheritance.json` contains tests that correspond directly to `TEST138`–`TEST164`.

**Most of the semantics are already implemented**:

* Default block content renders correctly.
* Blocks override defaults.
* Parent tags inject templates, can contain blocks.
* Text inside a parent call is ignored (except $ blocks are still parsed).
* Multi-level inheritance precedence works.
* Recursion scenario in spec matches expected output.
* Standalone parent + block + reindentation cases are largely handled.

**Remaining/fragile areas** (the ones that typically fail in Mustache engines):

* **Intrinsic indentation**: block open tag is standalone and has no indentation; indentation must be derived from the **default content** indentation.
* **Nested block reindentation**: when a block override contains nested blocks, the nested blocks’ output must reindent relative to the outer block after reindentation is applied.

---

## 2) Key concepts and namespaces

### 2.1 Mustache concepts (official spec)

* **Parent tag**: `{{<parentName}} ... {{/parentName}}`

  * Equivalent to injecting a partial **plus optional substitutions**.
  * “Parametric partial.”

* **Block tag**: `{{$name}} default {{/name}}`

  * Defines a **parameter slot** named `name`.
  * Default content between open/close renders if not overridden.
  * When used inside a Parent tag call, it becomes an **argument** passed into the parent template.

* **Override / substitution**:

  * If a child calls `{{<parent}}{{$a}}...{{/a}}{{/parent}}`, then inside `parent`, any `{{$a}}...{{/a}}` block is replaced by the override.

* **Namespace rule**:

  * Block names (parameters/arguments) are in a namespace distinct from:

    * Context data (`CTX`)
    * Partials/parent templates

### 2.2 MIOTPL2 concepts

MIOTPL2 has *two* “block-ish” features:

1. **Mustache inheritance blocks**: `{{$foo}} ... {{/foo}}`

   * These are the ones referenced by `_inheritance.json`.

2. **MIOTPL2 layout blocks**: `{{#block:title}} ... {{/block:title}}`

   * Used by `RENDERPAGE^MIOTPL2` and tests like `MIOTF122`, `TEST265–TEST267`.
   * Stored in `CTX("blocks",name)`.

**Important:** Do not conflate these.

* Mustache inheritance blocks are a *parameter-substitution system*.
* MIOTPL2 layout blocks are a *capture/override system* (like a page defining `head` for a layout).

A good rule for implementation:

* Keep Mustache inheritance override maps in a **separate local structure** during EVAL (e.g. `OVR(...)`).
* Only use `CTX("blocks",...)` for the `block:` feature.

---

## 3) Data structures

### 3.1 Configuration (`CONF`)

From tests, relevant keys include:

* `CONF("templates","root")` : filesystem root for templates
* `CONF("templates","ext")`  : extension (can be empty)

MIOTPL2 also appears to store defaults in `^MIO("CONF")`, which tests copy into CONF.

### 3.2 Context (`CTX`)

A M local array holding data for interpolation/sections.

Special meta keys used by MIOTPL2 tests:

* `CTX("meta","captureBlocks")` toggles layout-block capturing (`#block:`).

Mustache inheritance spec requires:

* **Block substitutions must not be pulled from CTX**.
* CTX can have keys that match block names, and that must NOT override the block substitution.

### 3.3 Tokens (`TOK`)

`COMPILE^MIOTPL2` produces `TOK(n,...)` entries.

Known fields (from failures you posted earlier):

* `TOK(i,"t")` : token type / opcode (e.g., `"text"`, `"parS"` etc)
* `TOK(i,"k")` : name / key
* `TOK(i,"raw")` : raw tag text
* `TOK(i,"bpos")` : start position in template
* `TOK(i,"indent")` : indentation captured for standalone tags (used in partials/parents/blocks)
* `TOK(i,"m")` : mode/metadata (used internally)

**Note:** exact token naming may differ in the code; this doc describes *required semantics* rather than a strict schema.

---

## 4) The two execution modes (scalar vs reference)

MIOTPL2 deliberately runs each test twice (`RUNTEST1`):

1. **Scalar template → scalar output**

   * `COMPILE^MIOTPL2(TPL,.TOK,.ERR)`
   * `EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)`

2. **Reference template → reference output**

   * Build `INROOT` chunks: `^TMP($J,"MIOTPLT","IN",n)=...`
   * `COMPREF^MIOTPL2(INROOT,.TOKR,.ERRR)`
   * `EVALREF^MIOTPL2(.TOKR,.CONF,.CTX,OUTROOT,.ERRR)`
   * Reassemble chunks into `OUT2`

### Why this matters for inheritance

Inheritance + indentation often needs:

* Scanning template text to determine standalone and indentation.
* Splitting/joining by newline boundaries.
* Dedenting and reindenting overridden blocks.

All of that must work identically when:

* the template is provided as **chunks** (tag boundaries can cross chunk boundaries)
* output is produced as **chunks** (line-by-line indentation must not require concatenating huge strings)

The ideal approach is to implement indentation logic in a **streaming-friendly** way:

* determine indentation metadata at **compile-time**, store it on tokens
* during render, apply indentation while writing output (scalar writer or chunk writer)

---

## 5) Parsing / compiling workflow

### 5.1 High-level scan loop

The compiler walks the template and emits:

* `text` tokens (raw text segments)
* tag tokens (interpolation, section, inverted, partial, parent, block, etc)

**Critical invariant:** the scan loop must always advance the input cursor.

#### Infinite-loop failure mode you observed

You posted repeated tokens:

```
TMP(47147,"t")="text"  TMP(47147,"v")="*"
TMP(47148,"t")="text"  TMP(47148,"v")="*"
...
```

This pattern almost always indicates:

* the parser hit a case where it **emits a 1-character text token**
* but **does not advance** the source position correctly, so it repeats.

**Recommended hard guard in the parser**:

* Keep `prevPos` and assert `pos>prevPos` each outer-loop iteration.
* If not, forcibly advance by 1 and/or raise an error.

This guard is especially important in `COMPREF`/chunked input, where:

* boundary logic around `{{` or `}}` can cause a “no match” branch that forgets to advance.

### 5.2 Standalone detection (core Mustache rule)

MIOTPL2 already implements standalone behavior for:

* sections / inverted sections
* comments
* partials
* (and now parent + block, per inheritance tests)

Standalone means:

* A tag is “standalone” if it is the only non-whitespace content on its line.
* When standalone, the entire line containing the tag is removed from output.
* The indentation (whitespace before the tag) is captured and used for partial/parent indentation.

MIOTPL2 appears to store this indentation on tokens via `TOK(i,"indent")`.

### 5.3 CRLF handling

MIOTPL2 has test coverage for CRLF detection and preservation (`MIOTF131–MIOTF133`).

Key requirements:

* If the template uses `\r\n`, output should generally preserve `\r\n` (or consistently normalize based on meta rules).
* When a value contains CRLF already, it must not be doubled into `\r\r\n`.
* Chunk boundaries can split CR and LF across chunks; CRLF detection must handle that.

**Performance note** (from your earlier comment):

* Avoid a second pass like `LF2CRLF` over the entire output.
* Prefer to normalize newlines **while writing output** (streaming), if CRLF mode is enabled.

---

## 6) Rendering workflow

### 6.1 Context stack model

Mustache requires a context stack:

* top of stack is current context
* name resolution searches from top down
* dotted-name resolution uses “former resolution” as the only context for later parts

MIOTPL2 tests cover this thoroughly (interpolation + sections specs).

### 6.2 Output writers

MIOTPL2 effectively has two writers:

* Scalar writer: appends into `OUT` string (fast)
* Ref writer: appends into `OUTROOT(n)` chunks (GB-safe)

For inheritance indentation work, it’s crucial that indentation can be applied without:

* concatenating huge strings
* rescanning full output

A clean strategy:

* have a single abstracted `WRITE(text)` primitive
* optionally wrap it with an `INDENTING_WRITER(indent)` that prepends indent after each newline

---

## 7) Mustache inheritance semantics (what must be true)

This section restates the official `_inheritance.json` semantics in “implementation-ready” form.

### 7.1 Block tokens outside any parent

Template: `{{$title}}Default title{{/title}}`

Behavior:

* If no override map is active, render **default content**.
* Default content must fully support all Mustache features (variables, sections, inverted, etc).
* Output must *not* re-interpolate injected mustache from data unless explicitly required by normal Mustache rules.

### 7.2 Parent tokens (parametric partial)

Template: `{{<parent}} ... {{/parent}}`

Behavior:

* Load template named `parent` from partial namespace.
* Parse/render it using default delimiters as initial delimiters (set delimiter tags in the child do not affect the parent parse).
* Render the parent with **the same context stack** at the site of the parent tag.

Inside the parent call:

* Parse `$block` tags so overrides can be collected.
* Ignore any other literal text or tags (spec tests 157/158).

### 7.3 Overrides precedence

When a parent template contains `{{$a}}DEFAULT{{/a}}` and the child call supplies `{{$a}}OVERRIDE{{/a}}`:

* OVERRIDE wins.

In multi-level inheritance:

* substitutions from the **top-level child** take precedence over substitutions defined by intermediate parents.

Meaning:

* each parent call supplies overrides for the template it injects
* but if an outer override for the same parameter exists, it must dominate

### 7.4 Scope of substituted blocks

**Critical** (test 159):

* Substituted block content is evaluated in the **context of the parent template** at the block site.

So:

* Never pre-render the override content in the child context.
* Store override content as tokens (AST) and render those tokens later in the parent’s context.

---

## 8) The hard part: indentation rules

Most inheritance bugs come from indentation.

### 8.1 Parent indentation (standalone parent)

If the parent tag is standalone, capture indentation `IND` (whitespace before the tag). When injecting the parent template output, **prepend IND to each line**.

Test 160 example:

Child:

```
Hi,
  {{<parent}}{{/parent}}
```

Parent content:

```
one
two
```

Expected:

```
Hi,
  one
  two
```

### 8.2 Block indentation (standalone block + reindentation)

Block indentation has two distinct concerns:

1. **Standalone-ness** of the block tags themselves (they can be standalone or inline).
2. **Reindentation** when overriding content:

   * remove indentation from the override as written
   * add indentation based on where the block expands in the parent

Test 162 example:

Child override:

```
{{$block}}
    one
    two
{{/block}}
```

Parent block site:

```
Hi,
  {{$block}}
  {{/block}}
```

Expected:

```
Hi,
  one
  two
```

Interpretation:

* The override’s `    ` indentation is **definition-site indentation**.
* The parent’s `  ` indentation is **expansion-site indentation**.
* Output should be override text with `definitionIndent` removed, then `expansionIndent` applied.

### 8.3 Intrinsic indentation (the missing spec piece)

Test 163:

Child override has no indentation:

```
{{$block}}
one
two
{{/block}}
```

Parent default has indentation:

```
Hi,
{{$block}}
  default
{{/block}}
```

Expected output:

```
Hi,
  one
  two
```

Meaning:

* When the **block opening tag is standalone**, and the tag line itself has little/no indentation, indentation should be derived from the **default content** inside the parent block.

We’ll call that derived indent: **intrinsicIndent**.

In this test:

* expansionIndent (tag line) = 0
* intrinsicIndent (from default body) = 2
* total indent applied to override = 2

### 8.4 Nested block reindentation (the second missing piece)

Test 164:

Child overrides `$nested`:

```
{{$nested}}
three
{{/nested}}
```

Parent injects grandparent with a `$block` which itself contains `$nested` default:

```
{{<grandparent}}
  {{$block}}
    one
    {{$nested}}
      two
    {{/nested}}
  {{/block}}
{{/grandparent}}
```

Grandparent:

```
{{$block}}default{{/block}}
```

Expected:

```
one
  three
```

Meaning:

* `$nested` override content (“three”) must be indented relative to its surrounding block.
* The outer block reindentation changes the baseline indentation, and nested blocks must reindent consistently within that new baseline.

---

## 9) Recommended internal model for inheritance

This section describes **how to represent inheritance in tokens** so the remaining tests can be implemented cleanly.

### 9.1 Represent overrides as token subtrees

When compiling a parent call:

```
{{<parent}}
  {{$a}}...{{/a}}
  {{$b}}...{{/b}}
{{/parent}}
```

During render:

* evaluate the body of the parent call **only to extract override definitions**
* store each override as:

  * `OVR("a","TOK") = tokenSubtreeForA`
  * `OVR("a","defIndent") = indent found in override default text`
  * `OVR("a","meta",...) = any needed indentation metadata`

Do **not** render those override tokens immediately.

### 9.2 Render parent templates with an “override environment”

When rendering parent template tokens:

* When hitting a block `{{$a}} DEFAULTTOKENS {{/a}}`:

  * if an override for `a` exists in the current override environment, render the override tokens instead
  * else render DEFAULTTOKENS

### 9.3 Multi-level precedence merging

When a parent template contains another parent call, there are two override maps in play:

* outer overrides (from the top child)
* inner overrides (defined by this intermediate parent)

Merge rule (outer wins):

```
Effective(name) = Outer(name) if exists
                else Inner(name) if exists
                else none
```

This rule is exactly what tests 155/156 require.

---

## 10) Approaches to finish `_inheritance.json` (and tradeoffs)

There are multiple viable strategies. This section documents them so “Stage 2” can choose the best one.

### Approach A — Pure render-time substitution (most straightforward)

**Idea:**

* Keep templates compiled as normal.
* At render time, parent tokens cause:

  1. load+compile parent template (cached)
  2. build override map from the child’s parent-call body
  3. render parent tokens using override map

**Pros:**

* Minimal compile-time complexity
* Easy to reason about correctness

**Cons:**

* Can be slower if parent templates are repeatedly compiled unless caching is robust

**Best fit if:** you already cache compiled tokens of templates and partials.

### Approach B — Compile-time “linking” (fastest at runtime, hardest to implement)

**Idea:**

* When compiling a template that contains a parent call, resolve it immediately:

  * load parent template
  * produce a combined token list where block slots are replaced with either:

    * the override subtree
    * or the parent default subtree

**Pros:**

* Fastest render-time

**Cons:**

* Complex cache invalidation
* Needs careful recursion handling
* Hard to keep memory under control

### Approach C — Hybrid: compiled templates + render-time override overlays (recommended)

**Idea:**

* Compile each template once.
* At render time, keep override maps as overlays.
* Block tokens consult the overlay.

**Pros:**

* Almost as fast as B (with cache)
* Much simpler than B
* Cleanly supports recursion and multi-level inheritance

**Cons:**

* Still needs good indentation metadata handling

### Approach D — Precompute indentation metadata during compile (recommended for tests 163/164)

**Idea:**

* At compile-time, compute and store on each block token:

  * `expansionIndent` (indent captured from standalone tag line)
  * `intrinsicIndent` (deduced from default content if open tag is standalone)
  * `defaultDedent` baseline (optional)

Then at render time:

* apply `indent = expansionIndent + intrinsicIndent` to overridden content

**Pros:**

* Makes rendering predictable
* Avoids rescanning strings during render
* Works for both scalar and ref output writers

**Cons:**

* Requires careful computation of intrinsicIndent from tokenized default body

---

## 11) How to compute indentation correctly (implementation-ready guidance)

This section gives concrete algorithms that match Mustache expectations.

### 11.1 Utility definitions

* `IndentOfLine(line)` = the maximal prefix of spaces/tabs before the first non-whitespace.
* `Lines(text)` = split by newline (LF or CRLF depending on detected mode).
* `NonBlank(line)` = line contains any non-whitespace.

### 11.2 Dedenting override content (definition-site)

Given override body as raw text (or as rendered text segments), compute `defIndent`:

1. Consider only lines after an initial newline if override starts with newline.
2. Collect indentation prefixes for all non-blank lines.
3. `defIndent` = the **minimum** indentation prefix among those lines.
4. Dedent each line by removing `defIndent` if present.

This is similar to “common indent” in many template engines.

### 11.3 Expansion indent (parent-site)

If the parent block open tag is standalone:

* `expansionIndent` is the indentation captured before the tag.

If not standalone:

* expansionIndent is typically `""` (no special indentation insertion)

### 11.4 Intrinsic indent (default-body-derived)

Only applies when:

* block open tag is standalone
* and the parent block’s default body provides indentation that should be preserved

Algorithm:

1. Examine the **default block body** tokens as text.
2. Identify the first non-blank line of default body.
3. Compute its indentation prefix relative to the block open tag line.
4. That prefix is `intrinsicIndent`.

Then:

* `totalIndent = expansionIndent + intrinsicIndent`

In test 163:

* expansionIndent = "" (0)
* intrinsicIndent = "  " (2)
* totalIndent = 2

### 11.5 Nested block reindentation

This is easier if you treat indentation as a **render-time environment**:

* When rendering a block (default or override), you render its body using a writer that:

  * dedents by `defIndent` (if rendering override)
  * then indents by `totalIndent` (expansion+intrinsic)

For nested blocks, the outer block’s writer becomes the baseline; nested blocks write into that baseline, so they automatically inherit the correct indentation.

If nested blocks themselves have their own indentation logic, the key is:

* apply outer writer indentation to **all** text written from inside, including nested blocks’ output.

---

## 12) Practical debugging checklist for Stage 2

### 12.1 When a test fails

1. Dump compiled tokens with their indentation metadata:

   * token index
   * token type
   * name/key
   * `indent` / `standalone` flags
   * block-specific metadata: `expansionIndent`, `intrinsicIndent`

2. For a failing block substitution, print:

   * override body raw
   * computed `defIndent`
   * parent computed `expansionIndent`
   * parent computed `intrinsicIndent`
   * final `totalIndent`

3. Run both scalar and ref mode; if only ref fails:

   * boundary logic around `\r\n`, `{{`, `}}` is likely.

### 12.2 Guard against infinite loops

Add a defensive check in compile loops:

* `if pos<=prevPos then error or pos=pos+1`

This prevents the “* * * * ...” runaway token emission.

---

## 13) What’s left to implement to finish `_inheritance.json`

Based on the test mapping:

* `TEST138–TEST162`: currently enabled and passing.
* `TEST163 (Intrinsic indentation)`: currently commented out; must pass.
* `TEST164 (Nested block reindentation)`: currently commented out; must pass.

The cleanest path to implement both is:

1. Ensure each block token in parent templates carries:

   * `expansionIndent`
   * `intrinsicIndent` (computed from default body)

2. Ensure each override definition carries:

   * `defIndent` (computed from its body)

3. Render substituted block bodies through an indentation-aware writer:

   * first dedent override body by `defIndent`
   * then indent by `expansionIndent + intrinsicIndent`

4. Make this indentation writer composable so nested blocks naturally follow the outer indentation.

---

## 14) Stage 2 deliverables (what we should implement next)

When you’re ready to proceed:

1. Enable `TEST163` and implement intrinsic indentation.
2. Enable `TEST164` and implement nested block reindentation.
3. Add a small *debug-only* toggle in CONF/CTX (optional) to trace indentation decisions.
4. Add an explicit parser progress guard to prevent infinite loops.

---

## Appendix A — Direct mapping: `_inheritance.json` → `MIOTPLT TEST138–TEST164`

The official JSON tests correspond directly:

* Default → TEST138
* Variable → TEST139
* Triple Mustache → TEST140
* Sections → TEST141
* Negative Sections → TEST142
* Mustache Injection → TEST143
* Inherit → TEST144
* Overridden content → TEST145
* Data does not override block → TEST146
* Data does not override block default → TEST147
* Overridden parent → TEST148
* Two overridden parents → TEST149
* Override parent with newlines → TEST150
* Inherit indentation → TEST151
* Only one override → TEST152
* Parent template → TEST153
* Recursion → TEST154
* Multi-level inheritance → TEST155
* Multi-level inheritance, no sub child → TEST156
* Text inside parent (parse $ tags) → TEST157
* Text inside parent (ignore) → TEST158
* Block scope → TEST159
* Standalone parent → TEST160
* Standalone block → TEST161
* Block reindentation → TEST162
* Intrinsic indentation → TEST163 (pending)
* Nested block reindentation → TEST164 (pending)
