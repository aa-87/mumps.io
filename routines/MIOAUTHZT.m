MIOAUTHZT ; Auth (JWT + RBAC/ABAC) tests
	;
	;
	NEW $ET SET $ET="DO STERR^MIOAUTHZT"
	D T001 ; HS256 JWT allows route (role admin)
	D T002 ; RBAC denies when role missing
	D T003 ; ABAC owner check: ownerParam=id, ownerClaim=sub
	D T004 ; missing Authorization header → 401
	D T005 ; malformed Bearer token → 401
	D T006 ; bad signature → 401
	D T007 ; expired token → 401
	D T008 ; token not yet valid (nbf) → 401
	D T009 ; roles success with second role in CSV → 200
	D T010 ; owner success when param matches sub → 200
	D T011 ; issuer mismatch → 401
	D T012 ; audience mismatch → 401
	D T013 ; claims.* route metadata mismatch → 403
	D T014 ; catches prefix parsing changes
	D T015 ; catches base64url validation regressions
	D T016 ; catches algorithm handling mistakes
	D T017 ; verifies skew logic really works
	D T018 ; verifies positive claim matching, not just mismatch denial
	D T019 ; verifies configurable role claim names
	D T020 ; verifies trimming logic on roles
	D T021 ; and T022 verify combined authorization gates
	D T023 ; verifies missing-secret configuration handling
	D T024 ; exp exactly now with zero skew -> 200
	D T025 ; nbf exactly now with zero skew -> 200
	D T026 ; custom bearer prefix accepted -> 200
	D T027 ; token without sub still auths -> 200 and empty sub
	D T028 ; authRequired route without roles/claims/owner -> 200
	D T029 ; multiple claims all match -> 200
	D T030 ; first claim mismatch denies -> 403
	D T031 ; roles empty string does not satisfy required role -> 403
	D T032 ; repeated commas in roles still finds admin -> 200
	D T033 ; owner route with missing ownerParam denies -> 403 not_owner
	D T034 ; malformed header JSON token -> 401 jwt_alg_missing
	D T035 ; auth mode jwt with public route still allows access -> 200
	D T036 ; no exp claim -> 200 by current semantics
	D T037 ; missing required custom claim -> 403 claim_mismatch
	D T038 ; duplicate roles still satisfy admin
	D T039 ; role matching is case-sensitive -> 403
	D T040 ; four JWT segments -> 401 jwt_format
	D T041 ; invalid JSON payload but valid signature -> 401 json error
	D T042 ; owner claim empty -> 403 not_owner
	D T043 ; protected request then public request in same test
	D T044 ; stale auth context does not grant next request with bad token
	D T045 ; RS256 configured without verifier -> 401 jwt_rs256_no_verifier
	D T046 ; public route ignores bad auth header -> 200
	D T047 ; custom bearer prefix mismatch -> 401 jwt_missing
	D T048 ; empty signature segment -> 401 jwt_format
	D T049 ; empty payload segment -> 401 jwt_format
	D T050 ; invalid base64url length -> 401 b64url_length
	D T051 ; audience exact match -> 200
	D T052 ; issuer exact match -> 200
	D T053 ; alternate roles claim missing -> 403 role_required
	D T054 ; claim mismatch on second required claim -> 403
	D T055 ; stale admin does not leak into fresh low-privilege request
	D T056 ; RS256 with missing verifier entry -> 401 jwt_rs256_no_verifier
	D T057 ; empty bearer prefix accepts raw token header value
	D T058 ; explicit now override can keep expired token valid under skew
	D T059 ; explicit now override can force not-yet-valid denial
	D T060 ; claim exact match with empty string -> 200
	D T061 ; protected route with bad token then good token in same test
	D T062 ; owner passes but role fails first -> 403 role_required
	D T063 ; owner fails even when claim requirement passes -> 403 not_owner
	D T064 ; issuer empty config does not enforce issuer
	D T065 ; audience empty config does not enforce audience
	D T066 ; authRequired explicit 0 does not enforce auth -> 200
	D T067 ; issuer + audience both exact match -> 200
	D T068 ; missing rolesClaim with owner-only route still allows owner success -> 200
	D T069 ; roles required plus matching claim -> 200
	D T070 ; roles pass but missing required claim -> 403 claim_mismatch
	D T071 ; owner passes with numeric-looking id string exact match -> 200
	D T072 ; owner fails with numeric-looking id non-exact mismatch -> 403 not_owner
	D T073 ; route metadata change after RESET does not leak from prior test
	D T074 ; malformed JSON header with alg omitted but valid payload/signature -> 401 jwt_alg_missing or json failure
	D T075 ; protected route with valid token and unrelated extra claims -> 200
	D T076 ; claim value with spaces exact match -> 200
	D T077 ; claim value with spaces mismatch -> 403
	D T078 ; roles required any-of first role matches -> 200
	D T079 ; roles required any-of second role matches -> 200
	D T080 ; roles required any-of none match -> 403
	D T081 ; roles metadata with spaces still matches -> 200
	D T082 ; protected POST route works with JWT -> 200
	D T083 ; same path different method metadata isolated
	D T084 ; token with only signature mismatch and same payload -> 401
	D T085 ; path param with dash owner exact match -> 200
	D T086 ; route requires manager, token has admin and manager -> 200
	D T087 ; claim exact numeric-looking string match -> 200
	D T088 ; claim numeric-looking string mismatch -> 403
	D T089 ; token with trailing spaces in auth header after token -> 401 bad signature
	D T090 ; route with only claim requirement denies unauthenticated -> 401
	D T091 ; route with role and claim both fail still returns 403
	D T092 ; malformed auth header without token -> 401 jwt_missing
	D T093 ; route owner + claim both pass -> 200
	D T094 ; auth context fresh after public request then protected request
	D T095 ; explicit now override with future value expires otherwise-valid token -> 401
	D T096 ; token with only sub and issuer/audience unset -> 200
	D T097 ; empty roles claim on non-role route still allows -> 200
	D T098 ; route role required and roles claim omitted -> 403
	D T099 ; claim present but route expects different empty/non-empty -> 403
	D T100 ; path route metadata survives multiple compile calls
	D T101 ; wrong method on protected route should not accidentally authorize matched path
	D T102 ; token with valid signature and extra dot in header value -> 401 jwt_format
	D T103 ; claim names do not collide with sub population
	D T104 ; owner check with slash-free unusual chars underscore exact match -> 200
	D T105 ; good token reused after prior deny still passes with fresh context
	D T106 ; RS256 verifier true -> 200
	D T107 ; RS256 verifier false -> 401
	D T108 ; RS256 verifier exception -> 401 verifier exception
	D T109 ; RS256 + RBAC pass -> 200
	D T110 ; RS256 + RBAC deny -> 403
	D T111 ; RS256 + owner pass -> 200
	D T112 ; RS256 + owner deny -> 403
	D T113 ; RS256 verifier bad entry format -> 401
	D T114 ; RS256 verifier illegal identifier entry -> 401
	D T115 ; RS256 verifier true plus claim requirement pass -> 200
	D T116 ; repeated successful dispatches with same valid HS256 token -> 200 both times
	D T117 ; repeated denied dispatches with same bad-signature token -> 401 both times
	D T118 ; HS256 token on RS256-only config without verifier -> 401 jwt_alg_unsupported or jwt_rs256_no_verifier not triggered
	D T119 ; token with sub only reused across owner route mismatch then match
	D T120 ; custom rolesClaim and unrelated default roles claim present -> custom wins
	D T121 ; malformed payload JSON with valid header and signature still 401 on every attempt
	D T122 ; route requiring empty-string role name is effectively unsatisfied -> 403
	D T123 ; claim with punctuation exact match -> 200
	D T124 ; protected route with RS256 valid then HS256 valid in same config session
	D T125 ; same valid token on two different protected routes with different policies
	D T126 ; multiple extra claims preserved in auth claim map -> 200
	D T127 ; same route protected then metadata changed after RESET to public
	D T128 ; owner check with long identifier exact match -> 200
	D T129 ; role deny does not populate handler status 200
	D T130 ; claim mismatch deny does not remove auth ok marker
	D T131 ; public route after denied protected route stays public
	D T132 ; issuer enforced while audience empty only checks issuer
	D T133 ; audience enforced while issuer empty only checks audience
	D T134 ; same valid token under different now override can pass then expire
	D T135 ; claim and role both pass on one route then different route denies on role only
	D T136 ; same token across three routes with pass, deny, pass
	D T137 ; empty custom bearer prefix with malformed raw token -> 401 jwt_format
	D T138 ; claim name with mixed case exact match
	D T139 ; claim name case mismatch denies
	D T140 ; roles claim contains spaces only -> 403 role_required
	D T141 ; two owner routes same token one pass one deny
	D T142 ; token without sub fails owner route but still authenticates
	D T143 ; issuer mismatch on RS256 verifier-true still denies at claim check
	D T144 ; audience mismatch on RS256 verifier-true still denies at claim check
	D T145 ; same good token reused after RS256 verifier exception route does not poison HS256
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
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T001][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T001][handler ran]")
	DO EQ^MIOTASSERT($GET(CTX("auth","ok")),1,"[MIOAUTHZT][T001][auth ok]")
	DO EQ^MIOTASSERT($GET(CTX("auth","roles","admin")),1,"[MIOAUTHZT][T001][role]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T002][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T002][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["MIOAUTHZ":1,1:0),1,"[MIOAUTHZT][T002][routine]")
	DO EQ^MIOTASSERT($SELECT(OUT["role_required":1,1:0),1,"[MIOAUTHZT][T002][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T003][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T003][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["not_owner":1,1:0),1,"[MIOAUTHZT][T003][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T004][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T004][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_missing":1,1:0),1,"[MIOAUTHZT][T004][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T005][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T005][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_format":1,1:0),1,"[MIOAUTHZT][T005][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T006][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T006][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_bad_signature":1,1:0),1,"[MIOAUTHZT][T006][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T007][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T007][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_expired":1,1:0),1,"[MIOAUTHZT][T007][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T008][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T008][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_not_yet_valid":1,1:0),1,"[MIOAUTHZT][T008][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T009][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T009][handler ran]")
	DO EQ^MIOTASSERT($GET(CTX("auth","roles","admin")),1,"[MIOAUTHZT][T009][admin role]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T010][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T010][handler ran]")
	DO EQ^MIOTASSERT($GET(CTX("auth","sub")),"u1","[MIOAUTHZT][T010][sub]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T011][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T011][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_issuer":1,1:0),1,"[MIOAUTHZT][T011][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T012][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T012][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_audience":1,1:0),1,"[MIOAUTHZT][T012][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T013][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T013][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["claim_mismatch:department":1,1:0),1,"[MIOAUTHZT][T013][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T014][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T014][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_missing":1,1:0),1,"[MIOAUTHZT][T014][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T015][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T015][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["b64url_char":1,1:0),1,"[MIOAUTHZT][T015][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T016][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T016][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_alg_unsupported":1,1:0),1,"[MIOAUTHZT][T016][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T017][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T017][handler ran]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T018][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T018][handler ran]")
	DO EQ^MIOTASSERT($GET(CTX("auth","claim","department")),"billing","[MIOAUTHZT][T018][claim]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T019][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T019][handler ran]")
	DO EQ^MIOTASSERT($GET(CTX("auth","roles","admin")),1,"[MIOAUTHZT][T019][admin role]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T020][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T020][handler ran]")
	DO EQ^MIOTASSERT($GET(CTX("auth","roles","admin")),1,"[MIOAUTHZT][T020][admin role]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T021][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T021][handler ran]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T022][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T022][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["not_owner":1,1:0),1,"[MIOAUTHZT][T022][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T023][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T023][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_hmac_secret_missing":1,1:0),1,"[MIOAUTHZT][T023][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T024][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T024][handler ran]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T025][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T025][handler ran]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T026][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T026][handler ran]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T027][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T027][handler ran]")
	DO EQ^MIOTASSERT($GET(CTX("auth","sub")),"","[MIOAUTHZT][T027][sub empty]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T028][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T028][handler ran]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T029][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T029][handler ran]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T030][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T030][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["claim_mismatch:department":1,1:0),1,"[MIOAUTHZT][T030][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T031][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T031][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["role_required":1,1:0),1,"[MIOAUTHZT][T031][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T032][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T032][handler ran]")
	DO EQ^MIOTASSERT($GET(CTX("auth","roles","admin")),1,"[MIOAUTHZT][T032][admin role]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T033][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T033][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["not_owner":1,1:0),1,"[MIOAUTHZT][T033][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T034][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T034][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_alg_missing":1,1:0),1,"[MIOAUTHZT][T034][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T035][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T035][handler ran]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T036][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T036][handler ran]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T037][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T037][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["claim_mismatch:department":1,1:0),1,"[MIOAUTHZT][T037][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T038][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T038][handler ran]")
	DO EQ^MIOTASSERT($GET(CTX("auth","roles","admin")),1,"[MIOAUTHZT][T038][admin role]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T039][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T039][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["role_required":1,1:0),1,"[MIOAUTHZT][T039][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T040][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T040][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_format":1,1:0),1,"[MIOAUTHZT][T040][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T041][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T041][handler not ran]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T042][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T042][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["not_owner":1,1:0),1,"[MIOAUTHZT][T042][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT1["200":1,1:0),1,"[MIOAUTHZT][T043A][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T043A][handler ran]")
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
	DO EQ^MIOTASSERT($SELECT(OUT2["200":1,1:0),1,"[MIOAUTHZT][T043B][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T043B][handler ran]")
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
	DO EQ^MIOTASSERT($SELECT(OUT1["200":1,1:0),1,"[MIOAUTHZT][T044A][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T044A][handler ran]")
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
	DO EQ^MIOTASSERT($SELECT(OUT2["401":1,1:0),1,"[MIOAUTHZT][T044B][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T044B][handler not ran]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T045][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T045][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_rs256_no_verifier":1,1:0),1,"[MIOAUTHZT][T045][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T046][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T046][handler ran]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T047][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T047][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_missing":1,1:0),1,"[MIOAUTHZT][T047][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T048][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T048][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_format":1,1:0),1,"[MIOAUTHZT][T048][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T049][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T049][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_format":1,1:0),1,"[MIOAUTHZT][T049][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T050][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T050][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["b64url_length":1,1:0),1,"[MIOAUTHZT][T050][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T051][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T051][handler ran]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T052][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T052][handler ran]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T053][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T053][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["role_required":1,1:0),1,"[MIOAUTHZT][T053][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T054][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T054][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["claim_mismatch:region":1,1:0),1,"[MIOAUTHZT][T054][reason]")
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
	DO EQ^MIOTASSERT($SELECT(OUT1["200":1,1:0),1,"[MIOAUTHZT][T055A][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T055A][handler ran]")
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
	DO EQ^MIOTASSERT($SELECT(OUT2["403":1,1:0),1,"[MIOAUTHZT][T055B][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T055B][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT2["role_required":1,1:0),1,"[MIOAUTHZT][T055B][reason]")
	QUIT
T056 ; RS256 with missing verifier entry -> 401 jwt_rs256_no_verifier
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET HJSON="{""alg"":""RS256"",""typ"":""JWT""}"
	SET PJSON="{""sub"":""u1"",""exp"":"_(NOW+3600)_"}"
	SET TOK=$$B64EURL^MIOAUTHJWT(HJSON)_"."_$$B64EURL^MIOAUTHJWT(PJSON)_"."_$$B64EURL^MIOAUTHJWT("sig")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az056"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t056.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T056][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T056][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_rs256_no_verifier":1,1:0),1,"[MIOAUTHZT][T056][reason]")
	QUIT
	;
T057 ; empty bearer prefix accepts raw token header value
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","bearerPrefix")=""
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")=TOK
	SET CTX("request_id")="az057"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t057.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T057][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T057][handler ran]")
	QUIT
	;
T058 ; explicit now override can keep expired token valid under skew
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","clockSkewSeconds")=10
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET CONF("auth","jwt","now")=NOW
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW-5)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az058"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t058.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T058][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T058][handler ran]")
	QUIT
	;
T059 ; explicit now override can force not-yet-valid denial
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""nbf"":"_(NOW+1)_",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az059"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t059.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T059][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T059][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_not_yet_valid":1,1:0),1,"[MIOAUTHZT][T059][reason]")
	QUIT
	;
T060 ; claim exact match with empty string -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("claims.note")=""
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""note"":"""",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az060"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t060.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T060][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T060][handler ran]")
	QUIT
	;
T061 ; protected route with bad token then good token in same test
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	;
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer abc.def"
	SET CTX("request_id")="az061a"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t061a.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT1)
	DO EQ^MIOTASSERT($SELECT(OUT1["401":1,1:0),1,"[MIOAUTHZT][T061A][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T061A][handler not ran]")
	;
	KILL REQ,CTX
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az061b"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t061b.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT2)
	DO EQ^MIOTASSERT($SELECT(OUT2["200":1,1:0),1,"[MIOAUTHZT][T061B][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T061B][handler ran]")
	QUIT
	;
T062 ; owner passes but role fails first -> 403 role_required
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
	SET CONF("auth","jwt","rolesClaim")="roles"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""user"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/item/u1"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az062"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t062.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T062][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T062][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["role_required":1,1:0),1,"[MIOAUTHZT][T062][reason]")
	QUIT
	;
T063 ; owner fails even when claim requirement passes -> 403 not_owner
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("claims.department")="billing"
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""department"":""billing"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/item/u2"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az063"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t063.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T063][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T063][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["not_owner":1,1:0),1,"[MIOAUTHZT][T063][reason]")
	QUIT
	;
T064 ; issuer empty config does not enforce issuer
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","issuer")=""
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""iss"":""anything"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az064"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t064.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T064][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T064][handler ran]")
	QUIT
	;
T065 ; audience empty config does not enforce audience
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","audience")=""
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""aud"":""anything"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az065"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t065.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T065][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T065][handler ran]")
	QUIT
T066 ; authRequired explicit 0 does not enforce auth -> 200
	DO RESET
	NEW META
	SET META("authRequired")=0
	DO ADDM^MIOROUTE("GET","/open","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	DO ENSURE^MIOMW(.CONF)
	SET REQ("method")="GET"
	SET REQ("path")="/open"
	SET CTX("request_id")="az066"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t066.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T066][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T066][handler ran]")
	QUIT
	;
T067 ; issuer + audience both exact match -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","issuer")="iss-1"
	SET CONF("auth","jwt","audience")="aud-1"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""iss"":""iss-1"",""aud"":""aud-1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az067"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t067.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T067][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T067][handler ran]")
	QUIT
	;
T068 ; missing rolesClaim with owner-only route still allows owner success -> 200
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
	SET CONF("auth","jwt","rolesClaim")="groups"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/item/u1"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az068"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t068.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T068][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T068][handler ran]")
	QUIT
	;
T069 ; roles required plus matching claim -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	SET META("claims.department")="billing"
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""admin"",""department"":""billing"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az069"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t069.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T069][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T069][handler ran]")
	QUIT
	;
T070 ; roles pass but missing required claim -> 403 claim_mismatch
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	SET META("claims.department")="billing"
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""admin"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az070"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t070.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T070][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T070][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["claim_mismatch:department":1,1:0),1,"[MIOAUTHZT][T070][reason]")
	QUIT
	;
T071 ; owner passes with numeric-looking id string exact match -> 200
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""001"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/item/001"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az071"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t071.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T071][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T071][handler ran]")
	QUIT
	;
T072 ; owner fails with numeric-looking id non-exact mismatch -> 403 not_owner
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/item/001"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az072"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t072.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T072][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T072][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["not_owner":1,1:0),1,"[MIOAUTHZT][T072][reason]")
	QUIT
	;
T073 ; route metadata change after RESET does not leak from prior test
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	DO RESET
	KILL META
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""user"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az073"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t073.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T073][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T073][handler ran]")
	QUIT
	;
T074 ; malformed JSON header with alg omitted but valid payload/signature -> 401 jwt_alg_missing or json failure
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
	SET HJSON="{""typ"":""JWT"""
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
	SET CTX("request_id")="az074"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t074.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T074][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T074][handler not ran]")
	QUIT
	;
T075 ; protected route with valid token and unrelated extra claims -> 200
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""foo"":""bar"",""x"":""1"",""y"":""2"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az075"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t075.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T075][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T075][handler ran]")
	DO EQ^MIOTASSERT($GET(CTX("auth","claim","foo")),"bar","[MIOAUTHZT][T075][extra claim]")
	QUIT
T076 ; claim value with spaces exact match -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("claims.team")="core platform"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""team"":""core platform"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az076"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t076.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T076][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T076][handler ran]")
	QUIT
	;
T077 ; claim value with spaces mismatch -> 403
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("claims.team")="core platform"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""team"":""core  platform"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az077"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t077.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T077][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T077][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["claim_mismatch:team":1,1:0),1,"[MIOAUTHZT][T077][reason]")
	QUIT
	;
