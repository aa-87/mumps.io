# MUMPS.IO (MIO) Web Server for YottaDB / GT.M

A fast web server stack written in MUMPS.

It targets YottaDB r2.02 (GT.M compatible).

It runs on Linux.

It is built for internal tools.

It is built for APIs.

It is built for real production use.

---

## Table of contents

- Why this project exists
- Design rules
- Quick start
- Project layout
- Run tests
- Run the server
- Configuration reference
- HTTP server features
- Router features
- Middleware features
- Static file features
- Multipart upload features
- WebSocket features
- Observability features
- Auth and RBAC features
- Health and readiness
- Rate limiting
- Development tools
- MIOTPL template engine (moustache.js style)
- Bench and perf tools
- FAQ
- Contributing
- License

---

## Why this project exists

MUMPS is still used in real systems.

Teams still need web APIs and modern UIs.

This project gives you a full stack in pure MUMPS.

It is meant for:
- internal tools
- small and medium APIs
- legacy modernization
- fast prototypes that can grow

---

## Design rules

These are hard rules.

They are enforced by tests.

- No `ZSYSTEM` in production code.
- No `GOTO` in production code.
- MAXSTRING-safe streaming only.
- Use globals for large payloads.
- All errors must set:
  - `ERR("routine")`
  - `ERR("error")`
  - `ERR("status")` when it matters
- Tests are quiet on success.
- Routing must be deterministic.
- Prefer one-pass parsing.
- Cache only when safe.

---

## Quick start

### Step 1. Load the core test suite

From the YDB prompt:

```mumps
ZL "MIOTESTS.m"
D ^MIOTESTS
```

If tests pass, your install is good.

### Step 2. Start with a tiny route

Register a route:

```mumps
D ADD^MIOROUTE("GET","/hello/:name","HELLO^MYAPP")
D COMPILE^MIOROUTE()
```

Handler example:

```mumps
MYAPP ;
HELLO(DEV,CONF,REQ,CTX)
  N NAME,BODY
  S NAME=$G(REQ("params","name"))
  S BODY="{""hello"":"_$C(34)_NAME_$C(34)_"}"
  D RESPJSON^MIOHTTP(.DEV,200,"OK",BODY,.CTX)
  Q
```

Try it with curl:

```bash
curl http://127.0.0.1:9080/hello/Ahmed
```

---

## Project layout

This repo uses a simple layout.

- `backend/routines/` holds `*.m` routines.
- Tests are also routines.

Common naming:
- `MIOHTTP` is HTTP parsing.
- `MIOROUTE` is routing.
- `MIOTPL` is templating.
- `MIOSTATIC` is static files.
- `MIOD` is the daemon loop.

Test harness routines:
- `MIOTESTS` runs the full suite.
- `MIOTPLT` tests the template engine.
- `MIOROUTET` tests the router.
- `MIOHTTPT` tests HTTP parsing.
- `MIOHTTPMPUTT` tests multipart parsing.
- `MIOSTATICT` tests static files.

---

## Run tests

Run all tests:

```mumps
ZL "MIOTESTS.m"
D ^MIOTESTS
```

Tests are quiet on success.

Tests write to temp files.

Tests read them back.

Tests compare the output.

---

## Run the server

The daemon routine is `MIOD`.

A simple start pattern looks like this:

```mumps
N CONF
M CONF=^MIO("CONF")
D START^MIOD(.CONF)
```

Your project may also use `MIO` or `MIOMIO` as the top entry.

Check `MIO.m` and `MIOMIO.m`.

---

## Configuration reference
Config is an M array.
Many installs store it in a global.
Most people use `^MIO("CONF",...)`.

This section lists keys used by the code in this repo.
Defaults are shown when the code sets them.
Some defaults are enforced by clamping in code.

### server.listen

- `CONF("server","listen","port")`.
  Default is `9080`.
  It is used by this module.
  Used in: MIOD.m.

### server.keepAlive

- `CONF("server","keepAlive","enabled")`.
  Default is `1`.
  It turns a feature on or off.
  Used in: MIOD.m.
- `CONF("server","keepAlive","idleSeconds")`.
  Default is `10`.
  It sets a timeout value.
  Used in: MIOD.m.
- `CONF("server","keepAlive","maxRequests")`.
  Default is `100`.
  It sets a maximum limit.
  Used in: MIOD.m.

### server.timeouts

- `CONF("server","timeouts","readBodyMs")`.
  Default is `3`.
  It sets a timeout value.
  Used in: MIOD.m, MIOHTTP.m, MIOHTTPDOC.m.
- `CONF("server","timeouts","readHeaderMs")`.
  Default is `2`.
  It sets a timeout value.
  Used in: MIOD.m, MIOHTTP.m, MIOHTTPDOC.m.

### server.limits

- `CONF("server","limits","maxBodyBytes")`.
  Default is `10485760`.
  It sets a maximum limit.
  Used in: MIOHTTP.m, MIOHTTP1CTT.m, MIOHTTPDOC.m, MIOHTTPT.m.
