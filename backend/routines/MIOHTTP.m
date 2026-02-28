MIOHTTP ; HTTP request parsing + streaming body storage (MAXSTRING-safe).;
;
; Purpose
; Parse HTTP/1.1 request lines, headers, and bodies.;
; Store request bodies in a MAXSTRING-safe way.;
;
; Goals
; - Avoid MAXSTRING errors.;
; - Be fast for small bodies.;
; - Be safe for large bodies.;
; - Support chunked transfer encoding.;
;
; Storage
; - Small bodies are stored as REQ("body") (scalar).;
; - Large bodies are stored as chunks in ^TMP($J,"MIOHTTP","BODY",REQ("id"),n).;
;
; Config keys (all optional)
; CONF("server","limits","maxRequestLineBytes")   default 8192
; CONF("server","limits","maxHeaderBytes")        default 65536
; CONF("server","limits","maxHeaderCount")        default 80
; CONF("server","limits","maxBodyBytes")          default 10485760
; CONF("server","limits","maxBodyScalarBytes")    default 262144
; CONF("server","http","readBodyChunkBytes")      default 65536
; CONF("server","http","supportChunkedRequest")   default 1
; CONF("server","timeouts","readHeaderMs")        default 2   (seconds)
; CONF("server","timeouts","readBodyMs")          default 3   (seconds)
;
; Public entry points
; - PARSE(DEV,CONF,REQ,ERR)
; - READLINE(DEV,TO,OUT,ERR)
; - READFIX(DEV,N,TO,OUT,ERR)
; - PARSEREQLINE(L,REQ,ERR)
; - PARSEQRY(P,REQ)
; - READHDRS(DEV,CONF,REQ,ERR)
; - READCHUNKED(DEV,CONF,REQ,ERR)
; - BODYOPEN(REQ,CUR)
; - BODYNEXT(REQ,CUR,CH)
; - BODYLEN(REQ)
; - BODYFREE(REQ)
; - STATUS4ERR(ERR)
; - RESPJSON / RESP / RESPX / RESPJSONX
;
; Notes
; - This routine does not assume a persistent connection.;
; - Errors should include routine name.;
;
	; Generated V1-02 (YottaDB/GT.M)
	;
	;
