MIOMOSCMD ; MIOMOS command execution boundary
	QUIT
	;
EXEC(STATE,CONF,TREE,OUT,ERR)
	NEW CMD,RAW,LAYOUT,VIEW
	KILL OUT,ERR
	SET ERR("routine")="MIOMOSCMD"
	SET CMD=$$LOW($GET(TREE("command")))
	IF CMD="" SET ERR("error")="command_missing",ERR("status")=400 QUIT 0
	IF CMD="desktop.ping" DO  QUIT 1
	. SET OUT("command")=CMD
	. SET OUT("pong")=1
	. SET OUT("sessionId")=$GET(STATE("sessionId"))
	IF CMD="layout.save" DO  QUIT 1
	. SET RAW=$GET(TREE("layoutJson"))
	. IF RAW="",$DATA(TREE("layout")) DO
	. . MERGE LAYOUT=TREE("layout")
	. . SET RAW=$$EN^MIOJSON1(.LAYOUT)
	. IF RAW="" SET RAW="{}"
	. DO SAVELAYOUT^MIOMOSST($GET(STATE("sessionId")),RAW)
	. SET OUT("command")=CMD
	. SET OUT("saved")=1
	IF CMD="theme.quick" QUIT $$THEME(.STATE,.TREE,.OUT,.ERR)
	IF CMD="settings.save" QUIT $$SETSAVE(.STATE,.TREE,.OUT,.ERR)
	IF CMD="session.ui.save" QUIT $$UISAVE(.STATE,.TREE,.OUT,.ERR)
	IF CMD="view.refresh" DO  QUIT 1
	. DO BUILD^MIOMOSVM(.STATE,.CONF,.VIEW)
	. MERGE OUT("view")=VIEW
	. SET OUT("command")=CMD
	IF CMD="wm.layout.apply" QUIT $$WMLAYOUT(.STATE,.CONF,.TREE,.OUT,.ERR)
	IF CMD="terminal.open" QUIT $$TERMOPEN(.STATE,.CONF,.TREE,.OUT,.ERR)
	IF CMD="terminal.input" QUIT $$TERMINPUT(.STATE,.TREE,.OUT,.ERR)
	IF CMD="terminal.reattach" QUIT $$TERMREATT(.STATE,.CONF,.TREE,.OUT,.ERR)
	IF CMD="terminal.close" QUIT $$TERMCLOSE(.STATE,.TREE,.OUT,.ERR)
	IF CMD="terminal.poll" QUIT $$TERMPOLL(.STATE,.TREE,.OUT,.ERR)
	IF CMD="terminal.resize" QUIT $$TERMRESZ(.STATE,.TREE,.OUT,.ERR)
	IF CMD="vfs.list" QUIT $$VFSLIST(.STATE,.CONF,.TREE,.OUT,.ERR)
	IF CMD="vfs.mkdir" QUIT $$VFSMKDIR(.STATE,.CONF,.TREE,.OUT,.ERR)
	IF CMD="vfs.rename" QUIT $$VFSREN(.STATE,.CONF,.TREE,.OUT,.ERR)
	IF CMD="vfs.delete" QUIT $$VFSDEL(.STATE,.CONF,.TREE,.OUT,.ERR)
	IF CMD="vfs.move" QUIT $$VFSMOVE(.STATE,.CONF,.TREE,.OUT,.ERR)
	IF CMD="vfs.recycle.restore" QUIT $$VFSREST(.STATE,.CONF,.TREE,.OUT,.ERR)
	IF CMD="vfs.recycle.empty" QUIT $$VFSEMPTY(.STATE,.CONF,.TREE,.OUT,.ERR)
	SET ERR("error")="command_unsupported",ERR("detail")=CMD,ERR("status")=400
	QUIT 0
	;
