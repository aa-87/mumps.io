MIOUITCTX ; MIOUI context tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL)
 S LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 D T020(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUITCTX"
 . Q
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N TCTX
 D BASE^MIOUICTX(.TCTX)
 D EQ(.FAIL,"[T001][name]",$G(TCTX("app","name")),"MIOUI")
 D EQ(.FAIL,"[T001][nav count]",$O(TCTX("nav",""),-1),5)
 D EQ(.FAIL,"[T001][footer last]",$G(TCTX("footer","links",5,"label")),"Billing")
 Q
 ;
T010(FAIL)
 N TCTX
 D BASE^MIOUICTX(.TCTX)
 D ACT^MIOUICTX(.TCTX,"tables")
 D EQ(.FAIL,"[T010][tables active]",+$G(TCTX("nav",3,"isActive")),1)
 D EQ(.FAIL,"[T010][forms inactive]",+$G(TCTX("nav",4,"isActive")),0)
 Q
 ;
T020(FAIL)
 N TCTX
 D BASE^MIOUICTX(.TCTX)
 D ALERT^MIOUICTX(.TCTX,1,"amber","Warning","Test")
 D STEP^MIOUICTX(.TCTX,2,"Preview","Body","current")
 D TIMELINE^MIOUICTX(.TCTX,1,"Now","Built","Done","sky")
 D EQ(.FAIL,"[T020][alert class]",$G(TCTX("alert",1,"badgeClass")),"badge-amber")
 D EQ(.FAIL,"[T020][step current]",+$G(TCTX("stepper",2,"isCurrent")),1)
 D EQ(.FAIL,"[T020][timeline tone]",$G(TCTX("timeline",1,"tone")),"badge-sky")
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
