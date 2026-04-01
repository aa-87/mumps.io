MIOOSPIPE ; MIOOS terminal wrapper over tested MIOMOSTPIPE
	QUIT
	;
OPEN(STATE,CONF,TERMID,OUT,ERR)
	NEW MCONF
	KILL OUT,ERR
	SET ERR("routine")="MIOOSPIPE"
	DO MAPCONF(.CONF,.MCONF)
	IF '$$OPEN^MIOMOSTPIPE(.STATE,.MCONF,$GET(TERMID),.OUT,.ERR) DO  QUIT 0
	. SET ERR("routine")="MIOOSPIPE"
	QUIT 1
	;
ATTACH(STATE,TERMID,OUT,ERR)
	KILL OUT,ERR
	SET ERR("routine")="MIOOSPIPE"
	IF '$$ATTACH^MIOMOSTPIPE(.STATE,$GET(TERMID),.OUT,.ERR) DO  QUIT 0
	. SET ERR("routine")="MIOOSPIPE"
	QUIT 1
	;
INPUT(STATE,TERMID,DATA,OUT,ERR)
	KILL OUT,ERR
	SET ERR("routine")="MIOOSPIPE"
	IF '$$INPUT^MIOMOSTPIPE(.STATE,$GET(TERMID),$GET(DATA),.OUT,.ERR) DO  QUIT 0
	. SET ERR("routine")="MIOOSPIPE"
	QUIT 1
	;
POLL(STATE,TERMID,OUT,ERR)
	KILL OUT,ERR
	SET ERR("routine")="MIOOSPIPE"
	IF '$$POLL^MIOMOSTPIPE(.STATE,$GET(TERMID),.OUT,.ERR) DO  QUIT 0
	. SET ERR("routine")="MIOOSPIPE"
	QUIT 1
	;
RESIZE(STATE,TERMID,COLS,ROWS,OUT,ERR)
	KILL OUT,ERR
	SET ERR("routine")="MIOOSPIPE"
	IF '$$RESIZE^MIOMOSTPIPE(.STATE,$GET(TERMID),+$GET(COLS),+$GET(ROWS),.OUT,.ERR) DO  QUIT 0
	. SET ERR("routine")="MIOOSPIPE"
	QUIT 1
	;
CLOSE(STATE,TERMID,OUT,ERR)
	KILL OUT,ERR
	SET ERR("routine")="MIOOSPIPE"
	IF '$$CLOSE^MIOMOSTPIPE(.STATE,$GET(TERMID),.OUT,.ERR) DO  QUIT 0
	. SET ERR("routine")="MIOOSPIPE"
	QUIT 1
	;
