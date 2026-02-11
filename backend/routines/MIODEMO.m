MIODEMO ; Demo routes for quick validation.;
; API STABILITY
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; Purpose
; Demo routes for quick validation.;
;
; Responsibilities
; - Provide reference endpoints.;
; - Demonstrate best practices.;
; - Emit events for WebSocket clients.;
;
; Entry Points
; - REG
; - HELLO
; - PHI
; - PAGE
;
; Notes
; Keep comments short.;
; Do not log secrets.;
;
	;
; Entry point
; See docs/routines for details.;
REG(CONF) ; DO REG^MIODEMO(.CONF)
	NEW EN S EN=$S($GET(CONF("examples","enabled"))="true":1,1:+$GET(CONF("examples","enabled")))
	IF 'EN QUIT
	DO ADD^MIOROUTE("GET","/v1/demo/hello","HELLO^MIODEMO")
	DO ADD^MIOROUTE("GET","/v1/demo/phi/:id","PHI^MIODEMO")
	DO ADD^MIOROUTE("GET","/v1/demo/page","PAGE^MIODEMO")
	QUIT
	;
; Entry point
; See docs/routines for details.;
HELLO(DEV,CONF,REQ,CTX)
	DO JSON^MIOERR(DEV,.CONF,200,"ok","hello from demo",.CTX)
	QUIT
	;
; Entry point
; See docs/routines for details.;
PHI(DEV,CONF,REQ,CTX)
	SET CTX("phi")=1
	SET CTX("auditAction")="DEMO_PHI_READ"
	NEW ID S ID=$GET(REQ("params","id"))
	NEW BODY S BODY="{""resource_id"":"""_$$ESC^MIOUTIL(ID)_""",""note"":""demo only""}"
	DO RESPJSON^MIOHTTP(DEV,.CONF,200,.CTX,BODY)
	QUIT
	;
	;
; Entry point
; See docs/routines for details.;
PAGE(DEV,CONF,REQ,CTX)
	NEW TCTX KILL TCTX
	SET TCTX("title")="MWS Template Demo"
	SET TCTX("user")=$GET(REQ("query","user")) IF TCTX("user")="" SET TCTX("user")="guest"
	SET TCTX("items",1)="fast"
	SET TCTX("items",2)="stable"
	SET TCTX("items",3)="mumps-native"
	NEW OUT,ERR
	IF '$$RENDER^MIOTPL("page.html",.CONF,.TCTX,.OUT,.ERR) DO  QUIT
	. DO RESPJSON^MIOHTTP(DEV,500,.CTX,"{""error"":""template_error"",""detail"":"""_ERR_"""}")
	NEW BODY,I,HEAD  S BODY="",I=0
	FOR  SET I=$ORDER(OUT(I)) QUIT:I=""  SET BODY=BODY_OUT(I)
	S HEAD("Content-Type")="text/html; charset=utf-8"
	DO RESP^MIOHTTP(DEV,.CONF,200,.HEAD,.BODY,CTX("request_id"))
	QUIT