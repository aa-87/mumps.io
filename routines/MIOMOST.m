MIOMOST ; MIOMOS ROI 10 smoke tests
START
	NEW CONF,REQ,CTX,OUT,ERR,STATE,OBJ,TOKEN,INVITE,RESET,ARR,WCTX,TERMID
	KILL ^MIO("MIOMOS"),^MIO("ROUTE")
	SET CONF("auth","enabled")=0
	DO CONFDEF^MIOMOS(.CONF)
	DO START^MIOTPL(.CONF)
	DO INIT^MIOROUTE
	DO REG^MIOMOS(.CONF)
	DO COMPILE^MIOROUTE
	;
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","GET","/api/miomos/admin/users","authRequired")),0,"[MIOMOST][T001][admin users auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","POST","/api/miomos/admin/invites/create","authRequired")),0,"[MIOMOST][T001][invite auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","POST","/api/miomos/auth/reset","authRequired")),0,"[MIOMOST][T001][reset auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","POST","/api/miomos/auth/guest","authRequired")),0,"[MIOMOST][T001][guest auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","GET","/api/miomos/settings","authRequired")),0,"[MIOMOST][T001][settings get auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","GET","/api/miomos/view","authRequired")),0,"[MIOMOST][T001][view auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","POST","/api/miomos/command","authRequired")),0,"[MIOMOST][T001][command auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","POST","/api/miomos/settings","authRequired")),0,"[MIOMOST][T001][settings post auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","GET","/api/miomos/observability/summary","authRequired")),0,"[MIOMOST][T001][observ summary auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","GET","/api/miomos/observability/access/export","authRequired")),0,"[MIOMOST][T001][access export auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","POST","/api/miomos/observability/retention/prune","authRequired")),0,"[MIOMOST][T001][retention prune auth]")
	;
	KILL REQ,CTX,STATE,ERR
	SET CTX("request_id")="miomost-rid"
	DO OK^MIOTASSERT($$ENSURE^MIOMOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOMOST][T002][ensure]")
	DO EQ^MIOTASSERT($GET(STATE("userName")),"Developer","[MIOMOST][T002][user]")
	DO EQ^MIOTASSERT($GET(STATE("profile")),"dev","[MIOMOST][T002][profile]")
	DO EQ^MIOTASSERT($GET(STATE("inviteOnly")),0,"[MIOMOST][T002][invite off]")
	;
	KILL OUT,ERR,CTX
	DO DESKCTX^MIOMOSUI(.STATE,.CONF,.CTX)
	DO OK^MIOTASSERT($$RENDERPAGE^MIOTPL("pages/miomos_desktop.html","layouts/miomos_shell.html",.CONF,.CTX,.OUT,.ERR),"[MIOMOST][T003][render]")
	DO OK^MIOTASSERT(OUT["data-admin-surface","[MIOMOST][T003][admin surface]")
	DO OK^MIOTASSERT(OUT["Identity hardening and admin operations","[MIOMOST][T003][admin copy]")
	DO OK^MIOTASSERT(OUT["/api/miomos/admin/users","[MIOMOST][T003][admin route]")
	DO OK^MIOTASSERT(OUT["Summary JSON","[MIOMOST][T003][obs export]")
	DO OK^MIOTASSERT(OUT["data-miomos-single-socket=""1""","[MIOMOST][T003][single socket]")
	DO OK^MIOTASSERT(OUT["data-miomos-command-transport=""websocket-only""","[MIOMOST][T003][ws command token]")
	DO OK^MIOTASSERT(OUT["data-miomos-command-event=""command.exec""","[MIOMOST][T003][ws command event]")
	DO OK^MIOTASSERT(OUT["data-miomos-realtime-contract=""single-websocket-command-and-events""","[MIOMOST][T003][ws realtime token]")
	DO OK^MIOTASSERT(OUT["data-miomos-ws-observability=""session-connection-registry""","[MIOMOST][T003][ws observability token]")
	DO OK^MIOTASSERT(OUT["data-miomos-release-gates=""test-runbook-checklist""","[MIOMOST][T003][release gates token]")
	DO OK^MIOTASSERT(OUT["data-miomos-deploy-runbook=""systemd-caddy-nginx""","[MIOMOST][T003][deploy runbook token]")
	DO OK^MIOTASSERT(OUT["data-miomos-route-rebuild=""REG^MIOMOS+COMPILE^MIOROUTE""","[MIOMOST][T003][route rebuild token]")
	DO OK^MIOTASSERT(OUT["data-miomos-ws-smoke=""hello-ping-command-terminal""","[MIOMOST][T003][ws smoke token]")
	DO OK^MIOTASSERT(OUT["data-miomos-browser-checklist=""start-theme-terminal-reconnect""","[MIOMOST][T003][browser checklist token]")
	DO OK^MIOTASSERT(OUT["data-miomos-session-binding=""principal-and-session""","[MIOMOST][T003][session binding token]")
	DO OK^MIOTASSERT(OUT["data-miomos-idle-lock=""server-authored-idle-lock""","[MIOMOST][T003][idle lock token]")
	DO OK^MIOTASSERT(OUT["data-miomos-session-registry=""1""","[MIOMOST][T003][session registry token]")
	DO OK^MIOTASSERT(OUT["data-ws-registry-surface=""1""","[MIOMOST][T003][ws registry token]")
	DO OK^MIOTASSERT(OUT["All live shell communication now goes through the primary websocket session.","[MIOMOST][T003][ws shell copy]")
	DO OK^MIOTASSERT(OUT["data-settings-form","[MIOMOST][T003][settings surface]")
	DO OK^MIOTASSERT(OUT["data-miomos-command=""/api/miomos/command""","[MIOMOST][T003][command route]")
	DO OK^MIOTASSERT(OUT["id=""miomosBootJson""","[MIOMOST][T003][boot json]")
	DO OK^MIOTASSERT(OUT["data-terminal-surface","[MIOMOST][T003][terminal surface]")
	DO OK^MIOTASSERT(OUT["data-terminal-engine=""xtermjs""","[MIOMOST][T003][terminal engine]")
	DO OK^MIOTASSERT(OUT["data-terminal-renderer=""xtermjs""","[MIOMOST][T003][terminal renderer]")
	DO OK^MIOTASSERT(OUT["miomosTerminalViewport","[MIOMOST][T003][terminal viewport]")
	DO OK^MIOTASSERT(OUT["data-setting-terminal=""fontFamily""","[MIOMOST][T003][terminal settings]")
	DO OK^MIOTASSERT(OUT["data-setting-terminal=""palette""","[MIOMOST][T003][terminal palette setting]")
	DO OK^MIOTASSERT(OUT["data-terminal-clear=""xterm-buffer""","[MIOMOST][T003][terminal clear action]")
	DO OK^MIOTASSERT(OUT["data-launch-app=""terminal""","[MIOMOST][T003][terminal app]")
	DO OK^MIOTASSERT(OUT["data-terminal-window-mode=""multi-window-launch""","[MIOMOST][T003][terminal window mode]")
	DO OK^MIOTASSERT(OUT["data-terminal-launch-behavior=""new-window-per-launch""","[MIOMOST][T003][terminal launch behavior]")
	DO OK^MIOTASSERT(OUT["data-entry-kind=""directory""","[MIOMOST][T003][directory entry]")
	DO OK^MIOTASSERT(OUT["data-entry-kind=""future""","[MIOMOST][T003][future entry]")
	DO OK^MIOTASSERT(OUT["data-mobile-ready=""1""","[MIOMOST][T003][mobile ready]")
	DO OK^MIOTASSERT(OUT["data-window-fade=""off""","[MIOMOST][T003][window fade off]")
	DO OK^MIOTASSERT(OUT["Mobile-friendly render prep","[MIOMOST][T003][mobile ui copy]")
	DO OK^MIOTASSERT(OUT["data-miomos-native-shell=""1""","[MIOMOST][T003][native shell token]")
	DO OK^MIOTASSERT(OUT["data-shell-chrome=""winxp""","[MIOMOST][T003][xp shell token]")
	DO OK^MIOTASSERT(OUT["data-start-menu-style=""winxp""","[MIOMOST][T003][xp start token]")
	DO OK^MIOTASSERT(OUT["Windows XP inspired shell chrome","[MIOMOST][T003][xp shell copy]")
	DO OK^MIOTASSERT(OUT["data-taskbar-style=""xp-plus-tray""","[MIOMOST][T003][xp taskbar token]")
	DO OK^MIOTASSERT(OUT["data-tray-style=""xp-notify-area""","[MIOMOST][T003][xp tray token]")
	DO OK^MIOTASSERT(OUT["data-shell-dialogs=""xp""","[MIOMOST][T003][xp dialog token]")
	DO OK^MIOTASSERT(OUT["Quick Launch","[MIOMOST][T003][quick launch copy]")
	DO OK^MIOTASSERT(OUT["data-task-order=""stable""","[MIOMOST][T003][task order token]")
	DO OK^MIOTASSERT(OUT["data-start-menu-behavior=""predictable""","[MIOMOST][T003][start behavior token]")
	DO OK^MIOTASSERT(OUT["data-start-search=""1""","[MIOMOST][T003][start search token]")
	DO OK^MIOTASSERT(OUT["data-taskbar-overflow=""1""","[MIOMOST][T003][overflow token]")
	DO OK^MIOTASSERT(OUT["data-keyboard-model=""ctrl-escape-enter-search""","[MIOMOST][T003][keyboard token]")
	DO OK^MIOTASSERT(OUT["Taskbar order stays stable while focus changes.","[MIOMOST][T003][task order copy]")
	DO OK^MIOTASSERT(OUT["Start search filters programs and shell actions.","[MIOMOST][T003][start search copy]")
	DO OK^MIOTASSERT(OUT["Overflow windows move into a More Windows list without changing taskbar order.","[MIOMOST][T003][overflow copy]")
	DO OK^MIOTASSERT(OUT["Ctrl+Escape opens Start and Enter launches the first search result.","[MIOMOST][T003][keyboard copy]")
	DO OK^MIOTASSERT(OUT["More Windows","[MIOMOST][T003][overflow label]")
	DO OK^MIOTASSERT(OUT["data-task-click-policy=""xp-toggle""","[MIOMOST][T003][task click token]")
	DO OK^MIOTASSERT(OUT["data-shell-surface-policy=""single-open-surface""","[MIOMOST][T003][surface policy token]")
	DO OK^MIOTASSERT(OUT["Clicking a task button toggles minimize or restore without shuffling neighboring items.","[MIOMOST][T003][task click copy]")
	DO OK^MIOTASSERT(OUT["Turn Off Computer","[MIOMOST][T003][power dialog copy]")
	DO OK^MIOTASSERT(OUT["data-shell-dialog-drag=""1""","[MIOMOST][T003][dialog drag token]")
	DO OK^MIOTASSERT(OUT["data-desktop-folder-create=""1""","[MIOMOST][T003][folder create token]")
	DO OK^MIOTASSERT(OUT["data-desktop-icons-draggable=""1""","[MIOMOST][T003][icon drag token]")
	DO OK^MIOTASSERT(OUT["data-desktop-curation=""ui-samples-settings-terminal""","[MIOMOST][T003][desktop curation token]")
	DO OK^MIOTASSERT(OUT["data-xp-folder-view=""1""","[MIOMOST][T003][xp folder view token]")
	DO OK^MIOTASSERT(OUT["data-explorer-view-switcher=""1""","[MIOMOST][T003][explorer view switcher token]")
	DO OK^MIOTASSERT(OUT["data-explorer-large-icons=""1""","[MIOMOST][T003][explorer large icons token]")
	DO OK^MIOTASSERT(OUT["data-explorer-draggable=""1""","[MIOMOST][T003][explorer draggable token]")
	DO OK^MIOTASSERT(OUT["data-explorer-sortable=""1""","[MIOMOST][T003][explorer sortable token]")
	DO OK^MIOTASSERT(OUT["data-explorer-view-option=""details""","[MIOMOST][T003][explorer details view token]")
	DO OK^MIOTASSERT(OUT["data-explorer-view-option=""large-icons""","[MIOMOST][T003][explorer large view option]")
	DO OK^MIOTASSERT(OUT["UI Samples","[MIOMOST][T003][ui samples copy]")
	DO EQ^MIOTASSERT(OUT["@osjs/client",0,"[MIOMOST][T003][osjs removed]")
	;
	KILL OBJ
	DO BOOTARY^MIOMOSST(.STATE,.CONF,.OBJ)
	DO EQ^MIOTASSERT($GET(OBJ("product","version")),"roi35-websocket-shell-bus","[MIOMOST][T004][version]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","engine")),"miomos-native-vue-css","[MIOMOST][T004][engine]")
	DO EQ^MIOTASSERT(+$GET(OBJ("desktop","nativeShell")),1,"[MIOMOST][T004][native shell]")
	DO EQ^MIOTASSERT(+$GET(OBJ("desktop","osjsEnabled")),0,"[MIOMOST][T004][osjs off]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","shellChrome")),"winxp-inspired","[MIOMOST][T004][shell chrome]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","contextMenuStyle")),"winxp","[MIOMOST][T004][context chrome]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","contextMenuStatefulness")),"window-aware","[MIOMOST][T004][context stateful]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","taskbarStyle")),"xp-plus-tray","[MIOMOST][T004][taskbar chrome]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","taskbarBehavior")),"stable-order","[MIOMOST][T004][taskbar behavior]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","taskbarFocusPolicy")),"focus-without-reorder","[MIOMOST][T004][taskbar focus policy]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","taskbarOverflowBehavior")),"preserve-order-and-overflow","[MIOMOST][T004][overflow behavior]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","startSearchBehavior")),"filter-programs-and-actions","[MIOMOST][T004][start search behavior]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","keyboardModel")),"ctrl-escape-enter-search","[MIOMOST][T004][keyboard model]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","taskbarClickPolicy")),"xp-toggle","[MIOMOST][T004][task click policy]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","shellSurfacePolicy")),"single-open-surface","[MIOMOST][T004][shell surface policy]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","trayStyle")),"xp-notify-area","[MIOMOST][T004][tray chrome]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","dialogStyle")),"xp-shell-classic","[MIOMOST][T004][dialog chrome]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","dialogBehavior")),"draggable-shell-dialogs","[MIOMOST][T004][dialog behavior]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","folderCreateBehavior")),"desktop-context-menu","[MIOMOST][T004][folder create behavior]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","desktopIconBehavior")),"draggable-autosave","[MIOMOST][T004][icon behavior]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","desktopComposition")),"ui-samples-settings-terminal","[MIOMOST][T004][desktop composition]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","explorerStyle")),"winxp-shell-folder","[MIOMOST][T004][explorer style]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","explorerDefaultView")),"large-icons","[MIOMOST][T004][explorer default view]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","explorerSortModel")),"name-size-type-modified","[MIOMOST][T004][explorer sort model]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","explorerLayoutBehavior")),"manual-drag-with-arrange-icons","[MIOMOST][T004][explorer layout behavior]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","mutationSaveBehavior")),"layout-on-shell-mutation","[MIOMOST][T004][mutation save behavior]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","startMenuBehavior")),"predictable-sections","[MIOMOST][T004][start behavior]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","adminUsers")),"/api/miomos/admin/users","[MIOMOST][T004][admin users route]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","settings")),"/api/miomos/settings","[MIOMOST][T004][settings route]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","view")),"/api/miomos/view","[MIOMOST][T004][view route]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","command")),"/api/miomos/command","[MIOMOST][T004][command route]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","commandEvent")),"command.exec","[MIOMOST][T004][command event]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","commandResultEvent")),"command.result","[MIOMOST][T004][command result event]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","signoutEvent")),"auth.signout","[MIOMOST][T004][signout event]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","guestSignin")),"/api/miomos/auth/guest","[MIOMOST][T004][guest signin route]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","accessExport")),"/api/miomos/observability/access/export","[MIOMOST][T004][access export route]")
	DO EQ^MIOTASSERT($GET(OBJ("observability","retention","accessDays")),30,"[MIOMOST][T004][access retain]")
	DO EQ^MIOTASSERT($GET(OBJ("observability","websocket","registryEnabled")),1,"[MIOMOST][T004][ws registry enabled]")
	DO EQ^MIOTASSERT($GET(OBJ("observability","websocket","model")),"session-connection-registry","[MIOMOST][T004][ws registry model]")
	DO EQ^MIOTASSERT($GET(OBJ("observability","websocket","controlModel")),"inspect-only","[MIOMOST][T004][ws control model]")
	DO EQ^MIOTASSERT($GET(OBJ("auth","inviteOnly")),0,"[MIOMOST][T004][invite only boot]")
	DO EQ^MIOTASSERT(+$GET(OBJ("auth","guestLoginEnabled")),1,"[MIOMOST][T004][guest login boot]")
	DO EQ^MIOTASSERT(+$GET(OBJ("auth","bootstrapEnabled")),1,"[MIOMOST][T004][bootstrap enabled boot]")
	DO EQ^MIOTASSERT($GET(OBJ("auth","seededUsers","guest","roles")),"guest","[MIOMOST][T004][guest role boot]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","fontFamily")),"Segoe UI","[MIOMOST][T004][font family]")
	DO EQ^MIOTASSERT(+$GET(OBJ("desktop","fontSize")),13,"[MIOMOST][T004][font size]")
	DO EQ^MIOTASSERT(+$DATA(OBJ("desktop","settings","catalog","themes",1,"key"))>0,1,"[MIOMOST][T004][settings catalog]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","commandTransport")),"websocket-only","[MIOMOST][T004][command transport]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","commandEvent")),"command.exec","[MIOMOST][T004][desktop command event]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","commandResultEvent")),"command.result","[MIOMOST][T004][desktop command result]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","realtimeContract")),"single-websocket-command-and-events","[MIOMOST][T004][realtime contract]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","signoutTransport")),"websocket-event","[MIOMOST][T004][signout transport]")
	DO EQ^MIOTASSERT($GET(OBJ("terminal","commandTransport")),"websocket-only","[MIOMOST][T004][terminal command transport]")
	DO EQ^MIOTASSERT($GET(OBJ("terminal","profile","fontFamily")),"Consolas","[MIOMOST][T004][terminal default font]")
	DO EQ^MIOTASSERT($GET(OBJ("terminal","profile","sizeMode")),"fit-container","[MIOMOST][T004][terminal size mode]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","policy","commandMaxInflight")),3,"[MIOMOST][T004][command max inflight]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","policy","commandTimeoutMs")),8000,"[MIOMOST][T004][command timeout]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","mobile","enabled")),1,"[MIOMOST][T004][mobile enabled]")
	DO EQ^MIOTASSERT(+$GET(OBJ("desktop","mobile","breakpoint")),900,"[MIOMOST][T004][mobile breakpoint]")
	DO EQ^MIOTASSERT(+$DATA(OBJ("desktop","settings","catalog","terminal","fonts",1,"key"))>0,1,"[MIOMOST][T004][terminal catalog]")
	DO EQ^MIOTASSERT($GET(OBJ("desktop","settings","catalog","terminal","palettes",1,"key")),"theme","[MIOMOST][T004][terminal palette catalog]")
	DO EQ^MIOTASSERT($GET(OBJ("apps",3,"key")),"ui-library","[MIOMOST][T004][ui library app key]")
	DO EQ^MIOTASSERT($GET(OBJ("apps",7,"key")),"terminal","[MIOMOST][T004][terminal app key]")
	DO EQ^MIOTASSERT($GET(OBJ("windows",6,"appKey")),"terminal","[MIOMOST][T004][terminal win key]")
	DO EQ^MIOTASSERT($GET(OBJ("apps",14,"key")),"ui-samples","[MIOMOST][T004][ui samples app key]")
	DO EQ^MIOTASSERT($GET(OBJ("windows",7,"appKey")),"ui-samples","[MIOMOST][T004][ui samples win key]")
	DO EQ^MIOTASSERT(+$DATA(OBJ("security","adminCounts","users"))>0,1,"[MIOMOST][T004][admin counts]")
	DO EQ^MIOTASSERT($GET(OBJ("security","sessionBinding")),"principal-and-session","[MIOMOST][T004][session binding]")
	DO EQ^MIOTASSERT($GET(OBJ("security","forcedSignoutEvent")),"session.signout","[MIOMOST][T004][forced signout event]")
	DO EQ^MIOTASSERT($GET(OBJ("security","permissionDeniedEvent")),"command.error","[MIOMOST][T004][permission denied event]")
	DO EQ^MIOTASSERT(+$GET(OBJ("security","idleLock","enabled")),1,"[MIOMOST][T004][idle lock enabled]")
	DO EQ^MIOTASSERT(+$GET(OBJ("security","idleLock","seconds")),300,"[MIOMOST][T004][idle lock seconds]")
	DO EQ^MIOTASSERT(+$GET(OBJ("security","sessionRegistry","enabled")),1,"[MIOMOST][T004][session registry enabled]")
	DO EQ^MIOTASSERT($GET(OBJ("security","sessionRegistry","model")),"server-authored","[MIOMOST][T004][session registry model]")
	DO EQ^MIOTASSERT($GET(OBJ("release","model")),"test-runbook-checklist","[MIOMOST][T004][release model]")
	DO EQ^MIOTASSERT($GET(OBJ("release","tests","suite")),"^MIOMOST","[MIOMOST][T004][release suite]")
	DO EQ^MIOTASSERT(+$GET(OBJ("release","tests","quietSuccess")),1,"[MIOMOST][T004][release quiet success]")
	DO EQ^MIOTASSERT($GET(OBJ("release","runbooks","deploy")),"systemd-caddy-nginx","[MIOMOST][T004][deploy runbook]")
	DO EQ^MIOTASSERT($GET(OBJ("release","runbooks","restart")),"graceful-websocket-aware","[MIOMOST][T004][restart runbook]")
	DO EQ^MIOTASSERT($GET(OBJ("release","runbooks","routeRebuild")),"REG^MIOMOS+COMPILE^MIOROUTE","[MIOMOST][T004][route rebuild runbook]")
	DO EQ^MIOTASSERT($GET(OBJ("release","smoke","websocket",4,"key")),"terminal","[MIOMOST][T004][release ws smoke]")
	DO EQ^MIOTASSERT($GET(OBJ("release","smoke","browser",3,"key")),"terminal-focus","[MIOMOST][T004][release browser smoke]")
	DO EQ^MIOTASSERT(+$GET(OBJ("release","docsCurrent")),1,"[MIOMOST][T004][release docs current]")
	;
	KILL CONF
	SET CONF("auth","enabled")=1
	SET CONF("miomos","profile")="prod"
	SET CONF("miomos","dev","enabled")=0
	SET CONF("miomos","dev","authDisabled")=0
	SET CONF("miomos","localAuth","enabled")=1
	SET CONF("miomos","localAuth","allowSignup")=1
	SET CONF("miomos","localAuth","inviteOnly")=1
	SET CONF("miomos","localAuth","lockThreshold")=2
	SET CONF("miomos","localAuth","lockMinutes")=15
	DO CONFDEF^MIOMOS(.CONF)
	KILL ERR,TOKEN
	DO EQ^MIOTASSERT($$SIGNUP^MIOMOSAUTH(.CONF,"phaseone","supersecret","Phase One Tester","operator",.TOKEN,.ERR),0,"[MIOMOST][T005][invite required]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"invite_required","[MIOMOST][T005][invite error]")
	DO OK^MIOTASSERT($$CREATEINVITE^MIOMOSAUTH(.CONF,"admin","operator","Phase invite",.INVITE,.ERR),"[MIOMOST][T005][invite create]")
	DO OK^MIOTASSERT($$SIGNUP^MIOMOSAUTH(.CONF,"phaseone","supersecret","Phase One Tester","",.TOKEN,.ERR,INVITE),"[MIOMOST][T005][signup invite]")
	DO OK^MIOTASSERT(INVITE'="","[MIOMOST][T005][invite token]")
	;
	DO EQ^MIOTASSERT($$SIGNIN^MIOMOSAUTH(.CONF,"phaseone","wrong-pass",.TOKEN,.ERR),0,"[MIOMOST][T006][signin fail one]")
	DO EQ^MIOTASSERT($$SIGNIN^MIOMOSAUTH(.CONF,"phaseone","wrong-pass",.TOKEN,.ERR),0,"[MIOMOST][T006][signin fail two]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"locked_account","[MIOMOST][T006][locked]")
	DO EQ^MIOTASSERT($$SIGNIN^MIOMOSAUTH(.CONF,"phaseone","supersecret",.TOKEN,.ERR),0,"[MIOMOST][T006][signin blocked]")
	DO OK^MIOTASSERT($$UNLOCK^MIOMOSAUTH("phaseone"),"[MIOMOST][T006][unlock]")
	DO OK^MIOTASSERT($$SIGNIN^MIOMOSAUTH(.CONF,"phaseone","supersecret",.TOKEN,.ERR),"[MIOMOST][T006][signin success]")
	;
	DO OK^MIOTASSERT($$REQUESTRESET^MIOMOSAUTH(.CONF,"admin","phaseone",.RESET,.ERR),"[MIOMOST][T007][reset request]")
	DO OK^MIOTASSERT($$APPLYRESET^MIOMOSAUTH(.CONF,RESET,"freshsecret",.ERR),"[MIOMOST][T007][reset apply]")
	DO OK^MIOTASSERT($$SIGNIN^MIOMOSAUTH(.CONF,"phaseone","freshsecret",.TOKEN,.ERR),"[MIOMOST][T007][signin after reset]")
	;
	DO OK^MIOTASSERT($$DISABLE^MIOMOSAUTH("phaseone"),"[MIOMOST][T008][disable]")
	DO EQ^MIOTASSERT($$SIGNIN^MIOMOSAUTH(.CONF,"phaseone","freshsecret",.TOKEN,.ERR),0,"[MIOMOST][T008][disabled signin]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"account_disabled","[MIOMOST][T008][disabled error]")
	DO OK^MIOTASSERT($$ENABLE^MIOMOSAUTH("phaseone"),"[MIOMOST][T008][enable]")
	DO OK^MIOTASSERT($$LOCK^MIOMOSAUTH(.CONF,"phaseone",5),"[MIOMOST][T008][lock manual]")
	DO EQ^MIOTASSERT($$SIGNIN^MIOMOSAUTH(.CONF,"phaseone","freshsecret",.TOKEN,.ERR),0,"[MIOMOST][T008][locked signin]")
	DO OK^MIOTASSERT($$UNLOCK^MIOMOSAUTH("phaseone"),"[MIOMOST][T008][unlock manual]")
	DO OK^MIOTASSERT($$SIGNIN^MIOMOSAUTH(.CONF,"phaseone","freshsecret",.TOKEN,.ERR),"[MIOMOST][T008][signin relogin]")
	;
	SET REQ("hdr","cookie")="miomos_auth="_TOKEN
	DO OK^MIOTASSERT($$LOADLOCAL^MIOMOSAUTH(.CONF,.REQ,.WCTX,.ERR),"[MIOMOST][T009][load local]")
	SET STATE("principal")="phaseone",STATE("roles")="developer",STATE("userName")="Phase One Tester",STATE("sessionId")="term-session-1",STATE("profile")="prod"
	DO LOAD^MIOMOSSET(.STATE,.CONF)
	DO EQ^MIOTASSERT($$HAS^MIOMOSPERM(.STATE,"admin.users.view"),1,"[MIOMOST][T009][perm view]")
	DO EQ^MIOTASSERT($$HAS^MIOMOSPERM(.STATE,"admin.reset.manage"),1,"[MIOMOST][T009][perm reset]")
	DO EQ^MIOTASSERT($$HAS^MIOMOSPERM(.STATE,"terminal.use"),1,"[MIOMOST][T009][perm terminal]")
	DO USERLIST^MIOMOSADMIN(10,.ARR)
	DO EQ^MIOTASSERT($$FINDUSR(.ARR,"phaseone")>0,1,"[MIOMOST][T009][user list]")
	DO COUNTS^MIOMOSADMIN(.ARR)
	DO EQ^MIOTASSERT(+$GET(ARR("users"))>0,1,"[MIOMOST][T009][admin counts]")
	DO EQ^MIOTASSERT($$HAS^MIOMOSPERM(.STATE,"logs.export"),1,"[MIOMOST][T009][perm logs export]")
	DO EQ^MIOTASSERT($$HAS^MIOMOSPERM(.STATE,"retention.manage"),1,"[MIOMOST][T009][perm retention]")
	DO EQ^MIOTASSERT($$HAS^MIOMOSPERM(.STATE,"settings.self"),1,"[MIOMOST][T009][perm settings]")
	KILL ARR,ERR
	SET ARR("themeKey")="clinical-blue",ARR("fontFamily")="Inter",ARR("fontSize")=14,ARR("titleAccent")="violet",ARR("iconStyle")="classic",ARR("wallpaper")="aurora-blue",ARR("density")="compact",ARR("animations")="off",ARR("icons","workspace")="WS",ARR("icons","terminal")="TR"
	SET ARR("terminal","fontFamily")="Fira Code",ARR("terminal","fontSize")=15,ARR("terminal","cursorStyle")="underline",ARR("terminal","cursorBlink")=0,ARR("terminal","palette")="black-on-white",ARR("terminal","renderer")="dom",ARR("terminal","unicode")="unicode11",ARR("terminal","scrollback")=5000,ARR("terminal","cols")=132,ARR("terminal","rows")=32
	DO OK^MIOTASSERT($$SAVE^MIOMOSSET("phaseone",.ARR,.OUT,.ERR),"[MIOMOST][T009][settings save]")
	DO EQ^MIOTASSERT($GET(OUT("current","themeKey")),"clinical-blue","[MIOMOST][T009][theme saved]")
	DO EQ^MIOTASSERT($GET(OUT("current","fontFamily")),"Inter","[MIOMOST][T009][font saved]")
	DO EQ^MIOTASSERT(+$GET(OUT("current","fontSize")),14,"[MIOMOST][T009][font size saved]")
	DO EQ^MIOTASSERT($GET(OUT("current","icon","workspace")),"WS","[MIOMOST][T009][icon saved]")
	DO EQ^MIOTASSERT($GET(OUT("current","icon","terminal")),"TR","[MIOMOST][T009][terminal icon saved]")
	DO EQ^MIOTASSERT($GET(OUT("current","terminal","fontFamily")),"Fira Code","[MIOMOST][T009][term font saved]")
	DO EQ^MIOTASSERT($GET(OUT("current","terminal","palette")),"black-on-white","[MIOMOST][T009][term palette saved]")
	DO EQ^MIOTASSERT(+$GET(OUT("current","terminal","cols")),132,"[MIOMOST][T009][term cols saved]")
	;
	KILL ARR,OUT,CTX
	SET CTX("request_id")="miomost-rid"
	DO ACCESS^MIOMOSOBS("export_probe",.CTX,.STATE)
	DO ERROR^MIOMOSOBS("error_probe","demo_code",.CTX,.STATE,"retention-probe")
	DO EVENTX^MIOMOSAUD("audit_probe",.CTX,.STATE,"digest-probe")
	DO SUMMARY^MIOMOSOBS(.STATE,.CONF,.OUT)
	DO EQ^MIOTASSERT(+$GET(OUT("counts","access"))>0,1,"[MIOMOST][T010][access count]")
	DO EQ^MIOTASSERT($GET(OUT("lastAccess","correlationId")),"miomost-rid","[MIOMOST][T010][correlation]")
	DO EXPORT^MIOMOSOBS("ERROR",10,.ARR)
	DO EQ^MIOTASSERT($GET(ARR(1,"event")),"error_probe","[MIOMOST][T010][error export]")
	DO EXPORT^MIOMOSAUD(10,.ARR)
	DO EQ^MIOTASSERT($GET(ARR(1,"event")),"audit_probe","[MIOMOST][T010][audit export]")
	;
	KILL OUT,ERR,ARR
	DO OK^MIOTASSERT($$OPEN^MIOMOSTERM(.STATE,.CONF,"",.OUT,.ERR),"[MIOMOST][T011][terminal open]")
	SET TERMID=$GET(OUT("terminalId"))
	DO EQ^MIOTASSERT(TERMID'="",1,"[MIOMOST][T011][terminal id]")
	DO EQ^MIOTASSERT(+$GET(OUT("profile","cols")),132,"[MIOMOST][T011][terminal profile cols]")
	DO EQ^MIOTASSERT($GET(OUT("profile","fontFamily")),"Fira Code","[MIOMOST][T011][terminal profile font]")
	DO OK^MIOTASSERT($$INPUT^MIOMOSTERM(.STATE,TERMID,"write 123,!",.OUT,.ERR),"[MIOMOST][T011][terminal write]")
	DO EQ^MIOTASSERT($$HASWRITE(.OUT,"123"),1,"[MIOMOST][T011][terminal output]")
	DO OK^MIOTASSERT($$RESIZE^MIOMOSTERM(.STATE,TERMID,132,32,.OUT,.ERR),"[MIOMOST][T011][terminal resize]")
	DO EQ^MIOTASSERT(+$GET(OUT("cols")),132,"[MIOMOST][T011][terminal cols]")
	DO OK^MIOTASSERT($$CLOSE^MIOMOSTERM(.STATE,TERMID,.OUT,.ERR),"[MIOMOST][T011][terminal close]")
	DO EQ^MIOTASSERT(+$GET(OUT("closed")),1,"[MIOMOST][T011][terminal closed]")
	;
	KILL ^MIO("MIOMOS","LOG","ACCESS"),^MIO("MIOMOS","LOG","ERROR"),^MIO("MIOMOS","AUDIT")
	SET CTX("request_id")="miomost-rid"
	DO ACCESS^MIOMOSOBS("keep_one",.CTX,.STATE)
	DO ACCESS^MIOMOSOBS("keep_two",.CTX,.STATE)
	DO ACCESS^MIOMOSOBS("drop_three",.CTX,.STATE)
	DO EVENTX^MIOMOSAUD("keep_audit_one",.CTX,.STATE,"")
	DO EVENTX^MIOMOSAUD("drop_audit_two",.CTX,.STATE,"")
	DO PRUNE^MIOMOSOBS("ACCESS",2,0,.OUT)
	DO EQ^MIOTASSERT($GET(OUT("removed")),1,"[MIOMOST][T012][access prune removed]")
	DO EXPORT^MIOMOSOBS("ACCESS",10,.ARR)
	DO EQ^MIOTASSERT($GET(ARR(1,"event")),"keep_two","[MIOMOST][T012][access prune oldest]")
	DO PRUNE^MIOMOSAUD(1,0,.OUT)
	DO EQ^MIOTASSERT($GET(OUT("removed")),1,"[MIOMOST][T012][audit prune removed]")
	;
	;
	NEW VM,TREE
	DO BUILD^MIOMOSVM(.STATE,.CONF,.VM)
	DO EQ^MIOTASSERT($GET(VM("workspace","headline")),"Production workspace","[MIOMOST][T013][workspace headline]")
	DO EQ^MIOTASSERT(+$DATA(VM("settings","catalog","themes",1,"key"))>0,1,"[MIOMOST][T013][settings catalog]")
	KILL TREE,OBJ,ERR
	SET TREE("command")="desktop.ping"
	DO OK^MIOTASSERT($$EXEC^MIOMOSCMD(.STATE,.CONF,.TREE,.OBJ,.ERR),"[MIOMOST][T013][command ping]")
	DO EQ^MIOTASSERT($GET(OBJ("pong")),1,"[MIOMOST][T013][pong]")
	KILL TREE,OBJ,ERR
	SET TREE("command")="layout.save",TREE("layoutJson")="{""layout"":{""windows"":[{""id"":""workspace""}]}}"
	DO OK^MIOTASSERT($$EXEC^MIOMOSCMD(.STATE,.CONF,.TREE,.OBJ,.ERR),"[MIOMOST][T013][layout save]")
	DO EQ^MIOTASSERT($GET(OBJ("saved")),1,"[MIOMOST][T013][layout saved]")
	DO OK^MIOTASSERT($$SAVEUIOK^MIOMOSST($GET(STATE("sessionId")),"{""menuOpen"":1,""startMenuSection"":""Applications"",""startMenuQuery"":""term""}"),"[MIOMOST][T013][ui save]")
	KILL ARR DO LOADUI^MIOMOSST($GET(STATE("sessionId")),.ARR)
	DO EQ^MIOTASSERT($GET(ARR("startMenuQuery")),"term","[MIOMOST][T013][ui start search]")
	;
	DO CURRENT^MIOMOSSET($GET(STATE("principal")),.ARR)
	DO EQ^MIOTASSERT(+$DATA(ARR("catalog","windowManager","windowPresets",1,"key"))>0,1,"[MIOMOST][T014][wm preset catalog]")
	DO EQ^MIOTASSERT(+$DATA(ARR("catalog","windowManager","motionProfiles",1,"key"))>0,1,"[MIOMOST][T014][wm motion catalog]")
	DO BUILD^MIOMOSVM(.STATE,.CONF,.VM)
	DO EQ^MIOTASSERT($GET(VM("terminal","transport")),"pipe","[MIOMOST][T014][terminal transport]")
	DO EQ^MIOTASSERT($GET(VM("terminal","commandTransport")),"websocket-only","[MIOMOST][T014][terminal command bus]")
	DO EQ^MIOTASSERT($GET(VM("uiLibrary","responsive",1,"title")),"Stacked shell under 900 px","[MIOMOST][T014][mobile section]")
	DO EQ^MIOTASSERT($GET(ARR("catalog","themes",6,"key")),"high-contrast-light","[MIOMOST][T014][high contrast light]")
	DO EQ^MIOTASSERT($GET(VM("windowManager","windowPreset"))'="",1,"[MIOMOST][T014][window preset]")
	DO EQ^MIOTASSERT($GET(VM("windowManager","engine")),"miomos-native-vue-css","[MIOMOST][T014][wm engine]")
	DO EQ^MIOTASSERT($GET(VM("shellChrome","quickLaunchLabel")),"Quick Launch","[MIOMOST][T014][quick launch label]")
	DO EQ^MIOTASSERT($GET(VM("shellChrome","overflowLabel")),"More Windows","[MIOMOST][T014][overflow label]")
	DO EQ^MIOTASSERT($GET(VM("shellChrome","trayStyle")),"xp-notify-area","[MIOMOST][T014][shell tray style]")
	DO EQ^MIOTASSERT($GET(VM("shellChrome","taskbarBehavior")),"stable-order","[MIOMOST][T014][taskbar stable]")
	DO EQ^MIOTASSERT($GET(VM("shellChrome","taskbarOverflowBehavior")),"preserve-order-and-overflow","[MIOMOST][T014][overflow stable]")
	DO EQ^MIOTASSERT($GET(VM("shellChrome","startMenuBehavior")),"predictable-sections","[MIOMOST][T014][start predictable]")
	DO EQ^MIOTASSERT($GET(VM("shellChrome","startSearchBehavior")),"filter-programs-and-actions","[MIOMOST][T014][start search behavior]")
	DO EQ^MIOTASSERT($GET(VM("shellChrome","keyboardModel")),"ctrl-escape-enter-search","[MIOMOST][T014][keyboard model]")
	DO EQ^MIOTASSERT($GET(VM("shellChrome","taskbarClickPolicy")),"xp-toggle","[MIOMOST][T014][task click policy]")
	DO EQ^MIOTASSERT($GET(VM("shellChrome","shellSurfacePolicy")),"single-open-surface","[MIOMOST][T014][surface policy]")
	DO EQ^MIOTASSERT($GET(VM("shellChrome","startFooter",3,"label")),"Turn Off Computer","[MIOMOST][T014][shell power label]")
	DO EQ^MIOTASSERT($GET(VM("shellChrome","dialogDragBehavior")),"titlebar-drag","[MIOMOST][T014][dialog drag behavior]")
	DO EQ^MIOTASSERT($GET(VM("shellChrome","folderCreateBehavior")),"desktop-context-menu","[MIOMOST][T014][folder create behavior]")
	DO EQ^MIOTASSERT($GET(VM("shellChrome","desktopComposition")),"ui-samples-settings-terminal","[MIOMOST][T014][desktop composition]")
	DO EQ^MIOTASSERT(+$GET(VM("windowManager","serverBackedUiState")),1,"[MIOMOST][T014][wm server ui]")
	DO EQ^MIOTASSERT($GET(ARR("catalog","windowManager","nativeCapabilities",1,"key")),"drag","[MIOMOST][T014][wm native cap]")
	DO DEFAULTWINS^MIOMOSWM(.ARR,"terminal")
	DO EQ^MIOTASSERT($GET(ARR(6,"appKey")),"terminal","[MIOMOST][T015][wm default terminal]")
	DO EQ^MIOTASSERT(+$GET(ARR(1,"taskOrder")),1,"[MIOMOST][T015][wm task order]")
	DO EQ^MIOTASSERT(+$GET(ARR(6,"width"))>1000,1,"[MIOMOST][T015][wm terminal width]")
	;
	NEW WSREQ,WSCTX,WSSTATE,WSSID,WSTERM,WSPAY,TERMARR
	KILL ERR,OBJ,ARR
	SET WSREQ("hdr","cookie")="miomos_auth="_TOKEN
	SET WSCTX("request_id")="miomost-ws-bootstrap"
	DO OK^MIOTASSERT($$LOADLOCAL^MIOMOSAUTH(.CONF,.WSREQ,.WSCTX,.ERR),"[MIOMOST][T016][ws local auth]")
	DO OK^MIOTASSERT($$ENSURE^MIOMOSST(.CONF,.WSREQ,.WSCTX,.WSSTATE,.ERR),"[MIOMOST][T016][ws ensure]")
	SET WSSID=$GET(WSSTATE("sessionId"))
	DO EQ^MIOTASSERT(WSSID'="",1,"[MIOMOST][T016][ws session id]")
	SET WSCTX("miomos","sessionId")=WSSID
	SET WSCTX("request_id")="miomost-ws-cmd"
	DO OK^MIOTASSERT($$COMMANDSIDJSON^MIOMOSWS(.CONF,.WSREQ,.WSCTX,WSSID,"{""event"":""command.exec"",""requestId"":""ws-1"",""command"":""desktop.ping""}",.OBJ,.ERR),"[MIOMOST][T016][ws ping exec]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON(OBJ,.ARR,.ERR),"[MIOMOST][T016][ws ping decode]")
	DO EQ^MIOTASSERT($GET(ARR("event")),"command.result","[MIOMOST][T016][ws ping event]")
	DO EQ^MIOTASSERT($GET(ARR("transport")),"websocket","[MIOMOST][T016][ws ping transport]")
	DO EQ^MIOTASSERT($GET(ARR("pong")),1,"[MIOMOST][T016][ws ping pong]")
	KILL OBJ,ARR,ERR
	SET WSCTX("request_id")="miomost-ws-view"
	DO OK^MIOTASSERT($$COMMANDSIDJSON^MIOMOSWS(.CONF,.WSREQ,.WSCTX,WSSID,"{""event"":""command.exec"",""requestId"":""ws-2"",""command"":""view.refresh""}",.OBJ,.ERR),"[MIOMOST][T016][ws view exec]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON(OBJ,.ARR,.ERR),"[MIOMOST][T016][ws view decode]")
	DO EQ^MIOTASSERT($GET(ARR("view","workspace","headline")),"Production workspace","[MIOMOST][T016][ws view headline]")
	KILL OBJ,ARR,ERR
	SET WSCTX("request_id")="miomost-ws-ui"
	DO OK^MIOTASSERT($$COMMANDSIDJSON^MIOMOSWS(.CONF,.WSREQ,.WSCTX,WSSID,"{""event"":""command.exec"",""requestId"":""ws-3"",""command"":""session.ui.save"",""startMenuSection"":""Applications"",""startMenuQuery"":""ops""}",.OBJ,.ERR),"[MIOMOST][T016][ws ui save exec]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON(OBJ,.ARR,.ERR),"[MIOMOST][T016][ws ui save decode]")
	DO EQ^MIOTASSERT($GET(ARR("saved")),1,"[MIOMOST][T016][ws ui save flag]")
	DO EQ^MIOTASSERT($GET(ARR("ui","startMenuQuery")),"ops","[MIOMOST][T016][ws ui save query]")
	KILL OBJ,ARR,ERR
	SET WSCTX("request_id")="miomost-ws-term"
	DO OK^MIOTASSERT($$COMMANDSIDJSON^MIOMOSWS(.CONF,.WSREQ,.WSCTX,WSSID,"{""event"":""command.exec"",""requestId"":""ws-4"",""command"":""terminal.open""}",.OBJ,.ERR),"[MIOMOST][T016][ws term open exec]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON(OBJ,.ARR,.ERR),"[MIOMOST][T016][ws term open decode]")
	DO EQ^MIOTASSERT($GET(ARR("terminal","terminalId"))'="",1,"[MIOMOST][T016][ws term id]")
	DO EQ^MIOTASSERT($GET(ARR("terminal","transport")),"pipe","[MIOMOST][T016][ws term transport]")
	SET WSTERM=$GET(ARR("terminal","terminalId"))
	KILL OBJ,ARR,ERR
	SET WSCTX("request_id")="miomost-ws-term-in"
	SET WSPAY="{""event"":""command.exec"",""requestId"":""ws-5"",""command"":""terminal.input"",""terminalId"":"""_WSTERM_""",""line"":""write 123,!""}"
	DO OK^MIOTASSERT($$COMMANDSIDJSON^MIOMOSWS(.CONF,.WSREQ,.WSCTX,WSSID,WSPAY,.OBJ,.ERR),"[MIOMOST][T016][ws term input exec]")
	DO OK^MIOTASSERT($$DECODE^MIOJSON(OBJ,.ARR,.ERR),"[MIOMOST][T016][ws term input decode]")
	MERGE TERMARR=ARR("terminal")
	DO EQ^MIOTASSERT($$HASWRITE(.TERMARR,"123"),1,"[MIOMOST][T016][ws term mumps output]")
	;
	KILL ^MIO("MIOMOS","WS")
	SET WSCTX("request_id")="miomost-ws-reg-1"
	DO WSREG^MIOMOSOBS("hello","ws-reg-1",.WSCTX,.WSSTATE,"bootstrap")
	SET WSCTX("request_id")="miomost-ws-reg-2"
	DO WSREG^MIOMOSOBS("pong","ws-reg-1",.WSCTX,.WSSTATE,"")
	SET WSCTX("request_id")="miomost-ws-reg-3"
	DO WSREG^MIOMOSOBS("command.exec","ws-reg-1",.WSCTX,.WSSTATE,"desktop.ping")
	SET WSCTX("request_id")="miomost-ws-reg-4"
	DO WSREG^MIOMOSOBS("terminal.stdout","ws-reg-1",.WSCTX,.WSSTATE,$GET(WSTERM))
	KILL ARR
	DO WSSUMMARY^MIOMOSOBS(.ARR)
	DO EQ^MIOTASSERT($GET(ARR("registryEnabled")),1,"[MIOMOST][T019][ws summary enabled]")
	DO EQ^MIOTASSERT($GET(ARR("model")),"session-connection-registry","[MIOMOST][T019][ws summary model]")
	DO EQ^MIOTASSERT(+$GET(ARR("activeConnections"))>0,1,"[MIOMOST][T019][ws active connections]")
	DO EQ^MIOTASSERT($GET(ARR("sessions")),1,"[MIOMOST][T019][ws sessions]")
	DO EQ^MIOTASSERT(+$GET(ARR("helloCount"))>0,1,"[MIOMOST][T019][ws hello count]")
	DO EQ^MIOTASSERT(+$GET(ARR("pongCount"))>0,1,"[MIOMOST][T019][ws pong count]")
	DO EQ^MIOTASSERT($GET(ARR("lastEvent")),"terminal.stdout","[MIOMOST][T019][ws last event]")
	KILL ARR
	DO WSEXPORT^MIOMOSOBS(5,.ARR)
	DO EQ^MIOTASSERT($GET(ARR(1,"connectionId")),"ws-reg-1","[MIOMOST][T019][ws export conn]")
	DO EQ^MIOTASSERT($GET(ARR(1,"lastEvent")),"terminal.stdout","[MIOMOST][T019][ws export event]")
	DO EQ^MIOTASSERT(+$GET(ARR(1,"commandExecCount"))>0,1,"[MIOMOST][T019][ws export command count]")
	;
	NEW SECCTX,SECSTATE,SECSID,SECREQ,SECA,SECERR,SECJSON
	SET SECREQ("hdr","cookie")="miomos_auth="_TOKEN
	SET SECCTX("request_id")="miomost-sec-1"
	DO OK^MIOTASSERT($$LOADLOCAL^MIOMOSAUTH(.CONF,.SECREQ,.SECCTX,.SECERR),"[MIOMOST][T020][sec load local]")
	DO OK^MIOTASSERT($$ENSURE^MIOMOSST(.CONF,.SECREQ,.SECCTX,.SECSTATE,.SECERR),"[MIOMOST][T020][sec ensure]")
	SET SECSID=$GET(SECSTATE("sessionId"))
	DO OK^MIOTASSERT($$LOCK^MIOMOSST(SECSID,"idle_lock"),"[MIOMOST][T020][lock]")
	KILL SECSTATE,SECERR
	DO EQ^MIOTASSERT($$ENSURE^MIOMOSST(.CONF,.SECREQ,.SECCTX,.SECSTATE,.SECERR),0,"[MIOMOST][T020][lock denied]")
	DO EQ^MIOTASSERT($GET(SECERR("error")),"session_locked","[MIOMOST][T020][lock code]")
	DO OK^MIOTASSERT($$UNLOCK^MIOMOSST(SECSID),"[MIOMOST][T020][unlock]")
	KILL SECSTATE,SECERR
	DO OK^MIOTASSERT($$ENSURE^MIOMOSST(.CONF,.SECREQ,.SECCTX,.SECSTATE,.SECERR),"[MIOMOST][T020][unlock ensure]")
	DO OK^MIOTASSERT($$FORCESIGNOUT^MIOMOSST(SECSID,"admin_forced"),"[MIOMOST][T020][force signout]")
	SET SECJSON=$$SESSIONJSON^MIOMOSWS("forced_signout","admin_forced",.SECSTATE,SECSID)
	DO OK^MIOTASSERT($$DECODE^MIOJSON(SECJSON,.SECA,.SECERR),"[MIOMOST][T020][signout decode]")
	DO EQ^MIOTASSERT($GET(SECA("event")),"session.signout","[MIOMOST][T020][signout event]")
	DO EQ^MIOTASSERT($GET(SECA("reason")),"forced_signout","[MIOMOST][T020][signout reason]")
	KILL SECSTATE,SECERR
	DO EQ^MIOTASSERT($$ENSURE^MIOMOSST(.CONF,.SECREQ,.SECCTX,.SECSTATE,.SECERR),0,"[MIOMOST][T020][forced denied]")
	DO EQ^MIOTASSERT($GET(SECERR("error")),"forced_signout","[MIOMOST][T020][forced code]")
	DO OK^MIOTASSERT($$CLEARFORCE^MIOMOSST(SECSID),"[MIOMOST][T020][clear force]")
	KILL SECCTX,SECSTATE,SECERR
	SET SECCTX("request_id")="miomost-sec-bind",SECCTX("miomos","sessionId")=SECSID
	SET SECCTX("auth","ok")=1,SECCTX("auth","claims","sub")="intruder",SECCTX("auth","claims","name")="Intruder"
	SET SECCTX("auth","roles","viewer")=1
	DO EQ^MIOTASSERT($$ENSURE^MIOMOSST(.CONF,.SECREQ,.SECCTX,.SECSTATE,.SECERR),0,"[MIOMOST][T020][binding denied]")
	DO EQ^MIOTASSERT($GET(SECERR("error")),"session_binding_mismatch","[MIOMOST][T020][binding code]")
	DO REGSNAP^MIOMOSST(SECSID,.SECA)
	DO EQ^MIOTASSERT($GET(SECA("sessionId")),SECSID,"[MIOMOST][T020][registry sid]")
	DO EQ^MIOTASSERT($GET(SECA("principal")),"phaseone","[MIOMOST][T020][registry principal]")
	;
	KILL ARR
	DO RELEASEARY^MIOMOSST(.STATE,.CONF,$NA(ARR))
	DO EQ^MIOTASSERT($GET(ARR("model")),"test-runbook-checklist","[MIOMOST][T021][release model]")
	DO EQ^MIOTASSERT($GET(ARR("tests","suite")),"^MIOMOST","[MIOMOST][T021][release suite]")
	DO EQ^MIOTASSERT($GET(ARR("runbooks","deploy")),"systemd-caddy-nginx","[MIOMOST][T021][release deploy]")
	DO EQ^MIOTASSERT($GET(ARR("runbooks","routeRebuild")),"REG^MIOMOS+COMPILE^MIOROUTE","[MIOMOST][T021][release rebuild]")
	DO EQ^MIOTASSERT($GET(ARR("smoke","websocket",1,"key")),"hello","[MIOMOST][T021][release ws smoke]")
	DO EQ^MIOTASSERT($GET(ARR("smoke","browser",4,"key")),"reconnect","[MIOMOST][T021][release browser smoke]")
	DO EQ^MIOTASSERT(+$GET(ARR("docsCurrent")),1,"[MIOMOST][T021][release docs current]")
	;
	KILL ^MIO("MIOMOS","USER"),^MIO("MIOMOS","AUTH")
	KILL CONF,ERR,TOKEN,REQ,WCTX,STATE,OBJ,OUT,ARR,CTX
	SET CONF("auth","enabled")=1
	SET CONF("miomos","profile")="prod"
	SET CONF("miomos","dev","enabled")=0
	SET CONF("miomos","dev","authDisabled")=0
	SET CONF("miomos","localAuth","enabled")=1
	SET CONF("miomos","localAuth","guestLoginEnabled")=1
	DO CONFDEF^MIOMOS(.CONF)
	DO EQ^MIOTASSERT($DATA(^MIO("MIOMOS","USER","admin"))>0,1,"[MIOMOST][T022][seed admin]")
	DO EQ^MIOTASSERT($DATA(^MIO("MIOMOS","USER","user"))>0,1,"[MIOMOST][T022][seed user]")
	DO EQ^MIOTASSERT($DATA(^MIO("MIOMOS","USER","guest"))>0,1,"[MIOMOST][T022][seed guest]")
	DO EQ^MIOTASSERT($GET(^MIO("MIOMOS","USER","guest","roles")),"guest","[MIOMOST][T022][guest role]")
	DO EQ^MIOTASSERT($GET(^MIO("MIOMOS","USER","admin","hash"))=$$PW^MIOMOSAUTH($GET(^MIO("MIOMOS","USER","admin","salt")),"admin123!"),1,"[MIOMOST][T022][admin hash]")
	DO EQ^MIOTASSERT($GET(^MIO("MIOMOS","USER","user","hash"))=$$PW^MIOMOSAUTH($GET(^MIO("MIOMOS","USER","user","salt")),"user123!"),1,"[MIOMOST][T022][user hash]")
	DO EQ^MIOTASSERT($GET(^MIO("MIOMOS","USER","guest","hash"))=$$PW^MIOMOSAUTH($GET(^MIO("MIOMOS","USER","guest","salt")),"guest123!"),1,"[MIOMOST][T022][guest hash]")
	DO EQ^MIOTASSERT($DATA(^MIO("MIOMOS","USER","admin","password")),0,"[MIOMOST][T022][no plain password]")
	DO OK^MIOTASSERT($$GUESTSIGNIN^MIOMOSAUTH(.CONF,.TOKEN,.ERR),"[MIOMOST][T022][guest signin]")
	SET REQ("hdr","cookie")="miomos_auth="_TOKEN
	DO OK^MIOTASSERT($$LOADLOCAL^MIOMOSAUTH(.CONF,.REQ,.CTX,.ERR),"[MIOMOST][T022][guest load local]")
	DO EQ^MIOTASSERT($GET(CTX("auth","claims","sub")),"guest","[MIOMOST][T022][guest principal]")
	DO OK^MIOTASSERT($$ENSURE^MIOMOSST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOMOST][T022][guest ensure]")
	DO EQ^MIOTASSERT($$HAS^MIOMOSPERM(.STATE,"terminal.use"),0,"[MIOMOST][T022][guest no terminal]")
	DO EQ^MIOTASSERT($$HAS^MIOMOSPERM(.STATE,"settings.self"),1,"[MIOMOST][T022][guest settings]")
	DO BOOTARY^MIOMOSST(.STATE,.CONF,.OBJ)
	DO EQ^MIOTASSERT(+$GET(OBJ("auth","guestLoginEnabled")),1,"[MIOMOST][T022][guest toggle boot]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","guestSignin")),"/api/miomos/auth/guest","[MIOMOST][T022][guest route boot]")
	DO AUTHCTX^MIOMOSUI(.CONF,.CTX)
	DO OK^MIOTASSERT($$RENDERPAGE^MIOTPL("pages/miomos_auth.html","layouts/miomos_shell.html",.CONF,.CTX,.OUT,.ERR),"[MIOMOST][T022][auth render]")
	DO OK^MIOTASSERT(OUT["Continue as guest","[MIOMOST][T022][guest button]")
	DO OK^MIOTASSERT(OUT["data-guest-login-enabled=""1""","[MIOMOST][T022][guest token]")
	QUIT
	;
FINDUSR(LIST,USER)
	NEW N,POS
	SET (N,POS)=0
	FOR  SET N=$ORDER(LIST(N)) QUIT:N=""  DO  QUIT:POS>0
	. IF $GET(LIST(N,"principal"))=$GET(USER) SET POS=N
	QUIT POS
	;
HASWRITE(OUT,TEXT)
	NEW N,FOUND
	SET (N,FOUND)=0
	FOR  SET N=$ORDER(OUT("write",N)) QUIT:N=""  DO  QUIT:FOUND
	. IF $GET(OUT("write",N))[$GET(TEXT) SET FOUND=1
	QUIT FOUND
	;
	;
