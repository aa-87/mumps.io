Rewrite MIOTPL as a drop-in replacement (Mustache/Handlebars-correct) + Context Dump
You are replacing the entire MIOTPL.m routine in a YottaDB/GT.M codebase.
Goal:
# Produce a drop-in replacement for MIOTPL that:
1. Passes the existing test suite in MIOTEST.m with no changes to templates or tests.
2. Works with the current templates used by the MUMPS.IO web server package (layouts, partials, blocks, repo browser pages).
3. Implements Mustache semantics 100% correctly, and is compatible with the subset of Handlebars-like behavior already used by templates.
4. Is stable: no infinite loops, no duplicate output, no recursion stack blow-ups.
5. Is fast: compile templates once, cache tokens, avoid repeated parsing, minimize indirection overhead.

# Environment & Constraints
* Runtime: YottaDB (GT.M compatible M).
* No external dependencies.
* Production-safe.
* Naming conventions must match project:
* * Routine is named MIOTPL
* * Globals are under ^MIO("TPL",...)
* Write in a professional, heavily commented style, short simple sentences.
* Output must include:
* * Full MIOTPL.m routine (complete).
* * docs/MIOTPL.md markdown user guide.

# Required public entry points (must remain)
## These labels and argument orders must exist and remain compatible:
* START(CONF)
* PRECOMPILE(CONF)
* RENDER(NAME,CONF,CTX,OUT,ERR)
* RENDERPAGE(PAGE,LAYOUT,CONF,CTX,OUT,ERR)
* RENDERLAYOUT(LAYOUT,CONF,CTX,OUT,ERR)
* GETTOK(NAME,CONF,TOK,ERR)
* GETTOKFP(FP,CONF,TOK,ERR)

# Mustache / Handlebars Behavior Requirements (non-negotiable)
## Variables
* {{var}} => HTML-escaped value.
* {{{var}}} => unescaped.
* Dot paths supported: a.b.c.
* {{.}} is the current context scalar.
* Missing variables => empty string.

## Sections
* {{#key}}...{{/key}}:
* * If key is a list/array => iterate items, each item becomes new context.
* * If key is an object => push object context once (render body once).
* * If key is scalar truthy => render body once with current context.
* {{^key}}...{{/key}} inverted:
* * Render if key missing OR falsey OR empty list/object.
* Truthiness:
* * False: missing, empty string, 0, "0"
* * True: everything else.

## Partials
* {{> partial}} includes another template by name/path under template root.
* Must prevent traversal (..).
* Must enforce recursion prevention and max depth.

## Blocks (project-specific)
* {{#block:name}}...{{/block:name}} captures rendered body into CTX("blocks",name) and does not output in place.

* Layout flow:
* * RENDERPAGE renders the page capturing blocks into CTX("blocks",...), sets CTX("content"), then renders layout.

## Critical implementation requirements (to avoid known failures)
* Do not implement section evaluation by copying token subarrays (it caused duplication and missing nested sections).
* Implement evaluation using explicit token-range scanning and/or a single-pass evaluator with an explicit stack.
* Avoid recursive descent where possible. Prefer iterative execution using an explicit “frame stack”:
* * Frame fields: token array ref, current index, end index, current CTX, mode, accumulator.
* Ensure consuming a section advances index to matching end exactly once.
* Dot-path resolution must be safe and correct:
* * Use $NA and/or stable helper functions.
* * Do not rely on ambiguous constructs like @REF@(I) (indirection + subscripting pitfalls).
* List iteration must work for numeric and string subscripts.
* Ensure inverted sections correctly render on missing keys and empty lists.

## Caching / dev watch (must preserve)
* Cache hash ^MIO("TPL","CACHE",FP,"H")
* Cache compiled tokens ^MIO("TPL","CACHE",FP,"TOK",...)
* Respect CONF("templates","devWatchEnabled")
* Hash function H32() or equivalent must exist.

## Documentation requirements
* Create docs/MIOTPL.md with:
* Supported syntax + examples
* Truthiness rules
* Context model
* Lists vs objects behavior
* Partials + recursion prevention
* Layout + blocks behavior
* Performance notes
* Common debugging tips

# Context Dump (real failing cases you must handle)
## Known tests (names + expected behavior)

The following test behaviors exist and must pass:

1. Dotted list rendering
* Template behaves like: iterating cats.items list and outputting {{.}};
* Expected output: Core;Tools;
2. Packages object/list rendering
* Template outputs list of package objects, using {{name}}-{{desc}};
* Expected output includes single entry (no duplicates):
* * mio-web-Web Server;
3. TF125: Inverted sections correctness
- Template shape:
* {{^packages}}NONE{{/packages}}{{#packages}}YES{{/packages}}
- Expected:
* When packages has items: YES
* When packages empty/missing: NONE
4. TF126 deep nested context
- Template shape (conceptually):
* {{#groups.items}}G={{name}}:[{{#members}}{{name}},{{/members}}{{^members}}EMPTY{{/members}}];{{/groups.items}}
- Given CTX:
* CTX("groups","items",1,"name")="Core"
* CTX("groups","items",1,"members",1,"name")="Alice" or scalars depending on variant
* CTX("groups","items",1,"members",2,"name")="Bob"
* CTX("groups","items",2,"name")="Tools"
* No members under Tools
- Expected output:
* G=Core:[Alice,Bob,];G=Tools:[EMPTY];
- Also a scalar-member variant where members are scalars:
* CTX("groups","items",1,"members",1)="Alice"
* CTX("groups","items",1,"members",2)="Bob"
- Expected output still:
* G=Core:[Alice,Bob,];G=Tools:[EMPTY];

## Token shape constraint
- Tokens are stored as numeric TOK(n,...) nodes with fields:
* TOK(n,"t") in {text,var,secS,secE,part}
* text: TOK(n,"v")
* var: TOK(n,"k") key and TOK(n,"e") 1/0 escape
* secS: TOK(n,"k") key and TOK(n,"inv") 1/0 inverted
* secE: TOK(n,"k") key
* part: TOK(n,"k") name

# Known failure modes to avoid (must not regress)
* Duplicate output (sections evaluated twice).
* Missing nested section tokens due to “TMP copy” stripping markers.
* Stack overflow due to recursive loops or reprocessing token ranges.
* Incorrect inverted section logic when node missing vs empty.
* Incorrect list detection due to indirection precedence.

# Deliverables
* Full rewritten MIOTPL.m routine (complete file).
* docs/MIOTPL.md content (complete markdown).
* A short compatibility checklist verifying:
* * All required entry points exist unchanged
* * Syntax supported
* * How blocks/partials/layout are handled
* * How caching works
* * Why the evaluator cannot double-render sections

 Do not ask questions

 Do not ask me for clarification. Make reasonable decisions that maximize backward compatibility and pass the tests and templates described above.