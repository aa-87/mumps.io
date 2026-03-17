MIOUIT016 ; ROI6 trace and audit depth tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 D T020(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIT016"
 I LOCAL S FAIL=1
 Q
 ;
BASECONF(CONF)
 D CONFDEF^MIOUI(.CONF)
 Q
 ;
T001(FAIL)
 N TCTX
 D SUMINIT^MIOUITRA(.TCTX,"main","Trace summary","High-level review")
 D SUMSTAT^MIOUITRA(.TCTX,"main",1,"Coverage",4,"sky")
 D SUMSTAT^MIOUITRA(.TCTX,"main",2,"Warnings",1,"amber")
 D SUMFINAL^MIOUITRA(.TCTX,"main")
 D CARDINIT^MIOUITRA(.TCTX,"main","Trace detail","Selected claim detail","sky")
 D CARDFIELD^MIOUITRA(.TCTX,"main",1,"Claim","CLM-1001")
 D CARDACT^MIOUITRA(.TCTX,"main",1,"Open","/mioui/trace","primary-button")
 D CARDFINAL^MIOUITRA(.TCTX,"main")
 D LGINIT^MIOUITRA(.TCTX,"main","Grouped evidence","Artifacts and warnings")
 D LGROUP^MIOUITRA(.TCTX,"main",1,"Canonical artifacts","Stable outputs","sky")
 D LGROW^MIOUITRA(.TCTX,"main",1,1,"roundtrip-report.json","Trace evidence","violet")
 D LGFINAL^MIOUITRA(.TCTX,"main")
 D TLINIT^MIOUITRA(.TCTX,"main","Audit timeline","Ordered audit events")
 D TLITEM^MIOUITRA(.TCTX,"main",1,"08:19","Trace generated","roundtrip-report.json written.","violet")
 D TLFINAL^MIOUITRA(.TCTX,"main")
 D TBINIT^MIOUITRA(.TCTX,"main","Trace table","Path mapping review.","No rows")
 D TBCOL^MIOUITRA(.TCTX,"main",1,"Path","left")
 D TBCELL^MIOUITRA(.TCTX,"main",1,1,"2400/SV1/03")
 D TBFINAL^MIOUITRA(.TCTX,"main")
 D EQ^MIOUIT000(.FAIL,"[T001][summary count]",+$G(TCTX("traceSummary","main","count")),2)
 D EQ^MIOUIT000(.FAIL,"[T001][detail fields]",+$G(TCTX("detailCard","main","fieldCount")),1)
 D EQ^MIOUIT000(.FAIL,"[T001][detail actions]",+$G(TCTX("detailCard","main","actionCount")),1)
 D EQ^MIOUIT000(.FAIL,"[T001][group count]",+$G(TCTX("listGroup","main","groupCount")),1)
 D EQ^MIOUIT000(.FAIL,"[T001][timeline count]",+$G(TCTX("timeline","main","count")),1)
 D EQ^MIOUIT000(.FAIL,"[T001][trace rows]",+$G(TCTX("traceTable","main","rowCount")),1)
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDTRACE^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_trace.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ^MIOUIT000(.FAIL,"[T010][render ok]",$D(ERR),0)
 D CONTAINS^MIOUIT000(.FAIL,"[T010][trace summary]",OUT,"Trace summary")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][detail]",OUT,"Trace detail")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][list group]",OUT,"Canonical artifacts")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][timeline]",OUT,"Audit timeline")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][trace table]",OUT,"2400/SV1/03")
 D CONTAINS^MIOUIT000(.FAIL,"[T010][artifact]",OUT,"roundtrip-report.json")
 Q
 ;
T020(FAIL)
 N REG,I
 D LIST^MIOUIREG(.REG)
 S I=$$FIND^MIOUIREG(.REG,"trace_audit_builder")
 D EQ^MIOUIT000(.FAIL,"[T020][builder status]",$G(REG(I,"status")),"implemented")
 D EQ^MIOUIT000(.FAIL,"[T020][builder test]",$G(REG(I,"test")),"MIOUIT016")
 S I=$$FIND^MIOUIREG(.REG,"timeline_partial")
 D EQ^MIOUIT000(.FAIL,"[T020][timeline status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"list_group")
 D EQ^MIOUIT000(.FAIL,"[T020][list group status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"detail_card")
 D EQ^MIOUIT000(.FAIL,"[T020][detail card status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"trace_summary")
 D EQ^MIOUIT000(.FAIL,"[T020][trace summary status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"trace_table")
 D EQ^MIOUIT000(.FAIL,"[T020][trace table status]",$G(REG(I,"status")),"implemented")
 S I=$$FIND^MIOUIREG(.REG,"page_trace")
 D EQ^MIOUIT000(.FAIL,"[T020][trace page kind]",$G(REG(I,"kind")),"page")
 D EQ^MIOUIT000(.FAIL,"[T020][trace page status]",$G(REG(I,"status")),"implemented")
 Q
 ;
