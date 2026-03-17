MIOUIT008 ; implemented component smoke coverage
	;
START(FAIL) ;
	N LOCAL,TOP
	S TOP='$D(FAIL),LOCAL=0
	D T001(.LOCAL)
	I TOP D  Q
	. I 'LOCAL W !,"OK - MIOUIT008"
	I LOCAL S FAIL=1
	Q
	;
T001(FAIL)
	N REG,OUTS
	D LIST^MIOUIREG(.REG)
	D PREP(.FAIL,.OUTS)
	N I,ID,PAGE,TOKEN,STATUS,KIND
	S I=0
	F  S I=$O(REG(I)) Q:'I  D
	. S STATUS=$G(REG(I,"status")),KIND=$G(REG(I,"kind"))
	. Q:STATUS'="implemented"
	. Q:KIND'="partial"
	. Q:$G(REG(I,"smokePage"))=""
	. S ID=$G(REG(I,"id")),PAGE=$G(REG(I,"smokePage")),TOKEN=$G(REG(I,"token"))
	. D CONTAINS^MIOUIT000(.FAIL,"[T001]["_ID_"]",$G(OUTS(PAGE)),TOKEN)
	N LAYOUT
	S I=$$FIND^MIOUIREG(.REG,"layout_app")
	S LAYOUT=$G(REG(I,"token"))
	D CONTAINS^MIOUIT000(.FAIL,"[T001][layout_app]",$G(OUTS("pages/mioui_home.html")),LAYOUT)
	Q
	;
PREP(FAIL,OUTS)
	N CONF,REQ,CTX,TCTX,OUT,ERR
	K ^TMP("MIOUIT","OUTS")
	D CONFDEF^MIOUI(.CONF)
	;
	D BUILDHOME^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_home.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][home render]" Q
	D STORE(.OUTS,"pages/mioui_home.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILDCOMP^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_components.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][components render]" Q
	D STORE(.OUTS,"pages/mioui_components.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILDTABLES^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_tables.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][tables render]" Q
	D STORE(.OUTS,"pages/mioui_tables.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILDFORMS^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_forms.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][forms render]" Q
	D STORE(.OUTS,"pages/mioui_forms.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILDEXPORT^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_export.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][export render]" Q
	D STORE(.OUTS,"pages/mioui_export.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILDBILL^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_billing.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][billing render]" Q
	D STORE(.OUTS,"pages/mioui_billing.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILDWORK^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_workflows.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][workflows render]" Q
	D STORE(.OUTS,"pages/mioui_workflows.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILDOPS^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_operators.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][operators render]" Q
	D STORE(.OUTS,"pages/mioui_operators.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILDPREMIUM^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_premium.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][premium render]" Q
	D STORE(.OUTS,"pages/mioui_premium.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILDTRACE^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_trace.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][trace render]" Q
	D STORE(.OUTS,"pages/mioui_trace.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILDLARGE^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_large_table.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][large table render]" Q
	D STORE(.OUTS,"pages/mioui_large_table.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILDMILLION^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_million_table.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][million table render]" Q
	D STORE(.OUTS,"pages/mioui_million_table.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILD^MIOUITWB(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_table_workbench.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][table workbench render]" Q
	D STORE(.OUTS,"pages/mioui_table_workbench.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILD^MIOUITMX(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_advanced_table.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][advanced table render]" Q
	D STORE(.OUTS,"pages/mioui_advanced_table.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILD^MIOUITSX(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_table_review_sync.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][table review sync render]" Q
	D STORE(.OUTS,"pages/mioui_table_review_sync.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILD^MIOUILYT(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_data_layouts.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][data layouts render]" Q
	D STORE(.OUTS,"pages/mioui_data_layouts.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILD^MIOUIADL(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_adaptive_workspaces.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][adaptive workspaces render]" Q
	D STORE(.OUTS,"pages/mioui_adaptive_workspaces.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILD^MIOUILST(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_workspace_state.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][workspace state render]" Q
	D STORE(.OUTS,"pages/mioui_workspace_state.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILD^MIOUILOV(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_layout_overlays.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][layout overlays render]" Q
	D STORE(.OUTS,"pages/mioui_layout_overlays.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILD^MIOUICLY(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_layout_choreography.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][layout choreography render]" Q
	D STORE(.OUTS,"pages/mioui_layout_choreography.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILD^MIOUIMMR(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_multi_monitor_layouts.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][multi monitor render]" Q
	D STORE(.OUTS,"pages/mioui_multi_monitor_layouts.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILD^MIOUICTR(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_control_room_layouts.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][control room render]" Q
	D STORE(.OUTS,"pages/mioui_control_room_layouts.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILD^MIOUILDV(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_layout_diversity.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][layout diversity render]" Q
	D STORE(.OUTS,"pages/mioui_layout_diversity.html",OUT)
	;
	K TCTX,OUT,ERR
	D BUILD^MIOUILTP(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_layout_topologies.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][layout topologies render]" Q
	D STORE(.OUTS,"pages/mioui_layout_topologies.html",OUT)
	;
;
	K TCTX,OUT,ERR
	D BUILD^MIOUIAFM(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_auth_forms.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) S FAIL=1 W !,"FAIL: [PREP][auth forms render]" Q
	D STORE(.OUTS,"pages/mioui_auth_forms.html",OUT)
	Q
	;
STORE(OUTS,KEY,VAL)
	S OUTS(KEY)=VAL
	S ^TMP("MIOUIT","OUTS",KEY)=VAL
	Q
	;