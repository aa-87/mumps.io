MUMPS.IO Web Server
Architecture and Routine Guide
Detailed documentation of the current web server stack, with special focus on MIOHTTP, MIOAUTHZ, and their associated routines.
Document purpose	Explain how the MUMPS.IO web server is structured and how requests move through it.
Primary focus	MIOHTTP, MIOAUTHZ, and the routines that connect parsing, routing, middleware, auth, static delivery, logging, health, and metrics.
Code baseline	Uploaded routines folder in routines.zip, after reverting the failed enhancement branch.
Audience	Developers, maintainers, and future contributors.

Important note: this guide describes the current stable routines in the uploaded source tree. It does not assume the reverted enhancement patches are active.


Executive Summary
The MUMPS.IO web server is organized as a small, focused set of routines that each own one part of the HTTP lifecycle. The design is practical and production-oriented: sockets are handled in one place, HTTP parsing and response writing are handled in one place, routing and middleware are separated, and authentication and authorization are layered rather than mixed into handlers.
At the center of the stack is MIOHTTP. It is responsible for request-line parsing, header parsing, request-body framing, chunked-body reading, safe body storage, and response helpers. It is the routine that turns raw bytes into a structured REQ array and turns handler output back into valid HTTP responses.
The authorization center of the stack is MIOAUTHZ. It does not perform authentication itself. Instead, it consumes the auth context produced by MIOAUTH and MIOAUTHJWT, reads route metadata from MIOROUTE, and enforces RBAC and ABAC rules in a clean, predictable way.
Around those two routines is a coherent server shell: MIOD drives worker execution, MIOSOCK handles socket I/O, MIOROUTE resolves routes, MIOMW wires standard middleware, MIOAUTH handles auth policy, MIOSTATIC serves files, MIOHEALTH exposes health checks, and MIOLOG / MIOMET / MIORATE provide observability and protective controls.
Reading Guide
• Read Section 2 first if you want a quick map of the system.
• Read Section 4 if you want to understand how the HTTP parser and response engine work.
• Read Section 5 if you want to understand route authorization in detail.
• Read Sections 6 through 9 if you want the larger server picture around routing, middleware, auth, static delivery, and operations.
System Map
The routines below form the practical web-server core in the uploaded codebase.
Routine	Primary role	Why it matters
MIOD	Worker daemon and request lifecycle driver	START, RUN, JOBCONN, keep-alive and WebSocket request decisions
MIOSOCK	Socket read/write helpers	LISTEN, WAIT, READLN, READN, WRITE, CLOSE
MIOHTTP	HTTP parser and response engine	PARSE, PARSEHDRS, READBODYONLY, READCHUNKED, RESP, RESPJSON, STREAMBEGIN, SENDFILE
MIOROUTE	Router and dispatcher	ADD, ADDM, COMPILE, MATCH, DISPATCH, GETMETA
MIOMW	Standard middleware set	ENSURE, CORSB/CORSA, SECB/SECA, AUTHB, LOGB/LOGA
MIOAUTH	Authentication policy layer	ENFORCE, ENFAPIKEY, ENFJWT, path protection decisions
MIOAUTHJWT	JWT verification and claim application	VERIFY, CHECKCLAIMS, APPLY, Base64URL helpers
MIOAUTHZ	Route authorization layer	ENFORCE, DENY
MIOSTATIC	Static file serving	STATIC, MIME, ETag/range/IMS helpers
MIOHEALTH	Health and readiness endpoints	HEALTH, READY
MIOLOG	Structured logging and access log	ACCESS, INFO/WARN/ERROR, flush helpers
MIOMET	Metrics and Prometheus export	OBS, METRICS
MIORATE	Token-bucket rate limiting	ALLOW, ALLOWAT
MIOCONF / MIOCONFV	Config and config validation	configuration source and validation support

