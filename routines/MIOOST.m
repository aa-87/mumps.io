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
	DO T028
	DO T029
	DO T030
	DO T031
	DO T032
	DO T033
	DO T034
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
	DO T050
	DO T051
	DO T052
	DO T053
	DO T054
	DO T055
	DO T056
	DO T057
	DO T058
	DO T060
	DO T061
	DO T062
	DO T065
	DO T066
	DO T067
	DO T068
	DO T069
	DO T070
	DO T071
	DO T072
	DO T073
	DO T074
	DO T075
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
		KILL EP DO AMATCH("[MIOOST][T001][fs setmeta]","POST","/api/mioos/fs/setmeta",1,"FSSETMETA^MIOOSAPI","/api/mioos/fs/setmeta",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][theme load]","POST","/api/mioos/theme/load",1,"THEMELOAD^MIOOSAPI","/api/mioos/theme/load",.EP)
	KILL EP DO AMATCH("[MIOOST][T001][theme save]","POST","/api/mioos/theme/save",1,"THEMESAVE^MIOOSAPI","/api/mioos/theme/save",.EP)
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
	DO EQ^MIOTASSERT($GET(OBJ("apps",1,"key")),"home","[MIOOST][T002][home app]")
	DO EQ^MIOTASSERT($GET(OBJ("windows",1,"appKey")),"home","[MIOOST][T002][home window]")
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
	DO EQ^MIOTASSERT($GET(OBJ("desktop","themeKey")),"luna-blue","[MIOOST][T002][theme key]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","themeMode")),"light","[MIOOST][T002][theme mode]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","windowing","chrome")),"reusable-shell-chrome","[MIOOST][T002][window chrome]")
	DO EQ^MIOTASSERT(+$GET(OBJ("desktop","windowing","titlebarHeight")),40,"[MIOOST][T002][titlebar height]")
	DO EQ^MIOTASSERT(+$GET(OBJ("desktop","windowing","windowMenuEnabled")),1,"[MIOOST][T002][window menu enabled]")
	DO EQ^MIOTASSERT(+$GET(OBJ("desktop","windowing","snapThreshold")),28,"[MIOOST][T002][snap threshold]")
	DO EQ^MIOTASSERT(+$GET(OBJ("windows",1,"resizable")),1,"[MIOOST][T002][window resizable]")
	DO EQ^MIOTASSERT($GET(OBJ("windows",1,"kind")),"explorer","[MIOOST][T002][window kind]")
	DO EQ^MIOTASSERT($GET(OBJ("windows",1,"workspaceKey")),"workspace-main","[MIOOST][T002][workspace key]")
	DO EQ^MIOTASSERT(+$GET(OBJ("desktop","workspaces","enabled")),0,"[MIOOST][T002][workspaces disabled]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","workspaces","model")),"single-desktop","[MIOOST][T002][single desktop model]")
	QUIT
	;
T003
		NEW CONF,REQ,CTX,STATE,ERR,DATA
		DO RESET
		DO CONFDEF^MIOOS(.CONF)
		DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T003][load]")
		DO DESKCTX^MIOOSUI(.STATE,.CONF,.DATA)
		DO EQ^MIOTASSERT($GET(DATA("page","title")),"MIOOS Desktop","[MIOOST][T003][page title]")
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-classic-contextmenu"),"[MIOOST][T003][folder context menu]")
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","openFolderPropertiesWindow(win.id"),"[MIOOST][T003][folder properties launch]")
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","taskbarPrimaryGroups()"),"[MIOOST][T003][grouped taskbar ui]")
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-classic-explorer"),"[MIOOST][T003][classic explorer shell]")
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","clockDateText"),"[MIOOST][T003][taskbar date clock]")
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","Notifications"),"[MIOOST][T003][notifications tray label]")
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","closeTrayPanel()"),"[MIOOST][T003][tray close action]")
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-classic-transfers"),"[MIOOST][T003][classic transfers shell]")
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-classic-customize"),"[MIOOST][T003][classic customize shell]")
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-classic-properties"),"[MIOOST][T003][classic properties shell]")
		DO EQ^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","win.appKey === 'diagnostics'"),0,"[MIOOST][T003][diagnostics surface removed]")
		DO EQ^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","win.appKey === 'security-center'"),0,"[MIOOST][T003][security surface removed]")
		DO EQ^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","win.appKey === 'debug-center'"),0,"[MIOOST][T003][debug surface removed]")
		DO EQ^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","win.appKey === 'app-catalog'"),0,"[MIOOST][T003][catalog surface removed]")
		DO EQ^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","win.appKey === 'control-panel'"),0,"[MIOOST][T003][control panel removed]")
		DO EQ^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","/public/mioos/7.scoped.css"),0,"[MIOOST][T003][7css removed]")
		DO EQ^MIOTASSERT($$FILEHAS("templates/layouts/mioos_shell.html","/public/mioos/mioos_reset.css"),0,"[MIOOST][T003][reset css consolidated]")
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
	DO EQ^MIOTASSERT($GET(OBJ("apps",1,"key")),"home","[MIOOST][T006][localized app key]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","performance","clientModel")),"thin-vue-umd","[MIOOST][T006][perf model]")
	QUIT
	;
