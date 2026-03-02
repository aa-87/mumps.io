MIOAUTHJWT ; JWT validation for HS256 and RS256.;
; API STABILITY
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; Purpose
; JWT validation for HS256 and RS256.;
;
; Responsibilities
; - Authenticate requests.;
; - Validate tokens and keys.;
; - Populate auth context.;
; - Deny safely.;
;
; Entry Points
; - VERIFY
; - CHECKCLAIMS
; - VHS256
; - VRS256
; - APPLY
; - RSAVERIFY
; - HMACSHA256
; - B64DURL
; - BIN2STR
; - READPIPE
; - READPIPEBIN
; - WFILE
; - WBIN
; - DEL
; - NOWS
;
; Notes
; Keep comments short.;
; Do not log secrets.;
;
	;
	; $$VERIFY(.CONF,.REQ,.CTX,.ERR) -> 1 ok, 0 fail
	; Populates:
	;   CTX("auth","ok")=1
	;   CTX("auth","sub")=...;
	;   CTX("auth","claim",name)=value (strings)
	;   CTX("auth","roles",role)=1 (from claim configured)
	;
; Entry point
; See docs/routines for details.;
VERIFY(CONF,REQ,CTX,ERR)
	KILL ERR
	NEW AH SET AH=$GET(REQ("hdr","authorization"))
	IF AH="" SET ERR("error")="jwt_missing" QUIT 0
	NEW PFX SET PFX=$GET(CONF("auth","jwt","bearerPrefix"),"Bearer ")
	IF $EXTRACT(AH,1,$LENGTH(PFX))'=PFX SET ERR("error")="jwt_missing" QUIT 0
	NEW TOK SET TOK=$EXTRACT(AH,$LENGTH(PFX)+1,999999)
	IF TOK="" SET ERR("error")="jwt_missing" QUIT 0
	;
	NEW H64,P64,S64
	SET H64=$PIECE(TOK,".",1),P64=$PIECE(TOK,".",2),S64=$PIECE(TOK,".",3)
	IF H64=""!(P64="")!(S64="") SET ERR("error")="jwt_format" QUIT 0
	;
	NEW HJSON SET HJSON=$$BIN2STR($$B64DURL(H64,.ERR)) IF $DATA(ERR) QUIT 0
	NEW PJSON SET PJSON=$$BIN2STR($$B64DURL(P64,.ERR)) IF $DATA(ERR) QUIT 0
	;
	NEW HOBJ,POBJ,OK
	SET OK=$$DECODET^MIOJSON(HJSON,.HOBJ,.ERR) IF 'OK QUIT 0
	SET OK=$$DECODET^MIOJSON(PJSON,.POBJ,.ERR) IF 'OK QUIT 0
	;
	NEW ALG SET ALG=$GET(HOBJ("v","alg","v"))
	IF ALG="" SET ERR("error")="jwt_alg_missing" QUIT 0
	;
	; basic claim checks
	IF '$$CHECKCLAIMS(.CONF,.POBJ,.ERR) QUIT 0
	;
	; Verify signature
	NEW DATA SET DATA=H64_"."_P64
	IF ALG="HS256" QUIT $$VHS256(DATA,S64,.CONF,.CTX,.POBJ,.ERR)
	IF ALG="RS256" QUIT $$VRS256(DATA,S64,.CONF,.CTX,.HOBJ,.POBJ,.ERR)
	SET ERR("error")="jwt_alg_unsupported" QUIT 0
	;
; Entry point
; See docs/routines for details.;
CHECKCLAIMS(CONF,POBJ,ERR)
	KILL ERR
	NEW NOW SET NOW=$$NOWS()
	NEW SKEW SET SKEW=+$GET(CONF("auth","jwt","clockSkewSeconds"),60)
	; exp
	NEW EXP SET EXP=+$GET(POBJ("v","exp","v"))
	IF EXP>0,(NOW-SKEW)>EXP SET ERR("error")="jwt_expired" QUIT 0
	; nbf
	NEW NBF SET NBF=+$GET(POBJ("v","nbf","v"))
	IF NBF>0,(NOW+SKEW)<NBF SET ERR("error")="jwt_not_yet_valid" QUIT 0
	; iss
	NEW ISSREQ SET ISSREQ=$GET(CONF("auth","jwt","issuer"))
	IF ISSREQ'="" DO  IF '$TEST QUIT 0
	. SET $TEST=($GET(POBJ("v","iss","v"))=ISSREQ)
	. IF '$TEST SET ERR("error")="jwt_issuer"
	; aud (string only for simplicity)
	NEW AUDREQ SET AUDREQ=$GET(CONF("auth","jwt","audience"))
	IF AUDREQ'="" DO  IF '$TEST QUIT 0
	. SET $TEST=($GET(POBJ("v","aud","v"))=AUDREQ)
	. IF '$TEST SET ERR("error")="jwt_audience"
	QUIT 1
	;
