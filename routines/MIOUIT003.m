MIOUIT003 ; theme tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 D T020(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIT003"
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N CONF
 D DEFAULTS^MIOUITHEME(.CONF)
 D EQ^MIOUIT000(.FAIL,"[T001][default mode]",$G(CONF("mioui","theme","default")),"dark")
 D EQ^MIOUIT000(.FAIL,"[T001][default density]",$G(CONF("mioui","density")),"dense")
 D EQ^MIOUIT000(.FAIL,"[T001][page size]",+$G(CONF("mioui","table","pageSize",2)),50)
 Q
 ;
T010(FAIL)
 N CONF,TCTX
 D DEFAULTS^MIOUITHEME(.CONF)
 S TCTX("theme","mode")="light",TCTX("theme","density")="normal"
 D APPLY^MIOUITHEME(.CONF,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T010][mode]",$G(TCTX("theme","mode")),"light")
 D EQ^MIOUIT000(.FAIL,"[T010][density]",$G(TCTX("theme","density")),"normal")
 D EQ^MIOUIT000(.FAIL,"[T010][toggle label]",$G(TCTX("theme","toggleLabel")),"Dark mode")
 D EQ^MIOUIT000(.FAIL,"[T010][density label]",$G(TCTX("theme","densityLabel")),"Normal density")
 Q
 ;
T020(FAIL)
 D EQ^MIOUIT000(.FAIL,"[T020][mode fallback]",$$MODE^MIOUITHEME("bad"),"dark")
 D EQ^MIOUIT000(.FAIL,"[T020][density fallback]",$$DENSITY^MIOUITHEME("bad"),"dense")
 D EQ^MIOUIT000(.FAIL,"[T020][tone fallback]",$$TONE^MIOUITHEME("bad"),"slate")
 D EQ^MIOUIT000(.FAIL,"[T020][badge]",$$BADGE^MIOUITHEME("emerald"),"badge-emerald")
 D EQ^MIOUIT000(.FAIL,"[T020][panel]",$$PANEL^MIOUITHEME("rose"),"tone-rose")
 Q
 ;
