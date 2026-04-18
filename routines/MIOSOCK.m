MIOSOCK ; Socket device helpers for read and write with timeouts.;
; API STABILITY
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; Purpose
; Socket device helpers for read and write with timeouts.;
;
; Responsibilities
; - Enforce request lifecycle.;
; - Keep work bounded.;
; - Fail safely.;
;
; Entry Points
; - LISTEN
; - LERR
; - WAIT
; - SETSOCK
; - READLN
; - READN
; - WRITE
; - CLOSE
;
; Notes
; Keep comments short.;
; Do not log secrets.;
;
	; Generated V1-01 (YottaDB)
	;
; Entry point
; See docs/routines for details.;
	;
	;
LISTEN(PORT,DEV,ERR) 
	NEW D SET D="SCK$"_PORT
	KILL ERR
	OPEN D:(ZLISTEN=PORT_":TCP":ATTACH="SERVER":IOERROR="T":EXCEPTION="GOTO LERR"):15:"socket"
	USE D:(DELIM=$C(13,10):ZBFSIZE=65536:ZIBFSIZE=65536:CHSET="M")
	SET DEV=D
	QUIT 1
; Entry point
; See docs/routines for details.;
LERR ;
	SET ERR("error")="listen_failed",ERR("port")=PORT,ERR("device")=D
	QUIT 0
	;
; Entry point
; See docs/routines for details.;
WAIT(DEV,TIMEOUT,KEY)
	USE DEV WRITE /WAIT(TIMEOUT)
	SET KEY=$KEY
	QUIT
	;
DETACH(DEV,HANDLE)
	U DEV:(DETACH=HANDLE)
	Q
; Entry point
; See docs/routines for details.;
SETSOCK(DEV,HANDLE)
	USE DEV:(SOCKET=HANDLE:CHSET="M")
	QUIT
	;
; Entry point
; See docs/routines for details.;
READLN(DEV,TO,OUT)
	USE DEV:(DELIM=$C(13,10):CHSET="M")
	USE DEV READ OUT:TO
	QUIT
	;
; Entry point
; See docs/routines for details.;
READN(DEV,N,TO,OUT)
	USE DEV:(NODELIM:CHSET="M":ZBFSIZE=N:ZIBFSIZE=N)
	READ OUT#N:TO
	USE DEV:(DELIM=$C(13,10):CHSET="M")
	QUIT
	;
; Entry point
; See docs/routines for details.;
READNWSCHNK(DEV,N,TO,OUT)
	USE DEV:(NODELIM:CHSET="M":ZBFSIZE=65536:ZIBFSIZE=65536)
	READ OUT#N:TO
	QUIT
	;
; Entry point
; See docs/routines for details.;
READNWS(DEV,N,TO,OUT)
	USE DEV:(NODELIM:CHSET="M":ZBFSIZE=65536:ZIBFSIZE=65536)
	N C,CH S C=0,OUT=$G(OUT) USE DEV FOR  READ *CH:TO S OUT=OUT_$C(CH),C=C+1 QUIT:C>=N
	QUIT
; Entry point
; See docs/routines for details.;
WRITE(DEV,S)
	USE DEV:(CHSET="M") WRITE S
	QUIT
	;
; Entry point
; See docs/routines for details.;
CLOSE(DEV)
	CLOSE DEV
	QUIT 
	;