MIOREGADM ; Admin registry API.;
; API STABILITY
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; PURPOSE
; Admin endpoints for registry maintenance.;
; Requires authentication with admin role.;
;
; ROUTES
; POST /api/admin/registry/upsert
; POST /api/admin/registry/delete
; POST /api/admin/registry/reload
; POST /api/admin/registry/reindex
	;
REG(CONF) ;
	DO ADD^MIOROUTE("POST","/api/admin/registry/upsert","UPSERT^MIOREGADM")
	DO ADD^MIOROUTE("POST","/api/admin/registry/delete","DELETE^MIOREGADM")
	DO ADD^MIOROUTE("POST","/api/admin/registry/reload","RELOAD^MIOREGADM")
	DO ADD^MIOROUTE("POST","/api/admin/registry/reindex","REIDX^MIOREGADM")
	DO ADD^MIOROUTE("POST","/api/admin/registry/publish","PUBLISH^MIOREGADM")
	QUIT
	;
UPSERT(DEV,CONF,REQ,CTX) ;
	IF '$$AUTH(.DEV,.CONF,.REQ,.CTX) QUIT
	NEW OBJ,ERR
	IF '$$PARSEJSON(.REQ,.OBJ,.ERR) DO  QUIT
	. DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)
	NEW PKG,SLUG
	SET SLUG=$GET(OBJ("slug")) IF SLUG="" SET SLUG=$GET(OBJ("package","slug"))
	IF SLUG="" DO  QUIT
	. KILL ERR SET ERR("error")="missing_slug"
	. DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)
	;
	; Accept either flat object or nested "package".;
	IF $DATA(OBJ("package")) MERGE PKG=OBJ("package") ELSE  MERGE PKG=OBJ
	SET PKG("slug")=SLUG
	;
	NEW UERR
	IF '$$UPSERT^MIOPKG(.PKG,.UERR) DO  QUIT
	. DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.UERR,$GET(CTX("request_id")),.CTX)
	;
	NEW OUT KILL OUT
	SET OUT("ok")=1
	SET OUT("slug")=SLUG
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	QUIT
	;
DELETE(DEV,CONF,REQ,CTX) ;
	IF '$$AUTH(.DEV,.CONF,.REQ,.CTX) QUIT
	NEW OBJ,ERR
	IF '$$PARSEJSON(.REQ,.OBJ,.ERR) DO  QUIT
	. DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)
	NEW SLUG SET SLUG=$GET(OBJ("slug"))
	IF SLUG="" DO  QUIT
	. KILL ERR SET ERR("error")="missing_slug"
	. DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)
	;
	NEW DERR
	IF '$$DELETE^MIOPKG(SLUG,.DERR) DO  QUIT
	. DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.DERR,$GET(CTX("request_id")),.CTX)
	;
	NEW OUT KILL OUT
	SET OUT("ok")=1
	SET OUT("slug")=SLUG
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	QUIT
	;
RELOAD(DEV,CONF,REQ,CTX) ;
	IF '$$AUTH(.DEV,.CONF,.REQ,.CTX) QUIT
	DO LOAD^MIOPKG(.CONF)
	NEW OUT KILL OUT
	SET OUT("ok")=1
	SET OUT("ready")=$GET(^MIO("PKG","READY"))
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	QUIT
	;
