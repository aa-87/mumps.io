MIOUIT013 ; ROI3 export and profile editor surface tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 D T020(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIT013"
 I LOCAL S FAIL=1
 Q
 ;
BASECONF(CONF)
 D CONFDEF^MIOUI(.CONF)
 Q
 ;
T001(FAIL)
 N TCTX
 D SUMINIT^MIOUIEXP(.TCTX,"main","Export profile summary","Compact rule summary")
 D SUMSTAT^MIOUIEXP(.TCTX,"main",1,"Mode","Claim summary","sky")
 D SUMRULE^MIOUIEXP(.TCTX,"main",1,"Delimiter","Comma")
 D CHKINIT^MIOUIEXP(.TCTX,"fieldCatalog","Field catalog","Dense checkbox catalog")
 D CHKITEM^MIOUIEXP(.TCTX,"fieldCatalog",1,"claim_id","Claim ID","Stable key",1)
 D CHKITEM^MIOUIEXP(.TCTX,"fieldCatalog",2,"dos","Date of service","High-value billing field",0)
 D CHKFINAL^MIOUIEXP(.TCTX,"fieldCatalog")
 D ORDINIT^MIOUIEXP(.TCTX,"selectedFields","Selected field order","Explicit row order")
 D ORDITEM^MIOUIEXP(.TCTX,"selectedFields",1,"Claim ID","claim_id")
 D ORDITEM^MIOUIEXP(.TCTX,"selectedFields",2,"Date of service","date_of_service")
 D ORDFINAL^MIOUIEXP(.TCTX,"selectedFields")
 D FOOTINIT^MIOUIEXP(.TCTX,"profile","Sticky actions","Visible primary actions")
 D FOOTACT^MIOUIEXP(.TCTX,"profile",1,"Save profile","/save","primary-button")
 D EQ^MIOUIT000(.FAIL,"[T001][summary title]",$G(TCTX("exportProfile","main","title")),"Export profile summary")
 D EQ^MIOUIT000(.FAIL,"[T001][summary stat]",$G(TCTX("exportProfile","main","stat",1,"value")),"Claim summary")
 D EQ^MIOUIT000(.FAIL,"[T001][checked count]",+$G(TCTX("checkboxGroup","fieldCatalog","checkedCount")),1)
 D EQ^MIOUIT000(.FAIL,"[T001][order can down]",+$G(TCTX("columnEditor","selectedFields","item",1,"canMoveDown")),1)
 D EQ^MIOUIT000(.FAIL,"[T001][footer action]",$G(TCTX("stickyFooter","profile","action",1,"label")),"Save profile")
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDEXPORT^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_export.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T010][summary]",OUT,"Export profile summary")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][field catalog]",OUT,"Field catalog")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][selected count]",OUT,"4 selected")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][column order]",OUT,"Selected field order")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][move up]",OUT,"Move up")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][sticky footer]",OUT,"Preview sample")
 Q
 ;
T020(FAIL)
 N REG,I
 D LIST^MIOUIREG(.REG)
 S I=$$FIND^MIOUIREG(.REG,"checkbox_group")
 D EQ^MIOUIT000(.FAIL,"[T020][checkbox group status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T020][checkbox group test]",$G(REG(I,"test")),"MIOUIT013")
 S I=$$FIND^MIOUIREG(.REG,"column_order_editor")
 D EQ^MIOUIT000(.FAIL,"[T020][column editor status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"export_profile_summary")
 D EQ^MIOUIT000(.FAIL,"[T020][export summary status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"page_export")
 D EQ^MIOUIT000(.FAIL,"[T020][page export status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T020][page export kind]",$G(REG(I,"kind")),"page")
 Q
 ;
