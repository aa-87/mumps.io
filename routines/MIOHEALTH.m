MIOHEALTH ; Health + readiness endpoints (ROI #5)
;
; PURPOSE
; Provide production-friendly health and readiness endpoints.;
;
; ENDPOINTS (typical)
;   GET /healthz  -> always 200 (service is running)
;   GET /readyz   -> 200 when ready, else 503 with JSON checks
;
; ROUTE REGISTRATION
;   DO REG^MIOHEALTH(.CONF) during startup before COMPILE^MIOROUTE.;
;
; DESIGN
; - Deterministic, fast checks
; - No ZSYSTEM, no GOTO
; - All error responses include routine + error
;
; GLOBALS
; - none (read-only checks on ^MIO(...) when present)
;
	Q
	;
REG(CONF) ; Register routes (safe no-op if router not available)
	IF $TEXT(ADD^MIOROUTE)="" QUIT
	DO ADD^MIOROUTE("GET","/healthz","HEALTH^MIOHEALTH")
	DO ADD^MIOROUTE("GET","/readyz","READY^MIOHEALTH")
	QUIT
	;
HEALTH(DEV,CONF,REQ,CTX) ; Always 200
	NEW OBJ
	KILL OBJ
	SET OBJ("ok")=1
	SET OBJ("status")="ok"
	SET OBJ("routine")="MIOHEALTH"
	SET OBJ("endpoint")="healthz"
	SET OBJ("request_id")=$GET(CTX("request_id"))
	IF $TEXT(NOWISO^MIOUTIL)'="" SET OBJ("ts")=$$NOWISO^MIOUTIL()
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
READY(DEV,CONF,REQ,CTX) ; 200 when ready else 503
	NEW OBJ,OK,STATUS
	SET OK=1
	KILL OBJ
	SET OBJ("routine")="MIOHEALTH"
	SET OBJ("endpoint")="readyz"
	SET OBJ("request_id")=$GET(CTX("request_id"))
	IF $TEXT(NOWISO^MIOUTIL)'="" SET OBJ("ts")=$$NOWISO^MIOUTIL()
	;
	; checks (deterministic order)
	DO CHKCONF(.CONF,.OBJ,.OK)
	DO CHKCONFV(.CONF,.OBJ,.OK)
	DO CHKROUTER(.CONF,.OBJ,.OK)
	DO CHKSTATIC(.CONF,.OBJ,.OK)
	DO CHKSPOOL(.CONF,.OBJ,.OK)
	DO CHKACCESSLOG(.CONF,.OBJ,.OK)
	DO CHKTPL(.CONF,.OBJ,.OK)
	;
	SET OBJ("ok")=$SELECT(OK:1,1:0)
	IF OK DO
	. SET OBJ("status")="ready"
	. SET STATUS=200
	ELSE  DO
	. SET OBJ("status")="not_ready"
	. SET OBJ("error")="not_ready"
	. SET STATUS=503
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,STATUS,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=STATUS
	QUIT
	;
; ---- checks ------------------------------------------------------------
CHKCONF(CONF,OBJ,OK)
	; Do not fail solely because CONF is empty (tests may pass minimal config)
	NEW HAS SET HAS=$SELECT($DATA(CONF)>0:1,1:0)
	DO SETCHK(.OBJ,"conf_loaded",1,$SELECT(HAS:"ok",1:"empty"))
	QUIT
	;
CHKCONFV(CONF,OBJ,OK)
	; Config validation: fail readiness only on explicit errors.;
	; Missing optional keys do not fail.;
	IF $TEXT(VALIDATE^MIOCONFV)="" DO  QUIT
	. DO SETCHK(.OBJ,"config_valid",1,"skipped")
	NEW REP,ERR,GOOD
	SET GOOD=$$VALIDATE^MIOCONFV(.CONF,.REP,.ERR)
	IF GOOD DO  QUIT
	. DO SETCHK(.OBJ,"config_valid",1,$SELECT(+$GET(REP("warn_count"))>0:"warn:"_+$GET(REP("warn_count")),1:"ok"))
	; invalid config
	DO SETCHK(.OBJ,"config_valid",0,"invalid:"_+$GET(REP("err_count")))
	; include first few issue codes for diagnostics
	NEW I,N SET (I,N)=0
	FOR  SET I=$ORDER(REP("issues",I)) QUIT:'I  DO  QUIT:N'<5
	. IF $GET(REP("issues",I,"sev"))'="error" QUIT
	. SET N=N+1
	. SET OBJ("checks","config_valid","issues",N)=$GET(REP("issues",I,"code"))
	SET OK=0
	QUIT
	;
CHKROUTER(CONF,OBJ,OK)
	; Optional: check that router was compiled (if info exists)
	NEW EN SET EN=$$BOOL($GET(CONF("server","health","readyCheckRouterCompiled"),0))
	IF 'EN DO  QUIT
	. DO SETCHK(.OBJ,"router_compiled",1,"skipped")
	NEW ROK SET ROK=+$GET(^MIO("ROUTE","COMPILE","ok"))
	DO SETCHK(.OBJ,"router_compiled",ROK,$SELECT(ROK:"ok",1:"not_compiled"))
	IF 'ROK SET OK=0
	QUIT
	;
CHKSTATIC(CONF,OBJ,OK)
	NEW EN SET EN=$$BOOL($GET(CONF("server","static","enabled")))
	IF 'EN DO  QUIT
	. DO SETCHK(.OBJ,"static_root",1,"disabled")
	NEW ROOT SET ROOT=$GET(CONF("server","static","root"),"public")
	NEW EOK SET EOK=$$DIREX(ROOT)
	DO SETCHK(.OBJ,"static_root",EOK,$SELECT(EOK:"ok",1:"missing:"_ROOT))
	IF 'EOK SET OK=0
	QUIT
	;
CHKSPOOL(CONF,OBJ,OK)
	; Multipart spooling is optional but common. We only check directory existence (no writes).;
	NEW EN SET EN=$$BOOL($GET(CONF("server","health","readyCheckSpoolDir"),0))
	IF 'EN DO  QUIT
	. DO SETCHK(.OBJ,"multipart_spool_dir",1,"skipped")
	NEW DIR SET DIR=$GET(CONF("server","multipart","spoolDir"),"/tmp")
	NEW DOK SET DOK=$$DIREX(DIR)
	DO SETCHK(.OBJ,"multipart_spool_dir",DOK,$SELECT(DOK:"ok",1:"missing:"_DIR))
	IF 'DOK SET OK=0
	QUIT
	;
CHKACCESSLOG(CONF,OBJ,OK)
	NEW EN SET EN=$$BOOL($GET(CONF("server","log","access","enabled")))
	IF 'EN DO  QUIT
	. DO SETCHK(.OBJ,"access_log_sink",1,"disabled")
	; Access logs are global-backed for determinism/perf.;
	NEW ME SET ME=+$GET(CONF("server","log","access","maxEntries"),20000)
	IF ME<100 DO  QUIT
	. DO SETCHK(.OBJ,"access_log_sink",0,"maxEntries_lt_100")
	. SET OK=0
	DO SETCHK(.OBJ,"access_log_sink",1,"global")
	QUIT
	;
CHKTPL(CONF,OBJ,OK)
	; Optional: only check templateDir when explicitly enabled.;
	NEW EN SET EN=$$BOOL($GET(CONF("server","health","readyCheckTemplates"),0))
	IF 'EN DO  QUIT
	. DO SETCHK(.OBJ,"template_dir",1,"skipped")
	NEW DIR SET DIR=$GET(CONF("server","templateDir"),"templates")
	NEW DOK SET DOK=$$DIREX(DIR)
	DO SETCHK(.OBJ,"template_dir",DOK,$SELECT(DOK:"ok",1:"missing:"_DIR))
	IF 'DOK SET OK=0
	QUIT
	;
; ---- helpers -----------------------------------------------------------
SETCHK(OBJ,NAME,OK,INFO)
	SET OBJ("checks",NAME,"ok")=+$GET(OK)
	IF $GET(INFO)'="" SET OBJ("checks",NAME,"info")=$GET(INFO)
	QUIT
	;
DIREX(PATH)
	NEW P SET P=$GET(PATH)
	IF P="" QUIT 0
	IF $L(P)>1,$E(P,$L(P))="/" SET P=$E(P,1,$L(P)-1)
	; Directory exists if any file matches (best-effort, deterministic)
	IF $ZSEARCH(P_"/.")'="" QUIT 1
	IF $ZSEARCH(P_"/")'="" QUIT 1
	IF $ZSEARCH(P)'="" QUIT 1
	QUIT 0
	;
BOOL(X)
	NEW V SET V=$$LOW^MIOHTTP($GET(X))
	QUIT $SELECT(V="1":1,V="true":1,V="yes":1,V="on":1,1:0)
	;