T007
	DO OK^MIOTASSERT($$FILEOK("mioos_llm.md"),"[MIOOST][T007][llm doc]")
	DO OK^MIOTASSERT($$FILEOK("docs/mioos/README.md"),"[MIOOST][T007][readme]")
	DO OK^MIOTASSERT($$FILEOK("docs/mioos/User_Guide.md"),"[MIOOST][T007][user guide]")
	DO OK^MIOTASSERT($$FILEOK("docs/mioos/Internal_Doc.md"),"[MIOOST][T007][internal doc]")
	DO OK^MIOTASSERT($$FILEOK("docs/mioos/HIPAA.md"),"[MIOOST][T007][hipaa doc]")
	DO OK^MIOTASSERT($$FILEOK("docs/mioos/Architecture_Overview.md"),"[MIOOST][T007][architecture doc]")
	DO OK^MIOTASSERT($$FILEOK("docs/mioos/Theme_System.md"),"[MIOOST][T007][theme system doc]")
	DO OK^MIOTASSERT($$FILEOK("docs/mioos/VFS_Metadata_Model.md"),"[MIOOST][T007][vfs metadata doc]")
	DO OK^MIOTASSERT($$FILEOK("docs/mioos/Drag_Drop_Rules.md"),"[MIOOST][T007][drag drop doc]")
	DO OK^MIOTASSERT($$FILEOK("docs/mioos/Transfer_Manager.md"),"[MIOOST][T007][transfer doc]")
	DO OK^MIOTASSERT($$FILEOK("docs/mioos/Migration_Notes.md"),"[MIOOST][T007][migration doc]")
	DO OK^MIOTASSERT($$FILEHAS("templates/layouts/mioos_shell.html","/public/mioos/app/mioos_core.js"),"[MIOOST][T007][core script]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","changeLocale($event.target.value)"),"[MIOOST][T007][locale switch]")
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
	DO EQ^MIOTASSERT($$HOMEID^MIOOSFS()'="root",1,"[MIOOST][T011][home id]")
	SET ROOT="/Home"
	DO OK^MIOTASSERT($$LIST^MIOOSFS(.STATE,ROOT,.OUT,.ERR),"[MIOOST][T011][list root]")
	DO EQ^MIOTASSERT(+$GET(OUT("count"))>0,1,"[MIOOST][T011][root entries]")
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
	KILL OUT DO OK^MIOTASSERT($$MOVE^MIOOSFS(.STATE,ID,"/Home",.OUT,.ERR),"[MIOOST][T011][move]")
	DO EQ^MIOTASSERT($GET(OUT("parentId"))=$$HOMEID^MIOOSFS(),1,"[MIOOST][T011][move parent]")
	KILL OUT DO OK^MIOTASSERT($$DELETE^MIOOSFS(.STATE,ID,.OUT,.ERR),"[MIOOST][T011][delete file]")
	DO EQ^MIOTASSERT(+$GET(OUT("deleted")),1,"[MIOOST][T011][delete flag]")
	SET PAY="{""event"":""desktop.command"",""requestId"":""fs-1"",""command"":""fs.list"",""parent"":""/Home""}"
	DO OK^MIOTASSERT($$COMMANDJSON^MIOOSWS(.CONF,.REQ,.CTX,.STATE,PAY,.JSON,.ERR),"[MIOOST][T011][ws fs list]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T011][ws fs decode]")
	DO EQ^MIOTASSERT($GET(OBJ("event")),"desktop.result","[MIOOST][T011][ws event]")
	DO EQ^MIOTASSERT($GET(OBJ("command")),"fs.list","[MIOOST][T011][ws command]")
	DO EQ^MIOTASSERT(+$GET(OBJ("vfs","count"))>0,1,"[MIOOST][T011][ws parent target]")
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
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","normalizeUploadEntries"),"[MIOOST][T014][multi upload normalizer]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","serverReadyForCommit"),"[MIOOST][T014][commit reconcile status]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","commitStarted"),"[MIOOST][T014][upload commit guard]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","missing_chunk"),"[MIOOST][T014][upload missing chunk reconcile]")
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
		DO EQ^MIOTASSERT($GET(OBJ("apps",4,"key")),"customize","[MIOOST][T015][customize app]")
		DO EQ^MIOTASSERT($GET(OBJ("windows",4,"appKey")),"customize","[MIOOST][T015][customize window]")
		DO EQ^MIOTASSERT($GET(OBJ("windows",5,"appKey")),"folder-properties","[MIOOST][T015][folder properties window]")
		QUIT
		;
T016
		DO EQ^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","https://unpkg.com/7.css/dist/7.scoped.css"),0,"[MIOOST][T016][remote 7css removed]")
		DO EQ^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","/public/mioos/7.scoped.css"),0,"[MIOOST][T016][local 7css removed]")
		DO EQ^MIOTASSERT($$FILEHAS("templates/layouts/mioos_shell.html","/public/mioos/mioos_reset.css"),0,"[MIOOST][T016][reset css consolidated]")
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css","mioos-taskbar--workspace"),"[MIOOST][T016][taskbar css]")
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css","mioos-folder-context-menu"),"[MIOOST][T016][folder menu css]")
		QUIT
		;
T017
	NEW CONF,REQ,CTX,STATE,ERR,JSON,OBJ
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T017][load]")
	SET JSON=$$BOOTJSON^MIOOSST(.STATE,.CONF)
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T017][decode]")
	DO EQ^MIOTASSERT($GET(OBJ("apps",3,"key")),"transfers","[MIOOST][T017][transfers app]")
	DO EQ^MIOTASSERT($GET(OBJ("windows",3,"appKey")),"transfers","[MIOOST][T017][transfers window]")
	DO EQ^MIOTASSERT(+$GET(OBJ("windows",3,"transferCenterEnabled")),1,"[MIOOST][T017][transfer enabled]")
	QUIT
	;
T018
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-classic-transfers"),"[MIOOST][T018][transfer window token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","openTransfersWindow()"),"[MIOOST][T018][transfer launcher]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-classic-explorer"),"[MIOOST][T018][classic explorer shell]")
	DO EQ^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","File and Folder Tasks"),0,"[MIOOST][T018][explorer tasks removed]")
	DO EQ^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-explorer-menubar"),0,"[MIOOST][T018][explorer menubar removed]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","registerTransfer"),"[MIOOST][T018][register transfer]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","openTransfersWindow"),"[MIOOST][T018][open transfers]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","transferId"),"[MIOOST][T018][explorer transfer hookup]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css",".mioos-classic-transfercard"),"[MIOOST][T018][transfers css]")
	DO EQ^MIOTASSERT($$FILEHAS("public/mioos/mioos.css",".mioos-explorer-taskpane"),0,"[MIOOST][T018][explorer taskpane removed]")
	DO EQ^MIOTASSERT($$FILEHAS("public/mioos/mioos.css",".mioos-explorer-menubar"),0,"[MIOOST][T018][explorer menubar css removed]")
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
	DO EQ^MIOTASSERT($GET(OBJ("apps",2,"iconLeft")),144,"[MIOOST][T019][terminal icon left]")
	QUIT
	;
T020
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-context-menu"),"[MIOOST][T020][context menu token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","openDesktopContextMenu($event)"),"[MIOOST][T020][desktop menu handler]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","openDesktopIconContextMenu(entry, $event)"),"[MIOOST][T020][icon menu handler]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","beginDesktopIconDrag"),"[MIOOST][T020][icon drag method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","desktopIconClass: function"),"[MIOOST][T020][icon class method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","handleGlobalMouseMove: function"),"[MIOOST][T020][global drag move method]")
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
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-classic-transferfacts"),"[MIOOST][T026][transfer summary]")
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-classic-progress"),"[MIOOST][T026][transfer progress]")
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","Retry"),"[MIOOST][T026][transfer retry ui]")
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","canPauseTransfer(item)"),"[MIOOST][T026][transfer pause ui]")
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","canResumeTransfer(item)"),"[MIOOST][T026][transfer resume ui]")
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","canCancelTransfer(item)"),"[MIOOST][T026][transfer cancel ui]")
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css","mioos-classic-transfercard"),"[MIOOST][T026][transfer css]")
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css","mioos-classic-transferrow.is-success"),"[MIOOST][T026][transfer status colors]")
		QUIT
		;
T027
		NEW CONF,REQ,CTX,STATE,ERR,JSON,OBJ
		DO RESET
		DO CONFDEF^MIOOS(.CONF)
		DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T027][load]")
		SET JSON=$$BOOTJSON^MIOOSST(.STATE,.CONF)
		DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T027][decode]")
		DO EQ^MIOTASSERT(+$GET(OBJ("desktop","moduleSystem","enabled")),0,"[MIOOST][T027][module system disabled]")
		DO EQ^MIOTASSERT(+$GET(OBJ("desktop","moduleSystem","moduleCount")),0,"[MIOOST][T027][module count zero]")
		DO EQ^MIOTASSERT($GET(OBJ("apps",1,"key")),"home","[MIOOST][T027][home retained]")
		QUIT
		;
T028
	DO EQ^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-module-catalog-window=""1"""),0,"[MIOOST][T028][catalog token removed]")
	DO EQ^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-module-window=""1"""),0,"[MIOOST][T028][module window token removed]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","refreshModuleCatalog"),"[MIOOST][T028][refresh catalog]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","openModuleEntry"),"[MIOOST][T028][open module entry]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSWS.m","module.catalog"),"[MIOOST][T028][ws module catalog]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css",".mioos-module-catalog-shell"),"[MIOOST][T028][module catalog css]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 23 — Module catalog and built-in module host"),"[MIOOST][T028][llm roi23]")
	QUIT
	;
