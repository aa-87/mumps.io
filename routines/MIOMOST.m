MIOMOST ; MIOMOS ROI 7 smoke tests
START
	NEW CONF,REQ,CTX,OUT,ERR,STATE,OBJ,TOKEN,INVITE,RESET,ARR,WCTX
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
	;
	KILL OBJ
	DO BOOTARY^MIOMOSST(.STATE,.CONF,.OBJ)
	DO EQ^MIOTASSERT($GET(OBJ("product","version")),"roi7-observability","[MIOMOST][T004][version]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","adminUsers")),"/api/miomos/admin/users","[MIOMOST][T004][admin users route]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","accessExport")),"/api/miomos/observability/access/export","[MIOMOST][T004][access export route]")
	DO EQ^MIOTASSERT($GET(OBJ("observability","retention","accessDays")),30,"[MIOMOST][T004][access retain]")
	DO EQ^MIOTASSERT($GET(OBJ("auth","inviteOnly")),0,"[MIOMOST][T004][invite only boot]")
	DO EQ^MIOTASSERT(+$DATA(OBJ("security","adminCounts","users"))>0,1,"[MIOMOST][T004][admin counts]")
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
	SET STATE("principal")="phaseone",STATE("roles")="developer",STATE("userName")="Phase One Tester"
	DO EQ^MIOTASSERT($$HAS^MIOMOSPERM(.STATE,"admin.users.view"),1,"[MIOMOST][T009][perm view]")
	DO EQ^MIOTASSERT($$HAS^MIOMOSPERM(.STATE,"admin.reset.manage"),1,"[MIOMOST][T009][perm reset]")
	DO USERLIST^MIOMOSADMIN(10,.ARR)
	DO EQ^MIOTASSERT($GET(ARR(1,"principal")),"phaseone","[MIOMOST][T009][user list]")
	DO COUNTS^MIOMOSADMIN(.ARR)
	DO EQ^MIOTASSERT(+$GET(ARR("users"))>0,1,"[MIOMOST][T009][admin counts]")
	DO EQ^MIOTASSERT($$HAS^MIOMOSPERM(.STATE,"logs.export"),1,"[MIOMOST][T009][perm logs export]")
	DO EQ^MIOTASSERT($$HAS^MIOMOSPERM(.STATE,"retention.manage"),1,"[MIOMOST][T009][perm retention]")
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
	KILL ^MIO("MIOMOS","LOG","ACCESS"),^MIO("MIOMOS","LOG","ERROR"),^MIO("MIOMOS","AUDIT")
	SET CTX("request_id")="miomost-rid"
	DO ACCESS^MIOMOSOBS("keep_one",.CTX,.STATE)
	DO ACCESS^MIOMOSOBS("keep_two",.CTX,.STATE)
	DO ACCESS^MIOMOSOBS("drop_three",.CTX,.STATE)
	DO EVENTX^MIOMOSAUD("keep_audit_one",.CTX,.STATE,"")
	DO EVENTX^MIOMOSAUD("drop_audit_two",.CTX,.STATE,"")
	DO PRUNE^MIOMOSOBS("ACCESS",2,0,.OUT)
	DO EQ^MIOTASSERT($GET(OUT("removed")),1,"[MIOMOST][T011][access prune removed]")
	DO EXPORT^MIOMOSOBS("ACCESS",10,.ARR)
	DO EQ^MIOTASSERT($GET(ARR(1,"event")),"keep_two","[MIOMOST][T011][access prune oldest]")
	DO PRUNE^MIOMOSAUD(1,0,.OUT)
	DO EQ^MIOTASSERT($GET(OUT("removed")),1,"[MIOMOST][T011][audit prune removed]")
	QUIT
	;
