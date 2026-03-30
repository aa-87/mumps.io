MIOMOSST ; MIOMOS state/session helpers
	QUIT
	;
ENSURE(CONF,REQ,CTX,STATE,ERR)
	NEW KEY,SID,NOWD,NOWS,ABS,IDLE,USER,ROLES,STARTD,STARTS,LASTD,LASTS,BINDOK
	KILL ERR,STATE
	SET ERR("routine")="MIOMOSST"
	SET KEY=$$PRINCIPAL(.CONF,.REQ,.CTX,.ERR)
	IF KEY="" QUIT 0
	SET USER=$$USERNAME(.CONF,.CTX)
	SET ROLES=$$ROLECSV(.CONF,.CTX)
	SET ABS=+$GET(CONF("miomos","session","absoluteTimeoutSeconds"),28800)
	SET IDLE=+$GET(CONF("miomos","session","idleTimeoutSeconds"),900)
	SET SID=$GET(CTX("miomos","sessionId"))
	IF SID="" SET SID=$GET(^MIO("MIOMOS","SESSION","BYKEY",KEY))
	SET NOWD=+$PIECE($HOROLOG,",",1),NOWS=+$PIECE($HOROLOG,",",2)
	SET BINDOK=1
	IF SID'="" DO
	. IF $GET(^MIO("MIOMOS","SESSION",SID,"principal"))'="",$GET(^MIO("MIOMOS","SESSION",SID,"principal"))'=KEY SET ERR("error")="session_binding_mismatch",ERR("detail")=SID,BINDOK=0 QUIT
	. IF +$GET(^MIO("MIOMOS","SESSION",SID,"locked"))=1 SET ERR("error")="session_locked",ERR("detail")=$GET(^MIO("MIOMOS","SESSION",SID,"lockReason")),BINDOK=0 QUIT
	. IF $GET(^MIO("MIOMOS","SESSION",SID,"forcedSignout"))'="" SET ERR("error")="forced_signout",ERR("detail")=$GET(^MIO("MIOMOS","SESSION",SID,"forcedSignout")),BINDOK=0 QUIT
	. SET STARTD=+$GET(^MIO("MIOMOS","SESSION",SID,"startedDay"))
	. SET STARTS=+$GET(^MIO("MIOMOS","SESSION",SID,"startedSec"))
	. SET LASTD=+$GET(^MIO("MIOMOS","SESSION",SID,"lastDay"))
	. SET LASTS=+$GET(^MIO("MIOMOS","SESSION",SID,"lastSec"))
	. IF $$AGESEC(STARTD,STARTS,NOWD,NOWS)>ABS SET SID="" QUIT
	. IF $$AGESEC(LASTD,LASTS,NOWD,NOWS)>IDLE SET SID=""
	IF 'BINDOK QUIT 0
	IF SID="" SET SID=$$NEWSID(KEY)
	SET ^MIO("MIOMOS","SESSION","BYKEY",KEY)=SID
	SET ^MIO("MIOMOS","SESSION",SID,"principal")=KEY
	SET ^MIO("MIOMOS","SESSION",SID,"userName")=USER
	SET ^MIO("MIOMOS","SESSION",SID,"roles")=ROLES
	SET ^MIO("MIOMOS","SESSION",SID,"lastDay")=NOWD
	SET ^MIO("MIOMOS","SESSION",SID,"lastSec")=NOWS
	SET ^MIO("MIOMOS","SESSION",SID,"lastSeenAt")=$$NOWISO^MIOUTIL()
	IF '$DATA(^MIO("MIOMOS","SESSION",SID,"startedAt")) DO
	. SET ^MIO("MIOMOS","SESSION",SID,"startedAt")=$$NOWISO^MIOUTIL()
	. SET ^MIO("MIOMOS","SESSION",SID,"startedDay")=NOWD
	. SET ^MIO("MIOMOS","SESSION",SID,"startedSec")=NOWS
	SET STATE("principal")=KEY
	SET STATE("userName")=USER
	SET STATE("roles")=ROLES
	SET STATE("sessionId")=SID
	SET STATE("startedAt")=$GET(^MIO("MIOMOS","SESSION",SID,"startedAt"))
	SET STATE("lastSeenAt")=$GET(^MIO("MIOMOS","SESSION",SID,"lastSeenAt"))
	SET STATE("layoutSavedAt")=$GET(^MIO("MIOMOS","SESSION",SID,"layoutSavedAt"))
	SET STATE("savedLayoutJson")=$GET(^MIO("MIOMOS","SESSION",SID,"layoutJson"))
	NEW UISTATE DO LOADUI(SID,.UISTATE) MERGE STATE("ui")=UISTATE
	SET STATE("startMenuQuery")=$GET(STATE("ui","startMenuQuery"))
	SET STATE("idleTimeoutSeconds")=IDLE
	SET STATE("absoluteTimeoutSeconds")=ABS
	SET STATE("desktopPath")=$GET(CONF("miomos","route","desktop"),"/miomos")
	SET STATE("bootstrapPath")=$GET(CONF("miomos","route","bootstrap"),"/api/miomos/bootstrap")
	SET STATE("wsPath")=$GET(CONF("miomos","route","ws"),"/ws/miomos")
	SET STATE("themePath")=$GET(CONF("miomos","route","theme"),"/api/miomos/theme")
	SET STATE("settingsPath")=$GET(CONF("miomos","route","settings"),"/api/miomos/settings")
	SET STATE("viewPath")=$GET(CONF("miomos","route","view"),"/api/miomos/view")
	SET STATE("commandPath")=$GET(CONF("miomos","route","command"),"/api/miomos/command")
	SET STATE("vfsUploadPath")=$GET(CONF("miomos","route","vfsUpload"),"/api/miomos/vfs/upload")
	SET STATE("vfsDownloadPath")=$GET(CONF("miomos","route","vfsDownload"),"/api/miomos/vfs/download")
	SET STATE("signinPath")=$GET(CONF("miomos","route","signin"),"/api/miomos/auth/signin")
	SET STATE("signupPath")=$GET(CONF("miomos","route","signup"),"/api/miomos/auth/signup")
	SET STATE("signoutPath")=$GET(CONF("miomos","route","signout"),"/api/miomos/auth/signout")
	SET STATE("guestSigninPath")=$GET(CONF("miomos","route","guestSignin"),"/api/miomos/auth/guest")
	SET STATE("resetApplyPath")=$GET(CONF("miomos","route","resetApply"),"/api/miomos/auth/reset")
	SET STATE("adminUsersPath")=$GET(CONF("miomos","route","adminUsers"),"/api/miomos/admin/users")
	SET STATE("adminDisablePath")=$GET(CONF("miomos","route","adminDisable"),"/api/miomos/admin/users/disable")
	SET STATE("adminEnablePath")=$GET(CONF("miomos","route","adminEnable"),"/api/miomos/admin/users/enable")
	SET STATE("adminLockPath")=$GET(CONF("miomos","route","adminLock"),"/api/miomos/admin/users/lock")
	SET STATE("adminUnlockPath")=$GET(CONF("miomos","route","adminUnlock"),"/api/miomos/admin/users/unlock")
	SET STATE("adminInviteCreatePath")=$GET(CONF("miomos","route","adminInviteCreate"),"/api/miomos/admin/invites/create")
	SET STATE("adminInvitesPath")=$GET(CONF("miomos","route","adminInvites"),"/api/miomos/admin/invites")
	SET STATE("adminResetRequestPath")=$GET(CONF("miomos","route","adminResetRequest"),"/api/miomos/admin/users/reset/request")
	SET STATE("observSummaryPath")=$GET(CONF("miomos","route","observSummary"),"/api/miomos/observability/summary")
	SET STATE("accessExportPath")=$GET(CONF("miomos","route","accessExport"),"/api/miomos/observability/access/export")
	SET STATE("errorExportPath")=$GET(CONF("miomos","route","errorExport"),"/api/miomos/observability/error/export")
	SET STATE("auditExportPath")=$GET(CONF("miomos","route","auditExport"),"/api/miomos/observability/audit/export")
	SET STATE("securityDigestPath")=$GET(CONF("miomos","route","securityDigest"),"/api/miomos/observability/digest")
	SET STATE("retentionPrunePath")=$GET(CONF("miomos","route","retentionPrune"),"/api/miomos/observability/retention/prune")
	SET STATE("brandTitle")=$GET(CONF("miomos","brand","title"),"MIOMOS")
	SET STATE("brandSubtitle")=$GET(CONF("miomos","brand","subtitle"),"MUMPS-first clinical workspace")
	SET STATE("wallpaper")=$GET(CONF("miomos","desktop","wallpaper"),"midnight-clinic")
	SET STATE("accent")=$GET(CONF("miomos","desktop","accent"),"#2f6fed")
	SET STATE("density")=$GET(CONF("miomos","desktop","density"),"dense")
	SET STATE("snapMargin")=+$GET(CONF("miomos","desktop","snapMargin"),18)
	SET STATE("profile")=$$PROFILE(.CONF)
	DO LOAD^MIOMOSSET(.STATE,.CONF)
	SET STATE("terminalPipeEnabled")=+$GET(CONF("miomos","terminal","pipe","enabled"),1)
	SET STATE("terminalPipeCommand")=$GET(CONF("miomos","terminal","pipe","command"),"yottadb")
	SET STATE("terminalPipeShell")=$GET(CONF("miomos","terminal","pipe","shell"),"/bin/sh")
	SET STATE("localAuthEnabled")=+$$LOCALAUTHEN^MIOMOS(.CONF)
	SET STATE("allowSignup")=+$$ALLOWSIGNUP^MIOMOSAUTH(.CONF)
	SET STATE("inviteOnly")=+$$INVITEONLY^MIOMOSAUTH(.CONF)
	SET STATE("guestLoginEnabled")=+$GET(CONF("miomos","localAuth","guestLoginEnabled"),1)
	SET STATE("bootstrapAuthEnabled")=+$GET(CONF("miomos","bootstrapAuth","enabled"),1)
	SET STATE("chatEnabled")=+$GET(CONF("miomos","chat","enabled"),1)
	SET STATE("chatRoom")=$GET(STATE("shell","chatRoom"),$GET(CONF("miomos","chat","defaultRoom"),"general"))
	SET STATE("chatLimit")=+$GET(STATE("shell","chatLimit"),+$GET(CONF("miomos","chat","messageLimit"),20))
	SET STATE("terminalLaunchMode")=$GET(STATE("shell","terminalLaunchMode"),"resume-last")
	DO ENSURE^MIOMOSVFS(KEY,USER)
	SET STATE("shellQuickLaunch")=$GET(STATE("shell","quickLaunch"),"workspace,collaboration,terminal")
	SET STATE("logMaxEntries")=+$GET(CONF("miomos","log","maxEntries"),500)
	SET STATE("logExportLimit")=+$GET(CONF("miomos","log","exportLimit"),250)
	SET STATE("logDigestTail")=+$GET(CONF("miomos","log","digestTail"),6)
	SET STATE("accessRetainDays")=+$GET(CONF("miomos","log","access","retainDays"),30)
	SET STATE("errorRetainDays")=+$GET(CONF("miomos","log","error","retainDays"),90)
	SET STATE("auditRetainDays")=+$GET(CONF("miomos","audit","retainDays"),180)
	SET STATE("logAccessEnabled")=+$GET(CONF("miomos","log","access","enabled"),1)
	SET STATE("wsRegistryEnabled")=+$GET(CONF("miomos","websocket","observability","registryEnabled"),1)
	SET STATE("wsRegistryTailLimit")=+$GET(CONF("miomos","websocket","observability","tailLimit"),12)
	SET STATE("wsControlModel")=$GET(CONF("miomos","websocket","observability","controlModel"),"inspect-only")
	SET STATE("securitySessionBinding")=$GET(CONF("miomos","security","sessionBinding"),"principal-and-session")
	SET STATE("securityForcedSignoutEvent")=$GET(CONF("miomos","security","forcedSignoutEvent"),"session.signout")
	SET STATE("securityPermissionDeniedEvent")=$GET(CONF("miomos","security","permissionDeniedEvent"),"command.error")
	SET STATE("securityIdleLockEnabled")=+$GET(CONF("miomos","security","idleLockEnabled"),1)
	SET STATE("securityIdleLockSeconds")=+$GET(CONF("miomos","security","idleLockSeconds"),300)
	SET STATE("securitySessionRegistryEnabled")=+$GET(CONF("miomos","security","sessionRegistryEnabled"),1)
	SET STATE("securitySessionRegistryModel")=$GET(CONF("miomos","security","sessionRegistryModel"),"server-authored")
	DO REGSYNC(SID,KEY,USER,ROLES,.STATE,.CONF)
	QUIT 1
	;
