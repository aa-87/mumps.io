MIOUIT032 ; ROI 22 tests
	Q
	;
START(FAIL) ; run ROI 23 coverage
	N FAIL,CONF,REQ,CTX,OUTS,OUT,REG
	S FAIL=0
	K ^TMP("MIOUIT","OUTS")
	D PREP^MIOUIT008(.FAIL,.OUTS)
	; page token coverage
	D HAS^MIOUIT000(.FAIL,"[T010][title]",$G(^TMP("MIOUIT","OUTS","pages/mioui_layout_topologies.html")),"Layout topology lab")
	D HAS^MIOUIT000(.FAIL,"[T010][corridor]",$G(^TMP("MIOUIT","OUTS","pages/mioui_layout_topologies.html")),"Timeline corridor layout")
	D HAS^MIOUIT000(.FAIL,"[T010][radial]",$G(^TMP("MIOUIT","OUTS","pages/mioui_layout_topologies.html")),"Radial dispatch hub")
	D HAS^MIOUIT000(.FAIL,"[T010][strip wall]",$G(^TMP("MIOUIT","OUTS","pages/mioui_layout_topologies.html")),"Dossier strip wall")
	D HAS^MIOUIT000(.FAIL,"[T010][cascade]",$G(^TMP("MIOUIT","OUTS","pages/mioui_layout_topologies.html")),"Nested queue cascade")
	D HAS^MIOUIT000(.FAIL,"[T010][deck]",$G(^TMP("MIOUIT","OUTS","pages/mioui_layout_topologies.html")),"Panorama comparison deck")
	D HAS^MIOUIT000(.FAIL,"[T010][lattice]",$G(^TMP("MIOUIT","OUTS","pages/mioui_layout_topologies.html")),"Signal triage lattice")
	D HAS^MIOUIT000(.FAIL,"[T010][hero callback]",$G(^TMP("MIOUIT","OUTS","pages/mioui_layout_topologies.html")),"openTopologyStudio")
	D HAS^MIOUIT000(.FAIL,"[T010][corridor callback]",$G(^TMP("MIOUIT","OUTS","pages/mioui_layout_topologies.html")),"openTimelineCorridor")
	D HAS^MIOUIT000(.FAIL,"[T010][lattice callback]",$G(^TMP("MIOUIT","OUTS","pages/mioui_layout_topologies.html")),"openSignalLattice")
	; registry contract
	K REG D BUILD^MIOUIREG(.REG)
	D FIND(.REG,"layout_timeline_corridor",.I)
	D EQ^MIOUIT000(.FAIL,"[T020][corridor status]",$G(REG(I,"status")),"implemented")
	D EQ^MIOUIT000(.FAIL,"[T020][corridor phase]",$G(REG(I,"phase")),"P1")
	D FIND(.REG,"layout_signal_triage_lattice",.I)
	D EQ^MIOUIT000(.FAIL,"[T020][lattice status]",$G(REG(I,"status")),"implemented")
	D EQ^MIOUIT000(.FAIL,"[T020][lattice phase]",$G(REG(I,"phase")),"P1")
	I 'FAIL W !,"OK - MIOUIT032"
	Q
	;
FIND(REG,ID,OUT)
	N I S OUT=""
	S I=0 F  S I=$O(REG(I)) Q:'I  I $G(REG(I,"id"))=ID S OUT=I Q
	Q
	;