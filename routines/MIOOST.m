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
	DO T021
	DO T026
	DO T027
	DO T028
	DO T029
	DO T030
	DO T031
	DO T032
	DO T033
	DO T034
	DO T035
	DO T036
	DO T037
	DO T038
	DO T039
	DO T040
	DO T041
	DO T042
	DO T043
	DO T044
	DO T045
	DO T046
	DO T047
	DO T048
	DO T049
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
	KILL EP DO AMATCH("[MIOOST][T001][password change]","POST","/api/mioos/auth/password/change",1,"CHANGEPASSWORD^MIOOSAPI","/api/mioos/auth/password/change",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][static]","GET","/public/mioos/mioos.css",1,"STATIC^MIOOS","/public/mioos/*",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][fs list]","POST","/api/mioos/fs/list",1,"FSLIST^MIOOSAPI","/api/mioos/fs/list",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][fs read]","POST","/api/mioos/fs/read",1,"FSREAD^MIOOSAPI","/api/mioos/fs/read",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][fs write]","POST","/api/mioos/fs/write",1,"FSWRITE^MIOOSAPI","/api/mioos/fs/write",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][fs mkdir]","POST","/api/mioos/fs/mkdir",1,"FSMKDIR^MIOOSAPI","/api/mioos/fs/mkdir",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][fs blob get]","GET","/api/mioos/fs/blob",1,"FSBLOB^MIOOSAPI","/api/mioos/fs/blob",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][fs blob head]","HEAD","/api/mioos/fs/blob",1,"FSBLOB^MIOOSAPI","/api/mioos/fs/blob",.EP)
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
	DO EQ^MIOTASSERT($GET(OBJ("routes","passwordChange")),"/api/mioos/auth/password/change","[MIOOST][T002][password change route]")
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
	DO EQ^MIOTASSERT($GET(OBJ("routes","fsBlob")),"/api/mioos/fs/blob","[MIOOST][T002][fs blob route]")
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
	KILL ERR
	DO EQ^MIOTASSERT($$GUESTSIGNIN^MIOOSAUTH(.CONF,.TOKEN,.ERR),0,"[MIOOST][T005][guest signin disabled]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"guest_login_disabled","[MIOOST][T005][guest error]")
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
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","win.appKey === 'pdf-viewer'"),"[MIOOST][T020][pdf viewer token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","win.appKey === 'structured-viewer'"),"[MIOOST][T020][structured viewer token]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","openPdfViewerWindow"),"[MIOOST][T020][pdf viewer method]")
	QUIT
	;
	;
T021
	NEW CONF,REQ,CTX,STATE,ERR,OUT,ID,HASH
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO INIT^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T021][load]")
	KILL OUT DO OK^MIOTASSERT($$WRITE^MIOOSFS(.STATE,$$HOMEID^MIOOSFS(),"download.txt","alpha beta gamma delta","text/plain",.OUT,.ERR),"[MIOOST][T021][write]")
	SET ID=$GET(OUT("id"))
	KILL HASH,ERR DO OK^MIOTASSERT($$HASH^MIOOSFS(.STATE,ID,.HASH,.ERR),"[MIOOST][T021][hash]")
	DO EQ^MIOTASSERT($GET(HASH("sha256"))'="",1,"[MIOOST][T021][sha present]")
	DO EQ^MIOTASSERT($GET(HASH("sha256")),$$SHA256^MIOSHA256("alpha beta gamma delta"),"[MIOOST][T021][sha value]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","buildFsBlobUrl(this, item, { download: true })"),"[MIOOST][T021][direct blob handoff]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSAPI.m","FSBLOB(DEV,CONF,REQ,CTX)"),"[MIOOST][T021][blob handler]")
	QUIT
	;
	;
T023
	NEW CONF,REQ,CTX,STATE,ERR,OUT,UP,STAT,PURGE,NOW
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO INIT^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T023][load]")
	KILL OUT DO OK^MIOTASSERT($$BEGIN^MIOOSFSUP(.STATE,.CONF,$$HOMEID^MIOOSFS(),"resume.txt","text/plain",11,"text",.OUT,.ERR),"[MIOOST][T023][upload begin]")
	SET UP=$GET(OUT("uploadId"))
	KILL OUT DO OK^MIOTASSERT($$CHUNK^MIOOSFSUP(.STATE,.CONF,UP,1,"hello",5,.OUT,.ERR),"[MIOOST][T023][upload chunk]")
	KILL STAT DO OK^MIOTASSERT($$STATUS^MIOOSFSUP(.STATE,.CONF,UP,.STAT,.ERR),"[MIOOST][T023][upload status]")
	DO EQ^MIOTASSERT(+$GET(STAT("receivedBytes")),5,"[MIOOST][T023][status bytes]")
	SET NOW=$HOROLOG
	SET ^MIO("MIOOS","UPLOAD","INFO",UP,"updatedAt")=(+NOW-1)_","_$PIECE(NOW,",",2)
	KILL OUT SET PURGE=$$PURGE^MIOOSFSUP(.CONF,.OUT)
	DO EQ^MIOTASSERT(PURGE,1,"[MIOOST][T023][purge count]")
	DO EQ^MIOTASSERT($DATA(^MIO("MIOOS","UPLOAD","META",UP))#2,0,"[MIOOST][T023][purged meta]")
	QUIT
	;
T024
	NEW CONF,REQ,CTX,STATE,ERR
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO INIT^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T024][load]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","cancelTransfer"),"[MIOOST][T024][cancel transfer method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","retryTransfer"),"[MIOOST][T024][retry transfer method]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","@click=""cancelTransfer(item)"""),"[MIOOST][T024][cancel transfer button]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","@click=""retryTransfer(item)"""),"[MIOOST][T024][retry transfer button]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 21 — Transfer resiliency, cancellation, retry, and stale-session cleanup"),"[MIOOST][T024][llm roi21]")
	QUIT
	;
T026
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-transport-diagnostics-window=""1"""),"[MIOOST][T026][diagnostics window token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","refreshTransportDiagnostics()"),"[MIOOST][T026][diagnostics refresh]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","transportSocketRows"),"[MIOOST][T026][socket telemetry rows]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_ws.js","setSocketTelemetry('core-1'"),"[MIOOST][T026][core socket telemetry]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","label: 'FS Worker ' + ordinal"),"[MIOOST][T026][worker socket telemetry]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSWS.m","transport.health"),"[MIOOST][T026][ws transport health]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css",".mioos-diagnostics-shell"),"[MIOOST][T026][diagnostics css]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 22 — Transport diagnostics and socket health"),"[MIOOST][T026][llm roi22]")
	QUIT
	;
T027
	NEW CONF,REQ,CTX,STATE,ERR,JSON,OBJ,PAY
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T027][load]")
	SET JSON=$$BOOTJSON^MIOOSST(.STATE,.CONF)
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T027][decode]")
	DO EQ^MIOTASSERT(+$GET(OBJ("desktop","moduleSystem","enabled")),1,"[MIOOST][T027][module enabled]")
	DO EQ^MIOTASSERT($GET(OBJ("apps",8,"key")),"app-catalog","[MIOOST][T027][catalog app]")
	DO EQ^MIOTASSERT($GET(OBJ("modules",1,"id")),"module-notes","[MIOOST][T027][module notes]")
	DO EQ^MIOTASSERT($GET(OBJ("windows",9,"moduleId")),"module-notes","[MIOOST][T027][module window]")
	SET PAY="{""event"":""desktop.command"",""requestId"":""module-1"",""command"":""module.catalog""}"
	DO OK^MIOTASSERT($$COMMANDJSON^MIOOSWS(.CONF,.REQ,.CTX,.STATE,PAY,.JSON,.ERR),"[MIOOST][T027][module catalog]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T027][module decode]")
	DO EQ^MIOTASSERT($GET(OBJ("command")),"module.catalog","[MIOOST][T027][module command]")
	DO EQ^MIOTASSERT($GET(OBJ("module","count"))>1,1,"[MIOOST][T027][module count]")
	QUIT
	;
T028
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-module-catalog-window=""1"""),"[MIOOST][T028][catalog token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-module-window=""1"""),"[MIOOST][T028][module window token]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","refreshModuleCatalog"),"[MIOOST][T028][refresh catalog]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","openModuleEntry"),"[MIOOST][T028][open module entry]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSWS.m","module.catalog"),"[MIOOST][T028][ws module catalog]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css",".mioos-module-catalog-shell"),"[MIOOST][T028][module catalog css]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 23 — Module catalog and built-in module host"),"[MIOOST][T028][llm roi23]")
	QUIT
	;
T029
	NEW CONF,REQ,CTX,STATE,ERR,JSON,OBJ,TOKEN
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO INIT^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T029][load]")
	SET JSON=$$BOOTJSON^MIOOSST(.STATE,.CONF)
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T029][decode]")
	DO EQ^MIOTASSERT($GET(OBJ("auth","required")),1,"[MIOOST][T029][auth required]")
	DO EQ^MIOTASSERT($GET(OBJ("auth","guestLoginEnabled")),0,"[MIOOST][T029][guest disabled]")
	DO EQ^MIOTASSERT($GET(OBJ("auth","unauthenticatedAccessAllowed")),0,"[MIOOST][T029][unauth blocked]")
	DO EQ^MIOTASSERT($GET(OBJ("auth","providers","local","enabled")),1,"[MIOOST][T029][local provider]")
	DO EQ^MIOTASSERT($GET(OBJ("auth","providers","framework","enabled")),1,"[MIOOST][T029][framework provider]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","auditExport")),"/api/mioos/auth/audit/export","[MIOOST][T029][audit export route]")
	DO EQ^MIOTASSERT($GET(OBJ("apps",11,"key")),"security-center","[MIOOST][T029][security app]")
	DO EQ^MIOTASSERT($GET(OBJ("windows",11,"appKey")),"security-center","[MIOOST][T029][security window]")
	KILL ERR
	DO EQ^MIOTASSERT($$GUESTSIGNIN^MIOOSAUTH(.CONF,.TOKEN,.ERR),0,"[MIOOST][T029][guest disabled auth]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"guest_login_disabled","[MIOOST][T029][guest disabled reason]")
	DO OK^MIOTASSERT($$SIGNIN^MIOOSAUTH(.CONF,"admin","admin123!",.TOKEN,.ERR),"[MIOOST][T029][signin admin]")
	DO OK^MIOTASSERT($$COUNT^MIOOSAUD()>0,"[MIOOST][T029][audit count]")
	QUIT
	;
T030
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-security-center-window=""1"""),"[MIOOST][T030][security window token]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","refreshSecurityCenter"),"[MIOOST][T030][refresh security method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","exportSecurityAudit"),"[MIOOST][T030][export security method]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSWS.m","auth.report"),"[MIOOST][T030][ws auth report]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSWS.m","auth.audit"),"[MIOOST][T030][ws auth audit]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSAPI.m","AUDITX(DEV,CONF,REQ,CTX)"),"[MIOOST][T030][audit export handler]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 24 — Typed authentication, local/framework auditability, and HIPAA reportability"),"[MIOOST][T030][llm roi24]")
	QUIT
	;
T031
	NEW CONF,REQ,CTX,STATE,ERR,JSON,OBJ,PAY,TOKEN,TOKEN2,SID,FOUND,I
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO INIT^MIOOS(.CONF)
	DO OK^MIOTASSERT($$SIGNIN^MIOOSAUTH(.CONF,"admin","admin123!",.TOKEN,.ERR),"[MIOOST][T031][signin admin]")
	DO OK^MIOTASSERT($$SIGNIN^MIOOSAUTH(.CONF,"user","user123!",.TOKEN2,.ERR),"[MIOOST][T031][signin user]")
	SET REQ("hdr","cookie")=$PIECE($$COOKIEHDR^MIOOSAUTH(.CONF,TOKEN,0),";",1)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T031][load]")
	FOR I=1:1:5 DO FAILLOGIN^MIOOSAUTH(.CONF,"user")
	SET PAY="{""event"":""desktop.command"",""requestId"":""sec-1"",""command"":""auth.sessions""}"
	DO OK^MIOTASSERT($$COMMANDJSON^MIOOSWS(.CONF,.REQ,.CTX,.STATE,PAY,.JSON,.ERR),"[MIOOST][T031][auth sessions]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T031][sessions decode]")
	DO EQ^MIOTASSERT($GET(OBJ("command")),"auth.sessions","[MIOOST][T031][sessions command]")
	DO EQ^MIOTASSERT(+$GET(OBJ("auth","count"))>1,1,"[MIOOST][T031][sessions count]")
	SET SID="",FOUND=0
	FOR I=1:1 QUIT:'$DATA(OBJ("auth","entries",I))  DO  QUIT:FOUND
	. IF +$GET(OBJ("auth","entries",I,"current"))=1 QUIT
	. SET SID=$GET(OBJ("auth","entries",I,"sessionId"))
	. IF SID'="" SET FOUND=1
	DO EQ^MIOTASSERT(FOUND,1,"[MIOOST][T031][revoke sid found]")
	SET PAY="{""event"":""desktop.command"",""requestId"":""sec-2"",""command"":""auth.session.revoke"",""sessionId"":"""_SID_"""}"
	DO OK^MIOTASSERT($$COMMANDJSON^MIOOSWS(.CONF,.REQ,.CTX,.STATE,PAY,.JSON,.ERR),"[MIOOST][T031][revoke session]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T031][revoke decode]")
	DO EQ^MIOTASSERT(+$GET(OBJ("auth","revoked")),1,"[MIOOST][T031][revoke flag]")
	SET PAY="{""event"":""desktop.command"",""requestId"":""sec-3"",""command"":""auth.accounts""}"
	DO OK^MIOTASSERT($$COMMANDJSON^MIOOSWS(.CONF,.REQ,.CTX,.STATE,PAY,.JSON,.ERR),"[MIOOST][T031][auth accounts]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T031][accounts decode]")
	DO EQ^MIOTASSERT($GET(OBJ("command")),"auth.accounts","[MIOOST][T031][accounts command]")
	DO EQ^MIOTASSERT(+$GET(OBJ("auth","lockedCount"))>0,1,"[MIOOST][T031][locked count]")
	SET PAY="{""event"":""desktop.command"",""requestId"":""sec-4"",""command"":""auth.user.unlock"",""username"":""user""}"
	DO OK^MIOTASSERT($$COMMANDJSON^MIOOSWS(.CONF,.REQ,.CTX,.STATE,PAY,.JSON,.ERR),"[MIOOST][T031][unlock user]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T031][unlock decode]")
	DO EQ^MIOTASSERT(+$GET(OBJ("auth","unlocked")),1,"[MIOOST][T031][unlock flag]")
	DO EQ^MIOTASSERT($$ISLOCKED^MIOOSAUTH("user"),0,"[MIOOST][T031][unlock cleared]")
	QUIT
	;
T032
	NEW CONF,REQ,CTX,STATE,ERR,JSON,OBJ
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T032][load]")
	SET JSON=$$BOOTJSON^MIOOSST(.STATE,.CONF)
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T032][decode]")
	DO EQ^MIOTASSERT(+$GET(OBJ("auth","management","sessionAdminEnabled")),1,"[MIOOST][T032][session admin enabled]")
	DO EQ^MIOTASSERT(+$GET(OBJ("auth","management","accountAdminEnabled")),1,"[MIOOST][T032][account admin enabled]")
	DO EQ^MIOTASSERT(+$GET(OBJ("auth","management","sessionLimit")),20,"[MIOOST][T032][session limit]")
	DO EQ^MIOTASSERT(+$GET(OBJ("auth","management","accountLimit")),20,"[MIOOST][T032][account limit]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-security-session-admin=""1"""),"[MIOOST][T032][session admin token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-security-account-admin=""1"""),"[MIOOST][T032][account admin token]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","revokeSecuritySession"),"[MIOOST][T032][revoke session method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","unlockSecurityUser"),"[MIOOST][T032][unlock user method]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSWS.m","auth.sessions"),"[MIOOST][T032][ws auth sessions]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSWS.m","auth.session.revoke"),"[MIOOST][T032][ws auth revoke]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSWS.m","auth.accounts"),"[MIOOST][T032][ws auth accounts]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSWS.m","auth.user.unlock"),"[MIOOST][T032][ws auth unlock]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 25 — Session governance, account lockout administration, and auditable security operations"),"[MIOOST][T032][llm roi25]")
	QUIT
	;
T033
	NEW CONF,ERR,TOKEN,OUT,TOKEN2,CHANGETOKEN
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	SET CONF("mioos","bootstrapAuth","admin","forcePasswordChange")=1
	DO INIT^MIOOS(.CONF)
	DO EQ^MIOTASSERT($$SIGNIN^MIOOSAUTH(.CONF,"admin","admin123!",.TOKEN,.ERR),0,"[MIOOST][T033][signin requires change]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"password_change_required","[MIOOST][T033][signin error]")
	SET CHANGETOKEN=$GET(ERR("changeToken"))
	DO EQ^MIOTASSERT(CHANGETOKEN'="",1,"[MIOOST][T033][change token]")
	DO EQ^MIOTASSERT(+$GET(ERR("passwordStatus","requiresChange")),1,"[MIOOST][T033][requires change]")
	KILL OUT,ERR
	DO OK^MIOTASSERT($$CHANGEPASSWORD^MIOOSAUTH(.CONF,CHANGETOKEN,"Admin2026!X1",.TOKEN2,.OUT,.ERR),"[MIOOST][T033][change password]")
	DO EQ^MIOTASSERT(+$GET(OUT("passwordChanged")),1,"[MIOOST][T033][password changed]")
	DO EQ^MIOTASSERT($GET(^MIO("MIOOS","USER","admin","passwordSource")),"local-rotated","[MIOOST][T033][password source]")
	DO EQ^MIOTASSERT(+$GET(^MIO("MIOOS","USER","admin","forcePasswordChange")),0,"[MIOOST][T033][force cleared]")
	KILL ERR
	DO EQ^MIOTASSERT($$SIGNIN^MIOOSAUTH(.CONF,"admin","admin123!",.TOKEN,.ERR),0,"[MIOOST][T033][old password denied]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"invalid_credentials","[MIOOST][T033][old password error]")
	KILL ERR
	DO OK^MIOTASSERT($$SIGNIN^MIOOSAUTH(.CONF,"admin","Admin2026!X1",.TOKEN,.ERR),"[MIOOST][T033][new password signin]")
	QUIT
	;
T034
	NEW CONF,REQ,CTX,STATE,ERR,JSON,OBJ
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T034][load]")
	SET JSON=$$BOOTJSON^MIOOSST(.STATE,.CONF)
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T034][decode]")
	DO EQ^MIOTASSERT(+$GET(OBJ("auth","passwordPolicy","minLength")),12,"[MIOOST][T034][min length]")
	DO EQ^MIOTASSERT(+$GET(OBJ("auth","passwordPolicy","maxAgeDays")),90,"[MIOOST][T034][max age]")
	DO EQ^MIOTASSERT(+$GET(OBJ("auth","passwordPolicy","changeTokenMinutes")),15,"[MIOOST][T034][change token minutes]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-auth-password-change=""1"""),"[MIOOST][T034][password change token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-security-password-posture=""1"""),"[MIOOST][T034][password posture token]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_auth.js","submitPasswordChange"),"[MIOOST][T034][submit password change]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_auth.js","passwordPolicyLines"),"[MIOOST][T034][password policy lines]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSAPI.m","CHANGEPASSWORD(DEV,CONF,REQ,CTX)"),"[MIOOST][T034][password change route handler]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSWS.m","CREDREPORT^MIOOSAUTH"),"[MIOOST][T034][credential report hook]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 26 — Password policy, rotation, and credential health"),"[MIOOST][T034][llm roi26]")
	DO OK^MIOTASSERT($$FILEHAS("docs/mioos/README.md","ROI 26 — Password policy, rotation, and credential health"),"[MIOOST][T034][docs roi26]")
	QUIT
	;
	;
T035
	NEW CONF,REQ,CTX,STATE,ERR,JSON,OBJ,PAY
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T035][load]")
	SET PAY="{""event"":""desktop.command"",""requestId"":""dbg-1"",""command"":""debug.snapshot""}"
	DO OK^MIOTASSERT($$COMMANDJSON^MIOOSWS(.CONF,.REQ,.CTX,.STATE,PAY,.JSON,.ERR),"[MIOOST][T035][debug snapshot]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T035][decode]")
	DO EQ^MIOTASSERT($GET(OBJ("event")),"desktop.result","[MIOOST][T035][event]")
	DO EQ^MIOTASSERT($GET(OBJ("command")),"debug.snapshot","[MIOOST][T035][command]")
	DO EQ^MIOTASSERT($GET(OBJ("debug","routes","viewCommand")),"view.refresh","[MIOOST][T035][view command]")
	DO EQ^MIOTASSERT(+$GET(OBJ("debug","transport","diagnosticsEnabled")),1,"[MIOOST][T035][diagnostics enabled]")
	DO EQ^MIOTASSERT(+$GET(OBJ("debug","counts","apps"))>0,1,"[MIOOST][T035][apps count]")
	DO EQ^MIOTASSERT($GET(OBJ("debug","debug","commands",10)),"debug.snapshot","[MIOOST][T035][command registry]")
	QUIT
	;
T036
	NEW CONF,REQ,CTX,STATE,ERR,JSON,OBJ
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T036][load]")
	SET JSON=$$BOOTJSON^MIOOSST(.STATE,.CONF)
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T036][decode]")
	DO EQ^MIOTASSERT(+$GET(OBJ("desktop","debugCenter","enabled")),1,"[MIOOST][T036][debug center enabled]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","debugSnapshotCommand")),"debug.snapshot","[MIOOST][T036][debug route]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","moduleSystem","debugAppKey")),"debug-center","[MIOOST][T036][debug app key]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-debug-center-window=""1"""),"[MIOOST][T036][debug window token]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","refreshDebugCenter"),"[MIOOST][T036][refresh debug method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","pushDebugEvent"),"[MIOOST][T036][push event method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","clearDebugEvents"),"[MIOOST][T036][clear event method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","debugCommandRows"),"[MIOOST][T036][command rows method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_ws.js","pushDebugEvent('socket.message'"),"[MIOOST][T036][socket message debug]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSWS.m","debug.snapshot"),"[MIOOST][T036][ws debug snapshot]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 27 — Debug Center and developer tools"),"[MIOOST][T036][llm roi27]")
	DO OK^MIOTASSERT($$FILEHAS("docs/mioos/README.md","ROI 27 — Debug Center and developer tools"),"[MIOOST][T036][docs roi27]")
	QUIT
	;
	;
T037
	NEW CONF,EP
	DO RESET
	DO REG^MIOOS(.CONF)
	DO COMPILE
	KILL EP DO AMATCH("[MIOOST][T037][fs upload begin]","POST","/api/mioos/fs/upload/begin",1,"FSUPBEGIN^MIOOSAPI","/api/mioos/fs/upload/begin",.EP)
	KILL EP DO AMATCH("[MIOOST][T037][fs upload chunk]","POST","/api/mioos/fs/upload/chunk",1,"FSUPCHUNK^MIOOSAPI","/api/mioos/fs/upload/chunk",.EP)
	KILL EP DO AMATCH("[MIOOST][T037][fs upload status]","POST","/api/mioos/fs/upload/status",1,"FSUPSTATUS^MIOOSAPI","/api/mioos/fs/upload/status",.EP)
	KILL EP DO AMATCH("[MIOOST][T037][fs upload commit]","POST","/api/mioos/fs/upload/commit",1,"FSUPCOMMIT^MIOOSAPI","/api/mioos/fs/upload/commit",.EP)
	KILL EP DO AMATCH("[MIOOST][T037][fs upload abort]","POST","/api/mioos/fs/upload/abort",1,"FSUPABORT^MIOOSAPI","/api/mioos/fs/upload/abort",.EP)
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","fsUploadChunk"),"[MIOOST][T037][explorer upload chunk route]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","application/octet-stream"),"[MIOOST][T037][binary content type]")
	QUIT
	;
T038
	NEW CONF,STATE,OUT,ERR,UP
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO INIT^MIOOS(.CONF)
	SET STATE("principal")=$GET(CONF("mioos","bootstrapAuth","admin","username"),"admin")
	SET STATE("roles")=$GET(CONF("mioos","bootstrapAuth","admin","roles"),"admin")
	SET UP=""
	DO OK^MIOTASSERT($$BEGIN^MIOOSFSUP(.STATE,.CONF,"fs-2","chunk.bin","application/octet-stream",12,"binary",.OUT,.ERR),"[MIOOST][T038][begin]")
	SET UP=$GET(OUT("uploadId"))
	KILL OUT,ERR
	DO OK^MIOTASSERT($$CHUNK^MIOOSFSUP(.STATE,.CONF,UP,1,"ABCD",4,.OUT,.ERR),"[MIOOST][T038][chunk1]")
	KILL OUT,ERR
	DO OK^MIOTASSERT($$CHUNK^MIOOSFSUP(.STATE,.CONF,UP,3,"IJKL",4,.OUT,.ERR),"[MIOOST][T038][chunk3]")
	KILL OUT,ERR
	DO OK^MIOTASSERT($$STATUS^MIOOSFSUP(.STATE,.CONF,UP,.OUT,.ERR),"[MIOOST][T038][status]")
	DO EQ^MIOTASSERT(+$GET(OUT("nextIndex")),2,"[MIOOST][T038][next index]")
	DO EQ^MIOTASSERT(+$GET(OUT("contiguousBytes")),4,"[MIOOST][T038][contiguous bytes]")
	KILL OUT,ERR
	DO EQ^MIOTASSERT($$COMMIT^MIOOSFSUP(.STATE,.CONF,UP,.OUT,.ERR),0,"[MIOOST][T038][commit blocked]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"missing_chunk","[MIOOST][T038][missing chunk]")
	QUIT
	;
T039
	NEW CONF,STATE,OUT,ERR,UP,ID,RAW,READOUT,DL,CHUNK,B64
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO INIT^MIOOS(.CONF)
	SET STATE("principal")=$GET(CONF("mioos","bootstrapAuth","admin","username"),"admin")
	SET STATE("roles")=$GET(CONF("mioos","bootstrapAuth","admin","roles"),"admin")
	SET RAW=$CHAR(1,2,3,34,92,127)_"MIO"
	DO OK^MIOTASSERT($$BEGIN^MIOOSFSUP(.STATE,.CONF,"fs-2","roundtrip.bin","application/octet-stream",$LENGTH(RAW),"binary",.OUT,.ERR),"[MIOOST][T039][begin]")
	SET UP=$GET(OUT("uploadId"))
	KILL OUT,ERR
	DO OK^MIOTASSERT($$CHUNK^MIOOSFSUP(.STATE,.CONF,UP,1,RAW,$LENGTH(RAW),.OUT,.ERR),"[MIOOST][T039][chunk]")
	KILL OUT,ERR
	DO OK^MIOTASSERT($$STATUS^MIOOSFSUP(.STATE,.CONF,UP,.OUT,.ERR),"[MIOOST][T039][status]")
	DO EQ^MIOTASSERT(+$GET(OUT("nextIndex")),2,"[MIOOST][T039][next index]")
	DO EQ^MIOTASSERT(+$GET(OUT("chunkCount")),1,"[MIOOST][T039][chunk count]")
	DO EQ^MIOTASSERT(+$GET(OUT("expectedChunks")),1,"[MIOOST][T039][expected chunks]")
	DO EQ^MIOTASSERT(+$GET(OUT("contiguousBytes")),$LENGTH(RAW),"[MIOOST][T039][contiguous bytes]")
	KILL OUT,ERR
	DO OK^MIOTASSERT($$COMMIT^MIOOSFSUP(.STATE,.CONF,UP,.OUT,.ERR),"[MIOOST][T039][commit]")
	SET ID=$GET(OUT("id"))
	DO OK^MIOTASSERT(ID'="","[MIOOST][T039][file id]")
	KILL READOUT,ERR
	DO OK^MIOTASSERT($$READ^MIOOSFS(.STATE,ID,.READOUT,.ERR),"[MIOOST][T039][read]")
	DO EQ^MIOTASSERT($GET(READOUT("encoding")),"base64-dataurl","[MIOOST][T039][read encoding]")
	SET B64=$PIECE($GET(READOUT("content")),",",2,99)
	DO EQ^MIOTASSERT($$B64D^MIOSJWT(B64),RAW,"[MIOOST][T039][read roundtrip]")
	KILL CHUNK,ERR
	DO OK^MIOTASSERT($$READRANGE^MIOOSFS(ID,0,$LENGTH(RAW),.CHUNK,.READ,.ERR),"[MIOOST][T039][readrange]")
	DO EQ^MIOTASSERT(CHUNK,RAW,"[MIOOST][T039][readrange roundtrip]")
	DO EQ^MIOTASSERT(READ,$LENGTH(RAW),"[MIOOST][T039][readrange bytes]")
	QUIT
	;
T040
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","buildFsBlobUrl"),"[MIOOST][T040][blob url helper]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","routes || {}).fsBlob"),"[MIOOST][T040][blob route usage]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","download=1"),"[MIOOST][T040][direct download flag]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSAPI.m","FSBLOB(DEV,CONF,REQ,CTX)"),"[MIOOST][T040][blob handler]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSAPI.m","Accept-Ranges"),"[MIOOST][T040][range header]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSAPI.m","PARSERANGE^MIOSTATIC"),"[MIOOST][T040][range parser]")
	QUIT
	;
T041
	NEW CONF,REQ,CTX,STATE,ERR,JSON,OBJ
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T041][load]")
	SET JSON=$$BOOTJSON^MIOOSST(.STATE,.CONF)
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T041][decode]")
	DO EQ^MIOTASSERT(+$GET(OBJ("vfs","chunkSize")),860000,"[MIOOST][T041][vfs chunk size]")
	DO EQ^MIOTASSERT(+$GET(OBJ("vfs","httpChunkBytes")),860000,"[MIOOST][T041][http chunk bytes]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","performance","downloadStrategy")),"direct-http-range-native","[MIOOST][T041][download strategy]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 36 — VFS storage layout acceleration and upload accounting"),"[MIOOST][T041][llm roi36]")
	DO OK^MIOTASSERT($$FILEHAS("docs/mioos/README.md","ROI 36 — VFS storage layout acceleration and upload accounting"),"[MIOOST][T041][docs roi36]")
	QUIT
	;
T042 QUIT
	NEW CONF,STATE,OUT,ERR,ID,BIG,SEG1,SEG2,SEG3,SLICE,READ,EXPECT,LID,LEGACY,NOW,I
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO INIT^MIOOS(.CONF)
	SET STATE("principal")=$GET(CONF("mioos","bootstrapAuth","admin","username"),"admin")
	SET STATE("roles")=$GET(CONF("mioos","bootstrapAuth","admin","roles"),"admin")
	SET SEG1=$TRANSLATE($JUSTIFY("",131072)," ","A")
	SET SEG2=$TRANSLATE($JUSTIFY("",131072)," ","B")
	SET SEG3=$TRANSLATE($JUSTIFY("",4464)," ","C")
	SET BIG=SEG1_SEG2_SEG3
	DO OK^MIOTASSERT($$WRITE^MIOOSFS(.STATE,$$HOMEID^MIOOSFS(),"big.txt",BIG,"text/plain",.OUT,.ERR),"[MIOOST][T042][write]")
	SET ID=$GET(OUT("id"))
	DO EQ^MIOTASSERT(+$GET(^MIO("MIOOS","FS","INFO",ID,"chunkSize")),131072,"[MIOOST][T042][stored chunk size]")
	DO EQ^MIOTASSERT($ORDER(^MIO("MIOOS","FS","DATA",ID,""),-1),3,"[MIOOST][T042][segment count]")
	KILL SLICE,ERR
	DO OK^MIOTASSERT($$READRANGE^MIOOSFS(ID,131000,8000,.SLICE,.READ,.ERR),"[MIOOST][T042][readrange new]")
	SET EXPECT=$TRANSLATE($JUSTIFY("",72)," ","A")_$TRANSLATE($JUSTIFY("",7928)," ","B")
	DO EQ^MIOTASSERT(SLICE,EXPECT,"[MIOOST][T042][readrange new content]")
	SET LID=$$NEXTID^MIOOSFS(),NOW=$HOROLOG,LEGACY=""
	FOR I=1:1:5000 SET LEGACY=LEGACY_$CHAR(97+((I-1)#26))
	DO SAVEENTRY^MIOOSFS(LID,"file",$$HOMEID^MIOOSFS(),"legacy.txt","text/plain",$LENGTH(LEGACY),NOW,NOW,STATE("principal"),STATE("roles"),1,1,1)
	SET ^MIO("MIOOS","FS","CHILD",$$HOMEID^MIOOSFS(),"legacy.txt")=LID
	SET ^MIO("MIOOS","FS","DATA",LID,1)=$EXTRACT(LEGACY,1,2048)
	SET ^MIO("MIOOS","FS","DATA",LID,2)=$EXTRACT(LEGACY,2049,4096)
	SET ^MIO("MIOOS","FS","DATA",LID,3)=$EXTRACT(LEGACY,4097,5000)
	KILL SLICE,ERR
	DO OK^MIOTASSERT($$READRANGE^MIOOSFS(LID,1900,600,.SLICE,.READ,.ERR),"[MIOOST][T042][readrange legacy]")
	DO EQ^MIOTASSERT(SLICE,$EXTRACT(LEGACY,1901,2500),"[MIOOST][T042][readrange legacy content]")
	QUIT
	;
T043
	NEW CONF,STATE,OUT,ERR,UP
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO INIT^MIOOS(.CONF)
	SET STATE("principal")=$GET(CONF("mioos","bootstrapAuth","admin","username"),"admin")
	SET STATE("roles")=$GET(CONF("mioos","bootstrapAuth","admin","roles"),"admin")
	DO OK^MIOTASSERT($$BEGIN^MIOOSFSUP(.STATE,.CONF,"fs-2","delta.bin","application/octet-stream",8,"binary",.OUT,.ERR),"[MIOOST][T043][begin]")
	SET UP=$GET(OUT("uploadId"))
	KILL OUT,ERR
	DO OK^MIOTASSERT($$CHUNK^MIOOSFSUP(.STATE,.CONF,UP,1,"ABCD",4,.OUT,.ERR),"[MIOOST][T043][chunk1]")
	DO EQ^MIOTASSERT(+$GET(OUT("receivedBytes")),4,"[MIOOST][T043][bytes 4]")
	KILL OUT,ERR
	DO OK^MIOTASSERT($$CHUNK^MIOOSFSUP(.STATE,.CONF,UP,2,"EFGH",4,.OUT,.ERR),"[MIOOST][T043][chunk2]")
	DO EQ^MIOTASSERT(+$GET(OUT("receivedBytes")),8,"[MIOOST][T043][bytes 8]")
	KILL OUT,ERR
	DO OK^MIOTASSERT($$CHUNK^MIOOSFSUP(.STATE,.CONF,UP,1,"ABC",3,.OUT,.ERR),"[MIOOST][T043][chunk1 replace]")
	DO EQ^MIOTASSERT(+$GET(OUT("receivedBytes")),7,"[MIOOST][T043][bytes 7]")
	KILL OUT,ERR
	DO OK^MIOTASSERT($$STATUS^MIOOSFSUP(.STATE,.CONF,UP,.OUT,.ERR),"[MIOOST][T043][status]")
	DO EQ^MIOTASSERT(+$GET(OUT("receivedBytes")),7,"[MIOOST][T043][status bytes]")
	QUIT
	;
T044
	NEW CONF,STATE,OUT,ERR,UP,TEMPID,ID,RAW
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO INIT^MIOOS(.CONF)
	SET STATE("principal")=$GET(CONF("mioos","bootstrapAuth","admin","username"),"admin")
	SET STATE("roles")=$GET(CONF("mioos","bootstrapAuth","admin","roles"),"admin")
	SET RAW="PROMOTE-FAST-PATH"
	DO OK^MIOTASSERT($$BEGIN^MIOOSFSUP(.STATE,.CONF,"fs-2","fast.bin","application/octet-stream",$LENGTH(RAW),"binary",.OUT,.ERR),"[MIOOST][T044][begin]")
	SET UP=$GET(OUT("uploadId"))
	SET TEMPID=$GET(^MIO("MIOOS","UPLOAD","INFO",UP,"tempId"))
	DO EQ^MIOTASSERT(+$GET(^MIO("MIOOS","UPLOAD","INFO",UP,"fastPromote")),1,"[MIOOST][T044][fast promote]")
	DO EQ^MIOTASSERT($GET(OUT("commitStrategy")),"direct-stage-promote","[MIOOST][T044][begin strategy]")
	KILL OUT,ERR
	DO OK^MIOTASSERT($$CHUNK^MIOOSFSUP(.STATE,.CONF,UP,1,RAW,$LENGTH(RAW),.OUT,.ERR),"[MIOOST][T044][chunk]")
	DO EQ^MIOTASSERT($GET(^MIO("MIOOS","FS","DATA",TEMPID,1)),RAW,"[MIOOST][T044][staged data]")
	KILL OUT,ERR
	DO OK^MIOTASSERT($$STATUS^MIOOSFSUP(.STATE,.CONF,UP,.OUT,.ERR),"[MIOOST][T044][status]")
	DO EQ^MIOTASSERT($GET(OUT("commitStrategy")),"direct-stage-promote","[MIOOST][T044][status strategy]")
	KILL OUT,ERR
	DO OK^MIOTASSERT($$COMMIT^MIOOSFSUP(.STATE,.CONF,UP,.OUT,.ERR),"[MIOOST][T044][commit]")
	SET ID=$GET(OUT("id"))
	DO EQ^MIOTASSERT(ID,TEMPID,"[MIOOST][T044][promoted id]")
	DO EQ^MIOTASSERT(+$GET(^MIO("MIOOS","FS","INFO",ID,"chunkSize")),860000,"[MIOOST][T044][promoted chunk size]")
	DO EQ^MIOTASSERT($GET(^MIO("MIOOS","FS","DATA",ID,1)),RAW,"[MIOOST][T044][final data]")
	DO EQ^MIOTASSERT($DATA(^MIO("MIOOS","UPLOAD","INFO",UP)),0,"[MIOOST][T044][stage cleaned]")
	QUIT
	;
T045
	NEW CONF,STATE,OUT,ERR,UP,ID1,ID2,READOUT,RAW
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO INIT^MIOOS(.CONF)
	SET STATE("principal")=$GET(CONF("mioos","bootstrapAuth","admin","username"),"admin")
	SET STATE("roles")=$GET(CONF("mioos","bootstrapAuth","admin","roles"),"admin")
	DO OK^MIOTASSERT($$WRITE^MIOOSFS(.STATE,"fs-2","overwrite.bin","OLD","application/octet-stream",.OUT,.ERR),"[MIOOST][T045][seed]")
	SET ID1=$GET(OUT("id"))
	SET RAW=$CHAR(1,2,3)_"OVERWRITE"
	KILL OUT,ERR
	DO OK^MIOTASSERT($$BEGIN^MIOOSFSUP(.STATE,.CONF,"fs-2","overwrite.bin","application/octet-stream",$LENGTH(RAW),"binary",.OUT,.ERR),"[MIOOST][T045][begin]")
	SET UP=$GET(OUT("uploadId"))
	DO EQ^MIOTASSERT(+$GET(^MIO("MIOOS","UPLOAD","INFO",UP,"fastPromote")),0,"[MIOOST][T045][overwrite fallback]")
	DO EQ^MIOTASSERT($GET(OUT("commitStrategy")),"copy-on-commit","[MIOOST][T045][begin strategy]")
	KILL OUT,ERR
	DO OK^MIOTASSERT($$CHUNK^MIOOSFSUP(.STATE,.CONF,UP,1,RAW,$LENGTH(RAW),.OUT,.ERR),"[MIOOST][T045][chunk]")
	KILL OUT,ERR
	DO OK^MIOTASSERT($$COMMIT^MIOOSFSUP(.STATE,.CONF,UP,.OUT,.ERR),"[MIOOST][T045][commit]")
	SET ID2=$GET(OUT("id"))
	DO EQ^MIOTASSERT(ID2,ID1,"[MIOOST][T045][preserve id]")
	KILL READOUT,ERR
	DO OK^MIOTASSERT($$READ^MIOOSFS(.STATE,ID2,.READOUT,.ERR),"[MIOOST][T045][read]")
	DO EQ^MIOTASSERT($GET(READOUT("encoding")),"base64-dataurl","[MIOOST][T045][read encoding]")
	DO EQ^MIOTASSERT($$B64D^MIOSJWT($PIECE($GET(READOUT("content")),",",2,99)),RAW,"[MIOOST][T045][roundtrip]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSST.m","uploadFinalizeStrategy"),"[MIOOST][T045][boot finalize strategy]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 37 — upload finalize direct-stage promote for new binary files"),"[MIOOST][T045][llm roi37]")
	DO OK^MIOTASSERT($$FILEHAS("docs/mioos/README.md","ROI 37 — upload finalize direct-stage promote for new binary files"),"[MIOOST][T045][docs roi37]")
	QUIT
	;
T046
	NEW CONF,STATE,OUT,ERR,ID,DATA,SLICE
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO INIT^MIOOS(.CONF)
	SET STATE("principal")=$GET(CONF("mioos","bootstrapAuth","admin","username"),"admin")
	SET STATE("roles")=$GET(CONF("mioos","bootstrapAuth","admin","roles"),"admin")
	SET DATA=$TRANSLATE($JUSTIFY("",12000)," ","L")_$CHAR(10)_$TRANSLATE($JUSTIFY("",12000)," ","M")
	DO OK^MIOTASSERT($$WRITE^MIOOSFS(.STATE,$$HOMEID^MIOOSFS(),"large.log",DATA,"text/plain",.OUT,.ERR),"[MIOOST][T046][write]")
	SET ID=$GET(OUT("id"))
	KILL OUT,ERR
	DO OK^MIOTASSERT($$READWIN^MIOOSFS(.STATE,ID,0,128,.OUT,.ERR),"[MIOOST][T046][read window]")
	DO EQ^MIOTASSERT($GET(OUT("encoding")),"text","[MIOOST][T046][encoding]")
	DO EQ^MIOTASSERT(+$GET(OUT("nextOffset")),128,"[MIOOST][T046][next offset]")
	DO EQ^MIOTASSERT(+$GET(OUT("truncated")),1,"[MIOOST][T046][truncated]")
	DO EQ^MIOTASSERT($GET(OUT("content")),$TRANSLATE($JUSTIFY("",128)," ","L"),"[MIOOST][T046][content]")
	KILL OUT,ERR
	DO OK^MIOTASSERT($$READWIN^MIOOSFS(.STATE,ID,11990,40,.OUT,.ERR),"[MIOOST][T046][cross newline]")
	SET SLICE=$TRANSLATE($JUSTIFY("",10)," ","L")_$CHAR(10)_$TRANSLATE($JUSTIFY("",29)," ","M")
	DO EQ^MIOTASSERT($GET(OUT("content")),SLICE,"[MIOOST][T046][cross content]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSWS.m","fs.read.range"),"[MIOOST][T046][ws read range]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","fs.read.range"),"[MIOOST][T046][explorer read range]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 38 — streamed blob delivery and windowed text preview"),"[MIOOST][T046][llm roi38]")
	DO OK^MIOTASSERT($$FILEHAS("docs/mioos/README.md","ROI 38 — streamed blob delivery and windowed text preview"),"[MIOOST][T046][docs roi38]")
	QUIT
	;
	;
T047
	NEW CONF,REQ,CTX,STATE,BOOT,ERR
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO INIT^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T047][load]")
	DO BOOTARY^MIOOSST(.STATE,.CONF,.BOOT)
	DO EQ^MIOTASSERT($GET(BOOT("desktop","performance","transferPersistence")),"localstorage-resumable-transfer-list","[MIOOST][T047][boot transfer persistence]")
	DO EQ^MIOTASSERT($GET(BOOT("desktop","performance","mediaStreamStrategy")),"range-kickstart-http-blob-partial-window","[MIOOST][T047][boot media strategy]")
	DO EQ^MIOTASSERT($GET(BOOT("vfs","transferPersistence")),"localstorage-resumable-transfer-list","[MIOOST][T047][boot vfs transfer persistence]")
	DO EQ^MIOTASSERT(+$GET(BOOT("vfs","mediaInitialBytes")),860000,"[MIOOST][T047][boot media bytes]")
	DO EQ^MIOTASSERT(+$GET(BOOT("vfs","mediaWarmupBytes")),65536,"[MIOOST][T047][boot media warmup bytes]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","transferStorageKey"),"[MIOOST][T047][core transfer storage key]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","recoverPersistedUploadTransfer"),"[MIOOST][T047][recover upload]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","autoPauseTransfersByReason"),"[MIOOST][T047][auto pause method]")
	QUIT
	;
	;
T048
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSAPI.m","STREAM=""media"""),"[MIOOST][T048][blob stream query]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSAPI.m","ISMEDIAMIME(MIME)"),"[MIOOST][T048][blob media helper]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSAPI.m","mediaWarmupBytes"),"[MIOOST][T048][media warmup config]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSAPI.m","IF RE>SIZE SET RE=SIZE-1"),"[MIOOST][T048][media partial clamp]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","stream: 'media'"),"[MIOOST][T048][explorer media stream]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 39 — persistent transfer recovery and media-first streaming"),"[MIOOST][T048][llm roi39]")
	DO OK^MIOTASSERT($$FILEHAS("docs/mioos/README.md","ROI 39 — persistent transfer recovery and media-first streaming"),"[MIOOST][T048][docs roi39]")
	QUIT
	;
	;
T049
	NEW CONF,REQ,CTX,STATE,BOOT,ERR
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO INIT^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T049][load]")
	DO BOOTARY^MIOOSST(.STATE,.CONF,.BOOT)
	DO EQ^MIOTASSERT(+$GET(BOOT("vfs","uploadChunkBytes")),860000,"[MIOOST][T049][upload chunk bytes]")
	DO EQ^MIOTASSERT(+$GET(BOOT("vfs","uploadConcurrency")),3,"[MIOOST][T049][upload concurrency]")
	DO EQ^MIOTASSERT(+$GET(BOOT("vfs","httpChunkBytes")),860000,"[MIOOST][T049][http chunk bytes]")
	DO EQ^MIOTASSERT(+$GET(BOOT("vfs","chunkSize")),860000,"[MIOOST][T049][chunk size]")
	DO EQ^MIOTASSERT(+$GET(BOOT("vfs","mediaInitialBytes")),860000,"[MIOOST][T049][media initial bytes]")
	DO EQ^MIOTASSERT(+$GET(BOOT("vfs","mediaWarmupBytes")),65536,"[MIOOST][T049][media warmup bytes]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","pauseForDisconnect"),"[MIOOST][T049][disconnect pause]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","retryChunkLater"),"[MIOOST][T049][chunk retry helper]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","xhr.timeout = uploadTimeoutConfig(self).uploadChunkTimeoutMs"),"[MIOOST][T049][chunk timeout]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","reconcileCommitFailure"),"[MIOOST][T049][commit reconcile]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSAPI.m","IF +$GET(ISMEDIA)=1,SENDCH>65536 SET SENDCH=65536"),"[MIOOST][T049][media send cap]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","onPause: function () { return pauseUpload"),"[MIOOST][T049][resume pause control]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","playsinline"),"[MIOOST][T049][video playsinline]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","preload=""metadata"""),"[MIOOST][T049][video preload metadata]")
	QUIT
	;
	;