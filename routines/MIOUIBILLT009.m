MIOUIBILLT009 ; Chart-focused report variant builder coverage
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIBILLT009"
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N CONF,REQ,CTX,TCTX
 D CONFDEF^MIOUI(.CONF)
 D BUILDREPA^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T001][mode]",$G(TCTX("billMode")),"reports-analytics")
 D EQ^MIOUIT000(.FAIL,"[T001][title]",$G(TCTX("page","title")),"MIOUI / Billing / Analytics studio")
 D EQ^MIOUIT000(.FAIL,"[T001][footer analytics]",$G(TCTX("footer","links",13,"href")),"/mioui/billing-reports-analytics")
 D EQ^MIOUIT000(.FAIL,"[T001][meter label]",$G(TCTX("billReportViz","meter","label")),"Net collection goal")
 D EQ^MIOUIT000(.FAIL,"[T001][trend day]",$G(TCTX("billReportViz","column",5,"label")),"Fri")
 D EQ^MIOUIT000(.FAIL,"[T001][bar payer]",$G(TCTX("billReportViz","bar",2,"label")),"Lakeview Senior Advantage")
 D EQ^MIOUIT000(.FAIL,"[T001][heat row]",$G(TCTX("billReportViz","heat",2,"label")),"Medical necessity")
 D EQ^MIOUIT000(.FAIL,"[T001][heat cell]",$G(TCTX("billReportViz","heat",1,"cell",1,"value")),"12")
 D EQ^MIOUIT000(.FAIL,"[T001][funnel stage]",$G(TCTX("billReportViz","funnel",4,"label")),"Appeal or follow-up")
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX
 D CONFDEF^MIOUI(.CONF)
 D BUILDREPW^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T010][mode]",$G(TCTX("billMode")),"reports-wallboard")
 D EQ^MIOUIT000(.FAIL,"[T010][title]",$G(TCTX("page","title")),"MIOUI / Billing / Visual wallboard")
 D EQ^MIOUIT000(.FAIL,"[T010][footer wallboard]",$G(TCTX("footer","links",14,"href")),"/mioui/billing-reports-wallboard")
 D EQ^MIOUIT000(.FAIL,"[T010][headline]",$G(TCTX("billReportWall","headline")),"Live chart wall")
 D EQ^MIOUIT000(.FAIL,"[T010][meter percent]",$G(TCTX("billReportViz","meter","percent")),"82.6")
 D EQ^MIOUIT000(.FAIL,"[T010][column count]",$G(TCTX("billReportViz","column",7,"label")),"Sun")
 D EQ^MIOUIT000(.FAIL,"[T010][segment]",$G(TCTX("billReportViz","segment",5,"label")),"120+")
 Q
 ;
