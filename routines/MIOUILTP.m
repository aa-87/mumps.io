MIOUILTP ; MIOUI layout topology builder
 Q
 ;
REG(CONF)
 N META
 K META S META("authRequired")=0,META("roles")=""
 D ADDM^MIOROUTE("GET","/mioui/layout-topologies","TOPOLOGY^MIOUILTP",.META)
 S ^MIO("ROUTE","RAW","GET","/mioui/layout-topologies")="TOPOLOGY^MIOUILTP"
 S ^MIO("ROUTE","META","GET","/mioui/layout-topologies","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/layout-topologies","roles")=""
 Q
 ;
TOPOLOGY(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_layout_topologies.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
BUILD(CONF,REQ,CTX,TCTX)
 D BASE^MIOUICTX(.TCTX)
 D APPLY^MIOUITHEME(.CONF,.TCTX)
 D ACT^MIOUICTX(.TCTX,"tables")
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Layout topologies","Layout topologies","Diverse dense layouts for queues, dossiers, timelines, escalation, and comparison-heavy review flows.","Layout topologies")
 S TCTX("pageTitle")="Layout topology lab"
 S TCTX("pageIntro")="Diverse dense layouts for queues, dossiers, timelines, escalation, and comparison-heavy review flows."
 S TCTX("heroCallback")="openTopologyStudio"
 Q
