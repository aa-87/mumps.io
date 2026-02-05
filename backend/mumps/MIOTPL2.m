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
; - START(CONF)
; - PRECOMPILE(CONF) ;
	; Precompile templates into ^MIO("TPL","CACHE",...).;
	; This improves cold-start latency and reduces first-request jitter.;
	; Strategy:
	; 1) If CONF("templates","precompile","path",n) exists, compile those paths.;
	; 2) Else enumerate common globs under template root (non-recursive best-effort).;
	;
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
ENUMGLOBS(ROOT,LIST) ;
	; Best-effort enumeration using common file globs.;
	; YottaDB supports $ZSEARCH for filesystem search with wildcards.;
	NEW P
	; Root-level pages and known folders (non-recursive).;
	DO ENUM1(ROOT_"/*.html",.LIST)
	DO ENUM1(ROOT_"/*.htm",.LIST)
	DO ENUM1(ROOT_"/pages/*.html",.LIST)
	DO ENUM1(ROOT_"/layouts/*.html",.LIST)
	DO ENUM1(ROOT_"/partials/*.html",.LIST)
	DO ENUM1(ROOT_"/includes/*.html",.LIST)
	QUIT
ENUM1(PAT,LIST) ;
	NEW F SET F=$ZSEARCH(PAT)
	FOR  QUIT:F=""  DO
	. SET LIST(F)=1
	. SET F=$ZSEARCH("")
	QUIT
RENDER(NAME,CONF,CTX,OUT,ERR) ;
	; Render a template to OUT() lines.;
	KILL OUT SET ERR=""
	NEW FP,OK,TOK
	SET OK=$$RESOLVE(NAME,.CONF,.FP,.ERR) IF 'OK QUIT 0
	SET OK=$$GETTOKFP(FP,.CONF,.TOK,.ERR) IF 'OK QUIT 0
	QUIT $$EVAL(.TOK,.CONF,.CTX,.OUT,.ERR)
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
RENDERLAYOUT(LAYOUT,CONF,CTX,OUT,ERR) ;
	; Render a layout that expects CTX("content") and CTX("blocks",...).;
	QUIT $$RENDER(LAYOUT,.CONF,.CTX,.OUT,.ERR)
GETTOK(NAME,CONF,TOK,ERR) ;
	NEW FP,OK
	SET OK=$$RESOLVE(NAME,.CONF,.FP,.ERR) IF 'OK QUIT 0
	QUIT $$GETTOKFP(FP,.CONF,.TOK,.ERR)
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
READFILE(FP,TXT,ERR) ;
	; Read the full file at FP into TXT as a single string.;
	; This must preserve newlines so templates compile correctly.;
	; NOTES
	; - READ without a length reads a line. We must loop to EOF.;
	; - We normalize line endings to LF.;
	KILL TXT SET ERR=""
	NEW $ETRAP SET $ETRAP="G RFERR^MIOTPL"
	NEW DEV SET DEV=FP
	NEW LINE,ACC
	SET ACC=""
	OPEN DEV:(readonly)
	USE DEV
	FOR  READ LINE QUIT:$ZEOF  DO
	. ; Normalize CRLF/CR to LF.;
	. IF $E(LINE,$L(LINE))=$C(13) SET LINE=$E(LINE,1,$L(LINE)-1)
	. SET ACC=ACC_LINE_$C(10)
	CLOSE DEV
	; Remove trailing LF added by loop, if present.;
	IF $L(ACC)>0,$E(ACC,$L(ACC))=$C(10) SET ACC=$E(ACC,1,$L(ACC)-1)
	SET TXT=ACC
	QUIT 1
RFERR ;
	SET ERR="template_read_failed:"_FP
	CLOSE DEV
	QUIT 0
