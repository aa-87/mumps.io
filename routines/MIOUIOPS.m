MIOUIOPS ; MIOUI dense operator ergonomics builders
 Q
 ;
PHEADER(TCTX,KEY,EYEBROW,TITLE,LEAD)
 K TCTX("pageHeader",$G(KEY))
 S TCTX("pageHeader",$G(KEY),"eyebrow")=$G(EYEBROW)
 S TCTX("pageHeader",$G(KEY),"title")=$G(TITLE)
 S TCTX("pageHeader",$G(KEY),"lead")=$G(LEAD)
 Q
 ;
PHEADACT(TCTX,KEY,IDX,LABEL,HREF,CLASS)
 S TCTX("pageHeader",$G(KEY),"action",+$G(IDX),"label")=$G(LABEL)
 S TCTX("pageHeader",$G(KEY),"action",+$G(IDX),"href")=$G(HREF)
 S TCTX("pageHeader",$G(KEY),"action",+$G(IDX),"class")=$S($G(CLASS)'="":CLASS,1:"quick-button")
 S TCTX("pageHeader",$G(KEY),"action",+$G(IDX),"isLink")=1
 Q
 ;
PHEADMETA(TCTX,KEY,IDX,LABEL,VALUE,TONE)
 S TCTX("pageHeader",$G(KEY),"meta",+$G(IDX),"label")=$G(LABEL)
 S TCTX("pageHeader",$G(KEY),"meta",+$G(IDX),"value")=$G(VALUE)
 S TCTX("pageHeader",$G(KEY),"meta",+$G(IDX),"badgeClass")=$$BADGE^MIOUITHEME($S($G(TONE)'="":$G(TONE),1:"slate"))
 Q
 ;
SUBINIT(TCTX,KEY,TITLE)
 K TCTX("subnav",$G(KEY))
 S TCTX("subnav",$G(KEY),"title")=$G(TITLE)
 Q
 ;
SUBITEM(TCTX,KEY,IDX,LABEL,HREF,ACTIVE)
 S TCTX("subnav",$G(KEY),"item",+$G(IDX),"label")=$G(LABEL)
 S TCTX("subnav",$G(KEY),"item",+$G(IDX),"href")=$G(HREF)
 S TCTX("subnav",$G(KEY),"item",+$G(IDX),"isActive")=+$G(ACTIVE)
 S TCTX("subnav",$G(KEY),"item",+$G(IDX),"class")=$S(+$G(ACTIVE):"primary-button",1:"quick-button")
 Q
 ;
SUBFINAL(TCTX,KEY)
 N I,C,CUR
 S (I,C,CUR)=0
 F  S I=$O(TCTX("subnav",$G(KEY),"item",I)) Q:'I  D
 . S C=C+1
 . I +$G(TCTX("subnav",$G(KEY),"item",I,"isActive")) S CUR=$G(TCTX("subnav",$G(KEY),"item",I,"label"))
 S TCTX("subnav",$G(KEY),"count")=C
 S TCTX("subnav",$G(KEY),"currentLabel")=$G(CUR)
 Q
 ;
VIEWSINIT(TCTX,KEY,TITLE,LEAD)
 K TCTX("savedViews",$G(KEY))
 S TCTX("savedViews",$G(KEY),"title")=$G(TITLE)
 S TCTX("savedViews",$G(KEY),"lead")=$G(LEAD)
 Q
 ;
VIEW(TCTX,KEY,IDX,LABEL,HREF,ACTIVE,COUNT)
 N CLASS
 S CLASS=$S(+$G(ACTIVE):"primary-button",1:"quick-button")
 S TCTX("savedViews",$G(KEY),"item",+$G(IDX),"label")=$G(LABEL)
 S TCTX("savedViews",$G(KEY),"item",+$G(IDX),"href")=$G(HREF)
 S TCTX("savedViews",$G(KEY),"item",+$G(IDX),"isActive")=+$G(ACTIVE)
 S TCTX("savedViews",$G(KEY),"item",+$G(IDX),"count")=+$G(COUNT)
 S TCTX("savedViews",$G(KEY),"item",+$G(IDX),"class")=CLASS
 Q
 ;
VIEWSFINAL(TCTX,KEY)
 N I,C,CUR
 S (I,C,CUR)=0
 F  S I=$O(TCTX("savedViews",$G(KEY),"item",I)) Q:'I  D
 . S C=C+1
 . I +$G(TCTX("savedViews",$G(KEY),"item",I,"isActive")) S CUR=$G(TCTX("savedViews",$G(KEY),"item",I,"label"))
 S TCTX("savedViews",$G(KEY),"count")=C
 S TCTX("savedViews",$G(KEY),"currentLabel")=$G(CUR)
 Q
 ;
CHINIT(TCTX,KEY,TITLE,LEAD)
 K TCTX("columnChooser",$G(KEY))
 S TCTX("columnChooser",$G(KEY),"title")=$G(TITLE)
 S TCTX("columnChooser",$G(KEY),"lead")=$G(LEAD)
 Q
 ;
CHITEM(TCTX,KEY,IDX,LABEL,HELP,SELECTED)
 S TCTX("columnChooser",$G(KEY),"item",+$G(IDX),"label")=$G(LABEL)
 S TCTX("columnChooser",$G(KEY),"item",+$G(IDX),"help")=$G(HELP)
 S TCTX("columnChooser",$G(KEY),"item",+$G(IDX),"isSelected")=+$G(SELECTED)
 S TCTX("columnChooser",$G(KEY),"item",+$G(IDX),"stateLabel")=$S(+$G(SELECTED):"Visible",1:"Hidden")
 S TCTX("columnChooser",$G(KEY),"item",+$G(IDX),"badgeClass")=$$BADGE^MIOUITHEME($S(+$G(SELECTED):"emerald",1:"slate"))
 Q
 ;
CHFINAL(TCTX,KEY)
 N I,C,S
 S (I,C,S)=0
 F  S I=$O(TCTX("columnChooser",$G(KEY),"item",I)) Q:'I  D
 . S C=C+1
 . I +$G(TCTX("columnChooser",$G(KEY),"item",I,"isSelected")) S S=S+1
 S TCTX("columnChooser",$G(KEY),"count")=C
 S TCTX("columnChooser",$G(KEY),"selectedCount")=S
 S TCTX("columnChooser",$G(KEY),"summary")=S_" of "_C_" visible"
 Q
 ;
SPLITINIT(TCTX,KEY,TITLE,LEAD,SELECTED)
 K TCTX("splitPanel",$G(KEY))
 S TCTX("splitPanel",$G(KEY),"title")=$G(TITLE)
 S TCTX("splitPanel",$G(KEY),"lead")=$G(LEAD)
 S TCTX("splitPanel",$G(KEY),"selectedTitle")=$G(SELECTED)
 Q
 ;
SPLITSUM(TCTX,KEY,IDX,LABEL,VALUE)
 S TCTX("splitPanel",$G(KEY),"summary",+$G(IDX),"label")=$G(LABEL)
 S TCTX("splitPanel",$G(KEY),"summary",+$G(IDX),"value")=$G(VALUE)
 Q
 ;
SPLITFIELD(TCTX,KEY,IDX,LABEL,VALUE)
 S TCTX("splitPanel",$G(KEY),"field",+$G(IDX),"label")=$G(LABEL)
 S TCTX("splitPanel",$G(KEY),"field",+$G(IDX),"value")=$G(VALUE)
 Q
 ;
SPLITFINAL(TCTX,KEY)
 S TCTX("splitPanel",$G(KEY),"summaryCount")=$$COUNT^MIOUICTX($NA(TCTX("splitPanel",$G(KEY),"summary")))
 S TCTX("splitPanel",$G(KEY),"fieldCount")=$$COUNT^MIOUICTX($NA(TCTX("splitPanel",$G(KEY),"field")))
 Q
 ;
FEEDINIT(TCTX,KEY,TITLE,LEAD)
 K TCTX("activityFeed",$G(KEY))
 S TCTX("activityFeed",$G(KEY),"title")=$G(TITLE)
 S TCTX("activityFeed",$G(KEY),"lead")=$G(LEAD)
 Q
 ;
FEEDITEM(TCTX,KEY,IDX,STAMP,TITLE,BODY,TONE)
 S TCTX("activityFeed",$G(KEY),"item",+$G(IDX),"stamp")=$G(STAMP)
 S TCTX("activityFeed",$G(KEY),"item",+$G(IDX),"title")=$G(TITLE)
 S TCTX("activityFeed",$G(KEY),"item",+$G(IDX),"body")=$G(BODY)
 S TCTX("activityFeed",$G(KEY),"item",+$G(IDX),"badgeClass")=$$BADGE^MIOUITHEME($S($G(TONE)'="":$G(TONE),1:"slate"))
 Q
 ;
FEEDFINAL(TCTX,KEY)
 S TCTX("activityFeed",$G(KEY),"count")=$$COUNT^MIOUICTX($NA(TCTX("activityFeed",$G(KEY),"item")))
 Q
 ;
