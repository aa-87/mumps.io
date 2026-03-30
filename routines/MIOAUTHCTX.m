MIOAUTHCTX ; Shared auth context helpers
	QUIT
	;
PRINCIPAL(CTX)
	NEW SUB,KID
	SET SUB=$GET(CTX("auth","claims","sub"))
	IF SUB'="" QUIT SUB
	SET KID=$GET(CTX("auth","key_id"))
	IF KID'="" QUIT "apikey-"_KID
	IF +$GET(CTX("auth","ok"))=1 QUIT "authenticated"
	QUIT ""
	;
USERNAME(CTX)
	NEW X
	SET X=$GET(CTX("auth","claims","preferred_username")) IF X'="" QUIT X
	SET X=$GET(CTX("auth","claims","name")) IF X'="" QUIT X
	SET X=$GET(CTX("auth","claims","sub")) IF X'="" QUIT X
	SET X=$GET(CTX("auth","key_id")) IF X'="" QUIT "API key "_X
	QUIT "Authenticated user"
	;
ROLECSV(CTX)
	NEW OUT,R
	SET OUT="",R=""
	FOR  SET R=$ORDER(CTX("auth","roles",R)) QUIT:R=""  DO
	. IF OUT'="" SET OUT=OUT_"," 
	. SET OUT=OUT_R
	IF OUT'="" QUIT OUT
	QUIT $GET(CTX("auth","claims","roles"))
	;
HASROLE(CTX,ROLE)
	NEW CSV,I,X,FOUND
	IF $GET(ROLE)="" QUIT 0
	IF +$DATA(CTX("auth","roles",ROLE)) QUIT 1
	SET CSV=$$ROLECSV(.CTX),FOUND=0
	FOR I=1:1:$LENGTH(CSV,",") DO  QUIT:FOUND
	. SET X=$$TRIM($PIECE(CSV,",",I))
	. IF X=ROLE SET FOUND=1
	QUIT FOUND
	;
ROLEARY(CTX,OUT)
	NEW CSV,I,X,N
	KILL OUT
	SET CSV=$$ROLECSV(.CTX),N=0
	FOR I=1:1:$LENGTH(CSV,",") DO
	. SET X=$$TRIM($PIECE(CSV,",",I))
	. IF X="" QUIT
	. SET N=N+1,OUT(N)=X
	QUIT
	;
SETROLES(CTX,CSV)
	NEW I,X
	FOR I=1:1:$LENGTH($GET(CSV),",") DO
	. SET X=$$TRIM($PIECE(CSV,",",I))
	. IF X'="" SET CTX("auth","roles",X)=1,CTX("auth","role",X)=1
	QUIT
	;
COOKIE(REQ,NAME)
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
TRIM(S)
	QUIT $$TRIM^MIOUTIL($GET(S))
	;
