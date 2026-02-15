MIOTPL2 ; MIO template engine with layouts, blocks, partials, and caching.;
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
MIOTEST 
	D MIOTF121,MIOTF122,MIOTF123,MIOTF124,MIOTF125
	D MIOTF126,MIOTF126B,MIOTF127,MIOTF128,MIOTF129,MIOTF130
	D MIOTF200,MIOTF201,MIOTF202,MIOTF203,MIOTF204,MIOTF205
	D MIOTF206
	Q
	;
MIOTF200 D MIOTF200^MIOTPLT QUIT 
MIOTF201 D MIOTF201^MIOTPLT QUIT
MIOTF202 D MIOTF202^MIOTPLT QUIT
MIOTF203 D MIOTF203^MIOTPLT QUIT
MIOTF204 D MIOTF204^MIOTPLT QUIT
MIOTF205 D MIOTF205^MIOTPLT QUIT
MIOTF206 D MIOTF206^MIOTPLT QUIT
MIOTF121 ; Full suite test 121 - TPL_SECTION_CTA.;
	NEW TOK,ERR,CONF,CTX,OUT
	D COMPILE("{{#cta}}X{{/cta}}",.TOK,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"compile")
	SET CTX("cta")=1
	DO EVAL(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"eval")
	DO EQ^MIOTASSERT(OUT,"X","section render")
	QUIT
MIOTF122 ; Full suite test 122 - TPL_BLOCK_TITLE.;
	NEW TOK,ERR,CONF,CTX,OUT
	DO COMPILE("{{#block:title}}Hello{{/block:title}}",.TOK,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"compile")
	DO EVAL(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"eval")
	DO EQ^MIOTASSERT($GET(CTX("blocks","title")),"Hello","block captured")
	QUIT
MIOTF123 ; Full suite test 123 - TPL_DOTTED_LIST.;
	NEW TOK,ERR,CONF,CTX,OUT
	SET CTX("cats","items",1)="Core"
	SET CTX("cats","items",2)="Tools"
	DO COMPILE("{{#cats.items}}{{.}};{{/cats.items}}",.TOK,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"compile")
	DO EVAL(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"eval")
	DO EQ^MIOTASSERT(OUT,"Core;Tools;","dotted list") 
	QUIT
MIOTF124 ; Full suite test 124 - TPL_PACKAGES_OBJECT.;
	NEW TOK,ERR,CONF,CTX,OUT
	SET CTX("packages",1,"slug")="mio-web"
	SET CTX("packages",1,"name")="Web Server"
	DO COMPILE("{{#packages}}{{slug}}-{{name}};{{/packages}}",.TOK,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"compile")
	DO EVAL(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"eval")
	DO EQ^MIOTASSERT(OUT,"mio-web-Web Server;","packages obj")
	QUIT
MIOTF125 ; Full suite test 125 - TPL_INVERTED_NORESULTS.;
	NEW TOK,ERR,CONF,CTX,OUT,RES
	; Template: show "NONE" only when packages is falsey/empty.;
	DO COMPILE("{{^packages}}NONE{{/packages}}{{#packages}}YES{{/packages}}",.TOK,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"compile")
	; Case A: packages has an item => inverted must NOT render, normal must render.;
	KILL CTX
	SET CTX("packages",1,"name")="Pkg1"
	DO EVAL(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"eval A")
	DO EQ^MIOTASSERT(OUT,"YES","inverted suppressed when list has items") 
	; Case B: packages empty => inverted MUST render, normal must NOT render.;
	KILL OUT,ERR,CTX
	DO EVAL(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"eval B")
	DO EQ^MIOTASSERT(OUT,"NONE","inverted renders when list empty")
	QUIT
MIOTF126 ; Full suite test 126 - TPL_DEEP_NESTED_CONTEXT.;
	NEW TOK,ERR,CONF,CTX,OUT,RES,TPL
	; This template expects:
	; CTX("groups","items",g,"name") = group name
	; CTX("groups","items",g,"members",m,"name") = member name
	; If no members, inverted section prints "EMPTY"
	SET TPL="{{#groups.items}}"
	SET TPL=TPL_"G={{name}}:["
	SET TPL=TPL_"{{#members}}{{name}},{{/members}}"
	SET TPL=TPL_"{{^members}}EMPTY{{/members}}"
	SET TPL=TPL_"];"
	SET TPL=TPL_"{{/groups.items}}"
	DO COMPILE(TPL,.TOK,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"compile")
	; Build deep context with two groups:
	; Group 1 has 2 members, Group 2 has none.;
	KILL CTX
	SET CTX("groups","items",1,"name")="Core"
	SET CTX("groups","items",1,"members",1,"name")="Alice"
	SET CTX("groups","items",1,"members",2,"name")="Bob"
	SET CTX("groups","items",2,"name")="Tools"
	; No members under group 2 => should show EMPTY
	DO EVAL(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"eval")
	DO EQ^MIOTASSERT(OUT,"G=Core:[Alice,Bob,];G=Tools:[EMPTY];","deep nested render")
	QUIT
MIOTF126B ; Full suite test 126B - TPL_DEEP_NESTED_CONTEXT_SCALARS.;
	NEW TOK,ERR,CONF,CTX,OUT,RES,TPL
	; Scalar member list variant:
	; CTX("groups","items",g,"name") = group name
	; CTX("groups","items",g,"members",m) = member scalar (e.g., "Alice")
	; Uses {{.}} inside members loop.;
	; If no members, inverted section prints "EMPTY"
	SET TPL="{{#groups.items}}"
	SET TPL=TPL_"G={{name}}:["
	SET TPL=TPL_"{{#members}}{{.}},{{/members}}"
	SET TPL=TPL_"{{^members}}EMPTY{{/members}}"
	SET TPL=TPL_"];"
	SET TPL=TPL_"{{/groups.items}}"
	DO COMPILE(TPL,.TOK,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"compile")
	; Two groups: one with scalar members, one empty.;
	KILL CTX
	SET CTX("groups","items",1,"name")="Core"
	SET CTX("groups","items",1,"members",1)="Alice"
	SET CTX("groups","items",1,"members",2)="Bob"
	SET CTX("groups","items",2,"name")="Tools"
	; No members under group 2 => should show EMPTY
	DO EVAL(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"eval")
	DO EQ^MIOTASSERT(OUT,"G=Core:[Alice,Bob,];G=Tools:[EMPTY];","deep nested scalars render")
	QUIT
	;
