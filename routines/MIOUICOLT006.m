MIOUICOLT006 ; Collaboration onboarding token coverage tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T200(.LOCAL)
 D T210(.LOCAL)
 D T220(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUICOLT006"
 I LOCAL S FAIL=1
 Q
 ;
T200(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDON^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX,"standard")
 D RENDER^MIOUICOL("pages/miouicol_onboarding.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T200][render ok]",$D(ERR),0)
 D TOK(.FAIL,"[T200][standard]",OUT)
 D HAS^MIOUIT000(.FAIL,"[T200][title]",OUT,"Onboarding workspace")
 Q
 ;
T210(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDON^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX,"dense")
 D RENDER^MIOUICOL("pages/miouicol_onboarding_dense.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T210][render ok]",$D(ERR),0)
 D TOK(.FAIL,"[T210][dense]",OUT)
 D HAS^MIOUIT000(.FAIL,"[T210][title]",OUT,"Dense onboarding review")
 Q
 ;
T220(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDON^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX,"guided")
 D RENDER^MIOUICOL("pages/miouicol_onboarding_guided.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T220][render ok]",$D(ERR),0)
 D TOK(.FAIL,"[T220][guided]",OUT)
 D HAS^MIOUIT000(.FAIL,"[T220][title]",OUT,"Guided onboarding launch")
 D HAS^MIOUIT000(.FAIL,"[T220][guided journey]",OUT,"Guided journey")
 Q
 ;
TOK(FAIL,LABEL,OUT)
 D HAS^MIOUIT000(.FAIL,LABEL_"[workspace onboarding]",OUT,"Workspace onboarding")
 D HAS^MIOUIT000(.FAIL,LABEL_"[identity and team]",OUT,"Identity and team")
 D HAS^MIOUIT000(.FAIL,LABEL_"[invite and presence]",OUT,"Invite and presence")
 D HAS^MIOUIT000(.FAIL,LABEL_"[rooms and watchlists]",OUT,"Rooms and watchlists")
 D HAS^MIOUIT000(.FAIL,LABEL_"[starter welcome note]",OUT,"Starter welcome note")
 D HAS^MIOUIT000(.FAIL,LABEL_"[launch and defaults]",OUT,"Launch and defaults")
 D HAS^MIOUIT000(.FAIL,LABEL_"[connected preview]",OUT,"Connected users preview")
 D HAS^MIOUIT000(.FAIL,LABEL_"[default rooms]",OUT,"Default rooms")
 D HAS^MIOUIT000(.FAIL,LABEL_"[eligibility refresh]",OUT,"Eligibility refresh")
 D HAS^MIOUIT000(.FAIL,LABEL_"[escalation watch]",OUT,"Escalation watch")
 D HAS^MIOUIT000(.FAIL,LABEL_"[maya]",OUT,"Maya Chen")
 D HAS^MIOUIT000(.FAIL,LABEL_"[jordan]",OUT,"Jordan Reyes")
 D HAS^MIOUIT000(.FAIL,LABEL_"[launch workspace]",OUT,"Launch workspace")
 Q
 ;
