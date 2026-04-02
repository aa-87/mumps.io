MIOOSTRXWS ; MIOOS transfer websocket foundation
	QUIT
	;
MESSAGE(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,RESP
	SET CTX("ws","keep_open")=1
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO SENDTEXT^MIOWS(.DEV,$$ERRJSON(.STATE,"session_error",$GET(ERR("error")),""))
	IF $$EVENTJSON(.CONF,.REQ,.CTX,.STATE,$GET(CTX("payload")),.RESP,.ERR) DO  QUIT
	. IF $GET(RESP)'="" DO SENDTEXT^MIOWS(.DEV,RESP)
	DO SENDTEXT^MIOWS(.DEV,$$ERRJSON(.STATE,$GET(ERR("error"),"transfer_event_error"),$GET(ERR("detail")),$GET(ERR("requestId"))))
	QUIT
	;
EVENTJSON(CONF,REQ,CTX,STATE,PAYLOAD,OUTJSON,ERR)
	NEW TREE,EVT,REQID,OUT
	KILL ERR
	SET ERR("routine")="MIOOSTRXWS"
	SET EVT=$$EVENT($GET(PAYLOAD),.TREE,.ERR)
	SET REQID=$GET(TREE("requestId"))
	SET ERR("requestId")=REQID
	IF EVT="" SET ERR("error")="event_missing" QUIT 0
	IF EVT="hello" SET OUTJSON=$$HELLOJSON(.STATE,.CONF) QUIT 1
	IF EVT="ping" SET OUTJSON=$$PONGJSON(.STATE,.TREE) QUIT 1
	IF EVT="transfer.upload.begin" DO  QUIT $SELECT($GET(ERR("error"))="":1,1:0)
	. IF '$$BEGIN^MIOOSTRXUP(.STATE,.CONF,.TREE,.OUT,.ERR) QUIT
	. SET OUTJSON=$$TRJSON(.STATE,EVT,.OUT,REQID)
	IF EVT="transfer.upload.chunk" DO  QUIT $SELECT($GET(ERR("error"))="":1,1:0)
	. IF '$$CHUNK^MIOOSTRXUP(.STATE,.CONF,.TREE,.OUT,.ERR) QUIT
	. SET OUTJSON=$$TRJSON(.STATE,EVT,.OUT,REQID)
	IF EVT="transfer.upload.commit" DO  QUIT $SELECT($GET(ERR("error"))="":1,1:0)
	. IF '$$COMMIT^MIOOSTRXUP(.STATE,.CONF,.TREE,.OUT,.ERR) QUIT
	. SET OUTJSON=$$TRJSON(.STATE,EVT,.OUT,REQID)
	IF EVT="transfer.upload.abort"!(EVT="transfer.upload.status") DO  QUIT $SELECT($GET(ERR("error"))="":1,1:0)
	. IF EVT="transfer.upload.abort",'$$ABORT^MIOOSTRXUP(.STATE,.CONF,.TREE,.OUT,.ERR) QUIT
	. IF EVT="transfer.upload.status",'$$STATUS^MIOOSTRXUP(.STATE,.CONF,.TREE,.OUT,.ERR) QUIT
	. SET OUTJSON=$$TRJSON(.STATE,EVT,.OUT,REQID)
	IF EVT="transfer.download.begin" DO  QUIT $SELECT($GET(ERR("error"))="":1,1:0)
	. IF '$$BEGIN^MIOOSTRXDN(.STATE,.CONF,.TREE,.OUT,.ERR) QUIT
	. SET OUTJSON=$$TRJSON(.STATE,EVT,.OUT,REQID)
	IF EVT="transfer.download.chunk" DO  QUIT $SELECT($GET(ERR("error"))="":1,1:0)
	. IF '$$CHUNK^MIOOSTRXDN(.STATE,.CONF,.TREE,.OUT,.ERR) QUIT
	. SET OUTJSON=$$TRJSON(.STATE,EVT,.OUT,REQID)
	IF EVT="transfer.download.end"!(EVT="transfer.download.abort")!(EVT="transfer.download.status") DO  QUIT $SELECT($GET(ERR("error"))="":1,1:0)
	. IF EVT="transfer.download.end",'$$END^MIOOSTRXDN(.STATE,.CONF,.TREE,.OUT,.ERR) QUIT
	. IF EVT="transfer.download.abort",'$$ABORT^MIOOSTRXDN(.STATE,.CONF,.TREE,.OUT,.ERR) QUIT
	. IF EVT="transfer.download.status",'$$STATUS^MIOOSTRXDN(.STATE,.CONF,.TREE,.OUT,.ERR) QUIT
	. SET OUTJSON=$$TRJSON(.STATE,EVT,.OUT,REQID)
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
HELLOJSON(STATE,CONF)
	NEW OBJ
	SET OBJ("event")="hello",OBJ("ok")=1
	SET OBJ("sessionId")=$GET(STATE("sessionId"))
	SET OBJ("product")=$GET(STATE("brandTitle"),"MIOOS")
	SET OBJ("transferTransport")="dedicated-websocket"
	SET OBJ("websocketPath")=$GET(CONF("mioos","route","wsTransfer"),"/ws/mioos/transfer")
	QUIT $$EN^MIOJSON1(.OBJ)
	;
PONGJSON(STATE,TREE)
	NEW OBJ
	SET OBJ("event")="pong",OBJ("ok")=1
	SET OBJ("sessionId")=$GET(STATE("sessionId"))
	SET OBJ("transferId")=$GET(TREE("transferId"))
	QUIT $$EN^MIOJSON1(.OBJ)
	;
TRJSON(STATE,EVENT,OUT,REQID)
	NEW OBJ
	SET OBJ("event")=$GET(EVENT),OBJ("ok")=1
	SET OBJ("requestId")=$GET(REQID),OBJ("sessionId")=$GET(STATE("sessionId"))
	MERGE OBJ("transfer")=OUT
	QUIT $$EN^MIOJSON1(.OBJ)
	;
ERRJSON(STATE,CODE,DETAIL,REQID)
	NEW OBJ
	SET OBJ("event")="error",OBJ("ok")=0
	SET OBJ("error")=$GET(CODE),OBJ("detail")=$GET(DETAIL)
	SET OBJ("requestId")=$GET(REQID),OBJ("sessionId")=$GET(STATE("sessionId"))
	SET OBJ("routine")="MIOOSTRXWS"
	QUIT $$EN^MIOJSON1(.OBJ)
	;
