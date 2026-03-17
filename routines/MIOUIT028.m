MIOUIT028 ; ROI18 layout choreography tests
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
 . I 'LOCAL W !,"OK - MIOUIT028"
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
 D BUILD^MIOUICLY(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T001][dock count]",$$COUNT^MIOUICTX($NA(TCTX("dock"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][presence count]",$$COUNT^MIOUICTX($NA(TCTX("presence"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][compare count]",$$COUNT^MIOUICTX($NA(TCTX("compare"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][sequence count]",$$COUNT^MIOUICTX($NA(TCTX("sequence"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][hotspot count]",$$COUNT^MIOUICTX($NA(TCTX("hotspot"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][policy callback]",$G(TCTX("policyCallback")),"applyPolicyQaLead")
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILD^MIOUICLY(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_layout_choreography.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T010][title]",OUT,"Layout choreography")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][policy]",OUT,"Layout policy banner")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][dock]",OUT,"Workspace dock matrix")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][presence]",OUT,"Collaboration presence rail")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][compare]",OUT,"Route snapshot compare")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][sequence]",OUT,"Transition sequence panel")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][hotspot]",OUT,"Attention hotspot map")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][policy callback]",OUT,"applyPolicyQaLead")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][dock callback]",OUT,"jumpDockEvidenceRail")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][presence callback]",OUT,"openPresenceSupervisor")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][compare callback]",OUT,"compareSnapshotCollectorVsQa")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][sequence callback]",OUT,"runTransitionSequenceReview")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][hotspot callback]",OUT,"centerAttentionHotspotClaims")
 Q
 ;
T020(FAIL)
 N CONF
 K ^MIO("ROUTE","RAW","GET","/mioui/layout-choreography")
 D REG^MIOUICLY(.CONF)
 D EQ^MIOUIT000(.FAIL,"[T020][route target]",$G(^MIO("ROUTE","RAW","GET","/mioui/layout-choreography")),"CHOREO^MIOUICLY")
 D EQ^MIOUIT000(.FAIL,"[T020][route auth]",+$G(^MIO("ROUTE","META","GET","/mioui/layout-choreography","authRequired")),0)
 Q
 ;
T030(FAIL)
 N REG,I
 D LIST^MIOUIREG(.REG)
 S I=$$FIND^MIOUIREG(.REG,"layout_choreography_builder")
 D EQ^MIOUIT000(.FAIL,"[T030][builder status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T030][builder phase]",$G(REG(I,"phase")),"P3")
 D EQ^MIOUIT000(.FAIL,"[T030][builder test]",$G(REG(I,"test")),"MIOUIT028")
 S I=$$FIND^MIOUIREG(.REG,"layout_policy_banner")
 D EQ^MIOUIT000(.FAIL,"[T030][policy status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"workspace_dock_matrix")
 D EQ^MIOUIT000(.FAIL,"[T030][dock status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"collaboration_presence_rail")
 D EQ^MIOUIT000(.FAIL,"[T030][presence status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"route_snapshot_compare")
 D EQ^MIOUIT000(.FAIL,"[T030][compare status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"transition_sequence_panel")
 D EQ^MIOUIT000(.FAIL,"[T030][sequence status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"attention_hotspot_map")
 D EQ^MIOUIT000(.FAIL,"[T030][hotspot status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"page_layout_choreography")
 D EQ^MIOUIT000(.FAIL,"[T030][page status]",$G(REG(I,"status")),"implemented")
 Q
 ;
