MIOTPL2 ; # MIOTPL2
	;
	; Template engine for MUMPS.IO.;
	; Mustache first. Small Handlebars-like subset.;
	;
	; ## Public entry points
	; - START(.CONF)
	; - PRECOMPILE(.CONF)
	; - RENDER(NAME,.CONF,.CTX,.OUT,.ERR)
	; - RENDERPAGE(PAGE,LAYOUT,.CONF,.CTX,.OUT,.ERR)
	; - RENDERLAYOUT(LAYOUT,.CONF,.CTX,.OUT,.ERR)
	; - GETTOK(NAME,.CONF,.TOK,.ERR)
	; - GETTOKFP(FP,.CONF,.TOK,.ERR[,OPT])
	; - GETTOKREF(NAME,.CONF,.TOKREF,.PMAX,.ERR)
	;
	; ## Token model
	; - TOK(n,"t") = text | var | secS | secE | part | comm | delim
	; - text: TOK(n,"v")
	; - var : TOK(n,"k") key, TOK(n,"e") escape flag
	; - secS: TOK(n,"k") key, TOK(n,"inv") inverted, TOK(n,"m") match index
	; - secE: TOK(n,"k") key
	; - part: TOK(n,"k") name, TOK(n,"indent") call-site indent (standalone only)
	; - meta: TOK("meta","crlf") = 1 when original input was CRLF
	;
	; ## Cache
	; - ^MIO("TPL","CACHE",FP,"H")       content hash (FNV-1a 32-bit)
	; - ^MIO("TPL","CACHE",FP,"TOK",...) compiled tokens
	; - ^MIO("TPL","CACHE",FP,"ts")      last compile time ($H)
	;
	; ## Notes
	; - Streaming compile avoids MAXSTRING. See CONF("templates","streamFiles").;
	; - Tests live in ^MIOTPLT.;
	;
	Q
START(CONF)
	I '$D(CONF("templates","streamFiles")) S CONF("templates","streamFiles")=0
	I '$D(CONF("templates","streamFallback")) S CONF("templates","streamFallback")=1
	I '$D(CONF("templates","fileChunk")) S CONF("templates","fileChunk")=32768
	NEW EN
	;DO START^MIOTPLW(.CONF)
	SET EN=$S($GET(CONF("templates","precompileEnabled"))="true":1,1:+$GET(CONF("templates","precompileEnabled")))
	IF EN DO PRECOMPILE(.CONF)
	QUIT
PRECOMPILE(CONF) ;
	NEW ROOT SET ROOT=$GET(CONF("server","templateDir")) IF ROOT="" SET ROOT="templates"
	NEW LIST KILL LIST
	NEW I,PATH
	SET I=0
	FOR  SET I=$ORDER(CONF("templates","precompile","path",I)) QUIT:'I  DO
	. SET PATH=$GET(CONF("templates","precompile","path",I))
	. IF PATH'="" SET LIST(PATH)=1
	IF '$DATA(LIST) DO ENUMGLOBS(ROOT,.LIST)
	NEW FP,OK,TOK,ERR
	SET FP=""
	FOR  SET FP=$ORDER(LIST(FP)) QUIT:FP=""  DO
	. DO GETTOKFP(FP,.CONF,.TOK,.ERR)
	QUIT
RENDER(NAME,CONF,CTX,OUT,ERR)
	K ERR S OUT=""
	N TOK
	D GETTOK(NAME,.CONF,.TOK,.ERR) Q:$D(ERR)
	D EVAL(.TOK,.CONF,.CTX,.OUT,.ERR)
	Q
RENDERPAGE(PAGE,LAYOUT,CONF,CTX,OUT,ERR)
	K ERR S OUT=""
	N PAGEOUT,OK
	; Reset blocks for this page render.;
	K CTX("blocks")
	S CTX("content")=""
	D RENDER(PAGE,.CONF,.CTX,.PAGEOUT,.ERR)  
	Q:$D(ERR) 
	S CTX("content")=PAGEOUT
	D RENDERLAYOUT(LAYOUT,.CONF,.CTX,.OUT,.ERR)
	Q
RENDERLAYOUT(LAYOUT,CONF,CTX,OUT,ERR)
	K ERR S OUT=""
	D RENDER(LAYOUT,.CONF,.CTX,.OUT,.ERR)
	Q
EVAL(TOK,CONF,CTX,OUT,ERR)
	K ERR
	D EVALX^MIOTPL2(.TOK,.CONF,.CTX,"S",.OUT,"",.ERR)
	Q
EVALREF(TOK,CONF,CTX,OREF,ERR)
	N DUM
	K ERR
	D EVALX^MIOTPL2(.TOK,.CONF,.CTX,"R",.DUM,$G(OREF),.ERR)
	Q
RENDERANY(IN,CONF,CTX,OUT,ERR)
	K ERR
	N TOK
	I $$ISREF^MIOTPL2($G(IN)) D  Q
	. D COMPREF^MIOTPL2($G(IN),.TOK,.ERR) Q:$D(ERR)
	. D EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	D COMPILE^MIOTPL2($G(IN),.TOK,.ERR) Q:$D(ERR)
	D EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	Q
RENDERREF(IN,CONF,CTX,OREF,ERR)
	K ERR
	N TOK
	S CONF("templates","streamFiles")=1
	I $$ISREF^MIOTPL2($G(IN)) D  Q
	. D COMPREF^MIOTPL2($G(IN),.TOK,.ERR) Q:$D(ERR)
	. D EVALREF^MIOTPL2(.TOK,.CONF,.CTX,$G(OREF),.ERR)
	D COMPILE^MIOTPL2($G(IN),.TOK,.ERR) Q:$D(ERR)
	D EVALREF^MIOTPL2(.TOK,.CONF,.CTX,$G(OREF),.ERR)
	Q
COMPILE(TEXT,TOK,ERR) ;
	N CRLF
	S CRLF=$S($F($G(TEXT),$C(13,10))>0:1,1:0)
	S TEXT=$$NORMNL^MIOTPL2(TEXT)
	D PARSE(.TEXT,.TOK,.ERR) 
	I $D(ERR) Q
	S TOK("meta","crlf")=CRLF
	D LINKSECS(.TOK,.ERR)
	I $D(ERR) Q
	D STANDTOK(.TOK)
	Q
COMPREF(TREF,TOK,ERR)
	N ROOT,CRLF
	D REFROOT(TREF,.ROOT,.ERR) I $D(ERR) Q
	D PARSEREF(ROOT,.TOK,.CRLF,.ERR) I $D(ERR) Q
	S TOK("meta","crlf")=CRLF
	D LINKSECS(.TOK,.ERR) I $D(ERR) Q
	D STANDTOK(.TOK)
	Q
COMPILEA(ARR,TOK,ERR)  
	N ROOT,CRLF
	S ROOT=$NA(ARR)
	D PARSEREF(ROOT,.TOK,.CRLF,.ERR) I $D(ERR) Q
	S TOK("meta","crlf")=CRLF
	D LINKSECS(.TOK,.ERR) I $D(ERR) Q
	D STANDTOK(.TOK)
	Q
GETTOKFP(FP,CONF,TOK,ERR,OPT);
	 K ERR K TOK
	NEW CH,OK,TXT,STREAM,FB
	S STREAM=$$BOOL($G(CONF("templates","streamFiles")))
	S FB=$$BOOL($G(CONF("templates","streamFallback")))
	I 'STREAM,'FB S FB=1 
	IF STREAM DO GETTOKFPSTR(FP,.CONF,.TOK,.ERR,$G(OPT)) QUIT
	SET CH=$GET(^MIO("TPL","CACHE",FP,"H"))
	SET OK=$$READFILE(FP,.TXT,.ERR)
	IF 'OK DO  QUIT
	. IF $GET(ERR("code"))="TPL_TOOLARGE",FB DO  QUIT
	. . DO GETTOKFPSTR(FP,.CONF,.TOK,.ERR,$G(OPT))
	. QUIT
	SET H=$$H32(TXT)
	IF CH'="",CH=H,$DATA(^MIO("TPL","CACHE",FP,"TOK",1)) DO  QUIT
	. S ^MIO("TPL","CACHE",FP,"ts")=$H
	. I $G(OPT)'="REF" M TOK=^MIO("TPL","CACHE",FP,"TOK")
	NEW TMP KILL TMP
	DO PARSE(TXT,.TMP,.ERR) QUIT:$D(ERR)
	DO LINKSECS(.TMP,.ERR) QUIT:$D(ERR)
	K ^MIO("TPL","CACHE",FP)
	S ^MIO("TPL","CACHE",FP,"ts")=$H
	S ^MIO("TPL","CACHE",FP,"H")=H
	M ^MIO("TPL","CACHE",FP,"TOK")=TMP
	I $G(OPT)="REF" K TOK
	E  MERGE TOK=TMP
	Q	
