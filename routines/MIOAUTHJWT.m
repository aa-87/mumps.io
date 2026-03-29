MIOAUTHJWT ; JWT validation using MIOSHA256 with original compat behavior
	;
	; Public API (used by tests + auth layer):
	;   $$VERIFY(.CONF,.REQ,.CTX,.ERR) -> 1/0
	;   $$CHECKCLAIMS(.CONF,.POBJ,.ERR) -> 1/0
	;   $$HMACSHA256(DATA,SECRET,.ERR) -> 32-byte binary
	;   $$B64DURL(S,.ERR) -> binary
	;   $$B64EURL(BIN) -> base64url (no padding)
	;   $$NOWS() -> seconds since $H origin (1840-12-31)
	;
	; Notes
	; - Keeps the original Base64URL implementation for framework compatibility.;
	; - Uses MIOSHA256 for HMAC-SHA256 only.;
	; - RS256 callback support preserved.;
	; - Default RS256 OpenSSL verifier auto-loads when RS256 key config exists.;
	; - HS256 secret resolution is opt-in and keeps hmacSecret precedence.;
	; - Client-secret lookup order for HS256 is:
	;     1) CONF("auth","jwt","hmacSecret")
	;     2) CONF("auth","jwt","hmacSecretByKid",<jwt header kid>)
	;     3) CONF("auth","jwt","hmacSecretByClient",<claim value>)
	;        using clientIdClaim, default claim name client_id
	;     4) CONF("auth","jwt","hs256Resolve")="TAG^ROUTINE"
	;
	QUIT
	;
