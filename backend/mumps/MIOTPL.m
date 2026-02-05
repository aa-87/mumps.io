MIOTPL ; MIO template engine with layouts, blocks, partials, and caching.;
;
	; MUMPS.IO - Mustache/Handlebars-compatible template engine (YottaDB/GT.M)
	; ---------------------------------------------------------------------------
	; Drop-in replacement for prior MIOTPL.m
	;
	; Design goals:
	; - Correct Mustache semantics (variables, sections, inverted sections, partials).;
	; - Compatible with the subset of Handlebars-like behavior used by existing templates.;
	; - Stable evaluator (no double-render, no recursive blow-ups).;
	; - Fast: compile once, cache tokens in ^MIO("TPL","CACHE",FP,...).;
	;
	; Public entry points (required):
	;   START(CONF)
	;   PRECOMPILE(CONF)
	;   RENDER(NAME,CONF,CTX,OUT,ERR)
	;   RENDERPAGE(PAGE,LAYOUT,CONF,CTX,OUT,ERR)
	;   RENDERLAYOUT(LAYOUT,CONF,CTX,OUT,ERR)
	;   GETTOK(NAME,CONF,TOK,ERR)
	;   GETTOKFP(FP,CONF,TOK,ERR)
	;
	; Token model (must match):
	;   TOK(n,"t") in {text,var,secS,secE,part}
	;   text: TOK(n,"v")
	;   var:  TOK(n,"k") key, TOK(n,"e") 1/0 escape
	;   secS: TOK(n,"k") key, TOK(n,"inv") 1/0 inverted
	;   secE: TOK(n,"k") key
	;   part: TOK(n,"k") name
	;
	; Additional internal fields (safe additions):
	;   TOK(n,"m") = matching secE index for secS
	;   TOK(n,"blk") = 1 if this is a block section (block:name)
	;   TOK(n,"bname") = block name (name after "block:")
	;
	; Globals:
	;   ^MIO("TPL","CACHE",FP,"H") = 32-bit hash of file content
	;   ^MIO("TPL","CACHE",FP,"TOK",n,...) = cached tokens
	;
	; ---------------------------------------------------------------------------
	;
	Q
	;
; =============================================================================
; START(CONF)
; Initialize template subsystem. Safe to call multiple times.;
; =============================================================================
START(CONF)
	; Ensure base nodes exist. Do not wipe cache here.;
	I '$D(^MIO("TPL")) S ^MIO("TPL")=1
	I '$D(^MIO("TPL","CACHE")) S ^MIO("TPL","CACHE")=1
	Q
	;
; =============================================================================
; PRECOMPILE(CONF)
; Compile selected templates into cache.;
; This is intentionally conservative for production safety.;
; If CONF("templates","precompile",NAME)=1 is provided, compile those.;
; =============================================================================
PRECOMPILE(CONF)
	N NAME,ERR,TOK
	S NAME=""
	F  S NAME=$O(CONF("templates","precompile",NAME)) Q:NAME=""  D
	. K ERR,TOK
	. D GETTOK(NAME,.CONF,.TOK,.ERR)
	Q
	;
; =============================================================================
; RENDER(NAME,CONF,CTX,OUT,ERR)
; Render a template by name into OUT (scalar string).;
; CTX is passed by reference and may be read/written (blocks/page flow uses it).;
; =============================================================================
RENDER(NAME,CONF,CTX,OUT,ERR)
	K ERR S OUT=""
	N TOK
	D GETTOK(NAME,.CONF,.TOK,.ERR) Q:$D(ERR)
	D EVAL(.TOK,.CONF,.CTX,.OUT,.ERR)
	Q
	;
; =============================================================================
; RENDERPAGE(PAGE,LAYOUT,CONF,CTX,OUT,ERR)
; Render PAGE capturing blocks, set CTX("content"), then render layout.;
; Layout flow:
;   - Render page template with block capture enabled.;
;   - Store rendered page output into CTX("content").;
;   - Render layout template (which may place {{content}} and blocks).;
; =============================================================================
RENDERPAGE(PAGE,LAYOUT,CONF,CTX,OUT,ERR)
	K ERR S OUT=""
	N PAGEOUT
	; Reset blocks for this page render.;
	K CTX("blocks")
	S CTX("content")=""
	D RENDER(PAGE,.CONF,.CTX,.PAGEOUT,.ERR) Q:$D(ERR)
	; Page output is typically not directly emitted by page templates if they only
	; define blocks, but we still capture whatever they produced.;
	S CTX("content")=PAGEOUT
	D RENDERLAYOUT(LAYOUT,.CONF,.CTX,.OUT,.ERR)
	Q
	;
