MIOOS ; MIOOS desktop subsystem
	QUIT
	;
CONFDEF(CONF)
	NEW ISDEV
	IF $GET(CONF("mioos","enabled"))="" SET CONF("mioos","enabled")=1
	IF $GET(CONF("mioos","profile"))="" SET CONF("mioos","profile")="dev"
	SET ISDEV=$SELECT($GET(CONF("mioos","profile"))="dev":1,1:0)
	IF $GET(CONF("mioos","route","desktop"))="" SET CONF("mioos","route","desktop")="/mioos"
	IF $GET(CONF("mioos","route","desktopAlias"))="" SET CONF("mioos","route","desktopAlias")="/"
	IF $GET(CONF("mioos","route","bootstrap"))="" SET CONF("mioos","route","bootstrap")="/api/mioos/bootstrap"
	IF $GET(CONF("mioos","route","view"))="" SET CONF("mioos","route","view")="/api/mioos/view"
	IF $GET(CONF("mioos","route","signin"))="" SET CONF("mioos","route","signin")="/api/mioos/auth/signin"
	IF $GET(CONF("mioos","route","publicSignin"))="" SET CONF("mioos","route","publicSignin")=$GET(CONF("mioos","route","signin"),"/api/mioos/auth/signin")
	IF $GET(CONF("mioos","route","signout"))="" SET CONF("mioos","route","signout")="/api/mioos/auth/signout"
	IF $GET(CONF("mioos","route","guestSignin"))="" SET CONF("mioos","route","guestSignin")="/api/mioos/auth/guest"
	IF $GET(CONF("mioos","route","passwordChange"))="" SET CONF("mioos","route","passwordChange")="/api/mioos/auth/password/change"
	IF $GET(CONF("mioos","route","auditExport"))="" SET CONF("mioos","route","auditExport")="/api/mioos/auth/audit/export"
	IF $GET(CONF("mioos","route","fsList"))="" SET CONF("mioos","route","fsList")="/api/mioos/fs/list"
	IF $GET(CONF("mioos","route","fsRead"))="" SET CONF("mioos","route","fsRead")="/api/mioos/fs/read"
	IF $GET(CONF("mioos","route","fsWrite"))="" SET CONF("mioos","route","fsWrite")="/api/mioos/fs/write"
	IF $GET(CONF("mioos","route","fsMkdir"))="" SET CONF("mioos","route","fsMkdir")="/api/mioos/fs/mkdir"
	IF $GET(CONF("mioos","route","fsMeta"))="" SET CONF("mioos","route","fsMeta")="/api/mioos/fs/meta"
	IF $GET(CONF("mioos","route","fsSetMeta"))="" SET CONF("mioos","route","fsSetMeta")="/api/mioos/fs/setmeta"
	IF $GET(CONF("mioos","route","fsRename"))="" SET CONF("mioos","route","fsRename")="/api/mioos/fs/rename"
	IF $GET(CONF("mioos","route","fsMove"))="" SET CONF("mioos","route","fsMove")="/api/mioos/fs/move"
	IF $GET(CONF("mioos","route","fsDelete"))="" SET CONF("mioos","route","fsDelete")="/api/mioos/fs/delete"
	IF $GET(CONF("mioos","route","fsUploadBegin"))="" SET CONF("mioos","route","fsUploadBegin")="/api/mioos/fs/upload/begin"
	IF $GET(CONF("mioos","route","fsUploadChunk"))="" SET CONF("mioos","route","fsUploadChunk")="/api/mioos/fs/upload/chunk"
	IF $GET(CONF("mioos","route","fsUploadStatus"))="" SET CONF("mioos","route","fsUploadStatus")="/api/mioos/fs/upload/status"
	IF $GET(CONF("mioos","route","fsUploadCommit"))="" SET CONF("mioos","route","fsUploadCommit")="/api/mioos/fs/upload/commit"
	IF $GET(CONF("mioos","route","fsUploadAbort"))="" SET CONF("mioos","route","fsUploadAbort")="/api/mioos/fs/upload/abort"
	IF $GET(CONF("mioos","route","fsBlob"))="" SET CONF("mioos","route","fsBlob")="/api/mioos/fs/blob"
	IF $GET(CONF("mioos","route","themeAssetUpload"))="" SET CONF("mioos","route","themeAssetUpload")="/api/mioos/theme-asset/upload"
	IF $GET(CONF("mioos","route","themeAsset"))="" SET CONF("mioos","route","themeAsset")="/api/mioos/theme-asset"
	IF $GET(CONF("mioos","route","themePublicAsset"))="" SET CONF("mioos","route","themePublicAsset")="/api/mioos/theme-public-asset"
	IF $GET(CONF("mioos","route","themeLoad"))="" SET CONF("mioos","route","themeLoad")="/api/mioos/theme/load"
	IF $GET(CONF("mioos","route","themeSave"))="" SET CONF("mioos","route","themeSave")="/api/mioos/theme/save"
	IF $GET(CONF("mioos","route","moduleCatalog"))="" SET CONF("mioos","route","moduleCatalog")="/api/mioos/modules/catalog"
	IF $GET(CONF("mioos","route","moduleTable"))="" SET CONF("mioos","route","moduleTable")="/api/mioos/modules/table"
	IF $GET(CONF("mioos","route","settingsLoad"))="" SET CONF("mioos","route","settingsLoad")="/api/mioos/settings/load"
	IF $GET(CONF("mioos","route","settingsSave"))="" SET CONF("mioos","route","settingsSave")="/api/mioos/settings/save"
	IF $GET(CONF("mioos","route","ws"))="" SET CONF("mioos","route","ws")="/ws/mioos"
	IF $GET(CONF("mioos","route","wsTerminal"))="" SET CONF("mioos","route","wsTerminal")="/ws/mioos/terminal"
	IF $GET(CONF("mioos","brand","title"))="" SET CONF("mioos","brand","title")="MIOOS"
	IF $GET(CONF("mioos","brand","subtitle"))="" SET CONF("mioos","brand","subtitle")="MUMPS-powered web desktop shell"
	IF $GET(CONF("mioos","i18n","default"))="" SET CONF("mioos","i18n","default")="en"
	IF $GET(CONF("mioos","desktop","theme"))="" SET CONF("mioos","desktop","theme")="luna-blue"
	IF $GET(CONF("mioos","desktop","wallpaper"))="" SET CONF("mioos","desktop","wallpaper")="aurora"
	IF $GET(CONF("mioos","desktop","density"))="" SET CONF("mioos","desktop","density")="comfortable"
	IF $GET(CONF("mioos","desktop","fontFamily"))="" SET CONF("mioos","desktop","fontFamily")="Segoe UI"
	IF $GET(CONF("mioos","desktop","fontSize"))="" SET CONF("mioos","desktop","fontSize")=13
	IF $GET(CONF("mioos","desktop","launcherLabel"))="" SET CONF("mioos","desktop","launcherLabel")="Menu"
	IF $GET(CONF("mioos","desktop","transport","eventName"))="" SET CONF("mioos","desktop","transport","eventName")="desktop.command"
	IF $GET(CONF("mioos","desktop","transport","resultEvent"))="" SET CONF("mioos","desktop","transport","resultEvent")="desktop.result"
	IF $GET(CONF("mioos","desktop","transport","errorEvent"))="" SET CONF("mioos","desktop","transport","errorEvent")="desktop.error"
	IF $GET(CONF("mioos","desktop","transport","model"))="" SET CONF("mioos","desktop","transport","model")="core-websocket-plus-app-websockets"
	IF $GET(CONF("mioos","desktop","themeMode"))="" SET CONF("mioos","desktop","themeMode")="light"
	IF $GET(CONF("mioos","desktop","themeSystem","editor"))="" SET CONF("mioos","desktop","themeSystem","editor")="customize"
	IF $GET(CONF("mioos","desktop","themeSystem","persistence"))="" SET CONF("mioos","desktop","themeSystem","persistence")="globals-profile-service"
	IF $GET(CONF("mioos","desktop","themeSystem","liveApply"))="" SET CONF("mioos","desktop","themeSystem","liveApply")=1
	IF $GET(CONF("mioos","desktop","themeSystem","quickSwitch"))="" SET CONF("mioos","desktop","themeSystem","quickSwitch")=1
	IF $GET(CONF("mioos","desktop","themeSystem","version"))="" SET CONF("mioos","desktop","themeSystem","version")=4
	IF $GET(CONF("mioos","desktop","windowPersistence"))="" SET CONF("mioos","desktop","windowPersistence")="localstorage-open-window-layout"
	IF $GET(CONF("mioos","desktop","desktopLayoutPersistence"))="" SET CONF("mioos","desktop","desktopLayoutPersistence")="localstorage-icon-layout"
	IF $GET(CONF("mioos","desktop","accessibility","persistence"))="" SET CONF("mioos","desktop","accessibility","persistence")="localstorage-shell-accessibility"
	IF $GET(CONF("mioos","desktop","accessibility","reducedMotionToggle"))="" SET CONF("mioos","desktop","accessibility","reducedMotionToggle")=1
	IF $GET(CONF("mioos","desktop","accessibility","keyboardShortcuts","showDesktop"))="" SET CONF("mioos","desktop","accessibility","keyboardShortcuts","showDesktop")="Meta+D"
	IF $GET(CONF("mioos","desktop","accessibility","keyboardShortcuts","windowSwitcher"))="" SET CONF("mioos","desktop","accessibility","keyboardShortcuts","windowSwitcher")="Alt+Tab"
	IF $GET(CONF("mioos","desktop","accessibility","keyboardShortcuts","closeFocusedWindow"))="" SET CONF("mioos","desktop","accessibility","keyboardShortcuts","closeFocusedWindow")="Shift+Escape"
	IF $GET(CONF("mioos","desktop","accessibility","keyboardShortcuts","openDiagnostics"))="" SET CONF("mioos","desktop","accessibility","keyboardShortcuts","openDiagnostics")="Ctrl+Shift+Escape"
	IF $GET(CONF("mioos","desktop","accessibility","keyboardShortcuts","snapLeft"))="" SET CONF("mioos","desktop","accessibility","keyboardShortcuts","snapLeft")="Alt+Shift+ArrowLeft"
	IF $GET(CONF("mioos","desktop","accessibility","keyboardShortcuts","snapRight"))="" SET CONF("mioos","desktop","accessibility","keyboardShortcuts","snapRight")="Alt+Shift+ArrowRight"
	IF $GET(CONF("mioos","desktop","accessibility","keyboardShortcuts","maximizeFocusedWindow"))="" SET CONF("mioos","desktop","accessibility","keyboardShortcuts","maximizeFocusedWindow")="Alt+Shift+ArrowUp"
	IF $GET(CONF("mioos","desktop","accessibility","keyboardShortcuts","restoreFocusedWindow"))="" SET CONF("mioos","desktop","accessibility","keyboardShortcuts","restoreFocusedWindow")="Alt+Shift+ArrowDown"
	IF $GET(CONF("mioos","desktop","appSurfaceModel"))="" SET CONF("mioos","desktop","appSurfaceModel")="shell-standard-actions"
	IF $GET(CONF("mioos","desktop","appActions","confirmBeforeDestructive"))="" SET CONF("mioos","desktop","appActions","confirmBeforeDestructive")=1
	IF $GET(CONF("mioos","desktop","appActions","notifyOnAdminActions"))="" SET CONF("mioos","desktop","appActions","notifyOnAdminActions")=1
	IF $GET(CONF("mioos","desktop","appActions","copyExportsToClipboard"))="" SET CONF("mioos","desktop","appActions","copyExportsToClipboard")=1
	IF $GET(CONF("mioos","desktop","appActions","moduleNotesSessionLocal"))="" SET CONF("mioos","desktop","appActions","moduleNotesSessionLocal")=1
	IF $GET(CONF("mioos","desktop","shellSurfaces","moduleWindows"))="" SET CONF("mioos","desktop","shellSurfaces","moduleWindows")=0
	IF $GET(CONF("mioos","desktop","chrome"))="" SET CONF("mioos","desktop","chrome")="shell-foundation"
	IF $GET(CONF("mioos","desktop","taskbarStyle"))="" SET CONF("mioos","desktop","taskbarStyle")="taskbar-foundation"
	IF $GET(CONF("mioos","desktop","startMenuStyle"))="" SET CONF("mioos","desktop","startMenuStyle")="launcher-foundation"
	IF $GET(CONF("mioos","desktop","windowManager"))="" SET CONF("mioos","desktop","windowManager")="mioos-native-vue-css"
	IF $GET(CONF("mioos","desktop","windowChrome"))="" SET CONF("mioos","desktop","windowChrome")="reusable-shell-chrome"
	IF $GET(CONF("mioos","desktop","windowTitlebarHeight"))="" SET CONF("mioos","desktop","windowTitlebarHeight")=40
	IF $GET(CONF("mioos","desktop","windowMenuEnabled"))="" SET CONF("mioos","desktop","windowMenuEnabled")=1
	IF $GET(CONF("mioos","desktop","windowStatusBadges"))="" SET CONF("mioos","desktop","windowStatusBadges")=1
	IF $GET(CONF("mioos","desktop","workspaces","enabled"))="" SET CONF("mioos","desktop","workspaces","enabled")=0
	IF $GET(CONF("mioos","desktop","workspaces","persistence"))="" SET CONF("mioos","desktop","workspaces","persistence")="none"
	IF $GET(CONF("mioos","desktop","workspaces","defaultKey"))="" SET CONF("mioos","desktop","workspaces","defaultKey")="workspace-main"
	IF $GET(CONF("mioos","desktop","workspaces","showInTaskbar"))="" SET CONF("mioos","desktop","workspaces","showInTaskbar")=0
	IF $GET(CONF("mioos","desktop","workspaces","followMovedWindow"))="" SET CONF("mioos","desktop","workspaces","followMovedWindow")=1
	IF $GET(CONF("mioos","desktop","accessibility","keyboardShortcuts","previousWorkspace"))="" SET CONF("mioos","desktop","accessibility","keyboardShortcuts","previousWorkspace")="Ctrl+Alt+ArrowLeft"
	IF $GET(CONF("mioos","desktop","accessibility","keyboardShortcuts","nextWorkspace"))="" SET CONF("mioos","desktop","accessibility","keyboardShortcuts","nextWorkspace")="Ctrl+Alt+ArrowRight"
	IF $GET(CONF("mioos","desktop","accessibility","keyboardShortcuts","moveFocusedWindowPreviousWorkspace"))="" SET CONF("mioos","desktop","accessibility","keyboardShortcuts","moveFocusedWindowPreviousWorkspace")="Ctrl+Alt+Shift+ArrowLeft"
	IF $GET(CONF("mioos","desktop","accessibility","keyboardShortcuts","moveFocusedWindowNextWorkspace"))="" SET CONF("mioos","desktop","accessibility","keyboardShortcuts","moveFocusedWindowNextWorkspace")="Ctrl+Alt+Shift+ArrowRight"
	IF $GET(CONF("mioos","desktop","authRequired"))="" SET CONF("mioos","desktop","authRequired")=1
	IF $GET(CONF("mioos","dev","enabled"))="" SET CONF("mioos","dev","enabled")=ISDEV
	IF $GET(CONF("mioos","dev","authDisabled"))="" SET CONF("mioos","dev","authDisabled")=0
	IF $GET(CONF("mioos","dev","principal"))="" SET CONF("mioos","dev","principal")="dev-user"
	IF $GET(CONF("mioos","dev","userName"))="" SET CONF("mioos","dev","userName")="Developer"
	IF $GET(CONF("mioos","dev","roles"))="" SET CONF("mioos","dev","roles")="developer,admin"
	IF $GET(CONF("mioos","localAuth","enabled"))="" SET CONF("mioos","localAuth","enabled")=1
	IF $GET(CONF("mioos","localAuth","guestLoginEnabled"))="" SET CONF("mioos","localAuth","guestLoginEnabled")=0
	IF $GET(CONF("mioos","localAuth","tokenCookie"))="" SET CONF("mioos","localAuth","tokenCookie")="mioos_auth"
	IF $GET(CONF("mioos","localAuth","tokenMaxAgeSeconds"))="" SET CONF("mioos","localAuth","tokenMaxAgeSeconds")=604800
	IF $GET(CONF("mioos","localAuth","lockThreshold"))="" SET CONF("mioos","localAuth","lockThreshold")=5
	IF $GET(CONF("mioos","localAuth","lockMinutes"))="" SET CONF("mioos","localAuth","lockMinutes")=15
	IF $GET(CONF("mioos","localAuth","passwordPolicy","minLength"))="" SET CONF("mioos","localAuth","passwordPolicy","minLength")=12
	IF $GET(CONF("mioos","localAuth","passwordPolicy","requireUpper"))="" SET CONF("mioos","localAuth","passwordPolicy","requireUpper")=1
	IF $GET(CONF("mioos","localAuth","passwordPolicy","requireLower"))="" SET CONF("mioos","localAuth","passwordPolicy","requireLower")=1
	IF $GET(CONF("mioos","localAuth","passwordPolicy","requireDigit"))="" SET CONF("mioos","localAuth","passwordPolicy","requireDigit")=1
	IF $GET(CONF("mioos","localAuth","passwordPolicy","requireSymbol"))="" SET CONF("mioos","localAuth","passwordPolicy","requireSymbol")=1
	IF $GET(CONF("mioos","localAuth","passwordPolicy","maxAgeDays"))="" SET CONF("mioos","localAuth","passwordPolicy","maxAgeDays")=90
	IF $GET(CONF("mioos","localAuth","passwordPolicy","warnDays"))="" SET CONF("mioos","localAuth","passwordPolicy","warnDays")=14
	IF $GET(CONF("mioos","localAuth","passwordPolicy","changeTokenMinutes"))="" SET CONF("mioos","localAuth","passwordPolicy","changeTokenMinutes")=15
	IF $GET(CONF("mioos","auth","frameworkProvider"))="" SET CONF("mioos","auth","frameworkProvider")="mioauth-session-jwt"
	IF $GET(CONF("mioos","auth","management","sessionAdminEnabled"))="" SET CONF("mioos","auth","management","sessionAdminEnabled")=1
	IF $GET(CONF("mioos","auth","management","accountAdminEnabled"))="" SET CONF("mioos","auth","management","accountAdminEnabled")=1
	IF $GET(CONF("mioos","auth","management","sessionLimit"))="" SET CONF("mioos","auth","management","sessionLimit")=20
	IF $GET(CONF("mioos","auth","management","accountLimit"))="" SET CONF("mioos","auth","management","accountLimit")=20
	IF $GET(CONF("mioos","debug","enabled"))="" SET CONF("mioos","debug","enabled")=0
	IF $GET(CONF("mioos","debug","eventLimit"))="" SET CONF("mioos","debug","eventLimit")=50
	IF $GET(CONF("mioos","debug","snapshotVersion"))="" SET CONF("mioos","debug","snapshotVersion")=1
	IF $GET(CONF("mioos","audit","enabled"))="" SET CONF("mioos","audit","enabled")=1
	IF $GET(CONF("mioos","audit","retainDays"))="" SET CONF("mioos","audit","retainDays")=365
	IF $GET(CONF("mioos","audit","reportLimit"))="" SET CONF("mioos","audit","reportLimit")=20
	IF $GET(CONF("mioos","audit","reportWindowDays"))="" SET CONF("mioos","audit","reportWindowDays")=30
	IF $GET(CONF("mioos","bootstrapAuth","enabled"))="" SET CONF("mioos","bootstrapAuth","enabled")=1
	IF $GET(CONF("mioos","bootstrapAuth","seedIfMissing"))="" SET CONF("mioos","bootstrapAuth","seedIfMissing")=1
	IF $GET(CONF("mioos","bootstrapAuth","syncOnBoot"))="" SET CONF("mioos","bootstrapAuth","syncOnBoot")=1
	IF $GET(CONF("mioos","bootstrapAuth","preservePasswordChanges"))="" SET CONF("mioos","bootstrapAuth","preservePasswordChanges")=1
	IF $GET(CONF("mioos","bootstrapAuth","admin","username"))="" SET CONF("mioos","bootstrapAuth","admin","username")="admin"
	IF $GET(CONF("mioos","bootstrapAuth","admin","displayName"))="" SET CONF("mioos","bootstrapAuth","admin","displayName")="Administrator"
	IF $GET(CONF("mioos","bootstrapAuth","admin","password"))="" SET CONF("mioos","bootstrapAuth","admin","password")="W@lid2012"
	IF $GET(CONF("mioos","bootstrapAuth","admin","roles"))="" SET CONF("mioos","bootstrapAuth","admin","roles")="admin"
	IF $GET(CONF("mioos","bootstrapAuth","admin","enabled"))="" SET CONF("mioos","bootstrapAuth","admin","enabled")=1
	IF $GET(CONF("mioos","bootstrapAuth","admin","forcePasswordChange"))="" SET CONF("mioos","bootstrapAuth","admin","forcePasswordChange")=$SELECT(ISDEV:0,1:1)
	IF $GET(CONF("mioos","bootstrapAuth","user","username"))="" SET CONF("mioos","bootstrapAuth","user","username")="user"
	IF $GET(CONF("mioos","bootstrapAuth","user","displayName"))="" SET CONF("mioos","bootstrapAuth","user","displayName")="User"
	IF $GET(CONF("mioos","bootstrapAuth","user","password"))="" SET CONF("mioos","bootstrapAuth","user","password")="W@lid2012"
	IF $GET(CONF("mioos","bootstrapAuth","user","roles"))="" SET CONF("mioos","bootstrapAuth","user","roles")="operator"
	IF $GET(CONF("mioos","bootstrapAuth","user","enabled"))="" SET CONF("mioos","bootstrapAuth","user","enabled")=1
	IF $GET(CONF("mioos","bootstrapAuth","user","forcePasswordChange"))="" SET CONF("mioos","bootstrapAuth","user","forcePasswordChange")=$SELECT(ISDEV:0,1:1)
	IF $GET(CONF("mioos","bootstrapAuth","guest","username"))="" SET CONF("mioos","bootstrapAuth","guest","username")="guest"
	IF $GET(CONF("mioos","bootstrapAuth","guest","displayName"))="" SET CONF("mioos","bootstrapAuth","guest","displayName")="Guest"
	IF $GET(CONF("mioos","bootstrapAuth","guest","password"))="" SET CONF("mioos","bootstrapAuth","guest","password")="W@lid2012"
	IF $GET(CONF("mioos","bootstrapAuth","guest","roles"))="" SET CONF("mioos","bootstrapAuth","guest","roles")="guest"
	IF $GET(CONF("mioos","bootstrapAuth","guest","enabled"))="" SET CONF("mioos","bootstrapAuth","guest","enabled")=0
	IF $GET(CONF("mioos","bootstrapAuth","guest","forcePasswordChange"))="" SET CONF("mioos","bootstrapAuth","guest","forcePasswordChange")=0
	IF $GET(CONF("mioos","terminal","enabled"))="" SET CONF("mioos","terminal","enabled")=1
	IF $GET(CONF("mioos","terminal","commandTransport"))="" SET CONF("mioos","terminal","commandTransport")="dedicated-websocket"
	IF $GET(CONF("mioos","terminal","websocket","pollMs"))="" SET CONF("mioos","terminal","websocket","pollMs")=250
	IF $GET(CONF("mioos","terminal","default","engine"))="" SET CONF("mioos","terminal","default","engine")="xtermjs"
	IF $GET(CONF("mioos","terminal","default","fontFamily"))="" SET CONF("mioos","terminal","default","fontFamily")="Consolas"
	IF $GET(CONF("mioos","terminal","default","fontSize"))="" SET CONF("mioos","terminal","default","fontSize")=14
	IF $GET(CONF("mioos","terminal","default","cursorBlink"))="" SET CONF("mioos","terminal","default","cursorBlink")=1
	IF $GET(CONF("mioos","terminal","default","cursorStyle"))="" SET CONF("mioos","terminal","default","cursorStyle")="block"
	IF $GET(CONF("mioos","terminal","default","scrollback"))="" SET CONF("mioos","terminal","default","scrollback")=2500
	IF $GET(CONF("mioos","terminal","default","renderer"))="" SET CONF("mioos","terminal","default","renderer")="canvas"
	IF $GET(CONF("mioos","terminal","default","unicode"))="" SET CONF("mioos","terminal","default","unicode")="unicode11"
	IF $GET(CONF("mioos","terminal","default","rows"))="" SET CONF("mioos","terminal","default","rows")=28
	IF $GET(CONF("mioos","terminal","default","cols"))="" SET CONF("mioos","terminal","default","cols")=112
	IF $GET(CONF("mioos","terminal","maxSessionsPerUser"))="" SET CONF("mioos","terminal","maxSessionsPerUser")=8
	IF $GET(CONF("mioos","terminal","historyLimit"))="" SET CONF("mioos","terminal","historyLimit")=400
	IF $GET(CONF("mioos","terminal","pipe","command"))="" SET CONF("mioos","terminal","pipe","command")=""
	IF $GET(CONF("mioos","terminal","pipe","shell"))="" SET CONF("mioos","terminal","pipe","shell")=""
	IF $GET(CONF("mioos","terminal","pipe","readLimit"))="" SET CONF("mioos","terminal","pipe","readLimit")=16384
	IF $GET(CONF("mioos","terminal","pipe","readPolls"))="" SET CONF("mioos","terminal","pipe","readPolls")=8
	IF $GET(CONF("mioos","terminal","pipe","drainPause"))="" SET CONF("mioos","terminal","pipe","drainPause")=.04
	IF $GET(CONF("mioos","terminal","pipe","reconnectGraceSeconds"))="" SET CONF("mioos","terminal","pipe","reconnectGraceSeconds")=180
	IF $GET(CONF("mioos","fs","enabled"))="" SET CONF("mioos","fs","enabled")=1
	IF $GET(CONF("mioos","fs","chunkSize"))="" SET CONF("mioos","fs","chunkSize")=131072
	IF $GET(CONF("mioos","download","httpChunkBytes"))="" SET CONF("mioos","download","httpChunkBytes")=131072
	IF $GET(CONF("mioos","fs","readPreviewBytes"))="" SET CONF("mioos","fs","readPreviewBytes")=262144
	IF $GET(CONF("mioos","fs","readWindowBytes"))="" SET CONF("mioos","fs","readWindowBytes")=262144
	IF $GET(CONF("mioos","fs","transferPersistence"))="" SET CONF("mioos","fs","transferPersistence")="localstorage-resumable-transfer-list"
	IF $GET(CONF("mioos","download","mediaInitialBytes"))="" SET CONF("mioos","download","mediaInitialBytes")=131072
	IF $GET(CONF("mioos","download","mediaWarmupBytes"))="" SET CONF("mioos","download","mediaWarmupBytes")=131072
	IF $GET(CONF("mioos","fs","transport"))="" SET CONF("mioos","fs","transport")="http-and-websocket"
	IF $GET(CONF("mioos","route","tableQuery"))="" SET CONF("mioos","route","tableQuery")="/api/mioos/table/query"
	IF $GET(CONF("mioos","route","tableMutate"))="" SET CONF("mioos","route","tableMutate")="/api/mioos/table/mutate"
	IF $GET(CONF("mioos","route","moduleCatalog"))="" SET CONF("mioos","route","moduleCatalog")="/api/mioos/modules/catalog"
	IF $GET(CONF("mioos","route","moduleTable"))="" SET CONF("mioos","route","moduleTable")="/api/mioos/modules/table"
	IF $GET(CONF("mioos","route","settingsLoad"))="" SET CONF("mioos","route","settingsLoad")="/api/mioos/settings/load"
	IF $GET(CONF("mioos","route","settingsSave"))="" SET CONF("mioos","route","settingsSave")="/api/mioos/settings/save"
	IF $GET(CONF("mioos","modules","enabled"))="" SET CONF("mioos","modules","enabled")=1
	IF $GET(CONF("mioos","modules","appCatalogEnabled"))="" SET CONF("mioos","modules","appCatalogEnabled")=1
	IF $GET(CONF("mioos","modules","dynamicWindows"))="" SET CONF("mioos","modules","dynamicWindows")=1
	IF $GET(CONF("mioos","modules","launcher"))="" SET CONF("mioos","modules","launcher")="desktop-icons-and-menu"
	IF $GET(CONF("mioos","table","maxPageSize"))="" SET CONF("mioos","table","maxPageSize")=250
	IF $GET(CONF("mioos","upload","chunkBytes"))="" SET CONF("mioos","upload","chunkBytes")=860000
	IF $GET(CONF("mioos","upload","concurrency"))="" SET CONF("mioos","upload","concurrency")=3
	IF $GET(CONF("mioos","upload","batchSize"))="" SET CONF("mioos","upload","batchSize")=2
	IF $GET(CONF("mioos","upload","maxInflightChunks"))="" SET CONF("mioos","upload","maxInflightChunks")=6
	IF $GET(CONF("mioos","upload","batchFlushThreshold"))="" SET CONF("mioos","upload","batchFlushThreshold")=2
	IF $GET(CONF("mioos","terminal","pipe","sessionIdleSeconds"))="" SET CONF("mioos","terminal","pipe","sessionIdleSeconds")=900
	IF $GET(CONF("mioos","websocket","maxSocketsPerSession"))="" SET CONF("mioos","websocket","maxSocketsPerSession")=9
	IF $GET(CONF("mioos","websocket","coreSockets"))="" SET CONF("mioos","websocket","coreSockets")=1
	IF $GET(CONF("mioos","websocket","fsSockets"))="" SET CONF("mioos","websocket","fsSockets")=1
	IF $GET(CONF("auth","protectMode"))="" SET CONF("auth","protectMode")="route"
	IF $GET(CONF("auth","mode"))="" SET CONF("auth","mode")="jwt"
	IF +$GET(CONF("mioos","desktop","authRequired"),1)=1 DO
	. NEW FWMODE SET FWMODE=$GET(CONF("auth","providers","framework","mode"))
	. IF FWMODE="mioauth-session-jwt",($GET(CONF("auth","mode"))="either"!($GET(CONF("auth","mode"))="api_key")) SET CONF("auth","mode")="jwt"
	IF $GET(CONF("auth","jwt","cookieName"))="" SET CONF("auth","jwt","cookieName")=$GET(CONF("mioos","localAuth","tokenCookie"),"mioos_auth")
	IF $GET(CONF("auth","jwt","rolesClaim"))="" SET CONF("auth","jwt","rolesClaim")="roles"
	IF $GET(CONF("auth","jwt","issuer"))="" SET CONF("auth","jwt","issuer")="mioos-local-auth"
	IF $GET(CONF("auth","jwt","audience"))="" SET CONF("auth","jwt","audience")="mioos"
	IF $GET(CONF("auth","jwt","hmacSecret"))="" SET CONF("auth","jwt","hmacSecret")="mioos-local-auth-change-me"
	IF $GET(CONF("auth","session","mioos","cookieName"))="" SET CONF("auth","session","mioos","cookieName")=$GET(CONF("mioos","localAuth","tokenCookie"),"mioos_auth")
	IF $GET(CONF("auth","session","mioos","maxAgeSeconds"))="" SET CONF("auth","session","mioos","maxAgeSeconds")=+$GET(CONF("mioos","localAuth","tokenMaxAgeSeconds"),604800)
	IF $GET(CONF("server","templateDir"))="" SET CONF("server","templateDir")="templates"
	IF $GET(CONF("templates","root"))="" SET CONF("templates","root")=$GET(CONF("server","templateDir"))_"/"
	IF $GET(CONF("templates","ext"))="" SET CONF("templates","ext")=""
	DO APPLY^MIOOSCFG(.CONF)
	QUIT
	;
