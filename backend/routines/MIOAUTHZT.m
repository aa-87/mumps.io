MIOAUTHZT ; Auth (JWT + RBAC/ABAC) tests
	;
	; Run:
	;   YDB>ZL "MIOHTTP.m","MIOROUTE.m","MIOMW.m","MIOAUTH.m","MIOAUTHJWT.m","MIOAUTHZ.m","MIOAUTHZT.m","MIOTASSERT.m"
	;   YDB>D ^MIOAUTHZT
	;
	NEW $ET SET $ET="DO STERR^MIOAUTHZT"
	DO T001
	DO T002
	DO T003
	DO T004
	DO T005
	DO T006
	DO T007
	DO T008
	DO T009
	DO T010
	DO T011
	DO T012
	DO T013
	QUIT
	;
STERR
	USE $PRINCIPAL WRITE "ERR ",$ZSTATUS,!
	QUIT
	;
RESET
	KILL ^MIO("ROUTE")
	QUIT
	;
READALL(PATH,OUT)
	NEW OIO SET OIO=$IO
	SET OUT=""
	NEW DEV SET DEV=PATH
	OPEN DEV:(readonly:stream:nowrap)
	USE DEV
	NEW X
	FOR  READ X#16384  QUIT:$ZEOF  SET OUT=OUT_X
	CLOSE DEV
	USE OIO
	QUIT
	;
; Build HS256 JWT token with payload JSON string.;
MKJWT(SECRET,PJSON)
	NEW HJSON,H64,P64,DATA,SIG,S64,ERR
	SET HJSON="{""alg"":""HS256"",""typ"":""JWT""}"
	SET H64=$$B64EURL^MIOAUTHJWT(HJSON)
	SET P64=$$B64EURL^MIOAUTHJWT(PJSON)
	SET DATA=H64_"."_P64
	SET SIG=$$HMACSHA256^MIOAUTHJWT(DATA,SECRET,.ERR)
	SET S64=$$B64EURL^MIOAUTHJWT(SIG)
	QUIT DATA_"."_S64
	;
T001 ; HS256 JWT allows route (role admin)
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	NEW CONF,REQ,CTX,DEV,OUT,OP,SECRET,NOW,TOK
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	SET CONF("auth","jwt","rolesClaim")="roles"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""admin,user"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az001"
	SET OP="tmp/mio_authz_t001.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T001][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T001][handler ran]")
	DO EQ^MIOTASSERT($GET(CTX("auth","ok")),1,"[T001][auth ok]")
	DO EQ^MIOTASSERT($GET(CTX("auth","roles","admin")),1,"[T001][role]")
	QUIT
	;
T002 ; RBAC denies when role missing
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	NEW CONF,REQ,CTX,DEV,OUT,OP,SECRET,NOW,TOK
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	SET CONF("auth","jwt","rolesClaim")="roles"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""user"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az002"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t002.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[T002][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T002][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["MIOAUTHZ":1,1:0),1,"[T002][routine]")
	DO EQ^MIOTASSERT($SELECT(OUT["role_required":1,1:0),1,"[T002][reason]")
	QUIT
	;
T003 ; ABAC owner check: ownerParam=id, ownerClaim=sub
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("ownerParam")="id"
	SET META("ownerClaim")="sub"
	DO ADDM^MIOROUTE("GET","/item/:id","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	NEW CONF,REQ,CTX,DEV,OUT,OP,SECRET,NOW,TOK
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/item/u2" ; mismatch
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az003"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t003.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[T003][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T003][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["not_owner":1,1:0),1,"[T003][reason]")
	QUIT
T004 ; Missing Authorization header -> 401 jwt_missing
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	DO ENSURE^MIOMW(.CONF)
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET CTX("request_id")="az004"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t004.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[T004][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T004][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_missing":1,1:0),1,"[T004][reason]")
	QUIT
	;
T005 ; Malformed token -> 401 jwt_format
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	DO ENSURE^MIOMW(.CONF)
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer abc.def"
	SET CTX("request_id")="az005"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t005.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[T005][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T005][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_format":1,1:0),1,"[T005][reason]")
	QUIT
	;
T006 ; Bad signature -> 401 jwt_bad_signature
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")="wrongsecret"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az006"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t006.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[T006][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T006][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_bad_signature":1,1:0),1,"[T006][reason]")
	QUIT
	;
T007 ; Expired token -> 401 jwt_expired
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW-120)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az007"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t007.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[T007][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T007][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_expired":1,1:0),1,"[T007][reason]")
	QUIT
	;
T008 ; Not yet valid -> 401 jwt_not_yet_valid
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""nbf"":"_(NOW+600)_",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az008"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t008.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[T008][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T008][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_not_yet_valid":1,1:0),1,"[T008][reason]")
	QUIT
	;
T009 ; CSV roles with admin second -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	SET CONF("auth","jwt","rolesClaim")="roles"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""user,admin"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az009"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t009.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T009][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T009][handler ran]")
	DO EQ^MIOTASSERT($GET(CTX("auth","roles","admin")),1,"[T009][admin role]")
	QUIT
	;
T010 ; Owner match -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("ownerParam")="id"
	SET META("ownerClaim")="sub"
	DO ADDM^MIOROUTE("GET","/item/:id","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/item/u1"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az010"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t010.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T010][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T010][handler ran]")
	DO EQ^MIOTASSERT($GET(CTX("auth","sub")),"u1","[T010][sub]")
	QUIT
	;
T011 ; Issuer mismatch -> 401
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	SET CONF("auth","jwt","issuer")="good-iss"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""iss"":""bad-iss"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az011"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t011.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[T011][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T011][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_issuer":1,1:0),1,"[T011][reason]")
	QUIT
	;
T012 ; Audience mismatch -> 401
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	SET CONF("auth","jwt","audience")="good-aud"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""aud"":""bad-aud"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az012"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t012.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[T012][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T012][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_audience":1,1:0),1,"[T012][reason]")
	QUIT
	;
T013 ; claims.department mismatch -> 403
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("claims.department")="billing"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""department"":""sales"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az013"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t013.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[T013][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T013][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["claim_mismatch:department":1,1:0),1,"[T013][reason]")
	QUIT
; ---- handler ----
HOK(DEV,CONF,REQ,CTX)
	SET CTX("ran")=1
	NEW OBJ
	SET OBJ("ok")=1
	SET OBJ("sub")=$GET(CTX("auth","sub"))
	SET OBJ("routine")="MIOAUTHZT"
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;