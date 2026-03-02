MIOSTATIC ; Static file serving (sendfile + ETag + Range)
	;
	; PUBLIC
	;   REG(.CONF)                       - optional route registration
	;   STATIC(DEV,CONF,REQ,CTX)         - handler for GET/HEAD /static/*path
	;
	; Requires:
	;   MIOHTTP  (LOW, TRIM, HEX2DEC, RESPJSONX, SENDFILE)
	;   MIOSOCK  (WRITE)  - used by MIOHTTP and by this module for range bodies
	;   MIOROUTE (optional for REG)
	;
	; Features:
	;   - Secure path join (prevents traversal)
	;   - Weak ETag + If-None-Match -> 304
	;   - Single Range: bytes=... -> 206 (no multipart/byteranges)
	;
	Q
	;
REG(CONF)
	IF '$GET(CONF("server","static","enabled")) QUIT
	NEW MOUNT SET MOUNT=$$NORMMOUNT($GET(CONF("server","static","mount"),"/static"))
	DO ADD^MIOROUTE("GET",MOUNT_"/*path","STATIC^MIOSTATIC")
	DO ADD^MIOROUTE("HEAD",MOUNT_"/*path","STATIC^MIOSTATIC")
	QUIT
	;
STATIC(DEV,CONF,REQ,CTX)
	NEW MOUNT SET MOUNT=$$NORMMOUNT($GET(CONF("server","static","mount"),"/static"))
	NEW ROOT  SET ROOT=$GET(CONF("server","static","root"),"public")
	NEW INDEX SET INDEX=$GET(CONF("server","static","index"),"index.html")
	NEW METHOD SET METHOD=$$LOW^MIOHTTP($GET(REQ("method"))) IF METHOD="" SET METHOD="get"
	;
	; Resolve relative path under mount
	NEW RPATH SET RPATH=$GET(REQ("params","path"))
	IF RPATH="" DO
	. NEW P SET P=$GET(REQ("path"))
	. IF $E(P,1,$L(MOUNT))=MOUNT SET RPATH=$E(P,$L(MOUNT)+2,999)
	;
	SET RPATH=$$URLDECPATH(RPATH)
	IF RPATH="" SET RPATH=INDEX
	;
	; Secure join (no traversal)
	NEW FS,OK
	SET OK=$$SAFEJOIN(ROOT,RPATH,INDEX,.FS)
	IF 'OK DO  QUIT
	. NEW OBJ SET OBJ("error")="not_found",OBJ("request_id")=$GET(CTX("request_id"))
	. DO RESPJSONX^MIOHTTP(.DEV,.CONF,404,.OBJ,$GET(CTX("request_id")),.CTX)
	. SET CTX("status")=404
	;
	NEW HEAD
	SET HEAD("Content-Type")=$$MIME(.CONF,FS)
	SET HEAD("X-Content-Type-Options")="nosniff"
	;
	; ETag / If-None-Match
	NEW META,ETAG
	DO GETMETA(.CONF,FS,.META)
	SET ETAG=$GET(META("etag"))
	IF ETAG'="" SET HEAD("ETag")=ETAG
	NEW INM SET INM=$GET(REQ("hdr","if-none-match"))
	IF ETAG'="",INM'="",$$ETAGMATCH(INM,ETAG) DO  QUIT
	. NEW H2 MERGE H2=HEAD
	. KILL H2("Transfer-Encoding")
	. SET H2("Content-Length")=0
	. DO RESPHEAD(.DEV,.CONF,304,.H2,$GET(CTX("request_id")))
	. SET CTX("status")=304
	;
	; Range requests (single range only)
	SET HEAD("Accept-Ranges")="bytes"
	NEW RNG SET RNG=$GET(REQ("hdr","range"))
	IF RNG'="" DO  QUIT:$GET(CTX("status"))>0
	. NEW FSZ,ROK,RS,RE,RLEN
	. SET FSZ=$$FILESIZE(.CONF,FS)
	. IF FSZ<0 QUIT  ; if unknown, ignore Range and send full body
	. SET ROK=$$PARSERANGE(RNG,FSZ,.RS,.RE)
	. IF 'ROK DO  QUIT
	. . NEW H3 MERGE H3=HEAD
	. . SET H3("Content-Range")="bytes */"_FSZ
	. . KILL H3("Transfer-Encoding")
	. . SET H3("Content-Length")=0
	. . DO RESPHEAD(.DEV,.CONF,416,.H3,$GET(CTX("request_id")))
	. . SET CTX("status")=416
	. SET RLEN=RE-RS+1
	. NEW H4 MERGE H4=HEAD
	. SET H4("Content-Range")="bytes "_RS_"-"_RE_"/"_FSZ
	. KILL H4("Transfer-Encoding")
	. SET H4("Content-Length")=RLEN
	. DO RESPHEAD(.DEV,.CONF,206,.H4,$GET(CTX("request_id")))
	. IF METHOD'="head" NEW OKR SET OKR=$$SENDRANGE(.DEV,.CONF,FS,RS,RLEN)
	. SET CTX("status")=206
	;
	; Full-body: stream using MIOHTTP sendfile (chunked).;
	; Note: MIOHTTP's RESP() forces Content-Length from BODY, so for full streaming we use SENDFILE.;
	NEW OK2 SET OK2=$$SENDFILE^MIOHTTP(.DEV,.CONF,FS,.HEAD,$GET(CTX("request_id")),.CTX,METHOD)
	IF 'OK2 DO
	. NEW OBJ SET OBJ("error")="not_found",OBJ("request_id")=$GET(CTX("request_id"))
	. DO RESPJSONX^MIOHTTP(.DEV,.CONF,404,.OBJ,$GET(CTX("request_id")),.CTX)
	. SET CTX("status")=404
	ELSE  SET CTX("status")=200
	QUIT
	;
