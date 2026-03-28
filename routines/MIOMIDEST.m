MIOMIDEST ; MIOIDE state helpers
	QUIT
	;
ENSURE(CONF,REQ,CTX,STATE,ERR)
	KILL STATE,ERR
	SET ERR("routine")="MIOMIDEST"
	IF $$DEVAUTHOFF^MIOMIDE(.CONF) DO  QUIT 1
	. SET STATE("principal")=$GET(CONF("miomide","dev","principal"),"dev-user")
	. SET STATE("userName")=$GET(CONF("miomide","dev","userName"),"Developer")
	. SET STATE("roles")=$GET(CONF("miomide","dev","roles"),"developer,admin")
	. SET STATE("profile")=$GET(CONF("miomide","profile"),"dev")
	. SET STATE("theme")=$GET(CONF("miomide","ui","theme"),"mioide-dark")
	IF '$GET(CTX("auth","ok")) SET ERR("error")="auth_required" QUIT 0
	SET STATE("principal")=$GET(CTX("auth","claims","sub"))
	IF STATE("principal")="" SET STATE("principal")=$GET(CTX("auth","claims","name"))
	IF STATE("principal")="" SET ERR("error")="principal_missing" QUIT 0
	SET STATE("userName")=$GET(CTX("auth","claims","name"),STATE("principal"))
	SET STATE("profile")=$GET(CONF("miomide","profile"),"prod")
	SET STATE("theme")=$GET(CONF("miomide","ui","theme"),"mioide-dark")
	DO ROLES(.CTX,.STATE)
	QUIT 1
	;
