MIOPLGD ; MIOPLGD - MIOTPL Template Playground + Library (Tailwind UI)
;
; MUMPS.IO - Template Playground (server-rendered UI + API render/save/favorite)
; -----------------------------------------------------------------------------
; Goals (V1):
;   - Modern Tailwind UI (CDN) + lightweight animations
;   - Template playground (edit template + JSON context; render output)
;   - Built-in template library + user templates + favorites (stored in ^MIO)
;   - Production-safe defaults (no untrusted lambdas; optional sandbox rules)
;
; ROI 4 (Library UX):
;   - Server-side search (q), group filter, tag filter, and sorting
;   - Tag + group facets w/ counts
;   - "Recently updated" panel
;
; ROI 4.5/4.6 (Scale UX):
;   - Cursor-stable pagination (after/before) + items-per-page
;   - Jump-to-page (page) + first/last links + page indicator
;
; Assumes these project components exist:
;   - MIOROUTE  : routing (ADD^MIOROUTE(method,path,handler))
;   - MIOHTTP   : HTTP responses (RESP^MIOHTTP, RESPJSON^MIOHTTP if available)
;   - MIOJSON   : JSON decode (DECODE^MIOJSON(json,.OUT))
;   - MIOTPL    : template engine (START^MIOTPL, RENDERPAGE^MIOTPL, RENDERANY^MIOTPL)
;   - (optional) MIOFNC : form decode (DECODEFORM^MIOFNC); if missing, we fall back
;
; Storage (globals)
;   ^MIO("PLGD","meta","seeded")=1
;   ^MIO("PLGD","meta","nextId")=<int>
;   ^MIO("PLGD","tpl",ID,"name")=<string>
;   ^MIO("PLGD","tpl",ID,"desc")=<string>
;   ^MIO("PLGD","tpl",ID,"group")=<string>
;   ^MIO("PLGD","tpl",ID,"tags")=<comma-separated tags>
;   ^MIO("PLGD","tpl",ID,"fav")=0|1
;   ^MIO("PLGD","tpl",ID,"createdH")=$H
;   ^MIO("PLGD","tpl",ID,"updatedH")=$H
;   ^MIO("PLGD","tpl",ID,"tpl",N)=<line>
;   ^MIO("PLGD","tpl",ID,"json",N)=<line>
;   ^MIO("PLGD","idx","tag",tagKey,ID)=1   ; normalized tag index (ROI4)
;
; Public entry points
;   REG(CONF)               - register routes
;   HOME(DEV,CONF,REQ,CTX)  - GET /plgd
;   PLAY(DEV,CONF,REQ,CTX)  - GET /plgd/playground
;   ABOUT(...)              - GET /plgd/about
;   APIRENDER(...)          - POST /plgd/api/render
;   APISAVE(...)            - POST /plgd/api/save
;   APIFAV(...)             - POST /plgd/api/fav
;   APIEXPORT(...)          - POST /plgd/api/export
;   APIIMPORT(...)          - POST /plgd/api/import
;
REG(CONF)
	; UI
	D ADD^MIOROUTE("GET","/plgd","HOME^MIOPLGD")
	D ADD^MIOROUTE("GET","/plgd/playground","PLAY^MIOPLGD")
	D ADD^MIOROUTE("GET","/plgd/about","ABOUT^MIOPLGD")
	; API
	D ADD^MIOROUTE("POST","/plgd/api/render","APIRENDER^MIOPLGD")
	D ADD^MIOROUTE("POST","/plgd/api/save","APISAVE^MIOPLGD")
	D ADD^MIOROUTE("POST","/plgd/api/fav","APIFAV^MIOPLGD")
	D ADD^MIOROUTE("POST","/plgd/api/export","APIEXPORT^MIOPLGD")
	D ADD^MIOROUTE("POST","/plgd/api/import","APIIMPORT^MIOPLGD")
	D ADD^MIOROUTE("POST","/plgd/api/revs","APIREVS^MIOPLGD")
	D ADD^MIOROUTE("POST","/plgd/api/revget","APIREVGET^MIOPLGD")
	D ADD^MIOROUTE("POST","/plgd/api/rollback","APIROLL^MIOPLGD")
	Q
	;
