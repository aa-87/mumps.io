MIOMIDET ; MIOIDE ROI 5 VS Code-like workbench smoke tests
START
	NEW CONF,OUT,ERR,CTX,REQ,OBJ,STATE,PAGE,LOAD,SAVE,LINES,STATUS,TREE
	KILL ^MIO("ROUTE"),^MIO("MIOMIDE")
	SET CONF("auth","enabled")=0
	DO CONFDEF^MIOMIDE(.CONF)
	DO START^MIOTPL(.CONF)
	DO INIT^MIOROUTE
	DO REG^MIOMIDE(.CONF)
	DO COMPILE^MIOROUTE
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","GET","/mioide","authRequired")),0,"[MIOMIDET][T001][desktop auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","GET","/mioide/api/bootstrap","authRequired")),0,"[MIOMIDET][T001][boot auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","GET","/mioide/api/routines","authRequired")),0,"[MIOMIDET][T001][routines auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","POST","/mioide/api/routine/:name/save","authRequired")),0,"[MIOMIDET][T001][save auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","GET","/mioide/api/debug","authRequired")),0,"[MIOMIDET][T001][debug auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","WS","/mioide/ws/events","authRequired")),0,"[MIOMIDET][T001][events ws auth]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","META","WS","/mioide/ws/terminal","authRequired")),0,"[MIOMIDET][T001][term ws auth]")
	;
	KILL CTX,REQ,OUT,ERR
	SET CTX("request_id")="miomide-test-rid"
	DO OK^MIOTASSERT($$ENSURE^MIOMIDEST(.CONF,.REQ,.CTX,.STATE,.ERR),"[MIOMIDET][T010][ensure]")
	DO PAGECTX^MIOMIDEST(.STATE,.CONF,.REQ,.CTX,.PAGE)
	DO OK^MIOTASSERT($$RENDERPAGE^MIOTPL("pages/miomide_index.html","layouts/miomide_shell.html",.CONF,.PAGE,.OUT,.ERR),"[MIOMIDET][T010][render]")
	DO OK^MIOTASSERT(OUT["data-workbench=""mioide""","[MIOMIDET][T010][workbench]")
	DO OK^MIOTASSERT(OUT["data-drop-zone=""sidebar""","[MIOMIDET][T010][sidebar zone]")
	DO OK^MIOTASSERT(OUT["data-drop-zone=""panel""","[MIOMIDET][T010][panel zone]")
	DO OK^MIOTASSERT(OUT["data-window-action=""dock""","[MIOMIDET][T010][dock action]")
	DO OK^MIOTASSERT(OUT["data-window-action=""pin""","[MIOMIDET][T010][pin action]")
	DO OK^MIOTASSERT(OUT["data-panel-mount=""output""","[MIOMIDET][T010][panel output]")
	DO OK^MIOTASSERT(OUT["data-panel-mount=""terminal""","[MIOMIDET][T010][panel terminal]")
	DO OK^MIOTASSERT(OUT["data-command-palette","[MIOMIDET][T010][command palette]")
	DO OK^MIOTASSERT(OUT["data-quick-open","[MIOMIDET][T010][quick open]")
	DO OK^MIOTASSERT(OUT["data-resizer=""sidebar""","[MIOMIDET][T010][sidebar resizer]")
	DO OK^MIOTASSERT(OUT["data-resizer=""panel""","[MIOMIDET][T010][panel resizer]")
	DO OK^MIOTASSERT(OUT["data-welcome-surface","[MIOMIDET][T010][welcome surface]")
	DO OK^MIOTASSERT(OUT["data-tab-strip","[MIOMIDET][T010][tab strip]")
	DO OK^MIOTASSERT(OUT["data-tab-context-menu","[MIOMIDET][T010][tab menu]")
	DO OK^MIOTASSERT(OUT["data-tab-action=""closeOthers""","[MIOMIDET][T010][tab close others]")
	DO OK^MIOTASSERT(OUT["data-tab-action=""closeAll""","[MIOMIDET][T010][tab close all]")
	DO OK^MIOTASSERT(OUT["data-terminal-status","[MIOMIDET][T010][terminal status]")
	DO OK^MIOTASSERT(OUT["data-terminal-action=""reconnect""","[MIOMIDET][T010][terminal reconnect]")
	DO OK^MIOTASSERT(OUT["Close Others","[MIOMIDET][T010][close others label]")
	DO OK^MIOTASSERT(OUT["Close All","[MIOMIDET][T010][close all label]")
	;
	KILL OBJ
	DO BOOTOBJ^MIOMIDEST(.STATE,.CONF,.OBJ)
	DO EQ^MIOTASSERT($GET(OBJ("product","version")),"roi5-vscode-workbench","[MIOMIDET][T020][version]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","bootstrap")),"/mioide/api/bootstrap","[MIOMIDET][T020][bootstrap route]")
	DO EQ^MIOTASSERT($GET(OBJ("routes","terminalWs")),"/mioide/ws/terminal","[MIOMIDET][T020][term ws route]")
	DO EQ^MIOTASSERT($GET(OBJ("terminal","cols")),132,"[MIOMIDET][T020][term cols]")
	DO EQ^MIOTASSERT($GET(OBJ("terminal","rows")),32,"[MIOMIDET][T020][term rows]")
	DO EQ^MIOTASSERT($GET(OBJ("terminal","readLimit")),8192,"[MIOMIDET][T020][term read limit]")
	DO EQ^MIOTASSERT($GET(OBJ("terminal","readPolls")),5,"[MIOMIDET][T020][term read polls]")
	DO EQ^MIOTASSERT($GET(OBJ("layout","sidebarWidth")),300,"[MIOMIDET][T020][sidebar width]")
	DO EQ^MIOTASSERT($GET(OBJ("layout","panelHeight")),220,"[MIOMIDET][T020][panel height]")
	DO EQ^MIOTASSERT($GET(OBJ("layout","tabMinWidth")),140,"[MIOMIDET][T020][tab min width]")
	DO EQ^MIOTASSERT($GET(OBJ("layout","tabMaxWidth")),240,"[MIOMIDET][T020][tab max width]")
	DO EQ^MIOTASSERT($GET(OBJ("layout","storageKey")),"miomide:workspace","[MIOMIDET][T020][storage key]")
	DO EQ^MIOTASSERT($GET(OBJ("ui","commandPalette")),1,"[MIOMIDET][T020][palette enabled]")
	DO EQ^MIOTASSERT($GET(OBJ("ui","quickOpen")),1,"[MIOMIDET][T020][quick open enabled]")
	DO EQ^MIOTASSERT($GET(OBJ("capabilities","terminal")),1,"[MIOMIDET][T020][term cap]")
	DO EQ^MIOTASSERT($GET(OBJ("capabilities","tabReorder")),1,"[MIOMIDET][T020][tab reorder cap]")
	DO EQ^MIOTASSERT($GET(OBJ("capabilities","tabContextMenu")),1,"[MIOMIDET][T020][tab menu cap]")
	DO EQ^MIOTASSERT($GET(OBJ("workspace","compileAutoSave")),1,"[MIOMIDET][T020][compile autosave]")
	DO EQ^MIOTASSERT($GET(OBJ("commands",10,"id")),"tab.closeAll","[MIOMIDET][T020][close all command]")
	DO EQ^MIOTASSERT($GET(OBJ("commands",11,"id")),"tab.closeSaved","[MIOMIDET][T020][close saved command]")
	DO EQ^MIOTASSERT($GET(OBJ("commands",12,"id")),"terminal.reconnect","[MIOMIDET][T020][terminal reconnect command]")
	;
	KILL LOAD,ERR,LINES,SAVE,OUT
	DO OK^MIOTASSERT($$LOAD^MIOMIDERT(.CONF,"MIOMIDE",.LOAD,.ERR),"[MIOMIDET][T030][load miomide]")
	DO OK^MIOTASSERT($DATA(LOAD("sourceLines",1))>0,"[MIOMIDET][T030][source lines]")
	DO OK^MIOTASSERT($GET(LOAD("lineCount"))>0,"[MIOMIDET][T030][line count]")
	DO OK^MIOTASSERT($GET(LOAD("checksum"))'="","[MIOMIDET][T030][checksum]")
	MERGE LINES=LOAD("sourceLines")
	DO OK^MIOTASSERT($$SAVEARR^MIOMIDERT(.CONF,"MIOMIDE",.LINES,.SAVE,.ERR),"[MIOMIDET][T030][save miomide]")
	DO EQ^MIOTASSERT($GET(SAVE("checksum")),$GET(LOAD("checksum")),"[MIOMIDET][T030][checksum roundtrip]")
	DO OK^MIOTASSERT($$COMPILE^MIOMIDERT(.CONF,"MIOMIDE",.OUT,.ERR),"[MIOMIDET][T030][compile miomide]")
	DO EQ^MIOTASSERT($GET(OUT("problemCount")),0,"[MIOMIDET][T030][compile problems]")
	DO EQ^MIOTASSERT($$PATH^MIOMIDERT(.CONF,"%TEST"),"routines/_TEST.m","[MIOMIDET][T030][percent path]")
	;
	KILL STATUS
	DO STATUSPROB^MIOMIDERT("150373194,DESKTOP+2^EFUZY,%YDB-E-LABELMISSING, Label referenced but not defined: REQUIRE",.STATUS)
	DO EQ^MIOTASSERT($GET(STATUS("problemCount")),1,"[MIOMIDET][T040][problem count]")
	DO EQ^MIOTASSERT($GET(STATUS("problems",1,"code")),"%YDB-E-LABELMISSING","[MIOMIDET][T040][problem code]")
	DO EQ^MIOTASSERT($GET(STATUS("problems",1,"line")),2,"[MIOMIDET][T040][problem line]")
	DO EQ^MIOTASSERT($GET(STATUS("problems",1,"routine")),"EFUZY","[MIOMIDET][T040][problem routine]")
	;
	KILL TREE
	SET TREE("clientId")="browser-a"
	DO EQ^MIOTASSERT($$CLIENTID^MIOMIDETM(.TREE,.STATE),"browser-a","[MIOMIDET][T050][client id explicit]")
	KILL TREE
	DO EQ^MIOTASSERT($$CLIENTID^MIOMIDETM(.TREE,.STATE),"term-dev-user","[MIOMIDET][T050][client id fallback]")
	DO EQ^MIOTASSERT($$TERMNUM^MIOMIDETM(0,132),132,"[MIOMIDET][T050][termnum fallback]")
	DO EQ^MIOTASSERT($$SAFE^MIOMIDETM("dev user!"),"dev-user-","[MIOMIDET][T050][safe]")
	SET ^MIO("MIOMIDE","TERM","CLIENT","dev-user","browser-a")="sid-a"
	DO EQ^MIOTASSERT($$LOOKUPSID^MIOMIDETM("dev-user","browser-a"),"sid-a","[MIOMIDET][T050][lookup sid]")
	SET ^MIO("MIOMIDE","TERM","SID","sid-a","principal")="dev-user"
	SET ^MIO("MIOMIDE","TERM","SID","sid-a","clientId")="browser-a"
	SET ^MIO("MIOMIDE","TERM","SID","sid-a","job")=999999
	SET ^MIO("MIOMIDE","TERM","SID","sid-a","device")="|dummy"
	SET ^MIO("MIOMIDE","TERM","SID","sid-a","lastSeenHorolog")=$HOROLOG
	DO CLOSEMETA^MIOMIDETM("sid-a")
	DO EQ^MIOTASSERT($DATA(^MIO("MIOMIDE","TERM","SID","sid-a")),0,"[MIOMIDET][T050][close meta sid]")
	DO EQ^MIOTASSERT($DATA(^MIO("MIOMIDE","TERM","CLIENT","dev-user","browser-a")),0,"[MIOMIDET][T050][close meta index]")
	QUIT
