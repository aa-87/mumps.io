MIOUIPRM ; MIOUI premium workflow enhancement builders
 Q
 ;
BARINIT(TCTX,KEY,TITLE,LEAD)
 K TCTX("commandBar",$G(KEY))
 S TCTX("commandBar",$G(KEY),"title")=$G(TITLE)
 S TCTX("commandBar",$G(KEY),"lead")=$G(LEAD)
 Q
 ;
BARGROUP(TCTX,KEY,GIDX,LABEL,LEAD)
 S TCTX("commandBar",$G(KEY),"group",+$G(GIDX),"label")=$G(LABEL)
 S TCTX("commandBar",$G(KEY),"group",+$G(GIDX),"lead")=$G(LEAD)
 Q
 ;
BARACT(TCTX,KEY,GIDX,AIDX,LABEL,HREF,CLASS)
 S TCTX("commandBar",$G(KEY),"group",+$G(GIDX),"action",+$G(AIDX),"label")=$G(LABEL)
 S TCTX("commandBar",$G(KEY),"group",+$G(GIDX),"action",+$G(AIDX),"href")=$G(HREF)
 S TCTX("commandBar",$G(KEY),"group",+$G(GIDX),"action",+$G(AIDX),"class")=$G(CLASS)
 Q
 ;
BARFINAL(TCTX,KEY)
 N G,A,GC,AC
 S (G,A,GC,AC)=0
 F  S G=$O(TCTX("commandBar",$G(KEY),"group",G)) Q:'G  D
 . S GC=GC+1,A=0
 . F  S A=$O(TCTX("commandBar",$G(KEY),"group",G,"action",A)) Q:'A  S AC=AC+1
 S TCTX("commandBar",$G(KEY),"groupCount")=GC
 S TCTX("commandBar",$G(KEY),"actionCount")=AC
 Q
 ;
FDINIT(TCTX,KEY,TITLE,LEAD)
 K TCTX("filterDrawer",$G(KEY))
 S TCTX("filterDrawer",$G(KEY),"title")=$G(TITLE)
 S TCTX("filterDrawer",$G(KEY),"lead")=$G(LEAD)
 Q
 ;
FDSECTION(TCTX,KEY,SIDX,LABEL,LEAD)
 S TCTX("filterDrawer",$G(KEY),"section",+$G(SIDX),"label")=$G(LABEL)
 S TCTX("filterDrawer",$G(KEY),"section",+$G(SIDX),"lead")=$G(LEAD)
 Q
 ;
FDFIELD(TCTX,KEY,SIDX,FIDX,LABEL,VALUE,META)
 S TCTX("filterDrawer",$G(KEY),"section",+$G(SIDX),"field",+$G(FIDX),"label")=$G(LABEL)
 S TCTX("filterDrawer",$G(KEY),"section",+$G(SIDX),"field",+$G(FIDX),"value")=$G(VALUE)
 S TCTX("filterDrawer",$G(KEY),"section",+$G(SIDX),"field",+$G(FIDX),"meta")=$G(META)
 Q
 ;
FDFINAL(TCTX,KEY)
 N S,F,SC,FC
 S (S,F,SC,FC)=0
 F  S S=$O(TCTX("filterDrawer",$G(KEY),"section",S)) Q:'S  D
 . S SC=SC+1,F=0
 . F  S F=$O(TCTX("filterDrawer",$G(KEY),"section",S,"field",F)) Q:'F  S FC=FC+1
 S TCTX("filterDrawer",$G(KEY),"sectionCount")=SC
 S TCTX("filterDrawer",$G(KEY),"fieldCount")=FC
 Q
 ;
TOAST(TCTX,KEY,KIND,TITLE,BODY,DISMISS)
 K TCTX("toast",$G(KEY))
 S TCTX("toast",$G(KEY),"kind")=$G(KIND)
 S TCTX("toast",$G(KEY),"title")=$G(TITLE)
 S TCTX("toast",$G(KEY),"body")=$G(BODY)
 S TCTX("toast",$G(KEY),"dismissible")=+$G(DISMISS)
 S TCTX("toast",$G(KEY),"panelClass")=$$PANEL^MIOUITHEME($S($G(KIND)="success":"emerald",$G(KIND)="warning":"amber",$G(KIND)="error":"rose",1:"sky"))
 S TCTX("toast",$G(KEY),"badgeClass")=$$BADGE^MIOUITHEME($S($G(KIND)="success":"emerald",$G(KIND)="warning":"amber",$G(KIND)="error":"rose",1:"sky"))
 Q
 ;
DIFFINIT(TCTX,KEY,TITLE,LEAD)
 K TCTX("inlineDiff",$G(KEY))
 S TCTX("inlineDiff",$G(KEY),"title")=$G(TITLE)
 S TCTX("inlineDiff",$G(KEY),"lead")=$G(LEAD)
 Q
 ;
DIFFROW(TCTX,KEY,IDX,LABEL,BEFORE,AFTER,CHANGED)
 S TCTX("inlineDiff",$G(KEY),"row",+$G(IDX),"label")=$G(LABEL)
 S TCTX("inlineDiff",$G(KEY),"row",+$G(IDX),"before")=$G(BEFORE)
 S TCTX("inlineDiff",$G(KEY),"row",+$G(IDX),"after")=$G(AFTER)
 S TCTX("inlineDiff",$G(KEY),"row",+$G(IDX),"changed")=+$G(CHANGED)
 S TCTX("inlineDiff",$G(KEY),"row",+$G(IDX),"badgeClass")=$S(+$G(CHANGED):$$BADGE^MIOUITHEME("amber"),1:$$BADGE^MIOUITHEME("slate"))
 S TCTX("inlineDiff",$G(KEY),"row",+$G(IDX),"stateLabel")=$S(+$G(CHANGED):"Changed",1:"Same")
 Q
 ;
DIFFFINAL(TCTX,KEY)
 N I,RC,CC
 S (I,RC,CC)=0
 F  S I=$O(TCTX("inlineDiff",$G(KEY),"row",I)) Q:'I  D
 . S RC=RC+1
 . I +$G(TCTX("inlineDiff",$G(KEY),"row",I,"changed")) S CC=CC+1
 S TCTX("inlineDiff",$G(KEY),"rowCount")=RC
 S TCTX("inlineDiff",$G(KEY),"changedCount")=CC
 Q
 ;
