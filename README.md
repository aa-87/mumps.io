# MUMPS.IO (MIO) Web Server for YottaDB / GT.M

A fast web server stack written in MUMPS.

It is built for YottaDB r2.02 (GT.M compatible) on Linux.

It is made to be safe, testable, and easy to run in production.

---

## Table of contents

- [Why this project exists](#why-this-project-exists)
- [Key rules and design goals](#key-rules-and-design-goals)
- [Quick start](#quick-start)
- [Configuration](#configuration)
- [Run the server](#run-the-server)
- [Run tests](#run-tests)
- [Features](#features)
- [MIOTPL template engine](#miotpl-template-engine)
  - [Basic variables](#basic-variables)
  - [HTML escaping](#html-escaping)
  - [Sections](#sections)
  - [Inverted sections](#inverted-sections)
  - [Lists and iteration](#lists-and-iteration)
  - [Dotted names](#dotted-names)
  - [Partials](#partials)
  - [Indentation rules](#indentation-rules)
  - [Caching and precompile](#caching-and-precompile)
  - [Common patterns for web pages](#common-patterns-for-web-pages)
- [Security](#security)
- [Operations](#operations)
- [Project layout](#project-layout)
- [Contributing](#contributing)
- [License](#license)

---

## Why this project exists

MUMPS is still used in real systems.

Teams still need web APIs and modern UIs.

This project gives you a real web server stack in pure MUMPS.

It is meant for:
- internal tools
- small and medium APIs
- legacy modernization
- hosted apps on YottaDB / GT.M

---

## Key rules and design goals

These are not “nice to have”.

They are hard rules.

- No `ZSYSTEM` in production code.
- No `GOTO` in production code.
- MAXSTRING-safe streaming only.
- Store large payloads in globals.
- All errors set:
  - `ERR("routine")`
  - `ERR("error")`
  - `ERR("status")` when it matters
- Tests are quiet on success.
- Routing is deterministic.
- One-pass parsing when possible.
- Cache only when safe.

---

## Quick start

### 1) Run the full test suite

From the YDB prompt:

```mumps
ZL "MIOTESTS.m"
D ^MIOTESTS
```

If tests pass, your install is good.

### 2) Add a route

Example route registration:

```mumps
; In your startup code
D ADD^MIOROUTE("GET","/hello/:name","HELLO^MYAPP")
D COMPILE^MIOROUTE()
```

Example handler:

```mumps
MYAPP ;
HELLO(DEV,CONF,REQ,CTX)
  N NAME,BODY
  S NAME=$G(REQ("params","name"))
  ; Build tiny JSON without tricky quotes:
  S BODY="{""hello"":"_$C(34)_NAME_$C(34)_"}"
  D RESPJSON^MIOHTTP(.DEV,200,"OK",BODY,.CTX)
  Q
```

> Use your project response helpers.
> Do not write raw HTTP by hand.

### 3) Render a template (MIOTPL)

```mumps
N CONF,CTX,OUT,ERR
M CONF=^MIO("CONF")
S CTX("name")="World"
D RENDER^MIOTPL("hello",.CONF,.CTX,.OUT,.ERR)
I $D(ERR) W "ERR=",ERR("error"),! Q
W OUT,!
```

---

## Configuration

Config is an M array.

Many deployments keep it in a global:

- `^MIO("CONF",...)`

Common keys you will use:

### Server
- `CONF("server","port")`
- `CONF("server","host")`
- `CONF("server","keepAlive","enabled")`
- `CONF("server","templateDir")`

### Static files
- `CONF("server","static","enabled")=1`
- `CONF("server","static","mount")="/static"`
- `CONF("server","static","root")="tmp"`

Precompressed assets:
- `CONF("server","static","precompressed","enabled")=1`
- `CONF("server","static","precompressed","allowRangeEncoded")=0`

Caching policy (optional):
- `CONF("server","static","cache","enabled")=1`
- `CONF("server","static","cache","maxAgeSeconds")=3600`
- `CONF("server","static","cache","immutable")=1`

### Middleware packs (optional)
Packs make ops simpler.

Example:

```mumps
S ^MIO("CONF","server","packs","enabled","standard")=1
S ^MIO("CONF","server","packs","enabled","debug")=1
```

Then call:

```mumps
N ERR
D APPLY^MIOPACK(.CONF,.ERR)
```

### Auth
Protect only what you want.

Use prefix mode:

```mumps
S ^MIO("CONF","auth","enabled")=1
S ^MIO("CONF","auth","mode")="api_key"  ; or "jwt"
S ^MIO("CONF","auth","protectMode")="prefix"

K ^MIO("CONF","auth","protect","prefix")
S ^MIO("CONF","auth","protect","prefix",1)="/api/"
S ^MIO("CONF","auth","protect","prefix",2)="/admin/"
S ^MIO("CONF","auth","protect","prefix",3)="/metrics"
S ^MIO("CONF","auth","protect","prefix",4)="/debug/"
```

API key:

```mumps
S ^MIO("CONF","auth","apiKey","value")="change-me"
```

JWT (HS256):

```mumps
S ^MIO("CONF","auth","jwt","hmacSecret")="change-me"
S ^MIO("CONF","auth","jwt","rolesClaim")="roles"
```

---

## Run the server

Your repo includes a daemon loop and connection handler.

Common patterns:
- `D START^MIOD` (or your entry routine)
- a systemd unit from the deployment pack

If you use systemd:
- use `/healthz` for liveness
- use `/readyz` for readiness

Graceful shutdown:
- the server supports drain + deadline
- it stops accepting new connections
- it finishes active requests
- it exits cleanly

---

## Run tests

Most users run:

```mumps
ZL "MIOTESTS.m"
D ^MIOTESTS
```

Tests are designed to:
- write temp files
- read them back
- assert outputs
- print nothing on success

---

## Features

### HTTP/1.1 parsing and streaming
- Strict request parsing.
- TE/CL conflict defense (smuggling hardening).
- Chunked transfer decoding.
- Scalar body for small payloads.
- Global-backed body for large payloads.
- Deterministic errors and error codes.

### Multipart streaming
- `multipart/form-data` parser.
- Per-part limits.
- Global-backed storage for large parts.
- Nested multipart support.

### Router
- Deterministic route match and precedence.
- Params like `:id`.
- Wildcards and deep paths.

### Middleware pipeline
- Global before/after middleware.
- Per-route middleware via route META.
- Deterministic order.
- Safe error handling.

Included middleware modules:
- CORS
- Security headers presets
- CSP (optional)
- Auth + RBAC
- Access logging
- Metrics

### Static files
- Safe path join (no traversal).
- ETag + If-None-Match (304).
- Last-Modified + If-Modified-Since (304).
- Range requests (single range) (206 / 416).
- Precompressed assets:
  - serve `.br` or `.gz` when present
  - set `Content-Encoding`
  - set `Vary: Accept-Encoding`
- Directory index support.
- Optional directory listing (default off).
- ETag persistence + cache invalidation helpers.

### Access logs (globals)
- Access log lines stored in globals.
- Fast and deterministic.
- No file system required on the hot path.

### Metrics (globals)
- request counts
- status buckets
- bytes in/out
- parse / handler / total timing
- `/metrics` endpoint (streamed)

### Hardening
- obs-fold reject
- strict header limits
- strict TE rules
- header token validation

### Health and readiness
- `/healthz` always 200
- `/readyz` checks config and required resources

### Rate limiting and DoS controls
- per-IP token bucket (globals)
- active connection cap (globals)
- graceful drain on shutdown

### Error Center and diagnostics
- error ring buffer in globals
- `/debug/errors` (auth protected)
- `/debug/config` redacted (auth protected)

### Performance harness
- perf smoke tests
- scaling ratio gates to catch O(N^2)
- optional absolute guard rails

---

## MIOTPL template engine

MIOTPL is a Mustache-compatible template engine in MUMPS.

It follows the same core rules as moustache.js.

It is designed to be:
- correct
- deterministic
- fast
- easy to test

It has a large spec-style test suite (`MIOTPLT`).

### Template files

Templates usually live in a folder like `templates/`.

Set:

```mumps
S ^MIO("CONF","server","templateDir")="templates"
```

A template name maps to a file path.

Example mapping (common pattern):
- `name="hello"` -> `templates/hello.html`

(Your build may support other mappings too.)

---

## Basic variables

Template:

```mustache
Hello {{name}}!
```

Context:

```mumps
S CTX("name")="World"
```

Output:

```
Hello World!
```

---

## HTML escaping

`{{name}}` escapes HTML by default.

Template:

```mustache
<p>{{name}}</p>
```

Context:

```mumps
S CTX("name")="<b>Alice</b>"
```

Output:

```html
<p>&lt;b&gt;Alice&lt;/b&gt;</p>
```

To render raw HTML, use triple braces:

```mustache
<p>{{{name}}}</p>
```

Output:

```html
<p><b>Alice</b></p>
```

---

## Sections

A section runs when the value is “truthy”.

Template:

```mustache
{{#user}}
Hello {{name}}!
{{/user}}
```

Context:

```mumps
S CTX("user","name")="Sam"
```

Output:

```
Hello Sam!
```

If `user` is missing or false, nothing is shown.

---

## Inverted sections

An inverted section runs when the value is missing or false.

Template:

```mustache
{{^items}}
No items.
{{/items}}
```

Context:

```mumps
; CTX("items") is not set
```

Output:

```
No items.
```

---

## Lists and iteration

If a section value is a list, the block repeats.

Template:

```mustache
<ul>
{{#items}}
  <li>{{name}}</li>
{{/items}}
</ul>
```

Context:

```mumps
S CTX("items",1,"name")="A"
S CTX("items",2,"name")="B"
```

Output:

```html
<ul>
  <li>A</li>
  <li>B</li>
</ul>
```

You can also use `{{.}}` for “current item”.

Template:

```mustache
{{#items}}- {{.}}
{{/items}}
```

Context:

```mumps
S CTX("items",1)="one"
S CTX("items",2)="two"
```

Output:

```
- one
- two
```

---

## Dotted names

Dotted names access nested values.

Template:

```mustache
User: {{user.name}}
```

Context:

```mumps
S CTX("user","name")="Rita"
```

Output:

```
User: Rita
```

---

## Partials

Partials let you reuse templates.

Main template:

```mustache
<h1>{{title}}</h1>
{{> card}}
```

Partial template `card`:

```mustache
<div class="card">
  {{text}}
</div>
```

Context:

```mumps
S CTX("title")="Home"
S CTX("text")="Welcome"
```

Output:

```html
<h1>Home</h1>
<div class="card">
  Welcome
</div>
```

---

## Indentation rules

If a partial tag is indented, its lines are indented too.

Template:

```mustache
<ul>
  {{> item}}
</ul>
```

Partial `item`:

```mustache
<li>{{name}}</li>
```

Output:

```html
<ul>
  <li>X</li>
</ul>
```

---

## Caching and precompile

MIOTPL supports caching compiled templates.

This makes repeated renders fast.

Common pattern:

```mumps
D PRECOMPILE^MIOTPL(.CONF)
```

Then render many times:

```mumps
D RENDER^MIOTPL("hello",.CONF,.CTX,.OUT,.ERR)
```

Cache is stored under a project global.

It avoids recompiling on every request.

---

## Common patterns for web pages

### Render HTML in a handler

```mumps
PAGE(DEV,CONF,REQ,CTX)
  N TCTX,OUT,ERR
  M TCTX=CTX
  S TCTX("title")="Home"
  D RENDER^MIOTPL("home",.CONF,.TCTX,.OUT,.ERR)
  I $D(ERR) D RESPJSON^MIOHTTP(.DEV,500,"ERR","{""error"":""template""}",.CTX) Q
  D RESP^MIOHTTP(.DEV,200,"OK","text/html; charset=utf-8",OUT,.CTX)
  Q
```

---

## Security

### Security headers
Use a preset:
- `balanced` (default)
- `strict`
- `dev`

Example:

```mumps
S ^MIO("CONF","server","security","preset")="strict"
```

### CSP
Start in report-only mode:

```mumps
S ^MIO("CONF","server","security","csp","enabled")=1
S ^MIO("CONF","server","security","csp","reportOnly")=1
```

Nonce mode (best for modern apps):

```mumps
S ^MIO("CONF","server","security","csp","nonce","enabled")=1
```

In templates:

```html
<script nonce="{{csp_nonce}}">/* inline script */</script>
```

---

## Operations

- Access logs live in globals.
- Metrics live in globals.
- Debug endpoints are protected by auth prefix rules.
- Graceful shutdown is supported.

---

## Project layout

- `backend/routines/` contains `*.m` routines.
- Tests are routines too.
- `MIOTESTS` runs the full suite.

---

## Contributing

See:
- `CONTRIBUTING.md`
- `SECURITY.md`

---

## License

Pick a license before you open source.
Common choices:
- Apache-2.0
- MIT
- MPL-2.0
