MIOUITTHE ; MIOUI theme tests
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
 . I 'LOCAL W !,"OK - MIOUITTHE"
 . Q
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N CONF
 D DEFAULTS^MIOUITHEME(.CONF)
 D EQ(.FAIL,"[T001][default mode]",$G(CONF("mioui","theme","default")),"dark")
 D EQ(.FAIL,"[T001][default density]",$G(CONF("mioui","density")),"dense")
 D EQ(.FAIL,"[T001][page size]",+$G(CONF("mioui","table","pageSize",2)),50)
 Q
 ;
T010(FAIL)
 N CONF,TCTX
 D DEFAULTS^MIOUITHEME(.CONF)
 S TCTX("theme","mode")="light",TCTX("theme","density")="normal"
 D APPLY^MIOUITHEME(.CONF,.TCTX)
 D EQ(.FAIL,"[T010][mode]",$G(TCTX("theme","mode")),"light")
 D EQ(.FAIL,"[T010][density]",$G(TCTX("theme","density")),"normal")
 D EQ(.FAIL,"[T010][label]",$G(TCTX("theme","toggleLabel")),"Dark mode")
 Q
 ;
T020(FAIL)
 D EQ(.FAIL,"[T020][tone fallback]",$$TONE^MIOUITHEME("bad"),"slate")
 D EQ(.FAIL,"[T020][badge]",$$BADGE^MIOUITHEME("emerald"),"badge-emerald")
 D EQ(.FAIL,"[T020][panel]",$$PANEL^MIOUITHEME("rose"),"tone-rose")
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
