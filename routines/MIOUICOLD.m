MIOUICOLD ; Collaboration view-model builders for MIOUI
 Q
 ;
BUILDPR(CONF,REQ,CTX,TCTX)
 D BASE(.CONF,.TCTX,"Presence and user bubbles","Realtime-ready identity primitives for dense operator workspaces.","Collaboration / Presence")
 D TABS(.TCTX,"presence")
 D HERO(.TCTX,"Presence coverage",92,"Connected now",18,"Escalation watch",3)
 D GROUP(.TCTX,1,"Follow-up swarm","Reviewing open balances","Sky")
 D GROUP(.TCTX,2,"Eligibility pod","Watching eligibility flips","Emerald")
 D GROUP(.TCTX,3,"Escalation watch","Supervising high-risk accounts","Amber")
 D USER(.TCTX,"bubble",1,"Maya Chen","MC","Lead collector","Billing follow-up","online","Reviewing AR > 30",12,"sky")
 D USER(.TCTX,"bubble",2,"Jordan Reyes","JR","Eligibility analyst","Eligibility desk","busy","Posting real-time eligibility notes",7,"amber")
 D USER(.TCTX,"bubble",3,"Nina Patel","NP","Denials RN","Medical necessity appeals","away","Will return in 9 minutes",3,"violet")
 D USER(.TCTX,"bubble",4,"Owen Brooks","OB","Supervisor","High balance review","offline","Shift ended 17 minutes ago",0,"slate")
 D ROW(.TCTX,1,"Maya Chen","MC","Follow-up swarm","12 unread","Escalation watch","Busy","/mioui/collab-users")
 D ROW(.TCTX,2,"Jordan Reyes","JR","Eligibility pod","7 unread","Eligibility refresh","Online","/mioui/collab-users#eligibility")
 D ROW(.TCTX,3,"Nina Patel","NP","Appeal queue","3 unread","Needs MD note","Away","/mioui/collab-users#appeals")
 D CARD(.TCTX,1,"Maya Chen","Lead collector","Working claim cluster","Blue Horizon Imaging","AR day 41 · 3 unresolved notes","Currently watching payer drift and callback windows.","online","sky")
 D CARD(.TCTX,2,"Jordan Reyes","Eligibility analyst","Pinned workspace","Tri-State Employer Health","Verifying COB and policy effective dates.","Surface built for fast hover review.","busy","amber")
 D CARD(.TCTX,3,"Nina Patel","Denials RN","Escalation thread","Medical necessity appeal","Requires physician narrative and drug history.","Surface built for compact roster context.","away","violet")
 Q
 ;
BUILDAV(CONF,REQ,CTX,TCTX)
 D BASE(.CONF,.TCTX,"Avatars and identity stacks","Reusable identity treatments for assignee chips, participant stacks, and shared-review rails.","Collaboration / Avatars")
 D TABS(.TCTX,"avatars")
 D HERO(.TCTX,"Avatar variants",11,"Shared review rail",5,"Role chips",9)
 D USER(.TCTX,"stack",1,"Maya Chen","MC","Lead collector","Follow-up swarm","online","Escalation owner",0,"sky")
 D USER(.TCTX,"stack",2,"Jordan Reyes","JR","Eligibility analyst","Eligibility pod","busy","Checking payer matrix",0,"emerald")
 D USER(.TCTX,"stack",3,"Nina Patel","NP","Denials RN","Appeal desk","away","Pending physician callback",0,"violet")
 D USER(.TCTX,"stack",4,"Owen Brooks","OB","Supervisor","Operations bridge","online","Watching team throughput",0,"amber")
 D CHIP(.TCTX,1,"Maya Chen","MC","Primary assignee","Online","sky")
 D CHIP(.TCTX,2,"Jordan Reyes","JR","Coverage verifier","Busy","emerald")
 D CHIP(.TCTX,3,"Nina Patel","NP","Clinical appeal","Away","violet")
 D CHIP(.TCTX,4,"Owen Brooks","OB","Supervisor","Online","amber")
 D MINI(.TCTX,1,"Maya Chen","MC","Lead collector","Handles payer callback windows.","sky")
 D MINI(.TCTX,2,"Dr. Maya Chen","DM","Medical reviewer","Approves medical necessity escalations.","rose")
 D MINI(.TCTX,3,"Jordan Reyes","JR","Eligibility analyst","Monitors COB and member status.","emerald")
 D MINI(.TCTX,4,"Nina Patel","NP","Denials RN","Leads appeal response drafting.","violet")
 D MINI(.TCTX,5,"Owen Brooks","OB","Supervisor","Coordinates shared review coverage.","amber")
 Q
 ;
