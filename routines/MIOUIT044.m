MIOUIT044 ; extended code menu variant tests
	Q
	;
START(FAIL)
	N LOCAL
	S LOCAL=0
	D T001(.LOCAL)
	I 'LOCAL W !,"OK - MIOUIT044"
	I $G(FAIL) S FAIL=FAIL+LOCAL Q
	I LOCAL S FAIL=1
	Q
	;
T001(FAIL)
	N CONF,REQ,CTX,TCTX,OUT,ERR
	D BUILDCODE^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOUIDEMO("pages/mioui_code_menus.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
	I $D(ERR) W !,"FAIL: [T001][render]" S FAIL=1 Q
	D HAS(.FAIL,"[T001][effective]",OUT,"Effective dating studio")
	D HAS(.FAIL,"[T001][dependency]",OUT,"Dependency rules")
	D HAS(.FAIL,"[T001][import]",OUT,"Import staging workspace")
	D HAS(.FAIL,"[T001][retire]",OUT,"Retirement and delete control")
	D HAS(.FAIL,"[T001][callback effective]",OUT,"scheduleCodeEffectiveDate")
	D HAS(.FAIL,"[T001][callback publish]",OUT,"publishFutureCodeVersion")
	D HAS(.FAIL,"[T001][callback dependency]",OUT,"saveCodeDependencyRules")
	D HAS(.FAIL,"[T001][callback preview]",OUT,"previewDeleteImpact")
	D HAS(.FAIL,"[T001][callback archive]",OUT,"archiveRetiredCodes")
	D HAS(.FAIL,"[T001][callback import]",OUT,"importCodeSetSpreadsheet")
	D HAS(.FAIL,"[T001][callback validate]",OUT,"validateImportedCodeRows")
	D HAS(.FAIL,"[T001][callback commit]",OUT,"commitImportedCodes")
	Q
	;
HAS(FAIL,LABEL,TXT,TOKEN)
	I TXT'[TOKEN W !,"FAIL: ",LABEL,": missing token=",TOKEN S FAIL=1
	Q
