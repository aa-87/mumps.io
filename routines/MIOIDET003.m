MIOIDET003 ; MIOIDE websocket and terminal tests
	D START Q
	;
START(FAIL)
	N TOP,LOCAL
	S TOP='$D(FAIL),LOCAL=0
	D T001(.LOCAL)
	D T010(.LOCAL)
	D T020(.LOCAL)
	D T030(.LOCAL)
	I TOP D  Q
	. I 'LOCAL W !,"OK - MIOIDET003"
	I LOCAL S FAIL=1
	Q
	;
T001(FAIL)
	N REQ,EV
	S REQ("hdr","x-mioide-client")="clientA"
	D PUBREQ^MIOIDEWS(.REQ,"save","MIOIDE","saved","Routine saved",.REQ)
	D TRUE^MIOIDET000(.FAIL,"[T001][queue next]",$$NEXTEV^MIOIDEWS("clientA",0,.EV))
	D EQ^MIOIDET000(.FAIL,"[T001][type]",$G(EV("type")),"save")
	D EQ^MIOIDET000(.FAIL,"[T001][routine]",$G(EV("routine")),"MIOIDE")
	Q
	;
T010(FAIL)
	N ERR,CONF
	D CONFDEF^MIOIDE(.CONF)
	D TRUE^MIOIDET000(.FAIL,"[T010][safe help]",$$TERMSAFE^MIOIDEWS("W !,1",.CONF,.ERR))
	K ERR
	D EQ^MIOIDET000(.FAIL,"[T010][block read]",$$TERMSAFE^MIOIDEWS("READ X",.CONF,.ERR),0)
	D EQ^MIOIDET000(.FAIL,"[T010][block err]",$G(ERR("error")),"command_not_allowed")
	Q
	;
T020(FAIL)
	N OBJ,ERR
	D PARSE^MIOIDEWS("{""cmd"":""ping"",""clientId"":""abc123""}",.OBJ,.ERR)
	D TRUE^MIOIDET000(.FAIL,"[T020][parse ok]",'$D(ERR))
	D EQ^MIOIDET000(.FAIL,"[T020][cmd]",$G(OBJ("cmd")),"ping")
	D EQ^MIOIDET000(.FAIL,"[T020][client]",$G(OBJ("clientId")),"abc123")
	Q
	;
T030(FAIL)
	N S,CONF,OPC,MSG,ERR
	D CONFDEF^MIOIDE(.CONF)
	D INITSTATE^MIOWS(.S,.CONF)
	D EQ^MIOIDET000(.FAIL,"[T030][state timeout]",+$G(S("to")),+$G(CONF("websocket","idleTimeoutSeconds"),3600))
	D EQ^MIOIDET000(.FAIL,"[T030][frag]",+$G(S("frag")),0)
	Q
	;