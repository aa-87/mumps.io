MIOOSST ; MIOOS session and boot state
	QUIT
	;
LOAD(CONF,REQ,CTX,STATE,ERR)
	NEW USER,ROLES,AUTHOK,AUTHERR,AUTHREQ,DEVOK,UNAME,LOC,CODE
	KILL STATE,ERR
	SET ERR("routine")="MIOOSST"
	DO BOOTSTRAP^MIOOSAUTH(.CONF)
	DO INIT^MIOOSFS(.CONF)
	NEW PURGEUP,PURGEDN
	SET PURGEUP=$$PURGE^MIOOSFSUP(.CONF)
	SET PURGEDN=$$PURGE^MIOOSFSDN(.CONF)
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
	SET STATE("authMode")=$SELECT(+$$LOCALEN^MIOOSAUTH(.CONF)=1:"local-session-required",DEVOK=1:"dev-bypass",1:"local-session-required")
	SET STATE("guestLoginEnabled")=+$$GUESTEN^MIOOSAUTH(.CONF)
	SET STATE("localAuthEnabled")=+$$LOCALEN^MIOOSAUTH(.CONF)
	SET STATE("frameworkAuthEnabled")=1
	SET STATE("frameworkAuthMode")=$GET(CONF("mioos","auth","frameworkProvider"),"mioauth-session-jwt")
	SET STATE("auditEnabled")=+$GET(CONF("mioos","audit","enabled"),1)
	SET STATE("auditRetainDays")=+$GET(CONF("mioos","audit","retainDays"),365)
	SET STATE("auditReportLimit")=+$GET(CONF("mioos","audit","reportLimit"),20)
	SET STATE("auditReportWindowDays")=+$GET(CONF("mioos","audit","reportWindowDays"),30)
	SET STATE("authSessionAdminEnabled")=+$GET(CONF("mioos","auth","management","sessionAdminEnabled"),1)
	SET STATE("authAccountAdminEnabled")=+$GET(CONF("mioos","auth","management","accountAdminEnabled"),1)
	SET STATE("authSessionLimit")=+$GET(CONF("mioos","auth","management","sessionLimit"),20)
	IF STATE("authSessionLimit")<1 SET STATE("authSessionLimit")=20
	SET STATE("authAccountLimit")=+$GET(CONF("mioos","auth","management","accountLimit"),20)
	IF STATE("authAccountLimit")<1 SET STATE("authAccountLimit")=20
	SET STATE("brandTitle")=$GET(CONF("mioos","brand","title"),"MIOOS")
	SET STATE("brandSubtitle")=$$TXT^MIOOSI18N(CODE,"product.subtitle","MUMPS powered Windows XP style desktop")
	SET STATE("profile")=$$PROFILE(.CONF)
	SET STATE("principal")=$SELECT(USER'="":USER,1:"guest")
	SET STATE("userName")=$SELECT(UNAME'="":UNAME,AUTHREQ=1:$$TXT^MIOOSI18N(CODE,"auth.state.required","Sign in required"),1:$$TXT^MIOOSI18N(CODE,"common.guest","Guest"))
	IF ROLES="" SET ROLES=$SELECT(STATE("principal")="guest":"guest",1:"")
	SET STATE("roles")=ROLES
	SET STATE("authAdmin")=$$HASROLECSV(ROLES,"admin")
	SET STATE("sessionId")=$GET(CTX("auth","claims","sid")) IF STATE("sessionId")="" SET STATE("sessionId")=$SELECT(STATE("authenticated")=1:"mioos-auth",1:"mioos-shell")
	SET STATE("desktopPath")=$GET(CONF("mioos","route","desktop"),"/mioos")
	SET STATE("bootstrapPath")=$GET(CONF("mioos","route","bootstrap"),"/api/mioos/bootstrap")
	SET STATE("viewPath")=$GET(CONF("mioos","route","view"),"/api/mioos/view")
	SET STATE("signinPath")=$GET(CONF("mioos","route","signin"),"/api/mioos/auth/signin")
	SET STATE("publicSigninPath")=$GET(CONF("mioos","route","publicSignin"),STATE("signinPath"))
	SET STATE("signoutPath")=$GET(CONF("mioos","route","signout"),"/api/mioos/auth/signout")
	SET STATE("authRefreshPath")=$GET(CONF("mioos","route","authRefresh"),"/api/mioos/auth/refresh")
	SET STATE("guestSigninPath")=$GET(CONF("mioos","route","guestSignin"),"/api/mioos/auth/guest")
	SET STATE("passwordChangePath")=$GET(CONF("mioos","route","passwordChange"),"/api/mioos/auth/password/change")
	SET STATE("auditExportPath")=$GET(CONF("mioos","route","auditExport"),"/api/mioos/auth/audit/export")
	SET STATE("fsListPath")=$GET(CONF("mioos","route","fsList"),"/api/mioos/fs/list")
	SET STATE("fsReadPath")=$GET(CONF("mioos","route","fsRead"),"/api/mioos/fs/read")
	SET STATE("fsWritePath")=$GET(CONF("mioos","route","fsWrite"),"/api/mioos/fs/write")
	SET STATE("fsUploadPath")=$GET(CONF("mioos","route","fsUpload"),"/api/mioos/fs/upload")
	SET STATE("fsMkdirPath")=$GET(CONF("mioos","route","fsMkdir"),"/api/mioos/fs/mkdir")
	SET STATE("fsMetaPath")=$GET(CONF("mioos","route","fsMeta"),"/api/mioos/fs/meta")
	SET STATE("wsPath")=$GET(CONF("mioos","route","ws"),"/ws/mioos")
	SET STATE("fsEnabled")=+$GET(CONF("mioos","fs","enabled"),1)
	SET STATE("fsChunkSize")=+$GET(CONF("mioos","fs","chunkSize"),2048)
	SET STATE("fsTransport")=$GET(CONF("mioos","fs","transport"),"http-and-websocket")
	SET STATE("fsRootId")=$$ROOTID^MIOOSFS()
	SET STATE("fsHomeId")=$$HOMEID^MIOOSFS()
	SET STATE("wsTerminalPath")=$GET(CONF("mioos","route","wsTerminal"),"/ws/mioos/terminal")
	SET STATE("wsMaxSockets")=+$GET(CONF("mioos","websocket","maxSocketsPerSession"),6)
	IF STATE("wsMaxSockets")<1 SET STATE("wsMaxSockets")=1
	SET STATE("wsCoreSockets")=+$GET(CONF("mioos","websocket","coreSockets"),1)
	IF STATE("wsCoreSockets")<1 SET STATE("wsCoreSockets")=1
	IF STATE("wsCoreSockets")>STATE("wsMaxSockets") SET STATE("wsCoreSockets")=STATE("wsMaxSockets")
	SET STATE("wsFsSockets")=+$GET(CONF("mioos","websocket","fsSockets"),5)
	IF STATE("wsFsSockets")<1 SET STATE("wsFsSockets")=1
	IF STATE("wsFsSockets")>STATE("wsMaxSockets") SET STATE("wsFsSockets")=STATE("wsMaxSockets")
	SET STATE("wsUploadBatchSize")=+$GET(CONF("mioos","websocket","uploadBatchSize"),1)
	IF STATE("wsUploadBatchSize")<1 SET STATE("wsUploadBatchSize")=1
	IF STATE("wsUploadBatchSize")>8 SET STATE("wsUploadBatchSize")=8
	SET STATE("wsHeartbeatSeconds")=+$GET(CONF("mioos","websocket","heartbeatSeconds"),15)
	SET STATE("wsResumeWindowSeconds")=+$GET(CONF("mioos","websocket","resumeWindowSeconds"),180)
	SET STATE("wsMaxInflightPerChannel")=+$GET(CONF("mioos","websocket","maxInflightPerChannel"),4)
	SET STATE("wsDiagnosticsEnabled")=+$GET(CONF("mioos","websocket","diagnosticsEnabled"),1)
	SET STATE("wsRequestTimeoutMs")=+$GET(CONF("mioos","websocket","requestTimeoutMs"),15000)
	IF STATE("wsRequestTimeoutMs")<1000 SET STATE("wsRequestTimeoutMs")=15000
	SET STATE("wsUploadBeginTimeoutMs")=+$GET(CONF("mioos","websocket","uploadBeginTimeoutMs"),20000)
	IF STATE("wsUploadBeginTimeoutMs")<1000 SET STATE("wsUploadBeginTimeoutMs")=20000
	SET STATE("wsUploadChunkTimeoutMs")=+$GET(CONF("mioos","websocket","uploadChunkTimeoutMs"),30000)
	IF STATE("wsUploadChunkTimeoutMs")<1000 SET STATE("wsUploadChunkTimeoutMs")=30000
	SET STATE("wsUploadCommitTimeoutMs")=+$GET(CONF("mioos","websocket","uploadCommitTimeoutMs"),120000)
	IF STATE("wsUploadCommitTimeoutMs")<1000 SET STATE("wsUploadCommitTimeoutMs")=120000
	SET STATE("wsUploadAbortTimeoutMs")=+$GET(CONF("mioos","websocket","uploadAbortTimeoutMs"),15000)
	IF STATE("wsUploadAbortTimeoutMs")<1000 SET STATE("wsUploadAbortTimeoutMs")=15000
	SET STATE("wsUploadSocketOpenTimeoutMs")=+$GET(CONF("mioos","websocket","uploadSocketOpenTimeoutMs"),15000)
	IF STATE("wsUploadSocketOpenTimeoutMs")<1000 SET STATE("wsUploadSocketOpenTimeoutMs")=15000
	SET STATE("wsMaxFrameBytes")=+$GET(CONF("websocket","maxFrameBytes"),262144)
	SET STATE("wsMaxMessageBytes")=+$GET(CONF("websocket","maxMessageBytes"),1048576)
	SET STATE("uploadStaleSeconds")=+$GET(CONF("mioos","upload","staleSeconds"),1800)
	SET STATE("downloadStaleSeconds")=+$GET(CONF("mioos","download","staleSeconds"),900)
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
	SET STATE("windowSnapThreshold")=+$GET(CONF("mioos","desktop","windowSnapThreshold"),28)
	IF STATE("windowSnapThreshold")<12 SET STATE("windowSnapThreshold")=12
	SET STATE("windowTaskbarHeight")=+$GET(CONF("mioos","desktop","taskbarHeight"),40)
	IF STATE("windowTaskbarHeight")<32 SET STATE("windowTaskbarHeight")=32
	SET STATE("windowMinWidth")=+$GET(CONF("mioos","desktop","minWindowWidth"),320)
	IF STATE("windowMinWidth")<240 SET STATE("windowMinWidth")=240
	SET STATE("windowMinHeight")=+$GET(CONF("mioos","desktop","minWindowHeight"),220)
	IF STATE("windowMinHeight")<180 SET STATE("windowMinHeight")=180
	SET STATE("windowAnimations")=$GET(CONF("mioos","desktop","windowAnimations"),"subtle")
	SET STATE("a11yRtl")=+$GET(STATE("localeRtl"),0)
	SET STATE("a11yKeyboardModel")="desktop-first"
	SET STATE("a11yScreenReaderHints")=1
	SET STATE("a11yMotionPreference")="respect-user-preference"
	SET STATE("perfClientModel")="thin-vue-umd"
	SET STATE("perfRenderBudgetMs")=16
	SET STATE("perfPayloadMode")="tmp-global-safe"
	SET STATE("perfTransport")="websocket-first-http-refresh"
	SET STATE("moduleSystemEnabled")=+$GET(CONF("mioos","modules","enabled"),1)
	SET STATE("debugEnabled")=+$GET(CONF("mioos","debug","enabled"),1)
	SET STATE("debugEventLimit")=+$GET(CONF("mioos","debug","eventLimit"),50)
	IF STATE("debugEventLimit")<10 SET STATE("debugEventLimit")=10
	SET STATE("debugSnapshotVersion")=+$GET(CONF("mioos","debug","snapshotVersion"),1)
	SET STATE("moduleManifestVersion")=+$GET(CONF("mioos","modules","manifestVersion"),1)
	IF STATE("moduleManifestVersion")<1 SET STATE("moduleManifestVersion")=1
	SET STATE("moduleLauncher")=$GET(CONF("mioos","modules","launcher"),"desktop-icons-and-menu")
	SET STATE("moduleAppCatalogEnabled")=+$GET(CONF("mioos","modules","appCatalogEnabled"),1)
	SET STATE("moduleDynamicWindows")=+$GET(CONF("mioos","modules","dynamicWindows"),1)
	DO LOADTERM^MIOOSTERM(.STATE,.CONF)
	DO MODULES(.STATE,.CONF)
	DO APPS(.STATE)
	DO WINDOWS(.STATE)
	DO LOADPREFS(.STATE,.CONF)
	QUIT 1
	;
LOADPREFS(STATE,CONF)
	NEW USER,ROOT,KEY
	SET USER=$SELECT($GET(STATE("principal"))'="":$GET(STATE("principal")),1:"guest")
	SET ROOT=$NAME(^MIO("MIOOS","PREF",USER,"desktop"))
	SET STATE("desktopIconSize")=$SELECT($GET(@ROOT@("iconSize"))'="":$GET(@ROOT@("iconSize")),1:"medium")
	SET STATE("desktopSortMode")=$SELECT($GET(@ROOT@("sortMode"))'="":$GET(@ROOT@("sortMode")),1:"manual")
	KILL STATE("desktopLayout")
	SET KEY="" FOR  SET KEY=$ORDER(@ROOT@("positions",KEY)) QUIT:KEY=""  DO
	. SET STATE("desktopLayout","positions",KEY,"left")=+$GET(@ROOT@("positions",KEY,"left"))
	. SET STATE("desktopLayout","positions",KEY,"top")=+$GET(@ROOT@("positions",KEY,"top"))
	QUIT
	;
MERGELAYOUT(STATE,ROOT)
	NEW IDX,KEY
	SET IDX=0 FOR  SET IDX=$ORDER(@ROOT@(IDX)) QUIT:'IDX  DO
	. SET KEY=$GET(@ROOT@(IDX,"key")) QUIT:KEY=""
	. IF $DATA(STATE("desktopLayout","positions",KEY)) DO
	. . SET @ROOT@(IDX,"iconLeft")=+$GET(STATE("desktopLayout","positions",KEY,"left"))
	. . SET @ROOT@(IDX,"iconTop")=+$GET(STATE("desktopLayout","positions",KEY,"top"))
	. SET @ROOT@(IDX,"desktopIconSize")=$GET(STATE("desktopIconSize"),"medium")
	QUIT
	;
SAVELAYOUT(STATE,TREE,OUT,ERR)
	NEW USER,ROOT,KEY
	SET USER=$SELECT($GET(STATE("principal"))'="":$GET(STATE("principal")),1:"guest")
	SET ROOT=$NAME(^MIO("MIOOS","PREF",USER,"desktop"))
	KILL @ROOT
	SET @ROOT@("iconSize")=$SELECT($GET(TREE("iconSize"))'="":$GET(TREE("iconSize")),1:"medium")
	SET @ROOT@("sortMode")=$SELECT($GET(TREE("sortMode"))'="":$GET(TREE("sortMode")),1:"manual")
	SET KEY="" FOR  SET KEY=$ORDER(TREE("positions",KEY)) QUIT:KEY=""  DO
	. SET @ROOT@("positions",KEY,"left")=+$GET(TREE("positions",KEY,"left"))
	. SET @ROOT@("positions",KEY,"top")=+$GET(TREE("positions",KEY,"top"))
	SET OUT("saved")=1
	SET OUT("user")=USER
	SET OUT("iconSize")=@ROOT@("iconSize")
	SET OUT("sortMode")=@ROOT@("sortMode")
	QUIT 1
	;
HASROLECSV(CSV,ROLE)
	NEW I,X,FOUND
	SET FOUND=0
	FOR I=1:1:$LENGTH($GET(CSV),",") DO  QUIT:FOUND
	. SET X=$$LOW^MIOUTIL($$TRIM^MIOUTIL($PIECE($GET(CSV),",",I)))
	. IF X=$$LOW^MIOUTIL($GET(ROLE)) SET FOUND=1
	QUIT FOUND
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
	SET OBJ("routes","publicSignin")=$GET(STATE("publicSigninPath"),$GET(STATE("signinPath")))
	SET OBJ("routes","signout")=$GET(STATE("signoutPath"))
	SET OBJ("routes","authRefresh")=$GET(STATE("authRefreshPath"))
	SET OBJ("routes","guestSignin")=$GET(STATE("guestSigninPath"))
	SET OBJ("routes","websocket")=$GET(STATE("wsPath"))
	SET OBJ("routes","terminalWebsocket")=$GET(STATE("wsTerminalPath"))
	SET OBJ("routes","websocketPool")=$GET(STATE("wsPath"))
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
	SET OBJ("desktop","performance","uploadStrategy")="http-multipart-with-auth-refresh"
	SET OBJ("desktop","performance","downloadStrategy")="chunked-websocket-verified"
	SET OBJ("desktop","viewers","text")=1
	SET OBJ("desktop","viewers","image")=1
	SET OBJ("desktop","viewers","media")=1
	SET OBJ("desktop","viewers","pdf")=1
	SET OBJ("desktop","viewers","structured")=1
	SET OBJ("desktop","windowing","engine")=$GET(STATE("windowManager"),"mioos-native-vue-css")
	SET OBJ("desktop","windowing","snapThreshold")=+$GET(STATE("windowSnapThreshold"),28)
	SET OBJ("desktop","windowing","taskbarHeight")=+$GET(STATE("windowTaskbarHeight"),40)
	SET OBJ("desktop","windowing","minWidth")=+$GET(STATE("windowMinWidth"),320)
	SET OBJ("desktop","windowing","minHeight")=+$GET(STATE("windowMinHeight"),220)
	SET OBJ("desktop","windowing","animations")=$GET(STATE("windowAnimations"),"subtle")
	SET OBJ("desktop","windowing","resizeHandles")="all-edges-and-corners"
	SET OBJ("desktop","windowing","snapModel")="edges-and-corners"
	SET OBJ("desktop","windowing","doubleClickTitlebar")=1
	SET OBJ("desktop","windowing","dropUpload")=1
	SET OBJ("desktop","moduleSystem","enabled")=+$GET(STATE("moduleSystemEnabled"),1)
	SET OBJ("desktop","moduleSystem","launcher")=$GET(STATE("moduleLauncher"),"desktop-icons-and-menu")
	SET OBJ("desktop","moduleSystem","manifestVersion")=+$GET(STATE("moduleManifestVersion"),1)
	SET OBJ("desktop","moduleSystem","appCatalogEnabled")=+$GET(STATE("moduleAppCatalogEnabled"),1)
	SET OBJ("desktop","moduleSystem","dynamicWindows")=+$GET(STATE("moduleDynamicWindows"),1)
	SET OBJ("desktop","moduleSystem","appCatalogKey")="app-catalog"
	SET OBJ("desktop","moduleSystem","moduleCount")=+$GET(STATE("moduleCount"),0)
	SET OBJ("desktop","moduleSystem","debugAppKey")="debug-center"
	SET OBJ("desktop","debugCenter","enabled")=+$GET(STATE("debugEnabled"),1)
	SET OBJ("desktop","debugCenter","eventLimit")=+$GET(STATE("debugEventLimit"),50)
	SET OBJ("desktop","debugCenter","snapshotVersion")=+$GET(STATE("debugSnapshotVersion"),1)
	SET OBJ("auth","required")=+$GET(STATE("authRequired"),0)
	SET OBJ("auth","enabled")=+$GET(STATE("localAuthEnabled"),0)
	SET OBJ("auth","guestLoginEnabled")=+$GET(STATE("guestLoginEnabled"),0)
	SET OBJ("auth","mode")=$GET(STATE("authMode"),"local-session-required")
	SET OBJ("auth","unauthenticatedAccessAllowed")=0
	SET OBJ("auth","providers","local","enabled")=+$GET(STATE("localAuthEnabled"),0)
	SET OBJ("auth","providers","local","loginMode")="username-password"
	SET OBJ("auth","providers","local","guestAllowed")=+$GET(STATE("guestLoginEnabled"),0)
	SET OBJ("auth","providers","framework","enabled")=+$GET(STATE("frameworkAuthEnabled"),1)
	SET OBJ("auth","providers","framework","mode")=$GET(STATE("frameworkAuthMode"),"mioauth-session-jwt")
	SET OBJ("auth","providers","framework","tokenType")="jwt"
	SET OBJ("auth","providers","framework","sessionCookie")=$GET(CONF("mioos","localAuth","tokenCookie"),"mioos_auth")
	SET OBJ("auth","tokenMaxAgeSeconds")=+$GET(CONF("mioos","localAuth","tokenMaxAgeSeconds"),604800)
	SET OBJ("auth","refreshWindowSeconds")=+$GET(CONF("mioos","localAuth","refreshWindowSeconds"),300)
	SET OBJ("auth","lockout","threshold")=+$GET(CONF("mioos","localAuth","lockThreshold"),5)
	SET OBJ("auth","lockout","minutes")=+$GET(CONF("mioos","localAuth","lockMinutes"),15)
	SET OBJ("auth","passwordPolicy","minLength")=+$GET(CONF("mioos","localAuth","passwordPolicy","minLength"),12)
	SET OBJ("auth","passwordPolicy","requireUpper")=+$GET(CONF("mioos","localAuth","passwordPolicy","requireUpper"),1)
	SET OBJ("auth","passwordPolicy","requireLower")=+$GET(CONF("mioos","localAuth","passwordPolicy","requireLower"),1)
	SET OBJ("auth","passwordPolicy","requireDigit")=+$GET(CONF("mioos","localAuth","passwordPolicy","requireDigit"),1)
	SET OBJ("auth","passwordPolicy","requireSymbol")=+$GET(CONF("mioos","localAuth","passwordPolicy","requireSymbol"),1)
	SET OBJ("auth","passwordPolicy","maxAgeDays")=+$GET(CONF("mioos","localAuth","passwordPolicy","maxAgeDays"),90)
	SET OBJ("auth","passwordPolicy","warnDays")=+$GET(CONF("mioos","localAuth","passwordPolicy","warnDays"),14)
	SET OBJ("auth","passwordPolicy","changeTokenMinutes")=+$GET(CONF("mioos","localAuth","passwordPolicy","changeTokenMinutes"),15)
	SET OBJ("auth","audit","enabled")=+$GET(STATE("auditEnabled"),1)
	SET OBJ("auth","audit","retainDays")=+$GET(STATE("auditRetainDays"),365)
	SET OBJ("auth","audit","reportLimit")=+$GET(STATE("auditReportLimit"),20)
	SET OBJ("auth","audit","reportWindowDays")=+$GET(STATE("auditReportWindowDays"),30)
	SET OBJ("auth","audit","scope")=$SELECT(+$GET(STATE("authAdmin"),0)=1:"all",1:"self")
	SET OBJ("auth","management","sessionAdminEnabled")=+$GET(STATE("authSessionAdminEnabled"),1)
	SET OBJ("auth","management","accountAdminEnabled")=+$GET(STATE("authAccountAdminEnabled"),1)
	SET OBJ("auth","management","sessionLimit")=+$GET(STATE("authSessionLimit"),20)
	SET OBJ("auth","management","accountLimit")=+$GET(STATE("authAccountLimit"),20)
	SET OBJ("auth","management","adminRole")="admin"
	SET OBJ("routes","passwordChange")=$GET(STATE("passwordChangePath"))
	SET OBJ("routes","auditExport")=$GET(STATE("auditExportPath"))
	SET OBJ("routes","debugSnapshotCommand")="debug.snapshot"
	SET OBJ("routes","fsList")=$GET(STATE("fsListPath"))
	SET OBJ("routes","fsRead")=$GET(STATE("fsReadPath"))
	SET OBJ("routes","fsWrite")=$GET(STATE("fsWritePath"))
	SET OBJ("routes","fsUpload")=$GET(STATE("fsUploadPath"))
	SET OBJ("routes","fsMkdir")=$GET(STATE("fsMkdirPath"))
	SET OBJ("routes","fsMeta")=$GET(STATE("fsMetaPath"))
	SET OBJ("vfs","enabled")=+$GET(STATE("fsEnabled"),1)
	SET OBJ("vfs","transport")=$GET(STATE("fsTransport"),"http-and-websocket")
	SET OBJ("vfs","rootId")=$GET(STATE("fsRootId"),"root")
	SET OBJ("vfs","homeId")=$GET(STATE("fsHomeId"),"root")
	SET OBJ("vfs","chunkSize")=+$GET(STATE("fsChunkSize"),2048)
	SET OBJ("vfs","uploadChunkBytes")=$$UPCHUNK^MIOOSFSUP(.CONF)
	SET OBJ("vfs","uploadConcurrency")=$$UPCONCUR^MIOOSFSUP(.CONF)
	SET OBJ("vfs","uploadBatchSize")=+$GET(STATE("wsUploadBatchSize"),1)
	SET OBJ("vfs","downloadChunkBytes")=$$DLCHUNK^MIOOSFSDN(.CONF)
	SET OBJ("vfs","downloadVerifyHash")=1
	SET OBJ("vfs","uploadStaleSeconds")=+$GET(STATE("uploadStaleSeconds"),1800)
	SET OBJ("vfs","downloadStaleSeconds")=+$GET(STATE("downloadStaleSeconds"),900)
	SET OBJ("vfs","transferControls","cancel")=1
	SET OBJ("vfs","transferControls","retry")=1
	SET OBJ("vfs","storage")="globals-only"
	SET OBJ("vfs","permissionsModel")="owner-role-flags"
	SET OBJ("desktop","icons","enabled")=1
	SET OBJ("desktop","icons","draggable")=1
	SET OBJ("desktop","icons","size")=$GET(STATE("desktopIconSize"),"medium")
	SET OBJ("desktop","icons","sortMode")=$GET(STATE("desktopSortMode"),"manual")
	SET OBJ("desktop","icons","sizeOptions",1)="small"
	SET OBJ("desktop","icons","sizeOptions",2)="medium"
	SET OBJ("desktop","icons","sizeOptions",3)="large"
	SET OBJ("desktop","contextMenu","desktop")=1
	SET OBJ("desktop","contextMenu","icon")=1
	SET OBJ("desktop","contextMenu","verbs",1)="refresh"
	SET OBJ("desktop","contextMenu","verbs",2)="rearrange"
	SET OBJ("desktop","contextMenu","verbs",3)="sort-name"
	SET OBJ("desktop","contextMenu","verbs",4)="sort-type"
	SET OBJ("desktop","contextMenu","verbs",5)="size-small"
	SET OBJ("desktop","contextMenu","verbs",6)="size-medium"
	SET OBJ("desktop","contextMenu","verbs",7)="size-large"
	SET OBJ("desktop","contextMenu","verbs",8)="personalize"
	SET OBJ("desktop","contextMenu","verbs",9)="control-panel"
	SET OBJ("desktop","contextMenu","verbs",10)="open"
	DO THEMES($NAME(OBJ("desktop","themes")),$GET(STATE("themeKey")))
	MERGE OBJ("apps")=STATE("apps")
	DO MERGELAYOUT(.STATE,$NAME(OBJ("apps")))
	MERGE OBJ("windows")=STATE("windows")
	MERGE OBJ("modules")=STATE("modules")
	SET OBJ("websocket","maxSocketsPerSession")=+$GET(STATE("wsMaxSockets"),6)
	SET OBJ("websocket","coreSockets")=+$GET(STATE("wsCoreSockets"),1)
	SET OBJ("websocket","fsSockets")=+$GET(STATE("wsFsSockets"),5)
	SET OBJ("websocket","uploadBatchSize")=+$GET(STATE("wsUploadBatchSize"),1)
	SET OBJ("websocket","heartbeatSeconds")=+$GET(STATE("wsHeartbeatSeconds"),15)
	SET OBJ("websocket","resumeWindowSeconds")=+$GET(STATE("wsResumeWindowSeconds"),180)
	SET OBJ("websocket","maxInflightPerChannel")=+$GET(STATE("wsMaxInflightPerChannel"),4)
	SET OBJ("websocket","diagnosticsEnabled")=+$GET(STATE("wsDiagnosticsEnabled"),1)
	SET OBJ("websocket","requestTimeoutMs")=+$GET(STATE("wsRequestTimeoutMs"),15000)
	SET OBJ("websocket","uploadBeginTimeoutMs")=+$GET(STATE("wsUploadBeginTimeoutMs"),20000)
	SET OBJ("websocket","uploadChunkTimeoutMs")=+$GET(STATE("wsUploadChunkTimeoutMs"),30000)
	SET OBJ("websocket","uploadCommitTimeoutMs")=+$GET(STATE("wsUploadCommitTimeoutMs"),120000)
	SET OBJ("websocket","uploadAbortTimeoutMs")=+$GET(STATE("wsUploadAbortTimeoutMs"),15000)
	SET OBJ("websocket","uploadSocketOpenTimeoutMs")=+$GET(STATE("wsUploadSocketOpenTimeoutMs"),15000)
	SET OBJ("websocket","maxFrameBytes")=+$GET(STATE("wsMaxFrameBytes"),262144)
	SET OBJ("websocket","maxMessageBytes")=+$GET(STATE("wsMaxMessageBytes"),1048576)
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
	NEW CODE,N,I,KEY
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
	SET STATE("apps",5,"key")="theme-studio"
	SET STATE("apps",5,"title")="Theme Studio"
	SET STATE("apps",5,"subtitle")="Customize wallpapers, colors, fonts, metrics, and shell recipes"
	SET STATE("apps",5,"icon")="🎨"
	SET STATE("apps",5,"kind")="tool"
	SET STATE("apps",6,"key")="transfers"
	SET STATE("apps",6,"title")="Transfers"
	SET STATE("apps",6,"subtitle")="Uploads, downloads, queue activity, and progress"
	SET STATE("apps",6,"icon")="⇅"
	SET STATE("apps",6,"kind")="tool"
	SET STATE("apps",7,"key")="diagnostics"
	SET STATE("apps",7,"title")="Diagnostics"
	SET STATE("apps",7,"subtitle")="Socket pool, transfer health, and session telemetry"
	SET STATE("apps",7,"icon")="📈"
	SET STATE("apps",7,"kind")="tool"
	SET N=7
	IF +$GET(STATE("moduleAppCatalogEnabled"),1)=1 DO
	. SET N=N+1
	. SET STATE("apps",N,"key")="app-catalog"
	. SET STATE("apps",N,"title")=$$TXT^MIOOSI18N(CODE,"app.app-catalog.title","App Catalog")
	. SET STATE("apps",N,"subtitle")=$$TXT^MIOOSI18N(CODE,"app.app-catalog.subtitle","Installed modules, launch policy, and built-in surfaces")
	. SET STATE("apps",N,"icon")="🧩"
	. SET STATE("apps",N,"kind")="system"
	SET I=0 FOR  SET I=$ORDER(STATE("modules",I)) QUIT:'I  DO
	. QUIT:+$GET(STATE("modules",I,"enabled"))'=1
	. SET N=N+1
	. SET KEY=$GET(STATE("modules",I,"appKey"),$GET(STATE("modules",I,"id")))
	. SET STATE("apps",N,"key")=KEY
	. SET STATE("apps",N,"title")=$GET(STATE("modules",I,"title"),KEY)
	. SET STATE("apps",N,"subtitle")=$GET(STATE("modules",I,"subtitle"),$GET(STATE("modules",I,"description")))
	. SET STATE("apps",N,"icon")=$GET(STATE("modules",I,"icon"),"🧩")
	. SET STATE("apps",N,"kind")="module"
	. SET STATE("apps",N,"moduleId")=$GET(STATE("modules",I,"id"))
	. SET STATE("apps",N,"moduleCategory")=$GET(STATE("modules",I,"category"),"general")
	. SET STATE("apps",N,"moduleBuiltIn")=+$GET(STATE("modules",I,"builtIn"),1)
	. SET STATE("apps",N,"moduleVersion")=$GET(STATE("modules",I,"version"),"1.0")
	SET N=N+1
	SET STATE("apps",N,"key")="security-center"
	SET STATE("apps",N,"title")="Security Center"
	SET STATE("apps",N,"subtitle")="Authentication posture, active sessions, account risk, and report export"
	SET STATE("apps",N,"icon")="🔐"
	SET STATE("apps",N,"kind")="system"
	IF +$GET(STATE("debugEnabled"),1)=1 DO
	. SET N=N+1
	. SET STATE("apps",N,"key")="debug-center"
	. SET STATE("apps",N,"title")=$$TXT^MIOOSI18N(CODE,"app.debug-center.title","Debug Center")
	. SET STATE("apps",N,"subtitle")=$$TXT^MIOOSI18N(CODE,"app.debug-center.subtitle","Server snapshot, command registry, and recent websocket activity")
	. SET STATE("apps",N,"icon")="🧪"
	. SET STATE("apps",N,"kind")="tool"
	QUIT
	;
MODULES(STATE,CONF)
	NEW CODE,N
	SET CODE=$GET(STATE("localeCode"),"en")
	KILL STATE("modules")
	SET N=0
	IF +$GET(STATE("moduleSystemEnabled"),1)'=1 SET STATE("moduleCount")=0 QUIT
	IF +$GET(CONF("mioos","modules","notes","enabled"),1)=1 DO
	. SET N=N+1
	. SET STATE("modules",N,"id")="module-notes"
	. SET STATE("modules",N,"appKey")="module-notes"
	. SET STATE("modules",N,"windowId")="win-module-notes"
	. SET STATE("modules",N,"title")=$$TXT^MIOOSI18N(CODE,"module.notes.title","Notes")
	. SET STATE("modules",N,"subtitle")=$$TXT^MIOOSI18N(CODE,"module.notes.subtitle","A lightweight notes surface for quick capture inside MIOOS")
	. SET STATE("modules",N,"description")=$$TXT^MIOOSI18N(CODE,"module.notes.description","Capture a short scratch note, track a few pinned cards, and keep module state inside the shell contract.")
	. SET STATE("modules",N,"icon")="📝"
	. SET STATE("modules",N,"category")="productivity"
	. SET STATE("modules",N,"version")="1.0"
	. SET STATE("modules",N,"kind")="module"
	. SET STATE("modules",N,"surface")="notes-board"
	. SET STATE("modules",N,"windowTitle")=$GET(STATE("modules",N,"title"))
	. SET STATE("modules",N,"installed")=1
	. SET STATE("modules",N,"enabled")=1
	. SET STATE("modules",N,"builtIn")=1
	. SET STATE("modules",N,"singleton")=1
	. SET STATE("modules",N,"launcherEnabled")=1
	. SET STATE("modules",N,"cards",1,"title")="Quick capture"
	. SET STATE("modules",N,"cards",1,"detail")="Use this space for release notes, shell TODOs, or operator breadcrumbs that do not belong in the terminal buffer."
	. SET STATE("modules",N,"cards",2,"title")="Server-authored"
	. SET STATE("modules",N,"cards",2,"detail")="The module manifest, window contract, and launcher metadata are emitted by MUMPS in the desktop boot payload."
	. SET STATE("modules",N,"cards",3,"title")="No extra runtime"
	. SET STATE("modules",N,"cards",3,"detail")="Modules stay inside the existing SSR plus Vue UMD shell model without introducing a separate package manager."
	IF +$GET(CONF("mioos","modules","opsCenter","enabled"),1)=1 DO
	. SET N=N+1
	. SET STATE("modules",N,"id")="module-ops-center"
	. SET STATE("modules",N,"appKey")="module-ops-center"
	. SET STATE("modules",N,"windowId")="win-module-ops-center"
	. SET STATE("modules",N,"title")=$$TXT^MIOOSI18N(CODE,"module.ops.title","Ops Center")
	. SET STATE("modules",N,"subtitle")=$$TXT^MIOOSI18N(CODE,"module.ops.subtitle","A built-in operational summary surface for the current shell session")
	. SET STATE("modules",N,"description")=$$TXT^MIOOSI18N(CODE,"module.ops.description","Review session identity, transport posture, and desktop contract metadata from one reusable module host.")
	. SET STATE("modules",N,"icon")="🧭"
	. SET STATE("modules",N,"category")="operations"
	. SET STATE("modules",N,"version")="1.0"
	. SET STATE("modules",N,"kind")="module"
	. SET STATE("modules",N,"surface")="ops-overview"
	. SET STATE("modules",N,"windowTitle")=$GET(STATE("modules",N,"title"))
	. SET STATE("modules",N,"installed")=1
	. SET STATE("modules",N,"enabled")=1
	. SET STATE("modules",N,"builtIn")=1
	. SET STATE("modules",N,"singleton")=1
	. SET STATE("modules",N,"launcherEnabled")=1
	. SET STATE("modules",N,"cards",1,"title")="Session"
	. SET STATE("modules",N,"cards",1,"detail")="Inspect the current principal, locale, and profile without opening the raw JSON boot payload."
	. SET STATE("modules",N,"cards",2,"title")="Transport"
	. SET STATE("modules",N,"cards",2,"detail")="Pairs well with Diagnostics: module hosts can consume existing shell state instead of building bespoke websocket channels."
	. SET STATE("modules",N,"cards",3,"title")="Extensibility"
	. SET STATE("modules",N,"cards",3,"detail")="This module demonstrates how built-ins can share one host template and one window contract while keeping their own manifest metadata."
	SET STATE("moduleCount")=N
	QUIT
	;
WINDOWS(STATE)
	NEW CODE,N,I,APPKEY,TITLE,MODW,MINW,MINH,LEFT,TOP,WIDTH,HEIGHT
	SET CODE=$GET(STATE("localeCode"),"en")
	KILL STATE("windows")
	DO WIN(.STATE,1,"win-my-computer","my-computer",$$TXT^MIOOSI18N(CODE,"app.my-computer.title","My Computer"),88,72,760,500,4,"normal",460,320,1,1)
	DO WIN(.STATE,2,"win-documents","documents",$$TXT^MIOOSI18N(CODE,"app.documents.title","My Documents"),180,118,620,420,2,"minimized",420,280,1,1)
	DO WIN(.STATE,3,"win-control-panel","control-panel",$$TXT^MIOOSI18N(CODE,"app.control-panel.title","Control Panel"),240,92,540,400,1,"minimized",420,280,1,1)
	DO WIN(.STATE,4,"win-terminal-template","terminal",$$TXT^MIOOSI18N(CODE,"app.terminal.title","Terminal"),120,88,820,430,3,"closed",560,300,1,1)
	DO WIN(.STATE,5,"win-theme-studio","theme-studio","Theme Studio",156,76,900,610,5,"closed",700,520,1,1)
	SET STATE("windows",5,"themeStudioEnabled")=1
	DO WIN(.STATE,6,"win-transfers","transfers","Transfers",218,108,760,520,6,"closed",620,420,1,1)
	SET STATE("windows",6,"transferCenterEnabled")=1
	DO WIN(.STATE,7,"win-diagnostics","diagnostics","Diagnostics",244,126,820,520,7,"closed",640,420,1,1)
	SET STATE("windows",7,"transportDiagnosticsEnabled")=+$GET(STATE("wsDiagnosticsEnabled"),1)
	SET N=7
	IF +$GET(STATE("moduleAppCatalogEnabled"),1)=1 DO
	. SET N=N+1
	. DO WIN(.STATE,N,"win-app-catalog","app-catalog",$$TXT^MIOOSI18N(CODE,"app.app-catalog.title","App Catalog"),268,122,860,560,N,"closed",660,420,1,1)
	. SET STATE("windows",N,"moduleCatalogEnabled")=1
	. SET STATE("windows",N,"moduleCatalogWindow")=1
	SET I=0 FOR  SET I=$ORDER(STATE("modules",I)) QUIT:'I  DO
	. QUIT:+$GET(STATE("modules",I,"enabled"))'=1
	. SET N=N+1
	. SET APPKEY=$GET(STATE("modules",I,"appKey"),$GET(STATE("modules",I,"id")))
	. SET TITLE=$GET(STATE("modules",I,"windowTitle"),$GET(STATE("modules",I,"title"),APPKEY))
	. SET LEFT=160+(I*26),TOP=94+(I*22),WIDTH=720,HEIGHT=500,MINW=560,MINH=340
	. DO WIN(.STATE,N,$GET(STATE("modules",I,"windowId"),"win-"_APPKEY),APPKEY,TITLE,LEFT,TOP,WIDTH,HEIGHT,N,"closed",MINW,MINH,1,1)
	. SET STATE("windows",N,"moduleWindow")=1
	. SET STATE("windows",N,"moduleId")=$GET(STATE("modules",I,"id"))
	. SET STATE("windows",N,"moduleCategory")=$GET(STATE("modules",I,"category"),"general")
	. SET STATE("windows",N,"moduleSurface")=$GET(STATE("modules",I,"surface"),"generic")
	. SET STATE("windows",N,"moduleBuiltIn")=+$GET(STATE("modules",I,"builtIn"),1)
	. SET STATE("windows",N,"moduleSingleton")=+$GET(STATE("modules",I,"singleton"),1)
	SET N=N+1
	DO WIN(.STATE,N,"win-security-center","security-center","Security Center",284,134,860,560,N,"closed",680,420,1,1)
	SET STATE("windows",N,"securityCenterEnabled")=1
	IF +$GET(STATE("debugEnabled"),1)=1 DO
	. SET N=N+1
	. DO WIN(.STATE,N,"win-debug-center","debug-center",$$TXT^MIOOSI18N(CODE,"app.debug-center.title","Debug Center"),308,146,900,580,N,"closed",700,440,1,1)
	. SET STATE("windows",N,"debugCenterEnabled")=1
	QUIT
	;
WIN(STATE,N,ID,APPKEY,TITLE,LEFT,TOP,WIDTH,HEIGHT,Z,MODE,MINW,MINH,RESIZE,DRAG)
	SET STATE("windows",N,"id")=ID
	SET STATE("windows",N,"appKey")=APPKEY
	SET STATE("windows",N,"title")=TITLE
	SET STATE("windows",N,"left")=LEFT
	SET STATE("windows",N,"top")=TOP
	SET STATE("windows",N,"width")=WIDTH
	SET STATE("windows",N,"height")=HEIGHT
	SET STATE("windows",N,"z")=Z
	SET STATE("windows",N,"state")=MODE
	SET STATE("windows",N,"minWidth")=+$GET(MINW,320)
	SET STATE("windows",N,"minHeight")=+$GET(MINH,220)
	SET STATE("windows",N,"resizable")=+$GET(RESIZE,1)
	SET STATE("windows",N,"draggable")=+$GET(DRAG,1)
	SET STATE("windows",N,"snappable")=1
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
