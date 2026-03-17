MIOUIMLT ; million-row SSR table builders for extreme data-intensive pages
 Q
 ;
INIT(TCTX,KEY,TITLE,LEAD,EMPTYTXT)
 K TCTX("mega",$G(KEY))
 S TCTX("mega",$G(KEY),"id")=$G(KEY)
 S TCTX("mega",$G(KEY),"title")=$G(TITLE)
 S TCTX("mega",$G(KEY),"lead")=$G(LEAD)
 S TCTX("mega",$G(KEY),"emptyText")=$G(EMPTYTXT)
 Q
 ;
CONFIG(TCTX,KEY,COMPID,TOTALROWS,TOTALCOLS,PER,PAGE,QUERY,SORTFIELD,SORTDIR)
 N LAST
 S TCTX("mega",$G(KEY),"componentId")=$G(COMPID)
 S TCTX("mega",$G(KEY),"totalRows")=+$G(TOTALROWS)
 S TCTX("mega",$G(KEY),"totalRowsLabel")=$$COMMA(+$G(TOTALROWS))_" rows"
 S TCTX("mega",$G(KEY),"totalColumns")=+$G(TOTALCOLS)
 S TCTX("mega",$G(KEY),"totalColumnsLabel")=+$G(TOTALCOLS)_" columns"
 S TCTX("mega",$G(KEY),"per")=+$G(PER)
 S TCTX("mega",$G(KEY),"page")=+$G(PAGE)
 S TCTX("mega",$G(KEY),"query")=$G(QUERY)
 S TCTX("mega",$G(KEY),"sortField")=$G(SORTFIELD)
 S TCTX("mega",$G(KEY),"sortDir")=$G(SORTDIR)
 S LAST=$S(+$G(PER)>0:((+$G(TOTALROWS)-1)\+$G(PER))+1,1:1)
 S TCTX("mega",$G(KEY),"lastPage")=LAST
 S TCTX("mega",$G(KEY),"pageLabel")="Page "_+$G(PAGE)_" of "_LAST
 S TCTX("mega",$G(KEY),"sortSummary")="Sort by "_$G(SORTFIELD)_" "_$G(SORTDIR)
 Q
 ;
