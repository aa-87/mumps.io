MIOOSTWS ; MIOOS dedicated terminal websocket handler
	QUIT
	;
MESSAGE(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,RESP
	SET CTX("ws","keep_open")=1
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO SENDTEXT^MIOWS(.DEV,$$ERRJSON(.STATE,"session_error",$GET(ERR("error")),""))
	IF $$EVENTJSON(.CONF,.REQ,.CTX,.STATE,$GET(CTX("payload")),.RESP,.ERR) DO  QUIT
	. IF $GET(RESP)'="" DO SENDTEXT^MIOWS(.DEV,RESP)
	DO SENDTEXT^MIOWS(.DEV,$$ERRJSON(.STATE,$GET(ERR("error"),"terminal_event_error"),$GET(ERR("detail")),$GET(ERR("requestId"))))
	QUIT
	;
EVENTJSON(CONF,REQ,CTX,STATE,PAYLOAD,OUTJSON,ERR)
	NEW TREE,EVT,REQID,OUT,SZ
	KILL ERR
	SET ERR("routine")="MIOOSTWS"
	SET EVT=$$EVENT($GET(PAYLOAD),.TREE,.ERR)
	SET REQID=$GET(TREE("requestId"))
	SET ERR("requestId")=REQID
	IF EVT="" SET ERR("error")="event_missing" QUIT 0
	IF EVT="hello" SET OUTJSON=$$HELLOJSON(.STATE,.CONF) QUIT 1
	IF EVT="ping" SET OUTJSON=$$PONGJSON(.STATE,.TREE) QUIT 1
	IF +$GET(STATE("authRequired"),0)=1,+$GET(STATE("authenticated"),0)'=1 DO  QUIT 0
	. SET ERR("error")="login_required",ERR("detail")=EVT
	IF EVT="terminal.open"!(EVT="terminal.attach") DO  QUIT $SELECT($GET(ERR("error"))="":1,1:0)
	. IF '$$OPEN^MIOOSTERM(.STATE,.CONF,$GET(TREE("terminalId")),.OUT,.ERR) QUIT
	. IF +$GET(TREE("cols"))>0!(+$GET(TREE("rows"))>0) DO
	. . IF $$RESIZE^MIOOSTERM(.STATE,.CONF,$GET(OUT("terminalId")),+$GET(TREE("cols")),+$GET(TREE("rows")),.SZ,.ERR) MERGE OUT=SZ
	. SET OUT("windowId")=$GET(TREE("windowId"))
	. SET OUTJSON=$$TERMEVTJSON(.STATE,"terminal.open",.OUT,REQID)
	IF EVT="terminal.input" DO  QUIT $SELECT($GET(ERR("error"))="":1,1:0)
	. IF '$$INPUTRAW^MIOOSTERM(.STATE,.CONF,$GET(TREE("terminalId")),$$INDATA(.TREE),.OUT,.ERR) QUIT
	. SET OUT("windowId")=$GET(TREE("windowId"))
	. SET OUTJSON=$$TERMEVTJSON(.STATE,"terminal.stdout",.OUT,REQID)
	IF EVT="terminal.poll"!(EVT="terminal.drain")!(EVT="ping.terminal") DO  QUIT $SELECT($GET(ERR("error"))="":1,1:0)
	. IF '$$POLL^MIOOSTERM(.STATE,.CONF,$GET(TREE("terminalId")),.OUT,.ERR) QUIT
	. SET OUT("windowId")=$GET(TREE("windowId"))
	. SET OUTJSON=$$TERMEVTJSON(.STATE,"terminal.stdout",.OUT,REQID)
	IF EVT="terminal.resize" DO  QUIT $SELECT($GET(ERR("error"))="":1,1:0)
	. IF '$$RESIZE^MIOOSTERM(.STATE,.CONF,$GET(TREE("terminalId")),+$GET(TREE("cols")),+$GET(TREE("rows")),.OUT,.ERR) QUIT
	. SET OUT("windowId")=$GET(TREE("windowId"))
	. SET OUTJSON=$$TERMEVTJSON(.STATE,"terminal.resize",.OUT,REQID)
	IF EVT="terminal.close" DO  QUIT $SELECT($GET(ERR("error"))="":1,1:0)
	. IF '$$CLOSE^MIOOSTERM(.STATE,.CONF,$GET(TREE("terminalId")),.OUT,.ERR) QUIT
	. SET OUT("windowId")=$GET(TREE("windowId"))
	. SET OUTJSON=$$TERMEVTJSON(.STATE,"terminal.close",.OUT,REQID)
	SET ERR("error")="unsupported_event",ERR("detail")=EVT
	QUIT 0
	;
EVENT(PAYLOAD,TREE,ERR)
	KILL TREE
	IF $GET(PAYLOAD)="hello" QUIT "hello"
	IF $GET(PAYLOAD)="ping" QUIT "ping"
	IF $EXTRACT($GET(PAYLOAD),1)'="{" QUIT ""
	IF '$$DECODE^MIOJSON($GET(PAYLOAD),.TREE,.ERR) QUIT ""
	QUIT $GET(TREE("event"))
	;
INDATA(TREE)
	NEW DATA
	SET DATA=$GET(TREE("data"))
	IF DATA'="" QUIT DATA
	SET DATA=$GET(TREE("line"))
	IF DATA'="",($EXTRACT(DATA,$LENGTH(DATA))'=$CHAR(10)),($EXTRACT(DATA,$LENGTH(DATA))'=$CHAR(13)) SET DATA=DATA_$CHAR(10)
	QUIT DATA
	;
HELLOJSON(STATE,CONF)
	NEW OBJ
	SET OBJ("event")="hello"
	SET OBJ("ok")=1
	SET OBJ("product")=$GET(STATE("brandTitle"),"MIOOS")
	SET OBJ("sessionId")=$GET(STATE("sessionId"))
	SET OBJ("user")=$GET(STATE("principal"))
	SET OBJ("terminalTransport")="dedicated-websocket"
	SET OBJ("websocketPath")=$GET(CONF("mioos","route","wsTerminal"),"/ws/mioos/terminal")
	QUIT $$EN^MIOJSON1(.OBJ)
	;
PONGJSON(STATE,TREE)
	NEW OBJ
	SET OBJ("event")="pong"
	SET OBJ("ok")=1
	SET OBJ("sessionId")=$GET(STATE("sessionId"))
	SET OBJ("terminalId")=$GET(TREE("terminalId"))
	QUIT $$EN^MIOJSON1(.OBJ)
	;
TERMEVTJSON(STATE,EVENT,OUT,REQID)
	NEW OBJ
	SET OBJ("event")=$GET(EVENT)
	SET OBJ("ok")=1
	SET OBJ("requestId")=$GET(REQID)
	SET OBJ("sessionId")=$GET(STATE("sessionId"))
	SET OBJ("transport")="websocket"
	MERGE OBJ("terminal")=OUT
	QUIT $$EN^MIOJSON1(.OBJ)
	;
ERRJSON(STATE,CODE,DETAIL,REQID)
	NEW OBJ
	SET OBJ("event")="error"
	SET OBJ("ok")=0
	SET OBJ("error")=$GET(CODE)
	SET OBJ("detail")=$GET(DETAIL)
	SET OBJ("requestId")=$GET(REQID)
	SET OBJ("sessionId")=$GET(STATE("sessionId"))
	SET OBJ("routine")="MIOOSTWS"
	QUIT $$EN^MIOJSON1(.OBJ)
	;
