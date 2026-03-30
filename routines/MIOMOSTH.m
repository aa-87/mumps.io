MIOMOSTH ; MIOMOS theme catalog and preferences
	QUIT
	;
CURRENT(STATE,CONF)
	NEW KEY,USER
	SET USER=$GET(STATE("principal"))
	SET KEY=$GET(^MIO("MIOMOS","PREF",USER,"theme"))
	IF $$VALID(KEY) QUIT KEY
	SET KEY=$GET(CONF("miomos","theme","default"),"clinical-blue")
	IF $$VALID(KEY) QUIT KEY
	QUIT "clinical-blue"
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
	SET KEY=$GET(KEY)
	IF KEY="midnight-professional" DO MIDNIGHT(.OUT) QUIT
	IF KEY="slate-light" DO SLATELIGHT(.OUT) QUIT
	IF KEY="clinical-blue" DO CLINICAL(.OUT) QUIT
	IF KEY="surgical-teal" DO SURGICAL(.OUT) QUIT
	IF KEY="high-contrast" DO CONTRAST(.OUT) QUIT
	IF KEY="high-contrast-light" DO CONTRASTL(.OUT) QUIT
	IF KEY="violet-dusk" DO VIOLET(.OUT) QUIT
	IF KEY="xp-olive" DO XPOLIVE(.OUT) QUIT
	IF KEY="xp-silver" DO XPSILVER(.OUT) QUIT
	QUIT
	;
MIDNIGHT(OUT)
	SET OUT("key")="midnight-professional",OUT("label")="Midnight Professional",OUT("mode")="dark",OUT("family")="7.css Noir",OUT("story")="Dark flagship palette for long operational sessions.",OUT("chrome")="glass"
	SET OUT("accent")="#5f8dff",OUT("accentSoft")="rgba(95,141,255,.18)",OUT("accentStrong")="rgba(95,141,255,.34)"
	SET OUT("wallpaper")="midnight-clinic",OUT("desktop")="#0b1320",OUT("surface")="rgba(15,23,36,.95)",OUT("surfaceAlt")="rgba(11,18,29,.96)",OUT("surfaceSoft")="rgba(19,28,43,.90)"
	SET OUT("border")="rgba(166,182,204,.28)",OUT("text")="#f1f6ff",OUT("muted")="#b8c7dc",OUT("icon")="linear-gradient(180deg,#7ea6ff,#4a73e6)"
	SET OUT("titleActive")="linear-gradient(180deg, rgba(255,255,255,0.12), rgba(255,255,255,0.03)), linear-gradient(90deg, #5f8dff, rgba(255,255,255,0.02) 38%)"
	SET OUT("titleInactive")="linear-gradient(180deg, rgba(91,103,122,0.42), rgba(45,56,72,0.36))"
	SET OUT("shadow")="0 18px 42px rgba(0,0,0,.26)"
	DO SHELLNIGHT(.OUT)
	QUIT
	;
SLATELIGHT(OUT)
	SET OUT("key")="slate-light",OUT("label")="Slate Light",OUT("mode")="light",OUT("family")="7.css Porcelain",OUT("story")="Bright clinical shell with restrained blue-gray chrome and darker body text.",OUT("chrome")="solid"
	SET OUT("accent")="#2f6fed",OUT("accentSoft")="rgba(47,111,237,.14)",OUT("accentStrong")="rgba(47,111,237,.24)"
	SET OUT("wallpaper")="soft-grid",OUT("desktop")="#e8eef6",OUT("surface")="rgba(255,255,255,.97)",OUT("surfaceAlt")="rgba(244,247,251,.96)",OUT("surfaceSoft")="rgba(234,240,247,.92)"
	SET OUT("border")="rgba(48,78,112,.30)",OUT("text")="#081b2d",OUT("muted")="#36506c",OUT("icon")="linear-gradient(180deg,#5a8ff2,#2b63d4)"
	SET OUT("titleActive")="linear-gradient(180deg,#ffffff,#e8effb)",OUT("titleInactive")="linear-gradient(180deg,#f3f6fa,#e4eaf1)",OUT("shadow")="0 16px 36px rgba(8,18,33,.18)"
	DO SHELLLIGHT(.OUT)
	QUIT
	;
