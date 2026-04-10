MIOOSTERM ; MIOOS YottaDB/xterm terminal helpers
	QUIT
	;
LOADTERM(STATE,CONF)
	SET STATE("terminal","engine")="xtermjs"
	SET STATE("terminal","transport")="pipe"
	SET STATE("terminal","sessionModel")="multi-window-ydb-direct"
	SET STATE("terminal","commandTransport")=$GET(CONF("mioos","terminal","commandTransport"),"dedicated-websocket")
	SET STATE("terminal","websocketPath")=$GET(CONF("mioos","route","wsTerminal"),"/ws/mioos/terminal")
	SET STATE("terminal","websocketPollMs")=+$GET(CONF("mioos","terminal","websocket","pollMs"),250)
	SET STATE("terminal","fontFamily")=$GET(CONF("mioos","terminal","default","fontFamily"),"Consolas")
	SET STATE("terminal","fontSize")=+$GET(CONF("mioos","terminal","default","fontSize"),14)
	SET STATE("terminal","cursorBlink")=+$GET(CONF("mioos","terminal","default","cursorBlink"),1)
	SET STATE("terminal","cursorStyle")=$GET(CONF("mioos","terminal","default","cursorStyle"),"block")
	SET STATE("terminal","scrollback")=+$GET(CONF("mioos","terminal","default","scrollback"),2500)
	SET STATE("terminal","renderer")=$GET(CONF("mioos","terminal","default","renderer"),"canvas")
	SET STATE("terminal","unicode")=$GET(CONF("mioos","terminal","default","unicode"),"unicode11")
	SET STATE("terminal","rows")=+$GET(CONF("mioos","terminal","default","rows"),28)
	SET STATE("terminal","cols")=+$GET(CONF("mioos","terminal","default","cols"),112)
	SET STATE("terminal","maxSessions")=+$GET(CONF("mioos","terminal","maxSessionsPerUser"),8)
	SET STATE("terminal","maxSessionsPerSession")=+$GET(CONF("mioos","terminal","maxSessionsPerSession"),4)
	SET STATE("terminal","historyLimit")=+$GET(CONF("mioos","terminal","historyLimit"),400)
	SET STATE("terminal","command")=$$CMD^MIOOSPIPE(.CONF)
	SET STATE("terminal","shell")=$$SHELL^MIOOSPIPE(.CONF)
	IF STATE("terminal","fontSize")<12 SET STATE("terminal","fontSize")=14
	IF STATE("terminal","rows")<20 SET STATE("terminal","rows")=28
	IF STATE("terminal","cols")<80 SET STATE("terminal","cols")=112
	QUIT
	;
LIST(STATE,OUT)
	NEW TERMID,N,SID
	KILL OUT
	SET SID=$GET(STATE("sessionId"))
	SET TERMID="",N=0
	FOR  SET TERMID=$ORDER(^MIO("MIOOS","PIPE","SESSION",TERMID)) QUIT:TERMID=""  DO
	. IF $GET(^MIO("MIOOS","PIPE","SESSION",TERMID,"principal"))'=$GET(STATE("principal")) QUIT
	. IF SID'="",$GET(^MIO("MIOOS","PIPE","SESSION",TERMID,"sessionId"))'=SID QUIT
	. IF '$GET(^MIO("MIOOS","PIPE","SESSION",TERMID,"open")) QUIT
	. SET N=N+1
	. SET OUT(N,"key")=TERMID
	. SET OUT(N,"terminalId")=TERMID
	. SET OUT(N,"label")="Session "_N
	. SET OUT(N,"transport")=$GET(^MIO("MIOOS","PIPE","SESSION",TERMID,"transport"),"pipe")
	. SET OUT(N,"command")=$GET(^MIO("MIOOS","PIPE","SESSION",TERMID,"command"))
	. SET OUT(N,"openedAt")=$GET(^MIO("MIOOS","PIPE","SESSION",TERMID,"openedAt"))
	. SET OUT(N,"lastSeenAt")=$GET(^MIO("MIOOS","PIPE","SESSION",TERMID,"lastSeenAt"))
	. SET OUT(N,"cols")=+$GET(^MIO("MIOOS","PIPE","SESSION",TERMID,"cols"))
	. SET OUT(N,"rows")=+$GET(^MIO("MIOOS","PIPE","SESSION",TERMID,"rows"))
	. SET OUT(N,"status")=$SELECT(+$GET(^MIO("MIOOS","PIPE","SESSION",TERMID,"job"))=$JOB:"live",1:"resume")
	QUIT
	;
