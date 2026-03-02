MIOSTATIC ; Static file serving (ETag + Range + If-Modified-Since)
	;
	; PUBLIC
	;   REG(.CONF)                 - optional route registration
	;   STATIC(DEV,CONF,REQ,CTX)   - handler for GET/HEAD /static/*path
	;
	; Goals
	; - MAXSTRING-safe streaming.;
	; - Production-grade conditional GET (ETag, If-Modified-Since).;
	; - Single-range support (206/416).;
	;
	; Pragmatic mtime strategy
	; - Primary: server-known mtime under ^MIO("STATIC","META",FS,"mhd"/"mhs")
	; - Optional: CONF("server","static","mtimeProvider")="LABEL^ROUTINE"
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
	SET RPATH=$$URLDECPATH(RPATH)
	IF RPATH="" SET RPATH=INDEX
	;
	; Secure join
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
	SET HEAD("Accept-Ranges")="bytes"
	;
	; --- ETag / If-None-Match (first) -------------------------------------
	NEW META,ETAG
	DO GETMETA(.CONF,FS,.META)
	SET ETAG=$GET(META("etag"))
	IF ETAG'="" SET HEAD("ETag")=ETAG
	NEW INM SET INM=$GET(REQ("hdr","if-none-match"))
	IF ETAG'="",INM'="",$$ETAGMATCH(INM,ETAG) DO  QUIT
	. NEW H2 MERGE H2=HEAD
	. SET H2("Content-Length")=0
	. DO RESPHEAD(.DEV,.CONF,304,.H2,$GET(CTX("request_id")))
	. SET CTX("status")=304
	;
	;
	; --- Last-Modified / If-Modified-Since (second) -----------------------
	NEW MHD,MHS,LM,MGOT SET MHD="",MHS="",LM="",MGOT=0
	SET MGOT=$$GETMTIME(.CONF,FS,.MHD,.MHS,.LM)
	; Pragmatic fallback: if no mtime is known for this file, seed it once.;
	IF 'MGOT DO
	. SET MHD=+$P($H,",",1),MHS=+$P($H,",",2)
	. DO SETMTIME(FS,MHD,MHS)
	. SET LM=$$HTTPDATE(MHD,MHS)
	. SET MGOT=1
	IF MGOT DO
	. IF LM="",$GET(MHD)'="" SET LM=$$HTTPDATE(MHD,MHS)
	. IF LM'="" SET HEAD("Last-Modified")=LM
	. NEW IMS SET IMS=$GET(REQ("hdr","if-modified-since")) 
	. NEW IHD,IHS
	. IF IMS'="",$$PARSEHTTPDATE(IMS,.IHD,.IHS) DO
	. . ; If resource time <= IMS then not modified
	. . IF $$CMPH(MHD,MHS,IHD,IHS) DO
	. . . NEW HLM MERGE HLM=HEAD
	. . . SET HLM("Content-Length")=0
	. . . DO RESPHEAD(.DEV,.CONF,304,.HLM,$GET(CTX("request_id")))
	. . . SET CTX("status")=304
	IF $GET(CTX("status"))=304 QUIT
	; --- Range (single) ---------------------------------------------------
	NEW RNG SET RNG=$GET(REQ("hdr","range"))
	IF RNG'="" DO  QUIT:$GET(CTX("status"))>0
	. NEW FSZ,ROK,RS,RE,RLEN
	. SET FSZ=$$FILESIZE(.CONF,FS)
	. IF FSZ<0 QUIT
	. SET ROK=$$PARSERANGE(RNG,FSZ,.RS,.RE)
	. IF 'ROK DO  QUIT
	. . NEW H3 MERGE H3=HEAD
	. . SET H3("Content-Range")="bytes */"_FSZ
	. . SET H3("Content-Length")=0
	. . DO RESPHEAD(.DEV,.CONF,416,.H3,$GET(CTX("request_id")))
	. . SET CTX("status")=416
	. SET RLEN=RE-RS+1
	. NEW H4 MERGE H4=HEAD
	. SET H4("Content-Range")="bytes "_RS_"-"_RE_"/"_FSZ
	. SET H4("Content-Length")=RLEN
	. DO RESPHEAD(.DEV,.CONF,206,.H4,$GET(CTX("request_id")))
	. IF METHOD'="head" NEW OKR SET OKR=$$SENDRANGE(.DEV,.CONF,FS,RS,RLEN)
	. SET CTX("status")=206
	;
	; --- Full-body 200 ----------------------------------------------------
	NEW FSZ200 SET FSZ200=$$FILESIZE(.CONF,FS)
	IF FSZ200'<0 DO  QUIT
	. NEW H200 MERGE H200=HEAD
	. SET H200("Content-Length")=FSZ200
	. DO RESPHEAD(.DEV,.CONF,200,.H200,$GET(CTX("request_id")))
	. IF METHOD'="head" NEW OK200 SET OK200=$$SENDRANGE(.DEV,.CONF,FS,0,FSZ200)
	. SET CTX("status")=200
	;
	; Fallback: unknown size -> chunked sendfile via MIOHTTP
	NEW OK2 SET OK2=$$SENDFILE^MIOHTTP(.DEV,.CONF,FS,.HEAD,$GET(CTX("request_id")),.CTX,METHOD)
	IF 'OK2 DO
	. NEW OBJ SET OBJ("error")="not_found",OBJ("request_id")=$GET(CTX("request_id"))
	. DO RESPJSONX^MIOHTTP(.DEV,.CONF,404,.OBJ,$GET(CTX("request_id")),.CTX)
	. SET CTX("status")=404
	ELSE  SET CTX("status")=200
	QUIT
	;
