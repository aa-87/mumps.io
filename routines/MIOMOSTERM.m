MIOMOSTERM ; MIOMOS terminal foundation helpers
	QUIT
	;
LOADTERM(STATE,CONF)
	NEW USER,DEF
	SET USER=$GET(STATE("principal"))
	SET DEF("fontFamily")=$GET(CONF("miomos","terminal","default","fontFamily"),"Consolas")
	SET DEF("fontSize")=+$GET(CONF("miomos","terminal","default","fontSize"),13)
	SET DEF("cursorBlink")=+$GET(CONF("miomos","terminal","default","cursorBlink"),1)
	SET DEF("cursorStyle")=$GET(CONF("miomos","terminal","default","cursorStyle"),"block")
	SET DEF("scrollback")=+$GET(CONF("miomos","terminal","default","scrollback"),3000)
	SET DEF("renderer")=$GET(CONF("miomos","terminal","default","renderer"),"canvas")
	SET DEF("sizeMode")=$GET(CONF("miomos","terminal","default","sizeMode"),"fit-container")
	SET DEF("unicode")=$GET(CONF("miomos","terminal","default","unicode"),"unicode11")
	SET DEF("rows")=+$GET(CONF("miomos","terminal","default","rows"),28)
	SET DEF("cols")=+$GET(CONF("miomos","terminal","default","cols"),120)
	SET DEF("palette")=$GET(CONF("miomos","terminal","default","palette"),"theme")
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
	SET STATE("terminal","sizeMode")=$$SIZEOK($$GETP(USER,"sizeMode",DEF("sizeMode")))
	IF STATE("terminal","sizeMode")="" SET STATE("terminal","sizeMode")=DEF("sizeMode")
	SET STATE("terminal","rows")=+$$GETP(USER,"rows",DEF("rows"))
	IF STATE("terminal","rows")<20 SET STATE("terminal","rows")=DEF("rows")
	IF STATE("terminal","rows")>60 SET STATE("terminal","rows")=DEF("rows")
	SET STATE("terminal","cols")=+$$GETP(USER,"cols",DEF("cols"))
	IF STATE("terminal","cols")<80 SET STATE("terminal","cols")=DEF("cols")
	IF STATE("terminal","cols")>220 SET STATE("terminal","cols")=DEF("cols")
	SET STATE("terminal","palette")=$$PALOK($$GETP(USER,"palette",DEF("palette")))
	IF STATE("terminal","palette")="" SET STATE("terminal","palette")=DEF("palette")
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
	IF $DATA(TREE("sizeMode")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$SIZEOK($GET(TREE("sizeMode"))) IF VAL="" SET ERR("error")="terminal_size_mode_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"terminal","sizeMode")=VAL
	IF $DATA(TREE("unicode")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$UNICODEOK($GET(TREE("unicode"))) IF VAL="" SET ERR("error")="terminal_unicode_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"terminal","unicode")=VAL
	IF $DATA(TREE("rows")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$ROWS(+$GET(TREE("rows"))) IF VAL<1 SET ERR("error")="terminal_rows_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"terminal","rows")=VAL
	IF $DATA(TREE("cols")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$COLS(+$GET(TREE("cols"))) IF VAL<1 SET ERR("error")="terminal_cols_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"terminal","cols")=VAL
	IF $DATA(TREE("palette")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$PALOK($GET(TREE("palette"))) IF VAL="" SET ERR("error")="terminal_palette_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"terminal","palette")=VAL
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
	DO OPTS($NAME(@ROOT@("fonts")),"Consolas^Consolas,JetBrains Mono^JetBrains Mono,IBM Plex Mono^IBM Plex Mono,Fira Code^Fira Code,Cascadia Mono^Cascadia Mono,Source Code Pro^Source Code Pro")
	DO INTOPTS($NAME(@ROOT@("fontSizes")),12,18)
	DO BOOL($NAME(@ROOT@("cursorBlink")))
	DO OPTS($NAME(@ROOT@("cursorStyles")),"block^Block,underline^Underline,bar^Bar")
	DO VALUEOPTS($NAME(@ROOT@("scrollbacks")),"2000^2,000 lines^2000,3000^3,000 lines^3000,5000^5,000 lines^5000,10000^10,000 lines^10000")
	DO OPTS($NAME(@ROOT@("renderers")),"canvas^Canvas,dom^DOM")
	DO OPTS($NAME(@ROOT@("sizeModes")),"fit-container^Fit terminal to window,fixed-grid^Use saved rows and cols")
	DO OPTS($NAME(@ROOT@("unicodeModes")),"unicode11^Unicode 11,graphemes^Grapheme experimental")
	DO VALUEOPTS($NAME(@ROOT@("rows")),"24^24 rows^24,28^28 rows^28,32^32 rows^32,36^36 rows^36")
	DO VALUEOPTS($NAME(@ROOT@("cols")),"100^100 cols^100,120^120 cols^120,132^132 cols^132,160^160 cols^160")
	DO OPTS($NAME(@ROOT@("palettes")),"theme^Follow Desktop Theme,midnight-blue^Midnight Blue,black-on-white^Black on White,white-on-black^White on Black")
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
	IF X="Consolas" QUIT X
	IF X="Source Code Pro" QUIT X
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
SIZEOK(X)
	SET X=$$TRIM^MIOUTIL($GET(X))
	IF X="fit-container"!(X="fixed-grid") QUIT X
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
PALOK(X)
	SET X=$$TRIM^MIOUTIL($GET(X))
	IF X="theme"!(X="midnight-blue")!(X="black-on-white")!(X="white-on-black") QUIT X
	QUIT ""
	;
OPEN(STATE,CONF,TERMID,OUT,ERR)
	QUIT $$OPEN^MIOMOSTPIPE(.STATE,.CONF,$GET(TERMID),.OUT,.ERR)
	;
ATTACH(STATE,TERMID,OUT,ERR)
	NEW CONF
	QUIT $$ATTACH^MIOMOSTPIPE(.STATE,$GET(TERMID),.OUT,.ERR)
	;
POLL(STATE,TERMID,OUT,ERR)
	QUIT $$POLL^MIOMOSTPIPE(.STATE,$GET(TERMID),.OUT,.ERR)
	;
INPUT(STATE,TERMID,LINE,OUT,ERR)
	NEW DATA
	SET DATA=$GET(LINE)
	IF DATA'="",($EXTRACT(DATA,$LENGTH(DATA))'=$CHAR(10)),($EXTRACT(DATA,$LENGTH(DATA))'=$CHAR(13)) SET DATA=DATA_$CHAR(10)
	QUIT $$INPUT^MIOMOSTPIPE(.STATE,$GET(TERMID),DATA,.OUT,.ERR)
	;
FINISH(ROOT,SID,FROMSEQ,OUT)
	DO DELTA(ROOT,FROMSEQ,.OUT)
	DO SETCURSOR(ROOT,SID,+$GET(@ROOT@("lineSeq")))
	QUIT 1
	;
RESIZE(STATE,TERMID,COLS,ROWS,OUT,ERR)
	QUIT $$RESIZE^MIOMOSTPIPE(.STATE,$GET(TERMID),+$GET(COLS),+$GET(ROWS),.OUT,.ERR)
	;
CLOSE(STATE,TERMID,OUT,ERR)
	QUIT $$CLOSE^MIOMOSTPIPE(.STATE,$GET(TERMID),.OUT,.ERR)
	;
PROFILEOUT(STATE,ROOT,OUT)
	MERGE OUT("profile")=STATE("terminal")
	SET OUT("prompt")=$$PROMPT(.STATE,$GET(@ROOT@("cwd"),"/"))
	SET OUT("cwd")=$GET(@ROOT@("cwd"),"/")
	SET OUT("transport")="miomos-shell"
	QUIT
	;
SNAPSHOT(TERMID,OUT)
	NEW ROOT,N,COUNT
	SET ROOT=$NAME(^MIO("MIOMOS","TERM","SESSION",$GET(TERMID)))
	KILL OUT("write")
	SET COUNT=0,N=0
	FOR  SET N=$ORDER(@ROOT@("line",N)) QUIT:N=""  DO
	. SET COUNT=COUNT+1
	. SET OUT("write",COUNT)=$GET(@ROOT@("line",N))_$CHAR(13,10)
	SET OUT("seq")=+$GET(@ROOT@("lineSeq"))
	QUIT
	;
DELTA(ROOT,FROMSEQ,OUT)
	NEW N,COUNT,LAST
	KILL OUT("write")
	SET COUNT=0,LAST=+$GET(@ROOT@("lineSeq"))
	SET N=+$GET(FROMSEQ)
	FOR  SET N=$ORDER(@ROOT@("line",N)) QUIT:N=""  DO
	. SET COUNT=COUNT+1
	. SET OUT("write",COUNT)=$GET(@ROOT@("line",N))_$CHAR(13,10)
	SET OUT("seq")=LAST
	QUIT
	;
GETCURSOR(ROOT,SID)
	QUIT +$GET(^MIO("MIOMOS","TERM","CURSOR",$GET(SID),$GET(@ROOT@("id"))))
	;
SETCURSOR(ROOT,SID,SEQ)
	IF $GET(SID)="" QUIT
	SET ^MIO("MIOMOS","TERM","CURSOR",SID,$GET(@ROOT@("id")))=+$GET(SEQ)
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
	SET @ROOT@("sizeMode")=$GET(STATE("terminal","sizeMode"),"fit-container")
	SET @ROOT@("unicode")=$GET(STATE("terminal","unicode"),"unicode11")
	SET @ROOT@("fontFamily")=$GET(STATE("terminal","fontFamily"),"Consolas")
	SET @ROOT@("fontSize")=+$GET(STATE("terminal","fontSize"),13)
	SET @ROOT@("cwd")="/home/"_$GET(STATE("principal"),"user")
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
HELP(ROOT)
	DO ADDLINE(ROOT,"Commands:")
	DO ADDLINE(ROOT,"  help      Show this command list")
	DO ADDLINE(ROOT,"  whoami    Show the current principal")
	DO ADDLINE(ROOT,"  pwd       Show the current working directory")
	DO ADDLINE(ROOT,"  ls        List pseudo workspace files")
	DO ADDLINE(ROOT,"  cd <dir>  Change pseudo working directory")
	DO ADDLINE(ROOT,"  cat <f>   Display a pseudo file")
	DO ADDLINE(ROOT,"  history   Show recent command history")
	DO ADDLINE(ROOT,"  clear     Clear the terminal viewport")
	DO ADDLINE(ROOT,"  exit      Close the current terminal session")
	QUIT
	;
LISTDIR(ROOT,PATH,STATE)
	NEW P,HOME
	SET P=$$NORMPATH($GET(PATH)),HOME="/home/"_$GET(STATE("principal"),"user")
	IF '$$VALIDDIR(P,.STATE) DO ADDLINE(ROOT,"ls: cannot access '"_P_"': No such directory") QUIT
	IF P="/" DO  QUIT
	. DO ADDLINE(ROOT,"home/")
	. DO ADDLINE(ROOT,"workspace/")
	. DO ADDLINE(ROOT,"system/")
	. DO ADDLINE(ROOT,"logs/")
	IF P="/home" DO  QUIT
	. DO ADDLINE(ROOT,$GET(STATE("principal"),"user")_"/")
	IF P=HOME DO  QUIT
	. DO ADDLINE(ROOT,"notes.txt")
	. DO ADDLINE(ROOT,"session.json")
	. DO ADDLINE(ROOT,"apps.lst")
	IF P="/workspace" DO  QUIT
	. DO ADDLINE(ROOT,"queue/")
	. DO ADDLINE(ROOT,"reports/")
	. DO ADDLINE(ROOT,"exports/")
	. DO ADDLINE(ROOT,"README.txt")
	IF P="/system" DO  QUIT
	. DO ADDLINE(ROOT,"build.txt")
	. DO ADDLINE(ROOT,"transport.txt")
	. DO ADDLINE(ROOT,"rights.txt")
	IF P="/logs" DO  QUIT
	. DO ADDLINE(ROOT,"access.log")
	. DO ADDLINE(ROOT,"audit.log")
	. DO ADDLINE(ROOT,"error.log")
	DO ADDLINE(ROOT,"Directory is empty.")
	QUIT
	;
CHDIR(ROOT,ARG,STATE)
	NEW P
	SET P=$$ABSPATH($GET(@ROOT@("cwd"),"/"),$GET(ARG))
	IF '$$VALIDDIR(P,.STATE) DO ADDLINE(ROOT,"cd: no such directory: "_P) QUIT
	SET @ROOT@("cwd")=P
	QUIT
	;
CATFILE(ROOT,PATH,STATE)
	NEW P,OBS,HOME
	SET P=$$NORMPATH($GET(PATH)),HOME="/home/"_$GET(STATE("principal"),"user")
	IF P=(HOME_"/notes.txt") DO  QUIT
	. DO ADDLINE(ROOT,"MIOMOS pseudo shell")
	. DO ADDLINE(ROOT,"This terminal is intentionally lightweight and MUMPS-owned.")
	IF P=(HOME_"/session.json") DO  QUIT
	. DO ADDLINE(ROOT,"{")
	. DO ADDLINE(ROOT,"  ""principal"": """_$GET(STATE("principal"))_""",")
	. DO ADDLINE(ROOT,"  ""sessionId"": """_$GET(STATE("sessionId"))_"""")
	. DO ADDLINE(ROOT,"}")
	IF P=(HOME_"/apps.lst") DO  QUIT
	. DO ADDLINE(ROOT,"workspace")
	. DO ADDLINE(ROOT,"terminal")
	. DO ADDLINE(ROOT,"settings")
	. DO ADDLINE(ROOT,"admin")
	IF P="/workspace/README.txt" DO  QUIT
	. DO ADDLINE(ROOT,"Production workspace")
	. DO ADDLINE(ROOT,"Server-authored windows, taskbar, dialogs, and terminal surfaces.")
	IF P="/system/build.txt" DO  QUIT
	. DO ADDLINE(ROOT,"MIOMOS native shell")
	. DO ADDLINE(ROOT,"Engine: miomos-native-vue-css")
	IF P="/system/transport.txt" DO  QUIT
	. DO ADDLINE(ROOT,"Terminal transport: MUMPS-owned emulator")
	. DO ADDLINE(ROOT,"Frontend: native Vue/CSS replica terminal")
	IF P="/system/rights.txt" DO  QUIT
	. DO ADDLINE(ROOT,"Permissions are evaluated server-side in MUMPS.")
	IF P="/logs/access.log" DO  QUIT
	. DO COUNTS^MIOMOSOBS(.OBS)
	. DO ADDLINE(ROOT,"Recent access events: "_$GET(OBS("access")))
	IF P="/logs/audit.log" DO  QUIT
	. DO COUNTS^MIOMOSOBS(.OBS)
	. DO ADDLINE(ROOT,"Recent audit events: "_$GET(OBS("audit")))
	IF P="/logs/error.log" DO  QUIT
	. DO COUNTS^MIOMOSOBS(.OBS)
	. DO ADDLINE(ROOT,"Recent error events: "_$GET(OBS("error")))
	DO ADDLINE(ROOT,"cat: "_P_": No such file")
	QUIT
	;
VALIDDIR(PATH,STATE)
	NEW P,HOME
	SET P=$$NORMPATH($GET(PATH)),HOME="/home/"_$GET(STATE("principal"),"user")
	IF P="/" QUIT 1
	IF P="/home" QUIT 1
	IF P=HOME QUIT 1
	IF P="/workspace" QUIT 1
	IF P="/system" QUIT 1
	IF P="/logs" QUIT 1
	QUIT 0
	;
ABSPATH(CWD,ARG)
	NEW A
	SET A=$$TRIM^MIOUTIL($GET(ARG))
	IF A=""!(A="~") QUIT $SELECT($PIECE($GET(CWD),"/",3)'="":"/home/"_$PIECE($GET(CWD),"/",3),1:"/home")
	IF $EXTRACT(A,1)="/" QUIT $$NORMPATH(A)
	QUIT $$NORMPATH($GET(CWD,"/")_"/"_A)
	;
NORMPATH(PATH)
	NEW P,I,PART,OUT,SEQ
	SET P=$TRANSLATE($GET(PATH),"\\","/")
	IF P="" SET P="/"
	IF $EXTRACT(P,1)'="/" SET P="/"_P
	FOR  QUIT:P'["//"  SET P=$PIECE(P,"//",1)_"/"_$PIECE(P,"//",2,999)
	KILL OUT SET SEQ=0
	FOR I=1:1:$LENGTH(P,"/") DO
	. SET PART=$PIECE(P,"/",I)
	. IF PART="" QUIT
	. IF PART="." QUIT
	. IF PART=".." DO  QUIT
	. . IF SEQ>0 KILL OUT(SEQ) SET SEQ=SEQ-1
	. SET SEQ=SEQ+1,OUT(SEQ)=PART
	SET P="/"
	FOR I=1:1:SEQ SET P=P_$SELECT(I>1:"/",1:"")_OUT(I)
	QUIT P
	;
SANIN(X)
	NEW Y
	SET Y=$GET(X)
	SET Y=$TRANSLATE(Y,$CHAR(13),"")
	SET Y=$PIECE(Y,$CHAR(10),1)
	QUIT $$TRIMR(Y)
	;
TRIMR(X)
	NEW Y
	SET Y=$GET(X)
	FOR  QUIT:Y=""  QUIT:$EXTRACT(Y,$LENGTH(Y))'=" "  SET Y=$EXTRACT(Y,1,$LENGTH(Y)-1)
	QUIT Y
	;
BANNER(STATE)
	QUIT "MIOMOS Terminal · "_$GET(STATE("userName"))_" · "_$GET(STATE("profile"))
	;
PROMPT(STATE,CWD)
	QUIT $GET(STATE("principal"),"user")_"@miomos:"_$GET(CWD,"/")_"$"
	;
LC(X)
	NEW Y
	SET Y=$TRANSLATE($GET(X),"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")
	QUIT $$TRIM^MIOUTIL(Y)
	;
	;