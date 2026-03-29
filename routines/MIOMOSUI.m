MIOMOSUI ; MIOMOS UI helpers
	QUIT
	;

OBSSSR(STATE,CONF,DATA)
	NEW OUT,N
	DO SUMMARY^MIOMOSOBS(.STATE,.CONF,.OUT)
	SET DATA("obsRetention","accessDays")=+$GET(OUT("retention","accessDays"))
	SET DATA("obsRetention","errorDays")=+$GET(OUT("retention","errorDays"))
	SET DATA("obsRetention","auditDays")=+$GET(OUT("retention","auditDays"))
	SET DATA("obsRetention","maxEntries")=+$GET(OUT("retention","maxEntries"))
	SET DATA("obsRetention","exportLimit")=+$GET(OUT("retention","exportLimit"))
	SET DATA("obsLastAccess","event")=$GET(OUT("lastAccess","event"))
	SET DATA("obsLastAccess","correlationId")=$GET(OUT("lastAccess","correlationId"))
	SET DATA("obsLastError","event")=$GET(OUT("lastError","event"))
	SET DATA("obsLastError","correlationId")=$GET(OUT("lastError","correlationId"))
	SET DATA("obsLastAudit","event")=$GET(OUT("lastAudit","event"))
	SET DATA("obsLastAudit","correlationId")=$GET(OUT("lastAudit","correlationId"))
	QUIT
	;
DESKCTX(STATE,CONF,DATA)
	KILL DATA
	SET DATA("page","title")=$GET(STATE("brandTitle"),"MIOMOS")_" Desktop"
	SET DATA("page","subtitle")=$GET(STATE("brandSubtitle"),"MUMPS-first clinical workspace")
	SET DATA("brandTitle")=$GET(STATE("brandTitle"),"MIOMOS")
	SET DATA("brandSubtitle")=$GET(STATE("brandSubtitle"),"MUMPS-first clinical workspace")
	SET DATA("userName")=$GET(STATE("userName"))
	SET DATA("profile")=$GET(STATE("profile"),"dev")
	SET DATA("sessionId")=$GET(STATE("sessionId"))
	SET DATA("desktopPath")=$GET(STATE("desktopPath"))
	SET DATA("bootstrapPath")=$GET(STATE("bootstrapPath"))
	SET DATA("wsPath")=$GET(STATE("wsPath"))
	SET DATA("themePath")=$GET(STATE("themePath"))
	SET DATA("settingsPath")=$GET(STATE("settingsPath"))
	SET DATA("viewPath")=$GET(STATE("viewPath"))
	SET DATA("commandPath")=$GET(STATE("commandPath"))
	SET DATA("commandEvent")=$GET(CONF("miomos","desktop","transport","eventName"),"command.exec")
	SET DATA("commandResultEvent")=$GET(CONF("miomos","desktop","transport","resultEvent"),"command.result")
	SET DATA("signoutEvent")="auth.signout"
	SET DATA("signoutPath")=$GET(STATE("signoutPath"))
	SET DATA("adminUsersPath")=$GET(STATE("adminUsersPath"))
	SET DATA("adminInviteCreatePath")=$GET(STATE("adminInviteCreatePath"))
	SET DATA("adminInvitePath")=$GET(STATE("adminInviteCreatePath"))
	SET DATA("adminResetRequestPath")=$GET(STATE("adminResetRequestPath"))
	SET DATA("adminResetPath")=$GET(STATE("adminResetRequestPath"))
	SET DATA("observSummaryPath")=$GET(STATE("observSummaryPath"))
	SET DATA("accessExportPath")=$GET(STATE("accessExportPath"))
	SET DATA("errorExportPath")=$GET(STATE("errorExportPath"))
	SET DATA("auditExportPath")=$GET(STATE("auditExportPath"))
	SET DATA("securityDigestPath")=$GET(STATE("securityDigestPath"))
	SET DATA("retentionPrunePath")=$GET(STATE("retentionPrunePath"))
	SET DATA("accent")=$GET(STATE("accent"),"#2f6fed")
	SET DATA("fontFamily")=$GET(STATE("fontFamily"),"Segoe UI")
	SET DATA("fontSize")=+$GET(STATE("fontSize"),13)
	SET DATA("titleAccentValue")=$GET(STATE("titleAccentValue"),$GET(STATE("accent"),"#2f6fed"))
	SET DATA("density")=$GET(STATE("density"),"dense")
	SET DATA("iconStyle")=$GET(STATE("iconStyle"),"glass")
	SET DATA("animations")=$GET(STATE("animations"),"standard")
	SET DATA("windowPreset")=$GET(STATE("windowPreset"),"analyst")
	SET DATA("snapMode")=$GET(STATE("snapMode"),"quadrant")
	SET DATA("motionProfile")=$GET(STATE("motionProfile"),"standard")
	SET DATA("titlebarStyle")=$GET(STATE("titlebarStyle"),"accent")
	SET DATA("wallpaper")=$GET(STATE("wallpaper"),"midnight-clinic")
	SET DATA("themeKey")=$GET(STATE("themeKey"),"midnight-professional")
	SET DATA("bootJson")=$$BOOTJSON^MIOMOSST(.STATE,.CONF)
	SET DATA("vueScript")="https://unpkg.com/vue@3/dist/vue.global.prod.js"
	SET DATA("nativeShellEngine")="miomos-native-vue-css"
	SET DATA("sevenCssHref")="https://unpkg.com/7.css/dist/7.scoped.css"
	DO APPSSR(.DATA,.STATE)
	DO WINSSR(.DATA,.STATE)
	DO THEMESSR(.DATA,$GET(STATE("themeKey"),"midnight-professional"))
	DO SETTINGSSSR(.DATA,.STATE,.CONF)
	DO AUDITSSR(.DATA)
	DO LOGSSR(.DATA)
	DO PERMSSR(.DATA,$GET(STATE("roles")))
	DO ADMINSSR(.DATA)
	DO OBSSSR(.STATE,.CONF,.DATA)
	QUIT
	;
