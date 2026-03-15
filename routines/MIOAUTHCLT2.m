MIOAUTHCLT2 ; Additional HS256 client-secret resolution tests for MIOAUTHJWT
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
 DO T009
 DO T010
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
T001 ; kid map wins over client map when both are configured
 DO RESET
 NEW META
 SET META("authRequired")=1
 DO ADDM^MIOROUTE("GET","/client2/kidwins","HOK^MIOAUTHCLT2",.META)
 DO COMPILE^MIOROUTE
 NEW CONF,REQ,CTX,DEV,OUT,OP,NOW,TOK
 KILL CONF,REQ,CTX
 SET CONF("auth","protectMode")="route"
 SET CONF("auth","mode")="jwt"
 SET CONF("auth","jwt","hmacSecretByKid","k1")="kid-secret-1"
 SET CONF("auth","jwt","hmacSecretByClient","client-a")="wrong-client-secret"
 DO ENSURE^MIOMW(.CONF)
 SET NOW=$$NOWS^MIOAUTHJWT()
 SET TOK=$$MKJWTKID("kid-secret-1","k1","{""sub"":""kidwins"",""client_id"":""client-a"",""exp"":"_(NOW+3600)_"}")
 SET REQ("method")="GET",REQ("path")="/client2/kidwins",REQ("hdr","authorization")="Bearer "_TOK
 SET CTX("request_id")="clt2001",CTX("ran")=0
 SET OP="tmp/mio_authclt2_t001.out"
 OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
 DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
 CLOSE DEV USE $PRINCIPAL
 DO READALL(OP,.OUT)
 DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHCLT2][T001][status]")
 DO EQ^MIOTASSERT($GET(CTX("auth","sub")),"kidwins","[MIOAUTHCLT2][T001][sub]")
 QUIT
 ;
T002 ; unknown kid falls back to client_id map
 DO RESET
 NEW META
 SET META("authRequired")=1
 DO ADDM^MIOROUTE("GET","/client2/fallback","HOK^MIOAUTHCLT2",.META)
 DO COMPILE^MIOROUTE
 NEW CONF,REQ,CTX,DEV,OUT,OP,NOW,TOK
 KILL CONF,REQ,CTX
 SET CONF("auth","protectMode")="route"
 SET CONF("auth","mode")="jwt"
 SET CONF("auth","jwt","hmacSecretByKid","other")="other-secret"
 SET CONF("auth","jwt","hmacSecretByClient","client-a")="client-secret-a"
 DO ENSURE^MIOMW(.CONF)
 SET NOW=$$NOWS^MIOAUTHJWT()
 SET TOK=$$MKJWTKID("client-secret-a","missing-kid","{""sub"":""claimfb"",""client_id"":""client-a"",""exp"":"_(NOW+3600)_"}")
 SET REQ("method")="GET",REQ("path")="/client2/fallback",REQ("hdr","authorization")="Bearer "_TOK
 SET CTX("request_id")="clt2002",CTX("ran")=0
 SET OP="tmp/mio_authclt2_t002.out"
 OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
 DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
 CLOSE DEV USE $PRINCIPAL
 DO READALL(OP,.OUT)
 DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHCLT2][T002][status]")
 DO EQ^MIOTASSERT($GET(CTX("auth","claim","client_id")),"client-a","[MIOAUTHCLT2][T002][client_id]")
 QUIT
 ;
T003 ; empty kid secret falls through to client_id map
 DO RESET
 NEW META
 SET META("authRequired")=1
 DO ADDM^MIOROUTE("GET","/client2/blankkid","HOK^MIOAUTHCLT2",.META)
 DO COMPILE^MIOROUTE
 NEW CONF,REQ,CTX,DEV,OUT,OP,NOW,TOK
 KILL CONF,REQ,CTX
 SET CONF("auth","protectMode")="route"
 SET CONF("auth","mode")="jwt"
 SET CONF("auth","jwt","hmacSecretByKid","k1")=""
 SET CONF("auth","jwt","hmacSecretByClient","client-a")="client-secret-a"
 DO ENSURE^MIOMW(.CONF)
 SET NOW=$$NOWS^MIOAUTHJWT()
 SET TOK=$$MKJWTKID("client-secret-a","k1","{""sub"":""blankkid"",""client_id"":""client-a"",""exp"":"_(NOW+3600)_"}")
 SET REQ("method")="GET",REQ("path")="/client2/blankkid",REQ("hdr","authorization")="Bearer "_TOK
 SET CTX("request_id")="clt2003",CTX("ran")=0
 SET OP="tmp/mio_authclt2_t003.out"
 OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
 DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
 CLOSE DEV USE $PRINCIPAL
 DO READALL(OP,.OUT)
 DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHCLT2][T003][status]")
 DO EQ^MIOTASSERT($GET(CTX("auth","sub")),"blankkid","[MIOAUTHCLT2][T003][sub]")
 QUIT
 ;
