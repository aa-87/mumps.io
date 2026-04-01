MIOOSAPI ; MIOOS API routes
	QUIT
	;
BOOTSTRAP(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,OBJ
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"bootstrap_state_error",$GET(ERR("error"),"bootstrap_state_error"),.CTX)
	DO BOOTARY^MIOOSST(.STATE,.CONF,.OBJ)
	SET OBJ("ok")=1
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
VIEW(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,OBJ
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"view_state_error",$GET(ERR("error"),"view_state_error"),.CTX)
	DO BUILD^MIOOSVM(.STATE,.CONF,.OBJ)
	SET OBJ("ok")=1
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
SIGNIN(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,TOKEN,OBJ,HEAD,JSON,USER
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$SIGNIN^MIOOSAUTH(.CONF,$GET(TREE("username")),$GET(TREE("password")),.TOKEN,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,401,"signin_failed",$GET(ERR("error")),.CTX)
	SET USER=$$CANON^MIOOSAUTH($GET(TREE("username")))
	SET OBJ("ok")=1,OBJ("tokenIssued")=1,OBJ("username")=USER
	SET JSON=$$EN^MIOJSON1(.OBJ)
	SET HEAD("Content-Type")="application/json; charset=utf-8"
	SET HEAD("Set-Cookie")=$$COOKIEHDR^MIOOSAUTH(.CONF,TOKEN,0)
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,JSON,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
SIGNOUT(DEV,CONF,REQ,CTX)
	NEW OBJ,HEAD,JSON
	DO SIGNOUT^MIOOSAUTH(.CONF,.REQ,.CTX)
	SET OBJ("ok")=1,OBJ("signedOut")=1
	SET JSON=$$EN^MIOJSON1(.OBJ)
	SET HEAD("Content-Type")="application/json; charset=utf-8"
	SET HEAD("Set-Cookie")=$$COOKIEHDR^MIOOSAUTH(.CONF,"",1)
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,JSON,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
GUESTSIGNIN(DEV,CONF,REQ,CTX)
	NEW ERR,TOKEN,OBJ,HEAD,JSON,USER
	IF '$$GUESTSIGNIN^MIOOSAUTH(.CONF,.TOKEN,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"guest_signin_failed",$GET(ERR("error")),.CTX)
	SET USER=$$CANON^MIOOSAUTH($GET(CONF("mioos","bootstrapAuth","guest","username"),"guest"))
	SET OBJ("ok")=1,OBJ("tokenIssued")=1,OBJ("guestAccess")=1,OBJ("username")=USER
	SET JSON=$$EN^MIOJSON1(.OBJ)
	SET HEAD("Content-Type")="application/json; charset=utf-8"
	SET HEAD("Set-Cookie")=$$COOKIEHDR^MIOOSAUTH(.CONF,TOKEN,0)
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,JSON,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
PARSEBODY(REQ,TREE,ERR)
	NEW JSON
	SET JSON=$$BODYTXT(.REQ)
	IF JSON="" SET ERR("routine")="MIOOSAPI",ERR("error")="body_missing" QUIT 0
	IF '$$DECODE^MIOJSON(JSON,.TREE,.ERR) SET ERR("routine")="MIOOSAPI" QUIT 0
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
RESPERR(DEV,CONF,STATUS,CODE,DETAIL,CTX)
	NEW OBJ
	SET OBJ("ok")=0,OBJ("error")=$GET(CODE),OBJ("detail")=$GET(DETAIL),OBJ("routine")="MIOOSAPI"
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,+$GET(STATUS),.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=+$GET(STATUS)
	QUIT
