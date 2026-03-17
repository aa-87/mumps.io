MIOUIT017 ; ROI7 premium workflow enhancement tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 D T020(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIT017"
 I LOCAL S FAIL=1
 Q
 ;
BASECONF(CONF)
 D CONFDEF^MIOUI(.CONF)
 Q
 ;
T001(FAIL)
 N TCTX
 D BARINIT^MIOUIPRM(.TCTX,"main","Quick actions and shortcuts","High-frequency command surface")
 D BARGROUP^MIOUIPRM(.TCTX,"main",1,"Quick actions","Common operator actions")
 D BARACT^MIOUIPRM(.TCTX,"main",1,1,"Create review batch","/mioui/premium","primary-button")
 D BARACT^MIOUIPRM(.TCTX,"main",1,2,"Save current view","/mioui/premium?save=1","quick-button")
 D BARFINAL^MIOUIPRM(.TCTX,"main")
 D FDINIT^MIOUIPRM(.TCTX,"main","Advanced filters","Deep queue narrowing")
 D FDSECTION^MIOUIPRM(.TCTX,"main",1,"Review state","Queue state filters")
 D FDFIELD^MIOUIPRM(.TCTX,"main",1,1,"Status","Previewed","Two statuses active")
 D FDFINAL^MIOUIPRM(.TCTX,"main")
 D TOAST^MIOUIPRM(.TCTX,"main","success","Saved view updated","The queue was saved.",1)
 D DIFFINIT^MIOUIPRM(.TCTX,"main","Inline diff review","Before and after comparison")
 D DIFFROW^MIOUIPRM(.TCTX,"main",1,"Subscriber last name","DOE","DOE-SMITH",1)
 D DIFFFINAL^MIOUIPRM(.TCTX,"main")
 D EQ^MIOUIT000(.FAIL,"[T001][group count]",+$G(TCTX("commandBar","main","groupCount")),1)
 D EQ^MIOUIT000(.FAIL,"[T001][action count]",+$G(TCTX("commandBar","main","actionCount")),2)
 D EQ^MIOUIT000(.FAIL,"[T001][drawer sections]",+$G(TCTX("filterDrawer","main","sectionCount")),1)
 D EQ^MIOUIT000(.FAIL,"[T001][drawer fields]",+$G(TCTX("filterDrawer","main","fieldCount")),1)
 D EQ^MIOUIT000(.FAIL,"[T001][toast dismissible]",+$G(TCTX("toast","main","dismissible")),1)
 D EQ^MIOUIT000(.FAIL,"[T001][diff rows]",+$G(TCTX("inlineDiff","main","rowCount")),1)
 D EQ^MIOUIT000(.FAIL,"[T001][diff changed]",+$G(TCTX("inlineDiff","main","changedCount")),1)
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDPREMIUM^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_premium.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T010][command bar]",OUT,"Quick actions and shortcuts")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][filter drawer]",OUT,"Advanced filters")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][toast]",OUT,"Saved view updated")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][inline diff]",OUT,"Subscriber last name")
 Q
 ;
T020(FAIL)
 N REG,I
 D LIST^MIOUIREG(.REG)
 S I=$$FIND^MIOUIREG(.REG,"premium_workflow_builder")
 D EQ^MIOUIT000(.FAIL,"[T020][builder status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T020][builder test]",$G(REG(I,"test")),"MIOUIT017")
 S I=$$FIND^MIOUIREG(.REG,"command_bar")
 D EQ^MIOUIT000(.FAIL,"[T020][command bar status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"advanced_filter_drawer")
 D EQ^MIOUIT000(.FAIL,"[T020][drawer status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"toast_inline")
 D EQ^MIOUIT000(.FAIL,"[T020][toast status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"inline_diff_card")
 D EQ^MIOUIT000(.FAIL,"[T020][diff status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"page_premium")
 D EQ^MIOUIT000(.FAIL,"[T020][page status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T020][page kind]",$G(REG(I,"kind")),"page")
 Q
 ;
