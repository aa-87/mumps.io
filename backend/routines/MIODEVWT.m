MIODEVWT ; MIODEVW test suite (pure M)
	;
	; Run:
	;   ZL "MIODEVW","MIODEVWT"
	;   D RUN^MIODEVWT
	;
	;
RUN
	NEW PASS,FAIL S (PASS,FAIL)=0
	DO TDEFAULT(.PASS,.FAIL)
	DO TIPC(.PASS,.FAIL)
	DO TRING(.PASS,.FAIL)
	DO THANDLE(.PASS,.FAIL)
	DO TWIDGET(.PASS,.FAIL)
	DO TUIDIFF(.PASS,.FAIL)
	DO TLOGPANEL(.PASS,.FAIL)
	DO TLOGAPI(.PASS,.FAIL)
	WRITE !,"MIODEVWT results: PASS=",PASS," FAIL=",FAIL,!
	QUIT
	;
; -------------------- Assertions --------------------
	;
ASSERT(COND,MSG,PASS,FAIL)
	IF +$GET(COND) DO  QUIT
	. SET PASS=PASS+1
	SET FAIL=FAIL+1
	WRITE !,"FAIL: ",MSG,!
	QUIT
	;
EQ(A,B,MSG,PASS,FAIL)
	DO ASSERT($GET(A)=$GET(B),MSG_" (got='"_$GET(A)_"' expected='"_$GET(B)_"')",.PASS,.FAIL)
	QUIT
	;
