MIOIDER ; MIOIDE routes and handlers
	Q
	;
REG(CONF)
	N META
	K META
	S META("authRequired")=+$G(CONF("mioide","authRequired"),1)
	S META("roles")=$G(CONF("mioide","roles"),"developer,admin")
	D ADDM^MIOROUTE("GET","/mioide","HOME^MIOIDER",.META)
	D ADDM^MIOROUTE("GET","/mioide/api/routines","APIRTN^MIOIDER",.META)
	D ADDM^MIOROUTE("GET","/mioide/api/routines/:name/source","APILOAD^MIOIDER",.META)
	D ADDM^MIOROUTE("PUT","/mioide/api/routines/:name/source","APISAVE^MIOIDER",.META)
	D ADDM^MIOROUTE("POST","/mioide/api/routines/:name/compile","APICOMP^MIOIDER",.META)
	D ADDM^MIOROUTE("POST","/mioide/api/routines/:name/run","APIRUN^MIOIDER",.META)
	D ADDM^MIOROUTE("GET","/mioide/api/search","APISEARCH^MIOIDER",.META)
	D ADDM^MIOROUTE("GET","/mioide/api/snippets","APISNIP^MIOIDER",.META)
	Q
	;
HOME(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D INIT^MIOIDE(.CONF)
	D BUILDHOME^MIOIDED(.CONF,.REQ,.CTX,.TCTX)
	D RENDER(.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR^MIOHTTP(.DEV,.CONF,500,"template_error",$G(ERR("error")),$G(CTX("request_id")),.CTX) Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
APIRTN(DEV,CONF,REQ,CTX)
	N OUT,RTNS,Q,I,CNT
	D INIT^MIOIDE(.CONF)
	S Q=$G(REQ("query","q"))
	D LISTRTN^MIOIDED(.CONF,Q,.RTNS)
	S OUT("ok")=1
	S OUT("query")=Q
	S I=0,CNT=0
	F  S I=$O(RTNS(I)) Q:'I  M OUT("routines",I)=RTNS(I) S CNT=CNT+1
	S OUT("count")=CNT
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$G(CTX("request_id")),.CTX)
	Q
	;
APILOAD(DEV,CONF,REQ,CTX)
	N RTN,ERR,OUT,OK,SRC
	D INIT^MIOIDE(.CONF)
	S RTN=$G(REQ("params","name"))
	S OK=$$LOADSRC^MIOIDED(RTN,.CONF,.SRC,.ERR)
	I 'OK D RESPERR^MIOHTTP(.DEV,.CONF,$S($G(ERR("error"))="not_found":404,1:400),$G(ERR("error"),"load_failed"),"",$G(CTX("request_id")),.CTX) Q
	S OUT("ok")=1
	S OUT("name")=RTN
	S OUT("source")=SRC
	I $G(ERR("truncated")) S OUT("truncated")=1
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$G(CTX("request_id")),.CTX)
	Q
	;
APISAVE(DEV,CONF,REQ,CTX)
	N RTN,ERR,SIZE,OUT
	D INIT^MIOIDE(.CONF)
	S RTN=$G(REQ("params","name"))
	I '$G(CONF("mioide","save","enabled")) D RESPERR^MIOHTTP(.DEV,.CONF,403,"save_disabled","",$G(CTX("request_id")),.CTX) Q
	I '$$WRITEREQ^MIOIDED(RTN,.REQ,.CONF,.ERR,.SIZE) D RESPERR^MIOHTTP(.DEV,.CONF,400,$G(ERR("error"),"save_failed"),"",$G(CTX("request_id")),.CTX) Q
	S OUT("ok")=1
	S OUT("name")=RTN
	S OUT("bytes")=SIZE
	S OUT("status")="saved"
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$G(CTX("request_id")),.CTX)
	Q
	;
APICOMP(DEV,CONF,REQ,CTX)
	N RTN,RES,OK,SC
	D INIT^MIOIDE(.CONF)
	S RTN=$G(REQ("params","name"))
	S OK=$$COMPILE^MIOIDED(RTN,.CONF,.RES)
	S SC=$S(OK:200,$G(RES("error"))="not_found":404,$G(RES("error"))="compile_disabled":403,1:400)
	D RESPJSONX^MIOHTTP(.DEV,.CONF,SC,.RES,$G(CTX("request_id")),.CTX)
	Q
	;
APIRUN(DEV,CONF,REQ,CTX)
	N RTN,ENTRY,RES,OK,SC
	D INIT^MIOIDE(.CONF)
	S RTN=$G(REQ("params","name"))
	S ENTRY=$G(REQ("query","entry"))
	S OK=$$RUN^MIOIDED(RTN,ENTRY,.CONF,.RES)
	S SC=$S(OK:200,$G(RES("error"))="run_disabled":403,$G(RES("error"))="run_not_allowed":403,1:400)
	D RESPJSONX^MIOHTTP(.DEV,.CONF,SC,.RES,$G(CTX("request_id")),.CTX)
	Q
	;
APISEARCH(DEV,CONF,REQ,CTX)
	N OUT,RES,Q,LIM,I,CNT
	D INIT^MIOIDE(.CONF)
	S Q=$G(REQ("query","q"))
	S LIM=+$G(REQ("query","limit")) I LIM<1 S LIM=+$G(CONF("mioide","search","limit"),60)
	D SEARCH^MIOIDED(.CONF,Q,LIM,.RES)
	S OUT("ok")=1
	S OUT("query")=Q
	S I=0,CNT=0
	F  S I=$O(RES(I)) Q:'I  M OUT("results",I)=RES(I) S CNT=CNT+1
	S OUT("count")=CNT
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$G(CTX("request_id")),.CTX)
	Q
	;
APISNIP(DEV,CONF,REQ,CTX)
	N TCTX,OUT,I,CNT
	D INIT^MIOIDE(.CONF)
	D SNIPS^MIOIDED(.TCTX)
	S OUT("ok")=1
	S I=0,CNT=0
	F  S I=$O(TCTX("snippets",I)) Q:'I  M OUT("snippets",I)=TCTX("snippets",I) S CNT=CNT+1
	S OUT("count")=CNT
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$G(CTX("request_id")),.CTX)
	Q
	;
RENDER(CONF,TCTX,OUT,ERR)
	K ERR
	D RENDERPAGE^MIOTPL("pages/mioide_home.html","layouts/mioide_app.html",.CONF,.TCTX,.OUT,.ERR)
	Q
	;
RESPHTML(DEV,CONF,CTX,OUT)
	N HEAD
	S HEAD("Content-Type")="text/html; charset=utf-8"
	D RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,$G(OUT),$G(CTX("request_id")),.CTX)
	Q
	;
