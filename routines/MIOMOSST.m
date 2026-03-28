MIOMOSST ; MIOMOS state/session helpers
	QUIT
	;
ENSURE(CONF,REQ,CTX,STATE,ERR)
	NEW KEY,SID,NOWD,NOWS,ABS,IDLE,USER,ROLES,STARTD,STARTS,LASTD,LASTS
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
	IF SID'="" DO
	. SET STARTD=+$GET(^MIO("MIOMOS","SESSION",SID,"startedDay"))
	. SET STARTS=+$GET(^MIO("MIOMOS","SESSION",SID,"startedSec"))
	. SET LASTD=+$GET(^MIO("MIOMOS","SESSION",SID,"lastDay"))
	. SET LASTS=+$GET(^MIO("MIOMOS","SESSION",SID,"lastSec"))
	. IF $$AGESEC(STARTD,STARTS,NOWD,NOWS)>ABS SET SID="" QUIT
	. IF $$AGESEC(LASTD,LASTS,NOWD,NOWS)>IDLE SET SID=""
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
	SET STATE("idleTimeoutSeconds")=IDLE
	SET STATE("absoluteTimeoutSeconds")=ABS
	SET STATE("desktopPath")=$GET(CONF("miomos","route","desktop"),"/miomos")
	SET STATE("bootstrapPath")=$GET(CONF("miomos","route","bootstrap"),"/api/miomos/bootstrap")
	SET STATE("wsPath")=$GET(CONF("miomos","route","ws"),"/ws/miomos")
	SET STATE("themePath")=$GET(CONF("miomos","route","theme"),"/api/miomos/theme")
	SET STATE("settingsPath")=$GET(CONF("miomos","route","settings"),"/api/miomos/settings")
	SET STATE("viewPath")=$GET(CONF("miomos","route","view"),"/api/miomos/view")
	SET STATE("commandPath")=$GET(CONF("miomos","route","command"),"/api/miomos/command")
	SET STATE("signinPath")=$GET(CONF("miomos","route","signin"),"/api/miomos/auth/signin")
	SET STATE("signupPath")=$GET(CONF("miomos","route","signup"),"/api/miomos/auth/signup")
	SET STATE("signoutPath")=$GET(CONF("miomos","route","signout"),"/api/miomos/auth/signout")
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
	SET STATE("chatEnabled")=+$GET(CONF("miomos","chat","enabled"),1)
	SET STATE("chatRoom")=$GET(CONF("miomos","chat","defaultRoom"),"general")
	SET STATE("chatLimit")=+$GET(CONF("miomos","chat","messageLimit"),20)
	SET STATE("logMaxEntries")=+$GET(CONF("miomos","log","maxEntries"),500)
	SET STATE("logExportLimit")=+$GET(CONF("miomos","log","exportLimit"),250)
	SET STATE("logDigestTail")=+$GET(CONF("miomos","log","digestTail"),6)
	SET STATE("accessRetainDays")=+$GET(CONF("miomos","log","access","retainDays"),30)
	SET STATE("errorRetainDays")=+$GET(CONF("miomos","log","error","retainDays"),90)
	SET STATE("auditRetainDays")=+$GET(CONF("miomos","audit","retainDays"),180)
	SET STATE("logAccessEnabled")=+$GET(CONF("miomos","log","access","enabled"),1)
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
	SET OBJ("product","version")="roi10-terminal-foundation"
	SET OBJ("product","profile")=$GET(STATE("profile"),"dev")
	SET OBJ("user","id")=$GET(STATE("principal"))
	SET OBJ("user","displayName")=$GET(STATE("userName"))
	DO CSV2ARY($GET(STATE("roles")),$NAME(OBJ("user","roles")))
	SET OBJ("session","id")=$GET(STATE("sessionId"))
	SET OBJ("session","startedAt")=$GET(STATE("startedAt"))
	SET OBJ("session","lastSeenAt")=$GET(STATE("lastSeenAt"))
	SET OBJ("session","idleTimeoutSeconds")=+$GET(STATE("idleTimeoutSeconds"))
	SET OBJ("session","absoluteTimeoutSeconds")=+$GET(STATE("absoluteTimeoutSeconds"))
	SET OBJ("routes","desktop")=$GET(STATE("desktopPath"))
	SET OBJ("routes","bootstrap")=$GET(STATE("bootstrapPath"))
	SET OBJ("routes","websocket")=$GET(STATE("wsPath"))
	SET OBJ("routes","theme")=$GET(STATE("themePath"))
	SET OBJ("routes","settings")=$GET(STATE("settingsPath"))
	SET OBJ("routes","view")=$GET(STATE("viewPath"))
	SET OBJ("routes","command")=$GET(STATE("commandPath"))
	SET OBJ("routes","signin")=$GET(STATE("signinPath"))
	SET OBJ("routes","signup")=$GET(STATE("signupPath"))
	SET OBJ("routes","signout")=$GET(STATE("signoutPath"))
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
	SET OBJ("desktop","launcherLabel")="Menu"
	SET OBJ("desktop","engine")="miomos-osjs-bridge"
	SET OBJ("desktop","windowManagerName")="miomos-lean-production"
	SET OBJ("desktop","savedLayoutJson")=$GET(^MIO("MIOMOS","SESSION",$GET(STATE("sessionId")),"layoutJson"))
	SET OBJ("desktop","contractVersion")="2026-03-roi12"
	SET OBJ("desktop","renderMode")="mumps-first"
	SET OBJ("desktop","renderer")="vue-thin"
	SET OBJ("desktop","motionProfile")=$GET(STATE("motionProfile"))
	SET OBJ("desktop","titlebarStyle")=$GET(STATE("titlebarStyle"))
	SET OBJ("desktop","windowPreset")=$GET(STATE("windowPreset"))
	SET OBJ("desktop","snapMode")=$GET(STATE("snapMode"))
	SET OBJ("desktop","policy","heartbeatMs")=+$GET(CONF("miomos","desktop","policy","heartbeatMs"),15000)
	SET OBJ("desktop","policy","reconnectBaseMs")=+$GET(CONF("miomos","desktop","policy","reconnectBaseMs"),1000)
	SET OBJ("desktop","policy","reconnectMaxMs")=+$GET(CONF("miomos","desktop","policy","reconnectMaxMs"),15000)
	SET OBJ("desktop","policy","staleSocketMs")=+$GET(CONF("miomos","desktop","policy","staleSocketMs"),45000)
	SET OBJ("desktop","policy","commandMaxInflight")=+$GET(CONF("miomos","desktop","policy","commandMaxInflight"),1)
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
	SET OBJ("auth","localEnabled")=+$GET(STATE("localAuthEnabled"))
	SET OBJ("auth","allowSignup")=+$GET(STATE("allowSignup"))
	SET OBJ("auth","inviteOnly")=+$GET(STATE("inviteOnly"))
	SET OBJ("chat","enabled")=+$GET(STATE("chatEnabled"))
	SET OBJ("chat","room")=$GET(STATE("chatRoom"))
	SET OBJ("chat","limit")=+$GET(STATE("chatLimit"),20)
	SET OBJ("terminal","transport")="pipe"
	SET OBJ("terminal","pipeEnabled")=+$GET(STATE("terminalPipeEnabled"),1)
	SET OBJ("terminal","command")=$GET(STATE("terminalPipeCommand"))
	SET OBJ("terminal","shell")=$GET(STATE("terminalPipeShell"))
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
	DO APPS($NAME(OBJ("desktop","apps")),.STATE)
	DO WINS($NAME(OBJ("desktop","windows")),.STATE)
		MERGE OBJ("apps")=OBJ("desktop","apps")
		MERGE OBJ("windows")=OBJ("desktop","windows")
	NEW VIEW
	DO BUILD^MIOMOSVM(.STATE,.CONF,.VIEW)
	MERGE OBJ("view")=VIEW
	QUIT
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
	SET @ROOT@(1,"key")="workspace",@ROOT@(1,"title")="Workspace",@ROOT@(1,"subtitle")="Core queues, review, export, and operational work surfaces",@ROOT@(1,"icon")=$GET(STATE("icon","workspace"),"APP"),@ROOT@(1,"badge")="Primary",@ROOT@(1,"kind")="app",@ROOT@(1,"group")="Pinned",@ROOT@(1,"order")=10,@ROOT@(1,"launchKey")="workspace",@ROOT@(1,"desktopPinned")=1,@ROOT@(1,"status")="available"
	SET @ROOT@(2,"key")="settings",@ROOT@(2,"title")="Settings",@ROOT@(2,"subtitle")="Themes, fonts, density, motion, icons, and preferences",@ROOT@(2,"icon")=$GET(STATE("icon","settings"),"SET"),@ROOT@(2,"badge")="Prefs",@ROOT@(2,"kind")="settings",@ROOT@(2,"group")="Pinned",@ROOT@(2,"order")=20,@ROOT@(2,"launchKey")="settings",@ROOT@(2,"desktopPinned")=1,@ROOT@(2,"status")="available"
	SET @ROOT@(3,"key")="jobs",@ROOT@(3,"title")="Jobs",@ROOT@(3,"subtitle")="Incoming work, queues, and monitored processing directories",@ROOT@(3,"icon")="DIR",@ROOT@(3,"badge")="Folder",@ROOT@(3,"kind")="directory",@ROOT@(3,"group")="Directories",@ROOT@(3,"order")=30,@ROOT@(3,"launchKey")="workspace",@ROOT@(3,"desktopPinned")=1,@ROOT@(3,"status")="available",@ROOT@(3,"summary")="142 active items"
	SET @ROOT@(4,"key")="exports",@ROOT@(4,"title")="Exports",@ROOT@(4,"subtitle")="Output artifacts, delivery staging, and downstream release folders",@ROOT@(4,"icon")="OUT",@ROOT@(4,"badge")="Folder",@ROOT@(4,"kind")="directory",@ROOT@(4,"group")="Directories",@ROOT@(4,"order")=40,@ROOT@(4,"launchKey")="workspace",@ROOT@(4,"desktopPinned")=1,@ROOT@(4,"status")="available",@ROOT@(4,"summary")="328 exports today"
	SET @ROOT@(5,"key")="profiles",@ROOT@(5,"title")="Profiles",@ROOT@(5,"subtitle")="Theme, terminal, workspace, and automation profile definitions",@ROOT@(5,"icon")="PRF",@ROOT@(5,"badge")="Folder",@ROOT@(5,"kind")="directory",@ROOT@(5,"group")="Directories",@ROOT@(5,"order")=50,@ROOT@(5,"launchKey")="settings",@ROOT@(5,"desktopPinned")=1,@ROOT@(5,"status")="available",@ROOT@(5,"summary")="Personalized"
	SET @ROOT@(6,"key")="terminal",@ROOT@(6,"title")="Terminal",@ROOT@(6,"subtitle")="Standard YottaDB session and future admin console",@ROOT@(6,"icon")=$GET(STATE("icon","terminal"),"YDB"),@ROOT@(6,"badge")="CLI",@ROOT@(6,"kind")="app",@ROOT@(6,"group")="Pinned",@ROOT@(6,"order")=60,@ROOT@(6,"launchKey")="terminal",@ROOT@(6,"desktopPinned")=1,@ROOT@(6,"status")="available"
	SET @ROOT@(7,"key")="collaboration",@ROOT@(7,"title")="Chat",@ROOT@(7,"subtitle")="User chat and analyst coordination workspace",@ROOT@(7,"icon")=$GET(STATE("icon","collaboration"),"CHT"),@ROOT@(7,"badge")="Team",@ROOT@(7,"kind")="app",@ROOT@(7,"group")="Applications",@ROOT@(7,"order")=70,@ROOT@(7,"launchKey")="collaboration",@ROOT@(7,"status")="available"
	SET @ROOT@(8,"key")="security",@ROOT@(8,"title")="Security",@ROOT@(8,"subtitle")="Access, errors, permissions, audit, and retention posture",@ROOT@(8,"icon")=$GET(STATE("icon","security"),"SEC"),@ROOT@(8,"badge")="Audit",@ROOT@(8,"kind")="app",@ROOT@(8,"group")="System",@ROOT@(8,"order")=80,@ROOT@(8,"launchKey")="security",@ROOT@(8,"status")="available"
	SET @ROOT@(9,"key")="admin",@ROOT@(9,"title")="Admin",@ROOT@(9,"subtitle")="Users, invites, reset tokens, and operational identity health",@ROOT@(9,"icon")=$GET(STATE("icon","admin"),"ADM"),@ROOT@(9,"badge")="Ops",@ROOT@(9,"kind")="app",@ROOT@(9,"group")="System",@ROOT@(9,"order")=90,@ROOT@(9,"launchKey")="admin",@ROOT@(9,"status")="available"
	SET @ROOT@(10,"key")="logs",@ROOT@(10,"title")="Logs",@ROOT@(10,"subtitle")="Audit, access, and operational trace directories",@ROOT@(10,"icon")="LOG",@ROOT@(10,"badge")="Folder",@ROOT@(10,"kind")="directory",@ROOT@(10,"group")="Directories",@ROOT@(10,"order")=100,@ROOT@(10,"launchKey")="security",@ROOT@(10,"status")="available",@ROOT@(10,"summary")="Retention managed"
	SET @ROOT@(11,"key")="automation",@ROOT@(11,"title")="Automation",@ROOT@(11,"subtitle")="Planned orchestration workspace for future workflow runners",@ROOT@(11,"icon")="AUT",@ROOT@(11,"badge")="Planned",@ROOT@(11,"kind")="future",@ROOT@(11,"group")="Planned",@ROOT@(11,"order")=110,@ROOT@(11,"disabled")=1,@ROOT@(11,"status")="planned"
	SET @ROOT@(12,"key")="integrations",@ROOT@(12,"title")="Integrations",@ROOT@(12,"subtitle")="Planned connectors, data exchange, and endpoint surfaces",@ROOT@(12,"icon")="API",@ROOT@(12,"badge")="Planned",@ROOT@(12,"kind")="future",@ROOT@(12,"group")="Planned",@ROOT@(12,"order")=120,@ROOT@(12,"disabled")=1,@ROOT@(12,"status")="planned"
	QUIT
	;
WINS(ROOT,STATE)
	DO DEFAULTWINS^MIOMOSWM(ROOT,$GET(STATE("windowPreset"),"analyst"))
	QUIT
	;
SAVELAYOUT(SID,PAYLOAD)
	NEW TREE,ERR,LAYOUT,RAW
	IF $GET(SID)="" QUIT 0
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
	QUIT
	;
