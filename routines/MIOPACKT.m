MIOPACKT ; Tests for MIOPACK middleware packs ; 2026-03-05
	; Quiet on success. Uses MIOTASSERT.;
	;
	;
START
	DO T001
	DO T002
	DO T003
	DO T004
	QUIT
	;
T001 ; standard pack populates lists deterministically when empty
	;NEW CONF,ERR
	KILL CONF
	SET CONF("server","packs","enabled","standard")=1
	DO OK^MIOTASSERT($$APPLY^MIOPACK(.CONF,.ERR)=1,"[T001][apply ok]")
	DO EQ^MIOTASSERT($GET(CONF("server","middleware","before",1)),"CORSB^MIOMW","[T001][b1]")
	DO EQ^MIOTASSERT($GET(CONF("server","middleware","before",2)),"SECB^MIOMW","[T001][b2]")
	DO EQ^MIOTASSERT($GET(CONF("server","middleware","before",3)),"AUTHB^MIOMW","[T001][b3]")
	DO EQ^MIOTASSERT($GET(CONF("server","middleware","before",4)),"LOGB^MIOMW","[T001][b4]")
	DO EQ^MIOTASSERT($GET(CONF("server","middleware","after",1)),"CORSA^MIOMW","[T001][a1]")
	DO EQ^MIOTASSERT($GET(CONF("server","middleware","after",2)),"SECA^MIOMW","[T001][a2]")
	DO EQ^MIOTASSERT($GET(CONF("server","middleware","after",3)),"LOGA^MIOMW","[T001][a3]")
	QUIT
	;
T002 ; merge mode does not duplicate existing entries
	NEW CONF,ERR
	KILL CONF
	; user already configured some
	SET CONF("server","middleware","before",1)="CORSB^MIOMW"
	SET CONF("server","middleware","before",2)="AUTHB^MIOMW"
	SET CONF("server","middleware","after",1)="LOGA^MIOMW"
	SET CONF("server","packs","enabled","standard")=1
	DO OK^MIOTASSERT($$APPLY^MIOPACK(.CONF,.ERR)=1,"[T002][apply ok]")
	; ensure AUTHB appears only once
	NEW I,C SET (I,C)=0
	FOR  SET I=$ORDER(CONF("server","middleware","before",I)) QUIT:'I  DO
	. IF $GET(CONF("server","middleware","before",I))="AUTHB^MIOMW" SET C=C+1
	DO EQ^MIOTASSERT(C,1,"[T002][no dup AUTHB]")
	QUIT
	;
T003 ; replace mode wipes and sets from pack
	NEW CONF,ERR
	KILL CONF
	SET CONF("server","packs","mode")="replace"
	SET CONF("server","middleware","before",1)="X^A"
	SET CONF("server","middleware","after",1)="Y^B"
	SET CONF("server","packs","enabled","public_site")=1
	DO OK^MIOTASSERT($$APPLY^MIOPACK(.CONF,.ERR)=1,"[T003][apply ok]")
	DO EQ^MIOTASSERT($GET(CONF("server","middleware","before",1)),"CORSB^MIOMW","[T003][b1]")
	; public_site removes AUTHB
	NEW I,FOUND SET (I,FOUND)=0
	FOR  SET I=$ORDER(CONF("server","middleware","before",I)) QUIT:'I  DO
	. IF $GET(CONF("server","middleware","before",I))="AUTHB^MIOMW" SET FOUND=1
	DO EQ^MIOTASSERT(FOUND,0,"[T003][no auth]")
	QUIT
	;
T004 ; debug pack protects /debug/ and enables errors
	NEW CONF,ERR
	KILL CONF
	SET CONF("server","packs","enabled","debug")=1
	DO OK^MIOTASSERT($$APPLY^MIOPACK(.CONF,.ERR)=1,"[T004][apply ok]")
	DO EQ^MIOTASSERT(+$GET(CONF("server","errors","enabled")),1,"[T004][errors enabled]")
	; verify /debug/ appears in protect prefix list
	NEW I,V,OK SET (I,OK)=0
	FOR  SET I=$ORDER(CONF("auth","protect","prefix",I)) QUIT:'I  DO
	. SET V=$GET(CONF("auth","protect","prefix",I))
	. IF V="/debug/" SET OK=1
	DO EQ^MIOTASSERT(OK,1,"[T004][debug protected]")
	QUIT
	;