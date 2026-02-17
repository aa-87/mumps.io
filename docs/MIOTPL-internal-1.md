Thinking
Reading documents
Reading documents

Reading documents
Reading documents

Accessing and displaying MIOTPL2.m file head
Always show details

bash -lc ls -l /mnt/data && sed -n '1,200p' /mnt/data/MIOTPL2.m
total 218
-rw-r--r-- 1 root root       77875 Feb 17 07:42 MIOTPL2.m
-rw-r--r-- 1 root root       83461 Feb 17 07:42 MIOTPLT.m
-rw-r--r-- 1 root oai_shared 12235 Feb 17 07:42 _inheritance.json
-rw-r--r-- 1 root root        3330 Feb 17 07:42 comments.json
-rw-r--r-- 1 root root        4360 Feb 17 07:42 delimiters.json
-rw-r--r-- 1 root root       13574 Feb 17 07:42 interpolation.json
-rw-r--r-- 1 root root        8117 Feb 17 07:42 inverted.json
-rw-r--r-- 1 root root        4488 Feb 17 07:42 partials.json
-rw-r--r-- 1 root root       13774 Feb 17 07:42 sections.json
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
Focusing on failing tests and indentation
Okay, I need to tackle the failing tests 163 and 164 in _inheritance.json. There’s some confusion about TEST162 passing, but we’re focusing on 163 and 164 right now. Also, I need to adjust indentation for when the block opening tag is standalone, based on the default content. I’ll check the test cases in more detail.

Inspecting tests in _inheritance.json
Always show details

bash -lc python - <<'PY'
import json, pathlib
p=pathlib.Path('/mnt/data/_inheritance.json')
text=p.read_text()
# file seems not a full JSON object maybe top-level? let's parse lenient
j=json.loads(text)
# It might have a dict with 'tests'.
print(j.keys())
print('num tests',len(j['tests']))
# show last 5 tests names
for t in j['tests'][-10:]:
    print(t['name'])
PY
dict_keys(['__ATTN__', 'overview', 'tests'])
num tests 27
Multi-level inheritance
Multi-level inheritance, no sub child
Text inside parent
Text inside parent
Block scope
Standalone parent
Standalone block
Block reindentation
Intrinsic indentation
Nested block reindentation
Reviewing last few tests
Okay, there are 27 tests in total, and the last ones focus on things like intrinsic indentation. I’ll go ahead and print the details for the final tests so I can get a better look at what’s being tested and how that fits into everything else.

Printing last test details
Always show details

bash -lc python - <<'PY'
import json
j=json.load(open('/mnt/data/_inheritance.json'))
# map index to name
for i,t in enumerate(j['tests']):
    if t['name'] in ('Standalone parent','Standalone block','Block reindentation','Intrinsic indentation','Nested block reindentation'):
        print(i,t['name'])
        print('template:',repr(t['template']))
        print('partials:',t.get('partials'))
        print('expected:',repr(t['expected']))
        print('---')
PY
22 Standalone parent
template: 'Hi,\n  {{<parent}}{{/parent}}\n'
partials: {'parent': 'one\ntwo\n'}
expected: 'Hi,\n  one\n  two\n'
---
23 Standalone block
template: '{{<parent}}{{$block}}\none\ntwo{{/block}}\n{{/parent}}\n'
partials: {'parent': 'Hi,\n  {{$block}}{{/block}}\n'}
expected: 'Hi,\n  one\n  two\n'
---
24 Block reindentation
template: '{{<parent}}{{$block}}\n    one\n    two\n{{/block}}{{/parent}}\n'
partials: {'parent': 'Hi,\n  {{$block}}\n  {{/block}}\n'}
expected: 'Hi,\n  one\n  two\n'
---
25 Intrinsic indentation
template: '{{<parent}}{{$block}}\none\ntwo\n{{/block}}{{/parent}}\n'
partials: {'parent': 'Hi,\n{{$block}}\n  default\n{{/block}}\n'}
expected: 'Hi,\n  one\n  two\n'
---
26 Nested block reindentation
template: '{{<parent}}{{$nested}}\nthree\n{{/nested}}{{/parent}}\n'
partials: {'parent': '{{<grandparent}}{{$block}}\n  one\n  {{$nested}}\n    two\n  {{/nested}}\n{{/block}}{{/grandparent}}\n', 'grandparent': '{{$block}}default{{/block}}'}
expected: 'one\n  three\n'
---
Analyzing test failures and indentation
So, it turns out tests 22-26 correspond to MIOTPLT tests 160-164, and each test starts from TEST138. The failures are related to Intrinsic indentation (TEST163) and Nested block reindentation (TEST164). In TEST163, the correct indentation was missing, and override content didn’t get properly indented. I'll need to focus on applying indentation properly here.

Understanding block indentation behavior
Okay, according to the spec, when the block opening tag is standalone, indentation should come from the default content. In my case, the block open tag is at the start of the line, so it doesn’t have indentation; but the content inside the block should still be indented by 2 spaces. Test 24 (Block reindentation) is already passing correctly.

