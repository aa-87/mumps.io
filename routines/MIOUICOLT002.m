MIOUICOLT002 ; Collaboration token coverage tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T100(.LOCAL)
 D T110(.LOCAL)
 D T120(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUICOLT002"
 I LOCAL S FAIL=1
 Q
 ;
T100(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDPR^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUICOL("pages/miouicol_presence.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T100][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T100][kicker]",OUT,"Reusable collaboration primitives")
 D HAS^MIOUIT000(.FAIL,"[T100][group 1]",OUT,"Follow-up swarm")
 D HAS^MIOUIT000(.FAIL,"[T100][group 2]",OUT,"Eligibility pod")
 D HAS^MIOUIT000(.FAIL,"[T100][group 3]",OUT,"Escalation watch")
 D HAS^MIOUIT000(.FAIL,"[T100][user bubbles]",OUT,"User bubbles")
 D HAS^MIOUIT000(.FAIL,"[T100][maya]",OUT,"Maya Chen")
 D HAS^MIOUIT000(.FAIL,"[T100][jordan]",OUT,"Jordan Reyes")
 D HAS^MIOUIT000(.FAIL,"[T100][nina]",OUT,"Nina Patel")
 D HAS^MIOUIT000(.FAIL,"[T100][owen]",OUT,"Owen Brooks")
 D HAS^MIOUIT000(.FAIL,"[T100][online]",OUT,"Online")
 D HAS^MIOUIT000(.FAIL,"[T100][busy]",OUT,"Busy")
 D HAS^MIOUIT000(.FAIL,"[T100][away]",OUT,"Away")
 D HAS^MIOUIT000(.FAIL,"[T100][offline]",OUT,"Offline")
 D HAS^MIOUIT000(.FAIL,"[T100][detail card]",OUT,"Pinned workspace")
 Q
 ;
T110(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDAV^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUICOL("pages/miouicol_avatars.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T110][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T110][tab avatars]",OUT,"Avatars")
 D HAS^MIOUIT000(.FAIL,"[T110][stack label]",OUT,"Avatar stack")
 D HAS^MIOUIT000(.FAIL,"[T110][shared rail]",OUT,"Shared review rail")
 D HAS^MIOUIT000(.FAIL,"[T110][role chips]",OUT,"Role chips")
 D HAS^MIOUIT000(.FAIL,"[T110][dr maya]",OUT,"Dr. Maya Chen")
 D HAS^MIOUIT000(.FAIL,"[T110][primary assignee]",OUT,"Primary assignee")
 D HAS^MIOUIT000(.FAIL,"[T110][medical reviewer]",OUT,"Medical reviewer")
 D HAS^MIOUIT000(.FAIL,"[T110][shared review coverage]",OUT,"shared review coverage")
 Q
 ;
T120(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDUS^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUICOL("pages/miouicol_users.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T120][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T120][connected users]",OUT,"Connected users")
 D HAS^MIOUIT000(.FAIL,"[T120][current workspace]",OUT,"Current workspace")
 D HAS^MIOUIT000(.FAIL,"[T120][unread]",OUT,"Unread")
 D HAS^MIOUIT000(.FAIL,"[T120][last active]",OUT,"Last active")
 D HAS^MIOUIT000(.FAIL,"[T120][workload]",OUT,"Workload")
 D HAS^MIOUIT000(.FAIL,"[T120][denial command]",OUT,"Denial command")
 D HAS^MIOUIT000(.FAIL,"[T120][claim follow-up]",OUT,"Claim follow-up")
 D HAS^MIOUIT000(.FAIL,"[T120][batch qa]",OUT,"Batch QA")
 D HAS^MIOUIT000(.FAIL,"[T120][who is viewing]",OUT,"Who is viewing this")
 D HAS^MIOUIT000(.FAIL,"[T120][handoff readiness]",OUT,"Handoff readiness")
 Q
 ;
