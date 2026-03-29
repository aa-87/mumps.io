MIOMOSVM ; MIOMOS server-driven view model
	QUIT
	;
BUILD(STATE,CONF,OUT)
	KILL OUT
	DO WORKSPACE(.STATE,.CONF,$NAME(OUT("workspace")))
	DO SECURITY(.STATE,.CONF,$NAME(OUT("security")))
	DO ADMIN(.STATE,.CONF,$NAME(OUT("admin")))
	DO SETTINGS(.STATE,.CONF,$NAME(OUT("settings")))
	DO UILIB(.STATE,.CONF,$NAME(OUT("uiLibrary")))
	DO CHAT(.STATE,.CONF,$NAME(OUT("chat")))
	DO TERMINAL(.STATE,.CONF,$NAME(OUT("terminal")))
	DO WINDOWS(.STATE,.CONF,$NAME(OUT("windowManager")))
	DO NOTIFICATIONS(.STATE,.CONF,$NAME(OUT("notifications")))
	DO SHELL(.STATE,.CONF,$NAME(OUT("shellChrome")))
	QUIT
	;
WORKSPACE(STATE,CONF,ROOT)
	NEW CNT,PERMS,N
	KILL @ROOT
	DO COUNTS^MIOMOSOBS(.CNT)
	DO LIST^MIOMOSPERM($GET(STATE("roles")),.PERMS)
	SET @ROOT@("headline")="Production workspace"
	SET @ROOT@("subheadline")="MUMPS-first desktop with a native Vue/CSS window manager, server-authored state, routes, settings, and operational summaries."
	SET @ROOT@("kpis",1,"label")="Access events"
	SET @ROOT@("kpis",1,"value")=+$GET(CNT("access"))
	SET @ROOT@("kpis",1,"copy")="Recent authenticated desktop actions."
	SET @ROOT@("kpis",2,"label")="Error events"
	SET @ROOT@("kpis",2,"value")=+$GET(CNT("error"))
	SET @ROOT@("kpis",2,"copy")="Observed application and route failures."
	SET @ROOT@("kpis",3,"label")="Audit events"
	SET @ROOT@("kpis",3,"value")=+$GET(CNT("audit"))
	SET @ROOT@("kpis",3,"copy")="Security-significant activity captured in MUMPS."
	SET @ROOT@("kpis",4,"label")="Effective permissions"
	SET N=0 F  S N=$O(PERMS(N)) Q:N=""  S @ROOT@("kpis",4,"value")=+$G(@ROOT@("kpis",4,"value"))+1
	SET @ROOT@("kpis",4,"copy")="Permissions resolved from current roles."
	DO BATCHES($NAME(@ROOT@("batches")))
	DO NOTES($NAME(@ROOT@("notes")))
	QUIT
	;
BATCHES(ROOT)
	KILL @ROOT
	SET @ROOT@(1,"batch")="837P-24081",@ROOT@(1,"payer")="Blue Cross",@ROOT@(1,"profile")="Colorado 837P",@ROOT@(1,"status")="Validated",@ROOT@(1,"owner")="Farah",@ROOT@(1,"age")="03m"
	SET @ROOT@(2,"batch")="837I-91842",@ROOT@(2,"payer")="Aetna",@ROOT@(2,"profile")="Facility Inpatient",@ROOT@(2,"status")="Mapped",@ROOT@(2,"owner")="Ahmed",@ROOT@(2,"age")="07m"
	SET @ROOT@(3,"batch")="837D-10118",@ROOT@(3,"payer")="Delta Dental",@ROOT@(3,"profile")="Dental Batch",@ROOT@(3,"status")="Exception",@ROOT@(3,"owner")="Sara",@ROOT@(3,"age")="12m"
	SET @ROOT@(4,"batch")="837P-24093",@ROOT@(4,"payer")="Cigna",@ROOT@(4,"profile")="Workers Comp",@ROOT@(4,"status")="Exporting",@ROOT@(4,"owner")="Joel",@ROOT@(4,"age")="16m"
	SET @ROOT@(5,"batch")="837P-24102",@ROOT@(5,"payer")="Humana",@ROOT@(5,"profile")="Medicare Pro",@ROOT@(5,"status")="Ready",@ROOT@(5,"owner")="Mina",@ROOT@(5,"age")="21m"
	QUIT
	;
