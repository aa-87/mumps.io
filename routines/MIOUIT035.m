MIOUIT035 ; invitation-state and expired-invite-recovery tests
	Q
	;
START(FAIL)
	N LOCAL,OUTS,OUT,REG
	S LOCAL=0
	K ^TMP("MIOUIT","OUTS")
	D PREP^MIOUIT008(.LOCAL,.OUTS)
	S OUT=$G(OUTS("pages/mioui_auth_forms.html"))
	D HAS(.LOCAL,"[T010][invite states]",OUT,"Invitation state variants")
	D HAS(.LOCAL,"[T010][valid invite]",OUT,"Valid invitation")
	D HAS(.LOCAL,"[T010][expired invite]",OUT,"Expired invitation")
	D HAS(.LOCAL,"[T010][rescinded invite]",OUT,"Rescinded by admin")
	D HAS(.LOCAL,"[T010][accepted invite]",OUT,"Already accepted")
	D HAS(.LOCAL,"[T010][recovery title]",OUT,"Request a fresh invitation")
	D HAS(.LOCAL,"[T010][recovery audit]",OUT,"INV-2048")
	D HAS(.LOCAL,"[T010][callback fresh invite]",OUT,"requestFreshInvite")
	D HAS(.LOCAL,"[T010][callback contact admin]",OUT,"contactWorkspaceAdmin")
	D HAS(.LOCAL,"[T010][callback sign in]",OUT,"goToWorkspaceSignIn")
	D LIST^MIOUIREG(.REG)
	D CHECKREG(.LOCAL,.REG,"auth_invitation_state_stack","implemented","P1")
	D CHECKREG(.LOCAL,.REG,"form_expired_invite_recovery","implemented","P1")
	I LOCAL S FAIL=1 Q
	W !,"OK - MIOUIT035"
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
