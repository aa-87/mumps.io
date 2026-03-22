MIOIDER ; MIOIDE routes, handlers, and MIOTPL template rendering
	Q
	;
REG(CONF)
	N META,METAWS
	K META,METAWS
	S META("authRequired")=+$G(CONF("mioide","authRequired"),1)
	S META("roles")=$G(CONF("mioide","roles"),"developer,admin")
	M METAWS=META
	S METAWS("wsPersistent")=1
	D ADDM^MIOROUTE("GET","/mioide","HOME^MIOIDER",.META)
	D ADDM^MIOROUTE("GET","/mioide/api/routines","APIRTN^MIOIDER",.META)
	D ADDM^MIOROUTE("GET","/mioide/api/routines/:name/source","APILOAD^MIOIDER",.META)
	D ADDM^MIOROUTE("PUT","/mioide/api/routines/:name/source","APISAVE^MIOIDER",.META)
	D ADDM^MIOROUTE("POST","/mioide/api/routines/:name/compile","APICOMP^MIOIDER",.META)
	D ADDM^MIOROUTE("POST","/mioide/api/routines/:name/run","APIRUN^MIOIDER",.META)
	D ADDM^MIOROUTE("GET","/mioide/api/search","APISEARCH^MIOIDER",.META)
	D ADDM^MIOROUTE("GET","/mioide/api/snippets","APISNIP^MIOIDER",.META)
	D ADDM^MIOROUTE("POST","/mioide/api/debug/sessions","DBGSTART^MIOIDER",.META)
	D ADDM^MIOROUTE("GET","/mioide/api/debug/sessions/:sid","DBGSNAP^MIOIDER",.META)
	D ADDM^MIOROUTE("WS","/mioide/ws/debug/:sid","WSDBG^MIOIDER",.METAWS)
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
	N RTN,TXT,ERR,OUT
	D INIT^MIOIDE(.CONF)
	S RTN=$G(REQ("params","name"))
	D GETSRCTXT^MIOIDED(RTN,.CONF,1048576,.TXT,.ERR)
	I $D(ERR) D RESPERR^MIOHTTP(.DEV,.CONF,$S($G(ERR("error"))="not_found":404,1:400),$G(ERR("error"),"load_failed"),"",$G(CTX("request_id")),.CTX) Q
	S OUT("ok")=1,OUT("name")=RTN,OUT("source")=TXT
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
APIDBGST(DEV,CONF,REQ,CTX)
	D DBGSTART(.DEV,.CONF,.REQ,.CTX)
	Q
	;
APIDBGSN(DEV,CONF,REQ,CTX)
	D DBGSNAP(.DEV,.CONF,.REQ,.CTX)
	Q
	;
DBGSTART(DEV,CONF,REQ,CTX)
	N RTN,ENTRY,CLIENT,RES,SC
	D INIT^MIOIDE(.CONF)
	S RTN=$G(REQ("query","routine"))
	I RTN="" S RTN=$G(REQ("body","routine"))
	S ENTRY=$G(REQ("query","entry")) I ENTRY="" S ENTRY=$G(REQ("body","entry"))
	S CLIENT=$G(REQ("query","client")) I CLIENT="" S CLIENT=$G(REQ("body","client"))
	I CLIENT="" S CLIENT="mioide"
	S SC=$S($$START^MIOIDEDBG(.CONF,RTN,ENTRY,CLIENT,.RES):200,$G(RES("error"))="not_found":404,$G(RES("error"))="debug_disabled":403,1:400)
	D RESPJSONX^MIOHTTP(.DEV,.CONF,SC,.RES,$G(CTX("request_id")),.CTX)
	Q
	;
DBGSNAP(DEV,CONF,REQ,CTX)
	N SID,RES,SC
	D INIT^MIOIDE(.CONF)
	S SID=$G(REQ("params","sid"))
	S SC=$S($$SNAP^MIOIDEDBG(SID,.CONF,.RES):200,1:404)
	D RESPJSONX^MIOHTTP(.DEV,.CONF,SC,.RES,$G(CTX("request_id")),.CTX)
	Q
	;
WSDBG(DEV,CONF,REQ,CTX)
	D INIT^MIOIDE(.CONF)
	D WS^MIOIDEDBG(.DEV,.CONF,.REQ,.CTX)
	Q
	;
RENDER(CONF,TCTX,OUT,ERR)
	K ERR
	D INIT^MIOIDE(.CONF)
	D RENDERPAGE^MIOTPL("pages/mioide_home.html","layouts/mioide_app.html",.CONF,.TCTX,.OUT,.ERR)
	Q
	;
RESPHTML(DEV,CONF,CTX,OUT)
	N HEAD
	S HEAD("Content-Type")="text/html; charset=utf-8"
	D RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,$G(OUT),$G(CTX("request_id")),.CTX)
	Q
	;
	;