MIOPUBADM ; Admin publisher management and audit retention endpoints.
; API STABILITY
; Public API labels are documented in docs/routines.
; Undocumented labels are internal.
;
; PURPOSE
; Let admins manage publishers and audit retention without editing code.
;
; ROUTES (admin-only)
; - GET  /api/admin/publishers
; - GET  /api/admin/publishers/:iss
; - POST /api/admin/publishers/upsert
; - POST /api/admin/publishers/allow
; - POST /api/admin/publishers/disallow
; - POST /api/admin/publishers/key
; - POST /api/admin/publishers/key/disable
; - POST /api/admin/audit/prune
;
; SECURITY
; Requires role "admin".

REG(CONF) ;
 DO ADD^MIOROUTE("GET","/api/admin/publishers","LIST^MIOPUBADM")
 DO ADD^MIOROUTE("GET","/api/admin/publishers/:iss","GET^MIOPUBADM")
 DO ADD^MIOROUTE("POST","/api/admin/publishers/upsert","UPSERT^MIOPUBADM")
 DO ADD^MIOROUTE("POST","/api/admin/publishers/allow","ALLOW^MIOPUBADM")
 DO ADD^MIOROUTE("POST","/api/admin/publishers/disallow","DISALLOW^MIOPUBADM")
 DO ADD^MIOROUTE("POST","/api/admin/publishers/key","KEYADD^MIOPUBADM")
 DO ADD^MIOROUTE("POST","/api/admin/publishers/key/disable","KEYDIS^MIOPUBADM")
 DO ADD^MIOROUTE("POST","/api/admin/audit/prune","PRUNEAUD^MIOPUBADM")
 QUIT

LIST(DEV,CONF,REQ,CTX) ;
 IF '$$ENFORCE^MIOAUTH(.DEV,.CONF,.REQ,.CTX,"admin") QUIT
 NEW RES KILL RES
 NEW ISS SET ISS="",I=0
 FOR  SET ISS=$ORDER(^MIO("REG","PUB",ISS)) QUIT:ISS=""  DO
 . SET I=I+1
 . SET RES("items",I,"iss")=ISS
 . SET RES("items",I,"enabled")=+$GET(^MIO("REG","PUB",ISS,"enabled"))
 . SET RES("items",I,"jwksUrl")=$GET(^MIO("REG","PUB",ISS,"jwksUrl"))
 DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.RES,$GET(CTX("request_id")),.CTX)
 QUIT

GET(DEV,CONF,REQ,CTX) ;
 IF '$$ENFORCE^MIOAUTH(.DEV,.CONF,.REQ,.CTX,"admin") QUIT
 NEW ISS SET ISS=$GET(REQ("params","iss"))
 NEW OUT,ERR
 IF '$$GETME^MIOREGPUB(.CONF,ISS,.OUT,.ERR) DO  QUIT
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,404,.ERR,$GET(CTX("request_id")),.CTX)
 DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
 QUIT

UPSERT(DEV,CONF,REQ,CTX) ;
 IF '$$ENFORCE^MIOAUTH(.DEV,.CONF,.REQ,.CTX,"admin") QUIT
 NEW OBJ,ERR
 IF '$$PARSEJSON^MIOREGADM(.REQ,.OBJ,.ERR) DO  QUIT
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)
 NEW ISS SET ISS=$GET(OBJ("iss"))
 IF ISS="" DO  QUIT
 . KILL ERR SET ERR("error")="missing_iss"
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)

 SET ^MIO("REG","PUB",ISS,"enabled")=+$GET(OBJ("enabled"),1)
 IF $DATA(OBJ("jwksUrl")) SET ^MIO("REG","PUB",ISS,"jwksUrl")=$GET(OBJ("jwksUrl"))
 NEW OUT KILL OUT
 SET OUT("ok")=1,OUT("iss")=ISS,OUT("enabled")=+$GET(^MIO("REG","PUB",ISS,"enabled"))
 DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
 QUIT

ALLOW(DEV,CONF,REQ,CTX) ;
 IF '$$ENFORCE^MIOAUTH(.DEV,.CONF,.REQ,.CTX,"admin") QUIT
 NEW OBJ,ERR
 IF '$$PARSEJSON^MIOREGADM(.REQ,.OBJ,.ERR) DO  QUIT
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)
 NEW ISS SET ISS=$GET(OBJ("iss"))
 NEW SLUG SET SLUG=$GET(OBJ("slug"))
 NEW PREF SET PREF=$GET(OBJ("prefix"))
 IF ISS="" DO  QUIT
 . KILL ERR SET ERR("error")="missing_iss"
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)
 IF SLUG=""&(PREF="") DO  QUIT
 . KILL ERR SET ERR("error")="missing_slug_or_prefix"
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)

 IF '$DATA(^MIO("REG","PUB",ISS)) SET ^MIO("REG","PUB",ISS,"enabled")=1
 IF SLUG'="" SET ^MIO("REG","PUB",ISS,"allowSlug",SLUG)=1
 IF PREF'="" SET ^MIO("REG","PUB",ISS,"allowPrefix",PREF)=1

 NEW OUT KILL OUT
 SET OUT("ok")=1,OUT("iss")=ISS
 DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
 QUIT

