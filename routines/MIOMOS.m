MIOMOS ; MIOMOS desktop subsystem
	QUIT
	;
CONFDEF(CONF)
	NEW ISDEV
	IF $GET(CONF("miomos","enabled"))="" SET CONF("miomos","enabled")=1
	IF $GET(CONF("miomos","profile"))="" SET CONF("miomos","profile")="dev"
	SET ISDEV=$SELECT($GET(CONF("miomos","profile"))="dev":1,1:0)
	IF $GET(CONF("miomos","route","desktop"))="" SET CONF("miomos","route","desktop")="/miomos"
	IF $GET(CONF("miomos","route","bootstrap"))="" SET CONF("miomos","route","bootstrap")="/api/miomos/bootstrap"
	IF $GET(CONF("miomos","route","ws"))="" SET CONF("miomos","route","ws")="/ws/miomos"
	IF $GET(CONF("miomos","route","theme"))="" SET CONF("miomos","route","theme")="/api/miomos/theme"
	IF $GET(CONF("miomos","route","settings"))="" SET CONF("miomos","route","settings")="/api/miomos/settings"
	IF $GET(CONF("miomos","route","view"))="" SET CONF("miomos","route","view")="/api/miomos/view"
	IF $GET(CONF("miomos","route","command"))="" SET CONF("miomos","route","command")="/api/miomos/command"
	IF $GET(CONF("miomos","route","signin"))="" SET CONF("miomos","route","signin")="/api/miomos/auth/signin"
	IF $GET(CONF("miomos","route","signup"))="" SET CONF("miomos","route","signup")="/api/miomos/auth/signup"
	IF $GET(CONF("miomos","route","signout"))="" SET CONF("miomos","route","signout")="/api/miomos/auth/signout"
	IF $GET(CONF("miomos","route","guestSignin"))="" SET CONF("miomos","route","guestSignin")="/api/miomos/auth/guest"
	IF $GET(CONF("miomos","route","resetApply"))="" SET CONF("miomos","route","resetApply")="/api/miomos/auth/reset"
	IF $GET(CONF("miomos","route","adminUsers"))="" SET CONF("miomos","route","adminUsers")="/api/miomos/admin/users"
	IF $GET(CONF("miomos","route","adminDisable"))="" SET CONF("miomos","route","adminDisable")="/api/miomos/admin/users/disable"
	IF $GET(CONF("miomos","route","adminEnable"))="" SET CONF("miomos","route","adminEnable")="/api/miomos/admin/users/enable"
	IF $GET(CONF("miomos","route","adminLock"))="" SET CONF("miomos","route","adminLock")="/api/miomos/admin/users/lock"
	IF $GET(CONF("miomos","route","adminUnlock"))="" SET CONF("miomos","route","adminUnlock")="/api/miomos/admin/users/unlock"
	IF $GET(CONF("miomos","route","adminInviteCreate"))="" SET CONF("miomos","route","adminInviteCreate")="/api/miomos/admin/invites/create"
	IF $GET(CONF("miomos","route","adminInvites"))="" SET CONF("miomos","route","adminInvites")="/api/miomos/admin/invites"
	IF $GET(CONF("miomos","route","adminResetRequest"))="" SET CONF("miomos","route","adminResetRequest")="/api/miomos/admin/users/reset/request"
	IF $GET(CONF("miomos","route","adminUserRoles"))="" SET CONF("miomos","route","adminUserRoles")="/api/miomos/admin/users/roles"
	IF $GET(CONF("miomos","route","adminGuestToggle"))="" SET CONF("miomos","route","adminGuestToggle")="/api/miomos/admin/config/guest-login"
	IF $GET(CONF("miomos","route","adminReports"))="" SET CONF("miomos","route","adminReports")="/api/miomos/admin/reports"
	IF $GET(CONF("miomos","route","observSummary"))="" SET CONF("miomos","route","observSummary")="/api/miomos/observability/summary"
	IF $GET(CONF("miomos","route","accessExport"))="" SET CONF("miomos","route","accessExport")="/api/miomos/observability/access/export"
	IF $GET(CONF("miomos","route","errorExport"))="" SET CONF("miomos","route","errorExport")="/api/miomos/observability/error/export"
	IF $GET(CONF("miomos","route","auditExport"))="" SET CONF("miomos","route","auditExport")="/api/miomos/observability/audit/export"
	IF $GET(CONF("miomos","route","securityDigest"))="" SET CONF("miomos","route","securityDigest")="/api/miomos/observability/digest"
	IF $GET(CONF("miomos","route","retentionPrune"))="" SET CONF("miomos","route","retentionPrune")="/api/miomos/observability/retention/prune"
	IF $GET(CONF("miomos","brand","title"))="" SET CONF("miomos","brand","title")="MIOMOS"
	IF $GET(CONF("miomos","brand","subtitle"))="" SET CONF("miomos","brand","subtitle")="MUMPS-first clinical workspace"
	IF $GET(CONF("miomos","desktop","wallpaper"))="" SET CONF("miomos","desktop","wallpaper")="midnight-clinic"
	IF $GET(CONF("miomos","desktop","accent"))="" SET CONF("miomos","desktop","accent")="#2f6fed"
	IF $GET(CONF("miomos","desktop","density"))="" SET CONF("miomos","desktop","density")="dense"
	IF $GET(CONF("miomos","desktop","snapMargin"))="" SET CONF("miomos","desktop","snapMargin")=18
	IF $GET(CONF("miomos","desktop","transport","commandBus"))="" SET CONF("miomos","desktop","transport","commandBus")="websocket-only"
	IF $GET(CONF("miomos","desktop","transport","eventName"))="" SET CONF("miomos","desktop","transport","eventName")="command.exec"
	IF $GET(CONF("miomos","desktop","transport","resultEvent"))="" SET CONF("miomos","desktop","transport","resultEvent")="command.result"
	IF $GET(CONF("miomos","desktop","transport","errorEvent"))="" SET CONF("miomos","desktop","transport","errorEvent")="command.error"
	IF $GET(CONF("miomos","desktop","policy","commandMaxInflight"))="" SET CONF("miomos","desktop","policy","commandMaxInflight")=3
	IF $GET(CONF("miomos","desktop","policy","commandTimeoutMs"))="" SET CONF("miomos","desktop","policy","commandTimeoutMs")=8000
	IF $GET(CONF("miomos","wm","defaultPreset"))="" SET CONF("miomos","wm","defaultPreset")="analyst"
	IF $GET(CONF("miomos","wm","defaultSnapMode"))="" SET CONF("miomos","wm","defaultSnapMode")="quadrant"
	IF $GET(CONF("miomos","wm","defaultMotionProfile"))="" SET CONF("miomos","wm","defaultMotionProfile")="standard"
	IF $GET(CONF("miomos","wm","defaultTitlebarStyle"))="" SET CONF("miomos","wm","defaultTitlebarStyle")="accent"
	IF $GET(CONF("miomos","theme","default"))="" SET CONF("miomos","theme","default")="midnight-professional"
	IF $GET(CONF("miomos","theme","allowSelfService"))="" SET CONF("miomos","theme","allowSelfService")=1
	IF $GET(CONF("miomos","settings","default","fontFamily"))="" SET CONF("miomos","settings","default","fontFamily")="Segoe UI"
	IF $GET(CONF("miomos","settings","default","fontSize"))="" SET CONF("miomos","settings","default","fontSize")=13
	IF $GET(CONF("miomos","settings","default","titleAccent"))="" SET CONF("miomos","settings","default","titleAccent")="theme"
	IF $GET(CONF("miomos","settings","default","iconStyle"))="" SET CONF("miomos","settings","default","iconStyle")="glass"
	IF $GET(CONF("miomos","settings","default","animations"))="" SET CONF("miomos","settings","default","animations")="standard"
	IF $GET(CONF("miomos","terminal","enabled"))="" SET CONF("miomos","terminal","enabled")=1
	IF $GET(CONF("miomos","terminal","pipe","enabled"))="" SET CONF("miomos","terminal","pipe","enabled")=1
	IF $GET(CONF("miomos","terminal","pipe","command"))="" SET CONF("miomos","terminal","pipe","command")="yottadb -direct"
	IF $GET(CONF("miomos","terminal","pipe","shell"))="" SET CONF("miomos","terminal","pipe","shell")="/bin/sh"
	IF $GET(CONF("miomos","terminal","pipe","independent"))="" SET CONF("miomos","terminal","pipe","independent")=0
	IF $GET(CONF("miomos","terminal","pipe","readLimit"))="" SET CONF("miomos","terminal","pipe","readLimit")=16384
	IF $GET(CONF("miomos","terminal","pipe","readPolls"))="" SET CONF("miomos","terminal","pipe","readPolls")=8
	IF $GET(CONF("miomos","terminal","pipe","drainPause"))="" SET CONF("miomos","terminal","pipe","drainPause")=.04
	IF $GET(CONF("miomos","terminal","pipe","sessionIdleSeconds"))="" SET CONF("miomos","terminal","pipe","sessionIdleSeconds")=900
	IF $GET(CONF("miomos","terminal","default","fontFamily"))="" SET CONF("miomos","terminal","default","fontFamily")="JetBrains Mono"
	IF $GET(CONF("miomos","terminal","default","fontSize"))="" SET CONF("miomos","terminal","default","fontSize")=13
	IF $GET(CONF("miomos","terminal","default","cursorBlink"))="" SET CONF("miomos","terminal","default","cursorBlink")=1
	IF $GET(CONF("miomos","terminal","default","cursorStyle"))="" SET CONF("miomos","terminal","default","cursorStyle")="block"
	IF $GET(CONF("miomos","terminal","default","scrollback"))="" SET CONF("miomos","terminal","default","scrollback")=3000
	IF $GET(CONF("miomos","terminal","default","palette"))="" SET CONF("miomos","terminal","default","palette")="midnight-blue"
	IF $GET(CONF("miomos","terminal","default","renderer"))="" SET CONF("miomos","terminal","default","renderer")="canvas"
	IF $GET(CONF("miomos","terminal","default","unicode"))="" SET CONF("miomos","terminal","default","unicode")="unicode11"
	IF $GET(CONF("miomos","terminal","default","rows"))="" SET CONF("miomos","terminal","default","rows")=28
	IF $GET(CONF("miomos","terminal","default","cols"))="" SET CONF("miomos","terminal","default","cols")=120
	IF $GET(CONF("miomos","session","idleTimeoutSeconds"))="" SET CONF("miomos","session","idleTimeoutSeconds")=900
	IF $GET(CONF("miomos","session","absoluteTimeoutSeconds"))="" SET CONF("miomos","session","absoluteTimeoutSeconds")=28800
	IF $GET(CONF("miomos","security","sessionBinding"))="" SET CONF("miomos","security","sessionBinding")="principal-and-session"
	IF $GET(CONF("miomos","security","forcedSignoutEvent"))="" SET CONF("miomos","security","forcedSignoutEvent")="session.signout"
	IF $GET(CONF("miomos","security","permissionDeniedEvent"))="" SET CONF("miomos","security","permissionDeniedEvent")="command.error"
	IF $GET(CONF("miomos","security","idleLockEnabled"))="" SET CONF("miomos","security","idleLockEnabled")=1
	IF $GET(CONF("miomos","security","idleLockSeconds"))="" SET CONF("miomos","security","idleLockSeconds")=300
	IF $GET(CONF("miomos","security","sessionRegistryEnabled"))="" SET CONF("miomos","security","sessionRegistryEnabled")=1
	IF $GET(CONF("miomos","security","sessionRegistryModel"))="" SET CONF("miomos","security","sessionRegistryModel")="server-authored"
	IF $GET(CONF("miomos","dev","enabled"))="" SET CONF("miomos","dev","enabled")=ISDEV
	IF $GET(CONF("miomos","dev","authDisabled"))="" SET CONF("miomos","dev","authDisabled")=ISDEV
	IF $GET(CONF("miomos","dev","principal"))="" SET CONF("miomos","dev","principal")="dev-user"
	IF $GET(CONF("miomos","dev","userName"))="" SET CONF("miomos","dev","userName")="Developer"
	IF $GET(CONF("miomos","dev","roles"))="" SET CONF("miomos","dev","roles")="developer,admin"
	IF $GET(CONF("miomos","localAuth","enabled"))="" SET CONF("miomos","localAuth","enabled")=0
	IF $GET(CONF("miomos","localAuth","allowSignup"))="" SET CONF("miomos","localAuth","allowSignup")=1
	IF $GET(CONF("miomos","localAuth","inviteOnly"))="" SET CONF("miomos","localAuth","inviteOnly")=0
	IF $GET(CONF("miomos","localAuth","inviteTokenDays"))="" SET CONF("miomos","localAuth","inviteTokenDays")=7
	IF $GET(CONF("miomos","localAuth","tokenCookie"))="" SET CONF("miomos","localAuth","tokenCookie")="miomos_auth"
	IF $GET(CONF("miomos","localAuth","tokenMaxAgeSeconds"))="" SET CONF("miomos","localAuth","tokenMaxAgeSeconds")=604800
	IF $GET(CONF("miomos","localAuth","resetTokenSeconds"))="" SET CONF("miomos","localAuth","resetTokenSeconds")=3600
	IF $GET(CONF("miomos","localAuth","lockThreshold"))="" SET CONF("miomos","localAuth","lockThreshold")=5
	IF $GET(CONF("miomos","localAuth","lockMinutes"))="" SET CONF("miomos","localAuth","lockMinutes")=15
	IF $GET(CONF("miomos","localAuth","guestLoginEnabled"))="" SET CONF("miomos","localAuth","guestLoginEnabled")=1
	IF $GET(CONF("miomos","bootstrapAuth","enabled"))="" SET CONF("miomos","bootstrapAuth","enabled")=1
	IF $GET(CONF("miomos","bootstrapAuth","seedIfMissing"))="" SET CONF("miomos","bootstrapAuth","seedIfMissing")=1
	IF $GET(CONF("miomos","bootstrapAuth","syncOnBoot"))="" SET CONF("miomos","bootstrapAuth","syncOnBoot")=1
	IF $GET(CONF("miomos","bootstrapAuth","showSeededCredentials"))="" SET CONF("miomos","bootstrapAuth","showSeededCredentials")=1
	IF $GET(CONF("miomos","bootstrapAuth","admin","username"))="" SET CONF("miomos","bootstrapAuth","admin","username")="admin"
	IF $GET(CONF("miomos","bootstrapAuth","admin","displayName"))="" SET CONF("miomos","bootstrapAuth","admin","displayName")="Administrator"
	IF $GET(CONF("miomos","bootstrapAuth","admin","password"))="" SET CONF("miomos","bootstrapAuth","admin","password")="admin123!"
	IF $GET(CONF("miomos","bootstrapAuth","admin","roles"))="" SET CONF("miomos","bootstrapAuth","admin","roles")="admin"
	IF $GET(CONF("miomos","bootstrapAuth","admin","enabled"))="" SET CONF("miomos","bootstrapAuth","admin","enabled")=1
	IF $GET(CONF("miomos","bootstrapAuth","user","username"))="" SET CONF("miomos","bootstrapAuth","user","username")="user"
	IF $GET(CONF("miomos","bootstrapAuth","user","displayName"))="" SET CONF("miomos","bootstrapAuth","user","displayName")="User"
	IF $GET(CONF("miomos","bootstrapAuth","user","password"))="" SET CONF("miomos","bootstrapAuth","user","password")="user123!"
	IF $GET(CONF("miomos","bootstrapAuth","user","roles"))="" SET CONF("miomos","bootstrapAuth","user","roles")="operator"
	IF $GET(CONF("miomos","bootstrapAuth","user","enabled"))="" SET CONF("miomos","bootstrapAuth","user","enabled")=1
	IF $GET(CONF("miomos","bootstrapAuth","guest","username"))="" SET CONF("miomos","bootstrapAuth","guest","username")="guest"
	IF $GET(CONF("miomos","bootstrapAuth","guest","displayName"))="" SET CONF("miomos","bootstrapAuth","guest","displayName")="Guest"
	IF $GET(CONF("miomos","bootstrapAuth","guest","password"))="" SET CONF("miomos","bootstrapAuth","guest","password")="guest123!"
	IF $GET(CONF("miomos","bootstrapAuth","guest","roles"))="" SET CONF("miomos","bootstrapAuth","guest","roles")="guest"
	IF $GET(CONF("miomos","bootstrapAuth","guest","enabled"))="" SET CONF("miomos","bootstrapAuth","guest","enabled")=1
	IF $GET(CONF("miomos","chat","enabled"))="" SET CONF("miomos","chat","enabled")=1
	IF $GET(CONF("miomos","chat","defaultRoom"))="" SET CONF("miomos","chat","defaultRoom")="general"
	IF $GET(CONF("miomos","chat","messageLimit"))="" SET CONF("miomos","chat","messageLimit")=20
	IF $GET(CONF("miomos","log","access","enabled"))="" SET CONF("miomos","log","access","enabled")=1
	IF $GET(CONF("miomos","log","error","enabled"))="" SET CONF("miomos","log","error","enabled")=1
	IF $GET(CONF("miomos","log","maxEntries"))="" SET CONF("miomos","log","maxEntries")=500
	IF $GET(CONF("miomos","log","exportLimit"))="" SET CONF("miomos","log","exportLimit")=250
	IF $GET(CONF("miomos","log","digestTail"))="" SET CONF("miomos","log","digestTail")=6
	IF $GET(CONF("miomos","log","access","retainDays"))="" SET CONF("miomos","log","access","retainDays")=30
	IF $GET(CONF("miomos","log","error","retainDays"))="" SET CONF("miomos","log","error","retainDays")=90
	IF $GET(CONF("miomos","audit","retainDays"))="" SET CONF("miomos","audit","retainDays")=180
	IF $GET(CONF("miomos","websocket","observability","registryEnabled"))="" SET CONF("miomos","websocket","observability","registryEnabled")=1
	IF $GET(CONF("miomos","websocket","observability","tailLimit"))="" SET CONF("miomos","websocket","observability","tailLimit")=12
	IF $GET(CONF("miomos","websocket","observability","controlModel"))="" SET CONF("miomos","websocket","observability","controlModel")="inspect-only"
	IF $GET(CONF("miomos","release","model"))="" SET CONF("miomos","release","model")="test-runbook-checklist"
	IF $GET(CONF("miomos","release","tests","suite"))="" SET CONF("miomos","release","tests","suite")="^MIOMOST"
	IF $GET(CONF("miomos","release","tests","quietSuccess"))="" SET CONF("miomos","release","tests","quietSuccess")=1
	IF $GET(CONF("miomos","release","runbooks","deploy"))="" SET CONF("miomos","release","runbooks","deploy")="systemd-caddy-nginx"
	IF $GET(CONF("miomos","release","runbooks","restart"))="" SET CONF("miomos","release","runbooks","restart")="graceful-websocket-aware"
	IF $GET(CONF("miomos","release","runbooks","routeRebuild"))="" SET CONF("miomos","release","runbooks","routeRebuild")="REG^MIOMOS+COMPILE^MIOROUTE"
	IF $GET(CONF("miomos","release","docsCurrent"))="" SET CONF("miomos","release","docsCurrent")=1
	IF $GET(CONF("server","templateDir"))="" SET CONF("server","templateDir")="templates"
	IF $GET(CONF("templates","root"))="" SET CONF("templates","root")=$GET(CONF("server","templateDir"))_"/"
	IF $GET(CONF("templates","ext"))="" SET CONF("templates","ext")=""
	DO BOOTSTRAP^MIOMOSAUTH(.CONF)
	QUIT
	;