T029
		NEW CONF,STATE,REQ,CTX,ERR,IN,OUT,HOME
		DO RESET
		DO CONFDEF^MIOOS(.CONF)
		DO INIT^MIOOS(.CONF)
		DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T029][load]")
		SET HOME=$$HOMEID^MIOOSFS()
		KILL IN,OUT,ERR
		SET IN("attributes","shared")=1
		SET IN("sharing","scope")="everyone"
		SET IN("attributes","readOnly")=1
		DO OK^MIOTASSERT($$SETMETA^MIOOSFS(.STATE,HOME,.IN,.OUT,.ERR),"[MIOOST][T029][setmeta]")
		DO EQ^MIOTASSERT(+$GET(^MIO("MIOOS","FS","META",HOME,"shared")),1,"[MIOOST][T029][shared flag]")
		DO EQ^MIOTASSERT($GET(^MIO("MIOOS","FS","META",HOME,"shareScope")),"everyone","[MIOOST][T029][share scope]")
		DO EQ^MIOTASSERT(+$GET(^MIO("MIOOS","FS","META",HOME,"readOnly")),1,"[MIOOST][T029][read only flag]")
		QUIT
		;
T030
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","win.appKey === 'folder-properties'"),"[MIOOST][T030][folder properties surface]")
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","Customize this folder"),"[MIOOST][T030][customize folder ui]")
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","Upload background image"),"[MIOOST][T030][folder background upload ui]")
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","Upload folder icon"),"[MIOOST][T030][folder icon upload ui]")
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","saveFolderPropertiesWindow"),"[MIOOST][T030][save properties method]")
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","uploadFolderCustomizeAsset"),"[MIOOST][T030][folder customize asset upload]")
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","responsePayload.id"),"[MIOOST][T030][wallpaper upload id response]")
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","fs.setmeta"),"[MIOOST][T030][setmeta client command]")
		DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSFS.m","METAFIELD(ID,""readOnly"")"),"[MIOOST][T030][readonly backend gate]")
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
	DO EQ^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-security-session-admin=""1"""),0,"[MIOOST][T032][session admin token removed]")
	DO EQ^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-security-account-admin=""1"""),0,"[MIOOST][T032][account admin token removed]")
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
	DO EQ^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-security-password-posture=""1"""),0,"[MIOOST][T034][password posture token removed]")
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
		NEW CONF,REQ,CTX,STATE,BOOT,ERR
		DO RESET
		DO CONFDEF^MIOOS(.CONF)
		DO INIT^MIOOS(.CONF)
		DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T035][load]")
		DO BOOTARY^MIOOSST(.STATE,.CONF,.BOOT)
		DO EQ^MIOTASSERT(+$GET(BOOT("desktop","moduleSystem","enabled")),0,"[MIOOST][T035][modules disabled]")
		DO EQ^MIOTASSERT(+$GET(BOOT("desktop","debugCenter","enabled")),0,"[MIOOST][T035][debug disabled]")
		DO EQ^MIOTASSERT(+$GET(BOOT("desktop","moduleSystem","appCatalogEnabled")),0,"[MIOOST][T035][catalog disabled]")
		QUIT
		;
T036
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","taskbarGroups"),"[MIOOST][T036][taskbar groups]")
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","taskbarOverflowGroups"),"[MIOOST][T036][taskbar overflow]")
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_wm.js","application/x-mioos-item"),"[MIOOST][T036][drag payload]")
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_wm.js","fs.copy"),"[MIOOST][T036][copy on ctrl drag]")
		QUIT
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
	DO EQ^MIOTASSERT(+$GET(OBJ("vfs","chunkSize")),131072,"[MIOOST][T041][vfs chunk size]")
	DO EQ^MIOTASSERT(+$GET(OBJ("vfs","httpChunkBytes")),131072,"[MIOOST][T041][http chunk bytes]")
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
	DO EQ^MIOTASSERT(+$GET(BOOT("vfs","mediaInitialBytes")),131072,"[MIOOST][T047][boot media bytes]")
	DO EQ^MIOTASSERT(+$GET(BOOT("vfs","mediaWarmupBytes")),131072,"[MIOOST][T047][boot media warmup bytes]")
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
	DO EQ^MIOTASSERT(+$GET(BOOT("vfs","httpChunkBytes")),131072,"[MIOOST][T049][http chunk bytes]")
	DO EQ^MIOTASSERT(+$GET(BOOT("vfs","chunkSize")),131072,"[MIOOST][T049][chunk size]")
	DO EQ^MIOTASSERT(+$GET(BOOT("vfs","mediaInitialBytes")),131072,"[MIOOST][T049][media initial bytes]")
	DO EQ^MIOTASSERT(+$GET(BOOT("vfs","mediaWarmupBytes")),131072,"[MIOOST][T049][media warmup bytes]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","pauseForDisconnect"),"[MIOOST][T049][disconnect pause]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","retryChunkLater"),"[MIOOST][T049][chunk retry helper]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","xhr.timeout = uploadTimeoutConfig(self).uploadChunkTimeoutMs"),"[MIOOST][T049][chunk timeout]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","reconcileCommitFailure"),"[MIOOST][T049][commit reconcile]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSAPI.m","IF +$GET(ISMEDIA)=1,SENDCH>131072 SET SENDCH=131072"),"[MIOOST][T049][media send cap]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","onPause: function () { return pauseUpload"),"[MIOOST][T049][resume pause control]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","playsinline"),"[MIOOST][T049][video playsinline]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","preload=""metadata"""),"[MIOOST][T049][video preload metadata]")
	QUIT
	;
	;
T050
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_wm.js","createWindowForApp"),"[MIOOST][T050][dynamic window factory]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_wm.js","function nextWindowId(vm, prefix)"),"[MIOOST][T050][wm dynamic window ids]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_wm.js","centerAuthWindow"),"[MIOOST][T050][wm auth bridge]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","centerAuthWindow"),"[MIOOST][T050][auth window centering]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css","Wave 1 shell foundation reset"),"[MIOOST][T050][shell foundation css]")
	QUIT
	;
	;
