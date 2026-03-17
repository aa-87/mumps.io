MIOUIBILLT012 ; Forecast and benchmark render coverage
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIBILLT012"
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDREPF^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_reports_forecast.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T001][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T001][forecast root]",OUT,"data-miouibill-report-forecast-root")
 D HAS^MIOUIT000(.FAIL,"[T001][forecast title]",OUT,"Billing forecast studio")
 D HAS^MIOUIT000(.FAIL,"[T001][headline]",OUT,"Six-week cash forecast")
 D HAS^MIOUIT000(.FAIL,"[T001][week 6]",OUT,"Week 6")
 D HAS^MIOUIT000(.FAIL,"[T001][scenario spread]",OUT,"Three cash scenarios")
 D HAS^MIOUIT000(.FAIL,"[T001][stretch case]",OUT,"Stretch case")
 D HAS^MIOUIT000(.FAIL,"[T001][bridge]",OUT,"Projected cash bridge")
 D HAS^MIOUIT000(.FAIL,"[T001][projected close]",OUT,"Projected close")
 D HAS^MIOUIT000(.FAIL,"[T001][benchmark link]",OUT,"Open benchmark deck")
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDREPB^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_reports_benchmark.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T010][benchmark root]",OUT,"data-miouibill-report-benchmark-root")
 D HAS^MIOUIT000(.FAIL,"[T010][benchmark title]",OUT,"Billing benchmark deck")
 D HAS^MIOUIT000(.FAIL,"[T010][ladder]",OUT,"Peer and payer benchmark ladder")
 D HAS^MIOUIT000(.FAIL,"[T010][net collection]",OUT,"Net collection rate")
 D HAS^MIOUIT000(.FAIL,"[T010][matrix]",OUT,"Payer-family benchmark matrix")
 D HAS^MIOUIT000(.FAIL,"[T010][scorecards]",OUT,"Payer ranking cards")
 D HAS^MIOUIT000(.FAIL,"[T010][score]",OUT,"92 / 100")
 D HAS^MIOUIT000(.FAIL,"[T010][forecast link]",OUT,"Open forecast studio")
 D HAS^MIOUIT000(.FAIL,"[T010][payers id]",OUT,"report-benchmark-payers")
 Q
 ;
