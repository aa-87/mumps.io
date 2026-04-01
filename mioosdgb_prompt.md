# YottaDB-Aware AST Parser and Debugger Foundation Prompt (`MIOOSDGB*`)

## Objective

Build a **production-grade, YottaDB-syntax-aware parser + AST + canonicalizer + debugger support layer** in **pure MUMPS**, with all new routines namespaced under **`MIOOSDGB*`**.

This is not a generic ANSI M parser. It must target **YottaDB syntax specifically**, with behavior aligned as closely as technically possible to real YottaDB parsing rules and runtime expectations.

## Primary Goal

Create a **very fast, MAXSTRING-safe, well-tested, production-grade parser subsystem** for **YottaDB syntax**, to serve as the foundation for a future debugger and source tooling.

## Non-Negotiable Requirements

1. All new routines must be namespaced under **`MIOOSDGB*`**.
2. The parser must be **AST-aware**, with stable node types and precise source spans.
3. Initial feature set must include:
   - **Expand commands**: convert legal abbreviated commands into canonical full-command form.
   - **Compress commands**: convert commands into the shortest legal YottaDB/standard abbreviation form where safe.
   - **Typical debugger-required features**.
4. Implementation must be:
   - **MAXSTRING-safe**
   - **Very performant**
   - **Production-minded**
   - **Well tested**
5. Follow repo conventions:
   - no `ZSYSTEM`
   - tests quiet on success
   - all errors include `ERR("routine")` and `ERR("error")`
   - no `GOTO` in production code unless absolutely unavoidable and clearly justified
6. Do not hand-wave syntax coverage. If a syntax area is not yet implemented, state it explicitly and gate tests accordingly.
7. Preserve correctness over convenience. Do not simplify away real YottaDB syntax.

## YottaDB Syntax Coverage Target

The parser must explicitly support, model, and test at least the following YottaDB-relevant source features from the start:

- routine line structure
- optional labels
- numeric labels
- formallists on labels
- local labels with trailing `:`
- line-start delimiters including spaces and YottaDB-accepted tabs
- leading level indicators (`.`) for argumentless `DO` nesting
- multiple commands on a single line
- command postconditionals
- comments beginning with `;`
- comments at line start and in argument position
- entryrefs
- labelrefs
- routine refs
- indirection forms relevant to parsing/debugging
- intrinsic functions
- intrinsic special variables
- standard commands
- YottaDB `Z*` commands needed for debug-aware parsing/canonicalization
- string literals
- numeric literals
- operators
- expression trees
- argument lists
- whitespace/trivia preservation sufficient for round-trip tooling where practical

Do not assume that a generic M grammar is good enough.

## What “AST-Aware” Means Here

The AST must not be a thin token dump. It must be structured enough to drive debugger and source tooling later.

At minimum, define stable node families for:

- routine
- line
- label
- formallist
- level indicator
- command sequence
- command
- command postconditional
- command argument list
- comment
- expression
- literal
- variable reference
- global reference
- intrinsic function call
- intrinsic special variable
- entryref
- labelref
- indirection node(s)
- operator node
- parse trivia / preserved text where needed

Every meaningful node should carry:

- start offset
- end offset
- line number
- column when practical
- original text slice or recoverable span
- normalized/canonical form where useful

## Expand / Compress Behavior

Implement command canonicalization in a way that is safe and deterministic.

### Expand

Given valid YottaDB source, produce a normalized representation and/or rewritten source where:

- abbreviated commands are expanded to full command names
- canonical spacing is applied consistently
- source remains semantically equivalent
- comments and source locations remain traceable
- non-command identifiers are not accidentally rewritten

### Compress

Given valid source or AST, produce the shortest safe legal command spelling where:

- only legal abbreviations are used
- standard commands use only standard abbreviations
- YottaDB `Z*` commands are handled correctly
- ambiguity is never introduced
- rewritten source remains semantically equivalent

### Round-Trip Expectations

At minimum, validate:

- `parse -> AST -> expand`
- `parse -> AST -> compress`
- `parse(expand(x))` remains semantically equivalent
- `parse(compress(x))` remains semantically equivalent
- `expand(compress(expand(x)))` stabilizes

## Typical Debugger-Required Features

Design the parser/AST so a debugger layer can later use it for:

- line-to-source mapping
- label and entryref resolution assistance
- breakpoint placement validation
- statement boundary detection
- step into / over / out boundaries
- postconditional visibility
- command boundary visibility
- expression capture points
- variable/global reference discovery
- stack-context display helpers
- source rendering around `$ZPOS`-style locations
- routine/label navigation
- safe source expansion for human-readable debug display

Build the AST and helper APIs now so later debugger code does not need to re-parse raw text in ad hoc ways.

## Architecture Requirements

Design this as a clean subsystem, not a monolith.

