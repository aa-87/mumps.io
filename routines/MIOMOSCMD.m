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
	IF CMD="view.refresh" DO  QUIT 1
	. DO BUILD^MIOMOSVM(.STATE,.CONF,.VIEW)
	. MERGE OUT("view")=VIEW
	. SET OUT("command")=CMD
	IF CMD="wm.layout.apply" QUIT $$WMLAYOUT(.STATE,.CONF,.TREE,.OUT,.ERR)
	IF CMD="terminal.open" QUIT $$TERMOPEN(.STATE,.CONF,.TREE,.OUT,.ERR)
	IF CMD="terminal.close" QUIT $$TERMCLOSE(.STATE,.TREE,.OUT,.ERR)
	IF CMD="terminal.poll" QUIT $$TERMPOLL(.STATE,.TREE,.OUT,.ERR)
	IF CMD="terminal.resize" QUIT $$TERMRESZ(.STATE,.TREE,.OUT,.ERR)
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
	NEW TERMOUT,TERMID
	IF '$$HAS^MIOMOSPERM(.STATE,"terminal.use") SET ERR("error")="forbidden",ERR("detail")="terminal.use",ERR("status")=403 QUIT 0
	SET TERMID=$GET(TREE("terminalId"))
	IF '$$OPEN^MIOMOSTPIPE(.STATE,.CONF,TERMID,.TERMOUT,.ERR) SET ERR("status")=400 QUIT 0
	MERGE OUT("terminal")=TERMOUT
	SET OUT("command")="terminal.open"
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
