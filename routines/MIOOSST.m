MIOOSST ; MIOOS session and boot state
	QUIT
	;
LOAD(CONF,REQ,CTX,STATE,ERR)
	NEW USER,ROLES
	KILL STATE,ERR
	SET STATE("brandTitle")=$GET(CONF("mioos","brand","title"),"MIOOS")
	SET STATE("brandSubtitle")=$GET(CONF("mioos","brand","subtitle"),"MUMPS powered Windows XP style desktop")
	SET STATE("profile")=$SELECT($GET(CONF("mioos","profile"))'="":$GET(CONF("mioos","profile")),1:"dev")
	SET USER=$GET(CTX("auth","claims","sub")) IF USER="" SET USER=$SELECT(+$GET(CONF("mioos","desktop","authRequired"),0)=1:"unknown",1:"guest")
	SET ROLES=$GET(CTX("auth","claims","roles")) IF ROLES="" SET ROLES=$SELECT(USER="guest":"guest",1:"operator")
	SET STATE("principal")=USER
	SET STATE("userName")=$SELECT(USER="guest":"Guest",1:USER)
	SET STATE("roles")=ROLES
	SET STATE("sessionId")=$GET(CTX("auth","claims","sid")) IF STATE("sessionId")="" SET STATE("sessionId")="mioos-local"
	SET STATE("desktopPath")=$GET(CONF("mioos","route","desktop"),"/mioos")
	SET STATE("bootstrapPath")=$GET(CONF("mioos","route","bootstrap"),"/api/mioos/bootstrap")
	SET STATE("viewPath")=$GET(CONF("mioos","route","view"),"/api/mioos/view")
	SET STATE("wsPath")=$GET(CONF("mioos","route","ws"),"/ws/mioos")
	SET STATE("themeKey")=$GET(CONF("mioos","desktop","theme"),"xp-classic-blue")
	SET STATE("wallpaper")=$GET(CONF("mioos","desktop","wallpaper"),"bliss")
	SET STATE("density")=$GET(CONF("mioos","desktop","density"),"comfortable")
	SET STATE("fontFamily")=$GET(CONF("mioos","desktop","fontFamily"),"Segoe UI")
	SET STATE("fontSize")=+$GET(CONF("mioos","desktop","fontSize"),13)
	SET STATE("launcherLabel")=$GET(CONF("mioos","desktop","launcherLabel"),"Menu")
	SET STATE("commandEvent")=$GET(CONF("mioos","desktop","transport","eventName"),"desktop.command")
	SET STATE("commandResultEvent")=$GET(CONF("mioos","desktop","transport","resultEvent"),"desktop.result")
	SET STATE("commandErrorEvent")=$GET(CONF("mioos","desktop","transport","errorEvent"),"desktop.error")
	SET STATE("transportModel")=$GET(CONF("mioos","desktop","transport","model"),"single-websocket-command-and-events")
	SET STATE("shellChrome")=$GET(CONF("mioos","desktop","chrome"),"winxp-professional")
	SET STATE("taskbarStyle")=$GET(CONF("mioos","desktop","taskbarStyle"),"xp-professional")
	SET STATE("startMenuStyle")=$GET(CONF("mioos","desktop","startMenuStyle"),"xp-two-column")
	SET STATE("windowManager")=$GET(CONF("mioos","desktop","windowManager"),"mioos-native-vue-css")
	DO APPS(.STATE)
	DO WINDOWS(.STATE)
	QUIT 1
	;
BOOTJSON(STATE,CONF)
	NEW OBJ
	DO BOOTARY(.STATE,.CONF,.OBJ)
	QUIT $$EN^MIOJSON1(.OBJ)
	;
BOOTARY(STATE,CONF,OBJ)
	KILL OBJ
	SET OBJ("product","name")=$GET(STATE("brandTitle"),"MIOOS")
	SET OBJ("product","subtitle")=$GET(STATE("brandSubtitle"),"MUMPS powered Windows XP style desktop")
	SET OBJ("product","version")="roi1-shell-foundation"
	SET OBJ("product","profile")=$GET(STATE("profile"),"dev")
	SET OBJ("user","id")=$GET(STATE("principal"))
	SET OBJ("user","displayName")=$GET(STATE("userName"))
	DO CSV2ARY($GET(STATE("roles")),$NAME(OBJ("user","roles")))
	SET OBJ("session","id")=$GET(STATE("sessionId"))
	SET OBJ("session","transportModel")=$GET(STATE("transportModel"),"single-websocket-command-and-events")
	SET OBJ("routes","desktop")=$GET(STATE("desktopPath"))
	SET OBJ("routes","bootstrap")=$GET(STATE("bootstrapPath"))
	SET OBJ("routes","view")=$GET(STATE("viewPath"))
	SET OBJ("routes","websocket")=$GET(STATE("wsPath"))
	SET OBJ("routes","commandEvent")=$GET(STATE("commandEvent"))
	SET OBJ("routes","commandResultEvent")=$GET(STATE("commandResultEvent"))
	SET OBJ("routes","commandErrorEvent")=$GET(STATE("commandErrorEvent"))
	SET OBJ("desktop","themeKey")=$GET(STATE("themeKey"))
	SET OBJ("desktop","wallpaper")=$GET(STATE("wallpaper"))
	SET OBJ("desktop","density")=$GET(STATE("density"))
	SET OBJ("desktop","fontFamily")=$GET(STATE("fontFamily"))
	SET OBJ("desktop","fontSize")=+$GET(STATE("fontSize"),13)
	SET OBJ("desktop","launcherLabel")=$GET(STATE("launcherLabel"),"Menu")
	SET OBJ("desktop","shellChrome")=$GET(STATE("shellChrome"),"winxp-professional")
	SET OBJ("desktop","taskbarStyle")=$GET(STATE("taskbarStyle"),"xp-professional")
	SET OBJ("desktop","startMenuStyle")=$GET(STATE("startMenuStyle"),"xp-two-column")
	SET OBJ("desktop","windowManager")=$GET(STATE("windowManager"),"mioos-native-vue-css")
	SET OBJ("desktop","commandTransport")="websocket-only"
	SET OBJ("desktop","realtimeContract")=$GET(STATE("transportModel"),"single-websocket-command-and-events")
	SET OBJ("desktop","taskbarOrder")="stable-order"
	SET OBJ("desktop","noMarkupData")=1
	DO THEMES($NAME(OBJ("desktop","themes")),$GET(STATE("themeKey")))
	MERGE OBJ("apps")=STATE("apps")
	MERGE OBJ("windows")=STATE("windows")
	QUIT
	;
APPS(STATE)
	KILL STATE("apps")
	SET STATE("apps",1,"key")="my-computer"
	SET STATE("apps",1,"title")="My Computer"
	SET STATE("apps",1,"subtitle")="Browse drives, folders, and shell locations"
	SET STATE("apps",1,"icon")="💻"
	SET STATE("apps",1,"kind")="folder"
	SET STATE("apps",2,"key")="documents"
	SET STATE("apps",2,"title")="My Documents"
	SET STATE("apps",2,"subtitle")="Personal workspace documents"
	SET STATE("apps",2,"icon")="📁"
	SET STATE("apps",2,"kind")="folder"
	SET STATE("apps",3,"key")="control-panel"
	SET STATE("apps",3,"title")="Control Panel"
	SET STATE("apps",3,"subtitle")="Desktop settings and shell behavior"
	SET STATE("apps",3,"icon")="🛠"
	SET STATE("apps",3,"kind")="system"
	SET STATE("apps",4,"key")="terminal"
	SET STATE("apps",4,"title")="Terminal"
	SET STATE("apps",4,"subtitle")="Websocket-backed MUMPS terminal surface"
	SET STATE("apps",4,"icon")=">_"
	SET STATE("apps",4,"kind")="tool"
	QUIT
	;
WINDOWS(STATE)
	KILL STATE("windows")
	DO WIN(.STATE,1,"win-my-computer","my-computer","My Computer",88,72,760,500,4,"normal")
	DO WIN(.STATE,2,"win-documents","documents","My Documents",180,118,620,420,2,"minimized")
	DO WIN(.STATE,3,"win-control-panel","control-panel","Control Panel",240,92,540,400,1,"minimized")
	DO WIN(.STATE,4,"win-terminal","terminal","Terminal",120,88,820,430,3,"minimized")
	QUIT
	;
WIN(STATE,N,ID,APPKEY,TITLE,LEFT,TOP,WIDTH,HEIGHT,Z,MODE)
	SET STATE("windows",N,"id")=ID
	SET STATE("windows",N,"appKey")=APPKEY
	SET STATE("windows",N,"title")=TITLE
	SET STATE("windows",N,"left")=LEFT
	SET STATE("windows",N,"top")=TOP
	SET STATE("windows",N,"width")=WIDTH
	SET STATE("windows",N,"height")=HEIGHT
	SET STATE("windows",N,"z")=Z
	SET STATE("windows",N,"state")=MODE
	QUIT
	;
THEMES(ROOT,CURRENT)
	KILL @ROOT
	SET @ROOT@(1,"key")="xp-classic-blue"
	SET @ROOT@(1,"title")="XP Classic Blue"
	SET @ROOT@(1,"isCurrent")=$SELECT($GET(CURRENT)="xp-classic-blue":1,1:0)
	SET @ROOT@(1,"wallpaper")="bliss"
	SET @ROOT@(1,"accent")="#245edb"
	SET @ROOT@(1,"taskbar")="#245edb"
	SET @ROOT@(2,"key")="xp-olive"
	SET @ROOT@(2,"title")="XP Olive"
	SET @ROOT@(2,"isCurrent")=$SELECT($GET(CURRENT)="xp-olive":1,1:0)
	SET @ROOT@(2,"wallpaper")="olive"
	SET @ROOT@(2,"accent")="#6b7d2b"
	SET @ROOT@(2,"taskbar")="#6b7d2b"
	QUIT
	;
CSV2ARY(CSV,ROOT)
	NEW I,ITEM
	KILL @ROOT
	FOR I=1:1:$LENGTH($GET(CSV),",") DO
	. SET ITEM=$PIECE($GET(CSV),",",I)
	. QUIT:ITEM=""
	. SET @ROOT@(I)=ITEM
	QUIT
