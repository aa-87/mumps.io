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
	IF $GET(KEY)="midnight-professional" DO MIDNIGHT(.OUT) QUIT
	IF $GET(KEY)="slate-light" DO SLATELT(.OUT) QUIT
	IF $GET(KEY)="clinical-blue" DO CLINICAL(.OUT) QUIT
	IF $GET(KEY)="surgical-teal" DO SURGICAL(.OUT) QUIT
	IF $GET(KEY)="high-contrast" DO CONTRAST(.OUT) QUIT
	IF $GET(KEY)="paper-chart" DO PAPER(.OUT) QUIT
	IF $GET(KEY)="sterile-night" DO STERILE(.OUT) QUIT
	QUIT
	;
MIDNIGHT(OUT)
	DO BASE(.OUT,"midnight-professional","Midnight Professional","dark")
	SET OUT("accent")="#5f8dff"
	SET OUT("accentSoft")="rgba(95,141,255,.18)"
	SET OUT("accentStrong")="rgba(95,141,255,.34)"
	SET OUT("wallpaper")="midnight-clinic"
	SET OUT("desktop")="#0b1320"
	SET OUT("desktopGlow")="rgba(95,141,255,.12)"
	SET OUT("surface")="rgba(15,23,36,.95)"
	SET OUT("surfaceAlt")="rgba(11,18,29,.96)"
	SET OUT("surfaceRaised")="rgba(18,29,44,.98)"
	SET OUT("surfaceInset")="rgba(6,12,20,.72)"
	SET OUT("border")="rgba(148,163,184,.18)"
	SET OUT("borderStrong")="rgba(175,191,214,.28)"
	SET OUT("text")="#ecf3ff"
	SET OUT("muted")="#93a7c4"
	SET OUT("icon")="linear-gradient(180deg,#7ea6ff,#4a73e6)"
	SET OUT("iconText")="#ffffff"
	SET OUT("titleActive")="linear-gradient(180deg, rgba(255,255,255,0.12), rgba(255,255,255,0.03)), linear-gradient(90deg, #5f8dff, rgba(255,255,255,0.02) 38%)"
	SET OUT("titleInactive")="linear-gradient(180deg, rgba(91,103,122,0.42), rgba(45,56,72,0.36))"
	SET OUT("taskbar")="rgba(9,16,27,.92)"
	SET OUT("taskbarBorder")="rgba(255,255,255,.08)"
	SET OUT("menuSurface")="rgba(10,18,30,.96)"
	SET OUT("menuText")="#eef5ff"
	SET OUT("buttonFace")="linear-gradient(180deg,#244578,#163055)"
	SET OUT("buttonHover")="linear-gradient(180deg,#2d538e,#1a3963)"
	SET OUT("buttonText")="#eef5ff"
	SET OUT("inputFace")="rgba(8,15,24,.78)"
	SET OUT("inputBorder")="rgba(140,165,207,.18)"
	SET OUT("focusRing")="rgba(95,141,255,.34)"
	SET OUT("success")="#20b07c"
	SET OUT("warn")="#d4a514"
	SET OUT("danger")="#ef6b7a"
	SET OUT("info")="#60a5fa"
	SET OUT("gridHairline")="rgba(255,255,255,.06)"
	SET OUT("shadow")="0 18px 42px rgba(0,0,0,.26)"
	SET OUT("shadowSoft")="0 12px 28px rgba(0,0,0,.18)"
	QUIT
	;
