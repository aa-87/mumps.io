MIOUIT031 ; ROI 21 tests
	D START Q
	;
START(FAIL)
	N LOCAL,TOP,ID
	S TOP='$D(FAIL),LOCAL=0
	D T001(.LOCAL)
	I TOP D  Q
	. I 'LOCAL W !,"OK - MIOUIT030"
	I LOCAL S FAIL=1
	Q
	;
	;
T001(FAIL)
	N REG,I,FOUND
	S FAIL=0
	; page token coverage
	D HAS^MIOUIT000(.FAIL,"[T010][title]",$G(^TMP("MIOUIT","OUTS","pages/mioui_layout_diversity.html")),"Layout diversity lab")
	D HAS^MIOUIT000(.FAIL,"[T010][cockpit]",$G(^TMP("MIOUIT","OUTS","pages/mioui_layout_diversity.html")),"Master-detail cockpit")
	D HAS^MIOUIT000(.FAIL,"[T010][board]",$G(^TMP("MIOUIT","OUTS","pages/mioui_layout_diversity.html")),"Queue board matrix")
	D HAS^MIOUIT000(.FAIL,"[T010][ledger]",$G(^TMP("MIOUIT","OUTS","pages/mioui_layout_diversity.html")),"Ledger tape layout")
	D HAS^MIOUIT000(.FAIL,"[T010][theater]",$G(^TMP("MIOUIT","OUTS","pages/mioui_layout_diversity.html")),"Document review theater")
	D HAS^MIOUIT000(.FAIL,"[T010][fusion]",$G(^TMP("MIOUIT","OUTS","pages/mioui_layout_diversity.html")),"Map-table context fusion")
	D HAS^MIOUIT000(.FAIL,"[T010][ring]",$G(^TMP("MIOUIT","OUTS","pages/mioui_layout_diversity.html")),"Escalation ring layout")
	D HAS^MIOUIT000(.FAIL,"[T010][callback cockpit]",$G(^TMP("MIOUIT","OUTS","pages/mioui_layout_diversity.html")),"openCockpitPreset")
	D HAS^MIOUIT000(.FAIL,"[T010][callback ring]",$G(^TMP("MIOUIT","OUTS","pages/mioui_layout_diversity.html")),"openEscalationRing")
	; registry contract
	K REG D BUILD^MIOUIREG(.REG)
	D FIND(.REG,"layout_master_detail_cockpit",.I)
	D EQ^MIOUIT000(.FAIL,"[T020][cockpit status]",$G(REG(I,"status")),"implemented")
	D EQ^MIOUIT000(.FAIL,"[T020][cockpit phase]",$G(REG(I,"phase")),"P1")
	D FIND(.REG,"layout_escalation_ring",.I)
	D EQ^MIOUIT000(.FAIL,"[T020][ring status]",$G(REG(I,"status")),"implemented")
	D EQ^MIOUIT000(.FAIL,"[T020][ring phase]",$G(REG(I,"phase")),"P1")
	I 'FAIL W !,"OK - MIOUIT031"
	Q
	;
FIND(REG,ID,OUT)
	N I S OUT=""
	S I=0 F  S I=$O(REG(I)) Q:'I  I $G(REG(I,"id"))=ID S OUT=I Q
	Q
	;