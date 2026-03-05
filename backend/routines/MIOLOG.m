MIOLOG ; Structured logging with enforced redaction.;
; API STABILITY
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; Purpose
; Structured logging with enforced redaction.;
;
; Responsibilities
; - Collect operational data.;
; - Export metrics.;
; - Enforce retention policies.;
;
; Entry Points
; - INFO
; - WARN
; - ERROR
; - PANIC
; - EMIT
; - REDACT
; - ISREDACT
; - LOW
;
; Globals Used
; - ^MIO("LOG",...)
;
; Notes
; Keep comments short.;
; Do not log secrets.;
;
	; Generated V1-01 (YottaDB)
	;
; Entry point
; See docs/routines for details.;
INFO(EVT,CTX) DO EMIT("info",EVT,.CTX) QUIT
; Entry point
; See docs/routines for details.;
WARN(EVT,CTX) DO EMIT("warn",EVT,.CTX) QUIT
; Entry point
; See docs/routines for details.;
ERROR(EVT,CTX) DO EMIT("error",EVT,.CTX) QUIT
; Entry point
; See docs/routines for details.;
PANIC(EVT,CTX) DO EMIT("panic",EVT,.CTX) QUIT
	;
; Entry point
; See docs/routines for details.;
EMIT(LEVEL,EVT,CTX)
	NEW REC,JSON
	SET REC("ts")=$$NOWISO^MIOUTIL()
	SET REC("level")=LEVEL
	SET REC("event")=EVT
	IF $DATA(CTX) MERGE REC("ctx")=CTX
	DO REDACT(.REC)
	NEW TMP MERGE TMP=REC
	SET JSON=$$EN^MIOJSON1(.TMP)
	USE $PRINCIPAL WRITE JSON,!
	QUIT
	;
; Entry point
; See docs/routines for details.;
REDACT(REC)
	IF $DATA(REC("ctx","req","hdr")) DO
	. NEW K SET K=""
	. FOR  SET K=$ORDER(REC("ctx","req","hdr",K)) QUIT:K=""  DO
	. . IF $$ISREDACT(K) SET REC("ctx","req","hdr",K)="[REDACTED]"
	IF $DATA(REC("ctx","req","query")) DO
	. NEW K SET K=""
	. FOR  SET K=$ORDER(REC("ctx","req","query",K)) QUIT:K=""  SET REC("ctx","req","query",K)="[REDACTED]"
	QUIT
	;
; Entry point
; See docs/routines for details.;
ISREDACT(K)
	SET K=$$LOW(K)
	IF K="authorization" QUIT 1
	IF K="cookie" QUIT 1
	IF K="set-cookie" QUIT 1
	IF K="x-api-key" QUIT 1
	QUIT 0
	;
; Entry point
; See docs/routines for details.;
LOW(S)
	NEW I,C,OUT SET OUT=""
	FOR I=1:1:$LENGTH(S) DO
	. SET C=$ASCII($EXTRACT(S,I))
	. IF C>64,C<91 SET C=C+32
	. SET OUT=OUT_$CHAR(C)
	QUIT OUT
	;
	; -------------------------------------------------------------------------
	; ROI #1: Access logs + timing metrics (deterministic, global-backed)
	;
	; Public entry points:
	;   $$ACCESS(.CONF,.REQ,.CTX,.ERR)   -> 1 ok, 0 error (ERR set)
	;   $$FLUSH(.CONF,.ERR)             -> 1 ok (no-op in global sink)
	;   DO ACLEAR                         -> clear access ring (tests)
	;   DO ALAST(.LINE,.SEQ)              -> get last access line (tests/ops)
	;
	; Config:
	;   CONF("server","log","access","enabled")     default 0
	;   CONF("server","log","access","format")      common|combined|json (default common)
	;   CONF("server","log","access","maxEntries")  default 20000 (ring size)
	;
	; Notes:
	; - No filesystem I/O on the request path (writes go to globals).;
	; - Deterministic: single atomic sequence per access line via $INCREMENT.;
	; - Errors always include ERR("routine") and ERR("error").;
	;
ACCESS(CONF,REQ,CTX,ERR)
	KILL ERR
	IF '$$AEN(.CONF) QUIT 1
	NEW FMT SET FMT=$$LOW($GET(CONF("server","log","access","format"),"common"))
	NEW LINE,OK SET LINE="",OK=1
	IF FMT="json" DO
	. SET LINE=$$AJSON(.CONF,.REQ,.CTX,.ERR)
	. IF $DATA(ERR) SET OK=0
	ELSE  SET LINE=$$ALINE(FMT,.REQ,.CTX)
	IF 'OK QUIT 0
	DO APUT(.CONF,LINE)
	QUIT 1
	;
FLUSH(CONF,ERR)
	; Global sink has no flush step; retained for compatibility.;
	KILL ERR
	QUIT 1
	;