Fixing intrinsic indentation failure
In test 25, the parent call-site has no indentation, but the default content has 2 spaces. According to the spec, override content should match the indentation of the default content. The engine seems to be using the tag's position instead of the default content’s indentation. I need to fix this by using the default content's indentation for overriding. It's all about matching the indentation relative to the parent tag.

Fixing indentation for standalone block
For the standalone block opening tag, indentation should be based on the default content's indentation (the leading whitespace before the first non-empty line). In my example, the parent’s default content has a 2-space indentation, which should carry over to the override content. I need to ensure the compiler properly stores and applies this indentation.

Handling block indentation with overrides
The opening tag for the block is at the start of the line, so it's showing no indentation. However, for the override content, I need to store the intrinsic indentation of the default content separately and apply the appropriate rules. The indentation should come from default content or, if needed, the parent tag indentation when applicable. This helps manage both reindentation and deindentation rules correctly.

Refining block indentation logic
For child tokens, I noticed the engine likely removes indentation before adding the parent’s. This seems to match the case where minimal indentation is stripped, and the parent’s indentation is added, giving me the expected result. For intrinsic indentation, the parent’s default content indentation should be used if no indentation from the parent tag is evident, keeping the solution flexible.

Handling nested block indentation rules
When both tag and default content have different indents, which one should prevail? For intrinsic indentation, if the parent tag has 0 indent but the default content has 2, should I use the 2-space indent from the default content? I need to keep handling multi-level indentations, as in test 26.

Clarifying block indentation rules with overrides
When rendering a parent’s override content within the grandparent, it should follow the grandparent's indent (0). The parent's override content is deindented first, with the minimal indent being 2. After adjusting, the parent content matches the expected output. Intrinsic indentation counts during the evaluation of nested blocks.

Clarifying nested block indentation handling
When processing nested blocks, the indentation changes after de-indenting the parent’s override content. For a proper nested block override, the intrinsic indentation must be calculated relative to the tag and default content indentation. After de-indenting, the final indentation is determined based on the de-indented content and expansion indent.

Refining block indentation handling
If the tag indentation is 2 and the default content indentation is 4, the intrinsic indent would be 2. This means the final indent should likely match the tag indent. For standalone blocks or tags at column 1, we use the minimum default content indent, making sure performance stays optimal without excessive string scans.

Planning "dindent" computation during compilation
I’m thinking about how to compute "dindent" during compilation by examining raw text between block tokens. I’ll compute this for the parent template by analyzing the block content. This will be tricky since certain processing steps might adjust indentation or remove whitespace. I’ll review the parser functions for clarity.

Analyzing block tag indentation and override expansion
Always show details