T004 ; resolver is not called when kid map already resolves
 DO RESET
 NEW META
 SET META("authRequired")=1
 DO ADDM^MIOROUTE("GET","/client2/nocallkid","HOK^MIOAUTHCLT2",.META)
 DO COMPILE^MIOROUTE
 NEW CONF,REQ,CTX,DEV,OUT,OP,NOW,TOK
 KILL CONF,REQ,CTX
 SET CONF("auth","protectMode")="route"
 SET CONF("auth","mode")="jwt"
 SET CONF("auth","jwt","hmacSecretByKid","k1")="kid-secret-1"
 SET CONF("auth","jwt","hs256Resolve")="HSRMARK^MIOAUTHCLT2"
 DO ENSURE^MIOMW(.CONF)
 SET NOW=$$NOWS^MIOAUTHJWT()
 SET TOK=$$MKJWTKID("kid-secret-1","k1","{""sub"":""nocallkid"",""client_id"":""dyn-mark"",""exp"":"_(NOW+3600)_"}")
 SET REQ("method")="GET",REQ("path")="/client2/nocallkid",REQ("hdr","authorization")="Bearer "_TOK
 SET CTX("request_id")="clt2004",CTX("ran")=0
 SET OP="tmp/mio_authclt2_t004.out"
 OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
 DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
 CLOSE DEV USE $PRINCIPAL
 DO READALL(OP,.OUT)
 DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHCLT2][T004][status]")
 DO EQ^MIOTASSERT($GET(CTX("resolverCalled")),"","[MIOAUTHCLT2][T004][resolver skipped]")
 QUIT
 ;
T005 ; resolver is not called when client_id map already resolves
 DO RESET
 NEW META
 SET META("authRequired")=1
 DO ADDM^MIOROUTE("GET","/client2/nocallclient","HOK^MIOAUTHCLT2",.META)
 DO COMPILE^MIOROUTE
 NEW CONF,REQ,CTX,DEV,OUT,OP,NOW,TOK
 KILL CONF,REQ,CTX
 SET CONF("auth","protectMode")="route"
 SET CONF("auth","mode")="jwt"
 SET CONF("auth","jwt","hmacSecretByClient","client-a")="client-secret-a"
 SET CONF("auth","jwt","hs256Resolve")="HSRMARK^MIOAUTHCLT2"
 DO ENSURE^MIOMW(.CONF)
 SET NOW=$$NOWS^MIOAUTHJWT()
 SET TOK=$$MKJWT("client-secret-a","{""sub"":""nocallclient"",""client_id"":""client-a"",""exp"":"_(NOW+3600)_"}")
 SET REQ("method")="GET",REQ("path")="/client2/nocallclient",REQ("hdr","authorization")="Bearer "_TOK
 SET CTX("request_id")="clt2005",CTX("ran")=0
 SET OP="tmp/mio_authclt2_t005.out"
 OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
 DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
 CLOSE DEV USE $PRINCIPAL
 DO READALL(OP,.OUT)
 DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHCLT2][T005][status]")
 DO EQ^MIOTASSERT($GET(CTX("resolverCalled")),"","[MIOAUTHCLT2][T005][resolver skipped]")
 QUIT
 ;
