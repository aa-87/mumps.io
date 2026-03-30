MIOOS
	;
	;
	Q
;
REG(CONF)
	D ADD^MIOROUTE("GET","/os","DESKTOP^MIOOS")
	D ADD^MIOROUTE("GET","/public/mioos/*","STATIC^MIOOS")
	Q
	;
STATIC(DEV,CONF,REQ,CTX)
	SET CONF("server","static","mount")="/public"
	SET CONF("server","static","root")="./public"
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	QUIT
	;
DESKTOP(DEV,CONF,REQ,CTX)
	SET HEAD("Content-Type")="text/html; charset=utf-8"
	D RENDERPAGE^MIOTPL("pages/mioos_desktop.html","layouts/mioos_shell.html",.CONF,.TCTX,.OUT,.ERR)
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,OUT,$GET(CTX("request_id")),.CTX)
	Q
	;