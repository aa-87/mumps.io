MIOUIBILLT008 ; Billing report variant token coverage
	D START Q
	;
START(FAIL)
	N LOCAL,TOP
	S TOP='$D(FAIL),LOCAL=0
	D T001(.LOCAL)
	D T010(.LOCAL)
	I TOP D  Q
	. I 'LOCAL W !,"OK - MIOUIBILLT008"
	I LOCAL S FAIL=1
	Q
	;
T001(FAIL)
	N CONF,REQ,CTX,TCTX,OUT,ERR
	D CONFDEF^MIOUI(.CONF)
	D BUILDREPD^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/miouibill_reports_dense.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	D EQ^MIOUIT000(.FAIL,"[T001][render ok]",$D(ERR),0)
	D HAS^MIOUIT000(.FAIL,"[T001][queue board]",OUT,"Queue board")
	D HAS^MIOUIT000(.FAIL,"[T001][recovery lanes]",OUT,"Recovery lanes")
	D HAS^MIOUIT000(.FAIL,"[T001][medical necessity]",OUT,"Medical necessity appeals")
	D HAS^MIOUIT000(.FAIL,"[T001][collections trend]",OUT,"Daily net collections trend")
	D HAS^MIOUIT000(.FAIL,"[T001][report exports]",OUT,"data-miouibill-report-dense-pane=""exports""")
	D HAS^MIOUIT000(.FAIL,"[T001][weekend lag]",OUT,"Weekend intake drift")
	Q
	;
T010(FAIL)
	N CONF,REQ,CTX,TCTX,OUT,ERR
	D CONFDEF^MIOUI(.CONF)
	D BUILDREPX^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/miouibill_reports_executive.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
	D HAS^MIOUIT000(.FAIL,"[T010][exec stories]",OUT,"report-exec-stories")
	D HAS^MIOUIT000(.FAIL,"[T010][oldest ar]",OUT,"Oldest A/R concentration")
	D HAS^MIOUIT000(.FAIL,"[T010][recommended]",OUT,"Recommended actions")
	D HAS^MIOUIT000(.FAIL,"[T010][clear auth]",OUT,"Clear top auth holds")
	D HAS^MIOUIT000(.FAIL,"[T010][denials]",OUT,"Top denial reasons")
	D HAS^MIOUIT000(.FAIL,"[T010][aging]",OUT,"Aging buckets")
	Q
	;
	;