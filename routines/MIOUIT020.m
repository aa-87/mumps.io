MIOUIT020 ; ROI10/12 million-row and advanced mechanics registry alignment tests
	D START Q
	;
START(FAIL)
	N LOCAL,TOP
	S TOP='$D(FAIL),LOCAL=0
	D T001(.LOCAL)
	D T010(.LOCAL)
	D T020(.LOCAL)
	D T030(.LOCAL)
	D T040(.LOCAL)
	I TOP D  Q
	. I 'LOCAL W !,"OK - MIOUIT020"
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
	D BUILDMILLION^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D EQ^MIOUIT000(.FAIL,"[T001][total rows]",+$G(TCTX("mega","main","totalRows")),1000000)
	D EQ^MIOUIT000(.FAIL,"[T001][total columns]",+$G(TCTX("mega","main","totalColumns")),20)
	D EQ^MIOUIT000(.FAIL,"[T001][visible columns]",+$G(TCTX("mega","main","visibleColumnCount")),20)
	D EQ^MIOUIT000(.FAIL,"[T001][selected columns]",+$G(TCTX("mega","main","selectedColumnCount")),8)
	D EQ^MIOUIT000(.FAIL,"[T001][page]",+$G(TCTX("mega","main","page")),4000)
	D EQ^MIOUIT000(.FAIL,"[T001][per]",+$G(TCTX("mega","main","per")),250)
	D EQ^MIOUIT000(.FAIL,"[T001][row count]",+$G(TCTX("mega","main","rowCount")),5)
	D EQ^MIOUIT000(.FAIL,"[T001][expanded row]",+$G(TCTX("mega","main","row",1,"isExpanded")),1)
	D EQ^MIOUIT000(.FAIL,"[T001][sorted col]",+$G(TCTX("mega","main","col",7,"isSorted")),1)
	D EQ^MIOUIT000(.FAIL,"[T001][callback count]",$$COUNT^MIOUICTX($NA(TCTX("mega","main","callback"))),3)
	Q
	;
T010(FAIL)
	N CONF,REQ,CTX,TCTX,OUT,ERR
	D BASECONF(.CONF)
	D BUILDMILLION^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_million_table.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
	D CONTAINS^MIOUIT000(.FAIL,"[T010][title]",OUT,"Million-row claims queue")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][rows]",OUT,"1,000,000 rows")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][columns]",OUT,"20 columns")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][search]",OUT,"alpha health 99213 west")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][filters]",OUT,"Status filters")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][selected columns]",OUT,"Selected columns")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][callbacks]",OUT,"applyColumnPreset")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][page label]",OUT,"Page 4000 of 4000")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][window]",OUT,"Rows 999751-1000000 of 1000000")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][code]",OUT,"99213")
	D CONTAINS^MIOUIT000(.FAIL,"[T010][expanded]",OUT,"Expanded row detail")
	Q
	;
T020(FAIL)
	N REG,I
	D LIST^MIOUIREG(.REG)
	S I=$$FIND^MIOUIREG(.REG,"data_grid_multi_sort")
	D EQ^MIOUIT000(.FAIL,"[T020][multi sort status]",$G(REG(I,"status")),"implemented")
	D EQ^MIOUIT000(.FAIL,"[T020][multi sort phase]",$G(REG(I,"phase")),"P1")
	S I=$$FIND^MIOUIREG(.REG,"data_grid_virtual_window")
	D EQ^MIOUIT000(.FAIL,"[T020][virtual window status]",$G(REG(I,"status")),"implemented")
	D EQ^MIOUIT000(.FAIL,"[T020][virtual window phase]",$G(REG(I,"phase")),"P1")
	S I=$$FIND^MIOUIREG(.REG,"data_grid_column_resize")
	D EQ^MIOUIT000(.FAIL,"[T020][resize status]",$G(REG(I,"status")),"implemented")
	D EQ^MIOUIT000(.FAIL,"[T020][resize phase]",$G(REG(I,"phase")),"P1")
	Q
	;
T030(FAIL)
	N REG,I
	D LIST^MIOUIREG(.REG)
	S I=$$FIND^MIOUIREG(.REG,"data_grid_virtual_window")
	D EQ^MIOUIT000(.FAIL,"[T030][virtual window planned]",$G(REG(I,"status")),"implemented")
	D EQ^MIOUIT000(.FAIL,"[T030][virtual window phase]",$G(REG(I,"phase")),"P1")
	S I=$$FIND^MIOUIREG(.REG,"data_grid_column_resize")
	D EQ^MIOUIT000(.FAIL,"[T030][resize phase]",$G(REG(I,"phase")),"P1")
	Q
	;
T040(FAIL)
	N CONF
	K ^MIO("ROUTE","RAW","GET","/mioui/million-table")
	D REG^MIOUIDEMO(.CONF)
	D EQ^MIOUIT000(.FAIL,"[T040][route target]",$G(^MIO("ROUTE","RAW","GET","/mioui/million-table")),"MILLIONTABLE^MIOUIDEMO")
	D EQ^MIOUIT000(.FAIL,"[T040][route auth]",+$G(^MIO("ROUTE","META","GET","/mioui/million-table","authRequired")),0)
	Q
	;
	;