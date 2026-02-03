MIOCONF ; Configuration loader and validator.;
; API STABILITY
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; Purpose
; Configuration loader and validator.;
;
; Responsibilities
; - Provide shared helpers.;
; - Keep behavior deterministic.;
;
; Entry Points
; - GETCONF
; - LOAD
; - READALL
; - RCERR
;
; Globals Used
; - ^MIO("CONF",...)
;
; Notes
; Keep comments short.;
; Do not log secrets.;
;
	; Generated V1-01 (YottaDB)
	;
; Entry point
; See docs/routines for details.;
GETCONF() ;
	NEW P
	SET P=$ZTRNLNM("MWS_CONF")
	IF P="" SET P="./config/mws.conf.json"
	QUIT P
; Entry point
; See docs/routines for details.;
LOAD(PATH,OUT) ;
	NEW JSON,ERR,RESULT
	KILL OUT
	D READFILE(PATH,.JSON)
	;IF $DATA(ERR) DO PANIC^MIOLOG("config_read_failed",.ERR) H 1
	;NEW OBJ
	;IF '$$DECODE^MIOJSON(JSON,.OBJ,.ERR) DO PANIC^MIOLOG("config_json_invalid",.ERR) H 1
	;MERGE OUT=JSON
	D DECODE^MIOJSON2("JSON","RESULT")
	M OUT=RESULT
	QUIT
; Entry point
; See docs/routines for details.;
READALL(PATH,ERR) ;
	NEW IO,BUF,LINE
	SET BUF=""
	OPEN PATH:(READONLY:EXCEPTION="GOTO RCERR")
	USE PATH
	FOR  READ LINE QUIT:$ZEOF  SET BUF=BUF_LINE_$CHAR(10)
	CLOSE PATH
	QUIT BUF
; Entry point
; See docs/routines for details.;
RCERR ;
	SET ERR("error")="cannot_open_config",ERR("path")=PATH
	QUIT ""
	;
READFILE(FILE,RETURN)
	N S,L,C,CD
	S S=FILE,CD=$IO
	O S:(READONLY:CHSET="M")
	F  U S R L:5 Q:$ZEOF  Q:'$T  D
	. S RETURN($I(C))=L
	C S u CD
	Q