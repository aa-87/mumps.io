MIOUIBILL ; Patient-oriented billing UI builders
 Q
 ;
HEADER(TCTX,CLAIMID,PATIENT,PAYER,STATUS,TONE)
 S TCTX("billHeader","claimId")=$G(CLAIMID)
 S TCTX("billHeader","patient")=$G(PATIENT)
 S TCTX("billHeader","payer")=$G(PAYER)
 S TCTX("billHeader","status")=$G(STATUS)
 S TCTX("billHeader","badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billHeader","panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
FACT(TCTX,IDX,LABEL,VALUE)
 N N
 S N=+$G(IDX)
 S TCTX("billFact",N,"label")=$G(LABEL)
 S TCTX("billFact",N,"value")=$G(VALUE)
 Q
 ;
SECTION(TCTX,IDX,TITLE,SUMMARY,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billSection",N,"idx")=N
 S TCTX("billSection",N,"title")=$G(TITLE)
 S TCTX("billSection",N,"summary")=$G(SUMMARY)
 S TCTX("billSection",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billSection",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
ITEM(TCTX,SECTION,IDX,LABEL,VALUE)
 N S,N
 S S=+$G(SECTION),N=+$G(IDX)
 S TCTX("billSection",S,"item",N,"label")=$G(LABEL)
 S TCTX("billSection",S,"item",N,"value")=$G(VALUE)
 S TCTX("billSection",S,"hasItems")=1
 Q
 ;
NOTE(TCTX,IDX,TITLE,BODY,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billNote",N,"title")=$G(TITLE)
 S TCTX("billNote",N,"body")=$G(BODY)
 S TCTX("billNote",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billNote",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
TXN(TCTX,IDX,TITLE,STATUS,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billTxn",N,"title")=$G(TITLE)
 S TCTX("billTxn",N,"status")=$G(STATUS)
 S TCTX("billTxn",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billTxn",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
TXNFACT(TCTX,TXN,IDX,LABEL,VALUE)
 N T,N
 S T=+$G(TXN),N=+$G(IDX)
 S TCTX("billTxn",T,"fact",N,"label")=$G(LABEL)
 S TCTX("billTxn",T,"fact",N,"value")=$G(VALUE)
 Q
 ;
TXNCODE(TCTX,TXN,TITLE,CODE,DESC)
 N T
 S T=+$G(TXN)
 S TCTX("billTxn",T,"codeTitle")=$G(TITLE)
 S TCTX("billTxn",T,"code")=$G(CODE)
 S TCTX("billTxn",T,"codeDesc")=$G(DESC)
 Q
 ;
TXNDIAG(TCTX,TXN,TITLE,CODE,DESC)
 N T
 S T=+$G(TXN)
 S TCTX("billTxn",T,"diagTitle")=$G(TITLE)
 S TCTX("billTxn",T,"diagCode")=$G(CODE)
 S TCTX("billTxn",T,"diagDesc")=$G(DESC)
 Q
 ;
TXNPROV(TCTX,TXN,TITLE,NAME,NPI)
 N T
 S T=+$G(TXN)
 S TCTX("billTxn",T,"providerTitle")=$G(TITLE)
 S TCTX("billTxn",T,"providerName")=$G(NAME)
 S TCTX("billTxn",T,"providerNpi")=$G(NPI)
 Q
 ;
X12META(TCTX,TOTALLOOPS,TOTALSEGS,CTRL,TYPE)
 S TCTX("billX12","totalLoops")=+$G(TOTALLOOPS)
 S TCTX("billX12","totalSegments")=+$G(TOTALSEGS)
 S TCTX("billX12","controlNumber")=$G(CTRL)
 S TCTX("billX12","transactionType")=$G(TYPE)
 Q
 ;
X12LOOP(TCTX,IDX,TITLE,LOOP,PARENT,OPEN,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billX12","loop",N,"idx")=N
 S TCTX("billX12","loop",N,"title")=$G(TITLE)
 S TCTX("billX12","loop",N,"loop")=$G(LOOP)
 S TCTX("billX12","loop",N,"parent")=$G(PARENT)
 S TCTX("billX12","loop",N,"isOpen")=+$G(OPEN)
 S TCTX("billX12","loop",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 Q
 ;
X12SEG(TCTX,LOOP,IDX,SEG,PARSED,RAW,NOTE)
 N L,N
 S L=+$G(LOOP),N=+$G(IDX)
 S TCTX("billX12","loop",L,"segment",N,"seg")=$G(SEG)
 S TCTX("billX12","loop",L,"segment",N,"parsed")=$G(PARSED)
 S TCTX("billX12","loop",L,"segment",N,"raw")=$G(RAW)
 S TCTX("billX12","loop",L,"segment",N,"note")=$G(NOTE)
 S TCTX("billX12","loop",L,"segmentCount")=$G(TCTX("billX12","loop",L,"segmentCount"))+1
 Q
 ;
