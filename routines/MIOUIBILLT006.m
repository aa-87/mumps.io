MIOUIBILLT006 ; Billing report route and render coverage
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIBILLT006"
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N CONF,REQ,CTX,TCTX
 D CONFDEF^MIOUI(.CONF)
 D BUILDREP^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T001][mode]",$G(TCTX("billMode")),"reports")
 D EQ^MIOUIT000(.FAIL,"[T001][page title]",$G(TCTX("page","title")),"MIOUI / Billing / Reports workspace")
 D EQ^MIOUIT000(.FAIL,"[T001][footer link]",$G(TCTX("footer","links",10,"href")),"/mioui/billing-reports")
 D EQ^MIOUIT000(.FAIL,"[T001][tab1]",$G(TCTX("billReport","tab",1,"key")),"summary")
 D EQ^MIOUIT000(.FAIL,"[T001][tab4]",$G(TCTX("billReport","tab",4,"key")),"exports")
 D EQ^MIOUIT000(.FAIL,"[T001][kpi count note]",$G(TCTX("billReport","kpi",6,"label")),"Cash Posted")
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDREP^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_reports.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T010][filters]",OUT,"Service Date")
 D HAS^MIOUIT000(.FAIL,"[T010][kpi gross]",OUT,"Gross Charges")
 D HAS^MIOUIT000(.FAIL,"[T010][kpi net]",OUT,"Net Collections")
 D HAS^MIOUIT000(.FAIL,"[T010][kpi fpr]",OUT,"First-Pass Rate")
 D HAS^MIOUIT000(.FAIL,"[T010][kpi ar]",OUT,"AR &gt; 60 Days")
 D HAS^MIOUIT000(.FAIL,"[T010][kpi denials]",OUT,"Open Denials")
 D HAS^MIOUIT000(.FAIL,"[T010][aging 31-60]",OUT,"31-60 Days")
 D HAS^MIOUIT000(.FAIL,"[T010][aging gt120]",OUT,"Greater than 120 Days")
 D HAS^MIOUIT000(.FAIL,"[T010][payer row]",OUT,"North Harbor Health Plan")
 D HAS^MIOUIT000(.FAIL,"[T010][payer days]",OUT,"Avg Days to Pay")
 D HAS^MIOUIT000(.FAIL,"[T010][reason title]",OUT,"Top denial reasons")
 D HAS^MIOUIT000(.FAIL,"[T010][reason item]",OUT,"Authorization missing or invalid")
 D HAS^MIOUIT000(.FAIL,"[T010][export item]",OUT,"Daily aging workbook")
 D HAS^MIOUIT000(.FAIL,"[T010][flag item]",OUT,"Auto-close small balance")
 Q
 ;
