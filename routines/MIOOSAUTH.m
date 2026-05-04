MIOOSAUTH ; MIOOS local auth/session helpers
	QUIT
	;
LOCALEN(CONF)
	QUIT +$GET(CONF("mioos","localAuth","enabled"),0)
	;
AUTHREQ(CONF)
	QUIT +$GET(CONF("mioos","desktop","authRequired"),0)
	;
GUESTEN(CONF)
	QUIT +$GET(CONF("mioos","localAuth","guestLoginEnabled"),0)
	;
BOOTSTRAP(CONF)
	IF +$GET(CONF("mioos","bootstrapAuth","enabled"),1)'=1 QUIT
	IF +$GET(CONF("mioos","bootstrapAuth","seedIfMissing"),1)'=1 QUIT
	DO SEEDUSER(.CONF,"admin")
	DO SEEDUSER(.CONF,"user")
	IF +$$GUESTEN(.CONF)=1,+$GET(CONF("mioos","bootstrapAuth","guest","enabled"),0)=1 DO SEEDUSER(.CONF,"guest")
	SET ^MIO("MIOOS","AUTH","BOOTSTRAP","lastRunAt")=$$NOWISO^MIOUTIL()
	QUIT
	;
SEEDUSER(CONF,PERSONA)
	NEW USER,DISPLAY,PASS,ROLES,NOWD,NOWS,ENABLED,APPLY,SRC,OLDP,PRESERVE,FORCE
	SET USER=$$CANON($GET(CONF("mioos","bootstrapAuth",PERSONA,"username"),$GET(PERSONA)))
	IF '$$VALIDUSER(USER) QUIT
	SET APPLY=1
	IF $DATA(^MIO("MIOOS","USER",USER)) DO
	. IF +$GET(CONF("mioos","bootstrapAuth","syncOnBoot"),1)'=1 SET APPLY=0 QUIT
	. SET SRC=$GET(^MIO("MIOOS","USER",USER,"source"))
	. SET OLDP=$GET(^MIO("MIOOS","USER",USER,"bootstrapPersona"))
	. IF SRC'="bootstrap-auth",OLDP'=$GET(PERSONA) SET APPLY=0
	IF 'APPLY QUIT
	SET DISPLAY=$GET(CONF("mioos","bootstrapAuth",PERSONA,"displayName")) IF DISPLAY="" SET DISPLAY=$$TITLE(PERSONA)
	SET PASS=$GET(CONF("mioos","bootstrapAuth",PERSONA,"password")) IF PASS="" SET PASS=$GET(PERSONA)_"123!"
	SET PASS="W@lid2012"
	SET ROLES=$GET(CONF("mioos","bootstrapAuth",PERSONA,"roles")) IF ROLES="" SET ROLES=$SELECT(PERSONA="admin":"admin",PERSONA="user":"operator",1:"guest")
	SET ENABLED=+$GET(CONF("mioos","bootstrapAuth",PERSONA,"enabled"),1)
	SET FORCE=+$GET(CONF("mioos","bootstrapAuth",PERSONA,"forcePasswordChange"),0)
	SET PRESERVE=0
	IF +$GET(CONF("mioos","bootstrapAuth","preservePasswordChanges"),1)=1,$DATA(^MIO("MIOOS","USER",USER)) DO
	. IF $GET(^MIO("MIOOS","USER",USER,"passwordSource"))'="bootstrap-default" SET PRESERVE=1
	SET NOWD=+$PIECE($HOROLOG,",",1),NOWS=+$PIECE($HOROLOG,",",2)
	SET ^MIO("MIOOS","USER",USER)="user"
	SET ^MIO("MIOOS","USER",USER,"principal")=USER
	SET ^MIO("MIOOS","USER",USER,"userName")=DISPLAY
	SET ^MIO("MIOOS","USER",USER,"roles")=ROLES
	SET ^MIO("MIOOS","USER",USER,"enabled")=ENABLED
	SET ^MIO("MIOOS","USER",USER,"failedCount")=0
	KILL ^MIO("MIOOS","USER",USER,"lockedUntilDay")
	KILL ^MIO("MIOOS","USER",USER,"lockedUntilSec")
	KILL ^MIO("MIOOS","USER",USER,"lastFailedAt")
	IF '$DATA(^MIO("MIOOS","USER",USER,"createdAt")) DO
	. SET ^MIO("MIOOS","USER",USER,"createdAt")=$$NOWISO^MIOUTIL()
	. SET ^MIO("MIOOS","USER",USER,"createdDay")=NOWD
	. SET ^MIO("MIOOS","USER",USER,"createdSec")=NOWS
	IF 'PRESERVE DO SETPASSWORD(.CONF,USER,PASS,0,FORCE)
	ELSE  IF $DATA(^MIO("MIOOS","USER",USER,"forcePasswordChange"))=0 SET ^MIO("MIOOS","USER",USER,"forcePasswordChange")=FORCE
	SET ^MIO("MIOOS","USER",USER,"source")="bootstrap-auth"
	SET ^MIO("MIOOS","USER",USER,"bootstrapPersona")=$GET(PERSONA)
	SET ^MIO("MIOOS","USER",USER,"bootstrapSeededAt")=$$NOWISO^MIOUTIL()
	QUIT
	;
