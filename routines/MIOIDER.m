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
	D ADDM^MIOROUTE("POST","/mioide/api/debug/sessions","APIDBGST^MIOIDER",.META)
	D ADDM^MIOROUTE("GET","/mioide/api/debug/sessions/:sid","APIDBGSN^MIOIDER",.META)
	D ADDM^MIOROUTE("POST","/mioide/api/debug/sessions/:sid/command","APIDBGCMD^MIOIDER",.META)
	D ADDM^MIOROUTE("GET","/mioide/api/debug/routines/:name/breakpoints","APIDBGBP^MIOIDER",.META)
	D ADDM^MIOROUTE("POST","/mioide/api/debug/routines/:name/breakpoints/:line/toggle","APIDBGBT^MIOIDER",.META)
	D ADDM^MIOROUTE("POST","/mioide/api/debug/sessions/:sid/watches","APIDBGWA^MIOIDER",.META)
	D ADDM^MIOROUTE("POST","/mioide/api/debug/sessions/:sid/watches/:idx/remove","APIDBGWR^MIOIDER",.META)
	D ADDM^MIOROUTE("POST","/mioide/api/debug/sessions/:sid/eval","APIDBGEV^MIOIDER",.META)
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

APIDBGST(DEV,CONF,REQ,CTX)
	N OBJ,ERR,RES,OK,SC
	D INIT^MIOIDE(.CONF)
	D READJSON(.REQ,.OBJ,.ERR)
	I $D(ERR) D RESPERR^MIOHTTP(.DEV,.CONF,400,$G(ERR("error"),"invalid_json"),"",$G(CTX("request_id")),.CTX) Q
	S OK=$$START^MIOIDBG($G(OBJ("routine")),$G(OBJ("entry")),.REQ,.CONF,.RES)
	S SC=$S(OK:200,$G(RES("error"))="debug_disabled":403,$G(RES("error"))="not_found":404,1:400)
	D RESPJSONX^MIOHTTP(.DEV,.CONF,SC,.RES,$G(CTX("request_id")),.CTX)
	Q
	;
APIDBGSN(DEV,CONF,REQ,CTX)
	N RES,OK,SC
	D INIT^MIOIDE(.CONF)
	S OK=$$SNAP^MIOIDBG($G(REQ("params","sid")),.CONF,.RES)
	S SC=$S(OK:200,$G(RES("error"))="session_not_found":404,1:400)
	D RESPJSONX^MIOHTTP(.DEV,.CONF,SC,.RES,$G(CTX("request_id")),.CTX)
	Q
	;
APIDBGCMD(DEV,CONF,REQ,CTX)
	N OBJ,ERR,RES,OK,SC
	D INIT^MIOIDE(.CONF)
	D READJSON(.REQ,.OBJ,.ERR)
	I $D(ERR) D RESPERR^MIOHTTP(.DEV,.CONF,400,$G(ERR("error"),"invalid_json"),"",$G(CTX("request_id")),.CTX) Q
	S OK=$$CMD^MIOIDBG($G(REQ("params","sid")),$G(OBJ("cmd")),.REQ,.CONF,.RES)
	S SC=$S(OK:200,$G(RES("error"))="session_not_found":404,1:400)
	D RESPJSONX^MIOHTTP(.DEV,.CONF,SC,.RES,$G(CTX("request_id")),.CTX)
	Q
	;
APIDBGBP(DEV,CONF,REQ,CTX)
	N OUT,I,CNT,BP
	D INIT^MIOIDE(.CONF)
	S OUT("ok")=1,OUT("routine")=$G(REQ("params","name"))
	D LISTBP^MIOIDBG($G(REQ("params","name")),.BP)
	S I=0,CNT=0
	F  S I=$O(BP(I)) Q:'I  M OUT("breakpoint",I)=BP(I) S CNT=CNT+1
	S OUT("count")=CNT
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$G(CTX("request_id")),.CTX)
	Q
	;
APIDBGBT(DEV,CONF,REQ,CTX)
	N RES,OK,SC
	D INIT^MIOIDE(.CONF)
	S OK=$$TOGBP^MIOIDBG($G(REQ("params","name")),$G(REQ("params","line")),.REQ,.CONF,.RES)
	S SC=$S(OK:200,1:400)
	D RESPJSONX^MIOHTTP(.DEV,.CONF,SC,.RES,$G(CTX("request_id")),.CTX)
	Q
	;
