MIOUICOLT001 ; Collaboration route and smoke tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 D T020(.LOCAL)
 D T030(.LOCAL)
 D T040(.LOCAL)
 D T050(.LOCAL)
 D T060(.LOCAL)
 D T070(.LOCAL)
 D T080(.LOCAL)
 D T090(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUICOLT001"
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N CONF
 K ^MIO("ROUTE","RAW","GET","/mioui/collab-presence")
 K ^MIO("ROUTE","RAW","GET","/mioui/collab-avatars")
 K ^MIO("ROUTE","RAW","GET","/mioui/collab-users")
 K ^MIO("ROUTE","RAW","GET","/mioui/collab-chat")
 K ^MIO("ROUTE","RAW","GET","/mioui/collab-chat-dense")
 K ^MIO("ROUTE","RAW","GET","/mioui/collab-chat-balanced")
 K ^MIO("ROUTE","RAW","GET","/mioui/collab-onboarding")
 K ^MIO("ROUTE","RAW","GET","/mioui/collab-onboarding-dense")
 K ^MIO("ROUTE","RAW","GET","/mioui/collab-onboarding-guided")
 D REG^MIOUI(.CONF)
 D EQ^MIOUIT000(.FAIL,"[T001][presence target]",$G(^MIO("ROUTE","RAW","GET","/mioui/collab-presence")),"PRESENCE^MIOUICOL")
 D EQ^MIOUIT000(.FAIL,"[T001][avatars target]",$G(^MIO("ROUTE","RAW","GET","/mioui/collab-avatars")),"AVATARS^MIOUICOL")
 D EQ^MIOUIT000(.FAIL,"[T001][users target]",$G(^MIO("ROUTE","RAW","GET","/mioui/collab-users")),"USERS^MIOUICOL")
 D EQ^MIOUIT000(.FAIL,"[T001][chat target]",$G(^MIO("ROUTE","RAW","GET","/mioui/collab-chat")),"CHAT^MIOUICOL")
 D EQ^MIOUIT000(.FAIL,"[T001][chat dense target]",$G(^MIO("ROUTE","RAW","GET","/mioui/collab-chat-dense")),"CHATDNS^MIOUICOL")
 D EQ^MIOUIT000(.FAIL,"[T001][chat balanced target]",$G(^MIO("ROUTE","RAW","GET","/mioui/collab-chat-balanced")),"CHATBAL^MIOUICOL")
 D EQ^MIOUIT000(.FAIL,"[T001][onboarding target]",$G(^MIO("ROUTE","RAW","GET","/mioui/collab-onboarding")),"ONBOARD^MIOUICOL")
 D EQ^MIOUIT000(.FAIL,"[T001][onboarding dense target]",$G(^MIO("ROUTE","RAW","GET","/mioui/collab-onboarding-dense")),"ONBDNS^MIOUICOL")
 D EQ^MIOUIT000(.FAIL,"[T001][onboarding guided target]",$G(^MIO("ROUTE","RAW","GET","/mioui/collab-onboarding-guided")),"ONBGUIDE^MIOUICOL")
 D EQ^MIOUIT000(.FAIL,"[T001][chat auth]",+$G(^MIO("ROUTE","META","GET","/mioui/collab-chat","authRequired")),0)
 D EQ^MIOUIT000(.FAIL,"[T001][onboarding auth]",+$G(^MIO("ROUTE","META","GET","/mioui/collab-onboarding","authRequired")),0)
 D EQ^MIOUIT000(.FAIL,"[T001][onboarding dense auth]",+$G(^MIO("ROUTE","META","GET","/mioui/collab-onboarding-dense","authRequired")),0)
 D EQ^MIOUIT000(.FAIL,"[T001][onboarding guided auth]",+$G(^MIO("ROUTE","META","GET","/mioui/collab-onboarding-guided","authRequired")),0)
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDPR^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUICOL("pages/miouicol_presence.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T010][page title]",OUT,"Presence and user bubbles")
 D HAS^MIOUIT000(.FAIL,"[T010][online now]",OUT,"Online now")
 D HAS^MIOUIT000(.FAIL,"[T010][connected users]",OUT,"Connected users")
 Q
 ;
T020(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDAV^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUICOL("pages/miouicol_avatars.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T020][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T020][page title]",OUT,"Avatars and identity stacks")
 D HAS^MIOUIT000(.FAIL,"[T020][avatar stack]",OUT,"Avatar stack")
 D HAS^MIOUIT000(.FAIL,"[T020][assignee chip]",OUT,"Assignee chip")
 Q
 ;
T030(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDUS^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUICOL("pages/miouicol_users.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T030][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T030][page title]",OUT,"Connected users workspace")
 D HAS^MIOUIT000(.FAIL,"[T030][current workspace]",OUT,"Current workspace")
 D HAS^MIOUIT000(.FAIL,"[T030][workload]",OUT,"Workload")
 Q
 ;
T040(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDCH^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX,"standard")
 D RENDER^MIOUICOL("pages/miouicol_chat.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T040][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T040][page title]",OUT,"Chat primitives")
 D HAS^MIOUIT000(.FAIL,"[T040][composer]",OUT,"Message composer")
 D HAS^MIOUIT000(.FAIL,"[T040][system event]",OUT,"System event")
 Q
 ;
T050(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDCH^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX,"dense")
 D RENDER^MIOUICOL("pages/miouicol_chat_dense.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T050][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T050][page title]",OUT,"Dense chat review")
 D HAS^MIOUIT000(.FAIL,"[T050][unread]",OUT,"3 unread messages")
 D HAS^MIOUIT000(.FAIL,"[T050][typing]",OUT,"Jordan Reyes is typing")
 Q
 ;
T060(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDCH^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX,"balanced")
 D RENDER^MIOUICOL("pages/miouicol_chat_balanced.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T060][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T060][page title]",OUT,"Balanced chat workspace")
 D HAS^MIOUIT000(.FAIL,"[T060][reply preview]",OUT,"Reply preview")
 D HAS^MIOUIT000(.FAIL,"[T060][thread summary]",OUT,"Thread summary")
 Q
 ;
T070(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDON^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX,"standard")
 D RENDER^MIOUICOL("pages/miouicol_onboarding.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T070][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T070][page title]",OUT,"Onboarding workspace")
 D HAS^MIOUIT000(.FAIL,"[T070][workspace onboarding]",OUT,"Workspace onboarding")
 D HAS^MIOUIT000(.FAIL,"[T070][launch workspace]",OUT,"Launch workspace")
 Q
 ;
T080(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDON^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX,"dense")
 D RENDER^MIOUICOL("pages/miouicol_onboarding_dense.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T080][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T080][page title]",OUT,"Dense onboarding review")
 D HAS^MIOUIT000(.FAIL,"[T080][invite preview]",OUT,"Invite preview")
 D HAS^MIOUIT000(.FAIL,"[T080][default rooms]",OUT,"Default rooms")
 Q
 ;
T090(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D CONFDEF^MIOUI(.CONF)
 D BUILDON^MIOUICOLD(.CONF,.REQ,.CTX,.TCTX,"guided")
 D RENDER^MIOUICOL("pages/miouicol_onboarding_guided.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T090][render ok]",$D(ERR),0)
 D HAS^MIOUIT000(.FAIL,"[T090][page title]",OUT,"Guided onboarding launch")
 D HAS^MIOUIT000(.FAIL,"[T090][guided journey]",OUT,"Guided journey")
 D HAS^MIOUIT000(.FAIL,"[T090][connected preview]",OUT,"Connected users preview")
 Q
 ;