VERIFY(CONF,REQ,CTX,ERR)
	KILL ERR
	NEW AH,PFX,TOK,H64,P64,S64,HJSON,PJSON,HOBJ,POBJ,OK,ALG,DATA,CNAME
	;
	SET AH=$GET(REQ("hdr","authorization"))
	SET PFX=$GET(CONF("auth","jwt","bearerPrefix"),"Bearer ")
	IF AH'="",$EXTRACT(AH,1,$L(PFX))=PFX SET TOK=$EXTRACT(AH,$L(PFX)+1,999999)
	IF $GET(TOK)="" DO
	. SET CNAME=$GET(CONF("auth","jwt","cookieName"),"miomos_auth")
	. SET TOK=$$COOKIEJWT(.REQ,CNAME)
	IF $GET(TOK)="" DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_missing",ERR("status")=401
	;
	SET H64=$PIECE(TOK,".",1),P64=$PIECE(TOK,".",2),S64=$PIECE(TOK,".",3)
	IF H64=""!(P64="")!(S64="")!($L(TOK,".")'=3) DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_format",ERR("status")=401
	;
	SET HJSON=$$BIN2STR($$B64DURL(H64,.ERR))
	IF $DATA(ERR) DO SETR(.ERR,"MIOAUTHJWT",401) QUIT 0
	;
	SET PJSON=$$BIN2STR($$B64DURL(P64,.ERR))
	IF $DATA(ERR) DO SETR(.ERR,"MIOAUTHJWT",401) QUIT 0
	;
	SET OK=$$DECODE^MIOJSON(HJSON,.HOBJ,.ERR)
	IF 'OK DO SETR(.ERR,"MIOAUTHJWT",401) QUIT 0
	;
	SET OK=$$DECODE^MIOJSON(PJSON,.POBJ,.ERR)
	IF 'OK DO SETR(.ERR,"MIOAUTHJWT",401) QUIT 0
	;
	SET ALG=$G(HOBJ("alg"))
	IF ALG="" DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_alg_missing",ERR("status")=401
	;
	IF '$$CHECKCLAIMS(.CONF,.POBJ,.ERR) DO SETR(.ERR,"MIOAUTHJWT",401) QUIT 0
	;
	SET DATA=H64_"."_P64
	IF ALG="HS256" QUIT $$VHS256(DATA,S64,.CONF,.CTX,.HOBJ,.POBJ,.ERR)
	IF ALG="RS256" QUIT $$VRS256(DATA,S64,.CONF,.CTX,.HOBJ,.POBJ,.ERR)
	;
	SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_alg_unsupported",ERR("status")=401
	QUIT 0
	;
CHECKCLAIMS(CONF,POBJ,ERR)
	KILL ERR
	NEW NOW,SKEW,EXP,NBF,ISSREQ,AUDREQ
	;
	SET NOW=+$GET(CONF("auth","jwt","now"))
	IF NOW'>0 SET NOW=$$NOWS()
	;
	SET SKEW=+$GET(CONF("auth","jwt","clockSkewSeconds"),60)
	;
	SET EXP=+$GET(POBJ("exp"))
	IF EXP>0,(NOW-SKEW)>EXP DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_expired",ERR("status")=401
	;
	SET NBF=+$GET(POBJ("nbf"))
	IF NBF>0,(NOW+SKEW)<NBF DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_not_yet_valid",ERR("status")=401
	;
	SET ISSREQ=$GET(CONF("auth","jwt","issuer"))
	IF ISSREQ'="",$GET(POBJ("iss"))'=ISSREQ DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_issuer",ERR("status")=401
	;
	SET AUDREQ=$GET(CONF("auth","jwt","audience"))
	IF AUDREQ'="",$GET(POBJ("aud"))'=AUDREQ DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_audience",ERR("status")=401
	;
	QUIT 1
	;
VHS256(DATA,S64,CONF,CTX,HOBJ,POBJ,ERR)
	KILL ERR
	NEW SECRET,SIGBIN,CALC
	;
	SET SECRET=$$GETHSEC(.CONF,.CTX,.HOBJ,.POBJ,.ERR)
	IF SECRET="" DO  QUIT 0
	. IF '$DATA(ERR) SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_hmac_secret_missing",ERR("status")=401
	. DO SETR(.ERR,"MIOAUTHJWT",401)
	;
	SET SIGBIN=$$B64DURL(S64,.ERR)
	IF $DATA(ERR) DO SETR(.ERR,"MIOAUTHJWT",401) QUIT 0
	;
	SET CALC=$$HMACSHA256(DATA,SECRET,.ERR)
	IF $DATA(ERR) DO SETR(.ERR,"MIOAUTHJWT",401) QUIT 0
	;
	IF CALC'=SIGBIN DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_bad_signature",ERR("status")=401
	;
	DO APPLY(.CONF,.CTX,.POBJ)
	QUIT 1
	;
GETHSEC(CONF,CTX,HOBJ,POBJ,ERR)
	NEW SECRET,KID,CCLAIM,CLIENT,ENTRY
	SET SECRET=$GET(CONF("auth","jwt","hmacSecret"))
	IF SECRET'="" QUIT SECRET
	;
	SET KID=$GET(HOBJ("kid"))
	IF KID'="",$DATA(CONF("auth","jwt","hmacSecretByKid",KID))#2 DO
	. SET SECRET=$GET(CONF("auth","jwt","hmacSecretByKid",KID))
	IF SECRET'="" QUIT SECRET
	;
	SET CCLAIM=$GET(CONF("auth","jwt","clientIdClaim"))
	IF CCLAIM="" SET CCLAIM="client_id"
	SET CLIENT=$GET(POBJ(CCLAIM))
	IF CLIENT'="",$DATA(CONF("auth","jwt","hmacSecretByClient",CLIENT))#2 DO
	. SET SECRET=$GET(CONF("auth","jwt","hmacSecretByClient",CLIENT))
	IF SECRET'="" QUIT SECRET
	;
	SET ENTRY=$GET(CONF("auth","jwt","hs256Resolve"))
	IF ENTRY'="" DO
	. IF $$CALLHSEC(ENTRY,.CONF,.CTX,.HOBJ,.POBJ,.SECRET,.ERR)'>0 QUIT
	IF SECRET'="" QUIT SECRET
	QUIT ""
	;
CALLHSEC(ENTRY,CONF,CTX,HOBJ,POBJ,SECRET,ERR)
	NEW TAG,RTN,OK,CMD
	SET TAG=$PIECE($GET(ENTRY),"^",1),RTN=$PIECE($GET(ENTRY),"^",2)
	IF TAG=""!(RTN="") SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_hs256_bad_resolver" QUIT 0
	IF '$$ISID(TAG)!'$$ISID(RTN) SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_hs256_bad_resolver" QUIT 0
	;
	SET OK=0,SECRET=""
	NEW $ETRAP
	SET $ETRAP="SET $ECODE="""" SET ERR(""routine"")=""MIOAUTHJWT"" SET ERR(""error"")=""jwt_hs256_resolver_exception"" SET OK=0 SET SECRET="""""
	SET CMD="SET OK=$$"_TAG_"^"_RTN_"(.CONF,.CTX,.HOBJ,.POBJ,.SECRET,.ERR)"
	XECUTE CMD
	QUIT +$GET(OK)
	;
VRS256(DATA,S64,CONF,CTX,HOBJ,POBJ,ERR)
	KILL ERR
	NEW ENTRY,SIGBIN,OK,OSIG64,OCSIG64
	;
	SET ENTRY=$GET(CONF("auth","jwt","rs256Verify"))
	IF ENTRY="",$$HASCFG^MIOAUTHRS(.CONF) DO
	. SET OK=$$INIT^MIOAUTHRS(.CONF,.ERR)
	. IF OK SET ENTRY=$GET(CONF("auth","jwt","rs256Verify"))
	IF ENTRY="" DO  QUIT 0
	. IF '$DATA(ERR) SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_rs256_no_verifier",ERR("status")=401
	. DO SETR(.ERR,"MIOAUTHJWT",401)
	;
	IF ENTRY="VERIFYOSSL^MIOAUTHRS" DO
	. SET OK=$$VERIFYJWT^MIOAUTHRS(DATA,S64,.CONF,.CTX,.HOBJ,.POBJ,.ERR)
	ELSE  DO
	. SET SIGBIN=$$B64DURL(S64,.ERR)
	. IF $DATA(ERR) DO SETR(.ERR,"MIOAUTHJWT",401) SET OK=0 QUIT
	. SET OSIG64=$GET(CTX("auth","jwt","sig64"))
	. SET OCSIG64=$GET(CONF("auth","jwt","_sig64"))
	. SET CTX("auth","jwt","sig64")=S64
	. SET CONF("auth","jwt","_sig64")=S64
	. SET OK=$$CALLVRFY(ENTRY,DATA,SIGBIN,.CONF,.CTX,.HOBJ,.POBJ,.ERR)
	. IF OSIG64="" KILL CTX("auth","jwt","sig64")
	. IF OSIG64'="" SET CTX("auth","jwt","sig64")=OSIG64
	. IF OCSIG64="" KILL CONF("auth","jwt","_sig64")
	. IF OCSIG64'="" SET CONF("auth","jwt","_sig64")=OCSIG64
	IF 'OK DO SETR(.ERR,"MIOAUTHJWT",401) QUIT 0
	;
	DO APPLY(.CONF,.CTX,.POBJ)
	QUIT 1
	;
CALLVRFY(ENTRY,DATA,SIGBIN,CONF,CTX,HOBJ,POBJ,ERR)
	NEW TAG,RTN,OK,CMD
	SET TAG=$PIECE($GET(ENTRY),"^",1),RTN=$PIECE($GET(ENTRY),"^",2)
	IF TAG=""!(RTN="") SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_rs256_bad_verifier" QUIT 0
	IF '$$ISID(TAG)!'$$ISID(RTN) SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_rs256_bad_verifier" QUIT 0
	;
	SET OK=0
	NEW $ETRAP
	SET $ETRAP="SET $ECODE="""" SET ERR(""routine"")=""MIOAUTHJWT"" SET ERR(""error"")=""jwt_rs256_verifier_exception"" SET OK=0"
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

COOKIEJWT(REQ,NAME)
	NEW RAW,I,PAIR,K,V
	SET RAW=$GET(REQ("hdr","cookie"))
	IF RAW="" SET RAW=$GET(REQ("hdr","Cookie"))
	IF RAW="" QUIT ""
	FOR I=1:1:$LENGTH(RAW,";") DO  QUIT:$GET(V)'=""
	. SET PAIR=$$TRIM($PIECE(RAW,";",I))
	. SET K=$$TRIM($PIECE(PAIR,"=",1))
	. IF K'=$GET(NAME) QUIT
	. SET V=$PIECE(PAIR,"=",2,999)
	QUIT $GET(V)
	;
APPLY(CONF,CTX,POBJ)
	SET CTX("auth","ok")=1
	;
	NEW SUB SET SUB=$GET(POBJ("sub"))
	IF SUB'="" DO
	. SET CTX("auth","sub")=SUB
	. SET CTX("auth","user")=SUB
	. SET CTX("auth","claim","sub")=SUB
	. SET CTX("auth","claims","sub")=SUB
	;
	; mirror all scalar claims into both claim and claims
	NEW K SET K=""
	FOR  SET K=$ORDER(POBJ(K)) QUIT:K=""  DO
	. IF $DATA(POBJ(K))#2 DO
	. . SET CTX("auth","claim",K)=$GET(POBJ(K))
	. . SET CTX("auth","claims",K)=$GET(POBJ(K))
	;
	; roles claim
	NEW RCLAIM SET RCLAIM=$GET(CONF("auth","jwt","rolesClaim"),"roles")
	NEW V,I,RR
	SET V=$GET(POBJ(RCLAIM))
	FOR I=1:1:$L(V,",") DO
	. SET RR=$$TRIM($PIECE(V,",",I))
	. IF RR'="" DO
	. . SET CTX("auth","roles",RR)=1
	. . SET CTX("auth","role",RR)=1
	;
	QUIT
	;
; ---------------- Base64url (original compat implementation) ----------------
B64DURL(S,ERR)
	KILL ERR
	NEW X,PAD,T,OUT,I
	SET X=$TRANSLATE($GET(S),"-_","+/")
	SET PAD=$L(X)#4
	IF PAD=2 SET X=X_"=="
	IF PAD=3 SET X=X_"="
	IF PAD=1 DO  QUIT ""
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="b64url_length"
	;
	SET T="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	SET OUT=""
	FOR I=1:4:$L(X) DO  QUIT:$DATA(ERR)
	. NEW C1,C2,C3,C4,V1,V2,V3,V4,N
	. SET C1=$E(X,I),C2=$E(X,I+1),C3=$E(X,I+2),C4=$E(X,I+3)
	. SET V1=$F(T,C1)-2
	. SET V2=$F(T,C2)-2
	. IF V1<0!(V2<0) DO  QUIT
	. . SET ERR("routine")="MIOAUTHJWT",ERR("error")="b64url_char"
	. SET V3=-1
	. IF C3'="=" SET V3=$F(T,C3)-2
	. SET V4=-1
	. IF C4'="=" SET V4=$F(T,C4)-2
	. IF (V3<-1)!(V4<-1) DO  QUIT
	. . SET ERR("routine")="MIOAUTHJWT",ERR("error")="b64url_char"
	. SET N=(V1*262144)+(V2*4096)
	. IF V3'=-1 SET N=N+(V3*64)
	. IF V4'=-1 SET N=N+V4
	. SET OUT=OUT_$C((N\65536)#256)
	. IF C3'="=" SET OUT=OUT_$C((N\256)#256)
	. IF C4'="=" SET OUT=OUT_$C(N#256)
	QUIT OUT
	;
B64EURL(BIN)
	NEW T,OUT,L,I
	SET T="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	SET OUT=""
	SET L=$L($GET(BIN))
	FOR I=1:3:L DO
	. NEW B1,B2,B3,N
	. SET B1=$A($E(BIN,I))
	. SET B2=$S(I+1<=L:$A($E(BIN,I+1)),1:-1)
	. SET B3=$S(I+2<=L:$A($E(BIN,I+2)),1:-1)
	. SET N=(B1*65536)+$S(B2=-1:0,1:B2*256)+$S(B3=-1:0,1:B3)
	. SET OUT=OUT_$E(T,(N\262144)+1)
	. SET OUT=OUT_$E(T,((N\4096)#64)+1)
	. IF B2=-1 QUIT
	. SET OUT=OUT_$E(T,((N\64)#64)+1)
	. IF B3=-1 QUIT
	. SET OUT=OUT_$E(T,(N#64)+1)
	SET OUT=$TRANSLATE(OUT,"+/","-_")
	QUIT OUT
	;
BIN2STR(B)
	QUIT B
	;
; ---------------- HMAC-SHA256 via MIOSHA256 ----------------
HMACSHA256(DATA,SECRET,ERR)
	KILL ERR
	NEW HEX
	SET HEX=$$HMAC^MIOSHA256($GET(SECRET),$GET(DATA))
	QUIT $$HEX2RAW^MIOSHA256(HEX)
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
NOWS()
	NEW H
	SET H=$HOROLOG
	QUIT +$PIECE(H,",",1)*86400+$PIECE(H,",",2)
	;
