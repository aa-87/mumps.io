MIOTPL ; MIO template engine with layouts, blocks, partials, and caching.;
;
; PURPOSE
; Render HTML templates safely and fast.;
;
; TEMPLATE SYNTAX
; - {{var}}        HTML-escaped variable lookup.;
; - {{{var}}}      Unescaped variable lookup.;
; - {{> path}}     Partial include (path relative to template root).;
; - {{#block:n}}..{{/block:n}}  Capture block content into CTX("blocks",n).;
;
; PUBLIC ENTRY POINTS
;
	; Precompile templates into ^MIO("TPL","CACHE",...).;
	; This improves cold-start latency and reduces first-request jitter.;
START(CONF)
	NEW EN
	DO START^MIOTPLW(.CONF)
	SET EN=$S($GET(CONF("templates","precompileEnabled"))="true":1,1:+$GET(CONF("templates","precompileEnabled")))
	IF EN DO PRECOMPILE(.CONF)
	QUIT
	;
	; Strategy:
	; 1) If CONF("templates","precompile","path",n) exists, compile those paths.;
	; 2) Else enumerate common globs under template root (non-recursive best-effort).;
	;
PRECOMPILE(CONF) ;
	; Compile all templates under template root.;
	; This is intentionally minimal in pure M.;
	; Use the provided tooling to enumerate files and call GETTOKFP.;
	NEW ROOT SET ROOT=$GET(CONF("server","templateDir")) IF ROOT="" SET ROOT="templates"
	NEW LIST KILL LIST
	NEW I,PATH
	SET I=0
	FOR  SET I=$ORDER(CONF("templates","precompile","path",I)) QUIT:'I  DO
	. SET PATH=$GET(CONF("templates","precompile","path",I))
	. IF PATH'="" SET LIST(PATH)=1
	;
	IF '$DATA(LIST) DO ENUMGLOBS(ROOT,.LIST)
	;
	; Compile
	NEW FP,OK,TOK,ERR
	SET FP=""
	FOR  SET FP=$ORDER(LIST(FP)) QUIT:FP=""  DO
	. SET OK=$$GETTOKFP(FP,.CONF,.TOK,.ERR)
	. ; Do not fail whole precompile on a single file, but record last error.;
	. IF 'OK SET CONF("templates","precompile","lastError")=ERR
	QUIT
	;
ENUMGLOBS(ROOT,LIST) ;
	; Best-effort enumeration using common file globs.;
	; YottaDB supports $ZSEARCH for filesystem search with wildcards.;
	DO ENUM1(ROOT,"/*.html",.LIST)
	DO ENUM1(ROOT,"/*.htm",.LIST)
	DO ENUM1(ROOT,"/pages/*.html",.LIST)
	DO ENUM1(ROOT,"/layouts/*.html",.LIST)
	DO ENUM1(ROOT,"/partials/*.html",.LIST)
	DO ENUM1(ROOT,"/includes/*.html",.LIST)
	QUIT
	;
ENUM1(RT,PAT,LIST) ;
	NEW F,L
	FOR  SET F=$ZSEARCH(RT_PAT)  QUIT:F=""  DO
	. S L=$P(F,"/"_RT_"/",2,999)
	. S LIST(RT_"/"_L)=1 S ^LL(RT_"/"_L)=1
	QUIT
	;
RENDER(NAME,CONF,CTX,OUT,ERR) ;
	; Render a template to OUT() lines.;
	KILL OUT SET ERR=""
	NEW FP,OK,TOK
	SET OK=$$RESOLVE(NAME,.CONF,.FP,.ERR) IF 'OK QUIT 0
	SET OK=$$GETTOKFP(FP,.CONF,.TOK,.ERR) IF 'OK QUIT 0
	QUIT $$EVAL(.TOK,.CONF,.CTX,.OUT,.ERR)
	;
RENDERPAGE(PAGE,LAYOUT,CONF,CTX,OUT,ERR) ;
	; Render PAGE and inject into LAYOUT.;
	; Captures blocks from PAGE into CTX("blocks",name).;
	KILL OUT SET ERR=""
	NEW BCTX MERGE BCTX=CTX
	KILL BCTX("blocks")
	NEW BODY,OK
	SET OK=$$RENDER(PAGE,.CONF,.BCTX,.BODY,.ERR) IF 'OK QUIT 0
	; BODY includes page content excluding captured blocks.;
	SET BCTX("content")=$$JOIN(.BODY)
	; Render layout using content + blocks.;
	QUIT $$RENDER(LAYOUT,.CONF,.BCTX,.OUT,.ERR)
	;
