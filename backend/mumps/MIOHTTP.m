MIOHTTP ; HTTP request parser and response writer.;
; API STABILITY
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; Purpose
; HTTP request parser and response writer.;
;
; Responsibilities
; - Enforce request lifecycle.;
; - Keep work bounded.;
; - Fail safely.;
;
; Entry Points
; - PARSE
; - READLINE
; - READFIX
; - PARSEREQLINE
; - PARSEQRY
; - READHDRS
; - READCHUNKED
; - RESPJSON
; - RESP
; - STATUSMSG
; - LOW
; - TRIM
; - RESPX
; - RESPJSONX
;
; Notes
; Keep comments short.;
; Do not log secrets.;
;
	; Generated V1-01 (YottaDB)
	;
; Entry point
; See docs/routines for details.;
PARSE(DEV,CONF,REQ,ERR)
	KILL REQ,ERR
	NEW TOH S TOH=$GET(CONF("server","timeouts","readHeaderMs"),2)
	NEW LINE DO READLINE(.DEV,TOH,.LINE,.ERR) IF $DATA(ERR) QUIT 0
	IF LINE="" SET ERR("error")="client_closed" QUIT 0
	IF $LENGTH(LINE)>$GET(CONF("server","limits","maxRequestLineBytes"),8192) SET ERR("error")="request_line_too_large" QUIT 0
	DO PARSEREQLINE(LINE,.REQ,.ERR) IF $DATA(ERR) QUIT 0
	DO READHDRS(.DEV,.CONF,.REQ,.ERR) IF $DATA(ERR) QUIT 0
	NEW CL SET CL=$GET(REQ("hdr","content-length"))
	NEW TE SET TE=$GET(REQ("hdr","transfer-encoding"))
	IF TE'="",$$LOW(TE)["chunked" DO
	. IF '$GET(CONF("server","http","supportChunkedRequest"),1) SET ERR("error")="chunked_not_supported" QUIT
	. DO READCHUNKED(.DEV,.CONF,.REQ,.ERR)
	ELSE  IF CL'="" DO
	. NEW MAXB SET MAXB=$GET(CONF("server","limits","maxBodyBytes"),10485760)
	. IF CL>MAXB SET ERR("error")="payload_too_large" QUIT
	. NEW TOB S TOB=$GET(CONF("server","timeouts","readBodyMs"),3)
	. NEW B DO READFIX(.DEV,CL,TOB,.B,.ERR) IF $DATA(ERR) QUIT
	. SET REQ("body")=B
	QUIT:$DATA(ERR) 0
	QUIT 1
	;
; Entry point
; See docs/routines for details.;
READLINE(DEV,TO,OUT,ERR)
	NEW X
	I 1 DO READLN^MIOSOCK(DEV,TO,.X)
	IF '$TEST SET ERR("error")="read_timeout" QUIT
	SET OUT=X
	QUIT
	;
; Entry point
; See docs/routines for details.;
READFIX(DEV,N,TO,OUT,ERR)
	NEW X DO READN^MIOSOCK(DEV,N,TO,.X)
	IF '$TEST SET ERR("error")="read_timeout" QUIT
	IF $LENGTH(X)'=N SET ERR("error")="short_read" QUIT
	SET OUT=X
	QUIT
	;
