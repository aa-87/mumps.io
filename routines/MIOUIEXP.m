MIOUIEXP ; MIOUI export and profile editing builders
 Q
 ;
SUMINIT(TCTX,KEY,TITLE,LEAD)
 K TCTX("exportProfile",$G(KEY))
 S TCTX("exportProfile",$G(KEY),"title")=$G(TITLE)
 S TCTX("exportProfile",$G(KEY),"lead")=$G(LEAD)
 Q
 ;
SUMSTAT(TCTX,KEY,IDX,LABEL,VALUE,TONE)
 S TCTX("exportProfile",$G(KEY),"stat",+$G(IDX),"label")=$G(LABEL)
 S TCTX("exportProfile",$G(KEY),"stat",+$G(IDX),"value")=$G(VALUE)
 S TCTX("exportProfile",$G(KEY),"stat",+$G(IDX),"panelClass")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
SUMRULE(TCTX,KEY,IDX,LABEL,VALUE)
 S TCTX("exportProfile",$G(KEY),"rule",+$G(IDX),"label")=$G(LABEL)
 S TCTX("exportProfile",$G(KEY),"rule",+$G(IDX),"value")=$G(VALUE)
 Q
 ;
CHKINIT(TCTX,KEY,TITLE,LEAD)
 K TCTX("checkboxGroup",$G(KEY))
 S TCTX("checkboxGroup",$G(KEY),"title")=$G(TITLE)
 S TCTX("checkboxGroup",$G(KEY),"lead")=$G(LEAD)
 Q
 ;
CHKITEM(TCTX,KEY,IDX,NAME,LABEL,HELP,CHECKED)
 N K,N
 S K=$G(KEY),N=+$G(IDX)
 S TCTX("checkboxGroup",K,"item",N,"name")=$G(NAME)
 S TCTX("checkboxGroup",K,"item",N,"label")=$G(LABEL)
 S TCTX("checkboxGroup",K,"item",N,"help")=$G(HELP)
 S TCTX("checkboxGroup",K,"item",N,"checked")=+$G(CHECKED)
 Q
 ;
CHKFINAL(TCTX,KEY)
 N K,I,C,SEL
 S K=$G(KEY),(I,C,SEL)=0
 F  S I=$O(TCTX("checkboxGroup",K,"item",I)) Q:'I  D
 . S C=C+1
 . I +$G(TCTX("checkboxGroup",K,"item",I,"checked")) S SEL=SEL+1
 S TCTX("checkboxGroup",K,"itemCount")=C
 S TCTX("checkboxGroup",K,"checkedCount")=SEL
 S TCTX("checkboxGroup",K,"hasItems")=$S(C>0:1,1:0)
 Q
 ;
ORDINIT(TCTX,KEY,TITLE,LEAD)
 K TCTX("columnEditor",$G(KEY))
 S TCTX("columnEditor",$G(KEY),"title")=$G(TITLE)
 S TCTX("columnEditor",$G(KEY),"lead")=$G(LEAD)
 Q
 ;
ORDITEM(TCTX,KEY,IDX,LABEL,FIELDKEY)
 N K,N
 S K=$G(KEY),N=+$G(IDX)
 S TCTX("columnEditor",K,"item",N,"position")=N
 S TCTX("columnEditor",K,"item",N,"label")=$G(LABEL)
 S TCTX("columnEditor",K,"item",N,"fieldKey")=$G(FIELDKEY)
 Q
 ;
ORDFINAL(TCTX,KEY)
 N K,I,C
 S K=$G(KEY),(I,C)=0
 F  S I=$O(TCTX("columnEditor",K,"item",I)) Q:'I  S C=C+1
 S TCTX("columnEditor",K,"itemCount")=C
 S TCTX("columnEditor",K,"hasItems")=$S(C>0:1,1:0)
 S I=0
 F  S I=$O(TCTX("columnEditor",K,"item",I)) Q:'I  D
 . S TCTX("columnEditor",K,"item",I,"canMoveUp")=$S(I>1:1,1:0)
 . S TCTX("columnEditor",K,"item",I,"canMoveDown")=$S(I<C:1,1:0)
 Q
 ;
FOOTINIT(TCTX,KEY,TITLE,LEAD)
 K TCTX("stickyFooter",$G(KEY))
 S TCTX("stickyFooter",$G(KEY),"title")=$G(TITLE)
 S TCTX("stickyFooter",$G(KEY),"lead")=$G(LEAD)
 Q
 ;
FOOTACT(TCTX,KEY,IDX,LABEL,HREF,CLASS)
 N K,N,C
 S K=$G(KEY),N=+$G(IDX),C=$G(CLASS)
 I C="" S C="quick-button"
 S TCTX("stickyFooter",K,"action",N,"label")=$G(LABEL)
 S TCTX("stickyFooter",K,"action",N,"href")=$G(HREF)
 S TCTX("stickyFooter",K,"action",N,"class")=C
 S TCTX("stickyFooter",K,"action",N,"isLink")=1
 Q
 ;
