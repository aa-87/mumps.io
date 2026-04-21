MIOOSST ; MIOOS session and boot state
	QUIT
	;
LOAD(CONF,REQ,CTX,STATE,ERR)
	NEW USER,ROLES,AUTHOK,AUTHERR,AUTHREQ,DEVOK,UNAME,LOC,CODE
	KILL STATE,ERR
	SET ERR("routine")="MIOOSST"
	DO BOOTSTRAP^MIOOSAUTH(.CONF)
	DO INIT^MIOOSFS(.CONF)
	NEW PURGEUP
	SET PURGEUP=$$PURGE^MIOOSFSUP(.CONF)
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
	SET STATE("guestSigninPath")=$GET(CONF("mioos","route","guestSignin"),"/api/mioos/auth/guest")
	SET STATE("passwordChangePath")=$GET(CONF("mioos","route","passwordChange"),"/api/mioos/auth/password/change")
	SET STATE("auditExportPath")=$GET(CONF("mioos","route","auditExport"),"/api/mioos/auth/audit/export")
	SET STATE("fsListPath")=$GET(CONF("mioos","route","fsList"),"/api/mioos/fs/list")
	SET STATE("fsReadPath")=$GET(CONF("mioos","route","fsRead"),"/api/mioos/fs/read")
	SET STATE("fsWritePath")=$GET(CONF("mioos","route","fsWrite"),"/api/mioos/fs/write")
	SET STATE("fsMkdirPath")=$GET(CONF("mioos","route","fsMkdir"),"/api/mioos/fs/mkdir")
	SET STATE("fsMetaPath")=$GET(CONF("mioos","route","fsMeta"),"/api/mioos/fs/meta")
	SET STATE("fsUploadBeginPath")=$GET(CONF("mioos","route","fsUploadBegin"),"/api/mioos/fs/upload/begin")
	SET STATE("fsUploadChunkPath")=$GET(CONF("mioos","route","fsUploadChunk"),"/api/mioos/fs/upload/chunk")
	SET STATE("fsUploadStatusPath")=$GET(CONF("mioos","route","fsUploadStatus"),"/api/mioos/fs/upload/status")
	SET STATE("fsUploadCommitPath")=$GET(CONF("mioos","route","fsUploadCommit"),"/api/mioos/fs/upload/commit")
	SET STATE("fsUploadAbortPath")=$GET(CONF("mioos","route","fsUploadAbort"),"/api/mioos/fs/upload/abort")
	SET STATE("fsBlobPath")=$GET(CONF("mioos","route","fsBlob"),"/api/mioos/fs/blob")
	SET STATE("themeAssetUploadPath")=$GET(CONF("mioos","route","themeAssetUpload"),"/api/mioos/theme-asset/upload")
	SET STATE("themeAssetPath")=$GET(CONF("mioos","route","themeAsset"),"/api/mioos/theme-asset")
	SET STATE("wsPath")=$GET(CONF("mioos","route","ws"),"/ws/mioos")
	SET STATE("fsEnabled")=+$GET(CONF("mioos","fs","enabled"),1)
	SET STATE("fsChunkSize")=+$GET(CONF("mioos","fs","chunkSize"),1048576)
	SET STATE("fsHttpChunkBytes")=+$GET(CONF("mioos","download","httpChunkBytes"),1048576)
	SET STATE("fsReadPreviewBytes")=+$GET(CONF("mioos","fs","readPreviewBytes"),16384)
	SET STATE("fsReadWindowBytes")=+$GET(CONF("mioos","fs","readWindowBytes"),131072)
	SET STATE("fsTransferPersistence")=$GET(CONF("mioos","fs","transferPersistence"),"localstorage-resumable-transfer-list")
	SET STATE("fsMediaInitialBytes")=+$GET(CONF("mioos","download","mediaInitialBytes"),860000)
	SET STATE("fsMediaWarmupBytes")=+$GET(CONF("mioos","download","mediaWarmupBytes"),131072)
	SET STATE("fsTransport")=$GET(CONF("mioos","fs","transport"),"http-and-websocket")
	SET STATE("fsRootId")=$$ROOTID^MIOOSFS()
	SET STATE("fsHomeId")=$$HOMEID^MIOOSFS()
	SET STATE("wsTerminalPath")=$GET(CONF("mioos","route","wsTerminal"),"/ws/mioos/terminal")
	SET STATE("wsMaxSockets")=+$GET(CONF("mioos","websocket","maxSocketsPerSession"),6)
	SET STATE("wsCoreSockets")=+$GET(CONF("mioos","websocket","coreSockets"),1)
	SET STATE("wsFsSockets")=+$GET(CONF("mioos","websocket","fsSockets"),5)
	IF STATE("wsMaxSockets")<1 SET STATE("wsMaxSockets")=1
	IF STATE("wsCoreSockets")<1 SET STATE("wsCoreSockets")=1
	IF STATE("wsCoreSockets")>STATE("wsMaxSockets") SET STATE("wsCoreSockets")=STATE("wsMaxSockets")
	IF STATE("wsFsSockets")<1 SET STATE("wsFsSockets")=1
	IF STATE("wsFsSockets")>STATE("wsMaxSockets") SET STATE("wsFsSockets")=STATE("wsMaxSockets")
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
	SET STATE("wsMaxFrameBytes")=+$GET(CONF("websocket","maxFrameBytes"),131072)
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
	DO LOAD^MIOOSMOD(.STATE,.CONF)
	DO INIT^MIOOSPERM(.STATE,.CONF)
	DO APPS(.STATE)
	DO WINDOWS(.STATE)
	DO LOADPREFS(.STATE,.CONF)
	DO LOAD^MIOOSTH(.STATE,.CONF)
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
	SET OBJ("product","version")="roi52-v1-shell-permissions-modules"
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
	SET OBJ("routes","guestSignin")=$GET(STATE("guestSigninPath"))
	SET OBJ("routes","websocket")=$GET(STATE("wsPath"))
	SET OBJ("routes","terminalWebsocket")=$GET(STATE("wsTerminalPath"))
	SET OBJ("routes","commandEvent")=$GET(STATE("commandEvent"))
	SET OBJ("routes","commandResultEvent")=$GET(STATE("commandResultEvent"))
	SET OBJ("routes","commandErrorEvent")=$GET(STATE("commandErrorEvent"))
	SET OBJ("routes","themeAssetUpload")=$GET(STATE("themeAssetUploadPath"))
	SET OBJ("routes","themeAsset")=$GET(STATE("themeAssetPath"))
	SET OBJ("routes","themeLoadCommand")="desktop.theme.load"
	SET OBJ("routes","themeSaveCommand")="desktop.theme.save"
	SET OBJ("routes","permissionsReportCommand")="permissions.report"
	SET OBJ("routes","permissionsSaveCommand")="permissions.save"
	SET OBJ("routes","moduleInstallCommand")="module.install"
	SET OBJ("routes","moduleRemoveCommand")="module.remove"
	SET OBJ("desktop","themeKey")=$GET(STATE("themeKey"))
	SET OBJ("desktop","themePersistence")="websocket-user-global"
	SET OBJ("desktop","themeHydration")="miotpl-boot-style"
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
	SET OBJ("desktop","performance","uploadStrategy")="batched-chunk-pool"
	SET OBJ("desktop","performance","transferPersistence")=$GET(STATE("fsTransferPersistence"),"localstorage-resumable-transfer-list")
	SET OBJ("desktop","performance","downloadStrategy")="direct-http-range-native"
	SET OBJ("desktop","performance","downloadSendStrategy")="vfs-segment-streaming-http-blob"
	SET OBJ("desktop","performance","mediaStreamStrategy")="range-kickstart-http-blob-partial-window"
	SET OBJ("desktop","performance","uploadPreparation")="blob-slice-no-base64"
	SET OBJ("desktop","performance","uploadStrategy")="http-binary-parallel-slice-xhr-with-auto-pause"
	SET OBJ("desktop","performance","uploadFinalizeStrategy")="binary-direct-stage-promote-with-copy-on-overwrite"
	SET OBJ("desktop","performance","downloadStrategy")="direct-http-range-native"
	SET OBJ("desktop","performance","textPreviewStrategy")="windowed-websocket-range-read"
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
	SET OBJ("desktop","moduleSystem","installEnabled")=1
	SET OBJ("desktop","moduleSystem","installScopes",1)="user"
	SET OBJ("desktop","moduleSystem","installScopes",2)="system"
	SET OBJ("desktop","moduleSystem","manifestFields",1)="id"
	SET OBJ("desktop","moduleSystem","manifestFields",2)="title"
	SET OBJ("desktop","moduleSystem","manifestFields",3)="subtitle"
	SET OBJ("desktop","moduleSystem","manifestFields",4)="description"
	SET OBJ("desktop","moduleSystem","manifestFields",5)="icon"
	SET OBJ("desktop","moduleSystem","manifestFields",6)="category"
	SET OBJ("desktop","moduleSystem","manifestFields",7)="version"
	SET OBJ("desktop","moduleSystem","manifestFields",8)="surface"
	SET OBJ("desktop","moduleSystem","manifestFields",9)="windowTitle"
	SET OBJ("desktop","moduleSystem","manifestFields",10)="singleton"
	SET OBJ("desktop","moduleSystem","manifestFields",11)="launcherEnabled"
	SET OBJ("desktop","moduleSystem","manifestFields",12)="cards[]"
	SET OBJ("desktop","moduleSystem","manifestFields",13)="params[]"
	SET OBJ("desktop","permissions","enabled")=1
	SET OBJ("desktop","permissions","model")="shell-target-action-matrix"
	SET OBJ("desktop","permissions","editable")=+$GET(STATE("authAdmin"),0)
	SET OBJ("desktop","permissions","adminRole")="admin"
	SET OBJ("desktop","permissions","reportCommand")="permissions.report"
	SET OBJ("desktop","permissions","saveCommand")="permissions.save"
	SET OBJ("desktop","uiKit","enabled")=1
	SET OBJ("desktop","uiKit","libraryVersion")=1
	SET OBJ("desktop","uiKit","patterns",1)="cards"
	SET OBJ("desktop","uiKit","patterns",2)="stat-grid"
	SET OBJ("desktop","uiKit","patterns",3)="toolbar"
	SET OBJ("desktop","uiKit","patterns",4)="table"
	SET OBJ("desktop","uiKit","patterns",5)="form-grid"
	SET OBJ("desktop","uiKit","patterns",6)="section-shell"
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
	SET OBJ("routes","fsMkdir")=$GET(STATE("fsMkdirPath"))
	SET OBJ("routes","fsMeta")=$GET(STATE("fsMetaPath"))
	SET OBJ("routes","fsUploadBegin")=$GET(STATE("fsUploadBeginPath"))
	SET OBJ("routes","fsUploadChunk")=$GET(STATE("fsUploadChunkPath"))
	SET OBJ("routes","fsUploadStatus")=$GET(STATE("fsUploadStatusPath"))
	SET OBJ("routes","fsUploadCommit")=$GET(STATE("fsUploadCommitPath"))
	SET OBJ("routes","fsUploadAbort")=$GET(STATE("fsUploadAbortPath"))
	SET OBJ("routes","fsBlob")=$GET(STATE("fsBlobPath"))
	SET OBJ("vfs","enabled")=+$GET(STATE("fsEnabled"),1)
	SET OBJ("vfs","transport")=$GET(STATE("fsTransport"),"http-and-websocket")
	SET OBJ("vfs","rootId")=$GET(STATE("fsRootId"),"root")
	SET OBJ("vfs","homeId")=$GET(STATE("fsHomeId"),"root")
	SET OBJ("vfs","chunkSize")=+$GET(STATE("fsChunkSize"),860000)
	SET OBJ("vfs","uploadChunkBytes")=$$UPCHUNK^MIOOSFSUP(.CONF)
	SET OBJ("vfs","uploadConcurrency")=$$UPCONCUR^MIOOSFSUP(.CONF)
	SET OBJ("vfs","httpChunkBytes")=+$GET(STATE("fsHttpChunkBytes"),860000)
	SET OBJ("vfs","readPreviewBytes")=+$GET(STATE("fsReadPreviewBytes"),16384)
	SET OBJ("vfs","readWindowBytes")=+$GET(STATE("fsReadWindowBytes"),131072)
	SET OBJ("vfs","mediaInitialBytes")=+$GET(STATE("fsMediaInitialBytes"),860000)
	SET OBJ("vfs","mediaWarmupBytes")=+$GET(STATE("fsMediaWarmupBytes"),131072)
	SET OBJ("vfs","transferPersistence")=$GET(STATE("fsTransferPersistence"),"localstorage-resumable-transfer-list")
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
	SET OBJ("desktop","contextMenu","verbs",11)="new-terminal"
	SET OBJ("desktop","contextMenu","verbs",12)="security-center"
	SET OBJ("desktop","performance","uploadUiStrategy")="throttled-progress-updates-and-persistent-resume"
	DO THEMES($NAME(OBJ("desktop","themes")),$GET(STATE("themeKey")))
	IF $DATA(STATE("themeProfile"))>1 MERGE OBJ("desktop","themeProfile")=STATE("themeProfile")
	MERGE OBJ("apps")=STATE("apps")
	DO MERGELAYOUT(.STATE,$NAME(OBJ("apps")))
	MERGE OBJ("windows")=STATE("windows")
	MERGE OBJ("modules")=STATE("modules")
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
	SET OBJ("websocket","maxFrameBytes")=+$GET(STATE("wsMaxFrameBytes"),131072)
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
	SET N=0
	DO APP(.STATE,.N,"my-computer",$$TXT^MIOOSI18N(CODE,"app.my-computer.title","My Computer"),$$TXT^MIOOSI18N(CODE,"app.my-computer.subtitle","Browse drives, folders, and shell locations"),"💻","folder")
	DO APP(.STATE,.N,"documents",$$TXT^MIOOSI18N(CODE,"app.documents.title","My Documents"),$$TXT^MIOOSI18N(CODE,"app.documents.subtitle","Personal workspace documents"),"📁","folder")
	DO APP(.STATE,.N,"control-panel",$$TXT^MIOOSI18N(CODE,"app.control-panel.title","Control Panel"),$$TXT^MIOOSI18N(CODE,"app.control-panel.subtitle","Desktop settings, components, and shell behavior"),"🛠","system")
	DO APP(.STATE,.N,"terminal",$$TXT^MIOOSI18N(CODE,"app.terminal.title","Terminal"),$$TXT^MIOOSI18N(CODE,"app.terminal.subtitle","Websocket-backed MUMPS terminal surface"),">_","tool")
	DO APP(.STATE,.N,"theme-studio","Theme Studio","Customize wallpapers, colors, fonts, metrics, and shell recipes","🎨","tool")
	DO APP(.STATE,.N,"transfers","Transfers","Uploads, downloads, queue activity, and progress","⇅","tool")
	DO APP(.STATE,.N,"diagnostics","Diagnostics","Socket pool, transfer health, and session telemetry","📈","tool")
	IF +$GET(STATE("moduleAppCatalogEnabled"),1)=1 DO APP(.STATE,.N,"app-catalog",$$TXT^MIOOSI18N(CODE,"app.app-catalog.title","App Catalog"),$$TXT^MIOOSI18N(CODE,"app.app-catalog.subtitle","Installed modules, launch policy, and custom module manifests"),"🧩","system")
	SET I=0 FOR  SET I=$ORDER(STATE("modules",I)) QUIT:'I  DO
	. QUIT:+$GET(STATE("modules",I,"enabled"))'=1
	. SET KEY=$GET(STATE("modules",I,"appKey"),$GET(STATE("modules",I,"id")))
	. QUIT:'$$ALLOW^MIOOSPERM(.STATE,"module:"_$GET(STATE("modules",I,"id")),"run")
	. SET N=N+1
	. SET STATE("apps",N,"key")=KEY
	. SET STATE("apps",N,"title")=$GET(STATE("modules",I,"title"),KEY)
	. SET STATE("apps",N,"subtitle")=$GET(STATE("modules",I,"subtitle"),$GET(STATE("modules",I,"description")))
	. SET STATE("apps",N,"icon")=$GET(STATE("modules",I,"icon"),"🧩")
	. SET STATE("apps",N,"kind")="module"
	. SET STATE("apps",N,"moduleId")=$GET(STATE("modules",I,"id"))
	. SET STATE("apps",N,"moduleCategory")=$GET(STATE("modules",I,"category"),"general")
	. SET STATE("apps",N,"moduleBuiltIn")=+$GET(STATE("modules",I,"builtIn"),1)
	. SET STATE("apps",N,"moduleVersion")=$GET(STATE("modules",I,"version"),"1.0")
	. SET STATE("apps",N,"permissionsTarget")=$GET(STATE("modules",I,"permissionsTarget"),"module:"_$GET(STATE("modules",I,"id")))
	DO APP(.STATE,.N,"security-center","Security Center","Authentication posture, active sessions, account risk, permission matrix, and report export","🔐","system")
	IF +$GET(STATE("debugEnabled"),1)=1 DO APP(.STATE,.N,"debug-center",$$TXT^MIOOSI18N(CODE,"app.debug-center.title","Debug Center"),$$TXT^MIOOSI18N(CODE,"app.debug-center.subtitle","Server snapshot, command registry, and recent websocket activity"),"🧪","tool")
	SET STATE("appCount")=N
	QUIT
	;
