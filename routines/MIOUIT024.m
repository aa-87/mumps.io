MIOUIT024 ; ROI14 data-intensive layout structure tests
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
 . I 'LOCAL W !,"OK - MIOUIT024"
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
 D BUILD^MIOUILYT(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T001][mode count]",$$COUNT^MIOUICTX($NA(TCTX("layout","mode"))),5)
 D EQ^MIOUIT000(.FAIL,"[T001][command metrics]",$$COUNT^MIOUICTX($NA(TCTX("layout","command","metric"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][tri cols]",$$COUNT^MIOUICTX($NA(TCTX("layout","tri","col"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][focus sections]",$$COUNT^MIOUICTX($NA(TCTX("layout","focus","section"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][board cols]",$$COUNT^MIOUICTX($NA(TCTX("layout","board","col"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][analytics rows]",$$COUNT^MIOUICTX($NA(TCTX("layout","analytics","row"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][active mode]",+$G(TCTX("layout","mode",1,"isActive")),1)
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILD^MIOUILYT(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_data_layouts.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T010][title]",OUT,"Data application layouts")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][modes]",OUT,"Layout modes")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][command]",OUT,"Operator command center")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][tri split]",OUT,"Tri-split queue layout")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][focus]",OUT,"Focus inspector layout")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][board]",OUT,"Board + rail layout")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][analytics]",OUT,"Analytics canvas")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][sticky rail]",OUT,"Sticky bottom action rail")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][callback A]",OUT,"publishReviewed")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][callback B]",OUT,"syncTraceToSelection")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][callback C]",OUT,"applyFormulaPreset")
 Q
 ;
T020(FAIL)
 N CONF
 K ^MIO("ROUTE","RAW","GET","/mioui/data-layouts")
 D REG^MIOUILYT(.CONF)
 D EQ^MIOUIT000(.FAIL,"[T020][route target]",$G(^MIO("ROUTE","RAW","GET","/mioui/data-layouts")),"DATALAYOUTS^MIOUILYT")
 D EQ^MIOUIT000(.FAIL,"[T020][route auth]",+$G(^MIO("ROUTE","META","GET","/mioui/data-layouts","authRequired")),0)
 Q
 ;
T030(FAIL)
 N REG,I
 D LIST^MIOUIREG(.REG)
 S I=$$FIND^MIOUIREG(.REG,"data_layout_builder")
 D EQ^MIOUIT000(.FAIL,"[T030][builder status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T030][builder phase]",$G(REG(I,"phase")),"P2")
 D EQ^MIOUIT000(.FAIL,"[T030][builder test]",$G(REG(I,"test")),"MIOUIT024")
 S I=$$FIND^MIOUIREG(.REG,"layout_mode_switcher")
 D EQ^MIOUIT000(.FAIL,"[T030][mode switcher status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"ops_command_center_layout")
 D EQ^MIOUIT000(.FAIL,"[T030][command status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"tri_split_queue_layout")
 D EQ^MIOUIT000(.FAIL,"[T030][tri status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"focus_inspector_layout")
 D EQ^MIOUIT000(.FAIL,"[T030][focus status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"board_rail_layout")
 D EQ^MIOUIT000(.FAIL,"[T030][board status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"analytics_canvas_layout")
 D EQ^MIOUIT000(.FAIL,"[T030][analytics status]",$G(REG(I,"status")),"implemented")
 Q
 ;
