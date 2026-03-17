MIOUILDV ; MIOUI layout diversity builders
 Q
 ;
REG(CONF)
 N META
 K META S META("authRequired")=0,META("roles")=""
 D ADDM^MIOROUTE("GET","/mioui/layout-diversity","DIVERSITY^MIOUILDV",.META)
 S ^MIO("ROUTE","RAW","GET","/mioui/layout-diversity")="DIVERSITY^MIOUILDV"
 S ^MIO("ROUTE","META","GET","/mioui/layout-diversity","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/layout-diversity","roles")=""
 Q
 ;
DIVERSITY(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_layout_diversity.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
BUILD(CONF,REQ,CTX,TCTX)
 D BASE^MIOUICTX(.TCTX)
 D APPLY^MIOUITHEME(.CONF,.TCTX)
 D ACT^MIOUICTX(.TCTX,"tables")
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Layout diversity","Layout diversity","Diverse dense shells for operators, reviewers, supervisors, and evidence-driven workflows.","Layout diversity")
 S TCTX("page","title")="Layout diversity lab"
 S TCTX("layoutDiversity","title")="Layout diversity for dense applications"
 S TCTX("layoutDiversity","summary")="Diverse high-density shells for queues, ledgers, review, and supervision."
 S TCTX("layoutDiversity","callback","openCockpitPreset")="openCockpitPreset"
 S TCTX("layoutDiversity","callback","openBoardPreset")="openBoardPreset"
 S TCTX("layoutDiversity","callback","openLedgerPreset")="openLedgerPreset"
 S TCTX("layoutDiversity","callback","openReviewTheater")="openReviewTheater"
 S TCTX("layoutDiversity","callback","openFusionMode")="openFusionMode"
 S TCTX("layoutDiversity","callback","openEscalationRing")="openEscalationRing"
 S TCTX("layoutDiversity","pattern",1,"title")="Master-detail cockpit"
 S TCTX("layoutDiversity","pattern",1,"desc")="Queue, detail canvas, and context rail."
 S TCTX("layoutDiversity","pattern",2,"title")="Queue board matrix"
 S TCTX("layoutDiversity","pattern",2,"desc")="Dense board lanes for active work distribution."
 S TCTX("layoutDiversity","pattern",3,"title")="Ledger tape layout"
 S TCTX("layoutDiversity","pattern",3,"desc")="Summary tape plus tabular ledger body."
 S TCTX("layoutDiversity","pattern",4,"title")="Document review theater"
 S TCTX("layoutDiversity","pattern",4,"desc")="Large evidence-first review screen."
 S TCTX("layoutDiversity","pattern",5,"title")="Map-table context fusion"
 S TCTX("layoutDiversity","pattern",5,"desc")="Spatial or contextual surface beside a dense table."
 S TCTX("layoutDiversity","pattern",6,"title")="Escalation ring layout"
 S TCTX("layoutDiversity","pattern",6,"desc")="Urgent center stack with support rails."
 Q
