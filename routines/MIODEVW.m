MIODEVW ; MUMPS.IO Development Watcher (YottaDB/GT.M)
	; ------------------------------------------------------------
	; Watches one or more directories for changes to matching files,
	; and writes events to an append-only JSONL log and an optional
	; status JSON file. Optionally prints a small TTY dashboard.;
	;
	; PUBLIC:
	;   START(.C)  - run watcher loop (blocking)
	;   STOP(.C)   - request stop by creating stopFile
	;   SAMPLE(.C) - fill sample config
	;
	; CONFIG (.C):
	;   C("dir",n)       = directory to scan (required)
	;   C("pattern")     = wildcard pattern (default from ext or "*.html")
	;   C("ext")         = convenience: "html" => pattern="*.html" if pattern missing
	;   C("interval")    = seconds between scans (default 1)
	;   C("logFile")     = append-only JSONL log file (default derived)
	;   C("statusFile")  = overwrite JSON status file each scan (optional)
	;   C("stopFile")    = if exists => watcher exits (default unique per $JOB)
	;   C("tty")         = 1 => terminal dashboard (default 1)
	;   C("uiLines")     = number of recent events to show (default 10)
	;   C("hashBytes")   = fallback hash prefix size (default 65536)
	;   C("onChange")    = entryref "LABEL^ROU" called:
	;                      DO @C("onChange")(<path>,<kind>,.C)
	;
	; EVENT kinds: "add" | "mod" | "del"
	N C D CONFIG(.C)
	D START(.C)
	Q
	;
; -------------------------
; Public API
; -------------------------
	;
START(C) ;
	DO NORM(.C)
	; init state
	KILL ^TMP("MIODEVW",$JOB)
	DO LOG(.C,$$NOW()_" watcher_start pid="_$JOB_" pattern="_C("pattern"))
	DO LOOP(.C)
	DO LOG(.C,$$NOW()_" watcher_stop pid="_$JOB)
	Q
	;
STOP(C) ;
	DO NORM(.C) ; ensures stopFile exists
	DO TOUCH(C("stopFile"))
	Q
	;
CONFIG(C) ;
	KILL C
	SET C("dir",1)="templates"
	SET C("dir",2)="templates/partials"
	SET C("dir",3)="templates/pages"
	SET C("dir",4)="templates/layouts"
	SET C("ext")="html"
	SET C("interval")=1
	SET C("tty")=1
	SET C("uiLines")=10
	; Optionally:
	SET C("onChange")="PROCESS^MIODEVW"
	Q
