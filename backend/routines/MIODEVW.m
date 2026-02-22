MIODEVW ; MIO Development Watcher (dashboard + IPC + widgets + log panel)
	;
	; Compatible: YottaDB / GT.M (Linux terminals with ANSI supported)
	;
	; What it does
	;   - Scans a directory pattern using $ZSEARCH
	;   - Detects new/changed files (by reading bytes+lines)
	;   - Calls an optional callback (CONF("onfile")="TAG^ROUTINE")
	;   - Dashboard UI (minimalist, extendible) via widget registry
	;   - IPC updates from other processes via ^MIO("DEVW",id,"Q",seq,...)
	;   - Scrollable/filterable log panel + helper APIs
	;   - dryUI + uidiff for tests / low-noise repaint
	;
	; PUBLIC
	;   DEVWATCH      - convenience launcher using ^MIO("CONF") (kept for your app)
	;   START(.CONF)  - loop watcher
	;   ONCE(.CONF)   - one scan pass
	;   HELP          - usage
	;
	; IPC (other jobs)
	;   D PUBSTATUS^MIODEVW(id,msg)
	;   D PUBERR^MIODEVW(id,msg)
	;   D PUBFILE^MIODEVW(id,fp,st,detail)
	;   D PUBMET^MIODEVW(id,name,delta)
	;   D PUBSET^MIODEVW(id,name,val)
	;   D PUBLOG^MIODEVW(id,level,msg)
	;   D SETCTL^MIODEVW(id,name,val)  ; pause/stop/logFilter/logScroll
	;
	; Log scroll helpers (next ROI)
	;   S s=$$LOGEND^MIODEVW(id)         ; tail
	;   S s=$$LOGHOME^MIODEVW(id)        ; oldest window
	;   S s=$$LOGUP^MIODEVW(id,n)
	;   S s=$$LOGDOWN^MIODEVW(id,n)
	;   S s=$$LOGPAGEUP^MIODEVW(id)
	;   S s=$$LOGPAGEDN^MIODEVW(id)
	;
	; Callback signature
	;   TAG(FILE,.CONF,.ERR)
	;
	; ---------------------------------------------------------------------------
	;
DEVWATCH
	NEW CONF,C
	KILL C
	MERGE CONF=^MIO("CONF")
	SET C("id")="mio"
	SET C("dir")=$GET(CONF("server","templateDir"))
	IF C("dir")="" SET C("dir")="templates"
	SET C("pattern")="*.*"
	SET C("interval")=1
	SET C("logFile")=$$JOIN(C("dir"),"mio-devwatch.log")
	SET C("stopFile")=$$JOIN(C("dir"),".miodevw.stop")
	SET C("tty")=1
	SET C("color")=1
	;
	; Dashboard
	SET C("ui")=1
	SET C("alt")=1
	SET C("rows")=24
	SET C("cols")=100
	SET C("lastN")=10
	SET C("errN")=6
	;
	; Log panel
	SET C("logPanel")=1
	SET C("paneAHeight")=6   ; header+metrics area baseline
	SET C("logMinH")=6
	SET C("logMax")=100
	;
	; UI perf
	SET C("dryUI")=0
	SET C("uidiff")=1
	;
	; Optional capture callback output
	SET C("captureDir")=""
	;
	; Callback to process files
	SET C("onfile")="PROCESS^MIODEVW"
	DO START^MIODEVW(.C)
	QUIT
	;
PROCESS(FP,CONF,ERR)
	; sample hook
	SET ERR=""
	MERGE ^AHM($INCREMENT(^AHM))=FP
	DO PUBFILE($GET(CONF("id"),"mio"),FP,"OK","queued")
	QUIT
	;
; -------------------- Runner --------------------
	;
START(CONF)
	NEW $ETRAP,$ES
	SET $ETRAP="DO ET^MIODEVW($ZSTATUS,.CONF) QUIT"
	DO DEFAULT(.CONF)
	SET CONF("ttyIO")=$IO
	DO OPENLOG(.CONF)
	DO INITSTATE(.CONF)
	IF $GET(CONF("ui")) DO UISTART(.CONF) ELSE  DO BANNER(.CONF)
	NEW spinI SET spinI=0
	NEW lastSeq SET lastSeq=+$GET(^MIO("DEVW",CONF("id"),"STATE","qdone"))
	NEW lastRateH SET lastRateH=$H
	NEW lastRateP SET lastRateP=+$GET(^MIO("DEVW",CONF("id"),"STATE","metrics","processed"))
	FOR  DO  QUIT:$$SHOULDSTOP(.CONF)
	. DO UIPOLL(.CONF,.lastSeq)
	. DO UIRENDER(.CONF,.spinI,.lastRateH,.lastRateP)
	. IF $$GETCTL(CONF("id"),"pause") DO  QUIT
	. . SET spinI=spinI+1
	. . HANG +$GET(CONF("interval"),1)
	. NEW files DO SCAN(.CONF,.files)
	. DO METADD(CONF("id"),"scans",1)
	. NEW did SET did=0
	. NEW f SET f=""
	. FOR  SET f=$ORDER(files(f)) QUIT:f=""  DO
	. . SET did=did+$$HANDLE(f,.CONF)
	. IF 'did SET spinI=spinI+1
	. HANG +$GET(CONF("interval"),1)
	DO LOGX("INFO","Watcher stopped.",.CONF)
	IF $GET(CONF("ui")) DO UIEND(.CONF)
	DO CLOSELOG(.CONF)
	QUIT
	;
ONCE(CONF)
	NEW $ETRAP,$ES
	SET $ETRAP="DO ET^MIODEVW($ZSTATUS,.CONF) QUIT"
	DO DEFAULT(.CONF)
	SET CONF("ttyIO")=$IO
	DO OPENLOG(.CONF)
	DO INITSTATE(.CONF)
	IF $GET(CONF("ui")) DO UISTART(.CONF) ELSE  DO BANNER(.CONF)
	NEW lastSeq SET lastSeq=+$GET(^MIO("DEVW",CONF("id"),"STATE","qdone"))
	NEW spinI SET spinI=0
	NEW lastRateH SET lastRateH=$H
	NEW lastRateP SET lastRateP=+$GET(^MIO("DEVW",CONF("id"),"STATE","metrics","processed"))
	NEW files DO SCAN(.CONF,.files)
	DO METADD(CONF("id"),"scans",1)
	NEW f SET f=""
	FOR  SET f=$ORDER(files(f)) QUIT:f=""  DO
	. DO HANDLE(f,.CONF)
	DO UIPOLL(.CONF,.lastSeq)
	DO UIRENDER(.CONF,.spinI,.lastRateH,.lastRateP)
	DO LOGX("OK","Done (ONCE).",.CONF)
	IF $GET(CONF("ui")) DO UIEND(.CONF)
	DO CLOSELOG(.CONF)
	QUIT
	;
