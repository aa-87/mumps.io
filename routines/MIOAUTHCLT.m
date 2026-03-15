MIOAUTHCLT ; HS256 client-secret resolution tests for MIOAUTHJWT
 ;
 QUIT
 ;
START
 DO T001
 DO T002
 DO T003
 DO T004
 DO T005
 DO T006
 DO T007
 DO T008
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
MKJWTHDR(HJSON,PJSON,SECRET)
 NEW H64,P64,DATA,SIG,S64,ERR
 SET H64=$$B64EURL^MIOAUTHJWT(HJSON)
 SET P64=$$B64EURL^MIOAUTHJWT(PJSON)
 SET DATA=H64_"."_P64
 SET SIG=$$HMACSHA256^MIOAUTHJWT(DATA,SECRET,.ERR)
 SET S64=$$B64EURL^MIOAUTHJWT(SIG)
 QUIT DATA_"."_S64
 ;
MKJWT(SECRET,PJSON)
 NEW HJSON
 SET HJSON="{""alg"":""HS256"",""typ"":""JWT""}"
 QUIT $$MKJWTHDR(HJSON,PJSON,SECRET)
 ;
MKJWTKID(SECRET,KID,PJSON)
 NEW HJSON
 SET HJSON="{""alg"":""HS256"",""typ"":""JWT"",""kid"":"""_KID_"""}"
 QUIT $$MKJWTHDR(HJSON,PJSON,SECRET)
 ;
T001 ; header kid resolves client secret -> 200
 DO RESET
 NEW META
 SET META("authRequired")=1
 DO ADDM^MIOROUTE("GET","/client/kid","HOK^MIOAUTHCLT",.META)
 DO COMPILE^MIOROUTE
 NEW CONF,REQ,CTX,DEV,OUT,OP,NOW,TOK
 KILL CONF,REQ,CTX
 SET CONF("auth","protectMode")="route"
 SET CONF("auth","mode")="jwt"
 SET CONF("auth","jwt","hmacSecretByKid","k1")="kid-secret-1"
 DO ENSURE^MIOMW(.CONF)
 SET NOW=$$NOWS^MIOAUTHJWT()
 SET TOK=$$MKJWTKID("kid-secret-1","k1","{""sub"":""ck1"",""exp"":"_(NOW+3600)_"}")
 SET REQ("method")="GET",REQ("path")="/client/kid",REQ("hdr","authorization")="Bearer "_TOK
 SET CTX("request_id")="clt001",CTX("ran")=0
 SET OP="tmp/mio_authclt_t001.out"
 OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
 DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
 CLOSE DEV USE $PRINCIPAL
 DO READALL(OP,.OUT)
 DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHCLT][T001][status]")
 DO EQ^MIOTASSERT($GET(CTX("auth","sub")),"ck1","[MIOAUTHCLT][T001][sub]")
 QUIT
 ;
T002 ; default client_id claim resolves client secret -> 200
 DO RESET
 NEW META
 SET META("authRequired")=1
 DO ADDM^MIOROUTE("GET","/client/claim","HOK^MIOAUTHCLT",.META)
 DO COMPILE^MIOROUTE
 NEW CONF,REQ,CTX,DEV,OUT,OP,NOW,TOK
 KILL CONF,REQ,CTX
 SET CONF("auth","protectMode")="route"
 SET CONF("auth","mode")="jwt"
 SET CONF("auth","jwt","hmacSecretByClient","client-a")="client-secret-a"
 DO ENSURE^MIOMW(.CONF)
 SET NOW=$$NOWS^MIOAUTHJWT()
 SET TOK=$$MKJWT("client-secret-a","{""sub"":""ca"",""client_id"":""client-a"",""exp"":"_(NOW+3600)_"}")
 SET REQ("method")="GET",REQ("path")="/client/claim",REQ("hdr","authorization")="Bearer "_TOK
 SET CTX("request_id")="clt002",CTX("ran")=0
 SET OP="tmp/mio_authclt_t002.out"
 OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
 DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
 CLOSE DEV USE $PRINCIPAL
 DO READALL(OP,.OUT)
 DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHCLT][T002][status]")
 DO EQ^MIOTASSERT($GET(CTX("auth","claim","client_id")),"client-a","[MIOAUTHCLT][T002][client_id]")
 QUIT
 ;
T003 ; custom clientIdClaim allows issuer keyed client secret -> 200
 DO RESET
 NEW META
 SET META("authRequired")=1
 DO ADDM^MIOROUTE("GET","/client/iss","HOK^MIOAUTHCLT",.META)
 DO COMPILE^MIOROUTE
 NEW CONF,REQ,CTX,DEV,OUT,OP,NOW,TOK
 KILL CONF,REQ,CTX
 SET CONF("auth","protectMode")="route"
 SET CONF("auth","mode")="jwt"
 SET CONF("auth","jwt","clientIdClaim")="iss"
 SET CONF("auth","jwt","hmacSecretByClient","issuer-a")="issuer-secret-a"
 DO ENSURE^MIOMW(.CONF)
 SET NOW=$$NOWS^MIOAUTHJWT()
 SET TOK=$$MKJWT("issuer-secret-a","{""sub"":""iss-user"",""iss"":""issuer-a"",""exp"":"_(NOW+3600)_"}")
 SET REQ("method")="GET",REQ("path")="/client/iss",REQ("hdr","authorization")="Bearer "_TOK
 SET CTX("request_id")="clt003",CTX("ran")=0
 SET OP="tmp/mio_authclt_t003.out"
 OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
 DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
 CLOSE DEV USE $PRINCIPAL
 DO READALL(OP,.OUT)
 DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHCLT][T003][status]")
 DO EQ^MIOTASSERT($GET(CTX("auth","claim","iss")),"issuer-a","[MIOAUTHCLT][T003][iss]")
 QUIT
 ;
T004 ; direct hmacSecret keeps precedence over client maps -> 200
 DO RESET
 NEW META
 SET META("authRequired")=1
 DO ADDM^MIOROUTE("GET","/client/precedence","HOK^MIOAUTHCLT",.META)
 DO COMPILE^MIOROUTE
 NEW CONF,REQ,CTX,DEV,OUT,OP,NOW,TOK
 KILL CONF,REQ,CTX
 SET CONF("auth","protectMode")="route"
 SET CONF("auth","mode")="jwt"
 SET CONF("auth","jwt","hmacSecret")="global-master"
 SET CONF("auth","jwt","hmacSecretByKid","k1")="wrong-kid-secret"
 SET CONF("auth","jwt","hmacSecretByClient","client-a")="wrong-client-secret"
 DO ENSURE^MIOMW(.CONF)
 SET NOW=$$NOWS^MIOAUTHJWT()
 SET TOK=$$MKJWTKID("global-master","k1","{""sub"":""master"",""client_id"":""client-a"",""exp"":"_(NOW+3600)_"}")
 SET REQ("method")="GET",REQ("path")="/client/precedence",REQ("hdr","authorization")="Bearer "_TOK
 SET CTX("request_id")="clt004",CTX("ran")=0
 SET OP="tmp/mio_authclt_t004.out"
 OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
 DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
 CLOSE DEV USE $PRINCIPAL
 DO READALL(OP,.OUT)
 DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHCLT][T004][status]")
 DO EQ^MIOTASSERT($GET(CTX("auth","sub")),"master","[MIOAUTHCLT][T004][sub]")
 QUIT
 ;
T005 ; resolver callback can provide client secret -> 200
 DO RESET
 NEW META
 SET META("authRequired")=1
 DO ADDM^MIOROUTE("GET","/client/resolve","HOK^MIOAUTHCLT",.META)
 DO COMPILE^MIOROUTE
 NEW CONF,REQ,CTX,DEV,OUT,OP,NOW,TOK
 KILL CONF,REQ,CTX
 SET CONF("auth","protectMode")="route"
 SET CONF("auth","mode")="jwt"
 SET CONF("auth","jwt","hs256Resolve")="HSRSLV^MIOAUTHCLT"
 DO ENSURE^MIOMW(.CONF)
 SET NOW=$$NOWS^MIOAUTHJWT()
 SET TOK=$$MKJWT("dynamic-secret-1","{""sub"":""dyn1"",""client_id"":""dyn-client-1"",""exp"":"_(NOW+3600)_"}")
 SET REQ("method")="GET",REQ("path")="/client/resolve",REQ("hdr","authorization")="Bearer "_TOK
 SET CTX("request_id")="clt005",CTX("ran")=0
 SET OP="tmp/mio_authclt_t005.out"
 OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
 DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
 CLOSE DEV USE $PRINCIPAL
 DO READALL(OP,.OUT)
 DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHCLT][T005][status]")
 DO EQ^MIOTASSERT($GET(CTX("auth","sub")),"dyn1","[MIOAUTHCLT][T005][sub]")
 QUIT
 ;
T006 ; unresolved client secret keeps existing error code -> 401 jwt_hmac_secret_missing
 DO RESET
 NEW META
 SET META("authRequired")=1
 DO ADDM^MIOROUTE("GET","/client/missing","HOK^MIOAUTHCLT",.META)
 DO COMPILE^MIOROUTE
 NEW CONF,REQ,CTX,DEV,OUT,OP,NOW,TOK
 KILL CONF,REQ,CTX
 SET CONF("auth","protectMode")="route"
 SET CONF("auth","mode")="jwt"
 DO ENSURE^MIOMW(.CONF)
 SET NOW=$$NOWS^MIOAUTHJWT()
 SET TOK=$$MKJWTKID("orphan-secret","missing-kid","{""sub"":""orphan"",""exp"":"_(NOW+3600)_"}")
 SET REQ("method")="GET",REQ("path")="/client/missing",REQ("hdr","authorization")="Bearer "_TOK
 SET CTX("request_id")="clt006",CTX("ran")=0
 SET OP="tmp/mio_authclt_t006.out"
 OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
 DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
 CLOSE DEV USE $PRINCIPAL
 DO READALL(OP,.OUT)
 DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHCLT][T006][status]")
 DO EQ^MIOTASSERT($SELECT(OUT["jwt_hmac_secret_missing":1,1:0),1,"[MIOAUTHCLT][T006][reason]")
 QUIT
 ;
T007 ; malformed resolver entry denies cleanly -> 401 jwt_hs256_bad_resolver
 DO RESET
 NEW META
 SET META("authRequired")=1
 DO ADDM^MIOROUTE("GET","/client/badresolver","HOK^MIOAUTHCLT",.META)
 DO COMPILE^MIOROUTE
 NEW CONF,REQ,CTX,DEV,OUT,OP,NOW,TOK
 KILL CONF,REQ,CTX
 SET CONF("auth","protectMode")="route"
 SET CONF("auth","mode")="jwt"
 SET CONF("auth","jwt","hs256Resolve")="bad-entry"
 DO ENSURE^MIOMW(.CONF)
 SET NOW=$$NOWS^MIOAUTHJWT()
 SET TOK=$$MKJWT("dynamic-secret-1","{""sub"":""dyn1"",""client_id"":""dyn-client-1"",""exp"":"_(NOW+3600)_"}")
 SET REQ("method")="GET",REQ("path")="/client/badresolver",REQ("hdr","authorization")="Bearer "_TOK
 SET CTX("request_id")="clt007",CTX("ran")=0
 SET OP="tmp/mio_authclt_t007.out"
 OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
 DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
 CLOSE DEV USE $PRINCIPAL
 DO READALL(OP,.OUT)
 DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHCLT][T007][status]")
 DO EQ^MIOTASSERT($SELECT(OUT["jwt_hs256_bad_resolver":1,1:0),1,"[MIOAUTHCLT][T007][reason]")
 QUIT
 ;
T008 ; resolver exception denies cleanly -> 401 jwt_hs256_resolver_exception
 DO RESET
 NEW META
 SET META("authRequired")=1
 DO ADDM^MIOROUTE("GET","/client/resolvererr","HOK^MIOAUTHCLT",.META)
 DO COMPILE^MIOROUTE
 NEW CONF,REQ,CTX,DEV,OUT,OP,NOW,TOK
 KILL CONF,REQ,CTX
 SET CONF("auth","protectMode")="route"
 SET CONF("auth","mode")="jwt"
 SET CONF("auth","jwt","hs256Resolve")="HSRERR^MIOAUTHCLT"
 DO ENSURE^MIOMW(.CONF)
 SET NOW=$$NOWS^MIOAUTHJWT()
 SET TOK=$$MKJWT("dynamic-secret-1","{""sub"":""dyn1"",""client_id"":""dyn-client-1"",""exp"":"_(NOW+3600)_"}")
 SET REQ("method")="GET",REQ("path")="/client/resolvererr",REQ("hdr","authorization")="Bearer "_TOK
 SET CTX("request_id")="clt008",CTX("ran")=0
 SET OP="tmp/mio_authclt_t008.out"
 OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
 DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
 CLOSE DEV USE $PRINCIPAL
 DO READALL(OP,.OUT)
 DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHCLT][T008][status]")
 DO EQ^MIOTASSERT($SELECT(OUT["jwt_hs256_resolver_exception":1,1:0),1,"[MIOAUTHCLT][T008][reason]")
 QUIT
 ;
HOK(DEV,CONF,REQ,CTX)
 SET CTX("ran")=1
 NEW OBJ
 SET OBJ("ok")=1
 SET OBJ("sub")=$GET(CTX("auth","sub"))
 SET OBJ("routine")="MIOAUTHCLT"
 DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
 SET CTX("status")=200
 QUIT
 ;
HSRSLV(CONF,CTX,HOBJ,POBJ,SECRET,ERR)
 NEW CID
 SET CID=$GET(POBJ("client_id"))
 IF CID="dyn-client-1" SET SECRET="dynamic-secret-1" QUIT 1
 QUIT 0
 ;
HSRERR(CONF,CTX,HOBJ,POBJ,SECRET,ERR)
 NEW X SET X=1/0
 QUIT 0