CLINICAL(OUT)
	SET OUT("key")="clinical-blue",OUT("label")="Clinical Blue",OUT("mode")="light",OUT("family")="7.css Classic",OUT("story")="Classic Windows XP blue shell with tuned daytime contrast for long MUMPS development sessions.",OUT("chrome")="accent"
	SET OUT("accent")="#1384d7",OUT("accentSoft")="rgba(19,132,215,.16)",OUT("accentStrong")="rgba(19,132,215,.28)"
	SET OUT("wallpaper")="aurora-blue",OUT("desktop")="#dfeef8",OUT("surface")="rgba(255,255,255,.97)",OUT("surfaceAlt")="rgba(241,247,252,.95)",OUT("surfaceSoft")="rgba(231,240,247,.92)"
	SET OUT("border")="rgba(41,84,117,.30)",OUT("text")="#0a2234",OUT("muted")="#34536b",OUT("icon")="linear-gradient(180deg,#46a8ec,#0a74c6)"
	SET OUT("titleActive")="linear-gradient(180deg,#ffffff,#edf7fd)",OUT("titleInactive")="linear-gradient(180deg,#edf5fa,#d8e8f4)",OUT("shadow")="0 16px 36px rgba(7,62,96,.16)"
	DO SHELLXPBLUE(.OUT)
	QUIT
	;
SURGICAL(OUT)
	SET OUT("key")="surgical-teal",OUT("label")="Surgical Teal",OUT("mode")="dark",OUT("family")="7.css Surgical",OUT("story")="Cool green-dark chrome tuned for dense workstation tasks.",OUT("chrome")="accent"
	SET OUT("accent")="#14b8a6",OUT("accentSoft")="rgba(20,184,166,.18)",OUT("accentStrong")="rgba(20,184,166,.30)"
	SET OUT("wallpaper")="aurora-blue",OUT("desktop")="#07141a",OUT("surface")="rgba(8,24,29,.95)",OUT("surfaceAlt")="rgba(6,18,23,.96)",OUT("surfaceSoft")="rgba(10,31,37,.90)"
	SET OUT("border")="rgba(98,171,163,.28)",OUT("text")="#eefefb",OUT("muted")="#b4d3d0",OUT("icon")="linear-gradient(180deg,#2dd4bf,#0f766e)"
	SET OUT("titleActive")="linear-gradient(180deg, rgba(255,255,255,0.10), rgba(255,255,255,0.02)), linear-gradient(90deg,#14b8a6, rgba(255,255,255,0.02) 42%)"
	SET OUT("titleInactive")="linear-gradient(180deg, rgba(71,98,102,0.36), rgba(32,46,48,0.34))",OUT("shadow")="0 18px 42px rgba(0,0,0,.28)"
	DO SHELLTEAL(.OUT)
	QUIT
	;
CONTRAST(OUT)
	SET OUT("key")="high-contrast",OUT("label")="High Contrast",OUT("mode")="dark",OUT("family")="7.css Contrast",OUT("story")="High-legibility palette for accessibility-sensitive users.",OUT("chrome")="contrast"
	SET OUT("accent")="#ffd400",OUT("accentSoft")="rgba(255,212,0,.20)",OUT("accentStrong")="rgba(255,212,0,.34)"
	SET OUT("wallpaper")="contrast-grid",OUT("desktop")="#000000",OUT("surface")="rgba(10,10,10,.96)",OUT("surfaceAlt")="rgba(0,0,0,.92)",OUT("surfaceSoft")="rgba(20,20,20,.94)"
	SET OUT("border")="rgba(255,255,255,.34)",OUT("text")="#ffffff",OUT("muted")="#f2f2f2",OUT("icon")="linear-gradient(180deg,#ffd400,#c79d00)"
	SET OUT("titleActive")="linear-gradient(180deg, #2b2b2b, #101010), linear-gradient(90deg,#ffd400, rgba(255,255,255,0.02) 30%)"
	SET OUT("titleInactive")="linear-gradient(180deg,#2c2c2c,#161616)",OUT("shadow")="0 18px 44px rgba(0,0,0,.44)"
	DO SHELLCONTRAST(.OUT)
	QUIT
	;
CONTRASTL(OUT)
	SET OUT("key")="high-contrast-light",OUT("label")="High Contrast Light",OUT("mode")="light",OUT("family")="7.css Contrast Light",OUT("story")="Bright accessibility-first palette with dark text, bright surfaces, and assertive outlines.",OUT("chrome")="contrast"
	SET OUT("accent")="#0b57d0",OUT("accentSoft")="rgba(11,87,208,.14)",OUT("accentStrong")="rgba(11,87,208,.24)"
	SET OUT("wallpaper")="soft-grid",OUT("desktop")="#f3f7fb",OUT("surface")="rgba(255,255,255,.99)",OUT("surfaceAlt")="rgba(247,250,253,.98)",OUT("surfaceSoft")="rgba(237,243,249,.94)"
	SET OUT("border")="rgba(18,31,46,.30)",OUT("text")="#07131f",OUT("muted")="#23384f",OUT("icon")="linear-gradient(180deg,#1d6de2,#0b57d0)"
	SET OUT("titleActive")="linear-gradient(180deg,#ffffff,#edf4fb)",OUT("titleInactive")="linear-gradient(180deg,#f8fbff,#e7eef6)",OUT("shadow")="0 16px 34px rgba(8,18,33,.16)"
	DO SHELLLIGHTCONTRAST(.OUT)
	QUIT
	;