NE(A,B,MSG,PASS,FAIL)
	DO ASSERT($GET(A)'=$GET(B),MSG_" (got='"_$GET(A)_"' expected different)",.PASS,.FAIL)
	QUIT
	;
; -------------------- Tests --------------------
	;
TDEFAULT(PASS,FAIL)
	NEW C KILL C
	DO DEFAULT^MIODEVW(.C)
	DO EQ($GET(C("id")),"default","DEFAULT sets id",.PASS,.FAIL)
	DO EQ($GET(C("interval")),1,"DEFAULT sets interval",.PASS,.FAIL)
	DO EQ(+$GET(C("uidiff")),1,"DEFAULT sets uidiff",.PASS,.FAIL)
	DO EQ(+$GET(C("dryUI")),0,"DEFAULT sets dryUI",.PASS,.FAIL)
	QUIT
	;
TIPC(PASS,FAIL)
	NEW ID SET ID="TIPC"_$J
	KILL ^MIO("DEVW",ID)
	NEW C KILL C
	SET C("id")=ID,C("ui")=1,C("tty")=0,C("dryUI")=1
	DO DEFAULT^MIODEVW(.C)
	DO INITSTATE^MIODEVW(.C)
	; publish
	DO PUBSTATUS^MIODEVW(ID,"hello")
	DO PUBMET^MIODEVW(ID,"jobs",3)
	DO PUBERR^MIODEVW(ID,"boom")
	DO PUBLOG^MIODEVW(ID,"INFO","log1")
	NEW lastSeq SET lastSeq=+$GET(^MIO("DEVW",ID,"STATE","qdone"))
	DO UIPOLL^MIODEVW(.C,.lastSeq)
	DO EQ($GET(^MIO("DEVW",ID,"STATE","status")),"hello","UIPOLL consumes status",.PASS,.FAIL)
	DO EQ(+$GET(^MIO("DEVW",ID,"STATE","metrics","jobs")),3,"UIPOLL consumes metadd",.PASS,.FAIL)
	DO ASSERT(+$GET(^MIO("DEVW",ID,"STATE","errors","n"))>0,"UIPOLL records error",.PASS,.FAIL)
	DO ASSERT(+$GET(^MIO("DEVW",ID,"STATE","log","n"))>0,"UIPOLL records log",.PASS,.FAIL)
	KILL ^MIO("DEVW",ID)
	QUIT
	;
TRING(PASS,FAIL)
	NEW ID SET ID="TRING"_$J
	KILL ^MIO("DEVW",ID)
	NEW C KILL C
	SET C("id")=ID,C("ui")=1,C("tty")=0,C("dryUI")=1
	DO DEFAULT^MIODEVW(.C)
	DO INITSTATE^MIODEVW(.C)
	SET ^MIO("DEVW",ID,"STATE","conf","lastN")=3
	SET ^MIO("DEVW",ID,"STATE","conf","errN")=2
	DO ADDRECENT^MIODEVW(ID,"/tmp/a.req","OK","1")
	DO ADDRECENT^MIODEVW(ID,"/tmp/b.req","OK","2")
	DO ADDRECENT^MIODEVW(ID,"/tmp/c.req","OK","3")
	DO ADDRECENT^MIODEVW(ID,"/tmp/d.req","OK","4")
	NEW n SET n=+$GET(^MIO("DEVW",ID,"STATE","recent","n"))
	DO EQ(n,4,"recent n increments",.PASS,.FAIL)
	NEW idx SET idx=((n-1)#3)+1
	NEW rec SET rec=$GET(^MIO("DEVW",ID,"STATE","recent",idx))
	DO ASSERT(rec["d.req","recent wrap keeps latest",.PASS,.FAIL)
	DO ADDERROR^MIODEVW(ID,"e1")
	DO ADDERROR^MIODEVW(ID,"e2")
	DO ADDERROR^MIODEVW(ID,"e3")
	NEW en SET en=+$GET(^MIO("DEVW",ID,"STATE","errors","n"))
	DO EQ(en,3,"errors n increments",.PASS,.FAIL)
	KILL ^MIO("DEVW",ID)
	QUIT
	;
THANDLE(PASS,FAIL)
	NEW ID SET ID="THND"_$J
	KILL ^MIO("DEVW",ID)
	NEW C KILL C
	SET C("id")=ID
	SET C("dir")="/tmp"
	SET C("pattern")="miodevw_test_"_$J_"_*.req"
	SET C("ui")=0,C("tty")=0,C("color")=0
	SET C("captureDir")="/tmp"
	SET C("onfile")="CB^MIODEVWT"
	DO DEFAULT^MIODEVW(.C)
	DO INITSTATE^MIODEVW(.C)
	NEW FP SET FP="/tmp/miodevw_test_"_$J_"_1.req"
	DO WFILE(FP,"one"_$C(10)_"two"_$C(10))
	KILL ^TMP($J,"MIODEVWT","cb")
	NEW r1 SET r1=$$HANDLE^MIODEVW(FP,.C)
	DO EQ(r1,1,"HANDLE processes new file",.PASS,.FAIL)
	DO EQ(+$GET(^TMP($J,"MIODEVWT","cb")),1,"callback called once",.PASS,.FAIL)
	NEW r2 SET r2=$$HANDLE^MIODEVW(FP,.C)
	DO EQ(r2,0,"HANDLE skips unchanged",.PASS,.FAIL)
	DO EQ(+$GET(^TMP($J,"MIODEVWT","cb")),1,"callback not called on skip",.PASS,.FAIL)
	DO AFILE(FP,"three"_$C(10))
	NEW r3 SET r3=$$HANDLE^MIODEVW(FP,.C)
	DO EQ(r3,1,"HANDLE processes changed",.PASS,.FAIL)
	DO EQ(+$GET(^TMP($J,"MIODEVWT","cb")),2,"callback called after change",.PASS,.FAIL)
	NEW out SET out="/tmp/"_$$BASENAME^MIODEVW(FP)_".out.log"
	DO ASSERT($$EXISTS^MIODEVW(out)=1,"capture output log created",.PASS,.FAIL)
	KILL ^MIO("DEVW",ID)
	QUIT
	;
TWIDGET(PASS,FAIL)
	NEW ID SET ID="TWID"_$J
	KILL ^MIO("DEVW",ID)
	KILL ^TMP($J,"MIODEVWT","wd"),^TMP($J,"MIODEVWT","wp"),^TMP($J,"MIODEVW","UI")
	NEW C KILL C
	SET C("id")=ID,C("dir")="/tmp",C("pattern")="*.req",C("interval")=1
	SET C("ui")=1,C("tty")=0,C("dryUI")=1,C("rows")=24,C("cols")=80
	DO DEFAULT^MIODEVW(.C)
	DO INITSTATE^MIODEVW(.C)
	DO REGW^MIODEVW(.C,"test",25,"WDRAW^MIODEVWT","WPAINT^MIODEVWT")
	DO UISTART^MIODEVW(.C)
	DO ASSERT(+$GET(^TMP($J,"MIODEVWT","wd"))=1,"external widget DRAW called",.PASS,.FAIL)
	NEW spinI,lastH,lastP
	SET spinI=0,lastH=$H,lastP=0
	DO UIRENDER^MIODEVW(.C,.spinI,.lastH,.lastP)
	DO ASSERT(+$GET(^TMP($J,"MIODEVWT","wp"))=1,"external widget PAINT called",.PASS,.FAIL)
	DO ASSERT(+$GET(^TMP($J,"MIODEVW","UI","ops"))>0,"dryUI captured ops",.PASS,.FAIL)
	KILL ^MIO("DEVW",ID)
	QUIT
	;
TUIDIFF(PASS,FAIL)
	KILL ^TMP($J,"MIODEVW","UI")
	SET ^TMP($J,"MIODEVW","UI","dry")=1
	SET ^TMP($J,"MIODEVW","UI","tty")=0
	SET ^TMP($J,"MIODEVW","UI","uidiff")=1
	KILL ^TMP($J,"MIODEVW","UI","cache"),^TMP($J,"MIODEVW","UI","ops")
	DO PUT^MIODEVW(1,1,"same")
	DO PUT^MIODEVW(1,1,"same")
	DO EQ(+$GET(^TMP($J,"MIODEVW","UI","ops")),1,"uidiff suppresses duplicate PUT",.PASS,.FAIL)
	QUIT
	;
TLOGPANEL(PASS,FAIL)
	NEW ID SET ID="TLOG"_$J
	KILL ^MIO("DEVW",ID),^TMP($J,"MIODEVW","UI")
	NEW C KILL C
	SET C("id")=ID,C("ui")=1,C("tty")=0,C("dryUI")=1,C("rows")=26,C("cols")=90
	SET C("logPanel")=1,C("logMinH")=6,C("logMax")=50
	DO DEFAULT^MIODEVW(.C)
	DO INITSTATE^MIODEVW(.C)
	DO UISTART^MIODEVW(.C)
	DO PUBLOG^MIODEVW(ID,"INFO","i1")
	DO PUBLOG^MIODEVW(ID,"ERROR","e1")
	DO PUBLOG^MIODEVW(ID,"ERROR","e2")
	NEW lastSeq SET lastSeq=+$GET(^MIO("DEVW",ID,"STATE","qdone"))
	DO UIPOLL^MIODEVW(.C,.lastSeq)
	NEW spinI,lastH,lastP
	SET spinI=0,lastH=$H,lastP=0
	DO UIRENDER^MIODEVW(.C,.spinI,.lastH,.lastP)
	DO ASSERT($$HASOP("e2",1)>0,"log panel renders logs",.PASS,.FAIL)
	; Filter ERROR only
	DO SETCTL^MIODEVW(ID,"logFilter","ERROR")
	NEW before SET before=+$GET(^TMP($J,"MIODEVW","UI","ops"))
	DO UIRENDER^MIODEVW(.C,.spinI,.lastH,.lastP)
	DO EQ($$HASOP("i1",before+1),0,"filter hides INFO",.PASS,.FAIL)
	DO ASSERT($$HASOP("e2",before+1)>0,"filter shows ERROR",.PASS,.FAIL)
	; Scroll up by 1 (skip newest ERROR -> show e1)
	DO SETCTL^MIODEVW(ID,"logScroll",1)
	SET before=+$GET(^TMP($J,"MIODEVW","UI","ops"))
	DO UIRENDER^MIODEVW(.C,.spinI,.lastH,.lastP)
	DO ASSERT($$HASOP("e1",before+1)>0,"scroll shows older log",.PASS,.FAIL)
	KILL ^MIO("DEVW",ID)
	QUIT
	;
TLOGAPI(PASS,FAIL)
	NEW ID SET ID="TAPI"_$J
	KILL ^MIO("DEVW",ID),^TMP($J,"MIODEVW","UI")
	NEW C KILL C
	SET C("id")=ID,C("ui")=1,C("tty")=0,C("dryUI")=1,C("rows")=26,C("cols")=90
	SET C("logPanel")=1,C("logMinH")=6,C("logMax")=50
	DO DEFAULT^MIODEVW(.C)
	DO INITSTATE^MIODEVW(.C)
	DO UISTART^MIODEVW(.C)
	; publish many logs
	NEW i,LVL
	FOR i=1:1:25 DO
	. SET LVL=$SELECT(i#5=0:"ERROR",i#5=1:"WARN",1:"INFO")
	. DO PUBLOG^MIODEVW(ID,LVL,"m"_i)
	NEW lastSeq SET lastSeq=+$GET(^MIO("DEVW",ID,"STATE","qdone"))
	DO UIPOLL^MIODEVW(.C,.lastSeq)
	NEW spinI,lastH,lastP
	SET spinI=0,lastH=$H,lastP=0
	DO UIRENDER^MIODEVW(.C,.spinI,.lastH,.lastP)
	NEW lines SET lines=+$GET(^MIO("DEVW",ID,"STATE","ui","log","lines"))
	DO ASSERT(lines>0,"viewport lines computed",.PASS,.FAIL)
	; ALL
	DO SETCTL^MIODEVW(ID,"logFilter","ALL")
	DO EQ($$LOGEND^MIODEVW(ID),0,"LOGEND returns 0",.PASS,.FAIL)
	NEW maxS SET maxS=$$LOGMAXSCROLL^MIODEVW(ID,"ALL",lines)
	DO EQ($$LOGHOME^MIODEVW(ID),maxS,"LOGHOME returns maxS",.PASS,.FAIL)
	DO EQ($$LOGDOWN^MIODEVW(ID,9999),0,"LOGDOWN clamps",.PASS,.FAIL)
	DO EQ($$LOGUP^MIODEVW(ID,9999),maxS,"LOGUP clamps",.PASS,.FAIL)
	; page up/down
	DO LOGEND^MIODEVW(ID)
	NEW expPU SET expPU=lines-1 IF expPU<1 SET expPU=1 IF expPU>maxS SET expPU=maxS
	DO EQ($$LOGPAGEUP^MIODEVW(ID),expPU,"LOGPAGEUP page",.PASS,.FAIL)
	DO EQ($$LOGPAGEDN^MIODEVW(ID),0,"LOGPAGEDN tail",.PASS,.FAIL)
	; ERROR filter clamp
	DO SETCTL^MIODEVW(ID,"logFilter","ERROR")
	DO SETCTL^MIODEVW(ID,"logScroll",maxS)
	DO UIRENDER^MIODEVW(.C,.spinI,.lastH,.lastP)
	NEW maxE SET maxE=$$LOGMAXSCROLL^MIODEVW(ID,"ERROR",lines)
	DO ASSERT(+$GET(^MIO("DEVW",ID,"CTL","logScroll"))'>maxE,"WLOG clamps scroll",.PASS,.FAIL)
	DO EQ($$LOGHOME^MIODEVW(ID),maxE,"LOGHOME uses filter max",.PASS,.FAIL)
	KILL ^MIO("DEVW",ID)
	QUIT
	;
; -------------------- Helpers --------------------
	;
HASOP(NEEDLE,FROM)
	; returns 1 if NEEDLE appears in dryUI ops starting at index FROM
	NEW i,n,s,found
	SET found=0
	SET FROM=+$GET(FROM) IF FROM<1 SET FROM=1
	SET n=+$GET(^TMP($J,"MIODEVW","UI","ops"))
	FOR i=FROM:1:n QUIT:found  DO
	. SET s=$GET(^TMP($J,"MIODEVW","UI","ops",i))
	. IF s[NEEDLE SET found=1
	QUIT found
	;
; callback used by THANDLE
CB(FP,CONF,ERR)
	SET ERR=""
	SET ^TMP($J,"MIODEVWT","cb")=+$GET(^TMP($J,"MIODEVWT","cb"))+1
	QUIT
	;
; custom widget draw (external)
WDRAW(CONF,LAY,CTX)
	SET ^TMP($J,"MIODEVWT","wd")=1
	QUIT
	;
; custom widget paint (external)
WPAINT(CONF,LAY,CTX)
	SET ^TMP($J,"MIODEVWT","wp")=1
	DO PUT^MIODEVW(10,5,"[custom widget]")
	QUIT
	;
WFILE(PATH,TXT)
	NEW $ETRAP,$ES,old
	SET old=$IO
	SET $ETRAP="SET $ECODE="""" USE old QUIT"
	OPEN PATH:(NEWVERSION)
	USE PATH WRITE TXT
	CLOSE PATH
	USE old
	QUIT
	;
AFILE(PATH,TXT)
	NEW $ETRAP,$ES,old
	SET old=$IO
	SET $ETRAP="SET $ECODE="""" USE old QUIT"
	OPEN PATH:(APPEND)
	USE PATH WRITE TXT
	CLOSE PATH
	USE old
	QUIT
	;