- `CONF("server","limits","maxBodyScalarBytes")`.
  Default is `262144`.
  It sets a maximum limit.
  Used in: MIOHTTP.m, MIOHTTPDOC.m, MIOHTTPT.m, MIOHTTPTX.m.
- `CONF("server","limits","maxHeaderBytes")`.
  It sets a maximum limit.
  Used in: MIOHTTP.m, MIOHTTPDOC.m, MIOHTTPHDT.m, MIOHTTPT.m.
- `CONF("server","limits","maxHeaderCount")`.
  It sets a maximum limit.
  Used in: MIOHTTP.m, MIOHTTPDOC.m, MIOHTTPHDT.m, MIOHTTPT.m.
- `CONF("server","limits","maxHeaderLineBytes")`.
  It sets a maximum limit.
  Used in: MIOHTTPDOC.m, MIOHTTPHDT.m.
- `CONF("server","limits","maxHeaderLineLength")`.
  It sets a maximum limit.
  Used in: MIOHTTP.m.
- `CONF("server","limits","maxMultipartHeaderBytes")`.
  Default is `32768`.
  It sets a maximum limit.
  Used in: MIOHTTPMPU.m.
- `CONF("server","limits","maxMultipartHeaders")`.
  Default is `80`.
  It sets a maximum limit.
  Used in: MIOHTTPMPU.m.
- `CONF("server","limits","maxMultipartPartBytes")`.
  Default is `0`.
  It sets a maximum limit.
  Used in: MIOHTTPMPU.m, MIOHTTPMPUTT.m.
- `CONF("server","limits","maxMultipartPartScalarBytes")`.
  Default is `65536 | MAXSC`.
  It sets a maximum limit.
  Used in: MIOHTTPMPU.m, MIOHTTPMPUTT.m.
- `CONF("server","limits","maxMultipartParts")`.
  Default is `200`.
  It sets a maximum limit.
  Used in: MIOHTTPMPU.m, MIOHTTPMPUTT.m.
- `CONF("server","limits","maxRequestLineBytes")`.
  It sets a maximum limit.
  Used in: MIOHTTP.m, MIOHTTPDOC.m, MIOHTTPHDT.m, MIOHTTPT.m.
- `CONF("server","limits","maxRequestLineLength")`.
  It sets a maximum limit.
  Used in: MIOHTTP.m.

### server.http

- `CONF("server","http","allowTECL")`.
  Default is `0`.
  It is used by this module.
  Used in: MIOHTTP.m.
- `CONF("server","http","defaultResponseHeaders")`.
  It sets default response headers.
  Used in: MIOHTTP.m, MIOSTATIC.m.
- `CONF("server","http","defaultResponseHeaders","Connection")`.
  It is used by this module.
  Used in: MIOD.m.
- `CONF("server","http","limits","maxHeaderLineLength")`.
  It sets a maximum limit.
  Used in: MIOHTTP.m.
- `CONF("server","http","limits","maxRequestLineLength")`.
  It sets a maximum limit.
  Used in: MIOHTTP.m.
- `CONF("server","http","readBodyChunkBytes")`.
  It is used by this module.
  Used in: MIOHTTP.m, MIOHTTPDOC.m, MIOHTTPT.m, MIOHTTPTX.m.
- `CONF("server","http","strictTE")`.
  Default is `1`.
  It is used by this module.
  Used in: MIOHTTP.m.
- `CONF("server","http","supportChunkedRequest")`.
  Default is `1`.
  It is used by this module.
  Used in: MIOHTTP.m, MIOHTTPT.m, MIOHTTPTX.m.

### server.multipart

- `CONF("server","multipart","allow")`.
  It controls API key auth.
  Used in: MIOHTTPMPU.m.
- `CONF("server","multipart","allow","text/plain")`.
  It is used by this module.
  Used in: MIOHTTPDOC.m.
- `CONF("server","multipart","allowTypes")`.
  It is used by this module.
  Used in: MIOHTTPDOC.m, MIOHTTPMPU.m, MIOHTTPMPUTT.m.
- `CONF("server","multipart","enableNested")`.
  Default is `0`.
  It is used by this module.
  Used in: MIOHTTPDOC.m, MIOHTTPMPU.m, MIOHTTPMPUTT.m.
- `CONF("server","multipart","maxDepth")`.
  Default is `3`.
  It sets a maximum limit.
  Used in: MIOHTTPDOC.m, MIOHTTPMPU.m.
- `CONF("server","multipart","maxFieldScalarBytes")`.
  Default is `8192`.
  It sets a maximum limit.
  Used in: MIOHTTPMPU.m.
- `CONF("server","multipart","maxMultipartSpoolBytes")`.
  Default is `0`.
  It sets a maximum limit.
  Used in: MIOHTTPDOC.m, MIOHTTPMPU.m, MIOHTTPMPUTT.m.