SLATELT(OUT)
	DO BASE(.OUT,"slate-light","Slate Light","light")
	SET OUT("accent")="#2f6fed"
	SET OUT("accentSoft")="rgba(47,111,237,.14)"
	SET OUT("accentStrong")="rgba(47,111,237,.24)"
	SET OUT("wallpaper")="soft-grid"
	SET OUT("desktop")="#e8eef6"
	SET OUT("desktopGlow")="rgba(47,111,237,.10)"
	SET OUT("surface")="rgba(255,255,255,.95)"
	SET OUT("surfaceAlt")="rgba(248,250,253,.94)"
	SET OUT("surfaceRaised")="rgba(255,255,255,.98)"
	SET OUT("surfaceInset")="rgba(237,242,248,.92)"
	SET OUT("border")="rgba(90,115,150,.18)"
	SET OUT("borderStrong")="rgba(77,103,140,.28)"
	SET OUT("text")="#162435"
	SET OUT("muted")="#607286"
	SET OUT("icon")="linear-gradient(180deg,#5a8ff2,#2b63d4)"
	SET OUT("iconText")="#ffffff"
	SET OUT("titleActive")="linear-gradient(180deg,#ffffff,#e8effb)"
	SET OUT("titleInactive")="linear-gradient(180deg,#f4f7fb,#e8edf3)"
	SET OUT("taskbar")="rgba(235,240,246,.94)"
	SET OUT("taskbarBorder")="rgba(82,106,140,.16)"
	SET OUT("menuSurface")="rgba(255,255,255,.98)"
	SET OUT("menuText")="#172437"
	SET OUT("buttonFace")="linear-gradient(180deg,#ffffff,#e8effb)"
	SET OUT("buttonHover")="linear-gradient(180deg,#ffffff,#dfe9fb)"
	SET OUT("buttonText")="#214d9f"
	SET OUT("inputFace")="rgba(255,255,255,.98)"
	SET OUT("inputBorder")="rgba(97,119,150,.18)"
	SET OUT("focusRing")="rgba(47,111,237,.24)"
	SET OUT("success")="#1e9a63"
	SET OUT("warn")="#b37b08"
	SET OUT("danger")="#c14b59"
	SET OUT("info")="#2f6fed"
	SET OUT("gridHairline")="rgba(47,111,237,.08)"
	SET OUT("shadow")="0 16px 36px rgba(8,18,33,.18)"
	SET OUT("shadowSoft")="0 10px 24px rgba(8,18,33,.12)"
	QUIT
	;
CLINICAL(OUT)
	DO BASE(.OUT,"clinical-blue","Clinical Blue","light")
	SET OUT("accent")="#1384d7"
	SET OUT("accentSoft")="rgba(19,132,215,.16)"
	SET OUT("accentStrong")="rgba(19,132,215,.28)"
	SET OUT("wallpaper")="aurora-blue"
	SET OUT("desktop")="#dfeef8"
	SET OUT("desktopGlow")="rgba(19,132,215,.11)"
	SET OUT("surface")="rgba(255,255,255,.96)"
	SET OUT("surfaceAlt")="rgba(242,248,252,.94)"
	SET OUT("surfaceRaised")="rgba(255,255,255,.98)"
	SET OUT("surfaceInset")="rgba(228,241,248,.92)"
	SET OUT("border")="rgba(64,118,150,.18)"
	SET OUT("borderStrong")="rgba(32,95,132,.28)"
	SET OUT("text")="#143042"
	SET OUT("muted")="#5c7685"
	SET OUT("icon")="linear-gradient(180deg,#46a8ec,#0a74c6)"
	SET OUT("iconText")="#ffffff"
	SET OUT("titleActive")="linear-gradient(180deg,#ffffff,#edf7fd)"
	SET OUT("titleInactive")="linear-gradient(180deg,#eef6fb,#dfeef8)"
	SET OUT("taskbar")="rgba(233,244,250,.94)"
	SET OUT("taskbarBorder")="rgba(64,118,150,.18)"
	SET OUT("menuSurface")="rgba(255,255,255,.98)"
	SET OUT("menuText")="#113044"
	SET OUT("buttonFace")="linear-gradient(180deg,#ffffff,#edf7fd)"
	SET OUT("buttonHover")="linear-gradient(180deg,#ffffff,#dceffd)"
	SET OUT("buttonText")="#0a74c6"
	SET OUT("inputFace")="rgba(255,255,255,.98)"
	SET OUT("inputBorder")="rgba(64,118,150,.18)"
	SET OUT("focusRing")="rgba(19,132,215,.26)"
	SET OUT("success")="#129b74"
	SET OUT("warn")="#ad7a0b"
	SET OUT("danger")="#cc5565"
	SET OUT("info")="#1384d7"
	SET OUT("gridHairline")="rgba(19,132,215,.10)"
	SET OUT("shadow")="0 16px 36px rgba(7,62,96,.16)"
	SET OUT("shadowSoft")="0 10px 24px rgba(7,62,96,.10)"
	QUIT
	;
