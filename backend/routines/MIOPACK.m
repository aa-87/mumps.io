MIOPACK ; Middleware pack registry / presets for MUMPS.IO web server ; 2026-03-05
	; ---------------------------------------------------------------------------
	; Goals:
	; - Provide deterministic, easy-to-enable middleware bundles ("packs") for ops.
	; - Avoid breaking existing explicit middleware configuration.
	; - No ZSYSTEM. No GOTO. Deterministic order. Quiet (no writes).
	;
	; Public:
	;   APPLY(.CONF,.ERR)  - apply enabled packs into CONF("server","middleware",...)
	;   LIST(.CONF,.OUT)   - list enabled packs (names)
	;
	; Configuration:
	;   CONF("server","packs","mode") = "merge" (default) | "replace"
	;   CONF("server","packs","enabled",<name>) = 1
	;
	; Packs (built-in):
	;   standard    - CORS + Security headers + Auth + Logging
	;   public_site - CORS + Security headers + Logging (no auth)
	;   api_strict  - standard + set security preset strict (does not change auth mode)
	;   debug       - ensures /debug/ is protected and errors capture is enabled
	;
	; Notes:
	; - APPLY is safe to call multiple times; MERGE mode dedupes by entryref.
	; - Pack application does not register routes; it only prepares CONF.
	;
	Q
	;
APPLY(CONF,ERR)
	NEW MODE SET MODE=$$LOW($GET(CONF("server","packs","mode")))
	IF MODE="" SET MODE="merge"
	IF MODE'="merge",MODE'="replace" DO  QUIT 0
	. DO ESET(.ERR,"MIOPACK","bad_pack_mode",500)
	;
	NEW P,EN,BEF,AFT SET EN=0
	NEW PB,PA KILL PB,PA
	;
	; gather enabled packs in deterministic lexical order
	SET P=""
	FOR  SET P=$ORDER(CONF("server","packs","enabled",P)) QUIT:P=""  DO
	. IF +$GET(CONF("server","packs","enabled",P))<1 QUIT
	. SET EN=1
	. DO ADDPACK(P,.CONF,.PB,.PA,.ERR)
	. ; ignore unknown packs: ADDPACK will add warning into ERR("warn",...)
	;
	IF 'EN QUIT 1  ; nothing to do
	;
	; apply middleware lists
	DO APPLYMW(.CONF,.PB,.PA,MODE)
	QUIT 1
	;
LIST(CONF,OUT)
	KILL OUT
	NEW P,N SET N=0,P=""
	FOR  SET P=$ORDER(CONF("server","packs","enabled",P)) QUIT:P=""  DO
	. IF +$GET(CONF("server","packs","enabled",P))<1 QUIT
	. SET N=N+1,OUT(N)=P
	QUIT
	;
	; --- Pack definitions ------------------------------------------------------
ADDPACK(NAME,CONF,PB,PA,ERR)
	NEW N SET N=$$LOW($GET(NAME))
	IF N="standard" DO  QUIT
	. DO DEFSTD(.PB,.PA)
	. ; safe defaults (do not override user if already set)
	. IF $GET(CONF("server","security","preset"))="" SET CONF("server","security","preset")="balanced"
	. DO DEFDBG(.CONF) ; standard also wants errors enabled by default
	IF N="public_site" DO  QUIT
	. DO DEFSTD(.PB,.PA)
	. DO REMOVE(.PB,"AUTHB^MIOMW") ; no auth
	. IF $GET(CONF("server","security","preset"))="" SET CONF("server","security","preset")="balanced"
	IF N="api_strict" DO  QUIT
	. DO DEFSTD(.PB,.PA)
	. SET CONF("server","security","preset")="strict"
	. ; encourage prefix protection if unset
	. IF $GET(CONF("auth","protectMode"))="" SET CONF("auth","protectMode")="prefix"
	. IF $DATA(CONF("auth","protect","prefix"))=0 DO
	. . SET CONF("auth","protect","prefix",1)="/api/"
	. . SET CONF("auth","protect","prefix",2)="/admin/"
	. . SET CONF("auth","protect","prefix",3)="/metrics"
	IF N="debug" DO  QUIT
	. DO DEFDBG(.CONF)
	. ; keep /debug protected
	. IF $GET(CONF("auth","protectMode"))="" SET CONF("auth","protectMode")="prefix"
	. IF '$$HASPX(.CONF,"/debug/") DO ADDPX(.CONF,"/debug/")
	;
	; unknown pack -> warning (non-fatal)
	DO WSET(.ERR,"unknown_pack:"_N)
	QUIT
	;
