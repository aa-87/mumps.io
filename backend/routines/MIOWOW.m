MIOWOW ; MIOTPL advanced demo routes (wow factor)
;
; Assumes MIOROUTE and MIOHTTP exist in your project.;
;
; PUBLIC
;   REG        - register routes
;   WOW        - GET /wow
;   PLAY       - GET /wow/playground
;   APIRENDER  - POST /wow/api/render
;
REG(CONF)
	D ADD^MIOROUTE("GET","/wow","WOW^MIOWOW")
	D ADD^MIOROUTE("GET","/wow/playground","PLAY^MIOWOW")
	D ADD^MIOROUTE("POST","/wow/api/render","APIRENDER^MIOWOW")
	Q
	;
WOW(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	K TCTX
	D BASECTX(.TCTX)
	S TCTX("page","heading")="MIOTPL Wow Dashboard"
	S TCTX("page","lead")="Blocks + partial components + dynamic partial selection + safe rendering."
	S TCTX("metrics",1,"label")="Templates",TCTX("metrics",1,"value")="Layouts / Pages / Partials"
	S TCTX("metrics",2,"label")="Cache",TCTX("metrics",2,"value")="^MIO(""TPL"",""CACHE"",...)"
	S TCTX("metrics",3,"label")="Safety",TCTX("metrics",3,"value")="Traversal + recursion limits"
	; dynamic component example: choose which hero partial to render
	S TCTX("hero","component")="ui_hero"
	S TCTX("hero","title")="Build real apps in M"
	S TCTX("hero","subtitle")="Component partials + inheritance feel like modern web frameworks."
	;
	D START^MIOTPL(.CONF)
	D RENDERPAGE^MIOTPL("pages/wow.html","layouts/wow_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPJSON^MIOHTTP(DEV,500,.CTX,"{""error"":""template_error""}") Q
	N HEAD S HEAD("Content-Type")="text/html; charset=utf-8"
	D RESP^MIOHTTP(DEV,.CONF,200,.HEAD,.OUT,CTX("request_id"))
	Q
	;
PLAY(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	K TCTX
	D BASECTX(.TCTX)
	S TCTX("page","heading")="Template Playground"
	S TCTX("page","lead")="Below, you can define input data and one or more Mustache templates. Pressing the “Render” button below a template reveals the result of that template, given your input."
	S TCTX("starterTpl")=""
	S TCTX("starterTpl")=TCTX("starterTpl")_" {{string}} {{#emphasize}}{{nested.string}}{{/emphasize}}"_$C(10)
	S TCTX("starterTpl")=TCTX("starterTpl")_"<ul>"_$C(10)
	S TCTX("starterTpl")=TCTX("starterTpl")_"    {{#list}}"_$C(10)
	S TCTX("starterTpl")=TCTX("starterTpl")_"    <li>{{.}}"_$C(10)
	S TCTX("starterTpl")=TCTX("starterTpl")_"    {{/list}}"_$C(10)
	S TCTX("starterTpl")=TCTX("starterTpl")_"</ul>"_$C(10)
	;
	S TCTX("boolean")="true"
	S TCTX("emphasize")="$$EMPHASIZE^MIOWOW"
	S TCTX("list",1)="null"
	S TCTX("list",2)="one"
	S TCTX("list",3)=2
	S TCTX("nested","string")="world"
	S TCTX("number")=1.5
	S TCTX("string")="hello"
	N T S T=""
	 S T=T_"{"_$C(10)
	S T=T_"  ""boolean"": true,"_$C(10)
	S T=T_"  ""emphasize"": ""$$EMPHASIZE^MIOWOW"","_$C(10)
	S T=T_"  ""list"": ["_$C(10)
	S T=T_"    null,"_$C(10)
	S T=T_"    ""one"","_$C(10)
	S T=T_"     2"_$C(10)
	S T=T_"  ],"_$C(10)
	S T=T_"  ""nested"": {"_$C(10)
	S T=T_"    ""string"": ""world"""_$C(10)
	S T=T_"   },"_$C(10)
	S T=T_"  ""number"": ""1.5"","_$C(10)
	S T=T_"  ""string"": ""hello"""_$C(10)
	S T=T_"}"
		S TCTX("starterJson")=T
	D RENDERPAGE^MIOTPL("pages/playground.html","layouts/wow_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPJSON^MIOHTTP(DEV,500,.CTX,"{""error"":""template_error""}") Q
	N HEAD S HEAD("Content-Type")="text/html; charset=utf-8"
	D RESP^MIOHTTP(DEV,.CONF,200,.HEAD,.OUT,CTX("request_id"))
	Q
	;
APIRENDER(DEV,CONF,REQ,CTX)
	; Expected request body JSON: {"template":"...","context":{...}}
	; Wire this to your project's JSON parser.;
	; SECURITY: do NOT allow lambdas from user input.;
	N ERR,OUT,TPL,TCTX
	K ERR,TCTX
	;
	; Demo fallback: accept form fields (playground uses this)
	;	
	N POSTREQ
	DO DECODEFORM^MIOFNC($G(REQ("body")),.POSTREQ) 
	S TPL=$G(POSTREQ("template"))
	D DECODE^MIOJSON(POSTREQ("json"),.TCTX)
	;	
	M ^A=POSTREQ,^B=TCTX
	D RENDERANY^MIOTPL(TPL,.CONF,.TCTX,.OUT,.ERR)
	M ^C=ERR,^D=OUT
	I $D(ERR) D RESPJSON^MIOHTTP(DEV,500,.CTX,"{""error"":""render_failed""}") Q
	;
	N HEAD S HEAD("Content-Type")="text/plain; charset=utf-8"
	D RESP^MIOHTTP(DEV,.CONF,200,.HEAD,.OUT,CTX("request_id"))
	Q
	;
BASECTX(TCTX)
	S TCTX("brand")="MIOTPL"
	S TCTX("nav",1,"href")="/wow",TCTX("nav",1,"label")="Dashboard"
	S TCTX("nav",2,"href")="/wow/playground",TCTX("nav",2,"label")="Playground"
	Q
	;
STRIPLAM(CTX)
	; Removes any scalar values that begin with "$$" (lambda marker)
	N K,V
	S K="" F  S K=$O(CTX(K)) Q:K=""  D
	. I $D(CTX(K))#2 D
	. . S V=$G(CTX(K))
	. . I $E(V,1,2)="$$" S CTX(K)=""
	Q
	;
EMPHASIZE(TEXT,LRID) ;LAM_HOS_MCALL_IN
	Q "<em>"_$G(TEXT)_"</em>"