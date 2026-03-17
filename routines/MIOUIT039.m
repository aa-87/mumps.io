MIOUIT039 ; profile-completion and first-run-hardening tests
	Q
	;
START(FAIL)
	N LOCAL,OUTS,OUT,REG
	S LOCAL=0
	K ^TMP("MIOUIT","OUTS")
	D PREP^MIOUIT008(.LOCAL,.OUTS)
	S OUT=$G(OUTS("pages/mioui_auth_forms.html"))
	D HAS(.LOCAL,"[T010][profile completion title]",OUT,"Profile completion variants")
	D HAS(.LOCAL,"[T010][profile operator]",OUT,"Operator profile completion")
	D HAS(.LOCAL,"[T010][profile supervisor]",OUT,"Supervisor profile completion")
	D HAS(.LOCAL,"[T010][profile external]",OUT,"External reviewer completion")
	D HAS(.LOCAL,"[T010][profile callback operator]",OUT,"completeOperatorProfile")
	D HAS(.LOCAL,"[T010][profile callback supervisor]",OUT,"completeSupervisorProfile")
	D HAS(.LOCAL,"[T010][profile callback external]",OUT,"completeExternalReviewerProfile")
	D HAS(.LOCAL,"[T010][hardening title]",OUT,"First-run account hardening")
	D HAS(.LOCAL,"[T010][hardening section]",OUT,"Identity hardening")
	D HAS(.LOCAL,"[T010][hardening checklist]",OUT,"Require MFA enrollment before queue access")
	D HAS(.LOCAL,"[T010][hardening callback save]",OUT,"saveFirstRunHardening")
	D HAS(.LOCAL,"[T010][hardening callback enforce]",OUT,"enforceMfaEnrollment")
	D HAS(.LOCAL,"[T010][hardening callback codes]",OUT,"generateBackupRecoveryCodes")
	D HAS(.LOCAL,"[T010][hardening callback trust]",OUT,"reviewTrustedDevicePolicy")
	D LIST^MIOUIREG(.REG)
	D CHECKREG(.LOCAL,.REG,"form_profile_completion_variants","implemented","P1")
	D CHECKREG(.LOCAL,.REG,"form_first_run_account_hardening","implemented","P1")
	I LOCAL S FAIL=1 Q
	W !,"OK - MIOUIT039"
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