; -------------------------------------------------------------------------
; Response headers (file-safe; does not override Content-Length)
RESPHEAD(DEV,CONF,STATUS,HEAD,REQID)
	NEW S SET S=+$GET(STATUS,200)
	DO WOUT(.DEV,"HTTP/1.1 "_S_" "_$$SMSG(S)_$C(13,10))
	NEW DH MERGE DH=CONF("server","http","defaultResponseHeaders")
	NEW K SET K=""
	FOR  SET K=$ORDER(DH(K)) QUIT:K=""  IF '$DATA(HEAD(K)) SET HEAD(K)=DH(K)
	IF REQID'="" SET HEAD("X-Request-Id")=REQID
	IF '$DATA(HEAD("Connection")) SET HEAD("Connection")="keep-alive"
	FOR  SET K=$ORDER(HEAD(K)) QUIT:K=""  DO WOUT(.DEV,K_": "_HEAD(K)_$C(13,10))
	DO WOUT(.DEV,$C(13,10))
	QUIT
	;
SMSG(S)
	QUIT $SELECT(S=200:"OK",S=206:"Partial Content",S=304:"Not Modified",S=404:"Not Found",S=416:"Range Not Satisfiable",1:"")
	;
WOUT(DEV,STR)
	NEW D SET D=$GET(DEV) IF D="" SET D=$IO
	NEW OIO SET OIO=$IO
	IF $E(D,1)="/"  GOTO WFILE
	IF $TEXT(WRITE^MIOSOCK)'=""  GOTO WSOCK
WFILE
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" USE OIO QUIT"
	USE D WRITE STR
	USE OIO
	QUIT