ROLES(CTX,STATE)
	NEW ROLE,LIST
	SET ROLE="",LIST=""
	FOR  SET ROLE=$ORDER(CTX("auth","roles",ROLE)) QUIT:ROLE=""  DO
	. SET LIST=LIST_$SELECT(LIST'="":",",1:"")_ROLE
	IF LIST="" SET LIST="developer"
	SET STATE("roles")=LIST
	QUIT
	;
PAGECTX(STATE,CONF,REQ,CTX,OUT)
	KILL OUT
	SET OUT("pageTitle")=$GET(CONF("miomide","brand","title"),"MIOIDE")
	SET OUT("productTitle")=$GET(CONF("miomide","brand","title"),"MIOIDE")
	SET OUT("productSubtitle")=$GET(CONF("miomide","brand","subtitle"),"MUMPS / YottaDB IDE")
	SET OUT("bootRoute")=$GET(CONF("miomide","route","bootstrap"))
	SET OUT("eventsWsRoute")=$GET(CONF("miomide","route","eventsWs"))
	SET OUT("terminalWsRoute")=$GET(CONF("miomide","route","terminalWs"))
	SET OUT("themeClass")=$GET(STATE("theme"),"mioide-dark")
	SET OUT("userName")=$GET(STATE("userName"))
	SET OUT("profile")=$GET(STATE("profile"))
	SET OUT("principal")=$GET(STATE("principal"))
	QUIT
	;
BOOTOBJ(STATE,CONF,OBJ)
	KILL OBJ
	SET OBJ("ok")=1
	SET OBJ("product","title")=$GET(CONF("miomide","brand","title"),"MIOIDE")
	SET OBJ("product","subtitle")=$GET(CONF("miomide","brand","subtitle"),"MUMPS / YottaDB IDE")
	SET OBJ("product","version")="roi5-vscode-workbench"
	SET OBJ("user","principal")=$GET(STATE("principal"))
	SET OBJ("user","name")=$GET(STATE("userName"))
	SET OBJ("user","roles")=$GET(STATE("roles"))
	SET OBJ("appearance","theme")=$GET(STATE("theme"),"mioide-dark")
	SET OBJ("appearance","themes",1)="mioide-dark"
	SET OBJ("appearance","themes",2)="mioide-light"
	SET OBJ("routes","desktop")=$GET(CONF("miomide","route","desktop"))
	SET OBJ("routes","bootstrap")=$GET(CONF("miomide","route","bootstrap"))
	SET OBJ("routes","routines")=$GET(CONF("miomide","route","routines"))
	SET OBJ("routes","routine")=$GET(CONF("miomide","route","routine"))
	SET OBJ("routes","save")=$GET(CONF("miomide","route","save"))
	SET OBJ("routes","compile")=$GET(CONF("miomide","route","compile"))
	SET OBJ("routes","run")=$GET(CONF("miomide","route","run"))
	SET OBJ("routes","search")=$GET(CONF("miomide","route","search"))
	SET OBJ("routes","globals")=$GET(CONF("miomide","route","globals"))
	SET OBJ("routes","debug")=$GET(CONF("miomide","route","debug"))
	SET OBJ("routes","eventsWs")=$GET(CONF("miomide","route","eventsWs"))
	SET OBJ("routes","terminalWs")=$GET(CONF("miomide","route","terminalWs"))
	SET OBJ("terminal","cols")=+$GET(CONF("miomide","terminal","cols"),132)
	SET OBJ("terminal","rows")=+$GET(CONF("miomide","terminal","rows"),32)
	SET OBJ("terminal","readLimit")=+$GET(CONF("miomide","terminal","readLimit"),8192)
	SET OBJ("terminal","readPolls")=+$GET(CONF("miomide","terminal","readPolls"),5)
	SET OBJ("terminal","drainPause")=+$GET(CONF("miomide","terminal","drainPause"),.04)
	SET OBJ("terminal","sessionIdleSeconds")=+$GET(CONF("miomide","terminal","sessionIdleSeconds"),900)
	SET OBJ("terminal","reconnectDelayMs")=+$GET(CONF("miomide","terminal","reconnectDelayMs"),1200)
	SET OBJ("terminal","pingIntervalMs")=+$GET(CONF("miomide","terminal","pingIntervalMs"),15000)
	SET OBJ("terminal","closeOnUnload")=+$GET(CONF("miomide","terminal","closeOnUnload"),1)
	SET OBJ("panels",1)="problems"
	SET OBJ("panels",2)="output"
	SET OBJ("panels",3)="terminal"
	SET OBJ("panels",4)="debug"
	SET OBJ("sidebars",1)="explorer"
	SET OBJ("sidebars",2)="search"
	SET OBJ("sidebars",3)="globals"
	SET OBJ("sidebars",4)="snippets"
	SET OBJ("sidebars",5)="debug"
	SET OBJ("snippets",1,"label")="SET"
	SET OBJ("snippets",1,"body")="SET X=1"
	SET OBJ("snippets",2,"label")="DO"
	SET OBJ("snippets",2,"body")="DO LABEL^ROUTINE"
	SET OBJ("snippets",3,"label")="QUIT"
	SET OBJ("snippets",3,"body")="QUIT"
	SET OBJ("snippets",4,"label")="$GET"
	SET OBJ("snippets",4,"body")="SET X=$GET(^GLOBAL(""KEY""))"
	SET OBJ("snippets",5,"label")="$ORDER"
	SET OBJ("snippets",5,"body")="SET KEY=$ORDER(^GLOBAL(KEY))"
	SET OBJ("capabilities","editor")=1
	SET OBJ("capabilities","compile")=1
	SET OBJ("capabilities","run")=1
	SET OBJ("capabilities","search")=1
	SET OBJ("capabilities","globals")=1
	SET OBJ("capabilities","terminal")=1
	SET OBJ("capabilities","terminalReconnect")=1
	SET OBJ("capabilities","terminalLifecycle")=1
	SET OBJ("capabilities","debug")=1
	SET OBJ("capabilities","problems")=1
	SET OBJ("capabilities","dirtyTabs")=1
	SET OBJ("capabilities","tabReorder")=1
	SET OBJ("capabilities","tabContextMenu")=1
	SET OBJ("capabilities","collaboration")=0
	SET OBJ("status","message")="VS Code-like workbench ready"
	SET OBJ("status","serverTime")=$$NOWISO^MIOUTIL()
	SET OBJ("layout","activityWidth")=+$GET(CONF("miomide","ui","activityWidth"),48)
	SET OBJ("layout","sidebarWidth")=+$GET(CONF("miomide","ui","sidebarWidth"),300)
	SET OBJ("layout","panelHeight")=+$GET(CONF("miomide","ui","panelHeight"),220)
	SET OBJ("layout","sidebarMinWidth")=+$GET(CONF("miomide","ui","sidebarMinWidth"),220)
	SET OBJ("layout","sidebarMaxWidth")=+$GET(CONF("miomide","ui","sidebarMaxWidth"),520)
	SET OBJ("layout","panelMinHeight")=+$GET(CONF("miomide","ui","panelMinHeight"),140)
	SET OBJ("layout","panelMaxHeight")=+$GET(CONF("miomide","ui","panelMaxHeight"),420)
	SET OBJ("layout","tabMinWidth")=+$GET(CONF("miomide","ui","tabMinWidth"),140)
	SET OBJ("layout","tabMaxWidth")=+$GET(CONF("miomide","ui","tabMaxWidth"),240)
	SET OBJ("layout","fontSize")=+$GET(CONF("miomide","ui","fontSize"),13)
	SET OBJ("layout","lineHeight")=+$GET(CONF("miomide","ui","lineHeight"),1.6)
	SET OBJ("layout","storageKey")=$GET(CONF("miomide","ui","storageKey"),"miomide:workspace")
	SET OBJ("layout","sidebarVisible")=1
	SET OBJ("layout","panelVisible")=1
	SET OBJ("layout","panelTab")="output"
	SET OBJ("ui","commandPalette")=+$GET(CONF("miomide","ui","commandPalette"),1)
	SET OBJ("ui","quickOpen")=+$GET(CONF("miomide","ui","quickOpen"),1)
	SET OBJ("ui","welcome")=+$GET(CONF("miomide","ui","welcome"),1)
	SET OBJ("workspace","compileAutoSave")=+$GET(CONF("miomide","workspace","compileAutoSave"),1)
	SET OBJ("workspace","problemLimit")=+$GET(CONF("miomide","workspace","problemLimit"),25)
	SET OBJ("workspace","recentLimit")=+$GET(CONF("miomide","workspace","recentLimit"),15)
	SET OBJ("commands",1,"id")="file.quickOpen"
	SET OBJ("commands",1,"label")="Go to File"
	SET OBJ("commands",1,"shortcut")="Ctrl+P"
	SET OBJ("commands",2,"id")="workbench.commandPalette"
	SET OBJ("commands",2,"label")="Command Palette"
	SET OBJ("commands",2,"shortcut")="Ctrl+Shift+P"
	SET OBJ("commands",3,"id")="view.toggleSidebar"
	SET OBJ("commands",3,"label")="Toggle Primary Side Bar"
	SET OBJ("commands",3,"shortcut")="Ctrl+B"
	SET OBJ("commands",4,"id")="workbench.action.terminal"
	SET OBJ("commands",4,"label")="Toggle Terminal"
	SET OBJ("commands",4,"shortcut")="Ctrl+`"
	SET OBJ("commands",5,"id")="workbench.action.theme"
	SET OBJ("commands",5,"label")="Toggle Theme"
	SET OBJ("commands",5,"shortcut")="Ctrl+K Ctrl+T"
	SET OBJ("commands",6,"id")="file.save"
	SET OBJ("commands",6,"label")="Save Active Routine"
	SET OBJ("commands",6,"shortcut")="Ctrl+S"
	SET OBJ("commands",7,"id")="routine.compile"
	SET OBJ("commands",7,"label")="Compile Active Routine"
	SET OBJ("commands",7,"shortcut")="Ctrl+Shift+B"
	SET OBJ("commands",8,"id")="routine.reload"
	SET OBJ("commands",8,"label")="Reload Active Routine"
	SET OBJ("commands",8,"shortcut")="Ctrl+R"
	SET OBJ("commands",9,"id")="routine.revert"
	SET OBJ("commands",9,"label")="Revert Unsaved Changes"
	SET OBJ("commands",9,"shortcut")="Ctrl+Alt+R"
	SET OBJ("commands",10,"id")="tab.closeAll"
	SET OBJ("commands",10,"label")="Close All Editors"
	SET OBJ("commands",10,"shortcut")="Ctrl+K Ctrl+W"
	SET OBJ("commands",11,"id")="tab.closeSaved"
	SET OBJ("commands",11,"label")="Close Saved Editors"
	SET OBJ("commands",11,"shortcut")="Ctrl+K U"
	SET OBJ("commands",12,"id")="terminal.reconnect"
	SET OBJ("commands",12,"label")="Reconnect Terminal Session"
	SET OBJ("commands",12,"shortcut")="Ctrl+Shift+`"
	QUIT
