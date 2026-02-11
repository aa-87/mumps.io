MIOAPP ; Reference app. CRUD API, UI routes, and event publishing.;
; API STABILITY
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; Purpose
; Reference app. CRUD API, UI routes, and event publishing.;
;
; Responsibilities
; - Provide reference endpoints.;
; - Demonstrate best practices.;
; - Emit events for WebSocket clients.;
;
; Entry Points
; - REG
; - PAGE
; - NEXTID
; - NOWISO
; - BCAST
; - LIST
; - CREATE
; - GETONE
; - UPDATE
; - DEL
; - RESPJSONT
; - BUILD
; - SAVE
; - LOAD
; - GETSDB
; - GETS
; - GETB
; - SETS
; - SETN
; - SETB
;
; Globals Used
; - ^MIO("APP",...)
;
; Notes
; Keep comments short.;
; Do not log secrets.;
;
	;
	; This reference app demonstrates:
	;  - HTML page rendered via MIOTPL (layout + blocks)
	;  - JSON REST API using MIOJSON / MIOJSON1
	;  - Simple persistent storage in ^MIO("APP",...)
	;  - WebSocket broadcast stream (/ws/app) using global message queue
	;
; Entry point
; See docs/routines for details.;
REG(CONF) ; DO REG^MIOAPP(.CONF)
	NEW EN SET EN=$S($GET(CONF("referenceApp","enabled"))="true":1,1:+$GET(CONF("referenceApp","enabled")))
	IF EN'=1 QUIT
	NEW META
	; UI page is public
	DO ADD^MIOROUTE("GET","/app","PAGE^MIOAPP")
	; API routes require auth + role user (example)
	SET META("authRequired")=1,META("roles")="user,admin"
	DO ADDM^MIOROUTE("GET","/api/items","LIST^MIOAPP",.META)
	DO ADDM^MIOROUTE("POST","/api/items","CREATE^MIOAPP",.META)
	DO ADDM^MIOROUTE("GET","/api/items/:id","GETONE^MIOAPP",.META)
	DO ADDM^MIOROUTE("PUT","/api/items/:id","UPDATE^MIOAPP",.META)
	DO ADDM^MIOROUTE("DELETE","/api/items/:id","DELONE^MIOAPP",.META)
	; WebSocket app stream requires auth
	KILL META SET META("authRequired")=1,META("roles")="user,admin"
	DO ADDWSM^MIOROUTE("/ws/app","ACCEPT^MIOAPPWS",.META)
	QUIT
	;
; Entry point
; See docs/routines for details.;
PAGE(DEV,CONF,REQ,CTX)
	NEW QUSER SET QUSER=$GET(REQ("query","user")) IF QUSER="" SET QUSER="Guest"
	NEW DATA
	SET DATA("user")=QUSER
	SET DATA("title")="MIO Reference App"
	; render page into layout
	NEW OUT,ERR
	IF '$$RENDERPAGE^MIOTPL("app_index.html","app_layout.html",.CONF,.DATA,.OUT,.ERR) DO  QUIT
	. DO JSON^MIOERR(DEV,CONF,CONF,500,"template_error",$GET(ERR("error")),.CTX)
	NEW HEAD SET HEAD("Content-Type")="text/html; charset=utf-8"
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,OUT,$GET(CTX("request_id")),.CTX)
	QUIT
	;
; ---- Storage helpers ----
NEXTID()
	NEW ID
	LOCK +^MIO("APP","SEQ"):2 ELSE  QUIT 0
	SET ID=$INCREMENT(^MIO("APP","SEQ"))
	LOCK -^MIO("APP","SEQ")
	QUIT ID
	;
; Entry point
; See docs/routines for details.;
NOWISO()
	QUIT $$NOWISO^MIOUTIL()
	;
; Entry point
; See docs/routines for details.;
BCAST(MSG)
	; Append a broadcast message string (JSON) into global queue
	NEW N SET N=$INCREMENT(^MIO("APP","BCAST","SEQ"))
	SET ^MIO("APP","BCAST",N)=MSG
	; optional bounded retention (keep last 10k)
	IF N>10000 KILL ^MIO("APP","BCAST",N-10000)
	QUIT
	;
