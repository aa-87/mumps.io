MIOMWSTDT ; Standard middleware set tests (CORS/Auth/Logging)
	;
	; Run:
	;   YDB>ZL "MIOHTTP.m","MIOROUTE.m","MIOMW.m","MIOAUTH.m","MIOLOG.m","MIOMET.m","MIOTASSERT.m","MIOMWSTDT.m"
	;   YDB>D ^MIOMWSTDT
	;
	NEW $ET SET $ET="DO STERR^MIOMWSTDT"
	DO T001
	DO T002
	DO T003
	DO T004
	QUIT
	;
STERR
	USE $PRINCIPAL WRITE "ERR ",$ZSTATUS,!
	QUIT
	;
RESET
	KILL ^MIO("ROUTE")
	QUIT
	;
READALL(PATH,OUT)
	NEW OIO SET OIO=$IO
	SET OUT=""
	NEW DEV SET DEV=PATH
	OPEN DEV:(readonly:stream:nowrap)
	USE DEV
	NEW X
	FOR  READ X#16384  QUIT:$ZEOF  SET OUT=OUT_X
	CLOSE DEV
	USE OIO
	QUIT
	;
T001 ; CORS preflight (OPTIONS) handled by middleware (204, no handler)
	DO RESET
	DO ADD^MIOROUTE("OPTIONS","/cors","H200^MIOMWSTDT")
	DO COMPILE^MIOROUTE
	NEW CONF,REQ,CTX,DEV,OUT,OP
	KILL CONF,REQ,CTX
	DO STDWIRE^MIOMW(.CONF)
	SET CONF("server","cors","enabled")=1
	SET REQ("method")="OPTIONS"
	SET REQ("path")="/cors"
	SET REQ("hdr","origin")="https://example.test"
	SET REQ("hdr","access-control-request-method")="GET"
	SET CTX("request_id")="mwstd001"
	SET OP="tmp/mio_mwstd_t001.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV
	USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["204":1,1:0),1,"[T001][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["Access-Control-Allow-Origin":1,1:0),1,"[T001][cors hdr]")
	DO EQ^MIOTASSERT($SELECT(OUT["Access-Control-Allow-Methods":1,1:0),1,"[T001][allow methods]")
	DO EQ^MIOTASSERT($SELECT($GET(CTX("mw_hit"))="":1,1:0),1,"[T001][handler skipped]")
	QUIT
	;
T002 ; CORS simple request adds headers to normal response
	DO RESET
	DO ADD^MIOROUTE("GET","/cors","H200^MIOMWSTDT")
	DO COMPILE^MIOROUTE
	NEW CONF,REQ,CTX,DEV,OUT,OP
	KILL CONF,REQ,CTX
	DO STDWIRE^MIOMW(.CONF)
	SET CONF("server","cors","enabled")=1
	SET REQ("method")="GET"
	SET REQ("path")="/cors"
	SET REQ("hdr","origin")="https://example.test"
	SET CTX("request_id")="mwstd002"
	SET OP="tmp/mio_mwstd_t002.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV
	USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T002][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["Access-Control-Allow-Origin: *":1,1:0),1,"[T002][allow origin]")
	DO EQ^MIOTASSERT($SELECT($GET(CTX("mw_hit"))="h":1,1:0),1,"[T002][handler ran]")
	QUIT
	;
T003 ; Auth middleware denies protected route without api key
	DO RESET
	DO ADD^MIOROUTE("GET","/api/secret","H200^MIOMWSTDT")
	DO COMPILE^MIOROUTE
	NEW CONF,REQ,CTX,DEV,OUT,OP
	KILL CONF,REQ,CTX
	DO STDWIRE^MIOMW(.CONF)
	; Default MIOAUTH protection includes /api/
	SET CONF("auth","mode")="api_key"
	SET CONF("auth","apiKey","value")="secret"
	SET REQ("method")="GET"
	SET REQ("path")="/api/secret"
	SET CTX("request_id")="mwstd003"
	SET OP="tmp/mio_mwstd_t003.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV
	USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[T003][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["api_key_missing":1,1:0),1,"[T003][reason]")
	DO EQ^MIOTASSERT($SELECT($GET(CTX("mw_hit"))="":1,1:0),1,"[T003][handler skipped]")
	QUIT
	;
T004 ; Logging middleware writes one access log line (json format)
	DO RESET
	DO ACLEAR^MIOLOG
	DO ADD^MIOROUTE("GET","/log","H200^MIOMWSTDT")
	DO COMPILE^MIOROUTE
	NEW CONF,REQ,CTX,DEV,OP,LOGTXT,LINE,SEQ
	KILL CONF,REQ,CTX
	DO STDWIRE^MIOMW(.CONF)
	SET CONF("server","log","access","enabled")=1
	SET CONF("server","log","access","format")="json"
	; Global sink: access lines are written to ^MIO("LOG","ACCESS",...) deterministically.
	SET CONF("server","log","access","maxEntries")=200
	SET CTX("t0us")=$$TSUS^MIOMET()
	SET REQ("method")="GET"
	SET REQ("path")="/log"
	SET CTX("request_id")="mwstd004"
	SET OP="tmp/mio_mwstd_t004.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV
	USE $PRINCIPAL
	; Access log ring should contain a JSON record with request_id
	DO ALAST^MIOLOG(.LINE,.SEQ)
	SET LOGTXT=LINE
	DO EQ^MIOTASSERT($SELECT(LOGTXT["mwstd004":1,1:0),1,"[T004][log contains request_id]")
	QUIT
	;
	; ---- handler fixture ----
H200(DEV,CONF,REQ,CTX)
	SET CTX("mw_hit")="h"
	NEW OBJ
	SET OBJ("ok")=1
	SET OBJ("routine")="MIOMWSTDT"
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
