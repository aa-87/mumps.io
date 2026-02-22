MIODEVW ; MIO Development Watcher (dashboard + IPC + pretty logs)
	;
	; Compatible: YottaDB / GT.M (Linux terminals with ANSI supported)
	;
	; ROI (implemented)
	;   1) Minimalist dashboard UI (metrics, rate, recent, errors)
	;   2) IPC updates from other processes (PUB* APIs -> queue)
	;   3) External control (pause/stop)
	;   4) Still supports classic "LINE()" output mode if ui=0
	;
	; PUBLIC ENTRYPOINTS
	;   DEVWATCH         - your convenience launcher (uses ^MIO("CONF"))
	;   START(.CONF)     - loop watcher
	;   ONCE(.CONF)      - one pass
	;   HELP             - usage
	;
	; IPC (other jobs)
	;   D PUBSTATUS^MIODEVW(ID,"msg")
	;   D PUBERR^MIODEVW(ID,"msg")
	;   D PUBFILE^MIODEVW(ID,FP,"OK|RUN|ERR","detail")
	;   D PUBMET^MIODEVW(ID,"metric",delta)
	;   D PUBSET^MIODEVW(ID,"metric",value)
	;   D SETCTL^MIODEVW(ID,"pause",1)   ; pause watcher
	;   D SETCTL^MIODEVW(ID,"pause",0)
	;   D SETCTL^MIODEVW(ID,"stop",1)    ; stop watcher
	;
	; Callback signature (recommended)
	;   TAG(FILE,.CONF,.ERR)
	;
	; ------------------------------------------------------------
	;
DEVWATCH
	NEW CONF,C
	KILL C
	MERGE CONF=^MIO("CONF")
	;
	SET C("id")="mio" ; dashboard channel id (publish to this from other jobs)
	SET C("dir")=$GET(CONF("server","templateDir"))
	IF C("dir")="" SET C("dir")="templates"
	;
	SET C("pattern")="*.*"
	SET C("interval")=1
	SET C("logFile")=$$JOIN(C("dir"),"mio-devwatch.log")
	SET C("stopFile")=$$JOIN(C("dir"),".miodevw.stop")
	;
	SET C("color")=1
	SET C("tty")=1
	;
	; Dashboard defaults (minimalist, extendible)
	SET C("ui")=1         ; 1=dashboard, 0=classic LINE() output
	SET C("alt")=1        ; alternate screen buffer (recommended)
	SET C("rows")=24      ; set to your terminal for best results
	SET C("cols")=100
	SET C("lastN")=10
	SET C("errN")=6
	;
	; Optional: capture callback stdout to per-file log
	SET C("captureDir")=""
	;
	; Callback to actually process files:
	SET C("onfile")="PROCESS^MIODEVW"
	;
	DO START^MIODEVW(.C)
	QUIT
	;
PROCESS(FP,CONF,ERR)
	; Your sample processing hook:
	; (keep simple; publish status/errors if you want)
	SET ERR=""
	MERGE ^AHM($INCREMENT(^AHM))=FP
	; Example IPC update:
	DO PUBFILE($GET(CONF("id"),"mio"),FP,"OK","queued")
	QUIT
	;
; -------------------- Main loop --------------------
	;
