# Configuration

This project uses an M array for configuration.

Most deployments store it in a global.

Most deployments use `^MIO("CONF",...)`.

This document covers:

- copy-and-paste configuration blocks
- a full reference of keys used by the code

---

## Copy-and-paste configurations

These blocks are designed to be pasted at the `YDB>` prompt.

They create a solid starting point.

### Development configuration

This configuration is suitable for local development.

It enables helpful defaults.

It keeps security reasonable.

```mumps
K ^MIO("CONF")

; Listen
S ^MIO("CONF","server","host")="127.0.0.1"
S ^MIO("CONF","server","port")=9080

; Templates
S ^MIO("CONF","server","templateDir")="templates"

; Static
S ^MIO("CONF","server","static","enabled")=1
S ^MIO("CONF","server","static","mount")="/static"
S ^MIO("CONF","server","static","root")="public"
S ^MIO("CONF","server","static","index")="index.html"

; Precompressed static assets
S ^MIO("CONF","server","static","precompressed","enabled")=1
S ^MIO("CONF","server","static","precompressed","allowRangeEncoded")=0

; Static cache policy
S ^MIO("CONF","server","static","cache","enabled")=1
S ^MIO("CONF","server","static","cache","maxAgeSeconds")=3600

; Middleware chain (deterministic order)
K ^MIO("CONF","server","middleware")
S ^MIO("CONF","server","middleware","before",1)="CORSB^MIOMW"
S ^MIO("CONF","server","middleware","before",2)="SECB^MIOMW"
S ^MIO("CONF","server","middleware","before",3)="AUTHB^MIOMW"
S ^MIO("CONF","server","middleware","before",4)="LOGB^MIOMW"
S ^MIO("CONF","server","middleware","after",1)="CORSA^MIOMW"
S ^MIO("CONF","server","middleware","after",2)="SECA^MIOMW"
S ^MIO("CONF","server","middleware","after",3)="LOGA^MIOMW"

; Security preset
S ^MIO("CONF","server","security","preset")="balanced"

; Auth (API key). Only protect selected prefixes.
S ^MIO("CONF","auth","enabled")=1
S ^MIO("CONF","auth","mode")="api_key"
S ^MIO("CONF","auth","protectMode")="prefix"
K ^MIO("CONF","auth","protect","prefix")
S ^MIO("CONF","auth","protect","prefix",1)="/api/"
S ^MIO("CONF","auth","protect","prefix",2)="/admin/"
S ^MIO("CONF","auth","protect","prefix",3)="/metrics"
S ^MIO("CONF","auth","protect","prefix",4)="/debug/"
S ^MIO("CONF","auth","apiKey","header")="X-Api-Key"
S ^MIO("CONF","auth","apiKey","value")="change-me"

; Access logs (globals)
S ^MIO("CONF","server","log","access","enabled")=1
S ^MIO("CONF","server","log","access","format")="json"
S ^MIO("CONF","server","log","access","maxEntries")=20000

; Metrics (globals)
S ^MIO("CONF","server","metrics","enabled")=1

; Health endpoints
S ^MIO("CONF","server","health","enabled")=1

; Rate limiting
S ^MIO("CONF","server","rate","enabled")=1
S ^MIO("CONF","server","rate","rps")=10
S ^MIO("CONF","server","rate","burst")=20
S ^MIO("CONF","server","rate","trustProxy")=0

; Connection caps
S ^MIO("CONF","server","dos","maxActiveConns")=200
S ^MIO("CONF","server","dos","maxConnSeconds")=300

; Error Center
S ^MIO("CONF","server","errors","enabled")=1
S ^MIO("CONF","server","errors","maxEntries")=2000
```

### Production configuration behind a reverse proxy

This configuration is suitable for production.

It assumes Nginx or Caddy terminates TLS.

It enables stricter security settings.

