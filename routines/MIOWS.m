MIOWS ; WebSocket protocol handler (RFC 6455).;
;
WSECHO(DEV,CONF,REQ,CTX)
	F  Q:$G(CTX("stop"))  H 0.5 S X=$G(X)_"X" D:'$G(CTX("stop")) SENDTEXT(.DEV,"THE TIME NOW IS "_$H) D:'$G(CTX("stop")) SENDTEXT(.DEV,$c(10)_X_$C(10)_$L(X))
	QUIT
	;
ACCEPT(DEV,CONF,REQ,CTX)
	NEW KEY SET KEY=$GET(REQ("hdr","sec-websocket-key"))
	IF KEY="" DO FAIL(.DEV,.CONF,.CTX,"missing_sec_websocket_key") QUIT
	NEW ACC S ACC=$$WSACCEPT^MIOSHA1(KEY)
	NEW HEAD
	SET HEAD("Upgrade")="websocket"
	SET HEAD("Connection")="Upgrade"
	SET HEAD("Sec-WebSocket-Accept")=ACC
	DO RESPX^MIOHTTP(.DEV,.CONF,101,.HEAD,"",$GET(CTX("request_id")),.CTX)
	SET CTX("skip_metrics")=1
	NEW T1 SET T1=$$TSUS^MIOMET()
	NEW LATMS SET LATMS=((T1-$GET(CTX("t0us")))/1000)
	DO OBS^MIOMET($GET(REQ("method")),$GET(CTX("route"),"/ws"),101,LATMS)
	DO LOOP(.DEV,.CONF,.REQ,.CTX)
	QUIT
	;
FAIL(DEV,CONF,CTX,WHY)
	NEW OBJ SET OBJ("error")=WHY,OBJ("request_id")=$GET(CTX("request_id"))
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.OBJ,$GET(CTX("request_id")),.CTX)
	QUIT
	;
LOOP(DEV,CONF,REQ,CTX)
	NEW TO SET TO=+$GET(CONF("websocket","idleTimeoutSeconds"),3600)
	NEW MAXFRAME SET MAXFRAME=+$GET(CONF("websocket","maxFrameBytes"),65536)
	NEW MAXMSG SET MAXMSG=+$GET(CONF("websocket","maxMessageBytes"),262144)
	NEW FRAG,MSGOPC,MSGBUF,MSGLEN
	NEW OPC,FIN,PAY,ERR
	SET FRAG=0,MSGOPC=0,MSGBUF="",MSGLEN=0
	FOR  DO  QUIT:$GET(CTX("stop"))
	. DO READFRAME(.DEV,TO,.FIN,.OPC,.PAY,.ERR,.MAXFRAME)
	. IF $DATA(ERR) SET CTX("stop")=1 QUIT
	. IF OPC=8 DO SENDCLOSE(.DEV,"",1000) SET CTX("stop")=1 QUIT
	. IF OPC=9 DO SENDPONG(.DEV,PAY) QUIT
	. IF OPC=10 QUIT
	. IF OPC=0 DO  QUIT
	. . IF 'FRAG SET CTX("stop")=1 DO SENDCLOSE(.DEV,"",1002) QUIT
	. . SET MSGBUF=MSGBUF_PAY,MSGLEN=MSGLEN+$LENGTH(PAY)
	. . IF MSGLEN>MAXMSG SET CTX("stop")=1 DO SENDCLOSE(.DEV,"",1009) QUIT
	. . IF FIN DO
	. . . DO HANDLEMSG(.DEV,.REQ,.CONF,.CTX,MSGOPC,MSGBUF)
	. . . SET FRAG=0,MSGOPC=0,MSGBUF="",MSGLEN=0
	. IF (OPC=1)!(OPC=2) DO  QUIT
	. . IF FRAG SET CTX("stop")=1 DO SENDCLOSE(.DEV,"",1002) QUIT
	. . IF FIN DO  QUIT
	. . . DO HANDLEMSG(.DEV,.REQ,.CONF,.CTX,OPC,PAY)
	. . SET FRAG=1,MSGOPC=OPC,MSGBUF=PAY,MSGLEN=$LENGTH(PAY)
	. . IF MSGLEN>MAXMSG SET CTX("stop")=1 DO SENDCLOSE(.DEV,"",1009) QUIT
	. SET CTX("stop")=1 DO SENDCLOSE(.DEV,"",1002)
	QUIT
	;
HANDLEMSG(DEV,REQ,CONF,CTX,OPC,PAY)
	NEW H,TAG,RTN,META,PERSIST
	I $G(CTX("stop")) QUIT
	DO PREMATCH^MIOROUTE(.REQ,.CTX)
	IF '$G(CTX("match","ok")) QUIT
	M REQ("params")=CTX("match","params")
	S H=CTX("match","handler")
	S TAG=$PIECE($GET(H),"^")
	S RTN=$PIECE($GET(H),"^",2)
	DO GETMETA^MIOROUTE("WS",$G(CTX("match","route")),.META)
	S PERSIST=+$G(META("wsPersistent"))
	S CTX("payload")=PAY
	S CTX("OPC")=OPC
	DO @(TAG_"^"_RTN_"(.DEV,.CONF,.REQ,.CTX)")
	I PERSIST!$G(CTX("ws","keep_open")) QUIT
	DO SENDCLOSE(.DEV,"",1003)
	SET CTX("stop")=1
	QUIT
	;
