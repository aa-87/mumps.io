MIOOST ; MIOOS tests
	DO T001
	DO T002
	DO T003
	DO T004
	DO T005
	DO T006
	DO T007
	QUIT
	;
RESET
	KILL ^MIO("ROUTE")
	KILL ^MIO("CONF","server","routing")
	KILL ^MIO("MIOOS")
	KILL ^MIO("AUTH","SESSION","mioos")
	KILL ^MIO("AUTH","SESSION","BYUSER","mioos")
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
	KILL EP DO AMATCH("[MIOOST][T001][ws]","WS","/ws/mioos",1,"MESSAGE^MIOOSWS","/ws/mioos",.EP)
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
	DO OK^MIOTASSERT($$DECODE^MIOJSON(JSON,.OBJ,.ERR),"[MIOOST][T002][decode]")
	DO EQ^MIOTASSERT($GET(OBJ("product","name")),"MIOOS","[MIOOST][T002][product]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","websocket")),"/ws/mioos","[MIOOST][T002][ws route]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","signin")),"/api/mioos/auth/signin","[MIOOST][T002][signin route]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","launcherLabel")),"Menu","[MIOOST][T002][launcher]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","commandTransport")),"websocket-only","[MIOOST][T002][transport]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","realtimeContract")),"single-websocket-command-and-events","[MIOOST][T002][realtime]")
	DO EQ^MIOTASSERT($GET(OBJ("apps",4,"key")),"terminal","[MIOOST][T002][terminal app]")
	DO EQ^MIOTASSERT($GET(OBJ("windows",1,"appKey")),"my-computer","[MIOOST][T002][explorer window]")
	DO EQ^MIOTASSERT(+$GET(OBJ("auth","enabled")),1,"[MIOOST][T002][auth enabled]")
	DO EQ^MIOTASSERT(+$GET(OBJ("desktop","noMarkupData")),1,"[MIOOST][T002][no markup data]")
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
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-mioos-single-socket=""1"""),"[MIOOST][T003][contract token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","data-mioos-signin="),"[MIOOST][T003][signin token]")
	DO OK^MIOTASSERT($$FILEHAS("templates/pages/mioos_desktop.html","mioos-auth-overlay"),"[MIOOST][T003][auth overlay]")
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
	DO OK^MIOTASSERT($$DECODE^MIOJSON(JSON,.OBJ,.ERR),"[MIOOST][T004][hello decode]")
	DO EQ^MIOTASSERT($GET(OBJ("event")),"hello","[MIOOST][T004][hello event]")
	DO EQ^MIOTASSERT($GET(OBJ("commandResultEvent")),"desktop.result","[MIOOST][T004][result event]")
	SET JSON=$$PONGJSON^MIOOSWS(.STATE)
	DO OK^MIOTASSERT($$DECODE^MIOJSON(JSON,.OBJ,.ERR),"[MIOOST][T004][pong decode]")
	DO EQ^MIOTASSERT($GET(OBJ("event")),"pong","[MIOOST][T004][pong event]")
	DO BUILD^MIOOSVM(.STATE,.CONF,.VIEW)
	SET JSON=$$VIEWJSON^MIOOSWS(.STATE,.VIEW)
	DO OK^MIOTASSERT($$DECODE^MIOJSON(JSON,.OBJ,.ERR),"[MIOOST][T004][view decode]")
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
	DO OK^MIOTASSERT($$DECODE^MIOJSON(JSON,.OBJ,.ERR),"[MIOOST][T006][decode]")
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