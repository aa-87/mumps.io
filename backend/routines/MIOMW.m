MIOMW ; Middleware pipeline for MIOROUTE (ROI #8)
	;
	; Goals
	; - Deterministic hook order (global then route-level)
	; - Minimal overhead when disabled
	; - No ZSYSTEM, no GOTO
	; - All errors include ERR("routine") and ERR("error")
	;
	; Hook entryref format:
	;   "TAG^ROUTINE"
	;
	; Before hook signature:
	;   OK=$$TAG^ROUTINE(.CONF,.REQ,.CTX,.ERR)  ; 1 continue, 0 abort
	;
	; After hook signature:
	;   DO TAG^ROUTINE(.CONF,.REQ,.CTX)         ; best-effort
	;
	; Middleware may inject response headers via:
	;   CTX("mw","hdr","Header-Name")="value"
	;   CTX("mw","hdr","Header-Name","force")=1
	;
	QUIT
	;
EN(CONF) ; $$ -> 1 enabled, 0 disabled
	QUIT $SELECT($GET(CONF("server","mw","enabled"))=1:1,1:0)
	;
DISABLED(METHOD,ROUTE) ; $$ -> 1 disabled for this route
	QUIT $SELECT($GET(^MIO("ROUTE","META",METHOD,ROUTE,"mwDisable"))=1:1,1:0)
	;
BUILD(CONF,METHOD,ROUTE,MW,ERR)
	KILL MW,ERR
	SET ERR("routine")="MIOMW"
	NEW N,H,CB,CA
	SET CB=0,CA=0
	; global before
	SET N=0
	FOR  SET N=$ORDER(CONF("server","mw","before",N)) QUIT:N=""  DO
	. SET H=$GET(CONF("server","mw","before",N)) QUIT:H=""
	. SET CB=CB+1,MW("before",CB)=H
	; route before
	IF $GET(ROUTE)'="" DO
	. SET N=0
	. FOR  SET N=$ORDER(^MIO("ROUTE","META",METHOD,ROUTE,"mw","before",N)) QUIT:N=""  DO
	. . SET H=$GET(^MIO("ROUTE","META",METHOD,ROUTE,"mw","before",N)) QUIT:H=""
	. . SET CB=CB+1,MW("before",CB)=H
	; global after
	SET N=0
	FOR  SET N=$ORDER(CONF("server","mw","after",N)) QUIT:N=""  DO
	. SET H=$GET(CONF("server","mw","after",N)) QUIT:H=""
	. SET CA=CA+1,MW("after",CA)=H
	; route after
	IF $GET(ROUTE)'="" DO
	. SET N=0
	. FOR  SET N=$ORDER(^MIO("ROUTE","META",METHOD,ROUTE,"mw","after",N)) QUIT:N=""  DO
	. . SET H=$GET(^MIO("ROUTE","META",METHOD,ROUTE,"mw","after",N)) QUIT:H=""
	. . SET CA=CA+1,MW("after",CA)=H
	QUIT
	;
RUNBEFORE(CONF,REQ,CTX,MW,ERR) ; $$ -> 1 continue, 0 abort
	NEW I,HOOK,OK
	SET OK=1
	SET I=0
	FOR  SET I=$ORDER(MW("before",I)) QUIT:I=""  DO  QUIT:OK=0
	. SET HOOK=$GET(MW("before",I)) QUIT:HOOK=""
	. KILL ERR
	. SET OK=$$CALLBEF(.CONF,.REQ,.CTX,HOOK,.ERR)
	. IF 'OK DO ENSERR("mw_abort","MIOMW",.ERR)
	QUIT $SELECT(OK=1:1,1:0)
	;
RUNAFTER(CONF,REQ,CTX,MW)
	NEW I,HOOK
	SET I=0
	FOR  SET I=$ORDER(MW("after",I)) QUIT:I=""  DO
	. SET HOOK=$GET(MW("after",I)) QUIT:HOOK=""
	. DO CALLAFT(.CONF,.REQ,.CTX,HOOK)
	QUIT
	;
CALLBEF(CONF,REQ,CTX,HOOK,ERR) ; $$ -> 1/0
	NEW TAG,RTN,OK,CMD
	SET TAG=$PIECE(HOOK,"^",1),RTN=$PIECE(HOOK,"^",2)
	IF TAG=""!(RTN="") DO ENSERR("bad_hook","MIOMW",.ERR) QUIT 0
	IF '$$SAFEENTRY(TAG,RTN) DO ENSERR("bad_hook","MIOMW",.ERR) QUIT 0
	NEW $ETRAP SET $ETRAP="DO TRAP^MIOMW(""hook_error"",.ERR) SET $ECODE="""" QUIT"
	SET OK=0
	SET CMD="SET OK=$$"_TAG_"^"_RTN_"(.CONF,.REQ,.CTX,.ERR)"
	XECUTE CMD
	QUIT $SELECT(OK=1:1,1:0)
	;
CALLAFT(CONF,REQ,CTX,HOOK)
	NEW TAG,RTN,CMD
	SET TAG=$PIECE(HOOK,"^",1),RTN=$PIECE(HOOK,"^",2)
	IF TAG=""!(RTN="") QUIT
	IF '$$SAFEENTRY(TAG,RTN) QUIT
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" QUIT"
	SET CMD="DO "_TAG_"^"_RTN_"(.CONF,.REQ,.CTX)"
	XECUTE CMD
	QUIT
	;
SAFEENTRY(TAG,RTN) ; $$ -> 1 ok
	NEW X SET X=TAG_"^"_RTN
	IF X["(" QUIT 0
	IF X[")" QUIT 0
	IF X["""" QUIT 0
	IF X[" " QUIT 0
	NEW I,C,BAD SET BAD=0
	FOR I=1:1:$L(X) QUIT:BAD  DO
	. SET C=$E(X,I)
	. IF C="^" QUIT
	. IF (C?1A)!(C?1N)!(C="%") QUIT
	. SET BAD=1
	QUIT $SELECT(BAD:0,1:1)
	;
ENSERR(CODE,RTN,ERR)
	IF $GET(ERR("routine"))="" SET ERR("routine")=$GET(RTN,"MIOMW")
	IF $GET(ERR("error"))="" SET ERR("error")=$GET(CODE,"mw_abort")
	IF $GET(ERR("status"))="" SET ERR("status")=500
	QUIT
	;
TRAP(CODE,ERR)
	NEW ZS SET ZS=$ZSTATUS
	SET ERR("routine")="MIOMW"
	SET ERR("error")=$GET(CODE,"mw_error")
	SET ERR("detail")=ZS
	IF $GET(ERR("status"))="" SET ERR("status")=500
	SET $ECODE=""
	QUIT
	;
RESPERR(DEV,CONF,REQ,CTX,ERR)
	NEW ST SET ST=+$GET(ERR("status")) IF ST<100 SET ST=500
	NEW OBJ
	SET OBJ("ok")=0
	SET OBJ("routine")=$GET(ERR("routine"),"MIOMW")
	SET OBJ("error")=$GET(ERR("error"),"error")
	IF $GET(ERR("detail"))'="" SET OBJ("detail")=ERR("detail")
	SET OBJ("request_id")=$GET(CTX("request_id"))
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,ST,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=ST
	QUIT