NOTES(ROOT)
	KILL @ROOT
	SET @ROOT@(1,"title")="MUMPS-first render contract",@ROOT@(1,"copy")="Apps, windows, settings, permissions, and summaries are authored in MUMPS and emitted as JSON to the thin Vue layer."
	SET @ROOT@(2,"title")="Server-authored settings",@ROOT@(2,"copy")="Theme, typography, density, wallpaper, icons, and terminal profile are persisted server-side in MUMPS globals."
	SET @ROOT@(3,"title")="Operational exports",@ROOT@(3,"copy")="Access, error, audit, digest, and retention posture remain server-managed and permission-controlled."
	SET @ROOT@(4,"title")="Native window manager foundation",@ROOT@(4,"copy")="The browser now uses a MIOMOS-native Vue/CSS window manager with server-backed layout, focus, and UI state."
	SET @ROOT@(5,"title")="Websocket shell bus",@ROOT@(5,"copy")="Shell commands, layout saves, settings, and terminal actions all ride the single MIOMOS websocket while MUMPS remains the source of truth."
	QUIT
	;
SECURITY(STATE,CONF,ROOT)
	NEW OBS,PERMS,N
	KILL @ROOT
	DO SUMMARY^MIOMOSOBS(.STATE,.CONF,.OBS)
	SET @ROOT@("metrics",1,"label")="Access",@ROOT@("metrics",1,"value")=+$GET(OBS("counts","access"))
	SET @ROOT@("metrics",2,"label")="Errors",@ROOT@("metrics",2,"value")=+$GET(OBS("counts","error"))
	SET @ROOT@("metrics",3,"label")="Audit",@ROOT@("metrics",3,"value")=+$GET(OBS("counts","audit"))
	MERGE @ROOT@("retention")=OBS("retention")
	SET @ROOT@("lastAccess","event")=$GET(OBS("lastAccess","event"))
	SET @ROOT@("lastAccess","correlationId")=$GET(OBS("lastAccess","correlationId"))
	SET @ROOT@("lastError","event")=$GET(OBS("lastError","event"))
	SET @ROOT@("lastError","correlationId")=$GET(OBS("lastError","correlationId"))
	SET @ROOT@("lastAudit","event")=$GET(OBS("lastAudit","event"))
	SET @ROOT@("lastAudit","correlationId")=$GET(OBS("lastAudit","correlationId"))
	DO LIST^MIOMOSPERM($GET(STATE("roles")),.PERMS)
	SET N=0 F  S N=$O(PERMS(N)) Q:N=""  MERGE @ROOT@("permissions",N)=PERMS(N)
	QUIT
	;
ADMIN(STATE,CONF,ROOT)
	NEW CNT,USR,INV,RST,N
	KILL @ROOT
	DO COUNTS^MIOMOSADMIN(.CNT)
	MERGE @ROOT@("counts")=CNT
	DO USERLIST^MIOMOSADMIN(8,.USR)
	SET N=0 F  S N=$O(USR(N)) Q:N=""  MERGE @ROOT@("users",N)=USR(N)
	DO INVITELIST^MIOMOSADMIN(6,.INV)
	SET N=0 F  S N=$O(INV(N)) Q:N=""  MERGE @ROOT@("invites",N)=INV(N)
	DO RESETLIST^MIOMOSADMIN(6,.RST)
	SET N=0 F  S N=$O(RST(N)) Q:N=""  MERGE @ROOT@("resets",N)=RST(N)
	QUIT
	;