T051
		NEW CONF,REQ,CTX,STATE,BOOT,ERR
		DO RESET
		DO CONFDEF^MIOOS(.CONF)
		DO INIT^MIOOS(.CONF)
		DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T051][load]")
		DO BOOTARY^MIOOSST(.STATE,.CONF,.BOOT)
		DO EQ^MIOTASSERT(+$GET(BOOT("desktop","themeSystem","version")),4,"[MIOOST][T051][theme system version]")
		DO EQ^MIOTASSERT($GET(BOOT("desktop","themeSystem","editor")),"customize","[MIOOST][T051][theme editor]")
		DO EQ^MIOTASSERT($GET(BOOT("desktop","themeSystem","persistence")),"globals-profile-service-with-localstorage-fallback","[MIOOST][T051][theme persistence]")
		DO EQ^MIOTASSERT(+$GET(BOOT("desktop","shellSurfaces","customize")),1,"[MIOOST][T051][customize surface]")
		DO EQ^MIOTASSERT(+$GET(BOOT("desktop","shellSurfaces","folderProperties")),1,"[MIOOST][T051][folder properties surface]")
		DO EQ^MIOTASSERT($GET(BOOT("routes","themeLoad")),"/api/mioos/theme/load","[MIOOST][T051][theme load route]")
		DO EQ^MIOTASSERT($GET(BOOT("routes","themeSave")),"/api/mioos/theme/save","[MIOOST][T051][theme save route]")
		DO EQ^MIOTASSERT($GET(BOOT("vfs","desktopId"))'="",1,"[MIOOST][T051][desktop id boot]")
		DO EQ^MIOTASSERT($GET(BOOT("desktop","themeSystem","windowGrammar")),"7css-primary","[MIOOST][T051][theme grammar]")
		DO EQ^MIOTASSERT($GET(BOOT("desktop","themeSystem","controlAugment")),"basecoat-augment","[MIOOST][T051][theme control augment]")
		DO EQ^MIOTASSERT(+$DATA(BOOT("desktop","themeSystem","presetFamilies",4,"key"))>0,1,"[MIOOST][T051][preset families boot]")
		DO OK^MIOTASSERT($$FILEHAS("templates/layouts/mioos_shell.html","/public/mioos/7.scoped.css"),"[MIOOST][T051][local 7css layout]")
		DO EQ^MIOTASSERT($$FILEHAS("templates/layouts/mioos_shell.html","/public/mioos/mioos_shell_overhaul.css"),0,"[MIOOST][T051][overhaul css consolidated]")
		DO OK^MIOTASSERT($$FILEHAS("templates/layouts/mioos_shell.html","basecoat-css@0.3.2"),"[MIOOST][T051][basecoat augment layout]")
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","themeStudioPresetFamilies"),"[MIOOST][T051][preset family method]")
		DO EQ^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","if (!this.requiresSignin) this.themeStudioLoadRemote"),0,"[MIOOST][T051][no pre-signin theme fetch]")
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","themeInlineStyle"),"[MIOOST][T051][miotpl theme inline]")
		DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSUI.m","THEMEINL"),"[MIOOST][T051][server theme inline]")
		DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSST.m","activeThemeProfile"),"[MIOOST][T051][boot active theme profile]")
		DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSTHEME.m","ACTIVE(STATE,OUT)"),"[MIOOST][T051][theme active helper]")
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","desktop.activeThemeProfile"),"[MIOOST][T051][client boot theme profile]")
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","themeStudioLoadRemote"),"[MIOOST][T051][theme load method]")
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","themeStudioSaveRemote"),"[MIOOST][T051][theme save method]")
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","Desktop Preview"),"[MIOOST][T051][desktop preview ui]")
		DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","Preset Families"),"[MIOOST][T051][preset families ui]")
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","setShellTheme"),"[MIOOST][T051][set shell theme]")
		QUIT
		;
T052
	NEW CONF,REQ,CTX,STATE,BOOT,ERR
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO INIT^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T052][load]")
	DO BOOTARY^MIOOSST(.STATE,.CONF,.BOOT)
	DO EQ^MIOTASSERT($GET(BOOT("desktop","notifications","model")),"tray-panel","[MIOOST][T052][notification model]")
	DO EQ^MIOTASSERT(+$GET(BOOT("desktop","notifications","stackLimit")),6,"[MIOOST][T052][notification stack]")
	DO EQ^MIOTASSERT($GET(BOOT("desktop","dialogs","model")),"shell-standard","[MIOOST][T052][dialog model]")
	DO EQ^MIOTASSERT(+$GET(BOOT("desktop","shellSurfaces","notifications")),1,"[MIOOST][T052][notifications surface]")
	DO EQ^MIOTASSERT(+$GET(BOOT("desktop","shellSurfaces","dialogs")),1,"[MIOOST][T052][dialogs surface]")
	DO EQ^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-notification-stack"),0,"[MIOOST][T052][legacy notification stack removed]")
	DO EQ^MIOTASSERT($$FILEHAS("public/mioos/mioos.css",".mioos-notification-stack"),0,"[MIOOST][T052][legacy notification css removed]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-shell-dialog"),"[MIOOST][T052][shell dialog ui]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-tray-panel"),"[MIOOST][T052][tray panel ui]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","pushNotification"),"[MIOOST][T052][push notification method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","inputDialog"),"[MIOOST][T052][input dialog method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","this.inputDialog"),"[MIOOST][T052][explorer shell input]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","this.confirmDialog"),"[MIOOST][T052][explorer shell confirm]")
	DO EQ^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html"," win7"),0,"[MIOOST][T052][no win7 surface token]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 53 — shell-standard dialogs, notifications, and built-in app cleanup"),"[MIOOST][T052][llm roi53]")
	DO OK^MIOTASSERT($$FILEHAS("docs/mioos/README.md","ROI 53 — shell-standard dialogs, notifications, and built-in app cleanup"),"[MIOOST][T052][docs roi53]")
	QUIT
	;
	;
T053
		NEW CONF,REQ,CTX,STATE,BOOT,ERR
		DO RESET
		DO CONFDEF^MIOOS(.CONF)
		DO INIT^MIOOS(.CONF)
		DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T053][load]")
		DO BOOTARY^MIOOSST(.STATE,.CONF,.BOOT)
		DO EQ^MIOTASSERT(+$GET(BOOT("desktop","shellSurfaces","moduleWindows")),0,"[MIOOST][T053][module windows removed]")
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","openFolderPropertiesWindow"),"[MIOOST][T053][folder properties method]")
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","activateTaskGroup"),"[MIOOST][T053][activate task group]")
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","copyTextToClipboard"),"[MIOOST][T053][clipboard helper]")
		QUIT
		;