T078 ; roles required any-of first role matches -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin,manager"
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""admin,user"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az078"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t078.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T078][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T078][handler ran]")
	QUIT
	;
T079 ; roles required any-of second role matches -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin,manager"
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""user,manager"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az079"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t079.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T079][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T079][handler ran]")
	QUIT
	;
T080 ; roles required any-of none match -> 403
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin,manager"
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""user,viewer"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az080"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t080.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T080][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T080][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["role_required":1,1:0),1,"[MIOAUTHZT][T080][reason]")
	QUIT
	;
T081 ; roles metadata with spaces still matches -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")=" admin , manager "
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""manager"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az081"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t081.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T081][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T081][handler ran]")
	QUIT
	;
T082 ; protected POST route works with JWT -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("POST","/secure-post","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="POST"
	SET REQ("path")="/secure-post"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az082"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t082.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T082][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T082][handler ran]")
	QUIT
	;
T083 ; same path different method metadata isolated
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	DO ADDM^MIOROUTE("GET","/dual","HOK^MIOAUTHZT",.META)
	KILL META
	SET META("authRequired")=1
	SET META("roles")="manager"
	DO ADDM^MIOROUTE("POST","/dual","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rolesClaim")="roles"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	; GET with admin should pass
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""admin"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/dual"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az083a"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t083a.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT1)
	DO EQ^MIOTASSERT($SELECT(OUT1["200":1,1:0),1,"[MIOAUTHZT][T083A][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T083A][handler ran]")
	; POST with same token should fail because manager required
	KILL REQ,CTX
	SET REQ("method")="POST"
	SET REQ("path")="/dual"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az083b"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t083b.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT2)
	DO EQ^MIOTASSERT($SELECT(OUT2["403":1,1:0),1,"[MIOAUTHZT][T083B][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T083B][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT2["role_required":1,1:0),1,"[MIOAUTHZT][T083B][reason]")
	QUIT
	;
T084 ; token with only signature mismatch and same payload -> 401
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
	; replace only signature with another valid-looking one
	SET TOK=$P(TOK,".",1)_"."_$P(TOK,".",2)_"."_$$B64EURL^MIOAUTHJWT("wrongsig")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az084"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t084.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T084][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T084][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_bad_signature":1,1:0),1,"[MIOAUTHZT][T084][reason]")
	QUIT
	;
T085 ; path param with dash owner exact match -> 200
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u-1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/item/u-1"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az085"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t085.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T085][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T085][handler ran]")
	QUIT