- `CONF("server","multipart","spoolDir")`.
  Default is `"/tmp"`.
  It sets a path value.
  Used in: MIOHEALTH.m, MIOHTTPDOC.m, MIOHTTPMPU.m, MIOHTTPMPUTT.m.
- `CONF("server","multipart","spoolReadChunkBytes")`.
  Default is `16384`.
  It is used by this module.
  Used in: MIOHTTPMPU.m.
- `CONF("server","multipart","zeroCopyFileParts")`.
  Default is `0`.
  It is used by this module.
  Used in: MIOHTTPDOC.m, MIOHTTPMPU.m, MIOHTTPMPUTT.m.
- `CONF("server","multipart","zrefReadChunkBytes")`.
  Default is `16384`.
  It is used by this module.
  Used in: MIOHTTPMPU.m.

### server.static

- `CONF("server","static","dirListing","enabled")`.
  Default is `0`.
  It turns a feature on or off.
  Used in: MIOSTATIC.m, MIOSTATICIDXT.m, MIOSTATICT.m.
- `CONF("server","static","dirListing","maxEntries")`.
  Default is `1024`.
  It sets a maximum limit.
  Used in: MIOSTATIC.m, MIOSTATICT.m.
- `CONF("server","static","dirListing","showDotfiles")`.
  Default is `0`.
  It is used by this module.
  Used in: MIOSTATIC.m.
- `CONF("server","static","enabled")`.
  It turns a feature on or off.
  Used in: MIOETAGT.m, MIOHEALTH.m, MIOHEALTHT.m, MIOHTTPDOC.m.
- `CONF("server","static","etagCacheSeconds")`.
  Default is `30`.
  It sets a timeout value.
  Used in: MIOETAGT.m, MIOHTTPDOC.m, MIOSTATIC.m, MIOSTATICT.m.
- `CONF("server","static","etagChunkBytes")`.
  Default is `65536`.
  It is used by this module.
  Used in: MIOHTTPDOC.m, MIOSTATIC.m.
- `CONF("server","static","index")`.
  Default is `"index.html"`.
  It sets a path value.
  Used in: MIOSTATIC.m, MIOSTATICIDXT.m, MIOSTATICT.m.
- `CONF("server","static","maxEtagBytes")`.
  Default is `2097152`.
  It sets a maximum limit.
  Used in: MIOETAGT.m, MIOHTTPDOC.m, MIOSTATIC.m, MIOSTATICT.m.
- `CONF("server","static","mount")`.
  Default is `"/static"`.
  It sets a path value.
  Used in: MIOETAGT.m, MIOHTTPDOC.m, MIOSTATIC.m, MIOSTATICIDXT.m.
- `CONF("server","static","mtimeProvider")`.
  It is used by this module.
  Used in: MIOHTTPDOC.m, MIOSTATIC.m.
- `CONF("server","static","precompressed","allowRangeEncoded")`.
  It is used by this module.
  Used in: MIOSTATIC.m, MIOSTATICZTT.m.
- `CONF("server","static","precompressed","enabled")`.
  Default is `0`.
  It turns a feature on or off.
  Used in: MIOSTATIC.m, MIOSTATICZTT.m.
- `CONF("server","static","readChunkBytes")`.
  Default is `65536`.
  It is used by this module.
  Used in: MIOHTTP.m, MIOHTTPDOC.m, MIOSTATIC.m.
- `CONF("server","static","root")`.
  Default is `"public"`.
  It sets a path value.
  Used in: MIOETAGT.m, MIOHEALTH.m, MIOHEALTHT.m, MIOHTTPDOC.m.

### server.cors

- `CONF("server","cors","allowCredentials")`.
  Default is `0`.
  It controls CORS.
  Used in: MIOMW.m.
- `CONF("server","cors","allowHeaders")`.
  Default is `"Content-Type,Authorization,X-Api-Key"`.
  It controls CORS.
  Used in: MIOMW.m.
- `CONF("server","cors","allowMethods")`.
  Default is `"GET,POST,PUT,PATCH,DELETE,OPTIONS"`.
  It controls CORS.
  Used in: MIOMW.m.
- `CONF("server","cors","allowOrigin")`.
  Default is `"*"`.
  It controls CORS.
  Used in: MIOMW.m.
- `CONF("server","cors","enabled")`.
  Default is `0`.
  It turns a feature on or off.
  Used in: MIOMW.m, MIOMWSTDT.m.
- `CONF("server","cors","exposeHeaders")`.
  Default is `"X-Request-Id"`.
  It controls CORS.
  Used in: MIOMW.m.
- `CONF("server","cors","maxAge")`.
  Default is `600`.
  It sets a maximum limit.
  Used in: MIOMW.m.
- `CONF("server","cors","vary")`.
  Default is `1`.
  It controls CORS.
  Used in: MIOMW.m.

### server.middleware

- `CONF("server","middleware")`.
  It is used by this module.
  Used in: MIOMW.m.
