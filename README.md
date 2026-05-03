# MUMPS.IO (MIO) Web Server for YottaDB / GT.M

MUMPS.IO (MIO) is a production-grade web server stack written in MUMPS.

It targets YottaDB r2.02 and works in GT.M-compatible environments.

It is designed for internal tools, APIs, and long-lived enterprise systems.

It is strict by default, and it is heavily tested.

**Current docs build date:** 2026-03-06

---

## Contents

- What this project is
- Design rules
- Quick start
- Request life cycle
- Module overview
- Configuration overview
- MIOHTTP deep dive (HTTP parsing and streaming)
- MIOROUTE deep dive (router)
- MIOMW deep dive (middleware)
- MIOTPL deep dive (Mustache / moustache.js style templates)
- MIOSTATIC deep dive (static files)
- Multipart uploads (MIOHTTPMPU)
- Observability (logs, metrics, error center)
- Security (headers, CSP, auth, RBAC)
- Rate limiting and DoS controls
- Health and readiness
- Graceful shutdown and draining
- Performance harness and regression gates
- Examples gallery
- Deployment notes
- Contributing and support

---

## What this project is

This repository provides a complete web server stack in MUMPS.

It includes HTTP parsing, routing, middleware, templating, and static file serving.

It also includes production features, such as observability, hardening, and graceful shutdown.

The project is designed to be open sourced.

The project is designed to support a professional services business.

---

## Design rules

These rules exist to keep the server predictable.

These rules exist to keep the server safe.

These rules exist to keep the code maintainable.

- Production code does not use `ZSYSTEM`.
- Production code does not use `GOTO`.
- Request bodies are streamed to avoid MAXSTRING failures.
- Large payloads are stored in globals such as `^TMP($J,...)`.
- Errors always include `ERR("routine")` and `ERR("error")`.
- Tests are quiet on success.
- Routing is deterministic.
- Parsing is single-pass whenever possible.
- Caching is used only when it is correct.

---

## Quick start

### 1) Run the full test suite

From the YDB prompt:

```mumps
ZL "MIOTESTS.m"
D ^MIOTESTS
```

If the suite passes, your environment is set up correctly.

### 2) Start the server

Most deployments load configuration from `^MIO("CONF")`.

```mumps
N CONF
M CONF=^MIO("CONF")
D START^MIOD(.CONF)
```

Your repository may also provide a top-level entry routine.

For example, you may start from `MIO` or `MIOMIO`.

### 3) Test the health endpoints

```bash
curl -i http://127.0.0.1:9080/healthz
curl -i http://127.0.0.1:9080/readyz
```

---

## Request life cycle

A single request follows a simple path.

1) The daemon accepts a connection.
2) The daemon reads and parses an HTTP request.
3) The router selects a handler.
4) Middleware runs in a deterministic order.
5) The handler writes a response (often streamed).
6) Observability is recorded (metrics, logs, error ring).
7) Keep-alive decides whether to read another request.

This design makes debugging easier.

This design makes testing easier.

---

## Module overview

This section provides a high-level map.

### Core server
- `MIOD` implements the connection loop.
- `MIOHTTP` parses requests and streams bodies.
- `MIOHTTPRESP` streams responses.
- `MIOROUTE` matches routes and dispatches handlers.

### Web app building blocks
- `MIOTPL` renders Mustache templates.
- `MIOSTATIC` serves static assets.
- `MIOHTTPMPU` parses multipart uploads.

### Middleware and security
- `MIOMW` provides middleware for CORS, security headers, CSP, auth, logging, and metrics.
- `MIOAUTH` implements auth enforcement logic.
- `MIOAUTHJWT` verifies JWTs (HS256) without external commands.
- `MIOAUTHZ` implements authorization checks (roles, owner checks, required claims).

### Observability and operations
- `MIOLOG` stores access logs in globals.
- `MIOMET` stores metrics in globals and serves `/metrics`.
- `MIOERRC` stores errors in a global ring and serves `/debug/*`.
- `MIOHEALTH` serves `/healthz` and `/readyz`.

### Protection
- `MIORATE` applies per-IP rate limiting (globals).
- `MIODOS` applies connection caps (globals).
- `MIODRAIN` coordinates graceful shutdown and draining.

