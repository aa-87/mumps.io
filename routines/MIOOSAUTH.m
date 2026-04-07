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
	NEW USER,DISPLAY,PASS,ROLES,SALT,HASH,NOWD,NOWS,ENABLED,APPLY,SRC,OLDP
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
	SET ROLES=$GET(CONF("mioos","bootstrapAuth",PERSONA,"roles")) IF ROLES="" SET ROLES=$SELECT(PERSONA="admin":"admin",PERSONA="user":"operator",1:"guest")
	SET ENABLED=+$GET(CONF("mioos","bootstrapAuth",PERSONA,"enabled"),1)
	SET SALT=$$UUID^MIOUTIL()
	SET HASH=$$PW(SALT,PASS)
	SET NOWD=+$PIECE($HOROLOG,",",1),NOWS=+$PIECE($HOROLOG,",",2)
	SET ^MIO("MIOOS","USER",USER)="user"
	SET ^MIO("MIOOS","USER",USER,"principal")=USER
	SET ^MIO("MIOOS","USER",USER,"userName")=DISPLAY
	SET ^MIO("MIOOS","USER",USER,"roles")=ROLES
	SET ^MIO("MIOOS","USER",USER,"salt")=SALT
	SET ^MIO("MIOOS","USER",USER,"hash")=HASH
	SET ^MIO("MIOOS","USER",USER,"enabled")=ENABLED
	SET ^MIO("MIOOS","USER",USER,"failedCount")=0
	KILL ^MIO("MIOOS","USER",USER,"lockedUntilDay")
	KILL ^MIO("MIOOS","USER",USER,"lockedUntilSec")
	KILL ^MIO("MIOOS","USER",USER,"lastFailedAt")
	IF '$DATA(^MIO("MIOOS","USER",USER,"createdAt")) DO
	. SET ^MIO("MIOOS","USER",USER,"createdAt")=$$NOWISO^MIOUTIL()
	. SET ^MIO("MIOOS","USER",USER,"createdDay")=NOWD
	. SET ^MIO("MIOOS","USER",USER,"createdSec")=NOWS
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
	NEW USER,SALT,HASH,OK
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
	IF $$AGESEC(DAY,SEC,NOWD,NOWS)>0 QUIT 1
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
