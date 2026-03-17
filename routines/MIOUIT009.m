MIOUIT009 ; planned component metadata tests
	D START Q
	;
START(FAIL)
	N LOCAL,TOP
	S TOP='$D(FAIL),LOCAL=0
	D T001(.LOCAL)
	D T010(.LOCAL)
	D T020(.LOCAL)
	I TOP D  Q
	. I 'LOCAL W !,"OK - MIOUIT009"
	I LOCAL S FAIL=1
	Q
	;
T001(FAIL)
	N REG,I
	D LIST^MIOUIREG(.REG)
	S I=0
	F  S I=$O(REG(I)) Q:'I  D
	. Q:$G(REG(I,"status"))'="planned"
	. D NOTEMPTY^MIOUIT000(.FAIL,"[T001]["_$G(REG(I,"id"))_"][phase]",$G(REG(I,"phase")))
	. D NOTEMPTY^MIOUIT000(.FAIL,"[T001]["_$G(REG(I,"id"))_"][test]",$G(REG(I,"test")))
	. D NOTEMPTY^MIOUIT000(.FAIL,"[T001]["_$G(REG(I,"id"))_"][desc]",$G(REG(I,"desc")))
	Q
	;
T010(FAIL)
	N REG,P1,P2,P3,I
	D LIST^MIOUIREG(.REG)
	S (P1,P2,P3,I)=0
	F  S I=$O(REG(I)) Q:'I  D
	. Q:$G(REG(I,"status"))'="planned"
	. I $G(REG(I,"phase"))="P1" S P1=P1+1 Q
	. I $G(REG(I,"phase"))="P2" S P2=P2+1 Q
	. I $G(REG(I,"phase"))="P3" S P3=P3+1
	D GE^MIOUIT000(.FAIL,"[T010][p1 count]",P1,1)
	D GE^MIOUIT000(.FAIL,"[T010][p2 count]",P2,2)
	D GE^MIOUIT000(.FAIL,"[T010][p3 count]",P3,1)
	Q
	;
T020(FAIL)
	N REG,I
	D LIST^MIOUIREG(.REG)
	S I=$$FIND^MIOUIREG(.REG,"evidence_chip_list")
	D EQ^MIOUIT000(.FAIL,"[T020][evidence chip phase]",$G(REG(I,"phase")),"P2")
	D EQ^MIOUIT000(.FAIL,"[T020][evidence chip family]",$G(REG(I,"family")),"workflow")
	S I=$$FIND^MIOUIREG(.REG,"radio_group")
	D EQ^MIOUIT000(.FAIL,"[T020][radio group phase]",$G(REG(I,"phase")),"P1")
	D EQ^MIOUIT000(.FAIL,"[T020][radio group family]",$G(REG(I,"family")),"forms")
	S I=$$FIND^MIOUIREG(.REG,"keyboard_shortcuts_dialog")
	D EQ^MIOUIT000(.FAIL,"[T020][kbd phase]",$G(REG(I,"phase")),"P3")
	D EQ^MIOUIT000(.FAIL,"[T020][kbd family]",$G(REG(I,"family")),"feedback")
	S I=$$FIND^MIOUIREG(.REG,"data_grid_multi_sort")
	D EQ^MIOUIT000(.FAIL,"[T020][multi sort phase]",$G(REG(I,"phase")),"P1")
	D EQ^MIOUIT000(.FAIL,"[T020][multi sort family]",$G(REG(I,"family")),"dense-data")
	Q
	;
	;