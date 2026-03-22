MIOHTTP ; HTTP parsing + streaming request body storage (MAXSTRING-safe).;
;
; Purpose
; Parse HTTP/1.1 request line, headers, and request bodies.;
; Store bodies in a way that avoids MAXSTRING errors and minimizes copying.;
;
; Storage model
; - Small bodies: REQ("body") (scalar), REQ("body","mode")="scalar"
; - Large bodies: chunks in ^TMP($J,"MIOHTTP","BODY",REQ("id"),n)
;   REQ("body","mode")="global", REQ("body","ref")=$NAME(^TMP(...)), REQ("body","n")=n
;
; Config (optional)
; CONF("server","limits","maxRequestLineBytes")   default 8192
; CONF("server","limits","maxHeaderBytes")        default 65536
; CONF("server","limits","maxHeaderCount")        default 80
; CONF("server","limits","maxBodyBytes")          default 10485760
; CONF("server","limits","maxBodyScalarBytes")    default 262144
; CONF("server","http","readBodyChunkBytes")      default 65536 (clamped 1024..262144)
; CONF("server","http","supportChunkedRequest")   default 1
; CONF("server","timeouts","readHeaderMs")        default 2 (seconds)
; CONF("server","timeouts","readBodyMs")          default 3 (seconds)
;
; Public entry points
; - PARSE(DEV,CONF,REQ,ERR)
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
	IF $L(LINE)>$$LIM(.CONF,"maxRequestLineBytes",8192) DO  QUIT 0
	. SET ERR("routine")="MIOHTTP",ERR("error")="request_line_too_large"
	;
	DO PARSEREQLINE(LINE,.REQ,.ERR) IF $DATA(ERR) QUIT 0
	DO READHDRS(.DEV,.CONF,.REQ,.ERR) IF $DATA(ERR) QUIT 0
	DO SETMETABASE(.REQ)
	IF '$$STRICTREQ(.CONF,.REQ,.ERR) QUIT 0
	NEW FR SET FR=$$BODYFRAMING(.CONF,.REQ,.ERR) IF $DATA(ERR) QUIT 0
	NEW CL SET CL=$GET(REQ("hdr","content-length"))
	IF FR="chunked" DO  QUIT $SELECT($DATA(ERR):0,1:1)
	. IF '$GET(CONF("server","http","supportChunkedRequest"),1) DO  QUIT
	. . SET ERR("routine")="MIOHTTP",ERR("error")="chunked_not_supported"
	. DO READCHUNKED(.DEV,.CONF,.REQ,.ERR)
	. IF '$DATA(ERR) DO SETBODYMETA(.REQ,"chunked")
	IF FR="content-length" DO  QUIT $SELECT($DATA(ERR):0,1:1)
	. DO READCL(.DEV,.CONF,.REQ,CL,.ERR)
	. IF '$DATA(ERR) DO SETBODYMETA(.REQ,"content-length")
	SET REQ("body","mode")="none",REQ("body","len")=0
	DO SETBODYMETA(.REQ,"none")
	QUIT 1
	;
READLINE(DEV,TO,OUT,ERR)
	; Read a CRLF-delimited line.;
	; IMPORTANT: file fixtures use DELIM=$C(13,10) and may need true M READ behavior
	; to correctly return empty lines (e.g. chunk terminators/trailers).;
	NEW X
	; File fixture path? (tests pass DEV as a filename like tmp/t004_*.req)
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
; -------------------------------------------------------------------------
; Request line and query parsing.;
	;
PARSEREQLINE(L,REQ,ERR)
	NEW M,P,V
	SET M=$PIECE(L," ",1),P=$PIECE(L," ",2),V=$PIECE(L," ",3)
	IF M=""!(P="")!(V="") SET ERR("error")="bad_request_line" QUIT
	SET REQ("method")=M
	SET REQ("rawpath")=P
	; Strip any stray CR from the version token.;
	SET REQ("httpver")=$TRANSLATE(V,$CHAR(13),"")
	SET REQ("path")=$PIECE(P,"?",1)
	DO PARSEQRY(P,.REQ)
	QUIT
	;
TARGETKIND(REQ)
	NEW M,P
	SET M=$$LOW($GET(REQ("method")))
	SET P=$GET(REQ("path"))
	IF P="*" QUIT "asterisk"
	IF M="connect",P'="",$EXTRACT(P)'="/" QUIT "authority"
	QUIT "origin"
	;
SETMETABASE(REQ)
	SET REQ("meta","targetKind")=$$TARGETKIND(.REQ)
	SET REQ("meta","contentLength")=$GET(REQ("hdr","content-length"))
	SET REQ("meta","transferEncoding")=$$LOW($GET(REQ("hdr","transfer-encoding")))
	SET REQ("meta","isForm")=$$ISFORM(.REQ)
	SET REQ("meta","isJSON")=$$ISJSON(.REQ)
	QUIT
	;
