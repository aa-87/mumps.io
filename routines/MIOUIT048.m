MIOUIT048 ; chart distribution + radar ROI tests
	Q
	;
START(FAIL)
	N LOCAL
	S LOCAL=0
	D T001(.LOCAL)
	I 'LOCAL W !,"OK - MIOUIT048"
	I $G(FAIL) S FAIL=FAIL+LOCAL Q
	I LOCAL S FAIL=1
	Q
	;
T001(FAIL)
	N CONF,REQ,CTX,TCTX,OUT,ERR
	D BUILDCHARTS^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_chart_variants.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) W !,"FAIL: [T001][render]" S FAIL=1 Q
	D HAS(.FAIL,"[T001][histogram title]",OUT,"Histogram distribution")
	D HAS(.FAIL,"[T001][histogram band]",OUT,"Target aging band")
	D HAS(.FAIL,"[T001][box title]",OUT,"Box-range summary")
	D HAS(.FAIL,"[T001][box note]",OUT,"Useful when averages hide a long-tail payer or facility")
	D HAS(.FAIL,"[T001][radar title]",OUT,"Radar score profile")
	D HAS(.FAIL,"[T001][radar legend]",OUT,"Benchmark overlay")
	D HAS(.FAIL,"[T001][callback dist]",OUT,"toggleDistributionBands")
	D HAS(.FAIL,"[T001][callback benchmark]",OUT,"changeBenchmarkOverlay")
	D HAS(.FAIL,"[T001][callback radar]",OUT,"switchRadarProfile")
	D HAS(.FAIL,"[T001][css hist]",OUT,"chart-hist-grid")
	D HAS(.FAIL,"[T001][css radar]",OUT,"chart-radar-fill")
	Q
	;
HAS(FAIL,LABEL,TXT,TOKEN)
	I TXT'[TOKEN W !,"FAIL: ",LABEL,": missing token=",TOKEN S FAIL=1
	Q
