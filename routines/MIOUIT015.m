MIOUIT015 ; ROI5 dense operator ergonomics tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 D T020(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIT015"
 I LOCAL S FAIL=1
 Q
 ;
BASECONF(CONF)
 D CONFDEF^MIOUI(.CONF)
 Q
 ;
T001(FAIL)
 N TCTX
 D PHEADER^MIOUIOPS(.TCTX,"main","Dense operator workflows","Operator workspace","High-volume list and detail review.")
 D PHEADMETA^MIOUIOPS(.TCTX,"main",1,"Queue","18 queued","sky")
 D PHEADACT^MIOUIOPS(.TCTX,"main",1,"Open billing preview","/mioui/billing","primary-button")
 D SUBINIT^MIOUIOPS(.TCTX,"main","Queue health")
 D SUBITEM^MIOUIOPS(.TCTX,"main",1,"Queues","/mioui/operators#queues",1)
 D SUBITEM^MIOUIOPS(.TCTX,"main",2,"Selected detail","/mioui/operators#detail",0)
 D SUBFINAL^MIOUIOPS(.TCTX,"main")
 D VIEWSINIT^MIOUIOPS(.TCTX,"main","Saved views","Reusable operator presets.")
 D VIEW^MIOUIOPS(.TCTX,"main",1,"My preview queue","/mioui/operators?view=preview",1,12)
 D VIEW^MIOUIOPS(.TCTX,"main",2,"Needs review","/mioui/operators?view=review",0,5)
 D VIEWSFINAL^MIOUIOPS(.TCTX,"main")
 D CHINIT^MIOUIOPS(.TCTX,"main","Visible columns","Only keep what the operator needs.")
 D CHITEM^MIOUIOPS(.TCTX,"main",1,"Claim","Primary identifier",1)
 D CHITEM^MIOUIOPS(.TCTX,"main",2,"Date of service","Scan anchor",1)
 D CHITEM^MIOUIOPS(.TCTX,"main",3,"Subscriber","Optional context",0)
 D CHFINAL^MIOUIOPS(.TCTX,"main")
 D SPLITINIT^MIOUIOPS(.TCTX,"main","Split detail panel","Keep the selected record in view.","Selected claim")
 D SPLITSUM^MIOUIOPS(.TCTX,"main",1,"Claim","CLM-1001")
 D SPLITFIELD^MIOUIOPS(.TCTX,"main",1,"Procedure","99213")
 D SPLITFINAL^MIOUIOPS(.TCTX,"main")
 D FEEDINIT^MIOUIOPS(.TCTX,"main","Operator activity","Compact event stream.")
 D FEEDITEM^MIOUIOPS(.TCTX,"main",1,"08:24","View saved","Morning preset selected.","sky")
 D FEEDITEM^MIOUIOPS(.TCTX,"main",2,"08:29","Claim opened","Split detail updated.","emerald")
 D FEEDFINAL^MIOUIOPS(.TCTX,"main")
 D EQ^MIOUIT000(.FAIL,"[T001][subnav count]",+$G(TCTX("subnav","main","count")),2)
 D EQ^MIOUIT000(.FAIL,"[T001][current view]",$G(TCTX("savedViews","main","currentLabel")),"My preview queue")
 D EQ^MIOUIT000(.FAIL,"[T001][chooser selected]",+$G(TCTX("columnChooser","main","selectedCount")),2)
 D EQ^MIOUIT000(.FAIL,"[T001][feed count]",+$G(TCTX("activityFeed","main","count")),2)
 D EQ^MIOUIT000(.FAIL,"[T001][split title]",$G(TCTX("splitPanel","main","selectedTitle")),"Selected claim")
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDOPS^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_operators.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T010][page header]",OUT,"Operator workspace")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][saved views]",OUT,"My preview queue")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][subnav]",OUT,"Queue health")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][chooser]",OUT,"Visible columns")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][split]",OUT,"Selected claim")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][feed]",OUT,"Operator activity")
 Q
 ;
T020(FAIL)
 N REG,I
 D LIST^MIOUIREG(.REG)
 S I=$$FIND^MIOUIREG(.REG,"saved_views_toolbar")
 D EQ^MIOUIT000(.FAIL,"[T020][saved views status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T020][saved views test]",$G(REG(I,"test")),"MIOUIT015")
 S I=$$FIND^MIOUIREG(.REG,"column_chooser")
 D EQ^MIOUIT000(.FAIL,"[T020][chooser status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"split_detail_panel")
 D EQ^MIOUIT000(.FAIL,"[T020][split status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"activity_feed")
 D EQ^MIOUIT000(.FAIL,"[T020][feed status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"page_header")
 D EQ^MIOUIT000(.FAIL,"[T020][page header status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"shell_subnav")
 D EQ^MIOUIT000(.FAIL,"[T020][subnav status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"page_operators")
 D EQ^MIOUIT000(.FAIL,"[T020][operators page kind]",$G(REG(I,"kind")),"page")
 D EQ^MIOUIT000(.FAIL,"[T020][operators page status]",$G(REG(I,"status")),"implemented")
 Q
 ;
