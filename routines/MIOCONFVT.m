MIOCONFVT ; Tests for MIOCONFV config validation
;
; Run:
;   YDB>D ^MIOCONFVT
;
	QUIT
	;
START
	DO T001
	DO T002
	DO T003
	QUIT
	;
T001 ; minimal empty config is ok
	NEW CONF,REP,ERR,OK
	KILL CONF
	SET OK=$$VALIDATE^MIOCONFV(.CONF,.REP,.ERR)
	DO EQ^MIOTASSERT(OK,1,"[T001][ok]")
	DO EQ^MIOTASSERT(+$GET(REP("err_count")),0,"[T001][err_count]")
	QUIT
	;
T002 ; invalid port is error
	NEW CONF,REP,ERR,OK
	KILL CONF
	SET CONF("server","listen","port")=70000
	SET OK=$$VALIDATE^MIOCONFV(.CONF,.REP,.ERR)
	DO EQ^MIOTASSERT(OK,0,"[T002][ok]")
	DO EQ^MIOTASSERT($GET(ERR("routine")),"MIOCONFV","[T002][routine]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"invalid_config","[T002][error]")
	QUIT
	;
T003 ; static enabled without root is error
	NEW CONF,REP,ERR,OK
	KILL CONF
	SET CONF("server","static","enabled")=1
	SET CONF("server","static","root")=""
	SET OK=$$VALIDATE^MIOCONFV(.CONF,.REP,.ERR)
	DO EQ^MIOTASSERT(OK,0,"[T003][ok]")
	QUIT
