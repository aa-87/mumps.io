MIOUIT014 ; ROI4 workflow polish surface tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 D T020(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIT014"
 I LOCAL S FAIL=1
 Q
 ;
BASECONF(CONF)
 D CONFDEF^MIOUI(.CONF)
 Q
 ;
T001(FAIL)
 N TCTX
 D ONBINIT^MIOUIWF(.TCTX,"firstRun","First-run onboarding","Guide setup","Continue","/next","Skip","/mioui")
 D ONBSTEP^MIOUIWF(.TCTX,"firstRun",1,"Connect","Pick folders","complete")
 D ONBSTEP^MIOUIWF(.TCTX,"firstRun",2,"Preview","Review defaults","current")
 D ONBSTEP^MIOUIWF(.TCTX,"firstRun",3,"Publish","Run sample","queued")
 D ONBFINAL^MIOUIWF(.TCTX,"firstRun")
 D CONFIRM^MIOUIWF(.TCTX,"publish","Publish staged files","Write outputs","amber","Publish","/publish","Cancel","/mioui")
 D DROPINIT^MIOUIWF(.TCTX,"staging","File staging","Drop files here","837, CSV","Local only")
 D DROPFILE^MIOUIWF(.TCTX,"staging",1,"alpha.837","148 KB","Ready","emerald")
 D DROPFILE^MIOUIWF(.TCTX,"staging",2,"notes.txt","4 KB","Needs review","amber")
 D DROPFINAL^MIOUIWF(.TCTX,"staging")
 D STEP^MIOUICTX(.TCTX,1,"Stage","Collect files","complete")
 D STEP^MIOUICTX(.TCTX,2,"Preview","Inspect claim rows","current")
 D STEP^MIOUICTX(.TCTX,3,"Confirm","Make actions explicit","queued")
 D STEP^MIOUICTX(.TCTX,4,"Publish","Write artifacts","queued")
 D STEPNOTE^MIOUIWF(.TCTX,2,"Preview should stay in context.","Open preview","/mioui/billing")
 D STEPFINAL^MIOUIWF(.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T001][onboarding total]",+$G(TCTX("onboarding","firstRun","totalCount")),3)
 D EQ^MIOUIT000(.FAIL,"[T001][onboarding complete]",+$G(TCTX("onboarding","firstRun","completeCount")),1)
 D EQ^MIOUIT000(.FAIL,"[T001][confirm title]",$G(TCTX("confirm","publish","title")),"Publish staged files")
 D EQ^MIOUIT000(.FAIL,"[T001][dropzone ready]",+$G(TCTX("dropzone","staging","readyCount")),1)
 D EQ^MIOUIT000(.FAIL,"[T001][step total]",+$G(TCTX("stepperMeta","total")),4)
 D EQ^MIOUIT000(.FAIL,"[T001][ordinal]",$G(TCTX("stepper",2,"ordinalLabel")),"Step 2 of 4")
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDWORK^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_workflows.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T010][onboarding]",OUT,"First-run onboarding")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][confirm]",OUT,"Publish staged files")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][dropzone]",OUT,"Drop files here")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][staged file]",OUT,"alpha-claim-batch.837")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][step ordinal]",OUT,"Step 2 of 4")
 Q
 ;
T020(FAIL)
 N REG,I
 D LIST^MIOUIREG(.REG)
 S I=$$FIND^MIOUIREG(.REG,"workflow_builder")
 D EQ^MIOUIT000(.FAIL,"[T020][workflow builder status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T020][workflow builder test]",$G(REG(I,"test")),"MIOUIT014")
 S I=$$FIND^MIOUIREG(.REG,"onboarding_modal")
 D EQ^MIOUIT000(.FAIL,"[T020][onboarding status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"confirm_dialog")
 D EQ^MIOUIT000(.FAIL,"[T020][confirm status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"file_dropzone")
 D EQ^MIOUIT000(.FAIL,"[T020][dropzone status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"page_workflows")
 D EQ^MIOUIT000(.FAIL,"[T020][page workflows kind]",$G(REG(I,"kind")),"page")
 D EQ^MIOUIT000(.FAIL,"[T020][page workflows status]",$G(REG(I,"status")),"implemented")
 Q
 ;
