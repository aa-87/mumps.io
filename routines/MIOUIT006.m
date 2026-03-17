MIOUIT006 ; form contract tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 D T020(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIT006"
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N TCTX
 D INIT^MIOUIFORM(.TCTX,"profile","Profile","Lead","/save","post")
 D FIELD^MIOUIFORM(.TCTX,"profile",1,"text","name","Name","Claims Review","","help","")
 D FIELD^MIOUIFORM(.TCTX,"profile",2,"select","mode","Mode","claim_summary","","help","")
 D OPTION^MIOUIFORM(.TCTX,"profile",2,1,"claim_summary","Claim summary",1)
 D ACTION^MIOUIFORM(.TCTX,"profile",1,"Save","submit","primary")
 D FINAL^MIOUIFORM(.TCTX,"profile")
 D EQ^MIOUIT000(.FAIL,"[T001][title]",$G(TCTX("form","profile","title")),"Profile")
 D EQ^MIOUIT000(.FAIL,"[T001][field count]",+$G(TCTX("form","profile","fieldCount")),2)
 D EQ^MIOUIT000(.FAIL,"[T001][selected]",+$G(TCTX("form","profile","field",2,"option",1,"isSelected")),1)
 D EQ^MIOUIT000(.FAIL,"[T001][action tone]",$G(TCTX("form","profile","actionBtn",1,"tone")),"primary-button")
 D EQ^MIOUIT000(.FAIL,"[T001][action class]",$G(TCTX("form","profile","actionBtn",1,"class")),"primary-button")
 Q
 ;
T010(FAIL)
 N TCTX
 D INIT^MIOUIFORM(.TCTX,"flags","Flags","Lead","/save","post")
 D FIELD^MIOUIFORM(.TCTX,"flags",1,"checkbox","headers","Headers","1","","Write headers","")
 D CHECKED^MIOUIFORM(.TCTX,"flags",1,1)
 D FIELD^MIOUIFORM(.TCTX,"flags",2,"toggle","quoteAll","Quote all","0","","Enable strict mode","required")
 D ACTION^MIOUIFORM(.TCTX,"flags",1,"Delete","submit","danger")
 D FINAL^MIOUIFORM(.TCTX,"flags")
 D EQ^MIOUIT000(.FAIL,"[T010][checked]",+$G(TCTX("form","flags","field",1,"checked")),1)
 D EQ^MIOUIT000(.FAIL,"[T010][toggle]",+$G(TCTX("form","flags","field",2,"isToggle")),1)
 D EQ^MIOUIT000(.FAIL,"[T010][error]",$G(TCTX("form","flags","field",2,"error")),"required")
 D EQ^MIOUIT000(.FAIL,"[T010][danger tone]",$G(TCTX("form","flags","actionBtn",1,"tone")),"danger-button")
 D EQ^MIOUIT000(.FAIL,"[T010][has errors]",+$G(TCTX("form","flags","hasErrors")),1)
 Q
 ;
T020(FAIL)
 N TCTX
 D INIT^MIOUIFORM(.TCTX,"profile","Profile","Lead","/save","post")
 D FIELD^MIOUIFORM(.TCTX,"profile",1,"text","name","Name","Claims Review","Friendly name","Short and specific","")
 D FIELD^MIOUIFORM(.TCTX,"profile",2,"textarea","selectedFields","Selected fields","","One field key per comma-separated token.","Order matters for export output.","At least one field key is required.")
 D FINAL^MIOUIFORM(.TCTX,"profile")
 D EQ^MIOUIT000(.FAIL,"[T020][has help]",+$G(TCTX("form","profile","field",1,"hasHelp")),1)
 D EQ^MIOUIT000(.FAIL,"[T020][error count]",+$G(TCTX("form","profile","errorCount")),1)
 D EQ^MIOUIT000(.FAIL,"[T020][has errors]",+$G(TCTX("form","profile","hasErrors")),1)
 D EQ^MIOUIT000(.FAIL,"[T020][error text]",$G(TCTX("form","profile","field",2,"error")),"At least one field key is required.")
 Q
 ;