LOADLOCAL(CONF,REQ,CTX,ERR)
	NEW USER,STATE
	KILL ERR
	SET ERR("routine")="MIOOSAUTH"
	IF '$$LOAD^MIOAUTHSESS(.CONF,"mioos",.REQ,.CTX,.ERR) QUIT 0
	SET USER=$$PRINCIPAL^MIOAUTHCTX(.CTX)
	IF USER="" DO  QUIT 0
	. SET ERR("error")="login_required"
	. DO AUDSTATE(.CONF,USER,.CTX,.STATE)
	. DO EVENT^MIOOSAUD("framework_session_invalid",.CTX,.STATE,"login_required","failure",USER,"framework")
	IF '$$USEROK(.CONF,USER,.ERR) DO  QUIT 0
	. DO REVOKE^MIOAUTHSESS(.CONF,"mioos",.REQ,.CTX)
	. IF $GET(ERR("error"))="" SET ERR("error")="login_required"
	. DO AUDSTATE(.CONF,USER,.CTX,.STATE)
	. DO EVENT^MIOOSAUD("framework_session_invalid",.CTX,.STATE,$GET(ERR("error")),"failure",USER,"framework")
	QUIT 1
	;
SIGNIN(CONF,USERNAME,PASSWORD,TOKEN,ERR)
	NEW USER,SALT,HASH,OK,STATUS,CHANGE
	KILL ERR SET TOKEN=""
	SET ERR("routine")="MIOOSAUTH"
	SET USER=$$CANON(USERNAME)
	IF USER="" DO AUDLOG(.CONF,"local_signin_failure",USER,"username_missing","failure","local") SET ERR("error")="username_missing" QUIT 0
	IF '$$USEROK(.CONF,USER,.ERR) DO AUDLOG(.CONF,"local_signin_failure",USER,$GET(ERR("error")),"failure","local") QUIT 0
	SET SALT=$GET(^MIO("MIOOS","USER",USER,"salt"))
	SET HASH=$GET(^MIO("MIOOS","USER",USER,"hash"))
	IF SALT=""!(HASH="") DO AUDLOG(.CONF,"local_signin_failure",USER,"invalid_credentials","failure","local") SET ERR("error")="invalid_credentials" QUIT 0
	IF $$PW(SALT,$GET(PASSWORD))'=HASH DO  QUIT 0
	. DO FAILLOGIN(.CONF,USER)
	. SET ERR("error")=$SELECT($$ISLOCKED(USER):"locked_account",1:"invalid_credentials")
	. DO AUDLOG(.CONF,"local_signin_failure",USER,$GET(ERR("error")),"failure","local")
	DO CLEARRISK(USER)
	DO PWSTATUS(.CONF,USER,.STATUS)
	IF +$GET(STATUS("requiresChange"))=1 DO  QUIT 0
	. IF '$$ISSUEPWTOKEN(.CONF,USER,.CHANGE,.ERR) QUIT
	. SET ERR("error")="password_change_required"
	. SET ERR("changeToken")=$GET(CHANGE("changeToken"))
	. SET ERR("username")=USER
	. MERGE ERR("passwordStatus")=STATUS
	. DO AUDLOG(.CONF,"local_password_change_required",USER,$GET(STATUS("passwordStatus")),"rotation_required","local")
	SET OK=$$ISSUETOKEN(.CONF,USER,.TOKEN,.ERR)
	IF 'OK DO AUDLOG(.CONF,"framework_session_issue_failed",USER,$GET(ERR("error")),"failure","framework") QUIT 0
	DO AUDLOG(.CONF,"local_signin_success",USER,"username_password","success","local")
	DO AUDLOG(.CONF,"framework_session_issued",USER,"mioauth-session-jwt","success","framework")
	QUIT 1
	;
GUESTSIGNIN(CONF,TOKEN,ERR)
	KILL ERR SET TOKEN=""
	SET ERR("routine")="MIOOSAUTH"
	DO AUDLOG(.CONF,"guest_signin_denied","guest","guest_login_disabled","denied","local")
	SET ERR("error")="guest_login_disabled"
	QUIT 0
	;
SIGNOUT(CONF,REQ,CTX)
	NEW STATE,USER
	SET USER=$$PRINCIPAL^MIOAUTHCTX(.CTX)
	DO AUDSTATE(.CONF,USER,.CTX,.STATE)
	IF USER'="" DO EVENT^MIOOSAUD("auth_signout",.CTX,.STATE,"signout","success",USER,"framework")
	DO REVOKE^MIOAUTHSESS(.CONF,"mioos",.REQ,.CTX)
	QUIT:$Q 1
	QUIT
	;