bash -lc grep -n "^COMPILE" -n /mnt/data/MIOTPL2.m && grep -n "STANDTOK" /mnt/data/MIOTPL2.m && grep -n "parS" /mnt/data/MIOTPL2.m && grep -n "blkS" /mnt/data/MIOTPL2.m | head
532:COMPILE(TEXT,TOK,ERR,OD,CD) ;
550:	D STANDTOK(.TOK)
694:; STANDTOK(TOK)
699:STANDTOK(TOK)
709:	. 	I TYP="parS" D  Q
742:; Standalone check for a RANGE (BS..BE), used for parent/include (parS..secE).;
836:ISSTANDB(TOK,I,MAX) ; standalone detection for blkS ignoring parS adjacency
839:	; must be "line pure" except we allow parS tokens on the line
842:	; find previous TEXT token scanning left, skipping parS
844:	F  Q:JP<1  Q:$G(TOK(JP,"t"))="text"  D  Q:$G(TOK(JP,"t"))'="parS"
845:	. I $G(TOK(JP,"t"))="parS" S JP=JP-1 Q
851:	; - no prev text (BOF or only parS) OR
862:	; find next TEXT token scanning right, skipping parS (defensive)
864:	F  Q:JN>MAX  Q:$G(TOK(JN,"t"))="text"  D  Q:$G(TOK(JN,"t"))'="parS"
865:	. I $G(TOK(JN,"t"))="parS" S JN=JN+1 Q
1181:LINEPUREB(TOK,I,MAX) ; like LINEPURE, but ignores parS tokens (inheritance blocks)
1188:	. I TYP="parS" Q  ; ignore parent/include start on same line
1195:	. I TYP="parS" Q  ; defensive (shouldn't occur to the right)
1257:	S TOK(N,"t")="parS"
1280:	. I (T="secS")!(T="parS")!(T="blkS") D  Q
1293:	. 	. I $G(STK(SP,"t"))="parS" S TOK(I,"parE")=1
1373:	. I TYP="parS" D  Q
715:	. 	I TYP="blkS" D  Q
816:	  I $G(TOK(I,"t"))="blkS" Q $$ISSTANDB(.TOK,I,MAX)
836:ISSTANDB(TOK,I,MAX) ; standalone detection for blkS ignoring parS adjacency
887:	I (TYP="part")!(TYP="blkS") D
1264:	S TOK(N,"t")="blkS"
1280:	. I (T="secS")!(T="parS")!(T="blkS") D  Q
1421:	. I TYP="blkS" D  Q
1446:	. . . ; between blkS and secE: only whitespace text (if any)
2301:	. Q:TYP'="blkS"
Reviewing STANDTOK and ISSTANDB logic
I’ll need to take a look at the relevant sections surrounding STANDTOK and ISSTANDB—those seem to handle the block evaluations and indentation. Understanding how these pieces of the logic work will be important for implementing the dindent calculation effectively. Let me go over those lines.

Viewing STANDTOK logic and evaluation blocks
Always show details

bash -lc sed -n '520,920p' /mnt/data/MIOTPL2.m
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
	N I,MAX,TYP,MI,J
	N DO,DOM,RSKIP  ; DO(I)=standalone start, DOM(I)=matching end index for range standalone
	;
	S MAX=$$NUMMAX(.TOK) Q:MAX<1
	;
	; pass 1: detect (no mutation)
	F I=1:1:MAX D
	. 	S TYP=$G(TOK(I,"t"))
	. 	; parent/include start: treat range I..MI as one unit
	. 	I TYP="parS" D  Q
	. 	.	S MI=+$G(TOK(I,"m")) I MI<I Q
	. 	.	I $$ISSTANDR(.TOK,I,MI,MAX) D
	. 	.	.	S DO(I)=1,DOM(I)=MI
	. 	.	.	F J=I+1:1:MI S RSKIP(J)=1
	. 	; block placeholder: allow standalone for the range {{$x}}...{{/x}} when open/close are on same line
	. 	I TYP="blkS" D  Q
	. 	.	S MI=+$G(TOK(I,"m")) I MI>I,$$ISSTANDR(.TOK,I,MI,MAX) D  Q
	. 	.	.	S DO(I)=1,DOM(I)=MI
	. 	.	.	F J=I+1:1:MI S RSKIP(J)=1
	. 	.	; otherwise fall back to normal standalone rules for just the opening tag
	. 	.	I $$ISSTAND(.TOK,I,MAX) S DO(I)=1
	. 	; NEW: treat consecutive close tags (secE) on the same line as a standalone range
	. 	I TYP="secE",I<MAX,$G(TOK(I+1,"t"))="secE" D  Q
	. 	.	S MI=I
	. 	.	F  Q:MI>=MAX  Q:$G(TOK(MI+1,"t"))'="secE"  S MI=MI+1
	. 	.	I $$ISSTANDRE(.TOK,I,MI,MAX) D
	. 	.	.	S DO(I)=1,DOM(I)=MI
	. 	.	.	F J=I+1:1:MI S RSKIP(J)=1
	. 	; existing standalone token types (single-token detection)
	. 	Q:(TYP'="secS")&(TYP'="secE")&(TYP'="part")&(TYP'="comm")&(TYP'="delim")
	. 	I $$ISSTAND(.TOK,I,MAX) S DO(I)=1
	;
	; pass 2: apply trims (reverse to avoid cascades)
	F I=MAX:-1:1 D
	. 	Q:$G(RSKIP(I))
	. 	Q:'$G(DO(I))
	. 	I $G(DOM(I))>0 D  Q
	. 	.	D STANDAPR(.TOK,I,+$G(DOM(I)),MAX)
	. 	D STANDAP(.TOK,I,MAX)
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
ISSTANDRE(TOK,BS,BE,MAX)
	; Standalone check for a RANGE of consecutive close tags (secE).;
	; Left/right whitespace rules are the same as ISSTANDR, but we do not require
	; anything about token types inside the range (they are non-text tags).;
	N PV,NV
	; left side: BOF or previous text tail is ws-only
	I BS>1 Q:$G(TOK(BS-1,"t"))'="text" 0 Q:'$$TAILWS($G(TOK(BS-1,"v"))) 0
	; right side: EOF allowed, else next text must start with ws then newline
	I BE<MAX Q:$G(TOK(BE+1,"t"))'="text" 0 Q:'$$HEADWNL($G(TOK(BE+1,"v"))) 0
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
	; --- NEW: capture indentation for standalone parent include range ---
	N IND,PV,P
	S IND=""
	I BS>1,$G(TOK(BS-1,"t"))="text" D
	. S PV=$G(TOK(BS-1,"v"))
	. ; indent = chars after last newline in PV (or whole PV if no newline)
	. S P=$$LASTNLSEQ(PV)
	. I P>0 S IND=$E(PV,P+1,$L(PV))
	. E  S IND=PV
	; keep only spaces/tabs
	I IND'="",$TR(IND," "_$C(9),"")'="" S IND=""
	S TOK(BS,"indent")=IND
	; --- END NEW ---
	;
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
	I (TYP="part")!(TYP="blkS") D
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
	I I<MAX D
	. N NX S NX=$G(TOK(I+1,"v"))
	. ; Do not trim the final trailing newline after a closing {{/parent}} tag (TEST161)
	. I (TYP="secE"),$G(TOK(I,"parE")),(I+1=MAX),(NX=$C(10)!(NX=$C(13,10))) Q
	. S TOK(I+1,"v")=$$CUTNX(NX)
	;
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
Reviewing indentation logic for partial and block placeholders
STANDTOK deals with indentation for standalone partials, blkS, and the parS range. It sets the TOK(I,"indent") for block opening tags, but we also need to capture default indentation for intrinsic purposes. I’ll search for “intr” or “dind” later in the file to locate relevant definitions.

Searching for indentation terms in file
Always show details

bash -lc grep -n "intr" /mnt/data/MIOTPL2.m | head -n 50 && grep -n "dindent" /mnt/data/MIOTPL2.m | head -n 50 && grep -n "def" /mnt/data/MIOTPL2.m | grep -n "indent" | head
10:2314:	. ; definition-site unindent for overrides (inheritance block semantics)
Inspecting comment at line 2314 for indentation logic
There’s a comment at line 2314, which might help in understanding the evaluation section for indentation. I’ll take a look around that line to see if it provides more context or information that can guide the next steps on the indentation logic.

Extracting lines around evaluation section
Always show details

bash -lc sed -n '2000,2520p' /mnt/data/MIOTPL2.m
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
COMMPREF(A,B)
	; Return common prefix of A and B
	N I,MAX,OUT
	S A=$G(A),B=$G(B)
	S MAX=$S($L(A)<$L(B):$L(A),1:$L(B))
	S OUT=""
	F I=1:1:MAX Q:$E(A,I)'=$E(B,I)  S OUT=OUT_$E(A,I)
	Q OUT
	;
BLKDEFIND(TOK)
	; Determine common leading indentation (spaces/tabs) across non-blank lines
	; in a block override token stream. Only considers template text.;
	N MAX,I,TYP,V,POS,CH,LS,LINE,IND,INIT
	S MAX=$$NUMMAX^MIOTPL2(.TOK)
	S LS=1,IND="",INIT=0,LINE=""
	F I=1:1:MAX D
	. S TYP=$G(TOK(I,"t")) Q:TYP=""
	. I TYP'="text" Q  ; only template text contributes
	. S V=$G(TOK(I,"v"))
	. S POS=1
	. F  Q:POS>$L(V)  D
	. . S CH=$E(V,POS),POS=POS+1
	. . I LS D  Q
	. . . I CH=$C(10)!(CH=$C(13)) Q  ; blank line, stay LS=1
	. . . I CH=" "!(CH=$C(9)) S LINE=LINE_CH Q  ; building leading ws
	. . . ; first non-ws content char at line start => commit LINE as indent candidate
	. . . I 'INIT S IND=LINE,INIT=1
	. . . E  S IND=$$COMMPREF^MIOTPL2(IND,LINE)
	. . . S LINE="",LS=0
	. . I CH=$C(10) S LS=1,LINE="" Q
	. . I CH=$C(13) S LS=1,LINE="" Q
	Q $G(IND)
	;
BLKUNPTOK(TOK,IND)
	; Remove IND from the start of each template line in TEXT tokens.;
	N MAX,I,TYP,V,AT
	S IND=$G(IND) Q:IND=""
	S MAX=$$NUMMAX^MIOTPL2(.TOK)
	S AT=1
	F I=1:1:MAX D
	. S TYP=$G(TOK(I,"t")) Q:TYP=""
	. I TYP="text" D
	. . S V=$G(TOK(I,"v"))
	. . S TOK(I,"v")=$$BLKUNDTXT^MIOTPL2(V,IND,.AT)
	. E  D
	. . ; non-text does not change line-start state
	. . Q
	Q
	;
BLKUNDTXT(V,IND,AT)
	; Remove IND at template line starts within a text chunk.;
	N OUT,I,CH,IL,LS
	S OUT="",IL=$L(IND),LS=+$G(AT)
	F I=1:1:$L($G(V)) D
	. S CH=$E(V,I)
	. I LS,IL>0,$E(V,I,I+IL-1)=IND D  S I=I+IL-1 Q
	. . ; removed indent; still at line start until non-newline char processed
	. . S LS=0
	. I CH=$C(10) S OUT=OUT_CH,LS=1 Q
	. I CH=$C(13) S OUT=OUT_CH,LS=1 Q
	. S OUT=OUT_CH,LS=0
	S AT=LS
	Q OUT
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
	. ; definition-site unindent for overrides (inheritance block semantics)
	. ; This is done at capture-time to avoid render-time token edge cases.;
	. N TMP,DIND
	. K TMP M TMP=OVT(OVIDX,BNAME)
	. S DIND=$$BLKDEFIND^MIOTPL2(.TMP)
	. I DIND'="" D BLKUNPTOK^MIOTPL2(.TMP,DIND)
	. K OVT(OVIDX,BNAME) M OVT(OVIDX,BNAME)=TMP K TMP
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
	;
Locating EVAL handling for indentation during expansion
I found some helper routines related to block overrides and handling indentation at capture time, which explains test 24 passing. However, we still need to handle indentation during expansion. I'll search for the EVAL label earlier in the file to find where it processes parS and blkS for further handling.

Searching for EVAL label in script
Always show details

bash -lc grep -n "^EVAL" -n /mnt/data/MIOTPL2.m && sed -n '1460,2000p' /mnt/data/MIOTPL2.m
1302:EVAL(TOK,CONF,CTX,OUT,ERR)
	. . . . I $L(OUT)>=$L(IND2),$E(OUT,$L(OUT)-$L(IND2)+1,$L(OUT))=IND2 S OUT=$E(OUT,1,$L(OUT)-$L(IND2))
	. . . . ; on the next text token, trim leading indentation + ONE newline (standalone rule)
	. . . . S F(FSP,"cutnx")="NX"
	. . ; --- end fallback ---
	. . I IND="" D  Q  ; (no indent path)
	. . . I OVIDX>0,$D(OVT(OVIDX,BNAME)) D  Q
	. . . . S OVTN="OVT("_OVIDX_","""_BNAME_""")"
	. . . . S OMAX=$$TOKENDR^MIOTPL2(OVTN)
	. . . . I OMAX>0 D PUSHFRAME^MIOTPL2(.FSP,.F,1,OMAX,CTSP,$G(F(FSP,"mode")),$G(F(FSP,"capRef")),OVTN)
	. . . ; default block content (slice in-place)
	. . . D PUSHFRAME^MIOTPL2(.FSP,.F,I+1,MI-1,CTSP,$G(F(FSP,"mode")),$G(F(FSP,"capRef")),TN)
	. . ;
	. . ; Indent path: clone chosen block tokens, indent template lines, then render
	. . K TMPTARR
	. . I OVIDX>0,$D(OVT(OVIDX,BNAME)) D
	. . . M TMPTARR=OVT(OVIDX,BNAME)
	. . E  D
	. . . S NN=0
	. . . F J=I+1:1:MI-1 D
	. . . . S NN=NN+1
	. . . . S REF=TN_"("_J_")"
	. . . . M TMPTARR(NN)=@REF
	. . D INDENTPTOK^MIOTPL2(.TMPTARR,IND)
	. . S BTID=BTID+1
	. . K BTOKS(BTID) M BTOKS(BTID)=TMPTARR K TMPTARR
	. . S OMAX=$$TOKENDR^MIOTPL2("BTOKS("_BTID_")")
	. . I OMAX>0 D PUSHFRAME^MIOTPL2(.FSP,.F,1,OMAX,CTSP,$G(F(FSP,"mode")),$G(F(FSP,"capRef")),"BTOKS("_BTID_")")
	. ;
	. ; TEXT
	. I TYP="text" D  Q
	. . N TV S TV=$$TOKGET(TN,I,"v")
	. . I $D(F(FSP,"cutnx")) D
	. . . I F(FSP,"cutnx")="IND" S TV=$$CUTIND(TV)
	. . . E  S TV=$$CUTNX(TV)
	. . . K F(FSP,"cutnx")
	. . D EMIT^MIOTPL2(.FSP,.F,.OUT,TV)
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
	;
; =============================================================================
; INDENTBTOK(.TOK,IND)
; Block-only indenter used for inheritance blocks.;
; Diff vs INDENTPTOK:
;  - Preserves line-start state across non-text tokens
;  - Uses AT returned by INDTXT (authoritative) to set LS
; This ensures embedded newlines inside a single text token indent the next line.;
; =============================================================================
INDENTBTOK(TOK,IND)
	N TMP,MAX,I,NEWN,LS,AT,TYP,V,S
	S IND=$G(IND) Q:IND=""
	K TMP S S=""
	F  S S=$O(TOK(S)) Q:S=""  I 'S?1.N M TMP(S)=TOK(S)
	S MAX=$$NUMMAX(.TOK)
	S NEWN=0,LS=1,AT=1
	F I=1:1:MAX D
	. S TYP=$G(TOK(I,"t"))
	. I LS,(TYP'="text") D
	. . S NEWN=NEWN+1
	. . S TMP(NEWN,"t")="text",TMP(NEWN,"v")=IND
	. . S LS=0,AT=0
	. S NEWN=NEWN+1 M TMP(NEWN)=TOK(I)
	. I TYP="text" D
	. . S V=$G(TMP(NEWN,"v"))
	. . S AT=LS
	. . S TMP(NEWN,"v")=$$INDTXT(V,IND,.AT)
	. . S LS=AT
	. E  D
	. . ; preserve LS across tags; they do not create line breaks
	. . Q
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
Reviewing full EVAL implementation
I found the start of the EVAL block around 1302, but it begins mid-evaluation for blkS. To understand it fully, I need to look at the complete EVAL implementation earlier. I'll open from that point to get a better picture of how it handles block evaluations.

Extracting code block for EVAL implementation
Always show details

bash -lc sed -n '1260,1600p' /mnt/data/MIOTPL2.m
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
	. 	. ; mark closing token if this was a parent include
	. 	. I $G(STK(SP,"t"))="parS" S TOK(I,"parE")=1
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
	; Local storage for indented block token arrays
	N BTID,BTOKS
	S BTID=0
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
	. . . ; else overlay inherited onto local (OVERWRITE)
	. . . S BN=""
	. . . F  S BN=$O(OVT(POVID,BN)) Q:BN=""  D
	. . . . ; overwrite (child wins)
	. . . . K OVT(OVIDX,BN)
	. . . . M OVT(OVIDX,BN)=OVT(POVID,BN)
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
	. . ; Standalone-parent indentation: indent parent tokens like standalone partials
	. . N IND
	. . S IND=$$TOKGET(TN,I,"indent")
	. . I IND'="" D
	. . . K TMPTARR M TMPTARR=PTOKS(PTID)
	. . . D INDENTBTOK^MIOTPL2(.TMPTARR,IND)
	. . . K PTOKS(PTID) M PTOKS(PTID)=TMPTARR K TMPTARR
	. . . S PMAX=$$TOKENDR^MIOTPL2("PTOKS("_PTID_")")  ; recompute after rewrite	
	. . D PUSHFRAME^MIOTPL2(.FSP,.F,1,PMAX,CTSP,$G(F(FSP,"mode")),$G(F(FSP,"capRef")),"PTOKS("_PTID_")")
	. . ; attach override id to new frame
	. . S F(FSP,"ovID")=OVIDX
	. . S F(FSP,"pname")=PNAME
	. . S F(FSP,"ikey")=IK
	. ;
	. ; Block tag {{$name}}...{{/name}}
	. I TYP="blkS" D  Q
	. . N MI,BNAME,OVIDX,OVTN,OMAX,IND,J,NN,REF
	. . S MI=+$$TOKGET(TN,I,"m") I MI<1 S ERR("code")="TPL_EVAL",ERR("msg")="Unmatched block tag." Q
	. . S BNAME=$$TOKGET(TN,I,"k")
	. . S IND=$$TOKGET(TN,I,"indent")  ; indentation captured by standalone trimming (may be "")
	. . ; advance parent first
	. . S F(FSP,"i")=MI+1
	. . S OVIDX=+$G(F(FSP,"ovID"))
	. . ;
	. . ; Fast path: no indent handling needed
	. . ; Render-time fallback: if IND wasn't captured by standalone trimming,
	. . ; detect "standalone block placeholder" pattern and synthesize indentation + newline-trim.;
	. . I IND="" D
	. . . N PV,P,IND2,OK,J,TV,NV
	. . . S IND2="",OK=1
	. . . ; previous token must be text ending with only spaces/tabs after its last newline
	. . . I I>1,$$TOKGET(TN,I-1,"t")="text" D
	. . . . S PV=$$TOKGET(TN,I-1,"v")
	. . . . S P=$$LASTNLSEQ(PV)
	. . . . I P>0 S IND2=$E(PV,P+1,$L(PV))
	. . . . E  S IND2=PV
	. . . E  S OK=0
	. . . I IND2="",OK=0
	. . . ; indentation must be spaces/tabs only
	. . . I OK,$TR(IND2," "_$C(9),"")'="" S OK=0
	. . . ; between blkS and secE: only whitespace text (if any)
	. . . I OK,(MI>I+1) D
	. . . . F J=I+1:1:MI-1 D  Q:'OK
	. . . . . S TV=$$TOKGET(TN,J,"t")
	. . . . . I TV'="text" S OK=0 Q
	. . . . . I '$$ALLWSNL($$TOKGET(TN,J,"v")) S OK=0 Q
	. . . ; next token after secE must start with optional ws then a newline (so the tag-line is standalone)
	. . . I OK,(MI<END),$$TOKGET(TN,MI+1,"t")="text" D
	. . . . S NV=$$TOKGET(TN,MI+1,"v")
	. . . . I '$$HASLEADNL(NV) S OK=0
	. . . E  S OK=0
	. . . I OK D
	. . . . S IND=IND2
	. . . . ; remove the indentation already emitted from OUT (it came from the parent template text)
	. . . . I $L(OUT)>=$L(IND2),$E(OUT,$L(OUT)-$L(IND2)+1,$L(OUT))=IND2 S OUT=$E(OUT,1,$L(OUT)-$L(IND2))
	. . . . ; on the next text token, trim leading indentation + ONE newline (standalone rule)
	. . . . S F(FSP,"cutnx")="NX"
	. . ; --- end fallback ---
	. . I IND="" D  Q  ; (no indent path)
	. . . I OVIDX>0,$D(OVT(OVIDX,BNAME)) D  Q
	. . . . S OVTN="OVT("_OVIDX_","""_BNAME_""")"
	. . . . S OMAX=$$TOKENDR^MIOTPL2(OVTN)
	. . . . I OMAX>0 D PUSHFRAME^MIOTPL2(.FSP,.F,1,OMAX,CTSP,$G(F(FSP,"mode")),$G(F(FSP,"capRef")),OVTN)
	. . . ; default block content (slice in-place)
	. . . D PUSHFRAME^MIOTPL2(.FSP,.F,I+1,MI-1,CTSP,$G(F(FSP,"mode")),$G(F(FSP,"capRef")),TN)
	. . ;
	. . ; Indent path: clone chosen block tokens, indent template lines, then render
	. . K TMPTARR
	. . I OVIDX>0,$D(OVT(OVIDX,BNAME)) D
	. . . M TMPTARR=OVT(OVIDX,BNAME)
	. . E  D
	. . . S NN=0
	. . . F J=I+1:1:MI-1 D
	. . . . S NN=NN+1
	. . . . S REF=TN_"("_J_")"
	. . . . M TMPTARR(NN)=@REF
	. . D INDENTPTOK^MIOTPL2(.TMPTARR,IND)
	. . S BTID=BTID+1
	. . K BTOKS(BTID) M BTOKS(BTID)=TMPTARR K TMPTARR
	. . S OMAX=$$TOKENDR^MIOTPL2("BTOKS("_BTID_")")
	. . I OMAX>0 D PUSHFRAME^MIOTPL2(.FSP,.F,1,OMAX,CTSP,$G(F(FSP,"mode")),$G(F(FSP,"capRef")),"BTOKS("_BTID_")")
	. ;
	. ; TEXT
	. I TYP="text" D  Q
	. . N TV S TV=$$TOKGET(TN,I,"v")
	. . I $D(F(FSP,"cutnx")) D
	. . . I F(FSP,"cutnx")="IND" S TV=$$CUTIND(TV)
	. . . E  S TV=$$CUTNX(TV)
	. . . K F(FSP,"cutnx")
	. . D EMIT^MIOTPL2(.FSP,.F,.OUT,TV)
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
Understanding EVAL and indentation handling
EVAL takes care of block (blkS) handling. For indentation, if IND is empty, it falls back to checking if the block is standalone and adjusts indentation accordingly, setting the cutnx flag. However, for intrinsic indentation, IND is empty, which is expected. We need to compute indentation in cases when IND is empty, based on the default content indentation for standalone blocks.

Handling intrinsic indentation for block expansion
We need to apply intrinsic indentation for block expansion when baseIndent is empty. Here's the plan:

First, baseIndent is taken from IND (whitespace before the tag).

If baseIndent is empty, and the opening tag is standalone, intrinsicIndent is computed from the parent block's content indentation. Test 25 expects the result to be " ", suggesting baseIndent should equal intrinsicIndent. I’ll check the spec for specifics.

Handling indentation rules based on default content and baseIndent
If default content is empty, we fall back to baseIndent, which is the whitespace before the tag. But if default content has indentation, we may need to combine baseIndent with the default indent — or perhaps just use it directly. In tests like 24 with empty default content, we need to stick with baseIndent. If there’s indented default content, expect that to define the level.

Clarifying indentation fallback for overrides
When there's no indent for an override, we could expect 4 spaces because the default content is indented by 4, not 2. However, our baseIndent approach would return 2, which might be incorrect. The right approach is: for a standalone block opening, use indentation from the first non-empty line of the default content. If the default content is empty, fallback to the whitespace before the opening tag.

Finalizing indentation algorithm with override handling
The algorithm should use the indentation of the first non-blank line of the block's default content. If it's empty, we'll fallback to baseIndent as defined earlier. For overrides, we need to remove any indentation at definition and then reapply computed indentation using the appropriate tokens, adjusting for cases like standalone blocks.

Handling block indentation with standalone tags
For blocks where the opening and closing tags are on the same line, the STANDTOK pass treats them as a single unit. It checks if the block is standalone, applies STANDAPR for indentation, and stores the indent (" "). This ensures that the indent path works correctly by using the INDENTPTOK with the right calculated indent.

Fixing standalone indentation issue
In the intrinsic indentation case, when the block open and close are not on the same line, it falls back to using the standalone check for the opening tag. The solution is to compute indent from the default content rather than the empty indent before the tag. The block's "standalone" status needs to be tracked post-trimming.

Fixing standalone indentation handling
In the intrinsic indentation case, open and close tags not being on the same line causes an issue where the indent value is empty. To fix this, we need to compute indent using default content, but only for standalone tags. To track "standalone," we can store a flag during processing and check token flags.

Handling indentation logic during evaluation
The challenge lies in setting the correct indentation for specific tokens (part, blkS, parS). The issue is determining when to apply computed indentation — it should only happen when the block open tag is standalone. After trimming, we might lose necessary context, but checking token boundaries for standalone tags might help and prevent wrongly applying indentation.

Refining indentation computation logic
To handle indentation, it’s better to store a flag during trimming. Missing or empty "indent" fields need to be carefully distinguished. If a field exists, it implies a standalone block. For Intrinsic indentation, determining whether a parent tag is standalone will guide how we compute indentation based on default content.

Handling indentation for blocks with default content
For blocks with default content, I need to compute the correct indentation based on the common indent across non-blank lines. If the default has more indent than the tag, I'll adjust accordingly. If the parent template has additional indentation, I’ll ensure the override content stays consistent. When no override exists, we must avoid double-indentation of the default content.

Addressing indentation with default content
While default content includes its own indentation, the current engine could fail when it tries to add more indentation to a line that's already indented. To fix this, I’ll need to ensure the compiler isn’t mistakenly adding extra spaces to default content lines unless required. Testing existing templates might help uncover issues with indented blocks.

Analyzing block indentation handling within templates
Always show details

bash -lc python - <<'PY'
import json, re
j=json.load(open('/mnt/data/_inheritance.json'))
for idx,t in enumerate(j['tests']):
    parts=t.get('partials') or {}
    for name,pt in parts.items():
        if '{{$' in pt and 'default' in pt:
            print('test',idx,t['name'],'partial',name,repr(pt))
PY
test 6 Inherit partial include '{{$foo}}default content{{/foo}}'
test 11 Two overridden parents partial parent '|{{$stuff}}...{{/stuff}}{{$default}} default{{/default}}|'
test 14 Only one override partial parent '{{$stuff}}new default one{{/stuff}}, {{$stuff2}}new default two{{/stuff2}}'
test 15 Parent template partial parent '{{$foo}}default content{{/foo}}'
test 16 Recursion partial parent '{{$foo}}default content{{/foo}} {{$bar}}{{<parent2}}{{/parent2}}{{/bar}}'
test 16 Recursion partial parent2 "{{$foo}}parent2 default content{{/foo}} {{<parent}}{{$bar}}don't recurse{{/bar}}{{/parent}}"
test 19 Text inside parent partial parent '{{$foo}}default content{{/foo}}'
test 20 Text inside parent partial parent '{{$foo}}default content{{/foo}}'
test 25 Intrinsic indentation partial parent 'Hi,\n{{$block}}\n  default\n{{/block}}\n'
test 26 Nested block reindentation partial grandparent '{{$block}}default{{/block}}'
Handling indentation for inline default content
In templates where {{$foo}}default content{{/foo}} is on the same line, indentation isn’t an issue because the open tag isn’t standalone. The algorithm correctly avoids adding extra indentation, leaving the default content as-is. If tags aren’t standalone, it doesn’t add indentation, and default content renders properly.

Ensuring correct indentation for block content
We need to preserve behavior where block content is indented only when the tag line is standalone. When the tag line is removed, the content should start right after it, with correct indentation. If the tag’s indentation is 0, the content starts at column 1—unless other indentation factors apply. Double indentation may result but needs confirmation.

Clarifying indentation on standalone tags
For standalone tags, the default content's indentation might have been removed during compilation. Standalone trimming removes the tag line and its following newline. So even though the tag line is removed, the default content remains indented if needed, but it should not be indented further when rendered without override.

Understanding indentation for default content
In the current code, if there's no "indent" token or IND is empty, no extra indentation is added. Default content, which already includes indentation, doesn't need to be indented further. Override content, however, might need indentation, but default content should not be reindented. Instead, it should be directly rendered.

Considering indentation of default content in block expansion
If a block tag has indentation and default content exists, we need to handle it carefully. Default content should match the expansion template's indentation, and there should be no double indentation. Even though a block's body might be deindented at the site of definition, default content must still follow the template's full structure.

Handling default content indentation in block expansion
In block expansion, when a parent template’s placeholder has indentation (e.g., 2 spaces), default content should maintain the same relative indent. We remove the initial indentation (2 spaces) and then reapply it, ensuring no net change. This way, content keeps its expected format even without an override.

Handling default content and override indentation
To ensure proper indentation, when there's no override, the default content should remain unmodified and retain its original indent. If there is an override, we compute the appropriate indent, but only apply it to the override content. In cases involving nested blocks, extra consideration is given to how the indentation is captured and modified.

Handling indentation for nested overrides
In this case, when deindenting the nested block, the "indent" property doesn't change. The expected behavior is that the parent’s override content keeps the original indentation, even after adjustments, to avoid adding excessive indentation. Keeping the original "indent" value ensures the final output is correct, with 2 spaces.

Determining correct final indentation
Deindenting removes common indent from text lines, but the tag's indentation stays in place, as it's captured separately. For a final indent, we need to apply the default content indent directly. Even if placeholder indent is 2, the default content’s 4 spaces should be used for consistency when overriding.

Clarifying indentation behavior for overrides
The default content indent includes raw spaces rather than the placeholder indent. The common indent of default content after deindenting is what we need to consider, especially for nested blocks. In this case, after removing common indent, we adjust based on the token stream at evaluation time, ensuring proper alignment.

Finalizing indentation handling for overrides
We should calculate indentation from the current token stream, not from compiled parent data. This includes scanning for whitespace in default content and adjusting for nested blocks. I'll implement a function to compute the intrinsic indentation dynamically and apply that for overrides when evaluating, ensuring consistency with expected results from the spec.

Handling indentation adjustments for overrides and default content
When rendering, I need to ensure that only override tokens are indented by the effective indentation value, while default content remains unmodified. I must carefully handle blocks with and without overrides. For nested cases, I’ll compute intrinsic indentation only when necessary, ensuring performance isn't impacted while adhering to the expected behavior in the spec. Testing should confirm if this approach resolves failing cases like nested block reindentation.

Analyzing nested block reindentation challenges
It seems that test 164 might be failing due to an issue with nested block reindentation. The expected output should show a line with "one" followed by an indented "three" by 2 spaces. However, miscalculations around placeholder indent and the handling of block overrides may be producing incorrect indentation. I'll need to revise how different levels of nesting are handled, possibly reconsidering how we compute and apply indentation for nested blocks.