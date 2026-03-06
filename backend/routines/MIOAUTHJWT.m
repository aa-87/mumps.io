MIOAUTHJWT ; JWT validation (HS256) using MIOSHA256 + MIOSJWT
	;
	; Public API (kept compatible with existing framework/tests):
	;   $$VERIFY(.CONF,.REQ,.CTX,.ERR) -> 1/0
	;   $$CHECKCLAIMS(.CONF,.POBJ,.ERR) -> 1/0
	;   $$HMACSHA256(DATA,SECRET,.ERR) -> 32-byte binary
	;   $$B64DURL(S,.ERR) -> binary
	;   $$B64EURL(BIN) -> base64url (no padding)
	;   $$NOWS() -> seconds since $H origin (compat mode)
	;
	; Notes
	; - Keeps original auth / claim / apply behavior.;
	; - Only crypto/Base64url internals delegate to MIOSHA256 / MIOSJWT.;
	; - RS256 callback support preserved.;
	;
	QUIT
	;
VERIFY(CONF,REQ,CTX,ERR)
	KILL ERR
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" DO ETRAP(.ERR) QUIT 0"
	NEW AH SET AH=$GET(REQ("hdr","authorization"))
	IF AH="" DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_missing",ERR("status")=401
	NEW PFX SET PFX=$GET(CONF("auth","jwt","bearerPrefix"),"Bearer ")
	IF $EXTRACT(AH,1,$L(PFX))'=PFX DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_missing",ERR("status")=401
	NEW TOK SET TOK=$EXTRACT(AH,$L(PFX)+1,999999)
	IF TOK="" DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_missing",ERR("status")=401
	;
	NEW H64,P64,S64
	SET H64=$PIECE(TOK,".",1),P64=$PIECE(TOK,".",2),S64=$PIECE(TOK,".",3)
	IF H64=""!(P64="")!(S64="") DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_format",ERR("status")=401
	;
	NEW HJSON SET HJSON=$$BIN2STR($$B64DURL(H64,.ERR)) IF $DATA(ERR) DO SETR(.ERR,"MIOAUTHJWT",401) QUIT 0
	NEW PJSON SET PJSON=$$BIN2STR($$B64DURL(P64,.ERR)) IF $DATA(ERR) DO SETR(.ERR,"MIOAUTHJWT",401) QUIT 0
	;
	NEW HOBJ,POBJ,OK
	SET OK=$$DECODET^MIOJSON(HJSON,.HOBJ,.ERR) IF 'OK DO SETR(.ERR,"MIOAUTHJWT",401) QUIT 0
	SET OK=$$DECODET^MIOJSON(PJSON,.POBJ,.ERR) IF 'OK DO SETR(.ERR,"MIOAUTHJWT",401) QUIT 0
	;
	NEW ALG SET ALG=$GET(HOBJ("v","alg","v"))
	IF ALG="" DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_alg_missing",ERR("status")=401
	;
	IF '$$CHECKCLAIMS(.CONF,.POBJ,.ERR) DO SETR(.ERR,"MIOAUTHJWT",401) QUIT 0
	;
	NEW DATA SET DATA=H64_"."_P64
	IF ALG="HS256" QUIT $$VHS256(DATA,S64,.CONF,.CTX,.POBJ,.ERR)
	IF ALG="RS256" QUIT $$VRS256(DATA,S64,.CONF,.CTX,.HOBJ,.POBJ,.ERR)
	SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_alg_unsupported",ERR("status")=401
	QUIT 0
	;
