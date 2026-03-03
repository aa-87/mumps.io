MIOHTTPDOC ; Documentation for MIOHTTP (HTTP parsing + streaming bodies)
 ;
 ; MUMPS.IO - Professional module documentation (developer-facing)
 ;
 ; How to view:
 ;   YDB>D SHOW^MIOHTTPDOC
 ;
 ; Notes
 ; - This routine contains documentation only.
 ; - It does not modify globals.
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
;;- Parse the HTTP request line and headers.
;;- Parse query parameters from the request target.
;;- Read the request body safely for large payloads.
;;- Avoid MAXSTRING by streaming into globals when needed.
;;
;;Primary entry points
;;- PARSE(DEV,.CONF,.REQ,.ERR) -> 1 success, 0 failure
;;  - Reads request line, headers, and body.
;;  - Populates REQ() and ERR().
;;- BODYOPEN(.REQ,.CUR)
;;- $$BODYNEXT(.REQ,.CUR,.CH) -> 1 (chunk returned), 0 (done)
;;- $$BODYLEN(.REQ) -> integer byte count
;;- BODYFREE(.REQ) -> frees any ^TMP body storage and clears REQ("body"...)
;;- $$STATUS4ERR(.ERR) -> HTTP status code for an error
;;- RESP / RESPJSON / RESPX / RESPJSONX -> response helpers used by MIOD
;;
;;Expect: 100-continue (ROI helpers; does not change PARSE behavior)
;;- PARSEHDRS(DEV,.CONF,.REQ,.ERR) -> 1/0
;;  - Reads only request line + headers.
;;  - Does not read the body.
;;- $$EXPECTDECIDE(.CONF,.REQ,.ERR) -> 1 continue, 0 reject
;;  - If Expect: 100-continue is present and Content-Length is too large, reject early.
;;- SEND100(DEV,.REQ,.ERR)
;;  - Writes: HTTP/1.1 100 Continue
;;  - Best-effort. It traps write errors.
;;- $$READBODY(DEV,.CONF,.REQ,.ERR) -> 1/0
;;  - Reads only the request body using the same rules as PARSE().
;;
;;Server-side flow (recommended)
;;- Read headers first.
;;- Decide if you accept the body.
;;- Send 100 Continue only when you accept the body.
;;- Then read the body.
;;
;;Example flow
;;- SET ok=$$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
;;- IF 'ok DO RESPJSONX^MIOHTTP(.DEV,.CONF,$$STATUS4ERR^MIOHTTP(.ERR),.ERR,REQ("id"),.CTX) QUIT
;;- SET ok=$$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR)
;;- IF 'ok DO RESPJSONX^MIOHTTP(.DEV,.CONF,$$STATUS4ERR^MIOHTTP(.ERR),.ERR,REQ("id"),.CTX) QUIT
;;- IF $$LOW^MIOHTTP($GET(REQ("hdr","expect")))""""["100-continue" DO SEND100^MIOHTTP(DEV,.REQ,.ERR)
;;- SET ok=$$READBODY^MIOHTTP(DEV,.CONF,.REQ,.ERR)
;;- IF 'ok DO RESPJSONX^MIOHTTP(.DEV,.CONF,$$STATUS4ERR^MIOHTTP(.ERR),.ERR,REQ("id"),.CTX) QUIT
;;
;;Data model
;;
;;REQ() outputs (core)
;;- REQ("method") = "GET" / "POST" / ...
;;- REQ("rawpath") = raw request target path (no host)
;;- REQ("path")    = normalized path (query removed)
;;- REQ("httpver") = "HTTP/1.1"
;;- REQ("query",key)=value (URL-decoded; '+' becomes space)
;;- REQ("hdr",lowerHeaderName)=value
;;
;;Body storage
;;
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
;;- ^TMP(...,1)=chunk1, ^TMP(...,2)=chunk2, ...
;;
;;IMPORTANT
;;- In global mode, there is no scalar value at REQ("body").
;;- This prevents accidental MAXSTRING concatenation.
;;
;;Streaming consumption (recommended)
;;- DO BODYOPEN^MIOHTTP(.REQ,.CUR)
;;- FOR  QUIT:'$$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH)  DO
;;    ; process CH
;;
;;Body framing rules
;;- Transfer-Encoding takes precedence over Content-Length.
;;- Supported Transfer-Encoding tokens:
;;  - chunked
;;  - identity
;;- Any other token is rejected with unsupported_transfer_encoding.
;;
;;Chunked bodies (request bodies)
;;- Chunk size supports 1+ hex digits.
;;- Chunk extensions after ';' are ignored.
;;- Chunk data is read as a fixed-length block.
;;- Chunk terminator is consumed as a line ending.
;;- Trailers after the 0-size chunk are consumed until a blank line.
;;
;;Configuration (CONF)
;;
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
;;  - Controls syscall count vs memory churn.
;;  - 8 KB to 64 KB is usually a good range.
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
;;- Prefer streaming via BODYOPEN/BODYNEXT for large payloads.
;;- Keep maxBodyScalarBytes conservative to reduce MAXSTRING risk.
;;- Always call BODYFREE after handling a request.
;;
;;Security notes
;;- Limits are enforced early (request line, headers, body bytes).
;;- Transfer-Encoding is whitelisted.
;;- Do not log raw bodies by default.
;;
;;------------------------------------------------------------------------
;;MIOHTTPMPU — multipart/form-data streaming parser (ROI)
;;
;;Purpose
;;- Parse multipart/form-data and multipart/* bodies from REQ("body",...).
;;- Keep it MAXSTRING-safe and stream-friendly.
;;- Support very large file parts (spool to disk).
;;
;;Primary entry points
;;- $$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR) -> 1 success, 0 failure
;;- FREE^MIOHTTPMPU(.MP) -> frees globals and (optionally) spool files
;;
;;Part access
;;- Part metadata is stored under MP("part",i,...).
;;- Iterate part data with:
;;  - PARTOPEN^MIOHTTPMPU(.MP,i,.CUR,.CONF)
;;  - $$PARTNEXT^MIOHTTPMPU(.MP,i,.CUR,.CH)
;;  - $$PARTSLURP^MIOHTTPMPU(.MP,i,.CONF) (small parts only)
;;
;;Fields
;;- Non-file fields can be published into:
;;  - MP("field",name)=value
;;
;;Part storage modes
;;- scalar
;;  - MP("part",i,"data") contains full content
;;- global
;;  - MP("part",i,"ref") points to ^TMP($J,"MIOHTTPMPU","PART",...)
;;- spool (ROI)
;;  - MP("part",i,"path") points to a file on disk
;;- zref (ROI, zero-copy file parts)
;;  - MP("part",i,"zref")=<REQ body global ref>
;;  - MP("part",i,"zstart"), MP("part",i,"zend") offsets
;;
;;Disk spooling (ROI)
;;- Enable with:
;;  - CONF("server","multipart","maxMultipartSpoolBytes")
;;  - CONF("server","multipart","spoolDir")
;;- When a file part exceeds maxMultipartSpoolBytes, it upgrades to mode=spool.
;;
;;Zero-copy file parts (ROI)
;;- Enable with:
;;  - CONF("server","multipart","zeroCopyFileParts")=1
;;- Requires request body mode=global.
;;- The file part becomes mode=zref (no copying into MP globals).
;;
;;Per-part Content-Type allowlist (ROI)
;;- Enable with either:
;;  - CONF("server","multipart","allowTypes")="text/plain,image/*"
;;  - CONF("server","multipart","allow","text/plain")=1
;;- On violation:
;;  - ERR("error")="disallowed_content_type"
;;
;;Nested multipart/mixed (ROI)
;;- Enable with:
;;  - CONF("server","multipart","enableNested")=1
;;  - CONF("server","multipart","maxDepth")=3 (default)
;;- Nested results are stored under:
;;  - MP("part",i,"sub",...)
;;
;;Recommended usage (multipart route handler)
;;- Parse HTTP request with MIOHTTP (headers + body).
;;- If Content-Type is multipart/*, call MIOHTTPMPU PARSE.
;;- Stream file parts using PARTOPEN/PARTNEXT.
;;- Call FREE when done.
;;
;;Testing
;;- ^MIOHTTPT covers HTTP parsing and body streaming.
;;- ^MIOHTTPMPUTT covers multipart parsing and ROI features.
;;- ^MIOHTTP1CTT covers Expect: 100-continue helpers.
;;
;;User-facing quick notes (short sentences)
;;- Use PARSE to read the request.
;;- Use BODYOPEN/BODYNEXT to stream the body.
;;- Use MIOHTTPMPU PARSE for multipart forms.
;;- Large files can spool to disk.
;;- Always call BODYFREE and FREE.
;;
;;------------------------------------------------------------------------
;;Response streaming + sendfile (ROI)
;;
;;Purpose
;;- Stream large responses safely.
;;- Avoid MAXSTRING.
;;- Send files without loading into memory.
;;
;;APIs in MIOHTTP
;;- STREAMBEGIN(DEV,.CONF,STATUS,.HEAD,REQID,.CTX)
;;  - Starts a chunked response.
;;- STREAMWRITE(DEV,DATA)
;;  - Writes one chunk.
;;- STREAMEND(DEV)
;;  - Ends the response.
;;- $$SENDFILE(DEV,.CONF,PATH,.HEAD,REQID,.CTX,METHOD)
;;  - Streams a file.
;;  - For HEAD, it sends headers only.
;;
;;Static files (MIOSTATIC)
;;- Serves GET/HEAD /static/*path.
;;- Prevents path traversal.
;;- Uses SENDFILE for streaming.
;;
;;Config
;;- CONF("server","static","enabled")=1
;;- CONF("server","static","root")="public"
;;- CONF("server","static","mount")="/static"
;;- CONF("server","static","readChunkBytes")=65536
;;
;;Security
;;- Rejects '.' and '..' segments.
;;- Adds X-Content-Type-Options: nosniff.
;;
;;Tests
;;- ^MIOHTTPRESPT tests streaming and sendfile.
;;- ^MIOSTATICT tests the static handler.

;;End.
;;
;;
;;Static file caching (ROI)
;;
;;ETag and If-None-Match
;;- MIOSTATIC can emit an ETag for small files.
;;- If the request includes If-None-Match and it matches the ETag, the server returns 304.
;;- 304 responses have no body.
;;
;;Config
;;- CONF("server","static","maxEtagBytes") default 2097152 (2 MB)
;;- CONF("server","static","etagCacheSeconds") default 30
;;- CONF("server","static","etagChunkBytes") default 65536
;;
;;Cache
;;- Stored under ^MIO("STATIC","META",fullPath)
;;- Contains META("etag") and META("ts")
;;
;;Notes
;;- Large files omit ETag to avoid extra I/O.
;;- Use sendfile streaming for large file delivery.
;;
;;
;;------------------------------------------------------------------------
;;Static Range Requests (ROI)
;;
;;MIOSTATIC now supports single Range: bytes=... requests.
;;It returns 206 Partial Content.
;;It sets Content-Range and Content-Length.
;;It sets Accept-Ranges: bytes.
;;
;;Supported forms
;;- Range: bytes=START-END
;;- Range: bytes=START-
;;- Range: bytes=-SUFFIX
;;
;;Unsupported
;;- Multiple ranges in one header.
;;  The server returns 416.
;;
;;Invalid range response
;;- Status: 416 Range Not Satisfiable
;;- Header: Content-Range: bytes */<size>
;;
;;HEAD
;;- Returns headers only (no body).
;;
;;Config
;;- CONF("server","static","readChunkBytes") controls streaming chunk size.
;;- File size is computed on demand and cached briefly in ^MIO("STATIC","META",path).
;;

;;
;;Static Range Requests (ROI)
;;Implementation note:
;;- MIOHTTP RESP/RESPX always sets Content-Length from BODY.
;;- For 206 responses, MIOSTATIC writes headers with RESPHEAD and streams bytes.
;;
;;Range support:
;;- Single-range only.
;;- bytes=START-END, bytes=START-, bytes=-SUFFIX
;;- 206: Content-Range, Content-Length, Accept-Ranges: bytes
;;- 416: Content-Range: bytes */<size>
;;
;;
;;------------------------------------------------------------------------
;;Static Last-Modified / If-Modified-Since (ROI)
;;
;;MIOSTATIC can emit Last-Modified when file mtime is available.
;;It can return 304 Not Modified for If-Modified-Since.
;;
;;Pragmatic mtime strategy
;;- Primary: server-known mtime stored under ^MIO("STATIC","META",path,"mhd"/"mhs").
;;- Optional: CONF("server","static","mtimeProvider")="LABEL^ROUTINE".
;;  The provider must return $H day and seconds in .MHD/.MHS and optionally .LM string.
;;- If no mtime is available, Last-Modified is omitted and If-Modified-Since is ignored.
;;
;;Public helper
;;- DO SETMTIME^MIOSTATIC(fullPath,horologDay,horologSeconds)
;;  This is useful for watchers or build pipelines.
;;
;;Precedence
;;- If-None-Match (ETag) is evaluated first.
;;- If-Modified-Since is evaluated only when mtime is available.
;;
;;Responses
;;- 304 includes no body.
;;Access logs + timing metrics (ROI #1)
;;- Implemented in MIOLOG (access logging queue + rotation) and integrated in MIOD.
;;- Enable:
;;  CONF("server","log","access","enabled")=1
;;- Optional buffering (recommended for performance):
;;  CONF("server","log","access","buffer")=1
;;  CONF("server","log","access","flushEvery")=50
;;  CONF("server","log","access","flushBytes")=65536
;;- Formats:
;;  common | combined | json
;;- Metrics included per request:
;;  parse_ms, handler_ms, total_ms
;;  bytes_in (REQ("body","len")), bytes_out (response byte accounting in MIOHTTP)
;;

;;
