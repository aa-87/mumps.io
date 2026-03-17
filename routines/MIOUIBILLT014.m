MIOUIBILLT014 ; Cashflow and denial render coverage
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIBILLT014"
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDREPC^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_reports_cashflow.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T001][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T001][cashflow root]",OUT,"data-miouibill-report-cashflow-root")
 D HAS^MIOUIT000(.FAIL,"[T001][cashflow title]",OUT,"Billing cashflow studio")
 D HAS^MIOUIT000(.FAIL,"[T001][runrate]",OUT,"Posted cash run-rate")
 D HAS^MIOUIT000(.FAIL,"[T001][today]",OUT,"Today")
 D HAS^MIOUIT000(.FAIL,"[T001][source mix]",OUT,"Cash source mix")
 D HAS^MIOUIT000(.FAIL,"[T001][era]",OUT,"ERA auto-post")
 D HAS^MIOUIT000(.FAIL,"[T001][lag]",OUT,"Payer remit lag")
 D HAS^MIOUIT000(.FAIL,"[T001][tri-state]",OUT,"Tri-State Employer Health")
 D HAS^MIOUIT000(.FAIL,"[T001][denial link]",OUT,"Open denial intelligence")
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDREPN^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_reports_denials.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T010][denials root]",OUT,"data-miouibill-report-denials-root")
 D HAS^MIOUIT000(.FAIL,"[T010][denials title]",OUT,"Billing denial intelligence")
 D HAS^MIOUIT000(.FAIL,"[T010][stream]",OUT,"Denial reason stream")
 D HAS^MIOUIT000(.FAIL,"[T010][medical necessity]",OUT,"Medical necessity")
 D HAS^MIOUIT000(.FAIL,"[T010][matrix]",OUT,"Payer risk matrix")
 D HAS^MIOUIT000(.FAIL,"[T010][commercial]",OUT,"Commercial")
 D HAS^MIOUIT000(.FAIL,"[T010][ladder]",OUT,"Appeal aging ladder")
 D HAS^MIOUIT000(.FAIL,"[T010][16 days]",OUT,"16+ days")
 D HAS^MIOUIT000(.FAIL,"[T010][cashflow link]",OUT,"Open cashflow studio")
 Q
 ;