```mumps
K ^MIO("CONF")

; Listen
S ^MIO("CONF","server","host")="127.0.0.1"
S ^MIO("CONF","server","port")=9080

; Hardening limits
S ^MIO("CONF","server","http","limits","maxRequestLineBytes")=8192
S ^MIO("CONF","server","http","limits","maxHeaderLineBytes")=8192
S ^MIO("CONF","server","http","limits","maxHeaderBytes")=65536
S ^MIO("CONF","server","http","limits","maxHeaderCount")=100

; Keep-alive
S ^MIO("CONF","server","keepAlive","enabled")=1
S ^MIO("CONF","server","keepAlive","maxRequests")=200

; Templates
S ^MIO("CONF","server","templateDir")="templates"

; Static
S ^MIO("CONF","server","static","enabled")=1
S ^MIO("CONF","server","static","mount")="/static"
S ^MIO("CONF","server","static","root")="public"
S ^MIO("CONF","server","static","index")="index.html"
S ^MIO("CONF","server","static","precompressed","enabled")=1
S ^MIO("CONF","server","static","cache","enabled")=1
S ^MIO("CONF","server","static","cache","maxAgeSeconds")=31536000
S ^MIO("CONF","server","static","cache","immutable")=1

; Security preset
S ^MIO("CONF","server","security","preset")="strict"

; CSP (start in report-only mode)
S ^MIO("CONF","server","security","csp","enabled")=1
S ^MIO("CONF","server","security","csp","reportOnly")=1
S ^MIO("CONF","server","security","csp","nonce","enabled")=1

; Packs (optional). These simplify middleware setup.
K ^MIO("CONF","server","packs")
S ^MIO("CONF","server","packs","enabled","api_strict")=1
S ^MIO("CONF","server","packs","enabled","debug")=1

; JWT auth (HS256)
S ^MIO("CONF","auth","enabled")=1
S ^MIO("CONF","auth","mode")="jwt"
S ^MIO("CONF","auth","protectMode")="prefix"
K ^MIO("CONF","auth","protect","prefix")
S ^MIO("CONF","auth","protect","prefix",1)="/api/"
S ^MIO("CONF","auth","protect","prefix",2)="/admin/"
S ^MIO("CONF","auth","protect","prefix",3)="/metrics"
S ^MIO("CONF","auth","protect","prefix",4)="/debug/"
S ^MIO("CONF","auth","jwt","hmacSecret")="change-me"
S ^MIO("CONF","auth","jwt","rolesClaim")="roles"
S ^MIO("CONF","auth","jwt","clockSkewSeconds")=60

; Observability
S ^MIO("CONF","server","log","access","enabled")=1
S ^MIO("CONF","server","log","access","format")="json"
S ^MIO("CONF","server","metrics","enabled")=1

; Rate limit
S ^MIO("CONF","server","rate","enabled")=1
S ^MIO("CONF","server","rate","rps")=50
S ^MIO("CONF","server","rate","burst")=100
S ^MIO("CONF","server","rate","trustProxy")=1

; Connection caps
S ^MIO("CONF","server","dos","maxActiveConns")=1000
S ^MIO("CONF","server","dos","maxConnSeconds")=120

; Graceful shutdown
S ^MIO("CONF","server","process","gracefulShutdownSeconds")=10

; Error center
S ^MIO("CONF","server","errors","enabled")=1
S ^MIO("CONF","server","errors","maxEntries")=5000
S ^MIO("CONF","server","errors","capture4xx")=1
S ^MIO("CONF","server","errors","capture404")=0
```

---

## Full key reference

The keys below are discovered by scanning the routines in this repo.

Defaults are shown when the code calls `$GET(CONF(...),DEFAULT)`.

Some defaults are enforced by clamping in code.

### auth.apiKey

- `CONF("auth","apiKey","allow")`
  This setting controls API key authentication.
  It is referenced in: MIOAUTH.m.

- `CONF("auth","apiKey","header")`
  The default value is `"X-Api-Key"`.
  This setting controls API key authentication.
  It is referenced in: MIOAUTH.m.

- `CONF("auth","apiKey","value")`
  This setting controls API key authentication.
  It is referenced in: MIOAUTH.m, MIOMWSTDT.m.


### auth.enabled

- `CONF("auth","enabled")`
  This setting turns the feature on or off.
  It is referenced in: MIOPUBAPI.m.


### auth.exempt

- `CONF("auth","exempt","prefix")`
  This setting is used by the server.
  It is referenced in: MIOAUTH.m.


### auth.jwt

- `CONF("auth","jwt","audience")`
  This setting controls JWT authentication.
  It is referenced in: MIOAUTHJWT.m.

- `CONF("auth","jwt","bearerPrefix")`
  The default value is `"Bearer "`.
  This setting controls JWT authentication.
  It is referenced in: MIOAUTHJWT.m.

- `CONF("auth","jwt","clockSkewSeconds")`
  The default value is `60`.
  This setting defines a timeout value.
  It is referenced in: MIOAUTHJWT.m.

