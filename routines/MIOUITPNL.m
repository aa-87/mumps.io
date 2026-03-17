MIOUITPNL ; MIOUI panel tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL)
 S LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUITPNL"
 . Q
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N TCTX
 D STAT^MIOUIPANEL(.TCTX,1,"Claims",2,"sky","/mioui/billing")
 D EMPTY^MIOUIPANEL(.TCTX,"empty","No rows","Body","Clear","/mioui/tables")
 D EQ(.FAIL,"[T001][stat label]",$G(TCTX("summarycards",1,"label")),"Claims")
 D EQ(.FAIL,"[T001][stat tone]",$G(TCTX("summarycards",1,"tone")),"tone-sky")
 D EQ(.FAIL,"[T001][empty action]",+$G(TCTX("empty","hasAction")),1)
 Q
 ;
T010(FAIL)
 N TCTX
 D DIAGSUM^MIOUIPANEL(.TCTX,1,0)
 D DIAG^MIOUIPANEL(.TCTX,"warning",1,"warn one")
 D ARTMETA^MIOUIPANEL(.TCTX,"canonical","Canonical","desc","violet")
 D ARTIFACT^MIOUIPANEL(.TCTX,"canonical",1,"claims.csv","CSV","/download","csv")
 D EQ(.FAIL,"[T010][warnings]",+$G(TCTX("diagnostic","warnings")),1)
 D EQ(.FAIL,"[T010][warning msg]",$G(TCTX("diagnostic","warning",1,"msg")),"warn one")
 D EQ(.FAIL,"[T010][artifact tone]",$G(TCTX("downloadGroup","canonical","tone")),"tone-violet")
 D EQ(.FAIL,"[T010][downloads any]",+$G(TCTX("downloadsAny")),1)
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
