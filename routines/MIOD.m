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
START(CONF,PORT)
	NEW ZJ S ZJ=0 S PORT=$G(PORT)
	I 'PORT SET PORT=$GET(CONF("server","listen","port"),8083)
	D INFO^MIOLOG("mio_server_started","")
	J RUN(PORT) 
	S ZJ=$ZJOB H 2 I ZJ D:$D(^MIO("CTL",ZJ)) INFO^MIOLOG("listen_success","port=["_PORT_"] pid=["_ZJ_"]")
	Q
	;
RUN(PORT)
	NEW DEV,ERR
	IF '$$LISTEN^MIOSOCK(PORT,.DEV,.ERR) DO PANIC^MIOLOG("listen_failed",.ERR) Q
	KILL ^MIO("CTL",$J)
	ZKILL ^MIO("CTL")
	SET ^MIO("CTL",$J,"DEV")=DEV
	SET ^MIO("CTL",$J,"PID")=$J
	SET ^MIO("CTL",$J,"PORT")=PORT
	;	
	;	
	W /LISTEN(5) NEW KEY FOR  QUIT:+$G(^MIO("CTL",$J,"STOP"))!($G(^MIO("CTL"))="STOP")  DO
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
	S ^MIO("CTL")="STOP"
	N P S P="" F  S P=$O(^MIO("CTL",P)) Q:P=""  S ^MIO("CTL",P,"STOP")=1
	N DEV,P S P="" F  S P=$O(^MIO("CTL",P)) Q:P=""  I P'="STOP" S DEV=^MIO("CTL",P,"DEV")  D
	. I DEV]"" H $G(^MIO("CONF","server","process","gracefulShutdownSeconds"),1) D CLOSE^MIOSOCK(DEV) I $T D
	. . D INFO^MIOLOG("listen_device_closed,","port=["_^MIO("CTL",P,"PORT")_"] pid=["_P_"]")
	. . K ^MIO("CTL",P) 
	D INFO^MIOLOG("mio_server_stopped","")
	QUIT
	;