VIOLET(OUT)
	SET OUT("key")="violet-dusk",OUT("label")="Violet Dusk",OUT("mode")="dark",OUT("family")="MIOMOS Modern",OUT("story")="A softer modern palette for design review and library work.",OUT("chrome")="glass"
	SET OUT("accent")="#8b5cf6",OUT("accentSoft")="rgba(139,92,246,.18)",OUT("accentStrong")="rgba(139,92,246,.30)"
	SET OUT("wallpaper")="midnight-clinic",OUT("desktop")="#110f1d",OUT("surface")="rgba(21,18,36,.95)",OUT("surfaceAlt")="rgba(17,15,29,.96)",OUT("surfaceSoft")="rgba(28,22,45,.92)"
	SET OUT("border")="rgba(183,168,255,.26)",OUT("text")="#f7f2ff",OUT("muted")="#cdc2e8",OUT("icon")="linear-gradient(180deg,#a78bfa,#7c3aed)"
	SET OUT("titleActive")="linear-gradient(180deg, rgba(255,255,255,0.10), rgba(255,255,255,0.02)), linear-gradient(90deg,#8b5cf6, rgba(255,255,255,0.02) 42%)"
	SET OUT("titleInactive")="linear-gradient(180deg, rgba(94,82,134,0.36), rgba(53,43,80,0.34))",OUT("shadow")="0 18px 44px rgba(5,3,12,.30)"
	DO SHELLVIOLET(.OUT)
	QUIT
	;
XPOLIVE(OUT)
	SET OUT("key")="xp-olive",OUT("label")="XP Olive",OUT("mode")="light",OUT("family")="Windows XP Olive",OUT("story")="Olive-green XP shell tuned for warm taskbar chrome and crisp daytime text.",OUT("chrome")="accent"
	SET OUT("accent")="#7a9b2d",OUT("accentSoft")="rgba(122,155,45,.16)",OUT("accentStrong")="rgba(122,155,45,.28)"
	SET OUT("wallpaper")="soft-grid",OUT("desktop")="#e7efe0",OUT("surface")="rgba(255,255,255,.97)",OUT("surfaceAlt")="rgba(245,248,240,.95)",OUT("surfaceSoft")="rgba(235,241,228,.92)"
	SET OUT("border")="rgba(77,98,46,.28)",OUT("text")="#1d2b12",OUT("muted")="#4e5f38",OUT("icon")="linear-gradient(180deg,#a9c76c,#799635)"
	SET OUT("titleActive")="linear-gradient(180deg,#fffef6,#f4f0dd)",OUT("titleInactive")="linear-gradient(180deg,#f2f1e8,#e1e0d6)",OUT("shadow")="0 16px 36px rgba(53,68,31,.18)"
	DO SHELLXPOLIVE(.OUT)
	QUIT
	;
XPSILVER(OUT)
	SET OUT("key")="xp-silver",OUT("label")="XP Silver",OUT("mode")="light",OUT("family")="Windows XP Silver",OUT("story")="Cool silver XP shell for review stations and multi-window administration.",OUT("chrome")="solid"
	SET OUT("accent")="#6a84bf",OUT("accentSoft")="rgba(106,132,191,.16)",OUT("accentStrong")="rgba(106,132,191,.26)"
	SET OUT("wallpaper")="soft-grid",OUT("desktop")="#e9edf5",OUT("surface")="rgba(255,255,255,.97)",OUT("surfaceAlt")="rgba(243,246,251,.95)",OUT("surfaceSoft")="rgba(234,239,247,.92)"
	SET OUT("border")="rgba(76,91,122,.28)",OUT("text")="#172235",OUT("muted")="#4a5a78",OUT("icon")="linear-gradient(180deg,#9cb2e6,#677fb5)"
	SET OUT("titleActive")="linear-gradient(180deg,#ffffff,#eef2fb)",OUT("titleInactive")="linear-gradient(180deg,#f4f6fb,#e1e5ef)",OUT("shadow")="0 16px 36px rgba(50,64,94,.18)"
	DO SHELLXPSILVER(.OUT)
	QUIT
	;
