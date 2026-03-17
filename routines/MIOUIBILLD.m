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
 D ADDM^MIOROUTE("GET","/mioui/billing-reports","REPORTS^MIOUIBILLD",.META)
 D ADDM^MIOROUTE("GET","/mioui/billing-reports-dense","REPORTSD^MIOUIBILLD",.META)
 D ADDM^MIOROUTE("GET","/mioui/billing-reports-executive","REPORTSX^MIOUIBILLD",.META)
 D ADDM^MIOROUTE("GET","/mioui/billing-reports-analytics","REPORTSA^MIOUIBILLD",.META)
 D ADDM^MIOROUTE("GET","/mioui/billing-reports-wallboard","REPORTSW^MIOUIBILLD",.META)
 D ADDM^MIOROUTE("GET","/mioui/billing-reports-forecast","REPORTSF^MIOUIBILLD",.META)
 D ADDM^MIOROUTE("GET","/mioui/billing-reports-benchmark","REPORTSB^MIOUIBILLD",.META)
 D ADDM^MIOROUTE("GET","/mioui/billing-reports-cashflow","REPORTSC^MIOUIBILLD",.META)
 D ADDM^MIOROUTE("GET","/mioui/billing-reports-denials","REPORTSN^MIOUIBILLD",.META)
 D ADDM^MIOROUTE("GET","/mioui/billing-reports-productivity","REPORTSP^MIOUIBILLD",.META)
 D ADDM^MIOROUTE("GET","/mioui/billing-reports-underpayments","REPORTSU^MIOUIBILLD",.META)
 S ^MIO("ROUTE","RAW","GET","/mioui/billing-patient")="PATIENT^MIOUIBILLD"
 S ^MIO("ROUTE","META","GET","/mioui/billing-patient","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/billing-patient","roles")=""
 S ^MIO("ROUTE","RAW","GET","/mioui/billing-patient-dense")="PATIENTD^MIOUIBILLD"
 S ^MIO("ROUTE","META","GET","/mioui/billing-patient-dense","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/billing-patient-dense","roles")=""
 S ^MIO("ROUTE","RAW","GET","/mioui/billing-patient-balanced")="PATIENTB^MIOUIBILLD"
 S ^MIO("ROUTE","META","GET","/mioui/billing-patient-balanced","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/billing-patient-balanced","roles")=""
 S ^MIO("ROUTE","RAW","GET","/mioui/billing-reports")="REPORTS^MIOUIBILLD"
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports","roles")=""
 S ^MIO("ROUTE","RAW","GET","/mioui/billing-reports-dense")="REPORTSD^MIOUIBILLD"
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports-dense","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports-dense","roles")=""
 S ^MIO("ROUTE","RAW","GET","/mioui/billing-reports-executive")="REPORTSX^MIOUIBILLD"
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports-executive","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports-executive","roles")=""
 S ^MIO("ROUTE","RAW","GET","/mioui/billing-reports-analytics")="REPORTSA^MIOUIBILLD"
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports-analytics","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports-analytics","roles")=""
 S ^MIO("ROUTE","RAW","GET","/mioui/billing-reports-wallboard")="REPORTSW^MIOUIBILLD"
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports-wallboard","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports-wallboard","roles")=""
 S ^MIO("ROUTE","RAW","GET","/mioui/billing-reports-forecast")="REPORTSF^MIOUIBILLD"
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports-forecast","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports-forecast","roles")=""
 S ^MIO("ROUTE","RAW","GET","/mioui/billing-reports-benchmark")="REPORTSB^MIOUIBILLD"
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports-benchmark","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports-benchmark","roles")=""
 S ^MIO("ROUTE","RAW","GET","/mioui/billing-reports-cashflow")="REPORTSC^MIOUIBILLD"
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports-cashflow","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports-cashflow","roles")=""
 S ^MIO("ROUTE","RAW","GET","/mioui/billing-reports-denials")="REPORTSN^MIOUIBILLD"
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports-denials","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports-denials","roles")=""
 S ^MIO("ROUTE","RAW","GET","/mioui/billing-reports-productivity")="REPORTSP^MIOUIBILLD"
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports-productivity","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports-productivity","roles")=""
 S ^MIO("ROUTE","RAW","GET","/mioui/billing-reports-underpayments")="REPORTSU^MIOUIBILLD"
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports-underpayments","authRequired")=0
 S ^MIO("ROUTE","META","GET","/mioui/billing-reports-underpayments","roles")=""
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
REPORTS(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILDREP(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_reports.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
REPORTSD(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILDREPD(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_reports_dense.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
REPORTSX(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILDREPX(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_reports_executive.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
REPORTSA(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILDREPA(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_reports_analytics.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
REPORTSW(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILDREPW(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_reports_wallboard.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
REPORTSF(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILDREPF(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_reports_forecast.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
REPORTSB(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILDREPB(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_reports_benchmark.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
REPORTSC(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILDREPC(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_reports_cashflow.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
REPORTSN(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILDREPN(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_reports_denials.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
REPORTSP(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILDREPP(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_reports_productivity.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 I $D(ERR) D RESPERR^MIOUIDEMO(.DEV,.CONF,.CTX,500,"template_error") Q
 D RESPHTML^MIOUIDEMO(.DEV,.CONF,.CTX,.OUT)
 Q
 ;
REPORTSU(DEV,CONF,REQ,CTX)
 N TCTX,OUT,ERR
 D BUILDREPU(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/miouibill_reports_underpayments.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
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
BUILDREP(CONF,REQ,CTX,TCTX)
 D BASE^MIOUICTX(.TCTX)
 D APPLY^MIOUITHEME(.CONF,.TCTX)
 D ACT^MIOUICTX(.TCTX,"billing")
 S TCTX("billMode")="reports"
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Billing / Reports workspace","Billing report workspace","Dense SSR billing reports for revenue, aging, payer variance, denial mix, and export distribution without leaving the MIOUI shell.","Billing reports lab")
 D FOOTER(.TCTX)
 D RSTATS(.TCTX,"standard")
 D RHEADER(.TCTX)
 D RFILTERS(.TCTX)
 D RKPIS(.TCTX)
 D RTABS(.TCTX)
 D RAGING(.TCTX)
 D RPAYERS(.TCTX)
 D RREASONS(.TCTX)
 D REXPORTS(.TCTX)
 D RFLAGS(.TCTX)
 Q
 ;
BUILDREPD(CONF,REQ,CTX,TCTX)
 D BUILDREP(.CONF,.REQ,.CTX,.TCTX)
 S TCTX("billMode")="reports-dense"
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Billing / Reports dense console","Billing report dense console","A compact operator-focused report console with fixed-height panes for queues, payer variance, aging, and scheduled distribution.","Billing report dense console")
 D RSTATS(.TCTX,"dense")
 D RPTHDR^MIOUIBILL(.TCTX,"Operator report console","Week ending 2026-03-13 · Queue-first view","Refreshed 08:07 AM","violet")
 S TCTX("billReport","lead")="A denser report variant for leads and operators who want queues, KPI drift, aging, payer variance, and export timing visible in one screen-oriented console."
 K TCTX("billReport","tab")
 D RPTTAB^MIOUIBILL(.TCTX,1,"queues","Queues",4,1)
 D RPTTAB^MIOUIBILL(.TCTX,2,"aging","Aging",5,0)
 D RPTTAB^MIOUIBILL(.TCTX,3,"payers","Payers",5,0)
 D RPTTAB^MIOUIBILL(.TCTX,4,"exports","Exports",3,0)
 S TCTX("billReportDense","workspaceClass")="h-[calc(100vh-16rem)] min-h-[44rem] overflow-hidden"
 D RDQUEUES(.TCTX)
 D RDTRENDS(.TCTX)
 Q
 ;
BUILDREPX(CONF,REQ,CTX,TCTX)
 D BUILDREP(.CONF,.REQ,.CTX,.TCTX)
 S TCTX("billMode")="reports-executive"
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Billing / Executive report snapshot","Billing executive report snapshot","A presentation-friendly revenue-cycle snapshot with narrative cards, action focus, and the same SSR billing report primitives.","Billing executive snapshot")
 D RSTATS(.TCTX,"executive")
 D RPTHDR^MIOUIBILL(.TCTX,"Executive billing snapshot","Week ending 2026-03-13 · Leadership summary","Board-ready at 08:07 AM","emerald")
 S TCTX("billReport","lead")="A calmer report variant for weekly revenue-cycle review. It keeps the same billing metrics but changes the page rhythm toward story, risk, and next-action visibility."
 D RXSTORIES(.TCTX)
 D RXACTIONS(.TCTX)
 Q
 ;
BUILDREPA(CONF,REQ,CTX,TCTX)
 D BUILDREP(.CONF,.REQ,.CTX,.TCTX)
 S TCTX("billMode")="reports-analytics"
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Billing / Analytics studio","Billing analytics studio","A chart-forward billing report studio built with SSR-first visual components for collections, aging, payer mix, denial patterns, and clean-claim progression.","Billing analytics studio")
 D RSTATS(.TCTX,"analytics")
 D RPTHDR^MIOUIBILL(.TCTX,"Billing analytics studio","Week ending 2026-03-13 · Visual trend lab","Charts refreshed 08:07 AM","sky")
 S TCTX("billReport","lead")="A chart-first billing report route for supervisors who want trend, distribution, funnel, and denial patterns to read faster than raw tables while remaining fully SSR and operator-safe."
 D RVIZ(.TCTX)
 Q
 ;
BUILDREPW(CONF,REQ,CTX,TCTX)
 D BUILDREPA(.CONF,.REQ,.CTX,.TCTX)
 S TCTX("billMode")="reports-wallboard"
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Billing / Visual wallboard","Billing visual wallboard","A wallboard-ready SSR chart surface for billing command centers, floor monitors, and queue leadership review.","Billing visual wallboard")
 D RSTATS(.TCTX,"wallboard")
 D RPTHDR^MIOUIBILL(.TCTX,"Billing visual wallboard","Week ending 2026-03-13 · Monitor view","Live chart wall · 08:07 AM","violet")
 S TCTX("billReport","lead")="A monitor-friendly chart wall that keeps the same synthetic revenue-cycle signals but enlarges the visual readout for shared spaces, shift huddles, and command-center scanning."
 S TCTX("billReportWall","headline")="Live chart wall"
 S TCTX("billReportWall","subhead")="Monitor-safe SSR layout with darker light-theme chart treatment and zero client chart framework overhead."
 Q
 ;
BUILDREPF(CONF,REQ,CTX,TCTX)
 D BUILDREP(.CONF,.REQ,.CTX,.TCTX)
 S TCTX("billMode")="reports-forecast"
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Billing / Forecast studio","Billing forecast studio","A projection-first billing report route with multi-week cash forecasting, scenario comparisons, and variance-bridge visuals.","Billing forecast studio")
 D RSTATS(.TCTX,"forecast")
 D RPTHDR^MIOUIBILL(.TCTX,"Billing forecast studio","Next 6 weeks · Projection and staffing view","Forecast refreshed 08:07 AM","amber")
 S TCTX("billReport","lead")="A forecast-first billing route for leaders who need the next six weeks of cash posture, expected collection drift, and best-case versus risk-case scenario spread in one SSR surface."
 D RFORECAST(.TCTX)
 Q
 ;
BUILDREPB(CONF,REQ,CTX,TCTX)
 D BUILDREP(.CONF,.REQ,.CTX,.TCTX)
 S TCTX("billMode")="reports-benchmark"
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Billing / Benchmark deck","Billing benchmark deck","A benchmark-focused billing route for peer comparison, payer ranking, and metric ladder visuals.","Billing benchmark deck")
 D RSTATS(.TCTX,"benchmark")
 D RPTHDR^MIOUIBILL(.TCTX,"Billing benchmark deck","Peer comparison · Weekly operator benchmark","Benchmarks refreshed 08:07 AM","violet")
 S TCTX("billReport","lead")="A benchmark-heavy billing route for comparing internal billing performance against payer cohorts, peer medians, and top-quartile operational targets without leaving the SSR shell."
 D RBENCH(.TCTX)
 Q
 ;
BUILDREPC(CONF,REQ,CTX,TCTX)
 D BUILDREP(.CONF,.REQ,.CTX,.TCTX)
 S TCTX("billMode")="reports-cashflow"
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Billing / Cashflow studio","Billing cashflow studio","A cash-movement billing route with chart-first run-rate, source-mix, and remit-lag views.","Billing cashflow studio")
 D RSTATS(.TCTX,"cashflow")
 D RPTHDR^MIOUIBILL(.TCTX,"Billing cashflow studio","Week ending 2026-03-13 · Posted cash and remit motion","Cashflow refreshed 08:07 AM","emerald")
 S TCTX("billReport","lead")="A cashflow-first billing route for supervisors who need posted-cash rhythm, remit source mix, and payer lag exposed before they drop into payer or export detail."
 D RCASH(.TCTX)
 Q
 ;
BUILDREPN(CONF,REQ,CTX,TCTX)
 D BUILDREP(.CONF,.REQ,.CTX,.TCTX)
 S TCTX("billMode")="reports-denials"
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Billing / Denial intelligence","Billing denial intelligence","A denial-focused billing route with chart-first reason streams, payer-risk matrix, and appeal-aging views.","Billing denial intelligence")
 D RSTATS(.TCTX,"denials")
 D RPTHDR^MIOUIBILL(.TCTX,"Billing denial intelligence","Week ending 2026-03-13 · Denial pressure and appeal posture","Denials refreshed 08:07 AM","rose")
 S TCTX("billReport","lead")="A denial-first billing route for managers who need reason concentration, payer-risk overlap, and appeal aging to read faster than flat tables while staying fully SSR."
 D RDENIAL(.TCTX)
 Q
 ;
BUILDREPP(CONF,REQ,CTX,TCTX)
 D BUILDREP(.CONF,.REQ,.CTX,.TCTX)
 S TCTX("billMode")="reports-productivity"
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Billing / Productivity studio","Billing productivity studio","A team-throughput billing route with chart-first touch-rate, queue heatmap, leaderboard, and backlog trend surfaces.","Billing productivity studio")
 D RSTATS(.TCTX,"productivity")
 D RPTHDR^MIOUIBILL(.TCTX,"Billing productivity studio","Week ending 2026-03-13 · Throughput and resolution cadence","Productivity refreshed 08:07 AM","sky")
 S TCTX("billReport","lead")="A productivity-first billing route for supervisors who need team touches, queue concentration, same-day resolution, and backlog posture visible before they drill into payer or denial detail."
 D RPRODUCT(.TCTX)
 Q
 ;
BUILDREPU(CONF,REQ,CTX,TCTX)
 D BUILDREP(.CONF,.REQ,.CTX,.TCTX)
 S TCTX("billMode")="reports-underpayments"
 D PAGE^MIOUICTX(.TCTX,"MIOUI / Billing / Underpayments studio","Billing underpayments studio","A reimbursement-leakage billing route with chart-first underpayment waterfall, payer leakage lanes, and contract variance matrix surfaces.","Billing underpayments studio")
 D RSTATS(.TCTX,"underpayments")
 D RPTHDR^MIOUIBILL(.TCTX,"Billing underpayments studio","Week ending 2026-03-13 · Expected-versus-paid variance","Underpayments refreshed 08:07 AM","amber")
 S TCTX("billReport","lead")="An underpayment-first billing route for leads who need contract leakage, payer-specific variance, and service-line spread to read quickly in one SSR workspace."
 D RUNDER(.TCTX)
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
 S TCTX("footer","links",10,"label")="Billing reports"
 S TCTX("footer","links",10,"href")="/mioui/billing-reports"
 S TCTX("footer","links",11,"label")="Reports dense"
 S TCTX("footer","links",11,"href")="/mioui/billing-reports-dense"
 S TCTX("footer","links",12,"label")="Reports executive"
 S TCTX("footer","links",12,"href")="/mioui/billing-reports-executive"
 S TCTX("footer","links",13,"label")="Reports analytics"
 S TCTX("footer","links",13,"href")="/mioui/billing-reports-analytics"
 S TCTX("footer","links",14,"label")="Reports wallboard"
 S TCTX("footer","links",14,"href")="/mioui/billing-reports-wallboard"
 S TCTX("footer","links",15,"label")="Reports forecast"
 S TCTX("footer","links",15,"href")="/mioui/billing-reports-forecast"
 S TCTX("footer","links",16,"label")="Reports benchmark"
 S TCTX("footer","links",16,"href")="/mioui/billing-reports-benchmark"
 S TCTX("footer","links",17,"label")="Reports cashflow"
 S TCTX("footer","links",17,"href")="/mioui/billing-reports-cashflow"
 S TCTX("footer","links",18,"label")="Reports denials"
 S TCTX("footer","links",18,"href")="/mioui/billing-reports-denials"
 S TCTX("footer","links",19,"label")="Reports productivity"
 S TCTX("footer","links",19,"href")="/mioui/billing-reports-productivity"
 S TCTX("footer","links",20,"label")="Reports underpayments"
 S TCTX("footer","links",20,"href")="/mioui/billing-reports-underpayments"
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
RSTATS(TCTX,MODE)
 I $G(MODE)="dense" D  Q
 . D STAT^MIOUIPANEL(.TCTX,1,"Queue lanes",4,"violet","/mioui/billing-reports-dense#report-dense-queues")
 . D STAT^MIOUIPANEL(.TCTX,2,"KPI cells",6,"sky","/mioui/billing-reports-dense#report-dense-kpis")
 . D STAT^MIOUIPANEL(.TCTX,3,"Payer rows",5,"amber","/mioui/billing-reports-dense#report-dense-payers")
 . D STAT^MIOUIPANEL(.TCTX,4,"Export jobs",3,"emerald","/mioui/billing-reports-dense#report-dense-exports")
 I $G(MODE)="executive" D  Q
 . D STAT^MIOUIPANEL(.TCTX,1,"Leadership cards",3,"emerald","/mioui/billing-reports-executive#report-exec-stories")
 . D STAT^MIOUIPANEL(.TCTX,2,"Primary KPIs",6,"sky","/mioui/billing-reports-executive#report-exec-kpis")
 . D STAT^MIOUIPANEL(.TCTX,3,"Priority actions",3,"amber","/mioui/billing-reports-executive#report-exec-actions")
 . D STAT^MIOUIPANEL(.TCTX,4,"Payer rows",5,"violet","/mioui/billing-reports-executive#report-exec-payers")
 I $G(MODE)="analytics" D  Q
 . D STAT^MIOUIPANEL(.TCTX,1,"Chart panels",6,"sky","/mioui/billing-reports-analytics#report-analytics-charts")
 . D STAT^MIOUIPANEL(.TCTX,2,"Trend bars",7,"emerald","/mioui/billing-reports-analytics#report-analytics-trend")
 . D STAT^MIOUIPANEL(.TCTX,3,"Heat cells",16,"amber","/mioui/billing-reports-analytics#report-analytics-heat")
 . D STAT^MIOUIPANEL(.TCTX,4,"Funnel stages",4,"violet","/mioui/billing-reports-analytics#report-analytics-funnel")
 I $G(MODE)="wallboard" D  Q
 . D STAT^MIOUIPANEL(.TCTX,1,"Live charts",6,"violet","/mioui/billing-reports-wallboard#report-wallboard-charts")
 . D STAT^MIOUIPANEL(.TCTX,2,"Trend bars",7,"sky","/mioui/billing-reports-wallboard#report-wallboard-trend")
 . D STAT^MIOUIPANEL(.TCTX,3,"Heat cells",16,"amber","/mioui/billing-reports-wallboard#report-wallboard-heat")
 . D STAT^MIOUIPANEL(.TCTX,4,"Wallboard KPIs",6,"emerald","/mioui/billing-reports-wallboard#report-wallboard-kpis")
 I $G(MODE)="forecast" D  Q
 . D STAT^MIOUIPANEL(.TCTX,1,"Forecast weeks",6,"amber","/mioui/billing-reports-forecast#report-forecast-band")
 . D STAT^MIOUIPANEL(.TCTX,2,"Scenario cards",3,"emerald","/mioui/billing-reports-forecast#report-forecast-scenarios")
 . D STAT^MIOUIPANEL(.TCTX,3,"Bridge steps",6,"violet","/mioui/billing-reports-forecast#report-forecast-bridge")
 . D STAT^MIOUIPANEL(.TCTX,4,"Forecast KPIs",6,"sky","/mioui/billing-reports-forecast#report-forecast-kpis")
 I $G(MODE)="benchmark" D  Q
 . D STAT^MIOUIPANEL(.TCTX,1,"Metric ladders",5,"violet","/mioui/billing-reports-benchmark#report-benchmark-ladder")
 . D STAT^MIOUIPANEL(.TCTX,2,"Peer matrix cells",16,"amber","/mioui/billing-reports-benchmark#report-benchmark-matrix")
 . D STAT^MIOUIPANEL(.TCTX,3,"Scorecards",4,"emerald","/mioui/billing-reports-benchmark#report-benchmark-scorecards")
 . D STAT^MIOUIPANEL(.TCTX,4,"Payer rows",5,"sky","/mioui/billing-reports-benchmark#report-benchmark-payers")
 I $G(MODE)="cashflow" D  Q
 . D STAT^MIOUIPANEL(.TCTX,1,"Run-rate bars",8,"emerald","/mioui/billing-reports-cashflow#report-cashflow-runrate")
 . D STAT^MIOUIPANEL(.TCTX,2,"Source lanes",4,"sky","/mioui/billing-reports-cashflow#report-cashflow-mix")
 . D STAT^MIOUIPANEL(.TCTX,3,"Lag tracks",5,"amber","/mioui/billing-reports-cashflow#report-cashflow-lag")
 . D STAT^MIOUIPANEL(.TCTX,4,"Payer rows",5,"violet","/mioui/billing-reports-cashflow#report-cashflow-payers")
 I $G(MODE)="denials" D  Q
 . D STAT^MIOUIPANEL(.TCTX,1,"Reason streams",4,"rose","/mioui/billing-reports-denials#report-denials-stream")
 . D STAT^MIOUIPANEL(.TCTX,2,"Risk matrix cells",16,"amber","/mioui/billing-reports-denials#report-denials-matrix")
 . D STAT^MIOUIPANEL(.TCTX,3,"Appeal ladders",5,"violet","/mioui/billing-reports-denials#report-denials-ladder")
 . D STAT^MIOUIPANEL(.TCTX,4,"Denial cards",4,"sky","/mioui/billing-reports-denials#report-denials-bands")
 I $G(MODE)="productivity" D  Q
 . D STAT^MIOUIPANEL(.TCTX,1,"Team bars",5,"sky","/mioui/billing-reports-productivity#report-productivity-team")
 . D STAT^MIOUIPANEL(.TCTX,2,"Heat cells",16,"violet","/mioui/billing-reports-productivity#report-productivity-heat")
 . D STAT^MIOUIPANEL(.TCTX,3,"Leaderboard cards",4,"emerald","/mioui/billing-reports-productivity#report-productivity-leaders")
 . D STAT^MIOUIPANEL(.TCTX,4,"Backlog points",6,"amber","/mioui/billing-reports-productivity#report-productivity-slope")
 I $G(MODE)="underpayments" D  Q
 . D STAT^MIOUIPANEL(.TCTX,1,"Waterfall steps",5,"amber","/mioui/billing-reports-underpayments#report-underpayments-waterfall")
 . D STAT^MIOUIPANEL(.TCTX,2,"Leakage lanes",4,"rose","/mioui/billing-reports-underpayments#report-underpayments-lanes")
 . D STAT^MIOUIPANEL(.TCTX,3,"Matrix cells",16,"violet","/mioui/billing-reports-underpayments#report-underpayments-matrix")
 . D STAT^MIOUIPANEL(.TCTX,4,"Leakage cards",4,"sky","/mioui/billing-reports-underpayments#report-underpayments-cards")
 D STAT^MIOUIPANEL(.TCTX,1,"KPIs",6,"sky","/mioui/billing-reports#report-kpis")
 D STAT^MIOUIPANEL(.TCTX,2,"Aging buckets",5,"amber","/mioui/billing-reports#report-aging")
 D STAT^MIOUIPANEL(.TCTX,3,"Payers",5,"violet","/mioui/billing-reports#report-payers")
 D STAT^MIOUIPANEL(.TCTX,4,"Exports",3,"emerald","/mioui/billing-reports#report-exports")
 Q
 ;
RHEADER(TCTX)
 D RPTHDR^MIOUIBILL(.TCTX,"March revenue cycle snapshot","Week ending 2026-03-13 · Service-date aging","Refreshed 08:07 AM","sky")
 S TCTX("billReport","lead")="A one-screen billing report workspace for supervisors who need revenue, aging, payer, denial, and distribution signals in the same SSR surface."
 Q
 ;
RFILTERS(TCTX)
 D RPTFILTER^MIOUIBILL(.TCTX,1,"Facility","North Harbor Infusion")
 D RPTFILTER^MIOUIBILL(.TCTX,2,"Billing Group","Home and Ambulatory")
 D RPTFILTER^MIOUIBILL(.TCTX,3,"Aged Basis","Service Date")
 D RPTFILTER^MIOUIBILL(.TCTX,4,"Payer Scope","All active payers")
 D RPTFILTER^MIOUIBILL(.TCTX,5,"Work Queue","Follow-up and denial recovery")
 Q
 ;
RKPIS(TCTX)
 D RPTKPI^MIOUIBILL(.TCTX,1,"Gross Charges","$482,914.22","+6.4% vs prior week","Home infusion volume remained elevated after the antimicrobial bundle refresh.","sky")
 D RPTKPI^MIOUIBILL(.TCTX,2,"Net Collections","$318,442.09","+4.1% vs prior week","Cash variance improved even after weekend remit lag normalization.","emerald")
 D RPTKPI^MIOUIBILL(.TCTX,3,"First-Pass Rate","92.4%","+1.7 pts","Cleaner subscriber and ordering-provider data reduced early edits.","violet")
 D RPTKPI^MIOUIBILL(.TCTX,4,"AR > 60 Days","$94,880.15","-8.9%","Recovery work pulled several commercial accounts back into current and 31-60 day buckets.","amber")
 D RPTKPI^MIOUIBILL(.TCTX,5,"Open Denials","126","-19","Medical-necessity and authorization denials both trended down week over week.","rose")
 D RPTKPI^MIOUIBILL(.TCTX,6,"Cash Posted","$74,218.31","+9.3%","Daily remit application remained stable across both ERA and manual posting streams.","emerald")
 Q
 ;
RTABS(TCTX)
 D RPTTAB^MIOUIBILL(.TCTX,1,"summary","Summary",6,1)
 D RPTTAB^MIOUIBILL(.TCTX,2,"aging","Aging",5,0)
 D RPTTAB^MIOUIBILL(.TCTX,3,"payers","Payers",5,0)
 D RPTTAB^MIOUIBILL(.TCTX,4,"exports","Exports",3,0)
 Q
 ;
RAGING(TCTX)
 D RPTAGING^MIOUIBILL(.TCTX,1,"Current","$182,441.20","418","42.7%","emerald")
 D RPTAGING^MIOUIBILL(.TCTX,2,"31-60 Days","$96,112.44","203","22.5%","sky")
 D RPTAGING^MIOUIBILL(.TCTX,3,"61-90 Days","$58,204.11","121","13.6%","amber")
 D RPTAGING^MIOUIBILL(.TCTX,4,"91-120 Days","$41,776.88","89","9.8%","violet")
 D RPTAGING^MIOUIBILL(.TCTX,5,"Greater than 120 Days","$48,503.96","77","11.4%","rose")
 Q
 ;
RPAYERS(TCTX)
 D RPTPAYER^MIOUIBILL(.TCTX,1,"North Harbor Health Plan","$122,408.00","$83,114.55","14","17.2","+3.8%","emerald")
 D RPTPAYER^MIOUIBILL(.TCTX,2,"Lakeview Senior Advantage","$96,510.44","$61,883.91","19","24.9","-1.4%","amber")
 D RPTPAYER^MIOUIBILL(.TCTX,3,"Apex Commercial PPO","$84,219.73","$55,442.10","11","16.4","+2.1%","sky")
 D RPTPAYER^MIOUIBILL(.TCTX,4,"Tri-State Employer Health","$73,944.15","$46,019.80","22","27.6","-3.2%","rose")
 D RPTPAYER^MIOUIBILL(.TCTX,5,"Summit Medicaid Managed","$58,447.62","$37,281.44","17","21.1","+0.9%","violet")
 Q
 ;
RREASONS(TCTX)
 D RPTREASON^MIOUIBILL(.TCTX,1,"Authorization missing or invalid","31","$18,440.22","Route same-day follow-up to auth recovery before rebill.","amber")
 D RPTREASON^MIOUIBILL(.TCTX,2,"Medical necessity documentation","27","$15,906.11","Pull infusion order and physician notes into the appeal pack.","rose")
 D RPTREASON^MIOUIBILL(.TCTX,3,"Member eligibility mismatch","22","$9,188.44","Re-verify subscriber plan and replay payer search before resubmit.","sky")
 D RPTREASON^MIOUIBILL(.TCTX,4,"Coding or modifier validation","19","$7,420.76","Review HCPCS units and modifier pattern on home health lines.","violet")
 Q
 ;
REXPORTS(TCTX)
 D RPTEXPORT^MIOUIBILL(.TCTX,1,"Daily aging workbook","XLSX","Weekdays · 06:30 AM","finance@northlight.example","Ready","emerald")
 D RPTEXPORT^MIOUIBILL(.TCTX,2,"Payer variance packet","PDF","Mondays · 07:00 AM","leadership@northlight.example","Queued","amber")
 D RPTEXPORT^MIOUIBILL(.TCTX,3,"Denial recovery queue","CSV","Hourly","ops-supervisors@northlight.example","Streaming","sky")
 Q
 ;
RFLAGS(TCTX)
 D RPTFLAG^MIOUIBILL(.TCTX,1,"Auto-close small balance","Current week rules closed 43 balances under $5 after remit confirmation.","emerald")
 D RPTFLAG^MIOUIBILL(.TCTX,2,"Weekend intake drift","Lakeview Senior Advantage posted 7 claims into 31-60 because weekend intake hit after payer cutoff.","amber")
 D RPTFLAG^MIOUIBILL(.TCTX,3,"Appeal packet watch","Medical-necessity denials are trending down, but appeal packet turnaround still averages 2.8 days.","violet")
 Q
 ;
RDQUEUES(TCTX)
 D RPTQUEUE^MIOUIBILL(.TCTX,1,"Authorization recovery","K. Morgan","14 open","$18,440.22","Same day","Top-dollar denials waiting for auth notes or retro approval.","amber")
 D RPTQUEUE^MIOUIBILL(.TCTX,2,"Medical necessity appeals","T. Reyes","11 open","$15,906.11","24 hours","Appeal packet completion speed is the main limiter this week.","rose")
 D RPTQUEUE^MIOUIBILL(.TCTX,3,"Eligibility replay","D. Sutton","9 open","$9,188.44","4 hours","Subscriber checks and payer-search replay can clear these quickly.","sky")
 D RPTQUEUE^MIOUIBILL(.TCTX,4,"Coding and modifier review","J. Mercer","7 open","$7,420.76","8 hours","Unit validation and modifier pairing still need manual review.","violet")
 Q
 ;
RDTRENDS(TCTX)
 D RPTTREND^MIOUIBILL(.TCTX,1,"Mon","$41.8k","62","Collections rebounded after weekend remit catch-up.","emerald")
 D RPTTREND^MIOUIBILL(.TCTX,2,"Tue","$44.1k","68","Gross charges stayed elevated in home infusion.","sky")
 D RPTTREND^MIOUIBILL(.TCTX,3,"Wed","$38.4k","56","One commercial payer posted later than usual.","amber")
 D RPTTREND^MIOUIBILL(.TCTX,4,"Thu","$47.6k","74","Appeal clearances raised same-week collections.","violet")
 D RPTTREND^MIOUIBILL(.TCTX,5,"Fri","$49.2k","78","Cash posted peaked before close.","emerald")
 D RPTTREND^MIOUIBILL(.TCTX,6,"Sat","$35.7k","49","Reduced remit volume is typical for Saturday.","slate")
 Q
 ;
RXSTORIES(TCTX)
 D RPTSTORY^MIOUIBILL(.TCTX,1,"Collections story","Net collections and cash posted both improved while open denials fell, which suggests the operating teams are converting queue work into posted cash instead of simply shifting balances between buckets.","emerald")
 D RPTSTORY^MIOUIBILL(.TCTX,2,"Oldest A/R concentration","The oldest balance remains concentrated in authorization and documentation categories, not broad payer underperformance. That narrows the next-week action plan toward appeal packet speed and auth cleanup.","amber")
 D RPTSTORY^MIOUIBILL(.TCTX,3,"Payer behavior","Commercial and employer plans are still the largest source of week-over-week variance. Lakeview and Tri-State explain most of the drag, while Apex and North Harbor remain supportive.","violet")
 Q
 ;
RXACTIONS(TCTX)
 D RPTACTION^MIOUIBILL(.TCTX,1,"Escalate Lakeview weekend lag","Ops lead · R. Patel","By 10:00 AM","Validate cutoff timing and tighten intake-to-submit handling so late-week claims do not age into 31-60 unnecessarily.","amber")
 D RPTACTION^MIOUIBILL(.TCTX,2,"Clear top auth holds","Auth recovery · K. Morgan","By noon","Resolve the 14 highest-value authorization denials and push same-day rebills where documentation is already complete.","emerald")
 D RPTACTION^MIOUIBILL(.TCTX,3,"Trim appeal packet turnaround","Appeals team · T. Reyes","Within 24 hours","Reduce packet assembly cycle time on medical-necessity denials so this category continues to trend down next week.","violet")
 Q
 ;
RVIZ(TCTX)
 D RPTMETER^MIOUIBILL(.TCTX,"Net collection goal","82.6%","82.6","$318.4k collected against a $385k weekly target.","emerald")
 D RPTVCOL^MIOUIBILL(.TCTX,1,"Mon","$41.8k","62","ERA posting recovered after the weekend catch-up.","emerald")
 D RPTVCOL^MIOUIBILL(.TCTX,2,"Tue","$44.1k","68","Commercial volume stayed elevated.","sky")
 D RPTVCOL^MIOUIBILL(.TCTX,3,"Wed","$38.4k","56","One large payer posted later than normal.","amber")
 D RPTVCOL^MIOUIBILL(.TCTX,4,"Thu","$47.6k","74","Appeal clearance added same-week cash.","violet")
 D RPTVCOL^MIOUIBILL(.TCTX,5,"Fri","$49.2k","78","Best day for posted cash in this cycle.","emerald")
 D RPTVCOL^MIOUIBILL(.TCTX,6,"Sat","$35.7k","49","Weekend remits are predictably lighter.","slate")
 D RPTVCOL^MIOUIBILL(.TCTX,7,"Sun","$29.4k","41","Carryover only, no full posting staff.","slate")
 D RPTVBAR^MIOUIBILL(.TCTX,1,"North Harbor Health Plan","$83.1k net paid","79","+3.8% variance","emerald")
 D RPTVBAR^MIOUIBILL(.TCTX,2,"Lakeview Senior Advantage","$61.9k net paid","58","-1.4% variance","amber")
 D RPTVBAR^MIOUIBILL(.TCTX,3,"Apex Commercial PPO","$55.4k net paid","53","+2.1% variance","sky")
 D RPTVBAR^MIOUIBILL(.TCTX,4,"Tri-State Employer Health","$46.0k net paid","44","-3.2% variance","rose")
 D RPTVBAR^MIOUIBILL(.TCTX,5,"Summit Medicaid Managed","$37.3k net paid","36","+0.9% variance","violet")
 D RPTVSEG^MIOUIBILL(.TCTX,1,"Current","$182.4k","42.7","emerald")
 D RPTVSEG^MIOUIBILL(.TCTX,2,"31-60","$96.1k","22.5","sky")
 D RPTVSEG^MIOUIBILL(.TCTX,3,"61-90","$58.2k","13.6","amber")
 D RPTVSEG^MIOUIBILL(.TCTX,4,"91-120","$41.8k","9.8","violet")
 D RPTVSEG^MIOUIBILL(.TCTX,5,"120+","$48.5k","11.4","rose")
 D RPTVROW^MIOUIBILL(.TCTX,1,"Authorization")
 D RPTVCELL^MIOUIBILL(.TCTX,1,1,"Commercial","12","0.86","amber")
 D RPTVCELL^MIOUIBILL(.TCTX,1,2,"Medicare Advantage","8","0.64","amber")
 D RPTVCELL^MIOUIBILL(.TCTX,1,3,"Managed Medicaid","4","0.38","sky")
 D RPTVCELL^MIOUIBILL(.TCTX,1,4,"Employer Plan","7","0.58","violet")
 D RPTVROW^MIOUIBILL(.TCTX,2,"Medical necessity")
 D RPTVCELL^MIOUIBILL(.TCTX,2,1,"Commercial","10","0.77","rose")
 D RPTVCELL^MIOUIBILL(.TCTX,2,2,"Medicare Advantage","9","0.70","rose")
 D RPTVCELL^MIOUIBILL(.TCTX,2,3,"Managed Medicaid","3","0.32","sky")
 D RPTVCELL^MIOUIBILL(.TCTX,2,4,"Employer Plan","5","0.46","violet")
 D RPTVROW^MIOUIBILL(.TCTX,3,"Eligibility")
 D RPTVCELL^MIOUIBILL(.TCTX,3,1,"Commercial","6","0.55","sky")
 D RPTVCELL^MIOUIBILL(.TCTX,3,2,"Medicare Advantage","7","0.60","sky")
 D RPTVCELL^MIOUIBILL(.TCTX,3,3,"Managed Medicaid","5","0.48","amber")
 D RPTVCELL^MIOUIBILL(.TCTX,3,4,"Employer Plan","4","0.36","violet")
 D RPTVROW^MIOUIBILL(.TCTX,4,"Coding and modifier")
 D RPTVCELL^MIOUIBILL(.TCTX,4,1,"Commercial","4","0.34","violet")
 D RPTVCELL^MIOUIBILL(.TCTX,4,2,"Medicare Advantage","3","0.27","violet")
 D RPTVCELL^MIOUIBILL(.TCTX,4,3,"Managed Medicaid","5","0.41","amber")
 D RPTVCELL^MIOUIBILL(.TCTX,4,4,"Employer Plan","7","0.57","rose")
 D RPTVFUN^MIOUIBILL(.TCTX,1,"Submitted","842 claims","100","sky")
 D RPTVFUN^MIOUIBILL(.TCTX,2,"Accepted","778 claims","92.4","emerald")
 D RPTVFUN^MIOUIBILL(.TCTX,3,"Paid or posted","612 claims","72.7","violet")
 D RPTVFUN^MIOUIBILL(.TCTX,4,"Appeal or follow-up","126 claims","15.0","amber")
 Q
 ;
RFORECAST(TCTX)
 S TCTX("billReportForecast","headline")="Six-week cash forecast"
 S TCTX("billReportForecast","subhead")="Projected collections compared with conservative, commit, and stretch ranges."
 D RPTVPROJ^MIOUIBILL(.TCTX,1,"Week 1","$76.4k","48","63","72","80","Front-loaded commercial remits hold steady after current queue clearance.","emerald")
 D RPTVPROJ^MIOUIBILL(.TCTX,2,"Week 2","$74.8k","44","58","69","78","One Medicare Advantage cycle lands later than normal.","sky")
 D RPTVPROJ^MIOUIBILL(.TCTX,3,"Week 3","$71.1k","40","54","65","76","Appeal packet lag narrows the mid-month cash window.","amber")
 D RPTVPROJ^MIOUIBILL(.TCTX,4,"Week 4","$79.2k","49","66","75","82","Expected rebound after backlogged auth approvals convert to paid claims.","violet")
 D RPTVPROJ^MIOUIBILL(.TCTX,5,"Week 5","$82.7k","53","70","80","86","Commercial and employer-plan mix improves average posted cash.","emerald")
 D RPTVPROJ^MIOUIBILL(.TCTX,6,"Week 6","$84.5k","56","73","83","88","Stretch case assumes same-day appeal closure remains above target.","sky")
 D RPTVSCN^MIOUIBILL(.TCTX,1,"Constrained case","$422k","90.8%","$101k >60","One large payer drifts outside normal remit timing and appeal packets stay above 48 hours.","rose")
 D RPTVSCN^MIOUIBILL(.TCTX,2,"Commit case","$468k","92.6%","$88k >60","Current queue throughput holds and auth recovery remains same day for top-dollar holds.","emerald")
 D RPTVSCN^MIOUIBILL(.TCTX,3,"Stretch case","$493k","93.8%","$79k >60","Appeal packet turnaround compresses below 24 hours and payer variance remains favorable.","violet")
 D RPTVBRDG^MIOUIBILL(.TCTX,1,"Opening expected cash","$318.4k","100","up","Baseline expectation from current remit cadence and posted cash trend.","sky")
 D RPTVBRDG^MIOUIBILL(.TCTX,2,"Authorization holds","-$18.4k","22","down","High-dollar auth recovery still blocks several clean remits.","amber")
 D RPTVBRDG^MIOUIBILL(.TCTX,3,"Medical necessity appeals","-$15.9k","18","down","Appeal packets remain the main timing risk inside the forecast window.","rose")
 D RPTVBRDG^MIOUIBILL(.TCTX,4,"Weekend remit lag","-$6.7k","10","down","Weekend staffing keeps Saturday and Sunday posting lighter than target.","slate")
 D RPTVBRDG^MIOUIBILL(.TCTX,5,"Rebill recovery upside","+$28.6k","31","up","Resolved eligibility and modifier edits add recoverable upside.","emerald")
 D RPTVBRDG^MIOUIBILL(.TCTX,6,"Projected close","$468.0k","88","up","Commit path close after risk and upside adjustment.","violet")
 Q
 ;
RBENCH(TCTX)
 S TCTX("billReportBench","headline")="Peer and payer benchmark ladder"
 S TCTX("billReportBench","subhead")="Internal results plotted against peer median and top-quartile targets."
 D RPTVBEN^MIOUIBILL(.TCTX,1,"Net collection rate","96.2%","95.0%","97.4%","72","Above peer median with room to close top-quartile gap.","emerald")
 D RPTVBEN^MIOUIBILL(.TCTX,2,"First-pass rate","92.4%","90.7%","94.1%","68","Strong edit prevention keeps the team in the upper tier.","sky")
 D RPTVBEN^MIOUIBILL(.TCTX,3,"Denial rate","4.3%","5.1%","3.6%","61","Better than peer median, but still trailing the best-performing cohort.","amber")
 D RPTVBEN^MIOUIBILL(.TCTX,4,"Days to pay","20.6","23.4","17.8","66","Internal cycle time remains favorable across commercial mix.","violet")
 D RPTVBEN^MIOUIBILL(.TCTX,5,"AR > 90 days","21.2%","24.8%","18.6%","64","Old A/R concentration is improving but not yet top quartile.","rose")
 D RPTVBROW^MIOUIBILL(.TCTX,1,"Net collection rate")
 D RPTVBCELL^MIOUIBILL(.TCTX,1,1,"Commercial","96.8%","0.82","emerald")
 D RPTVBCELL^MIOUIBILL(.TCTX,1,2,"Medicare Advantage","95.9%","0.73","sky")
 D RPTVBCELL^MIOUIBILL(.TCTX,1,3,"Managed Medicaid","94.8%","0.58","amber")
 D RPTVBCELL^MIOUIBILL(.TCTX,1,4,"Employer Plan","96.1%","0.76","violet")
 D RPTVBROW^MIOUIBILL(.TCTX,2,"First-pass rate")
 D RPTVBCELL^MIOUIBILL(.TCTX,2,1,"Commercial","93.1%","0.76","emerald")
 D RPTVBCELL^MIOUIBILL(.TCTX,2,2,"Medicare Advantage","91.2%","0.61","amber")
 D RPTVBCELL^MIOUIBILL(.TCTX,2,3,"Managed Medicaid","90.6%","0.55","amber")
 D RPTVBCELL^MIOUIBILL(.TCTX,2,4,"Employer Plan","92.8%","0.71","sky")
 D RPTVBROW^MIOUIBILL(.TCTX,3,"Denial rate")
 D RPTVBCELL^MIOUIBILL(.TCTX,3,1,"Commercial","3.7%","0.42","emerald")
 D RPTVBCELL^MIOUIBILL(.TCTX,3,2,"Medicare Advantage","4.6%","0.63","amber")
 D RPTVBCELL^MIOUIBILL(.TCTX,3,3,"Managed Medicaid","5.4%","0.81","rose")
 D RPTVBCELL^MIOUIBILL(.TCTX,3,4,"Employer Plan","4.1%","0.52","sky")
 D RPTVBROW^MIOUIBILL(.TCTX,4,"Days to pay")
 D RPTVBCELL^MIOUIBILL(.TCTX,4,1,"Commercial","17.8","0.46","emerald")
 D RPTVBCELL^MIOUIBILL(.TCTX,4,2,"Medicare Advantage","24.9","0.84","rose")
 D RPTVBCELL^MIOUIBILL(.TCTX,4,3,"Managed Medicaid","21.6","0.66","amber")
 D RPTVBCELL^MIOUIBILL(.TCTX,4,4,"Employer Plan","19.2","0.54","sky")
 D RPTVSCORE^MIOUIBILL(.TCTX,1,"North Harbor Health Plan","92 / 100","Top 10%","Best net collection and strongest same-week cash conversion.","emerald")
 D RPTVSCORE^MIOUIBILL(.TCTX,2,"Apex Commercial PPO","88 / 100","Top 20%","Fast payment cycle and low denial pressure across infusion claims.","sky")
 D RPTVSCORE^MIOUIBILL(.TCTX,3,"Summit Medicaid Managed","81 / 100","Top 35%","Steady but still exposed to eligibility rework and slower appeals.","amber")
 D RPTVSCORE^MIOUIBILL(.TCTX,4,"Tri-State Employer Health","76 / 100","Top 45%","Higher variance and slower remit timing drag the overall ranking.","violet")
 Q
 ;
RCASH(TCTX)
 S TCTX("billReportCash","headline")="Posted cash run-rate"
 S TCTX("billReportCash","subhead")="Eight-day posted cash rhythm across the current operating window with darker light-theme bars for fast operator scan."
 D RPTCRUN^MIOUIBILL(.TCTX,1,"Mon","$38.6k","61","ERA backlog cleared after weekend intake.","emerald")
 D RPTCRUN^MIOUIBILL(.TCTX,2,"Tue","$41.9k","66","Commercial remits posted early in the morning cycle.","sky")
 D RPTCRUN^MIOUIBILL(.TCTX,3,"Wed","$37.2k","58","Appeal receipts landed but one payer lagged into the afternoon.","amber")
 D RPTCRUN^MIOUIBILL(.TCTX,4,"Thu","$46.5k","73","Best same-week conversion after auth cleanup.","violet")
 D RPTCRUN^MIOUIBILL(.TCTX,5,"Fri","$49.8k","78","High-value home infusion batch closed before cutoff.","emerald")
 D RPTCRUN^MIOUIBILL(.TCTX,6,"Sat","$28.1k","44","Weekend posting crew worked only priority remits.","slate")
 D RPTCRUN^MIOUIBILL(.TCTX,7,"Sun","$23.4k","37","Carryover activity only with no full remit team.","slate")
 D RPTCRUN^MIOUIBILL(.TCTX,8,"Today","$31.6k","52","Current day pace is tracking above the prior Tuesday at noon.","sky")
 D RPTCMIX^MIOUIBILL(.TCTX,1,"ERA auto-post","$118.4k","41","emerald")
 D RPTCMIX^MIOUIBILL(.TCTX,2,"Manual remit posting","$76.2k","27","sky")
 D RPTCMIX^MIOUIBILL(.TCTX,3,"Appeal recovery","$49.7k","17","amber")
 D RPTCMIX^MIOUIBILL(.TCTX,4,"Rebill conversion","$43.5k","15","violet")
 D RPTCLAG^MIOUIBILL(.TCTX,1,"North Harbor Health Plan","18.4 hours","36","Fastest remit-to-post cycle in the current payer mix.","emerald")
 D RPTCLAG^MIOUIBILL(.TCTX,2,"Apex Commercial PPO","22.7 hours","45","Stable remit arrival with predictable overnight queueing.","sky")
 D RPTCLAG^MIOUIBILL(.TCTX,3,"Lakeview Senior Advantage","28.9 hours","57","Aging mostly tied to manual remit balancing steps.","amber")
 D RPTCLAG^MIOUIBILL(.TCTX,4,"Tri-State Employer Health","33.6 hours","66","Employer-plan files continue to land later than the rest of the mix.","rose")
 D RPTCLAG^MIOUIBILL(.TCTX,5,"Summit Medicaid Managed","26.2 hours","52","Recovery improved after eligibility edits dropped.","violet")
 Q
 ;
RDENIAL(TCTX)
 S TCTX("billReportDenial","headline")="Denial reason stream"
 S TCTX("billReportDenial","subhead")="Open, appealed, and closed posture by denial family so supervisors can spot pressure before it distorts cash timing."
 D RPTDSTREAM^MIOUIBILL(.TCTX,1,"Authorization","62","21","17","Authorization gaps are still concentrated in late-added infusion orders.","amber")
 D RPTDSTREAM^MIOUIBILL(.TCTX,2,"Medical necessity","54","26","20","Appeal packets are moving, but supporting documentation still arrives late from ordering providers.","rose")
 D RPTDSTREAM^MIOUIBILL(.TCTX,3,"Eligibility","41","18","41","Front-end verification fixes are closing a larger share before rebill aging grows.","sky")
 D RPTDSTREAM^MIOUIBILL(.TCTX,4,"Coding and modifier","36","24","40","Coder feedback loop is keeping modifier-related denials shorter lived.","violet")
 D RPTDROW^MIOUIBILL(.TCTX,1,"Authorization")
 D RPTDCELL^MIOUIBILL(.TCTX,1,1,"Commercial","18","0.72","amber")
 D RPTDCELL^MIOUIBILL(.TCTX,1,2,"Medicare Advantage","14","0.58","amber")
 D RPTDCELL^MIOUIBILL(.TCTX,1,3,"Managed Medicaid","9","0.44","sky")
 D RPTDCELL^MIOUIBILL(.TCTX,1,4,"Employer Plan","12","0.52","violet")
 D RPTDROW^MIOUIBILL(.TCTX,2,"Medical necessity")
 D RPTDCELL^MIOUIBILL(.TCTX,2,1,"Commercial","21","0.84","rose")
 D RPTDCELL^MIOUIBILL(.TCTX,2,2,"Medicare Advantage","17","0.71","rose")
 D RPTDCELL^MIOUIBILL(.TCTX,2,3,"Managed Medicaid","8","0.39","amber")
 D RPTDCELL^MIOUIBILL(.TCTX,2,4,"Employer Plan","10","0.46","violet")
 D RPTDROW^MIOUIBILL(.TCTX,3,"Eligibility")
 D RPTDCELL^MIOUIBILL(.TCTX,3,1,"Commercial","11","0.48","sky")
 D RPTDCELL^MIOUIBILL(.TCTX,3,2,"Medicare Advantage","13","0.56","sky")
 D RPTDCELL^MIOUIBILL(.TCTX,3,3,"Managed Medicaid","16","0.69","amber")
 D RPTDCELL^MIOUIBILL(.TCTX,3,4,"Employer Plan","7","0.33","violet")
 D RPTDROW^MIOUIBILL(.TCTX,4,"Coding and modifier")
 D RPTDCELL^MIOUIBILL(.TCTX,4,1,"Commercial","8","0.36","violet")
 D RPTDCELL^MIOUIBILL(.TCTX,4,2,"Medicare Advantage","6","0.28","violet")
 D RPTDCELL^MIOUIBILL(.TCTX,4,3,"Managed Medicaid","9","0.43","amber")
 D RPTDCELL^MIOUIBILL(.TCTX,4,4,"Employer Plan","12","0.51","rose")
 D RPTDAGE^MIOUIBILL(.TCTX,1,"0-2 days","18 cases","36","Fresh denials still inside same-day or next-day triage.","emerald")
 D RPTDAGE^MIOUIBILL(.TCTX,2,"3-5 days","14 cases","28","Most records are already in packet-building posture.","sky")
 D RPTDAGE^MIOUIBILL(.TCTX,3,"6-10 days","9 cases","18","Follow-up work remains concentrated in medical necessity review.","amber")
 D RPTDAGE^MIOUIBILL(.TCTX,4,"11-15 days","6 cases","12","Escalations are beginning to accumulate in employer-plan denials.","violet")
 D RPTDAGE^MIOUIBILL(.TCTX,5,"16+ days","3 cases","6","These are the oldest open appeals and should be cleared first.","rose")
 Q
 ;

RPRODUCT(TCTX)
 S TCTX("billReportProd","headline")="Collector and biller productivity"
 S TCTX("billReportProd","subhead")="A throughput-focused SSR readout for touches per day, queue concentration, same-day resolution, and backlog glidepath."
 D RPTPTEAM^MIOUIBILL(.TCTX,1,"K. Morgan","94 touches","88","Authorization and appeal cleanup remained the biggest same-day cash unlock.","sky")
 D RPTPTEAM^MIOUIBILL(.TCTX,2,"T. Reyes","87 touches","81","Appeal packet completion sped up after medical-necessity template cleanup.","violet")
 D RPTPTEAM^MIOUIBILL(.TCTX,3,"B. Ortega","82 touches","76","Balanced mix across follow-up, underpayments, and denial replay work.","emerald")
 D RPTPTEAM^MIOUIBILL(.TCTX,4,"J. Mercer","74 touches","69","Coding queue stabilized after modifier review moved upstream.","amber")
 D RPTPTEAM^MIOUIBILL(.TCTX,5,"D. Sutton","68 touches","61","Eligibility replay remained choppy but same-day close rate still improved.","rose")
 D RPTPROW^MIOUIBILL(.TCTX,1,"Follow-up")
 D RPTPCELL^MIOUIBILL(.TCTX,1,1,"Mon","24","0.48","sky")
 D RPTPCELL^MIOUIBILL(.TCTX,1,2,"Tue","26","0.53","sky")
 D RPTPCELL^MIOUIBILL(.TCTX,1,3,"Wed","23","0.46","sky")
 D RPTPCELL^MIOUIBILL(.TCTX,1,4,"Thu","27","0.56","sky")
 D RPTPROW^MIOUIBILL(.TCTX,2,"Denials")
 D RPTPCELL^MIOUIBILL(.TCTX,2,1,"Mon","15","0.39","rose")
 D RPTPCELL^MIOUIBILL(.TCTX,2,2,"Tue","18","0.44","rose")
 D RPTPCELL^MIOUIBILL(.TCTX,2,3,"Wed","16","0.41","rose")
 D RPTPCELL^MIOUIBILL(.TCTX,2,4,"Thu","17","0.43","rose")
 D RPTPROW^MIOUIBILL(.TCTX,3,"Underpayments")
 D RPTPCELL^MIOUIBILL(.TCTX,3,1,"Mon","11","0.34","amber")
 D RPTPCELL^MIOUIBILL(.TCTX,3,2,"Tue","13","0.38","amber")
 D RPTPCELL^MIOUIBILL(.TCTX,3,3,"Wed","12","0.36","amber")
 D RPTPCELL^MIOUIBILL(.TCTX,3,4,"Thu","14","0.40","amber")
 D RPTPROW^MIOUIBILL(.TCTX,4,"Eligibility")
 D RPTPCELL^MIOUIBILL(.TCTX,4,1,"Mon","9","0.29","emerald")
 D RPTPCELL^MIOUIBILL(.TCTX,4,2,"Tue","10","0.31","emerald")
 D RPTPCELL^MIOUIBILL(.TCTX,4,3,"Wed","8","0.26","emerald")
 D RPTPCELL^MIOUIBILL(.TCTX,4,4,"Thu","12","0.33","emerald")
 D RPTPLEAD^MIOUIBILL(.TCTX,1,"K. Morgan","Same-day resolution 84%","Top closer","Authorization holds converted to clean rebills before noon.","emerald")
 D RPTPLEAD^MIOUIBILL(.TCTX,2,"T. Reyes","Appeal packet cycle 1.9 days","Fastest appeals","Medical-necessity packets moved faster after checklist cleanup.","violet")
 D RPTPLEAD^MIOUIBILL(.TCTX,3,"B. Ortega","Underpayment recoveries $8.4k","Best leakage catch","High-value employer-plan variances were resolved inside two days.","amber")
 D RPTPLEAD^MIOUIBILL(.TCTX,4,"D. Sutton","Eligibility replay close 78%","Verification lift","Front-end corrections kept rebills from rolling into older aging buckets.","sky")
 D RPTPSLOPE^MIOUIBILL(.TCTX,1,"Mon","126 open","82","Backlog began higher after weekend carryover.","rose")
 D RPTPSLOPE^MIOUIBILL(.TCTX,2,"Tue","118 open","76","Same-day auth cleanup reduced active follow-up load.","amber")
 D RPTPSLOPE^MIOUIBILL(.TCTX,3,"Wed","111 open","71","Appeal packet output improved midweek.","sky")
 D RPTPSLOPE^MIOUIBILL(.TCTX,4,"Thu","104 open","66","Underpayment team cleared older employer-plan spread cases.","violet")
 D RPTPSLOPE^MIOUIBILL(.TCTX,5,"Fri","97 open","61","Friday close posture stayed below the 100-open mark.","emerald")
 D RPTPSLOPE^MIOUIBILL(.TCTX,6,"Sat","101 open","64","Weekend intake lifted the visible queue slightly.","slate")
 Q
 ;
RUNDER(TCTX)
 S TCTX("billReportUnder","headline")="Underpayment leakage map"
 S TCTX("billReportUnder","subhead")="Track expected-versus-paid variance by payer, service line, and contract family without leaving the SSR billing shell."
 D RPTUWF^MIOUIBILL(.TCTX,1,"Gross charges","$482.9k","100","up","Starting submitted charge base for the week.","slate")
 D RPTUWF^MIOUIBILL(.TCTX,2,"Expected allowed","$344.7k","71","down","Contracted expected allowables after fee-schedule normalization.","sky")
 D RPTUWF^MIOUIBILL(.TCTX,3,"Expected paid","$328.4k","68","down","Expected paid after patient-share and sequestration logic.","emerald")
 D RPTUWF^MIOUIBILL(.TCTX,4,"Paid","$309.6k","64","down","Actual paid dollars posted across ERA and manual remit streams.","violet")
 D RPTUWF^MIOUIBILL(.TCTX,5,"Leakage gap","$18.8k","4","down","Current recoverable spread before appeal and contract review.","rose")
 D RPTULANE^MIOUIBILL(.TCTX,1,"North Harbor Health Plan","$3.9k","21","Mostly timing variance on infusion drug lines.","emerald")
 D RPTULANE^MIOUIBILL(.TCTX,2,"Lakeview Senior Advantage","$5.4k","29","Largest spread this week, concentrated in home infusion drugs.","rose")
 D RPTULANE^MIOUIBILL(.TCTX,3,"Apex Commercial PPO","$4.1k","22","Variance is concentrated in pump supply bundling.","amber")
 D RPTULANE^MIOUIBILL(.TCTX,4,"Tri-State Employer Health","$5.4k","28","Employer-plan schedule lag is still creating payment drift.","violet")
 D RPTUROW^MIOUIBILL(.TCTX,1,"Infusion administration")
 D RPTUCELL^MIOUIBILL(.TCTX,1,1,"Commercial","$1.8k","0.43","sky")
 D RPTUCELL^MIOUIBILL(.TCTX,1,2,"Medicare Advantage","$1.4k","0.38","amber")
 D RPTUCELL^MIOUIBILL(.TCTX,1,3,"Employer Plan","$1.9k","0.46","rose")
 D RPTUCELL^MIOUIBILL(.TCTX,1,4,"Managed Medicaid","$0.8k","0.24","emerald")
 D RPTUROW^MIOUIBILL(.TCTX,2,"Pump supplies")
 D RPTUCELL^MIOUIBILL(.TCTX,2,1,"Commercial","$1.2k","0.35","amber")
 D RPTUCELL^MIOUIBILL(.TCTX,2,2,"Medicare Advantage","$1.6k","0.42","violet")
 D RPTUCELL^MIOUIBILL(.TCTX,2,3,"Employer Plan","$1.5k","0.39","rose")
 D RPTUCELL^MIOUIBILL(.TCTX,2,4,"Managed Medicaid","$0.7k","0.21","sky")
 D RPTUROW^MIOUIBILL(.TCTX,3,"Home infusion drugs")
 D RPTUCELL^MIOUIBILL(.TCTX,3,1,"Commercial","$2.9k","0.61","rose")
 D RPTUCELL^MIOUIBILL(.TCTX,3,2,"Medicare Advantage","$2.1k","0.54","amber")
 D RPTUCELL^MIOUIBILL(.TCTX,3,3,"Employer Plan","$3.1k","0.66","rose")
 D RPTUCELL^MIOUIBILL(.TCTX,3,4,"Managed Medicaid","$1.2k","0.33","sky")
 D RPTUROW^MIOUIBILL(.TCTX,4,"Nursing visits")
 D RPTUCELL^MIOUIBILL(.TCTX,4,1,"Commercial","$1.1k","0.28","sky")
 D RPTUCELL^MIOUIBILL(.TCTX,4,2,"Medicare Advantage","$0.9k","0.24","emerald")
 D RPTUCELL^MIOUIBILL(.TCTX,4,3,"Employer Plan","$1.4k","0.31","violet")
 D RPTUCELL^MIOUIBILL(.TCTX,4,4,"Managed Medicaid","$0.6k","0.18","emerald")
 D RPTUCARD^MIOUIBILL(.TCTX,1,"Commercial infusion spread","$6.1k","Commercial infusion drug lines still carry the largest single-family expected-versus-paid gap.","rose")
 D RPTUCARD^MIOUIBILL(.TCTX,2,"Employer schedule lag","$5.4k","Employer-plan remits continue to underpay against updated schedules until contract tables are refreshed.","violet")
 D RPTUCARD^MIOUIBILL(.TCTX,3,"Pump-supply bundling","$4.1k","Bundled pump-supply logic is compressing allowed amounts more than expected in two payer families.","amber")
 D RPTUCARD^MIOUIBILL(.TCTX,4,"Recovered this week","$8.4k","Resolved underpayments were concentrated in commercial infusion admin and employer-plan supply lines.","emerald")
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
