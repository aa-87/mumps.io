MIOMOSTH ; MIOMOS theme catalog and preferences
	QUIT
	;
CURRENT(STATE,CONF)
	NEW KEY,USER
	SET USER=$GET(STATE("principal"))
	SET KEY=$GET(^MIO("MIOMOS","PREF",USER,"theme"))
	IF $$VALID(KEY) QUIT KEY
	SET KEY=$GET(CONF("miomos","theme","default"),"midnight-professional")
	IF $$VALID(KEY) QUIT KEY
	QUIT "midnight-professional"
	;
SAVE(USER,KEY,ERR)
	KILL ERR
	SET ERR("routine")="MIOMOSTH"
	IF $GET(USER)="" SET ERR("error")="principal_missing" QUIT 0
	IF '$$VALID($GET(KEY)) SET ERR("error")="theme_invalid" QUIT 0
	SET ^MIO("MIOMOS","PREF",USER,"theme")=KEY
	SET ^MIO("MIOMOS","PREF",USER,"themeSavedAt")=$$NOWISO^MIOUTIL()
	QUIT 1
	;
VALID(KEY)
	NEW TMP
	DO THEME($GET(KEY),.TMP)
	QUIT $SELECT($GET(TMP("key"))'="":1,1:0)
	;
THEME(KEY,OUT)
	KILL OUT
	IF $GET(KEY)="midnight-professional" DO  QUIT
	. SET OUT("key")="midnight-professional",OUT("label")="Midnight Professional",OUT("mode")="dark"
	. SET OUT("accent")="#5f8dff",OUT("accentSoft")="rgba(95,141,255,.18)",OUT("wallpaper")="midnight-clinic"
	. SET OUT("desktop")="#0f1724",OUT("taskbar")="rgba(8,14,24,.78)",OUT("surface")="rgba(20,28,39,.92)"
	. SET OUT("surfaceAlt")="rgba(14,21,31,.88)",OUT("border")="rgba(149,168,196,.18)",OUT("text")="#edf3fb"
	. SET OUT("muted")="#98a8bf",OUT("icon")="linear-gradient(180deg,#7ea6ff,#4a73e6)"
	IF $GET(KEY)="slate-light" DO  QUIT
	. SET OUT("key")="slate-light",OUT("label")="Slate Light",OUT("mode")="light"
	. SET OUT("accent")="#2f6fed",OUT("accentSoft")="rgba(47,111,237,.14)",OUT("wallpaper")="soft-grid"
	. SET OUT("desktop")="#e8eef6",OUT("taskbar")="rgba(241,246,252,.90)",OUT("surface")="rgba(255,255,255,.95)"
	. SET OUT("surfaceAlt")="rgba(248,250,253,.94)",OUT("border")="rgba(90,115,150,.18)",OUT("text")="#162435"
	. SET OUT("muted")="#607286",OUT("icon")="linear-gradient(180deg,#5a8ff2,#2b63d4)"
	IF $GET(KEY)="clinical-blue" DO  QUIT
	. SET OUT("key")="clinical-blue",OUT("label")="Clinical Blue",OUT("mode")="light"
	. SET OUT("accent")="#1384d7",OUT("accentSoft")="rgba(19,132,215,.16)",OUT("wallpaper")="clinical-grid"
	. SET OUT("desktop")="#dfeef8",OUT("taskbar")="rgba(231,242,249,.92)",OUT("surface")="rgba(255,255,255,.96)"
	. SET OUT("surfaceAlt")="rgba(242,248,252,.94)",OUT("border")="rgba(64,118,150,.18)",OUT("text")="#143042"
	. SET OUT("muted")="#5c7685",OUT("icon")="linear-gradient(180deg,#46a8ec,#0a74c6)"
	IF $GET(KEY)="high-contrast" DO  QUIT
	. SET OUT("key")="high-contrast",OUT("label")="High Contrast",OUT("mode")="dark"
	. SET OUT("accent")="#ffd400",OUT("accentSoft")="rgba(255,212,0,.20)",OUT("wallpaper")="contrast"
	. SET OUT("desktop")="#000000",OUT("taskbar")="rgba(0,0,0,.92)",OUT("surface")="rgba(10,10,10,.96)"
	. SET OUT("surfaceAlt")="rgba(0,0,0,.90)",OUT("border")="rgba(255,255,255,.34)",OUT("text")="#ffffff"
	. SET OUT("muted")="#f2f2f2",OUT("icon")="linear-gradient(180deg,#ffd400,#c79d00)"
	QUIT
	;
CATALOG(ROOT)
	KILL @ROOT
	DO CATSET(ROOT,1,"midnight-professional")
	DO CATSET(ROOT,2,"slate-light")
	DO CATSET(ROOT,3,"clinical-blue")
	DO CATSET(ROOT,4,"high-contrast")
	QUIT
	;
CATSET(ROOT,N,KEY)
	NEW TMP,K
	DO THEME(KEY,.TMP)
	SET K=""
	FOR  SET K=$ORDER(TMP(K)) QUIT:K=""  SET @ROOT@(N,K)=TMP(K)
	QUIT
	;
PUTOBJ(ROOT,KEY)
	NEW TMP,K
	DO THEME(KEY,.TMP)
	SET K=""
	FOR  SET K=$ORDER(TMP(K)) QUIT:K=""  SET @ROOT@(K)=TMP(K)
	QUIT
	;
