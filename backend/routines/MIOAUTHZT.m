MIOAUTHZT ; Auth (JWT + RBAC/ABAC) tests
	;
	;
	;T001 HS256 JWT allows route (role admin)
	;T002 RBAC denies when role missing
	;T003 ABAC owner check: ownerParam=id, ownerClaim=sub
	;T004 missing Authorization header → 401
	;T005 malformed Bearer token → 401
	;T006 bad signature → 401
	;T007 expired token → 401
	;T008 token not yet valid (nbf) → 401
	;T009 roles success with second role in CSV → 200
	;T010 owner success when param matches sub → 200
	;T011 issuer mismatch → 401
	;T012 audience mismatch → 401
	;T013 claims.* route metadata mismatch → 403
	;T014 catches prefix parsing changes
	;T015 catches base64url validation regressions
	;T016 catches algorithm handling mistakes
	;T017 verifies skew logic really works
	;T018 verifies positive claim matching, not just mismatch denial
	;T019 verifies configurable role claim names
	;T020 verifies trimming logic on roles
	;T021 and T022 verify combined authorization gates
	;T023 verifies missing-secret configuration handling
	;T024 exp exactly now with zero skew -> 200
	;T025 nbf exactly now with zero skew -> 200
	;T026 custom bearer prefix accepted -> 200
	;T027 token without sub still auths -> 200 and empty sub
	;T028 authRequired route without roles/claims/owner -> 200
	;T029 multiple claims all match -> 200
	;T030 first claim mismatch denies -> 403
	;T031 roles empty string does not satisfy required role -> 403
	;T032 repeated commas in roles still finds admin -> 200
	;T033 owner route with missing ownerParam denies -> 403 not_owner
	;T034 malformed header JSON token -> 401 jwt_alg_missing
	;T035 auth mode jwt with public route still allows access -> 200
	;T036 no exp claim -> 200 by current semantics
	;T037 missing required custom claim -> 403 claim_mismatch
	;T038 duplicate roles still satisfy admin
	;T039 role matching is case-sensitive -> 403
	;T040 four JWT segments -> 401 jwt_format
	;T041 invalid JSON payload but valid signature -> 401 json error
	;T042 owner claim empty -> 403 not_owner
	;T043 protected request then public request in same test
	;T044 stale auth context does not grant next request with bad token
	;T045 RS256 configured without verifier -> 401 jwt_rs256_no_verifier
	;
	;
	;
	;
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
	DO T014
	DO T015
	DO T016
	DO T017
	DO T018
	DO T019
	DO T020
	DO T021
	DO T022
	DO T023
	DO T024
	DO T025
	DO T026
	DO T027
	DO T028
	DO T029
	DO T030
	DO T031
	DO T032
	DO T033
	DO T034
	DO T035
	DO T036
	DO T037
	DO T038
	DO T039
	DO T040
	DO T041
	DO T042
	DO T043
	DO T044
	DO T045
	DO T046
	DO T047
	DO T048
	DO T049
	DO T050
	DO T051
	DO T052
	DO T053
	DO T054
	DO T055
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
T014 ; Wrong bearer prefix -> 401 jwt_missing
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Token "_TOK
	SET CTX("request_id")="az014"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t014.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[T014][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T014][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_missing":1,1:0),1,"[T014][reason]")
	QUIT
	;
T015 ; Invalid base64url chars in token -> 401 b64url_char
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
	SET REQ("hdr","authorization")="Bearer abc$.def.ghi"
	SET CTX("request_id")="az015"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t015.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[T015][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T015][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["b64url_char":1,1:0),1,"[T015][reason]")
	QUIT
	;
T016 ; Unsupported alg -> 401 jwt_alg_unsupported
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
	SET HJSON="{""alg"":""HS512"",""typ"":""JWT""}"
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET PJSON="{""sub"":""u1"",""exp"":"_(NOW+3600)_"}"
	SET H64=$$B64EURL^MIOAUTHJWT(HJSON)
	SET P64=$$B64EURL^MIOAUTHJWT(PJSON)
	SET DATA=H64_"."_P64
	SET SIG=$$HMACSHA256^MIOAUTHJWT(DATA,SECRET,.ERR)
	SET TOK=DATA_"."_$$B64EURL^MIOAUTHJWT(SIG)
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az016"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t016.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[T016][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T016][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_alg_unsupported":1,1:0),1,"[T016][reason]")
	QUIT
	;
