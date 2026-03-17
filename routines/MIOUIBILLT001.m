MIOUIBILLT001 ; Builder contract tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIBILLT001"
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N TCTX
 D HEADER^MIOUIBILL(.TCTX,"CLMNO58274","Rios, Elaine M","North Harbor Health Plan","Ready for review","sky")
 D FACT^MIOUIBILL(.TCTX,1,"Patient Ctrl Num (Claim ID)","CLMNO58274")
 D SECTION^MIOUIBILL(.TCTX,1,"Receiver","ETIN: 442781593 - Name: Harbor Claims Gateway","slate")
 D ITEM^MIOUIBILL(.TCTX,1,1,"Business Name","Harbor Claims Gateway")
 D TXN^MIOUIBILL(.TCTX,1,"Line 1 (S9500)","Charge Amount: $1,260.00 - Units: 7","emerald")
 D TXNFACT^MIOUIBILL(.TCTX,1,1,"Charge Amt","$1,260.00")
 D TXNCODE^MIOUIBILL(.TCTX,1,"HCPCS Procedure (S9500)","S9500","Home infusion therapy per diem")
 D TXNDIAG^MIOUIBILL(.TCTX,1,"Related Diagnosis (J18.9)","J18.9","Pneumonia, unspecified organism")
 D TXNPROV^MIOUIBILL(.TCTX,1,"Ordering Provider NPI: 1831749028 Name: Cross, Imani","Cross, Imani","1831749028")
 D X12META^MIOUIBILL(.TCTX,9,25,"58274","837P")
 D X12LOOP^MIOUIBILL(.TCTX,1,"Submitter Name","1000A","Transaction Set Header / 0000",1,"sky")
 D X12SEG^MIOUIBILL(.TCTX,1,1,"NM1","41 2 Northlight Revenue Partners 46 731845902","NM1*41*2*Northlight Revenue Partners*****46*731845902~","Submitter identifier")
 D EQ^MIOUIT000(.FAIL,"[T001][header claim]",$G(TCTX("billHeader","claimId")),"CLMNO58274")
 D EQ^MIOUIT000(.FAIL,"[T001][header badge]",$G(TCTX("billHeader","badgeClass")),"badge-sky")
 D EQ^MIOUIT000(.FAIL,"[T001][fact label]",$G(TCTX("billFact",1,"label")),"Patient Ctrl Num (Claim ID)")
 D EQ^MIOUIT000(.FAIL,"[T001][section title]",$G(TCTX("billSection",1,"title")),"Receiver")
 D EQ^MIOUIT000(.FAIL,"[T001][section value]",$G(TCTX("billSection",1,"item",1,"value")),"Harbor Claims Gateway")
 D EQ^MIOUIT000(.FAIL,"[T001][txn status]",$G(TCTX("billTxn",1,"status")),"Charge Amount: $1,260.00 - Units: 7")
 D EQ^MIOUIT000(.FAIL,"[T001][txn code]",$G(TCTX("billTxn",1,"code")),"S9500")
 D EQ^MIOUIT000(.FAIL,"[T001][txn provider]",$G(TCTX("billTxn",1,"providerNpi")),"1831749028")
 D EQ^MIOUIT000(.FAIL,"[T001][x12 ctrl]",$G(TCTX("billX12","controlNumber")),"58274")
 D EQ^MIOUIT000(.FAIL,"[T001][x12 loop]",$G(TCTX("billX12","loop",1,"loop")),"1000A")
 D EQ^MIOUIT000(.FAIL,"[T001][x12 seg raw]",$G(TCTX("billX12","loop",1,"segment",1,"raw")),"NM1*41*2*Northlight Revenue Partners*****46*731845902~")
 Q
 ;