THEME(STATE,TREE,OUT,ERR)
	NEW SAVE,CUR
	IF '$$HAS^MIOMOSPERM(.STATE,"settings.self") SET ERR("error")="forbidden",ERR("detail")="settings.self",ERR("status")=403 QUIT 0
	SET SAVE("themeKey")=$GET(TREE("themeKey"))
	IF SAVE("themeKey")="" SET ERR("error")="theme_missing",ERR("status")=400 QUIT 0
	IF '$$SAVE^MIOMOSSET($GET(STATE("principal")),.SAVE,.CUR,.ERR) SET ERR("status")=400 QUIT 0
	MERGE OUT("settings")=CUR
	SET OUT("command")="theme.quick"
	QUIT 1
	;
SETSAVE(STATE,TREE,OUT,ERR)
	NEW CUR
	IF '$$HAS^MIOMOSPERM(.STATE,"settings.self") SET ERR("error")="forbidden",ERR("detail")="settings.self",ERR("status")=403 QUIT 0
	IF '$$SAVE^MIOMOSSET($GET(STATE("principal")),.TREE,.CUR,.ERR) SET ERR("status")=400 QUIT 0
	MERGE OUT("settings")=CUR
	SET OUT("command")="settings.save"
	QUIT 1
	;
UISAVE(STATE,TREE,OUT,ERR)
	NEW SAVE,RAW,UI
	IF '$$HAS^MIOMOSPERM(.STATE,"settings.self") SET ERR("error")="forbidden",ERR("detail")="settings.self",ERR("status")=403 QUIT 0
	SET SAVE("menuOpen")=+$GET(TREE("menuOpen"))
	SET SAVE("activeWindowId")=$GET(TREE("activeWindowId"))
	SET SAVE("focusedAppKey")=$GET(TREE("focusedAppKey"))
	SET SAVE("layoutMode")=$GET(TREE("layoutMode"))
	SET SAVE("lastCommandName")=$GET(TREE("lastCommandName"))
	SET SAVE("terminalId")=$GET(TREE("terminalId"))
	SET SAVE("reason")=$GET(TREE("reason"))
	SET SAVE("startMenuSection")=$GET(TREE("startMenuSection"))
	SET SAVE("startMenuQuery")=$GET(TREE("startMenuQuery"))
	SET SAVE("shellSurface")=$GET(TREE("shellSurface"))
	SET RAW=$$EN^MIOJSON1(.SAVE)
	IF '$$SAVEUIOK^MIOMOSST($GET(STATE("sessionId")),RAW) SET ERR("error")="ui_state_save_failed",ERR("status")=400 QUIT 0
	DO LOADUI^MIOMOSST($GET(STATE("sessionId")),.UI)
	MERGE OUT("ui")=UI
	SET OUT("saved")=1
	SET OUT("command")="session.ui.save"
	QUIT 1
	;
	;

PUTVFS(STATE,CONF,OUT)
	DO CATALOG^MIOMOSVFS($GET(STATE("principal")),.CONF,$NAME(OUT("vfs")))
	QUIT
	;
VFSLIST(STATE,CONF,TREE,OUT,ERR)
	DO PUTVFS(.STATE,.CONF,.OUT)
	SET OUT("command")="vfs.list"
	SET OUT("parentKey")=$GET(TREE("parentKey"))
	QUIT 1
	;
VFSMKDIR(STATE,CONF,TREE,OUT,ERR)
	NEW ITEM
	IF '$$MKDIRCMD^MIOMOSVFS($GET(STATE("principal")),$GET(TREE("parentKey")),$GET(TREE("parentTitle")),$GET(TREE("title")),.ITEM,.ERR) QUIT 0
	MERGE OUT("entry")=ITEM
	DO PUTVFS(.STATE,.CONF,.OUT)
	SET OUT("command")="vfs.mkdir"
	QUIT 1
	;
VFSREN(STATE,CONF,TREE,OUT,ERR)
	NEW ITEM
	IF '$$RENAME^MIOMOSVFS($GET(STATE("principal")),$GET(TREE("key")),$GET(TREE("title")),.ITEM,.ERR) QUIT 0
	MERGE OUT("entry")=ITEM
	DO PUTVFS(.STATE,.CONF,.OUT)
	SET OUT("command")="vfs.rename"
	QUIT 1
	;
