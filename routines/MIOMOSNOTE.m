MIOMOSNOTE ; MIOMOS shell notification helpers
	QUIT
	;
META(STATE,CONF,OUT)
	NEW CNT,TERM,N,MAX
	KILL OUT
	SET OUT("headline")="Notification Center"
	SET OUT("subheadline")="Server-authored shell notices for collaboration, terminal sessions, and account posture."
	SET MAX=+$$PREVIEW($GET(STATE("shell","notificationPreviewCount"),$GET(CONF("miomos","settings","shell","notificationPreviewCount"),4)))
	IF MAX<1 SET MAX=4
	DO COUNTS^MIOMOSADMIN(.CNT)
	DO LIST^MIOMOSPERM(.STATE,.TERM)
	SET N=0
	IF $$HAS^MIOMOSPERM(.STATE,"chat.use") DO
	. SET N=N+1
	. SET OUT("items",N,"key")="collaboration"
	. SET OUT("items",N,"tone")="info"
	. SET OUT("items",N,"icon")="CHT"
	. SET OUT("items",N,"title")="Collaboration ready"
	. SET OUT("items",N,"copy")="Room "_$GET(STATE("shell","chatRoom"),$GET(STATE("chatRoom"),"general"))_" is available for live operator coordination."
	. SET OUT("items",N,"action")="launch:collaboration"
	. SET OUT("items",N,"count")=0
	IF $$HAS^MIOMOSPERM(.STATE,"terminal.use") DO
	. NEW TC SET TC=$$COUNT(.TERM)
	. SET N=N+1
	. SET OUT("items",N,"key")="terminal"
	. SET OUT("items",N,"tone")=$SELECT(TC>0:"ok",1:"info")
	. SET OUT("items",N,"icon")="YDB"
	. SET OUT("items",N,"title")=$SELECT(TC>0:"Terminal sessions active",1:"Terminal ready")
	. SET OUT("items",N,"copy")=$SELECT(TC>0:TC_" active terminal session"_$SELECT(TC=1:"",1:"s")_" available from the taskbar.",1:"Launch a new YottaDB terminal window from Start or Quick Launch.")
	. SET OUT("items",N,"action")="launch:terminal"
	. SET OUT("items",N,"count")=TC
	IF $$HAS^MIOMOSPERM(.STATE,"admin.users.view") DO
	. IF +$GET(CNT("locked"))>0 DO
	. . SET N=N+1
	. . SET OUT("items",N,"key")="locked-users"
	. . SET OUT("items",N,"tone")="warn"
	. . SET OUT("items",N,"icon")="SEC"
	. . SET OUT("items",N,"title")="Locked user accounts"
	. . SET OUT("items",N,"copy")=+$GET(CNT("locked"))_" account"_$SELECT(+$GET(CNT("locked"))=1:" is",1:"s are")_" currently locked and may need review."
	. . SET OUT("items",N,"action")="launch:admin"
	. . SET OUT("items",N,"count")=+$GET(CNT("locked"))
	. IF +$GET(CNT("invites"))>0!(+$GET(CNT("resets"))>0) DO
	. . SET N=N+1
	. . SET OUT("items",N,"key")="workflow"
	. . SET OUT("items",N,"tone")="info"
	. . SET OUT("items",N,"icon")="ADM"
	. . SET OUT("items",N,"title")="Pending access workflow"
	. . SET OUT("items",N,"copy")=+$GET(CNT("invites"))_" invite"_$SELECT(+$GET(CNT("invites"))=1:"",1:"s")_" and "_+$GET(CNT("resets"))_" reset"_$SELECT(+$GET(CNT("resets"))=1:"",1:"s")_" remain open."
	. . SET OUT("items",N,"action")="launch:admin"
	. . SET OUT("items",N,"count")=(+$GET(CNT("invites"))+$GET(CNT("resets")))
	. IF $$GUESTLOGIN^MIOMOSADMIN(.CONF) DO
	. . SET N=N+1
	. . SET OUT("items",N,"key")="guest-login"
	. . SET OUT("items",N,"tone")="warn"
	. . SET OUT("items",N,"icon")="GST"
	. . SET OUT("items",N,"title")="Guest quick login enabled"
	. . SET OUT("items",N,"copy")="Guest access is enabled for this environment. Review the access posture before production handoff."
	. . SET OUT("items",N,"action")="launch:admin"
	. . SET OUT("items",N,"count")=1
	IF N=0 DO
	. SET N=1
	. SET OUT("items",1,"key")="all-clear"
	. SET OUT("items",1,"tone")="ok"
	. SET OUT("items",1,"icon")="OK"
	. SET OUT("items",1,"title")="No active shell alerts"
	. SET OUT("items",1,"copy")="Desktop collaboration, terminal access, and account posture are currently clear."
	. SET OUT("items",1,"action")="launch:workspace"
	. SET OUT("items",1,"count")=0
	SET OUT("total")=N
	SET OUT("badge")=$$BADGE(.OUT)
	IF MAX<N SET OUT("hasMore")=1
	SET OUT("previewCount")=MAX
	QUIT
	;
COUNT(ARR)
	NEW N,C SET (N,C)=0
	FOR  SET N=$ORDER(ARR(N)) QUIT:N=""  SET C=C+1
	QUIT C
	;
BADGE(OUT)
	NEW N,C SET (N,C)=0
	FOR  SET N=$ORDER(OUT("items",N)) QUIT:N=""  DO
	. SET C=C+$GET(OUT("items",N,"count"))
	IF C<1 SET C=+$GET(OUT("total"))
	QUIT C
	;
PREVIEW(N)
	SET N=+N
	IF N<1 SET N=4
	IF N>8 SET N=8
	QUIT N
	;