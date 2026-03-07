MIODRAINT ; Graceful shutdown/drain unit tests (deterministic).;
;
; Run:
;   YDB>D ^MIODRAINT
;
START
	DO T001
	DO T002
	DO T003
	QUIT
	;
T001 ; drain flag set + deadline computed
	NEW CONF,REP,OK
	DO RESET^MIODRAIN
	SET CONF("server","process","gracefulShutdownSeconds")=3
	DO REQSTOP^MIODRAIN(.CONF,"test")
	DO EQ^MIOTASSERT($GET(^MIO("CTL","DRAIN")),1,"[T001][drain enabled]")
	DO EQ^MIOTASSERT($GET(^MIO("CTL","DRAIN","reason")),"test","[T001][reason]")
	DO EQ^MIOTASSERT($SELECT(+$GET(^MIO("CTL","DRAIN","deadline_us"))>+$GET(^MIO("CTL","DRAIN","t0us")):1,1:0),1,"[T001][deadline]")
	QUIT
	;
T002 ; active tracking begin/end
	NEW CONF
	DO RESET^MIODRAIN
	DO EQ^MIOTASSERT($$ACTIVE^MIODRAIN(),0,"[T002][active init]")
	DO BEGIN^MIODRAIN(.CONF,"1.2.3.4","h",123)
	DO EQ^MIOTASSERT($$ACTIVE^MIODRAIN(),1,"[T002][active after begin]")
	DO END^MIODRAIN($J)
	DO EQ^MIOTASSERT($$ACTIVE^MIODRAIN(),0,"[T002][active after end]")
	QUIT
	;
T003 ; waitdrain behavior
	NEW OK
	DO RESET^MIODRAIN
	SET OK=$$WAITDRAIN^MIODRAIN(0)
	DO EQ^MIOTASSERT(OK,1,"[T003][wait ok when none]")
	; simulate active
	SET ^MIO("CTL","CONN","active")=1
	SET OK=$$WAITDRAIN^MIODRAIN(0)
	DO EQ^MIOTASSERT(OK,0,"[T003][wait times out]")
	DO RESET^MIODRAIN
	QUIT
	;
