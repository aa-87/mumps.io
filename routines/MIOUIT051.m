MIOUIT051 ; collaboration workspace and composer ROI tests
	Q
	;
START(FAIL)
	N LOCAL
	S LOCAL=0
	D T010(.LOCAL)
	I 'LOCAL W !,"OK - MIOUIT051"
	I $G(FAIL) S FAIL=FAIL+LOCAL Q
	I LOCAL S FAIL=1
	Q
	;
T010(FAIL)
	N CONF,REQ,CTX,TCTX,OUT,ERR
	D BUILDCOLLAB^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_collaboration.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) W !,"FAIL: [T010][render]" S FAIL=1 Q
	D HAS(.FAIL,"[T010][workspace two pane]",OUT,"Two-pane chat workspace")
	D HAS(.FAIL,"[T010][workspace three pane]",OUT,"Three-pane collaboration workspace")
	D HAS(.FAIL,"[T010][quick reply]",OUT,"Quick reply composer")
	D HAS(.FAIL,"[T010][multiline]",OUT,"Multiline composer")
	D HAS(.FAIL,"[T010][internal note]",OUT,"Internal note toggle")
	D HAS(.FAIL,"[T010][escalation]",OUT,"Escalation composer")
	D HAS(.FAIL,"[T010][context side panel]",OUT,"Context side panel")
	D HAS(.FAIL,"[T010][callback quick]",OUT,"sendQuickReply")
	D HAS(.FAIL,"[T010][callback internal]",OUT,"sendInternalNote")
	D HAS(.FAIL,"[T010][callback snippet]",OUT,"insertMessageTemplate")
	D HAS(.FAIL,"[T010][callback context]",OUT,"openContextPanel")
	D HAS(.FAIL,"[T010][callback escalation]",OUT,"openEscalationThread")
	D HAS(.FAIL,"[T010][callback visibility]",OUT,"toggleSharedVisibility")
	D HAS(.FAIL,"[T010][composer input css]",OUT,"composer-input")
	D HAS(.FAIL,"[T010][workspace pane css]",OUT,"workspace-pane")
	Q
	;
HAS(FAIL,LABEL,TXT,TOKEN)
	I TXT'[TOKEN W !,"FAIL: ",LABEL,": missing token=",TOKEN S FAIL=1
	Q