SETBODYMETA(REQ,FRAMING)
	NEW BL,CL
	SET BL=+$GET(REQ("body","len"))
	SET CL=+$GET(REQ("meta","contentLength"))
	SET REQ("meta","bodyFraming")=$GET(FRAMING,"none")
	SET REQ("meta","hasBody")=$SELECT(BL>0:1,$GET(FRAMING)="chunked":1,$GET(FRAMING)="content-length"&(CL>0):1,1:0)
	QUIT
	;
STRICTREQ(CONF,REQ,ERR)
	NEW STRICT SET STRICT=+$GET(CONF("server","http","strict"),0)
	IF 'STRICT QUIT 1
	NEW TK,M,P,V
	SET TK=$GET(REQ("meta","targetKind")) IF TK="" SET TK=$$TARGETKIND(.REQ)
	SET M=$$LOW($GET(REQ("method")))
	SET P=$GET(REQ("path"))
	SET V=$GET(REQ("httpver"))
	IF V="HTTP/1.1",TK="origin",$GET(REQ("hdr","host"))="" DO  QUIT 0
	. SET ERR("routine")="MIOHTTP",ERR("error")="missing_host"
	IF TK="origin",(P=""!($EXTRACT(P)'="/")) DO  QUIT 0
	. SET ERR("routine")="MIOHTTP",ERR("error")="invalid_request_target"
	IF TK="asterisk",M'="options" DO  QUIT 0
	. SET ERR("routine")="MIOHTTP",ERR("error")="invalid_request_target"
	IF TK="authority",M'="connect" DO  QUIT 0
	. SET ERR("routine")="MIOHTTP",ERR("error")="invalid_request_target"
	QUIT 1
	;
BODYFRAMING(CONF,REQ,ERR)
	NEW CL,TE,ALLOWTECL,STRICTTE,FR
	SET CL=$GET(REQ("hdr","content-length"))
	SET TE=$$LOW($GET(REQ("hdr","transfer-encoding")))
	SET ALLOWTECL=+$GET(CONF("server","http","allowTECL"),0)
	SET STRICTTE=+$GET(CONF("server","http","strictTE"),1)
	SET FR="none"
	IF TE'="" DO  QUIT $SELECT($DATA(ERR):"",1:FR)
	. IF '$$TEOK(TE) DO  QUIT
	. . SET ERR("routine")="MIOHTTP",ERR("error")="unsupported_transfer_encoding"
	. IF STRICTTE,$$TEHAS(TE,"chunked"),'$$TECHUNKLAST(TE) DO  QUIT
	. . SET ERR("routine")="MIOHTTP",ERR("error")="bad_transfer_encoding_order"
	. IF $$TEHAS(TE,"chunked") DO  QUIT
	. . IF CL'="",'ALLOWTECL DO  QUIT
	. . . SET ERR("routine")="MIOHTTP",ERR("error")="te_cl_conflict"
	. . SET REQ("meta","contentLength")=""
	. . SET REQ("meta","transferEncoding")=TE
	. . SET FR="chunked"
	. IF CL'="" SET FR="content-length" QUIT
	. SET FR="none"
	IF CL'="" SET FR="content-length"
	SET REQ("meta","bodyFraming")=FR
	QUIT FR
	;
PARSEQRY(P,REQ)
	KILL REQ("query")
	NEW Q SET Q=$PIECE(P,"?",2,999)
	IF Q="" QUIT
	NEW I,PAIR,K,V
	FOR I=1:1:$LENGTH(Q,"&") DO
	. SET PAIR=$PIECE(Q,"&",I)
	. SET K=$$URLDECQ($PIECE(PAIR,"=",1))
	. SET V=$$URLDECQ($PIECE(PAIR,"=",2,999))
	. IF K'="" SET REQ("query",K)=V
	QUIT
	;
; Query/Form URL decoder: '+' => space, %HH => byte.;
; Invalid % sequences are preserved.;
URLDECQ(S)
	NEW IN,OUT,L,I,C,HEX,B
	SET IN=$TRANSLATE($GET(S),"+"," ")
	; fast path
	IF IN'["%",IN'[" " QUIT IN
	SET OUT="",L=$LENGTH(IN),I=1
	FOR  QUIT:I>L  DO
	. SET C=$EXTRACT(IN,I)
	. IF C="%",(I+2)'>L DO  QUIT
	. . SET HEX=$EXTRACT(IN,I+1,I+2)
	. . SET B=$$HEX2DEC(HEX)
	. . IF B'<0 SET OUT=OUT_$CHAR(B),I=I+3 QUIT
	. . SET OUT=OUT_"%",I=I+1
	. SET OUT=OUT_C
	. SET I=I+1
	QUIT OUT
	;
; Convert exactly 2 hex digits (used for %HH decoding).;
HEX2DEC(HH)
	NEW A,B
	SET A=$$HEXVAL($EXTRACT($GET(HH),1))
	SET B=$$HEXVAL($EXTRACT($GET(HH),2))
	IF A<0!(B<0) QUIT -1
	QUIT (A*16)+B
	;
; Convert variable-length hex string (1..8 chars) to decimal.;
; Used for chunked transfer sizes like "4" or "1A3".;
HEXSTR2DEC(HX)
	NEW I,C,V,OUT
	SET HX=$ZCONVERT($GET(HX),"U")
	IF HX="" QUIT -1
	IF $LENGTH(HX)>8 QUIT -1
	SET OUT=0
	FOR I=1:1:$LENGTH(HX) DO
	. SET C=$EXTRACT(HX,I)
	. SET V=$$HEXVAL(C)
	. IF V<0 SET OUT=-1 QUIT
	. SET OUT=(OUT*16)+V
	QUIT OUT
	;
HEXVAL(C)
	NEW U,P
	SET U=$ZCONVERT($GET(C),"U")
	SET P=$FIND("0123456789ABCDEF",U)
	QUIT $SELECT(P=0:-1,1:P-2)
	;
; -------------------------------------------------------------------------
; Header parsing.;
	;
READHDRS(DEV,CONF,REQ,ERR)
	KILL REQ("hdr")
	NEW MAXC,MAXB,MAXL,COUNT,BYTES,LINE,TOH
	SET MAXC=$$LIM(.CONF,"maxHeaderCount",80)
	SET MAXB=$$LIM(.CONF,"maxHeaderBytes",65536)
	SET MAXL=$$LIM(.CONF,"maxHeaderLineBytes",8192)
	SET COUNT=0,BYTES=0
	SET TOH=$GET(CONF("server","timeouts","readHeaderMs"),2)
	FOR  DO  QUIT:LINE=""
	. DO READLINE(.DEV,TOH,.LINE,.ERR) IF $DATA(ERR) QUIT
	. ; blank line ends headers
	. IF LINE="" QUIT
	. ; per-line limit (prevents pathological single-line headers)
	. IF $LENGTH(LINE)>MAXL DO  QUIT
	. . SET ERR("error")="header_line_too_large",ERR("routine")="MIOHTTP"
	. SET BYTES=BYTES+$LENGTH(LINE)+2
	. IF BYTES>MAXB DO  QUIT
	. . SET ERR("error")="headers_too_large",ERR("routine")="MIOHTTP"
	. SET COUNT=COUNT+1
	. IF COUNT>MAXC DO  QUIT
	. . SET ERR("error")="too_many_headers",ERR("routine")="MIOHTTP"
	. ; Reject obs-fold (line starts with SP/TAB)
	. IF $EXTRACT(LINE,1)=" "!($EXTRACT(LINE,1)=$CHAR(9)) DO  QUIT
	. . SET ERR("error")="header_folding_rejected",ERR("routine")="MIOHTTP"
	. ; Must contain ':'
	. IF LINE'[":" DO  QUIT
	. . SET ERR("error")="bad_header_line",ERR("routine")="MIOHTTP"
	. NEW RAWN,N,V
	. SET RAWN=$$TRIM($PIECE(LINE,":",1))
	. IF RAWN="" DO  QUIT
	. . SET ERR("error")="invalid_header_name",ERR("routine")="MIOHTTP"
	. SET N=$$LOW(RAWN)
	. IF '$$HTOK(N) DO  QUIT
	. . SET ERR("error")="invalid_header_name",ERR("routine")="MIOHTTP"
	. SET V=$$TRIM($PIECE(LINE,":",2,999))
	. IF '$$HVALOK(V) DO  QUIT
	. . SET ERR("error")="invalid_header_value",ERR("routine")="MIOHTTP"
	. ; Strict duplicate rejection for smuggling-sensitive headers
	. IF N="content-length",$DATA(REQ("hdr",N)) DO  QUIT
	. . SET ERR("error")="duplicate_content_length",ERR("routine")="MIOHTTP"
	. IF N="transfer-encoding",$DATA(REQ("hdr",N)) DO  QUIT
	. . SET ERR("error")="duplicate_transfer_encoding",ERR("routine")="MIOHTTP"
	. IF N="host",$DATA(REQ("hdr",N)) DO  QUIT
	. . SET ERR("error")="duplicate_host",ERR("routine")="MIOHTTP"
	. SET REQ("hdr",N)=V
	QUIT
	;
; -------------------------------------------------------------------------
; Error mapping.;
	;
STATUS4ERR(ERR)
	NEW E SET E=$GET(ERR("error"))
	QUIT $SELECT(E="client_closed":0,E="rate_limited":429,E="read_timeout":408,E="request_line_too_large":414,E="header_line_too_large":431,E="headers_too_large":431,E="too_many_headers":431,E="payload_too_large":413,E="te_cl_conflict":400,E="duplicate_content_length":400,E="duplicate_transfer_encoding":400,E="duplicate_host":400,E="bad_header_line":400,E="invalid_header_name":400,E="invalid_header_value":400,E="bad_transfer_encoding_order":400,E="chunked_not_supported":400,E="unsupported_transfer_encoding":501,E="invalid_content_length":400,E="bad_request_line":400,E="invalid_request_target":400,E="missing_host":400,E="short_read":400,E="bad_chunk_size":400,E="bad_chunk_ending":400,E="header_folding_rejected":400,1:400)
	;
; -------------------------------------------------------------------------
; Response helpers.;
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
	;
RESP(DEV,CONF,STATUS,HEAD,BODY,REQID)
	NEW BYTES SET BYTES=0
	NEW THEAD M THEAD=HEAD
	NEW S SET S=+$GET(STATUS,200)
	NEW METH SET METH=$$CURMETH()
	NEW ISH SET ISH=$SELECT(METH="head":1,1:0)
	NEW NOB SET NOB=$$NOBODY(S)
	NEW BLEN SET BLEN=$LENGTH($GET(BODY))
	IF NOB SET BLEN=0
	NEW HLINE SET HLINE="HTTP/1.1 "_S_" "_$$STATUSMSG(S)_$CHAR(13,10)
	DO WRITE^MIOSOCK(DEV,HLINE) SET BYTES=BYTES+$L(HLINE)
	NEW DH MERGE DH=CONF("server","http","defaultResponseHeaders")
	NEW K SET K=""
	FOR  SET K=$ORDER(DH(K)) QUIT:K=""  SET HEAD(K)=DH(K)
	IF REQID'="" SET HEAD("X-Request-Id")=REQID
	; Status codes that must not include a body
	IF NOB SET HEAD("Content-Length")=0
	ELSE  SET HEAD("Content-Length")=BLEN
	IF '$DATA(HEAD("Connection")) SET HEAD("Connection")="keep-alive"
	I $D(THEAD) M HEAD=THEAD
	FOR  SET K=$ORDER(HEAD(K)) QUIT:K=""  DO
	. NEW L SET L=K_": "_HEAD(K)_$CHAR(13,10)
	. DO WRITE^MIOSOCK(DEV,L) SET BYTES=BYTES+$L(L)
	NEW BL SET BL=$CHAR(13,10)
	DO WRITE^MIOSOCK(DEV,BL) SET BYTES=BYTES+$L(BL)
	; HEAD requests and no-body statuses must not emit a message body
	IF 'ISH,'NOB DO
	. DO WRITE^MIOSOCK(DEV,$GET(BODY)) SET BYTES=BYTES+$L($GET(BODY))
	SET ^TMP($J,"MIOHTTP","RESP","bytes")=BYTES
	QUIT
	;
STATUSMSG(S)
	NEW X SET X=+S
	QUIT $SELECT(X=100:"Continue",X=101:"Switching Protocols",X=200:"OK",X=201:"Created",X=202:"Accepted",X=204:"No Content",X=205:"Reset Content",X=301:"Moved Permanently",X=302:"Found",X=303:"See Other",X=304:"Not Modified",X=307:"Temporary Redirect",X=308:"Permanent Redirect",X=400:"Bad Request",X=401:"Unauthorized",X=404:"Not Found",X=405:"Method Not Allowed",X=408:"Request Timeout",X=409:"Conflict",X=413:"Payload Too Large",X=414:"URI Too Long",X=422:"Unprocessable Entity",X=429:"Too Many Requests",X=431:"Request Header Fields Too Large",X=500:"Internal Server Error",X=501:"Not Implemented",X=503:"Service Unavailable",1:"")
	;
LOW(S) QUIT $ZCONVERT($GET(S),"L")
	;
TRIM(S)
	NEW X SET X=$GET(S)
	FOR  QUIT:$EXTRACT(X,1)'=" "  SET X=$EXTRACT(X,2,$LENGTH(X))
	FOR  QUIT:$EXTRACT(X,$LENGTH(X))'=" "  SET X=$EXTRACT(X,1,$LENGTH(X)-1)
	QUIT X
	;
MEDIATYPE(CTYPE)
	NEW X
	SET X=$$LOW($$TRIM($PIECE($GET(CTYPE),";",1)))
	QUIT X
	;
CTPARAM(CTYPE,NAME)
	NEW I,P,K,V,ANS
	SET NAME=$$LOW($$TRIM($GET(NAME)))
	SET ANS=""
	FOR I=2:1:$LENGTH($GET(CTYPE),";") QUIT:ANS'=""  DO
	. SET P=$$TRIM($PIECE(CTYPE,";",I))
	. QUIT:P=""
	. SET K=$$LOW($$TRIM($PIECE(P,"=",1)))
	. SET V=$$TRIM($PIECE(P,"=",2,999))
	. IF $EXTRACT(V)=""",$EXTRACT(V,$LENGTH(V))=""",$LENGTH(V)>1 SET V=$EXTRACT(V,2,$LENGTH(V)-1)
	. IF K=NAME SET ANS=V
	QUIT ANS
	;
ISFORM(REQ)
	NEW MT
	SET MT=$$MEDIATYPE($GET(REQ("hdr","content-type")))
	QUIT $SELECT(MT="application/x-www-form-urlencoded":1,1:0)
	;
ISJSON(REQ)
	NEW MT
	SET MT=$$MEDIATYPE($GET(REQ("hdr","content-type")))
	IF MT="application/json" QUIT 1
	IF $LENGTH(MT)>5,$EXTRACT(MT,$LENGTH(MT)-4,$LENGTH(MT))="+json" QUIT 1
	QUIT 0
	;
PARSEFORM(REQ,OUT,ERR)
	KILL OUT,ERR
	IF '$$ISFORM(.REQ) DO  QUIT 0
	. SET ERR("routine")="MIOHTTP",ERR("error")="not_form_content_type"
	NEW CUR,CH,BUF,PIECEI
	SET BUF=""
	DO BODYOPEN(.REQ,.CUR)
	FOR  QUIT:'$$BODYNEXT(.REQ,.CUR,.CH)  DO
	. SET BUF=BUF_$GET(CH)
	. FOR  QUIT:BUF'["&"  DO
	. . NEW PAIR
	. . SET PAIR=$PIECE(BUF,"&",1)
	. . SET BUF=$PIECE(BUF,"&",2,999)
	. . DO FORMPAIR(.PAIR,.OUT)
	IF BUF'="" DO FORMPAIR(.BUF,.OUT)
	QUIT 1
	;
FORMPAIR(PAIR,OUT)
	NEW KENC,VENC,EQ,K,V
	QUIT:$GET(PAIR)=""
	SET EQ=$FIND(PAIR,"=")
	IF EQ>0 DO
	. SET KENC=$EXTRACT(PAIR,1,EQ-2)
	. SET VENC=$EXTRACT(PAIR,EQ,$LENGTH(PAIR))
	ELSE  DO
	. SET KENC=PAIR
	. SET VENC=""
	SET K=$$URLDECQ(KENC)
	SET V=$$URLDECQ(VENC)
	DO FORMSET(.OUT,K,V)
	SET PAIR=""
	QUIT
	;
FORMSET(OUT,KEY,VAL)
	NEW CNT,OLD
	QUIT:$GET(KEY)=""
	IF '$DATA(OUT(KEY)) DO  QUIT
	. SET OUT(KEY)=VAL
	SET CNT=$GET(OUT(KEY,0))
	IF CNT="" DO  QUIT
	. SET OLD=$GET(OUT(KEY))
	. SET OUT(KEY,0)=2
	. SET OUT(KEY,1)=OLD
	. SET OUT(KEY,2)=VAL
	. SET OUT(KEY)=VAL
	SET CNT=CNT+1
	SET OUT(KEY,0)=CNT
	SET OUT(KEY,CNT)=VAL
	SET OUT(KEY)=VAL
	QUIT
	;
REDIRECT(DEV,CONF,LOC,STATUS,REQID,CTX)
	NEW HEAD,S,BODY
	SET S=+$GET(STATUS)
	IF 'S SET S=303
	SET HEAD("Content-Type")="text/plain; charset=utf-8"
	SET HEAD("Location")=$GET(LOC,"/")
	SET BODY=$SELECT($$STATUSMSG(S)'="":$$STATUSMSG(S),1:"Redirect")
	DO RESPX(.DEV,.CONF,S,.HEAD,BODY,$GET(REQID),.CTX)
	QUIT
	;
RESPTEXT(DEV,CONF,STATUS,TEXT,REQID,CTX)
	NEW HEAD,S
	SET S=+$GET(STATUS)
	IF 'S SET S=200
	SET HEAD("Content-Type")="text/plain; charset=utf-8"
	DO RESPX(.DEV,.CONF,S,.HEAD,$GET(TEXT),$GET(REQID),.CTX)
	QUIT
	;
RESPERR(DEV,CONF,STATUS,CODE,MESSAGE,REQID,CTX)
	NEW OBJ,S
	SET S=+$GET(STATUS)
	IF 'S SET S=400
	SET OBJ("ok")=0
	SET OBJ("error")=$GET(CODE)
	IF $GET(MESSAGE)'="" SET OBJ("message")=$GET(MESSAGE)
	DO RESPJSONX(.DEV,.CONF,S,.OBJ,$GET(REQID),.CTX)
	QUIT
;
LIM(CONF,NAME,DEF)
	; Lookup limit values with backward-compatible paths.;
	; Preferred: CONF("server","http","limits",NAME)
	; Fallback:  CONF("server","limits",NAME)
	NEW V SET V=$GET(CONF("server","http","limits",NAME))
	IF V="" SET V=$GET(CONF("server","limits",NAME))
	; Allow legacy/alternate key spellings
	IF V="",NAME="maxHeaderLineBytes" DO
	. SET V=$GET(CONF("server","http","limits","maxHeaderLineLength"))
	. IF V="" SET V=$GET(CONF("server","limits","maxHeaderLineLength"))
	IF V="",NAME="maxRequestLineBytes" DO
	. SET V=$GET(CONF("server","http","limits","maxRequestLineLength"))
	. IF V="" SET V=$GET(CONF("server","limits","maxRequestLineLength"))
	IF V="" SET V=$GET(DEF)
	QUIT V
	;
RESPX(DEV,CONF,STATUS,HEAD,BODY,REQID,CTX)
	SET CTX("status")=STATUS
	DO RESP(DEV,.CONF,STATUS,.HEAD,BODY,REQID)
	QUIT
	;
RESPJSONX(DEV,CONF,STATUS,OBJ,REQID,CTX)
	SET CTX("status")=STATUS
	DO RESPJSON(DEV,.CONF,STATUS,.OBJ,REQID)
	QUIT
	;
; -------------------------------------------------------------------------
; Expect: 100-continue helpers (ROI)
;
; These helpers do NOT change PARSE() behavior.;
; Typical server flow:
;   ok=$$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
;   ok2=$$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR)
;   if ok2=0 -> respond and close
;   else -> DO SEND100^MIOHTTP(DEV,.REQ,.ERR) then DO READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR)
;
EXPECTDECIDE(CONF,REQ,ERR)
	NEW EXP SET EXP=$$LOW($GET(REQ("hdr","expect")))
	IF EXP'["100-continue" QUIT 1
	NEW MAXB SET MAXB=+$GET(CONF("server","limits","maxBodyBytes"),10485760)
	NEW CL SET CL=+$GET(REQ("hdr","content-length"),0)
	IF CL>0,CL>MAXB DO  QUIT 0
	. SET ERR("routine")="MIOHTTP",ERR("error")="payload_too_large"
	QUIT 1
;
SEND100(DEV,REQ,ERR)
	NEW OIO SET OIO=$IO
	NEW $ETRAP SET $ETRAP="DO TRAPIO^MIOHTTP"
	USE DEV WRITE "HTTP/1.1 100 Continue",$CHAR(13,10),$CHAR(13,10)
	USE OIO
	QUIT
;
; Parse request line + headers only (no body).;
PARSEHDRS(DEV,CONF,REQ,ERR)
	NEW RID SET RID=$GET(REQ("id"))
	KILL REQ,ERR
	IF RID'="" SET REQ("id")=RID
	IF $GET(REQ("id"))="" SET REQ("id")=$TR($ZH,",")_"-"_$J
	NEW TOH SET TOH=$GET(CONF("server","timeouts","readHeaderMs"),2)
	NEW LINE DO READLINE(.DEV,TOH,.LINE,.ERR) IF $DATA(ERR) QUIT 0
	DO PARSEREQLINE(LINE,.REQ,.ERR) IF $DATA(ERR) QUIT 0
	DO READHDRS(.DEV,.CONF,.REQ,.ERR) IF $DATA(ERR) QUIT 0
	DO SETMETABASE(.REQ)
	IF '$$STRICTREQ(.CONF,.REQ,.ERR) QUIT 0
	NEW FR SET FR=$$BODYFRAMING(.CONF,.REQ,.ERR) IF $DATA(ERR) QUIT 0
	DO SETBODYMETA(.REQ,FR)
	QUIT 1
	;	
; Read only the request body, assuming headers already parsed.;
READBODYONLY(DEV,CONF,REQ,ERR)
	DO SETMETABASE(.REQ)
	IF '$$STRICTREQ(.CONF,.REQ,.ERR) QUIT 0
	NEW FR SET FR=$$BODYFRAMING(.CONF,.REQ,.ERR) IF $DATA(ERR) QUIT 0
	NEW CL SET CL=+$GET(REQ("hdr","content-length"),0)
	IF FR="chunked" DO  QUIT $SELECT($DATA(ERR):0,1:1)
	. IF '$GET(CONF("server","http","supportChunkedRequest"),1) DO  QUIT
	. . SET ERR("routine")="MIOHTTP",ERR("error")="chunked_not_supported"
	. DO READCHUNKED(.DEV,.CONF,.REQ,.ERR)
	. IF '$DATA(ERR) DO SETBODYMETA(.REQ,"chunked")
	IF FR="content-length" DO  QUIT $SELECT($DATA(ERR):0,1:1)
	. IF CL'>0 DO  QUIT
	. . SET REQ("body","mode")="none",REQ("body","len")=0
	. . DO SETBODYMETA(.REQ,"content-length")
	. NEW TOB SET TOB=$GET(CONF("server","timeouts","readBodyMs"),3)
	. DO READLEN(.DEV,.CONF,.REQ,CL,TOB,.ERR)
	. IF '$DATA(ERR) DO SETBODYMETA(.REQ,"content-length")
	SET REQ("body","mode")="none",REQ("body","len")=0
	DO SETBODYMETA(.REQ,"none")
	QUIT 1
	;
; -----------------------------------------------------------------------------
; Response streaming + sendfile (ROI)
;
; Public:
;   STREAMBEGIN(DEV,CONF,STATUS,HEAD,REQID,CTX,METHOD)
;   STREAMWRITE(DEV,DATA)
;   STREAMEND(DEV)
;   $$SENDFILE(DEV,CONF,PATH,HEAD,REQID,CTX,METHOD)
;
WRESP(DEV,S)
	NEW D SET D=$GET(DEV) IF D="" SET D=$IO
	NEW OIO SET OIO=$IO
	NEW $ETRAP SET $ETRAP="DO TRAPIO^MIOHTTP"
	IF $TEXT(WRITE^MIOSOCK)'="" DO
	. DO WRITE^MIOSOCK(D,S)
	ELSE  DO
	. USE D WRITE S
	; Stream byte accounting (ROI #1)
	IF +$GET(^TMP($J,"MIOHTTP","STREAM","active")) DO
	. SET ^TMP($J,"MIOHTTP","STREAM","bytes")=+$GET(^TMP($J,"MIOHTTP","STREAM","bytes"))+$L($GET(S))
	USE OIO
	QUIT
;
HEXOUT(N)
	NEW H SET H="0123456789ABCDEF"
	IF N=0 QUIT "0"
	NEW OUT SET OUT=""
	NEW Q,R
	FOR  QUIT:N=0  DO
	. SET Q=N\16,R=N#16
	. SET OUT=$E(H,R+1)_OUT
	. SET N=Q
	QUIT OUT
;
	;
STREAMBEGIN(DEV,CONF,STATUS,HEAD,REQID,CTX,METHOD)
	IF '$G(STATUS) SET STATUS=200
	N TH M TH=HEAD
	IF $G(REQID)="" SET REQID=$TR($ZH,",")_"-"_$J
	SET CTX("status")=STATUS
	KILL ^TMP($J,"MIOHTTP","RESP","bytes")
	SET ^TMP($J,"MIOHTTP","STREAM","active")=1
	SET ^TMP($J,"MIOHTTP","STREAM","bytes")=0
	NEW S SET S=+STATUS
	NEW METH SET METH=$$CURMETH($G(METHOD))
	NEW ISH SET ISH=$SELECT(METH="head":1,METH="HEAD":1,1:0)
	NEW NOB SET NOB=$$NOBODY(S)
	SET ^TMP($J,"MIOHTTP","STREAM","skipbody")=$SELECT(ISH!NOB:1,1:0)
	DO WRESP(.DEV,"HTTP/1.1 "_S_" "_$$STATUSMSG(S)_$CHAR(13,10))
	NEW DH MERGE DH=CONF("server","http","defaultResponseHeaders")
	NEW K SET K=""
	FOR  SET K=$ORDER(DH(K)) QUIT:K=""  SET HEAD(K)=DH(K)
	IF REQID'="" SET HEAD("X-Request-Id")=REQID
	KILL HEAD("Content-Length")
	IF NOB DO
	. ; no-body statuses: send Content-Length: 0 and do not use chunked framing
	. KILL HEAD("Transfer-Encoding")
	. SET HEAD("Content-Length")=0
	. SET ^TMP($J,"MIOHTTP","STREAM","chunked")=0
	ELSE  DO
	. SET HEAD("Transfer-Encoding")="chunked"
	. SET ^TMP($J,"MIOHTTP","STREAM","chunked")=1
	IF '$DATA(HEAD("Connection")) SET HEAD("Connection")="keep-alive"
	M HEAD=TH
	FOR  SET K=$ORDER(HEAD(K)) QUIT:K=""  DO WRESP(.DEV,K_": "_HEAD(K)_$CHAR(13,10))
	DO WRESP(.DEV,$CHAR(13,10))
	QUIT
;
	;
STREAMWRITE(DEV,DATA)
	; In HEAD/no-body mode, suppress chunk emission entirely.;
	IF +$GET(^TMP($J,"MIOHTTP","STREAM","skipbody")) QUIT
	NEW L SET L=$L($GET(DATA))
	IF L=0 QUIT
	DO WRESP(.DEV,$$HEXOUT(L)_$CHAR(13,10))
	DO WRESP(.DEV,DATA)
	DO WRESP(.DEV,$CHAR(13,10))
	QUIT
;
	;
STREAMEND(DEV)
	; If chunked framing is active, always terminate it (even for HEAD) so the message is well-formed.;
	IF +$GET(^TMP($J,"MIOHTTP","STREAM","chunked")) DO WRESP(.DEV,"0"_$CHAR(13,10)_$CHAR(13,10))
	SET ^TMP($J,"MIOHTTP","STREAM","active")=0
	QUIT
;
SENDFILE(DEV,CONF,PATH,HEAD,REQID,CTX,METHOD)
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" SET CTX(""err"",""routine"")=""MIOHTTP"",CTX(""err"",""error"")=""open_failed"" QUIT 0"
	NEW P SET P=$GET(PATH)
	IF P="" DO  QUIT 0
	. SET CTX("err","routine")="MIOHTTP",CTX("err","error")="file_not_specified"
	NEW M SET M=$$LOW($GET(METHOD,"GET"))
	NEW CHSZ SET CHSZ=+$GET(CONF("server","static","readChunkBytes"),65536)
	IF CHSZ<1024 SET CHSZ=1024
	IF CHSZ>262144 SET CHSZ=262144
	NEW OIO SET OIO=$IO
	NEW FDEV SET FDEV=P
	; open file (no trap); on failure return 0 with CTX(err)
	OPEN FDEV:(readonly:stream:nowrap):1 ELSE  DO  QUIT 0
	. SET CTX("err","routine")="MIOHTTP",CTX("err","error")="open_failed"
	USE FDEV
	IF M="head" DO  QUIT 1
	. ; Mirror GET framing: send headers with chunked Transfer-Encoding, but suppress body chunks (HEAD semantics).;
	. DO STREAMBEGIN(.DEV,.CONF,200,.HEAD,REQID,.CTX,$G(METHOD))
	. DO STREAMEND(.DEV)
	. CLOSE FDEV
	. USE OIO
	DO STREAMBEGIN(.DEV,.CONF,200,.HEAD,REQID,.CTX,$G(METHOD))
	NEW X
	FOR  DO  QUIT:$ZEOF
	. READ X#CHSZ
	. IF X'="" DO STREAMWRITE(.DEV,X)
	DO STREAMEND(.DEV)
	CLOSE FDEV
	USE OIO
	QUIT 1
	;
TRAPIO ; internal: restore IO on error
	SET $ECODE=""
	IF $G(OIO)'="" USE OIO
	ELSE  USE $PRINCIPAL
	QUIT
	;
;
; ---------------- Header validation (hardening) ----------------
;
HTOK(N)
	; Return 1 if N is a valid RFC7230 token (lowercase recommended).;
	NEW I,C,OK,AL
	SET N=$GET(N)
	IF N="" QUIT 0
	SET AL="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&'*+-.^_`|~"
	SET OK=1
	FOR I=1:1:$LENGTH(N) DO  QUIT:'OK
	. SET C=$EXTRACT(N,I)
	. IF $FIND(AL,C)=0 SET OK=0
	QUIT OK
	;
HVALOK(V)
	; Reject CTL chars (except HTAB).;
	NEW I,A,OK
	SET V=$GET(V)
	SET OK=1
	FOR I=1:1:$LENGTH(V) DO  QUIT:'OK
	. SET A=$ASCII($EXTRACT(V,I))
	. IF A=9 QUIT
	. IF A<32!(A=127) SET OK=0
	QUIT OK
	;
TECHUNKLAST(TE)
	; Return 1 if 'chunked' is absent OR is the last non-empty token.;
	NEW I,T,POS,LAST
	SET TE=$GET(TE)
	SET POS=0,LAST=0
	FOR I=1:1:$LENGTH(TE,",") DO
	. SET T=$$LOW($$TRIM($PIECE(TE,",",I)))
	. IF T="" QUIT
	. SET LAST=I
	. IF T="chunked" SET POS=I
	IF POS=0 QUIT 1
	QUIT $SELECT(POS=LAST:1,1:0)
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
	IF $DATA(ERR) QUIT:$QUIT 0  QUIT 
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
	QUIT:$QUIT $S($D(ERR):0,1:1)
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
	; -------------------------------------------------------------------------
	; ROI #10 helpers (response correctness)
	;
	; Current request method (lowercase).;
	; MIOD sets ^TMP($J,"MIOHTTP","REQ","method") for each request.;
CURMETH(MTH)
	NEW M 
	S M=$G(MTH)
	IF M="" SET M=$GET(^TMP($J,"MIOHTTP","REQ","method"))
	IF M="" SET M=$GET(^TMP($J,"MIOHTTP","REQ","METHOD"))
	IF M="" QUIT "get"
	QUIT $$LOW(M)
	;
	; Status codes that must not include a message body per RFC semantics.;
	; (1xx, 204, 205, 304)
NOBODY(S)
	NEW X SET X=+S
	IF X\100=1 QUIT 1
	IF X=204 QUIT 1
	IF X=205 QUIT 1
	IF X=304 QUIT 1
	QUIT 0
	;
RESPHTML(DEV,CONF,CTX,OUT)
	D RESPTXT(.DEV,.CONF,.CTX,.OUT,"text/html; charset=utf-8") 
	Q
	;
RESPTXT(DEV,CONF,CTX,OUT,CTYPE)
	N HEAD S HEAD("Content-Type")=$G(CTYPE)
	D RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,$G(OUT),$G(CTX("request_id")),.CTX) 
	Q