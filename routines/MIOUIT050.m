MIOUIT050 ; collaboration chat primitives ROI tests
	Q
	;
START(FAIL)
	N LOCAL
	S LOCAL=0
	D T010(.LOCAL)
	I 'LOCAL W !,"OK - MIOUIT050"
	I $G(FAIL) S FAIL=FAIL+LOCAL Q
	I LOCAL S FAIL=1
	Q
	;
T010(FAIL)
	N CONF,REQ,CTX,TCTX,OUT,ERR
	D BUILDCOLLAB^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_collaboration.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) W !,"FAIL: [T010][render]" S FAIL=1 Q
	D HAS(.FAIL,"[T010][conversation section]",OUT,"Conversation list and transcript variants")
	D HAS(.FAIL,"[T010][callback openConversation]",OUT,"openConversation")
	D HAS(.FAIL,"[T010][callback send]",OUT,"sendMessage")
	D HAS(.FAIL,"[T010][callback attach]",OUT,"attachFile")
	D HAS(.FAIL,"[T010][callback reply]",OUT,"replyToMessage")
	D HAS(.FAIL,"[T010][callback react]",OUT,"toggleReaction")
	D HAS(.FAIL,"[T010][callback pin]",OUT,"pinConversation")
	D HAS(.FAIL,"[T010][callback mute]",OUT,"muteConversation")
	D HAS(.FAIL,"[T010][unread]",OUT,"Unread messages")
	D HAS(.FAIL,"[T010][system]",OUT,"System event message")
	D HAS(.FAIL,"[T010][draft]",OUT,"Draft saved")
	D HAS(.FAIL,"[T010][conversation css]",OUT,"conversation-row")
	D HAS(.FAIL,"[T010][incoming css]",OUT,"message-bubble-incoming")
	D HAS(.FAIL,"[T010][reaction css]",OUT,"reaction-chip")
	Q
	;
HAS(FAIL,LABEL,TXT,TOKEN)
	I TXT'[TOKEN W !,"FAIL: ",LABEL,": missing token=",TOKEN S FAIL=1
	Q
