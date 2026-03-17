MIOUILYT ; data-intensive layout structure builders and route
 Q
 ;
REG(CONF)
 N META
 K META S META("authRequired")=0,META("roles")=""
 D ADDM^MIOROUTE("GET","/mioui/data-layouts","DATALAYOUTS^MIOUILYT",.META)
 S ^MIO("ROUTE","RAW","GET","/mioui/data-layouts")="DATALAYOUTS^MIOUILYT"
 S ^MIO("ROUTE","META","GET","/mioui/data-layouts","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/data-layouts","roles")=""
 Q
 ;
DATALAYOUTS(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_data_layouts.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
BUILD(CONF,REQ,CTX,TCTX)
 D BASE^MIOUICTX(.TCTX)
 D APPLY^MIOUITHEME(.CONF,.TCTX)
 D ACT^MIOUICTX(.TCTX,"tables")
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Data application layouts","Data application layouts","Reusable shell structures for dense operator queues, triage boards, analytics canvases, inspector-heavy review flows, and multi-pane command centers.","Data application layouts")
 S TCTX("layoutTitle")="Data application layouts"
 S TCTX("layoutLead")="Use layout structures to decide where dense tables, inspectors, metrics, traces, and action rails live before choosing lower-level widgets. These patterns are designed for high-volume billing and operator applications."
 S TCTX("layoutModesTitle")="Layout modes"
 S TCTX("layoutModesLead")="Switch layout structures based on the job to be done, not on a single universal shell."
 D MODE(.TCTX,1,"Command center","Best for queue ownership, metrics, and live work intake.",1)
 D MODE(.TCTX,2,"Tri-split review","Best for queue + inspector + trace evidence.",0)
 D MODE(.TCTX,3,"Board + rail","Best for work buckets and assignment flows.",0)
 D MODE(.TCTX,4,"Analytics canvas","Best for wide comparisons and aggregate-heavy review.",0)
 D MODE(.TCTX,5,"Focus inspector","Best for single-row deep work with strong side context.",0)
 ; operator command center
 S TCTX("layout","command","title")="Operator command center"
 S TCTX("layout","command","lead")="Top metrics plus a primary queue and a right rail keeps intake, SLA state, and next actions visible without hiding the main table."
 D CMDMET(.TCTX,1,"Ready now",128,"badge badge-emerald")
 D CMDMET(.TCTX,2,"Needs review",42,"badge badge-amber")
 D CMDMET(.TCTX,3,"Over SLA",9,"badge badge-rose")
 D CMDSLOT(.TCTX,1,"Primary queue","Claims queue with owner, DOS, status, and variance visible.")
 D CMDSLOT(.TCTX,2,"Right rail","Alerts, handoff notes, and quick callbacks.")
 D CMDACT(.TCTX,1,"Assign west pod","assignWestPod")
 D CMDACT(.TCTX,2,"Publish reviewed","publishReviewed")
 ; tri-split
 S TCTX("layout","tri","title")="Tri-split queue layout"
 S TCTX("layout","tri","lead")="A left filter rail, center review table, and right trace inspector works well when teams move rapidly between list review and evidence."
 D TRICOL(.TCTX,1,"Filter rail","Saved views, facets, and search scopes.")
 D TRICOL(.TCTX,2,"Review grid","High-density queue with pinned claim identity.")
 D TRICOL(.TCTX,3,"Trace inspector","Source-path evidence and diagnostics.")
 S TCTX("layout","tri","callback")="syncTraceToSelection"
 ; focus inspector
 S TCTX("layout","focus","title")="Focus inspector layout"
 S TCTX("layout","focus","lead")="Keep a narrow worklist on the left and dedicate most of the screen to the selected row, service lines, diagnostics, and timeline."
 D FOCUSSEC(.TCTX,1,"Pinned worklist","Compact claims list with 15-row visible slice.")
 D FOCUSSEC(.TCTX,2,"Primary review pane","Claim summary, service lines, and validation summary.")
 D FOCUSSEC(.TCTX,3,"Sticky inspector rail","Artifacts, callbacks, and audit events.")
 ; board rail
 S TCTX("layout","board","title")="Board + rail layout"
 S TCTX("layout","board","lead")="Use grouped work buckets in the center with a persistent rail for selection, assignment, and bulk actions."
 D BOARDCOL(.TCTX,1,"Ready bucket",56)
 D BOARDCOL(.TCTX,2,"Needs payer follow-up",18)
 D BOARDCOL(.TCTX,3,"Blocked",7)
 S TCTX("layout","board","railTitle")="Sticky bottom action rail"
 S TCTX("layout","board","railLead")="Selection state, bulk actions, and undo cues should stay anchored even while operators scroll tall boards."
 S TCTX("layout","board","callback")="openBulkDrawer"
 ; analytics
 S TCTX("layout","analytics","title")="Analytics canvas"
 S TCTX("layout","analytics","lead")="A wide top comparison band, lower detail table, and formula rail works best when users cross-check aggregates and exact rows at the same time."
 D CANVASROW(.TCTX,1,"Comparison band","Variance vs allowed amount vs charge by payer and owner.")
 D CANVASROW(.TCTX,2,"Lower detail grid","Current filtered row window with sortable numeric columns.")
 D CANVASROW(.TCTX,3,"Formula rail","Live totals, subtotals, and export parity cues.")
 S TCTX("layout","analytics","callback")="applyFormulaPreset"
 Q
 ;
MODE(TCTX,IDX,LABEL,DETAIL,ACTIVE)
 S TCTX("layout","mode",+IDX,"label")=$G(LABEL)
 S TCTX("layout","mode",+IDX,"detail")=$G(DETAIL)
 S TCTX("layout","mode",+IDX,"isActive")=+$G(ACTIVE)
 S TCTX("layout","mode",+IDX,"class")=$S(+$G(ACTIVE):"primary-button",1:"quick-button")
 Q
 ;
CMDMET(TCTX,IDX,LABEL,VALUE,BADGE)
 S TCTX("layout","command","metric",+IDX,"label")=$G(LABEL)
 S TCTX("layout","command","metric",+IDX,"value")=$G(VALUE)
 S TCTX("layout","command","metric",+IDX,"badgeClass")=$G(BADGE)
 Q
 ;
CMDSLOT(TCTX,IDX,TITLE,DETAIL)
 S TCTX("layout","command","slot",+IDX,"title")=$G(TITLE)
 S TCTX("layout","command","slot",+IDX,"detail")=$G(DETAIL)
 Q
 ;
CMDACT(TCTX,IDX,LABEL,CALLBACK)
 S TCTX("layout","command","action",+IDX,"label")=$G(LABEL)
 S TCTX("layout","command","action",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
TRICOL(TCTX,IDX,TITLE,DETAIL)
 S TCTX("layout","tri","col",+IDX,"title")=$G(TITLE)
 S TCTX("layout","tri","col",+IDX,"detail")=$G(DETAIL)
 Q
 ;
FOCUSSEC(TCTX,IDX,TITLE,DETAIL)
 S TCTX("layout","focus","section",+IDX,"title")=$G(TITLE)
 S TCTX("layout","focus","section",+IDX,"detail")=$G(DETAIL)
 Q
 ;
BOARDCOL(TCTX,IDX,TITLE,COUNT)
 S TCTX("layout","board","col",+IDX,"title")=$G(TITLE)
 S TCTX("layout","board","col",+IDX,"count")=$G(COUNT)
 Q
 ;
CANVASROW(TCTX,IDX,TITLE,DETAIL)
 S TCTX("layout","analytics","row",+IDX,"title")=$G(TITLE)
 S TCTX("layout","analytics","row",+IDX,"detail")=$G(DETAIL)
 Q
 ;
