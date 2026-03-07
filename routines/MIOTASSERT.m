MIOTASSERT ; Full test suite assertions.
;
; NOTE
; Tests sometimes temporarily switch $IO to a read-only device (e.g. request fixture files).
; Assertions must ALWAYS print to $PRINCIPAL to avoid %YDB-E-DEVICEREADONLY.
;
OK(EXPR,MSG) ; Assert EXPR is truthy (1)
	IF +$GET(EXPR)=1 QUIT
	DO FAIL($GET(MSG,"assert failed"))
	QUIT
	;
EQ(A,B,MSG) ; Assert A equals B
	IF $GET(A)=$GET(B) QUIT
	DO FAIL($GET(MSG,"not equal")_": got="_$GET(A)_" expected="_$GET(B))
	QUIT
	;
NE(A,B,MSG) ; Assert A not equal B
	IF $GET(A)'=$GET(B) QUIT
	DO FAIL($GET(MSG,"unexpected equal")_": value="_$GET(A))
	QUIT
	;
HAS(REF,MSG) ; Assert $DATA(@REF)
	IF $DATA(@REF) QUIT
	DO FAIL($GET(MSG,"expected defined"))
	QUIT
	;
NOTHAS(REF,MSG) ; Assert '$DATA(@REF)
	IF '$DATA(@REF) QUIT
	DO FAIL($GET(MSG,"expected undefined"))
	QUIT
	;
FAIL(MSG) ; Print failure line
	; Force output to terminal to avoid read-only device errors.
	USE $PRINCIPAL
	WRITE "FAIL: ",$GET(MSG),!
	QUIT
