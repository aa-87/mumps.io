MIOUIT027 ; ROI17 layout transition and overlay tests
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
 . I 'LOCAL W !,"OK - MIOUIT027"
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
 D BUILD^MIOUILOV(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T001][transition count]",$$COUNT^MIOUICTX($NA(TCTX("transition"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][snapshot count]",$$COUNT^MIOUICTX($NA(TCTX("snapshot"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][route map count]",$$COUNT^MIOUICTX($NA(TCTX("routeMap"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][focus count]",$$COUNT^MIOUICTX($NA(TCTX("focusMode"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][handoff count]",$$COUNT^MIOUICTX($NA(TCTX("handoff"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][matrix count]",$$COUNT^MIOUICTX($NA(TCTX("matrix"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][active transition]",+$G(TCTX("transition",1,"isActive")),1)
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILD^MIOUILOV(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_layout_overlays.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T010][title]",OUT,"Layout transitions and overlays")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][transitions]",OUT,"Layout transitions")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][snapshots]",OUT,"Workspace snapshots")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][map]",OUT,"Cross-route workspace map")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][focus]",OUT,"Emergency focus layout")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][handoff]",OUT,"Shift handoff layout")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][matrix]",OUT,"Overlay density matrix")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][transition callback]",OUT,"activateTransitionAudit")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][snapshot callback]",OUT,"restoreSnapshotCollector")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][map callback]",OUT,"jumpRouteClaimReview")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][focus callback]",OUT,"enterEmergencyFocusMode")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][handoff callback]",OUT,"openShiftHandoffLayout")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][matrix callback]",OUT,"applyOverlayDensityMatrix")
 Q
 ;
T020(FAIL)
 N CONF
 K ^MIO("ROUTE","RAW","GET","/mioui/layout-overlays")
 D REG^MIOUILOV(.CONF)
 D EQ^MIOUIT000(.FAIL,"[T020][route target]",$G(^MIO("ROUTE","RAW","GET","/mioui/layout-overlays")),"OVERLAY^MIOUILOV")
 D EQ^MIOUIT000(.FAIL,"[T020][route auth]",+$G(^MIO("ROUTE","META","GET","/mioui/layout-overlays","authRequired")),0)
 Q
 ;
T030(FAIL)
 N REG,I
 D LIST^MIOUIREG(.REG)
 S I=$$FIND^MIOUIREG(.REG,"layout_overlay_builder")
 D EQ^MIOUIT000(.FAIL,"[T030][builder status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T030][builder phase]",$G(REG(I,"phase")),"P3")
 D EQ^MIOUIT000(.FAIL,"[T030][builder test]",$G(REG(I,"test")),"MIOUIT027")
 S I=$$FIND^MIOUIREG(.REG,"layout_transition_bar")
 D EQ^MIOUIT000(.FAIL,"[T030][transition status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"snapshot_restore_gallery")
 D EQ^MIOUIT000(.FAIL,"[T030][snapshot status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"cross_route_workspace_map")
 D EQ^MIOUIT000(.FAIL,"[T030][map status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"emergency_focus_layout")
 D EQ^MIOUIT000(.FAIL,"[T030][focus status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"shift_handoff_layout")
 D EQ^MIOUIT000(.FAIL,"[T030][handoff status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"overlay_density_matrix")
 D EQ^MIOUIT000(.FAIL,"[T030][matrix status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"page_layout_overlays")
 D EQ^MIOUIT000(.FAIL,"[T030][page status]",$G(REG(I,"status")),"implemented")
 Q
 ;
