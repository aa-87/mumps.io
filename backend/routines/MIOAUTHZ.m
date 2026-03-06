MIOAUTHZ ; Authorization checks (RBAC/ABAC) using route metadata and claims.;
; API STABILITY
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; Purpose
; Authorization checks (RBAC/ABAC) using route metadata and claims.;
;
; Responsibilities
; - Authenticate requests.;
; - Validate tokens and keys.;
; - Populate auth context.;
; - Deny safely.;
;
; Entry Points
; - ENFORCE
; - DENY
;
; Globals Used
; - ^MIO("ROUTE",...)
;
; Notes
; Keep comments short.;
; Do not log secrets.;
;
	;
	; Entry:
	;   $$ENFORCE(.DEV,.CONF,.REQ,.CTX) -> 1 allow, 0 deny (writes response)
	;
	; Works with route metadata stored by MIOROUTE:
	;   meta("authRequired")=1
	;   meta("roles")="admin,user"     ; any-of
	;   meta("claims.<name>")="<val>"  ; exact match required
	;   meta("ownerParam")="id"        ; ABAC owner check
	;   meta("ownerClaim")="sub"       ; compare claim to param
	;
; Entry point
; See docs/routines for details.;
ENFORCE(DEV,CONF,REQ,CTX)
	NEW RP
	SET RP=$GET(CTX("match","route"))
	IF RP="" SET RP=$GET(CTX("route"))
	IF RP="" QUIT 1
	;
	NEW M SET M=$GET(REQ("method"))
	NEW META DO GETMETA^MIOROUTE(M,RP,.META)
	NEW TEST S TEST=$TEST
	;
	IF +$GET(META("authRequired"))'=1 QUIT 1
	;
	IF '$GET(CTX("auth","ok")) QUIT $$DENY(.DEV,.CONF,.REQ,.CTX,"unauthorized","not_authenticated")
	;
	NEW REQROLES SET REQROLES=$GET(META("roles"))
	IF REQROLES'="" DO  IF 'TEST QUIT $$DENY(.DEV,.CONF,.REQ,.CTX,"forbidden","role_required")
	. NEW OK SET OK=0
	. NEW I,RR SET RR=""
	. FOR I=1:1:$LENGTH(REQROLES,",") DO
	. . SET RR=$$TRIM^MIOAUTH($PIECE(REQROLES,",",I))
	. . IF RR="" QUIT
	. . IF $GET(CTX("auth","roles",RR)) SET OK=1
	. SET TEST=OK
	;
	NEW K,DENY,DENYNM SET K="claims.",DENY=0,DENYNM=""
	FOR  SET K=$ORDER(META(K)) QUIT:K=""  QUIT:$EXTRACT(K,1,7)'="claims."  QUIT:DENY  DO
	. I DENY QUIT
	. NEW NAME SET NAME=$EXTRACT(K,8,999)
	. NEW WANT SET WANT=$GET(META(K))
	. NEW GOT SET GOT=$GET(CTX("auth","claim",NAME))
	. IF WANT'="",GOT'=WANT S DENY=1,DENYNM=NAME QUIT 
	I DENY QUIT $$DENY(.DEV,.CONF,.REQ,.CTX,"forbidden","claim_mismatch:"_DENYNM)
	;
	NEW OP,OC
	SET OP=$GET(META("ownerParam"))
	SET OC=$GET(META("ownerClaim"))
	IF OP'="",OC'="" DO  IF 'TEST QUIT $$DENY(.DEV,.CONF,.REQ,.CTX,"forbidden","not_owner")
	. NEW PV,CV
	. SET PV=$GET(REQ("params",OP))
	. SET CV=$GET(CTX("auth","claim",OC))
	. SET TEST=(PV'="")&(CV'="")&(PV=CV)
	;
	QUIT 1
; Entry point
; See docs/routines for details.;
DENY(DEV,CONF,REQ,CTX,ECODE,REASON)
	NEW OBJ
	SET OBJ("routine")="MIOAUTHZ"
	SET OBJ("error")=ECODE
	SET OBJ("reason")=REASON
	SET OBJ("request_id")=$GET(CTX("request_id"))
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,403,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=403
	QUIT 0
	;