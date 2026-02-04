MIOTEST 
	;
	;
	; test
	;
	;
	; 100-121 Coverage instrumentation per routines, to be implemented later
	; 120-125 D MIOTF120 *skipped* - Coverage instrumentation for a full test suite
	D MIOTF121,MIOTF122,MIOTF123,MIOTF124,MIOTF125,MIOTF126,MIOTF126B
	Q
MIOTF121 ; Full suite test 121 - TPL_SECTION_CTA.;
	NEW TOK,ERR,OK,CONF,CTX,OUT
	SET OK=$$COMPILE^MIOTPL("{{#cta}}X{{/cta}}",.TOK,.ERR)
	DO OK^MIOTASSERT(OK,"compile")
	SET CTX("cta")=1
	SET OK=$$EVAL^MIOTPL(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT(OK,"eval")
	DO EQ^MIOTASSERT($$JOIN^MIOTPL(.OUT),"X","section render")
	QUIT
MIOTF122 ; Full suite test 122 - TPL_BLOCK_TITLE.;
	NEW TOK,ERR,OK,CONF,CTX,OUT
	SET OK=$$COMPILE^MIOTPL("{{#block:title}}Hello{{/block:title}}",.TOK,.ERR)
	DO OK^MIOTASSERT(OK,"compile")
	SET OK=$$EVAL^MIOTPL(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT(OK,"eval")
	DO EQ^MIOTASSERT($GET(CTX("blocks","title")),"Hello","block captured")
	QUIT
MIOTF123 ; Full suite test 123 - TPL_DOTTED_LIST.;
	NEW TOK,ERR,OK,CONF,CTX,OUT
	SET CTX("cats","items",1)="Core"
	SET CTX("cats","items",2)="Tools"
	SET OK=$$COMPILE^MIOTPL("{{#cats.items}}{{.}};{{/cats.items}}",.TOK,.ERR)
	DO OK^MIOTASSERT(OK,"compile")
	SET OK=$$EVAL^MIOTPL(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT(OK,"eval")
	DO EQ^MIOTASSERT($$JOIN^MIOTPL(.OUT),"Core;Tools;","dotted list")
	QUIT
MIOTF124 ; Full suite test 124 - TPL_PACKAGES_OBJECT.;
	NEW TOK,ERR,OK,CONF,CTX,OUT
	SET CTX("packages",1,"slug")="mio-web"
	SET CTX("packages",1,"name")="Web Server"
	SET OK=$$COMPILE^MIOTPL("{{#packages}}{{slug}}-{{name}};{{/packages}}",.TOK,.ERR)
	DO OK^MIOTASSERT(OK,"compile")
	SET OK=$$EVAL^MIOTPL(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT(OK,"eval")
	DO EQ^MIOTASSERT($$JOIN^MIOTPL(.OUT),"mio-web-Web Server;","packages obj")
	QUIT
MIOTF125 ; Full suite test 125 - TPL_INVERTED_NORESULTS.;
	N %MIOTESTF125
	NEW TOK,ERR,OK,CONF,CTX,OUT,RES
	; Template: show "NONE" only when packages is falsey/empty.;
	SET OK=$$COMPILE^MIOTPL("{{^packages}}NONE{{/packages}}{{#packages}}YES{{/packages}}",.TOK,.ERR)
	DO OK^MIOTASSERT(OK,"compile")
	; Case A: packages has an item => inverted must NOT render, normal must render.;
	S %MIOTESTF125="eval A" KILL CTX
	SET CTX("packages",1,"name")="Pkg1"
	SET OK=$$EVAL^MIOTPL(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT(OK,"eval A")
	SET RES=$$JOIN^MIOTPL(.OUT)
	DO EQ^MIOTASSERT(RES,"YES","TF125 "_%MIOTESTF125_" inverted suppressed when list has items") ;CURRENT PROBLEM= inverted suppressed when list has no items !!!!!
	; Case B: packages empty => inverted MUST render, normal must NOT render.;
	S %MIOTESTF125="eval B" KILL OUT,ERR,CTX
	SET OK=$$EVAL^MIOTPL(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT(OK,"eval B")
	SET RES=$$JOIN^MIOTPL(.OUT)
	DO EQ^MIOTASSERT(RES,"NONE","TF125 "_%MIOTESTF125_" inverted renders when list empty")
	QUIT
MIOTF126 ; Full suite test 126 - TPL_DEEP_NESTED_CONTEXT.;
	NEW TOK,ERR,OK,CONF,CTX,OUT,RES,TPL
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
	SET OK=$$COMPILE^MIOTPL(TPL,.TOK,.ERR)
	DO OK^MIOTASSERT(OK,"compile")
	; Build deep context with two groups:
	; Group 1 has 2 members, Group 2 has none.;
	KILL CTX
	SET CTX("groups","items",1,"name")="Core"
	SET CTX("groups","items",1,"members",1,"name")="Alice"
	SET CTX("groups","items",1,"members",2,"name")="Bob"
	SET CTX("groups","items",2,"name")="Tools"
	; No members under group 2 => should show EMPTY
	SET OK=$$EVAL^MIOTPL(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT(OK,"eval")
	SET RES=$$JOIN^MIOTPL(.OUT)
	DO EQ^MIOTASSERT(RES,"G=Core:[Alice,Bob,];G=Tools:[EMPTY];","deep nested render")
	QUIT
MIOTF126B ; Full suite test 126B - TPL_DEEP_NESTED_CONTEXT_SCALARS.;
	NEW TOK,ERR,OK,CONF,CTX,OUT,RES,TPL
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
	SET OK=$$COMPILE^MIOTPL(TPL,.TOK,.ERR)
	DO OK^MIOTASSERT(OK,"compile")
	; Two groups: one with scalar members, one empty.;
	KILL CTX
	SET CTX("groups","items",1,"name")="Core"
	SET CTX("groups","items",1,"members",1)="Alice"
	SET CTX("groups","items",1,"members",2)="Bob"
	SET CTX("groups","items",2,"name")="Tools"
	; No members under group 2 => should show EMPTY
	SET OK=$$EVAL^MIOTPL(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT(OK,"eval")
	SET RES=$$JOIN^MIOTPL(.OUT)
	DO EQ^MIOTASSERT(RES,"G=Core:[Alice,Bob,];G=Tools:[EMPTY];","deep nested scalars render")
	QUIT