HOME(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR,OPT,VIEW,FAVONLY,Q,GRP,TAG,SORT,PAGE,PER,AFTER,BEFORE,PAR
	K TCTX,ERR
	D CONFDEF(.CONF)
	D INIT(.CONF)
	D BASECTX(.TCTX)
	S TCTX("page","heading")="MIOPLGD"
	S TCTX("page","lead")="A modern template playground for MIOTPL (Mustache-first). Edit templates, provide JSON context, render output, and curate a reusable library."
	;
	; ROI4/4.5 filters + pagination
	S VIEW=$$QSVAL(.REQ,"view","grid")
	S FAVONLY=$$QSVAL(.REQ,"fav","0")
	S Q=$$QSVAL(.REQ,"q","")
	S GRP=$$QSVAL(.REQ,"group","")
	S TAG=$$QSVAL(.REQ,"tag","")
	S SORT=$$QSVAL(.REQ,"sort","updated") ; name|updated|created|group|fav
	S PAGE=+$$QSVAL(.REQ,"page","1")
	S PER=+$$QSVAL(.REQ,"per","18")
	S AFTER=$$QSVAL(.REQ,"after","")
	S BEFORE=$$QSVAL(.REQ,"before","")
	I PAGE<1 S PAGE=1
	I PER<6 S PER=6
	I PER>96 S PER=96
	;
	S TCTX("view")=VIEW
	K TCTX("ui")
	S TCTX("ui","isGrid")=$S(VIEW="grid":1,1:0)
	S TCTX("ui","isList")=$S(VIEW="list":1,1:0)
	I VIEW="list" S TCTX("tplCardPartial")="partials/ui_tpl_card_list"
	E  S TCTX("tplCardPartial")="partials/ui_tpl_card_grid"
	;
	S OPT("favOnly")=FAVONLY
	S OPT("q")=Q
	S OPT("group")=GRP
	S OPT("tag")=TAG
	S OPT("sort")=SORT
	S OPT("view")=VIEW
	S OPT("paginate")=1
	S OPT("page")=PAGE
	S OPT("per")=PER
	S OPT("after")=AFTER
	S OPT("before")=BEFORE
	D LOADLIB(.TCTX,.OPT)
	D LOADMETA(.TCTX,.OPT)
	;
	; View toggles should preserve current filters/per, but reset cursor.;
	K PAR D BUILDPAR(.PAR,.OPT)
	S PAR("view")="grid" S TCTX("links","viewGrid")=$$MKURL("/plgd",.PAR,0)
	K PAR D BUILDPAR(.PAR,.OPT)
	S PAR("view")="list" S TCTX("links","viewList")=$$MKURL("/plgd",.PAR,0)
	;
	D START^MIOTPL(.CONF)
	D RENDERPAGE^MIOTPL("pages/plgd_home.html","layouts/plgd_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(DEV,.CONF,.CTX,.OUT)
	Q
	;
PLAY(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR,OPT,ID,REC,VIEW
	K TCTX,ERR
	D CONFDEF(.CONF)
	D INIT(.CONF)
	D BASECTX(.TCTX)
	S TCTX("page","heading")="Playground"
	S TCTX("page","lead")="Pick a template from your library, edit it, set JSON context, and render in real time."
	;
	S VIEW=$$QSVAL(.REQ,"view","grid")
	S TCTX("view")=VIEW
	;
	S ID=$$QSVAL(.REQ,"id","")
	I ID="" S ID=$$FIRSTID()
	I ID'="" D GETREC(ID,.REC)
	;
	I '$D(REC) D
	. S TCTX("sel","id")=""
	. S TCTX("sel","name")="New Template"
	. S TCTX("sel","group")="Scratch"
	. S TCTX("sel","tags")="starter"
	. S TCTX("sel","desc")="A blank template. Start typing and save it to your library."
	. S TCTX("sel","fav")=0
	. S TCTX("sel","tpl")="{{title}}"_$C(10)_"{{#items}}- {{.}}"_$C(10)_"{{/items}}"
	. S TCTX("sel","json")="{""title"":""Hello from MIOPLGD"",""items"":[""one"",""two""]}"
	E  D
	. S TCTX("sel","id")=REC("id")
	. S TCTX("sel","name")=REC("name")
	. S TCTX("sel","group")=REC("group")
	. S TCTX("sel","tags")=$G(REC("tags"))
	. S TCTX("sel","desc")=REC("desc")
	. S TCTX("sel","fav")=+$G(REC("fav"))
	. S TCTX("sel","tpl")=$G(REC("tpl"))
	. S TCTX("sel","json")=$G(REC("json"))
	;
	; Keep sidebar predictable: name sort, no filters here (client-side quick search remains)
	S OPT("favOnly")=0
	S OPT("q")=""
	S OPT("group")=""
	S OPT("tag")=""
	S OPT("sort")="name"
	S OPT("view")=VIEW
	D LOADLIB(.TCTX,.OPT)
	;
	D START^MIOTPL(.CONF)
	D RENDERPAGE^MIOTPL("pages/plgd_playground.html","layouts/plgd_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(DEV,.CONF,.CTX,.OUT)
	Q
	;
ABOUT(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	K TCTX,ERR
	D CONFDEF(.CONF)
	D INIT(.CONF)
	D BASECTX(.TCTX)
	S TCTX("page","heading")="About"
	S TCTX("page","lead")="MIOPLGD is a MIOTPL-powered playground designed for fast iteration, safe rendering, and reusable template libraries."
	D START^MIOTPL(.CONF)
	D RENDERPAGE^MIOTPL("pages/plgd_about.html","layouts/plgd_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(DEV,.CONF,.CTX,.OUT)
	Q
	;
APIRENDER(DEV,CONF,REQ,CTX)
	; Render a template with context.;
	; Accepts either:
	;   x-www-form-urlencoded: template=...&json=...;
	;   JSON: {"template":"...","json":"{...}"} or {"template":"...","context":{...}}
	;
	N BODY,POST,OBJ,TPL,JSON,TCTX,OUT,ERR
	K POST,OBJ,TCTX,ERR
	D CONFDEF(.CONF)
	D INIT(.CONF)
	;
	S BODY=$G(REQ("body"))
	D PARSEBODY(BODY,.POST,.OBJ)
	S TPL=$G(POST("template")) I TPL="" S TPL=$G(OBJ("template"))
	S JSON=$G(POST("json")) I JSON="" S JSON=$G(OBJ("json"))
	;
	; If client posted a decoded object under "context", use it.;
	I $D(OBJ("context")) M TCTX=OBJ("context")
	E  D
	. I JSON="" S JSON="{}"
	. D TRYJSON(JSON,.TCTX,.ERR)
	;
	I $D(ERR) D RESPERR(DEV,.CONF,.CTX,400,"invalid_json",$G(ERR("zstatus"))) Q
	;
	; SECURITY: strip any lambdas from untrusted input (scalar values beginning with "$$")
	D STRIPLAMR(.TCTX)
	;
	; Optional sandbox rule: disallow partials/inheritance in ad-hoc templates.;
	; (Library templates are server-stored; ad-hoc templates are user-provided.)
	I $$HASTAG(TPL,"{{>")!$$HASTAG(TPL,"{{<") D RESPERR(DEV,.CONF,.CTX,400,"partials_disabled") Q
	;
	D START^MIOTPL(.CONF)
	D RENDERANY^MIOTPL(TPL,.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(DEV,.CONF,.CTX,500,"render_failed",$$ERR2TXT(.ERR)) Q
	;
	D RESPTXT(DEV,.CONF,.CTX,.OUT)
	Q
	;
APISAVE(DEV,CONF,REQ,CTX)
	; Save (create/update) a template library entry.;
	; Expected form fields:
	;   id (optional), name, group, tags, desc, fav (0|1), template, json
	;
	N BODY,POST,OBJ,ID,REC,RESP,JCTX,JERR
	K POST,OBJ,JERR
	D CONFDEF(.CONF)
	D INIT(.CONF)
	;
	S BODY=$G(REQ("body"))
	D PARSEBODY(BODY,.POST,.OBJ)
	;
	S ID=$G(POST("id")) I ID="" S ID=$G(OBJ("id"))
	S REC("id")=ID
	S REC("name")=$$TRIM($G(POST("name"))) I REC("name")="" S REC("name")=$$TRIM($G(OBJ("name")))
	S REC("group")=$$TRIM($G(POST("group"))) I REC("group")="" S REC("group")=$$TRIM($G(OBJ("group")))
	S REC("tags")=$$TRIM($G(POST("tags"))) I REC("tags")="" S REC("tags")=$$TRIM($G(OBJ("tags")))
	S REC("desc")=$$TRIM($G(POST("desc"))) I REC("desc")="" S REC("desc")=$$TRIM($G(OBJ("desc")))
	S REC("fav")=+$G(POST("fav")) I REC("fav")=0,$G(OBJ("fav"))'="" S REC("fav")=+$G(OBJ("fav"))
	S REC("tpl")=$G(POST("template")) I REC("tpl")="" S REC("tpl")=$G(OBJ("template"))
	S REC("json")=$G(POST("json")) I REC("json")="" S REC("json")=$G(OBJ("json"))
	;
	; Basic validation
	I REC("name")="" D RESPERR(DEV,.CONF,.CTX,400,"name_required") Q
	I REC("group")="" S REC("group")="General"
	S REC("tags")=$$SANITAGS($G(REC("tags")))
	I $L(REC("name"))>80 S REC("name")=$E(REC("name"),1,80)
	I $L(REC("group"))>40 S REC("group")=$E(REC("group"),1,40)
	I $L(REC("tags"))>140 S REC("tags")=$E(REC("tags"),1,140)
	I $L(REC("desc"))>280 S REC("desc")=$E(REC("desc"),1,280)
	;
	; Size limits (adjust as needed)
	I $L(REC("tpl"))>200000 D RESPERR(DEV,.CONF,.CTX,413,"template_too_large") Q
	I $L(REC("json"))>200000 D RESPERR(DEV,.CONF,.CTX,413,"json_too_large") Q
	;
	; Prevent HTML-breakout sequences when we later show it inside <textarea>.;
	I $$HASTAG(REC("tpl"),"</textarea") D RESPERR(DEV,.CONF,.CTX,400,"invalid_template") Q
	I $$HASTAG(REC("json"),"</textarea") D RESPERR(DEV,.CONF,.CTX,400,"invalid_json") Q
	;
	; Ensure JSON is parseable; if not, still allow save but return a warning.;
	D TRYJSON($S(REC("json")="":"{}",1:REC("json")),.JCTX,.JERR)
	;
	; Versioning (ROI): snapshot current before overwrite if this is an update and content changed
	I ID'="",$D(^MIO("PLGD","tpl",ID)) D
	. N OLD,CHG
	. K OLD S CHG=0
	. D GETREC(ID,.OLD)
	. I $G(OLD("name"))'=$G(REC("name")) S CHG=1
	. I $G(OLD("group"))'=$G(REC("group")) S CHG=1
	. I $G(OLD("tags"))'=$G(REC("tags")) S CHG=1
	. I $G(OLD("desc"))'=$G(REC("desc")) S CHG=1
	. I +$G(OLD("fav"))'=+$G(REC("fav")) S CHG=1
	. I $G(OLD("tpl"))'=$G(REC("tpl")) S CHG=1
	. I $G(OLD("json"))'=$G(REC("json")) S CHG=1
	. I CHG D SAVEREV(ID,"save")
	;
	S ID=$$SAVEREC(.REC)
	S RESP="{""ok"":true,""id"":"""_ID_""""
	I $D(JERR) S RESP=RESP_",""warning"":""json_invalid"""
	S RESP=RESP_"}"
	D RESPJSON(DEV,.CONF,.CTX,200,RESP)
	Q
	;
APIFAV(DEV,CONF,REQ,CTX)
	; Toggle favorite
	N BODY,POST,OBJ,ID,VAL,RESP
	K POST,OBJ
	D CONFDEF(.CONF)
	D INIT(.CONF)
	S BODY=$G(REQ("body"))
	D PARSEBODY(BODY,.POST,.OBJ)
	S ID=$G(POST("id")) I ID="" S ID=$G(OBJ("id"))
	I ID="" D RESPERR(DEV,.CONF,.CTX,400,"id_required") Q
	I '$D(^MIO("PLGD","tpl",ID)) D RESPERR(DEV,.CONF,.CTX,404,"not_found") Q
	S VAL=$G(POST("fav")) I VAL="" S VAL=$G(OBJ("fav"))
	I VAL="" S VAL=$S(+$G(^MIO("PLGD","tpl",ID,"fav"))=1:0,1:1)
	S ^MIO("PLGD","tpl",ID,"fav")=+VAL
	S ^MIO("PLGD","tpl",ID,"updatedH")=$H
	S RESP="{""ok"":true,""id"":"""_ID_""",""fav"":"_+VAL_"}"
	D RESPJSON(DEV,.CONF,.CTX,200,RESP)
	Q
	;
APIEXPORT(DEV,CONF,REQ,CTX)
	; Export library templates as JSON.;
	N JSON S JSON=$$EXPORTJSON()
	D RESPJSON(DEV,.CONF,.CTX,200,JSON)
	Q
	;
APIIMPORT(DEV,CONF,REQ,CTX)
	; Import templates from JSON.;
	; Expected body: {"templates":[{...},{...}]}
	N BODY,OBJ,POST,ERR,RESP
	K OBJ,POST,ERR
	D CONFDEF(.CONF)
	D INIT(.CONF)
	S BODY=$G(REQ("body"))
	D PARSEBODY(BODY,.POST,.OBJ)
	;
	I '$D(OBJ("templates")) D RESPERR(DEV,.CONF,.CTX,400,"templates_required") Q
	D IMPORT(.OBJ,.ERR)
	I $D(ERR) D RESPERR(DEV,.CONF,.CTX,400,"import_failed") Q
	S RESP="{""ok"":true}"
	D RESPJSON(DEV,.CONF,.CTX,200,RESP)
	Q
	;
	; -------------------------
	; Config + template context
	; -------------------------
APIREVS(DEV,CONF,REQ,CTX)
	; List revisions for a template ID (newest first)
	N BODY,POST,OBJ,ID,MAX,RID,JSON,N,NOTE,H
	K POST,OBJ
	D CONFDEF(.CONF)
	D INIT(.CONF)
	S BODY=$G(REQ("body"))
	D PARSEBODY(BODY,.POST,.OBJ)
	S ID=$G(POST("id")) I ID="" S ID=$G(OBJ("id"))
	I ID="" D RESPERR(DEV,.CONF,.CTX,400,"id_required") Q
	I '$D(^MIO("PLGD","tpl",ID)) D RESPERR(DEV,.CONF,.CTX,404,"not_found") Q
	S MAX=+$G(POST("max")) I MAX=0 S MAX=+$G(OBJ("max"))
	I MAX<1 S MAX=25
	I MAX>100 S MAX=100
	S JSON="{""ok"":true,""id"":"""_$$JESC(ID)_""",""revs"":["
	S N=0
	S RID=$O(^MIO("PLGD","tpl",ID,"rev",""),-1)
	F  Q:RID=""!(N'<MAX)  D  S RID=$O(^MIO("PLGD","tpl",ID,"rev",RID),-1)
	. S N=N+1
	. I N>1 S JSON=JSON_","
	. S NOTE=$G(^MIO("PLGD","tpl",ID,"rev",RID,"note"))
	. S H=$G(^MIO("PLGD","tpl",ID,"rev",RID,"savedH"))
	. S JSON=JSON_"{""rev"":"_+RID_",""savedH"":"""_$$JESC(H)_""",""savedAgo"":"""_$$JESC($$AGO(H))_""",""note"":"""_$$JESC(NOTE)_""",""name"":"""_$$JESC($G(^MIO("PLGD","tpl",ID,"rev",RID,"name")))_"""}"
	S JSON=JSON_"]}"
	D RESPJSON(DEV,.CONF,.CTX,200,JSON)
	Q
	;
APIREVGET(DEV,CONF,REQ,CTX)
	; Get a specific revision (includes tpl/json)
	N BODY,POST,OBJ,ID,RID,REC,JSON
	K POST,OBJ,REC
	D CONFDEF(.CONF)
	D INIT(.CONF)
	S BODY=$G(REQ("body"))
	D PARSEBODY(BODY,.POST,.OBJ)
	S ID=$G(POST("id")) I ID="" S ID=$G(OBJ("id"))
	S RID=$G(POST("rev")) I RID="" S RID=$G(OBJ("rev"))
	I ID="" D RESPERR(DEV,.CONF,.CTX,400,"id_required") Q
	I RID="" D RESPERR(DEV,.CONF,.CTX,400,"rev_required") Q
	I '$D(^MIO("PLGD","tpl",ID,"rev",RID)) D RESPERR(DEV,.CONF,.CTX,404,"rev_not_found") Q
	D GETREV(ID,RID,.REC)
	S JSON="{""ok"":true,""id"":"""_$$JESC(ID)_""",""rev"":"_+RID_",""name"":"""_$$JESC($G(REC("name")))_""",""group"":"""_$$JESC($G(REC("group")))_""",""tags"":"""_$$JESC($G(REC("tags")))_""",""desc"":"""_$$JESC($G(REC("desc")))_""",""fav"":"_+$G(REC("fav"))_",""template"":"""_$$JESC($G(REC("tpl")))_""",""json"":"""_$$JESC($G(REC("json")))_"""}"
	D RESPJSON(DEV,.CONF,.CTX,200,JSON)
	Q
	;
APIROLL(DEV,CONF,REQ,CTX)
	; Roll back a template to a prior revision
	N BODY,POST,OBJ,ID,RID,REC,NOTE,RESP
	K POST,OBJ,REC
	D CONFDEF(.CONF)
	D INIT(.CONF)
	S BODY=$G(REQ("body"))
	D PARSEBODY(BODY,.POST,.OBJ)
	S ID=$G(POST("id")) I ID="" S ID=$G(OBJ("id"))
	S RID=$G(POST("rev")) I RID="" S RID=$G(OBJ("rev"))
	I ID="" D RESPERR(DEV,.CONF,.CTX,400,"id_required") Q
	I RID="" D RESPERR(DEV,.CONF,.CTX,400,"rev_required") Q
	I '$D(^MIO("PLGD","tpl",ID)) D RESPERR(DEV,.CONF,.CTX,404,"not_found") Q
	I '$D(^MIO("PLGD","tpl",ID,"rev",RID)) D RESPERR(DEV,.CONF,.CTX,404,"rev_not_found") Q
	S NOTE="rollback_to_rev_"_RID
	D SAVEREV(ID,NOTE)
	D GETREV(ID,RID,.REC)
	S REC("id")=ID
	S ID=$$SAVEREC(.REC)
	S RESP="{""ok"":true,""id"":"""_ID_""",""rev"":"_+RID_"}"
	D RESPJSON(DEV,.CONF,.CTX,200,RESP)
	Q
	;
	;
CONFDEF(CONF)
	; Production-safe defaults (matches LLM_APPLICATION_SPEC)
	I '$D(CONF("templates","root")) S CONF("templates","root")="templates/"
	I '$D(CONF("templates","ext")) S CONF("templates","ext")=".html"
	I '$D(CONF("templates","precompileEnabled")) S CONF("templates","precompileEnabled")=0
	I '$D(CONF("templates","streamFiles")) S CONF("templates","streamFiles")=0
	I '$D(CONF("templates","streamFallback")) S CONF("templates","streamFallback")=1
	I '$D(CONF("templates","maxPartialDepth")) S CONF("templates","maxPartialDepth")=20
	I '$D(CONF("output","auto")) S CONF("output","auto")=1
	I '$D(CONF("output","maxString")) S CONF("output","maxString")=900000
	I '$D(CONF("output","autoReturnRef")) S CONF("output","autoReturnRef")=1
	Q
	;
BASECTX(TCTX)
	S TCTX("brand")="MIOPLGD"
	S TCTX("nav",1,"href")="/plgd",TCTX("nav",1,"label")="Library"
	S TCTX("nav",2,"href")="/plgd/playground",TCTX("nav",2,"label")="Playground"
	S TCTX("nav",3,"href")="/plgd/about",TCTX("nav",3,"label")="About"
	Q
	;
LOADLIB(TCTX,OPT)
	; Loads ^MIO("PLGD","tpl",...) into a render-friendly list: TCTX("tpls",n,...)
	; Filters:
	;   OPT("favOnly")=1
	;   OPT("q")=<string>
	;   OPT("group")=<group name>
	;   OPT("tag")=<tag label or key>
	; Sorting:
	;   OPT("sort") = name|updated|created|group|fav
	; Pagination (ROI4.5):
	;   OPT("paginate")=1 enables paging
	;   OPT("per")=<int> items per page
	;   OPT("page")=<int> (offset mode)
	;   OPT("after")=<cursor token> (forward)
	;   OPT("before")=<cursor token> (backward)
	;
	N ID,N,FAVONLY,REC,Q,GRP,TAG,SORT,ROOT,TKEY,HAY,KEEP,KEY
	N PAG,PER,PAGE,AFTER,BEFORE,OFF,SKIP,TAKEN,TOTAL
	N FIRSTKEY,FIRSTID,LASTKEY,LASTID,MODE
	K TCTX("tpls"),TCTX("metrics"),TCTX("pager")
	K ^TMP($J,"PLGD","sort"),^TMP($J,"PLGD","page")
	;
	S FAVONLY=+$G(OPT("favOnly"))
	S Q=$$TRIM($G(OPT("q")))
	S GRP=$$TRIM($G(OPT("group")))
	S TAG=$$TRIM($G(OPT("tag")))
	S SORT=$$TRIM($G(OPT("sort"))) I SORT="" S SORT="updated"
	S PAG=+$G(OPT("paginate"))
	S PER=+$G(OPT("per")) I PER<1 S PER=18
	I PER>200 S PER=200
	S PAGE=+$G(OPT("page")) I PAGE<1 S PAGE=1
	S AFTER=$G(OPT("after"))
	S BEFORE=$G(OPT("before"))
	S OFF=(PAGE-1)*PER
	S TOTAL=0
	;
	; Choose candidate ID stream (tag index if tag filter is present)
	I TAG'="" D
	. S TKEY=$$TAGKEY(TAG)
	. I $D(^MIO("PLGD","idx","tag",TKEY)) S ROOT=$NA(^MIO("PLGD","idx","tag",TKEY))
	. E  S ROOT=$NA(^MIO("PLGD","tpl"))
	E  S ROOT=$NA(^MIO("PLGD","tpl"))
	;
	; Build sorted index (metadata only; no template/json text)
	S ID=""
	F  S ID=$O(@ROOT@(ID)) Q:ID=""  D
	. ; when ROOT is tag index: ^...("idx","tag",TKEY,ID)=1; validate template exists
	. I ROOT'=$NA(^MIO("PLGD","tpl")),'$D(^MIO("PLGD","tpl",ID)) Q
	. I FAVONLY,($G(^MIO("PLGD","tpl",ID,"fav"))'=1) Q
	. I GRP'="",$G(^MIO("PLGD","tpl",ID,"group"))'=GRP Q
	. K REC D GETMETA(ID,.REC) Q:'$D(REC)
	. ; Search filter (name/desc/group/tags). Multi-word AND.;
	. I Q'="" D  Q:'KEEP
	. . S HAY=$$LC($G(REC("name"))_" "_$G(REC("desc"))_" "_$G(REC("group"))_" "_$G(REC("tags")))
	. . S KEEP=$$MATCHQ(HAY,Q)
	. ; Tag filter: if no tag index existed, we must filter manually
	. I TAG'="",ROOT=$NA(^MIO("PLGD","tpl")) D  Q:'KEEP
	. . S KEEP=$$HASTAG2($G(REC("tags")),TAG)
	. ; Build sort key
	. S KEY=$$SORTKEY(.REC,SORT)
	. S ^TMP($J,"PLGD","sort",KEY,ID)=""
	. S TOTAL=TOTAL+1
	;
	; Decide paging mode
	S MODE="all"
	I PAG D
	. I BEFORE'="" S MODE="before"
	. E  I AFTER'="" S MODE="after"
	. E  S MODE="offset"
	;
	; Clamp offset page within bounds (ROI4.6)
	I PAG,MODE="offset" D
	. N PGS S PGS=$S(+PER>0:((+TOTAL+PER-1)\PER),1:1)
	. I +TOTAL=0 S PGS=0
	. I PGS>0,(+PAGE>PGS) S PAGE=PGS,OFF=(PAGE-1)*PER
	;
	; Emit results (paged)
	S (TAKEN,N)=0
	S (FIRSTKEY,FIRSTID,LASTKEY,LASTID)=""
	I MODE="all" D
	. S KEY=""
	. F  S KEY=$O(^TMP($J,"PLGD","sort",KEY)) Q:KEY=""  D
	. . S ID=""
	. . F  S ID=$O(^TMP($J,"PLGD","sort",KEY,ID)) Q:ID=""  D
	. . . K REC D GETMETA(ID,.REC) Q:'$D(REC)
	. . . S TAKEN=TAKEN+1,N=TAKEN
	. . . D REC2CTX(.REC,.TCTX,N,.OPT)
	. S FIRSTKEY=$O(^TMP($J,"PLGD","sort","")),FIRSTID=$O(^TMP($J,"PLGD","sort",FIRSTKEY,""))
	. S LASTKEY=$O(^TMP($J,"PLGD","sort",""),-1),LASTID=$O(^TMP($J,"PLGD","sort",LASTKEY,""),-1)
	E  I MODE="offset" D
	. N STOP
	. S STOP=0,SKIP=OFF
	. S KEY=""
	. F  S KEY=$O(^TMP($J,"PLGD","sort",KEY)) Q:KEY=""!(STOP)  D
	. . S ID=""
	. . F  S ID=$O(^TMP($J,"PLGD","sort",KEY,ID)) Q:ID=""!(STOP)  D
	. . . I SKIP>0 S SKIP=SKIP-1 Q
	. . . K REC D GETMETA(ID,.REC) Q:'$D(REC)
	. . . I TAKEN=0 S FIRSTKEY=KEY,FIRSTID=ID
	. . . S TAKEN=TAKEN+1,N=TAKEN
	. . . D REC2CTX(.REC,.TCTX,N,.OPT)
	. . . S LASTKEY=KEY,LASTID=ID
	. . . I TAKEN'<PER S STOP=1
	E  I MODE="after" D
	. N AK,AI,STOP D CURPAR(AFTER,.AK,.AI)
	. S STOP=0
	. S KEY="",ID=""
	. ; jump to first node strictly after token
	. I AK'="" D
	. . S KEY=AK,ID=AI
	. . S ID=$O(^TMP($J,"PLGD","sort",KEY,ID))
	. . I ID="" S KEY=$O(^TMP($J,"PLGD","sort",KEY)),ID=""
	. E  S KEY=$O(^TMP($J,"PLGD","sort",KEY)),ID=""
	. F  Q:KEY=""!(STOP)  D
	. . I ID="" S ID=$O(^TMP($J,"PLGD","sort",KEY,ID))
	. . F  Q:ID=""!(STOP)  D
	. . . K REC D GETMETA(ID,.REC) Q:'$D(REC)
	. . . I TAKEN=0 S FIRSTKEY=KEY,FIRSTID=ID
	. . . S TAKEN=TAKEN+1,N=TAKEN
	. . . D REC2CTX(.REC,.TCTX,N,.OPT)
	. . . S LASTKEY=KEY,LASTID=ID
	. . . I TAKEN'<PER S STOP=1 Q
	. . . S ID=$O(^TMP($J,"PLGD","sort",KEY,ID))
	. . I ID="" S KEY=$O(^TMP($J,"PLGD","sort",KEY)),ID=""
	E  I MODE="before" D
	. N BK,BI,IDX,STOP D CURPAR(BEFORE,.BK,.BI)
	. S STOP=0
	. S KEY="",ID=""
	. I BK="" S KEY=$O(^TMP($J,"PLGD","sort",""),-1),ID=""
	. E  S KEY=BK,ID=BI
	. ; jump to node strictly before token
	. I KEY'="" D
	. . S ID=$O(^TMP($J,"PLGD","sort",KEY,ID),-1)
	. . I ID="" S KEY=$O(^TMP($J,"PLGD","sort",KEY),-1) I KEY'="" S ID=$O(^TMP($J,"PLGD","sort",KEY,""),-1)
	. S IDX=0
	. F  Q:KEY=""!(STOP)  D
	. . I ID="" S ID=$O(^TMP($J,"PLGD","sort",KEY,ID),-1)
	. . F  Q:ID=""!(STOP)  D
	. . . S IDX=IDX+1,^TMP($J,"PLGD","page",IDX)=ID,^TMP($J,"PLGD","page",IDX,"k")=KEY
	. . . I IDX'<PER S STOP=1 Q
	. . . S ID=$O(^TMP($J,"PLGD","sort",KEY,ID),-1)
	. . I ID="" S KEY=$O(^TMP($J,"PLGD","sort",KEY),-1) I KEY'="" S ID=$O(^TMP($J,"PLGD","sort",KEY,""),-1)
	. ; reverse emit so output is forward-sorted
	. F IDX=IDX:-1:1 D
	. . S ID=^TMP($J,"PLGD","page",IDX)
	. . S KEY=$G(^TMP($J,"PLGD","page",IDX,"k"))
	. . K REC D GETMETA(ID,.REC) Q:'$D(REC)
	. . I TAKEN=0 S FIRSTKEY=KEY,FIRSTID=ID
	. . S TAKEN=TAKEN+1,N=TAKEN
	. . D REC2CTX(.REC,.TCTX,N,.OPT)
	. . S LASTKEY=KEY,LASTID=ID
	; Pager context (cursor-stable Prev/Next)
	D PAGERCTX(.TCTX,.OPT,MODE,PER,PAGE,OFF,TOTAL,TAKEN,FIRSTKEY,FIRSTID,LASTKEY,LASTID)
	;
	; Metrics (total results are filter-aware)
	S TCTX("metrics",1,"label")="Results"
	S TCTX("metrics",1,"value")=TOTAL
	S TCTX("metrics",2,"label")="Favorites"
	S TCTX("metrics",2,"value")=$$FAVCOUNT()
	S TCTX("metrics",3,"label")="Engine"
	S TCTX("metrics",3,"value")="MIOTPL"
	Q
	;
REC2CTX(REC,TCTX,N,OPT)
	; Map record to a template card context node (TCTX("tpls",N,...))
	N TAGS,TI,VIEW,HP,PAR
	S VIEW=$G(OPT("view"))
	S TCTX("tpls",N,"id")=REC("id")
	S TCTX("tpls",N,"name")=REC("name")
	S TCTX("tpls",N,"group")=REC("group")
	S TCTX("tpls",N,"desc")=REC("desc")
	S TCTX("tpls",N,"tags")=$G(REC("tags"))
	; tags list (for UI chips)
	K TCTX("tpls",N,"tagList")
	I $G(REC("tags"))'="" D
	. N A,LBL,TI
	. K A D PARSETAGS($G(REC("tags")),.A)
	. S TI=0,LBL=""
	. F  S LBL=$O(A(LBL)) Q:LBL=""  D  Q:TI'<6
	. . S TI=TI+1
	. . S TCTX("tpls",N,"tagList",TI)=LBL
	S TCTX("tpls",N,"fav")=+$G(REC("fav"))
	S TCTX("tpls",N,"favText")=$S(+$G(REC("fav"))=1:"Favorited",1:"Favorite")
	S TCTX("tpls",N,"favIcon")=$S(+$G(REC("fav"))=1:"★",1:"☆")
	S TCTX("tpls",N,"updatedH")=$G(REC("updatedH"))
	S TCTX("tpls",N,"updatedAgo")=$$AGO($G(REC("updatedH")))
	;
	; Group quick-filter link
	K PAR D BUILDPAR(.PAR,.OPT)
	S PAR("group")=REC("group")
	S PAR("view")=$S(VIEW="":"grid",1:VIEW)
	S TCTX("tpls",N,"groupHref")=$$MKURL("/plgd",.PAR,0)
	;
	; Tag chips (each chip links to tag filter)
	K TCTX("tpls",N,"tagsArr")
	S TAGS=$G(REC("tags"))
	I TAGS'="" D
	. D TAGARR(TAGS,$NA(TCTX("tpls",N,"tagsArr")),.OPT)
	Q
	;
TAGARR(TAGS,OUTREF,OPT)
	; OUTREF is a closed reference like $NA(TCTX(...,"tagsArr"))
	N ARR,TI,LBL,KEY,PAR,VIEW
	K ARR
	D PARSETAGS(TAGS,.ARR)
	S TI=0,VIEW=$G(OPT("view"))
	S LBL=""
	F  S LBL=$O(ARR(LBL)) Q:LBL=""  D
	. S TI=TI+1
	. S @OUTREF@(TI,"label")=LBL
	. K PAR D BUILDPAR(.PAR,.OPT)
	. S PAR("tag")=LBL
	. S PAR("view")=$S(VIEW="":"grid",1:VIEW)
	. S @OUTREF@(TI,"href")=$$MKURL("/plgd",.PAR,0)
	Q
	;
LOADMETA(TCTX,OPT)
	; Build facet lists (groups + tags) and recently updated panel
	N ID,GRP,GC,TC,TLBL,TKEY,REC,MAXREC,KEY,HSEC,INV,PAR,VIEW,Q,SORT,FAVONLY,SEL
	K TCTX("facets"),TCTX("recent")
	K ^TMP($J,"PLGD","facetG"),^TMP($J,"PLGD","facetT"),^TMP($J,"PLGD","recent")
	;
	S VIEW=$G(OPT("view"))
	S Q=$G(OPT("q")),SORT=$G(OPT("sort")),FAVONLY=$G(OPT("favOnly"))
	;
	; Facets from all templates (not filter-dependent)
	S ID=""
	F  S ID=$O(^MIO("PLGD","tpl",ID)) Q:ID=""  D
	. S GRP=$G(^MIO("PLGD","tpl",ID,"group")) I GRP="" S GRP="(none)"
	. S ^TMP($J,"PLGD","facetG",GRP)=$G(^TMP($J,"PLGD","facetG",GRP))+1
	. S TLBL=$G(^MIO("PLGD","tpl",ID,"tags")) I TLBL'="" D
	. . N ARR S ARR="" K ARR
	. . D PARSETAGS(TLBL,.ARR)
	. . S TLBL=""
	. . F  S TLBL=$O(ARR(TLBL)) Q:TLBL=""  D
	. . . S ^TMP($J,"PLGD","facetT",TLBL)=$G(^TMP($J,"PLGD","facetT",TLBL))+1
	. ; Recently updated (top 6)
	. K REC D GETMETA(ID,.REC) Q:'$D(REC)
	. S HSEC=$$H2S($G(REC("updatedH"))) ; seconds since epoch-ish
	. ; invert for asc lexical sort
	. S INV=$$PAD((999999999999-HSEC),12)
	. S KEY=INV_"|"_$$LC($G(REC("name")))_"|"_ID
	. S ^TMP($J,"PLGD","recent",KEY)=ID
	;
	; Active filter echo back to templates (for form controls / clear button)
	S TCTX("filters","q")=$G(OPT("q"))
	S TCTX("filters","group")=$G(OPT("group"))
	S TCTX("filters","tag")=$G(OPT("tag"))
	S TCTX("filters","sort")=$G(OPT("sort"))
	S TCTX("filters","fav")=+$G(OPT("favOnly"))
	S TCTX("filters","view")=$S(VIEW="":"grid",1:VIEW)
	S TCTX("filters","per")=$S(+$G(OPT("per"))>0:+$G(OPT("per")),1:18)
	S TCTX("filters","hasAny")=$S(($G(OPT("q"))'="")!($G(OPT("group"))'="")!($G(OPT("tag"))'="")!(+$G(OPT("favOnly"))=1)!($G(OPT("sort"))'="updated"):1,1:0)
	;
	; Links: clear filters (preserve view/per)
	K PAR S PAR("view")=$S(VIEW="":"grid",1:VIEW),PAR("per")=$G(OPT("per"))
	S TCTX("links","clear")=$$MKURL("/plgd",.PAR,0)
	; View links (preserve filters/per)
	K PAR D BUILDPAR(.PAR,.OPT) S PAR("view")="grid" S TCTX("links","viewGrid")=$$MKURL("/plgd",.PAR,0)
	K PAR D BUILDPAR(.PAR,.OPT) S PAR("view")="list" S TCTX("links","viewList")=$$MKURL("/plgd",.PAR,0)
	;
	; Sort options
	D SORTOPTS(.TCTX,$G(OPT("sort")))
	D PEROPTS(.TCTX,$S(+$G(OPT("per"))>0:+$G(OPT("per")),1:18))
	;
	; Groups facet
	S GRP="",GC=0
	F  S GRP=$O(^TMP($J,"PLGD","facetG",GRP)) Q:GRP=""  D
	. S GC=GC+1
	. S TCTX("facets","groups",GC,"name")=GRP
	. S TCTX("facets","groups",GC,"count")=^TMP($J,"PLGD","facetG",GRP)
	. S SEL=$S($G(OPT("group"))=GRP:1,1:0)
	. S TCTX("facets","groups",GC,"isSel")=SEL
	. K PAR
	. I SEL S PAR("group")="" ; clicking selected removes filter
	. E  S PAR("group")=GRP
	. S PAR("q")=$G(OPT("q"))
	. S PAR("tag")=$G(OPT("tag"))
	. S PAR("sort")=$G(OPT("sort"))
	. S PAR("fav")=$G(OPT("favOnly"))
	. S PAR("view")=$S(VIEW="":"grid",1:VIEW)
	. S PAR("per")=$G(OPT("per"))
	. S TCTX("facets","groups",GC,"href")=$$MKURL("/plgd",.PAR,1)
	;
	; Tags facet
	S TLBL="",TC=0
	F  S TLBL=$O(^TMP($J,"PLGD","facetT",TLBL)) Q:TLBL=""  D
	. S TC=TC+1
	. S TCTX("facets","tags",TC,"name")=TLBL
	. S TCTX("facets","tags",TC,"count")=^TMP($J,"PLGD","facetT",TLBL)
	. S SEL=$S($$TAGKEY($G(OPT("tag")))=$$TAGKEY(TLBL):1,1:0)
	. S TCTX("facets","tags",TC,"isSel")=SEL
	. K PAR
	. I SEL S PAR("tag")=""
	. E  S PAR("tag")=TLBL
	. S PAR("q")=$G(OPT("q"))
	. S PAR("group")=$G(OPT("group"))
	. S PAR("sort")=$G(OPT("sort"))
	. S PAR("fav")=$G(OPT("favOnly"))
	. S PAR("view")=$S(VIEW="":"grid",1:VIEW)
	. S PAR("per")=$G(OPT("per"))
	. S TCTX("facets","tags",TC,"href")=$$MKURL("/plgd",.PAR,1)
	;
	; Recent panel (top 6)
	S KEY="",MAXREC=0
	F  S KEY=$O(^TMP($J,"PLGD","recent",KEY)) Q:KEY=""  D  Q:MAXREC'<6
	. S ID=^TMP($J,"PLGD","recent",KEY)
	. K REC D GETMETA(ID,.REC) Q:'$D(REC)
	. S MAXREC=MAXREC+1
	. S TCTX("recent",MAXREC,"id")=REC("id")
	. S TCTX("recent",MAXREC,"name")=REC("name")
	. S TCTX("recent",MAXREC,"group")=REC("group")
	. S TCTX("recent",MAXREC,"updatedAgo")=$$AGO($G(REC("updatedH")))
	Q
	;
SORTOPTS(TCTX,SEL)
	; Provide sort dropdown list
	K TCTX("sorts")
	S TCTX("sorts",1,"val")="updated",TCTX("sorts",1,"label")="Recently updated"
	S TCTX("sorts",2,"val")="name",TCTX("sorts",2,"label")="Name (A→Z)"
	S TCTX("sorts",3,"val")="created",TCTX("sorts",3,"label")="Recently created"
	S TCTX("sorts",4,"val")="group",TCTX("sorts",4,"label")="Group, then name"
	S TCTX("sorts",5,"val")="fav",TCTX("sorts",5,"label")="Favorites first"
	N I F I=1:1:5 S TCTX("sorts",I,"isSel")=$S($G(SEL)=TCTX("sorts",I,"val"):1,1:0)
	Q
PEROPTS(TCTX,SEL)
	; Items-per-page dropdown list
	K TCTX("perOpts")
	N V,I
	S V(1)=12,V(2)=18,V(3)=24,V(4)=36,V(5)=48,V(6)=96
	F I=1:1:6 D
	. S TCTX("perOpts",I,"val")=V(I)
	. S TCTX("perOpts",I,"label")=V(I)_" / page"
	. S TCTX("perOpts",I,"isSel")=$S(+$G(SEL)=+V(I):1,1:0)
	Q
	;
	;
	;
SORTKEY(REC,SORT)
	N NM,GR,ID,FAV,CRE,UPD,HSEC,INV,KEY
	S ID=$G(REC("id"))
	S NM=$$LC($G(REC("name")))
	S GR=$$LC($G(REC("group")))
	S FAV=+$G(REC("fav"))
	S CRE=$G(REC("createdH")),UPD=$G(REC("updatedH"))
	;
	I SORT="name" Q NM_"|"_ID
	I SORT="group" Q GR_"|"_NM_"|"_ID
	I SORT="fav" Q $S(FAV=1:"0",1:"1")_"|"_NM_"|"_ID
	I SORT="created" D  Q KEY
	. S HSEC=$$H2S(CRE)
	. S INV=$$PAD((999999999999-HSEC),12)
	. S KEY=INV_"|"_NM_"|"_ID
	; default: updated desc
	S HSEC=$$H2S(UPD)
	S INV=$$PAD((999999999999-HSEC),12)
	Q INV_"|"_NM_"|"_ID
	;
MATCHQ(HAY,Q)
	; AND-match of tokens split on spaces.;
	N I,W,OK
	S OK=1
	F I=1:1:$L(Q," ") D  Q:'OK
	. S W=$$LC($P(Q," ",I))
	. I W="" Q
	. I HAY'[W S OK=0
	Q OK
	;
	;
	; -------------------------
	; Pagination helpers (ROI4.5)
	; -------------------------
BUILDPAR(PAR,OPT)
	; Build base query params from current OPT (filters + view + per). Omits cursor/page.;
	K PAR
	S PAR("q")=$G(OPT("q"))
	S PAR("group")=$G(OPT("group"))
	S PAR("tag")=$G(OPT("tag"))
	S PAR("sort")=$G(OPT("sort"))
	S PAR("fav")=$G(OPT("favOnly"))
	S PAR("view")=$G(OPT("view"))
	S PAR("per")=$G(OPT("per"))
	Q
	;
CURTOK(KEY,ID)
	; Cursor token uses a delimiter unlikely to occur in keys.;
	Q $G(KEY)_$C(30)_$G(ID)
	;
CURPAR(TOK,KEY,ID)
	; Parse cursor token into KEY/ID.;
	N D
	S D=$C(30)
	S KEY="",ID=""
	I $G(TOK)="" Q
	I TOK'[D Q
	S KEY=$P(TOK,D,1),ID=$P(TOK,D,2,999)
	Q
	;
HASAFTER(KEY,ID)
	; Is there at least one item after (KEY,ID) in the current sorted temp?
	N NID,NKEY
	I $G(KEY)="" Q 0
	S NID=$O(^TMP($J,"PLGD","sort",KEY,ID))
	I NID'="" Q 1
	S NKEY=$O(^TMP($J,"PLGD","sort",KEY))
	I NKEY'="" Q 1
	Q 0
	;
HASBEFORE(KEY,ID)
	; Is there at least one item before (KEY,ID) in the current sorted temp?
	N PID,PKEY
	I $G(KEY)="" Q 0
	S PID=$O(^TMP($J,"PLGD","sort",KEY,ID),-1)
	I PID'="" Q 1
	S PKEY=$O(^TMP($J,"PLGD","sort",KEY),-1)
	I PKEY'="" Q 1
	Q 0
	;
SCANPOS(KEY,ID)
	; Return 1-based position of (KEY,ID) within ^TMP($J,"PLGD","sort",...)
	; Used to compute page number/range even when navigating by cursor.;
	N K,DI,POS,FOUND
	S POS=0,FOUND=0
	S K=""
	F  S K=$O(^TMP($J,"PLGD","sort",K)) Q:K=""  D  Q:FOUND
	. S DI=""
	. F  S DI=$O(^TMP($J,"PLGD","sort",K,DI)) Q:DI=""  D  Q:FOUND
	. . S POS=POS+1
	. . I K=$G(KEY),DI=$G(ID) S FOUND=1 Q
	Q $S(FOUND:POS,1:0)
	;
	;
PAGERCTX(TCTX,OPT,MODE,PER,PAGE,OFF,TOTAL,TAKEN,FKEY,FID,LKEY,LID)
	; Populate TCTX("pager",...) including stable cursor Prev/Next URLs.;
	; ROI4.6: also compute page number + first/last/jump controls for cursor modes.;
	N PAR,STOK,ETOK,HPREV,HNEXT,PAGES,FROM,TO,POS,PG
	K TCTX("pager")
	S TCTX("pager","mode")=$G(MODE)
	S TCTX("pager","per")=+PER
	S TCTX("pager","total")=+TOTAL
	S TCTX("pager","count")=+TAKEN
	;
	; Total pages
	S PAGES=$S(+PER>0:((+TOTAL+PER-1)\PER),1:1)
	S TCTX("pager","pages")=PAGES
	I +TOTAL=0 S PAGES=0,TCTX("pager","pages")=0
	;
	; Determine 1-based FROM/TO range for the current window
	S FROM=0,TO=0,PG=1
	I +TOTAL=0 D
	. S FROM=0,TO=0,PG=0
	E  I $G(MODE)="offset" D
	. I +TAKEN>0 S FROM=(+OFF+1),TO=(+OFF+TAKEN)
	. E  S FROM=0,TO=0
	. S PG=$S(FROM>0:(((FROM-1)\PER)+1),1:+PAGE)
	E  D
	. ; cursor modes: compute position of first item by scanning sorted temp
	. I +TAKEN>0 S POS=$$SCANPOS($G(FKEY),$G(FID)) S FROM=POS,TO=(POS+TAKEN-1)
	. E  S FROM=0,TO=0
	. S PG=$S(FROM>0:(((FROM-1)\PER)+1),1:1)
	;
	S TCTX("pager","from")=FROM
	S TCTX("pager","to")=TO
	S TCTX("pager","page")=PG
	S TCTX("pager","hasRange")=$S(+$G(TOTAL)>0:1,1:0)
	I +$G(TOTAL)=0 S TCTX("pager","rangeText")="No results"
	E  S TCTX("pager","rangeText")="Showing "_FROM_"–"_TO_" of "_+TOTAL
	;
	; Cursor tokens from first/last items in current window
	S STOK=$S(($G(FKEY)="")!($G(FID)=""):"",1:$$CURTOK(FKEY,FID))
	S ETOK=$S(($G(LKEY)="")!($G(LID)=""):"",1:$$CURTOK(LKEY,LID))
	S HPREV=$S(STOK'="":$$HASBEFORE(FKEY,FID),1:0)
	S HNEXT=$S(ETOK'="":$$HASAFTER(LKEY,LID),1:0)
	S TCTX("pager","hasPrev")=HPREV
	S TCTX("pager","hasNext")=HNEXT
	;
	; Build stable cursor Prev/Next URLs (preserve filters/view/per; reset page)
	K PAR D BUILDPAR(.PAR,.OPT)
	I HPREV S PAR("before")=STOK
	S TCTX("pager","prevHref")=$S(HPREV:$$MKURL("/plgd",.PAR,0),1:"")
	K PAR D BUILDPAR(.PAR,.OPT)
	I HNEXT S PAR("after")=ETOK
	S TCTX("pager","nextHref")=$S(HNEXT:$$MKURL("/plgd",.PAR,0),1:"")
	;
	; First/Last links use page numbers (offset). These reset cursor.;
	S TCTX("pager","hasFirst")=$S(PG>1:1,1:0)
	S TCTX("pager","hasLast")=$S(PG<PAGES:1,1:0)
	K PAR D BUILDPAR(.PAR,.OPT) S PAR("page")=1
	S TCTX("pager","firstHref")=$$MKURL("/plgd",.PAR,0)
	K PAR D BUILDPAR(.PAR,.OPT) S PAR("page")=PAGES
	S TCTX("pager","lastHref")=$$MKURL("/plgd",.PAR,0)
	Q
	;
HASTAG2(TAGS,TAG)
	; True if TAG exists in TAGS list (case/spacing-insensitive)
	N ARR,KEY
	S KEY=$$TAGKEY($G(TAG))
	I KEY="" Q 0
	K ARR D PARSETAGS($G(TAGS),.ARR)
	Q $S($D(ARR(KEY)):1,1:0)
	;
GETMETA(ID,REC)
	; Metadata-only fetch (no template/json text). Good for large libraries.;
	K REC
	I $G(ID)="" Q
	I '$D(^MIO("PLGD","tpl",ID)) Q
	S REC("id")=ID
	S REC("name")=$G(^MIO("PLGD","tpl",ID,"name"))
	S REC("desc")=$G(^MIO("PLGD","tpl",ID,"desc"))
	S REC("group")=$G(^MIO("PLGD","tpl",ID,"group"))
	S REC("tags")=$G(^MIO("PLGD","tpl",ID,"tags"))
	S REC("fav")=+$G(^MIO("PLGD","tpl",ID,"fav"))
	S REC("createdH")=$G(^MIO("PLGD","tpl",ID,"createdH"))
	S REC("updatedH")=$G(^MIO("PLGD","tpl",ID,"updatedH"))
	Q
	;
	; -------------------------
	; Library storage helpers
	; -------------------------
GETREC(ID,REC)
	; Returns REC("tpl") and REC("json") as scalar strings.;
	K REC
	I ID="" Q
	I '$D(^MIO("PLGD","tpl",ID)) Q
	S REC("id")=ID
	S REC("name")=$G(^MIO("PLGD","tpl",ID,"name"))
	S REC("desc")=$G(^MIO("PLGD","tpl",ID,"desc"))
	S REC("group")=$G(^MIO("PLGD","tpl",ID,"group"))
	S REC("tags")=$G(^MIO("PLGD","tpl",ID,"tags"))
	S REC("fav")=+$G(^MIO("PLGD","tpl",ID,"fav"))
	S REC("createdH")=$G(^MIO("PLGD","tpl",ID,"createdH"))
	S REC("updatedH")=$G(^MIO("PLGD","tpl",ID,"updatedH"))
	N TT
	S TT="" D GETTEXT($NA(^MIO("PLGD","tpl",ID,"tpl")),.TT) S REC("tpl")=TT
	S TT="" D GETTEXT($NA(^MIO("PLGD","tpl",ID,"json")),.TT) S REC("json")=TT
	Q
	;
SAVEREC(REC)
	; Create/update. Returns ID.;
	N ID,OLDTAGS
	S ID=$G(REC("id"))
	I ID="" S ID=$$NEXTID()
	;
	S ^MIO("PLGD","tpl",ID,"name")=$G(REC("name"))
	S ^MIO("PLGD","tpl",ID,"desc")=$G(REC("desc"))
	S ^MIO("PLGD","tpl",ID,"group")=$G(REC("group"))
	S ^MIO("PLGD","tpl",ID,"fav")=+$G(REC("fav"))
	;
	; ROI4 tags + index maintenance
	S OLDTAGS=$G(^MIO("PLGD","tpl",ID,"tags"))
	S ^MIO("PLGD","tpl",ID,"tags")=$G(REC("tags"))
	D TAGIDXSET(ID,OLDTAGS,$G(REC("tags")))
	;
	I '$D(^MIO("PLGD","tpl",ID,"createdH")) S ^MIO("PLGD","tpl",ID,"createdH")=$H
	S ^MIO("PLGD","tpl",ID,"updatedH")=$H
	D SETTEXT($NA(^MIO("PLGD","tpl",ID,"tpl")),$G(REC("tpl")))
	D SETTEXT($NA(^MIO("PLGD","tpl",ID,"json")),$G(REC("json")))
	Q:$Q ID
	Q
	;
TAGIDXSET(ID,OLD,NEW)
	; Remove old tag index entries and add new ones
	N ARR,LBL,KEY
	I $G(ID)="" Q
	; remove
	I $G(OLD)'="" D
	. K ARR D PARSETAGS(OLD,.ARR)
	. S LBL=""
	. F  S LBL=$O(ARR(LBL)) Q:LBL=""  D
	. . S KEY=$$TAGKEY(LBL)
	. . K ^MIO("PLGD","idx","tag",KEY,ID)
	; add
	I $G(NEW)'="" D
	. K ARR D PARSETAGS(NEW,.ARR)
	. S LBL=""
	. F  S LBL=$O(ARR(LBL)) Q:LBL=""  D
	. . S KEY=$$TAGKEY(LBL)
	. . S ^MIO("PLGD","idx","tag",KEY,ID)=1
	Q
	;
	;
	; -------------------------
	; Versioning / rollback (library-grade)
	; -------------------------
NEXTREV(ID)
	; Next revision id for a template
	N X S X=+$G(^MIO("PLGD","tpl",ID,"revNext"))
	S X=X+1,^MIO("PLGD","tpl",ID,"revNext")=X
	Q X
	;
SAVEREV(ID,NOTE)
	; Save current state as a revision (before overwrite / rollback)
	N RID,REC,KEEP
	I $G(ID)="" Q
	I '$D(^MIO("PLGD","tpl",ID)) Q
	K REC D GETREC(ID,.REC) I '$D(REC) Q
	S RID=$$NEXTREV(ID)
	S ^MIO("PLGD","tpl",ID,"rev",RID,"savedH")=$H
	S ^MIO("PLGD","tpl",ID,"rev",RID,"note")=$G(NOTE)
	S ^MIO("PLGD","tpl",ID,"rev",RID,"name")=$G(REC("name"))
	S ^MIO("PLGD","tpl",ID,"rev",RID,"group")=$G(REC("group"))
	S ^MIO("PLGD","tpl",ID,"rev",RID,"tags")=$G(REC("tags"))
	S ^MIO("PLGD","tpl",ID,"rev",RID,"desc")=$G(REC("desc"))
	S ^MIO("PLGD","tpl",ID,"rev",RID,"fav")=+$G(REC("fav"))
	D SETTEXT($NA(^MIO("PLGD","tpl",ID,"rev",RID,"tpl")),$G(REC("tpl")))
	D SETTEXT($NA(^MIO("PLGD","tpl",ID,"rev",RID,"json")),$G(REC("json")))
	; cap revisions to last 50 (simple: drop RID-50)
	S KEEP=50
	I +RID>KEEP K ^MIO("PLGD","tpl",ID,"rev",(RID-KEEP))
	Q
	;
GETREV(ID,RID,REC)
	; Load a revision into REC, including tpl/json scalar
	K REC
	I $G(ID)="" Q
	I $G(RID)="" Q
	I '$D(^MIO("PLGD","tpl",ID,"rev",RID)) Q
	S REC("id")=ID
	S REC("name")=$G(^MIO("PLGD","tpl",ID,"rev",RID,"name"))
	S REC("group")=$G(^MIO("PLGD","tpl",ID,"rev",RID,"group"))
	S REC("tags")=$G(^MIO("PLGD","tpl",ID,"rev",RID,"tags"))
	S REC("desc")=$G(^MIO("PLGD","tpl",ID,"rev",RID,"desc"))
	S REC("fav")=+$G(^MIO("PLGD","tpl",ID,"rev",RID,"fav"))
	N TT
	S TT="" D GETTEXT($NA(^MIO("PLGD","tpl",ID,"rev",RID,"tpl")),.TT) S REC("tpl")=TT
	S TT="" D GETTEXT($NA(^MIO("PLGD","tpl",ID,"rev",RID,"json")),.TT) S REC("json")=TT
	Q
	;
NEXTID()
	N X S X=+$G(^MIO("PLGD","meta","nextId"))
	S X=X+1,^MIO("PLGD","meta","nextId")=X
	Q X
	;
FIRSTID()
	N ID S ID=$O(^MIO("PLGD","tpl",""))
	Q ID
	;
FAVCOUNT()
	N ID,C S (ID,C)=""
	S C=0,ID=""
	F  S ID=$O(^MIO("PLGD","tpl",ID)) Q:ID=""  I +$G(^MIO("PLGD","tpl",ID,"fav"))=1 S C=C+1
	Q C
	;
GETTEXT(ROOT,OUT)
	; ROOT points at a line-store root (e.g. $NA(^MIO(...,"tpl"))).;
	; OUT returns a single string with LF between lines.;
	N I,LINE
	S OUT=""
	I $G(ROOT)="" Q
	S I=0
	F  S I=$O(@ROOT@(I)) Q:'I  D
	. S LINE=$G(@ROOT@(I))
	. ; Preserve original lines; rejoin with LF
	. S OUT=OUT_LINE_$C(10)
	; Trim trailing LF (optional, but friendlier for editors)
	I $E(OUT,$L(OUT))=$C(10) S OUT=$E(OUT,1,$L(OUT)-1)
	Q
	;
SETTEXT(ROOT,TEXT)
	; Stores TEXT split by LF.;
	N I,N,LINE
	K @ROOT
	S N=$L($G(TEXT),$C(10))
	I N=0 Q
	F I=1:1:N D
	. S LINE=$P($G(TEXT),$C(10),I)
	. S @ROOT@(I)=LINE
	Q
	;
	; -------------------------
	; Seeding (built-in library)
	; -------------------------
INIT(CONF)
	; Seed only once (but still run maintenance)
	I $G(^MIO("PLGD","meta","seeded"))=1 D ENSUREIDX^MIOPLGD Q
	; start ids at 1000 so user-created ids are obvious
	S ^MIO("PLGD","meta","nextId")=1000
	;
	; Template 1: Welcome card
	N REC
	K REC
	S REC("name")="Welcome Card"
	S REC("group")="Basics"
	S REC("tags")="starter, card, basics"
	S REC("desc")="A tiny starter that demonstrates variables, sections, inverted sections, and dot-lookup."
	S REC("fav")=1
	S REC("tpl")="<h1>{{title}}</h1>"_$C(10)_"{{#user}}<p>Hi {{name}}.</p>{{/user}}"_$C(10)_"{{^user}}<p>No user provided.</p>{{/user}}"_$C(10)_"<ul>"_$C(10)_"{{#items}}<li>{{.}}</li>{{/items}}"_$C(10)_"{{^items}}<li>(empty)</li>{{/items}}"_$C(10)_"</ul>"
	S REC("json")="{""title"":""Hello, MIOPLGD!"",""user"":{""name"":""World""},""items"":[""one"",""two"",""three""]}"
	D SAVEREC(.REC)
	;
	; Template 2: Invoice
	K REC
	S REC("name")="Invoice (simple)"
	S REC("group")="Documents"
	S REC("tags")="invoice, billing, document"
	S REC("desc")="Invoice-style document with nested objects and totals."
	S REC("fav")=0
	S REC("tpl")="<h2>Invoice #{{invoice.number}}</h2>"_$C(10)_"<p><strong>Bill To:</strong> {{customer.name}}</p>"_$C(10)_"<table>"_$C(10)_"<tr><th>Item</th><th>Qty</th><th>Price</th></tr>"_$C(10)_"{{#lines}}<tr><td>{{name}}</td><td>{{qty}}</td><td>${{price}}</td></tr>{{/lines}}"_$C(10)_"</table>"_$C(10)_"<p><strong>Total:</strong> ${{invoice.total}}</p>"
	S REC("json")="{""invoice"":{""number"":""1007"",""total"":""128.75""},""customer"":{""name"":""Acme Co""},""lines"":[{""name"":""Widget"",""qty"":2,""price"":""24.99""},{""name"":""Service"",""qty"":1,""price"":""78.77""}]}"
	D SAVEREC(.REC)
	;
	; Template 3: Status dashboard
	K REC
	S REC("name")="Status Dashboard"
	S REC("group")="Dashboards"
	S REC("tags")="status, dashboard, ops"
	S REC("desc")="A dashboard block that lists services and uses conditional badges."
	S REC("fav")=1
	S REC("tpl")="<h2>Status</h2>"_$C(10)_"<ul>"_$C(10)_"{{#services}}<li>{{name}} - {{#ok}}OK{{/ok}}{{^ok}}DOWN{{/ok}}</li>{{/services}}"_$C(10)_"</ul>"
	S REC("json")="{""services"":[{""name"":""API"",""ok"":true},{""name"":""Auth"",""ok"":true},{""name"":""Billing"",""ok"":false}]}"
	D SAVEREC(.REC)
	;
	; Template 4: Email newsletter
	K REC
	S REC("name")="Email Newsletter"
	S REC("group")="Email"
	S REC("tags")="email, newsletter, marketing"
	S REC("desc")="Newsletter with sections and a hero."
	S REC("fav")=0
	S REC("tpl")="<h1>{{subject}}</h1>"_$C(10)_"<p>{{intro}}</p>"_$C(10)_"<h2>Highlights</h2>"_$C(10)_"<ul>{{#items}}<li><strong>{{title}}</strong>: {{desc}}</li>{{/items}}</ul>"_$C(10)_"{{#cta}}<p><a href=""{{url}}"">{{label}}</a></p>{{/cta}}"
	S REC("json")="{""subject"":""Weekly Update"",""intro"":""Here is what shipped."",""items"":[{""title"":""Faster renders"",""desc"":""Improved caching.""},{""title"":""New templates"",""desc"":""Added a library.""}],""cta"":{""url"":""https://example.com"",""label"":""Read more""}}"
	D SAVEREC(.REC)
	;
	; Template 5: Release notes
	K REC
	S REC("name")="Release Notes"
	S REC("group")="Product"
	S REC("tags")="release, changelog, product"
	S REC("desc")="Release notes grouped by version; demonstrates nested lists."
	S REC("fav")=0
	S REC("tpl")="<h2>Release {{version}}</h2>"_$C(10)_"{{#sections}}<h3>{{title}}</h3><ul>{{#items}}<li>{{.}}</li>{{/items}}</ul>{{/sections}}"
	S REC("json")="{""version"":""1.2.0"",""sections"":[{""title"":""Added"",""items"":[""Template search"",""Export/import""]},{""title"":""Fixed"",""items"":[""Edge-case rendering""]}]}"
	D SAVEREC(.REC)
	;
	; Template 6: Bug report
	K REC
	S REC("name")="Bug Report"
	S REC("group")="Ops"
	S REC("tags")="bug, incident, ops"
	S REC("desc")="Bug report template with optional reproduction steps."
	S REC("fav")=0
	S REC("tpl")="<h2>Bug: {{title}}</h2>"_$C(10)_"<p><strong>Severity:</strong> {{severity}}</p>"_$C(10)_"<p>{{summary}}</p>"_$C(10)_"{{#steps}}<h3>Steps</h3><ol>{{#steps}}<li>{{.}}</li>{{/steps}}</ol>{{/steps}}"_$C(10)_"{{^steps}}<p>No steps provided.</p>{{/steps}}"
	S REC("json")="{""title"":""Save button unresponsive"",""severity"":""High"",""summary"":""Clicking save does nothing."",""steps"":[""Open playground"",""Edit template"",""Click Save""]}"
	D SAVEREC(.REC)
	;
	; Template 7: Onboarding checklist
	K REC
	S REC("name")="Onboarding Checklist"
	S REC("group")="Process"
	S REC("tags")="onboarding, checklist, process"
	S REC("desc")="Checklist with done/undone items."
	S REC("fav")=0
	S REC("tpl")="<h2>{{title}}</h2>"_$C(10)_"<ul>{{#tasks}}<li>{{#done}}[x]{{/done}}{{^done}}[ ]{{/done}} {{name}}</li>{{/tasks}}</ul>"
	S REC("json")="{""title"":""First Day"",""tasks"":[{""name"":""Get laptop access"",""done"":true},{""name"":""Join Slack"",""done"":false},{""name"":""Read handbook"",""done"":false}]}"
	D SAVEREC(.REC)
	;
	; Mark seeded
	S ^MIO("PLGD","meta","seeded")=1
	D ENSUREIDX^MIOPLGD
	Q
	;
ENSUREIDX
	; ROI4 maintenance: build tag index once for existing libraries.;
	; Safe to run on every request: it exits if already built.;
	I $G(^MIO("PLGD","meta","tagIndexBuilt"))=1 Q
	K ^MIO("PLGD","idx","tag")
	N ID,TAGS,ARR,LBL,KEY
	S ID=""
	F  S ID=$O(^MIO("PLGD","tpl",ID)) Q:ID=""  D
	. S TAGS=$G(^MIO("PLGD","tpl",ID,"tags")) Q:TAGS=""
	. K ARR D PARSETAGS(TAGS,.ARR)
	. S LBL=""
	. F  S LBL=$O(ARR(LBL)) Q:LBL=""  D
	. . S KEY=$$TAGKEY(LBL)
	. . S ^MIO("PLGD","idx","tag",KEY,ID)=1
	S ^MIO("PLGD","meta","tagIndexBuilt")=1
	Q
	;
	;
	; -------------------------
	; Parsing + JSON + safety
	; -------------------------
PARSEBODY(BODY,POST,OBJ)
	; Try form decode; if not, try JSON decode.;
	; POST and OBJ are optional outputs.;
	K POST,OBJ
	N TRIM
	S TRIM=$$TRIM($G(BODY))
	I TRIM="" Q
	I $E(TRIM,1)="{" D  Q
	. D TRYJSON(TRIM,.OBJ,.POST) ; store json errors in POST if needed
	;
	; Form decode (x-www-form-urlencoded)
	I $T(DECODEFORM^MIOFNC)'="" D  Q
	. D DECODEFORM^MIOFNC($G(BODY),.POST)
	;
	; Minimal fallback parser for key=value&... (with percent-decode)
	D QSDECODE($G(BODY),.POST)
	Q
	;
TRYJSON(JSON,OUT,ERR)
	; OUT is a local array; ERR is a local array for errors (optional)
	K OUT
	N $ETRAP,$ESTACK
	S $ETRAP="D JSONTRAP^MIOPLGD(.ERR) Q"
	D DECODE^MIOJSON($G(JSON),.OUT)
	S $ETRAP=""
	Q
JSONTRAP(ERR)
	; Trap any JSON parser errors
	S ERR("json")=1
	S ERR("zstatus")=$ZSTATUS
	S $ECODE=""
	Q
	;
STRIPLAMR(ARR)
	; Remove any scalar values beginning with "$$" anywhere in ARR.;
	N ROOT,REF,VAL
	S ROOT=$NA(ARR)
	S REF=ROOT
	F  S REF=$Q(@REF) Q:REF=""  Q:$E(REF,1,$L(ROOT))'=ROOT  D
	. I $D(@REF)#2 D
	. . S VAL=$G(@REF)
	. . I $E(VAL,1,2)="$$" S @REF=""
	Q
	;
HASTAG(TEXT,PAT)
	Q $S($F($G(TEXT),PAT)>0:1,1:0)
	;
TRIM(X)
	N Y S Y=$G(X)
	; left trim
	F  Q:$E(Y,1)'=" "  S Y=$E(Y,2,$L(Y))
	; right trim
	F  Q:$E(Y,$L(Y))'=" "  S Y=$E(Y,1,$L(Y)-1)
	Q Y
	;
LC(X)
	Q $TR($G(X),"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")
	;
QSVAL(REQ,KEY,DEF)
	; Gets querystring value for KEY from REQ.;
	; Supports REQ("query",KEY) if present; otherwise parses REQ("uri") or REQ("path").;
	N V,URI,QS,MAP
	S V=$G(REQ("query",KEY))
	I V'="" Q V
	S URI=$G(REQ("uri")) I URI="" S URI=$G(REQ("path"))
	S QS=$P(URI,"?",2,999)
	I QS="" Q $G(DEF)
	K MAP D QSDECODE(QS,.MAP)
	S V=$G(MAP(KEY)) I V="" Q $G(DEF)
	Q V
	;
QSDECODE(QS,OUT)
	; Minimal query/form decoder for key=value&... supporting + for space and %HH.;
	K OUT
	N I,PAIR,K,V,N
	S QS=$G(QS)
	I QS="" Q
	S N=$L(QS,"&")
	F I=1:1:N D
	. S PAIR=$P(QS,"&",I)
	. S K=$P(PAIR,"=",1),V=$P(PAIR,"=",2,999)
	. S K=$$URLDEC(K),V=$$URLDEC(V)
	. I K'="" S OUT(K)=V
	Q
	;
URLDEC(X)
	; Decode '+' and %HH
	N OUT,I,C,HEX
	S OUT=""
	S X=$G(X)
	F I=1:1:$L(X) D
	. S C=$E(X,I)
	. I C="+" S OUT=OUT_" " Q
	. I C="%",I+2'>$L(X) S OUT=OUT_C Q
	. I C="%" D  Q
	. . S HEX=$E(X,I+1,I+2)
	. . I $$ISHEX(HEX) S OUT=OUT_$C($$H2D(HEX)),I=I+2 Q
	. . S OUT=OUT_"%" ; invalid; keep
	. S OUT=OUT_C
	Q OUT
	;
URLESC(X)
	; URL-escape for query params (space -> +)
	N OUT,I,C,ASC
	S OUT="",X=$G(X)
	F I=1:1:$L(X) D
	. S C=$E(X,I)
	. I C?1AN!(C="-")!(C="_")!(C=".")!(C="~") S OUT=OUT_C Q
	. I C=" " S OUT=OUT_"+" Q
	. S ASC=$A(C)
	. S OUT=OUT_"%"_$$D2H(ASC)
	Q OUT
	;
D2H(N)
	; decimal 0..255 to 2-digit hex
	N HI,LO
	S HI=N\16,LO=N#16
	Q $$H1R(HI)_$$H1R(LO)
H1R(N)
	I N<10 Q N
	Q $E("ABCDEF",N-9)
	;
MKURL(PATH,PAR,KEEPDEF)
	; Build URL with query params (PAR array). If KEEPDEF=0, omit empty params.;
	N K,QS,SEP,V
	S QS="",SEP="?"
	S K=""
	F  S K=$O(PAR(K)) Q:K=""  D
	. S V=$G(PAR(K))
	. I 'KEEPDEF,V="" Q
	. I QS'="" S SEP="&"
	. S QS=QS_SEP_$$URLESC(K)_"="_$$URLESC(V)
	I QS="" Q PATH
	Q PATH_QS
	;
ISHEX(H)
	N A,B
	S A=$E($G(H),1),B=$E($G(H),2)
	Q $$ISHEX1(A)&$$ISHEX1(B)
ISHEX1(C)
	I C?1N Q 1
	I C?1U Q 1
	I C?1L Q 1
	Q 0
H2D(H)
	; hex to decimal (00-FF)
	N A,B
	S A=$$H1($E(H,1)),B=$$H1($E(H,2))
	Q (A*16)+B
H1(C)
	N X S C=$TR(C,"abcdef","ABCDEF")
	I C?1N Q C
	I C="A" Q 10
	I C="B" Q 11
	I C="C" Q 12
	I C="D" Q 13
	I C="E" Q 14
	I C="F" Q 15
	Q 0
	;
H2S(H)
	; $H -> seconds since day 0 (for sorting only)
	N D,S
	I $G(H)="" Q 0
	S D=+$P(H,",",1),S=+$P(H,",",2)
	Q (D*86400)+S
	;
PAD(N,LEN)
	; zero-pad N to LEN digits (positive)
	N S
	S S=+$G(N)
	S S=$TR(S,"-","")
	S S=$J(S,LEN)
	S S=$TR(S," ","0")
	Q S
	;
AGO(H)
	; Pretty relative time from $H value: "5m ago", "2h ago", "3d ago"
	N NOW,DS,SEC
	S NOW=$H
	S SEC=$$H2S(NOW)-$$H2S($G(H))
	I SEC<0 S SEC=0
	I SEC<60 Q "Just now"
	I SEC<3600 Q (SEC\60)_"m ago"
	I SEC<86400 Q (SEC\3600)_"h ago"
	Q (SEC\86400)_"d ago"
	;
	; -------------------------
	; Tags
	; -------------------------
SANITAGS(T)
	; Keep tags as a comma-separated list of simple tokens; normalize spacing.;
	N OUT,I,N,RAW,LBL,ARR
	S T=$G(T)
	S T=$TR(T,$C(9),",")
	S T=$TR(T,";"," ,")
	S T=$TR(T,"|"," ,")
	S T=$TR(T,"/"," ")
	S T=$TR(T,"\\"," ")
	; Split on commas, then trim, keep token chars only
	K ARR
	N P,SEG
	S N=$L(T,",")
	F I=1:1:N D
	. S SEG=$$TRIM($P(T,",",I))
	. I SEG="" Q
	. S SEG=$$TAGCLEAN(SEG)
	. I SEG'="" S ARR(SEG)=1
	; Rejoin in alpha order
	S OUT="",LBL=""
	F  S LBL=$O(ARR(LBL)) Q:LBL=""  D
	. I OUT'="" S OUT=OUT_", "
	. S OUT=OUT_LBL
	Q OUT
	;
TAGCLEAN(X)
	; Tag token cleanup: letters, numbers, dash, underscore, dot
	N Y,I,C
	S Y=""
	F I=1:1:$L($G(X)) D
	. S C=$E(X,I)
	. I C?1AN!(C="-")!(C="_")!(C=".") S Y=Y_C
	Q $$LC(Y)
	;
TAGKEY(LBL)
	Q $$TAGCLEAN($G(LBL))
	;
PARSETAGS(T,ARR)
	; Output ARR(label)=1 (labels are lowercase clean tokens)
	K ARR
	N I,N,SEG
	S T=$G(T)
	S N=$L(T,",")
	F I=1:1:N D
	. S SEG=$$TRIM($P(T,",",I))
	. S SEG=$$TAGCLEAN(SEG)
	. I SEG'="" S ARR(SEG)=1
	Q
	;
	; -------------------------
	; Export / Import
	; -------------------------
EXPORTJSON()
	; Returns {"templates":[...]}
	N ID,N,REC,JSON
	S JSON="{""templates"":["
	S ID="",N=0
	F  S ID=$O(^MIO("PLGD","tpl",ID)) Q:ID=""  D
	. K REC D GETMETA(ID,.REC) Q:'$D(REC)
	. S N=N+1
	. I N>1 S JSON=JSON_","
	. S JSON=JSON_$$REC2JSON(.REC)
	S JSON=JSON_"]}"
	Q JSON
	;
REC2JSON(REC)
	; NOTE: minimal JSON escaping.;
	N S
	S S="{"
	S S=S_"""id"":"""_$$JESC($G(REC("id")))_""","
	S S=S_"""name"":"""_$$JESC($G(REC("name")))_""","
	S S=S_"""group"":"""_$$JESC($G(REC("group")))_""","
	S S=S_"""tags"":"""_$$JESC($G(REC("tags")))_""","
	S S=S_"""desc"":"""_$$JESC($G(REC("desc")))_""","
	S S=S_"""fav"":"_+$G(REC("fav"))_","
	S S=S_"""template"":"""_$$JESC($G(REC("tpl")))_""","
	S S=S_"""json"":"""_$$JESC($G(REC("json")))_""""
	S S=S_"}"
	Q S
	;
JESC(X)
	; Escape for JSON strings: backslash, quotes, and LF/CR/TAB.;
	N Y S Y=$G(X)
	S Y=$TR(Y,$C(9),"\t")
	S Y=$TR(Y,$C(13),"\r")
	S Y=$TR(Y,$C(10),"\n")
	S Y=$$REPL(Y,"\","\\")
	S Y=$$REPL(Y,"""","\""")
	Q Y
REPL(S,FR,TO)
	; Replace all occurrences of FR with TO
	N OUT,P,L
	S OUT="",L=$L(S,FR)
	I L=1 Q S
	F P=1:1:L-1 S OUT=OUT_$P(S,FR,P)_TO
	S OUT=OUT_$P(S,FR,L)
	Q OUT
	;
IMPORT(OBJ,ERR)
	; OBJ("templates",n,...) produced by JSON decode.;
	N N,REC
	S N=0
	F  S N=$O(OBJ("templates",N)) Q:'N  D
	. K REC
	. S REC("id")=$G(OBJ("templates",N,"id"))
	. S REC("name")=$G(OBJ("templates",N,"name"))
	. S REC("group")=$G(OBJ("templates",N,"group"))
	. S REC("tags")=$G(OBJ("templates",N,"tags"))
	. S REC("desc")=$G(OBJ("templates",N,"desc"))
	. S REC("fav")=+$G(OBJ("templates",N,"fav"))
	. S REC("tpl")=$G(OBJ("templates",N,"template"))
	. S REC("json")=$G(OBJ("templates",N,"json"))
	. I $$TRIM(REC("name"))="" Q
	. S REC("tags")=$$SANITAGS($G(REC("tags")))
	. D SAVEREC(.REC)
	Q
	;
	;
	; -------------------------
	; Error formatting
	; -------------------------
ERR2TXT(ERR)
	; Build a compact, readable diagnostics string from an error array.;
	; Keeps output small and safe for JSON transport.;
	N S,K,K2,LINE
	S S=""
	S K=""
	F  S K=$O(ERR(K)) Q:K=""  D
	. I $D(ERR(K))#2 D  Q
	. . S LINE=K_": "_$G(ERR(K))
	. . S S=S_LINE_$C(10)
	. S K2=""
	. F  S K2=$O(ERR(K,K2)) Q:K2=""  D
	. . S LINE=K_"("_K2_")"_": "_$G(ERR(K,K2))
	. . S S=S_LINE_$C(10)
	; trim trailing LF
	I $E(S,$L(S))=$C(10) S S=$E(S,1,$L(S)-1)
	Q S
	;
	;
	; -------------------------
	; HTTP helpers
	; -------------------------
RESPHTML(DEV,CONF,CTX,OUT)
	N HEAD S HEAD("Content-Type")="text/html; charset=utf-8"
	D RESP^MIOHTTP(DEV,.CONF,200,.HEAD,.OUT,$G(CTX("request_id")))
	Q
	;
RESPTXT(DEV,CONF,CTX,OUT)
	N HEAD S HEAD("Content-Type")="text/plain; charset=utf-8"
	D RESP^MIOHTTP(DEV,.CONF,200,.HEAD,.OUT,$G(CTX("request_id")))
	Q
	;
RESPJSON(DEV,CONF,CTX,STATUS,JSON)
	N HEAD S HEAD("Content-Type")="application/json"
	D RESP^MIOHTTP(DEV,.CONF,.STATUS,.HEAD,.JSON,$G(CTX("request_id")))
	Q
	;
RESPERR(DEV,CONF,CTX,STATUS,CODE,DETAIL)
	N J,DET
	S J="{""ok"":false,""error"":"""_$G(CODE)_""""
	S DET=$G(DETAIL)
	I DET'="" S J=J_",""detail"":"""_$$JESC(DET)_""""
	S J=J_"}"
	D RESPJSON(DEV,.CONF,.CTX,STATUS,J)
	Q
	;
	;