T054
	NEW CONF,REQ,CTX,STATE,BOOT,ERR,OUT,JSON,OBJ,PAY,UP,STATUS
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	DO INIT^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T054][load]")
	DO BOOTARY^MIOOSST(.STATE,.CONF,.BOOT)
	DO EQ^MIOTASSERT(+$GET(BOOT("websocket","maxSocketsPerSession")),+$GET(CONF("mioos","websocket","maxSocketsPerSession")),"[MIOOST][T054][boot max sockets]")
	DO EQ^MIOTASSERT(+$GET(BOOT("websocket","uploadBatchSize")),+$GET(CONF("mioos","upload","batchSize")),"[MIOOST][T054][boot batch size]")
	DO EQ^MIOTASSERT(+$GET(BOOT("vfs","uploadMaxInflightChunks")),+$GET(CONF("mioos","upload","maxInflightChunks")),"[MIOOST][T054][boot inflight chunks]")
	SET JSON=$$HELLOJSON^MIOOSWS(.STATE,.CONF)
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T054][hello decode]")
	DO EQ^MIOTASSERT(+$GET(OBJ("socketPool","maxSocketsPerSession")),+$GET(CONF("mioos","websocket","maxSocketsPerSession")),"[MIOOST][T054][hello max sockets]")
	DO EQ^MIOTASSERT(+$GET(OBJ("socketPool","uploadBatchSize")),+$GET(CONF("mioos","upload","batchSize")),"[MIOOST][T054][hello batch size]")
	KILL OUT DO OK^MIOTASSERT($$BEGIN^MIOOSFSUP(.STATE,.CONF,"root","batch.txt","text/plain",8,"binary",.OUT,.ERR),"[MIOOST][T054][begin]")
	SET UP=$GET(OUT("uploadId"))
	SET PAY="{""event"":""desktop.command"",""requestId"":""batch-1"",""command"":""fs.upload.batch"",""uploadId"":"""_UP_""",""socketId"":""core-1"",""socketRole"":""core"",""socketOrdinal"":1,""chunks"":[{""index"":1,""data"":""ABCD"",""bytes"":4},{""index"":2,""data"":""EFGH"",""bytes"":4}]}"
	DO OK^MIOTASSERT($$COMMANDJSON^MIOOSWS(.CONF,.REQ,.CTX,.STATE,PAY,.JSON,.ERR),"[MIOOST][T054][batch command]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON($G(JSON),.OBJ,.ERR),"[MIOOST][T054][batch decode]")
	DO EQ^MIOTASSERT($GET(OBJ("command")),"fs.upload.batch","[MIOOST][T054][batch command name]")
	DO EQ^MIOTASSERT(+$GET(OBJ("vfs","batchCount")),2,"[MIOOST][T054][batch count]")
	DO EQ^MIOTASSERT(+$GET(OBJ("vfs","receivedBytes")),8,"[MIOOST][T054][batch received]")
	KILL STATUS DO OK^MIOTASSERT($$STATUS^MIOOSFSUP(.STATE,.CONF,UP,.STATUS,.ERR),"[MIOOST][T054][status]")
	DO EQ^MIOTASSERT(+$GET(STATUS("nextIndex")),3,"[MIOOST][T054][next index]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","fs.upload.batch"),"[MIOOST][T054][explorer batch token]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSWS.m","FSUPBATCH"),"[MIOOST][T054][ws batch handler]")
	DO EQ^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","Server socket registry"),0,"[MIOOST][T054][server socket registry ui removed]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","transportServerSocketRows"),"[MIOOST][T054][server socket rows method]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 55 — websocket batch uploads and socket-pool observability"),"[MIOOST][T054][llm roi55]")
	DO OK^MIOTASSERT($$FILEHAS("docs/mioos/README.md","ROI 55 — websocket batch uploads and socket-pool observability"),"[MIOOST][T054][docs roi55]")
	QUIT
	;
	;
		;
T055
		NEW CONF,REQ,CTX,STATE,BOOT,ERR
		DO RESET
		DO CONFDEF^MIOOS(.CONF)
		DO INIT^MIOOS(.CONF)
		DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T055][load]")
		DO BOOTARY^MIOOSST(.STATE,.CONF,.BOOT)
		DO EQ^MIOTASSERT(+$GET(BOOT("desktop","workspaces","enabled")),0,"[MIOOST][T055][workspaces enabled]")
		DO EQ^MIOTASSERT($GET(BOOT("desktop","workspaces","currentKey")),"workspace-main","[MIOOST][T055][current workspace]")
		DO EQ^MIOTASSERT($GET(BOOT("desktop","workspaces","items",1,"key")),"workspace-main","[MIOOST][T055][single workspace]")
		DO EQ^MIOTASSERT(+$GET(BOOT("desktop","shellSurfaces","workspacePager")),0,"[MIOOST][T055][workspace pager surface]")
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","workspaceEnabled"),"[MIOOST][T055][workspace gate method]")
		DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_wm.js","moveWindowToWorkspace"),"[MIOOST][T055][move workspace method retained]")
		DO EQ^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-workspace-pager"),0,"[MIOOST][T055][workspace pager ui]")
		QUIT
	;
	;
T056
	NEW CONF,REQ,CTX,STATE,ERR,DATA,BOOT,IN,OUT,STATE2,DATA2,STYLE,STYLE2
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	SET CONF("mioos","localAuth","enabled")=1
	SET CONF("mioos","dev","authDisabled")=0
	DO INIT^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T056][load]")
	DO DESKCTX^MIOOSUI(.STATE,.CONF,.DATA)
	SET STYLE=$GET(DATA("themeInlineStyle"))
	DO OK^MIOTASSERT(STYLE["--mioos-accent:","[MIOOST][T056][css accent first paint]")
	DO OK^MIOTASSERT(STYLE["--mioos-bg:","[MIOOST][T056][css bg first paint]")
	DO OK^MIOTASSERT(STYLE["--mioos-window-radius:","[MIOOST][T056][css radius first paint]")
	DO OK^MIOTASSERT($$FILEHAS("templates/layouts/mioos_shell.html","mioosFirstPaintTheme"),"[MIOOST][T056][layout first paint style]")
	DO OK^MIOTASSERT($$FILEHAS("templates/layouts/mioos_shell.html",":root{ {{{themeInlineStyle}}} }"),"[MIOOST][T056][layout root css variables]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-wallpaper-url=""{{wallpaperUrl}}"""),"[MIOOST][T056][page wallpaper data]")
	DO EQ^MIOTASSERT(STYLE["/api/mioos/theme-asset",0,"[MIOOST][T056][no theme asset first paint before auth]")
	DO EQ^MIOTASSERT(STYLE["/api/mioos/fs/blob",0,"[MIOOST][T056][no fs blob first paint before auth]")
	DO EQ^MIOTASSERT($GET(DATA("wallpaperUrl")),"","[MIOOST][T056][wallpaper url empty before auth]")
	DO BOOTARY^MIOOSST(.STATE,.CONF,.BOOT)
	DO EQ^MIOTASSERT($GET(STATE("theme")),$GET(STATE("themeKey")),"[MIOOST][T056][state theme alias]")
	DO EQ^MIOTASSERT($GET(BOOT("desktop","theme")),$GET(STATE("themeKey")),"[MIOOST][T056][boot theme alias]")
	DO EQ^MIOTASSERT($GET(BOOT("desktop","wallpaperUrl")),"","[MIOOST][T056][boot wallpaper url empty before auth]")
	DO EQ^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","applyPersistedThemeStudioProfile();"),0,"[MIOOST][T056][no localstorage theme first paint]")
	DO EQ^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","applyBootThemeDefaults();"),0,"[MIOOST][T056][no js theme first paint]")
	DO EQ^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","if (!this.requiresSignin) this.themeStudioLoadRemote"),0,"[MIOOST][T056][no preauth theme load]")
	KILL STATE,DATA,BOOT,ERR
	SET CONF("mioos","localAuth","enabled")=0
	SET CONF("mioos","dev","authDisabled")=1
	DO INIT^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T056][auth load]")
	KILL IN,OUT,ERR
	SET IN("key")="roi1-saved-theme",IN("activate")=1
	SET IN("profile","presetKey")="ember-panel-dark"
	SET IN("profile","mode")="dark"
	SET IN("profile","density")="compact"
	SET IN("profile","appearance","accent")="#ffb087"
	SET IN("profile","colors","panel")="#20161a"
	SET IN("profile","desktop","wallpaperPreset")="custom-url"
	SET IN("profile","desktop","wallpaperUrl")=$GET(STATE("wallpaperUrl"))
	SET IN("profile","desktop","wallpaperFit")="cover"
	DO OK^MIOTASSERT($$SAVE^MIOOSTHEME(.STATE,.CONF,.IN,.OUT,.ERR),"[MIOOST][T056][save active theme]")
	KILL STATE2,DATA2,BOOT,ERR
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE2,.ERR),"[MIOOST][T056][reload]")
	DO DESKCTX^MIOOSUI(.STATE2,.CONF,.DATA2)
	SET STYLE2=$GET(DATA2("themeInlineStyle"))
	DO EQ^MIOTASSERT($GET(STATE2("theme")),"ember-panel-dark","[MIOOST][T056][persisted theme]")
	DO EQ^MIOTASSERT($GET(STATE2("themeMode")),"dark","[MIOOST][T056][persisted mode]")
	DO EQ^MIOTASSERT($GET(STATE2("density")),"compact","[MIOOST][T056][persisted density]")
	DO OK^MIOTASSERT(STYLE2["#ffb087","[MIOOST][T056][persisted style]")
	QUIT
	;
	;	;
T057
	NEW CONF,REQ,CTX,STATE,BOOT,VIEW,ERR,OUT,DESK,FOUND,I,ID
	DO RESET
	DO CONFDEF^MIOOS(.CONF)
	SET CONF("mioos","localAuth","enabled")=0
	SET CONF("mioos","dev","authDisabled")=1
	DO INIT^MIOOS(.CONF)
	DO OK^MIOTASSERT($$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOOST][T057][load]")
	SET DESK=$$DESKTOPID^MIOOSFS()
	DO EQ^MIOTASSERT($$PATH^MIOOSFS(DESK),"/Home/Desktop","[MIOOST][T057][canonical desktop path]")
	DO BOOTARY^MIOOSST(.STATE,.CONF,.BOOT)
	DO EQ^MIOTASSERT($GET(BOOT("vfs","desktopId")),DESK,"[MIOOST][T057][boot desktop id]")
	DO EQ^MIOTASSERT($GET(BOOT("desktop","canonicalDesktopPath")),"/Home/Desktop","[MIOOST][T057][boot canonical path]")
	DO EQ^MIOTASSERT($GET(BOOT("desktopFolder","id")),DESK,"[MIOOST][T057][boot desktop folder]")
	KILL OUT,ERR DO OK^MIOTASSERT($$WRITE^MIOOSFS(.STATE,DESK,"roi2-note.txt","desktop vfs","text/plain",.OUT,.ERR),"[MIOOST][T057][write desktop]")
	SET ID=$GET(OUT("id"))
	KILL VIEW DO BUILD^MIOOSVM(.STATE,.CONF,.VIEW)
	DO EQ^MIOTASSERT($GET(VIEW("explorer","currentFolderId")),DESK,"[MIOOST][T057][explorer opens desktop]")
	DO EQ^MIOTASSERT($GET(VIEW("desktopFolder","id")),DESK,"[MIOOST][T057][view desktop folder]")
	DO EQ^MIOTASSERT($GET(VIEW("desktopFolder","canonicalPath")),"/Home/Desktop","[MIOOST][T057][view canonical path]")
	SET FOUND=0,I=0 FOR  SET I=$ORDER(VIEW("desktopEntries",I)) QUIT:I'>0  DO
	. IF $GET(VIEW("desktopEntries",I,"name"))="roi2-note.txt" DO
	. . SET FOUND=1
	. . DO EQ^MIOTASSERT($GET(VIEW("desktopEntries",I,"key")),ID,"[MIOOST][T057][desktop key is vfs id]")
	. . DO EQ^MIOTASSERT($GET(VIEW("desktopEntries",I,"source")),"vfs","[MIOOST][T057][desktop source]")
	DO EQ^MIOTASSERT(FOUND,1,"[MIOOST][T057][write appears on desktop]")
	KILL OUT,ERR DO OK^MIOTASSERT($$MKDIR^MIOOSFS(.STATE,DESK,"ROI2Folder",.OUT,.ERR),"[MIOOST][T057][mkdir desktop]")
	KILL VIEW DO BUILD^MIOOSVM(.STATE,.CONF,.VIEW)
	SET FOUND=0,I=0 FOR  SET I=$ORDER(VIEW("desktopEntries",I)) QUIT:I'>0  IF $GET(VIEW("desktopEntries",I,"name"))="ROI2Folder",$GET(VIEW("desktopEntries",I,"kind"))="folder" SET FOUND=1
	DO EQ^MIOTASSERT(FOUND,1,"[MIOOST][T057][folder appears on desktop]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","openDesktopEntry"),"[MIOOST][T057][desktop entry opener]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_shell_ui.js","vm.openDesktopEntry(icon)"),"[MIOOST][T057][desktop icon opener]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSVM.m","DESKTOPVM"),"[MIOOST][T057][vfs desktop vm]")
	QUIT
	;
