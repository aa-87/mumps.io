MIOUIBILLT010 ; Chart-focused report render token coverage
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIBILLT010"
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDREPA^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_reports_analytics.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T001][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T001][analytics root]",OUT,"data-miouibill-report-analytics-root")
 D HAS^MIOUIT000(.FAIL,"[T001][analytics studio]",OUT,"Billing analytics studio")
 D HAS^MIOUIT000(.FAIL,"[T001][goal]",OUT,"Collection goal attainment")
 D HAS^MIOUIT000(.FAIL,"[T001][rhythm]",OUT,"Daily collections rhythm")
 D HAS^MIOUIT000(.FAIL,"[T001][payer graph]",OUT,"Payer mix and variance")
 D HAS^MIOUIT000(.FAIL,"[T001][aging graph]",OUT,"Aging distribution")
 D HAS^MIOUIT000(.FAIL,"[T001][heatmap]",OUT,"Denial heatmap")
 D HAS^MIOUIT000(.FAIL,"[T001][funnel]",OUT,"Clean claim funnel")
 D HAS^MIOUIT000(.FAIL,"[T001][wallboard link]",OUT,"Open visual wallboard")
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDREPW^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_reports_wallboard.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T010][wallboard root]",OUT,"data-miouibill-report-wallboard-root")
 D HAS^MIOUIT000(.FAIL,"[T010][wallboard title]",OUT,"Billing visual wallboard")
 D HAS^MIOUIT000(.FAIL,"[T010][headline]",OUT,"Live chart wall")
 D HAS^MIOUIT000(.FAIL,"[T010][subhead]",OUT,"Monitor-safe SSR layout")
 D HAS^MIOUIT000(.FAIL,"[T010][goal]",OUT,"Cash posted to target")
 D HAS^MIOUIT000(.FAIL,"[T010][trend]",OUT,"Daily collections rhythm")
 D HAS^MIOUIT000(.FAIL,"[T010][heatmap]",OUT,"Denial heatmap")
 D HAS^MIOUIT000(.FAIL,"[T010][kpi anchor]",OUT,"report-wallboard-kpis")
 D HAS^MIOUIT000(.FAIL,"[T010][analytics link]",OUT,"Open analytics studio")
 Q
 ;
