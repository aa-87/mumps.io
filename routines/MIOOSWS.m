MIOOSWS ; MIOOS websocket handlers
	QUIT
	;
MESSAGE(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,RESP,EVT,VIEW
	SET CTX("ws","keep_open")=1
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO SENDTEXT^MIOWS(.DEV,$$ERRJSON(.STATE,"session_error",$GET(ERR("error"),"session_error"),""))
	SET EVT=$$EVENT($GET(CTX("payload")))
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
	. IF +$GET(STATE("authRequired"),0)=1,+$GET(STATE("authenticated"),0)'=1 DO
	. . DO SENDTEXT^MIOWS(.DEV,$$ERRJSON(.STATE,"login_required","shell.open",""))
	. . QUIT
	. DO SENDTEXT^MIOWS(.DEV,$$ACKJSON(.STATE,"shell.open",$$FIELD($GET(CTX("payload")),"appKey")))
	IF EVT="desktop.command"!(EVT="command.exec") DO  QUIT
	. IF $$COMMANDJSON(.CONF,.REQ,.CTX,.STATE,$GET(CTX("payload")),.RESP,.ERR) DO
	. . DO SENDTEXT^MIOWS(.DEV,RESP)
	. ELSE  DO
	. . DO SENDTEXT^MIOWS(.DEV,$$CMDERRJSON(.STATE,$GET(ERR("requestId")),$GET(ERR("command")),500,$GET(ERR("error"),"command_error"),$GET(ERR("detail"))))
	DO SENDTEXT^MIOWS(.DEV,$$ERRJSON(.STATE,"unsupported_event",EVT,""))
	QUIT
	;
COMMANDJSON(CONF,REQ,CTX,STATE,PAYLOAD,OUTJSON,ERR)
	NEW TREE,CMD,REQID
	KILL ERR
	SET ERR("routine")="MIOOSWS"
	IF '$$DECODE^MIOJSON($GET(PAYLOAD),.TREE,.ERR) SET ERR("error")="payload_invalid_json" QUIT 0
	SET CMD=$GET(TREE("command"))
	SET REQID=$GET(TREE("requestId"))
	SET ERR("requestId")=REQID,ERR("command")=CMD
	IF CMD="" SET ERR("error")="command_missing" QUIT 0
	IF +$GET(STATE("authRequired"),0)=1,+$GET(STATE("authenticated"),0)'=1 DO  QUIT 0
	. SET ERR("error")="login_required",ERR("detail")=CMD
	IF CMD="terminal.open"!(CMD="terminal.attach") QUIT $$CMDOPEN(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="terminal.input" QUIT $$CMDINPUT(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="terminal.poll" QUIT $$CMDPOLL(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="terminal.resize" QUIT $$CMDRESIZE(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="terminal.close" QUIT $$CMDCLOSE(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="terminal.list" QUIT $$CMDLIST(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.list" QUIT $$FSLIST(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.read" QUIT $$FSREAD(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.write" QUIT $$FSWRITE(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.mkdir" QUIT $$FSMKDIR(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.meta" QUIT $$FSMETA(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.rename" QUIT $$FSRENAME(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.move" QUIT $$FSMOVE(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.delete" QUIT $$FSDELETE(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="transfer.upload.begin" QUIT $$TRUPBEGIN(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="transfer.upload.chunk" QUIT $$TRUPCHUNK(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="transfer.upload.commit" QUIT $$TRUPCOMMIT(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="transfer.upload.abort" QUIT $$TRUPABORT(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="transfer.upload.status" QUIT $$TRUPSTATUS(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="transfer.download.begin" QUIT $$TRDNBGIN(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="transfer.download.chunk" QUIT $$TRDNCHNK(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="transfer.download.end" QUIT $$TRDNEND(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="transfer.download.abort" QUIT $$TRDNABRT(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="transfer.download.status" QUIT $$TRDNSTAT(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	SET ERR("error")="command_unsupported",ERR("detail")=CMD
	QUIT 0
	;
CMDOPEN(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT,SZ
	IF '$$OPEN^MIOOSTERM(.STATE,.CONF,$GET(TREE("terminalId")),.OUT,.ERR) QUIT 0
	IF +$GET(TREE("cols"))>0!(+$GET(TREE("rows"))>0) DO
	. IF $$RESIZE^MIOOSTERM(.STATE,.CONF,$GET(OUT("terminalId")),+$GET(TREE("cols")),+$GET(TREE("rows")),.SZ,.ERR) MERGE OUT=SZ
	SET OUT("windowId")=$GET(TREE("windowId"))
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"terminal.open","terminal",.OUT)
	QUIT 1
	;
CMDINPUT(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$INPUT^MIOOSTERM(.STATE,.CONF,$GET(TREE("terminalId")),$GET(TREE("line")),.OUT,.ERR) QUIT 0
	SET OUT("windowId")=$GET(TREE("windowId"))
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"terminal.input","terminal",.OUT)
	QUIT 1
	;
CMDPOLL(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$POLL^MIOOSTERM(.STATE,.CONF,$GET(TREE("terminalId")),.OUT,.ERR) QUIT 0
	SET OUT("windowId")=$GET(TREE("windowId"))
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"terminal.poll","terminal",.OUT)
	QUIT 1
	;
CMDRESIZE(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$RESIZE^MIOOSTERM(.STATE,.CONF,$GET(TREE("terminalId")),+$GET(TREE("cols")),+$GET(TREE("rows")),.OUT,.ERR) QUIT 0
	SET OUT("windowId")=$GET(TREE("windowId"))
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"terminal.resize","terminal",.OUT)
	QUIT 1
	;
CMDCLOSE(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$CLOSE^MIOOSTERM(.STATE,.CONF,$GET(TREE("terminalId")),.OUT,.ERR) QUIT 0
	SET OUT("windowId")=$GET(TREE("windowId"))
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"terminal.close","terminal",.OUT)
	QUIT 1
	;
CMDLIST(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	DO LIST^MIOOSTERM(.STATE,$NAME(OUT("sessions")))
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"terminal.list","terminal",.OUT)
	QUIT 1
	;
FSLIST(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$LIST^MIOOSFS(.STATE,$SELECT($GET(TREE("parent"))'="":$GET(TREE("parent")),1:"root"),.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"fs.list","vfs",.OUT)
	QUIT 1
	;
FSREAD(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT,ID
	SET ID=$SELECT($GET(TREE("id"))'="":$GET(TREE("id")),1:$GET(TREE("path")))
	IF '$$READ^MIOOSFS(.STATE,ID,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"fs.read","vfs",.OUT)
	QUIT 1
	;
FSWRITE(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT,PARENT,NAME
	SET PARENT=$SELECT($GET(TREE("parent"))'="":$GET(TREE("parent")),1:"root")
	SET NAME=$GET(TREE("name"))
	IF '$$WRITE^MIOOSFS(.STATE,PARENT,NAME,$GET(TREE("content")),$GET(TREE("mime"),"text/plain"),.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"fs.write","vfs",.OUT)
	QUIT 1
	;
FSMKDIR(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$MKDIR^MIOOSFS(.STATE,$SELECT($GET(TREE("parent"))'="":$GET(TREE("parent")),1:"root"),$GET(TREE("name")),.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"fs.mkdir","vfs",.OUT)
	QUIT 1
	;
FSMETA(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT,ID
	SET ID=$SELECT($GET(TREE("id"))'="":$GET(TREE("id")),1:$GET(TREE("path")))
	IF '$$META^MIOOSFS(.STATE,ID,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"fs.meta","vfs",.OUT)
	QUIT 1
	;
FSRENAME(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$RENAME^MIOOSFS(.STATE,$GET(TREE("id")),$GET(TREE("name")),.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"fs.rename","vfs",.OUT)
	QUIT 1
	;
FSMOVE(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$MOVE^MIOOSFS(.STATE,$GET(TREE("id")),$GET(TREE("parent")),.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"fs.move","vfs",.OUT)
	QUIT 1
	;
FSDELETE(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$DELETE^MIOOSFS(.STATE,$GET(TREE("id")),.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"fs.delete","vfs",.OUT)
	QUIT 1

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
	SET OBJ("authenticated")=+$GET(STATE("authenticated"),0)
	SET OBJ("localeCode")=$GET(STATE("localeCode"),"en")
	SET OBJ("localeDir")=$GET(STATE("localeDir"),"ltr")
	SET OBJ("commandEvent")=$GET(STATE("commandEvent"),"desktop.command")
	SET OBJ("commandResultEvent")=$GET(STATE("commandResultEvent"),"desktop.result")
	SET OBJ("realtimeContract")=$GET(STATE("transportModel"),"core-websocket-plus-app-websockets")
	SET OBJ("terminalEngine")=$GET(STATE("terminal","engine"),"xtermjs")
	SET OBJ("terminalTransport")=$GET(STATE("terminal","transport"),"pipe")
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
	SET OBJ("localeCode")=$GET(STATE("localeCode"),"en")
	MERGE OBJ("view")=VIEW
	QUIT $$EN^MIOJSON1(.OBJ)
	;
ACKJSON(STATE,EVENT,VALUE)
	NEW OBJ
	SET OBJ("event")=$GET(EVENT)
	SET OBJ("ok")=1
	SET OBJ("value")=$GET(VALUE)
	SET OBJ("sessionId")=$GET(STATE("sessionId"))
	QUIT $$EN^MIOJSON1(.OBJ)
	;
CMDOKJSON(STATE,REQID,CMD,ROOT,OUT)
	NEW OBJ
	SET OBJ("event")=$GET(STATE("commandResultEvent"),"desktop.result")
	SET OBJ("ok")=1
	SET OBJ("requestId")=$GET(REQID)
	SET OBJ("command")=$GET(CMD)
	SET OBJ("sessionId")=$GET(STATE("sessionId"))
	MERGE OBJ($GET(ROOT,"result"))=OUT
	QUIT $$EN^MIOJSON1(.OBJ)
	;
CMDERRJSON(STATE,REQID,CMD,STATUS,CODE,DETAIL)
	NEW OBJ
	SET OBJ("event")=$GET(STATE("commandErrorEvent"),"desktop.error")
	SET OBJ("ok")=0
	SET OBJ("requestId")=$GET(REQID)
	SET OBJ("command")=$GET(CMD)
	SET OBJ("status")=+$GET(STATUS,400)
	SET OBJ("error")=$GET(CODE)
	SET OBJ("detail")=$GET(DETAIL)
	SET OBJ("routine")="MIOOSWS"
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
	SET OBJ("routine")="MIOOSWS"
	QUIT $$EN^MIOJSON1(.OBJ)


TRUPBEGIN(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$BEGIN^MIOOSTRXUP(.STATE,.CONF,.TREE,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"transfer.upload.begin","transfer",.OUT)
	QUIT 1
	;
TRUPCHUNK(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$CHUNK^MIOOSTRXUP(.STATE,.CONF,.TREE,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"transfer.upload.chunk","transfer",.OUT)
	QUIT 1
	;
TRUPCOMMIT(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$COMMIT^MIOOSTRXUP(.STATE,.CONF,.TREE,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"transfer.upload.commit","transfer",.OUT)
	QUIT 1
	;
TRUPABORT(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$ABORT^MIOOSTRXUP(.STATE,.CONF,.TREE,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"transfer.upload.abort","transfer",.OUT)
	QUIT 1
	;
TRUPSTATUS(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$STATUS^MIOOSTRXUP(.STATE,.CONF,.TREE,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"transfer.upload.status","transfer",.OUT)
	QUIT 1
	;
TRDNBGIN(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$BEGIN^MIOOSTRXDN(.STATE,.CONF,.TREE,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"transfer.download.begin","transfer",.OUT)
	QUIT 1
	;
TRDNCHNK(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$CHUNK^MIOOSTRXDN(.STATE,.CONF,.TREE,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"transfer.download.chunk","transfer",.OUT)
	QUIT 1
	;
TRDNEND(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$END^MIOOSTRXDN(.STATE,.CONF,.TREE,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"transfer.download.end","transfer",.OUT)
	QUIT 1
	;
TRDNABRT(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$ABORT^MIOOSTRXDN(.STATE,.CONF,.TREE,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"transfer.download.abort","transfer",.OUT)
	QUIT 1
	;
TRDNSTAT(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$STATUS^MIOOSTRXDN(.STATE,.CONF,.TREE,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"transfer.download.status","transfer",.OUT)
	QUIT 1
	;
