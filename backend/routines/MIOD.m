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
	K  U 0 G DEVWATCH
	Q
	;
DEVWATCH
	;
	;
	Q
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
	. . N J S J="JOBCONN(ADDR,HANDLE)"
	; Connection worker. Handles HTTP/1.x keep-alive lifecycle.;
	; DEV is a MIOSOCK detached handle device (read+write).;
	;
	NEW CONF MERGE CONF=^MIO("CONF")
	SET $ET="G STERR^MIOD"
	NEW DEV SET DEV=$PRINCIPAL
	USE DEV:(delim=$C(13,10))
	NEW CTX,REQ,ERR
	SET CTX("remote_addr")=$GET(ADDR)
	;
	; Keep-alive policy
	NEW KAEN SET KAEN=+$GET(CONF("server","keepAlive","enabled"),1)
	NEW KAMAX SET KAMAX=+$GET(CONF("server","keepAlive","maxRequests"),100)
	IF KAMAX<1 SET KAMAX=1
	NEW KATMO SET KATMO=+$GET(CONF("server","keepAlive","idleSeconds"),10)
	IF KATMO<1 SET KATMO=1
	;
	NEW ORIGTOH SET ORIGTOH=$GET(CONF("server","timeouts","readHeaderMs"),2)
	NEW ORIGTOB SET ORIGTOB=$GET(CONF("server","timeouts","readBodyMs"),3)
	;
	NEW NREQ SET NREQ=0
	NEW DONE SET DONE=0
	FOR  QUIT:DONE  DO  QUIT:$GET(DONE)
	. ; For the first request, use normal timeouts.;
	. ; For subsequent requests, use keep-alive idle timeout for header reads.;
	. IF NREQ>0 DO
	. . SET CONF("server","timeouts","readHeaderMs")=KATMO
	. . SET CONF("server","timeouts","readBodyMs")=ORIGTOB
	. ELSE  DO
	. . SET CONF("server","timeouts","readHeaderMs")=ORIGTOH
	. . SET CONF("server","timeouts","readBodyMs")=ORIGTOB
	. ;
	. KILL REQ,ERR
	. SET CTX("request_id")=$$UUID^MIOUTIL()
	. SET CTX("t0us")=$$TSUS^MIOMET()
	. KILL CTX("status"),CTX("route"),CTX("skip_metrics"),CTX("match"),CTX("is_websocket")
	. ;
	. NEW OK SET OK=$$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	. IF 'OK DO  QUIT
	. . ; Treat keep-alive idle timeout as a clean close (after at least one request).;
	. . IF NREQ>0,$GET(ERR("error"))="read_timeout" SET DONE=1 QUIT
	. . ; Otherwise close hard.;
	. . SET DONE=1
	. ;
	. SET NREQ=NREQ+1
	. ;
	. ; If this is a WebSocket Upgrade request, route under method "WS".;
	. IF $$ISWSREQ(.REQ) DO
	. . SET CTX("is_websocket")=1
	. . SET REQ("http_method")=$GET(REQ("method"))
	. . SET REQ("method")="WS"
	. ;
	. ; Decide connection persistence for THIS response.;
	. NEW KEEP SET KEEP=$$KASHOULD(.CONF,.REQ,NREQ,KAEN,KAMAX)
	. SET CONF("server","http","defaultResponseHeaders","Connection")=$$KACONN(.REQ,KEEP)
	. ;
	. ; Pre-match route (enables per-route authz without double parse)
	. DO PREMATCH^MIOROUTE(.REQ,.CTX)
	. ;
	. ; Authentication / authorization gate (config-driven)
	. IF '$$ENFORCE^MIOAUTH(DEV,.CONF,.REQ,.CTX) DO  QUIT
	. . NEW OBJ,HEAD,BODY
	. . SET HEAD("Content-Type")="application/json"
	. . SET HEAD("Connection")="close"
	. . SET OBJ("error")="unauthorized",OBJ("request_id")=$GET(CTX("request_id"))
	. . SET BODY=$$EN^MIOJSON1(.OBJ)
	. . DO RESPX^MIOHTTP(.DEV,.CONF,401,.HEAD,BODY,$GET(CTX("request_id")),.CTX)
	. . SET CTX("status")=401,CTX("route")="(unauthorized)"
	. . SET DONE=1
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
	. ;
	. ; Free request body storage each request
	. DO BODYFREE^MIOHTTP(.REQ)
	. ;
	. ; WebSocket handler owns the connection lifecycle.;
	. IF $GET(CTX("is_websocket")) SET DONE=1 QUIT
	. ;
	. ; If not keeping the connection, stop after this response.;
	. IF 'KEEP SET DONE=1
	;
	; Restore defaults (best effort)
	SET CONF("server","timeouts","readHeaderMs")=ORIGTOH
	SET CONF("server","timeouts","readBodyMs")=ORIGTOB
	DO CLOSE^MIOSOCK(DEV)
	QUIT
	;
; Keep-alive decision: returns 1 to keep, 0 to close after this request.;
KASHOULD(CONF,REQ,NREQ,KAEN,KAMAX)
	IF 'KAEN QUIT 0
	IF NREQ'<KAMAX QUIT 0
	; Request may force close.;
	IF $$KAREQWANTS($GET(REQ("httpver")),$GET(REQ("hdr","connection"))) QUIT 0
	; Otherwise, keep if protocol allows.;
	QUIT $$KAPROTO($GET(REQ("httpver")),$GET(REQ("hdr","connection")))
	;
; Map KEEP decision to response header value.;
KACONN(REQ,KEEP)
	IF 'KEEP QUIT "close"
	; HTTP/1.0 clients need explicit keep-alive.;
	IF $$LOW^MIOHTTP($GET(REQ("httpver")))="http/1.0" QUIT "keep-alive"
	QUIT "keep-alive"
	;
; Does the request explicitly require close?
KAREQWANTS(HTTPVER,CONN)
	NEW C SET C=$$LOW^MIOHTTP($GET(CONN))
	IF C["close" QUIT 1
	QUIT 0
	;
; Protocol default keep-alive behavior for a request.;
KAPROTO(HTTPVER,CONN)
	NEW V SET V=$$LOW^MIOHTTP($GET(HTTPVER))
	NEW C SET C=$$LOW^MIOHTTP($GET(CONN))
	IF V="http/1.1" QUIT 1
	IF V="http/1.0" QUIT $SELECT(C["keep-alive":1,1:0)
	; Unknown version -> be conservative.;
	QUIT 0
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