MIOUIBILLD ; Patient-oriented billing component demo
 Q
 ;
REG(CONF)
 N META
 K META
 S META("authRequired")=0
 S META("roles")=""
 D ADDM^MIOROUTE("GET","/mioui/billing-patient","PATIENT^MIOUIBILLD",.META)
 D ADDM^MIOROUTE("GET","/mioui/billing-patient-dense","PATIENTD^MIOUIBILLD",.META)
 D ADDM^MIOROUTE("GET","/mioui/billing-patient-balanced","PATIENTB^MIOUIBILLD",.META)
 S ^MIO("ROUTE","RAW","GET","/mioui/billing-patient")="PATIENT^MIOUIBILLD"
 S ^MIO("ROUTE","META","GET","/mioui/billing-patient","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/billing-patient","roles")=""
 S ^MIO("ROUTE","RAW","GET","/mioui/billing-patient-dense")="PATIENTD^MIOUIBILLD"
 S ^MIO("ROUTE","META","GET","/mioui/billing-patient-dense","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/billing-patient-dense","roles")=""
 S ^MIO("ROUTE","RAW","GET","/mioui/billing-patient-balanced")="PATIENTB^MIOUIBILLD"
 S ^MIO("ROUTE","META","GET","/mioui/billing-patient-balanced","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/billing-patient-balanced","roles")=""
 Q
 ;
