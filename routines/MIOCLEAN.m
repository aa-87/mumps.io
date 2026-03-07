MIOCLEAN ; Cleanup job. Enforces retention and bounds global growth.;
; API STABILITY
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; Purpose
; Cleanup job. Enforces retention and bounds global growth.;
;
; Responsibilities
; - Collect operational data.;
; - Export metrics.;
; - Enforce retention policies.;
;
; Entry Points
; - START
; - RUN
; - MET
; - NOWMIN
;
; Globals Used
; - ^MIO(...)
;
; Notes
; Keep comments short.;
; Do not log secrets.;
;
	; Background cleanup jobs to keep globals bounded.;
	; Focus: metrics window retention and stale metric buffers.;
	;
	; This job is intentionally conservative and low frequency.;
	;
; Entry point
; See docs/routines for details.;
START(CONF)
	; Start cleaner job if metrics enabled
	IF '$GET(CONF("metrics","enabled"),0) QUIT
	; Avoid multiple cleaners
	IF $GET(^MIO("CTL","CLEANER","RUNNING"))=1 QUIT
	SET ^MIO("CTL","CLEANER","RUNNING")=1
	JOB RUN^MIOCLEAN
	QUIT
	;
; Entry point
; See docs/routines for details.;
RUN
	NEW CONF MERGE CONF=^MIO("CONF")
	SET ^MIO("CTL","CLEANER","JOB")=$J
	FOR  QUIT:$GET(^MIO("CTL","STOP"))  DO
	. DO MET^MIOCLEAN(.CONF)
	. HANG $GET(CONF("metrics","cleanupIntervalSeconds"),60)
	SET ^MIO("CTL","CLEANER","RUNNING")=0
	QUIT
	;
; Entry point
; See docs/routines for details.;
MET(CONF)
	; Delete metric window buckets older than retention
	NEW RET SET RET=+$GET(CONF("metrics","retentionMinutes"),180)
	IF RET'>0 QUIT
	NEW NOWMIN SET NOWMIN=$$NOWMIN^MIOCLEAN()
	NEW CUTOFF SET CUTOFF=NOWMIN-RET
	NEW M SET M=0
	FOR  SET M=$ORDER(^MIO("MET","WIN",M)) QUIT:'M  DO  QUIT:M>CUTOFF
	. KILL ^MIO("MET","WIN",M)
	;
	; Delete stale metric buffers (e.g., worker died before flush)
	NEW STALE SET STALE=+$GET(CONF("metrics","staleBufferMinutes"),10)
	IF STALE'>0 QUIT
	NEW NOWUS SET NOWUS=$$TSUS^MIOMET()
	NEW LIMIT SET LIMIT=STALE*60*1000000
	NEW J SET J=""
	FOR  SET J=$ORDER(^MIO("MET","BUF",J)) QUIT:J=""  DO
	. NEW LAST SET LAST=+$GET(^MIO("MET","BUF",J,"LASTUS"))
	. IF LAST=0 QUIT
	. IF (NOWUS-LAST)>LIMIT KILL ^MIO("MET","BUF",J)
	QUIT
	;
; Entry point
; See docs/routines for details.;
NOWMIN()
	NEW H SET H=$HOROLOG
	NEW DAYS,SEC SET DAYS=+$PIECE(H,",",1),SEC=+$PIECE(H,",",2)
	QUIT (DAYS*1440)+(SEC\60)
	;