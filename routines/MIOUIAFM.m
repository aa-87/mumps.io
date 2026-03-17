MIOUIAFM ; MIOUI auth and forms builders
 Q
 ;
REG(CONF)
 N META
 K META S META("authRequired")=0,META("roles")=""
 D ADDM^MIOROUTE("GET","/mioui/auth-forms","AUTHFORMS^MIOUIAFM",.META)
 S ^MIO("ROUTE","RAW","GET","/mioui/auth-forms")="AUTHFORMS^MIOUIAFM"
 S ^MIO("ROUTE","META","GET","/mioui/auth-forms","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/auth-forms","roles")=""
 Q
 ;
AUTHFORMS(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_auth_forms.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
BUILD(CONF,REQ,CTX,TCTX)
 D BASE^MIOUICTX(.TCTX)
 D APPLY^MIOUITHEME(.CONF,.TCTX)
 D ACT^MIOUICTX(.TCTX,"forms")
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Auth and forms","Auth and forms","Reusable login, signup, recovery, verification, and dense form combinations for operator products.","Auth and form lab")
 S TCTX("pageTitle")="Auth and form lab"
 S TCTX("pageIntro")="Reusable login, signup, recovery, verification, and dense form combinations for operator products."
 S TCTX("heroCallback")="openAuthPatternStudio"
 ; hero cards
 S TCTX("hero",1,"title")="Trusted access"
 S TCTX("hero",1,"desc")="Dense login surface for operator and supervisor access."
 S TCTX("hero",1,"callback")="submitLoginForm"
 S TCTX("hero",2,"title")="Create account"
 S TCTX("hero",2,"desc")="Account creation with role and organization capture."
 S TCTX("hero",2,"callback")="submitSignupForm"
 ; login
 S TCTX("login","title")="Trusted access"
 S TCTX("login","subtitle")="Sign in to your operator workspace."
 S TCTX("login","email")="operator@efuzy.local"
 S TCTX("login","callback")="submitLoginForm"
 ; signup
 S TCTX("signup","title")="Create account"
 S TCTX("signup","subtitle")="Create a new team or join an existing workspace."
 S TCTX("signup","callback")="submitSignupForm"
 ; forgot/reset/mfa
 S TCTX("forgot","title")="Forgot password"
 S TCTX("forgot","callback")="sendResetLink"
 S TCTX("reset","title")="Reset password"
 S TCTX("reset","callback")="submitResetPassword"
 S TCTX("mfa","title")="Verification code"
 S TCTX("mfa","callback")="verifyOtpCode"
 ; profile registration
 S TCTX("profile","title")="Registration profile"
 S TCTX("profile","callback")="saveProfileBasics"
 S TCTX("profile","org")="North Shore Billing"
 S TCTX("profile","role")="Revenue operations lead"
 ; onboarding
 S TCTX("onboard","title")="Step 1 of 3"
 S TCTX("onboard","callback")="continueOnboarding"
 S TCTX("onboard","step",1,"title")="Workspace basics"
 S TCTX("onboard","step",2,"title")="Security defaults"
 S TCTX("onboard","step",3,"title")="Queue preferences"
 ; advanced filters
 S TCTX("filters","title")="Advanced filters"
 S TCTX("filters","callback")="applyAdvancedFilters"
 S TCTX("filters","savedName")="High-risk follow-up"
 ; validation
 S TCTX("validation","title")="Please correct the highlighted fields"
 S TCTX("validation","callback")="focusInvalidField"
 S TCTX("validation","issue",1)="Email is required"
 S TCTX("validation","issue",2)="Password must be at least 12 characters"
 S TCTX("validation","issue",3)="At least one queue preference is required"
 Q
 ;
