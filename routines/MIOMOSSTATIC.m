MIOMOSSTATIC
	;
	;
	;
	Q
	;
GET(DEV,CONF,REQ,CTX)
	SET CONF("server","static","mount")="/public"
	SET CONF("server","static","root")="./public"
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	QUIT
	;
	;
GET2(DEV,CONF,REQ,CTX)
	SET CONF("server","static","mount")="/public"
	SET CONF("server","static","root")="./public"
	;DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX) M ^CC=CTX
	S FS="./public/miomos/miomos_shell.css"
	S HEAD=""
	S METHOD="GET"
	NEW OK SET OK=$$SENDFILE^MIOHTTP(.DEV,.CONF,FS,.HEAD,$GET(CTX("request_id")),.CTX,METHOD)
	;	
	QUIT