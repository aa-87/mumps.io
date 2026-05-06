MIOOSUI ; MIOOS UI helpers
	QUIT
	;
DESKCTX(STATE,CONF,DATA)
	KILL DATA
	SET DATA("page","title")=$GET(STATE("brandTitle"),"MIOOS")_" "_$$TXT^MIOOSI18N($GET(STATE("localeCode"),"en"),"page.desktop","Desktop")
	SET DATA("brandTitle")=$GET(STATE("brandTitle"),"MIOOS")
	SET DATA("brandSubtitle")=$GET(STATE("brandSubtitle"),"MUMPS-powered web desktop shell")
	SET DATA("profile")=$GET(STATE("profile"),"dev")
	SET DATA("sessionId")=$GET(STATE("sessionId"))
	SET DATA("desktopPath")=$GET(STATE("desktopPath"))
	SET DATA("bootstrapPath")=$GET(STATE("bootstrapPath"))
	SET DATA("viewPath")=$GET(STATE("viewPath"))
	SET DATA("fsUploadPath")=$GET(STATE("fsUploadPath"))
	SET DATA("fsUploadBeginPath")=$GET(STATE("fsUploadBeginPath"))
	SET DATA("fsUploadChunkPath")=$GET(STATE("fsUploadChunkPath"))
	SET DATA("fsUploadStatusPath")=$GET(STATE("fsUploadStatusPath"))
	SET DATA("fsUploadCommitPath")=$GET(STATE("fsUploadCommitPath"))
	SET DATA("fsUploadAbortPath")=$GET(STATE("fsUploadAbortPath"))
	SET DATA("themeAssetUploadPath")=$GET(STATE("themeAssetUploadPath"))
	SET DATA("themeAssetPath")=$GET(STATE("themeAssetPath"))
	SET DATA("fsCopyPath")=$GET(STATE("fsCopyPath"))
	SET DATA("signinPath")=$GET(STATE("signinPath"))
	SET DATA("signoutPath")=$GET(STATE("signoutPath"))
	SET DATA("guestSigninPath")=$GET(STATE("guestSigninPath"))
	SET DATA("wsPath")=$GET(STATE("wsPath"))
	SET DATA("wsTerminalPath")=$GET(STATE("wsTerminalPath"))
	SET DATA("wsMaxSockets")=+$GET(STATE("wsMaxSockets"),4)
	SET DATA("wsFsSockets")=+$GET(STATE("wsFsSockets"),3)
	SET DATA("commandEvent")=$GET(STATE("commandEvent"),"desktop.command")
	SET DATA("commandResultEvent")=$GET(STATE("commandResultEvent"),"desktop.result")
	SET DATA("themeKey")=$GET(STATE("themeKey"),"foundation-light")
	SET DATA("wallpaper")=$GET(STATE("wallpaper"),"aurora")
	SET DATA("wallpaperUrl")=$GET(STATE("wallpaperUrl"))
	IF '+$GET(STATE("authenticated"),0),$$PROTURL(DATA("wallpaperUrl"),.STATE) SET DATA("wallpaperUrl")=""
	SET DATA("density")=$GET(STATE("density"),"comfortable")
	SET DATA("launcherLabel")=$GET(STATE("launcherLabel"),"Menu")
	SET DATA("shellChrome")=$GET(STATE("shellChrome"),"shell-foundation")
	SET DATA("taskbarStyle")=$GET(STATE("taskbarStyle"),"taskbar-foundation")
	SET DATA("startMenuStyle")=$GET(STATE("startMenuStyle"),"launcher-foundation")
	SET DATA("shellDialogModel")=$GET(STATE("shellDialogModel"),"shell-modal")
	SET DATA("windowManager")=$GET(STATE("windowManager"),"mioos-native-vue-css")
	SET DATA("themeMode")=$GET(STATE("themeMode"),"light")
	SET DATA("themeInlineStyle")=$$THEMEINL(.STATE)
	SET DATA("themeKey")=$GET(STATE("themeKey"),$GET(DATA("themeKey"),"foundation-light"))
	SET DATA("themeMode")=$GET(STATE("themeMode"),$GET(DATA("themeMode"),"light"))
	SET DATA("themeRootClass")=$SELECT($GET(DATA("themeMode"))="dark":"theme-dark-mode",1:"")
	SET DATA("density")=$GET(STATE("density"),$GET(DATA("density"),"comfortable"))
	SET DATA("motionPreference")=$GET(STATE("a11yMotionPreference"),"respect-user-preference")
	SET DATA("windowSnapThreshold")=+$GET(STATE("windowSnapThreshold"),28)
	SET DATA("windowResizeModel")="all-edges-and-corners"
	SET DATA("authRequired")=+$GET(STATE("authRequired"),0)
	SET DATA("localAuthEnabled")=+$GET(STATE("localAuthEnabled"),0)
	SET DATA("guestLoginEnabled")=+$GET(STATE("guestLoginEnabled"),0)
	SET DATA("localeCode")=$GET(STATE("localeCode"),"en")
	SET DATA("localeDir")=$GET(STATE("localeDir"),"ltr")
	SET DATA("bootJson")=$$BOOTJSON^MIOOSST(.STATE,.CONF)
	QUIT
