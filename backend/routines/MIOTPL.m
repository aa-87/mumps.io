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
	Q
START(CONF)
	I '$D(CONF("templates","streamFiles")) S CONF("templates","streamFiles")=0
	I '$D(CONF("templates","streamFallback")) S CONF("templates","streamFallback")=1
	I '$D(CONF("templates","fileChunk")) S CONF("templates","fileChunk")=32768
	; ROI: auto output (opt-in)
	I '$D(CONF("output","auto")) S CONF("output","auto")=0
	I '$D(CONF("output","maxString")) S CONF("output","maxString")=900000  ; safe default
	I '$D(CONF("output","autoReturnRef")) S CONF("output","autoReturnRef")=0
	; compat defaults
	I '$D(CONF("compat","truthiness")) S CONF("compat","truthiness")="legacy"
	NEW EN
	SET EN=$S($GET(CONF("templates","precompileEnabled"))="true":1,1:+$GET(CONF("templates","precompileEnabled")))
	IF EN DO PRECOMPILE(.CONF)
	QUIT
; ============================
; Release: version info
; ============================
	;
VERSION() ; semantic version string
	Q "2.0.0"
	;
BUILD() ; build stamp (you can update per release)
	Q "2026-02-21"
	;
BANNER() ; one-line banner
	Q "MIOTPL2 "_$$VERSION()_" ("_$$BUILD()_")"
	;
PRINTBANNER() ; convenience
	W $$BANNER(),!
	Q
PRECOMPILE(CONF) ;
	NEW ROOT SET ROOT=$GET(CONF("server","templateDir")) IF ROOT="" SET ROOT="templates"
	NEW LIST KILL LIST
	NEW I,PATH
	SET I=0
	FOR  SET I=$ORDER(CONF("templates","precompile","path",I)) QUIT:'I  DO
	. SET PATH=$GET(CONF("templates","precompile","path",I))
	. IF PATH'="" SET LIST(PATH)=1
	IF '$DATA(LIST) DO ENUMGLOBS(ROOT,.LIST)
	NEW FP,DUM,ERR
	SET FP=""
	FOR  SET FP=$ORDER(LIST(FP)) QUIT:FP=""  DO
	. DO GETTOKFP(FP,.CONF,.DUM,.ERR,"REF")
	QUIT
GETTOKFP(FP,CONF,TOK,ERR,OPT) ;
	K ERR K TOK
	IF $GET(OPT)="REF" QUIT
	M TOK=^MIO("TPL","CACHE",FP,"TOK")
	Q
PROCESSFILE(FP)
	I '$D(CONF) M CONF=^MIO("CONF")
	NEW CH,OK,TXT,STREAM,FB,H,CRLF,NTXT,TOKR,MREF,PM
	S STREAM=$$BOOL($G(CONF("templates","streamFiles")))
	S FB=$$BOOL($G(CONF("templates","streamFallback")))
	I 'STREAM,'FB S FB=1
	IF STREAM DO GETTOKFPSTR(FP,.CONF,.TOK,.ERR,$G(OPT)) QUIT
	SET CH=$GET(^MIO("TPL","CACHE",FP,"H"))
	SET CRLF=0
	SET OK=$$READFILE(FP,.TXT,.ERR,.CRLF)
	IF 'OK DO  QUIT
	. IF $GET(ERR("code"))="TPL_TOOLARGE",FB DO  QUIT
	. . DO GETTOKFPSTR(FP,.CONF,.TOK,.ERR,$G(OPT))
	. QUIT
	SET H=$$H32(TXT)
	SET NTXT=$$NORMNL(TXT)
	SET TOKR=$NA(^MIO("TPL","CACHE",FP,"TOK"))
	SET MREF=$$APPREF(TOKR,"meta")
	IF CH'="",CH=H,$DATA(^MIO("TPL","CACHE",FP,"TOK",1)) DO  QUIT
	. SET ^MIO("TPL","CACHE",FP,"ts")=$H
	. IF '$DATA(@($$APPREF(MREF,"crlf"))) SET @($$APPREF(MREF,"crlf"))=+CRLF
	. SET PM=+$GET(@($$APPREF(MREF,"pmax")))
	. IF 'PM SET PM=$$TOKENDR(TOKR),@($$APPREF(MREF,"pmax"))=PM
	. IF $GET(OPT)'="REF" MERGE TOK=^MIO("TPL","CACHE",FP,"TOK")
	. IF '$DATA(@($$APPREF(MREF,"simple"))) DO ANALYZERREF(TOKR,MREF)
	. QUIT
	NEW TMP KILL TMP
	DO PARSE(NTXT,.TMP,.ERR) QUIT:$D(ERR)
	DO DOLLARBLK(.TMP) 
	DO LINKSECS(.TMP,.ERR) QUIT:$D(ERR)
	DO STANDTOK(.TMP)
	SET TMP("meta","crlf")=+CRLF
	SET TMP("meta","pmax")=$$NUMMAX(.TMP)
	KILL ^MIO("TPL","CACHE",FP)
	SET ^MIO("TPL","CACHE",FP,"ts")=$H
	SET ^MIO("TPL","CACHE",FP,"H")=H
	MERGE ^MIO("TPL","CACHE",FP,"TOK")=TMP
	;IF $GET(OPT)="REF" KILL TOK QUIT
	;MERGE TOK=TMP
	QUIT
RENDER(NAME,CONF,CTX,OUT,ERR)
	K ERR S OUT=""
	N TOKREF,PMAX,TOK
	D GETTOKREF(NAME,.CONF,.TOKREF,.PMAX,.ERR) Q:$D(ERR)
	; Token-handle (small locals only)
	S TOK("ref")=TOKREF
	S TOK("pmax")=PMAX
	D EVAL(.TOK,.CONF,.CTX,.OUT,.ERR)
	Q
RENDERPAGE(PAGE,LAYOUT,CONF,CTX,OUT,ERR)
	K ERR S OUT=""
	N PAGEOUT,OK,OLD
	K CTX("blocks")
	S CTX("content")=""
	S OLD=$G(CTX("meta","captureBlocks"))
	S CTX("meta","captureBlocks")=1
	D RENDER(PAGE,.CONF,.CTX,.PAGEOUT,.ERR)
	S CTX("meta","captureBlocks")=0
	Q:$D(ERR)
	S CTX("content")=PAGEOUT
	D RENDERLAYOUT(LAYOUT,.CONF,.CTX,.OUT,.ERR)
	I OLD'="" S CTX("meta","captureBlocks")=OLD
	E  K CTX("meta","captureBlocks")
	Q:$Q $S($D(ERR):0,1:1)
	Q
RENDERLAYOUT(LAYOUT,CONF,CTX,OUT,ERR)
	K ERR S OUT=""
	D RENDER(LAYOUT,.CONF,.CTX,.OUT,.ERR)
	Q
EVAL(TOK,CONF,CTX,OUT,ERR)
	K ERR
	D EVALX(.TOK,.CONF,.CTX,"S",.OUT,"",.ERR)
	Q
EVALREF(TOK,CONF,CTX,OREF,ERR)
	N DUM
	K ERR
	D EVALX(.TOK,.CONF,.CTX,"R",.DUM,$G(OREF),.ERR)
	Q
RENDERANY(IN,CONF,CTX,OUT,ERR)
	K ERR
	N TOK
	I $$ISREF($G(IN)) D  Q
	. D COMPREF($G(IN),.TOK,.ERR) Q:$D(ERR)
	. D EVAL(.TOK,.CONF,.CTX,.OUT,.ERR)
	D COMPILE($G(IN),.TOK,.ERR) Q:$D(ERR)
	D EVAL(.TOK,.CONF,.CTX,.OUT,.ERR)
	Q
RENDERREF(IN,CONF,CTX,OREF,ERR)
	K ERR
	N TOK
	S CONF("templates","streamFiles")=1
	I $$ISREF($G(IN)) D  Q
	. D COMPREF($G(IN),.TOK,.ERR) Q:$D(ERR)
	. D EVALREF(.TOK,.CONF,.CTX,$G(OREF),.ERR)
	D COMPILE($G(IN),.TOK,.ERR) Q:$D(ERR)
	D EVALREF(.TOK,.CONF,.CTX,$G(OREF),.ERR)
	Q
COMPILE(TEXT,TOK,ERR) ;
	N CRLF
	S CRLF=$S($F($G(TEXT),$C(13,10))>0:1,1:0)
	S TEXT=$$NORMNL(TEXT)
	D PARSE(.TEXT,.TOK,.ERR)
	I $D(ERR) Q
	D DOLLARBLK(.TOK)  
	D TOKPOS(.TOK)
	S TOK("meta","crlf")=CRLF
	D LINKSECS(.TOK,.ERR)
	I $D(ERR) Q
	D STANDTOK(.TOK)
	S TOK("meta","pmax")=$$NUMMAX(.TOK)
	D ANALYZE(.TOK)
	Q
COMPREF(TREF,TOK,ERR)
	N ROOT,CRLF
	D REFROOT(TREF,.ROOT,.ERR) I $D(ERR) Q
	D PARSEREF(ROOT,.TOK,.CRLF,.ERR) I $D(ERR) Q
	S TOK("meta","crlf")=CRLF
	D DOLLARBLK(.TOK)
	D LINKSECS(.TOK,.ERR) I $D(ERR) Q
	D STANDTOK(.TOK)
	S TOK("meta","pmax")=$$NUMMAX(.TOK)
	D ANALYZE(.TOK)
	Q
COMPILEA(ARR,TOK,ERR)  
	N ROOT,CRLF
	S ROOT=$NA(ARR)
	D PARSEREF(ROOT,.TOK,.CRLF,.ERR) I $D(ERR) Q
	S TOK("meta","crlf")=CRLF
	D LINKSECS(.TOK,.ERR) I $D(ERR) Q
	D DOLLARBLK(.TOK) 
	D STANDTOK(.TOK)
	S TOK("meta","pmax")=$$NUMMAX(.TOK)
	D ANALYZE(.TOK)
	Q
