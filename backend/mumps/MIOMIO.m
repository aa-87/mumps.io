MIOMIO ; MUMPS.IO landing page routes.
; API STABILITY
; Public API labels are documented in docs/routines.
; Undocumented labels are internal.
;
; PURPOSE
; Serve the MUMPS.IO marketing landing page.
; Provide a professional landing page using MIOTPL layouts and partials.
;
; RESPONSIBILITIES
; Register landing page routes.
; Render templates with layout and blocks.
;
; PUBLIC ENTRY POINTS
; REG   - Register routes.
; HOME  - GET /
;
; GLOBALS USED
; None.
;
; NOTES
; This routine is safe for production.
; It does not execute code from templates.
; It renders templates with escaping by default.

REG(CONF) ;
 ; Register MUMPS.IO site routes.
 ; This should be called during startup before COMPILE^MIOROUTE.
 DO ADD^MIOROUTE("GET","/","HOME^MIOMIO")
 DO ADD^MIOROUTE("GET","/community","COMM^MIOMIO")
 DO ADD^MIOROUTE("GET","/pro","PRO^MIOMIO")
 DO ADD^MIOROUTE("GET","/enterprise","ENT^MIOMIO")
 DO ADD^MIOROUTE("GET","/docs","DOCS^MIOMIO")
 DO ADD^MIOROUTE("GET","/security","SEC^MIOMIO")
 DO ADD^MIOROUTE("GET","/status","STATUS^MIOMIO")
 DO ADD^MIOROUTE("GET","/terms","TERMS^MIOMIO")
 DO ADD^MIOROUTE("GET","/privacy","PRIV^MIOMIO")
 QUIT

HOME(DEV,CONF,REQ,CTX) ;
 ; Render the MUMPS.IO landing page.
 NEW TCTX KILL TCTX
 SET TCTX("year")=$$YEAR^MIOUTIL()
 SET TCTX("desc")="MUMPS.IO is a professional home for M packages. Community and Pro products. Web server, tooling, and enterprise-ready features."

 NEW OUT,ERR
 IF '$$RENDERPAGE^MIOTPL("mio_index.html","mio_layout.html",.CONF,.TCTX,.OUT,.ERR) DO  QUIT
 . DO RESPJSON^MIOHTTP(DEV,500,.CTX,"{""error"":""template_error"",""detail"":"""_$$ESC^MIOUTIL($GET(ERR("error")))_"""}")

 NEW BODY,I SET BODY="",I=0
 FOR  SET I=$ORDER(OUT(I)) QUIT:I=""  SET BODY=BODY_OUT(I)

 DO RESP^MIOHTTP(DEV,200,"text/html; charset=utf-8",.CTX,BODY)
 QUIT

PAGE(DEV,CONF,REQ,CTX,TITLE,KICKER,HEADING,LEAD,NEXTT,NEXTX,CTAL,CTAH,CTAL2,CTAH2) ;
 ; Render a simple placeholder page using the shared layout.
 NEW TCTX KILL TCTX
 SET TCTX("year")=$$YEAR^MIOUTIL()
 SET TCTX("desc")="MUMPS.IO packages and professional tooling for M."

 SET TCTX("title")=TITLE
 SET TCTX("kicker")=KICKER
 SET TCTX("heading")=HEADING
 SET TCTX("lead")=LEAD
 SET TCTX("nextTitle")=NEXTT
 SET TCTX("nextText")=NEXTX

 IF $L($G(CTAL)),$L($G(CTAH)) DO
 . SET TCTX("cta","label")=CTAL
 . SET TCTX("cta","href")=CTAH
 . IF $L($G(CTAL2)),$L($G(CTAH2)) DO
 . . SET TCTX("cta","secondary","label")=CTAL2
 . . SET TCTX("cta","secondary","href")=CTAH2

 NEW OUT,ERR
 IF '$$RENDERPAGE^MIOTPL("mio_page.html","mio_layout.html",.CONF,.TCTX,.OUT,.ERR) DO  QUIT
 . DO RESPJSON^MIOHTTP(DEV,500,.CTX,"{""error"":""template_error"",""detail"":"""_$$ESC^MIOUTIL($GET(ERR("error")))_"""}")

 NEW BODY,I SET BODY="",I=0
 FOR  SET I=$ORDER(OUT(I)) QUIT:I=""  SET BODY=BODY_OUT(I)
 DO RESP^MIOHTTP(DEV,200,"text/html; charset=utf-8",.CTX,BODY)
 QUIT

REPO(DEV,CONF,REQ,CTX) ;
 DO PAGE(DEV,.CONF,.REQ,.CTX,"MUMPS.IO — Package Registry","Registry","Browse packages","Package discovery and versioned releases.","Next: publish packages","Add package pages and a search index.","Browse packages","/repo/mio-ws","Read docs","/docs")
 QUIT

COMM(DEV,CONF,REQ,CTX) ;
 DO PAGE(DEV,.CONF,.REQ,.CTX,"MUMPS.IO — Community","Community","Free packages","Community packages are free to use.","Next: onboarding","Add install guides and examples.","Browse packages","/repo","Pro plans","/pro")
 QUIT

PRO(DEV,CONF,REQ,CTX) ;
 DO PAGE(DEV,.CONF,.REQ,.CTX,"MUMPS.IO — Pro","Pro","Paid packages and support","Pro adds enterprise features and support.","Next: pricing and checkout","Integrate billing and license delivery.","View Pro details","/pro","Contact","/enterprise")
 QUIT

ENT(DEV,CONF,REQ,CTX) ;
 DO PAGE(DEV,.CONF,.REQ,.CTX,"MUMPS.IO — Enterprise","Enterprise","Talk to us","Enterprise includes SLAs and deployment guidance.","Next: contact flow","Add a contact form and response workflow.","Email us","mailto:hello@mumps.io","Back to home","/")
 QUIT

DOCS(DEV,CONF,REQ,CTX) ;
 DO PAGE(DEV,.CONF,.REQ,.CTX,"MUMPS.IO — Documentation","Docs","Documentation","Docs cover installation, security, and operations.","Next: docs hub","Create a docs index page for packages.","Open docs","/docs","Browse packages","/repo")
 QUIT

SEC(DEV,CONF,REQ,CTX) ;
 DO PAGE(DEV,.CONF,.REQ,.CTX,"MUMPS.IO — Security","Security","Security and compliance","Security features include JWT, JWKS hardening, audit, and limits.","Next: security page","Publish a security overview and disclosure policy.","Read security","/security","Back to home","/")
 QUIT

STATUS(DEV,CONF,REQ,CTX) ;
 DO PAGE(DEV,.CONF,.REQ,.CTX,"MUMPS.IO — Status","Status","Service status","Publish uptime and incidents here.","Next: status automation","Link to monitoring and incident history.","Back to home","/","Contact","/enterprise")
 QUIT

TERMS(DEV,CONF,REQ,CTX) ;
 DO PAGE(DEV,.CONF,.REQ,.CTX,"MUMPS.IO — Terms","Legal","Terms of service","Replace this with your terms when ready.","Next: legal review","Finalize terms and acceptable use.","Back to home","/","Privacy","/privacy")
 QUIT

PRIV(DEV,CONF,REQ,CTX) ;
 DO PAGE(DEV,.CONF,.REQ,.CTX,"MUMPS.IO — Privacy","Legal","Privacy policy","Replace this with your privacy policy when ready.","Next: legal review","Finalize privacy policy and data handling.","Back to home","/","Terms","/terms")
 QUIT
