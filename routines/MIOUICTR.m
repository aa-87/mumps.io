MIOUICTR ; control-room layout builders
 Q
 ;
REG(CONF)
 N META
 K META S META("authRequired")=0,META("roles")=""
 D ADDM^MIOROUTE("GET","/mioui/control-room-layouts","CTRL^MIOUICTR",.META)
 S ^MIO("ROUTE","RAW","GET","/mioui/control-room-layouts")="CTRL^MIOUICTR"
 S ^MIO("ROUTE","META","GET","/mioui/control-room-layouts","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/control-room-layouts","roles")=""
 Q
 ;
CTRL(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_control_room_layouts.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
BUILD(CONF,REQ,CTX,TCTX)
 D BASE^MIOUICTX(.TCTX)
 D APPLY^MIOUITHEME(.CONF,.TCTX)
 D ACT^MIOUICTX(.TCTX,"tables")
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Control-room layouts","Control-room layouts","Supervisory command-room shells for dense claim operations, escalation management, exception routing, and shift execution.","Control-room layouts")
 S TCTX("workspaceTitle")="Control-room layouts"
 S TCTX("workspaceLead")="Use these patterns when dense queue work needs supervisor sightlines, live escalation ownership, resolution sweeps, and visible command callbacks."
 S TCTX("briefTitle")="Shift briefing ribbon"
 S TCTX("briefLead")="Pin the current shift goal, handoff delta, and active callback path before operators enter the queue."
 D BRIEF(.TCTX,1,"Morning objectives","Top payer backlog, oldest blockers, and SLA risk","openBriefingObjectives")
 D BRIEF(.TCTX,2,"Shift delta","What changed since the last handoff","openBriefingDelta")
 D BRIEF(.TCTX,3,"Command callback","Launch the shift control checklist","openShiftCommandChecklist")
 S TCTX("heatTitle")="Capacity heat grid"
 S TCTX("heatLead")="Show where staff, queue volume, and exception pressure are moving together across the workspace."
 D HEAT(.TCTX,1,"Team A","Payer follow-up lane","High pressure","openCapacityHeatTeamA")
 D HEAT(.TCTX,2,"Team B","QA and exception review","Moderate pressure","openCapacityHeatTeamB")
 D HEAT(.TCTX,3,"Team C","Supervisor reserve","Low pressure","openCapacityHeatTeamC")
 S TCTX("escalTitle")="Supervisor escalation stack"
 S TCTX("escalLead")="Keep the highest-severity items in a visible ordered stack with an explicit next callback."
 D ESCAL(.TCTX,1,"Missing COB evidence","Collector blocked until evidence arrives","openEscalationCob")
 D ESCAL(.TCTX,2,"Timely filing appeal","Lead review needed before 2 PM","openEscalationTimely")
 D ESCAL(.TCTX,3,"Authorization variance","Supervisor decision required","openEscalationAuth")
 S TCTX("exceptionTitle")="Live exception lane"
 S TCTX("exceptionLead")="Route exceptions into a dedicated lane without collapsing the main queue shell."
 D EX(.TCTX,1,"New fatal parser issue","SV201 mismatch in active batch","openExceptionFatal")
 D EX(.TCTX,2,"Carrier response drift","Unexpected payer mapping values","openExceptionCarrier")
 D EX(.TCTX,3,"Export profile mismatch","Column preset out of sync with route","openExceptionExport")
 S TCTX("sweepTitle")="Resolution sweep board"
 S TCTX("sweepLead")="Use the sweep board to clear stale blockers, unowned notes, and near-complete items before shift end."
 D SWEEP(.TCTX,1,"Unowned blockers","14 items ready for assignment","openSweepBlockers")
 D SWEEP(.TCTX,2,"Aging notes","9 notes older than 4 hours","openSweepNotes")
 D SWEEP(.TCTX,3,"Ready-to-close claims","23 claims waiting on final action","openSweepReady")
 S TCTX("footerTitle")="Route command footer"
 S TCTX("footerLead")="A compact footer for active shell, escalation count, queue mode, and the next route-specific command."
 S TCTX("footer","shell")="Supervisor command room"
 S TCTX("footer","route")="/claims/follow-up"
 S TCTX("footer","mode")="Escalation review"
 S TCTX("footer","count")="6 active escalations"
 S TCTX("footer","callback")="openRouteCommandFooter"
 Q
 ;
BRIEF(TCTX,IDX,LABEL,DETAIL,CALLBACK)
 S TCTX("brief",+IDX,"label")=$G(LABEL)
 S TCTX("brief",+IDX,"detail")=$G(DETAIL)
 S TCTX("brief",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
HEAT(TCTX,IDX,LABEL,DETAIL,STATE,CALLBACK)
 S TCTX("heat",+IDX,"label")=$G(LABEL)
 S TCTX("heat",+IDX,"detail")=$G(DETAIL)
 S TCTX("heat",+IDX,"state")=$G(STATE)
 S TCTX("heat",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
ESCAL(TCTX,IDX,LABEL,DETAIL,CALLBACK)
 S TCTX("escal",+IDX,"label")=$G(LABEL)
 S TCTX("escal",+IDX,"detail")=$G(DETAIL)
 S TCTX("escal",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
EX(TCTX,IDX,LABEL,DETAIL,CALLBACK)
 S TCTX("exception",+IDX,"label")=$G(LABEL)
 S TCTX("exception",+IDX,"detail")=$G(DETAIL)
 S TCTX("exception",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
SWEEP(TCTX,IDX,LABEL,DETAIL,CALLBACK)
 S TCTX("sweep",+IDX,"label")=$G(LABEL)
 S TCTX("sweep",+IDX,"detail")=$G(DETAIL)
 S TCTX("sweep",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