DEFSTD(PB,PA)
	; deterministic base order:
	; before: CORS, SEC, AUTH, LOGB
	; after : CORSA, SECA, LOGA
	DO ADD(.PB,"CORSB^MIOMW")
	DO ADD(.PB,"SECB^MIOMW")
	DO ADD(.PB,"AUTHB^MIOMW")
	DO ADD(.PB,"LOGB^MIOMW")
	DO ADD(.PA,"CORSA^MIOMW")
	DO ADD(.PA,"SECA^MIOMW")
	DO ADD(.PA,"LOGA^MIOMW")
	QUIT
	;
DEFDBG(CONF)
	IF $GET(CONF("server","errors","enabled"))="" SET CONF("server","errors","enabled")=1
	IF $GET(CONF("server","errors","maxEntries"))="" SET CONF("server","errors","maxEntries")=2000
	QUIT
	;
	; --- Apply helpers --------------------------------------------------------
APPLYMW(CONF,PB,PA,MODE)
	NEW B0,A0 SET B0=$$HASMWS(.CONF,"before"),A0=$$HASMWS(.CONF,"after")
	IF MODE="replace" DO
	. KILL CONF("server","middleware","before")
	. KILL CONF("server","middleware","after")
	. DO SETLIST(.CONF,"before",.PB)
	. DO SETLIST(.CONF,"after",.PA)
	. QUIT
	; merge (default): add missing, preserve user order
	IF 'B0 DO SETLIST(.CONF,"before",.PB)
	ELSE  DO MERGELIST(.CONF,"before",.PB)
	IF 'A0 DO SETLIST(.CONF,"after",.PA)
	ELSE  DO MERGELIST(.CONF,"after",.PA)
	QUIT
	;
SETLIST(CONF,WHICH,ARR)
	NEW I,N SET N=0,I=0
	FOR  SET I=$ORDER(ARR(I)) QUIT:'I  DO
	. SET N=N+1,CONF("server","middleware",WHICH,N)=ARR(I)
	QUIT
	;
MERGELIST(CONF,WHICH,ARR)
	; Build set of existing entries
	NEW SET,I S I=0 KILL SET
	FOR  SET I=$ORDER(CONF("server","middleware",WHICH,I)) QUIT:'I  DO
	. NEW E SET E=$GET(CONF("server","middleware",WHICH,I))
	. IF E'="" SET SET(E)=1
	; Append new entries not present
	SET I=0
	FOR  SET I=$ORDER(ARR(I)) QUIT:'I  DO
	. NEW E SET E=ARR(I) IF E="" QUIT
	. IF $DATA(SET(E)) QUIT
	. DO APPEND(.CONF,WHICH,E)
	. SET SET(E)=1
	QUIT
	;
APPEND(CONF,WHICH,ENTRY)
	NEW I SET I=+$ORDER(CONF("server","middleware",WHICH,""),-1)
	SET CONF("server","middleware",WHICH,I+1)=ENTRY
	QUIT
	;
HASMWS(CONF,WHICH)
	NEW I SET I=+$ORDER(CONF("server","middleware",WHICH,0))
	QUIT $SELECT(I>0:1,1:0)
	;
ADD(ARR,ENTRY)
	NEW I SET I=+$ORDER(ARR(""),-1)
	SET ARR(I+1)=ENTRY
	QUIT
	;
REMOVE(ARR,ENTRY)
	NEW I,F SET I=0,F=0
	FOR  SET I=$ORDER(ARR(I)) QUIT:'I  DO  QUIT:F
	. IF $GET(ARR(I))=ENTRY SET F=1 KILL ARR(I)
	QUIT
	;
	; prefix protect list utilities (supports both "protect" and "protect","prefix")
HASPX(CONF,PX)
	NEW I,V,FOUND SET (I,FOUND)=0
	; new layout
	FOR  SET I=$ORDER(CONF("auth","protect","prefix",I)) QUIT:'I  DO  QUIT:FOUND
	. SET V=$GET(CONF("auth","protect","prefix",I))
	. IF V=PX SET FOUND=1
	; old layout
	SET I=0
	FOR  SET I=$ORDER(CONF("auth","protect",I)) QUIT:'I  DO  QUIT:FOUND
	. SET V=$GET(CONF("auth","protect",I))
	. IF V=PX SET FOUND=1
	QUIT FOUND
	;
ADDPX(CONF,PX)
	NEW I SET I=+$ORDER(CONF("auth","protect","prefix",""),-1)
	SET CONF("auth","protect","prefix",I+1)=PX
	QUIT
	;
	; --- Error helpers --------------------------------------------------------
ESET(ERR,RTN,CODE,STATUS)
	KILL ERR
	SET ERR("routine")=RTN
	SET ERR("error")=CODE
	IF $GET(STATUS)'="" SET ERR("status")=+STATUS
	QUIT
WSET(ERR,MSG)
	NEW I SET I=+$ORDER(ERR("warn",""),-1)
	SET ERR("warn",I+1)=MSG
	QUIT
	;
LOW(S) QUIT $ZCONVERT($GET(S),"L")