PATIENT(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_patient_review.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
PATIENTD(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILDD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_patient_review_dense.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
PATIENTB(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILDB(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_patient_review_balanced.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
BUILD(CONF,REQ,CTX,TCTX)
 D BASE(.CONF,.REQ,.CTX,.TCTX,"stacked")
 Q
 ;
BUILDD(CONF,REQ,CTX,TCTX)
 D BASE(.CONF,.REQ,.CTX,.TCTX,"dense")
 S TCTX("billDense","workspaceClass")="h-[calc(100vh-16.5rem)] min-h-[42rem] overflow-hidden"
 S TCTX("billDense","tab",1,"key")="claim"
 S TCTX("billDense","tab",1,"label")="Claims"
 S TCTX("billDense","tab",1,"count")=8
 S TCTX("billDense","tab",1,"isActive")=1
 S TCTX("billDense","tab",2,"key")="transactions"
 S TCTX("billDense","tab",2,"label")="Transactions"
 S TCTX("billDense","tab",2,"count")=3
 S TCTX("billDense","tab",3,"key")="x12"
 S TCTX("billDense","tab",3,"label")="Raw X12"
 S TCTX("billDense","tab",3,"count")=12
 Q
 ;
BUILDB(CONF,REQ,CTX,TCTX)
 D BASE(.CONF,.REQ,.CTX,.TCTX,"balanced")
 S TCTX("billBalanced","tab",1,"key")="parties"
 S TCTX("billBalanced","tab",1,"label")="Patient and Parties"
 S TCTX("billBalanced","tab",1,"count")=8
 S TCTX("billBalanced","tab",1,"isActive")=1
 S TCTX("billBalanced","tab",2,"key")="transactions"
 S TCTX("billBalanced","tab",2,"label")="Transactions"
 S TCTX("billBalanced","tab",2,"count")=3
 S TCTX("billBalanced","tab",3,"key")="x12"
 S TCTX("billBalanced","tab",3,"label")="Raw X12"
 S TCTX("billBalanced","tab",3,"count")=12
 Q
 ;
BASE(CONF,REQ,CTX,TCTX,MODE)
 D BASE^MIOUICTX(.TCTX)
 D APPLY^MIOUITHEME(.CONF,.TCTX)
 D ACT^MIOUICTX(.TCTX,"billing")
 S TCTX("billMode")=$G(MODE)
 D PAGECFG(.TCTX,$G(MODE))
 D FOOTER(.TCTX)
 D STATS(.TCTX,$G(MODE))
 D HEADER^MIOUIBILL(.TCTX,"CLMNO58274","Rios, Elaine M","North Harbor Health Plan","Ready for review","sky")
 D FACTS(.TCTX)
 D SECTIONS(.TCTX)
 D NOTES(.TCTX)
 D TXNS(.TCTX)
 D X12(.TCTX)
 Q
 ;
PAGECFG(TCTX,MODE)
 I $G(MODE)="dense" D  Q
 . D PAGE^MIOUICTX(.TCTX,"MIOUI / Billing / Patient dense review","Patient-oriented dense billing review","A fixed-height tabbed workspace that keeps claim, transaction, and raw X12 review on one screen without page-level vertical scrolling.","Billing dense workspace")
 I $G(MODE)="balanced" D  Q
 . D PAGE^MIOUICTX(.TCTX,"MIOUI / Billing / Patient balanced review","Patient-oriented balanced billing review","A hybrid billing workspace that blends a readable claim overview with tabbed switching for parties, transactions, and raw X12 review.","Billing balanced workspace")
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Billing / Patient review","Patient-oriented billing review","Dense claim, transaction, and raw X12 components shaped for operator scanning, payer review, and patient-level trace.","Billing detail lab")
 Q
 ;
FOOTER(TCTX)
 S TCTX("footer","links",7,"label")="Patient review"
 S TCTX("footer","links",7,"href")="/mioui/billing-patient"
 S TCTX("footer","links",8,"label")="Patient dense"
 S TCTX("footer","links",8,"href")="/mioui/billing-patient-dense"
 S TCTX("footer","links",9,"label")="Patient balanced"
 S TCTX("footer","links",9,"href")="/mioui/billing-patient-balanced"
 Q
 ;
STATS(TCTX,MODE)
 I $G(MODE)="dense" D  Q
 . D STAT^MIOUIPANEL(.TCTX,1,"Tabs",3,"sky","/mioui/billing-patient-dense")
 . D STAT^MIOUIPANEL(.TCTX,2,"Claim cards",8,"violet","/mioui/billing-patient-dense")
 . D STAT^MIOUIPANEL(.TCTX,3,"Service lines",3,"emerald","/mioui/billing-patient-dense")
 . D STAT^MIOUIPANEL(.TCTX,4,"X12 loops",12,"amber","/mioui/billing-patient-dense")
 I $G(MODE)="balanced" D  Q
 . D STAT^MIOUIPANEL(.TCTX,1,"Workspace tabs",3,"sky","/mioui/billing-patient-balanced")
 . D STAT^MIOUIPANEL(.TCTX,2,"Detail cards",8,"violet","/mioui/billing-patient-balanced#balanced-parties")
 . D STAT^MIOUIPANEL(.TCTX,3,"Service lines",3,"emerald","/mioui/billing-patient-balanced#balanced-transactions")
 . D STAT^MIOUIPANEL(.TCTX,4,"X12 loops",12,"amber","/mioui/billing-patient-balanced#balanced-x12")
 D STAT^MIOUIPANEL(.TCTX,1,"Claim facts",9,"sky","/mioui/billing-patient#claim-component")
 D STAT^MIOUIPANEL(.TCTX,2,"Detail cards",8,"violet","/mioui/billing-patient#claim-sections")
 D STAT^MIOUIPANEL(.TCTX,3,"Service lines",3,"emerald","/mioui/billing-patient#transaction-component")
 D STAT^MIOUIPANEL(.TCTX,4,"X12 loops",12,"amber","/mioui/billing-patient#x12-component")
 Q
 ;
FACTS(TCTX)
 D FACT^MIOUIBILL(.TCTX,1,"Patient Ctrl Num (Claim ID)","CLMNO58274")
 D FACT^MIOUIBILL(.TCTX,2,"Charge Amt","$1,986.40")
 D FACT^MIOUIBILL(.TCTX,3,"Place of Service","12 - Home Health")
 D FACT^MIOUIBILL(.TCTX,4,"Frequency","Original claim")
 D FACT^MIOUIBILL(.TCTX,5,"Service Dates","2026-02-11 - 2026-02-17 (7 days)")
 D FACT^MIOUIBILL(.TCTX,6,"Provider Signature Indicator","Y")
 D FACT^MIOUIBILL(.TCTX,7,"Assignment Participation Code","A")
 D FACT^MIOUIBILL(.TCTX,8,"Benefits Assignment Indicator","Y")
 D FACT^MIOUIBILL(.TCTX,9,"Release of Information Code","Y")
 Q
 ;
SECTIONS(TCTX)
 D SECTION^MIOUIBILL(.TCTX,1,"Insured Subscriber (Self, Primary)","Member ID: MBR842175 - Name: Rios, Elaine M","sky")
 D ITEM^MIOUIBILL(.TCTX,1,1,"Name","Rios, Elaine M")
 D ITEM^MIOUIBILL(.TCTX,1,2,"Member ID","MBR842175")
 D ITEM^MIOUIBILL(.TCTX,1,3,"Gender","Female")
 D ITEM^MIOUIBILL(.TCTX,1,4,"Date of Birth","September 12, 1978 (47 years old)")
 D ITEM^MIOUIBILL(.TCTX,1,5,"Address","88 Cedar Valley Rd Hudson, OH 44236")
 D ITEM^MIOUIBILL(.TCTX,1,6,"Payer Sequence","Primary")
 D ITEM^MIOUIBILL(.TCTX,1,7,"Insurance Plan Type","Commercial PPO")
 D ITEM^MIOUIBILL(.TCTX,1,8,"Business Name","North Harbor Health Plan")
 D ITEM^MIOUIBILL(.TCTX,1,9,"Plan ID","NHP442901")
 D SECTION^MIOUIBILL(.TCTX,2,"Payer","Plan ID: NHP442901 - Name: North Harbor Health Plan","emerald")
 D ITEM^MIOUIBILL(.TCTX,2,1,"Business Name","North Harbor Health Plan")
 D ITEM^MIOUIBILL(.TCTX,2,2,"Plan ID","NHP442901")
 D SECTION^MIOUIBILL(.TCTX,3,"Diagnoses (J18.9, Z79.2, T36.95XA)","Primary respiratory diagnosis plus medication therapy context.","amber")
 D ITEM^MIOUIBILL(.TCTX,3,1,"Code","J18.9")
 D ITEM^MIOUIBILL(.TCTX,3,2,"Description","Pneumonia, unspecified organism")
 D ITEM^MIOUIBILL(.TCTX,3,3,"Code","Z79.2")
 D ITEM^MIOUIBILL(.TCTX,3,4,"Description","Long term (current) use of antibiotics")
 D ITEM^MIOUIBILL(.TCTX,3,5,"Code","T36.95XA")
 D ITEM^MIOUIBILL(.TCTX,3,6,"Description","Adverse effect of other systemic antibiotics, initial encounter")
 D SECTION^MIOUIBILL(.TCTX,4,"Billing Provider","NPI: 1467082351 - Name: Summit Home Infusion Group","violet")
 D ITEM^MIOUIBILL(.TCTX,4,1,"Business Name","Summit Home Infusion Group")
 D ITEM^MIOUIBILL(.TCTX,4,2,"NPI","1467082351")
 D ITEM^MIOUIBILL(.TCTX,4,3,"Employer's Identification Number","20-5567812")
 D ITEM^MIOUIBILL(.TCTX,4,4,"Address","410 Meridian Park Dr Columbus, OH 43215")
 D ITEM^MIOUIBILL(.TCTX,4,5,"Contact Name","Maya Patel")
 D ITEM^MIOUIBILL(.TCTX,4,6,"Telephone","6145550184")
 D SECTION^MIOUIBILL(.TCTX,5,"Submitter","ETIN: 731845902 - Name: Northlight Revenue Partners","sky")
 D ITEM^MIOUIBILL(.TCTX,5,1,"Business Name","Northlight Revenue Partners")
 D ITEM^MIOUIBILL(.TCTX,5,2,"ETIN","731845902")
 D ITEM^MIOUIBILL(.TCTX,5,3,"Contact Name","Avery Sloan")
 D ITEM^MIOUIBILL(.TCTX,5,4,"Telephone","6145554401")
 D SECTION^MIOUIBILL(.TCTX,6,"Receiver","ETIN: 442781593 - Name: Harbor Claims Gateway","slate")
 D ITEM^MIOUIBILL(.TCTX,6,1,"Business Name","Harbor Claims Gateway")
 D ITEM^MIOUIBILL(.TCTX,6,2,"ETIN","442781593")
 D SECTION^MIOUIBILL(.TCTX,7,"EDI Transaction Info","Control Number: 58274","emerald")
 D ITEM^MIOUIBILL(.TCTX,7,1,"Control Number","58274")
 D ITEM^MIOUIBILL(.TCTX,7,2,"Creation Date and Time","2026-02-18, 08:14 AM")
 D ITEM^MIOUIBILL(.TCTX,7,3,"Loaded Date and Time","2026-02-18, 08:19 AM")
 D ITEM^MIOUIBILL(.TCTX,7,4,"Transaction Type","837P")
 D ITEM^MIOUIBILL(.TCTX,7,5,"Claim or Encounter Type","Chargeable")
 D ITEM^MIOUIBILL(.TCTX,7,6,"Originator Transaction ID","0048")
 D SECTION^MIOUIBILL(.TCTX,8,"EDI File Info","Inbound file facts for trace and replay.","slate")
 D ITEM^MIOUIBILL(.TCTX,8,1,"File Name","daily/home-infusion-batch-0211.837")
 D ITEM^MIOUIBILL(.TCTX,8,2,"Last Modified Date and Time","2026-02-18, 07:58 AM")
 D ITEM^MIOUIBILL(.TCTX,8,3,"File's Url","/staging/inbox/home-infusion-batch-0211.837")
 Q
 ;
NOTES(TCTX)
 D NOTE^MIOUIBILL(.TCTX,1,"Scan anchor","Keep the claim facts bar compact so the operator can pin claim ID, charge, and service dates while reviewing deeper party and EDI detail.","sky")
 D NOTE^MIOUIBILL(.TCTX,2,"Route confidence","Payer, billing provider, submitter, and receiver stay in their own cards so routing questions do not compete with patient and diagnosis review.","emerald")
 D NOTE^MIOUIBILL(.TCTX,3,"Raw trace","The X12 explorer mirrors loop names and segment ordering so a reviewer can validate the rendered claim view against the source transaction without leaving the page.","amber")
 Q
 ;
TXNS(TCTX)
 D TXN^MIOUIBILL(.TCTX,1,"Line 1 (S9500)","Charge Amount: $1,260.00 - Units: 7","emerald")
 D TXNFACT^MIOUIBILL(.TCTX,1,1,"Charge Amt","$1,260.00")
 D TXNFACT^MIOUIBILL(.TCTX,1,2,"Units","7")
 D TXNFACT^MIOUIBILL(.TCTX,1,3,"Place of Service","12 - Home Health")
 D TXNFACT^MIOUIBILL(.TCTX,1,4,"Service Dates","2026-02-11 - 2026-02-17 (7 days)")
 D TXNCODE^MIOUIBILL(.TCTX,1,"HCPCS Procedure (S9500)","S9500","Home infusion therapy, anti-infective regimen, once every 24 hours, including pharmacy coordination and supplies.")
 D TXNDIAG^MIOUIBILL(.TCTX,1,"Related Diagnosis (J18.9)","J18.9","Pneumonia, unspecified organism")
 D TXNPROV^MIOUIBILL(.TCTX,1,"Ordering Provider NPI: 1831749028 Name: Cross, Imani","Cross, Imani","1831749028")
 D TXN^MIOUIBILL(.TCTX,2,"Line 2 (A4223)","Charge Amount: $726.40 - Units: 7","sky")
 D TXNFACT^MIOUIBILL(.TCTX,2,1,"Charge Amt","$726.40")
 D TXNFACT^MIOUIBILL(.TCTX,2,2,"Units","7")
 D TXNFACT^MIOUIBILL(.TCTX,2,3,"Place of Service","12 - Home Health")
 D TXNFACT^MIOUIBILL(.TCTX,2,4,"Service Dates","2026-02-11 - 2026-02-17 (7 days)")
 D TXNCODE^MIOUIBILL(.TCTX,2,"HCPCS Procedure (A4223)","A4223","Infusion supplies for home administration, per diem billing unit with tubing, connectors, and pump-ready setup.")
 D TXNDIAG^MIOUIBILL(.TCTX,2,"Related Diagnosis (Z79.2)","Z79.2","Long term (current) use of antibiotics")
 D TXNPROV^MIOUIBILL(.TCTX,2,"Ordering Provider NPI: 1831749028 Name: Cross, Imani","Cross, Imani","1831749028")
 D TXN^MIOUIBILL(.TCTX,3,"Line 3 (S5000)","Charge Amount: $214.00 - Units: 14","amber")
 D TXNFACT^MIOUIBILL(.TCTX,3,1,"Charge Amt","$214.00")
 D TXNFACT^MIOUIBILL(.TCTX,3,2,"Units","14")
 D TXNFACT^MIOUIBILL(.TCTX,3,3,"Place of Service","12 - Home Health")
 D TXNFACT^MIOUIBILL(.TCTX,3,4,"Service Dates","2026-02-11 - 2026-02-17 (7 days)")
 D TXNCODE^MIOUIBILL(.TCTX,3,"HCPCS Procedure (S5000)","S5000","Prescription drug, generic oral, non-self-administered, by report.")
 D TXNDIAG^MIOUIBILL(.TCTX,3,"Related Diagnosis (T36.95XA)","T36.95XA","Adverse effect of other systemic antibiotics, initial encounter")
 D TXNPROV^MIOUIBILL(.TCTX,3,"Ordering Provider NPI: 1831749028 Name: Cross, Imani","Cross, Imani","1831749028")
 Q
 ;
X12(TCTX)
 D X12META^MIOUIBILL(.TCTX,12,36,"58274","837P")
 D X12LOOP^MIOUIBILL(.TCTX,1,"Transaction Set Header","0000","Root",1,"slate")
 D X12SEG^MIOUIBILL(.TCTX,1,1,"ST","837 58274 005010X222A1","ST*837*58274*005010X222A1~","Transaction set header")
 D X12SEG^MIOUIBILL(.TCTX,1,2,"BHT","0019 00 0048 20260218 0814 CH","BHT*0019*00*0048*20260218*0814*CH~","Beginning of hierarchical transaction")
 D X12SEG^MIOUIBILL(.TCTX,1,3,"SE","36 58274","SE*36*58274~","Transaction set trailer")
 D X12LOOP^MIOUIBILL(.TCTX,2,"Submitter Name","1000A","Transaction Set Header, Loop: 0000",1,"sky")
 D X12SEG^MIOUIBILL(.TCTX,2,1,"NM1","41 2 Northlight Revenue Partners 46 731845902","NM1*41*2*Northlight Revenue Partners*****46*731845902~","Submitter identifier")
 D X12SEG^MIOUIBILL(.TCTX,2,2,"PER","IC Avery Sloan TE 6145554401","PER*IC*Avery Sloan*TE*6145554401~","Submitter contact")
 D X12LOOP^MIOUIBILL(.TCTX,3,"Receiver Name","1000B","Transaction Set Header, Loop: 0000",1,"slate")
 D X12SEG^MIOUIBILL(.TCTX,3,1,"NM1","40 2 Harbor Claims Gateway 46 442781593","NM1*40*2*Harbor Claims Gateway*****46*442781593~","Receiver identifier")
 D X12LOOP^MIOUIBILL(.TCTX,4,"Billing Provider Hierarchical Level","2000A","Transaction Set Header, Loop: 0000",1,"amber")
 D X12SEG^MIOUIBILL(.TCTX,4,1,"HL","1 20 1","HL*1**20*1~","Billing provider hierarchy")
 D X12LOOP^MIOUIBILL(.TCTX,5,"Billing Provider Name","2010AA","Transaction Set Header, Loop: 0000",1,"violet")
 D X12SEG^MIOUIBILL(.TCTX,5,1,"NM1","85 2 Summit Home Infusion Group XX 1467082351","NM1*85*2*Summit Home Infusion Group*****XX*1467082351~","Billing provider NPI")
 D X12SEG^MIOUIBILL(.TCTX,5,2,"N3","410 Meridian Park Dr","N3*410 Meridian Park Dr~","Billing provider street")
 D X12SEG^MIOUIBILL(.TCTX,5,3,"N4","Columbus OH 43215","N4*Columbus*OH*43215~","Billing provider city state zip")
 D X12SEG^MIOUIBILL(.TCTX,5,4,"REF","EI 20-5567812","REF*EI*20-5567812~","Employer identification number")
 D X12SEG^MIOUIBILL(.TCTX,5,5,"PER","IC Maya Patel TE 6145550184","PER*IC*Maya Patel*TE*6145550184~","Billing provider contact")
 D X12LOOP^MIOUIBILL(.TCTX,6,"Subscriber Hierarchical Level","2000B","Transaction Set Header, Loop: 0000",1,"sky")
 D X12SEG^MIOUIBILL(.TCTX,6,1,"HL","2 1 22 0","HL*2*1*22*0~","Subscriber hierarchy")
 D X12LOOP^MIOUIBILL(.TCTX,7,"Subscriber Name","2010BA","Subscriber Information, Loop: 2000B",1,"emerald")
 D X12SEG^MIOUIBILL(.TCTX,7,1,"SBR","P 18 GRP442901 CI","SBR*P*18*GRP442901******CI~","Subscriber relationship and group")
 D X12SEG^MIOUIBILL(.TCTX,7,2,"NM1","IL 1 Rios Elaine M MI MBR842175","NM1*IL*1*Rios*Elaine*M***MI*MBR842175~","Subscriber identifier")
 D X12SEG^MIOUIBILL(.TCTX,7,3,"N3","88 Cedar Valley Rd","N3*88 Cedar Valley Rd~","Subscriber street")
 D X12SEG^MIOUIBILL(.TCTX,7,4,"N4","Hudson OH 44236","N4*Hudson*OH*44236~","Subscriber city state zip")
 D X12SEG^MIOUIBILL(.TCTX,7,5,"DMG","D8 19780912 F","DMG*D8*19780912*F~","Subscriber demographics")
 D X12LOOP^MIOUIBILL(.TCTX,8,"Payer Name","2010BB","Subscriber Information, Loop: 2000B",1,"slate")
 D X12SEG^MIOUIBILL(.TCTX,8,1,"NM1","PR 2 North Harbor Health Plan XV NHP442901","NM1*PR*2*North Harbor Health Plan*****XV*NHP442901~","Payer identifier")
 D X12LOOP^MIOUIBILL(.TCTX,9,"Claim Information","2300","Subscriber Information, Loop: 2000B",1,"amber")
 D X12SEG^MIOUIBILL(.TCTX,9,1,"CLM","CLMNO58274 1986.40 12 B 1 Y A Y Y","CLM*CLMNO58274*1986.40***12:B:1*Y*A*Y*Y~","Claim header")
 D X12SEG^MIOUIBILL(.TCTX,9,2,"HI","ABK J189 ABF Z792 ABF T3695XA","HI*ABK:J189*ABF:Z792*ABF:T3695XA~","Diagnosis codes")
 D X12LOOP^MIOUIBILL(.TCTX,10,"Service Line","2400","Claim Information, Loop: 2300",1,"amber")
 D X12SEG^MIOUIBILL(.TCTX,10,1,"LX","1","LX*1~","Service line counter")
 D X12SEG^MIOUIBILL(.TCTX,10,2,"SV1","HC S9500 1260.00 UN 7 12 1","SV1*HC:S9500*1260.00*UN*7*12**1~","First service line")
 D X12SEG^MIOUIBILL(.TCTX,10,3,"DTP","472 RD8 20260211-20260217","DTP*472*RD8*20260211-20260217~","First service line dates")
 D X12SEG^MIOUIBILL(.TCTX,10,4,"LX","2","LX*2~","Second service line counter")
 D X12SEG^MIOUIBILL(.TCTX,10,5,"SV1","HC A4223 726.40 UN 7 12 1","SV1*HC:A4223*726.40*UN*7*12**1~","Second service line")
 D X12SEG^MIOUIBILL(.TCTX,10,6,"DTP","472 RD8 20260211-20260217","DTP*472*RD8*20260211-20260217~","Second service line dates")
 D X12SEG^MIOUIBILL(.TCTX,10,7,"LX","3","LX*3~","Third service line counter")
 D X12SEG^MIOUIBILL(.TCTX,10,8,"SV1","HC S5000 214.00 UN 14 12 1","SV1*HC:S5000*214.00*UN*14*12**1~","Third service line")
 D X12SEG^MIOUIBILL(.TCTX,10,9,"DTP","472 RD8 20260211-20260217","DTP*472*RD8*20260211-20260217~","Third service line dates")
 D X12LOOP^MIOUIBILL(.TCTX,11,"Drug Identification","2410","Service Line, Loop: 2400",1,"violet")
 D X12SEG^MIOUIBILL(.TCTX,11,1,"LIN","N4 00003161201","LIN*N4*00003161201~","Drug identifier 1")
 D X12SEG^MIOUIBILL(.TCTX,11,2,"CTP","XZ 2530001 1260.00","CTP**XZ*2530001*1260.00~","Drug pricing 1")
 D X12SEG^MIOUIBILL(.TCTX,11,3,"LIN","N4 63323025510","LIN*N4*63323025510~","Drug identifier 2")
 D X12SEG^MIOUIBILL(.TCTX,11,4,"CTP","XZ 2530002 67.69","CTP**XZ*2530002*67.69~","Drug pricing 2")
 D X12SEG^MIOUIBILL(.TCTX,11,5,"LIN","N4 08290326810","LIN*N4*08290326810~","Drug identifier 3")
 D X12SEG^MIOUIBILL(.TCTX,11,6,"CTP","XZ 2530003 57.12","CTP**XZ*2530003*57.12~","Drug pricing 3")
 D X12LOOP^MIOUIBILL(.TCTX,12,"Ordering Provider Name","2420E","Service Line, Loop: 2400",1,"violet")
 D X12SEG^MIOUIBILL(.TCTX,12,1,"NM1","DK 1 Cross Imani XX 1831749028","NM1*DK*1*Cross*Imani****XX*1831749028~","Ordering provider")
 Q
 ;
