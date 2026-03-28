MIOMIDE ; MIOIDE browser IDE subsystem
	QUIT
	;
CONFDEF(CONF)
	NEW ISDEV
	IF $GET(CONF("miomide","enabled"))="" SET CONF("miomide","enabled")=1
	IF $GET(CONF("miomide","profile"))="" SET CONF("miomide","profile")="dev"
	SET ISDEV=$SELECT($GET(CONF("miomide","profile"))="dev":1,1:0)
	IF $GET(CONF("miomide","brand","title"))="" SET CONF("miomide","brand","title")="MIOIDE"
	IF $GET(CONF("miomide","brand","subtitle"))="" SET CONF("miomide","brand","subtitle")="MUMPS / YottaDB IDE"
	IF $GET(CONF("miomide","route","desktop"))="" SET CONF("miomide","route","desktop")="/mioide"
	IF $GET(CONF("miomide","route","bootstrap"))="" SET CONF("miomide","route","bootstrap")="/mioide/api/bootstrap"
	IF $GET(CONF("miomide","route","routines"))="" SET CONF("miomide","route","routines")="/mioide/api/routines"
	IF $GET(CONF("miomide","route","routine"))="" SET CONF("miomide","route","routine")="/mioide/api/routine/:name"
	IF $GET(CONF("miomide","route","save"))="" SET CONF("miomide","route","save")="/mioide/api/routine/:name/save"
	IF $GET(CONF("miomide","route","compile"))="" SET CONF("miomide","route","compile")="/mioide/api/routine/:name/compile"
	IF $GET(CONF("miomide","route","run"))="" SET CONF("miomide","route","run")="/mioide/api/run"
	IF $GET(CONF("miomide","route","search"))="" SET CONF("miomide","route","search")="/mioide/api/search"
	IF $GET(CONF("miomide","route","globals"))="" SET CONF("miomide","route","globals")="/mioide/api/globals"
	IF $GET(CONF("miomide","route","debug"))="" SET CONF("miomide","route","debug")="/mioide/api/debug"
	IF $GET(CONF("miomide","route","eventsWs"))="" SET CONF("miomide","route","eventsWs")="/mioide/ws/events"
	IF $GET(CONF("miomide","route","terminalWs"))="" SET CONF("miomide","route","terminalWs")="/mioide/ws/terminal"
	IF $GET(CONF("miomide","routineDir"))="" SET CONF("miomide","routineDir")="routines"
	IF $GET(CONF("miomide","routinePattern"))="" SET CONF("miomide","routinePattern")="*"
	IF $GET(CONF("miomide","run","command"))="" SET CONF("miomide","run","command")="ydb -run"
	IF $GET(CONF("miomide","terminal","command"))="" SET CONF("miomide","terminal","command")="ydb -direct"
	IF $GET(CONF("miomide","terminal","readLimit"))="" SET CONF("miomide","terminal","readLimit")=8192
	IF $GET(CONF("miomide","terminal","readPolls"))="" SET CONF("miomide","terminal","readPolls")=5
	IF $GET(CONF("miomide","terminal","drainPause"))="" SET CONF("miomide","terminal","drainPause")=.04
	IF $GET(CONF("miomide","terminal","sessionIdleSeconds"))="" SET CONF("miomide","terminal","sessionIdleSeconds")=900
	IF $GET(CONF("miomide","terminal","reconnectDelayMs"))="" SET CONF("miomide","terminal","reconnectDelayMs")=1200
	IF $GET(CONF("miomide","terminal","pingIntervalMs"))="" SET CONF("miomide","terminal","pingIntervalMs")=15000
	IF $GET(CONF("miomide","terminal","closeOnUnload"))="" SET CONF("miomide","terminal","closeOnUnload")=1
	IF $GET(CONF("miomide","search","limit"))="" SET CONF("miomide","search","limit")=50
	IF $GET(CONF("miomide","globals","limit"))="" SET CONF("miomide","globals","limit")=100
	IF $GET(CONF("miomide","terminal","cols"))="" SET CONF("miomide","terminal","cols")=132
	IF $GET(CONF("miomide","terminal","rows"))="" SET CONF("miomide","terminal","rows")=32
	IF $GET(CONF("miomide","ui","storageKey"))="" SET CONF("miomide","ui","storageKey")="miomide:workspace"
	IF $GET(CONF("miomide","ui","activityWidth"))="" SET CONF("miomide","ui","activityWidth")=48
	IF $GET(CONF("miomide","ui","sidebarWidth"))="" SET CONF("miomide","ui","sidebarWidth")=300
	IF $GET(CONF("miomide","ui","panelHeight"))="" SET CONF("miomide","ui","panelHeight")=220
	IF $GET(CONF("miomide","ui","sidebarMinWidth"))="" SET CONF("miomide","ui","sidebarMinWidth")=220
	IF $GET(CONF("miomide","ui","sidebarMaxWidth"))="" SET CONF("miomide","ui","sidebarMaxWidth")=520
	IF $GET(CONF("miomide","ui","panelMinHeight"))="" SET CONF("miomide","ui","panelMinHeight")=140
	IF $GET(CONF("miomide","ui","panelMaxHeight"))="" SET CONF("miomide","ui","panelMaxHeight")=420
	IF $GET(CONF("miomide","ui","tabMinWidth"))="" SET CONF("miomide","ui","tabMinWidth")=140
	IF $GET(CONF("miomide","ui","tabMaxWidth"))="" SET CONF("miomide","ui","tabMaxWidth")=240
	IF $GET(CONF("miomide","ui","theme"))="" SET CONF("miomide","ui","theme")="mioide-dark"
	IF $GET(CONF("miomide","ui","fontSize"))="" SET CONF("miomide","ui","fontSize")=13
	IF $GET(CONF("miomide","ui","lineHeight"))="" SET CONF("miomide","ui","lineHeight")=1.6
	IF $GET(CONF("miomide","ui","commandPalette"))="" SET CONF("miomide","ui","commandPalette")=1
	IF $GET(CONF("miomide","ui","quickOpen"))="" SET CONF("miomide","ui","quickOpen")=1
	IF $GET(CONF("miomide","ui","welcome"))="" SET CONF("miomide","ui","welcome")=1
	IF $GET(CONF("miomide","workspace","compileAutoSave"))="" SET CONF("miomide","workspace","compileAutoSave")=1
	IF $GET(CONF("miomide","workspace","problemLimit"))="" SET CONF("miomide","workspace","problemLimit")=25
	IF $GET(CONF("miomide","workspace","recentLimit"))="" SET CONF("miomide","workspace","recentLimit")=15
	IF $GET(CONF("miomide","dev","enabled"))="" SET CONF("miomide","dev","enabled")=ISDEV
	IF $GET(CONF("miomide","dev","authDisabled"))="" SET CONF("miomide","dev","authDisabled")=ISDEV
	IF $GET(CONF("miomide","dev","principal"))="" SET CONF("miomide","dev","principal")="dev-user"
	IF $GET(CONF("miomide","dev","userName"))="" SET CONF("miomide","dev","userName")="Developer"
	IF $GET(CONF("miomide","dev","roles"))="" SET CONF("miomide","dev","roles")="developer,admin"
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
	NEW AUTHREQ,META,WSMETA
	DO CONFDEF(.CONF)
	QUIT:'+$GET(CONF("miomide","enabled"),1)
	SET AUTHREQ=$SELECT($$DEVAUTHOFF(.CONF):0,1:1)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("miomide","route","desktop")),"DESKTOP^MIOMIDE",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("miomide","route","bootstrap")),"BOOTSTRAP^MIOMIDEAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("miomide","route","routines")),"ROUTINES^MIOMIDEAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("miomide","route","routine")),"ROUTINE^MIOMIDEAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("POST",$GET(CONF("miomide","route","save")),"SAVE^MIOMIDEAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("POST",$GET(CONF("miomide","route","compile")),"COMPILE^MIOMIDEAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("POST",$GET(CONF("miomide","route","run")),"RUN^MIOMIDEAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("miomide","route","search")),"SEARCH^MIOMIDEAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("miomide","route","globals")),"GLOBALS^MIOMIDEAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("miomide","route","debug")),"DEBUG^MIOMIDEAPI",.META)
	KILL WSMETA SET WSMETA("authRequired")=AUTHREQ
	DO ADDWSM^MIOROUTE($GET(CONF("miomide","route","eventsWs")),"MESSAGE^MIOMIDEWS",.WSMETA)
	KILL WSMETA SET WSMETA("authRequired")=AUTHREQ
	DO ADDWSM^MIOROUTE($GET(CONF("miomide","route","terminalWs")),"MESSAGE^MIOMIDETM",.WSMETA)
	QUIT
	;
