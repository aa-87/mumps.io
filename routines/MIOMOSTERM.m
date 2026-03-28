MIOMOSTERM ; MIOMOS terminal foundation helpers
	QUIT
	;
LOADTERM(STATE,CONF)
	NEW USER,DEF
	SET USER=$GET(STATE("principal"))
	SET DEF("fontFamily")=$GET(CONF("miomos","terminal","default","fontFamily"),"JetBrains Mono")
	SET DEF("fontSize")=+$GET(CONF("miomos","terminal","default","fontSize"),13)
	SET DEF("cursorBlink")=+$GET(CONF("miomos","terminal","default","cursorBlink"),1)
	SET DEF("cursorStyle")=$GET(CONF("miomos","terminal","default","cursorStyle"),"block")
	SET DEF("scrollback")=+$GET(CONF("miomos","terminal","default","scrollback"),3000)
	SET DEF("renderer")=$GET(CONF("miomos","terminal","default","renderer"),"canvas")
	SET DEF("unicode")=$GET(CONF("miomos","terminal","default","unicode"),"unicode11")
	SET DEF("rows")=+$GET(CONF("miomos","terminal","default","rows"),28)
	SET DEF("cols")=+$GET(CONF("miomos","terminal","default","cols"),120)
	SET STATE("terminal","fontFamily")=$$GETP(USER,"fontFamily",DEF("fontFamily"))
	SET STATE("terminal","fontSize")=+$$GETP(USER,"fontSize",DEF("fontSize"))
	IF STATE("terminal","fontSize")<12 SET STATE("terminal","fontSize")=13
	IF STATE("terminal","fontSize")>18 SET STATE("terminal","fontSize")=13
	SET STATE("terminal","cursorBlink")=+$$GETP(USER,"cursorBlink",DEF("cursorBlink"))
	SET STATE("terminal","cursorStyle")=$$CURSOROK($$GETP(USER,"cursorStyle",DEF("cursorStyle")))
	IF STATE("terminal","cursorStyle")="" SET STATE("terminal","cursorStyle")=DEF("cursorStyle")
	SET STATE("terminal","scrollback")=+$$GETP(USER,"scrollback",DEF("scrollback"))
	IF STATE("terminal","scrollback")<1000 SET STATE("terminal","scrollback")=DEF("scrollback")
	IF STATE("terminal","scrollback")>10000 SET STATE("terminal","scrollback")=DEF("scrollback")
	SET STATE("terminal","renderer")=$$RENDEREROK($$GETP(USER,"renderer",DEF("renderer")))
	IF STATE("terminal","renderer")="" SET STATE("terminal","renderer")=DEF("renderer")
	SET STATE("terminal","unicode")=$$UNICODEOK($$GETP(USER,"unicode",DEF("unicode")))
	IF STATE("terminal","unicode")="" SET STATE("terminal","unicode")=DEF("unicode")
	SET STATE("terminal","rows")=+$$GETP(USER,"rows",DEF("rows"))
	IF STATE("terminal","rows")<20 SET STATE("terminal","rows")=DEF("rows")
	IF STATE("terminal","rows")>60 SET STATE("terminal","rows")=DEF("rows")
	SET STATE("terminal","cols")=+$$GETP(USER,"cols",DEF("cols"))
	IF STATE("terminal","cols")<80 SET STATE("terminal","cols")=DEF("cols")
	IF STATE("terminal","cols")>220 SET STATE("terminal","cols")=DEF("cols")
	QUIT
	;
GETP(USER,KEY,DEF)
	NEW X
	SET X=$GET(^MIO("MIOMOS","PREF",$GET(USER),"terminal",$GET(KEY)))
	IF X'="" QUIT X
	QUIT $GET(DEF)
	;
