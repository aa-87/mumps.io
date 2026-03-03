MIOHEALTHT ; Health + readiness endpoint tests (ROI #5)
;
; Run:
;   YDB>ZL "MIOHTTP.m","MIOROUTE.m","MIOHEALTH.m","MIOHEALTHT.m","MIOTASSERT.m","MIOUTIL.m"
;   YDB>D ^MIOHEALTHT
;
; Output:
;   Prints only FAIL lines. No output means pass.;
;
	DO T001
	DO T002
	DO T003
	DO T004
	QUIT
	;
RESET
	KILL ^MIO("ROUTE")
	KILL ^MIO("CONF","server","routing")
	QUIT
	;
READALL(PATH,OUT)
	NEW OIO SET OIO=$IO
	SET OUT=""
	NEW DEV SET DEV=PATH
	OPEN DEV:(readonly:stream:nowrap):1 ELSE  QUIT
	USE DEV
	NEW X
	FOR  READ X#16384  QUIT:$ZEOF  SET OUT=OUT_X
	CLOSE DEV
	USE OIO
	QUIT
	;
T001 ; /readyz is registered by INIT
	DO RESET
	DO INIT^MIOROUTE
	DO COMPILE^MIOROUTE
	NEW P,H,RP,OK
	KILL P
	SET OK=$$MATCH^MIOROUTE("GET","/readyz",.P,.H,.RP)
	DO EQ^MIOTASSERT(+OK,1,"[T001] match ok")
	DO EQ^MIOTASSERT($GET(H),"READY^MIOHEALTH","[T001] handler")
	QUIT
	;
T002 ; /healthz always 200
	DO RESET
	DO INIT^MIOROUTE
	DO COMPILE^MIOROUTE
	NEW CONF,REQ,CTX,DEV,OUT,OP
	SET OP="tmp/mio_health_t002.out"
	KILL REQ,CTX
	SET REQ("method")="GET",REQ("path")="/healthz"
	SET CTX("request_id")="hz002"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 200":1,1:0),1,"[T002] status")
	DO EQ^MIOTASSERT($SELECT(OUT["ok":1,1:0),1,"[T002] body")
	QUIT
	;
T003 ; /readyz ok when no required deps enabled
	DO RESET
	DO INIT^MIOROUTE
	DO COMPILE^MIOROUTE
	NEW CONF,REQ,CTX,DEV,OUT,OP
	SET OP="tmp/mio_health_t003.out"
	; static/log disabled by default
	KILL REQ,CTX
	SET REQ("method")="GET",REQ("path")="/readyz"
	SET CTX("request_id")="rz003"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 200":1,1:0),1,"[T003] status")
	DO EQ^MIOTASSERT($SELECT(OUT["""ok"":1":1,1:0),1,"[T003] ok=1")
	DO EQ^MIOTASSERT($SELECT(OUT["""routine"":""MIOHEALTH""":1,1:0),1,"[T003] routine")
	QUIT
	;
T004 ; /readyz 503 when static enabled but root missing
	DO RESET
	DO INIT^MIOROUTE
	DO COMPILE^MIOROUTE
	NEW CONF,REQ,CTX,DEV,OUT,OP
	SET OP="tmp/mio_health_t004.out"
	SET CONF("server","static","enabled")=1
	SET CONF("server","static","root")="tmp/__no_such_dir_mio_readyz_"_$J
	KILL REQ,CTX
	SET REQ("method")="GET",REQ("path")="/readyz"
	SET CTX("request_id")="rz004"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 503":1,1:0),1,"[T004] status")
	DO EQ^MIOTASSERT($SELECT(OUT["""error"":""not_ready""":1,1:0),1,"[T004] error")
	DO EQ^MIOTASSERT($SELECT(OUT["static_root":1,1:0),1,"[T004] static_root check")
	QUIT
	;