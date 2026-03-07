MIOTPL5MIN ; MIOTPL 5-minute success demo
;
; PURPOSE
; - Smallest working example: layout + blocks + partials + list rendering.
;
; USAGE (YottaDB/GT.M)
;   ZL "MIOTPL","MIOTPL5MIN"
;   D RUN^MIOTPL5MIN
;
RUN ; render templates/pages/home.html with templates/layouts/app_layout.html
  N CONF,CTX,OUT,ERR
  D CONF(.CONF)
  D CTX(.CTX)
  D START^MIOTPL(.CONF)
  D RENDERPAGE^MIOTPL("pages/home.html","layouts/app_layout.html",.CONF,.CTX,.OUT,.ERR)
  I $D(ERR) D  Q
  . W "[MIOTPL5MIN] ERROR: ",$G(ERR("code"))," ",$G(ERR("msg")),!
  . I $D(ERR("stack")) D
  . . N I S I=0 F  S I=$O(ERR("stack",I)) Q:'I  D
  . . . W "  at ",$G(ERR("stack",I,"type"))," ", $G(ERR("stack",I,"name"))," ",$G(ERR("stack",I,"line")),":",$G(ERR("stack",I,"col")),!
  W OUT,!
  Q

CONF(CONF)
  ; Adjust root if your templates folder is elsewhere.
  S CONF("templates","root")="templates/"
  S CONF("templates","ext")=".html"
  ; safe defaults
  S CONF("templates","precompileEnabled")=0
  S CONF("templates","streamFiles")=0
  S CONF("templates","streamFallback")=1
  S CONF("templates","maxPartialDepth")=20
  ; output policy
  S CONF("output","auto")=1
  S CONF("output","maxString")=900000
  S CONF("output","autoReturnRef")=1
  Q

CTX(CTX)
  ; demo context
  S CTX("title")="It works."
  S CTX("subtitle")="MIOTPL rendered this with a layout + partial."
  S CTX("now")=$$NOW()
  ; list
  S CTX("items",1,"id")=101,CTX("items",1,"name")="Alpha"
  S CTX("items",2,"id")=102,CTX("items",2,"name")="Beta"
  S CTX("items",3,"id")=103,CTX("items",3,"name")="Gamma"
  ; a tiny preview string (keep it short)
  S CTX("ctxPreview")="title="_CTX("title")_$C(10)_"items="_3
  Q

NOW() ; simple timestamp using $H (demo only)
  N H,DAY,SEC
  S H=$H,DAY=$P(H,","),SEC=$P(H,",",2)
  Q "DAY"_DAY_"TSEC"_SEC
