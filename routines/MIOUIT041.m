MIOUIT041 ; patient financial profile variant tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 D T020(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIT041"
 I LOCAL S FAIL=1
 Q
 ;
BASECONF(CONF)
 D CONFDEF^MIOUI(.CONF)
 D INIT^MIOUI(.CONF)
 Q
 ;
T001(FAIL)
 N CONF,REQ,CTX,TCTX
 D BASECONF(.CONF)
 D BUILD^MIOUIPRF(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOUIT000(.FAIL,"[T001][finance variant count]",$$COUNT^MIOUICTX($NA(TCTX("financeVariant"))),2)
 D EQ^MIOUIT000(.FAIL,"[T001][financial summary count]",$$COUNT^MIOUICTX($NA(TCTX("patientFinancial","summary"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][financial ledger count]",$$COUNT^MIOUICTX($NA(TCTX("patientFinancial","ledger"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][financial policy count]",$$COUNT^MIOUICTX($NA(TCTX("patientFinancial","policy"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][payment metric count]",$$COUNT^MIOUICTX($NA(TCTX("paymentPlan","metric"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][payment schedule count]",$$COUNT^MIOUICTX($NA(TCTX("paymentPlan","schedule"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][payment guardrail count]",$$COUNT^MIOUICTX($NA(TCTX("paymentPlan","guardrail"))),4)
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILD^MIOUIPRF(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_profile_variants.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T010][financial section]",OUT,"Patient financial and payment-plan variants")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][financial title]",OUT,"Patient financial summary")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][payment title]",OUT,"Payment-plan profile")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][financial callback]",OUT,"openPatientFinancialSummary")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][ledger callback]",OUT,"reviewPatientLedger")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][counseling callback]",OUT,"sendFinancialCounselingPacket")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][payment callback]",OUT,"openPatientPaymentPlan")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][simulate callback]",OUT,"simulatePlanAdjustment")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][agreement callback]",OUT,"sendPlanAgreement")
 Q
 ;
T020(FAIL)
 N REG,I,ID
 D LIST^MIOUIREG(.REG)
 F ID="profile_patient_financial_summary","profile_patient_payment_plan" D
 . S I=$$FIND^MIOUIREG(.REG,ID)
 . D EQ^MIOUIT000(.FAIL,"[T020]["_ID_" status]",$G(REG(I,"status")),"implemented")
 . D EQ^MIOUIT000(.FAIL,"[T020]["_ID_" phase]",$G(REG(I,"phase")),"P1")
 . D EQ^MIOUIT000(.FAIL,"[T020]["_ID_" test]",$G(REG(I,"test")),"MIOUIT041")
 Q
 ;
