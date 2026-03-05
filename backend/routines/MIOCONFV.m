MIOCONFV ; Config validation + self diagnostics (ROI)
;
; PURPOSE
; Validate server configuration deterministically.
;
; DESIGN
; - No ZSYSTEM, no GOTO
; - Deterministic issue ordering
; - Does not fail on missing optional keys
;
; API
;   OK=$$VALIDATE(.CONF,.REP,.ERR)
;     REP("ok")=1/0
;     REP("err_count"), REP("warn_count")
;     REP("issues",n,"sev")="error"|"warn"
;     REP("issues",n,"code"), ("path"), ("msg")
;     ERR("routine")="MIOCONFV" when OK=0
;     ERR("error")="invalid_config" when OK=0
;
	QUIT
	;
VALIDATE(CONF,REP,ERR) ; return 1 if valid else 0
	KILL REP,ERR
	SET REP("routine")="MIOCONFV"
	;
	; ---- checks in deterministic order ----
	DO VPORT(.CONF,.REP)
	DO VSTATIC(.CONF,.REP)
	DO VKEEPAL(.CONF,.REP)
	DO VHTTP(.CONF,.REP)
	DO VRATE(.CONF,.REP)
	DO VDOS(.CONF,.REP)
	DO VSEC(.CONF,.REP)
	;
	DO SUM(.REP)
	IF +$GET(REP("err_count"))>0 DO  QUIT 0
	. SET ERR("routine")="MIOCONFV"
	. SET ERR("error")="invalid_config"
	. SET ERR("status")=500
	SET REP("ok")=1
	QUIT 1
	;
; ---- validators ------------------------------------------------------
VPORT(CONF,REP)
	; Only error if provided and invalid
	NEW P SET P=$GET(CONF("server","listen","port"))
	IF P="" QUIT
	IF '(P?1.N) DO ADD(.REP,"error","bad_port","server.listen.port","not_numeric") QUIT
	IF +P<1!(+P>65535) DO ADD(.REP,"error","bad_port","server.listen.port","out_of_range")
	QUIT
	;
VSTATIC(CONF,REP)
	NEW EN SET EN=+$GET(CONF("server","static","enabled"),0)
	IF 'EN QUIT
	NEW ROOT SET ROOT=$GET(CONF("server","static","root"))
	IF ROOT="" DO ADD(.REP,"error","static_root_missing","server.static.root","required_when_static_enabled")
	NEW MNT SET MNT=$GET(CONF("server","static","mount"),"/static")
	IF $EXTRACT(MNT,1)'="/" DO ADD(.REP,"error","static_mount_invalid","server.static.mount","must_start_with_slash")
	QUIT
	;
VKEEPAL(CONF,REP)
	NEW EN SET EN=$GET(CONF("server","keepAlive","enabled"))
	IF EN="" QUIT
	NEW V SET V=$$BOOL(EN)
	IF 'V QUIT
	NEW MX SET MX=$GET(CONF("server","keepAlive","maxRequests"))
	IF MX="" QUIT
	IF '(MX?1.N) DO ADD(.REP,"error","keepalive_max_invalid","server.keepAlive.maxRequests","not_numeric") QUIT
	IF +MX<1 DO ADD(.REP,"error","keepalive_max_invalid","server.keepAlive.maxRequests","must_be_ge_1")
	QUIT
	;
VHTTP(CONF,REP)
	; Validate important hardening limits if present
	NEW B
	SET B=$GET(CONF("server","http","limits","maxHeaderBytes"))
	IF B'="" DO
	. IF '(B?1.N) DO ADD(.REP,"error","maxHeaderBytes_invalid","server.http.limits.maxHeaderBytes","not_numeric") QUIT
	. IF +B<1024 DO ADD(.REP,"warn","maxHeaderBytes_small","server.http.limits.maxHeaderBytes","lt_1024")
	SET B=$GET(CONF("server","http","limits","maxHeaderCount"))
	IF B'="" DO
	. IF '(B?1.N) DO ADD(.REP,"error","maxHeaderCount_invalid","server.http.limits.maxHeaderCount","not_numeric") QUIT
	. IF +B<8 DO ADD(.REP,"warn","maxHeaderCount_small","server.http.limits.maxHeaderCount","lt_8")
	QUIT
	;
VRATE(CONF,REP)
	NEW EN SET EN=+$GET(CONF("server","rate","enabled"),0)
	IF 'EN QUIT
	NEW RPS SET RPS=$GET(CONF("server","rate","rps"))
	IF RPS="" DO ADD(.REP,"error","rate_rps_missing","server.rate.rps","required_when_enabled") QUIT
	IF '(RPS?1.N) DO ADD(.REP,"error","rate_rps_invalid","server.rate.rps","not_numeric") QUIT
	IF +RPS<1 DO ADD(.REP,"error","rate_rps_invalid","server.rate.rps","must_be_ge_1")
	NEW B SET B=$GET(CONF("server","rate","burst"))
	IF B'="" DO
	. IF '(B?1.N) DO ADD(.REP,"error","rate_burst_invalid","server.rate.burst","not_numeric") QUIT
	. IF +B<1 DO ADD(.REP,"error","rate_burst_invalid","server.rate.burst","must_be_ge_1")
	QUIT
	;
VDOS(CONF,REP)
	NEW M SET M=$GET(CONF("server","dos","maxActiveConns"))
	IF M="" QUIT
	IF '(M?1.N) DO ADD(.REP,"error","dos_maxActive_invalid","server.dos.maxActiveConns","not_numeric") QUIT
	IF +M<1 DO ADD(.REP,"error","dos_maxActive_invalid","server.dos.maxActiveConns","must_be_ge_1")
	QUIT
	;
VSEC(CONF,REP)
	; Security preset sanity if present
	NEW P SET P=$$LOW($GET(CONF("server","security","preset")))
	IF P="" QUIT
	IF P'="strict",P'="balanced",P'="dev",P'="off" DO ADD(.REP,"warn","security_preset_unknown","server.security.preset","unknown_value")
	QUIT
	;
; ---- helpers ---------------------------------------------------------
ADD(REP,SEV,CODE,PATH,MSG)
	NEW N SET N=+$ORDER(REP("issues",""),-1)+1
	SET REP("issues",N,"sev")=$GET(SEV)
	SET REP("issues",N,"code")=$GET(CODE)
	SET REP("issues",N,"path")=$GET(PATH)
	SET REP("issues",N,"msg")=$GET(MSG)
	QUIT
	;
SUM(REP)
	NEW I,E,W SET (E,W)=0
	SET I=0
	FOR  SET I=$ORDER(REP("issues",I)) QUIT:'I  DO
	. IF $GET(REP("issues",I,"sev"))="error" SET E=E+1 QUIT
	. IF $GET(REP("issues",I,"sev"))="warn" SET W=W+1
	SET REP("err_count")=E
	SET REP("warn_count")=W
	SET REP("ok")=$SELECT(E>0:0,1:1)
	QUIT
	;
BOOL(X)
	NEW V SET V=$$LOW($GET(X))
	QUIT $SELECT(V="1":1,V="true":1,V="yes":1,V="on":1,1:0)
	;
LOW(S)
	QUIT $ZCONVERT($GET(S),"L")
	;