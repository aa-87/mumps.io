MIOHTTPDOC ; Documentation for MIOHTTP (HTTP parsing + streaming bodies)
	;
	; MUMPS.IO - Professional module documentation (developer-facing)
	;
	; How to view:
	;   YDB>D SHOW^MIOHTTPDOC
	;
	; Notes
	; - This routine contains documentation only.;
	; - It does not modify globals.;
	;
	Q
	;
SHOW ;
	NEW I,LINE
	FOR I=1:1 DO  QUIT:LINE=""
	. SET LINE=$P($T(DOC+I),";;",2,999)
	. QUIT:LINE=""
	. W LINE,!
	QUIT
	;
GET(OUT) ;
	; Return documentation as OUT(n)=line
	KILL OUT
	NEW I,LINE,N SET N=0
	FOR I=1:1 DO  QUIT:LINE=""
	. SET LINE=$P($T(DOC+I),";;",2,999)
	. QUIT:LINE=""
	. SET N=N+1,OUT(N)=LINE
	QUIT
	;
DOC ;;
;;MIOHTTP — HTTP parsing + streaming request bodies (MAXSTRING-safe)
;; 
;;Purpose
;;- Parse the HTTP request line and headers.;
;;- Parse query parameters from the request target.;
;;- Read the request body safely for large payloads.;
;;- Avoid MAXSTRING by streaming into globals when needed.;
;; 
;;Primary entry points
;;- PARSE(DEV,.CONF,.REQ,.ERR) -> 1 success, 0 failure
;;  - Reads request line, headers, and body.;
;;  - Populates REQ() and ERR().;
;;- BODYOPEN(.REQ,.CUR)
;;- $$BODYNEXT(.REQ,.CUR,.CH) -> 1 (chunk returned), 0 (done)
;;- $$BODYLEN(.REQ) -> integer byte count
;;- BODYFREE(.REQ) -> frees any ^TMP body storage and clears REQ("body"...)
;;- $$STATUS4ERR(.ERR) -> HTTP status code for an error
;;- RESP / RESPJSON / RESPX / RESPJSONX -> response helpers used by MIOD
;; 
;;Data model
;; 
;;REQ() inputs (caller-provided)
;;- REQ("id") (optional)
;;  - If provided, used to name the ^TMP body store for global-mode bodies.;
;; 
;;REQ() outputs (core)
;;- REQ("method") = "GET" / "POST" / ...;
;;- REQ("rawpath") = raw request target path (no host)
;;- REQ("path")    = normalized path (query removed)
;;- REQ("httpver") = "HTTP/1.1"
;;- REQ("query",key)=value (URL-decoded; '+' becomes space)
;;- REQ("hdr",lowerHeaderName)=value
;; 
;;Body storage
;;Scalar mode (small bodies)
;;- REQ("body") = string
;;- REQ("body","mode")="scalar"
;;- REQ("body","len")=N
;; 
;;Global mode (large bodies, or forced by limits)
;;- REQ("body","mode")="global"
;;- REQ("body","ref")=$NAME(^TMP($J,"MIOHTTP","BODY",REQID))
;;- REQ("body","n")=chunkCount
;;- REQ("body","len")=N
;;- ^TMP(...,1)=chunk1, ^TMP(...,2)=chunk2, ...;
;; 
;;IMPORTANT
;;- In global mode, there is no scalar value at REQ("body").;
;;  - This prevents accidental MAXSTRING concatenation.;
;; 
;;Streaming consumption (recommended)
;;- DO BODYOPEN^MIOHTTP(.REQ,.CUR)
;;- FOR  QUIT:'$$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH)  DO
;;    ; process CH
;; 
;;Body framing rules
;;- Transfer-Encoding takes precedence over Content-Length.;
;;- Supported Transfer-Encoding tokens:
;;  - chunked
;;  - identity
;;- Any other token (gzip/deflate/etc.) is rejected with unsupported_transfer_encoding.;
;; 
;;Chunked bodies
;;- Chunk size supports 1+ hex digits.;
;;- Chunk extensions after ';' are ignored.;
;;- Chunk data is read as a fixed-length block.;
;;- Chunk terminator is consumed via line-read (expects an empty line under CRLF delim).;
;;- Trailers after the 0-size chunk are consumed until a blank line.;
;; 
;;Configuration (CONF)
;;Timeouts
;;- CONF("server","timeouts","readHeaderMs")  default 2
;;- CONF("server","timeouts","readBodyMs")    default 3
;; 
;;Limits
;;- CONF("server","limits","maxRequestLineBytes")  default 8192
;;- CONF("server","limits","maxHeaderLineBytes")   default 8192
;;- CONF("server","limits","maxHeaderBytes")       default 65536
;;- CONF("server","limits","maxHeaderCount")       default 80
;;- CONF("server","limits","maxBodyBytes")         default 10485760 (10 MB)
;;- CONF("server","limits","maxBodyScalarBytes")   default 262144   (256 KB)
;; 
;;Body read window
;;- CONF("server","http","readBodyChunkBytes")
;;  - If set, READLEN reads in windows of this size.;
;;  - If unset, READLEN selects a safe window (up to 256 KB).;
;; 
;;Feature flags
;;- CONF("server","http","supportChunkedRequest") default 1
;; 
;;Error contract (ERR)
;;- ERR("routine")="MIOHTTP"
;;- ERR("error")=<code>
;;- ERR("status") can be derived via $$STATUS4ERR(.ERR)
;; 
;;Common error codes
;;- client_closed
;;- read_timeout
;;- request_line_too_large
;;- bad_request_line
;;- header_line_too_large
;;- headers_too_large
;;- too_many_headers
;;- header_folding_rejected
;;- invalid_content_length
;;- payload_too_large
;;- unsupported_transfer_encoding
;;- chunked_not_supported
;;- bad_chunk_size
;;- bad_chunk_ending
;;- short_read
;; 
;;Performance notes
;;- Prefer streaming via BODYOPEN/BODYNEXT for large payloads.;
;;- Keep maxBodyScalarBytes conservative to reduce MAXSTRING risk.;
;;- readBodyChunkBytes controls read() syscall count vs memory churn.;
;;  - 8 KB to 64 KB is usually a good range.;
;;- BODYFREE must be called after request handling to avoid ^TMP growth.;
;; 
;;Security notes
;;- Limits are enforced early (request line, header bytes, body bytes).;
;;- Transfer-Encoding is whitelisted to prevent unexpected decompression attacks.;
;;- Do not log raw bodies by default.;
;; 
;;Example: parse + stream body
;;- SET ok=$$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR)
;;- IF 'ok DO RESPJSONX^MIOHTTP(.DEV,.CONF,$$STATUS4ERR^MIOHTTP(.ERR),.ERR,REQ("id"),.CTX) QUIT
;;- DO BODYOPEN^MIOHTTP(.REQ,.CUR)
;;- FOR  QUIT:'$$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH)  DO
;;    ; process CH
;;- DO BODYFREE^MIOHTTP(.REQ)
;; 
;;End.;
;;