MIOWS ; WebSocket protocol handler (RFC 6455).;
; API STABILITY
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; Purpose
; WebSocket protocol handler (RFC 6455).;
;
; Responsibilities
; - Enforce request lifecycle.;
; - Keep work bounded.;
; - Fail safely.;
;
; Entry Points
; - ACCEPT
; - ACCEPTKEY
; - FAIL
; - LOOP
; - HANDLEMSG
; - READFRAME
; - UNMASK
; - SENDTEXT
; - SENDPONG
; - SENDCLOSE
; - SENDFRAME
; - WRITETXT
; - INITSTATE
; - READMSG
;
; Globals Used
; - ^MIO("MET",...)
;
; Notes
; Keep comments short.;
; Do not log secrets.;
;
	;
	; Handshake + frame loop.;
	; Supports full fragmentation reassembly for text/binary messages.;
	; Control frames (close/ping/pong) may appear interleaved.;
	;
	; Entry:
	;   DO ACCEPT^MIOWS(DEV,.CONF,.REQ,.CTX)
	;
; Entry point
; See docs/routines for details.;
ACCEPT(DEV,CONF,REQ,CTX)
	NEW KEY SET KEY=$GET(REQ("hdr","sec-websocket-key"))
	IF KEY="" DO FAIL(.DEV,.CONF,.CTX,"missing_sec_websocket_key") QUIT
	NEW ACC S ACC=$$WSACCEPT^MIOSHA1(KEY) S ^AHM("ACC")=ACC
	NEW HEAD
	SET HEAD("Upgrade")="websocket"
	SET HEAD("Connection")="Upgrade"
	SET HEAD("Sec-WebSocket-Accept")=ACC
	DO RESPX^MIOHTTP(.DEV,.CONF,101,.HEAD,"",$GET(CTX("request_id")),.CTX)
	; handshake-only metrics; exclude long-lived websocket loop
	SET CTX("skip_metrics")=1
	NEW T1 SET T1=$$TSUS^MIOMET()
	NEW LATMS SET LATMS=((T1-$GET(CTX("t0us")))/1000)
	DO OBS^MIOMET($GET(REQ("method")),$GET(CTX("route"),"/ws"),101,LATMS)
	DO LOOP(.DEV,.CONF,.REQ,.CTX)
	QUIT
	;
; Entry point
; See docs/routines for details.;
FAIL(DEV,CONF,CTX,WHY)
	NEW OBJ SET OBJ("error")=WHY,OBJ("request_id")=$GET(CTX("request_id"))
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.OBJ,$GET(CTX("request_id")),.CTX)
	QUIT
	;
; Entry point
; See docs/routines for details.;
LOOP(DEV,CONF,REQ,CTX)
	NEW TO SET TO=+$GET(CONF("websocket","idleTimeoutSeconds"),3600)
	NEW MAXFRAME SET MAXFRAME=+$GET(CONF("websocket","maxFrameBytes"),65536)
	NEW MAXMSG SET MAXMSG=+$GET(CONF("websocket","maxMessageBytes"),262144)
	; fragmentation state
	NEW FRAG,MSGOPC,MSGBUF,MSGLEN
	SET FRAG=0,MSGOPC=0,MSGBUF="",MSGLEN=0
	FOR  DO  QUIT:$GET(CTX("stop"))
	. NEW OPC,FIN,PAY,ERR
	. DO READFRAME(.DEV,TO,.FIN,.OPC,.PAY,.ERR,.MAXFRAME)
	. IF $DATA(ERR) SET CTX("stop")=1 QUIT
	. ; control frames may appear anytime
	. IF OPC=8 DO SENDCLOSE(.DEV,"",1000) SET CTX("stop")=1 QUIT
	. IF OPC=9 DO SENDPONG(.DEV,PAY) QUIT
	. IF OPC=10 QUIT
	. ; continuation
	. IF OPC=0 DO  QUIT
	. . IF 'FRAG SET CTX("stop")=1 DO SENDCLOSE(.DEV,"",1002) QUIT
	. . SET MSGBUF=MSGBUF_PAY,MSGLEN=MSGLEN+$LENGTH(PAY)
	. . IF MSGLEN>MAXMSG SET CTX("stop")=1 DO SENDCLOSE(.DEV,"",1009) QUIT
	. . IF FIN DO
	. . . DO HANDLEMSG(.DEV,.CONF,.CTX,MSGOPC,MSGBUF)
	. . . SET FRAG=0,MSGOPC=0,MSGBUF="",MSGLEN=0
	. ; data frames
	. IF (OPC=1)!(OPC=2) DO  QUIT
	. . IF FRAG SET CTX("stop")=1 DO SENDCLOSE(.DEV,"",1002) QUIT
	. . IF FIN DO  QUIT
	. . . DO HANDLEMSG(.DEV,.CONF,.CTX,OPC,PAY)
	. . SET FRAG=1,MSGOPC=OPC,MSGBUF=PAY,MSGLEN=$LENGTH(PAY)
	. . IF MSGLEN>MAXMSG SET CTX("stop")=1 DO SENDCLOSE(.DEV,"",1009) QUIT
	. ; unknown opcode
	. SET CTX("stop")=1 DO SENDCLOSE(.DEV,"",1002)
	QUIT
	;
