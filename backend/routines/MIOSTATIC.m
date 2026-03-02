MIOSTATIC ; Static file serving (sendfile + secure path join + ETag)
	;
	; Public
	;   REG(.CONF)                       ; optional route registration
	;   STATIC(DEV,CONF,REQ,CTX)         ; handler for GET/HEAD /static/*path
	;
	; Config (CONF)
	;   CONF("server","static","enabled")=1              ; default 0
	;   CONF("server","static","root")="public"          ; default "public"
	;   CONF("server","static","mount")="/static"        ; default "/static"
	;   CONF("server","static","index")="index.html"     ; default "index.html"
	;   CONF("server","static","readChunkBytes")=65536   ; sendfile chunk size
	;   CONF("server","static","mime",ext)=mimeType
	;
	; ETag (ROI)
	;   CONF("server","static","maxEtagBytes")=2097152       ; default 2MB
	;   CONF("server","static","etagCacheSeconds")=30        ; default 30s
	;   CONF("server","static","etagChunkBytes")=65536       ; default 64KB
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
	; ETag / If-None-Match (ROI)
	NEW META,ETAG
	DO GETMETA(.CONF,FS,.META)
	SET ETAG=$GET(META("etag"))
	IF ETAG'="" SET HEAD("ETag")=ETAG
	NEW INM SET INM=$GET(REQ("hdr","if-none-match"))
	IF ETAG'="",INM'="",$$ETAGMATCH(INM,ETAG) DO  QUIT
	. NEW H2 MERGE H2=HEAD
	. KILL H2("Transfer-Encoding"),H2("Content-Length")
	. DO RESPX^MIOHTTP(.DEV,.CONF,304,.H2,"",$GET(CTX("request_id")),.CTX)
	. SET CTX("status")=304
	;
	; Stream file using MIOHTTP sendfile
	NEW OK2 SET OK2=$$SENDFILE^MIOHTTP(.DEV,.CONF,FS,.HEAD,$GET(CTX("request_id")),.CTX,METHOD)
	IF 'OK2 DO
	. NEW OBJ SET OBJ("error")="not_found",OBJ("request_id")=$GET(CTX("request_id"))
	. DO RESPJSONX^MIOHTTP(.DEV,.CONF,404,.OBJ,$GET(CTX("request_id")),.CTX)
	. SET CTX("status")=404
	ELSE  SET CTX("status")=200
	QUIT
	;
; --- helpers -------------------------------------------------------------
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
	; Reject NUL
	IF P[$C(0) QUIT 0
	FOR I=1:1:$L(P,"/") DO
	. SET SEG=$P(P,"/",I)
	. IF SEG="" QUIT
	. IF SEG="."!(SEG="..") KILL OUT QUIT
	IF $E(R,$L(R))="/" SET R=$E(R,1,$L(R)-1)
	SET OUT=R_"/"_P
	IF $E(OUT,$L(OUT))="/" SET OUT=OUT_$GET(INDEX)
	; Existence check (open)
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" KILL OUT QUIT 0"
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
; --- ETag helpers (ROI) -------------------------------------------------
GETMETA(CONF,FS,META)
	; Computes META("etag") for small files and caches briefly.;
	KILL META
	NEW MAXB SET MAXB=+$GET(CONF("server","static","maxEtagBytes"),2097152)
	NEW TTL  SET TTL=+$GET(CONF("server","static","etagCacheSeconds"),30)
	IF TTL<0 SET TTL=0
	NEW NOWD SET NOWD=+$P($H,",",1)
	NEW NOWS SET NOWS=+$P($H,",",2)
	NEW CREF SET CREF=$NA(^MIO("STATIC","META",FS))
	IF TTL>0,$DATA(@CREF) DO
	. NEW TD SET TD=+$GET(@CREF@("tsd"))
	. NEW TS SET TS=+$GET(@CREF@("tss"))
	. IF $$HDELTA(TD,TS,NOWD,NOWS)'>TTL MERGE META=@CREF QUIT
	;
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
	IF X="*" S Q=1 QUIT Q
	NEW I,IT
	FOR I=1:1:$L(X,",") DO
	. SET IT=$$TRIM^MIOHTTP($P(X,",",I))
	. IF IT=ETAG S Q=1 QUIT
	QUIT Q
	;