; =============================================================================
; RENDERLAYOUT(LAYOUT,CONF,CTX,OUT,ERR)
; Render layout template using current CTX (must include CTX("content") usually).;
; =============================================================================
RENDERLAYOUT(LAYOUT,CONF,CTX,OUT,ERR)
	K ERR S OUT=""
	D RENDER(LAYOUT,.CONF,.CTX,.OUT,.ERR)
	Q
	;
; =============================================================================
; GETTOK(NAME,CONF,TOK,ERR)
; Compile template by logical name.;
; - Resolves NAME to a file path under template root.;
; - Prevents path traversal.;
; =============================================================================
GETTOK(NAME,CONF,TOK,ERR)
	K ERR K TOK
	N FP
	S FP=$$NAME2FP(NAME,.CONF,.ERR) Q:$D(ERR)
	D GETTOKFP(FP,.CONF,.TOK,.ERR)
	Q
	;
; =============================================================================
; GETTOKFP(FP,CONF,TOK,ERR)
; Compile template by file path.;
; - Uses cache hash ^MIO("TPL","CACHE",FP,"H")
; - Stores tokens under ^MIO("TPL","CACHE",FP,"TOK",...)
; - Respects CONF("templates","devWatchEnabled")
; =============================================================================
GETTOKFP(FP,CONF,TOK,ERR)
	K ERR K TOK
	N DEVWATCH S DEVWATCH=+$G(CONF("templates","devWatchEnabled"))
	N TEXT,NEW H
	S TEXT=$$READFILE(FP,.ERR) Q:$D(ERR)
	S H=$$H32(TEXT)
	; If cached and devWatch disabled, always reuse tokens if present.;
	I 'DEVWATCH,$D(^MIO("TPL","CACHE",FP,"TOK",1)) D  Q
	. D LOADTOK(FP,.TOK)
	; If devWatch enabled, reuse only if hash matches.;
	I DEVWATCH,$G(^MIO("TPL","CACHE",FP,"H"))=H,$D(^MIO("TPL","CACHE",FP,"TOK",1)) D  Q
	. D LOADTOK(FP,.TOK)
	; Compile and cache.;
	N LTOK
	D PARSE(TEXT,.LTOK,.ERR) Q:$D(ERR)
	D LINKSECS(.LTOK,.ERR) Q:$D(ERR)
	; Store into global cache.;
	K ^MIO("TPL","CACHE",FP,"TOK")
	M ^MIO("TPL","CACHE",FP,"TOK")=LTOK
	S ^MIO("TPL","CACHE",FP,"H")=H
	; Return in TOK.;
	M TOK=LTOK
	Q
	;
; =============================================================================
; Internal: LOADTOK(FP,TOK)
; =============================================================================
LOADTOK(FP,TOK)
	K TOK
	M TOK=^MIO("TPL","CACHE",FP,"TOK")
	Q
	;
