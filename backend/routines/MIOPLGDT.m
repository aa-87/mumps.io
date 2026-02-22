MIOPLGDT ; MIOPLGD - self tests (smoke + basic render)
;
; Run:
;   YDB> D SMOKE^MIOPLGDT
;
; NOTE: These tests expect the working directory contains:
;   templates/layouts/plgd_layout.html
;   templates/pages/plgd_home.html
;   templates/pages/plgd_playground.html
;   templates/pages/plgd_about.html
;   templates/partials/*.html
;
SMOKE
	N CONF,CTX,OUT,ERR,OK,OPT
	K CONF,CTX,ERR
	D CONFDEF^MIOPLGD(.CONF)
	D START^MIOTPL(.CONF)
	D INIT^MIOPLGD(.CONF)
	;
	; 1) Home render
	K CTX S OK=1
	D BASECTX^MIOPLGD(.CTX)
	S CTX("page","heading")="MIOPLGD"
	S CTX("page","lead")="test"
	S CTX("tplCardPartial")="partials/ui_tpl_card_grid"
	S OPT("favOnly")=0 S OPT("view")="grid" S OPT("sort")="updated" D LOADLIB^MIOPLGD(.CTX,.OPT) D LOADMETA^MIOPLGD(.CTX,.OPT)
	D RENDERPAGE^MIOTPL("pages/plgd_home.html","layouts/plgd_layout.html",.CONF,.CTX,.OUT,.ERR)
	D ASSERT('$D(ERR),"Home rendered without errors") I $D(ERR) S OK=0
	D ASSERT($F(OUT,"MIOPLGD")>0,"Home contains brand") I $F(OUT,"MIOPLGD")=0 S OK=0
	;
	; 2) Playground render
	K CTX,ERR,OUT
	D BASECTX^MIOPLGD(.CTX)
	S CTX("page","heading")="Playground"
	S CTX("page","lead")="test"
	S CTX("sel","id")=""
	S CTX("sel","name")="New Template"
	S CTX("sel","group")="Scratch"
	S CTX("sel","tags")="starter"
	S CTX("sel","desc")="test"
	S CTX("sel","fav")=0
	S CTX("sel","tpl")="{{x}}"
	S CTX("sel","json")="{""x"":""y""}"
	K OPT S OPT("favOnly")=0
	D LOADLIB^MIOPLGD(.CTX,.OPT)
	D RENDERPAGE^MIOTPL("pages/plgd_playground.html","layouts/plgd_layout.html",.CONF,.CTX,.OUT,.ERR)
	D ASSERT('$D(ERR),"Playground rendered without errors") I $D(ERR) S OK=0
	D ASSERT($F(OUT,"api/render")>0,"Playground includes render endpoint") I $F(OUT,"api/render")=0 S OK=0
	;
	; 3) About render
	K CTX,ERR,OUT
	D BASECTX^MIOPLGD(.CTX)
	S CTX("page","heading")="About"
	S CTX("page","lead")="test"
	D RENDERPAGE^MIOTPL("pages/plgd_about.html","layouts/plgd_layout.html",.CONF,.CTX,.OUT,.ERR)
	D ASSERT('$D(ERR),"About rendered without errors") I $D(ERR) S OK=0
	;
	W !,$S(OK:"PASS",1:"FAIL")," - MIOPLGD SMOKE"
	Q
	;
ASSERT(COND,MSG)
	I $G(COND) W !,"OK: ",$G(MSG) Q
	W !,"FAIL: ",$G(MSG)
	Q