### Developer tools
- `MIOPACK` applies middleware “packs” for simple ops.
- `MIOPERF` is a performance harness and regression gate.

---

## Configuration overview

Configuration is an M array.

Most deployments store configuration in a global.

Most deployments use `^MIO("CONF",...)`.

You can see full configuration documentation in `docs/CONFIG.md`.

This README includes practical configuration examples.

### Minimal development configuration

```mumps
K ^MIO("CONF")

S ^MIO("CONF","server","host")="127.0.0.1"
S ^MIO("CONF","server","port")=9080

S ^MIO("CONF","server","templateDir")="templates"

S ^MIO("CONF","server","static","enabled")=1
S ^MIO("CONF","server","static","mount")="/static"
S ^MIO("CONF","server","static","root")="public"

; Standard middleware chain
K ^MIO("CONF","server","middleware")
S ^MIO("CONF","server","middleware","before",1)="CORSB^MIOMW"
S ^MIO("CONF","server","middleware","before",2)="SECB^MIOMW"
S ^MIO("CONF","server","middleware","before",3)="AUTHB^MIOMW"
S ^MIO("CONF","server","middleware","before",4)="LOGB^MIOMW"
S ^MIO("CONF","server","middleware","after",1)="CORSA^MIOMW"
S ^MIO("CONF","server","middleware","after",2)="SECA^MIOMW"
S ^MIO("CONF","server","middleware","after",3)="LOGA^MIOMW"

; Auth protects only selected prefixes
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
```

---

## MIOHTTP deep dive

`MIOHTTP` is the HTTP/1.1 parser and request body ingestor.

It is strict.

It is streaming.

It is hardened against smuggling.

### Main entry points

These entry points are present in your code:

- PARSE, BODYOPEN, BODYNEXT, RESP, RESPJSON, STREAMBEGIN, STREAMWRITE, STREAMEND, SENDFILE, TRIM, LOW

### Parse a request

The parser fills a request array `REQ(...)`.

It also fills an error array `ERR(...)` on failure.

A common pattern in a connection loop looks like this:

```mumps
N REQ,ERR,OK
S OK=$$PARSE^MIOHTTP(.DEV,.CONF,.REQ,.ERR)
I 'OK D  Q
. ; ERR("routine"), ERR("error"), ERR("status") are set.
. ; Write an error response here.
```

### Read the request body safely

The body may be stored as a scalar or in a global.

You should not assume one mode.

Use the iterator API.

Example that works for all body modes:

```mumps
READBODY(REQ,OUT)
  K OUT
  N CUR,CH,I
  D BODYOPEN^MIOHTTP(.REQ,.CUR)
  S I=0
  F  Q:'$$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH)  D
  . S I=I+1
  . S OUT(I)=CH
  Q
```

### Respond with JSON

Use `RESPJSON` for JSON responses.

This keeps responses consistent.

```mumps
N BODY
S BODY="{""ok"":true}"
D RESPJSON^MIOHTTP(.DEV,200,"OK",BODY,.CTX)
```

### Stream a response

Streaming is useful for large outputs.

Streaming avoids MAXSTRING issues.

Example streaming response:

```mumps
D STREAMBEGIN^MIOHTTP(.DEV,200,"OK","text/plain; charset=utf-8",.CTX)
D STREAMWRITE^MIOHTTP(.DEV,"first chunk",.CTX)
D STREAMWRITE^MIOHTTP(.DEV,$C(10),.CTX)
D STREAMWRITE^MIOHTTP(.DEV,"second chunk",.CTX)
D STREAMEND^MIOHTTP(.DEV,.CTX)
```

### Send a static file efficiently

`SENDFILE` is used by the static handler.

It supports HEAD correctness.

It supports keep-alive.

---

## MIOROUTE deep dive

`MIOROUTE` provides deterministic routing.

It supports static paths, params, and wildcards.

### Main entry points

These entry points are present in your code:

- ADD, ADDM, COMPILE, DISPATCH

### Register routes