- `CONF("auth","jwt","hmacSecret")`
  This setting controls JWT authentication.
  It is referenced in: MIOAUTHJWT.m.

- `CONF("auth","jwt","issuer")`
  This setting controls JWT authentication.
  It is referenced in: MIOAUTHJWT.m.

- `CONF("auth","jwt","jwksUrl")`
  This setting controls JWT authentication.
  It is referenced in: MIOAUTHJWT.m.

- `CONF("auth","jwt","rolesClaim")`
  The default value is `"roles"`.
  This setting controls JWT authentication.
  It is referenced in: MIOAUTHJWT.m.


### auth.mode

- `CONF("auth","mode")`
  The default value is `"api_key"`.
  This setting selects a mode.
  It is referenced in: MIOAUTH.m, MIOMWSTDT.m, MIOPUBAPI.m.


### auth.protect

- `CONF("auth","protect","prefix")`
  This setting is used by the server.
  It is referenced in: MIOAUTH.m.


### auth.protectMode

- `CONF("auth","protectMode")`
  The default value is `"prefix"`.
  This setting is used by the server.
  It is referenced in: MIOAUTH.m.


### bench.iters

- `CONF("bench","iters","compile")`
  This setting is used by the server.
  It is referenced in: MIOTPLB.m.

- `CONF("bench","iters","render")`
  This setting is used by the server.
  It is referenced in: MIOTPLB.m.


### bench.warmup

- `CONF("bench","warmup")`
  This setting is used by the server.
  It is referenced in: MIOTPLB.m.


### compat.truthiness

- `CONF("compat","truthiness")`
  This setting is used by the server.
  It is referenced in: MIOTPL.m, MIOTPLT.m.


### examples.enabled

- `CONF("examples","enabled")`
  This setting turns the feature on or off.
  It is referenced in: MIODEMO.m.


### metrics.cleanupIntervalSeconds

- `CONF("metrics","cleanupIntervalSeconds")`
  The default value is `60`.
  This setting defines a timeout value.
  It is referenced in: MIOCLEAN.m.


### metrics.enabled

- `CONF("metrics","enabled")`
  The default value is `0`.
  This setting turns the feature on or off.
  It is referenced in: MIOCLEAN.m, MIOMET.m.


### metrics.retentionMinutes

- `CONF("metrics","retentionMinutes")`
  The default value is `180`.
  This setting controls metrics collection.
  It is referenced in: MIOCLEAN.m.


### metrics.staleBufferMinutes

- `CONF("metrics","staleBufferMinutes")`
  The default value is `10`.
  This setting controls metrics collection.
  It is referenced in: MIOCLEAN.m.


### output.auto

- `CONF("output","auto")`
  This setting is used by the server.
  It is referenced in: MIOPLGD.m, MIOTPL.m.


### output.autoReturnRef

- `CONF("output","autoReturnRef")`
  This setting is used by the server.
  It is referenced in: MIOPLGD.m, MIOTPL.m.


### output.chunk

- `CONF("output","chunk")`
  This setting is used by the server.
  It is referenced in: MIOTPL.m, MIOTPLB.m.


### output.maxString

- `CONF("output","maxString")`
  This setting is used by the server.
  It is referenced in: MIOPLGD.m, MIOTPL.m.


### packages.catalogPath

- `CONF("packages","catalogPath")`
  This setting is used by the server.
  It is referenced in: MIOPKG.m.


### referenceApp.enabled

- `CONF("referenceApp","enabled")`
  This setting turns the feature on or off.
  It is referenced in: MIOAPP.m.


### registry.publish

- `CONF("registry","publish","allowUnsigned")`
  The default value is `0`.
  This setting is used by the server.
  It is referenced in: MIOREGADM.m.


### server.cors

- `CONF("server","cors","allowCredentials")`
  The default value is `0`.
  This setting controls CORS behavior.
  It is referenced in: MIOMW.m.

- `CONF("server","cors","allowHeaders")`
  The default value is `"Content-Type,Authorization,X-Api-Key"`.
  This setting controls CORS behavior.
  It is referenced in: MIOMW.m.

- `CONF("server","cors","allowMethods")`
  The default value is `"GET,POST,PUT,PATCH,DELETE,OPTIONS"`.
  This setting controls CORS behavior.
  It is referenced in: MIOMW.m.

