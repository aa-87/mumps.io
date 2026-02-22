MIODEVWT ; MIODEVW test suite (pure M)
	;
	; Comprehensive tests for:
	;  - DEFAULT/INITSTATE
	;  - IPC queue + consumption (PUB* + UIPOLL)
	;  - Ring buffers (recent/errors)
	;  - HANDLE change detection + callback + capture
	;  - Widget registry (REGW + external widget calls)
	;
	; Run:
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
	DO ASSERT($GET(A)'=$GET(B),MSG_" (got='"_$GET(A)_"' expected !=)",.PASS,.FAIL)
	QUIT
	;
; -------------------- Tests --------------------
	;
TDEFAULT(PASS,FAIL)
	NEW C KILL C
	DO DEFAULT^MIODEVW(.C)
	DO EQ($GET(C("id")),"default","DEFAULT sets id",.PASS,.FAIL)
	DO EQ($GET(C("interval")),1,"DEFAULT sets interval",.PASS,.FAIL)
	DO EQ($GET(C("dryUI")),0,"DEFAULT sets dryUI",.PASS,.FAIL)
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
	NEW lastSeq SET lastSeq=+$GET(^MIO("DEVW",ID,"STATE","qdone"))
	DO UIPOLL^MIODEVW(.C,.lastSeq)
	DO EQ($GET(^MIO("DEVW",ID,"STATE","status")),"hello","UIPOLL consumes status",.PASS,.FAIL)
	DO EQ(+$GET(^MIO("DEVW",ID,"STATE","metrics","jobs")),3,"UIPOLL consumes metadd",.PASS,.FAIL)
	DO ASSERT(+$GET(^MIO("DEVW",ID,"STATE","errors","n"))>0,"UIPOLL records error",.PASS,.FAIL)
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
	; shrink buffers
	SET ^MIO("DEVW",ID,"STATE","conf","lastN")=3
	SET ^MIO("DEVW",ID,"STATE","conf","errN")=2
	; recent wrap
	DO ADDRECENT^MIODEVW(ID,"/tmp/a.req","OK","1")
	DO ADDRECENT^MIODEVW(ID,"/tmp/b.req","OK","2")
	DO ADDRECENT^MIODEVW(ID,"/tmp/c.req","OK","3")
	DO ADDRECENT^MIODEVW(ID,"/tmp/d.req","OK","4")
	NEW n SET n=+$GET(^MIO("DEVW",ID,"STATE","recent","n"))
	DO EQ(n,4,"recent n increments",.PASS,.FAIL)
	; after 4 inserts with max=3, latest should be present
	NEW idx SET idx=((n-1)#3)+1
	NEW rec SET rec=$GET(^MIO("DEVW",ID,"STATE","recent",idx))
	DO ASSERT(rec["d.req","recent wrap keeps latest",.PASS,.FAIL)
	; errors wrap
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
	; create file
	NEW FP SET FP="/tmp/miodevw_test_"_$J_"_1.req"
	DO WFILE(FP,"one"_$C(10)_"two"_$C(10))
	KILL ^TMP($J,"MIODEVWT","cb")
	NEW r1 SET r1=$$HANDLE^MIODEVW(FP,.C)
	DO EQ(r1,1,"HANDLE processes new file",.PASS,.FAIL)
	DO EQ(+$GET(^TMP($J,"MIODEVWT","cb")),1,"callback called once",.PASS,.FAIL)
	; unchanged should skip
	NEW r2 SET r2=$$HANDLE^MIODEVW(FP,.C)
	DO EQ(r2,0,"HANDLE skips unchanged file",.PASS,.FAIL)
	DO EQ(+$GET(^TMP($J,"MIODEVWT","cb")),1,"callback not called on skip",.PASS,.FAIL)
	; modify file
	DO AFILE(FP,"three"_$C(10))
	NEW r3 SET r3=$$HANDLE^MIODEVW(FP,.C)
	DO EQ(r3,1,"HANDLE processes changed file",.PASS,.FAIL)
	DO EQ(+$GET(^TMP($J,"MIODEVWT","cb")),2,"callback called after change",.PASS,.FAIL)
	; capture log exists
	NEW out SET out="/tmp/"_$$BASENAME^MIODEVW(FP)_".out.log"
	DO ASSERT($$EXISTS^MIODEVW(out)=1,"capture output log created",.PASS,.FAIL)
	KILL ^MIO("DEVW",ID)
	QUIT
	;
TWIDGET(PASS,FAIL)
	NEW ID SET ID="TWID"_$J
	KILL ^MIO("DEVW",ID)
	KILL ^TMP($J,"MIODEVWT","wd"),^TMP($J,"MIODEVWT","wp")
	NEW C KILL C
	SET C("id")=ID,C("dir")="/tmp",C("pattern")="*.req",C("interval")=1
	SET C("ui")=1,C("tty")=0,C("dryUI")=1,C("rows")=24,C("cols")=80
	DO DEFAULT^MIODEVW(.C)
	DO INITSTATE^MIODEVW(.C)
	; register external widget
	DO REGW^MIODEVW(.C,"test",25,"WDRAW^MIODEVWT","WPAINT^MIODEVWT")
	; start UI (tty=0 so no terminal impact)
	DO UISTART^MIODEVW(.C)
	DO ASSERT(+$GET(^TMP($J,"MIODEVWT","wd"))=1,"external widget DRAW called",.PASS,.FAIL)
	; paint
	NEW spinI,lastH,lastP
	SET spinI=0,lastH=$H,lastP=0
	DO UIRENDER^MIODEVW(.C,.spinI,.lastH,.lastP)
	DO ASSERT(+$GET(^TMP($J,"MIODEVWT","wp"))=1,"external widget PAINT called",.PASS,.FAIL)
	; and we should have collected some UI ops
	DO ASSERT(+$GET(^TMP($J,"MIODEVW","UI","ops"))>0,"dryUI captured ops",.PASS,.FAIL)
	KILL ^MIO("DEVW",ID)
	QUIT
	;
; -------------------- Test helpers --------------------
	;
CB(FP,CONF,ERR)
	; callback used by THANDLE
	SET ERR=""
	SET ^TMP($J,"MIODEVWT","cb")=+$GET(^TMP($J,"MIODEVWT","cb"))+1
	QUIT
	;
WDRAW(CONF,LAY,CTX)
	; custom widget draw (external)
	SET ^TMP($J,"MIODEVWT","wd")=1
	QUIT
	;
WPAINT(CONF,LAY,CTX)
	; custom widget paint (external)
	SET ^TMP($J,"MIODEVWT","wp")=1
	; write something to prove op recording
	DO PUT^MIODEVW(10,5,"[custom widget]")
	QUIT
	;
WFILE(PATH,TXT)
	NEW $ETRAP,$ES,old
	SET old=$IO
	SET $ETRAP="SET $ECODE="""" USE old QUIT"
	OPEN PATH:(NEWVERSION)
	USE PATH
	WRITE TXT
	CLOSE PATH
	USE old
	QUIT
	;
AFILE(PATH,TXT)
	NEW $ETRAP,$ES,old
	SET old=$IO
	SET $ETRAP="SET $ECODE="""" USE old QUIT"
	OPEN PATH:(APPEND)
	USE PATH
	WRITE TXT
	CLOSE PATH
	USE old
	QUIT
	;