START(CONF)
	NEW $ETRAP,$ES
	SET $ETRAP="DO ET^MIODEVW($ZSTATUS,.CONF) QUIT"
	;
	DO DEFAULT(.CONF)
	SET CONF("ttyIO")=$IO
	;
	DO OPENLOG(.CONF)
	DO INITSTATE(.CONF)
	;
	IF $GET(CONF("ui")) DO UISTART(.CONF) ELSE  DO BANNER(.CONF)
	;
	NEW spinI SET spinI=0
	NEW lastSeq SET lastSeq=+$GET(^MIO("DEVW",CONF("id"),"STATE","qdone"))
	;
	NEW lastRateH SET lastRateH=$H
	NEW lastRateP SET lastRateP=+$GET(^MIO("DEVW",CONF("id"),"STATE","metrics","processed"))
	;
	FOR  DO  QUIT:$$SHOULDSTOP(.CONF)
	. ; Consume IPC events & repaint
	. DO UIPOLL(.CONF,.lastSeq)
	. DO UIRENDER(.CONF,.spinI,.lastRateH,.lastRateP)
	. ; Pause support (UI still updates)
	. IF $$GETCTL(CONF("id"),"pause") DO  QUIT
	. . SET spinI=spinI+1
	. . HANG +$GET(CONF("interval"),1)
	. NEW files DO SCAN(.CONF,.files)
	. DO METADD(CONF("id"),"scans",1)
	. NEW did SET did=0
	. NEW f SET f=""
	. FOR  SET f=$ORDER(files(f)) QUIT:f=""  DO
	. . SET did=did+$$HANDLE(f,.CONF)
	. IF 'did DO  ; idle tick (classic mode uses one-line status)
	. . IF '$GET(CONF("ui")) DO IDLE(.CONF,.spinI)
	. . SET spinI=spinI+1
	. HANG +$GET(CONF("interval"),1)
	DO LOGX("INFO","Watcher stopped.",.CONF)
	IF $GET(CONF("ui")) DO UIEND(.CONF)
	DO CLOSELOG(.CONF)
	QUIT
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
	WRITE "  D START^MIODEVW(.CONF)   ; loop",!
	WRITE "  D ONCE^MIODEVW(.CONF)    ; one pass",!
	WRITE "  D DEVWATCH^MIODEVW       ; uses ^MIO(""CONF"")",!
	WRITE !
	WRITE "CONF() common:",!
	WRITE "  id, dir, pattern, interval, stopFile, logFile, onfile, captureDir",!
	WRITE "  tty=1, color=1",!
	WRITE "  ui=1 (dashboard), alt=1, rows, cols, lastN, errN",!
	WRITE !
	WRITE "IPC from other jobs:",!
	WRITE "  D PUBSTATUS^MIODEVW(ID,""..."")",!
	WRITE "  D PUBERR^MIODEVW(ID,""..."")",!
	WRITE "  D PUBFILE^MIODEVW(ID,FP,""OK"",""detail"")",!
	WRITE "  D PUBMET^MIODEVW(ID,""jobs"",1)",!
	WRITE "  D SETCTL^MIODEVW(ID,""pause"",1)  /  D SETCTL^MIODEVW(ID,""stop"",1)",!
	WRITE "Log panel helpers (if logPanel=1):",!
	WRITE "  D LOGEND^MIODEVW(ID)      ; tail (newest)",!
	WRITE "  D LOGHOME^MIODEVW(ID)     ; oldest window",!
	WRITE "  D LOGUP^MIODEVW(ID,1)     ; up 1",!
	WRITE "  D LOGDOWN^MIODEVW(ID,1)   ; down 1",!
	WRITE "  D LOGPAGEUP^MIODEVW(ID)   ; up one page",!
	WRITE "  D LOGPAGEDN^MIODEVW(ID)   ; down one page",!
	WRITE !
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
	;
	; stopFile: if not absolute/relative path, assume in dir
	IF $GET(CONF("stopFile"))="" SET CONF("stopFile")=$$JOIN(CONF("dir"),".miodevw.stop")
	IF $GET(CONF("stopFile"))'["/" SET CONF("stopFile")=$$JOIN(CONF("dir"),CONF("stopFile"))
	;
	; dashboard knobs
	IF $GET(CONF("ui"))=""       SET CONF("ui")=1
	IF $GET(CONF("alt"))=""      SET CONF("alt")=1
	IF $GET(CONF("rows"))=""     SET CONF("rows")=24
	IF $GET(CONF("cols"))=""     SET CONF("cols")=100
	IF $GET(CONF("lastN"))=""    SET CONF("lastN")=10
	IF $GET(CONF("errN"))=""     SET CONF("errN")=6
	;
	; dev/test UI options
	IF $GET(CONF("dryUI"))=""    SET CONF("dryUI")=0   ; 1=record PUT() ops to ^TMP($J,"MIODEVW","UI")
	IF $GET(CONF("uidiff"))=""   SET CONF("uidiff")=1  ; 1=skip unchanged PUT() writes
	;
	; log panel options
	IF $GET(CONF("logPanel"))="" SET CONF("logPanel")=$SELECT(+$GET(CONF("ui")):1,1:0)
	IF $GET(CONF("paneAHeight"))="" SET CONF("paneAHeight")=0 ; 0=auto
	IF $GET(CONF("logMinH"))=""  SET CONF("logMinH")=6
	IF $GET(CONF("logMax"))=""   SET CONF("logMax")=50
	QUIT
	;
INITSTATE(CONF)
	NEW id SET id=CONF("id")
	; store display conf snapshot used by renderer
	SET ^MIO("DEVW",id,"STATE","conf","rows")=CONF("rows")
	SET ^MIO("DEVW",id,"STATE","conf","cols")=CONF("cols")
	SET ^MIO("DEVW",id,"STATE","conf","lastN")=CONF("lastN")
	SET ^MIO("DEVW",id,"STATE","conf","errN")=CONF("errN")
	SET ^MIO("DEVW",id,"STATE","conf","logMax")=+$GET(CONF("logMax"),50)
	;
	IF $GET(^MIO("DEVW",id,"STATE","startH"))="" SET ^MIO("DEVW",id,"STATE","startH")=$H
	IF $GET(^MIO("DEVW",id,"STATE","status"))="" SET ^MIO("DEVW",id,"STATE","status")="Watching..."
	SET ^MIO("DEVW",id,"STATE","dirty")=1
	QUIT
	;
; -------------------- Core watcher logic --------------------
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
	; returns 1 if processed, 0 if skipped
	NEW bytes,lines,err
	DO FILEINFO(FILE,.bytes,.lines,.err)
	IF err'="" DO LOGX("ERROR","Cannot read "_FILE_": "_err,.CONF) QUIT 0
	;
	; skip unchanged
	NEW prev SET prev=$GET(^MIO("DEVW",CONF("id"),"STATE","seen",FILE))
	IF prev'="",+$PIECE(prev,"|",1)=bytes QUIT 0
	;
	; record + metrics
	DO ADDRECENT(CONF("id"),FILE,"RUN",lines_"L "_bytes_"B")
	DO LOGX("INFO","Processing "_$$BASENAME(FILE)_" ("_lines_" lines, "_bytes_" bytes)",.CONF)
	;
	; optional capture callback output
	NEW oldIO SET oldIO=$IO
	NEW capIO,capErr SET capIO="" SET capErr=""
	DO CAPTUREON(FILE,.CONF,.capIO,.capErr)
	IF capErr'="" DO LOGX("WARN","capture failed: "_capErr,.CONF)
	;
	; callback
	NEW cb SET cb=$GET(CONF("onfile"))
	KILL err
	IF cb'="" DO
	. DO CALLCB(cb,FILE,.CONF,.err)
	. IF err'="" DO
	. . DO LOGX("ERROR","Callback error: "_err,.CONF)
	. . DO ADDERROR(CONF("id"),err)
	. . DO ADDRECENT(CONF("id"),FILE,"ERR",$EXTRACT(err,1,70))
	ELSE  DO
	. DO LOGX("DEBUG","No CONF(""onfile"") set; watcher only.",.CONF)
	;
	; restore IO and close capture
	IF capIO'="" DO  USE oldIO
	. CLOSE capIO
	;
	; mark seen
	SET ^MIO("DEVW",CONF("id"),"STATE","seen",FILE)=bytes_"|"_$$NOW()
	;
	DO METADD(CONF("id"),"processed",1)
	IF $GET(err)="" DO
	. DO METADD(CONF("id"),"ok",1)
	. DO ADDRECENT(CONF("id"),FILE,"OK","")
	ELSE  DO METADD(CONF("id"),"errors",1)
	;
	DO LOGX("OK","Done: "_$$BASENAME(FILE),.CONF)
	QUIT 1
	;
