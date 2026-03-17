MIOUIMMR ; multi-monitor dense layout builders
 Q
 ;
REG(CONF)
 N META
 K META S META("authRequired")=0,META("roles")=""
 D ADDM^MIOROUTE("GET","/mioui/multi-monitor-layouts","MMR^MIOUIMMR",.META)
 S ^MIO("ROUTE","RAW","GET","/mioui/multi-monitor-layouts")="MMR^MIOUIMMR"
 S ^MIO("ROUTE","META","GET","/mioui/multi-monitor-layouts","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/multi-monitor-layouts","roles")=""
 Q
 ;
MMR(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_multi_monitor_layouts.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
BUILD(CONF,REQ,CTX,TCTX)
 D BASE^MIOUICTX(.TCTX)
 D APPLY^MIOUITHEME(.CONF,.TCTX)
 D ACT^MIOUICTX(.TCTX,"tables")
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Multi-monitor layouts","Multi-monitor layouts","High-intensity multi-monitor shells for queue triage, evidence review, supervision, failover, and coordinated handoff.","Multi-monitor layouts")
 S TCTX("workspaceTitle")="Multi-monitor layouts"
 S TCTX("workspaceLead")="Use these patterns when a dense operator product needs more than one screen, explicit monitor ownership, and stable supervisory sightlines."
 ; assignment grid
 S TCTX("assignTitle")="Monitor assignment grid"
 S TCTX("assignLead")="Give each monitor a contract so queue, trace, notes, and approval work never fight for the same space."
 D MON(.TCTX,1,"Monitor A","Primary queue","Claims grid, saved filters, and bulk triage","assignMonitorQueue")
 D MON(.TCTX,2,"Monitor B","Evidence wall","Trace, artifacts, notes, and document preview","assignMonitorEvidence")
 D MON(.TCTX,3,"Monitor C","Supervisor rail","Escalations, approvals, and shift handoff","assignMonitorSupervisor")
 ; burst layout
 S TCTX("burstTitle")="Queue burst layout"
 S TCTX("burstLead")="Flip into a burst-response shell when queue spikes demand faster claim movement and fewer secondary panes."
 D BURST(.TCTX,1,"Burst queue board","High-priority claims pinned left","openBurstQueueBoard")
 D BURST(.TCTX,2,"Rapid action rail","Approval, defer, reroute, and annotate","openBurstActionRail")
 D BURST(.TCTX,3,"Cooldown map","Fall back to normal shell after the surge","openBurstCooldownMap")
 ; evidence wall
 S TCTX("wallTitle")="Evidence wall layout"
 S TCTX("wallLead")="Keep source snippets, trace events, diagnostics, and file artifacts visible at the same time."
 D WALL(.TCTX,1,"Trace column","Segment path and event chain","focusEvidenceTrace")
 D WALL(.TCTX,2,"Artifact column","CSV, JSON, and canonical output","focusEvidenceArtifacts")
 D WALL(.TCTX,3,"Diagnostic column","Grouped blockers and warnings","focusEvidenceDiagnostics")
 ; overwatch
 S TCTX("overwatchTitle")="Supervisor overwatch layout"
 S TCTX("overwatchLead")="A wide supervisory shell for blocker heat, reviewer presence, and live intervention."
 D OVER(.TCTX,1,"Blocker heatmap","See where queues stall first","openOverwatchHeatmap")
 D OVER(.TCTX,2,"Reviewer rail","Who owns each lane right now","openOverwatchReviewerRail")
 D OVER(.TCTX,3,"Intervention drawer","Force route, note, or approval callbacks","openOverwatchIntervention")
 ; failover
 S TCTX("failTitle")="Layout failover strip"
 S TCTX("failLead")="Show fallback shells when a monitor drops, a dock closes, or remote review needs a smaller footprint."
 D FAILITEM(.TCTX,1,"3-screen -> 2-screen","Fold evidence wall into right rail","applyFailoverTwoScreen")
 D FAILITEM(.TCTX,2,"2-screen -> laptop","Stack trace under the queue and pin notes","applyFailoverLaptop")
 D FAILITEM(.TCTX,3,"Laptop -> mobile audit","Switch to single-focus evidence mode","applyFailoverMobileAudit")
 ; handshake
 S TCTX("handTitle")="Operator handshake board"
 S TCTX("handLead")="Coordinate ownership changes across reviewers before the layout or queue contract moves."
 D HAND(.TCTX,1,"Collector -> QA","Hand claim set and note context","openHandshakeCollectorQa")
 D HAND(.TCTX,2,"QA -> Lead","Promote blocker with evidence intact","openHandshakeQaLead")
 D HAND(.TCTX,3,"Lead -> Next shift","Leave snapshot, notes, and pinned hotspots","openHandshakeLeadShift")
 Q
 ;
MON(TCTX,IDX,LABEL,ROLE,DETAIL,CALLBACK)
 S TCTX("monitor",+IDX,"label")=$G(LABEL)
 S TCTX("monitor",+IDX,"role")=$G(ROLE)
 S TCTX("monitor",+IDX,"detail")=$G(DETAIL)
 S TCTX("monitor",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
BURST(TCTX,IDX,LABEL,DETAIL,CALLBACK)
 S TCTX("burst",+IDX,"label")=$G(LABEL)
 S TCTX("burst",+IDX,"detail")=$G(DETAIL)
 S TCTX("burst",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
WALL(TCTX,IDX,LABEL,DETAIL,CALLBACK)
 S TCTX("wall",+IDX,"label")=$G(LABEL)
 S TCTX("wall",+IDX,"detail")=$G(DETAIL)
 S TCTX("wall",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
OVER(TCTX,IDX,LABEL,DETAIL,CALLBACK)
 S TCTX("overwatch",+IDX,"label")=$G(LABEL)
 S TCTX("overwatch",+IDX,"detail")=$G(DETAIL)
 S TCTX("overwatch",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
FAILITEM(TCTX,IDX,LABEL,DETAIL,CALLBACK)
 S TCTX("failover",+IDX,"label")=$G(LABEL)
 S TCTX("failover",+IDX,"detail")=$G(DETAIL)
 S TCTX("failover",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
HAND(TCTX,IDX,LABEL,DETAIL,CALLBACK)
 S TCTX("handshake",+IDX,"label")=$G(LABEL)
 S TCTX("handshake",+IDX,"detail")=$G(DETAIL)
 S TCTX("handshake",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