SHELLNIGHT(OUT)
	SET OUT("shellChromeFont")="Tahoma"
	SET OUT("shellTaskbar")="linear-gradient(180deg,#1e2d4a 0%, #18253b 54%, #101a2c 100%)"
	SET OUT("shellTaskbarBorderTop")="rgba(149,181,255,.30)"
	SET OUT("shellStartButton")="linear-gradient(180deg,#4f7ce0 0%, #335db7 55%, #24458a 100%)"
	SET OUT("shellStartButtonBorder")="rgba(11,27,68,.64)",OUT("shellStartButtonText")="#f5f8ff",OUT("shellQuickLaunchLabel")="#d5e4ff"
	SET OUT("shellTaskActive")="linear-gradient(180deg,#8fb8ff 0%, #6794ea 48%, #426fca 100%)",OUT("shellTaskActiveText")="#f5f8ff"
	SET OUT("shellMenuFrame")="linear-gradient(180deg,#355ea7 0%, #16387a 100%)",OUT("shellMenuBanner")="linear-gradient(180deg,#3f74c6 0%, #224e9d 100%)",OUT("shellMenuBannerText")="#f5f9ff"
	SET OUT("shellMenuBody")="linear-gradient(90deg,#f7fbff 0 70%, #dbe7ff 70% 71%, #2b3f68 71% 100%)",OUT("shellMenuMain")="rgba(246,250,255,.98)",OUT("shellMenuSide")="linear-gradient(180deg,#22365c,#15243d)"
	SET OUT("shellMenuSideBorder")="rgba(132,161,226,.24)",OUT("shellMenuFooter")="linear-gradient(180deg,#335fa9 0%, #194286 100%)"
	SET OUT("shellWindowControl")="linear-gradient(180deg,#f7fbff,#c9dcff)",OUT("shellWindowControlBorder")="rgba(24,52,110,.42)",OUT("shellWindowControlText")="#143671",OUT("shellWindowControlDanger")="#c83b39"
	SET OUT("shellWindowActiveText")="#f9fbff",OUT("shellWindowInactiveText")="#d8e2f4"
	SET OUT("shellContextMenu")="linear-gradient(180deg,#f7fbff,#ebf3ff)",OUT("shellContextMenuBorder")="#365f9f",OUT("shellContextMenuText")="#143360"
	SET OUT("shellExplorerToolbar")="linear-gradient(180deg,#eef4ff 0%, #dbe7ff 100%)",OUT("shellExplorerPane")="linear-gradient(180deg,#203353,#17263f)",OUT("shellExplorerContent")="rgba(9,17,28,.90)"
	SET OUT("shellExplorerBorder")="rgba(116,145,202,.32)",OUT("shellExplorerText")="#edf4ff",OUT("shellExplorerMuted")="#b8cae6",OUT("shellExplorerSelection")="linear-gradient(180deg,#5e8ef2 0%, #3b69c9 100%)"
	SET OUT("shellExplorerSelectionBorder")="rgba(163,196,255,.38)",OUT("shellExplorerGlyph")="#d8e6ff"
	SET OUT("shellDialogFrame")="linear-gradient(180deg,#f5f9ff,#e4eefc)",OUT("shellDialogBorder")="#21488f",OUT("shellDialogHeader")="linear-gradient(180deg,#3667ba 0%, #22488e 100%)"
	SET OUT("shellDialogHeaderText")="#ffffff",OUT("shellDialogBodyText")="#1a355d"
	QUIT
	;
