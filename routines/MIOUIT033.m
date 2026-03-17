MIOUIT033 ; auth/forms ROI tests
	Q
	;
START(FAIL)  ; run ROI 23 coverage
	N FAIL,CONF,REQ,CTX,OUTS,OUT,REG
	S FAIL=0
	K ^TMP("MIOUIT","OUTS")
	D PREP^MIOUIT008(.FAIL,.OUTS)
	S OUT=$G(OUTS("pages/mioui_auth_forms.html"))
	D HAS(.FAIL,"[T010][title]",OUT,"Auth and form lab")
	D HAS(.FAIL,"[T010][login]",OUT,"Trusted access")
	D HAS(.FAIL,"[T010][signup]",OUT,"Create account")
	D HAS(.FAIL,"[T010][forgot]",OUT,"Forgot password")
	D HAS(.FAIL,"[T010][reset]",OUT,"Reset password")
	D HAS(.FAIL,"[T010][mfa]",OUT,"Verification code")
	D HAS(.FAIL,"[T010][profile]",OUT,"Registration profile")
	D HAS(.FAIL,"[T010][onboarding]",OUT,"Step 1 of 3")
	D HAS(.FAIL,"[T010][filters]",OUT,"Advanced filters")
	D HAS(.FAIL,"[T010][validation]",OUT,"Please correct the highlighted fields")
	D HAS(.FAIL,"[T010][callback login]",OUT,"submitLoginForm")
	D HAS(.FAIL,"[T010][callback signup]",OUT,"submitSignupForm")
	D HAS(.FAIL,"[T010][callback forgot]",OUT,"sendResetLink")
	D HAS(.FAIL,"[T010][callback reset]",OUT,"submitResetPassword")
	D HAS(.FAIL,"[T010][callback mfa]",OUT,"verifyOtpCode")
	D HAS(.FAIL,"[T010][callback filters]",OUT,"applyAdvancedFilters")
	D LIST^MIOUIREG(.REG)
	D CHECKREG(.FAIL,.REG,"auth_login_card","implemented","P1")
	D CHECKREG(.FAIL,.REG,"auth_signup_card","implemented","P1")
	D CHECKREG(.FAIL,.REG,"form_advanced_filter_panel","implemented","P1")
	D CHECKREG(.FAIL,.REG,"page_auth_forms","implemented","P1")
	I 'FAIL W !,"OK - MIOUIT033"
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
	;