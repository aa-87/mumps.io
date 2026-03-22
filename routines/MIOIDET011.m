MIOIDET011 ; MIOIDE websocket debugger protocol tests
	D START Q
	;
START(FAIL)
	N TOP,LOCAL
	S TOP='$D(FAIL),LOCAL=0
	D T001(.LOCAL)
	I TOP D  Q
	. I 'LOCAL W !,"OK - MIOIDET011"
	I LOCAL S FAIL=1
	Q
	;
T001(FAIL)
	N CMD,ARG,JSON,CONF,ERR,OK,RES,SNAP
	D PAYLOAD^MIOIDEDBGP("{""cmd"":""toggle_breakpoint"",""routine"":""MIOIDE"",""line"":2}",.CMD,.ARG)
	D EQ^MIOIDET000(.FAIL,"[T001][cmd]",CMD,"toggle_breakpoint")
	D EQ^MIOIDET000(.FAIL,"[T001][routine]",$G(ARG("routine")),"MIOIDE")
	D EQ^MIOIDET000(.FAIL,"[T001][line]",+$G(ARG("line")),2)
	D RESETDBG^MIOIDET000
	D CONFDEF^MIOIDE(.CONF)
	S CONF("mioide","routineDir")="tmp"
	S OK=$$SAVETEXT^MIOIDED("MIOIDBGX3","MIOIDBGX3 ; dbg fixture"_$C(10)_" Q",.CONF,.ERR)
	D TRUE^MIOIDET000(.FAIL,"[T001][save]",OK)
	S OK=$$START^MIOIDEDBG(.CONF,"MIOIDBGX3","","cli-3",.RES)
	D TRUE^MIOIDET000(.FAIL,"[T001][start]",OK)
	N OK S OK=$$SNAP^MIOIDEDBG($G(RES("sid")),.CONF,.SNAP)
	D PUBLISH^MIOIDEDBGP($G(RES("sid")),"hello",.CONF,.SNAP,.JSON)
	D HAS^MIOIDET000(.FAIL,"[T001][json type]",JSON,"""type"":""hello""")
	D HAS^MIOIDET000(.FAIL,"[T001][json sid]",JSON,$G(RES("sid")))
	Q
	;
	;