MIOTPL2 internal engine guide (current state) + roadmap for full _inheritance.json

This is an internal “read the code like a machine” document aimed at:

a human dev coming in cold, and

an LLM that needs to reason precisely about what MIOTPL2 is doing today and what still needs doing to finish the official Mustache inheritance spec.

It’s written to match what’s observable from your test harness (MIOTPLT), the public entrypoints you’re calling (COMPILE, COMPREF, EVAL, EVALREF, etc.), and the token/debug fields you’ve shown (TOK(n,"k"), TOK(n,"t"), TOK(n,"indent"), TOK("meta","crlf"), …).

0) Big picture

MIOTPL2 is a two-phase engine:

Compile: parse template text into a compact token stream (array TOK).

Eval: walk TOK using a context stack, optional partials/parent loader, and optional block override stack, producing output either:

as a scalar string (highest performance, but can hit YottaDB max-string limits), or

into a reference buffer (GB-safe chunk output), later concatenated by the caller if needed.

Your harness (RUNTEST1) validates both:

COMPILE + EVAL (scalar path), and

COMPREF + EVALREF (chunk/reference path, with intentionally tiny chunk size to stress boundary logic).

Inheritance in Mustache (“parent tags” {{<name}}...{{/name}} + “block tags” {{$block}}default{{/block}}) adds a third conceptual stack:

a block-override namespace that is not the context stack and is not the partial namespace.

1) Key public entrypoints (what callers rely on)

From MIOTPLT, MIOTPL2 exposes at least these stable APIs:

Compilation

COMPILE^MIOTPL2(templateString,.TOK,.ERR)

COMPILEA^MIOTPL2(.arrayOfChunks,.TOK,.ERR) (for chunked input)

COMPREF^MIOTPL2(inputRootRef,.TOK,.ERR) (for global/local reference input)

Evaluation

EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR) → scalar OUT

EVALREF^MIOTPL2(.TOK,.CONF,.CTX,outputRootRef,.ERR) → chunk OUT in @outputRootRef@(n)

Rendering helpers (file-based)

RENDER^MIOTPL2("main.html",.CONF,.CTX,.OUT,.ERR) (reads file, compiles, evals)

RENDERPAGE^MIOTPL2("page.html","layout.html",.CONF,.CTX,.OUT,.ERR) (layout/page composition)

READFILE^MIOTPL2(path,.TXT,.ERR) (file → scalar)

plus cache usage under ^MIO("TPL","CACHE",...)

Common helper used by harness

APPREF^MIOTPL2(ROOT,N) (builds a subscript reference like ROOT@(N) safely)

Contractually important: Your test harness intentionally runs everything twice (scalar vs ref). Any inheritance implementation must remain identical across both output modes.

2) Data model: what a “token stream” is in MIOTPL2

MIOTPL2 compiles into TOK, which is a sparse MUMPS local array with:

TOK("meta",...) values affecting output & parsing

TOK(1..N,...) individual tokens (“ops”)

From your debug snippets, tokens commonly carry:

TOK(i,"k") — “kind” / operator family
Examples you’ve shown: "parent", "block".

TOK(i,"t") — subtype or internal tag classification string
Example you’ve shown: "parS" (likely “parent section” token).

TOK(i,"raw") — raw tag text (helpful for debug/roundtrip)

TOK(i,"m") — mode/flags for standalone/indent logic (your tests expose m=5 in some traces; treat as internal bitfield)

TOK(i,"bpos") — base position/offset into the original template or scan window (used for error reporting / indentation decisions)

TOK(i,"indent") — indentation captured for standalone behaviors (used for partial/parent/block reindentation)

And meta:

TOK("meta","crlf") — newline style detected during compile

likely other compile-time flags for safe parsing / max-string handling

The crucial invariant: tokens must be fully sufficient for evaluation without needing to rescan the original template (except file loading for partials/parents).

3) Newline model + CRLF handling (current behavior and why it matters)
What you currently do

Compile detects newline style (LF vs CRLF), even across chunk boundaries (see MIOTF133).

Evaluation produces output with correct newline normalization.

There is/was a post-step like:

I $G(TOK("meta","crlf")) S OUT=$$LF2CRLF^MIOTPL2(OUT)
which is correct but costly for large templates because it re-walks output.

Why inheritance complicates this

Inheritance + indentation can introduce many injected segments. If CRLF conversion or indentation are done by “post-processing the whole output” repeatedly, cost multiplies quickly.