High-Level Request Lifecycle
A normal HTTP request passes through the stack in a predictable order. The same structure is what makes the server easy to reason about, easy to test, and easy to extend.
• MIOD accepts or owns the connection and decides whether to keep the connection alive after the request.
• MIOSOCK reads bytes from the socket device with timeouts.
• MIOHTTP parses the request line, headers, query parameters, and request body.
• MIOROUTE resolves the handler and route metadata.
• MIOMW runs standard before middleware, including CORS, security, authentication, and access-log setup.
• MIOAUTH authenticates the request when protection rules apply.
• MIOAUTHZ authorizes the request against route metadata, roles, claims, and ownership rules.
• The matched handler runs, often using MIOHTTP response helpers to write the response.
• After middleware runs, then logging, metrics, and connection reuse decisions finish the request.
Lifecycle by routine
Step	What happens	Primary routines
1	Connection accepted	MIOD, MIOSOCK
2	Headers and body parsed	MIOHTTP
3	Route matched and metadata loaded	MIOROUTE
4	Before middleware executes	MIOMW
5	Authentication check	MIOAUTH / MIOAUTHJWT
6	Authorization check	MIOAUTHZ
7	Handler executes	Route handler / MIOSTATIC / MIOHEALTH / app routines
8	Response written	MIOHTTP
9	After middleware, logs, metrics, keep-alive	MIOMW, MIOLOG, MIOMET, MIOD

MIOHTTP: Detailed Design
MIOHTTP is the routine that turns raw HTTP into structured request data and turns handler output into valid HTTP responses. It is intentionally central. If a developer wants to understand the server, this is the first routine to master.
What MIOHTTP owns
• Request-line parsing.
• Query-string parsing and URL decoding.
• Header reading, validation, and size/count limits.
• Request-body framing decisions for Content-Length and Transfer-Encoding.
• Chunked request-body parsing.
• MAXSTRING-safe body storage using either scalar or ^TMP global chunks.
• Response writers for plain text, JSON, streaming output, and sendfile output.
• Helpers used by the worker and middleware layers, including 100-continue decisions.
What MIOHTTP does not own
• Socket accept and raw device lifecycle; that belongs to MIOD and MIOSOCK.
• Route selection; that belongs to MIOROUTE.
• Authentication and authorization policy; that belongs to MIOAUTH and MIOAUTHZ.
• Business logic in handlers; that belongs to the application routines.
• Static-file policy decisions beyond the write helpers; MIOSTATIC is its own module.
Public entry points
Entry point	Responsibility
PARSE	Read request line, headers, and body in one call.
PARSEHDRS	Read only request line and headers.
READBODYONLY	Read only the body after a header-only phase.
READLINE / READFIX	Low-level line and fixed-size readers.
PARSEREQLINE / PARSEQRY / URLDECQ	Request-target parsing helpers.
READHDRS / READCHUNKED	Header and chunked-body readers.
BODYOPEN / BODYNEXT / BODYLEN / BODYFREE	Streaming consumption and cleanup helpers for request bodies.
STATUS4ERR / STATUSMSG	Map parser failures to status codes and phrases.
RESP / RESPJSON / RESPX / RESPJSONX	Primary response helper family.
EXPECTDECIDE / SEND100	Support for Expect: 100-continue flows.
STREAMBEGIN / STREAMWRITE / STREAMEND	Chunked streaming response support.
SENDFILE	File response helper.

Request model
The routine produces a REQ array with a stable shape. This is one of the strongest parts of the design because downstream routines can stay simple once the parser has normalized the request.
Field	Meaning
REQ("method")	HTTP method, such as GET or POST
REQ("rawpath")	Original request target before query stripping
REQ("path")	Normalized path without the query string
REQ("httpver")	HTTP version token, such as HTTP/1.1
REQ("query",key)	Query parameter values after URL decoding
REQ("hdr",lowerHeaderName)	Normalized header map
REQ("body",...)	Body storage subtree

