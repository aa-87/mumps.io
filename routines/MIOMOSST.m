MIOMOSST ; MIOMOS state/session helpers
	QUIT
	;
ENSURE(CONF,REQ,CTX,STATE,ERR)
	NEW KEY,SID,NOWD,NOWS,ABS,IDLE,USER,ROLES,STARTD,STARTS,LASTD,LASTS
	KILL ERR,STATE
	SET ERR("routine")="MIOMOSST"
	SET KEY=$$PRINCIPAL(.CONF,.CTX)
	IF KEY="" SET ERR("error")="auth_context_missing" QUIT 0
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
	SET STATE("brandTitle")=$GET(CONF("miomos","brand","title"),"MIOMOS")
	SET STATE("brandSubtitle")=$GET(CONF("miomos","brand","subtitle"),"MUMPS-first clinical workspace")
	SET STATE("wallpaper")=$GET(CONF("miomos","desktop","wallpaper"),"midnight-clinic")
	SET STATE("accent")=$GET(CONF("miomos","desktop","accent"),"#2f6fed")
	SET STATE("density")=$GET(CONF("miomos","desktop","density"),"compact")
	SET STATE("profile")=$$PROFILE(.CONF)
	QUIT 1
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
PRINCIPAL(CONF,CTX)
	IF $$DEVAUTH(.CONF) QUIT $GET(CONF("miomos","dev","principal"),"dev-user")
	QUIT $$PRINCIPAL^MIOMOSAUTH(.CTX)
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
	SET OBJ("product","version")="osjs-rebuild-roi3"
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
	SET OBJ("desktopPath")=$GET(STATE("desktopPath"))
	SET OBJ("bootstrapPath")=$GET(STATE("bootstrapPath"))
	SET OBJ("websocketPath")=$GET(STATE("wsPath"))
	SET OBJ("desktop","theme","wallpaper")=$GET(STATE("wallpaper"))
	SET OBJ("desktop","theme","accent")=$GET(STATE("accent"))
	SET OBJ("desktop","density")=$GET(STATE("density"))
	SET OBJ("desktop","launcherLabel")="Menu"
	SET OBJ("desktop","engine")="miomos-osjs-bridge"
	SET OBJ("integrations","vue","global")="Vue"
	SET OBJ("integrations","vue","mode")="options-api-umd"
	SET OBJ("integrations","osjs","global")="osjsClient"
	SET OBJ("integrations","osjs","clientScript")="https://cdn.jsdelivr.net/npm/@osjs/client/dist/main.js"
	SET OBJ("integrations","osjs","standalone")="deferred"
	SET OBJ("integrations","sevenCss","scopeClass")="win7"
	DO APPS($NAME(OBJ("desktop","apps")))
	DO WINS($NAME(OBJ("desktop","windows")))
	SET OBJ("desktop","savedLayoutJson")=$GET(^MIO("MIOMOS","SESSION",$GET(STATE("sessionId")),"layoutJson"))
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
	SET @ROOT@(2,"key")="operations"
	SET @ROOT@(2,"title")="Operations"
	SET @ROOT@(2,"subtitle")="Throughput, latency, and batch posture"
	SET @ROOT@(2,"icon")="O"
	SET @ROOT@(2,"badge")="Ops"
	SET @ROOT@(3,"key")="security"
	SET @ROOT@(3,"title")="Audit"
	SET @ROOT@(3,"subtitle")="Sessions, controls, and privileged actions"
	SET @ROOT@(3,"icon")="A"
	SET @ROOT@(3,"badge")="Audit"
	QUIT
	;
WINS(ROOT)
	KILL @ROOT
	SET @ROOT@(1,"id")="win-workspace"
	SET @ROOT@(1,"appKey")="workspace"
	SET @ROOT@(1,"title")="Workspace"
	SET @ROOT@(1,"state")="normal"
	SET @ROOT@(1,"left")=18
	SET @ROOT@(1,"top")=18
	SET @ROOT@(1,"width")=1104
	SET @ROOT@(1,"height")=660
	SET @ROOT@(1,"z")=4
	SET @ROOT@(2,"id")="win-operations"
	SET @ROOT@(2,"appKey")="operations"
	SET @ROOT@(2,"title")="Operations"
	SET @ROOT@(2,"state")="minimized"
	SET @ROOT@(2,"left")=1136
	SET @ROOT@(2,"top")=18
	SET @ROOT@(2,"width")=280
	SET @ROOT@(2,"height")=320
	SET @ROOT@(2,"z")=3
	SET @ROOT@(3,"id")="win-security"
	SET @ROOT@(3,"appKey")="security"
	SET @ROOT@(3,"title")="Audit"
	SET @ROOT@(3,"state")="minimized"
	SET @ROOT@(3,"left")=1136
	SET @ROOT@(3,"top")=350
	SET @ROOT@(3,"width")=280
	SET @ROOT@(3,"height")=268
	SET @ROOT@(3,"z")=2
	QUIT
	;
SAVELAYOUT(SID,PAYLOAD)
	IF $GET(SID)="" QUIT 0
	SET ^MIO("MIOMOS","SESSION",SID,"layoutJson")=$EXTRACT($GET(PAYLOAD),1,8192)
	SET ^MIO("MIOMOS","SESSION",SID,"layoutSavedAt")=$$NOWISO^MIOUTIL()
	QUIT 1
	;