T017 ; Expired by 1 second but allowed by skew -> 200
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
	SET CONF("auth","jwt","clockSkewSeconds")=60
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW-1)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az017"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t017.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T017][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T017][handler ran]")
	QUIT
	;
T018 ; Claims.department exact match -> 200
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""department"":""billing"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az018"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t018.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T018][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T018][handler ran]")
	DO EQ^MIOTASSERT($GET(CTX("auth","claim","department")),"billing","[T018][claim]")
	QUIT
	;
T019 ; Alternate roles claim name groups -> 200
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
	SET CONF("auth","jwt","rolesClaim")="groups"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""groups"":""staff,admin"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az019"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t019.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T019][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T019][handler ran]")
	DO EQ^MIOTASSERT($GET(CTX("auth","roles","admin")),1,"[T019][admin role]")
	QUIT
	;
T020 ; Roles CSV trims whitespace -> 200
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":"" user , admin "",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az020"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t020.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T020][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T020][handler ran]")
	DO EQ^MIOTASSERT($GET(CTX("auth","roles","admin")),1,"[T020][admin role]")
	QUIT
	;
T021 ; Combined role + owner success -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	SET META("ownerParam")="id"
	SET META("ownerClaim")="sub"
	DO ADDM^MIOROUTE("GET","/item/:id","HOK^MIOAUTHZT",.META)
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
	SET REQ("path")="/item/u1"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az021"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t021.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T021][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T021][handler ran]")
	QUIT
	;
T022 ; Combined role ok but owner mismatch -> 403 not_owner
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	SET META("ownerParam")="id"
	SET META("ownerClaim")="sub"
	DO ADDM^MIOROUTE("GET","/item/:id","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	SET CONF("auth","jwt","rolesClaim")="roles"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""admin"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/item/u2"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az022"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t022.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[T022][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T022][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["not_owner":1,1:0),1,"[T022][reason]")
	QUIT
	;
T023 ; Missing HMAC secret -> 401 jwt_hmac_secret_missing
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az023"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t023.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[T023][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T023][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_hmac_secret_missing":1,1:0),1,"[T023][reason]")
	QUIT
T024 ; exp exactly now with zero skew -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","clockSkewSeconds")=0
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET CONF("auth","jwt","now")=NOW
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_NOW_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az024"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t024.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T024][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T024][handler ran]")
	QUIT
	;
T025 ; nbf exactly now with zero skew -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","clockSkewSeconds")=0
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET CONF("auth","jwt","now")=NOW
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""nbf"":"_NOW_",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az025"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t025.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T025][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T025][handler ran]")
	QUIT
	;
T026 ; custom bearer prefix accepted -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","bearerPrefix")="Token "
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Token "_TOK
	SET CTX("request_id")="az026"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t026.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T026][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T026][handler ran]")
	QUIT
	;
T027 ; token without sub still auths -> 200 and empty sub
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
	SET TOK=$$MKJWT(SECRET,"{""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az027"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t027.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T027][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T027][handler ran]")
	DO EQ^MIOTASSERT($GET(CTX("auth","sub")),"","[T027][sub empty]")
	QUIT
	;
T028 ; authRequired route without roles/claims/owner -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/plainsecure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u9"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/plainsecure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az028"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t028.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T028][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T028][handler ran]")
	QUIT
	;
T029 ; multiple claims all match -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("claims.department")="billing"
	SET META("claims.region")="east"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""department"":""billing"",""region"":""east"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az029"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t029.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T029][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T029][handler ran]")
	QUIT
	;
T030 ; first claim mismatch denies -> 403
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("claims.department")="billing"
	SET META("claims.region")="east"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""department"":""sales"",""region"":""east"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az030"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t030.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[T030][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T030][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["claim_mismatch:department":1,1:0),1,"[T030][reason]")
	QUIT
	;
