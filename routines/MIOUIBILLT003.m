MIOUIBILLT003 ; Reference element coverage for all billing patient variants
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T100(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIBILLT003"
 I LOCAL S FAIL=1
 Q
 ;
T100(FAIL)
 N CONF,REQ,CTX,TCTX,OUT1,OUT2,OUT3,ERR1,ERR2,ERR3,TOK
 D CONFDEF^MIOUI(.CONF)
 D BUILD^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_patient_review.html",.CONF,.CTX,.TCTX,.OUT1,.ERR1)
 D EQ^MIOUIT000(.FAIL,"[T100][base render]",$D(ERR1),0)
 D BUILDD^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_patient_review_dense.html",.CONF,.CTX,.TCTX,.OUT2,.ERR2)
 D EQ^MIOUIT000(.FAIL,"[T100][dense render]",$D(ERR2),0)
 D BUILDB^MIOUIBILLD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_patient_review_balanced.html",.CONF,.CTX,.TCTX,.OUT3,.ERR3)
 D EQ^MIOUIT000(.FAIL,"[T100][balanced render]",$D(ERR3),0)
 D CLAIMS(.TOK)
 D CHECK(.FAIL,"[T100][claims][base]",OUT1,.TOK)
 D CHECK(.FAIL,"[T100][claims][dense]",OUT2,.TOK)
 D CHECK(.FAIL,"[T100][claims][balanced]",OUT3,.TOK)
 K TOK D TXNS(.TOK)
 D CHECK(.FAIL,"[T100][txns][base]",OUT1,.TOK)
 D CHECK(.FAIL,"[T100][txns][dense]",OUT2,.TOK)
 D CHECK(.FAIL,"[T100][txns][balanced]",OUT3,.TOK)
 K TOK D X12(.TOK)
 D CHECK(.FAIL,"[T100][x12][base]",OUT1,.TOK)
 D CHECK(.FAIL,"[T100][x12][dense]",OUT2,.TOK)
 D CHECK(.FAIL,"[T100][x12][balanced]",OUT3,.TOK)
 Q
 ;
CHECK(FAIL,PREFIX,OUT,TOK)
 N I
 S I=""
 F  S I=$O(TOK(I)) Q:I=""  D HAS^MIOUIT000(.FAIL,PREFIX_"["_I_"]",OUT,TOK(I))
 Q
 ;
CLAIMS(TOK)
 S TOK(1)="Expand All"
 S TOK(2)="Collapse All"
 S TOK(3)="Patient Ctrl Num (Claim ID)"
 S TOK(4)="Charge Amt"
 S TOK(5)="Place of Service"
 S TOK(6)="Frequency"
 S TOK(7)="Service Dates"
 S TOK(8)="Provider Signature Indicator"
 S TOK(9)="Assignment Participation Code"
 S TOK(10)="Benefits Assignment Indicator"
 S TOK(11)="Release of Information Code"
 S TOK(12)="Key Info"
 S TOK(13)="Name"
 S TOK(14)="Member ID"
 S TOK(15)="Gender"
 S TOK(16)="Date of Birth"
 S TOK(17)="Address"
 S TOK(18)="Payer Sequence"
 S TOK(19)="Insurance Plan Type"
 S TOK(20)="Business Name"
 S TOK(21)="Plan ID"
 S TOK(22)="Payer"
 S TOK(23)="Insured Subscriber (Self, Primary)"
 S TOK(24)="Code"
 S TOK(25)="Description"
 S TOK(26)="Diagnoses"
 S TOK(27)="NPI"
 S TOK(28)="Employer's Identification Number"
 S TOK(29)="Contact Name"
 S TOK(30)="Telephone"
 S TOK(31)="Billing Provider"
 S TOK(32)="ETIN"
 S TOK(33)="Submitter"
 S TOK(34)="Receiver"
 S TOK(35)="Control Number"
 S TOK(36)="Creation Date and Time"
 S TOK(37)="Loaded Date and Time"
 S TOK(38)="Transaction Type"
 S TOK(39)="Claim or Encounter Type"
 S TOK(40)="Originator Transaction ID"
 S TOK(41)="EDI Transaction Info"
 S TOK(42)="File Name"
 S TOK(43)="Last Modified Date and Time"
 S TOK(44)="File's Url"
 S TOK(45)="EDI File Info"
 Q
 ;
TXNS(TOK)
 S TOK(1)="Charge Amt"
 S TOK(2)="Units"
 S TOK(3)="Place of Service"
 S TOK(4)="Service Dates"
 S TOK(5)="Code"
 S TOK(6)="Description"
 S TOK(7)="HCPCS Procedure (S9500)"
 S TOK(8)="HCPCS Procedure (A4223)"
 S TOK(9)="HCPCS Procedure (S5000)"
 S TOK(10)="Related Diagnosis (J18.9)"
 S TOK(11)="Related Diagnosis (Z79.2)"
 S TOK(12)="Related Diagnosis (T36.95XA)"
 S TOK(13)="Ordering Provider"
 S TOK(14)="NPI:"
 S TOK(15)="Name:"
 S TOK(16)="Line 1 (S9500)"
 S TOK(17)="Charge Amount:"
 S TOK(18)="Units:"
 Q
 ;
X12(TOK)
 S TOK(1)="ST"
 S TOK(2)="BHT"
 S TOK(3)="SE"
 S TOK(4)="NM1"
 S TOK(5)="PER"
 S TOK(6)="HL"
 S TOK(7)="N3"
 S TOK(8)="N4"
 S TOK(9)="REF"
 S TOK(10)="SBR"
 S TOK(11)="DMG"
 S TOK(12)="CLM"
 S TOK(13)="HI"
 S TOK(14)="LX"
 S TOK(15)="SV1"
 S TOK(16)="DTP"
 S TOK(17)="LIN"
 S TOK(18)="CTP"
 S TOK(19)="Submitter Name"
 S TOK(20)="Loop: 1000A"
 S TOK(21)="Parent: Transaction Set Header, Loop: 0000"
 S TOK(22)="Receiver Name"
 S TOK(23)="Loop: 1000B"
 S TOK(24)="Billing Provider Hierarchical Level"
 S TOK(25)="Loop: 2000A"
 S TOK(26)="Billing Provider Name"
 S TOK(27)="Loop: 2010AA"
 S TOK(28)="Subscriber Hierarchical Level"
 S TOK(29)="Loop: 2000B"
 S TOK(30)="Subscriber Name"
 S TOK(31)="Loop: 2010BA"
 S TOK(32)="Parent: Subscriber Information, Loop: 2000B"
 S TOK(33)="Payer Name"
 S TOK(34)="Loop: 2010BB"
 S TOK(35)="Subscriber Information"
 S TOK(36)="Claim Information"
 S TOK(37)="Loop: 2300"
 S TOK(38)="Service Line"
 S TOK(39)="Loop: 2400"
 S TOK(40)="Parent: Claim Information, Loop: 2300"
 S TOK(41)="Ordering Provider Name"
 S TOK(42)="Loop: 2420E"
 S TOK(43)="Parent: Service Line, Loop: 2400"
 S TOK(44)="Drug Identification"
 S TOK(45)="Loop: 2410"
 S TOK(46)="Transaction Set Header"
 S TOK(47)="Loop: 0000"
 Q
 ;