; -------------------------------------------------------------------------
; Response header writer (does not override Content-Length)
RESPHEAD(DEV,CONF,STATUS,HEAD,REQID)
	NEW S SET S=+$GET(STATUS,200)
	NEW LINE SET LINE="HTTP/1.1 "_S_" "_$$SMSG(S)_$C(13,10)
	DO WRITE^MIOSOCK(DEV,LINE)
	NEW DH MERGE DH=CONF("server","http","defaultResponseHeaders")
	NEW K SET K=""
	FOR  SET K=$ORDER(DH(K)) QUIT:K=""  IF '$DATA(HEAD(K)) SET HEAD(K)=DH(K)
	IF REQID'="" SET HEAD("X-Request-Id")=REQID
	IF '$DATA(HEAD("Connection")) SET HEAD("Connection")="keep-alive"
	FOR  SET K=$ORDER(HEAD(K)) QUIT:K=""  DO WRITE^MIOSOCK(DEV,K_": "_HEAD(K)_$C(13,10))
	DO WRITE^MIOSOCK(DEV,$C(13,10))
	QUIT
	;
SMSG(S)
	QUIT $SELECT(S=200:"OK",S=206:"Partial Content",S=304:"Not Modified",S=404:"Not Found",S=416:"Range Not Satisfiable",S=500:"Internal Server Error",1:"")
	;
; -------------------------------------------------------------------------
; Path helpers
NORMMOUNT(M)
	NEW X SET X=$GET(M)
	IF X="" SET X="/static"
	IF $E(X,1)'="/" SET X="/"_X
	IF $L(X)>1,$E(X,$L(X))="/" SET X=$E(X,1,$L(X)-1)
	QUIT X
	;
URLDECPATH(S) ; percent-decoding for path (does NOT treat + as space)
	NEW IN,OUT,L,I,C,HEX,B
	SET IN=$GET(S)
	IF IN'["%" QUIT IN
	SET OUT="",L=$L(IN),I=1
	FOR  QUIT:I>L  DO
	. SET C=$E(IN,I)
	. IF C="%",(I+2)'>L DO  QUIT
	. . SET HEX=$E(IN,I+1,I+2)
	. . SET B=$$HEX2DEC^MIOHTTP(HEX)
	. . IF B'<0 SET OUT=OUT_$C(B),I=I+3 QUIT
	. . SET OUT=OUT_"%",I=I+1
	. SET OUT=OUT_C
	. SET I=I+1
	QUIT OUT
	;