BUILDUS(CONF,REQ,CTX,TCTX)
 D BASE(.CONF,.TCTX,"Connected users workspace","Dense connected-user panels for workspace rosters, inline staffing context, and operator handoff visibility.","Collaboration / Users")
 D TABS(.TCTX,"users")
 D HERO(.TCTX,"Connected users",18,"Active workspaces",6,"Unread mentions",34)
 D ROSTER(.TCTX,1,"Maya Chen","MC","Denial command","Lead collector","34","2 min ago","78%","online","High balance claims","sky")
 D ROSTER(.TCTX,2,"Jordan Reyes","JR","Claim follow-up","Eligibility analyst","18","now","65%","busy","Eligibility clean-up","emerald")
 D ROSTER(.TCTX,3,"Nina Patel","NP","Batch QA","Denials RN","11","6 min ago","59%","away","Medical necessity batch","violet")
 D ROSTER(.TCTX,4,"Owen Brooks","OB","Supervisor bridge","Supervisor","4","now","83%","online","Team throughput watch","amber")
 D ROSTER(.TCTX,5,"Sara Kim","SK","Payment variance","Contract analyst","7","14 min ago","52%","offline","Variance ladder review","slate")
 D PANEL(.TCTX,1,"Who is viewing this","Maya Chen, Jordan Reyes, and Owen Brooks are watching the same payer cluster right now.","sky")
 D PANEL(.TCTX,2,"Connected users","Use roster rows to expose unread, workload, and current workspace without opening a profile.","emerald")
 D PANEL(.TCTX,3,"Handoff readiness","Assignee chips and status dots are tuned for dense review queues and multi-user rooms.","amber")
 Q
 ;
BUILDCH(CONF,REQ,CTX,TCTX,VARIANT)
 N MODE,TITLE,LEAD,EYEBROW
 S MODE=$$MODE($G(VARIANT))
 S TITLE=$S(MODE="dense":"Dense chat review",MODE="balanced":"Balanced chat workspace",1:"Chat primitives")
 S LEAD=$S(MODE="dense":"Ultra-dense message primitives for rapid queue reading, escalation triage, and minimal pointer travel.",MODE="balanced":"A middle path between scan speed and comfortable thread reading for shared review rooms.",1:"Incoming, outgoing, system, and threaded message components for SSR-first operator collaboration.")
 S EYEBROW=$S(MODE="dense":"Collaboration / Chat Dense",MODE="balanced":"Collaboration / Chat Balanced",1:"Collaboration / Chat")
 D BASE(.CONF,.TCTX,TITLE,LEAD,EYEBROW)
 D TABS(.TCTX,$S(MODE="dense":"chatDense",MODE="balanced":"chatBalanced",1:"chat"))
 D HERO(.TCTX,$S(MODE="dense":"Visible messages",MODE="balanced":"Shared participants",1:"Active thread"),$S(MODE="dense":9,MODE="balanced":4,1:1),$S(MODE="dense":"Unread markers",MODE="balanced":"Quick actions",1:"Participants"),$S(MODE="dense":1,MODE="balanced":4,1:4),$S(MODE="dense":"Typing signals",MODE="balanced":"Open reply chains",1:"Thread replies"),$S(MODE="dense":1,MODE="balanced":4,1:4))
 S TCTX("chatVariant")=MODE
 S TCTX("chatVariantLabel")=$S(MODE="dense":"Dense",MODE="balanced":"Balanced",1:"Standard")
 S TCTX("chatHeader","title")="Blue Horizon Imaging denial coordination"
 S TCTX("chatHeader","subtitle")="Care coordination · Payer callback room"
 S TCTX("chatHeader","queue")="Escalation watch"
 S TCTX("chatHeader","status")="4 active participants"
 S TCTX("chatHeader","badgeClass")=$$BADGE^MIOUITHEME("sky")
 S TCTX("chatHeader","helper")="Built to reuse the same message model across normal, dense, and balanced chat variants."
 D PUSER(.TCTX,1,"Maya Chen","MC","Lead collector","online","sky")
 D PUSER(.TCTX,2,"Jordan Reyes","JR","Eligibility analyst","busy","emerald")
 D PUSER(.TCTX,3,"Nina Patel","NP","Denials RN","away","violet")
 D PUSER(.TCTX,4,"Owen Brooks","OB","Supervisor","online","amber")
 D ITEMDATE(.TCTX,1,"Today")
 D ITEMIN(.TCTX,2,"Maya Chen","MC","Lead collector","9:10 AM","I pushed the Blue Horizon appeal bundle into the payer callback room and attached the latest eligibility summary.","Reply preview","Yesterday · Sara Kim · Confirm whether the secondary plan terminated on March 1.","Quoted message","Need payer callback before 3:00 PM so the authorization window does not roll.","Eligibility summary PDF","PDF · 4 pages · Updated 9:06 AM","4 replies","Focus the callback on COB and medical necessity.","sky")
 D REACT(.TCTX,2,1,"👀 3")
 D REACT(.TCTX,2,2,"✅ 2")
 D ITEMOUT(.TCTX,3,"Jordan Reyes","JR","Eligibility analyst","9:14 AM","I verified the member still has active commercial coverage. The termination date in the previous remit was stale.","Internal note","Care coordination","Delivered to 3 participants","Edited","I also added the policy effective date and subscriber relationship into the attachment note.","emerald")
 D REACT(.TCTX,3,1,"👍 2")
 D REACT(.TCTX,3,2,"📎 1")
 D ITEMSYS(.TCTX,4,"System event","Owen Brooks moved the conversation to Escalation watch and pinned the callback checklist.","amber")
 D ITEMUNR(.TCTX,5,"3 unread messages")
 D ITEMIN(.TCTX,6,"Nina Patel","NP","Denials RN","9:22 AM","I can draft the clinical summary after the callback. Tag me once the payer confirms the prior-authorization logic.","Reply preview","Thread · Maya Chen · Keep the narrative short enough for portal upload.","Quoted message","Prior denial cited medical necessity and missing supporting documentation.","Clinical summary outline","DOCX · 2 sections · Draft ready","2 replies","Care coordination","violet")
 D REACT(.TCTX,6,1,"🩺 1")
 D ITEMOUT(.TCTX,7,"Maya Chen","MC","Lead collector","9:24 AM","Perfect. I will call now and update this thread with the payer reference number as soon as I have it.","Outgoing update","Callback owner","Read by Owen Brooks","","","sky")
 D ITEMTYP(.TCTX,8,"Jordan Reyes is typing…")
 D SIDE(.TCTX,1,"Thread summary","4 replies","Medical necessity appeal · eligibility refresh · callback checklist pinned.","sky")
 D SIDE(.TCTX,2,"Read state","Read by Owen Brooks","Delivered to 3 participants · last read 9:24 AM.","emerald")
 D SIDE(.TCTX,3,"Inline actions","Internal note · mention · reply preview","Actions stay visible without forcing a second toolbar.","amber")
 D ACTN(.TCTX,1,"Mention")
 D ACTN(.TCTX,2,"Attach")
 D ACTN(.TCTX,3,"Internal note")
 D ACTN(.TCTX,4,"Send update")
 S TCTX("composer","placeholder")="Write a follow-up, internal note, or payer callback update"
 S TCTX("composer","helper")="Message composer"
 S TCTX("composer","secondary")="Composer actions are modeled in the server context for SSR-first rendering."
 Q
 ;