PROCESS(FP,KIND,C)
	N DD,V,CNF,TOK,ERR,OPT 
	S OPT="" M CNF=^MIO("CONF")
	S DD="templates"
	S V=DD_$P(FP,DD,2,9999)
	I V]"",V[".html" D PROCESSFILE^MIOTPL(V) W "."
	Q
; -------------------------
; Main loop
; -------------------------
	;
LOOP(C) ;
	NEW EV
	FOR  QUIT:$$STOPPED(.C)  DO
	. KILL EV
	. DO SCAN(.C,.EV)
	. IF $DATA(EV("add"))!$DATA(EV("mod"))!$DATA(EV("del")) DO
	. . DO HANDLE(.C,.EV)
	. DO STATUS(.C,.EV)
	. DO UI(.C,.EV)
	. HANG +$GET(C("interval"),1)
	Q
	;
STOPPED(C) ;
	NEW sf SET sf=$GET(C("stopFile"))
	IF sf'="",$ZSEARCH(sf)'="" QUIT 1
	QUIT 0
	;
; -------------------------
; Scan + diff
; -------------------------
	;
SCAN(C,EV) ;
	NEW root,old,new
	SET root=$NAME(^TMP("MIODEVW",$JOB))
	SET old=$NAME(@root@("map"))
	SET new=$NAME(@root@("new"))
	KILL @new
	;
	NEW i,dir,spec,fp,sig,meta
	FOR i=1:1:+C("dirCount") DO
	. SET dir=$GET(C("dir",i)) QUIT:dir=""
	. SET spec=$$JOIN(dir,C("pattern"))
	. SET fp=$ZSEARCH(spec,-1)  ; reset stream each scan
	. FOR  QUIT:fp=""  DO
	. . DO FILESIG(fp,.sig,.meta,.C)
	. . SET @new@(fp)=sig
	. . SET fp=$ZSEARCH(spec)
	;
	; additions + modifications
	NEW k SET k=""
	FOR  SET k=$ORDER(@new@(k)) QUIT:k=""  DO
	. IF '$DATA(@old@(k)) SET EV("add",k)=@new@(k) QUIT
	. IF @old@(k)'=@new@(k) SET EV("mod",k)=@new@(k)
	;
	; deletions
	SET k=""
	FOR  SET k=$ORDER(@old@(k)) QUIT:k=""  DO
	. IF '$DATA(@new@(k)) SET EV("del",k)=@old@(k)
	;
	; meta
	SET EV("meta","ts")=$$NOW()
	SET EV("meta","files")=$$COUNT(new)
	;
	; commit
	KILL @old MERGE @old=@new KILL @new
	Q
	;
FILESIG(fp,sig,meta,C) ;
	KILL meta
	; Prefer ydbposix statfile (mtime/size) when available
	IF $$HASPOSIX(.C) DO  QUIT:$DATA(sig)
	. NEW st,ok SET ok=$$statfile^%ydbposix(fp,.st)
	. IF ok DO
	. . SET sig=st("mtime")_"|"_st("size")
	. . MERGE meta=st
	;
	; Fallback: prefix-hash of file content
	SET sig=$$HASHFILE(fp,.meta,.C)
	Q
	;
HASPOSIX(C) ;
	; Cache probe result
	IF $DATA(C("hasPosix")) QUIT C("hasPosix")
	NEW $ETRAP,$ESTACK,ok SET ok=1
	SET $ETRAP="SET ok=0,$ECODE="""",$ETRAP="""""  ; if plugin missing
	NEW dummy SET dummy=$$filemodeconst^%ydbposix("S_IFREG")
	SET C("hasPosix")=ok
	QUIT ok
	;
HASHFILE(fp,meta,C) ;
	NEW $ETRAP,$ESTACK,io,buf,chunk,tot,limit,hash,done,need
	SET meta("readerr")=0
	SET limit=+$GET(C("hashBytes")) IF limit<1 SET limit=65536
	SET io=$IO,buf="",tot=0,hash="",done=0
	SET $ETRAP="SET meta(""readerr"")=1,hash="""",done=1 GOTO HFQ"
	;
	OPEN fp:(READONLY:STREAM)
	USE fp
	FOR  DO  QUIT:done
	. READ chunk#4096
	. IF chunk'="" DO
	. . SET tot=tot+$LENGTH(chunk)
	. . IF $LENGTH(buf)<limit DO
	. . . SET need=limit-$LENGTH(buf)
	. . . SET buf=buf_$EXTRACT(chunk,1,need)
	. IF $ZEOF SET done=1
	;
	CLOSE fp USE io
	SET hash=$ZYHASH(buf)   ; returns hex
	SET meta("size")=tot,meta("hash")=hash
HFQ     QUIT tot_"|"_hash
	;
COUNT(aref) ;
	; aref is a CLOSED reference string (e.g. new or $NAME(EV("add")))
	NEW n,k SET n=0,k=""
	FOR  SET k=$ORDER(@aref@(k)) QUIT:k=""  SET n=n+1
	QUIT n
	;
; -------------------------
; Event handling
; -------------------------
	;
HANDLE(C,EV) ;
	NEW kind,fp,ts SET ts=$GET(EV("meta","ts"))
	FOR kind="add","mod","del" DO
	. SET fp=""
	. FOR  SET fp=$ORDER(EV(kind,fp)) QUIT:fp=""  DO
	. . DO LOGEVENT(.C,ts,kind,fp)
	. . DO RING(.C,ts,kind,fp)
	. . DO HOOK(.C,kind,fp)
	Q
	;
HOOK(C,kind,fp) ;
	NEW er SET er=$GET(C("onChange"))
	IF er="" QUIT
	; Hook must have formal list: LABEL(path,kind,.C)
	DO @er@(fp,kind,.C)
	Q
	;
RING(C,ts,kind,fp) ;
	NEW root SET root=$NAME(^TMP("MIODEVW",$JOB,"ring"))
	NEW max SET max=+$GET(C("uiLines")) IF max<1 SET max=10
	NEW idx SET idx=+$GET(@root@("idx"))+1
	SET @root@("idx")=idx
	SET @root@(idx)=ts_" "_kind_" "_fp
	; trim old (best-effort)
	NEW killto SET killto=idx-max
	IF killto>0 KILL @root@(killto)
	Q
	;
; -------------------------
; Logging + status output
; -------------------------
	;
LOGEVENT(C,ts,kind,fp) ;
	NEW line
	SET line="{""ts"":"""_$$JESC(ts)_""",""event"":"""_kind_""",""file"":"""_$$JESC(fp)_"""}"
	DO LOG(.C,line)
	Q
	;
LOG(C,line) ;
	NEW lf SET lf=$GET(C("logFile"))
	IF lf="" QUIT
	DO APPEND(lf,line)
	Q
	;
STATUS(C,EV) ;
	NEW sf SET sf=$GET(C("statusFile"))
	IF sf="" QUIT
	NEW ts SET ts=$GET(EV("meta","ts"),$$NOW())
	NEW files SET files=+$GET(EV("meta","files"))
	NEW adds,mods,dels
	SET adds=$$COUNT($NAME(EV("add")))
	SET mods=$$COUNT($NAME(EV("mod")))
	SET dels=$$COUNT($NAME(EV("del")))
	NEW js
	SET js="{""ts"":"""_$$JESC(ts)_""",""files"":"_files_",""add"":"_adds_",""mod"":"_mods_",""del"":"_dels_",""pid"":"_$JOB_"}"
	DO WRITEFILE(sf,js_$CHAR(10))
	Q
	;
APPEND(path,line) ;
	NEW $ETRAP,$ESTACK,io SET io=$IO
	SET $ETRAP="SET $ECODE="""",$ETRAP="""""  ; best-effort
	OPEN path:(APPEND:STREAM)
	USE path WRITE line,!
	CLOSE path USE io
	Q
	;
WRITEFILE(path,txt) ;
	NEW $ETRAP,$ESTACK,io SET io=$IO
	SET $ETRAP="SET $ECODE="""",$ETRAP="""""  ; best-effort
	OPEN path:(NEWVERSION:STREAM)
	USE path WRITE txt
	CLOSE path USE io
	Q
	;
TOUCH(path) ;
	DO WRITEFILE(path,"stop "_$$NOW()_$CHAR(10))
	Q
	;
; -------------------------
; Terminal UI (optional)
; -------------------------
	;
UI(C,EV) ;
	IF +$GET(C("tty"),1)'=1 QUIT
	NEW root SET root=$NAME(^TMP("MIODEVW",$JOB,"ring"))
	NEW ts SET ts=$GET(EV("meta","ts"),$$NOW())
	NEW files SET files=+$GET(EV("meta","files"))
	NEW adds,mods,dels
	SET adds=$$COUNT($NAME(EV("add")))
	SET mods=$$COUNT($NAME(EV("mod")))
	SET dels=$$COUNT($NAME(EV("del")))
	DO CLR
	WRITE "MIODEVW  pid=",$JOB,"  ts=",ts,!
	WRITE "Watching: ",C("dirCount")," dir(s)  pattern=",C("pattern"),"  interval=",+C("interval"),"s",!
	WRITE "Files: ",files,"   add:",adds,"  mod:",mods,"  del:",dels,!
	WRITE "Stopfile: ",C("stopFile"),!
	WRITE "Recent:",!
	NEW idx,max,from SET max=+$GET(C("uiLines")) IF max<1 SET max=10
	SET idx=+$GET(@root@("idx")),from=idx-max+1 IF from<1 SET from=1
	FOR  QUIT:from>idx  DO
	. IF $DATA(@root@(from)) WRITE "  ",@root@(from),!
	. SET from=from+1
	Q
	;
CLR ;
	; ANSI clear screen + home
	WRITE $CHAR(27)_"[2J"_$CHAR(27)_"[H"
	Q
	;
; -------------------------
; Helpers
; -------------------------
	;
NORM(C) ;
	; Normalize dirs
	IF $DATA(C("dir")),'$DATA(C("dir",1)) DO
	. SET C("dir",1)=C("dir") KILL C("dir")
	;
	; Count dirs
	NEW max SET max=$ORDER(C("dir",""),-1)
	IF max<1 SET max=0
	SET C("dirCount")=max
	;
	; Pattern from ext if needed
	IF $GET(C("pattern"))="" DO
	. IF $GET(C("ext"))'="" SET C("pattern")="*."_$GET(C("ext"))
	. ELSE  SET C("pattern")="*.html"
	;
	; Defaults
	IF $GET(C("interval"))="" SET C("interval")=1
	IF $GET(C("tty"))="" SET C("tty")=1
	IF $GET(C("uiLines"))="" SET C("uiLines")=10
	IF $GET(C("hashBytes"))="" SET C("hashBytes")=65536
	;
	; Derive a safe default stopFile/logFile per $JOB to avoid stale-file deletes
	NEW baseDir SET baseDir=$GET(C("dir",1))
	IF baseDir="" SET baseDir="."
	IF $GET(C("stopFile"))="" SET C("stopFile")=$$JOIN(baseDir,".miodevw."_$JOB_".stop")
	IF $GET(C("logFile"))=""  SET C("logFile")=$$JOIN(baseDir,"mio-devwatch."_$JOB_".log")
	; statusFile is optional; don’t force if user doesn’t want it
	Q
	;
JOIN(dir,pat) ;
	NEW d SET d=$GET(dir)
	IF d="" QUIT pat
	IF $EXTRACT(d,$LENGTH(d))'="/" SET d=d_"/"
	QUIT d_pat
	;
NOW() ;
	QUIT $ZDATE($HOROLOG,"YEAR-MM-DD 24:60:SS")
	;
JESC(s) ;
	; Minimal JSON string escaping
	NEW out,i,c SET out=""
	FOR i=1:1:$LENGTH($GET(s)) DO
	. SET c=$EXTRACT(s,i)
	. IF c="\" SET out=out_"\\"
	. ELSE  IF c="""" SET out=out_"\"""  ; \"
	. ELSE  IF c=$CHAR(10) SET out=out_"\n"
	. ELSE  IF c=$CHAR(13) SET out=out_"\r"
	. ELSE  IF c=$CHAR(9)  SET out=out_"\t"
	. ELSE  SET out=out_c
	QUIT out