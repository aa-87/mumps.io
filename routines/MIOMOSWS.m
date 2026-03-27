MIOMOSWS ; MIOMOS websocket handler
	QUIT
	;
MESSAGE(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,RESP,EVT,APPKEY,SID,OK
	SET CTX("ws","keep_open")=1
	SET EVT=$$EVENT($GET(CTX("payload")))
	SET OK=$$ENSURE^MIOMOSST(.CONF,.REQ,.CTX,.STATE,.ERR)
	IF 'OK DO
	. SET SID=$GET(CTX("miomos","sessionId"))
	. IF SID="" SET SID=$$SESSIONID($GET(CTX("payload")))
	. IF $$INJECTAUTH(.CONF,SID,.CTX,.ERR) SET OK=$$ENSURE^MIOMOSST(.CONF,.REQ,.CTX,.STATE,.ERR)
	IF 'OK DO  QUIT
	. SET RESP=$$ERRJSON("session_error",$GET(ERR("error")))
	. DO SENDTEXT^MIOWS(.DEV,RESP)
	SET CTX("miomos","sessionId")=$GET(STATE("sessionId"))
	SET CTX("ws","keep_open")=1
	IF EVT="hello" DO  QUIT
	. DO EVENT^MIOMOSAUD("ws_hello",.CTX,.STATE)
	. SET RESP=$$HELLO(.STATE)
	. DO SENDTEXT^MIOWS(.DEV,RESP)
	IF EVT="ping" DO  QUIT
	. DO EVENT^MIOMOSAUD("ws_ping",.CTX,.STATE)
	. SET RESP=$$PONG(.STATE)
	. DO SENDTEXT^MIOWS(.DEV,RESP)
	IF EVT="launcher.open" DO  QUIT
	. SET APPKEY=$$APPKEY($GET(CTX("payload")))
	. IF APPKEY="" SET APPKEY="workspace"
	. DO EVENT^MIOMOSAUD("ws_launcher_open",.CTX,.STATE)
	. SET RESP=$$ACK("launcher.open",APPKEY,.STATE)
	. DO SENDTEXT^MIOWS(.DEV,RESP)
	IF EVT="layout.sync" DO  QUIT
	. DO SAVELAYOUT^MIOMOSST($GET(STATE("sessionId")),$GET(CTX("payload")))
	. DO EVENT^MIOMOSAUD("ws_layout_sync",.CTX,.STATE)
	. SET RESP=$$ACK("layout.sync","layout",.STATE)
	. DO SENDTEXT^MIOWS(.DEV,RESP)
	DO EVENT^MIOMOSAUD("ws_unsupported",.CTX,.STATE)
	SET RESP=$$ERRJSON("unsupported_event",EVT)
	DO SENDTEXT^MIOWS(.DEV,RESP)
	QUIT
	;
EVENT(PAY)
	NEW TREE,ERR,EVT
	SET EVT=""
	IF $GET(PAY)="" QUIT EVT
	IF $EXTRACT(PAY,1)="{" DO  QUIT:$GET(EVT)'="" EVT
	. IF '$$DECODE^MIOJSON($GET(PAY),.TREE,.ERR) QUIT
	. SET EVT=$GET(TREE("event"))
	IF PAY="hello" QUIT "hello"
	IF PAY="ping" QUIT "ping"
	QUIT EVT
	;
APPKEY(PAY)
	NEW TREE,ERR
	IF $EXTRACT($GET(PAY),1)="{" DO  QUIT $GET(TREE("appKey"))
	. IF '$$DECODE^MIOJSON($GET(PAY),.TREE,.ERR) QUIT
	QUIT ""
	;
SESSIONID(PAY)
	NEW TREE,ERR,SID
	SET SID=""
	IF $GET(PAY)="" QUIT SID
	IF $EXTRACT(PAY,1)'="{" QUIT SID
	IF '$$DECODE^MIOJSON($GET(PAY),.TREE,.ERR) QUIT SID
	SET SID=$GET(TREE("sessionId"))
	QUIT SID
	;
INJECTAUTH(CONF,SID,CTX,ERR)
	NEW KEY,USER,ROLES,I,X
	KILL ERR
	SET ERR("routine")="MIOMOSWS"
	IF $GET(SID)="" SET ERR("error")="session_id_missing" QUIT 0
	SET KEY=$GET(^MIO("MIOMOS","SESSION",SID,"principal"))
	IF KEY="" SET ERR("error")="session_not_found" QUIT 0
	SET USER=$GET(^MIO("MIOMOS","SESSION",SID,"userName"))
	IF USER="" SET USER=KEY
	SET ROLES=$GET(^MIO("MIOMOS","SESSION",SID,"roles"))
	KILL CTX("auth")
	SET CTX("auth","ok")=1
	SET CTX("auth","claims","sub")=KEY
	SET CTX("auth","claims","name")=USER
	FOR I=1:1:$LENGTH(ROLES,",") DO
	. SET X=$$TRIM^MIOUTIL($PIECE(ROLES,",",I))
	. IF X'="" SET CTX("auth","roles",X)=1
	QUIT 1
	;
HELLO(STATE)
	NEW OBJ
	SET OBJ("ok")=1
	SET OBJ("event")="hello"
	SET OBJ("sessionId")=$GET(STATE("sessionId"))
	SET OBJ("userName")=$GET(STATE("userName"))
	SET OBJ("profile")=$GET(STATE("profile"))
	SET OBJ("serverTime")=$$NOWISO^MIOUTIL()
	SET OBJ("idleTimeoutSeconds")=+$GET(STATE("idleTimeoutSeconds"))
	SET OBJ("absoluteTimeoutSeconds")=+$GET(STATE("absoluteTimeoutSeconds"))
	QUIT $$EN^MIOJSON1(.OBJ)
	;
PONG(STATE)
	NEW OBJ
	SET OBJ("ok")=1
	SET OBJ("event")="pong"
	SET OBJ("sessionId")=$GET(STATE("sessionId"))
	SET OBJ("serverTime")=$$NOWISO^MIOUTIL()
	QUIT $$EN^MIOJSON1(.OBJ)
	;
ACK(EVT,APPKEY,STATE)
	NEW OBJ
	SET OBJ("ok")=1
	SET OBJ("event")=$GET(EVT)
	SET OBJ("appKey")=$GET(APPKEY)
	SET OBJ("sessionId")=$GET(STATE("sessionId"))
	SET OBJ("serverTime")=$$NOWISO^MIOUTIL()
	QUIT $$EN^MIOJSON1(.OBJ)
	;
ERRJSON(CODE,DETAIL)
	NEW OBJ
	SET OBJ("ok")=0
	SET OBJ("error")=$GET(CODE)
	SET OBJ("detail")=$GET(DETAIL)
	SET OBJ("routine")="MIOMOSWS"
	QUIT $$EN^MIOJSON1(.OBJ)
	;
