MIOTEST 
	;
	;
	;
	D MIOTF123
	D MIOTF124
	D MIOTF125
	Q
	;
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
	;
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
	;
MIOTF125 ; Full suite test 125 - TPL_INVERTED_NORESULTS.;
	N %MIOTESTF125
	NEW TOK,ERR,OK,CONF,CTX,OUT,RES
	; Template: show "NONE" only when packages is falsey/empty.;
	SET OK=$$COMPILE^MIOTPL("{{^packages}}NONE{{/packages}}{{#packages}}YES{{/packages}}",.TOK,.ERR)
	DO OK^MIOTASSERT(OK,"compile")
	;
	; Case A: packages has an item => inverted must NOT render, normal must render.;
	S %MIOTESTF125="eval A" KILL CTX
	SET CTX("packages",1,"name")="Pkg1"
	SET OK=$$EVAL^MIOTPL(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT(OK,"eval A")
	SET RES=$$JOIN^MIOTPL(.OUT)
	DO EQ^MIOTASSERT(RES,"YES","TF125 "_%MIOTESTF125_" inverted suppressed when list has items") ;CURRENT PROBLEM= inverted suppressed when list has no items !!!!!
	;
	; Case B: packages empty => inverted MUST render, normal must NOT render.;
	S %MIOTESTF125="eval B" KILL OUT,ERR,CTX
	SET OK=$$EVAL^MIOTPL(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT(OK,"eval B")
	SET RES=$$JOIN^MIOTPL(.OUT)
	DO EQ^MIOTASSERT(RES,"NONE","TF125 "_%MIOTESTF125_" inverted renders when list empty")
	;
	QUIT