T031 ; roles empty string does not satisfy required role -> 403
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rolesClaim")="roles"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":"""",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az031"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t031.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[T031][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T031][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["role_required":1,1:0),1,"[T031][reason]")
	QUIT
	;
T032 ; repeated commas in roles still finds admin -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rolesClaim")="roles"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":"",,admin,,"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az032"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t032.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T032][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T032][handler ran]")
	DO EQ^MIOTASSERT($GET(CTX("auth","roles","admin")),1,"[T032][admin role]")
	QUIT
	;
T033 ; owner route with missing ownerParam denies -> 403 not_owner
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("ownerParam")="missingid"
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
	SET CTX("request_id")="az033"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t033.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[T033][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T033][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["not_owner":1,1:0),1,"[T033][reason]")
	QUIT
T034 ; malformed header JSON token -> 401 jwt_alg_missing
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
	SET HJSON="{""typ"":""JWT""}"
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET PJSON="{""sub"":""u1"",""exp"":"_(NOW+3600)_"}"
	SET H64=$$B64EURL^MIOAUTHJWT(HJSON)
	SET P64=$$B64EURL^MIOAUTHJWT(PJSON)
	SET DATA=H64_"."_P64
	SET SIG=$$HMACSHA256^MIOAUTHJWT(DATA,SECRET,.ERR)
	SET TOK=DATA_"."_$$B64EURL^MIOAUTHJWT(SIG)
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az034"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t034.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[T034][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T034][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_alg_missing":1,1:0),1,"[T034][reason]")
	QUIT
	;
T035 ; auth mode jwt with public route still allows access -> 200
	DO RESET
	NEW META
	DO ADDM^MIOROUTE("GET","/public","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	DO ENSURE^MIOMW(.CONF)
	SET REQ("method")="GET"
	SET REQ("path")="/public"
	SET CTX("request_id")="az035"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t035.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T035][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T035][handler ran]")
	QUIT
T036 ; no exp claim -> 200 by current semantics
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1""}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az036"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t036.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T036][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T036][handler ran]")
	QUIT
	;
T037 ; missing required custom claim -> 403 claim_mismatch
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az037"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t037.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[T037][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T037][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["claim_mismatch:department":1,1:0),1,"[T037][reason]")
	QUIT
	;
T038 ; duplicate roles still satisfy admin
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rolesClaim")="roles"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""admin,admin,user"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az038"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t038.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T038][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T038][handler ran]")
	DO EQ^MIOTASSERT($GET(CTX("auth","roles","admin")),1,"[T038][admin role]")
	QUIT
	;
T039 ; role matching is case-sensitive -> 403
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rolesClaim")="roles"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""Admin"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az039"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t039.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[T039][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T039][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["role_required":1,1:0),1,"[T039][reason]")
	QUIT
	;
T040 ; four JWT segments -> 401 jwt_format
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
	SET REQ("hdr","authorization")="Bearer a.b.c.d"
	SET CTX("request_id")="az040"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t040.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[T040][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T040][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_format":1,1:0),1,"[T040][reason]")
	QUIT
	;
T041 ; invalid JSON payload but valid signature -> 401 json error
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX,ERR
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET HJSON="{""alg"":""HS256"",""typ"":""JWT""}"
	SET PJSON="{bad json"
	SET H64=$$B64EURL^MIOAUTHJWT(HJSON)
	SET P64=$$B64EURL^MIOAUTHJWT(PJSON)
	SET DATA=H64_"."_P64
	SET SIG=$$HMACSHA256^MIOAUTHJWT(DATA,SECRET,.ERR)
	SET TOK=DATA_"."_$$B64EURL^MIOAUTHJWT(SIG)
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az041"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t041.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[T041][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T041][handler not ran]")
	QUIT
	;
T042 ; owner claim empty -> 403 not_owner
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":"""",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/item/u1"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az042"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t042.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[T042][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T042][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["not_owner":1,1:0),1,"[T042][reason]")
	QUIT
	;