RENDERLAYOUT(LAYOUT,CONF,CTX,OUT,ERR) ;
	; Render a layout that expects CTX("content") and CTX("blocks",...).;
	QUIT $$RENDER(LAYOUT,.CONF,.CTX,.OUT,.ERR)
	;
GETTOK(NAME,CONF,TOK,ERR) ;
	NEW FP,OK
	SET OK=$$RESOLVE(NAME,.CONF,.FP,.ERR) IF 'OK QUIT 0
	QUIT $$GETTOKFP(FP,.CONF,.TOK,.ERR)
	;
GETTOKFP(FP,CONF,TOK,ERR) ;
	; Load and compile a template by full path.;
	KILL TOK SET ERR=""
	NEW CH,WH,DEVW,OK,TXT,H
	SET DEVW=+$GET(CONF("templates","devWatchEnabled"))
	SET CH=$GET(^MIO("TPL","CACHE",FP,"H"))
	IF DEVW,CH'="" DO  IF $DATA(^MIO("TPL","CACHE",FP,"TOK",1)) DO  QUIT
	. SET WH=$GET(^MIO("TPL","FS",FP,"H"))
	. IF WH'="",WH=CH DO  QUIT
	. . MERGE TOK=^MIO("TPL","CACHE",FP,"TOK")
	; Fallback: read + hash
	SET OK=$$READFILE(FP,.TXT,.ERR) IF 'OK QUIT 0
	SET H=$$H32(TXT)
	IF CH'="",CH=H,$DATA(^MIO("TPL","CACHE",FP,"TOK",1)) DO  QUIT 1
	. MERGE TOK=^MIO("TPL","CACHE",FP,"TOK")
	; Compile
	NEW TMP KILL TMP
	SET OK=$$COMPILE(.TXT,.TMP,.ERR) IF 'OK QUIT 0
	KILL ^MIO("TPL","CACHE",FP)
	SET ^MIO("TPL","CACHE",FP,"H")=H
	MERGE ^MIO("TPL","CACHE",FP,"TOK")=TMP
	MERGE TOK=TMP
	QUIT 1
	;
READFILE(FP,TXT,ERR) ;
	; Read file into TXT (a single string).;
	; Pure M implementation using sequential READ.;
	KILL TXT SET ERR="" N TMP S TMP=""
	NEW $ETRAP SET $ETRAP="G RFERR^MIOTPL"
	NEW DEV SET DEV=FP
	OPEN DEV:(readonly)
	USE DEV F  READ TMP:2 Q:$ZEOF  Q:'$T  S TXT=$G(TXT)_TMP
	CLOSE DEV
	QUIT 1
RFERR ;
	SET ERR="template_read_failed:"_FP
	CLOSE FP
	QUIT 0
	;