T058
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_shell_ui.js","mioos-explorer-native"),"[MIOOST][T058][native explorer shell]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_shell_ui.js","role=""menubar"""),"[MIOOST][T058][explorer menubar]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_shell_ui.js","mioos-explorer-nav-pane"),"[MIOOST][T058][navigation pane]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_shell_ui.js","mioos-explorer-listview"),"[MIOOST][T058][details listview]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_shell_ui.js","mioos-explorer-statusbar"),"[MIOOST][T058][status bar]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_shell_ui.js","mioos-explorer-context-menu"),"[MIOOST][T058][explorer context menu]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_shell_ui.js","vm.explorerPromptUpload(window.id)"),"[MIOOST][T058][upload action retained]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_shell_ui.js","vm.explorerDownloadSelected(window.id)"),"[MIOOST][T058][download action retained]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","explorerQuickPlaces"),"[MIOOST][T058][quick places method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","explorerVisibleItems"),"[MIOOST][T058][filtered sorted items]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","explorerSortBy"),"[MIOOST][T058][sortable columns]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","explorerGoBack"),"[MIOOST][T058][history back]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","explorerGoForward"),"[MIOOST][T058][history forward]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","openExplorerContextMenu"),"[MIOOST][T058][context handler]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_explorer.js","explorerPasteIntoWindow"),"[MIOOST][T058][vfs copy paste]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css",".mioos-explorer-native"),"[MIOOST][T058][native explorer css]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css",".mioos-explorer-listview"),"[MIOOST][T058][listview css]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css",".mioos-explorer-context-menu"),"[MIOOST][T058][context css]")
	QUIT
	;
	;	;
T060
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","startMenuAppCatalogItems"),"[MIOOST][T060][start menu app catalog]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","startMenuFilesystemItems"),"[MIOOST][T060][start menu filesystem]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","startMenuFlatItems"),"[MIOOST][T060][start menu long list source]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","startMenuHandleKeydown"),"[MIOOST][T060][start menu keyboard]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","startMenuOpenItem"),"[MIOOST][T060][start menu launcher]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_shell_ui.js","vm.startMenuOpenItem(item)"),"[MIOOST][T060][start menu item click]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_shell_ui.js","vm.startMenuHandleKeydown($event)"),"[MIOOST][T060][start menu key handler]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","Desktop Files"),"[MIOOST][T060][start menu desktop files]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_wm.js","createWindowForApp(app"),"[MIOOST][T060][dynamic start menu window]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css",".mioos-start-entry-vue.is-selected"),"[MIOOST][T060][start menu selection css]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css","--start-menu-max-height"),"[MIOOST][T060][start menu overflow css]")
	QUIT
	;
T061
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","themeStudioOpenSession"),"[MIOOST][T061][customize open session]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","themeStudioCancel"),"[MIOOST][T061][customize cancel method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","themeStudioPersistActiveRemote"),"[MIOOST][T061][customize remote persistence]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","themeStudioServerProfile"),"[MIOOST][T061][customize server profile]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","themeStudioConfigFromServerProfile"),"[MIOOST][T061][customize boot profile mapping]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","themeStudioSetUploadedAsset"),"[MIOOST][T061][customize uploaded asset apply]")
	DO EQ^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","themeStudioUploadFallbackDataUrl"),0,"[MIOOST][T061][no dataurl upload fallback]")
	DO EQ^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","readAsDataURL"),0,"[MIOOST][T061][no dataurl reader]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","themeStudioLoadRemote: function (key)"),"[MIOOST][T061][theme load post method]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","method: 'POST'"),"[MIOOST][T061][theme api post]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_shell_ui.js","vm.themeStudioOpenSession"),"[MIOOST][T061][theme studio session ui]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_shell_ui.js","vm.themeStudioCancel()"),"[MIOOST][T061][theme studio cancel ui]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_shell_ui.js","Upload wallpaper"),"[MIOOST][T061][theme studio wallpaper upload ui]")
	DO EQ^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_shell_ui.js","themeStudioCreateNewTheme"),0,"[MIOOST][T061][no dead theme create button]")
	DO EQ^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_shell_ui.js","themeStudioDeleteCustomTheme"),0,"[MIOOST][T061][no dead theme delete button]")
	QUIT
	;
T062
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSUI.m","$$PROTURL(CSSV,.STATE)"),"[MIOOST][T062][first-paint protected css var filter]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_core.js","sanitizeBootThemeForAuth"),"[MIOOST][T062][client boot theme sanitizer]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOS.m","/api/mioos/table/mutate"),"[MIOOST][T062][table mutate route default]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSAPI.m","TABLEMUTATE"),"[MIOOST][T062][table mutate api]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSTBL.m","bulk.delete"),"[MIOOST][T062][bulk delete backend]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","backendTableToggleSelectAllVisible"),"[MIOOST][T062][select all visible]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","backendTableOpenRowEditor"),"[MIOOST][T062][row crud ui]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","backendTableOpenColumnEditor"),"[MIOOST][T062][column crud ui]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSTBL.m","patient-registration"),"[MIOOST][T062][patient registration dataset]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSTBL.m","ui-elements"),"[MIOOST][T062][ui elements dataset]")
	DO OK^MIOTASSERT($$FILEOK("public/mioos/app/mioos_permissions.js"),"[MIOOST][T062][permissions ui script]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSMOD.m","Patient Registration"),"[MIOOST][T062][patient registration catalogue]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSMOD.m","UI + Form Elements"),"[MIOOST][T062][ui elements catalogue]")
	DO OK^MIOTASSERT($$FILEHAS("docs/mioos/Backend_Table.md","/api/mioos/table/mutate"),"[MIOOST][T062][table docs]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 62"),"[MIOOST][T062][llm notes]")
	QUIT
	;
	;
T065
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_modules.js","mioos-surface-ui-elements"),"[MIOOST][T065][ui elements standalone surface]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_modules.js","mioos-ui-elements-v1"),"[MIOOST][T065][ui elements gallery version]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_modules.js","saveSample"),"[MIOOST][T065][stateful save pattern]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_modules.js","onFilePick"),"[MIOOST][T065][file picker metadata]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_modules.js","alertdialog"),"[MIOOST][T065][confirmation dialog]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_modules.js","role=""dialog"""),"[MIOOST][T065][modal dialog]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSMOD.m","mioos-surface-ui-elements"),"[MIOOST][T065][registry ui elements surface]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSMOD.m","interactive-forms"),"[MIOOST][T065][registry ui feature]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_shell_ui.js","mioos-surface-ui-elements"),"[MIOOST][T065][shell fallback]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_wm.js","mioos-surface-ui-elements"),"[MIOOST][T065][window sizing]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css","ROI 64B UI Modules examples gallery"),"[MIOOST][T065][gallery css]")
	DO OK^MIOTASSERT($$FILEHAS("docs/mioos/ROI_64B_UI_Elements_Gallery.md","mioos-surface-ui-elements"),"[MIOOST][T065][roi64b docs]")
	DO OK^MIOTASSERT($$FILEHAS("examples/mioos_modules/ui_elements/module.json","mioos-surface-ui-elements"),"[MIOOST][T065][example manifest]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 64B"),"[MIOOST][T065][llm roi64b]")
	QUIT
