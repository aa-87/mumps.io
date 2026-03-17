MIOUICOLT003 ; Collaboration chat builder tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T100(.LOCAL)
 D T110(.LOCAL)
 D T120(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUICOLT003"
 I LOCAL S FAIL=1
 Q
 ;
T100(FAIL)
 N CONF,REQ,CTX,TCTX
 D CONFDEF^MIOUI(.CONF)
 D BUILDCH^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX,"standard")
 D EQ^MIOUIT000(.FAIL,"[T100][variant]",$G(TCTX("chatVariant")),"standard")
 D EQ^MIOUIT000(.FAIL,"[T100][title]",$G(TCTX("page","heading")),"Chat primitives")
 D EQ^MIOUIT000(.FAIL,"[T100][active tab]",+$G(TCTX("collabTab",4,"isActive")),1)
 D EQ^MIOUIT000(.FAIL,"[T100][participants]",$$COUNT^MIOUICTX($NA(TCTX("participant"))),4)
 D EQ^MIOUIT000(.FAIL,"[T100][items]",$$COUNT^MIOUICTX($NA(TCTX("chatItem"))),8)
 D EQ^MIOUIT000(.FAIL,"[T100][actions]",$$COUNT^MIOUICTX($NA(TCTX("composerAction"))),4)
 D EQ^MIOUIT000(.FAIL,"[T100][side panels]",$$COUNT^MIOUICTX($NA(TCTX("chatSide"))),3)
 Q
 ;
T110(FAIL)
 N CONF,REQ,CTX,TCTX
 D CONFDEF^MIOUI(.CONF)
 D BUILDCH^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX,"dense")
 D EQ^MIOUIT000(.FAIL,"[T110][variant]",$G(TCTX("chatVariant")),"dense")
 D EQ^MIOUIT000(.FAIL,"[T110][title]",$G(TCTX("page","heading")),"Dense chat review")
 D EQ^MIOUIT000(.FAIL,"[T110][active tab]",+$G(TCTX("collabTab",5,"isActive")),1)
 D EQ^MIOUIT000(.FAIL,"[T110][hero label]",$G(TCTX("heroStat",1,"label")),"Visible messages")
 D EQ^MIOUIT000(.FAIL,"[T110][thread title]",$G(TCTX("chatHeader","title")),"Blue Horizon Imaging denial coordination")
 Q
 ;
T120(FAIL)
 N CONF,REQ,CTX,TCTX
 D CONFDEF^MIOUI(.CONF)
 D BUILDCH^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX,"balanced")
 D EQ^MIOUIT000(.FAIL,"[T120][variant]",$G(TCTX("chatVariant")),"balanced")
 D EQ^MIOUIT000(.FAIL,"[T120][title]",$G(TCTX("page","heading")),"Balanced chat workspace")
 D EQ^MIOUIT000(.FAIL,"[T120][active tab]",+$G(TCTX("collabTab",6,"isActive")),1)
 D EQ^MIOUIT000(.FAIL,"[T120][hero label]",$G(TCTX("heroStat",2,"label")),"Quick actions")
 D EQ^MIOUIT000(.FAIL,"[T120][composer helper]",$G(TCTX("composer","helper")),"Message composer")
 Q
 ;
