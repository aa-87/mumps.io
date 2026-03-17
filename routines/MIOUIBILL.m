MIOUIBILL ; Patient-oriented billing and reporting UI builders
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
RPTHDR(TCTX,TITLE,PERIOD,STATUS,TONE)
 S TCTX("billReport","header","title")=$G(TITLE)
 S TCTX("billReport","header","period")=$G(PERIOD)
 S TCTX("billReport","header","status")=$G(STATUS)
 S TCTX("billReport","header","badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReport","header","panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTFILTER(TCTX,IDX,LABEL,VALUE)
 N N
 S N=+$G(IDX)
 S TCTX("billReport","filter",N,"label")=$G(LABEL)
 S TCTX("billReport","filter",N,"value")=$G(VALUE)
 Q
 ;
RPTKPI(TCTX,IDX,LABEL,VALUE,DELTA,NOTE,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReport","kpi",N,"label")=$G(LABEL)
 S TCTX("billReport","kpi",N,"value")=$G(VALUE)
 S TCTX("billReport","kpi",N,"delta")=$G(DELTA)
 S TCTX("billReport","kpi",N,"note")=$G(NOTE)
 S TCTX("billReport","kpi",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReport","kpi",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTTAB(TCTX,IDX,KEY,LABEL,COUNT,ACTIVE)
 N N
 S N=+$G(IDX)
 S TCTX("billReport","tab",N,"key")=$G(KEY)
 S TCTX("billReport","tab",N,"label")=$G(LABEL)
 S TCTX("billReport","tab",N,"count")=+$G(COUNT)
 S TCTX("billReport","tab",N,"isActive")=+$G(ACTIVE)
 Q
 ;
RPTAGING(TCTX,IDX,BUCKET,AMOUNT,CLAIMS,PCT,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReport","aging",N,"bucket")=$G(BUCKET)
 S TCTX("billReport","aging",N,"amount")=$G(AMOUNT)
 S TCTX("billReport","aging",N,"claims")=$G(CLAIMS)
 S TCTX("billReport","aging",N,"percent")=$G(PCT)
 S TCTX("billReport","aging",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 Q
 ;
RPTPAYER(TCTX,IDX,PAYER,SUBMITTED,PAID,DENIED,DAYS,VAR,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReport","payer",N,"payer")=$G(PAYER)
 S TCTX("billReport","payer",N,"submitted")=$G(SUBMITTED)
 S TCTX("billReport","payer",N,"paid")=$G(PAID)
 S TCTX("billReport","payer",N,"denied")=$G(DENIED)
 S TCTX("billReport","payer",N,"days")=$G(DAYS)
 S TCTX("billReport","payer",N,"variance")=$G(VAR)
 S TCTX("billReport","payer",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 Q
 ;
RPTREASON(TCTX,IDX,REASON,COUNT,AMOUNT,ACTION,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReport","reason",N,"reason")=$G(REASON)
 S TCTX("billReport","reason",N,"count")=$G(COUNT)
 S TCTX("billReport","reason",N,"amount")=$G(AMOUNT)
 S TCTX("billReport","reason",N,"action")=$G(ACTION)
 S TCTX("billReport","reason",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReport","reason",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTEXPORT(TCTX,IDX,NAME,FMT,SCHED,DEST,STATUS,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReport","export",N,"name")=$G(NAME)
 S TCTX("billReport","export",N,"format")=$G(FMT)
 S TCTX("billReport","export",N,"schedule")=$G(SCHED)
 S TCTX("billReport","export",N,"destination")=$G(DEST)
 S TCTX("billReport","export",N,"status")=$G(STATUS)
 S TCTX("billReport","export",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReport","export",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTFLAG(TCTX,IDX,TITLE,BODY,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReport","flag",N,"title")=$G(TITLE)
 S TCTX("billReport","flag",N,"body")=$G(BODY)
 S TCTX("billReport","flag",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReport","flag",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;

RPTQUEUE(TCTX,IDX,TITLE,OWNER,OPEN,AMOUNT,SLA,NOTE,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportDense","queue",N,"title")=$G(TITLE)
 S TCTX("billReportDense","queue",N,"owner")=$G(OWNER)
 S TCTX("billReportDense","queue",N,"open")=$G(OPEN)
 S TCTX("billReportDense","queue",N,"amount")=$G(AMOUNT)
 S TCTX("billReportDense","queue",N,"sla")=$G(SLA)
 S TCTX("billReportDense","queue",N,"note")=$G(NOTE)
 S TCTX("billReportDense","queue",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportDense","queue",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTTREND(TCTX,IDX,LABEL,VALUE,PCT,NOTE,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportDense","trend",N,"label")=$G(LABEL)
 S TCTX("billReportDense","trend",N,"value")=$G(VALUE)
 S TCTX("billReportDense","trend",N,"percent")=$G(PCT)
 S TCTX("billReportDense","trend",N,"note")=$G(NOTE)
 S TCTX("billReportDense","trend",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportDense","trend",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTSTORY(TCTX,IDX,TITLE,BODY,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportExec","story",N,"title")=$G(TITLE)
 S TCTX("billReportExec","story",N,"body")=$G(BODY)
 S TCTX("billReportExec","story",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportExec","story",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTACTION(TCTX,IDX,TITLE,OWNER,DUE,BODY,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportExec","action",N,"title")=$G(TITLE)
 S TCTX("billReportExec","action",N,"owner")=$G(OWNER)
 S TCTX("billReportExec","action",N,"due")=$G(DUE)
 S TCTX("billReportExec","action",N,"body")=$G(BODY)
 S TCTX("billReportExec","action",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportExec","action",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
 ;

RPTMETER(TCTX,LABEL,VALUE,PCT,NOTE,TONE)
 S TCTX("billReportViz","meter","label")=$G(LABEL)
 S TCTX("billReportViz","meter","value")=$G(VALUE)
 S TCTX("billReportViz","meter","percent")=$G(PCT)
 S TCTX("billReportViz","meter","note")=$G(NOTE)
 S TCTX("billReportViz","meter","badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportViz","meter","panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 S TCTX("billReportViz","meter","ringColor")=$$RINGCLR($G(TONE))
 Q
 ;
RPTVCOL(TCTX,IDX,LABEL,VALUE,PCT,NOTE,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportViz","column",N,"label")=$G(LABEL)
 S TCTX("billReportViz","column",N,"value")=$G(VALUE)
 S TCTX("billReportViz","column",N,"percent")=$G(PCT)
 S TCTX("billReportViz","column",N,"note")=$G(NOTE)
 S TCTX("billReportViz","column",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportViz","column",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTVBAR(TCTX,IDX,LABEL,VALUE,PCT,NOTE,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportViz","bar",N,"label")=$G(LABEL)
 S TCTX("billReportViz","bar",N,"value")=$G(VALUE)
 S TCTX("billReportViz","bar",N,"percent")=$G(PCT)
 S TCTX("billReportViz","bar",N,"note")=$G(NOTE)
 S TCTX("billReportViz","bar",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportViz","bar",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTVSEG(TCTX,IDX,LABEL,VALUE,PCT,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportViz","segment",N,"label")=$G(LABEL)
 S TCTX("billReportViz","segment",N,"value")=$G(VALUE)
 S TCTX("billReportViz","segment",N,"percent")=$G(PCT)
 S TCTX("billReportViz","segment",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportViz","segment",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTVROW(TCTX,ROW,LABEL)
 N R
 S R=+$G(ROW)
 S TCTX("billReportViz","heat",R,"label")=$G(LABEL)
 Q
 ;
RPTVCELL(TCTX,ROW,COL,LABEL,VALUE,OPACITY,TONE)
 N R,C
 S R=+$G(ROW),C=+$G(COL)
 S TCTX("billReportViz","heat",R,"cell",C,"label")=$G(LABEL)
 S TCTX("billReportViz","heat",R,"cell",C,"value")=$G(VALUE)
 S TCTX("billReportViz","heat",R,"cell",C,"opacity")=$G(OPACITY)
 S TCTX("billReportViz","heat",R,"cell",C,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportViz","heat",R,"cell",C,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTVFUN(TCTX,IDX,LABEL,VALUE,PCT,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportViz","funnel",N,"label")=$G(LABEL)
 S TCTX("billReportViz","funnel",N,"value")=$G(VALUE)
 S TCTX("billReportViz","funnel",N,"percent")=$G(PCT)
 S TCTX("billReportViz","funnel",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportViz","funnel",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;

RPTVPROJ(TCTX,IDX,LABEL,VALUE,LOWP,COMMITP,STRETCHP,GOALP,NOTE,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportForecast","point",N,"label")=$G(LABEL)
 S TCTX("billReportForecast","point",N,"value")=$G(VALUE)
 S TCTX("billReportForecast","point",N,"lowPercent")=$G(LOWP)
 S TCTX("billReportForecast","point",N,"commitPercent")=$G(COMMITP)
 S TCTX("billReportForecast","point",N,"stretchPercent")=$G(STRETCHP)
 S TCTX("billReportForecast","point",N,"goalPercent")=$G(GOALP)
 S TCTX("billReportForecast","point",N,"note")=$G(NOTE)
 S TCTX("billReportForecast","point",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportForecast","point",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTVBRDG(TCTX,IDX,LABEL,VALUE,PCT,DIRECTION,NOTE,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportForecast","bridge",N,"label")=$G(LABEL)
 S TCTX("billReportForecast","bridge",N,"value")=$G(VALUE)
 S TCTX("billReportForecast","bridge",N,"percent")=$G(PCT)
 S TCTX("billReportForecast","bridge",N,"direction")=$G(DIRECTION)
 S TCTX("billReportForecast","bridge",N,"note")=$G(NOTE)
 S TCTX("billReportForecast","bridge",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportForecast","bridge",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTVSCN(TCTX,IDX,TITLE,CASH,FPR,AR,NOTE,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportForecast","scenario",N,"title")=$G(TITLE)
 S TCTX("billReportForecast","scenario",N,"cash")=$G(CASH)
 S TCTX("billReportForecast","scenario",N,"fpr")=$G(FPR)
 S TCTX("billReportForecast","scenario",N,"ar")=$G(AR)
 S TCTX("billReportForecast","scenario",N,"note")=$G(NOTE)
 S TCTX("billReportForecast","scenario",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportForecast","scenario",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTVBEN(TCTX,IDX,LABEL,INTERNAL,MEDIAN,TOP,POS,NOTE,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportBench","ladder",N,"label")=$G(LABEL)
 S TCTX("billReportBench","ladder",N,"internal")=$G(INTERNAL)
 S TCTX("billReportBench","ladder",N,"median")=$G(MEDIAN)
 S TCTX("billReportBench","ladder",N,"topQuartile")=$G(TOP)
 S TCTX("billReportBench","ladder",N,"position")=$G(POS)
 S TCTX("billReportBench","ladder",N,"note")=$G(NOTE)
 S TCTX("billReportBench","ladder",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportBench","ladder",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTVBROW(TCTX,ROW,LABEL)
 N R
 S R=+$G(ROW)
 S TCTX("billReportBench","matrix",R,"label")=$G(LABEL)
 Q
 ;
RPTVBCELL(TCTX,ROW,COL,LABEL,VALUE,OPACITY,TONE)
 N R,C
 S R=+$G(ROW),C=+$G(COL)
 S TCTX("billReportBench","matrix",R,"cell",C,"label")=$G(LABEL)
 S TCTX("billReportBench","matrix",R,"cell",C,"value")=$G(VALUE)
 S TCTX("billReportBench","matrix",R,"cell",C,"opacity")=$G(OPACITY)
 S TCTX("billReportBench","matrix",R,"cell",C,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportBench","matrix",R,"cell",C,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTVSCORE(TCTX,IDX,TITLE,SCORE,RANK,NOTE,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportBench","scorecard",N,"title")=$G(TITLE)
 S TCTX("billReportBench","scorecard",N,"score")=$G(SCORE)
 S TCTX("billReportBench","scorecard",N,"rank")=$G(RANK)
 S TCTX("billReportBench","scorecard",N,"note")=$G(NOTE)
 S TCTX("billReportBench","scorecard",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportBench","scorecard",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;

RPTCRUN(TCTX,IDX,LABEL,VALUE,PCT,NOTE,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportCash","run",N,"label")=$G(LABEL)
 S TCTX("billReportCash","run",N,"value")=$G(VALUE)
 S TCTX("billReportCash","run",N,"percent")=$G(PCT)
 S TCTX("billReportCash","run",N,"note")=$G(NOTE)
 S TCTX("billReportCash","run",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportCash","run",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTCMIX(TCTX,IDX,LABEL,VALUE,PCT,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportCash","mix",N,"label")=$G(LABEL)
 S TCTX("billReportCash","mix",N,"value")=$G(VALUE)
 S TCTX("billReportCash","mix",N,"percent")=$G(PCT)
 S TCTX("billReportCash","mix",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportCash","mix",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTCLAG(TCTX,IDX,LABEL,VALUE,PCT,NOTE,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportCash","lag",N,"label")=$G(LABEL)
 S TCTX("billReportCash","lag",N,"value")=$G(VALUE)
 S TCTX("billReportCash","lag",N,"percent")=$G(PCT)
 S TCTX("billReportCash","lag",N,"note")=$G(NOTE)
 S TCTX("billReportCash","lag",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportCash","lag",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTDSTREAM(TCTX,IDX,TITLE,OPENP,APPEALP,CLOSEDP,NOTE,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportDenial","stream",N,"title")=$G(TITLE)
 S TCTX("billReportDenial","stream",N,"openPercent")=$G(OPENP)
 S TCTX("billReportDenial","stream",N,"appealPercent")=$G(APPEALP)
 S TCTX("billReportDenial","stream",N,"closedPercent")=$G(CLOSEDP)
 S TCTX("billReportDenial","stream",N,"note")=$G(NOTE)
 S TCTX("billReportDenial","stream",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportDenial","stream",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTDROW(TCTX,ROW,LABEL)
 N R
 S R=+$G(ROW)
 S TCTX("billReportDenial","matrix",R,"label")=$G(LABEL)
 Q
 ;
RPTDCELL(TCTX,ROW,COL,LABEL,VALUE,OPACITY,TONE)
 N R,C
 S R=+$G(ROW),C=+$G(COL)
 S TCTX("billReportDenial","matrix",R,"cell",C,"label")=$G(LABEL)
 S TCTX("billReportDenial","matrix",R,"cell",C,"value")=$G(VALUE)
 S TCTX("billReportDenial","matrix",R,"cell",C,"opacity")=$G(OPACITY)
 S TCTX("billReportDenial","matrix",R,"cell",C,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportDenial","matrix",R,"cell",C,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTDAGE(TCTX,IDX,LABEL,VALUE,PCT,NOTE,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportDenial","ladder",N,"label")=$G(LABEL)
 S TCTX("billReportDenial","ladder",N,"value")=$G(VALUE)
 S TCTX("billReportDenial","ladder",N,"percent")=$G(PCT)
 S TCTX("billReportDenial","ladder",N,"note")=$G(NOTE)
 S TCTX("billReportDenial","ladder",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportDenial","ladder",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;

RPTPTEAM(TCTX,IDX,LABEL,VALUE,PCT,NOTE,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportProd","team",N,"label")=$G(LABEL)
 S TCTX("billReportProd","team",N,"value")=$G(VALUE)
 S TCTX("billReportProd","team",N,"percent")=$G(PCT)
 S TCTX("billReportProd","team",N,"note")=$G(NOTE)
 S TCTX("billReportProd","team",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportProd","team",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTPROW(TCTX,ROW,LABEL)
 N R
 S R=+$G(ROW)
 S TCTX("billReportProd","heat",R,"label")=$G(LABEL)
 Q
 ;
RPTPCELL(TCTX,ROW,COL,LABEL,VALUE,OPACITY,TONE)
 N R,C
 S R=+$G(ROW),C=+$G(COL)
 S TCTX("billReportProd","heat",R,"cell",C,"label")=$G(LABEL)
 S TCTX("billReportProd","heat",R,"cell",C,"value")=$G(VALUE)
 S TCTX("billReportProd","heat",R,"cell",C,"opacity")=$G(OPACITY)
 S TCTX("billReportProd","heat",R,"cell",C,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportProd","heat",R,"cell",C,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTPLEAD(TCTX,IDX,TITLE,VALUE,RANK,NOTE,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportProd","leader",N,"title")=$G(TITLE)
 S TCTX("billReportProd","leader",N,"value")=$G(VALUE)
 S TCTX("billReportProd","leader",N,"rank")=$G(RANK)
 S TCTX("billReportProd","leader",N,"note")=$G(NOTE)
 S TCTX("billReportProd","leader",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportProd","leader",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTPSLOPE(TCTX,IDX,LABEL,VALUE,PCT,NOTE,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportProd","slope",N,"label")=$G(LABEL)
 S TCTX("billReportProd","slope",N,"value")=$G(VALUE)
 S TCTX("billReportProd","slope",N,"percent")=$G(PCT)
 S TCTX("billReportProd","slope",N,"note")=$G(NOTE)
 S TCTX("billReportProd","slope",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportProd","slope",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTUWF(TCTX,IDX,LABEL,VALUE,PCT,DIRECTION,NOTE,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportUnder","waterfall",N,"label")=$G(LABEL)
 S TCTX("billReportUnder","waterfall",N,"value")=$G(VALUE)
 S TCTX("billReportUnder","waterfall",N,"percent")=$G(PCT)
 S TCTX("billReportUnder","waterfall",N,"direction")=$G(DIRECTION)
 S TCTX("billReportUnder","waterfall",N,"note")=$G(NOTE)
 S TCTX("billReportUnder","waterfall",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportUnder","waterfall",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTULANE(TCTX,IDX,LABEL,VALUE,PCT,NOTE,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportUnder","lane",N,"label")=$G(LABEL)
 S TCTX("billReportUnder","lane",N,"value")=$G(VALUE)
 S TCTX("billReportUnder","lane",N,"percent")=$G(PCT)
 S TCTX("billReportUnder","lane",N,"note")=$G(NOTE)
 S TCTX("billReportUnder","lane",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportUnder","lane",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTUROW(TCTX,ROW,LABEL)
 N R
 S R=+$G(ROW)
 S TCTX("billReportUnder","matrix",R,"label")=$G(LABEL)
 Q
 ;
RPTUCELL(TCTX,ROW,COL,LABEL,VALUE,OPACITY,TONE)
 N R,C
 S R=+$G(ROW),C=+$G(COL)
 S TCTX("billReportUnder","matrix",R,"cell",C,"label")=$G(LABEL)
 S TCTX("billReportUnder","matrix",R,"cell",C,"value")=$G(VALUE)
 S TCTX("billReportUnder","matrix",R,"cell",C,"opacity")=$G(OPACITY)
 S TCTX("billReportUnder","matrix",R,"cell",C,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportUnder","matrix",R,"cell",C,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RPTUCARD(TCTX,IDX,TITLE,VALUE,NOTE,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("billReportUnder","card",N,"title")=$G(TITLE)
 S TCTX("billReportUnder","card",N,"value")=$G(VALUE)
 S TCTX("billReportUnder","card",N,"note")=$G(NOTE)
 S TCTX("billReportUnder","card",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("billReportUnder","card",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
RINGCLR(TONE)
 N X
 S X=$G(TONE)
 I X="sky" Q "#0369a1"
 I X="emerald" Q "#047857"
 I X="violet" Q "#6d28d9"
 I X="amber" Q "#b45309"
 I X="rose" Q "#be123c"
 Q "#334155"
 ;