SHELLLIGHT(OUT)
	SET OUT("shellChromeFont")="Tahoma"
	SET OUT("shellTaskbar")="linear-gradient(180deg,#4894ea 0%, #2f74d6 48%, #235dbd 100%)"
	SET OUT("shellTaskbarBorderTop")="rgba(255,255,255,.46)"
	SET OUT("shellStartButton")="linear-gradient(180deg,#4ec64e 0%, #2d962d 58%, #207220 100%)"
	SET OUT("shellStartButtonBorder")="rgba(34,96,31,.62)",OUT("shellStartButtonText")="#f8fff8",OUT("shellQuickLaunchLabel")="#f0f6ff"
	SET OUT("shellTaskActive")="linear-gradient(180deg,#ffd970 0%, #f5c84c 48%, #d9a82d 100%)",OUT("shellTaskActiveText")="#253142"
	SET OUT("shellMenuFrame")="linear-gradient(180deg,#2d74e0 0%, #0d4ea9 100%)",OUT("shellMenuBanner")="linear-gradient(180deg,#2d74e0 0%, #0d4ea9 100%)",OUT("shellMenuBannerText")="#ffffff"
	SET OUT("shellMenuBody")="linear-gradient(90deg,#ffffff 0 72%, #d9e8ff 72% 73%, #f3e0a4 73% 100%)",OUT("shellMenuMain")="rgba(255,255,255,.96)",OUT("shellMenuSide")="linear-gradient(180deg,#f7eec4,#f2d689)"
	SET OUT("shellMenuSideBorder")="rgba(157,126,28,.28)",OUT("shellMenuFooter")="linear-gradient(180deg,#2d74e0 0%, #1751b5 100%)"
	SET OUT("shellWindowControl")="linear-gradient(180deg,#fff5eb,#f1c88c)",OUT("shellWindowControlBorder")="rgba(9,35,91,.38)",OUT("shellWindowControlText")="#6a2d00",OUT("shellWindowControlDanger")="#ba2f1e"
	SET OUT("shellWindowActiveText")="#ffffff",OUT("shellWindowInactiveText")="#375176"
	SET OUT("shellContextMenu")="linear-gradient(180deg,#ffffff,#eef4ff)",OUT("shellContextMenuBorder")="#295ba9",OUT("shellContextMenuText")="#18385c"
	SET OUT("shellExplorerToolbar")="linear-gradient(180deg,#ffffff 0%, #eef4ff 100%)",OUT("shellExplorerPane")="linear-gradient(180deg,#f7f3d8,#efe1a5)",OUT("shellExplorerContent")="rgba(255,255,255,.98)"
	SET OUT("shellExplorerBorder")="rgba(54,94,158,.28)",OUT("shellExplorerText")="#18324d",OUT("shellExplorerMuted")="#4d617e",OUT("shellExplorerSelection")="linear-gradient(180deg,#cfe6ff 0%, #9bc5fb 100%)"
	SET OUT("shellExplorerSelectionBorder")="rgba(44,97,171,.38)",OUT("shellExplorerGlyph")="#295fae"
	SET OUT("shellDialogFrame")="linear-gradient(180deg,#f7fbff 0%, #e8f0fb 100%)",OUT("shellDialogBorder")="#0c3a9a",OUT("shellDialogHeader")="linear-gradient(180deg,#2d74e0 0%, #0d4ea9 100%)"
	SET OUT("shellDialogHeaderText")="#ffffff",OUT("shellDialogBodyText")="#19375f"
	QUIT
	;
SHELLXPBLUE(OUT)
	DO SHELLLIGHT(.OUT)
	SET OUT("shellTaskbar")="linear-gradient(180deg,#4aa1f0 0%, #2578d9 48%, #1a5bb4 100%)"
	SET OUT("shellTaskbarBorderTop")="rgba(255,255,255,.56)"
	SET OUT("shellStartButton")="linear-gradient(180deg,#5bd55b 0%, #38a838 55%, #247f24 100%)"
	SET OUT("shellStartButtonBorder")="rgba(28,88,22,.64)"
	SET OUT("shellMenuFrame")="linear-gradient(180deg,#3184e7 0%, #0d58b8 100%)"
	SET OUT("shellMenuBanner")="linear-gradient(180deg,#3184e7 0%, #0d58b8 100%)"
	SET OUT("shellMenuFooter")="linear-gradient(180deg,#3184e7 0%, #1a60be 100%)"
	SET OUT("shellExplorerToolbar")="linear-gradient(180deg,#ffffff 0%, #ebf4ff 100%)"
	SET OUT("shellExplorerSelection")="linear-gradient(180deg,#d7ebff 0%, #a8d0ff 100%)"
	QUIT
	;
