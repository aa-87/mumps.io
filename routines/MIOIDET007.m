MIOIDET007 ; MIOIDE ROI 3A websocket and terminal helper coverage
	D START Q
	;
START(FAIL)
	N TOP,LOCAL
	S TOP='$D(FAIL),LOCAL=0
	I $T(REG^MIOIDEWS)="" G DONE
	D T001(.LOCAL)
	D T010(.LOCAL)
	D T020(.LOCAL)
	D T030(.LOCAL)
DONE	I TOP D  Q
	. I 'LOCAL W !,"OK - MIOIDET007"
	I LOCAL S FAIL=1
	Q
	;
T001(FAIL)
	N REQ
	K REQ S REQ("hdr","x-mioide-client")="cli_1"
	D EQ^MIOIDET000(.FAIL,"[T001][client hdr]",$$CLIENT^MIOIDEWS(.REQ),"cli_1")
	K REQ S REQ("query","client")="cli-2"
	D EQ^MIOIDET000(.FAIL,"[T001][client query]",$$CLIENT^MIOIDEWS(.REQ),"cli-2")
	K REQ S REQ("hdr","x-mioide-client")="bad id!"
	D EQ^MIOIDET000(.FAIL,"[T001][client invalid]",$$CLIENT^MIOIDEWS(.REQ),"")
	D TRUE^MIOIDET000(.FAIL,"[T001][safe id]",$$SAFEID^MIOIDEWS("cli-2"))
	D FALSE^MIOIDET000(.FAIL,"[T001][unsafe id]",$$SAFEID^MIOIDEWS("bad id!"))
	Q
	;
T010(FAIL)
	N EV,OUT
	D RESETWS^MIOIDET000
	S EV("type")="save",EV("routine")="MIOIDXT1",EV("status")="saved"
	D PUB^MIOIDEWS("cliA",.EV)
	K OUT
	D TRUE^MIOIDET000(.FAIL,"[T010][next ok]",$$NEXTEV^MIOIDEWS("cliA",0,.OUT))
	D EQ^MIOIDET000(.FAIL,"[T010][seq]",+$G(OUT("seq")),1)
	D EQ^MIOIDET000(.FAIL,"[T010][type]",$G(OUT("type")),"save")
	D EQ^MIOIDET000(.FAIL,"[T010][status]",$G(OUT("status")),"saved")
	Q
	;
T020(FAIL)
	N REQ,DATA,OUT
	D RESETWS^MIOIDET000
	S ^MIO("CONF","mioide","events","retain")=2
	S REQ("hdr","x-mioide-client")="cliB"
	S DATA("output")="line-one"
	D PUBREQ^MIOIDEWS(.REQ,"compile","MIOIDXT1","compiled","ok",.DATA)
	D PUBREQ^MIOIDEWS(.REQ,"run","MIOIDXT1","completed","ok",.DATA)
	D PUBREQ^MIOIDEWS(.REQ,"save","MIOIDXT1","saved","ok",.DATA)
	K OUT
	D TRUE^MIOIDET000(.FAIL,"[T020][trim next]",$$NEXTEV^MIOIDEWS("cliB",0,.OUT))
	D EQ^MIOIDET000(.FAIL,"[T020][first seq]",+$G(OUT("seq")),1)
	D HAS^MIOIDET000(.FAIL,"[T020][output]",$G(OUT("output")),"line-one")
	Q
	;
T030(FAIL)
	N CONF,ERR
	D CONFDEF^MIOIDE(.CONF)
	D TRUE^MIOIDET000(.FAIL,"[T030][safe command]",$$TERMSAFE^MIOIDEWS("S X=1",.CONF,.ERR))
	K ERR
	D FALSE^MIOIDET000(.FAIL,"[T030][blocked command]",$$TERMSAFE^MIOIDEWS("zsystem 1",.CONF,.ERR))
	D EQ^MIOIDET000(.FAIL,"[T030][blocked err]",$G(ERR("error")),"command_not_allowed")
	S CONF("mioide","terminal","allowXecute")=0
	K ERR
	D FALSE^MIOIDET000(.FAIL,"[T030][xecute off]",$$TERMSAFE^MIOIDEWS("S X=1",.CONF,.ERR))
	D EQ^MIOIDET000(.FAIL,"[T030][xecute err]",$G(ERR("error")),"xecute_disabled")
	Q
	;
