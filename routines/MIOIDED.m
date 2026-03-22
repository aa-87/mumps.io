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
	S TCTX("eyebrow")="MUMPS.IO / Monaco / WebSocket-ready"
	S TCTX("heading")="MIOIDE Debug Workbench"
	S TCTX("lead")="SSR-first Monaco workbench for M routines. Explorer, editor, debugger rails, problems dock, and live app-like motion without a heavy SPA framework."
	S TCTX("statusText")="Idle"
	S TCTX("statusTone")="badge-emerald"
	S TCTX("apiBase")="/mioide/api"
	S TCTX("debugApiBase")=$G(CONF("mioide","debug","apiBase"),"/mioide/api/debug")
	S TCTX("debugWsBase")=$G(CONF("mioide","debug","wsPath"),"/mioide/ws/debug")
	S TCTX("saveMethod")="PUT"
	S TCTX("editorTheme")=$S(TCTX("themeMode")="light":"mumps-light",1:"mumps-dark")
	S TCTX("saveEnabled")=+$G(CONF("mioide","save","enabled"))
	S TCTX("compileEnabled")=+$G(CONF("mioide","compile","enabled"))
	S TCTX("runEnabled")=+$G(CONF("mioide","run","enabled"))
	S TCTX("debugEnabled")=+$G(CONF("mioide","debug","enabled"))
	S TCTX("commandPlaceholder")="Type a command or jump to a routine"
	S TCTX("workspaceTitle")="Full-stack M routine editor"
	S TCTX("workspaceLead")="Traditional IDE hierarchy with explorer, workbench tabs, debugger sidebars, problems, and status telemetry."
	S TCTX("branchName")="main"
	S TCTX("connectionText")="MIOWS-ready"
	S TCTX("connectionTone")="badge-sky"
	S TCTX("shellMode")="SSR first - dense layout"
	S TCTX("searchPlaceholder")="Find routine or symbol"
	D LISTRTN(.CONF,$G(REQ("query","q")),.RTNS)
	M TCTX("routines")=RTNS
	S COUNT=$$COUNT(.RTNS)
	S TCTX("routineCount")=COUNT
	S ACTIVE=$G(REQ("query","name"))
	I ACTIVE="" S ACTIVE=$G(RTNS(1,"name"))
	I ACTIVE="" S ACTIVE="MIOIDE"
	S TCTX("activeName")=ACTIVE
	S TCTX("currentPath")="routines/"_ACTIVE_".m"
	S TCTX("activeSymbol")="DO ^"_ACTIVE
	S TCTX("lineInfo")="Ln 1, Col 1"
	S TCTX("indentInfo")="Spaces: 2"
	S TCTX("syntaxInfo")="MUMPS"
	S TCTX("encodingInfo")="UTF-8"
	S TCTX("eolInfo")="LF"
	S TCTX("workspaceState")="Routine saved & compiled successfully"
	S TCTX("workspaceStateTone")="badge-emerald"
	S TCTX("debugHint")="Attach debugger"
	S TCTX("terminalHint")="Open terminal"
	S TCTX("collabHint")="Presence later"
	S TCTX("titlebarContext")="Workspace - "_TCTX("branchName")
	S I=0
	F  S I=$O(TCTX("routines",I)) Q:'I  D
	. S NM=$G(TCTX("routines",I,"name"))
	. S TCTX("routines",I,"summary")=$S(NM["TEST":"Test harness",NM["T":"Test surface",NM["AUTH":"Auth module",NM["WS":"WebSocket surface",1:"Routine module")
	. S TCTX("routines",I,"icon")=$S(NM["T":"T",NM["AUTH":"A",NM["WS":"W",1:"M")
	. S TCTX("routines",I,"modified")=$S(I=1:"now",I=2:"2m",I=3:"8m",I=4:"14m",I=5:"22m",1:"31m")
	. I $G(TCTX("routines",I,"pkg"))="" S TCTX("routines",I,"pkg")="core"
	. I NM=ACTIVE S TCTX("routines",I,"isActive")=1
	S MAXI=+$G(CONF("mioide","editor","maxInitialBytes"),262144)
	S SRC=""
	I ACTIVE'="" D GETSRCTXT(ACTIVE,.CONF,MAXI,.SRC,.ERR)
	I SRC="" S SRC=ACTIVE_" ; MIOIDE scratch routine"_$C(10)_" QUIT"
	S TCTX("initialSource")=SRC
	S TCTX("activity",1,"id")="explorer",TCTX("activity",1,"abbr")="EX",TCTX("activity",1,"label")="Explorer",TCTX("activity",1,"isActive")=1
	S TCTX("activity",2,"id")="search",TCTX("activity",2,"abbr")="SR",TCTX("activity",2,"label")="Search"
	S TCTX("activity",3,"id")="debug",TCTX("activity",3,"abbr")="RD",TCTX("activity",3,"label")="Run and Debug"
	S TCTX("activity",4,"id")="globals",TCTX("activity",4,"abbr")="GL",TCTX("activity",4,"label")="Global explorer"
	S TCTX("activity",5,"id")="scm",TCTX("activity",5,"abbr")="SC",TCTX("activity",5,"label")="Source control"
	S TCTX("tabs",1,"title")=ACTIVE_".m",TCTX("tabs",1,"path")=TCTX("currentPath"),TCTX("tabs",1,"isActive")=1,TCTX("tabs",1,"isDirty")=1
	S TCTX("tabs",2,"title")="MIOIDET002.m",TCTX("tabs",2,"path")="tests/MIOIDET002.m",TCTX("tabs",2,"badge")="test"
	S TCTX("tabs",3,"title")="MIOIDE_ROI1.md",TCTX("tabs",3,"path")="docs/MIOIDE_ROI1.md",TCTX("tabs",3,"badge")="plan"
	S TCTX("openEditor",1,"title")=ACTIVE_".m",TCTX("openEditor",1,"detail")="Active editor",TCTX("openEditor",1,"isActive")=1
	S TCTX("openEditor",2,"title")="MIOIDET002.m",TCTX("openEditor",2,"detail")="Render smoke tests"
	S TCTX("openEditor",3,"title")="MIOIDER.m",TCTX("openEditor",3,"detail")="Route handlers"
	S TCTX("searchMatch",1,"routine")=ACTIVE,TCTX("searchMatch",1,"line")=1,TCTX("searchMatch",1,"text")=ACTIVE_" ; entry routine"
	S TCTX("searchMatch",2,"routine")="MIOIDER",TCTX("searchMatch",2,"line")=9,TCTX("searchMatch",2,"text")="D ADDM^MIOROUTE(""GET"",""/mioide"",""HOME^MIOIDER"",.META)"
	S TCTX("searchMatch",3,"routine")="MIOIDED",TCTX("searchMatch",3,"line")=3,TCTX("searchMatch",3,"text")="BUILDHOME(CONF,REQ,CTX,TCTX)"
	S TCTX("searchMatch",4,"routine")="MIOIDE",TCTX("searchMatch",4,"line")=20,TCTX("searchMatch",4,"text")="D REG^MIOIDER(.CONF)"
	S TCTX("watch",1,"name")="REQ(""params"",""name"")",TCTX("watch",1,"value")=ACTIVE
	S TCTX("watch",2,"name")="CTX(""request_id"")",TCTX("watch",2,"value")="$G(CTX(""request_id""))"
	S TCTX("watch",3,"name")="$ZSTATUS",TCTX("watch",3,"value")="ready"
	S TCTX("watch",4,"name")="saveEnabled",TCTX("watch",4,"value")=$S(TCTX("saveEnabled"):1,1:0)
	S TCTX("callstack",1,"frame")="HOME^MIOIDER",TCTX("callstack",1,"detail")="SSR route entry",TCTX("callstack",1,"isActive")=1
	S TCTX("callstack",2,"frame")="BUILDHOME^MIOIDED",TCTX("callstack",2,"detail")="Context builder"
	S TCTX("callstack",3,"frame")="RENDERPAGE^MIOTPL",TCTX("callstack",3,"detail")="Layout + page render"
	S TCTX("callstack",4,"frame")="RESPX^MIOHTTP",TCTX("callstack",4,"detail")="HTTP response writer"
	S TCTX("breakpoint",1,"loc")=ACTIVE_"+1",TCTX("breakpoint",1,"detail")="routine entry"
	S TCTX("breakpoint",2,"loc")="MIOIDER+42",TCTX("breakpoint",2,"detail")="compile response"
	S TCTX("breakpoint",3,"loc")="MIOIDED+76",TCTX("breakpoint",3,"detail")="body stream save"
	S TCTX("problem",1,"sevClass")="pill-error",TCTX("problem",1,"sevLabel")="Error",TCTX("problem",1,"file")=ACTIVE_".m",TCTX("problem",1,"line")=42,TCTX("problem",1,"message")="Expected command separator or postconditional near compile surface"
	S TCTX("problem",2,"sevClass")="pill-warn",TCTX("problem",2,"sevLabel")="Warning",TCTX("problem",2,"file")="MIOIDER.m",TCTX("problem",2,"line")=27,TCTX("problem",2,"message")="Debugger boot now uses WebSocket sessions for lower-latency step control"
	S TCTX("problem",3,"sevClass")="pill-info",TCTX("problem",3,"sevLabel")="Info",TCTX("problem",3,"file")="MIOIDEDBG.m",TCTX("problem",3,"line")=1,TCTX("problem",3,"message")="Debugger session bootstrap available at "_TCTX("debugApiBase")_"/sessions"
	S TCTX("output",1,"channel")="compile",TCTX("output",1,"text")="[compile] "_ACTIVE_" ready for compile"
	S TCTX("output",2,"channel")="save",TCTX("output",2,"text")="[save] Stream body writer configured for MAXSTRING-safe routine writes"
	S TCTX("output",3,"channel")="run",TCTX("output",3,"text")="[run] Sandbox runner available when prefix policy allows execution"
	S TCTX("output",4,"channel")="debug",TCTX("output",4,"text")="[debug] WebSocket session transport ready at "_TCTX("debugWsBase")
	S TCTX("globalPreview",1,"node")="^MIO(""ROUTE"",""RAW"",""GET"",""/mioide"")",TCTX("globalPreview",1,"value")="HOME^MIOIDER"
	S TCTX("globalPreview",2,"node")="^MIO(""ROUTE"",""META"",""GET"",""/mioide"",""authRequired"")",TCTX("globalPreview",2,"value")=+$G(CONF("mioide","authRequired"),1)
	S TCTX("globalPreview",3,"node")="^MIO(""MIOIDE"",""DBG"")",TCTX("globalPreview",3,"value")="cold"
	S TCTX("scmState",1,"label")="Changes",TCTX("scmState",1,"value")="3 files"
	S TCTX("scmState",2,"label")="Ahead",TCTX("scmState",2,"value")="2 commits"
	S TCTX("scmState",3,"label")="Checks",TCTX("scmState",3,"value")="passing"
	S TCTX("palette",1,"id")="save",TCTX("palette",1,"label")="File: Save current routine",TCTX("palette",1,"hint")="Ctrl+S"
	S TCTX("palette",2,"id")="compile",TCTX("palette",2,"label")="Build: Compile current routine",TCTX("palette",2,"hint")="Ctrl+Shift+B"
	S TCTX("palette",3,"id")="run",TCTX("palette",3,"label")="Run: Execute current routine",TCTX("palette",3,"hint")="F5"
	S TCTX("palette",4,"id")="debug.start",TCTX("palette",4,"label")="Debug: Start WebSocket session",TCTX("palette",4,"hint")="F9"
	D SNIPS(.TCTX)
	D ROIS(.TCTX)
	Q
	;
LISTRTN(CONF,Q,OUT)
	N %ZR,QQ,NAME,IDX
	K OUT
	S QQ=$$LOW($G(Q))
	K %ZR D SILENT^%RSEL("MIOIDE*","CALL")
	S NAME="",IDX=0
	F  S NAME=$O(%ZR(NAME)) Q:NAME=""  D
	. I QQ'="",$$LOW(NAME)'[QQ Q
	. S IDX=IDX+1
	. S OUT(IDX,"name")=NAME
	. S OUT(IDX,"path")=$G(%ZR(NAME))
	. S OUT(IDX,"pkg")=$$PKG(NAME)
	Q
	;
GETSRCTXT(RTN,CONF,MAX,OUT,ERR)
	N PATH
	K ERR
	S OUT=""
	I '$$ISRTN($G(RTN)) S ERR("error")="invalid_routine" Q
	S PATH=$$ROUTEPATH(RTN,.CONF)
	I '$$FILEX(PATH) S ERR("error")="not_found" Q
	D READTXT(PATH,+$G(MAX,262144),.OUT,.ERR)
	Q
	;
WRITEREQ(RTN,REQ,CONF,ERR,SIZE)
	N DEV,PATH,LINE,RAW,ROOT,I,CHUNK,OK,TEXT
	K ERR
	S SIZE=0
	I '$$ISRTN($G(RTN)) S ERR("error")="invalid_routine" Q 0
	I '$D(REQ("body","file")),$G(REQ("body"))="" S ERR("error")="empty_body" Q 0
	I $D(REQ("body","file")) D  Q $$SAVETEXT(RTN,TEXT,.CONF,.ERR,.SIZE)
	. K ERR S TEXT=""
	. N X D READTXT($G(REQ("body","file")),1048576,.TEXT,.ERR)
	S TEXT=$G(REQ("body"))
	Q $$SAVETEXT(RTN,TEXT,.CONF,.ERR,.SIZE)
	;
SAVETEXT(RTN,TEXT,CONF,ERR,SIZE)
	N PATH,OIO
	K ERR
	S SIZE=0
	I '$$ISRTN($G(RTN)) S ERR("error")="invalid_routine" Q 0
	D ENSDIR($$RDIR(.CONF))
	S PATH=$$ROUTEPATH(RTN,.CONF)
	S OIO=$IO
	OPEN PATH:(NEWVERSION:STREAM):1 ELSE  S ERR("error")="open_failed" Q 0
	USE PATH W $G(TEXT)
	CLOSE PATH
	USE OIO
	S SIZE=$L($G(TEXT))
	Q 1
	;
STREAMSRC(DEV,CONF,RTN,CTX,ERR)
	N TXT,HEAD
	K ERR
	D GETSRCTXT(RTN,.CONF,1048576,.TXT,.ERR)
	I $D(ERR) Q 0
	S HEAD("Content-Type")="text/plain; charset=utf-8"
	D RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,TXT,$G(CTX("request_id")),.CTX)
	Q 1
	;
COMPILE(RTN,CONF,RES)
	N ZCS,CMD,RET
	K RES
	S RET=0
	S RES("ok")=0,RES("compiled")=0,RES("name")=$G(RTN)
	I '$G(CONF("mioide","compile","enabled")) S RES("error")="compile_disabled"
	E  I '$$ISRTN($G(RTN)) S RES("error")="invalid_routine"
	E  I '$$FILEX($$ROUTEPATH(RTN,.CONF)) S RES("error")="not_found"
	E  D
	. S $ETRAP="D CERR^MIOIDED(.RES) S RET=0 S $ECODE="""""
	. S CMD="ZLINK """_$G(RTN)_".m"""
	. XECUTE CMD
	. S ZCS=+$ZCSTATUS
	. S RES("zcstatus")=ZCS
	. I ZCS>1 S RES("ok")=0,RES("compiled")=0,RES("error")="compile_failed",RES("status")="compile_failed" Q
	. S RES("ok")=1,RES("compiled")=1,RES("status")="compiled",RES("message")="Routine compiled successfully",RET=1
	I $Q Q RET
	Q
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
	N OIO,PATH,OUT,ERR,CMD,MAX,RET
	K RES
	S RET=0
	S RES("routine")="MIOIDED"
	S RES("name")=$G(RTN)
	S RES("entry")=$G(ENTRY)
	I '$G(CONF("mioide","run","enabled")) S RES("ok")=0,RES("error")="run_disabled"
	E  I '$$ISRTN($G(RTN)) S RES("ok")=0,RES("error")="invalid_routine"
	E  I ENTRY'="",'$$ISID(ENTRY) S RES("ok")=0,RES("error")="invalid_entry"
	E  I '$$RUNOK(RTN,.CONF) S RES("ok")=0,RES("error")="run_not_allowed"
	E  D
	. D ENSDIR($$TDIR(.CONF))
	. S PATH=$$RUNPATH(.CONF)
	. S OIO=$IO
	. OPEN PATH:(NEWVERSION:STREAM):1 ELSE  S RES("ok")=0,RES("error")="open_failed" Q
	. USE PATH
	. S RES("ok")=1
	. S $ETRAP="D RERR^MIOIDED(.RES) USE OIO CLOSE PATH S RET=0 S $ECODE="""""
	. S CMD=$S(ENTRY'="":"DO "_ENTRY_"^"_RTN,1:"DO ^"_RTN)
	. XECUTE CMD
	. CLOSE PATH
	. USE OIO
	. S MAX=+$G(CONF("mioide","run","maxOutputBytes"),131072)
	. S OUT=""
	. K ERR
	. D READTXT(PATH,MAX,.OUT,.ERR)
	. S RES("output")=OUT
	. S RES("status")="completed",RET=1
	I $Q Q RET
	Q
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
	S PAT=DIR_"/*.m*"
	S FP=$ZSEARCH(PAT)
	S IDX=0
	F  Q:FP=""  D  Q:IDX'<LIMIT
	. S NAME=$$NOEXT($$BASE(FP))
	. I NAME[";" S NAME=$P(NAME,";",1)
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
	K TCTX("snippets")
	D ADDSNIP(.TCTX,1,"SET/get","Set default with $GET","S value=$G(^GLOBAL(node),"""")")
	D ADDSNIP(.TCTX,2,"FOR/$ORDER","Loop through nodes","S key="""" F  S key=$O(^GLOBAL(key)) Q:key=""""  D")
	D ADDSNIP(.TCTX,3,"Error trap","Simple local trap","N $ET S $ET=""Q""")
	D ADDSNIP(.TCTX,4,"API handler","Standard route entry","ROUTE(DEV,CONF,REQ,CTX) N OUT,ERR Q")
	D ADDSNIP(.TCTX,5,"Quiet test","Quiet-on-success assertion","D EQ^MIOTASSERT($G(X),1,""[T001][ok]"")")
	Q
	;
ROIS(TCTX)
	K TCTX("nextRoi")
	S TCTX("nextRoi",1,"title")="ROI 1: foundation shell"
	S TCTX("nextRoi",1,"body")="Explorer, Monaco editor, save, compile, run, search, snippets, and dense SSR layout."
	S TCTX("nextRoi",2,"title")="ROI 2: WebSocket event bus"
	S TCTX("nextRoi",2,"body")="Save, compile, run, and presence events over MIOWS with bounded queues and reconnect-safe cursors."
	S TCTX("nextRoi",3,"title")="ROI 3: WebSocket debugger"
	S TCTX("nextRoi",3,"body")="Boot sessions over HTTP and drive step, breakpoints, watches, eval, and snapshots over a persistent MIOWS socket."
	S TCTX("nextRoi",4,"title")="ROI 4: integrated terminal"
	S TCTX("nextRoi",4,"body")="Real YottaDB prompt transport with PTY/session controls, auth gates, and audit logging."
	S TCTX("nextRoi",5,"title")="ROI 5: globals and collaboration"
	S TCTX("nextRoi",5,"body")="Global explorer, diffing, shared cursors, locking, and collaborative routine sessions."
	Q
	;
ADDSNIP(TCTX,IDX,TITLE,LEAD,CODE)
	S TCTX("snippets",IDX,"title")=$G(TITLE)
	S TCTX("snippets",IDX,"lead")=$G(LEAD)
	S TCTX("snippets",IDX,"code")=$G(CODE)
	Q
	;
COUNT(ARR,KEY,VAL)
	N I,C
	S I="",C=0
	I $G(KEY)'="" D  Q C
	. F  S I=$O(ARR(I)) Q:I=""  I $G(ARR(I,KEY))=$G(VAL) S C=C+1
	F  S I=$O(ARR(I)) Q:I=""  S C=C+1
	Q C
	;
PKG(RTN)
	N I,C,OUT
	S OUT=""
	F I=1:1:$L($G(RTN)) S C=$E(RTN,I) Q:C'?1A  S OUT=OUT_C Q:$L(OUT)'<4
	I OUT="" S OUT="misc"
	Q OUT
	;
ROUTEPATH(RTN,CONF)
	Q $$RDIR(.CONF)_"/"_$G(RTN)_".m"
	;
RDIR(CONF)
	Q $$TRAIL($G(CONF("mioide","routineDir"),"routines"))
	;
TDIR(CONF)
	Q $$TRAIL($G(CONF("mioide","tempDir"),"tmp/mioide"))
	;
RUNPATH(CONF)
	Q $$TDIR(.CONF)_"/run-"_$J_"-"_$TR($H,",","-")_".out"
	;
TRAIL(PATH)
	N P
	S P=$G(PATH)
	I $E(P,$L(P))="/" Q $E(P,1,$L(P)-1)
	Q P
	;
ENSDIRERR ; placeholder
	Q
	;
ENSDIR(PATH)
	Q
	;
READARR(PATH,OUT,ERR)
	N OIO,I,LINE
	K OUT
	K ERR
	S OIO=$IO
	OPEN PATH:(READONLY):1 ELSE  S ERR("error")="open_failed" Q 0
	USE PATH
	S I=0
	F  R LINE Q:$ZEOF  S I=I+1,OUT(I)=LINE
	CLOSE PATH
	USE OIO
	Q 1
	;
READTXT(PATH,MAX,OUT,ERR)
	N LINES,I,LEN,LINE,RET
	K ERR
	S OUT="",RET=0
	I $$READARR(PATH,.LINES,.ERR) D
	. S LEN=0,I=0
	. F  S I=$O(LINES(I)) Q:'I  D  Q:LEN'<MAX
	. . S LINE=$G(LINES(I))
	. . I I>1 S OUT=OUT_$C(10),LEN=LEN+1 I LEN'<MAX Q
	. . I LEN+$L(LINE)>MAX S OUT=OUT_$E(LINE,1,MAX-LEN),LEN=MAX Q
	. . S OUT=OUT_LINE,LEN=LEN+$L(LINE)
	. S RET=1
	I $Q Q RET
	Q
	;
FILEX(PATH)
	N X
	S X=$ZSEARCH($G(PATH))
	Q $S(X'="":1,1:0)
	;
BASE(PATH)
	N I,C,OUT
	S OUT=$G(PATH)
	F I=$L(OUT):-1:1 S C=$E(OUT,I) I C="/"!(C="\") Q
	Q $E(OUT,I+1,$L(OUT))
	;
NOEXT(NAME)
	N I
	S I=$L($G(NAME),".")
	I I'>1 Q $G(NAME)
	Q $P(NAME,".",1,I-1)
	;
LOW(X)
	Q $ZCONVERT($G(X),"L")
	;
URLENC(S)
	Q $$URLE^MIOUTIL($G(S))
	;
ISID(X)
	N I,C,Q S Q=1
	S X=$G(X)
	I X="" Q 0
	I '$E(X,1)?1A Q 0
	F I=1:1:$L(X) S C=$E(X,I) I C'?1A,C'?1N,C'="%" S Q=0 Q
	Q Q
	;
ISRTN(X)
	N I,C,Q S Q=1
	S X=$G(X)
	I X="" Q 0
	I $L(X)>31 Q 0
	I '$E(X,1)?1A,$E(X,1)'="%" Q 0
	F I=1:1:$L(X) S C=$E(X,I) I C'?1A,C'?1N,C'="%" S Q=0 Q
	Q Q
	;
RUNOK(RTN,CONF)
	N I,P,PRE
	S P="",I=0
	F  S I=$O(CONF("mioide","run","allowPrefix",I)) Q:'I  D  Q:P'=""
	. S PRE=$G(CONF("mioide","run","allowPrefix",I))
	. I PRE'="",$E($G(RTN),1,$L(PRE))=PRE S P=PRE
	Q $S(P'="":1,1:0)
	;
	;