SHELLXPOLIVE(OUT)
	DO SHELLLIGHT(.OUT)
	SET OUT("shellTaskbar")="linear-gradient(180deg,#9db36d 0%, #7a8f4a 48%, #62743a 100%)"
	SET OUT("shellTaskbarBorderTop")="rgba(255,255,255,.44)"
	SET OUT("shellStartButton")="linear-gradient(180deg,#c9d86a 0%, #9cad3d 54%, #78862d 100%)"
	SET OUT("shellStartButtonBorder")="rgba(85,96,29,.62)",OUT("shellStartButtonText")="#22300f"
	SET OUT("shellQuickLaunchLabel")="#f7f8ea"
	SET OUT("shellMenuFrame")="linear-gradient(180deg,#879c50 0%, #67773a 100%)",OUT("shellMenuBanner")="linear-gradient(180deg,#879c50 0%, #67773a 100%)",OUT("shellMenuBannerText")="#fbfff4"
	SET OUT("shellMenuBody")="linear-gradient(90deg,#ffffff 0 72%, #e9eed5 72% 73%, #f1e6b9 73% 100%)",OUT("shellMenuSide")="linear-gradient(180deg,#f2edca,#dfd3a0)"
	SET OUT("shellMenuSideBorder")="rgba(116,108,43,.24)",OUT("shellMenuFooter")="linear-gradient(180deg,#879c50 0%, #6e8040 100%)"
	SET OUT("shellWindowControl")="linear-gradient(180deg,#fffce8,#e8dbac)",OUT("shellWindowControlBorder")="rgba(95,93,37,.34)",OUT("shellWindowControlText")="#5a4c10"
	SET OUT("shellContextMenuBorder")="#718343",OUT("shellContextMenuText")="#31411a"
	SET OUT("shellExplorerToolbar")="linear-gradient(180deg,#fffffb 0%, #f3f0df 100%)",OUT("shellExplorerPane")="linear-gradient(180deg,#f7f1d4,#e3d7a8)",OUT("shellExplorerContent")="rgba(255,255,255,.98)"
	SET OUT("shellExplorerBorder")="rgba(97,112,55,.26)",OUT("shellExplorerText")="#2e3b1c",OUT("shellExplorerMuted")="#5b6a43",OUT("shellExplorerSelection")="linear-gradient(180deg,#e8f0bf 0%, #c8d67d 100%)"
	SET OUT("shellExplorerSelectionBorder")="rgba(110,127,44,.34)",OUT("shellExplorerGlyph")="#6e8340"
	SET OUT("shellDialogBorder")="#68793d",OUT("shellDialogHeader")="linear-gradient(180deg,#879c50 0%, #67773a 100%)",OUT("shellDialogHeaderText")="#fbfff4",OUT("shellDialogBodyText")="#304019"
	QUIT
	;
SHELLXPSILVER(OUT)
	DO SHELLLIGHT(.OUT)
	SET OUT("shellTaskbar")="linear-gradient(180deg,#b9bfd1 0%, #8e97b3 48%, #757e9f 100%)"
	SET OUT("shellTaskbarBorderTop")="rgba(255,255,255,.54)"
	SET OUT("shellStartButton")="linear-gradient(180deg,#9fd0ff 0%, #6e9fd1 54%, #5178a8 100%)"
	SET OUT("shellStartButtonBorder")="rgba(62,87,132,.58)"
	SET OUT("shellMenuFrame")="linear-gradient(180deg,#7a86b5 0%, #5d6997 100%)",OUT("shellMenuBanner")="linear-gradient(180deg,#7a86b5 0%, #5d6997 100%)"
	SET OUT("shellMenuBody")="linear-gradient(90deg,#ffffff 0 72%, #e4e8f4 72% 73%, #ddd3e8 73% 100%)",OUT("shellMenuSide")="linear-gradient(180deg,#ece7f5,#d8cee6)"
	SET OUT("shellMenuSideBorder")="rgba(103,92,132,.22)",OUT("shellMenuFooter")="linear-gradient(180deg,#7a86b5 0%, #6170a4 100%)"
	SET OUT("shellWindowControl")="linear-gradient(180deg,#fff8ff,#ddd6ef)",OUT("shellWindowControlBorder")="rgba(76,78,118,.34)",OUT("shellWindowControlText")="#483f6d"
	SET OUT("shellContextMenuBorder")="#65729f",OUT("shellContextMenuText")="#253352"
	SET OUT("shellExplorerToolbar")="linear-gradient(180deg,#ffffff 0%, #eef2fb 100%)",OUT("shellExplorerPane")="linear-gradient(180deg,#f3effa,#dfd8ea)",OUT("shellExplorerContent")="rgba(255,255,255,.98)"
	SET OUT("shellExplorerBorder")="rgba(98,108,143,.26)",OUT("shellExplorerText")="#253352",OUT("shellExplorerMuted")="#596989",OUT("shellExplorerSelection")="linear-gradient(180deg,#dbe5ff 0%, #b5c6ee 100%)"
	SET OUT("shellExplorerSelectionBorder")="rgba(88,103,153,.34)",OUT("shellExplorerGlyph")="#6779b8"
	SET OUT("shellDialogBorder")="#6271a0",OUT("shellDialogHeader")="linear-gradient(180deg,#7a86b5 0%, #5d6997 100%)",OUT("shellDialogHeaderText")="#ffffff",OUT("shellDialogBodyText")="#253552"
	QUIT
	;
