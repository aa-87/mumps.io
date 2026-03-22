MIOIDET008 ; MIOIDE ROI 3A debugger contract coverage
	D START Q
	;
START(FAIL)
	N TOP,LOCAL
	S TOP='$D(FAIL),LOCAL=0
	I $T(START^MIOIDBG)="" G DONE
	D T001(.LOCAL)
	D T010(.LOCAL)
	D T020(.LOCAL)
	D T030(.LOCAL)
DONE	I TOP D  Q
	. I 'LOCAL W !,"OK - MIOIDET008"
	I LOCAL S FAIL=1
	Q
	;
BASE(CONF,REQ)
	D RESETDBG^MIOIDET000
	D CONFDEF^MIOIDE(.CONF)
	D MKFIX^MIOIDET000(.CONF)
	S REQ("hdr","x-mioide-client")="dbg-roi3a"
	Q
	;
T001(FAIL)
	N CONF,REQ,RES
	D BASE(.CONF,.REQ)
	D EQ^MIOIDET000(.FAIL,"[T001][snap bad]",$$SNAP^MIOIDBG("bad id!",.CONF,.RES),0)
	D EQ^MIOIDET000(.FAIL,"[T001][snap bad err]",$G(RES("error")),"invalid_session")
	K RES
	D EQ^MIOIDET000(.FAIL,"[T001][cmd missing]",$$CMD^MIOIDBG("missing","continue",.REQ,.CONF,.RES),0)
	D EQ^MIOIDET000(.FAIL,"[T001][cmd missing err]",$G(RES("error")),"session_not_found")
	K RES
	D EQ^MIOIDET000(.FAIL,"[T001][watch missing]",$$ADDWATCH^MIOIDBG("missing","$JOB",.REQ,.CONF,.RES),0)
	D EQ^MIOIDET000(.FAIL,"[T001][watch missing err]",$G(RES("error")),"session_not_found")
	Q
	;
T010(FAIL)
	N CONF,REQ,RES,SID,SNAP
	D BASE(.CONF,.REQ)
	D TRUE^MIOIDET000(.FAIL,"[T010][start ok]",$$START^MIOIDBG("MIOIDXT1","",.REQ,.CONF,.RES))
	S SID=$G(RES("sid"))
	D TRUE^MIOIDET000(.FAIL,"[T010][sid]",SID'="")
	D NODE^MIOIDET000(.FAIL,"[T010][frame node]",$D(RES("frame",1)))
	D HAS^MIOIDET000(.FAIL,"[T010][current text]",$G(RES("currentText")),"MIOIDXT1")
	D TRUE^MIOIDET000(.FAIL,"[T010][snap ok]",$$SNAP^MIOIDBG(SID,.CONF,.SNAP))
	D EQ^MIOIDET000(.FAIL,"[T010][snap sid]",$G(SNAP("sid")),SID)
	D EQ^MIOIDET000(.FAIL,"[T010][snap status]",$G(SNAP("status")),"paused")
	D NODE^MIOIDET000(.FAIL,"[T010][snap frame]",$D(SNAP("frame",1)))
	Q
	;
T020(FAIL)
	N CONF,REQ,RES,SID
	D BASE(.CONF,.REQ)
	D TRUE^MIOIDET000(.FAIL,"[T020][start ok]",$$START^MIOIDBG("MIOIDXT1","",.REQ,.CONF,.RES))
	S SID=$G(RES("sid"))
	D TRUE^MIOIDET000(.FAIL,"[T020][bp on]",$$TOGBP^MIOIDBG("MIOIDXT1",3,.REQ,.CONF,.RES))
	D EQ^MIOIDET000(.FAIL,"[T020][bp enabled]",+$G(RES("enabled")),1)
	D TRUE^MIOIDET000(.FAIL,"[T020][continue ok]",$$CMD^MIOIDBG(SID,"continue",.REQ,.CONF,.RES))
	D EQ^MIOIDET000(.FAIL,"[T020][continue reason]",$G(RES("reason")),"breakpoint")
	D EQ^MIOIDET000(.FAIL,"[T020][continue line]",+$G(RES("line")),3)
	D TRUE^MIOIDET000(.FAIL,"[T020][bp off]",$$TOGBP^MIOIDBG("MIOIDXT1",3,.REQ,.CONF,.RES))
	D EQ^MIOIDET000(.FAIL,"[T020][bp disabled]",+$G(RES("enabled")),0)
	Q
	;
T030(FAIL)
	N CONF,REQ,RES,SID
	D BASE(.CONF,.REQ)
	D TRUE^MIOIDET000(.FAIL,"[T030][start ok]",$$START^MIOIDBG("MIOIDXT1","",.REQ,.CONF,.RES))
	S SID=$G(RES("sid"))
	D TRUE^MIOIDET000(.FAIL,"[T030][add watch]",$$ADDWATCH^MIOIDBG(SID,"$HOROLOG",.REQ,.CONF,.RES))
	D NODE^MIOIDET000(.FAIL,"[T030][watch node]",$D(RES("watch",1)))
	D EQ^MIOIDET000(.FAIL,"[T030][bad eval]",$$EVAL^MIOIDBG(SID,"WRITE X",.REQ,.CONF,.RES),0)
	D EQ^MIOIDET000(.FAIL,"[T030][bad eval err]",$G(RES("error")),"unsupported_expression")
	D EQ^MIOIDET000(.FAIL,"[T030][bad remove]",$$DELWATCH^MIOIDBG(SID,0,.REQ,.CONF,.RES),0)
	D EQ^MIOIDET000(.FAIL,"[T030][bad remove err]",$G(RES("error")),"invalid_watch")
	D EQ^MIOIDET000(.FAIL,"[T030][invalid bp rtn]",$$TOGBP^MIOIDBG("BAD-RTN",2,.REQ,.CONF,.RES),0)
	D EQ^MIOIDET000(.FAIL,"[T030][invalid bp line]",$$TOGBP^MIOIDBG("MIOIDXT1",0,.REQ,.CONF,.RES),0)
	Q
	;
