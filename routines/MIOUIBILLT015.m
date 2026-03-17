MIOUIBILLT015 ; Productivity and underpayments builder coverage
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIBILLT015"
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N CONF,REQ,CTX,TCTX
 D CONFDEF^MIOUI(.CONF)
 D BUILDREPP^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T001][mode]",$G(TCTX("billMode")),"reports-productivity")
 D EQ^MIOUIT000(.FAIL,"[T001][title]",$G(TCTX("page","title")),"MIOUI / Billing / Productivity studio")
 D EQ^MIOUIT000(.FAIL,"[T001][footer productivity]",$G(TCTX("footer","links",19,"href")),"/mioui/billing-reports-productivity")
 D EQ^MIOUIT000(.FAIL,"[T001][headline]",$G(TCTX("billReportProd","headline")),"Collector and biller productivity")
 D EQ^MIOUIT000(.FAIL,"[T001][team 3]",$G(TCTX("billReportProd","team",3,"label")),"B. Ortega")
 D EQ^MIOUIT000(.FAIL,"[T001][heat row]",$G(TCTX("billReportProd","heat",2,"label")),"Denials")
 D EQ^MIOUIT000(.FAIL,"[T001][heat cell]",$G(TCTX("billReportProd","heat",2,"cell",4,"value")),"17")
 D EQ^MIOUIT000(.FAIL,"[T001][leader]",$G(TCTX("billReportProd","leader",1,"title")),"K. Morgan")
 D EQ^MIOUIT000(.FAIL,"[T001][slope day]",$G(TCTX("billReportProd","slope",5,"label")),"Fri")
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX
 D CONFDEF^MIOUI(.CONF)
 D BUILDREPU^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T010][mode]",$G(TCTX("billMode")),"reports-underpayments")
 D EQ^MIOUIT000(.FAIL,"[T010][title]",$G(TCTX("page","title")),"MIOUI / Billing / Underpayments studio")
 D EQ^MIOUIT000(.FAIL,"[T010][footer underpayments]",$G(TCTX("footer","links",20,"href")),"/mioui/billing-reports-underpayments")
 D EQ^MIOUIT000(.FAIL,"[T010][headline]",$G(TCTX("billReportUnder","headline")),"Underpayment leakage map")
 D EQ^MIOUIT000(.FAIL,"[T010][waterfall 2]",$G(TCTX("billReportUnder","waterfall",2,"label")),"Expected allowed")
 D EQ^MIOUIT000(.FAIL,"[T010][lane 2]",$G(TCTX("billReportUnder","lane",2,"label")),"Lakeview Senior Advantage")
 D EQ^MIOUIT000(.FAIL,"[T010][matrix row]",$G(TCTX("billReportUnder","matrix",3,"label")),"Home infusion drugs")
 D EQ^MIOUIT000(.FAIL,"[T010][card 1]",$G(TCTX("billReportUnder","card",1,"title")),"Commercial infusion spread")
 Q
 ;