SHELLTEAL(OUT)
	DO SHELLNIGHT(.OUT)
	SET OUT("shellTaskbar")="linear-gradient(180deg,#1b665e 0%, #154e48 52%, #103a35 100%)"
	SET OUT("shellTaskbarBorderTop")="rgba(155,240,228,.22)"
	SET OUT("shellStartButton")="linear-gradient(180deg,#2fd2bb 0%, #1ca18f 56%, #137465 100%)"
	SET OUT("shellStartButtonBorder")="rgba(6,63,56,.62)",OUT("shellQuickLaunchLabel")="#d7fff9"
	SET OUT("shellMenuFrame")="linear-gradient(180deg,#1f877b 0%, #14564e 100%)",OUT("shellMenuBanner")="linear-gradient(180deg,#1f877b 0%, #14564e 100%)"
	SET OUT("shellMenuBody")="linear-gradient(90deg,#f8fffd 0 70%, #daf6f1 70% 71%, #143531 71% 100%)",OUT("shellMenuSide")="linear-gradient(180deg,#143d38,#0d2b28)"
	SET OUT("shellMenuFooter")="linear-gradient(180deg,#1f877b 0%, #165d55 100%)"
	SET OUT("shellExplorerToolbar")="linear-gradient(180deg,#f6fffd 0%, #dff7f2 100%)",OUT("shellExplorerPane")="linear-gradient(180deg,#153a36,#0f2b28)",OUT("shellExplorerContent")="rgba(8,24,29,.94)"
	SET OUT("shellExplorerSelection")="linear-gradient(180deg,#9de6dd 0%, #57c2b5 100%)",OUT("shellExplorerSelectionBorder")="rgba(87,194,181,.34)"
	SET OUT("shellDialogBorder")="#14645b",OUT("shellDialogHeader")="linear-gradient(180deg,#1f877b 0%, #14564e 100%)"
	QUIT
	;
SHELLCONTRAST(OUT)
	SET OUT("shellChromeFont")="Tahoma"
	SET OUT("shellTaskbar")="linear-gradient(180deg,#181818 0%, #080808 100%)",OUT("shellTaskbarBorderTop")="#ffffff"
	SET OUT("shellStartButton")="linear-gradient(180deg,#ffd400 0%, #d0a700 100%)",OUT("shellStartButtonBorder")="#ffffff",OUT("shellStartButtonText")="#000000",OUT("shellQuickLaunchLabel")="#ffffff"
	SET OUT("shellTaskActive")="linear-gradient(180deg,#ffffff 0%, #d8d8d8 100%)",OUT("shellTaskActiveText")="#000000"
	SET OUT("shellMenuFrame")="linear-gradient(180deg,#111111 0%, #000000 100%)",OUT("shellMenuBanner")="linear-gradient(180deg,#111111 0%, #000000 100%)",OUT("shellMenuBannerText")="#ffffff"
	SET OUT("shellMenuBody")="linear-gradient(90deg,#ffffff 0 72%, #f0f0f0 72% 73%, #000000 73% 100%)",OUT("shellMenuMain")="#ffffff",OUT("shellMenuSide")="#000000"
	SET OUT("shellMenuSideBorder")="#ffffff",OUT("shellMenuFooter")="linear-gradient(180deg,#111111 0%, #000000 100%)"
	SET OUT("shellWindowControl")="linear-gradient(180deg,#ffffff,#dedede)",OUT("shellWindowControlBorder")="#000000",OUT("shellWindowControlText")="#000000",OUT("shellWindowControlDanger")="#ff3b30"
	SET OUT("shellWindowActiveText")="#ffffff",OUT("shellWindowInactiveText")="#ffffff"
	SET OUT("shellContextMenu")="#ffffff",OUT("shellContextMenuBorder")="#000000",OUT("shellContextMenuText")="#000000"
	SET OUT("shellExplorerToolbar")="#ffffff",OUT("shellExplorerPane")="#000000",OUT("shellExplorerContent")="#000000"
	SET OUT("shellExplorerBorder")="#ffffff",OUT("shellExplorerText")="#ffffff",OUT("shellExplorerMuted")="#ffffff",OUT("shellExplorerSelection")="#ffd400",OUT("shellExplorerSelectionBorder")="#ffffff",OUT("shellExplorerGlyph")="#ffd400"
	SET OUT("shellDialogFrame")="#ffffff",OUT("shellDialogBorder")="#000000",OUT("shellDialogHeader")="#000000",OUT("shellDialogHeaderText")="#ffffff",OUT("shellDialogBodyText")="#000000"
	QUIT
	;
