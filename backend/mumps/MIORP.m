MIORP ; Package registry pages for MUMPS.IO.;
; API STABILITY
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; PURPOSE
; Serve the package registry pages.;
; Provide search, filters, sorting, and pagination.;
;
; PUBLIC ENTRY POINTS
; REG   - Register routes.;
; LIST  - GET /repo
; PKG   - GET /repo/:slug
	;
REG(CONF) ;
	DO ADD^MIOROUTE("GET","/repo","LIST^MIORP")
	DO ADD^MIOROUTE("GET","/repo/:slug","PKG^MIORP")
	QUIT
	;
	
	
	;
LIST(DEV,CONF,REQ,CTX) ;
	DO ENSURE(.CONF)
	;
	NEW Q SET Q=$$QGET(.REQ,"q")
	NEW CAT SET CAT=$$QGET(.REQ,"cat")
	NEW TAG SET TAG=$$LC^MIOUTIL($$QGET(.REQ,"tag"))
	NEW TIER SET TIER=$$LC^MIOUTIL($$QGET(.REQ,"tier"))
	NEW SORT SET SORT=$$LC^MIOUTIL($$QGET(.REQ,"sort")) IF SORT="" SET SORT="featured"
	;
	NEW PAGE SET PAGE=+$$QGET(.REQ,"page") IF PAGE<1 SET PAGE=1
	NEW PER SET PER=+$$QGET(.REQ,"per") IF PER<1 SET PER=12 IF PER>48 SET PER=48
	;
	NEW TCTX KILL TCTX
	SET TCTX("year")=$$YEAR^MIOUTIL()
	SET TCTX("desc")="MUMPS.IO package registry. Browse community and pro packages."
	SET TCTX("q")=Q
	SET TCTX("filters","cat")=CAT
	SET TCTX("filters","tag")=TAG
	SET TCTX("filters","tier")=TIER
	SET TCTX("filters","sort")=SORT
	;
	NEW CATS DO LISTCATS^MIOPKG(.CATS)
	NEW I SET I=0
	FOR  SET I=$ORDER(CATS(I)) QUIT:I=""  SET TCTX("cats","items",I)=CATS(I)
	;
	NEW TAGS DO LISTTAGS^MIOPKG(.TAGS,24)
	SET I=0
	FOR  SET I=$ORDER(TAGS(I)) QUIT:I=""  SET TCTX("tags","items",I)=TAGS(I)
	;
	; Build match list and sort keys.;
	NEW SLUG,MN SET SLUG="",MN=0
	NEW KEY,SK
	FOR  SET SLUG=$ORDER(^MIO("PKG","IDX","ALL",SLUG)) QUIT:SLUG=""  DO
	. IF '$$MATCH(SLUG,Q,CAT,TAG,TIER) QUIT
	. SET SK=$$SORTKEY(SLUG,SORT)
	. ; Use SK as first subscript for ordering.;
	. SET MN=MN+1
	. SET ORDER(SK,SLUG)=1
	;
	; Flatten ORDER into MATCH(n)=slug.;
	NEW TOTAL SET TOTAL=0
	NEW SK1 SET SK1=""
	FOR  SET SK1=$ORDER(ORDER(SK1)) QUIT:SK1=""  DO
	. NEW S2 SET S2=""
	. FOR  SET S2=$ORDER(ORDER(SK1,S2)) QUIT:S2=""  DO
	. . SET TOTAL=TOTAL+1
	. . SET MATCH(TOTAL)=S2
	;
	NEW TOTALP SET TOTALP=$SELECT(TOTAL=0:1,1:((TOTAL+PER-1)\PER))
	IF PAGE>TOTALP SET PAGE=TOTALP
	;
	NEW START SET START=((PAGE-1)*PER)+1
	NEW STOP SET STOP=START+PER-1
	;
	SET TCTX("pager","page")=PAGE
	SET TCTX("pager","per")=PER
	SET TCTX("pager","total")=TOTAL
	SET TCTX("pager","totalPages")=TOTALP
	SET TCTX("pager","base")=$$BASEURL(Q,CAT,TAG,TIER,SORT,PER)
	IF PAGE>1 SET TCTX("pager","prev")=TCTX("pager","base")_"&page="_(PAGE-1)
	IF PAGE<TOTALP SET TCTX("pager","next")=TCTX("pager","base")_"&page="_(PAGE+1)
	;
	NEW POS,IDX SET POS=0,IDX=0
	FOR POS=START:1:STOP QUIT:POS>TOTAL  DO
	. SET SLUG=$GET(MATCH(POS)) QUIT:SLUG=""
	. SET IDX=IDX+1
	. DO PACK(SLUG,.TCTX,IDX)
	;
	NEW OUT,ERR
	IF '$$RENDERPAGE^MIOTPL("mio_repo.html","mio_layout.html",.CONF,.TCTX,.OUT,.ERR) DO  QUIT
	. DO RESPJSON^MIOHTTP(DEV,500,.CTX,"{""error"":""template_error"",""detail"":"""_$$ESC^MIOUTIL($GET(ERR("error")))_"""}")
	;
	NEW BODY,K,HEAD SET BODY="",K=0
	FOR  SET K=$ORDER(OUT(K)) QUIT:K=""  SET BODY=BODY_OUT(K)
	S HEAD("Content-Type")="text/html; charset=utf-8"
	DO RESP^MIOHTTP(DEV,.CONF,200,.HEAD,.BODY,CTX("request_id"))
	QUIT
	;
PKG(DEV,CONF,REQ,CTX) ;
	DO ENSURE(.CONF)
	NEW SLUG SET SLUG=$GET(REQ("params","slug"))
	IF SLUG="" DO  QUIT
	. DO RESPJSON^MIOHTTP(DEV,404,.CTX,"{""error"":""not_found""}")
	IF '$DATA(^MIO("PKG","ITEM",SLUG)) DO  QUIT
	. DO RESPJSON^MIOHTTP(DEV,404,.CTX,"{""error"":""not_found""}")
	;
	NEW VERQ SET VERQ=$$QGET(.REQ,"ver")
	NEW VER,ERR
	IF VERQ'="" SET VER=VERQ
	ELSE  SET VER=$$LATEST^MIOPKG(SLUG)
	;
	NEW OUTREC KILL OUTREC
	IF '$$GETVER^MIOPKG(SLUG,VER,.OUTREC,.ERR) DO  QUIT
	. DO RESPJSON^MIOHTTP(DEV,404,.CTX,"{""error"":""not_found""}")
	;
	NEW TCTX KILL TCTX
	SET TCTX("year")=$$YEAR^MIOUTIL()
	SET TCTX("desc")="MUMPS.IO package details."
	SET TCTX("pkg","slug")=SLUG
	SET TCTX("pkg","selectedVer")=VER
	;
	NEW KEY
	FOR KEY="name","category","version","license","maintainer","summary","description","install","docsUrl","repoUrl","tier","price","downloads","featured" DO
	. SET TCTX("pkg",KEY)=$GET(OUTREC(KEY))
	;
	NEW J SET J=0
	FOR  SET J=$ORDER(OUTREC("tags",J)) QUIT:J=""  SET TCTX("pkg","tags","items",J)=OUTREC("tags",J)
	;
	NEW VLIST DO LISTVERS^MIOPKG(SLUG,.VLIST)
	NEW I SET I=0
	FOR  SET I=$ORDER(VLIST(I)) QUIT:I=""  DO
	. SET TCTX("versions",I,"ver")=VLIST(I)
	. SET TCTX("versions",I,"href")="/repo/"_SLUG_"?ver="_$$URLE^MIOUTIL(VLIST(I))
	. IF VLIST(I)=VER SET TCTX("versions",I,"selected")=1
	;
	NEW OUT,ERR2
	IF '$$RENDERPAGE^MIOTPL("mio_pkg.html","mio_layout.html",.CONF,.TCTX,.OUT,.ERR2) DO  QUIT
	. DO RESPJSON^MIOHTTP(DEV,500,.CTX,"{""error"":""template_error"",""detail"":"""_$$ESC^MIOUTIL($GET(ERR2("error")))_"""}")
	;
	NEW BODY,K SET BODY="",K=0
	FOR  SET K=$ORDER(OUT(K)) QUIT:K=""  SET BODY=BODY_OUT(K)
	DO RESP^MIOHTTP(DEV,200,"text/html; charset=utf-8",.CTX,BODY)
	QUIT
	;
ENSURE(CONF) ;
	DO ENSURE^MIOPKG(.CONF)
	QUIT
	;
PACK(SLUG,TCTX,IDX) ;
	SET TCTX("packages",IDX,"slug")=SLUG
	SET TCTX("packages",IDX,"name")=$GET(^MIO("PKG","ITEM",SLUG,"name"))
	SET TCTX("packages",IDX,"category")=$GET(^MIO("PKG","ITEM",SLUG,"category"))
	SET TCTX("packages",IDX,"version")=$GET(^MIO("PKG","ITEM",SLUG,"version"))
	SET TCTX("packages",IDX,"license")=$GET(^MIO("PKG","ITEM",SLUG,"license"))
	SET TCTX("packages",IDX,"summary")=$GET(^MIO("PKG","ITEM",SLUG,"summary"))
	SET TCTX("packages",IDX,"tier")=$GET(^MIO("PKG","ITEM",SLUG,"tier"))
	SET TCTX("packages",IDX,"price")=$GET(^MIO("PKG","ITEM",SLUG,"price"))
	SET TCTX("packages",IDX,"downloads")=+$GET(^MIO("PKG","ITEM",SLUG,"downloads"))
	IF +$GET(^MIO("PKG","ITEM",SLUG,"featured"))=1 SET TCTX("packages",IDX,"featured")=1
	NEW J,TAG3 SET J=0,TAG3=""
	FOR  SET TAG3=$ORDER(^MIO("PKG","ITEM",SLUG,"tag",TAG3)) QUIT:TAG3=""  DO
	. SET J=J+1
	. SET TCTX("packages",IDX,"tags","items",J)=TAG3
	QUIT
	;
MATCH(SLUG,Q,CAT,TAG,TIER) ;
	IF CAT'="",CAT'=$GET(^MIO("PKG","ITEM",SLUG,"category")) QUIT 0
	IF TIER'="",TIER'=$$LC^MIOUTIL($GET(^MIO("PKG","ITEM",SLUG,"tier"))) QUIT 0
	IF TAG'="",'$DATA(^MIO("PKG","ITEM",SLUG,"tag",TAG)) QUIT 0
	IF $L(Q) DO  QUIT OK
	. NEW H SET H=$$LC^MIOUTIL($GET(^MIO("PKG","ITEM",SLUG,"name"))_" "_$GET(^MIO("PKG","ITEM",SLUG,"summary"))_" "_$GET(^MIO("PKG","ITEM",SLUG,"category")))
	. SET OK=(H[$$LC^MIOUTIL(Q))
	QUIT 1
	;
SORTKEY(SLUG,SORT) ;
	; Keys are built so that $ORDER yields the correct order.;
	; Use inverted numbers for descending sorts.;
	NEW K
	IF SORT="name" QUIT $$LC^MIOUTIL($GET(^MIO("PKG","ITEM",SLUG,"name")))_$CHAR(0)
	IF SORT="recent" DO  QUIT K
	. NEW MS SET MS=+$GET(^MIO("PKG","ITEM",SLUG,"updatedMs"))
	. SET K=$$INVNUM(MS)_$CHAR(0)
	IF SORT="popular" DO  QUIT K
	. NEW D SET D=+$GET(^MIO("PKG","ITEM",SLUG,"downloads"))
	. SET K=$$INVNUM(D)_$CHAR(0)
	; featured default: featured desc, then recent desc
	NEW F SET F=+$GET(^MIO("PKG","ITEM",SLUG,"featured"))
	NEW MS SET MS=+$GET(^MIO("PKG","ITEM",SLUG,"updatedMs"))
	SET K=$$INVNUM(F)_"-"_$$INVNUM(MS)_$CHAR(0)
	QUIT K
	;
INVNUM(N) ;
	; Invert non-negative integers for descending lexicographic order.;
	; Pad to 20 digits.;
	NEW X SET X=+$GET(N) IF X<0 SET X=0
	NEW P SET P=99999999999999999999-X
	NEW S SET S=P
	; left pad
	FOR  QUIT:$L(S)'<20  SET S="0"_S
	QUIT S
	;
BASEURL(Q,CAT,TAG,TIER,SORT,PER) ;
	NEW U SET U="/repo?"
	SET U=U_"q="_$$URLE^MIOUTIL(Q)
	IF CAT'="" SET U=U_"&cat="_$$URLE^MIOUTIL(CAT)
	IF TAG'="" SET U=U_"&tag="_$$URLE^MIOUTIL(TAG)
	IF TIER'="" SET U=U_"&tier="_$$URLE^MIOUTIL(TIER)
	IF SORT'="" SET U=U_"&sort="_$$URLE^MIOUTIL(SORT)
	SET U=U_"&per="_PER
	QUIT U
	;
QGET(REQ,KEY) ;
	NEW V SET V=$GET(REQ("query",KEY))
	IF V'="" QUIT V
	NEW URI SET URI=$GET(REQ("uri")) IF URI="" SET URI=$GET(REQ("rawuri"))
	IF URI'["?" QUIT ""
	NEW QSTR SET QSTR=$PIECE(URI,"?",2,999)
	NEW I,PAIR,K,VAL
	FOR I=1:1:$L(QSTR,"&") DO
	. SET PAIR=$PIECE(QSTR,"&",I)
	. SET K=$PIECE(PAIR,"=",1),VAL=$PIECE(PAIR,"=",2,999)
	. IF $$LC^MIOUTIL(K)=$$LC^MIOUTIL(KEY) SET V=$$URLDEC^MIOUTIL(VAL)
	QUIT V