- `CONF("server","middleware","after")`.
  It is used by this module.
  Used in: MIOMW.m, MIOROUTE.m.
- `CONF("server","middleware","before")`.
  It is used by this module.
  Used in: MIOMW.m, MIOROUTE.m.

### server.log

- `CONF("server","log","access","enabled")`.
  Default is `0`.
  It turns a feature on or off.
  Used in: MIOD.m, MIOHEALTH.m, MIOHTTPDOC.m, MIOLOG.m.
- `CONF("server","log","access","flushBytes")`.
  Default is `65536`.
  It is used by this module.
  Used in: MIOLOG.m.
- `CONF("server","log","access","flushEvery")`.
  Default is `50`.
  It is used by this module.
  Used in: MIOLOG.m.
- `CONF("server","log","access","format")`.
  Default is `"common"`.
  It selects a mode.
  Used in: MIOLOG.m, MIOLOGT.m, MIOMWSTDT.m.
- `CONF("server","log","access","maxEntries")`.
  Default is `20000`.
  It sets a maximum limit.
  Used in: MIOHEALTH.m, MIOLOG.m, MIOLOGT.m, MIOMWSTDT.m.

### server.metrics

- `CONF("server","metrics","enabled")`.
  It turns a feature on or off.
  Used in: MIOMET.m, MIOMETT.m.

### server.rate

- `CONF("server","rate","burst")`.
  Default is `20`.
  It tunes rate limiting.
  Used in: MIORATE.m, MIORATET.m.
- `CONF("server","rate","enabled")`.
  Default is `0`.
  It turns a feature on or off.
  Used in: MIOD.m, MIOHTTPDOC.m, MIORATE.m, MIORATET.m.
- `CONF("server","rate","exempt","9.9.9.9")`.
  It is used by this module.
  Used in: MIORATET.m.
- `CONF("server","rate","perIp","burst")`.
  It tunes rate limiting.
  Used in: MIOHTTPDOC.m.
- `CONF("server","rate","perIp","rps")`.
  It tunes rate limiting.
  Used in: MIOHTTPDOC.m.
- `CONF("server","rate","perIp","ttlSeconds")`.
  It sets a timeout value.
  Used in: MIOHTTPDOC.m.
- `CONF("server","rate","rps")`.
  Default is `10`.
  It tunes rate limiting.
  Used in: MIORATE.m, MIORATET.m.
- `CONF("server","rate","trustProxy")`.
  Default is `0`.
  It is used by this module.
  Used in: MIORATE.m, MIORATET.m.

### server.health

- `CONF("server","health","readyCheckRouterCompiled")`.
  Default is `0`.
  It is used by this module.
  Used in: MIOHEALTH.m, MIOHEALTHT.m.
- `CONF("server","health","readyCheckSpoolDir")`.
  Default is `0`.
  It is used by this module.
  Used in: MIOHEALTH.m, MIOHEALTHT.m.
- `CONF("server","health","readyCheckTemplates")`.
  Default is `0`.
  It is used by this module.
  Used in: MIOHEALTH.m, MIOHEALTHT.m, MIOHTTPDOC.m.

### auth.apiKey

- `CONF("auth","apiKey","allow")`.
  It controls API key auth.
  Used in: MIOAUTH.m.
- `CONF("auth","apiKey","header")`.
  Default is `"X-Api-Key"`.
  It controls API key auth.
  Used in: MIOAUTH.m.
- `CONF("auth","apiKey","value")`.
  It controls API key auth.
  Used in: MIOAUTH.m, MIOMWSTDT.m.

### auth.jwt

- `CONF("auth","jwt","audience")`.
  It controls JWT auth.
  Used in: MIOAUTHJWT.m.
- `CONF("auth","jwt","bearerPrefix")`.
  Default is `"Bearer "`.
  It controls JWT auth.
  Used in: MIOAUTHJWT.m.
- `CONF("auth","jwt","clockSkewSeconds")`.
  Default is `60`.
  It sets a timeout value.
  Used in: MIOAUTHJWT.m.
- `CONF("auth","jwt","hmacSecret")`.
  It controls JWT auth.
  Used in: MIOAUTHJWT.m.
- `CONF("auth","jwt","issuer")`.
  It controls JWT auth.
  Used in: MIOAUTHJWT.m.
- `CONF("auth","jwt","jwksUrl")`.
  It controls JWT auth.
  Used in: MIOAUTHJWT.m.
- `CONF("auth","jwt","rolesClaim")`.
  Default is `"roles"`.
  It controls JWT auth.
  Used in: MIOAUTHJWT.m.

### auth.enabled

- `CONF("auth","enabled")`.
  It turns a feature on or off.
  Used in: MIOPUBAPI.m.

### auth.exempt

- `CONF("auth","exempt","prefix")`.
  It is used by this module.
  Used in: MIOAUTH.m.

### auth.mode