PARSEBUF(P,TOK,N,ERR,FINAL)
	N BUF,OD,CD,POS,L,OPEN,PRE,TRI,END3,CLOSE,INSIDE,RAW
	N DONE,TAIL,SAFE,TXT
	S BUF=$G(P("buf")),OD=$G(P("od")),CD=$G(P("cd"))
	S POS=1,DONE=0
	F  Q:DONE  D  Q:$D(ERR)
	. S L=$L(BUF)
	. I POS>L S BUF="",DONE=1 Q
	. S OPEN=$F(BUF,OD,POS)
	. I 'OPEN D  Q
	. . I FINAL D
	. . . S PRE=$E(BUF,POS,L) I PRE'="" D ADDTXT(.TOK,.N,PRE)
	. . . S BUF="",DONE=1 Q
	. . S TAIL=$L(OD)-1 I TAIL<0 S TAIL=0
	. . I TAIL=0 D  S BUF="",DONE=1 Q
	. . . S TXT=$E(BUF,POS,L) I TXT'="" D ADDTXT(.TOK,.N,TXT)
	. . S SAFE=L-TAIL
		. . I SAFE<POS S BUF=$E(BUF,POS,L),DONE=1 Q
	. . S TXT=$E(BUF,POS,SAFE) I TXT'="" D ADDTXT(.TOK,.N,TXT)
	. . S BUF=$E(BUF,SAFE+1,L)
	. . S DONE=1 Q
	. S PRE=$E(BUF,POS,OPEN-$L(OD)-1)
	. I PRE'="" D ADDTXT(.TOK,.N,PRE)
	. S TRI=0
	. I (OD="{{")&(CD="}}") D
	. . I OPEN>$L(BUF) S TRI=-1 Q
	. . I $E(BUF,OPEN)="{" S TRI=1
	. I TRI=-1 D  Q
	. . S BUF=$E(BUF,OPEN-$L(OD),L),POS=1,DONE=1
	. I TRI=1 D  Q
	. . S END3=$F(BUF,"}}}",OPEN)
	. . I 'END3 D  Q
	. . . I FINAL S ERR("code")="TPL_PARSE",ERR("msg")="Unclosed triple mustache." Q
	. . . S BUF=$E(BUF,OPEN-$L(OD),L),POS=1,DONE=1
	. . S RAW=$$TRIM($E(BUF,OPEN+1,END3-4))
	. . D ADDVAR(.TOK,.N,RAW,0)
	. . S POS=END3
	. S CLOSE=$F(BUF,CD,OPEN)
	. I 'CLOSE D  Q
	. . I FINAL S ERR("code")="TPL_PARSE",ERR("msg")="Unclosed mustache tag." Q
	. . S BUF=$E(BUF,OPEN-$L(OD),L),POS=1,DONE=1
	. S INSIDE=$$TRIM($E(BUF,OPEN,CLOSE-$L(CD)-1))
	. I $E(INSIDE,1)="=",$E(INSIDE,$L(INSIDE))="=" D  S POS=CLOSE Q
	. . N MID,REST,W1,W2
	. . S MID=$$TRIM($E(INSIDE,2,$L(INSIDE)-1))
	. . S REST=MID
	. . S W1=$$NEXTTOK(.REST),W2=$$NEXTTOK(.REST)
	. . I W1=""!(W2="") S ERR("code")="TPL_PARSE",ERR("msg")="Bad delimiter change tag." Q
	. . D ADDDELIM(.TOK,.N,W1,W2)
	. . S OD=W1,CD=W2
	. . S P("od")=OD,P("cd")=CD
	. ; comment
	. I $E(INSIDE,1)="!" D ADDCOMM(.TOK,.N) S POS=CLOSE Q
	. ; unescaped via &
	. I $E(INSIDE,1)="&" D  S POS=CLOSE Q
	. . N K S K=$$TRIM($E(INSIDE,2,$L(INSIDE))) D ADDVAR(.TOK,.N,K,0)
	. ; partials
	. I $E(INSIDE,1)=">" D  S POS=CLOSE Q
	. . N PNM S PNM=$$TRIM($E(INSIDE,2,$L(INSIDE))) D ADDPART(.TOK,.N,PNM)
	. ; sections / inverted / end
	. I $E(INSIDE,1)="#"!($E(INSIDE,1)="^")!($E(INSIDE,1)="/") D  S POS=CLOSE Q
	. . N OP,K,INV
	. . S OP=$E(INSIDE,1)
	. . S K=$$TRIM($E(INSIDE,2,$L(INSIDE)))
	. . ; Handlebars-ish helper prefixes
	. . I OP="#" D
	. . . I $E(K,1,3)="if " S K=$$TRIM($E(K,4,$L(K)))
	. . . I $E(K,1,5)="each " S K=$$TRIM($E(K,6,$L(K)))
	. . . I $E(K,1,7)="unless " S OP="^",K=$$TRIM($E(K,8,$L(K)))
	. . I OP="/" D ADDSECE(.TOK,.N,K) Q
	. . S INV=$S(OP="^":1,1:0)
	. . D ADDSECS(.TOK,.N,K,INV)
	. . I $E(K,1,6)="block:" S TOK(N,"blk")=1,TOK(N,"bname")=$E(K,7,$L(K))
	. ; default escaped var
	. D ADDVAR(.TOK,.N,INSIDE,1)
	. S POS=CLOSE
	S P("buf")=BUF
	Q
	;
	;	
	;	
	;	
	;	
ENUMGLOBS(ROOT,LIST) ;
	DO ENUM1(ROOT,"/*.html",.LIST)
	DO ENUM1(ROOT,"/*.htm",.LIST)
	DO ENUM1(ROOT,"/pages/*.html",.LIST)
	DO ENUM1(ROOT,"/layouts/*.html",.LIST)
	DO ENUM1(ROOT,"/partials/*.html",.LIST)
	DO ENUM1(ROOT,"/includes/*.html",.LIST)
	QUIT
ENUM1(RT,PAT,LIST) ;
	NEW F,T SET F=$ZSEARCH(RT_PAT)
	FOR  QUIT:F=""  DO
	. SET T=RT_$P(F,RT,2,999)
	. SET LIST(T)=1
	. SET F=$ZSEARCH(RT_PAT)
	QUIT
GETTOK(NAME,CONF,TOK,ERR)
	K ERR K TOK N FP
	S FP=$$NAME2FP(NAME,.CONF,.ERR) Q:$D(ERR)
	D GETTOKFP(FP,.CONF,.TOK,.ERR)
	Q
GETTOKREF(NAME,CONF,TOKREF,PMAX,ERR)
	NEW FP,DUM
	K ERR
	S TOKREF="",PMAX=0
	S FP=$$NAME2FP^MIOTPL2(NAME,.CONF,.ERR) Q:$D(ERR)
	; Ensure cached tokens exist, but do NOT MERGE to local arrays
	D GETTOKFP^MIOTPL2(FP,.CONF,.DUM,.ERR,"REF") Q:$D(ERR)
	S TOKREF=$NA(^MIO("TPL","CACHE",FP,"TOK"))
	S PMAX=$$TOKENDR^MIOTPL2(TOKREF)
	Q
	;
BOOL(X)
	N L S L=$ZCONVERT($G(X),"L")
	Q $S(X=1:1,X="1":1,L="true":1,L="yes":1,1:0)