APIDBGWA(DEV,CONF,REQ,CTX)
	N OBJ,ERR,RES,OK,SC
	D INIT^MIOIDE(.CONF)
	D READJSON(.REQ,.OBJ,.ERR)
	I $D(ERR) D RESPERR^MIOHTTP(.DEV,.CONF,400,$G(ERR("error"),"invalid_json"),"",$G(CTX("request_id")),.CTX) Q
	S OK=$$ADDWATCH^MIOIDBG($G(REQ("params","sid")),$G(OBJ("expr")),.REQ,.CONF,.RES)
	S SC=$S(OK:200,$G(RES("error"))="session_not_found":404,1:400)
	D RESPJSONX^MIOHTTP(.DEV,.CONF,SC,.RES,$G(CTX("request_id")),.CTX)
	Q
	;
APIDBGWR(DEV,CONF,REQ,CTX)
	N RES,OK,SC
	D INIT^MIOIDE(.CONF)
	S OK=$$DELWATCH^MIOIDBG($G(REQ("params","sid")),$G(REQ("params","idx")),.REQ,.CONF,.RES)
	S SC=$S(OK:200,$G(RES("error"))="session_not_found":404,1:400)
	D RESPJSONX^MIOHTTP(.DEV,.CONF,SC,.RES,$G(CTX("request_id")),.CTX)
	Q
	;
APIDBGEV(DEV,CONF,REQ,CTX)
	N OBJ,ERR,RES,OK,SC
	D INIT^MIOIDE(.CONF)
	D READJSON(.REQ,.OBJ,.ERR)
	I $D(ERR) D RESPERR^MIOHTTP(.DEV,.CONF,400,$G(ERR("error"),"invalid_json"),"",$G(CTX("request_id")),.CTX) Q
	S OK=$$EVAL^MIOIDBG($G(REQ("params","sid")),$G(OBJ("expr")),.REQ,.CONF,.RES)
	S SC=$S(OK:200,$G(RES("error"))="session_not_found":404,1:400)
	D RESPJSONX^MIOHTTP(.DEV,.CONF,SC,.RES,$G(CTX("request_id")),.CTX)
	Q
	;
READJSON(REQ,OBJ,ERR)
	N RAW,CUR,CH
	K OBJ,ERR
	S RAW=""
	D BODYOPEN^MIOHTTP(.REQ,.CUR)
	F  Q:'$$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH)  S RAW=RAW_CH
	I RAW="" S ERR("error")="empty_body" Q
	D DECODE^MIOJSON(RAW,.OBJ,.ERR)
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
	I '$$WRITEREQ^MIOIDED(RTN,.REQ,.CONF,.ERR,.SIZE) D RESPERR^MIOHTTP(.DEV,.CONF,400,$G(ERR("error"),"save_failed"),"",$G(CTX("request_id")),.CTX) D PUBREQ^MIOIDEWS(.REQ,"save",RTN,"save_failed","Save failed",.ERR) Q
	S OUT("ok")=1
	S OUT("name")=RTN
	S OUT("bytes")=SIZE
	S OUT("status")="saved"
	D PUBREQ^MIOIDEWS(.REQ,"save",RTN,"saved","Routine saved",.OUT)
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$G(CTX("request_id")),.CTX)
	Q
	;
APICOMP(DEV,CONF,REQ,CTX)
	N RTN,RES,OK,SC
	D INIT^MIOIDE(.CONF)
	S RTN=$G(REQ("params","name"))
	S OK=$$COMPILE^MIOIDED(RTN,.CONF,.RES)
	D PUBREQ^MIOIDEWS(.REQ,"compile",RTN,$S(OK:"compiled",1:$G(RES("error"),"compile_failed")),$S(OK:"Routine compiled",1:"Compile failed"),.RES)
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
	D PUBREQ^MIOIDEWS(.REQ,"run",RTN,$S(OK:"completed",1:$G(RES("error"),"run_failed")),$S(OK:"Run completed",1:"Run failed"),.RES)
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