Best internal mental model

Treat newlines as a render-time concern, not a post-pass:

When emitting a newline, emit the correct sequence (LF or CRLF).

When indenting injected content, handle line prefixes at emission time (see §9).

That’s the direction you already hinted at: fold normalization into the main render loop.

4) Context stack rules (baseline Mustache behavior)

Even though your focus is inheritance, inheritance correctness depends on:

dotted-name resolution,

truthiness rules,

sections/inverted sections pushing/popping contexts,

not re-interpolating interpolated output.

Your harness already covers those thoroughly (interpolation.json, sections.json, inverted.json, …). Inheritance should reuse those mechanisms unchanged.

Key principles (as your test comments describe):

. resolves to the current stack top.

Dotted name a.b.c is resolved stepwise, each step against the prior result (not against the whole outer context again).

Falsey handling: empty / missing behave as falsey (plus special-casing "false" strings in your tests).

Interpolated values are not re-rendered as templates (see “Mustache Injection” tests).

5) Partials vs Parents: shared loader rules

Mustache says Parents live in the partial namespace: “injecting a regular Partial is exactly equivalent to injecting a Parent without making any substitutions.”

Your implementation should therefore share:

template lookup rules (root/ext, path semantics),

caching of read/compiled templates,

delimiter isolation rules:

delimiters set outside a partial/parent do not affect parsing inside the injected template

delimiters set inside the partial do not leak back outward

Indentation (partials)

Already implemented in MIOTPL2:

If a partial tag is standalone, capture indentation from the whitespace before the tag on that line, and prepend it to each injected line.

Parents must behave the same for the parent injection part.

6) Mustache inheritance model (what must be true)

Inheritance introduces two special constructs:

A) Parent tags — {{<parentName}}...{{/parentName}}

Meaning: inject/render another template (“parent”) at this location, but with possible block substitutions defined inside the tag body.

Rules:

The tag name must be a non-whitespace sequence not containing the closing delimiter.

If parent template missing → inject empty string.

Render parent against the current context stack (at the location of the tag).

Standalone behavior same as partials: captured indentation is applied to each line of parent output.

Special rule about the content between {{<...}} and {{/...}}:

It may contain junk text, but that text is ignored.

Only $ blocks inside are meaningful, and they define overrides (“arguments”) to be applied when rendering the injected parent.

B) Block tags — {{$name}} default {{/name}}

Blocks serve two roles:

Parameter definition (in templates generally):

In any template, {{$x}}DEFAULT{{/x}} defines a named “slot”

If there is no override in the active override map, render DEFAULT.

Argument/override (inside a Parent tag):

Inside {{<parent}} ... {{/parent}}, a {{$x}}OVERRIDE{{/x}} supplies override content for parent’s $x slot.

Block names are in their own namespace:

Not the context namespace

Not the partial namespace

“Data does not override block” tests enforce this.

7) The “block override stack” (the extra structure you need)

To evaluate inheritance correctly and support multi-level nesting, you need a structure like:

OVR — a map: OVR(blockName) = overrideTokenStream (or pointer/ref to it)

and conceptually a stack of these maps, because a template may itself be rendered as part of another parent call.

Precedence rule (multi-level)

Top-level substitutions win. Concretely:

If we are rendering template T with “current override map” = OVR_in,
and T contains a parent call {{<P}} overrides_from_T {{/P}},
then the overrides used when rendering P should be:

OVR_for_P = merge(OVR_in, overrides_from_T) where:

if a name exists in OVR_in, keep it (outer wins)

else take it from overrides_from_T

That single rule explains:

Multi-level inheritance (c beats p beats o beats g)

Multi-level no-sub-child (if top didn’t provide, next layer does)

8) What MIOTPL2 appears to implement today (based on passing tests)

Your MIOTF206 suite (tests 138–164) mirrors the official _inheritance.json semantics.

From your tests, MIOTPL2 already supports at least:

block default rendering (outside any parent call)

blocks containing variables/sections/triple-mustache

parent calls with default slots rendered inside injected parent

block overrides supplied in parent call body

ignoring random text in the parent call body except $ blocks

block scope evaluated in parent template context (fruit = bananas)

standalone parent indentation (test 160)

standalone block behavior + reindentation (161–162)

intrinsic indentation and nested reindentation (163–164) — these were historically the tricky ones

Even if you currently have 163/164 commented in the suite sometimes, the design needs to treat them as first-class invariants, because they are the “real” spec pain points.

