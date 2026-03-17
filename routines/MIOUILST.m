MIOUILST ; workspace state and session-restored layout builders
 Q
 ;
REG(CONF)
 N META
 K META S META("authRequired")=0,META("roles")=""
 D ADDM^MIOROUTE("GET","/mioui/workspace-state","STATE^MIOUILST",.META)
 S ^MIO("ROUTE","RAW","GET","/mioui/workspace-state")="STATE^MIOUILST"
 S ^MIO("ROUTE","META","GET","/mioui/workspace-state","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/workspace-state","roles")=""
 Q
 ;
STATE(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_workspace_state.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
BUILD(CONF,REQ,CTX,TCTX)
 D BASE^MIOUICTX(.TCTX)
 D APPLY^MIOUITHEME(.CONF,.TCTX)
 D ACT^MIOUICTX(.TCTX,"tables")
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Workspace state orchestration","Workspace state orchestration","Session-restored layout state, role-aware defaults, route-specific pane persistence, mobile audit variants, and annotation rails tied to workspace context.","Workspace state orchestration")
 S TCTX("workspaceTitle")="Workspace state orchestration"
 S TCTX("workspaceLead")="Treat layout as durable application state. These surfaces restore the operator workspace by route, role, and task so dense data screens reopen with the right panes, rails, and annotations already in place."
 ; session restore
 S TCTX("restoreTitle")="Session-restored layout state"
 S TCTX("restoreLead")="Reopen the last useful workspace without forcing the operator to rebuild pane ratios, active preset, rail state, and current review anchor every login."
 D RESTORE(.TCTX,1,"Claims follow-up queue","Collector triage · /claims/queue","Tri-split audit · 22 / 48 / 30","restoreQueueSession",1)
 D RESTORE(.TCTX,2,"Claim review detail","QA deep audit · /claims/review/CLM-1001","Focus inspector · trace rail open","restoreReviewSession",0)
 D RESTORE(.TCTX,3,"Denial board","Supervisor board · /denials/board","Board + rail · bottom bulk tray closed","restoreBoardSession",0)
 D RESTORE(.TCTX,4,"Variance analytics","Analyst compare · /analytics/variance","Analytics canvas · formula rail open","restoreAnalyticsSession",0)
 ; role defaults
 S TCTX("roleTitle")="Auth-aware role defaults"
 S TCTX("roleLead")="Layout defaults should be seeded from authenticated role and task scope before user overrides are applied."
 D ROLE(.TCTX,1,"Collector","Tri-split queue","Filters + queue + actions","useCollectorDefaultLayout")
 D ROLE(.TCTX,2,"QA reviewer","Focus inspector","Review + trace + notes","useQaDefaultLayout")
 D ROLE(.TCTX,3,"Supervisor","Command center","Metrics + board + rail","useSupervisorDefaultLayout")
 D ROLE(.TCTX,4,"Analyst","Analytics canvas","Compare + detail grid + formulas","useAnalystDefaultLayout")
 ; route persistence
 S TCTX("routeTitle")="Route-specific pane persistence"
 S TCTX("routeLead")="Persist pane state by route so claims, denials, analytics, and audit traces each reopen with the correct spatial rhythm."
 D RTE(.TCTX,1,"/claims/queue","22 / 48 / 30","Left filter rail collapsed","persistClaimsQueueState")
 D RTE(.TCTX,2,"/claims/review/:id","18 / 58 / 24","Trace pane focused","persistClaimReviewState")
 D RTE(.TCTX,3,"/denials/board","16 / 64 / 20","Board swimlanes expanded","persistDenialBoardState")
 D RTE(.TCTX,4,"/analytics/variance","18 / 54 / 28","Formula rail open","persistAnalyticsState")
 ; mobile audit
 S TCTX("mobileTitle")="Mobile-first dense audit variants"
 S TCTX("mobileLead")="Dense audit pages should degrade into controlled overlays and compact stacks, not blank space or hidden evidence."
 D MOBILE(.TCTX,1,"Phone audit stack","Single active pane + bottom shortcut bar","openPhoneAuditVariant")
 D MOBILE(.TCTX,2,"Tablet trace overlay","Queue + inspector with trace sheet","openTabletTraceVariant")
 D MOBILE(.TCTX,3,"Laptop dense audit","Dual pane + hot trace popover","openLaptopAuditVariant")
 D MOBILE(.TCTX,4,"Desktop evidence mode","Three live panes + pinned notes rail","openDesktopAuditVariant")
 ; annotation rail
 S TCTX("annotTitle")="Threaded annotation rail"
 S TCTX("annotLead")="Keep threaded notes attached to the active row, active route, and current workspace so annotations survive layout changes."
 D ANNOT(.TCTX,1,"Claim status mismatch","CLM-1001 · active row","Trace pane","openClaimAnnotationThread")
 D ANNOT(.TCTX,2,"DOS check pending","SV1 line 2","Inspector pane","openDosAnnotationThread")
 D ANNOT(.TCTX,3,"Override requested","Board card DEN-244","Action rail","openOverrideAnnotationThread")
 D ANNOT(.TCTX,4,"Variance note","Analytics comparison set","Formula rail","openVarianceAnnotationThread")
 ; footer audit
 S TCTX("footerTitle")="Workspace state footer"
 S TCTX("footerLead")="Expose the saved state object so dense products can explain what will be restored and when it was last changed."
 S TCTX("stateKey")="collector.claims.queue.default"
 S TCTX("stateRoute")="/claims/queue"
 S TCTX("statePreset")="Revenue follow-up"
 S TCTX("stateChanged")="2026-03-17 22:48 ET"
 S TCTX("stateCallback")="saveWorkspaceStateNow"
 Q
 ;
RESTORE(TCTX,IDX,LABEL,DETAIL,STATE,CALLBACK,ACTIVE)
 S TCTX("restore",+IDX,"label")=$G(LABEL)
 S TCTX("restore",+IDX,"detail")=$G(DETAIL)
 S TCTX("restore",+IDX,"state")=$G(STATE)
 S TCTX("restore",+IDX,"callback")=$G(CALLBACK)
 S TCTX("restore",+IDX,"isActive")=+$G(ACTIVE)
 S TCTX("restore",+IDX,"class")=$S(+$G(ACTIVE):"primary-button",1:"quick-button")
 Q
 ;
ROLE(TCTX,IDX,ROLE,LAYOUT,DETAIL,CALLBACK)
 S TCTX("roleDefault",+IDX,"role")=$G(ROLE)
 S TCTX("roleDefault",+IDX,"layout")=$G(LAYOUT)
 S TCTX("roleDefault",+IDX,"detail")=$G(DETAIL)
 S TCTX("roleDefault",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
RTE(TCTX,IDX,ROUTE,RATIO,STATE,CALLBACK)
 S TCTX("routePersist",+IDX,"route")=$G(ROUTE)
 S TCTX("routePersist",+IDX,"ratio")=$G(RATIO)
 S TCTX("routePersist",+IDX,"state")=$G(STATE)
 S TCTX("routePersist",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
MOBILE(TCTX,IDX,LABEL,DETAIL,CALLBACK)
 S TCTX("mobileVariant",+IDX,"label")=$G(LABEL)
 S TCTX("mobileVariant",+IDX,"detail")=$G(DETAIL)
 S TCTX("mobileVariant",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
ANNOT(TCTX,IDX,LABEL,ANCHOR,PANE,CALLBACK)
 S TCTX("annotation",+IDX,"label")=$G(LABEL)
 S TCTX("annotation",+IDX,"anchor")=$G(ANCHOR)
 S TCTX("annotation",+IDX,"pane")=$G(PANE)
 S TCTX("annotation",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
