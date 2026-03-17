MIOUITTBL ; MIOUI table tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL)
 S LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUITTBL"
 . Q
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N TCTX
 D INIT^MIOUITBL(.TCTX,"claims","Claims","No rows")
 D COL^MIOUITBL(.TCTX,"claims",1,"Claim","left")
 D CELL^MIOUITBL(.TCTX,"claims",1,1,"CLM-1")
 D ROWBADGE^MIOUITBL(.TCTX,"claims",1,"Previewed","sky")
 D FINAL^MIOUITBL(.TCTX,"claims")
 D EQ(.FAIL,"[T001][title]",$G(TCTX("table","claims","title")),"Claims")
 D EQ(.FAIL,"[T001][rows]",+$G(TCTX("table","claims","rowCount")),1)
 D EQ(.FAIL,"[T001][badge]",$G(TCTX("table","claims","row",1,"badgeClass")),"badge-sky")
 Q
 ;
T010(FAIL)
 N TCTX
 D INIT^MIOUITBL(.TCTX,"audit","Audit","Empty")
 D FILTER^MIOUITBL(.TCTX,"audit",1,"ok","ok",1)
 D BULK^MIOUITBL(.TCTX,"audit","Selected",2)
 D FINAL^MIOUITBL(.TCTX,"audit")
 D EQ(.FAIL,"[T010][filter active]",+$G(TCTX("table","audit","filter",1,"isActive")),1)
 D EQ(.FAIL,"[T010][bulk count]",+$G(TCTX("table","audit","bulk","count")),2)
 D EQ(.FAIL,"[T010][no rows]",+$G(TCTX("table","audit","hasRows")),0)
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
