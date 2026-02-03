MIOREGAPI ; Public JSON registry API.;
; API STABILITY
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; PURPOSE
; Provide a stable JSON API for the package registry.;
; This is used by tools like a package manager or CLI.;
;
; PUBLIC ROUTES
; GET /api/registry
; GET /api/registry/:slug
	;
REG(CONF) ;
	DO ADD^MIOROUTE("GET","/api/registry","LIST^MIOREGAPI")
	DO ADD^MIOROUTE("GET","/api/registry/:slug","GET^MIOREGAPI")
	DO ADD^MIOROUTE("GET","/api/registry/:slug/versions","VERS^MIOREGAPI")
	QUIT
	;
LIST(DEV,CONF,REQ,CTX) ;
	DO ENSURE(.CONF)
	NEW Q SET Q=$$QGET(.REQ,"q")
	NEW CAT SET CAT=$$QGET(.REQ,"cat")
	NEW TAG SET TAG=$$LC^MIOUTIL($$QGET(.REQ,"tag"))
	NEW TIER SET TIER=$$LC^MIOUTIL($$QGET(.REQ,"tier"))
	NEW SORT SET SORT=$$LC^MIOUTIL($$QGET(.REQ,"sort")) IF SORT="" SET SORT="featured"
	NEW PAGE SET PAGE=+($$QGET(.REQ,"page")) IF PAGE<1 SET PAGE=1
	NEW PER SET PER=+($$QGET(.REQ,"per")) IF PER<1 SET PER=25 IF PER>200 SET PER=200
	;
	; Reuse MIORP sorting logic.;
	NEW ORDER,MATCH,TOTAL,SLUG,SK
	SET TOTAL=0,SLUG=""
	FOR  SET SLUG=$ORDER(^MIO("PKG","IDX","ALL",SLUG)) QUIT:SLUG=""  DO
	. IF '$$MATCH^MIORP(SLUG,Q,CAT,TAG,TIER) QUIT
	. SET SK=$$SORTKEY^MIORP(SLUG,SORT)
	. SET ORDER(SK,SLUG)=1
	;
	NEW SK1 SET SK1=""
	FOR  SET SK1=$ORDER(ORDER(SK1)) QUIT:SK1=""  DO
	. NEW S2 SET S2=""
	. FOR  SET S2=$ORDER(ORDER(SK1,S2)) QUIT:S2=""  DO
	. . SET TOTAL=TOTAL+1
	. . SET MATCH(TOTAL)=S2
	;
	NEW TOTALP SET TOTALP=$SELECT(TOTAL=0:1,1:((TOTAL+PER-1)\PER))
	IF PAGE>TOTALP SET PAGE=TOTALP
	NEW START SET START=((PAGE-1)*PER)+1
	NEW STOP SET STOP=START+PER-1
	;
	NEW OBJ KILL OBJ
	SET OBJ("page")=PAGE
	SET OBJ("per")=PER
	SET OBJ("total")=TOTAL
	SET OBJ("totalPages")=TOTALP
	;
	NEW N SET N=0
	NEW POS FOR POS=START:1:STOP QUIT:POS>TOTAL  DO
	. SET SLUG=$GET(MATCH(POS)) QUIT:SLUG=""
	. SET N=N+1
	. DO ONE(SLUG,.OBJ,N)
	;
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	QUIT
	;
GET(DEV,CONF,REQ,CTX) ;
	DO ENSURE(.CONF)
	NEW SLUG SET SLUG=$GET(REQ("params","slug"))
	IF SLUG="" DO  QUIT
	. DO RESPJSON^MIOHTTP(DEV,404,.CTX,"{""error"":""not_found""}")
	IF '$DATA(^MIO("PKG","ITEM",SLUG)) DO  QUIT
	. DO RESPJSON^MIOHTTP(DEV,404,.CTX,"{""error"":""not_found""}")
	NEW OBJ KILL OBJ
	DO ONE(SLUG,.OBJ,1)
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	QUIT
	;
ONE(SLUG,OBJ,IDX) ;
	NEW KEY
	SET OBJ("packages",IDX,"slug")=SLUG
	FOR KEY="name","category","version","license","maintainer","summary","docsUrl","repoUrl","tier","price","downloads","featured","updatedMs" DO
	. SET OBJ("packages",IDX,KEY)=$GET(^MIO("PKG","ITEM",SLUG,KEY))
	NEW T,J SET T="",J=0
	FOR  SET T=$ORDER(^MIO("PKG","ITEM",SLUG,"tag",T)) QUIT:T=""  DO
	. SET J=J+1
	. SET OBJ("packages",IDX,"tags",J)=T
	QUIT
	;
VERS(DEV,CONF,REQ,CTX) ;
	DO ENSURE(.CONF)
	NEW SLUG SET SLUG=$GET(REQ("params","slug"))
	IF SLUG="" DO  QUIT
	. DO RESPJSON^MIOHTTP(DEV,404,.CTX,"{""error"":""not_found""}")
	IF '$DATA(^MIO("PKG","ITEM",SLUG)) DO  QUIT
	. DO RESPJSON^MIOHTTP(DEV,404,.CTX,"{""error"":""not_found""}")
	;
	NEW VLIST DO LISTVERS^MIOPKG(SLUG,.VLIST)
	NEW OBJ KILL OBJ
	SET OBJ("slug")=SLUG
	SET OBJ("latest")=$$LATEST^MIOPKG(SLUG)
	NEW I SET I=0
	FOR  SET I=$ORDER(VLIST(I)) QUIT:I=""  SET OBJ("versions",I)=VLIST(I)
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	QUIT
	;
ENSURE(CONF) ;
	DO ENSURE^MIOPKG(.CONF)
	QUIT
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
	;