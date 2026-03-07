MIOTPLW ; Template dev watcher. Tracks file changes for fast reload.;
; API STABILITY
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; Purpose
; Template dev watcher. Tracks file changes for fast reload.;
;
; Responsibilities
; - Render templates safely.;
; - Escape HTML by default.;
; - Bound recursion and depth.;
; - Cache compiled templates.;
;
; Entry Points
; - START
; - LOOP
; - SCAN
; - HASHFILE
;
; Globals Used
; - ^MIO("TPL","FS",...)
;
; Notes
; Keep comments short.;
; Do not log secrets.;
;
	;
	; Dev-only template watch mode:
	;   - Runs off the request path to avoid hashing templates per request.;
	;   - Periodically scans templateDir for matching patterns.;
	;   - Computes H32 hash (same as MIOTPL) and stores:
	;       ^MIO("TPL","FS",fullpath,"H")=<hash>
	;       ^MIO("TPL","FS",fullpath,"TS")=<seconds since epoch>
	;
	; Rendering path (MIOTPL) compares cached token hash to FS hash.;
	; If equal, it uses cached tokens without re-reading the file.;
	;
	; NOTE: This is a polling watcher (portable). For production, leave disabled.;
	;
; Entry point
; See docs/routines for details.;
START(CONF)
	NEW EN 
	SET EN=$S($GET(CONF("templates","devWatchEnabled"))="true":1,1:+$GET(CONF("templates","devWatchEnabled")))
	IF 'EN QUIT
	NEW DIR SET DIR=$GET(CONF("server","templateDir")) IF DIR="" SET DIR="templates"
	NEW INT SET INT=+$GET(CONF("templates","devWatchIntervalSeconds")) IF INT<1 SET INT=2
	; fire watcher in background
	JOB LOOP^MIOTPLW(DIR,INT)
	QUIT
	;
; Entry point
; See docs/routines for details.;
LOOP(DIR,INT)
	NEW STOP SET STOP=0
	FOR  DO  QUIT:STOP
	. IF $GET(^MIO("CTL","STOP"))=1 SET STOP=1 QUIT
	. DO SCAN(DIR)
	. HANG INT
	QUIT
	;
; Entry point
; See docs/routines for details.;
SCAN(DIR)
	NEW PATS,PI,PAT,F
	KILL PATS
	; patterns from config if available
	MERGE PATS=^MIO("CONF","templates","precompilePatterns")
	IF '$DATA(PATS) DO
	. SET PATS(1)="*.html",PATS(2)="*.tpl"
	NEW NOW SET NOW=$$EPOCH^MIOUTIL()
	SET PI=0
	FOR  SET PI=$ORDER(PATS(PI)) QUIT:PI=""  DO
	. SET PAT=$GET(PATS(PI)) QUIT:PAT=""
	. SET F=$ZSEARCH(DIR_"/"_PAT)
	. FOR  QUIT:F=""  DO
	. . DO HASHFILE(F,NOW)
	. . SET F=$ZSEARCH("")
	QUIT
	;
; Entry point
; See docs/routines for details.;
HASHFILE(FP,NOW)
	NEW TXT,ERR,OK,H
	SET ERR=""
	SET OK=$$READFILE^MIOTPL(FP,.TXT,.ERR) IF 'OK QUIT
	SET H=$$H32^MIOTPL(TXT)
	SET ^MIO("TPL","FS",FP,"H")=H
	SET ^MIO("TPL","FS",FP,"TS")=NOW
	QUIT
	;