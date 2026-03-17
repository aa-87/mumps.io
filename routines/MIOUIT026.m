MIOUIT026 ; ROI16 workspace state orchestration tests
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
 . I 'LOCAL W !,"OK - MIOUIT026"
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
 D BUILD^MIOUILST(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T001][restore count]",$$COUNT^MIOUICTX($NA(TCTX("restore"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][role count]",$$COUNT^MIOUICTX($NA(TCTX("roleDefault"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][route count]",$$COUNT^MIOUICTX($NA(TCTX("routePersist"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][mobile count]",$$COUNT^MIOUICTX($NA(TCTX("mobileVariant"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][annotation count]",$$COUNT^MIOUICTX($NA(TCTX("annotation"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][active restore]",+$G(TCTX("restore",1,"isActive")),1)
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILD^MIOUILST(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_workspace_state.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T010][title]",OUT,"Workspace state orchestration")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][restore]",OUT,"Session-restored layout state")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][role]",OUT,"Auth-aware role defaults")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][route]",OUT,"Route-specific pane persistence")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][mobile]",OUT,"Mobile-first dense audit variants")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][annot]",OUT,"Threaded annotation rail")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][footer]",OUT,"Workspace state footer")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][restore callback]",OUT,"restoreQueueSession")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][role callback]",OUT,"useCollectorDefaultLayout")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][route callback]",OUT,"persistClaimReviewState")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][mobile callback]",OUT,"openTabletTraceVariant")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][annotation callback]",OUT,"openClaimAnnotationThread")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][state callback]",OUT,"saveWorkspaceStateNow")
 Q
 ;
T020(FAIL)
 N CONF
 K ^MIO("ROUTE","RAW","GET","/mioui/workspace-state")
 D REG^MIOUILST(.CONF)
 D EQ^MIOUIT000(.FAIL,"[T020][route target]",$G(^MIO("ROUTE","RAW","GET","/mioui/workspace-state")),"STATE^MIOUILST")
 D EQ^MIOUIT000(.FAIL,"[T020][route auth]",+$G(^MIO("ROUTE","META","GET","/mioui/workspace-state","authRequired")),0)
 Q
 ;
T030(FAIL)
 N REG,I
 D LIST^MIOUIREG(.REG)
 S I=$$FIND^MIOUIREG(.REG,"workspace_state_builder")
 D EQ^MIOUIT000(.FAIL,"[T030][builder status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T030][builder phase]",$G(REG(I,"phase")),"P2")
 D EQ^MIOUIT000(.FAIL,"[T030][builder test]",$G(REG(I,"test")),"MIOUIT026")
 S I=$$FIND^MIOUIREG(.REG,"session_layout_restore")
 D EQ^MIOUIT000(.FAIL,"[T030][restore status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"auth_role_default_layouts")
 D EQ^MIOUIT000(.FAIL,"[T030][role status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"route_pane_persistence")
 D EQ^MIOUIT000(.FAIL,"[T030][route status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"mobile_audit_layout_variants")
 D EQ^MIOUIT000(.FAIL,"[T030][mobile status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"annotation_state_rail")
 D EQ^MIOUIT000(.FAIL,"[T030][annotation status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"workspace_state_footer")
 D EQ^MIOUIT000(.FAIL,"[T030][footer status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"page_workspace_state")
 D EQ^MIOUIT000(.FAIL,"[T030][page status]",$G(REG(I,"status")),"implemented")
 Q
 ;