MIOTF127 ;
	K ERR,OUT,CONF,CTX
	M CONF=^MIO("CONF")
	;
	S ROOT="templates/test127-"_$J_"/"
	D MKDIR(ROOT),MKDIR(ROOT_"partials/")
	;
	S CONF("templates","root")=ROOT
	S CONF("templates","ext")=""
	; Write layout + page templates
	D WRFILE(ROOT_"layout.html","L0<title>{{{blocks.title}}}</title>|D={{desc}}|{{{content}}}|L9",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write layout") K ERR
	;
	N T,OK S OK=$$READFILE^MIOTPL2(ROOT_"layout.html",.T,.ERR) 
	D EQ^MIOTASSERT($E(T,1,9),"L0<title>","layout file prefix")
	;
	D WRFILE(ROOT_"page.html","{{#block:title}}T{{year}}{{/block:title}}P{{year}}",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write page") K ERR
	;
	; Clear cache entries for these exact filepaths (defensive)
	K ^MIO("TPL","CACHE",ROOT_"layout.html")
	K ^MIO("TPL","CACHE",ROOT_"page.html")
	;	
	;
	; Context
	S CTX("year")=2026
	S CTX("desc")="DESC"
	;
	;
	D RENDERPAGE("page.html","layout.html",.CONF,.CTX,.OUT,.ERR)
	D OK^MIOTASSERT('$D(ERR),"renderpage") ZWR:$D(ERR) ERR
	;
	; Expected output
	D EQ^MIOTASSERT(OUT,"L0<title>T2026</title>|D=DESC|P2026|L9","layout+page output")
	D EQ^MIOTASSERT($G(CTX("blocks","title")),"T2026","block title captured")
	;
	; Cleanup best-effort
	D RMDIR(ROOT)
	Q
	;
MIOTF128 ; Full suite test 128 - TPL_PARTIALS_INCLUDE
	K ERR,OUT,CONF,CTX
	N ROOT
	;
	; Pull base config first (if you want it), THEN override root/ext
	M CONF=^MIO("CONF")
	;
	S ROOT="templates/test128-"_$J_"/"
	D MKDIR(ROOT)
	D MKDIR(ROOT_"partials/")
	;
	S CONF("templates","root")=ROOT
	S CONF("templates","ext")=""
	;
	; --- write partials ---
	D WRFILE(ROOT_"partials/app1.html","APP1",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write app1") K ERR
	;
	D WRFILE(ROOT_"partials/p.html","PP",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write p") K ERR
	;
	; --- write main (includes both partials) ---
	D WRFILE(ROOT_"main.html","{{> partials/app1.html}}{{> partials/p.html}}",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write main") K ERR
	;
	; --- render main by logical name (NO ROOT PREFIX) ---
	D RENDER("main.html",.CONF,.CTX,.OUT,.ERR)
	D OK^MIOTASSERT('$D(ERR),"render main") I $D(ERR) ZWR ERR
	;
	D EQ^MIOTASSERT(OUT,"APP1PP","partials include output")
	;
	D RMDIR(ROOT)
	Q
	;
MIOTF129 ;
	N TOK,ERR,CONF,CTX,OUT
	D COMPILE("{{#x}}Y{{/x}}{{^x}}N{{/x}}",.TOK,.ERR)
	S CTX("x")="false"
	D EVAL(.TOK,.CONF,.CTX,.OUT,.ERR)
	D EQ^MIOTASSERT(OUT,"N","false string is falsey")
	K OUT,ERR
	S CTX("x")="true"
	D EVAL(.TOK,.CONF,.CTX,.OUT,.ERR)
	D EQ^MIOTASSERT(OUT,"Y","true string is truthy")
	Q
	;
MIOTF130 ;
	N TOK,ERR,CONF,CTX,OUT
	D COMPILE("{{#x}}Y{{/x}}{{^x}}N{{/x}}",.TOK,.ERR)
	S CTX("x")="FALSE"
	D EVAL(.TOK,.CONF,.CTX,.OUT,.ERR)
	D EQ^MIOTASSERT(OUT,"N","FALSE is falsey")
	Q
	;
; -----------------------------
; Helpers for filesystem tests
; -----------------------------
	;
WRFILE(FP,TXT,ERR) ; Write TXT to FP (overwrite)
	K ERR
	NEW $ETRAP S $ETRAP="S ERR(""code"")=""TPL_IO"",ERR(""msg"")=""Write failed: ""_FP Q"
	OPEN FP:(NEWVERSION:WRITEONLY:EXCEPTION="GOTO WFERR")
	USE FP
	WRITE TXT
	CLOSE FP
	Q
WFERR ;
	CLOSE FP
	S ERR("code")="TPL_IO",ERR("msg")="Write failed: "_FP
	Q
	;
MKDIR(PATH) ; mkdir -p PATH (best-effort)
	NEW CMD
	S CMD="mkdir -p "_$$SHQ(PATH)
	ZSY CMD
	Q
	;
RMDIR(PATH) ; rm -rf PATH (best-effort)
	NEW CMD
	S CMD="rm -rf "_$$SHQ(PATH)
	ZSY CMD
	Q
	;
SHQ(S) ; shell-quote
	; Wrap in single quotes; escape single quotes safely: ' -> '\'' (close, escape, reopen)
	NEW X S X=$G(S)
	I X["'" S X=$$REPLQ(X)
	Q "'"_X_"'"
	;
REPLQ(S) ; replace ' with '\'' for shell single-quote context
	NEW OUT,P,F
	S OUT="",P=1
	F  D  Q:P>$L(S)
	. S F=$F(S,"'",P)
	. I 'F S OUT=OUT_$E(S,P,$L(S)),P=$L(S)+1 Q
	. S OUT=OUT_$E(S,P,F-2)_"'\''"
	. S P=F
	Q OUT
	;
	;
start
	K 
	S PATH=$$GETCONF^MIOCONF()
	D LOAD^MIOCONF(PATH,.CONF)
	M CONF=^MIO("CONF")
	D START(.CONF)
	Q
START(CONF)
	NEW EN
	;DO START^MIOTPLW(.CONF)
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
	. DO GETTOKFP(FP,.CONF,.TOK,.ERR)
	. ; Do not fail whole precompile on a single file, but record last error.;
	. ;IF 'OK SET CONF("templates","precompile","lastError")=ERR
	QUIT
ENUMGLOBS(ROOT,LIST) ;
	; Best-effort enumeration using common file globs.;
	; YottaDB supports $ZSEARCH for filesystem search with wildcards.;
	; Root-level pages and known folders (non-recursive).;
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
	N PAGEOUT,OK
	; Reset blocks for this page render.;
	K CTX("blocks")
	S CTX("content")=""
	D RENDER(PAGE,.CONF,.CTX,.PAGEOUT,.ERR)  
	Q:$D(ERR) 
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
	;I '$$GETTOKFP^MIOTPL(NAME,.CONF,.TOK,.ERR) S ERR=1 
	;Q	
	K ERR K TOK N FP
	S FP=$$NAME2FP(NAME,.CONF,.ERR) Q:$D(ERR)
	D GETTOKFP(FP,.CONF,.TOK,.ERR)
	;I $$GETTOKFP^MIOTPL(NAME,.CONF,.TOK,.ERR)
	Q
; =============================================================================
; GETTOKFP(FP,CONF,TOK,ERR)
; Compile template by file path.;k
; - Uses cache hash ^MIO("TPL","CACHE",FP,"H")
; - Stores tokens under ^MIO("TPL","CACHE",FP,"TOK",...)
; - Respects CONF("templates","devWatchEnabled")
; =============================================================================
GETTOKFP(FP,CONF,TOK,ERR) ;
	; Load and compile a template by full path.;
	KILL TOK SET ERR=""
	NEW CH,WH,DEVW,OK,TXT,H
	SET DEVW=+$GET(CONF("templates","devWatchEnabled"))
	;SET DEVW=1
	SET CH=$GET(^MIO("TPL","CACHE",FP,"H"))
	IF DEVW,CH'="" DO  IF $DATA(^MIO("TPL","CACHE",FP,"TOK",1)) DO  QUIT
	. SET WH=$GET(^MIO("TPL","FS",FP,"H"))
	. IF WH'="",WH=CH DO  QUIT
	. . MERGE TOK=^MIO("TPL","CACHE",FP,"TOK")
	; Fallback: read + hash
	SET OK=$$READFILE(FP,.TXT,.ERR) IF 'OK QUIT
	SET H=$$H32(TXT)
	IF CH'="",CH=H,$DATA(^MIO("TPL","CACHE",FP,"TOK",1)) DO  QUIT
	. MERGE TOK=^MIO("TPL","CACHE",FP,"TOK")
	; Compile
	NEW TMP KILL TMP
	D PARSE(TXT,.TMP,.ERR) Q:$D(ERR)
	D LINKSECS(.TMP,.ERR) Q:$D(ERR)
	KILL ^MIO("TPL","CACHE",FP)
	SET ^MIO("TPL","CACHE",FP,"H")=H
	MERGE ^MIO("TPL","CACHE",FP,"TOK")=TMP
	MERGE TOK=TMP
	QUIT
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
	;I EXT="" S EXT=".html"
	S NM=NAME
	; Normalize backslashes to slashes for safety/consistency.;
	S NM=$TR(NM,"\","/")
	; If caller passed an already-rooted path, strip the root to avoid double prefix
	N R1,R2
	S R1=ROOT
	S R2="./"_ROOT
	I $E(NM,1,$L(R2))=R2 S NM=$E(NM,$L(R2)+1,$L(NM))
	E  I $E(NM,1,$L(R1))=R1 S NM=$E(NM,$L(R1)+1,$L(NM))
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
READFILE(FP,TXT,ERR) ;
	N LINE,MAX
	K ERR
	S TXT=""
	N IO S IO=$PRINCIPAL
	; Safety limit: 2 MB (adjustable via CONF later if needed).;
	S MAX=2*1024*1024
	;I '$$FILEEXISTS(FP) ="" 
	;S FP="./"_FP
	;I '$$FILEEXISTS(FP) S ERR("code")="TPL_NOFILE",ERR("msg")="Template file not found: "_FP Q 0
	O FP:(READONLY:EXCEPTION="GOTO RFERR^MIOTPL2":CHSET="M"):2	
	F  U FP R *LINE Q:$ZEOF  D  Q:('$T!$D(ERR))
	. ; Keep newlines. Most templates expect them.;
	. S TXT=TXT_$C(LINE)
	. I $L(TXT)>MAX S ERR("code")="TPL_TOOLARGE",ERR("msg")="Template too large (limit 2MB): "_FP
	I $D(ERR) Q 0
	C FP U IO
	I $E(TXT,$L(TXT))=$C(10) S TXT=$E(TXT,1,$L(TXT)-1) ;get rid of the extra $C(10)
	Q 1
	;
RFERR ;
	C FP
	I $zstatus["%YDB-E-IOEOF" D  K ERR Q 1
	. I $E(TXT,$L(TXT))=$C(10) S TXT=$E(TXT,1,$L(TXT)-1) ;get rid of the extra $C(10)
	. S $ZSTATUS="",$EC=""
	S ERR("code")="TPL_IO",ERR("msg")="I/O error reading template: "_FP_" $zstatus:"_$zstatus
	Q ""
; =============================================================================
; Internal: FILEEXISTS(FP)
; Portable-ish file existence check for GT.M/YottaDB.;
; =============================================================================
FILEEXISTS(FP) Q $ZSEARCH(FP)]""
	; $ZSEARCH returns "" if not found.;
; =============================================================================
;  PARSE + LINKSECS
; =============================================================================
	;
COMPILE(TEXT,TOK,ERR,OD,CD) ;
	N CRLF
	; Detect original newline style BEFORE normalization
	S CRLF=$S($F($G(TEXT),$C(13,10))>0:1,1:0)
	;
	; Normalize only for parsing/standalone logic
	S TEXT=$$NORMNL^MIOTPL2(TEXT)
	;
	D PARSE(.TEXT,.TOK,.ERR,.OD,.CD)  ; PARSE kills TOK
	I $D(ERR) Q
	;
	; Metadata
	S TOK("meta","crlf")=CRLF
	S TOK("meta","src")=TEXT
	;
	D LINKSECS(.TOK,.ERR)
	I $D(ERR) Q
	;
	D STANDTOK(.TOK)
	Q
LINEPURE(TOK,I,MAX)
	N J,TYP,OK,FOUND
	S OK=1
	;
	; scan left until newline boundary
	S FOUND=0
	F J=I-1:-1:1 Q:'OK  D  Q:FOUND
	. S TYP=$G(TOK(J,"t"))
	. I TYP'="text" S OK=0 Q
	. I $$HASNL($G(TOK(J,"v"))) S FOUND=1
	;
	; scan right until newline boundary
	S FOUND=0
	F J=I+1:1:MAX Q:'OK  D  Q:FOUND
	. S TYP=$G(TOK(J,"t"))
	. I TYP'="text" S OK=0 Q
	. I $$HASNL($G(TOK(J,"v"))) S FOUND=1
	Q OK
	;
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
; =============================================================================
; PARSE(TEXT,TOK,ERR)
; =============================================================================
	;
PARSE(TEXT,TOK,ERR,OD,CD)
	; Mustache-compatible parser with delimiter support.;
	; OD/CD are the current open/close delimiters (default "{{" / "}}").;
	; Stores raw body ranges for section/block/parent tags to support lambdas.;
	K ERR K TOK
	N L,POS,ODL,CDL,OPEN,CLOSE,PRE,INSIDE,RAW,END3,TRI
	N N S N=0
	S OD=$G(OD,"{{"),CD=$G(CD,"}}")
	S ODL=$L(OD),CDL=$L(CD)
	S L=$L(TEXT),POS=1
	;
	F  Q:POS>L  D  Q:$D(ERR)
	. ; Find next open delimiter
	. S OPEN=$F(TEXT,OD,POS)
	. I 'OPEN D  Q
	. . S PRE=$E(TEXT,POS,L)
	. . I PRE'="" D ADDTXT(.TOK,.N,PRE)
	. . S POS=L+1
	. ;
	. ; Text before tag
	. S PRE=$E(TEXT,POS,OPEN-ODL-1)
	. I PRE'="" D ADDTXT(.TOK,.N,PRE)
	. ;
	. ; Triple mustache ONLY when default delimiters are active
	. S TRI=0
	. I (OD="{{")&(CD="}}"),$E(TEXT,OPEN)="{" S TRI=1
	. I TRI D  Q
	. . S END3=$F(TEXT,"}}}",OPEN)
	. . I 'END3 S ERR("code")="TPL_PARSE",ERR("msg")="Unclosed triple mustache." Q
	. . S RAW=$E(TEXT,OPEN+1,END3-4)
	. . S RAW=$$TRIM(RAW)
	. . D ADDVAR(.TOK,.N,RAW,0)
	. . S POS=END3
	. ;
	. ; Normal mustache "{{ ... }}" (or custom delimiters)
	. S CLOSE=$F(TEXT,CD,OPEN)
	. I 'CLOSE S ERR("code")="TPL_PARSE",ERR("msg")="Unclosed mustache tag." Q
	. S INSIDE=$E(TEXT,OPEN,CLOSE-CDL-1)
	. S INSIDE=$$TRIM(INSIDE)
	. ;
	. ; Delimiter change: {{= newOD newCD =}}
	. I $E(INSIDE,1)="=",$E(INSIDE,$L(INSIDE))="=" D  S POS=CLOSE Q
	. . N MID,A,B
	. . S MID=$$TRIM($E(INSIDE,2,$L(INSIDE)-1))
	. . ; split by whitespace into 2 tokens
	. . S A=$$TRIM($P(MID," ",1))
	. . S B=$$TRIM($P(MID," ",2,99))
	. . S B=$$TRIM($P(B," ",1))
	. . I A=""!(B="") S ERR("code")="TPL_PARSE",ERR("msg")="Bad delimiter tag." Q
	. . D ADDDELIM(.TOK,.N,A,B)
	. . ; update active delimiters for subsequent scans
	. . S OD=A,CD=B,ODL=$L(OD),CDL=$L(CD)
	. ;
	. ; Comments
	. I $E(INSIDE,1)="!" D  S POS=CLOSE Q
	. . D ADDCOMM(.TOK,.N)
	. ;
	. ; Unescaped via &
	. I $E(INSIDE,1)="&" D  S POS=CLOSE Q
	. . N K S K=$$TRIM($E(INSIDE,2,$L(INSIDE)))
	. . D ADDVAR(.TOK,.N,K,0)
	. ;
	. ; Partials
	. I $E(INSIDE,1)=">" D  S POS=CLOSE Q
	. . N P S P=$$TRIM($E(INSIDE,2,$L(INSIDE)))
	. . D ADDPART(.TOK,.N,P)
	. ;
	. ; Parent (inheritance): {{<parent}}
	. I $E(INSIDE,1)="<" D  S POS=CLOSE Q
	. . N P S P=$$TRIM($E(INSIDE,2,$L(INSIDE)))
	. . D ADDPARENT(.TOK,.N,P,CLOSE) ; body starts after this tag
	. ;
	. ; Block: {{$block}}
	. I $E(INSIDE,1)="$" D  S POS=CLOSE Q
	. . N B S B=$$TRIM($E(INSIDE,2,$L(INSIDE)))
	. . D ADDBLOCK(.TOK,.N,B,CLOSE)
	. ;
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
	. . I OP="/" D ADDSECE(.TOK,.N,K,OPEN-ODL) Q  ; store open-delim pos for raw slicing
	. . S INV=$S(OP="^":1,1:0)
	. . D ADDSECS(.TOK,.N,K,INV,CLOSE)
	. ;
	. ; Default: variable escaped
	. D ADDVAR(.TOK,.N,INSIDE,1)
	. S POS=CLOSE
	Q
NUMMAX(TOK)
	N I,MAX
	S MAX=0,I=0
	F  S I=$O(TOK(I)) Q:I=""  D
	. I I?1.N,I>MAX S MAX=I
	Q MAX
; =============================================================================
; STANDTOK(TOK)
; Mustache standalone trimming using SNAPSHOT line boundaries.;
; This avoids "cascading" bugs where trimming earlier tags removes the evidence
; needed to recognize later tags on their own lines (fixes TEST073/095).;
; =============================================================================
STANDTOK(TOK)
	N I,MAX,TYP,MI
	N DO,DOM  ; DO(I)=standalone single token, DOM(I)=matching end index for parS
	;
	S MAX=$$NUMMAX(.TOK) Q:MAX<1
	;
	; pass 1: detect (no mutation)
	F I=1:1:MAX D
	. S TYP=$G(TOK(I,"t"))
	. ; parent/include start: treat range I..MI as one unit
	. I TYP="parS" D  Q
	. . S MI=+$G(TOK(I,"m")) I MI<I Q
	. . I $$ISSTANDR(.TOK,I,MI,MAX) S DO(I)=1,DOM(I)=MI
	. ; existing standalone token types
	. Q:(TYP'="secS")&(TYP'="secE")&(TYP'="blkS")&(TYP'="part")&(TYP'="comm")&(TYP'="delim")
	. I $$ISSTAND(.TOK,I,MAX) S DO(I)=1
	;
	; pass 2: apply trims (reverse to avoid cascades)
	F I=MAX:-1:1 I $G(DO(I)) D
	. I $G(TOK(I,"t"))="parS" D  Q
	. . D STANDAPR(.TOK,I,+$G(DOM(I)),MAX)
	. D STANDAP(.TOK,I,MAX)
	Q
; =============================================================================
; ISSTANDR(TOK,BS,BE,MAX)
; Standalone check for a RANGE (BS..BE), used for parent/include (parS..secE).;
; Same rules as standalone lines: only whitespace on the line besides the range,
; and we may remove the following newline (or allow EOF).;
; =============================================================================
ISSTANDR(TOK,BS,BE,MAX)
	N POK,NOK,PV,NV,J
	;
	; left side: BOF or previous text tail is ws-only
	S POK=1
	I BS>1 D  Q:'POK 0
	. I $G(TOK(BS-1,"t"))'="text" S POK=0 Q
	. S PV=$G(TOK(BS-1,"v"))
	. I '$$TAILWS(PV) S POK=0
	;
	; inside range must not contain any non-ws text tokens (usually none)
	F J=BS+1:1:BE-1 D  Q:'POK
	. I $G(TOK(J,"t"))'="text" S POK=0 Q
	. I '$$ALLWSIND($G(TOK(J,"v"))) S POK=0
	Q:'POK 0
	;
	; right side: EOF allowed, else next text must start with ws then newline (or be empty => allow EOF)
	S NOK=1
	I BE<MAX D  Q:'NOK 0
	. I $G(TOK(BE+1,"t"))'="text" S NOK=0 Q
	. S NV=$G(TOK(BE+1,"v"))
	. I '$$HEADWNL(NV) S NOK=0
	Q 1
	;
; =============================================================================
; STANDAPR(TOK,BS,BE,MAX)
; Apply standalone trimming for range BS..BE:
; - trim indentation before BS
; - blank ws-only tokens inside range (if any)
; - trim leading ws + ONE newline after BE (if present)
; =============================================================================
STANDAPR(TOK,BS,BE,MAX)
	N J
	; trim prev indentation
	I BS>1 S TOK(BS-1,"v")=$$CUTPRE($G(TOK(BS-1,"v")))
	; blank whitespace-only text tokens between BS and BE (rare but safe)
	F J=BS+1:1:BE-1 I $G(TOK(J,"t"))="text" S TOK(J,"v")=""
	; trim next leading ws + ONE newline
	I BE<MAX S TOK(BE+1,"v")=$$CUTNX($G(TOK(BE+1,"v")))
	Q
; returns 1 if token I is standalone (uses your current rules)
ISSTAND(TOK,I,MAX)
	N POK,NOK,PV,NV
	;
	; keep your "no inline non-text on same line" guard if you want it:
	  I $G(TOK(I,"t"))="blkS" Q $$ISSTANDB(.TOK,I,MAX)
	E  I '$$LINEPURE(.TOK,I,MAX) Q 0
	;
	; prev side must be start-of-file OR text token whose tail after last LF is all ws
	S POK=1
	I I>1 D
	. I $G(TOK(I-1,"t"))'="text" S POK=0 Q
	. S PV=$G(TOK(I-1,"v"))
	. I '$$TAILWS(PV) S POK=0
	Q:'POK 0
	;
	; next side must be end-of-file OR text token starting with ws then LF/CRLF/CR (whatever your HEADWNL supports)
	S NOK=1
	I I<MAX D
	. I $G(TOK(I+1,"t"))'="text" S NOK=0 Q
	. S NV=$G(TOK(I+1,"v"))
	. I '$$HEADWNL(NV) S NOK=0
	Q:'NOK 0
	;
	Q 1
ISSTANDB(TOK,I,MAX) ; standalone detection for blkS ignoring parS adjacency
	N JP,JN,PV,NV,P,OK
	;
	; must be "line pure" except we allow parS tokens on the line
	I '$$LINEPUREB(.TOK,I,MAX) Q 0
	;
	; find previous TEXT token scanning left, skipping parS
	S JP=I-1
	F  Q:JP<1  Q:$G(TOK(JP,"t"))="text"  D  Q:$G(TOK(JP,"t"))'="parS"
	. I $G(TOK(JP,"t"))="parS" S JP=JP-1 Q
	. Q
	S PV=""
	I JP>=1,$G(TOK(JP,"t"))="text" S PV=$G(TOK(JP,"v"))
	;
	; prev side OK if:
	; - no prev text (BOF or only parS) OR
	; - after last newline in PV, only spaces/tabs
	S OK=1
	I PV'="" D
	. S P=$$LASTNLSEQ(PV)
	. I P>0 D  Q
	. . I $TR($E(PV,P+1,$L(PV))," "_$C(9),"")'="" S OK=0
	. ; no newline in PV => must be all ws (otherwise tag not standalone)
	. I P=0,$TR(PV," "_$C(9),"")'="" S OK=0
	I 'OK Q 0
	;
	; find next TEXT token scanning right, skipping parS (defensive)
	S JN=I+1
	F  Q:JN>MAX  Q:$G(TOK(JN,"t"))="text"  D  Q:$G(TOK(JN,"t"))'="parS"
	. I $G(TOK(JN,"t"))="parS" S JN=JN+1 Q
	. Q
	;
	; next must exist and begin with optional ws/CR then a newline
	S NV=$S(JN<=MAX&($G(TOK(JN,"t"))="text"):$G(TOK(JN,"v")),1:"")
	I NV="" Q 0
	I '$$HASLEADNL(NV) Q 0
	;
	Q 1
HASLEADNL(S) ; true if S begins with [spaces/tabs/CR]* then LF or CRLF
	N J,C,L
	S S=$G(S),L=$L(S)
	I L=0 Q 0
	F J=1:1:L S C=$E(S,J) Q:(C'=" ")&(C'=$C(9))&(C'=$C(13))
	I J>L Q 0
	I $E(S,J)=$C(10) Q 1
	I $E(S,J)=$C(13),$E(S,J+1)=$C(10) Q 1
	Q 0
STANDAP(TOK,I,MAX)
	N TYP,PV,P,IND
	S TYP=$G(TOK(I,"t"))
	;
	I TYP="part" D
	. S IND=""
	. I I>1,$G(TOK(I-1,"t"))="text" D
	. . S PV=$G(TOK(I-1,"v"))
	. . S P=$$LASTNLSEQ(PV)
	. . I P>0 S IND=$E(PV,P+1,$L(PV))
	. . E  S IND=PV
	. I IND'="",$TR(IND," "_$C(9),"")'="" S IND=""
	. S TOK(I,"indent")=IND
	;
	I I>1 S TOK(I-1,"v")=$$CUTPRE($G(TOK(I-1,"v")))
	I I<MAX S TOK(I+1,"v")=$$CUTNX($G(TOK(I+1,"v")))
	;
	; NEW: also trim blkS raw if we are trimming this tag as standalone
	I TYP="blkS" S TOK(I,"raw")=$$CUTNX1($G(TOK(I,"raw")))
	Q
LINEIND(V) ; indentation after last LF (or BOF), spaces/tabs only
	N P,TAIL
	S V=$G(V)
	S P=$$LASTLF(V)
	S TAIL=$S(P>0:$E(V,P+1,$L(V)),1:V)
	I '$$ALLWSIND(TAIL) Q ""
	Q TAIL
INDENTSTR(S,IND)
	I $G(IND)="" Q $G(S)
	N I,L,CH,OUT
	S S=$G(S),OUT=IND,L=$L(S)
	F I=1:1:L D
	. S CH=$E(S,I),OUT=OUT_CH
	. ; after LF, add IND unless LF is last char
	. I CH=$C(10),I<L S OUT=OUT_IND
	Q OUT
	;
; =============================================================================
; STAND1(TOK,I,MAX,LBN,RBN)
; Tag token I is standalone if:
;   - From line-start to I: only whitespace TEXT tokens (no other tags)
;   - From I to line-end: only whitespace TEXT tokens
; Uses snapshot LBN/RBN so earlier trimming can't break later decisions.;
; =============================================================================
STAND1(TOK,I,MAX,LBN,RBN)
	N LB,RB
	S LB=$S(I>1:+$G(LBN(I-1)),1:0)        ; token index containing LF before I, or 0 for BOF
	S RB=$S(I<MAX:+$G(RBN(I+1)),1:0)      ; token index containing LF after I, or 0 for EOF
	;
	; --- PRE side check (LB+1 .. I-1 must be whitespace-only text; and tail of LB after last LF ws-only)
	I '$$PREOK(.TOK,LB,I) Q
	;
	; --- POST side check (I+1 .. RB-1 must be whitespace-only text; and head of RB before first LF ws-only)
	I '$$POSTOK(.TOK,I,RB,MAX) Q
	;
	; --- TRIM PRE: remove indentation between line-start and tag
	D TRIMPRE(.TOK,LB,I)
	;
	; --- TRIM POST: remove whitespace after tag up to (and including) ONE LF if present
	D TRIMPOST(.TOK,I,RB,MAX)
	;
	Q
	;
; =============================================================================
; PREOK(TOK,LB,I)
; =============================================================================
PREOK(TOK,LB,I)
	N J,V,P,TAIL,Q S Q=1
	; tokens between LB and I must be text + whitespace-only
	F J=$S(LB>0:LB+1,1:1):1:I-1 D  S Q=0 Q
	. I $G(TOK(J,"t"))'="text" S Q=0 Q
	. I '$$ALLWSIND($G(TOK(J,"v"))) S Q=0 Q
	; tail of LB after last LF (indentation) must be ws-only
	I LB>0 D
	. S V=$G(TOK(LB,"v")),P=$$LASTNL(V)
	. S TAIL=$S(P>0:$E(V,P+1,$L(V)),1:"")
	. I '$$ALLWSIND(TAIL) S Q=0 Q
	Q Q
FIRSTNL(S) ; $F-like index of first NL start char; returns position (1-based) of NL char, 0 if none
	N I,L,C,Q S Q=0
	S S=$G(S),L=$L(S)
	F I=1:1:L S C=$E(S,I) I (C=$C(10))!(C=$C(13)) S Q=I Q
	Q Q
; =============================================================================
; POSTOK(TOK,I,RB,MAX)
; =============================================================================
POSTOK(TOK,I,RB,MAX)
	N J,V,P,HEAD,Q S Q=1
	; tokens after I until RB must be text + whitespace-only
	F J=I+1:1:$S(RB>0:RB-1,1:MAX) D  S Q=0 Q
	. I $G(TOK(J,"t"))'="text" S Q=0 Q
	. I '$$ALLWSIND($G(TOK(J,"v"))) S Q=0 Q
	; if RB exists, head before first LF must be ws-only
	I RB>0 D
	. S V=$G(TOK(RB,"v"))
	. ;S P=$F(V,$C(10))
	. N P
	. S P=$$FIRSTNL(V) I P'>0 S Q=0 Q
	. S HEAD=$E(V,1,P-2)
	. I '$$ALLWSIND(HEAD) S Q=0 Q
	. ; must actually contain LF to be a line boundary
	. I P'>0 S Q=0 Q
	. S HEAD=$E(V,1,P-2)
	. I '$$ALLWSIND(HEAD) S Q=0 Q
	Q Q
	;
; =============================================================================
; TRIMPRE(TOK,LB,I)
; Keep up to last LF in boundary token; blank all-whitespace tokens between.;
; =============================================================================
TRIMPRE(TOK,LB,I)
	N J,V,P
	I LB>0 D
	. S V=$G(TOK(LB,"v"))
	. S P=$$LASTNL(V)
	. S TOK(LB,"v")=$E(V,1,P)
	F J=$S(LB>0:LB+1,1:1):1:I-1 S TOK(J,"v")=""
	Q
	;
; =============================================================================
; TRIMPOST(TOK,I,RB,MAX)
; Blank whitespace tokens after tag; remove ONE LF from RB token (after ws).;
; =============================================================================
TRIMPOST(TOK,I,RB,MAX)
	N J
	F J=I+1:1:$S(RB>0:RB-1,1:MAX) S TOK(J,"v")=""
	I RB>0 S TOK(RB,"v")=$$CUTNXNL($G(TOK(RB,"v")))
	Q
	;
; =============================================================================
; CUTNXLF(S)
; Remove leading indentation ws (space/tab) then remove exactly ONE LF.;
; (Input is normalized to LF already.)
; =============================================================================
CUTNXLF(S)
	N J,C,L
	S S=$G(S),L=$L(S)
	I L=0 Q ""
	; skip indentation (spaces/tabs only)
	F J=1:1:L S C=$E(S,J) Q:(C'=" ")&(C'=$C(9))
	I J>L Q S
	; remove one LF if present
	I $E(S,J)=$C(10) Q $E(S,J+1,L)
	Q S
HEADWNL(S) ; starts with [spaces/tabs]* then LF, or empty => allow EOF
	N J,C,L
	S S=$G(S) I S="" Q 1
	S L=$L(S)
	F J=1:1:L S C=$E(S,J) Q:(C'=" ")&(C'=$C(9))
	I J>L Q 0
	Q $S($E(S,J)=$C(10):1,1:0)
; =============================================================================
; ALLWSIND(S)  spaces/tabs only
; =============================================================================
ALLWSIND(S)
	N I,C,Q S Q=1
	S S=$G(S)
	F I=1:1:$L(S) S C=$E(S,I) I (C'=" ")&(C'=$C(9)) S Q=0 Q
	Q Q
	;
; =============================================================================
; LASTLF(S) position of last LF, 0 if none
; =============================================================================
LASTLF(S)
	N P,AT
	S S=$G(S),P=0,AT=0
	F  S AT=$F(S,$C(10),AT+1) Q:'AT  S P=AT-1
	Q P
; spaces/tabs only (CR is NOT indentation whitespace)
ALLWS(S)
	N I,C,OK
	S OK=1,S=$G(S)
	F I=1:1:$L(S) D  Q:'OK
	. S C=$E(S,I)
	. I (C'=" ")&(C'=$C(9)) S OK=0
	Q OK
	;
CUTNX(S) ; drop leading [spaces/tabs]* then ONE LF
	N J,C,L
	S S=$G(S) I S="" Q ""
	S L=$L(S)
	F J=1:1:L S C=$E(S,J) Q:(C'=" ")&(C'=$C(9))
	I J>L Q S
	I $E(S,J)=$C(10) Q $E(S,J+1,L)
	Q S
; =============================================================================
; CUTNX1(S)
; Remove leading spaces/tabs/CR then remove one newline:
;  - if CRLF -> remove both
;  - else LF -> remove LF
; =============================================================================
CUTNX1(S)
	N J,C,L
	S S=$G(S),L=$L(S)
	I L=0 Q ""
	; skip leading ws excluding LF
	F J=1:1:L S C=$E(S,J) Q:(C'=" ")&(C'=$C(9))&(C'=$C(13))
	I J>L Q S
	; now at first non-(space/tab/CR)
	I $E(S,J)=$C(10) Q $E(S,J+1,L)            ; LF
	; if we landed on CR (unlikely here), allow CRLF handling
	I $E(S,J)=$C(13),$E(S,J+1)=$C(10) Q $E(S,J+2,L)
	Q S
	;
; --- helpers ---
; =============================================================================
; NORMNL(S)
; Normalize newlines: CRLF -> LF, CR -> LF
; =============================================================================
NORMNL(S)
	N I,L,CH,NXT,OUT
	S S=$G(S),OUT="",L=$L(S),I=1
	F  Q:I>L  D
	. S CH=$E(S,I)
	. I CH=$C(13) D  Q
	. . ; CRLF -> single LF
	. . S NXT=$S(I<L:$E(S,I+1),1:"")
	. . I NXT=$C(10) S OUT=OUT_$C(10),I=I+2 Q
	. . ; lone CR -> LF
	. . S OUT=OUT_$C(10),I=I+1
	. ; normal char
	. S OUT=OUT_CH,I=I+1
	Q OUT
TAILWS(S)
	N P,TAIL
	S S=$G(S)
	S P=$$LASTNLSEQ(S)
	S TAIL=$S(P>0:$E(S,P+1,$L(S)),1:S)
	Q $$ALLWS(TAIL)
LASTNLSEQ(S) ; position of last newline char in last newline sequence (CRLF->LF pos)
	N I,L,P
	S S=$G(S),L=$L(S),P=0
	F I=1:1:L D
	. I $E(S,I)=$C(10) S P=I
	. I $E(S,I)=$C(13) D
	. . ; if CRLF, consider LF as the newline "end"
	. . I (I<L),$E(S,I+1)=$C(10) S P=I+1
	. . E  S P=I
	Q P
; =============================================================================
; HASNL(S)
; Return 1 if S contains ANY newline char (LF or CR), else 0
; =============================================================================
HASNL(S)
	Q:($F($G(S),$C(10))>0) 1
	Q:($F($G(S),$C(13))>0) 1
	Q 0
	;
; =============================================================================
; LASTNL(S)
; Position of the *last* newline sequence end.;
; For CRLF treat the newline as ending at LF (position of LF).;
; For lone CR treat as CR position.;
; For lone LF treat as LF position.;
; Returns 0 if none.;
; =============================================================================
LASTNL(S) ; position of last newline char (LF or CR), 0 if none
	N P10,P13
	S S=$G(S)
	S P10=$$LASTCHR(S,$C(10))
	S P13=$$LASTCHR(S,$C(13))
	Q $S(P10>P13:P10,1:P13)
LASTCHR(S,CH)
	N P,AT
	S S=$G(S),P=0,AT=0
	F  S AT=$F(S,CH,AT+1) Q:'AT  S P=AT-1
	Q P	
CUTNXNL(S) ; drop leading indent (space/tab) then ONE newline seq (CRLF/LF/CR)
	N J,C,L
	S S=$G(S),L=$L(S)
	I L=0 Q ""
	; skip indentation (space/tab only)
	F J=1:1:L S C=$E(S,J) Q:(C'=" ")&(C'=$C(9))
	I J>L Q S
	;
	; remove one newline sequence
	I $E(S,J)=$C(13) D  Q $E(S,J+1,L)
	. ; if CRLF, also drop following LF
	. I (J<L),$E(S,J+1)=$C(10) S J=J+1
	;
	I $E(S,J)=$C(10) Q $E(S,J+1,L)
	;
	Q S
LINEPUREB(TOK,I,MAX) ; like LINEPURE, but ignores parS tokens (inheritance blocks)
	N J,TYP,OK,FOUND
	S OK=1
	; scan left until newline boundary
	S FOUND=0
	F J=I-1:-1:1 Q:'OK  D  Q:FOUND
	. S TYP=$G(TOK(J,"t"))
	. I TYP="parS" Q  ; ignore parent/include start on same line
	. I TYP'="text" S OK=0 Q
	. I $$HASNL($G(TOK(J,"v"))) S FOUND=1
	; scan right until newline boundary
	S FOUND=0
	F J=I+1:1:MAX Q:'OK  D  Q:FOUND
	. S TYP=$G(TOK(J,"t"))
	. I TYP="parS" Q  ; defensive (shouldn't occur to the right)
	. I TYP'="text" S OK=0 Q
	. I $$HASNL($G(TOK(J,"v"))) S FOUND=1
	Q OK
CUTPRE(S) ; keep up to and including last newline sequence; drop indentation after it
	N P
	S S=$G(S)
	S P=$$LASTNLSEQ(S)
	Q $S(P>0:$E(S,1,P),1:"")
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
	;
ADDSECS(TOK,N,KEY,INV,BPOS)
	S N=N+1
	S TOK(N,"t")="secS"
	S TOK(N,"k")=KEY
	S TOK(N,"inv")=+$G(INV)
	;
	; Legacy block capture support: {{#block:name}} ... {{/block:name}}
	; Captured content stored into CTX("blocks",name) during render.;
	I $E($G(KEY),1,6)="block:" D
	. S TOK(N,"blk")=1
	. S TOK(N,"bname")=$E(KEY,7,$L(KEY))
	;
	; raw body start position in source text (after close delimiter)
	I $G(BPOS)>0 S TOK(N,"bpos")=+BPOS
	Q
	;
ADDSECE(TOK,N,KEY,OPOS)
	S N=N+1
	S TOK(N,"t")="secE"
	S TOK(N,"k")=KEY
	; open delimiter start position for this end tag (for raw slicing)
	I $G(OPOS)>0 S TOK(N,"opos")=+OPOS
	Q
	;
ADDPART(TOK,N,NAME)
	S N=N+1
	S TOK(N,"t")="part"
	S TOK(N,"k")=NAME
	Q
	;
ADDDELIM(TOK,N,OD,CD)
	S N=N+1
	S TOK(N,"t")="delim"
	S TOK(N,"od")=OD
	S TOK(N,"cd")=CD
	Q
	;
ADDPARENT(TOK,N,NAME,BPOS)
	S N=N+1
	S TOK(N,"t")="parS"
	S TOK(N,"k")=NAME
	I $G(BPOS)>0 S TOK(N,"bpos")=+BPOS
	Q
	;
ADDBLOCK(TOK,N,NAME,BPOS)
	S N=N+1
	S TOK(N,"t")="blkS"
	S TOK(N,"k")=NAME
	I $G(BPOS)>0 S TOK(N,"bpos")=+BPOS
	Q
	;
	;
LINKSECS(TOK,ERR)
	; Precompute matching indices for sections, blocks, and parents.;
	; - TOK(i,"m") stored on start token to point to matching end token index.;
	; - Also computes TOK(start,"raw") from TOK("meta","src") using stored bpos/opos when available (for lambdas).;
	K ERR
	N STK,SP,I,T,K,TOP,TT
	S SP=0
	S I=0
	F  S I=$O(TOK(I)) Q:'I  D  Q:$D(ERR)
	. S T=$G(TOK(I,"t"))
	. I (T="secS")!(T="parS")!(T="blkS") D  Q
	. . S SP=SP+1
	. . S STK(SP,"i")=I
	. . S STK(SP,"k")=$G(TOK(I,"k"))
	. . S STK(SP,"t")=T
	. I T="secE" D  Q
	. . S K=$G(TOK(I,"k"))
	. . I SP<1 S ERR("code")="TPL_PARSE",ERR("msg")="Section end without start: "_K Q
	. . S TOP=$G(STK(SP,"k"))
	. . I TOP'=K S ERR("code")="TPL_PARSE",ERR("msg")="Section mismatch: expected /"_TOP_" got /"_K Q
	. . N SI S SI=STK(SP,"i")
	. . S TOK(SI,"m")=I
	. . ; If we have source offsets, compute raw body
	. . I $D(TOK("meta","src")),$G(TOK(SI,"bpos"))>0,$G(TOK(I,"opos"))>0 D
	. . . N BS,BE S BS=+TOK(SI,"bpos"),BE=+TOK(I,"opos")-1
	. . . I BE'<BS S TOK(SI,"raw")=$E(TOK("meta","src"),BS,BE)
	. . S SP=SP-1
	I SP>0 D
	. S ERR("code")="TPL_PARSE",ERR("msg")="Unclosed section: "_$G(STK(SP,"k"))
	Q
EVAL(TOK,CONF,CTX,OUT,ERR)
	K ERR
	N CST,CTSP
	S CTSP=1
	S CST(1)="CTX"
	; Partial recursion protection
	N PDEPTHMAX S PDEPTHMAX=+$G(CONF("templates","maxPartialDepth")) I PDEPTHMAX<1 S PDEPTHMAX=20
	N PACTIVEN,IACTIVE ; inheritance recursion protection (keyed by parent#ovID)
	;Temp Array
	N TMPTARR
	; Local storage for partial token arrays
	N PTID,PTOKS
	S PTID=0
	; Block capture buffers keyed by frame#
	N BCAP
	; Frame stack
	N FSP,F
	S FSP=1
	S F(1,"i")=1
	S F(1,"end")=$$TOKENDR("TOK")
	S F(1,"ctxTop")=CTSP
	S F(1,"mode")="emit"
	S F(1,"capRef")=""
	S F(1,"tokName")="TOK"
	S OUT=""
	; Delimiter state (used for lambdas re-rendering)
	N DOD,DCD S DOD="{{",DCD="}}"
	; Inheritance override token storage
	N OVID,OVT S OVID=0
	; Safety limit
	N FRAMELIM,FRAMES
	S FRAMELIM=2000,FRAMES=0
	; Main loop
	F  Q:FSP<1  D  Q:$D(ERR)
	. S FRAMES=FRAMES+1
	. I FRAMES>FRAMELIM S ERR("code")="TPL_LIMIT",ERR("msg")="Render exceeded safety frame limit." Q
	. ; ITERATOR controller
	. I $G(F(FSP,"mode"))="iter" D  Q
	. . N LREF,SUB,BS,BE,PM,PC,PARENTMODE,PARENTCAP
	. . S LREF=$G(F(FSP,"listRef"))
	. . S SUB=$G(F(FSP,"sub"))
	. . S BS=+$G(F(FSP,"bodyS"))
	. . S BE=+$G(F(FSP,"bodyE"))
	. . S PARENTMODE=$G(F(FSP,"parentMode"))
	. . S PARENTCAP=$G(F(FSP,"parentCap"))
	. . ; next element
	. . S SUB=$O(@($$APPREF^MIOTPL2(LREF,SUB)))
	. . I SUB="" D POPF^MIOTPL2(.FSP,.F,.CST,.CTSP) Q
	. . S F(FSP,"sub")=SUB
	. . ; push item context and render body once
	. . N ITEMREF,NEWTOP
	. . S ITEMREF=$$APPREF^MIOTPL2(LREF,SUB)
	. . S NEWTOP=CTSP+1,CST(NEWTOP)=ITEMREF,CTSP=NEWTOP
	. . D PUSHFRAME^MIOTPL2(.FSP,.F,BS,BE,CTSP,PARENTMODE,PARENTCAP,F(FSP-1,"tokName"))
	. ; Fetch current token
	. N I,END,TN,TYP
	. S I=+$G(F(FSP,"i"))
	. S END=+$G(F(FSP,"end"))
	. I I<1!(I>END) D POPF^MIOTPL2(.FSP,.F,.CST,.CTSP) Q
	. S TN=$G(F(FSP,"tokName")) I TN="" S TN="TOK"
	. S TYP=$$TOKGET(TN,I,"t")
	. ; Comments and delimiter changes emit nothing
	. I TYP="comm" S F(FSP,"i")=I+1 Q
	. I TYP="delim" D  S F(FSP,"i")=I+1 Q
	. . S DOD=$$TOKGET(TN,I,"od")
	. . S DCD=$$TOKGET(TN,I,"cd")
	. ;
	. ; Inheritance parent tag {{<parent}}...{{/parent}}
	. I TYP="parS" D  Q
	. . N MI,PNAME,PTID,PMAX,OVIDX
	. . S MI=+$$TOKGET(TN,I,"m") I MI<1 S ERR("code")="TPL_EVAL",ERR("msg")="Unmatched parent tag." Q
	. . S PNAME=$$TOKGET(TN,I,"k")
	. . ; collect overrides from child body (blocks only)
	. . S OVID=OVID+1,OVIDX=OVID
	. . K OVT(OVIDX)
	. . D COLLOVR^MIOTPL2(TN,I+1,MI-1,OVIDX,.OVT)
	. . ; inherit/merge overrides from current frame into this include's overrides	
	. . N POVID,BN
	. . S POVID=+$G(F(FSP,"ovID"))
	. . I POVID>0,$D(OVT(POVID)) D
	. . . ; if child body has no overrides, reuse inherited ovID
	. . . I $O(OVT(OVIDX,""))="" K OVT(OVIDX) S OVIDX=POVID Q
	. . . ; else copy missing overrides from inherited into local (local wins)
	. . . S BN=""
	. . . F  S BN=$O(OVT(POVID,BN)) Q:BN=""  D
	. . . . I '$D(OVT(OVIDX,BN)) D
	. . . . . ; MERGE the whole token subtree (critical!)
	. . . . . M OVT(OVIDX,BN)=OVT(POVID,BN)
	. . ; recursion protection for inherited templates: key by parent name + ovID
	. . S IK=PNAME_"#"_OVIDX
	. . I $G(IACTIVE(IK))>0 Q
	. . S IACTIVE(IK)=+$G(IACTIVE(IK))+1
	. . ; advance parent first
	. . S F(FSP,"i")=MI+1
	. . ; load parent as partial
	. . S PTID=+$G(F(FSP,"ptid"))+1 S F(FSP,"ptid")=PTID
	. . N TMPTARR K TMPTARR
	. . D GETTOK^MIOTPL2(PNAME,.CONF,.TMPTARR,.ERR) Q:$D(ERR)
	. . M PTOKS(PTID)=TMPTARR K TMPTARR
	. . S PMAX=$$TOKENDR^MIOTPL2("PTOKS("_PTID_")")
	. . I PMAX<1 Q
	. . D PUSHFRAME^MIOTPL2(.FSP,.F,1,PMAX,CTSP,$G(F(FSP,"mode")),$G(F(FSP,"capRef")),"PTOKS("_PTID_")")
	. . ; attach override id to new frame
	. . S F(FSP,"ovID")=OVIDX
	. . S F(FSP,"pname")=PNAME
	. . S F(FSP,"ikey")=IK
	. ;
	. ; Block tag {{$name}}...{{/name}}
	. I TYP="blkS" D  Q
	. . N MI,BNAME,OVIDX,OVTN,OMAX
	. . S MI=+$$TOKGET(TN,I,"m") I MI<1 S ERR("code")="TPL_EVAL",ERR("msg")="Unmatched block tag." Q
	. . S BNAME=$$TOKGET(TN,I,"k")
	. . ; advance parent first
	. . S F(FSP,"i")=MI+1
	. . S OVIDX=+$G(F(FSP,"ovID"))
	. . I OVIDX>0,$D(OVT(OVIDX,BNAME)) D  Q
	. . . S OVTN="OVT("_OVIDX_","""_BNAME_""")"
	. . . S OMAX=$$TOKENDR^MIOTPL2(OVTN)
	. . . I OMAX>0 D PUSHFRAME^MIOTPL2(.FSP,.F,1,OMAX,CTSP,$G(F(FSP,"mode")),$G(F(FSP,"capRef")),OVTN)
	. . ; default block content
	. . D PUSHFRAME^MIOTPL2(.FSP,.F,I+1,MI-1,CTSP,$G(F(FSP,"mode")),$G(F(FSP,"capRef")),TN)
	. ; TEXT
	. I TYP="text" D  Q
	. . D EMIT^MIOTPL2(.FSP,.F,.OUT,$$TOKGET(TN,I,"v"))
	. . S F(FSP,"i")=I+1
	. ; VAR
	. I TYP="var" D  Q
	. . N KEY,ESC,VAL,ISSET,TYPE,REF,LT,LO,LE
	. . S KEY=$$TOKGET(TN,I,"k")
	. . S ESC=+$$TOKGET(TN,I,"e")
	. . ; lambdas: value is callable -> call, then re-render
	. . D RESREF^MIOTPL2(KEY,.CST,CTSP,.ISSET,.TYPE,.REF)
	. . I ISSET,TYPE="lambda" D  S F(FSP,"i")=I+1 Q
	. . . S VAL=$$LAM0^MIOTPL2(REF,$S(ESC:1,1:0),DOD,DCD,.CONF,.CST,CTSP,.ERR)
	. . . I $D(ERR) Q
	. . . D EMIT^MIOTPL2(.FSP,.F,.OUT,VAL)
	. . ; normal variable
	. . S VAL=$$RESVAL^MIOTPL2(KEY,.CST,CTSP)
	. . I ESC S VAL=$$ESCHTML^MIOTPL2(VAL)
	. . D EMIT^MIOTPL2(.FSP,.F,.OUT,VAL)
	. . S F(FSP,"i")=I+1
	. ; PARTIAL
	. ; COMMENT (no output)
	. I TYP="comm" D  Q
	. . S F(FSP,"i")=I+1
	. I TYP="part" D  Q
	. . N PNAME,IND,MODE,CAP,PMAX
	. . S PNAME=$$TOKGET(TN,I,"k")
	. . ; dynamic partial names: {{>*name}} resolves name from context
	. . I $E(PNAME)="*" D
	. . . N DKEY S DKEY=$E(PNAME,2,$L(PNAME))
	. . . I (DKEY="")!(DKEY["*") S PNAME="" Q
	. . . S PNAME=$$RESVAL^MIOTPL2(DKEY,.CST,CTSP)
	. . S IND=$$TOKGET(TN,I,"indent")  ; may be ""
	. . ; advance parent now
	. . S F(FSP,"i")=I+1
	. . ; recursion control (SAFE)
	. . S PACTIVE(PNAME)=+$G(PACTIVE(PNAME))
	. . I (PACTIVE(PNAME)+1)>PDEPTHMAX S ERR("code")="TPL_PARTIAL_DEPTH",ERR("msg")="Partial recursion depth exceeded: "_PNAME Q
	. . S PACTIVE(PNAME)=PACTIVE(PNAME)+1
	. . ; load partial tokens
	. . S PTID=PTID+1
	. . K PTOKS(PTID),TMPTARR
	. . D GETTOK^MIOTPL2(PNAME,.CONF,.TMPTARR,.ERR)
	. . M PTOKS(PTID)=TMPTARR K TMPTARR
	. . I $D(ERR) D  I $D(ERR) Q
	. . . N EC S EC=$G(ERR("code"))
	. . . I (EC="TPL_NOFILE")!(EC="TPL_IO") D  Q
	. . . . S PACTIVE(PNAME)=+$G(PACTIVE(PNAME))-1
	. . . . I PACTIVE(PNAME)'>0 K PACTIVE(PNAME)
	. . . . K ERR
	. . ; compute PMAX safely (numeric-only)
	. . S PMAX=$$TOKENDR^MIOTPL2("PTOKS("_PTID_")")
	. . I PMAX<1 D  Q
	. . . S PACTIVE(PNAME)=+$G(PACTIVE(PNAME))-1
	. . . I PACTIVE(PNAME)'>0 K PACTIVE(PNAME)
	. . ;
	. . ; if IND, indent the PARTIAL TOKENS (template newlines only) BEFORE rendering
	. . I IND'="" D
	. . . K TMPTARR M TMPTARR=PTOKS(PTID)
	. . . D INDENTPTOK^MIOTPL2(.TMPTARR,IND)
	. . . K PTOKS(PTID) M PTOKS(PTID)=TMPTARR K TMPTARR
	. . . S PMAX=$$TOKENDR^MIOTPL2("PTOKS("_PTID_")")  ; recompute after rewrite
	. . ;
	. . S MODE=$G(F(FSP,"mode"))
	. . S CAP=$G(F(FSP,"capRef"))
	. . D PUSHFRAME^MIOTPL2(.FSP,.F,1,PMAX,CTSP,MODE,CAP,"PTOKS("_PTID_")")
	. . S F(FSP,"pname")=PNAME
	. I TYP="secS" D  Q
	. . N KEY,INV,MI,NEXT,PARENT
	. . S PARENT=FSP
	. . S KEY=$$TOKGET(TN,I,"k")
	. . S INV=+$$TOKGET(TN,I,"inv")
	. . S MI=+$$TOKGET(TN,I,"m")
	. . I 'MI S ERR("code")="TPL_PARSE",ERR("msg")="Section start without match: "_KEY Q
	. . ; advance parent beyond close now (so we never double-run)
	. . S NEXT=MI+1
	. . S F(PARENT,"i")=NEXT
	. . ; block capture
	. . I +$$TOKGET(TN,I,"blk") D  Q
	. . . N BNAME,NEWF,CAPREF
	. . . S BNAME=$$TOKGET(TN,I,"bname")
	. . . S NEWF=FSP+1
	. . . S BCAP(NEWF)=""
	. . . S CAPREF=$NA(BCAP(NEWF))
	. . . D PUSHFRAME^MIOTPL2(.FSP,.F,I+1,MI-1,CTSP,"capture",CAPREF,TN)
	. . . S F(FSP,"storeBlock")=1
	. . . S F(FSP,"storeName")=BNAME
	. . . S F(FSP,"storeCapRef")=CAPREF
	. . ; resolve key
	. . N ISSET,TYPE,REF
	. . D RESREF^MIOTPL2(KEY,.CST,CTSP,.ISSET,.TYPE,.REF)
	. . ; --- normalize: if "list" but first subscript is non-numeric, it's an object/hash
	. . I TYPE="list" D
	. . . N S0 S S0=$$FIRSTSUB^MIOTPL2(REF)
	. . . I S0'="",S0'?1.N S TYPE="obj"
	. . ; lambda section: call with raw section text, then render result with current delimiters
	. . I ISSET,TYPE="lambda" D  Q
	. . . I INV Q  ; lambdas are truthy => inverted sections do not render
	. . . N RAW,VAL
	. . . S RAW=$G(TOK(I,"raw"))
	. . . S VAL=$$LAM1^MIOTPL2(REF,RAW,DOD,DCD,.CONF,.CST,CTSP,.ERR)
	. . . I $D(ERR) Q
	. . . D EMIT^MIOTPL2(.FSP,.F,.OUT,VAL)
	. . ; inverted
	. . I INV D  Q
	. . . I $$ISTRUTH^MIOTPL2(.ISSET,.TYPE,.REF)=0 D
	. . . . D PUSHFRAME^MIOTPL2(.FSP,.F,I+1,MI-1,CTSP,$G(F(PARENT,"mode")),$G(F(PARENT,"capRef")),TN)
	. . ; normal: skip if falsey
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
	. . ; object context: push
	. . I TYPE="obj" D  Q
	. . . N NEWTOP S NEWTOP=CTSP+1
	. . . S CST(NEWTOP)=REF,CTSP=NEWTOP
	. . . D PUSHFRAME^MIOTPL2(.FSP,.F,I+1,MI-1,CTSP,$G(F(PARENT,"mode")),$G(F(PARENT,"capRef")),TN)
	. . ; scalar context: push (so {{.}} works)
	. . I TYPE="scalar" D  Q
	. . . N NEWTOP S NEWTOP=CTSP+1
	. . . S CST(NEWTOP)=REF,CTSP=NEWTOP
	. . . D PUSHFRAME^MIOTPL2(.FSP,.F,I+1,MI-1,CTSP,$G(F(PARENT,"mode")),$G(F(PARENT,"capRef")),TN)
	. . ; fallback
	. . D PUSHFRAME^MIOTPL2(.FSP,.F,I+1,MI-1,CTSP,$G(F(PARENT,"mode")),$G(F(PARENT,"capRef")),TN)
	. ; SECTION END-
	. I TYP="secE" D  Q
	. . S F(FSP,"i")=I+1
	I $G(TOK("meta","crlf")) S OUT=$$LF2CRLF^MIOTPL2(OUT)
	Q:$Q $S($D(ERR):0,1:1)
	Q
; =============================================================================
; INDENTPTOK(.TOK,IND)
; Indent partial TEMPLATE lines only:
;  - Indent text tokens at template line starts
;  - If a template line begins with a NON-text token (var/sec/part), inject
;    a leading text token containing IND before it.;
; This avoids indenting newlines produced by variable values (passes TEST109).;
; =============================================================================
INDENTPTOK(TOK,IND)
	N TMP,MAX,I,NEWN,LS,AT,TYP,V,S
	S IND=$G(IND) Q:IND=""
	;
	; preserve any non-numeric subscripts (e.g. "meta")
	K TMP
	S S=""
	F  S S=$O(TOK(S)) Q:S=""  D
	. I S?1.N Q
	. M TMP(S)=TOK(S)
	;
	S MAX=$$NUMMAX(.TOK)
	S NEWN=0
	S LS=1  ; start-of-partial is line start
	S AT=1  ; for INDTXT
	;
	F I=1:1:MAX D
	. S TYP=$G(TOK(I,"t"))
	. ;
	. ; if we're at template line start and next token is non-text,
	. ; inject indent as a text token
	. I LS,(TYP'="text") D
	. . S NEWN=NEWN+1
	. . S TMP(NEWN,"t")="text"
	. . S TMP(NEWN,"v")=IND
	. . S LS=0,AT=0
	. ;
	. ; copy token
	. S NEWN=NEWN+1
	. M TMP(NEWN)=TOK(I)
	. ;
	. ; if text, indent within it at template line starts
	. I TYP="text" D
	. . S V=$G(TMP(NEWN,"v"))
	. . ; AT tells INDTXT whether we're at a template line start
	. . S AT=LS
	. . S TMP(NEWN,"v")=$$INDTXT(V,IND,.AT)
	. . ; update LS: if (original) text ends with LF, next token starts a new line
	. . I $L(V)>0,$E(V,$L(V))=$C(10) S LS=1 Q
	. . S LS=0
	. E  D
	. . ; non-text token is not a line break by itself
	. . S LS=0
	;
	K TOK M TOK=TMP
	Q
ADDCOMM(TOK,N)
	S N=N+1
	S TOK(N,"t")="comm"
	Q
; =============================================================================
; INDTXT(V,IND,.AT)
; If AT=1, prepend IND before first emitted char in this token line.;
; After each LF in TEMPLATE text, insert IND for the next template line *only
; if more text follows inside this same token*; otherwise AT=1 so the next token
; on that new template line is handled (including non-text via injected token).;
; =============================================================================
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
	;
TOCRLF(S)
	N I,N,OUT
	S S=$G(S)
	S N=$L(S,$C(10))
	I N<2 Q S
	S OUT=$P(S,$C(10),1)
	F I=2:1:N S OUT=OUT_$C(13,10)_$P(S,$C(10),I)
	Q OUT
; =============================================================================
; TOKGET(TN,I,FIELD)  -- safe token getter
; TN examples: "TOK" or "PTOKS(3)"
; =============================================================================
TOKGET(TN,I,FIELD)
	N R
	I TN["(" D
	. ; splice before final ')'
	. S R=$E(TN,1,$L(TN)-1)_","_I_","""_FIELD_""")"
	E  D
	. S R=TN_"("_I_","""_FIELD_""")"
	Q $G(@R)
	;
; =============================================================================
; TOKENDR(TOKNAME)
; Return the last NUMERIC token index in token root TOKNAME.;
; (Ignores string subscripts like TOK("meta",...))
; =============================================================================
	;
TOKENDR(TOKR)
	; Return last numeric token index in token root TOKR.;
	; TOKR may be "TOK" or "PTOKS(3)" or "OVT(1,\"name\")", etc.;
	N I,MAX,BASE
	S MAX=0,I=0
	I TOKR["(" D  Q MAX
	. S BASE=$E(TOKR,1,$L(TOKR)-1) ; drop trailing ')'
	. F  S I=$O(@(BASE_","_I_")")) Q:I=""  D
	. . I I?1.N,I>MAX S MAX=I
	F  S I=$O(@TOKR@(I)) Q:I=""  D
	. I I?1.N,I>MAX S MAX=I
	Q MAX
REPL(s,f,t)
	i $tr(s,f)=s q s
	n o,i s o="" f i=1:1:$l(s,f)  s o=o_$s(i<$l(s,f):$p(s,f,i)_t,1:$p(s,f,i))
	q o
; =============================================================================
; PUSHFRAME(FSP,F,START,END,CTSP,MODE,CAPREF,TOKNAME)
; =============================================================================
PUSHFRAME(FSP,F,START,END,CTSP,MODE,CAPREF,TOKNAME)
	S FSP=FSP+1
	S F(FSP,"i")=START
	S F(FSP,"end")=END
	S F(FSP,"ctxTop")=CTSP
	S F(FSP,"mode")=$G(MODE,"emit")
	S F(FSP,"capRef")=$G(CAPREF)
	S F(FSP,"tokName")=$G(TOKNAME,"TOK")
	S F(FSP,"ovID")=$G(F(FSP-1,"ovID"))
	Q
	;
	;
; =============================================================================
; POPF(FSP,F,CST,CTSP)
; (Uses CTX, PACTIVE in outer scope)
; =============================================================================
POPF(FSP,F,CST,CTSP)
	N OLD S OLD=FSP
	;
	; Block store finalizer
	I +$G(F(OLD,"storeBlock")) D
	. N BN,CR,VAL
	. S BN=$G(F(OLD,"storeName"))
	. S CR=$G(F(OLD,"storeCapRef"))
	. S VAL=$G(@CR)
	. S CTX("blocks",BN)=VAL
	;
	; Partial decrement finalizer
	I $G(F(OLD,"pname"))'="" D
	. N PN S PN=$G(F(OLD,"pname"))
	. S PACTIVE(PN)=+$G(PACTIVE(PN))-1
	. I PACTIVE(PN)<1 K PACTIVE(PN)
	;
	; inherit recursion finalizer
	I $G(F(OLD,"ikey"))'="" D
	. N IK S IK=$G(F(OLD,"ikey"))
	. S IACTIVE(IK)=+$G(IACTIVE(IK))-1
	. I IACTIVE(IK)<1 K IACTIVE(IK)
	;
	; capEmit finalizer (indented partial emit)
	I +$G(F(OLD,"capEmit")) D
	. N IND,VAL
	. S IND=$G(F(OLD,"indent"))
	. S VAL=$G(@$G(F(OLD,"capRef")))
	. I IND'="" S VAL=$$INDENTTXT^MIOTPL2(VAL,IND)
	. D EMIT^MIOTPL2(.FSP,.F,.OUT,VAL)
	;
	; >>> ADD THIS: Inheritance override capture finalizer <<<
	; Inheritance override capture finalizer ({{<parent}} {{$block}}..{{/block}} {{/parent}})
	I $G(F(OLD,"ovrName"))'="" D
	. N CR,VAL,OR
	. S CR=$G(F(OLD,"capRef"))
	. S VAL=$S(CR'="":$G(@CR),1:"")
	. S OR=$G(F(OLD,"ovrRef"))
	. I OR'="" S @OR=VAL
	. K F(OLD,"ovrName"),F(OLD,"ovrPar"),F(OLD,"ovrRef")
	;
	; Pop and restore CTSP
	S FSP=FSP-1
	I FSP>0 S CTSP=+$G(F(FSP,"ctxTop"))
	Q
; =============================================================================
; LF2CRLF(S)  Convert LF -> CRLF
; =============================================================================
LF2CRLF(S)
	N LF,N,I,OUT
	S LF=$C(10)
	S N=$L($G(S),LF)
	I N<2 Q $G(S)  ; no LF present
	;
	S OUT=$P(S,LF,1)
	F I=2:1:N S OUT=OUT_$C(13,10)_$P(S,LF,I)
	Q OUT
; =============================================================================
; TOKMAX(TOKNAME)
; Return last numeric token index for an array referenced by name (e.g. "TOK", "PTOKS(3)")
; =============================================================================
TOKMAX(TOKNAME)
	Q $$TOKENDR(TOKNAME)
	;
	;
; =============================================================================
; FIRSTSUB(REF)  (fix for INDEXTRACHARS everywhere)
; =============================================================================
FIRSTSUB(REF)
	N CHREF
	S CHREF=$$APPREF^MIOTPL2(REF,"")
	Q $O(@CHREF)
	;
; =============================================================================
; EMIT(FSP,F,OUT,VAL)
; Emits to OUT or capture buffer depending on current frame mode.;
; =============================================================================
EMIT(FSP,F,OUT,VAL)
	N MODE S MODE=$G(F(FSP,"mode"))
	I MODE="capture" D  Q
	. N CR S CR=$G(F(FSP,"capRef")) Q:CR=""
	. S @CR=$G(@CR)_$G(VAL)
	S OUT=$G(OUT)_$G(VAL)
	Q
; =============================================================================
; TOKEND(TOKR)
; Return the last numeric token index in token root TOKR.;
; =============================================================================
TOKEND(TOKR)
	Q $$TOKENDR(TOKR)
	;
; =============================================================================
; TOKG(TOKR,I,FIELD)
; Safe token field getter using a $NA(...) root.;
; =============================================================================
TOKG(TOKR,I,FIELD)
	Q $G(@(TOKR_"("_I_","""_FIELD_""")"))
	;
	;	
	;
;=====================================================
; RESREF(KEY,CST,CTSP,ISSET,TYPE,REF)
; Resolve KEY using Mustache lookup rules.;
; REF is a reference-string like: CTX("groups","items",1)
; =============================================================================
RESREF(KEY,CST,CTSP,ISSET,TYPE,REF)
	N K S K=KEY
	S ISSET=0,TYPE="missing",REF=""
	I K="" Q
	;
	; {{.}} : current context (scalar OR obj/list)  (your fixed version)
	I K="." D  Q
	. N R S R=$G(CST(CTSP)) Q:R=""
	. I '$D(@R) S ISSET=0,TYPE="missing",REF="" Q
	. I $D(@R)>1 D  Q
	. . N S0 S S0=$$FIRSTSUB^MIOTPL2(R)
	. . I S0'="" S ISSET=1,TYPE="list",REF=R Q
	. . S ISSET=1,TYPE="obj",REF=R Q
	. I $D(@R)#2 S ISSET=1,TYPE="scalar",REF=R Q
	. S ISSET=0,TYPE="missing",REF="" Q
	;
	; ------------------------------------------------------------------
	; DOTTED NAME PRECEDENCE (Mustache spec):
	; Resolve first segment via context stack; then resolve remaining
	; segments ONLY within that resolved ref (NO fallback).;
	; ------------------------------------------------------------------
	I K["." D  Q
	. N PARTS,PC,I,P1,LEVEL,BASE,OK1,TT1,RR1,CUR,NEXT
	. D SPLIT^MIOTPL2(K,".",.PARTS,.PC)
	. I PC<2 Q  ; safety
	. S P1=$G(PARTS(1)) I P1="" Q
	. ;
	. ; 1) Resolve first segment top-down
	. S OK1=0,TT1="missing",RR1=""
	. F LEVEL=CTSP:-1:1 Q:OK1  D
	. . S BASE=$G(CST(LEVEL)) Q:BASE=""
	. . D RESINBASE^MIOTPL2(BASE,P1,.OK1,.TT1,.RR1)
	. I 'OK1 S ISSET=0,TYPE="missing",REF="" Q
	. ;
	. ; If first segment is scalar but key continues => missing
	. I TT1="scalar" S ISSET=0,TYPE="missing",REF="" Q
	. ;
	. ; 2) Resolve remaining segments ONLY within RR1
	. S CUR=RR1
	. F I=2:1:PC D  Q:'ISSET
	. . S P=$G(PARTS(I))
	. . I P="" S ISSET=0,TYPE="missing",REF="" Q
	. . S NEXT=$$APPREF^MIOTPL2(CUR,P)
	. . I '$D(@NEXT) S ISSET=0,TYPE="missing",REF="" Q
	. . S CUR=NEXT,ISSET=1
	. I 'ISSET Q
	. ;
	. ; Determine final TYPE at CUR
	. I $D(@CUR)>1 D  Q
	. . N S0 S S0=$$FIRSTSUB^MIOTPL2(CUR)
	. . I S0'="" S TYPE="list",REF=CUR,ISSET=1 Q
	. . S TYPE="obj",REF=CUR,ISSET=1 Q
	. I $D(@CUR)#2 S TYPE="scalar",REF=CUR,ISSET=1 Q
	. S ISSET=0,TYPE="missing",REF="" Q
	;
	; ------------------------------------------------------------------
	; Non-dotted: existing behavior (top-down normal lookup)
	; ------------------------------------------------------------------
	N LEVEL
	F LEVEL=CTSP:-1:1 D  Q:ISSET
	. N BASE S BASE=$G(CST(LEVEL)) Q:BASE=""
	. N OK,RR,TT
	. D RESINBASE^MIOTPL2(BASE,K,.OK,.TT,.RR)
	. I OK S ISSET=1,TYPE=TT,REF=RR
	I $G(ISSET),$G(TYPE)="obj" D  ; detect lambda objects
	. I $$ISCODE^MIOTPL2(REF) S TYPE="lambda"
	Q
; =============================================================================
; RESINBASE(BASE,KEY,OK,TYPE,REF)
; Resolve dotted KEY within a single BASE reference-string.;
RESINBASE(BASE,KEY,OK,TYPE,REF)
	S OK=0,TYPE="missing",REF=""
	N CUR S CUR=BASE
	N PARTS,PC,I,P
	D SPLIT(KEY,".",.PARTS,.PC)
	I PC=0 Q
	; Walk dotted path
	F I=1:1:PC D  Q:'OK&(I>1)
	. S P=PARTS(I)
	. I P="." S OK=1 Q
	. N NEXT S NEXT=$$APPREF(CUR,P)
	. I '$D(@NEXT) S OK=0,TYPE="missing",REF="" Q
	. S CUR=NEXT,OK=1
	I 'OK Q
	I '$D(@CUR) Q
	;
	; Determine TYPE (IMPORTANT)
	I $D(@CUR)>1 D  Q
	. N S0 S S0=$$FIRSTSUB(CUR)
	. I S0=""  S OK=1,TYPE="obj",REF=CUR Q  ; has children flag but no subscripts (rare)
	. I S0?1.N S OK=1,TYPE="list",REF=CUR Q
	. S OK=1,TYPE="obj",REF=CUR Q
	;
	I $D(@CUR)#2 S OK=1,TYPE="scalar",REF=CUR Q
	S OK=0,TYPE="missing",REF=""
	Q
	;
; =============================================================================
; RESVAL(KEY,CST,CTSP)
; Variable resolution returns a scalar or "" if missing/non-scalar.;
; =============================================================================
RESVAL(KEY,CST,CTSP)
	N ISSET,TYPE,REF,V,VL
	D RESREF(KEY,.CST,CTSP,.ISSET,.TYPE,.REF)
	I 'ISSET Q ""
	I $D(@REF)#2 D  Q V
	. S V=$G(@REF)
	. ; normalize JSON null string -> empty
	. S VL=$ZCONVERT(V,"L")
	. I VL="null" S V=""
	Q ""
ISREF(REF)
	; Very small guard: our engine only stores local ref strings like "CTX(...)".;
	; Reject literals like "Joe" or empty.;
	N R S R=$G(REF)
	I R="" Q 0
	I $E(R,1)'?1A Q 0
	Q 1
; =============================================================================
; ISTRUTH(ISSET,TYPE,REF)
; Truthiness:
; False: missing, "", 0, "0", "false" (case-insensitive), empty list/object
; True : "true" (case-insensitive), any other non-empty scalar, non-empty list/object
; =============================================================================
ISTRUTH(ISSET,TYPE,REF)
	I 'ISSET Q 0
	; list/object: false if no subscripts
	I TYPE="list"!(TYPE="obj") Q $S($$FIRSTSUB(REF)="":0,1:1)
	;
	; scalar truthiness
	N V,VL
	S V=$G(@REF)
	;
	; empty is falsey
	I V="" Q 0
	;
	; normalize JSON null string -> falsey
	S VL=$ZCONVERT(V,"L")
	I VL="null" Q 0
	;
	; numeric/zero rules
	I V=0 Q 0
	I V="0" Q 0
	;
	; JSON booleans as strings
	I VL="false" Q 0
	I VL="true" Q 1
	;
	; default truthy
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
REPLXX(S,FROM,TO)
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
	;
	;
; =============================================================================
; Inheritance & Lambda helpers
; =============================================================================
ISCODE(REF)
	; True if REF points to a "code" object from mustache-spec JSON
	N T S T=$G(@REF@("__tag__"))
	I $ZCONVERT(T,"L")="code" Q 1
	Q 0
	;
TOKNODE(TN,IDX)
	; Build a node reference string for token IDX under token-root TN.;
	I TN["(" Q $E(TN,1,$L(TN)-1)_","_IDX_")"
	Q TN_"("_IDX_")"
	;
COLLOVR(TN,FROM,TO,OVIDX,OVT)
	; Collect block overrides from a child template body (inside a parent tag).;
	; Stores override token ranges into OVT(OVIDX,blockName,1..n,*)
	N I,TYP,MI,BNAME,NS,NE,N
	F I=FROM:1:TO D
	. S TYP=$$TOKGET^MIOTPL2(TN,I,"t")
	. Q:TYP'="blkS"
	. S MI=+$$TOKGET^MIOTPL2(TN,I,"m") Q:MI<1
	. Q:MI>TO
	. S BNAME=$$TOKGET^MIOTPL2(TN,I,"k")
	. ; copy range (I+1 .. MI-1)
	. K OVT(OVIDX,BNAME)
	. S N=0,NS=I+1,NE=MI-1
	. I NE<NS Q
	. N J,REF
	. F J=NS:1:NE D
	. . S N=N+1
	. . S REF=$$TOKNODE^MIOTPL2(TN,J)
	. . M OVT(OVIDX,BNAME,N)=@REF
	Q
	;
QSTR(S)
	; Quote a string for XECUTE (double-quote escaping)
	N X S X=$G(S)
	S X=$TR(X,"""","""""")
	Q """"_X_""""
	;
LAMCALL(REF)
	; Determine MUMPS callable entrypoint for a lambda object.;
	; Supported:
	;  - @REF@("mumps") = "TAG^ROU" or "$$TAG^ROU"
	;  - scalar @REF (rare): "TAG^ROU"
	N C
	S C=$G(@REF@("mumps"))
	I C="" S C=$G(@REF)
	I C="" Q ""
	I $E(C,1,2)="$$" S C=$E(C,3,$L(C))
	Q C
	;
CALL0(CALL,ERR)
	N $ETRAP S $ETRAP="S ERR(""code"")=""TPL_LAMBDA"",ERR(""msg"")=$ZSTATUS Q"
	N RES S RES=""
	I CALL="" S ERR("code")="TPL_LAMBDA",ERR("msg")="Lambda has no MUMPS entrypoint." Q ""
	X "S RES=$$"_CALL_"()"
	Q $G(RES)
	;
CALL1(CALL,ARG,ERR)
	N $ETRAP S $ETRAP="S ERR(""code"")=""TPL_LAMBDA"",ERR(""msg"")=$ZSTATUS Q"
	N RES S RES=""
	I CALL="" S ERR("code")="TPL_LAMBDA",ERR("msg")="Lambda has no MUMPS entrypoint." Q ""
	N A S A=$$QSTR^MIOTPL2($G(ARG))
	X "S RES=$$"_CALL_"("_A_")"
	Q $G(RES)
	;
LAMRENDER(TXT,OD,CD,CONF,CST,CTSP,ERR)
	; Compile+render TXT using top-of-stack context.;
	N LTOK,LERR,LOUT,TCTX
	K LTOK,LERR,LOUT,TCTX
	D COMPILE^MIOTPL2(TXT,.LTOK,.LERR,$G(OD,"{{"),$G(CD,"}}"))
	I $D(LERR) M ERR=LERR Q ""
	M TCTX=@CST(CTSP)
	D EVAL^MIOTPL2(.LTOK,.CONF,.TCTX,.LOUT,.LERR)
	I $D(LERR) M ERR=LERR Q ""
	Q $G(LOUT)
	;
LAM0(REF,ESC,DOD,DCD,CONF,CST,CTSP,ERR)
	; Interpolation lambda: call with no args; render with default delimiters; escape if ESC=1.;
	N CALL,TXT,VAL
	S CALL=$$LAMCALL^MIOTPL2(REF)
	S TXT=$$CALL0^MIOTPL2(CALL,.ERR) I $D(ERR) Q ""
	S VAL=$$LAMRENDER^MIOTPL2(TXT,"{{","}}",.CONF,.CST,CTSP,.ERR) I $D(ERR) Q ""
	I +$G(ESC) S VAL=$$ESCHTML^MIOTPL2(VAL)
	Q VAL
	;
LAM1(REF,RAW,OD,CD,CONF,CST,CTSP,ERR)
	; Section lambda: call with raw section string; render with current delimiters.;
	N CALL,TXT,VAL
	S CALL=$$LAMCALL^MIOTPL2(REF)
	S TXT=$$CALL1^MIOTPL2(CALL,$G(RAW),.ERR) I $D(ERR) Q ""
	S VAL=$$LAMRENDER^MIOTPL2(TXT,$G(OD,"{{"),$G(CD,"}}"),.CONF,.CST,CTSP,.ERR) I $D(ERR) Q ""
	Q VAL
	;
	;