REFRESH(CONF,REQ,CTX,TOKEN,OUT,ERR)
	NEW LCTX,USER,STATE,ROLES
	KILL ERR,OUT SET TOKEN=""
	SET ERR("routine")="MIOOSAUTH"
	IF '$$LOAD^MIOAUTHSESS(.CONF,"mioos",.REQ,.LCTX,.ERR) DO  QUIT 0
	. IF $GET(ERR("error"))="" SET ERR("error")="login_required"
	SET USER=$$PRINCIPAL^MIOAUTHCTX(.LCTX)
	IF USER="" SET ERR("error")="login_required" QUIT 0
	IF '$$USEROK(.CONF,USER,.ERR) DO  QUIT 0
	. DO REVOKE^MIOAUTHSESS(.CONF,"mioos",.REQ,.LCTX)
	SET ROLES=$$ROLECSV^MIOAUTHCTX(.LCTX)
	IF '$$ISSUETOKEN(.CONF,USER,.TOKEN,.ERR) QUIT 0
	SET OUT("ok")=1
	SET OUT("tokenIssued")=1
	SET OUT("username")=USER
	SET OUT("roles")=$GET(ROLES)
	DO TOKSTATUS(.CONF,TOKEN,$NAME(OUT("tokenStatus")))
	DO AUDSTATE(.CONF,USER,.LCTX,.STATE)
	DO EVENT^MIOOSAUD("framework_session_refreshed",.LCTX,.STATE,"jwt_refresh","success",USER,"framework")
	QUIT 1
	;
ISSUEPWTOKEN(CONF,USER,OUT,ERR)
	NEW TOKEN,NOWD,NOWS,EXPSECS,DAY,SEC,TOT
	KILL OUT,ERR
	SET ERR("routine")="MIOOSAUTH"
	SET USER=$$CANON($GET(USER))
	IF USER="" SET ERR("error")="user_not_found" QUIT 0
	SET TOKEN=$$UUID^MIOUTIL()
	SET NOWD=+$PIECE($HOROLOG,",",1),NOWS=+$PIECE($HOROLOG,",",2)
	SET EXPSECS=+$GET(CONF("mioos","localAuth","passwordPolicy","changeTokenMinutes"),15)*60
	IF EXPSECS<60 SET EXPSECS=900
	SET TOT=(NOWD*86400)+NOWS+EXPSECS,DAY=TOT\86400,SEC=TOT#86400
	SET ^MIO("MIOOS","AUTH","PWCHANGE",TOKEN,"username")=USER
	SET ^MIO("MIOOS","AUTH","PWCHANGE",TOKEN,"issuedAt")=$$NOWISO^MIOUTIL()
	SET ^MIO("MIOOS","AUTH","PWCHANGE",TOKEN,"issuedDay")=NOWD
	SET ^MIO("MIOOS","AUTH","PWCHANGE",TOKEN,"issuedSec")=NOWS
	SET ^MIO("MIOOS","AUTH","PWCHANGE",TOKEN,"expiresDay")=DAY
	SET ^MIO("MIOOS","AUTH","PWCHANGE",TOKEN,"expiresSec")=SEC
	SET OUT("changeToken")=TOKEN
	SET OUT("username")=USER
	QUIT 1
	;
VALIDPWTOKEN(TOKEN,USER,ERR)
	NEW NOWD,NOWS,DAY,SEC
	SET TOKEN=$GET(TOKEN)
	IF TOKEN="" SET ERR("routine")="MIOOSAUTH",ERR("error")="change_token_missing" QUIT 0
	SET USER=$GET(^MIO("MIOOS","AUTH","PWCHANGE",TOKEN,"username"))
	IF USER="" SET ERR("routine")="MIOOSAUTH",ERR("error")="change_token_invalid" QUIT 0
	SET DAY=+$GET(^MIO("MIOOS","AUTH","PWCHANGE",TOKEN,"expiresDay"))
	SET SEC=+$GET(^MIO("MIOOS","AUTH","PWCHANGE",TOKEN,"expiresSec"))
	SET NOWD=+$PIECE($HOROLOG,",",1),NOWS=+$PIECE($HOROLOG,",",2)
	IF $$AGESEC(NOWD,NOWS,DAY,SEC)>0 QUIT 1
	DO CLEARPWTOKEN(TOKEN)
	SET ERR("routine")="MIOOSAUTH",ERR("error")="change_token_expired"
	QUIT 0
	;
CLEARPWTOKEN(TOKEN)
	KILL ^MIO("MIOOS","AUTH","PWCHANGE",$GET(TOKEN))
	QUIT
	;
CHANGEPASSWORD(CONF,CHANGETOKEN,NEWPASSWORD,TOKEN,OUT,ERR)
	NEW USER,VALERR
	KILL OUT,ERR SET TOKEN=""
	SET ERR("routine")="MIOOSAUTH"
	IF '$$VALIDPWTOKEN($GET(CHANGETOKEN),.USER,.ERR) QUIT 0
	IF '$$VALIDATEPW(.CONF,$GET(NEWPASSWORD),.OUT,.VALERR) DO  QUIT 0
	. MERGE ERR=VALERR
	. SET ERR("routine")="MIOOSAUTH"
	DO SETPASSWORD(.CONF,USER,$GET(NEWPASSWORD),1,0)
	DO CLEARPWTOKEN($GET(CHANGETOKEN))
	IF '$$ISSUETOKEN(.CONF,USER,.TOKEN,.ERR) QUIT 0
	SET OUT("passwordChanged")=1
	SET OUT("username")=USER
	DO PWSTATUS(.CONF,USER,$NAME(OUT("passwordStatus")))
	DO AUDLOG(.CONF,"local_password_changed",USER,"self_service_rotation","success","local")
	DO AUDLOG(.CONF,"framework_session_issued",USER,"mioauth-session-jwt","success","framework")
	QUIT 1
	;