- `CONF("server","cors","allowOrigin")`
  The default value is `"*"`.
  This setting controls CORS behavior.
  It is referenced in: MIOMW.m.

- `CONF("server","cors","enabled")`
  The default value is `0`.
  This setting turns the feature on or off.
  It is referenced in: MIOMW.m, MIOMWSTDT.m.

- `CONF("server","cors","exposeHeaders")`
  The default value is `"X-Request-Id"`.
  This setting controls CORS behavior.
  It is referenced in: MIOMW.m.

- `CONF("server","cors","maxAge")`
  The default value is `600`.
  This setting controls CORS behavior.
  It is referenced in: MIOMW.m.

- `CONF("server","cors","vary")`
  The default value is `1`.
  This setting controls CORS behavior.
  It is referenced in: MIOMW.m.


### server.health

- `CONF("server","health","readyCheckRouterCompiled")`
  The default value is `0`.
  This setting is used by the server.
  It is referenced in: MIOHEALTH.m, MIOHEALTHT.m.

- `CONF("server","health","readyCheckSpoolDir")`
  The default value is `0`.
  This setting is used by the server.
  It is referenced in: MIOHEALTH.m, MIOHEALTHT.m.

- `CONF("server","health","readyCheckTemplates")`
  The default value is `0`.
  This setting is used by the server.
  It is referenced in: MIOHEALTH.m, MIOHEALTHT.m, MIOHTTPDOC.m.


### server.http

- `CONF("server","http","allowTECL")`
  The default value is `0`.
  This setting is used by the server.
  It is referenced in: MIOHTTP.m.

- `CONF("server","http","defaultResponseHeaders")`
  This setting is used by the server.
  It is referenced in: MIOHTTP.m, MIOSTATIC.m.

- `CONF("server","http","defaultResponseHeaders","Connection")`
  This setting is used by the server.
  It is referenced in: MIOD.m.

- `CONF("server","http","limits","maxHeaderLineLength")`
  This setting is used by the server.
  It is referenced in: MIOHTTP.m.

- `CONF("server","http","limits","maxRequestLineLength")`
  This setting is used by the server.
  It is referenced in: MIOHTTP.m.

- `CONF("server","http","readBodyChunkBytes")`
  This setting is used by the server.
  It is referenced in: MIOHTTP.m, MIOHTTPDOC.m, MIOHTTPT.m, MIOHTTPTX.m.

- `CONF("server","http","strictTE")`
  The default value is `1`.
  This setting is used by the server.
  It is referenced in: MIOHTTP.m.

- `CONF("server","http","supportChunkedRequest")`
  The default value is `1`.
  This setting is used by the server.
  It is referenced in: MIOHTTP.m, MIOHTTPT.m, MIOHTTPTX.m.


### server.keepAlive

- `CONF("server","keepAlive","enabled")`
  The default value is `1`.
  This setting turns the feature on or off.
  It is referenced in: MIOD.m.

- `CONF("server","keepAlive","idleSeconds")`
  The default value is `10`.
  This setting defines a timeout value.
  It is referenced in: MIOD.m.

- `CONF("server","keepAlive","maxRequests")`
  The default value is `100`.
  This setting is used by the server.
  It is referenced in: MIOD.m.


### server.limits

- `CONF("server","limits","maxBodyBytes")`
  The default value is `10485760`.
  This setting defines an upper limit.
  It is referenced in: MIOHTTP.m, MIOHTTP1CTT.m, MIOHTTPDOC.m, MIOHTTPT.m, MIOHTTPTX.m.

- `CONF("server","limits","maxBodyScalarBytes")`
  The default value is `262144`.
  This setting defines an upper limit.
  It is referenced in: MIOHTTP.m, MIOHTTPDOC.m, MIOHTTPT.m, MIOHTTPTX.m.

- `CONF("server","limits","maxHeaderBytes")`
  This setting defines an upper limit.
  It is referenced in: MIOHTTP.m, MIOHTTPDOC.m, MIOHTTPHDT.m, MIOHTTPT.m, MIOHTTPTX.m.

- `CONF("server","limits","maxHeaderCount")`
  This setting defines an upper limit.
  It is referenced in: MIOHTTP.m, MIOHTTPDOC.m, MIOHTTPHDT.m, MIOHTTPT.m, MIOHTTPTX.m.

- `CONF("server","limits","maxHeaderLineBytes")`
  This setting defines an upper limit.
  It is referenced in: MIOHTTPDOC.m, MIOHTTPHDT.m.