- `CONF("auth","mode")`.
  Default is `"api_key"`.
  It selects a mode.
  Used in: MIOAUTH.m, MIOMWSTDT.m, MIOPUBAPI.m.

### auth.protect

- `CONF("auth","protect","prefix")`.
  It is used by this module.
  Used in: MIOAUTH.m.

### auth.protectMode

- `CONF("auth","protectMode")`.
  Default is `"prefix"`.
  It is used by this module.
  Used in: MIOAUTH.m.

### bench.iters

- `CONF("bench","iters","compile")`.
  It is used by this module.
  Used in: MIOTPLB.m.
- `CONF("bench","iters","render")`.
  It is used by this module.
  Used in: MIOTPLB.m.

### bench.warmup

- `CONF("bench","warmup")`.
  It is used by this module.
  Used in: MIOTPLB.m.

### compat.truthiness

- `CONF("compat","truthiness")`.
  It is used by this module.
  Used in: MIOTPL.m, MIOTPLT.m.

### examples.enabled

- `CONF("examples","enabled")`.
  It turns a feature on or off.
  Used in: MIODEMO.m.

### metrics.cleanupIntervalSeconds

- `CONF("metrics","cleanupIntervalSeconds")`.
  Default is `60`.
  It sets a timeout value.
  Used in: MIOCLEAN.m.

### metrics.enabled

- `CONF("metrics","enabled")`.
  Default is `0`.
  It turns a feature on or off.
  Used in: MIOCLEAN.m, MIOMET.m.

### metrics.retentionMinutes

- `CONF("metrics","retentionMinutes")`.
  Default is `180`.
  It is used by this module.
  Used in: MIOCLEAN.m.

### metrics.staleBufferMinutes

- `CONF("metrics","staleBufferMinutes")`.
  Default is `10`.
  It is used by this module.
  Used in: MIOCLEAN.m.

### output.auto

- `CONF("output","auto")`.
  It is used by this module.
  Used in: MIOPLGD.m, MIOTPL.m.

### output.autoReturnRef

- `CONF("output","autoReturnRef")`.
  It is used by this module.
  Used in: MIOPLGD.m, MIOTPL.m.

### output.chunk

- `CONF("output","chunk")`.
  It is used by this module.
  Used in: MIOTPL.m, MIOTPLB.m.

### output.maxString

- `CONF("output","maxString")`.
  It sets a maximum limit.
  Used in: MIOPLGD.m, MIOTPL.m.

### packages.catalogPath

- `CONF("packages","catalogPath")`.
  It is used by this module.
  Used in: MIOPKG.m.

### referenceApp.enabled

- `CONF("referenceApp","enabled")`.
  It turns a feature on or off.
  Used in: MIOAPP.m.

### registry.publish

- `CONF("registry","publish","allowUnsigned")`.
  Default is `0`.
  It is used by this module.
  Used in: MIOREGADM.m.

### server.templateDir

- `CONF("server","templateDir")`.
  Default is `"templates"`.
  It is used by this module.
  Used in: MIOHEALTH.m, MIOHTTPDOC.m, MIOTPL.m, MIOTPLW.m.

### templates.captureBlocks

- `CONF("templates","captureBlocks")`.
  It is used by this module.
  Used in: MIOTPL.m.

### templates.devWatchEnabled

- `CONF("templates","devWatchEnabled")`.
  It is used by this module.
  Used in: MIOTPLW.m.

### templates.devWatchIntervalSeconds

- `CONF("templates","devWatchIntervalSeconds")`.
  It sets a timeout value.
  Used in: MIOTPLW.m.

### templates.ext

- `CONF("templates","ext")`.
  It is used by this module.
  Used in: MIOPLGD.m, MIOTPL.m, MIOTPLT.m.

### templates.fileChunk

- `CONF("templates","fileChunk")`.
  It is used by this module.
  Used in: MIOTPL.m.

### templates.maxPartialDepth

- `CONF("templates","maxPartialDepth")`.
  It sets a maximum limit.
  Used in: MIOPLGD.m, MIOTPL.m.

### templates.partialsRef

- `CONF("templates","partialsRef")`.
  It is used by this module.
  Used in: MIOTPL.m.

### templates.precompileEnabled

- `CONF("templates","precompileEnabled")`.
  It is used by this module.
  Used in: MIOPLGD.m, MIOTPL.m, MIOTPLB.m.

### templates.root

- `CONF("templates","root")`.
  It sets a path value.
  Used in: MIOPLGD.m, MIOTPL.m, MIOTPLT.m.

### templates.streamFallback

- `CONF("templates","streamFallback")`.
  It is used by this module.
  Used in: MIOPLGD.m, MIOTPL.m.

### templates.streamFiles

- `CONF("templates","streamFiles")`.
  It is used by this module.
  Used in: MIOPLGD.m, MIOTPL.m.

### websocket.idleTimeoutSeconds

