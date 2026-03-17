MIOUIBILLT007 ; Billing report variant builder coverage
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIBILLT007"
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N CONF,REQ,CTX,TCTX
 D CONFDEF^MIOUI(.CONF)
 D BUILDREPD^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T001][mode]",$G(TCTX("billMode")),"reports-dense")
 D EQ^MIOUIT000(.FAIL,"[T001][title]",$G(TCTX("page","title")),"MIOUI / Billing / Reports dense console")
 D EQ^MIOUIT000(.FAIL,"[T001][footer dense]",$G(TCTX("footer","links",11,"href")),"/mioui/billing-reports-dense")
 D EQ^MIOUIT000(.FAIL,"[T001][tab1]",$G(TCTX("billReport","tab",1,"key")),"queues")
 D EQ^MIOUIT000(.FAIL,"[T001][queue lane]",$G(TCTX("billReportDense","queue",1,"title")),"Authorization recovery")
 D EQ^MIOUIT000(.FAIL,"[T001][queue owner]",$G(TCTX("billReportDense","queue",2,"owner")),"T. Reyes")
 D EQ^MIOUIT000(.FAIL,"[T001][trend day]",$G(TCTX("billReportDense","trend",5,"label")),"Fri")
 D EQ^MIOUIT000(.FAIL,"[T001][workspace class]",$G(TCTX("billReportDense","workspaceClass")),"h-[calc(100vh-16rem)] min-h-[44rem] overflow-hidden")
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX
 D CONFDEF^MIOUI(.CONF)
 D BUILDREPX^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T010][mode]",$G(TCTX("billMode")),"reports-executive")
 D EQ^MIOUIT000(.FAIL,"[T010][title]",$G(TCTX("page","title")),"MIOUI / Billing / Executive report snapshot")
 D EQ^MIOUIT000(.FAIL,"[T010][footer exec]",$G(TCTX("footer","links",12,"href")),"/mioui/billing-reports-executive")
 D EQ^MIOUIT000(.FAIL,"[T010][story1]",$G(TCTX("billReportExec","story",1,"title")),"Collections story")
 D EQ^MIOUIT000(.FAIL,"[T010][story3 badge]",$G(TCTX("billReportExec","story",3,"badgeClass")),"badge-violet")
 D EQ^MIOUIT000(.FAIL,"[T010][action2 owner]",$G(TCTX("billReportExec","action",2,"owner")),"Auth recovery · K. Morgan")
 D EQ^MIOUIT000(.FAIL,"[T010][action3 due]",$G(TCTX("billReportExec","action",3,"due")),"Within 24 hours")
 Q
 ;
