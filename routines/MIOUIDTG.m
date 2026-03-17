MIOUIDTG ; detailed data-grid builders for dense operator review
	Q
	;
INIT(TCTX,KEY,TITLE,LEAD,EMPTYTXT)
	K TCTX("grid",$G(KEY))
	S TCTX("grid",$G(KEY),"id")=$G(KEY)
	S TCTX("grid",$G(KEY),"title")=$G(TITLE)
	S TCTX("grid",$G(KEY),"lead")=$G(LEAD)
	S TCTX("grid",$G(KEY),"emptyText")=$G(EMPTYTXT)
	Q
	;
INSIGHT(TCTX,KEY,IDX,LABEL,VALUE,TONE)
	S TCTX("grid",$G(KEY),"insight",IDX,"label")=$G(LABEL)
	S TCTX("grid",$G(KEY),"insight",IDX,"value")=$G(VALUE)
	S TCTX("grid",$G(KEY),"insight",IDX,"badgeClass")=$$BADGE^MIOUITHEME($S($G(TONE)'="":TONE,1:"slate"))
	Q
	;
PREF(TCTX,KEY,IDX,LABEL,VALUE)
	S TCTX("grid",$G(KEY),"pref",IDX,"label")=$G(LABEL)
	S TCTX("grid",$G(KEY),"pref",IDX,"value")=$G(VALUE)
	Q
	;
SUMMARY(TCTX,KEY,COUNT,BODY)
	S TCTX("grid",$G(KEY),"selection","count")=+$G(COUNT)
	S TCTX("grid",$G(KEY),"selection","body")=$G(BODY)
	S TCTX("grid",$G(KEY),"selection","summary")=+$G(COUNT)_" selected for publish"
	Q
	;
SUMACT(TCTX,KEY,IDX,LABEL,HREF,CLASS)
	S TCTX("grid",$G(KEY),"selection","action",IDX,"label")=$G(LABEL)
	S TCTX("grid",$G(KEY),"selection","action",IDX,"href")=$G(HREF)
	S TCTX("grid",$G(KEY),"selection","action",IDX,"class")=$S($G(CLASS)'="":CLASS,1:"quick-button")
	S TCTX("grid",$G(KEY),"selection","action",IDX,"isLink")=1
	Q
	;
COL(TCTX,KEY,IDX,LABEL,ALIGN,WIDTH,SORTLABEL,ISSORTED)
	S TCTX("grid",$G(KEY),"col",IDX,"label")=$G(LABEL)
	S TCTX("grid",$G(KEY),"col",IDX,"align")=$S($G(ALIGN)'="":ALIGN,1:"left")
	S TCTX("grid",$G(KEY),"col",IDX,"alignClass")=$S($G(ALIGN)="right":"text-right",1:"text-left")
	S TCTX("grid",$G(KEY),"col",IDX,"width")=$S($G(WIDTH)'="":WIDTH,1:"10rem")
	S TCTX("grid",$G(KEY),"col",IDX,"sortLabel")=$G(SORTLABEL)
	S TCTX("grid",$G(KEY),"col",IDX,"isSorted")=+$G(ISSORTED)
	Q
	;
ROW(TCTX,KEY,IDX,PRIMARY,SECONDARY,META,SELECTED,HREF)
	S TCTX("grid",$G(KEY),"row",IDX,"primary")=$G(PRIMARY)
	S TCTX("grid",$G(KEY),"row",IDX,"secondary")=$G(SECONDARY)
	S TCTX("grid",$G(KEY),"row",IDX,"meta")=$G(META)
	S TCTX("grid",$G(KEY),"row",IDX,"href")=$G(HREF)
	S TCTX("grid",$G(KEY),"row",IDX,"hasHref")=$S($G(HREF)'="":1,1:0)
	S TCTX("grid",$G(KEY),"row",IDX,"isSelected")=+$G(SELECTED)
	S TCTX("grid",$G(KEY),"row",IDX,"rowClass")=$S(+$G(SELECTED):"bg-sky-500/10",1:"")
	Q
	;
CELL(TCTX,KEY,ROW,COL,VAL,EMPH)
	S TCTX("grid",$G(KEY),"row",ROW,"cell",COL,"value")=$G(VAL)
	S TCTX("grid",$G(KEY),"row",ROW,"cell",COL,"isStrong")=+$G(EMPH)
	Q
	;
ROWBADGE(TCTX,KEY,ROW,LABEL,TONE)
	S TCTX("grid",$G(KEY),"row",ROW,"badgeLabel")=$G(LABEL)
	S TCTX("grid",$G(KEY),"row",ROW,"badgeClass")=$$BADGE^MIOUITHEME($S($G(TONE)'="":TONE,1:"slate"))
	S TCTX("grid",$G(KEY),"row",ROW,"hasBadge")=$S($G(LABEL)'="":1,1:0)
	Q
	;
ROWACT(TCTX,KEY,ROW,IDX,LABEL,HREF,CLASS)
	S TCTX("grid",$G(KEY),"row",ROW,"action",IDX,"label")=$G(LABEL)
	S TCTX("grid",$G(KEY),"row",ROW,"action",IDX,"href")=$G(HREF)
	S TCTX("grid",$G(KEY),"row",ROW,"action",IDX,"class")=$S($G(CLASS)'="":CLASS,1:"quick-button")
	S TCTX("grid",$G(KEY),"row",ROW,"action",IDX,"isLink")=1
	Q
	;
FINAL(TCTX,KEY)
	N R,C,SEL
	S (R,C,SEL)=0
	F  S R=$O(TCTX("grid",$G(KEY),"row",R)) Q:'R  D
	. S C=C+1
	. I +$G(TCTX("grid",$G(KEY),"row",R,"isSelected")) S SEL=SEL+1
	S TCTX("grid",$G(KEY),"rowCount")=C
	S TCTX("grid",$G(KEY),"selectedCount")=SEL
	S TCTX("grid",$G(KEY),"hasRows")=$S(C>0:1,1:0)
	Q
	;