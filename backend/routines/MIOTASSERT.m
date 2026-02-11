MIOTASSERT ; Full test suite assertions.;
OK(EXPR,MSG) ;
	IF +$GET(EXPR)=1 QUIT
	DO FAIL($GET(MSG,"assert failed"))
	QUIT
EQ(A,B,MSG) ;
	IF $GET(A)=$GET(B) QUIT
	DO FAIL($GET(MSG,"not equal")_": got="_$GET(A)_" expected="_$GET(B))
	QUIT
NE(A,B,MSG) ;
	IF $GET(A)'=$GET(B) QUIT
	DO FAIL($GET(MSG,"unexpected equal")_": value="_$GET(A))
	QUIT
HAS(REF,MSG) ;
	IF $DATA(@REF) QUIT
	DO FAIL($GET(MSG,"expected defined"))
	QUIT
NOTHAS(REF,MSG) ;
	IF '$DATA(@REF) QUIT
	DO FAIL($GET(MSG,"expected undefined"))
	QUIT
FAIL(MSG) ;
	WRITE "FAIL: ",$GET(MSG),!
	Q
	;