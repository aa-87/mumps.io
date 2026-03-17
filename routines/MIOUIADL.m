MIOUIADL ; adaptive dense workspace builders and route
 Q
 ;
REG(CONF)
 N META
 K META S META("authRequired")=0,META("roles")=""
 D ADDM^MIOROUTE("GET","/mioui/adaptive-workspaces","ADAPTWS^MIOUIADL",.META)
 S ^MIO("ROUTE","RAW","GET","/mioui/adaptive-workspaces")="ADAPTWS^MIOUIADL"
 S ^MIO("ROUTE","META","GET","/mioui/adaptive-workspaces","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/adaptive-workspaces","roles")=""
 Q
 ;
ADAPTWS(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_adaptive_workspaces.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
BUILD(CONF,REQ,CTX,TCTX)
 D BASE^MIOUICTX(.TCTX)
 D APPLY^MIOUITHEME(.CONF,.TCTX)
 D ACT^MIOUICTX(.TCTX,"tables")
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Adaptive dense workspaces","Adaptive dense workspaces","Role-aware and keyboard-first layout presets for dense data applications with persistent pane ratios, collapsible rails, and responsive stacking.","Adaptive dense workspaces")
 S TCTX("workspaceTitle")="Adaptive dense workspaces"
 S TCTX("workspaceLead")="Choose shell behavior by role, task, and screen width. These patterns keep queue-heavy applications dense without forcing every operator into the same pane structure."
 ; preset bar
 S TCTX("presetTitle")="Role and task presets"
 S TCTX("presetLead")="Presets should switch multiple layout settings together: active shell, focused pane, saved split ratio, visible rails, and shortcut profile."
 D PRESET(.TCTX,1,"Revenue follow-up","Collector triage","Tri-split queue","Ctrl+1","applyPresetRevenueFollowup",1)
 D PRESET(.TCTX,2,"QA review","Deep audit","Focus inspector","Ctrl+2","applyPresetQaReview",0)
 D PRESET(.TCTX,3,"Team lead","Board control","Board + rail","Ctrl+3","applyPresetTeamLead",0)
 D PRESET(.TCTX,4,"Analyst","Variance drill","Analytics canvas","Ctrl+4","applyPresetAnalytics",0)
 D PRESET(.TCTX,5,"Supervisor","Command center","Command center","Ctrl+5","applyPresetSupervisor",0)
 ; pane focus
 S TCTX("focusTitle")="Keyboard-first pane focus"
 S TCTX("focusLead")="Make pane focus explicit so operators can move between the queue, inspector, trace, notes, and actions without leaving the keyboard."
 D PANE(.TCTX,1,"Queue pane","Main claim list and search results.","Alt+Q",1)
 D PANE(.TCTX,2,"Inspector pane","Selected-row details and service lines.","Alt+I",0)
 D PANE(.TCTX,3,"Trace pane","Source-path evidence and diagnostics.","Alt+T",0)
 D PANE(.TCTX,4,"Notes pane","Inline annotations and follow-up notes.","Alt+N",0)
 D PANE(.TCTX,5,"Action rail","Bulk actions and publish controls.","Alt+A",0)
 S TCTX("focusCallback")="focusTracePane"
 ; ratios
 S TCTX("ratioTitle")="Persistent pane ratios"
 S TCTX("ratioLead")="Store split percentages by preset so operators return to the same spatial rhythm at login and between tasks."
 D RATIO(.TCTX,1,"Tri-split audit","22 / 48 / 30","Filters, grid, trace",1)
 D RATIO(.TCTX,2,"Inspector heavy","18 / 58 / 24","Worklist, review, rail",0)
 D RATIO(.TCTX,3,"Board review","16 / 64 / 20","Buckets, board, rail",0)
 D RATIO(.TCTX,4,"Analytics compare","18 / 54 / 28","Navigator, canvas, formulas",0)
 S TCTX("ratioCallback")="saveSplitPreset"
 ; collapsed rails
 S TCTX("railTitle")="Collapsed rails"
 S TCTX("railLead")="Dense applications need rails that can collapse to recover horizontal space while preserving state and quick reopen affordances."
 D RAIL(.TCTX,1,"Left filter rail","Collapsed","toggleLeftRail")
 D RAIL(.TCTX,2,"Right inspector rail","Expanded","toggleRightRail")
 D RAIL(.TCTX,3,"Bottom action rail","Collapsed","toggleBottomRail")
 S TCTX("railCallback")="toggleRightRail"
 ; responsive stacking
 S TCTX("responsiveTitle")="Responsive dense stacking"
 S TCTX("responsiveLead")="On smaller screens, preserve density by changing the pane sequence rather than simply hiding content."
 D STACK(.TCTX,1,"Desktop","Three live panes","Queue + review + trace visible","useDesktopDenseMode")
 D STACK(.TCTX,2,"Laptop","Two panes plus overlay rail","Inspector becomes an overlay rail","useLaptopDenseMode")
 D STACK(.TCTX,3,"Tablet","Stacked queue and inspector","Trace opens in an overlay sheet","useTabletDenseMode")
 D STACK(.TCTX,4,"Narrow mobile","Single active pane","Fast preset switcher and keyboard overlay survive","useMobileDenseMode")
 ; shortcuts
 S TCTX("shortcutTitle")="Keyboard shortcuts"
 S TCTX("shortcutLead")="Expose the shortcut system inside the layout package so teams can learn and trust pane switching, saved presets, and rail toggles."
 D SHORT(.TCTX,1,"Open shortcut overlay","?","openShortcutOverlay")
 D SHORT(.TCTX,2,"Focus queue pane","Alt+Q","focusQueuePane")
 D SHORT(.TCTX,3,"Focus trace pane","Alt+T","focusTracePane")
 D SHORT(.TCTX,4,"Cycle presets","Ctrl+Shift+P","cycleWorkspacePreset")
 D SHORT(.TCTX,5,"Save current split","Ctrl+Shift+S","saveSplitPreset")
 Q
 ;
PRESET(TCTX,IDX,ROLE,TASK,LAYOUT,HINT,CALLBACK,ACTIVE)
 S TCTX("preset",+IDX,"role")=$G(ROLE)
 S TCTX("preset",+IDX,"task")=$G(TASK)
 S TCTX("preset",+IDX,"layout")=$G(LAYOUT)
 S TCTX("preset",+IDX,"hint")=$G(HINT)
 S TCTX("preset",+IDX,"callback")=$G(CALLBACK)
 S TCTX("preset",+IDX,"isActive")=+$G(ACTIVE)
 S TCTX("preset",+IDX,"class")=$S(+$G(ACTIVE):"primary-button",1:"quick-button")
 Q
 ;
PANE(TCTX,IDX,LABEL,DETAIL,KEY,ACTIVE)
 S TCTX("focusPane",+IDX,"label")=$G(LABEL)
 S TCTX("focusPane",+IDX,"detail")=$G(DETAIL)
 S TCTX("focusPane",+IDX,"key")=$G(KEY)
 S TCTX("focusPane",+IDX,"isActive")=+$G(ACTIVE)
 S TCTX("focusPane",+IDX,"badgeClass")=$S(+$G(ACTIVE):"badge badge-sky",1:"badge")
 Q
 ;
RATIO(TCTX,IDX,LABEL,RATIO,DETAIL,ACTIVE)
 S TCTX("ratio",+IDX,"label")=$G(LABEL)
 S TCTX("ratio",+IDX,"ratio")=$G(RATIO)
 S TCTX("ratio",+IDX,"detail")=$G(DETAIL)
 S TCTX("ratio",+IDX,"isActive")=+$G(ACTIVE)
 Q
 ;
RAIL(TCTX,IDX,LABEL,STATE,CALLBACK)
 S TCTX("rail",+IDX,"label")=$G(LABEL)
 S TCTX("rail",+IDX,"state")=$G(STATE)
 S TCTX("rail",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
STACK(TCTX,IDX,LABEL,MODE,DETAIL,CALLBACK)
 S TCTX("stack",+IDX,"label")=$G(LABEL)
 S TCTX("stack",+IDX,"mode")=$G(MODE)
 S TCTX("stack",+IDX,"detail")=$G(DETAIL)
 S TCTX("stack",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
SHORT(TCTX,IDX,LABEL,KEY,CALLBACK)
 S TCTX("shortcut",+IDX,"label")=$G(LABEL)
 S TCTX("shortcut",+IDX,"key")=$G(KEY)
 S TCTX("shortcut",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