; Entry point
; See docs/routines for details.;
HANDLEMSG(DEV,CONF,CTX,OPC,PAY)
	; OPC 1=text, 2=binary. Default server: echo text; reject binary.;
	IF OPC=1 DO SENDTEXT(.DEV,PAY) QUIT
	DO SENDCLOSE(.DEV,"",1003)
	SET CTX("stop")=1
	QUIT
	;
; Entry point
; See docs/routines for details.;
READFRAME(DEV,TO,FIN,OPC,PAY,ERR,MAXFRAME)
	KILL ERR
	NEW B1,B2
	DO READN^MIOSOCK(DEV,1,TO,.B1) IF '$TEST SET ERR("error")="ws_timeout" QUIT
	DO READN^MIOSOCK(DEV,1,TO,.B2) IF '$TEST SET ERR("error")="ws_timeout" QUIT
	NEW N1,N2 SET N1=$ASCII(B1),N2=$ASCII(B2)
	SET FIN=$S($ZBITAND(N1,128)>0:1,1:0)
	SET OPC=$ZBITAND(N1,15)
	; RSV bits must be 0 (no extensions)
	IF $ZBITAND(N1,112)>0 SET ERR("error")="ws_rsv_not_supported" QUIT
	NEW MASK SET MASK=$S($ZBITAND(N2,128)>0:1,1:0)
	NEW LEN SET LEN=$ZBITAND(N2,127)
	; control frames: FIN=1 and <=125 bytes
	IF (OPC=8)!(OPC=9)!(OPC=10) DO
	. IF 'FIN SET ERR("error")="ws_control_fragmented" QUIT
	. IF LEN>125 SET ERR("error")="ws_control_too_large" QUIT
	IF $DATA(ERR) QUIT
	IF LEN=126 DO
	. NEW X DO READN^MIOSOCK(DEV,2,TO,.X) IF '$TEST SET ERR("error")="ws_timeout" QUIT
	. SET LEN=($ASCII($EXTRACT(X,1))*256)+$ASCII($EXTRACT(X,2))
	ELSE  IF LEN=127 DO
	. NEW X DO READN^MIOSOCK(DEV,8,TO,.X) IF '$TEST SET ERR("error")="ws_timeout" QUIT
	. NEW I,VAL SET VAL=0
	. FOR I=1:1:8 SET VAL=VAL*256+$ASCII($EXTRACT(X,I))
	. IF VAL>2147483647 SET ERR("error")="ws_frame_too_large" QUIT
	. SET LEN=VAL
	IF $DATA(ERR) QUIT
	IF LEN>MAXFRAME SET ERR("error")="ws_frame_too_large" QUIT
	IF 'MASK SET ERR("error")="ws_client_unmasked" QUIT
	NEW MK DO READN^MIOSOCK(DEV,4,TO,.MK) IF '$TEST SET ERR("error")="ws_timeout" QUIT
	NEW DATA SET DATA=""
	IF LEN>0 DO READN^MIOSOCK(DEV,LEN,TO,.DATA) IF '$TEST SET ERR("error")="ws_timeout" QUIT
	SET PAY=$$UNMASK(DATA,MK)
	QUIT
	;
