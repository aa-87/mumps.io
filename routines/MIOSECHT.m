MIOSECHT ; Security headers presets + CSP tests (middleware)
	;
	; Run:
	;   YDB>ZL "MIOHTTP.m","MIOROUTE.m","MIOMW.m","MIOTASSERT.m","MIOSECHT.m"
	;   YDB>D ^MIOSECHT
	;
	NEW $ET SET $ET="DO STERR^MIOSECHT"
	DO T001
	DO T002
	DO T003
	DO T004
	DO T005
	DO T006
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
T001 ; balanced default adds safe headers, CSP disabled by default
	DO RESET
	DO ADD^MIOROUTE("GET","/sec/bal","H200^MIOSECHT")
	DO COMPILE^MIOROUTE
	NEW CONF,REQ,CTX,DEV,OUT,OP
	KILL CONF,REQ,CTX
	DO STDWIRE^MIOMW(.CONF)
	; security enabled by default; preset defaults to balanced
	SET REQ("method")="GET"
	SET REQ("path")="/sec/bal"
	SET CTX("request_id")="sec001"
	SET OP="tmp/mio_sec_t001.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T001][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["X-Content-Type-Options: nosniff":1,1:0),1,"[T001][nosniff]")
	DO EQ^MIOTASSERT($SELECT(OUT["X-Frame-Options: SAMEORIGIN":1,1:0),1,"[T001][xfo]")
	DO EQ^MIOTASSERT($SELECT(OUT["Referrer-Policy: strict-origin-when-cross-origin":1,1:0),1,"[T001][refpol]")
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Security-Policy:":1,1:0),0,"[T001][no csp]")
	QUIT
	;
T002 ; strict per-route preset override
	DO RESET
	NEW META
	SET META("sec_preset")="strict"
	DO ADDM^MIOROUTE("GET","/sec/strict","H200^MIOSECHT",.META)
	DO COMPILE^MIOROUTE
	NEW CONF,REQ,CTX,DEV,OUT,OP
	KILL CONF,REQ,CTX
	DO STDWIRE^MIOMW(.CONF)
	SET REQ("method")="GET"
	SET REQ("path")="/sec/strict"
	SET CTX("request_id")="sec002"
	SET OP="tmp/mio_sec_t002.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T002][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["X-Frame-Options: DENY":1,1:0),1,"[T002][xfo deny]")
	DO EQ^MIOTASSERT($SELECT(OUT["Cross-Origin-Opener-Policy: same-origin":1,1:0),1,"[T002][coop]")
	DO EQ^MIOTASSERT($SELECT(OUT["Cross-Origin-Resource-Policy: same-origin":1,1:0),1,"[T002][corp]")
	QUIT
	;
T003 ; CSP enabled + per-route append
	DO RESET
	NEW META
	SET META("csp")="img-src https: data:"
	SET META("csp_mode")="append"
	DO ADDM^MIOROUTE("GET","/sec/csp","H200^MIOSECHT",.META)
	DO COMPILE^MIOROUTE
	NEW CONF,REQ,CTX,DEV,OUT,OP
	KILL CONF,REQ,CTX
	DO STDWIRE^MIOMW(.CONF)
	SET CONF("server","security","csp","enabled")=1
	SET REQ("method")="GET"
	SET REQ("path")="/sec/csp"
	SET CTX("request_id")="sec003"
	SET OP="tmp/mio_sec_t003.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Security-Policy:":1,1:0),1,"[T003][csp present]")
	DO EQ^MIOTASSERT($SELECT(OUT["default-src 'self'":1,1:0),1,"[T003][base]")
	DO EQ^MIOTASSERT($SELECT(OUT["img-src https: data:":1,1:0),1,"[T003][append]")
	QUIT
	;
T004 ; CSP report-only + per-route replace (no base policy)
	DO RESET
	NEW META
	SET META("csp")="default-src 'none'"
	SET META("csp_mode")="replace"
	DO ADDM^MIOROUTE("GET","/sec/cspr","H200^MIOSECHT",.META)
	DO COMPILE^MIOROUTE
	NEW CONF,REQ,CTX,DEV,OUT,OP
	KILL CONF,REQ,CTX
	DO STDWIRE^MIOMW(.CONF)
	SET CONF("server","security","csp","enabled")=1
	SET CONF("server","security","csp","reportOnly")=1
	SET REQ("method")="GET"
	SET REQ("path")="/sec/cspr"
	SET CTX("request_id")="sec004"
	SET OP="tmp/mio_sec_t004.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Security-Policy-Report-Only:":1,1:0),1,"[T004][csp ro present]")
	DO EQ^MIOTASSERT($SELECT(OUT["default-src 'none'":1,1:0),1,"[T004][replace]")
	DO EQ^MIOTASSERT($SELECT(OUT["default-src 'self'":1,1:0),0,"[T004][no base]")
	QUIT

T005 ; CSP nonce enabled (fixed) injects nonce into policy + exposes CTX("csp_nonce")
	DO RESET
	DO ADD^MIOROUTE("GET","/sec/cspn","H200^MIOSECHT")
	DO COMPILE^MIOROUTE
	NEW CONF,REQ,CTX,DEV,OUT,OP
	KILL CONF,REQ,CTX
	DO STDWIRE^MIOMW(.CONF)
	SET CONF("server","security","csp","enabled")=1
	SET CONF("server","security","csp","nonce","enabled")=1
	SET CONF("server","security","csp","nonce","fixed")="abc123"
	SET CONF("server","security","csp","nonce","directives")="script-src"
	SET REQ("method")="GET"
	SET REQ("path")="/sec/cspn"
	SET CTX("request_id")="sec005"
	SET OP="tmp/mio_sec_t005.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Security-Policy:":1,1:0),1,"[T005][csp present]")
	DO EQ^MIOTASSERT($SELECT(OUT["nonce-abc123":1,1:0),1,"[T005][nonce token]")
	DO EQ^MIOTASSERT($SELECT($GET(CTX("csp_nonce"))="abc123":1,1:0),1,"[T005][ctx nonce]")
	QUIT
	;
T006 ; Per-route csp_nonce=0 disables nonce even when globally enabled
	DO RESET
	NEW META
	SET META("csp_nonce")=0
	DO ADDM^MIOROUTE("GET","/sec/cspno","H200^MIOSECHT",.META)
	DO COMPILE^MIOROUTE
	NEW CONF,REQ,CTX,DEV,OUT,OP
	KILL CONF,REQ,CTX
	DO STDWIRE^MIOMW(.CONF)
	SET CONF("server","security","csp","enabled")=1
	SET CONF("server","security","csp","nonce","enabled")=1
	SET CONF("server","security","csp","nonce","fixed")="abc123"
	SET REQ("method")="GET"
	SET REQ("path")="/sec/cspno"
	SET CTX("request_id")="sec006"
	SET OP="tmp/mio_sec_t006.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Security-Policy:":1,1:0),1,"[T006][csp present]")
	DO EQ^MIOTASSERT($SELECT(OUT["nonce-abc123":1,1:0),0,"[T006][no nonce]")
	DO EQ^MIOTASSERT($SELECT($GET(CTX("csp_nonce"))="":1,1:0),1,"[T006][no ctx nonce]")
	QUIT
	;
	;
	; ---- handler fixture ----
H200(DEV,CONF,REQ,CTX)
	NEW HEAD,BODY
	SET HEAD("Content-Type")="text/plain; charset=utf-8"
	SET BODY="ok"
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,BODY,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