- `CONF("server","limits","maxHeaderLineLength")`
  This setting is used by the server.
  It is referenced in: MIOHTTP.m.

- `CONF("server","limits","maxMultipartHeaderBytes")`
  The default value is `32768`.
  This setting defines an upper limit.
  It is referenced in: MIOHTTPMPU.m.

- `CONF("server","limits","maxMultipartHeaders")`
  The default value is `80`.
  This setting is used by the server.
  It is referenced in: MIOHTTPMPU.m.

- `CONF("server","limits","maxMultipartPartBytes")`
  The default value is `0`.
  This setting defines an upper limit.
  It is referenced in: MIOHTTPMPU.m, MIOHTTPMPUTT.m.

- `CONF("server","limits","maxMultipartPartScalarBytes")`
  The default value is `65536 | MAXSC`.
  This setting defines an upper limit.
  It is referenced in: MIOHTTPMPU.m, MIOHTTPMPUTT.m.

- `CONF("server","limits","maxMultipartParts")`
  The default value is `200`.
  This setting is used by the server.
  It is referenced in: MIOHTTPMPU.m, MIOHTTPMPUTT.m.

- `CONF("server","limits","maxRequestLineBytes")`
  This setting defines an upper limit.
  It is referenced in: MIOHTTP.m, MIOHTTPDOC.m, MIOHTTPHDT.m, MIOHTTPT.m, MIOHTTPTX.m.

- `CONF("server","limits","maxRequestLineLength")`
  This setting is used by the server.
  It is referenced in: MIOHTTP.m.


### server.listen

- `CONF("server","listen","port")`
  The default value is `9080`.
  This setting controls how the server listens for connections.
  It is referenced in: MIOD.m.


### server.log

- `CONF("server","log","access","enabled")`
  The default value is `0`.
  This setting turns the feature on or off.
  It is referenced in: MIOD.m, MIOHEALTH.m, MIOHTTPDOC.m, MIOLOG.m, MIOLOGT.m, MIOMW.m.

- `CONF("server","log","access","flushBytes")`
  The default value is `65536`.
  This setting controls access logging.
  It is referenced in: MIOLOG.m.

- `CONF("server","log","access","flushEvery")`
  The default value is `50`.
  This setting controls access logging.
  It is referenced in: MIOLOG.m.

- `CONF("server","log","access","format")`
  The default value is `"common"`.
  This setting selects a mode.
  It is referenced in: MIOLOG.m, MIOLOGT.m, MIOMWSTDT.m.

- `CONF("server","log","access","maxEntries")`
  The default value is `20000`.
  This setting defines an upper limit.
  It is referenced in: MIOHEALTH.m, MIOLOG.m, MIOLOGT.m, MIOMWSTDT.m.


### server.metrics

- `CONF("server","metrics","enabled")`
  This setting turns the feature on or off.
  It is referenced in: MIOMET.m, MIOMETT.m.


### server.middleware

- `CONF("server","middleware")`
  This setting controls the middleware chain.
  It is referenced in: MIOMW.m.

- `CONF("server","middleware","after")`
  This setting controls the middleware chain.
  It is referenced in: MIOMW.m, MIOROUTE.m.

- `CONF("server","middleware","before")`
  This setting controls the middleware chain.
  It is referenced in: MIOMW.m, MIOROUTE.m.


### server.multipart

- `CONF("server","multipart","allow")`
  This setting is used by the server.
  It is referenced in: MIOHTTPMPU.m.

- `CONF("server","multipart","allow","text/plain")`
  This setting is used by the server.
  It is referenced in: MIOHTTPDOC.m.

- `CONF("server","multipart","allowTypes")`
  This setting is used by the server.
  It is referenced in: MIOHTTPDOC.m, MIOHTTPMPU.m, MIOHTTPMPUTT.m.

- `CONF("server","multipart","enableNested")`
  The default value is `0`.
  This setting is used by the server.
  It is referenced in: MIOHTTPDOC.m, MIOHTTPMPU.m, MIOHTTPMPUTT.m.

- `CONF("server","multipart","maxDepth")`
  The default value is `3`.
  This setting is used by the server.
  It is referenced in: MIOHTTPDOC.m, MIOHTTPMPU.m.

- `CONF("server","multipart","maxFieldScalarBytes")`
  The default value is `8192`.
  This setting defines an upper limit.
  It is referenced in: MIOHTTPMPU.m.