MAPCONF(CONF,MCONF)
	MERGE MCONF=CONF
	IF $GET(MCONF("miomos","terminal","enabled"))="" SET MCONF("miomos","terminal","enabled")=1
	IF $GET(MCONF("miomos","terminal","pipe","enabled"))="" SET MCONF("miomos","terminal","pipe","enabled")=1
	IF $GET(MCONF("miomos","terminal","pipe","command"))="" SET MCONF("miomos","terminal","pipe","command")=$$CMD(.CONF)
	IF $GET(MCONF("miomos","terminal","pipe","shell"))="" SET MCONF("miomos","terminal","pipe","shell")=$$SHELL(.CONF)
	IF $GET(MCONF("miomos","terminal","pipe","readLimit"))="" SET MCONF("miomos","terminal","pipe","readLimit")=$$READLIM(.CONF)
	IF $GET(MCONF("miomos","terminal","pipe","readPolls"))="" SET MCONF("miomos","terminal","pipe","readPolls")=$$READPOLLS(.CONF)
	IF $GET(MCONF("miomos","terminal","pipe","drainPause"))="" SET MCONF("miomos","terminal","pipe","drainPause")=$$DRAINPAUSE(.CONF)
	IF $GET(MCONF("miomos","terminal","pipe","sessionIdleSeconds"))="" SET MCONF("miomos","terminal","pipe","sessionIdleSeconds")=$$IDLE(.CONF)
	IF $GET(MCONF("miomos","terminal","pipe","reconnectGraceSeconds"))="" SET MCONF("miomos","terminal","pipe","reconnectGraceSeconds")=$$GRACE(.CONF)
	IF $GET(MCONF("miomos","terminal","default","fontFamily"))="" SET MCONF("miomos","terminal","default","fontFamily")=$GET(CONF("mioos","terminal","default","fontFamily"),"Consolas")
	IF $GET(MCONF("miomos","terminal","default","fontSize"))="" SET MCONF("miomos","terminal","default","fontSize")=+$GET(CONF("mioos","terminal","default","fontSize"),14)
	IF $GET(MCONF("miomos","terminal","default","cursorBlink"))="" SET MCONF("miomos","terminal","default","cursorBlink")=+$GET(CONF("mioos","terminal","default","cursorBlink"),1)
	IF $GET(MCONF("miomos","terminal","default","cursorStyle"))="" SET MCONF("miomos","terminal","default","cursorStyle")=$GET(CONF("mioos","terminal","default","cursorStyle"),"block")
	IF $GET(MCONF("miomos","terminal","default","scrollback"))="" SET MCONF("miomos","terminal","default","scrollback")=+$GET(CONF("mioos","terminal","default","scrollback"),2500)
	IF $GET(MCONF("miomos","terminal","default","renderer"))="" SET MCONF("miomos","terminal","default","renderer")=$GET(CONF("mioos","terminal","default","renderer"),"canvas")
	IF $GET(MCONF("miomos","terminal","default","unicode"))="" SET MCONF("miomos","terminal","default","unicode")=$GET(CONF("mioos","terminal","default","unicode"),"unicode11")
	IF $GET(MCONF("miomos","terminal","default","rows"))="" SET MCONF("miomos","terminal","default","rows")=$$ROWS(+$GET(CONF("mioos","terminal","default","rows"),28))
	IF $GET(MCONF("miomos","terminal","default","cols"))="" SET MCONF("miomos","terminal","default","cols")=$$COLS(+$GET(CONF("mioos","terminal","default","cols"),112))
	QUIT
	;
CMD(CONF)
	NEW X,D
	SET X=$$TRIM^MIOUTIL($GET(CONF("mioos","terminal","pipe","command")))
	IF X'="" QUIT X
	SET D=$$TRIM^MIOUTIL($ZTRNLNM("ydb_dist"))
	IF D'="" QUIT D_"/yottadb -direct"
	QUIT "yottadb -direct"
	;
SHELL(CONF)
	NEW X
	SET X=$$TRIM^MIOUTIL($GET(CONF("mioos","terminal","pipe","shell")))
	IF X'="" QUIT X
	QUIT "/bin/sh"
	;
READLIM(CONF)
	NEW N
	SET N=+$GET(CONF("mioos","terminal","pipe","readLimit"),16384)
	IF N<1024 SET N=16384
	QUIT N
	;
READPOLLS(CONF)
	NEW N
	SET N=+$GET(CONF("mioos","terminal","pipe","readPolls"),8)
	IF N<1 SET N=8
	QUIT N
	;
DRAINPAUSE(CONF)
	NEW N
	SET N=+$GET(CONF("mioos","terminal","pipe","drainPause"),.04)
	IF N'>0 SET N=.04
	QUIT N
	;
GRACE(CONF)
	NEW N
	SET N=+$GET(CONF("mioos","terminal","pipe","reconnectGraceSeconds"),180)
	IF N<30 SET N=180
	QUIT N
	;
IDLE(CONF)
	NEW N
	SET N=+$GET(CONF("mioos","terminal","pipe","sessionIdleSeconds"),900)
	IF N<60 SET N=900
	QUIT N
	;
ROWS(N)
	IF N<20 QUIT 28
	IF N>60 QUIT 28
	QUIT N
	;
COLS(N)
	IF N<80 QUIT 112
	IF N>220 QUIT 112
	QUIT N
	;