SURGICAL(OUT)
	DO BASE(.OUT,"surgical-teal","Surgical Teal","dark")
	SET OUT("accent")="#14b8a6"
	SET OUT("accentSoft")="rgba(20,184,166,.18)"
	SET OUT("accentStrong")="rgba(20,184,166,.30)"
	SET OUT("wallpaper")="aurora-blue"
	SET OUT("desktop")="#07141a"
	SET OUT("desktopGlow")="rgba(20,184,166,.10)"
	SET OUT("surface")="rgba(8,24,29,.95)"
	SET OUT("surfaceAlt")="rgba(6,18,23,.96)"
	SET OUT("surfaceRaised")="rgba(10,28,35,.98)"
	SET OUT("surfaceInset")="rgba(3,13,17,.76)"
	SET OUT("border")="rgba(89,161,154,.22)"
	SET OUT("borderStrong")="rgba(124,211,202,.28)"
	SET OUT("text")="#e7fcf8"
	SET OUT("muted")="#8ab4b0"
	SET OUT("icon")="linear-gradient(180deg,#2dd4bf,#0f766e)"
	SET OUT("iconText")="#052a28"
	SET OUT("titleActive")="linear-gradient(180deg, rgba(255,255,255,0.10), rgba(255,255,255,0.02)), linear-gradient(90deg,#14b8a6, rgba(255,255,255,0.02) 42%)"
	SET OUT("titleInactive")="linear-gradient(180deg, rgba(71,98,102,0.36), rgba(32,46,48,0.34))"
	SET OUT("taskbar")="rgba(5,17,22,.92)"
	SET OUT("taskbarBorder")="rgba(124,211,202,.10)"
	SET OUT("menuSurface")="rgba(5,19,24,.96)"
	SET OUT("menuText")="#ebfffb"
	SET OUT("buttonFace")="linear-gradient(180deg,#0d6f68,#0a5b55)"
	SET OUT("buttonHover")="linear-gradient(180deg,#12837a,#0c6d66)"
	SET OUT("buttonText")="#ebfffb"
	SET OUT("inputFace")="rgba(5,18,22,.82)"
	SET OUT("inputBorder")="rgba(124,211,202,.18)"
	SET OUT("focusRing")="rgba(20,184,166,.30)"
	SET OUT("success")="#2dd4bf"
	SET OUT("warn")="#f6c453"
	SET OUT("danger")="#fb7185"
	SET OUT("info")="#5eead4"
	SET OUT("gridHairline")="rgba(255,255,255,.06)"
	SET OUT("shadow")="0 18px 42px rgba(0,0,0,.28)"
	SET OUT("shadowSoft")="0 12px 28px rgba(0,0,0,.18)"
	QUIT
	;