DISALLOW(DEV,CONF,REQ,CTX) ;
 IF '$$ENFORCE^MIOAUTH(.DEV,.CONF,.REQ,.CTX,"admin") QUIT
 NEW OBJ,ERR
 IF '$$PARSEJSON^MIOREGADM(.REQ,.OBJ,.ERR) DO  QUIT
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)
 NEW ISS SET ISS=$GET(OBJ("iss"))
 NEW SLUG SET SLUG=$GET(OBJ("slug"))
 NEW PREF SET PREF=$GET(OBJ("prefix"))
 IF ISS="" DO  QUIT
 . KILL ERR SET ERR("error")="missing_iss"
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)
 IF SLUG=""&(PREF="") DO  QUIT
 . KILL ERR SET ERR("error")="missing_slug_or_prefix"
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)

 IF SLUG'="" KILL ^MIO("REG","PUB",ISS,"allowSlug",SLUG)
 IF PREF'="" KILL ^MIO("REG","PUB",ISS,"allowPrefix",PREF)

 NEW OUT KILL OUT
 SET OUT("ok")=1,OUT("iss")=ISS
 DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
 QUIT

KEYADD(DEV,CONF,REQ,CTX) ;
 IF '$$ENFORCE^MIOAUTH(.DEV,.CONF,.REQ,.CTX,"admin") QUIT
 NEW OBJ,ERR
 IF '$$PARSEJSON^MIOREGADM(.REQ,.OBJ,.ERR) DO  QUIT
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)
 NEW ISS,KID,N,E
 SET ISS=$GET(OBJ("iss"))
 SET KID=$GET(OBJ("kid"))
 SET N=$GET(OBJ("n"))
 SET E=$GET(OBJ("e"))
 IF ISS=""!(KID="")!(N="")!(E="") DO  QUIT
 . KILL ERR SET ERR("error")="missing_iss_kid_n_e"
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)

 IF '$DATA(^MIO("REG","PUB",ISS)) SET ^MIO("REG","PUB",ISS,"enabled")=1
 SET ^MIO("REG","PUB",ISS,"key",KID,"enabled")=1
 SET ^MIO("REG","PUB",ISS,"key",KID,"n")=N
 SET ^MIO("REG","PUB",ISS,"key",KID,"e")=E

 NEW OUT KILL OUT
 SET OUT("ok")=1,OUT("iss")=ISS,OUT("kid")=KID,OUT("enabled")=1
 DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
 QUIT

KEYDIS(DEV,CONF,REQ,CTX) ;
 IF '$$ENFORCE^MIOAUTH(.DEV,.CONF,.REQ,.CTX,"admin") QUIT
 NEW OBJ,ERR
 IF '$$PARSEJSON^MIOREGADM(.REQ,.OBJ,.ERR) DO  QUIT
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)
 NEW ISS,KID
 SET ISS=$GET(OBJ("iss"))
 SET KID=$GET(OBJ("kid"))
 IF ISS=""!(KID="") DO  QUIT
 . KILL ERR SET ERR("error")="missing_iss_or_kid"
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)

 IF '$DATA(^MIO("REG","PUB",ISS,"key",KID)) DO  QUIT
 . KILL ERR SET ERR("error")="not_found"
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,404,.ERR,$GET(CTX("request_id")),.CTX)

 SET ^MIO("REG","PUB",ISS,"key",KID,"enabled")=0
 NEW OUT KILL OUT
 SET OUT("ok")=1,OUT("iss")=ISS,OUT("kid")=KID,OUT("enabled")=0
 DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
 QUIT

PRUNEAUD(DEV,CONF,REQ,CTX) ;
 IF '$$ENFORCE^MIOAUTH(.DEV,.CONF,.REQ,.CTX,"admin") QUIT
 NEW OBJ,ERR
 IF '$$PARSEJSON^MIOREGADM(.REQ,.OBJ,.ERR) DO  QUIT
 . DO RESPJSONX^MIOHTTP(.DEV,.CONF,400,.ERR,$GET(CTX("request_id")),.CTX)

 NEW KEEP SET KEEP=+$GET(OBJ("keepMax"),0)
 NEW DAYS SET DAYS=+$GET(OBJ("olderThanDays"),0)
 NEW CUT SET CUT=0
 IF DAYS>0 SET CUT=$$EPOCHMS^MIOUTIL()-(DAYS*86400*1000)

 DO PRUNEREG^MIOAUD(KEEP,CUT)
 NEW OUT KILL OUT
 SET OUT("ok")=1,OUT("keepMax")=KEEP,OUT("olderThanDays")=DAYS
 DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
 QUIT
