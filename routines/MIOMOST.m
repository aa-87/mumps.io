MIOMOST ; MIOMOS smoke tests
START
	NEW CONF,REQ,CTX,OUT,ERR,STATE,OBJ
	KILL ^MIO("MIOMOS"),^MIO("ROUTE")
	SET CONF("auth","enabled")=0
	DO CONFDEF^MIOMOS(.CONF)
	DO START^MIOTPL(.CONF)
	DO INIT^MIOROUTE
	DO REG^MIOMOS(.CONF)
	DO COMPILE^MIOROUTE
	;
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","GET","/miomos","authRequired")),0,"[MIOMOST][T001][desktop auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","GET","/api/miomos/bootstrap","authRequired")),0,"[MIOMOST][T001][bootstrap auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","WS","/ws/miomos","authRequired")),0,"[MIOMOST][T001][ws auth]")
	;
	KILL REQ,CTX,STATE,ERR
	SET CTX("request_id")="miomost-rid"
	DO OK^MIOTASSERT($$ENSURE^MIOMOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOMOST][T002][ensure]")
	DO EQ^MIOTASSERT($GET(STATE("userName")),"Developer","[MIOMOST][T002][user]")
	DO EQ^MIOTASSERT($GET(STATE("profile")),"dev","[MIOMOST][T002][profile]")
	DO EQ^MIOTASSERT($GET(STATE("density")),"compact","[MIOMOST][T002][density]")
	;
	KILL OUT,ERR,CTX
	DO DESKCTX^MIOMOSUI(.STATE,.CONF,.CTX)
	DO OK^MIOTASSERT($$RENDERPAGE^MIOTPL("pages/miomos_desktop.html","layouts/miomos_shell.html",.CONF,.CTX,.OUT,.ERR),"[MIOMOST][T003][render]")
	DO OK^MIOTASSERT(OUT["data-miomos-taskbar","[MIOMOST][T003][taskbar]")
	DO OK^MIOTASSERT(OUT["data-miomos-single-socket","[MIOMOST][T003][single socket]")
	DO OK^MIOTASSERT(OUT["miomos-desktop-icons","[MIOMOST][T003][desktop icons]")
	DO OK^MIOTASSERT(OUT["miomos-window-controls","[MIOMOST][T003][controls]")
	DO OK^MIOTASSERT(OUT["miomos-grid-table","[MIOMOST][T003][dense table]")
	DO OK^MIOTASSERT(OUT["/ws/miomos","[MIOMOST][T003][ws path]")
	DO EQ^MIOTASSERT(OUT["miomos-topbar",0,"[MIOMOST][T003][no topbar]")
	DO EQ^MIOTASSERT(OUT["miomos-side-rail",0,"[MIOMOST][T003][no side rail]")
	;
	KILL OBJ
	DO BOOTARY^MIOMOSST(.STATE,.CONF,.OBJ)
	DO EQ^MIOTASSERT($GET(OBJ("product","profile")),"dev","[MIOMOST][T004][boot profile]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","websocket")),"/ws/miomos","[MIOMOST][T004][boot ws]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","launcherLabel")),"Menu","[MIOMOST][T004][menu]")
	DO EQ^MIOTASSERT($GET(OBJ("integrations","osjs","standalone")),"deferred","[MIOMOST][T004][osjs deferred]")
	;
	NEW PAYLOAD,SID,WCTX,WERR
	SET PAYLOAD="{""event"":""hello"",""sessionId"":"""_$GET(STATE("sessionId"))_"""}"
	SET SID=$$SESSIONID^MIOMOSWS(PAYLOAD)
	DO EQ^MIOTASSERT(SID,$GET(STATE("sessionId")),"[MIOMOST][T005][sid parse]")
	DO OK^MIOTASSERT($$INJECTAUTH^MIOMOSWS(.CONF,SID,.WCTX,.WERR),"[MIOMOST][T005][inject]")
	DO EQ^MIOTASSERT($GET(WCTX("auth","claims","name")),"Developer","[MIOMOST][T005][inject user]")
	QUIT
	;