CONTRAST(OUT)
	DO BASE(.OUT,"high-contrast","High Contrast","dark")
	SET OUT("accent")="#ffd400"
	SET OUT("accentSoft")="rgba(255,212,0,.20)"
	SET OUT("accentStrong")="rgba(255,212,0,.34)"
	SET OUT("wallpaper")="contrast-grid"
	SET OUT("desktop")="#000000"
	SET OUT("desktopGlow")="rgba(255,212,0,.08)"
	SET OUT("surface")="rgba(10,10,10,.96)"
	SET OUT("surfaceAlt")="rgba(0,0,0,.92)"
	SET OUT("surfaceRaised")="rgba(14,14,14,.98)"
	SET OUT("surfaceInset")="rgba(0,0,0,.96)"
	SET OUT("border")="rgba(255,255,255,.34)"
	SET OUT("borderStrong")="rgba(255,255,255,.48)"
	SET OUT("text")="#ffffff"
	SET OUT("muted")="#f2f2f2"
	SET OUT("icon")="linear-gradient(180deg,#ffd400,#c79d00)"
	SET OUT("iconText")="#000000"
	SET OUT("titleActive")="linear-gradient(180deg,#2b2b2b,#101010), linear-gradient(90deg,#ffd400, rgba(255,255,255,0.02) 30%)"
	SET OUT("titleInactive")="linear-gradient(180deg,#2c2c2c,#161616)"
	SET OUT("taskbar")="rgba(0,0,0,.94)"
	SET OUT("taskbarBorder")="rgba(255,255,255,.24)"
	SET OUT("menuSurface")="rgba(0,0,0,.98)"
	SET OUT("menuText")="#ffffff"
	SET OUT("buttonFace")="linear-gradient(180deg,#2b2b2b,#111111)"
	SET OUT("buttonHover")="linear-gradient(180deg,#3a3a3a,#191919)"
	SET OUT("buttonText")="#ffffff"
	SET OUT("inputFace")="rgba(0,0,0,.98)"
	SET OUT("inputBorder")="rgba(255,255,255,.34)"
	SET OUT("focusRing")="rgba(255,212,0,.38)"
	SET OUT("success")="#00ff84"
	SET OUT("warn")="#ffd400"
	SET OUT("danger")="#ff5470"
	SET OUT("info")="#87c5ff"
	SET OUT("gridHairline")="rgba(255,255,255,.14)"
	SET OUT("shadow")="0 18px 44px rgba(0,0,0,.44)"
	SET OUT("shadowSoft")="0 12px 30px rgba(0,0,0,.28)"
	QUIT
	;
PAPER(OUT)
	DO BASE(.OUT,"paper-chart","Paper Chart","light")
	SET OUT("accent")="#7a5c2e"
	SET OUT("accentSoft")="rgba(122,92,46,.12)"
	SET OUT("accentStrong")="rgba(122,92,46,.24)"
	SET OUT("wallpaper")="soft-grid"
	SET OUT("desktop")="#f2eee2"
	SET OUT("desktopGlow")="rgba(122,92,46,.08)"
	SET OUT("surface")="rgba(255,251,241,.96)"
	SET OUT("surfaceAlt")="rgba(248,243,231,.94)"
	SET OUT("surfaceRaised")="rgba(255,254,248,.98)"
	SET OUT("surfaceInset")="rgba(239,231,213,.92)"
	SET OUT("border")="rgba(143,119,80,.18)"
	SET OUT("borderStrong")="rgba(122,92,46,.26)"
	SET OUT("text")="#2f2418"
	SET OUT("muted")="#6f6357"
	SET OUT("icon")="linear-gradient(180deg,#c39a62,#8f6b3b)"
	SET OUT("iconText")="#ffffff"
	SET OUT("titleActive")="linear-gradient(180deg,#fffef8,#f2eee2)"
	SET OUT("titleInactive")="linear-gradient(180deg,#f8f4e7,#eee7d5)"
	SET OUT("taskbar")="rgba(244,239,228,.94)"
	SET OUT("taskbarBorder")="rgba(122,92,46,.14)"
	SET OUT("menuSurface")="rgba(255,252,245,.98)"
	SET OUT("menuText")="#302418"
	SET OUT("buttonFace")="linear-gradient(180deg,#fffef8,#efe6d3)"
	SET OUT("buttonHover")="linear-gradient(180deg,#fffef8,#e7dcc4)"
	SET OUT("buttonText")="#7a5c2e"
	SET OUT("inputFace")="rgba(255,255,250,.98)"
	SET OUT("inputBorder")="rgba(122,92,46,.18)"
	SET OUT("focusRing")="rgba(122,92,46,.22)"
	SET OUT("success")="#2d8a5c"
	SET OUT("warn")="#a66b00"
	SET OUT("danger")="#bf4d4d"
	SET OUT("info")="#6e81b6"
	SET OUT("gridHairline")="rgba(122,92,46,.08)"
	SET OUT("shadow")="0 16px 36px rgba(82,57,26,.12)"
	SET OUT("shadowSoft")="0 10px 24px rgba(82,57,26,.08)"
	QUIT
	;
