MIOUIT018 ; ROI8 detailed data-grid tests
	D START Q
	;
START(FAIL)
	N LOCAL,TOP
	S TOP='$D(FAIL),LOCAL=0
	D T001(.LOCAL)
	D T010(.LOCAL)
	D T020(.LOCAL)
	D T030(.LOCAL)
	I TOP D  Q
	. I 'LOCAL W !,"OK - MIOUIT018"
	I LOCAL S FAIL=1
	Q
	;
BASECONF(CONF)
	D CONFDEF^MIOUI(.CONF)
	D INIT^MIOUI(.CONF)
	Q
	;
T001(FAIL)
	N TCTX
	D BUILD^MIOUIDTGD(.CONF,.REQ,.CTX,.TCTX)
	D EQ^MIOUIT000(.FAIL,"[T001][row count]",+$G(TCTX("grid","main","rowCount")),4)
	D EQ^MIOUIT000(.FAIL,"[T001][selected count]",+$G(TCTX("grid","main","selectedCount")),2)
	D EQ^MIOUIT000(.FAIL,"[T001][insight label]",$G(TCTX("grid","main","insight",1,"label")),"Rendered rows")
	D EQ^MIOUIT000(.FAIL,"[T001][sorted header]",+$G(TCTX("grid","main","col",4,"isSorted")),1)
	D EQ^MIOUIT000(.FAIL,"[T001][row meta]",$G(TCTX("grid","main","row",1,"meta")),"837P professional")
	Q
	;
T010(FAIL)
	N CONF,REQ,CTX,TCTX,OUT,ERR
	D BASECONF(.CONF)
	D BUILD^MIOUIDTGD(.CONF,.REQ,.CTX,.TCTX)
	D RENDERPAGE^MIOTPL("pages/mioui_datagrid.html","layouts/mioui_app.html",.CONF,.TCTX,.OUT,.ERR)
	D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
	D CONTAINS^MIOUIT000(.FAIL,"[T010][grid title]",OUT,"Detailed claims grid")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][rendered rows]",OUT,"Rendered rows")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][selection]",OUT,"2 selected for publish")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][header]",OUT,"Claim / patient")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][row meta]",OUT,"837P professional")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][needs review]",OUT,"Needs review")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][saved view]",OUT,"Pinned operator view")
	Q
	;
T020(FAIL)
	N CONF
	K ^MIO("ROUTE","RAW","GET","/mioui/datagrid")
	D REG^MIOUI(.CONF)
	D EQ^MIOUIT000(.FAIL,"[T020][route target]",$G(^MIO("ROUTE","RAW","GET","/mioui/datagrid")),"DATAGRID^MIOUIDTGD")
	D EQ^MIOUIT000(.FAIL,"[T020][route auth]",+$G(^MIO("ROUTE","META","GET","/mioui/datagrid","authRequired")),0)
	Q
	;
T030(FAIL)
	N REG,I
	D LIST^MIOUIREG(.REG)
	S I=$$FIND^MIOUIREG(.REG,"detailed_grid_builder")
	D EQ^MIOUIT000(.FAIL,"[T030][builder status]",$G(REG(I,"status")),"implemented")
	D EQ^MIOUIT000(.FAIL,"[T030][builder test]",$G(REG(I,"test")),"MIOUIT018")
	S I=$$FIND^MIOUIREG(.REG,"detailed_data_grid")
	D EQ^MIOUIT000(.FAIL,"[T030][grid status]",$G(REG(I,"status")),"implemented")
	S I=$$FIND^MIOUIREG(.REG,"selection_summary")
	D EQ^MIOUIT000(.FAIL,"[T030][selection status]",$G(REG(I,"status")),"implemented")
	S I=$$FIND^MIOUIREG(.REG,"table_insights")
	D EQ^MIOUIT000(.FAIL,"[T030][insights status]",$G(REG(I,"status")),"implemented")
	S I=$$FIND^MIOUIREG(.REG,"data_grid_virtual_window")
	D EQ^MIOUIT000(.FAIL,"[T030][virtual window planned]",$G(REG(I,"status")),"implemented")
	Q
	;
	;