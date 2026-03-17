MIOUIT045 ; code menu editor and governance tests
	Q
	;
START(FAIL)
	N LOCAL
	S LOCAL=0
	D T001(.LOCAL)
	D T010(.LOCAL)
	I 'LOCAL W !,"OK - MIOUIT045"
	I $G(FAIL) S FAIL=FAIL+LOCAL Q
	I LOCAL S FAIL=1
	Q
	;
T001(FAIL)
	N CONF,REQ,CTX,TCTX,OUT,ERR
	D BUILDCODE^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_code_menus.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) W !,"FAIL: [T001][render]" S FAIL=1 Q
	D HAS(.FAIL,"[T001][inline]",OUT,"Inline row editor")
	D HAS(.FAIL,"[T001][drawer]",OUT,"Side-drawer editor")
	D HAS(.FAIL,"[T001][compare]",OUT,"Compare and merge review")
	D HAS(.FAIL,"[T001][approval]",OUT,"Approval queue")
	D HAS(.FAIL,"[T001][callback inline open]",OUT,"openInlineCodeEditor")
	D HAS(.FAIL,"[T001][callback inline save]",OUT,"saveInlineCodeRow")
	D HAS(.FAIL,"[T001][callback drawer]",OUT,"openCodeSideDrawer")
	D HAS(.FAIL,"[T001][callback create]",OUT,"createCodeMenuEntry")
	D HAS(.FAIL,"[T001][callback compare]",OUT,"compareIncomingCodeSet")
	D HAS(.FAIL,"[T001][callback merge]",OUT,"mergeSelectedCodeDiffs")
	D HAS(.FAIL,"[T001][callback submit]",OUT,"submitCodeApprovalBatch")
	D HAS(.FAIL,"[T001][callback approve]",OUT,"approveCodeChangeSet")
	D HAS(.FAIL,"[T001][callback reject]",OUT,"rejectCodeChangeSet")
	Q
	;
T010(FAIL)
	N CONF
	K ^MIO("ROUTE","RAW","GET","/mioui/code-menus")
	D REG^MIOUIDEMO(.CONF)
	D EQ^MIOUIT000(.FAIL,"[T010][target]",$G(^MIO("ROUTE","RAW","GET","/mioui/code-menus")),"CODEMENUS^MIOUIDEMO")
	D EQ^MIOUIT000(.FAIL,"[T010][auth]",+$G(^MIO("ROUTE","META","GET","/mioui/code-menus","authRequired")),0)
	Q
	;
HAS(FAIL,LABEL,TXT,TOKEN)
	I TXT'[TOKEN W !,"FAIL: ",LABEL,": missing token=",TOKEN S FAIL=1
	Q
