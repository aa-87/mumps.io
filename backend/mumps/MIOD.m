MIOD ; Worker daemon. Accepts connections and runs request lifecycle.;
; API STABILITY
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; Purpose
; Worker daemon. Accepts connections and runs request lifecycle.;
;
; Responsibilities
; - Enforce request lifecycle.;
; - Keep work bounded.;
; - Fail safely.;
;
; Entry Points
; - START
; - WORKER
; - HANDLECONN
; - ISWSREQ
;
; Globals Used
; - ^MIO("MET",...)
;
; Notes
; Keep comments short.;
; Do not log secrets.;
;
	; Generated V1-01 (YottaDB)
	;
; Entry point
; See docs/routines for details.;
	;
T
	;			
	;
ST
	NEW PATH S PATH=$$GETCONF^MIOCONF()
	DO LOAD^MIOCONF(PATH,.CONF)	
	D START(.CONF)
	Q
	;
STERR
	ZSHOW "*":^AAA
	S ^AAA=$ZSTATUS
	Q
	;	
	;	
	;	
	;	
START(CONF)
	KILL ^MIO("CTL")
	NEW PORT SET PORT=$GET(CONF("server","listen","port"),9080)
	NEW DEV,ERR
	IF '$$LISTEN^MIOSOCK(PORT,.DEV,.ERR) DO PANIC^MIOLOG("listen_failed",.ERR) Q
	SET ^MIO("CTL","DEV")=DEV
	NEW W SET W=$GET(CONF("server","process","workers"),4)
	;NEW I FOR I=1:1:W H 0.1 JOB WORKER^MIOD(I,DEV)
	D WORKER^MIOD(1,DEV)
	DO INFO^MIOLOG("master_started","")
	FOR  DO  QUIT:$GET(^MIO("CTL","STOP"))
	. HANG 1
	SET ^MIO("CTL","STOP")=1
	HANG $GET(CONF("server","process","gracefulShutdownSeconds"),15)
	DO CLOSE^MIOSOCK(DEV)
	QUIT
	;
; Entry point
; See docs/routines for details.;
WORKER(ID,DEV)
	NEW CONF MERGE CONF=^MIO("CONF")
	NEW KEY
	FOR  QUIT:$GET(^MIO("CTL","STOP"))  DO
	. DO WAIT^MIOSOCK(DEV,1,.KEY)
	. IF KEY="" QUIT
	. I $P(KEY,"|")="CONNECT" D
	. . N HANDLE,ADDR
	. . S HANDLE=$PIECE(KEY,"|",2),ADDR=$PIECE(KEY,"|",3)
	. . U DEV:(detach=HANDLE)
	. . N Q S Q=""""
	. . N ARG S ARG=Q_"SOCKET:"_HANDLE_Q
	. . N J S J="JOBCONN(ADDR,HANDLE):(input="_ARG_":output="_ARG_")"
	. . J @J
	DO FLUSHJOB^MIOMET()
	QUIT
	;
	;
JOBCONN(ADDR,HANDLE)
	N CONF I $D(^MIO("CONF")) M CONF=^MIO("CONF")
	E  D
	. NEW PATH S PATH=$$GETCONF^MIOCONF()
	. DO LOAD^MIOCONF(PATH,.CONF)	
	. M ^MIO("CONF")=CONF
	S $ET="G STERR^MIOD"
	NEW CTX,REQ,ERR,DEV
	S DEV=$PRINCIPAL U DEV:(delim=$C(13,10))
	SET CTX("remote_addr")=ADDR
	FOR  DO  QUIT:$GET(^MIO("CTL","STOP"))
	. KILL REQ,ERR
	. SET CTX("request_id")=$$UUID^MIOUTIL()
	. NEW OK SET OK=$$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	. IF 'OK QUIT
	. ; If this is a WebSocket Upgrade request, route under method "WS".;
	. ; This allows registering WS endpoints without colliding with normal GET routes.;
	. IF $$ISWSREQ(.REQ) DO
	. . SET CTX("is_websocket")=1
	. . SET REQ("http_method")=$GET(REQ("method"))
	. . SET REQ("method")="WS"
	. . ;
	. SET CTX("t0us")=$$TSUS^MIOMET()
	. KILL CTX("status"),CTX("route"),CTX("skip_metrics")
	. ; Pre-match route (enables per-route authz without double parse)
	. ; 
	. ;
	. DO PREMATCH^MIOROUTE(.REQ,.CTX)
	. ; Authentication / authorization gate (config-driven)
	. ;
	. IF '$$ENFORCE^MIOAUTH(DEV,.CONF,.REQ,.CTX) QUIT
	. ;
	. DO DISPATCH^MIOROUTE(DEV,.CONF,.REQ,.CTX)
	. ;
	. ; Metrics observation (skip if handler requested)
	. IF '$GET(CTX("skip_metrics")) DO
	. . NEW T1 SET T1=$$TSUS^MIOMET()
	. . NEW LATMS SET LATMS=((T1-$GET(CTX("t0us")))/1000)
	. . NEW RT SET RT=$GET(CTX("route"),"unknown")
	. . NEW ST SET ST=$GET(CTX("status"),0)
	. . NEW MM SET MM=$GET(REQ("http_method"),$GET(REQ("method")))
	. . DO OBS^MIOMET(MM,RT,ST,LATMS)
	. IF $$LOW^MIOHTTP($GET(REQ("hdr","connection")))="close" QUIT
	C DEV
	QUIT
	;	
	;	
	;	
LOOP
	I $G(^MIO(":WS","JOB:STATUS"))="stopped" C TCPIO  Q
	D  G LOOP
	. F  W /WAIT(10) Q:$KEY]""  Q:($G(^MIO(":WS","JOB:STATUS"))="stopped")
	. Q:($G(^MIO(":WS","JOB:STATUS"))="stopped")
	. I $P($KEY,"|")="CONNECT" D
	. . S CHILDSOCK=$P($KEY,"|",2)
	. . U TCPIO:(detach=CHILDSOCK)
	. . N Q S Q=""""
	. . N ARG S ARG=Q_"SOCKET:"_CHILDSOCK_Q
	. . N J S J="CHILD($G(TLSCONFIG),$G(NOGBL)):(input="_ARG_":output="_ARG_")"
	. . J @J
	QUIT	
	;	