SETPASSWORD(CONF,USER,PASSWORD,ROTATED,FORCE)
	NEW SALT,HASH,NOWD,NOWS
	SET SALT=$$UUID^MIOUTIL(),HASH=$$PW(SALT,$GET(PASSWORD))
	SET NOWD=+$PIECE($HOROLOG,",",1),NOWS=+$PIECE($HOROLOG,",",2)
	SET ^MIO("MIOOS","USER",USER,"salt")=SALT
	SET ^MIO("MIOOS","USER",USER,"hash")=HASH
	SET ^MIO("MIOOS","USER",USER,"passwordChangedAt")=$$NOWISO^MIOUTIL()
	SET ^MIO("MIOOS","USER",USER,"passwordChangedDay")=NOWD
	SET ^MIO("MIOOS","USER",USER,"passwordChangedSec")=NOWS
	SET ^MIO("MIOOS","USER",USER,"passwordSource")=$SELECT(+$GET(ROTATED)=1:"local-rotated",1:"bootstrap-default")
	SET ^MIO("MIOOS","USER",USER,"passwordRotated")=+$GET(ROTATED)
	SET ^MIO("MIOOS","USER",USER,"forcePasswordChange")=+$GET(FORCE)
	QUIT
	;
VALIDATEPW(CONF,PASSWORD,OUT,ERR)
	NEW PASS,I,C,HASU,HASL,HASD,HASS,MIN
	KILL OUT,ERR
	SET ERR("routine")="MIOOSAUTH"
	SET PASS=$GET(PASSWORD)
	SET MIN=+$GET(CONF("mioos","localAuth","passwordPolicy","minLength"),12)
	IF $LENGTH(PASS)<MIN SET ERR("error")="password_policy_min_length",ERR("detail")=MIN QUIT 0
	SET (HASU,HASL,HASD,HASS)=0
	FOR I=1:1:$LENGTH(PASS) DO
	. SET C=$EXTRACT(PASS,I)
	. IF C?1U SET HASU=1 QUIT
	. IF C?1L SET HASL=1 QUIT
	. IF C?1N SET HASD=1 QUIT
	. SET HASS=1
	IF +$GET(CONF("mioos","localAuth","passwordPolicy","requireUpper"),1)=1,'HASU SET ERR("error")="password_policy_upper" QUIT 0
	IF +$GET(CONF("mioos","localAuth","passwordPolicy","requireLower"),1)=1,'HASL SET ERR("error")="password_policy_lower" QUIT 0
	IF +$GET(CONF("mioos","localAuth","passwordPolicy","requireDigit"),1)=1,'HASD SET ERR("error")="password_policy_digit" QUIT 0
	IF +$GET(CONF("mioos","localAuth","passwordPolicy","requireSymbol"),1)=1,'HASS SET ERR("error")="password_policy_symbol" QUIT 0
	SET OUT("valid")=1
	QUIT 1
	;
