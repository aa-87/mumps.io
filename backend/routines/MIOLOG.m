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
	; ROI #1: Access logs + timing metrics (fast path + optional buffering)
	;
	; Public entry points:
	;   $$ACCESS(.CONF,.REQ,.CTX,.ERR)   -> 1 ok, 0 error (ERR set)
	;   $$FLUSH(.CONF,.ERR)             -> 1 ok, 0 error (ERR set)
	;
	; Config:
	;   CONF("server","log","access","enabled")     default 0
	;   CONF("server","log","access","path")        default "tmp/mio-access"
	;   CONF("server","log","access","format")      common|combined|json (default common)
	;   CONF("server","log","access","daily")       default 1
	;   CONF("server","log","access","maxBytes")    default 10485760 (10MB)
	;   CONF("server","log","access","buffer")      default 1 (queue in ^TMP($J,...))
	;   CONF("server","log","access","flushEvery")  default 50 (lines)
	;   CONF("server","log","access","flushBytes")  default 65536 (queued bytes)
	;   CONF("server","log","access","fhCache")     default 1 (keep file open between flushes)
	;   CONF("server","log","access","fhIdleSeconds") default 5 (best-effort close on idle)
	;
	; Notes:
	; - No ZSYSTEM (rotation is by filename).;
	; - Buffered mode reduces open/close overhead by batching writes.;
	; - FLUSH is safe to call frequently; it is a no-op when queue is empty.;
	; - Errors always include ERR("routine") and ERR("error").;
	;
ACCESS(CONF,REQ,CTX,ERR)
	KILL ERR
	IF '$$AEN(.CONF) QUIT 1
	DO FHCLOSEIDLE(.CONF)
	NEW FMT SET FMT=$$LOW($GET(CONF("server","log","access","format"),"common"))
	NEW LINE,OK SET LINE="",OK=1
	IF FMT="json" DO
	. SET LINE=$$AJSON(.CONF,.REQ,.CTX,.ERR)
	. IF $DATA(ERR) SET OK=0
	ELSE  SET LINE=$$ALINE(FMT,.REQ,.CTX)
	IF 'OK QUIT 0
	DO QPUT(LINE)
	NEW BUF SET BUF=+$GET(CONF("server","log","access","buffer"),1)
	IF 'BUF QUIT $$FLUSH(.CONF,.ERR)
	IF $$NEEDFLUSH(.CONF) QUIT $$FLUSH(.CONF,.ERR)
	QUIT 1
	;
FLUSH(CONF,ERR)
	KILL ERR
	IF '$$AEN(.CONF) QUIT 1
	DO FHCLOSEIDLE(.CONF)
	NEW QC SET QC=+$GET(^TMP($J,"MIOLOG","A","qC"))
	IF QC<1 QUIT 1
	NEW BASE SET BASE=$GET(CONF("server","log","access","path"),"tmp/mio-access")
	NEW DAILY SET DAILY=+$GET(CONF("server","log","access","daily"),1)
	NEW MAXB SET MAXB=+$GET(CONF("server","log","access","maxBytes"),10485760)
	NEW DAY SET DAY=$SELECT(DAILY:$$DAY(),1:"")
	; If the log base path changes within the same job (common in tests),
	; reset rotation state so we don't incorrectly continue prior suffix/bytes.;
	NEW CURBASE SET CURBASE=$GET(^TMP($J,"MIOLOG","A","base"))
	IF CURBASE'=BASE DO
	. SET ^TMP($J,"MIOLOG","A","base")=BASE
	. SET ^TMP($J,"MIOLOG","A","day")=DAY
	. SET ^TMP($J,"MIOLOG","A","sfx")=0
	. SET ^TMP($J,"MIOLOG","A","bytes")=0
	; daily boundary resets rotation state
	IF DAILY,$GET(^TMP($J,"MIOLOG","A","day"))'=DAY DO
	. SET ^TMP($J,"MIOLOG","A","day")=DAY
	. SET ^TMP($J,"MIOLOG","A","sfx")=0
	. SET ^TMP($J,"MIOLOG","A","bytes")=0
	NEW SFX SET SFX=+$GET(^TMP($J,"MIOLOG","A","sfx"))
	NEW BYTES SET BYTES=+$GET(^TMP($J,"MIOLOG","A","bytes"))
	NEW FP SET FP=$$FPATH(BASE,DAY,SFX,DAILY)
	NEW BASEFP SET BASEFP=$$FPATH(BASE,DAY,0,DAILY)
	NEW DEV SET DEV=FP
	NEW CACHE SET CACHE=$$FHCACHE(.CONF)
	NEW OIO SET OIO=$IO
	NEW OKOPEN SET OKOPEN=1
	IF CACHE SET OKOPEN=$$FHOPEN(.CONF,DEV)
	ELSE  SET OKOPEN=$$OPENA(DEV)
	IF 'OKOPEN DO SETERR(.ERR,"open_failed",FP) USE OIO QUIT 0
	USE DEV
	NEW I SET I=0
	FOR  SET I=$ORDER(^TMP($J,"MIOLOG","A","Q",I)) QUIT:I=""  DO  IF $DATA(ERR) QUIT
	. NEW L SET L=$GET(^TMP($J,"MIOLOG","A","Q",I))
	. NEW WLEN SET WLEN=$L(L)+1
	. IF MAXB>0,BYTES>0,(BYTES+WLEN)>MAXB DO
	. . IF CACHE DO FHCLOSE(.CONF) ELSE  CLOSE DEV
	. . SET SFX=SFX+1,BYTES=0
	. . SET FP=$$FPATH(BASE,DAY,SFX,DAILY),DEV=FP
	. . IF CACHE DO
	. . . IF '$$FHOPEN(.CONF,DEV) DO SETERR(.ERR,"open_failed",FP) QUIT
	. . ELSE  DO
	. . . IF '$$OPENA(DEV) DO SETERR(.ERR,"open_failed",FP) QUIT
	. . USE DEV
	. WRITE L,$CHAR(10)
	. SET BYTES=BYTES+WLEN
	IF 'CACHE CLOSE DEV
	IF 'CACHE,SFX>0 DO SAFECLOSE(BASEFP)
	IF CACHE SET ^TMP($J,"MIOLOG","FH","access","last")=$$HSEC()
	USE OIO
	IF $DATA(ERR) QUIT 0
	SET ^TMP($J,"MIOLOG","A","sfx")=SFX
	SET ^TMP($J,"MIOLOG","A","bytes")=BYTES
	DO QCLR
	QUIT 1
	;