AUTHCTX(CONF,DATA)
	KILL DATA
	SET DATA("page","title")=$GET(CONF("miomos","brand","title"),"MIOMOS")_" Access"
	SET DATA("page","subtitle")=$GET(CONF("miomos","brand","subtitle"),"MUMPS-first clinical workspace")
	SET DATA("brandTitle")=$GET(CONF("miomos","brand","title"),"MIOMOS")
	SET DATA("brandSubtitle")=$GET(CONF("miomos","brand","subtitle"),"MUMPS-first clinical workspace")
	SET DATA("signinPath")=$GET(CONF("miomos","route","signin"),"/api/miomos/auth/signin")
	SET DATA("signupPath")=$GET(CONF("miomos","route","signup"),"/api/miomos/auth/signup")
	SET DATA("guestSigninPath")=$GET(CONF("miomos","route","guestSignin"),"/api/miomos/auth/guest")
	SET DATA("desktopPath")=$GET(CONF("miomos","route","desktop"),"/miomos")
	SET DATA("allowSignup")=+$GET(CONF("miomos","localAuth","allowSignup"),1)
	SET DATA("inviteOnly")=+$GET(CONF("miomos","localAuth","inviteOnly"),0)
	SET DATA("guestLoginEnabled")=+$GET(CONF("miomos","localAuth","guestLoginEnabled"),1)
	SET DATA("bootstrapAuthEnabled")=+$GET(CONF("miomos","bootstrapAuth","enabled"),1)
	SET DATA("seededVisible")=+$GET(CONF("miomos","bootstrapAuth","showSeededCredentials"),1)
	SET DATA("authWorkflow")=$SELECT(+$GET(CONF("miomos","localAuth","enabled"),0)=1:"local-auth",1:"guest-only")
	DO SEEDSSR(.CONF,.DATA)
	SET DATA("sevenCssHref")="https://unpkg.com/7.css/dist/7.scoped.css"
	QUIT
	;
SEEDSSR(CONF,DATA)
	NEW MAP,ROLE,N,USER,PASS,DISPLAY,ENABLED,LABEL
	SET MAP(1)="admin",MAP(2)="user",MAP(3)="guest"
	SET N=0 FOR  SET N=$ORDER(MAP(N)) QUIT:N=""  DO
	. SET ROLE=MAP(N)
	. SET ENABLED=+$GET(CONF("miomos","bootstrapAuth",ROLE,"enabled"),1)
	. SET USER=$GET(CONF("miomos","bootstrapAuth",ROLE,"username"),ROLE)
	. SET PASS=$GET(CONF("miomos","bootstrapAuth",ROLE,"password"))
	. SET DISPLAY=$GET(CONF("miomos","bootstrapAuth",ROLE,"displayName"),$ZCONVERT(ROLE,"U"))
	. SET LABEL=$SELECT(ROLE="admin":"Administrator",ROLE="user":"Standard user",1:"Guest")
	. SET DATA("seeded",N,"key")=ROLE
	. SET DATA("seeded",N,"username")=USER
	. SET DATA("seeded",N,"password")=PASS
	. SET DATA("seeded",N,"displayName")=DISPLAY
	. SET DATA("seeded",N,"roleLabel")=LABEL
	. SET DATA("seeded",N,"enabled")=ENABLED
	. SET DATA("seeded",N,"isAdmin")=$SELECT(ROLE="admin":1,1:0)
	. SET DATA("seeded",N,"isUser")=$SELECT(ROLE="user":1,1:0)
	. SET DATA("seeded",N,"isGuest")=$SELECT(ROLE="guest":1,1:0)
	. IF ROLE="admin" SET DATA("seededAdminUsername")=USER,DATA("seededAdminPassword")=PASS
	. IF ROLE="user" SET DATA("seededUserUsername")=USER,DATA("seededUserPassword")=PASS
	. IF ROLE="guest" SET DATA("seededGuestUsername")=USER,DATA("seededGuestPassword")=PASS
	QUIT
	;
