MIOUIT036 ; account-recovery and trusted-device tests
	Q
	;
START(FAIL)
	N LOCAL,OUTS,OUT,REG
	S LOCAL=0
	K ^TMP("MIOUIT","OUTS")
	D PREP^MIOUIT008(.LOCAL,.OUTS)
	S OUT=$G(OUTS("pages/mioui_auth_forms.html"))
	D HAS(.LOCAL,"[T010][recovery title]",OUT,"Account recovery routes")
	D HAS(.LOCAL,"[T010][recovery email]",OUT,"Send a recovery email link")
	D HAS(.LOCAL,"[T010][recovery code]",OUT,"Verify a recovery code")
	D HAS(.LOCAL,"[T010][recovery escalate]",OUT,"Escalate to workspace review")
	D HAS(.LOCAL,"[T010][trusted title]",OUT,"Trusted device message")
	D HAS(.LOCAL,"[T010][trusted note]",OUT,"Trust only secure workstations")
	D HAS(.LOCAL,"[T010][trusted current]",OUT,"Youngstown review desk")
	D HAS(.LOCAL,"[T010][callback email]",OUT,"sendRecoveryEmailLink")
	D HAS(.LOCAL,"[T010][callback code]",OUT,"verifyRecoveryCode")
	D HAS(.LOCAL,"[T010][callback resend]",OUT,"resendRecoveryCode")
	D HAS(.LOCAL,"[T010][callback escalate]",OUT,"escalateRecoveryReview")
	D HAS(.LOCAL,"[T010][callback trust]",OUT,"trustCurrentDevice")
	D HAS(.LOCAL,"[T010][callback manage]",OUT,"manageTrustedDevices")
	D HAS(.LOCAL,"[T010][callback revoke]",OUT,"revokeDeviceTrust")
	D LIST^MIOUIREG(.REG)
	D CHECKREG(.LOCAL,.REG,"auth_account_recovery_variants","implemented","P1")
	D CHECKREG(.LOCAL,.REG,"auth_trusted_device_message","implemented","P1")
	I LOCAL S FAIL=1 Q
	W !,"OK - MIOUIT036"
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
