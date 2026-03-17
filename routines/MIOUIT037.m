MIOUIT037 ; admin preference matrix and access review tests
	Q
	;
START(FAIL)
	N LOCAL,OUTS,OUT,REG
	S LOCAL=0
	K ^TMP("MIOUIT","OUTS")
	D PREP^MIOUIT008(.LOCAL,.OUTS)
	S OUT=$G(OUTS("pages/mioui_auth_forms.html"))
	D HAS(.LOCAL,"[T010][admin prefs title]",OUT,"Admin preference matrix")
	D HAS(.LOCAL,"[T010][admin prefs section]",OUT,"Default security posture")
	D HAS(.LOCAL,"[T010][admin prefs callback save]",OUT,"saveAdminPreferenceMatrix")
	D HAS(.LOCAL,"[T010][admin prefs callback reset]",OUT,"resetAdminPreferenceDefaults")
	D HAS(.LOCAL,"[T010][access review title]",OUT,"Access review queue")
	D HAS(.LOCAL,"[T010][access review pending]",OUT,"Pending access request")
	D HAS(.LOCAL,"[T010][access review callback approve]",OUT,"approveAccessRequest")
	D HAS(.LOCAL,"[T010][access review callback clarify]",OUT,"requestAccessClarification")
	D HAS(.LOCAL,"[T010][access review callback deny]",OUT,"denyAccessRequest")
	D HAS(.LOCAL,"[T010][access review callback audit]",OUT,"viewAccessReviewAudit")
	D LIST^MIOUIREG(.REG)
	D CHECKREG(.LOCAL,.REG,"form_admin_preference_matrix","implemented","P1")
	D CHECKREG(.LOCAL,.REG,"form_access_review_stack","implemented","P1")
	I LOCAL S FAIL=1 Q
	W !,"OK - MIOUIT037"
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
