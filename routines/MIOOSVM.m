MIOOSVM ; MIOOS view model builders
	QUIT
	;
BUILD(STATE,CONF,VIEW)
	KILL VIEW
	MERGE VIEW("desktopEntries")=STATE("apps")
	SET VIEW("summary","headline")="Production shell foundation"
	SET VIEW("summary","subheadline")="Server-authored boot contract, thin Vue 3 shell, and websocket-first transport."
	SET VIEW("summary","theme")=$GET(STATE("themeKey"))
	SET VIEW("summary","launcherLabel")=$GET(STATE("launcherLabel"),"Menu")
	SET VIEW("summary","windowManager")=$GET(STATE("windowManager"),"mioos-native-vue-css")
	SET VIEW("documents",1,"title")="Desktop contract"
	SET VIEW("documents",1,"detail")="Routes, theme, apps, and windows are authored by MUMPS."
	SET VIEW("documents",2,"title")="Session posture"
	SET VIEW("documents",2,"detail")="The shell keeps one primary websocket for hello, ping, and view refresh."
	SET VIEW("documents",3,"title")="Front-end model"
	SET VIEW("documents",3,"detail")="Vue Options API UMD renders the current server contract without markup placeholders."
	SET VIEW("controlPanel",1,"title")="Theme"
	SET VIEW("controlPanel",1,"detail")=$GET(STATE("themeKey"))
	SET VIEW("controlPanel",2,"title")="Font"
	SET VIEW("controlPanel",2,"detail")=$GET(STATE("fontFamily"))_" "_+$GET(STATE("fontSize"),13)
	SET VIEW("controlPanel",3,"title")="Transport"
	SET VIEW("controlPanel",3,"detail")="websocket-only"
	SET VIEW("terminal","status")="ready"
	SET VIEW("terminal","transport")="single-websocket-command-and-events"
	SET VIEW("terminal","headline")="MUMPS terminal path ready"
	SET VIEW("terminal","subheadline")="Open the window from the taskbar or Menu; live shell transport belongs on the websocket boundary."
	QUIT