AEN(CONF)
	QUIT +$GET(CONF("server","log","access","enabled"),0)
	;
; ---- access ring storage (global sink) ---------------------------------
;
; Store LINE into a fixed-size ring in ^MIO("LOG","ACCESS","ring",slot).;
; Uses one atomic sequence counter to preserve deterministic ordering.;
;
APUT(CONF,LINE)
	NEW MAX SET MAX=+$GET(CONF("server","log","access","maxEntries"),20000)
	;IF MAX<100 SET MAX=100
	NEW SEQ SET SEQ=$INCREMENT(^MIO("LOG","ACCESS","seq"))
	NEW SLOT SET SLOT=((SEQ-1)#MAX)+1
	SET ^MIO("LOG","ACCESS","ring",SLOT)=LINE
	SET ^MIO("LOG","ACCESS","ring",SLOT,"seq")=SEQ
	SET ^MIO("LOG","ACCESS","last")=SEQ
	SET ^MIO("LOG","ACCESS","lastSlot")=SLOT
	SET ^MIO("LOG","ACCESS","maxEntries")=MAX
	SET ^MIO("LOG","ACCESS","count")=$INCREMENT(^MIO("LOG","ACCESS","count"))
	QUIT
	;
ACLEAR ; Clear access log ring (tests)
	KILL ^MIO("LOG","ACCESS","ring")
	KILL ^MIO("LOG","ACCESS","last"),^MIO("LOG","ACCESS","lastSlot")
	QUIT
	;
ALAST(LINE,SEQ) ; Return last access log line (tests/ops)
	SET LINE="",SEQ=0
	NEW SLOT SET SLOT=+$GET(^MIO("LOG","ACCESS","lastSlot"))
	IF SLOT<1 QUIT
	SET LINE=$GET(^MIO("LOG","ACCESS","ring",SLOT))
	SET SEQ=+$GET(^MIO("LOG","ACCESS","ring",SLOT,"seq"))
	QUIT
	;
; Deterministic access logging:
; - No file-handle caching; each FLUSH opens and closes the target file(s).;
; - Prevents read-only device errors across re-runs/tests.;
;
SCTRP ; internal: safe close trap helper
	SET $ECODE=""
	QUIT
	;
SAFECLOSE(DEV)
	NEW $ETRAP,$ESTACK,$ET,$ES
	SET $ETRAP="DO SCTRP^MIOLOG"
	CLOSE DEV
	QUIT
	;
CLOSEALL(CONF)
	; Public: retained for compatibility (deterministic mode keeps no cached handles).;
	QUIT
	;
NEEDFLUSH(CONF)
	NEW QC SET QC=+$GET(^TMP($J,"MIOLOG","A","qC"))
	NEW QB SET QB=+$GET(^TMP($J,"MIOLOG","A","qB"))
	NEW FE SET FE=+$GET(CONF("server","log","access","flushEvery"),50)
	NEW FB SET FB=+$GET(CONF("server","log","access","flushBytes"),65536)
	IF FE<1 SET FE=1
	IF FB<1024 SET FB=1024
	IF QC'<FE QUIT 1
	IF QB'<FB QUIT 1
	QUIT 0
	;
QPUT(LINE)
	NEW N SET N=+$GET(^TMP($J,"MIOLOG","A","qN"))
	SET N=N+1,^TMP($J,"MIOLOG","A","qN")=N
	SET ^TMP($J,"MIOLOG","A","Q",N)=LINE
	SET ^TMP($J,"MIOLOG","A","qC")=+$GET(^TMP($J,"MIOLOG","A","qC"))+1
	SET ^TMP($J,"MIOLOG","A","qB")=+$GET(^TMP($J,"MIOLOG","A","qB"))+$L(LINE)+1
	QUIT
	;
QCLR
	KILL ^TMP($J,"MIOLOG","A","Q")
	SET ^TMP($J,"MIOLOG","A","qC")=0
	SET ^TMP($J,"MIOLOG","A","qB")=0
	QUIT
	;
	;
OPNTRAP ; internal: open() error trap helper (OPENA)
	SET OK=0
	SET $ECODE=""
	QUIT
	;
OPENA(DEV)
	; Robust open for append-only log writes.;
	; Returns 1 on success, 0 on failure (no exception raised).;
	NEW $ETRAP,$ESTACK,$ET,$ES
	NEW OK SET OK=0
	DO SAFECLOSE(DEV)
	SET $ETRAP="DO OPNTRAP^MIOLOG"
	OPEN DEV:(append:stream:nowrap):1
	IF $TEST SET OK=1 QUIT 1
	; On some YottaDB/GT.M builds, APPEND may not create a missing file.;
	; Use NEW (not NEWVERSION) so the created path is exactly DEV.;
	OPEN DEV:(new:stream:nowrap):1
	IF $TEST SET OK=1
	QUIT OK
	;
FPATH(BASE,DAY,SFX,DAILY)
	NEW ROOT SET ROOT=$GET(BASE)
	IF ROOT="" SET ROOT="tmp/mio-access"
	IF DAILY DO
	. SET ROOT=ROOT_"-"_DAY
	ELSE  DO
	. IF $E(ROOT,$L(ROOT)-3,$L(ROOT))=".log" SET ROOT=$E(ROOT,1,$L(ROOT)-4)
	IF +$GET(SFX)>0 SET ROOT=ROOT_"."_SFX
	QUIT ROOT_".log"
	;
DAY()
	NEW H SET H=$HOROLOG
	QUIT $ZDATE($PIECE(H,",",1),"YYYYMMDD")
	;
SETERR(ERR,CODE,PATH)
	SET ERR("routine")="MIOLOG"
	SET ERR("error")=CODE
	IF $GET(PATH)'="" SET ERR("path")=PATH
	QUIT
	;
ALINE(FMT,REQ,CTX)
	NEW IP SET IP=$GET(CTX("remote_addr"),"-")
	NEW TS SET TS=$$NOWISO^MIOUTIL()
	NEW M SET M=$GET(REQ("method"),"-")
	NEW T SET T=$$TARGET(.REQ)
	NEW V SET V=$GET(REQ("httpver"),"HTTP/1.1")
	NEW ST SET ST=+$GET(CTX("status"),0)
	NEW BIN SET BIN=+$GET(CTX("bytes_in"),+$GET(REQ("body","len"),0))
	NEW BOUT SET BOUT=+$GET(CTX("bytes_out"),0)
	NEW RID SET RID=$GET(CTX("request_id"),"")
	NEW PMS SET PMS=$$NUM($GET(CTX("met","parse_ms")))
	NEW HMS SET HMS=$$NUM($GET(CTX("met","handler_ms")))
	NEW TMS SET TMS=$$NUM($GET(CTX("met","total_ms")))
	NEW E SET E=$GET(CTX("error"),"")
	NEW L SET L=IP_" - - ["_TS_"] """_M_" "_T_" "_V_""" "_ST_" "_BOUT
	IF FMT="combined" DO
	. NEW R SET R=$$ESCQ($GET(REQ("hdr","referer"),"-"))
	. NEW UA SET UA=$$ESCQ($GET(REQ("hdr","user-agent"),"-"))
	. SET L=L_" """_R_""" """_UA_""""
	SET L=L_" bin="_BIN_" pms="_PMS_" hms="_HMS_" tms="_TMS
	IF RID'="" SET L=L_" rid="_RID
	IF E'="" SET L=L_" err="_E
	QUIT L
	;
AJSON(CONF,REQ,CTX,ERR)
	KILL ERR
	NEW O
	SET O("ts")=$$NOWISO^MIOUTIL()
	SET O("remote_addr")=$GET(CTX("remote_addr"),"-")
	SET O("request_id")=$GET(CTX("request_id"),"")
	SET O("method")=$GET(REQ("method"),"-")
	SET O("target")=$$TARGET(.REQ)
	SET O("httpver")=$GET(REQ("httpver"),"HTTP/1.1")
	SET O("status")=+$GET(CTX("status"),0)
	SET O("bytes_in")=+$GET(CTX("bytes_in"),+$GET(REQ("body","len"),0))
	SET O("bytes_out")=+$GET(CTX("bytes_out"),0)
	SET O("parse_ms")=$$NUM($GET(CTX("met","parse_ms")))
	SET O("handler_ms")=$$NUM($GET(CTX("met","handler_ms")))
	SET O("total_ms")=$$NUM($GET(CTX("met","total_ms")))
	NEW UA SET UA=$GET(REQ("hdr","user-agent")) IF UA'="" SET O("user_agent")=UA
	NEW R SET R=$GET(REQ("hdr","referer")) IF R'="" SET O("referer")=R
	NEW E SET E=$GET(CTX("error")) IF E'="" SET O("error")=E
	NEW TMP MERGE TMP=O
	QUIT $$EN^MIOJSON1(.TMP)
	;
TARGET(REQ)
	IF $GET(REQ("target"))'="" QUIT $GET(REQ("target"))
	IF $GET(REQ("path"))'="" QUIT $GET(REQ("path"))
	IF $GET(REQ("uri"))'="" QUIT $GET(REQ("uri"))
	QUIT "/"
	;
NUM(X)
	NEW V SET V=+$GET(X)
	QUIT V
	;
ESCQ(S)
	NEW X SET X=$GET(S,"")
	SET X=$TRANSLATE(X,$CHAR(13,10),"  ")
	IF X["\\" SET X=$$REPLACE^MIOUTIL(X,"\\","\\\\")
	IF X["""" SET X=$$REPLACE^MIOUTIL(X,"""","\\""")
	QUIT X
	;
	;