T086 ; route requires manager, token has admin and manager -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="manager"
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""admin,manager"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az086"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t086.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T086][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T086][handler ran]")
	QUIT
	;
T087 ; claim exact numeric-looking string match -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("claims.level")="2"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""level"":""2"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az087"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t087.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T087][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T087][handler ran]")
	QUIT
	;
T088 ; claim numeric-looking string mismatch -> 403
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("claims.level")="2"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""level"":""02"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az088"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t088.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T088][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T088][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["claim_mismatch:level":1,1:0),1,"[MIOAUTHZT][T088][reason]")
	QUIT
	;
T089 ; token with trailing spaces in auth header after token -> 401 bad signature
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
	SET REQ("hdr","authorization")="Bearer "_TOK_" "
	SET CTX("request_id")="az089"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t089.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T089][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T089][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["b64url_char":1,1:0),1,"[MIOAUTHZT][T089][reason]")
	QUIT
	;
T090 ; route with only claim requirement denies unauthenticated -> 401
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("claims.department")="billing"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	DO ENSURE^MIOMW(.CONF)
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET CTX("request_id")="az090"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t090.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T090][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T090][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_missing":1,1:0),1,"[MIOAUTHZT][T090][reason]")
	QUIT
	;
T091 ; route with role and claim both fail still returns 403
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	SET META("claims.department")="billing"
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""user"",""department"":""sales"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az091"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t091.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T091][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T091][handler not ran]")
	QUIT
	;