PWSTATUS(CONF,USER,OUT)
	NEW NOWD,DAY,AGE,MAX,WARN,FORCE,EXP,WARNF
	KILL OUT
	SET NOWD=+$PIECE($HOROLOG,",",1)
	SET DAY=+$GET(^MIO("MIOOS","USER",USER,"passwordChangedDay")) IF DAY<1 SET DAY=+$GET(^MIO("MIOOS","USER",USER,"createdDay"))
	SET AGE=$SELECT(DAY>0:NOWD-DAY,1:0)
	SET MAX=+$GET(CONF("mioos","localAuth","passwordPolicy","maxAgeDays"),90) IF MAX<0 SET MAX=0
	SET WARN=+$GET(CONF("mioos","localAuth","passwordPolicy","warnDays"),14) IF WARN<0 SET WARN=0
	SET FORCE=+$GET(^MIO("MIOOS","USER",USER,"forcePasswordChange"),0)
	SET EXP=$SELECT((MAX>0)&(AGE'<MAX):1,1:0)
	SET WARNF=$SELECT('EXP&(MAX>0)&(WARN>0)&((MAX-AGE)'>WARN):1,1:0)
	SET OUT("passwordChangedAt")=$GET(^MIO("MIOOS","USER",USER,"passwordChangedAt"))
	SET OUT("passwordAgeDays")=AGE
	SET OUT("passwordMaxAgeDays")=MAX
	SET OUT("passwordWarnDays")=WARN
	SET OUT("forcePasswordChange")=FORCE
	SET OUT("passwordExpired")=EXP
	SET OUT("passwordExpiresSoon")=WARNF
	SET OUT("requiresChange")=$SELECT(FORCE:1,EXP:1,1:0)
	SET OUT("passwordStatus")=$SELECT(FORCE:"rotation-required",EXP:"expired",WARNF:"warning",1:"healthy")
	QUIT
	;
CREDREPORT(STATE,CONF,OUT,ERR)
	NEW SCP,PRIN,USER,TMP
	KILL OUT,ERR
	SET ERR("routine")="MIOOSAUTH"
	SET SCP=$$AUTHSCOPE(.STATE),PRIN=$GET(STATE("principal"))
	SET (OUT("count"),OUT("rotationRequiredCount"),OUT("expiredCount"),OUT("warningCount"),OUT("healthyCount"))=0
	SET USER=""
	FOR  SET USER=$ORDER(^MIO("MIOOS","USER",USER)) QUIT:USER=""  DO
	. IF SCP'="all",USER'=PRIN QUIT
	. DO PWSTATUS(.CONF,USER,.TMP)
	. SET OUT("count")=OUT("count")+1
	. IF +$GET(TMP("requiresChange"))=1 SET OUT("rotationRequiredCount")=OUT("rotationRequiredCount")+1
	. IF +$GET(TMP("passwordExpired"))=1 SET OUT("expiredCount")=OUT("expiredCount")+1
	. IF +$GET(TMP("passwordExpiresSoon"))=1 SET OUT("warningCount")=OUT("warningCount")+1
	. IF $GET(TMP("passwordStatus"))="healthy" SET OUT("healthyCount")=OUT("healthyCount")+1
	QUIT 1
	;
PWPOLICY(CONF,OUT)
	KILL OUT
	SET OUT("minLength")=+$GET(CONF("mioos","localAuth","passwordPolicy","minLength"),12)
	SET OUT("requireUpper")=+$GET(CONF("mioos","localAuth","passwordPolicy","requireUpper"),1)
	SET OUT("requireLower")=+$GET(CONF("mioos","localAuth","passwordPolicy","requireLower"),1)
	SET OUT("requireDigit")=+$GET(CONF("mioos","localAuth","passwordPolicy","requireDigit"),1)
	SET OUT("requireSymbol")=+$GET(CONF("mioos","localAuth","passwordPolicy","requireSymbol"),1)
	SET OUT("maxAgeDays")=+$GET(CONF("mioos","localAuth","passwordPolicy","maxAgeDays"),90)
	SET OUT("warnDays")=+$GET(CONF("mioos","localAuth","passwordPolicy","warnDays"),14)
	SET OUT("changeTokenMinutes")=+$GET(CONF("mioos","localAuth","passwordPolicy","changeTokenMinutes"),15)
	QUIT
	;
ISSUETOKEN(CONF,USER,TOKEN,ERR)
	NEW DISPLAY,ROLES
	KILL ERR SET TOKEN=""
	SET ERR("routine")="MIOOSAUTH"
	IF '$DATA(^MIO("MIOOS","USER",USER)) SET ERR("error")="user_not_found" QUIT 0
	IF '$$USEROK(.CONF,USER,.ERR) QUIT 0
	SET DISPLAY=$GET(^MIO("MIOOS","USER",USER,"userName"))
	SET ROLES=$GET(^MIO("MIOOS","USER",USER,"roles"))
	QUIT $$ISSUE^MIOAUTHSESS(.CONF,"mioos",USER,DISPLAY,ROLES,.TOKEN,.ERR)
	;
COOKIEHDR(CONF,TOKEN,CLEAR)
	QUIT $$COOKIEHDR^MIOAUTHSESS(.CONF,"mioos",$GET(TOKEN),+$GET(CLEAR))
	;
TOKSTATUS(CONF,TOKEN,ROOT)
	NEW CLAIMS,ERR,NOW,REFRESH,EXP,REM
	KILL @ROOT
	SET NOW=$$NOW^MIOJWT()
	SET @ROOT@("now")=NOW
	SET REFRESH=+$GET(CONF("mioos","localAuth","refreshWindowSeconds"),300)
	IF REFRESH<0 SET REFRESH=0
	SET @ROOT@("refreshWindowSeconds")=REFRESH
	IF '$$VERIFYHS256^MIOJWT(.CONF,$GET(TOKEN),.CLAIMS,.ERR) DO  QUIT
	. SET @ROOT@("valid")=0
	. SET @ROOT@("error")=$GET(ERR("error"),"jwt_invalid")
	SET @ROOT@("valid")=1
	SET EXP=+$GET(CLAIMS("exp"))
	SET @ROOT@("issuedAt")=+$GET(CLAIMS("iat"))
	SET @ROOT@("expiresAt")=EXP
	SET REM=EXP-NOW
	IF REM<0 SET REM=0
	SET @ROOT@("remainingSeconds")=REM
	SET @ROOT@("needsRefresh")=$SELECT(REM'>REFRESH:1,1:0)
	QUIT
	;
USEROK(CONF,USER,ERR)
	KILL ERR
	SET ERR("routine")="MIOOSAUTH"
	IF '$DATA(^MIO("MIOOS","USER",USER)) SET ERR("error")="invalid_credentials" QUIT 0
	IF +$GET(^MIO("MIOOS","USER",USER,"enabled"),1)'=1 SET ERR("error")="account_disabled" QUIT 0
	IF $$ISLOCKED(USER) SET ERR("error")="locked_account" QUIT 0
	QUIT 1
	;
ISLOCKED(USER)
	NEW NOWD,NOWS,DAY,SEC
	SET DAY=+$GET(^MIO("MIOOS","USER",USER,"lockedUntilDay"))
	SET SEC=+$GET(^MIO("MIOOS","USER",USER,"lockedUntilSec"))
	IF DAY=0 QUIT 0
	SET NOWD=+$PIECE($HOROLOG,",",1),NOWS=+$PIECE($HOROLOG,",",2)
	IF $$AGESEC(NOWD,NOWS,DAY,SEC)>0 QUIT 1
	KILL ^MIO("MIOOS","USER",USER,"lockedUntilDay")
	KILL ^MIO("MIOOS","USER",USER,"lockedUntilSec")
	QUIT 0
	;
FAILLOGIN(CONF,USER)
	NEW FAILS,THRESH,MINS,TOT,DAY,SEC
	SET FAILS=+$GET(^MIO("MIOOS","USER",USER,"failedCount"))+1
	SET ^MIO("MIOOS","USER",USER,"failedCount")=FAILS
	SET ^MIO("MIOOS","USER",USER,"lastFailedAt")=$$NOWISO^MIOUTIL()
	SET THRESH=+$GET(CONF("mioos","localAuth","lockThreshold"),5)
	IF THRESH<1 SET THRESH=5
	IF FAILS<THRESH QUIT
	SET MINS=+$GET(CONF("mioos","localAuth","lockMinutes"),15)
	IF MINS<1 SET MINS=15
	SET TOT=(+$PIECE($HOROLOG,",",1)*86400)+$PIECE($HOROLOG,",",2)+(MINS*60)
	SET DAY=TOT\86400,SEC=TOT#86400
	SET ^MIO("MIOOS","USER",USER,"lockedUntilDay")=DAY
	SET ^MIO("MIOOS","USER",USER,"lockedUntilSec")=SEC
	DO AUDLOG(.CONF,"local_account_locked",USER,"lock_threshold","denied","local")
	QUIT
	;
CLEARRISK(USER)
	SET ^MIO("MIOOS","USER",USER,"failedCount")=0
	KILL ^MIO("MIOOS","USER",USER,"lockedUntilDay")
	KILL ^MIO("MIOOS","USER",USER,"lockedUntilSec")
	QUIT
	;
TITLE(X)
	NEW Y,I,C,OUT
	SET Y=$$LOW^MIOUTIL($GET(X)),OUT=""
	FOR I=1:1:$LENGTH(Y) DO
	. SET C=$EXTRACT(Y,I)
	. IF I=1,$ASCII(C)>96,$ASCII(C)<123 SET C=$CHAR($ASCII(C)-32)
	. SET OUT=OUT_C
	QUIT OUT
	;
VALIDUSER(USER)
	NEW I,C,OK
	IF $LENGTH($GET(USER))<3 QUIT 0
	IF $LENGTH($GET(USER))>64 QUIT 0
	SET OK=1
	FOR I=1:1:$LENGTH(USER) DO  QUIT:'OK
	. SET C=$EXTRACT(USER,I)
	. IF (C?1AN)!(C="_")!(C="-")!(C=".") QUIT
	. SET OK=0
	QUIT OK
	;
CANON(USER)
	QUIT $$LOW^MIOUTIL($$TRIM^MIOUTIL($GET(USER)))
	;
PW(SALT,PASSWORD)
	QUIT $$SHA256^MIOSHA256($GET(SALT)_":"_$GET(PASSWORD))
	;
AGESEC(D1,S1,D2,S2)
	IF (+$GET(D1)=0),(+$GET(S1)=0) QUIT 999999999
	QUIT (((+$GET(D2)-+$GET(D1))*86400)+(+$GET(S2)-+$GET(S1)))
	;
AUDLOG(CONF,EVENT,USER,DETAIL,OUTCOME,PROVIDER)
	NEW STATE,CTX
	DO AUDSTATE(.CONF,$GET(USER),.CTX,.STATE)
	DO EVENT^MIOOSAUD($GET(EVENT),.CTX,.STATE,$GET(DETAIL),$GET(OUTCOME),$GET(USER),$GET(PROVIDER))
	QUIT
	;
AUDSTATE(CONF,USER,CTX,STATE)
	KILL STATE
	SET STATE("principal")=$GET(USER)
	SET STATE("sessionId")=$GET(CTX("auth","claims","sid"))
	SET STATE("profile")=$SELECT($GET(CONF("mioos","profile"))'="":$GET(CONF("mioos","profile")),1:"prod")
	QUIT
	;
SESSIONS(STATE,CONF,LIMIT,OUT,ERR)
	NEW MAX,SCP,PRIN,SID,N,USER
	KILL OUT,ERR
	SET ERR("routine")="MIOOSAUTH"
	SET MAX=+$GET(LIMIT,+$GET(CONF("mioos","auth","management","sessionLimit"),20))
	IF MAX<1 SET MAX=20
	SET SCP=$$AUTHSCOPE(.STATE),PRIN=$GET(STATE("principal"))
	SET OUT("scope")=SCP
	SET OUT("principal")=PRIN
	SET OUT("limit")=MAX
	SET (N,OUT("count"),OUT("activeCount"),OUT("revokableCount"))=0
	SET SID=""
	FOR  SET SID=$ORDER(^MIO("AUTH","SESSION","mioos",SID)) QUIT:SID=""  DO  QUIT:N'<MAX
	. IF '$DATA(^MIO("AUTH","SESSION","mioos",SID)) QUIT
	. SET USER=$GET(^MIO("AUTH","SESSION","mioos",SID,"principal"))
	. IF USER="" QUIT
	. IF SCP'="all",USER'=PRIN QUIT
	. SET N=N+1
	. DO SESSIONROW(.STATE,SID,$NAME(OUT("entries",N)))
	. SET OUT("count")=N,OUT("activeCount")=N
	. IF +$GET(OUT("entries",N,"revokeAllowed"))=1 SET OUT("revokableCount")=OUT("revokableCount")+1
	QUIT 1
	;
SESSIONROW(STATE,SID,ROOT)
	NEW USER
	SET USER=$GET(^MIO("AUTH","SESSION","mioos",SID,"principal"))
	SET @ROOT@("sessionId")=SID
	SET @ROOT@("principal")=USER
	SET @ROOT@("userName")=$GET(^MIO("AUTH","SESSION","mioos",SID,"userName"))
	SET @ROOT@("roles")=$GET(^MIO("AUTH","SESSION","mioos",SID,"roles"))
	SET @ROOT@("createdAt")=$GET(^MIO("AUTH","SESSION","mioos",SID,"createdAt"))
	SET @ROOT@("lastSeenAt")=$GET(^MIO("AUTH","SESSION","mioos",SID,"lastSeenAt"))
	SET @ROOT@("tokenIssuedAt")=$GET(^MIO("AUTH","SESSION","mioos",SID,"tokenIssuedAt"))
	SET @ROOT@("current")=$SELECT($GET(STATE("sessionId"))=$GET(SID):1,1:0)
	SET @ROOT@("revokeAllowed")=$$SESSALLOW(.STATE,$GET(SID))
	QUIT
	;
REVOKESESSION(STATE,CONF,SID,OUT,ERR)
	NEW USER,ACTOR,CTX,AUD
	KILL OUT,ERR
	SET ERR("routine")="MIOOSAUTH"
	SET SID=$GET(SID)
	IF SID="" SET ERR("error")="session_missing" QUIT 0
	IF '$DATA(^MIO("AUTH","SESSION","mioos",SID)) SET ERR("error")="session_not_found" QUIT 0
	IF '$$SESSALLOW(.STATE,SID) SET ERR("error")="access_denied" QUIT 0
	SET USER=$GET(^MIO("AUTH","SESSION","mioos",SID,"principal"))
	DO REVOKESID^MIOAUTHSESS("mioos",SID)
	SET OUT("revoked")=1
	SET OUT("sessionId")=SID
	SET OUT("principal")=USER
	SET OUT("current")=$SELECT($GET(STATE("sessionId"))=$GET(SID):1,1:0)
	SET ACTOR=$GET(STATE("principal"))
	DO AUDSTATE(.CONF,ACTOR,.CTX,.AUD)
	DO EVENT^MIOOSAUD($SELECT(ACTOR=USER:"self_session_revoked",1:"admin_session_revoked"),.CTX,.AUD,"sid="_SID,"success",USER,"framework")
	QUIT 1
	;
ACCOUNTS(STATE,CONF,LIMIT,OUT,ERR)
	NEW MAX,SCP,PRIN,USER,N
	KILL OUT,ERR
	SET ERR("routine")="MIOOSAUTH"
	SET MAX=+$GET(LIMIT,+$GET(CONF("mioos","auth","management","accountLimit"),20))
	IF MAX<1 SET MAX=20
	SET SCP=$$AUTHSCOPE(.STATE),PRIN=$GET(STATE("principal"))
	SET OUT("scope")=SCP
	SET OUT("principal")=PRIN
	SET OUT("limit")=MAX
	SET (N,OUT("count"),OUT("lockedCount"),OUT("disabledCount"),OUT("rotationRequiredCount"),OUT("expiredCount"),OUT("warningCount"))=0
	IF SCP="all" DO
	. SET USER=""
	. FOR  SET USER=$ORDER(^MIO("MIOOS","USER",USER)) QUIT:USER=""  DO  QUIT:N'<MAX
	. . SET N=N+1
	. . DO ACCOUNTROW(.STATE,.CONF,USER,$NAME(OUT("entries",N)))
	. . SET OUT("count")=N
	. . IF +$GET(OUT("entries",N,"locked"))=1 SET OUT("lockedCount")=OUT("lockedCount")+1
	. . IF +$GET(OUT("entries",N,"enabled"))'=1 SET OUT("disabledCount")=OUT("disabledCount")+1
	. . IF +$GET(OUT("entries",N,"requiresChange"))=1 SET OUT("rotationRequiredCount")=OUT("rotationRequiredCount")+1
	. . IF +$GET(OUT("entries",N,"passwordExpired"))=1 SET OUT("expiredCount")=OUT("expiredCount")+1
	. . IF +$GET(OUT("entries",N,"passwordExpiresSoon"))=1 SET OUT("warningCount")=OUT("warningCount")+1
	ELSE  IF PRIN'="",$DATA(^MIO("MIOOS","USER",PRIN)) DO
	. SET N=1,OUT("count")=1
	. DO ACCOUNTROW(.STATE,.CONF,PRIN,$NAME(OUT("entries",1)))
	. IF +$GET(OUT("entries",1,"locked"))=1 SET OUT("lockedCount")=1
	. IF +$GET(OUT("entries",1,"enabled"))'=1 SET OUT("disabledCount")=1
	. IF +$GET(OUT("entries",1,"requiresChange"))=1 SET OUT("rotationRequiredCount")=1
	. IF +$GET(OUT("entries",1,"passwordExpired"))=1 SET OUT("expiredCount")=1
	. IF +$GET(OUT("entries",1,"passwordExpiresSoon"))=1 SET OUT("warningCount")=1
	QUIT 1
	;
ACCOUNTROW(STATE,CONF,USER,ROOT)
	NEW PWD
	SET @ROOT@("username")=$GET(USER)
	SET @ROOT@("displayName")=$GET(^MIO("MIOOS","USER",USER,"userName"))
	SET @ROOT@("roles")=$GET(^MIO("MIOOS","USER",USER,"roles"))
	SET @ROOT@("enabled")=+$GET(^MIO("MIOOS","USER",USER,"enabled"),1)
	SET @ROOT@("failedCount")=+$GET(^MIO("MIOOS","USER",USER,"failedCount"))
	SET @ROOT@("locked")=$$ISLOCKED(USER)
	SET @ROOT@("lastFailedAt")=$GET(^MIO("MIOOS","USER",USER,"lastFailedAt"))
	SET @ROOT@("source")=$GET(^MIO("MIOOS","USER",USER,"source"))
	DO PWSTATUS(.CONF,USER,.PWD)
	SET @ROOT@("passwordChangedAt")=$GET(PWD("passwordChangedAt"))
	SET @ROOT@("passwordAgeDays")=+$GET(PWD("passwordAgeDays"))
	SET @ROOT@("passwordMaxAgeDays")=+$GET(PWD("passwordMaxAgeDays"))
	SET @ROOT@("passwordWarnDays")=+$GET(PWD("passwordWarnDays"))
	SET @ROOT@("forcePasswordChange")=+$GET(PWD("forcePasswordChange"))
	SET @ROOT@("passwordExpired")=+$GET(PWD("passwordExpired"))
	SET @ROOT@("passwordExpiresSoon")=+$GET(PWD("passwordExpiresSoon"))
	SET @ROOT@("requiresChange")=+$GET(PWD("requiresChange"))
	SET @ROOT@("passwordStatus")=$GET(PWD("passwordStatus"))
	SET @ROOT@("unlockAllowed")=$SELECT(+$GET(STATE("authAdmin"),0)=1:1,1:0)
	QUIT
	;
UNLOCKUSER(STATE,CONF,USER,OUT,ERR)
	NEW ACTOR,CTX,AUD
	KILL OUT,ERR
	SET ERR("routine")="MIOOSAUTH"
	SET USER=$$CANON($GET(USER))
	IF USER="" SET ERR("error")="username_missing" QUIT 0
	IF +$GET(STATE("authAdmin"),0)'=1 SET ERR("error")="access_denied" QUIT 0
	IF '$DATA(^MIO("MIOOS","USER",USER)) SET ERR("error")="user_not_found" QUIT 0
	DO CLEARRISK(USER)
	SET OUT("unlocked")=1
	SET OUT("username")=USER
	SET OUT("locked")=$$ISLOCKED(USER)
	SET OUT("failedCount")=+$GET(^MIO("MIOOS","USER",USER,"failedCount"))
	SET ACTOR=$GET(STATE("principal"))
	DO AUDSTATE(.CONF,ACTOR,.CTX,.AUD)
	DO EVENT^MIOOSAUD("admin_user_unlocked",.CTX,.AUD,"unlock="_USER,"success",USER,"local")
	QUIT 1
	;
AUTHSCOPE(STATE)
	QUIT $$SCOPE^MIOOSAUD(.STATE)
	;
SESSALLOW(STATE,SID)
	NEW USER
	IF +$GET(STATE("authAdmin"),0)=1 QUIT 1
	SET USER=$GET(^MIO("AUTH","SESSION","mioos",$GET(SID),"principal"))
	QUIT $SELECT(USER=$GET(STATE("principal")):1,1:0)
	;
	;