Body storage model
The body-storage model is one of the most important design choices in MIOHTTP. It prevents MAXSTRING problems while keeping the common small-body path fast.
Mode	Why it exists
Scalar mode	Small bodies stay in REQ("body"). REQ("body","mode")="scalar". This is the fast path for ordinary API and form requests.
Global mode	Large bodies are split into chunks under ^TMP($J,"MIOHTTP","BODY",REQID,...). REQ("body","mode")="global" and the REQ array stores a reference, chunk count, and length.
Streaming consumption	Downstream code should use BODYOPEN and BODYNEXT when body size can be large.
Cleanup	BODYFREE must be called once the request body is no longer needed.

Why this matters operationally
This design means the server can accept normal web forms, JSON API payloads, and larger uploads without forcing all callers into one memory strategy. It also lets higher-level routines read the body incrementally, which is a good fit for MUMPS environments where accidental large-string concatenation is expensive or unsafe.
Request-body framing rules
MIOHTTP follows a clear framing model. Transfer-Encoding takes precedence over Content-Length. Chunked request bodies are supported when the feature is enabled. Unsupported transfer-encoding tokens are rejected. Limits are enforced early, and the parser distinguishes header limits from body limits.
The split-flow helpers are especially valuable. PARSEHDRS lets the server inspect headers first. EXPECTDECIDE then determines whether a body should be accepted. SEND100 writes the interim response only after the server decides the body is allowed. READBODYONLY then reads the request body using the same rules as the full parser. This is the cleanest way to handle large uploads and early rejection paths.
Response engine
MIOHTTP is not only a parser. It is also the response engine. That matters because request and response policy stay close together in one module, which reduces drift between parse-time assumptions and write-time behavior.
• RESP and RESPX write standard responses with explicit header maps.
• RESPJSON and RESPJSONX serialize object arrays to JSON and write the correct content type.
• STREAMBEGIN, STREAMWRITE, and STREAMEND support chunked streaming responses.
• SENDFILE writes file responses and integrates naturally with HEAD and GET behavior.
• STATUS4ERR gives the rest of the server a clean translation from parser errors to HTTP status codes.
Configuration knobs in MIOHTTP
Setting	Purpose
maxRequestLineBytes	Maximum request-line size
maxHeaderLineBytes	Maximum size of a single header line
maxHeaderBytes	Maximum total header bytes
maxHeaderCount	Maximum number of headers
maxBodyBytes	Maximum accepted body size
maxBodyScalarBytes	Threshold before upgrading body storage to global mode
readBodyChunkBytes	Chunk size for body reads
supportChunkedRequest	Enable or disable chunked request bodies
readHeaderMs / readBodyMs	Header and body read timeouts

Associated HTTP routines
Routine	Why it matters
MIOHTTPDOC	Developer-facing documentation routine for MIOHTTP.
MIOHTTPT / MIOHTTPP1T / MIOHTTPRESPT / MIOHTTPHDT / MIOHTTP1CTT	Dedicated parser, helper, header, response, and 100-continue test coverage.
MIOHTTPMPU / MIOHTTPMPUTT	Multipart/form-data companion parser and its test suite.

MIOAUTHZ: Detailed Design
MIOAUTHZ is the authorization layer. It does not decide whether a request carries a valid API key or JWT. Instead, it assumes authentication has already populated CTX("auth",...) and it decides whether the authenticated principal is allowed to access the matched route.
Core responsibility
The routine reads route metadata from MIOROUTE and applies three families of authorization checks: authentication required, role-based checks, and attribute-based ownership or claim checks. The result is simple but powerful because the route itself carries the authorization contract.
Route metadata contract
Metadata	Meaning
authRequired=1	The route requires authentication.
roles="admin,user"	Any-of role match. If none of the listed roles are present in CTX("auth","roles",...), access is denied.
claims.<name>="<value>"	Exact claim match requirement.
ownerParam="id"	Path or request parameter name used for ownership checks.
ownerClaim="sub"	Claim name compared with the request parameter value.

