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
STERR
	ZSHOW "*":^AAA
	S ^AAA=$ZSTATUS
	Q
	;
START(CONF)
	KILL ^MIO("CTL")
	NEW PORT,ZJ S ZJ=0
	SET PORT=$GET(CONF("server","listen","port"),9080)
	J RUN(PORT) I $T S ZJ=$ZJOB D INFO^MIOLOG("mio_server_started","pid="_ZJ) I 1
	E  D PANIC^MIOLOG("mio_server_failed","")
	H 2 I $G(^MIO("CTL","PID"))=ZJ D INFO^MIOLOG("listen_success","port="_PORT)
	Q
	;
RUN(PORT)
	NEW DEV,ERR
	IF '$$LISTEN^MIOSOCK(PORT,.DEV,.ERR) DO PANIC^MIOLOG("listen_failed",.ERR) Q
	SET ^MIO("CTL","DEV")=DEV
	SET ^MIO("CTL","PID")=$J
	W /LISTEN(5) NEW KEY FOR  QUIT:$GET(^MIO("CTL","STOP"))  DO
	. DO WAIT^MIOSOCK(DEV,10,.KEY)
	. IF KEY="" QUIT
	. I $P(KEY,"|")="CONNECT" D
	. . N HANDLE,ADDR
	. . S HANDLE=$PIECE(KEY,"|",2),ADDR=$PIECE(KEY,"|",3)
	. . U DEV:(detach=HANDLE)
	. . N Q S Q=""""
	. . N ARG S ARG=Q_"SOCKET:"_HANDLE_Q
	. . N J S J="JOBCONN(ADDR,HANDLE):(input="_ARG_":output="_ARG_")"
	. . J @J
	QUIT
	;
STOP ; to do -> make sure to kill the pid associated after checking
	S ^MIO("CTL","STOP")=1
	N DEV S DEV=$G(^MIO("CTL","DEV"))
	H $GET(^MIO("CONF","server","process","gracefulShutdownSeconds"),3)
	I DEV]"" I 1 D CLOSE^MIOSOCK(DEV) D:$T INFO^MIOLOG("listen_device_closed","")
	D INFO^MIOLOG("mio_server_stopped","")
	QUIT
	;
JOBCONN(ADDR,HANDLE)
	N CONF M CONF=^MIO("CONF")
	S $ET="G STERR^MIOD"
	NEW CTX,REQ,ERR,DEV
	S DEV=$PRINCIPAL U DEV:(delim=$C(13,10))
	SET CTX("remote_addr")=ADDR
	KILL REQ,ERR SET CTX("request_id")=$$UUID^MIOUTIL()
	NEW OK SET OK=$$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	IF 'OK DO CLOSE^MIOSOCK(DEV) QUIT
	; If this is a WebSocket Upgrade request, route under method "WS".;
	; This allows registering WS endpoints without colliding with normal GET routes.;
	IF $$ISWSREQ(.REQ) DO
	. SET CTX("is_websocket")=1
	. SET REQ("http_method")=$GET(REQ("method"))
	. SET REQ("method")="WS"
	SET CTX("t0us")=$$TSUS^MIOMET()
	KILL CTX("status"),CTX("route"),CTX("skip_metrics")
	; Pre-match route (enables per-route authz without double parse)
	DO PREMATCH^MIOROUTE(.REQ,.CTX)
	; Authentication / authorization gate (config-driven)
	IF '$$ENFORCE^MIOAUTH(DEV,.CONF,.REQ,.CTX) D  Q
	. NEW OBJ SET OBJ("error")="unauthorized",OBJ("request_id")=$GET(CTX("request_id"))
	. DO RESPJSONX^MIOHTTP(.DEV,.CONF,401,.OBJ,$GET(CTX("request_id")),.CTX)
	. SET CTX("status")=401,CTX("route")="(unauthorized)"
	. DO CLOSE^MIOSOCK(DEV) Q
	DO DISPATCH^MIOROUTE(DEV,.CONF,.REQ,.CTX)
	; Metrics observation (skip if handler requested)
	IF '$GET(CTX("skip_metrics")) DO
	. NEW T1 SET T1=$$TSUS^MIOMET()
	. NEW LATMS SET LATMS=((T1-$GET(CTX("t0us")))/1000)
	. NEW RT SET RT=$GET(CTX("route"),"unknown")
	. NEW ST SET ST=$GET(CTX("status"),0)
	. NEW MM SET MM=$GET(REQ("http_method"),$GET(REQ("method")))
	. DO OBS^MIOMET(MM,RT,ST,LATMS)
	DO CLOSE^MIOSOCK(DEV)
	IF $$LOW^MIOHTTP($GET(REQ("hdr","connection")))="close" H
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