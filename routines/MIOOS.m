MIOOS ; MIOOS desktop subsystem
	QUIT
	;
CONFDEF(CONF)
	NEW ISDEV
	IF $GET(CONF("mioos","enabled"))="" SET CONF("mioos","enabled")=1
	IF $GET(CONF("mioos","profile"))="" SET CONF("mioos","profile")="dev"
	SET ISDEV=$SELECT($GET(CONF("mioos","profile"))="dev":1,1:0)
	IF $GET(CONF("mioos","route","desktop"))="" SET CONF("mioos","route","desktop")="/mioos"
	IF $GET(CONF("mioos","route","desktopAlias"))="" SET CONF("mioos","route","desktopAlias")="/os"
	IF $GET(CONF("mioos","route","bootstrap"))="" SET CONF("mioos","route","bootstrap")="/api/mioos/bootstrap"
	IF $GET(CONF("mioos","route","view"))="" SET CONF("mioos","route","view")="/api/mioos/view"
	IF $GET(CONF("mioos","route","signin"))="" SET CONF("mioos","route","signin")="/api/mioos/auth/signin"
	IF $GET(CONF("mioos","route","signout"))="" SET CONF("mioos","route","signout")="/api/mioos/auth/signout"
	IF $GET(CONF("mioos","route","guestSignin"))="" SET CONF("mioos","route","guestSignin")="/api/mioos/auth/guest"
	IF $GET(CONF("mioos","route","fsList"))="" SET CONF("mioos","route","fsList")="/api/mioos/fs/list"
	IF $GET(CONF("mioos","route","fsRead"))="" SET CONF("mioos","route","fsRead")="/api/mioos/fs/read"
	IF $GET(CONF("mioos","route","fsWrite"))="" SET CONF("mioos","route","fsWrite")="/api/mioos/fs/write"
	IF $GET(CONF("mioos","route","fsMkdir"))="" SET CONF("mioos","route","fsMkdir")="/api/mioos/fs/mkdir"
	IF $GET(CONF("mioos","route","fsMeta"))="" SET CONF("mioos","route","fsMeta")="/api/mioos/fs/meta"
	IF $GET(CONF("mioos","route","fsRename"))="" SET CONF("mioos","route","fsRename")="/api/mioos/fs/rename"
	IF $GET(CONF("mioos","route","fsMove"))="" SET CONF("mioos","route","fsMove")="/api/mioos/fs/move"
	IF $GET(CONF("mioos","route","fsDelete"))="" SET CONF("mioos","route","fsDelete")="/api/mioos/fs/delete"
	IF $GET(CONF("mioos","route","ws"))="" SET CONF("mioos","route","ws")="/ws/mioos"
	IF $GET(CONF("mioos","route","wsTerminal"))="" SET CONF("mioos","route","wsTerminal")="/ws/mioos/terminal"
	IF $GET(CONF("mioos","websocket","maxSocketsPerSession"))="" SET CONF("mioos","websocket","maxSocketsPerSession")=4
	IF $GET(CONF("mioos","websocket","coreSockets"))="" SET CONF("mioos","websocket","coreSockets")=1
	IF $GET(CONF("mioos","websocket","fsSockets"))="" SET CONF("mioos","websocket","fsSockets")=3
	IF $GET(CONF("mioos","websocket","uploadBatchSize"))="" SET CONF("mioos","websocket","uploadBatchSize")=4
	IF $GET(CONF("mioos","brand","title"))="" SET CONF("mioos","brand","title")="MIOOS"
	IF $GET(CONF("mioos","brand","subtitle"))="" SET CONF("mioos","brand","subtitle")="MUMPS powered Windows XP style desktop"
	IF $GET(CONF("mioos","i18n","default"))="" SET CONF("mioos","i18n","default")="en"
	IF $GET(CONF("mioos","desktop","theme"))="" SET CONF("mioos","desktop","theme")="xp-classic-blue"
	IF $GET(CONF("mioos","desktop","wallpaper"))="" SET CONF("mioos","desktop","wallpaper")="bliss"
	IF $GET(CONF("mioos","desktop","density"))="" SET CONF("mioos","desktop","density")="comfortable"
	IF $GET(CONF("mioos","desktop","fontFamily"))="" SET CONF("mioos","desktop","fontFamily")="Segoe UI"
	IF $GET(CONF("mioos","desktop","fontSize"))="" SET CONF("mioos","desktop","fontSize")=13
	IF $GET(CONF("mioos","desktop","launcherLabel"))="" SET CONF("mioos","desktop","launcherLabel")="Menu"
	IF $GET(CONF("mioos","desktop","transport","eventName"))="" SET CONF("mioos","desktop","transport","eventName")="desktop.command"
	IF $GET(CONF("mioos","desktop","transport","resultEvent"))="" SET CONF("mioos","desktop","transport","resultEvent")="desktop.result"
	IF $GET(CONF("mioos","desktop","transport","errorEvent"))="" SET CONF("mioos","desktop","transport","errorEvent")="desktop.error"
	IF $GET(CONF("mioos","desktop","transport","model"))="" SET CONF("mioos","desktop","transport","model")="core-websocket-plus-app-websockets"
	IF $GET(CONF("mioos","desktop","chrome"))="" SET CONF("mioos","desktop","chrome")="winxp-professional"
	IF $GET(CONF("mioos","desktop","taskbarStyle"))="" SET CONF("mioos","desktop","taskbarStyle")="xp-professional"
	IF $GET(CONF("mioos","desktop","startMenuStyle"))="" SET CONF("mioos","desktop","startMenuStyle")="xp-two-column"
	IF $GET(CONF("mioos","desktop","windowManager"))="" SET CONF("mioos","desktop","windowManager")="mioos-native-vue-css"
	IF $GET(CONF("mioos","desktop","authRequired"))="" SET CONF("mioos","desktop","authRequired")=0
	IF $GET(CONF("mioos","dev","enabled"))="" SET CONF("mioos","dev","enabled")=ISDEV
	IF $GET(CONF("mioos","dev","authDisabled"))="" SET CONF("mioos","dev","authDisabled")=0
	IF $GET(CONF("mioos","dev","principal"))="" SET CONF("mioos","dev","principal")="dev-user"
	IF $GET(CONF("mioos","dev","userName"))="" SET CONF("mioos","dev","userName")="Developer"
	IF $GET(CONF("mioos","dev","roles"))="" SET CONF("mioos","dev","roles")="developer,admin"
	IF $GET(CONF("mioos","localAuth","enabled"))="" SET CONF("mioos","localAuth","enabled")=1
	IF $GET(CONF("mioos","localAuth","guestLoginEnabled"))="" SET CONF("mioos","localAuth","guestLoginEnabled")=1
	IF $GET(CONF("mioos","localAuth","tokenCookie"))="" SET CONF("mioos","localAuth","tokenCookie")="mioos_auth"
	IF $GET(CONF("mioos","localAuth","tokenMaxAgeSeconds"))="" SET CONF("mioos","localAuth","tokenMaxAgeSeconds")=604800
	IF $GET(CONF("mioos","localAuth","lockThreshold"))="" SET CONF("mioos","localAuth","lockThreshold")=5
	IF $GET(CONF("mioos","localAuth","lockMinutes"))="" SET CONF("mioos","localAuth","lockMinutes")=15
	IF $GET(CONF("mioos","bootstrapAuth","enabled"))="" SET CONF("mioos","bootstrapAuth","enabled")=1
	IF $GET(CONF("mioos","bootstrapAuth","seedIfMissing"))="" SET CONF("mioos","bootstrapAuth","seedIfMissing")=1
	IF $GET(CONF("mioos","bootstrapAuth","syncOnBoot"))="" SET CONF("mioos","bootstrapAuth","syncOnBoot")=1
	IF $GET(CONF("mioos","bootstrapAuth","admin","username"))="" SET CONF("mioos","bootstrapAuth","admin","username")="admin"
	IF $GET(CONF("mioos","bootstrapAuth","admin","displayName"))="" SET CONF("mioos","bootstrapAuth","admin","displayName")="Administrator"
	IF $GET(CONF("mioos","bootstrapAuth","admin","password"))="" SET CONF("mioos","bootstrapAuth","admin","password")="admin123!"
	IF $GET(CONF("mioos","bootstrapAuth","admin","roles"))="" SET CONF("mioos","bootstrapAuth","admin","roles")="admin"
	IF $GET(CONF("mioos","bootstrapAuth","admin","enabled"))="" SET CONF("mioos","bootstrapAuth","admin","enabled")=1
	IF $GET(CONF("mioos","bootstrapAuth","user","username"))="" SET CONF("mioos","bootstrapAuth","user","username")="user"
	IF $GET(CONF("mioos","bootstrapAuth","user","displayName"))="" SET CONF("mioos","bootstrapAuth","user","displayName")="User"
	IF $GET(CONF("mioos","bootstrapAuth","user","password"))="" SET CONF("mioos","bootstrapAuth","user","password")="user123!"
	IF $GET(CONF("mioos","bootstrapAuth","user","roles"))="" SET CONF("mioos","bootstrapAuth","user","roles")="operator"
	IF $GET(CONF("mioos","bootstrapAuth","user","enabled"))="" SET CONF("mioos","bootstrapAuth","user","enabled")=1
	IF $GET(CONF("mioos","bootstrapAuth","guest","username"))="" SET CONF("mioos","bootstrapAuth","guest","username")="guest"
	IF $GET(CONF("mioos","bootstrapAuth","guest","displayName"))="" SET CONF("mioos","bootstrapAuth","guest","displayName")="Guest"
	IF $GET(CONF("mioos","bootstrapAuth","guest","password"))="" SET CONF("mioos","bootstrapAuth","guest","password")="guest123!"
	IF $GET(CONF("mioos","bootstrapAuth","guest","roles"))="" SET CONF("mioos","bootstrapAuth","guest","roles")="guest"
	IF $GET(CONF("mioos","bootstrapAuth","guest","enabled"))="" SET CONF("mioos","bootstrapAuth","guest","enabled")=1
	IF $GET(CONF("mioos","terminal","enabled"))="" SET CONF("mioos","terminal","enabled")=1
	IF $GET(CONF("mioos","terminal","commandTransport"))="" SET CONF("mioos","terminal","commandTransport")="dedicated-websocket"
	IF $GET(CONF("mioos","terminal","websocket","pollMs"))="" SET CONF("mioos","terminal","websocket","pollMs")=250
	IF $GET(CONF("mioos","terminal","default","engine"))="" SET CONF("mioos","terminal","default","engine")="xtermjs"
	IF $GET(CONF("mioos","terminal","default","fontFamily"))="" SET CONF("mioos","terminal","default","fontFamily")="Consolas"
	IF $GET(CONF("mioos","terminal","default","fontSize"))="" SET CONF("mioos","terminal","default","fontSize")=14
	IF $GET(CONF("mioos","terminal","default","cursorBlink"))="" SET CONF("mioos","terminal","default","cursorBlink")=1
	IF $GET(CONF("mioos","terminal","default","cursorStyle"))="" SET CONF("mioos","terminal","default","cursorStyle")="block"
	IF $GET(CONF("mioos","terminal","default","scrollback"))="" SET CONF("mioos","terminal","default","scrollback")=2500
	IF $GET(CONF("mioos","terminal","default","renderer"))="" SET CONF("mioos","terminal","default","renderer")="canvas"
	IF $GET(CONF("mioos","terminal","default","unicode"))="" SET CONF("mioos","terminal","default","unicode")="unicode11"
	IF $GET(CONF("mioos","terminal","default","rows"))="" SET CONF("mioos","terminal","default","rows")=28
	IF $GET(CONF("mioos","terminal","default","cols"))="" SET CONF("mioos","terminal","default","cols")=112
	IF $GET(CONF("mioos","terminal","maxSessionsPerUser"))="" SET CONF("mioos","terminal","maxSessionsPerUser")=8
	IF $GET(CONF("mioos","terminal","historyLimit"))="" SET CONF("mioos","terminal","historyLimit")=400
	IF $GET(CONF("mioos","terminal","pipe","command"))="" SET CONF("mioos","terminal","pipe","command")=""
	IF $GET(CONF("mioos","terminal","pipe","shell"))="" SET CONF("mioos","terminal","pipe","shell")=""
	IF $GET(CONF("mioos","terminal","pipe","readLimit"))="" SET CONF("mioos","terminal","pipe","readLimit")=16384
	IF $GET(CONF("mioos","terminal","pipe","readPolls"))="" SET CONF("mioos","terminal","pipe","readPolls")=8
	IF $GET(CONF("mioos","terminal","pipe","drainPause"))="" SET CONF("mioos","terminal","pipe","drainPause")=.04
	IF $GET(CONF("mioos","terminal","pipe","reconnectGraceSeconds"))="" SET CONF("mioos","terminal","pipe","reconnectGraceSeconds")=180
	IF $GET(CONF("mioos","fs","enabled"))="" SET CONF("mioos","fs","enabled")=1
	IF $GET(CONF("mioos","fs","chunkSize"))="" SET CONF("mioos","fs","chunkSize")=2048
	IF $GET(CONF("mioos","fs","transport"))="" SET CONF("mioos","fs","transport")="http-and-websocket"
	IF $GET(CONF("mioos","upload","chunkBytes"))="" SET CONF("mioos","upload","chunkBytes")=32768
	IF $GET(CONF("mioos","upload","concurrency"))="" SET CONF("mioos","upload","concurrency")=7
	IF $GET(CONF("mioos","terminal","pipe","sessionIdleSeconds"))="" SET CONF("mioos","terminal","pipe","sessionIdleSeconds")=900
	IF $GET(CONF("auth","protectMode"))="" SET CONF("auth","protectMode")="route"
	IF $GET(CONF("auth","mode"))="" SET CONF("auth","mode")="jwt"
	IF $GET(CONF("auth","jwt","cookieName"))="" SET CONF("auth","jwt","cookieName")=$GET(CONF("mioos","localAuth","tokenCookie"),"mioos_auth")
	IF $GET(CONF("auth","jwt","rolesClaim"))="" SET CONF("auth","jwt","rolesClaim")="roles"
	IF $GET(CONF("auth","jwt","issuer"))="" SET CONF("auth","jwt","issuer")="mioos-local-auth"
	IF $GET(CONF("auth","jwt","audience"))="" SET CONF("auth","jwt","audience")="mioos"
	IF $GET(CONF("auth","jwt","hmacSecret"))="" SET CONF("auth","jwt","hmacSecret")="mioos-local-auth-change-me"
	IF $GET(CONF("auth","session","mioos","cookieName"))="" SET CONF("auth","session","mioos","cookieName")=$GET(CONF("mioos","localAuth","tokenCookie"),"mioos_auth")
	IF $GET(CONF("auth","session","mioos","maxAgeSeconds"))="" SET CONF("auth","session","mioos","maxAgeSeconds")=+$GET(CONF("mioos","localAuth","tokenMaxAgeSeconds"),604800)
	IF $GET(CONF("server","templateDir"))="" SET CONF("server","templateDir")="templates"
	IF $GET(CONF("templates","root"))="" SET CONF("templates","root")=$GET(CONF("server","templateDir"))_"/"
	IF $GET(CONF("templates","ext"))="" SET CONF("templates","ext")=""
	QUIT
	;