PRINCIPAL(CONF,REQ,CTX,ERR)
	NEW KEY
	IF $$DEVAUTH(.CONF) QUIT $GET(CONF("miomos","dev","principal"),"dev-user")
	SET KEY=$$PRINCIPAL^MIOMOSAUTH(.CTX)
	IF KEY'="" QUIT KEY
	IF $$LOCALAUTHEN^MIOMOS(.CONF) DO  QUIT KEY
	. IF '$$LOADLOCAL^MIOMOSAUTH(.CONF,.REQ,.CTX,.ERR) SET KEY="" QUIT
	. SET KEY=$$PRINCIPAL^MIOMOSAUTH(.CTX)
	IF $$LOCALAUTHEN^MIOMOS(.CONF) SET ERR("error")="login_required" QUIT ""
	SET ERR("error")="auth_context_missing"
	QUIT ""
	;
PROFILE(CONF)
	IF $$DEVPROFILE^MIOMOS(.CONF) QUIT "dev"
	QUIT $SELECT($GET(CONF("miomos","profile"))'="":$GET(CONF("miomos","profile")),1:"prod")
	;
DEVAUTH(CONF)
	IF $$PROFILE(.CONF)="dev" QUIT 1
	IF +$GET(CONF("miomos","dev","authDisabled"),0)=1 QUIT 1
	QUIT 0
	;
USERNAME(CONF,CTX)
	IF $$DEVAUTH(.CONF) QUIT $GET(CONF("miomos","dev","userName"),"Developer")
	QUIT $$USERNAME^MIOMOSAUTH(.CTX)
	;
ROLECSV(CONF,CTX)
	IF $$DEVAUTH(.CONF) QUIT $GET(CONF("miomos","dev","roles"),"developer,admin")
	QUIT $$ROLECSV^MIOMOSAUTH(.CTX)
	;
NEWSID(KEY)
	QUIT "miomos-"_$$UUID^MIOUTIL()
	;
AGESEC(D1,S1,D2,S2)
	IF (+$GET(D1)=0),(+$GET(S1)=0) QUIT 999999999
	QUIT (((+$GET(D2)-+$GET(D1))*86400)+(+$GET(S2)-+$GET(S1)))
	;
BOOTJSON(STATE,CONF)
	NEW OBJ
	DO BOOTARY(.STATE,.CONF,.OBJ)
	QUIT $$EN^MIOJSON1(.OBJ)
	;
BOOTARY(STATE,CONF,OBJ)
	KILL OBJ
	SET OBJ("product","name")=$GET(STATE("brandTitle"),"MIOMOS")
	SET OBJ("product","subtitle")=$GET(STATE("brandSubtitle"),"MUMPS-first clinical workspace")
	SET OBJ("product","version")="roi35-websocket-shell-bus"
	SET OBJ("product","profile")=$GET(STATE("profile"),"dev")
	SET OBJ("user","id")=$GET(STATE("principal"))
	SET OBJ("user","displayName")=$GET(STATE("userName"))
	DO CSV2ARY($GET(STATE("roles")),$NAME(OBJ("user","roles")))
	SET OBJ("session","id")=$GET(STATE("sessionId"))
	SET OBJ("session","startedAt")=$GET(STATE("startedAt"))
	SET OBJ("session","lastSeenAt")=$GET(STATE("lastSeenAt"))
	SET OBJ("session","idleTimeoutSeconds")=+$GET(STATE("idleTimeoutSeconds"))
	SET OBJ("session","absoluteTimeoutSeconds")=+$GET(STATE("absoluteTimeoutSeconds"))
	NEW SNAP
	NEW SNAPOK SET SNAPOK=$$SNAPOK($GET(STATE("sessionId")),.SNAP)
	MERGE OBJ("session","ui")=SNAP("ui")
	SET OBJ("session","lastEvent")=$GET(SNAP("lastEvent"))
	SET OBJ("session","layoutSavedAt")=$GET(SNAP("layoutSavedAt"))
	SET OBJ("session","uiSavedAt")=$GET(SNAP("uiSavedAt"))
	SET OBJ("session","hasLayout")=+$GET(SNAP("hasLayout"))
	SET OBJ("session","heartbeatCount")=+$GET(SNAP("eventCounts","heartbeat"))
	SET OBJ("session","viewRefreshCount")=+$GET(SNAP("eventCounts","view.refresh"))
	SET OBJ("session","uiSaveCount")=+$GET(SNAP("eventCounts","ui_state_save"))
	SET OBJ("routes","desktop")=$GET(STATE("desktopPath"))
	SET OBJ("routes","bootstrap")=$GET(STATE("bootstrapPath"))
	SET OBJ("routes","websocket")=$GET(STATE("wsPath"))
	SET OBJ("routes","theme")=$GET(STATE("themePath"))
	SET OBJ("routes","settings")=$GET(STATE("settingsPath"))
	SET OBJ("routes","view")=$GET(STATE("viewPath"))
	SET OBJ("routes","command")=$GET(STATE("commandPath"))
	SET OBJ("routes","vfsUpload")=$GET(STATE("vfsUploadPath"))
	SET OBJ("routes","vfsDownload")=$GET(STATE("vfsDownloadPath"))
	SET OBJ("routes","commandEvent")=$GET(CONF("miomos","desktop","transport","eventName"),"command.exec")
	SET OBJ("routes","commandResultEvent")=$GET(CONF("miomos","desktop","transport","resultEvent"),"command.result")
	SET OBJ("routes","commandErrorEvent")=$GET(CONF("miomos","desktop","transport","errorEvent"),"command.error")
	SET OBJ("routes","signoutEvent")="auth.signout"
	SET OBJ("routes","signin")=$GET(STATE("signinPath"))
	SET OBJ("routes","signup")=$GET(STATE("signupPath"))
	SET OBJ("routes","signout")=$GET(STATE("signoutPath"))
	SET OBJ("routes","guestSignin")=$GET(STATE("guestSigninPath"))
	SET OBJ("routes","resetApply")=$GET(STATE("resetApplyPath"))
	SET OBJ("routes","adminUsers")=$GET(STATE("adminUsersPath"))
	SET OBJ("routes","adminDisable")=$GET(STATE("adminDisablePath"))
	SET OBJ("routes","adminEnable")=$GET(STATE("adminEnablePath"))
	SET OBJ("routes","adminLock")=$GET(STATE("adminLockPath"))
	SET OBJ("routes","adminUnlock")=$GET(STATE("adminUnlockPath"))
	SET OBJ("routes","adminInviteCreate")=$GET(STATE("adminInviteCreatePath"))
	SET OBJ("routes","adminInvites")=$GET(STATE("adminInvitesPath"))
	SET OBJ("routes","adminResetRequest")=$GET(STATE("adminResetRequestPath"))
	SET OBJ("routes","observSummary")=$GET(STATE("observSummaryPath"))
	SET OBJ("routes","accessExport")=$GET(STATE("accessExportPath"))
	SET OBJ("routes","errorExport")=$GET(STATE("errorExportPath"))
	SET OBJ("routes","auditExport")=$GET(STATE("auditExportPath"))
	SET OBJ("routes","securityDigest")=$GET(STATE("securityDigestPath"))
	SET OBJ("routes","retentionPrune")=$GET(STATE("retentionPrunePath"))
	SET OBJ("desktopPath")=$GET(STATE("desktopPath"))
	SET OBJ("bootstrapPath")=$GET(STATE("bootstrapPath"))
	SET OBJ("websocketPath")=$GET(STATE("wsPath"))
	SET OBJ("desktop","theme","currentKey")=$GET(STATE("themeKey"))
	DO PUTOBJ^MIOMOSTH($NAME(OBJ("desktop","theme","current")),$GET(STATE("themeKey")))
	DO CATALOG^MIOMOSTH($NAME(OBJ("desktop","themes")))
	SET OBJ("desktop","density")=$GET(STATE("density"))
	SET OBJ("desktop","fontFamily")=$GET(STATE("fontFamily"))
	SET OBJ("desktop","fontSize")=+$GET(STATE("fontSize"),13)
	SET OBJ("desktop","titleAccent")=$GET(STATE("titleAccent"))
	SET OBJ("desktop","titleAccentValue")=$GET(STATE("titleAccentValue"))
	SET OBJ("desktop","iconStyle")=$GET(STATE("iconStyle"))
	SET OBJ("desktop","animations")=$GET(STATE("animations"))
	SET OBJ("desktop","snapMargin")=+$GET(STATE("snapMargin"),18)
	DO PUTBOOT^MIOMOSSET($NAME(OBJ("desktop","settings")),.STATE,.CONF)
	DO PUTBOOT^MIOMOSWM($NAME(OBJ("desktop","windowManager")),.STATE,.CONF)
	DO BOOT^MIOMOSVFS($GET(STATE("principal")),.CONF,$NAME(OBJ("desktop","vfs")))
	SET OBJ("desktop","launcherLabel")="Start"
	SET OBJ("desktop","shellChrome")="winxp-inspired"
	SET OBJ("desktop","taskbarStyle")="xp-plus-tray"
	SET OBJ("desktop","taskbarBehavior")="stable-order"
	SET OBJ("desktop","taskbarFocusPolicy")="focus-without-reorder"
	SET OBJ("desktop","taskbarOverflowBehavior")="preserve-order-and-overflow"
	SET OBJ("desktop","startMenuStyle")="winxp-dual-pane"
	SET OBJ("desktop","startMenuBehavior")="predictable-sections"
	SET OBJ("desktop","startSearchBehavior")="filter-programs-and-actions"
	SET OBJ("desktop","taskbarClickPolicy")="xp-toggle"
	SET OBJ("desktop","shellSurfacePolicy")="single-open-surface"
	SET OBJ("desktop","startMenuSectionMemory")="server-backed"
	SET OBJ("desktop","keyboardModel")="ctrl-escape-enter-search"
	SET OBJ("desktop","contextMenuStyle")="winxp"
	SET OBJ("desktop","contextMenuStatefulness")="window-aware"
	SET OBJ("desktop","trayStyle")="xp-notify-area"
	SET OBJ("desktop","dialogStyle")="xp-shell-classic"
	SET OBJ("desktop","dialogBehavior")="draggable-shell-dialogs"
	SET OBJ("desktop","folderCreateBehavior")="desktop-context-menu"
	SET OBJ("desktop","desktopIconBehavior")="draggable-autosave"
	SET OBJ("desktop","desktopComposition")="ui-samples-settings-terminal"
	SET OBJ("desktop","explorerStyle")="winxp-shell-folder"
	SET OBJ("desktop","explorerViewMode")="large-icons"
	SET OBJ("desktop","explorerDefaultView")="large-icons"
	SET OBJ("desktop","explorerViewModes")="thumbnails,tiles,large-icons,icons,list,details"
	SET OBJ("desktop","explorerDefaultSort")="name"
	SET OBJ("desktop","explorerDefaultSortDir")="asc"
	SET OBJ("desktop","explorerSortModel")="name-size-type-modified"
	SET OBJ("desktop","explorerLayoutBehavior")="manual-drag-with-arrange-icons"
	SET OBJ("desktop","explorerSidePane")="common-tasks-other-places-details"
	SET OBJ("desktop","explorerStatusBar")="selection-summary"
	SET OBJ("desktop","explorerReplicaTarget")="windows-xp-folder-view"
	SET OBJ("desktop","dragDropModel")="xp-shell-semantics"
	SET OBJ("desktop","dragDropDefaultOperation")="move"
	SET OBJ("desktop","dragDropCopyModifier")="ctrl"
	SET OBJ("desktop","dragDropShortcutModifier")="alt"
	SET OBJ("desktop","dragDropDirectoryTarget")="folder-and-explorer-directory"
	SET OBJ("desktop","dragDropPermissionModel")="directory-flags-and-shell-rules"
	SET OBJ("desktop","dragDropBridge")="layout-preview-until-websocket-fs-bridge"
	SET OBJ("desktop","dragDropProgressiveEnhancement")="browser-safe-no-native-dragout-required"
	SET OBJ("desktop","mutationSaveBehavior")="layout-on-shell-mutation"
	SET OBJ("desktop","engine")="miomos-native-vue-css"
	SET OBJ("desktop","windowManagerName")="miomos-native-window-manager"
	SET OBJ("desktop","nativeShell")=1
	SET OBJ("desktop","osjsEnabled")=0
	SET OBJ("desktop","savedLayoutJson")=$GET(^MIO("MIOMOS","SESSION",$GET(STATE("sessionId")),"layoutJson"))
	SET OBJ("desktop","savedLayoutAt")=$GET(^MIO("MIOMOS","SESSION",$GET(STATE("sessionId")),"layoutSavedAt"))
	SET OBJ("desktop","contractVersion")="2026-03-roi35"
	SET OBJ("desktop","mobile","enabled")=1
	SET OBJ("desktop","mobile","breakpoint")=900
	SET OBJ("desktop","mobile","mode")="stacked-shell"
	SET OBJ("desktop","mobile","touchTargets")="comfortable"
	SET OBJ("desktop","mobile","dragging")="disabled-under-breakpoint"
	SET OBJ("desktop","renderMode")="mumps-first"
	SET OBJ("desktop","renderer")="vue-thin"
	SET OBJ("desktop","commandTransport")=$GET(CONF("miomos","desktop","transport","commandBus"),"websocket-only")
	SET OBJ("desktop","commandEvent")=$GET(CONF("miomos","desktop","transport","eventName"),"command.exec")
	SET OBJ("desktop","commandResultEvent")=$GET(CONF("miomos","desktop","transport","resultEvent"),"command.result")
	SET OBJ("desktop","commandErrorEvent")=$GET(CONF("miomos","desktop","transport","errorEvent"),"command.error")
	SET OBJ("desktop","realtimeContract")="single-websocket-command-and-events"
	SET OBJ("desktop","signoutTransport")="websocket-event"
	SET OBJ("desktop","motionProfile")=$GET(STATE("motionProfile"))
	SET OBJ("desktop","titlebarStyle")=$GET(STATE("titlebarStyle"))
	SET OBJ("desktop","windowPreset")=$GET(STATE("windowPreset"))
	SET OBJ("desktop","snapMode")=$GET(STATE("snapMode"))
	SET OBJ("desktop","uiState","menuOpen")=+$GET(STATE("ui","menuOpen"))
	SET OBJ("desktop","uiState","activeWindowId")=$GET(STATE("ui","activeWindowId"))
	SET OBJ("desktop","uiState","focusedAppKey")=$GET(STATE("ui","focusedAppKey"))
	SET OBJ("desktop","uiState","layoutMode")=$GET(STATE("ui","layoutMode"))
	SET OBJ("desktop","uiState","lastCommandName")=$GET(STATE("ui","lastCommandName"))
	SET OBJ("desktop","uiState","startMenuSection")=$GET(STATE("ui","startMenuSection"))
	SET OBJ("desktop","uiState","startMenuQuery")=$GET(STATE("ui","startMenuQuery"))
	SET OBJ("desktop","uiState","shellSurface")=$GET(STATE("ui","shellSurface"))
	SET OBJ("desktop","uiState","activeTerminalTabId")=$GET(STATE("ui","activeTerminalTabId"))
	MERGE OBJ("desktop","shell")=STATE("shell")
	SET OBJ("desktop","policy","heartbeatMs")=+$GET(CONF("miomos","desktop","policy","heartbeatMs"),15000)
	SET OBJ("desktop","policy","reconnectBaseMs")=+$GET(CONF("miomos","desktop","policy","reconnectBaseMs"),1000)
	SET OBJ("desktop","policy","reconnectMaxMs")=+$GET(CONF("miomos","desktop","policy","reconnectMaxMs"),15000)
	SET OBJ("desktop","policy","staleSocketMs")=+$GET(CONF("miomos","desktop","policy","staleSocketMs"),45000)
	SET OBJ("desktop","policy","commandMaxInflight")=+$GET(CONF("miomos","desktop","policy","commandMaxInflight"),3)
	SET OBJ("desktop","policy","commandTimeoutMs")=+$GET(CONF("miomos","desktop","policy","commandTimeoutMs"),8000)
	SET OBJ("desktop","policy","persistMenuState")=+$GET(CONF("miomos","desktop","policy","persistMenuState"),1)
	SET OBJ("desktop","policy","persistActiveWindow")=+$GET(CONF("miomos","desktop","policy","persistActiveWindow"),1)
	SET OBJ("desktop","policy","persistLayout")=+$GET(CONF("miomos","desktop","policy","persistLayout"),1)
	SET OBJ("desktop","policy","showReliabilityPanel")=+$GET(CONF("miomos","desktop","policy","showReliabilityPanel"),1)
	SET OBJ("observability","retention","accessDays")=+$GET(STATE("accessRetainDays"))
	SET OBJ("observability","retention","errorDays")=+$GET(STATE("errorRetainDays"))
	SET OBJ("observability","retention","auditDays")=+$GET(STATE("auditRetainDays"))
	SET OBJ("observability","retention","maxEntries")=+$GET(STATE("logMaxEntries"))
	SET OBJ("observability","retention","exportLimit")=+$GET(STATE("logExportLimit"))
	SET OBJ("observability","retention","digestTail")=+$GET(STATE("logDigestTail"))
	NEW WSS
	DO WSSUMMARY^MIOMOSOBS(.WSS)
	MERGE OBJ("observability","websocket")=WSS
	SET OBJ("observability","websocket","registryEnabled")=+$GET(STATE("wsRegistryEnabled"),1)
	SET OBJ("observability","websocket","tailLimit")=+$GET(STATE("wsRegistryTailLimit"),12)
	SET OBJ("observability","websocket","controlModel")=$GET(STATE("wsControlModel"),"inspect-only")
	SET OBJ("auth","localEnabled")=+$GET(STATE("localAuthEnabled"))
	SET OBJ("auth","allowSignup")=+$GET(STATE("allowSignup"))
	SET OBJ("auth","inviteOnly")=+$GET(STATE("inviteOnly"))
	SET OBJ("auth","guestLoginEnabled")=+$GET(STATE("guestLoginEnabled"),1)
	SET OBJ("auth","guestRole")="guest"
	SET OBJ("auth","bootstrapEnabled")=+$GET(STATE("bootstrapAuthEnabled"),1)
	DO BOOTUSERS(.CONF,$NAME(OBJ("auth","seededUsers")))
	SET OBJ("chat","enabled")=+$GET(STATE("chatEnabled"))
	SET OBJ("chat","room")=$GET(STATE("chatRoom"))
	SET OBJ("chat","limit")=+$GET(STATE("chatLimit"),20)
	SET OBJ("terminal","transport")="pipe"
	SET OBJ("terminal","commandTransport")=$GET(CONF("miomos","desktop","transport","commandBus"),"websocket-only")
	SET OBJ("terminal","pipeEnabled")=+$GET(STATE("terminalPipeEnabled"),1)
	SET OBJ("terminal","command")=$GET(STATE("terminalPipeCommand"))
	SET OBJ("terminal","shell")=$GET(STATE("terminalPipeShell"))
	SET OBJ("terminal","launchMode")=$GET(STATE("terminalLaunchMode"),"resume-last")
	MERGE OBJ("terminal","profile")=STATE("terminal")
	NEW CNT,USR,INV,RST,OBS
	DO LIST^MIOMOSPERM($GET(STATE("roles")),$NAME(OBJ("security","permissions")))
	DO SUMMARY^MIOMOSOBS(.STATE,.CONF,.OBS)
	MERGE OBJ("security","observability")=OBS
	DO COUNTS^MIOMOSADMIN(.CNT)
	MERGE OBJ("security","adminCounts")=CNT
	DO USERLIST^MIOMOSADMIN(12,.USR)
	MERGE OBJ("security","users")=USR
	DO INVITELIST^MIOMOSADMIN(6,.INV)
	MERGE OBJ("security","invites")=INV
	DO RESETLIST^MIOMOSADMIN(6,.RST)
	MERGE OBJ("security","resets")=RST
	SET OBJ("security","sessionBinding")=$GET(STATE("securitySessionBinding"),"principal-and-session")
	SET OBJ("security","forcedSignoutEvent")=$GET(STATE("securityForcedSignoutEvent"),"session.signout")
	SET OBJ("security","permissionDeniedEvent")=$GET(STATE("securityPermissionDeniedEvent"),"command.error")
	SET OBJ("security","idleLock","enabled")=+$GET(STATE("securityIdleLockEnabled"),1)
	SET OBJ("security","idleLock","seconds")=+$GET(STATE("securityIdleLockSeconds"),300)
	SET OBJ("security","idleLock","model")="server-authored-idle-lock"
	SET OBJ("security","sessionRegistry","enabled")=+$GET(STATE("securitySessionRegistryEnabled"),1)
	SET OBJ("security","sessionRegistry","model")=$GET(STATE("securitySessionRegistryModel"),"server-authored")
	N TTMP M TTMP=OBJ("security","sessionRegistry","current") DO REGSNAP($GET(STATE("sessionId")),.TTMP) M OBJ("security","sessionRegistry","current")=TTMP K TTMP
	DO RELEASEARY(.STATE,.CONF,$NAME(OBJ("release")))
	DO APPS($NAME(OBJ("desktop","apps")),.STATE)
	DO WINS($NAME(OBJ("desktop","windows")),.STATE)
		MERGE OBJ("apps")=OBJ("desktop","apps")
		MERGE OBJ("windows")=OBJ("desktop","windows")
	NEW VIEW
	DO BUILD^MIOMOSVM(.STATE,.CONF,.VIEW)
	MERGE OBJ("view")=VIEW
	QUIT
	;
BOOTUSERS(CONF,ROOT)
	NEW P
	KILL @ROOT
	FOR P="admin","user","guest" DO
	. SET @ROOT@(P,"username")=$$CANON^MIOMOSAUTH($GET(CONF("miomos","bootstrapAuth",P,"username"),P))
	. SET @ROOT@(P,"displayName")=$GET(CONF("miomos","bootstrapAuth",P,"displayName"),$$TITLE^MIOMOSAUTH(P))
	. SET @ROOT@(P,"roles")=$GET(CONF("miomos","bootstrapAuth",P,"roles"),$SELECT(P="admin":"admin",P="user":"operator",1:"guest"))
	QUIT
	;
RELEASEARY(STATE,CONF,ROOT)
	KILL @ROOT
	SET @ROOT@("model")=$GET(CONF("miomos","release","model"),"test-runbook-checklist")
	SET @ROOT@("docsCurrent")=+$GET(CONF("miomos","release","docsCurrent"),1)
	SET @ROOT@("tests","suite")=$GET(CONF("miomos","release","tests","suite"),"^MIOMOST")
	SET @ROOT@("tests","quietSuccess")=+$GET(CONF("miomos","release","tests","quietSuccess"),1)
	SET @ROOT@("runbooks","deploy")=$GET(CONF("miomos","release","runbooks","deploy"),"systemd-caddy-nginx")
	SET @ROOT@("runbooks","restart")=$GET(CONF("miomos","release","runbooks","restart"),"graceful-websocket-aware")
	SET @ROOT@("runbooks","routeRebuild")=$GET(CONF("miomos","release","runbooks","routeRebuild"),"REG^MIOMOS+COMPILE^MIOROUTE")
	SET @ROOT@("smoke","websocket",1,"key")="hello",@ROOT@("smoke","websocket",1,"label")="Hello handshake"
	SET @ROOT@("smoke","websocket",2,"key")="ping",@ROOT@("smoke","websocket",2,"label")="Heartbeat ping/pong"
	SET @ROOT@("smoke","websocket",3,"key")="command",@ROOT@("smoke","websocket",3,"label")="Command bus request/response"
	SET @ROOT@("smoke","websocket",4,"key")="terminal",@ROOT@("smoke","websocket",4,"label")="Terminal open/input/output"
	SET @ROOT@("smoke","browser",1,"key")="start-menu",@ROOT@("smoke","browser",1,"label")="Start menu and shell chrome"
	SET @ROOT@("smoke","browser",2,"key")="theme",@ROOT@("smoke","browser",2,"label")="Theme and settings persistence"
	SET @ROOT@("smoke","browser",3,"key")="terminal-focus",@ROOT@("smoke","browser",3,"label")="Terminal input, clear, and palette"
	SET @ROOT@("smoke","browser",4,"key")="reconnect",@ROOT@("smoke","browser",4,"label")="Reconnect banner and socket recovery"
	QUIT
	;
	;
CSV2ARY(CSV,ROOT)
	NEW I,X,N
	KILL @ROOT
	SET N=0
	FOR I=1:1:$LENGTH($GET(CSV),",") DO
	. SET X=$$TRIM($PIECE(CSV,",",I))
	. IF X="" QUIT
	. SET N=N+1,@ROOT@(N)=X
	QUIT
	;
TRIM(X)
	QUIT $$TRIM^MIOUTIL($GET(X))
	;
APPS(ROOT,STATE)
	KILL @ROOT
	SET @ROOT@(1,"key")="workspace",@ROOT@(1,"title")="Workspace",@ROOT@(1,"subtitle")="Core queues, review, export, and operational work surfaces",@ROOT@(1,"icon")=$GET(STATE("icon","workspace"),"APP"),@ROOT@(1,"badge")="Primary",@ROOT@(1,"kind")="app",@ROOT@(1,"group")="Applications",@ROOT@(1,"order")=10,@ROOT@(1,"launchKey")="workspace",@ROOT@(1,"desktopPinned")=0,@ROOT@(1,"status")="available"
	SET @ROOT@(2,"key")="settings",@ROOT@(2,"title")="Settings",@ROOT@(2,"subtitle")="Themes, fonts, density, motion, icons, and preferences",@ROOT@(2,"icon")=$GET(STATE("icon","settings"),"SET"),@ROOT@(2,"badge")="Prefs",@ROOT@(2,"kind")="settings",@ROOT@(2,"group")="Pinned",@ROOT@(2,"order")=20,@ROOT@(2,"launchKey")="settings",@ROOT@(2,"desktopPinned")=1,@ROOT@(2,"status")="available"
	SET @ROOT@(3,"key")="ui-library",@ROOT@(3,"title")="UI Library",@ROOT@(3,"subtitle")="7.css-influenced forms, tables, overlays, navigation, and tokens",@ROOT@(3,"icon")="UIL",@ROOT@(3,"badge")="Design",@ROOT@(3,"kind")="app",@ROOT@(3,"group")="Applications",@ROOT@(3,"order")=25,@ROOT@(3,"launchKey")="ui-library",@ROOT@(3,"desktopPinned")=0,@ROOT@(3,"status")="available"
	SET @ROOT@(4,"key")="jobs",@ROOT@(4,"title")="Jobs",@ROOT@(4,"subtitle")="Incoming work, queues, and monitored processing directories",@ROOT@(4,"icon")="DIR",@ROOT@(4,"badge")="Folder",@ROOT@(4,"kind")="directory",@ROOT@(4,"group")="Directories",@ROOT@(4,"order")=30,@ROOT@(4,"launchKey")="workspace",@ROOT@(4,"desktopPinned")=0,@ROOT@(4,"status")="available",@ROOT@(4,"summary")="142 active items"
	SET @ROOT@(5,"key")="exports",@ROOT@(5,"title")="Exports",@ROOT@(5,"subtitle")="Output artifacts, delivery staging, and downstream release folders",@ROOT@(5,"icon")="OUT",@ROOT@(5,"badge")="Folder",@ROOT@(5,"kind")="directory",@ROOT@(5,"group")="Directories",@ROOT@(5,"order")=40,@ROOT@(5,"launchKey")="workspace",@ROOT@(5,"desktopPinned")=0,@ROOT@(5,"status")="available",@ROOT@(5,"summary")="328 exports today"
	SET @ROOT@(6,"key")="profiles",@ROOT@(6,"title")="Profiles",@ROOT@(6,"subtitle")="Theme, terminal, workspace, and automation profile definitions",@ROOT@(6,"icon")="PRF",@ROOT@(6,"badge")="Folder",@ROOT@(6,"kind")="directory",@ROOT@(6,"group")="Directories",@ROOT@(6,"order")=50,@ROOT@(6,"launchKey")="settings",@ROOT@(6,"desktopPinned")=0,@ROOT@(6,"status")="available",@ROOT@(6,"summary")="Personalized"
	SET @ROOT@(7,"key")="terminal",@ROOT@(7,"title")="Terminal",@ROOT@(7,"subtitle")="Standard YottaDB session and future admin console",@ROOT@(7,"icon")=$GET(STATE("icon","terminal"),"YDB"),@ROOT@(7,"badge")="CLI",@ROOT@(7,"kind")="app",@ROOT@(7,"group")="Pinned",@ROOT@(7,"order")=60,@ROOT@(7,"launchKey")="terminal",@ROOT@(7,"desktopPinned")=1,@ROOT@(7,"status")="available"
	SET @ROOT@(8,"key")="collaboration",@ROOT@(8,"title")="Chat",@ROOT@(8,"subtitle")="User chat and analyst coordination workspace",@ROOT@(8,"icon")=$GET(STATE("icon","collaboration"),"CHT"),@ROOT@(8,"badge")="Team",@ROOT@(8,"kind")="app",@ROOT@(8,"group")="Applications",@ROOT@(8,"order")=70,@ROOT@(8,"launchKey")="collaboration",@ROOT@(8,"status")="available"
	SET @ROOT@(9,"key")="security",@ROOT@(9,"title")="Security",@ROOT@(9,"subtitle")="Access, errors, permissions, audit, and retention posture",@ROOT@(9,"icon")=$GET(STATE("icon","security"),"SEC"),@ROOT@(9,"badge")="Audit",@ROOT@(9,"kind")="app",@ROOT@(9,"group")="System",@ROOT@(9,"order")=80,@ROOT@(9,"launchKey")="security",@ROOT@(9,"status")="available"
	SET @ROOT@(10,"key")="admin",@ROOT@(10,"title")="Admin",@ROOT@(10,"subtitle")="Users, invites, reset tokens, and operational identity health",@ROOT@(10,"icon")=$GET(STATE("icon","admin"),"ADM"),@ROOT@(10,"badge")="Ops",@ROOT@(10,"kind")="app",@ROOT@(10,"group")="System",@ROOT@(10,"order")=90,@ROOT@(10,"launchKey")="admin",@ROOT@(10,"status")="available"
	SET @ROOT@(11,"key")="logs",@ROOT@(11,"title")="Logs",@ROOT@(11,"subtitle")="Audit, access, and operational trace directories",@ROOT@(11,"icon")="LOG",@ROOT@(11,"badge")="Folder",@ROOT@(11,"kind")="directory",@ROOT@(11,"group")="Directories",@ROOT@(11,"order")=100,@ROOT@(11,"desktopPinned")=0,@ROOT@(11,"launchKey")="security",@ROOT@(11,"status")="available",@ROOT@(11,"summary")="Retention managed"
	SET @ROOT@(14,"key")="ui-samples",@ROOT@(14,"title")="UI Samples",@ROOT@(14,"subtitle")="Shell samples, UI library, and curated showcase surfaces",@ROOT@(14,"icon")="UI",@ROOT@(14,"badge")="Folder",@ROOT@(14,"kind")="directory",@ROOT@(14,"group")="Pinned",@ROOT@(14,"order")=15,@ROOT@(14,"launchKey")="ui-samples",@ROOT@(14,"desktopPinned")=1,@ROOT@(14,"status")="available",@ROOT@(14,"summary")="Product shell samples"
	SET @ROOT@(15,"key")="my-computer",@ROOT@(15,"title")="My Computer",@ROOT@(15,"subtitle")="Browse shell surfaces, devices, and workspace roots",@ROOT@(15,"icon")="PC",@ROOT@(15,"badge")="System",@ROOT@(15,"kind")="directory",@ROOT@(15,"group")="Pinned",@ROOT@(15,"order")=11,@ROOT@(15,"launchKey")="my-computer",@ROOT@(15,"desktopPinned")=1,@ROOT@(15,"status")="available",@ROOT@(15,"summary")="System shell"
	SET @ROOT@(16,"key")="my-documents",@ROOT@(16,"title")="My Documents",@ROOT@(16,"subtitle")="Personal workspace documents and common project folders",@ROOT@(16,"icon")="DOC",@ROOT@(16,"badge")="System",@ROOT@(16,"kind")="directory",@ROOT@(16,"group")="Pinned",@ROOT@(16,"order")=12,@ROOT@(16,"launchKey")="my-documents",@ROOT@(16,"desktopPinned")=1,@ROOT@(16,"status")="available",@ROOT@(16,"summary")="Personal files"
	SET @ROOT@(17,"key")="my-network-places",@ROOT@(17,"title")="My Network Places",@ROOT@(17,"subtitle")="Collaboration rooms, websocket presence, and shared services",@ROOT@(17,"icon")="NET",@ROOT@(17,"badge")="System",@ROOT@(17,"kind")="directory",@ROOT@(17,"group")="Pinned",@ROOT@(17,"order")=13,@ROOT@(17,"launchKey")="my-network-places",@ROOT@(17,"desktopPinned")=1,@ROOT@(17,"status")="available",@ROOT@(17,"summary")="Shared access"
	SET @ROOT@(18,"key")="recycle-bin",@ROOT@(18,"title")="Recycle Bin",@ROOT@(18,"subtitle")="Recently deleted desktop folders and pending cleanup",@ROOT@(18,"icon")="BIN",@ROOT@(18,"badge")="System",@ROOT@(18,"kind")="directory",@ROOT@(18,"group")="Pinned",@ROOT@(18,"order")=14,@ROOT@(18,"launchKey")="recycle-bin",@ROOT@(18,"desktopPinned")=1,@ROOT@(18,"status")="available",@ROOT@(18,"summary")="Deleted items"
	QUIT
	;
WINS(ROOT,STATE)
	NEW N
	DO DEFAULTWINS^MIOMOSWM(ROOT,$GET(STATE("windowPreset"),"analyst"))
	SET N=$ORDER(@ROOT@(""),-1)+1
	SET @ROOT@(N,"id")="win-ui-samples",@ROOT@(N,"appKey")="ui-samples",@ROOT@(N,"title")="UI Samples",@ROOT@(N,"left")=240,@ROOT@(N,"top")=82,@ROOT@(N,"width")=860,@ROOT@(N,"height")=560,@ROOT@(N,"z")=5,@ROOT@(N,"state")="minimized",@ROOT@(N,"taskOrder")=7
	SET N=N+1
	SET @ROOT@(N,"id")="win-ui-library",@ROOT@(N,"appKey")="ui-library",@ROOT@(N,"title")="UI Library",@ROOT@(N,"left")=268,@ROOT@(N,"top")=94,@ROOT@(N,"width")=920,@ROOT@(N,"height")=600,@ROOT@(N,"z")=6,@ROOT@(N,"state")="minimized",@ROOT@(N,"taskOrder")=8
	QUIT
	;
SAVELAYOUT(SID,PAYLOAD)
	DO SAVELAYOUTCORE(SID,$GET(PAYLOAD))
	QUIT
	;
SAVELAYOUTOK(SID,PAYLOAD)
	NEW OK SET OK=0
	DO SAVELAYOUTCORE(SID,$GET(PAYLOAD),.OK)
	QUIT OK
	;
SAVELAYOUTCORE(SID,PAYLOAD,OK)
	NEW TREE,ERR,LAYOUT,RAW
	SET:$DATA(OK) OK=0
	IF $GET(SID)="" QUIT
	SET RAW=$GET(PAYLOAD)
	IF RAW'="",$EXTRACT(RAW,1)="{" DO
	. IF $$DECODE^MIOJSON(RAW,.TREE,.ERR) DO
	. . IF $DATA(TREE("layout","windows")) DO
	. . . MERGE LAYOUT=TREE("layout")
	. . . SET RAW=$$EN^MIOJSON1(.LAYOUT)
	. . IF '$DATA(TREE("layout","windows")),$DATA(TREE("windows")) DO
	. . . MERGE LAYOUT=TREE
	. . . SET RAW=$$EN^MIOJSON1(.LAYOUT)
	SET ^MIO("MIOMOS","SESSION",SID,"layoutJson")=$EXTRACT(RAW,1,16384)
	SET ^MIO("MIOMOS","SESSION",SID,"layoutSavedAt")=$$NOWISO^MIOUTIL()
	DO TOUCH(SID,"layout.save")
	SET:$DATA(OK) OK=1
	QUIT
	;
	;
SAVEUI(SID,PAYLOAD)
	DO SAVEUICORE(SID,$GET(PAYLOAD))
	QUIT
	;
SAVEUIOK(SID,PAYLOAD)
	NEW OK SET OK=0
	DO SAVEUICORE(SID,$GET(PAYLOAD),.OK)
	QUIT OK
	;
SAVEUICORE(SID,PAYLOAD,OK)
	NEW TREE,ERR,RAW,SAVE
	SET:$DATA(OK) OK=0
	IF $GET(SID)="" QUIT
	SET RAW=$GET(PAYLOAD)
	KILL SAVE
	IF RAW'="",$EXTRACT(RAW,1)="{" DO
	. IF $$DECODE^MIOJSON(RAW,.TREE,.ERR) DO
	. . SET SAVE("menuOpen")=+$GET(TREE("menuOpen"))
	. . SET SAVE("activeWindowId")=$EXTRACT($GET(TREE("activeWindowId")),1,128)
	. . SET SAVE("focusedAppKey")=$EXTRACT($GET(TREE("focusedAppKey")),1,64)
	. . SET SAVE("layoutMode")=$EXTRACT($GET(TREE("layoutMode")),1,64)
	. . SET SAVE("lastCommandName")=$EXTRACT($GET(TREE("lastCommandName")),1,128)
	. . SET SAVE("terminalId")=$EXTRACT($GET(TREE("terminalId")),1,128)
	. . SET SAVE("reason")=$EXTRACT($GET(TREE("reason")),1,64)
	. . SET SAVE("startMenuSection")=$EXTRACT($GET(TREE("startMenuSection")),1,64)
	. . SET SAVE("startMenuQuery")=$EXTRACT($GET(TREE("startMenuQuery")),1,128)
	. . SET SAVE("shellSurface")=$EXTRACT($GET(TREE("shellSurface")),1,32)
	. . SET SAVE("activeTerminalTabId")=$EXTRACT($GET(TREE("activeTerminalTabId")),1,128)
	ELSE  DO
	. SET SAVE("menuOpen")=0
	. SET SAVE("activeWindowId")=""
	. SET SAVE("focusedAppKey")=""
	. SET SAVE("layoutMode")=""
	. SET SAVE("lastCommandName")=""
	. SET SAVE("terminalId")=""
	. SET SAVE("reason")=""
	. SET SAVE("startMenuSection")=""
	. SET SAVE("startMenuQuery")=""
	. SET SAVE("shellSurface")=""
	. SET SAVE("activeTerminalTabId")=""
	KILL ^MIO("MIOMOS","SESSION",SID,"ui")
	SET ^MIO("MIOMOS","SESSION",SID,"ui","menuOpen")=+$GET(SAVE("menuOpen"))
	SET ^MIO("MIOMOS","SESSION",SID,"ui","activeWindowId")=$GET(SAVE("activeWindowId"))
	SET ^MIO("MIOMOS","SESSION",SID,"ui","focusedAppKey")=$GET(SAVE("focusedAppKey"))
	SET ^MIO("MIOMOS","SESSION",SID,"ui","layoutMode")=$GET(SAVE("layoutMode"))
	SET ^MIO("MIOMOS","SESSION",SID,"ui","lastCommandName")=$GET(SAVE("lastCommandName"))
	SET ^MIO("MIOMOS","SESSION",SID,"ui","terminalId")=$GET(SAVE("terminalId"))
	SET ^MIO("MIOMOS","SESSION",SID,"ui","reason")=$GET(SAVE("reason"))
	SET ^MIO("MIOMOS","SESSION",SID,"ui","startMenuSection")=$GET(SAVE("startMenuSection"))
	SET ^MIO("MIOMOS","SESSION",SID,"ui","startMenuQuery")=$GET(SAVE("startMenuQuery"))
	SET ^MIO("MIOMOS","SESSION",SID,"ui","shellSurface")=$GET(SAVE("shellSurface"))
	SET ^MIO("MIOMOS","SESSION",SID,"ui","activeTerminalTabId")=$GET(SAVE("activeTerminalTabId"))
	SET ^MIO("MIOMOS","SESSION",SID,"uiJson")=$EXTRACT($$EN^MIOJSON1(.SAVE),1,4096)
	SET ^MIO("MIOMOS","SESSION",SID,"uiSavedAt")=$$NOWISO^MIOUTIL()
	DO TOUCH(SID,"ui_state_save")
	SET:$DATA(OK) OK=1
	QUIT
	;
LOADUI(SID,OUT)
	KILL OUT
	IF $GET(SID)="" QUIT
	SET OUT("menuOpen")=+$GET(^MIO("MIOMOS","SESSION",SID,"ui","menuOpen"))
	SET OUT("activeWindowId")=$GET(^MIO("MIOMOS","SESSION",SID,"ui","activeWindowId"))
	SET OUT("focusedAppKey")=$GET(^MIO("MIOMOS","SESSION",SID,"ui","focusedAppKey"))
	SET OUT("layoutMode")=$GET(^MIO("MIOMOS","SESSION",SID,"ui","layoutMode"))
	SET OUT("lastCommandName")=$GET(^MIO("MIOMOS","SESSION",SID,"ui","lastCommandName"))
	SET OUT("terminalId")=$GET(^MIO("MIOMOS","SESSION",SID,"ui","terminalId"))
	SET OUT("reason")=$GET(^MIO("MIOMOS","SESSION",SID,"ui","reason"))
	SET OUT("startMenuSection")=$GET(^MIO("MIOMOS","SESSION",SID,"ui","startMenuSection"))
	SET OUT("startMenuQuery")=$GET(^MIO("MIOMOS","SESSION",SID,"ui","startMenuQuery"))
	SET OUT("shellSurface")=$GET(^MIO("MIOMOS","SESSION",SID,"ui","shellSurface"))
	SET OUT("activeTerminalTabId")=$GET(^MIO("MIOMOS","SESSION",SID,"ui","activeTerminalTabId"))
	QUIT
	;
TOUCH(SID,EVENT)
	DO TOUCHCORE(SID,$GET(EVENT))
	QUIT
	;
TOUCHOK(SID,EVENT)
	NEW OK SET OK=0
	DO TOUCHCORE(SID,$GET(EVENT),.OK)
	QUIT OK
	;
TOUCHCORE(SID,EVENT,OK)
	NEW NOWD,NOWS,KEY
	SET:$DATA(OK) OK=0
	IF $GET(SID)="" QUIT
	SET NOWD=+$PIECE($HOROLOG,",",1),NOWS=+$PIECE($HOROLOG,",",2)
	SET ^MIO("MIOMOS","SESSION",SID,"lastDay")=NOWD
	SET ^MIO("MIOMOS","SESSION",SID,"lastSec")=NOWS
	SET ^MIO("MIOMOS","SESSION",SID,"lastSeenAt")=$$NOWISO^MIOUTIL()
	SET KEY=$EXTRACT($GET(EVENT),1,64)
	IF KEY'="" DO
	. SET ^MIO("MIOMOS","SESSION",SID,"lastEvent")=KEY
	. SET ^MIO("MIOMOS","SESSION",SID,"eventCounts",KEY)=+$GET(^MIO("MIOMOS","SESSION",SID,"eventCounts",KEY))+1
	SET:$DATA(OK) OK=1
	QUIT
	;
LOCK(SID,REASON)
	IF $GET(SID)="" QUIT 0
	SET ^MIO("MIOMOS","SESSION",SID,"locked")=1
	SET ^MIO("MIOMOS","SESSION",SID,"lockReason")=$SELECT($GET(REASON)'="":$GET(REASON),1:"session_locked")
	SET ^MIO("MIOMOS","SESSION",SID,"lockedAt")=$$NOWISO^MIOUTIL()
	DO REGSNAPUPD(SID)
	QUIT 1
	;
UNLOCK(SID)
	IF $GET(SID)="" QUIT 0
	KILL ^MIO("MIOMOS","SESSION",SID,"locked"),^MIO("MIOMOS","SESSION",SID,"lockReason"),^MIO("MIOMOS","SESSION",SID,"lockedAt")
	DO REGSNAPUPD(SID)
	QUIT 1
	;
FORCESIGNOUT(SID,REASON)
	IF $GET(SID)="" QUIT 0
	SET ^MIO("MIOMOS","SESSION",SID,"forcedSignout")=$SELECT($GET(REASON)'="":$GET(REASON),1:"forced_signout")
	SET ^MIO("MIOMOS","SESSION",SID,"forcedSignoutAt")=$$NOWISO^MIOUTIL()
	DO REGSNAPUPD(SID)
	QUIT 1
	;
CLEARFORCE(SID)
	IF $GET(SID)="" QUIT 0
	KILL ^MIO("MIOMOS","SESSION",SID,"forcedSignout"),^MIO("MIOMOS","SESSION",SID,"forcedSignoutAt")
	DO REGSNAPUPD(SID)
	QUIT 1
	;
REGSYNC(SID,KEY,USER,ROLES,STATE,CONF)
	IF $GET(SID)="" QUIT
	IF +$GET(CONF("miomos","security","sessionRegistryEnabled"),1)'=1 QUIT
	SET ^MIO("MIOMOS","SESSION","REG",SID,"sessionId")=$GET(SID)
	SET ^MIO("MIOMOS","SESSION","REG",SID,"principal")=$GET(KEY)
	SET ^MIO("MIOMOS","SESSION","REG",SID,"userName")=$GET(USER)
	SET ^MIO("MIOMOS","SESSION","REG",SID,"roles")=$GET(ROLES)
	SET ^MIO("MIOMOS","SESSION","REG",SID,"profile")=$GET(STATE("profile"))
	SET ^MIO("MIOMOS","SESSION","REG",SID,"lastSeenAt")=$$NOWISO^MIOUTIL()
	SET ^MIO("MIOMOS","SESSION","REG",SID,"lastEvent")=$GET(^MIO("MIOMOS","SESSION",SID,"lastEvent"))
	SET ^MIO("MIOMOS","SESSION","REG",SID,"locked")=+$GET(^MIO("MIOMOS","SESSION",SID,"locked"))
	SET ^MIO("MIOMOS","SESSION","REG",SID,"lockReason")=$GET(^MIO("MIOMOS","SESSION",SID,"lockReason"))
	SET ^MIO("MIOMOS","SESSION","REG",SID,"forcedSignout")=$GET(^MIO("MIOMOS","SESSION",SID,"forcedSignout"))
	QUIT
	;
REGSNAPUPD(SID)
	IF $GET(SID)="" QUIT
	IF '$DATA(^MIO("MIOMOS","SESSION","REG",SID)) QUIT
	SET ^MIO("MIOMOS","SESSION","REG",SID,"lastSeenAt")=$$NOWISO^MIOUTIL()
	SET ^MIO("MIOMOS","SESSION","REG",SID,"locked")=+$GET(^MIO("MIOMOS","SESSION",SID,"locked"))
	SET ^MIO("MIOMOS","SESSION","REG",SID,"lockReason")=$GET(^MIO("MIOMOS","SESSION",SID,"lockReason"))
	SET ^MIO("MIOMOS","SESSION","REG",SID,"forcedSignout")=$GET(^MIO("MIOMOS","SESSION",SID,"forcedSignout"))
	QUIT
	;
REGSNAP(SID,OUT)
	KILL OUT
	IF $GET(SID)="" QUIT
	SET OUT("sessionId")=$GET(^MIO("MIOMOS","SESSION","REG",SID,"sessionId"))
	SET OUT("principal")=$GET(^MIO("MIOMOS","SESSION","REG",SID,"principal"))
	SET OUT("userName")=$GET(^MIO("MIOMOS","SESSION","REG",SID,"userName"))
	SET OUT("profile")=$GET(^MIO("MIOMOS","SESSION","REG",SID,"profile"))
	SET OUT("lastSeenAt")=$GET(^MIO("MIOMOS","SESSION","REG",SID,"lastSeenAt"))
	SET OUT("locked")=+$GET(^MIO("MIOMOS","SESSION","REG",SID,"locked"))
	SET OUT("lockReason")=$GET(^MIO("MIOMOS","SESSION","REG",SID,"lockReason"))
	SET OUT("forcedSignout")=$GET(^MIO("MIOMOS","SESSION","REG",SID,"forcedSignout"))
	QUIT
	;
SNAPSHOT(SID,OUT)
		DO SNAPCORE(SID,.OUT)
		QUIT
		;
SNAPOK(SID,OUT)
		DO SNAPCORE(SID,.OUT)
		QUIT +$GET(OUT("ok"))
		;
SNAPCORE(SID,OUT)
		NEW NOWD,NOWS
		KILL OUT
		SET OUT("ok")=0
		IF $GET(SID)="" QUIT
		IF '$DATA(^MIO("MIOMOS","SESSION",SID,"principal")) QUIT
		SET NOWD=+$PIECE($HOROLOG,",",1),NOWS=+$PIECE($HOROLOG,",",2)
		SET OUT("id")=SID
		SET OUT("principal")=$GET(^MIO("MIOMOS","SESSION",SID,"principal"))
		SET OUT("userName")=$GET(^MIO("MIOMOS","SESSION",SID,"userName"))
		SET OUT("roles")=$GET(^MIO("MIOMOS","SESSION",SID,"roles"))
		SET OUT("startedAt")=$GET(^MIO("MIOMOS","SESSION",SID,"startedAt"))
		SET OUT("lastSeenAt")=$GET(^MIO("MIOMOS","SESSION",SID,"lastSeenAt"))
		SET OUT("lastEvent")=$GET(^MIO("MIOMOS","SESSION",SID,"lastEvent"))
		SET OUT("layoutSavedAt")=$GET(^MIO("MIOMOS","SESSION",SID,"layoutSavedAt"))
		SET OUT("uiSavedAt")=$GET(^MIO("MIOMOS","SESSION",SID,"uiSavedAt"))
		SET OUT("hasLayout")=$SELECT($GET(^MIO("MIOMOS","SESSION",SID,"layoutJson"))'="":1,1:0)
		SET OUT("ageSeconds")=$$AGESEC(+$GET(^MIO("MIOMOS","SESSION",SID,"startedDay")),+$GET(^MIO("MIOMOS","SESSION",SID,"startedSec")),NOWD,NOWS)
		SET OUT("idleSeconds")=$$AGESEC(+$GET(^MIO("MIOMOS","SESSION",SID,"lastDay")),+$GET(^MIO("MIOMOS","SESSION",SID,"lastSec")),NOWD,NOWS)
		NEW UISTATE DO LOADUI(SID,.UISTATE) MERGE OUT("ui")=UISTATE
		MERGE OUT("eventCounts")=^MIO("MIOMOS","SESSION",SID,"eventCounts")
		SET OUT("ok")=1
		QUIT
	;