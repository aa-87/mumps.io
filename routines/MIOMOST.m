MIOMOST ; MIOMOS ROI 10 smoke tests
START
	NEW CONF,REQ,CTX,OUT,ERR,STATE,OBJ,TOKEN,INVITE,RESET,ARR,WCTX,TERMID
	KILL ^MIO("MIOMOS"),^MIO("ROUTE")
	SET CONF("auth","enabled")=0
	DO CONFDEF^MIOMOS(.CONF)
	DO START^MIOTPL(.CONF)
	DO INIT^MIOROUTE
	DO REG^MIOMOS(.CONF)
	DO COMPILE^MIOROUTE
	;
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","GET","/api/miomos/admin/users","authRequired")),0,"[MIOMOST][T001][admin users auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","POST","/api/miomos/admin/invites/create","authRequired")),0,"[MIOMOST][T001][invite auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","POST","/api/miomos/auth/reset","authRequired")),0,"[MIOMOST][T001][reset auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","GET","/api/miomos/settings","authRequired")),0,"[MIOMOST][T001][settings get auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","GET","/api/miomos/view","authRequired")),0,"[MIOMOST][T001][view auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","POST","/api/miomos/command","authRequired")),0,"[MIOMOST][T001][command auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","POST","/api/miomos/settings","authRequired")),0,"[MIOMOST][T001][settings post auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","GET","/api/miomos/observability/summary","authRequired")),0,"[MIOMOST][T001][observ summary auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","GET","/api/miomos/observability/access/export","authRequired")),0,"[MIOMOST][T001][access export auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","POST","/api/miomos/observability/retention/prune","authRequired")),0,"[MIOMOST][T001][retention prune auth]")
	;
	KILL REQ,CTX,STATE,ERR
	SET CTX("request_id")="miomost-rid"
	DO OK^MIOTASSERT($$ENSURE^MIOMOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOMOST][T002][ensure]")
	DO EQ^MIOTASSERT($GET(STATE("userName")),"Developer","[MIOMOST][T002][user]")
	DO EQ^MIOTASSERT($GET(STATE("profile")),"dev","[MIOMOST][T002][profile]")
	DO EQ^MIOTASSERT($GET(STATE("inviteOnly")),0,"[MIOMOST][T002][invite off]")
	;
	KILL OUT,ERR,CTX
	DO DESKCTX^MIOMOSUI(.STATE,.CONF,.CTX)
	DO OK^MIOTASSERT($$RENDERPAGE^MIOTPL("pages/miomos_desktop.html","layouts/miomos_shell.html",.CONF,.CTX,.OUT,.ERR),"[MIOMOST][T003][render]")
	DO OK^MIOTASSERT(OUT["data-admin-surface","[MIOMOST][T003][admin surface]")
	DO OK^MIOTASSERT(OUT["Identity hardening and admin operations","[MIOMOST][T003][admin copy]")
	DO OK^MIOTASSERT(OUT["/api/miomos/admin/users","[MIOMOST][T003][admin route]")
	DO OK^MIOTASSERT(OUT["Summary JSON","[MIOMOST][T003][obs export]")
	DO OK^MIOTASSERT(OUT["data-miomos-single-socket=""1""","[MIOMOST][T003][single socket]")
	DO OK^MIOTASSERT(OUT["data-settings-form","[MIOMOST][T003][settings surface]")
	DO OK^MIOTASSERT(OUT["data-miomos-command=""/api/miomos/command""","[MIOMOST][T003][command route]")
	DO OK^MIOTASSERT(OUT["id=""miomosBootJson""","[MIOMOST][T003][boot json]")
	DO OK^MIOTASSERT(OUT["data-terminal-surface","[MIOMOST][T003][terminal surface]")
	DO OK^MIOTASSERT(OUT["miomosTerminalViewport","[MIOMOST][T003][terminal viewport]")
	DO OK^MIOTASSERT(OUT["data-setting-terminal=""fontFamily""","[MIOMOST][T003][terminal settings]")
	DO OK^MIOTASSERT(OUT["data-launch-app=""terminal""","[MIOMOST][T003][terminal app]")
	DO OK^MIOTASSERT(OUT["data-entry-kind=""directory""","[MIOMOST][T003][directory entry]")
	DO OK^MIOTASSERT(OUT["data-entry-kind=""future""","[MIOMOST][T003][future entry]")
	DO OK^MIOTASSERT(OUT["data-session-surface","[MIOMOST][T003][session surface]")
	DO OK^MIOTASSERT(OUT["data-ui-contract","[MIOMOST][T003][ui contract]")
	DO OK^MIOTASSERT(OUT["Server-owned session posture","[MIOMOST][T003][session copy]")
	DO OK^MIOTASSERT(OUT["session.ui.save","[MIOMOST][T003][session command]")
	;
	KILL OBJ
	DO BOOTARY^MIOMOSST(.STATE,.CONF,.OBJ)
	DO EQ^MIOTASSERT($GET(OBJ("product","version")),"roi21-uiux-session-hardening","[MIOMOST][T004][version]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","adminUsers")),"/api/miomos/admin/users","[MIOMOST][T004][admin users route]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","settings")),"/api/miomos/settings","[MIOMOST][T004][settings route]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","view")),"/api/miomos/view","[MIOMOST][T004][view route]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","command")),"/api/miomos/command","[MIOMOST][T004][command route]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","accessExport")),"/api/miomos/observability/access/export","[MIOMOST][T004][access export route]")
	DO EQ^MIOTASSERT($GET(OBJ("observability","retention","accessDays")),30,"[MIOMOST][T004][access retain]")
	DO EQ^MIOTASSERT($GET(OBJ("auth","inviteOnly")),0,"[MIOMOST][T004][invite only boot]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","fontFamily")),"Segoe UI","[MIOMOST][T004][font family]")
	DO EQ^MIOTASSERT(+$GET(OBJ("desktop","fontSize")),13,"[MIOMOST][T004][font size]")
	DO EQ^MIOTASSERT(+$DATA(OBJ("desktop","settings","catalog","themes",1,"key"))>0,1,"[MIOMOST][T004][settings catalog]")
	DO EQ^MIOTASSERT(+$DATA(OBJ("desktop","settings","catalog","terminal","fonts",1,"key"))>0,1,"[MIOMOST][T004][terminal catalog]")
	DO EQ^MIOTASSERT($GET(OBJ("apps",6,"key")),"terminal","[MIOMOST][T004][terminal app key]")
	DO EQ^MIOTASSERT($GET(OBJ("windows",6,"appKey")),"terminal","[MIOMOST][T004][terminal win key]")
	DO EQ^MIOTASSERT(+$DATA(OBJ("security","adminCounts","users"))>0,1,"[MIOMOST][T004][admin counts]")
	DO EQ^MIOTASSERT($GET(OBJ("session","ui","menuOpen")),0,"[MIOMOST][T004][session ui boot]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","savedLayoutAt")),"","[MIOMOST][T004][layout saved at empty]")
	;
	KILL CONF
	SET CONF("auth","enabled")=1
	SET CONF("miomos","profile")="prod"
	SET CONF("miomos","dev","enabled")=0
	SET CONF("miomos","dev","authDisabled")=0
	SET CONF("miomos","localAuth","enabled")=1
	SET CONF("miomos","localAuth","allowSignup")=1
	SET CONF("miomos","localAuth","inviteOnly")=1
	SET CONF("miomos","localAuth","lockThreshold")=2
	SET CONF("miomos","localAuth","lockMinutes")=15
	DO CONFDEF^MIOMOS(.CONF)
	KILL ERR,TOKEN
	DO EQ^MIOTASSERT($$SIGNUP^MIOMOSAUTH(.CONF,"phaseone","supersecret","Phase One Tester","operator",.TOKEN,.ERR),0,"[MIOMOST][T005][invite required]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"invite_required","[MIOMOST][T005][invite error]")
	DO OK^MIOTASSERT($$CREATEINVITE^MIOMOSAUTH(.CONF,"admin","operator","Phase invite",.INVITE,.ERR),"[MIOMOST][T005][invite create]")
	DO OK^MIOTASSERT($$SIGNUP^MIOMOSAUTH(.CONF,"phaseone","supersecret","Phase One Tester","",.TOKEN,.ERR,INVITE),"[MIOMOST][T005][signup invite]")
	DO OK^MIOTASSERT(INVITE'="","[MIOMOST][T005][invite token]")
	;
	DO EQ^MIOTASSERT($$SIGNIN^MIOMOSAUTH(.CONF,"phaseone","wrong-pass",.TOKEN,.ERR),0,"[MIOMOST][T006][signin fail one]")
	DO EQ^MIOTASSERT($$SIGNIN^MIOMOSAUTH(.CONF,"phaseone","wrong-pass",.TOKEN,.ERR),0,"[MIOMOST][T006][signin fail two]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"locked_account","[MIOMOST][T006][locked]")
	DO EQ^MIOTASSERT($$SIGNIN^MIOMOSAUTH(.CONF,"phaseone","supersecret",.TOKEN,.ERR),0,"[MIOMOST][T006][signin blocked]")
	DO OK^MIOTASSERT($$UNLOCK^MIOMOSAUTH("phaseone"),"[MIOMOST][T006][unlock]")
	DO OK^MIOTASSERT($$SIGNIN^MIOMOSAUTH(.CONF,"phaseone","supersecret",.TOKEN,.ERR),"[MIOMOST][T006][signin success]")
	;
	DO OK^MIOTASSERT($$REQUESTRESET^MIOMOSAUTH(.CONF,"admin","phaseone",.RESET,.ERR),"[MIOMOST][T007][reset request]")
	DO OK^MIOTASSERT($$APPLYRESET^MIOMOSAUTH(.CONF,RESET,"freshsecret",.ERR),"[MIOMOST][T007][reset apply]")
	DO OK^MIOTASSERT($$SIGNIN^MIOMOSAUTH(.CONF,"phaseone","freshsecret",.TOKEN,.ERR),"[MIOMOST][T007][signin after reset]")
	;
	DO OK^MIOTASSERT($$DISABLE^MIOMOSAUTH("phaseone"),"[MIOMOST][T008][disable]")
	DO EQ^MIOTASSERT($$SIGNIN^MIOMOSAUTH(.CONF,"phaseone","freshsecret",.TOKEN,.ERR),0,"[MIOMOST][T008][disabled signin]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"account_disabled","[MIOMOST][T008][disabled error]")
	DO OK^MIOTASSERT($$ENABLE^MIOMOSAUTH("phaseone"),"[MIOMOST][T008][enable]")
	DO OK^MIOTASSERT($$LOCK^MIOMOSAUTH(.CONF,"phaseone",5),"[MIOMOST][T008][lock manual]")
	DO EQ^MIOTASSERT($$SIGNIN^MIOMOSAUTH(.CONF,"phaseone","freshsecret",.TOKEN,.ERR),0,"[MIOMOST][T008][locked signin]")
	DO OK^MIOTASSERT($$UNLOCK^MIOMOSAUTH("phaseone"),"[MIOMOST][T008][unlock manual]")
	DO OK^MIOTASSERT($$SIGNIN^MIOMOSAUTH(.CONF,"phaseone","freshsecret",.TOKEN,.ERR),"[MIOMOST][T008][signin relogin]")
	;
	SET REQ("hdr","cookie")="miomos_auth="_TOKEN
	DO OK^MIOTASSERT($$LOADLOCAL^MIOMOSAUTH(.CONF,.REQ,.WCTX,.ERR),"[MIOMOST][T009][load local]")
	SET STATE("principal")="phaseone",STATE("roles")="developer",STATE("userName")="Phase One Tester",STATE("sessionId")="term-session-1",STATE("profile")="prod"
	DO LOAD^MIOMOSSET(.STATE,.CONF)
	DO EQ^MIOTASSERT($$HAS^MIOMOSPERM(.STATE,"admin.users.view"),1,"[MIOMOST][T009][perm view]")
	DO EQ^MIOTASSERT($$HAS^MIOMOSPERM(.STATE,"admin.reset.manage"),1,"[MIOMOST][T009][perm reset]")
	DO EQ^MIOTASSERT($$HAS^MIOMOSPERM(.STATE,"terminal.use"),1,"[MIOMOST][T009][perm terminal]")
	DO USERLIST^MIOMOSADMIN(10,.ARR)
	DO EQ^MIOTASSERT($GET(ARR(1,"principal")),"phaseone","[MIOMOST][T009][user list]")
	DO COUNTS^MIOMOSADMIN(.ARR)
	DO EQ^MIOTASSERT(+$GET(ARR("users"))>0,1,"[MIOMOST][T009][admin counts]")
	DO EQ^MIOTASSERT($$HAS^MIOMOSPERM(.STATE,"logs.export"),1,"[MIOMOST][T009][perm logs export]")
	DO EQ^MIOTASSERT($$HAS^MIOMOSPERM(.STATE,"retention.manage"),1,"[MIOMOST][T009][perm retention]")
	DO EQ^MIOTASSERT($$HAS^MIOMOSPERM(.STATE,"settings.self"),1,"[MIOMOST][T009][perm settings]")
	KILL ARR,ERR
	SET ARR("themeKey")="clinical-blue",ARR("fontFamily")="Inter",ARR("fontSize")=14,ARR("titleAccent")="violet",ARR("iconStyle")="classic",ARR("wallpaper")="aurora-blue",ARR("density")="compact",ARR("animations")="off",ARR("icons","workspace")="WS",ARR("icons","terminal")="TR"
	SET ARR("terminal","fontFamily")="Fira Code",ARR("terminal","fontSize")=15,ARR("terminal","cursorStyle")="underline",ARR("terminal","cursorBlink")=0,ARR("terminal","renderer")="dom",ARR("terminal","unicode")="unicode11",ARR("terminal","scrollback")=5000,ARR("terminal","cols")=132,ARR("terminal","rows")=32
	DO OK^MIOTASSERT($$SAVE^MIOMOSSET("phaseone",.ARR,.OUT,.ERR),"[MIOMOST][T009][settings save]")
	DO EQ^MIOTASSERT($GET(OUT("current","themeKey")),"clinical-blue","[MIOMOST][T009][theme saved]")
	DO EQ^MIOTASSERT($GET(OUT("current","fontFamily")),"Inter","[MIOMOST][T009][font saved]")
	DO EQ^MIOTASSERT(+$GET(OUT("current","fontSize")),14,"[MIOMOST][T009][font size saved]")
	DO EQ^MIOTASSERT($GET(OUT("current","icon","workspace")),"WS","[MIOMOST][T009][icon saved]")
	DO EQ^MIOTASSERT($GET(OUT("current","icon","terminal")),"TR","[MIOMOST][T009][terminal icon saved]")
	DO EQ^MIOTASSERT($GET(OUT("current","terminal","fontFamily")),"Fira Code","[MIOMOST][T009][term font saved]")
	DO EQ^MIOTASSERT(+$GET(OUT("current","terminal","cols")),132,"[MIOMOST][T009][term cols saved]")
	;
	KILL ARR,OUT,CTX
	SET CTX("request_id")="miomost-rid"
	DO ACCESS^MIOMOSOBS("export_probe",.CTX,.STATE)
	DO ERROR^MIOMOSOBS("error_probe","demo_code",.CTX,.STATE,"retention-probe")
	DO EVENTX^MIOMOSAUD("audit_probe",.CTX,.STATE,"digest-probe")
	DO SUMMARY^MIOMOSOBS(.STATE,.CONF,.OUT)
	DO EQ^MIOTASSERT(+$GET(OUT("counts","access"))>0,1,"[MIOMOST][T010][access count]")
	DO EQ^MIOTASSERT($GET(OUT("lastAccess","correlationId")),"miomost-rid","[MIOMOST][T010][correlation]")
	DO EXPORT^MIOMOSOBS("ERROR",10,.ARR)
	DO EQ^MIOTASSERT($GET(ARR(1,"event")),"error_probe","[MIOMOST][T010][error export]")
	DO EXPORT^MIOMOSAUD(10,.ARR)
	DO EQ^MIOTASSERT($GET(ARR(1,"event")),"audit_probe","[MIOMOST][T010][audit export]")
	;
	KILL OUT,ERR,ARR
	DO OK^MIOTASSERT($$OPEN^MIOMOSTERM(.STATE,.CONF,"",.OUT,.ERR),"[MIOMOST][T011][terminal open]")
	SET TERMID=$GET(OUT("terminalId"))
	DO EQ^MIOTASSERT(TERMID'="",1,"[MIOMOST][T011][terminal id]")
	DO EQ^MIOTASSERT(+$GET(OUT("profile","cols")),132,"[MIOMOST][T011][terminal profile cols]")
	DO OK^MIOTASSERT($$INPUT^MIOMOSTERM(.STATE,TERMID,"whoami",.OUT,.ERR),"[MIOMOST][T011][terminal whoami]")
	DO EQ^MIOTASSERT($$HASWRITE(.OUT,"phaseone"),1,"[MIOMOST][T011][terminal output]")
	DO OK^MIOTASSERT($$RESIZE^MIOMOSTERM(.STATE,TERMID,132,32,.OUT,.ERR),"[MIOMOST][T011][terminal resize]")
	DO EQ^MIOTASSERT(+$GET(OUT("cols")),132,"[MIOMOST][T011][terminal cols]")
	DO OK^MIOTASSERT($$CLOSE^MIOMOSTERM(.STATE,TERMID,.OUT,.ERR),"[MIOMOST][T011][terminal close]")
	DO EQ^MIOTASSERT(+$GET(OUT("closed")),1,"[MIOMOST][T011][terminal closed]")
	;
	KILL ^MIO("MIOMOS","LOG","ACCESS"),^MIO("MIOMOS","LOG","ERROR"),^MIO("MIOMOS","AUDIT")
	SET CTX("request_id")="miomost-rid"
	DO ACCESS^MIOMOSOBS("keep_one",.CTX,.STATE)
	DO ACCESS^MIOMOSOBS("keep_two",.CTX,.STATE)
	DO ACCESS^MIOMOSOBS("drop_three",.CTX,.STATE)
	DO EVENTX^MIOMOSAUD("keep_audit_one",.CTX,.STATE,"")
	DO EVENTX^MIOMOSAUD("drop_audit_two",.CTX,.STATE,"")
	DO PRUNE^MIOMOSOBS("ACCESS",2,0,.OUT)
	DO EQ^MIOTASSERT($GET(OUT("removed")),1,"[MIOMOST][T012][access prune removed]")
	DO EXPORT^MIOMOSOBS("ACCESS",10,.ARR)
	DO EQ^MIOTASSERT($GET(ARR(1,"event")),"keep_two","[MIOMOST][T012][access prune oldest]")
	DO PRUNE^MIOMOSAUD(1,0,.OUT)
	DO EQ^MIOTASSERT($GET(OUT("removed")),1,"[MIOMOST][T012][audit prune removed]")
	;
	;
	NEW VM,TREE
	DO BUILD^MIOMOSVM(.STATE,.CONF,.VM)
	DO EQ^MIOTASSERT($GET(VM("workspace","headline")),"Production workspace","[MIOMOST][T013][workspace headline]")
	DO EQ^MIOTASSERT($GET(VM("session","headline")),"Server-owned session posture","[MIOMOST][T013][session headline]")
	DO EQ^MIOTASSERT($GET(VM("ux","headline")),"UI contract hardening","[MIOMOST][T013][ux headline]")
	DO EQ^MIOTASSERT(+$DATA(VM("settings","catalog","themes",1,"key"))>0,1,"[MIOMOST][T013][settings catalog]")
	KILL TREE,OBJ,ERR
	SET TREE("command")="desktop.ping"
	DO OK^MIOTASSERT($$EXEC^MIOMOSCMD(.STATE,.CONF,.TREE,.OBJ,.ERR),"[MIOMOST][T013][command ping]")
	DO EQ^MIOTASSERT($GET(OBJ("pong")),1,"[MIOMOST][T013][pong]")
	KILL TREE,OBJ,ERR
	SET TREE("command")="layout.save",TREE("layoutJson")="{""layout"":{""windows"":[{""id"":""workspace""}]}}"
	DO OK^MIOTASSERT($$EXEC^MIOMOSCMD(.STATE,.CONF,.TREE,.OBJ,.ERR),"[MIOMOST][T013][layout save]")
	DO EQ^MIOTASSERT($GET(OBJ("saved")),1,"[MIOMOST][T013][layout saved]")
	KILL TREE,OBJ,ERR
	SET TREE("command")="session.ui.save",TREE("menuOpen")=1,TREE("activeWindowId")="win-terminal",TREE("focusedAppKey")="terminal",TREE("layoutMode")="tile",TREE("lastCommandName")="shell.focusTerminal",TREE("reason")="test"
	DO OK^MIOTASSERT($$EXEC^MIOMOSCMD(.STATE,.CONF,.TREE,.OBJ,.ERR),"[MIOMOST][T013][session ui save]")
	DO EQ^MIOTASSERT($GET(OBJ("session","ui","activeWindowId")),"win-terminal","[MIOMOST][T013][session active win]")
	DO EQ^MIOTASSERT($GET(OBJ("session","ui","menuOpen")),1,"[MIOMOST][T013][session menu open]")
	KILL TREE,OBJ,ERR
	SET TREE("command")="session.snapshot"
	DO OK^MIOTASSERT($$EXEC^MIOMOSCMD(.STATE,.CONF,.TREE,.OBJ,.ERR),"[MIOMOST][T013][session snapshot]")
	DO EQ^MIOTASSERT($GET(OBJ("session","ui","focusedAppKey")),"terminal","[MIOMOST][T013][session focused app]")
	DO EQ^MIOTASSERT($GET(OBJ("session","hasLayout")),1,"[MIOMOST][T013][session has layout]")
	;
	DO CURRENT^MIOMOSSET($GET(STATE("principal")),.ARR)
	DO EQ^MIOTASSERT(+$DATA(ARR("catalog","windowManager","windowPresets",1,"key"))>0,1,"[MIOMOST][T014][wm preset catalog]")
	DO EQ^MIOTASSERT(+$DATA(ARR("catalog","windowManager","motionProfiles",1,"key"))>0,1,"[MIOMOST][T014][wm motion catalog]")
	DO BUILD^MIOMOSVM(.STATE,.CONF,.VM)
	DO EQ^MIOTASSERT($GET(VM("terminal","transport")),"pipe","[MIOMOST][T014][terminal transport]")
	DO EQ^MIOTASSERT($GET(VM("windowManager","windowPreset"))'="",1,"[MIOMOST][T014][window preset]")
	DO DEFAULTWINS^MIOMOSWM(.ARR,"terminal")
	DO EQ^MIOTASSERT($GET(ARR(6,"appKey")),"terminal","[MIOMOST][T015][wm default terminal]")
	DO EQ^MIOTASSERT(+$GET(ARR(6,"width"))>1000,1,"[MIOMOST][T015][wm terminal width]")
	QUIT
	;
HASWRITE(OUT,TEXT)
	NEW N,FOUND
	SET (N,FOUND)=0
	FOR  SET N=$ORDER(OUT("write",N)) QUIT:N=""  DO  QUIT:FOUND
	. IF $GET(OUT("write",N))[$GET(TEXT) SET FOUND=1
	QUIT FOUND
	;
	;