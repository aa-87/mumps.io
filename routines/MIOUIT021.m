MIOUIT021 ; ROI11 table workbench tests
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
 . I 'LOCAL W !,"OK - MIOUIT021"
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
 D BUILD^MIOUITWB(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T001][metric count]",$$COUNT^MIOUICTX($NA(TCTX("workbench","metric"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][rule count]",$$COUNT^MIOUICTX($NA(TCTX("workbench","rule"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][chip count]",$$COUNT^MIOUICTX($NA(TCTX("workbench","chip"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][view count]",$$COUNT^MIOUICTX($NA(TCTX("workbench","view"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][bulk actions]",$$COUNT^MIOUICTX($NA(TCTX("workbench","bulk","action"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][inspector facts]",$$COUNT^MIOUICTX($NA(TCTX("workbench","inspect","fact"))),6)
 D EQ^MIOUIT000(.FAIL,"[T001][export actions]",$$COUNT^MIOUICTX($NA(TCTX("workbench","export","action"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][active view]",+$G(TCTX("workbench","view",1,"isActive")),1)
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILD^MIOUITWB(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_table_workbench.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T010][title]",OUT,"Detailed table workbench")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][metrics]",OUT,"Queue metrics")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][query builder]",OUT,"Query builder")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][saved views]",OUT,"Saved views")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][bulk actions]",OUT,"Bulk actions")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][inspector]",OUT,"Row inspector")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][export]",OUT,"Export current view")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][callback]",OUT,"exportCurrentViewCsv")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][procedure]",OUT,"99213")
 Q
 ;
T020(FAIL)
 N CONF
 K ^MIO("ROUTE","RAW","GET","/mioui/table-workbench")
 D REG^MIOUITWB(.CONF)
 D EQ^MIOUIT000(.FAIL,"[T020][route target]",$G(^MIO("ROUTE","RAW","GET","/mioui/table-workbench")),"TABLEWB^MIOUITWB")
 D EQ^MIOUIT000(.FAIL,"[T020][route auth]",+$G(^MIO("ROUTE","META","GET","/mioui/table-workbench","authRequired")),0)
 Q
 ;
T030(FAIL)
 N REG,I
 D LIST^MIOUIREG(.REG)
 S I=$$FIND^MIOUIREG(.REG,"table_workbench_builder")
 D EQ^MIOUIT000(.FAIL,"[T030][builder status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T030][builder test]",$G(REG(I,"test")),"MIOUIT021")
 S I=$$FIND^MIOUIREG(.REG,"table_metric_bar")
 D EQ^MIOUIT000(.FAIL,"[T030][metric bar status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"table_query_builder")
 D EQ^MIOUIT000(.FAIL,"[T030][query builder status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"table_saved_view_manager")
 D EQ^MIOUIT000(.FAIL,"[T030][saved views status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"table_bulk_action_drawer")
 D EQ^MIOUIT000(.FAIL,"[T030][bulk status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"row_inspector")
 D EQ^MIOUIT000(.FAIL,"[T030][inspector status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"data_grid_export_current_view")
 D EQ^MIOUIT000(.FAIL,"[T030][export current view status]",$G(REG(I,"status")),"implemented")
 Q
 ;
