MIOUITDMO ; MIOUI demo render smoke tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL)
 S LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 D T020(.LOCAL)
 D T030(.LOCAL)
 D T040(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUITDMO"
 . Q
 I LOCAL S FAIL=1
 Q
 ;
BASECONF(CONF)
 D CONFDEF^MIOUI(.CONF)
 Q
 ;
T001(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDHOME^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_home.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ(.FAIL,"[T001][render ok]",$D(ERR),0)
 D EQ(.FAIL,"[T001][contains brand]",OUT["MIOUI",1)
 D EQ(.FAIL,"[T001][contains dense]",OUT["Dense data surfaces",1)
 Q
 ;
T010(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDCOMP^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_components.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ(.FAIL,"[T010][render ok]",$D(ERR),0)
 D EQ(.FAIL,"[T010][alerts]",OUT["Warning",1)
 D EQ(.FAIL,"[T010][timeline]",OUT["Template context built",1)
 Q
 ;
T020(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDTABLES^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_tables.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ(.FAIL,"[T020][render ok]",$D(ERR),0)
 D EQ(.FAIL,"[T020][claims row]",OUT["CLM-1001",1)
 D EQ(.FAIL,"[T020][audit title]",OUT["Audit log",1)
 Q
 ;
T030(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDBILL^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_billing.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ(.FAIL,"[T030][render ok]",$D(ERR),0)
 D EQ(.FAIL,"[T030][claim preview]",OUT["Claim preview",1)
 D EQ(.FAIL,"[T030][artifact]",OUT["roundtrip-report.json",1)
 Q
 ;
T040(FAIL)
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D BASECONF(.CONF)
 D BUILDFORMS^MIOUIDEMO(.CONF,.REQ,.CTX,.TCTX)
 D RENDER^MIOUIDEMO("pages/mioui_forms.html",.CONF,.CTX,.TCTX,.OUT,.ERR)
 D EQ(.FAIL,"[T040][render ok]",$D(ERR),0)
 D EQ(.FAIL,"[T040][profile title]",OUT["Export profile",1)
 D EQ(.FAIL,"[T040][filter title]",OUT["Review filters",1)
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
