MIOUIBILLT004 ; Balanced variant builder and layout coverage
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIBILLT004"
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N CONF,REQ,CTX,TCTX
 D CONFDEF^MIOUI(.CONF)
 D BUILDB^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T001][mode]",$G(TCTX("billMode")),"balanced")
 D EQ^MIOUIT000(.FAIL,"[T001][page title]",$G(TCTX("page","title")),"MIOUI / Billing / Patient balanced review")
 D EQ^MIOUIT000(.FAIL,"[T001][tab1 key]",$G(TCTX("billBalanced","tab",1,"key")),"parties")
 D EQ^MIOUIT000(.FAIL,"[T001][tab2 key]",$G(TCTX("billBalanced","tab",2,"key")),"transactions")
 D EQ^MIOUIT000(.FAIL,"[T001][tab3 key]",$G(TCTX("billBalanced","tab",3,"key")),"x12")
 D EQ^MIOUIT000(.FAIL,"[T001][footer link]",$G(TCTX("footer","links",9,"href")),"/mioui/billing-patient-balanced")
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDB^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_patient_review_balanced.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T010][balanced tabs label]",OUT,"Billing patient balanced tabs")
 D HAS^MIOUIT000(.FAIL,"[T010][hybrid copy]",OUT,"Mix of overview and speed")
 D HAS^MIOUIT000(.FAIL,"[T010][parties count]",OUT,"Patient and Parties")
 D HAS^MIOUIT000(.FAIL,"[T010][review modes]",OUT,"3 review modes inside one hybrid page")
 D HAS^MIOUIT000(.FAIL,"[T010][routing focus]",OUT,"Routing focus")
 D HAS^MIOUIT000(.FAIL,"[T010][open balanced tabs]",OUT,"Open balanced tabs")
 Q
 ;