; Entry point
; See docs/routines for details.;
PARSEREQLINE(L,REQ,ERR)
	NEW M,P,V
	SET M=$PIECE(L," ",1),P=$PIECE(L," ",2),V=$PIECE(L," ",3)
	IF M=""!(P="")!(V="") SET ERR("error")="bad_request_line" QUIT
	SET REQ("method")=M,REQ("rawpath")=P,REQ("httpver")=$S(V[$C(13,10):$P(V,$C(13,10)),1:V)
	SET REQ("path")=$PIECE(P,"?",1)
	DO PARSEQRY(P,.REQ)
	QUIT
	;
; Entry point
; See docs/routines for details.;
PARSEQRY(P,REQ)
	NEW Q SET Q=$PIECE(P,"?",2,999)
	IF Q="" QUIT
	NEW I,PAIR,K,V
	FOR I=1:1:$LENGTH(Q,"&") DO
	. SET PAIR=$PIECE(Q,"&",I)
	. SET K=$$URLDEC^MIOROUTE($PIECE(PAIR,"=",1))
	. SET V=$$URLDEC^MIOROUTE($PIECE(PAIR,"=",2,999))
	. IF K'="" SET REQ("query",K)=V
	QUIT
	;
; Entry point
; See docs/routines for details.;
READHDRS(DEV,CONF,REQ,ERR)
	NEW MAXC,MAXB,COUNT,BYTES,LINE,TOH
	SET MAXC=$GET(CONF("server","limits","maxHeaderCount"),80)
	SET MAXB=$GET(CONF("server","limits","maxHeaderBytes"),65536)
	SET COUNT=0,BYTES=0
	SET TOH=$GET(CONF("server","timeouts","readHeaderMs"),2)
	FOR  DO  QUIT:LINE=""
	. DO READLINE(.DEV,TOH,.LINE,.ERR) IF $DATA(ERR) QUIT
	. SET BYTES=BYTES+$LENGTH(LINE)+2
	. IF BYTES>MAXB SET ERR("error")="headers_too_large" QUIT
	. IF LINE="" QUIT
	. SET COUNT=COUNT+1 IF COUNT>MAXC SET ERR("error")="too_many_headers" QUIT
	. IF LINE[$CHAR(9)!(LINE["  ") SET ERR("error")="header_folding_rejected" QUIT
	. NEW N,V SET N=$$LOW($PIECE(LINE,":",1)),V=$$TRIM($PIECE(LINE,":",2,999))
	. IF N'="" SET REQ("hdr",N)=V
	QUIT
	;
; Entry point
; See docs/routines for details.;
READCHUNKED(DEV,CONF,REQ,ERR)
	NEW MAXB SET MAXB=$GET(CONF("server","limits","maxBodyBytes"),10485760)
	NEW TOB S TOB=$GET(CONF("server","timeouts","readBodyMs"),30000)
	NEW OUT SET OUT=""
	FOR  DO  QUIT:$DATA(ERR)
	. NEW LINE DO READLINE(.DEV,TOB,.LINE,.ERR) IF $DATA(ERR) QUIT
	. NEW SZ SET SZ=$$HEX2DEC^MIOUTIL($PIECE(LINE,";",1))
	. IF SZ=0 DO  QUIT
	. . FOR  QUIT:$DATA(ERR)  DO READLINE(.DEV,TOB,.LINE,.ERR) QUIT:LINE=""
	. . SET REQ("body")=OUT
	. NEW CH DO READFIX(.DEV,SZ,TOB,.CH,.ERR) IF $DATA(ERR) QUIT
	. NEW CRLF DO READFIX(.DEV,2,TOB,.CRLF,.ERR) IF $DATA(ERR) QUIT
	. SET OUT=OUT_CH
	. IF $LENGTH(OUT)>MAXB SET ERR("error")="payload_too_large" QUIT
	QUIT
	;
; Entry point
; See docs/routines for details.;
RESPJSON(DEV,CONF,STATUS,OBJ,REQID)
	NEW BODY,HEAD
	SET BODY=$$EN^MIOJSON1(.OBJ)
	SET HEAD("Content-Type")="application/json"
	DO RESP(.DEV,.CONF,STATUS,.HEAD,BODY,REQID)
	QUIT
	;
T1
	S DEV=0
	M CONF=^MIO("CONF")
	S STATUS=404
	S HEAD("Content-Type")="application/json"
	S BODY="{""error"":""not_found"",""request_id"":""ae53b3f2-3ec2-440d-1205-4eb25cc4b24b""}"
	S REQID="ae53b3f2-3ec2-440d-1205-4eb25cc4b24b"
	DO RESP(.DEV,.CONF,STATUS,.HEAD,BODY,REQID)
	Q
	;	
	;	
; Entry point
; See docs/routines for details.;
RESP(DEV,CONF,STATUS,HEAD,BODY,REQID)
	NEW HLINE SET HLINE="HTTP/1.1 "_STATUS_" "_$$STATUSMSG(STATUS)_$CHAR(13,10)
	DO WRITE^MIOSOCK(DEV,HLINE)
	NEW DH MERGE DH=CONF("server","http","defaultResponseHeaders")
	NEW K SET K=""
	FOR  SET K=$ORDER(DH(K)) QUIT:K=""  SET HEAD(K)=DH(K)
	IF REQID'="" SET HEAD("X-Request-Id")=REQID
	SET HEAD("Content-Length")=$LENGTH($G(BODY))
	IF '$DATA(HEAD("Connection")) SET HEAD("Connection")="keep-alive"
	FOR  SET K=$ORDER(HEAD(K)) QUIT:K=""  DO WRITE^MIOSOCK(DEV,K_": "_HEAD(K)_$CHAR(13,10))
	DO WRITE^MIOSOCK(DEV,$CHAR(13,10))
	DO WRITE^MIOSOCK(DEV,BODY)
	QUIT
	;
; Entry point
; See docs/routines for details.;
STATUSMSG(S)
	QUIT $SELECT(S=200:"OK",S=101:"Switching Protocols",S=400:"Bad Request",S=404:"Not Found",S=413:"Payload Too Large",S=500:"Internal Server Error",1:"")
	;
; Entry point
; See docs/routines for details.;
LOW(S) Q $ZCONVERT(S,"L")
	;NEW I,C,OUT SET OUT=""
	;FOR I=1:1:$LENGTH(S) DO
	;. SET C=$ASCII($EXTRACT(S,I))
	;. IF C>64,C<91 SET C=C+32
	;. SET OUT=OUT_$CHAR(C)
	;QUIT OUT
	;
; Entry point
; See docs/routines for details.;
TRIM(S)
	FOR  QUIT:$EXTRACT(S,1)'=" "  SET S=$EXTRACT(S,2,$LENGTH(S))
	QUIT S
	;
	;
; Entry point
; See docs/routines for details.;
RESPX(DEV,CONF,STATUS,HEAD,BODY,REQID,CTX)
	; Like RESP but records status in CTX (if passed by reference)
	IF $DATA(CTX) SET CTX("status")=STATUS
	DO RESP(DEV,.CONF,STATUS,.HEAD,BODY,REQID)
	QUIT
	;
; Entry point
; See docs/routines for details.;
RESPJSONX(DEV,CONF,STATUS,OBJ,REQID,CTX)
	; Like RESPJSON but records status in CTX
	IF $DATA(CTX) SET CTX("status")=STATUS
	DO RESPJSON(DEV,.CONF,STATUS,.OBJ,REQID)
	QUIT
	;