JOBCONN(ADDR,HANDLE)
	NEW CONF MERGE CONF=^MIO("CONF")
	; Ensure router middleware pipeline is configured (CORS/Auth/AccessLog defaults)
	DO ENSURE^MIOMW(.CONF)
	SET $ET="G STERR^MIOD"
	NEW DEV SET DEV=$PRINCIPAL
	USE DEV:(delim=$C(13,10))
	NEW CTX,REQ,ERR
	SET CTX("remote_addr")=$GET(ADDR)
	;
	; Access log (ROI #1)
	NEW LOGEN SET LOGEN=+$GET(CONF("server","log","access","enabled"),0)
	; Metrics (ROI #1)
	NEW METEN SET METEN=$$EN^MIOMET(.CONF)
	; Rate limiting (ROI #6)
	NEW RLEN SET RLEN=+$GET(CONF("server","rate","enabled"),0)
		; Error Center (ROI B)
	NEW ERREN SET ERREN=$$EN^MIOERRC(.CONF)
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
	FOR  DO  QUIT:$GET(DONE)
	. ; For the first request, use normal timeouts.;
	. ; For subsequent requests, use keep-alive idle timeout for header reads.;
	. IF DONE QUIT
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
	. KILL CTX("status"),CTX("route"),CTX("skip_metrics"),CTX("match"),CTX("is_websocket"),CTX("bytes_in"),CTX("bytes_out"),CTX("error"),CTX("met")
	. ;
	. KILL ^TMP($J,"MIOHTTP","RESP"),^TMP($J,"MIOHTTP","STREAM")
	. ;
	. ;
	. NEW TPARSE SET TPARSE="" 
	. NEW OK SET OK=$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR),OK=$$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	. IF METEN!LOGEN SET TPARSE=$$TSUS^MIOMET(),CTX("met","parse_ms")=((TPARSE-$GET(CTX("t0us")))/1000)
	. IF 'OK DO  QUIT
	. . ; Access log parse failures (best effort)
	. . IF METEN!LOGEN DO
	. . . SET CTX("status")=$$STATUS4ERR^MIOHTTP(.ERR)
	. . . SET CTX("route")="(parse_error)"
	. . . SET CTX("error")=$GET(ERR("error"))
	. . . SET CTX("bytes_in")=0,CTX("bytes_out")=0
	. . . IF TPARSE="" SET TPARSE=$$TSUS^MIOMET()
	. . . SET CTX("met","parse_ms")=((TPARSE-$GET(CTX("t0us")))/1000)
	. . . SET CTX("met","handler_ms")=0
	. . . SET CTX("met","total_ms")=$GET(CTX("met","parse_ms"))
	. . . ; Metrics + access log
	. . . IF METEN DO OBSX^MIOMET($GET(REQ("method")),"(parse_error)",+$GET(CTX("status")),+$GET(CTX("met","total_ms")),+$GET(CTX("met","parse_ms")),0,0,0,$GET(CTX("error")))
	. . . IF LOGEN NEW LERR,OKL SET OKL=$$ACCESS^MIOLOG(.CONF,.REQ,.CTX,.LERR)
	. . IF ERREN DO PUSH^MIOERRC(.CONF,.REQ,.CTX,.ERR,"parse")
	. . ; Treat keep-alive idle timeout as a clean close (after at least one request).;
	. . IF NREQ>0,$GET(ERR("error"))="read_timeout" SET DONE=1 QUIT
	. . ; Otherwise close hard.;
	. . SET DONE=1
	. ;
	. SET NREQ=NREQ+1
	. ; Rate limiting (per-IP token bucket)
	. IF RLEN DO  QUIT:$GET(DONE)
	. . NEW RERR,OKR SET OKR=$$ALLOW^MIORATE(.CONF,.CTX,.REQ,.RERR)
	. . IF OKR QUIT
	. . ; Respond 429 and close (do not dispatch handlers)
	. . NEW OBJ,HEAD,BODY
	. . SET HEAD("Content-Type")="application/json"
	. . SET HEAD("Connection")="close"
	. . SET HEAD("Retry-After")=$GET(RERR("retry_after"),"1")
	. . SET OBJ("ok")=0
	. . SET OBJ("error")=$GET(RERR("error"),"rate_limited")
	. . SET OBJ("routine")=$GET(RERR("routine"),"MIORATE")
	. . SET OBJ("request_id")=$GET(CTX("request_id"))
	. . SET BODY=$$EN^MIOJSON1(.OBJ)
	. . DO RESPX^MIOHTTP(.DEV,.CONF,429,.HEAD,BODY,$GET(CTX("request_id")),.CTX)
	. . SET CTX("status")=429,CTX("route")="(rate_limited)",CTX("error")=$GET(RERR("error"))
	. . ; Metrics + access log for rate-limited responses (best effort)
	. . NEW TRL SET TRL=$$TSUS^MIOMET()
	. . SET CTX("bytes_in")=+$GET(REQ("body","len"),0)
	. . NEW BOUT SET BOUT=+$GET(^TMP($J,"MIOHTTP","RESP","bytes"))
	. . SET CTX("bytes_out")=BOUT
	. . SET CTX("met","handler_ms")=0
	. . SET CTX("met","total_ms")=((TRL-$GET(CTX("t0us")))/1000)
	. . IF METEN DO OBSX^MIOMET($GET(REQ("method")),"(rate_limited)",429,+$GET(CTX("met","total_ms")),+$GET(CTX("met","parse_ms")),0,+$GET(CTX("bytes_in")),+BOUT,$GET(CTX("error")))
	. . IF LOGEN NEW LERR,OKL SET OKL=$$ACCESS^MIOLOG(.CONF,.REQ,.CTX,.LERR)
	. . IF ERREN DO PUSH^MIOERRC(.CONF,.REQ,.CTX,.RERR,"rate")
	. . ; Free request body storage
	. . DO BODYFREE^MIOHTTP(.REQ)
	. . SET DONE=1
	. ;
	. ; If this is a WebSocket Upgrade request, route under method "WS".;
	. IF '$GET(DONE),$$ISWSREQ(.REQ) DO  QUIT
	. . SET CTX("is_websocket")=1
	. . SET REQ("http_method")=$GET(REQ("method"))
	. . SET REQ("method")="WS"
	. . DO ACCEPT^MIOWS(DEV,.CONF,.REQ,.CTX)
	. . S DONE=1
	. ; Decide connection persistence for THIS response.;
	. NEW KEEP SET KEEP=$$KASHOULD(.CONF,.REQ,NREQ,KAEN,KAMAX)
	. SET CONF("server","http","defaultResponseHeaders","Connection")=$$KACONN(.REQ,KEEP)
	. ;
	. ; Pre-match route (enables per-route authz without double parse)
	. DO PREMATCH^MIOROUTE(.REQ,.CTX)
	. ;
	. ; Auth is enforced via MIOROUTE middleware (MIOMW AUTHB) when enabled.;
	. ;
	. DO DISPATCH^MIOROUTE(DEV,.CONF,.REQ,.CTX)
	. ;
	. NEW TEND SET TEND=""
	. IF METEN!LOGEN,'$GET(CTX("skip_metrics")) SET TEND=$$TSUS^MIOMET()
	. ;
	. ; Metrics observation (skip if handler requested)
	. IF METEN,'$GET(CTX("skip_metrics")) DO
	. . NEW LATMS SET LATMS=((TEND-$GET(CTX("t0us")))/1000)
	. . NEW RT SET RT=$GET(CTX("route"),"unknown")
	. . NEW ST SET ST=$GET(CTX("status"),0)
	. . NEW MM SET MM=$GET(REQ("http_method"),$GET(REQ("method")))
	. . ; Compute bytes in/out once per request
	. . SET CTX("bytes_in")=+$GET(REQ("body","len"),0)
	. . NEW BOUT SET BOUT=+$GET(^TMP($J,"MIOHTTP","RESP","bytes"))
	. . IF BOUT<1 SET BOUT=+$GET(^TMP($J,"MIOHTTP","STREAM","bytes"))
	. . SET CTX("bytes_out")=BOUT
	. . ; Compute handler_ms if router captured h0/h1
	. . IF $GET(CTX("met","handler_ms"))="",+$GET(CTX("met","h0us"))>0,+$GET(CTX("met","h1us"))'>+$GET(CTX("met","h0us")) DO
	. . . SET CTX("met","handler_ms")=((CTX("met","h1us")-CTX("met","h0us"))/1000)
	. . ; Ensure parse_ms exists
	. . IF $GET(CTX("met","parse_ms"))="",TPARSE'="" SET CTX("met","parse_ms")=((TPARSE-$GET(CTX("t0us")))/1000)
	. . SET CTX("met","total_ms")=LATMS
	. . IF $GET(CTX("error"))="" SET CTX("error")=$GET(CTX("err","error"))
	. . DO OBSX^MIOMET(MM,RT,ST,LATMS,+$GET(CTX("met","parse_ms")),+$GET(CTX("met","handler_ms")),+$GET(CTX("bytes_in")),+BOUT,$GET(CTX("error")))
	. ;
	. ; Access log for normal requests is emitted by router middleware (MIOMW LOGA).;
	. ; Error Center capture (best effort)
	. IF ERREN DO CAPREQ^MIOERRC(.CONF,.REQ,.CTX)
	. ; Free request body storage each request
	. DO BODYFREE^MIOHTTP(.REQ)
	. ;
	. ; If not keeping the connection, stop after this response.;
	. IF 'KEEP SET DONE=1
	;
	DO CLOSE^MIOSOCK(DEV)
	QUIT
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