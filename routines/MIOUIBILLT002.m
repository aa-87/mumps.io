MIOUIBILLT002 ; Route and render tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 D T020(.LOCAL)
 D T030(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIBILLT002"
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N CONF
 K ^MIO("ROUTE","RAW","GET","/mioui/billing-patient")
 K ^MIO("ROUTE","RAW","GET","/mioui/billing-patient-dense")
 K ^MIO("ROUTE","RAW","GET","/mioui/billing-patient-balanced")
 D REG^MIOUI(.CONF)
 D EQ^MIOUIT000(.FAIL,"[T001][route target]",$G(^MIO("ROUTE","RAW","GET","/mioui/billing-patient")),"PATIENT^MIOUIBILLD")
 D EQ^MIOUIT000(.FAIL,"[T001][route auth]",+$G(^MIO("ROUTE","META","GET","/mioui/billing-patient","authRequired")),0)
 D EQ^MIOUIT000(.FAIL,"[T001][dense target]",$G(^MIO("ROUTE","RAW","GET","/mioui/billing-patient-dense")),"PATIENTD^MIOUIBILLD")
 D EQ^MIOUIT000(.FAIL,"[T001][dense auth]",+$G(^MIO("ROUTE","META","GET","/mioui/billing-patient-dense","authRequired")),0)
 D EQ^MIOUIT000(.FAIL,"[T001][balanced target]",$G(^MIO("ROUTE","RAW","GET","/mioui/billing-patient-balanced")),"PATIENTB^MIOUIBILLD")
 D EQ^MIOUIT000(.FAIL,"[T001][balanced auth]",+$G(^MIO("ROUTE","META","GET","/mioui/billing-patient-balanced","authRequired")),0)
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILD^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_patient_review.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T010][claim id]",OUT,"CLMNO58274")
 D HAS^MIOUIT000(.FAIL,"[T010][key info]",OUT,"Key Info")
 D HAS^MIOUIT000(.FAIL,"[T010][claim label]",OUT,"Patient Ctrl Num (Claim ID)")
 D HAS^MIOUIT000(.FAIL,"[T010][subscriber]",OUT,"Insured Subscriber (Self, Primary)")
 D HAS^MIOUIT000(.FAIL,"[T010][billing provider]",OUT,"Billing Provider")
 D HAS^MIOUIT000(.FAIL,"[T010][submitter]",OUT,"Submitter")
 D HAS^MIOUIT000(.FAIL,"[T010][receiver]",OUT,"Receiver")
 D HAS^MIOUIT000(.FAIL,"[T010][txn title]",OUT,"HCPCS Procedure (S9500)")
 D HAS^MIOUIT000(.FAIL,"[T010][diag title]",OUT,"Related Diagnosis (J18.9)")
 D HAS^MIOUIT000(.FAIL,"[T010][ordering provider]",OUT,"Ordering Provider")
 D HAS^MIOUIT000(.FAIL,"[T010][expand]",OUT,"Expand All")
 D HAS^MIOUIT000(.FAIL,"[T010][collapse]",OUT,"Collapse All")
 D HAS^MIOUIT000(.FAIL,"[T010][loop0000]",OUT,"Loop: 0000")
 D HAS^MIOUIT000(.FAIL,"[T010][claim info loop]",OUT,"Claim Information")
 D HAS^MIOUIT000(.FAIL,"[T010][drug id loop]",OUT,"Drug Identification")
 Q
 ;
T020(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDD^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_patient_review_dense.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T020][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T020][workspace]",OUT,"data-miouibill-workspace")
 D HAS^MIOUIT000(.FAIL,"[T020][no page scroll]",OUT,"overflow-hidden")
 D HAS^MIOUIT000(.FAIL,"[T020][claim tab]",OUT,"data-miouibill-tab=""claim""")
 D HAS^MIOUIT000(.FAIL,"[T020][txn tab]",OUT,"data-miouibill-tab=""transactions""")
 D HAS^MIOUIT000(.FAIL,"[T020][x12 tab]",OUT,"data-miouibill-tab=""x12""")
 D HAS^MIOUIT000(.FAIL,"[T020][claim pane]",OUT,"data-miouibill-pane=""claim""")
 D HAS^MIOUIT000(.FAIL,"[T020][txn pane]",OUT,"data-miouibill-pane=""transactions""")
 D HAS^MIOUIT000(.FAIL,"[T020][x12 pane]",OUT,"data-miouibill-pane=""x12""")
 D HAS^MIOUIT000(.FAIL,"[T020][stacked link]",OUT,"Open stacked review")
 D HAS^MIOUIT000(.FAIL,"[T020][expand]",OUT,"Expand All")
 D HAS^MIOUIT000(.FAIL,"[T020][collapse]",OUT,"Collapse All")
 Q
 ;
T030(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDB^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_patient_review_balanced.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T030][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T030][root]",OUT,"data-miouibill-balanced")
 D HAS^MIOUIT000(.FAIL,"[T030][balanced review]",OUT,"Balanced review")
 D HAS^MIOUIT000(.FAIL,"[T030][tabs id]",OUT,"balanced-tabs")
 D HAS^MIOUIT000(.FAIL,"[T030][parties tab]",OUT,"data-miouibill-balanced-tab=""parties""")
 D HAS^MIOUIT000(.FAIL,"[T030][transactions tab]",OUT,"data-miouibill-balanced-tab=""transactions""")
 D HAS^MIOUIT000(.FAIL,"[T030][x12 tab]",OUT,"data-miouibill-balanced-tab=""x12""")
 D HAS^MIOUIT000(.FAIL,"[T030][parties pane]",OUT,"data-miouibill-balanced-pane=""parties""")
 D HAS^MIOUIT000(.FAIL,"[T030][transactions pane]",OUT,"data-miouibill-balanced-pane=""transactions""")
 D HAS^MIOUIT000(.FAIL,"[T030][x12 pane]",OUT,"data-miouibill-balanced-pane=""x12""")
 D HAS^MIOUIT000(.FAIL,"[T030][stacked link]",OUT,"Open stacked review")
 D HAS^MIOUIT000(.FAIL,"[T030][dense link]",OUT,"Open dense workspace")
 Q
 ;
