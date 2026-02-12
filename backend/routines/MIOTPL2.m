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
	;
; =============================================================================
; START(CONF)
; Initialize template subsystem. Safe to call multiple times.;
; =============================================================================
MIOTEST 
	; 100-121 Coverage instrumentation per routines, to be implemented later
	; 120-125 D MIOTF120 *skipped* - Coverage instrumentation for a full test suite
	D MIOTF121,MIOTF122,MIOTF123,MIOTF124,MIOTF125
	D MIOTF126,MIOTF126B,MIOTF127,MIOTF128,MIOTF129,MIOTF130
	D MIOTF200,MIOTF201,MIOTF202,MIOTF203
	Q
	;
MIOTF200 D MIOTF200^MIOTPLT QUIT 
MIOTF201 D MIOTF201^MIOTPLT QUIT
MIOTF202 D MIOTF202^MIOTPLT QUIT
MIOTF203 D MIOTF203^MIOTPLT QUIT
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
	O FP:(READONLY:EXCEPTION="GOTO RFERR^MIOTPL2")
	U FP
	F  R LINE Q:$ZEOF  D  Q:('$T!$D(ERR))
	. ; Keep newlines. Most templates expect them.;
	. S TXT=TXT_LINE_$C(10)
	. I $L(TXT)>MAX S ERR("code")="TPL_TOOLARGE",ERR("msg")="Template too large (limit 2MB): "_FP
	I $D(ERR) Q 0
	C FP U IO
	S TXT=$E(TXT,1,$L(TXT)-1) ;get rid of the extra $C(10)
	Q 1
	;
RFERR ;
	C FP
	S ERR("code")="TPL_IO",ERR("msg")="I/O error reading template: "_FP
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
COMPILE(TEXT,TOK,ERR) ;
	DO PARSE(.TEXT,.TOK,.ERR)
	DO:'$D(ERR) LINKSECS(.TOK,.ERR)
	DO STANDTOK(.TOK) 
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
; =============================================================================
; PARSE(TEXT,TOK,ERR)
; =============================================================================
PARSE(TEXT,TOK,ERR)
	K ERR K TOK
	N L,POS,OPEN,CLOSE,PRE,INSIDE,RAW,END3,TRI
	N N S N=0
	;
	S L=$L(TEXT),POS=1
	F  Q:POS>L  D  Q:$D(ERR)
	. ; Find next {{
	. S OPEN=$F(TEXT,"{{",POS)
	. I 'OPEN D  Q
	. . S PRE=$E(TEXT,POS,L)
	. . I PRE'="" D ADDTXT(.TOK,.N,PRE)
	. . S POS=L+1
	. ;
	. ; Text before tag
	. S PRE=$E(TEXT,POS,OPEN-3)
	. I PRE'="" D ADDTXT(.TOK,.N,PRE)
	. ;
	. ; Triple mustache?  "{{{"
	. ; NOTE: OPEN points to the char immediately AFTER "{{"
	. S TRI=0
	. I $E(TEXT,OPEN)="{" S TRI=1
	. ;
	. I TRI D  Q
	. . S END3=$F(TEXT,"}}}",OPEN)
	. . I 'END3 S ERR("code")="TPL_PARSE",ERR("msg")="Unclosed triple mustache." Q
	. . ; inside is from after the 3rd "{" (OPEN+1) to before "}}}" (END3-4)
	. . S RAW=$E(TEXT,OPEN+1,END3-4)
	. . S RAW=$$TRIM(RAW)
	. . D ADDVAR(.TOK,.N,RAW,0)
	. . S POS=END3
	. ;
	. ; Normal mustache "{{ ... }}"
	. S CLOSE=$F(TEXT,"}}",OPEN)
	. I 'CLOSE S ERR("code")="TPL_PARSE",ERR("msg")="Unclosed mustache tag." Q
	. S INSIDE=$E(TEXT,OPEN,CLOSE-3)
	. S INSIDE=$$TRIM(INSIDE)
	. ;
	. ; Comments
	. I $E(INSIDE,1)="!" S POS=CLOSE Q
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
	. ;
	. ; Default: variable escaped
	. D ADDVAR(.TOK,.N,INSIDE,1)
	. S POS=CLOSE
	D STANDTOK(.TOK)
	Q
	;
; =============================================================================
; STANDTOK(TOK)
; Apply Mustache standalone line trimming at token level.;
; This does NOT remove the tag token, only surrounding whitespace/newline.;
; =============================================================================
STANDTOK(TOK)
	N I,MAX,TYP
	S MAX=+$O(TOK(""),-1) Q:MAX<1
	;
	F I=1:1:MAX D
	. S TYP=$G(TOK(I,"t"))
	. Q:(TYP'="secS")&(TYP'="secE")&(TYP'="part")
	. D STAND1(.TOK,I,MAX)
	Q
	;
; =============================================================================
; STAND1(TOK,I,MAX)
; If token I sits alone on its line (optionally indented), trim surrounding newline.;
; =============================================================================
STAND1(TOK,I,MAX)
	N POK,NOK,PV,NV
	; prev side must be start-of-file OR text token whose tail after last LF is all ws
	S POK=1
	I I>1 D
	. I $G(TOK(I-1,"t"))'="text" S POK=0 Q
	. S PV=$G(TOK(I-1,"v"))
	. I '$$TAILWS(PV) S POK=0
	Q:'POK
	;
	; next side must be end-of-file OR text token starting with ws then LF
	S NOK=1
	I I<MAX D
	. I $G(TOK(I+1,"t"))'="text" S NOK=0 Q
	. S NV=$G(TOK(I+1,"v"))
	. I '$$HEADWNL(NV) S NOK=0
	Q:'NOK
	;
	; trim prev indentation (ws after last LF)
	I I>1 S TOK(I-1,"v")=$$CUTPRE($G(TOK(I-1,"v")))
	; trim next leading ws + ONE LF
	I I<MAX S TOK(I+1,"v")=$$CUTNX($G(TOK(I+1,"v")))
	Q
	;
; --- helpers ---
	;
TAILWS(S) ; 1 if everything after last LF is ws (or no LF and whole string ws)
	N P,TAIL
	S S=$G(S)
	S P=$$LASTLF(S)
	S TAIL=$S(P>0:$E(S,P+1,$L(S)),1:S)
	Q $$ALLWS(TAIL)
	;
HEADWNL(S) ; 1 if starts with ws then LF (or empty string => allow EOF)
	N J,C
	S S=$G(S)
	I S="" Q 1
	F J=1:1:$L(S) S C=$E(S,J) Q:(C'=" ")&(C'=$C(9))&(C'=$C(13))
	I J>$L(S) Q 0
	Q $S($E(S,J)=$C(10):1,1:0)
	;
CUTPRE(S) ; keep up to last LF, drop any ws after it; if no LF, drop all
	N P
	S S=$G(S)
	S P=$$LASTLF(S)
	Q $S(P>0:$E(S,1,P),1:"")
	;
CUTNX(S) ; drop leading ws then one LF
	N J,C
	S S=$G(S)
	I S="" Q ""
	F J=1:1:$L(S) S C=$E(S,J) Q:(C'=" ")&(C'=$C(9))&(C'=$C(13))
	I J>$L(S) Q S
	I $E(S,J)'=$C(10) Q S
	Q $E(S,J+1,$L(S))
	;
ALLWS(S) ; spaces/tabs/CR only
	N I,C,Q S Q=1
	S S=$G(S)
	F I=1:1:$L(S) D  Q:$Q
	. S C=$E(S,I)
	. I (C'=" ")&(C'=$C(9))&(C'=$C(13)) S Q=0
	Q Q
	;
LASTLF(S) ; position of last LF, 0 if none
	N P,AT
	S S=$G(S),P=0,AT=0
	F  S AT=$F(S,$C(10),AT+1) Q:'AT  S P=AT-1
	Q P
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
; =============================================================================
; EVAL(TOK,CONF,CTX,OUT,ERR)
; =============================================================================
EVAL(TOK,CONF,CTX,OUT,ERR)
	K ERR
	N CST,CTSP
	S CTSP=1
	S CST(1)="CTX"
	; Partial recursion protection
	N PDEPTHMAX S PDEPTHMAX=+$G(CONF("templates","maxPartialDepth")) I PDEPTHMAX<1 S PDEPTHMAX=20
	N PACTIVE
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
	. ; TEXT
	. I TYP="text" D  Q
	. . D EMIT^MIOTPL2(.FSP,.F,.OUT,$$TOKGET(TN,I,"v"))
	. . S F(FSP,"i")=I+1
	. ; VAR
	. I TYP="var" D  Q
	. . N KEY,ESC,VAL
	. . S KEY=$$TOKGET(TN,I,"k")
	. . S ESC=+$$TOKGET(TN,I,"e")
	. . S VAL=$$RESVAL^MIOTPL2(KEY,.CST,CTSP)
	. . I ESC S VAL=$$ESCHTML^MIOTPL2(VAL)
	. . D EMIT^MIOTPL2(.FSP,.F,.OUT,VAL)
	. . S F(FSP,"i")=I+1
	. ; PARTIAL
	. I TYP="part" D  Q
	. . N PNAME
	. . S PNAME=$$TOKGET(TN,I,"k")
	. . ; advance parent now
	. . S F(FSP,"i")=I+1
	. . ; recursion control
	. . I $G(PACTIVE(PNAME))'<0 S PACTIVE(PNAME)=+$G(PACTIVE(PNAME))
	. . I PACTIVE(PNAME)+1>PDEPTHMAX S ERR("code")="TPL_PARTIAL_DEPTH",ERR("msg")="Partial recursion depth exceeded: "_PNAME Q
	. . S PACTIVE(PNAME)=PACTIVE(PNAME)+1
	. . ; load partial tokens into PTOKS(pid)
	. . S PTID=PTID+1
	. . K PTOKS(PTID),TMPTARR
	. . D GETTOK^MIOTPL2(PNAME,.CONF,.TMPTARR,.ERR)
	. . M PTOKS(PTID)=TMPTARR K TMPTARR
	. . I $D(ERR) D  I $D(ERR) Q
	. . . N EC S EC=$G(ERR("code")) 
	. . . ; Treat "not found" / "can't open" as missing ONLY for partials
	. . . I (EC="TPL_NOFILE")!(EC="TPL_IO") D  Q
	. . . . S PACTIVE(PNAME)=PACTIVE(PNAME)-1 I PACTIVE(PNAME)<1 K PACTIVE(PNAME)
	. . . . K ERR ;reset 
	. . N PMAX S PMAX=$O(PTOKS(PTID,""),-1)
	. . I PMAX<1 D  Q  ; empty partial ok
	. . . I $G(PACTIVE(PNAME))="" K PACTIVE(PNAME) Q
	. . . S PACTIVE(PNAME)=PACTIVE(PNAME)-1 I PACTIVE(PNAME)<1 K PACTIVE(PNAME)
	. . ; push frame for partial, inherit mode/cap from current frame
	. . N MODE,CAP
	. . S MODE=$G(F(FSP,"mode"))
	. . S CAP=$G(F(FSP,"capRef"))
	. . D PUSHFRAME^MIOTPL2(.FSP,.F,1,PMAX,CTSP,MODE,CAP,"PTOKS("_PTID_")")
	. . ; mark pname so POPF decrements
	. . S F(FSP,"pname")=PNAME
	. ; SECTION START
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
	Q:$Q $S($D(ERR):0,1:1)
	Q
	;
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
; TOKENDR(TN) -- last numeric subscript
; =============================================================================
TOKENDR(TN)
	N R
	I TN["(" D
	. S R=$E(TN,1,$L(TN)-1)_","""")"
	E  D
	. S R=TN_"("""")"
	Q +$O(@R,-1)
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
	. I PACTIVE(PN)<0 K PACTIVE(PN)
	;
	; Pop and restore CTSP
	S FSP=FSP-1
	I FSP>0 S CTSP=+$G(F(FSP,"ctxTop"))
	Q
	;
	;
; =============================================================================
; TOKMAX(TOKNAME)
; Return last numeric token index for an array referenced by name (e.g. "TOK", "PTOKS(3)")
; =============================================================================
TOKMAX(TOKNAME)
	Q +$O(@TOKNAME@(""),-1)
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
	N X S X=$O(@(TOKR_"("""")"),-1)
	Q +X
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
	Q
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