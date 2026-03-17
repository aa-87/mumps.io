MIOUIT043 ; code menu ROI tests
	Q
	;
START(FAIL)
	N LOCAL
	S LOCAL=0
	D T001(.LOCAL)
	D T010(.LOCAL)
	I 'LOCAL W !,"OK - MIOUIT043"
	I $G(FAIL) S FAIL=FAIL+LOCAL Q
	I LOCAL S FAIL=1
	Q
	;
T001(FAIL)
	N CONF,REQ,CTX,TCTX,OUT,ERR
	D BUILDCODE^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_code_menus.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) W !,"FAIL: [T001][render]" S FAIL=1 Q
	D HAS(.FAIL,"[T001][title]",OUT,"Code menu variants")
	D HAS(.FAIL,"[T001][catalog]",OUT,"Master catalog")
	D HAS(.FAIL,"[T001][hierarchy]",OUT,"Hierarchy control")
	D HAS(.FAIL,"[T001][crosswalk]",OUT,"Crosswalk workspace")
	D HAS(.FAIL,"[T001][custom]",OUT,"Custom field studio")
	D HAS(.FAIL,"[T001][audit]",OUT,"Change history")
	D HAS(.FAIL,"[T001][callback add]",OUT,"addCodeRow")
	D HAS(.FAIL,"[T001][callback edit]",OUT,"editSelectedCode")
	D HAS(.FAIL,"[T001][callback delete]",OUT,"deleteSelectedCodes")
	D HAS(.FAIL,"[T001][callback search]",OUT,"searchCodeCatalog")
	D HAS(.FAIL,"[T001][callback order]",OUT,"reorderCodeSet")
	D HAS(.FAIL,"[T001][callback custom]",OUT,"saveCodeCustomFields")
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