SAVEPROF(USER,TREE,OUT,ERR)
	NEW VAL
	KILL OUT
	SET ERR("routine")="MIOMOSTERM"
	IF $GET(USER)="" SET ERR("error")="principal_missing" QUIT 0
	IF $DATA(TREE("fontFamily")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$FONTOK($GET(TREE("fontFamily"))) IF VAL="" SET ERR("error")="terminal_font_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"terminal","fontFamily")=VAL
	IF $DATA(TREE("fontSize")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$FONTSIZE(+$GET(TREE("fontSize"))) IF VAL<1 SET ERR("error")="terminal_font_size_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"terminal","fontSize")=VAL
	IF $DATA(TREE("cursorBlink")) DO
	. SET ^MIO("MIOMOS","PREF",USER,"terminal","cursorBlink")=$SELECT(+$GET(TREE("cursorBlink")):1,1:0)
	IF $DATA(TREE("cursorStyle")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$CURSOROK($GET(TREE("cursorStyle"))) IF VAL="" SET ERR("error")="terminal_cursor_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"terminal","cursorStyle")=VAL
	IF $DATA(TREE("scrollback")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$SCROLLBACK(+$GET(TREE("scrollback"))) IF VAL<1 SET ERR("error")="terminal_scrollback_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"terminal","scrollback")=VAL
	IF $DATA(TREE("renderer")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$RENDEREROK($GET(TREE("renderer"))) IF VAL="" SET ERR("error")="terminal_renderer_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"terminal","renderer")=VAL
	IF $DATA(TREE("unicode")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$UNICODEOK($GET(TREE("unicode"))) IF VAL="" SET ERR("error")="terminal_unicode_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"terminal","unicode")=VAL
	IF $DATA(TREE("rows")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$ROWS(+$GET(TREE("rows"))) IF VAL<1 SET ERR("error")="terminal_rows_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"terminal","rows")=VAL
	IF $DATA(TREE("cols")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$COLS(+$GET(TREE("cols"))) IF VAL<1 SET ERR("error")="terminal_cols_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"terminal","cols")=VAL
	SET ^MIO("MIOMOS","PREF",USER,"terminal","savedAt")=$$NOWISO^MIOUTIL()
	DO CURRENT(USER,.OUT)
	QUIT 1
	;
CURRENT(USER,OUT)
	NEW STATE,CONF
	KILL OUT
	SET STATE("principal")=$GET(USER)
	DO LOADTERM(.STATE,.CONF)
	MERGE OUT("current")=STATE("terminal")
	DO CATALOG($NAME(OUT("catalog")))
	QUIT
	;
CATALOG(ROOT)
	KILL @ROOT
	DO OPTS($NAME(@ROOT@("fonts")),"JetBrains Mono^JetBrains Mono,IBM Plex Mono^IBM Plex Mono,Fira Code^Fira Code,Cascadia Mono^Cascadia Mono")
	DO INTOPTS($NAME(@ROOT@("fontSizes")),12,18)
	DO BOOL($NAME(@ROOT@("cursorBlink")))
	DO OPTS($NAME(@ROOT@("cursorStyles")),"block^Block,underline^Underline,bar^Bar")
	DO VALUEOPTS($NAME(@ROOT@("scrollbacks")),"2000^2,000 lines^2000,3000^3,000 lines^3000,5000^5,000 lines^5000,10000^10,000 lines^10000")
	DO OPTS($NAME(@ROOT@("renderers")),"canvas^Canvas,dom^DOM")
	DO OPTS($NAME(@ROOT@("unicodeModes")),"unicode11^Unicode 11,graphemes^Grapheme experimental")
	DO VALUEOPTS($NAME(@ROOT@("rows")),"24^24 rows^24,28^28 rows^28,32^32 rows^32,36^36 rows^36")
	DO VALUEOPTS($NAME(@ROOT@("cols")),"100^100 cols^100,120^120 cols^120,132^132 cols^132,160^160 cols^160")
	DO OPTS($NAME(@ROOT@("transport")),"pipe^YottaDB PIPE WebSocket")
	QUIT
	;
BOOL(ROOT)
	KILL @ROOT
	SET @ROOT@(1,"key")=1,@ROOT@(1,"label")="On"
	SET @ROOT@(2,"key")=0,@ROOT@(2,"label")="Off"
	QUIT
	;
OPTS(ROOT,CSV)
	NEW I,N,ITEM
	KILL @ROOT
	SET N=0
	FOR I=1:1:$LENGTH($GET(CSV),",") DO
	. SET ITEM=$PIECE(CSV,",",I)
	. IF ITEM="" QUIT
	. SET N=N+1
	. SET @ROOT@(N,"key")=$PIECE(ITEM,"^",1)
	. SET @ROOT@(N,"label")=$PIECE(ITEM,"^",2)
	QUIT
	;
VALUEOPTS(ROOT,CSV)
	NEW I,N,ITEM
	KILL @ROOT
	SET N=0
	FOR I=1:1:$LENGTH($GET(CSV),",") DO
	. SET ITEM=$PIECE(CSV,",",I)
	. IF ITEM="" QUIT
	. SET N=N+1
	. SET @ROOT@(N,"key")=$PIECE(ITEM,"^",1)
	. SET @ROOT@(N,"label")=$PIECE(ITEM,"^",2)
	. SET @ROOT@(N,"value")=$PIECE(ITEM,"^",3)
	QUIT
	;
INTOPTS(ROOT,START,STOP)
	NEW N,V
	KILL @ROOT
	SET N=0
	FOR V=+START:1:+STOP DO
	. SET N=N+1
	. SET @ROOT@(N,"key")=V
	. SET @ROOT@(N,"label")=V_" px"
	QUIT
	;
FONTOK(X)
	SET X=$$TRIM^MIOUTIL($GET(X))
	IF X="JetBrains Mono" QUIT X
	IF X="IBM Plex Mono" QUIT X
	IF X="Fira Code" QUIT X
	IF X="Cascadia Mono" QUIT X
	QUIT ""
	;
FONTSIZE(N)
	IF N<12 QUIT 0
	IF N>18 QUIT 0
	QUIT N
	;
CURSOROK(X)
	SET X=$$TRIM^MIOUTIL($GET(X))
	IF X="block"!(X="underline")!(X="bar") QUIT X
	QUIT ""
	;
SCROLLBACK(N)
	IF N<1000 QUIT 0
	IF N>10000 QUIT 0
	QUIT N
	;
RENDEREROK(X)
	SET X=$$TRIM^MIOUTIL($GET(X))
	IF X="canvas"!(X="dom") QUIT X
	QUIT ""
	;
UNICODEOK(X)
	SET X=$$TRIM^MIOUTIL($GET(X))
	IF X="unicode11"!(X="graphemes") QUIT X
	QUIT ""
	;
ROWS(N)
	IF N<20 QUIT 0
	IF N>60 QUIT 0
	QUIT N
	;
COLS(N)
	IF N<80 QUIT 0
	IF N>220 QUIT 0
	QUIT N
	;
OPEN(STATE,CONF,TERMID,OUT,ERR)
	NEW SID,TERMROOT
	KILL OUT,ERR
	SET ERR("routine")="MIOMOSTERM"
	DO LOADTERM(.STATE,.CONF)
	SET SID=$GET(STATE("sessionId"))
	IF SID="" SET ERR("error")="session_missing" QUIT 0
	IF $GET(TERMID)="" SET TERMID=$GET(^MIO("MIOMOS","TERM","BYSESSION",SID))
	IF TERMID="" SET TERMID="term-"_$$UUID^MIOUTIL()
	SET TERMROOT=$NAME(^MIO("MIOMOS","TERM","SESSION",TERMID))
	IF '$DATA(@TERMROOT@("createdAt")) DO
	. DO INITTERM(TERMROOT,.STATE,TERMID)
	. DO ADDLINE(TERMROOT,$$BANNER(.STATE))
	. DO ADDLINE(TERMROOT,"Type help for commands, clear to reset the viewport, and exit to close this terminal.")
	. DO ADDLINE(TERMROOT,$$PROMPT(.STATE))
	SET ^MIO("MIOMOS","TERM","BYSESSION",SID)=TERMID
	SET @TERMROOT@("lastAt")=$$NOWISO^MIOUTIL()
	DO PROFILEOUT(.STATE,.OUT)
	SET OUT("ok")=1
	SET OUT("terminalId")=TERMID
	SET OUT("opened")=1
	DO SNAPSHOT(TERMID,.OUT)
	QUIT 1
	;
ATTACH(STATE,TERMID,OUT,ERR)
	NEW CONF
	KILL OUT,ERR
	SET ERR("routine")="MIOMOSTERM"
	DO LOADTERM(.STATE,.CONF)
	IF $GET(TERMID)="" SET TERMID=$GET(^MIO("MIOMOS","TERM","BYSESSION",$GET(STATE("sessionId"))))
	IF TERMID="" QUIT $$OPEN(.STATE,.CONF,TERMID,.OUT,.ERR)
	IF '$DATA(^MIO("MIOMOS","TERM","SESSION",TERMID,"createdAt")) SET ERR("error")="terminal_not_found" QUIT 0
	IF $GET(^MIO("MIOMOS","TERM","SESSION",TERMID,"principal"))'=$GET(STATE("principal")) SET ERR("error")="terminal_forbidden" QUIT 0
	SET ^MIO("MIOMOS","TERM","SESSION",TERMID,"lastAt")=$$NOWISO^MIOUTIL()
	DO PROFILEOUT(.STATE,.OUT)
	SET OUT("ok")=1,OUT("terminalId")=TERMID,OUT("attached")=1
	DO SNAPSHOT(TERMID,.OUT)
	QUIT 1
	;
INPUT(STATE,TERMID,LINE,OUT,ERR)
	NEW ROOT,CMD,CNT,OBS
	KILL OUT,ERR
	SET ERR("routine")="MIOMOSTERM"
	SET ROOT=$NAME(^MIO("MIOMOS","TERM","SESSION",$GET(TERMID)))
	IF '$DATA(@ROOT@("createdAt")) SET ERR("error")="terminal_not_found" QUIT 0
	IF $GET(@ROOT@("principal"))'=$GET(STATE("principal")) SET ERR("error")="terminal_forbidden" QUIT 0
	SET @ROOT@("lastAt")=$$NOWISO^MIOUTIL()
	SET LINE=$$TRIM^MIOUTIL($GET(LINE))
	DO ADDHIST(ROOT,LINE)
	SET OUT("ok")=1,OUT("terminalId")=$GET(TERMID)
	IF LINE="" DO  QUIT 1
	. DO ADDLINE(ROOT,$$PROMPT(.STATE))
	. DO PENDING(ROOT,.OUT)
	SET CMD=$$LC($PIECE(LINE," ",1))
	IF CMD="clear" DO  QUIT 1
	. KILL @ROOT@("line")
	. SET @ROOT@("lineSeq")=0
	. SET OUT("clear")=1
	. DO ADDLINE(ROOT,$$BANNER(.STATE))
	. DO ADDLINE(ROOT,$$PROMPT(.STATE))
	. DO PENDING(ROOT,.OUT)
	IF CMD="help" DO  QUIT 1
	. DO ADDLINE(ROOT,"Commands: help, whoami, roles, date, theme, settings, profile, logs, history, clear, exit")
	. DO ADDLINE(ROOT,$$PROMPT(.STATE))
	. DO PENDING(ROOT,.OUT)
	IF CMD="whoami" DO  QUIT 1
	. DO ADDLINE(ROOT,$GET(STATE("principal")))
	. DO ADDLINE(ROOT,$$PROMPT(.STATE))
	. DO PENDING(ROOT,.OUT)
	IF CMD="roles" DO  QUIT 1
	. DO ADDLINE(ROOT,$GET(STATE("roles")))
	. DO ADDLINE(ROOT,$$PROMPT(.STATE))
	. DO PENDING(ROOT,.OUT)
	IF CMD="date" DO  QUIT 1
	. DO ADDLINE(ROOT,$$NOWISO^MIOUTIL())
	. DO ADDLINE(ROOT,$$PROMPT(.STATE))
	. DO PENDING(ROOT,.OUT)
	IF CMD="theme" DO  QUIT 1
	. DO ADDLINE(ROOT,"Theme "_$GET(STATE("themeKey"))_" · Accent "_$GET(STATE("titleAccentValue")))
	. DO ADDLINE(ROOT,$$PROMPT(.STATE))
	. DO PENDING(ROOT,.OUT)
	IF CMD="settings" DO  QUIT 1
	. DO ADDLINE(ROOT,"Desktop "_$GET(STATE("fontFamily"))_" "_$GET(STATE("fontSize"))_"px · "_$GET(STATE("density"))_" · "_$GET(STATE("wallpaper")))
	. DO ADDLINE(ROOT,$$PROMPT(.STATE))
	. DO PENDING(ROOT,.OUT)
	IF CMD="profile" DO  QUIT 1
	. DO ADDLINE(ROOT,"Terminal "_$GET(STATE("terminal","fontFamily"))_" "_$GET(STATE("terminal","fontSize"))_"px · "_$GET(STATE("terminal","renderer"))_" · "_$GET(STATE("terminal","unicode")))
	. DO ADDLINE(ROOT,"Cursor "_$GET(STATE("terminal","cursorStyle"))_" · Blink "_$GET(STATE("terminal","cursorBlink"))_" · "_$GET(STATE("terminal","cols"))_"x"_$GET(STATE("terminal","rows")))
	. DO ADDLINE(ROOT,$$PROMPT(.STATE))
	. DO PENDING(ROOT,.OUT)
	IF CMD="logs" DO  QUIT 1
	. DO COUNTS^MIOMOSOBS(.OBS)
	. DO ADDLINE(ROOT,"Access "_$GET(OBS("access"))_" · Error "_$GET(OBS("error"))_" · Audit "_$GET(OBS("audit")))
	. DO ADDLINE(ROOT,$$PROMPT(.STATE))
	. DO PENDING(ROOT,.OUT)
	IF CMD="history" DO  QUIT 1
	. SET CNT=+$GET(@ROOT@("historySeq"))
	. IF CNT<1 DO ADDLINE(ROOT,"No history yet.")
	. FOR  QUIT:CNT<1  DO  QUIT:CNT<1
	. . DO ADDLINE(ROOT,$GET(@ROOT@("history",CNT)))
	. . SET CNT=CNT-1
	. . IF CNT<+$GET(@ROOT@("historySeq"))-4 SET CNT=0
	. DO ADDLINE(ROOT,$$PROMPT(.STATE))
	. DO PENDING(ROOT,.OUT)
	IF CMD="exit" QUIT $$CLOSE(.STATE,TERMID,.OUT,.ERR)
	DO ADDLINE(ROOT,LINE_": command not found")
	DO ADDLINE(ROOT,$$PROMPT(.STATE))
	DO PENDING(ROOT,.OUT)
	QUIT 1
	;
RESIZE(STATE,TERMID,COLS,ROWS,OUT,ERR)
	NEW ROOT
	KILL OUT,ERR
	SET ERR("routine")="MIOMOSTERM"
	SET ROOT=$NAME(^MIO("MIOMOS","TERM","SESSION",$GET(TERMID)))
	IF '$DATA(@ROOT@("createdAt")) SET ERR("error")="terminal_not_found" QUIT 0
	SET COLS=$$COLS(+$GET(COLS)) IF COLS<1 SET COLS=120
	SET ROWS=$$ROWS(+$GET(ROWS)) IF ROWS<1 SET ROWS=28
	SET @ROOT@("cols")=COLS,@ROOT@("rows")=ROWS,@ROOT@("lastAt")=$$NOWISO^MIOUTIL()
	SET OUT("ok")=1,OUT("terminalId")=$GET(TERMID),OUT("cols")=COLS,OUT("rows")=ROWS
	QUIT 1
	;
CLOSE(STATE,TERMID,OUT,ERR)
	NEW ROOT,SID
	KILL OUT,ERR
	SET ERR("routine")="MIOMOSTERM"
	SET ROOT=$NAME(^MIO("MIOMOS","TERM","SESSION",$GET(TERMID)))
	IF '$DATA(@ROOT@("createdAt")) SET ERR("error")="terminal_not_found" QUIT 0
	SET SID=$GET(@ROOT@("sessionId"))
	SET @ROOT@("status")="closed",@ROOT@("closedAt")=$$NOWISO^MIOUTIL()
	KILL ^MIO("MIOMOS","TERM","BYSESSION",SID)
	SET OUT("ok")=1,OUT("terminalId")=$GET(TERMID),OUT("closed")=1
	SET OUT("write",1)="Terminal session closed."_$CHAR(13,10)
	QUIT 1
	;
PROFILEOUT(STATE,OUT)
	MERGE OUT("profile")=STATE("terminal")
	QUIT
	;
SNAPSHOT(TERMID,OUT)
	NEW ROOT,N,START,COUNT
	SET ROOT=$NAME(^MIO("MIOMOS","TERM","SESSION",$GET(TERMID)))
	KILL OUT("write")
	SET COUNT=0
	SET START=+$GET(@ROOT@("lineSeq"))-24 IF START<1 SET START=1
	SET N=START-1
	FOR  SET N=$ORDER(@ROOT@("line",N)) QUIT:N=""  DO
	. SET COUNT=COUNT+1
	. SET OUT("write",COUNT)=$GET(@ROOT@("line",N))_$CHAR(13,10)
	QUIT
	;
PENDING(ROOT,OUT)
	NEW N,COUNT,LAST
	KILL OUT("write")
	SET COUNT=0,LAST=+$GET(@ROOT@("lineSeq"))
	SET N=LAST-8 IF N<1 SET N=0
	FOR  SET N=$ORDER(@ROOT@("line",N)) QUIT:N=""  DO
	. SET COUNT=COUNT+1
	. SET OUT("write",COUNT)=$GET(@ROOT@("line",N))_$CHAR(13,10)
	QUIT
	;
INITTERM(ROOT,STATE,TERMID)
	SET @ROOT@("id")=$GET(TERMID)
	SET @ROOT@("principal")=$GET(STATE("principal"))
	SET @ROOT@("sessionId")=$GET(STATE("sessionId"))
	SET @ROOT@("createdAt")=$$NOWISO^MIOUTIL()
	SET @ROOT@("status")="open"
	SET @ROOT@("cols")=+$GET(STATE("terminal","cols"),120)
	SET @ROOT@("rows")=+$GET(STATE("terminal","rows"),28)
	SET @ROOT@("renderer")=$GET(STATE("terminal","renderer"),"canvas")
	SET @ROOT@("unicode")=$GET(STATE("terminal","unicode"),"unicode11")
	SET @ROOT@("fontFamily")=$GET(STATE("terminal","fontFamily"),"JetBrains Mono")
	SET @ROOT@("fontSize")=+$GET(STATE("terminal","fontSize"),13)
	QUIT
	;
ADDLINE(ROOT,TEXT)
	NEW N
	SET N=+$GET(@ROOT@("lineSeq"))+1
	SET @ROOT@("lineSeq")=N
	SET @ROOT@("line",N)=$GET(TEXT)
	QUIT
	;
ADDHIST(ROOT,LINE)
	NEW N
	IF $GET(LINE)="" QUIT
	SET N=+$GET(@ROOT@("historySeq"))+1
	SET @ROOT@("historySeq")=N
	SET @ROOT@("history",N)=$GET(LINE)
	QUIT
	;
BANNER(STATE)
	QUIT "MIOMOS Terminal · "_$GET(STATE("userName"))_" · "_$GET(STATE("profile"))
	;
PROMPT(STATE)
	QUIT $GET(STATE("principal"),"user")_"@miomos:$ "
	;
LC(X)
	NEW Y
	SET Y=$TRANSLATE($GET(X),"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")
	QUIT $$TRIM^MIOUTIL(Y)
	;