AEN(CONF)
	QUIT +$GET(CONF("server","log","access","enabled"),0)
	;
FHCACHE(CONF)
	; 1=enabled, 0=disabled (strict cap: only one open handle per job)
	NEW X SET X=+$GET(CONF("server","log","access","fhCache"),1)
	QUIT $SELECT(X>0:1,1:0)
	;
HSEC()
	NEW H SET H=$HOROLOG
	QUIT ($PIECE(H,",",1)*86400)+$PIECE(H,",",2)
	;
FHCLOSEIDLE(CONF)
	IF '$$FHCACHE(.CONF) QUIT
	NEW IDLE SET IDLE=+$GET(CONF("server","log","access","fhIdleSeconds"),5)
	IF IDLE<1 QUIT
	NEW LAST SET LAST=+$GET(^TMP($J,"MIOLOG","FH","access","last"))
	IF LAST<1 QUIT
	IF ($$HSEC()-LAST)>IDLE DO FHCLOSE(.CONF)
	QUIT
	;
FHOPEN(CONF,FP)
	; Ensure the access log device is open and cached for this job.;
	DO FHCLOSEIDLE(.CONF)
	NEW CUR SET CUR=$GET(^TMP($J,"MIOLOG","FH","access","fp"))
	IF CUR=FP,$GET(^TMP($J,"MIOLOG","FH","access","ok"))=1 DO  QUIT 1
	. SET ^TMP($J,"MIOLOG","FH","access","last")=$$HSEC()
	IF CUR'="" DO FHCLOSE(.CONF)
	IF '$$OPENA(FP) QUIT 0
	SET ^TMP($J,"MIOLOG","FH","access","fp")=FP
	SET ^TMP($J,"MIOLOG","FH","access","ok")=1
	SET ^TMP($J,"MIOLOG","FH","access","last")=$$HSEC()
	QUIT 1
	;
FHCLOSE(CONF)
	NEW FP SET FP=$GET(^TMP($J,"MIOLOG","FH","access","fp"))
	IF FP="" KILL ^TMP($J,"MIOLOG","FH","access") QUIT
	NEW $ETRAP,$ESTACK,$ET,$ES
	SET $ETRAP="DO CLSTRAP^MIOLOG"
	CLOSE FP
	KILL ^TMP($J,"MIOLOG","FH","access")
	QUIT
	;
CLSTRAP ; internal: close error trap helper
	SET $ECODE=""
	KILL ^TMP($J,"MIOLOG","FH","access")
	QUIT
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
	; Public: close any cached access log handle for this job.;
	DO FHCLOSE(.CONF)
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