- `CONF("websocket","idleTimeoutSeconds")`.
  Default is `3600`.
  It sets a timeout value.
  Used in: MIOWS.m.

### websocket.maxFrameBytes

- `CONF("websocket","maxFrameBytes")`.
  Default is `65536`.
  It sets a maximum limit.
  Used in: MIOWS.m.

### websocket.maxMessageBytes

- `CONF("websocket","maxMessageBytes")`.
  Default is `262144`.
  It sets a maximum limit.
  Used in: MIOWS.m.



---

## HTTP server features

HTTP parsing lives in `MIOHTTP`.

It is strict.

It is safe.

It is streaming.

### Request parsing

It parses:
- request line
- query string
- headers
- body

It builds a request array:

- `REQ("method")`
- `REQ("path")`
- `REQ("qry",...)`
- `REQ("hdr",...)`
- `REQ("id")`

It also sets body storage info.

### MAXSTRING-safe body storage

Small bodies use a scalar:

- `REQ("body")`
- `REQ("body","mode")="scalar"`

Large bodies use a global:

- `REQ("body","mode")="global"`
- `REQ("body","ref")` points to `^TMP($J,"MIOHTTP","BODY",REQ("id"),...)`
- `REQ("body","n")` is the chunk count

This avoids MAXSTRING errors.

### Read the body in a handler

Example that works for both modes:

```mumps
READBODY(REQ,OUT)
  K OUT
  N CUR,CH
  D BODYOPEN^MIOHTTP(.REQ,.CUR)
  N I S I=0
  F  Q:'$$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH)  D
  . S I=I+1
  . S OUT(I)=CH
  Q
```

### Chunked request bodies

Chunked request bodies are supported.

TE and CL rules are enforced.

TE/CL conflicts are rejected.

Bad chunk sizes are rejected.

Short reads are rejected.

### Hardening

Hardening is enforced in parsing.

Examples:
- obs-fold is rejected
- header count is limited
- header bytes are limited
- request line length is limited
- header name tokens are validated
- control chars in values are rejected
- strict TE rules are enforced

---

## Router features

Routing lives in `MIOROUTE`.

It is a segment trie.

It is deterministic.

It supports:
- static paths
- params
- wildcards

Examples:

```mumps
D ADD^MIOROUTE("GET","/users/me","ME^APP")
D ADD^MIOROUTE("GET","/users/:id","USER^APP")
D ADD^MIOROUTE("GET","/static/*path","STATIC^MIOSTATIC")
D COMPILE^MIOROUTE()
```

Params show up here:

- `REQ("params","id")`
- `REQ("params","path")`

### Route meta

Use `ADDM^MIOROUTE` to attach meta.

Meta is stored under `^MIO("ROUTE","META",...)`.

Example:

```mumps
N META
S META("mw_before")="AUTHB^MIOMW"
S META("mw_after")="LOGA^MIOMW"
S META("authRequired")=1
S META("roles")="admin"
D ADDM^MIOROUTE("GET","/admin","ADMIN^APP",.META)
```

Meta is available to middleware and auth code.

---

## Middleware features

Middleware is supported at two levels.

Level 1 is global middleware lists.

Level 2 is per-route middleware meta.

Global middleware lists:

- `CONF("server","middleware","before",n)="LABEL^ROUTINE"`
- `CONF("server","middleware","after",n)="LABEL^ROUTINE"`

Per-route lists via meta:

- `META("mw_before")="A^R,B^R"`
- `META("mw_after")="X^R"`

### Middleware call style

Before middleware is an extrinsic.

It returns 1 to continue.

It returns 0 to stop.

Signature:

```mumps
OK=$$MW^RTN(.DEV,.CONF,.REQ,.CTX,.ERR)
```

After middleware is a DO.

Signature:

```mumps
D MW^RTN(.DEV,.CONF,.REQ,.CTX,.ERR)
```

### Built-in middleware in this repo

`MIOMW` provides:
- CORS
- Auth (API key or JWT)
- Access logging hooks

Use `STDWIRE^MIOMW(.CONF)` to set a good default chain.

---

## Static file features

Static files are handled by `MIOSTATIC`.

You mount a static tree.

You serve files under it.

You stay safe from path traversal.

### Basic config

```mumps
S ^MIO("CONF","server","static","enabled")=1
S ^MIO("CONF","server","static","mount")="/static"
S ^MIO("CONF","server","static","root")="public"
```

### Directory index

If a user requests a directory, the server can serve an index.

Default index is `index.html`.

You can change it:

```mumps
S ^MIO("CONF","server","static","index")="home.html"
```

### Optional directory listing

Directory listing is off by default.

Turn it on:

```mumps
S ^MIO("CONF","server","static","dirListing","enabled")=1
S ^MIO("CONF","server","static","dirListing","maxEntries")=1000
S ^MIO("CONF","server","static","dirListing","showDotfiles")=0
```

### ETag and 304

ETag is computed for static files.

If the client sends `If-None-Match`, you may get 304.