CHECKCLAIMS(CONF,POBJ,ERR)
	KILL ERR
	NEW NOW SET NOW=+$GET(CONF("auth","jwt","now"))
	IF NOW'>0 SET NOW=$$NOWS()
	NEW SKEW SET SKEW=+$GET(CONF("auth","jwt","clockSkewSeconds"),60)
	NEW EXP SET EXP=+$GET(POBJ("v","exp","v"))
	IF EXP>0,(NOW-SKEW)>EXP DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_expired",ERR("status")=401
	NEW NBF SET NBF=+$GET(POBJ("v","nbf","v"))
	IF NBF>0,(NOW+SKEW)<NBF DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_not_yet_valid",ERR("status")=401
	NEW ISSREQ SET ISSREQ=$GET(CONF("auth","jwt","issuer"))
	IF ISSREQ'="",$GET(POBJ("v","iss","v"))'=ISSREQ DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_issuer",ERR("status")=401
	NEW AUDREQ SET AUDREQ=$GET(CONF("auth","jwt","audience"))
	IF AUDREQ'="",$GET(POBJ("v","aud","v"))'=AUDREQ DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_audience",ERR("status")=401
	QUIT 1
	;
VHS256(DATA,S64,CONF,CTX,POBJ,ERR)
	KILL ERR
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" DO ETRAP(.ERR) QUIT 0"
	NEW SECRET SET SECRET=$GET(CONF("auth","jwt","hmacSecret"))
	IF SECRET="" DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_hmac_secret_missing",ERR("status")=401
	NEW SIGBIN SET SIGBIN=$$B64DURL(S64,.ERR) IF $DATA(ERR) DO SETR(.ERR,"MIOAUTHJWT",401) QUIT 0
	NEW CALC SET CALC=$$HMACSHA256(DATA,SECRET,.ERR) IF $DATA(ERR) DO SETR(.ERR,"MIOAUTHJWT",401) QUIT 0
	IF CALC'=SIGBIN DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_bad_signature",ERR("status")=401
	DO APPLY(.CONF,.CTX,.POBJ)
	QUIT 1
	;
VRS256(DATA,S64,CONF,CTX,HOBJ,POBJ,ERR)
	KILL ERR
	NEW ENTRY SET ENTRY=$GET(CONF("auth","jwt","rs256Verify"))
	IF ENTRY="" DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_rs256_no_verifier",ERR("status")=401
	NEW SIGBIN SET SIGBIN=$$B64DURL(S64,.ERR) IF $DATA(ERR) DO SETR(.ERR,"MIOAUTHJWT",401) QUIT 0
	NEW OK SET OK=$$CALLVRFY(ENTRY,DATA,SIGBIN,.CONF,.CTX,.HOBJ,.POBJ,.ERR)
	IF 'OK DO SETR(.ERR,"MIOAUTHJWT",401) QUIT 0
	DO APPLY(.CONF,.CTX,.POBJ)
	QUIT 1
	;
CALLVRFY(ENTRY,DATA,SIGBIN,CONF,CTX,HOBJ,POBJ,ERR)
	NEW TAG,RTN,OK,CMD
	SET TAG=$PIECE($GET(ENTRY),"^",1),RTN=$PIECE($GET(ENTRY),"^",2)
	IF TAG=""!(RTN="") SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_rs256_bad_verifier" QUIT 0
	IF '$$ISID(TAG)!'$$ISID(RTN) SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_rs256_bad_verifier" QUIT 0
	SET OK=0
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" SET ERR(""routine"")=""MIOAUTHJWT"" SET ERR(""error"")=""jwt_rs256_verifier_exception"" SET OK=0"
	SET CMD="SET OK=$$"_TAG_"^"_RTN_"(DATA,SIGBIN,.CONF,.CTX,.HOBJ,.POBJ,.ERR)"
	XECUTE CMD
	QUIT +$GET(OK)
	;
ISID(S)
	NEW I,C,OK
	SET S=$GET(S) IF S="" QUIT 0
	SET C=$EXTRACT(S,1)
	SET OK=$SELECT((C?1A)!(C="%"):1,1:0)
	IF 'OK QUIT 0
	FOR I=2:1:$L(S) DO  QUIT:'OK
	. SET C=$EXTRACT(S,I)
	. IF '(C?1AN) SET OK=0
	QUIT OK
	;