VFSDEL(STATE,CONF,TREE,OUT,ERR)
	NEW ITEM
	IF '$$DELETE^MIOMOSVFS($GET(STATE("principal")),$GET(TREE("key")),$GET(TREE("mode")),.ITEM,.ERR) QUIT 0
	MERGE OUT("entry")=ITEM
	DO PUTVFS(.STATE,.CONF,.OUT)
	SET OUT("command")="vfs.delete"
	QUIT 1
	;
VFSMOVE(STATE,CONF,TREE,OUT,ERR)
	NEW ITEM
	IF '$$MOVE^MIOMOSVFS($GET(STATE("principal")),$GET(TREE("key")),$GET(TREE("targetParentKey")),$GET(TREE("operation")),.ITEM,.ERR) QUIT 0
	MERGE OUT("entry")=ITEM
	DO PUTVFS(.STATE,.CONF,.OUT)
	SET OUT("command")="vfs.move"
	QUIT 1
	;
VFSREST(STATE,CONF,TREE,OUT,ERR)
	NEW ITEM
	IF '$$RESTORE^MIOMOSVFS($GET(STATE("principal")),$GET(TREE("key")),.ITEM,.ERR) QUIT 0
	MERGE OUT("entry")=ITEM
	DO PUTVFS(.STATE,.CONF,.OUT)
	SET OUT("command")="vfs.recycle.restore"
	QUIT 1
	;
VFSEMPTY(STATE,CONF,TREE,OUT,ERR)
	NEW ITEM
	IF '$$EMPTYBIN^MIOMOSVFS($GET(STATE("principal")),.ITEM,.ERR) QUIT 0
	MERGE OUT("entry")=ITEM
	DO PUTVFS(.STATE,.CONF,.OUT)
	SET OUT("command")="vfs.recycle.empty"
	QUIT 1
	;
LOW(X)
	NEW Y
	SET Y=$TR($GET(X),"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")
	QUIT Y

	;
WMLAYOUT(STATE,CONF,TREE,OUT,ERR)
	NEW PRESET,WIN
	IF '$$HAS^MIOMOSPERM(.STATE,"settings.self") SET ERR("error")="forbidden",ERR("detail")="settings.self",ERR("status")=403 QUIT 0
	SET PRESET=$GET(TREE("windowPreset")) IF PRESET="" SET PRESET=$GET(STATE("windowPreset"),"analyst")
	IF '$$SAVE^MIOMOSWM($GET(STATE("principal")),.TREE,.WIN,.ERR) SET ERR("status")=400 QUIT 0
	DO DEFAULTWINS^MIOMOSWM($NAME(OUT("windows")),PRESET)
	SET OUT("command")="wm.layout.apply"
	SET OUT("windowPreset")=PRESET
	QUIT 1
	;
TERMOPEN(STATE,CONF,TREE,OUT,ERR)
	NEW TERMOUT,TERMID,COLS,ROWS
	IF '$$HAS^MIOMOSPERM(.STATE,"terminal.use") SET ERR("error")="forbidden",ERR("detail")="terminal.use",ERR("status")=403 QUIT 0
	SET TERMID=$GET(TREE("terminalId"))
	IF $$BOOL($GET(TREE("forceNew"))) SET TERMID="__new__"
	SET COLS=$$COLS^MIOMOSTERM(+$GET(TREE("cols")))
	SET ROWS=$$ROWS^MIOMOSTERM(+$GET(TREE("rows")))
	IF COLS>0 SET STATE("terminal","cols")=COLS
	IF ROWS>0 SET STATE("terminal","rows")=ROWS
	IF '$$OPEN^MIOMOSTPIPE(.STATE,.CONF,TERMID,.TERMOUT,.ERR) SET ERR("status")=400 QUIT 0
	MERGE OUT("terminal")=TERMOUT
	SET OUT("command")="terminal.open"
	QUIT 1
	;

