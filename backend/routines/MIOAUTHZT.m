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
	;NEW CONF,REQ,CTX,DEV,OUT,OP,SECRET,NOW,TOK
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
	ZWR OUT
	QUIT
	;
T002 ; RBAC denies when role missing
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	;NEW CONF,REQ,CTX,DEV,OUT,OP,SECRET,NOW,TOK
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
	ZWR OUT
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
	;NEW CONF,REQ,CTX,DEV,OUT,OP,SECRET,NOW,TOK
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
	SET OP="tmp/mio_authz_t003.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[T003][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T003][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["not_owner":1,1:0),1,"[T003][reason]")
	ZWR OUT
	QUIT
	;
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