APPSSR(DATA,STATE)
	KILL DATA("apps")
	SET DATA("apps",1,"key")="workspace",DATA("apps",1,"title")="Workspace",DATA("apps",1,"subtitle")="Queues, intake, review, and export",DATA("apps",1,"icon")=$GET(STATE("icon","workspace"),"W"),DATA("apps",1,"badge")="Live"
	SET DATA("apps",2,"key")="ui-library",DATA("apps",2,"title")="UI Library",DATA("apps",2,"subtitle")="7.css-influenced forms, tables, overlays, navigation, and tokens",DATA("apps",2,"icon")="UIL",DATA("apps",2,"badge")="Design"
	SET DATA("apps",3,"key")="collaboration",DATA("apps",3,"title")="Chat",DATA("apps",3,"subtitle")="User chat and analyst coordination",DATA("apps",3,"icon")=$GET(STATE("icon","collaboration"),"C"),DATA("apps",3,"badge")="Team"
	SET DATA("apps",4,"key")="security",DATA("apps",4,"title")="Security",DATA("apps",4,"subtitle")="Access, errors, permissions, and audit",DATA("apps",4,"icon")=$GET(STATE("icon","security"),"S"),DATA("apps",4,"badge")="Audit"
	SET DATA("apps",5,"key")="admin",DATA("apps",5,"title")="Admin",DATA("apps",5,"subtitle")="Users, invites, resets, and lockout posture",DATA("apps",5,"icon")=$GET(STATE("icon","admin"),"A"),DATA("apps",5,"badge")="Ops"
	SET DATA("apps",6,"key")="settings",DATA("apps",6,"title")="Settings",DATA("apps",6,"subtitle")="Themes, fonts, density, colors, and icons",DATA("apps",6,"icon")=$GET(STATE("icon","settings"),"T"),DATA("apps",6,"badge")="Prefs"
	SET DATA("apps",7,"key")="terminal",DATA("apps",7,"title")="Terminal",DATA("apps",7,"subtitle")="Native MIOMOS replica terminal over the native window manager",DATA("apps",7,"icon")=$GET(STATE("icon","terminal"),">_"),DATA("apps",7,"badge")="CLI"
	QUIT
	;
WINSSR(DATA,STATE)
	DO WIN(.DATA,1,"win-workspace","workspace","Workspace",16,14,1180,690,6,"normal",$GET(STATE("icon","workspace"),"W"))
	SET DATA("windows",1,"isWorkspace")=1
	DO WIN(.DATA,2,"win-ui-library","ui-library","UI Library",268,94,920,600,5,"minimized","UIL")
	SET DATA("windows",2,"isUiLibrary")=1
	DO WIN(.DATA,3,"win-collaboration","collaboration","Chat",940,44,420,430,3,"minimized",$GET(STATE("icon","collaboration"),"C"))
	SET DATA("windows",3,"isCollaboration")=1
	DO WIN(.DATA,4,"win-security","security","Security",970,488,390,258,2,"minimized",$GET(STATE("icon","security"),"S"))
	SET DATA("windows",4,"isSecurity")=1
	DO WIN(.DATA,5,"win-admin","admin","Admin",220,68,820,520,4,"minimized",$GET(STATE("icon","admin"),"A"))
	SET DATA("windows",5,"isAdmin")=1
	DO WIN(.DATA,6,"win-settings","settings","Settings",240,88,700,520,5,"minimized",$GET(STATE("icon","settings"),"T"))
	SET DATA("windows",6,"isSettings")=1
	DO WIN(.DATA,7,"win-terminal","terminal","Terminal",110,80,960,540,7,"minimized",$GET(STATE("icon","terminal"),">_"))
	SET DATA("windows",7,"isTerminal")=1
	QUIT
	;
