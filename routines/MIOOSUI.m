MIOOSUI ; MIOOS UI helpers
	QUIT
	;
DESKCTX(STATE,CONF,DATA)
	KILL DATA
	SET DATA("page","title")=$GET(STATE("brandTitle"),"MIOOS")_" Desktop"
	SET DATA("brandTitle")=$GET(STATE("brandTitle"),"MIOOS")
	SET DATA("brandSubtitle")=$GET(STATE("brandSubtitle"),"MUMPS powered Windows XP style desktop")
	SET DATA("profile")=$GET(STATE("profile"),"dev")
	SET DATA("sessionId")=$GET(STATE("sessionId"))
	SET DATA("desktopPath")=$GET(STATE("desktopPath"))
	SET DATA("bootstrapPath")=$GET(STATE("bootstrapPath"))
	SET DATA("viewPath")=$GET(STATE("viewPath"))
	SET DATA("wsPath")=$GET(STATE("wsPath"))
	SET DATA("commandEvent")=$GET(STATE("commandEvent"),"desktop.command")
	SET DATA("commandResultEvent")=$GET(STATE("commandResultEvent"),"desktop.result")
	SET DATA("themeKey")=$GET(STATE("themeKey"),"xp-classic-blue")
	SET DATA("wallpaper")=$GET(STATE("wallpaper"),"bliss")
	SET DATA("density")=$GET(STATE("density"),"comfortable")
	SET DATA("launcherLabel")=$GET(STATE("launcherLabel"),"Menu")
	SET DATA("shellChrome")=$GET(STATE("shellChrome"),"winxp-professional")
	SET DATA("taskbarStyle")=$GET(STATE("taskbarStyle"),"xp-professional")
	SET DATA("startMenuStyle")=$GET(STATE("startMenuStyle"),"xp-two-column")
	SET DATA("windowManager")=$GET(STATE("windowManager"),"mioos-native-vue-css")
	SET DATA("bootJson")=$$BOOTJSON^MIOOSST(.STATE,.CONF)
	QUIT