STERILE(OUT)
	DO BASE(.OUT,"sterile-night","Sterile Night","dark")
	SET OUT("accent")="#7cc6ff"
	SET OUT("accentSoft")="rgba(124,198,255,.16)"
	SET OUT("accentStrong")="rgba(124,198,255,.26)"
	SET OUT("wallpaper")="slate-grid"
	SET OUT("desktop")="#101821"
	SET OUT("desktopGlow")="rgba(124,198,255,.08)"
	SET OUT("surface")="rgba(22,30,41,.96)"
	SET OUT("surfaceAlt")="rgba(16,24,33,.96)"
	SET OUT("surfaceRaised")="rgba(27,36,48,.98)"
	SET OUT("surfaceInset")="rgba(10,15,22,.78)"
	SET OUT("border")="rgba(160,184,208,.18)"
	SET OUT("borderStrong")="rgba(160,184,208,.28)"
	SET OUT("text")="#edf6ff"
	SET OUT("muted")="#a3b5c8"
	SET OUT("icon")="linear-gradient(180deg,#9ddaff,#5797d7)"
	SET OUT("iconText")="#0d1a24"
	SET OUT("titleActive")="linear-gradient(180deg, rgba(255,255,255,.12), rgba(255,255,255,.04)), linear-gradient(90deg,#7cc6ff, rgba(255,255,255,.02) 36%)"
	SET OUT("titleInactive")="linear-gradient(180deg, rgba(108,122,137,.40), rgba(53,67,82,.34))"
	SET OUT("taskbar")="rgba(13,19,27,.94)"
	SET OUT("taskbarBorder")="rgba(160,184,208,.12)"
	SET OUT("menuSurface")="rgba(15,23,32,.98)"
	SET OUT("menuText")="#edf6ff"
	SET OUT("buttonFace")="linear-gradient(180deg,#3e5d7c,#2b4258)"
	SET OUT("buttonHover")="linear-gradient(180deg,#4a6f93,#32506b)"
	SET OUT("buttonText")="#edf6ff"
	SET OUT("inputFace")="rgba(11,17,24,.82)"
	SET OUT("inputBorder")="rgba(160,184,208,.18)"
	SET OUT("focusRing")="rgba(124,198,255,.26)"
	SET OUT("success")="#48c78e"
	SET OUT("warn")="#f2b94b"
	SET OUT("danger")="#ff7d86"
	SET OUT("info")="#7cc6ff"
	SET OUT("gridHairline")="rgba(255,255,255,.06)"
	SET OUT("shadow")="0 18px 42px rgba(0,0,0,.30)"
	SET OUT("shadowSoft")="0 12px 28px rgba(0,0,0,.20)"
	QUIT
	;
BASE(OUT,KEY,LABEL,MODE)
	SET OUT("key")=$GET(KEY)
	SET OUT("label")=$GET(LABEL)
	SET OUT("mode")=$GET(MODE)
	SET OUT("previewTitle")=$GET(LABEL)
	SET OUT("previewBody")="Healthcare-ready shell with dense workspace chrome, readable forms, and permission-aware admin surfaces."
	QUIT
	;
CATALOG(ROOT)
	KILL @ROOT
	DO CATSET(ROOT,1,"midnight-professional")
	DO CATSET(ROOT,2,"slate-light")
	DO CATSET(ROOT,3,"clinical-blue")
	DO CATSET(ROOT,4,"surgical-teal")
	DO CATSET(ROOT,5,"high-contrast")
	DO CATSET(ROOT,6,"paper-chart")
	DO CATSET(ROOT,7,"sterile-night")
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