SETTINGS(STATE,CONF,ROOT)
	NEW CUR
	KILL @ROOT
	DO CURRENT^MIOMOSSET($GET(STATE("principal")),.CUR)
	MERGE @ROOT@("current")=CUR("current")
	MERGE @ROOT@("catalog")=CUR("catalog")
	SET @ROOT@("contract")="server-authored"
	QUIT
	;
UILIB(STATE,CONF,ROOT)
	NEW THEMES
	KILL @ROOT
	SET @ROOT@("headline")="UI Library and component contract"
	SET @ROOT@("subheadline")="7.css-influenced foundations refined with MIOMOS-native shell chrome, WinXP-inspired taskbar and Start menu structure, clinical readability, and mobile-aware behavior."
	SET @ROOT@("overview",1,"label")="Buttons"
	SET @ROOT@("overview",1,"value")=6
	SET @ROOT@("overview",1,"copy")="Primary, subtle, quiet, destructive, and toolbar actions."
	SET @ROOT@("overview",2,"label")="Form controls"
	SET @ROOT@("overview",2,"value")=8
	SET @ROOT@("overview",2,"copy")="Inputs, selects, textareas, toggles, validation, and helper copy."
	SET @ROOT@("overview",3,"label")="Data patterns"
	SET @ROOT@("overview",3,"value")=5
	SET @ROOT@("overview",3,"copy")="Tables, badges, segmented tabs, drawers, command palette rows, and shell chrome surfaces."
	SET @ROOT@("overview",4,"label")="Theme packs"
	SET @ROOT@("overview",4,"value")=0
	SET @ROOT@("overview",4,"copy")="7.css-inspired window chrome with MIOMOS modern contrast tuning, XP taskbar cues, and tray/dialog patterns."
	SET @ROOT@("overview",5,"label")="Mobile-ready patterns"
	SET @ROOT@("overview",5,"value")=4
	SET @ROOT@("overview",5,"copy")="Stacked shell, touch targets, and small-screen workspace behavior."
	SET @ROOT@("buttons",1,"label")="Primary action"
	SET @ROOT@("buttons",1,"tone")="primary"
	SET @ROOT@("buttons",1,"copy")="Use for one strong commit action per surface."
	SET @ROOT@("buttons",2,"label")="Secondary action"
	SET @ROOT@("buttons",2,"tone")="secondary"
	SET @ROOT@("buttons",2,"copy")="Use for adjacent non-destructive actions."
	SET @ROOT@("buttons",3,"label")="Quiet action"
	SET @ROOT@("buttons",3,"tone")="quiet"
	SET @ROOT@("buttons",3,"copy")="Use inside dense toolbars and command bars."
	SET @ROOT@("buttons",4,"label")="Destructive action"
	SET @ROOT@("buttons",4,"tone")="danger"
	SET @ROOT@("buttons",4,"copy")="Reserve for high intent actions only."
	SET @ROOT@("tabs",1,"label")="Overview"
	SET @ROOT@("tabs",1,"state")="active"
	SET @ROOT@("tabs",2,"label")="Forms"
	SET @ROOT@("tabs",3,"label")="Tables"
	SET @ROOT@("tabs",4,"label")="Overlays"
	SET @ROOT@("fields",1,"label")="Patient batch search"
	SET @ROOT@("fields",1,"value")="Search by batch, payer, or profile"
	SET @ROOT@("fields",1,"help")="Compact search field for command bars and filter rails."
	SET @ROOT@("fields",1,"state")="default"
	SET @ROOT@("fields",2,"label")="Workspace density"
	SET @ROOT@("fields",2,"value")=$GET(STATE("density"),"dense")
	SET @ROOT@("fields",2,"help")="Server-authored preference with live shell impact."
	SET @ROOT@("fields",2,"state")="default"
	SET @ROOT@("fields",3,"label")="Invite email"
	SET @ROOT@("fields",3,"value")="operator@clinic.local"
	SET @ROOT@("fields",3,"help")="Example validation and helper text pattern."
	SET @ROOT@("fields",3,"state")="success"
	SET @ROOT@("fields",4,"label")="Security digest cadence"
	SET @ROOT@("fields",4,"value")="Daily at 06:00"
	SET @ROOT@("fields",4,"help")="Surface non-editable operational values with quiet emphasis."
	SET @ROOT@("fields",4,"state")="readonly"
	SET @ROOT@("statusPills",1,"label")="Healthy"
	SET @ROOT@("statusPills",1,"tone")="ok"
	SET @ROOT@("statusPills",2,"label")="Review"
	SET @ROOT@("statusPills",2,"tone")="warn"
	SET @ROOT@("statusPills",3,"label")="Locked"
	SET @ROOT@("statusPills",3,"tone")="danger"
	SET @ROOT@("statusPills",4,"label")="Info"
	SET @ROOT@("statusPills",4,"tone")="info"
	SET @ROOT@("tableRows",1,"name")="Blue Cross 837P"
	SET @ROOT@("tableRows",1,"owner")="Farah"
	SET @ROOT@("tableRows",1,"status")="Ready"
	SET @ROOT@("tableRows",1,"eta")="02m"
	SET @ROOT@("tableRows",2,"name")="Aetna Inpatient"
	SET @ROOT@("tableRows",2,"owner")="Ahmed"
	SET @ROOT@("tableRows",2,"status")="Mapped"
	SET @ROOT@("tableRows",2,"eta")="05m"
	SET @ROOT@("tableRows",3,"name")="Dental Review"
	SET @ROOT@("tableRows",3,"owner")="Sara"
	SET @ROOT@("tableRows",3,"status")="Exception"
	SET @ROOT@("tableRows",3,"eta")="Needs analyst"
	SET @ROOT@("commands",1,"title")="Open command palette"
	SET @ROOT@("commands",1,"shortcut")="Alt+M"
	SET @ROOT@("commands",1,"copy")="Global launcher and command routing pattern."
	SET @ROOT@("commands",2,"title")="Tile the workspace"
	SET @ROOT@("commands",2,"shortcut")="Alt+G"
	SET @ROOT@("commands",2,"copy")="Window tool pattern for dense review sessions."
	SET @ROOT@("commands",3,"title")="Focus terminal"
	SET @ROOT@("commands",3,"shortcut")="Alt+T"
	SET @ROOT@("commands",3,"copy")="Operational jump action for MUMPS power users."
	SET @ROOT@("tokens",1,"label")="Corner radius"
	SET @ROOT@("tokens",1,"value")="14 / 16 / 18 px"
	SET @ROOT@("tokens",2,"label")="Shadow stack"
	SET @ROOT@("tokens",2,"value")="Soft glass + active focus"
	SET @ROOT@("tokens",3,"label")="Focus ring"
	SET @ROOT@("tokens",3,"value")="Accent outline with 2px offset"
	SET @ROOT@("shellPatterns",1,"title")="Quick Launch rail"
	SET @ROOT@("shellPatterns",1,"copy")="Compact pinned launchers with XP-like separators and tray balance."
	SET @ROOT@("shellPatterns",2,"title")="Shell dialogs"
	SET @ROOT@("shellPatterns",2,"copy")="Run, About, and Turn Off Computer dialogs share one consistent shell contract."
	SET @ROOT@("shellPatterns",3,"title")="Notification area"
	SET @ROOT@("shellPatterns",3,"copy")="Status chips, live clock, and taskbar-side actions stay readable on light shells."
	SET @ROOT@("shellPatterns",4,"title")="Stable taskbar order"
	SET @ROOT@("shellPatterns",4,"copy")="Task buttons keep their slot while focus changes so the strip behaves like a real desktop instead of reshuffling on every click."
	SET @ROOT@("tokens",4,"label")="Density scale"
	SET @ROOT@("tokens",4,"value")="compact / dense / comfortable"
	SET @ROOT@("tokens",5,"label")="Touch target"
	SET @ROOT@("tokens",5,"value")="44 px minimum on compact screens"
	SET @ROOT@("lightChecks",1,"title")="Dark-enough body text"
	SET @ROOT@("lightChecks",1,"copy")="Light themes keep body copy, pills, and table text in a deep slate range instead of washed-out gray."
	SET @ROOT@("lightChecks",2,"title")="Action chrome stays visible"
	SET @ROOT@("lightChecks",2,"copy")="Top bar, taskbar, and window frames retain contrast even when the desktop theme switches to light mode."
	SET @ROOT@("lightChecks",3,"title")="High Contrast Light is available"
	SET @ROOT@("lightChecks",3,"copy")="Accessibility-sensitive operators can choose a bright shell with strong outlines and assertive text values."
	;	
	SET @ROOT@("shellChrome",1,"title")="WinXP-inspired shell chrome"
	SET @ROOT@("shellChrome",1,"copy")="Taskbar, Start menu, and context menus use XP-like gradients, highlights, and tray patterns without abandoning MIOMOS ownership of state and permissions."
	SET @ROOT@("shellChrome",2,"title")="Professional not nostalgic"
	SET @ROOT@("shellChrome",2,"copy")="The chrome borrows recognizable XP structure while keeping healthcare-friendly spacing, cleaner typography, and calmer content density."
	SET @ROOT@("shellChrome",3,"title")="Context actions stay focused"
	SET @ROOT@("shellChrome",3,"copy")="Right-click menus expose only a small, predictable set of launch and window actions rather than a crowded desktop imitation."
	SET @ROOT@("shellChrome",4,"title")="Start menu sections stay predictable"
	SET @ROOT@("shellChrome",4,"copy")="Programs, pinned entries, directories, and system actions keep a consistent order so operators build muscle memory."
	SET @ROOT@("responsive",1,"title")="Stacked shell under 900 px"
	SET @ROOT@("responsive",1,"copy")="Windows render as a single-column flow, drag handles are suppressed, and the launcher becomes a mobile-friendly sheet."
	SET @ROOT@("responsive",2,"title")="Touch-safe controls"
	SET @ROOT@("responsive",2,"copy")="Task buttons, menu actions, and shell controls keep comfortable spacing for smaller touch devices."
	SET @ROOT@("responsive",3,"title")="Desktop still remains server-authored"
	SET @ROOT@("responsive",3,"copy")="The browser only changes layout strategy. Window/app metadata, routes, and session state continue to come from MUMPS."
	SET @ROOT@("responsive",4,"title")="Terminal stays secondary on handheld"
	SET @ROOT@("responsive",4,"copy")="The shell prepares for mobile by favoring workspace and UI surfaces first while keeping the terminal available when needed."
	SET @ROOT@("nativeWindowManager",1,"title")="Native Vue/CSS shell"
	SET @ROOT@("nativeWindowManager",1,"copy")="No OS.js runtime bridge is required. Windows are managed by MIOMOS Vue state, CSS chrome, and MUMPS-authored metadata."
	SET @ROOT@("nativeWindowManager",2,"title")="Server-backed UI state"
	SET @ROOT@("nativeWindowManager",2,"copy")="Active window, launcher state, layout mode, and focused surface persist back through the MIOMOS websocket command bus."
	SET @ROOT@("nativeWindowManager",3,"title")="Mobile-friendly windowing"
	SET @ROOT@("nativeWindowManager",3,"copy")="Compact viewports switch to a stacked shell without changing the MUMPS-authored desktop contract."
	DO CATALOG^MIOMOSTH($NAME(THEMES))
	NEW N,M SET N=0,M=0
	FOR  SET N=$ORDER(THEMES(N)) QUIT:N=""  DO
	. SET M=M+1
	. MERGE @ROOT@("themes",M)=THEMES(N)
	. SET @ROOT@("themes",M,"isCurrent")=$SELECT($GET(THEMES(N,"key"))=$GET(STATE("themeKey")):1,1:0)
	SET @ROOT@("overview",4,"value")=M
	QUIT
	;
