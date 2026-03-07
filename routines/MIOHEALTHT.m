MIOHEALTHT ; Tests for health + readiness endpoints (ROI #5)
;
; Run:
;   YDB>D ^MIOHEALTHT
;
; Notes
; - Quiet on success.;
; - Writes to tmp files and validates response content.;
;
	Q
	;
START
	DO T001
	DO T002
	DO T003
	DO T004
	DO T005
	QUIT
	;
T001 ; /healthz always 200
	NEW CONF,REQ,CTX,OUT,OP
	SET OP="tmp/mio_health_t001.out"
	DO SETUPROUTES
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/healthz"
	SET CTX("request_id")="hlt001"
	DO RUNDISP(OP,.CONF,.REQ,.CTX,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 200 OK":1,1:0),1,"[T001][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["""endpoint"":""healthz""":1,1:0),1,"[T001][body]")
	QUIT
	;
T002 ; /readyz 200 with minimal config (static disabled)
	NEW CONF,REQ,CTX,OUT,OP
	SET OP="tmp/mio_health_t002.out"
	DO SETUPROUTES
	SET CONF("server","static","enabled")=0
	; do not require template/spool/router checks in this minimal config
	SET CONF("server","health","readyCheckTemplates")=0
	SET CONF("server","health","readyCheckSpoolDir")=0
	SET CONF("server","health","readyCheckRouterCompiled")=0
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/readyz"
	SET CTX("request_id")="hlt002"
	DO RUNDISP(OP,.CONF,.REQ,.CTX,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 200 OK":1,1:0),1,"[T002][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["""status"":""ready""":1,1:0),1,"[T002][body]")
	QUIT
	;
T003 ; /readyz 503 when static enabled but root missing
	NEW CONF,REQ,CTX,OUT,OP
	SET OP="tmp/mio_health_t003.out"
	DO SETUPROUTES
	SET CONF("server","static","enabled")=1
	SET CONF("server","static","root")="tmp/__mio_missing_dir__"
	SET CONF("server","health","readyCheckTemplates")=0
	SET CONF("server","health","readyCheckSpoolDir")=0
	SET CONF("server","health","readyCheckRouterCompiled")=0
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/readyz"
	SET CTX("request_id")="hlt003"
	DO RUNDISP(OP,.CONF,.REQ,.CTX,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 503 Service Unavailable":1,1:0),1,"[T003][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["""routine"":""MIOHEALTH""":1,1:0),1,"[T003][routine]")
	DO EQ^MIOTASSERT($SELECT(OUT["""error"":""not_ready""":1,1:0),1,"[T003][error]")
	DO EQ^MIOTASSERT($SELECT(OUT["""static_root""":1,1:0),1,"[T003][checks]")
	QUIT
	;
T004 ; /readyz 200 when static enabled and root exists
	NEW CONF,REQ,CTX,OUT,OP
	SET OP="tmp/mio_health_t004.out"
	DO SETUPROUTES
	SET CONF("server","static","enabled")=1
	SET CONF("server","static","root")="tmp"
	SET CONF("server","health","readyCheckTemplates")=0
	SET CONF("server","health","readyCheckSpoolDir")=0
	SET CONF("server","health","readyCheckRouterCompiled")=0
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/readyz"
	SET CTX("request_id")="hlt004"
	DO RUNDISP(OP,.CONF,.REQ,.CTX,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 200 OK":1,1:0),1,"[T004][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["""status"":""ready""":1,1:0),1,"[T004][body]")
	QUIT
	;
T005 ; /readyz 503 when config validation finds an explicit error
	NEW CONF,REQ,CTX,OUT,OP
	SET OP="tmp/mio_health_t005.out"
	DO SETUPROUTES
	; introduce an invalid listen port
	SET CONF("server","listen","port")=70000
	SET CONF("server","static","enabled")=0
	SET CONF("server","health","readyCheckTemplates")=0
	SET CONF("server","health","readyCheckSpoolDir")=0
	SET CONF("server","health","readyCheckRouterCompiled")=0
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/readyz"
	SET CTX("request_id")="hlt005"
	DO RUNDISP(OP,.CONF,.REQ,.CTX,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 503 Service Unavailable":1,1:0),1,"[T005][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["""config_valid""":1,1:0),1,"[T005][check present]")
	DO EQ^MIOTASSERT($SELECT(OUT["bad_port":1,1:0),1,"[T005][issue code]")
	QUIT
	;
; ---- harness helpers ---------------------------------------------------
SETUPROUTES
	; Setup minimal routes for these tests (avoid depending on full INIT)
	IF $TEXT(ADD^MIOROUTE)="" QUIT
	KILL ^MIO("ROUTE")
	DO ADD^MIOROUTE("GET","/healthz","HEALTH^MIOHEALTH")
	DO ADD^MIOROUTE("GET","/readyz","READY^MIOHEALTH")
	DO COMPILE^MIOROUTE
	QUIT
	;
RUNDISP(OP,CONF,REQ,CTX,OUT)
	NEW DEV,OIO
	SET OIO=$IO
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE OIO
	DO READALL(OP,.OUT)
	QUIT
	;
READALL(FP,OUT)
	NEW X S OUT=""
	NEW $ETRAP SET $ETRAP="SET $ECODE="" QUIT"
	OPEN FP:(readonly:stream:nowrap)
	USE FP
	FOR  READ X QUIT:$ZEOF  SET OUT=OUT_X
	CLOSE FP USE $PRINCIPAL
	QUIT
	;