APP(STATE,N,KEY,TITLE,SUBTITLE,ICON,KIND)
	IF '$$ALLOW^MIOOSPERM(.STATE,"app:"_$GET(KEY),"run") QUIT
	SET N=N+1
	SET STATE("apps",N,"key")=$GET(KEY)
	SET STATE("apps",N,"title")=$GET(TITLE)
	SET STATE("apps",N,"subtitle")=$GET(SUBTITLE)
	SET STATE("apps",N,"icon")=$GET(ICON)
	SET STATE("apps",N,"kind")=$GET(KIND)
	SET STATE("apps",N,"permissionsTarget")="app:"_$GET(KEY)
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
	. SET STATE("modules",N,"scope")="system"
	. SET STATE("modules",N,"owner")=""
	. SET STATE("modules",N,"permissionsTarget")="module:module-notes"
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
	. SET STATE("modules",N,"scope")="system"
	. SET STATE("modules",N,"owner")=""
	. SET STATE("modules",N,"permissionsTarget")="module:module-ops-center"
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
	NEW CODE,N,I,APPKEY,TITLE,MINW,MINH,LEFT,TOP,WIDTH,HEIGHT
	SET CODE=$GET(STATE("localeCode"),"en")
	KILL STATE("windows")
	SET N=0
	DO WINADD(.STATE,.N,"win-my-computer","my-computer",$$TXT^MIOOSI18N(CODE,"app.my-computer.title","My Computer"),72,54,860,560,460,320)
	DO WINADD(.STATE,.N,"win-documents","documents",$$TXT^MIOOSI18N(CODE,"app.documents.title","My Documents"),136,96,720,500,420,280)
	DO WINADD(.STATE,.N,"win-control-panel","control-panel",$$TXT^MIOOSI18N(CODE,"app.control-panel.title","Control Panel"),212,96,700,500,520,340)
	DO WINADD(.STATE,.N,"win-terminal-template","terminal",$$TXT^MIOOSI18N(CODE,"app.terminal.title","Terminal"),118,82,900,500,560,300)
	IF $$HASAPP(.STATE,"terminal") SET STATE("windows",N,"state")="closed"
	DO WINADD(.STATE,.N,"win-theme-studio","theme-studio","Theme Studio",144,64,980,640,720,520)
	IF $$HASAPP(.STATE,"theme-studio") SET STATE("windows",N,"themeStudioEnabled")=1
	DO WINADD(.STATE,.N,"win-transfers","transfers","Transfers",186,108,820,560,620,420)
	IF $$HASAPP(.STATE,"transfers") SET STATE("windows",N,"transferCenterEnabled")=1
	DO WINADD(.STATE,.N,"win-diagnostics","diagnostics","Diagnostics",238,126,900,580,680,440)
	IF $$HASAPP(.STATE,"diagnostics") SET STATE("windows",N,"transportDiagnosticsEnabled")=+$GET(STATE("wsDiagnosticsEnabled"),1)
	DO WINADD(.STATE,.N,"win-app-catalog","app-catalog",$$TXT^MIOOSI18N(CODE,"app.app-catalog.title","App Catalog"),224,96,980,620,720,500)
	IF $$HASAPP(.STATE,"app-catalog") SET STATE("windows",N,"moduleCatalogEnabled")=1,STATE("windows",N,"moduleCatalogWindow")=1
	SET I=0 FOR  SET I=$ORDER(STATE("modules",I)) QUIT:'I  DO
	. SET APPKEY=$GET(STATE("modules",I,"appKey"),$GET(STATE("modules",I,"id")))
	. QUIT:'$$HASAPP(.STATE,APPKEY)
	. SET TITLE=$GET(STATE("modules",I,"windowTitle"),$GET(STATE("modules",I,"title"),APPKEY))
	. SET LEFT=164+(I*24),TOP=92+(I*20),WIDTH=760,HEIGHT=520,MINW=560,MINH=340
	. DO WINADD(.STATE,.N,$GET(STATE("modules",I,"windowId"),"win-"_APPKEY),APPKEY,TITLE,LEFT,TOP,WIDTH,HEIGHT,MINW,MINH)
	. SET STATE("windows",N,"moduleWindow")=1
	. SET STATE("windows",N,"moduleId")=$GET(STATE("modules",I,"id"))
	. SET STATE("windows",N,"moduleCategory")=$GET(STATE("modules",I,"category"),"general")
	. SET STATE("windows",N,"moduleSurface")=$GET(STATE("modules",I,"surface"),"generic")
	. SET STATE("windows",N,"moduleBuiltIn")=+$GET(STATE("modules",I,"builtIn"),1)
	. SET STATE("windows",N,"moduleSingleton")=+$GET(STATE("modules",I,"singleton"),1)
	DO WINADD(.STATE,.N,"win-security-center","security-center","Security Center",252,124,980,620,720,500)
	IF $$HASAPP(.STATE,"security-center") SET STATE("windows",N,"securityCenterEnabled")=1
	DO WINADD(.STATE,.N,"win-debug-center","debug-center",$$TXT^MIOOSI18N(CODE,"app.debug-center.title","Debug Center"),278,138,940,600,720,460)
	IF $$HASAPP(.STATE,"debug-center") SET STATE("windows",N,"debugCenterEnabled")=1
	QUIT
	;
WINADD(STATE,N,ID,APPKEY,TITLE,LEFT,TOP,WIDTH,HEIGHT,MINW,MINH)
	IF '$$HASAPP(.STATE,$GET(APPKEY)) QUIT
	SET N=N+1
	DO WIN(.STATE,N,$GET(ID),$GET(APPKEY),$GET(TITLE),+$GET(LEFT),+$GET(TOP),+$GET(WIDTH),+$GET(HEIGHT),N,"closed",+$GET(MINW),+$GET(MINH),1,1)
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
HASAPP(STATE,APPKEY)
	NEW I,FOUND
	SET (I,FOUND)=0
	FOR  SET I=$ORDER(STATE("apps",I)) QUIT:I'>0  DO  QUIT:FOUND
	. IF $GET(STATE("apps",I,"key"))=$GET(APPKEY) SET FOUND=1
	QUIT FOUND
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
	;