OPEN(STATE,CONF,TERMID,OUT,ERR)
	NEW USERCOUNT,SESSIONCOUNT
	IF $GET(TERMID)=""!($GET(TERMID)="__new__") DO  QUIT:$GET(ERR("error"))'="" 0
	. SET USERCOUNT=$$COUNTUSER(.STATE)
	. SET SESSIONCOUNT=$$COUNTSESSION(.STATE)
	. IF +$GET(STATE("terminal","maxSessions"),8)>0,USERCOUNT>=+$GET(STATE("terminal","maxSessions"),8) SET ERR("routine")="MIOOSTERM",ERR("error")="terminal_limit_reached" QUIT
	. IF +$GET(STATE("terminal","maxSessionsPerSession"),4)>0,SESSIONCOUNT>=+$GET(STATE("terminal","maxSessionsPerSession"),4) SET ERR("routine")="MIOOSTERM",ERR("error")="terminal_session_limit_reached" QUIT
	IF '$$OPEN^MIOOSPIPE(.STATE,.CONF,$GET(TERMID),.OUT,.ERR) QUIT 0
	DO PROFILE(.STATE,.CONF,$GET(OUT("terminalId")),.OUT)
	QUIT 1
	;
POLL(STATE,CONF,TERMID,OUT,ERR)
	IF '$$POLL^MIOOSPIPE(.STATE,$GET(TERMID),.OUT,.ERR) QUIT 0
	DO PROFILE(.STATE,.CONF,$GET(TERMID),.OUT)
	QUIT 1
	;
