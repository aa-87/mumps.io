MIOOSTRX ; MIOOS transfer shared helpers
	QUIT
	;
ROOT()
	QUIT $NAME(^MIO("MIOOS","TRANSFER"))
	;
NEXTID()
	NEW N
	SET N=$INCREMENT(^MIO("MIOOS","TRANSFER","SEQ"))
	QUIT "trx-"_N
	;
CHUNK(CONF)
	NEW N
	SET N=+$GET(CONF("mioos","transfer","chunkSize"),24576)
	IF N<1024 SET N=1024
	IF N>32768 SET N=32768
	QUIT N
	;
LEASE(CONF,DIR)
	NEW N
	SET N=+$SELECT($GET(DIR)="download":$GET(CONF("mioos","transfer","downloadWorkers"),2),1:$GET(CONF("mioos","transfer","uploadWorkers"),2))
	IF N<1 SET N=1
	IF N>70 SET N=70
	QUIT N
	;
RESUME(CONF)
	NEW N
	SET N=+$GET(CONF("mioos","transfer","resumeSeconds"),1800)
	IF N<60 SET N=60
	QUIT N
	;
INIT(STATE,CONF,DIR,META,OUT,ERR)
	NEW ID,NOW,USER
	KILL OUT
	SET ERR("routine")="MIOOSTRX"
	SET ID=$$NEXTID(),NOW=$HOROLOG,USER=$GET(STATE("principal"),"guest")
	SET ^MIO("MIOOS","TRANSFER",ID,"direction")=$GET(DIR)
	SET ^MIO("MIOOS","TRANSFER",ID,"state")="active"
	SET ^MIO("MIOOS","TRANSFER",ID,"owner")=USER
	SET ^MIO("MIOOS","TRANSFER",ID,"sessionId")=$GET(STATE("sessionId"))
	SET ^MIO("MIOOS","TRANSFER",ID,"createdAt")=NOW
	SET ^MIO("MIOOS","TRANSFER",ID,"updatedAt")=NOW
	SET ^MIO("MIOOS","TRANSFER",ID,"resumeSeconds")=$$RESUME(.CONF)
	SET ^MIO("MIOOS","TRANSFER",ID,"chunkSize")=$$CHUNK(.CONF)
	SET ^MIO("MIOOS","TRANSFER",ID,"workerCount")=$$LEASE(.CONF,DIR)
	MERGE ^MIO("MIOOS","TRANSFER",ID,"meta")=META
	SET ^MIO("MIOOS","TRANSFER","BYUSER",USER,ID)=""
	SET ^MIO("MIOOS","TRANSFER","ACTIVE",ID)=""
	DO SNAP(ID,.OUT)
	QUIT ID
	;
SNAP(ID,OUT)
	KILL OUT
	SET OUT("transferId")=$GET(ID)
	SET OUT("direction")=$GET(^MIO("MIOOS","TRANSFER",ID,"direction"))
	SET OUT("state")=$GET(^MIO("MIOOS","TRANSFER",ID,"state"))
	SET OUT("owner")=$GET(^MIO("MIOOS","TRANSFER",ID,"owner"))
	SET OUT("sessionId")=$GET(^MIO("MIOOS","TRANSFER",ID,"sessionId"))
	SET OUT("createdAt")=$GET(^MIO("MIOOS","TRANSFER",ID,"createdAt"))
	SET OUT("updatedAt")=$GET(^MIO("MIOOS","TRANSFER",ID,"updatedAt"))
	SET OUT("resumeSeconds")=+$GET(^MIO("MIOOS","TRANSFER",ID,"resumeSeconds"))
	SET OUT("chunkSize")=+$GET(^MIO("MIOOS","TRANSFER",ID,"chunkSize"))
	SET OUT("workerCount")=+$GET(^MIO("MIOOS","TRANSFER",ID,"workerCount"))
	SET OUT("bytesTotal")=+$GET(^MIO("MIOOS","TRANSFER",ID,"bytesTotal"))
	SET OUT("bytesDone")=+$GET(^MIO("MIOOS","TRANSFER",ID,"bytesDone"))
	SET OUT("chunkTotal")=+$GET(^MIO("MIOOS","TRANSFER",ID,"chunkTotal"))
	SET OUT("chunkReceived")=+$GET(^MIO("MIOOS","TRANSFER",ID,"chunkReceived"))
	SET OUT("chunkSent")=+$GET(^MIO("MIOOS","TRANSFER",ID,"chunkSent"))
	IF $DATA(^MIO("MIOOS","TRANSFER",ID,"meta")) MERGE OUT("meta")=^MIO("MIOOS","TRANSFER",ID,"meta")
	QUIT
	;
OWNOK(STATE,ID,ERR)
	NEW USER,OWNER
	SET USER=$GET(STATE("principal"),"guest"),OWNER=$GET(^MIO("MIOOS","TRANSFER",$GET(ID),"owner"))
	IF ID="" SET ERR("error")="transfer_missing" QUIT 0
	IF OWNER="" SET ERR("error")="transfer_not_found",ERR("detail")=ID QUIT 0
	IF USER'=OWNER SET ERR("error")="access_denied",ERR("detail")=ID QUIT 0
	QUIT 1
	;
TOUCH(ID)
	SET ^MIO("MIOOS","TRANSFER",$GET(ID),"updatedAt")=$HOROLOG
	QUIT
	;
ABORT(STATE,ID,OUT,ERR)
	SET ERR("routine")="MIOOSTRX"
	IF '$$OWNOK(.STATE,$GET(ID),.ERR) QUIT 0
	SET ^MIO("MIOOS","TRANSFER",ID,"state")="aborted"
	DO TOUCH(ID)
	DO SNAP(ID,.OUT)
	KILL ^MIO("MIOOS","TRANSFER","ACTIVE",ID)
	QUIT 1
	;
DONE(ID,FILEID)
	SET ^MIO("MIOOS","TRANSFER",$GET(ID),"state")="complete"
	IF $GET(FILEID)'="" SET ^MIO("MIOOS","TRANSFER",$GET(ID),"fileId")=$GET(FILEID)
	DO TOUCH($GET(ID))
	KILL ^MIO("MIOOS","TRANSFER","ACTIVE",$GET(ID))
	QUIT
	;
	;