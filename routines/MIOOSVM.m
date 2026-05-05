MIOOSVM ; MIOOS view model builders
	QUIT
	;
BUILD(STATE,CONF,VIEW)
	NEW CODE,AUTHTXT
	SET CODE=$GET(STATE("localeCode"),"en")
	KILL VIEW
	DO DESKTOPVM(.STATE,.CONF,$NAME(VIEW("desktopEntries")),$NAME(VIEW("desktopFolder")))
	SET VIEW("summary","headline")=$$TXT^MIOOSI18N(CODE,"view.summary.headline","Production shell foundation")
	SET VIEW("summary","subheadline")=$$TXT^MIOOSI18N(CODE,"view.summary.subheadline","Server-authored boot contract, thin Vue 3 shell, websocket-first transport, and local auth sessions.")
	SET VIEW("summary","theme")=$GET(STATE("themeKey"))
	SET VIEW("summary","launcherLabel")=$GET(STATE("launcherLabel"),"Menu")
	SET VIEW("summary","windowManager")=$GET(STATE("windowManager"),"mioos-native-vue-css")
	SET VIEW("summary","authMode")=$GET(STATE("authMode"),"anonymous")
	SET VIEW("summary","authenticated")=+$GET(STATE("authenticated"),0)
	SET VIEW("documents",1,"title")=$$TXT^MIOOSI18N(CODE,"view.documents.1.title","Desktop contract")
	SET VIEW("documents",1,"detail")=$$TXT^MIOOSI18N(CODE,"view.documents.1.detail","Routes, theme, apps, windows, locale, and auth posture are authored by MUMPS.")
	SET VIEW("documents",2,"title")=$$TXT^MIOOSI18N(CODE,"view.documents.2.title","Session posture")
	SET VIEW("documents",2,"detail")=$$TXT^MIOOSI18N(CODE,"view.documents.2.detail","The shell keeps one primary websocket and optional local JWT cookie sessions for sign-in.")
	SET VIEW("documents",3,"title")=$$TXT^MIOOSI18N(CODE,"view.documents.3.title","Front-end model")
	SET VIEW("documents",3,"detail")=$$TXT^MIOOSI18N(CODE,"view.documents.3.detail","Vue Options API UMD renders the current server contract without markup placeholders.")
	SET VIEW("controlPanel",1,"title")=$$TXT^MIOOSI18N(CODE,"view.controlPanel.1.title","Theme")
	SET VIEW("controlPanel",1,"detail")=$GET(STATE("themeKey"))
	SET VIEW("controlPanel",2,"title")=$$TXT^MIOOSI18N(CODE,"view.controlPanel.2.title","Font")
	SET VIEW("controlPanel",2,"detail")=$GET(STATE("fontFamily"))_" "_+$GET(STATE("fontSize"),13)
	SET VIEW("controlPanel",3,"title")=$$TXT^MIOOSI18N(CODE,"view.controlPanel.3.title","Transport")
	SET VIEW("controlPanel",3,"detail")="websocket-only"
	SET VIEW("controlPanel",4,"title")=$$TXT^MIOOSI18N(CODE,"view.controlPanel.4.title","Authentication")
	IF +$GET(STATE("authenticated"),0)=1 DO
	. SET AUTHTXT=$$TXT^MIOOSI18N(CODE,"auth.state.signedInAs","Signed in as")_" "_$GET(STATE("userName"))
	ELSE  IF +$GET(STATE("authRequired"),0)=1 DO
	. SET AUTHTXT=$$TXT^MIOOSI18N(CODE,"auth.state.required","Sign in required")
	ELSE  DO
	. SET AUTHTXT=$$TXT^MIOOSI18N(CODE,"auth.state.guest","Desktop available without sign-in")
	SET VIEW("controlPanel",4,"detail")=AUTHTXT
	SET VIEW("explorer","currentFolderId")=$GET(STATE("fsDesktopId"),$GET(STATE("fsHomeId"),$GET(STATE("fsRootId"),"root")))
	SET VIEW("explorer","quickPlaces",1,"id")=$GET(STATE("fsHomeId"),$GET(STATE("fsRootId"),"root"))
	SET VIEW("explorer","quickPlaces",1,"title")="Home"
	SET VIEW("explorer","quickPlaces",2,"id")=$GET(STATE("fsDesktopId"),$GET(STATE("fsRootId"),"root"))
	SET VIEW("explorer","quickPlaces",2,"title")="Desktop"
	SET VIEW("terminal","status")="ready"
	SET VIEW("terminal","transport")=$GET(STATE("terminal","transport"),"pipe")
	SET VIEW("terminal","engine")=$GET(STATE("terminal","engine"),"xtermjs")
	SET VIEW("terminal","renderer")=$GET(STATE("terminal","renderer"),"canvas")
	SET VIEW("terminal","sessionModel")=$GET(STATE("terminal","sessionModel"),"multi-window-ydb-direct")
	SET VIEW("terminal","headline")=$$TXT^MIOOSI18N(CODE,"terminal.headline","MIOOS YottaDB terminal ready")
	SET VIEW("terminal","subheadline")=$$TXT^MIOOSI18N(CODE,"terminal.subheadline","Open Terminal from the desktop or Menu. Each window attaches to its own YottaDB pipe session over the primary websocket.")
	SET VIEW("terminal","profile","fontFamily")=$GET(STATE("terminal","fontFamily"),"Consolas")
	SET VIEW("terminal","profile","fontSize")=+$GET(STATE("terminal","fontSize"),14)
	SET VIEW("terminal","profile","rows")=+$GET(STATE("terminal","rows"),28)
	SET VIEW("terminal","profile","cols")=+$GET(STATE("terminal","cols"),112)
	DO LIST^MIOOSTERM(.STATE,$NAME(VIEW("terminal","sessions")))
	QUIT
	;