; Entry point
; See docs/routines for details.;
VHS256(DATA,S64,CONF,CTX,POBJ,ERR)
	KILL ERR
	NEW SECRET SET SECRET=$GET(CONF("auth","jwt","hmacSecret"))
	IF SECRET="" SET ERR("error")="jwt_hmac_secret_missing" QUIT 0
	NEW SIGBIN SET SIGBIN=$$B64DURL(S64,.ERR) IF $DATA(ERR) QUIT 0
	NEW CALC SET CALC=$$HMACSHA256(DATA,SECRET,.ERR) IF $DATA(ERR) QUIT 0
	IF CALC'=SIGBIN SET ERR("error")="jwt_bad_signature" QUIT 0
	DO APPLY(.CONF,.CTX,.POBJ)
	QUIT 1
	;
; Entry point
; See docs/routines for details.;
VRS256(DATA,S64,CONF,CTX,HOBJ,POBJ,ERR)
	KILL ERR
	NEW KID SET KID=$GET(HOBJ("v","kid","v"))
	NEW URL SET URL=$GET(CONF("auth","jwt","jwksUrl"))
	NEW PEM
	IF '$$GETPEM^MIOJWKS(URL,KID,.PEM,.ERR,.CONF) QUIT 0
	NEW SIGBIN SET SIGBIN=$$B64DURL(S64,.ERR) IF $DATA(ERR) QUIT 0
	IF '$$RSAVERIFY(DATA,SIGBIN,PEM,.ERR) QUIT 0
	DO APPLY(.CONF,.CTX,.POBJ)
	QUIT 1
	;
; Entry point
; See docs/routines for details.;
APPLY(CONF,CTX,POBJ)
	SET CTX("auth","ok")=1
	NEW SUB SET SUB=$GET(POBJ("v","sub","v"))
	IF SUB'="" SET CTX("auth","sub")=SUB,CTX("auth","claim","sub")=SUB
	; capture common string claims
	NEW K SET K=""
	FOR  SET K=$ORDER(POBJ("v",K)) QUIT:K=""  DO
	. IF $GET(POBJ("v",K,"t"))="str" SET CTX("auth","claim",K)=$GET(POBJ("v",K,"v"))
	; roles claim (string "a,b" or array of strings)
	NEW RCLAIM SET RCLAIM=$GET(CONF("auth","jwt","rolesClaim"),"roles")
	IF $GET(POBJ("v",RCLAIM,"t"))="str" DO
	. NEW V SET V=$GET(POBJ("v",RCLAIM,"v"))
	. NEW I,RR FOR I=1:1:$LENGTH(V,",") DO
	. . SET RR=$$TRIM^MIOAUTH($PIECE(V,",",I)) IF RR'="" SET CTX("auth","roles",RR)=1
	IF $GET(POBJ("v",RCLAIM,"t"))="arr" DO
	. NEW I SET I=0
	. FOR  SET I=$ORDER(POBJ("v",RCLAIM,"v",I)) QUIT:I=""  DO
	. . NEW RR SET RR=$GET(POBJ("v",RCLAIM,"v",I,"v"))
	. . IF RR'="" SET CTX("auth","roles",RR)=1
	QUIT
	;