BUILDON(CONF,REQ,CTX,TCTX,VARIANT)
 N MODE,TITLE,LEAD,EYEBROW
 S MODE=$$ONMODE($G(VARIANT))
 S TITLE=$S(MODE="dense":"Dense onboarding review",MODE="guided":"Guided onboarding launch",1:"Onboarding workspace")
 S LEAD=$S(MODE="dense":"Compact onboarding surfaces for dense workspace setup, role mapping, defaults, and first-run launch decisions.",MODE="guided":"A guided onboarding path that mixes step context, invite preview, and launch controls for first-run adoption.",1:"Reusable onboarding surfaces for workspace launch, team invite preview, channel defaults, and first-message setup.")
 S EYEBROW=$S(MODE="dense":"Collaboration / Onboarding Dense",MODE="guided":"Collaboration / Onboarding Guided",1:"Collaboration / Onboarding")
 D BASE(.CONF,.TCTX,TITLE,LEAD,EYEBROW)
 D TABS(.TCTX,$S(MODE="dense":"onboardingDense",MODE="guided":"onboardingGuided",1:"onboarding"))
 D HERO(.TCTX,$S(MODE="dense":"Launch blocks",MODE="guided":"Guided moments",1:"Setup blocks"),$S(MODE="dense":9,MODE="guided":6,1:6),$S(MODE="dense":"Invite seats",MODE="guided":"Preview rails",1:"Invite seats"),$S(MODE="dense":4,MODE="guided":3,1:4),$S(MODE="dense":"Default rooms",MODE="guided":"First actions",1:"Default rooms"),$S(MODE="dense":3,MODE="guided":4,1:3))
 S TCTX("onboardVariant")=MODE
 S TCTX("onboardVariantLabel")=$S(MODE="dense":"Dense",MODE="guided":"Guided",1:"Standard")
 D ONBINIT^MIOUIWF(.TCTX,"launch",TITLE,"Shape a shared workspace, preload roles, and launch collaboration without leaving the SSR shell.","Launch workspace","/mioui/collab-chat","Review connected users","/mioui/collab-users")
 D ONBSTEP^MIOUIWF(.TCTX,"launch",1,"Identity and team","Select the working group, coverage style, and default assignee visibility.","complete")
 D ONBSTEP^MIOUIWF(.TCTX,"launch",2,"Invite and presence","Preview connected users, seat assignments, and who appears online from day one.","current")
 D ONBSTEP^MIOUIWF(.TCTX,"launch",3,"Rooms and watchlists","Choose default rooms, escalation lanes, and read-state behavior for the team.",$S(MODE="guided":"current",MODE="dense":"warning",1:"warning"))
 D ONBSTEP^MIOUIWF(.TCTX,"launch",4,"Starter message and launch","Seed the welcome thread, routing hints, and launch actions for the workspace.","queued")
 D ONBFINAL^MIOUIWF(.TCTX,"launch")
 D STAGE(.TCTX,1,"Workspace goal","Denial coordination room","4 live participants","Presence-first launch with message read states and connected user preview.","sky")
 D STAGE(.TCTX,2,"Team structure","2 collectors · 1 analyst · 1 supervisor","Role map ready","Assignee chips and roster rows stay consistent across the onboarding family.","emerald")
 D STAGE(.TCTX,3,"Default rooms","Eligibility refresh · appeal desk · escalation watch","3 rooms","Each onboarding variant surfaces room defaults at a different density.","violet")
 D STAGE(.TCTX,4,"Starter welcome note","Pinned callback checklist and escalation owner","1 pinned note","Warm-start the workspace with a message shell and explicit next actions.","amber")
 D INVITE(.TCTX,1,"Maya Chen","MC","Lead collector","Seat assigned","Primary owner for the first denial lane.","online","sky")
 D INVITE(.TCTX,2,"Jordan Reyes","JR","Eligibility analyst","Seat assigned","Owns COB refresh and policy checks.","busy","emerald")
 D INVITE(.TCTX,3,"Nina Patel","NP","Denials RN","Invite pending","Reviews medical necessity responses.","away","violet")
 D INVITE(.TCTX,4,"Owen Brooks","OB","Supervisor","Shadow mode","Receives escalation watch updates.","online","amber")
 D CL(.TCTX,1,"Verify workspace name and role mix","Maya Chen","Now","Ready","emerald")
 D CL(.TCTX,2,"Confirm default rooms and watchlists","Jordan Reyes","Today","In progress","sky")
 D CL(.TCTX,3,"Seed starter welcome note","Nina Patel","Today","Queued","amber")
 D CL(.TCTX,4,"Review launch actions and connected roster","Owen Brooks","Before launch","Queued","slate")
 D ROOM(.TCTX,1,"Eligibility refresh","Coverage changes and COB questions","3 watchers","emerald")
 D ROOM(.TCTX,2,"Appeal desk","Clinical appeals and medical necessity notes","2 watchers","violet")
 D ROOM(.TCTX,3,"Escalation watch","Supervisor follow-up and risk handoff","4 watchers","amber")
 S TCTX("launchPanel","title")="Launch and defaults"
 S TCTX("launchPanel","lead")="Starter welcome note"
 S TCTX("launchPanel","body")="Use launch actions to pin a first message, expose connected users, and turn on read-state visibility from the first session."
 S TCTX("launchPanel","tip")="Connected users preview"
 S TCTX("launchPanel","tipBody")="The onboarding family reuses the same avatar, bubble, and roster primitives from ROI 1."
 S TCTX("launchPanel","primaryLabel")="Launch workspace"
 S TCTX("launchPanel","primaryHref")="/mioui/collab-chat"
 S TCTX("launchPanel","secondaryLabel")="Open connected users"
 S TCTX("launchPanel","secondaryHref")="/mioui/collab-users"
 D LACT(.TCTX,1,"Presence and read states","Show participant stack and read badges in the first thread.","sky")
 D LACT(.TCTX,2,"Default rooms","Create three starter rooms and one escalation watch lane.","violet")
 D LACT(.TCTX,3,"Warm welcome note","Seed the first pinned update with callback guidance.","emerald")
 D LACT(.TCTX,4,"Connected roster","Expose who is viewing this from the moment launch completes.","amber")
 D USER(.TCTX,"bubble",1,"Maya Chen","MC","Lead collector","Denial coordination room","online","Assigned as primary owner",6,"sky")
 D USER(.TCTX,"bubble",2,"Jordan Reyes","JR","Eligibility analyst","Eligibility refresh","busy","Watching default room coverage",3,"emerald")
 D USER(.TCTX,"bubble",3,"Owen Brooks","OB","Supervisor","Escalation watch","online","Reviewing launch actions",1,"amber")
 D ROW(.TCTX,1,"Maya Chen","MC","Denial coordination room","6 unread","Primary owner online","Online","/mioui/collab-users")
 D ROW(.TCTX,2,"Jordan Reyes","JR","Eligibility refresh","3 unread","Coverage checks active","Busy","/mioui/collab-users#eligibility")
 D ROW(.TCTX,3,"Owen Brooks","OB","Escalation watch","1 unread","Supervisor shadow mode","Online","/mioui/collab-users#supervisor")
 Q
 ;