T006 ; resolver can resolve by kid when client_id is absent
 DO RESET
 NEW META
 SET META("authRequired")=1
 DO ADDM^MIOROUTE("GET","/client2/resolvekid","HOK^MIOAUTHCLT2",.META)
 DO COMPILE^MIOROUTE
 NEW CONF,REQ,CTX,DEV,OUT,OP,NOW,TOK
 KILL CONF,REQ,CTX
 SET CONF("auth","protectMode")="route"
 SET CONF("auth","mode")="jwt"
 SET CONF("auth","jwt","hs256Resolve")="HSRKID^MIOAUTHCLT2"
 DO ENSURE^MIOMW(.CONF)
 SET NOW=$$NOWS^MIOAUTHJWT()
 SET TOK=$$MKJWTKID("dyn-kid-secret","dyn-k1","{""sub"":""dynkid"",""exp"":"_(NOW+3600)_"}")
 SET REQ("method")="GET",REQ("path")="/client2/resolvekid",REQ("hdr","authorization")="Bearer "_TOK
 SET CTX("request_id")="clt2006",CTX("ran")=0
 SET OP="tmp/mio_authclt2_t006.out"
 OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
 DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
 CLOSE DEV USE $PRINCIPAL
 DO READALL(OP,.OUT)
 DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHCLT2][T006][status]")
 DO EQ^MIOTASSERT($GET(CTX("auth","sub")),"dynkid","[MIOAUTHCLT2][T006][sub]")
 QUIT
 ;
T007 ; client_id map with wrong signing secret denies as bad signature
 DO RESET
 NEW META
 SET META("authRequired")=1
 DO ADDM^MIOROUTE("GET","/client2/badsig","HOK^MIOAUTHCLT2",.META)
 DO COMPILE^MIOROUTE
 NEW CONF,REQ,CTX,DEV,OUT,OP,NOW,TOK
 KILL CONF,REQ,CTX
 SET CONF("auth","protectMode")="route"
 SET CONF("auth","mode")="jwt"
 SET CONF("auth","jwt","hmacSecretByClient","client-a")="expected-secret"
 DO ENSURE^MIOMW(.CONF)
 SET NOW=$$NOWS^MIOAUTHJWT()
 SET TOK=$$MKJWT("wrong-secret","{""sub"":""badone"",""client_id"":""client-a"",""exp"":"_(NOW+3600)_"}")
 SET REQ("method")="GET",REQ("path")="/client2/badsig",REQ("hdr","authorization")="Bearer "_TOK
 SET CTX("request_id")="clt2007",CTX("ran")=0
 SET OP="tmp/mio_authclt2_t007.out"
 OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
 DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
 CLOSE DEV USE $PRINCIPAL
 DO READALL(OP,.OUT)
 DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHCLT2][T007][status]")
 DO EQ^MIOTASSERT($SELECT(OUT["jwt_bad_signature":1,1:0),1,"[MIOAUTHCLT2][T007][reason]")
 QUIT
 ;
T008 ; roles from client-secret token satisfy route RBAC
 DO RESET
 NEW META
 SET META("authRequired")=1
 SET META("roles")="ops"
 DO ADDM^MIOROUTE("GET","/client2/roles","HOK^MIOAUTHCLT2",.META)
 DO COMPILE^MIOROUTE
 NEW CONF,REQ,CTX,DEV,OUT,OP,NOW,TOK
 KILL CONF,REQ,CTX
 SET CONF("auth","protectMode")="route"
 SET CONF("auth","mode")="jwt"
 SET CONF("auth","jwt","hmacSecretByClient","client-role")="role-secret"
 SET CONF("auth","jwt","rolesClaim")="roles"
 DO ENSURE^MIOMW(.CONF)
 SET NOW=$$NOWS^MIOAUTHJWT()
 SET TOK=$$MKJWT("role-secret","{""sub"":""roleuser"",""client_id"":""client-role"",""roles"":""user,ops"",""exp"":"_(NOW+3600)_"}")
 SET REQ("method")="GET",REQ("path")="/client2/roles",REQ("hdr","authorization")="Bearer "_TOK
 SET CTX("request_id")="clt2008",CTX("ran")=0
 SET OP="tmp/mio_authclt2_t008.out"
 OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
 DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
 CLOSE DEV USE $PRINCIPAL
 DO READALL(OP,.OUT)
 DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHCLT2][T008][status]")
 DO EQ^MIOTASSERT($GET(CTX("auth","roles","ops")),1,"[MIOAUTHCLT2][T008][role]")
 QUIT
 ;
