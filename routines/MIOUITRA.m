MIOUITRA ; MIOUI trace and audit builders
 Q
 ;
SUMINIT(TCTX,KEY,TITLE,LEAD)
 K TCTX("traceSummary",$G(KEY))
 S TCTX("traceSummary",$G(KEY),"title")=$G(TITLE)
 S TCTX("traceSummary",$G(KEY),"lead")=$G(LEAD)
 Q
 ;
SUMSTAT(TCTX,KEY,IDX,LABEL,VALUE,TONE)
 S TCTX("traceSummary",$G(KEY),"stat",+$G(IDX),"label")=$G(LABEL)
 S TCTX("traceSummary",$G(KEY),"stat",+$G(IDX),"value")=$G(VALUE)
 S TCTX("traceSummary",$G(KEY),"stat",+$G(IDX),"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 S TCTX("traceSummary",$G(KEY),"stat",+$G(IDX),"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 Q
 ;
SUMFINAL(TCTX,KEY)
 N I,C
 S (I,C)=0
 F  S I=$O(TCTX("traceSummary",$G(KEY),"stat",I)) Q:'I  S C=C+1
 S TCTX("traceSummary",$G(KEY),"count")=C
 Q
 ;
CARDINIT(TCTX,KEY,TITLE,LEAD,TONE)
 K TCTX("detailCard",$G(KEY))
 S TCTX("detailCard",$G(KEY),"title")=$G(TITLE)
 S TCTX("detailCard",$G(KEY),"lead")=$G(LEAD)
 S TCTX("detailCard",$G(KEY),"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
CARDFIELD(TCTX,KEY,IDX,LABEL,VALUE)
 S TCTX("detailCard",$G(KEY),"field",+$G(IDX),"label")=$G(LABEL)
 S TCTX("detailCard",$G(KEY),"field",+$G(IDX),"value")=$G(VALUE)
 Q
 ;
CARDACT(TCTX,KEY,IDX,LABEL,HREF,CLASS)
 S TCTX("detailCard",$G(KEY),"action",+$G(IDX),"label")=$G(LABEL)
 S TCTX("detailCard",$G(KEY),"action",+$G(IDX),"href")=$G(HREF)
 S TCTX("detailCard",$G(KEY),"action",+$G(IDX),"class")=$G(CLASS)
 Q
 ;
CARDFINAL(TCTX,KEY)
 N I,C
 S (I,C)=0
 F  S I=$O(TCTX("detailCard",$G(KEY),"field",I)) Q:'I  S C=C+1
 S TCTX("detailCard",$G(KEY),"fieldCount")=C
 S (I,C)=0
 F  S I=$O(TCTX("detailCard",$G(KEY),"action",I)) Q:'I  S C=C+1
 S TCTX("detailCard",$G(KEY),"actionCount")=C
 Q
 ;
LGINIT(TCTX,KEY,TITLE,LEAD)
 K TCTX("listGroup",$G(KEY))
 S TCTX("listGroup",$G(KEY),"title")=$G(TITLE)
 S TCTX("listGroup",$G(KEY),"lead")=$G(LEAD)
 Q
 ;
LGROUP(TCTX,KEY,GIDX,LABEL,LEAD,TONE)
 S TCTX("listGroup",$G(KEY),"group",+$G(GIDX),"label")=$G(LABEL)
 S TCTX("listGroup",$G(KEY),"group",+$G(GIDX),"lead")=$G(LEAD)
 S TCTX("listGroup",$G(KEY),"group",+$G(GIDX),"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 Q
 ;
LGROW(TCTX,KEY,GIDX,RIDX,TITLE,META,TONE)
 S TCTX("listGroup",$G(KEY),"group",+$G(GIDX),"row",+$G(RIDX),"title")=$G(TITLE)
 S TCTX("listGroup",$G(KEY),"group",+$G(GIDX),"row",+$G(RIDX),"meta")=$G(META)
 S TCTX("listGroup",$G(KEY),"group",+$G(GIDX),"row",+$G(RIDX),"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 Q
 ;
LGFINAL(TCTX,KEY)
 N G,R,GC,RC
 S (G,R,GC,RC)=0
 F  S G=$O(TCTX("listGroup",$G(KEY),"group",G)) Q:'G  D
 . S GC=GC+1,R=0
 . F  S R=$O(TCTX("listGroup",$G(KEY),"group",G,"row",R)) Q:'R  S RC=RC+1
 S TCTX("listGroup",$G(KEY),"groupCount")=GC
 S TCTX("listGroup",$G(KEY),"rowCount")=RC
 Q
 ;
TLINIT(TCTX,KEY,TITLE,LEAD)
 K TCTX("timeline",$G(KEY))
 S TCTX("timeline",$G(KEY),"title")=$G(TITLE)
 S TCTX("timeline",$G(KEY),"lead")=$G(LEAD)
 Q
 ;
TLITEM(TCTX,KEY,IDX,STAMP,TITLE,BODY,TONE)
 S TCTX("timeline",$G(KEY),"item",+$G(IDX),"stamp")=$G(STAMP)
 S TCTX("timeline",$G(KEY),"item",+$G(IDX),"title")=$G(TITLE)
 S TCTX("timeline",$G(KEY),"item",+$G(IDX),"body")=$G(BODY)
 S TCTX("timeline",$G(KEY),"item",+$G(IDX),"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 Q
 ;
TLFINAL(TCTX,KEY)
 N I,C
 S (I,C)=0
 F  S I=$O(TCTX("timeline",$G(KEY),"item",I)) Q:'I  S C=C+1
 S TCTX("timeline",$G(KEY),"count")=C
 Q
 ;
TBINIT(TCTX,KEY,TITLE,LEAD,EMPTY)
 K TCTX("traceTable",$G(KEY))
 S TCTX("traceTable",$G(KEY),"title")=$G(TITLE)
 S TCTX("traceTable",$G(KEY),"lead")=$G(LEAD)
 S TCTX("traceTable",$G(KEY),"emptyText")=$G(EMPTY)
 Q
 ;
TBCOL(TCTX,KEY,IDX,LABEL,ALIGN)
 S TCTX("traceTable",$G(KEY),"col",+$G(IDX),"label")=$G(LABEL)
 S TCTX("traceTable",$G(KEY),"col",+$G(IDX),"align")=$S($G(ALIGN)="right":"text-right",1:"text-left")
 Q
 ;
TBCELL(TCTX,KEY,RIDX,CIDX,VALUE)
 S TCTX("traceTable",$G(KEY),"row",+$G(RIDX),"cell",+$G(CIDX),"value")=$G(VALUE)
 Q
 ;
TBFINAL(TCTX,KEY)
 N R,C,RC,CC
 S (R,C,RC,CC)=0
 F  S C=$O(TCTX("traceTable",$G(KEY),"col",C)) Q:'C  S CC=CC+1
 F  S R=$O(TCTX("traceTable",$G(KEY),"row",R)) Q:'R  S RC=RC+1
 S TCTX("traceTable",$G(KEY),"colCount")=CC
 S TCTX("traceTable",$G(KEY),"rowCount")=RC
 S TCTX("traceTable",$G(KEY),"hasRows")=$S(RC>0:1,1:0)
 Q
 ;