TERMREATT(STATE,CONF,TREE,OUT,ERR)
	NEW TERMOUT
	IF '$$HAS^MIOMOSPERM(.STATE,"terminal.use") SET ERR("error")="forbidden",ERR("detail")="terminal.use",ERR("status")=403 QUIT 0
	IF '$$REATTACH^MIOMOSTPIPE(.STATE,.CONF,$GET(TREE("terminalId")),.TERMOUT,.ERR) SET ERR("status")=400 QUIT 0
	MERGE OUT("terminal")=TERMOUT
	SET OUT("command")="terminal.reattach"
	QUIT 1
	;

TERMINPUT(STATE,TREE,OUT,ERR)
	NEW TERMOUT,DATA
	IF '$$HAS^MIOMOSPERM(.STATE,"terminal.use") SET ERR("error")="forbidden",ERR("detail")="terminal.use",ERR("status")=403 QUIT 0
	SET DATA=$SELECT($DATA(TREE("line")):$$TERMNL($GET(TREE("line"))),1:$GET(TREE("data")))
	IF '$$INPUT^MIOMOSTPIPE(.STATE,$GET(TREE("terminalId")),DATA,.TERMOUT,.ERR) SET ERR("status")=400 QUIT 0
	MERGE OUT("terminal")=TERMOUT
	SET OUT("command")="terminal.input"
	QUIT 1
	;
TERMCLOSE(STATE,TREE,OUT,ERR)
	NEW TERMOUT
	IF '$$HAS^MIOMOSPERM(.STATE,"terminal.use") SET ERR("error")="forbidden",ERR("detail")="terminal.use",ERR("status")=403 QUIT 0
	IF '$$CLOSE^MIOMOSTPIPE(.STATE,$GET(TREE("terminalId")),.TERMOUT,.ERR) SET ERR("status")=400 QUIT 0
	MERGE OUT("terminal")=TERMOUT
	SET OUT("command")="terminal.close"
	QUIT 1
	;
TERMPOLL(STATE,TREE,OUT,ERR)
	NEW TERMOUT
	IF '$$HAS^MIOMOSPERM(.STATE,"terminal.use") SET ERR("error")="forbidden",ERR("detail")="terminal.use",ERR("status")=403 QUIT 0
	IF '$$POLL^MIOMOSTPIPE(.STATE,$GET(TREE("terminalId")),.TERMOUT,.ERR) SET ERR("status")=400 QUIT 0
	MERGE OUT("terminal")=TERMOUT
	SET OUT("command")="terminal.poll"
	QUIT 1
	;
TERMRESZ(STATE,TREE,OUT,ERR)
	NEW TERMOUT
	IF '$$HAS^MIOMOSPERM(.STATE,"terminal.use") SET ERR("error")="forbidden",ERR("detail")="terminal.use",ERR("status")=403 QUIT 0
	IF '$$RESIZE^MIOMOSTPIPE(.STATE,$GET(TREE("terminalId")),+$GET(TREE("cols")),+$GET(TREE("rows")),.TERMOUT,.ERR) SET ERR("status")=400 QUIT 0
	MERGE OUT("terminal")=TERMOUT
	SET OUT("command")="terminal.resize"
	QUIT 1
	;
TERMNL(X)
	NEW Y
	SET Y=$GET(X)
	IF Y="" QUIT $CHAR(10)
	IF $EXTRACT(Y,$LENGTH(Y))=$CHAR(10) QUIT Y
	IF $EXTRACT(Y,$LENGTH(Y))=$CHAR(13) QUIT Y
	QUIT Y_$CHAR(10)

BOOL(X)
	NEW V
	SET V=$ZCONVERT($$TRIM^MIOUTIL($GET(X)),"L")
	IF V="true" QUIT 1
	IF V="yes" QUIT 1
	IF V="on" QUIT 1
	QUIT $SELECT(+$GET(X):1,1:0)
	;