- `CONF("server","multipart","maxMultipartSpoolBytes")`
  The default value is `0`.
  This setting defines an upper limit.
  It is referenced in: MIOHTTPDOC.m, MIOHTTPMPU.m, MIOHTTPMPUTT.m.

- `CONF("server","multipart","spoolDir")`
  The default value is `"/tmp"`.
  This setting defines a path on disk.
  It is referenced in: MIOHEALTH.m, MIOHTTPDOC.m, MIOHTTPMPU.m, MIOHTTPMPUTT.m.

- `CONF("server","multipart","spoolReadChunkBytes")`
  The default value is `16384`.
  This setting is used by the server.
  It is referenced in: MIOHTTPMPU.m.

- `CONF("server","multipart","zeroCopyFileParts")`
  The default value is `0`.
  This setting is used by the server.
  It is referenced in: MIOHTTPDOC.m, MIOHTTPMPU.m, MIOHTTPMPUTT.m.

- `CONF("server","multipart","zrefReadChunkBytes")`
  The default value is `16384`.
  This setting is used by the server.
  It is referenced in: MIOHTTPMPU.m.


### server.rate

- `CONF("server","rate","burst")`
  The default value is `20`.
  This setting controls rate limiting.
  It is referenced in: MIORATE.m, MIORATET.m.

- `CONF("server","rate","enabled")`
  The default value is `0`.
  This setting turns the feature on or off.
  It is referenced in: MIOD.m, MIOHTTPDOC.m, MIORATE.m, MIORATET.m.

- `CONF("server","rate","exempt","9.9.9.9")`
  This setting controls rate limiting.
  It is referenced in: MIORATET.m.

- `CONF("server","rate","perIp","burst")`
  This setting controls rate limiting.
  It is referenced in: MIOHTTPDOC.m.

- `CONF("server","rate","perIp","rps")`
  This setting controls rate limiting.
  It is referenced in: MIOHTTPDOC.m.

- `CONF("server","rate","perIp","ttlSeconds")`
  This setting defines a timeout value.
  It is referenced in: MIOHTTPDOC.m.

- `CONF("server","rate","rps")`
  The default value is `10`.
  This setting controls rate limiting.
  It is referenced in: MIORATE.m, MIORATET.m.

- `CONF("server","rate","trustProxy")`
  The default value is `0`.
  This setting controls rate limiting.
  It is referenced in: MIORATE.m, MIORATET.m.


### server.static

- `CONF("server","static","dirListing","enabled")`
  The default value is `0`.
  This setting turns the feature on or off.
  It is referenced in: MIOSTATIC.m, MIOSTATICIDXT.m, MIOSTATICT.m.

- `CONF("server","static","dirListing","maxEntries")`
  The default value is `1024`.
  This setting defines an upper limit.
  It is referenced in: MIOSTATIC.m, MIOSTATICT.m.

- `CONF("server","static","dirListing","showDotfiles")`
  The default value is `0`.
  This setting is used by the server.
  It is referenced in: MIOSTATIC.m.

- `CONF("server","static","enabled")`
  This setting turns the feature on or off.
  It is referenced in: MIOETAGT.m, MIOHEALTH.m, MIOHEALTHT.m, MIOHTTPDOC.m, MIOSTATIC.m, MIOSTATICIDXT.m.

- `CONF("server","static","etagCacheSeconds")`
  The default value is `30`.
  This setting defines a timeout value.
  It is referenced in: MIOETAGT.m, MIOHTTPDOC.m, MIOSTATIC.m, MIOSTATICT.m.

- `CONF("server","static","etagChunkBytes")`
  The default value is `65536`.
  This setting is used by the server.
  It is referenced in: MIOHTTPDOC.m, MIOSTATIC.m.

- `CONF("server","static","index")`
  The default value is `"index.html"`.
  This setting defines a path on disk.
  It is referenced in: MIOSTATIC.m, MIOSTATICIDXT.m, MIOSTATICT.m.

- `CONF("server","static","maxEtagBytes")`
  The default value is `2097152`.
  This setting defines an upper limit.
  It is referenced in: MIOETAGT.m, MIOHTTPDOC.m, MIOSTATIC.m, MIOSTATICT.m.

