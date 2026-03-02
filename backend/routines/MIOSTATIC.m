MIOSTATIC ; Static file serving (sendfile + secure path join)
	;
	; Public:
	;   REG(.CONF)                       ; registers routes (optional)
	;   STATIC(DEV,CONF,REQ,CTX)         ; handler for GET/HEAD /static/*path
	;
	; Config:
	;   CONF("server","static","enabled")=1        ; default 0
	;   CONF("server","static","root")="public"    ; default "public"
	;   CONF("server","static","mount")="/static"  ; default "/static"
	;   CONF("server","static","index")="index.html"
	;   CONF("server","static","readChunkBytes")=65536
	;   CONF("server","static","mime",ext)="type/subtype"
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
	NEW ROOT SET ROOT=$GET(CONF("server","static","root"),"public")
	NEW INDEX SET INDEX=$GET(CONF("server","static","index"),"index.html")
	NEW METHOD SET METHOD=$$LOW^MIOHTTP($GET(REQ("method")))
	IF METHOD="" SET METHOD="get"
	;
	; Resolve relative path under mount
	NEW RPATH SET RPATH=$GET(REQ("params","path"))
	IF RPATH="" DO
	. ; fallback: strip mount from REQ("path")
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
	; Stream file using MIOHTTP chunked sendfile
	NEW OK2 SET OK2=$$SENDFILE^MIOHTTP(.DEV,.CONF,FS,.HEAD,$GET(CTX("request_id")),.CTX,METHOD)
	IF 'OK2 DO
	. NEW OBJ SET OBJ("error")="not_found",OBJ("request_id")=$GET(CTX("request_id"))
	. DO RESPJSONX^MIOHTTP(.DEV,.CONF,404,.OBJ,$GET(CTX("request_id")),.CTX)
	. SET CTX("status")=404
	ELSE  SET CTX("status")=200
	QUIT
	;
; --- helpers ---
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
	; Prevent traversal. Allows only segments that are not "." or "..".;
	NEW R SET R=$GET(ROOT)
	NEW P SET P=$GET(RPATH)
	NEW I,SEG,OK
	SET OK=1
	; normalize slashes
	IF $E(P,1)="/" SET P=$E(P,2,999)
	IF P="" SET P=$GET(INDEX)
	; check segments
	FOR I=1:1:$L(P,"/") DO  QUIT:'OK
	. SET SEG=$P(P,"/",I)
	. IF SEG="" QUIT
	. IF SEG="."!(SEG="..") SET OK=0 QUIT
	. IF SEG[$C(0) SET OK=0 QUIT
	IF 'OK QUIT 0
	; build path
	IF $E(R,$L(R))="/" SET R=$E(R,1,$L(R)-1)
	SET OUT=R_"/"_P
	IF $E(OUT,$L(OUT))="/" SET OUT=OUT_$GET(INDEX)
	; existence check (open test)
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" SET OK=0"
	OPEN OUT:(readonly)
	CLOSE OUT
	QUIT OK
	;
	;
MIME(CONF,PATH)
	NEW EXT SET EXT=$$LOW^MIOHTTP($P($GET(PATH),".",$L(PATH,".")))
	IF EXT="" QUIT "application/octet-stream"
	IF $DATA(CONF("server","static","mime",EXT)) QUIT CONF("server","static","mime",EXT)
	QUIT $SELECT(EXT="html":"text/html; charset=utf-8",EXT="css":"text/css; charset=utf-8",EXT="js":"application/javascript; charset=utf-8",EXT="json":"application/json; charset=utf-8",EXT="png":"image/png",EXT="jpg":"image/jpeg",EXT="jpeg":"image/jpeg",EXT="gif":"image/gif",EXT="svg":"image/svg+xml",EXT="txt":"text/plain; charset=utf-8",EXT="ico":"image/x-icon",EXT="woff":"font/woff",EXT="woff2":"font/woff2",1:"application/octet-stream")
	;