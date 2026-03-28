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
	. SET OUT("accent")="#5f8dff",OUT("accentSoft")="rgba(95,141,255,.18)",OUT("accentStrong")="rgba(95,141,255,.34)"
	. SET OUT("wallpaper")="midnight-clinic",OUT("desktop")="#0b1320",OUT("surface")="rgba(15,23,36,.95)",OUT("surfaceAlt")="rgba(11,18,29,.96)"
	. SET OUT("border")="rgba(148,163,184,.18)",OUT("text")="#ecf3ff",OUT("muted")="#93a7c4",OUT("icon")="linear-gradient(180deg,#7ea6ff,#4a73e6)"
	. SET OUT("titleActive")="linear-gradient(180deg, rgba(255,255,255,0.12), rgba(255,255,255,0.03)), linear-gradient(90deg, #5f8dff, rgba(255,255,255,0.02) 38%)"
	. SET OUT("titleInactive")="linear-gradient(180deg, rgba(91,103,122,0.42), rgba(45,56,72,0.36))"
	. SET OUT("shadow")="0 18px 42px rgba(0,0,0,.26)"
	IF $GET(KEY)="slate-light" DO  QUIT
	. SET OUT("key")="slate-light",OUT("label")="Slate Light",OUT("mode")="light"
	. SET OUT("accent")="#2f6fed",OUT("accentSoft")="rgba(47,111,237,.14)",OUT("accentStrong")="rgba(47,111,237,.24)"
	. SET OUT("wallpaper")="soft-grid",OUT("desktop")="#e8eef6",OUT("surface")="rgba(255,255,255,.95)",OUT("surfaceAlt")="rgba(248,250,253,.94)"
	. SET OUT("border")="rgba(90,115,150,.18)",OUT("text")="#162435",OUT("muted")="#607286",OUT("icon")="linear-gradient(180deg,#5a8ff2,#2b63d4)"
	. SET OUT("titleActive")="linear-gradient(180deg,#ffffff,#e8effb)",OUT("titleInactive")="linear-gradient(180deg,#f4f7fb,#e8edf3)",OUT("shadow")="0 16px 36px rgba(8,18,33,.18)"
	IF $GET(KEY)="clinical-blue" DO  QUIT
	. SET OUT("key")="clinical-blue",OUT("label")="Clinical Blue",OUT("mode")="light"
	. SET OUT("accent")="#1384d7",OUT("accentSoft")="rgba(19,132,215,.16)",OUT("accentStrong")="rgba(19,132,215,.28)"
	. SET OUT("wallpaper")="aurora-blue",OUT("desktop")="#dfeef8",OUT("surface")="rgba(255,255,255,.96)",OUT("surfaceAlt")="rgba(242,248,252,.94)"
	. SET OUT("border")="rgba(64,118,150,.18)",OUT("text")="#143042",OUT("muted")="#5c7685",OUT("icon")="linear-gradient(180deg,#46a8ec,#0a74c6)"
	. SET OUT("titleActive")="linear-gradient(180deg,#ffffff,#edf7fd)",OUT("titleInactive")="linear-gradient(180deg,#eef6fb,#dfeef8)",OUT("shadow")="0 16px 36px rgba(7,62,96,.16)"
	IF $GET(KEY)="surgical-teal" DO  QUIT
	. SET OUT("key")="surgical-teal",OUT("label")="Surgical Teal",OUT("mode")="dark"
	. SET OUT("accent")="#14b8a6",OUT("accentSoft")="rgba(20,184,166,.18)",OUT("accentStrong")="rgba(20,184,166,.30)"
	. SET OUT("wallpaper")="aurora-blue",OUT("desktop")="#07141a",OUT("surface")="rgba(8,24,29,.95)",OUT("surfaceAlt")="rgba(6,18,23,.96)"
	. SET OUT("border")="rgba(89,161,154,.22)",OUT("text")="#e7fcf8",OUT("muted")="#8ab4b0",OUT("icon")="linear-gradient(180deg,#2dd4bf,#0f766e)"
	. SET OUT("titleActive")="linear-gradient(180deg, rgba(255,255,255,0.10), rgba(255,255,255,0.02)), linear-gradient(90deg,#14b8a6, rgba(255,255,255,0.02) 42%)"
	. SET OUT("titleInactive")="linear-gradient(180deg, rgba(71,98,102,0.36), rgba(32,46,48,0.34))",OUT("shadow")="0 18px 42px rgba(0,0,0,.28)"
	IF $GET(KEY)="high-contrast" DO  QUIT
	. SET OUT("key")="high-contrast",OUT("label")="High Contrast",OUT("mode")="dark"
	. SET OUT("accent")="#ffd400",OUT("accentSoft")="rgba(255,212,0,.20)",OUT("accentStrong")="rgba(255,212,0,.34)"
	. SET OUT("wallpaper")="contrast-grid",OUT("desktop")="#000000",OUT("surface")="rgba(10,10,10,.96)",OUT("surfaceAlt")="rgba(0,0,0,.92)"
	. SET OUT("border")="rgba(255,255,255,.34)",OUT("text")="#ffffff",OUT("muted")="#f2f2f2",OUT("icon")="linear-gradient(180deg,#ffd400,#c79d00)"
	. SET OUT("titleActive")="linear-gradient(180deg, #2b2b2b, #101010), linear-gradient(90deg,#ffd400, rgba(255,255,255,0.02) 30%)"
	. SET OUT("titleInactive")="linear-gradient(180deg,#2c2c2c,#161616)",OUT("shadow")="0 18px 44px rgba(0,0,0,.44)"
	QUIT
	;
CATALOG(ROOT)
	KILL @ROOT
	DO CATSET(ROOT,1,"midnight-professional")
	DO CATSET(ROOT,2,"slate-light")
	DO CATSET(ROOT,3,"clinical-blue")
	DO CATSET(ROOT,4,"surgical-teal")
	DO CATSET(ROOT,5,"high-contrast")
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