RESOLVE(NAME,CONF,FP,ERR) ;
	; Resolve NAME into FP within template root.;
	NEW ROOT SET ROOT=$GET(CONF("server","templateDir")) IF ROOT="" SET ROOT="templates"
	SET ERR=""
	; Disallow path traversal.;
	IF NAME[".." SET ERR="template_invalid_name" QUIT 0
	SET FP=ROOT_"/"_NAME
	QUIT 1
	;
PUSHDEPTH(CTX,CONF,FP,ERR) ;
	; Enforce max render depth and prevent recursion.;
	; Uses CTX("tplDepth") and CTX("tplStack",n).;
	NEW D,MAX,I
	SET ERR=""
	SET D=+$GET(CTX("tplDepth"))+1
	SET MAX=+$GET(CONF("templates","maxRenderDepth")) IF MAX<1 SET MAX=32
	IF D>MAX SET ERR="template_max_depth_exceeded:"_MAX QUIT 0
	N TQ S TQ=1
	FOR I=1:1:D-1 IF $GET(CTX("tplStack",I))=FP SET ERR="template_recursion_detected:"_FP S TQ=0
	I 'TQ QUIT 0
	SET CTX("tplDepth")=D
	SET CTX("tplStack",D)=FP
	QUIT 1
	;
POPDEPTH(CTX) ;
	NEW D SET D=+$GET(CTX("tplDepth"))
	IF D<1 QUIT
	KILL CTX("tplStack",D)
	SET D=D-1
	IF D=0 KILL CTX("tplDepth") QUIT
	SET CTX("tplDepth")=D
	QUIT
	;
TEST
	NEW TXT,TOK,ERR,OK
	SET TXT="Hello {{> partials/x.html}} World"
	SET OK=$$COMPILE^MIOTPL(TXT,.TOK,.ERR)
	;DO OK^MIOTASSERT(OK,"compile")
	NEW I,FND SET (I,FND)=0
	FOR  SET I=$ORDER(TOK(I)) QUIT:'I  DO
	. IF $GET(TOK(I,"t"))="inc" SET FND=1
	;DO OK^MIOTASSERT(FND,"found inc token")
	W FND
	QUIT
	;	
	;	
	;	
	;	
COMPILE(TXT,TOK,ERR)
	; Token format:
	;   TOK(n,"t")="text"  TOK(n,"v")=...;
	;   TOK(n,"t")="var"   TOK(n,"k")=key TOK(n,"e")=1/0 (escape?)
	;   TOK(n,"t")="secS"  TOK(n,"k")=key TOK(n,"inv")=1/0
	;   TOK(n,"t")="secE"  TOK(n,"k")=key
	;   TOK(n,"t")="part"  TOK(n,"k")=name
	KILL TOK SET ERR=""
	NEW I,POS,START,END,CHUNK,N SET POS=1,N=0
	FOR  DO  QUIT:POS>$LENGTH(TXT)
	. SET START=$FIND(TXT,"{{",POS)
	. IF START=0 DO  QUIT
	. . SET N=N+1,TOK(N,"t")="text",TOK(N,"v")=$EXTRACT(TXT,POS,$LENGTH(TXT))
	. . SET POS=$LENGTH(TXT)+1
	. ; text before tag
	. IF START-3>=POS DO 
	. . SET CHUNK=$EXTRACT(TXT,POS,START-3)
	. . IF CHUNK'="" SET N=N+1,TOK(N,"t")="text",TOK(N,"v")=CHUNK
	. ; determine triple
	. IF $EXTRACT(TXT,START,START)="{" DO  ; triple {{{
	. . ; triple mustache {{{key}}}
	. . SET END=$FIND(TXT,"}}}",START)
	. . IF END=0 SET ERR="template_unclosed_tag" QUIT
	. . NEW KEY SET KEY=$$TRIM($EXTRACT(TXT,START+1,END-4))
	. . SET N=N+1,TOK(N,"t")="var",TOK(N,"k")=KEY,TOK(N,"e")=0
	. . SET POS=END
	. ELSE  DO  ; double {{
	. . SET END=$FIND(TXT,"}}",START)
	. . IF END=0 SET ERR="template_unclosed_tag" QUIT
	. . NEW RAW SET RAW=$$TRIM($EXTRACT(TXT,START,END-3))
	. . NEW C0 SET C0=$EXTRACT(RAW,1)
	. . IF C0="#" DO  ; section start
	. . . NEW KEY SET KEY=$$TRIM($EXTRACT(RAW,2,$LENGTH(RAW)))
	. . . SET N=N+1,TOK(N,"t")="secS",TOK(N,"k")=KEY,TOK(N,"inv")=0
	. . IF C0="^" DO  ; inverted section start
	. . . NEW KEY SET KEY=$$TRIM($EXTRACT(RAW,2,$LENGTH(RAW)))
	. . . SET N=N+1,TOK(N,"t")="secS",TOK(N,"k")=KEY,TOK(N,"inv")=1
	. . IF C0="/" DO  ; section end
	. . . NEW KEY SET KEY=$$TRIM($EXTRACT(RAW,2,$LENGTH(RAW)))
	. . . SET N=N+1,TOK(N,"t")="secE",TOK(N,"k")=KEY
	. . IF C0=">" DO  ; partial/include
	. . . NEW KEY SET KEY=$$TRIM($EXTRACT(RAW,2,$LENGTH(RAW)))
	. . . SET N=N+1,TOK(N,"t")="inc",TOK(N,"p")=KEY
	. . IF C0'="#",C0'="^",C0'="/",C0'=">" DO  ; normal var
	. . . SET N=N+1,TOK(N,"t")="var",TOK(N,"k")=RAW,TOK(N,"e")=1
	. . SET POS=END
	IF ERR'="" QUIT 0
	; validate sections stack
	NEW STK,SP SET SP=0
	FOR I=1:1:N DO
	. IF TOK(I,"t")="secS" SET SP=SP+1,STK(SP)=TOK(I,"k")
	. IF TOK(I,"t")="secE" DO
	. . IF SP=0 SET ERR="template_unexpected_section_end:"_TOK(I,"k") QUIT
	. . IF STK(SP)'=TOK(I,"k") SET ERR="template_section_mismatch:"_STK(SP)_"!="_TOK(I,"k") QUIT
	. . SET SP=SP-1
	IF ERR'="" QUIT 0
	IF SP>0 SET ERR="template_unclosed_section:"_STK(SP) QUIT 0
	QUIT 1
	;
EVAL(TOK,CONF,CTX,OUT,ERR) ;
	; Evaluate tokens to OUT() lines.;
	KILL OUT SET ERR=""
	NEW ACC SET ACC=""
	NEW I SET I=0
	FOR  SET I=$ORDER(TOK(I)) QUIT:'I  DO  QUIT:ERR'=""
	. NEW TT SET TT=$GET(TOK(I,"t"))
	. IF TT="text" SET ACC=ACC_$GET(TOK(I,"v")) QUIT
	. IF TT="var" DO  QUIT
	. . NEW V SET V=$$LOOKUP(.CTX,$GET(TOK(I,"k")))
	. . ;IF '$GET(TOK(I,"raw")) SET V=$$ESC(V)
	. . SET ACC=ACC_V
	. IF TT="inc" DO  QUIT
	. . NEW P SET P=$GET(TOK(I,"p"))
	. . NEW FP,OK,TTOK,TOUT
	. . SET OK=$$RESOLVE(P,.CONF,.FP,.ERR) IF 'OK QUIT
	. . DO EDGE(.CTX,$GET(CTX("tplStack",+$GET(CTX("tplDepth")))),FP,.ERR)
	. . SET OK=$$PUSHDEPTH(.CTX,.CONF,FP,.ERR) IF 'OK QUIT
	. . SET OK=$$GETTOKFP(FP,.CONF,.TTOK,.ERR) IF 'OK DO POPDEPTH(.CTX) QUIT
	. . SET OK=$$EVAL(.TTOK,.CONF,.CTX,.TOUT,.ERR) DO POPDEPTH(.CTX) IF 'OK QUIT
	. . SET ACC=ACC_$$JOIN(.TOUT)
	. IF TT="b0" DO  QUIT
	. . NEW BNAME SET BNAME=$GET(TOK(I,"n"))
	. . NEW BOUT,OK SET OK=$$EVALBLOCK(.TOK,.CONF,.CTX,.I,BNAME,.BOUT,.ERR) IF 'OK QUIT
	. . SET CTX("blocks",BNAME)=$$JOIN(.BOUT)
	. IF TT="b1" QUIT  ; handled by EVALBLOCK
	DO SPLIT(.ACC,.OUT)
	QUIT 1
	;
	;
EVALBLOCK(TOK,CONF,CTX,IDX,BNAME,OUT,ERR) ;
	; Called when TOK(IDX) is b0. Consumes until matching b1.;
	KILL OUT SET ERR=""
	NEW DEPTH SET DEPTH=1
	NEW I SET I=IDX
	NEW TMP KILL TMP
	NEW J SET J=0
	FOR  SET I=$ORDER(TOK(I)) QUIT:'I  DO  QUIT:ERR'=""
	. NEW TT SET TT=$GET(TOK(I,"t"))
	. IF TT="b0",$GET(TOK(I,"n"))=BNAME SET DEPTH=DEPTH+1 QUIT
	. IF TT="b1",$GET(TOK(I,"n"))=BNAME DO  QUIT
	. . SET DEPTH=DEPTH-1
	. . IF DEPTH=0 SET IDX=I QUIT
	. . QUIT
	. IF DEPTH>0 DO
	. . SET J=J+1
	. . MERGE TMP(J)=TOK(I)
	IF ERR'="" QUIT 0
	NEW OK SET OK=$$EVAL(.TMP,.CONF,.CTX,.OUT,.ERR)
	QUIT OK
	;
EDGE(CTX,FROM,TO,ERR) ;
	; Record include edge and detect cycles.;
	; We still rely primarily on PUSHDEPTH stack check.;
	;
	; CTX("tplEdge",from,to)=1 is request-local.;
	IF $GET(FROM)'=""&($GET(TO)'="") SET CTX("tplEdge",FROM,TO)=1
	QUIT
	;
LOOKUP(CTX,PATH) ;
	; Dot-path lookup in CTX or CTX("blocks").;
	NEW P SET P=$GET(PATH)
	IF P="" QUIT ""
	IF $E(P,1,7)="blocks." QUIT $GET(CTX("blocks",$E(P,8,$L(P))))
	NEW A,I,REF
	SET REF="CTX"
	FOR I=1:1:$L(P,".") DO
	. SET A=$PIECE(P,".",I)
	. IF A="" QUIT
	. SET REF=REF_"("""_A_""")"
	QUIT $GET(@REF)
	;
JOIN(ARR,SEP) ;
	; Join numeric ARR() into string.;
	NEW S SET S=""
	NEW D SET D=$GET(SEP) IF D="" SET D=$C(10)
	NEW I SET I=0
	FOR  SET I=$ORDER(ARR(I)) QUIT:'I  DO
	. IF S'="" SET S=S_D
	. SET S=S_$GET(ARR(I))
	QUIT S
	;
SPLIT(STR,OUT) ;
	; Split STR by LF into OUT() lines.;
	KILL OUT
	NEW POS,NEXT,LINE,IDX
	SET POS=1,IDX=0
	FOR  DO  QUIT:POS>$L(STR)
	. SET NEXT=$F(STR,$C(10),POS)
	. IF NEXT=0 DO
	. . SET LINE=$E(STR,POS,$L(STR))
	. . SET IDX=IDX+1,OUT(IDX)=LINE
	. . SET POS=$L(STR)+1
	. ELSE  DO
	. . SET LINE=$E(STR,POS,NEXT-2)
	. . SET IDX=IDX+1,OUT(IDX)=LINE
	. . SET POS=NEXT
	QUIT
	;
TRIM(S) ;
	; Trim leading and trailing whitespace (space, tab, CR, LF).;
	NEW X SET X=$GET(S)
	FOR  QUIT:X=""  QUIT:($E(X,1)'=" ")&($E(X,1)'=$C(9))&($E(X,1)'=$C(10))&($E(X,1)'=$C(13))  SET X=$E(X,2,$L(X))
	FOR  QUIT:X=""  QUIT:($E(X,$L(X))'=" ")&($E(X,$L(X))'=$C(9))&($E(X,$L(X))'=$C(10))&($E(X,$L(X))'=$C(13))  SET X=$E(X,1,$L(X)-1)
	QUIT X
	;
ESC(S) ;
	; Escape basic HTML entities.;
	NEW X SET X=$GET(S)
	SET X=$$REPL(X,"&","&amp;")
	SET X=$$REPL(X,"<","&lt;")
	SET X=$$REPL(X,">","&gt;")
	SET X=$$REPL(X,"""","&quot;")
	SET X=$$REPL(X,"'","&#39;")
	QUIT X
	;
REPL(S,A,B) ;
	NEW X SET X=$GET(S)
	NEW P SET P=1
	NEW OUT SET OUT=""
	NEW F
	FOR  DO  QUIT:P>$L(X)
	. SET F=$F(X,A,P)
	. IF F=0 DO  QUIT
	. . SET OUT=OUT_$E(X,P,$L(X))
	. . SET P=$L(X)+1
	. SET OUT=OUT_$E(X,P,F-$L(A)-1)_B
	. SET P=F
	QUIT OUT
	;
H32(S) ;
	; Simple 32-bit FNV-1a hash for change detection.;
	;FNV-1a (Fowler–Noll–Vo) is a fast, non-cryptographic hash function designed 
	;for high dispersion and low collision rates, ideal for hash tables, checksums, 
	;and data deduplication. It operates by XORing each byte of input data with 
	;the hash value, followed by a multiplication with a prime number. It is 
	;particularly effective for hashing nearly identical strings like URLs, 
	;hostnames, and IP addresses.;
	NEW I,H,C
	SET H=2166136261
	FOR I=1:1:$L(S) DO
	. SET C=$ASCII($E(S,I))
	. SET H=$$BXOR(H,C)
	. SET H=$$MULMOD(H,16777619)
	QUIT H
	;
MULMOD(A,B) ;
	; 32-bit multiply modulo 2^32.;
	NEW X SET X=(A*B)#4294967296
	QUIT X
	;
BXOR(A,B) ;
	; Portable XOR for small integers (0..2^32-1).;
	NEW I,RA,RB,OUT,P
	SET OUT=0,P=1
	FOR I=1:1:32 DO
	. SET RA=A#2,RB=B#2
	. IF (RA+RB)=1 SET OUT=OUT+P
	. SET A=A\2,B=B\2,P=P*2
	QUIT OUT
	;