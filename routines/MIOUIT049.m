MIOUIT049 ; collaboration presence ROI tests
	Q
	;
START(FAIL)
	N LOCAL
	S LOCAL=0
	D T001(.LOCAL)
	D T010(.LOCAL)
	I 'LOCAL W !,"OK - MIOUIT049"
	I $G(FAIL) S FAIL=FAIL+LOCAL Q
	I LOCAL S FAIL=1
	Q
	;
T001(FAIL)
	N CONF
	K ^MIO("ROUTE","RAW","GET","/mioui/collaboration")
	D REG^MIOUIDEMO(.CONF)
	D EQ^MIOUIT000(.FAIL,"[T001][route target]",$G(^MIO("ROUTE","RAW","GET","/mioui/collaboration")),"COLLAB^MIOUIDEMO")
	D EQ^MIOUIT000(.FAIL,"[T001][route auth]",+$G(^MIO("ROUTE","META","GET","/mioui/collaboration","authRequired")),0)
	Q
	;
T010(FAIL)
	N CONF,REQ,CTX,TCTX,OUT,ERR
	D BUILDCOLLAB^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_collaboration.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) W !,"FAIL: [T010][render]" S FAIL=1 Q
	D HAS(.FAIL,"[T010][title]",OUT,"Presence, conversation, and workspace variants")
	D HAS(.FAIL,"[T010][connected users]",OUT,"Connected users")
	D HAS(.FAIL,"[T010][participant rows]",OUT,"Active workspace participants")
	D HAS(.FAIL,"[T010][user cards]",OUT,"Rich profile bubbles and cards")
	D HAS(.FAIL,"[T010][callback openUserCard]",OUT,"openUserCard")
	D HAS(.FAIL,"[T010][callback presence]",OUT,"openPresencePanel")
	D HAS(.FAIL,"[T010][callback filter]",OUT,"filterConnectedUsers")
	D HAS(.FAIL,"[T010][callback availability]",OUT,"toggleAvailability")
	D HAS(.FAIL,"[T010][callback group]",OUT,"viewParticipantGroup")
	D HAS(.FAIL,"[T010][css avatar xs]",OUT,"presence-avatar-xs")
	D HAS(.FAIL,"[T010][css ring online]",OUT,"avatar-ring-online")
	D HAS(.FAIL,"[T010][css participant row]",OUT,"participant-row")
	Q
	;
HAS(FAIL,LABEL,TXT,TOKEN)
	I TXT'[TOKEN W !,"FAIL: ",LABEL,": missing token=",TOKEN S FAIL=1
	Q
