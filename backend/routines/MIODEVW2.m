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
START
	NEW CONF,C,base
	KILL C
	MERGE CONF=^MIO("CONF")
	SET C("id")="mio"
	; base directory (used for log/stop file paths)
	SET base=$GET(CONF("server","templateDir"))
	IF base="" SET base="templates"
	; multi-dir scan list (DIRLIST() will prefer this)
	SET C("dir",1)=base
	SET C("dir",2)=base_"/partials"
	SET C("dir",3)=base_"/pages"
	SET C("dir",4)=base_"/layouts"
	; keep C("dir") as the base dir for JOIN()/logFile/stopFile
	SET C("dir")=base
	SET C("pattern")="*.html"
	SET C("interval")=1
	SET C("logFile")=$$JOIN(C("dir"),"mio-devwatch.log")
	SET C("stopFile")=$$JOIN(C("dir"),".miodevw.stop")
	SET C("tty")=1
	; smooth, non-jumpy UI
	SET C("smoothUI")=1   ; prevent scan increments from forcing redraw
	SET C("uiTick")=1     ; repaint at most once/sec when idle
	SET C("animate")=1
	SET C("uidiff")=1
	; styling 
	SET C("color")=1
	SET C("colorMode")=2  ; 1=minimal (recommended)
	; dashboard sizing
	SET C("ui")=1
	SET C("compactUI")=0
	SET C("alt")=0
	SET C("rows")=24
	SET C("cols")=100
	SET C("lastN")=10
	SET C("errN")=6
	; log panel
	SET C("logPanel")=1
	SET C("logMinH")=2
	SET C("logMaxH")=6   ; (if you added the new clamp in UILAYOUT)
	SET C("logMax")=200   ; bigger ring since you have more screen
	SET C("dryUI")=0
	SET C("captureDir")=""
	SET C("onfile")="PROCESS^MIODEVW"
	DO BEGIN^MIODEVW(.C)
	QUIT
