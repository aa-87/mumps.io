MIOROUTEDOC ; MIOROUTE developer documentation (detailed).;
;
; This routine is documentation only.;
; It contains no production logic.;
;
; You can view it by running:
;   YDB>D SHOW^MIOROUTEDOC
;
; ------------------------------------------------------------------------------
	;
SHOW ;
	NEW I,LINE
	FOR I=1:1 DO  QUIT:LINE="***END***"
	. SET LINE=$P($T(DOC+I),";;",2,999)
	. IF LINE="***END***" QUIT
	. WRITE LINE,!
	QUIT
	;
DOC ;;
;;MIOROUTE - Developer Guide
;;
;;Goal
;;- Provide a production router for the MIO web server.;
;;- Match common router semantics from trie/radix routers.;
;;- Keep routing fast and safe.;
;;
;;Concepts
;;- A route is METHOD + PATTERN.;
;;- PATTERN uses path segments.;
;;- Static segments match exactly.;
;;- A param segment starts with ':' (example: /users/:id).;
;;- A wildcard segment starts with '*' (example: /static/*path).;
;;- Wildcard must be the last segment.;
;;
;;Precedence
;;- Static beats param.;
;;- Param beats wildcard.;
;;- This avoids ambiguity.;
;;
;;Data in globals
;;1) Raw registrations
;;- ^MIO("ROUTE","RAW",METHOD,PATTERN)=HANDLER
;;- HANDLER is "TAG^ROUTINE".;
;;
;;2) Route metadata
;;- ^MIO("ROUTE","META",METHOD,PATTERN,KEY)=VALUE
;;- Use this for auth/authz decisions.;
;;
;;3) Compiled trie
;;- ^MIO("ROUTE","UTRIE",...) is the unified trie.;
;;- It is shared by all methods.;
;;- Leaves store handlers per method:
;;  - $HANDLER(METHOD)=HANDLER
;;  - $ROUTE(METHOD)=original PATTERN
;;
;;4) Last compile report
;;- ^MIO("ROUTE","COMPILE","ok") = 1|0
;;- ^MIO("ROUTE","COMPILE","err",n,...) = error records
;;- Each error record includes:
;;  - routine = "MIOROUTE"
;;  - type, method, path, info
;;
;;Configuration
;;All keys are optional.;
;;Defaults preserve older behavior.;
;;
;;- ignoreTrailingSlash (default 1)
;;  - If 1, /a and /a/ match the same route.;
;;  - If 0, /a and /a/ can be different routes.;
;;
;;- plusAsSpaceInPath (default 1)
;;  - If 1, '+' in the PATH decodes to a space.;
;;  - If 0, '+' stays '+'.;
;;  - Query decoding remains unchanged (handled elsewhere).;
;;
;;- collapseSlashes (default 0)
;;  - If 1, repeated slashes collapse to one slash in normalization.;
;;  - Matching also skips empty segments, so // is tolerated.;
;;
;;Public APIs
;;- INIT
;;  - Clears ^MIO("ROUTE") and registers core routes.;
;;
;;- ADD / ADDM
;;  - Registers a route into RAW.;
;;  - ADDM also stores metadata.;
;;
;;- ADDWS / ADDWSM
;;  - Same as ADD/ADDM but with METHOD="WS".;
;;  - Used for Upgrade requests.;
;;
;;- COMPILE / COMPILEX
;;  - Builds ^MIO("ROUTE","UTRIE") from RAW.;
;;  - Validates patterns.;
;;  - Stores a compile report.;
;;
;;- NORM
;;  - Normalizes a path or a pattern using config policies.;
;;
;;- MATCH
;;  - Method-aware match.;
;;  - Returns 1 only if METHOD has a handler.;
;;  - Returns handler and matched pattern.;
;;  - Returns params in PARAMS().;
;;
;;- MATCHA
;;  - Same as MATCH.;
;;  - Also returns ALLOW(method)=1 when other methods match the path.;
;;  - ALLOW excludes method "WS".;
;;
;;- PREMATCH
;;  - Runs MATCHA for the incoming request.;
;;  - Stores results in CTX("match",...).;
;;  - Stores CTX("match","allow",method)=1 on method mismatch.;
;;
;;- GETMETA
;;  - Reads route metadata for a matched pattern.;
;;
;;- DISPATCH
;;  - Uses PREMATCH result if present.;
;;  - Otherwise runs MATCHA.;
;;  - On 404, returns JSON with rtn="MIOROUTE".;
;;  - On 405, returns JSON with rtn="MIOROUTE" and Allow header.;
;;  - Validates handler format before calling it.;
;;
;;Error types (compile)
;;- empty_handler
;;- invalid_param
;;- param_conflict
;;- wildcard_not_last
;;- wildcard_param_conflict
;;- duplicate_route
;;
;;Performance notes
;;- Unified trie means one traversal for routing and Allow discovery.;
;;- SPLITPATH does a single pass split.;
;;- Policies are read once per match.;
;;- Static segments in patterns are percent-decoded at compile time.;
;;
;;Security notes
;;- Router never executes data as code.;
;;- Handler strings must be controlled by server code.;
;;- Route params are decoded. Treat them as untrusted input.;
;;
;;***END***
;