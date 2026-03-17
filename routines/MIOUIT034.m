MIOUIT034 ; invitation, consent, and progressive preference form tests
	Q
	;
START(FAIL)
	N FAIL,OUTS,OUT,REG
	S FAIL=0
	K ^TMP("MIOUIT","OUTS")
	D PREP^MIOUIT008(.FAIL,.OUTS)
	S OUT=$G(OUTS("pages/mioui_auth_forms.html"))
	D HAS(.FAIL,"[T010][invite]",OUT,"Workspace invitation")
	D HAS(.FAIL,"[T010][invite workspace]",OUT,"North Shore Billing")
	D HAS(.FAIL,"[T010][consent]",OUT,"Consent and approval")
	D HAS(.FAIL,"[T010][prefs]",OUT,"Security and notification preferences")
	D HAS(.FAIL,"[T010][prefs item]",OUT,"Require MFA for elevated actions")
	D HAS(.FAIL,"[T010][callback invite]",OUT,"acceptWorkspaceInvite")
	D HAS(.FAIL,"[T010][callback consent]",OUT,"approvePolicyBundle")
	D HAS(.FAIL,"[T010][callback prefs]",OUT,"saveSecurityPreferences")
	D LIST^MIOUIREG(.REG)
	D CHECKREG(.FAIL,.REG,"auth_workspace_invitation","implemented","P1")
	D CHECKREG(.FAIL,.REG,"form_consent_approval","implemented","P1")
	D CHECKREG(.FAIL,.REG,"form_progressive_preferences","implemented","P1")
	I 'FAIL W !,"OK - MIOUIT034"
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
