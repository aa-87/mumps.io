MIOOSWS ; MIOOS websocket handlers
	QUIT
	;
MESSAGE(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,RESP,EVT,VIEW
	SET CTX("ws","keep_open")=1
	SET EVT=$$EVENT($GET(CTX("payload")))
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO SENDTEXT^MIOWS(.DEV,$$ERRJSON("session_error",$GET(ERR("error"),"session_error")))
	IF EVT="hello" DO  QUIT
	. SET RESP=$$HELLOJSON(.STATE,.CONF)
	. DO SENDTEXT^MIOWS(.DEV,RESP)
	IF EVT="ping" DO  QUIT
	. SET RESP=$$PONGJSON(.STATE)
	. DO SENDTEXT^MIOWS(.DEV,RESP)
	IF EVT="view.refresh" DO  QUIT
	. DO BUILD^MIOOSVM(.STATE,.CONF,.VIEW)
	. SET RESP=$$VIEWJSON(.STATE,.VIEW)
	. DO SENDTEXT^MIOWS(.DEV,RESP)
	IF EVT="shell.open" DO  QUIT
	. DO SENDTEXT^MIOWS(.DEV,$$ACKJSON("shell.open",$$FIELD($GET(CTX("payload")),"appKey")))
	DO SENDTEXT^MIOWS(.DEV,$$ERRJSON("unsupported_event",EVT))
	QUIT
	;
EVENT(PAYLOAD)
	NEW TREE,ERR
	IF $GET(PAYLOAD)="hello" QUIT "hello"
	IF $GET(PAYLOAD)="ping" QUIT "ping"
	IF $EXTRACT($GET(PAYLOAD),1)="{" DO  QUIT $GET(TREE("event"))
	. IF '$$DECODE^MIOJSON($GET(PAYLOAD),.TREE,.ERR) QUIT
	QUIT ""
	;
FIELD(PAYLOAD,NAME)
	NEW TREE,ERR
	IF $EXTRACT($GET(PAYLOAD),1)'="{" QUIT ""
	IF '$$DECODE^MIOJSON($GET(PAYLOAD),.TREE,.ERR) QUIT ""
	QUIT $GET(TREE($GET(NAME)))
	;
HELLOJSON(STATE,CONF)
	NEW OBJ
	SET OBJ("event")="hello"
	SET OBJ("ok")=1
	SET OBJ("product")=$GET(STATE("brandTitle"),"MIOOS")
	SET OBJ("profile")=$GET(STATE("profile"),"dev")
	SET OBJ("sessionId")=$GET(STATE("sessionId"))
	SET OBJ("user")=$GET(STATE("principal"))
	SET OBJ("commandEvent")=$GET(STATE("commandEvent"),"desktop.command")
	SET OBJ("commandResultEvent")=$GET(STATE("commandResultEvent"),"desktop.result")
	SET OBJ("realtimeContract")=$GET(STATE("transportModel"),"single-websocket-command-and-events")
	QUIT $$EN^MIOJSON1(.OBJ)
	;
PONGJSON(STATE)
	NEW OBJ
	SET OBJ("event")="pong"
	SET OBJ("ok")=1
	SET OBJ("sessionId")=$GET(STATE("sessionId"))
	SET OBJ("product")=$GET(STATE("brandTitle"),"MIOOS")
	QUIT $$EN^MIOJSON1(.OBJ)
	;
VIEWJSON(STATE,VIEW)
	NEW OBJ
	SET OBJ("event")="view.refresh"
	SET OBJ("ok")=1
	SET OBJ("sessionId")=$GET(STATE("sessionId"))
	MERGE OBJ("view")=VIEW
	QUIT $$EN^MIOJSON1(.OBJ)
	;
ACKJSON(EVENT,VALUE)
	NEW OBJ
	SET OBJ("event")=$GET(EVENT)
	SET OBJ("ok")=1
	SET OBJ("value")=$GET(VALUE)
	QUIT $$EN^MIOJSON1(.OBJ)
	;
ERRJSON(CODE,DETAIL)
	NEW OBJ
	SET OBJ("event")="error"
	SET OBJ("ok")=0
	SET OBJ("error")=$GET(CODE)
	SET OBJ("detail")=$GET(DETAIL)
	SET OBJ("routine")="MIOOSWS"
	QUIT $$EN^MIOJSON1(.OBJ)
