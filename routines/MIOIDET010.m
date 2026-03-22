MIOIDET010 ; MIOIDE ROI 3A failure and cleanup coverage
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
	. I 'LOCAL W !,"OK - MIOIDET010"
	I LOCAL S FAIL=1
	Q
	;
T001(FAIL)
	D RESETIDE^MIOIDET000
	S ^MIO("MIOIDE","DBG","SESSION","S1","status")="paused"
	S ^MIO("MIOIDE","DBG","BP","MIOIDXT1",3)=1
	S ^MIO("MIOIDE","EV","cli",1,"type")="save"
	S ^MIO("ROUTE","RAW","GET","/mioide")="HOME^MIOIDER"
	D RESETIDE^MIOIDET000
	D EQ^MIOIDET000(.FAIL,"[T001][dbg cleared]",$D(^MIO("MIOIDE","DBG")),0)
	D EQ^MIOIDET000(.FAIL,"[T001][ev cleared]",$D(^MIO("MIOIDE","EV")),0)
	D EQ^MIOIDET000(.FAIL,"[T001][route cleared]",$G(^MIO("ROUTE","RAW","GET","/mioide")),"")
	Q
	;
T010(FAIL)
	N CONF,RES,OUT,ERR
	D CONFDEF^MIOIDE(.CONF)
	D MKFIX^MIOIDET000(.CONF)
	D COMPILE^MIOIDED("1BAD",.CONF,.RES)
	D EQ^MIOIDET000(.FAIL,"[T010][compile invalid]",$G(RES("error")),"invalid_routine")
	K RES
	D COMPILE^MIOIDED("MIOIDZNF",.CONF,.RES)
	D EQ^MIOIDET000(.FAIL,"[T010][compile missing]",$G(RES("error")),"not_found")
	S CONF("mioide","run","enabled")=0
	K RES
	D RUN^MIOIDED("MIOIDXT1","",.CONF,.RES)
	D EQ^MIOIDET000(.FAIL,"[T010][run disabled]",$G(RES("error")),"run_disabled")
	K OUT
	D SEARCH^MIOIDED(.CONF,"",5,.OUT)
	D EQ^MIOIDET000(.FAIL,"[T010][search empty]",$$COUNT^MIOIDED(.OUT),0)
	K ERR,OUT
	D FALSE^MIOIDET000(.FAIL,"[T010][exec bad]",$$EXECBUF^MIOIDED("S X=",.CONF,.OUT,.ERR))
	D EQ^MIOIDET000(.FAIL,"[T010][exec err]",$G(ERR("error")),"xecute_failed")
	Q
	;
T020(FAIL)
	N EV
	D RESETWS^MIOIDET000
	D FALSE^MIOIDET000(.FAIL,"[T020][nextev bad id]",$$NEXTEV^MIOIDEWS("bad id",0,.EV))
	D PUB^MIOIDEWS("bad id",.EV)
	D EQ^MIOIDET000(.FAIL,"[T020][no invalid ev]",$D(^MIO("MIOIDE","EV","bad id")),0)
	Q
	;
T030(FAIL)
	N CONF,REQ,RES,SID,BP
	I $T(START^MIOIDBG)="" Q
	D CONFDEF^MIOIDE(.CONF)
	D MKFIX^MIOIDET000(.CONF)
	S REQ("hdr","x-mioide-client")="dbg-clean"
	D START^MIOIDBG("MIOIDXT1","",.REQ,.CONF,.RES)
	S SID=$G(RES("sid"))
	D TOGBP^MIOIDBG("MIOIDXT1",3,.REQ,.CONF,.RES)
	D RESETDBG^MIOIDET000
	K RES
	D EQ^MIOIDET000(.FAIL,"[T030][snap after reset]",$$SNAP^MIOIDBG(SID,.CONF,.RES),0)
	D EQ^MIOIDET000(.FAIL,"[T030][snap reset err]",$G(RES("error")),"session_not_found")
	D LISTBP^MIOIDBG("MIOIDXT1",.BP)
	D EQ^MIOIDET000(.FAIL,"[T030][bp cleared]",$$COUNT^MIOIDED(.BP),0)
	Q
	;
