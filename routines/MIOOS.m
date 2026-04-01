MIOOS ; MIOOS desktop subsystem
	QUIT
	;
CONFDEF(CONF)
	IF $GET(CONF("mioos","enabled"))="" SET CONF("mioos","enabled")=1
	IF $GET(CONF("mioos","profile"))="" SET CONF("mioos","profile")="dev"
	IF $GET(CONF("mioos","route","desktop"))="" SET CONF("mioos","route","desktop")="/mioos"
	IF $GET(CONF("mioos","route","desktopAlias"))="" SET CONF("mioos","route","desktopAlias")="/os"
	IF $GET(CONF("mioos","route","bootstrap"))="" SET CONF("mioos","route","bootstrap")="/api/mioos/bootstrap"
	IF $GET(CONF("mioos","route","view"))="" SET CONF("mioos","route","view")="/api/mioos/view"
	IF $GET(CONF("mioos","route","ws"))="" SET CONF("mioos","route","ws")="/ws/mioos"
	IF $GET(CONF("mioos","brand","title"))="" SET CONF("mioos","brand","title")="MIOOS"
	IF $GET(CONF("mioos","brand","subtitle"))="" SET CONF("mioos","brand","subtitle")="MUMPS powered Windows XP style desktop"
	IF $GET(CONF("mioos","desktop","theme"))="" SET CONF("mioos","desktop","theme")="xp-classic-blue"
	IF $GET(CONF("mioos","desktop","wallpaper"))="" SET CONF("mioos","desktop","wallpaper")="bliss"
	IF $GET(CONF("mioos","desktop","density"))="" SET CONF("mioos","desktop","density")="comfortable"
	IF $GET(CONF("mioos","desktop","fontFamily"))="" SET CONF("mioos","desktop","fontFamily")="Segoe UI"
	IF $GET(CONF("mioos","desktop","fontSize"))="" SET CONF("mioos","desktop","fontSize")=13
	IF $GET(CONF("mioos","desktop","launcherLabel"))="" SET CONF("mioos","desktop","launcherLabel")="Menu"
	IF $GET(CONF("mioos","desktop","transport","eventName"))="" SET CONF("mioos","desktop","transport","eventName")="desktop.command"
	IF $GET(CONF("mioos","desktop","transport","resultEvent"))="" SET CONF("mioos","desktop","transport","resultEvent")="desktop.result"
	IF $GET(CONF("mioos","desktop","transport","errorEvent"))="" SET CONF("mioos","desktop","transport","errorEvent")="desktop.error"
	IF $GET(CONF("mioos","desktop","transport","model"))="" SET CONF("mioos","desktop","transport","model")="single-websocket-command-and-events"
	IF $GET(CONF("mioos","desktop","chrome"))="" SET CONF("mioos","desktop","chrome")="winxp-professional"
	IF $GET(CONF("mioos","desktop","taskbarStyle"))="" SET CONF("mioos","desktop","taskbarStyle")="xp-professional"
	IF $GET(CONF("mioos","desktop","startMenuStyle"))="" SET CONF("mioos","desktop","startMenuStyle")="xp-two-column"
	IF $GET(CONF("mioos","desktop","windowManager"))="" SET CONF("mioos","desktop","windowManager")="mioos-native-vue-css"
	IF $GET(CONF("mioos","desktop","authRequired"))="" SET CONF("mioos","desktop","authRequired")=0
	IF $GET(CONF("server","templateDir"))="" SET CONF("server","templateDir")="templates"
	IF $GET(CONF("templates","root"))="" SET CONF("templates","root")=$GET(CONF("server","templateDir"))_"/"
	IF $GET(CONF("templates","ext"))="" SET CONF("templates","ext")=""
	QUIT
	;
INIT(CONF)
	DO CONFDEF(.CONF)
	QUIT
	;
REG(CONF)
	NEW META,WSMETA,AUTHREQ
	DO INIT(.CONF)
	IF +$GET(CONF("mioos","enabled"),1)'=1 QUIT
	SET AUTHREQ=+$GET(CONF("mioos","desktop","authRequired"),0)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("mioos","route","desktop")),"DESKTOP^MIOOS",.META)
	DO ADDM^MIOROUTE("GET",$GET(CONF("mioos","route","desktopAlias")),"DESKTOP^MIOOS",.META)
	DO ADDM^MIOROUTE("GET",$GET(CONF("mioos","route","bootstrap")),"BOOTSTRAP^MIOOSAPI",.META)
	DO ADDM^MIOROUTE("GET",$GET(CONF("mioos","route","view")),"VIEW^MIOOSAPI",.META)
	KILL META SET META("authRequired")=0
	DO ADDM^MIOROUTE("GET","/public/mioos/*","STATIC^MIOOS",.META)
	KILL WSMETA SET WSMETA("authRequired")=AUTHREQ,WSMETA("wsPersistent")=1
	DO ADDWSM^MIOROUTE($GET(CONF("mioos","route","ws")),"MESSAGE^MIOOSWS",.WSMETA)
	QUIT
	;
STATIC(DEV,CONF,REQ,CTX)
	SET CONF("server","static","mount")="/public"
	SET CONF("server","static","root")="./public"
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	QUIT
	;
DESKTOP(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,TCTX,OUT,HEAD
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"desktop_state_error",$GET(ERR("error"),"desktop_state_error"),.CTX)
	DO DESKCTX^MIOOSUI(.STATE,.CONF,.TCTX)
	DO RENDERPAGE^MIOTPL("pages/mioos_desktop.html","layouts/mioos_shell.html",.CONF,.TCTX,.OUT,.ERR)
	IF $DATA(ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"template_error",$GET(ERR("error"),"template_error"),.CTX)
	SET HEAD("Content-Type")="text/html; charset=utf-8"
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
RESPERR(DEV,CONF,STATUS,CODE,DETAIL,CTX)
	NEW OBJ
	SET OBJ("ok")=0,OBJ("error")=$GET(CODE),OBJ("detail")=$GET(DETAIL),OBJ("routine")="MIOOS"
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,+$GET(STATUS),.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=+$GET(STATUS)
	QUIT
