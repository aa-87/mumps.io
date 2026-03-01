MIOHTTP ; HTTP request parsing + streaming request bodies (MAXSTRING-safe)
;
; Entry points
;   PARSE(DEV,CONF,REQ,ERR)  -> 1 ok, 0 error (ERR populated)
;   BODYLEN(.REQ)
;   BODYOPEN(.REQ,.CUR)
;   BODYNEXT(.REQ,.CUR,.CH) -> 1 chunk, 0 done
;   BODYFREE(.REQ)
;   STATUS4ERR(.ERR)        -> HTTP status code
;   RESP/RESPJSON/RESPX/RESPJSONX
;
; Body storage
;   Scalar:
;     REQ("body")=string
;     REQ("body","mode")="scalar"
;     REQ("body","len")=N
;   Global (chunked / large):
;     REQ("body","mode")="global"
;     REQ("body","ref")=$NAME(^TMP($J,"MIOHTTP","BODY",REQID))
;     REQ("body","n")=chunkCount
;     REQ("body","len")=N
;     ^TMP(...,1)=chunk1, ^TMP(...,2)=chunk2, ...;
;
; ---------------------------------------------------------------------------
	;
PARSE(DEV,CONF,REQ,ERR)
	; Parse request line, headers, and body.;
	NEW RID SET RID=$GET(REQ("id"))
	KILL ERR
	KILL REQ
	IF RID'="" SET REQ("id")=RID
	IF $GET(REQ("id"))="" SET REQ("id")=$TR($ZH,",")_"-"_$J
	;
	NEW TOH SET TOH=$GET(CONF("server","timeouts","readHeaderMs"),2)
	NEW LINE
	DO READLINE(.DEV,TOH,.LINE,.ERR) IF $DATA(ERR) QUIT 0
	IF LINE="" DO  QUIT 0
	. SET ERR("routine")="MIOHTTP",ERR("error")="client_closed"
	IF $L(LINE)>$GET(CONF("server","limits","maxRequestLineBytes"),8192) DO  QUIT 0
	. SET ERR("routine")="MIOHTTP",ERR("error")="request_line_too_large"
	;
	DO PARSEREQLINE(LINE,.REQ,.ERR) IF $DATA(ERR) QUIT 0
	DO READHDRS(.DEV,.CONF,.REQ,.ERR) IF $DATA(ERR) QUIT 0
	;
	; Decide body framing
	NEW CL SET CL=$GET(REQ("hdr","content-length"))
	NEW TE SET TE=$GET(REQ("hdr","transfer-encoding"))
	;
	; Transfer-Encoding beats Content-Length
	IF TE'="" DO  QUIT:$DATA(ERR) 0  QUIT 1
	. IF '$$TEOK(TE) DO  QUIT
	. . SET ERR("routine")="MIOHTTP",ERR("error")="unsupported_transfer_encoding"
	. IF $$TEHAS(TE,"chunked") DO  QUIT
	. . IF '$GET(CONF("server","http","supportChunkedRequest"),1) DO  QUIT
	. . . SET ERR("routine")="MIOHTTP",ERR("error")="chunked_not_supported"
	. . DO READCHUNKED(.DEV,.CONF,.REQ,.ERR)
	. ; identity only => no framing, require Content-Length if body expected
	. IF $DATA(ERR) QUIT
	. IF CL'="" DO
	. . DO READCL(.DEV,.CONF,.REQ,CL,.ERR)
	. ELSE  DO
	. . SET REQ("body","mode")="none",REQ("body","len")=0
	;
	; No TE
	IF CL'="" DO  QUIT:$DATA(ERR) 0  QUIT 1
	. DO READCL(.DEV,.CONF,.REQ,CL,.ERR)
	;
	; No body
	SET REQ("body","mode")="none",REQ("body","len")=0
	QUIT 1
	;
; ---------------- read helpers ----------------
	;
