MIOUIBILLT011 ; Forecast and benchmark builder coverage
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIBILLT011"
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N CONF,REQ,CTX,TCTX
 D CONFDEF^MIOUI(.CONF)
 D BUILDREPF^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T001][mode]",$G(TCTX("billMode")),"reports-forecast")
 D EQ^MIOUIT000(.FAIL,"[T001][title]",$G(TCTX("page","title")),"MIOUI / Billing / Forecast studio")
 D EQ^MIOUIT000(.FAIL,"[T001][footer forecast]",$G(TCTX("footer","links",15,"href")),"/mioui/billing-reports-forecast")
 D EQ^MIOUIT000(.FAIL,"[T001][headline]",$G(TCTX("billReportForecast","headline")),"Six-week cash forecast")
 D EQ^MIOUIT000(.FAIL,"[T001][week 4]",$G(TCTX("billReportForecast","point",4,"label")),"Week 4")
 D EQ^MIOUIT000(.FAIL,"[T001][scenario]",$G(TCTX("billReportForecast","scenario",2,"title")),"Commit case")
 D EQ^MIOUIT000(.FAIL,"[T001][bridge]",$G(TCTX("billReportForecast","bridge",6,"label")),"Projected close")
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX
 D CONFDEF^MIOUI(.CONF)
 D BUILDREPB^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T010][mode]",$G(TCTX("billMode")),"reports-benchmark")
 D EQ^MIOUIT000(.FAIL,"[T010][title]",$G(TCTX("page","title")),"MIOUI / Billing / Benchmark deck")
 D EQ^MIOUIT000(.FAIL,"[T010][footer benchmark]",$G(TCTX("footer","links",16,"href")),"/mioui/billing-reports-benchmark")
 D EQ^MIOUIT000(.FAIL,"[T010][headline]",$G(TCTX("billReportBench","headline")),"Peer and payer benchmark ladder")
 D EQ^MIOUIT000(.FAIL,"[T010][ladder 1]",$G(TCTX("billReportBench","ladder",1,"label")),"Net collection rate")
 D EQ^MIOUIT000(.FAIL,"[T010][matrix row]",$G(TCTX("billReportBench","matrix",3,"label")),"Denial rate")
 D EQ^MIOUIT000(.FAIL,"[T010][scorecard]",$G(TCTX("billReportBench","scorecard",4,"title")),"Tri-State Employer Health")
 Q
 ;
