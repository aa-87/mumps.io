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
	. DO REGPAYL(.STATE,$GET(CTX("payload")))
	. SET RESP=$$HELLOJSON(.STATE,.CONF)
	. DO SENDTEXT^MIOWS(.DEV,RESP)
	IF EVT="ping" DO  QUIT
	. DO REGPAYL(.STATE,$GET(CTX("payload")))
	. SET RESP=$$PONGJSON(.STATE)
	. DO SENDTEXT^MIOWS(.DEV,RESP)
	IF EVT="view.refresh" DO  QUIT
	. IF +$GET(STATE("authRequired"),0)=1,+$GET(STATE("authenticated"),0)'=1 DO
	. . DO SENDTEXT^MIOWS(.DEV,$$ERRJSON(.STATE,"login_required","view.refresh",""))
	. . QUIT
	. DO BUILD^MIOOSVM(.STATE,.CONF,.VIEW)
	. SET RESP=$$VIEWJSON(.STATE,.VIEW)
	. DO SENDTEXT^MIOWS(.DEV,RESP)
	IF EVT="shell.open" DO  QUIT
	. IF +$GET(STATE("authRequired"),0)=1,+$GET(STATE("authenticated"),0)'=1 DO
	. . DO SENDTEXT^MIOWS(.DEV,$$ERRJSON(.STATE,"login_required","shell.open",""))
	. . QUIT
	. DO SENDTEXT^MIOWS(.DEV,$$ACKJSON(.STATE,"shell.open",$$FIELD($GET(CTX("payload")),"appKey")))
	IF EVT="desktop.command"!(EVT="command.exec") DO  QUIT
	. DO REGPAYL(.STATE,$GET(CTX("payload")))
	. IF +$GET(STATE("authRequired"),0)=1,+$GET(STATE("authenticated"),0)'=1 DO  QUIT
	. . DO SENDTEXT^MIOWS(.DEV,$$CMDERRJSON(.STATE,$$RAWJSONFIELD($GET(CTX("payload")),"requestId"),$$RAWJSONFIELD($GET(CTX("payload")),"command"),401,"login_required",$$RAWJSONFIELD($GET(CTX("payload")),"command")))
	. IF $$COMMANDJSON(.CONF,.REQ,.CTX,.STATE,$GET(CTX("payload")),.RESP,.ERR) DO  IF 1
	. . DO SENDTEXT^MIOWS(.DEV,RESP)
	. ELSE  DO
	. . DO SENDTEXT^MIOWS(.DEV,$$CMDERRJSON(.STATE,$GET(ERR("requestId")),$GET(ERR("command")),500,$GET(ERR("error"),"command_error"),$GET(ERR("detail"))))
	DO SENDTEXT^MIOWS(.DEV,$$ERRJSON(.STATE,"unsupported_event",EVT,""))
	QUIT
	;