; Entry point
; See docs/routines for details.;
UNMASK(DATA,MK)
	NEW OUT SET OUT=""
	NEW I
	FOR I=1:1:$LENGTH(DATA) DO
	. NEW B SET B=$ASCII($EXTRACT(DATA,I))
	. NEW K SET K=$ASCII($EXTRACT(MK,((I-1)#4)+1))
	. SET OUT=OUT_$CHAR($ZBITXOR(B,K))
	QUIT OUT
	;
; Entry point
; See docs/routines for details.;
SENDTEXT(DEV,TXT) DO SENDFRAME(DEV,1,TXT,1) QUIT
; Entry point
; See docs/routines for details.;
SENDPONG(DEV,PAY) DO SENDFRAME(DEV,10,PAY,1) QUIT
	;
; Entry point
; See docs/routines for details.;
SENDCLOSE(DEV,REASON,CODE)
	NEW PAY SET PAY=""
	IF $GET(CODE)>0 SET PAY=$CHAR((CODE\256))_$CHAR(CODE#256)_$GET(REASON)
	DO SENDFRAME(DEV,8,PAY,1)
	QUIT
	;
; Entry point
; See docs/routines for details.;
SENDFRAME(DEV,OPC,PAY,FIN)
	NEW B1 SET B1=$CHAR($SELECT($GET(FIN):128,1:0)+OPC)
	NEW LEN SET LEN=$LENGTH(PAY)
	NEW HDR
	IF LEN<126 SET HDR=B1_$CHAR(LEN)
	ELSE  IF LEN<65536 SET HDR=B1_$CHAR(126)_$CHAR(LEN\256)_$CHAR(LEN#256)
	ELSE  DO
	. NEW I,REM,BUF SET BUF="",REM=LEN
	. FOR I=8:-1:1 DO
	. . SET BUF=$CHAR(REM#256)_BUF
	. . SET REM=REM\256
	. SET HDR=B1_$CHAR(127)_BUF
	DO WRITE^MIOSOCK(DEV,HDR_PAY)
	QUIT
	;
; --- Convenience aliases for other modules ---
WRITETXT(DEV,TXT) DO SENDTEXT(.DEV,TXT) QUIT
	;
; --- Message-level reader with fragmentation reassembly ---
; READMSG returns a complete message (text/binary) when available.;
; It transparently handles ping/pong. On timeout, sets ERR("timeout")=1.;
; State array S must be preserved between calls.;
;
INITSTATE(S,CONF)
	KILL S
	SET S("to")=+$GET(CONF("websocket","idleTimeoutSeconds"),3600)
	SET S("maxframe")=+$GET(CONF("websocket","maxFrameBytes"),65536)
	SET S("maxmsg")=+$GET(CONF("websocket","maxMessageBytes"),262144)
	SET S("frag")=0,S("msgopc")=0,S("buf")="",S("len")=0
	QUIT
	;
; Entry point
; See docs/routines for details.;
READMSG(DEV,TO,S,OPC,MSG,ERR)
	KILL ERR
	SET OPC="",MSG=""
	NEW MAXFRAME SET MAXFRAME=+$GET(S("maxframe"),65536)
	NEW MAXMSG SET MAXMSG=+$GET(S("maxmsg"),262144)
	FOR  DO  QUIT:$DATA(ERR)!(OPC'="")
	. NEW FOPC,FIN,PAY,FERR
	. DO READFRAME(.DEV,TO,.FIN,.FOPC,.PAY,.FERR,.MAXFRAME)
	. IF $DATA(FERR) DO  QUIT
	. . IF $GET(FERR("error"))="ws_timeout" SET ERR("timeout")=1 QUIT
	. . MERGE ERR=FERR
	. ; control frames
	. IF FOPC=8 SET OPC=8,MSG=PAY QUIT
	. IF FOPC=9 DO SENDPONG(.DEV,PAY) QUIT
	. IF FOPC=10 QUIT
	. ; continuation
	. IF FOPC=0 DO  QUIT
	. . IF '$GET(S("frag")) DO SENDCLOSE(.DEV,"",1002) SET ERR("error")="ws_protocol" QUIT
	. . SET S("buf")=$GET(S("buf"))_PAY
	. . SET S("len")=+$GET(S("len"))+$LENGTH(PAY)
	. . IF S("len")>MAXMSG DO SENDCLOSE(.DEV,"",1009) SET ERR("error")="ws_message_too_large" QUIT
	. . IF FIN DO
	. . . SET OPC=$GET(S("msgopc")),MSG=$GET(S("buf"))
	. . . SET S("frag")=0,S("msgopc")=0,S("buf")="",S("len")=0
	. ; new data frame
	. IF (FOPC=1)!(FOPC=2) DO  QUIT
	. . IF $GET(S("frag")) DO SENDCLOSE(.DEV,"",1002) SET ERR("error")="ws_protocol" QUIT
	. . IF FIN SET OPC=FOPC,MSG=PAY QUIT
	. . SET S("frag")=1,S("msgopc")=FOPC,S("buf")=PAY,S("len")=$LENGTH(PAY)
	. . IF S("len")>MAXMSG DO SENDCLOSE(.DEV,"",1009) SET ERR("error")="ws_message_too_large" QUIT
	. ; unknown opcode
	. DO SENDCLOSE(.DEV,"",1002) SET ERR("error")="ws_bad_opcode"
	QUIT