INIT(CONF)
	SET CONF("miomos","profile")="prod"
	SET CONF("miomos","localAuth","enabled")=1
	SET CONF("miomos","dev","authDisabled")=0
	SET CONF("miomos","bootstrapAuth","showSeededCredentials")=1
	;
	SET CONF("miomos","bootstrapAuth","admin","username")="admin"
	SET CONF("miomos","bootstrapAuth","admin","password")="admin123!"
	SET CONF("miomos","bootstrapAuth","user","username")="user"
	SET CONF("miomos","bootstrapAuth","user","password")="user123!"
	SET CONF("miomos","bootstrapAuth","guest","username")="guest"
	SET CONF("miomos","bootstrapAuth","guest","password")="guest123!"
	;
	DO CONFDEF(.CONF)
	;
	QUIT
	;
REG(CONF)
	NEW EN,AUTHREQ,META,WSMETA
	DO INIT(.CONF)
	SET EN=+$GET(CONF("miomos","enabled"),1)
	IF EN'=1 QUIT
	IF $$DEVAUTHOFF(.CONF)!$$LOCALAUTHEN(.CONF) DO DEVEXEMPT(.CONF)
	IF '$$DEVAUTHOFF(.CONF),'$$LOCALAUTHEN(.CONF) DO ADDPROTECT(.CONF,$GET(CONF("miomos","route","desktop")))
	SET AUTHREQ=$SELECT($$DEVAUTHOFF(.CONF):0,$$LOCALAUTHEN(.CONF):0,1:1)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("miomos","route","desktop")),"DESKTOP^MIOMOS",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("miomos","route","bootstrap")),"BOOTSTRAP^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("POST",$GET(CONF("miomos","route","theme")),"SETTHEME^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("miomos","route","settings")),"GETSETTINGS^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("POST",$GET(CONF("miomos","route","settings")),"SAVESETTINGS^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("miomos","route","view")),"VIEW^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("POST",$GET(CONF("miomos","route","command")),"COMMAND^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=0
	DO ADDM^MIOROUTE("POST",$GET(CONF("miomos","route","signin")),"SIGNIN^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=0
	DO ADDM^MIOROUTE("POST",$GET(CONF("miomos","route","signup")),"SIGNUP^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=0
	DO ADDM^MIOROUTE("POST",$GET(CONF("miomos","route","signout")),"SIGNOUT^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=0
	DO ADDM^MIOROUTE("POST",$GET(CONF("miomos","route","guestSignin")),"GUESTSIGNIN^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=0
	DO ADDM^MIOROUTE("POST",$GET(CONF("miomos","route","resetApply")),"RESETAPPLY^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("miomos","route","adminUsers")),"ADMINUSERS^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("POST",$GET(CONF("miomos","route","adminDisable")),"ADMINDISABLE^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("POST",$GET(CONF("miomos","route","adminEnable")),"ADMINENABLE^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("POST",$GET(CONF("miomos","route","adminLock")),"ADMINLOCK^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("POST",$GET(CONF("miomos","route","adminUnlock")),"ADMINUNLOCK^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("POST",$GET(CONF("miomos","route","adminInviteCreate")),"ADMININVITE^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("miomos","route","adminInvites")),"ADMININVITES^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("POST",$GET(CONF("miomos","route","adminResetRequest")),"ADMINRESETREQUEST^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("POST",$GET(CONF("miomos","route","adminUserRoles")),"ADMINUSERROLES^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("POST",$GET(CONF("miomos","route","adminGuestToggle")),"ADMINGUESTTOGGLE^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("miomos","route","adminReports")),"ADMINREPORTS^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("miomos","route","observSummary")),"OBSSUMMARY^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("miomos","route","accessExport")),"ACCESSX^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("miomos","route","errorExport")),"ERRORX^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("miomos","route","auditExport")),"AUDITX^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("GET",$GET(CONF("miomos","route","securityDigest")),"DIGEST^MIOMOSAPI",.META)
	KILL META SET META("authRequired")=AUTHREQ
	DO ADDM^MIOROUTE("POST",$GET(CONF("miomos","route","retentionPrune")),"PRUNERET^MIOMOSAPI",.META)
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
LOCALAUTHEN(CONF)
	QUIT +$GET(CONF("miomos","localAuth","enabled"),0)
	;
DEVEXEMPT(CONF)
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","desktop")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","bootstrap")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","theme")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","settings")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","view")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","command")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","ws")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","signin")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","signup")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","signout")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","guestSignin")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","resetApply")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","adminUsers")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","adminDisable")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","adminEnable")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","adminLock")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","adminUnlock")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","adminInviteCreate")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","adminInvites")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","adminResetRequest")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","adminUserRoles")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","adminGuestToggle")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","adminReports")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","observSummary")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","accessExport")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","errorExport")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","auditExport")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","securityDigest")))
	DO ADDEXEMPT(.CONF,$GET(CONF("miomos","route","retentionPrune")))
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
	. IF $GET(ERR("error"))="login_required" DO  QUIT
	. . DO AUTHCTX^MIOMOSUI(.CONF,.DATA)
	. . IF '$$RENDERPAGE^MIOTPL("pages/miomos_auth.html","layouts/miomos_shell.html",.CONF,.DATA,.OUT,.ERR) DO  QUIT
	. . . DO RESPERR(.DEV,.CONF,500,"template_error",$GET(ERR("error")),.CTX)
	. . SET HEAD("Content-Type")="text/html; charset=utf-8"
	. . DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,OUT,$GET(CTX("request_id")),.CTX)
	. . SET CTX("status")=200
	. . DO ACCESS^MIOMOSOBS("desktop_auth_gate",.CTX,.STATE)
	. DO ERROR^MIOMOSOBS("desktop_session_error",$GET(ERR("error")),.CTX,.STATE,$GET(ERR("error")))
	. DO RESPERR(.DEV,.CONF,500,"session_error",$GET(ERR("error")),.CTX)
	DO DESKCTX^MIOMOSUI(.STATE,.CONF,.DATA)
	IF '$$RENDERPAGE^MIOTPL("pages/miomos_desktop.html","layouts/miomos_shell.html",.CONF,.DATA,.OUT,.ERR) DO  QUIT
	. DO ERROR^MIOMOSOBS("desktop_template_error",$GET(ERR("error")),.CTX,.STATE,$GET(ERR("error")))
	. DO RESPERR(.DEV,.CONF,500,"template_error",$GET(ERR("error")),.CTX)
	SET HEAD("Content-Type")="text/html; charset=utf-8"
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	DO EVENT^MIOMOSAUD("desktop_render",.CTX,.STATE)
	DO ACCESS^MIOMOSOBS("desktop_render",.CTX,.STATE)
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
	;