BASE(CONF,TCTX,TITLE,LEAD,EYEBROW)
 D BASE^MIOUICTX(.TCTX)
 D APPLY^MIOUITHEME(.CONF,.TCTX)
 D ACT^MIOUICTX(.TCTX,"collaboration")
 D PAGE^MIOUICTX(.TCTX,"MIOUI / "_$G(TITLE),$G(TITLE),$G(LEAD),$G(EYEBROW))
 S TCTX("heroKicker")="Reusable collaboration primitives"
 Q
 ;
TABS(TCTX,ACTIVE)
 S TCTX("collabTab",1,"label")="Presence"
 S TCTX("collabTab",1,"href")="/mioui/collab-presence"
 S TCTX("collabTab",1,"isActive")=$S($G(ACTIVE)="presence":1,1:0)
 S TCTX("collabTab",2,"label")="Avatars"
 S TCTX("collabTab",2,"href")="/mioui/collab-avatars"
 S TCTX("collabTab",2,"isActive")=$S($G(ACTIVE)="avatars":1,1:0)
 S TCTX("collabTab",3,"label")="Connected users"
 S TCTX("collabTab",3,"href")="/mioui/collab-users"
 S TCTX("collabTab",3,"isActive")=$S($G(ACTIVE)="users":1,1:0)
 S TCTX("collabTab",4,"label")="Chat"
 S TCTX("collabTab",4,"href")="/mioui/collab-chat"
 S TCTX("collabTab",4,"isActive")=$S($G(ACTIVE)="chat":1,1:0)
 S TCTX("collabTab",5,"label")="Chat dense"
 S TCTX("collabTab",5,"href")="/mioui/collab-chat-dense"
 S TCTX("collabTab",5,"isActive")=$S($G(ACTIVE)="chatDense":1,1:0)
 S TCTX("collabTab",6,"label")="Chat balanced"
 S TCTX("collabTab",6,"href")="/mioui/collab-chat-balanced"
 S TCTX("collabTab",6,"isActive")=$S($G(ACTIVE)="chatBalanced":1,1:0)
 S TCTX("collabTab",7,"label")="Onboarding"
 S TCTX("collabTab",7,"href")="/mioui/collab-onboarding"
 S TCTX("collabTab",7,"isActive")=$S($G(ACTIVE)="onboarding":1,1:0)
 S TCTX("collabTab",8,"label")="Onboarding dense"
 S TCTX("collabTab",8,"href")="/mioui/collab-onboarding-dense"
 S TCTX("collabTab",8,"isActive")=$S($G(ACTIVE)="onboardingDense":1,1:0)
 S TCTX("collabTab",9,"label")="Onboarding guided"
 S TCTX("collabTab",9,"href")="/mioui/collab-onboarding-guided"
 S TCTX("collabTab",9,"isActive")=$S($G(ACTIVE)="onboardingGuided":1,1:0)
 Q
 ;