PARSEBUF(P,TOK,N,ERR,FINAL)
	N BUF,OD,CD,POS,L,OPEN,PRE,TRI,END3,CLOSE,INSIDE,RAW
	N DONE,TAIL,SAFE,TXT,RAWTAG
	S BUF=$G(P("buf")),OD=$G(P("od")),CD=$G(P("cd"))
	S POS=1,DONE=0
	F  Q:DONE  D  Q:$D(ERR)
	. S L=$L(BUF)
	. I POS>L S BUF="",DONE=1 Q
	. S OPEN=$F(BUF,OD,POS)
	. I 'OPEN D  Q
	. . I FINAL D
	. . . S PRE=$E(BUF,POS,L) I PRE'="" D ADDTXT(.TOK,.N,PRE,PRE)
	. . . S BUF="",DONE=1 Q
	. . S TAIL=$L(OD)-1 I TAIL<0 S TAIL=0
	. . I TAIL=0 D  S BUF="",DONE=1 Q
	. . . S TXT=$E(BUF,POS,L) I TXT'="" D ADDTXT(.TOK,.N,TXT,TXT)
	. . S SAFE=L-TAIL
	. . I SAFE<POS S BUF=$E(BUF,POS,L),DONE=1 Q
	. . S TXT=$E(BUF,POS,SAFE) I TXT'="" D ADDTXT(.TOK,.N,TXT,TXT)
	. . S BUF=$E(BUF,SAFE+1,L)
	. . S DONE=1 Q
	. S PRE=$E(BUF,POS,OPEN-$L(OD)-1)
	. I PRE'="" D ADDTXT(.TOK,.N,PRE,PRE)
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
	. . S RAWTAG=$E(BUF,OPEN-$L(OD),END3-1)
	. . D ADDVAR(.TOK,.N,RAW,0,RAWTAG)
	. . S POS=END3
	. S CLOSE=$F(BUF,CD,OPEN)
	. I 'CLOSE D  Q
	. . I FINAL S ERR("code")="TPL_PARSE",ERR("msg")="Unclosed mustache tag." Q
	. . S BUF=$E(BUF,OPEN-$L(OD),L),POS=1,DONE=1
	. S INSIDE=$$TRIM($E(BUF,OPEN,CLOSE-$L(CD)-1))
	. S RAWTAG=$E(BUF,OPEN-$L(OD),CLOSE-1)
	. ; delimiter change
	. I $E(INSIDE,1)="=",$E(INSIDE,$L(INSIDE))="=" D  S POS=CLOSE Q
	. . N MID,REST,W1,W2
	. . S MID=$$TRIM($E(INSIDE,2,$L(INSIDE)-1))
	. . S REST=MID
	. . S W1=$$NEXTTOK(.REST),W2=$$NEXTTOK(.REST)
	. . I W1=""!(W2="") S ERR("code")="TPL_PARSE",ERR("msg")="Bad delimiter change tag." Q
	. . D ADDDELIM(.TOK,.N,W1,W2,RAWTAG)
	. . S OD=W1,CD=W2
	. . S P("od")=OD,P("cd")=CD
	. ; comment
	. I $E(INSIDE,1)="!" D ADDCOMM(.TOK,.N,RAWTAG) S POS=CLOSE Q
	. ; unescaped via &
	. I $E(INSIDE,1)="&" D  S POS=CLOSE Q
	. . N K S K=$$TRIM($E(INSIDE,2,$L(INSIDE)))
	. . D ADDVAR(.TOK,.N,K,0,RAWTAG)
	. ; partials
	. I $E(INSIDE,1)=">" D  S POS=CLOSE Q
	. . N PNM S PNM=$$PNORM($E(INSIDE,2,$L(INSIDE))) I PNM'="" D ADDPART(.TOK,.N,PNM,RAWTAG)
	. ; parents (Mustache inheritance extension)
	. I $E(INSIDE,1)="<" D  S POS=CLOSE Q
	. . N PNM S PNM=$$PNORM($E(INSIDE,2,$L(INSIDE))) I PNM'="" D ADDPARS(.TOK,.N,PNM,RAWTAG)
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
	. . I OP="/" D ADDSECE(.TOK,.N,K,RAWTAG) Q
	. . S INV=$S(OP="^":1,1:0)
	. . D ADDSECS(.TOK,.N,K,INV,RAWTAG)
	. . I $E(K,1,6)="block:" S TOK(N,"blk")=1,TOK(N,"bname")=$E(K,7,$L(K))
	. ; default escaped var
	. D ADDVAR(.TOK,.N,INSIDE,1,RAWTAG)
	. S POS=CLOSE
	S P("buf")=BUF
	Q
ENUMGLOBS(ROOT,LIST) ;
	DO ENUM1(ROOT,"/*.html",.LIST)
	DO ENUM1(ROOT,"/pages/*.html",.LIST)
	DO ENUM1(ROOT,"/layouts/*.html",.LIST)
	DO ENUM1(ROOT,"/partials/*.html",.LIST)
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
	NEW FP,DUM,MREF,PM
	K ERR S TOKREF="",PMAX=0
	S FP=$$NAME2FP(NAME,.CONF,.ERR) Q:$D(ERR)
	D GETTOKFP(FP,.CONF,.DUM,.ERR,"REF") Q:$D(ERR)
	S TOKREF=$NA(^MIO("TPL","CACHE",FP,"TOK"))
	S MREF=$$APPREF(TOKREF,"meta")
	S PM=+$G(@($$APPREF(MREF,"pmax")))
	I 'PM D
	. S PM=$$TOKENDR(TOKREF)
	. S @($$APPREF(MREF,"pmax"))=PM
	S PMAX=PM
	Q
BOOL(X)
	N L S L=$ZCONVERT($G(X),"L")
	Q $S(X=1:1,X="1":1,L="true":1,L="yes":1,1:0)