; ---- API ----
LIST(DEV,CONF,REQ,CTX)
	NEW ARR,ID
	SET ARR("type")="array"
	NEW I SET I=0
	SET ID=0
	FOR  SET ID=$ORDER(^MIO("APP","ITEM",ID)) QUIT:ID=""  DO
	. NEW OBJ DO LOAD(ID,.OBJ)
	. SET I=I+1 MERGE ARR("value",I)=OBJ
	DO RESPJSONT(DEV,CONF,200,.ARR,.CTX)
	QUIT
	;
; Entry point
; See docs/routines for details.;
CREATE(DEV,CONF,REQ,CTX)
	NEW TREE,ERR
	IF '$$DECODET^MIOJSON($GET(REQ("body")),.TREE,.ERR) DO  QUIT
	. DO JSON^MIOERR(DEV,CONF,CONF,400,"bad_json",$GET(ERR("error")),.CTX)
	NEW ID SET ID=$$NEXTID() IF ID=0 DO JSON^MIOERR(DEV,CONF,CONF,503,"busy","try again",.CTX) QUIT
	NEW ITEM DO BUILD(ID,.TREE,.ITEM,1)
	DO SAVE(ID,.ITEM)
	; broadcast create
	NEW MSG SET MSG=$$EVENT("created",ID,.ITEM)
	DO BCAST(MSG)
	DO RESPJSONT(DEV,CONF,201,.ITEM,.CTX)
	QUIT
	;
; Entry point
; See docs/routines for details.;
GETONE(DEV,CONF,REQ,CTX)
	NEW ID SET ID=+$GET(REQ("params","id"))
	IF ID<1!'$DATA(^MIO("APP","ITEM",ID)) DO JSON^MIOERR(DEV,CONF,CONF,404,"not_found","item not found",.CTX) QUIT
	NEW ITEM DO LOAD(ID,.ITEM)
	DO RESPJSONT(DEV,CONF,200,.ITEM,.CTX)
	QUIT
	;
; Entry point
; See docs/routines for details.;
UPDATE(DEV,CONF,REQ,CTX)
	NEW ID SET ID=+$GET(REQ("params","id"))
	IF ID<1!'$DATA(^MIO("APP","ITEM",ID)) DO JSON^MIOERR(DEV,CONF,CONF,404,"not_found","item not found",.CTX) QUIT
	NEW TREE,ERR
	IF '$$DECODET^MIOJSON($GET(REQ("body")),.TREE,.ERR) DO  QUIT
	. DO JSON^MIOERR(DEV,CONF,CONF,400,"bad_json",$GET(ERR("error")),.CTX)
	NEW ITEM DO BUILD(ID,.TREE,.ITEM,0)
	DO SAVE(ID,.ITEM)
	NEW MSG SET MSG=$$EVENT("updated",ID,.ITEM)
	DO BCAST(MSG)
	DO RESPJSONT(DEV,CONF,200,.ITEM,.CTX)
	QUIT
	;
; Entry point
; See docs/routines for details.;
DEL(DEV,CONF,REQ,CTX)
	NEW ID SET ID=+$GET(REQ("params","id"))
	IF ID<1!'$DATA(^MIO("APP","ITEM",ID)) DO JSON^MIOERR(DEV,CONF,CONF,404,"not_found","item not found",.CTX) QUIT
	NEW ITEM DO LOAD(ID,.ITEM)
	KILL ^MIO("APP","ITEM",ID)
	NEW MSG SET MSG=$$EVENT("deleted",ID,.ITEM)
	DO BCAST(MSG)
	NEW OBJ SET OBJ("type")="object",OBJ("value","ok","type")="bool",OBJ("value","ok","value")=1
	DO RESPJSONT(DEV,CONF,200,.OBJ,.CTX)
	QUIT
	;
; ---- Typed JSON helpers ----
RESPJSONT(DEV,CONF,STATUS,TREE,CTX)
	NEW BODY SET BODY=$$ENT^MIOJSON1(.TREE)
	NEW HEAD SET HEAD("Content-Type")="application/json; charset=utf-8"
	DO RESPX^MIOHTTP(.DEV,.CONF,STATUS,.HEAD,BODY,$GET(CTX("request_id")),.CTX)
	QUIT
	;