HELP
	WRITE !
	WRITE "MIODEVW - Development Watcher (dashboard + IPC)",!
	WRITE "  D DEVWATCH^MIODEVW",!
	WRITE "  D START^MIODEVW(.CONF)",!
	WRITE "  D ONCE^MIODEVW(.CONF)",!
	WRITE !
	WRITE "IPC:",!
	WRITE "  D PUBLOG^MIODEVW(id,level,msg)",!
	WRITE "  D SETCTL^MIODEVW(id,""pause"",1)  /  D SETCTL^MIODEVW(id,""stop"",1)",!
	WRITE "  D SETCTL^MIODEVW(id,""logFilter"",""WARN,ERROR"")",!
	WRITE "  D LOGPAGEUP^MIODEVW(id) / D LOGPAGEDN^MIODEVW(id)",!
	WRITE !
	QUIT
	;
; -------------------- Defaults / state --------------------
	;
DEFAULT(CONF)
	IF $GET(CONF("id"))=""        SET CONF("id")="default"
	IF $GET(CONF("dir"))=""       SET CONF("dir")="."
	IF $GET(CONF("pattern"))=""   SET CONF("pattern")="*.req"
	IF $GET(CONF("interval"))=""  SET CONF("interval")=1
	IF $GET(CONF("tty"))=""       SET CONF("tty")=1
	IF $GET(CONF("color"))=""     SET CONF("color")=1
	IF $GET(CONF("logFile"))=""   SET CONF("logFile")=$$JOIN(CONF("dir"),"miodevw.log")
	IF $GET(CONF("stopFile"))=""  SET CONF("stopFile")=$$JOIN(CONF("dir"),".miodevw.stop")
	IF $GET(CONF("stopFile"))'="",CONF("stopFile")'["/" SET CONF("stopFile")=$$JOIN(CONF("dir"),CONF("stopFile"))
	;
	IF $GET(CONF("ui"))=""        SET CONF("ui")=1
	IF $GET(CONF("alt"))=""       SET CONF("alt")=1
	IF $GET(CONF("rows"))=""      SET CONF("rows")=24
	IF $GET(CONF("cols"))=""      SET CONF("cols")=100
	IF $GET(CONF("lastN"))=""     SET CONF("lastN")=10
	IF $GET(CONF("errN"))=""      SET CONF("errN")=6
	;
	IF $GET(CONF("uidiff"))=""    SET CONF("uidiff")=1
	IF $GET(CONF("dryUI"))=""     SET CONF("dryUI")=0
	;
	IF $GET(CONF("logPanel"))=""  SET CONF("logPanel")=0
	IF $GET(CONF("paneAHeight"))="" SET CONF("paneAHeight")=6
	IF $GET(CONF("logMinH"))=""   SET CONF("logMinH")=6
	IF $GET(CONF("logMax"))=""    SET CONF("logMax")=100
	QUIT
	;
INITSTATE(CONF)
	NEW id SET id=CONF("id")
	SET ^MIO("DEVW",id,"STATE","conf","rows")=CONF("rows")
	SET ^MIO("DEVW",id,"STATE","conf","cols")=CONF("cols")
	SET ^MIO("DEVW",id,"STATE","conf","lastN")=CONF("lastN")
	SET ^MIO("DEVW",id,"STATE","conf","errN")=CONF("errN")
	SET ^MIO("DEVW",id,"STATE","conf","logMax")=CONF("logMax")
	IF $GET(^MIO("DEVW",id,"STATE","startH"))="" SET ^MIO("DEVW",id,"STATE","startH")=$H
	IF $GET(^MIO("DEVW",id,"STATE","status"))="" SET ^MIO("DEVW",id,"STATE","status")="Watching..."
	IF $GET(^MIO("DEVW",id,"CTL","logFilter"))="" SET ^MIO("DEVW",id,"CTL","logFilter")="ALL"
	IF $GET(^MIO("DEVW",id,"CTL","logScroll"))="" SET ^MIO("DEVW",id,"CTL","logScroll")=0
	SET ^MIO("DEVW",id,"STATE","dirty")=1
	QUIT
	;
; -------------------- Widget Registry --------------------
	;
REGW(CONF,NAME,PRI,DRAW,PAINT)
	IF $GET(NAME)="" QUIT
	IF $GET(PRI)="" SET PRI=50
	SET CONF("ui","W",PRI,NAME)=$GET(DRAW)_"|"_$GET(PAINT)
	QUIT
	;
WREGDEFAULT(CONF)
	DO REGW(.CONF,"chrome",10,"WCHROME^MIODEVW","")
	DO REGW(.CONF,"header",20,"","WHEADER^MIODEVW")
	DO REGW(.CONF,"metrics",30,"","WMETRICS^MIODEVW")
	DO REGW(.CONF,"recent",40,"","WRECENT^MIODEVW")
	DO REGW(.CONF,"errors",50,"","WERRORS^MIODEVW")
	IF +$GET(CONF("logPanel")) DO REGW(.CONF,"log",60,"","WLOG^MIODEVW")
	QUIT
	;
UIINIT(CONF)
	IF '$GET(CONF("ui")) QUIT
	IF '$DATA(CONF("ui","W")) DO WREGDEFAULT(.CONF)
	; dryUI control block used by PUT()
	KILL ^TMP($J,"MIODEVW","UI")
	SET ^TMP($J,"MIODEVW","UI","id")=$GET(CONF("id"),"default")
	SET ^TMP($J,"MIODEVW","UI","tty")=+$GET(CONF("tty"))
	SET ^TMP($J,"MIODEVW","UI","dry")=+$GET(CONF("dryUI"))
	SET ^TMP($J,"MIODEVW","UI","uidiff")=+$GET(CONF("uidiff"))
	SET ^TMP($J,"MIODEVW","UI","ttyIO")=$GET(CONF("ttyIO"),$IO)
	QUIT
	;
WDRAW(CONF,LAY,CTX)
	NEW pri,name,val,draw
	SET pri=""
	FOR  SET pri=$ORDER(CONF("ui","W",pri)) QUIT:pri=""  DO
	. SET name=""
	. FOR  SET name=$ORDER(CONF("ui","W",pri,name)) QUIT:name=""  DO
	. . SET val=$GET(CONF("ui","W",pri,name))
	. . SET draw=$PIECE(val,"|",1)
	. . IF draw'="" DO WDO(draw,.CONF,.LAY,.CTX)
	QUIT
	;
WPAINT(CONF,LAY,CTX)
	NEW pri,name,val,paint
	SET pri=""
	FOR  SET pri=$ORDER(CONF("ui","W",pri)) QUIT:pri=""  DO
	. SET name=""
	. FOR  SET name=$ORDER(CONF("ui","W",pri,name)) QUIT:name=""  DO
	. . SET val=$GET(CONF("ui","W",pri,name))
	. . SET paint=$PIECE(val,"|",2)
	. . IF paint'="" DO WDO(paint,.CONF,.LAY,.CTX)
	QUIT
	;
WDO(REF,CONF,LAY,CTX)
	NEW $ETRAP,$ES,tag,rou,cmd,id
	SET id=$GET(CONF("id"),"default")
	SET $ETRAP="SET $ECODE="""" DO ADDERROR^MIODEVW(id,""UI widget error: ""_$ZSTATUS) QUIT"
	SET tag=$PIECE(REF,"^",1),rou=$PIECE(REF,"^",2)
	IF rou="" SET rou=$$RTN()
	SET cmd=tag_"^"_rou_"(.CONF,.LAY,.CTX)"
	DO @cmd
	QUIT
	;
UILAYOUT(CONF,LAY)
	NEW rows,cols,errW,leftW,splitC
	SET rows=+$GET(CONF("rows"),24),cols=+$GET(CONF("cols"),100)
	SET errW=32 IF cols<80 SET errW=26
	SET leftW=cols-errW-3 IF leftW<30 SET leftW=30
	SET splitC=leftW+2
	SET LAY("rows")=rows,LAY("cols")=cols
	SET LAY("leftW")=leftW,LAY("errW")=errW,LAY("splitC")=splitC
	SET LAY("hdr1")=1,LAY("hdr2")=2,LAY("div1")=3,LAY("met")=4,LAY("div2")=5
	SET LAY("colhdr")=6
	;
	; Determine log panel placement (optional)
	IF +$GET(CONF("logPanel")) DO
	. NEW logMin SET logMin=+$GET(CONF("logMinH"),6)
	. NEW help SET help=rows
	. NEW divB SET divB=rows-1
	. NEW logTop SET logTop=divB-logMin
	. IF logTop<(LAY("colhdr")+2) SET logTop=LAY("colhdr")+2
	. SET LAY("logTop")=logTop
	. SET LAY("logBottom")=divB-1
	. SET LAY("logLines")=LAY("logBottom")-LAY("logTop")+1
	. IF LAY("logLines")<1 SET LAY("logLines")=0
	. SET LAY("listTop")=LAY("colhdr")+1
	. SET LAY("listBottom")=logTop-2
	ELSE  DO
	. SET LAY("listTop")=LAY("colhdr")+1
	. SET LAY("listBottom")=rows-2
	. SET LAY("logTop")=0,LAY("logBottom")=0,LAY("logLines")=0
	SET LAY("divB")=rows-1,LAY("help")=rows
	QUIT
	;
; -------------------- Core watcher --------------------
	;
SCAN(CONF,LIST)
	KILL LIST
	NEW pat SET pat=$$PATTERN(.CONF)
	NEW f SET f=$ZSEARCH(pat)
	FOR  QUIT:f=""  DO  SET f=$ZSEARCH("")
	. SET LIST(f)=""
	QUIT
	;
HANDLE(FILE,CONF)
	NEW bytes,lines,err
	DO FILEINFO(FILE,.bytes,.lines,.err)
	IF err'="" DO LOGX("ERROR","Cannot read "_FILE_": "_err,.CONF) QUIT 0
	NEW prev SET prev=$GET(^MIO("DEVW",CONF("id"),"STATE","seen",FILE))
	IF prev'="",+$PIECE(prev,"|",1)=bytes QUIT 0
	DO ADDRECENT(CONF("id"),FILE,"RUN",lines_"L "_bytes_"B")
	DO LOGX("INFO","Processing "_$$BASENAME(FILE)_" ("_lines_" lines, "_bytes_" bytes)",.CONF)
	;
	NEW oldIO SET oldIO=$IO
	NEW capIO,capErr SET capIO="" SET capErr=""
	DO CAPTUREON(FILE,.CONF,.capIO,.capErr)
	IF capErr'="" DO LOGX("WARN","capture failed: "_capErr,.CONF)
	;
	NEW cb SET cb=$GET(CONF("onfile"))
	KILL err
	IF cb'="" DO
	. DO CALLCB(cb,FILE,.CONF,.err)
	. IF err'="" DO
	. . DO LOGX("ERROR","Callback error: "_err,.CONF)
	. . DO ADDERROR(CONF("id"),err)
	. . DO ADDRECENT(CONF("id"),FILE,"ERR",$EXTRACT(err,1,70))
	ELSE  DO LOGX("DEBUG","No CONF(""onfile"") set; watcher only.",.CONF)
	;
	IF capIO'="" DO  USE oldIO
	. CLOSE capIO
	;
	SET ^MIO("DEVW",CONF("id"),"STATE","seen",FILE)=bytes_"|"_$$NOW()
	DO METADD(CONF("id"),"processed",1)
	IF $GET(err)="" DO
	. DO METADD(CONF("id"),"ok",1)
	. DO ADDRECENT(CONF("id"),FILE,"OK","")
	ELSE  DO METADD(CONF("id"),"errors",1)
	DO LOGX("OK","Done: "_$$BASENAME(FILE),.CONF)
	QUIT 1
	;
SHOULDSTOP(CONF)
	IF $$GETCTL(CONF("id"),"stop") QUIT 1
	NEW sf SET sf=$GET(CONF("stopFile"))
	IF sf="" QUIT 0
	QUIT $$EXISTS(sf)
	;
; -------------------- Callback + capture --------------------
	;
CALLCB(CB,FILE,CONF,ERR)
	SET ERR=""
	NEW TAG,ROU,ref
	SET TAG=$PIECE(CB,"^",1),ROU=$PIECE(CB,"^",2)
	IF TAG="" SET ERR="Invalid CONF(""onfile"") (missing tag): "_CB QUIT
	IF ROU="" SET ROU=$$RTN()
	SET ref=TAG_"^"_ROU_"("""_$$ESCQ(FILE)_""",.CONF,.ERR)"
	DO @ref
	QUIT
	;
CAPTUREON(FILE,CONF,CAPIO,ERR)
	SET ERR="",CAPIO=""
	NEW cd SET cd=$GET(CONF("captureDir"))
	IF cd="" QUIT
	NEW out SET out=$$JOIN(cd,$$BASENAME(FILE)_".out.log")
	NEW $ETRAP,$ES,tty
	SET tty=$IO
	SET $ETRAP="SET ERR=$ZSTATUS,$ECODE="""",CAPIO="""" USE tty QUIT"
	OPEN out:(APPEND)
	SET CAPIO=out
	USE CAPIO
	WRITE "----- ",$$TS(),"  FILE=",FILE," -----",!
	USE tty
	QUIT
	;
; -------------------- Logging --------------------
	;
BANNER(CONF)
	DO LINE("HEAD","MIODEVW - Development Watcher started",.CONF)
	DO LINE("INFO","dir="_CONF("dir")_"  pattern="_CONF("pattern")_"  interval="_CONF("interval")_"s",.CONF)
	DO LINE("INFO","stopFile="_CONF("stopFile"),.CONF)
	IF $GET(CONF("onfile"))'="" DO LINE("INFO","onfile="_CONF("onfile"),.CONF)
	IF $GET(CONF("captureDir"))'="" DO LINE("INFO","captureDir="_CONF("captureDir"),.CONF)
	QUIT
	;
LOGX(LEVEL,MSG,CONF)
	NEW id SET id=CONF("id")
	NEW line SET line=$$TS()_" ["_LEVEL_"] "_MSG
	; logfile
	IF $GET(CONF("logIO"))'="" DO
	. NEW old SET old=$IO
	. USE CONF("logIO") WRITE line,!
	. USE old
	; state
	IF LEVEL="ERROR" DO ADDERROR(id,MSG)
	IF LEVEL="INFO"!(LEVEL="OK")!(LEVEL="WARN") SET ^MIO("DEVW",id,"STATE","status")=MSG
	SET ^MIO("DEVW",id,"STATE","dirty")=1
	; push to log ring (for log panel)
	IF $GET(CONF("ui")) DO ADDLOG(id,LEVEL,MSG)
	; classic terminal lines
	IF '$GET(CONF("ui")) DO LINE(LEVEL,MSG,.CONF)
	QUIT
	;
LINE(LEVEL,MSG,CONF)
	NEW line SET line=$$TS()_" ["_LEVEL_"] "_MSG
	IF $GET(CONF("tty")) DO
	. NEW io SET io=$GET(CONF("ttyIO"),$IO)
	. USE io
	. WRITE $CHAR(13),$$CLRLINE()
	. WRITE $$C(LEVEL,.CONF),line,$$RESET(.CONF),!
	IF $GET(CONF("logIO"))'="" DO
	. NEW old SET old=$IO
	. USE CONF("logIO") WRITE line,!
	. USE old
	QUIT
	;
OPENLOG(CONF)
	NEW lf SET lf=$GET(CONF("logFile"))
	IF lf="" QUIT
	NEW $ETRAP,$ES,tty
	SET tty=$IO
	SET $ETRAP="USE tty SET CONF(""logIO"")="""" SET $ECODE="""" QUIT"
	OPEN lf:(APPEND)
	SET CONF("logIO")=lf
	USE tty
	QUIT
	;
CLOSELOG(CONF)
	IF $GET(CONF("logIO"))'="" CLOSE CONF("logIO")
	KILL CONF("logIO")
	QUIT
	;
ET(ST,CONF)
	NEW io SET io=$GET(CONF("ttyIO"),$IO)
	USE io
	WRITE !
	WRITE $$C("ERROR",.CONF),"[FATAL] ",ST,$$RESET(.CONF),!
	IF $GET(CONF("ui")) DO UIEND(.CONF)
	DO CLOSELOG(.CONF)
	QUIT
	;
; -------------------- IPC + control --------------------
	;
PUBSTATUS(ID,MSG)   DO PUBEVENT(ID,"status",MSG,"","") QUIT
PUBERR(ID,MSG)      DO PUBEVENT(ID,"error",MSG,"","") QUIT
PUBFILE(ID,FP,ST,DETAIL) DO PUBEVENT(ID,"file",FP,"status",ST_"|"_DETAIL) QUIT
PUBMET(ID,NAME,DELTA) DO PUBEVENT(ID,"metadd","",NAME,DELTA) QUIT
PUBSET(ID,NAME,VALUE) DO PUBEVENT(ID,"metset","",NAME,VALUE) QUIT
PUBLOG(ID,LEVEL,MSG) DO PUBEVENT(ID,"log",MSG,"level",LEVEL) QUIT
	;
SETCTL(ID,NAME,VALUE)
	SET ^MIO("DEVW",ID,"CTL",NAME)=VALUE
	; Force a repaint on next UIRENDER (important for logFilter/logScroll)
	SET ^MIO("DEVW",ID,"STATE","dirty")=1
	QUIT
	;
GETCTL(ID,NAME)
	QUIT $GET(^MIO("DEVW",ID,"CTL",NAME))
	;
PUBEVENT(ID,TYPE,MSG,K,V)
	NEW seq
	SET seq=$INCREMENT(^MIO("DEVW",ID,"Q","next"))
	SET ^MIO("DEVW",ID,"Q",seq,"ts")=$H
	SET ^MIO("DEVW",ID,"Q",seq,"job")=$J
	SET ^MIO("DEVW",ID,"Q",seq,"type")=TYPE
	SET ^MIO("DEVW",ID,"Q",seq,"msg")=MSG
	IF $GET(K)'="" SET ^MIO("DEVW",ID,"Q",seq,"k")=K
	IF $DATA(V) SET ^MIO("DEVW",ID,"Q",seq,"v")=V
	QUIT
	;
UIPOLL(CONF,lastSeq)
	NEW id SET id=CONF("id")
	NEW next SET next=+$GET(^MIO("DEVW",id,"Q","next"))
	FOR  QUIT:lastSeq>=next  DO
	. SET lastSeq=lastSeq+1
	. NEW type,msg,k,v
	. SET type=$GET(^MIO("DEVW",id,"Q",lastSeq,"type"))
	. SET msg=$GET(^MIO("DEVW",id,"Q",lastSeq,"msg"))
	. SET k=$GET(^MIO("DEVW",id,"Q",lastSeq,"k"))
	. SET v=$GET(^MIO("DEVW",id,"Q",lastSeq,"v"))
	. IF type="status" SET ^MIO("DEVW",id,"STATE","status")=msg,^MIO("DEVW",id,"STATE","dirty")=1
	. IF type="error" DO ADDERROR(id,msg)
	. IF type="file" DO
	. . NEW st,detail SET st=$PIECE(v,"|",1),detail=$PIECE(v,"|",2,999)
	. . DO ADDRECENT(id,msg,st,detail)
	. IF type="metadd" DO METADD(id,k,+v)
	. IF type="metset" DO METSET(id,k,v)
	. IF type="log" DO ADDLOG(id,$SELECT(v'="":v,1:"INFO"),msg)
	. KILL ^MIO("DEVW",id,"Q",lastSeq)
	SET ^MIO("DEVW",id,"STATE","qdone")=lastSeq
	QUIT
	;
; -------------------- State helpers --------------------
	;
METADD(ID,NAME,DELTA)
	SET ^MIO("DEVW",ID,"STATE","metrics",NAME)=+$GET(^MIO("DEVW",ID,"STATE","metrics",NAME))+(+DELTA)
	SET ^MIO("DEVW",ID,"STATE","dirty")=1
	QUIT
	;
METSET(ID,NAME,VALUE)
	SET ^MIO("DEVW",ID,"STATE","metrics",NAME)=VALUE
	SET ^MIO("DEVW",ID,"STATE","dirty")=1
	QUIT
	;
ADDRECENT(ID,FILE,STATUS,DETAIL)
	NEW max,n,idx
	SET max=+$GET(^MIO("DEVW",ID,"STATE","conf","lastN"),10)
	SET n=+$GET(^MIO("DEVW",ID,"STATE","recent","n"))
	SET idx=(n#max)+1
	SET ^MIO("DEVW",ID,"STATE","recent","n")=n+1
	SET ^MIO("DEVW",ID,"STATE","recent",idx)=$$TS()_"^"_STATUS_"^"_$$BASENAME(FILE)_"^"_DETAIL
	SET ^MIO("DEVW",ID,"STATE","dirty")=1
	QUIT
	;
ADDERROR(ID,MSG)
	NEW max,n,idx
	SET max=+$GET(^MIO("DEVW",ID,"STATE","conf","errN"),6)
	SET n=+$GET(^MIO("DEVW",ID,"STATE","errors","n"))
	SET idx=(n#max)+1
	SET ^MIO("DEVW",ID,"STATE","errors","n")=n+1
	SET ^MIO("DEVW",ID,"STATE","errors",idx)=$$TS()_"^"_$EXTRACT(MSG,1,140)
	SET ^MIO("DEVW",ID,"STATE","dirty")=1
	QUIT
	;
ADDLOG(ID,LEVEL,MSG)
	NEW max,n,idx
	SET max=+$GET(^MIO("DEVW",ID,"STATE","conf","logMax"),100)
	SET n=+$GET(^MIO("DEVW",ID,"STATE","log","n"))
	SET idx=(n#max)+1
	SET ^MIO("DEVW",ID,"STATE","log","n")=n+1
	SET ^MIO("DEVW",ID,"STATE","log",idx)=$$TS()_"^"_LEVEL_"^"_$EXTRACT(MSG,1,200)
	SET ^MIO("DEVW",ID,"STATE","dirty")=1
	QUIT
	;
; -------------------- Log scroll helper APIs (ROI) --------------------
	;
LOGEND(ID)
	DO SETCTL(ID,"logScroll",0)
	QUIT:$Q 0
	QUIT
	;
LOGHOME(ID)
	NEW lines SET lines=+$GET(^MIO("DEVW",ID,"STATE","ui","log","lines"))
	NEW filt SET filt=$$LOGFILT(ID)
	NEW maxS SET maxS=$$LOGMAXSCROLL(ID,filt,lines)
	DO SETCTL(ID,"logScroll",maxS)
	QUIT maxS
	;
LOGUP(ID,N)
	SET N=+$GET(N,1) IF N<1 SET N=1
	NEW lines SET lines=+$GET(^MIO("DEVW",ID,"STATE","ui","log","lines"))
	NEW filt SET filt=$$LOGFILT(ID)
	NEW maxS SET maxS=$$LOGMAXSCROLL(ID,filt,lines)
	NEW cur SET cur=+$GET(^MIO("DEVW",ID,"CTL","logScroll"))
	NEW s SET s=cur+N IF s>maxS SET s=maxS
	DO SETCTL(ID,"logScroll",s)
	QUIT s
	;
LOGDOWN(ID,N)
	SET N=+$GET(N,1) IF N<1 SET N=1
	NEW cur SET cur=+$GET(^MIO("DEVW",ID,"CTL","logScroll"))
	NEW s SET s=cur-N IF s<0 SET s=0
	DO SETCTL(ID,"logScroll",s)
	QUIT s
	;
LOGPAGEUP(ID)
	NEW lines SET lines=+$GET(^MIO("DEVW",ID,"STATE","ui","log","lines"))
	IF lines<2 SET lines=2
	QUIT $$LOGUP(ID,lines-1)
	;
LOGPAGEDN(ID)
	NEW lines SET lines=+$GET(^MIO("DEVW",ID,"STATE","ui","log","lines"))
	IF lines<2 SET lines=2
	QUIT $$LOGDOWN(ID,lines-1)
	;
LOGFILT(ID)
	NEW f SET f=$GET(^MIO("DEVW",ID,"CTL","logFilter"))
	IF f="" SET f="ALL"
	QUIT f
	;
LOGMAXSCROLL(ID,FILT,LINES)
	; max scroll value given current filter and viewport size
	SET LINES=+$GET(LINES)
	IF LINES<1 QUIT 0
	NEW max SET max=+$GET(^MIO("DEVW",ID,"STATE","conf","logMax"),100)
	NEW n SET n=+$GET(^MIO("DEVW",ID,"STATE","log","n"))
	NEW cap SET cap=$SELECT(n<max:n,1:max)
	NEW i,idx,rec,lvl,match
	SET match=0
	FOR i=0:1:(cap-1) DO
	. SET idx=((n-i-1)#max)+1
	. SET rec=$GET(^MIO("DEVW",ID,"STATE","log",idx))
	. IF rec="" QUIT
	. SET lvl=$PIECE(rec,"^",2)
	. IF $$LOGMATCH(FILT,lvl) SET match=match+1
	NEW ms SET ms=match-LINES
	IF ms<0 SET ms=0
	QUIT ms
	;
LOGMATCH(FILT,LVL)
	NEW f,l
	SET f=$ZCONVERT($GET(FILT,"ALL"),"U")
	SET l=$ZCONVERT($GET(LVL,""),"U")
	IF f=""!(f="ALL") QUIT 1
	; comma-separated levels, e.g. "WARN,ERROR"
	QUIT ((","_f_",")[(","_l_","))
	;
; -------------------- UI (widgets) --------------------
	;
UISTART(CONF)
	DO UIINIT(.CONF)
	NEW io SET io=$GET(CONF("ttyIO"),$IO)
	IF +$GET(CONF("dryUI")) DO  QUIT
	. NEW LAY,CTX
	. DO UILAYOUT(.CONF,.LAY)
	. DO WDRAW(.CONF,.LAY,.CTX)
	IF '$GET(CONF("tty")) QUIT
	USE io
	IF $GET(CONF("alt")) WRITE $$ALT(1)
	WRITE $$HIDECUR(),$$CLR()
	NEW LAY,CTX
	DO UILAYOUT(.CONF,.LAY)
	DO WDRAW(.CONF,.LAY,.CTX)
	QUIT
	;
UIEND(CONF)
	IF +$GET(CONF("dryUI")) QUIT
	IF '$GET(CONF("tty")) QUIT
	NEW io SET io=$GET(CONF("ttyIO"),$IO)
	USE io
	WRITE $$SHOWCUR()
	IF $GET(CONF("alt")) WRITE $$ALT(0)
	QUIT
	;
UIRENDER(CONF,spinI,lastRateH,lastRateP)
	IF '$GET(CONF("ui")) QUIT
	NEW id SET id=CONF("id")
	NEW dirty SET dirty=+$GET(^MIO("DEVW",id,"STATE","dirty"))
	SET ^MIO("DEVW",id,"STATE","dirty")=0
	;
	NEW LAY,CTX
	DO UILAYOUT(.CONF,.LAY)
	;
	; compute rate
	NEW nowH SET nowH=$H
	NEW p SET p=+$GET(^MIO("DEVW",id,"STATE","metrics","processed"))
	NEW dt SET dt=$$HSECS(nowH,lastRateH)
	NEW rate SET rate=0
	IF dt>0 SET rate=(p-lastRateP)/dt
	SET lastRateH=nowH,lastRateP=p
	;
	SET CTX("spin")=$EXTRACT("|/-""",((+$GET(spinI))#4)+1)
	SET CTX("status")=$GET(^MIO("DEVW",id,"STATE","status"),"Watching...")
	SET CTX("processed")=p
	SET CTX("rate")=rate
	SET CTX("dirty")=dirty
	SET CTX("id")=id
	;
	DO WPAINT(.CONF,.LAY,.CTX)
	QUIT
	;
; -------------------- Default widgets --------------------
	;
WCHROME(CONF,LAY,CTX)
	; static scaffolding
	NEW rows,cols,splitC,r
	SET rows=LAY("rows"),cols=LAY("cols"),splitC=LAY("splitC")
	DO PUT(LAY("hdr1"),1,$$C("HEAD",.CONF)_"MIODEVW"_$$RESET(.CONF)_" "_$$C("DIM",.CONF)_"id="_$GET(CONF("id"))_$$RESET(.CONF))
	DO PUT(LAY("hdr2"),1,$$C("DIM",.CONF)_"dir="_CONF("dir")_"  pattern="_CONF("pattern")_"  interval="_CONF("interval")_"s"_$$RESET(.CONF))
	DO HLINE(LAY("div1"),1,cols)
	DO HLINE(LAY("div2"),1,cols)
	DO PUT(LAY("colhdr"),1,$$C("HEAD",.CONF)_"Recent"_$$RESET(.CONF))
	DO PUT(LAY("colhdr"),splitC+1,$$C("HEAD",.CONF)_"Errors"_$$RESET(.CONF))
	FOR r=LAY("colhdr"):1:LAY("listBottom") DO PUT(r,splitC,"|")
	IF +$GET(CONF("logPanel")) DO
	. DO HLINE(LAY("logTop")-1,1,cols)
	. DO PUT(LAY("logTop")-1,1,$$C("HEAD",.CONF)_"Log"_$$RESET(.CONF))
	DO HLINE(LAY("divB"),1,cols)
	DO PUT(LAY("help"),1,$$C("DIM",.CONF)_"IPC: PUBLOG/PUBSTATUS  |  CTL: pause/stop/logFilter/logScroll  |  LOGPAGEUP/LOGPAGEDN"_$$RESET(.CONF))
	QUIT
	;
WHEADER(CONF,LAY,CTX)
	NEW cols SET cols=LAY("cols")
	DO PUT(LAY("hdr1"),20,$$C("DIM",.CONF)_"["_CTX("spin")_"] "_$$RESET(.CONF)_$$FIT(CTX("status"),cols-22))
	NEW qnext SET qnext=+$GET(^MIO("DEVW",CTX("id"),"Q","next"))
	NEW qdone SET qdone=+$GET(^MIO("DEVW",CTX("id"),"STATE","qdone"))
	NEW qlag SET qlag=qnext-qdone IF qlag<0 SET qlag=0
	NEW ctl SET ctl="pause="_$$YESNO($$GETCTL(CTX("id"),"pause"))_" stop="_$$YESNO($$GETCTL(CTX("id"),"stop"))_" qlag="_qlag
	DO PUT(LAY("hdr2"),cols-$L(ctl)+1,$$C("DIM",.CONF)_ctl_$$RESET(.CONF))
	QUIT
WMETRICS(CONF,LAY,CTX)
	NEW cols SET cols=LAY("cols")
	NEW id SET id=CTX("id")
	NEW scans,ok,errs,uptime
	SET scans=+$GET(^MIO("DEVW",id,"STATE","metrics","scans"))
	SET ok=+$GET(^MIO("DEVW",id,"STATE","metrics","ok"))
	SET errs=+$GET(^MIO("DEVW",id,"STATE","metrics","errors"))
	SET uptime=$$UPTIME($GET(^MIO("DEVW",id,"STATE","startH"),$H),$H)
	NEW mline SET mline="uptime "_uptime_"  scans "_scans_"  processed "_CTX("processed")_"  ok "_ok_"  errors "_errs_"  rate "_$$FMT(CTX("rate"),2)_"/s"
	DO PUT(LAY("met"),1,$$FIT(mline,cols))
	QUIT
WRECENT(CONF,LAY,CTX)
	IF 'CTX("dirty") QUIT
	NEW id SET id=CTX("id")
	NEW top SET top=LAY("listTop") N bottom SET bottom=LAY("listBottom")
	NEW width SET width=LAY("leftW")
	NEW max SET max=+$GET(^MIO("DEVW",id,"STATE","conf","lastN"),10)
	NEW n SET n=+$GET(^MIO("DEVW",id,"STATE","recent","n"))
	NEW i,row,idx,rec,ts,st,name,detail,line
	FOR row=top:1:bottom DO
	. SET i=row-top+1
	. IF i>max DO PUT(row,1,$$FIT("",width)) QUIT
	. SET idx=((n-i)#max)+1
	. SET rec=$GET(^MIO("DEVW",id,"STATE","recent",idx))
	. IF rec="" DO PUT(row,1,$$FIT("",width)) QUIT
	. SET ts=$PIECE(rec,"^",1),st=$PIECE(rec,"^",2),name=$PIECE(rec,"^",3),detail=$PIECE(rec,"^",4,99)
	. SET line=ts_" ["_st_"] "_name
	. IF detail'="" SET line=line_" - "_detail
	. DO PUT(row,1,$$FIT($$COLORST(st,line,.CONF),width))
	QUIT
WERRORS(CONF,LAY,CTX)
	IF 'CTX("dirty") QUIT
	NEW id SET id=CTX("id")
	NEW top SET top=LAY("listTop") N bottom SET bottom=LAY("listBottom")
	NEW left SET left=LAY("splitC")+1
	NEW width SET width=LAY("errW")
	NEW max SET max=+$GET(^MIO("DEVW",id,"STATE","conf","errN"),6)
	NEW n SET n=+$GET(^MIO("DEVW",id,"STATE","errors","n"))
	NEW i,row,idx,rec
	FOR row=top:1:bottom DO
	. SET i=row-top+1
	. IF i>max DO PUT(row,left,$$FIT("",width)) QUIT
	. SET idx=((n-i)#max)+1
	. SET rec=$GET(^MIO("DEVW",id,"STATE","errors",idx))
	. IF rec="" DO PUT(row,left,$$FIT("",width)) QUIT
	. DO PUT(row,left,$$FIT($$C("ERROR",.CONF)_rec_$$RESET(.CONF),width))
	QUIT
WLOG(CONF,LAY,CTX)
	; Scrollable log panel (bottom)
	NEW id SET id=CTX("id")
	NEW top SET top=LAY("logTop") N bottom SET bottom=LAY("logBottom")
	IF top<1!(bottom<top) QUIT
	NEW lines SET lines=LAY("logLines")
	SET ^MIO("DEVW",id,"STATE","ui","log","lines")=lines
	NEW cols SET cols=LAY("cols")
	NEW filt SET filt=$$LOGFILT(id)
	NEW maxS SET maxS=$$LOGMAXSCROLL(id,filt,lines)
	NEW scroll SET scroll=+$GET(^MIO("DEVW",id,"CTL","logScroll"))
	IF scroll<0 SET scroll=0
	IF scroll>maxS SET scroll=maxS SET ^MIO("DEVW",id,"CTL","logScroll")=scroll
	; header line (uses div above already) - show filter+scroll
	NEW hdr SET hdr="filter="_filt_"  scroll="_scroll_"/"_maxS
	DO PUT(top-1,cols-$L(hdr)+1,$$C("DIM",.CONF)_hdr_$$RESET(.CONF))
	 ; --- FORCE REPAINT when logFilter/logScroll changes ---
	NEW id SET id=$GET(CONF("id"),"default")
	NEW fltNow SET fltNow=$$LOGFILTER(id)            ; normalize to "ALL"/"ERROR"/"WARN,ERROR"
	NEW scrNow SET scrNow=+$$GETCTL(id,"logScroll")  ; 0 = tail
	NEW fltOld SET fltOld=$GET(^MIO("DEVW",id,"STATE","ui","log","flt"))
	NEW scrOld SET scrOld=+$GET(^MIO("DEVW",id,"STATE","ui","log","scr"))
	NEW force SET force=((fltNow'=fltOld)!(scrNow'=scrOld))
	IF force DO
	. SET ^MIO("DEVW",id,"STATE","ui","log","flt")=fltNow
	. SET ^MIO("DEVW",id,"STATE","ui","log","scr")=scrNow
	. ; clear uidiff cache for the log rows so repaint produces ops (fixes your 2 test failures)
	. DO CLRCACHE(LAY("logTop"),LAY("logTop")+LAY("logLines")-1)
	. SET CTX("dirty")=1
	; If not dirty (and no force), nothing to repaint
	; IF '$GET(CTX("dirty")) QUIT
	; render log lines newest->oldest applying scroll and filter
	IF 'CTX("dirty") QUIT  ; only repaint on dirty
	NEW max SET max=+$GET(^MIO("DEVW",id,"STATE","conf","logMax"),100)
	NEW n SET n=+$GET(^MIO("DEVW",id,"STATE","log","n"))
	NEW cap SET cap=$SELECT(n<max:n,1:max)
	NEW needSkip SET needSkip=scroll
	NEW outCount SET outCount=0
	NEW lines SET lines=+$GET(LAY("logLines")) IF lines<1 SET lines=1
	SET ^MIO("DEVW",id,"STATE","ui","log","lines")=lines
	NEW maxS SET maxS=$$LOGMAXSCROLL(id,fltNow,lines)
	IF scrNow>maxS DO
	. SET scrNow=maxS
	. SET ^MIO("DEVW",id,"CTL","logScroll")=scrNow
	. DO CLRCACHE(LAY("logTop"),LAY("logTop")+lines-1)
	NEW i,idx,rec,lvl,msg
	FOR i=0:1:(cap-1) QUIT:outCount'<lines  DO
	. SET idx=((n-i-1)#max)+1
	. SET rec=$GET(^MIO("DEVW",id,"STATE","log",idx))
	. IF rec="" QUIT
	. SET lvl=$PIECE(rec,"^",2),msg=$PIECE(rec,"^",3)
	. IF '$$LOGMATCH(filt,lvl) QUIT
	. IF needSkip>0 SET needSkip=needSkip-1 QUIT
	. SET outCount=outCount+1
	. NEW row SET row=top+outCount-1
	. NEW line SET line=$PIECE(rec,"^",1)_" ["_lvl_"] "_msg
	. DO PUT(row,1,$$FIT($$LOGLINE(lvl,line,.CONF),cols))
	;
	; clear remaining
	NEW row
	FOR row=(top+outCount):1:bottom DO PUT(row,1,$$FIT("",cols))
	QUIT
	;
LOGLINE(LVL,LINE,CONF)
	NEW l SET l=$ZCONVERT($GET(LVL),"U")
	IF l="ERROR" QUIT $$C("ERROR",.CONF)_LINE_$$RESET(.CONF)
	IF l="WARN" QUIT $$C("WARN",.CONF)_LINE_$$RESET(.CONF)
	IF l="OK" QUIT $$C("OK",.CONF)_LINE_$$RESET(.CONF)
	IF l="INFO" QUIT $$C("INFO",.CONF)_LINE_$$RESET(.CONF)
	QUIT $$C("DIM",.CONF)_LINE_$$RESET(.CONF)
	;
; -------------------- Drawing primitives (dryUI + uidiff) --------------------
	;
PUT(R,C,S)
	; If dryUI, record ops; if uidiff, suppress identical writes
	NEW dry SET dry=+$GET(^TMP($J,"MIODEVW","UI","dry"))
	NEW uid SET uid=+$GET(^TMP($J,"MIODEVW","UI","uidiff"))
	IF dry DO  QUIT
	. NEW cacheKey SET cacheKey=R_","_C
	. IF uid,$GET(^TMP($J,"MIODEVW","UI","cache",R,C))=$GET(S) QUIT
	. SET ^TMP($J,"MIODEVW","UI","cache",R,C)=$GET(S)
	. NEW n SET n=+$GET(^TMP($J,"MIODEVW","UI","ops"))+1
	. SET ^TMP($J,"MIODEVW","UI","ops")=n
	. SET ^TMP($J,"MIODEVW","UI","ops",n)="("_R_","_C_") "_$GET(S)
	;
	IF '$GET(^TMP($J,"MIODEVW","UI","tty")) QUIT
	NEW io SET io=$GET(^TMP($J,"MIODEVW","UI","ttyIO"),$IO)
	USE io
	WRITE $$GOTO(R,C),S,$$CLREOL()
	QUIT
	;
HLINE(R,C,L)
	NEW i,s SET s=""
	FOR i=1:1:L SET s=s_"-"
	DO PUT(R,C,s)
	QUIT
	;
COLORST(ST,LINE,CONF)
	IF '$GET(CONF("color")) QUIT LINE
	IF ST="OK" QUIT $$C("OK",.CONF)_LINE_$$RESET(.CONF)
	IF ST="RUN" QUIT $$C("INFO",.CONF)_LINE_$$RESET(.CONF)
	IF ST="ERR" QUIT $$C("ERROR",.CONF)_LINE_$$RESET(.CONF)
	IF ST="WARN" QUIT $$C("WARN",.CONF)_LINE_$$RESET(.CONF)
	QUIT LINE
	;
; -------------------- File helpers --------------------
	;
FILEINFO(FILE,BYTES,LINES,ERR)
	NEW $ETRAP,$ES,old
	SET old=$IO
	SET (BYTES,LINES)=0,ERR=""
	SET $ETRAP="SET ERR=$ZSTATUS,$ECODE="""",BYTES=0,LINES=0 USE old QUIT"
	OPEN FILE:(READONLY)
	USE FILE
	NEW x
	FOR  READ x QUIT:$ZEOF  DO
	. SET LINES=LINES+1
	. SET BYTES=BYTES+$LENGTH(x)+1
	CLOSE FILE
	USE old
	QUIT
	;
EXISTS(PATH)
	NEW ok,$ETRAP,$ES
	SET ok=1
	SET $ETRAP="SET ok=0,$ECODE="""" QUIT ok"
	OPEN PATH:(READONLY)
	CLOSE PATH
	QUIT ok
	;
; -------------------- String / path helpers --------------------
	;
PATTERN(CONF)
	QUIT $$JOIN($GET(CONF("dir"),"."),$GET(CONF("pattern"),"*.req"))
	;
JOIN(DIR,NAME)
	NEW d SET d=DIR
	IF d="" QUIT NAME
	IF $EXTRACT(d,$LENGTH(d))="/" QUIT d_NAME
	QUIT d_"/"_NAME
	;
BASENAME(PATH)
	NEW p SET p=PATH
	FOR  QUIT:p=""  QUIT:$EXTRACT(p,$LENGTH(p))'="/"  SET p=$EXTRACT(p,1,$LENGTH(p)-1)
	NEW i FOR i=$LENGTH(p):-1:1 QUIT:$EXTRACT(p,i)="/"
	IF i<1 QUIT p
	QUIT $EXTRACT(p,i+1,$LENGTH(p))
	;
ESCQ(S)
	QUIT $TRANSLATE(S,"""","""""")
	;
RTN()
	QUIT $PIECE($TEXT(+0)," ",1)
	;
FIT(S,W)
	NEW x SET x=$GET(S)
	IF $LENGTH(x)>W QUIT $EXTRACT(x,1,W)
	QUIT x_$$REPL(" ",W-$LENGTH(x))
	;
REPL(CH,N)
	NEW i,s SET s=""
	FOR i=1:1:+$GET(N) SET s=s_CH
	QUIT s
	;
; -------------------- Time helpers --------------------
	;
TS() QUIT $$H2ISO($H)
NOW() QUIT $H
	;
H2ISO(H)
	NEW days,secs SET days=+$PIECE(H,",",1),secs=+$PIECE(H,",",2)
	NEW hh,mm,ss SET hh=secs\3600,mm=(secs#3600)\60,ss=secs#60
	NEW y,m,d DO H2YMD(days,.y,.m,.d)
	QUIT y_"-"_$$Z2(m)_"-"_$$Z2(d)_"T"_$$Z2(hh)_":"_$$Z2(mm)_":"_$$Z2(ss)
	;
Z2(N) QUIT $SELECT(N<10:"0"_N,1:N)
	;
H2YMD(DAYS,Y,M,D)
	NEW z SET z=DAYS+672046
	NEW era,doe,yoe,doy,mp
	SET era=z\146097
	SET doe=z#146097
	SET yoe=(doe-doe\1460+doe\36524-doe\146096)\365
	SET Y=yoe+(era*400)
	SET doy=doe-(365*yoe+yoe\4-yoe\100)
	SET mp=(5*doy+2)\153
	SET D=doy-(153*mp+2)\5+1
	SET M=mp+$SELECT(mp<10:3,1:-9)
	SET Y=Y+$SELECT(M<=2:1,1:0)
	QUIT
	;
HSECS(H1,H0)
	NEW d1,s1,d0,s0
	SET d1=+$PIECE(H1,",",1),s1=+$PIECE(H1,",",2)
	SET d0=+$PIECE(H0,",",1),s0=+$PIECE(H0,",",2)
	QUIT (d1-d0)*86400+(s1-s0)
	;
UPTIME(H0,H1)
	NEW s SET s=$$HSECS(H1,H0) IF s<0 SET s=0
	NEW hh SET hh=s\3600,mm=(s#3600)\60,ss=s#60
	QUIT $$Z2(hh)_":"_$$Z2(mm)_":"_$$Z2(ss)
	;
FMT(X,D)
	NEW sign SET sign="" IF X<0 SET sign="-",X=-X
	NEW p SET p=10**+$GET(D)
	NEW n SET n=(X*p)+0.5\1
	NEW a SET a=n\p
	NEW b SET b=n#p
	IF +$GET(D)=0 QUIT sign_a
	NEW bs SET bs=b
	FOR  QUIT:$LENGTH(bs)'<D  SET bs="0"_bs
	QUIT sign_a_"."_bs
	;
YESNO(V) QUIT $SELECT(+V:"YES",1:"NO")
	;
; -------------------- ANSI helpers --------------------
	;
GOTO(R,C)   QUIT $CHAR(27)_"["_R_";"_C_"H"
CLR()       QUIT $CHAR(27)_"[2J"
CLREOL()    QUIT $CHAR(27)_"[2K"
HIDECUR()   QUIT $CHAR(27)_"[?25l"
SHOWCUR()   QUIT $CHAR(27)_"[?25h"
ALT(ON)     QUIT $SELECT(ON:$CHAR(27)_"[?1049h",1:$CHAR(27)_"[?1049l")
	;
RESET(CONF)
	IF '$GET(CONF("color")) QUIT ""
	QUIT $CHAR(27)_"[0m"
	;
CLRLINE() QUIT $CHAR(27)_"[2K"
	;
C(LEVEL,CONF)
	IF '$GET(CONF("color")) QUIT ""
	NEW esc SET esc=$CHAR(27)_"["
	IF LEVEL="ERROR" QUIT esc_"31m"
	IF LEVEL="WARN"  QUIT esc_"33m"
	IF LEVEL="INFO"  QUIT esc_"32m"
	IF LEVEL="OK"    QUIT esc_"36m"
	IF LEVEL="DEBUG" QUIT esc_"90m"
	IF LEVEL="HEAD"  QUIT esc_"35m"
	IF LEVEL="DIM"   QUIT esc_"90m"
	QUIT esc_"0m"
	;
CLRCACHE(TOP,BOT)
	; Clear uidiff cache for a row range (forces PUT to emit ops again)
	NEW r
	FOR r=TOP:1:BOT KILL ^TMP($J,"MIODEVW","UI","cache",r)
	QUIT
LOGFILTER(ID)
	NEW f SET f=$GET(^MIO("DEVW",ID,"CTL","logFilter"))
	SET f=$$TRIM($$UCASE(f))
	IF f="" SET f="ALL"
	QUIT f
	;
UCASE(S) QUIT $ZCONVERT($GET(S),"U")
TRIM(S)
	FOR  QUIT:$EXTRACT(S,1)'=" "  SET S=$EXTRACT(S,2,$LENGTH(S))
	QUIT S