MIOUIBILLT013 ; Cashflow and denial builder coverage
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIBILLT013"
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N CONF,REQ,CTX,TCTX
 D CONFDEF^MIOUI(.CONF)
 D BUILDREPC^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T001][mode]",$G(TCTX("billMode")),"reports-cashflow")
 D EQ^MIOUIT000(.FAIL,"[T001][title]",$G(TCTX("page","title")),"MIOUI / Billing / Cashflow studio")
 D EQ^MIOUIT000(.FAIL,"[T001][footer cashflow]",$G(TCTX("footer","links",17,"href")),"/mioui/billing-reports-cashflow")
 D EQ^MIOUIT000(.FAIL,"[T001][headline]",$G(TCTX("billReportCash","headline")),"Posted cash run-rate")
 D EQ^MIOUIT000(.FAIL,"[T001][run 8]",$G(TCTX("billReportCash","run",8,"label")),"Today")
 D EQ^MIOUIT000(.FAIL,"[T001][mix 1]",$G(TCTX("billReportCash","mix",1,"label")),"ERA auto-post")
 D EQ^MIOUIT000(.FAIL,"[T001][lag 4]",$G(TCTX("billReportCash","lag",4,"label")),"Tri-State Employer Health")
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX
 D CONFDEF^MIOUI(.CONF)
 D BUILDREPN^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T010][mode]",$G(TCTX("billMode")),"reports-denials")
 D EQ^MIOUIT000(.FAIL,"[T010][title]",$G(TCTX("page","title")),"MIOUI / Billing / Denial intelligence")
 D EQ^MIOUIT000(.FAIL,"[T010][footer denials]",$G(TCTX("footer","links",18,"href")),"/mioui/billing-reports-denials")
 D EQ^MIOUIT000(.FAIL,"[T010][headline]",$G(TCTX("billReportDenial","headline")),"Denial reason stream")
 D EQ^MIOUIT000(.FAIL,"[T010][stream 2]",$G(TCTX("billReportDenial","stream",2,"title")),"Medical necessity")
 D EQ^MIOUIT000(.FAIL,"[T010][matrix row]",$G(TCTX("billReportDenial","matrix",3,"label")),"Eligibility")
 D EQ^MIOUIT000(.FAIL,"[T010][ladder 5]",$G(TCTX("billReportDenial","ladder",5,"label")),"16+ days")
 Q
 ;
