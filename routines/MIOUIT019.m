MIOUIT019 ; ROI9 very large table tests
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
	. I 'LOCAL W !,"OK - MIOUIT019"
	I LOCAL S FAIL=1
	Q
	;
BASECONF(CONF)
	D CONFDEF^MIOUI(.CONF)
	D INIT^MIOUI(.CONF)
	Q
	;
T001(FAIL)
	N CONF,REQ,CTX,TCTX
	D BASECONF(.CONF)
	D BUILDLARGE^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D EQ^MIOUIT000(.FAIL,"[T001][row count]",+$G(TCTX("large","main","rowCount")),5)
	D EQ^MIOUIT000(.FAIL,"[T001][selected count]",+$G(TCTX("large","main","selectedCount")),3)
	D EQ^MIOUIT000(.FAIL,"[T001][page]",+$G(TCTX("large","main","page")),3)
	D EQ^MIOUIT000(.FAIL,"[T001][per]",+$G(TCTX("large","main","per")),100)
	D EQ^MIOUIT000(.FAIL,"[T001][total]",+$G(TCTX("large","main","total")),24812)
	D EQ^MIOUIT000(.FAIL,"[T001][sorted col]",+$G(TCTX("large","main","col",5,"isSorted")),1)
	D EQ^MIOUIT000(.FAIL,"[T001][pinned col]",+$G(TCTX("large","main","col",1,"isPinned")),1)
	D EQ^MIOUIT000(.FAIL,"[T001][expanded row]",+$G(TCTX("large","main","row",1,"isExpanded")),1)
	Q
	;
T010(FAIL)
	N CONF,REQ,CTX,TCTX,OUT,ERR
	D BASECONF(.CONF)
	D BUILDLARGE^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_large_table.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
	D CONTAINS^MIOUIT000(.FAIL,"[T010][title]",OUT,"Large claims queue")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][results]",OUT,"24812 results")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][window]",OUT,"Rows 201-300 of 24812")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][sort]",OUT,"Sort by charge desc")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][density]",OUT,"Density switcher")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][filters]",OUT,"Filters")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][column order]",OUT,"Visible column order")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][pinned]",OUT,"Pinned")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][expander]",OUT,"Expanded row detail")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][totals]",OUT,"Page totals")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][code]",OUT,"99213")
	Q
	;
T020(FAIL)
	N CONF
	K ^MIO("ROUTE","RAW","GET","/mioui/large-table")
	D REG^MIOUIDEMO(.CONF)
	D EQ^MIOUIT000(.FAIL,"[T020][route target]",$G(^MIO("ROUTE","RAW","GET","/mioui/large-table")),"LARGETABLE^MIOUIDEMO")
	D EQ^MIOUIT000(.FAIL,"[T020][route auth]",+$G(^MIO("ROUTE","META","GET","/mioui/large-table","authRequired")),0)
	Q
	;
T030(FAIL)
	N REG,I
	D LIST^MIOUIREG(.REG)
	S I=$$FIND^MIOUIREG(.REG,"large_table_builder")
	D EQ^MIOUIT000(.FAIL,"[T030][builder status]",$G(REG(I,"status")),"implemented")
	D EQ^MIOUIT000(.FAIL,"[T030][builder test]",$G(REG(I,"test")),"MIOUIT019")
	S I=$$FIND^MIOUIREG(.REG,"page_large_table")
	D EQ^MIOUIT000(.FAIL,"[T030][page status]",$G(REG(I,"status")),"implemented")
	S I=$$FIND^MIOUIREG(.REG,"large_table_toolbar")
	D EQ^MIOUIT000(.FAIL,"[T030][toolbar status]",$G(REG(I,"status")),"implemented")
	S I=$$FIND^MIOUIREG(.REG,"large_table_filters")
	D EQ^MIOUIT000(.FAIL,"[T030][filters status]",$G(REG(I,"status")),"implemented")
	S I=$$FIND^MIOUIREG(.REG,"data_grid_server_sort")
	D EQ^MIOUIT000(.FAIL,"[T030][server sort status]",$G(REG(I,"status")),"implemented")
	S I=$$FIND^MIOUIREG(.REG,"data_grid_footer_totals")
	D EQ^MIOUIT000(.FAIL,"[T030][footer totals status]",$G(REG(I,"status")),"implemented")
	S I=$$FIND^MIOUIREG(.REG,"data_grid_virtual_window")
	D EQ^MIOUIT000(.FAIL,"[T030][virtual window phase]",$G(REG(I,"phase")),"P1")
	Q
	;
	;