MIODRAIN ; Graceful shutdown + draining helpers (globals-only, deterministic).;
;
; Public entry points:
;   REQSTOP(CONF,REASON)   - request drain + set deadline
;   ISDRAIN()              - 1 if draining requested
;   REJECTNEW(CONN0US)     - 1 if draining and connection started after drain began
;   BEGIN(CONF,ADDR,HANDLE,CONN0US) - register active connection/job
;   END(JOB)               - unregister job
;   ETRAP(JOB)             - best-effort unregister on crash
;   ACTIVE()               - active conn count
;   WAITDRAIN(SEC)         - wait up to SEC seconds for ACTIVE() to reach 0
;   RESET                  - test helper (clears drain/conn state)
;
; Notes:
; - No ZSYSTEM.;
; - Uses ^MIO("CTL",...) to match existing MIOD conventions.;
;
REQSTOP(CONF,REASON)
	NEW GS,T0,DL
	SET ^MIO("CTL","DRAIN")=1
	SET ^MIO("CTL","DRAIN","reason")=$GET(REASON,"stop")
	SET T0=$$TSUS^MIOMET()
	SET ^MIO("CTL","DRAIN","t0us")=T0
	SET GS=+$GET(CONF("server","process","gracefulShutdownSeconds"),3)
	IF GS<0 SET GS=0
	SET DL=T0+(GS*1000000)
	SET ^MIO("CTL","DRAIN","deadline_us")=DL
	QUIT
	;
ISDRAIN()
	QUIT +$GET(^MIO("CTL","DRAIN"),0)
	;
REJECTNEW(CONN0US)
	NEW T0
	IF '$$ISDRAIN() QUIT 0
	SET T0=+$GET(^MIO("CTL","DRAIN","t0us"),0)
	IF T0<1 QUIT 1  ; conservative
	QUIT $SELECT(+$GET(CONN0US)>=T0:1,1:0)
	;
BEGIN(CONF,ADDR,HANDLE,CONN0US)
	NEW J SET J=$J
	; idempotent: if already registered, do nothing
	IF $GET(^MIO("CTL","CONN","job",J))=1 QUIT
	SET ^MIO("CTL","CONN","job",J)=1
	SET ^MIO("CTL","CONN","job",J,"addr")=$GET(ADDR)
	SET ^MIO("CTL","CONN","job",J,"handle")=$GET(HANDLE)
	SET ^MIO("CTL","CONN","job",J,"t0us")=+$GET(CONN0US)
	NEW A SET A=$INCREMENT(^MIO("CTL","CONN","active"))
	QUIT
	;
END(JOB)
	NEW J SET J=+$GET(JOB,$J)
	IF $GET(^MIO("CTL","CONN","job",J))'=1 QUIT
	KILL ^MIO("CTL","CONN","job",J)
	NEW A SET A=$INCREMENT(^MIO("CTL","CONN","active"),-1)
	IF A<0 SET ^MIO("CTL","CONN","active")=0
	QUIT
	;
ETRAP(JOB)
	DO END($GET(JOB,$J))
	QUIT
	;
ACTIVE()
	NEW A SET A=+$GET(^MIO("CTL","CONN","active"),0)
	IF A<0 SET A=0
	QUIT A
	;
WAITDRAIN(SEC)
	NEW S,DL,OK
	SET S=+$GET(SEC,0) IF S<0 SET S=0
	SET DL=$$TSUS^MIOMET()+(S*1000000)
	SET OK=0
	DO  ;QUIT:OK 
	. IF $$ACTIVE()=0 SET OK=1 QUIT
	. IF $$TSUS^MIOMET()>=DL SET OK=0 QUIT
	. HANG 1
	QUIT OK
	;
RESET ; test helper
	KILL ^MIO("CTL","DRAIN")
	KILL ^MIO("CTL","CONN")
	QUIT
	;
	;