Suggested routine split:

- `MIOOSDGBLEX` — lexer / scanner
- `MIOOSDGBPAR` — parser
- `MIOOSDGBAST` — AST construction/helpers
- `MIOOSDGBCAN` — expand/compress canonicalizer
- `MIOOSDGBDBG` — debugger-oriented query helpers
- `MIOOSDGBVAL` — validation / semantic checks
- `MIOOSDGBERR` — parse/diagnostic helpers
- `MIOOSDGBT*` — tests

You may rename or refine this layout, but keep the namespace and separation of concerns.

## Performance and MAXSTRING Requirements

The implementation must be safe for large routines and must avoid accidental string blowups.

Requirements:

- do not repeatedly concatenate large strings in quadratic ways
- prefer indexed spans/tables over copying full text repeatedly
- support parsing by line and by offset
- preserve enough raw source for diagnostics without duplicating huge payloads unnecessarily
- keep canonicalization incremental where practical
- document any unavoidable size limits

If any output may exceed safe limits, chunk it deterministically.

## Testing Requirements

Testing is a first-class deliverable.

Create a thorough test suite under `MIOOSDGB*T` that includes:

### Unit Tests

- tokenization of labels, commands, comments, strings, globals, entryrefs, indirection
- command postconditionals
- command separators
- level indicators
- tabs vs spaces
- local labels
- numeric labels
- multiline routine handling

### Golden Syntax Tests

Build a corpus of representative YottaDB source snippets and assert exact parse trees or normalized summaries for:

- single-command lines
- multi-command lines
- nested dotted lines
- comments in legal YottaDB positions
- extrinsics, entryrefs, labelrefs
- standard commands and `Z*` commands
- edge-case whitespace
- empty arguments where legal
- ambiguous-looking but legal constructs

### Canonicalization Tests

- expand known abbreviated forms
- compress full forms
- verify semantic equivalence after rewrite
- ensure comments and labels are preserved correctly
- ensure no accidental rewrites inside strings/comments

### Debugger-Shape Tests

- statement boundary extraction
- breakpoint candidate detection
- command span mapping
- label lookup metadata
- stepping boundary metadata

### Robustness Tests

- malformed source with expected diagnostics
- partial lines
- unterminated strings
- invalid postconditionals
- bad entryrefs
- invalid abbreviations
- stress tests for long lines, many commands, and many labels

### Differential Confidence Tests

Where practical, compare parser assumptions against real YottaDB behavior using tiny compile/execute probes, especially for edge syntax.

## Diagnostics Requirements

Diagnostics must be structured and useful.

For parse errors/warnings, return:

- `ok`
- machine-readable error code
- human-readable message
- routine name
- line number
- column if available
- source excerpt or bounded context
- offending token/span

Do not emit vague parse failures.

## Deliverables

Produce the following:

1. Parser subsystem in `MIOOSDGB*`
2. AST definitions and helpers
3. Expand/compress canonicalizer
4. Debugger-facing query helpers
5. Comprehensive tests
6. Developer documentation describing:
   - AST schema
   - supported syntax surface
   - unsupported/deferred items
   - canonicalization rules
   - performance notes
   - how debugger code should consume the AST

## Execution Approach

Work in small, verifiable ROIs and keep the system green at each step.

Recommended implementation order:

### ROI 1
- lexer/scanner
- line model
- labels/comments/level indicators
- basic test corpus

### ROI 2
- command parsing
- command postconditionals
- command sequences
- standard command table
- abbreviation table

### ROI 3
- expressions
- variable/global refs
- intrinsic functions/special variables
- entryrefs/labelrefs

### ROI 4
- YottaDB-specific syntax support needed for debugger work
- `Z*` command handling relevant to parsing/canonicalization/debug visibility

### ROI 5
- expand/compress engine
- round-trip tests
- semantic equivalence helpers

### ROI 6
- debugger query APIs
- breakpoint/step boundary metadata
- source mapping helpers

### ROI 7
- stress/performance hardening
- diagnostics hardening
- docs

## Definition of Done

This work is not done until:

- tests are comprehensive and passing
- parser output is stable and documented
- expand/compress works on a meaningful YottaDB corpus
- debugger helper APIs are present and exercised
- large-input behavior is MAXSTRING-safe
- performance is measured, not assumed
- any unsupported YottaDB syntax is explicitly listed

## Output Expectations

Return:

- all new/updated routines in full, not delta-only fragments
- a concise architecture summary
- a test inventory
- known limitations
- recommended next ROIs after this foundation

Do not produce placeholder code. Do not fake parser coverage. Do not silently simplify YottaDB syntax.

If a tradeoff is necessary, choose:

1. correctness
2. debuggability
3. performance
4. convenience

A generic parser is not acceptable. This must be a **YottaDB-aware, debugger-ready parsing foundation**.