DEVAUTHOFF(CONF)
	QUIT +$GET(CONF("miomide","dev","enabled"))&+$GET(CONF("miomide","dev","authDisabled"))
	;
DESKTOP(DEV,CONF,REQ,CTX)
	NEW STATE,DATA,OUT,ERR,HEAD
	IF '$$ENSURE^MIOMIDEST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,401,"login_required",$GET(ERR("error")),.CTX)
	DO PAGECTX^MIOMIDEST(.STATE,.CONF,.REQ,.CTX,.DATA)
	IF '$$RENDERPAGE^MIOTPL("pages/miomide_index.html","layouts/miomide_shell.html",.CONF,.DATA,.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"template_error",$GET(ERR("error")),.CTX)
	SET HEAD("Content-Type")="text/html; charset=utf-8"
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,OUT,$GET(CTX("request_id")),.CTX)
	QUIT
	;
RESPERR(DEV,CONF,STATUS,CODE,DETAIL,CTX)
	NEW OBJ
	SET OBJ("ok")=0
	SET OBJ("routine")="MIOMIDE"
	SET OBJ("error")=$GET(CODE)
	SET OBJ("detail")=$GET(DETAIL)
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,+$GET(STATUS,500),.OBJ,$GET(CTX("request_id")),.CTX)
	QUIT
