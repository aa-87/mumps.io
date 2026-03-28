MIOMIDEWS ; MIOIDE event websocket
	QUIT
	;
MESSAGE(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,RESP,EVT,TREE
	SET CTX("ws","keep_open")=1
	IF '$$ENSURE^MIOMIDEST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO SENDTEXT^MIOWS(.DEV,$$ERRJSON("login_required",$GET(ERR("error"))))
	SET EVT=$$EVENT($GET(CTX("payload")),.TREE)
	IF EVT="hello" DO  QUIT
	. DO SENDTEXT^MIOWS(.DEV,$$HELLO(.STATE))
	IF EVT="ping" DO  QUIT
	. DO SENDTEXT^MIOWS(.DEV,$$PONG())
	IF EVT="presence" DO  QUIT
	. DO SENDTEXT^MIOWS(.DEV,$$ACK("presence",$GET(STATE("userName"))))
	IF EVT="collab.join" DO  QUIT
	. DO SENDTEXT^MIOWS(.DEV,$$ACK("collab.join",$GET(TREE("routine"))))
	DO SENDTEXT^MIOWS(.DEV,$$ERRJSON("unsupported_event",EVT))
	QUIT
	;
EVENT(PAY,TREE)
	NEW ERR,EVT
	KILL TREE
	SET EVT=""
	IF $GET(PAY)="" QUIT EVT
	IF $EXTRACT(PAY,1)="{" DO  QUIT $GET(TREE("event"))
	. IF '$$DECODE^MIOJSON($GET(PAY),.TREE,.ERR) QUIT
	IF PAY="hello" QUIT "hello"
	IF PAY="ping" QUIT "ping"
	QUIT EVT
	;
HELLO(STATE)
	NEW OBJ
	SET OBJ("ok")=1
	SET OBJ("event")="hello"
	SET OBJ("user")=$GET(STATE("userName"))
	SET OBJ("serverTime")=$$NOWISO^MIOUTIL()
	QUIT $$EN^MIOJSON1(.OBJ)
	;
PONG()
	NEW OBJ
	SET OBJ("ok")=1
	SET OBJ("event")="pong"
	SET OBJ("serverTime")=$$NOWISO^MIOUTIL()
	QUIT $$EN^MIOJSON1(.OBJ)
	;
ACK(EVT,DETAIL)
	NEW OBJ
	SET OBJ("ok")=1
	SET OBJ("event")=$GET(EVT)
	SET OBJ("detail")=$GET(DETAIL)
	SET OBJ("serverTime")=$$NOWISO^MIOUTIL()
	QUIT $$EN^MIOJSON1(.OBJ)
	;
ERRJSON(CODE,DETAIL)
	NEW OBJ
	SET OBJ("ok")=0
	SET OBJ("event")="error"
	SET OBJ("error")=$GET(CODE)
	SET OBJ("detail")=$GET(DETAIL)
	QUIT $$EN^MIOJSON1(.OBJ)
	;