T066
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","mioos-advanced-table-v8"),"[MIOOST][T066][table v7 contract]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","table.query"),"[MIOOST][T066][websocket table query]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","mutateTransport: 'websocket'"),"[MIOOST][T066][http-safe table mutate]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","backendTableBeginActionsResize"),"[MIOOST][T066][actions column resize]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","mioos-table-editor-backdrop"),"[MIOOST][T066][viewport editor]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","mioos-surface-table-showcase"),"[MIOOST][T066][table showcase surface]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","columnGroups: false"),"[MIOOST][T066][column groups off by default]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","density: 'compact'"),"[MIOOST][T066][compact density]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_modules.js","mioos-surface-table-showcase"),"[MIOOST][T066][catalog table showcase routing]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_shell_ui.js","mioos-surface-table-showcase"),"[MIOOST][T066][shell table showcase fallback]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSWS.m","table.query"),"[MIOOST][T066][ws table query command]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","backendTableShowActions"),"[MIOOST][T066][conditional actions column]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSTBL.m","MASSFASTQ"),"[MIOOST][T066][massive fast page materialization]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSTBL.m","readOnly"),"[MIOOST][T066][readonly feature flag]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSAPI.m","table_mutate_failed"),"[MIOOST][T066][mutation json error]")
	DO OK^MIOTASSERT($$FILEHAS("docs/mioos/ROI_64D_Table_Performance_Mutations.md","MUMPS developer contracts"),"[MIOOST][T066][roi64d docs]")
	DO OK^MIOTASSERT($$FILEHAS("examples/mioos_modules/table/module.json","mioos-advanced-table-v8"),"[MIOOST][T066][table manifest contract]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 64D"),"[MIOOST][T066][llm roi64d]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","SET MOD(""tableState"",""dataset"")"),"[MIOOST][T066][mumps table examples]")
	QUIT
	;
	;
T067
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","mioos-advanced-table-v8"),"[MIOOST][T067][table v7 contract]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","mumpsTableSnippet"),"[MIOOST][T067][mumps dataset snippets]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","mioos-table-detail-toggle"),"[MIOOST][T067][details control column]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","columnPickerOpen"),"[MIOOST][T067][modal column picker state]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","backendTableOpenColumnPicker"),"[MIOOST][T067][modal column picker api]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSTBL.m","VALIDATE(STATE,CONF,DATASET,ACTION,IN,ERR)"),"[MIOOST][T067][mumps mutation validation]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSTBL.m","field_too_long"),"[MIOOST][T067][row field max validation]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSAPI.m","OUT(""error"")=""table_mutate_failed"""),"[MIOOST][T067][http mutation deterministic json]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSWS.m","OUT(""error"")=""table_mutate_failed"""),"[MIOOST][T067][ws mutation deterministic json]")
	DO OK^MIOTASSERT($$FILEHAS("examples/mioos_modules/table/README.md","Complete MUMPS-first dataset"),"[MIOOST][T067][examples dataset definition]")
	DO OK^MIOTASSERT($$FILEHAS("docs/mioos/ROI_64E_Table_Mutations_MUMPS_API.md","Mutation execution path"),"[MIOOST][T067][roi64e docs]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 64E table follow-up"),"[MIOOST][T067][llm roi64e]")
	QUIT
	;
