MIOUIT025 ; ROI15 adaptive dense workspace tests
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
 . I 'LOCAL W !,"OK - MIOUIT025"
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
 D BUILD^MIOUIADL(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T001][preset count]",$$COUNT^MIOUICTX($NA(TCTX("preset"))),5)
 D EQ^MIOUIT000(.FAIL,"[T001][focus count]",$$COUNT^MIOUICTX($NA(TCTX("focusPane"))),5)
 D EQ^MIOUIT000(.FAIL,"[T001][ratio count]",$$COUNT^MIOUICTX($NA(TCTX("ratio"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][rail count]",$$COUNT^MIOUICTX($NA(TCTX("rail"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][stack count]",$$COUNT^MIOUICTX($NA(TCTX("stack"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][shortcut count]",$$COUNT^MIOUICTX($NA(TCTX("shortcut"))),5)
 D EQ^MIOUIT000(.FAIL,"[T001][active preset]",+$G(TCTX("preset",1,"isActive")),1)
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILD^MIOUIADL(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_adaptive_workspaces.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T010][title]",OUT,"Adaptive dense workspaces")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][presets]",OUT,"Role and task presets")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][focus]",OUT,"Keyboard-first pane focus")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][ratios]",OUT,"Persistent pane ratios")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][rails]",OUT,"Collapsed rails")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][responsive]",OUT,"Responsive dense stacking")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][shortcuts]",OUT,"Keyboard shortcuts")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][preset callback]",OUT,"applyPresetRevenueFollowup")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][focus callback]",OUT,"focusTracePane")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][ratio callback]",OUT,"saveSplitPreset")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][rail callback]",OUT,"toggleRightRail")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][stack callback]",OUT,"useTabletDenseMode")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][shortcut callback]",OUT,"openShortcutOverlay")
 Q
 ;
T020(FAIL)
 N CONF
 K ^MIO("ROUTE","RAW","GET","/mioui/adaptive-workspaces")
 D REG^MIOUIADL(.CONF)
 D EQ^MIOUIT000(.FAIL,"[T020][route target]",$G(^MIO("ROUTE","RAW","GET","/mioui/adaptive-workspaces")),"ADAPTWS^MIOUIADL")
 D EQ^MIOUIT000(.FAIL,"[T020][route auth]",+$G(^MIO("ROUTE","META","GET","/mioui/adaptive-workspaces","authRequired")),0)
 Q
 ;
T030(FAIL)
 N REG,I
 D LIST^MIOUIREG(.REG)
 S I=$$FIND^MIOUIREG(.REG,"adaptive_dense_layout_builder")
 D EQ^MIOUIT000(.FAIL,"[T030][builder status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T030][builder phase]",$G(REG(I,"phase")),"P2")
 D EQ^MIOUIT000(.FAIL,"[T030][builder test]",$G(REG(I,"test")),"MIOUIT025")
 S I=$$FIND^MIOUIREG(.REG,"layout_role_preset_bar")
 D EQ^MIOUIT000(.FAIL,"[T030][preset status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"keyboard_pane_focus_map")
 D EQ^MIOUIT000(.FAIL,"[T030][focus status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"persistent_pane_ratios")
 D EQ^MIOUIT000(.FAIL,"[T030][ratio status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"collapsed_rail_toggle_strip")
 D EQ^MIOUIT000(.FAIL,"[T030][rail status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"responsive_dense_stack_layout")
 D EQ^MIOUIT000(.FAIL,"[T030][responsive status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"keyboard_shortcut_cheatsheet")
 D EQ^MIOUIT000(.FAIL,"[T030][shortcut status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"page_adaptive_workspaces")
 D EQ^MIOUIT000(.FAIL,"[T030][page status]",$G(REG(I,"status")),"implemented")
 Q
 ;