INPUT(STATE,CONF,TERMID,LINE,OUT,ERR)
	NEW DATA
	SET DATA=$GET(LINE)
	IF DATA="" SET DATA=$CHAR(10)
	IF DATA'="",($EXTRACT(DATA,$LENGTH(DATA))'=$CHAR(10)),($EXTRACT(DATA,$LENGTH(DATA))'=$CHAR(13)) SET DATA=DATA_$CHAR(10)
	QUIT $$INPUTRAW(.STATE,.CONF,$GET(TERMID),DATA,.OUT,.ERR)
	;
INPUTRAW(STATE,CONF,TERMID,DATA,OUT,ERR)
	IF '$$INPUT^MIOOSPIPE(.STATE,$GET(TERMID),$GET(DATA),.OUT,.ERR) QUIT 0
	DO PROFILE(.STATE,.CONF,$GET(TERMID),.OUT)
	QUIT 1
	;
RESIZE(STATE,CONF,TERMID,COLS,ROWS,OUT,ERR)
	IF '$$RESIZE^MIOOSPIPE(.STATE,$GET(TERMID),+$GET(COLS),+$GET(ROWS),.OUT,.ERR) QUIT 0
	DO PROFILE(.STATE,.CONF,$GET(TERMID),.OUT)
	QUIT 1
	;
CLOSE(STATE,CONF,TERMID,OUT,ERR)
	IF '$$CLOSE^MIOOSPIPE(.STATE,$GET(TERMID),.OUT,.ERR) QUIT 0
	DO PROFILE(.STATE,.CONF,$GET(TERMID),.OUT)
	QUIT 1
	;
PROFILE(STATE,CONF,TERMID,OUT)
	KILL OUT("profile")
	SET OUT("transport")="pipe"
	SET OUT("engine")=$GET(STATE("terminal","engine"),"xtermjs")
	SET OUT("renderer")=$GET(STATE("terminal","renderer"),"canvas")
	SET OUT("sessionModel")=$GET(STATE("terminal","sessionModel"),"multi-window-ydb-direct")
	SET OUT("commandTransport")=$GET(STATE("terminal","commandTransport"),"dedicated-websocket")
	SET OUT("websocketPath")=$GET(STATE("terminal","websocketPath"),"/ws/mioos/terminal")
	SET OUT("websocketPollMs")=+$GET(STATE("terminal","websocketPollMs"),250)
	SET OUT("title")=$SELECT($GET(TERMID)'="":"Terminal "_$PIECE($GET(TERMID),"-",$LENGTH($GET(TERMID),"-")),1:"Terminal")
	SET OUT("profile","fontFamily")=$GET(STATE("terminal","fontFamily"),"Consolas")
	SET OUT("profile","fontSize")=+$GET(STATE("terminal","fontSize"),14)
	SET OUT("profile","cursorBlink")=+$GET(STATE("terminal","cursorBlink"),1)
	SET OUT("profile","cursorStyle")=$GET(STATE("terminal","cursorStyle"),"block")
	SET OUT("profile","scrollback")=+$GET(STATE("terminal","scrollback"),2500)
	SET OUT("profile","renderer")=$GET(STATE("terminal","renderer"),"canvas")
	SET OUT("profile","unicode")=$GET(STATE("terminal","unicode"),"unicode11")
	SET OUT("profile","rows")=+$GET(^MIO("MIOOS","PIPE","SESSION",$GET(TERMID),"rows"),+$GET(STATE("terminal","rows"),28))
	SET OUT("profile","cols")=+$GET(^MIO("MIOOS","PIPE","SESSION",$GET(TERMID),"cols"),+$GET(STATE("terminal","cols"),112))
	SET OUT("profile","transport")="pipe"
	SET OUT("profile","command")=$GET(^MIO("MIOOS","PIPE","SESSION",$GET(TERMID),"command"),$$CMD^MIOOSPIPE(.CONF))
	SET OUT("maxSessionsPerUser")=+$GET(STATE("terminal","maxSessions"),8)
	SET OUT("maxSessionsPerSession")=+$GET(STATE("terminal","maxSessionsPerSession"),4)
	SET OUT("profile","shell")=$GET(^MIO("MIOOS","PIPE","SESSION",$GET(TERMID),"shell"),$$SHELL^MIOOSPIPE(.CONF))
	QUIT
COUNTUSER(STATE)
	NEW TERMID,N
	SET TERMID="",N=0
	FOR  SET TERMID=$ORDER(^MIO("MIOOS","PIPE","SESSION",TERMID)) QUIT:TERMID=""  DO
	. IF $GET(^MIO("MIOOS","PIPE","SESSION",TERMID,"principal"))'=$GET(STATE("principal")) QUIT
	. IF '$GET(^MIO("MIOOS","PIPE","SESSION",TERMID,"open")) QUIT
	. SET N=N+1
	QUIT N
	;
COUNTSESSION(STATE)
	NEW TERMID,N,SID
	SET TERMID="",N=0,SID=$GET(STATE("sessionId"))
	FOR  SET TERMID=$ORDER(^MIO("MIOOS","PIPE","SESSION",TERMID)) QUIT:TERMID=""  DO
	. IF $GET(^MIO("MIOOS","PIPE","SESSION",TERMID,"principal"))'=$GET(STATE("principal")) QUIT
	. IF SID'="",$GET(^MIO("MIOOS","PIPE","SESSION",TERMID,"sessionId"))'=SID QUIT
	. IF '$GET(^MIO("MIOOS","PIPE","SESSION",TERMID,"open")) QUIT
	. SET N=N+1
	QUIT N
	;
