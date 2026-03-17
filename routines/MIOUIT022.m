MIOUIT022 ; ROI12 advanced table mechanics tests
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
 . I 'LOCAL W !,"OK - MIOUIT022"
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
 D BUILD^MIOUITMX(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T001][sort count]",$$COUNT^MIOUICTX($NA(TCTX("mxSort"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][jump count]",$$COUNT^MIOUICTX($NA(TCTX("mxJump"))),6)
 D EQ^MIOUIT000(.FAIL,"[T001][resize count]",$$COUNT^MIOUICTX($NA(TCTX("mxResize"))),6)
 D EQ^MIOUIT000(.FAIL,"[T001][group count]",$$COUNT^MIOUICTX($NA(TCTX("mxGroup"))),2)
 D EQ^MIOUIT000(.FAIL,"[T001][subtotal count]",$$COUNT^MIOUICTX($NA(TCTX("mxSubtotal"))),2)
 D EQ^MIOUIT000(.FAIL,"[T001][summary count]",$$COUNT^MIOUICTX($NA(TCTX("mxSummary"))),6)
 D EQ^MIOUIT000(.FAIL,"[T001][sort priority]",+$G(TCTX("mxSort",1,"priority")),1)
 D EQ^MIOUIT000(.FAIL,"[T001][jump label]",$G(TCTX("mxJump",6,"label")),"Last window")
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILD^MIOUITMX(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_advanced_table.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T010][title]",OUT,"Advanced table mechanics")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][multi sort]",OUT,"Multi-sort stack")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][virtual window]",OUT,"Virtual window navigator")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][resize]",OUT,"Column resize ruler")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][grouping]",OUT,"Grouped rows")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][subtotal]",OUT,"Subtotal bands")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][right frozen]",OUT,"Right-frozen summary")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][jump]",OUT,"Jump -500 windows")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][claim]",OUT,"CLM-501001")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][callback]",OUT,"resizeColumnWidth")
 Q
 ;
T020(FAIL)
 N CONF
 K ^MIO("ROUTE","RAW","GET","/mioui/advanced-table")
 D REG^MIOUITMX(.CONF)
 D EQ^MIOUIT000(.FAIL,"[T020][route target]",$G(^MIO("ROUTE","RAW","GET","/mioui/advanced-table")),"ADVTABLE^MIOUITMX")
 D EQ^MIOUIT000(.FAIL,"[T020][route auth]",+$G(^MIO("ROUTE","META","GET","/mioui/advanced-table","authRequired")),0)
 Q
 ;
T030(FAIL)
 N REG,I
 D LIST^MIOUIREG(.REG)
 S I=$$FIND^MIOUIREG(.REG,"advanced_table_mechanics_builder")
 D EQ^MIOUIT000(.FAIL,"[T030][builder status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T030][builder test]",$G(REG(I,"test")),"MIOUIT022")
 S I=$$FIND^MIOUIREG(.REG,"data_grid_multi_sort")
 D EQ^MIOUIT000(.FAIL,"[T030][multi sort status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"data_grid_virtual_window")
 D EQ^MIOUIT000(.FAIL,"[T030][virtual window status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"data_grid_column_resize")
 D EQ^MIOUIT000(.FAIL,"[T030][resize status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"data_grid_row_grouping")
 D EQ^MIOUIT000(.FAIL,"[T030][grouping status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"data_grid_subtotal_band")
 D EQ^MIOUIT000(.FAIL,"[T030][subtotal status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"data_grid_column_freeze_right")
 D EQ^MIOUIT000(.FAIL,"[T030][freeze right status]",$G(REG(I,"status")),"implemented")
 Q
 ;
