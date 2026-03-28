MIOMOSVM ; MIOMOS server-driven view model
	QUIT
	;
BUILD(STATE,CONF,OUT)
	KILL OUT
	DO WORKSPACE(.STATE,.CONF,$NAME(OUT("workspace")))
	DO SECURITY(.STATE,.CONF,$NAME(OUT("security")))
	DO ADMIN(.STATE,.CONF,$NAME(OUT("admin")))
	DO SETTINGS(.STATE,.CONF,$NAME(OUT("settings")))
	DO CHAT(.STATE,.CONF,$NAME(OUT("chat")))
	DO TERMINAL(.STATE,.CONF,$NAME(OUT("terminal")))
	DO SESSION(.STATE,.CONF,$NAME(OUT("session")))
	DO UX(.STATE,.CONF,$NAME(OUT("ux")))
	DO WINDOWS(.STATE,.CONF,$NAME(OUT("windowManager")))
	QUIT
	;
WORKSPACE(STATE,CONF,ROOT)
	NEW CNT,PERMS,N
	KILL @ROOT
	DO COUNTS^MIOMOSOBS(.CNT)
	DO LIST^MIOMOSPERM($GET(STATE("roles")),.PERMS)
	SET @ROOT@("headline")="Production workspace"
	SET @ROOT@("subheadline")="MUMPS-first desktop with server-authored state, routes, settings, operational summaries, and session-backed shell restore."
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
	SET @ROOT@(4,"title")="PIPE terminal bridge",@ROOT@(4,"copy")="The browser renders xterm.js while MUMPS launches and supervises a child YottaDB session over PIPE devices and websockets."
	SET @ROOT@(5,"title")="Session-backed shell restore",@ROOT@(5,"copy")="Active window, menu posture, layout mode, and last command are now persisted in MUMPS as part of the desktop session contract."
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
CHAT(STATE,CONF,ROOT)
	KILL @ROOT
	SET @ROOT@("enabled")=+$GET(STATE("chatEnabled"))
	SET @ROOT@("room")=$GET(STATE("chatRoom"),"general")
	SET @ROOT@("limit")=+$GET(STATE("chatLimit"),20)
	QUIT
	;
TERMINAL(STATE,CONF,ROOT)
	KILL @ROOT
	MERGE @ROOT@("profile")=STATE("terminal")
	SET @ROOT@("status")="Terminal idle"
	SET @ROOT@("enabled")=+$GET(CONF("miomos","terminal","enabled"),1)
	SET @ROOT@("transport")="pipe"
	SET @ROOT@("command")=$GET(CONF("miomos","terminal","pipe","command"),"yottadb")
	SET @ROOT@("shell")=$GET(CONF("miomos","terminal","pipe","shell"),"/bin/sh")
	SET @ROOT@("bridge")="mumps-owned"
	QUIT

	;
WINDOWS(STATE,CONF,ROOT)
	KILL @ROOT
	SET @ROOT@("windowPreset")=$GET(STATE("windowPreset"),"analyst")
	SET @ROOT@("snapMode")=$GET(STATE("snapMode"),"quadrant")
	SET @ROOT@("motionProfile")=$GET(STATE("motionProfile"),"standard")
	SET @ROOT@("titlebarStyle")=$GET(STATE("titlebarStyle"),"accent")
	DO CATALOG^MIOMOSWM($NAME(@ROOT@("catalog")))
	QUIT