PROCESS(FP,CONF,ERR)
	; sample hook
	SET $ETRAP="SET $ECODE="""" DO ADDERROR^MIODEVW(CONF(""id""),""UI widget error: ""_$ZSTATUS) QUIT"
	K CNF,TOK,ERR,OPT 
	S OPT="" M CNF=^MIO("CONF")
	D WATCH^MIOTPL(FP,.CNF,.TOK,.ERR,.OPT)
	I $D(ERR) D ADDERROR(CONF("id"),"MIOTPL error in: "_FP_"-"_$G(ERR("msg")))
	;D PUBSTATUS^MIODEVW(CONF("id"),$C(10)_"***** "_FP_" *****"_$C(10))
	DO PUBFILE($GET(CONF("id"),"MIOTPL"),FP,"OK","processed")
	;	
	QUIT
	;
; -------------------- Runner --------------------
	;
BEGIN(CONF)
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
	IF $GET(CONF("colorMode"))="" SET CONF("colorMode")=1  ; 1=minimal, 2=full
	IF $GET(CONF("logFile"))=""   SET CONF("logFile")=$$JOIN(CONF("dir"),"miodevw.log")
	IF $GET(CONF("stopFile"))=""  SET CONF("stopFile")=$$JOIN(CONF("dir"),".miodevw.stop")
	IF $GET(CONF("stopFile"))'="",CONF("stopFile")'["/" SET CONF("stopFile")=$$JOIN(CONF("dir"),CONF("stopFile"))
	;
	IF $GET(CONF("ui"))=""        SET CONF("ui")=1
	IF $GET(CONF("compactUI"))="" SET CONF("compactUI")=1  ; compact by default
	IF $GET(CONF("animate"))=""   SET CONF("animate")=0    ; low motion by default
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
	;
	IF $GET(CONF("logo"))="" SET CONF("logo")=1
	IF $GET(CONF("logoText"))="" SET CONF("logoText")="MUMPS.IO"
	IF $GET(CONF("logoDelay"))="" SET CONF("logoDelay")=0.2  ; seconds (0 to disable pause)
	QUIT
LOGO(CONF)
	IF '$GET(CONF("tty")) QUIT
	NEW io,cols,txt,delay
	SET io=$GET(CONF("ttyIO"),$IO)
	SET cols=+$GET(CONF("cols"),80)
	SET txt=$GET(CONF("logoText"),"MUMPS.IO")
	SET delay=+$GET(CONF("logoDelay"),0)
	;
	USE io
	; small, clean, no heavy color
	WRITE $$CLR()
	NEW c SET c=((cols-$L(txt))\2)+1 IF c<1 SET c=1
	WRITE $$GOTO(2,c),$$C("HEAD",.CONF),txt,$$RESET(.CONF)
	WRITE $$GOTO(3,c),"dev watcher"
	;
	IF delay>0 HANG delay
	WRITE $$CLR()
	QUIT
INITSTATE(CONF)
	NEW id SET id=CONF("id")
	SET ^MIO("DEVW",id,"STATE","conf","rows")=CONF("rows")
	SET ^MIO("DEVW",id,"STATE","conf","cols")=CONF("cols")
	SET ^MIO("DEVW",id,"STATE","conf","lastN")=CONF("lastN")
	SET ^MIO("DEVW",id,"STATE","conf","errN")=CONF("errN")
	SET ^MIO("DEVW",id,"STATE","conf","logMax")=CONF("logMax")
	SET ^MIO("DEVW",id,"STATE","ui","smooth")=+$GET(CONF("smoothUI"))
	SET ^MIO("DEVW",id,"STATE","ui","tick")=+$GET(CONF("uiTick"),1)
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
	KILL ^TMP($J,"MIODEVW","UI")
	SET ^TMP($J,"MIODEVW","UI","id")=$GET(CONF("id"),"default")
	SET ^TMP($J,"MIODEVW","UI","tty")=+$GET(CONF("tty"))
	SET ^TMP($J,"MIODEVW","UI","dry")=+$GET(CONF("dryUI"))
	SET ^TMP($J,"MIODEVW","UI","uidiff")=+$GET(CONF("uidiff"))
	SET ^TMP($J,"MIODEVW","UI","ttyIO")=$GET(CONF("ttyIO"),$IO)
	SET ^TMP($J,"MIODEVW","UI","cols")=+$GET(CONF("cols"),100)
	QUIT
VISLEN(S)
	; visible length ignoring simple ANSI SGR sequences ESC[...m
	NEW i,ch,esc,vis SET (esc,vis)=0
	FOR i=1:1:$L($G(S)) DO
	. SET ch=$E(S,i)
	. IF esc DO  QUIT
	. . IF ch="m" SET esc=0
	. IF ch=$C(27) SET esc=1 QUIT
	. SET vis=vis+1
	QUIT vis
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
	;
	; column widths (slightly tighter errors column in compact mode)
	SET errW=32 IF cols<80 SET errW=26
	IF +$GET(CONF("compactUI")) SET errW=28 IF cols<80 SET errW=24
	;
	SET leftW=cols-errW-3 IF leftW<30 SET leftW=30
	SET splitC=leftW+2
	;
	SET LAY("rows")=rows,LAY("cols")=cols
	SET LAY("leftW")=leftW,LAY("errW")=errW,LAY("splitC")=splitC
	;
	; compact layout: 2 lines only (hdr1=status/brand, met=telemetry), then headers
	IF +$GET(CONF("compactUI")) DO
	. SET LAY("hdr1")=1
	. SET LAY("hdr2")=0        ; not used (we blank it in WHEADER)
	. SET LAY("met")=2         ; telemetry bar
	. SET LAY("div1")=0,LAY("div2")=0
	. SET LAY("colhdr")=3
	ELSE  DO
	. SET LAY("hdr1")=1,LAY("hdr2")=2,LAY("div1")=3,LAY("met")=4,LAY("div2")=5
	. SET LAY("colhdr")=6
	;
	; bottom chrome rows
	SET LAY("divB")=rows-1,LAY("help")=rows
	;
	; Determine log panel placement (optional)
	IF +$GET(CONF("logPanel")) DO
	. NEW minH,maxH,logH,divB,logTop
	. SET minH=+$GET(CONF("logMinH"),5)
	. IF minH<3 SET minH=3
	. SET maxH=+$GET(CONF("logMaxH"),8) ; NEW optional knob (safe default)
	. IF maxH<minH SET maxH=minH
	. ; choose a log height that preserves list space
	. ; goal: at least 6 list rows if possible
	. SET divB=LAY("divB")
	. SET logH=minH
	. IF rows>18 SET logH=minH+1
	. IF rows>22 SET logH=minH+2
	. IF logH>maxH SET logH=maxH
	. ; place log above bottom divider
	. SET logTop=divB-logH
	. ; never overlap column headers area
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
	;
	QUIT
ENUMGLOBS(ROOT,LIST) ;
	DO ENUM1(ROOT,"/*.html",.LIST)
	DO ENUM1(ROOT,"/pages/*.html",.LIST)
	DO ENUM1(ROOT,"/layouts/*.html",.LIST)
	DO ENUM1(ROOT,"/partials/*.html",.LIST)
	QUIT
ENUM1(RT,PAT,LIST) ;
	NEW F,T SET F=$ZSEARCH(RT_PAT)
	FOR  QUIT:F=""  DO
	. SET T=RT_$P(F,RT,2,999)
	. SET LIST(T)=1
	. SET F=$ZSEARCH(RT_PAT)
	QUIT
; -------------------- Core watcher --------------------
SCAN(CONF,LIST)
	KILL LIST
	NEW ROOT
	S ROOT="templates"
	D ENUMGLOBS(ROOT,.LIST)
	Q
XXX	
	SET di=""
	N DD,V M ^D=LIST
	FOR  SET di=$ORDER(D(di)) QUIT:di=""  DO
	. SET dir=D(di)
	. SET pat=$$JOIN(dir,$GET(CONF("pattern"),"*.html"))
	. SET f=$ZSEARCH(pat)
	. FOR  QUIT:f=""  DO  SET f=$ZSEARCH("")
	. . S DD=$ZPARSE(f,"DIRECTORY")
	. . S V=dir_"/"_$P(f,DD,2,9999)
	. . I V]"",V[".html" SET LIST(V)=""
	QUIT
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
	;
	; Smooth mode: scans change constantly; don’t repaint for that
	IF $GET(^MIO("DEVW",ID,"STATE","ui","smooth")),NAME="scans" QUIT
	;
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
LOGFILT(ID) QUIT $$LOGFILTER(ID)
	;
LOGMAXSCROLL(ID,FILT,LINES)
	; max scroll value given current filter and viewport size
	; IMPORTANT: if match<=LINES, still allow shift up to match-1
	SET LINES=+$GET(LINES)
	IF LINES<1 QUIT 0
	NEW max,n,cap,i,idx,rec,lvl,match,ms
	SET max=+$GET(^MIO("DEVW",ID,"STATE","conf","logMax"),100)
	SET n=+$GET(^MIO("DEVW",ID,"STATE","log","n"))
	SET cap=$SELECT(n<max:n,1:max)
	SET match=0
	FOR i=0:1:(cap-1) DO
	. SET idx=((n-i-1)#max)+1
	. SET rec=$GET(^MIO("DEVW",ID,"STATE","log",idx))
	. IF rec="" QUIT
	. SET lvl=$PIECE(rec,"^",2)
	. IF $$LOGMATCH(FILT,lvl) SET match=match+1
	;
	IF match'>LINES SET ms=match-1
	ELSE  SET ms=match-LINES
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
	IF '$GET(CONF("dryUI")),$GET(CONF("logo")),'$GET(^MIO("DEVW",CONF("id"),"STATE","ui","logoShown")) DO
	. SET ^MIO("DEVW",CONF("id"),"STATE","ui","logoShown")=1
	. DO LOGO(.CONF)
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
	NEW animate SET animate=+$GET(CONF("animate"))
	NEW smooth SET smooth=+$GET(^MIO("DEVW",id,"STATE","ui","smooth"))
	;
	; if not dirty and not animating:
	IF 'dirty,'animate DO  QUIT:'$$NEEDTICK(id)
	. ; allow a very low-frequency repaint (tick) to refresh uptime/rate
	;
	; if we’re here, we will paint
	SET ^MIO("DEVW",id,"STATE","dirty")=0
	;
	NEW LAY,CTX
	DO UILAYOUT(.CONF,.LAY)
	;
	; compute rate only when repainting
	NEW nowH SET nowH=$H
	NEW p SET p=+$GET(^MIO("DEVW",id,"STATE","metrics","processed"))
	NEW dt SET dt=$$HSECS(nowH,lastRateH)
	NEW rate SET rate=0
	IF dt>0 SET rate=(p-lastRateP)/dt
	SET lastRateH=nowH,lastRateP=p
	;
	; much less motion: spinner only if animate=1
	IF animate SET CTX("spin")=$EXTRACT("|/-\",((+$GET(spinI))#4)+1)
	ELSE  SET CTX("spin")=""
	;
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
	; static scaffolding (compact + dense)
	NEW rows,cols,splitC,r,pat,ctl
	SET rows=LAY("rows"),cols=LAY("cols"),splitC=LAY("splitC")
	;
	; watch summary: supports multi-dir via $$PATSTR(.CONF) if present
	SET pat=$SELECT($TEXT(PATSTR^MIODEVW)'="":$$PATSTR(.CONF),1:CONF("dir")_"/"_CONF("pattern"))
	;
	; line 1: brand + id (minimal color)
	DO PUT(LAY("hdr1"),1,$$C("HEAD",.CONF)_"MUMPS.IO"_$$RESET(.CONF)_"  MIODEVW  id="_$GET(CONF("id")))
	;
	; line 2: one dense watch line (no extra labels)
	; ex: "watch templates/*.html (+2)  int 0.1s"
	DO PUT(LAY("hdr2"),1,"watch "_pat_"  int "_$GET(CONF("interval"),1)_"s")
	;
	; separators only if non-compact layout uses them
	IF +$GET(LAY("div1"))>0 DO HLINE(LAY("div1"),1,cols)
	IF +$GET(LAY("div2"))>0 DO HLINE(LAY("div2"),1,cols)
	;
	; column headers (dense)
	DO PUT(LAY("colhdr"),1,$$C("HEAD",.CONF)_"Recent"_$$RESET(.CONF))
	DO PUT(LAY("colhdr"),splitC+1,$$C("HEAD",.CONF)_"Errors"_$$RESET(.CONF))
	;
	; vertical divider (static once)
	FOR r=LAY("colhdr"):1:LAY("listBottom") DO PUT(r,splitC,"|")
	;
	; log panel header line (static once)
	IF +$GET(CONF("logPanel")) DO
	. DO HLINE(LAY("logTop")-1,1,cols)
	. DO PUT(LAY("logTop")-1,1,$$C("HEAD",.CONF)_"Log"_$$RESET(.CONF))
	;
	; bottom divider + compact footer hint
	DO HLINE(LAY("divB"),1,cols)
	SET ctl="CTL: pause/stop/filter/scroll  |  IPC: PUBLOG/PUBSTATUS"
	DO PUT(LAY("help"),1,$$C("DIM",.CONF)_"MUMPS.IO  "_ctl_$$RESET(.CONF))
	QUIT
	;
WHEADER(CONF,LAY,CTX)
	NEW cols SET cols=LAY("cols")
	;
	; fixed width prefix so status never shifts
	NEW prefix SET prefix=$SELECT($GET(CTX("spin"))'="":"["_CTX("spin")_"] ",1:"    ")
	;
	; left: status (fits inside remaining space)
	DO PUT(LAY("hdr1"),20,$$FIT(prefix_CTX("status"),cols-22))
	;
	; row 2 is now owned by metrics bar (WMETRICS), so keep hdr2 blank
	DO PUT(LAY("hdr2"),1,$$FIT("",cols))
	QUIT
WMETRICS(CONF,LAY,CTX)
	NEW cols SET cols=LAY("cols")
	NEW id SET id=CTX("id")
	;
	; queue lag
	NEW qnext SET qnext=+$GET(^MIO("DEVW",id,"Q","next"))
	NEW qdone SET qdone=+$GET(^MIO("DEVW",id,"STATE","qdone"))
	NEW qlag SET qlag=qnext-qdone IF qlag<0 SET qlag=0
	;
	; ctl flags
	NEW pz SET pz=$$YESNO($$GETCTL(id,"pause"))
	NEW sz SET sz=$$YESNO($$GETCTL(id,"stop"))
	;
	; counters
	NEW scans,ok,errs,uptime
	SET scans=+$GET(^MIO("DEVW",id,"STATE","metrics","scans"))
	SET ok=+$GET(^MIO("DEVW",id,"STATE","metrics","ok"))
	SET errs=+$GET(^MIO("DEVW",id,"STATE","metrics","errors"))
	SET uptime=$$UPTIME($GET(^MIO("DEVW",id,"STATE","startH"),$H),$H)
	;
	; one dense line (stable token order)
	NEW line
	SET line="p:"_pz_" s:"_sz_" q:"_qlag_"  up "_uptime_"  sc "_scans_" pr "_CTX("processed")_" ok "_ok_" er "_errs_" r "_$$FMT(CTX("rate"),2)_"/s"
	;
	DO PUT(LAY("met"),1,$$FIT(line,cols))
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
	; Scrollable log panel (bottom). Deterministic for dryUI tests.;
	NEW id SET id=$GET(CTX("id"),$GET(CONF("id"),"default"))
	NEW top SET top=+$GET(LAY("logTop"))
	NEW bottom SET bottom=+$GET(LAY("logBottom"))
	IF top<1!(bottom<top) QUIT
	;
	NEW lines SET lines=+$GET(LAY("logLines"))
	IF lines<1 QUIT
	SET ^MIO("DEVW",id,"STATE","ui","log","lines")=lines
	;
	NEW cols SET cols=+$GET(LAY("cols")) IF cols<1 SET cols=80
	;
	; Normalize filter + clamp scroll (using NEW LOGMAXSCROLL behavior)
	NEW fltNow SET fltNow=$$LOGFILTER(id)
	NEW maxS SET maxS=$$LOGMAXSCROLL(id,fltNow,lines)
	;
	NEW scrNow SET scrNow=+$GET(^MIO("DEVW",id,"CTL","logScroll"))
	IF scrNow<0 SET scrNow=0
	IF scrNow>maxS SET scrNow=maxS
	;
	; Detect ctl changes + force repaint (and clear uidiff cache for log rows)
	NEW fltOld SET fltOld=$GET(^MIO("DEVW",id,"STATE","ui","log","flt"))
	NEW scrOld SET scrOld=+$GET(^MIO("DEVW",id,"STATE","ui","log","scr"))
	NEW force SET force=((fltNow'=fltOld)!(scrNow'=scrOld))
	;
	IF force DO
	. SET ^MIO("DEVW",id,"STATE","ui","log","flt")=fltNow
	. SET ^MIO("DEVW",id,"STATE","ui","log","scr")=scrNow
	. SET ^MIO("DEVW",id,"CTL","logScroll")=scrNow
	. DO CLRCACHE(top,top+lines-1)
	. SET CTX("dirty")=1
	;
	; Also repaint if new log entries arrived since last paint (important for tests)
	NEW logN SET logN=+$GET(^MIO("DEVW",id,"STATE","log","n"))
	NEW lastPaintN SET lastPaintN=+$GET(^MIO("DEVW",id,"STATE","ui","log","nPaint"))
	IF logN'=lastPaintN DO
	. SET ^MIO("DEVW",id,"STATE","ui","log","nPaint")=logN
	. ; no need to clear cache here; content will differ, but ensure we do paint
	. SET CTX("dirty")=1
	;
	; If still not dirty, skip work
	IF '$GET(CTX("dirty")) QUIT
	SET ^TMP($J,"MIODEVW","UI","force")=1
	;
	; Header right side (keep minimal)
	IF (top-1)>0 DO
	. NEW hdr SET hdr="filter="_fltNow_" scroll="_scrNow_"/"_maxS
	. NEW cpos SET cpos=cols-$L(hdr)+1 IF cpos<1 SET cpos=1
	. DO PUT(top-1,cpos,$$C("DIM",.CONF)_hdr_$$RESET(.CONF))
	; Render newest->oldest applying filter + scroll
	NEW max SET max=+$GET(^MIO("DEVW",id,"STATE","conf","logMax"),100)
	NEW n SET n=logN
	NEW cap SET cap=$SELECT(n<max:n,1:max)
	;
	NEW needSkip SET needSkip=scrNow
	NEW outCount SET outCount=0
	;
	NEW i,idx,rec,lvl,msg,row,line
	FOR i=0:1:(cap-1) QUIT:(outCount'<lines)  DO
	. SET idx=((n-i-1)#max)+1
	. SET rec=$GET(^MIO("DEVW",id,"STATE","log",idx))
	. IF rec="" QUIT
	. SET lvl=$PIECE(rec,"^",2),msg=$PIECE(rec,"^",3)
	. IF '$$LOGMATCH(fltNow,lvl) QUIT
	. IF needSkip>0 SET needSkip=needSkip-1 QUIT
	. SET outCount=outCount+1
	. SET row=top+outCount-1
	. SET line=$PIECE(rec,"^",1)_" ["_lvl_"] "_msg
	. DO PUT(row,1,$$FIT($$LOGLINE(lvl,line,.CONF),cols))
	;
	; Clear remaining rows
	FOR row=(top+outCount):1:bottom DO PUT(row,1,$$FIT("",cols))
	KILL ^TMP($J,"MIODEVW","UI","force")
	QUIT
LOGLINE(LVL,LINE,CONF)
	NEW l SET l=$ZCONVERT($GET(LVL),"U")
	IF l="ERROR" QUIT $$C("ERROR",.CONF)_LINE_$$RESET(.CONF)
	IF l="WARN" QUIT $$C("WARN",.CONF)_LINE_$$RESET(.CONF)
	IF l="OK" QUIT $$C("OK",.CONF)_LINE_$$RESET(.CONF)
	IF l="INFO" QUIT $$C("INFO",.CONF)_LINE_$$RESET(.CONF)
	QUIT $$C("DIM",.CONF)_LINE_$$RESET(.CONF)
	;
; -------------------- Drawing primitives (dryUI + uidiff) --------------------
PUT(R,C,S)
	; Smooth PUT: no CLREOL, diff-cache for BOTH dryUI and real TTY, pad only when C=1
	NEW dry SET dry=+$GET(^TMP($J,"MIODEVW","UI","dry"))
	NEW uid SET uid=+$GET(^TMP($J,"MIODEVW","UI","uidiff"))
	NEW frc SET frc=+$GET(^TMP($J,"MIODEVW","UI","force"))
	NEW cols SET cols=+$GET(^TMP($J,"MIODEVW","UI","cols"),0)
	;
	; Diff cache applies to both dry and tty
	IF 'frc,uid,$GET(^TMP($J,"MIODEVW","UI","cache",R,C))=$G(S) QUIT
	SET ^TMP($J,"MIODEVW","UI","cache",R,C)=$G(S)
	;
	IF dry DO  QUIT
	. NEW n SET n=+$GET(^TMP($J,"MIODEVW","UI","ops"))+1
	. SET ^TMP($J,"MIODEVW","UI","ops")=n
	. SET ^TMP($J,"MIODEVW","UI","ops",n)="("_R_","_C_") "_$G(S)
	;
	IF '$GET(^TMP($J,"MIODEVW","UI","tty")) QUIT
	NEW io SET io=$GET(^TMP($J,"MIODEVW","UI","ttyIO"),$IO)
	USE io
	WRITE $$GOTO(R,C),$G(S)
	;
	; Pad only full-line writes so we don't erase right-side columns
	IF cols>0,(+C=1) DO
	. NEW pad SET pad=cols-$$VISLEN($G(S))
	. IF pad>0 WRITE $J("",pad)
	;
	QUIT
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
	QUIT $$JOIN($$FIRSTDIR(.CONF),$GET(CONF("pattern"),"*.*"))
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
	; Return ANSI prefix (or "") safely as an EXTRINSIC.;
	IF '$GET(CONF("color")) QUIT ""
	NEW esc,mode,t
	SET esc=$CHAR(27)_"["
	SET mode=+$GET(CONF("colorMode"),1)
	SET t=""
	; mode 1 = minimal: only ERROR/WARN + mild emphasis
	IF mode=1 DO  QUIT t
	. IF LEVEL="ERROR" SET t=esc_"31m" QUIT
	. IF LEVEL="WARN"  SET t=esc_"33m" QUIT
	. IF LEVEL="HEAD"  SET t=esc_"1m"  QUIT  ; bold
	. IF LEVEL="DIM"   SET t=esc_"2m"  QUIT  ; faint
	. SET t="" QUIT
	; mode 2 = full palette
	IF LEVEL="ERROR" QUIT esc_"31m"
	IF LEVEL="WARN"  QUIT esc_"33m"
	IF LEVEL="INFO"  QUIT esc_"32m"
	IF LEVEL="OK"    QUIT esc_"36m"
	IF LEVEL="DEBUG" QUIT esc_"90m"
	IF LEVEL="HEAD"  QUIT esc_"35m"
	IF LEVEL="DIM"   QUIT esc_"90m"
	QUIT esc_"0m"
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
NEEDTICK(ID)
	NEW tick,days,sec,now,last
	SET tick=+$GET(^MIO("DEVW",ID,"STATE","ui","tick"),1)
	IF tick<1 QUIT 0
	SET days=+$PIECE($H,",",1),sec=+$PIECE($H,",",2)
	SET now=(days*86400)+sec
	SET last=+$GET(^MIO("DEVW",ID,"STATE","ui","lastPaint"))
	IF (now-last)<tick QUIT 0
	SET ^MIO("DEVW",ID,"STATE","ui","lastPaint")=now
	QUIT 1
DIRLIST(CONF,DIRS)
	; Build a normalized directory list into DIRS(n)=path
	KILL DIRS
	NEW n,i,x,c
	; (1) dir(n)
	IF $DATA(CONF("dir",1)) DO  QUIT
	. SET n=0
	. FOR  SET n=$ORDER(CONF("dir",n)) QUIT:n=""  DO
	. . SET x=$GET(CONF("dir",n)) QUIT:x=""
	. . SET DIRS(n)=x
	; (2) dirs CSV
	SET c=$GET(CONF("dirs"))
	IF c'="" DO  QUIT
	. FOR i=1:1:$L(c,",") DO
	. . SET x=$$TRIMB($PIECE(c,",",i)) QUIT:x=""
	. . SET DIRS(i)=x
	; (3) single dir
	SET x=$GET(CONF("dir")) IF x="" SET x="."
	SET DIRS(1)=x
	QUIT
	;
FIRSTDIR(CONF)
	NEW D,di
	DO DIRLIST(.CONF,.D)
	SET di=$ORDER(D(""))
	IF di="" QUIT "."
	QUIT D(di)
	;
PATSTR(CONF)
	; Nice display string: "<first>/<pattern> (+N)"
	NEW D,di,c,first,pat
	DO DIRLIST(.CONF,.D)
	SET (c,first)=0,di=""
	FOR  SET di=$ORDER(D(di)) QUIT:di=""  DO
	. SET c=c+1
	. IF c=1 SET first=D(di)
	SET pat=$GET(CONF("pattern"),"*.*")
	NEW s SET s=first_"/"_pat
	IF c>1 SET s=s_" (+"_(c-1)_")"
	QUIT s
	;
TRIMB(S)
	NEW x SET x=$GET(S)
	FOR  QUIT:$EXTRACT(x,1)'=" "  SET x=$EXTRACT(x,2,$LENGTH(x))
	FOR  QUIT:$EXTRACT(x,$LENGTH(x))'=" "  SET x=$EXTRACT(x,1,$LENGTH(x)-1)
	QUIT x
	;