INIT(CONF)
	DO CONFDEF(.CONF)
	DO BOOTSTRAP^MIOOSAUTH(.CONF)
	DO INIT^MIOOSFS(.CONF)
	QUIT
	;
REG(CONF)
	NEW META,WSMETA
	DO INIT(.CONF)
	IF +$GET(CONF("mioos","enabled"),1)'=1 QUIT
	KILL META SET META("authRequired")=0
	DO ADDM^MIOROUTE("GET",$GET(CONF("mioos","route","desktop")),"DESKTOP^MIOOS",.META)
	DO ADDM^MIOROUTE("GET",$GET(CONF("mioos","route","desktopAlias")),"DESKTOP^MIOOS",.META)
	DO ADDM^MIOROUTE("GET",$GET(CONF("mioos","route","bootstrap")),"BOOTSTRAP^MIOOSAPI",.META)
	DO ADDM^MIOROUTE("GET",$GET(CONF("mioos","route","view")),"VIEW^MIOOSAPI",.META)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","signin")),"SIGNIN^MIOOSAPI",.META)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","signout")),"SIGNOUT^MIOOSAPI",.META)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","guestSignin")),"GUESTSIGNIN^MIOOSAPI",.META)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsList")),"FSLIST^MIOOSAPI",.META)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsRead")),"FSREAD^MIOOSAPI",.META)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsWrite")),"FSWRITE^MIOOSAPI",.META)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsMkdir")),"FSMKDIR^MIOOSAPI",.META)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsMeta")),"FSMETA^MIOOSAPI",.META)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsRename")),"FSRENAME^MIOOSAPI",.META)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsMove")),"FSMOVE^MIOOSAPI",.META)
	DO ADDM^MIOROUTE("POST",$GET(CONF("mioos","route","fsDelete")),"FSDELETE^MIOOSAPI",.META)
	DO ADDM^MIOROUTE("GET","/public/mioos/*","STATIC^MIOOS",.META)
	KILL WSMETA SET WSMETA("authRequired")=0,WSMETA("wsPersistent")=1
	DO ADDWSM^MIOROUTE($GET(CONF("mioos","route","ws")),"MESSAGE^MIOOSWS",.WSMETA)
	DO ADDWSM^MIOROUTE($GET(CONF("mioos","route","wsTerminal")),"MESSAGE^MIOOSTWS",.WSMETA)
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
	;