Example request:

```bash
curl -I http://127.0.0.1:9080/static/app.js
```

Example second request:

```bash
curl -I http://127.0.0.1:9080/static/app.js -H 'If-None-Match: W/"123-456"'
```

### Last-Modified and 304

`Last-Modified` is supported.

If the client sends `If-Modified-Since`, you may get 304.

### Range requests

Single range is supported.

Examples:

```bash
curl -v http://127.0.0.1:9080/static/big.bin -H 'Range: bytes=0-99'
```

It returns 206.

Bad ranges return 416.

### Precompressed assets

If a client asks for `br` or `gzip`, the server can serve `file.br` or `file.gz`.

Turn it on:

```mumps
S ^MIO("CONF","server","static","precompressed","enabled")=1
S ^MIO("CONF","server","static","precompressed","allowRangeEncoded")=0
```

The server sets:
- `Content-Encoding`
- `Vary: Accept-Encoding`

Example:

```bash
curl -I http://127.0.0.1:9080/static/app.js -H 'Accept-Encoding: br'
```

---

## Multipart upload features

Multipart parsing is in `MIOHTTPMPU`.

It is streaming.

It is MAXSTRING-safe.

It supports:
- scalar parts
- global-backed parts
- disk spooling for large file parts
- nested multipart (optional)
- allowlists for content-type

### Parse multipart

A typical flow:

1) Parse the HTTP request with `MIOHTTP`.
2) Parse multipart with `MIOHTTPMPU`.

Example:

```mumps
N REQ,MP,ERR
I '$$PARSE^MIOHTTP(.DEV,.CONF,.REQ,.ERR) Q
I '$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR) Q
```

### Read a part as a stream

Use the iterator API.

Example:

```mumps
N CUR,CH
D PARTOPEN^MIOHTTPMPU(.MP,1,.CUR,.CONF)
F  Q:'$$PARTNEXT^MIOHTTPMPU(.MP,1,.CUR,.CH)  D
. ; CH is a chunk of bytes
. ; Write it to a file, or append to a global
```

### Slurp a small part

Use `$$PARTSLURP`.

Example:

```mumps
N S
S S=$$PARTSLURP^MIOHTTPMPU(.MP,1,.CONF)
```

---

## WebSocket features

WebSocket support is in `MIOWS`.

It supports:
- RFC 6455 handshake
- frame parsing
- ping and pong
- limits for frame and message size

You can configure:
- `CONF("websocket","maxFrameBytes")`
- `CONF("websocket","maxMessageBytes")`
- `CONF("websocket","idleTimeoutSeconds")`

---

## Observability features

### Access logs

Logging lives in `MIOLOG`.

Access logs are stored in globals.

This is fast.

This is deterministic.

Enable access logs:

```mumps
S ^MIO("CONF","server","log","access","enabled")=1
S ^MIO("CONF","server","log","access","format")="common"
S ^MIO("CONF","server","log","access","maxEntries")=20000
```

Formats:
- `common`
- `combined`
- `json`

### Metrics

Metrics live in `MIOMET`.

They are stored in globals.

They are exported via `/metrics`.

Typical data includes:
- counts
- status buckets
- bytes
- timing

Enable metrics:

```mumps
S ^MIO("CONF","server","metrics","enabled")=1
S ^MIO("CONF","metrics","enabled")=1
```

Retention and cleanup:

```mumps
S ^MIO("CONF","metrics","retentionMinutes")=180
S ^MIO("CONF","metrics","cleanupIntervalSeconds")=60
S ^MIO("CONF","metrics","staleBufferMinutes")=10
```

---

## Auth and RBAC features

Auth middleware lives in `MIOAUTH`.

JWT support lives in `MIOAUTHJWT`.

Authorization checks live in `MIOAUTHZ`.

### API key auth

Config:

```mumps
S ^MIO("CONF","auth","enabled")=1
S ^MIO("CONF","auth","mode")="api_key"
S ^MIO("CONF","auth","apiKey","header")="X-Api-Key"
S ^MIO("CONF","auth","apiKey","value")="change-me"
```

Protect only what you want:

```mumps
S ^MIO("CONF","auth","protectMode")="prefix"
K ^MIO("CONF","auth","protect","prefix")
S ^MIO("CONF","auth","protect","prefix",1)="/api/"
```

### JWT auth (HS256)

Config:

```mumps
S ^MIO("CONF","auth","mode")="jwt"
S ^MIO("CONF","auth","jwt","hmacSecret")="s3cr3t"
S ^MIO("CONF","auth","jwt","bearerPrefix")="Bearer "
S ^MIO("CONF","auth","jwt","clockSkewSeconds")=60
S ^MIO("CONF","auth","jwt","rolesClaim")="roles"
```

Send a token:

```bash
curl http://127.0.0.1:9080/api/me \
  -H 'Authorization: Bearer <token>'
```

### RBAC and ABAC using route meta

