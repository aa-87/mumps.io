MIOAUTH ; Authentication middleware. Enforces API key and JWT policies.;
; API STABILITY
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; Purpose
; Authentication middleware. Enforces API key and JWT policies.;
;
; Responsibilities
; - Authenticate requests.;
; - Validate tokens and keys.;
; - Populate auth context.;
; - Deny safely.;
;
; Entry Points
; - ENFORCE
; - ISPROTECTED
; - ISEXEMPT
; - KEYID
; - U32
; - HEX8
; - LOW
; - TRIM
; - DENY
;
; Notes
; Keep comments short.;
; Do not log secrets.;
;
	;
	; $$ENFORCE(.DEV,.CONF,.REQ,.CTX) -> 1 allow, 0 deny (writes response)
	;
; Entry point
; See docs/routines for details.;
ENFORCE(DEV,CONF,REQ,CTX)
	NEW M,TEST S TEST=$T SET M=$GET(REQ("method"))
	IF M="OPTIONS" QUIT 1
	NEW PATH SET PATH=$GET(REQ("path"))
	IF PATH="" QUIT 1
	;
	; Exempt paths
	IF $$ISEXEMPT(PATH,.CONF) QUIT 1
	;
	; Determine protection mode:
	;   - "prefix": protect by prefixes list (or defaults)
	;   - "route": protect only if matched route meta authRequired=1
	NEW PMODE SET PMODE=$GET(CONF("auth","protectMode"),"prefix")
	; Route-based protection: enforce only when route meta authRequired=1.
	; This must work both when CTX("match",...) is populated and when only CTX("route") is set.
	IF PMODE="route" DO
	. NEW RP SET RP=$GET(CTX("match","route"))
	. IF RP="" SET RP=$GET(CTX("route"))
	. ; If no real route match, do not enforce here
	. IF RP="" SET PMODE="none" QUIT
	. IF $EXTRACT(RP,1)="(" SET PMODE="none" QUIT
	. NEW META DO GETMETA^MIOROUTE($GET(REQ("method")),RP,.META)
	. IF +$GET(META("authRequired"))'=1 SET PMODE="none" QUIT
	; If not protected by route meta, allow
	IF PMODE="none" QUIT 1
	;
	; Prefix-based protection
	; Default behavior: only enforce auth for protected prefixes (/api/, /ws/app, or CONF list)
	IF PMODE="prefix" IF '$$ISPROTECTED(PATH,.CONF) QUIT 1
	;
	; Authenticate
	NEW MODE SET MODE=$GET(CONF("auth","mode"),"api_key")
	NEW OK
	IF MODE="api_key" SET OK=$$ENFAPIKEY(.DEV,.CONF,.REQ,.CTX)
	ELSE  IF MODE="jwt" SET OK=$$ENFJWT(.DEV,.CONF,.REQ,.CTX)
	ELSE  IF MODE="either" SET OK=($$ENFAPIKEY(.DEV,.CONF,.REQ,.CTX)!($$ENFJWT(.DEV,.CONF,.REQ,.CTX)))
	ELSE  SET OK=$$DENY(.DEV,.CONF,.REQ,.CTX,"unauthorized","auth_mode_unsupported")
	;
	IF 'OK QUIT 0
	;
	; Authorization (RBAC/ABAC) based on route metadata (if any)
	IF '$$ENFORCE^MIOAUTHZ(.DEV,.CONF,.REQ,.CTX) QUIT 0
	;
	QUIT 1
	;
ENFAPIKEY(DEV,CONF,REQ,CTX)
	N TEST S TEST=$T
	NEW HN SET HN=$$LOW($GET(CONF("auth","apiKey","header"),"X-Api-Key"))
	NEW KEY SET KEY=$GET(REQ("hdr",HN))
	IF KEY="" QUIT $$DENY(.DEV,.CONF,.REQ,.CTX,"unauthorized","api_key_missing")
	;
	; Allow list: CONF("auth","apiKey","allow",key)=1 optionally with role mapping
	IF $DATA(CONF("auth","apiKey","allow")) DO  QUIT:TEST 1  QUIT $$DENY(.DEV,.CONF,.REQ,.CTX,"unauthorized","api_key_invalid")
	. IF $GET(CONF("auth","apiKey","allow",KEY))=1 DO
	. . SET CTX("auth","ok")=1
	. . SET CTX("auth","key_id")=$$KEYID(KEY)
	. . ; optional roles mapping: allowRoles(key,"admin")=1
	. . NEW R SET R=""
	. . FOR  SET R=$ORDER(CONF("auth","apiKey","roles",KEY,R)) QUIT:R=""  SET CTX("auth","roles",R)=1
	. . SET TEST=1 QUIT
	. SET TEST=0
	; Single key mode
	NEW EXPECT SET EXPECT=$GET(CONF("auth","apiKey","value"))
	IF EXPECT="" SET EXPECT="change-me"
	IF KEY'=EXPECT QUIT $$DENY(.DEV,.CONF,.REQ,.CTX,"unauthorized","api_key_invalid")
	SET CTX("auth","ok")=1,CTX("auth","key_id")=$$KEYID(KEY)
	QUIT 1
	;
