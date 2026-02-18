		;; =============================================================================
	;;		; ## Public entry points
	;;		; =============================================================================
	;;		Q
	;;	START(CONF)
	;;	PRECOMPILE(CONF)
	;;	RENDER(NAME,CONF,CTX,OUT,ERR)
	;;	RENDERPAGE(PAGE,LAYOUT,CONF,CTX,OUT,ERR)
	;;	RENDERLAYOUT(LAYOUT,CONF,CTX,OUT,ERR)
	;;	EVAL(TOK,CONF,CTX,OUT,ERR)
	;;	EVALREF(TOK,CONF,CTX,OREF,ERR)
	;;	RENDERANY(IN,CONF,CTX,OUT,ERR)
	;;	RENDERREF(IN,CONF,CTX,OREF,ERR)
	;;
	;;		; =============================================================================
	;;		; ## Template acquisition & cache
	;;		; =============================================================================
	;;	GETTOK(NAME,CONF,TOK,ERR)
	;;	GETTOKREF(NAME,CONF,TOKREF,PMAX,ERR)
	;;	GETTOKFP(FP,CONF,TOK,ERR,OPT)
	;;	GETTOKFPSTR(FP,CONF,TOK,ERR,OPT)
	;;	LOADTOK(FP,TOK)
	;;	NAME2FP(NAME,CONF,ERR)
	;;	FILEEXISTS(FP)
	;;	ENUMGLOBS(ROOT,LIST)
	;;	ENUM1(RT,PAT,LIST)
	;;
	;;		; =============================================================================
	;;		; ## File IO / streaming
	;;		; =============================================================================
	;;	READFILE(FP,TXT,ERR)
	;;	RFERR
	;;	READFILE2REF(FP,ROOT,CONF,H,ERR)
	;;	RF2ERR
	;;	REFROOT(TREF,ROOT,ERR)
	;;
	;;		; =============================================================================
	;;		; ## Compile / parse
	;;		; =============================================================================
	;;	COMPILE(TEXT,TOK,ERR)
	;;	COMPREF(TREF,TOK,ERR)
	;;	COMPILEA(ARR,TOK,ERR)
	;;	PARSEREF(ROOT,TOK,CRLF,ERR)
	;;	PARSE(TEXT,TOK,ERR)
	;;	PARSEBUF(P,TOK,N,ERR,FINAL)
	;;	NORMNL(S)
	;;	NORMNLCH(CHUNK,P,CRLF)
	;;	NEXTTOK(REST)
	;;	ADDDELIM(TOK,N,OD,CD)
	;;	ADDTXT(TOK,N,VAL)
	;;	ADDVAR(TOK,N,KEY,ESC)
	;;	ADDSECS(TOK,N,KEY,INV)
	;;	ADDSECE(TOK,N,KEY)
	;;	ADDPART(TOK,N,NAME)
	;;	ADDCOMM(TOK,N)
	;;	LINKSECS(TOK,ERR)
	;;
	;;		; =============================================================================
	;;		; ## Standalone tags / indentation
	;;		; =============================================================================
	;;	STANDTOK(TOK)
	;;	ISSTAND(TOK,I,MAX)
	;;	STANDAP(TOK,I,MAX)
	;;	LINEPURE(TOK,I,MAX)
	;;	INDENTSTR(S,IND)
	;;	INDTXT(V,IND,AT)
	;;	HEADWNL(S)
	;;	CUTNX(S)
	;;	CUTPRE(S)
	;;	TAILWS(S)
	;;	LASTNLSEQ(S)
	;;	HASNL(S)
	;;	ALLWS(S)
	;;	INDENTPTOK(TOK,IND)
	;;	NUMMAX(TOK)
	;;
	;;		; =============================================================================
	;;		; ## Evaluation engine (zero-copy capable)
	;;		; =============================================================================
	;;	EVALX(TOK,CONF,CTX,OUTMODE,OUT,OREF,ERR)
	;;	TOKINFO(TOK,TOKR,PMAX,CRLF)
	;;	TOKGET(TN,I,FIELD)
	;;	TOKENDR(TOKR)
	;;	TOKEND(TOKR)
	;;	TOKG(TOKR,I,FIELD)
	;;	TOKMAX(TOKNAME)
	;;	PUSHFRAME(...)
	;;	PUSHFRAMEI(...)
	;;	POPX(...)
	;;	EMITX(...)
	;;	OUTNORM(...)
	;;	ISTRUTH(...)
	;;	RESREF(...)
	;;	RESINBASE(...)
	;;	RESVAL(...)
	;;
	;;		; =============================================================================
	;;		; ## Output writer (REF mode)
	;;		; =============================================================================
	;;	OUTINIT(W,OREF,CONF,CRLF)
	;;	OUTAPP(W,VAL)
	;;	OUTFLUSH(W)
	;;	LF2CRLF(S)
	;;
	;;		; =============================================================================
	;;		; ## Data structure helpers / string utils / hashing
	;;		; =============================================================================
	;;	APPREF(REF,SUB)
	;;	FIRSTSUB(REF)
	;;	QSUB(SUB)
	;;	SPLIT(STR,DEL,ARR,COUNT)
	;;	TRIM(S)
	;;	ESCHTML(S)
	;;	REPL(s,f,t)
	;;	BOOL(X)
	;;	JOIN(ARR,SEP)
	;;	H32(TEXT)
	;;	H32UPD(H,TEXT)
	;;	XOR32(A,B)
	;;	MUL32(A,M)
	;;	ADD32(A,B) ;