; Entry point
; See docs/routines for details.;
BUILD(ID,TREE,OUT,ISNEW)
	; Build typed object OUT from input TREE (typed object)
	NEW T SET T=$GET(TREE("type"))
	NEW TITLE,NOTE,PHI
	SET TITLE=$$GETS(.TREE,"title","")
	SET NOTE=$$GETS(.TREE,"note","")
	SET PHI=$$GETB(.TREE,"phi",0)
	SET OUT("type")="object"
	DO SETN(.OUT,"id",ID)
	DO SETS(.OUT,"title",TITLE)
	DO SETS(.OUT,"note",NOTE)
	DO SETB(.OUT,"phi",PHI)
	IF ISNEW DO SETS(.OUT,"createdAt",$$NOWISO())
	ELSE  DO SETS(.OUT,"createdAt",$$GETSDB(ID,"createdAt",""))
	DO SETS(.OUT,"updatedAt",$$NOWISO())
	QUIT
	;
; Entry point
; See docs/routines for details.;
SAVE(ID,ITEM)
	; Store minimal fields for retrieval
	SET ^MIO("APP","ITEM",ID,"title")=$$GETS(.ITEM,"title","")
	SET ^MIO("APP","ITEM",ID,"note")=$$GETS(.ITEM,"note","")
	SET ^MIO("APP","ITEM",ID,"phi")=$$GETB(.ITEM,"phi",0)
	SET ^MIO("APP","ITEM",ID,"createdAt")=$$GETS(.ITEM,"createdAt","")
	SET ^MIO("APP","ITEM",ID,"updatedAt")=$$GETS(.ITEM,"updatedAt","")
	QUIT
	;
; Entry point
; See docs/routines for details.;
LOAD(ID,OUT)
	SET OUT("type")="object"
	DO SETN(.OUT,"id",ID)
	DO SETS(.OUT,"title",$GET(^MIO("APP","ITEM",ID,"title")))
	DO SETS(.OUT,"note",$GET(^MIO("APP","ITEM",ID,"note")))
	DO SETB(.OUT,"phi",+$GET(^MIO("APP","ITEM",ID,"phi")))
	DO SETS(.OUT,"createdAt",$GET(^MIO("APP","ITEM",ID,"createdAt")))
	DO SETS(.OUT,"updatedAt",$GET(^MIO("APP","ITEM",ID,"updatedAt")))
	QUIT
	;
; Entry point
; See docs/routines for details.;
GETSDB(ID,KEY,DEF)
	NEW V SET V=$GET(^MIO("APP","ITEM",ID,KEY))
	IF V="" QUIT DEF
	QUIT V
	;
; typed getters/setters
GETS(TREE,KEY,DEF)
	NEW N SET N=$GET(TREE("value",KEY,"type"))
	IF N'="string" QUIT DEF
	QUIT $GET(TREE("value",KEY,"value"))
; Entry point
; See docs/routines for details.;
GETB(TREE,KEY,DEF)
	NEW N SET N=$GET(TREE("value",KEY,"type"))
	IF N'="bool" QUIT DEF
	QUIT +$GET(TREE("value",KEY,"value"))
; Entry point
; See docs/routines for details.;
SETS(OBJ,KEY,VAL)
	SET OBJ("value",KEY,"type")="string",OBJ("value",KEY,"value")=VAL QUIT
; Entry point
; See docs/routines for details.;
SETN(OBJ,KEY,VAL)
	SET OBJ("value",KEY,"type")="number",OBJ("value",KEY,"value")=VAL QUIT
; Entry point
; See docs/routines for details.;
SETB(OBJ,KEY,VAL)
	SET OBJ("value",KEY,"type")="bool",OBJ("value",KEY,"value")=$SELECT(+VAL:1,1:0) QUIT
	;
; Entry point
; See docs/routines for details.;
EVENT(TYPE,ID,ITEM)
	NEW EV SET EV("type")="object"
	DO SETS(.EV,"event",TYPE)
	DO SETN(.EV,"id",ID)
	SET EV("value","item")=$GET(ITEM("type"))  ; ensure node exists
	MERGE EV("value","item")=ITEM
	QUIT $$ENT^MIOJSON1(.EV)
	;
; Entry point
; See docs/routines for details.;
WSAPP(DEV,CONF,REQ,CTX)
	; Hand off to reference-app WebSocket loop (broadcast + echo)
	DO ACCEPT^MIOAPPWS(.DEV,.CONF,.REQ,.CTX)
	QUIT
	;
	;