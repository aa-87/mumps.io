MIOMOSPIPET ; MIOMOS PIPE terminal safe tests
START
	NEW CONF,STATE,ARR,ERR,OUT
	DO CONFDEF^MIOMOS(.CONF)
	SET STATE("principal")="dev-user",STATE("sessionId")="pipe-test-1"
	DO LOAD^MIOMOSSET(.STATE,.CONF)
	DO EQ^MIOTASSERT($GET(CONF("miomos","terminal","pipe","command"))="yottadb -direct",1,"[MIOMOSPIPET][T001][pipe command]")
	DO EQ^MIOTASSERT(+$GET(CONF("miomos","terminal","pipe","readLimit"))>0,1,"[MIOMOSPIPET][T001][pipe read limit]")
	DO EQ^MIOTASSERT(+$GET(CONF("miomos","terminal","pipe","readPolls"))>0,1,"[MIOMOSPIPET][T001][pipe read polls]")
	DO EQ^MIOTASSERT(+$GET(CONF("miomos","terminal","pipe","sessionIdleSeconds"))>0,1,"[MIOMOSPIPET][T001][pipe idle]")
	DO EQ^MIOTASSERT($GET(CONF("miomos","terminal","pipe","shell"))'="",1,"[MIOMOSPIPET][T001][pipe shell]")
	DO CURRENT^MIOMOSSET($GET(STATE("principal")),.ARR)
	DO EQ^MIOTASSERT(+$DATA(ARR("catalog","windowManager","titlebarStyles",1,"key"))>0,1,"[MIOMOSPIPET][T002][titlebar catalog]")
	DO EQ^MIOTASSERT(+$DATA(ARR("catalog","terminal","transport",1,"key"))>0,1,"[MIOMOSPIPET][T002][transport catalog]")
	DO DEFAULTWINS^MIOMOSWM(.OUT,"review")
	DO EQ^MIOTASSERT($GET(OUT(1,"appKey")),"workspace","[MIOMOSPIPET][T003][review layout workspace]")
	DO EQ^MIOTASSERT(+$GET(OUT(6,"width"))>0,1,"[MIOMOSPIPET][T003][review layout terminal]")
	QUIT