APPLY(CONF,CTX,POBJ)
	SET CTX("auth","ok")=1
	NEW SUB SET SUB=$GET(POBJ("v","sub","v"))
	IF SUB'="" SET CTX("auth","sub")=SUB,CTX("auth","claim","sub")=SUB
	; capture string claims
	NEW K SET K=""
	FOR  SET K=$ORDER(POBJ("v",K)) QUIT:K=""  DO
	. IF $GET(POBJ("v",K,"t"))="str" SET CTX("auth","claim",K)=$GET(POBJ("v",K,"v"))
	; roles
	NEW RCLAIM SET RCLAIM=$GET(CONF("auth","jwt","rolesClaim"),"roles")
	IF $GET(POBJ("v",RCLAIM,"t"))="str" DO
	. NEW V SET V=$GET(POBJ("v",RCLAIM,"v"))
	. NEW I,RR FOR I=1:1:$L(V,",") DO
	. . SET RR=$$TRIM($PIECE(V,",",I)) IF RR'="" SET CTX("auth","roles",RR)=1
	IF $GET(POBJ("v",RCLAIM,"t"))="arr" DO
	. NEW I SET I=0
	. FOR  SET I=$ORDER(POBJ("v",RCLAIM,"v",I)) QUIT:I=""  DO
	. . NEW RR SET RR=$GET(POBJ("v",RCLAIM,"v",I,"v"))
	. . SET RR=$$TRIM(RR) IF RR'="" SET CTX("auth","roles",RR)=1
	QUIT
	;
	; ---------------- wrappers over MIOSJWT / MIOSHA256 ----------------
B64DURL(S,ERR)
	KILL ERR
	NEW X,L
	SET X=$GET(S)
	IF X="" QUIT ""
	IF '$$ISB64URL(X) DO  QUIT ""
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="b64url_char"
	SET L=$L(X)#4
	IF L=1 DO  QUIT ""
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="b64url_length"
	QUIT $$B64URLD^MIOSJWT(X)
	;
B64EURL(BIN)
	QUIT $$B64URLE^MIOSJWT($GET(BIN))
	;
BIN2STR(B)
	QUIT B
	;
HMACSHA256(DATA,SECRET,ERR)
	KILL ERR
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" DO ETRAP(.ERR) QUIT """""
	NEW HEX
	SET HEX=$$HMAC^MIOSHA256($GET(SECRET),$GET(DATA))
	QUIT $$HEX2RAW^MIOSHA256(HEX)
	;
ISB64URL(S)
	NEW I,C,OK
	SET OK=1
	FOR I=1:1:$L($GET(S)) DO  QUIT:'OK
	. SET C=$E(S,I)
	. IF C?1AN QUIT
	. IF C="-" QUIT
	. IF C="_" QUIT
	. SET OK=0
	QUIT OK
	;
TRIM(S)
	NEW X
	SET X=$GET(S)
	FOR  QUIT:X=""  QUIT:$E(X,1)'=" "  SET X=$E(X,2,$L(X))
	FOR  QUIT:X=""  QUIT:$E(X,$L(X))'=" "  SET X=$E(X,1,$L(X)-1)
	QUIT X
	;
SETR(ERR,RTN,ST)
	IF $GET(ERR("routine"))="" SET ERR("routine")=$GET(RTN)
	IF $GET(ERR("status"))="" SET ERR("status")=+$GET(ST)
	IF $GET(ERR("error"))="" SET ERR("error")="jwt_error"
	QUIT
	;
ETRAP(ERR)
	SET ERR("routine")="MIOAUTHJWT"
	IF $GET(ERR("error"))="" SET ERR("error")="jwt_exception"
	SET ERR("status")=401
	SET ERR("zstatus")=$ZSTATUS
	QUIT
	;
NOWS()
	; compatibility: seconds since $H origin (1840-12-31)
	QUIT ($PIECE($H,",",1)*86400)+$PIECE($H,",",2)
	;