GETTOKFPSTR(FP,CONF,TOK,ERR,OPT) ;
	K ERR K TOK
	I $$FILEEXISTS(FP)="" S ERR("code")="TPL_NOFILE",ERR("msg")="Template file not found: "_FP Q
	NEW CH,H,ROOT,CRLFDET,TOKR,MREF,PM
	SET ROOT=$NA(TMPBUF("FILE"))
	SET CH=$G(^MIO("TPL","CACHE",FP,"H"))
	NEW TMPBUF KILL @ROOT
	DO READFILE2REF(FP,ROOT,.CONF,.H,.ERR,.CRLFDET) I $D(ERR) KILL @ROOT QUIT
	IF CH'="",CH=H,$DATA(^MIO("TPL","CACHE",FP,"TOK",1)) DO  KILL @ROOT QUIT
	. SET ^MIO("TPL","CACHE",FP,"ts")=$H
	. SET TOKR=$NA(^MIO("TPL","CACHE",FP,"TOK"))
	. SET MREF=$$APPREF(TOKR,"meta")
	. IF '$DATA(@($$APPREF(MREF,"crlf"))) SET @($$APPREF(MREF,"crlf"))=+CRLFDET
	. SET PM=+$GET(@($$APPREF(MREF,"pmax")))
	. IF 'PM SET PM=$$TOKENDR(TOKR),@($$APPREF(MREF,"pmax"))=PM
	. IF $GET(OPT)'="REF" MERGE TOK=^MIO("TPL","CACHE",FP,"TOK")
	. QUIT
	NEW TMP KILL TMP
	DO COMPREF(ROOT,.TMP,.ERR)
	KILL @ROOT
	QUIT:$D(ERR)
	IF '$DATA(TMP("meta","crlf")) SET TMP("meta","crlf")=+CRLFDET
	IF '$DATA(TMP("meta","pmax")) SET TMP("meta","pmax")=$$NUMMAX(.TMP)
	KILL ^MIO("TPL","CACHE",FP)
	SET ^MIO("TPL","CACHE",FP,"ts")=$H
	SET ^MIO("TPL","CACHE",FP,"H")=H
	MERGE ^MIO("TPL","CACHE",FP,"TOK")=TMP
	IF $GET(OPT)="REF" KILL TOK QUIT
	MERGE TOK=TMP
	QUIT
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
READFILE(FP,TXT,ERR,CRLF) ;
	N LINE,MAX,PREV
	K ERR
	S TXT=""
	S CRLF=0
	N IO S IO=$PRINCIPAL
	S MAX=2*1024*1024
	S PREV=-1
	O FP:(READONLY:EXCEPTION="G RFERR^MIOTPL2":CHSET="M"):2
	F  U FP R *LINE Q:$ZEOF  D  Q:('$T!$D(ERR))
	. I PREV=13,LINE=10 S CRLF=1
	. S PREV=LINE
	. S TXT=TXT_$C(LINE)
	. I $L(TXT)>MAX S ERR("code")="TPL_TOOLARGE",ERR("msg")="Template too large (limit 2MB): "_FP
	I $D(ERR) C FP U IO Q 0
	C FP U IO
	I $L(TXT)>0 D
	. I $E(TXT,$L(TXT))=$C(10) D
	. . I $L(TXT)>1,$E(TXT,$L(TXT)-1)=$C(13) S TXT=$E(TXT,1,$L(TXT)-2) Q
	. . S TXT=$E(TXT,1,$L(TXT)-1)
	. E  I $E(TXT,$L(TXT))=$C(13) S TXT=$E(TXT,1,$L(TXT)-1)
	Q 1
RFERR
	C FP
	I $ZSTATUS["DEVOPENFAIL" D  Q 0
	. S ERR("code")="TPL_NOFILE",ERR("msg")="Template file not found: "_FP
	. S $ZSTATUS="",$EC=""
	I $ZSTATUS["IOEOF" D  K ERR Q 1
	. I $L(TXT)>0 D
	. . I $E(TXT,$L(TXT))=$C(10) D
	. . . I $L(TXT)>1,$E(TXT,$L(TXT)-1)=$C(13) S TXT=$E(TXT,1,$L(TXT)-2) Q
	. . . S TXT=$E(TXT,1,$L(TXT)-1)
	. . E  I $E(TXT,$L(TXT))=$C(13) S TXT=$E(TXT,1,$L(TXT)-1)
	. S $ZSTATUS="",$EC=""
	S ERR("code")="TPL_IO",ERR("msg")="I/O error reading template: "_FP_" $zstatus:"_$zstatus
	Q 0
READFILE2REF(FP,ROOT,CONF,H,ERR,CRLF) ;
	K ERR
	N IO,CHSZ,BUF,N,PREV,LASTC
	S IO=$PRINCIPAL
	S CHSZ=+$G(CONF("templates","fileChunk"))
	I CHSZ<1024 S CHSZ=32768
	S H=2166136261
	S N=0,PREV=""
	S CRLF=0
	S LASTC=-1
	O FP:(READONLY:EXCEPTION="GOTO RF2ERR^MIOTPL2":CHSET="M"):2
	F  U FP R *BUF  D  Q:$ZEOF
	. I LASTC=13,BUF=10 S CRLF=1
	. S LASTC=BUF
	. I PREV'="",$L(PREV)>=CHSZ D
	. . S N=N+1
	. . S @($$APPREF(ROOT,N))=PREV
	. . S H=$$H32UPD(H,PREV)
	. . S PREV=""
	. E  S PREV=PREV_$C(BUF)
	C FP U IO
	I PREV'="" D
	. S N=N+1
	. S @($$APPREF(ROOT,N))=PREV
	. S H=$$H32UPD(H,PREV)
	Q
RF2ERR
	C FP
	I $ZSTATUS["DEVOPENFAIL" D  Q 0
	. S ERR("code")="TPL_NOFILE",ERR("msg")="Template file not found: "_FP
	. S $ZSTATUS="",$EC=""
	I $ZSTATUS["IOEOF" D  K ERR Q
	. I PREV'="" D
	. . S N=N+1
	. . S @($$APPREF(ROOT,N))=PREV
	. . S H=$$H32UPD(H,PREV)
	. . S $ZSTATUS="",$EC="",PREV=""
	S ERR("code")="TPL_IO",ERR("msg")="I/O error reading template: "_FP_" $ZSTATUS:"_$ZSTATUS
	Q
H32UPD(H,TEXT)
	N I,C
	F I=1:1:$L(TEXT) D
	. S C=$A(TEXT,I)
	. S H=$$XOR32(H,C)
	. S H=$$MUL32(H,16777619)
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
	F  S SUB=$O(@($$APPREF(ROOT,SUB))) Q:SUB=""  D  Q:$D(ERR)
	. S CH=$G(@($$APPREF(ROOT,SUB)))
	. D NORMNLCH(.CH,.P,.CRLF)
	. I CH'="" S P("buf")=$G(P("buf"))_CH
	. D PARSEBUF(.P,.TOK,.N,.ERR,0)
	I +$G(P("pendCR")) D
	. S P("pendCR")=0
	. S P("buf")=$G(P("buf"))_$C(10)
	D PARSEBUF(.P,.TOK,.N,.ERR,1)
	D TOKPOS(.TOK)
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
	N N,OD,CD,RAWTAG
	S N=0
	S OD="{{",CD="}}"
	S L=$L(TEXT),POS=1
	F  Q:POS>L  D  Q:$D(ERR)
	. S OPEN=$F(TEXT,OD,POS)
	. I 'OPEN D  Q
	. . S PRE=$E(TEXT,POS,L)
	. . I PRE'="" D ADDTXT(.TOK,.N,PRE,PRE)
	. . S POS=L+1
	. S PRE=$E(TEXT,POS,OPEN-$L(OD)-1)
	. I PRE'="" D ADDTXT(.TOK,.N,PRE,PRE)
	. S TRI=0
	. I (OD="{{")&(CD="}}") I $E(TEXT,OPEN)="{" S TRI=1
	. I TRI D  Q
	. . S END3=$F(TEXT,"}}}",OPEN)
	. . I 'END3 S ERR("code")="TPL_PARSE",ERR("msg")="Unclosed triple mustache." Q
	. . S RAW=$$TRIM($E(TEXT,OPEN+1,END3-4))
	. . S RAWTAG=$E(TEXT,OPEN-$L(OD),END3-1)
	. . D ADDVAR(.TOK,.N,RAW,0,RAWTAG)
	. . S POS=END3
	. S CLOSE=$F(TEXT,CD,OPEN)
	. I 'CLOSE S ERR("code")="TPL_PARSE",ERR("msg")="Unclosed mustache tag." Q
	. S INSIDE=$$TRIM($E(TEXT,OPEN,CLOSE-$L(CD)-1))
	. S RAWTAG=$E(TEXT,OPEN-$L(OD),CLOSE-1)
	. ; delimiter change
	. I $E(INSIDE,1)="=",$E(INSIDE,$L(INSIDE))="=" D  S POS=CLOSE Q
	. . N MID,W1,W2,REST
	. . S MID=$$TRIM($E(INSIDE,2,$L(INSIDE)-1))
	. . S REST=MID
	. . S W1=$$NEXTTOK(.REST),W2=$$NEXTTOK(.REST)
	. . I W1=""!(W2="") S ERR("code")="TPL_PARSE",ERR("msg")="Bad delimiter change tag." Q
	. . D ADDDELIM(.TOK,.N,W1,W2,RAWTAG)
	. . S OD=W1,CD=W2
	. ; Comments
	. I $E(INSIDE,1)="!" D ADDCOMM(.TOK,.N,RAWTAG) S POS=CLOSE Q
	. ; Unescaped via &
	. I $E(INSIDE,1)="&" D  S POS=CLOSE Q
	. . N K S K=$$TRIM($E(INSIDE,2,$L(INSIDE)))
	. . D ADDVAR(.TOK,.N,K,0,RAWTAG)
	. ; Partials
	. I $E(INSIDE,1)=">" D  S POS=CLOSE Q
	. . N P S P=$$PNORM($E(INSIDE,2,$L(INSIDE))) I P'="" D ADDPART(.TOK,.N,P,RAWTAG)
	. ; Parents (Mustache inheritance extension)
	. I $E(INSIDE,1)="<" D  S POS=CLOSE Q
	. . N P S P=$$PNORM($E(INSIDE,2,$L(INSIDE))) I P'="" D ADDPARS(.TOK,.N,P,RAWTAG)
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
	. . I OP="/" D ADDSECE(.TOK,.N,K,RAWTAG) Q
	. . S INV=$S(OP="^":1,1:0)
	. . D ADDSECS(.TOK,.N,K,INV,RAWTAG)
	. . I $E(K,1,6)="block:" D
	. . . S TOK(N,"blk")=1
	. . . S TOK(N,"bname")=$E(K,7,$L(K))
	. ; Default: variable escaped
	. D ADDVAR(.TOK,.N,INSIDE,1,RAWTAG)
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
	. Q:(TYP'="secS")&(TYP'="secE")&(TYP'="part")&(TYP'="parS")&(TYP'="comm")&(TYP'="delim")
	. I TYP="secE",$G(TOK(I,"styp"))="parS" Q  ; <<< add this
	. I $$ISSTAND(.TOK,I,MAX) S DO(I)=1
	F I=1:1:MAX I $G(DO(I)) D STANDAP(.TOK,I,MAX)
	Q
ISSTAND(TOK,I,MAX)
	Q $$STLEFTOK(.TOK,I)&$$STRIGHTOK(.TOK,I,MAX)
	;
STLEFTOK(TOK,I) ; from token I-1 leftwards to start-of-line: only WS text + standalone-eligible tags
	N J,TYP,V,P,TAIL,OK,SEENNL
	S OK=1,SEENNL=0
	F J=I-1:-1:1 Q:'OK  Q:SEENNL  D
	. S TYP=$G(TOK(J,"t"))
	. I TYP="text" D  Q
	. . S V=$G(TOK(J,"v"))
	. . S P=$$LASTNLSEQ(V)
	. . S TAIL=$S(P>0:$E(V,P+1,$L(V)),1:V)
	. . I $TR(TAIL," "_$C(9),"")'="" S OK=0 Q
	. . I P>0 S SEENNL=1
	. ; allow other standalone-eligible tags on the same line
	. I TYP="comm"!(TYP="delim")!(TYP="part")!(TYP="parS")!(TYP="secS")!(TYP="secE") Q
	. ; anything else on the line (e.g. var/unesc) => not standalone
	. S OK=0
	Q OK
STRIGHTOK(TOK,I,MAX) ; from token I+1 rightwards to end-of-line: only WS text + standalone-eligible tags
	N J,TYP,V,P,HEAD,OK,SEENNL
	S OK=1,SEENNL=0
	F J=I+1:1:MAX Q:'OK  Q:SEENNL  D
	. S TYP=$G(TOK(J,"t"))
	. I TYP="text" D  Q
	. . S V=$G(TOK(J,"v"))
	. . S P=$$FIRSTNLSEQ(V) 
	. . S HEAD=$S(P>0:$E(V,1,P-1),1:V)
	. . I $TR(HEAD," "_$C(9),"")'="" S OK=0 Q
	. . I P>0 S SEENNL=1
	. I TYP="comm"!(TYP="delim")!(TYP="part")!(TYP="parS")!(TYP="secS")!(TYP="secE") Q
	. S OK=0
	Q OK
FIRSTNLSEQ(S) ; position of first LF in S (0 if none)
	N P S P=$F($G(S),$C(10))
	Q $S(P>0:P-1,1:0)
STANDAP(TOK,I,MAX)
	N TYP,PV,P,IND,ISBLK,ISPART,ISPAR,L,R
	S TYP=$G(TOK(I,"t"))
	S ISBLK=$S(TYP="secS":+$G(TOK(I,"blk")),1:0)
	S ISPART=$S(TYP="part":1,1:0)
	S ISPAR=$S(TYP="parS":1,1:0)
	; mark standalone
	S TOK(I,"stand")=1
	; nearest prev text
	S L=I-1
	F  Q:L<1  Q:$G(TOK(L,"t"))="text"  S L=L-1
	; nearest next text
	S R=I+1
	F  Q:R>MAX  Q:$G(TOK(R,"t"))="text"  S R=R+1
	; capture call-site indent for partials, parents, and standalone blocks
	I ISPART!ISPAR!ISBLK D
	. S IND=""
	. I L>0 D
	. . S PV=$G(TOK(L,"v"))
	. . S P=$$LASTNLSEQ(PV)
	. . I P>0 S IND=$E(PV,P+1,$L(PV))
	. . E  S IND=PV
	. I IND'="",$TR(IND," "_$C(9),"")'="" S IND=""
	. S TOK(I,"indent")=IND
	; trim standalone line: cut left tail + right head/newline
	I L>0 S TOK(L,"v")=$$CUTPRE($G(TOK(L,"v")))
	I R'>MAX S TOK(R,"v")=$$CUTNX($G(TOK(R,"v")))
	Q
INDENTSTR(S,IND)
	I $G(IND)="" Q $G(S)
	N I,L,CH,OUT
	S S=$G(S),OUT=IND,L=$L(S)
	F I=1:1:L D
	. S CH=$E(S,I),OUT=OUT_CH
	. I CH=$C(10),I<L S OUT=OUT_IND
	Q OUT
DEINDENTSTR(S,IND) ; Inverse of INDENTSTR
	I $G(IND)="" Q $G(S)
	N LF,N,I,LINE,OUT
	S S=$G(S),LF=$C(10),OUT=""
	S N=$L(S,LF)
	F I=1:1:N D
	. S LINE=$P(S,LF,I)
	. I $E(LINE,1,$L(IND))=IND S LINE=$E(LINE,$L(IND)+1,$L(LINE))
	. S OUT=OUT_LINE
	. I I<N S OUT=OUT_LF
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
LINKSECS(TOK,ERR)
	K ERR
	N STK,SP,I,T,K,TOP,SI
	S SP=0,I=0
	F  S I=$O(TOK(I)) Q:'I  D  Q:$D(ERR)
	. S T=$G(TOK(I,"t"))
	. I (T="secS")!(T="parS") D  Q
	. . S SP=SP+1
	. . S STK(SP,"i")=I
	. . S STK(SP,"k")=$G(TOK(I,"k"))
	. I T="secE" D  Q
	. . S K=$G(TOK(I,"k"))
	. . I SP<1 D  S ERR("code")="TPL_PARSE",ERR("msg")="End without start: "_K Q
	. . . S SI=STK(SP,"i")
	. . . S ERR("line")=+$G(TOK(SI,"line"))
	. . . S ERR("col")=+$G(TOK(SI,"col"))
	. . . S ERR("tag")=$G(TOK(SI,"raw"))
	. . S TOP=$G(STK(SP,"k"))
	. . I TOP'=K D  Q
	. . . S SI=STK(SP,"i")
	. . . S ERR("line")=+$G(TOK(SI,"line"))
	. . . S ERR("col")=+$G(TOK(SI,"col"))
	. . . S ERR("tag")=$G(TOK(SI,"raw"))
	. . . S ERR("code")="TPL_PARSE",ERR("msg")="Mismatch: expected /"_TOP_" got /"_K Q
	. . S SI=STK(SP,"i")
	. . S TOK(SI,"m")=I
	. . S TOK(I,"styp")=$G(TOK(SI,"t"))  ; <<< add this
	. . S SP=SP-1
	I SP>0 D 
	. S ERR("code")="TPL_PARSE",ERR("msg")="Unclosed: "_$G(STK(SP,"k"))
	. S ERR("line")=+$G(TOK(SI,"line"))
	. S ERR("col")=+$G(TOK(SI,"col"))
	. S ERR("tag")=$G(TOK(SI,"raw"))
	Q
OUTINIT(W,OREF,CONF,CRLF)
	K W
	S W("root")=$G(OREF)
	S W("n")=0
	S W("buf")=""
	S W("chunk")=+$G(CONF("output","chunk")) I W("chunk")<256 S W("chunk")=8192
	S W("crlf")=+$G(CRLF)
	; PERF: cache base for fast numeric subs when root looks like a ref ending in ")"
	N R S R=W("root")
	I R["(",$E(R,$L(R))=")" S W("base")=$E(R,1,$L(R)-1)
	E  S W("base")=""
	Q
OUTAPP(W,VAL)
	N V,CHUNK,SPACE,PIECE,BUF
	S V=$G(VAL) Q:V=""
	S CHUNK=+$G(W("chunk")) I CHUNK<256 S CHUNK=8192
	; PERF: keep buf local, write back once
	S BUF=$G(W("buf"))
	F  Q:V=""  D
	. S SPACE=CHUNK-$L(BUF)
	. I SPACE<1 D  S SPACE=CHUNK
	. . S W("buf")=BUF
	. . D OUTFLUSH(.W)
	. . S BUF=""
	. S PIECE=$E(V,1,SPACE)
	. S BUF=BUF_PIECE
	. S V=$E(V,SPACE+1,$L(V))
	. I $L(BUF)'<CHUNK D
	. . S W("buf")=BUF
	. . D OUTFLUSH(.W)
	. . S BUF=""
	S W("buf")=BUF
	Q
OUTFLUSH(W)
	N BASE,ROOT,BUF,N
	S BUF=$G(W("buf")) Q:BUF=""
	S BASE=$G(W("base"))
	; PERF: fast numeric append when we have a cached base
	I BASE'="" D  Q
	. S N=+$G(W("n"))+1
	. S W("n")=N
	. S @(BASE_","_N_")")=BUF
	. S W("buf")=""
	; Fallback (should be rare)
	S ROOT=$G(W("root")) Q:ROOT=""
	S N=+$G(W("n"))+1
	S W("n")=N
	S @($$APPREF(ROOT,N))=BUF
	S W("buf")=""
	Q
ISREF(S)
	N R S R=$$TRIM($G(S))
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
	N R,TB
	; Local token array path (root tokens when not using token-handle refs)
	I TN="TOK" Q $G(TOK(I,FIELD))
	; Global/ref token path: cache base in TBX(TN)
	S TB=$G(TBX(TN))
	I TB="" D
	. I TN["(",$E(TN,$L(TN))=")" S TB=$E(TN,1,$L(TN)-1),TBX(TN)=TB
	I TB="" Q ""
	S R=TB_","_I_","""_FIELD_""")"
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
	N TN,TG
	S FSP=FSP+1
	K F(FSP)  ; clear stale flags
	S F(FSP,"i")=START
	S F(FSP,"end")=END
	S F(FSP,"ctxTop")=CTSP
	S F(FSP,"mode")=$G(MODE,"emit")
	S F(FSP,"capRef")=$G(CAPREF)
	; cache token addressing mode for loop
	S TN=$G(TOKNAME,"TOK")
	S F(FSP,"tokName")=TN
	S TG=$S(TN["(":1,1:0)
	S F(FSP,"tg")=TG
	I TG S F(FSP,"tb")=$E(TN,1,$L(TN)-1)
	E  S F(FSP,"tb")=""
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
	. S TXT=$$INDENTSTR(VAL,IND)
	. I CR'="" S @CR=""
	. K F(OLD,"capEmit"),F(OLD,"indent")
	. S PMODE=$G(F(OLD-1,"mode"))
	. I PMODE="capture" D
	. . S PCR=$G(F(OLD-1,"capRef")) Q:PCR=""
	. . S @PCR=$G(@PCR)_TXT
	. E  D EMIT(OLD-1,.F,.OUT,TXT)
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
	S CHREF=$$APPREF(REF,"")
	Q $O(@CHREF)
EMIT(FSP,F,OUT,VAL)
	N MODE,V
	S MODE=$G(F(FSP,"mode"))
	I MODE="capture" D  Q
	. N CR S CR=$G(F(FSP,"capRef")) Q:CR=""
	. S @CR=$G(@CR)_$G(VAL)
	S V=$G(VAL)
	I $G(CRLF),V'="" D
	. I V[$C(13) S V=$$NORMNL(V)
	. I V[$C(10) S V=$$LF2CRLF(V)
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
	. . N S0 S S0=$$FIRSTSUB(R)
	. . I S0'="" S ISSET=1,TYPE="list",REF=R Q
	. . S ISSET=1,TYPE="obj",REF=R Q
	. I $D(@R)#2 S ISSET=1,TYPE="scalar",REF=R Q
	. S ISSET=0,TYPE="missing",REF="" Q
	I K["." D  Q
	. N PARTS,PC,I,P1,LEVEL,BASE,OK1,TT1,RR1,CUR,NEXT
	. D SPLIT(K,".",.PARTS,.PC)
	. I PC<2 Q  ; safety
	. S P1=$G(PARTS(1)) I P1="" Q
	. S OK1=0,TT1="missing",RR1=""
	. F LEVEL=CTSP:-1:1 Q:OK1  D
	. . S BASE=$G(CST(LEVEL)) Q:BASE=""
	. . D RESINBASE(BASE,P1,.OK1,.TT1,.RR1)
	. I 'OK1 S ISSET=0,TYPE="missing",REF="" Q
	. I TT1="scalar" S ISSET=0,TYPE="missing",REF="" Q
	. S CUR=RR1
	. F I=2:1:PC D  Q:'ISSET
	. . S P=$G(PARTS(I))
	. . I P="" S ISSET=0,TYPE="missing",REF="" Q
	. . S NEXT=$$APPREF(CUR,P)
	. . I '$D(@NEXT) S ISSET=0,TYPE="missing",REF="" Q
	. . S CUR=NEXT,ISSET=1
	. I 'ISSET Q
	. I $D(@CUR)>1 D  Q
	. . N S0 S S0=$$FIRSTSUB(CUR)
	. . I S0'="" S TYPE="list",REF=CUR,ISSET=1 Q
	. . S TYPE="obj",REF=CUR,ISSET=1 Q
	. I $D(@CUR)#2 S TYPE="scalar",REF=CUR,ISSET=1 Q
	. S ISSET=0,TYPE="missing",REF="" Q
	N LEVEL
	F LEVEL=CTSP:-1:1 D  Q:ISSET
	. N BASE S BASE=$G(CST(LEVEL)) Q:BASE=""
	. N OK,RR,TT
	. D RESINBASE(BASE,K,.OK,.TT,.RR)
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
	D PUSHFRAME(.FSP,.F,START,END,CTSP,.MODE,.CAPREF,.TOKNAME)
	S F(FSP,"indent")=$G(F(PARENT,"indent"))
	S F(FSP,"at")=+$G(F(PARENT,"at"))
	Q
NUMBASE(REF)
	N R
	S R=$G(REF)
	I R["(" Q $E(R,1,$L(R)-1)_","
	Q R_"("
OUTNORM(V,CRLF)
	N X S X=$G(V)
	I 'CRLF Q X
	I X[$C(13) S X=$$NORMNL(X)
	I X[$C(10) S X=$$LF2CRLF(X)
	Q X
EVALX(TOK,CONF,CTX,OUTMODE,OUT,OREF,ERR)
	K ERR
	N CST,CTSP
	N TBX  ; PERF: token-ref base cache used by TOKGET()
	; Allow sub-render to pass a prepared context-stack via CTX("meta","__ctsp"/"__cst",i)
	; Only honor it if __cst(1) exists (prevents accidental blank-stack regressions)
	I $D(CTX("meta","__ctsp")),$D(CTX("meta","__cst",1)) D
	. N I
	. S CTSP=+$G(CTX("meta","__ctsp")) I CTSP<1 S CTSP=1
	. F I=1:1:CTSP S CST(I)=$G(CTX("meta","__cst",I))
	E  D
	. S CTSP=1,CST(1)="CTX"
	N ROOTTPL S ROOTTPL=$G(CTX("meta","templateName")) ; optional if you set it upstream
	N LASTTN,LASTI S LASTTN="",LASTI=0
	; partial / parent recursion protection
	N PDEPTHMAX S PDEPTHMAX=+$G(CONF("templates","maxPartialDepth")) I PDEPTHMAX<1 S PDEPTHMAX=20
	N PACTIVE,PTCACHE
	; IMPORTANT: compiled partial-token cache moved to PARTTOKC to avoid colliding with partial source maps
	K ^TMP($J,"MIOTPL2","PARTTOKC")
	; parent override stack (scoped to each {{<parent}} call)
	N BOVRSP,BOVR
	S BOVRSP=0
	N BCAP
	N TOKR,PMAX,CRLF
	D TOKINFO(.TOK,.TOKR,.PMAX,.CRLF)
	N W
	I $G(OUTMODE)="R" D  Q:$D(ERR)
	. I $G(OREF)="" S ERR("code")="TPL_OREF",ERR("msg")="Missing output reference." Q
	. K @OREF
	. D OUTINIT(.W,OREF,.CONF,CRLF)
	E  S OUTMODE="S",OUT=""
	; fast path
	N MREF,SIMPLE
	S SIMPLE=0
	I TOKR["(" D
	. S MREF=$$APPREF(TOKR,"meta")
	. I '$D(@($$APPREF(MREF,"simple"))) D ANALYZERREF(TOKR,MREF)
	. S SIMPLE=+$G(@($$APPREF(MREF,"simple")))
	E  D
	. I '$D(TOK("meta","simple")) D ANALYZE(.TOK)
	. S SIMPLE=+$G(TOK("meta","simple"))
	I SIMPLE D  Q:$Q $S($D(ERR):0,1:1)  Q
	. D EVALSIMP(.TOK,TOKR,PMAX,CRLF,.CONF,.CST,.CTSP,OUTMODE,.OUT,.W,.ERR)
	; frame stack
	N FSP,F
	S FSP=1
	S F(1,"i")=1
	S F(1,"end")=PMAX
	S F(1,"ctxTop")=CTSP
	S F(1,"mode")="emit"
	S F(1,"capRef")=""
	S F(1,"tokName")=TOKR
	S F(1,"indent")=""
	S F(1,"at")=1
	N FRAMELIM,FRAMES
	S FRAMELIM=2000,FRAMES=0
	F  Q:FSP<1  D  Q:$D(ERR)
	. S FRAMES=FRAMES+1
	. I FRAMES>FRAMELIM S ERR("code")="TPL_LIMIT",ERR("msg")="Render exceeded safety frame limit." Q
	. ; list-iterator frame (PERF: use listBase)
	. I $G(F(FSP,"mode"))="iter" D  Q
	. . N PARENT,LREF,LBASE,SUB,BS,BE,PMODE,PCAP
	. . S PARENT=FSP
	. . S LREF=$G(F(PARENT,"listRef"))
	. . S LBASE=$G(F(PARENT,"listBase"))
	. . I LBASE="" S LBASE=$S(LREF["("&($E(LREF,$L(LREF))=")"):$E(LREF,1,$L(LREF)-1),1:""),F(PARENT,"listBase")=LBASE
	. . S SUB=$G(F(PARENT,"sub"))
	. . S BS=+$G(F(PARENT,"bodyS"))
	. . S BE=+$G(F(PARENT,"bodyE"))
	. . S PMODE=$G(F(PARENT,"parentMode"))
	. . S PCAP=$G(F(PARENT,"parentCap"))
	. . I LBASE="" D  Q  ; ultra-safety fallback
	. . . S SUB=$O(@($$APPREF(LREF,SUB)))
	. . . I SUB="" D POPX(OUTMODE,.FSP,.F,.CST,.CTSP,.OUT,.W,CRLF) Q
	. . . S F(PARENT,"sub")=SUB
	. . . N ITEMREF,NEWTOP
	. . . S ITEMREF=$$APPREF(LREF,SUB)
	. . . S NEWTOP=CTSP+1,CST(NEWTOP)=ITEMREF,CTSP=NEWTOP
	. . . D PUSHFRAMEI(.FSP,.F,BS,BE,CTSP,PMODE,PCAP,$G(F(PARENT,"tokName")),PARENT)
	. . ; numeric list fast-path: SUB="" => start
	. . I SUB="" S SUB=$O(@(LBASE_","""")"))
	. . E  S SUB=$O(@(LBASE_","_SUB_")"))
	. . I SUB="" D POPX(OUTMODE,.FSP,.F,.CST,.CTSP,.OUT,.W,CRLF) Q
	. . S F(PARENT,"sub")=SUB
	. . N ITEMREF,NEWTOP
	. . S ITEMREF=LBASE_","_SUB_")"
	. . S NEWTOP=CTSP+1,CST(NEWTOP)=ITEMREF,CTSP=NEWTOP
	. . D PUSHFRAMEI(.FSP,.F,BS,BE,CTSP,PMODE,PCAP,$G(F(PARENT,"tokName")),PARENT)
	. ; end-of-frame
	. N I,END,TN,TYP
	. S I=+$G(F(FSP,"i")),END=+$G(F(FSP,"end"))
	. I I<1!(I>END) D POPX(OUTMODE,.FSP,.F,.CST,.CTSP,.OUT,.W,CRLF) Q
	. S TN=$G(F(FSP,"tokName")) S:TN="" TN="TOK"
	. S LASTTN=TN,LASTI=I
	. S TYP=$$TOKGET(TN,I,"t")
	. ; TEXT
	. I TYP="text" D  Q
	. . N V,IND,AT
	. . S V=$$TOKGET(TN,I,"v")
	. . S IND=$G(F(FSP,"indent"))
	. . I IND'="" D
	. . . S AT=+$G(F(FSP,"at"))
	. . . S V=$$INDTXT(V,IND,.AT)
	. . . S F(FSP,"at")=AT
	. . E  D
	. . . I V'="" S F(FSP,"at")=$S($E(V,$L(V))=$C(10):1,1:0)
	. . D EMITX(OUTMODE,FSP,.F,.OUT,.W,V,CRLF)
	. . S F(FSP,"i")=I+1
	. ; VAR / UNESC
	. I (TYP="var")!(TYP="unesc") D  Q
	. . N KEY,ESC,VAL,IND,AT
	. . S KEY=$$TOKGET(TN,I,"k")
	. . S ESC=+$$TOKGET(TN,I,"e")
	. . S VAL=$$RESVAL(KEY,.CST,CTSP)
	. . ; variable lambdas (mustache.js-style): call with no args
	. . I $$ISLAM(VAL) D  Q:$D(ERR)
	. . . S VAL=$$LAMCALL0(VAL,.ERR)
	. . I ESC S VAL=$$ESCHTML(VAL)
	. . ; indentation-at-start-of-line only for scalar vars (existing behavior)
	. . S IND=$G(F(FSP,"indent"))
	. . S AT=+$G(F(FSP,"at"))
	. . I AT,IND'="",VAL'="" D EMITX(OUTMODE,FSP,.F,.OUT,.W,IND,CRLF) S AT=0
	. . I VAL'="" S AT=0
	. . S F(FSP,"at")=AT
	. . D EMITX(OUTMODE,FSP,.F,.OUT,.W,VAL,CRLF)
	. . S F(FSP,"i")=I+1
	. ; COMMENT / DELIM
	. I (TYP="comm")!(TYP="delim") D  Q
	. . S F(FSP,"i")=I+1
	. ; PARTIAL
	. I TYP="part" D  Q
	. . N PARENT,PN0,PN,INDTOK,PKEY,PTREF,PMX,PMODE,PCAP
	. . S PARENT=FSP
	. . S PN0=$$TOKGET(TN,I,"k")
	. . S PN=PN0
	. . I $E(PN,1)="*" D
	. . . I $E(PN,2)="*" S PN="" Q  ; no double-deref (spec)
	. . . S PN=$$RESVAL($E(PN,2,$L(PN)),.CST,CTSP)
	. . S F(PARENT,"i")=I+1
	. . I PN="" Q
	. . S PKEY=">"_PN
	. . S PACTIVE(PKEY)=+$G(PACTIVE(PKEY))+1
	. . I PACTIVE(PKEY)>PDEPTHMAX S ERR("code")="TPL_PARTIAL_DEPTH",ERR("msg")="Partial recursion depth exceeded: "_PN Q
	. . I '$D(PTCACHE(PKEY,"ref")) D
	. . . D GETPTOK(PN,PKEY,.CONF,.CTX,.PTREF,.PMX,.ERR)
	. . . I $D(ERR) D  Q
	. . . . S PACTIVE(PKEY)=PACTIVE(PKEY)-1 I PACTIVE(PKEY)'>0 K PACTIVE(PKEY)
	. . . . Q
	. . . S PTCACHE(PKEY,"ref")=PTREF
	. . . S PTCACHE(PKEY,"max")=PMX
	. . S PTREF=$G(PTCACHE(PKEY,"ref")),PMX=+$G(PTCACHE(PKEY,"max"))
	. . I PTREF="" D  Q
	. . . S PACTIVE(PKEY)=PACTIVE(PKEY)-1 I PACTIVE(PKEY)'>0 K PACTIVE(PKEY)
	. . S INDTOK=$$TOKGET(TN,I,"indent")
	. . S PMODE=$G(F(PARENT,"mode"))
	. . S PCAP=$G(F(PARENT,"capRef"))
	. . D PUSHFRAMEI(.FSP,.F,1,PMX,CTSP,PMODE,PCAP,PTREF,PARENT)
	. . S F(FSP,"pname")=PKEY
	. . S F(FSP,"callLine")=+$$TOKGET(TN,I,"line")
	. . S F(FSP,"callCol")=+$$TOKGET(TN,I,"col")
	. . I INDTOK'="" S F(FSP,"indent")=$G(F(FSP,"indent"))_INDTOK
	. ; PARENT ({{<name}} ... {{/name}})
	. I TYP="parS" D  Q
	. . N PARENT,PN0,PN,MI,INDTOK,PKEY,PTREF,PMX,PMODE,PCAP
	. . S PARENT=FSP
	. . S PN0=$$TOKGET(TN,I,"k")
	. . S MI=+$$TOKGET(TN,I,"m")
	. . I 'MI S ERR("code")="TPL_PARSE",ERR("msg")="Parent start without match: "_PN0 Q
	. . ; skip entire parent section in current stream
	. . S F(PARENT,"i")=MI+1
	. . S PN=PN0
	. . I $E(PN,1)="*" D
	. . . I $E(PN,2)="*" S PN="" Q
	. . . S PN=$$RESVAL($E(PN,2,$L(PN)),.CST,CTSP)
	. . I PN="" Q
	. . S PKEY="<"_PN
	. . S PACTIVE(PKEY)=+$G(PACTIVE(PKEY))+1
	. . I PACTIVE(PKEY)>PDEPTHMAX S ERR("code")="TPL_PARTIAL_DEPTH",ERR("msg")="Parent recursion depth exceeded: "_PN Q
	. . I '$D(PTCACHE(PKEY,"ref")) D
	. . . D GETPTOK(PN,PKEY,.CONF,.CTX,.PTREF,.PMX,.ERR)
	. . . I $D(ERR) D  Q
	. . . . S PACTIVE(PKEY)=PACTIVE(PKEY)-1 I PACTIVE(PKEY)'>0 K PACTIVE(PKEY)
	. . . . Q
	. . . S PTCACHE(PKEY,"ref")=PTREF
	. . . S PTCACHE(PKEY,"max")=PMX
	. . S PTREF=$G(PTCACHE(PKEY,"ref")),PMX=+$G(PTCACHE(PKEY,"max"))
	. . I PTREF="" D  Q
	. . . S PACTIVE(PKEY)=PACTIVE(PKEY)-1 I PACTIVE(PKEY)'>0 K PACTIVE(PKEY)
	. . ; push a new override scope for THIS parent invocation
	. . S BOVRSP=BOVRSP+1
	. . K BOVR(BOVRSP)
	. . ; push parent-render frame FIRST (runs AFTER the body define frame)
	. . S PMODE=$G(F(PARENT,"mode"))
	. . S PCAP=$G(F(PARENT,"capRef"))
	. . D PUSHFRAMEI(.FSP,.F,1,PMX,CTSP,PMODE,PCAP,PTREF,PARENT)
	. . S F(FSP,"pname")=PKEY
	. . S F(FSP,"callLine")=+$$TOKGET(TN,I,"line")
	. . S F(FSP,"callCol")=+$$TOKGET(TN,I,"col")
	. . S F(FSP,"bovrPop")=1
	. . S INDTOK=$$TOKGET(TN,I,"indent")
	. . I INDTOK'="" S F(FSP,"indent")=$G(F(FSP,"indent"))_INDTOK
	. . ; push parent-body “define” frame (drop output, register {{$block}} overrides)
	. . I (I+1)>(MI-1) Q
	. . D PUSHFRAMEI(.FSP,.F,I+1,MI-1,CTSP,"drop","",TN,PARENT)
	. . S F(FSP,"pdef")=1
	. ; SECTION START
	. I TYP="secS" D  Q
	. . N PARENT,KEY,INV,MI,ISBLK
	. . S PARENT=FSP
	. . S KEY=$$TOKGET(TN,I,"k")
	. . S INV=+$$TOKGET(TN,I,"inv")
	. . S MI=+$$TOKGET(TN,I,"m")
	. . I 'MI S ERR("code")="TPL_PARSE",ERR("msg")="Section start without match: "_KEY Q
	. . ; BLOCK ({{$name}} ... {{/name}})
	. . I $E(TN,$L(TN))=")" S ISBLK=+$G(@($E(TN,1,$L(TN)-1)_","_I_",""blk"")"))
	. . E  S ISBLK=+$G(@(TN_"("_I_",""blk"")"))
	. . I 'ISBLK S ISBLK=+$$TOKGET(TN,I,"blk")
	. . I ISBLK D  Q
	. . . N BNAME,CAPMODE,OTOK,OS,OE,OIND,OAT,EIND,TXT,NEWF,CAPREF
	. . . S BNAME=$$TOKGET(TN,I,"bname") S:BNAME="" BNAME=KEY
	. . . ; Parent-define frame: register override, do not render body
	. . . I +$G(F(PARENT,"pdef")) D  Q
	. . . . S BOVR(BOVRSP,BNAME,"tok")=TN
	. . . . S BOVR(BOVRSP,BNAME,"s")=I+1
	. . . . S BOVR(BOVRSP,BNAME,"e")=MI-1
	. . . . S BOVR(BOVRSP,BNAME,"indent")=$G(F(PARENT,"indent"))
	. . . . S BOVR(BOVRSP,BNAME,"at")=+$G(F(PARENT,"at"))
	. . . . S F(PARENT,"i")=MI+1
	. . . ; captureBlocks mode (page defines blocks for layout)
	. . . S CAPMODE=$S(+$G(F(PARENT,"capBlocks")):1,$D(CTX("meta","captureBlocks")):+$G(CTX("meta","captureBlocks")),1:+$G(CONF("templates","captureBlocks")))
	. . . I CAPMODE D  Q
	. . . . S F(PARENT,"i")=MI+1
	. . . . S NEWF=FSP+1,BCAP(NEWF)="",CAPREF=$NA(BCAP(NEWF))
	. . . . D PUSHFRAMEI(.FSP,.F,I+1,MI-1,CTSP,"capture",CAPREF,TN,PARENT)
	. . . . S F(FSP,"storeBlock")=1
	. . . . S F(FSP,"storeName")=BNAME
	. . . . S F(FSP,"storeCapRef")=CAPREF
	. . . ; overridden by nearest parent scope?
	. . . D GETBOVR(BNAME,.OTOK,.OS,.OE,.OIND,.OAT)
	. . . I OTOK'="" D  Q
	. . . . S EIND=$$BLKEXPIND(TN,I,MI,$G(F(PARENT,"indent")))
	. . . . S F(PARENT,"i")=MI+1
	. . . . S NEWF=FSP+1,BCAP(NEWF)="",CAPREF=$NA(BCAP(NEWF))
	. . . . D PUSHFRAMEI(.FSP,.F,OS,OE,CTSP,"capture",CAPREF,OTOK,PARENT)
	. . . . S F(FSP,"indent")=$G(OIND)
	. . . . S F(FSP,"at")=+$G(OAT)
	. . . . S F(FSP,"capEmit")=1
	. . . . S F(FSP,"emitIndent")=EIND
	. . . . S F(FSP,"blockDefIndent")=""
	. . . . N SIND S SIND=$$BLKSTRIPIND(OTOK,OS,OE)
	. . . . S F(FSP,"stripIndent")=SIND
	. . . ; block provided directly in CTX("blocks",...)
	. . . I $D(CTX("blocks",BNAME)) D  Q
	. . . . S EIND=$$BLKEXPIND(TN,I,MI,$G(F(PARENT,"indent")))
	. . . . I $G(F(PARENT,"mode"))="capture",$G(F(PARENT,"stripIndent"))'="" S EIND=$G(F(PARENT,"stripIndent"))_EIND
	. . . . S TXT=$G(CTX("blocks",BNAME))
	. . . . S TXT=$$INDENTSTR(TXT,EIND)
	. . . . D EMITX(OUTMODE,PARENT,.F,.OUT,.W,TXT,CRLF)
	. . . . I TXT'="" S F(PARENT,"at")=$S($E(TXT,$L(TXT))=$C(10):1,1:0)
	. . . . S F(PARENT,"i")=MI+1
	. . . ; default content: render body normally
	. . . S F(PARENT,"i")=MI+1
	. . . D PUSHFRAMEI(.FSP,.F,I+1,MI-1,CTSP,$G(F(PARENT,"mode")),$G(F(PARENT,"capRef")),TN,PARENT)
	. . ; Normal section flow
	. . S F(PARENT,"i")=MI+1
	. . N ISSET,TYPE,REF
	. . D RESREF(KEY,.CST,CTSP,.ISSET,.TYPE,.REF)
	. . I TYPE="list" D
	. . . N S0 S S0=$$FIRSTSUB(REF)
	. . . I S0'="",S0'?1.N S TYPE="obj"
	. . ; Higher-order section lambdas (Mustache.js-style) - only for non-inverted, scalar, set
	. . N DIDLAM S DIDLAM=0
	. . I 'INV,(TYPE="scalar"),ISSET D  Q:$D(ERR)
	. . . N LAMV,LVL,RAW,LRID,RET,OUT2,LL,DEP
	. . . S LAMV=$G(@REF)
	. . . S LVL=$ZCONVERT(LAMV,"L") I LVL="null" S LAMV=""
	. . . Q:'$$ISLAM(LAMV)
	. . . S RAW=$$RAWTEXT(TN,I+1,MI-1)
	. . . D LAMHNEW(.CONF,.CTX,.CST,CTSP,.LRID)
	. . . S RET=$$LAMCALL2(LAMV,RAW,LRID,.ERR)
	. . . S DEP=0
	. . . F  Q:$D(ERR)  Q:'$$ISLAM(RET)  D
	. . . . S DEP=DEP+1
	. . . . I DEP>16 S ERR("code")="TPL_LAMBDA",ERR("msg")="Lambda nesting too deep." Q
	. . . . S RET=$$LAMCALL2(RET,RAW,LRID,.ERR)
	. . . I '$D(ERR) S OUT2=$$LRENDER(LRID,RET)
	. . . D LAMHKILL(LRID)
	. . . Q:$D(ERR)
	. . . I $G(OUT2)'="" D
	. . . . D EMITX(OUTMODE,PARENT,.F,.OUT,.W,OUT2,CRLF)
	. . . . S LL=$L(OUT2) I LL>0 S F(PARENT,"at")=$S($E(OUT2,LL)=$C(10):1,1:0)
	. . . S DIDLAM=1
	. . I DIDLAM Q  ; do NOT render section body
	. . ; Inverted
	. . I INV D  Q
	. . . I $$ISTRUTH(.ISSET,.TYPE,.REF)=0 D PUSHFRAMEI(.FSP,.F,I+1,MI-1,CTSP,$G(F(PARENT,"mode")),$G(F(PARENT,"capRef")),TN,PARENT)
	. . I $$ISTRUTH(.ISSET,.TYPE,.REF)=0 Q
	. . I TYPE="list" D  Q
	. . . S FSP=FSP+1
	. . . K F(FSP)
	. . . S F(FSP,"mode")="iter"
	. . . S F(FSP,"i")=0,F(FSP,"end")=0
	. . . S F(FSP,"ctxTop")=CTSP
	. . . S F(FSP,"listRef")=REF
	. . . ; PERF: cache base once for iterator
	. . . I REF["(",$E(REF,$L(REF))=")" S F(FSP,"listBase")=$E(REF,1,$L(REF)-1)
	. . . E  S F(FSP,"listBase")=""
	. . . S F(FSP,"sub")=""
	. . . S F(FSP,"bodyS")=I+1
	. . . S F(FSP,"bodyE")=MI-1
	. . . S F(FSP,"parentMode")=$G(F(PARENT,"mode"))
	. . . S F(FSP,"parentCap")=$G(F(PARENT,"capRef"))
	. . . S F(FSP,"tokName")=TN
	. . . S F(FSP,"indent")=$G(F(PARENT,"indent"))
	. . . S F(FSP,"at")=+$G(F(PARENT,"at"))
	. . I (TYPE="obj")!(TYPE="scalar") D  Q
	. . . N NEWTOP S NEWTOP=CTSP+1
	. . . S CST(NEWTOP)=REF,CTSP=NEWTOP
	. . . D PUSHFRAMEI(.FSP,.F,I+1,MI-1,CTSP,$G(F(PARENT,"mode")),$G(F(PARENT,"capRef")),TN,PARENT)
	. . D PUSHFRAMEI(.FSP,.F,I+1,MI-1,CTSP,$G(F(PARENT,"mode")),$G(F(PARENT,"capRef")),TN,PARENT)
	. ; SECTION END
	. I TYP="secE" D  Q
	. . S F(FSP,"i")=I+1
	. ; unknown
	. S F(FSP,"i")=I+1
	I $G(OUTMODE)="R" D OUTFLUSH(.W)
	I $D(ERR) D ERRATTACH(LASTTN,LASTI,.F,.FSP,ROOTTPL,.ERR)
	Q:$Q $S($D(ERR):0,1:1)
	Q
RAWTEXT(TN,BS,BE)
	N OUT,I,R
	S OUT=""
	I +$G(BS)<1 Q OUT
	I +$G(BE)<BS Q OUT
	F I=BS:1:BE D
	. S R=$$TOKGET(TN,I,"raw")
	. I R="" D  ; fallback best-effort
	. . I $$TOKGET(TN,I,"t")="text" S R=$$TOKGET(TN,I,"v")
	. . E  S R=$$TOK2TPL(TN,I,I)
	. S OUT=OUT_R
	Q OUT
EMITX(OUTMODE,FSP,F,OUT,W,VAL,CRLF)
	N MODE,V,CR
	S MODE=$G(F(FSP,"mode"))
	I MODE="drop" Q
	I MODE="capture" D  Q
	. S CR=$G(F(FSP,"capRef")) Q:CR=""
	. S @CR=$G(@CR)_$G(VAL)
	S V=$G(VAL)
	Q:V=""
	; inline OUTNORM (same behavior, avoids $$OUTNORM in hot path)
	I +$G(CRLF) D
	. I V[$C(13) S V=$$NORMNL(V)
	. I V[$C(10) S V=$$LF2CRLF(V)
	I $G(OUTMODE)="R" D OUTAPP(.W,V) Q
	S OUT=$G(OUT)_V
	Q
	;
POPX(OUTMODE,FSP,F,CST,CTSP,OUT,W,CRLF)
	N OLD,CM,PM,CAPVAL,DEFIND,STRIP,CR
	S OLD=FSP
	S CM=$G(F(OLD,"mode"))
	S PM=$S(OLD>1:$G(F(OLD-1,"mode")),1:"")
	; storeBlock: deindent captured block text into CTX("blocks",...)
	S CAPVAL="",DEFIND="",STRIP="",CR=""
	I +$G(F(OLD,"storeBlock")) D
	. S CR=$G(F(OLD,"storeCapRef")) I CR="" S CR=$G(F(OLD,"capRef"))
	. S CAPVAL=$S(CR'="":$G(@CR),1:"")
	. S DEFIND=$G(F(OLD,"blockDefIndent"))
	. S STRIP=DEFIND I STRIP="" S STRIP=$$BLKMININD(CAPVAL)
	. I STRIP'="" S CAPVAL=$$DEINDENTSTR(CAPVAL,STRIP)
	. N BN,NOOVR
	. S BN=$G(F(OLD,"storeName"))
	. S NOOVR=+$G(F(OLD,"storeNoOverwrite"))
	. I NOOVR,$D(CTX("blocks",BN)) Q
	. S CTX("blocks",BN)=CAPVAL
	; partial/parent recursion accounting
	I $G(F(OLD,"pname"))'="" D
	. N PN S PN=$G(F(OLD,"pname"))
	. S PACTIVE(PN)=+$G(PACTIVE(PN))-1
	. I PACTIVE(PN)'>0 K PACTIVE(PN)
	; capEmit: emit captured content into parent, with deindent->indent transform
	I +$G(F(OLD,"capEmit")) D
	. N VAL,IND,TXT,LL
	. S CR=$G(F(OLD,"capRef"))
	. S VAL=$S(CR'="":$G(@CR),1:"")
	. S DEFIND=$G(F(OLD,"blockDefIndent"))
	. S STRIP=DEFIND I STRIP="" S STRIP=$$BLKMININD(VAL)
	. I STRIP'="" S VAL=$$DEINDENTSTR(VAL,STRIP)
	. S IND=$G(F(OLD,"emitIndent")) I IND="" S IND=$G(F(OLD,"indent"))
	. N PSTRIP S PSTRIP=""
	. I OLD>1,$G(F(OLD-1,"mode"))="capture" S PSTRIP=$G(F(OLD-1,"stripIndent"))
	. I PSTRIP'="" S IND=PSTRIP_IND
	. S TXT=$$INDENTSTR(VAL,IND)
	. I CR'="" S @CR=""
	. K F(OLD,"capEmit"),F(OLD,"emitIndent")
	. I OLD>1 D
	. . D EMITX(OUTMODE,OLD-1,.F,.OUT,.W,TXT,CRLF)
	. . ; *** critical: update parent "at" based on what was just emitted
	. . S LL=$L(TXT)
	. . I LL>0 S F(OLD-1,"at")=$S($E(TXT,LL)=$C(10):1,1:0)
	; propagate "at" unless capture boundary
	I OLD>1 D
	. I '(CM="capture"&(PM'="capture")) S F(OLD-1,"at")=+$G(F(OLD,"at"))
	; pop parent-override scope (Mustache parent call ends)
	I +$G(F(OLD,"bovrPop")) D
	. K BOVR($G(BOVRSP))
	. S BOVRSP=$G(BOVRSP)-1
	. I BOVRSP<0 S BOVRSP=0
	S FSP=FSP-1
	I FSP>0 S CTSP=+$G(F(FSP,"ctxTop"))
	Q
TOKINFO(TOK,TOKR,PMAX,CRLF)
	N MREF,PM
	S TOKR="TOK",PMAX=0,CRLF=0
	; Token-handle (zero-copy path)
	I $D(TOK("ref")) D  Q
	. S TOKR=$G(TOK("ref"))
	. S PMAX=+$G(TOK("pmax"))
	. S MREF=$$APPREF(TOKR,"meta")
	. I 'PMAX D
	. . S PM=+$G(@($$APPREF(MREF,"pmax")))
	. . I 'PM S PM=$$TOKENDR(TOKR),@($$APPREF(MREF,"pmax"))=PM
	. . S PMAX=PM
	. S CRLF=+$G(@($$APPREF(MREF,"crlf")))
	; Local token array path
	S PMAX=+$G(TOK("meta","pmax"))
	I 'PMAX S PMAX=$$NUMMAX(.TOK),TOK("meta","pmax")=PMAX
	S CRLF=+$G(TOK("meta","crlf"))
	Q
RENDERX(NAME,CONF,CTX,OUT,ERR,OPT)
	; OPT("mode") = "S" | "R" | "AUTO"
	;   S    : scalar OUT (same as RENDER)
	;   R    : REF output, requires OPT("oref")
	;   AUTO : render to temp ref, then return scalar if <= maxString,
	;          else ERR("oref") OR OUT("ref") if autoReturnRef=1
	K ERR K OUT
	N MODE S MODE=$ZCONVERT($G(OPT("mode")),"U")
	I MODE="" S MODE=$S($$BOOL($G(CONF("output","auto"))):"AUTO",1:"S")
	I MODE="S" D  Q
	. D RENDER(NAME,.CONF,.CTX,.OUT,.ERR)
	I MODE="R" D  Q
	. N OREF S OREF=$G(OPT("oref"))
	. I OREF="" S ERR("code")="TPL_OREF",ERR("msg")="RENDERX mode=R requires OPT(""oref"")." Q
	. D RENDERREFNAME(NAME,.CONF,.CTX,OREF,.ERR) Q:$D(ERR)
	. S OUT("mode")="R",OUT("ref")=OREF
	; AUTO
	N MAX S MAX=+$G(CONF("output","maxString")) I MAX<1024 S MAX=900000
	N OREF S OREF=$G(OPT("oref")) I OREF="" S OREF=$$DEFOREF()
	K @OREF
	D RENDERREFNAME(NAME,.CONF,.CTX,OREF,.ERR) Q:$D(ERR)
	N LEN,CHUNKS
	D OUTLEN(OREF,.LEN,.CHUNKS)
	I LEN>MAX D  Q
	. I $$BOOL($G(CONF("output","autoReturnRef"))) D  Q
	. . S OUT("mode")="R",OUT("ref")=OREF,OUT("len")=LEN,OUT("chunks")=CHUNKS
	. S ERR("code")="TPL_OUT_TOO_LARGE"
	. S ERR("msg")="Rendered output is "_LEN_" bytes; exceeds maxString="_MAX_". Use RENDERREF/RENDERX mode=R."
	. S ERR("oref")=OREF
	D OUTJOIN(OREF,.OUT,.ERR)
	Q
RENDERREFNAME(NAME,CONF,CTX,OREF,ERR)
	K ERR
	N TOKREF,PMAX,TOK,DUM
	D GETTOKREF(NAME,.CONF,.TOKREF,.PMAX,.ERR) Q:$D(ERR)
	S TOK("ref")=TOKREF
	S TOK("pmax")=PMAX
	D EVALX(.TOK,.CONF,.CTX,"R",.DUM,$G(OREF),.ERR)
	Q
DEFOREF()
	Q $NA(^TMP($J,"MIOTPL2","OUT"))
OUTLEN(ROOT,LEN,CHUNKS)
	N S,REF
	S LEN=0,CHUNKS=0
	S REF=$G(ROOT) Q:REF=""
	S S=0
	F  S S=$O(@REF@(S)) Q:S=""  D
	. Q:'(S?1.N)
	. S CHUNKS=CHUNKS+1
	. S LEN=LEN+$L($G(@REF@(S)))
	Q
OUTJOIN(ROOT,OUT,ERR)
	K ERR S OUT=""
	N S,REF,CH
	S REF=$G(ROOT)
	I REF="" S ERR("code")="TPL_OREF",ERR("msg")="OUTJOIN missing ROOT." Q
	S S=0
	F  S S=$O(@REF@(S)) Q:S=""  D  Q:$D(ERR)
	. Q:'(S?1.N)
	. S CH=$G(@REF@(S))
	. S OUT=OUT_CH
	Q
ANALYZE(TOK)
	N MAX,I,TYP,SIMPLE,TXONLY
	S SIMPLE=1,TXONLY=1
	S MAX=+$G(TOK("meta","pmax"))
	I 'MAX S MAX=$$NUMMAX(.TOK) S TOK("meta","pmax")=MAX
	F I=1:1:MAX Q:(SIMPLE=0)&(TXONLY=0)  D
	. S TYP=$G(TOK(I,"t"))
	. I TYP="text" Q
	. I TYP="var"!(TYP="unesc") S TXONLY=0 Q
	. I TYP="comm"!(TYP="delim") Q
	. S SIMPLE=0,TXONLY=0
	S TOK("meta","simple")=SIMPLE
	S TOK("meta","textOnly")=TXONLY
	Q
ANALYZERREF(TOKR,MREF)
	N PM,BASE,I,TYP,SIMPLE,TXONLY
	S PM=+$G(@($$APPREF(MREF,"pmax")))
	I 'PM S PM=$$TOKENDR(TOKR) S @($$APPREF(MREF,"pmax"))=PM
	S BASE=$E(TOKR,1,$L(TOKR)-1)
	S SIMPLE=1,TXONLY=1
	F I=1:1:PM Q:(SIMPLE=0)&(TXONLY=0)  D
	. S TYP=$G(@(BASE_","_I_",""t"")"))
	. I TYP="text" Q
	. I TYP="var"!(TYP="unesc") S TXONLY=0 Q
	. I TYP="comm"!(TYP="delim") Q
	. S SIMPLE=0,TXONLY=0
	S @($$APPREF(MREF,"simple"))=SIMPLE
	S @($$APPREF(MREF,"textOnly"))=TXONLY
	Q
EVALSIMP(TOK,TOKR,PMAX,CRLF,CONF,CST,CTSP,OUTMODE,OUT,W,ERR)
	N TG,TB,TN,I,TYP,V,KEY,ESC,VAL,CR
	S CR=+$G(CRLF)
	S TG=$S(TOKR["(":1,1:0)
	I TG S TB=$E(TOKR,1,$L(TOKR)-1)
	S TN=TOKR I TN="" S TN="TOK"
	F I=1:1:PMAX Q:$D(ERR)  D
	. ; type
	. I TG S TYP=$G(@(TB_","_I_",""t"")"))
	. E  I TN="TOK" S TYP=$G(TOK(I,"t"))
	. E  S TYP=$G(@(TN_"("_I_",""t"")"))
	. I TYP="text" D  Q
	. . I TG S V=$G(@(TB_","_I_",""v"")"))
	. . E  I TN="TOK" S V=$G(TOK(I,"v"))
	. . E  S V=$G(@(TN_"("_I_",""v"")"))
	. . Q:V=""
	. . I CR D
	. . . I V[$C(13) S V=$$NORMNL(V)
	. . . I V[$C(10) S V=$$LF2CRLF(V)
	. . I V="" Q
	. . I OUTMODE="R" D OUTAPP(.W,V) Q
	. . S OUT=$G(OUT)_V
	. I TYP="var"!(TYP="unesc") D  Q
	. . I TG S KEY=$G(@(TB_","_I_",""k"")")),ESC=+$G(@(TB_","_I_",""e"")"))
	. . E  I TN="TOK" S KEY=$G(TOK(I,"k")),ESC=+$G(TOK(I,"e"))
	. . E  S KEY=$G(@(TN_"("_I_",""k"")")),ESC=+$G(@(TN_"("_I_",""e"")"))
	. . S VAL=$$RESVAL(KEY,.CST,CTSP)
	. . I $$ISLAM(VAL) D  Q:$D(ERR)
	. . . S VAL=$$LAMCALL0(VAL,.ERR)
	. . I ESC S VAL=$$ESCHTML(VAL)
	. . Q:VAL=""
	. . I CR D
	. . . I VAL[$C(13) S VAL=$$NORMNL(VAL)
	. . . I VAL[$C(10) S VAL=$$LF2CRLF(VAL)
	. . I VAL="" Q
	. . I OUTMODE="R" D OUTAPP(.W,VAL) Q
	. . S OUT=$G(OUT)_VAL
	. I TYP="comm"!(TYP="delim") Q
	. S ERR("code")="TPL_INT",ERR("msg")="Simple-eval hit complex token: "_TYP
	I OUTMODE="R" D OUTFLUSH(.W)
	Q
BLKMININD(S)
	N LF,N,I,LINE,PFX,COM
	S S=$G(S) Q:S="" ""
	S LF=$C(10),COM=""
	S N=$L(S,LF)
	F I=1:1:N D  Q:COM=""
	. S LINE=$P(S,LF,I)
	. I LINE="" Q
	. I $$ALLWS(LINE) Q
	. S PFX=$$LEADWS(LINE)
	. I COM="" S COM=PFX Q
	. S COM=$$COMMPFX(COM,PFX)
	Q COM
BLKSTRIPIND(TN,BS,BE)
	N COM,CUR,AT,I,TYP,V,L,J,CH
	S COM="",CUR="",AT=1
	F I=BS:1:BE D
	. S TYP=$$TOKGET(TN,I,"t")
	. I TYP="text" D  Q
	. . S V=$$TOKGET(TN,I,"v"),L=$L(V)
	. . F J=1:1:L D
	. . . S CH=$E(V,J)
	. . . I AT D
	. . . . I (CH=" ")!(CH=$C(9)) S CUR=CUR_CH Q
	. . . . I CH=$C(10) S CUR="" Q
	. . . . I COM="" S COM=CUR
	. . . . E  S COM=$$COMMPFX(COM,CUR)
	. . . . S AT=0
	. . . I CH=$C(10) S AT=1,CUR=""
	. I AT,(TYP="var")!(TYP="unesc")!(TYP="part") D
	. . I COM="" S COM=CUR
	. . E  S COM=$$COMMPFX(COM,CUR)
	. . S AT=0
	Q COM
LEADWS(LINE)
	N L,J,C
	S LINE=$G(LINE),L=$L(LINE)
	F J=1:1:L S C=$E(LINE,J) Q:(C'=" ")&(C'=$C(9))
	Q $E(LINE,1,J-1)
COMMPFX(A,B)
	N L,I
	S A=$G(A),B=$G(B)
	S L=$L(A) I $L(B)<L S L=$L(B)
	S I=1
	F  Q:I>L  Q:$E(A,I)'=$E(B,I)  S I=I+1
	Q $E(A,1,I-1)
DOLLARBLK(TOK) ; convert {{$name}} to a block section start
	N I,MAX,K,BN
	S MAX=$$NUMMAX(.TOK) Q:MAX<1
	F I=1:1:MAX D
	. Q:$G(TOK(I,"t"))'="var"
	. S K=$G(TOK(I,"k")) Q:$E(K)'="$"
	. S BN=$E(K,2,$L(K)) Q:BN=""
	. K TOK(I,"e") ; escape flag doesnt apply for secS
	. S TOK(I,"t")="secS"
	. S TOK(I,"k")=BN
	. S TOK(I,"inv")=0
	. S TOK(I,"blk")=1
	. S TOK(I,"bname")=BN
	Q
BLKDEFIND(TN,BS,BE)
	N I,TYP,V,L,J,CH,AT,CUR,IND
	S IND="",AT=1,CUR=""
	F I=BS:1:BE Q:IND'=""  D
	. S TYP=$$TOKGET(TN,I,"t")
	. I TYP="text" D  Q
	. . S V=$$TOKGET(TN,I,"v"),L=$L(V)
	. . F J=1:1:L Q:IND'=""  D
	. . . S CH=$E(V,J)
	. . . I AT D  Q
	. . . . I CH=$C(10) S CUR="",AT=1 Q
	. . . . I (CH=" ")!(CH=$C(9)) S CUR=CUR_CH Q
	. . . . S IND=CUR Q
	. . . I CH=$C(10) S CUR="",AT=1
	. I AT,(TYP="var")!(TYP="unesc")!(TYP="secS")!(TYP="part")!(TYP="parS") S IND=CUR
	Q IND
BLKEXPIND(TN,I,MI,PIND)
	N ST,BASE
	S ST=+$$TOKGET(TN,I,"stand")
	I 'ST Q ""
	S BASE=$$TOKGET(TN,I,"indent")
	I BASE="" S BASE=$$BLKDEFIND(TN,I+1,MI-1)
	Q $G(PIND)_BASE
GETBOVR(BNAME,OTOK,OS,OE,OIND,OAT)
	N L
	S OTOK="",OS=0,OE=0,OIND="",OAT=1
	F L=1:1:$G(BOVRSP) Q:OTOK'=""  D
	. I $D(BOVR(L,BNAME,"tok")) D
	. . S OTOK=$G(BOVR(L,BNAME,"tok"))
	. . S OS=+$G(BOVR(L,BNAME,"s"))
	. . S OE=+$G(BOVR(L,BNAME,"e"))
	. . S OIND=$G(BOVR(L,BNAME,"indent"))
	. . S OAT=+$G(BOVR(L,BNAME,"at"))
	Q
PNORM(S) ; normalize partial/parent name (handles {{> * dynamic }} => *dynamic)
	N R,REST,NAME
	S R=$$TRIM($G(S))
	I R="" Q ""
	; if dynamic: accept whitespace between "*" and name
	I $E(R)="*" D  Q $S(NAME="":"",1:"*"_NAME)
	. S REST=$$TRIM($E(R,2,$L(R)))
	. S NAME=$$NEXTTOK(.REST)
	; static: take first token (ignore any accidental extra tokens)
	S REST=R
	S NAME=$$NEXTTOK(.REST)
	Q NAME
PREFROOT(CONF,CTX) ; returns a ref to partial sources map, or ""
	N R
	S R=$G(CONF("templates","partialsRef")) I R'="" Q R
	S R=$G(CTX("meta","partialsRef")) I R'="" Q R
	Q ""
PARTLOOK(PREF,NAME,SRC,FOUND) ; lookup partial source text in PREF(name)
	S FOUND=0,SRC=""
	N PR S PR=$$APPREF(PREF,NAME)
	I '$D(@PR) Q
	I $D(@PR)#2 S SRC=$G(@PR),FOUND=1 Q
	I $D(@PR)>1 D
	. N I S I=0
	. F  S I=$O(@PR@(I)) Q:I=""  D
	. . Q:'(I?1.N)
	. . S SRC=SRC_$G(@PR@(I))
	. S FOUND=$S(SRC'="":1,1:0)
	Q
GETPTOK(PN,PKEY,CONF,CTX,PTREF,PMX,ERR) ; resolve partial tokens via map OR filesystem
	K ERR S PTREF="",PMX=0
	N PREF,SRC,FOUND,TMP,MREF,PM
	; 1) If a partials map is provided, it is authoritative (spec behavior)
	S PREF=$$PREFROOT(.CONF,.CTX)
	I PREF'="" D  Q
	. D PARTLOOK(PREF,PN,.SRC,.FOUND)
	. I 'FOUND S PTREF="",PMX=0 Q  ; missing partial => renders nothing
	. K TMP
	. D COMPILE(SRC,.TMP,.ERR) Q:$D(ERR)
	. ; IMPORTANT: store compiled partial TOKENS in PARTTOKC (not PARTTOK)
	. S PTREF=$NA(^TMP($J,"MIOTPL2","PARTTOKC",PKEY))
	. K @PTREF M @PTREF=TMP
	. S MREF=$$APPREF(PTREF,"meta")
	. S PMX=+$G(@($$APPREF(MREF,"pmax")))
	. I 'PMX S PM=$$TOKENDR(PTREF),@($$APPREF(MREF,"pmax"))=PM,PMX=PM
	; 2) Default: filesystem partials
	D GETTOKREF(PN,.CONF,.PTREF,.PMX,.ERR)
	I $D(ERR),$G(ERR("code"))="TPL_NOFILE" K ERR S PTREF="",PMX=0
	Q
ISLAM(V) ; 1 if scalar value looks like a callable lambda
	N S S S=$$TRIM($G(V))
	Q $S($E(S,1,2)="$$":1,1:0)
LAMBASE(LAM) ; normalize "$$LBL^ROU(...)" => "$$LBL^ROU"
	N S S S=$$TRIM($G(LAM))
	I S="" Q ""
	I $E(S,1,2)'="$$" S S="$$"_S
	I S["(" S S=$P(S,"(",1)
	Q S
LAMCALL0(LAM,ERR) ; variable lambda => $$LBL^ROU()
	N RES,EX,$ET,$ES
	S RES="" K ERR
	S EX=$$LAMBASE($G(LAM)) I EX="" Q ""
	S $ET="D LAMTRAP^MIOTPL(.ERR) S $ECODE="""""
	X "S RES="_EX_"()"
	S $ET=""
	Q $G(RES)
LAMCALL2(LAM,TXT,LRID,ERR) ; section lambda => $$LBL^ROU(text[, renderHandle])
	N RES,EX,A1,A2,$ET,$ES,ZS,RETRY
	S RES="" K ERR
	S EX=$$LAMBASE($G(LAM)) I EX="" Q ""
	S A1=$G(TXT),A2=+$G(LRID)
	S ZS="" S $ET="S ZS=$ZSTATUS,$ECODE="""""
	X "S RES="_EX_"(A1,A2)"
	S $ET=""
	I ZS="" Q $G(RES)
	D LAMTRAP(.ERR)
	Q ""
LAMTRAP(ERR)
	N $ET S $ET=""
	S ERR("code")="TPL_LAMBDA"
	S ERR("msg")="Lambda execution error: "_$ZSTATUS
	S $ZSTATUS="",$ECODE=""
	Q
LAMHNEW(CONF,CTX,CST,CTSP,LRID) ; create render-handle for subRender
	N ID,I
	S ID=$INCREMENT(^TMP($J,"MIOTPL2","LAMBDA","H"))
	K ^TMP($J,"MIOTPL2","LAMBDA",ID)
	M ^TMP($J,"MIOTPL2","LAMBDA",ID,"CONF")=CONF
	M ^TMP($J,"MIOTPL2","LAMBDA",ID,"CTX")=CTX
	S ^TMP($J,"MIOTPL2","LAMBDA",ID,"CTSP")=+$G(CTSP)
	F I=1:1:+$G(CTSP) S ^TMP($J,"MIOTPL2","LAMBDA",ID,"CST",I)=$G(CST(I))
	S LRID=ID
	Q
LAMHKILL(LRID)
	Q:LRID=""
	K ^TMP($J,"MIOTPL2","LAMBDA",+$G(LRID))
	Q
TOK2TPL(TN,BS,BE) ; reconstruct inner template text from tokens BS..BE (best-effort)
	N OUT,OD,CD,I,TYP,K,ESC,INV,NEWOD,NEWCD,BLK,BN
	S OUT="",OD="{{",CD="}}"
	I +$G(BS)<1 Q ""
	I +$G(BE)<BS Q ""
	F I=BS:1:BE D
	. S TYP=$$TOKGET(TN,I,"t")
	. I TYP="text" S OUT=OUT_$$TOKGET(TN,I,"v") Q
	. I TYP="var"!(TYP="unesc") D  Q
	. . S K=$$TOKGET(TN,I,"k")
	. . S ESC=+$$TOKGET(TN,I,"e")
	. . I ESC S OUT=OUT_OD_K_CD Q
	. . ; best-effort unescaped as triple braces when using default delimiters, else use &-form
	. . I (OD="{{")&(CD="}}") S OUT=OUT_"{{{"_K_"}}}" Q
	. . S OUT=OUT_OD_"&"_K_CD
	. I TYP="comm" S OUT=OUT_OD_"!"_CD Q
	. I TYP="part" S K=$$TOKGET(TN,I,"k") S OUT=OUT_OD_">"_K_CD Q
	. I TYP="parS" S K=$$TOKGET(TN,I,"k") S OUT=OUT_OD_"<"_K_CD Q
	. I TYP="secS" D  Q
	. . S K=$$TOKGET(TN,I,"k")
	. . S INV=+$$TOKGET(TN,I,"inv")
	. . S BLK=+$$TOKGET(TN,I,"blk")
	. . S BN=$$TOKGET(TN,I,"bname") S:BN="" BN=K
	. . I BLK S OUT=OUT_OD_"$"_BN_CD Q
	. . S OUT=OUT_OD_$S(INV:"^",1:"#")_K_CD
	. I TYP="secE" S K=$$TOKGET(TN,I,"k") S OUT=OUT_OD_"/"_K_CD Q
	. I TYP="delim" D  Q
	. . S NEWOD=$$TOKGET(TN,I,"od"),NEWCD=$$TOKGET(TN,I,"cd")
	. . S OUT=OUT_OD_"="_NEWOD_" "_NEWCD_"="_CD
	. . S OD=NEWOD,CD=NEWCD
	Q OUT
	;
LRENDER(LRID,TEMPLATE) ; subRender callback for section lambdas: $$LRENDER^MIOTPL(LRID,tmpl)
	N OUT,ERR,CONF,CTX,CST,CTSP,I,TOK
	S OUT=""
	I +$G(LRID)<1 Q OUT
	; restore snapshot
	M CONF=^TMP($J,"MIOTPL2","LAMBDA",LRID,"CONF")
	M CTX=^TMP($J,"MIOTPL2","LAMBDA",LRID,"CTX")
	S CTSP=+$G(^TMP($J,"MIOTPL2","LAMBDA",LRID,"CTSP"))
	I CTSP<1 S CTSP=1
	; embed the preserved stack into CTX meta ( to be used by EVALX)
	S CTX("meta","__ctsp")=CTSP
	F I=1:1:CTSP S CTX("meta","__cst",I)=$G(^TMP($J,"MIOTPL2","LAMBDA",LRID,"CST",I))
	; compile + render
	D COMPILE($G(TEMPLATE),.TOK,.ERR) Q:$D(ERR) ""
	D EVALX(.TOK,.CONF,.CTX,"S",.OUT,"",.ERR) Q:$D(ERR) ""
	Q $G(OUT)
ADDTXT(TOK,N,VAL,RAW)
	S N=N+1
	S TOK(N,"t")="text"
	S TOK(N,"v")=VAL
	S TOK(N,"raw")=$S($D(RAW):RAW,1:VAL)
	Q
ADDVAR(TOK,N,KEY,ESC,RAW)
	S N=N+1
	S TOK(N,"t")="var"
	S TOK(N,"k")=KEY
	S TOK(N,"e")=+$G(ESC)
	S TOK(N,"raw")=$G(RAW)
	Q
ADDSECS(TOK,N,KEY,INV,RAW)
	S N=N+1
	S TOK(N,"t")="secS"
	S TOK(N,"k")=KEY
	S TOK(N,"inv")=+$G(INV)
	S TOK(N,"raw")=$G(RAW)
	Q
ADDSECE(TOK,N,KEY,RAW)
	S N=N+1
	S TOK(N,"t")="secE"
	S TOK(N,"k")=KEY
	S TOK(N,"raw")=$G(RAW)
	Q
ADDPART(TOK,N,NAME,RAW)
	S N=N+1
	S TOK(N,"t")="part"
	S TOK(N,"k")=NAME
	S TOK(N,"raw")=$G(RAW)
	Q
ADDPARS(TOK,N,NAME,RAW)
	S N=N+1
	S TOK(N,"t")="parS"
	S TOK(N,"k")=NAME
	S TOK(N,"raw")=$G(RAW)
	Q
ADDDELIM(TOK,N,OD,CD,RAW)
	S N=N+1
	S TOK(N,"t")="delim"
	S TOK(N,"od")=$G(OD)
	S TOK(N,"cd")=$G(CD)
	S TOK(N,"raw")=$G(RAW)
	Q
ADDCOMM(TOK,N,RAW)
	S N=N+1
	S TOK(N,"t")="comm"
	S TOK(N,"raw")=$G(RAW)
	Q
TOK2RAW(TN,BS,BE) ; exact raw substring from tokens (prefers TOK(i,"raw"))
	N OUT,I,R,TYP
	S OUT=""
	I +$G(BS)<1 Q ""
	I +$G(BE)<BS Q ""
	F I=BS:1:BE D
	. S R=$$TOKGET(TN,I,"raw")
	. I R="" D  ; fallback for older tokens
	. . S TYP=$$TOKGET(TN,I,"t")
	. . I TYP="text" S R=$$TOKGET(TN,I,"v") Q
	. . ; last-resort: reconstruct approximately ( so it's safe if raw missing)
	. . S R=$$TOK2TPL(TN,I,I)
	. S OUT=OUT_R
	Q OUT
TOKPOS(TOK) ; annotate TOK(n,"line"), TOK(n,"col")
	N MAX,I,LINE,COL,RAW
	S MAX=+$G(TOK("meta","pmax")) I 'MAX S MAX=$$NUMMAX(.TOK) S TOK("meta","pmax")=MAX
	S LINE=1,COL=1
	F I=1:1:MAX D
	. S TOK(I,"line")=LINE
	. S TOK(I,"col")=COL
	. S RAW=$G(TOK(I,"raw"))
	. I RAW="" D  ; fallback
	. . I $G(TOK(I,"t"))="text" S RAW=$G(TOK(I,"v"))
	. ; advance cursor across RAW
	. D POSADV(.LINE,.COL,RAW)
	Q
POSADV(LINE,COL,S)
	N J,L,CH
	S S=$G(S),L=$L(S)
	F J=1:1:L D
	. S CH=$E(S,J)
	. I CH=$C(10) S LINE=LINE+1,COL=1 Q
	. S COL=COL+1
	Q
ERRSTACK(F,FSP,ROOTTPL,ERR)
	N N,IDX,PN,T
	K ERR("stack")
	S IDX=0
	I $G(ROOTTPL)'="" D
	. S IDX=IDX+1
	. S ERR("stack",IDX,"name")=ROOTTPL
	. S ERR("stack",IDX,"type")="root"
	F N=1:1:+$G(FSP) D
	. S PN=$G(F(N,"pname")) Q:PN=""
	. S IDX=IDX+1
	. S ERR("stack",IDX,"name")=PN
	. S T=$S($E(PN)=">":"partial",$E(PN)="<":"parent",1:"include")
	. S ERR("stack",IDX,"type")=T
	. S ERR("stack",IDX,"line")=+$G(F(N,"callLine"))
	. S ERR("stack",IDX,"col")=+$G(F(N,"callCol"))
	Q
	;
ERRATTACH(TN,I,F,FSP,ROOTTPL,ERR)
	N LN,CL,RAW
	I $G(TN)'="",+$G(I)>0 D
	. S LN=+$$TOKGET(TN,I,"line"),CL=+$$TOKGET(TN,I,"col")
	. I LN>0 S ERR("line")=LN,ERR("col")=CL
	. S RAW=$$TOKGET(TN,I,"raw") I RAW'="" S ERR("tag")=RAW
	D ERRSTACK(.F,.FSP,$G(ROOTTPL),.ERR)
	Q