GETTOKFPSTR(FP,CONF,TOK,ERR,OPT) ;
	K ERR K TOK
	I $$FILEEXISTS(FP)="" S ERR("code")="TPL_NOFILE",ERR("msg")="Template file not found: "_FP Q
	NEW CH,H,ROOT SET ROOT=$NA(TMPBUF("FILE"))
	NEW TMPBUF KILL @ROOT
	DO READFILE2REF(FP,ROOT,.CONF,.H,.ERR) I $D(ERR) KILL @ROOT QUIT
	IF CH'="",CH=H,$DATA(^MIO("TPL","CACHE",FP,"TOK",1)) DO  KILL @ROOT QUIT
	. MERGE TOK=^MIO("TPL","CACHE",FP,"TOK")
	NEW TMP KILL TMP
	DO COMPREF(ROOT,.TMP,.ERR)
	KILL @ROOT
	QUIT:$D(ERR)
	KILL ^MIO("TPL","CACHE",FP)
	SET ^MIO("TPL","CACHE",FP,"H")=H
	MERGE ^MIO("TPL","CACHE",FP,"TOK")=TMP
	I $G(OPT)="REF" K TOK
	E  MERGE TOK=TMP
	Q
LOADTOK(FP,TOK)
	K TOK
	M TOK=^MIO("TPL","CACHE",FP,"TOK")
	Q
