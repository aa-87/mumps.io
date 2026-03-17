MIOUITBL ; MIOUI dense table builders
 Q
 ;
INIT(TCTX,KEY,TITLE,EMPTYTXT)
 K TCTX("table",$G(KEY))
 S TCTX("table",$G(KEY),"id")=$G(KEY)
 S TCTX("table",$G(KEY),"title")=$G(TITLE)
 S TCTX("table",$G(KEY),"emptyText")=$G(EMPTYTXT)
 Q
 ;
COL(TCTX,KEY,IDX,LABEL,ALIGN)
 S TCTX("table",$G(KEY),"col",IDX,"label")=$G(LABEL)
 S TCTX("table",$G(KEY),"col",IDX,"align")=$S($G(ALIGN)'="":ALIGN,1:"left")
 Q
 ;
CELL(TCTX,KEY,ROW,COL,VAL)
 S TCTX("table",$G(KEY),"row",ROW,"cell",COL,"value")=$G(VAL)
 Q
 ;
ROWHREF(TCTX,KEY,ROW,HREF)
 S TCTX("table",$G(KEY),"row",ROW,"href")=$G(HREF)
 S TCTX("table",$G(KEY),"row",ROW,"hasHref")=$S($G(HREF)'="":1,1:0)
 Q
 ;
ROWBADGE(TCTX,KEY,ROW,LABEL,TONE)
 S TCTX("table",$G(KEY),"row",ROW,"badgeLabel")=$G(LABEL)
 S TCTX("table",$G(KEY),"row",ROW,"badgeClass")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("table",$G(KEY),"row",ROW,"hasBadge")=$S($G(LABEL)'="":1,1:0)
 Q
 ;
FILTER(TCTX,KEY,IDX,LABEL,VALUE,ACTIVE)
 S TCTX("table",$G(KEY),"filter",IDX,"label")=$G(LABEL)
 S TCTX("table",$G(KEY),"filter",IDX,"value")=$G(VALUE)
 S TCTX("table",$G(KEY),"filter",IDX,"isActive")=+$G(ACTIVE)
 S TCTX("table",$G(KEY),"hasFilters")=1
 Q
 ;
FILTERMETA(TCTX,KEY,TITLE,LEAD)
 S TCTX("table",$G(KEY),"filters","title")=$G(TITLE)
 S TCTX("table",$G(KEY),"filters","lead")=$G(LEAD)
 S TCTX("table",$G(KEY),"hasFilterPanel")=1
 Q
 ;
TOOLBAR(TCTX,KEY,KICKER,SUMMARY,SEARCH,PLACEHOLDER)
 S TCTX("table",$G(KEY),"toolbar","kicker")=$G(KICKER)
 S TCTX("table",$G(KEY),"toolbar","summary")=$G(SUMMARY)
 S TCTX("table",$G(KEY),"toolbar","search")=$G(SEARCH)
 S TCTX("table",$G(KEY),"toolbar","placeholder")=$G(PLACEHOLDER)
 S TCTX("table",$G(KEY),"hasToolbar")=1
 Q
 ;
TOOLACT(TCTX,KEY,IDX,LABEL,HREF,CLASS)
 S TCTX("table",$G(KEY),"toolbar","action",IDX,"label")=$G(LABEL)
 S TCTX("table",$G(KEY),"toolbar","action",IDX,"href")=$G(HREF)
 S TCTX("table",$G(KEY),"toolbar","action",IDX,"class")=$S($G(CLASS)'="":CLASS,1:"quick-button")
 S TCTX("table",$G(KEY),"toolbar","action",IDX,"isLink")=1
 S TCTX("table",$G(KEY),"hasToolbar")=1
 Q
 ;
BULK(TCTX,KEY,LABEL,COUNT)
 S TCTX("table",$G(KEY),"bulk","label")=$G(LABEL)
 S TCTX("table",$G(KEY),"bulk","count")=+$G(COUNT)
 S TCTX("table",$G(KEY),"hasBulk")=1
 Q
 ;
BULKACT(TCTX,KEY,IDX,LABEL,HREF,CLASS)
 S TCTX("table",$G(KEY),"bulk","action",IDX,"label")=$G(LABEL)
 S TCTX("table",$G(KEY),"bulk","action",IDX,"href")=$G(HREF)
 S TCTX("table",$G(KEY),"bulk","action",IDX,"class")=$S($G(CLASS)'="":CLASS,1:"quick-button")
 S TCTX("table",$G(KEY),"bulk","action",IDX,"isLink")=1
 S TCTX("table",$G(KEY),"hasBulk")=1
 Q
 ;
PAGER(TCTX,KEY,PAGE,PER,TOTAL,PREVHREF,NEXTHREF)
 N LAST,START,STOP
 S PAGE=+$G(PAGE) I PAGE<1 S PAGE=1
 S PER=+$G(PER) I PER<1 S PER=25
 S TOTAL=+$G(TOTAL) I TOTAL<0 S TOTAL=0
 S LAST=$S(TOTAL>0:((TOTAL-1)\PER)+1,1:1)
 S START=$S(TOTAL>0:((PAGE-1)*PER)+1,1:0)
 S STOP=PAGE*PER I STOP>TOTAL S STOP=TOTAL
 S TCTX("table",$G(KEY),"pager","page")=PAGE
 S TCTX("table",$G(KEY),"pager","per")=PER
 S TCTX("table",$G(KEY),"pager","total")=TOTAL
 S TCTX("table",$G(KEY),"pager","lastPage")=LAST
 S TCTX("table",$G(KEY),"pager","start")=START
 S TCTX("table",$G(KEY),"pager","stop")=STOP
 S TCTX("table",$G(KEY),"pager","prevHref")=$G(PREVHREF)
 S TCTX("table",$G(KEY),"pager","nextHref")=$G(NEXTHREF)
 S TCTX("table",$G(KEY),"pager","hasPrev")=$S(PAGE>1:1,1:0)
 S TCTX("table",$G(KEY),"pager","hasNext")=$S(PAGE<LAST:1,1:0)
 S TCTX("table",$G(KEY),"hasPager")=1
 Q
 ;
FINAL(TCTX,KEY)
 N C,R
 S C=0,R=0
 F  S R=$O(TCTX("table",$G(KEY),"row",R)) Q:'R  S C=C+1
 S TCTX("table",$G(KEY),"rowCount")=C
 S TCTX("table",$G(KEY),"hasRows")=$S(C>0:1,1:0)
 Q
 ;
