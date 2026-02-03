MIOPUBAPI ; Publisher self service and audit APIs.
; API STABILITY
; Public API labels are documented in docs/routines.
; Undocumented labels are internal.
;
; PURPOSE
; Provide endpoints for publishers to view profile and rotate keys.
; Provide admin endpoint to view registry audit log.
;
; ROUTES
; - GET  /api/publisher/me
; - POST /api/publisher/keys
; - POST /api/publisher/keys/disable
; - GET  /api/admin/audit/registry
;
; SECURITY
; Publisher endpoints require JWT auth.
; Admin audit requires role "admin".

REG(CONF) ;
 DO ADD^MIOROUTE("GET","/api/publisher/me","ME^MIOPUBAPI")
 DO ADD^MIOROUTE("POST","/api/publisher/keys","ADDKEY^MIOPUBAPI")
 DO ADD^MIOROUTE("POST","/api/publisher/keys/disable","DISKEY^MIOPUBAPI")
 DO ADD^MIOROUTE("GET","/api/admin/audit/registry","AUDREG^MIOPUBAPI")
 QUIT

ME(DEV,CONF,REQ,CTX) ;
 IF '$$NEEDJWT(.DEV,.CONF,.REQ,.CTX) QUIT
 NEW ISS SET ISS=$GET(CTX("auth","claim","iss"))
 IF ISS="" DO  QUIT
 . NEW E KILL E SET E("error")="issuer_missing"
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.E,$GET(CTX("request_id")),.CTX)

 NEW OUT,ERR
 IF '$$GETME^MIOREGPUB(.CONF,ISS,.OUT,.ERR) DO  QUIT
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)

 DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
 QUIT

ADDKEY(DEV,CONF,REQ,CTX) ;
 IF '$$NEEDJWT(.DEV,.CONF,.REQ,.CTX) QUIT
 NEW ISS SET ISS=$GET(CTX("auth","claim","iss"))
 IF ISS="" DO  QUIT
 . NEW E KILL E SET E("error")="issuer_missing"
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.E,$GET(CTX("request_id")),.CTX)

 NEW OBJ,ERR
 IF '$$PARSEJSON^MIOREGADM(.REQ,.OBJ,.ERR) DO  QUIT
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)

 NEW KID,N,E
 SET KID=$GET(OBJ("kid"))
 SET N=$GET(OBJ("n"))
 SET E=$GET(OBJ("e"))
 IF KID=""!(N="")!(E="") DO  QUIT
 . KILL ERR SET ERR("error")="missing_kid_n_e"
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)

 ; Create publisher if missing in globals.
 IF '$DATA(^MIO("REG","PUB",ISS)) SET ^MIO("REG","PUB",ISS,"enabled")=1

 SET ^MIO("REG","PUB",ISS,"key",KID,"enabled")=1
 SET ^MIO("REG","PUB",ISS,"key",KID,"n")=N
 SET ^MIO("REG","PUB",ISS,"key",KID,"e")=E

 NEW OUT KILL OUT
 SET OUT("ok")=1,OUT("iss")=ISS,OUT("kid")=KID
 DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
 QUIT

DISKEY(DEV,CONF,REQ,CTX) ;
 IF '$$NEEDJWT(.DEV,.CONF,.REQ,.CTX) QUIT
 NEW ISS SET ISS=$GET(CTX("auth","claim","iss"))
 IF ISS="" DO  QUIT
 . NEW E KILL E SET E("error")="issuer_missing"
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.E,$GET(CTX("request_id")),.CTX)

 NEW OBJ,ERR
 IF '$$PARSEJSON^MIOREGADM(.REQ,.OBJ,.ERR) DO  QUIT
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)

 NEW KID SET KID=$GET(OBJ("kid"))
 IF KID="" DO  QUIT
 . KILL ERR SET ERR("error")="missing_kid"
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)

 IF '$DATA(^MIO("REG","PUB",ISS,"key",KID)) DO  QUIT
 . KILL ERR SET ERR("error")="not_found"
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,404,.ERR,$GET(CTX("request_id")),.CTX)

 SET ^MIO("REG","PUB",ISS,"key",KID,"enabled")=0
 NEW OUT KILL OUT
 SET OUT("ok")=1,OUT("iss")=ISS,OUT("kid")=KID,OUT("enabled")=0
 DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
 QUIT

AUDREG(DEV,CONF,REQ,CTX) ;
 ; Admin only.
 IF '$$ENFORCE^MIOAUTH(.DEV,.CONF,.REQ,.CTX,"admin") QUIT
 NEW LIM SET LIM=+$GET(REQ("query","limit")) IF LIM<1 SET LIM=50
 NEW OUT KILL OUT
 DO LISTREG^MIOAUD(.OUT,LIM)
 NEW RES KILL RES
 SET RES("items")=""
 NEW I SET I=0
 FOR  SET I=$ORDER(OUT(I)) QUIT:I=""  DO
 . MERGE RES("items",I)=OUT(I)
 DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.RES,$GET(CTX("request_id")),.CTX)
 QUIT

NEEDJWT(DEV,CONF,REQ,CTX) ;
 ; Require JWT auth. This prevents API key callers from acting as publishers.
 IF $GET(CONF("auth","enabled"))'=1 DO  QUIT 0
 . NEW E KILL E SET E("error")="auth_disabled"
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.E,$GET(CTX("request_id")),.CTX)
 IF $GET(CONF("auth","mode"))'="jwt" DO  QUIT 0
 . NEW E KILL E SET E("error")="jwt_required"
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,403,.E,$GET(CTX("request_id")),.CTX)
 IF $GET(CTX("auth","ok"))'=1 DO  QUIT 0
 . NEW E KILL E SET E("error")="unauthorized"
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,401,.E,$GET(CTX("request_id")),.CTX)
 QUIT 1