T009 ; custom clientIdClaim still allows kid map precedence
 DO RESET
 NEW META
 SET META("authRequired")=1
 DO ADDM^MIOROUTE("GET","/client2/customclaimkid","HOK^MIOAUTHCLT2",.META)
 DO COMPILE^MIOROUTE
 NEW CONF,REQ,CTX,DEV,OUT,OP,NOW,TOK
 KILL CONF,REQ,CTX
 SET CONF("auth","protectMode")="route"
 SET CONF("auth","mode")="jwt"
 SET CONF("auth","jwt","clientIdClaim")="iss"
 SET CONF("auth","jwt","hmacSecretByKid","k9")="kid-secret-9"
 SET CONF("auth","jwt","hmacSecretByClient","issuer-a")="wrong-issuer-secret"
 DO ENSURE^MIOMW(.CONF)
 SET NOW=$$NOWS^MIOAUTHJWT()
 SET TOK=$$MKJWTKID("kid-secret-9","k9","{""sub"":""ck9"",""iss"":""issuer-a"",""exp"":"_(NOW+3600)_"}")
 SET REQ("method")="GET",REQ("path")="/client2/customclaimkid",REQ("hdr","authorization")="Bearer "_TOK
 SET CTX("request_id")="clt2009",CTX("ran")=0
 SET OP="tmp/mio_authclt2_t009.out"
 OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
 DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
 CLOSE DEV USE $PRINCIPAL
 DO READALL(OP,.OUT)
 DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHCLT2][T009][status]")
 DO EQ^MIOTASSERT($GET(CTX("auth","sub")),"ck9","[MIOAUTHCLT2][T009][sub]")
 QUIT
 ;
T010 ; direct VERIFY with client lookup populates auth context without routing
 NEW CONF,REQ,CTX,ERR,NOW,TOK,OK
 KILL CONF,REQ,CTX,ERR
 SET CONF("auth","jwt","hmacSecretByClient","client-direct")="direct-secret"
 SET CONF("auth","jwt","rolesClaim")="roles"
 SET NOW=$$NOWS^MIOAUTHJWT()
 SET TOK=$$MKJWT("direct-secret","{""sub"":""direct1"",""client_id"":""client-direct"",""roles"":""admin,ops"",""exp"":"_(NOW+3600)_"}")
 SET REQ("hdr","authorization")="Bearer "_TOK
 SET OK=$$VERIFY^MIOAUTHJWT(.CONF,.REQ,.CTX,.ERR)
 DO EQ^MIOTASSERT(OK,1,"[MIOAUTHCLT2][T010][ok]")
 DO EQ^MIOTASSERT($GET(CTX("auth","ok")),1,"[MIOAUTHCLT2][T010][auth ok]")
 DO EQ^MIOTASSERT($GET(CTX("auth","sub")),"direct1","[MIOAUTHCLT2][T010][sub]")
 DO EQ^MIOTASSERT($GET(CTX("auth","claim","client_id")),"client-direct","[MIOAUTHCLT2][T010][client_id]")
 DO EQ^MIOTASSERT($GET(CTX("auth","roles","admin")),1,"[MIOAUTHCLT2][T010][admin role]")
 QUIT
 ;
HOK(DEV,CONF,REQ,CTX)
 SET CTX("ran")=1
 NEW OBJ
 SET OBJ("ok")=1
 SET OBJ("sub")=$GET(CTX("auth","sub"))
 SET OBJ("routine")="MIOAUTHCLT2"
 DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
 SET CTX("status")=200
 QUIT
 ;
HSRMARK(CONF,CTX,HOBJ,POBJ,SECRET,ERR)
 SET CTX("resolverCalled")=1
 SET SECRET=""
 QUIT 0
 ;
HSRKID(CONF,CTX,HOBJ,POBJ,SECRET,ERR)
 NEW KID
 SET KID=$GET(HOBJ("kid"))
 IF KID="dyn-k1" SET SECRET="dyn-kid-secret" QUIT 1
 QUIT 0
