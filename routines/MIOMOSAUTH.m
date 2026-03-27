MIOMOSAUTH ; MIOMOS auth helpers
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
TRIM(X)
	NEW Y
	SET Y=$GET(X)
	FOR  QUIT:$EXTRACT(Y,1)'=" "  SET Y=$EXTRACT(Y,2,$LENGTH(Y))
	FOR  QUIT:$EXTRACT(Y,$LENGTH(Y))'=" "  SET Y=$EXTRACT(Y,1,$LENGTH(Y)-1)
	QUIT Y
	;