- `CONF("server","static","mount")`
  The default value is `"/static"`.
  This setting defines a path on disk.
  It is referenced in: MIOETAGT.m, MIOHTTPDOC.m, MIOSTATIC.m, MIOSTATICIDXT.m, MIOSTATICT.m, MIOSTATICZTT.m.

- `CONF("server","static","mtimeProvider")`
  This setting is used by the server.
  It is referenced in: MIOHTTPDOC.m, MIOSTATIC.m.

- `CONF("server","static","precompressed","allowRangeEncoded")`
  This setting controls precompressed static assets.
  It is referenced in: MIOSTATIC.m, MIOSTATICZTT.m.

- `CONF("server","static","precompressed","enabled")`
  The default value is `0`.
  This setting turns the feature on or off.
  It is referenced in: MIOSTATIC.m, MIOSTATICZTT.m.

- `CONF("server","static","readChunkBytes")`
  The default value is `65536`.
  This setting is used by the server.
  It is referenced in: MIOHTTP.m, MIOHTTPDOC.m, MIOSTATIC.m.

- `CONF("server","static","root")`
  The default value is `"public"`.
  This setting defines a path on disk.
  It is referenced in: MIOETAGT.m, MIOHEALTH.m, MIOHEALTHT.m, MIOHTTPDOC.m, MIOSTATIC.m, MIOSTATICIDXT.m.


### server.templateDir

- `CONF("server","templateDir")`
  The default value is `"templates"`.
  This setting defines a path on disk.
  It is referenced in: MIOHEALTH.m, MIOHTTPDOC.m, MIOTPL.m, MIOTPLW.m.


### server.timeouts

- `CONF("server","timeouts","readBodyMs")`
  The default value is `3`.
  This setting defines a timeout value.
  It is referenced in: MIOD.m, MIOHTTP.m, MIOHTTPDOC.m.

- `CONF("server","timeouts","readHeaderMs")`
  The default value is `2`.
  This setting defines a timeout value.
  It is referenced in: MIOD.m, MIOHTTP.m, MIOHTTPDOC.m.


### templates.captureBlocks

- `CONF("templates","captureBlocks")`
  This setting controls template rendering.
  It is referenced in: MIOTPL.m.


### templates.devWatchEnabled

- `CONF("templates","devWatchEnabled")`
  This setting controls template rendering.
  It is referenced in: MIOTPLW.m.


### templates.devWatchIntervalSeconds

- `CONF("templates","devWatchIntervalSeconds")`
  This setting defines a timeout value.
  It is referenced in: MIOTPLW.m.


### templates.ext

- `CONF("templates","ext")`
  This setting controls template rendering.
  It is referenced in: MIOPLGD.m, MIOTPL.m, MIOTPLT.m.


### templates.fileChunk

- `CONF("templates","fileChunk")`
  This setting controls template rendering.
  It is referenced in: MIOTPL.m.


### templates.maxPartialDepth

- `CONF("templates","maxPartialDepth")`
  This setting controls template rendering.
  It is referenced in: MIOPLGD.m, MIOTPL.m.


### templates.partialsRef

- `CONF("templates","partialsRef")`
  This setting controls template rendering.
  It is referenced in: MIOTPL.m.


### templates.precompileEnabled

- `CONF("templates","precompileEnabled")`
  This setting controls template rendering.
  It is referenced in: MIOPLGD.m, MIOTPL.m, MIOTPLB.m.


### templates.root

- `CONF("templates","root")`
  This setting defines a path on disk.
  It is referenced in: MIOPLGD.m, MIOTPL.m, MIOTPLT.m.


### templates.streamFallback

- `CONF("templates","streamFallback")`
  This setting controls template rendering.
  It is referenced in: MIOPLGD.m, MIOTPL.m.


### templates.streamFiles

- `CONF("templates","streamFiles")`
  This setting controls template rendering.
  It is referenced in: MIOPLGD.m, MIOTPL.m.


### websocket.idleTimeoutSeconds

- `CONF("websocket","idleTimeoutSeconds")`
  The default value is `3600`.
  This setting defines a timeout value.
  It is referenced in: MIOWS.m.


### websocket.maxFrameBytes

- `CONF("websocket","maxFrameBytes")`
  The default value is `65536`.
  This setting defines an upper limit.
  It is referenced in: MIOWS.m.


### websocket.maxMessageBytes

- `CONF("websocket","maxMessageBytes")`
  The default value is `262144`.
  This setting defines an upper limit.
  It is referenced in: MIOWS.m.


