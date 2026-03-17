MIOUILGT ; large SSR table builders for very large data-intensive pages
 Q
 ;
INIT(TCTX,KEY,TITLE,LEAD,EMPTYTXT)
 K TCTX("large",$G(KEY))
 S TCTX("large",$G(KEY),"id")=$G(KEY)
 S TCTX("large",$G(KEY),"title")=$G(TITLE)
 S TCTX("large",$G(KEY),"lead")=$G(LEAD)
 S TCTX("large",$G(KEY),"emptyText")=$G(EMPTYTXT)
 Q
 ;
INSIGHT(TCTX,KEY,IDX,LABEL,VALUE,TONE)
 S TCTX("large",$G(KEY),"insight",+$G(IDX),"label")=$G(LABEL)
 S TCTX("large",$G(KEY),"insight",+$G(IDX),"value")=$G(VALUE)
 S TCTX("large",$G(KEY),"insight",+$G(IDX),"badgeClass")=$$BADGE^MIOUITHEME($S($G(TONE)'="":$G(TONE),1:"slate"))
 Q
 ;
PREF(TCTX,KEY,IDX,LABEL,VALUE)
 S TCTX("large",$G(KEY),"pref",+$G(IDX),"label")=$G(LABEL)
 S TCTX("large",$G(KEY),"pref",+$G(IDX),"value")=$G(VALUE)
 Q
 ;
SUMMARY(TCTX,KEY,COUNT,BODY)
 S TCTX("large",$G(KEY),"selection","count")=+$G(COUNT)
 S TCTX("large",$G(KEY),"selection","summary")=+$G(COUNT)_" selected across this page"
 S TCTX("large",$G(KEY),"selection","body")=$G(BODY)
 Q
 ;
SUMACT(TCTX,KEY,IDX,LABEL,HREF,CLASS)
 S TCTX("large",$G(KEY),"selection","action",+$G(IDX),"label")=$G(LABEL)
 S TCTX("large",$G(KEY),"selection","action",+$G(IDX),"href")=$G(HREF)
 S TCTX("large",$G(KEY),"selection","action",+$G(IDX),"class")=$S($G(CLASS)'="":$G(CLASS),1:"quick-button")
 S TCTX("large",$G(KEY),"selection","action",+$G(IDX),"isLink")=1
 Q
 ;
STATE(TCTX,KEY,QUERY,PAGE,PER,TOTAL,SORTFIELD,SORTDIR)
 N LAST,START,STOP
 S PAGE=+$G(PAGE) I PAGE<1 S PAGE=1
 S PER=+$G(PER) I PER<1 S PER=100
 S TOTAL=+$G(TOTAL) I TOTAL<0 S TOTAL=0
 S LAST=$S(TOTAL>0:((TOTAL-1)\PER)+1,1:1)
 I PAGE>LAST S PAGE=LAST
 S START=$S(TOTAL>0:((PAGE-1)*PER)+1,1:0)
 S STOP=PAGE*PER I STOP>TOTAL S STOP=TOTAL
 S TCTX("large",$G(KEY),"query")=$G(QUERY)
 S TCTX("large",$G(KEY),"page")=PAGE
 S TCTX("large",$G(KEY),"per")=PER
 S TCTX("large",$G(KEY),"total")=TOTAL
 S TCTX("large",$G(KEY),"lastPage")=LAST
 S TCTX("large",$G(KEY),"start")=START
 S TCTX("large",$G(KEY),"stop")=STOP
 S TCTX("large",$G(KEY),"sortField")=$G(SORTFIELD)
 S TCTX("large",$G(KEY),"sortDir")=$G(SORTDIR)
 S TCTX("large",$G(KEY),"resultLabel")=TOTAL_" results"
 S TCTX("large",$G(KEY),"windowLabel")="Rows "_START_"-"_STOP_" of "_TOTAL
 S TCTX("large",$G(KEY),"sortSummary")="Sort by "_$G(SORTFIELD)_" "_$G(SORTDIR)
 Q
 ;
NAV(TCTX,KEY,PREVHREF,NEXTHREF)
 S TCTX("large",$G(KEY),"prevHref")=$G(PREVHREF)
 S TCTX("large",$G(KEY),"nextHref")=$G(NEXTHREF)
 S TCTX("large",$G(KEY),"hasPrev")=$S($G(PREVHREF)'="":1,1:0)
 S TCTX("large",$G(KEY),"hasNext")=$S($G(NEXTHREF)'="":1,1:0)
 Q
 ;
PEROPT(TCTX,KEY,IDX,LABEL,ACTIVE,HREF)
 S TCTX("large",$G(KEY),"perOption",+$G(IDX),"label")=$G(LABEL)
 S TCTX("large",$G(KEY),"perOption",+$G(IDX),"href")=$G(HREF)
 S TCTX("large",$G(KEY),"perOption",+$G(IDX),"isActive")=+$G(ACTIVE)
 S TCTX("large",$G(KEY),"perOption",+$G(IDX),"class")=$S(+$G(ACTIVE):"primary-button",1:"quick-button")
 Q
 ;
DENSITY(TCTX,KEY,IDX,LABEL,ACTIVE,HREF)
 S TCTX("large",$G(KEY),"density",+$G(IDX),"label")=$G(LABEL)
 S TCTX("large",$G(KEY),"density",+$G(IDX),"href")=$G(HREF)
 S TCTX("large",$G(KEY),"density",+$G(IDX),"isActive")=+$G(ACTIVE)
 S TCTX("large",$G(KEY),"density",+$G(IDX),"class")=$S(+$G(ACTIVE):"primary-button",1:"ghost-button")
 Q
 ;
FILTERGROUP(TCTX,KEY,GIDX,LABEL)
 S TCTX("large",$G(KEY),"filterGroup",+$G(GIDX),"label")=$G(LABEL)
 Q
 ;
FILTEROPT(TCTX,KEY,GIDX,IDX,LABEL,COUNT,ACTIVE,HREF)
 S TCTX("large",$G(KEY),"filterGroup",+$G(GIDX),"item",+$G(IDX),"label")=$G(LABEL)
 S TCTX("large",$G(KEY),"filterGroup",+$G(GIDX),"item",+$G(IDX),"count")=+$G(COUNT)
 S TCTX("large",$G(KEY),"filterGroup",+$G(GIDX),"item",+$G(IDX),"href")=$G(HREF)
 S TCTX("large",$G(KEY),"filterGroup",+$G(GIDX),"item",+$G(IDX),"isActive")=+$G(ACTIVE)
 S TCTX("large",$G(KEY),"filterGroup",+$G(GIDX),"item",+$G(IDX),"class")=$S(+$G(ACTIVE):"primary-button",1:"quick-button")
 Q
 ;
ACTIVEFILTER(TCTX,KEY,IDX,LABEL,HREF)
 S TCTX("large",$G(KEY),"activeFilter",+$G(IDX),"label")=$G(LABEL)
 S TCTX("large",$G(KEY),"activeFilter",+$G(IDX),"href")=$G(HREF)
 S TCTX("large",$G(KEY),"activeFilter",+$G(IDX),"class")="ghost-button"
 Q
 ;
COL(TCTX,KEY,IDX,ID,LABEL,ALIGN,WIDTH,ISSORTED,SORTDIR,SORTHREF,ISPINNED)
 N A,STICK
 S A=$S($G(ALIGN)="right":"text-right",1:"text-left")
 S STICK=$S(+$G(ISPINNED):"sticky left-0 z-10 bg-slate-950/95",1:"")
 S TCTX("large",$G(KEY),"col",+$G(IDX),"id")=$G(ID)
 S TCTX("large",$G(KEY),"col",+$G(IDX),"label")=$G(LABEL)
 S TCTX("large",$G(KEY),"col",+$G(IDX),"alignClass")=A
 S TCTX("large",$G(KEY),"col",+$G(IDX),"width")=$S($G(WIDTH)'="":$G(WIDTH),1:"10rem")
 S TCTX("large",$G(KEY),"col",+$G(IDX),"isSorted")=+$G(ISSORTED)
 S TCTX("large",$G(KEY),"col",+$G(IDX),"sortDir")=$G(SORTDIR)
 S TCTX("large",$G(KEY),"col",+$G(IDX),"sortHref")=$G(SORTHREF)
 S TCTX("large",$G(KEY),"col",+$G(IDX),"isPinned")=+$G(ISPINNED)
 S TCTX("large",$G(KEY),"col",+$G(IDX),"stickyClass")=STICK
 Q
 ;
ORDER(TCTX,KEY,IDX,LABEL,ACTIVE,UPHREF,DOWNHREF)
 S TCTX("large",$G(KEY),"order",+$G(IDX),"position")=+$G(IDX)
 S TCTX("large",$G(KEY),"order",+$G(IDX),"label")=$G(LABEL)
 S TCTX("large",$G(KEY),"order",+$G(IDX),"isActive")=+$G(ACTIVE)
 S TCTX("large",$G(KEY),"order",+$G(IDX),"upHref")=$G(UPHREF)
 S TCTX("large",$G(KEY),"order",+$G(IDX),"downHref")=$G(DOWNHREF)
 Q
 ;
ROW(TCTX,KEY,IDX,PRIMARY,SECONDARY,META,SELECTED,EXPANDED,HREF)
 S TCTX("large",$G(KEY),"row",+$G(IDX),"primary")=$G(PRIMARY)
 S TCTX("large",$G(KEY),"row",+$G(IDX),"secondary")=$G(SECONDARY)
 S TCTX("large",$G(KEY),"row",+$G(IDX),"meta")=$G(META)
 S TCTX("large",$G(KEY),"row",+$G(IDX),"isSelected")=+$G(SELECTED)
 S TCTX("large",$G(KEY),"row",+$G(IDX),"isExpanded")=+$G(EXPANDED)
 S TCTX("large",$G(KEY),"row",+$G(IDX),"href")=$G(HREF)
 S TCTX("large",$G(KEY),"row",+$G(IDX),"rowClass")=$S(+$G(SELECTED):"bg-sky-500/10",1:"")
 Q
 ;
IDCELL(TCTX,KEY,ROW,IDX,ISPINNED)
 S TCTX("large",$G(KEY),"row",+$G(ROW),"cell",+$G(IDX),"isIdentity")=1
 S TCTX("large",$G(KEY),"row",+$G(ROW),"cell",+$G(IDX),"alignClass")="text-left"
 S TCTX("large",$G(KEY),"row",+$G(ROW),"cell",+$G(IDX),"textClass")=""
 S TCTX("large",$G(KEY),"row",+$G(ROW),"cell",+$G(IDX),"isPinned")=+$G(ISPINNED)
 Q
 ;
CELL(TCTX,KEY,ROW,IDX,VAL,ALIGN,STYLE,ISPINNED)
 N A,C
 S A=$S($G(ALIGN)="right":"text-right",1:"text-left")
 S C=$S($G(STYLE)="strong":"font-semibold",$G(STYLE)="muted":"muted",1:"")
 S TCTX("large",$G(KEY),"row",+$G(ROW),"cell",+$G(IDX),"value")=$G(VAL)
 S TCTX("large",$G(KEY),"row",+$G(ROW),"cell",+$G(IDX),"alignClass")=A
 S TCTX("large",$G(KEY),"row",+$G(ROW),"cell",+$G(IDX),"textClass")=C
 S TCTX("large",$G(KEY),"row",+$G(ROW),"cell",+$G(IDX),"isPinned")=+$G(ISPINNED)
 Q
 ;
ROWBADGE(TCTX,KEY,ROW,LABEL,TONE)
 S TCTX("large",$G(KEY),"row",+$G(ROW),"badgeLabel")=$G(LABEL)
 S TCTX("large",$G(KEY),"row",+$G(ROW),"badgeClass")=$$BADGE^MIOUITHEME($S($G(TONE)'="":$G(TONE),1:"slate"))
 S TCTX("large",$G(KEY),"row",+$G(ROW),"hasBadge")=$S($G(LABEL)'="":1,1:0)
 Q
 ;
ROWACT(TCTX,KEY,ROW,IDX,LABEL,HREF,CLASS)
 S TCTX("large",$G(KEY),"row",+$G(ROW),"action",+$G(IDX),"label")=$G(LABEL)
 S TCTX("large",$G(KEY),"row",+$G(ROW),"action",+$G(IDX),"href")=$G(HREF)
 S TCTX("large",$G(KEY),"row",+$G(ROW),"action",+$G(IDX),"class")=$S($G(CLASS)'="":$G(CLASS),1:"quick-button")
 S TCTX("large",$G(KEY),"row",+$G(ROW),"action",+$G(IDX),"isLink")=1
 Q
 ;
DETAIL(TCTX,KEY,ROW,TITLE,BODY)
 S TCTX("large",$G(KEY),"row",+$G(ROW),"detailTitle")=$G(TITLE)
 S TCTX("large",$G(KEY),"row",+$G(ROW),"detailBody")=$G(BODY)
 Q
 ;
TOTAL(TCTX,KEY,IDX,VALUE,ALIGN,STRONG)
 N A
 S A=$S($G(ALIGN)="right":"text-right",1:"text-left")
 S TCTX("large",$G(KEY),"totalCell",+$G(IDX),"value")=$G(VALUE)
 S TCTX("large",$G(KEY),"totalCell",+$G(IDX),"alignClass")=A
 S TCTX("large",$G(KEY),"totalCell",+$G(IDX),"isStrong")=+$G(STRONG)
 S TCTX("large",$G(KEY),"hasTotals")=1
 Q
 ;
FINAL(TCTX,KEY)
 N I,R,C,SEL,CCOUNT
 S (I,R,C,SEL,CCOUNT)=0
 F  S I=$O(TCTX("large",$G(KEY),"col",I)) Q:'I  S CCOUNT=CCOUNT+1
 F  S R=$O(TCTX("large",$G(KEY),"row",R)) Q:'R  D
 . S C=C+1
 . I +$G(TCTX("large",$G(KEY),"row",R,"isSelected")) S SEL=SEL+1
 . S TCTX("large",$G(KEY),"row",R,"detailColspan")=CCOUNT+1
 S TCTX("large",$G(KEY),"columnCount")=CCOUNT
 S TCTX("large",$G(KEY),"rowCount")=C
 S TCTX("large",$G(KEY),"selectedCount")=SEL
 S TCTX("large",$G(KEY),"hasRows")=$S(C>0:1,1:0)
 Q
 ;
