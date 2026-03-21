MIOIDED ; MIOIDE data, file, compile, run, and search helpers
	Q
	;
BUILDHOME(CONF,REQ,CTX,TCTX)
	N RTNS,ACTIVE,ERR,MAXI,SRC,COUNT,I,NM
	K TCTX
	S TCTX("appName")="MIOIDE"
	S TCTX("appVersion")=$$VERSION^MIOIDE()
	S TCTX("banner")=$$BANNER^MIOIDE()
	S TCTX("themeMode")=$S($G(CONF("mioide","theme","default"))="light":"light",1:"dark")
	S TCTX("pageTitle")="MIOIDE / Debug Workbench"
	S TCTX("heading")="MIOIDE Debug Workbench"
	S TCTX("lead")="Dense SSR-first M routine IDE with Monaco, Xterm.js, live MIOWS terminal transport, and a debugger foundation with breakpoints, watches, and source-mapped stepping."
	S TCTX("statusText")="Ready"
	S TCTX("commandBarLabel")="Command Palette"
	S TCTX("apiBase")="/mioide/api"
	S TCTX("debugApiBase")="/mioide/api/debug"
	S TCTX("debugSessionText")="No active debug session"
	S TCTX("debugReasonText")="Start a session to inspect source-mapped frames"
	S TCTX("saveMethod")="PUT"
	S TCTX("branchName")="main"
	S TCTX("lineInfo")="Ln 1, Col 1"
	S TCTX("indentInfo")="Spaces: 2"
	S TCTX("syntaxInfo")="MUMPS"
	S TCTX("encodingInfo")="UTF-8"
	S TCTX("eolInfo")="LF"
	S TCTX("workspaceState")="Ready"
	S TCTX("connectionText")="Events offline"
	S TCTX("searchPlaceholder")="Search routines or symbols"
	S TCTX("commandPlaceholder")="Type a command or jump to a routine"
	S TCTX("terminalIntro")="Live WebSocket terminal ready. Commands execute inside a controlled MIOIDE session."
	S TCTX("terminalSeed")="MIOIDE terminal"_$C(10)_"MIOWS transport ready"_$C(10)_"Type help for commands"_$C(10)_"YDB> "
	S TCTX("wsEventsUrl")=$G(CONF("mioide","ws","eventsPath"),"/mioide/ws/events")
	S TCTX("wsTerminalUrl")=$G(CONF("mioide","ws","terminalPath"),"/mioide/ws/terminal")
	D LISTRTN(.CONF,$G(REQ("query","q")),.RTNS)
	M TCTX("routines")=RTNS
	S COUNT=$$COUNT(.RTNS)
	S TCTX("routineCount")=COUNT
	S ACTIVE=$G(REQ("query","name"))
	I ACTIVE="" S ACTIVE=$G(RTNS(1,"name"))
	I ACTIVE="" S ACTIVE="MIOIDE"
	S TCTX("activeName")=ACTIVE
	S TCTX("currentPath")="routines/"_ACTIVE_".m"
	S MAXI=+$G(CONF("mioide","editor","maxInitialBytes"),262144)
	S SRC=""
	I ACTIVE'="" D GETSRCTXT(ACTIVE,.CONF,MAXI,.SRC,.ERR)
	I SRC="" S SRC=ACTIVE_" ; MIOIDE scratch routine"_$C(10,9)_"Q"
	S TCTX("initialSource")=SRC
	S I=0
	F  S I=$O(TCTX("routines",I)) Q:'I  D
	. S NM=$G(TCTX("routines",I,"name"))
	. S TCTX("routines",I,"summary")=$S(NM["TEST":"Test harness",NM["AUTH":"Auth module",NM["WS":"WebSocket surface",1:"Routine module")
	. S TCTX("routines",I,"icon")=$S(NM["T":"T",NM["AUTH":"A",NM["WS":"W",1:"M")
	. I NM=ACTIVE S TCTX("routines",I,"isActive")=1
	S TCTX("activity",1,"id")="explorer",TCTX("activity",1,"abbr")="EX",TCTX("activity",1,"icon")="[]",TCTX("activity",1,"label")="Routine explorer",TCTX("activity",1,"isActive")=1
	S TCTX("activity",2,"id")="search",TCTX("activity",2,"abbr")="SR",TCTX("activity",2,"icon")="?/",TCTX("activity",2,"label")="Search"
	S TCTX("activity",3,"id")="debug",TCTX("activity",3,"abbr")="RD",TCTX("activity",3,"icon")="RUN",TCTX("activity",3,"label")="Run and Debug"
	S TCTX("activity",4,"id")="problems",TCTX("activity",4,"abbr")="PB",TCTX("activity",4,"icon")="ERR",TCTX("activity",4,"label")="Problems"
	S TCTX("activity",5,"id")="snippets",TCTX("activity",5,"abbr")="SN",TCTX("activity",5,"icon")="{}",TCTX("activity",5,"label")="Snippet library"
	S TCTX("activity",6,"id")="output",TCTX("activity",6,"abbr")="OU",TCTX("activity",6,"icon")="OUT",TCTX("activity",6,"label")="Output"
	S TCTX("activity",7,"id")="terminal",TCTX("activity",7,"abbr")="TM",TCTX("activity",7,"icon")="$_",TCTX("activity",7,"label")="Terminal"
	S TCTX("activity",8,"id")="palette",TCTX("activity",8,"abbr")="CP",TCTX("activity",8,"icon")="CMD",TCTX("activity",8,"label")="Command Palette"
	S TCTX("activity",9,"id")="theme",TCTX("activity",9,"abbr")="TH",TCTX("activity",9,"icon")="THM",TCTX("activity",9,"label")="Toggle theme"
	S TCTX("watch",1,"name")="REQ(""params"",""name"")",TCTX("watch",1,"value")=ACTIVE
	S TCTX("watch",2,"name")="saveEnabled",TCTX("watch",2,"value")=$S($G(CONF("mioide","save","enabled")):1,1:0)
	S TCTX("watch",3,"name")="$ZSTATUS",TCTX("watch",3,"value")="ready"
	S TCTX("callstack",1,"frame")="HOME^MIOIDER",TCTX("callstack",1,"detail")="SSR route entry",TCTX("callstack",1,"isActive")=1
	S TCTX("callstack",2,"frame")="BUILDHOME^MIOIDED",TCTX("callstack",2,"detail")="Context builder"
	S TCTX("callstack",3,"frame")="RENDERPAGE^MIOTPL",TCTX("callstack",3,"detail")="Layout + page render"
	K TCTX("breakpoint")
	N TARR M TARR=TCTX("breakpoint") D LISTBP^MIOIDBG(ACTIVE,.TARR) K TCTX("breakpoint") M TCTX("breakpoint")=TARR K TARR
	I '$D(TCTX("breakpoint")) D
	. S TCTX("breakpoint",1,"loc")=ACTIVE_"+1",TCTX("breakpoint",1,"detail")="routine entry"
	S TCTX("problem",1,"sevClass")="pill-error",TCTX("problem",1,"sevLabel")="Error",TCTX("problem",1,"file")=ACTIVE_".m",TCTX("problem",1,"line")=42,TCTX("problem",1,"message")="Compiler output and diagnostics surface here"
	S TCTX("problem",2,"sevClass")="pill-warn",TCTX("problem",2,"sevLabel")="Warning",TCTX("problem",2,"file")="MIOIDEWS.m",TCTX("problem",2,"line")=18,TCTX("problem",2,"message")="Interactive sessions run inside a controlled MIOIDE REPL"
	S TCTX("output",1,"text")="[boot] MIOIDE workbench ready"
	S TCTX("output",2,"text")="[events] waiting for WebSocket connection"
	S TCTX("output",3,"text")="[terminal] MIOWS session transport enabled"
	S TCTX("output",4,"text")="[run] Run output will appear here"
	S TCTX("output",5,"text")="[debug] Breakpoints and watch updates stream here"
	S TCTX("palette",1,"id")="save",TCTX("palette",1,"label")="File: Save current routine",TCTX("palette",1,"hint")="Ctrl+S"
	S TCTX("palette",2,"id")="reload",TCTX("palette",2,"label")="File: Reload current routine",TCTX("palette",2,"hint")="Ctrl+R"
	S TCTX("palette",3,"id")="compile",TCTX("palette",3,"label")="Build: Compile current routine",TCTX("palette",3,"hint")="Ctrl+Shift+B"
	S TCTX("palette",4,"id")="run",TCTX("palette",4,"label")="Run: Execute current routine",TCTX("palette",4,"hint")="F5"
	S TCTX("palette",5,"id")="newterm",TCTX("palette",5,"label")="Terminal: New terminal",TCTX("palette",5,"hint")="Ctrl+Shift+`"
	S TCTX("palette",6,"id")="terminal",TCTX("palette",6,"label")="View: Focus terminal dock",TCTX("palette",6,"hint")="Alt+7"
	S TCTX("palette",7,"id")="output",TCTX("palette",7,"label")="View: Focus output dock",TCTX("palette",7,"hint")="Alt+6"
	S TCTX("palette",8,"id")="explorer",TCTX("palette",8,"label")="View: Focus explorer",TCTX("palette",8,"hint")="Alt+1"
	S TCTX("palette",9,"id")="search",TCTX("palette",9,"label")="View: Focus search",TCTX("palette",9,"hint")="Alt+2"
	S TCTX("palette",10,"id")="debug",TCTX("palette",10,"label")="View: Focus Run and Debug",TCTX("palette",10,"hint")="Alt+3"
	S TCTX("palette",11,"id")="snippets",TCTX("palette",11,"label")="View: Focus snippet library",TCTX("palette",11,"hint")="Alt+5"
	S TCTX("palette",12,"id")="problems",TCTX("palette",12,"label")="View: Focus problems",TCTX("palette",12,"hint")="Alt+4"
	S TCTX("palette",13,"id")="theme",TCTX("palette",13,"label")="Preferences: Toggle theme",TCTX("palette",13,"hint")="Ctrl+K Ctrl+T"
	S TCTX("palette",14,"id")="dock",TCTX("palette",14,"label")="View: Toggle bottom panel",TCTX("palette",14,"hint")="Ctrl+J"
	S TCTX("palette",15,"id")="startdebug",TCTX("palette",15,"label")="Debug: Start session",TCTX("palette",15,"hint")="F9"
	S TCTX("palette",16,"id")="continue",TCTX("palette",16,"label")="Debug: Continue",TCTX("palette",16,"hint")="F8"
	S TCTX("palette",17,"id")="stepinto",TCTX("palette",17,"label")="Debug: Step Into",TCTX("palette",17,"hint")="F10"
	S TCTX("palette",18,"id")="stepover",TCTX("palette",18,"label")="Debug: Step Over",TCTX("palette",18,"hint")="F11"
	S TCTX("palette",19,"id")="stopdebug",TCTX("palette",19,"label")="Debug: Stop session",TCTX("palette",19,"hint")="Shift+F5"
	D SNIPS(.TCTX)
	Q
	;
LISTRTN(CONF,Q,OUT)
	N %ZR,PAT,NAME,IDX,LIM,QQ,KEY
	K OUT,%ZR
	S LIM=+$G(CONF("mioide","explorer","limit"),250)
	I LIM<1 S LIM=250
	S QQ=$$LOW($G(Q))
	S PAT=$S(QQ'="":$ZCONVERT($G(Q),"U")_"*",1:"*")
	D SILENT^%RSEL(PAT,"CALL")
	S NAME="",IDX=0
	F  S NAME=$O(%ZR(NAME)) Q:NAME=""  D  Q:IDX'<LIM
	. I '$$ISRTN(NAME) Q
	. I QQ'="",$$LOW(NAME)'[QQ Q
	. S IDX=IDX+1
	. S OUT(IDX,"name")=NAME
	. S OUT(IDX,"href")="/mioide?name="_$$URLENC(NAME)
	. S OUT(IDX,"kind")="routine"
	. S OUT(IDX,"path")=$G(%ZR(NAME))_NAME_".m"
	. S KEY=$$PKG(NAME)
	. S OUT(IDX,"pkg")=KEY
	K %ZR
	Q
	;
LOADSRC(RTN,CONF,OUT,ERR)
	N MAX
	K ERR
	S OUT=""
	I '$$ISRTN($G(RTN)) S ERR("error")="invalid_routine" Q 0
	I '$$FILEX($$ROUTEPATH(RTN,.CONF)) S ERR("error")="not_found" Q 0
	S MAX=+$G(CONF("mioide","editor","maxInitialBytes"),262144)
	D GETSRCTXT(RTN,.CONF,MAX,.OUT,.ERR)
	Q $S($D(ERR("error")):0,1:1)
	;
GETSRCTXT(RTN,CONF,MAX,OUT,ERR)
	N PATH,LINES,OK,I,LEN,LINE,TRUNC
	K ERR
	S OUT=""
	I '$$ISRTN($G(RTN)) S ERR("error")="invalid_routine" Q
	S PATH=$$ROUTEPATH(RTN,.CONF)
	S OK=$$READARR(PATH,.LINES,.ERR)
	I 'OK Q
	S LEN=0,TRUNC=0,I=0
	F  S I=$O(LINES(I)) Q:'I  D  Q:TRUNC
	. S LINE=$G(LINES(I))
	. I I>1 D  Q:TRUNC
	. . I LEN+1>MAX S TRUNC=1 Q
	. . S OUT=OUT_$C(10),LEN=LEN+1
	. I LEN+$L(LINE)>MAX S OUT=OUT_$E(LINE,1,MAX-LEN),TRUNC=1,LEN=MAX Q
	. S OUT=OUT_LINE,LEN=LEN+$L(LINE)
	I TRUNC S ERR("truncated")=1
	Q
	;
WRITEREQ(RTN,REQ,CONF,ERR,SIZE)
	N PATH,OIO,CUR,CH,OK,DIR
	K ERR
	S SIZE=0
	I '$$ISRTN($G(RTN)) S ERR("error")="invalid_routine" Q 0
	S DIR=$$RDIR(.CONF)
	D ENSDIR(DIR)
	S PATH=$$ROUTEPATH(RTN,.CONF)
	S OIO=$IO
	OPEN PATH:(NEWVERSION:STREAM):1 ELSE  S ERR("error")="open_failed" Q 0
	USE PATH
	D BODYOPEN^MIOHTTP(.REQ,.CUR)
	S OK=0
	F  Q:'$$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH)  D
	. W CH
	. S SIZE=SIZE+$L(CH),OK=1
	CLOSE PATH
	USE OIO
	I 'OK,$G(REQ("body","len"),0)=0 S ERR("error")="empty_body" Q 0
	Q 1
	;
SAVETEXT(RTN,TEXT,CONF,ERR)
	N PATH,OIO,DIR
	K ERR
	I '$$ISRTN($G(RTN)) S ERR("error")="invalid_routine" Q 0
	S DIR=$$RDIR(.CONF)
	D ENSDIR(DIR)
	S PATH=$$ROUTEPATH(RTN,.CONF)
	S OIO=$IO
	OPEN PATH:(NEWVERSION:STREAM):1 ELSE  S ERR("error")="open_failed" Q 0
	USE PATH W $G(TEXT)
	CLOSE PATH
	USE OIO
	Q 1
	;
COMPILE(RTN,CONF,RES)
	N CMD,ZCS
	K RES
	S RES("routine")="MIOIDED"
	S RES("name")=$G(RTN)
	I '$G(CONF("mioide","compile","enabled")) S RES("ok")=0,RES("error")="compile_disabled" Q:$Q 0 Q
	I '$$ISRTN($G(RTN)) S RES("ok")=0,RES("error")="invalid_routine" Q:$Q 0 Q
	I '$$FILEX($$ROUTEPATH(RTN,.CONF)) S RES("ok")=0,RES("error")="not_found" Q:$Q 0 Q
	S RES("ok")=1,RES("compiled")=0
	S $ETRAP="D CERR^MIOIDED(.RES) Q:$Q 0 Q"
	S CMD="ZLINK """_$G(RTN)_""".m"""
	XECUTE CMD
	S ZCS=+$ZCSTATUS
	S RES("zcstatus")=ZCS
	I ZCS>1 S RES("ok")=0,RES("compiled")=0,RES("error")="compile_failed",RES("status")="compile_failed" Q 0
	S RES("compiled")=1
	S RES("status")="compiled"
	S RES("message")="Routine compiled successfully"
	Q 1
	;
CERR(RES)
	S $ECODE=""
	S RES("ok")=0
	S RES("compiled")=0
	S RES("error")="compile_failed"
	S RES("zstatus")=$ZSTATUS
	Q
	;
RUN(RTN,ENTRY,CONF,RES)
	N OIO,PATH,OUT,ERR,CMD,MAX
	K RES
	S RES("routine")="MIOIDED"
	S RES("name")=$G(RTN)
	S RES("entry")=$G(ENTRY)
	I '$G(CONF("mioide","run","enabled")) S RES("ok")=0,RES("error")="run_disabled" Q 0
	I '$$ISRTN($G(RTN)) S RES("ok")=0,RES("error")="invalid_routine" Q:$Q 0 Q
	I ENTRY'="" D
	. I '$$ISID(ENTRY) S RES("ok")=0,RES("error")="invalid_entry"
	I $G(RES("error"))="invalid_entry" Q 0
	I '$$RUNOK(RTN,.CONF) S RES("ok")=0,RES("error")="run_not_allowed" Q 0
	D ENSDIR($$TDIR(.CONF))
	S PATH=$$RUNPATH(.CONF)
	S OIO=$IO
	OPEN PATH:(NEWVERSION:STREAM):1 ELSE  S RES("ok")=0,RES("error")="open_failed" Q 0
	USE PATH
	S RES("ok")=1
	S $ETRAP="D RERR^MIOIDED(.RES) USE OIO CLOSE PATH Q"
	S CMD=$S(ENTRY'="":"DO "_ENTRY_"^"_RTN,1:"DO ^"_RTN)
	XECUTE CMD
	CLOSE PATH
	USE OIO
	S MAX=+$G(CONF("mioide","run","maxOutputBytes"),131072)
	S OUT=""
	K ERR
	D READTXT(PATH,MAX,.OUT,.ERR)
	S RES("output")=OUT
	S RES("status")="completed"
	Q 1
	;
RERR(RES)
	S $ECODE=""
	S RES("ok")=0
	S RES("error")="run_failed"
	S RES("zstatus")=$ZSTATUS
	Q
	;
SEARCH(CONF,Q,LIMIT,OUT)
	N DIR,PAT,FP,NAME,LINE,IDX,N,QQ,I,ERR
	K OUT
	S QQ=$$LOW($G(Q))
	I QQ="" Q
	S LIMIT=+$G(LIMIT) I LIMIT<1 S LIMIT=20
	S DIR=$$RDIR(.CONF)
	S PAT=DIR_"/*.m"
	S FP=$ZSEARCH(PAT)
	S IDX=0
	F  Q:FP=""  D  Q:IDX'<LIMIT
	. S NAME=$$NOEXT($$BASE(FP))
	. I '$$ISRTN(NAME) S FP=$ZSEARCH("") Q
	. K LINE,ERR S N=0
	. I '$$READARR(FP,.LINE,.ERR) S FP=$ZSEARCH("") Q
	. S I=0
	. F  S I=$O(LINE(I)) Q:'I  D  Q:IDX'<LIMIT
	. . I $$LOW($G(LINE(I)))[QQ D
	. . . S IDX=IDX+1
	. . . S OUT(IDX,"routine")=NAME
	. . . S OUT(IDX,"line")=I
	. . . S OUT(IDX,"text")=$E($G(LINE(I)),1,220)
	. S FP=$ZSEARCH("")
	Q
	;
SNIPS(TCTX)
	S TCTX("snippets",1,"title")="SET"
	S TCTX("snippets",1,"lead")="Assign values and defaults"
	S TCTX("snippets",1,"code")="S X=$G(X,0)"
	S TCTX("snippets",2,"title")="DO"
	S TCTX("snippets",2,"lead")="Invoke a label or routine"
	S TCTX("snippets",2,"code")="D TAG^ROUTINE"
	S TCTX("snippets",3,"title")="QUIT"
	S TCTX("snippets",3,"lead")="Return from entry points"
	S TCTX("snippets",3,"code")="Q"
	S TCTX("snippets",4,"title")="$GET"
	S TCTX("snippets",4,"lead")="Read safely with a default"
	S TCTX("snippets",4,"code")="$G(^GLOBAL(KEY),"""")"
	S TCTX("snippets",5,"title")="FOR"
	S TCTX("snippets",5,"lead")="Simple bounded loop"
	S TCTX("snippets",5,"code")="F I=1:1:10 W !,I"
	Q
	;
RDIR(CONF)
	Q $G(CONF("mioide","routineDir"),"routines")
	;
TDIR(CONF)
	Q $G(CONF("mioide","tempDir"),"tmp")
	;
ROUTEPATH(RTN,CONF)
	Q $$RDIR(.CONF)_"/"_$G(RTN)_".m"
	;
RUNPATH(CONF)
	Q $$TDIR(.CONF)_"/mioide_run.out"
	;
PKG(NAME)
	Q $E($G(NAME),1,3)
	;
COUNT(ARR)
	N I,N S I=0,N=0 F  S I=$O(ARR(I)) Q:'I  S N=N+1
	Q N
	;
LOW(X)
	Q $ZCONVERT($G(X),"L")
	;
NOEXT(X)
	N P S P=$L($G(X),".") I P>1 Q $P(X,".",1,P-1)
	Q $G(X)
	;
BASE(PATH)
	N I,P,CUR S CUR=$G(PATH)
	F I=$L(CUR):-1:1 I $E(CUR,I)="/" Q
	I I>0 Q $E(CUR,I+1,$L(CUR))
	Q CUR
	;
URLENC(X)
	Q $TR($G(X)," ","+")
	;
ISRTN(X)
	Q $$ISID($G(X))
	;
ISID(S)
	N I,C,OK
	S S=$G(S)
	I S="" Q 0
	S C=$E(S,1),OK=$S((C?1A)!(C="%"):1,1:0)
	I 'OK Q 0
	F I=2:1:$L(S) Q:'OK  D
	. S C=$E(S,I)
	. I '(C?1AN) S OK=0
	Q OK
	;
RUNOK(RTN,CONF)
	N I,P,OK
	S OK=0
	S I=0
	F  S I=$O(CONF("mioide","run","allowPrefix",I)) Q:'I  D  Q:OK
	. S P=$G(CONF("mioide","run","allowPrefix",I))
	. I P'="",$E($G(RTN),1,$L(P))=P S OK=1
	Q OK
	;
READARR(PATH,OUT,ERR)
	N OIO,LINE,I
	K OUT,ERR
	S OIO=$IO
	OPEN PATH:(READONLY:STREAM):1 ELSE  S ERR("error")="open_failed" Q 0
	USE PATH
	S I=0
	F  U PATH R LINE Q:$ZEOF  S I=I+1,OUT(I)=LINE
	CLOSE PATH
	USE OIO
	Q 1
	;
READTXT(PATH,MAX,OUT,ERR)
	N ARR,I,LEN
	K ERR
	S OUT=""
	I '$$READARR(PATH,.ARR,.ERR) Q
	S I=0,LEN=0
	F  S I=$O(ARR(I)) Q:'I  D  Q:LEN'<MAX
	. I I>1 S OUT=OUT_$C(10),LEN=LEN+1
	. S OUT=OUT_$E($G(ARR(I)),1,MAX-LEN),LEN=$L(OUT)
	Q
	;
FILEX(PATH)
	N X S X=$ZSEARCH($G(PATH))
	Q $S(X="":0,1:1)
	;
ENSDIR(DIR)
	Q
	;
	;
EXECBUF(CODE,CONF,OUT,ERR)
	N PATH,OIO,MAX
	K ERR
	S OUT=""
	D ENSDIR($$TDIR(.CONF))
	S PATH=$$TDIR(.CONF)_"/mioide_term.out"
	S OIO=$IO
	OPEN PATH:(NEWVERSION:STREAM):1 ELSE  S ERR("error")="open_failed" Q 0
	USE PATH
	S $ETRAP="D EXECERR^MIOIDED(.ERR) USE OIO CLOSE PATH Q"
	XECUTE CODE
	CLOSE PATH
	USE OIO
	S MAX=+$G(CONF("mioide","terminal","maxOutputBytes"),65536)
	D READTXT(PATH,MAX,.OUT,.ERR)
	Q $S($D(ERR("error")):0,1:1)
	;
EXECERR(ERR)
	S $ECODE=""
	S ERR("error")="xecute_failed"
	S ERR("zstatus")=$ZSTATUS
	Q
	;