WSOCK
	NEW OK SET OK=1
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" SET OK=0"
	DO WRITE^MIOSOCK(D,STR)
	IF OK USE OIO QUIT
	GOTO WFILE
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
URLDECPATH(S)
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
; ETag helpers (do NOT clobber mtime keys)
GETMETA(CONF,FS,META)
	KILL META
	NEW MAXB SET MAXB=+$GET(CONF("server","static","maxEtagBytes"),2097152)
	NEW TTL  SET TTL=+$GET(CONF("server","static","etagCacheSeconds"),30)
	IF TTL<0 SET TTL=0
	NEW NOWD SET NOWD=+$P($H,",",1)
	NEW NOWS SET NOWS=+$P($H,",",2)
	NEW CREF SET CREF=$NA(^MIO("STATIC","META",FS))
	IF TTL>0,$DATA(@CREF@("etag")),$DATA(@CREF@("tsd")),$DATA(@CREF@("tss")) DO
	. IF $$HDELTA(@CREF@("tsd"),@CREF@("tss"),NOWD,NOWS)'>TTL DO  QUIT
	. . MERGE META=@CREF
	;
	NEW CHSZ SET CHSZ=+$GET(CONF("server","static","etagChunkBytes"),65536)
	IF CHSZ<1024 SET CHSZ=1024
	IF CHSZ>262144 SET CHSZ=262144
	NEW LEN SET LEN=0
	NEW S1,S2 SET S1=1,S2=0
	NEW X
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" QUIT"
	OPEN FS:(readonly:stream:nowrap)
	USE FS
	FOR  DO  QUIT:$ZEOF  QUIT:LEN>MAXB
	. READ X#CHSZ
	. IF X="" QUIT
	. DO ADLERUP(.S1,.S2,X,.LEN,MAXB)
	CLOSE FS
	IF LEN>MAXB SET META("etag")="" GOTO GMSTORE
	NEW MOD SET MOD=65521
	NEW A SET A=S1#MOD
	NEW B SET B=S2#MOD
	NEW SUM SET SUM=B*65536+A
	SET META("etag")="W/"""_LEN_"-"_SUM_""""
GMSTORE
	SET META("tsd")=NOWD,META("tss")=NOWS
	SET META("len")=$$FILESIZE(.CONF,FS)
	; Store only ETag fields (preserve mhd/mhs/lm)
	SET @CREF@("etag")=META("etag")
	SET @CREF@("tsd")=META("tsd")
	SET @CREF@("tss")=META("tss")
	SET @CREF@("len")=META("len")
	QUIT
	;
HDELTA(D0,S0,D1,S1)
	QUIT (D1-D0)*86400+(S1-S0)
	;
ADLERUP(S1,S2,STR,LEN,MAXB)
	NEW MOD SET MOD=65521
	NEW I,CH,MX,L
	SET MX=MAXB-LEN
	IF MX'>0 SET LEN=LEN+1 QUIT
	SET L=$L(STR)
	IF L>MX SET STR=$E(STR,1,MX),L=MX
	FOR I=1:1:L DO
	. SET CH=$ASCII($E(STR,I))
	. SET S1=(S1+CH)#MOD
	. SET S2=(S2+S1)#MOD
	SET LEN=LEN+L
	QUIT
	;
ETAGMATCH(INM,ETAG)
	NEW X,Q S Q=0 SET X=$$TRIM^MIOHTTP($GET(INM))
	IF X="*" QUIT 1
	NEW I,IT
	FOR I=1:1:$L(X,",") DO
	. SET IT=$$TRIM^MIOHTTP($P(X,",",I))
	. IF IT=ETAG S Q=1 QUIT
	QUIT Q
	;
; -------------------------------------------------------------------------
; If-Modified-Since helpers
GETMTIME(CONF,FS,MHD,MHS,LM)
	I $D(^MIO("STATIC","META",FS)) D
	. SET MHD=+$GET(^MIO("STATIC","META",FS,"mhd"))
	. SET MHS=+$GET(^MIO("STATIC","META",FS,"mhs"))
	. SET LM=$GET(^MIO("STATIC","META",FS,"lm"))
	IF MHD,MHS,LM="" SET LM=$$HTTPDATE(MHD,MHS),^MIO("STATIC","META",FS,"lm")=LM
	IF $GET(MHD)'="" QUIT 1
	QUIT 0
	;NEW PROV SET PROV=$GET(CONF("server","static","mtimeProvider"))
	;IF PROV'="" DO
	;. NEW OK SET OK=0
	;. NEW $ETRAP SET $ETRAP="SET $ECODE="""" SET OK=0"
	;. SET OK=$$@PROV@(FS,.MHD,.MHS,.LM,.CONF)
	;. IF 'OK KILL MHD,MHS,LM
	;IF +$GET(MHD)'="" QUIT 1
	;NEW CREF SET CREF=$NA(^MIO("STATIC","META",FS))
	;IF $DATA(@CREF@("mhd")),$DATA(@CREF@("mhs")) DO
	;. SET MHD=+$GET(@CREF@("mhd"))
	;. SET MHS=+$GET(@CREF@("mhs"))
	;. SET LM=$GET(@CREF@("lm"))
	;. IF LM="" SET LM=$$HTTPDATE(MHD,MHS),@CREF@("lm")=LM
	;IF +$GET(MHD)'="" QUIT 1
	;QUIT 0
	;