SESSION(STATE,CONF,ROOT)
	NEW SNAP
	KILL @ROOT
	DO SNAPSHOT^MIOMOSST($GET(STATE("sessionId")),.SNAP)
	SET @ROOT@("headline")="Server-owned session posture"
	SET @ROOT@("subheadline")="Idle timers, layout restore, active window, and shell chrome are persisted in MUMPS and emitted back into the SSR desktop."
	SET @ROOT@("summary","id")=$GET(SNAP("id"),$GET(STATE("sessionId")))
	SET @ROOT@("summary","startedAt")=$GET(SNAP("startedAt"),$GET(STATE("startedAt")))
	SET @ROOT@("summary","lastSeenAt")=$GET(SNAP("lastSeenAt"),$GET(STATE("lastSeenAt")))
	SET @ROOT@("summary","lastEvent")=$GET(SNAP("lastEvent"),"desktop_render")
	SET @ROOT@("summary","ageSeconds")=+$GET(SNAP("ageSeconds"))
	SET @ROOT@("summary","idleSeconds")=+$GET(SNAP("idleSeconds"))
	SET @ROOT@("summary","layoutSavedAt")=$GET(SNAP("layoutSavedAt"))
	SET @ROOT@("summary","uiSavedAt")=$GET(SNAP("uiSavedAt"))
	SET @ROOT@("summary","menuOpen")=+$GET(SNAP("ui","menuOpen"))
	SET @ROOT@("summary","activeWindowId")=$GET(SNAP("ui","activeWindowId"))
	SET @ROOT@("summary","focusedAppKey")=$GET(SNAP("ui","focusedAppKey"))
	SET @ROOT@("summary","layoutMode")=$GET(SNAP("ui","layoutMode"))
	SET @ROOT@("summary","lastCommandName")=$GET(SNAP("ui","lastCommandName"))
	SET @ROOT@("summary","hasLayout")=+$GET(SNAP("hasLayout"))
	SET @ROOT@("summary","heartbeatCount")=+$GET(SNAP("eventCounts","heartbeat"))
	SET @ROOT@("summary","viewRefreshCount")=+$GET(SNAP("eventCounts","view.refresh"))
	SET @ROOT@("summary","uiSaveCount")=+$GET(SNAP("eventCounts","ui_state_save"))
	QUIT
	;
UX(STATE,CONF,ROOT)
	KILL @ROOT
	SET @ROOT@("headline")="UI contract hardening"
	SET @ROOT@("subheadline")="Buttons, forms, tabs, pills, tables, and shell shortcuts now follow one production-facing render contract that can be tested by tokens."
	SET @ROOT@("tabs",1,"label")="Overview",@ROOT@("tabs",1,"active")=1
	SET @ROOT@("tabs",2,"label")="Forms",@ROOT@("tabs",2,"active")=0
	SET @ROOT@("tabs",3,"label")="Tables",@ROOT@("tabs",3,"active")=0
	SET @ROOT@("buttons",1,"label")="Primary action",@ROOT@("buttons",1,"kind")="primary"
	SET @ROOT@("buttons",2,"label")="Secondary action",@ROOT@("buttons",2,"kind")="secondary"
	SET @ROOT@("buttons",3,"label")="Quiet action",@ROOT@("buttons",3,"kind")="quiet"
	SET @ROOT@("states",1,"label")="Ready",@ROOT@("states",1,"kind")="ok"
	SET @ROOT@("states",2,"label")="Review",@ROOT@("states",2,"kind")="warn"
	SET @ROOT@("states",3,"label")="Protected",@ROOT@("states",3,"kind")="neutral"
	SET @ROOT@("form","title")="Profile and permission workflow"
	SET @ROOT@("form","copy")="Use explicit labels, compact spacing, inline help, and visible validation language for all privileged workflows."
	SET @ROOT@("form","fields",1,"label")="Display name",@ROOT@("form","fields",1,"value")=$GET(STATE("userName"))
	SET @ROOT@("form","fields",2,"label")="Role bundle",@ROOT@("form","fields",2,"value")=$GET(STATE("roles"))
	SET @ROOT@("form","fields",3,"label")="Session identifier",@ROOT@("form","fields",3,"value")=$GET(STATE("sessionId"))
	SET @ROOT@("table",1,"surface")="Buttons and pills",@ROOT@("table",1,"status")="Ready",@ROOT@("table",1,"detail")="Consistent sizing, focus, density, and badge styling."
	SET @ROOT@("table",2,"surface")="Forms and validation",@ROOT@("table",2,"status")="Ready",@ROOT@("table",2,"detail")="Inline labels, helper copy, and compact field grouping."
	SET @ROOT@("table",3,"surface")="Session restore",@ROOT@("table",3,"status")="Ready",@ROOT@("table",3,"detail")="Menu posture, active window, layout mode, and restore timestamps persisted in MUMPS."
	SET @ROOT@("table",4,"surface")="Admin tables",@ROOT@("table",4,"status")="Ready",@ROOT@("table",4,"detail")="Clear action columns and state badges for identity operations."
	SET @ROOT@("shortcuts",1,"label")="Open menu",@ROOT@("shortcuts",1,"keys")="Alt+M"
	SET @ROOT@("shortcuts",2,"label")="Tile windows",@ROOT@("shortcuts",2,"keys")="Alt+G"
	SET @ROOT@("shortcuts",3,"label")="Focus terminal",@ROOT@("shortcuts",3,"keys")="Alt+T"
	QUIT
