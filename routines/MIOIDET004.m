MIOIDET004 ; MIOIDE websocket debugger service tests
	D START Q
	;
START(FAIL)
	N TOP,LOCAL
	S TOP='$D(FAIL),LOCAL=0
	D T001(.LOCAL)
	D T020(.LOCAL)
	I TOP D  Q
	. I 'LOCAL W !,"OK - MIOIDET004"
	I LOCAL S FAIL=1
	Q
	;
T001(FAIL)
	N CONF,ERR,OK,RES,SNAP,RET
	D RESETDBG^MIOIDET000
	D CONFDEF^MIOIDE(.CONF)
	S CONF("mioide","routineDir")="tmp"
	S OK=$$SAVETEXT^MIOIDED("MIOIDBGX1","MIOIDBGX1 ; dbg fixture"_$C(10)_" S X=1"_$C(10)_" W X"_$C(10)_" Q",.CONF,.ERR)
	D TRUE^MIOIDET000(.FAIL,"[T001][fixture save]",OK)
	S OK=$$START^MIOIDEDBG(.CONF,"MIOIDBGX1","","cli-1",.RES)
	D TRUE^MIOIDET000(.FAIL,"[T001][start ok]",OK)
	D HAS^MIOIDET000(.FAIL,"[T001][ws path]",$G(RES("wsPath")),"/mioide/ws/debug/")
	D EQ^MIOIDET000(.FAIL,"[T001][status]",$G(RES("status")),"paused")
	D EQ^MIOIDET000(.FAIL,"[T001][line]",+$G(RES("line")),1)
	D GE^MIOIDET000(.FAIL,"[T001][maxline]",+$G(RES("maxline")),4)
	S OK=$$SNAP^MIOIDEDBG($G(RES("sid")),.CONF,.SNAP)
	D TRUE^MIOIDET000(.FAIL,"[T001][snap ok]",OK)
	D EQ^MIOIDET000(.FAIL,"[T001][snap status]",$G(SNAP("status")),"paused")
	Q
	;
T020(FAIL)
	N CONF,ERR,OK,RES,ARG,SNAP
	D RESETDBG^MIOIDET000
	D CONFDEF^MIOIDE(.CONF)
	S CONF("mioide","routineDir")="tmp"
	S OK=$$SAVETEXT^MIOIDED("MIOIDBGX2","MIOIDBGX2 ; dbg fixture"_$C(10)_" S A=1"_$C(10)_" S B=2"_$C(10)_" W A+B"_$C(10)_" Q",.CONF,.ERR)
	D TRUE^MIOIDET000(.FAIL,"[T020][fixture save]",OK)
	S OK=$$START^MIOIDEDBG(.CONF,"MIOIDBGX2","","cli-2",.RES)
	D TRUE^MIOIDET000(.FAIL,"[T020][start ok]",OK)
	S OK=$$TOGBP^MIOIDEDBG($G(RES("sid")),"MIOIDBGX2",3,.CONF,.ARG)
	D TRUE^MIOIDET000(.FAIL,"[T020][bp ok]",OK)
	D EQ^MIOIDET000(.FAIL,"[T020][bp enabled]",+$G(ARG("enabled")),1)
	S OK=$$ADDWATCH^MIOIDEDBG($G(RES("sid")),"$JOB",.CONF,.ARG)
	D TRUE^MIOIDET000(.FAIL,"[T020][watch add]",OK)
	S OK=$$CMD^MIOIDEDBG($G(RES("sid")),"continue",.ARG,.CONF,.SNAP)
	D TRUE^MIOIDET000(.FAIL,"[T020][continue]",OK)
	D EQ^MIOIDET000(.FAIL,"[T020][break line]",+$G(SNAP("line")),3)
	D EQ^MIOIDET000(.FAIL,"[T020][break reason]",$G(SNAP("reason")),"breakpoint")
	S OK=$$CMD^MIOIDEDBG($G(RES("sid")),"step_over",.ARG,.CONF,.SNAP)
	D TRUE^MIOIDET000(.FAIL,"[T020][step]",OK)
	D EQ^MIOIDET000(.FAIL,"[T020][line 4]",+$G(SNAP("line")),4)
	S OK=$$EVAL^MIOIDEDBG($G(RES("sid")),"$JOB",.CONF,.ARG)
	D TRUE^MIOIDET000(.FAIL,"[T020][eval]",OK)
	D GE^MIOIDET000(.FAIL,"[T020][job]",+$G(ARG("value")),1)
	Q
	;