SETMTIME(FS,MHD,MHS)
	NEW CREF SET CREF=$NA(^MIO("STATIC","META",FS))
	SET @CREF@("mhd")=+$GET(MHD)
	SET @CREF@("mhs")=+$GET(MHS)
	SET @CREF@("lm")=$$HTTPDATE(+$GET(MHD),+$GET(MHS))
	QUIT
	;
CMPH(D1,S1,D2,S2)
	IF D1<D2 QUIT 0
	IF D1>D2 QUIT 1
	IF S1<S2 QUIT 0
	IF S1>S2 QUIT 1
	QUIT 0
	;
PARSEHTTPDATE(STR,HD,HS)
	NEW X SET X=$$TRIM^MIOHTTP($GET(STR))
	IF X="" QUIT 0
	IF X["," SET X=$$TRIM^MIOHTTP($P(X,",",2,999))
	NEW DD,MON,YYYY,TIME,HH,MM,SS,MN
	SET DD=$P(X," ",1),MON=$P(X," ",2),YYYY=$P(X," ",3),TIME=$P(X," ",4)
	IF DD=""!(MON="")!(YYYY="")!(TIME="") QUIT 0
	IF DD'?1.2N QUIT 0
	IF YYYY'?4N QUIT 0
	SET MN=$$MONNUM(MON) IF MN<1 QUIT 0
	SET HH=$P(TIME,":",1),MM=$P(TIME,":",2),SS=$P(TIME,":",3)
	IF HH'?1.2N!(MM'?1.2N)!(SS'?1.2N) QUIT 0
	IF +HH>23!(+MM>59)!(+SS>59) QUIT 0
	SET HD=$$YMD2H(+YYYY,MN,+DD)
	SET HS=(+HH*3600)+(+MM*60)+(+SS)
	QUIT 1
	;
MONNUM(MON)
	NEW M SET M=$$LOW^MIOHTTP($GET(MON))
	QUIT $SELECT(M="jan":1,M="feb":2,M="mar":3,M="apr":4,M="may":5,M="jun":6,M="jul":7,M="aug":8,M="sep":9,M="oct":10,M="nov":11,M="dec":12,1:-1)
	;
HTTPDATE(HD,HS)
	NEW Y,M,D DO H2YMD(HD,.Y,.M,.D)
	NEW HH,MM,SS
	SET HH=HS\3600,MM=(HS#3600)\60,SS=HS#60
	NEW DOW SET DOW=$$DOWNAME((HD+4)#7)
	NEW MON SET MON=$$MONNAME(M)
	QUIT DOW_", "_$$PAD2(D)_" "_MON_" "_$$PAD4(Y)_" "_$$PAD2(HH)_":"_$$PAD2(MM)_":"_$$PAD2(SS)_" GMT"
	;
DOWNAME(I) QUIT $SELECT(I=0:"Sun",I=1:"Mon",I=2:"Tue",I=3:"Wed",I=4:"Thu",I=5:"Fri",I=6:"Sat",1:"Sun")
MONNAME(M) QUIT $SELECT(M=1:"Jan",M=2:"Feb",M=3:"Mar",M=4:"Apr",M=5:"May",M=6:"Jun",M=7:"Jul",M=8:"Aug",M=9:"Sep",M=10:"Oct",M=11:"Nov",M=12:"Dec",1:"Jan")
PAD2(N) NEW X SET X=+$GET(N) QUIT $SELECT(X<10:"0"_X,1:X)
PAD4(N) NEW S SET S=+$GET(N) QUIT $SELECT($L(S)=4:S,$L(S)=3:"0"_S,$L(S)=2:"00"_S,$L(S)=1:"000"_S,1:S)
	;
YMD2H(Y,M,D)
	NEW YY SET YY=+Y,MM=+M,DD=+D
	NEW Y0 SET Y0=YY IF MM'>2 SET Y0=Y0-1
	NEW ERA SET ERA=Y0\400
	NEW YOE SET YOE=Y0-(ERA*400)
	NEW MP SET MP=MM+$SELECT(MM>2:-3,1:9)
	NEW DOY SET DOY=((153*MP+2)\5)+DD-1
	NEW DOE SET DOE=(YOE*365)+(YOE\4)-(YOE\100)+DOY
	NEW Z SET Z=(ERA*146097)+DOE-719468
	QUIT Z+47117
	;
H2YMD(HD,Y,M,D)
	NEW Z SET Z=+HD-47117
	SET Z=Z+719468
	NEW ERA SET ERA=Z\146097
	NEW DOE SET DOE=Z-(ERA*146097)
	NEW YOE SET YOE=(DOE-(DOE\1460)+(DOE\36524)-(DOE\146096))\365
	SET Y=YOE+(ERA*400)
	NEW DOY SET DOY=DOE-((365*YOE)+(YOE\4)-(YOE\100))
	NEW MP SET MP=(5*DOY+2)\153
	SET D=DOY-((153*MP+2)\5)+1
	SET M=MP+$SELECT(MP<10:3,1:-9)
	SET Y=Y+$SELECT(M'>2:1,1:0)
	QUIT
	;
; -------------------------------------------------------------------------
; Range helpers
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
	NEW TTL SET TTL=+$GET(CONF("server","static","etagCacheSeconds"),30)
	IF TTL<0 SET TTL=0
	NEW NOWD SET NOWD=+$P($H,",",1)
	NEW NOWS SET NOWS=+$P($H,",",2)
	NEW CREF SET CREF=$NA(^MIO("STATIC","META",FS))
	IF TTL>0,$DATA(@CREF@("len")),$DATA(@CREF@("tsd")),$DATA(@CREF@("tss")),$$HDELTA(@CREF@("tsd"),@CREF@("tss"),NOWD,NOWS)'>TTL QUIT @CREF@("len")
	NEW CHSZ SET CHSZ=+$GET(CONF("server","static","etagChunkBytes"),65536)
	IF CHSZ<1024 SET CHSZ=1024
	IF CHSZ>262144 SET CHSZ=262144
	NEW LEN SET LEN=0
	NEW X
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" QUIT -1"
	OPEN FS:(readonly:stream:nowrap)
	USE FS
	FOR  DO  QUIT:$ZEOF
	. READ X#CHSZ
	. SET LEN=LEN+$L(X)
	CLOSE FS
	SET @CREF@("len")=LEN
	SET @CREF@("tsd")=NOWD
	SET @CREF@("tss")=NOWS
	QUIT LEN
	;
SENDRANGE(DEV,CONF,FS,OFF,LEN)
	NEW CHSZ SET CHSZ=+$GET(CONF("server","static","readChunkBytes"),65536)
	IF CHSZ<1024 SET CHSZ=1024
	IF CHSZ>262144 SET CHSZ=262144
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" QUIT 0"
	OPEN FS:(readonly:stream:nowrap)
	USE FS
	NEW SK SET SK=OFF
	NEW X,N
	FOR  QUIT:SK'>0  DO  QUIT:$ZEOF
	. SET N=$SELECT(SK>CHSZ:CHSZ,1:SK)
	. READ X#N
	. SET SK=SK-$L(X)
	IF SK>0 CLOSE FS QUIT 0
	NEW REM SET REM=LEN
	FOR  QUIT:REM'>0  DO  QUIT:$ZEOF
	. SET N=$SELECT(REM>CHSZ:CHSZ,1:REM)
	. READ X#N
	. IF $L(X)=0 CLOSE FS QUIT 0
	. DO WOUT(.DEV,X)
	. SET REM=REM-$L(X)
	CLOSE FS
	QUIT $SELECT(REM=0:1,1:0)
	;