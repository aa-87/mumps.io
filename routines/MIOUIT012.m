MIOUIT012 ; ROI2 billing review surface tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIT012"
 I LOCAL S FAIL=1
 Q
 ;
BASECONF(CONF)
 D CONFDEF^MIOUI(.CONF)
 Q
 ;
T001(FAIL)
 N TCTX
 D CLAIM^MIOUIBIL(.TCTX,1,"CLM-1001","JANE DOE","ALPHA HEALTH","2026-03-01","125.00","Previewed","sky")
 D VALSUM^MIOUIBIL(.TCTX,1,0,2,1,"Publishable","emerald")
 D DIAG^MIOUIBIL(.TCTX,"warning",1,"SV201","Modifier missing","2400/SV1/03","Review payer rules")
 D META^MIOUIBIL(.TCTX,1,"Profile","Claim summary")
 D ARTMETA^MIOUIBIL(.TCTX,"canonical","Canonical artifacts","Stable outputs","sky")
 D ARTROW^MIOUIBIL(.TCTX,"canonical",1,"claims.csv","CSV","/download/claims","csv")
 D EQ^MIOUIT000(.FAIL,"[T001][claim id]",$G(TCTX("claimCard",1,"claim")),"CLM-1001")
 D EQ^MIOUIT000(.FAIL,"[T001][claim badge]",$G(TCTX("claimCard",1,"badgeClass")),"badge-sky")
 D EQ^MIOUIT000(.FAIL,"[T001][publishable]",+$G(TCTX("validation","publishable")),1)
 D EQ^MIOUIT000(.FAIL,"[T001][validation badge]",$G(TCTX("validation","badgeClass")),"badge-emerald")
 D EQ^MIOUIT000(.FAIL,"[T001][diag severity]",$G(TCTX("diagnosticList","warning",1,"severity")),"Warning")
 D EQ^MIOUIT000(.FAIL,"[T001][diag code]",$G(TCTX("diagnosticList","warning",1,"code")),"SV201")
 D EQ^MIOUIT000(.FAIL,"[T001][meta]",$G(TCTX("claimMeta",1,"value")),"Claim summary")
 D EQ^MIOUIT000(.FAIL,"[T001][artifact item]",$G(TCTX("artifactGroup","canonical","item",1,"name")),"claims.csv")
 D EQ^MIOUIT000(.FAIL,"[T001][artifact badge]",$G(TCTX("artifactGroup","canonical","item",1,"badgeClass")),"badge-slate")
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDBILL^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_billing.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T010][claim summary]",OUT,"CLM-1001")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][dos]",OUT,"Date of service")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][service line]",OUT,"99213")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][validation]",OUT,"Publishable")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][diagnostic]",OUT,"SV201")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][artifact group]",OUT,"Canonical artifacts")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][download row]",OUT,"claims.csv")
 Q
 ;
