MIOOSST ; MIOOS session and boot state
	QUIT
	;
LOAD(CONF,REQ,CTX,STATE,ERR)
	NEW USER,ROLES,AUTHOK,AUTHERR,AUTHREQ,DEVOK,UNAME,LOC,CODE
	KILL STATE,ERR
	SET ERR("routine")="MIOOSST"
	DO BOOTSTRAP^MIOOSAUTH(.CONF)
	DO INIT^MIOOSFS(.CONF)
	DO APPLY^MIOOSCFG(.CONF)
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
	SET STATE("brandSubtitle")=$$TXT^MIOOSI18N(CODE,"product.subtitle","MUMPS-powered web desktop shell")
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
	SET STATE("fsSetMetaPath")=$GET(CONF("mioos","route","fsSetMeta"),"/api/mioos/fs/setmeta")
	SET STATE("fsUploadBeginPath")=$GET(CONF("mioos","route","fsUploadBegin"),"/api/mioos/fs/upload/begin")
	SET STATE("fsUploadChunkPath")=$GET(CONF("mioos","route","fsUploadChunk"),"/api/mioos/fs/upload/chunk")
	SET STATE("fsUploadStatusPath")=$GET(CONF("mioos","route","fsUploadStatus"),"/api/mioos/fs/upload/status")
	SET STATE("fsUploadCommitPath")=$GET(CONF("mioos","route","fsUploadCommit"),"/api/mioos/fs/upload/commit")
	SET STATE("fsUploadAbortPath")=$GET(CONF("mioos","route","fsUploadAbort"),"/api/mioos/fs/upload/abort")
	SET STATE("fsBlobPath")=$GET(CONF("mioos","route","fsBlob"),"/api/mioos/fs/blob")
	SET STATE("tableQueryPath")=$GET(CONF("mioos","route","tableQuery"),"/api/mioos/table/query")
	SET STATE("tableMutatePath")=$GET(CONF("mioos","route","tableMutate"),"/api/mioos/table/mutate")
	SET STATE("moduleCatalogPath")=$GET(CONF("mioos","route","moduleCatalog"),"/api/mioos/modules/catalog")
	SET STATE("moduleTablePath")=$GET(CONF("mioos","route","moduleTable"),"/api/mioos/modules/table")
	SET STATE("settingsLoadPath")=$GET(CONF("mioos","route","settingsLoad"),"/api/mioos/settings/load")
	SET STATE("settingsSavePath")=$GET(CONF("mioos","route","settingsSave"),"/api/mioos/settings/save")
	SET STATE("themeAssetUploadPath")=$GET(CONF("mioos","route","themeAssetUpload"),"/api/mioos/theme-asset/upload")
	SET STATE("themeAssetPath")=$GET(CONF("mioos","route","themeAsset"),"/api/mioos/theme-asset")
	SET STATE("themeLoadPath")=$GET(CONF("mioos","route","themeLoad"),"/api/mioos/theme/load")
	SET STATE("themeSavePath")=$GET(CONF("mioos","route","themeSave"),"/api/mioos/theme/save")
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
	SET STATE("fsDesktopId")=$$DESKTOPID^MIOOSFS()
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
	SET STATE("uploadBatchSize")=$$UPBATCH^MIOOSFSUP(.CONF)
	SET STATE("uploadMaxInflightChunks")=$$UPINFLGT^MIOOSFSUP(.CONF)
	SET STATE("uploadBatchFlushThreshold")=$$UPFLUSH^MIOOSFSUP(.CONF)
	SET STATE("themeKey")=$GET(CONF("mioos","desktop","theme"),"luna-blue")
	SET STATE("wallpaper")=$GET(CONF("mioos","desktop","wallpaper"),"aurora")
	SET STATE("density")=$GET(CONF("mioos","desktop","density"),"comfortable")
	SET STATE("fontFamily")=$GET(CONF("mioos","desktop","fontFamily"),"Segoe UI")
	SET STATE("fontSize")=+$GET(CONF("mioos","desktop","fontSize"),13)
	SET STATE("launcherLabel")=$$TXT^MIOOSI18N(CODE,"launcher.menu","Menu")
	SET STATE("commandEvent")=$GET(CONF("mioos","desktop","transport","eventName"),"desktop.command")
	SET STATE("commandResultEvent")=$GET(CONF("mioos","desktop","transport","resultEvent"),"desktop.result")
	SET STATE("commandErrorEvent")=$GET(CONF("mioos","desktop","transport","errorEvent"),"desktop.error")
	SET STATE("transportModel")=$GET(CONF("mioos","desktop","transport","model"),"core-websocket-plus-app-websockets")
	SET STATE("themeMode")=$GET(CONF("mioos","desktop","themeMode"),$SELECT($GET(CONF("mioos","desktop","theme"))["dark":"dark",1:"light"))
	DO ACTIVETHM(.STATE,.CONF)
	DO THEMEBOOT(.STATE,.CONF)
	SET STATE("themeSystemEditor")=$GET(CONF("mioos","desktop","themeSystem","editor"),"customize")
	SET STATE("themeSystemPersistence")=$GET(CONF("mioos","desktop","themeSystem","persistence"),"globals-profile-service-with-localstorage-fallback")
	SET STATE("themeSystemLiveApply")=+$GET(CONF("mioos","desktop","themeSystem","liveApply"),1)
	SET STATE("themeSystemQuickSwitch")=+$GET(CONF("mioos","desktop","themeSystem","quickSwitch"),1)
	SET STATE("themeSystemVersion")=+$GET(CONF("mioos","desktop","themeSystem","version"),4)
	SET STATE("shellChrome")=$GET(CONF("mioos","desktop","chrome"),"shell-foundation")
	SET STATE("taskbarStyle")=$GET(CONF("mioos","desktop","taskbarStyle"),"taskbar-foundation")
	SET STATE("startMenuStyle")=$GET(CONF("mioos","desktop","startMenuStyle"),"launcher-foundation")
	SET STATE("windowManager")=$GET(CONF("mioos","desktop","windowManager"),"mioos-native-vue-css")
	SET STATE("windowChrome")=$GET(CONF("mioos","desktop","windowChrome"),"reusable-shell-chrome")
	SET STATE("windowTitlebarHeight")=+$GET(CONF("mioos","desktop","windowTitlebarHeight"),40)
	IF STATE("windowTitlebarHeight")<32 SET STATE("windowTitlebarHeight")=32
	SET STATE("windowMenuEnabled")=+$GET(CONF("mioos","desktop","windowMenuEnabled"),1)
	SET STATE("windowStatusBadges")=+$GET(CONF("mioos","desktop","windowStatusBadges"),1)
		SET STATE("workspacesEnabled")=+$GET(CONF("mioos","desktop","workspaces","enabled"),0)
		SET STATE("workspacesPersistence")=$GET(CONF("mioos","desktop","workspaces","persistence"),"none")
		SET STATE("workspacesDefaultKey")=$GET(CONF("mioos","desktop","workspaces","defaultKey"),"workspace-main")
		SET STATE("workspacesShowInTaskbar")=+$GET(CONF("mioos","desktop","workspaces","showInTaskbar"),0)
		SET STATE("workspacesFollowMovedWindow")=+$GET(CONF("mioos","desktop","workspaces","followMovedWindow"),1)
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
	SET STATE("debugEnabled")=0
	SET STATE("debugEventLimit")=+$GET(CONF("mioos","debug","eventLimit"),50)
	IF STATE("debugEventLimit")<10 SET STATE("debugEventLimit")=10
	SET STATE("debugSnapshotVersion")=+$GET(CONF("mioos","debug","snapshotVersion"),1)
	SET STATE("moduleManifestVersion")=+$GET(CONF("mioos","modules","manifestVersion"),1)
	IF STATE("moduleManifestVersion")<1 SET STATE("moduleManifestVersion")=1
	SET STATE("moduleLauncher")=$GET(CONF("mioos","modules","launcher"),"desktop-icons-and-menu")
	SET STATE("moduleAppCatalogEnabled")=+$GET(CONF("mioos","modules","appCatalogEnabled"),1)
	SET STATE("moduleDynamicWindows")=+$GET(CONF("mioos","modules","dynamicWindows"),1)
	DO LOADTERM^MIOOSTERM(.STATE,.CONF)
		DO WORKSPACES(.STATE)
	DO MODULES(.STATE,.CONF)
	DO APPS(.STATE)
	DO WINDOWS(.STATE)
	DO LOADPREFS(.STATE,.CONF)
	QUIT 1
	;
ACTIVETHM(STATE,CONF)
	NEW OUT,ERR,KEY,MODE,DENSITY
	KILL OUT,ERR,STATE("activeThemeProfile"),STATE("activeThemeKey")
	IF '+$GET(STATE("authenticated")) QUIT
	IF '+$$LOAD^MIOOSTHEME(.STATE,.CONF,.OUT,.ERR) QUIT
	IF '+$DATA(OUT("profile")) QUIT
	MERGE STATE("activeThemeProfile")=OUT("profile")
	SET STATE("activeThemeKey")=$GET(OUT("profileKey"),$GET(OUT("activeKey")))
	SET KEY=$GET(STATE("activeThemeProfile","presetKey"))
	IF KEY="" SET KEY=$GET(STATE("activeThemeProfile","key"))
	IF KEY'="" SET STATE("themeKey")=KEY
	SET MODE=$GET(STATE("activeThemeProfile","mode"))
	IF MODE="" SET MODE=$GET(STATE("activeThemeProfile","activeMode"))
	IF MODE'="" SET STATE("themeMode")=MODE
	SET DENSITY=$GET(STATE("activeThemeProfile","density"))
	IF DENSITY="" SET DENSITY=$GET(STATE("activeThemeProfile","appearance","density"))
	IF DENSITY'="" SET STATE("density")=DENSITY
	QUIT
	;
THEMEBOOT(STATE,CONF)
	NEW DESK,WID,URL,FIT
	SET STATE("theme")=$GET(STATE("themeKey"),"luna-blue")
	SET URL=$GET(STATE("activeThemeProfile","desktop","wallpaperUrl"))
	SET WID=$GET(STATE("activeThemeProfile","desktop","wallpaperId"))
	IF URL="",WID'="" SET URL=$GET(STATE("fsBlobPath"),"/api/mioos/fs/blob")_"?id="_WID
	SET FIT=$GET(STATE("activeThemeProfile","desktop","wallpaperFit"))
	IF FIT="" SET FIT=$GET(CONF("mioos","desktop","wallpaperFit"),"cover")
	IF URL="" DO
	. SET DESK=$GET(STATE("fsDesktopId"))
	. IF DESK="" SET DESK=$$DESKTOPID^MIOOSFS()
	. SET WID=$$METAFIELD^MIOOSFS(DESK,"wallpaperId")
	. IF WID'="" SET URL=$GET(STATE("fsBlobPath"),"/api/mioos/fs/blob")_"?id="_WID
	. IF URL="" SET URL=$GET(CONF("mioos","desktop","wallpaperUrl"))
	IF '+$GET(STATE("authenticated"),0),$$PROTURL(URL,.STATE) SET URL="",WID=""
	SET STATE("wallpaperUrl")=URL
	SET STATE("wallpaperId")=WID
	SET STATE("wallpaperFit")=FIT
	QUIT
	;
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
SANPROF(ROOT,STATE)
	NEW K,V
	IF $GET(@ROOT@("desktop","wallpaperUrl"))'="",$$PROTURL($GET(@ROOT@("desktop","wallpaperUrl")),.STATE) SET @ROOT@("desktop","wallpaperUrl")=""
	IF $GET(@ROOT@("wallpaperUrl"))'="",$$PROTURL($GET(@ROOT@("wallpaperUrl")),.STATE) SET @ROOT@("wallpaperUrl")=""
	IF $GET(@ROOT@("loginScreenConfig","wallpaperUrl"))'="",$$PROTURL($GET(@ROOT@("loginScreenConfig","wallpaperUrl")),.STATE) SET @ROOT@("loginScreenConfig","wallpaperUrl")=""
	SET K="" FOR  SET K=$ORDER(@ROOT@("cssVars",K)) QUIT:K=""  DO
	. SET V=$GET(@ROOT@("cssVars",K)) IF V'="",$$PROTURL(V,.STATE) KILL @ROOT@("cssVars",K)
	SET K="" FOR  SET K=$ORDER(@ROOT@("colors",K)) QUIT:K=""  DO
	. SET V=$GET(@ROOT@("colors",K)) IF V'="",$$PROTURL(V,.STATE) KILL @ROOT@("colors",K)
	QUIT
	;

LOADPREFS(STATE,CONF)
	NEW USER,ROOT,KEY
	SET USER=$SELECT($GET(STATE("principal"))'="":$GET(STATE("principal")),1:"guest")
	SET ROOT=$NAME(^MIO("MIOOS","PREF",USER,"desktop"))
	SET STATE("desktopIconSize")=$SELECT($GET(@ROOT@("iconSize"))'="":$GET(@ROOT@("iconSize")),1:"medium")
	SET STATE("desktopSortMode")=$SELECT($GET(@ROOT@("sortMode"))'="":$GET(@ROOT@("sortMode")),1:"manual")
	KILL STATE("desktopLayout")
	SET KEY="" FOR  SET KEY=$ORDER(@ROOT@("positions",KEY)) QUIT:KEY=""  DO
	. SET STATE("desktopLayout","positions",KEY,"left")=$GET(@ROOT@("positions",KEY,"left"))
	. SET STATE("desktopLayout","positions",KEY,"top")=$GET(@ROOT@("positions",KEY,"top"))
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
	NEW USER,ROOT,KEY,RID,DESK,SAVED
	SET USER=$SELECT($GET(STATE("principal"))'="":$GET(STATE("principal")),1:"guest")
	SET ROOT=$NAME(^MIO("MIOOS","PREF",USER,"desktop"))
	KILL @ROOT@("positions")
	SET @ROOT@("iconSize")=$SELECT($GET(TREE("iconSize"))'="":$GET(TREE("iconSize")),1:"medium")
	SET @ROOT@("sortMode")=$SELECT($GET(TREE("sortMode"))'="":$GET(TREE("sortMode")),1:"manual")
	SET DESK=$GET(STATE("fsDesktopId")) IF DESK="" SET DESK=$$DESKTOPID^MIOOSFS()
	SET SAVED=0,KEY="" FOR  SET KEY=$ORDER(TREE("positions",KEY)) QUIT:KEY=""  DO
	. SET RID=KEY
	. IF '$$EXISTS^MIOOSFS(RID) QUIT
	. IF $$FIELD^MIOOSFS(RID,2)'=DESK QUIT
	. DO SETMETAFLD^MIOOSFS(RID,"iconLeft",+$GET(TREE("positions",KEY,"left")))
	. DO SETMETAFLD^MIOOSFS(RID,"iconTop",+$GET(TREE("positions",KEY,"top")))
	. SET SAVED=SAVED+1
	SET OUT("saved")=1
	SET OUT("savedPositions")=SAVED
	SET OUT("storage")="vfs-entry-meta"
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
	SET OBJ("product","subtitle")=$GET(STATE("brandSubtitle"),"MUMPS-powered web desktop shell")
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
	SET OBJ("routes","guestSignin")=$GET(STATE("guestSigninPath"))
	SET OBJ("routes","websocket")=$GET(STATE("wsPath"))
	SET OBJ("routes","terminalWebsocket")=$GET(STATE("wsTerminalPath"))
	SET OBJ("routes","commandEvent")=$GET(STATE("commandEvent"))
	SET OBJ("routes","commandResultEvent")=$GET(STATE("commandResultEvent"))
	SET OBJ("routes","commandErrorEvent")=$GET(STATE("commandErrorEvent"))
	SET OBJ("desktop","themeKey")=$GET(STATE("themeKey"))
	SET OBJ("desktop","theme")=$GET(STATE("theme"),$GET(STATE("themeKey")))
	SET OBJ("desktop","wallpaper")=$GET(STATE("wallpaper"))
	SET OBJ("desktop","wallpaperUrl")=$GET(STATE("wallpaperUrl"))
	SET OBJ("desktop","wallpaperId")=$GET(STATE("wallpaperId"))
	SET OBJ("desktop","wallpaperFit")=$GET(STATE("wallpaperFit"),"cover")
	SET OBJ("desktop","density")=$GET(STATE("density"))
	SET OBJ("desktop","fontFamily")=$GET(STATE("fontFamily"))
	SET OBJ("desktop","fontSize")=+$GET(STATE("fontSize"),13)
	SET OBJ("desktop","launcherLabel")=$GET(STATE("launcherLabel"),"Menu")
	SET OBJ("desktop","themeMode")=$GET(STATE("themeMode"),"light")
	SET OBJ("desktop","shellChrome")=$GET(STATE("shellChrome"),"shell-foundation")
	SET OBJ("desktop","taskbarStyle")=$GET(STATE("taskbarStyle"),"taskbar-foundation")
	SET OBJ("desktop","startMenuStyle")=$GET(STATE("startMenuStyle"),"launcher-foundation")
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
	SET OBJ("desktop","components","table")=1
	SET OBJ("desktop","components","tableBackend")="MIOOSTBL"
	SET OBJ("desktop","windowing","engine")=$GET(STATE("windowManager"),"mioos-native-vue-css")
	SET OBJ("desktop","windowing","chrome")=$GET(STATE("windowChrome"),"reusable-shell-chrome")
	SET OBJ("desktop","windowing","titlebarHeight")=+$GET(STATE("windowTitlebarHeight"),40)
	SET OBJ("desktop","windowing","windowMenuEnabled")=+$GET(STATE("windowMenuEnabled"),1)
	SET OBJ("desktop","windowing","statusBadges")=+$GET(STATE("windowStatusBadges"),1)
	SET OBJ("desktop","windowing","snapThreshold")=+$GET(STATE("windowSnapThreshold"),28)
	SET OBJ("desktop","windowing","taskbarHeight")=+$GET(STATE("windowTaskbarHeight"),40)
	SET OBJ("desktop","windowing","minWidth")=+$GET(STATE("windowMinWidth"),320)
	SET OBJ("desktop","windowing","minHeight")=+$GET(STATE("windowMinHeight"),220)
	SET OBJ("desktop","windowing","animations")=$GET(STATE("windowAnimations"),"subtle")
	SET OBJ("desktop","windowing","resizeHandles")="all-edges-and-corners"
	SET OBJ("desktop","windowing","snapModel")="edges-and-corners"
	SET OBJ("desktop","windowing","doubleClickTitlebar")=1
	SET OBJ("desktop","windowing","dropUpload")=1
	SET OBJ("desktop","windowing","snapShortcuts","left")=$GET(CONF("mioos","desktop","accessibility","keyboardShortcuts","snapLeft"),"Alt+Shift+ArrowLeft")
	SET OBJ("desktop","windowing","snapShortcuts","right")=$GET(CONF("mioos","desktop","accessibility","keyboardShortcuts","snapRight"),"Alt+Shift+ArrowRight")
	SET OBJ("desktop","windowing","snapShortcuts","maximize")=$GET(CONF("mioos","desktop","accessibility","keyboardShortcuts","maximizeFocusedWindow"),"Alt+Shift+ArrowUp")
	SET OBJ("desktop","windowing","snapShortcuts","restore")=$GET(CONF("mioos","desktop","accessibility","keyboardShortcuts","restoreFocusedWindow"),"Alt+Shift+ArrowDown")
	SET OBJ("desktop","moduleSystem","enabled")=+$GET(STATE("moduleSystemEnabled"),0)
	SET OBJ("desktop","moduleSystem","launcher")=$GET(STATE("moduleLauncher"),"desktop-icons-and-menu")
	SET OBJ("desktop","moduleSystem","manifestVersion")=+$GET(STATE("moduleManifestVersion"),1)
	SET OBJ("desktop","moduleSystem","appCatalogEnabled")=+$GET(STATE("moduleAppCatalogEnabled"),0)
	SET OBJ("desktop","moduleSystem","dynamicWindows")=+$GET(STATE("moduleDynamicWindows"),1)
	SET OBJ("desktop","moduleSystem","appCatalogKey")="ui-modules"
	SET OBJ("desktop","moduleSystem","moduleCount")=+$GET(STATE("moduleCount"),0)
	SET OBJ("desktop","moduleSystem","debugAppKey")=""
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
	SET OBJ("routes","fsSetMeta")=$GET(STATE("fsSetMetaPath"))
	SET OBJ("routes","fsUploadBegin")=$GET(STATE("fsUploadBeginPath"))
	SET OBJ("routes","fsUploadChunk")=$GET(STATE("fsUploadChunkPath"))
	SET OBJ("routes","fsUploadStatus")=$GET(STATE("fsUploadStatusPath"))
	SET OBJ("routes","fsUploadCommit")=$GET(STATE("fsUploadCommitPath"))
	SET OBJ("routes","fsUploadAbort")=$GET(STATE("fsUploadAbortPath"))
	SET OBJ("routes","fsBlob")=$GET(STATE("fsBlobPath"))
	SET OBJ("routes","tableQuery")=$GET(STATE("tableQueryPath"))
	SET OBJ("routes","tableMutate")=$GET(STATE("tableMutatePath"))
	SET OBJ("routes","moduleCatalog")=$GET(STATE("moduleCatalogPath"))
	SET OBJ("routes","moduleTable")=$GET(STATE("moduleTablePath"))
	SET OBJ("routes","settingsLoad")=$GET(STATE("settingsLoadPath"))
	SET OBJ("routes","settingsSave")=$GET(STATE("settingsSavePath"))
	SET OBJ("routes","themeAssetUpload")=$GET(STATE("themeAssetUploadPath"))
	SET OBJ("routes","themeAsset")=$GET(STATE("themeAssetPath"))
	SET OBJ("routes","themeLoad")=$GET(STATE("themeLoadPath"))
	SET OBJ("routes","themeSave")=$GET(STATE("themeSavePath"))
	SET OBJ("vfs","enabled")=+$GET(STATE("fsEnabled"),1)
	SET OBJ("vfs","transport")=$GET(STATE("fsTransport"),"http-and-websocket")
	SET OBJ("vfs","rootId")=$GET(STATE("fsRootId"),"root")
	SET OBJ("vfs","homeId")=$GET(STATE("fsHomeId"),"root")
	SET OBJ("vfs","desktopId")=$GET(STATE("fsDesktopId"),$GET(STATE("fsRootId"),"root"))
	SET OBJ("vfs","chunkSize")=+$GET(STATE("fsChunkSize"),860000)
	SET OBJ("vfs","uploadChunkBytes")=$$UPCHUNK^MIOOSFSUP(.CONF)
	SET OBJ("vfs","uploadConcurrency")=$$UPCONCUR^MIOOSFSUP(.CONF)
	SET OBJ("vfs","uploadBatchSize")=+$GET(STATE("uploadBatchSize"),1)
	SET OBJ("vfs","uploadMaxInflightChunks")=+$GET(STATE("uploadMaxInflightChunks"),+$GET(STATE("uploadBatchSize"),1))
	SET OBJ("vfs","batchFlushThreshold")=+$GET(STATE("uploadBatchFlushThreshold"),+$GET(STATE("uploadBatchSize"),1))
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
	SET OBJ("desktop","contextMenu","verbs",8)="customize"
	SET OBJ("desktop","contextMenu","verbs",9)="open"
	SET OBJ("desktop","contextMenu","verbs",10)=""
	SET OBJ("desktop","shellSurfaces","explorer")=1
	SET OBJ("desktop","shellSurfaces","customize")=1
	SET OBJ("desktop","shellSurfaces","transfers")=1
	SET OBJ("desktop","shellSurfaces","folderProperties")=1
	SET OBJ("desktop","shellSurfaces","notifications")=1
	SET OBJ("desktop","shellSurfaces","dialogs")=1
	SET OBJ("desktop","shellSurfaces","windowSwitcher")=1
	SET OBJ("desktop","shellSurfaces","moduleWindows")=0
	SET OBJ("desktop","appSurfaceModel")=$GET(CONF("mioos","desktop","appSurfaceModel"),"shell-standard-actions")
	SET OBJ("desktop","appActions","confirmBeforeDestructive")=+$GET(CONF("mioos","desktop","appActions","confirmBeforeDestructive"),1)
	SET OBJ("desktop","appActions","notifyOnAdminActions")=+$GET(CONF("mioos","desktop","appActions","notifyOnAdminActions"),1)
	SET OBJ("desktop","appActions","copyExportsToClipboard")=+$GET(CONF("mioos","desktop","appActions","copyExportsToClipboard"),1)
	SET OBJ("desktop","appActions","moduleNotesSessionLocal")=+$GET(CONF("mioos","desktop","appActions","moduleNotesSessionLocal"),1)
	SET OBJ("desktop","notifications","model")=$GET(STATE("notificationsModel"),"tray-panel")
	SET OBJ("desktop","notifications","stackLimit")=+$GET(STATE("notificationsStackLimit"),6)
	SET OBJ("desktop","notifications","tray")=1
	SET OBJ("desktop","dialogs","model")="shell-standard"
	SET OBJ("desktop","dialogs","confirm")=1
	SET OBJ("desktop","dialogs","input")=1
		SET OBJ("desktop","workspaces","enabled")=+$GET(STATE("workspacesEnabled"),1)
		SET OBJ("desktop","workspaces","model")="single-desktop"
		SET OBJ("desktop","workspaces","persistence")=$GET(STATE("workspacesPersistence"),"none")
		SET OBJ("desktop","workspaces","currentKey")=$GET(STATE("workspacesDefaultKey"),"workspace-main")
		SET OBJ("desktop","workspaces","showInTaskbar")=+$GET(STATE("workspacesShowInTaskbar"),1)
		SET OBJ("desktop","workspaces","followMovedWindow")=+$GET(STATE("workspacesFollowMovedWindow"),1)
		SET OBJ("desktop","workspaces","switchShortcuts","previous")=""
		SET OBJ("desktop","workspaces","switchShortcuts","next")=""
		SET OBJ("desktop","workspaces","moveShortcuts","previous")=""
		SET OBJ("desktop","workspaces","moveShortcuts","next")=""
		DO MERGEWK(.STATE,$NAME(OBJ("desktop","workspaces","items")))
		SET OBJ("desktop","shellSurfaces","workspacePager")=0
	SET OBJ("desktop","shortcuts","showDesktop")="Meta+D"
	SET OBJ("desktop","shortcuts","windowSwitcher")="Alt+Tab"
	SET OBJ("desktop","shortcuts","closeFocusedWindow")="Shift+Escape"
	SET OBJ("desktop","shortcuts","openDiagnostics")="Ctrl+Shift+Escape"
	SET OBJ("desktop","persistence","desktopLayout")="vfs-entry-meta"
	SET OBJ("desktop","persistence","windowLayout")="localstorage-window-layout"
	SET OBJ("desktop","persistence","authWindow")="localstorage-auth-window-frame"
	SET OBJ("desktop","accessibility","reducedMotionToggle")=1
	SET OBJ("desktop","themeSystem","version")=+$GET(STATE("themeSystemVersion"),4)
	SET OBJ("desktop","themeSystem","editor")=$GET(STATE("themeSystemEditor"),"customize")
	SET OBJ("desktop","themeSystem","persistence")=$GET(STATE("themeSystemPersistence"),"globals-profile-service-with-localstorage-fallback")
	SET OBJ("desktop","themeSystem","liveApply")=+$GET(STATE("themeSystemLiveApply"),1)
	SET OBJ("desktop","themeSystem","quickSwitch")=+$GET(STATE("themeSystemQuickSwitch"),1)
	SET OBJ("desktop","themeSystem","densityOptions",1)="compact"
	SET OBJ("desktop","themeSystem","densityOptions",2)="comfortable"
	SET OBJ("desktop","themeSystem","densityOptions",3)="spacious"
	SET OBJ("desktop","themeSystem","windowGrammar")="7css-primary"
	SET OBJ("desktop","themeSystem","controlAugment")="basecoat-augment"
	SET OBJ("desktop","themeSystem","presetFamilies",1,"key")="meadow-classic"
	SET OBJ("desktop","themeSystem","presetFamilies",1,"title")="Meadow Classic"
	SET OBJ("desktop","themeSystem","presetFamilies",2,"key")="glass-horizon"
	SET OBJ("desktop","themeSystem","presetFamilies",2,"title")="Glass Horizon"
	SET OBJ("desktop","themeSystem","presetFamilies",3,"key")="graphite-dock"
	SET OBJ("desktop","themeSystem","presetFamilies",3,"title")="Graphite Dock"
	SET OBJ("desktop","themeSystem","presetFamilies",4,"key")="ember-panel"
	SET OBJ("desktop","themeSystem","presetFamilies",4,"title")="Ember Panel"
	SET OBJ("desktop","performance","uploadUiStrategy")="throttled-progress-updates-and-persistent-resume"
	SET OBJ("desktop","performance","uploadBatching")="websocket-batch-with-single-chunk-fallback"
	DO THEMES($NAME(OBJ("desktop","themes")),$GET(STATE("themeKey")))
	IF $DATA(STATE("activeThemeProfile")) DO
	. MERGE OBJ("desktop","activeThemeProfile")=STATE("activeThemeProfile")
	. IF '+$GET(STATE("authenticated"),0) DO SANPROF($NAME(OBJ("desktop","activeThemeProfile")),.STATE)
	IF $GET(STATE("activeThemeKey"))'="" SET OBJ("desktop","activeThemeKey")=$GET(STATE("activeThemeKey"))
	MERGE OBJ("apps")=STATE("apps")
	DO MERGELAYOUT(.STATE,$NAME(OBJ("apps")))
	KILL OBJ("desktopEntries"),OBJ("desktopFolder")
	DO DESKTOPVM^MIOOSVM(.STATE,.CONF,$NAME(OBJ("desktopEntries")),$NAME(OBJ("desktopFolder")))
	SET OBJ("desktop","canonicalDesktopPath")="/Home/Desktop"
	SET OBJ("desktop","desktopFolderId")=$GET(STATE("fsDesktopId"))
	MERGE OBJ("windows")=STATE("windows")
	MERGE OBJ("modules")=STATE("modules")
	MERGE OBJ("uiModules")=STATE("uiModules")
	SET OBJ("websocket","heartbeatSeconds")=+$GET(STATE("wsHeartbeatSeconds"),15)
	SET OBJ("websocket","resumeWindowSeconds")=+$GET(STATE("wsResumeWindowSeconds"),180)
	SET OBJ("websocket","maxInflightPerChannel")=+$GET(STATE("wsMaxInflightPerChannel"),4)
	SET OBJ("websocket","maxSocketsPerSession")=+$GET(STATE("wsMaxSockets"),1)
	SET OBJ("websocket","coreSockets")=+$GET(STATE("wsCoreSockets"),1)
	SET OBJ("websocket","fsSockets")=+$GET(STATE("wsFsSockets"),1)
	SET OBJ("websocket","uploadBatchSize")=+$GET(STATE("uploadBatchSize"),1)
	SET OBJ("websocket","uploadMaxInflightChunks")=+$GET(STATE("uploadMaxInflightChunks"),+$GET(STATE("uploadBatchSize"),1))
	SET OBJ("websocket","batchFlushThreshold")=+$GET(STATE("uploadBatchFlushThreshold"),+$GET(STATE("uploadBatchSize"),1))
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
	NEW CODE
	SET CODE=$GET(STATE("localeCode"),"en")
	KILL STATE("apps")
	SET STATE("apps",1,"key")="home"
	SET STATE("apps",1,"title")=$$TXT^MIOOSI18N(CODE,"app.home.title","Home")
	SET STATE("apps",1,"subtitle")="Secure desktop for files, launchers, and application folders"
	SET STATE("apps",1,"icon")="🏠"
	SET STATE("apps",1,"kind")="explorer"
	SET STATE("apps",2,"key")="terminal"
	SET STATE("apps",2,"title")=$$TXT^MIOOSI18N(CODE,"app.terminal.title","Terminal")
	SET STATE("apps",2,"subtitle")="Websocket-backed MUMPS terminal session"
	SET STATE("apps",2,"icon")=">_"
	SET STATE("apps",2,"kind")="tool"
	SET STATE("apps",3,"key")="transfers"
	SET STATE("apps",3,"title")="Transfers"
	SET STATE("apps",3,"subtitle")="Operational transfer manager for uploads, downloads, and recovery"
	SET STATE("apps",3,"icon")="⇅"
	SET STATE("apps",3,"kind")="tool"
	SET STATE("apps",4,"key")="customize"
	SET STATE("apps",4,"title")="Theme Studio"
	SET STATE("apps",4,"subtitle")="Themes, Appearance, Desktop, Taskbar, Start Menu, and Login Screen"
	SET STATE("apps",4,"icon")="🎨"
	SET STATE("apps",4,"kind")="tool"
	SET STATE("apps",5,"key")="control-panel"
	SET STATE("apps",5,"title")="System Settings"
	SET STATE("apps",5,"subtitle")="Server-backed MIOOS configuration with validation and safeguards"
	SET STATE("apps",5,"icon")="⚙"
	SET STATE("apps",5,"kind")="tool"
	IF +$GET(STATE("moduleSystemEnabled"),0),+$GET(STATE("moduleAppCatalogEnabled"),0),$GET(STATE("moduleLauncher"),"desktop-icons-and-menu")'="hidden" DO
	. SET STATE("apps",6,"key")="patient-registration"
	. SET STATE("apps",6,"title")="Patient Registration"
	. SET STATE("apps",6,"subtitle")="Search, review queues, and duplicate resolution"
	. SET STATE("apps",6,"icon")="🏥"
	. SET STATE("apps",6,"kind")="module"
	. SET STATE("apps",7,"key")="ui-modules"
	. SET STATE("apps",7,"title")="UI Modules"
	. SET STATE("apps",7,"subtitle")="Create and launch internal or user-created UI modules"
	. SET STATE("apps",7,"icon")="▦"
	. SET STATE("apps",7,"kind")="tool"
	QUIT
	;
WORKSPACES(STATE)
		NEW CODE
		SET CODE=$GET(STATE("localeCode"),"en")
		KILL STATE("workspaces")
		SET STATE("workspaces",1,"key")="workspace-main"
		SET STATE("workspaces",1,"title")=$$TXT^MIOOSI18N(CODE,"workspace.main","Desktop")
		SET STATE("workspaces",1,"icon")="⌂"
		SET STATE("workspaces",1,"description")=$$TXT^MIOOSI18N(CODE,"workspace.main.description","Single desktop surface for all application windows")
		SET STATE("workspaces",1,"ordinal")=1
		QUIT
		;
MERGEWK(STATE,ROOT)
		NEW WK,ORD
		KILL @ROOT
		SET WK=0,ORD=0
		FOR  SET WK=$ORDER(STATE("workspaces",WK)) QUIT:'WK  DO
		. SET ORD=ORD+1
		. SET @ROOT@(ORD,"key")=$GET(STATE("workspaces",WK,"key"))
		. SET @ROOT@(ORD,"title")=$GET(STATE("workspaces",WK,"title"))
		. SET @ROOT@(ORD,"icon")=$GET(STATE("workspaces",WK,"icon"))
		. SET @ROOT@(ORD,"description")=$GET(STATE("workspaces",WK,"description"))
		. SET @ROOT@(ORD,"ordinal")=+$GET(STATE("workspaces",WK,"ordinal"),ORD)
		QUIT
		;
MODULES(STATE,CONF)
	DO LOAD^MIOOSMOD(.STATE,.CONF)
	QUIT
	;
WINDOWS(STATE)
	NEW CODE
	SET CODE=$GET(STATE("localeCode"),"en")
	KILL STATE("windows")
	DO WIN(.STATE,1,"win-home","home",$$TXT^MIOOSI18N(CODE,"app.home.title","Home"),96,72,980,620,4,"normal",520,340,1,1,"explorer","🏠","workspace-main",1)
	DO WIN(.STATE,2,"win-terminal-template","terminal",$$TXT^MIOOSI18N(CODE,"app.terminal.title","Terminal"),160,92,900,520,3,"closed",620,320,1,1,"terminal","⌨","workspace-main",0)
	DO WIN(.STATE,3,"win-transfers","transfers","Transfers",220,116,860,560,5,"closed",680,420,1,1,"transfers","⇅","workspace-main",1)
	SET STATE("windows",3,"transferCenterEnabled")=1
	DO WIN(.STATE,4,"win-customize","customize","Themes and Appearance",180,86,1040,680,6,"closed",780,560,1,1,"studio","🎨","workspace-main",1)
	SET STATE("windows",4,"themeStudioEnabled")=1
	DO WIN(.STATE,5,"win-folder-properties","folder-properties","Folder Properties",260,140,640,520,8,"closed",560,420,0,1,"properties","📂","workspace-main",0)
	SET STATE("windows",5,"propertySheetEnabled")=1
	DO WIN(.STATE,6,"win-control-panel","control-panel","System Settings",150,72,1080,680,7,"closed",820,520,1,1,"settings","⚙","workspace-main",1)
	SET STATE("windows",6,"systemSettingsEnabled")=1
	IF +$GET(STATE("moduleSystemEnabled"),0),+$GET(STATE("moduleAppCatalogEnabled"),0),$GET(STATE("moduleLauncher"),"desktop-icons-and-menu")'="hidden" DO
	. DO WIN(.STATE,7,"win-patient-registration","patient-registration","Patient Registration",132,76,1120,680,9,"closed",820,540,1,1,"module","🏥","workspace-main",1)
	. SET STATE("windows",7,"moduleWindow")=1
	. SET STATE("windows",7,"moduleId")="mioos.ui.patient.registration"
	. SET STATE("windows",7,"moduleComponent")="table"
	. SET STATE("windows",7,"surface")="mioos-surface-table"
	. SET STATE("windows",7,"tableState","id")="patient-registration-table"
	. SET STATE("windows",7,"tableState","title")="Patient Registration"
	. SET STATE("windows",7,"tableState","dataset")="patient-registration"
	. SET STATE("windows",7,"tableState","config","defaultSort","column")="lastName"
	. SET STATE("windows",7,"tableState","config","defaultSort","direction")="ascending"
	. DO WIN(.STATE,8,"win-ui-modules","ui-modules","UI Modules",156,86,1040,640,10,"closed",780,520,1,1,"module-catalog","▦","workspace-main",1)
	. SET STATE("windows",8,"moduleWindow")=1
	. SET STATE("windows",8,"moduleId")="mioos.ui.modules"
	. SET STATE("windows",8,"moduleComponent")="module-catalog"
	QUIT
	;
WIN(STATE,N,ID,APPKEY,TITLE,LEFT,TOP,WIDTH,HEIGHT,Z,MODE,MINW,MINH,RESIZE,DRAG,KIND,ICON,WORKSPACE,PERSIST)
	SET STATE("windows",N,"id")=ID
	SET STATE("windows",N,"appKey")=APPKEY
	SET STATE("windows",N,"title")=TITLE
	SET STATE("windows",N,"kind")=$SELECT($GET(KIND)'="":$GET(KIND),1:"app")
	SET STATE("windows",N,"icon")=$SELECT($GET(ICON)'="":$GET(ICON),1:"□")
	SET STATE("windows",N,"workspaceKey")=$SELECT($GET(WORKSPACE)'="":$GET(WORKSPACE),1:"workspace-"_APPKEY)
	SET STATE("windows",N,"persistLayout")=+$SELECT($DATA(PERSIST)#2:PERSIST,1:1)
	SET STATE("windows",N,"focusable")=1
	SET STATE("windows",N,"focused")=0
	SET STATE("windows",N,"chrome")=$GET(STATE("windowChrome"),"reusable-shell-chrome")
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
		SET @ROOT@(1,"key")="meadow-classic-light"
		SET @ROOT@(1,"title")="Meadow Classic"
		SET @ROOT@(1,"family")="Meadow Classic"
		SET @ROOT@(1,"familyKey")="meadow-classic"
		SET @ROOT@(1,"mode")="light"
		SET @ROOT@(1,"isCurrent")=$SELECT($GET(CURRENT)="luna-blue":1,$GET(CURRENT)="meadow-classic-light":1,1:0)
		SET @ROOT@(1,"wallpaper")="gradient-gloss"
		SET @ROOT@(1,"accent")="#3a78d8"
		SET @ROOT@(1,"taskbar")="#4b82d8"
		SET @ROOT@(2,"key")="meadow-classic-dark"
		SET @ROOT@(2,"title")="Meadow Classic Night"
		SET @ROOT@(2,"family")="Meadow Classic"
		SET @ROOT@(2,"familyKey")="meadow-classic"
		SET @ROOT@(2,"mode")="dark"
		SET @ROOT@(2,"isCurrent")=$SELECT($GET(CURRENT)="royale-noir":1,$GET(CURRENT)="meadow-classic-dark":1,1:0)
		SET @ROOT@(2,"wallpaper")="gradient-gloss"
		SET @ROOT@(2,"accent")="#8eb6ff"
		SET @ROOT@(2,"taskbar")="#223951"
		SET @ROOT@(3,"key")="glass-horizon-light"
		SET @ROOT@(3,"title")="Glass Horizon"
		SET @ROOT@(3,"family")="Glass Horizon"
		SET @ROOT@(3,"familyKey")="glass-horizon"
		SET @ROOT@(3,"mode")="light"
		SET @ROOT@(3,"isCurrent")=$SELECT($GET(CURRENT)="aero-glass":1,$GET(CURRENT)="glass-horizon-light":1,1:0)
		SET @ROOT@(3,"wallpaper")="gradient-gloss"
		SET @ROOT@(3,"accent")="#72a8ff"
		SET @ROOT@(3,"taskbar")="#6385bd"
		SET @ROOT@(4,"key")="glass-horizon-dark"
		SET @ROOT@(4,"title")="Glass Horizon Midnight"
		SET @ROOT@(4,"family")="Glass Horizon"
		SET @ROOT@(4,"familyKey")="glass-horizon"
		SET @ROOT@(4,"mode")="dark"
		SET @ROOT@(4,"isCurrent")=$SELECT($GET(CURRENT)="aero-midnight":1,$GET(CURRENT)="glass-horizon-dark":1,1:0)
		SET @ROOT@(4,"wallpaper")="gradient-gloss"
		SET @ROOT@(4,"accent")="#93b0ff"
		SET @ROOT@(4,"taskbar")="#1d2a3d"
		SET @ROOT@(5,"key")="graphite-dock-light"
		SET @ROOT@(5,"title")="Graphite Dock"
		SET @ROOT@(5,"family")="Graphite Dock"
		SET @ROOT@(5,"familyKey")="graphite-dock"
		SET @ROOT@(5,"mode")="light"
		SET @ROOT@(5,"isCurrent")=$SELECT($GET(CURRENT)="graphite-dock-light":1,1:0)
		SET @ROOT@(5,"wallpaper")="gradient-gloss"
		SET @ROOT@(5,"accent")="#7da8ff"
		SET @ROOT@(5,"taskbar")="#d9dce4"
		SET @ROOT@(6,"key")="graphite-dock-dark"
		SET @ROOT@(6,"title")="Graphite Dock Night"
		SET @ROOT@(6,"family")="Graphite Dock"
		SET @ROOT@(6,"familyKey")="graphite-dock"
		SET @ROOT@(6,"mode")="dark"
		SET @ROOT@(6,"isCurrent")=$SELECT($GET(CURRENT)="graphite-dock-dark":1,1:0)
		SET @ROOT@(6,"wallpaper")="gradient-gloss"
		SET @ROOT@(6,"accent")="#a9beff"
		SET @ROOT@(6,"taskbar")="#2e343f"
		SET @ROOT@(7,"key")="ember-panel-light"
		SET @ROOT@(7,"title")="Ember Panel"
		SET @ROOT@(7,"family")="Ember Panel"
		SET @ROOT@(7,"familyKey")="ember-panel"
		SET @ROOT@(7,"mode")="light"
		SET @ROOT@(7,"isCurrent")=$SELECT($GET(CURRENT)="ubuntu-human":1,$GET(CURRENT)="ember-panel-light":1,1:0)
		SET @ROOT@(7,"wallpaper")="gradient-gloss"
		SET @ROOT@(7,"accent")="#ffb26d"
		SET @ROOT@(7,"taskbar")="#f0a05d"
		SET @ROOT@(8,"key")="ember-panel-dark"
		SET @ROOT@(8,"title")="Ember Panel Night"
		SET @ROOT@(8,"family")="Ember Panel"
		SET @ROOT@(8,"familyKey")="ember-panel"
		SET @ROOT@(8,"mode")="dark"
		SET @ROOT@(8,"isCurrent")=$SELECT($GET(CURRENT)="ubuntu-graphite":1,$GET(CURRENT)="ember-panel-dark":1,1:0)
		SET @ROOT@(8,"wallpaper")="gradient-gloss"
		SET @ROOT@(8,"accent")="#ffb087"
		SET @ROOT@(8,"taskbar")="#3c241f"
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
