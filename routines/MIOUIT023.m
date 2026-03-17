MIOUIT023 ; ROI13 table review sync tests
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
 . I 'LOCAL W !,"OK - MIOUIT023"
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
 D BUILD^MIOUITSX(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T001][facet count]",$$COUNT^MIOUICTX($NA(TCTX("sync","facet"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][note count]",$$COUNT^MIOUICTX($NA(TCTX("sync","note"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][preset count]",$$COUNT^MIOUICTX($NA(TCTX("sync","preset"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][density count]",$$COUNT^MIOUICTX($NA(TCTX("sync","density"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][left facts]",$$COUNT^MIOUICTX($NA(TCTX("sync","compare","left","fact"))),5)
 D EQ^MIOUIT000(.FAIL,"[T001][right facts]",$$COUNT^MIOUICTX($NA(TCTX("sync","compare","right","fact"))),5)
 D EQ^MIOUIT000(.FAIL,"[T001][diff count]",$$COUNT^MIOUICTX($NA(TCTX("sync","compare","diff"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][split rows]",$$COUNT^MIOUICTX($NA(TCTX("sync","split","row"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][trace steps]",$$COUNT^MIOUICTX($NA(TCTX("sync","split","trace"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][active facet]",+$G(TCTX("sync","facet",1,"isActive")),1)
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILD^MIOUITSX(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_table_review_sync.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T010][title]",OUT,"Table review sync")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][facets]",OUT,"Facet counts")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][notes]",OUT,"Inline cell notes")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][presets]",OUT,"Width presets and density packs")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][compare]",OUT,"Compare two rows")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][sync]",OUT,"Split grid / trace synchronization")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][facet token]",OUT,"Clear all facets")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][note callback]",OUT,"openCellNote")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][preset callback]",OUT,"applyWidthPreset")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][density callback]",OUT,"applyDensityPack")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][trace callback]",OUT,"syncTraceToRow")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][row token]",OUT,"CLM-884210")
 Q
 ;
T020(FAIL)
 N CONF
 K ^MIO("ROUTE","RAW","GET","/mioui/table-review-sync")
 D REG^MIOUITSX(.CONF)
 D EQ^MIOUIT000(.FAIL,"[T020][route target]",$G(^MIO("ROUTE","RAW","GET","/mioui/table-review-sync")),"REVIEWSYNC^MIOUITSX")
 D EQ^MIOUIT000(.FAIL,"[T020][route auth]",+$G(^MIO("ROUTE","META","GET","/mioui/table-review-sync","authRequired")),0)
 Q
 ;
T030(FAIL)
 N REG,I
 D LIST^MIOUIREG(.REG)
 S I=$$FIND^MIOUIREG(.REG,"table_review_sync_builder")
 D EQ^MIOUIT000(.FAIL,"[T030][builder status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T030][builder phase]",$G(REG(I,"phase")),"P2")
 D EQ^MIOUIT000(.FAIL,"[T030][builder test]",$G(REG(I,"test")),"MIOUIT023")
 S I=$$FIND^MIOUIREG(.REG,"data_grid_facet_bar")
 D EQ^MIOUIT000(.FAIL,"[T030][facet status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"data_grid_inline_cell_notes")
 D EQ^MIOUIT000(.FAIL,"[T030][notes status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"data_grid_width_presets")
 D EQ^MIOUIT000(.FAIL,"[T030][width status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"data_grid_compare_rows")
 D EQ^MIOUIT000(.FAIL,"[T030][compare status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"data_grid_trace_sync")
 D EQ^MIOUIT000(.FAIL,"[T030][trace sync status]",$G(REG(I,"status")),"implemented")
 Q
 ;
