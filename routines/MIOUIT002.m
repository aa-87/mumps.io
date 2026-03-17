MIOUIT002 ; shared shell context tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIT002"
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N TCTX
 D BASE^MIOUICTX(.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T001][nav count]",$O(TCTX("nav",""),-1),6)
 D EQ^MIOUIT000(.FAIL,"[T001][footer last]",$G(TCTX("footer","links",6,"label")),"Billing")
 D EQ^MIOUIT000(.FAIL,"[T001][search shown]",+$G(TCTX("shell","showSearch")),1)
 D EQ^MIOUIT000(.FAIL,"[T001][export nav label]",$G(TCTX("nav",5,"label")),"Export")
 D EQ^MIOUIT000(.FAIL,"[T001][billing nav label]",$G(TCTX("nav",6,"label")),"Billing")
 Q
 ;
T010(FAIL)
 N TCTX
 D BASE^MIOUICTX(.TCTX)
 D ACT^MIOUICTX(.TCTX,"export")
 D EQ^MIOUIT000(.FAIL,"[T010][export active]",+$G(TCTX("nav",5,"isActive")),1)
 D EQ^MIOUIT000(.FAIL,"[T010][billing inactive]",+$G(TCTX("nav",6,"isActive")),0)
 D ACT^MIOUICTX(.TCTX,"billing")
 D EQ^MIOUIT000(.FAIL,"[T010][billing active]",+$G(TCTX("nav",6,"isActive")),1)
 Q
 ;
