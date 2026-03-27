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
	SET STATE("themeKey")=$$CURRENT^MIOMOSTH(.STATE,.CONF)
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
	SET OBJ("product","version")="roi7-observability"
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
	SET OBJ("desktop","snapMargin")=+$GET(STATE("snapMargin"),18)
	SET OBJ("desktop","launcherLabel")="Menu"
	SET OBJ("desktop","engine")="miomos-osjs-bridge"
	SET OBJ("desktop","windowManager")="miomos-lean-production"
	SET OBJ("desktop","savedLayoutJson")=$GET(^MIO("MIOMOS","SESSION",$GET(STATE("sessionId")),"layoutJson"))
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
	DO APPS($NAME(OBJ("desktop","apps")))
	DO WINS($NAME(OBJ("desktop","windows")))
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
APPS(ROOT)
	KILL @ROOT
	SET @ROOT@(1,"key")="workspace"
	SET @ROOT@(1,"title")="Workspace"
	SET @ROOT@(1,"subtitle")="Queues, intake, review, and export"
	SET @ROOT@(1,"icon")="W"
	SET @ROOT@(1,"badge")="Live"
	SET @ROOT@(2,"key")="collaboration"
	SET @ROOT@(2,"title")="Chat"
	SET @ROOT@(2,"subtitle")="User chat and analyst coordination"
	SET @ROOT@(2,"icon")="C"
	SET @ROOT@(2,"badge")="Team"
	SET @ROOT@(3,"key")="security"
	SET @ROOT@(3,"title")="Security"
	SET @ROOT@(3,"subtitle")="Access, errors, permissions, and audit"
	SET @ROOT@(3,"icon")="S"
	SET @ROOT@(3,"badge")="Audit"
	SET @ROOT@(4,"key")="admin"
	SET @ROOT@(4,"title")="Admin"
	SET @ROOT@(4,"subtitle")="Users, invites, reset tokens, and account health"
	SET @ROOT@(4,"icon")="A"
	SET @ROOT@(4,"badge")="Ops"
	QUIT
	;
WINS(ROOT)
	KILL @ROOT
	SET @ROOT@(1,"id")="win-workspace"
	SET @ROOT@(1,"appKey")="workspace"
	SET @ROOT@(1,"title")="Workspace"
	SET @ROOT@(1,"state")="normal"
	SET @ROOT@(1,"left")=16
	SET @ROOT@(1,"top")=14
	SET @ROOT@(1,"width")=1180
	SET @ROOT@(1,"height")=690
	SET @ROOT@(1,"z")=6
	SET @ROOT@(2,"id")="win-collaboration"
	SET @ROOT@(2,"appKey")="collaboration"
	SET @ROOT@(2,"title")="Chat"
	SET @ROOT@(2,"state")="minimized"
	SET @ROOT@(2,"left")=940
	SET @ROOT@(2,"top")=44
	SET @ROOT@(2,"width")=420
	SET @ROOT@(2,"height")=430
	SET @ROOT@(2,"z")=3
	SET @ROOT@(3,"id")="win-security"
	SET @ROOT@(3,"appKey")="security"
	SET @ROOT@(3,"title")="Security"
	SET @ROOT@(3,"state")="minimized"
	SET @ROOT@(3,"left")=970
	SET @ROOT@(3,"top")=488
	SET @ROOT@(3,"width")=390
	SET @ROOT@(3,"height")=258
	SET @ROOT@(3,"z")=2
	SET @ROOT@(4,"id")="win-admin"
	SET @ROOT@(4,"appKey")="admin"
	SET @ROOT@(4,"title")="Admin"
	SET @ROOT@(4,"state")="minimized"
	SET @ROOT@(4,"left")=220
	SET @ROOT@(4,"top")=68
	SET @ROOT@(4,"width")=820
	SET @ROOT@(4,"height")=520
	SET @ROOT@(4,"z")=4
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
	QUIT 1
	;