How ENFORCE works
• Find the matched route pattern from CTX("match","route") or CTX("route").
• Load route metadata from MIOROUTE.
• If authRequired is not set, allow the request immediately.
• If CTX("auth","ok") is not true, deny with a 403 payload from MIOAUTHZ that says the caller is not authenticated.
• If roles are required, look for any required role in CTX("auth","roles",...).
• If claims.<name> requirements are present, compare exact values against CTX("auth","claim",name).
• If ownerParam and ownerClaim are present, compare the request parameter to the claim and deny if they do not match.
• If all checks pass, return 1 and let the handler run.
Why MIOAUTHZ is a good design choice
The routine is small, focused, and predictable. That is exactly what authorization code should be. It does not try to parse tokens. It does not try to route requests. It does not mutate application state. It simply interprets route policy against auth context and either allows or denies.
This separation keeps authorization logic readable in production and easy to test. The large dedicated test routine, MIOAUTHZT, is evidence that the design is stable enough to support many scenario checks without becoming tangled.
Failure path
When MIOAUTHZ denies access, it writes a 403 JSON response through MIOHTTP.RESPJSONX, sets CTX("status")=403, and returns 0. The payload identifies MIOAUTHZ as the routine, returns an error code such as forbidden, and gives a reason such as role_required, claim_mismatch, or not_owner.
Associated authorization routines
Routine	Relation to MIOAUTHZ
MIOAUTH	Authentication policy layer that decides when auth is required and which auth mode applies.
MIOAUTHJWT	JWT verification, claim validation, signature checking, and auth-context population.
MIOSJWT	General JWT helper routine in the wider auth/tooling stack.
MIOSHA256 / MIOSHA256T	HMAC-SHA256 support used by JWT verification.
MIOAUTHZT	Comprehensive authorization and authentication test suite.

MIOAUTH and MIOAUTHJWT
MIOAUTH is the server-facing authentication policy layer. It decides whether authentication applies to a request at all, then delegates to API-key or JWT enforcement. After successful authentication, it hands control to MIOAUTHZ for route-level authorization.
MIOAUTH protection model
Setting	Meaning
protectMode="prefix"	Protect routes by path prefixes. This is useful for simple deployments where all API routes share a common namespace.
protectMode="route"	Protect only routes that explicitly carry route metadata such as authRequired=1. This is cleaner for complex applications because policy lives with the route definition.
mode="api_key"	Require API key authentication.
mode="jwt"	Require JWT authentication.
mode="either"	Allow either API key or JWT to satisfy authentication.

MIOAUTHJWT responsibilities
• Extract the Authorization header and bearer token.
• Validate token structure.
• Decode Base64URL segments.
• Parse header and payload JSON.
• Check claims such as exp, nbf, issuer, and audience.
• Verify signatures for HS256 through MIOSHA256 and preserve RS256 callback support.
• Populate CTX("auth",...) with sub, user, claims, and roles.
How auth and authz fit together
A useful way to remember the layering is this: MIOAUTH answers “who are you and should this request be authenticated at all?”, while MIOAUTHZ answers “given who you are, may you use this route?” That separation is one of the strongest parts of the design.
Routing and Dispatch: MIOROUTE
MIOROUTE is the URL router and dispatcher. It stores raw registrations and metadata, compiles a trie-based representation, matches requests by method and path, extracts params, and executes the dispatch pipeline.
From an architecture point of view, MIOROUTE is the bridge between the parser and the middleware/handler world. MIOHTTP creates REQ. MIOROUTE decides where REQ should go.
Routing model
• Routes are METHOD + PATTERN.
• Static segments beat parameter segments.
• Parameter segments beat wildcard segments.
• Wildcard segments must be last.
• Route metadata is stored alongside the route and is later consumed by auth, authz, and middleware logic.
Key route entry points
Entry point	Purpose
ADD / ADDM	Register HTTP routes, optionally with metadata.
ADDWS / ADDWSM	Register WebSocket routes, optionally with metadata.
COMPILE	Build the compiled trie used for matching.
MATCH / MATCHX	Resolve a method and path to a handler and params.
GETMETA	Load route metadata for downstream policy logic.
DISPATCH	Execute the end-to-end request dispatch sequence.