READLINE(DEV,TO,OUT,ERR)
	; Read a CRLF-delimited line.;
	; IMPORTANT: file fixtures use DELIM=$C(13,10) and may need true M READ behavior
	; to correctly return empty lines (e.g. chunk terminators/trailers).;
	NEW X
	; File fixture path? (tests pass DEV as a filename like /tmp/t004_*.req)
	IF $GET(DEV)["/" DO  QUIT
	. NEW $ETRAP SET $ETRAP="SET $ECODE="""" SET OUT="""" SET ERR(""routine"")=""MIOHTTP"",ERR(""error"")=""short_read"" QUIT"
	. USE DEV
	. READ X:TO
	. IF '$TEST DO  QUIT
	. . SET ERR("routine")="MIOHTTP",ERR("error")="read_timeout"
	. ; Strip any CR chars (some devices can leave trailing CR)
	. SET OUT=$TR(X,$C(13))
	; Socket / normal device: delegate to MIOSOCK
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" SET OUT="""" SET ERR(""routine"")=""MIOHTTP"",ERR(""error"")=""short_read"" QUIT"
	DO READLN^MIOSOCK(DEV,TO,.X)
	IF '$TEST DO  QUIT
	. SET ERR("routine")="MIOHTTP",ERR("error")="read_timeout"
	SET OUT=$TR(X,$C(13))
	QUIT
	;
READFIX(DEV,N,TO,OUT,ERR)
	; Read exactly N bytes.;
	; For file fixtures (DEV is a pathname), do a raw READ#N with DELIM disabled.;
	NEW X
	IF $GET(DEV)["/" DO  QUIT
	. NEW $ETRAP SET $ETRAP="SET $ECODE="""" SET OUT="""" SET ERR(""routine"")=""MIOHTTP"",ERR(""error"")=""short_read"" QUIT"
	. USE DEV:(DELIM=$C(0))
	. READ X#N:TO
	. ; Restore HTTP delimiter for subsequent READLINE usage
	. USE DEV:(DELIM=$C(13,10))
	. IF '$TEST DO  QUIT
	. . SET ERR("routine")="MIOHTTP",ERR("error")="read_timeout"
	. IF $L(X)'=N DO  QUIT
	. . SET ERR("routine")="MIOHTTP",ERR("error")="short_read"
	. SET OUT=X
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" SET OUT="""" SET ERR(""routine"")=""MIOHTTP"",ERR(""error"")=""short_read"" QUIT"
	DO READN^MIOSOCK(DEV,N,TO,.X)
	IF '$TEST DO  QUIT
	. SET ERR("routine")="MIOHTTP",ERR("error")="read_timeout"
	IF $L(X)'=N DO  QUIT
	. SET ERR("routine")="MIOHTTP",ERR("error")="short_read"
	SET OUT=X
	QUIT
	;
PARSEREQLINE(L,REQ,ERR)
	NEW M,P,V
	SET M=$P(L," ",1),P=$P(L," ",2),V=$P(L," ",3)
	IF M=""!(P="")!(V="") DO  QUIT
	. SET ERR("routine")="MIOHTTP",ERR("error")="bad_request_line"
	SET REQ("method")=M
	SET REQ("rawpath")=P
	SET REQ("httpver")=V
	SET REQ("path")=$P(P,"?",1)
	DO PARSEQRY(P,.REQ)
	QUIT
	;
PARSEQRY(P,REQ)
	KILL REQ("query")
	NEW Q SET Q=$P(P,"?",2,999)
	IF Q="" QUIT
	NEW I,PAIR,K,V
	FOR I=1:1:$L(Q,"&") DO
	. SET PAIR=$P(Q,"&",I)
	. SET K=$$URLDECQ($P(PAIR,"=",1))
	. SET V=$$URLDECQ($P(PAIR,"=",2,999))
	. IF K'="" SET REQ("query",K)=V
	QUIT
	;
URLDECQ(S)
	; '+' => space, %HH => byte. Invalid sequences preserved.;
	NEW IN,OUT,I,C,HEX,D
	SET IN=$GET(S),OUT=""
	FOR I=1:1:$L(IN) DO
	. SET C=$E(IN,I)
	. IF C="+" SET OUT=OUT_" " QUIT
	. IF C'="%" SET OUT=OUT_C QUIT
	. SET HEX=$E(IN,I+1,I+2)
	. IF $L(HEX)'=2 SET OUT=OUT_C QUIT
	. SET D=$$HEX2DEC(HEX)
	. IF D<0 SET OUT=OUT_C QUIT
	. SET OUT=OUT_$C(D)
	. SET I=I+2
	QUIT OUT
	;
HEX2DEC(H)
	NEW A,B
	SET A=$$HEX1($E(H,1)),B=$$HEX1($E(H,2))
	IF A<0!(B<0) QUIT -1
	QUIT (A*16)+B
	;
HEX1(C)
	NEW U,P
	SET U=$ZCONVERT($GET(C),"U")
	SET P=$F("0123456789ABCDEF",U)
	QUIT $S(P=0:-1,1:P-2)
	;
HEXSTR2DEC(S)
	; Decode 1+ hex digits into decimal. Returns -1 on invalid.;
	NEW X SET X=$$TRIM($GET(S))
	IF X="" QUIT -1
	NEW I,C,V,N SET N=0
	FOR I=1:1:$L(X) DO
	. SET C=$E(X,I)
	. SET V=$$HEX1(C)
	. IF V<0 SET N=-1 QUIT
	. SET N=(N*16)+V
	IF N<0 QUIT -1
	QUIT N
	;
; ---------------- headers ----------------
	;
READHDRS(DEV,CONF,REQ,ERR)
	KILL REQ("hdr")
	NEW MAXC,MAXB,COUNT,BYTES,LINE,TOH
	SET MAXC=$GET(CONF("server","limits","maxHeaderCount"),80)
	SET MAXB=$GET(CONF("server","limits","maxHeaderBytes"),65536)
	SET COUNT=0,BYTES=0
	SET TOH=$GET(CONF("server","timeouts","readHeaderMs"),2)
	FOR  DO  QUIT:LINE=""  QUIT:$DATA(ERR)
	. DO READLINE(.DEV,TOH,.LINE,.ERR) IF $DATA(ERR) QUIT
	. IF LINE="" QUIT
	. SET BYTES=BYTES+$L(LINE)+2
	. IF BYTES>MAXB DO  QUIT
	. . SET ERR("routine")="MIOHTTP",ERR("error")="headers_too_large"
	. SET COUNT=COUNT+1
	. IF COUNT>MAXC DO  QUIT
	. . SET ERR("routine")="MIOHTTP",ERR("error")="too_many_headers"
	. IF $E(LINE,1)=" "!($E(LINE,1)=$C(9)) DO  QUIT
	. . SET ERR("routine")="MIOHTTP",ERR("error")="header_folding_rejected"
	. NEW N,V
	. SET N=$$LOW($P(LINE,":",1))
	. SET V=$$TRIM($P(LINE,":",2,999))
	. IF N'="" SET REQ("hdr",N)=V
	QUIT
	;
LOW(S) QUIT $ZCONVERT($GET(S),"L")
	;
TRIM(S)
	NEW X SET X=$GET(S)
	FOR  QUIT:X=""!($E(X,1)'=" ")  SET X=$E(X,2,$L(X))
	FOR  QUIT:X=""!($E(X,$L(X))'=" ")  SET X=$E(X,1,$L(X)-1)
	QUIT X
	;
; ---------------- Transfer-Encoding parsing ----------------
	;
TEOK(TE)
	; Allow only: chunked and/or identity (in any order). Reject gzip, deflate, etc.;
	NEW I,TOK,OK
	SET OK=1
	FOR I=1:1:$L(TE,",") DO
	. SET TOK=$$LOW($$TRIM($P(TE,",",I)))
	. IF TOK="" QUIT
	. IF TOK'="chunked",TOK'="identity" SET OK=0
	QUIT OK
	;
TEHAS(TE,NAME)
	NEW I,TOK,Q S Q=0
	FOR I=1:1:$L(TE,",") DO
	. SET TOK=$$LOW($$TRIM($P(TE,",",I)))
	. IF TOK=$$LOW(NAME) S Q=1 QUIT
	QUIT Q
	;
; ---------------- body: Content-Length ----------------
	;
READCL(DEV,CONF,REQ,CL,ERR)
	IF CL'?1N.N DO  QUIT
	. SET ERR("routine")="MIOHTTP",ERR("error")="invalid_content_length"
	NEW MAXB SET MAXB=$GET(CONF("server","limits","maxBodyBytes"),10485760)
	IF +CL>MAXB DO  QUIT
	. SET ERR("routine")="MIOHTTP",ERR("error")="payload_too_large"
	IF +CL'>0 SET REQ("body","mode")="none",REQ("body","len")=0 QUIT
	NEW TOB SET TOB=$GET(CONF("server","timeouts","readBodyMs"),3)
	DO READLEN(.DEV,.CONF,.REQ,+CL,TOB,.ERR)
	QUIT
	;
READLEN(DEV,CONF,REQ,CL,TOB,ERR)
	NEW MAXB SET MAXB=$GET(CONF("server","limits","maxBodyBytes"),10485760)
	NEW MAXS SET MAXS=$GET(CONF("server","limits","maxBodyScalarBytes"),262144)
	NEW CHSZ SET CHSZ=+$GET(CONF("server","http","readBodyChunkBytes"))
	IF CHSZ<1 SET CHSZ=$S(CL>MAXS:MAXS,1:65536)
	IF CHSZ<1 SET CHSZ=1
	IF CHSZ>262144 SET CHSZ=262144
	;
	DO BODYINIT(.REQ,.CONF,CL)
	IF $DATA(ERR) QUIT
	;
	NEW REM SET REM=CL
	FOR  QUIT:REM'>0  QUIT:$DATA(ERR)  DO
	. NEW N SET N=$S(REM>CHSZ:CHSZ,1:REM)
	. NEW CH
	. DO READFIX(.DEV,N,TOB,.CH,.ERR) IF $DATA(ERR) QUIT
	. DO BODYAPPEND(.REQ,.CONF,.CH,.ERR) IF $DATA(ERR) QUIT
	. SET REM=REM-N
	. IF $GET(REQ("body","len"))>MAXB DO
	. . SET ERR("routine")="MIOHTTP",ERR("error")="payload_too_large"
	QUIT
	;
; ---------------- body: chunked ----------------
	;
	;
READCHUNKED(DEV,CONF,REQ,ERR)
	; Read chunked transfer-encoding request body.;
	NEW MAXB SET MAXB=$GET(CONF("server","limits","maxBodyBytes"),10485760)
	NEW TOB SET TOB=$GET(CONF("server","timeouts","readBodyMs"),3)
	NEW DONE SET DONE=0
	DO BODYINIT(.REQ,.CONF,"")
	IF $DATA(ERR) QUIT
	FOR  QUIT:DONE  QUIT:$DATA(ERR)  DO
	. NEW LINE DO READLINE(.DEV,TOB,.LINE,.ERR) IF $DATA(ERR) QUIT
	. ; chunk-size line may include extensions after ';'
	. NEW HEX SET HEX=$$TRIM($PIECE(LINE,";",1))
	. IF HEX="" DO  QUIT
	. . SET ERR("error")="bad_chunk_size",ERR("routine")="MIOHTTP"
	. NEW SZ SET SZ=$$HEXSTR2DEC(HEX)
	. IF SZ<0 DO  QUIT
	. . SET ERR("error")="bad_chunk_size",ERR("routine")="MIOHTTP"
	. IF SZ=0 DO  QUIT
	. . ; trailer headers until blank line then stop
	. . NEW TLINE SET TLINE="x"
	. . FOR  DO  QUIT:$DATA(ERR)  QUIT:TLINE=""
	. . . DO READLINE(.DEV,TOB,.TLINE,.ERR) IF $DATA(ERR) QUIT
	. . SET DONE=1
	. NEW CH DO READFIX(.DEV,SZ,TOB,.CH,.ERR) IF $DATA(ERR) QUIT
	. ; consume chunk terminator using a line read. Under CRLF delim this returns "".;
	. NEW EOL DO READLINE(.DEV,TOB,.EOL,.ERR) IF $DATA(ERR) QUIT
	. IF EOL'="" DO  QUIT
	. . SET ERR("error")="bad_chunk_ending",ERR("routine")="MIOHTTP"
	. DO BODYAPPEND(.REQ,.CONF,.CH,.ERR) IF $DATA(ERR) QUIT
	. IF $GET(REQ("body","len"))>MAXB DO
	. . SET ERR("error")="payload_too_large",ERR("routine")="MIOHTTP"
	QUIT
	;
BODYINIT(REQ,CONF,EXPECTLEN)
	DO BODYFREE(.REQ)
	KILL REQ("body")
	KILL REQ("body","mode"),REQ("body","ref"),REQ("body","n"),REQ("body","len")
	SET REQ("body","len")=0
	NEW MAXS SET MAXS=$GET(CONF("server","limits","maxBodyScalarBytes"),262144)
	IF EXPECTLEN'="",(+EXPECTLEN>MAXS) SET REQ("body","mode")="global"
	ELSE  SET REQ("body","mode")="scalar"
	IF REQ("body","mode")="global" DO
	. NEW RID SET RID=$GET(REQ("id")) IF RID="" SET RID=$TR($ZH,",")_"-"_$J
	. SET REQ("id")=RID
	. SET REQ("body","ref")=$NAME(^TMP($J,"MIOHTTP","BODY",RID))
	. KILL @REQ("body","ref")
	. SET REQ("body","n")=0
	QUIT
	;
BODYAPPEND(REQ,CONF,CH,ERR)
	NEW MODE SET MODE=$GET(REQ("body","mode"),"scalar")
	NEW NEWLEN SET NEWLEN=+$GET(REQ("body","len"))+$L(CH)
	SET REQ("body","len")=NEWLEN
	NEW MAXS SET MAXS=$GET(CONF("server","limits","maxBodyScalarBytes"),262144)
	;
	IF MODE="scalar" DO
	. IF NEWLEN>MAXS DO
	. . DO BODYUP(.REQ,.CONF)
	. . SET MODE=$GET(REQ("body","mode"),"global")
	. IF MODE="scalar" DO  QUIT
	. . SET REQ("body")=$GET(REQ("body"))_CH
	; global append
	DO BODYAPPG(.REQ,CH)
	QUIT
	;
BODYUP(REQ,CONF)
	; Convert scalar -> global preserving existing bytes.;
	NEW B SET B=$GET(REQ("body"))
	NEW TOT SET TOT=+$GET(REQ("body","len"))
	NEW RID SET RID=$GET(REQ("id")) IF RID="" SET RID=$TR($ZH,",")_"-"_$J
	SET REQ("id")=RID
	SET REQ("body","mode")="global"
	SET REQ("body","ref")=$NAME(^TMP($J,"MIOHTTP","BODY",RID))
	KILL @REQ("body","ref")
	SET REQ("body","n")=0
	IF B'="" DO BODYAPPG(.REQ,B)
	SET REQ("body","len")=TOT
	; remove scalar value at REQ("body") but keep descendants
	DO KILLBODYVAL(.REQ)
	QUIT
	;
KILLBODYVAL(REQ)
	NEW TMP,SUB
	KILL TMP
	SET SUB=""
	FOR  SET SUB=$ORDER(REQ("body",SUB)) QUIT:SUB=""  MERGE TMP(SUB)=REQ("body",SUB)
	KILL REQ("body")
	MERGE REQ("body")=TMP
	QUIT
	;
BODYAPPG(REQ,CH)
	NEW REF SET REF=$GET(REQ("body","ref"))
	IF REF="" QUIT
	NEW N SET N=+$GET(REQ("body","n"))+1
	SET REQ("body","n")=N
	SET @REF@(N)=CH
	QUIT
	;
BODYOPEN(REQ,CUR)
	SET CUR=0
	QUIT
	;
BODYNEXT(REQ,CUR,CH)
	SET CH=""
	NEW MODE SET MODE=$GET(REQ("body","mode"))
	IF MODE=""!(MODE="none") QUIT 0
	IF MODE="scalar" DO  QUIT $S(CH'="":1,1:0)
	. IF CUR>0 QUIT
	. SET CUR=1
	. SET CH=$GET(REQ("body"))
	NEW REF SET REF=$GET(REQ("body","ref"))
	IF REF="" QUIT 0
	NEW NMAX SET NMAX=+$GET(REQ("body","n"))
	IF CUR'<NMAX QUIT 0
	SET CUR=CUR+1
	SET CH=$GET(@REF@(CUR))
	QUIT 1
	;
BODYLEN(REQ)
	QUIT +$GET(REQ("body","len"))
	;
BODYFREE(REQ)
	IF $GET(REQ("body","mode"))="global" DO
	. NEW REF SET REF=$GET(REQ("body","ref"))
	. IF REF'="" KILL @REF
	KILL REQ("body")
	KILL REQ("body","mode"),REQ("body","ref"),REQ("body","n"),REQ("body","len")
	QUIT
	;
; ---------------- error mapping ----------------
	;
STATUS4ERR(ERR)
	NEW E SET E=$GET(ERR("error"))
	QUIT $SELECT(E="client_closed":0,E="read_timeout":408,E="request_line_too_large":414,E="headers_too_large":431,E="too_many_headers":431,E="payload_too_large":413,E="unsupported_transfer_encoding":501,E="chunked_not_supported":400,E="invalid_content_length":400,E="bad_request_line":400,E="short_read":400,E="bad_chunk_size":400,E="bad_chunk_ending":400,E="header_folding_rejected":400,1:400)
	;
; ---------------- responses (used by MIOD) ----------------
	;
RESPJSON(DEV,CONF,STATUS,OBJ,REQID)
	NEW BODY,HEAD
	SET BODY=$$EN^MIOJSON1(.OBJ)
	SET HEAD("Content-Type")="application/json"
	IF '$G(STATUS) SET STATUS=200
	IF '$G(REQID) SET REQID=$TR($ZH,",")
	DO RESP(.DEV,.CONF,STATUS,.HEAD,BODY,REQID)
	QUIT
	;
RESP(DEV,CONF,STATUS,HEAD,BODY,REQID)
	NEW HLINE SET HLINE="HTTP/1.1 "_STATUS_" "_$$STATUSMSG(STATUS)_$C(13,10)
	DO WRITE^MIOSOCK(DEV,HLINE)
	NEW DH MERGE DH=CONF("server","http","defaultResponseHeaders")
	NEW K SET K=""
	FOR  SET K=$ORDER(DH(K)) QUIT:K=""  SET HEAD(K)=DH(K)
	IF REQID'="" SET HEAD("X-Request-Id")=REQID
	SET HEAD("Content-Length")=$L(BODY)
	IF '$DATA(HEAD("Connection")) SET HEAD("Connection")="keep-alive"
	FOR  SET K=$ORDER(HEAD(K)) QUIT:K=""  DO WRITE^MIOSOCK(DEV,K_": "_HEAD(K)_$C(13,10))
	DO WRITE^MIOSOCK(DEV,$C(13,10))
	DO WRITE^MIOSOCK(DEV,BODY)
	QUIT
	;
STATUSMSG(S)
	QUIT $SELECT(S=200:"OK",S=101:"Switching Protocols",S=400:"Bad Request",S=401:"Unauthorized",S=404:"Not Found",S=405:"Method Not Allowed",S=408:"Request Timeout",S=413:"Payload Too Large",S=414:"URI Too Long",S=431:"Request Header Fields Too Large",S=500:"Internal Server Error",S=501:"Not Implemented",1:"")
	;
RESPX(DEV,CONF,STATUS,HEAD,BODY,REQID,CTX)
	IF $DATA(CTX) SET CTX("status")=STATUS
	DO RESP(DEV,.CONF,STATUS,.HEAD,BODY,REQID)
	QUIT
	;
RESPJSONX(DEV,CONF,STATUS,OBJ,REQID,CTX)
	IF $DATA(CTX) SET CTX("status")=STATUS
	DO RESPJSON(DEV,.CONF,STATUS,.OBJ,REQID)
	QUIT
	;