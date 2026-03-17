MIOUIBILLT016 ; Productivity and underpayments render coverage
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIBILLT016"
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDREPP^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_reports_productivity.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T001][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T001][root]",OUT,"data-miouibill-report-productivity-root")
 D HAS^MIOUIT000(.FAIL,"[T001][title]",OUT,"Billing productivity studio")
 D HAS^MIOUIT000(.FAIL,"[T001][headline]",OUT,"Collector and biller productivity")
 D HAS^MIOUIT000(.FAIL,"[T001][touches]",OUT,"Touches per day")
 D HAS^MIOUIT000(.FAIL,"[T001][team member]",OUT,"B. Ortega")
 D HAS^MIOUIT000(.FAIL,"[T001][heatmap]",OUT,"Queue touch heatmap")
 D HAS^MIOUIT000(.FAIL,"[T001][denials]",OUT,"Denials")
 D HAS^MIOUIT000(.FAIL,"[T001][resolution]",OUT,"Same-day resolution")
 D HAS^MIOUIT000(.FAIL,"[T001][underpayments link]",OUT,"Open underpayments studio")
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDREPU^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_reports_underpayments.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T010][root]",OUT,"data-miouibill-report-underpayments-root")
 D HAS^MIOUIT000(.FAIL,"[T010][title]",OUT,"Billing underpayments studio")
 D HAS^MIOUIT000(.FAIL,"[T010][headline]",OUT,"Underpayment leakage map")
 D HAS^MIOUIT000(.FAIL,"[T010][waterfall]",OUT,"Underpayment waterfall")
 D HAS^MIOUIT000(.FAIL,"[T010][expected allowed]",OUT,"Expected allowed")
 D HAS^MIOUIT000(.FAIL,"[T010][lanes]",OUT,"Payer leakage lanes")
 D HAS^MIOUIT000(.FAIL,"[T010][lakeview]",OUT,"Lakeview Senior Advantage")
 D HAS^MIOUIT000(.FAIL,"[T010][matrix]",OUT,"Contract variance matrix")
 D HAS^MIOUIT000(.FAIL,"[T010][home infusion drugs]",OUT,"Home infusion drugs")
 D HAS^MIOUIT000(.FAIL,"[T010][card]",OUT,"Commercial infusion spread")
 D HAS^MIOUIT000(.FAIL,"[T010][productivity link]",OUT,"Open productivity studio")
 Q
 ;