T092 ; malformed auth header without token -> 401 jwt_missing
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
	SET REQ("hdr","authorization")="Bearer "
	SET CTX("request_id")="az092"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t092.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T092][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T092][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_missing":1,1:0),1,"[MIOAUTHZT][T092][reason]")
	QUIT
	;
T093 ; route owner + claim both pass -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("ownerParam")="id"
	SET META("ownerClaim")="sub"
	SET META("claims.department")="billing"
	DO ADDM^MIOROUTE("GET","/item/:id","HOK^MIOAUTHZT",.META)
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
	SET REQ("path")="/item/u1"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az093"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t093.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T093][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T093][handler ran]")
	QUIT
	;
T094 ; auth context fresh after public request then protected request
	DO RESET
	NEW META
	DO ADDM^MIOROUTE("GET","/public","HOK^MIOAUTHZT",.META)
	KILL META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	;
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/public"
	SET CTX("request_id")="az094a"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t094a.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT1)
	DO EQ^MIOTASSERT($SELECT(OUT1["200":1,1:0),1,"[MIOAUTHZT][T094A][status]")
	;
	KILL REQ,CTX
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az094b"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t094b.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT2)
	DO EQ^MIOTASSERT($SELECT(OUT2["200":1,1:0),1,"[MIOAUTHZT][T094B][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T094B][handler ran]")
	QUIT
	;
T095 ; explicit now override with future value expires otherwise-valid token -> 401
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
	SET CONF("auth","jwt","now")=NOW+7200
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az095"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t095.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T095][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T095][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_expired":1,1:0),1,"[MIOAUTHZT][T095][reason]")
	QUIT
