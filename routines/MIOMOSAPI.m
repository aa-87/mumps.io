MIOMOSAPI ; MIOMOS API routes
	QUIT
	;
BOOTSTRAP(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,OBJ
	IF '$$ENSURE^MIOMOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. IF $GET(ERR("error"))="login_required" DO  QUIT
	. . DO RESPERR(.DEV,.CONF,401,"login_required","login_required",.CTX)
	. DO ERROR^MIOMOSOBS("bootstrap_session_error",$GET(ERR("error")),.CTX,.STATE,$GET(ERR("error")))
	. DO RESPERR(.DEV,.CONF,500,"session_error",$GET(ERR("error")),.CTX)
	DO BOOTARY^MIOMOSST(.STATE,.CONF,.OBJ)
	SET OBJ("ok")=1
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	DO EVENT^MIOMOSAUD("bootstrap",.CTX,.STATE)
	DO ACCESS^MIOMOSOBS("bootstrap",.CTX,.STATE)
	QUIT
	;
SETTHEME(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,TREE,KEY,OBJ
	IF '$$ENSURE^MIOMOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,401,"login_required",$GET(ERR("error")),.CTX)
	IF '$$HAS^MIOMOSPERM(.STATE,"theme.self") DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"forbidden","theme.self",.CTX)
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	SET KEY=$GET(TREE("themeKey"))
	IF '$$SAVE^MIOMOSTH($GET(STATE("principal")),KEY,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"theme_invalid",$GET(ERR("error")),.CTX)
	SET OBJ("ok")=1,OBJ("themeKey")=KEY
	DO PUTOBJ^MIOMOSTH($NAME(OBJ("theme")),KEY)
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	DO EVENTX^MIOMOSAUD("theme_update",.CTX,.STATE,KEY)
	DO ACCESS^MIOMOSOBS("theme_update",.CTX,.STATE)
	QUIT
	;
SIGNUP(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,TOKEN,OBJ,HEAD,JSON,STATE
	IF '$$ALLOWSIGNUP^MIOMOSAUTH(.CONF) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"signup_disabled","signup_disabled",.CTX)
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$SIGNUP^MIOMOSAUTH(.CONF,$GET(TREE("username")),$GET(TREE("password")),$GET(TREE("displayName")),"",.TOKEN,.ERR,$GET(TREE("inviteToken")))=0 DO  QUIT
	. DO ERROR^MIOMOSOBS("auth_signup_error",$GET(ERR("error")),.CTX,.STATE,$GET(ERR("error")))
	. DO RESPERR(.DEV,.CONF,400,"signup_failed",$GET(ERR("error")),.CTX)
	SET OBJ("ok")=1,OBJ("tokenIssued")=1,OBJ("username")=$$CANON^MIOMOSAUTH($GET(TREE("username")))
	SET JSON=$$EN^MIOJSON1(.OBJ)
	SET HEAD("Content-Type")="application/json; charset=utf-8"
	SET HEAD("Set-Cookie")=$$COOKIEHDR(.CONF,TOKEN,0)
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,JSON,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	SET STATE("principal")=$$CANON^MIOMOSAUTH($GET(TREE("username")))
	SET STATE("sessionId")="pending",STATE("profile")="signup"
	DO EVENTX^MIOMOSAUD("auth_signup",.CTX,.STATE,$GET(TREE("username")))
	DO ACCESS^MIOMOSOBS("auth_signup",.CTX,.STATE)
	QUIT
	;
SIGNIN(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,TOKEN,OBJ,HEAD,JSON,STATE,USER
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$SIGNIN^MIOMOSAUTH(.CONF,$GET(TREE("username")),$GET(TREE("password")),.TOKEN,.ERR)=0 DO  QUIT
	. DO ERROR^MIOMOSOBS("auth_signin_error",$GET(ERR("error")),.CTX,.STATE,$GET(ERR("error")))
	. DO RESPERR(.DEV,.CONF,401,"signin_failed",$GET(ERR("error")),.CTX)
	SET USER=$$CANON^MIOMOSAUTH($GET(TREE("username")))
	SET OBJ("ok")=1,OBJ("tokenIssued")=1,OBJ("username")=USER
	SET JSON=$$EN^MIOJSON1(.OBJ)
	SET HEAD("Content-Type")="application/json; charset=utf-8"
	SET HEAD("Set-Cookie")=$$COOKIEHDR(.CONF,TOKEN,0)
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,JSON,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	SET STATE("principal")=USER,STATE("sessionId")="pending",STATE("profile")="signin"
	DO EVENTX^MIOMOSAUD("auth_signin",.CTX,.STATE,USER)
	DO ACCESS^MIOMOSOBS("auth_signin",.CTX,.STATE)
	QUIT
	;
SIGNOUT(DEV,CONF,REQ,CTX)
	NEW OBJ,HEAD,JSON,STATE
	DO SIGNOUT^MIOMOSAUTH(.CONF,.REQ,.CTX)
	SET OBJ("ok")=1,OBJ("signedOut")=1
	SET JSON=$$EN^MIOJSON1(.OBJ)
	SET HEAD("Content-Type")="application/json; charset=utf-8"
	SET HEAD("Set-Cookie")=$$COOKIEHDR(.CONF,"",1)
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,JSON,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	SET STATE("principal")=$GET(CTX("auth","claims","sub")),STATE("sessionId")=$GET(CTX("miomos","sessionId"))
	DO EVENTX^MIOMOSAUD("auth_signout",.CTX,.STATE,"")
	DO ACCESS^MIOMOSOBS("auth_signout",.CTX,.STATE)
	QUIT
	;
RESETAPPLY(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,OBJ,STATE
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$APPLYRESET^MIOMOSAUTH(.CONF,$GET(TREE("resetToken")),$GET(TREE("password")),.ERR) DO  QUIT
	. DO ERROR^MIOMOSOBS("auth_reset_apply_error",$GET(ERR("error")),.CTX,.STATE,$GET(ERR("error")))
	. DO RESPERR(.DEV,.CONF,400,"reset_failed",$GET(ERR("error")),.CTX)
	SET OBJ("ok")=1,OBJ("resetApplied")=1
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	SET STATE("profile")="reset",STATE("sessionId")="pending"
	DO EVENTX^MIOMOSAUD("auth_reset_apply",.CTX,.STATE,$GET(TREE("resetToken")))
	DO ACCESS^MIOMOSOBS("auth_reset_apply",.CTX,.STATE)
	QUIT
	;
ADMINUSERS(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,OBJ
	IF '$$ENSURE^MIOMOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,401,"login_required",$GET(ERR("error")),.CTX)
	IF '$$HAS^MIOMOSPERM(.STATE,"admin.users.view") DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"forbidden","admin.users.view",.CTX)
	NEW CNT,USR,INV,RST
	DO COUNTS^MIOMOSADMIN(.CNT)
	MERGE OBJ("counts")=CNT
	DO USERLIST^MIOMOSADMIN(20,.USR)
	MERGE OBJ("users")=USR
	DO INVITELIST^MIOMOSADMIN(8,.INV)
	MERGE OBJ("invites")=INV
	DO RESETLIST^MIOMOSADMIN(8,.RST)
	MERGE OBJ("resets")=RST
	SET OBJ("ok")=1
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	DO EVENT^MIOMOSAUD("admin_users_view",.CTX,.STATE)
	DO ACCESS^MIOMOSOBS("admin_users_view",.CTX,.STATE)
	QUIT
	;
ADMINDISABLE(DEV,CONF,REQ,CTX)
	DO ADMINUSERACTION(.DEV,.CONF,.REQ,.CTX,"disable")
	QUIT
	;
ADMINENABLE(DEV,CONF,REQ,CTX)
	DO ADMINUSERACTION(.DEV,.CONF,.REQ,.CTX,"enable")
	QUIT
	;
ADMINLOCK(DEV,CONF,REQ,CTX)
	DO ADMINUSERACTION(.DEV,.CONF,.REQ,.CTX,"lock")
	QUIT
	;
ADMINUNLOCK(DEV,CONF,REQ,CTX)
	DO ADMINUSERACTION(.DEV,.CONF,.REQ,.CTX,"unlock")
	QUIT
	;
ADMINUSERACTION(DEV,CONF,REQ,CTX,ACTION)
	NEW STATE,ERR,TREE,USER,OBJ,OK,MINUTES
	IF '$$ENSURE^MIOMOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,401,"login_required",$GET(ERR("error")),.CTX)
	IF '$$HAS^MIOMOSPERM(.STATE,"admin.users.manage") DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"forbidden","admin.users.manage",.CTX)
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	SET USER=$$CANON^MIOMOSAUTH($GET(TREE("username")))
	SET OK=0
	IF ACTION="disable" SET OK=$$DISABLE^MIOMOSAUTH(USER)
	IF ACTION="enable" SET OK=$$ENABLE^MIOMOSAUTH(USER)
	IF ACTION="unlock" SET OK=$$UNLOCK^MIOMOSAUTH(USER)
	IF ACTION="lock" DO
	. SET MINUTES=+$GET(TREE("minutes"))
	. SET OK=$$LOCK^MIOMOSAUTH(.CONF,USER,MINUTES)
	IF 'OK DO  QUIT
	. DO RESPERR(.DEV,.CONF,404,"user_not_found",USER,.CTX)
	SET OBJ("ok")=1,OBJ("action")=ACTION,OBJ("username")=USER
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	DO EVENTX^MIOMOSAUD("admin_user_"_ACTION,.CTX,.STATE,USER)
	DO ACCESS^MIOMOSOBS("admin_user_"_ACTION,.CTX,.STATE)
	QUIT
	;
ADMININVITE(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,TREE,OBJ,TOKEN,ROLES,LABEL
	IF '$$ENSURE^MIOMOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,401,"login_required",$GET(ERR("error")),.CTX)
	IF '$$HAS^MIOMOSPERM(.STATE,"admin.invites.manage") DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"forbidden","admin.invites.manage",.CTX)
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	SET ROLES=$GET(TREE("roles")) IF ROLES="" SET ROLES="operator"
	SET LABEL=$GET(TREE("label"))
	IF '$$CREATEINVITE^MIOMOSAUTH(.CONF,$GET(STATE("principal")),ROLES,LABEL,.TOKEN,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invite_failed",$GET(ERR("error")),.CTX)
	SET OBJ("ok")=1,OBJ("inviteToken")=TOKEN,OBJ("roles")=ROLES,OBJ("label")=LABEL
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	DO EVENTX^MIOMOSAUD("admin_invite_create",.CTX,.STATE,TOKEN)
	DO ACCESS^MIOMOSOBS("admin_invite_create",.CTX,.STATE)
	QUIT
	;
ADMININVITES(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,OBJ
	IF '$$ENSURE^MIOMOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,401,"login_required",$GET(ERR("error")),.CTX)
	IF '$$HAS^MIOMOSPERM(.STATE,"admin.invites.manage") DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"forbidden","admin.invites.manage",.CTX)
	NEW INV
	DO INVITELIST^MIOMOSADMIN(12,.INV)
	MERGE OBJ("invites")=INV
	SET OBJ("ok")=1
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	DO EVENT^MIOMOSAUD("admin_invites_view",.CTX,.STATE)
	DO ACCESS^MIOMOSOBS("admin_invites_view",.CTX,.STATE)
	QUIT
	;
ADMINRESETREQUEST(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,TREE,OBJ,TOKEN,USER
	IF '$$ENSURE^MIOMOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,401,"login_required",$GET(ERR("error")),.CTX)
	IF '$$HAS^MIOMOSPERM(.STATE,"admin.reset.manage") DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"forbidden","admin.reset.manage",.CTX)
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	SET USER=$$CANON^MIOMOSAUTH($GET(TREE("username")))
	IF '$$REQUESTRESET^MIOMOSAUTH(.CONF,$GET(STATE("principal")),USER,.TOKEN,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"reset_request_failed",$GET(ERR("error")),.CTX)
	SET OBJ("ok")=1,OBJ("resetToken")=TOKEN,OBJ("username")=USER
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	DO EVENTX^MIOMOSAUD("admin_reset_request",.CTX,.STATE,USER)
	DO ACCESS^MIOMOSOBS("admin_reset_request",.CTX,.STATE)
	QUIT
	;

OBSSUMMARY(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,OBJ
	IF '$$ENSURE^MIOMOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,401,"login_required",$GET(ERR("error")),.CTX)
	IF '$$HAS^MIOMOSPERM(.STATE,"logs.view") DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"forbidden","logs.view",.CTX)
	DO SUMMARY^MIOMOSOBS(.STATE,.CONF,.OBJ)
	SET OBJ("ok")=1
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	DO EVENT^MIOMOSAUD("observ_summary_view",.CTX,.STATE)
	DO ACCESS^MIOMOSOBS("observ_summary_view",.CTX,.STATE)
	QUIT
	;
ACCESSX(DEV,CONF,REQ,CTX)
	DO OBSX(.DEV,.CONF,.REQ,.CTX,"ACCESS","logs.export")
	QUIT
	;
ERRORX(DEV,CONF,REQ,CTX)
	DO OBSX(.DEV,.CONF,.REQ,.CTX,"ERROR","logs.export")
	QUIT
	;
AUDITX(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,OBJ,LIMIT,ARR
	IF '$$ENSURE^MIOMOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,401,"login_required",$GET(ERR("error")),.CTX)
	IF '$$HAS^MIOMOSPERM(.STATE,"audit.export") DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"forbidden","audit.export",.CTX)
	SET LIMIT=+$GET(CONF("miomos","log","exportLimit"),250) IF LIMIT<1 SET LIMIT=250
	DO EXPORT^MIOMOSAUD(LIMIT,.ARR)
	SET OBJ("ok")=1,OBJ("type")="AUDIT",OBJ("limit")=LIMIT
	MERGE OBJ("entries")=ARR
	DO RESPJSONDL(.DEV,.CONF,.OBJ,"miomos-audit-export.json",.CTX)
	SET CTX("status")=200
	DO EVENT^MIOMOSAUD("audit_export",.CTX,.STATE)
	DO ACCESS^MIOMOSOBS("audit_export",.CTX,.STATE)
	QUIT
	;
OBSX(DEV,CONF,REQ,CTX,TYPE,PERM)
	NEW STATE,ERR,OBJ,LIMIT,ARR,FN
	IF '$$ENSURE^MIOMOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,401,"login_required",$GET(ERR("error")),.CTX)
	IF '$$HAS^MIOMOSPERM(.STATE,$GET(PERM)) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"forbidden",$GET(PERM),.CTX)
	SET LIMIT=+$GET(CONF("miomos","log","exportLimit"),250) IF LIMIT<1 SET LIMIT=250
	DO EXPORT^MIOMOSOBS($GET(TYPE),LIMIT,.ARR)
	SET OBJ("ok")=1,OBJ("type")=$GET(TYPE),OBJ("limit")=LIMIT
	MERGE OBJ("entries")=ARR
	SET FN="miomos-"_$ZCONVERT($GET(TYPE),"L")_"-export.json"
	DO RESPJSONDL(.DEV,.CONF,.OBJ,FN,.CTX)
	SET CTX("status")=200
	DO EVENTX^MIOMOSAUD("log_export",.CTX,.STATE,$GET(TYPE))
	DO ACCESS^MIOMOSOBS("log_export",.CTX,.STATE)
	QUIT
	;
DIGEST(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,HEAD,TXT
	IF '$$ENSURE^MIOMOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,401,"login_required",$GET(ERR("error")),.CTX)
	IF '$$HAS^MIOMOSPERM(.STATE,"digest.export") DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"forbidden","digest.export",.CTX)
	SET TXT=$$DIGESTTXT(.STATE,.CONF)
	SET HEAD("Content-Type")="text/plain; charset=utf-8"
	SET HEAD("Content-Disposition")="attachment; filename=miomos-security-digest.txt"
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,TXT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	DO EVENT^MIOMOSAUD("security_digest_download",.CTX,.STATE)
	DO ACCESS^MIOMOSOBS("security_digest_download",.CTX,.STATE)
	QUIT
	;
PRUNERET(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,TREE,OBJ,KEEP,DAYS,ACCRES,ERRRES,AUDRES,SUMMARY
	IF '$$ENSURE^MIOMOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,401,"login_required",$GET(ERR("error")),.CTX)
	IF '$$HAS^MIOMOSPERM(.STATE,"retention.manage") DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"forbidden","retention.manage",.CTX)
	IF $$BODYTXT(.REQ)'="" IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	SET KEEP("ACCESS")=$SELECT($GET(TREE("accessKeep"))'="":+$GET(TREE("accessKeep")),1:+$GET(CONF("miomos","log","maxEntries"),500))
	SET KEEP("ERROR")=$SELECT($GET(TREE("errorKeep"))'="":+$GET(TREE("errorKeep")),1:+$GET(CONF("miomos","log","maxEntries"),500))
	SET KEEP("AUDIT")=$SELECT($GET(TREE("auditKeep"))'="":+$GET(TREE("auditKeep")),1:+$GET(CONF("miomos","log","maxEntries"),500))
	SET DAYS("ACCESS")=$SELECT($GET(TREE("accessDays"))'="":+$GET(TREE("accessDays")),1:+$GET(CONF("miomos","log","access","retainDays"),30))
	SET DAYS("ERROR")=$SELECT($GET(TREE("errorDays"))'="":+$GET(TREE("errorDays")),1:+$GET(CONF("miomos","log","error","retainDays"),90))
	SET DAYS("AUDIT")=$SELECT($GET(TREE("auditDays"))'="":+$GET(TREE("auditDays")),1:+$GET(CONF("miomos","audit","retainDays"),180))
	DO PRUNE^MIOMOSOBS("ACCESS",KEEP("ACCESS"),DAYS("ACCESS"),.ACCRES)
	DO PRUNE^MIOMOSOBS("ERROR",KEEP("ERROR"),DAYS("ERROR"),.ERRRES)
	DO PRUNE^MIOMOSAUD(KEEP("AUDIT"),DAYS("AUDIT"),.AUDRES)
	MERGE OBJ("access")=ACCRES
	MERGE OBJ("error")=ERRRES
	MERGE OBJ("audit")=AUDRES
	SET OBJ("ok")=1
	DO SUMMARY^MIOMOSOBS(.STATE,.CONF,.SUMMARY)
	MERGE OBJ("summary")=SUMMARY
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	DO EVENT^MIOMOSAUD("retention_prune",.CTX,.STATE)
	DO ACCESS^MIOMOSOBS("retention_prune",.CTX,.STATE)
	QUIT
RESPJSONDL(DEV,CONF,OBJ,FN,CTX)
	NEW HEAD,JSON
	SET JSON=$$EN^MIOJSON1(.OBJ)
	SET HEAD("Content-Type")="application/json; charset=utf-8"
	SET HEAD("Content-Disposition")="attachment; filename="_$GET(FN,"miomos-export.json")
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,JSON,$GET(CTX("request_id")),.CTX)
	QUIT
	;
DIGESTTXT(STATE,CONF)
	NEW CNT,AUD,ERRS,ACC,TXT,I,LIM
	DO COUNTS^MIOMOSOBS(.CNT)
	SET TXT="MIOMOS security digest"_$CHAR(10)
	SET TXT=TXT_"Profile: "_$GET(STATE("profile"))_$CHAR(10)
	SET TXT=TXT_"Session: "_$GET(STATE("sessionId"))_$CHAR(10)
	SET TXT=TXT_"Counts: access="_+$GET(CNT("access"))_" error="_+$GET(CNT("error"))_" audit="_+$GET(CNT("audit"))_$CHAR(10)
	SET TXT=TXT_"Retention days: access="_+$GET(CONF("miomos","log","access","retainDays"),30)_" error="_+$GET(CONF("miomos","log","error","retainDays"),90)_" audit="_+$GET(CONF("miomos","audit","retainDays"),180)_$CHAR(10,10)
	SET LIM=+$GET(CONF("miomos","log","digestTail"),6) IF LIM<1 SET LIM=6
	DO TAIL^MIOMOSOBS("ACCESS",LIM,.ACC)
	SET TXT=TXT_"Recent access"_$CHAR(10)
	FOR I=1:1:$ORDER(ACC(""),-1) SET TXT=TXT_"- "_$GET(ACC(I,"ts"))_" | "_$GET(ACC(I,"event"))_" | corr="_$GET(ACC(I,"correlationId"))_$CHAR(10)
	DO TAIL^MIOMOSOBS("ERROR",LIM,.ERRS)
	SET TXT=TXT_$CHAR(10)_"Recent errors"_$CHAR(10)
	FOR I=1:1:$ORDER(ERRS(""),-1) SET TXT=TXT_"- "_$GET(ERRS(I,"ts"))_" | "_$GET(ERRS(I,"event"))_" | "_$GET(ERRS(I,"code"))_" | corr="_$GET(ERRS(I,"correlationId"))_$CHAR(10)
	DO TAIL^MIOMOSAUD(LIM,.AUD)
	SET TXT=TXT_$CHAR(10)_"Recent audit"_$CHAR(10)
	FOR I=1:1:$ORDER(AUD(""),-1) SET TXT=TXT_"- "_$GET(AUD(I,"ts"))_" | "_$GET(AUD(I,"event"))_" | corr="_$GET(AUD(I,"correlationId"))_$CHAR(10)
	QUIT TXT
	;
PARSEBODY(REQ,TREE,ERR)
	NEW JSON
	SET JSON=$$BODYTXT(.REQ)
	IF JSON="" SET ERR("routine")="MIOMOSAPI",ERR("error")="body_missing" QUIT 0
	IF '$$DECODE^MIOJSON(JSON,.TREE,.ERR) SET ERR("routine")="MIOMOSAPI" QUIT 0
	QUIT 1
	;
BODYTXT(REQ)
	NEW MODE,REF,N,I,TXT
	SET MODE=$GET(REQ("body","mode"),"scalar")
	IF MODE="scalar" QUIT $GET(REQ("body"))
	IF MODE'="global" QUIT ""
	SET REF=$GET(REQ("body","ref"))
	IF REF="" QUIT ""
	SET N=+$GET(REQ("body","n")),TXT=""
	FOR I=1:1:N SET TXT=TXT_$GET(@REF@(I))
	QUIT TXT
	;
COOKIEHDR(CONF,TOKEN,CLEAR)
	NEW NAME,OUT,MAXAGE
	SET NAME=$GET(CONF("miomos","localAuth","tokenCookie"),"miomos_auth")
	SET MAXAGE=+$GET(CONF("miomos","localAuth","tokenMaxAgeSeconds"),604800)
	IF +$GET(CLEAR)=1 QUIT NAME_"=; Path=/; Max-Age=0; HttpOnly; SameSite=Lax"
	SET OUT=NAME_"="_$GET(TOKEN)_"; Path=/; Max-Age="_MAXAGE_"; HttpOnly; SameSite=Lax"
	QUIT OUT
	;
RESPERR(DEV,CONF,STATUS,CODE,DETAIL,CTX)
	NEW OBJ
	SET OBJ("routine")="MIOMOSAPI"
	SET OBJ("error")=$GET(CODE,"miomos_api_error")
	SET OBJ("detail")=$GET(DETAIL)
	SET OBJ("request_id")=$GET(CTX("request_id"))
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,+$GET(STATUS,500),.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=+$GET(STATUS,500)
	QUIT
	;
