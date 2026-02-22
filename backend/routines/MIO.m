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
start ; start^MIO
	N PATH S PATH=$$GETCONF^MIOCONF()
	N CONF D LOAD^MIOCONF(PATH,.CONF)
	K ^MIO("CONF") M ^MIO("CONF")=CONF
	DO INIT^MIOROUTE
	DO START^MIOTPL(.CONF)
	DO REG^MIODEMO(.CONF)
	DO REG^MIOMIO(.CONF)
	DO REG^MIORP(.CONF)
	DO REG^MIOPUBAPI(.CONF)
	DO REG^MIOPUBADM(.CONF)
	DO REG^MIOREGAPI(.CONF)	
	DO REG^MIOREGADM(.CONF)
	DO REG^MIOWOW(.CONF)
	DO REG^MIOAPP(.CONF)
	DO COMPILE^MIOROUTE
	DO START^MIOCLEAN(.CONF)
	DO START^MIOD(.CONF)
	QUIT
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