NOTIFICATIONS(STATE,CONF,ROOT)
	NEW TMP
	KILL @ROOT,TMP
	DO META^MIOMOSNOTE(.STATE,.CONF,.TMP)
	MERGE @ROOT=TMP
	QUIT
	;
SHELL(STATE,CONF,ROOT)
	KILL @ROOT
	SET @ROOT@("headline")="Product shell correctness and desktop folders"
	SET @ROOT@("taskbarBehavior")="stable-order"
	SET @ROOT@("taskbarOverflowBehavior")="preserve-order-and-overflow"
	SET @ROOT@("startMenuBehavior")="predictable-sections"
	SET @ROOT@("startSearchBehavior")="filter-programs-and-actions"
	SET @ROOT@("taskbarClickPolicy")="xp-toggle"
	SET @ROOT@("shellSurfacePolicy")="single-open-surface"
	SET @ROOT@("contextMenuStatefulness")="window-aware"
	SET @ROOT@("startMenuSectionMemory")="server-backed"
	SET @ROOT@("keyboardModel")="ctrl-escape-enter-search"
	SET @ROOT@("dialogDragBehavior")="titlebar-drag"
	SET @ROOT@("folderCreateBehavior")="desktop-context-menu"
	SET @ROOT@("desktopComposition")="ui-samples-settings-terminal"
	SET @ROOT@("mutationSaveBehavior")="layout-on-shell-mutation"
	SET @ROOT@("taskbarBehaviorCopy")="Taskbar order stays stable while focus changes."
	SET @ROOT@("taskbarOverflowCopy")="Overflow windows move into a More Windows list without changing taskbar order."
	SET @ROOT@("startMenuBehaviorCopy")="Start menu sections stay pinned and predictable."
	SET @ROOT@("startSearchBehaviorCopy")="Start search filters programs, actions, and directories from one field."
	SET @ROOT@("taskbarClickPolicyCopy")="Clicking a task button toggles minimize or restore without shuffling neighboring items."
	SET @ROOT@("shellSurfacePolicyCopy")="Only one shell surface stays open at a time: Start menu, context menu, or dialog."
	SET @ROOT@("dialogDragBehaviorCopy")="Shell dialogs can be dragged by their title bars like real desktop dialogs."
	SET @ROOT@("folderCreateBehaviorCopy")="New Folder is available from the desktop context menu and saves immediately."
	SET @ROOT@("desktopCompositionCopy")="The desktop now stays curated: UI Samples, Settings, and Terminal."
	SET @ROOT@("quickLaunchLabel")="Quick Launch"
	SET @ROOT@("overflowLabel")="More Windows"
	SET @ROOT@("recentLabel")="Recently used"
	SET @ROOT@("searchPlaceholder")="Search programs and shell actions"
	SET @ROOT@("taskbarStyle")="xp-plus-tray"
	SET @ROOT@("startMenuStyle")="winxp-dual-pane"
	SET @ROOT@("trayStyle")="xp-notify-area"
	SET @ROOT@("dialogStyle")="xp-shell-classic"
	SET @ROOT@("showClockSeconds")=+$GET(STATE("shell","showClockSeconds"))
	SET @ROOT@("showTrayLabels")=+$GET(STATE("shell","showTrayLabels"))
	SET @ROOT@("showAccountName")=+$GET(STATE("shell","showAccountName"),1)
	SET @ROOT@("showNotificationBadge")=+$GET(STATE("shell","showNotificationBadge"),1)
	SET @ROOT@("notificationPreviewCount")=+$GET(STATE("shell","notificationPreviewCount"),4)
	SET @ROOT@("startMenuSection")=$GET(STATE("shell","startMenuSection"),"Pinned")
	SET @ROOT@("quickLaunch")=$GET(STATE("shell","quickLaunch"),"workspace,collaboration,terminal")
	SET @ROOT@("userMenuStyle")="xp-account-menu"
	SET @ROOT@("accountLabel")=$GET(STATE("userName"),$GET(STATE("principal"),"Operator"))
	SET @ROOT@("accountRoleLabel")=$GET(STATE("roleLabel"),$$ROLELABEL^MIOMOSPERM($GET(STATE("roles"))))
	SET @ROOT@("notificationLabel")="Notifications"
	SET @ROOT@("tray",1,"key")="notifications",@ROOT@("tray",1,"label")="Notifications",@ROOT@("tray",1,"icon")="✦",@ROOT@("tray",1,"action")="notifications"
	SET @ROOT@("tray",2,"key")="account",@ROOT@("tray",2,"label")="Account",@ROOT@("tray",2,"icon")="☺",@ROOT@("tray",2,"action")="account"
	SET @ROOT@("tray",3,"key")="workspace",@ROOT@("tray",3,"label")="Workspace ready",@ROOT@("tray",3,"icon")="✓",@ROOT@("tray",3,"action")="refresh"
	SET @ROOT@("tray",4,"key")="power",@ROOT@("tray",4,"label")="Power options",@ROOT@("tray",4,"icon")="⏻",@ROOT@("tray",4,"action")="power"
	SET @ROOT@("accountMenu",1,"key")="settings",@ROOT@("accountMenu",1,"label")="Settings",@ROOT@("accountMenu",1,"copy")="Open personal desktop preferences.",@ROOT@("accountMenu",1,"action")="launch:settings"
	SET @ROOT@("accountMenu",2,"key")="collaboration",@ROOT@("accountMenu",2,"label")="Collaboration",@ROOT@("accountMenu",2,"copy")="Open the team chat surface.",@ROOT@("accountMenu",2,"action")="launch:collaboration"
	SET @ROOT@("accountMenu",3,"key")="terminal",@ROOT@("accountMenu",3,"label")="Terminal",@ROOT@("accountMenu",3,"copy")="Launch a new YottaDB terminal window.",@ROOT@("accountMenu",3,"action")="launch:terminal"
	SET @ROOT@("accountMenu",4,"key")="switchUser",@ROOT@("accountMenu",4,"label")="Switch User",@ROOT@("accountMenu",4,"copy")="Return to the access screen without closing the server session.",@ROOT@("accountMenu",4,"action")="switch-user"
	SET @ROOT@("accountMenu",5,"key")="signout",@ROOT@("accountMenu",5,"label")="Sign Out",@ROOT@("accountMenu",5,"copy")="End the authenticated desktop session.",@ROOT@("accountMenu",5,"action")="signout"
	SET @ROOT@("accountMenu",6,"key")="power",@ROOT@("accountMenu",6,"label")="Turn Off Computer",@ROOT@("accountMenu",6,"copy")="Open shell power options.",@ROOT@("accountMenu",6,"action")="power"
	IF $$HAS^MIOMOSPERM(.STATE,"admin.users.view")!$$HAS^MIOMOSPERM(.STATE,"admin.users.manage") SET @ROOT@("accountMenu",7,"key")="admin",@ROOT@("accountMenu",7,"label")="Admin Center",@ROOT@("accountMenu",7,"copy")="Open user administration and reports.",@ROOT@("accountMenu",7,"action")="launch:admin"
	SET @ROOT@("recentFallback",1,"key")="ui-samples",@ROOT@("recentFallback",1,"label")="UI Samples"
	SET @ROOT@("recentFallback",2,"key")="terminal",@ROOT@("recentFallback",2,"label")="Terminal"
	SET @ROOT@("recentFallback",3,"key")="settings",@ROOT@("recentFallback",3,"label")="Settings"
	SET @ROOT@("startFooter",1,"key")="run",@ROOT@("startFooter",1,"label")="Run…",@ROOT@("startFooter",1,"copy")="Launch a desktop command or app."
	SET @ROOT@("startFooter",2,"key")="signout",@ROOT@("startFooter",2,"label")="Log Off",@ROOT@("startFooter",2,"copy")="End the authenticated desktop session."
	SET @ROOT@("startFooter",3,"key")="power",@ROOT@("startFooter",3,"label")="Turn Off Computer",@ROOT@("startFooter",3,"copy")="Open the shell power dialog."
	SET @ROOT@("dialogs",1,"key")="run",@ROOT@("dialogs",1,"title")="Run",@ROOT@("dialogs",1,"copy")="Open a MIOMOS app by name, such as workspace, terminal, or settings."
	SET @ROOT@("dialogs",2,"key")="about",@ROOT@("dialogs",2,"title")="About MIOMOS",@ROOT@("dialogs",2,"copy")="WinXP-inspired shell chrome on a native Vue/CSS window manager with MUMPS-owned state."
	SET @ROOT@("dialogs",3,"key")="power",@ROOT@("dialogs",3,"title")="Turn off computer",@ROOT@("dialogs",3,"copy")="Choose whether to log off, restart the shell, or close all windows."
	SET @ROOT@("transportLabel")="WebSocket shell bus"
	SET @ROOT@("transportCopy")="All live shell communication now goes through the primary websocket session."
	QUIT
	;