; Entry point
; See docs/routines for details.;
HANDLECONN(DEV,HANDLE,ADDR,CONF)
	NEW CTX,REQ,ERR
	SET CTX("remote_addr")=ADDR
	DO SETSOCK^MIOSOCK(DEV,HANDLE)
	FOR  DO  QUIT:$GET(^MIO("CTL","STOP"))
	. KILL REQ,ERR
	. SET CTX("request_id")=$$UUID^MIOUTIL()
	. NEW OK SET OK=$$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	. IF 'OK QUIT
	. ; If this is a WebSocket Upgrade request, route under method "WS".;
	. ; This allows registering WS endpoints without colliding with normal GET routes.;
	. IF $$ISWSREQ(.REQ) DO
	. . SET CTX("is_websocket")=1
	. . SET REQ("http_method")=$GET(REQ("method"))
	. . SET REQ("method")="WS"
	. SET CTX("t0us")=$$TSUS^MIOMET()
	. KILL CTX("status"),CTX("route"),CTX("skip_metrics")
	. ; Pre-match route (enables per-route authz without double parse)
	. DO PREMATCH^MIOROUTE(.REQ,.CTX)
	. ; Authentication / authorization gate (config-driven)
	. IF '$$ENFORCE^MIOAUTH(DEV,.CONF,.REQ,.CTX) QUIT
	. DO DISPATCH^MIOROUTE(DEV,.CONF,.REQ,.CTX)
	. ; Metrics observation (skip if handler requested)
	. IF '$GET(CTX("skip_metrics")) DO
	. . NEW T1 SET T1=$$TSUS^MIOMET()
	. . NEW LATMS SET LATMS=((T1-$GET(CTX("t0us")))/1000)
	. . NEW RT SET RT=$GET(CTX("route"),"unknown")
	. . NEW ST SET ST=$GET(CTX("status"),0)
	. . NEW MM SET MM=$GET(REQ("http_method"),$GET(REQ("method")))
	. . DO OBS^MIOMET(MM,RT,ST,LATMS)
	. IF $$LOW^MIOHTTP($GET(REQ("hdr","connection")))="close" QUIT
	QUIT
	;
; Entry point
; See docs/routines for details.;
ISWSREQ(REQ)
	; Detect RFC6455 Upgrade request.;
	NEW UP SET UP=$$LOW^MIOHTTP($GET(REQ("hdr","upgrade")))
	IF UP'="websocket" QUIT 0
	NEW CON SET CON=$$LOW^MIOHTTP($GET(REQ("hdr","connection")))
	IF CON'["upgrade" QUIT 0
	QUIT 1
	;