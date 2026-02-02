MIOTROUTE ; Test routines. Unit and regression coverage for core subsystems.
; API STABILITY
; Public API labels are documented in docs/routines.
; Undocumented labels are internal.
;
; Purpose
; Test routines. Unit and regression coverage for core subsystems.
;
; Responsibilities
; - Validate behavior.
; - Prevent regressions.
;
; Entry Points
; - TROUTE
;
; Notes
; Keep comments short.
; Do not log secrets.
;
 ; Generated V1-01 (YottaDB)
 ;
; Entry point
; See docs/routines for details.
TROUTE ;
    DO INIT^MIOROUTE
    NEW P,H,OK
    SET OK=$$MATCH^MIOROUTE("GET","/api/ping",.P,.H)
    IF 'OK WRITE "FAIL match ping",! HALT 1
    QUIT
