MIOUIT038 ; workspace bootstrap form tests
	Q
	;
START(FAIL)
	N LOCAL,OUTS,OUT,REG
	S LOCAL=0
	K ^TMP("MIOUIT","OUTS")
	D PREP^MIOUIT008(.LOCAL,.OUTS)
	S OUT=$G(OUTS("pages/mioui_auth_forms.html"))
	D HAS(.LOCAL,"[T010][bootstrap title]",OUT,"Workspace bootstrap variants")
	D HAS(.LOCAL,"[T010][bootstrap create]",OUT,"Create a new workspace")
	D HAS(.LOCAL,"[T010][bootstrap join]",OUT,"Join an existing workspace")
	D HAS(.LOCAL,"[T010][bootstrap review]",OUT,"Request admin-reviewed join")
	D HAS(.LOCAL,"[T010][resolution title]",OUT,"Create or join workspace resolution")
	D HAS(.LOCAL,"[T010][resolution slug]",OUT,"north-shore-billing")
	D HAS(.LOCAL,"[T010][resolution invite]",OUT,"NSB-2048")
	D HAS(.LOCAL,"[T010][callback create]",OUT,"startCreateWorkspace")
	D HAS(.LOCAL,"[T010][callback join]",OUT,"startJoinWorkspace")
	D HAS(.LOCAL,"[T010][callback resolve]",OUT,"resolveInviteCode")
	D HAS(.LOCAL,"[T010][callback provision]",OUT,"provisionWorkspaceDefaults")
	D HAS(.LOCAL,"[T010][callback match]",OUT,"matchExistingWorkspace")
	D HAS(.LOCAL,"[T010][callback request]",OUT,"sendJoinRequestToAdmin")
	D LIST^MIOUIREG(.REG)
	D CHECKREG(.LOCAL,.REG,"form_workspace_bootstrap_variants","implemented","P1")
	D CHECKREG(.LOCAL,.REG,"form_workspace_bootstrap_resolution","implemented","P1")
	I LOCAL S FAIL=1 Q
	W !,"OK - MIOUIT038"
	Q
	;
CHECKREG(FAIL,REG,ID,STATUS,PHASE)
	N I,F S F=0,I=0
	F  S I=$O(REG(I)) Q:'I  I $G(REG(I,"id"))=ID S F=1 Q
	I 'F W !,"FAIL: [T020][",ID," status]: got= expected=",STATUS S FAIL=1 Q
	I $G(REG(I,"status"))'=STATUS W !,"FAIL: [T020][",ID," status]: got=",$G(REG(I,"status"))," expected=",STATUS S FAIL=1
	I $G(REG(I,"phase"))'=PHASE W !,"FAIL: [T020][",ID," phase]: got=",$G(REG(I,"phase"))," expected=",PHASE S FAIL=1
	Q
	;
HAS(FAIL,LABEL,TXT,TOKEN)
	I TXT'[TOKEN W !,"FAIL: ",LABEL,": missing token=",TOKEN S FAIL=1
	Q
	;