FEATURE(TCTX,KEY,IDX,LABEL,VALUE,TONE)
 S TCTX("mega",$G(KEY),"insight",+$G(IDX),"label")=$G(LABEL)
 S TCTX("mega",$G(KEY),"insight",+$G(IDX),"value")=$G(VALUE)
 S TCTX("mega",$G(KEY),"insight",+$G(IDX),"badgeClass")=$$BADGE^MIOUITHEME($S($G(TONE)'="":$G(TONE),1:"slate"))
 Q
 ;
SEARCH(TCTX,KEY,QUERY,PLACEHOLDER,CLEARHREF)
 S TCTX("mega",$G(KEY),"search","query")=$G(QUERY)
 S TCTX("mega",$G(KEY),"search","placeholder")=$G(PLACEHOLDER)
 S TCTX("mega",$G(KEY),"search","clearHref")=$G(CLEARHREF)
 Q
 ;
WINDOW(TCTX,KEY,PAGE,PER,TOTALROWS)
 N START,STOP,LAST
 S PAGE=+$G(PAGE) I PAGE<1 S PAGE=1
 S PER=+$G(PER) I PER<1 S PER=100
 S TOTALROWS=+$G(TOTALROWS) I TOTALROWS<0 S TOTALROWS=0
 S LAST=$S(TOTALROWS>0:((TOTALROWS-1)\PER)+1,1:1)
 I PAGE>LAST S PAGE=LAST
 S START=$S(TOTALROWS>0:((PAGE-1)*PER)+1,1:0)
 S STOP=PAGE*PER I STOP>TOTALROWS S STOP=TOTALROWS
 S TCTX("mega",$G(KEY),"page")=PAGE
 S TCTX("mega",$G(KEY),"per")=PER
 S TCTX("mega",$G(KEY),"lastPage")=LAST
 S TCTX("mega",$G(KEY),"start")=START
 S TCTX("mega",$G(KEY),"stop")=STOP
 S TCTX("mega",$G(KEY),"windowLabel")="Rows "_START_"-"_STOP_" of "_TOTALROWS
 S TCTX("mega",$G(KEY),"pageLabel")="Page "_PAGE_" of "_LAST
 Q
 ;
NAV(TCTX,KEY,PREVHREF,NEXTHREF)
 S TCTX("mega",$G(KEY),"prevHref")=$G(PREVHREF)
 S TCTX("mega",$G(KEY),"nextHref")=$G(NEXTHREF)
 S TCTX("mega",$G(KEY),"hasPrev")=$S($G(PREVHREF)'="":1,1:0)
 S TCTX("mega",$G(KEY),"hasNext")=$S($G(NEXTHREF)'="":1,1:0)
 Q
 ;
PEROPT(TCTX,KEY,IDX,LABEL,ACTIVE,HREF)
 S TCTX("mega",$G(KEY),"perOption",+$G(IDX),"label")=$G(LABEL)
 S TCTX("mega",$G(KEY),"perOption",+$G(IDX),"href")=$G(HREF)
 S TCTX("mega",$G(KEY),"perOption",+$G(IDX),"isActive")=+$G(ACTIVE)
 S TCTX("mega",$G(KEY),"perOption",+$G(IDX),"class")=$S(+$G(ACTIVE):"primary-button",1:"quick-button")
 Q
 ;
SORTSTACK(TCTX,KEY,IDX,LABEL,DIR,PRIORITY,HREF)
 S TCTX("mega",$G(KEY),"sortStack",+$G(IDX),"label")=$G(LABEL)
 S TCTX("mega",$G(KEY),"sortStack",+$G(IDX),"dir")=$G(DIR)
 S TCTX("mega",$G(KEY),"sortStack",+$G(IDX),"priority")=+$G(PRIORITY)
 S TCTX("mega",$G(KEY),"sortStack",+$G(IDX),"href")=$G(HREF)
 Q
 ;
FILTERGROUP(TCTX,KEY,GIDX,LABEL)
 S TCTX("mega",$G(KEY),"filterGroup",+$G(GIDX),"label")=$G(LABEL)
 Q
 ;
FILTEROPT(TCTX,KEY,GIDX,IDX,LABEL,COUNT,ACTIVE,HREF)
 S TCTX("mega",$G(KEY),"filterGroup",+$G(GIDX),"item",+$G(IDX),"label")=$G(LABEL)
 S TCTX("mega",$G(KEY),"filterGroup",+$G(GIDX),"item",+$G(IDX),"count")=+$G(COUNT)
 S TCTX("mega",$G(KEY),"filterGroup",+$G(GIDX),"item",+$G(IDX),"href")=$G(HREF)
 S TCTX("mega",$G(KEY),"filterGroup",+$G(GIDX),"item",+$G(IDX),"isActive")=+$G(ACTIVE)
 S TCTX("mega",$G(KEY),"filterGroup",+$G(GIDX),"item",+$G(IDX),"class")=$S(+$G(ACTIVE):"primary-button",1:"quick-button")
 Q
 ;
ACTIVEFILTER(TCTX,KEY,IDX,LABEL,HREF)
 S TCTX("mega",$G(KEY),"activeFilter",+$G(IDX),"label")=$G(LABEL)
 S TCTX("mega",$G(KEY),"activeFilter",+$G(IDX),"href")=$G(HREF)
 S TCTX("mega",$G(KEY),"activeFilter",+$G(IDX),"class")="ghost-button"
 Q
 ;
CALLBACK(TCTX,KEY,IDX,LABEL,CALLBACK,HREF,CLASS)
 S TCTX("mega",$G(KEY),"callback",+$G(IDX),"label")=$G(LABEL)
 S TCTX("mega",$G(KEY),"callback",+$G(IDX),"callback")=$G(CALLBACK)
 S TCTX("mega",$G(KEY),"callback",+$G(IDX),"href")=$G(HREF)
 S TCTX("mega",$G(KEY),"callback",+$G(IDX),"class")=$S($G(CLASS)'="":$G(CLASS),1:"quick-button")
 S TCTX("mega",$G(KEY),"callback",+$G(IDX),"isLink")=1
 Q
 ;
SELCOL(TCTX,KEY,IDX,LABEL,STATE,ACTIVE,UPHREF,DOWNHREF)
 S TCTX("mega",$G(KEY),"selectedColumn",+$G(IDX),"position")=+$G(IDX)
 S TCTX("mega",$G(KEY),"selectedColumn",+$G(IDX),"label")=$G(LABEL)
 S TCTX("mega",$G(KEY),"selectedColumn",+$G(IDX),"state")=$G(STATE)
 S TCTX("mega",$G(KEY),"selectedColumn",+$G(IDX),"isActive")=+$G(ACTIVE)
 S TCTX("mega",$G(KEY),"selectedColumn",+$G(IDX),"upHref")=$G(UPHREF)
 S TCTX("mega",$G(KEY),"selectedColumn",+$G(IDX),"downHref")=$G(DOWNHREF)
 S TCTX("mega",$G(KEY),"selectedColumn",+$G(IDX),"badgeClass")=$S(+$G(ACTIVE):"badge-sky",1:"badge-slate")
 Q
 ;
COL(TCTX,KEY,IDX,ID,LABEL,ALIGN,WIDTH,ISSORTED,SORTDIR,SORTHREF,ISVISIBLE,ISPINNED)
 N A,STICK
 S A=$S($G(ALIGN)="right":"text-right",1:"text-left")
 S STICK=$S(+$G(ISPINNED):"sticky left-0 z-10 bg-slate-950/95",1:"")
 S TCTX("mega",$G(KEY),"col",+$G(IDX),"id")=$G(ID)
 S TCTX("mega",$G(KEY),"col",+$G(IDX),"label")=$G(LABEL)
 S TCTX("mega",$G(KEY),"col",+$G(IDX),"alignClass")=A
 S TCTX("mega",$G(KEY),"col",+$G(IDX),"width")=$S($G(WIDTH)'="":$G(WIDTH),1:"10rem")
 S TCTX("mega",$G(KEY),"col",+$G(IDX),"isSorted")=+$G(ISSORTED)
 S TCTX("mega",$G(KEY),"col",+$G(IDX),"sortDir")=$G(SORTDIR)
 S TCTX("mega",$G(KEY),"col",+$G(IDX),"sortHref")=$G(SORTHREF)
 S TCTX("mega",$G(KEY),"col",+$G(IDX),"isVisible")=+$G(ISVISIBLE)
 S TCTX("mega",$G(KEY),"col",+$G(IDX),"isPinned")=+$G(ISPINNED)
 S TCTX("mega",$G(KEY),"col",+$G(IDX),"stickyClass")=STICK
 Q
 ;
MROW(TCTX,KEY,IDX,PRIMARY,SECONDARY,META,SELECTED,EXPANDED,HREF)
 S TCTX("mega",$G(KEY),"row",+$G(IDX),"primary")=$G(PRIMARY)
 S TCTX("mega",$G(KEY),"row",+$G(IDX),"secondary")=$G(SECONDARY)
 S TCTX("mega",$G(KEY),"row",+$G(IDX),"meta")=$G(META)
 S TCTX("mega",$G(KEY),"row",+$G(IDX),"isSelected")=+$G(SELECTED)
 S TCTX("mega",$G(KEY),"row",+$G(IDX),"isExpanded")=+$G(EXPANDED)
 S TCTX("mega",$G(KEY),"row",+$G(IDX),"href")=$G(HREF)
 S TCTX("mega",$G(KEY),"row",+$G(IDX),"rowClass")=$S(+$G(SELECTED):"bg-sky-500/10",1:"")
 Q
 ;
MCELL(TCTX,KEY,ROW,IDX,VAL,ALIGN,STYLE,ISPINNED)
 N A,C
 S A=$S($G(ALIGN)="right":"text-right",1:"text-left")
 S C=$S($G(STYLE)="strong":"font-semibold",$G(STYLE)="muted":"muted",1:"")
 S TCTX("mega",$G(KEY),"row",+$G(ROW),"cell",+$G(IDX),"value")=$G(VAL)
 S TCTX("mega",$G(KEY),"row",+$G(ROW),"cell",+$G(IDX),"alignClass")=A
 S TCTX("mega",$G(KEY),"row",+$G(ROW),"cell",+$G(IDX),"textClass")=C
 S TCTX("mega",$G(KEY),"row",+$G(ROW),"cell",+$G(IDX),"isPinned")=+$G(ISPINNED)
 S TCTX("mega",$G(KEY),"row",+$G(ROW),"cell",+$G(IDX),"isIdentity")=$S(+$G(IDX)=1:1,1:0)
 Q
 ;
MROWBADGE(TCTX,KEY,ROW,LABEL,TONE)
 S TCTX("mega",$G(KEY),"row",+$G(ROW),"badgeLabel")=$G(LABEL)
 S TCTX("mega",$G(KEY),"row",+$G(ROW),"badgeClass")=$$BADGE^MIOUITHEME($S($G(TONE)'="":$G(TONE),1:"slate"))
 S TCTX("mega",$G(KEY),"row",+$G(ROW),"hasBadge")=$S($G(LABEL)'="":1,1:0)
 Q
 ;
MROWACT(TCTX,KEY,ROW,IDX,LABEL,HREF,CLASS)
 S TCTX("mega",$G(KEY),"row",+$G(ROW),"action",+$G(IDX),"label")=$G(LABEL)
 S TCTX("mega",$G(KEY),"row",+$G(ROW),"action",+$G(IDX),"href")=$G(HREF)
 S TCTX("mega",$G(KEY),"row",+$G(ROW),"action",+$G(IDX),"class")=$S($G(CLASS)'="":$G(CLASS),1:"quick-button")
 S TCTX("mega",$G(KEY),"row",+$G(ROW),"action",+$G(IDX),"isLink")=1
 Q
 ;
MDETAIL(TCTX,KEY,ROW,TITLE,BODY)
 S TCTX("mega",$G(KEY),"row",+$G(ROW),"detailTitle")=$G(TITLE)
 S TCTX("mega",$G(KEY),"row",+$G(ROW),"detailBody")=$G(BODY)
 Q
 ;
FINAL(TCTX,KEY)
 N I,R,VC,RC,SC,CC
 S (I,R,VC,RC,SC,CC)=0
 F  S I=$O(TCTX("mega",$G(KEY),"col",I)) Q:'I  D
 . S CC=CC+1
 . I +$G(TCTX("mega",$G(KEY),"col",I,"isVisible")) S VC=VC+1
 F  S I=$O(TCTX("mega",$G(KEY),"selectedColumn",I)) Q:'I  S SC=SC+1
 F  S R=$O(TCTX("mega",$G(KEY),"row",R)) Q:'R  D
 . S RC=RC+1
 . S TCTX("mega",$G(KEY),"row",R,"detailColspan")=CC+1
 S TCTX("mega",$G(KEY),"columnCount")=CC
 S TCTX("mega",$G(KEY),"visibleColumnCount")=VC
 S TCTX("mega",$G(KEY),"selectedColumnCount")=SC
 S TCTX("mega",$G(KEY),"rowCount")=RC
 S TCTX("mega",$G(KEY),"hasRows")=$S(RC>0:1,1:0)
 D HTML(.TCTX,$G(KEY))
 Q
 ;
HTML(TCTX,KEY)
 N I,R,HEADER,BODY,Q
 S Q=$C(34),HEADER="",BODY=""
 S I=0 F  S I=$O(TCTX("mega",$G(KEY),"col",I)) Q:'I  D
 . S HEADER=HEADER_$$COLHTML(.TCTX,$G(KEY),I)
 S HEADER=HEADER_"<th class="_Q_"px-4 py-3 align-top"_Q_">Actions</th>"
 S R=0 F  S R=$O(TCTX("mega",$G(KEY),"row",R)) Q:'R  D
 . S BODY=BODY_$$ROWHMTL(.TCTX,$G(KEY),R)
 S TCTX("mega",$G(KEY),"headerHtml")=HEADER
 S TCTX("mega",$G(KEY),"bodyHtml")=BODY
 Q
 ;
COLHTML(TCTX,KEY,IDX)
 N HTML,LBL,SORTDIR,SORTHREF,ALIGN,STICKY,WIDTH,Q
 S Q=$C(34)
 S LBL=$G(TCTX("mega",$G(KEY),"col",+$G(IDX),"label"))
 S SORTDIR=$G(TCTX("mega",$G(KEY),"col",+$G(IDX),"sortDir"))
 S SORTHREF=$G(TCTX("mega",$G(KEY),"col",+$G(IDX),"sortHref"))
 S ALIGN=$G(TCTX("mega",$G(KEY),"col",+$G(IDX),"alignClass"))
 S STICKY=$G(TCTX("mega",$G(KEY),"col",+$G(IDX),"stickyClass"))
 S WIDTH=$G(TCTX("mega",$G(KEY),"col",+$G(IDX),"width"))
 S HTML="<th class="_Q_"px-4 py-3 align-top "_ALIGN_" "_STICKY_Q_" style="_Q_"width: "_WIDTH_";"_Q_"><div class="_Q_"flex flex-wrap items-center gap-2"_Q_"><span>"_LBL_"</span>"
 I +$G(TCTX("mega",$G(KEY),"col",+$G(IDX),"isPinned")) S HTML=HTML_"<span class="_Q_"badge badge-slate"_Q_">Pinned</span>"
 I +$G(TCTX("mega",$G(KEY),"col",+$G(IDX),"isSorted")) S HTML=HTML_"<span class="_Q_"badge badge-sky"_Q_">"_SORTDIR_"</span>"
 S HTML=HTML_"</div><div class="_Q_"mt-1 text-xs"_Q_"><a href="_Q_SORTHREF_Q_" class="_Q_"hover:underline"_Q_">Order column</a></div></th>"
 Q HTML
 ;
ROWHMTL(TCTX,KEY,ROW)
 N HTML,I,CELLHTML,ROWCLASS,ACTHTML,BADGEHTML,COLSPAN,DTITLE,DBODY,Q
 S Q=$C(34)
 S ROWCLASS=$G(TCTX("mega",$G(KEY),"row",+$G(ROW),"rowClass"))
 S HTML="<tr class="_Q_"border-t border-slate-500/10 "_ROWCLASS_Q_">"
 S I=0 F  S I=$O(TCTX("mega",$G(KEY),"row",+$G(ROW),"cell",I)) Q:'I  D
 . S CELLHTML=$$CELLHTML(.TCTX,$G(KEY),ROW,I)
 . S HTML=HTML_CELLHTML
 S ACTHTML=""
 I +$G(TCTX("mega",$G(KEY),"row",+$G(ROW),"hasBadge")) D
 . S BADGEHTML="<span class="_Q_"badge "_$G(TCTX("mega",$G(KEY),"row",+$G(ROW),"badgeClass"))_Q_">"_$G(TCTX("mega",$G(KEY),"row",+$G(ROW),"badgeLabel"))_"</span>"
 . S ACTHTML=ACTHTML_BADGEHTML
 S I=0 F  S I=$O(TCTX("mega",$G(KEY),"row",+$G(ROW),"action",I)) Q:'I  D
 . S ACTHTML=ACTHTML_"<a href="_Q_$G(TCTX("mega",$G(KEY),"row",+$G(ROW),"action",I,"href"))_Q_" class="_Q_$G(TCTX("mega",$G(KEY),"row",+$G(ROW),"action",I,"class"))_Q_">"_$G(TCTX("mega",$G(KEY),"row",+$G(ROW),"action",I,"label"))_"</a>"
 S HTML=HTML_"<td class="_Q_"px-4 py-3 align-top"_Q_"><div class="_Q_"flex flex-wrap items-center gap-2"_Q_">"_ACTHTML_"</div></td></tr>"
 I +$G(TCTX("mega",$G(KEY),"row",+$G(ROW),"isExpanded")) D
 . S COLSPAN=+$G(TCTX("mega",$G(KEY),"row",+$G(ROW),"detailColspan"))
 . S DTITLE=$G(TCTX("mega",$G(KEY),"row",+$G(ROW),"detailTitle"))
 . S DBODY=$G(TCTX("mega",$G(KEY),"row",+$G(ROW),"detailBody"))
 . S HTML=HTML_"<tr class="_Q_"border-t border-slate-500/10 bg-slate-500/5"_Q_"><td colspan="_Q_COLSPAN_Q_" class="_Q_"px-4 py-4"_Q_"><div class="_Q_"panel-soft rounded-2xl p-4"_Q_"><div class="_Q_"text-sm font-semibold"_Q_">"_DTITLE_"</div><p class="_Q_"mt-2 text-sm muted"_Q_">"_DBODY_"</p></div></td></tr>"
 Q HTML
 ;
CELLHTML(TCTX,KEY,ROW,IDX)
 N HTML,ALIGN,STICKY,TXTCLS,VAL,Q
 S Q=$C(34)
 S ALIGN=$G(TCTX("mega",$G(KEY),"row",+$G(ROW),"cell",+$G(IDX),"alignClass"))
 S STICKY=$S(+$G(TCTX("mega",$G(KEY),"row",+$G(ROW),"cell",+$G(IDX),"isPinned")):"sticky left-0 z-10 bg-slate-950/95",1:"")
 S HTML="<td class="_Q_"px-4 py-3 align-top "_ALIGN_" "_STICKY_Q_">"
 I +$G(TCTX("mega",$G(KEY),"row",+$G(ROW),"cell",+$G(IDX),"isIdentity")) D  Q HTML_"</td>"
 . S HTML=HTML_"<div class="_Q_"font-semibold"_Q_">"_$G(TCTX("mega",$G(KEY),"row",+$G(ROW),"primary"))_"</div>"
 . S HTML=HTML_"<div class="_Q_"mt-1 text-sm muted"_Q_">"_$G(TCTX("mega",$G(KEY),"row",+$G(ROW),"secondary"))_"</div>"
 . S HTML=HTML_"<div class="_Q_"mt-1 text-xs muted"_Q_">"_$G(TCTX("mega",$G(KEY),"row",+$G(ROW),"meta"))_"</div>"
 S TXTCLS=$G(TCTX("mega",$G(KEY),"row",+$G(ROW),"cell",+$G(IDX),"textClass"))
 S VAL=$G(TCTX("mega",$G(KEY),"row",+$G(ROW),"cell",+$G(IDX),"value"))
 S HTML=HTML_"<span class="_Q_TXTCLS_Q_">"_VAL_"</span></td>"
 Q HTML
 ;
COMMA(N)
 N S,L,OUT
 S S=$TR($J(+$G(N),1,0)," ","")
 S L=$L(S)
 I L<4 Q S
 S OUT=""
 F  Q:L'>3  D
 . S OUT=","_$E(S,L-2,L)_OUT
 . S L=L-3
 S OUT=$E(S,1,L)_OUT
 Q OUT
 ;
