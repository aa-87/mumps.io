MIOUIT011 ; P1 primitive component smoke tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 D T020(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIT011"
 I LOCAL S FAIL=1
 Q
 ;
BASECONF(CONF)
 D CONFDEF^MIOUI(.CONF)
 Q
 ;
T001(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDCOMP^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_components.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T001][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T001][badge]",OUT,"Published")
 D CONTAINS^MIOUIT000(.FAIL,"[T001][button]",OUT,"Primary action")
 D CONTAINS^MIOUIT000(.FAIL,"[T001][empty]",OUT,"No jobs matched this filter")
 D CONTAINS^MIOUIT000(.FAIL,"[T001][alert]",OUT,"Reserve warning panels for operator attention")
 D CONTAINS^MIOUIT000(.FAIL,"[T001][tabs]",OUT,"Foundation")
 D CONTAINS^MIOUIT000(.FAIL,"[T001][stepper]",OUT,"Claims, lines, diagnostics, and trace visible")
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDTABLES^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_tables.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T010][toolbar]",OUT,"Search claims, patients, and payers")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][bulk]",OUT,"2 selected")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][filters]",OUT,"Filter set")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][pager]",OUT,"Page 1 of 4")
 Q
 ;
T020(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDFORMS^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_forms.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T020][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T020][field help]",OUT,"Short and specific")
 D CONTAINS^MIOUIT000(.FAIL,"[T020][field error]",OUT,"At least one field key is required")
 Q
 ;