`MIOAUTHZ` can use route meta such as:
- `authRequired=1`
- `roles="admin,ops"`
- `ownerParam="id"`
- `ownerClaim="sub"`
- `claims.<name>="<value>"`

Example:

```mumps
N META
S META("authRequired")=1
S META("roles")="admin"
D ADDM^MIOROUTE("GET","/admin","ADMIN^APP",.META)
```

---

## Health and readiness

Health endpoints live in `MIOHEALTH`.

- `/healthz` always returns 200.
- `/readyz` returns 200 or 503.

Ready checks are configurable.

Examples:

```mumps
S ^MIO("CONF","server","health","readyCheckRouterCompiled")=1
S ^MIO("CONF","server","health","readyCheckTemplates")=1
S ^MIO("CONF","server","health","readyCheckSpoolDir")=1
```

---

## Rate limiting

Rate limiting lives in `MIORATE`.

It is a per-IP token bucket.

It is stored in globals.

Enable it:

```mumps
S ^MIO("CONF","server","rate","enabled")=1
S ^MIO("CONF","server","rate","rps")=10
S ^MIO("CONF","server","rate","burst")=20
S ^MIO("CONF","server","rate","trustProxy")=0
S ^MIO("CONF","server","rate","exempt","127.0.0.1")=1
```

---

## Development tools

### Template playground

`MIOPLGD` is a template playground app.

It is meant to demo MIOTPL.

It can render templates in the browser.

It can store a library of templates.

### File watcher

`MIODEVW` is a dev watcher.

It can watch template folders.

It can show a clean TTY dashboard.

---

## MIOTPL template engine (moustache.js style)

MIOTPL is the template engine in this repo.

It is Mustache compatible.

It follows moustache.js core rules.

It also includes practical extensions for real apps.

It is tested by `MIOTPLT`.

### Template files

Templates live in a directory.

Default is `templates/`.

Config:

```mumps
S ^MIO("CONF","server","templateDir")="templates"
```

You can also set a templates root:

```mumps
S ^MIO("CONF","templates","root")="templates"
S ^MIO("CONF","templates","ext")=".html"
```

### Basic render

```mumps
N CONF,CTX,OUT,ERR
M CONF=^MIO("CONF")
S CTX("name")="World"
D RENDER^MIOTPL("hello",.CONF,.CTX,.OUT,.ERR)
I $D(ERR) W ERR("error"),! Q
W OUT,!
```

### Variables

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

### Escaping

`{{name}}` escapes HTML.

`{{{name}}}` does not.

Example:

```mustache
<p>{{name}}</p>
<p>{{{name}}}</p>
```

Context:

```mumps
S CTX("name")="<b>Alice</b>"
```

Output:

```html
<p>&lt;b&gt;Alice&lt;/b&gt;</p>
<p><b>Alice</b></p>
```

### Sections

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

### Inverted sections

Template:

```mustache
{{^items}}
No items.
{{/items}}
```

If `items` is empty, it prints.

### Iteration

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

### Dotted names

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

### Partials

Template:

```mustache
<h1>{{title}}</h1>
{{> card}}
```

Partial:

```mustache
<div class="card">{{text}}</div>
```

### Set delimiters

Mustache supports delimiter changes.

Example:

```mustache
{{=<% %>=}}
Hello <%name%>!
<%={{ }}=%>
Bye {{name}}!
```

MIOTPL supports delimiter changes.

### Layouts and pages

MIOTPL includes helpers to render full pages.

Entry points:
- `RENDERPAGE(PAGE,LAYOUT,...)`
- `RENDERLAYOUT(LAYOUT,...)`

This is useful for web apps.

This is useful for shared headers and footers.

### Streaming and MAXSTRING-safe output

MIOTPL can stream template files.

It can fall back to scalar reads for small files.

Config:

- `CONF("templates","streamFiles")`
- `CONF("templates","streamFallback")`
- `CONF("templates","fileChunk")`

MIOTPL can also control output size.

Config:

- `CONF("output","maxString")`
- `CONF("output","chunk")`
- `CONF("output","auto")`

Use this when you render large pages.

---

## Bench and perf tools

`MIOTPLB` contains benchmark helpers.

It can run compile and render loops.

Config:

- `CONF("bench","iters","compile")`
- `CONF("bench","iters","render")`
- `CONF("bench","warmup")`

---

## FAQ

### Is this server safe for big uploads

Yes.

Bodies are streamed.

Multipart is streamed.

Globals are used for large content.

### Can I use it behind Nginx

Yes.

That is common.

Use `/healthz` and `/readyz` for probes.

### How do I bypass auth for public routes

Use prefix protect mode.

Protect only `/api/` and similar.

Do not protect `/`.

---

## Contributing

Keep changes small.

Add tests.

Keep tests quiet on success.

Follow the rules.

---

## License

Pick a license before release.

Apache-2.0 is common for servers.

MIT is simple.

MPL-2.0 is a middle ground.