THEMEINL(STATE)
	NEW KEY,MODE,TOP,MID,BOT,TASK1,TASK2,START1,START2,TITLE1,TITLE2,PANEL,TEXT,PROFILE,URL,FIT,BG,DEN,ACCENT,TASKH,STARTW,TASKW,ICON,SPACE,BASE,TITLE,SIDE,CV,COL,RADIUS,OUT,CSSK,CSSV,LOGINURL,LOGINBG
	SET KEY=$GET(STATE("themeKey"),"glass-horizon-light"),MODE=$GET(STATE("themeMode"),"light")
	SET TOP="#2d66c2",MID="#153a79",BOT="#0d244b",TASK1="#6385bd",TASK2="#24406f",START1="#7fd25f",START2="#2f7e22",TITLE1="#6f93c7",TITLE2="#4e6e9f",PANEL="#f8fbff",TEXT="#173455",ACCENT="#72a8ff",RADIUS="10px"
	IF KEY["meadow-classic" DO
	. SET TOP="#7ec85a",MID="#4e9b35",BOT="#1d5f20",TASK1="#4f972c",TASK2="#1f5f1f",START1="#7fd25f",START2="#2f7e22",TITLE1="#8fcf67",TITLE2="#4f972c"
	IF KEY["graphite-dock" DO
	. SET TOP="#cfd6df",MID="#8d97a5",BOT="#515868",TASK1="#d9dce4",TASK2="#8d93a0",START1="#f7f8fb",START2="#c8ccd7",TITLE1="#d7dbe4",TITLE2="#8e96a5",TEXT="#2e3440"
	IF KEY["ember-panel" DO
	. SET TOP="#e58c46",MID="#9a4d29",BOT="#4e1e18",TASK1="#f0a05d",TASK2="#7b2f1d",START1="#f3b36c",START2="#b94f2a",TITLE1="#ef9a4f",TITLE2="#6d221a",TEXT="#2b1e1a"
	IF MODE="dark" DO
	. SET PANEL="#1a2331",TEXT="#eef4fb"
	. IF KEY["glass-horizon" SET TOP="#1f2d40",MID="#172232",BOT="#0f1621",TASK1="#1d2a3d",TASK2="#111b29",TITLE1="#44556f",TITLE2="#263243"
	. IF KEY["meadow-classic" SET TOP="#244a2a",MID="#1d2f39",BOT="#101921",TASK1="#223951",TASK2="#111e2d",TITLE1="#42607f",TITLE2="#203246"
	. IF KEY["graphite-dock" SET TOP="#48505b",MID="#262b33",BOT="#12161d",TASK1="#2e343f",TASK2="#171c23",TITLE1="#6b7280",TITLE2="#39414d"
	. IF KEY["ember-panel" SET TOP="#5e2b22",MID="#2b1714",BOT="#120d0f",TASK1="#3c241f",TASK2="#1b1110",TITLE1="#7f4333",TITLE2="#43201c"
	IF $DATA(STATE("activeThemeProfile")) DO
	. MERGE PROFILE=STATE("activeThemeProfile")
	. SET KEY=$GET(PROFILE("presetKey"),$GET(PROFILE("key"),KEY)),MODE=$GET(PROFILE("mode"),$GET(PROFILE("activeMode"),MODE))
	. SET TOP=$GET(PROFILE("desktop","wallpaperTop"),TOP),MID=$GET(PROFILE("desktop","wallpaperMiddle"),MID),BOT=$GET(PROFILE("desktop","wallpaperBottom"),BOT)
	. SET TASK1=$GET(PROFILE("panel","taskbarTop"),TASK1),TASK2=$GET(PROFILE("panel","taskbarBottom"),TASK2),START1=$GET(PROFILE("panel","startTop"),START1),START2=$GET(PROFILE("panel","startBottom"),START2)
	. SET TITLE1=$GET(PROFILE("windowChrome","titleTop"),TITLE1),TITLE2=$GET(PROFILE("windowChrome","titleBottom"),TITLE2),PANEL=$GET(PROFILE("colors","panel"),PANEL),TEXT=$GET(PROFILE("colors","panelText"),TEXT)
	. SET CV=$NAME(PROFILE("cssVars")),COL=$NAME(PROFILE("colors"))
	. SET ACCENT=$GET(@CV@("--accent"),$GET(@COL@("--accent"),$GET(PROFILE("appearance","accent"),ACCENT)))
	. SET PANEL=$GET(@CV@("--window-bg"),$GET(@COL@("--window-bg"),PANEL))
	. SET TEXT=$GET(@CV@("--menu-text"),$GET(@COL@("--menu-text"),TEXT))
	. SET TASK1=$GET(@CV@("--taskbar-bg"),$GET(@COL@("--taskbar-bg"),TASK1))
	. SET TASK2=$GET(@CV@("--taskbar-border"),$GET(@COL@("--taskbar-border"),TASK2))
	. SET TITLE1=$GET(@CV@("--titlebar-bg"),$GET(@COL@("--titlebar-bg"),TITLE1))
	. SET TITLE2=$GET(@CV@("--titlebar-inactive"),$GET(@COL@("--titlebar-inactive"),TITLE2))
	. SET RADIUS=$GET(@CV@("--window-radius"),$GET(@COL@("--window-radius"),RADIUS))
	SET BG=$GET(PROFILE("cssVars","--desktop-bg"),$GET(PROFILE("colors","--desktop-bg"),""))
	IF '+$GET(STATE("authenticated"),0),$$PROTURL(BG,.STATE) SET BG=""
	IF BG="" SET BG="radial-gradient(circle at 18% 20%,rgba(255,255,255,.20),transparent 26%),linear-gradient(180deg,"_TOP_" 0%,"_MID_" 52%,"_BOT_" 100%)"
	SET URL=$GET(PROFILE("desktop","wallpaperUrl")),FIT=$GET(PROFILE("desktop","wallpaperFit"),"cover")
	IF URL="" SET URL=$GET(STATE("wallpaperUrl"))
	IF '+$GET(STATE("authenticated"),0),$$PROTURL(URL,.STATE) SET URL=""
	IF URL'="" SET BG="linear-gradient(180deg,rgba(255,255,255,.12),rgba(255,255,255,.02)),url('"_URL_"') center/"_$SELECT(FIT="tile":"240px auto repeat",FIT="contain":"contain no-repeat",FIT="center":"auto no-repeat",1:"cover no-repeat")
	SET DEN=$GET(PROFILE("density"),$GET(PROFILE("appearance","density"),$GET(STATE("density"),"comfortable")))
	SET ACCENT=$GET(PROFILE("cssVars","--accent"),$GET(PROFILE("colors","--accent"),$GET(PROFILE("appearance","accent"),"#72a8ff"))),TASKH=+$GET(PROFILE("cssVars","--taskbar-height"),$GET(PROFILE("panel","height"),46)),STARTW=+$GET(PROFILE("panel","startMinWidth"),92),TASKW=+$GET(PROFILE("panel","taskMinWidth"),122)
	SET ICON=+$GET(PROFILE("cssVars","--desktop-icon-size"),$GET(PROFILE("desktop","iconSize"),54)),SPACE=+$GET(PROFILE("desktop","iconSpacing"),16),BASE=+$GET(PROFILE("cssVars","--font-size-ui"),$GET(PROFILE("fonts","baseSize"),12)),TITLE=+$GET(PROFILE("fonts","titleSize"),12),SIDE=+$GET(PROFILE("windowChrome","sidebarWidth"),220)
	SET LOGINURL=$GET(PROFILE("loginScreenConfig","wallpaperUrl")),LOGINBG=BG
	IF '+$GET(STATE("authenticated"),0),$$PROTURL(LOGINURL,.STATE) SET LOGINURL=""
	IF LOGINURL'="" SET LOGINBG="url('"_LOGINURL_"') center/cover no-repeat"
	SET OUT="--mioos-accent:"_ACCENT_";--mioos-bg:"_PANEL_";--mioos-window-radius:"_RADIUS_";--desktop-bg:"_BG_";--desktop-wallpaper:"_BG_";--login-wallpaper:"_LOGINBG_";--mioos-desktop-background:"_BG_";--mioos-body-background:linear-gradient(180deg,"_TOP_" 0%,"_MID_" 55%,"_BOT_" 100%);--mioos-taskbar:"_TASK1_";--mioos-taskbar-dark:"_TASK2_";--mioos-start:"_START1_";--mioos-start-bottom:"_START2_";--mioos-titlebar:"_TITLE1_";--mioos-titlebar-bottom:"_TITLE2_";--mioos-panel:"_PANEL_";--mioos-text:"_TEXT_";--mioos-blue-1:"_ACCENT_";--mioos-taskbar-height:"_TASKH_"px;--mioos-start-min-width:"_STARTW_"px;--mioos-task-min-width:"_TASKW_"px;--mioos-icon-size:"_ICON_"px;--mioos-icon-grid-gap:"_SPACE_"px;--mioos-base-size:"_BASE_"px;--mioos-title-size:"_TITLE_"px;--mioos-sidebar-width:"_SIDE_"px;"
	IF $DATA(PROFILE("cssVars")) DO
	. SET CSSK="" FOR  SET CSSK=$ORDER(PROFILE("cssVars",CSSK)) QUIT:CSSK=""  DO
	. . IF $EXTRACT(CSSK,1,2)'="--" QUIT
	. . SET CSSV=$GET(PROFILE("cssVars",CSSK)) IF CSSV="" QUIT
	. . IF '+$GET(STATE("authenticated"),0),$$PROTURL(CSSV,.STATE) QUIT
	. . SET OUT=OUT_CSSK_":"_CSSV_";"
	QUIT OUT

PROTURL(URL,STATE)
	NEW U,FS,TA
	SET U=$GET(URL) IF U="" QUIT 0
	SET FS=$GET(STATE("fsBlobPath"),"/api/mioos/fs/blob")
	SET TA=$GET(STATE("themeAssetPath"),"/api/mioos/theme-asset")
	IF U[FS QUIT 1
	IF U[TA QUIT 1
	IF U["/api/mioos/fs/blob" QUIT 1
	IF U["/api/mioos/theme-asset" QUIT 1
	QUIT 0
	;