CHAT(STATE,CONF,ROOT)
	NEW ROOMS,ROSTER
	KILL @ROOT
	SET @ROOT@("enabled")=+$GET(STATE("chatEnabled"))
	SET @ROOT@("room")=$GET(STATE("chatRoom"),"general")
	SET @ROOT@("limit")=+$GET(STATE("chatLimit"),20)
	DO ROOMS^MIOMOSCHAT(.STATE,.ROOMS)
	MERGE @ROOT@("rooms")=ROOMS
	DO ROSTER^MIOMOSCHAT(.STATE,.ROSTER)
	MERGE @ROOT@("roster")=ROSTER
	QUIT
	;
TERMINAL(STATE,CONF,ROOT)
	NEW SESS
	KILL @ROOT
	MERGE @ROOT@("profile")=STATE("terminal")
	SET @ROOT@("status")="Terminal idle"
	SET @ROOT@("enabled")=+$GET(CONF("miomos","terminal","enabled"),1)
	SET @ROOT@("transport")="pipe"
	SET @ROOT@("commandTransport")=$GET(CONF("miomos","desktop","transport","commandBus"),"websocket-only")
	SET @ROOT@("command")=$GET(CONF("miomos","terminal","pipe","command"),"yottadb")
	SET @ROOT@("shell")=$GET(CONF("miomos","terminal","pipe","shell"),"/bin/sh")
	SET @ROOT@("bridge")="mumps-owned"
	SET @ROOT@("launchMode")=$SELECT($GET(STATE("terminalLaunchMode"))'="":$GET(STATE("terminalLaunchMode")),$GET(STATE("shell","terminalLaunchMode"))'="":$GET(STATE("shell","terminalLaunchMode")),1:"resume-last")
	DO LIST^MIOMOSTERM(.STATE,.SESS)
	MERGE @ROOT@("sessions")=SESS
	QUIT
	;
	;
WINDOWS(STATE,CONF,ROOT)
	KILL @ROOT
	SET @ROOT@("windowPreset")=$GET(STATE("windowPreset"),"analyst")
	SET @ROOT@("snapMode")=$GET(STATE("snapMode"),"quadrant")
	SET @ROOT@("motionProfile")=$GET(STATE("motionProfile"),"standard")
	SET @ROOT@("titlebarStyle")=$GET(STATE("titlebarStyle"),"accent")
	SET @ROOT@("engine")="miomos-native-vue-css"
	SET @ROOT@("nativeShell")=1
	SET @ROOT@("serverBackedUiState")=1
	DO CATALOG^MIOMOSWM($NAME(@ROOT@("catalog")))
	QUIT
	;