T068
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","backendTableBeginDialogDrag"),"[MIOOST][T068][bounded draggable table dialogs]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","backendTableFilterControl"),"[MIOOST][T068][typed filter controls]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","Advanced filters"),"[MIOOST][T068][advanced filter modal]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","column.option.add"),"[MIOOST][T068][add select option mutation]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","rows.export"),"[MIOOST][T068][server side selected csv export]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","mioos-table-loading-line"),"[MIOOST][T068][loading bar indicator]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSTBL.m","FILTERVAL"),"[MIOOST][T068][advanced filter backend]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSTBL.m","column.option.add"),"[MIOOST][T068][option add backend]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSTBL.m","EXPORT(STATE,DATASET,ROOT,IN,OUT)"),"[MIOOST][T068][csv export backend]")
	DO OK^MIOTASSERT($$FILEHAS("docs/mioos/ROI_64I_64K_Table_DataTables_Parity.md","ROI 64J"),"[MIOOST][T068][next roi column reorder design]")
	DO OK^MIOTASSERT($$FILEHAS("docs/mioos/ROI_64I_64K_Table_DataTables_Parity.md","ROI 64K"),"[MIOOST][T068][next roi fixed columns design]")
	QUIT
	;
	;
T069
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","backendTableSaveCell"),"[MIOOST][T069][editable cell save api]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","mioos-table-cell-editor"),"[MIOOST][T069][inline cell editor]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","backendTableAddFilterOption"),"[MIOOST][T069][advanced filter add value]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","Table loading"),"[MIOOST][T069][bar only loading indicator]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSTBL.m","cell.save"),"[MIOOST][T069][cell save mutation]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSTBL.m","VALCELL"),"[MIOOST][T069][cell validation]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSTBL.m","CELLCB"),"[MIOOST][T069][cell callback]")
	DO OK^MIOTASSERT($$FILEHAS("docs/mioos/ROI_64I_Editable_Cells.md","cellCallback"),"[MIOOST][T069][roi64i docs]")
	DO OK^MIOTASSERT($$FILEHAS("examples/mioos_modules/table/module.json","cellEditing"),"[MIOOST][T069][manifest cell editing]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 64I editable cells"),"[MIOOST][T069][llm roi64i]")
	QUIT
	;
	;
T070
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","columnReorder: true"),"[MIOOST][T070][column reorder feature flag]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","backendTableMoveColumn"),"[MIOOST][T070][column reorder ui move]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","column.reorder"),"[MIOOST][T070][column reorder mutation]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","backendTableOpenOptionDialog"),"[MIOOST][T070][mioos add value dialog]")
	DO EQ^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","prompt("),0,"[MIOOST][T070][no native prompt]")
	DO EQ^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","confirm("),0,"[MIOOST][T070][no native confirm]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSTBL.m","VALORDER"),"[MIOOST][T070][column order backend validation]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSTBL.m","REORDER(ROOT,IN,OUT)"),"[MIOOST][T070][column order backend persistence]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSMOD.m","column-reorder"),"[MIOOST][T070][component feature advertises reorder]")
	DO OK^MIOTASSERT($$FILEHAS("examples/mioos_modules/table/module.json","columnReorder"),"[MIOOST][T070][manifest column reorder]")
	DO OK^MIOTASSERT($$FILEHAS("docs/mioos/ROI_64J_Column_Reorder.md","column.reorder"),"[MIOOST][T070][roi64j docs]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 64J column reorder"),"[MIOOST][T070][llm roi64j]")
	QUIT
	;
	;
T071
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","fixedColumns: true"),"[MIOOST][T071][fixed columns feature flag]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","backendTableSetFixedColumns"),"[MIOOST][T071][fixed columns ui mutation]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","backendTableStickyClass"),"[MIOOST][T071][fixed columns sticky class]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","column.fixed"),"[MIOOST][T071][fixed columns mutation]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSTBL.m","VALFIXED"),"[MIOOST][T071][fixed columns backend validation]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSTBL.m","FIXED(ROOT,IN,OUT)"),"[MIOOST][T071][fixed columns persistence]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSMOD.m","fixed-columns"),"[MIOOST][T071][module advertises fixed columns]")
	DO OK^MIOTASSERT($$FILEHAS("examples/mioos_modules/table/module.json","fixedColumns"),"[MIOOST][T071][manifest fixed columns]")
	DO OK^MIOTASSERT($$FILEHAS("docs/mioos/ROI_64K_Fixed_Columns.md","column.fixed"),"[MIOOST][T071][roi64k docs]")
	QUIT
	;
T072
	DO OK^MIOTASSERT($$FILEHAS("docs/mioos/ROI_64L_Hardening_Polish.md","ROI 64L"),"[MIOOST][T072][roi64l docs]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css","ROI 64L hardening"),"[MIOOST][T072][roi64l css marker]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","backendTableCloseTopDialog"),"[MIOOST][T072][escape close top dialog]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","mioos-table-loading-line"),"[MIOOST][T072][bar loading retained]")
	DO EQ^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","vm.backendTableNormalizeFixedColumns"),0,"[MIOOST][T072][no undefined vm apply payload regression]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","this.backendTableNormalizeFixedColumns"),"[MIOOST][T072][apply payload fixed columns method scope]")
	DO EQ^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","prompt("),0,"[MIOOST][T072][no native prompt]")
	DO EQ^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","confirm("),0,"[MIOOST][T072][no native confirm]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 64L advanced table hardening"),"[MIOOST][T072][llm roi64l]")
	QUIT
	;
T073
	DO RUN^MIOOSTBLC
	QUIT
	;
	;
T074
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSPAT.m","mioos-patient-registration-v4"),"[MIOOST][T074][patient v3 contract]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSPAT.m","reviewQueues"),"[MIOOST][T074][review queues]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSPAT.m","PATACTION"),"[MIOOST][T074][patient server actions]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSST.m","win-patient-registration"),"[MIOOST][T074][direct patient window]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSMOD.m","duplicate-resolution"),"[MIOOST][T074][module advertises duplicate resolution]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","backendTableApplyPatientQueue"),"[MIOOST][T074][patient queue UI]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css","restore original modal backdrops"),"[MIOOST][T074][opaque modal bodies only]")
	DO OK^MIOTASSERT($$FILEHAS("docs/mioos/ROI_70_Patient_Registration_Search_Review_Queues.md","ROI 70"),"[MIOOST][T074][roi70 docs]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 70 patient registration"),"[MIOOST][T074][llm roi70]")
	QUIT
	;
	;
T075
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSPAT.m","CANLAUNCH"),"[MIOOST][T075][patient launch permission helper]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSPAT.m","MASKOUT"),"[MIOOST][T075][patient phi masking]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSTBL.m","ALLOW^MIOOSPAT"),"[MIOOST][T075][patient table denial]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSMOD.m","CANLAUNCH^MIOOSPAT"),"[MIOOST][T075][catalog patient gate]")
	DO OK^MIOTASSERT($$FILEHAS("routines/MIOOSST.m","CANLAUNCH^MIOOSPAT"),"[MIOOST][T075][desktop patient gate]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","backendTablePatientAddDefaults"),"[MIOOST][T075][queue aware add row]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/app/mioos_table.js","mioos-table-cell-action"),"[MIOOST][T075][compact cell edit actions]")
	DO OK^MIOTASSERT($$FILEHAS("public/mioos/mioos.css","ROI 71: compact cell edit controls"),"[MIOOST][T075][roi71 css]")
	DO OK^MIOTASSERT($$FILEHAS("docs/mioos/ROI_71_Patient_Registration_Permissions_PHI_Hardening.md","ROI 71"),"[MIOOST][T075][roi71 docs]")
	DO OK^MIOTASSERT($$FILEHAS("mioos_llm.md","ROI 71 patient registration"),"[MIOOST][T075][llm roi71]")
	QUIT
	;
	;