ENFJWT(DEV,CONF,REQ,CTX)
	NEW ERR,OK
	SET OK=$$VERIFY^MIOAUTHJWT(.CONF,.REQ,.CTX,.ERR)
	IF 'OK QUIT $$DENY(.DEV,.CONF,.REQ,.CTX,"unauthorized",$GET(ERR("error"),"jwt_invalid"))
	QUIT 1
	;
; Entry point
; See docs/routines for details.;
ISPROTECTED(PATH,CONF)
	NEW I,P,T S T=$T
	IF $DATA(CONF("auth","protect","prefix")) DO  QUIT T
	. SET T=0
	. SET I=""
	. FOR  SET I=$ORDER(CONF("auth","protect","prefix",I)) QUIT:I=""  DO
	. . SET P=$GET(CONF("auth","protect","prefix",I))
	. . IF P'="",PATH?1P.E,($EXTRACT(PATH,1,$LENGTH(P))=P) SET T=1
	; default prefixes
	IF $EXTRACT(PATH,1,5)="/api/" QUIT 1
	IF $EXTRACT(PATH,1,7)="/ws/app" QUIT 1
	QUIT 0
	;
; Entry point
; See docs/routines for details.;
ISEXEMPT(PATH,CONF)
	NEW I,P,TEST
	IF $DATA(CONF("auth","exempt","prefix")) DO  QUIT TEST
	. SET TEST=0
	. SET I=""
	. FOR  SET I=$ORDER(CONF("auth","exempt","prefix",I)) QUIT:I=""  DO
	. . SET P=$GET(CONF("auth","exempt","prefix",I))
	. . IF P'="",($EXTRACT(PATH,1,$LENGTH(P))=P) SET TEST=1
	; defaults
	IF PATH="/healthz" QUIT 1
	IF PATH="/metrics" QUIT 1
	IF PATH="/bench" QUIT 1
	IF PATH="/api/ping" QUIT 1
	IF PATH="/app" QUIT 1
	IF PATH="/ws" QUIT 1
	QUIT 0
	;
; Entry point
; See docs/routines for details.;
KEYID(KEY)
	; short stable id, not reversible: simple 32-bit rolling hash
	NEW H SET H=2166136261
	NEW I FOR I=1:1:$LENGTH(KEY) DO
	. ;SET H=$$U32((H#C0FFFFFFFF)*16777619)
	. SET H=$$U32(H+$ASCII($EXTRACT(KEY,I)))
	QUIT $$HEX8(H)
	;
; Entry point
; See docs/routines for details.;
U32(N)
	; keep within 32-bit range
	QUIT (N#4294967296)
	;
; Entry point
; See docs/routines for details.;
HEX8(N)
	NEW HEX SET HEX="0123456789abcdef"
	NEW S SET S=""
	NEW X SET X=N
	NEW I FOR I=1:1:8 DO
	. SET S=$EXTRACT(HEX,(X#16)+1)_S
	. SET X=X\16
	QUIT S
	;
; Entry point
; See docs/routines for details.;
LOW(S)
	NEW X SET X=$GET(S)
	QUIT $TRANSLATE(X,"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")
	;
; Entry point
; See docs/routines for details.;
TRIM(S)
	NEW X SET X=$GET(S)
	FOR  QUIT:$EXTRACT(X,1)'=" "  SET X=$EXTRACT(X,2,999999)
	FOR  QUIT:$EXTRACT(X,$LENGTH(X))'=" "  SET X=$EXTRACT(X,1,$LENGTH(X)-1)
	QUIT X
	;
; Entry point
; See docs/routines for details.;
DENY(DEV,CONF,REQ,CTX,ECODE,REASON)
	NEW OBJ
	SET OBJ("routine")="MIOAUTH"
	SET OBJ("error")=ECODE
	SET OBJ("reason")=REASON
	SET OBJ("request_id")=$GET(CTX("request_id"))
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,401,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=401
	QUIT 0
	;