NAME2FP(NAME,CONF,ERR)
	N ROOT,EXT,NM,FP
	K ERR
	S ROOT=$G(CONF("templates","root"))
	I ROOT="" S ROOT="templates/"
	I $E(ROOT,$L(ROOT))'="/" S ROOT=ROOT_"/"
	S EXT=$G(CONF("templates","ext"))
	S NM=NAME
	S NM=$TR(NM,"\","/")
	N R1,R2
	S R1=ROOT
	S R2="./"_ROOT
	I $E(NM,1,$L(R2))=R2 S NM=$E(NM,$L(R2)+1,$L(NM))
	E  I $E(NM,1,$L(R1))=R1 S NM=$E(NM,$L(R1)+1,$L(NM))
	I NM[".." S ERR("code")="TPL_TRAVERSAL",ERR("msg")="Path traversal '..' is not allowed." Q ""
	I NM[":" S ERR("code")="TPL_TRAVERSAL",ERR("msg")="Device/path ':' is not allowed." Q ""
	I $E(NM,1)="/" S ERR("code")="TPL_TRAVERSAL",ERR("msg")="Absolute paths are not allowed." Q ""
	I NM'["." S NM=NM_EXT
	S FP=ROOT_NM
	Q FP
READFILE(FP,TXT,ERR) ;
	N LINE,MAX
	K ERR
	S TXT=""
	N IO S IO=$PRINCIPAL
	S MAX=2*1024*1024
	O FP:(READONLY:EXCEPTION="G RFERR^MIOTPL2":CHSET="M"):2	
	F  U FP R *LINE Q:$ZEOF  D  Q:('$T!$D(ERR))
	. S TXT=TXT_$C(LINE)
	. I $L(TXT)>MAX S ERR("code")="TPL_TOOLARGE",ERR("msg")="Template too large (limit 2MB): "_FP
	I $D(ERR) C FP U IO Q 0
	C FP U IO
	I $E(TXT,$L(TXT))=$C(10) S TXT=$E(TXT,1,$L(TXT)-1)
	Q 1
RFERR
	C FP
	I $ZSTATUS["DEVOPENFAIL" D  Q 0
	. S ERR("code")="TPL_NOFILE",ERR("msg")="Template file not found: "_FP
	. S $ZSTATUS="",$EC=""
	I $zstatus["IOEOF" D  K ERR Q 1
	. I $E(TXT,$L(TXT))=$C(10) S TXT=$E(TXT,1,$L(TXT)-1)
	. S $ZSTATUS="",$EC=""
	S ERR("code")="TPL_IO",ERR("msg")="I/O error reading template: "_FP_" $zstatus:"_$zstatus
	Q 0
READFILE2REF(FP,ROOT,CONF,H,ERR) ;
	K ERR
	N IO,CHSZ,BUF,N,PREV,STRIP
	S IO=$PRINCIPAL
	S CHSZ=+$G(CONF("templates","fileChunk"))
	I CHSZ<1024 S CHSZ=32768
	S H=2166136261
	S N=0,PREV=""
	O FP:(READONLY:EXCEPTION="GOTO RF2ERR^MIOTPL2":CHSET="M"):2
	F  U FP R *BUF  D  Q:$ZEOF
	. I PREV'="",$L(PREV)>=CHSZ D
	. . S N=N+1
	. . S @($$APPREF^MIOTPL2(ROOT,N))=PREV
	. . S H=$$H32UPD^MIOTPL2(H,PREV)
	. . S PREV=""
	. E  S PREV=PREV_$C(BUF)
	C FP U IO
	I PREV'="" D
	. S N=N+1
	. S @($$APPREF^MIOTPL2(ROOT,N))=PREV
	. S H=$$H32UPD^MIOTPL2(H,PREV)
	Q
RF2ERR
	C FP
	I $ZSTATUS["DEVOPENFAIL" D  Q 0
	. S ERR("code")="TPL_NOFILE",ERR("msg")="Template file not found: "_FP
	. S $ZSTATUS="",$EC=""
	I $ZSTATUS["IOEOF" D  K ERR Q
	. I PREV'="" D
	. . S N=N+1
	. . S @($$APPREF^MIOTPL2(ROOT,N))=PREV
	. . S H=$$H32UPD^MIOTPL2(H,PREV)
	. . S $ZSTATUS="",$EC="",PREV=""
	S ERR("code")="TPL_IO",ERR("msg")="I/O error reading template: "_FP_" $zstatus:"_$ZSTATUS
	Q
H32UPD(H,TEXT)
	N I,C
	F I=1:1:$L(TEXT) D
	. S C=$A(TEXT,I)
	. S H=$$XOR32^MIOTPL2(H,C)
	. S H=$$MUL32^MIOTPL2(H,16777619)
	Q H
FILEEXISTS(FP) Q $ZSEARCH(FP)]""
	;
REFROOT(TREF,ROOT,ERR)
	K ERR
	N R S R=$$TRIM($G(TREF))
	I R="" S ERR("code")="TPL_REF",ERR("msg")="Empty template reference." Q
	I ($E(R)="$")!(R["(")!($E(R)="^") S ROOT=R Q
	I $D(@(R_"($J)")) S ROOT=R_"($J)" Q
	S ROOT=R
	Q
PARSEREF(ROOT,TOK,CRLF,ERR)
	K ERR K TOK
	N P,N,SUB,CH
	S CRLF=0
	S N=0
	K P
	S P("od")="{{",P("cd")="}}"
	S P("buf")=""
	S P("pendCR")=0
	S SUB=""
	F  S SUB=$O(@($$APPREF^MIOTPL2(ROOT,SUB))) Q:SUB=""  D  Q:$D(ERR)
	. S CH=$G(@($$APPREF^MIOTPL2(ROOT,SUB)))
	. D NORMNLCH(.CH,.P,.CRLF)
	. I CH'="" S P("buf")=$G(P("buf"))_CH
	. D PARSEBUF(.P,.TOK,.N,.ERR,0)
	I +$G(P("pendCR")) D
	. S P("pendCR")=0
	. S P("buf")=$G(P("buf"))_$C(10)
	D PARSEBUF(.P,.TOK,.N,.ERR,1)
	Q
NORMNLCH(CHUNK,P,CRLF)
	N S,OUT,I,PC
	S S=$G(CHUNK)
	I +$G(P("pendCR")) D
	. S P("pendCR")=0
	. I $E(S,1)=$C(10) S CRLF=1,S=$E(S,2,$L(S))
	. S S=$C(10)_S
	I $L(S)>0,$E(S,$L(S))=$C(13) S P("pendCR")=1,S=$E(S,1,$L(S)-1)
	I S[$C(13,10) S CRLF=1
	I S[$C(13,10) D
	. S PC=$L(S,$C(13,10))
	. I PC>1 D
	. . S OUT=$P(S,$C(13,10),1)
	. . F I=2:1:PC S OUT=OUT_$C(10)_$P(S,$C(13,10),I)
	. . S S=OUT
	I S[$C(13) S S=$TR(S,$C(13),$C(10))
	S CHUNK=S
	Q
	;
LINEPURE(TOK,I,MAX)
	N J,TYP,OK,FOUND
	S OK=1
	S FOUND=0
	F J=I-1:-1:1 Q:'OK  D  Q:FOUND
	. S TYP=$G(TOK(J,"t"))
	. I TYP'="text" S OK=0 Q
	. I $$HASNL($G(TOK(J,"v"))) S FOUND=1
	S FOUND=0
	F J=I+1:1:MAX Q:'OK  D  Q:FOUND
	. S TYP=$G(TOK(J,"t"))
	. I TYP'="text" S OK=0 Q
	. I $$HASNL($G(TOK(J,"v"))) S FOUND=1
	Q OK
PARSE(TEXT,TOK,ERR)
	K ERR K TOK
	N L,POS,OPEN,CLOSE,PRE,INSIDE,RAW,END3,TRI
	N N S N=0
	N OD,CD
	S OD="{{",CD="}}"
	S L=$L(TEXT),POS=1
	F  Q:POS>L  D  Q:$D(ERR)
	. S OPEN=$F(TEXT,OD,POS)
	. I 'OPEN D  Q
	. . S PRE=$E(TEXT,POS,L)
	. . I PRE'="" D ADDTXT(.TOK,.N,PRE)
	. . S POS=L+1
	. S PRE=$E(TEXT,POS,OPEN-$L(OD)-1)
	. I PRE'="" D ADDTXT(.TOK,.N,PRE)
	. S TRI=0
	. I (OD="{{")&(CD="}}") I $E(TEXT,OPEN)="{" S TRI=1
	. I TRI D  Q
	. . S END3=$F(TEXT,"}}}",OPEN)
	. . I 'END3 S ERR("code")="TPL_PARSE",ERR("msg")="Unclosed triple mustache." Q
	. . S RAW=$E(TEXT,OPEN+1,END3-4)
	. . S RAW=$$TRIM(RAW)
	. . D ADDVAR(.TOK,.N,RAW,0)
	. . S POS=END3
	. S CLOSE=$F(TEXT,CD,OPEN)
	. I 'CLOSE S ERR("code")="TPL_PARSE",ERR("msg")="Unclosed mustache tag." Q
	. S INSIDE=$E(TEXT,OPEN,CLOSE-$L(CD)-1)
	. S INSIDE=$$TRIM(INSIDE)
	. I $E(INSIDE,1)="=",$E(INSIDE,$L(INSIDE))="=" D  S POS=CLOSE Q
	. . N MID,W1,W2,REST
	. . S MID=$$TRIM($E(INSIDE,2,$L(INSIDE)-1))
	. . S REST=MID
	. . S W1=$$NEXTTOK(.REST),W2=$$NEXTTOK(.REST)
	. . I W1=""!(W2="") S ERR("code")="TPL_PARSE",ERR("msg")="Bad delimiter change tag." Q
	. . D ADDDELIM(.TOK,.N,W1,W2)
	. . S OD=W1,CD=W2
	. ; Comments
	. I $E(INSIDE,1)="!" D  S POS=CLOSE Q
	. . D ADDCOMM(.TOK,.N)
	. ; Unescaped via &
	. I $E(INSIDE,1)="&" D  S POS=CLOSE Q
	. . N K S K=$$TRIM($E(INSIDE,2,$L(INSIDE)))
	. . D ADDVAR(.TOK,.N,K,0)
	. ; Partials
	. I $E(INSIDE,1)=">" D  S POS=CLOSE Q
	. . N P S P=$$TRIM($E(INSIDE,2,$L(INSIDE)))
	. . D ADDPART(.TOK,.N,P)
	. ; Sections / inverted / end
	. I $E(INSIDE,1)="#"!($E(INSIDE,1)="^")!($E(INSIDE,1)="/") D  S POS=CLOSE Q
	. . N OP,K,INV
	. . S OP=$E(INSIDE,1)
	. . S K=$$TRIM($E(INSIDE,2,$L(INSIDE)))
	. . ; Handlebars-like helpers
	. . I OP="#" D
	. . . I $E(K,1,3)="if " S K=$$TRIM($E(K,4,$L(K)))
	. . . I $E(K,1,5)="each " S K=$$TRIM($E(K,6,$L(K)))
	. . . I $E(K,1,7)="unless " S OP="^",K=$$TRIM($E(K,8,$L(K)))
	. . I OP="/" D ADDSECE(.TOK,.N,K) Q
	. . S INV=$S(OP="^":1,1:0)
	. . D ADDSECS(.TOK,.N,K,INV)
	. . ; Block detection: key like "block:name"
	. . I $E(K,1,6)="block:" D
	. . . S TOK(N,"blk")=1
	. . . S TOK(N,"bname")=$E(K,7,$L(K))
	. ; Default: variable escaped
	. D ADDVAR(.TOK,.N,INSIDE,1)
	. S POS=CLOSE
	Q
NEXTTOK(REST)
	N S,L,I,C
	S S=$G(REST),L=$L(S),I=1
	F  Q:I>L  S C=$E(S,I) Q:(C'=" ")&(C'=$C(9))  S I=I+1
	I I>L S REST="" Q ""
	N J S J=I
	F  Q:J>L  S C=$E(S,J) Q:(C=" ")!(C=$C(9))  S J=J+1
	N OUT S OUT=$E(S,I,J-1)
	S REST=$$TRIM($E(S,J,L))
	Q OUT
ADDDELIM(TOK,N,OD,CD)
	S N=N+1
	S TOK(N,"t")="delim"
	S TOK(N,"od")=$G(OD)
	S TOK(N,"cd")=$G(CD)
	Q
NUMMAX(TOK)
	N I,MAX
	S MAX=0,I=0
	F  S I=$O(TOK(I)) Q:I=""  D
	. I I?1.N,I>MAX S MAX=I
	Q MAX
STANDTOK(TOK)
	N I,MAX,TYP
	N DO
	S MAX=$$NUMMAX(.TOK) Q:MAX<1
	F I=1:1:MAX D
	. S TYP=$G(TOK(I,"t"))
	. Q:(TYP'="secS")&(TYP'="secE")&(TYP'="part")&(TYP'="comm")&(TYP'="delim")
	. I $$ISSTAND(.TOK,I,MAX) S DO(I)=1
	F I=1:1:MAX I $G(DO(I)) D
	. D STANDAP(.TOK,I,MAX)
	Q
ISSTAND(TOK,I,MAX)
	N POK,NOK,PV,NV
	I '$$LINEPURE(.TOK,I,MAX) Q 0
	S POK=1
	I I>1 D
	. I $G(TOK(I-1,"t"))'="text" S POK=0 Q
	. S PV=$G(TOK(I-1,"v"))
	. I '$$TAILWS(PV) S POK=0
	Q:'POK 0
	S NOK=1
	I I<MAX D
	. I $G(TOK(I+1,"t"))'="text" S NOK=0 Q
	. S NV=$G(TOK(I+1,"v"))
	. I '$$HEADWNL(NV) S NOK=0
	Q:'NOK 0
	Q 1
STANDAP(TOK,I,MAX)
	N TYP,PV,P,IND
	S TYP=$G(TOK(I,"t"))
	I TYP="part" D
	. S IND=""
	. I I>1,$G(TOK(I-1,"t"))="text" D
	. . S PV=$G(TOK(I-1,"v"))
	. . S P=$$LASTNLSEQ(PV)
	. . I P>0 S IND=$E(PV,P+1,$L(PV))
	. . E  S IND=PV
	. I IND'="",$TR(IND," "_$C(9),"")'="" S IND=""
	. S TOK(I,"indent")=IND
	I I>1 S TOK(I-1,"v")=$$CUTPRE($G(TOK(I-1,"v")))
	I I<MAX S TOK(I+1,"v")=$$CUTNX($G(TOK(I+1,"v")))
	Q
INDENTSTR(S,IND)
	I $G(IND)="" Q $G(S)
	N I,L,CH,OUT
	S S=$G(S),OUT=IND,L=$L(S)
	F I=1:1:L D
	. S CH=$E(S,I),OUT=OUT_CH
	. I CH=$C(10),I<L S OUT=OUT_IND
	Q OUT
HEADWNL(S)
	N J,C,L
	S S=$G(S) I S="" Q 1
	S L=$L(S)
	F J=1:1:L S C=$E(S,J) Q:(C'=" ")&(C'=$C(9))
	I J>L Q 0
	Q $S($E(S,J)=$C(10):1,1:0)
ALLWS(S)
	N I,C,OK
	S OK=1,S=$G(S)
	F I=1:1:$L(S) D  Q:'OK
	. S C=$E(S,I)
	. I (C'=" ")&(C'=$C(9)) S OK=0
	Q OK
CUTNX(S)
	N J,C,L
	S S=$G(S) I S="" Q ""
	S L=$L(S)
	F J=1:1:L S C=$E(S,J) Q:(C'=" ")&(C'=$C(9))
	I J>L Q S
	I $E(S,J)=$C(10) Q $E(S,J+1,L)
	Q S
NORMNL(S)
	N I,L,CH,NXT,OUT
	S S=$G(S),OUT="",L=$L(S),I=1
	F  Q:I>L  D
	. S CH=$E(S,I)
	. I CH=$C(13) D  Q
	. . S NXT=$S(I<L:$E(S,I+1),1:"")
	. . I NXT=$C(10) S OUT=OUT_$C(10),I=I+2 Q
	. . S OUT=OUT_$C(10),I=I+1
	. S OUT=OUT_CH,I=I+1
	Q OUT
TAILWS(S)
	N P,TAIL
	S S=$G(S)
	S P=$$LASTNLSEQ(S)
	S TAIL=$S(P>0:$E(S,P+1,$L(S)),1:S)
	Q $$ALLWS(TAIL)
LASTNLSEQ(S)
	N I,L,P
	S S=$G(S),L=$L(S),P=0
	F I=1:1:L D
	. I $E(S,I)=$C(10) S P=I
	. I $E(S,I)=$C(13) D
	. . I (I<L),$E(S,I+1)=$C(10) S P=I+1
	. . E  S P=I
	Q P
HASNL(S)
	Q:($F($G(S),$C(10))>0) 1
	Q:($F($G(S),$C(13))>0) 1
	Q 0
CUTPRE(S)
	N P
	S S=$G(S)
	S P=$$LASTNLSEQ(S)
	Q $S(P>0:$E(S,1,P),1:"")
ADDTXT(TOK,N,VAL)
	S N=N+1
	S TOK(N,"t")="text"
	S TOK(N,"v")=VAL
	Q
ADDVAR(TOK,N,KEY,ESC)
	S N=N+1
	S TOK(N,"t")="var"
	S TOK(N,"k")=KEY
	S TOK(N,"e")=+$G(ESC)
	Q
ADDSECS(TOK,N,KEY,INV)
	S N=N+1
	S TOK(N,"t")="secS"
	S TOK(N,"k")=KEY
	S TOK(N,"inv")=+$G(INV)
	Q
ADDSECE(TOK,N,KEY)
	S N=N+1
	S TOK(N,"t")="secE"
	S TOK(N,"k")=KEY
	Q
ADDPART(TOK,N,NAME)
	S N=N+1
	S TOK(N,"t")="part"
	S TOK(N,"k")=NAME
	Q
LINKSECS(TOK,ERR)
	K ERR
	N STK,SP,I,T,K,TOP
	S SP=0
	S I=0
	F  S I=$O(TOK(I)) Q:'I  D  Q:$D(ERR)
	. S T=$G(TOK(I,"t"))
	. I T="secS" D  Q
	. . S SP=SP+1
	. . S STK(SP,"i")=I
	. . S STK(SP,"k")=$G(TOK(I,"k"))
	. I T="secE" D  Q
	. . S K=$G(TOK(I,"k"))
	. . I SP<1 S ERR("code")="TPL_PARSE",ERR("msg")="Section end without start: "_K Q
	. . S TOP=$G(STK(SP,"k"))
	. . I TOP'=K S ERR("code")="TPL_PARSE",ERR("msg")="Section mismatch: expected /"_TOP_" got /"_K Q
	. . N SI S SI=STK(SP,"i")
	. . S TOK(SI,"m")=I
	. . S SP=SP-1
	I SP>0 D
	. S ERR("code")="TPL_PARSE",ERR("msg")="Unclosed section: "_$G(STK(SP,"k"))
	Q
	;
OUTINIT(W,OREF,CONF,TOK)
	K W
	S W("root")=$G(OREF)
	S W("n")=0
	S W("buf")=""
	S W("chunk")=+$G(CONF("output","chunk")) I W("chunk")<256 S W("chunk")=8192
	S W("crlf")=+$G(TOK("meta","crlf"))
	Q
OUTAPP(W,VAL)
	N V,CHUNK,SPACE,PIECE
	S V=$G(VAL) Q:V=""
	S CHUNK=+$G(W("chunk")) I CHUNK<256 S CHUNK=8192
	F  Q:V=""  D
	. S SPACE=CHUNK-$L($G(W("buf")))
	. I SPACE<1 D OUTFLUSH^MIOTPL2(.W) S SPACE=CHUNK
	. S PIECE=$E(V,1,SPACE)
	. S W("buf")=$G(W("buf"))_PIECE
	. S V=$E(V,SPACE+1,$L(V))
	. I $L(W("buf"))'<CHUNK D OUTFLUSH^MIOTPL2(.W)
	Q
OUTFLUSH(W)
	N ROOT,BUF,N
	S BUF=$G(W("buf")) Q:BUF=""
	S ROOT=$G(W("root")) Q:ROOT=""
	S N=+$G(W("n"))+1
	S W("n")=N
	S @($$APPREF^MIOTPL2(ROOT,N))=BUF
	S W("buf")=""
	Q
ISREF(S)
	N R S R=$$TRIM^MIOTPL2($G(S))
	I R="" Q 0
	; global ref
	I $E(R)="^" Q 1
	; local/global with subscripts: NAME(...)
	I R?1(1A,1"%")1.AN1"("1.E Q 1
	; bare name: treat as ref only if NAME($J) has value/descendants
	I R?1(1A,1"%")1.AN,$D(@(R_"($J)")) Q 1
	Q 0
INDENTPTOK(TOK,IND)
	N TMP,MAX,I,NEWN,LS,AT,TYP,V,S
	S IND=$G(IND) Q:IND=""
	K TMP
	S S=""
	F  S S=$O(TOK(S)) Q:S=""  D
	. I S?1.N Q
	. M TMP(S)=TOK(S)
	S MAX=$$NUMMAX(.TOK)
	S NEWN=0
	S LS=1
	S AT=1
	F I=1:1:MAX D
	. S TYP=$G(TOK(I,"t"))
	. I LS,(TYP'="text") D
	. . S NEWN=NEWN+1
	. . S TMP(NEWN,"t")="text"
	. . S TMP(NEWN,"v")=IND
	. . S LS=0,AT=0
	. S NEWN=NEWN+1
	. M TMP(NEWN)=TOK(I)
	. I TYP="text" D
	. . S V=$G(TMP(NEWN,"v"))
	. . S AT=LS
	. . S TMP(NEWN,"v")=$$INDTXT(V,IND,.AT)
	. . I $L(V)>0,$E(V,$L(V))=$C(10) S LS=1 Q
	. . S LS=0
	. E  D
	. . S LS=0
	K TOK M TOK=TMP
	Q
ADDCOMM(TOK,N)
	S N=N+1
	S TOK(N,"t")="comm"
	Q
INDTXT(V,IND,AT)
	N OUT,L,I,CH
	S V=$G(V),OUT="",L=$L(V)
	I AT,L>0 S OUT=OUT_IND,AT=0
	F I=1:1:L D
	. S CH=$E(V,I)
	. S OUT=OUT_CH
	. I CH=$C(10) D
	. . I I<L S OUT=OUT_IND
	. . E  S AT=1
	Q OUT
TOKGET(TN,I,FIELD)
	N R
	I TN["(" D
	. S R=$E(TN,1,$L(TN)-1)_","_I_","""_FIELD_""")"
	E  D
	. S R=TN_"("_I_","""_FIELD_""")"
	Q $G(@R)
TOKENDR(TOKR)
	N I,MAX
	S MAX=0,I=0
	F  S I=$O(@TOKR@(I)) Q:I=""  D
	. I I?1.N,I>MAX S MAX=I
	Q MAX
REPL(s,f,t)
	i $tr(s,f)=s q s
	n o,i s o="" f i=1:1:$l(s,f)  s o=o_$s(i<$l(s,f):$p(s,f,i)_t,1:$p(s,f,i))
	q o
PUSHFRAME(FSP,F,START,END,CTSP,MODE,CAPREF,TOKNAME)
	S FSP=FSP+1
	S F(FSP,"i")=START
	S F(FSP,"end")=END
	S F(FSP,"ctxTop")=CTSP
	S F(FSP,"mode")=$G(MODE,"emit")
	S F(FSP,"capRef")=$G(CAPREF)
	S F(FSP,"tokName")=$G(TOKNAME,"TOK")
	Q
POPF(FSP,F,CST,CTSP)
	N OLD S OLD=FSP
	I +$G(F(OLD,"storeBlock")) D
	. N BN,CR,VAL
	. S BN=$G(F(OLD,"storeName"))
	. S CR=$G(F(OLD,"storeCapRef"))
	. S VAL=$G(@CR)
	. S CTX("blocks",BN)=VAL
	I $G(F(OLD,"pname"))'="" D
	. N PN S PN=$G(F(OLD,"pname"))
	. S PACTIVE(PN)=+$G(PACTIVE(PN))-1
	. I PACTIVE(PN)'>0 K PACTIVE(PN)
	I +$G(F(OLD,"capEmit")) D
	. N CR,VAL,IND,TXT,PMODE,PCR
	. S CR=$G(F(OLD,"capRef"))
	. S VAL=$S(CR'="":$G(@CR),1:"")
	. S IND=$G(F(OLD,"indent"))
	. S TXT=$$INDENTSTR^MIOTPL2(VAL,IND)
	. I CR'="" S @CR=""
	. K F(OLD,"capEmit"),F(OLD,"indent")
	. S PMODE=$G(F(OLD-1,"mode"))
	. I PMODE="capture" D
	. . S PCR=$G(F(OLD-1,"capRef")) Q:PCR=""
	. . S @PCR=$G(@PCR)_TXT
	. E  D EMIT^MIOTPL2(OLD-1,.F,.OUT,TXT)
	S FSP=FSP-1
	I FSP>0 S CTSP=+$G(F(FSP,"ctxTop"))
	Q
LF2CRLF(S)
	N LF,N,I,OUT
	S LF=$C(10)
	S N=$L($G(S),LF)
	I N<2 Q $G(S)
	S OUT=$P(S,LF,1)
	F I=2:1:N S OUT=OUT_$C(13,10)_$P(S,LF,I)
	Q OUT
TOKMAX(TOKNAME)
	Q $$TOKENDR(TOKNAME)
FIRSTSUB(REF)
	N CHREF
	S CHREF=$$APPREF^MIOTPL2(REF,"")
	Q $O(@CHREF)
EMIT(FSP,F,OUT,VAL)
	N MODE,V
	S MODE=$G(F(FSP,"mode"))
	I MODE="capture" D  Q
	. N CR S CR=$G(F(FSP,"capRef")) Q:CR=""
	. S @CR=$G(@CR)_$G(VAL)
	S V=$G(VAL)
	I $G(CRLF),V'="" D
	. I V[$C(13) S V=$$NORMNL^MIOTPL2(V)
	. I V[$C(10) S V=$$LF2CRLF^MIOTPL2(V)
	S OUT=$G(OUT)_V
	Q
TOKEND(TOKR)
	Q $$TOKENDR(TOKR)
TOKG(TOKR,I,FIELD)
	Q $G(@(TOKR_"("_I_","""_FIELD_""")"))
RESREF(KEY,CST,CTSP,ISSET,TYPE,REF)
	N K S K=KEY
	S ISSET=0,TYPE="missing",REF=""
	I K="" Q
	I K="." D  Q
	. N R S R=$G(CST(CTSP)) Q:R=""
	. I '$D(@R) S ISSET=0,TYPE="missing",REF="" Q
	. I $D(@R)>1 D  Q
	. . N S0 S S0=$$FIRSTSUB^MIOTPL2(R)
	. . I S0'="" S ISSET=1,TYPE="list",REF=R Q
	. . S ISSET=1,TYPE="obj",REF=R Q
	. I $D(@R)#2 S ISSET=1,TYPE="scalar",REF=R Q
	. S ISSET=0,TYPE="missing",REF="" Q
	I K["." D  Q
	. N PARTS,PC,I,P1,LEVEL,BASE,OK1,TT1,RR1,CUR,NEXT
	. D SPLIT^MIOTPL2(K,".",.PARTS,.PC)
	. I PC<2 Q  ; safety
	. S P1=$G(PARTS(1)) I P1="" Q
	. S OK1=0,TT1="missing",RR1=""
	. F LEVEL=CTSP:-1:1 Q:OK1  D
	. . S BASE=$G(CST(LEVEL)) Q:BASE=""
	. . D RESINBASE^MIOTPL2(BASE,P1,.OK1,.TT1,.RR1)
	. I 'OK1 S ISSET=0,TYPE="missing",REF="" Q
	. I TT1="scalar" S ISSET=0,TYPE="missing",REF="" Q
	. S CUR=RR1
	. F I=2:1:PC D  Q:'ISSET
	. . S P=$G(PARTS(I))
	. . I P="" S ISSET=0,TYPE="missing",REF="" Q
	. . S NEXT=$$APPREF^MIOTPL2(CUR,P)
	. . I '$D(@NEXT) S ISSET=0,TYPE="missing",REF="" Q
	. . S CUR=NEXT,ISSET=1
	. I 'ISSET Q
	. I $D(@CUR)>1 D  Q
	. . N S0 S S0=$$FIRSTSUB^MIOTPL2(CUR)
	. . I S0'="" S TYPE="list",REF=CUR,ISSET=1 Q
	. . S TYPE="obj",REF=CUR,ISSET=1 Q
	. I $D(@CUR)#2 S TYPE="scalar",REF=CUR,ISSET=1 Q
	. S ISSET=0,TYPE="missing",REF="" Q
	N LEVEL
	F LEVEL=CTSP:-1:1 D  Q:ISSET
	. N BASE S BASE=$G(CST(LEVEL)) Q:BASE=""
	. N OK,RR,TT
	. D RESINBASE^MIOTPL2(BASE,K,.OK,.TT,.RR)
	. I OK S ISSET=1,TYPE=TT,REF=RR
	Q
RESINBASE(BASE,KEY,OK,TYPE,REF)
	S OK=0,TYPE="missing",REF=""
	N CUR S CUR=BASE
	N PARTS,PC,I,P
	D SPLIT(KEY,".",.PARTS,.PC)
	I PC=0 Q
	F I=1:1:PC D  Q:'OK&(I>1)
	. S P=PARTS(I)
	. I P="." S OK=1 Q
	. N NEXT S NEXT=$$APPREF(CUR,P)
	. I '$D(@NEXT) S OK=0,TYPE="missing",REF="" Q
	. S CUR=NEXT,OK=1
	I 'OK Q
	I '$D(@CUR) Q
	I $D(@CUR)>1 D  Q
	. N S0 S S0=$$FIRSTSUB(CUR)
	. I S0=""  S OK=1,TYPE="obj",REF=CUR Q
	. I S0?1.N S OK=1,TYPE="list",REF=CUR Q
	. S OK=1,TYPE="obj",REF=CUR Q
	I $D(@CUR)#2 S OK=1,TYPE="scalar",REF=CUR Q
	S OK=0,TYPE="missing",REF=""
	Q
RESVAL(KEY,CST,CTSP)
	N ISSET,TYPE,REF,V,VL
	D RESREF(KEY,.CST,CTSP,.ISSET,.TYPE,.REF)
	I 'ISSET Q ""
	I $D(@REF)#2 D  Q V
	. S V=$G(@REF)
	. S VL=$ZCONVERT(V,"L")
	. I VL="null" S V=""
	Q ""
ISTRUTH(ISSET,TYPE,REF)
	I 'ISSET Q 0
	I TYPE="list"!(TYPE="obj") Q $S($$FIRSTSUB(REF)="":0,1:1)
	N V,VL
	S V=$G(@REF)
	I V="" Q 0
	S VL=$ZCONVERT(V,"L")
	I VL="null" Q 0
	I V=0 Q 0
	I V="0" Q 0
	I VL="false" Q 0
	I VL="true" Q 1
	Q 1
APPREF(REF,SUB)
	N R,Q,OUT
	S R=REF
	S Q=$$QSUB(SUB)
	I R["(" D  Q OUT
	. S OUT=$E(R,1,$L(R)-1)_","_Q_")"
	Q R_"("_Q_")"
QSUB(SUB)
	N S S S=$G(SUB)
	I S?1.N Q S
	S S=$$REPL(S,$C(34),$C(34,34))
	Q $C(34)_S_$C(34)
SPLIT(STR,DEL,ARR,COUNT)
	K ARR S COUNT=0
	N I,CH,BUF S BUF=""
	F I=1:1:$L(STR) D
	. S CH=$E(STR,I)
	. I CH=DEL D  Q
	. . S COUNT=COUNT+1,ARR(COUNT)=BUF,BUF=""
	. S BUF=BUF_CH
	S COUNT=COUNT+1,ARR(COUNT)=BUF
	Q
TRIM(S)
	N A,B
	S A=1,B=$L(S)
	F  Q:A>B  Q:$E(S,A)'=" "&($E(S,A)'=$C(9))  S A=A+1
	F  Q:B<A  Q:$E(S,B)'=" "&($E(S,B)'=$C(9))  S B=B-1
	Q $E(S,A,B)
ESCHTML(S)
	N X S X=$G(S)
	S X=$$REPL(X,"&","&amp;")
	S X=$$REPL(X,"<","&lt;")
	S X=$$REPL(X,">","&gt;")
	S X=$$REPL(X,$C(34),"&quot;")
	S X=$$REPL(X,"'","&#39;")
	Q X
H32(TEXT)
	N H,I,C
	S H=2166136261
	F I=1:1:$L(TEXT) D
	. S C=$A(TEXT,I)
	. S H=$$XOR32(H,C)
	. S H=$$MUL32(H,16777619)
	Q H
XOR32(A,B)
	N R,I,BA,BB,POW
	S R=0,POW=1
	F I=0:1:31 D
	. S BA=A#2,A=A\2
	. S BB=B#2,B=B\2
	. I (BA+BB)=1 S R=R+POW
	. S POW=POW*2
	Q R
MUL32(A,M)
	N R
	S R=0
	F  Q:M=0  D
	. I M#2 S R=$$ADD32(R,A)
	. S M=M\2
	. S A=$$ADD32(A,A)
	Q R
ADD32(A,B)
	N S
	S S=A+B
	I S'<4294967296 S S=S#4294967296
	Q S
JOIN(ARR,SEP) ;
	NEW S SET S=""
	NEW D SET D=$GET(SEP) IF D="" SET D=$C(10)
	NEW I SET I=0
	FOR  SET I=$ORDER(ARR(I)) QUIT:'I  DO
	. IF S'="" SET S=S_D
	. SET S=S_$GET(ARR(I))
	QUIT S
PUSHFRAMEI(FSP,F,START,END,CTSP,MODE,CAPREF,TOKNAME,PARENT)
	D PUSHFRAME^MIOTPL2(.FSP,.F,START,END,CTSP,.MODE,.CAPREF,.TOKNAME)
	S F(FSP,"indent")=$G(F(PARENT,"indent"))
	S F(FSP,"at")=+$G(F(PARENT,"at"))
	Q
OUTNORM(V,CRLF)
	N X S X=$G(V)
	I 'CRLF Q X
	I X[$C(13) S X=$$NORMNL^MIOTPL2(X)
	I X[$C(10) S X=$$LF2CRLF^MIOTPL2(X)
	Q X
EVALX(TOK,CONF,CTX,OUTMODE,OUT,OREF,ERR)
	K ERR
	N CST,CTSP
	S CTSP=1,CST(1)="CTX"
	N PDEPTHMAX S PDEPTHMAX=+$G(CONF("templates","maxPartialDepth")) I PDEPTHMAX<1 S PDEPTHMAX=20
	N PACTIVE,PTCACHE
	N BCAP
	N CRLF S CRLF=+$G(TOK("meta","crlf"))
	N W
	I $G(OUTMODE)="R" D  Q:$D(ERR)
	. I $G(OREF)="" S ERR("code")="TPL_OREF",ERR("msg")="Missing output reference." Q
	. K @OREF
	. D OUTINIT^MIOTPL2(.W,OREF,.CONF,.TOK)
	E  S OUTMODE="S",OUT=""
	N FSP,F
	S FSP=1
	S F(1,"i")=1
	S F(1,"end")=$$TOKENDR^MIOTPL2("TOK")
	S F(1,"ctxTop")=CTSP
	S F(1,"mode")="emit"
	S F(1,"capRef")=""
	S F(1,"tokName")="TOK"
	S F(1,"indent")=""
	S F(1,"at")=1
	N FRAMELIM,FRAMES
	S FRAMELIM=2000,FRAMES=0
	F  Q:FSP<1  D  Q:$D(ERR)
	. S FRAMES=FRAMES+1
	. I FRAMES>FRAMELIM S ERR("code")="TPL_LIMIT",ERR("msg")="Render exceeded safety frame limit." Q
	. I $G(F(FSP,"mode"))="iter" D  Q
	. . N PARENT,LREF,SUB,BS,BE,PMODE,PCAP
	. . S PARENT=FSP
	. . S LREF=$G(F(PARENT,"listRef"))
	. . S SUB=$G(F(PARENT,"sub"))
	. . S BS=+$G(F(PARENT,"bodyS"))
	. . S BE=+$G(F(PARENT,"bodyE"))
	. . S PMODE=$G(F(PARENT,"parentMode"))
	. . S PCAP=$G(F(PARENT,"parentCap"))
	. . S SUB=$O(@($$APPREF^MIOTPL2(LREF,SUB)))
	. . I SUB="" D POPX^MIOTPL2(OUTMODE,.FSP,.F,.CST,.CTSP,.OUT,.W,CRLF) Q
	. . S F(PARENT,"sub")=SUB
	. . N ITEMREF,NEWTOP
	. . S ITEMREF=$$APPREF^MIOTPL2(LREF,SUB)
	. . S NEWTOP=CTSP+1,CST(NEWTOP)=ITEMREF,CTSP=NEWTOP
	. . D PUSHFRAMEI^MIOTPL2(.FSP,.F,BS,BE,CTSP,PMODE,PCAP,$G(F(PARENT,"tokName")),PARENT)
	. N I,END,TN,TYP
	. S I=+$G(F(FSP,"i")),END=+$G(F(FSP,"end"))
	. I I<1!(I>END) D POPX^MIOTPL2(OUTMODE,.FSP,.F,.CST,.CTSP,.OUT,.W,CRLF) Q
	. S TN=$G(F(FSP,"tokName")) I TN="" S TN="TOK"
	. S TYP=$$TOKGET^MIOTPL2(TN,I,"t")
	. I TYP="text" D  Q
	. . N V,IND,AT
	. . S V=$$TOKGET^MIOTPL2(TN,I,"v")
	. . S IND=$G(F(FSP,"indent"))
	. . I IND'="" D
	. . . S AT=+$G(F(FSP,"at"))
	. . . S V=$$INDTXT^MIOTPL2(V,IND,.AT)
	. . . S F(FSP,"at")=AT
	. . E  D
	. . . I V'="" S F(FSP,"at")=$S($E(V,$L(V))=$C(10):1,1:0)
	. . D EMITX^MIOTPL2(OUTMODE,FSP,.F,.OUT,.W,V,CRLF)
	. . S F(FSP,"i")=I+1
	. ; VAR (escaped/unescaped)
	. I (TYP="var")!(TYP="unesc") D  Q
	. . N KEY,ESC,VAL,IND,AT
	. . S KEY=$$TOKGET^MIOTPL2(TN,I,"k")
	. . S ESC=+$$TOKGET^MIOTPL2(TN,I,"e")
	. . S VAL=$$RESVAL^MIOTPL2(KEY,.CST,CTSP)
	. . I ESC S VAL=$$ESCHTML^MIOTPL2(VAL)
	. . S IND=$G(F(FSP,"indent"))
	. . S AT=+$G(F(FSP,"at"))
	. . I AT,IND'="",VAL'="" D EMITX^MIOTPL2(OUTMODE,FSP,.F,.OUT,.W,IND,CRLF) S AT=0
	. . I VAL'="" S AT=0
	. . S F(FSP,"at")=AT
	. . D EMITX^MIOTPL2(OUTMODE,FSP,.F,.OUT,.W,VAL,CRLF)
	. . S F(FSP,"i")=I+1
	. ; COMMENT / DELIM
	. I (TYP="comm")!(TYP="delim") D  Q
	. . S F(FSP,"i")=I+1
	. ; PARTIAL
	. I TYP="part" D  Q
	. . N PARENT,PNAME,INDTOK,PTREF,PMAX,PMODE,PCAP
	. . S PARENT=FSP
	. . S PNAME=$$TOKGET^MIOTPL2(TN,I,"k")
	. . S INDTOK=$$TOKGET^MIOTPL2(TN,I,"indent")
	. . S F(PARENT,"i")=I+1
	. . ; recursion protection
	. . S PACTIVE(PNAME)=+$G(PACTIVE(PNAME))+1
	. . I PACTIVE(PNAME)>PDEPTHMAX S ERR("code")="TPL_PARTIAL_DEPTH",ERR("msg")="Partial recursion depth exceeded: "_PNAME Q
	. . ; per-render ref cache
	. . I '$D(PTCACHE(PNAME,"ref")) D
	. . . D GETTOKREF^MIOTPL2(PNAME,.CONF,.PTREF,.PMAX,.ERR)
	. . . I $D(ERR) D  Q
	. . . . I $G(ERR("code"))="TPL_NOFILE" K ERR S PTCACHE(PNAME,"ref")="",PTCACHE(PNAME,"max")=0 Q
	. . . . S PACTIVE(PNAME)=PACTIVE(PNAME)-1 I PACTIVE(PNAME)'>0 K PACTIVE(PNAME)
	. . . . Q
	. . . S PTCACHE(PNAME,"ref")=PTREF
	. . . S PTCACHE(PNAME,"max")=PMAX
	. . S PTREF=$G(PTCACHE(PNAME,"ref")),PMAX=+$G(PTCACHE(PNAME,"max"))
	. . I PTREF="" D  Q
	. . . S PACTIVE(PNAME)=PACTIVE(PNAME)-1 I PACTIVE(PNAME)'>0 K PACTIVE(PNAME)
	. . ; push partial frame inheriting indent/at
	. . S PMODE=$G(F(PARENT,"mode"))
	. . S PCAP=$G(F(PARENT,"capRef"))
	. . D PUSHFRAMEI^MIOTPL2(.FSP,.F,1,PMAX,CTSP,PMODE,PCAP,PTREF,PARENT)
	. . S F(FSP,"pname")=PNAME
	. . ; compose indent: inherited indent + call-site indent
	. . I INDTOK'="" S F(FSP,"indent")=$G(F(FSP,"indent"))_INDTOK
	. ; SECTION START
	. I TYP="secS" D  Q
	. . N PARENT,KEY,INV,MI,NEXT
	. . S PARENT=FSP
	. . S KEY=$$TOKGET^MIOTPL2(TN,I,"k")
	. . S INV=+$$TOKGET^MIOTPL2(TN,I,"inv")
	. . S MI=+$$TOKGET^MIOTPL2(TN,I,"m")
	. . I 'MI S ERR("code")="TPL_PARSE",ERR("msg")="Section start without match: "_KEY Q
	. . S NEXT=MI+1
	. . S F(PARENT,"i")=NEXT
	. . ; block capture
	. . I +$$TOKGET^MIOTPL2(TN,I,"blk") D  Q
	. . . N BNAME,NEWF,CAPREF
	. . . S BNAME=$$TOKGET^MIOTPL2(TN,I,"bname")
	. . . S NEWF=FSP+1
	. . . S BCAP(NEWF)=""
	. . . S CAPREF=$NA(BCAP(NEWF))
	. . . D PUSHFRAMEI^MIOTPL2(.FSP,.F,I+1,MI-1,CTSP,"capture",CAPREF,TN,PARENT)
	. . . S F(FSP,"storeBlock")=1
	. . . S F(FSP,"storeName")=BNAME
	. . . S F(FSP,"storeCapRef")=CAPREF
	. . ; resolve key
	. . N ISSET,TYPE,REF
	. . D RESREF^MIOTPL2(KEY,.CST,CTSP,.ISSET,.TYPE,.REF)
	. . I TYPE="list" D
	. . . N S0 S S0=$$FIRSTSUB^MIOTPL2(REF)
	. . . I S0'="",S0'?1.N S TYPE="obj"
	. . ; inverted
	. . I INV D  Q
	. . . I $$ISTRUTH^MIOTPL2(.ISSET,.TYPE,.REF)=0 D
	. . . . D PUSHFRAMEI^MIOTPL2(.FSP,.F,I+1,MI-1,CTSP,$G(F(PARENT,"mode")),$G(F(PARENT,"capRef")),TN,PARENT)
	. . I $$ISTRUTH^MIOTPL2(.ISSET,.TYPE,.REF)=0 Q
	. . ; list iteration
	. . I TYPE="list" D  Q
	. . . S FSP=FSP+1
	. . . S F(FSP,"mode")="iter"
	. . . S F(FSP,"i")=0,F(FSP,"end")=0
	. . . S F(FSP,"ctxTop")=CTSP
	. . . S F(FSP,"listRef")=REF
	. . . S F(FSP,"sub")=""
	. . . S F(FSP,"bodyS")=I+1
	. . . S F(FSP,"bodyE")=MI-1
	. . . S F(FSP,"parentMode")=$G(F(PARENT,"mode"))
	. . . S F(FSP,"parentCap")=$G(F(PARENT,"capRef"))
	. . . S F(FSP,"tokName")=TN
	. . . S F(FSP,"indent")=$G(F(PARENT,"indent"))
	. . . S F(FSP,"at")=+$G(F(PARENT,"at"))
	. . ; object/scalar context
	. . I (TYPE="obj")!(TYPE="scalar") D  Q
	. . . N NEWTOP S NEWTOP=CTSP+1
	. . . S CST(NEWTOP)=REF,CTSP=NEWTOP
	. . . D PUSHFRAMEI^MIOTPL2(.FSP,.F,I+1,MI-1,CTSP,$G(F(PARENT,"mode")),$G(F(PARENT,"capRef")),TN,PARENT)
	. . ; fallback
	. . D PUSHFRAMEI^MIOTPL2(.FSP,.F,I+1,MI-1,CTSP,$G(F(PARENT,"mode")),$G(F(PARENT,"capRef")),TN,PARENT)
	. ; SECTION END
	. I TYP="secE" D  Q
	. . S F(FSP,"i")=I+1
	. ; unknown token: skip
	. S F(FSP,"i")=I+1
	; final flush (writer mode)
	I $G(OUTMODE)="R" D OUTFLUSH^MIOTPL2(.W)
	Q:$Q $S($D(ERR):0,1:1)
	Q
EMITX(OUTMODE,FSP,F,OUT,W,VAL,CRLF)
	N MODE,V,CR
	S MODE=$G(F(FSP,"mode"))
	I MODE="capture" D  Q
	. S CR=$G(F(FSP,"capRef")) Q:CR=""
	. S @CR=$G(@CR)_$G(VAL)
	S V=$$OUTNORM^MIOTPL2($G(VAL),+$G(CRLF))
	Q:V=""
	I $G(OUTMODE)="R" D OUTAPP^MIOTPL2(.W,V) Q
	S OUT=$G(OUT)_V
	Q	
POPX(OUTMODE,FSP,F,CST,CTSP,OUT,W,CRLF)
	N OLD,CM,PM
	S OLD=FSP
	S CM=$G(F(OLD,"mode"))
	S PM=$S(OLD>1:$G(F(OLD-1,"mode")),1:"")
	I +$G(F(OLD,"storeBlock")) D
	. N BN,CR,VAL
	. S BN=$G(F(OLD,"storeName"))
	. S CR=$G(F(OLD,"storeCapRef"))
	. S VAL=$S(CR'="":$G(@CR),1:"")
	. S CTX("blocks",BN)=VAL
	I $G(F(OLD,"pname"))'="" D
	. N PN S PN=$G(F(OLD,"pname"))
	. S PACTIVE(PN)=+$G(PACTIVE(PN))-1
	. I PACTIVE(PN)'>0 K PACTIVE(PN)
	I +$G(F(OLD,"capEmit")) D
	. N CR,VAL,IND,TXT
	. S CR=$G(F(OLD,"capRef"))
	. S VAL=$S(CR'="":$G(@CR),1:"")
	. S IND=$G(F(OLD,"indent"))
	. S TXT=$$INDENTSTR^MIOTPL2(VAL,IND)
	. I CR'="" S @CR=""
	. K F(OLD,"capEmit"),F(OLD,"indent")
	. I OLD>1 D EMITX^MIOTPL2(OUTMODE,OLD-1,.F,.OUT,.W,TXT,CRLF)
	I OLD>1 D
	. I '(CM="capture"&(PM'="capture")) S F(OLD-1,"at")=+$G(F(OLD,"at"))
	S FSP=FSP-1
	I FSP>0 S CTSP=+$G(F(FSP,"ctxTop"))
	Q
	;