READFRAME(DEV,TO,FIN,OPC,PAY,ERR,MAXFRAME)
	KILL ERR
	NEW B1,B2
	DO READN^MIOSOCK(DEV,1,TO,.B1) IF '$TEST SET ERR("error")="ws_timeout" QUIT
	DO READN^MIOSOCK(DEV,1,TO,.B2) IF '$TEST SET ERR("error")="ws_timeout" QUIT
	NEW N1,N2 SET N1=$ASCII(B1),N2=$ASCII(B2)
	S FIN=(N1\128),OPC=(N1#128)
	NEW MASK SET MASK=(N2\128)
	NEW LEN SET LEN=(N2#128)
	IF (OPC=8)!(OPC=9)!(OPC=10) DO
	. IF 'FIN SET ERR("error")="ws_control_fragmented" QUIT
	. IF LEN>125 SET ERR("error")="ws_control_too_large" QUIT
	IF $DATA(ERR) QUIT
	IF LEN=126 DO
	. NEW X DO READN^MIOSOCK(DEV,2,TO,.X) IF '$TEST SET ERR("error")="ws_timeout" QUIT
	. SET LEN=($ASCII($EXTRACT(X,1))*256)+$ASCII($EXTRACT(X,2))
	IF LEN=127 DO
	. NEW X DO READN^MIOSOCK(DEV,8,TO,.X) IF '$TEST SET ERR("error")="ws_timeout" QUIT
	. NEW I,VAL SET VAL=0
	. FOR I=1:1:8 SET VAL=VAL*256+$ASCII($EXTRACT(X,I))
	. IF VAL>2147483647 SET ERR("error")="ws_frame_too_large" QUIT
	. SET LEN=VAL
	IF LEN>MAXFRAME SET ERR("error")="ws_frame_too_large" QUIT
	IF 'MASK SET ERR("error")="ws_client_unmasked" QUIT
	NEW MK DO READN^MIOSOCK(DEV,4,TO,.MK) IF '$TEST SET ERR("error")="ws_timeout" QUIT
	NEW DATA SET DATA=""
	IF LEN>0 DO READN^MIOSOCK(DEV,LEN,TO,.DATA) IF '$TEST SET ERR("error")="ws_timeout" QUIT
	SET PAY=$$UNMSK(DATA,MK)
	QUIT
UNMSK(X,Y) N I,O S O="" F I=1:1:$L(X) S O=O_$C($$XOR($A(X,I),$A(Y,$S('(I#4):4,1:I#4)),8))
	Q O
XOR(A,B,W) N I,M,R S R=B,M=1 F I=1:1:W S:A\M#2 R=R+$S(R\M#2:-M,1:M) S M=M+M
	Q R	
	;
SENDTEXT(DEV,TXT) DO SENDFRAME(DEV,1,TXT,1) QUIT
SENDPONG(DEV,PAY) DO SENDFRAME(DEV,10,PAY,1) QUIT
	;
SENDCLOSE(DEV,REASON,CODE)
	NEW PAY SET PAY=""
	IF $GET(CODE)>0 SET PAY=$CHAR((CODE\256))_$CHAR(CODE#256)_$GET(REASON)
	DO SENDFRAME(DEV,8,PAY,1)
	QUIT
	;
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
WRITETXT(DEV,TXT) DO SENDTEXT(.DEV,TXT) QUIT
	;
INITSTATE(S,CONF)
	KILL S
	SET S("to")=+$GET(CONF("websocket","idleTimeoutSeconds"),3600)
	SET S("maxframe")=+$GET(CONF("websocket","maxFrameBytes"),65536)
	SET S("maxmsg")=+$GET(CONF("websocket","maxMessageBytes"),262144)
	SET S("frag")=0,S("msgopc")=0,S("buf")="",S("len")=0
	QUIT
	;
READMSG(DEV,S,OPC,MSG,ERR)
	N FIN,PAY
	K ERR
	S OPC="",MSG=""
	F  D  Q:$G(ERR("done"))!$G(ERR("timeout"))!$G(ERR("closed"))!$D(ERR("error"))
	. D READFRAME(.DEV,+$G(S("to"),1),.FIN,.OPC,.PAY,.ERR,+$G(S("maxframe"),65536))
	. I $G(ERR("error"))="ws_timeout" K ERR S ERR("timeout")=1,ERR("done")=1 Q
	. I $D(ERR("error")) S ERR("done")=1 Q
	. I OPC=8 S ERR("closed")=1,ERR("done")=1 Q
	. I OPC=9 D SENDPONG(.DEV,PAY) Q
	. I OPC=10 Q
	. I OPC=0 DO  Q
	. . I '$G(S("frag")) S ERR("error")="ws_protocol_error",ERR("done")=1 Q
	. . S S("buf")=$G(S("buf"))_PAY,S("len")=+$G(S("len"))+$L(PAY)
	. . I +$G(S("len"))>+$G(S("maxmsg"),262144) S ERR("error")="ws_message_too_large",ERR("done")=1 Q
	. . I FIN S MSG=$G(S("buf")),OPC=$G(S("msgopc")),S("frag")=0,S("msgopc")=0,S("buf")="",S("len")=0,ERR("done")=1
	. I (OPC=1)!(OPC=2) DO  Q
	. . I FIN S MSG=PAY,ERR("done")=1 Q
	. . S S("frag")=1,S("msgopc")=OPC,S("buf")=PAY,S("len")=$L(PAY)
	. . I +$G(S("len"))>+$G(S("maxmsg"),262144) S ERR("error")="ws_message_too_large",ERR("done")=1
	. S ERR("error")="ws_protocol_error",ERR("done")=1
	K ERR("done")
	Q $S($D(ERR("timeout"))!$D(ERR("closed"))!$D(ERR("error")):0,1:1)
	;