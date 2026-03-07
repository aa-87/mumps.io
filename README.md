# MUMPS.IO (MIO) Web Server for YottaDB / GT.M

MUMPS.IO (MIO) is a production-grade web server stack written in MUMPS.

It targets YottaDB r2.02 and works in GT.M-compatible environments.

It is designed for internal tools, APIs, and long-lived enterprise systems.

It is strict by default, and it is heavily tested.

---

## Core principles

This project follows hard rules.

These rules exist to keep the server safe and predictable.

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

## Getting started

### Run the full test suite

From the YDB prompt:

```mumps
ZL "MIOTESTS.m"
D ^MIOTESTS
```

If the suite passes, your environment is set up correctly.

### Start the server

Most deployments load config from `^MIO("CONF")`:

```mumps
N CONF
M CONF=^MIO("CONF")
D START^MIOD(.CONF)
```

Your repository may also provide a top-level entry routine.

For example, you may start from `MIO` or `MIOMIO`.

---

## Documentation

This repository ships with dedicated documentation pages.

- `docs/CONFIG.md`  
  This document lists configuration keys used by the code.  
  It also includes copy-and-paste “golden configs”.

- `docs/MIOTPL.md`  
  This document explains MIOTPL in detail.  
  It includes many examples.  
  It focuses on moustache.js style Mustache behavior.

- `docs/CURL.md`  
  This document is a curl cookbook for common endpoints and features.

---

## Major components

- `MIOD` implements the daemon loop and keep-alive behavior.  
  It also implements graceful shutdown and connection draining.

- `MIOHTTP` parses HTTP/1.1 requests.  
  It enforces strict hardening rules.  
  It streams bodies into globals when needed.

- `MIOHTTPMPU` parses `multipart/form-data` bodies in a streaming way.

- `MIOROUTE` implements deterministic routing with params and wildcards.  
  It also supports per-route metadata.

- `MIOMW` implements middleware.  
  It includes CORS, security headers, CSP support, auth, logging, and metrics hooks.

- `MIOSTATIC` implements static file serving.  
  It supports ETags, Last-Modified, range requests, and precompressed assets.

- `MIOTPL` implements the Mustache template engine.  
  Its test harness is `MIOTPLT`.

---

## What you get out of the box

You get a strict HTTP server.

You get streaming request bodies and streaming multipart parsing.

You get deterministic routing and middleware.

You get static files with cache correctness.

You get security headers and optional CSP.

You get API key and JWT auth.

You get RBAC and owner checks via route metadata.

You get access logs and metrics stored in globals.

You get a global-backed Error Center and debug endpoints.

You get rate limiting and connection-level protections.

---

## Next steps

Start with `docs/CONFIG.md`.

Then read `docs/MIOTPL.md`.

Finally, use `docs/CURL.md` during testing and deployment.