DESKTOPVM(STATE,CONF,ROOT,FROOT)
	NEW TARGET,OUT,ERR,I,N,ID,KIND,NAME,MIME,ICON
	KILL @ROOT,@FROOT
	SET TARGET=$GET(STATE("fsDesktopId")) IF TARGET="" SET TARGET=$$DESKTOPID^MIOOSFS()
	IF TARGET="" SET TARGET="root"
	IF '$$LIST^MIOOSFS(.STATE,TARGET,.OUT,.ERR) DO  QUIT
	. SET @FROOT@("id")=TARGET
	. SET @FROOT@("path")="/Home/Desktop"
	. SET @FROOT@("canonicalPath")="/Home/Desktop"
	. SET @FROOT@("error")=$GET(ERR("error"))
	MERGE @FROOT=OUT("folder")
	SET @FROOT@("canonicalPath")="/Home/Desktop"
	SET N=0,I=0
	FOR  SET I=$ORDER(OUT("entries",I)) QUIT:I'>0  DO
	. SET ID=$GET(OUT("entries",I,"id")) QUIT:ID=""
	. SET NAME=$GET(OUT("entries",I,"name"))
	. IF $$SKIPDESK(NAME) QUIT
	. SET N=N+1
	. MERGE @ROOT@(N)=OUT("entries",I)
	. SET KIND=$GET(OUT("entries",I,"kind")),MIME=$GET(OUT("entries",I,"mime"))
	. SET @ROOT@(N,"key")=ID
	. SET @ROOT@(N,"title")=NAME
	. SET @ROOT@(N,"label")=NAME
	. SET @ROOT@(N,"source")="vfs"
	. SET @ROOT@(N,"targetPath")=$GET(OUT("entries",I,"path"))
	. IF $GET(OUT("entries",I,"iconLeft"))'="" SET @ROOT@(N,"iconLeft")=$GET(OUT("entries",I,"iconLeft"))
	. IF $GET(OUT("entries",I,"iconTop"))'="" SET @ROOT@(N,"iconTop")=$GET(OUT("entries",I,"iconTop"))
	. IF $GET(OUT("entries",I,"launchKey"))'="" SET @ROOT@(N,"launchKey")=$GET(OUT("entries",I,"launchKey"))
	. IF $GET(OUT("entries",I,"appKey"))'="" SET @ROOT@(N,"appKey")=$GET(OUT("entries",I,"appKey"))
	. IF $GET(OUT("entries",I,"shortcut","targetAppKey"))'="" SET @ROOT@(N,"targetAppKey")=$GET(OUT("entries",I,"shortcut","targetAppKey"))
	. SET ICON=$GET(OUT("entries",I,"customize","icon"))
	. IF ICON="" SET ICON=$$ICON(KIND,MIME,NAME)
	. SET @ROOT@(N,"icon")=ICON
	. SET @ROOT@(N,"subtitle")=$SELECT(KIND="shortcut":"Shortcut",KIND="folder":"Folder",$GET(OUT("entries",I,"sizeLabel"))'="":$GET(OUT("entries",I,"sizeLabel")),1:"File")
	SET @FROOT@("count")=N
	QUIT
	;
SKIPDESK(NAME)
	QUIT $SELECT($GET(NAME)="ROI2Folder":1,1:0)
	;
ICON(KIND,MIME,NAME)
	NEW LNAME,LMIME
	SET LNAME=$$LOW^MIOUTIL($GET(NAME)),LMIME=$$LOW^MIOUTIL($GET(MIME))
	IF $GET(KIND)="folder" QUIT "📁"
	IF LMIME["image/" QUIT "🖼"
	IF LMIME["audio/" QUIT "🎵"
	IF LMIME["video/" QUIT "🎬"
	IF LMIME["pdf" QUIT "📕"
	IF LNAME[".txt"!(LNAME[".md")!(LNAME[".m") QUIT "📄"
	QUIT "📄"
	;