SHOULDSTOP(CONF)
	; stop if ctl stop OR sentinel file exists
	IF $$GETCTL(CONF("id"),"stop") QUIT 1
	NEW sf SET sf=$GET(CONF("stopFile"))
	IF sf="" QUIT 0
	QUIT $$EXISTS(sf)
	;
IDLE(CONF,spinI)
	IF '$GET(CONF("tty")) QUIT
	SET spinI=spinI+1
	NEW s SET s=$EXTRACT("|/-\",((spinI-1)#4)+1)
	NEW msg SET msg="Watching "_$$PATTERN(.CONF)_"  "_s_"  "_$$TS()
	DO STATUS(msg,.CONF)
	QUIT
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
	;
	NEW $ETRAP,$ES,tty
	SET tty=$IO
	SET $ETRAP="SET ERR=$ZSTATUS,$ECODE="""",CAPIO="""" USE tty QUIT"
	;
	OPEN out:(APPEND)
	SET CAPIO=out
	USE CAPIO
	WRITE "----- ",$$TS(),"  FILE=",FILE," -----",!
	USE tty
	QUIT
	;
; -------------------- Logging (classic + dashboard aware) --------------------
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
	; unified logger:
	; - always writes logfile
	; - updates dashboard state
	; - prints terminal lines only when ui=0 (classic)
	NEW id SET id=CONF("id")
	NEW line SET line=$$TS()_" ["_LEVEL_"] "_MSG
	;
	; logfile
	IF $GET(CONF("logIO"))'="" DO
	. NEW old SET old=$IO
	. USE CONF("logIO") WRITE line,!
	. USE old
	;
	; state updates
	IF LEVEL="ERROR" DO ADDERROR(id,MSG)
	IF LEVEL="ERROR" SET ^MIO("DEVW",id,"STATE","status")="ERROR: "_$EXTRACT(MSG,1,70)
	IF LEVEL="INFO"!(LEVEL="OK") SET ^MIO("DEVW",id,"STATE","status")=MSG
	SET ^MIO("DEVW",id,"STATE","dirty")=1
	IF $GET(CONF("ui")) DO ADDLOG(id,LEVEL,MSG)
	;
	; classic terminal
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
STATUS(MSG,CONF)
	IF '$GET(CONF("tty")) QUIT
	NEW io SET io=$GET(CONF("ttyIO"),$IO)
	USE io
	WRITE $CHAR(13),$$CLRLINE()
	WRITE $$C("DIM",.CONF),MSG,$$RESET(.CONF)
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
; -------------------- IPC queue + control --------------------
	;
PUBSTATUS(ID,MSG)   DO PUBEVENT(ID,"status",MSG,"","") QUIT
PUBERR(ID,MSG)      DO PUBEVENT(ID,"error",MSG,"","") QUIT
PUBLOG(ID,LEVEL,MSG) DO PUBEVENT(ID,"log",MSG,"",$$UP(LEVEL)) QUIT
PUBFILE(ID,FP,ST,DETAIL)
	DO PUBEVENT(ID,"file",FP,"status",ST_"|"_DETAIL) QUIT
PUBMET(ID,NAME,DELTA)
	DO PUBEVENT(ID,"metadd","",NAME,DELTA) QUIT
PUBSET(ID,NAME,VALUE)
	DO PUBEVENT(ID,"metset","",NAME,VALUE) QUIT
	;
SETCTL(ID,NAME,VALUE)
	SET ^MIO("DEVW",ID,"CTL",NAME)=VALUE
	QUIT
	;
GETCTL(ID,NAME)
	QUIT +$GET(^MIO("DEVW",ID,"CTL",NAME))
	;
GETCTLS(ID,NAME)
	QUIT $GET(^MIO("DEVW",ID,"CTL",NAME))
	;
PUBEVENT(ID,TYPE,MSG,K,V)
	; Atomic-ish sequence using $INCREMENT (fast, lockless)
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
	. IF type="status" DO  QUIT
	. . SET ^MIO("DEVW",id,"STATE","status")=msg
	. . SET ^MIO("DEVW",id,"STATE","dirty")=1
	. IF type="error" DO  QUIT
	. . DO ADDERROR(id,msg)
	. . DO METADD(id,"errors",1)
	. IF type="file" DO  QUIT
	. . NEW st,detail
	. . SET st=$PIECE(v,"|",1),detail=$PIECE(v,"|",2,999)
	. . DO ADDRECENT(id,msg,st,detail)
	. IF type="metadd" DO  QUIT
	. . DO METADD(id,k,+v)
	. IF type="metset" DO  QUIT
	. . DO METSET(id,k,v)
	. IF type="log" DO  QUIT
	. . DO ADDLOG(id,v,msg)
	. ; prune consumed event to keep global tidy
	. KILL ^MIO("DEVW",id,"Q",lastSeq)
	SET ^MIO("DEVW",id,"STATE","qdone")=lastSeq
	QUIT
	;
; -------------------- Dashboard state helpers --------------------
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
	;
ADDLOG(ID,LEVEL,MSG)
	; Log ring for UI log panel (timestamp^LEVEL^message).;
	NEW max,n,idx,rec
	SET max=+$GET(^MIO("DEVW",ID,"STATE","conf","logMax")) IF max<10 SET max=10
	IF $GET(LEVEL)="" SET LEVEL="INFO"
	SET LEVEL=$$UP(LEVEL)
	SET MSG=$GET(MSG)
	SET n=+$GET(^MIO("DEVW",ID,"STATE","log","n"))
	SET idx=(n#max)+1
	SET ^MIO("DEVW",ID,"STATE","log","n")=n+1
	SET rec=$$TS()_"^"_LEVEL_"^"_$EXTRACT(MSG,1,200)
	SET ^MIO("DEVW",ID,"STATE","log",idx)=rec
	SET ^MIO("DEVW",ID,"STATE","dirty")=1
	QUIT
	;
MATCHLVL(LVL,FILT)
	; FILT: ALL or comma/space/pipe separated levels.;
	NEW f,pat
	SET LVL=$$UP($GET(LVL)),FILT=$$UP($GET(FILT))
	IF FILT=""!(FILT="ALL") QUIT 1
	SET f=$TRANSLATE(FILT,"| "," ,,")
	SET pat=","_f_","
	QUIT (pat[(","_LVL_",")) 
	;
LOGVIEW(ID,FILT,SKIP,COUNT,OUT)
	; OUT(i)=rec (ts^lvl^msg), newest-first window with filter + scroll.;
	KILL OUT
	NEW max,n,seen,i,idx,rec,lvl
	SET max=+$GET(^MIO("DEVW",ID,"STATE","conf","logMax")) IF max<10 SET max=10
	SET n=+$GET(^MIO("DEVW",ID,"STATE","log","n"))
	SET seen=0,i=0
	FOR  QUIT:(i>=COUNT)!(seen>=max)  DO
	. IF n-seen'>0 QUIT
	. SET idx=((n-seen-1)#max)+1
	. SET rec=$GET(^MIO("DEVW",ID,"STATE","log",idx))
	. SET seen=seen+1
	. IF rec="" QUIT
	. SET lvl=$PIECE(rec,"^",2)
	. IF '$$MATCHLVL(lvl,FILT) QUIT
	. IF +SKIP>0 SET SKIP=SKIP-1 QUIT
	. SET i=i+1
	. SET OUT(i)=rec
	QUIT
	;
	;
	; ----- Log scroll helpers (Next ROI) -----
	; These are safe to call from other processes. They clamp scroll based on:
	;   - current filter (CTL "logFilter", default ALL)
	;   - visible log lines (STATE ui log lines; falls back to 10)
	;
LOGCOUNT(ID,FILT)
	; Count matching log records in the ring (up to logMax).;
	NEW max,n,seen,idx,rec,lvl,cnt
	SET max=+$GET(^MIO("DEVW",ID,"STATE","conf","logMax")) IF max<10 SET max=10
	SET n=+$GET(^MIO("DEVW",ID,"STATE","log","n"))
	SET cnt=0,seen=0
	FOR  QUIT:(seen>=max)  DO  QUIT:n-seen'>0
	. SET idx=((n-seen-1)#max)+1
	. SET rec=$GET(^MIO("DEVW",ID,"STATE","log",idx))
	. SET seen=seen+1
	. IF rec="" QUIT
	. SET lvl=$PIECE(rec,"^",2)
	. IF $$MATCHLVL(lvl,FILT) SET cnt=cnt+1
	QUIT cnt
	;
LOGMAXSCROLL(ID,FILT,LINES)
	; Maximum valid scroll offset for current ring/filter/viewport.;
	NEW lines,cnt,maxS
	SET lines=+$GET(LINES)
	IF lines<=0 SET lines=+$GET(^MIO("DEVW",ID,"STATE","ui","log","lines"))
	IF lines<=0 SET lines=10
	SET cnt=$$LOGCOUNT(ID,FILT)
	SET maxS=cnt-lines
	IF maxS<0 SET maxS=0
	QUIT maxS
	;
LOGEND(ID)
	; Jump to tail (newest).;
	DO SETCTL(ID,"logScroll",0)
	QUIT 0
	;
LOGHOME(ID)
	; Jump to oldest window (top).;
	NEW filt SET filt=$$UP($$GETCTLS(ID,"logFilter")) IF filt="" SET filt="ALL"
	NEW maxS SET maxS=$$LOGMAXSCROLL(ID,filt,0)
	DO SETCTL(ID,"logScroll",maxS)
	QUIT maxS
	;
LOGUP(ID,STEP)
	; Scroll up (older) by STEP lines (default 1), clamped. Returns new scroll. ;
	NEW s,cur,filt,maxS,new
	SET s=+$GET(STEP) IF s<=0 SET s=1
	SET cur=+$GET(^MIO("DEVW",ID,"CTL","logScroll"))
	SET filt=$$UP($$GETCTLS(ID,"logFilter")) IF filt="" SET filt="ALL"
	SET maxS=$$LOGMAXSCROLL(ID,filt,0)
	SET new=cur+s IF new>maxS SET new=maxS
	DO SETCTL(ID,"logScroll",new)
	QUIT new
	;
LOGDOWN(ID,STEP)
	; Scroll down (newer) by STEP lines (default 1), clamped. Returns new scroll. ;
	NEW s,cur,new
	SET s=+$GET(STEP) IF s<=0 SET s=1
	SET cur=+$GET(^MIO("DEVW",ID,"CTL","logScroll"))
	SET new=cur-s IF new<0 SET new=0
	DO SETCTL(ID,"logScroll",new)
	QUIT new
	;
LOGPAGEUP(ID)
	; Page up by (lines-1) (or 1 if unknown).;
	NEW lines SET lines=+$GET(^MIO("DEVW",ID,"STATE","ui","log","lines"))
	IF lines<=1 SET lines=2
	QUIT $$LOGUP(ID,lines-1)
	;
LOGPAGEDN(ID)
	; Page down by (lines-1) (or 1 if unknown).;
	NEW lines SET lines=+$GET(^MIO("DEVW",ID,"STATE","ui","log","lines"))
	IF lines<=1 SET lines=2
	QUIT $$LOGDOWN(ID,lines-1)
	;
	;
	;
; -------------------- Minimalist Dashboard UI (widget-based + log panel) --------------------
;
; Next ROI:
;   - Scrollable full-height Log panel (filtered by level)
;   - Controlled from other processes via:
;       SETCTL(ID,"logScroll",N)   ; 0=tail, 1.. scroll up (skip newest matching lines)
;       SETCTL(ID,"logFilter","ERROR") or "ERROR,WARN" or "ALL"
;   - Row-level diff flushing (uidiff) and dryUI recording for tests
;
; Widget Registry
;   CONF("ui","W",priority,name)=DRAW_"|"_PAINT
;   DRAW is called during UISTART (and on resize redraw)
;   PAINT is called every UIRENDER
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
	DO REGW(.CONF,"log",60,"","WLOG^MIODEVW")
	QUIT
	;
UIINIT(CONF)
	; Prepare temp UI state for PUT() (dryUI/uidiff/cache).;
	IF '$GET(CONF("ui")) QUIT
	IF '$DATA(CONF("ui","W")) DO WREGDEFAULT(.CONF)
	IF '$DATA(^TMP($J,"MIODEVW","UI","init")) DO
	. KILL ^TMP($J,"MIODEVW","UI")
	. SET ^TMP($J,"MIODEVW","UI","init")=1
	; Always refresh dynamic knobs
	SET ^TMP($J,"MIODEVW","UI","dry")=+$GET(CONF("dryUI"))
	SET ^TMP($J,"MIODEVW","UI","tty")=+$GET(CONF("tty"))
	SET ^TMP($J,"MIODEVW","UI","ttyIO")=$GET(CONF("ttyIO"),$IO)
	SET ^TMP($J,"MIODEVW","UI","uidiff")=+$GET(CONF("uidiff"))
	SET ^TMP($J,"MIODEVW","UI","cols")=+$GET(CONF("cols"),80)
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
	; Compute minimalist layout + optional log panel at bottom.;
	NEW rows,cols,errW,leftW,splitC,pane,maxPane,logMin
	SET rows=+$GET(CONF("rows"),24),cols=+$GET(CONF("cols"),100)
	SET errW=32 IF cols<80 SET errW=26
	SET leftW=cols-errW-3 IF leftW<30 SET leftW=30
	SET splitC=leftW+2
	SET LAY("rows")=rows,LAY("cols")=cols
	SET LAY("leftW")=leftW,LAY("errW")=errW,LAY("splitC")=splitC
	SET LAY("hdr1")=1,LAY("hdr2")=2
	SET LAY("div1")=3,LAY("met")=4,LAY("div2")=5
	SET LAY("colhdr")=6
	SET LAY("listTop")=7
	SET LAY("divB")=rows-1,LAY("help")=rows
	SET LAY("logPanel")=0
	SET LAY("listBottom")=rows-2
	IF '+$GET(CONF("logPanel")) QUIT
	SET logMin=+$GET(CONF("logMinH"),6) IF logMin<4 SET logMin=4
	SET pane=+$GET(CONF("paneAHeight"))
	IF pane<=0 SET pane=$SELECT(rows>=30:10,rows>=26:8,rows>=24:6,1:4)
	SET maxPane=rows-logMin-10
	IF maxPane<3 QUIT  ; too small: disable log panel
	IF pane>maxPane SET pane=maxPane
	IF pane<3 SET pane=3
	SET LAY("listBottom")=LAY("listTop")+pane-1
	SET LAY("div3")=LAY("listBottom")+1
	SET LAY("logHdr")=LAY("div3")+1
	SET LAY("logTop")=LAY("logHdr")+1
	SET LAY("logBottom")=rows-2
	SET LAY("logLines")=LAY("logBottom")-LAY("logTop")+1
	SET LAY("logPanel")=1
	QUIT
	;
; ----- UI lifecycle -----
UISTART(CONF)
	IF '$GET(CONF("ui")) QUIT
	DO UIINIT(.CONF)
	KILL ^TMP($J,"MIODEVW","UI","cache") ; reset diff-cache for a fresh screen
	NEW id SET id=$GET(CONF("id"),"default")
	NEW LAY,CTX
	DO UILAYOUT(.CONF,.LAY)
	SET CTX("phase")="draw",CTX("dirty")=1
	IF $GET(CONF("tty")) DO
	. NEW io SET io=$GET(CONF("ttyIO"),$IO)
	. NEW old SET old=$IO
	. USE io
	. IF $GET(CONF("alt")) WRITE $$ALT(1)
	. WRITE $$HIDECUR(),$$CLR()
	. DO WDRAW(.CONF,.LAY,.CTX)
	. USE old
	ELSE  DO WDRAW(.CONF,.LAY,.CTX)
	SET ^MIO("DEVW",id,"STATE","ui","sig")=LAY("rows")_"x"_LAY("cols")
	SET ^MIO("DEVW",id,"STATE","dirty")=1
	QUIT
	;
UIEND(CONF)
	IF '$GET(CONF("tty")) QUIT
	NEW io SET io=$GET(CONF("ttyIO"),$IO)
	USE io
	WRITE $$SHOWCUR()
	IF $GET(CONF("alt")) WRITE $$ALT(0)
	QUIT
	;
UIDRAWSTATIC(CONF)
	; Backward compatible shim (uses widgets).;
	IF '$GET(CONF("ui")) QUIT
	DO UIINIT(.CONF)
	NEW LAY,CTX
	DO UILAYOUT(.CONF,.LAY)
	SET CTX("phase")="draw",CTX("dirty")=1
	DO WDRAW(.CONF,.LAY,.CTX)
	QUIT
	;
UIRENDER(CONF,spinI,lastRateH,lastRateP)
	IF '$GET(CONF("ui")) QUIT
	DO UIINIT(.CONF)
	NEW id SET id=$GET(CONF("id"),"default")
	NEW LAY,CTX
	DO UILAYOUT(.CONF,.LAY)
	; redraw chrome if size changed
	NEW sig SET sig=LAY("rows")_"x"_LAY("cols")
	IF $GET(^MIO("DEVW",id,"STATE","ui","sig"))'=sig DO
	. KILL ^TMP($J,"MIODEVW","UI","cache")
	. NEW oldIO SET oldIO=$IO
	. IF $GET(CONF("tty")) USE $GET(CONF("ttyIO"),$IO)
	. SET CTX("phase")="draw",CTX("dirty")=1
	. DO WDRAW(.CONF,.LAY,.CTX)
	. USE oldIO
	. SET ^MIO("DEVW",id,"STATE","ui","sig")=sig
	. SET ^MIO("DEVW",id,"STATE","dirty")=1
	NEW dirty SET dirty=+$GET(^MIO("DEVW",id,"STATE","dirty"))
	SET ^MIO("DEVW",id,"STATE","dirty")=0
	; rate calc
	NEW nowH SET nowH=$H
	NEW p SET p=+$GET(^MIO("DEVW",id,"STATE","metrics","processed"))
	NEW dt SET dt=$$HSECS(nowH,lastRateH)
	NEW rate SET rate=0
	IF dt>0 SET rate=(p-lastRateP)/dt
	SET lastRateH=nowH,lastRateP=p
	SET CTX("phase")="paint",CTX("dirty")=dirty
	SET CTX("spin")=$EXTRACT("|/-",((spinI)#4)+1)
	SET CTX("processed")=p,CTX("rate")=rate
	NEW oldIO SET oldIO=$IO
	IF $GET(CONF("tty")) USE $GET(CONF("ttyIO"),$IO)
	DO WPAINT(.CONF,.LAY,.CTX)
	USE oldIO
	QUIT
	;
; ----- Default widgets -----
WCHROME(CONF,LAY,CTX)
	NEW cols,splitC,id,bottom
	SET cols=LAY("cols"),splitC=LAY("splitC")
	SET bottom=LAY("listBottom")
	SET id=$GET(CONF("id"),"default")
	DO PUT(LAY("hdr1"),1,$$C("HEAD",.CONF)_"MIODEVW"_$$RESET(.CONF)_" "_$$C("DIM",.CONF)_"id="_id_$$RESET(.CONF))
	DO PUT(LAY("hdr2"),1,$$C("DIM",.CONF)_"dir="_CONF("dir")_"  pattern="_CONF("pattern")_"  interval="_CONF("interval")_"s"_$$RESET(.CONF))
	DO HLINE(LAY("div1"),1,cols)
	DO PUT(LAY("met"),1,"")
	DO HLINE(LAY("div2"),1,cols)
	DO PUT(LAY("colhdr"),1,$$C("HEAD",.CONF)_"Recent"_$$RESET(.CONF))
	DO PUT(LAY("colhdr"),splitC+1,$$C("HEAD",.CONF)_"Errors"_$$RESET(.CONF))
	NEW r FOR r=LAY("colhdr"):1:bottom DO PUT(r,splitC,"|")
	IF +$GET(LAY("logPanel")) DO
	. DO HLINE(LAY("div3"),1,cols)
	. DO PUT(LAY("logHdr"),1,$$C("HEAD",.CONF)_"Log"_$$RESET(.CONF))
	DO HLINE(LAY("divB"),1,cols)
	DO PUT(LAY("help"),1,$$C("DIM",.CONF)_"IPC: PUBSTATUS/PUBERR/PUBFILE/PUBLOG  |  CTL: SETCTL(pause/stop/logScroll/logFilter)"_$$RESET(.CONF))
	QUIT
	;
WHEADER(CONF,LAY,CTX)
	NEW id SET id=$GET(CONF("id"),"default")
	NEW cols SET cols=LAY("cols")
	NEW spin SET spin=$GET(CTX("spin"),"|")
	NEW status SET status=$GET(^MIO("DEVW",id,"STATE","status"),"Watching...")
	IF $L(status)>(cols-22) SET status=$E(status,1,(cols-22))
	DO PUT(LAY("hdr1"),20,$$C("DIM",.CONF)_"["_spin_"] "_$$RESET(.CONF)_status)
	NEW qnext SET qnext=+$GET(^MIO("DEVW",id,"Q","next"))
	NEW qdone SET qdone=+$GET(^MIO("DEVW",id,"STATE","qdone"))
	NEW qlag SET qlag=qnext-qdone IF qlag<0 SET qlag=0
	NEW ls SET ls=+$GET(^MIO("DEVW",id,"CTL","logScroll"))
	NEW lf SET lf=$$UP($$GETCTLS(id,"logFilter")) IF lf="" SET lf="ALL"
	NEW ctl SET ctl="pause="_$$YESNO($$GETCTL(id,"pause"))_" stop="_$$YESNO($$GETCTL(id,"stop"))_" qlag="_qlag
	IF +$GET(LAY("logPanel")) SET ctl=ctl_" logScroll="_ls_" logFilter="_lf
	NEW cpos SET cpos=cols-$L(ctl)+1 IF cpos<1 SET cpos=1
	DO PUT(LAY("hdr2"),cpos,$$C("DIM",.CONF)_ctl_$$RESET(.CONF))
	QUIT
	;
WMETRICS(CONF,LAY,CTX)
	NEW id SET id=$GET(CONF("id"),"default")
	NEW cols SET cols=LAY("cols")
	NEW p SET p=+$GET(CTX("processed"))
	NEW rate SET rate=+$GET(CTX("rate"))
	NEW scans,ok,errs,uptime
	SET scans=+$GET(^MIO("DEVW",id,"STATE","metrics","scans"))
	SET ok=+$GET(^MIO("DEVW",id,"STATE","metrics","ok"))
	SET errs=+$GET(^MIO("DEVW",id,"STATE","metrics","errors"))
	SET uptime=$$UPTIME($GET(^MIO("DEVW",id,"STATE","startH"),$H),$H)
	NEW mline SET mline="uptime "_uptime_"  scans "_scans_"  processed "_p_"  ok "_ok_"  errors "_errs_"  rate "_$$FMT(rate,2)_"/s"
	IF $L(mline)>cols SET mline=$E(mline,1,cols)
	DO PUT(LAY("met"),1,mline)
	QUIT
	;
WRECENT(CONF,LAY,CTX)
	IF '$GET(CTX("dirty")) QUIT
	NEW id SET id=$GET(CONF("id"),"default")
	NEW top SET top=LAY("listTop"),bottom=LAY("listBottom")
	NEW width SET width=LAY("leftW")
	NEW max SET max=+$GET(^MIO("DEVW",id,"STATE","conf","lastN"),10)
	NEW n SET n=+$GET(^MIO("DEVW",id,"STATE","recent","n"))
	NEW i,row,idx,rec,ts,st,name,detail,line,out
	FOR i=1:1:(bottom-top+1) DO
	. SET row=top+i-1
	. IF i>max DO PUT(row,1,"") QUIT
	. SET idx=((n-i)#max)+1
	. SET rec=$GET(^MIO("DEVW",id,"STATE","recent",idx))
	. IF rec="" DO PUT(row,1,"") QUIT
	. SET ts=$P(rec,"^",1),st=$P(rec,"^",2),name=$P(rec,"^",3),detail=$P(rec,"^",4,99)
	. SET line=ts_" ["_st_"] "_name
	. IF detail'="" SET line=line_" - "_detail
	. IF $L(line)>width SET line=$E(line,1,width)
	. SET out=$$CPFX(st,.CONF)_line_$$RESET(.CONF)
	. DO PUT(row,1,out)
	QUIT
	;
WERRORS(CONF,LAY,CTX)
	IF '$GET(CTX("dirty")) QUIT
	NEW id SET id=$GET(CONF("id"),"default")
	NEW top SET top=LAY("listTop"),bottom=LAY("listBottom")
	NEW width SET width=LAY("errW")
	NEW left SET left=LAY("splitC")+1
	NEW max SET max=+$GET(^MIO("DEVW",id,"STATE","conf","errN"),6)
	NEW n SET n=+$GET(^MIO("DEVW",id,"STATE","errors","n"))
	NEW i,row,idx,rec,line
	FOR i=1:1:(bottom-top+1) DO
	. SET row=top+i-1
	. IF i>max DO PUT(row,left,"") QUIT
	. SET idx=((n-i)#max)+1
	. SET rec=$GET(^MIO("DEVW",id,"STATE","errors",idx))
	. IF rec="" DO PUT(row,left,"") QUIT
	. SET line=rec IF $L(line)>width SET line=$E(line,1,width)
	. DO PUT(row,left,$$C("ERROR",.CONF)_line_$$RESET(.CONF))
	QUIT
	;
WLOG(CONF,LAY,CTX)
	IF '+$GET(LAY("logPanel")) QUIT
	NEW id SET id=$GET(CONF("id"),"default")
	NEW cols SET cols=LAY("cols")
	NEW hdr SET hdr=LAY("logHdr"),top=LAY("logTop"),bot=LAY("logBottom")
	NEW lines SET lines=(bot-top+1) IF lines<1 QUIT
	NEW filt SET filt=$$UP($$GETCTLS(id,"logFilter")) IF filt="" SET filt="ALL"
	NEW scroll SET scroll=+$GET(^MIO("DEVW",id,"CTL","logScroll"))
	; remember viewport lines for scroll helpers
	SET ^MIO("DEVW",id,"STATE","ui","log","lines")=lines
	NEW maxS SET maxS=$$LOGMAXSCROLL(id,filt,lines)
	IF scroll>maxS SET scroll=maxS,^MIO("DEVW",id,"CTL","logScroll")=scroll
	NEW dirty SET dirty=+$GET(CTX("dirty"))
	IF scroll'=+$GET(^MIO("DEVW",id,"STATE","ui","log","scroll")) SET dirty=1,^MIO("DEVW",id,"STATE","ui","log","scroll")=scroll
	IF filt'=$GET(^MIO("DEVW",id,"STATE","ui","log","filter")) SET dirty=1,^MIO("DEVW",id,"STATE","ui","log","filter")=filt
	IF 'dirty QUIT
	NEW h SET h=$$C("HEAD",.CONF)_"Log"_$$RESET(.CONF)_" "_$$C("DIM",.CONF)_"filter="_filt_" scroll="_scroll_"/"_maxS_" (0=tail)"_$$RESET(.CONF)
	IF $L(h)>cols SET h=$E(h,1,cols)
	DO PUT(hdr,1,h)
	NEW view,i,row,rec,ts,lvl,msg,line,out
	DO LOGVIEW(id,filt,scroll,lines,.view)
	FOR i=1:1:lines DO
	. SET row=top+i-1
	. SET rec=$GET(view(i))
	. IF rec="" DO PUT(row,1,"") QUIT
	. SET ts=$P(rec,"^",1),lvl=$P(rec,"^",2),msg=$P(rec,"^",3,99)
	. SET line=ts_" ["_lvl_"] "_msg
	. IF $L(line)>cols SET line=$E(line,1,cols)
	. SET out=$$CPFX(lvl,.CONF)_line_$$RESET(.CONF)
	. DO PUT(row,1,out)
	QUIT
	;
CPFX(ST,CONF)
	IF '$GET(CONF("color")) QUIT ""
	SET ST=$$UP($GET(ST))
	IF ST="ERROR" QUIT $$C("ERROR",.CONF)
	IF ST="WARN"  QUIT $$C("WARN",.CONF)
	IF ST="OK"    QUIT $$C("OK",.CONF)
	IF ST="INFO"  QUIT $$C("INFO",.CONF)
	IF ST="DEBUG" QUIT $$C("DEBUG",.CONF)
	IF ST="RUN"   QUIT $$C("INFO",.CONF)
	IF ST="ERR"   QUIT $$C("ERROR",.CONF)
	QUIT $$C("DIM",.CONF)
	;
; ----- Drawing primitives (supports dryUI + uidiff) -----
PUT(R,C,S)
	NEW dry SET dry=+$GET(^TMP($J,"MIODEVW","UI","dry"))
	NEW tty SET tty=+$GET(^TMP($J,"MIODEVW","UI","tty"))
	NEW uidiff SET uidiff=+$GET(^TMP($J,"MIODEVW","UI","uidiff"))
	IF uidiff,$GET(^TMP($J,"MIODEVW","UI","cache",R,C))=S QUIT
	IF uidiff SET ^TMP($J,"MIODEVW","UI","cache",R,C)=S
	IF dry DO  QUIT
	. NEW n SET n=$INCREMENT(^TMP($J,"MIODEVW","UI","ops"))
	. SET ^TMP($J,"MIODEVW","UI","ops",n)=R_$C(9)_C_$C(9)_S
	IF 'tty QUIT
	WRITE $$GOTO(R,C),S,$$CLREOL()
	QUIT
	;
HLINE(R,C,L)
	NEW i,s SET s=""
	FOR i=1:1:L SET s=s_"-"
	DO PUT(R,C,s)
	QUIT
	;
; -------------------- File helpers --------------------
	; --------------------
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
	SET $ETRAP="SET ok=0,$ECODE="""" QUIT 0"
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
UP(X)
	QUIT $TRANSLATE($GET(X),"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
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
	NEW p SET p=10**D
	NEW n SET n=(X*p)+0.5\1
	NEW a SET a=n\p
	NEW b SET b=n#p
	IF D=0 QUIT sign_a
	NEW bs SET bs=b
	FOR  QUIT:$LENGTH(bs)'<D  SET bs="0"_bs
	QUIT sign_a_"."_bs
	;
YESNO(V) QUIT $SELECT(+V:"YES",1:"NO")
	;
FIT(S,W)
	NEW x SET x=S
	IF $LENGTH(x)>W QUIT $EXTRACT(x,1,W)
	QUIT x_$$REPL(" ",W-$LENGTH(x))
	;
REPL(CH,N)
	NEW i,s SET s=""
	FOR i=1:1:N SET s=s_CH
	QUIT s
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