MIOUICLY ; collaborative layout choreography builders
 Q
 ;
REG(CONF)
 N META
 K META S META("authRequired")=0,META("roles")=""
 D ADDM^MIOROUTE("GET","/mioui/layout-choreography","CHOREO^MIOUICLY",.META)
 S ^MIO("ROUTE","RAW","GET","/mioui/layout-choreography")="CHOREO^MIOUICLY"
 S ^MIO("ROUTE","META","GET","/mioui/layout-choreography","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/layout-choreography","roles")=""
 Q
 ;
CHOREO(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_layout_choreography.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
BUILD(CONF,REQ,CTX,TCTX)
 D BASE^MIOUICTX(.TCTX)
 D APPLY^MIOUITHEME(.CONF,.TCTX)
 D ACT^MIOUICTX(.TCTX,"tables")
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Layout choreography","Layout choreography","Collaborative dock maps, transition sequences, presence rails, and attention routing for dense operator shells.","Layout choreography")
 S TCTX("workspaceTitle")="Layout choreography"
 S TCTX("workspaceLead")="Use these surfaces when dense shells need explicit policy, shared presence, and guided transitions instead of ad hoc pane changes."
 ; policy
 S TCTX("policyTitle")="Layout policy banner"
 S TCTX("policyLead")="Expose the active workspace contract before changing panes or restoring snapshots."
 S TCTX("policyName")="QA lead escalation policy"
 S TCTX("policyOwner")="layoutPolicyQaLead"
 S TCTX("policyDetail")="QA leads may widen trace, pin notes, and lock handoff rails during escalation review."
 S TCTX("policyCallback")="applyPolicyQaLead"
 ; dock matrix
 S TCTX("dockTitle")="Workspace dock matrix"
 S TCTX("dockLead")="Make dock ownership explicit across the grid, inspector, trace, notes, and action rails."
 D DOCK(.TCTX,1,"Grid + queue","center","Claim grid and bulk triage","jumpDockGrid")
 D DOCK(.TCTX,2,"Evidence rail","right","Trace and source evidence","jumpDockEvidenceRail")
 D DOCK(.TCTX,3,"Annotation rail","right-bottom","Shared notes and review comments","jumpDockNotesRail")
 D DOCK(.TCTX,4,"Action rail","bottom","Callbacks, exports, and approvals","jumpDockActionRail")
 ; presence
 S TCTX("presenceTitle")="Collaboration presence rail"
 S TCTX("presenceLead")="Keep shared shell presence visible so operators know who owns the current state and handoff."
 D PRES(.TCTX,1,"Supervisor","Watching escalations","openPresenceSupervisor")
 D PRES(.TCTX,2,"QA reviewer","Pinned to trace rail","openPresenceQa")
 D PRES(.TCTX,3,"Collector","Owning queue state","openPresenceCollector")
 ; compare
 S TCTX("compareTitle")="Route snapshot compare"
 S TCTX("compareLead")="Compare two route-bound snapshots before restoring a shared layout."
 D CMP(.TCTX,1,"Collector queue","Tri-split with audit rail","compareSnapshotCollectorVsQa")
 D CMP(.TCTX,2,"QA audit","Focus inspector with pinned evidence","compareSnapshotQaVsLead")
 D CMP(.TCTX,3,"Lead escalation","Board rail with approval drawer","compareSnapshotLeadVsOps")
 ; sequence
 S TCTX("sequenceTitle")="Transition sequence panel"
 S TCTX("sequenceLead")="Treat dense shell changes as sequences with callbacks, not one-off jumps."
 D STEP(.TCTX,1,"Queue -> review","Open claim grid, widen trace, pin notes","runTransitionSequenceReview")
 D STEP(.TCTX,2,"Review -> handoff","Collapse bulk rail, expand handoff notes","runTransitionSequenceHandoff")
 D STEP(.TCTX,3,"Handoff -> analytics","Switch to metrics canvas and retain blockers","runTransitionSequenceAnalytics")
 ; attention
 S TCTX("attentionTitle")="Attention hotspot map"
 S TCTX("attentionLead")="Move attention deliberately between queue pressure, blockers, evidence, and supervisor requests."
 D HOT(.TCTX,1,"Claims hotspot","New blockers in payer queue","centerAttentionHotspotClaims")
 D HOT(.TCTX,2,"Trace hotspot","Evidence conflict on active claim","centerAttentionHotspotTrace")
 D HOT(.TCTX,3,"Supervisor hotspot","Override requested in approval rail","centerAttentionHotspotSupervisor")
 Q
 ;
DOCK(TCTX,IDX,LABEL,POS,DETAIL,CALLBACK)
 S TCTX("dock",+IDX,"label")=$G(LABEL)
 S TCTX("dock",+IDX,"position")=$G(POS)
 S TCTX("dock",+IDX,"detail")=$G(DETAIL)
 S TCTX("dock",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
PRES(TCTX,IDX,LABEL,DETAIL,CALLBACK)
 S TCTX("presence",+IDX,"label")=$G(LABEL)
 S TCTX("presence",+IDX,"detail")=$G(DETAIL)
 S TCTX("presence",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
CMP(TCTX,IDX,LABEL,DETAIL,CALLBACK)
 S TCTX("compare",+IDX,"label")=$G(LABEL)
 S TCTX("compare",+IDX,"detail")=$G(DETAIL)
 S TCTX("compare",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
STEP(TCTX,IDX,LABEL,DETAIL,CALLBACK)
 S TCTX("sequence",+IDX,"label")=$G(LABEL)
 S TCTX("sequence",+IDX,"detail")=$G(DETAIL)
 S TCTX("sequence",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
HOT(TCTX,IDX,LABEL,DETAIL,CALLBACK)
 S TCTX("hotspot",+IDX,"label")=$G(LABEL)
 S TCTX("hotspot",+IDX,"detail")=$G(DETAIL)
 S TCTX("hotspot",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
