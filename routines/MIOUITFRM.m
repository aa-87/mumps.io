MIOUITFRM ; MIOUI form tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL)
 S LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUITFRM"
 . Q
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
 D EQ(.FAIL,"[T001][title]",$G(TCTX("form","profile","title")),"Profile")
 D EQ(.FAIL,"[T001][field count]",+$G(TCTX("form","profile","fieldCount")),2)
 D EQ(.FAIL,"[T001][selected]",+$G(TCTX("form","profile","field",2,"option",1,"isSelected")),1)
 Q
 ;
T010(FAIL)
 N TCTX
 D INIT^MIOUIFORM(.TCTX,"flags","Flags","Lead","/save","post")
 D FIELD^MIOUIFORM(.TCTX,"flags",1,"checkbox","headers","Headers","1","","help","")
 D CHECKED^MIOUIFORM(.TCTX,"flags",1,1)
 D FIELD^MIOUIFORM(.TCTX,"flags",2,"toggle","quoteAll","Quote all","0","","help","required")
 D FINAL^MIOUIFORM(.TCTX,"flags")
 D EQ(.FAIL,"[T010][checked]",+$G(TCTX("form","flags","field",1,"checked")),1)
 D EQ(.FAIL,"[T010][toggle]",+$G(TCTX("form","flags","field",2,"isToggle")),1)
 D EQ(.FAIL,"[T010][error]",$G(TCTX("form","flags","field",2,"error")),"required")
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