; =============================================================================
; Internal: NAME2FP(NAME,CONF,ERR)
; Resolve template logical name into file path under root.;
; - Prevents traversal: no "..", no ":".;
; - Allows subfolders "repo/browser/page".;
; - Adds default extension if missing.;
; =============================================================================
NAME2FP(NAME,CONF,ERR)
	N ROOT,EXT,NM,FP
	K ERR
	S ROOT=$G(CONF("templates","root"))
	I ROOT="" S ROOT="templates/"
	I $E(ROOT,$L(ROOT))'="/" S ROOT=ROOT_"/"
	S EXT=$G(CONF("templates","ext"))
	I EXT="" S EXT=".mustache"
	S NM=NAME
	; Normalize backslashes to slashes for safety/consistency.;
	S NM=$TR(NM,"\","/")
	; Block obvious traversal / absolute / device patterns.;
	I NM[".." S ERR("code")="TPL_TRAVERSAL",ERR("msg")="Path traversal '..' is not allowed." Q ""
	I NM[":" S ERR("code")="TPL_TRAVERSAL",ERR("msg")="Device/path ':' is not allowed." Q ""
	I $E(NM,1)="/" S ERR("code")="TPL_TRAVERSAL",ERR("msg")="Absolute paths are not allowed." Q ""
	; Add extension if missing.;
	I NM'["." S NM=NM_EXT
	S FP=ROOT_NM
	Q FP
	;
; =============================================================================
; Internal: READFILE(FP,ERR)
; Read entire file into a single string.;
; Production-safe: detects missing file, limits worst-case memory blow-ups.;
; =============================================================================
READFILE(FP,ERR)
	N IO,LINE,MAX,TXT
	K ERR
	S TXT=""
	; Safety limit: 2 MB (adjustable via CONF later if needed).;
	S MAX=2*1024*1024
	I '$$FILEEXISTS(FP) S ERR("code")="TPL_NOFILE",ERR("msg")="Template file not found: "_FP Q ""
	O FP:(READONLY:REWIND:EXCEPTION="GOTO RFERR")
	U FP
	F  R LINE Q:$ZEOF  D  Q:$D(ERR)
	. ; Keep newlines. Most templates expect them.;
	. S TXT=TXT_LINE_$C(10)
	. I $L(TXT)>MAX S ERR("code")="TPL_TOOLARGE",ERR("msg")="Template too large (limit 2MB): "_FP
	C FP
	Q TXT
	;
RFERR ;
	C FP
	S ERR("code")="TPL_IO",ERR("msg")="I/O error reading template: "_FP
	Q ""
	;
; =============================================================================
; Internal: FILEEXISTS(FP)
; Portable-ish file existence check for GT.M/YottaDB.;
; =============================================================================
FILEEXISTS(FP)
	; $ZSEARCH returns "" if not found.;
	N X S X=$ZSEARCH(FP)
	Q $S(X'="":1,1:0)
; =============================================================================
;  PARSE + LINKSECS
; =============================================================================
COMPILE(TEXT,TOK,ERR) ;
	DO PARSE^MIOTPL(.TEXT,.TOK,.ERR)
	D:'$D(ERR) LINKSECS^MIOTPL(.TOK,.ERR)
	Q 
; =============================================================================
; PARSE(TEXT,TOK,ERR)
; Mustache parser -> token list.;
; Supported tags:
;   {{var}} escaped
;   {{{var}}} unescaped
;   {{& var}} unescaped
;   {{#key}} section start
;   {{^key}} inverted section start
;   {{/key}} section end
;   {{> partial}} partial
;   {{! comment}} ignored
; Handlebars-like subset compatibility:
;   {{#if key}} treated like {{#key}}
;   {{#each key}} treated like {{#key}}
;   {{#unless key}} treated like inverted {{^key}}
; =============================================================================
PARSE(TEXT,TOK,ERR)
	K ERR K TOK
	N I,L,POS,OPEN,CLOSE,PRE,INSIDE,RAW,TRI,END3
	N N S N=0
	S L=$L(TEXT),POS=1
	F  Q:POS>L  D  Q:$D(ERR)
	. S OPEN=$F(TEXT,"{{",POS)
	. I 'OPEN D  Q
	. . ; Remaining tail is text.;
	. . S PRE=$E(TEXT,POS,L)
	. . I PRE'="" D ADDTXT(.TOK,.N,PRE)
	. . S POS=L+1
	. ; Text before tag.;
	. S PRE=$E(TEXT,POS,OPEN-3)
	. I PRE'="" D ADDTXT(.TOK,.N,PRE)
	. ; Triple mustache?
	. S TRI=0
	. I $E(TEXT,OPEN,OPEN)="{",$E(TEXT,OPEN+1,OPEN+1)="{",$E(TEXT,OPEN+2,OPEN+2)="{" D
	. . ; This means we saw "{{" then next char is "{", so actually "{{{"
	. . S TRI=1
	. I TRI D  Q
	. . ; Find "}}}"
	. . SET END3=$F(TEXT,"}}}",OPEN)
	. . I 'END3 S ERR("code")="TPL_PARSE",ERR("msg")="Unclosed triple mustache." Q
	. . SET RAW=$E(TEXT,OPEN+1,END3-4) ; inside {{{ ... }}}
	. . S RAW=$$TRIM(RAW)
	. . D ADDVAR(.TOK,.N,RAW,0)
	. . S POS=END3
	. ; Normal mustache "{{ ... }}"
	. S CLOSE=$F(TEXT,"}}",OPEN)
	. I 'CLOSE S ERR("code")="TPL_PARSE",ERR("msg")="Unclosed mustache tag." Q
	. S INSIDE=$E(TEXT,OPEN,CLOSE-3) ; inside {{ ... }}
	. S INSIDE=$$TRIM(INSIDE)
	. ; Comments
	. I $E(INSIDE,1)="!" S POS=CLOSE Q
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
	. ; Default: variable escaped.;
	. D ADDVAR(.TOK,.N,INSIDE,1)
	. S POS=CLOSE
	Q
	;
ADDTXT(TOK,N,VAL)
	S N=N+1
	S TOK(N,"t")="text"
	S TOK(N,"v")=VAL
	Q
	;
ADDVAR(TOK,N,KEY,ESC)
	S N=N+1
	S TOK(N,"t")="var"
	S TOK(N,"k")=KEY
	S TOK(N,"e")=+$G(ESC)
	Q
	;
ADDSECS(TOK,N,KEY,INV)
	S N=N+1
	S TOK(N,"t")="secS"
	S TOK(N,"k")=KEY
	S TOK(N,"inv")=+$G(INV)
	Q
	;
ADDSECE(TOK,N,KEY)
	S N=N+1
	S TOK(N,"t")="secE"
	S TOK(N,"k")=KEY
	Q
	;
ADDPART(TOK,N,NAME)
	S N=N+1
	S TOK(N,"t")="part"
	S TOK(N,"k")=NAME
	Q
	;
; =============================================================================
; LINKSECS(TOK,ERR)
; Precompute matching indices for sections.;
; - TOK(i,"m") stored on secS token to point to matching secE index.;
; - Detect mismatches early.;
; =============================================================================
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
; =============================================================================
; EVAL(TOK,CONF,CTX,OUT,ERR)
; Iterative evaluator using an explicit frame stack.;
; This prevents:
; - double-render of sections
; - recursion blow-ups
; - losing nested markers
;
; Frame fields:
;   F(n,"tok") = reference name of token array ("TOK" local or "PTOK" local)
;   F(n,"i")   = current token index
;   F(n,"end") = end token index (inclusive)
;   F(n,"ctxTop") = numeric pointer into context stack
;   F(n,"mode")   = "emit" or "capture"
;   F(n,"capRef") = reference to capture destination (for blocks)
;
; Context stack holds references (strings) to nodes:
;   CST(1)="CTX"
;   CST(2)="$NA(CTX(""groups"",""items"",1))" etc (stored as actual ref strings)
; We store as fully-qualified $NA strings, then use indirection with subscripts.;
; =============================================================================
EVAL(TOK,CONF,CTX,OUT,ERR)
	K ERR,CAP
	N CST,CTSP
	S CTSP=1
	S CST(1)="CTX"
	;
	; Partial recursion protection.;
	N PDEPTHMAX S PDEPTHMAX=+$G(CONF("templates","maxPartialDepth")) I PDEPTHMAX<1 S PDEPTHMAX=20
	N PACTIVE ; PACTIVE(name)=count
	;
	; Frame stack.;
	N FSP,F
	S FSP=1
	S F(1,"i")=1
	S F(1,"end")=$O(TOK(""),-1)
	S F(1,"ctxTop")=CTSP
	S F(1,"mode")="emit"
	S OUT=""
	;
	; Hard safety limit for total frames to prevent pathological loops.;
	N FRAMELIM S FRAMELIM=2000
	N FRAMES S FRAMES=0
	;
	; Main loop.;
	F  Q:FSP<1  D  Q:$D(ERR)
	. S FRAMES=FRAMES+1
	. I FRAMES>FRAMELIM S ERR("code")="TPL_LIMIT",ERR("msg")="Render exceeded safety frame limit." Q
	 . ; Iterator frames do not use TOK(i,"t"). Run them first.;
	. I $G(F(FSP,"mode"))="iter" D  Q
	. . N LREF,SUB,BS,BE,PM,PC
	. . S LREF=$G(F(FSP,"listRef"))
	. . S SUB=$G(F(FSP,"sub"))
	. . S BS=+$G(F(FSP,"bodyS"))
	. . S BE=+$G(F(FSP,"bodyE"))
	. . S PM=$G(F(FSP,"parentMode"))
	. . S PC=$G(F(FSP,"parentCap"))
	. . ; next item
	. . S SUB=$O(@($$APPREF(LREF,SUB)))
	. . I SUB="" D POPF(.FSP,.F,.CST,.CTSP) Q
	. . S F(FSP,"sub")=SUB
	. . N ITEMREF S ITEMREF=$$APPREF(LREF,SUB)
	. . ; push item context and render body
	. . N NEWTOP S NEWTOP=CTSP+1
	. . S CST(NEWTOP)=ITEMREF,CTSP=NEWTOP
	. . D PUSHFRAME(.FSP,.F,.TOK,BS,BE,CTSP,PM,PC)
	. N I,END,TYP
	. S I=+$G(F(FSP,"i"))
	. S END=+$G(F(FSP,"end"))
	. I I<1!(I>END) D POPF(.FSP,.F,.CST,.CTSP) Q
	. S TYP=$G(TOK(I,"t"))
	. I TYP="text" D  Q
	. . D EMIT(.FSP,.F,.OUT,$G(TOK(I,"v")))
	. . S F(FSP,"i")=I+1
	. I TYP="var" D  Q
	. . N KEY,ESC,VAL
	. . S KEY=$G(TOK(I,"k")),ESC=+$G(TOK(I,"e"))
	. . S VAL=$$RESVAL(KEY,.CST,CTSP)
	. . I ESC S VAL=$$ESCHTML(VAL)
	. . D EMIT(.FSP,.F,.OUT,VAL)
	. . S F(FSP,"i")=I+1
	. I TYP="part" D  Q
	. . N PN S PN=$G(TOK(I,"k"))
	. . ; Prevent traversal in partial names too.;
	. . N PERR,FP
	. . S FP=$$NAME2FP(PN,.CONF,.PERR)
	. . I $D(PERR) S ERR=PERR Q
	. . ; Recursion control by name (logical).;
	. . I $G(PACTIVE(PN))'<0 S PACTIVE(PN)=+$G(PACTIVE(PN))
	. . I PACTIVE(PN)+1>PDEPTHMAX S ERR("code")="TPL_PARTIAL_DEPTH",ERR("msg")="Partial recursion depth exceeded: "_PN Q
	. . S PACTIVE(PN)=PACTIVE(PN)+1
	. . ; Load partial tokens.;
	. . N PTOK
	. . D GETTOK(PN,.CONF,.PTOK,.ERR) I $D(ERR) S PACTIVE(PN)=PACTIVE(PN)-1 Q
	. . ; Push a frame for PTOK evaluation. Same context top.;
	. . D PUSHFRAME(.FSP,.F,.PTOK,1,$O(PTOK(""),-1),CTSP,$G(F(FSP-1,"mode")),$G(F(FSP-1,"capRef")))
	. . ; Advance parent token index once.;
	. . S F(FSP-1,"i")=I+1
	. . ; When PTOK frame finishes, decrement recursion counter.;
	. . ; We do it in POPF by detecting a marker.;
	. . S F(FSP,"pname")=PN
	. I TYP="secS" D  Q
	. . N KEY,INV,MI
	. . S KEY=$G(TOK(I,"k")),INV=+$G(TOK(I,"inv"))
	. . S MI=+$G(TOK(I,"m"))
	. . I 'MI S ERR("code")="TPL_PARSE",ERR("msg")="Section start without match: "_KEY Q
	. . ; Block section handling.;
	. . I +$G(TOK(I,"blk")) D  Q
	. . . N BNAME S BNAME=$G(TOK(I,"bname"))
	. . . ; Render body into a capture buffer (string), store into CTX("blocks",BNAME).;
	. . . ; The block does NOT output in place.;
	. . . N CAP S CAP=""
	. . . ; Push a capture frame for the body.;
	. . . ; We keep the same context, but mode="capture" and capRef points to local CAP by reference string.;
	. . . N CAPREF S CAPREF=$NA(CAP)
	. . . ; Push child frame: token range (I+1 .. MI-1)
	. . . D PUSHFRAME(.FSP,.F,.TOK,I+1,MI-1,CTSP,"capture",CAPREF)
	. . . ; Advance parent index to MI+1 exactly once.;
	. . . S F(FSP-1,"i")=MI+1
	. . . ; When capture frame pops, store result.;
	. . . S F(FSP,"storeBlock")=1
	. . . S F(FSP,"storeName")=BNAME
	. . . S F(FSP,"storeCapRef")=CAPREF
	. . ; Normal section truthiness evaluation.;
	. . N REF,TYPE,ISSET
	. . D RESREF(KEY,.CST,CTSP,.ISSET,.TYPE,.REF)
	. . ; Inverted logic:
	. . I INV D  Q
	. . . I $$ISTRUTH(.ISSET,.TYPE,.REF)=0 D
	. . . . ; Render body once (current context). No context push.;
	. . . . D PUSHFRAME(.FSP,.F,.TOK,I+1,MI-1,CTSP,$G(F(FSP,"mode")),$G(F(FSP,"capRef")))
	. . . ; Advance parent index to MI+1 no matter what.;
	. . . S F(FSP-1,"i")=MI+1
	. . ; Non-inverted sections
	. . I $$ISTRUTH(.ISSET,.TYPE,.REF)=0 D  Q
	. . . ; Skip body.;
	. . . S F(FSP,"i")=MI+1
	. . ; If list/array: iterate.;
	. . I TYPE="list" D  Q
	. . . N SUB S SUB=""
	. . . ; Empty list means falsey, but we already checked truthy, so it has at least one item.;
	. . . ; We iterate in $O order, stable for numeric and string subscripts.;
	. . . ; Iteration is done by pushing frames one-by-one (no recursion copying tokens).;
	. . . ; We push an iterator frame that manages SUB state.;
	. . . N ITSP S ITSP=FSP+1
	. . . ; Parent advances past section now.;
	. . . S F(FSP,"i")=MI+1
	. . . ; Push iterator controller frame.;
	. . . S FSP=FSP+1
	. . . S F(FSP,"mode")="iter"
	. . . S F(FSP,"end")=MI-1
	. . . S F(FSP,"i")=I+1
	. . . S F(FSP,"ctxTop")=CTSP
	. . . S F(FSP,"listRef")=REF
	. . . S F(FSP,"sub")=""
	. . . S F(FSP,"bodyS")=I+1
	. . . S F(FSP,"bodyE")=MI-1
	. . . S F(FSP,"parentMode")=$G(F(FSP-1,"mode"))
	. . . S F(FSP,"parentCap")=$G(F(FSP-1,"capRef"))
	. . . Q
	. . ; If object: push object context once, render body once.;
	. . I TYPE="obj" D  Q
	. . . N NEWTOP S NEWTOP=CTSP+1
	. . . S CST(NEWTOP)=REF
	. . . S CTSP=NEWTOP
	. . . D PUSHFRAME(.FSP,.F,.TOK,I+1,MI-1,CTSP,$G(F(FSP,"mode")),$G(F(FSP,"capRef")))
	. . . ; Advance parent index.;
	. . . S F(FSP-1,"i")=MI+1
	. . ; Scalar truthy: render body once with current context.;
	. . D PUSHFRAME(.FSP,.F,.TOK,I+1,MI-1,CTSP,$G(F(FSP,"mode")),$G(F(FSP,"capRef")))
	. . S F(FSP-1,"i")=MI+1
	. I TYP="secE" D  Q
	. . ; End tokens are never executed directly because secS jumps past them.;
	. . S F(FSP,"i")=I+1
	;
	;
	; Pop logic handles:
	; - partial recursion decrement
	; - block capture storage
	Q
	;
; =============================================================================
; PUSHFRAME(FSP,F,TOKREF,START,END,CTSP,MODE,CAPREF)
; TOKREF is passed by reference, but we always evaluate the local array in scope.;
; We store no token ref indirection. We assume caller passes the correct TOK array.;
; =============================================================================
PUSHFRAME(FSP,F,TOK,START,END,CTSP,MODE,CAPREF)
	; NOTE: We rely on the fact that the token array is in lexical scope as "TOK"
	; or "PTOK". For PTOK we passed it as .PTOK into this label, so local name is TOK.;
	S FSP=FSP+1
	S F(FSP,"i")=START
	S F(FSP,"end")=END
	S F(FSP,"ctxTop")=CTSP
	S F(FSP,"mode")=$G(MODE,"emit")
	S F(FSP,"capRef")=$G(CAPREF)
	Q
	;
; =============================================================================
; POPF(FSP,F,CST,CTSP)
; Pop frame and apply any frame-finalizers:
; - partial recursion decrement (frame "pname")
; - block capture store (frame "storeBlock")
; Also restore CTSP to parent's ctxTop.;
; =============================================================================
POPF(FSP,F,CST,CTSP)
	N OLD S OLD=FSP
	;
	; Block store finalizer.;
	I +$G(F(OLD,"storeBlock")) D
	. N BN,CR,VAL
	. S BN=$G(F(OLD,"storeName"))
	. S CR=$G(F(OLD,"storeCapRef"))
	. S VAL=$G(@CR)
	. S CTX("blocks",BN)=VAL
	;
	; Partial decrement finalizer.;
	I $G(F(OLD,"pname"))'="" D
	. N PN S PN=$G(F(OLD,"pname"))
	. S PACTIVE(PN)=+$G(PACTIVE(PN))-1
	. I PACTIVE(PN)<0 K PACTIVE(PN)
	;
	; Restore context top to parent's ctxTop (if any).;
	S FSP=FSP-1
	I FSP>0 S CTSP=+$G(F(FSP,"ctxTop")) Q
	; No frames left.;
	Q
	;
; =============================================================================
; EMIT(FSP,F,OUT,VAL)
; Emit to OUT or to capture buffer depending on frame mode.;
; =============================================================================
EMIT(FSP,F,OUT,VAL)
	N MODE S MODE=$G(F(FSP,"mode"))
	I MODE="capture" D  Q
	. N CR S CR=$G(F(FSP,"capRef")) Q:CR=""
	. S @CR=$G(@CR)_$G(VAL)
	; Default: emit to OUT scalar.;
	S OUT=$G(OUT)_$G(VAL)
	Q
; =============================================================================
; RESREF(KEY,CST,CTSP,ISSET,TYPE,REF)
; Resolve KEY using Mustache lookup rules.;
; REF is a reference-string like: CTX("groups","items",1)
; =============================================================================
RESREF(KEY,CST,CTSP,ISSET,TYPE,REF)
	N K S K=KEY
	S ISSET=0,TYPE="missing",REF=""
	I K="" Q
	; {{.}} => current context scalar (if any)
	I K="." D  Q
	. N R S R=$G(CST(CTSP)) Q:R=""
	. I $D(@R)#2 S ISSET=1,TYPE="scalar",REF=R Q
	. ; If the node has children but no scalar, treat {{.}} as empty.;
	. S ISSET=0,TYPE="missing",REF=""
	; Search top-down
	N LEVEL
	F LEVEL=CTSP:-1:1 D  Q:ISSET
	. N BASE S BASE=$G(CST(LEVEL)) Q:BASE=""
	. N OK,RR,TT
	. D RESINBASE(BASE,K,.OK,.TT,.RR)
	. I OK S ISSET=1,TYPE=TT,REF=RR
	Q
	;
; =============================================================================
; RESINBASE(BASE,KEY,OK,TYPE,REF)
; Resolve dotted KEY within a single BASE reference-string.;
; =============================================================================
RESINBASE(BASE,KEY,OK,TYPE,REF)
	S OK=0,TYPE="missing",REF=""
	N CUR S CUR=BASE
	N PARTS,PC,I,P
	D SPLIT(KEY,".",.PARTS,.PC)
	I PC=0 Q
	; Walk dotted path
	F I=1:1:PC D  Q:'OK&(I>1)  ; stop early on fail
	. S P=PARTS(I)
	. I P="." S OK=1 Q
	. N NEXT S NEXT=$$APPREF(CUR,P)
	. I '$D(@NEXT) S OK=0,TYPE="missing",REF="" Q
	. S CUR=NEXT,OK=1
	I 'OK Q
	I '$D(@CUR) Q
	; Determine type:
	; - children => list if it has any subscript at that level
	; - scalar only => scalar
	I $D(@CUR)>1 D  Q
	. N S0 S S0=$$FIRSTSUB(CUR)
	. I S0'="" S OK=1,TYPE="list",REF=CUR Q
	. S OK=1,TYPE="obj",REF=CUR
	I $D(@CUR)#2 S OK=1,TYPE="scalar",REF=CUR Q
	Q
	;
; =============================================================================
; RESVAL(KEY,CST,CTSP)
; Variable resolution returns a scalar or "" if missing/non-scalar.;
; =============================================================================
RESVAL(KEY,CST,CTSP)
	N ISSET,TYPE,REF
	D RESREF(KEY,.CST,CTSP,.ISSET,.TYPE,.REF)
	I 'ISSET Q ""
	I $D(@REF)#2 Q $G(@REF)
	Q ""
	;
; =============================================================================
; ISTRUTH(ISSET,TYPE,REF)
; Truthiness:
; False: missing, "", 0, "0", empty list/object
; =============================================================================
ISTRUTH(ISSET,TYPE,REF)
	I 'ISSET Q 0
	; list/object: false if no subscripts
	I TYPE="list"!(TYPE="obj") Q $S($$FIRSTSUB(REF)="":0,1:1)
	; scalar truthiness
	N V S V=$G(@REF)
	I V="" Q 0
	I V=0 Q 0
	I V="0" Q 0
	Q 1
	;
; =============================================================================
; APPREF(REF,SUB)
; Append a subscript to a reference-string.;
; REF examples:
;  "CTX"
;  "CTX(""groups"",1)"
; SUB can be numeric or string (including "").;
; =============================================================================
APPREF(REF,SUB)
	N R,Q,OUT
	S R=REF
	S Q=$$QSUB(SUB)
	; If already has (...), splice before final ')'
	I R["(" D  Q OUT
	. ; assume well-formed and ends with ')'
	. S OUT=$E(R,1,$L(R)-1)_","_Q_")"
	; No subs yet.;
	Q R_"("_Q_")"
	;
; =============================================================================
; QSUB(SUB)
; Quote/escape a subscript for use in a reference-string.;
; - Numeric stays numeric.;
; - Everything else becomes a quoted string with internal quotes doubled.;
; =============================================================================
QSUB(SUB)
	N S S S=$G(SUB)
	; treat pure numeric as numeric
	I S?1.N Q S
	; quote string
	S S=$$REPL(S,$C(34),$C(34,34))
	Q $C(34)_S_$C(34)
	;
; =============================================================================
; FIRSTSUB(REF)
; Return first subscript at REF level, or "" if none.;
; Uses $O(@(REF("..."))) pattern via APPREF.;
; =============================================================================
FIRSTSUB(REF)
	N S0
	S S0=$O(@($$APPREF(REF,"")))
	Q S0
; =============================================================================
; SPLIT(STR,DEL,ARR,COUNT)
; Split string STR by DEL into ARR(1..COUNT).;
; =============================================================================
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
	;
; =============================================================================
; TRIM(S)
; Simple trim for spaces and tabs.;
; =============================================================================
TRIM(S)
	N A,B
	S A=1,B=$L(S)
	F  Q:A>B  Q:$E(S,A)'=" "&($E(S,A)'=$C(9))  S A=A+1
	F  Q:B<A  Q:$E(S,B)'=" "&($E(S,B)'=$C(9))  S B=B-1
	Q $E(S,A,B)
	;
; =============================================================================
; ESCHTML(S)
; HTML escaping for {{var}}:
;  & < > " '
; =============================================================================
ESCHTML(S)
	N X S X=$G(S)
	; Order matters: escape & first.;
	S X=$$REPL(X,"&","&amp;")
	S X=$$REPL(X,"<","&lt;")
	S X=$$REPL(X,">","&gt;")
	S X=$$REPL(X,$C(34),"&quot;")
	S X=$$REPL(X,"'","&#39;")
	Q X
	;
; =============================================================================
; REPL(S,FROM,TO)
; Replace all occurrences.;
; =============================================================================
REPL(S,FROM,TO)
	N OUT,P,L1,L2
	S OUT="",P=1,L1=$L(FROM)
	I L1=0 Q S
	F  D  Q:P>$L(S)
	. N F S F=$F(S,FROM,P)
	. I 'F S OUT=OUT_$E(S,P,$L(S)),P=$L(S)+1 Q
	. S OUT=OUT_$E(S,P,F-L1-1)_TO
	. S P=F
	Q OUT
	;
; =============================================================================
; H32(TEXT)
; Fast 32-bit non-cryptographic hash for caching.;
; FNV-1a 32-bit variant.;
; =============================================================================
H32(TEXT)
	N H,I,C
	; FNV offset basis: 2166136261
	S H=2166136261
	F I=1:1:$L(TEXT) D
	. S C=$A(TEXT,I)
	. ; H = H XOR C
	. S H=$$XOR32(H,C)
	. ; H = H * 16777619 mod 2^32
	. S H=$$MUL32(H,16777619)
	Q H
	;
; =============================================================================
; XOR32(A,B)
; 32-bit XOR using $ZBIT* if present, else fallback bit arithmetic.;
; YottaDB provides $ZBITXOR on newer builds; GT.M varies.;
; We implement a portable fallback.;
; =============================================================================
XOR32(A,B)
	N R,I,BA,BB,POW
	S R=0,POW=1
	F I=0:1:31 D
	. S BA=A#2,A=A\2
	. S BB=B#2,B=B\2
	. I (BA+BB)=1 S R=R+POW
	. S POW=POW*2
	Q R
	;
; =============================================================================
; MUL32(A,M)
; Multiply mod 2^32 using iterative doubling to stay in integer range.;
; =============================================================================
MUL32(A,M)
	N R
	S R=0
	F  Q:M=0  D
	. I M#2 S R=$$ADD32(R,A)
	. S M=M\2
	. S A=$$ADD32(A,A)
	Q R
	;
; =============================================================================
; ADD32(A,B)
; Add mod 2^32
; =============================================================================
ADD32(A,B)
	N S
	S S=A+B
	; Reduce mod 2^32 (4294967296)
	I S'<4294967296 S S=S#4294967296
	Q S
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