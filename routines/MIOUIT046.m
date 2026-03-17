MIOUIT046 ; chart variant ROI tests
	Q
	;
START(FAIL)
	N LOCAL
	S LOCAL=0
	D T001(.LOCAL)
	D T010(.LOCAL)
	I 'LOCAL W !,"OK - MIOUIT046"
	I $G(FAIL) S FAIL=FAIL+LOCAL Q
	I LOCAL S FAIL=1
	Q
	;
T001(FAIL)
	N CONF,REQ,CTX,TCTX,OUT,ERR
	D BUILDCHARTS^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_chart_variants.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) W !,"FAIL: [T001][render]" S FAIL=1 Q
	D HAS(.FAIL,"[T001][title]",OUT,"Chart and graph variants")
	D HAS(.FAIL,"[T001][bar]",OUT,"Horizontal bar comparisons")
	D HAS(.FAIL,"[T001][stack]",OUT,"Stacked resolution mix")
	D HAS(.FAIL,"[T001][line]",OUT,"Run-rate line trend")
	D HAS(.FAIL,"[T001][area]",OUT,"Area forecast band")
	D HAS(.FAIL,"[T001][pie]",OUT,"Pie and donut summaries")
	D HAS(.FAIL,"[T001][heat]",OUT,"Heatmap activity grid")
	D HAS(.FAIL,"[T001][bullet]",OUT,"Bullet and target grid")
	D HAS(.FAIL,"[T001][funnel]",OUT,"Funnel stage board")
	D HAS(.FAIL,"[T001][spark]",OUT,"Sparkline comparison table")
	D HAS(.FAIL,"[T001][callback open]",OUT,"openChartVariantStudio")
	D HAS(.FAIL,"[T001][callback date]",OUT,"changeChartDateWindow")
	D HAS(.FAIL,"[T001][callback granularity]",OUT,"switchChartGranularity")
	D HAS(.FAIL,"[T001][callback series]",OUT,"toggleChartSeries")
	D HAS(.FAIL,"[T001][callback filter]",OUT,"filterChartPopulation")
	D HAS(.FAIL,"[T001][callback compare]",OUT,"compareChartSegments")
	D HAS(.FAIL,"[T001][callback thresholds]",OUT,"saveChartThresholds")
	D HAS(.FAIL,"[T001][callback export]",OUT,"exportChartSnapshot")
	D HAS(.FAIL,"[T001][callback pin]",OUT,"pinChartToDashboard")
	D HAS(.FAIL,"[T001][callback drill]",OUT,"drillIntoChartPoint")
	D HAS(.FAIL,"[T001][callback annotate]",OUT,"annotateChartRunRate")
	D HAS(.FAIL,"[T001][callback palette]",OUT,"cycleChartPalette")
	Q
	;
T010(FAIL)
	N CONF
	K ^MIO("ROUTE","RAW","GET","/mioui/charts")
	D REG^MIOUIDEMO(.CONF)
	D EQ^MIOUIT000(.FAIL,"[T010][target]",$G(^MIO("ROUTE","RAW","GET","/mioui/charts")),"CHARTS^MIOUIDEMO")
	D EQ^MIOUIT000(.FAIL,"[T010][auth]",+$G(^MIO("ROUTE","META","GET","/mioui/charts","authRequired")),0)
	Q
	;
HAS(FAIL,LABEL,TXT,TOKEN)
	I TXT'[TOKEN W !,"FAIL: ",LABEL,": missing token=",TOKEN S FAIL=1
	Q
