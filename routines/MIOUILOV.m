MIOUILOV ; layout transition and overlay workspace builders
 Q
 ;
REG(CONF)
 N META
 K META S META("authRequired")=0,META("roles")=""
 D ADDM^MIOROUTE("GET","/mioui/layout-overlays","OVERLAY^MIOUILOV",.META)
 S ^MIO("ROUTE","RAW","GET","/mioui/layout-overlays")="OVERLAY^MIOUILOV"
 S ^MIO("ROUTE","META","GET","/mioui/layout-overlays","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/layout-overlays","roles")=""
 Q
 ;
OVERLAY(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_layout_overlays.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
BUILD(CONF,REQ,CTX,TCTX)
 D BASE^MIOUICTX(.TCTX)
 D APPLY^MIOUITHEME(.CONF,.TCTX)
 D ACT^MIOUICTX(.TCTX,"tables")
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Layout transitions and overlays","Layout transitions and overlays","Overlay-first layout systems for dense operator products with workspace snapshots, cross-route maps, emergency focus modes, and shift handoff shells.","Layout transitions and overlays")
 S TCTX("workspaceTitle")="Layout transitions and overlays"
 S TCTX("workspaceLead")="These layout systems help operators move between shells without losing context. Use them when dense queue work needs temporary focus modes, handoff views, and fast snapshot restore."
 ; transition bar
 S TCTX("transitionTitle")="Layout transitions"
 S TCTX("transitionLead")="Promote shell changes to a visible system so teams can move between audit, review, handoff, and focus modes without spatial confusion."
 D TRANS(.TCTX,1,"Audit to review","Tri-split -> focus inspector","activateTransitionAudit",1)
 D TRANS(.TCTX,2,"Review to board","Focus inspector -> board rail","activateTransitionBoard",0)
 D TRANS(.TCTX,3,"Board to command","Board rail -> command center","activateTransitionCommand",0)
 D TRANS(.TCTX,4,"Analytics to audit","Analytics canvas -> tri-split","activateTransitionAnalytics",0)
 ; snapshot gallery
 S TCTX("snapshotTitle")="Workspace snapshots"
 S TCTX("snapshotLead")="Capture complete workspace shells so operators can restore known-good states before diving back into dense queues."
 D SNAP(.TCTX,1,"Collector morning queue","Revenue follow-up · tri-split","restoreSnapshotCollector",1)
 D SNAP(.TCTX,2,"QA deep audit","Focus inspector + trace rail","restoreSnapshotQa",0)
 D SNAP(.TCTX,3,"Supervisor handoff","Board + action rail","restoreSnapshotSupervisor",0)
 D SNAP(.TCTX,4,"Analyst compare set","Analytics canvas + formulas","restoreSnapshotAnalyst",0)
 ; route map
 S TCTX("mapTitle")="Cross-route workspace map"
 S TCTX("mapLead")="Make route jumps spatially explicit so claims, denials, trace, and analytics each reopen with the right shell instead of forcing a cold start."
 D MAP(.TCTX,1,"Claims queue","/claims/queue","Tri-split queue","jumpRouteClaimsQueue")
 D MAP(.TCTX,2,"Claim review","/claims/review/CLM-1001","Focus inspector","jumpRouteClaimReview")
 D MAP(.TCTX,3,"Denial board","/denials/board","Board rail","jumpRouteDenialBoard")
 D MAP(.TCTX,4,"Trace review","/trace/claim/CLM-1001","Evidence layout","jumpRouteTraceReview")
 ; emergency focus
 S TCTX("emergencyTitle")="Emergency focus layout"
 S TCTX("emergencyLead")="Use a narrow, interruption-resistant shell when operators need to resolve one item without queue noise, board metrics, or secondary rails."
 D FOCUS(.TCTX,1,"Single item shell","Only the active claim and trace stay open.","enterEmergencyFocusMode")
 D FOCUS(.TCTX,2,"Muted rails","Bulk tools and boards collapse automatically.","muteSecondaryRails")
 D FOCUS(.TCTX,3,"Pinned evidence","Trace and annotations stay visible during edits.","pinEvidenceRail")
 ; shift handoff
 S TCTX("handoffTitle")="Shift handoff layout"
 S TCTX("handoffLead")="Create handoff-specific shells that summarize queues, active blockers, notes, and next actions for the incoming operator."
 D HAND(.TCTX,1,"Collector to QA","Claims needing audit follow-up","openShiftHandoffLayout")
 D HAND(.TCTX,2,"QA to supervisor","Escalations and override requests","openSupervisorHandoff")
 D HAND(.TCTX,3,"Analyst to lead","Variance review and pending formulas","openAnalystHandoff")
 ; density matrix
 S TCTX("matrixTitle")="Overlay density matrix"
 S TCTX("matrixLead")="Treat overlays as density tools. Choose whether drawers, sheets, and floating inspectors preserve or interrupt queue visibility."
 D MATRIX(.TCTX,1,"Drawer overlay","Queue remains visible","applyOverlayDensityMatrix")
 D MATRIX(.TCTX,2,"Sheet overlay","Inspector dominates the shell","applySheetDensityMatrix")
 D MATRIX(.TCTX,3,"Modal workbench","Background dims but state remains","applyModalDensityMatrix")
 Q
 ;
TRANS(TCTX,IDX,LABEL,DETAIL,CALLBACK,ACTIVE)
 S TCTX("transition",+IDX,"label")=$G(LABEL)
 S TCTX("transition",+IDX,"detail")=$G(DETAIL)
 S TCTX("transition",+IDX,"callback")=$G(CALLBACK)
 S TCTX("transition",+IDX,"isActive")=+$G(ACTIVE)
 S TCTX("transition",+IDX,"class")=$S(+$G(ACTIVE):"primary-button",1:"quick-button")
 Q
 ;
SNAP(TCTX,IDX,LABEL,DETAIL,CALLBACK,ACTIVE)
 S TCTX("snapshot",+IDX,"label")=$G(LABEL)
 S TCTX("snapshot",+IDX,"detail")=$G(DETAIL)
 S TCTX("snapshot",+IDX,"callback")=$G(CALLBACK)
 S TCTX("snapshot",+IDX,"isActive")=+$G(ACTIVE)
 S TCTX("snapshot",+IDX,"class")=$S(+$G(ACTIVE):"primary-button",1:"quick-button")
 Q
 ;
MAP(TCTX,IDX,LABEL,ROUTE,LAYOUT,CALLBACK)
 S TCTX("routeMap",+IDX,"label")=$G(LABEL)
 S TCTX("routeMap",+IDX,"route")=$G(ROUTE)
 S TCTX("routeMap",+IDX,"layout")=$G(LAYOUT)
 S TCTX("routeMap",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
FOCUS(TCTX,IDX,LABEL,DETAIL,CALLBACK)
 S TCTX("focusMode",+IDX,"label")=$G(LABEL)
 S TCTX("focusMode",+IDX,"detail")=$G(DETAIL)
 S TCTX("focusMode",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
HAND(TCTX,IDX,LABEL,DETAIL,CALLBACK)
 S TCTX("handoff",+IDX,"label")=$G(LABEL)
 S TCTX("handoff",+IDX,"detail")=$G(DETAIL)
 S TCTX("handoff",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
MATRIX(TCTX,IDX,LABEL,DETAIL,CALLBACK)
 S TCTX("matrix",+IDX,"label")=$G(LABEL)
 S TCTX("matrix",+IDX,"detail")=$G(DETAIL)
 S TCTX("matrix",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