RESOLVE(NAME,CONF,FP,ERR) ;
	; Resolve NAME into FP within template root.;
	NEW ROOT SET ROOT=$GET(CONF("server","templateDir")) IF ROOT="" SET ROOT="templates"
	SET ERR=""
	; Disallow path traversal.;
	IF NAME[".." SET ERR="template_invalid_name" QUIT 0
	SET FP=ROOT_"/"_NAME
	QUIT 1
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
	I 'TQ Q 0
	SET CTX("tplDepth")=D
	SET CTX("tplStack",D)=FP
	QUIT 1
POPDEPTH(CTX) ;
	NEW D SET D=+$GET(CTX("tplDepth"))
	IF D<1 QUIT
	KILL CTX("tplStack",D)
	SET D=D-1
	IF D=0 KILL CTX("tplDepth") QUIT
	SET CTX("tplDepth")=D
	QUIT
COMPILE(TXT,TOK,ERR) ;
	; Compile TXT into TOK() tokens.;
	; Token format:
	;   TOK(n,"t")="text"  TOK(n,"v")=...;
	;   TOK(n,"t")="var"   TOK(n,"k")=key TOK(n,"e")=1/0 (escape?)
	;   TOK(n,"t")="secS"  TOK(n,"k")=key TOK(n,"inv")=1/0
	;   TOK(n,"t")="secE"  TOK(n,"k")=key
	;   TOK(n,"t")="part"  TOK(n,"k")=name
	KILL TOK SET ERR=""
	NEW I,POS,START,END,CHUNK,N SET POS=1,N=0
	FOR  DO  QUIT:POS>$LENGTH(TXT)!(ERR'="")
	. SET START=$FIND(TXT,"{{",POS)
	. IF START=0 DO  QUIT
	. . SET CHUNK=$EXTRACT(TXT,POS,$LENGTH(TXT))
	. . IF CHUNK'="" SET N=N+1,TOK(N,"t")="text",TOK(N,"v")=CHUNK
	. . SET POS=$LENGTH(TXT)+1
	. ; text before tag
	. IF (START-3)>=POS DO
	. . SET CHUNK=$EXTRACT(TXT,POS,START-3)
	. . IF CHUNK'="" SET N=N+1,TOK(N,"t")="text",TOK(N,"v")=CHUNK
	. ; determine triple
	. IF $EXTRACT(TXT,START,START)="{" DO  ; triple mustache {{{key}}}
	. . SET END=$FIND(TXT,"}}}",START)
	. . IF END=0 SET ERR="template_unclosed_tag" QUIT
	. . NEW KEY SET KEY=$$TRIM($EXTRACT(TXT,START+1,END-4))
	. . SET N=N+1,TOK(N,"t")="var",TOK(N,"k")=KEY,TOK(N,"e")=0
	. . SET POS=END
	. ELSE  DO
	. . SET END=$FIND(TXT,"}}",START)
	. . IF END=0 SET ERR="template_unclosed_tag" QUIT
	. . NEW RAW SET RAW=$$TRIM($EXTRACT(TXT,START,END-3))
	. . NEW C0 SET C0=$EXTRACT(RAW,1)
	. . IF C0="#" DO  ; section start
	. . . NEW KEY SET KEY=$$TRIM($EXTRACT(RAW,2,$LENGTH(RAW)))
	. . . SET N=N+1,TOK(N,"t")="secS",TOK(N,"k")=KEY,TOK(N,"inv")=0
	. . ELSE  IF C0="^" DO  ; inverted section start
	. . . NEW KEY SET KEY=$$TRIM($EXTRACT(RAW,2,$LENGTH(RAW)))
	. . . SET N=N+1,TOK(N,"t")="secS",TOK(N,"k")=KEY,TOK(N,"inv")=1
	. . ELSE  IF C0="/" DO  ; section end
	. . . NEW KEY SET KEY=$$TRIM($EXTRACT(RAW,2,$LENGTH(RAW)))
	. . . SET N=N+1,TOK(N,"t")="secE",TOK(N,"k")=KEY
	. . ELSE  IF C0=">" DO  ; partial
	. . . NEW KEY SET KEY=$$TRIM($EXTRACT(RAW,2,$LENGTH(RAW)))
	. . . SET N=N+1,TOK(N,"t")="part",TOK(N,"k")=KEY
	. . ELSE  DO  ; normal var
	. . . SET N=N+1,TOK(N,"t")="var",TOK(N,"k")=RAW,TOK(N,"e")=1
	. . SET POS=END
	; validate sections stack
	NEW STK,SP SET SP=0
	FOR I=1:1:N DO  QUIT:ERR'=""
	. IF TOK(I,"t")="secS" SET SP=SP+1,STK(SP)=TOK(I,"k") QUIT
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
	; Supports:
	; - text, var, part, secS/secE (mustache sections), and legacy inc/b0/b1.;
	KILL OUT SET ERR=""
	NEW ACC SET ACC=""
	NEW S SET S=1
	NEW I SET I=0
	FOR  SET I=$ORDER(TOK(I)) QUIT:'I  DO  QUIT:ERR'=""
	. NEW TT SET TT=$GET(TOK(I,"t"))
	. IF TT="text" SET ACC=ACC_$GET(TOK(I,"v")) QUIT
	. IF TT="var" DO  QUIT
	. . NEW V SET V=$$LOOKUP(.CTX,$GET(TOK(I,"k")))
	. . IF $GET(TOK(I,"e"),1) SET V=$$ESC(V)
	. . SET ACC=ACC_V
	. IF TT="part" DO  QUIT
	. . NEW P SET P=$GET(TOK(I,"k"))
	. . DO DOINCLUDE(.P,.TOK,.CONF,.CTX,.ACC,.ERR)
	. IF TT="secS" DO  QUIT
	. . NEW KEY SET KEY=$GET(TOK(I,"k"))
	. . NEW INV SET INV=+$GET(TOK(I,"inv"))
	. . NEW OK SET OK=$$EVALSEC(.TOK,.CONF,.CTX,.I,KEY,INV,.ACC,.ERR)
	. . IF 'OK QUIT
	. IF TT="secE" QUIT
	. ; Legacy block capture tokens (kept for compatibility)
	. IF TT="b0" DO  QUIT
	. . NEW BNAME SET BNAME=$GET(TOK(I,"n"))
	. . NEW BOUT,OK SET OK=$$EVALBLOCK(.TOK,.CONF,.CTX,.I,BNAME,.BOUT,.ERR) IF 'OK QUIT
	. . SET CTX("blocks",BNAME)=$$JOIN(.BOUT)
	. IF TT="b1" QUIT
	DO SPLIT(.ACC,.OUT)
	QUIT 1
	;
DOINCLUDE(P,TOK,CONF,CTX,ACC,ERR) ;
	; Append rendered include to ACC.;
	NEW FP,OK,TTOK,TOUT
	SET OK=$$RESOLVE(P,.CONF,.FP,.ERR) IF 'OK QUIT
	SET OK=$$PUSHDEPTH(.CTX,.CONF,FP,.ERR) IF 'OK QUIT
	SET OK=$$GETTOKFP(FP,.CONF,.TTOK,.ERR)
	IF 'OK DO POPDEPTH(.CTX) QUIT
	SET OK=$$EVAL(.TTOK,.CONF,.CTX,.TOUT,.ERR)
	DO POPDEPTH(.CTX)
	IF 'OK QUIT
	SET ACC=ACC_$$JOIN(.TOUT)
	QUIT
	;
EVALSEC(TOK,CONF,CTX,IDX,KEY,INV,ACC,ERR) ;
	NEW I,DEPTH,DONE
	SET DEPTH=1,DONE=0
	KILL TMP
	SET J=0 
	SET I=IDX
	FOR  SET I=$ORDER(TOK(I)) QUIT:'I  QUIT:DONE  DO  QUIT:ERR'=""
	. NEW TT SET TT=$GET(TOK(I,"t"))
	. IF TT="secS",$GET(TOK(I,"k"))=KEY SET DEPTH=DEPTH+1 QUIT 
	. IF TT="secE",$GET(TOK(I,"k"))=KEY DO  QUIT
	. . SET DEPTH=DEPTH-1
	. . IF DEPTH=0 SET IDX=I,DONE=1 QUIT
	. ; Never include structural markers in body
	. IF TT="secS" QUIT
	. IF TT="secE" QUIT
	. ; Copy body tokens
	. SET J=J+1
	. MERGE TMP(J)=TOK(I)
	;
	IF ERR'="" QUIT 0
	;
	; block capture
	IF $E(KEY,1,6)="block:" QUIT $$CAPBLOCK(.TMP,.CONF,.CTX,KEY,.ACC,.ERR)
	;
	; missing node handling (single, clean)
	NEW REF,ISARR,OKN
	SET OKN=$$GETREF(.CTX,KEY,.REF,.ISARR)
	IF 'OKN DO  QUIT 1
	. IF INV DO
	. . NEW OUT,OK2 SET OK2=$$EVAL(.TMP,.CONF,.CTX,.OUT,.ERR) IF 'OK2 QUIT
	. . SET ACC=ACC_$$JOIN(.OUT)
	;
	; Mustache truthiness
	NEW HAS,VAL,TRUTH
	SET HAS=$$HASITEMS(.CTX,KEY)
	IF HAS SET TRUTH=1
	ELSE  DO
	. SET VAL=$$LOOKUP(.CTX,KEY)
	. SET TRUTH=$$ISTRUE(VAL)
	;
	IF INV SET TRUTH='TRUTH
	IF 'TRUTH QUIT 1
	;
	IF HAS QUIT $$EVALARR(.TMP,.CONF,.CTX,KEY,.ACC,.ERR)
	;
	NEW OUT,OK
	SET OK=$$EVAL(.TMP,.CONF,.CTX,.OUT,.ERR) IF 'OK QUIT 0
	SET ACC=ACC_$$JOIN(.OUT)
	QUIT 1
	;
CAPBLOCK(TMP,CONF,CTX,KEY,ACC,ERR) ;
	NEW NAME SET NAME=$E(KEY,7,$L(KEY))
	NEW OUT,OK SET OK=$$EVAL(.TMP,.CONF,.CTX,.OUT,.ERR) IF 'OK QUIT 0
	SET CTX("blocks",NAME)=$$JOIN(.OUT)
	; Block content is not appended to ACC.;
	QUIT 1 ;
EVALARR(TMP,CONF,CTX,KEY,ACC,ERR) ;
	NEW REF,ISARR
	IF '$$GETREF(.CTX,KEY,.REF,.ISARR) QUIT 0
	IF 'ISARR QUIT 1
	NEW BASE,I,ITEMREF
	SET BASE=$E(REF,1,$L(REF)-1)  ; strip trailing ")"
	SET I=0
	FOR  SET I=$ORDER(@(BASE_","_I_")")) QUIT:'I  DO
	. SET ITEMREF=BASE_","_I_")"
	. ;
	. NEW SCTX MERGE SCTX=CTX
	. SET SCTX(".")=$GET(@ITEMREF)
	. SET SCTX("item")=$GET(@ITEMREF)
	. IF $DATA(@ITEMREF)>1 MERGE SCTX=@ITEMREF
	. ;
	. NEW OUT,OK2
	. SET OK2=$$EVAL(.TMP,.CONF,.SCTX,.OUT,.ERR) IF 'OK2 QUIT
	. SET ACC=ACC_$$JOIN(.OUT)
	;
	IF ERR'="" QUIT 0
	QUIT 1
EVALARR2(TMP,CONF,CTX,REF,ACC,ERR) ;
	; REF is base reference like: CTX("cats","items") or CTX("packages")
	; We must iterate first-level subscripts reliably.;
	;
	; IMPORTANT:
	; - Use BASE without trailing ")"
	; - Use $ORDER on BASE_","""_I_""") so the first call is valid even when I=""
	;
	NEW BASE,I,ITEMREF
	SET BASE=$E(REF,1,$L(REF)-1)  ; REF like: CTX("cats","items")
	SET I=0
	NEW SUB
	SET SUB=BASE_","_I_")"
	FOR  SET I=$ORDER(@SUB) QUIT:'I  DO
	. SET SUB=BASE_","_I_")" 
	. SET ITEMREF=SUB
	. NEW SCTX MERGE SCTX=CTX
	. SET SCTX(".")=$GET(@ITEMREF)
	. SET SCTX("item")=$GET(@ITEMREF)
	. IF $DATA(@ITEMREF)>1 MERGE SCTX=@ITEMREF
	. NEW OUT,OK2
	. SET OK2=$$EVAL(.TMP,.CONF,.SCTX,.OUT,.ERR) IF 'OK2 QUIT
	. SET ACC=ACC_$$JOIN(.OUT)
	IF ERR'="" QUIT 0
	QUIT 1
	;	
ISTRUE(V) ;
	NEW X SET X=$GET(V)
	IF X="" QUIT 0
	IF X=0 QUIT 0
	QUIT 1
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
	QUIT 1
	;
GETREF(CTX,PATH,REF,ISARR) ;
	; Build REF (a string) pointing at CTX node for PATH.;
	; ISARR=1 if node has children, 0 otherwise.;
	NEW P,A,I
	SET REF="CTX"
	SET ISARR=0
	SET P=$GET(PATH)
	IF P="" QUIT 0
	FOR I=1:1:$L(P,".") DO
	. SET A=$PIECE(P,".",I)
	. IF A="" QUIT
	. IF A="." QUIT
	. SET REF=REF_"("""_A_""")" 
	I REF[""")("""  S REF=$$REPLACE^MIOUTIL(REF,""")(""",""",""")
	IF $DATA(@REF)>1 SET ISARR=1
	QUIT $DATA(@REF)>0	
	;
HASITEMS(CTX,KEY) ;
	; Returns 1 if KEY resolves to a node with at least one child subscript.;
	NEW REF,ISARR,BASE,S
	SET ISARR=0
	IF '$$GETREF(.CTX,KEY,.REF,.ISARR) QUIT 0
	IF 'ISARR QUIT 0
	; REF is like: CTX("packages") or CTX("cats","items")
	SET BASE=$E(REF,1,$L(REF)-1) ;strip trailing ")"
	SET S=$ORDER(@(BASE_",0)"))    ; first numeric child
	IF S'="" QUIT 1
	QUIT 0	
	;
HASCHILD(CTX,PATH) ;
		; Return 1 if PATH resolves to a node with children (array/object).;
	NEW REF,DATA
	IF '$$RESREF(.CTX,$GET(PATH),.REF,.DATA) QUIT 0
	IF DATA>1 QUIT 1
	QUIT 0
	;
RESREF(CTX,PATH,REF,DATA) ;
	; Resolve dot-path PATH into a string reference REF.;
	; DATA is set to $DATA(@REF).;
	;
	; Examples:
	;   PATH="packages"     => REF="CTX(""packages"")"
	;   PATH="cats.items"   => REF="CTX(""cats"",""items"")"
	;
	NEW P,A,I
	SET REF="",DATA=0
	SET P=$GET(PATH)
	IF P="" QUIT 0
	IF $E(P,1,7)="blocks." DO  QUIT 1
	. SET REF="CTX(""blocks"","""_$E(P,8,$L(P))_""")"
	. SET DATA=$DATA(@REF)
	IF P="." DO  QUIT 1
	. SET REF="CTX(""."")"
	. SET DATA=$DATA(@REF)
	SET REF="CTX"
	FOR I=1:1:$L(P,".") DO
	. SET A=$PIECE(P,".",I)
	. IF A="" QUIT
	. SET REF=REF_"("""_A_""")"
	I REF[""")("""  S REF=$$REPLACE^MIOUTIL(REF,""")(""",""",""")
	SET DATA=$DATA(@REF)
	QUIT 1
	;
LOOKUP(CTX,PATH) ;
	NEW P SET P=$GET(PATH)
	IF P="" QUIT ""
	IF P="." QUIT $GET(CTX("."))
	IF $E(P,1,7)="blocks." QUIT $GET(CTX("blocks",$E(P,8,$L(P))))
	NEW REF,ISARR,OK
	SET OK=$$GETREF(.CTX,P,.REF,.ISARR)
	IF 'OK QUIT ""
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