T043 ; protected request then public request in same test
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	KILL META
	DO ADDM^MIOROUTE("GET","/public","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	;
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	;
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az043a"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t043a.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT1)
	DO EQ^MIOTASSERT($SELECT(OUT1["200":1,1:0),1,"[T043A][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T043A][handler ran]")
	;
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/public"
	SET CTX("request_id")="az043b"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t043b.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT2)
	DO EQ^MIOTASSERT($SELECT(OUT2["200":1,1:0),1,"[T043B][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T043B][handler ran]")
	QUIT
	;
T044 ; stale auth context does not grant next request with bad token
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	;
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rolesClaim")="roles"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	;
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""admin"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az044a"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t044a.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT1)
	DO EQ^MIOTASSERT($SELECT(OUT1["200":1,1:0),1,"[T044A][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T044A][handler ran]")
	;
	; new request with bad token, fresh context
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer abc.def"
	SET CTX("request_id")="az044b"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t044b.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT2)
	DO EQ^MIOTASSERT($SELECT(OUT2["401":1,1:0),1,"[T044B][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T044B][handler not ran]")
	QUIT
	;
T045 ; RS256 configured without verifier -> 401 jwt_rs256_no_verifier
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX,ERR
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	DO ENSURE^MIOMW(.CONF)
	SET HJSON="{""alg"":""RS256"",""typ"":""JWT""}"
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET PJSON="{""sub"":""u1"",""exp"":"_(NOW+3600)_"}"
	SET TOK=$$B64EURL^MIOAUTHJWT(HJSON)_"."_$$B64EURL^MIOAUTHJWT(PJSON)_"."_$$B64EURL^MIOAUTHJWT("sig")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az045"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t045.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[T045][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T045][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_rs256_no_verifier":1,1:0),1,"[T045][reason]")
	QUIT
T046 ; public route ignores bad auth header -> 200
	DO RESET
	NEW META
	DO ADDM^MIOROUTE("GET","/public","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	DO ENSURE^MIOMW(.CONF)
	SET REQ("method")="GET"
	SET REQ("path")="/public"
	SET REQ("hdr","authorization")="Bearer abc.def"
	SET CTX("request_id")="az046"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t046.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T046][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T046][handler ran]")
	QUIT
	;
T047 ; custom bearer prefix mismatch -> 401 jwt_missing
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","bearerPrefix")="Token "
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az047"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t047.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[T047][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T047][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_missing":1,1:0),1,"[T047][reason]")
	QUIT
	;
T048 ; empty signature segment -> 401 jwt_format
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX,ERR
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET HJSON="{""alg"":""HS256"",""typ"":""JWT""}"
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET PJSON="{""sub"":""u1"",""exp"":"_(NOW+3600)_"}"
	SET TOK=$$B64EURL^MIOAUTHJWT(HJSON)_"."_$$B64EURL^MIOAUTHJWT(PJSON)_"."
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az048"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t048.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[T048][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T048][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_format":1,1:0),1,"[T048][reason]")
	QUIT
	;
T049 ; empty payload segment -> 401 jwt_format
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
	SET REQ("hdr","authorization")="Bearer abc..def"
	SET CTX("request_id")="az049"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t049.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[T049][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T049][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_format":1,1:0),1,"[T049][reason]")
	QUIT
	;
T050 ; invalid base64url length -> 401 b64url_length
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
	SET REQ("hdr","authorization")="Bearer a.abcde.c"
	SET CTX("request_id")="az050"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t050.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[T050][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T050][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["b64url_length":1,1:0),1,"[T050][reason]")
	QUIT
	;
T051 ; audience exact match -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","audience")="good-aud"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""aud"":""good-aud"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az051"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t051.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T051][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T051][handler ran]")
	QUIT
	;
T052 ; issuer exact match -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","issuer")="good-iss"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""iss"":""good-iss"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az052"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t052.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T052][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T052][handler ran]")
	QUIT
	;
T053 ; alternate roles claim missing -> 403 role_required
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rolesClaim")="groups"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""admin"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az053"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t053.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[T053][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T053][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["role_required":1,1:0),1,"[T053][reason]")
	QUIT
	;
T054 ; claim mismatch on second required claim -> 403
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("claims.department")="billing"
	SET META("claims.region")="east"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""department"":""billing"",""region"":""west"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az054"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t054.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[T054][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T054][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["claim_mismatch:region":1,1:0),1,"[T054][reason]")
	QUIT
	;
T055 ; stale admin does not leak into fresh low-privilege request
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	;
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rolesClaim")="roles"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	;
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""admin"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az055a"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t055a.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT1)
	DO EQ^MIOTASSERT($SELECT(OUT1["200":1,1:0),1,"[T055A][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[T055A][handler ran]")
	;
	KILL REQ,CTX
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""user"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az055b"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t055b.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT2)
	DO EQ^MIOTASSERT($SELECT(OUT2["403":1,1:0),1,"[T055B][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[T055B][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT2["role_required":1,1:0),1,"[T055B][reason]")
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