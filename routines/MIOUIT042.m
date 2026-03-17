MIOUIT042 ; specialist profile variant tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 D T020(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIT042"
 I LOCAL S FAIL=1
 Q
 ;
BASECONF(CONF)
 D CONFDEF^MIOUI(.CONF)
 D INIT^MIOUI(.CONF)
 Q
 ;
T001(FAIL)
 N CONF,REQ,CTX,TCTX
 D BASECONF(.CONF)
 D BUILD^MIOUIPRF(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T001][specialist variant count]",$$COUNT^MIOUICTX($NA(TCTX("specialistVariant"))),3)
 D EQ^MIOUIT000(.FAIL,"[T001][collector metric count]",$$COUNT^MIOUICTX($NA(TCTX("collector","metric"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][collector pipeline count]",$$COUNT^MIOUICTX($NA(TCTX("collector","pipeline"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][collector compliance count]",$$COUNT^MIOUICTX($NA(TCTX("collector","compliance"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][qa metric count]",$$COUNT^MIOUICTX($NA(TCTX("qa","metric"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][qa queue count]",$$COUNT^MIOUICTX($NA(TCTX("qa","queue"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][qa variance count]",$$COUNT^MIOUICTX($NA(TCTX("qa","variance"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][denial metric count]",$$COUNT^MIOUICTX($NA(TCTX("denial","metric"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][denial inventory count]",$$COUNT^MIOUICTX($NA(TCTX("denial","inventory"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][denial appeal count]",$$COUNT^MIOUICTX($NA(TCTX("denial","appeal"))),4)
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILD^MIOUIPRF(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_profile_variants.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T010][specialist section]",OUT,"Collector, QA reviewer, and denial-specialist variants")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][collector title]",OUT,"Collector profile")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][qa title]",OUT,"QA reviewer profile")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][denial title]",OUT,"Denial specialist profile")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][collector callback]",OUT,"openCollectorProfile")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][collection plan callback]",OUT,"launchCollectionPlan")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][promise callback]",OUT,"reviewCollectorPromiseToPay")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][qa callback]",OUT,"openQaReviewerProfile")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][qa queue callback]",OUT,"openQaAuditQueue")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][drift callback]",OUT,"compareDocumentationDrift")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][denial callback]",OUT,"openDenialSpecialistProfile")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][packet callback]",OUT,"reviewDenialPackets")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][appeal callback]",OUT,"launchAppealStrategy")
 Q
 ;
T020(FAIL)
 N REG,I,ID
 D LIST^MIOUIREG(.REG)
 F ID="profile_collector_workbench","profile_qa_reviewer_board","profile_denial_specialist_desk" D
 . S I=$$FIND^MIOUIREG(.REG,ID)
 . D EQ^MIOUIT000(.FAIL,"[T020]["_ID_" status]",$G(REG(I,"status")),"implemented")
 . D EQ^MIOUIT000(.FAIL,"[T020]["_ID_" phase]",$G(REG(I,"phase")),"P1")
 . D EQ^MIOUIT000(.FAIL,"[T020]["_ID_" test]",$G(REG(I,"test")),"MIOUIT042")
 Q
 ;