SHELLLIGHTCONTRAST(OUT)
	SET OUT("shellChromeFont")="Tahoma"
	SET OUT("shellTaskbar")="linear-gradient(180deg,#ffffff 0%, #eceff5 100%)",OUT("shellTaskbarBorderTop")="#0f172a"
	SET OUT("shellStartButton")="linear-gradient(180deg,#0b57d0 0%, #093a88 100%)",OUT("shellStartButtonBorder")="#0f172a",OUT("shellStartButtonText")="#ffffff",OUT("shellQuickLaunchLabel")="#0f172a"
	SET OUT("shellTaskActive")="linear-gradient(180deg,#ffd400 0%, #d1ad00 100%)",OUT("shellTaskActiveText")="#000000"
	SET OUT("shellMenuFrame")="linear-gradient(180deg,#ffffff 0%, #edf4fb 100%)",OUT("shellMenuBanner")="linear-gradient(180deg,#0b57d0 0%, #093a88 100%)",OUT("shellMenuBannerText")="#ffffff"
	SET OUT("shellMenuBody")="linear-gradient(90deg,#ffffff 0 72%, #f3f6fb 72% 73%, #dfe8f6 73% 100%)",OUT("shellMenuMain")="#ffffff",OUT("shellMenuSide")="#f3f6fb"
	SET OUT("shellMenuSideBorder")="#0f172a",OUT("shellMenuFooter")="linear-gradient(180deg,#ffffff 0%, #edf4fb 100%)"
	SET OUT("shellWindowControl")="linear-gradient(180deg,#ffffff,#e7eef6)",OUT("shellWindowControlBorder")="#0f172a",OUT("shellWindowControlText")="#0f172a",OUT("shellWindowControlDanger")="#c62828"
	SET OUT("shellWindowActiveText")="#ffffff",OUT("shellWindowInactiveText")="#0f172a"
	SET OUT("shellContextMenu")="#ffffff",OUT("shellContextMenuBorder")="#0f172a",OUT("shellContextMenuText")="#07131f"
	SET OUT("shellExplorerToolbar")="#ffffff",OUT("shellExplorerPane")="#f3f6fb",OUT("shellExplorerContent")="#ffffff"
	SET OUT("shellExplorerBorder")="#0f172a",OUT("shellExplorerText")="#07131f",OUT("shellExplorerMuted")="#23384f",OUT("shellExplorerSelection")="#d6e7ff",OUT("shellExplorerSelectionBorder")="#0b57d0",OUT("shellExplorerGlyph")="#0b57d0"
	SET OUT("shellDialogFrame")="#ffffff",OUT("shellDialogBorder")="#0f172a",OUT("shellDialogHeader")="linear-gradient(180deg,#0b57d0 0%, #093a88 100%)",OUT("shellDialogHeaderText")="#ffffff",OUT("shellDialogBodyText")="#07131f"
	QUIT
	;
SHELLVIOLET(OUT)
	DO SHELLNIGHT(.OUT)
	SET OUT("shellTaskbar")="linear-gradient(180deg,#5d4db5 0%, #463791 52%, #31256e 100%)"
	SET OUT("shellTaskbarBorderTop")="rgba(221,206,255,.26)"
	SET OUT("shellStartButton")="linear-gradient(180deg,#ad8cff 0%, #845ee2 56%, #6635cf 100%)"
	SET OUT("shellStartButtonBorder")="rgba(51,28,107,.62)"
	SET OUT("shellMenuFrame")="linear-gradient(180deg,#6c52d8 0%, #4d35ab 100%)",OUT("shellMenuBanner")="linear-gradient(180deg,#6c52d8 0%, #4d35ab 100%)"
	SET OUT("shellMenuBody")="linear-gradient(90deg,#fff9ff 0 70%, #efe6ff 70% 71%, #23183f 71% 100%)",OUT("shellMenuSide")="linear-gradient(180deg,#2a1d4f,#1c1437)"
	SET OUT("shellMenuFooter")="linear-gradient(180deg,#6c52d8 0%, #5038b6 100%)"
	SET OUT("shellExplorerToolbar")="linear-gradient(180deg,#fffaff 0%, #f1e8ff 100%)",OUT("shellExplorerPane")="linear-gradient(180deg,#2c204f,#1d1637)"
	SET OUT("shellExplorerSelection")="linear-gradient(180deg,#d8c9ff 0%, #b49ef5 100%)",OUT("shellExplorerSelectionBorder")="rgba(155,127,248,.36)"
	SET OUT("shellDialogBorder")="#4c35a9",OUT("shellDialogHeader")="linear-gradient(180deg,#6c52d8 0%, #4d35ab 100%)"
	QUIT
	;
CATALOG(ROOT)
	KILL @ROOT
	DO CATSET(ROOT,1,"midnight-professional")
	DO CATSET(ROOT,2,"slate-light")
	DO CATSET(ROOT,3,"clinical-blue")
	DO CATSET(ROOT,4,"surgical-teal")
	DO CATSET(ROOT,5,"high-contrast")
	DO CATSET(ROOT,6,"high-contrast-light")
	DO CATSET(ROOT,7,"violet-dusk")
	DO CATSET(ROOT,8,"xp-olive")
	DO CATSET(ROOT,9,"xp-silver")
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
