MIOUIPANEL ; MIOUI panel, stat, diagnostic, and artifact builders
 Q
 ;
STAT(TCTX,IDX,LABEL,VALUE,TONE,HREF)
 S TCTX("summarycards",IDX,"label")=$G(LABEL)
 S TCTX("summarycards",IDX,"value")=$G(VALUE)
 S TCTX("summarycards",IDX,"tone")=$$PANEL^MIOUITHEME($G(TONE))
 S TCTX("summarycards",IDX,"badge")=$$BADGE^MIOUITHEME($G(TONE))
 S TCTX("summarycards",IDX,"href")=$G(HREF)
 Q
 ;
KV(TCTX,GROUP,IDX,LABEL,VALUE)
 S TCTX($G(GROUP),IDX,"label")=$G(LABEL)
 S TCTX($G(GROUP),IDX,"value")=$G(VALUE)
 Q
 ;
EMPTY(TCTX,KEY,TITLE,BODY,ACTIONLABEL,ACTIONHREF)
 S TCTX($G(KEY),"title")=$G(TITLE)
 S TCTX($G(KEY),"body")=$G(BODY)
 S TCTX($G(KEY),"actionLabel")=$G(ACTIONLABEL)
 S TCTX($G(KEY),"actionHref")=$G(ACTIONHREF)
 S TCTX($G(KEY),"hasAction")=$S($G(ACTIONLABEL)'="":1,1:0)
 Q
 ;
ARTIFACT(TCTX,GROUP,IDX,NAME,BADGE,HREF,TYPE)
 S TCTX("downloadGroup",$G(GROUP),"item",IDX,"name")=$G(NAME)
 S TCTX("downloadGroup",$G(GROUP),"item",IDX,"badge")=$G(BADGE)
 S TCTX("downloadGroup",$G(GROUP),"item",IDX,"href")=$G(HREF)
 S TCTX("downloadGroup",$G(GROUP),"item",IDX,"type")=$G(TYPE)
 S TCTX("downloadGroup",$G(GROUP),"hasItems")=1
 S TCTX("downloadsAny")=1
 Q
 ;
ARTMETA(TCTX,GROUP,LABEL,DESC,TONE)
 S TCTX("downloadGroup",$G(GROUP),"label")=$G(LABEL)
 S TCTX("downloadGroup",$G(GROUP),"desc")=$G(DESC)
 S TCTX("downloadGroup",$G(GROUP),"tone")=$$PANEL^MIOUITHEME($G(TONE))
 Q
 ;
DIAG(TCTX,KIND,IDX,MSG)
 S TCTX("diagnostic",$G(KIND),IDX,"msg")=$G(MSG)
 S TCTX("diagnostic",$G(KIND)_"Any")=1
 Q
 ;
DIAGSUM(TCTX,WARN,ERR)
 S TCTX("diagnostic","warnings")=+$G(WARN)
 S TCTX("diagnostic","errors")=+$G(ERR)
 Q
 ;