SAFEJOIN(ROOT,RPATH,INDEX,OUT)
	; Prevent traversal. Reject "." and "..".;
	KILL OUT
	NEW R SET R=$GET(ROOT)
	NEW P SET P=$GET(RPATH)
	NEW I,SEG
	IF $E(P,1)="/" SET P=$E(P,2,999)
	IF P="" SET P=$GET(INDEX)
	IF P[$C(0) QUIT 0
	FOR I=1:1:$L(P,"/") DO
	. SET SEG=$P(P,"/",I)
	. IF SEG="" QUIT
	. IF SEG="."!(SEG="..") KILL OUT QUIT
	IF $E(R,$L(R))="/" SET R=$E(R,1,$L(R)-1)
	SET OUT=R_"/"_P
	IF $E(OUT,$L(OUT))="/" SET OUT=OUT_$GET(INDEX)
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" KILL OUT QUIT $SELECT($DATA(OUT):1,1:0)"
	OPEN OUT:(readonly)
	CLOSE OUT
	QUIT $SELECT($DATA(OUT):1,1:0)
	;
MIME(CONF,PATH)
	NEW EXT SET EXT=$$LOW^MIOHTTP($P($GET(PATH),".",$L(PATH,".")))
	IF EXT="" QUIT "application/octet-stream"
	IF $DATA(CONF("server","static","mime",EXT)) QUIT CONF("server","static","mime",EXT)
	QUIT $SELECT(EXT="html":"text/html; charset=utf-8",EXT="css":"text/css; charset=utf-8",EXT="js":"application/javascript; charset=utf-8",EXT="json":"application/json; charset=utf-8",EXT="png":"image/png",EXT="jpg":"image/jpeg",EXT="jpeg":"image/jpeg",EXT="gif":"image/gif",EXT="svg":"image/svg+xml",EXT="txt":"text/plain; charset=utf-8",EXT="ico":"image/x-icon",EXT="woff":"font/woff",EXT="woff2":"font/woff2",1:"application/octet-stream")
	;
; -------------------------------------------------------------------------
; ETag helpers (weak ETag: W/"len-adler32")
GETMETA(CONF,FS,META)
	KILL META
	NEW MAXB SET MAXB=+$GET(CONF("server","static","maxEtagBytes"),2097152)
	NEW TTL  SET TTL=+$GET(CONF("server","static","etagCacheSeconds"),30)
	IF TTL<0 SET TTL=0
	NEW NOWD SET NOWD=+$P($H,",",1)
	NEW NOWS SET NOWS=+$P($H,",",2)
	NEW CREF SET CREF=$NA(^MIO("STATIC","META",FS))
	IF TTL>0,$DATA(@CREF@("etag")),$DATA(@CREF@("tsd")),$DATA(@CREF@("tss")) DO
	. IF $$HDELTA(@CREF@("tsd"),@CREF@("tss"),NOWD,NOWS)'>TTL MERGE META=@CREF QUIT
	NEW DEV SET DEV=FS
	NEW CHSZ SET CHSZ=+$GET(CONF("server","static","etagChunkBytes"),65536)
	IF CHSZ<1024 SET CHSZ=1024
	IF CHSZ>262144 SET CHSZ=262144
	NEW LEN SET LEN=0
	NEW S1,S2 SET S1=1,S2=0
	NEW X
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" QUIT"
	OPEN DEV:(readonly:stream:nowrap)
	USE DEV
	FOR  DO  QUIT:$ZEOF  QUIT:LEN>MAXB
	. READ X#CHSZ
	. IF X="" QUIT
	. DO ADLERUP(.S1,.S2,X,.LEN,MAXB)
	CLOSE DEV
	IF LEN>MAXB SET META("etag")="" GOTO GMSTORE
	NEW MOD SET MOD=65521
	NEW A SET A=S1#MOD
	NEW B SET B=S2#MOD
	NEW SUM SET SUM=B*65536+A
	SET META("etag")="W/"""_LEN_"-"_SUM_""""
GMSTORE
	SET META("tsd")=NOWD,META("tss")=NOWS
	; store length for range reuse
	SET META("len")=$$FILESIZE(.CONF,FS)
	KILL @CREF MERGE @CREF=META
	QUIT
	;
HDELTA(D0,S0,D1,S1)
	QUIT (D1-D0)*86400+(S1-S0)
	;
ADLERUP(S1,S2,STR,LEN,MAXB)
	NEW MOD SET MOD=65521
	NEW I,CH,MX
	SET MX=MAXB-LEN
	IF MX'>0 SET LEN=LEN+1 QUIT
	NEW L SET L=$L(STR)
	IF L>MX SET STR=$E(STR,1,MX),L=MX
	FOR I=1:1:L DO
	. SET CH=$ASCII($E(STR,I))
	. SET S1=(S1+CH)#MOD
	. SET S2=(S2+S1)#MOD
	SET LEN=LEN+L
	QUIT
	;
ETAGMATCH(INM,ETAG)
	NEW Q S Q=0
	NEW X SET X=$$TRIM^MIOHTTP($GET(INM))
	IF X="*" QUIT 1
	NEW I,IT
	FOR I=1:1:$L(X,",") DO
	. SET IT=$$TRIM^MIOHTTP($P(X,",",I))
	. IF IT=ETAG S Q=1 QUIT 
	QUIT Q
	;
; -------------------------------------------------------------------------
; Range helpers (single range)
PARSERANGE(RNG,FSZ,RS,RE)
	NEW X SET X=$$TRIM^MIOHTTP($GET(RNG))
	IF X="" QUIT 0
	IF $$LOW^MIOHTTP($P(X,"=",1))'="bytes" QUIT 0
	SET X=$$TRIM^MIOHTTP($P(X,"=",2,999))
	IF X["," QUIT 0
	NEW A,B
	SET A=$P(X,"-",1),B=$P(X,"-",2,999)
	IF A="" QUIT $$RANGESUFF(B,FSZ,.RS,.RE)
	IF '$$ISNUM(A) QUIT 0
	SET RS=+A
	IF RS<0 QUIT 0
	IF B="" SET RE=FSZ-1 QUIT $$RANGEVAL(FSZ,.RS,.RE)
	IF '$$ISNUM(B) QUIT 0
	SET RE=+B
	QUIT $$RANGEVAL(FSZ,.RS,.RE)
	;
RANGESUFF(B,FSZ,RS,RE)
	IF B="" QUIT 0
	IF '$$ISNUM(B) QUIT 0
	NEW S SET S=+B
	IF S'>0 QUIT 0
	IF S>FSZ SET S=FSZ
	SET RS=FSZ-S
	SET RE=FSZ-1
	QUIT $$RANGEVAL(FSZ,.RS,.RE)
	;
RANGEVAL(FSZ,RS,RE)
	IF FSZ<0 QUIT 0
	IF RS'<FSZ QUIT 0
	IF RE<RS QUIT 0
	IF RE'<FSZ SET RE=FSZ-1
	QUIT 1
	;
ISNUM(X)
	NEW Y SET Y=$GET(X)
	IF Y="" QUIT 0
	IF Y'?1.N QUIT 0
	QUIT 1
	;
FILESIZE(CONF,FS)
	; Returns file size in bytes, or -1 on error.;
	NEW TTL SET TTL=+$GET(CONF("server","static","etagCacheSeconds"),30)
	IF TTL<0 SET TTL=0
	NEW NOWD SET NOWD=+$P($H,",",1)
	NEW NOWS SET NOWS=+$P($H,",",2)
	NEW CREF SET CREF=$NA(^MIO("STATIC","META",FS))
	IF TTL>0,$DATA(@CREF@("len")),$DATA(@CREF@("tsd")),$DATA(@CREF@("tss")),$$HDELTA(@CREF@("tsd"),@CREF@("tss"),NOWD,NOWS)'>TTL QUIT @CREF@("len")
	NEW DEV SET DEV=FS
	NEW CHSZ SET CHSZ=+$GET(CONF("server","static","etagChunkBytes"),65536)
	IF CHSZ<1024 SET CHSZ=1024
	IF CHSZ>262144 SET CHSZ=262144
	NEW LEN SET LEN=0
	NEW X
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" QUIT -1"
	OPEN DEV:(readonly:stream:nowrap)
	USE DEV
	FOR  DO  QUIT:$ZEOF
	. READ X#CHSZ
	. SET LEN=LEN+$L(X)
	CLOSE DEV
	SET @CREF@("len")=LEN
	SET @CREF@("tsd")=NOWD,@CREF@("tss")=NOWS
	QUIT LEN
	;
SENDRANGE(DEV,CONF,FS,OFF,LEN)
	; Streams LEN bytes from file FS starting at offset OFF (0-based).;
	NEW CHSZ SET CHSZ=+$GET(CONF("server","static","readChunkBytes"),65536)
	IF CHSZ<1024 SET CHSZ=1024
	IF CHSZ>262144 SET CHSZ=262144
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" QUIT 0"
	OPEN FS:(readonly:stream:nowrap)
	USE FS
	; skip OFF bytes
	NEW SK SET SK=OFF
	NEW X,N
	FOR  QUIT:SK'>0  DO  QUIT:$ZEOF
	. SET N=$SELECT(SK>CHSZ:CHSZ,1:SK)
	. READ X#N
	. SET SK=SK-$L(X)
	IF SK>0 CLOSE FS QUIT 0
	; send LEN bytes
	NEW REM SET REM=LEN
	FOR  QUIT:REM'>0  DO  QUIT:$ZEOF
	. SET N=$SELECT(REM>CHSZ:CHSZ,1:REM)
	. READ X#N
	. IF $L(X)=0 CLOSE FS QUIT 0
	. DO WRITE^MIOSOCK(DEV,X)
	. SET REM=REM-$L(X)
	CLOSE FS
	QUIT $SELECT(REM=0:1,1:0)
	;