; Entry point
PARSE(DEV,CONF,REQ,ERR)
	KILL REQ,ERR
	SET REQ("id")=$GET(REQ("id"))
	IF REQ("id")="" SET REQ("id")=$TR($ZH,",")
	NEW TOH SET TOH=$GET(CONF("server","timeouts","readHeaderMs"),2)
	NEW LINE DO READLINE(.DEV,TOH,.LINE,.ERR) IF $DATA(ERR) QUIT 0
	IF LINE="" DO  QUIT 0
	. SET ERR("error")="client_closed",ERR("routine")="MIOHTTP"
	IF $LENGTH(LINE)>$GET(CONF("server","limits","maxRequestLineBytes"),8192) DO  QUIT 0
	. SET ERR("error")="request_line_too_large",ERR("routine")="MIOHTTP"
	DO PARSEREQLINE(LINE,.REQ,.ERR) IF $DATA(ERR) DO  QUIT 0
	. SET ERR("routine")="MIOHTTP"
	DO READHDRS(.DEV,.CONF,.REQ,.ERR) IF $DATA(ERR) DO  QUIT 0
	. SET ERR("routine")="MIOHTTP"
	;
	; Body (streaming)
	NEW CL SET CL=$GET(REQ("hdr","content-length"))
	NEW TE SET TE=$GET(REQ("hdr","transfer-encoding"))
	IF TE='"" DO
	. NEW LOTE SET LOTE=$$LOW(TE)
	. IF LOTE["chunked" DO  QUIT
	. . IF '$GET(CONF("server","http","supportChunkedRequest"),1) DO  QUIT
	. . . SET ERR("error")="chunked_not_supported",ERR("routine")="MIOHTTP"
	. . DO READCHUNKED(.DEV,.CONF,.REQ,.ERR)
	. ELSE  DO
	. . ; Unknown transfer-encoding
	. . SET ERR("error")="unsupported_transfer_encoding",ERR("routine")="MIOHTTP"
	ELSE  IF CL='"" DO
	. IF CL'?1.N DO  QUIT
	. . SET ERR("error")="invalid_content_length",ERR("routine")="MIOHTTP"
	. NEW MAXB SET MAXB=$GET(CONF("server","limits","maxBodyBytes"),10485760)
	. IF CL>MAXB DO  QUIT
	. . SET ERR("error")="payload_too_large",ERR("routine")="MIOHTTP"
	. NEW TOB SET TOB=$GET(CONF("server","timeouts","readBodyMs"),3)
	. DO READLEN(.DEV,.CONF,.REQ,CL,TOB,.ERR)
	QUIT:$DATA(ERR) 0
	QUIT 1
	;
; Entry point
READLINE(DEV,TO,OUT,ERR)
	NEW X
	DO READLN^MIOSOCK(DEV,TO,.X)
	IF '$TEST DO  QUIT
	. SET ERR("error")="read_timeout",ERR("routine")="MIOHTTP"
	SET OUT=X
	QUIT
	;
; Entry point
READFIX(DEV,N,TO,OUT,ERR)
	NEW X DO READN^MIOSOCK(DEV,N,TO,.X)
	IF '$TEST DO  QUIT
	. SET ERR("error")="read_timeout",ERR("routine")="MIOHTTP"
	IF $LENGTH(X)'=N DO  QUIT
	. SET ERR("error")="short_read",ERR("routine")="MIOHTTP"
	SET OUT=X
	QUIT
	;
; Entry point
PARSEREQLINE(L,REQ,ERR)
	NEW M,P,V
	SET M=$PIECE(L," ",1),P=$PIECE(L," ",2),V=$PIECE(L," ",3)
	IF M=""!(P="")!(V="") SET ERR("error")="bad_request_line" QUIT
	SET REQ("method")=M
	SET REQ("rawpath")=P
	SET REQ("httpver")=$S(V[$C(13,10):$P(V,$C(13,10)),1:V)
	SET REQ("path")=$PIECE(P,"?",1)
	DO PARSEQRY(P,.REQ)
	QUIT
	;
; Entry point
PARSEQRY(P,REQ)
	NEW Q SET Q=$PIECE(P,"?",2,999)
	IF Q="" QUIT
	NEW I,PAIR,K,V
	FOR I=1:1:$LENGTH(Q,"&") DO
	. SET PAIR=$PIECE(Q,"&",I)
	. SET K=$$URLDEC^MIOROUTE($PIECE(PAIR,"=",1))
	. SET V=$$URLDEC^MIOROUTE($PIECE(PAIR,"=",2,999))
	. IF K='"" SET REQ("query",K)=V
	QUIT
	;
; Entry point
READHDRS(DEV,CONF,REQ,ERR)
	NEW MAXC,MAXB,COUNT,BYTES,LINE,TOH
	SET MAXC=$GET(CONF("server","limits","maxHeaderCount"),80)
	SET MAXB=$GET(CONF("server","limits","maxHeaderBytes"),65536)
	SET COUNT=0,BYTES=0
	SET TOH=$GET(CONF("server","timeouts","readHeaderMs"),2)
	FOR  DO  QUIT:LINE=""
	. DO READLINE(.DEV,TOH,.LINE,.ERR) IF $DATA(ERR) QUIT
	. SET BYTES=BYTES+$LENGTH(LINE)+2
	. IF BYTES>MAXB DO  QUIT
	. . SET ERR("error")="headers_too_large",ERR("routine")="MIOHTTP"
	. IF LINE="" QUIT
	. SET COUNT=COUNT+1 IF COUNT>MAXC DO  QUIT
	. . SET ERR("error")="too_many_headers",ERR("routine")="MIOHTTP"
	. ; Reject obs-fold / folding
	. IF LINE[$CHAR(9)!(LINE["  ") DO  QUIT
	. . SET ERR("error")="header_folding_rejected",ERR("routine")="MIOHTTP"
	. NEW N,V SET N=$$LOW($PIECE(LINE,":",1)),V=$$TRIM($PIECE(LINE,":",2,999))
	. IF N='"" SET REQ("hdr",N)=V
	QUIT
	;
; Read fixed-length body into scalar or chunk store.;
; Internal.;
READLEN(DEV,CONF,REQ,CL,TOB,ERR)
	NEW MAXB SET MAXB=$GET(CONF("server","limits","maxBodyBytes"),10485760)
	NEW MAXS SET MAXS=$GET(CONF("server","limits","maxBodyScalarBytes"),262144)
	NEW CHSZ SET CHSZ=$GET(CONF("server","http","readBodyChunkBytes"),65536)
	IF CHSZ<1024 SET CHSZ=1024
	IF CHSZ>262144 SET CHSZ=262144
	;
	DO BODYINIT(.REQ,.CONF,CL)
	IF $DATA(ERR) QUIT
	;
	; Fast path: scalar + single read.;
	IF $GET(REQ("body","mode"))="scalar",CL'>MAXS DO  QUIT
	. NEW B DO READFIX(.DEV,CL,TOB,.B,.ERR) IF $DATA(ERR) QUIT
	. SET REQ("body")=B,REQ("body","len")=CL
	;
	NEW REM SET REM=CL
	FOR  QUIT:REM'>0  DO  QUIT:$DATA(ERR)
	. NEW N SET N=$SELECT(REM>CHSZ:CHSZ,1:REM)
	. NEW CH DO READFIX(.DEV,N,TOB,.CH,.ERR) IF $DATA(ERR) QUIT
	. DO BODYAPPEND(.REQ,.CONF,.CH,.ERR) IF $DATA(ERR) QUIT
	. SET REM=REM-N
	. IF $GET(REQ("body","len"))>MAXB DO  QUIT
	. . SET ERR("error")="payload_too_large",ERR("routine")="MIOHTTP"
	QUIT
	;
; Entry point
; Chunked request bodies, stored MAXSTRING-safe.;
READCHUNKED(DEV,CONF,REQ,ERR)
	NEW MAXB SET MAXB=$GET(CONF("server","limits","maxBodyBytes"),10485760)
	NEW TOB SET TOB=$GET(CONF("server","timeouts","readBodyMs"),3)
	DO BODYINIT(.REQ,.CONF,"")
	IF $DATA(ERR) QUIT
	FOR  DO  QUIT:$DATA(ERR)
	. NEW LINE DO READLINE(.DEV,TOB,.LINE,.ERR) IF $DATA(ERR) QUIT
	. ; chunk-size line may include extensions after ';'
	. NEW HEX SET HEX=$$TRIM($PIECE(LINE,";",1))
	. IF HEX="" DO  QUIT
	. . SET ERR("error")="bad_chunk_size",ERR("routine")="MIOHTTP"
	. NEW SZ SET SZ=$$HEX2DEC^MIOUTIL(HEX)
	. IF SZ<0 DO  QUIT
	. . SET ERR("error")="bad_chunk_size",ERR("routine")="MIOHTTP"
	. IF SZ=0 DO  QUIT
	. . ; trailer headers until blank line
	. . FOR  DO  QUIT:$DATA(ERR)
	. . . DO READLINE(.DEV,TOB,.LINE,.ERR) IF $DATA(ERR) QUIT
	. . . IF LINE="" QUIT
	. . SET REQ("body","done")=1
	. NEW CH DO READFIX(.DEV,SZ,TOB,.CH,.ERR) IF $DATA(ERR) QUIT
	. NEW CRLF DO READFIX(.DEV,2,TOB,.CRLF,.ERR) IF $DATA(ERR) QUIT
	. IF CRLF'=$CHAR(13,10) DO  QUIT
	. . SET ERR("error")="bad_chunk_ending",ERR("routine")="MIOHTTP"
	. DO BODYAPPEND(.REQ,.CONF,.CH,.ERR) IF $DATA(ERR) QUIT
	. IF $GET(REQ("body","len"))>MAXB DO  QUIT
	. . SET ERR("error")="payload_too_large",ERR("routine")="MIOHTTP"
	QUIT
	;
; Initialize body storage.;
; EXPECTLEN may be numeric or "".;
BODYINIT(REQ,CONF,EXPECTLEN)
	; Clean prior body storage if reused.;
	DO BODYFREE(.REQ)
	KILL REQ("body")
	KILL REQ("body","mode"),REQ("body","ref"),REQ("body","n"),REQ("body","len"),REQ("body","done")
	SET REQ("body","len")=0
	NEW MAXS SET MAXS=$GET(CONF("server","limits","maxBodyScalarBytes"),262144)
	;
	; If expected is known and small, prefer scalar.;
	IF EXPECTLEN='"",EXPECTLEN>0,EXPECTLEN>MAXS DO
	. SET REQ("body","mode")="global"
	ELSE  IF EXPECTLEN='"",EXPECTLEN>0 DO
	. SET REQ("body","mode")="scalar"
	ELSE  DO
	. ; Unknown length (chunked). Start scalar and upgrade when needed.;
	. SET REQ("body","mode")="scalar"
	;
	IF REQ("body","mode")="global" DO
	. NEW RID SET RID=$GET(REQ("id")) IF RID="" SET RID=$TR($ZH,",")
	. SET REQ("id")=RID
	. SET REQ("body","ref")=$NAME(^TMP($J,"MIOHTTP","BODY",RID))
	. KILL @REQ("body","ref")
	. SET REQ("body","n")=0
	QUIT
	;
; Append CH to body storage. Upgrades scalar->global if needed.;
BODYAPPEND(REQ,CONF,CH,ERR)
	NEW MODE SET MODE=$GET(REQ("body","mode"),"scalar")
	NEW LCH SET LCH=$LENGTH(CH)
	NEW NEWLEN SET NEWLEN=$GET(REQ("body","len"))+LCH
	SET REQ("body","len")=NEWLEN
	IF MODE="scalar" DO
	. NEW MAXS SET MAXS=$GET(CONF("server","limits","maxBodyScalarBytes"),262144)
	. ; Upgrade if adding would exceed threshold.;
	. IF NEWLEN>MAXS DO
	. . DO BODYUP(.REQ,.CONF)
	. . SET MODE=$GET(REQ("body","mode"))
	. IF MODE="scalar" DO
	. . SET REQ("body")=$GET(REQ("body"))_CH
	. ELSE  DO
	. . DO BODYAPPG(.REQ,CH)
	ELSE  DO BODYAPPG(.REQ,CH)
	QUIT
	;
; Upgrade scalar body to global chunks.;
BODYUP(REQ,CONF)
	NEW TOT SET TOT=+$GET(REQ("body","len"))
	NEW B SET B=$GET(REQ("body"))
	DO BODYINIT(.REQ,.CONF,TOT)
	; BODYINIT chose global because EXPECTLEN > MAXS.;
	IF $GET(REQ("body","mode"))'="global" DO
	. ; Force global.;
	. NEW RID SET RID=$GET(REQ("id")) IF RID="" SET RID=$TR($ZH,",")
	. SET REQ("id")=RID
	. SET REQ("body","mode")="global"
	. SET REQ("body","ref")=$NAME(^TMP($J,"MIOHTTP","BODY",RID))
	. KILL @REQ("body","ref")
	. SET REQ("body","n")=0
	; Move existing scalar body as first chunk.;
	IF B='"" DO BODYAPPG(.REQ,B)
	; Restore total length (BODYINIT resets len).;
	SET REQ("body","len")=TOT
	KILL REQ("body")
	QUIT
	;
; Append to global chunk store.;
BODYAPPG(REQ,CH)
	NEW REF SET REF=$GET(REQ("body","ref"))
	IF REF="" QUIT
	NEW N SET N=$GET(REQ("body","n"))+1
	SET REQ("body","n")=N
	SET @REF@(N)=CH
	QUIT
	;
; Entry point
; Initialize CUR for iteration.;
BODYOPEN(REQ,CUR)
	SET CUR=0
	QUIT
	;
; Entry point
; Return next chunk in CH. CUR is updated.;
; Returns 1 if a chunk is returned, else 0.;
BODYNEXT(REQ,CUR,CH)
	SET CH=""
	NEW MODE SET MODE=$GET(REQ("body","mode"))
	IF MODE="" QUIT 0
	IF MODE="scalar" DO  QUIT $SELECT(CH='"":1,1:0)
	. IF CUR>0 SET CH="" QUIT
	. SET CUR=1
	. SET CH=$GET(REQ("body"))
	IF MODE="global" DO
	. NEW REF SET REF=$GET(REQ("body","ref"))
	. IF REF="" SET CH="" QUIT
	. SET CUR=CUR+1
	. SET CH=$GET(@REF@(CUR))
	QUIT $SELECT(CH='"":1,1:0)
	;
; Entry point
BODYLEN(REQ)
	QUIT +$GET(REQ("body","len"))
	;
; Entry point
; Free global storage for this request.;
BODYFREE(REQ)
	IF $GET(REQ("body","mode"))="global" DO
	. NEW REF SET REF=$GET(REQ("body","ref"))
	. IF REF='"" KILL @REF
	KILL REQ("body","ref"),REQ("body","n"),REQ("body","mode"),REQ("body","len"),REQ("body","done")
	QUIT
	;
; Entry point
; Map parse errors to HTTP statuses.;
STATUS4ERR(ERR)
	NEW E SET E=$GET(ERR("error"))
	QUIT $SELECT(E="read_timeout":408,E="request_line_too_large":414,E="headers_too_large":431,E="too_many_headers":431,E="payload_too_large":413,E="chunked_not_supported":400,E="unsupported_transfer_encoding":501,E="invalid_content_length":400,E="bad_request_line":400,E="short_read":400,E="bad_chunk_size":400,E="bad_chunk_ending":400,1:400)
	;
; --- Responses ---
	;
; Entry point
RESPJSON(DEV,CONF,STATUS,OBJ,REQID)
	NEW BODY,HEAD
	SET BODY=$$EN^MIOJSON1(.OBJ)
	SET HEAD("Content-Type")="application/json"
	IF '$G(STATUS) SET STATUS=200
	IF '$G(REQID) SET REQID=$TR($ZH,",")
	DO RESP(.DEV,.CONF,STATUS,.HEAD,BODY,REQID)
	QUIT
	;
; Entry point
RESP(DEV,CONF,STATUS,HEAD,BODY,REQID)
	NEW HLINE SET HLINE="HTTP/1.1 "_STATUS_" "_$$STATUSMSG(STATUS)_$CHAR(13,10)
	DO WRITE^MIOSOCK(DEV,HLINE)
	NEW DH MERGE DH=CONF("server","http","defaultResponseHeaders")
	NEW K SET K=""
	FOR  SET K=$ORDER(DH(K)) QUIT:K=""  SET HEAD(K)=DH(K)
	IF REQID='"" SET HEAD("X-Request-Id")=REQID
	SET HEAD("Content-Length")=$LENGTH(BODY)
	IF '$DATA(HEAD("Connection")) SET HEAD("Connection")="keep-alive"
	FOR  SET K=$ORDER(HEAD(K)) QUIT:K=""  DO WRITE^MIOSOCK(DEV,K_": "_HEAD(K)_$CHAR(13,10))
	DO WRITE^MIOSOCK(DEV,$CHAR(13,10))
	DO WRITE^MIOSOCK(DEV,BODY)
	QUIT
	;
; Entry point
STATUSMSG(S)
	QUIT $SELECT(S=200:"OK",S=101:"Switching Protocols",S=400:"Bad Request",S=401:"Unauthorized",S=404:"Not Found",S=405:"Method Not Allowed",S=408:"Request Timeout",S=413:"Payload Too Large",S=414:"URI Too Long",S=431:"Request Header Fields Too Large",S=500:"Internal Server Error",S=501:"Not Implemented",1:"")
	;
; Entry point
LOW(S) QUIT $ZCONVERT(S,"L")
	;
; Entry point
TRIM(S)
	FOR  QUIT:$EXTRACT(S,1)'=" "  SET S=$EXTRACT(S,2,$LENGTH(S))
	FOR  QUIT:$EXTRACT(S,$LENGTH(S))'=" "  SET S=$EXTRACT(S,1,$LENGTH(S)-1)
	QUIT S
	;
; Entry point
RESPX(DEV,CONF,STATUS,HEAD,BODY,REQID,CTX)
	IF $DATA(CTX) SET CTX("status")=STATUS
	DO RESP(DEV,.CONF,STATUS,.HEAD,BODY,REQID)
	QUIT
	;
; Entry point
RESPJSONX(DEV,CONF,STATUS,OBJ,REQID,CTX)
	IF $DATA(CTX) SET CTX("status")=STATUS
	DO RESPJSON(DEV,.CONF,STATUS,.OBJ,REQID)
	QUIT
	;