```mumps
D ADD^MIOROUTE("GET","/","HOME^APP")
D ADD^MIOROUTE("GET","/users/:id","USER^APP")
D ADD^MIOROUTE("GET","/static/*path","STATIC^MIOSTATIC")
D COMPILE^MIOROUTE()
```

### Register a route with metadata

Metadata supports auth, RBAC, and per-route middleware.

```mumps
N META
S META("authRequired")=1
S META("roles")="admin,ops"
S META("mw_before")="AUTHB^MIOMW"
S META("mw_after")="LOGA^MIOMW"
D ADDM^MIOROUTE("GET","/admin","ADMIN^APP",.META)
D COMPILE^MIOROUTE()
```

### Dispatch

The daemon calls dispatch after parsing.

You can also dispatch in tests.

```mumps
N ERR
D DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX,.ERR)
```

---

## MIOMW deep dive

`MIOMW` implements the middleware pipeline.

Middleware runs in a deterministic order.

Middleware can run globally and per-route.

### Global middleware configuration

```mumps
K ^MIO("CONF","server","middleware")
S ^MIO("CONF","server","middleware","before",1)="CORSB^MIOMW"
S ^MIO("CONF","server","middleware","before",2)="SECB^MIOMW"
S ^MIO("CONF","server","middleware","before",3)="AUTHB^MIOMW"
S ^MIO("CONF","server","middleware","before",4)="LOGB^MIOMW"
S ^MIO("CONF","server","middleware","after",1)="CORSA^MIOMW"
S ^MIO("CONF","server","middleware","after",2)="SECA^MIOMW"
S ^MIO("CONF","server","middleware","after",3)="LOGA^MIOMW"
```

### Per-route middleware configuration

Use route metadata:

```mumps
N META
S META("mw_before")="AUTHB^MIOMW"
S META("mw_after")="LOGA^MIOMW"
D ADDM^MIOROUTE("GET","/secure","SECURE^APP",.META)
```

### CORS middleware

CORS middleware supports preflight behavior.

You can configure origins and allowed headers.

Example:

```mumps
S ^MIO("CONF","server","cors","enabled")=1
S ^MIO("CONF","server","cors","allowOrigin")="https://example.com"
S ^MIO("CONF","server","cors","allowCredentials")=0
```

Preflight example:

```bash
curl -i -X OPTIONS http://127.0.0.1:9080/api/me \
  -H 'Origin: https://example.com' \
  -H 'Access-Control-Request-Method: GET'
```

### Security headers and CSP

Security presets include `dev`, `balanced`, and `strict`.

```mumps
S ^MIO("CONF","server","security","preset")="strict"
```

CSP can start in report-only mode:

```mumps
S ^MIO("CONF","server","security","csp","enabled")=1
S ^MIO("CONF","server","security","csp","reportOnly")=1
```

Nonce mode is supported:

```mumps
S ^MIO("CONF","server","security","csp","nonce","enabled")=1
```

Template usage:

```html
<script nonce="{{csp_nonce}}">/* inline */</script>
```

---

## MIOTPL deep dive

`MIOTPL` is the Mustache template engine in this repository.

It aims to match moustache.js behavior for the Mustache core.

It is built for correctness first.

It is built for performance second.

The test harness is `MIOTPLT`.

### Main entry points

These entry points are present in your code:

- START, PRECOMPILE, RENDER, RENDERPAGE, RENDERLAYOUT, COMPILE, PARSE, EVAL

### Minimal render

Template file `templates/hello.html`:

```mustache
Hello {{name}}!
```

Render call:

```mumps
N CONF,CTX,OUT,ERR
M CONF=^MIO("CONF")
S CONF("server","templateDir")="templates"
S CTX("name")="World"
D RENDER^MIOTPL("hello",.CONF,.CTX,.OUT,.ERR)
I $D(ERR) W "ERR=",ERR("error"),! Q
W OUT,!
```

### Variables and escaping

Double braces escape HTML.

Triple braces do not escape.

Template:

