MIODOS ; Connection-level DoS hardening (caps + lifetime).;
;
; Purpose
; Enforce deterministic, low-overhead per-connection limits to reduce DoS risk.;
;
; Features
; - Global active-connection cap using ^MIO("DOS","active") (atomic $INCREMENT).;
; - Optional maximum connection lifetime (seconds) using microsecond clock from MIOMET.;
;
; Config
; CONF("server","dos","maxActiveConns")   default 200 (min 1)
; CONF("server","dos","maxConnSeconds")    default 0 (disabled)
;
; Conventions
; Errors include ERR("routine") and ERR("error"). ERR("status") set when relevant.;
;
; Public entry points
; - $$CONNOPEN(.CONF,.CTX,.ERR)
; - DO CONNCLOSE(.CTX)
; - $$CONNEXPIRED(.CONF,.CTX)
; - $$ACTIVE()
;
	; ROI #11 (connection-level hardening)
	;
	;
CONNOPEN(CONF,CTX,ERR) ; Admit a connection (active cap). Returns 1/0.;
	KILL ERR
	NEW MAX SET MAX=+$GET(CONF("server","dos","maxActiveConns"),200)
	IF MAX<1 SET MAX=1
	NEW A SET A=$INCREMENT(^MIO("DOS","active"))
	IF A>MAX DO  QUIT 0
	. IF $INCREMENT(^MIO("DOS","active"),-1)
	. SET ERR("routine")="MIODOS",ERR("error")="too_many_connections",ERR("status")=503
	; Track per-job admission for crash-safe cleanup
	SET ^MIO("DOS","job",$J)=1
	SET CTX("dos","active")=1
	SET CTX("dos","conn_t0us")=$$TSUS^MIOMET()
	QUIT 1
	;
CONNCLOSE(CTX) ; Release a connection admission slot.;
	; Prefer per-job marker to avoid double-decrement and to work from traps.;
	IF $DATA(^MIO("DOS","job",$J)) DO
	. KILL ^MIO("DOS","job",$J)
	. IF $INCREMENT(^MIO("DOS","active"),-1)
	KILL CTX("dos","active")
	QUIT
	;
CONNEXPIRED(CONF,CTX) ; Returns 1 if connection lifetime exceeded.;
	NEW MAXS SET MAXS=+$GET(CONF("server","dos","maxConnSeconds"),0)
	IF MAXS'>0 QUIT 0
	NEW T0 SET T0=+$GET(CTX("dos","conn_t0us"))
	IF T0'>0 QUIT 0
	NEW NOW SET NOW=$$TSUS^MIOMET()
	IF (NOW-T0)>(MAXS*1000000) QUIT 1
	QUIT 0
	;
ACTIVE() ; Current active connection count (best effort).;
	QUIT +$GET(^MIO("DOS","active"),0)
	;