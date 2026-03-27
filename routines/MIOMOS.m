MIOMOS ; MIOMOS desktop subsystem
	QUIT
	;
CONFDEF(CONF)
	IF $GET(CONF("miomos","enabled"))="" SET CONF("miomos","enabled")=1
	IF $GET(CONF("miomos","profile"))="" SET CONF("miomos","profile")="dev"
	IF $GET(CONF("miomos","route","desktop"))="" SET CONF("miomos","route","desktop")="/miomos"
	IF $GET(CONF("miomos","route","bootstrap"))="" SET CONF("miomos","route","bootstrap")="/api/miomos/bootstrap"
	IF $GET(CONF("miomos","route","ws"))="" SET CONF("miomos","route","ws")="/ws/miomos"
	IF $GET(CONF("miomos","brand","title"))="" SET CONF("miomos","brand","title")="MIOMOS"
	IF $GET(CONF("miomos","brand","subtitle"))="" SET CONF("miomos","brand","subtitle")="MUMPS-first clinical workspace"
	IF $GET(CONF("miomos","desktop","wallpaper"))="" SET CONF("miomos","desktop","wallpaper")="midnight-clinic"
	IF $GET(CONF("miomos","desktop","accent"))="" SET CONF("miomos","desktop","accent")="#2f6fed"
	IF $GET(CONF("miomos","desktop","density"))="" SET CONF("miomos","desktop","density")="dense"
	IF $GET(CONF("miomos","session","idleTimeoutSeconds"))="" SET CONF("miomos","session","idleTimeoutSeconds")=900
	IF $GET(CONF("miomos","session","absoluteTimeoutSeconds"))="" SET CONF("miomos","session","absoluteTimeoutSeconds")=28800
	IF $GET(CONF("miomos","dev","enabled"))="" SET CONF("miomos","dev","enabled")=$SELECT($$DEVPROFILE(.CONF):1,1:0)
	IF $GET(CONF("miomos","dev","authDisabled"))="" SET CONF("miomos","dev","authDisabled")=$SELECT($$DEVPROFILE(.CONF):1,1:0)
	IF $GET(CONF("miomos","dev","principal"))="" SET CONF("miomos","dev","principal")="dev-user"
	IF $GET(CONF("miomos","dev","userName"))="" SET CONF("miomos","dev","userName")="Developer"
	IF $GET(CONF("miomos","dev","roles"))="" SET CONF("miomos","dev","roles")="developer,admin"
	IF $GET(CONF("server","templateDir"))="" SET CONF("server","templateDir")="templates"
	IF $GET(CONF("templates","root"))="" SET CONF("templates","root")=$GET(CONF("server","templateDir"))_"/"
	IF $GET(CONF("templates","ext"))="" SET CONF("templates","ext")=""
	QUIT
	;
INIT(CONF)
	DO CONFDEF(.CONF)
	DO START^MIOTPL(.CONF)
	QUIT
	;
REG(CONF)
	NEW EN,AUTHREQ,META,WSMETA
	DO CONFDEF(.CONF)
	SET EN=+$GET(CONF("miomos","enabled"),1)
	IF EN'=1 QUIT
	IF $$DEVAUTHOFF(.CONF) DO DEVEXEMPT(.CONF)
	IF '$$DEVAUTHOFF(.CONF) DO ADDPROTECT(.CONF,$GET(CONF("miomos","route","desktop")))
	SET AUTHREQ=$SELECT($$DEVAUTHOFF(.CONF):0,1:1)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("miomos","route","desktop")),"DESKTOP^MIOMOS",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("miomos","route","bootstrap")),"BOOTSTRAP^MIOMOSAPI",.META)
	KILL WSMETA SET WSMETA("authRequired")=AUTHREQ,WSMETA("wsPersistent")=1
	DO ADDWSM^MIOROUTE($GET(CONF("miomos","route","ws")),"MESSAGE^MIOMOSWS",.WSMETA)
	QUIT
	;
DEVPROFILE(CONF)
	IF $GET(CONF("miomos","profile"))="dev" QUIT 1
	IF +$GET(CONF("miomos","dev","enabled"),0)=1 QUIT 1
	IF +$GET(CONF("auth","enabled"),1)'=1 QUIT 1
	QUIT 0
	;
DEVAUTHOFF(CONF)
	IF '$$DEVPROFILE(.CONF) QUIT 0
	IF +$GET(CONF("miomos","dev","authDisabled"),1)=1 QUIT 1
	QUIT 0
	;
DEVEXEMPT(CONF)
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","desktop")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","bootstrap")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","ws")))
	QUIT
	;
ADDEXEMPT(CONF,PATH)
	NEW I,N,FOUND
	IF $GET(PATH)="" QUIT
	SET FOUND=0,I=""
	FOR  SET I=$ORDER(CONF("auth","exempt","prefix",I)) QUIT:I=""  DO  QUIT:FOUND
	. IF $GET(CONF("auth","exempt","prefix",I))=PATH SET FOUND=1
	IF FOUND QUIT
	SET N=0,I=""
	FOR  SET I=$ORDER(CONF("auth","exempt","prefix",I)) QUIT:I=""  SET N=+I
	SET CONF("auth","exempt","prefix",N+1)=PATH
	QUIT
	;
ADDPROTECT(CONF,PATH)
	NEW I,N,FOUND
	IF $GET(PATH)="" QUIT
	SET FOUND=0,I=""
	FOR  SET I=$ORDER(CONF("auth","protect","prefix",I)) QUIT:I=""  DO  QUIT:FOUND
	. IF $GET(CONF("auth","protect","prefix",I))=PATH SET FOUND=1
	IF FOUND QUIT
	SET N=0,I=""
	FOR  SET I=$ORDER(CONF("auth","protect","prefix",I)) QUIT:I=""  SET N=+I
	SET CONF("auth","protect","prefix",N+1)=PATH
	QUIT
	;
DESKTOP(DEV,CONF,REQ,CTX)
	NEW STATE,DATA,OUT,ERR,HEAD
	DO CONFDEF(.CONF)
	IF '$$ENSURE^MIOMOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"session_error",$GET(ERR("error")),.CTX)
	DO DESKCTX^MIOMOSUI(.STATE,.CONF,.DATA)
	IF '$$RENDERPAGE^MIOTPL("pages/miomos_desktop.html","layouts/miomos_shell.html",.CONF,.DATA,.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"template_error",$GET(ERR("error")),.CTX)
	SET HEAD("Content-Type")="text/html; charset=utf-8"
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	DO EVENT^MIOMOSAUD("desktop_render",.CTX,.STATE)
	QUIT
	;
RESPERR(DEV,CONF,STATUS,CODE,DETAIL,CTX)
	NEW OBJ
	SET OBJ("routine")="MIOMOS"
	SET OBJ("error")=$GET(CODE,"miomos_error")
	SET OBJ("detail")=$GET(DETAIL)
	SET OBJ("request_id")=$GET(CTX("request_id"))
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,+$GET(STATUS,500),.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=+$GET(STATUS,500)
	QUIT
	;
