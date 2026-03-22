MIOIDET012 ; MIOIDE ROI 3C debugger hardening tests
	D START Q
	;
START(FAIL)
	N TOP,LOCAL
	S TOP='$D(FAIL),LOCAL=0
	D T001(.LOCAL)
	D T010(.LOCAL)
	D T020(.LOCAL)
	I TOP D  Q
	. I 'LOCAL W !,"OK - MIOIDET012"
	I LOCAL S FAIL=1
	Q
	;
BASE(CONF,RTN,RES)
	N ERR,OK
	D RESETDBG^MIOIDET000
	D CONFDEF^MIOIDE(.CONF)
	S CONF("mioide","routineDir")="tmp"
	S OK=$$SAVETEXT^MIOIDED($G(RTN),$G(RTN)_" ; harden fixture"_$C(10)_" S A=1"_$C(10)_" S B=2"_$C(10)_" W A+B"_$C(10)_" Q",.CONF,.ERR)
	I 'OK M RES=ERR Q 0
	Q 1
	;
T001(FAIL)
	N CONF,RES,OK,SID,ARG
	S OK=$$BASE(.CONF,"MIOIDBGC1",.RES)
	D TRUE^MIOIDET000(.FAIL,"[T001][base]",OK)
	Q:'OK
	S OK=$$START^MIOIDEDBG(.CONF,"MIOIDBGC1","","cli-c1",.RES)
	D TRUE^MIOIDET000(.FAIL,"[T001][start]",OK)
	S SID=$G(RES("sid"))
	D EQ^MIOIDET000(.FAIL,"[T001][start status]",$G(RES("status")),"paused")
	K ARG S OK=$$CMD^MIOIDEDBG(SID,"step_into",.ARG,.CONF,.RES)
	D TRUE^MIOIDET000(.FAIL,"[T001][step into]",OK)
	D EQ^MIOIDET000(.FAIL,"[T001][step status]",$G(RES("status")),"paused")
	D EQ^MIOIDET000(.FAIL,"[T001][step line]",+$G(RES("line")),2)
	D EQ^MIOIDET000(.FAIL,"[T001][step reason]",$G(RES("reason")),"step_into")
	K ARG S OK=$$CMD^MIOIDEDBG(SID,"stop",.ARG,.CONF,.RES)
	D TRUE^MIOIDET000(.FAIL,"[T001][stop]",OK)
	D EQ^MIOIDET000(.FAIL,"[T001][stop status]",$G(RES("status")),"terminated")
	D EQ^MIOIDET000(.FAIL,"[T001][stop reason]",$G(RES("reason")),"stopped")
	K ARG S OK=$$CMD^MIOIDEDBG(SID,"stop",.ARG,.CONF,.RES)
	D TRUE^MIOIDET000(.FAIL,"[T001][stop again]",OK)
	D EQ^MIOIDET000(.FAIL,"[T001][stop again status]",$G(RES("status")),"terminated")
	K ARG S OK=$$CMD^MIOIDEDBG(SID,"continue",.ARG,.CONF,.RES)
	D FALSE^MIOIDET000(.FAIL,"[T001][continue closed]",OK)
	D EQ^MIOIDET000(.FAIL,"[T001][continue closed err]",$G(RES("error")),"session_closed")
	Q
	;
T010(FAIL)
	N CONF,RES,OK,SID,JSON,EV,OUT
	S OK=$$BASE(.CONF,"MIOIDBGC2",.RES)
	D TRUE^MIOIDET000(.FAIL,"[T010][base]",OK)
	Q:'OK
	S CONF("mioide","debug","eventRetain")=2
	S OK=$$START^MIOIDEDBG(.CONF,"MIOIDBGC2","","cli-c2",.RES)
	D TRUE^MIOIDET000(.FAIL,"[T010][start]",OK)
	S SID=$G(RES("sid"))
	S EV("sid")=SID,EV("status")="paused",EV("line")=1
	D PUBLISH^MIOIDEDBGP(SID,"one",.CONF,.EV,.JSON)
	D PUBLISH^MIOIDEDBGP(SID,"two",.CONF,.EV,.JSON)
	D PUBLISH^MIOIDEDBGP(SID,"three",.CONF,.EV,.JSON)
	D EQ^MIOIDET000(.FAIL,"[T010][last seq]",$$LASTSEQ^MIOIDEDBGS(SID),4)
	D EQ^MIOIDET000(.FAIL,"[T010][event count]",$$EVCOUNT^MIOIDEDBGS(SID),2)
	D TRUE^MIOIDET000(.FAIL,"[T010][next after zero]",$$NEXT^MIOIDEDBG(SID,0,.CONF,.OUT))
	D EQ^MIOIDET000(.FAIL,"[T010][trim seq]",+$G(OUT("seq")),3)
	D EQ^MIOIDET000(.FAIL,"[T010][trim type]",$G(OUT("type")),"two")
	D TRUE^MIOIDET000(.FAIL,"[T010][next after three]",$$NEXT^MIOIDEDBG(SID,3,.CONF,.OUT))
	D EQ^MIOIDET000(.FAIL,"[T010][last type]",$G(OUT("type")),"three")
	Q
	;
T020(FAIL)
	N CONF,RES,OK,SID1,SID2,SID3,RR
	D RESETDBG^MIOIDET000
	D CONFDEF^MIOIDE(.CONF)
	S CONF("mioide","routineDir")="tmp"
	S CONF("mioide","debug","idleSeconds")=1
	S CONF("mioide","debug","sessionRetain")=1
	S OK=$$SAVETEXT^MIOIDED("MIOIDBGC3","MIOIDBGC3 ; harden"_$C(10)_" Q",.CONF,.RES)
	D TRUE^MIOIDET000(.FAIL,"[T020][save]",OK)
	Q:'OK
	S OK=$$START^MIOIDEDBG(.CONF,"MIOIDBGC3","","cli-r1",.RES) S SID1=$G(RES("sid"))
	D TRUE^MIOIDET000(.FAIL,"[T020][start1]",OK)
	S ^MIO("MIOIDE","DBG","SESSION",SID1,"lastSeenTs")=$$OLDTS^MIOIDET000(5)
	S ^MIO("MIOIDE","DBG","SESSION",SID1,"updatedTs")=$$OLDTS^MIOIDET000(5)
	S OK=$$START^MIOIDEDBG(.CONF,"MIOIDBGC3","","cli-r2",.RES) S SID2=$G(RES("sid"))
	D TRUE^MIOIDET000(.FAIL,"[T020][start2]",OK)
	S OK=$$START^MIOIDEDBG(.CONF,"MIOIDBGC3","","cli-r3",.RES) S SID3=$G(RES("sid"))
	D TRUE^MIOIDET000(.FAIL,"[T020][start3]",OK)
	D TRUE^MIOIDET000(.FAIL,"[T020][reap]",$$REAP^MIOIDEDBG(.CONF,.RR))
	D GE^MIOIDET000(.FAIL,"[T020][removed stale]",+$G(RR("removed")),1)
	D GE^MIOIDET000(.FAIL,"[T020][pruned cap]",+$G(RR("pruned")),1)
	D EQ^MIOIDET000(.FAIL,"[T020][kept]",+$G(RR("kept")),1)
	D FALSE^MIOIDET000(.FAIL,"[T020][sid1 gone]",$$EXISTS^MIOIDEDBGS(SID1))
	D EQ^MIOIDET000(.FAIL,"[T020][count one]",$$SESSIONCOUNT^MIOIDEDBGS(),1)
	Q
	;