INIT(CONF)
	SET CONF("auth","mode")="jwt"
	DO CONFDEF(.CONF)
	DO BOOTSTRAP^MIOOSAUTH(.CONF)
	DO INIT^MIOOSFS(.CONF)
	QUIT
	;
REG(CONF)
	NEW META,PROT,WSMETA,AUTHREQ,SIGNIN,PSIGNIN
	DO INIT(.CONF)
	IF +$GET(CONF("mioos","enabled"),1)'=1 QUIT
	SET AUTHREQ=+$GET(CONF("mioos","desktop","authRequired"),1)
	SET SIGNIN=$GET(CONF("mioos","route","signin"),"/api/mioos/auth/signin")
	SET PSIGNIN=$GET(CONF("mioos","route","publicSignin"),SIGNIN)
	KILL META SET META("authRequired")=0
	DO ADDM^MIOROUTE("GET",$GET(CONF("mioos","route","desktop")),"DESKTOP^MIOOS",.META)
	DO ADDM^MIOROUTE("GET",$GET(CONF("mioos","route","desktopAlias")),"DESKTOP^MIOOS",.META)
	DO ADDM^MIOROUTE("POST",SIGNIN,"SIGNIN^MIOOSAPI",.META)
	IF PSIGNIN'=SIGNIN DO ADDM^MIOROUTE("POST",PSIGNIN,"SIGNIN^MIOOSAPI",.META)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","signout")),"SIGNOUT^MIOOSAPI",.META)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","guestSignin")),"GUESTSIGNIN^MIOOSAPI",.META)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","passwordChange")),"CHANGEPASSWORD^MIOOSAPI",.META)
	KILL PROT SET PROT("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("mioos","route","bootstrap")),"BOOTSTRAP^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("GET",$GET(CONF("mioos","route","view")),"VIEW^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("GET",$GET(CONF("mioos","route","auditExport")),"AUTHEXPORT^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsList")),"FSLIST^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsRead")),"FSREAD^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsWrite")),"FSWRITE^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsMkdir")),"FSMKDIR^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsMeta")),"FSMETA^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsSetMeta")),"FSSETMETA^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsRename")),"FSRENAME^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsMove")),"FSMOVE^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsDelete")),"FSDELETE^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","tableQuery")),"TABLEQUERY^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","tableMutate")),"TABLEMUTATE^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","moduleCatalog")),"MODULECATALOG^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","moduleTable")),"MODULETABLE^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","settingsLoad")),"SETTINGSLOAD^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","settingsSave")),"SETTINGSSAVE^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsUploadBegin")),"FSUPBEGIN^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsUploadChunk")),"FSUPCHUNK^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsUploadStatus")),"FSUPSTATUS^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsUploadCommit")),"FSUPCOMMIT^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsUploadAbort")),"FSUPABORT^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("GET",$GET(CONF("mioos","route","fsBlob")),"FSBLOB^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("HEAD",$GET(CONF("mioos","route","fsBlob")),"FSBLOB^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","themeAssetUpload")),"THEMEASSETUP^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("GET",$GET(CONF("mioos","route","themeAsset")),"THEMEASSET^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("HEAD",$GET(CONF("mioos","route","themeAsset")),"THEMEASSET^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("GET",$GET(CONF("mioos","route","themePublicAsset")),"THEMEPUBLICASSET^MIOOSAPI",.META)
	DO ADDM^MIOROUTE("HEAD",$GET(CONF("mioos","route","themePublicAsset")),"THEMEPUBLICASSET^MIOOSAPI",.META)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","themeLoad")),"THEMELOAD^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","themeSave")),"THEMESAVE^MIOOSAPI",.PROT)
	DO ADDM^MIOROUTE("GET","/public/mioos/*","STATIC^MIOOS",.META)
	KILL WSMETA SET WSMETA("authRequired")=AUTHREQ,WSMETA("wsPersistent")=1
	DO ADDWSM^MIOROUTE($GET(CONF("mioos","route","ws")),"MESSAGE^MIOOSWS",.WSMETA)
	DO ADDWSM^MIOROUTE($GET(CONF("mioos","route","wsTerminal")),"MESSAGE^MIOOSTWS",.WSMETA)
	DO ADDEXEMPT(.CONF,$GET(CONF("mioos","route","desktop")))
	DO ADDEXEMPT(.CONF,$GET(CONF("mioos","route","desktopAlias")))
	DO ADDEXEMPT(.CONF,"/public/mioos/")
	DO ADDEXEMPT(.CONF,SIGNIN)
	DO ADDEXEMPT(.CONF,PSIGNIN)
	DO ADDEXEMPT(.CONF,$GET(CONF("mioos","route","passwordChange")))
	DO ADDEXEMPT(.CONF,$GET(CONF("mioos","route","themePublicAsset")))
	IF 'AUTHREQ DO ADDEXEMPT(.CONF,$GET(CONF("mioos","route","bootstrap")))
	IF AUTHREQ DO
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","bootstrap")))
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","view")))
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","auditExport")))
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","fsList")))
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","fsRead")))
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","fsWrite")))
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","fsMkdir")))
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","fsMeta")))
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","fsSetMeta")))
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","fsRename")))
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","fsMove")))
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","fsDelete")))
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","moduleCatalog")))
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","moduleTable")))
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","settingsLoad")))
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","settingsSave")))
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","themeAssetUpload")))
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","themeAsset")))
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","themeLoad")))
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","themeSave")))
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","ws")))
	. DO ADDPROTECT(.CONF,$GET(CONF("mioos","route","wsTerminal")))
	QUIT
	;
ADDEXEMPT(CONF,PATH)
	NEW I,N,FOUND
	IF $GET(PATH)="" QUIT
	SET FOUND=0,I=""
	FOR  SET I=$ORDER(CONF("auth","exempt","prefix",I)) QUIT:I=""  DO  QUIT:FOUND
	. IF $GET(CONF("auth","exempt","prefix",I))=PATH SET FOUND=1
	IF FOUND QUIT
	SET N=0,I=""
	FOR  SET I=$ORDER(CONF("auth","exempt","prefix",I)) QUIT:I=""  SET N=+I
	SET CONF("auth","exempt","prefix",N+1)=PATH
	QUIT
	;
ADDPROTECT(CONF,PATH)
	NEW I,N,FOUND
	IF $GET(PATH)="" QUIT
	SET FOUND=0,I=""
	FOR  SET I=$ORDER(CONF("auth","protect","prefix",I)) QUIT:I=""  DO  QUIT:FOUND
	. IF $GET(CONF("auth","protect","prefix",I))=PATH SET FOUND=1
	IF FOUND QUIT
	SET N=0,I=""
	FOR  SET I=$ORDER(CONF("auth","protect","prefix",I)) QUIT:I=""  SET N=+I
	SET CONF("auth","protect","prefix",N+1)=PATH
	QUIT
	;
STATIC(DEV,CONF,REQ,CTX)
	SET CONF("server","static","mount")="/public"
	SET CONF("server","static","root")="./public"
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	QUIT
	;
DESKTOP(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,TCTX,OUT,HEAD
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"desktop_state_error",$GET(ERR("error"),"desktop_state_error"),.CTX)
	DO DESKCTX^MIOOSUI(.STATE,.CONF,.TCTX)
	DO RENDERPAGE^MIOTPL("pages/mioos_desktop.html","layouts/mioos_shell.html",.CONF,.TCTX,.OUT,.ERR)
	IF $DATA(ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"template_error",$GET(ERR("error"),"template_error"),.CTX)
	SET HEAD("Content-Type")="text/html; charset=utf-8"
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
RESPERR(DEV,CONF,STATUS,CODE,DETAIL,CTX)
	NEW OBJ
	SET OBJ("ok")=0,OBJ("error")=$GET(CODE),OBJ("detail")=$GET(DETAIL),OBJ("routine")="MIOOS"
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,+$GET(STATUS),.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=+$GET(STATUS)
	QUIT
	;
	;
	;