PUBLISH(DEV,CONF,REQ,CTX) ;
	; Publish a new version for a slug.;
	;
	; Modes:
	; - Signed publish (default): body must contain { "jws": "<compact-jws>" }
	; - Unsigned publish (optional): enabled by CONF("registry","publish","allowUnsigned")=1
	;
	; Publisher authorization:
	; - issuer must be enabled in CONF("registry","publish","publishers",iss,"enabled")=1
	; - slug must be allowed by allowSlug or allowPrefix rules
	;
	IF '$$AUTH(.DEV,.CONF,.REQ,.CTX) QUIT
	;
	NEW OBJ,ERR
	IF '$$PARSEJSON(.REQ,.OBJ,.ERR) DO  QUIT
	. DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)
	;
	NEW REQUIRE SET REQUIRE=$$REQUIRE^MIOREGPUB(.CONF)
	NEW ALLOWU SET ALLOWU=+$GET(CONF("registry","publish","allowUnsigned"),0)
	;
	NEW JWS SET JWS=$GET(OBJ("jws"))
	IF REQUIRE,'ALLOWU,JWS="" DO  QUIT
	. KILL ERR SET ERR("error")="publish_requires_jws"
	. DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)
	;
	NEW PKG,ISS,SLUG,VER
	;
	IF JWS'="" DO  QUIT:$TEST
	. NEW HDR,PAY,VERERR
	. IF '$$VERIFY^MIOJWS(.CONF,JWS,.HDR,.PAY,.VERERR) DO  QUIT
	. . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.VERERR,$GET(CTX("request_id")),.CTX)
	. ; Convert PAY (MIOJSON object) to flat PKG values expected by MIOPKG.;
	. DO FLATTEN(.PAY,.PKG)
	. SET ISS=$GET(PKG("iss"))
	. SET SLUG=$GET(PKG("slug"))
	. SET VER=$GET(PKG("version"))
	. IF '$$AUTHZ^MIOREGPUB(.CONF,ISS,SLUG,.ERR) DO  QUIT
	. . DO RESPJSONX^MIOHTTP(.DEV,.CONF,403,.ERR,$GET(CTX("request_id")),.CTX)
	. NEW PERR
	. IF '$$PUBLISH^MIOPKG(.PKG,.PERR) DO  QUIT
	. . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.PERR,$GET(CTX("request_id")),.CTX)
	. NEW OUT KILL OUT
	. DO LOGREGPUB^MIOAUD(ISS,SLUG,VER,$GET(HDR("v","kid","v")),1,1,.CTX)
	. SET OUT("ok")=1,OUT("signed")=1
	. SET OUT("iss")=ISS,OUT("slug")=SLUG,OUT("version")=VER,OUT("latest")=$$LATEST^MIOPKG(SLUG)
	. DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	;
	; Unsigned mode: accept { "package": {...} } or flat package.;
	IF 'ALLOWU DO  QUIT
	. KILL ERR SET ERR("error")="publish_unsigned_disabled"
	. DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)
	;
	IF $DATA(OBJ("package")) MERGE PKG=OBJ("package") ELSE  MERGE PKG=OBJ
	SET ISS=$GET(PKG("iss"))
	SET SLUG=$GET(PKG("slug"))
	SET VER=$GET(PKG("version"))
	;
	IF SLUG=""!(VER="") DO  QUIT
	. KILL ERR SET ERR("error")="missing_slug_or_version"
	. DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)
	;
	; Optional authz for unsigned mode if iss is provided.;
	IF ISS'="" DO  QUIT:'$$AUTHZ^MIOREGPUB(.CONF,ISS,SLUG,.ERR)
	. DO RESPJSONX^MIOHTTP(.DEV,.CONF,403,.ERR,$GET(CTX("request_id")),.CTX)
	;
	NEW PERR
	IF '$$PUBLISH^MIOPKG(.PKG,.PERR) DO  QUIT
	. DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.PERR,$GET(CTX("request_id")),.CTX)
	;
	NEW OUT KILL OUT
	DO LOGREGPUB^MIOAUD(ISS,SLUG,VER,"",0,1,.CTX)
	SET OUT("ok")=1,OUT("signed")=0
	SET OUT("iss")=ISS,OUT("slug")=SLUG,OUT("version")=VER,OUT("latest")=$$LATEST^MIOPKG(SLUG)
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	QUIT
	;
FLATTEN(PAY,PKG) ;
	; Convert parsed JSON object PAY into flat PKG fields.;
	; PAY is MIOJSON structure: PAY("v",key,"v") etc.;
	KILL PKG
	NEW K SET K=""
	FOR  SET K=$ORDER(PAY("v",K)) QUIT:K=""  DO
	. NEW T SET T=$GET(PAY("v",K,"t"))
	. IF T="str"!(T="num")!(T="bool") SET PKG(K)=$GET(PAY("v",K,"v")) QUIT
	. IF T="arr" DO
	. . NEW I SET I=0
	. . FOR  SET I=$ORDER(PAY("v",K,"v",I)) QUIT:I=""  DO
	. . . NEW TV SET TV=$GET(PAY("v",K,"v",I,"v"))
	. . . SET PKG("tags",I)=TV
	QUIT
	;
REIDX(DEV,CONF,REQ,CTX) ;
	IF '$$AUTH(.DEV,.CONF,.REQ,.CTX) QUIT
	DO REIDX^MIOPKG
	NEW OUT KILL OUT
	SET OUT("ok")=1
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	QUIT
	;
AUTH(DEV,CONF,REQ,CTX) ;
	; Require auth with admin role.;
	IF '$$ENFORCE^MIOAUTH(.DEV,.CONF,.REQ,.CTX) QUIT 0
	IF $DATA(CTX("auth","roles","admin")) QUIT 1
	NEW E KILL E
	SET E("error")="forbidden"
	SET E("reason")="admin_role_required"
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,403,.E,$GET(CTX("request_id")),.CTX)
	QUIT 0
	;
PARSEJSON(REQ,OBJ,ERR) ;
	KILL OBJ,ERR
	NEW B SET B=$GET(REQ("body"))
	IF B="" SET ERR("error")="missing_body" QUIT 0
	NEW E
	IF '$$DECODE^MIOJSON(.B,.OBJ,.E) DO
	. SET ERR("error")="invalid_json"
	. SET ERR("detail")=$GET(E("error"))
	. QUIT
	QUIT:'$DATA(ERR) 1
	QUIT 0