T096 ; token with only sub and issuer/audience unset -> 200
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
	SET CTX("request_id")="az096"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t096.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T096][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T096][handler ran]")
	QUIT
	;
T097 ; empty roles claim on non-role route still allows -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
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
	SET CTX("request_id")="az097"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t097.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T097][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T097][handler ran]")
	QUIT
	;
T098 ; route role required and roles claim omitted -> 403
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az098"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t098.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T098][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T098][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["role_required":1,1:0),1,"[MIOAUTHZT][T098][reason]")
	QUIT
	;
T099 ; claim present but route expects different empty/non-empty -> 403
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("claims.note")="x"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""note"":"""",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az099"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t099.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T099][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T099][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["claim_mismatch:note":1,1:0),1,"[MIOAUTHZT][T099][reason]")
	QUIT
	;
T100 ; path route metadata survives multiple compile calls
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("ownerParam")="id"
	SET META("ownerClaim")="sub"
	DO ADDM^MIOROUTE("GET","/item/:id","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
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
	SET CTX("request_id")="az100"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t100.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T100][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T100][handler ran]")
	QUIT
	;
T101 ; wrong method on protected route should not accidentally authorize matched path
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	DO ADDM^MIOROUTE("POST","/secure-post","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rolesClaim")="roles"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""admin"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure-post"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az101"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t101.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT'["200":1,1:0),1,"[MIOAUTHZT][T101][not ok]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T101][handler not ran]")
	QUIT
	;
T102 ; token with valid signature and extra dot in header value -> 401 jwt_format
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
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")_"."
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az102"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t102.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T102][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T102][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_format":1,1:0),1,"[MIOAUTHZT][T102][reason]")
	QUIT
	;
T103 ; claim names do not collide with sub population
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("claims.sub")="u1"
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
	SET CTX("request_id")="az103"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t103.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T103][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T103][handler ran]")
	DO EQ^MIOTASSERT($GET(CTX("auth","sub")),"u1","[MIOAUTHZT][T103][sub]")
	QUIT
	;
T104 ; owner check with slash-free unusual chars underscore exact match -> 200
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u_1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/item/u_1"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az104"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t104.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T104][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T104][handler ran]")
	QUIT
	;
T105 ; good token reused after prior deny still passes with fresh context
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rolesClaim")="roles"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	; first deny
	KILL REQ,CTX
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""user"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az105a"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t105a.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT1)
	DO EQ^MIOTASSERT($SELECT(OUT1["403":1,1:0),1,"[MIOAUTHZT][T105A][status]")
	; then allow
	KILL REQ,CTX
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""admin"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az105b"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t105b.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT2)
	DO EQ^MIOTASSERT($SELECT(OUT2["200":1,1:0),1,"[MIOAUTHZT][T105B][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T105B][handler ran]")
	QUIT
	;
T106 ; RS256 verifier true -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rs256Verify")="VRFYOK^MIOAUTHZT"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKRSJWT("{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az106"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t106.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T106][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T106][handler ran]")
	QUIT
	;
T107 ; RS256 verifier false -> 401
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rs256Verify")="VRFYNO^MIOAUTHZT"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKRSJWT("{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az107"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t107.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T107][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T107][handler not ran]")
	QUIT
	;
T108 ; RS256 verifier exception -> 401 verifier exception
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rs256Verify")="VRFYERR^MIOAUTHZT"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKRSJWT("{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az108"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t108.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T108][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T108][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_rs256_verifier_exception":1,1:0),1,"[MIOAUTHZT][T108][reason]")
	QUIT
	;
T109 ; RS256 + RBAC pass -> 200
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
	SET CONF("auth","jwt","rs256Verify")="VRFYOK^MIOAUTHZT"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKRSJWT("{""sub"":""u1"",""roles"":""admin"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az109"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t109.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T109][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T109][handler ran]")
	QUIT
	;
T110 ; RS256 + RBAC deny -> 403
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
	SET CONF("auth","jwt","rs256Verify")="VRFYOK^MIOAUTHZT"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKRSJWT("{""sub"":""u1"",""roles"":""user"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az110"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t110.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T110][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T110][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["role_required":1,1:0),1,"[MIOAUTHZT][T110][reason]")
	QUIT
	;
T111 ; RS256 + owner pass -> 200
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
	SET CONF("auth","jwt","rs256Verify")="VRFYOK^MIOAUTHZT"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKRSJWT("{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/item/u1"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az111"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t111.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T111][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T111][handler ran]")
	QUIT
	;
T112 ; RS256 + owner deny -> 403
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
	SET CONF("auth","jwt","rs256Verify")="VRFYOK^MIOAUTHZT"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKRSJWT("{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/item/u2"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az112"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t112.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T112][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T112][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["not_owner":1,1:0),1,"[MIOAUTHZT][T112][reason]")
	QUIT
	;
T113 ; RS256 verifier bad entry format -> 401
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rs256Verify")="BADENTRY"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKRSJWT("{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az113"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t113.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T113][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T113][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_rs256_bad_verifier":1,1:0),1,"[MIOAUTHZT][T113][reason]")
	QUIT
	;
T114 ; RS256 verifier illegal identifier entry -> 401
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rs256Verify")="BAD-TAG^MIOAUTHZT"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKRSJWT("{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az114"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t114.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T114][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T114][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_rs256_bad_verifier":1,1:0),1,"[MIOAUTHZT][T114][reason]")
	QUIT
	;
T115 ; RS256 verifier true plus claim requirement pass -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("claims.department")="billing"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rs256Verify")="VRFYOK^MIOAUTHZT"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKRSJWT("{""sub"":""u1"",""department"":""billing"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az115"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t115.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T115][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T115][handler ran]")
	QUIT
T116 ; repeated successful dispatches with same valid HS256 token -> 200 both times
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	;
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az116a"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t116a.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT1)
	DO EQ^MIOTASSERT($SELECT(OUT1["200":1,1:0),1,"[MIOAUTHZT][T116A][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T116A][handler ran]")
	;
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az116b"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t116b.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT2)
	DO EQ^MIOTASSERT($SELECT(OUT2["200":1,1:0),1,"[MIOAUTHZT][T116B][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T116B][handler ran]")
	QUIT
	;
T117 ; repeated denied dispatches with same bad-signature token -> 401 both times
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")="wrongsecret"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	;
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az117a"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t117a.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT1)
	DO EQ^MIOTASSERT($SELECT(OUT1["401":1,1:0),1,"[MIOAUTHZT][T117A][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T117A][handler not ran]")
	;
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az117b"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t117b.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT2)
	DO EQ^MIOTASSERT($SELECT(OUT2["401":1,1:0),1,"[MIOAUTHZT][T117B][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T117B][handler not ran]")
	QUIT
	;
T118 ; HS256 token on RS256-only config without verifier -> 401 jwt_alg_unsupported or jwt_rs256_no_verifier not triggered
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	; no HS256 restriction in config, routine should still use header alg path
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az118"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t118.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T118][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T118][handler ran]")
	QUIT
	;
T119 ; token with sub only reused across owner route mismatch then match
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("ownerParam")="id"
	SET META("ownerClaim")="sub"
	DO ADDM^MIOROUTE("GET","/item/:id","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	;
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/item/u2"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az119a"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t119a.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT1)
	DO EQ^MIOTASSERT($SELECT(OUT1["403":1,1:0),1,"[MIOAUTHZT][T119A][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T119A][handler not ran]")
	;
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/item/u1"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az119b"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t119b.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT2)
	DO EQ^MIOTASSERT($SELECT(OUT2["200":1,1:0),1,"[MIOAUTHZT][T119B][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T119B][handler ran]")
	QUIT
	;
T120 ; custom rolesClaim and unrelated default roles claim present -> custom wins
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""user"",""groups"":""admin"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az120"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t120.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T120][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T120][handler ran]")
	QUIT
	;
T121 ; malformed payload JSON with valid header and signature still 401 on every attempt
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET HJSON="{""alg"":""HS256"",""typ"":""JWT""}"
	SET PJSON="{""sub"":"
	SET H64=$$B64EURL^MIOAUTHJWT(HJSON)
	SET P64=$$B64EURL^MIOAUTHJWT(PJSON)
	SET DATA=H64_"."_P64
	SET SIG=$$HMACSHA256^MIOAUTHJWT(DATA,SECRET,.ERR)
	SET TOK=DATA_"."_$$B64EURL^MIOAUTHJWT(SIG)
	;
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az121a"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t121a.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT1)
	DO EQ^MIOTASSERT($SELECT(OUT1["401":1,1:0),1,"[MIOAUTHZT][T121A][status]")
	;
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az121b"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t121b.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT2)
	DO EQ^MIOTASSERT($SELECT(OUT2["401":1,1:0),1,"[MIOAUTHZT][T121B][status]")
	QUIT
	;
T122 ; route requiring empty-string role name is effectively unsatisfied -> 403
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")=","
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""user"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az122"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t122.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T122][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T122][handler not ran]")
	QUIT
	;
T123 ; claim with punctuation exact match -> 200
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("claims.tag")="a-b_c.1"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""tag"":""a-b_c.1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az123"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t123.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T123][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T123][handler ran]")
	QUIT
	;
T124 ; protected route with RS256 valid then HS256 valid in same config session
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rs256Verify")="VRFYOK^MIOAUTHZT"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	;
	KILL REQ,CTX
	SET TOK=$$MKRSJWT("{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az124a"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t124a.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT1)
	DO EQ^MIOTASSERT($SELECT(OUT1["200":1,1:0),1,"[MIOAUTHZT][T124A][status]")
	;
	KILL REQ,CTX
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az124b"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t124b.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT2)
	DO EQ^MIOTASSERT($SELECT(OUT2["200":1,1:0),1,"[MIOAUTHZT][T124B][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T124B][handler ran]")
	QUIT
	;
T125 ; same valid token on two different protected routes with different policies
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("claims.department")="billing"
	DO ADDM^MIOROUTE("GET","/a","HOK^MIOAUTHZT",.META)
	KILL META
	SET META("authRequired")=1
	SET META("claims.department")="sales"
	DO ADDM^MIOROUTE("GET","/b","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""department"":""billing"",""exp"":"_(NOW+3600)_"}")
	;
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/a"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az125a"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t125a.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT1)
	DO EQ^MIOTASSERT($SELECT(OUT1["200":1,1:0),1,"[MIOAUTHZT][T125A][status]")
	;
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/b"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az125b"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t125b.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT2)
	DO EQ^MIOTASSERT($SELECT(OUT2["403":1,1:0),1,"[MIOAUTHZT][T125B][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T125B][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT2["claim_mismatch:department":1,1:0),1,"[MIOAUTHZT][T125B][reason]")
	QUIT
T126 ; multiple extra claims preserved in auth claim map -> 200
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""a"":""1"",""b"":""2"",""c"":""3"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az126"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t126.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T126][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T126][handler ran]")
	DO EQ^MIOTASSERT($GET(CTX("auth","claim","a")),"1","[MIOAUTHZT][T126][claim a]")
	DO EQ^MIOTASSERT($GET(CTX("auth","claim","b")),"2","[MIOAUTHZT][T126][claim b]")
	DO EQ^MIOTASSERT($GET(CTX("auth","claim","c")),"3","[MIOAUTHZT][T126][claim c]")
	QUIT
	;
T127 ; same route protected then metadata changed after RESET to public
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/flip","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	DO RESET
	KILL META
	DO ADDM^MIOROUTE("GET","/flip","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	DO ENSURE^MIOMW(.CONF)
	SET REQ("method")="GET"
	SET REQ("path")="/flip"
	SET CTX("request_id")="az127"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t127.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T127][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T127][handler ran]")
	QUIT
	;
T128 ; owner check with long identifier exact match -> 200
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
	SET LONGID="user-1234567890-abcdef"
	SET TOK=$$MKJWT(SECRET,"{""sub"":"""_LONGID_""",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/item/"_LONGID
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az128"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t128.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T128][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T128][handler ran]")
	QUIT
	;
T129 ; role deny does not populate handler status 200
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""user"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az129"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t129.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($GET(CTX("status")),403,"[MIOAUTHZT][T129][ctx status]")
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),0,"[MIOAUTHZT][T129][not 200]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T129][handler not ran]")
	QUIT
	;
T130 ; claim mismatch deny does not remove auth ok marker
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
	SET CTX("request_id")="az130"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t130.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($GET(CTX("auth","ok")),1,"[MIOAUTHZT][T130][auth ok kept]")
	DO EQ^MIOTASSERT($GET(CTX("status")),403,"[MIOAUTHZT][T130][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T130][handler not ran]")
	QUIT
	;
T131 ; public route after denied protected route stays public
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	KILL META
	DO ADDM^MIOROUTE("GET","/public","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rolesClaim")="roles"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	;
	KILL REQ,CTX
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""user"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az131a"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t131a.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT1)
	DO EQ^MIOTASSERT($SELECT(OUT1["403":1,1:0),1,"[MIOAUTHZT][T131A][status]")
	;
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/public"
	SET CTX("request_id")="az131b"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t131b.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT2)
	DO EQ^MIOTASSERT($SELECT(OUT2["200":1,1:0),1,"[MIOAUTHZT][T131B][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T131B][handler ran]")
	QUIT
	;
T132 ; issuer enforced while audience empty only checks issuer
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","issuer")="iss-1"
	SET CONF("auth","jwt","audience")=""
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""iss"":""iss-1"",""aud"":""anything"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az132"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t132.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T132][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T132][handler ran]")
	QUIT
	;
T133 ; audience enforced while issuer empty only checks audience
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","issuer")=""
	SET CONF("auth","jwt","audience")="aud-1"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""iss"":""anything"",""aud"":""aud-1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az133"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t133.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T133][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T133][handler ran]")
	QUIT
	;
T134 ; same valid token under different now override can pass then expire
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","clockSkewSeconds")=0
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+10)_"}")
	;
	KILL REQ,CTX
	SET CONF("auth","jwt","now")=NOW
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az134a"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t134a.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT1)
	DO EQ^MIOTASSERT($SELECT(OUT1["200":1,1:0),1,"[MIOAUTHZT][T134A][status]")
	;
	KILL REQ,CTX
	SET CONF("auth","jwt","now")=NOW+11
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az134b"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t134b.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT2)
	DO EQ^MIOTASSERT($SELECT(OUT2["401":1,1:0),1,"[MIOAUTHZT][T134B][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T134B][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT2["jwt_expired":1,1:0),1,"[MIOAUTHZT][T134B][reason]")
	QUIT
	;
T135 ; claim and role both pass on one route then different route denies on role only
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	SET META("claims.department")="billing"
	DO ADDM^MIOROUTE("GET","/r1","HOK^MIOAUTHZT",.META)
	KILL META
	SET META("authRequired")=1
	SET META("roles")="manager"
	DO ADDM^MIOROUTE("GET","/r2","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rolesClaim")="roles"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""admin"",""department"":""billing"",""exp"":"_(NOW+3600)_"}")
	;
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/r1"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az135a"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t135a.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT1)
	DO EQ^MIOTASSERT($SELECT(OUT1["200":1,1:0),1,"[MIOAUTHZT][T135A][status]")
	;
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/r2"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az135b"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t135b.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT2)
	DO EQ^MIOTASSERT($SELECT(OUT2["403":1,1:0),1,"[MIOAUTHZT][T135B][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T135B][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT2["role_required":1,1:0),1,"[MIOAUTHZT][T135B][reason]")
	QUIT
T136 ; same token across three routes with pass, deny, pass
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("claims.department")="billing"
	DO ADDM^MIOROUTE("GET","/a","HOK^MIOAUTHZT",.META)
	KILL META
	SET META("authRequired")=1
	SET META("roles")="admin"
	DO ADDM^MIOROUTE("GET","/b","HOK^MIOAUTHZT",.META)
	KILL META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/c","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rolesClaim")="roles"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""department"":""billing"",""roles"":""user"",""exp"":"_(NOW+3600)_"}")
	;
	KILL REQ,CTX
	SET REQ("method")="GET",REQ("path")="/a",REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az136a",CTX("ran")=0
	SET OP="tmp/mio_authz_t136a.out" OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX) CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT1)
	DO EQ^MIOTASSERT($SELECT(OUT1["200":1,1:0),1,"[MIOAUTHZT][T136A][status]")
	;
	KILL REQ,CTX
	SET REQ("method")="GET",REQ("path")="/b",REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az136b",CTX("ran")=0
	SET OP="tmp/mio_authz_t136b.out" OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX) CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT2)
	DO EQ^MIOTASSERT($SELECT(OUT2["403":1,1:0),1,"[MIOAUTHZT][T136B][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T136B][handler not ran]")
	;
	KILL REQ,CTX
	SET REQ("method")="GET",REQ("path")="/c",REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az136c",CTX("ran")=0
	SET OP="tmp/mio_authz_t136c.out" OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX) CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT3)
	DO EQ^MIOTASSERT($SELECT(OUT3["200":1,1:0),1,"[MIOAUTHZT][T136C][status]")
	QUIT
	;
T137 ; empty custom bearer prefix with malformed raw token -> 401 jwt_format
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","bearerPrefix")=""
	DO ENSURE^MIOMW(.CONF)
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="abc.def"
	SET CTX("request_id")="az137"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t137.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T137][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T137][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_format":1,1:0),1,"[MIOAUTHZT][T137][reason]")
	QUIT
	;
T138 ; claim name with mixed case exact match
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("claims.DepartmentCode")="A1"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""DepartmentCode"":""A1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az138"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t138.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHZT][T138][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T138][handler ran]")
	QUIT
	;
T139 ; claim name case mismatch denies
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("claims.departmentcode")="A1"
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""DepartmentCode"":""A1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az139"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t139.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T139][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T139][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["claim_mismatch:departmentcode":1,1:0),1,"[MIOAUTHZT][T139][reason]")
	QUIT
	;
T140 ; roles claim contains spaces only -> 403 role_required
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
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""roles"":""   "",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az140"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t140.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T140][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T140][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["role_required":1,1:0),1,"[MIOAUTHZT][T140][reason]")
	QUIT
	;
T141 ; two owner routes same token one pass one deny
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("ownerParam")="id"
	SET META("ownerClaim")="sub"
	DO ADDM^MIOROUTE("GET","/item/:id","HOK^MIOAUTHZT",.META)
	KILL META
	SET META("authRequired")=1
	SET META("ownerParam")="id"
	SET META("ownerClaim")="sub"
	DO ADDM^MIOROUTE("GET","/doc/:id","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	;
	KILL REQ,CTX
	SET REQ("method")="GET",REQ("path")="/item/u1",REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az141a",CTX("ran")=0
	SET OP="tmp/mio_authz_t141a.out" OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX) CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT1)
	DO EQ^MIOTASSERT($SELECT(OUT1["200":1,1:0),1,"[MIOAUTHZT][T141A][status]")
	;
	KILL REQ,CTX
	SET REQ("method")="GET",REQ("path")="/doc/u2",REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az141b",CTX("ran")=0
	SET OP="tmp/mio_authz_t141b.out" OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX) CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT2)
	DO EQ^MIOTASSERT($SELECT(OUT2["403":1,1:0),1,"[MIOAUTHZT][T141B][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T141B][handler not ran]")
	QUIT
	;
T142 ; token without sub fails owner route but still authenticates
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
	SET TOK=$$MKJWT(SECRET,"{""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/item/u1"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az142"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t142.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($GET(CTX("auth","ok")),1,"[MIOAUTHZT][T142][auth ok]")
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[MIOAUTHZT][T142][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T142][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["not_owner":1,1:0),1,"[MIOAUTHZT][T142][reason]")
	QUIT
	;
T143 ; issuer mismatch on RS256 verifier-true still denies at claim check
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","issuer")="iss-ok"
	SET CONF("auth","jwt","rs256Verify")="VRFYOK^MIOAUTHZT"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKRSJWT("{""sub"":""u1"",""iss"":""iss-bad"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az143"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t143.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T143][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T143][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_issuer":1,1:0),1,"[MIOAUTHZT][T143][reason]")
	QUIT
	;
T144 ; audience mismatch on RS256 verifier-true still denies at claim check
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/secure","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","audience")="aud-ok"
	SET CONF("auth","jwt","rs256Verify")="VRFYOK^MIOAUTHZT"
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	SET TOK=$$MKRSJWT("{""sub"":""u1"",""aud"":""aud-bad"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET"
	SET REQ("path")="/secure"
	SET REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az144"
	SET CTX("ran")=0
	SET OP="tmp/mio_authz_t144.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["401":1,1:0),1,"[MIOAUTHZT][T144][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),0,"[MIOAUTHZT][T144][handler not ran]")
	DO EQ^MIOTASSERT($SELECT(OUT["jwt_audience":1,1:0),1,"[MIOAUTHZT][T144][reason]")
	QUIT
	;
T145 ; same good token reused after RS256 verifier exception route does not poison HS256
	DO RESET
	NEW META
	SET META("authRequired")=1
	DO ADDM^MIOROUTE("GET","/hs","HOK^MIOAUTHZT",.META)
	DO ADDM^MIOROUTE("GET","/rs","HOK^MIOAUTHZT",.META)
	DO COMPILE^MIOROUTE
	KILL CONF
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rs256Verify")="VRFYERR^MIOAUTHZT"
	SET SECRET="s3cr3t"
	SET CONF("auth","jwt","hmacSecret")=SECRET
	DO ENSURE^MIOMW(.CONF)
	SET NOW=$$NOWS^MIOAUTHJWT()
	;
	KILL REQ,CTX
	SET TOK=$$MKRSJWT("{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET",REQ("path")="/rs",REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az145a",CTX("ran")=0
	SET OP="tmp/mio_authz_t145a.out" OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX) CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT1)
	DO EQ^MIOTASSERT($SELECT(OUT1["401":1,1:0),1,"[MIOAUTHZT][T145A][status]")
	;
	KILL REQ,CTX
	SET TOK=$$MKJWT(SECRET,"{""sub"":""u1"",""exp"":"_(NOW+3600)_"}")
	SET REQ("method")="GET",REQ("path")="/hs",REQ("hdr","authorization")="Bearer "_TOK
	SET CTX("request_id")="az145b",CTX("ran")=0
	SET OP="tmp/mio_authz_t145b.out" OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX) CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT2)
	DO EQ^MIOTASSERT($SELECT(OUT2["200":1,1:0),1,"[MIOAUTHZT][T145B][status]")
	DO EQ^MIOTASSERT($GET(CTX("ran")),1,"[MIOAUTHZT][T145B][handler ran]")
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
; ---- RS256 verifier stubs ----
VRFYOK(DATA,SIGBIN,CONF,CTX,HOBJ,POBJ,ERR)
	QUIT 1
	;
VRFYNO(DATA,SIGBIN,CONF,CTX,HOBJ,POBJ,ERR)
	SET ERR("routine")="MIOAUTHJWT"
	SET ERR("error")="jwt_bad_signature"
	QUIT 0
	;
VRFYERR(DATA,SIGBIN,CONF,CTX,HOBJ,POBJ,ERR)
	NEW X SET X=1/0
	QUIT 0
	;
MKRSJWT(PJSON)
	NEW HJSON,H64,P64,S64
	SET HJSON="{""alg"":""RS256"",""typ"":""JWT""}"
	SET H64=$$B64EURL^MIOAUTHJWT(HJSON)
	SET P64=$$B64EURL^MIOAUTHJWT(PJSON)
	SET S64=$$B64EURL^MIOAUTHJWT("sig")
	QUIT H64_"."_P64_"."_S64