Middleware and Security: MIOMW
MIOMW provides the standard middleware set that MIOROUTE runs in the pipeline. The routine keeps concerns separate by defining before and after handlers for CORS, security headers, authentication, and access logging.
Default middleware order
Phase	Label	Role
Before 1	CORSB	CORS request handling and preflight support
Before 2	SECB	Security headers, CSP, HSTS, preset handling
Before 3	AUTHB	Authentication entry point
Before 4	LOGB	Request-start logging setup
After 1	CORSA	Restore per-request CORS defaults
After 2	SECA	Restore per-request security defaults
After 3	LOGA	Finalize access logging

This separation is useful because security and CORS behavior can be applied consistently without every handler remembering to manage headers manually. It also means auth is enforced before business logic runs, which is exactly where it belongs.
Worker, Socket, and Connection Management
MIOD and MIOSOCK are the routines that make the rest of the stack possible. They are not glamorous, but they are operationally critical.
MIOD
• Starts the worker daemon and accepts connections.
• Runs the request lifecycle and connection loop.
• Makes keep-alive decisions.
• Identifies WebSocket upgrade requests and hands them to the right path.
MIOSOCK
• Owns the low-level socket device reads and writes.
• Provides READLN and READN helpers used by MIOHTTP.
• Exposes write and close helpers that keep I/O logic out of parser code.
Static files, health, logging, metrics, and rate limiting
Routine	Operational role
MIOSTATIC	Serves static assets with MIME handling, ETag, Range, and If-Modified-Since support.
MIOHEALTH	Provides /health and readiness-style endpoints.
MIOLOG	Structured logging and access log support with redaction discipline.
MIOMET	Metrics collection and Prometheus export.
MIORATE	Per-IP token-bucket rate limiting.

Testing and documentation routines
The web-server stack is unusually well supported by dedicated documentation and test routines. That matters because it lowers maintenance cost and makes refactoring safer.
Routine	Role in maintenance
MIOHTTPDOC	Developer-facing documentation for the HTTP parser and response engine.
MIOROUTEDOC	Developer-facing documentation for the router.
MIOHTTPT / MIOHTTPP1T / MIOHTTPRESPT / MIOHTTPHDT / MIOHTTP1CTT	HTTP parser, header, response, and 100-continue tests.
MIOAUTHZT	Large auth and authz scenario suite.
MIOMWT	Middleware tests.
MIOROUTET	Router tests.
MIOSTATICT / MIOSTATICZTT	Static-file behavior tests.
MIOHEALTHT / MIOLOGT / MIOMETT / MIORATET	Operational support routine tests.

Practical maintenance guidance
If a future maintainer needs to debug the server quickly, the best reading order is: MIOHTTP, MIOROUTE, MIOMW, MIOAUTH, MIOAUTHJWT, MIOAUTHZ, then MIOD. That order mirrors the logical request path and gives the fastest payoff.
• When debugging parse failures, start in MIOHTTP and use STATUS4ERR plus the dedicated HTTP tests.
• When debugging route selection or metadata problems, inspect MIOROUTE registrations and compiled route behavior.
• When debugging 401 responses, start in MIOAUTH and MIOAUTHJWT.
• When debugging 403 responses, start in MIOAUTHZ and route metadata.
• When debugging headers that appear or disappear unexpectedly, inspect MIOMW before blaming handlers.
• When debugging file delivery, focus on MIOSTATIC and then MIOHTTP.SENDFILE.
Summary
The MUMPS.IO web server has a clean separation of concerns. MIOHTTP owns parsing and response writing. MIOROUTE owns route selection and metadata lookup. MIOMW owns standard middleware. MIOAUTH and MIOAUTHJWT authenticate. MIOAUTHZ authorizes. MIOD and MIOSOCK provide the execution shell. Operational routines such as MIOSTATIC, MIOHEALTH, MIOLOG, MIOMET, and MIORATE fill out the platform.
The most important routines to understand are still MIOHTTP and MIOAUTHZ. MIOHTTP is the boundary between raw bytes and structured server state. MIOAUTHZ is the boundary between an authenticated identity and an authorized action. Together, they explain most of how the server behaves under real traffic.