COMMANDJSON(CONF,REQ,CTX,STATE,PAYLOAD,OUTJSON,ERR)
	N $ET S $ET="G STERR^MIOD"
	NEW TREE,CMD,REQID
	KILL ERR
	SET ERR("routine")="MIOOSWS"
	SET REQID=$$RAWJSONFIELD($GET(PAYLOAD),"requestId")
	SET CMD=$$RAWJSONFIELD($GET(PAYLOAD),"command")
	SET ERR("requestId")=REQID,ERR("command")=CMD
	IF '$$DECODE^MIOJSON($GET(PAYLOAD),.TREE,.ERR) SET ERR("error")="payload_invalid_json" QUIT 0
	SET CMD=$SELECT($GET(TREE("command"))'="":$GET(TREE("command")),1:CMD)
	SET REQID=$SELECT($GET(TREE("requestId"))'="":$GET(TREE("requestId")),1:REQID)
	SET ERR("requestId")=REQID,ERR("command")=CMD
	IF CMD="" SET ERR("error")="command_missing" QUIT 0
	IF CMD="terminal.open"!(CMD="terminal.attach") QUIT $$CMDOPEN(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="terminal.input" QUIT $$CMDINPUT(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="terminal.poll" QUIT $$CMDPOLL(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="terminal.resize" QUIT $$CMDRESIZE(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="terminal.close" QUIT $$CMDCLOSE(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="terminal.list" QUIT $$CMDLIST(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.list" QUIT $$FSLIST(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.read" QUIT $$FSREAD(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.read.range" QUIT $$FSREADRNG(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.write" QUIT $$FSWRITE(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.upload.begin" QUIT $$FSUPBEGIN(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.upload.chunk" QUIT $$FSUPCHUNK(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.upload.batch" QUIT $$FSUPBATCH(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.upload.commit" QUIT $$FSUPCOMMIT(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.upload.abort" QUIT $$FSUPABORT(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.mkdir" QUIT $$FSMKDIR(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.meta" QUIT $$FSMETA(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.setmeta" QUIT $$FSSETMETA(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.rename" QUIT $$FSRENAME(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.move" QUIT $$FSMOVE(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.copy" QUIT $$FSCOPY(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="fs.delete" QUIT $$FSDELETE(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="transport.health" QUIT $$TRANHEALTH(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="auth.report" QUIT $$AUTHREPORT(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="auth.audit" QUIT $$AUTHAUDIT(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="auth.sessions" QUIT $$AUTHSESS(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="auth.session.revoke" QUIT $$AUTHREVOKE(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="auth.accounts" QUIT $$AUTHACCTS(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="auth.user.unlock" QUIT $$AUTHUNLOCK(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="view.refresh" QUIT $$CMDVIEW(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="module.catalog" QUIT $$MODCAT(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="table.query" QUIT $$TABLEQUERY(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="table.mutate" QUIT $$TABLEMUTATE(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="debug.snapshot" QUIT $$DEBUGSNAP(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
	IF CMD="desktop.layout.save" QUIT $$DESKLAYOUT(.STATE,.CONF,.TREE,.OUTJSON,.ERR)
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
	NEW OUT,TARGET
	SET TARGET=$$FSTARGET(.TREE)
	IF '$$LIST^MIOOSFS(.STATE,TARGET,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"fs.list","vfs",.OUT)
	QUIT 1
	;
FSTARGET(TREE)
	IF $GET(TREE("id"))'="" QUIT $GET(TREE("id"))
	IF $GET(TREE("path"))'="" QUIT $GET(TREE("path"))
	IF $GET(TREE("parent"))'="" QUIT $GET(TREE("parent"))
	QUIT "root"
	;
FSREAD(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT,ID
	SET ID=$SELECT($GET(TREE("id"))'="":$GET(TREE("id")),1:$GET(TREE("path")))
	IF '$$READ^MIOOSFS(.STATE,ID,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"fs.read","vfs",.OUT)
	QUIT 1
	;
FSREADRNG(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT,ID,SIZE
	SET ID=$SELECT($GET(TREE("id"))'="":$GET(TREE("id")),1:$GET(TREE("path")))
	SET SIZE=+$GET(TREE("size")) IF SIZE<1 SET SIZE=+$GET(CONF("mioos","fs","readPreviewBytes"),16384)
	IF '$$READWIN^MIOOSFS(.STATE,ID,+$GET(TREE("offset")),SIZE,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"fs.read.range","vfs",.OUT)
	QUIT 1
	;
	;
	;
	;
FSWRITE(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT,PARENT,NAME
	SET PARENT=$SELECT($GET(TREE("parent"))'="":$GET(TREE("parent")),1:"root")
	SET NAME=$GET(TREE("name"))
	IF '$$WRITE^MIOOSFS(.STATE,PARENT,NAME,$GET(TREE("content")),$GET(TREE("mime"),"text/plain"),.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"fs.write","vfs",.OUT)
	QUIT 1
	;
FSUPBEGIN(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT,PARENT,NAME,MIME,TOTAL,ENC
	SET PARENT=$SELECT($GET(TREE("parent"))'="":$GET(TREE("parent")),1:"root")
	SET NAME=$GET(TREE("name"))
	SET MIME=$GET(TREE("mime"),"application/octet-stream")
	SET TOTAL=+$GET(TREE("totalBytes"))
	SET ENC=$GET(TREE("encoding"),"base64-dataurl")
	IF '$$BEGIN^MIOOSFSUP(.STATE,.CONF,PARENT,NAME,MIME,TOTAL,ENC,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"fs.upload.begin","vfs",.OUT)
	QUIT 1
	;
FSUPCHUNK(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$CHUNK^MIOOSFSUP(.STATE,.CONF,$GET(TREE("uploadId")),+$GET(TREE("index")),$GET(TREE("data")),+$GET(TREE("bytes")),.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"fs.upload.chunk","vfs",.OUT)
	QUIT 1
	;
FSUPBATCH(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT,CHROOT
	SET CHROOT=$NAME(TREE("chunks"))
	IF '$DATA(@CHROOT@(1)) SET ERR("error")="upload_batch_missing" QUIT 0
	IF '$$BATCH^MIOOSFSUP(.STATE,.CONF,$GET(TREE("uploadId")),CHROOT,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"fs.upload.batch","vfs",.OUT)
	QUIT 1
	;
	;
FSUPCOMMIT(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$COMMIT^MIOOSFSUP(.STATE,.CONF,$GET(TREE("uploadId")),.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"fs.upload.commit","vfs",.OUT)
	QUIT 1
	;
FSUPABORT(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$ABORT^MIOOSFSUP(.STATE,.CONF,$GET(TREE("uploadId")),.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"fs.upload.abort","vfs",.OUT)
	QUIT 1
	;
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
FSSETMETA(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT,ID
	SET ID=$SELECT($GET(TREE("id"))'="":$GET(TREE("id")),1:$GET(TREE("path")))
	IF '$$SETMETA^MIOOSFS(.STATE,ID,.TREE,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"fs.setmeta","vfs",.OUT)
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
FSCOPY(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$COPY^MIOOSFS(.STATE,$GET(TREE("id")),$GET(TREE("parent")),$GET(TREE("name")),.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"fs.copy","vfs",.OUT)
	QUIT 1
	;
FSDELETE(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$DELETE^MIOOSFS(.STATE,$GET(TREE("id")),.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"fs.delete","vfs",.OUT)
	QUIT 1
	;
AUTHREPORT(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT,CRED,CERR
	IF '$$REPORT^MIOOSAUD(.STATE,.CONF,.OUT,.ERR) QUIT 0
	IF $$CREDREPORT^MIOOSAUTH(.STATE,.CONF,.CRED,.CERR) MERGE OUT("credentials")=CRED
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"auth.report","auth",.OUT)
	QUIT 1
	;
AUTHAUDIT(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT,LIMIT
	SET LIMIT=+$GET(TREE("limit"),+$GET(CONF("mioos","audit","reportLimit"),20))
	IF LIMIT<1 SET LIMIT=+$GET(CONF("mioos","audit","reportLimit"),20)
	IF '$$TAIL^MIOOSAUD(.STATE,.CONF,LIMIT,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"auth.audit","auth",.OUT)
	QUIT 1
	;
AUTHSESS(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT,LIMIT
	SET LIMIT=+$GET(TREE("limit"),+$GET(CONF("mioos","auth","management","sessionLimit"),20))
	IF LIMIT<1 SET LIMIT=+$GET(CONF("mioos","auth","management","sessionLimit"),20)
	IF '$$SESSIONS^MIOOSAUTH(.STATE,.CONF,LIMIT,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"auth.sessions","auth",.OUT)
	QUIT 1
	;
AUTHREVOKE(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$REVOKESESSION^MIOOSAUTH(.STATE,.CONF,$GET(TREE("sessionId")),.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"auth.session.revoke","auth",.OUT)
	QUIT 1
	;
AUTHACCTS(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT,LIMIT
	SET LIMIT=+$GET(TREE("limit"),+$GET(CONF("mioos","auth","management","accountLimit"),20))
	IF LIMIT<1 SET LIMIT=+$GET(CONF("mioos","auth","management","accountLimit"),20)
	IF '$$ACCOUNTS^MIOOSAUTH(.STATE,.CONF,LIMIT,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"auth.accounts","auth",.OUT)
	QUIT 1
	;
AUTHUNLOCK(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$UNLOCKUSER^MIOOSAUTH(.STATE,.CONF,$GET(TREE("username")),.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"auth.user.unlock","auth",.OUT)
	QUIT 1
	;
MODCAT(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$CATALOG^MIOOSMOD(.STATE,.CONF,.OUT,.ERR) QUIT 0
	SET OUT("enabled")=+$GET(STATE("moduleSystemEnabled"),0)
	SET OUT("count")=+$GET(OUT("moduleCount"),0)
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"module.catalog","module",.OUT)
	QUIT 1
	;
TABLEQUERY(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF +$GET(STATE("authRequired"),0)=1,+$GET(STATE("authenticated"),0)'=1 SET ERR("error")="login_required",ERR("detail")="table.query" QUIT 0
	IF '$$QUERY^MIOOSTBL(.STATE,.CONF,.TREE,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"table.query","table",.OUT)
	QUIT 1
	;
TABLEMUTATE(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF +$GET(STATE("authRequired"),0)=1,+$GET(STATE("authenticated"),0)'=1 DO  QUIT 1
	. SET OUT("ok")=0,OUT("error")="login_required",OUT("detail")="table.mutate"
	. SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"table.mutate","table",.OUT)
	IF '$$MUTATE^MIOOSTBL(.STATE,.CONF,.TREE,.OUT,.ERR) DO  QUIT 1
	. SET OUT("ok")=0,OUT("error")="table_mutate_failed",OUT("detail")=$GET(ERR("error")),OUT("routine")=$GET(ERR("routine"),"MIOOSTBL"),OUT("field")=$GET(ERR("field")),OUT("message")=$GET(ERR("message"),$GET(ERR("error"))),OUT("mutationOnly")=1,OUT("refetch")=0
	. IF $DATA(ERR("fieldErrors")) MERGE OUT("fieldErrors")=ERR("fieldErrors")
	. SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"table.mutate","table",.OUT)
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"table.mutate","table",.OUT)
	QUIT 1
	;
DEBUGSNAP(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$SNAPSHOT(.STATE,.CONF,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"debug.snapshot","debug",.OUT)
	QUIT 1
	;
SNAPSHOT(STATE,CONF,OUT,ERR)
	NEW I
	KILL OUT
	SET ERR("routine")="MIOOSWS"
	SET OUT("snapshotVersion")=+$GET(STATE("debugSnapshotVersion"),1)
	SET OUT("sessionId")=$GET(STATE("sessionId"))
	SET OUT("profile")=$GET(STATE("profile"),"dev")
	SET OUT("principal")=$GET(STATE("principal"),"guest")
	SET OUT("authenticated")=+$GET(STATE("authenticated"),0)
	SET OUT("localeCode")=$GET(STATE("localeCode"),"en")
	SET OUT("localeDir")=$GET(STATE("localeDir"),"ltr")
	SET OUT("routes","commandEvent")=$GET(STATE("commandEvent"),"desktop.command")
	SET OUT("routes","commandResultEvent")=$GET(STATE("commandResultEvent"),"desktop.result")
	SET OUT("routes","commandErrorEvent")=$GET(STATE("commandErrorEvent"),"desktop.error")
	SET OUT("routes","debugSnapshotCommand")="debug.snapshot"
	SET OUT("routes","viewCommand")="view.refresh"
	SET OUT("counts","apps")=$$COUNTARY("apps",.STATE)
	SET OUT("counts","windows")=$$COUNTARY("windows",.STATE)
	SET OUT("counts","modules")=+$GET(STATE("moduleCount"),0)
	SET OUT("transport","model")=$GET(STATE("transportModel"),"core-websocket-plus-app-websockets")
	SET OUT("transport","heartbeatSeconds")=+$GET(STATE("wsHeartbeatSeconds"),15)
	SET OUT("transport","resumeWindowSeconds")=+$GET(STATE("wsResumeWindowSeconds"),180)
	SET OUT("transport","maxInflightPerChannel")=+$GET(STATE("wsMaxInflightPerChannel"),4)
	SET OUT("transport","diagnosticsEnabled")=+$GET(STATE("wsDiagnosticsEnabled"),1)
	SET OUT("vfs","enabled")=+$GET(STATE("fsEnabled"),1)
	SET OUT("vfs","rootId")=$GET(STATE("fsRootId"),"root")
	SET OUT("vfs","homeId")=$GET(STATE("fsHomeId"),"root")
	SET OUT("terminal","engine")=$GET(STATE("terminal","engine"),"xtermjs")
	SET OUT("terminal","transport")=$GET(STATE("terminal","transport"),"pipe")
	SET OUT("auth","required")=+$GET(STATE("authRequired"),0)
	SET OUT("auth","mode")=$GET(STATE("authMode"),"local-session-required")
	SET OUT("auth","framework")=$GET(STATE("frameworkAuthMode"),"mioauth-session-jwt")
	SET OUT("debug","enabled")=+$GET(STATE("debugEnabled"),1)
	SET OUT("debug","eventLimit")=+$GET(STATE("debugEventLimit"),50)
	SET OUT("debug","commands",1)="view.refresh"
	SET OUT("debug","commands",2)="transport.health"
	SET OUT("debug","commands",3)="module.catalog"
	SET OUT("debug","commands",4)="auth.report"
	SET OUT("debug","commands",5)="auth.audit"
	SET OUT("debug","commands",6)="auth.sessions"
	SET OUT("debug","commands",7)="auth.session.revoke"
	SET OUT("debug","commands",8)="auth.accounts"
	SET OUT("debug","commands",9)="auth.user.unlock"
	SET OUT("debug","commands",10)="debug.snapshot"
	SET I=0 FOR  SET I=$ORDER(STATE("modules",I)) QUIT:I'>0  DO
	. SET OUT("modules",I,"id")=$GET(STATE("modules",I,"id"))
	. SET OUT("modules",I,"title")=$GET(STATE("modules",I,"title"))
	. SET OUT("modules",I,"surface")=$GET(STATE("modules",I,"surface"))
	QUIT 1
	;
COUNTARY(NAME,STATE)
	NEW I,N
	SET (I,N)=0
	FOR  SET I=$ORDER(STATE(NAME,I)) QUIT:I'>0  SET N=N+1
	QUIT N
	;
REGPAYL(STATE,PAYLOAD)
	NEW TREE,ERR,EVT
	IF $EXTRACT($GET(PAYLOAD),1)'="{" QUIT
	IF '$$DECODE^MIOJSON($GET(PAYLOAD),.TREE,.ERR) QUIT
	SET EVT=$GET(TREE("event"))
	IF EVT="" SET EVT="message"
	DO TOUCHSOCK(.STATE,.TREE,EVT)
	QUIT
	;
TOUCHSOCK(STATE,TREE,EVT)
	NEW SID,ROLE,ORD,SOCKETID,NOW,ROOT,LABEL
	SET SID=$GET(STATE("sessionId")) IF SID="" QUIT
	SET ROLE=$SELECT($GET(TREE("socketRole"))'="":$GET(TREE("socketRole")),$GET(TREE("role"))'="":$GET(TREE("role")),1:"core")
	SET ORD=+$GET(TREE("socketOrdinal")) IF ORD<1 SET ORD=1
	SET SOCKETID=$GET(TREE("socketId"))
	IF SOCKETID="" SET SOCKETID=ROLE_"-"_ORD
	SET NOW=$$NOW^MIOOSFSUP()
	SET LABEL=$SELECT(ROLE="fs":"FS Worker "_ORD,ROLE="core":"Core Socket",ROLE="terminal":"Terminal Socket "_ORD,1:ROLE_" Socket "_ORD)
	SET ROOT=$NAME(^MIO("MIOOS","WS","SESSION",SID,"SOCKETS",SOCKETID))
	SET @ROOT@("socketId")=SOCKETID
	SET @ROOT@("role")=ROLE
	SET @ROOT@("ordinal")=ORD
	SET @ROOT@("label")=LABEL
	IF $GET(@ROOT@("firstSeen"))="" SET @ROOT@("firstSeen")=NOW
	IF $GET(EVT)="hello" SET @ROOT@("helloAt")=NOW
	SET @ROOT@("lastSeen")=NOW
	SET @ROOT@("lastEvent")=$SELECT($GET(TREE("command"))'="":$GET(TREE("command")),1:$GET(EVT))
	SET @ROOT@("state")=$SELECT($GET(EVT)="hello":"ready",$GET(EVT)="ping":"open",1:"active")
	SET @ROOT@("principal")=$GET(STATE("principal"),"guest")
	SET @ROOT@("profile")=$GET(STATE("profile"),"dev")
	SET ^MIO("MIOOS","WS","SESSION",SID,"updatedAt")=NOW
	SET ^MIO("MIOOS","WS","SESSION",SID,"principal")=$GET(STATE("principal"),"guest")
	QUIT
	;
SOCKPURGE(STATE)
	NEW SID,ROOT,SOCKETID,NOW,TTL,LAST,COUNT
	SET SID=$GET(STATE("sessionId")) IF SID="" QUIT 0
	SET ROOT=$NAME(^MIO("MIOOS","WS","SESSION",SID,"SOCKETS"))
	SET NOW=$$NOW^MIOOSFSUP(),TTL=+$GET(STATE("wsResumeWindowSeconds"),180)
	IF TTL<30 SET TTL=30
	SET TTL=TTL*2
	SET (COUNT,SOCKETID)=0
	FOR  SET SOCKETID=$ORDER(@ROOT@(SOCKETID)) QUIT:SOCKETID=""  DO
	. SET LAST=$GET(@ROOT@(SOCKETID,"lastSeen"))
	. IF LAST="" SET LAST=$GET(@ROOT@(SOCKETID,"firstSeen"))
	. IF $$SECSDIFF^MIOOSFSUP(LAST,NOW)>TTL KILL @ROOT@(SOCKETID) SET COUNT=COUNT+1
	QUIT COUNT
	;
SOCKSUM(STATE,OUT)
	NEW SID,ROOT,SOCKETID,IDX,ROLE
	SET SID=$GET(STATE("sessionId")) IF SID="" QUIT
	SET ROOT=$NAME(^MIO("MIOOS","WS","SESSION",SID,"SOCKETS"))
	SET OUT("socketPool","activeCount")=0
	SET (SOCKETID,IDX)=""
	SET IDX=0
	FOR  SET SOCKETID=$ORDER(@ROOT@(SOCKETID)) QUIT:SOCKETID=""  DO
	. SET IDX=IDX+1
	. SET ROLE=$GET(@ROOT@(SOCKETID,"role"),"core")
	. SET OUT("socketPool","activeCount")=+$GET(OUT("socketPool","activeCount"))+1
	. SET OUT("socketPool","roleCounts",ROLE)=+$GET(OUT("socketPool","roleCounts",ROLE))+1
	. SET OUT("socketPool","sockets",IDX,"id")=SOCKETID
	. SET OUT("socketPool","sockets",IDX,"label")=$GET(@ROOT@(SOCKETID,"label"),SOCKETID)
	. SET OUT("socketPool","sockets",IDX,"role")=ROLE
	. SET OUT("socketPool","sockets",IDX,"ordinal")=+$GET(@ROOT@(SOCKETID,"ordinal"),1)
	. SET OUT("socketPool","sockets",IDX,"state")=$GET(@ROOT@(SOCKETID,"state"),"active")
	. SET OUT("socketPool","sockets",IDX,"lastEvent")=$GET(@ROOT@(SOCKETID,"lastEvent"))
	. SET OUT("socketPool","sockets",IDX,"ageSeconds")=$$SECSDIFF^MIOOSFSUP($GET(@ROOT@(SOCKETID,"lastSeen")),$$NOW^MIOOSFSUP())
	QUIT
	;
TRANHEALTH(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$HEALTH(.STATE,.CONF,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"transport.health","transport",.OUT)
	QUIT 1
	;
HEALTH(STATE,CONF,OUT,ERR)
	NEW TERM,COUNT,SKEY,DLID,UPID,META,OWNER,IDX
	KILL OUT
	SET ERR("routine")="MIOOSWS"
	SET OUT("sessionId")=$GET(STATE("sessionId"))
	SET OUT("principal")=$GET(STATE("principal"),"guest")
	SET OUT("authenticated")=+$GET(STATE("authenticated"),0)
	SET OUT("profile")=$GET(STATE("profile"),"dev")
	SET OUT("localeCode")=$GET(STATE("localeCode"),"en")
	SET OUT("transportModel")=$GET(STATE("transportModel"),"core-websocket-plus-app-websockets")
	SET OUT("diagnosticsEnabled")=+$GET(STATE("wsDiagnosticsEnabled"),1)
	SET OUT("websocket","heartbeatSeconds")=+$GET(STATE("wsHeartbeatSeconds"),15)
	SET OUT("websocket","resumeWindowSeconds")=+$GET(STATE("wsResumeWindowSeconds"),180)
	SET OUT("websocket","maxInflightPerChannel")=+$GET(STATE("wsMaxInflightPerChannel"),4)
	SET OUT("websocket","maxSocketsPerSession")=+$GET(STATE("wsMaxSockets"),1)
	SET OUT("websocket","coreSockets")=+$GET(STATE("wsCoreSockets"),1)
	SET OUT("websocket","fsSockets")=+$GET(STATE("wsFsSockets"),1)
	SET OUT("websocket","uploadBatchSize")=+$GET(STATE("uploadBatchSize"),1)
	SET OUT("websocket","uploadMaxInflightChunks")=+$GET(STATE("uploadMaxInflightChunks"),+$GET(STATE("uploadBatchSize"),1))
	SET OUT("websocket","batchFlushThreshold")=+$GET(STATE("uploadBatchFlushThreshold"),+$GET(STATE("uploadBatchSize"),1))
	SET OUT("websocket","requestTimeoutMs")=+$GET(STATE("wsRequestTimeoutMs"),15000)
	SET OUT("websocket","maxFrameBytes")=+$GET(STATE("wsMaxFrameBytes"),262144)
	SET OUT("websocket","maxMessageBytes")=+$GET(STATE("wsMaxMessageBytes"),1048576)
	SET OUT("vfs","rootId")=$GET(STATE("fsRootId"),"root")
	SET OUT("vfs","homeId")=$GET(STATE("fsHomeId"),"root")
	SET OUT("vfs","uploadStaleSeconds")=+$GET(STATE("uploadStaleSeconds"),1800)
	SET OUT("vfs","downloadStaleSeconds")=+$GET(STATE("downloadStaleSeconds"),900)
	SET OUT("vfs","uploadConcurrency")=$$UPCONCUR^MIOOSFSUP(.CONF)
	SET OUT("vfs","uploadChunkBytes")=$$UPCHUNK^MIOOSFSUP(.CONF)
	SET OUT("vfs","uploadBatchSize")=+$GET(STATE("uploadBatchSize"),1)
	SET OUT("vfs","uploadMaxInflightChunks")=+$GET(STATE("uploadMaxInflightChunks"),+$GET(STATE("uploadBatchSize"),1))
	SET OUT("vfs","batchFlushThreshold")=+$GET(STATE("uploadBatchFlushThreshold"),+$GET(STATE("uploadBatchSize"),1))
	SET (OUT("uploads","activeCount"),OUT("uploads","receivedBytes"),OUT("uploads","declaredBytes"))=0
	SET OUT("uploads","batchSize")=+$GET(STATE("uploadBatchSize"),1)
	SET OUT("uploads","maxInflightChunks")=+$GET(STATE("uploadMaxInflightChunks"),+$GET(STATE("uploadBatchSize"),1))
	SET UPID=""
	FOR  SET UPID=$ORDER(^MIO("MIOOS","UPLOAD","META",UPID)) QUIT:UPID=""  DO
	. SET META=$GET(^MIO("MIOOS","UPLOAD","META",UPID))
	. SET OWNER=$PIECE(META,"^",4)
	. IF OWNER'=$GET(STATE("principal"),"guest") QUIT
	. SET OUT("uploads","activeCount")=OUT("uploads","activeCount")+1
	. SET OUT("uploads","receivedBytes")=OUT("uploads","receivedBytes")+$GET(^MIO("MIOOS","UPLOAD","INFO",UPID,"bytes"))
	. SET OUT("uploads","declaredBytes")=OUT("uploads","declaredBytes")+$PIECE(META,"^",7)
	SET (OUT("downloads","activeCount"),OUT("downloads","bytes"))=0
	SET SKEY=$GET(STATE("sessionId"))
	SET DLID=""
	FOR  SET DLID=$ORDER(^MIO("MIOOS","DL",SKEY,DLID)) QUIT:DLID=""  DO
	. SET OUT("downloads","activeCount")=OUT("downloads","activeCount")+1
	. SET OUT("downloads","bytes")=OUT("downloads","bytes")+$GET(^MIO("MIOOS","DL",SKEY,DLID,"size"))
	SET OUT("socketPool","maxSocketsPerSession")=+$GET(STATE("wsMaxSockets"),1)
	SET OUT("socketPool","coreSockets")=+$GET(STATE("wsCoreSockets"),1)
	SET OUT("socketPool","fsSockets")=+$GET(STATE("wsFsSockets"),1)
	SET OUT("socketPool","stalePurged")=$$SOCKPURGE(.STATE)
	DO SOCKSUM(.STATE,.OUT)
	SET OUT("socketPool","capacityRemaining")=$SELECT(+$GET(OUT("socketPool","activeCount"))<+$GET(OUT("socketPool","maxSocketsPerSession")):+$GET(OUT("socketPool","maxSocketsPerSession"))-+$GET(OUT("socketPool","activeCount")),1:0)
	KILL TERM DO LIST^MIOOSTERM(.STATE,$NAME(TERM("sessions")))
	SET (COUNT,IDX)=0 FOR  SET IDX=$ORDER(TERM("sessions",IDX)) QUIT:IDX'>0  SET COUNT=COUNT+1
	SET OUT("terminal","openCount")=COUNT
	SET OUT("terminal","maxSessions")=+$GET(STATE("terminal","maxSessions"),8)
	SET OUT("terminal","engine")=$GET(STATE("terminal","engine"),"xtermjs")
	SET OUT("terminal","transport")=$GET(STATE("terminal","transport"),"pipe")
	QUIT 1
	;
DESKLAYOUT(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	IF '$$SAVELAYOUT^MIOOSST(.STATE,.TREE,.OUT,.ERR) QUIT 0
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"desktop.layout.save","desktop",.OUT)
	QUIT 1
	;
CMDVIEW(STATE,CONF,TREE,OUTJSON,ERR)
	NEW OUT
	DO BUILD^MIOOSVM(.STATE,.CONF,.OUT)
	SET OUTJSON=$$CMDOKJSON(.STATE,$GET(TREE("requestId")),"view.refresh","view",.OUT)
	QUIT 1
	;
	;
RAWJSONFIELD(PAYLOAD,NAME)
	NEW PAT,POS,REST,ENDQ,VAL
	SET PAT=""""_$GET(NAME)_""":"""
	SET POS=$FIND($GET(PAYLOAD),PAT)
	IF POS'>0 QUIT ""
	SET REST=$EXTRACT($GET(PAYLOAD),POS,256000)
	SET ENDQ=$FIND(REST,"""")
	IF ENDQ'>0 QUIT ""
	SET VAL=$EXTRACT(REST,1,ENDQ-2)
	QUIT VAL
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
	SET OBJ("authenticated")=+$GET(STATE("authenticated"),0)
	SET OBJ("localeCode")=$GET(STATE("localeCode"),"en")
	SET OBJ("localeDir")=$GET(STATE("localeDir"),"ltr")
	SET OBJ("commandEvent")=$GET(STATE("commandEvent"),"desktop.command")
	SET OBJ("commandResultEvent")=$GET(STATE("commandResultEvent"),"desktop.result")
	SET OBJ("realtimeContract")=$GET(STATE("transportModel"),"core-websocket-plus-app-websockets")
	SET OBJ("socketPool","heartbeatSeconds")=+$GET(STATE("wsHeartbeatSeconds"),15)
	SET OBJ("socketPool","resumeWindowSeconds")=+$GET(STATE("wsResumeWindowSeconds"),180)
	SET OBJ("socketPool","maxInflightPerChannel")=+$GET(STATE("wsMaxInflightPerChannel"),4)
	SET OBJ("socketPool","maxSocketsPerSession")=+$GET(STATE("wsMaxSockets"),1)
	SET OBJ("socketPool","coreSockets")=+$GET(STATE("wsCoreSockets"),1)
	SET OBJ("socketPool","fsSockets")=+$GET(STATE("wsFsSockets"),1)
	SET OBJ("socketPool","uploadBatchSize")=+$GET(STATE("uploadBatchSize"),1)
	SET OBJ("socketPool","batchFlushThreshold")=+$GET(STATE("uploadBatchFlushThreshold"),+$GET(STATE("uploadBatchSize"),1))
	SET OBJ("socketPool","diagnosticsEnabled")=+$GET(STATE("wsDiagnosticsEnabled"),1)
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
	;