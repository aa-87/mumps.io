MIOUIT040 ; profile variant page tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 D T020(.LOCAL)
 D T030(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIT040"
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
 D EQ^MIOUIT000(.FAIL,"[T001][variant count]",$$COUNT^MIOUICTX($NA(TCTX("variant"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][patient summary count]",$$COUNT^MIOUICTX($NA(TCTX("patient","summary"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][patient event count]",$$COUNT^MIOUICTX($NA(TCTX("patient","event"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][biller metric count]",$$COUNT^MIOUICTX($NA(TCTX("biller","metric"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][biller queue count]",$$COUNT^MIOUICTX($NA(TCTX("biller","queue"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][manager summary count]",$$COUNT^MIOUICTX($NA(TCTX("manager","summary"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][manager approval count]",$$COUNT^MIOUICTX($NA(TCTX("manager","approval"))),4)
 D EQ^MIOUIT000(.FAIL,"[T001][matrix row count]",$$COUNT^MIOUICTX($NA(TCTX("matrix","row"))),5)
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILD^MIOUIPRF(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_profile_variants.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T010][title]",OUT,"Profile variants")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][patient]",OUT,"Patient profile")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][biller]",OUT,"Biller profile")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][manager]",OUT,"Manager profile")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][matrix]",OUT,"Profile variant capability matrix")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][patient callback]",OUT,"openPatientProfile")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][patient outreach]",OUT,"launchPatientOutreachPlan")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][biller callback]",OUT,"manageBillerAssignments")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][manager callback]",OUT,"openManagerEscalationBoard")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][matrix callback]",OUT,"openProfileVariantStudio")
 Q
 ;
T020(FAIL)
 N CONF
 K ^MIO("ROUTE","RAW","GET","/mioui/profile-variants")
 D REG^MIOUIPRF(.CONF)
 D EQ^MIOUIT000(.FAIL,"[T020][route target]",$G(^MIO("ROUTE","RAW","GET","/mioui/profile-variants")),"PROFILES^MIOUIPRF")
 D EQ^MIOUIT000(.FAIL,"[T020][route auth]",+$G(^MIO("ROUTE","META","GET","/mioui/profile-variants","authRequired")),0)
 Q
 ;
T030(FAIL)
 N REG,I,ID
 D LIST^MIOUIREG(.REG)
 S I=$$FIND^MIOUIREG(.REG,"profile_variant_builder")
 D EQ^MIOUIT000(.FAIL,"[T030][builder status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T030][builder phase]",$G(REG(I,"phase")),"P1")
 D EQ^MIOUIT000(.FAIL,"[T030][builder test]",$G(REG(I,"test")),"MIOUIT040")
 F ID="profile_patient_dossier","profile_biller_workbench","profile_manager_command","profile_variant_capability_matrix","page_profile_variants" D
 . S I=$$FIND^MIOUIREG(.REG,ID)
 . D EQ^MIOUIT000(.FAIL,"[T030]["_ID_" status]",$G(REG(I,"status")),"implemented")
 Q
 ;
