MIOTPLT
	;
	D TEST001
	Q
	;
TEST001
	NEW HDR S HDR="[MIOTPL][TEST001][No Interpolation]"
	NEW DESC S DESC=HDR_"[Mustache-free templates should render as-is]"
	NEW TOK,ERR,CONF,CTX,OUT
	D COMPILE^MIOTPL2($$UES("Hello from {Mustache}!\n"),.TOK,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"compile "_HDR)
	SET CTX("cta")=1
	DO EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"[EVAL]"_DESC)
	DO EQ^MIOTASSERT(OUT,$$UES("Hello from {Mustache}!\n"),"[RENDER]"_DESC)
	QUIT
TEST002
	NEW HDR S HDR="[MIOTPL][TEST002][Basic Interpolation]"
	NEW DESC S DESC=HDR_"[Unadorned tags should interpolate content into the template.]"
	NEW TOK,ERR,CONF,CTX,OUT
	D COMPILE^MIOTPL2($$UES("Hello, {{subject}}!\n"),.TOK,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"compile "_HDR)
	SET CTX("cta")=1
	SET CTX("subject")="world"
	DO EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"[EVAL]"_DESC)
	DO EQ^MIOTASSERT(OUT,$$UES("Hello, world!\n"),"[RENDER]"_DESC)
	QUIT
	;
UES(X)
	N POS,Y,START
	S POS=0,Y=""
	F  S START=POS+1 D  Q:START>$L(X)
	. S POS=$F(X,"\",POS+1)
	. I 'POS S Y=Y_$E(X,START,$L(X)),POS=$L(X) I 1
	. E  S Y=Y_$E(X,START,POS-2)_$$REALCHAR($E(X,POS),X,.POS)
	Q Y
REALCHAR(C,X,POS)
	N OPOS
	I C="""" Q """"
	I C="/" Q "/"
	I C="\" Q "\"
	I C="b" Q $C(8)
	I C="f" Q $C(12)
	I C="n" Q $C(10)
	I C="r" Q $C(13)
	I C="t" Q $C(9)
	I C="u" S OPOS=POS S POS=POS+4 Q $C($$FUNC^%HD($E(X,OPOS+1,OPOS+4)))
	Q C
	;
	;