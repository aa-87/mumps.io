# MIOTPL Application Spec for LLMs

This document is a **build contract** for generating applications that use **MIOTPL** (Mustache-first M template engine for YottaDB/GT.M). It’s meant to be pasted into an LLM prompt so the LLM generates correct, consistent, production-safe code.

## 1) Target environment

- Runtime: **YottaDB or GT.M** (M language)
- Templates: **MIOTPL** routine provides compile + render + cache
- Web server: assumed existing (typical pattern: `MIOROUTE` for routing, `MIOHTTP` for responses)
- JSON parser: assumed existing (use a project-provided routine; don’t hand-roll)

## 2) Filesystem conventions

Recommended project layout:

```
routines/
  MIOTPL.m
  <APP>.m
  <APPTEST>.m
templates/
  layouts/
  pages/
  partials/
docs/
```

Template resolution:

- `CONF("templates","root")` defaults to `templates/`
- If a template name has no extension, `CONF("templates","ext")` is appended

## 3) MIOTPL public API (use exactly)

### Start-up

- `D START^MIOTPL(.CONF)`
  - sets defaults and optional precompile

### Compile / token cache

- `D GETTOKREF^MIOTPL(NAME,.CONF,.TOKREF,.PMAX,.ERR)`
- `D GETTOKFP^MIOTPL(FP,.CONF,.TOK,.ERR[,OPT])`

### Render

- Scalar output:
  - `D RENDER^MIOTPL(NAME,.CONF,.CTX,.OUT,.ERR)`
  - `D RENDERPAGE^MIOTPL(PAGE,LAYOUT,.CONF,.CTX,.OUT,.ERR)`

- Large output / streaming output:
  - `D RENDERREFNAME^MIOTPL(NAME,.CONF,.CTX,OREF,.ERR)`
  - `D RENDERX^MIOTPL(NAME,.CONF,.CTX,.OUT,.ERR,.OPT)` (mode `AUTO` supported)

## 4) Context rules (how to build CTX)

- `CTX("key")="value"` for scalars.
- Objects:
  - `CTX("user","name")="Ahmed"`
- Lists:
  - `CTX("items",1,"name")="A"`
  - `CTX("items",2,"name")="B"`

Dot-lookup works: `{{user.name}}`.

## 5) Template features used in apps

### Variables
- `{{name}}` (HTML-escaped)
- `{{{name}}}` or `{{& name}}` (unescaped)

### Sections
- `{{#items}}...{{/items}}`
- `{{^items}}...{{/items}}`

### Partials
- `{{> header}}`
- dynamic partial (single deref): `{{> *partialKey}}`

### Parents + blocks (inheritance)
- Parent: `{{< layout}} ... {{/layout}}`
- Define blocks: `{{$title}}...{{/title}}`
- Expand blocks in layout via `{{{blocks.title}}}` and `{{{content}}}`

> Apps should prefer `RENDERPAGE(page, layout)` when possible.

### Lambdas (advanced)
MIOTPL supports callables via scalar values starting with `$$`.

- Variable lambda: `CTX("now")="$$NOW^APP"` and template uses `{{now}}`.
- Section lambda: `CTX("fmt")="$$FMT^APP"` and template uses `{{#fmt}}...{{/fmt}}`.

**Security rule:** never accept lambda values from untrusted input.

## 6) Security requirements for generated apps

### Path traversal
Template names must not be user-controlled without validation.
MIOTPL already blocks `..`, absolute paths, and `:` device paths.

### Recursion limits
Set a conservative recursion limit:

- `CONF("templates","maxPartialDepth")=20` (or lower for untrusted templates)

### Lambda safety
If the app accepts user templates, lambdas must be disabled by policy:

- Do not set any `CTX(key)` value that begins with `$$` from user data.
- Optionally, strip/replace such values during request processing.

### Output size
If output may be large, use `RENDERX` mode `AUTO` with a strict max:

- `CONF("output","auto")=1`
- `CONF("output","maxString")=900000` (adjust per system)
- `CONF("output","autoReturnRef")=1` (optional)

## 7) Testing contract

Generated apps must include:

- a small self-test routine `<APPTEST>.m`
- at least one end-to-end render test that calls `RENDERPAGE^MIOTPL`
- a “smoke run” entry point for humans

## 8) What to output (LLM instruction)

When generating an app, output:

1. `routines/<APP>.m` with:
   - `REG` label (route registration)
   - route handlers (GET/POST)
   - a shared render helper
2. `templates/layouts/<layout>.html`
3. `templates/pages/<page>.html`
4. `templates/partials/*.html` (component partials)
5. `docs/README.md` with setup + run steps
6. `routines/<APPTEST>.m` with a smoke test

Keep everything deterministic and production-safe.
