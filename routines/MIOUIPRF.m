MIOUIPRF ; profile variant page builders
 Q
 ;
REG(CONF)
 N META
 K META S META("authRequired")=0,META("roles")=""
 D ADDM^MIOROUTE("GET","/mioui/profile-variants","PROFILES^MIOUIPRF",.META)
 S ^MIO("ROUTE","RAW","GET","/mioui/profile-variants")="PROFILES^MIOUIPRF"
 S ^MIO("ROUTE","META","GET","/mioui/profile-variants","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/profile-variants","roles")=""
 Q
 ;
PROFILES(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_profile_variants.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
BUILD(CONF,REQ,CTX,TCTX)
 D BASE^MIOUICTX(.TCTX)
 D APPLY^MIOUITHEME(.CONF,.TCTX)
 D ACT^MIOUICTX(.TCTX,"forms")
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Profile variants","Profile variants","Patient, biller, manager, and specialist profile pages shaped as dense SSR-first surfaces for billing and operator software.","Profile variants")
 S TCTX("pageTitle")="Profile variants"
 S TCTX("pageIntro")="Patient, biller, manager, and specialist profile pages shaped as dense SSR-first surfaces for billing and operator software. This pass preserves the original dossier/workbench/command families, keeps the patient financial subvariants, and adds collector, QA reviewer, and denial-specialist profile variants for denser operational personas."
 S TCTX("heroCallback")="openProfileVariantStudio"
 ; variant strip
 D VAR(.TCTX,1,"Patient profile","Coverage, communication, and recent financial activity.","openPatientProfile")
 D VAR(.TCTX,2,"Biller profile","Queues, productivity, payer focus, and access posture.","openBillerProfile")
 D VAR(.TCTX,3,"Manager profile","Capacity, approvals, escalations, and team oversight.","openManagerProfile")
 D VAR(.TCTX,4,"Profile comparison","Matrix view for deciding what belongs in each profile family.","openProfileComparisonMatrix")
 ; patient profile
 S TCTX("patient","eyebrow")="Patient variant"
 S TCTX("patient","title")="Patient profile"
 S TCTX("patient","subtitle")="A patient-facing profile should keep coverage, outreach preferences, balances, and recent activity visible without turning into a noisy internal workstation."
 S TCTX("patient","name")="Lila Bennett"
 S TCTX("patient","status")="Self-pay follow-up"
 S TCTX("patient","statusClass")="bg-amber-500/10 text-amber-700 dark:bg-amber-500/20 dark:text-amber-200"
 S TCTX("patient","patientId")="PT-20418"
 S TCTX("patient","dob")="1987-04-19"
 S TCTX("patient","coverage")="Northshore Silver HMO"
 S TCTX("patient","balance")="$482.14"
 S TCTX("patient","nextAction")="Verify secondary COB before next statement cycle"
 D KP(.TCTX,"patient","summary",1,"Preferred contact","SMS + portal")
 D KP(.TCTX,"patient","summary",2,"Statements","Electronic only")
 D KP(.TCTX,"patient","summary",3,"Last payment","2026-03-02 · $125.00")
 D KP(.TCTX,"patient","summary",4,"Care setting","Outpatient surgery")
 D KP(.TCTX,"patient","signal",1,"Eligibility","Active through 2026-12-31")
 D KP(.TCTX,"patient","signal",2,"Authorization","Approved · AUTH-88214")
 D KP(.TCTX,"patient","signal",3,"Collections risk","Moderate")
 D KP(.TCTX,"patient","signal",4,"Preferred language","English")
 D ITEM(.TCTX,"patient","event",1,"Estimate sent","2026-02-27","Portal estimate acknowledged with payment-plan question.")
 D ITEM(.TCTX,"patient","event",2,"Payment posted","2026-03-02","Card payment applied to anesthesia balance.")
 D ITEM(.TCTX,"patient","event",3,"Coverage review","2026-03-07","Secondary COB still missing from intake packet.")
 D ITEM(.TCTX,"patient","event",4,"Outreach scheduled","2026-03-18","SMS reminder prepared for billing support callback.")
 S TCTX("patient","primaryLabel")="Open patient profile"
 S TCTX("patient","primaryCallback")="openPatientProfile"
 S TCTX("patient","secondaryLabel")="Launch outreach plan"
 S TCTX("patient","secondaryCallback")="launchPatientOutreachPlan"
 S TCTX("patient","tertiaryLabel")="Run eligibility review"
 S TCTX("patient","tertiaryCallback")="runPatientEligibilityReview"
 ; biller profile
 S TCTX("biller","eyebrow")="Biller variant"
 S TCTX("biller","title")="Biller profile"
 S TCTX("biller","subtitle")="A biller-facing profile should center queue ownership, payer specialization, follow-up velocity, and controlled access to high-impact actions."
 S TCTX("biller","name")="Rafael Gomez"
 S TCTX("biller","role")="Senior follow-up biller"
 S TCTX("biller","team")="Commercial AR"
 S TCTX("biller","shift")="08:00 - 16:30 ET"
 D KP(.TCTX,"biller","metric",1,"Open claims","186")
 D KP(.TCTX,"biller","metric",2,"Touched today","42")
 D KP(.TCTX,"biller","metric",3,"Avg age bucket","31-45 days")
 D KP(.TCTX,"biller","metric",4,"Recovery this week","$18,420")
 D ITEM(.TCTX,"biller","queue",1,"BlueCross follow-up","72 claims · high dollar · callback 11:00 ET")
 D ITEM(.TCTX,"biller","queue",2,"Out-of-network reviews","28 claims · COB and appeals mix")
 D ITEM(.TCTX,"biller","queue",3,"Patient balance outreach","41 accounts · payment-plan offers enabled")
 D ITEM(.TCTX,"biller","queue",4,"Claim corrections","13 claims · provider note pending")
 D ITEM(.TCTX,"biller","focus",1,"Top payer","BlueCross MA","Largest current aging bucket")
 D ITEM(.TCTX,"biller","focus",2,"Specialty","Outpatient surgery","Most denials tied to authorization and implant coding")
 D ITEM(.TCTX,"biller","focus",3,"Escalation scope","Appeals up to level 1","Manager sign-off required above refund threshold")
 D ITEM(.TCTX,"biller","focus",4,"Trusted device","Required for ERA export","Device trust resets after password or browser changes")
 S TCTX("biller","primaryLabel")="Open biller profile"
 S TCTX("biller","primaryCallback")="openBillerProfile"
 S TCTX("biller","secondaryLabel")="Manage assignments"
 S TCTX("biller","secondaryCallback")="manageBillerAssignments"
 S TCTX("biller","tertiaryLabel")="Review access posture"
 S TCTX("biller","tertiaryCallback")="reviewBillerAccessPosture"
 ; manager profile
 S TCTX("manager","eyebrow")="Manager variant"
 S TCTX("manager","title")="Manager profile"
 S TCTX("manager","subtitle")="A manager-facing profile should behave like a compact command deck with staffing pressure, approvals, escalations, and performance drift visible at a glance."
 S TCTX("manager","name")="Maya Patel"
 S TCTX("manager","role")="Revenue cycle manager"
 S TCTX("manager","span")="3 teams · 19 billers · 2 QA reviewers"
 D KP(.TCTX,"manager","summary",1,"At-risk queues","3")
 D KP(.TCTX,"manager","summary",2,"Pending approvals","11")
 D KP(.TCTX,"manager","summary",3,"Coverage gaps","7")
 D KP(.TCTX,"manager","summary",4,"Overtime risk","Low")
 D ITEM(.TCTX,"manager","approval",1,"Access escalation","2 awaiting manager sign-off","One request extends ERA export privileges and one enables refund overrides.")
 D ITEM(.TCTX,"manager","approval",2,"Refund exception","1 over threshold requires approval","Balance review tied to duplicate patient payment investigation.")
 D ITEM(.TCTX,"manager","approval",3,"Appeal strategy","3 accounts flagged for payer counsel","Commercial payer bundle may need standardized appeal language.")
 D ITEM(.TCTX,"manager","approval",4,"Shift variance","5 queue moves need review","Temporary reassignment proposed to protect surgery follow-up SLA.")
 D ITEM(.TCTX,"manager","team",1,"Commercial AR","6 billers · queue heat 82%","BlueCross and Aetna backlog remains the main driver.")
 D ITEM(.TCTX,"manager","team",2,"Patient balance","5 billers · queue heat 69%","Payment-plan outreach is stable but statement callbacks are rising.")
 D ITEM(.TCTX,"manager","team",3,"Government follow-up","4 billers · queue heat 74%","Eligibility rechecks are slowing closure on crossover claims.")
 D ITEM(.TCTX,"manager","team",4,"QA and denials","4 reviewers · queue heat 63%","Appeal inventory is stable, but overturn rate drift needs review.")
 S TCTX("manager","primaryLabel")="Open manager profile"
 S TCTX("manager","primaryCallback")="openManagerProfile"
 S TCTX("manager","secondaryLabel")="Open escalation board"
 S TCTX("manager","secondaryCallback")="openManagerEscalationBoard"
 S TCTX("manager","tertiaryLabel")="Review capacity"
 S TCTX("manager","tertiaryCallback")="openManagerCapacityReview"
 ; comparison matrix
 S TCTX("matrix","eyebrow")="Shared profile contract"
 S TCTX("matrix","title")="Profile variant capability matrix"
 S TCTX("matrix","subtitle")="Use one comparison panel to decide which sections belong to each profile family before cloning layouts across the product."
 D ROW(.TCTX,1,"Identity and trust","Masked contact, coverage, consent","Role, team, access posture","Span, privilege scope, approval level")
 D ROW(.TCTX,2,"Primary metrics","Balance, estimate, last payment","Open claims, touch rate, recovery","Queue heat, approvals, staffing")
 D ROW(.TCTX,3,"Daily workflow","Statements, outreach, plan setup","Assignments, payer follow-up, corrections","Escalations, rebalancing, exceptions")
 D ROW(.TCTX,4,"Evidence detail","Recent encounters and notes","Worklists, payer focus, compliance","Approvals, team drift, blockers")
 D ROW(.TCTX,5,"Best CTA","Contact support or pay balance","Open work queue","Resolve pressure or approve changes")
 S TCTX("matrix","noteTitle")="Keep the density role-aware"
 S TCTX("matrix","noteBody")="Patient profiles should remain calmer and more explanatory. Biller and manager variants can be denser because they support queue work and operational decisions."
 S TCTX("matrix","callback")="openProfileVariantStudio"
 ; patient financial extensions
 D FVAR(.TCTX,1,"Patient financial summary","Balance bands, statements, charity review, and ledger posture.","openPatientFinancialSummary")
 D FVAR(.TCTX,2,"Payment-plan profile","Installments, autopay posture, missed-payment risk, and counseling actions.","openPatientPaymentPlan")
 S TCTX("patientFinancial","eyebrow")="Patient financial variant"
 S TCTX("patientFinancial","title")="Patient financial summary"
 S TCTX("patientFinancial","subtitle")="Use a quieter financial profile when the main task is balance review, assistance screening, and statement strategy instead of general account navigation."
 S TCTX("patientFinancial","name")="Lila Bennett"
 S TCTX("patientFinancial","status")="Statement cycle in progress"
 S TCTX("patientFinancial","statusClass")="bg-emerald-500/10 text-emerald-700 dark:bg-emerald-500/20 dark:text-emerald-200"
 S TCTX("patientFinancial","accountRef")="ACCT-77120 · Outpatient surgery"
 D KP(.TCTX,"patientFinancial","summary",1,"Total patient balance","$482.14")
 D KP(.TCTX,"patientFinancial","summary",2,"Current cycle due","$160.72")
 D KP(.TCTX,"patientFinancial","summary",3,"Last statement","2026-03-05")
 D KP(.TCTX,"patientFinancial","summary",4,"Promise to pay","2026-03-24")
 D ITEM(.TCTX,"patientFinancial","ledger",1,"Insurance payment","2026-02-24 · $1,184.66","Primary payer posted after deductible and coinsurance split.")
 D ITEM(.TCTX,"patientFinancial","ledger",2,"Patient payment","2026-03-02 · $125.00","Portal card payment applied to anesthesia portion.")
 D ITEM(.TCTX,"patientFinancial","ledger",3,"Statement generation","2026-03-05 · cycle 2","Printed and portal notices both queued because email bounce risk was cleared.")
 D ITEM(.TCTX,"patientFinancial","ledger",4,"Counseling review","2026-03-11 · financial assistance pending","Income attestation uploaded and awaiting counselor validation.")
 D ITEM(.TCTX,"patientFinancial","policy",1,"Bad-debt threshold","240 days aging","Do not advance while assistance packet remains active.")
 D ITEM(.TCTX,"patientFinancial","policy",2,"Preferred statement route","Portal then SMS","Paper statements only if outreach fails twice.")
 D ITEM(.TCTX,"patientFinancial","policy",3,"Charity review stage","Needs household-size confirmation","Counselor follow-up should occur before the next cycle closes.")
 D ITEM(.TCTX,"patientFinancial","policy",4,"Self-pay discount","Eligible for prompt-pay tier","Offer remains valid through 2026-03-28.")
 S TCTX("patientFinancial","primaryLabel")="Open patient financial summary"
 S TCTX("patientFinancial","primaryCallback")="openPatientFinancialSummary"
 S TCTX("patientFinancial","secondaryLabel")="Review patient ledger"
 S TCTX("patientFinancial","secondaryCallback")="reviewPatientLedger"
 S TCTX("patientFinancial","tertiaryLabel")="Send counseling packet"
 S TCTX("patientFinancial","tertiaryCallback")="sendFinancialCounselingPacket"
 S TCTX("paymentPlan","eyebrow")="Payment-plan variant"
 S TCTX("paymentPlan","title")="Payment-plan profile"
 S TCTX("paymentPlan","subtitle")="Use a plan-focused profile when the main task is installment design, autopay readiness, missed-payment prevention, and counselor follow-up."
 S TCTX("paymentPlan","name")="Lila Bennett"
 S TCTX("paymentPlan","status")="Draft plan awaiting consent"
 S TCTX("paymentPlan","statusClass")="bg-violet-500/10 text-violet-700 dark:bg-violet-500/20 dark:text-violet-200"
 S TCTX("paymentPlan","planRef")="PLAN-22941 · 6-month proposal"
 D KP(.TCTX,"paymentPlan","metric",1,"Down payment","$82.14")
 D KP(.TCTX,"paymentPlan","metric",2,"Monthly installment","$66.00")
 D KP(.TCTX,"paymentPlan","metric",3,"Autopay status","Eligible · card on file")
 D KP(.TCTX,"paymentPlan","metric",4,"Missed-payment risk","Low")
 D ITEM(.TCTX,"paymentPlan","schedule",1,"Installment 1","2026-03-24 · $82.14","Down payment collected at agreement signing.")
 D ITEM(.TCTX,"paymentPlan","schedule",2,"Installment 2","2026-04-24 · $66.00","Autopay draft with SMS reminder 3 days prior.")
 D ITEM(.TCTX,"paymentPlan","schedule",3,"Installment 3","2026-05-24 · $66.00","Portal acknowledgment requested if card token changes.")
 D ITEM(.TCTX,"paymentPlan","schedule",4,"Installment 4-6","2026-06 through 2026-08 · $66.00","Manager approval required only if hardship extension pushes beyond 6 months.")
 D ITEM(.TCTX,"paymentPlan","guardrail",1,"Autopay guardrail","Card token verified","Re-verify after any password reset or device-trust reset.")
 D ITEM(.TCTX,"paymentPlan","guardrail",2,"Grace window","5 days","After day 5, counseling follow-up starts before collections handoff.")
 D ITEM(.TCTX,"paymentPlan","guardrail",3,"Hardship override","Supervisor approval","Required if monthly installment falls below floor amount.")
 D ITEM(.TCTX,"paymentPlan","guardrail",4,"Agreement delivery","Portal plus PDF email","Send paper copy only on explicit request.")
 S TCTX("paymentPlan","primaryLabel")="Open patient payment-plan profile"
 S TCTX("paymentPlan","primaryCallback")="openPatientPaymentPlan"
 S TCTX("paymentPlan","secondaryLabel")="Simulate plan adjustment"
 S TCTX("paymentPlan","secondaryCallback")="simulatePlanAdjustment"
 S TCTX("paymentPlan","tertiaryLabel")="Send plan agreement"
 S TCTX("paymentPlan","tertiaryCallback")="sendPlanAgreement"
 ; operational specialist extensions
 D SVAR(.TCTX,1,"Collector profile","Promise-to-pay inventory, outbound strategy, and collections compliance.","openCollectorProfile")
 D SVAR(.TCTX,2,"QA reviewer profile","Audit queue, defect drift, and coaching signals.","openQaReviewerProfile")
 D SVAR(.TCTX,3,"Denial specialist profile","Denial inventory, filing-window risk, and appeal posture.","openDenialSpecialistProfile")
 S TCTX("collector","eyebrow")="Collector variant"
 S TCTX("collector","title")="Collector profile"
 S TCTX("collector","subtitle")="Use a collector-focused profile when the main task is promise-to-pay management, outbound cadence, hardship flags, and collections-safe scripting."
 S TCTX("collector","name")="Naomi Brooks"
 S TCTX("collector","role")="Patient collections specialist"
 S TCTX("collector","region")="East self-pay portfolio"
 S TCTX("collector","status")="High-touch call block in progress"
 S TCTX("collector","statusClass")="bg-amber-500/10 text-amber-700 dark:bg-amber-500/20 dark:text-amber-200"
 D KP(.TCTX,"collector","metric",1,"Accounts assigned","144")
 D KP(.TCTX,"collector","metric",2,"Promises to pay","18")
 D KP(.TCTX,"collector","metric",3,"Due today","6")
 D KP(.TCTX,"collector","metric",4,"Recovered this week","$12,610")
 D ITEM(.TCTX,"collector","pipeline",1,"Morning callbacks","07 accounts · $3,240","Six patients requested post-workday outreach windows and one needs interpreter support.")
 D ITEM(.TCTX,"collector","pipeline",2,"Broken promise review","05 accounts · aging 61-90","Two accounts qualify for hardship review before external collections escalation.")
 D ITEM(.TCTX,"collector","pipeline",3,"Settlement candidates","04 accounts · supervisor review","All four exceed the standard discount floor and need documented approval.")
 D ITEM(.TCTX,"collector","pipeline",4,"Text-to-pay batch","12 accounts · portal-ready","Send only where consent and mobile verification are both active.")
 D ITEM(.TCTX,"collector","compliance",1,"Mini-Miranda script","Required on third-party debt calls","Trigger script automatically when the account source flips to agency-prep.")
 D ITEM(.TCTX,"collector","compliance",2,"Do-not-call window","Protected 20:00 to 08:00 local","Five accounts in the queue need timezone normalization before outreach.")
 D ITEM(.TCTX,"collector","compliance",3,"Hardship posture","3 pending attestations","Do not move these accounts into settlement workflows until documents are reviewed.")
 D ITEM(.TCTX,"collector","compliance",4,"Preferred payment rail","Portal and IVR only","Agent-assisted card capture is disabled for this profile family.")
 S TCTX("collector","primaryLabel")="Open collector profile"
 S TCTX("collector","primaryCallback")="openCollectorProfile"
 S TCTX("collector","secondaryLabel")="Launch collection plan"
 S TCTX("collector","secondaryCallback")="launchCollectionPlan"
 S TCTX("collector","tertiaryLabel")="Review promises to pay"
 S TCTX("collector","tertiaryCallback")="reviewCollectorPromiseToPay"
 S TCTX("qa","eyebrow")="QA reviewer variant"
 S TCTX("qa","title")="QA reviewer profile"
 S TCTX("qa","subtitle")="Use a QA-focused profile when the main task is sampling work, documenting defects, coaching billers, and tracking policy drift across queues."
 S TCTX("qa","name")="Evan Cole"
 S TCTX("qa","role")="Revenue cycle QA reviewer"
 S TCTX("qa","coverage")="Commercial AR + patient balance"
 S TCTX("qa","status")="Audit sample queued"
 S TCTX("qa","statusClass")="bg-sky-500/10 text-sky-700 dark:bg-sky-500/20 dark:text-sky-200"
 D KP(.TCTX,"qa","metric",1,"Open audits","27")
 D KP(.TCTX,"qa","metric",2,"High-risk defects","5")
 D KP(.TCTX,"qa","metric",3,"Coaching tasks","9")
 D KP(.TCTX,"qa","metric",4,"Overturn drift","-3.2%")
 D ITEM(.TCTX,"qa","queue",1,"Authorization audits","08 cases · outpatient surgery","Four need note-level evidence because authorization IDs were captured late.")
 D ITEM(.TCTX,"qa","queue",2,"Patient statement audits","06 cases · self-pay","Focus is on discount disclosures and counseling packet timing.")
 D ITEM(.TCTX,"qa","queue",3,"Appeal packet review","07 cases · commercial","Verify medical necessity attachments and payer-specific form completeness.")
 D ITEM(.TCTX,"qa","queue",4,"Refund exception audit","06 cases · threshold review","One case shows likely duplicate patient payment reversal timing drift.")
 D ITEM(.TCTX,"qa","variance",1,"Top defect theme","Missing follow-up evidence","Appears mostly in reassigned queues after shift balancing.")
 D ITEM(.TCTX,"qa","variance",2,"Documentation drift","Portal note templates outdated","Two macros still reference retired denial categories.")
 D ITEM(.TCTX,"qa","variance",3,"Coaching posture","3 billers need targeted review","One collector also needs call-script coaching tied to hardship language.")
 D ITEM(.TCTX,"qa","variance",4,"Escalation threshold","Manager review after 2 severe defects","Current week has one specialist approaching threshold.")
 S TCTX("qa","primaryLabel")="Open QA reviewer profile"
 S TCTX("qa","primaryCallback")="openQaReviewerProfile"
 S TCTX("qa","secondaryLabel")="Open audit queue"
 S TCTX("qa","secondaryCallback")="openQaAuditQueue"
 S TCTX("qa","tertiaryLabel")="Compare documentation drift"
 S TCTX("qa","tertiaryCallback")="compareDocumentationDrift"
 S TCTX("denial","eyebrow")="Denial specialist variant"
 S TCTX("denial","title")="Denial specialist profile"
 S TCTX("denial","subtitle")="Use a denial-specialist profile when the main task is denial triage, filing-window protection, overturn strategy, and appeal packet quality."
 S TCTX("denial","name")="Priya Shah"
 S TCTX("denial","role")="Senior denial specialist"
 S TCTX("denial","focus")="Orthopedic and surgery appeals"
 S TCTX("denial","status")="Appeal window risk elevated"
 S TCTX("denial","statusClass")="bg-rose-500/10 text-rose-700 dark:bg-rose-500/20 dark:text-rose-200"
 D KP(.TCTX,"denial","metric",1,"Active denials","92")
 D KP(.TCTX,"denial","metric",2,"At-risk filing windows","7")
 D KP(.TCTX,"denial","metric",3,"Appealed dollars","$84,120")
 D KP(.TCTX,"denial","metric",4,"Overturn target","74%")
 D ITEM(.TCTX,"denial","inventory",1,"Medical necessity","31 cases · $28,440","Largest bucket. Three need physician attestation updates before submission.")
 D ITEM(.TCTX,"denial","inventory",2,"Authorization missing","22 cases · $17,860","Seven may move to payer-reconsideration rather than full appeal.")
 D ITEM(.TCTX,"denial","inventory",3,"Coding mismatch","18 cases · $14,200","Implant and modifier usage remain the main review areas.")
 D ITEM(.TCTX,"denial","inventory",4,"Timely filing disputes","09 cases · $11,540","Escalate immediately when internal hold time caused payer deadline proximity.")
 D ITEM(.TCTX,"denial","appeal",1,"Next appeal wave","2026-03-19 · 14 packets","Bundle by payer and denial reason to reduce evidence assembly time.")
 D ITEM(.TCTX,"denial","appeal",2,"Physician signatures","5 pending","Surgery packets are blocked until operative-note addenda are uploaded.")
 D ITEM(.TCTX,"denial","appeal",3,"Counsel review","2 high-value accounts","Use when payer policy language conflicts with contract interpretation.")
 D ITEM(.TCTX,"denial","appeal",4,"Template drift","1 payer form retired","Update packet checklist before tomorrow's submission block.")
 S TCTX("denial","primaryLabel")="Open denial specialist profile"
 S TCTX("denial","primaryCallback")="openDenialSpecialistProfile"
 S TCTX("denial","secondaryLabel")="Review denial packets"
 S TCTX("denial","secondaryCallback")="reviewDenialPackets"
 S TCTX("denial","tertiaryLabel")="Launch appeal strategy"
 S TCTX("denial","tertiaryCallback")="launchAppealStrategy"
 Q
 ;
VAR(TCTX,IDX,TITLE,DESC,CALLBACK)
 S TCTX("variant",+IDX,"title")=$G(TITLE)
 S TCTX("variant",+IDX,"desc")=$G(DESC)
 S TCTX("variant",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
FVAR(TCTX,IDX,TITLE,DESC,CALLBACK)
 S TCTX("financeVariant",+IDX,"title")=$G(TITLE)
 S TCTX("financeVariant",+IDX,"desc")=$G(DESC)
 S TCTX("financeVariant",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
SVAR(TCTX,IDX,TITLE,DESC,CALLBACK)
 S TCTX("specialistVariant",+IDX,"title")=$G(TITLE)
 S TCTX("specialistVariant",+IDX,"desc")=$G(DESC)
 S TCTX("specialistVariant",+IDX,"callback")=$G(CALLBACK)
 Q
 ;
KP(TCTX,ROOT,NODE,IDX,LABEL,VALUE)
 S TCTX(ROOT,NODE,+IDX,"label")=$G(LABEL)
 S TCTX(ROOT,NODE,+IDX,"value")=$G(VALUE)
 Q
 ;
ITEM(TCTX,ROOT,NODE,IDX,LABEL,VALUE,DETAIL)
 S TCTX(ROOT,NODE,+IDX,"label")=$G(LABEL)
 S TCTX(ROOT,NODE,+IDX,"value")=$G(VALUE)
 S TCTX(ROOT,NODE,+IDX,"detail")=$G(DETAIL)
 Q
 ;
ROW(TCTX,IDX,LABEL,PATIENT,BILLER,MANAGER)
 S TCTX("matrix","row",+IDX,"label")=$G(LABEL)
 S TCTX("matrix","row",+IDX,"patient")=$G(PATIENT)
 S TCTX("matrix","row",+IDX,"biller")=$G(BILLER)
 S TCTX("matrix","row",+IDX,"manager")=$G(MANAGER)
 Q
 ;
