MIOLOG ; Structured logging with enforced redaction.
; API STABILITY
; Public API labels are documented in docs/routines.
; Undocumented labels are internal.
;
; Purpose
; Structured logging with enforced redaction.
;
; Responsibilities
; - Collect operational data.
; - Export metrics.
; - Enforce retention policies.
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
; Keep comments short.
; Do not log secrets.
;
 ; Generated V1-01 (YottaDB)
 ;
; Entry point
; See docs/routines for details.
INFO(EVT,CTX) DO EMIT("info",EVT,.CTX) QUIT
; Entry point
; See docs/routines for details.
WARN(EVT,CTX) DO EMIT("warn",EVT,.CTX) QUIT
; Entry point
; See docs/routines for details.
ERROR(EVT,CTX) DO EMIT("error",EVT,.CTX) QUIT
; Entry point
; See docs/routines for details.
PANIC(EVT,CTX) DO EMIT("panic",EVT,.CTX) QUIT

; Entry point
; See docs/routines for details.
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

; Entry point
; See docs/routines for details.
REDACT(REC)
    IF $DATA(REC("ctx","req","hdr")) DO
    . NEW K SET K=""
    . FOR  SET K=$ORDER(REC("ctx","req","hdr",K)) QUIT:K=""  DO
    . . IF $$ISREDACT(K) SET REC("ctx","req","hdr",K)="[REDACTED]"
    IF $DATA(REC("ctx","req","query")) DO
    . NEW K SET K=""
    . FOR  SET K=$ORDER(REC("ctx","req","query",K)) QUIT:K=""  SET REC("ctx","req","query",K)="[REDACTED]"
    QUIT

; Entry point
; See docs/routines for details.
ISREDACT(K)
    SET K=$$LOW(K)
    IF K="authorization" QUIT 1
    IF K="cookie" QUIT 1
    IF K="set-cookie" QUIT 1
    IF K="x-api-key" QUIT 1
    QUIT 0

; Entry point
; See docs/routines for details.
LOW(S)
    NEW I,C,OUT SET OUT=""
    FOR I=1:1:$LENGTH(S) DO
    . SET C=$ASCII($EXTRACT(S,I))
    . IF C>64,C<91 SET C=C+32
    . SET OUT=OUT_$CHAR(C)
    QUIT OUT
