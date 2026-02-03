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
	I $D(^MIO("CONF")) M CONF=^NIO("CONF")
	E  D
	. N PATH S PATH=$$GETCONF^MIOCONF()
	. DO LOAD^MIOCONF(PATH,.CONF)	
	. M ^MIO("CONF")=CONF
	DO INIT^MIOROUTE
	DO START^MIOTPL(.CONF)
	DO REG^MIODEMO(.CONF)
	DO REG^MIOMIO(.CONF)
	DO REG^MIORP(.CONF)
	DO REG^MIOPUBAPI(.CONF)
	DO REG^MIOPUBADM(.CONF)
	DO REG^MIOREGAPI(.CONF)	
	DO REG^MIOREGADM(.CONF)
	DO REG^MIOAPP(.CONF)
	;
	DO COMPILE^MIOROUTE
	DO START^MIOCLEAN(.CONF)
	DO START^MIOD(.CONF)
	QUIT
; Entry point
; See docs/routines for details.;
stop ; stop^MIO
	SET ^MIO("CTL","STOP")=1
	WRITE "stop requested",!
	QUIT
; Entry point
; See docs/routines for details.;
version ; version^MIO
	WRITE "mws 0.1.0",!
	QUIT
	;