; Entry point
; See docs/routines for details.;
RSAVERIFY(DATA,SIGBIN,PEM,ERR)
	KILL ERR
	; write temp files
	NEW TS SET TS=$HOROLOG
	NEW F1 SET F1="tmp/miojwt_data_"_$J_"_"_$PIECE(TS,",",2)
	NEW F2 SET F2="tmp/miojwt_sig_"_$J_"_"_$PIECE(TS,",",2)
	NEW F3 SET F3="tmp/miojwt_pub_"_$J_"_"_$PIECE(TS,",",2)
	DO WFILE(F1,DATA_$CHAR(10))
	DO WBIN(F2,SIGBIN)
	DO WFILE(F3,PEM)
	NEW CMD SET CMD="openssl dgst -sha256 -verify "_F3_" -signature "_F2_" "_F1_" 2>/dev/null"
	NEW OUT SET OUT=$$READPIPE(CMD,200,.ERR)
	DO DEL(F1),DEL(F2),DEL(F3)
	IF $DATA(ERR) QUIT 0
	IF OUT["Verified OK" QUIT 1
	SET ERR("error")="jwt_bad_signature"
	QUIT 0
	;
; Entry point
; See docs/routines for details.;
HMACSHA256(DATA,SECRET,ERR)
	KILL ERR
	NEW TS SET TS=$HOROLOG
	NEW F1 SET F1="tmp/miohmac_data_"_$J_"_"_$PIECE(TS,",",2)
	DO WFILE(F1,DATA)
	NEW CMD SET CMD="openssl dgst -sha256 -mac HMAC -macopt key:"_$$Q(SECRET)_" -binary "_F1_" 2>/dev/null"
	NEW OUTBIN SET OUTBIN=$$READPIPEBIN(CMD,1024,.ERR)
	DO DEL(F1)
	QUIT OUTBIN
	;
; ----- base64url decode -----
B64DURL(S,ERR)
	KILL ERR
	NEW X SET X=$TRANSLATE($GET(S),"-_","+/")
	NEW PAD SET PAD=$LENGTH(X)#4
	IF PAD=2 SET X=X_"=="
	ELSE  IF PAD=3 SET X=X_"="
	ELSE  IF PAD=1 SET ERR("error")="b64url_length" QUIT ""
	NEW T SET T="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	NEW OUT SET OUT=""
	NEW I FOR I=1:4:$LENGTH(X) DO
	. NEW C1,C2,C3,C4
	. SET C1=$EXTRACT(X,I),C2=$EXTRACT(X,I+1),C3=$EXTRACT(X,I+2),C4=$EXTRACT(X,I+3)
	. NEW V1,V2,V3,V4
	. SET V1=$FIND(T,C1)-2,V2=$FIND(T,C2)-2
	. IF V1<0!(V2<0) SET ERR("error")="b64url_char" QUIT
	. IF C3="=" SET V3=-1 ELSE  SET V3=$FIND(T,C3)-2
	. IF C4="=" SET V4=-1 ELSE  SET V4=$FIND(T,C4)-2
	. IF (V3<-1)!(V4<-1) SET ERR("error")="b64url_char" QUIT
	. NEW N SET N=(V1*262144)+(V2*4096)+$SELECT(V3=-1:0,1:V3*64)+$SELECT(V4=-1:0,1:V4)
	. SET OUT=OUT_$CHAR((N\65536)#256)
	. IF C3'="=" SET OUT=OUT_$CHAR((N\256)#256)
	. IF C4'="=" SET OUT=OUT_$CHAR(N#256)
	QUIT OUT
	;
; Entry point
; See docs/routines for details.;
BIN2STR(B)
	QUIT B  ; bytes are fine as M string
	;
; ----- small helpers -----
READPIPE(CMD,MAX,ERR)
	KILL ERR
	NEW DEV SET DEV="|"_CMD
	OPEN DEV:(readonly)::"pipe" ELSE  SET ERR("error")="pipe_open_failed" QUIT ""
	USE DEV
	NEW CH,OUT SET OUT=""
	FOR  READ CH:1 QUIT:$ZEOF  DO
	. SET OUT=OUT_CH
	. IF $LENGTH(OUT)>MAX SET ERR("error")="pipe_output_too_large" QUIT
	CLOSE DEV
	QUIT OUT
	;
; Entry point
; See docs/routines for details.;
READPIPEBIN(CMD,MAX,ERR)
	; read binary output
	KILL ERR
	NEW DEV SET DEV="|"_CMD
	OPEN DEV:(readonly)::"pipe" ELSE  SET ERR("error")="pipe_open_failed" QUIT ""
	USE DEV
	NEW CH,OUT SET OUT=""
	FOR  READ CH#1:1 QUIT:$ZEOF  DO
	. SET OUT=OUT_CH
	. IF $LENGTH(OUT)>MAX SET ERR("error")="pipe_output_too_large" QUIT
	CLOSE DEV
	QUIT OUT
	;
; Entry point
; See docs/routines for details.;
WFILE(PATH,TXT)
	OPEN PATH:"WNS" USE PATH WRITE TXT CLOSE PATH QUIT
	;
; Entry point
; See docs/routines for details.;
WBIN(PATH,BIN)
	OPEN PATH:"WNS" USE PATH WRITE BIN CLOSE PATH QUIT
	;
; Entry point
; See docs/routines for details.;
DEL(PATH)
	NEW CMD SET CMD="rm -f "_PATH
	ZSYSTEM CMD
	QUIT
	;
Q(S) ; for -macopt key:... (strip quotes)
	NEW X SET X=$GET(S)
	SET X=$TRANSLATE(X,"'","")
	QUIT X
	;
; Entry point
; See docs/routines for details.;
NOWS()
	NEW H SET H=$HOROLOG
	QUIT +$PIECE(H,",",1)*86400 + +$PIECE(H,",",2)
	;