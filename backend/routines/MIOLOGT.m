MIOLOGT ; MIOLOG access log test suite (ROI #1)
;
; Run:
;   YDB>ZL "MIOLOG.m","MIOLOGT.m","MIOTASSERT.m","MIOUTIL.m","MIOJSON1.m","MIOJSON2.m"
;   YDB>D ^MIOLOGT
;
; Notes
; - Prints only FAIL lines.;
; - Uses unique tmp paths; no file deletes required.;
	;
	NEW DEBUG SET DEBUG=$GET(^MIO("CONF","test","debug"),0)
	DO T001
	DO T002
	DO T003
	DO T004
	DO T005
	DO T006
	QUIT
	;
; ---------------- helpers ----------------
	;
TMPBASE(NAME)
	NEW TS SET TS=$HOROLOG
	QUIT "tmp/miologt_"_NAME_"_"_$J_"_"_$PIECE(TS,",",2)
	;
	;
	;
OPNTRAP ; internal: open() error trap helper (RDTXT)
	SET OPNOK=0
	SET $ECODE=""
	QUIT
	;
RDTXT(PATH,OUT)
	KILL OUT
	SET OUT=""
	NEW DEV SET DEV=PATH
	NEW $ETRAP,$ESTACK,$ET,$ES,OPNOK
	SET OPNOK=0
	SET $ETRAP="DO OPNTRAP^MIOLOGT"
	OPEN DEV:(readonly:stream:nowrap):1
	IF '$TEST QUIT 0
	USE DEV
	NEW X,TXT SET TXT=""
	FOR  READ X QUIT:$ZEOF  SET TXT=TXT_X_$CHAR(10)
	CLOSE DEV
	SET OUT=TXT
	QUIT 1
	;
	;
HAS(S,SUB)
	QUIT $SELECT($F($GET(S),$GET(SUB))>0:1,1:0)
	;
	;
; ---------------- tests ----------------
	;
T001 ; common format
	KILL ^TMP($J,"MIOLOG","A")
	NEW CONF,REQ,CTX,ERR,BASE,PATH,OUT,OK
	SET BASE=$$TMPBASE("common")
	SET CONF("server","log","access","enabled")=1
	SET CONF("server","log","access","fhCache")=0
	SET CONF("server","log","access","path")=BASE
	SET CONF("server","log","access","daily")=0
	SET CONF("server","log","access","format")="common"
	SET CONF("server","log","access","buffer")=0
	SET REQ("method")="GET",REQ("target")="/hello",REQ("httpver")="HTTP/1.1"
	SET REQ("body","len")=5
	SET CTX("remote_addr")="127.0.0.1"
	SET CTX("status")=200
	SET CTX("request_id")="rid123"
	SET CTX("bytes_in")=5,CTX("bytes_out")=10
	SET CTX("met","parse_ms")=1,CTX("met","handler_ms")=2,CTX("met","total_ms")=3
	SET OK=$$ACCESS^MIOLOG(.CONF,.REQ,.CTX,.ERR)
	DO OK^MIOTASSERT(OK=1,"[T001] access common returned error="_$GET(ERR("error")))
	SET PATH=BASE_".log"
	DO OK^MIOTASSERT($$RDTXT(PATH,.OUT)=1,"[T001] log file missing")
	DO OK^MIOTASSERT($$HAS(OUT,"127.0.0.1")=1,"[T001] ip missing")
	DO OK^MIOTASSERT($$HAS(OUT,"""GET /hello HTTP/1.1""")=1,"[T001] request line missing")
	DO OK^MIOTASSERT($$HAS(OUT," rid=rid123")=1,"[T001] request id missing")
	QUIT
	;
T002 ; combined format
	KILL ^TMP($J,"MIOLOG","A")
	NEW CONF,REQ,CTX,ERR,BASE,PATH,OUT,OK
	SET BASE=$$TMPBASE("combined")
	SET CONF("server","log","access","enabled")=1
	SET CONF("server","log","access","fhCache")=0
	SET CONF("server","log","access","path")=BASE
	SET CONF("server","log","access","daily")=0
	SET CONF("server","log","access","format")="combined"
	SET CONF("server","log","access","buffer")=0
	SET REQ("method")="GET",REQ("target")="/x",REQ("httpver")="HTTP/1.1"
	SET REQ("hdr","referer")="http://ref/"
	SET REQ("hdr","user-agent")="UA"
	SET CTX("remote_addr")="10.0.0.1"
	SET CTX("status")=200,CTX("request_id")="ridC"
	SET OK=$$ACCESS^MIOLOG(.CONF,.REQ,.CTX,.ERR)
	DO OK^MIOTASSERT(OK=1,"[T002] access combined returned error="_$GET(ERR("error")))
	SET PATH=BASE_".log"
	DO OK^MIOTASSERT($$RDTXT(PATH,.OUT)=1,"[T002] log file missing")
	DO OK^MIOTASSERT($$HAS(OUT,"""http://ref/"" ""UA""")=1,"[T002] combined fields missing")
	QUIT
	;
T003 ; json format
	KILL ^TMP($J,"MIOLOG","A")
	;NEW CONF,REQ,CTX,ERR,BASE,PATH,OUT,OK
	SET BASE=$$TMPBASE("json")
	SET CONF("server","log","access","enabled")=1
	SET CONF("server","log","access","fhCache")=0
	SET CONF("server","log","access","path")=BASE
	SET CONF("server","log","access","daily")=0
	SET CONF("server","log","access","format")="json"
	SET CONF("server","log","access","buffer")=0
	SET REQ("method")="POST",REQ("target")="/api",REQ("httpver")="HTTP/1.1"
	SET CTX("remote_addr")="192.168.1.2"
	SET CTX("status")=201
	SET CTX("request_id")="ridJ"
	SET OK=$$ACCESS^MIOLOG(.CONF,.REQ,.CTX,.ERR)
	DO OK^MIOTASSERT(OK=1,"[T003] access json returned error="_$GET(ERR("error")))
	SET PATH=BASE_".log"
	DO OK^MIOTASSERT($$RDTXT(PATH,.OUT)=1,"[T003] log file missing")
	DO OK^MIOTASSERT($$HAS(OUT,"""request_id"":""ridJ""")=1,"[T003] request_id missing")
	DO OK^MIOTASSERT($$HAS(OUT,"""method"":""POST""")=1,"[T003] method missing")
	QUIT
	;
T004 ; rotation trigger (maxBytes)
	KILL ^TMP($J,"MIOLOG","A")
	;NEW CONF,REQ,CTX,ERR,BASE,P0,P1,O0,O1,OK
	SET BASE=$$TMPBASE("rot")
	SET CONF("server","log","access","enabled")=1
	SET CONF("server","log","access","fhCache")=0
	SET CONF("server","log","access","path")=BASE
	SET CONF("server","log","access","daily")=0
	SET CONF("server","log","access","format")="common"
	SET CONF("server","log","access","buffer")=1
	SET CONF("server","log","access","flushEvery")=9999
	SET CONF("server","log","access","flushBytes")=999999
	SET CONF("server","log","access","maxBytes")=160
	; 1st line (long target)
	KILL REQ,CTX,ERR
	SET REQ("method")="GET",REQ("target")="/"_$JUSTIFY("",120),REQ("httpver")="HTTP/1.1"
	SET CTX("remote_addr")="1.1.1.1",CTX("status")=200,CTX("request_id")="r1"
	SET OK=$$ACCESS^MIOLOG(.CONF,.REQ,.CTX,.ERR)
	DO OK^MIOTASSERT(OK=1,"[T004] access #1 error="_$GET(ERR("error")))
	; 2nd line forces rotate
	KILL REQ,CTX,ERR
	SET REQ("method")="GET",REQ("target")="/"_$JUSTIFY("",120),REQ("httpver")="HTTP/1.1"
	SET CTX("remote_addr")="1.1.1.1",CTX("status")=200,CTX("request_id")="r2"
	SET OK=$$ACCESS^MIOLOG(.CONF,.REQ,.CTX,.ERR)
	DO OK^MIOTASSERT(OK=1,"[T004] access #2 error="_$GET(ERR("error")))
	SET OK=$$FLUSH^MIOLOG(.CONF,.ERR)
	DO OK^MIOTASSERT(OK=1,"[T004] flush error="_$GET(ERR("error")))
	SET P0=BASE_".log",P1=BASE_".1.log"
	DO OK^MIOTASSERT($$RDTXT(P0,.O0)=1,"[T004] base log missing")
	DO OK^MIOTASSERT($$RDTXT(P1,.O1)=1,"[T004] rotated log missing")
	DO OK^MIOTASSERT($$HAS(O0," rid=r1")=1,"[T004] r1 missing in base")
	DO OK^MIOTASSERT($$HAS(O1," rid=r2")=1,"[T004] r2 missing in rotated")
	QUIT
	;
T005 ; open failure -> ERR includes routine + error
	KILL ^TMP($J,"MIOLOG","A")
	NEW CONF,REQ,CTX,ERR,OK
	SET CONF("server","log","access","enabled")=1
	SET CONF("server","log","access","fhCache")=0
	SET CONF("server","log","access","daily")=0
	SET CONF("server","log","access","buffer")=0
	SET CONF("server","log","access","path")="tmp/__no_such_dir_"_$J_"/mio"
	SET REQ("method")="GET",REQ("target")="/x",REQ("httpver")="HTTP/1.1"
	SET CTX("remote_addr")="127.0.0.1",CTX("status")=200,CTX("request_id")="ridE"
	SET OK=$$ACCESS^MIOLOG(.CONF,.REQ,.CTX,.ERR)
	DO OK^MIOTASSERT(OK=0,"[T005] expected open failure")
	DO EQ^MIOTASSERT($GET(ERR("routine")),"MIOLOG","[T005] ERR routine missing")
	DO EQ^MIOTASSERT($GET(ERR("error")),"open_failed","[T005] ERR code mismatch")
	QUIT
	;
T006 ; file-handle cache: keep open between flushes, close explicitly
	KILL ^TMP($J,"MIOLOG","A"),^TMP($J,"MIOLOG","FH")
	NEW CONF,REQ,CTX,ERR,BASE,PATH,OUT,OK
	SET BASE=$$TMPBASE("fh")
	SET CONF("server","log","access","enabled")=1
	SET CONF("server","log","access","fhCache")=1
	SET CONF("server","log","access","fhIdleSeconds")=999
	SET CONF("server","log","access","path")=BASE
	SET CONF("server","log","access","daily")=0
	SET CONF("server","log","access","format")="common"
	SET CONF("server","log","access","buffer")=0
	SET REQ("method")="GET",REQ("target")="/x",REQ("httpver")="HTTP/1.1"
	SET REQ("body","len")=0
	SET CTX("remote_addr")="127.0.0.1"
	SET CTX("status")=200
	SET CTX("request_id")="ridA"
	SET OK=$$ACCESS^MIOLOG(.CONF,.REQ,.CTX,.ERR)
	DO OK^MIOTASSERT(OK=1,"[T006] first access failed err="_$GET(ERR("error")))
	SET PATH=BASE_".log"
	DO OK^MIOTASSERT($GET(^TMP($J,"MIOLOG","FH","access","fp"))=PATH,"[T006] cache fp missing/mismatch")
	SET CTX("request_id")="ridB"
	KILL ERR SET OK=$$ACCESS^MIOLOG(.CONF,.REQ,.CTX,.ERR)
	DO OK^MIOTASSERT(OK=1,"[T006] second access failed err="_$GET(ERR("error")))
	DO OK^MIOTASSERT($DATA(^TMP($J,"MIOLOG","FH","access","fp"))=1,"[T006] cache not present after second flush")
	DO CLOSEALL^MIOLOG(.CONF)
	DO OK^MIOTASSERT($DATA(^TMP($J,"MIOLOG","FH","access"))=0,"[T006] cache not cleared by CLOSEALL")
	DO OK^MIOTASSERT($$RDTXT(PATH,.OUT)=1,"[T006] log file missing")
	DO OK^MIOTASSERT($$HAS(OUT,"ridA"),"[T006] ridA missing")
	DO OK^MIOTASSERT($$HAS(OUT,"ridB"),"[T006] ridB missing")
	QUIT
	;
	;