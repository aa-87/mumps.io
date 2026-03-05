MIOMW ; Standard middleware set (CORS/Auth/Access Log) for MIOROUTE pipeline.
;
; Purpose
;   Provide production-ready middleware functions compatible with the
;   MIOROUTE router-level middleware pipeline (ROI #8).
;
; Middleware entry points
;   CORSB(DEV,CONF,REQ,CTX,ERR)  ; before-hook (returns 1 continue, 0 stop)
;   CORSA(DEV,CONF,REQ,CTX,ERR)  ; after-hook  (best-effort restore)
;   AUTHB(DEV,CONF,REQ,CTX,ERR)  ; before-hook (enforce MIOAUTH)
;   LOGB (DEV,CONF,REQ,CTX,ERR)  ; before-hook (capture handler start)
;   LOGA (DEV,CONF,REQ,CTX,ERR)  ; after-hook  (compute metrics + access log)
;
; Wiring helper
;   STDWIRE(.CONF) sets CONF("server","middleware",...) lists to a practical
;   default ordering: CORS -> AUTH -> LOG start, then CORS restore -> LOG end.
;
; Config (recommended)
;
;   CORS:
;     CONF("server","cors","enabled")         default 0
;     CONF("server","cors","allowOrigin")      default "*" (or comma list)
;     CONF("server","cors","allowMethods")     default "GET,POST,PUT,PATCH,DELETE,OPTIONS"
;     CONF("server","cors","allowHeaders")     default "Content-Type,Authorization,X-Api-Key"
;     CONF("server","cors","exposeHeaders")    default "X-Request-Id"
;     CONF("server","cors","allowCredentials") default 0
;     CONF("server","cors","maxAge")           default 600
;     CONF("server","cors","vary")             default 1
;
; Notes
; - No ZSYSTEM.
; - MAXSTRING-safe (headers + small JSON only).
; - No GOTO.
; - All middleware rejections populate ERR("routine") and ERR("error").

	;
	;
ENSURE(CONF)
	; Install the default middleware lists only if none are configured.
	IF $DATA(CONF("server","middleware","before"))!$DATA(CONF("server","middleware","after")) QUIT
	DO STDWIRE(.CONF)
	QUIT

STDWIRE(CONF)
	KILL CONF("server","middleware")
	SET CONF("server","middleware","before",1)="CORSB^MIOMW"
	SET CONF("server","middleware","before",2)="AUTHB^MIOMW"
	SET CONF("server","middleware","before",3)="LOGB^MIOMW"
	SET CONF("server","middleware","after",1)="CORSA^MIOMW"
	SET CONF("server","middleware","after",2)="LOGA^MIOMW"
	QUIT

	;
	; ------------------------------
	; CORS middleware
	; ------------------------------
	;
CORSB(DEV,CONF,REQ,CTX,ERR)
	KILL ERR
	IF '+$GET(CONF("server","cors","enabled"),0) QUIT 1
	;
	NEW ORG SET ORG=$GET(REQ("hdr","origin"))
	; If no Origin header, treat as non-CORS (do nothing).
	IF ORG="" QUIT 1
	;
	NEW ACFG SET ACFG=$GET(CONF("server","cors","allowOrigin"),"*")
	NEW AO SET AO=$$ALLOWORIG(ORG,ACFG)
	; If origin not allowed, do not set any CORS headers, but do not block.
	IF AO="" QUIT 1
	;
	NEW CREDS SET CREDS=+$GET(CONF("server","cors","allowCredentials"),0)
	; Spec: if credentials are used, must echo origin (not '*').
	IF CREDS,ACFG="*" SET AO=ORG
	IF 'CREDS,ACFG="*" SET AO="*"
	;
	; Apply per-request default response headers (saved/restored by CORSA).
	DO DEFSET(.CONF,.CTX,"Access-Control-Allow-Origin",AO)
	IF CREDS DO DEFSET(.CONF,.CTX,"Access-Control-Allow-Credentials","true")
	NEW EXH SET EXH=$GET(CONF("server","cors","exposeHeaders"),"X-Request-Id")
	IF EXH'="" DO DEFSET(.CONF,.CTX,"Access-Control-Expose-Headers",EXH)
	IF +$GET(CONF("server","cors","vary"),1) DO DEFAPP(.CONF,.CTX,"Vary","Origin")
	;
	; Preflight handling (only when an OPTIONS route is matched)
	IF $GET(REQ("method"))="OPTIONS",$GET(REQ("hdr","access-control-request-method"))'="" DO  QUIT 0
	. NEW HEAD
	. SET HEAD("Content-Type")="text/plain"
	. SET HEAD("Access-Control-Allow-Origin")=AO
	. IF CREDS SET HEAD("Access-Control-Allow-Credentials")="true"
	. NEW AM SET AM=$GET(CONF("server","cors","allowMethods"),"GET,POST,PUT,PATCH,DELETE,OPTIONS")
	. SET HEAD("Access-Control-Allow-Methods")=AM
	. NEW AH SET AH=$GET(CONF("server","cors","allowHeaders"),"Content-Type,Authorization,X-Api-Key")
	. ; If allowHeaders is "*", echo requested headers when present.
	. IF AH="*",$GET(REQ("hdr","access-control-request-headers"))'="" SET AH=$GET(REQ("hdr","access-control-request-headers"))
	. SET HEAD("Access-Control-Allow-Headers")=AH
	. NEW MA SET MA=+$GET(CONF("server","cors","maxAge"),600)
	. IF MA>0 SET HEAD("Access-Control-Max-Age")=MA
	. IF +$GET(CONF("server","cors","vary"),1) SET HEAD("Vary")=$$VARYADD($GET(HEAD("Vary")),"Origin")
	. DO RESPX^MIOHTTP(.DEV,.CONF,204,.HEAD,"",$GET(CTX("request_id")),.CTX)
	. SET CTX("status")=204
	. ; Restore immediately (no after-hook runs when we stop before handler)
	. DO DEFREST(.CONF,.CTX,"cors")
	. SET ERR("routine")="MIOMW",ERR("error")="cors_preflight",ERR("status")=204
	QUIT 1

CORSA(DEV,CONF,REQ,CTX,ERR)
	; Restore any per-request defaults set by CORSB.
	DO DEFREST(.CONF,.CTX,"cors")
	QUIT

	;
	; ------------------------------
	; Auth middleware (wraps MIOAUTH)
	; ------------------------------
	;
AUTHB(DEV,CONF,REQ,CTX,ERR)
	KILL ERR
	NEW OK SET OK=$$ENFORCE^MIOAUTH(.DEV,.CONF,.REQ,.CTX)
	IF OK QUIT 1
	SET ERR("routine")="MIOAUTH"
	SET ERR("error")="unauthorized"
	SET ERR("status")=+$GET(CTX("status"),401)
	QUIT 0

	;
	; ------------------------------
	; Logging middleware (handler timing + access log)
	; ------------------------------
	;
LOGB(DEV,CONF,REQ,CTX,ERR)
	KILL ERR
	IF '+$GET(CONF("server","log","access","enabled"),0) QUIT 1
	; Capture handler start in microseconds
	SET CTX("mw","log","h0us")=$$TSUS^MIOMET()
	QUIT 1

LOGA(DEV,CONF,REQ,CTX,ERR)
	; Best-effort: do nothing unless access logging is enabled
	IF '+$GET(CONF("server","log","access","enabled"),0) QUIT
	NEW H0 SET H0=+$GET(CTX("mw","log","h0us"))
	NEW TEND SET TEND=$$TSUS^MIOMET()
	;
	; Bytes in/out (available after handler wrote response)
	SET CTX("bytes_in")=+$GET(REQ("body","len"),0)
	NEW BOUT SET BOUT=+$GET(^TMP($J,"MIOHTTP","RESP","bytes"))
	IF BOUT<1 SET BOUT=+$GET(^TMP($J,"MIOHTTP","STREAM","bytes"))
	SET CTX("bytes_out")=BOUT
	;
	; Timing metrics
	IF H0>0 SET CTX("met","handler_ms")=((TEND-H0)/1000)
	IF +$GET(CTX("t0us"))>0 SET CTX("met","total_ms")=((TEND-$GET(CTX("t0us")))/1000)
	IF $GET(CTX("met","parse_ms"))="",(H0>0),(+$GET(CTX("t0us"))>0) SET CTX("met","parse_ms")=((H0-$GET(CTX("t0us")))/1000)
	;
	; Emit access log line (buffered by default)
	NEW LERR,OKL SET OKL=$$ACCESS^MIOLOG(.CONF,.REQ,.CTX,.LERR)
	; Do not throw inside middleware
	QUIT

	;
	; ------------------------------
	; Helpers: per-request defaultResponseHeaders patching
	; ------------------------------
	;
DEFSET(CONF,CTX,KEY,VAL)
	; Save original defaultResponseHeaders values under CTX("mw","def",NS,...)
	NEW NS SET NS="cors"  ; namespace for restore
	IF '$DATA(CTX("mw","def",NS,"saved",KEY)) DO
	. NEW HAS SET HAS=$DATA(CONF("server","http","defaultResponseHeaders",KEY))
	. SET CTX("mw","def",NS,"saved",KEY,"has")=HAS
	. IF HAS SET CTX("mw","def",NS,"saved",KEY,"val")=$GET(CONF("server","http","defaultResponseHeaders",KEY))
	SET CONF("server","http","defaultResponseHeaders",KEY)=VAL
	QUIT

DEFAPP(CONF,CTX,KEY,ADD)
	NEW CUR SET CUR=$GET(CONF("server","http","defaultResponseHeaders",KEY))
	NEW NEWV SET NEWV=$$VARYADD(CUR,ADD)
	DO DEFSET(.CONF,.CTX,KEY,NEWV)
	QUIT

DEFREST(CONF,CTX,NS)
	NEW KEY SET KEY=""
	FOR  SET KEY=$ORDER(CTX("mw","def",NS,"saved",KEY)) QUIT:KEY=""  DO
	. NEW HAS SET HAS=+$GET(CTX("mw","def",NS,"saved",KEY,"has"))
	. IF HAS DO
	. . SET CONF("server","http","defaultResponseHeaders",KEY)=$GET(CTX("mw","def",NS,"saved",KEY,"val"))
	. ELSE  DO
	. . KILL CONF("server","http","defaultResponseHeaders",KEY)
	KILL CTX("mw","def",NS)
	QUIT

VARYADD(CUR,ADD)
	NEW V SET V=$GET(CUR)
	NEW A SET A=$GET(ADD)
	IF A="" QUIT V
	IF V="" QUIT A
	; Case-insensitive contains check on comma tokens
	NEW LCUR SET LCUR=$$LOW^MIOHTTP(V)
	NEW LADD SET LADD=$$LOW^MIOHTTP(A)
	IF (","_LCUR_",")[(","_LADD_",") QUIT V
	QUIT V_", "_A

ALLOWORIG(ORIGIN,ALLOW)
	NEW A SET A=$GET(ALLOW,"*")
	IF A="*" QUIT ORIGIN
	; Comma-separated exact matches
	NEW I,ONE,OK SET OK=0
	FOR I=1:1:$L(A,",") DO
	. SET ONE=$$TRIM^MIOHTTP($P(A,",",I))
	. IF ONE'="",ONE=ORIGIN SET OK=1
	IF OK QUIT ORIGIN
	QUIT ""
