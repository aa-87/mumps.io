MIOUIT047 ; chart light-theme + waterfall ROI tests
	Q
	;
START(FAIL)
	N LOCAL
	S LOCAL=0
	D T001(.LOCAL)
	I 'LOCAL W !,"OK - MIOUIT047"
	I $G(FAIL) S FAIL=FAIL+LOCAL Q
	I LOCAL S FAIL=1
	Q
	;
T001(FAIL)
	N CONF,REQ,CTX,TCTX,OUT,ERR
	D BUILDCHARTS^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_chart_variants.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) W !,"FAIL: [T001][render]" S FAIL=1 Q
	D HAS(.FAIL,"[T001][theme css]",OUT,"html[data-theme=""light""] .mioui-chart-lab .chart-surface")
	D HAS(.FAIL,"[T001][semantic chip]",OUT,"chart-stat-chip")
	D HAS(.FAIL,"[T001][waterfall title]",OUT,"Waterfall variance bridge")
	D HAS(.FAIL,"[T001][waterfall detail]",OUT,"Sequential variance view")
	D HAS(.FAIL,"[T001][waterfall callback]",OUT,"rebaseVarianceBridge")
	Q
	;
HAS(FAIL,LABEL,TXT,TOKEN)
	I TXT'[TOKEN W !,"FAIL: ",LABEL,": missing token=",TOKEN S FAIL=1
	Q
	;