9) Indentation and reindentation: the hardest part (and how to reason about it)

There are three indentation mechanisms that can stack:

Standalone parent indentation
Applies when {{<parent}}...{{/parent}} is standalone:

capture indent I_parentCall

after rendering parent output, prefix each line with I_parentCall

Standalone block indentation at expansion site
When a block tag in the parent template is standalone, it has an indent context (and may also have “intrinsic” indent; see #3).

Block reindentation (definition-site vs expansion-site)
When inserting override content into a block:

remove indentation that comes from how the content was defined

add indentation that comes from where it is expanded

9.1 A robust internal representation (recommended)

For each block definition token in a template (the place where content will be inserted), store:

IND_EXP — expansion indent:

whitespace preceding the standalone opening tag on its line (if standalone)

else "" (inline expansion has no implicit prefix)

IND_INTR — intrinsic indent:

only relevant when the opening tag is standalone but has no indent

computed from the default body’s indentation (see below)

For each override captured inside a parent call, store:

IND_DEF — definition indent of the override content

computed from the override body itself (often from its minimal common indentation across lines)

Then, when expanding:

render override output as lines

dedent(lines, IND_DEF)

indent(lines, effectiveIndent) where:

effectiveIndent = IND_EXP if IND_EXP not empty

else if IND_EXP empty and tag is standalone: IND_INTR

else ""

This is exactly what test 163 is checking:

expansion site has no indent (IND_EXP="")

but opening tag is standalone and default body has IND_INTR=" "

override lines must get " " prefixed

9.2 How to compute intrinsic indent (test 163)

Given parent template block:

{{$block}}
  default
{{/block}}


The opening tag line has no indent. Yet the default body clearly shows that the “slot” is conceptually indented by two spaces.

Intrinsic indent algorithm (practical):

Look at the default body lines (raw text, after tokenizing but before rendering).

Ignore empty lines.

For each non-empty line, count leading spaces/tabs.

Take the minimum leading whitespace prefix among those lines.

That minimum is IND_INTR.

That makes nested/relative indentation behave like “dedent to minimum indentation”.

9.3 Nested block reindentation (test 164)

This is the “composition” property:

Outer override may be dedented/indented as it is inserted.

Inside that outer override, there can be inner block placeholders.

When inner blocks expand, their indentation must be computed relative to the already-transformed outer content.

Implementation implication:

indentation cannot be purely “string post-processing” at the end

it must be handled in a way that respects nesting, ideally token-driven

The safest approach is to make indentation part of the evaluator state:

maintain a current “line prefix” (indent) stack

when entering a block expansion, push a derived prefix, and pop on exit

emit text/newlines such that prefix is inserted at line starts

This avoids O(n²) rescans and naturally composes for nesting.

10) “Text inside parent tag is ignored” (tests 157–158): how to implement cleanly

Inside a parent call body:

{{<parent}} asdf {{$foo}}hmm{{/foo}} asdf {{/parent}}


Rules:

All raw text is ignored.

Only $ blocks are meaningful override definitions.

Those $ blocks must still be parsed fully (their bodies can contain any Mustache content).

Practical compile strategy:

While compiling a parent call body, run a normal parse, but:

discard text tokens and non-$ tags at the top level

whenever you see a $block section at the top level, capture it into the parent-call token’s override map

This is easiest if your parser already supports “mode flags” such as:

normal mode

inside-parent-call mode (only accept $ blocks as children)

If your current parser doesn’t have modes, a simpler approach is:

parse normally into a temporary token list

filter out everything except $ blocks, and attach those blocks to the parent-call token

11) Collision warning: MIOTPL “layout blocks” vs Mustache $ blocks

You have another feature:

