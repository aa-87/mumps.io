MIOAUTHZ ; Authorization checks (RBAC/ABAC) using route metadata and claims.
; API STABILITY
; Public API labels are documented in docs/routines.
; Undocumented labels are internal.
;
; Purpose
; Authorization checks (RBAC/ABAC) using route metadata and claims.
;
; Responsibilities
; - Authenticate requests.
; - Validate tokens and keys.
; - Populate auth context.
; - Deny safely.
;
; Entry Points
; - ENFORCE
; - DENY
;
; Globals Used
; - ^MIO("ROUTE",...)
;
; Notes
; Keep comments short.
; Do not log secrets.
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
; See docs/routines for details.
ENFORCE(DEV,CONF,REQ,CTX)
    ; If no prematch route, do nothing (auth middleware can still be prefix-based)
    NEW RP SET RP=$GET(CTX("match","route"))
    IF RP="" QUIT 1
    NEW M SET M=$GET(REQ("method"))
    NEW META DO GETMETA^MIOROUTE(M,RP,.META)

    ; If route doesn't require auth, allow
    IF +$GET(META("authRequired"))'=1 QUIT 1

    ; Must be authenticated
    IF '$GET(CTX("auth","ok")) QUIT $$DENY(.DEV,.CONF,.REQ,.CTX,"unauthorized","not_authenticated")

    ; RBAC: roles any-of
    NEW REQROLES SET REQROLES=$GET(META("roles"))
    IF REQROLES'="" DO  IF '$TEST QUIT $$DENY(.DEV,.CONF,.REQ,.CTX,"forbidden","role_required")
    . NEW OK SET OK=0
    . NEW I,RR SET RR=""
    . FOR I=1:1:$LENGTH(REQROLES,",") DO
    . . SET RR=$$TRIM^MIOAUTH($PIECE(REQROLES,",",I))
    . . IF RR="" QUIT
    . . IF $GET(CTX("auth","roles",RR)) SET OK=1
    . SET $TEST=OK

    ; Claim requirements (exact match)
    NEW K SET K=""
    FOR  SET K=$ORDER(META("claims.")) QUIT:K=""  DO
    . NEW NAME SET NAME=$PIECE(K,".",2,99)
    . NEW WANT SET WANT=$GET(META(K))
    . NEW GOT SET GOT=$GET(CTX("auth","claim",NAME))
    . IF WANT'="",GOT'=WANT QUIT $$DENY(.DEV,.CONF,.REQ,.CTX,"forbidden","claim_mismatch:"_NAME)
    ; Owner check
    NEW OP SET OP=$GET(META("ownerParam")),OC=$GET(META("ownerClaim"))
    IF OP'="",OC'="" DO  IF '$TEST QUIT $$DENY(.DEV,.CONF,.REQ,.CTX,"forbidden","not_owner")
    . NEW PV SET PV=$GET(REQ("params",OP))
    . NEW CV SET CV=$GET(CTX("auth","claim",OC))
    . SET $TEST=(PV'="")&(CV'="")&(PV=CV)

    QUIT 1

; Entry point
; See docs/routines for details.
DENY(DEV,CONF,REQ,CTX,ECODE,REASON)
    NEW OBJ
    SET OBJ("error")=ECODE
    SET OBJ("reason")=REASON
    SET OBJ("request_id")=$GET(CTX("request_id"))
    DO RESPJSONX^MIOHTTP(.DEV,.CONF,403,.OBJ,$GET(CTX("request_id")),.CTX)
    SET CTX("status")=403
    QUIT 0