HERO(TCTX,L1,V1,L2,V2,L3,V3)
 S TCTX("heroStat",1,"label")=$G(L1)
 S TCTX("heroStat",1,"value")=$G(V1)
 S TCTX("heroStat",2,"label")=$G(L2)
 S TCTX("heroStat",2,"value")=$G(V2)
 S TCTX("heroStat",3,"label")=$G(L3)
 S TCTX("heroStat",3,"value")=$G(V3)
 Q
 ;
GROUP(TCTX,IDX,LABEL,DETAIL,TONE)
 S TCTX("presenceGroup",IDX,"label")=$G(LABEL)
 S TCTX("presenceGroup",IDX,"detail")=$G(DETAIL)
 S TCTX("presenceGroup",IDX,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 Q
 ;
USER(TCTX,ROOT,IDX,NAME,INITIALS,ROLE,WORKSPACE,STATE,DETAIL,UNREAD,TONE)
 S TCTX(ROOT,IDX,"name")=$G(NAME)
 S TCTX(ROOT,IDX,"initials")=$G(INITIALS)
 S TCTX(ROOT,IDX,"role")=$G(ROLE)
 S TCTX(ROOT,IDX,"workspace")=$G(WORKSPACE)
 S TCTX(ROOT,IDX,"state")=$$UP($G(STATE))
 S TCTX(ROOT,IDX,"detail")=$G(DETAIL)
 S TCTX(ROOT,IDX,"unread")=+$G(UNREAD)
 S TCTX(ROOT,IDX,"avatarClass")=$$AVCLS($G(TONE))
 S TCTX(ROOT,IDX,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX(ROOT,IDX,"stateClass")=$$STATECLS($G(STATE))
 Q
 ;
ROW(TCTX,IDX,NAME,INITIALS,WORKSPACE,UNREAD,NOTE,STATE,HREF)
 S TCTX("connected",IDX,"name")=$G(NAME)
 S TCTX("connected",IDX,"initials")=$G(INITIALS)
 S TCTX("connected",IDX,"workspace")=$G(WORKSPACE)
 S TCTX("connected",IDX,"unreadLabel")=$G(UNREAD)
 S TCTX("connected",IDX,"note")=$G(NOTE)
 S TCTX("connected",IDX,"state")=$G(STATE)
 S TCTX("connected",IDX,"href")=$G(HREF)
 S TCTX("connected",IDX,"stateClass")=$$STATECLS($G(STATE))
 S TCTX("connected",IDX,"avatarClass")=$$AVCLS($S($G(STATE)="Busy":"amber",$G(STATE)="Away":"violet",$G(STATE)="Offline":"slate",1:"sky"))
 Q
 ;
CARD(TCTX,IDX,NAME,ROLE,TITLE,SUBJECT,DETAIL,HELP,STATE,TONE)
 S TCTX("detailCard",IDX,"name")=$G(NAME)
 S TCTX("detailCard",IDX,"role")=$G(ROLE)
 S TCTX("detailCard",IDX,"title")=$G(TITLE)
 S TCTX("detailCard",IDX,"subject")=$G(SUBJECT)
 S TCTX("detailCard",IDX,"detail")=$G(DETAIL)
 S TCTX("detailCard",IDX,"help")=$G(HELP)
 S TCTX("detailCard",IDX,"state")=$$UP($G(STATE))
 S TCTX("detailCard",IDX,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("detailCard",IDX,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
CHIP(TCTX,IDX,NAME,INITIALS,ROLE,STATE,TONE)
 S TCTX("chip",IDX,"name")=$G(NAME)
 S TCTX("chip",IDX,"initials")=$G(INITIALS)
 S TCTX("chip",IDX,"role")=$G(ROLE)
 S TCTX("chip",IDX,"state")=$G(STATE)
 S TCTX("chip",IDX,"avatarClass")=$$AVCLS($G(TONE))
 S TCTX("chip",IDX,"stateClass")=$$STATECLS($G(STATE))
 Q
 ;
MINI(TCTX,IDX,NAME,INITIALS,ROLE,DETAIL,TONE)
 S TCTX("miniUser",IDX,"name")=$G(NAME)
 S TCTX("miniUser",IDX,"initials")=$G(INITIALS)
 S TCTX("miniUser",IDX,"role")=$G(ROLE)
 S TCTX("miniUser",IDX,"detail")=$G(DETAIL)
 S TCTX("miniUser",IDX,"avatarClass")=$$AVCLS($G(TONE))
 Q
 ;
ROSTER(TCTX,IDX,NAME,INITIALS,WORKSPACE,ROLE,UNREAD,LAST,LOAD,STATE,FOCUS,TONE)
 S TCTX("roster",IDX,"name")=$G(NAME)
 S TCTX("roster",IDX,"initials")=$G(INITIALS)
 S TCTX("roster",IDX,"workspace")=$G(WORKSPACE)
 S TCTX("roster",IDX,"role")=$G(ROLE)
 S TCTX("roster",IDX,"unread")=$G(UNREAD)
 S TCTX("roster",IDX,"lastActive")=$G(LAST)
 S TCTX("roster",IDX,"load")=$G(LOAD)
 S TCTX("roster",IDX,"state")=$$UP($G(STATE))
 S TCTX("roster",IDX,"focus")=$G(FOCUS)
 S TCTX("roster",IDX,"avatarClass")=$$AVCLS($G(TONE))
 S TCTX("roster",IDX,"stateClass")=$$STATECLS($G(STATE))
 Q
 ;
PANEL(TCTX,IDX,TITLE,BODY,TONE)
 S TCTX("infoPanel",IDX,"title")=$G(TITLE)
 S TCTX("infoPanel",IDX,"body")=$G(BODY)
 S TCTX("infoPanel",IDX,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
PUSER(TCTX,IDX,NAME,INITIALS,ROLE,STATE,TONE)
 S TCTX("participant",IDX,"name")=$G(NAME)
 S TCTX("participant",IDX,"initials")=$G(INITIALS)
 S TCTX("participant",IDX,"role")=$G(ROLE)
 S TCTX("participant",IDX,"state")=$$UP($G(STATE))
 S TCTX("participant",IDX,"avatarClass")=$$AVCLS($G(TONE))
 S TCTX("participant",IDX,"stateClass")=$$STATECLS($G(STATE))
 Q
 ;
ITEMDATE(TCTX,IDX,LABEL)
 S TCTX("chatItem",IDX,"isDateSeparator")=1
 S TCTX("chatItem",IDX,"label")=$G(LABEL)
 Q
 ;
ITEMUNR(TCTX,IDX,LABEL)
 S TCTX("chatItem",IDX,"isUnreadSeparator")=1
 S TCTX("chatItem",IDX,"label")=$G(LABEL)
 Q
 ;
ITEMSYS(TCTX,IDX,TITLE,DETAIL,TONE)
 S TCTX("chatItem",IDX,"isSystemEvent")=1
 S TCTX("chatItem",IDX,"title")=$G(TITLE)
 S TCTX("chatItem",IDX,"detail")=$G(DETAIL)
 S TCTX("chatItem",IDX,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 Q
 ;
ITEMIN(TCTX,IDX,SENDER,INITIALS,ROLE,STAMP,BODY,RLABEL,RTEXT,QLABEL,QTEXT,ANAME,AMETA,TLABEL,MENTION,TONE)
 S TCTX("chatItem",IDX,"isIncoming")=1
 D MSG(.TCTX,IDX,.SENDER,.INITIALS,.ROLE,.STAMP,.BODY,.RLABEL,.RTEXT,.QLABEL,.QTEXT,.ANAME,.AMETA,.TLABEL,.MENTION,.TONE)
 Q
 ;
ITEMOUT(TCTX,IDX,SENDER,INITIALS,ROLE,STAMP,BODY,RLABEL,RTEXT,DSTATE,EDITLBL,EXTRA,TONE)
 S TCTX("chatItem",IDX,"isOutgoing")=1
 S TCTX("chatItem",IDX,"sender")=$G(SENDER)
 S TCTX("chatItem",IDX,"initials")=$G(INITIALS)
 S TCTX("chatItem",IDX,"role")=$G(ROLE)
 S TCTX("chatItem",IDX,"stamp")=$G(STAMP)
 S TCTX("chatItem",IDX,"body")=$G(BODY)
 S TCTX("chatItem",IDX,"avatarClass")=$$AVCLS($G(TONE))
 S TCTX("chatItem",IDX,"bubbleClass")="bg-sky-500/10 ring-1 ring-sky-400/25"
 I $G(RLABEL)'="" S TCTX("chatItem",IDX,"hasReply")=1,TCTX("chatItem",IDX,"replyLabel")=$G(RLABEL),TCTX("chatItem",IDX,"replyText")=$G(RTEXT)
 I $G(DSTATE)'="" S TCTX("chatItem",IDX,"deliveryState")=$G(DSTATE)
 I $G(EDITLBL)'="" S TCTX("chatItem",IDX,"editedLabel")=$G(EDITLBL)
 I $G(EXTRA)'="" S TCTX("chatItem",IDX,"extraBody")=$G(EXTRA)
 Q
 ;
ITEMTYP(TCTX,IDX,LABEL)
 S TCTX("chatItem",IDX,"isTyping")=1
 S TCTX("chatItem",IDX,"label")=$G(LABEL)
 Q
 ;
MSG(TCTX,IDX,SENDER,INITIALS,ROLE,STAMP,BODY,RLABEL,RTEXT,QLABEL,QTEXT,ANAME,AMETA,TLABEL,MENTION,TONE)
 S TCTX("chatItem",IDX,"sender")=$G(SENDER)
 S TCTX("chatItem",IDX,"initials")=$G(INITIALS)
 S TCTX("chatItem",IDX,"role")=$G(ROLE)
 S TCTX("chatItem",IDX,"stamp")=$G(STAMP)
 S TCTX("chatItem",IDX,"body")=$G(BODY)
 S TCTX("chatItem",IDX,"avatarClass")=$$AVCLS($G(TONE))
 S TCTX("chatItem",IDX,"bubbleClass")="panel-soft"
 I $G(RLABEL)'="" S TCTX("chatItem",IDX,"hasReply")=1,TCTX("chatItem",IDX,"replyLabel")=$G(RLABEL),TCTX("chatItem",IDX,"replyText")=$G(RTEXT)
 I $G(QLABEL)'="" S TCTX("chatItem",IDX,"hasQuote")=1,TCTX("chatItem",IDX,"quoteLabel")=$G(QLABEL),TCTX("chatItem",IDX,"quoteText")=$G(QTEXT)
 I $G(ANAME)'="" S TCTX("chatItem",IDX,"hasAttachment")=1,TCTX("chatItem",IDX,"attachmentName")=$G(ANAME),TCTX("chatItem",IDX,"attachmentMeta")=$G(AMETA)
 I $G(TLABEL)'="" S TCTX("chatItem",IDX,"hasThread")=1,TCTX("chatItem",IDX,"threadLabel")=$G(TLABEL)
 I $G(MENTION)'="" S TCTX("chatItem",IDX,"mention")=$G(MENTION)
 Q
 ;
REACT(TCTX,IDX,RIDX,LABEL)
 S TCTX("chatItem",IDX,"reaction",RIDX,"label")=$G(LABEL)
 Q
 ;
SIDE(TCTX,IDX,TITLE,LABEL,DETAIL,TONE)
 S TCTX("chatSide",IDX,"title")=$G(TITLE)
 S TCTX("chatSide",IDX,"label")=$G(LABEL)
 S TCTX("chatSide",IDX,"detail")=$G(DETAIL)
 S TCTX("chatSide",IDX,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("chatSide",IDX,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
ACTN(TCTX,IDX,LABEL)
 S TCTX("composerAction",IDX,"label")=$G(LABEL)
 Q
 ;

STAGE(TCTX,IDX,TITLE,LABEL,METRIC,DETAIL,TONE)
 S TCTX("stageCard",IDX,"title")=$G(TITLE)
 S TCTX("stageCard",IDX,"label")=$G(LABEL)
 S TCTX("stageCard",IDX,"metric")=$G(METRIC)
 S TCTX("stageCard",IDX,"detail")=$G(DETAIL)
 S TCTX("stageCard",IDX,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("stageCard",IDX,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
INVITE(TCTX,IDX,NAME,INITIALS,ROLE,SEAT,DETAIL,STATE,TONE)
 S TCTX("inviteMember",IDX,"name")=$G(NAME)
 S TCTX("inviteMember",IDX,"initials")=$G(INITIALS)
 S TCTX("inviteMember",IDX,"role")=$G(ROLE)
 S TCTX("inviteMember",IDX,"seat")=$G(SEAT)
 S TCTX("inviteMember",IDX,"detail")=$G(DETAIL)
 S TCTX("inviteMember",IDX,"state")=$$UP($G(STATE))
 S TCTX("inviteMember",IDX,"avatarClass")=$$AVCLS($G(TONE))
 S TCTX("inviteMember",IDX,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("inviteMember",IDX,"stateClass")=$$STATECLS($G(STATE))
 Q
 ;
CL(TCTX,IDX,LABEL,OWNER,DUE,STATE,TONE)
 S TCTX("checkItem",IDX,"label")=$G(LABEL)
 S TCTX("checkItem",IDX,"owner")=$G(OWNER)
 S TCTX("checkItem",IDX,"due")=$G(DUE)
 S TCTX("checkItem",IDX,"state")=$G(STATE)
 S TCTX("checkItem",IDX,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 Q
 ;
ROOM(TCTX,IDX,LABEL,DETAIL,META,TONE)
 S TCTX("defaultRoom",IDX,"label")=$G(LABEL)
 S TCTX("defaultRoom",IDX,"detail")=$G(DETAIL)
 S TCTX("defaultRoom",IDX,"meta")=$G(META)
 S TCTX("defaultRoom",IDX,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("defaultRoom",IDX,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
LACT(TCTX,IDX,LABEL,DETAIL,TONE)
 S TCTX("launchChoice",IDX,"label")=$G(LABEL)
 S TCTX("launchChoice",IDX,"detail")=$G(DETAIL)
 S TCTX("launchChoice",IDX,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 Q
 ;
ONMODE(X)
 N Y
 S Y=$ZCONVERT($G(X),"L")
 I Y="dense"!(Y="guided") Q Y
 Q "standard"
 ;

MODE(X)
 N Y
 S Y=$ZCONVERT($G(X),"L")
 I Y="dense"!(Y="balanced") Q Y
 Q "standard"
 ;
AVCLS(TONE)
 N X
 S X=$$TONE^MIOUITHEME($G(TONE))
 I X="neutral" S X="slate"
 Q "bg-"_X_"-500/20 text-white ring-1 ring-"_X_"-400/30"
 ;
STATECLS(STATE)
 N X
 S X=$ZCONVERT($G(STATE),"L")
 I X="busy" Q "bg-amber-400"
 I X="away" Q "bg-violet-400"
 I X="offline" Q "bg-slate-400"
 Q "bg-emerald-400"
 ;
UP(X)
 N Y
 S Y=$ZCONVERT($G(X),"L")
 I Y="" Q ""
 Q $ZCONVERT($E(Y),"U")_$E(Y,2,$L(Y))
 ;
