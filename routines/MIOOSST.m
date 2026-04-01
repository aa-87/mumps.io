MIOOSST ; MIOOS session and boot state
	QUIT
	;
LOAD(CONF,REQ,CTX,STATE,ERR)
	NEW USER,ROLES,AUTHOK,AUTHERR,AUTHREQ,DEVOK,UNAME,LOC,CODE
	KILL STATE,ERR
	SET ERR("routine")="MIOOSST"
	DO BOOTSTRAP^MIOOSAUTH(.CONF)
	DO INIT^MIOOSFS(.CONF)
	DO RESOLVE^MIOOSI18N(.CONF,.REQ,.CTX,.LOC)
	SET CODE=$GET(LOC("code"),"en")
	SET AUTHREQ=+$$AUTHREQ^MIOOSAUTH(.CONF)
	SET AUTHOK=0
	IF +$$LOCALEN^MIOOSAUTH(.CONF)=1 DO
	. SET AUTHOK=$$LOADLOCAL^MIOOSAUTH(.CONF,.REQ,.CTX,.AUTHERR)
	SET DEVOK=$$DEVAUTH(.CONF)
	IF AUTHOK DO
	. SET USER=$$PRINCIPAL^MIOAUTHCTX(.CTX)
	. SET UNAME=$$USERNAME^MIOAUTHCTX(.CTX)
	. SET ROLES=$$ROLECSV^MIOAUTHCTX(.CTX)
	ELSE  IF DEVOK DO
	. SET USER=$GET(CONF("mioos","dev","principal"),"dev-user")
	. SET UNAME=$GET(CONF("mioos","dev","userName"),"Developer")
	. SET ROLES=$GET(CONF("mioos","dev","roles"),"developer,admin")
	ELSE  DO
	. SET USER=""
	. SET UNAME=""
	. SET ROLES=""
	SET STATE("localeCode")=CODE
	SET STATE("localeDir")=$GET(LOC("dir"),"ltr")
	SET STATE("localeLabel")=$GET(LOC("label"),$$LABEL^MIOOSI18N(CODE))
	SET STATE("localeRtl")=+$GET(LOC("rtl"),0)
	SET STATE("authenticated")=$SELECT(USER'="":1,1:0)
	SET STATE("authRequired")=AUTHREQ
	SET STATE("authMode")=$SELECT(+$$LOCALEN^MIOOSAUTH(.CONF)=1:"local-session",DEVOK=1:"dev-bypass",1:"anonymous")
	SET STATE("guestLoginEnabled")=+$$GUESTEN^MIOOSAUTH(.CONF)
	SET STATE("localAuthEnabled")=+$$LOCALEN^MIOOSAUTH(.CONF)
	SET STATE("brandTitle")=$GET(CONF("mioos","brand","title"),"MIOOS")
	SET STATE("brandSubtitle")=$$TXT^MIOOSI18N(CODE,"product.subtitle","MUMPS powered Windows XP style desktop")
	SET STATE("profile")=$$PROFILE(.CONF)
	SET STATE("principal")=$SELECT(USER'="":USER,AUTHREQ=1:"anonymous",1:"guest")
	SET STATE("userName")=$SELECT(UNAME'="":UNAME,AUTHREQ=1:$$TXT^MIOOSI18N(CODE,"auth.state.required","Sign in required"),1:$$TXT^MIOOSI18N(CODE,"common.guest","Guest"))
	IF ROLES="" SET ROLES=$SELECT(STATE("principal")="guest":"guest",1:"")
	SET STATE("roles")=ROLES
	SET STATE("sessionId")=$GET(CTX("auth","claims","sid")) IF STATE("sessionId")="" SET STATE("sessionId")=$SELECT(STATE("authenticated")=1:"mioos-auth",1:"mioos-shell")
	SET STATE("desktopPath")=$GET(CONF("mioos","route","desktop"),"/mioos")
	SET STATE("bootstrapPath")=$GET(CONF("mioos","route","bootstrap"),"/api/mioos/bootstrap")
	SET STATE("viewPath")=$GET(CONF("mioos","route","view"),"/api/mioos/view")
	SET STATE("signinPath")=$GET(CONF("mioos","route","signin"),"/api/mioos/auth/signin")
	SET STATE("signoutPath")=$GET(CONF("mioos","route","signout"),"/api/mioos/auth/signout")
	SET STATE("guestSigninPath")=$GET(CONF("mioos","route","guestSignin"),"/api/mioos/auth/guest")
	SET STATE("fsListPath")=$GET(CONF("mioos","route","fsList"),"/api/mioos/fs/list")
	SET STATE("fsReadPath")=$GET(CONF("mioos","route","fsRead"),"/api/mioos/fs/read")
	SET STATE("fsWritePath")=$GET(CONF("mioos","route","fsWrite"),"/api/mioos/fs/write")
	SET STATE("fsMkdirPath")=$GET(CONF("mioos","route","fsMkdir"),"/api/mioos/fs/mkdir")
	SET STATE("fsMetaPath")=$GET(CONF("mioos","route","fsMeta"),"/api/mioos/fs/meta")
	SET STATE("wsPath")=$GET(CONF("mioos","route","ws"),"/ws/mioos")
	SET STATE("fsEnabled")=+$GET(CONF("mioos","fs","enabled"),1)
	SET STATE("fsChunkSize")=+$GET(CONF("mioos","fs","chunkSize"),2048)
	SET STATE("fsTransport")=$GET(CONF("mioos","fs","transport"),"http-and-websocket")
	SET STATE("fsRootId")=$$ROOTID^MIOOSFS()
	SET STATE("fsHomeId")=$$HOMEID^MIOOSFS()
	SET STATE("wsTerminalPath")=$GET(CONF("mioos","route","wsTerminal"),"/ws/mioos/terminal")
	SET STATE("themeKey")=$GET(CONF("mioos","desktop","theme"),"xp-classic-blue")
	SET STATE("wallpaper")=$GET(CONF("mioos","desktop","wallpaper"),"bliss")
	SET STATE("density")=$GET(CONF("mioos","desktop","density"),"comfortable")
	SET STATE("fontFamily")=$GET(CONF("mioos","desktop","fontFamily"),"Segoe UI")
	SET STATE("fontSize")=+$GET(CONF("mioos","desktop","fontSize"),13)
	SET STATE("launcherLabel")=$$TXT^MIOOSI18N(CODE,"launcher.menu","Menu")
	SET STATE("commandEvent")=$GET(CONF("mioos","desktop","transport","eventName"),"desktop.command")
	SET STATE("commandResultEvent")=$GET(CONF("mioos","desktop","transport","resultEvent"),"desktop.result")
	SET STATE("commandErrorEvent")=$GET(CONF("mioos","desktop","transport","errorEvent"),"desktop.error")
	SET STATE("transportModel")=$GET(CONF("mioos","desktop","transport","model"),"core-websocket-plus-app-websockets")
	SET STATE("shellChrome")=$GET(CONF("mioos","desktop","chrome"),"winxp-professional")
	SET STATE("taskbarStyle")=$GET(CONF("mioos","desktop","taskbarStyle"),"xp-professional")
	SET STATE("startMenuStyle")=$GET(CONF("mioos","desktop","startMenuStyle"),"xp-two-column")
	SET STATE("windowManager")=$GET(CONF("mioos","desktop","windowManager"),"mioos-native-vue-css")
	SET STATE("a11yRtl")=+$GET(STATE("localeRtl"),0)
	SET STATE("a11yKeyboardModel")="desktop-first"
	SET STATE("a11yScreenReaderHints")=1
	SET STATE("a11yMotionPreference")="respect-user-preference"
	SET STATE("perfClientModel")="thin-vue-umd"
	SET STATE("perfRenderBudgetMs")=16
	SET STATE("perfPayloadMode")="tmp-global-safe"
	SET STATE("perfTransport")="websocket-first-http-refresh"
	DO LOADTERM^MIOOSTERM(.STATE,.CONF)
	DO APPS(.STATE)
	DO WINDOWS(.STATE)
	QUIT 1
	;
PROFILE(CONF)
	IF $$DEVAUTH(.CONF) QUIT "dev"
	QUIT $SELECT($GET(CONF("mioos","profile"))'="":$GET(CONF("mioos","profile")),1:"prod")
	;
DEVAUTH(CONF)
	IF +$$LOCALEN^MIOOSAUTH(.CONF)=1 QUIT 0
	IF +$GET(CONF("mioos","dev","authDisabled"),0)=1 QUIT 1
	IF +$GET(CONF("mioos","dev","enabled"),0)=1,$GET(CONF("mioos","profile"))="dev" QUIT 1
	QUIT 0
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
	SET OBJ("product","version")="roi6-core-plus-terminal-websockets"
	SET OBJ("product","profile")=$GET(STATE("profile"),"dev")
	SET OBJ("user","id")=$GET(STATE("principal"))
	SET OBJ("user","displayName")=$GET(STATE("userName"))
	SET OBJ("user","authenticated")=+$GET(STATE("authenticated"),0)
	DO CSV2ARY($GET(STATE("roles")),$NAME(OBJ("user","roles")))
	SET OBJ("session","id")=$GET(STATE("sessionId"))
	SET OBJ("session","transportModel")=$GET(STATE("transportModel"),"core-websocket-plus-app-websockets")
	SET OBJ("locale","code")=$GET(STATE("localeCode"),"en")
	SET OBJ("locale","dir")=$GET(STATE("localeDir"),"ltr")
	SET OBJ("locale","label")=$GET(STATE("localeLabel"),"English")
	SET OBJ("locale","rtl")=+$GET(STATE("localeRtl"),0)
	DO SUPPORTED^MIOOSI18N($NAME(OBJ("locale","supported")),$GET(CONF("mioos","i18n","default"),"en"))
	DO CATALOG^MIOOSI18N($GET(STATE("localeCode"),"en"),$NAME(OBJ("i18n","strings")))
	SET OBJ("routes","desktop")=$GET(STATE("desktopPath"))
	SET OBJ("routes","bootstrap")=$GET(STATE("bootstrapPath"))
	SET OBJ("routes","view")=$GET(STATE("viewPath"))
	SET OBJ("routes","signin")=$GET(STATE("signinPath"))
	SET OBJ("routes","signout")=$GET(STATE("signoutPath"))
	SET OBJ("routes","guestSignin")=$GET(STATE("guestSigninPath"))
	SET OBJ("routes","websocket")=$GET(STATE("wsPath"))
	SET OBJ("routes","terminalWebsocket")=$GET(STATE("wsTerminalPath"))
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
	SET OBJ("desktop","realtimeContract")=$GET(STATE("transportModel"),"core-websocket-plus-app-websockets")
	SET OBJ("desktop","taskbarOrder")="stable-order"
	SET OBJ("desktop","noMarkupData")=1
	SET OBJ("desktop","accessibility","rtl")=+$GET(STATE("a11yRtl"),0)
	SET OBJ("desktop","accessibility","keyboardModel")=$GET(STATE("a11yKeyboardModel"),"desktop-first")
	SET OBJ("desktop","accessibility","screenReaderHints")=+$GET(STATE("a11yScreenReaderHints"),1)
	SET OBJ("desktop","accessibility","motionPreference")=$GET(STATE("a11yMotionPreference"),"respect-user-preference")
	SET OBJ("desktop","performance","clientModel")=$GET(STATE("perfClientModel"),"thin-vue-umd")
	SET OBJ("desktop","performance","renderBudgetMs")=+$GET(STATE("perfRenderBudgetMs"),16)
	SET OBJ("desktop","performance","payloadMode")=$GET(STATE("perfPayloadMode"),"tmp-global-safe")
	SET OBJ("desktop","performance","transport")=$GET(STATE("perfTransport"),"websocket-first-http-refresh")
	SET OBJ("auth","required")=+$GET(STATE("authRequired"),0)
	SET OBJ("auth","enabled")=+$GET(STATE("localAuthEnabled"),0)
	SET OBJ("auth","guestLoginEnabled")=+$GET(STATE("guestLoginEnabled"),0)
	SET OBJ("auth","mode")=$GET(STATE("authMode"),"anonymous")
	SET OBJ("routes","fsList")=$GET(STATE("fsListPath"))
	SET OBJ("routes","fsRead")=$GET(STATE("fsReadPath"))
	SET OBJ("routes","fsWrite")=$GET(STATE("fsWritePath"))
	SET OBJ("routes","fsMkdir")=$GET(STATE("fsMkdirPath"))
	SET OBJ("routes","fsMeta")=$GET(STATE("fsMetaPath"))
	SET OBJ("vfs","enabled")=+$GET(STATE("fsEnabled"),1)
	SET OBJ("vfs","transport")=$GET(STATE("fsTransport"),"http-and-websocket")
	SET OBJ("vfs","rootId")=$GET(STATE("fsRootId"),"root")
	SET OBJ("vfs","homeId")=$GET(STATE("fsHomeId"),"root")
	SET OBJ("vfs","chunkSize")=+$GET(STATE("fsChunkSize"),2048)
	SET OBJ("vfs","storage")="globals-only"
	SET OBJ("vfs","permissionsModel")="owner-role-flags"
	DO THEMES($NAME(OBJ("desktop","themes")),$GET(STATE("themeKey")))
	MERGE OBJ("apps")=STATE("apps")
	MERGE OBJ("windows")=STATE("windows")
	SET OBJ("terminal","enabled")=1
	SET OBJ("terminal","commandTransport")=$GET(CONF("mioos","terminal","commandTransport"),"dedicated-websocket")
	SET OBJ("terminal","websocketPath")=$GET(STATE("wsTerminalPath"))
	SET OBJ("terminal","websocketPollMs")=+$GET(CONF("mioos","terminal","websocket","pollMs"),250)
	SET OBJ("terminal","engine")=$GET(STATE("terminal","engine"),"xtermjs")
	SET OBJ("terminal","transport")=$GET(STATE("terminal","transport"),"pipe")
	SET OBJ("terminal","sessionModel")=$GET(STATE("terminal","sessionModel"),"multi-window-ydb-direct")
	SET OBJ("terminal","profile","fontFamily")=$GET(STATE("terminal","fontFamily"),"Consolas")
	SET OBJ("terminal","profile","fontSize")=+$GET(STATE("terminal","fontSize"),14)
	SET OBJ("terminal","profile","cursorBlink")=+$GET(STATE("terminal","cursorBlink"),1)
	SET OBJ("terminal","profile","cursorStyle")=$GET(STATE("terminal","cursorStyle"),"block")
	SET OBJ("terminal","profile","scrollback")=+$GET(STATE("terminal","scrollback"),2500)
	SET OBJ("terminal","profile","renderer")=$GET(STATE("terminal","renderer"),"canvas")
	SET OBJ("terminal","profile","unicode")=$GET(STATE("terminal","unicode"),"unicode11")
	SET OBJ("terminal","profile","rows")=+$GET(STATE("terminal","rows"),28)
	SET OBJ("terminal","profile","cols")=+$GET(STATE("terminal","cols"),112)
	SET OBJ("terminal","maxSessionsPerUser")=+$GET(STATE("terminal","maxSessions"),8)
	QUIT
	;
APPS(STATE)
	NEW CODE
	SET CODE=$GET(STATE("localeCode"),"en")
	KILL STATE("apps")
	SET STATE("apps",1,"key")="my-computer"
	SET STATE("apps",1,"title")=$$TXT^MIOOSI18N(CODE,"app.my-computer.title","My Computer")
	SET STATE("apps",1,"subtitle")=$$TXT^MIOOSI18N(CODE,"app.my-computer.subtitle","Browse drives, folders, and shell locations")
	SET STATE("apps",1,"icon")="💻"
	SET STATE("apps",1,"kind")="folder"
	SET STATE("apps",2,"key")="documents"
	SET STATE("apps",2,"title")=$$TXT^MIOOSI18N(CODE,"app.documents.title","My Documents")
	SET STATE("apps",2,"subtitle")=$$TXT^MIOOSI18N(CODE,"app.documents.subtitle","Personal workspace documents")
	SET STATE("apps",2,"icon")="📁"
	SET STATE("apps",2,"kind")="folder"
	SET STATE("apps",3,"key")="control-panel"
	SET STATE("apps",3,"title")=$$TXT^MIOOSI18N(CODE,"app.control-panel.title","Control Panel")
	SET STATE("apps",3,"subtitle")=$$TXT^MIOOSI18N(CODE,"app.control-panel.subtitle","Desktop settings and shell behavior")
	SET STATE("apps",3,"icon")="🛠"
	SET STATE("apps",3,"kind")="system"
	SET STATE("apps",4,"key")="terminal"
	SET STATE("apps",4,"title")=$$TXT^MIOOSI18N(CODE,"app.terminal.title","Terminal")
	SET STATE("apps",4,"subtitle")=$$TXT^MIOOSI18N(CODE,"app.terminal.subtitle","Websocket-backed MUMPS terminal surface")
	SET STATE("apps",4,"icon")=">_"
	SET STATE("apps",4,"kind")="tool"
	QUIT
	;
WINDOWS(STATE)
	NEW CODE
	SET CODE=$GET(STATE("localeCode"),"en")
	KILL STATE("windows")
	DO WIN(.STATE,1,"win-my-computer","my-computer",$$TXT^MIOOSI18N(CODE,"app.my-computer.title","My Computer"),88,72,760,500,4,"normal")
	DO WIN(.STATE,2,"win-documents","documents",$$TXT^MIOOSI18N(CODE,"app.documents.title","My Documents"),180,118,620,420,2,"minimized")
	DO WIN(.STATE,3,"win-control-panel","control-panel",$$TXT^MIOOSI18N(CODE,"app.control-panel.title","Control Panel"),240,92,540,400,1,"minimized")
	DO WIN(.STATE,4,"win-terminal-template","terminal",$$TXT^MIOOSI18N(CODE,"app.terminal.title","Terminal"),120,88,820,430,3,"closed")
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
	NEW I,ITEM,N
	KILL @ROOT
	SET N=0
	FOR I=1:1:$LENGTH($GET(CSV),",") DO
	. SET ITEM=$PIECE($GET(CSV),",",I)
	. QUIT:ITEM=""
	. SET N=N+1,@ROOT@(N)=ITEM
	QUIT