```mustache
<p>{{name}}</p>
<p>{{{{{name}}}}}</p>
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

### Sections and lists

Template:

```mustache
{{#items}}- {{.}}
{{/items}}
{{^items}}No items.
{{/items}}
```

Context:

```mumps
S CTX("items",1)="one"
S CTX("items",2)="two"
```

Output:

```text
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

```text
User: Rita
```

### Partials

Main template `templates/page.html`:

```mustache
<h1>{{title}}</h1>
{{> card}}
```

Partial `templates/partials/card.html`:

```mustache
<div class="card">{{text}}</div>
```

Context:

```mumps
S CTX("title")="Home"
S CTX("text")="Welcome"
```

### Indentation rules for partials

Mustache partial indentation rules are important.

They keep HTML clean.

They also keep YAML and code templates clean.

Example:

```mustache
<ul>
  {{> item}}
</ul>
```

If `item` has multiple lines, all of them inherit the indentation.

### Precompile and cache

Precompiling at startup improves performance.

It also reduces per-request overhead.

Example:

```mumps
N CONF
M CONF=^MIO("CONF")
D START^MIOTPL(.CONF)
D PRECOMPILE^MIOTPL(.CONF)
```

---

## MIOSTATIC deep dive

`MIOSTATIC` provides safe static file serving.

It enforces path safety.

It provides cache correctness.

### Basic mount

```mumps
S ^MIO("CONF","server","static","enabled")=1
S ^MIO("CONF","server","static","mount")="/static"
S ^MIO("CONF","server","static","root")="public"
```

### ETag and If-None-Match

ETag supports 304 revalidation.

Example:

```bash
curl -i http://127.0.0.1:9080/static/app.js
curl -i http://127.0.0.1:9080/static/app.js -H 'If-None-Match: W/"...paste..."'
```

### Last-Modified and If-Modified-Since

Example:

```bash
curl -i http://127.0.0.1:9080/static/app.js
curl -i http://127.0.0.1:9080/static/app.js -H 'If-Modified-Since: Thu, 31 Dec 1840 00:00:00 GMT'
```

### Range support

Example:

```bash
curl -i http://127.0.0.1:9080/static/big.bin -H 'Range: bytes=0-99'
```

### Precompressed `.br` and `.gz`

Enable:

```mumps
S ^MIO("CONF","server","static","precompressed","enabled")=1
S ^MIO("CONF","server","static","precompressed","allowRangeEncoded")=0
```

Then:

```bash
curl -I http://127.0.0.1:9080/static/app.js -H 'Accept-Encoding: br'
```

The server sets `Content-Encoding` and `Vary: Accept-Encoding`.

---

## Multipart uploads (MIOHTTPMPU)

Multipart parsing is streaming and MAXSTRING-safe.

It supports per-part limits.

Example handler flow:

```mumps
N REQ,MP,ERR
I '$$PARSE^MIOHTTP(.DEV,.CONF,.REQ,.ERR) Q
I '$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR) Q
```

Streaming a part:

```mumps
N CUR,CH
D PARTOPEN^MIOHTTPMPU(.MP,1,.CUR,.CONF)
F  Q:'$$PARTNEXT^MIOHTTPMPU(.MP,1,.CUR,.CH)  D
. ; CH is a byte chunk
. ; Write it to a file or a global
```

---

## Observability

This stack stores hot-path data in globals.

This keeps overhead low.

This keeps behavior deterministic.

### Access logs

```mumps
N LINE,SEQ
D ALAST^MIOLOG(.LINE,.SEQ)
W SEQ,": ",LINE,!
```

### Metrics

```bash
curl -i http://127.0.0.1:9080/metrics
```

### Error Center

```bash
curl -i http://127.0.0.1:9080/debug/errors
curl -i http://127.0.0.1:9080/debug/config
```

---

## Security

Security is layered.

It starts in parsing.

It continues in middleware.

It ends in route-level authorization.

### JWT auth and RBAC route meta examples

RBAC example:

```mumps
N META
S META("authRequired")=1
S META("roles")="admin"
D ADDM^MIOROUTE("GET","/admin","ADMIN^APP",.META)
```

Owner check example:

```mumps
N META
S META("authRequired")=1
S META("ownerParam")="id"
S META("ownerClaim")="sub"
D ADDM^MIOROUTE("GET","/item/:id","ITEM^APP",.META)
```

---

## Rate limiting and DoS controls

```mumps
S ^MIO("CONF","server","rate","enabled")=1
S ^MIO("CONF","server","rate","rps")=50
S ^MIO("CONF","server","rate","burst")=100

S ^MIO("CONF","server","dos","maxActiveConns")=1000
S ^MIO("CONF","server","dos","maxConnSeconds")=120
```

---

## Health and readiness

`/healthz` always returns 200.

`/readyz` returns 200 or 503.

---

## Graceful shutdown and draining

The server supports graceful shutdown.

It stops accepting new connections.

It drains active connections up to a deadline.

---

## Performance harness and regression gates

```mumps
ZL "MIOPERFT.m"
D START^MIOPERFT
```

Enable gates:

```mumps
S ^MIO("CONF","server","perf","enabled")=1
```

---

## Examples gallery

### Example. Render HTML with MIOTPL in a handler

```mumps
APP ;
HOME(DEV,CONF,REQ,CTX)
  N TCTX,OUT,ERR
  M TCTX=CTX
  S TCTX("title")="Home"
  D RENDER^MIOTPL("home",.CONF,.TCTX,.OUT,.ERR)
  I $D(ERR) D RESPJSON^MIOHTTP(.DEV,500,"ERR","{""error"":""template""}",.CTX) Q
  D RESP^MIOHTTP(.DEV,200,"OK","text/html; charset=utf-8",OUT,.CTX)
  Q
```

---

## Deployment notes

This project includes a deployment pack.

It includes systemd, Nginx, Caddy, and Kubernetes examples.

Use `/healthz` and `/readyz` for probes.

Use graceful shutdown for rolling deploys.

---

## Contributing and support

Run the test suite before you submit a change.

Add tests for new behavior.

Keep tests quiet on success.

Follow the no-`ZSYSTEM` and no-`GOTO` rules.



#TODO IN README
```Next README expansions I will generate

      Full request lifecycle walkthrough

      Step-by-step flow

      MIOD → MIOHTTP → MIOROUTE → MIOMW → handler → response

      Real REQ(...), CTX(...), ERR(...) structures

      Example debug traces

      Deep MIOTPL documentation

      moustache.js compatibility table

      section evaluation rules

      dotted name resolution algorithm

      partial indentation behavior

      caching internals

      template inheritance examples

      performance considerations

      Advanced MIOHTTP internals

      HTTP parsing algorithm

      chunked transfer decoding

      request body streaming modes

      MAXSTRING avoidance design

      security protections (TE/CL conflicts, duplicate headers)

      Router internals

      route compilation

      wildcard matching

      param extraction

      middleware injection

      Production deployment guide

      systemd

      nginx

      caddy

      docker

      kubernetes probes

      Debugging guide

      tracing middleware

      reading the error center

      interpreting logs and metrics

      Full working application example

      small but complete MIO web app

      templates

      API

      auth

      static assets
      ```

    ```
    installation notes for a fresh ubuntu install
     sudo apt-get install --no-install-recommends file cmake make gawk gcc git curl tcsh libjansson4 {libconfig,libelf,libicu,libncurses,libreadline,libjansson,libssl}-dev binutils ca-certificates
 
 
    source $(pkg-config --variable=prefix yottadb)/ydb_env_set
    export ydb_routines=`$ydb_dist/yottadb -run %XCMD 'W $P($P($ZRO,"(",1,2),")")_" "_"/home/aa/work/mumps.io/routines"_")"_$P($ZRO,")",2,$L($ZRO,"'` 
    ```

    ## Beginners Ubuntu
A Beginners Guide To Things To Do After Installing Ubuntu.
####	1. Check For Updates

	sudo apt update && sudo apt upgrade

#### 2. Enable additional repositories for more software
Ubuntu has several repositories from where it provides software for your system. 
Enabling all these repositories will give you access to more software and proprietary drivers.

- open Gnome Search Box and search for Software & Updates:


Under the Ubuntu Software tab, make sure you have **checked all of the Main, Universe, Restricted and Multiverse repository** checked. 

Now move to the **Other Software** tab, check the option of **Canonical Partners**. 

You’ll have to enter your password in order to update the software sources. Once it completes, you’ll find more applications to install in the Software Center.

####	3.  Install All Missing / Additional Drivers
To install Additional or Missing Drivers on your Ubuntu 18.04 LTS dekstop,
- Open Gnome Search Box search for Software & update.
- Click on “Additional Drivers” Tab and follow the specific instructions provided on the screen.

####	4.Installing Complete Multimedia Support
In order to play media files like MP#, MPEG4, AVI etc, you’ll need to install media codecs. Ubuntu has them in their repository but doesn’t install it by default because of copyright issues in various countries.
	
	sudo apt install ubuntu-restricted-extras
	
####	5. Improve Battery by installing TLP for Linux

	sudo apt-get install tlp tlp-rdw
	
Once installed, run the command below to start it:
	
	sudo tlp start
	
####	6. Enable ‘Minimize on Click’ for the Ubuntu Dock 
I like to click on an app icon in the Dock to both restore, switch to and minimise it. This is the default behaviour in Windows.

But by default the Ubuntu Dock has this option turned off.default the Ubuntu Dock has this option turned off.

To enable minimise on click for the Ubuntu Dock, just run this command in the Terminal:
	
	gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
####	7. Turn On Night Light

To enable Night light in the Ubuntu desktop, head over to.
 light. 
 - Settings > Devices > Screen Display >Night Light. 
 - Turn on the toggle switch for enabling Night light. 

*Additionally, you can also schedule the time for when Night Light sets in.*

####	8. Cleaning

To remove the packages that failed to install completely,

	sudo apt-get autoclean

Additionally, to remove the apt-cache,

	 sudo apt-get clean

Finally, to remove the unwanted software dependencies,
	 
	 sudo apt-get autoremove

####	9. Disable Startup Applications from the gnome app list. 
In the Startup Application Preferences, you can disable, add or remove the programs. 

 - Open Gnome Search Box
 - Search for Startup Application
 - Here you can add/remove programs 

    
####	10. Install GNOME Shell Extensions
**GNOME Shell Extensions** are a great way for GNOME desktop users to customize their user experience by configuring interface components like launching animations, window management. 

The GNOME Shell Extensions mainly work as extensions for your web browsers, such as chrome or firefox. Installation is done with just a flick of a button.  A must-have feature to have after installing Ubuntu. 

GNOME Extensions website: https://extensions.gnome.org/  

####	11. Change the look of your desktop with new themes and icons
allow you to customize your desktop environment the way you like. 
	
	sudo apt install gnome-tweak-tool -y
	
####	12.Use Flatpak in Ubuntu 18.04 to get access to more applications 
Flatpak is a universal packaging system from Fedora. Like Snap, you can install Flatpak packaged applications in various Linux distributions that support Flatpak. 

>Ubuntu 18.04 supports Flatpak by default. However, with a few tweaks, you can get Flatpak applications directly in Ubuntu Software Center. This will enable you to easily install additional applications like Viber etc which you won’t find in the default Ubuntu Software Center.

First, check if Flatpak support is enabled or not (minimal install option don’t have Flatpak:

	sudo apt install flatpak

And then, install the Flatpak plugin for GNOME Software Center.

	sudo apt install gnome-software-plugin-flatpak

The last thing would be to add the Flathub repository that will give you access to all the applications available on Flathub website.

	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

>The only **downside** is that you’ll see multiple applications in Ubuntu software center. Flatpak applications are tagged with source dl.flathub.org and thus you can easily distinguish them.
####	13. Opt out of data collection in Ubuntu 18.04 (optional)
you can disable it by going to System Settings -> Privacy and then set the Problem Reporting to Manual or you can set it to never.

####	13. Customize the dock panel.

	 gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
	 gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
	 gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode FIXED
	 gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 64
	 gsettings set org.gnome.shell.extensions.dash-to-dock unity-backlit-items true

Tip #1: Use apt-fast instead of apt-get
apt-fast is a shell script wrapper for apt-get and aptitude that can drastically improve APT download times by downloading packages with multiple connections per package. 

The apt-fast package can be installed in all currently supported versions of Ubuntu by adding the apt-fast/stable PPA to your software sources and installing it using these commands.

	sudo add-apt-repository ppa:apt-fast/stable 
	sudo apt-get update
	sudo apt-get install apt-fast  