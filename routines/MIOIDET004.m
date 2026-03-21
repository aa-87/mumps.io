MIOIDET004 ; MIOIDE debugger foundation tests
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
	. I 'LOCAL W !,"OK - MIOIDET004"
	I LOCAL S FAIL=1
	Q
	;
T001(FAIL)
	N CONF,REQ,RES
	D RESET^MIOIDBG(1)
	D CONFDEF^MIOIDE(.CONF)
	S CONF("mioide","routineDir")="routines"
	D MKFIX^MIOIDET002(.CONF)
	S REQ("hdr","x-mioide-client")="dbgA"
	D TRUE^MIOIDET000(.FAIL,"[T001][start ok]",$$START^MIOIDBG("MIOIDXA1","",.REQ,.CONF,.RES))
	D EQ^MIOIDET000(.FAIL,"[T001][status]",$G(RES("status")),"paused")
	D EQ^MIOIDET000(.FAIL,"[T001][reason]",$G(RES("reason")),"entry")
	D EQ^MIOIDET000(.FAIL,"[T001][routine]",$G(RES("routine")),"MIOIDXA1")
	Q
	;
T010(FAIL)
	N CONF,REQ,RES,SID
	D RESET^MIOIDBG(1)
	D CONFDEF^MIOIDE(.CONF)
	S CONF("mioide","routineDir")="routines"
	D MKFIX^MIOIDET002(.CONF)
	S REQ("hdr","x-mioide-client")="dbgB"
	D START^MIOIDBG("MIOIDXA1","",.REQ,.CONF,.RES)
	S SID=$G(RES("sid"))
	D TRUE^MIOIDET000(.FAIL,"[T010][sid]",SID'="")
	D CMD^MIOIDBG(SID,"stepinto",.REQ,.CONF,.RES)
	D EQ^MIOIDET000(.FAIL,"[T010][step status]",$G(RES("status")),"paused")
	D TRUE^MIOIDET000(.FAIL,"[T010][line advanced]",+$G(RES("line"))>1)
	Q
	;
T020(FAIL)
	N CONF,REQ,RES,SID,BP
	D RESET^MIOIDBG(1)
	D CONFDEF^MIOIDE(.CONF)
	S CONF("mioide","routineDir")="routines"
	D MKFIX^MIOIDET002(.CONF)
	S REQ("hdr","x-mioide-client")="dbgC"
	D TOGBP^MIOIDBG("MIOIDXA1",2,.REQ,.CONF,.RES)
	D EQ^MIOIDET000(.FAIL,"[T020][bp enabled]",+$G(RES("enabled")),1)
	D LISTBP^MIOIDBG("MIOIDXA1",.BP)
	D EQ^MIOIDET000(.FAIL,"[T020][bp line]",+$G(BP(1,"line")),2)
	Q
	;
T030(FAIL)
	N CONF,REQ,RES,SID
	D RESET^MIOIDBG(1)
	D CONFDEF^MIOIDE(.CONF)
	S CONF("mioide","routineDir")="routines"
	D MKFIX^MIOIDET002(.CONF)
	S REQ("hdr","x-mioide-client")="dbgD"
	D START^MIOIDBG("MIOIDXA1","",.REQ,.CONF,.RES)
	S SID=$G(RES("sid"))
	D ADDWATCH^MIOIDBG(SID,"$JOB",.REQ,.CONF,.RES)
	D TRUE^MIOIDET000(.FAIL,"[T030][watch count]",$S($D(RES("watch",1))>0:1,1:0))
	D EVAL^MIOIDBG(SID,"$JOB",.REQ,.CONF,.RES)
	D TRUE^MIOIDET000(.FAIL,"[T030][eval ok]",+$G(RES("ok"))=1)
	D TRUE^MIOIDET000(.FAIL,"[T030][eval value]",$G(RES("value"))'="")
	Q
	;