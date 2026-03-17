MIOUICOLT005 ; Collaboration onboarding builder tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T100(.LOCAL)
 D T110(.LOCAL)
 D T120(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUICOLT005"
 I LOCAL S FAIL=1
 Q
 ;
T100(FAIL)
 N CONF,REQ,CTX,TCTX
 D CONFDEF^MIOUI(.CONF)
 D BUILDON^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX,"standard")
 D EQ^MIOUIT000(.FAIL,"[T100][variant]",$G(TCTX("onboardVariant")),"standard")
 D EQ^MIOUIT000(.FAIL,"[T100][title]",$G(TCTX("page","heading")),"Onboarding workspace")
 D EQ^MIOUIT000(.FAIL,"[T100][active tab]",+$G(TCTX("collabTab",7,"isActive")),1)
 D EQ^MIOUIT000(.FAIL,"[T100][steps]",$$COUNT^MIOUICTX($NA(TCTX("onboarding","launch","step"))),4)
 D EQ^MIOUIT000(.FAIL,"[T100][stage cards]",$$COUNT^MIOUICTX($NA(TCTX("stageCard"))),4)
 D EQ^MIOUIT000(.FAIL,"[T100][invite members]",$$COUNT^MIOUICTX($NA(TCTX("inviteMember"))),4)
 D EQ^MIOUIT000(.FAIL,"[T100][rooms]",$$COUNT^MIOUICTX($NA(TCTX("defaultRoom"))),3)
 Q
 ;
T110(FAIL)
 N CONF,REQ,CTX,TCTX
 D CONFDEF^MIOUI(.CONF)
 D BUILDON^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX,"dense")
 D EQ^MIOUIT000(.FAIL,"[T110][variant]",$G(TCTX("onboardVariant")),"dense")
 D EQ^MIOUIT000(.FAIL,"[T110][title]",$G(TCTX("page","heading")),"Dense onboarding review")
 D EQ^MIOUIT000(.FAIL,"[T110][active tab]",+$G(TCTX("collabTab",8,"isActive")),1)
 D EQ^MIOUIT000(.FAIL,"[T110][hero 1]",$G(TCTX("heroStat",1,"label")),"Launch blocks")
 D EQ^MIOUIT000(.FAIL,"[T110][launch title]",$G(TCTX("launchPanel","title")),"Launch and defaults")
 D EQ^MIOUIT000(.FAIL,"[T110][check items]",$$COUNT^MIOUICTX($NA(TCTX("checkItem"))),4)
 Q
 ;
T120(FAIL)
 N CONF,REQ,CTX,TCTX
 D CONFDEF^MIOUI(.CONF)
 D BUILDON^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX,"guided")
 D EQ^MIOUIT000(.FAIL,"[T120][variant]",$G(TCTX("onboardVariant")),"guided")
 D EQ^MIOUIT000(.FAIL,"[T120][title]",$G(TCTX("page","heading")),"Guided onboarding launch")
 D EQ^MIOUIT000(.FAIL,"[T120][active tab]",+$G(TCTX("collabTab",9,"isActive")),1)
 D EQ^MIOUIT000(.FAIL,"[T120][hero 2]",$G(TCTX("heroStat",2,"label")),"Preview rails")
 D EQ^MIOUIT000(.FAIL,"[T120][summary]",$G(TCTX("onboarding","launch","summary")),"1 of 4 complete")
 Q
 ;
