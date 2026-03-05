MIOHEALTH ; Health + readiness endpoints (ROI #5)
;
; Purpose
; - Provide production-friendly health and readiness endpoints.
;
; Endpoints
; - GET /readyz  -> 200 when ready, else 503 with JSON details.
;   /healthz is a core handler in MIOROUTE and always returns 200.
;
; Notes
; - No ZSYSTEM.
; - Keep checks fast and deterministic.
; - When not ready, response includes routine + error fields.
;
	QUIT
	;
READY(DEV,CONF,REQ,CTX)
	NEW OBJ,OK,STATUS
	SET OK=1
	KILL OBJ
	SET OBJ("routine")="MIOHEALTH"
	SET OBJ("endpoint")="readyz"
	SET OBJ("ts")=$$NOWISO^MIOUTIL()
	;
	; checks (deterministic order)
	DO CHKCONF(.CONF,.OBJ,.OK)
	DO CHKSTATIC(.CONF,.OBJ,.OK)
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
	; CONF is passed by reference by the server, but may be empty in tests
	; or minimal configurations. Readiness should not fail solely because
	; the configuration array is empty.
	NEW HAS SET HAS=$SELECT($DATA(CONF)>0:1,1:0)
	DO SETCHK(.OBJ,"conf_loaded",1,$SELECT(HAS:"ok",1:"empty"))
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
CHKACCESSLOG(CONF,OBJ,OK)
	NEW EN SET EN=$$BOOL($GET(CONF("server","log","access","enabled")))
	IF 'EN DO  QUIT
	. DO SETCHK(.OBJ,"access_log_dir",1,"disabled")
	; Access logs are global-backed for determinism/perf.
	NEW ME SET ME=+$GET(CONF("server","log","access","maxEntries"),20000)
	IF ME<100 DO  QUIT
	. DO SETCHK(.OBJ,"access_log_sink",0,"maxEntries_lt_100")
	. SET OK=0
	DO SETCHK(.OBJ,"access_log_sink",1,"global")
	QUIT
	;
CHKTPL(CONF,OBJ,OK)
	; Optional: only check templateDir when explicitly enabled.
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
	IF $ZSEARCH(P)'="" QUIT 1
	IF $ZSEARCH(P_"/")'="" QUIT 1
	IF $ZSEARCH(P_"/.")'="" QUIT 1
	QUIT 0
	;
DIRNAME(PATH)
	NEW P SET P=$GET(PATH)
	NEW N SET N=$L(P,"/")
	IF N<2 QUIT ""
	NEW D SET D=$P(P,"/",1,N-1)
	IF D="" SET D="/"
	QUIT D
	;
CANWRITE(DIR,FN)
	NEW OK SET OK=1
	NEW FP SET FP=$GET(DIR)
	IF FP="" QUIT 0
	IF $E(FP,$L(FP))'="/" SET FP=FP_"/"
	SET FP=FP_$GET(FN,".mio_ready")
	NEW $ETRAP SET $ETRAP="SET $ECODE=\"\" SET OK=0"
	; Try append; if file doesn't exist, create new.
	OPEN FP:(append:stream:nowrap):1 ELSE  DO
	. OPEN FP:(new:stream:nowrap):1 ELSE  SET OK=0
	IF OK CLOSE FP
	QUIT OK
	;
BOOL(X)
	NEW V SET V=$$LOW^MIOHTTP($GET(X))
	QUIT $SELECT(V="1":1,V="true":1,V="yes":1,V="on":1,1:0)