{{#block:title}}...{{/block:title}} capturing into CTX("blocks","title")

and optionally overriding output via CTX("blocks","...") (tests 265–267)

This is not Mustache inheritance blocks. They must remain distinct:

Mustache blocks: {{$name}}...{{/name}}
live in inheritance override namespace

MIOTPL layout blocks: {{#block:name}}...{{/block:name}}
live in CTX("blocks",...) and are controlled by CTX("meta","captureBlocks")

When implementing _inheritance.json completely, ensure:

{{$x}} never consults CTX("x") or CTX("blocks","x")

{{#block:x}} never participates in inheritance override lookup

12) Approaches to finish/solidify full _inheritance.json support

Below are three viable implementation approaches. The best choice depends on your priorities (perf vs simplicity vs memory), but they all can be made correct.

Approach A — Token-level override maps (recommended for MIOTPL2)

Compile time

Parent call token stores:

parentName

overrideMap(name) -> overrideTokenSubtree

standalone indent for the parent call itself

Block definition token stores:

blockName

default-body tokens

expansion indent metadata (IND_EXP, IND_INTR)

Eval time

Evaluator carries:

context stack

override map stack

current line-prefix state for indentation

On parent call:

load/compile parent template tokens (cached)

compute merged overrides (outer wins)

eval parent tokens with merged overrides

apply parent-call standalone indent through the normal line-prefix mechanism

Pros

Correct nesting behavior naturally

No big string rescans

Matches your existing tokenized architecture

Cons

Requires careful “line-prefix” emission to avoid later post-processing

Needs a clean way to store token subtrees as override values

Approach B — Render overrides to strings, then reindent strings (simple, but can be costly)

Eval time

When expanding a block:

render override subtree to a temporary string (or temp output-ref)

dedent/indent by scanning the string

append to main output

Pros

Conceptually easy

Works without touching your core emitter much

Cons

Can become expensive, especially with nested blocks (risk O(n²))

Harder to integrate cleanly with CRLF normalization and high-perf mode

More temporary allocations (in MUMPS, that can matter)

Approach C — Compile-time “macro expansion” (usually not worth it here)

Expand parent templates into the caller token stream at compile time.

Substitute blocks at compile time.

Pros

Eval becomes very fast (single stream walk)

Cons

Complicated with runtime partial loading / missing parents

Harder with delimiter isolation and caching

Multi-level inheritance becomes “compile explosion” unless heavily cached

For MIOTPL2’s design (file-based templates, caching, multiple input/output modes), this is typically the least attractive.

13) What to verify next (even if tests “pass” today)

To make _inheritance.json genuinely “done” and future-proof:

Run the official _inheritance.json through the same JSON runner model

You already have RUNJSONSPECSPART for partial-writing tests.

Add/enable a RUNJSONSPECSINHERIT("./tests/data/_inheritance.json") (or similar) that:

writes partials to disk per test

runs the template once

cleans up

Verify identical behavior across scalar vs ref eval

Your harness already enforces this; keep it that way for any new inheritance tests.

Verify delimiter isolation specifically for parent tags

You’ve handled partials; ensure parent injection uses the same “compile injected template in isolation” behavior.

Stress nesting depth

Inheritance + recursion can produce deep eval recursion.

If your evaluator uses MUMPS call stack heavily, you may eventually want an iterative evaluator loop (explicit stack) for safety.

CRLF + indentation interaction

If you implement “indent prefix on newline emission,” ensure CRLF is emitted as a unit and indentation is applied after the newline, not between \r and \n.

14) Suggested “stage plan” for the next implementation phase (after this doc)

Since you want staged implementation:

Stage 1 — Make inheritance internals explicit (even if behavior is already correct)

Document and centralize:

override map merge rule (outer wins)

block lookup rule (override namespace only)

parent-call body filtering rule (ignore everything except $ blocks)

Stage 2 — Unify indentation + CRLF into the emitter

Replace any “post-pass” LF→CRLF conversion with newline-aware emission.

Ensure indentation is applied at emission-time (line-prefix stack).

This will also address your performance concern about looping over output again.

Stage 3 — Formalize block indentation metadata

Store IND_EXP and IND_INTR explicitly on block tokens.

Store IND_DEF for override subtrees (or compute on-demand once and cache).

Stage 4 — Add/enable the full official JSON suite runner for _inheritance.json

So you’re not relying only on manually mirrored tests long-term.

15) Minimal “cheat sheet” for someone reading MIOTPL2.m

When a new dev/LLM opens MIOTPL2.m, tell them to search for these anchors:

COMPILE / COMPREF / COMPILEA — input handling + tokenizer entrypoints

EVAL / EVALREF — evaluator entrypoints

“standalone” logic — usually a function that detects whether a tag is alone on its line

partial loader (often something like GETPART, LOADPART, READTPL)

cache access: ^MIO("TPL","CACHE"...

inheritance keywords: handling for operators < and $

indentation helpers: something like DEINDENT, REINDENT, INDENTALL, or per-token indent fields

CRLF helpers: LF2CRLF, newline detection in compile meta

The goal is to quickly map:

parsing (text → tokens)

evaluation (tokens → output)

injection (partials/parents)

override lookup (blocks)

indentation/newlines (render correctness + performance)