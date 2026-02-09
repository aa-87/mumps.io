MIOTPLT
	;
	D TEST001
	Q
	;
TEST001
	NEW HDR S HDR="[MIOTPL][TEST001][No Interpolation]"
	NEW DESC S DESC=HDR_"[Mustache-free templates should render as-is]"
	NEW TOK,ERR,CONF,CTX,OUT
	D COMPILE^MIOTPL2("Hello from {Mustache}!"_$C(10),.TOK,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"compile "_HDR)
	SET CTX("cta")=1
	DO EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),DESC)
	DO EQ^MIOTASSERT(OUT,"Hello from {Mustache}!"_$C(10),"section render")
	QUIT
	;
	;