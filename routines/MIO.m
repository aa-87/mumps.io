MIO ; Routine for the MIO web server package.;
; API STABILITY 
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; Purpose
; Routine for the MIO web server package.;
;
; Responsibilities
; - Provide routine functionality.;
;
; Entry Points
; - start
; - stop
; - version 
;
; Notes
; Keep comments short.;
; Do not log secrets.;
;
	; Generated V1-01 (YottaDB)
	;
; Entry point
; See docs/routines for details.;
start(PORT) ; start^MIO
	NEW CONF S PORT=$G(PORT)
	DO INIT(.CONF)
	S CONF("server","version")="0.1.0"
	S CONF("server","process","workers")=999999
	S CONF("server","timeouts","handlerMaxMs")=60000
	S CONF("server","name")="efuzy-public"
	S CONF("server","http","keepAlive")="true"
	S CONF("server","errors","enabled")=0
	S CONF("server","keepAlive","enabled")=1
	S CONF("server","keepAlive","maxRequests")=999999
	S CONF("server","keepAlive","idleSeconds")=60
	S CONF("server","timeouts","readHeaderMs")=60
	S CONF("server","timeouts","readBodyMs")=60
	S CONF("server","metrics","enabled")=0
	S CONF("server","rate","enabled")=0
	DO START^MIOD(.CONF,PORT)
	QUIT
	;
BOOTCONF(CONF)
	NEW PATH
	KILL CONF
	SET PATH=$$GETCONF^MIOCONF()
	DO LOAD^MIOCONF(PATH,.CONF)
	;
	; Apply defaults only when missing.;
	IF $GET(CONF("auth","enabled"))="" SET CONF("auth","enabled")=1
	IF $GET(CONF("auth","protectMode"))="" SET CONF("auth","protectMode")="prefix"
	IF '$DATA(CONF("auth","protect","prefix")) DO
	. SET CONF("auth","protect","prefix",1)="/api/"
	. SET CONF("auth","protect","prefix",2)="/admin/"
	. SET CONF("auth","protect","prefix",3)="/metrics"
	. SET CONF("auth","protect","prefix",4)="/debug/"
	IF $GET(CONF("server","errors","enabled"))="" SET CONF("server","errors","enabled")=1
	IF $GET(CONF("server","errors","maxEntries"))="" SET CONF("server","errors","maxEntries")=2000
	IF $GET(CONF("server","errors","capture4xx"))="" SET CONF("server","errors","capture4xx")=1
	IF $GET(CONF("server","errors","capture404"))="" SET CONF("server","errors","capture404")=1
	DO SYNCCONF(.CONF)
	QUIT
	;
SYNCCONF(CONF)
	KILL ^MIO("CONF")
	MERGE ^MIO("CONF")=CONF
	QUIT
	;
INIT(CONF)
	DO BOOTCONF(.CONF)
	DO INIT^MIOROUTE
	DO START^MIOTPL(.CONF)
	DO REG^MIODEMO(.CONF)
	DO REG^MIORP(.CONF)
	DO REG^MIOPUBAPI(.CONF)
	DO REG^MIOPUBADM(.CONF)
	DO REG^MIOREGAPI(.CONF)	
	DO REG^MIOREGADM(.CONF)
	DO REG^MIOMOS(.CONF)
	DO REG^MIOPLGD(.CONF)
	DO REG^MIOSTATIC(.CONF)
	DO REG^MIOHEALTH(.CONF)
	DO REG^MIOERRC(.CONF)
	DO REG^MIOOS(.CONF)
	DO COMPILE^MIOROUTE
	DO SYNCCONF(.CONF)
	DO START^MIOCLEAN(.CONF)
	QUIT
	;
; Entry point
; See docs/routines for details.;
stop ; stop^MIO
	D STOP^MIOD
	SET ^MIO("CTL","STOP")=1
	WRITE "stop requested",!
	QUIT
; Entry point
; See docs/routines for details.;
version ; version^MIO
	WRITE "mws 0.1.0",!
	QUIT
	;
GetRoutineList(routine,result)
	N %ZR K result,%ZR
	do SILENT^%RSEL(routine,"CALL")
	M result=%ZR
	K %ZR
	Q
	;
link
	N R,RTN
	D GetRoutineList("MIO*",.R)
	N A S A="" F  S A=$O(R(A)) Q:A=""  D
	. S RTN=A
	. I $E(RTN)="%" S $E(RTN)="_"
	. W !,"ZL " ZL RTN_".m" W RTN_".m"
	Q
linkui
	N R,RTN
	D GetRoutineList("MIOUI*",.R)
	N A S A="" F  S A=$O(R(A)) Q:A=""  D
	. S RTN=A
	. I $E(RTN)="%" S $E(RTN)="_"
	. W !,"ZL " ZL RTN_".m" W RTN_".m"
	Q
	;	
	;
RESETMIOMOS
	K ^MIO("MIOMOS","USER")
	K ^MIO("MIOMOS","AUTH")
	D INIT^MIOMOS(.CONF)
	D REG^MIOMOS(.CONF)
	;
	Q