WIN(DATA,N,ID,APPKEY,TITLE,LEFT,TOP,WIDTH,HEIGHT,Z,STATE,GLYPH)
	SET DATA("windows",N,"id")=ID
	SET DATA("windows",N,"appKey")=APPKEY
	SET DATA("windows",N,"title")=TITLE
	SET DATA("windows",N,"left")=LEFT
	SET DATA("windows",N,"top")=TOP
	SET DATA("windows",N,"width")=WIDTH
	SET DATA("windows",N,"height")=HEIGHT
	SET DATA("windows",N,"z")=Z
	SET DATA("windows",N,"state")=STATE
	SET DATA("windows",N,"glyph")=$SELECT($GET(GLYPH)'="":$GET(GLYPH),1:$EXTRACT(TITLE,1))
	SET DATA("windows",N,"stateClass")=$SELECT(STATE="minimized":"is-minimized",1:"")
	QUIT
	;
THEMESSR(DATA,CURRENT)
	NEW CAT,N
	DO CATALOG^MIOMOSTH($NAME(CAT))
	KILL DATA("themes")
	SET N=0
	FOR  SET N=$ORDER(CAT(N)) QUIT:N=""  DO
	. MERGE DATA("themes",N)=CAT(N)
	. SET DATA("themes",N,"isCurrent")=$SELECT($GET(CAT(N,"key"))=$GET(CURRENT):1,1:0)
	QUIT
	;
SETTINGSSSR(DATA,STATE,CONF)
	NEW CUR,N
	DO CURRENT^MIOMOSSET($GET(STATE("principal")),.CUR)
	MERGE DATA("settingsCurrent")=CUR("current")
	MERGE DATA("settingsCatalog")=CUR("catalog")
	SET N=0 FOR  SET N=$ORDER(DATA("settingsCatalog","themes",N)) QUIT:N=""  DO
	. SET DATA("settingsCatalog","themes",N,"isCurrent")=$SELECT($GET(DATA("settingsCatalog","themes",N,"key"))=$GET(STATE("themeKey")):1,1:0)
	QUIT
	;

AUDITSSR(DATA)
	NEW TAIL,N
	DO TAIL^MIOMOSAUD(4,.TAIL)
	KILL DATA("audit")
	SET N=0
	FOR  SET N=$ORDER(TAIL(N)) QUIT:N=""  MERGE DATA("audit",N)=TAIL(N)
	QUIT
	;
LOGSSR(DATA)
	NEW CNT,TAIL,N
	DO COUNTS^MIOMOSOBS(.CNT)
	SET DATA("logCounts","access")=+$GET(CNT("access"))
	SET DATA("logCounts","error")=+$GET(CNT("error"))
	SET DATA("logCounts","audit")=+$GET(CNT("audit"))
	DO TAIL^MIOMOSOBS("ERROR",3,.TAIL)
	KILL DATA("errors")
	SET N=0
	FOR  SET N=$ORDER(TAIL(N)) QUIT:N=""  MERGE DATA("errors",N)=TAIL(N)
	QUIT
	;
PERMSSR(DATA,ROLES)
	NEW LIST,N
	DO LIST^MIOMOSPERM($GET(ROLES),.LIST)
	KILL DATA("permissions")
	SET N=0
	FOR  SET N=$ORDER(LIST(N)) QUIT:N=""  MERGE DATA("permissions",N)=LIST(N)
	QUIT
	;
ADMINSSR(DATA)
	NEW CNT,USR,INV,RST,N
	DO COUNTS^MIOMOSADMIN(.CNT)
	SET DATA("adminCounts","users")=+$GET(CNT("users"))
	SET DATA("adminCounts","enabled")=+$GET(CNT("enabled"))
	SET DATA("adminCounts","disabled")=+$GET(CNT("disabled"))
	SET DATA("adminCounts","locked")=+$GET(CNT("locked"))
	SET DATA("adminCounts","invites")=+$GET(CNT("invites"))
	SET DATA("adminCounts","resets")=+$GET(CNT("resets"))
	DO USERLIST^MIOMOSADMIN(8,.USR)
	KILL DATA("adminUsers")
	SET N=0 FOR  SET N=$ORDER(USR(N)) QUIT:N=""  MERGE DATA("adminUsers",N)=USR(N)
	DO INVITELIST^MIOMOSADMIN(4,.INV)
	KILL DATA("adminInvites")
	SET N=0 FOR  SET N=$ORDER(INV(N)) QUIT:N=""  MERGE DATA("adminInvites",N)=INV(N)
	DO RESETLIST^MIOMOSADMIN(4,.RST)
	KILL DATA("adminResets")
	SET N=0 FOR  SET N=$ORDER(RST(N)) QUIT:N=""  MERGE DATA("adminResets",N)=RST(N)
	QUIT
	;
