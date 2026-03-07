MIOLOGT ; MIOLOG access log test suite (ROI #1 - global sink)
;
; Run:
;   YDB>ZL "MIOLOG.m","MIOLOGT.m","MIOTASSERT.m","MIOUTIL.m","MIOJSON1.m","MIOJSON2.m"
;   YDB>D ^MIOLOGT
;
; Notes
; - Prints only FAIL lines.
; - Deterministic: uses global-backed ring ^MIO("LOG","ACCESS",...).
;
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
RESET
	KILL ^MIO("LOG","ACCESS")
	KILL ^TMP($J,"MIOLOG")
	QUIT
	;
HAS(S,SUB)
	QUIT $SELECT($F($GET(S),$GET(SUB))>0:1,1:0)
	;
LAST(OUT)
	NEW LINE,SEQ
	SET OUT=""
	DO ALAST^MIOLOG(.LINE,.SEQ)
	SET OUT=LINE
	QUIT
	;
; ---------------- tests ----------------
	;
T001 ; common format
	DO RESET
	NEW CONF,REQ,CTX,ERR,OK,OUT
	SET CONF("server","log","access","enabled")=1
	SET CONF("server","log","access","format")="common"
	SET CONF("server","log","access","maxEntries")=200
	SET REQ("method")="GET",REQ("target")="/hello",REQ("httpver")="HTTP/1.1"
	SET REQ("body","len")=5
	SET CTX("remote_addr")="127.0.0.1"
	SET CTX("status")=200
	SET CTX("request_id")="rid123"
	SET CTX("bytes_in")=5,CTX("bytes_out")=10
	SET CTX("met","parse_ms")=1,CTX("met","handler_ms")=2,CTX("met","total_ms")=3
	SET OK=$$ACCESS^MIOLOG(.CONF,.REQ,.CTX,.ERR)
	DO OK^MIOTASSERT(OK=1,"[T001] access common returned error="_$GET(ERR("error")))
	DO LAST(.OUT)
	DO OK^MIOTASSERT($$HAS(OUT,"127.0.0.1")=1,"[T001] ip missing")
	DO OK^MIOTASSERT($$HAS(OUT,"""GET /hello HTTP/1.1""")=1,"[T001] request line missing")
	DO OK^MIOTASSERT($$HAS(OUT," rid=rid123")=1,"[T001] request id missing")
	QUIT
	;
T002 ; combined format
	DO RESET
	NEW CONF,REQ,CTX,ERR,OK,OUT
	SET CONF("server","log","access","enabled")=1
	SET CONF("server","log","access","format")="combined"
	SET CONF("server","log","access","maxEntries")=200
	SET REQ("method")="GET",REQ("target")="/x",REQ("httpver")="HTTP/1.1"
	SET REQ("hdr","referer")="http://ref/"
	SET REQ("hdr","user-agent")="UA"
	SET CTX("remote_addr")="10.0.0.1"
	SET CTX("status")=200,CTX("request_id")="ridC"
	SET OK=$$ACCESS^MIOLOG(.CONF,.REQ,.CTX,.ERR)
	DO OK^MIOTASSERT(OK=1,"[T002] access combined returned error="_$GET(ERR("error")))
	DO LAST(.OUT)
	DO OK^MIOTASSERT($$HAS(OUT,"""http://ref/"" ""UA""")=1,"[T002] combined fields missing")
	QUIT
	;
T003 ; json format
	DO RESET
	NEW CONF,REQ,CTX,ERR,OK,OUT
	SET CONF("server","log","access","enabled")=1
	SET CONF("server","log","access","format")="json"
	SET CONF("server","log","access","maxEntries")=200
	SET REQ("method")="POST",REQ("target")="/api",REQ("httpver")="HTTP/1.1"
	SET CTX("remote_addr")="192.168.1.2"
	SET CTX("status")=201
	SET CTX("request_id")="ridJ"
	SET OK=$$ACCESS^MIOLOG(.CONF,.REQ,.CTX,.ERR)
	DO OK^MIOTASSERT(OK=1,"[T003] access json returned error="_$GET(ERR("error")))
	DO LAST(.OUT)
	DO OK^MIOTASSERT($$HAS(OUT,"""request_id"":""ridJ""")=1,"[T003] request_id missing")
	DO OK^MIOTASSERT($$HAS(OUT,"""method"":""POST""")=1,"[T003] method missing")
	QUIT
	;
T004 ; ring wrap (maxEntries)
	DO RESET
	NEW CONF,REQ,CTX,ERR,OK,OUT
	SET CONF("server","log","access","enabled")=1
	SET CONF("server","log","access","format")="common"
	SET CONF("server","log","access","maxEntries")=1
	SET REQ("method")="GET",REQ("target")="/x",REQ("httpver")="HTTP/1.1"
	SET CTX("remote_addr")="1.1.1.1",CTX("status")=200
	SET CTX("request_id")="r1"
	SET OK=$$ACCESS^MIOLOG(.CONF,.REQ,.CTX,.ERR)
	DO OK^MIOTASSERT(OK=1,"[T004] access #1 error="_$GET(ERR("error")))
	SET CTX("request_id")="r2"
	KILL ERR SET OK=$$ACCESS^MIOLOG(.CONF,.REQ,.CTX,.ERR)
	DO OK^MIOTASSERT(OK=1,"[T004] access #2 error="_$GET(ERR("error")))
	DO LAST(.OUT)
	DO OK^MIOTASSERT($$HAS(OUT," rid=r2")=1,"[T004] last should be r2")
	DO OK^MIOTASSERT($SELECT($GET(^MIO("LOG","ACCESS","ring",1))[" rid=r2":1,1:0),"[T004] ring slot not overwritten")
	QUIT
	;
T005 ; deterministic counters increment
	DO RESET
	NEW CONF,REQ,CTX,ERR,OK,C0,C1
	SET CONF("server","log","access","enabled")=1
	SET CONF("server","log","access","format")="common"
	SET CONF("server","log","access","maxEntries")=10
	SET REQ("method")="GET",REQ("target")="/x",REQ("httpver")="HTTP/1.1"
	SET CTX("remote_addr")="2.2.2.2",CTX("status")=200
	SET C0=+$GET(^MIO("LOG","ACCESS","count"))
	SET CTX("request_id")="c1" SET OK=$$ACCESS^MIOLOG(.CONF,.REQ,.CTX,.ERR)
	DO OK^MIOTASSERT(OK=1,"[T005] access #1 error="_$GET(ERR("error")))
	SET CTX("request_id")="c2" KILL ERR SET OK=$$ACCESS^MIOLOG(.CONF,.REQ,.CTX,.ERR)
	DO OK^MIOTASSERT(OK=1,"[T005] access #2 error="_$GET(ERR("error")))
	SET C1=+$GET(^MIO("LOG","ACCESS","count"))
	DO OK^MIOTASSERT(C1=(C0+2),"[T005] count mismatch")
	QUIT
	;
T006 ; no ^TMP queue / no filesystem dependence
	DO RESET
	NEW CONF,REQ,CTX,ERR,OK
	SET CONF("server","log","access","enabled")=1
	SET CONF("server","log","access","format")="common"
	SET CONF("server","log","access","maxEntries")=10
	SET REQ("method")="GET",REQ("target")="/x",REQ("httpver")="HTTP/1.1"
	SET CTX("remote_addr")="3.3.3.3",CTX("status")=200,CTX("request_id")="ridA"
	SET OK=$$ACCESS^MIOLOG(.CONF,.REQ,.CTX,.ERR)
	DO OK^MIOTASSERT(OK=1,"[T006] access error="_$GET(ERR("error")))
	DO OK^MIOTASSERT($DATA(^TMP($J,"MIOLOG","A"))=0,"[T006] unexpected ^TMP queue present")
	QUIT
