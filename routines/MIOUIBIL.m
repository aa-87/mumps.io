MIOUIBIL ; MIOUI billing review builders
 Q
 ;
CLAIM(TCTX,IDX,CLAIM,PATIENT,SUBSCRIBER,DOS,TOTAL,STATUS,TONE)
 N N
 S N=+$G(IDX)
 S TCTX("claimCard",N,"claim")=$G(CLAIM)
 S TCTX("claimCard",N,"patient")=$G(PATIENT)
 S TCTX("claimCard",N,"subscriber")=$G(SUBSCRIBER)
 S TCTX("claimCard",N,"dateOfService")=$G(DOS)
 S TCTX("claimCard",N,"totalCharge")=$G(TOTAL)
 S TCTX("claimCard",N,"status")=$G(STATUS)
 S TCTX("claimCard",N,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("claimCard",N,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 S TCTX("claimCardAny")=1
 Q
 ;
VALSUM(TCTX,WARN,ERR,INFO,PUBLISHABLE,STATE,TONE)
 S TCTX("validation","warnings")=+$G(WARN)
 S TCTX("validation","errors")=+$G(ERR)
 S TCTX("validation","info")=+$G(INFO)
 S TCTX("validation","publishable")=+$G(PUBLISHABLE)
 S TCTX("validation","publishState")=$G(STATE)
 S TCTX("validation","badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("validation","panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
DIAG(TCTX,KIND,IDX,CODE,MSG,PATH,HINT)
 N N,S,T
 S N=+$G(IDX),S=$ZCONVERT($G(KIND),"L")
 I S="" S S="info"
 I S'="warning",S'="error",S'="info" S S="info"
 S T=$S(S="warning":"amber",S="error":"rose",1:"sky")
 S TCTX("diagnosticList",S,N,"severity")=$$UP(S)
 S TCTX("diagnosticList",S,N,"code")=$G(CODE)
 S TCTX("diagnosticList",S,N,"message")=$G(MSG)
 S TCTX("diagnosticList",S,N,"path")=$G(PATH)
 S TCTX("diagnosticList",S,N,"hint")=$G(HINT)
 S TCTX("diagnosticList",S,N,"badgeClass")=$$BADGE^MIOUITHEME(T)
 S TCTX("diagnosticList",S,N,"panelClass")=$$PANEL^MIOUITHEME(T)
 S TCTX("diagnosticList",S_"Any")=1
 S TCTX("diagnosticListAny")=1
 Q
 ;
ARTMETA(TCTX,KEY,LABEL,DESC,TONE)
 N K
 S K=$G(KEY)
 S TCTX("artifactGroup",K,"label")=$G(LABEL)
 S TCTX("artifactGroup",K,"desc")=$G(DESC)
 S TCTX("artifactGroup",K,"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 S TCTX("artifactGroupAny")=1
 Q
 ;
ARTROW(TCTX,KEY,IDX,NAME,BADGE,HREF,TYPE)
 N K,N
 S K=$G(KEY),N=+$G(IDX)
 S TCTX("artifactGroup",K,"item",N,"name")=$G(NAME)
 S TCTX("artifactGroup",K,"item",N,"badge")=$G(BADGE)
 S TCTX("artifactGroup",K,"item",N,"href")=$G(HREF)
 S TCTX("artifactGroup",K,"item",N,"type")=$G(TYPE)
 S TCTX("artifactGroup",K,"item",N,"badgeClass")="badge-slate"
 S TCTX("artifactGroup",K,"hasItems")=1
 S TCTX("artifactGroupAny")=1
 Q
 ;
META(TCTX,IDX,LABEL,VALUE)
 S TCTX("claimMeta",+$G(IDX),"label")=$G(LABEL)
 S TCTX("claimMeta",+$G(IDX),"value")=$G(VALUE)
 Q
 ;
UP(X)
 N Y
 S Y=$ZCONVERT($G(X),"L")
 I Y="" Q ""
 Q $ZCONVERT($E(Y),"U")_$E(Y,2,$L(Y))
 ;
