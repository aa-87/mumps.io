MIOUIBILLT005 ; Billing report builder contract tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIBILLT005"
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N TCTX
 D RPTHDR^MIOUIBILL(.TCTX,"March revenue cycle snapshot","Week ending 2026-03-13","Refreshed 08:07 AM","sky")
 D RPTFILTER^MIOUIBILL(.TCTX,1,"Facility","North Harbor Infusion")
 D RPTKPI^MIOUIBILL(.TCTX,1,"Gross Charges","$482,914.22","+6.4% vs prior week","Home infusion volume remained elevated.","sky")
 D RPTTAB^MIOUIBILL(.TCTX,1,"summary","Summary",6,1)
 D RPTAGING^MIOUIBILL(.TCTX,1,"Current","$182,441.20","418","42.7%","emerald")
 D RPTPAYER^MIOUIBILL(.TCTX,1,"North Harbor Health Plan","$122,408.00","$83,114.55","14","17.2","+3.8%","emerald")
 D RPTREASON^MIOUIBILL(.TCTX,1,"Authorization missing or invalid","31","$18,440.22","Route same-day follow-up.","amber")
 D RPTEXPORT^MIOUIBILL(.TCTX,1,"Daily aging workbook","XLSX","Weekdays · 06:30 AM","finance@northlight.example","Ready","emerald")
 D RPTFLAG^MIOUIBILL(.TCTX,1,"Auto-close small balance","Closed 43 balances under $5.","emerald")
 D EQ^MIOUIT000(.FAIL,"[T001][report title]",$G(TCTX("billReport","header","title")),"March revenue cycle snapshot")
 D EQ^MIOUIT000(.FAIL,"[T001][report badge]",$G(TCTX("billReport","header","badgeClass")),"badge-sky")
 D EQ^MIOUIT000(.FAIL,"[T001][filter label]",$G(TCTX("billReport","filter",1,"label")),"Facility")
 D EQ^MIOUIT000(.FAIL,"[T001][kpi value]",$G(TCTX("billReport","kpi",1,"value")),"$482,914.22")
 D EQ^MIOUIT000(.FAIL,"[T001][tab key]",$G(TCTX("billReport","tab",1,"key")),"summary")
 D EQ^MIOUIT000(.FAIL,"[T001][aging bucket]",$G(TCTX("billReport","aging",1,"bucket")),"Current")
 D EQ^MIOUIT000(.FAIL,"[T001][payer]",$G(TCTX("billReport","payer",1,"payer")),"North Harbor Health Plan")
 D EQ^MIOUIT000(.FAIL,"[T001][reason count]",$G(TCTX("billReport","reason",1,"count")),"31")
 D EQ^MIOUIT000(.FAIL,"[T001][export status]",$G(TCTX("billReport","export",1,"status")),"Ready")
 D EQ^MIOUIT000(.FAIL,"[T001][flag title]",$G(TCTX("billReport","flag",1,"title")),"Auto-close small balance")
 Q
 ;
