MIOOST ; MIOOS tests
	DO T001
	DO T002
	DO T003
	DO T004
	DO T005
	DO T006
	DO T007
	DO T008
	DO T009
	DO T010
	DO T011
	DO T012
	DO T013
	DO T014
	DO T015
	DO T016
	DO T017
	DO T018
	DO T019
	DO T020
	QUIT
	;
RESET
	KILL ^MIO("ROUTE")
	KILL ^MIO("CONF","server","routing")
	KILL ^MIO("MIOOS")
	KILL ^MIO("AUTH","SESSION","mioos")
	KILL ^MIO("AUTH","SESSION","BYUSER","mioos")
	KILL ^MIO("MIOOS","FS")
	QUIT
	;
COMPILE
	DO COMPILE^MIOROUTE
	QUIT
	;
FILEHAS(PATH,NEED)
	NEW OK,LINE
	SET OK=0
	OPEN PATH:(readonly):1 ELSE  QUIT 0
	USE PATH
	FOR  READ LINE QUIT:$ZEOF  DO  QUIT:OK
	. IF LINE[NEED SET OK=1
	CLOSE PATH
	QUIT OK
	;
FILEOK(PATH)
	OPEN PATH:(readonly):1 ELSE  QUIT 0
	CLOSE PATH
	QUIT 1
	;
AMATCH(DESC,METHOD,PATH,EXPOK,EXPH,EXPRP,EP)
	NEW P,H,RP,OK,KEY
	KILL P
	SET OK=$$MATCH^MIOROUTE($GET(METHOD),$GET(PATH),.P,.H,.RP)
	DO EQ^MIOTASSERT(+OK,+$GET(EXPOK),DESC_": ok")
	IF +$GET(EXPOK)'=1 QUIT
	DO EQ^MIOTASSERT($GET(H),$GET(EXPH),DESC_": handler")
	DO EQ^MIOTASSERT($GET(RP),$GET(EXPRP),DESC_": route")
	SET KEY="" FOR  SET KEY=$ORDER(EP(KEY)) QUIT:KEY=""  DO
	. DO EQ^MIOTASSERT($GET(P(KEY)),$GET(EP(KEY)),DESC_": param "_KEY)
	QUIT
	;
T001
	NEW CONF,EP
	DO RESET
	DO REG^MIOOS(.CONF)
	DO COMPILE
	KILL EP DO AMATCH("[MIOOST][T001][desktop]","GET","/mioos",1,"DESKTOP^MIOOS","/mioos",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][alias]","GET","/os",1,"DESKTOP^MIOOS","/os",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][bootstrap]","GET","/api/mioos/bootstrap",1,"BOOTSTRAP^MIOOSAPI","/api/mioos/bootstrap",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][view]","GET","/api/mioos/view",1,"VIEW^MIOOSAPI","/api/mioos/view",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][signin]","POST","/api/mioos/auth/signin",1,"SIGNIN^MIOOSAPI","/api/mioos/auth/signin",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][signout]","POST","/api/mioos/auth/signout",1,"SIGNOUT^MIOOSAPI","/api/mioos/auth/signout",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][guest]","POST","/api/mioos/auth/guest",1,"GUESTSIGNIN^MIOOSAPI","/api/mioos/auth/guest",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][static]","GET","/public/mioos/mioos.css",1,"STATIC^MIOOS","/public/mioos/*",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][fs list]","POST","/api/mioos/fs/list",1,"FSLIST^MIOOSAPI","/api/mioos/fs/list",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][fs read]","POST","/api/mioos/fs/read",1,"FSREAD^MIOOSAPI","/api/mioos/fs/read",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][fs write]","POST","/api/mioos/fs/write",1,"FSWRITE^MIOOSAPI","/api/mioos/fs/write",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][fs mkdir]","POST","/api/mioos/fs/mkdir",1,"FSMKDIR^MIOOSAPI","/api/mioos/fs/mkdir",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][ws]","WS","/ws/mioos",1,"MESSAGE^MIOOSWS","/ws/mioos",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][ws terminal]","WS","/ws/mioos/terminal",1,"MESSAGE^MIOOSTWS","/ws/mioos/terminal",.EP)
	DO EQ^MIOTASSERT(+$GET(^MIO("ROUTE","META","GET","/mioos","authRequired")),0,"[MIOOST][T001][desktop auth]")
	DO EQ^MIOTASSERT(+$GET(^MIO("ROUTE","META","POST","/api/mioos/auth/signin","authRequired")),0,"[MIOOST][T001][signin auth]")
	QUIT
	;
T002
	NEW CONF,REQ,CTX,STATE,ERR,JSON,OBJ
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T002][load]")
	SET JSON=$$BOOTJSON^MIOOSST(.STATE,.CONF)
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T002][decode]")
	DO EQ^MIOTASSERT($GET(OBJ("product","name")),"MIOOS","[MIOOST][T002][product]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","websocket")),"/ws/mioos","[MIOOST][T002][ws route]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","terminalWebsocket")),"/ws/mioos/terminal","[MIOOST][T002][terminal ws route]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","signin")),"/api/mioos/auth/signin","[MIOOST][T002][signin route]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","launcherLabel")),"Menu","[MIOOST][T002][launcher]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","commandTransport")),"websocket-only","[MIOOST][T002][transport]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","realtimeContract")),"core-websocket-plus-app-websockets","[MIOOST][T002][realtime]")
	DO EQ^MIOTASSERT($GET(OBJ("apps",4,"key")),"terminal","[MIOOST][T002][terminal app]")
	DO EQ^MIOTASSERT($GET(OBJ("windows",1,"appKey")),"my-computer","[MIOOST][T002][explorer window]")
	DO EQ^MIOTASSERT(+$GET(OBJ("auth","enabled")),1,"[MIOOST][T002][auth enabled]")
	DO EQ^MIOTASSERT(+$GET(OBJ("desktop","noMarkupData")),1,"[MIOOST][T002][no markup data]")
	DO EQ^MIOTASSERT($GET(OBJ("terminal","engine")),"xtermjs","[MIOOST][T002][terminal engine]")
	DO EQ^MIOTASSERT($GET(OBJ("terminal","transport")),"pipe","[MIOOST][T002][terminal transport]")
	DO EQ^MIOTASSERT($GET(OBJ("terminal","commandTransport")),"dedicated-websocket","[MIOOST][T002][terminal command transport]")
	DO EQ^MIOTASSERT($GET(OBJ("terminal","profile","fontFamily")),"Consolas","[MIOOST][T002][terminal font]")
	DO EQ^MIOTASSERT(+$GET(OBJ("vfs","enabled")),1,"[MIOOST][T002][vfs enabled]")
	DO EQ^MIOTASSERT($GET(OBJ("vfs","storage")),"globals-only","[MIOOST][T002][vfs storage]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","fsList")),"/api/mioos/fs/list","[MIOOST][T002][fs list route]")
	DO EQ^MIOTASSERT(+$GET(OBJ("websocket","maxSocketsPerSession")),4,"[MIOOST][T002][max sockets]")
	DO EQ^MIOTASSERT(+$GET(OBJ("websocket","fsSockets")),3,"[MIOOST][T002][fs sockets]")
	DO EQ^MIOTASSERT(+$GET(OBJ("vfs","uploadBatchSize")),4,"[MIOOST][T002][upload batch size]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","windowing","engine")),"mioos-native-vue-css","[MIOOST][T002][windowing engine]")
	DO EQ^MIOTASSERT(+$GET(OBJ("desktop","windowing","snapThreshold")),28,"[MIOOST][T002][snap threshold]")
	DO EQ^MIOTASSERT(+$GET(OBJ("windows",1,"resizable")),1,"[MIOOST][T002][window resizable]")
	QUIT
	;
T003
	NEW CONF,REQ,CTX,STATE,ERR,DATA
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T003][load]")
	DO DESKCTX^MIOOSUI(.STATE,.CONF,.DATA)
	DO EQ^MIOTASSERT($GET(DATA("page","title")),"MIOOS Desktop","[MIOOST][T003][page title]")
	DO EQ^MIOTASSERT($GET(DATA("commandEvent")),"desktop.command","[MIOOST][T003][command event]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-mioos-core-socket=""1"""),"[MIOOST][T003][core socket token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-mioos-app-sockets=""1"""),"[MIOOST][T003][app sockets token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-mioos-max-sockets="),"[MIOOST][T003][max sockets token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-mioos-upload-batch-size="),"[MIOOST][T003][upload batch token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-mioos-signin="),"[MIOOST][T003][signin token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-auth-overlay"),"[MIOOST][T003][auth overlay]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-snap-preview"),"[MIOOST][T003][snap preview token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-resize-edge=""n"""),"[MIOOST][T003][resize north token]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_auth.js","submitSignin"),"[MIOOST][T003][signin method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css",".mioos-auth-card"),"[MIOOST][T003][css auth]")
	QUIT
	;
T004
	NEW CONF,REQ,CTX,STATE,ERR,JSON,OBJ,VIEW
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T004][load]")
	SET JSON=$$HELLOJSON^MIOOSWS(.STATE,.CONF)
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T004][hello decode]")
	DO EQ^MIOTASSERT($GET(OBJ("event")),"hello","[MIOOST][T004][hello event]")
	DO EQ^MIOTASSERT($GET(OBJ("commandResultEvent")),"desktop.result","[MIOOST][T004][result event]")
	DO EQ^MIOTASSERT($GET(OBJ("terminalEngine")),"xtermjs","[MIOOST][T004][engine]")
	DO EQ^MIOTASSERT($GET(OBJ("realtimeContract")),"core-websocket-plus-app-websockets","[MIOOST][T004][realtime contract]")
	DO EQ^MIOTASSERT(+$GET(OBJ("socketPool","maxSocketsPerSession")),4,"[MIOOST][T004][hello max sockets]")
	SET JSON=$$PONGJSON^MIOOSWS(.STATE)
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T004][pong decode]")
	DO EQ^MIOTASSERT($GET(OBJ("event")),"pong","[MIOOST][T004][pong event]")
	DO BUILD^MIOOSVM(.STATE,.CONF,.VIEW)
	SET JSON=$$VIEWJSON^MIOOSWS(.STATE,.VIEW)
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T004][view decode]")
	DO EQ^MIOTASSERT($GET(OBJ("event")),"view.refresh","[MIOOST][T004][view event]")
	DO EQ^MIOTASSERT($GET(OBJ("view","terminal","status")),"ready","[MIOOST][T004][terminal status]")
	QUIT
	;
T005
	NEW CONF,REQ,CTX,STATE,ERR,TOKEN,OBJ
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO INIT^MIOOS(.CONF)
	DO OK^MIOTASSERT($DATA(^MIO("MIOOS","USER","admin"))#2,"[MIOOST][T005][bootstrap admin]")
	DO OK^MIOTASSERT($$SIGNIN^MIOOSAUTH(.CONF,"admin","admin123!",.TOKEN,.ERR),"[MIOOST][T005][signin]")
	SET REQ("hdr","cookie")=$PIECE($$COOKIEHDR^MIOOSAUTH(.CONF,TOKEN,0),";",1)
	DO OK^MIOTASSERT($$LOADLOCAL^MIOOSAUTH(.CONF,.REQ,.CTX,.ERR),"[MIOOST][T005][load local]")
	DO EQ^MIOTASSERT($GET(CTX("auth","claims","sub")),"admin","[MIOOST][T005][principal]")
	DO OK^MIOTASSERT($$GUESTSIGNIN^MIOOSAUTH(.CONF,.TOKEN,.ERR),"[MIOOST][T005][guest signin]")
	DO SIGNOUT^MIOOSAUTH(.CONF,.REQ,.CTX)
	DO EQ^MIOTASSERT($DATA(^MIO("AUTH","SESSION","mioos",$GET(CTX("auth","claims","sid"))))#2,0,"[MIOOST][T005][session revoked]")
	QUIT
	;
T006
	NEW CONF,REQ,CTX,STATE,ERR,JSON,OBJ
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	SET REQ("query","lang")="ar"
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T006][load ar]")
	SET JSON=$$BOOTJSON^MIOOSST(.STATE,.CONF)
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T006][decode]")
	DO EQ^MIOTASSERT($GET(OBJ("locale","code")),"ar","[MIOOST][T006][locale code]")
	DO EQ^MIOTASSERT($GET(OBJ("locale","dir")),"rtl","[MIOOST][T006][locale dir]")
	DO EQ^MIOTASSERT(+$GET(OBJ("desktop","accessibility","rtl")),1,"[MIOOST][T006][rtl flag]")
	DO EQ^MIOTASSERT($GET(OBJ("i18n","strings","auth.signin")),"تسجيل الدخول","[MIOOST][T006][signin copy]")
	DO EQ^MIOTASSERT($GET(OBJ("apps",1,"title")),"جهاز الكمبيوتر","[MIOOST][T006][localized app]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","performance","clientModel")),"thin-vue-umd","[MIOOST][T006][perf model]")
	QUIT
	;
T007
	DO OK^MIOTASSERT($$FILEOK("mioos_llm.md"),"[MIOOST][T007][llm doc]")
	DO OK^MIOTASSERT($$FILEOK("docs/mioos/README.md"),"[MIOOST][T007][readme]")
	DO OK^MIOTASSERT($$FILEOK("docs/mioos/User_Guide.md"),"[MIOOST][T007][user guide]")
	DO OK^MIOTASSERT($$FILEOK("docs/mioos/Internal_Doc.md"),"[MIOOST][T007][internal doc]")
	DO OK^MIOTASSERT($$FILEOK("docs/mioos/HIPAA.md"),"[MIOOST][T007][hipaa doc]")
	DO OK^MIOTASSERT($$FILEHAS("templates/layouts/mioos_shell.html","/public/mioos/app/mioos_core.js"),"[MIOOST][T007][core script]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","changeLocale(locale.code)"),"[MIOOST][T007][locale switch]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_state.js","window.MIOOSState"),"[MIOOST][T007][state module]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","window.MIOOSCore"),"[MIOOST][T007][core module]")
	QUIT
	;
T008
	NEW CONF,REQ,CTX,STATE,ERR,JSON,OBJ,TERMID,PAY
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T008][load]")
	SET PAY="{""event"":""desktop.command"",""requestId"":""ws-1"",""command"":""terminal.open"",""windowId"":""win-term-1""}"
	DO OK^MIOTASSERT($$COMMANDJSON^MIOOSWS(.CONF,.REQ,.CTX,.STATE,PAY,.JSON,.ERR),"[MIOOST][T008][open cmd]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T008][open decode]")
	DO EQ^MIOTASSERT($GET(OBJ("event")),"desktop.result","[MIOOST][T008][open event]")
	SET TERMID=$GET(OBJ("terminal","terminalId"))
	DO EQ^MIOTASSERT(TERMID'="",1,"[MIOOST][T008][terminal id]")
	DO EQ^MIOTASSERT($GET(OBJ("terminal","engine")),"xtermjs","[MIOOST][T008][terminal engine]")
	DO EQ^MIOTASSERT($GET(OBJ("terminal","transport")),"pipe","[MIOOST][T008][terminal transport]")
	DO EQ^MIOTASSERT($GET(OBJ("terminal","profile","fontFamily")),"Consolas","[MIOOST][T008][terminal font]")
	SET PAY="{""event"":""desktop.command"",""requestId"":""ws-2"",""command"":""terminal.input"",""windowId"":""win-term-1"",""terminalId"":"""_TERMID_""",""line"":""write 123,!""}"
	DO OK^MIOTASSERT($$COMMANDJSON^MIOOSWS(.CONF,.REQ,.CTX,.STATE,PAY,.JSON,.ERR),"[MIOOST][T008][input cmd]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T008][input decode]")
	DO EQ^MIOTASSERT($GET(OBJ("terminal","terminalId")),TERMID,"[MIOOST][T008][input terminal]")
	DO OK^MIOTASSERT($GET(OBJ("terminal","write",1))["123","[MIOOST][T008][pipe write]")
	SET PAY="{""event"":""desktop.command"",""requestId"":""ws-2b"",""command"":""terminal.poll"",""windowId"":""win-term-1"",""terminalId"":"""_TERMID_"""}"
	DO OK^MIOTASSERT($$COMMANDJSON^MIOOSWS(.CONF,.REQ,.CTX,.STATE,PAY,.JSON,.ERR),"[MIOOST][T008][poll cmd]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T008][poll decode]")
	DO EQ^MIOTASSERT($GET(OBJ("terminal","terminalId")),TERMID,"[MIOOST][T008][poll terminal]")
	SET PAY="{""event"":""desktop.command"",""requestId"":""ws-3"",""command"":""terminal.resize"",""windowId"":""win-term-1"",""terminalId"":"""_TERMID_""",""cols"":132,""rows"":32}"
	DO OK^MIOTASSERT($$COMMANDJSON^MIOOSWS(.CONF,.REQ,.CTX,.STATE,PAY,.JSON,.ERR),"[MIOOST][T008][resize cmd]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T008][resize decode]")
	DO EQ^MIOTASSERT(+$GET(OBJ("terminal","cols")),132,"[MIOOST][T008][cols]")
	SET PAY="{""event"":""desktop.command"",""requestId"":""ws-4"",""command"":""terminal.close"",""windowId"":""win-term-1"",""terminalId"":"""_TERMID_"""}"
	DO OK^MIOTASSERT($$COMMANDJSON^MIOOSWS(.CONF,.REQ,.CTX,.STATE,PAY,.JSON,.ERR),"[MIOOST][T008][close cmd]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T008][close decode]")
	DO EQ^MIOTASSERT(+$GET(OBJ("terminal","closed")),1,"[MIOOST][T008][closed]")
	QUIT
	;
T009
	DO OK^MIOTASSERT($$FILEHAS("templates/layouts/mioos_shell.html","/public/mioos/app/mioos_terminal.js"),"[MIOOST][T009][terminal script]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-terminal-engine=""xtermjs-ydb"""),"[MIOOST][T009][terminal engine token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-mioos-terminal-ws="),"[MIOOST][T009][terminal ws token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-terminal-viewport"),"[MIOOST][T009][terminal viewport]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_terminal.js","window.MIOOSTerminal"),"[MIOOST][T009][terminal module]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css",".mioos-terminal-shell"),"[MIOOST][T009][terminal css]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 6 — core socket plus dedicated terminal sockets"),"[MIOOST][T009][llm roi6]")
	QUIT
	;
T010
	NEW CONF,REQ,CTX,STATE,ERR,JSON,OBJ,TERMID,PAY
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T010][load]")
	SET PAY="{""event"":""terminal.open"",""requestId"":""tw-1"",""windowId"":""win-term-2"",""terminalId"":""__new__""}"
	DO OK^MIOTASSERT($$EVENTJSON^MIOOSTWS(.CONF,.REQ,.CTX,.STATE,PAY,.JSON,.ERR),"[MIOOST][T010][open event]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T010][open decode]")
	DO EQ^MIOTASSERT($GET(OBJ("event")),"terminal.open","[MIOOST][T010][open name]")
	SET TERMID=$GET(OBJ("terminal","terminalId"))
	DO EQ^MIOTASSERT(TERMID'="",1,"[MIOOST][T010][terminal id]")
	DO EQ^MIOTASSERT($GET(OBJ("terminal","commandTransport")),"dedicated-websocket","[MIOOST][T010][command transport]")
	SET PAY="{""event"":""terminal.input"",""requestId"":""tw-2"",""windowId"":""win-term-2"",""terminalId"":"""_TERMID_""",""line"":""write 456,!""}"
	DO OK^MIOTASSERT($$EVENTJSON^MIOOSTWS(.CONF,.REQ,.CTX,.STATE,PAY,.JSON,.ERR),"[MIOOST][T010][input event]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T010][input decode]")
	DO EQ^MIOTASSERT($GET(OBJ("event")),"terminal.stdout","[MIOOST][T010][stdout name]")
	DO OK^MIOTASSERT($GET(OBJ("terminal","write",1))["456","[MIOOST][T010][stdout payload]")
	SET PAY="{""event"":""terminal.close"",""requestId"":""tw-3"",""windowId"":""win-term-2"",""terminalId"":"""_TERMID_"""}"
	DO OK^MIOTASSERT($$EVENTJSON^MIOOSTWS(.CONF,.REQ,.CTX,.STATE,PAY,.JSON,.ERR),"[MIOOST][T010][close event]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T010][close decode]")
	DO EQ^MIOTASSERT($GET(OBJ("event")),"terminal.close","[MIOOST][T010][close name]")
	DO EQ^MIOTASSERT(+$GET(OBJ("terminal","closed")),1,"[MIOOST][T010][closed]")
	QUIT
	;
T011
	NEW CONF,REQ,CTX,STATE,ERR,OUT,ID,ROOT,JSON,OBJ,PAY
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO INIT^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T011][load]")
	SET ROOT=$$ROOTID^MIOOSFS()
	DO OK^MIOTASSERT($$LIST^MIOOSFS(.STATE,ROOT,.OUT,.ERR),"[MIOOST][T011][list root]")
	DO EQ^MIOTASSERT(+$GET(OUT("count"))>1,1,"[MIOOST][T011][root entries]")
	KILL OUT DO OK^MIOTASSERT($$MKDIR^MIOOSFS(.STATE,ROOT,"Tests",.OUT,.ERR),"[MIOOST][T011][mkdir]")
	SET ID=$GET(OUT("id"))
	DO EQ^MIOTASSERT(ID'="",1,"[MIOOST][T011][mkdir id]")
	KILL OUT DO OK^MIOTASSERT($$WRITE^MIOOSFS(.STATE,ID,"note.txt","alpha beta gamma","text/plain",.OUT,.ERR),"[MIOOST][T011][write]")
	DO EQ^MIOTASSERT($GET(OUT("kind")),"file","[MIOOST][T011][write kind]")
	SET ID=$GET(OUT("id"))
	KILL OUT DO OK^MIOTASSERT($$READ^MIOOSFS(.STATE,ID,.OUT,.ERR),"[MIOOST][T011][read]")
	DO EQ^MIOTASSERT($GET(OUT("content")),"alpha beta gamma","[MIOOST][T011][read content]")
	KILL OUT DO OK^MIOTASSERT($$RENAME^MIOOSFS(.STATE,ID,"renamed.txt",.OUT,.ERR),"[MIOOST][T011][rename]")
	DO EQ^MIOTASSERT($GET(OUT("name")),"renamed.txt","[MIOOST][T011][rename name]")
	KILL OUT DO OK^MIOTASSERT($$MOVE^MIOOSFS(.STATE,ID,"/Documents",.OUT,.ERR),"[MIOOST][T011][move]")
	DO EQ^MIOTASSERT($GET(OUT("parentId"))=$$HOMEID^MIOOSFS(),1,"[MIOOST][T011][move parent]")
	KILL OUT DO OK^MIOTASSERT($$DELETE^MIOOSFS(.STATE,ID,.OUT,.ERR),"[MIOOST][T011][delete file]")
	DO EQ^MIOTASSERT(+$GET(OUT("deleted")),1,"[MIOOST][T011][delete flag]")
	SET PAY="{""event"":""desktop.command"",""requestId"":""fs-1"",""command"":""fs.list"",""parent"":""/Documents""}"
	DO OK^MIOTASSERT($$COMMANDJSON^MIOOSWS(.CONF,.REQ,.CTX,.STATE,PAY,.JSON,.ERR),"[MIOOST][T011][ws fs list]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T011][ws fs decode]")
	DO EQ^MIOTASSERT($GET(OBJ("event")),"desktop.result","[MIOOST][T011][ws event]")
	DO EQ^MIOTASSERT($GET(OBJ("command")),"fs.list","[MIOOST][T011][ws command]")
	QUIT
	;
	;
T012
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","explorerPromptUpload(win.id)"),"[MIOOST][T012][upload action]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-imageviewer-shell"),"[MIOOST][T012][image viewer token]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","openImageViewerWindow"),"[MIOOST][T012][image viewer method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","explorerPromptUpload"),"[MIOOST][T012][upload method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css",".mioos-imageviewer-shell"),"[MIOOST][T012][image viewer css]")
	QUIT
	;
	;
T013
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-mediaviewer-shell"),"[MIOOST][T013][media viewer token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","explorerDownloadSelected(win.id)"),"[MIOOST][T013][download action]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","openMediaViewerWindow"),"[MIOOST][T013][media viewer method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","downloadViewerFile"),"[MIOOST][T013][download method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css",".mioos-mediaviewer-shell"),"[MIOOST][T013][media viewer css]")
	QUIT
	;
T014
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","fs.upload.batch"),"[MIOOST][T014][upload batch command]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","socketPoolConfig"),"[MIOOST][T014][socket pool config]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSWS.m","fs.upload.batch"),"[MIOOST][T014][ws upload batch]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSFSUP.m","BATCH(STATE,CONF,UPLOADID,CHROOT,OUT,ERR)"),"[MIOOST][T014][fsup batch]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_wm.js","beginResize"),"[MIOOST][T014][wm resize method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","uploadFilesToExplorer"),"[MIOOST][T014][explorer drop upload helper]")
	QUIT
	;
	;
T015
	NEW CONF,REQ,CTX,STATE,ERR,JSON,OBJ
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T015][load]")
	SET JSON=$$BOOTJSON^MIOOSST(.STATE,.CONF)
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T015][decode]")
	DO EQ^MIOTASSERT($GET(OBJ("apps",5,"key")),"theme-studio","[MIOOST][T015][theme studio app]")
	DO EQ^MIOTASSERT($GET(OBJ("windows",5,"appKey")),"theme-studio","[MIOOST][T015][theme studio window]")
	DO EQ^MIOTASSERT(+$GET(OBJ("windows",5,"themeStudioEnabled")),1,"[MIOOST][T015][theme studio enabled]")
	QUIT
	;
T016
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","https://unpkg.com/7.css/dist/7.scoped.css"),"[MIOOST][T016][7css scoped link]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-theme-studio-shell win7"),"[MIOOST][T016][theme studio win7 shell]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","role=""tablist"""),"[MIOOST][T016][tablist token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","Theme Studio"),"[MIOOST][T016][theme studio copy]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","themeStudioApplyPreset"),"[MIOOST][T016][theme studio preset method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","themeStudioApplyCurrent"),"[MIOOST][T016][theme studio apply method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","applyThemeStudioProfile"),"[MIOOST][T016][theme studio live apply]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","themeStudioExportProfile"),"[MIOOST][T016][theme studio export method]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","Apply Theme"),"[MIOOST][T016][theme studio apply copy]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css","--mioos-desktop-background"),"[MIOOST][T016][theme studio css vars]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css",".mioos-theme-studio-layout"),"[MIOOST][T016][theme studio css]")
	QUIT
	;

	;
T017
	NEW CONF,REQ,CTX,STATE,ERR,JSON,OBJ
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T017][load]")
	SET JSON=$$BOOTJSON^MIOOSST(.STATE,.CONF)
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T017][decode]")
	DO EQ^MIOTASSERT($GET(OBJ("apps",6,"key")),"transfers","[MIOOST][T017][transfers app]")
	DO EQ^MIOTASSERT($GET(OBJ("windows",6,"appKey")),"transfers","[MIOOST][T017][transfers window]")
	DO EQ^MIOTASSERT(+$GET(OBJ("windows",6,"transferCenterEnabled")),1,"[MIOOST][T017][transfer enabled]")
	QUIT
	;
T018
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-transfer-window=""1"""),"[MIOOST][T018][transfer window token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","openTransfersWindow()"),"[MIOOST][T018][transfer launcher]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-explorer-appframe--xp"),"[MIOOST][T018][explorer xp appframe]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","File and Folder Tasks"),"[MIOOST][T018][explorer xp tasks]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-explorer-menubar"),"[MIOOST][T018][explorer xp menubar]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","registerTransfer"),"[MIOOST][T018][register transfer]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","openTransfersWindow"),"[MIOOST][T018][open transfers]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","transferId"),"[MIOOST][T018][explorer transfer hookup]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css",".mioos-transfers-shell"),"[MIOOST][T018][transfers css]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css",".mioos-explorer-taskpane"),"[MIOOST][T018][explorer xp taskpane css]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css",".mioos-explorer-menubar"),"[MIOOST][T018][explorer xp menubar css]")
	QUIT

	;
T019
	NEW CONF,REQ,CTX,STATE,ERR,JSON,OBJ
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	SET ^MIO("MIOOS","PREF","guest","desktop","iconSize")="large"
	SET ^MIO("MIOOS","PREF","guest","desktop","sortMode")="manual"
	SET ^MIO("MIOOS","PREF","guest","desktop","positions","terminal","left")=144
	SET ^MIO("MIOOS","PREF","guest","desktop","positions","terminal","top")=88
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T019][load]")
	SET JSON=$$BOOTJSON^MIOOSST(.STATE,.CONF)
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T019][decode]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","icons","enabled")),1,"[MIOOST][T019][icons enabled]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","icons","draggable")),1,"[MIOOST][T019][icons draggable]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","icons","size")),"large","[MIOOST][T019][icon size]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","contextMenu","desktop")),1,"[MIOOST][T019][desktop menu]")
	DO EQ^MIOTASSERT($GET(OBJ("apps",4,"iconLeft")),144,"[MIOOST][T019][terminal icon left]")
	QUIT
	;
T020
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-context-menu"),"[MIOOST][T020][context menu token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","openDesktopContextMenu($event)"),"[MIOOST][T020][desktop menu handler]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","openDesktopIconContextMenu(entry, $event)"),"[MIOOST][T020][icon menu handler]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","beginDesktopIconDrag"),"[MIOOST][T020][icon drag method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","desktop.layout.save"),"[MIOOST][T020][layout save command]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","setDesktopIconSize"),"[MIOOST][T020][icon size method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css",".mioos-context-menu"),"[MIOOST][T020][context menu css]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css",".mioos-desktop-icon.is-large"),"[MIOOST][T020][large icon css]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSWS.m","desktop.layout.save"),"[MIOOST][T020][ws layout save]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSWS.m","fs.download.begin"),"[MIOOST][T020][ws download begin]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","win.appKey === 'pdf-viewer'"),"[MIOOST][T020][pdf viewer token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","win.appKey === 'structured-viewer'"),"[MIOOST][T020][structured viewer token]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","openPdfViewerWindow"),"[MIOOST][T020][pdf viewer method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","fs.download.chunk"),"[MIOOST][T020][chunked download method]")
	QUIT
