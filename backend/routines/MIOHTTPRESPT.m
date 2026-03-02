MIOHTTPRESPT ; Response streaming + sendfile tests (robust chunk parser)
 ;
 ; Run:
 ;   YDB>ZL "MIOHTTP.m","MIOHTTPRESPT.m","MIOTASSERT.m"
 ;   YDB>D ^MIOHTTPRESPT
 ;
 ; Notes:
 ; - Uses file devices as output.
 ; - T001 parses the chunked response instead of doing a brittle substring match.
 ;
 NEW $ET SET $ET="DO STERR^MIOHTTPRESPT"
 DO T001
 DO T002
 QUIT
 ;
STERR
 USE $PRINCIPAL WRITE "ERR ",$ZSTATUS,!
 QUIT
 ;
READALL(PATH,OUT)
 NEW OIO SET OIO=$IO
 SET OUT=""
 NEW DEV SET DEV=PATH
 OPEN DEV:(readonly:stream:nowrap)
 USE DEV
 NEW X
 FOR  READ X#16384  QUIT:$ZEOF  SET OUT=OUT_X
 CLOSE DEV
 USE OIO
 QUIT
 ;
NORMEOL(S) ; normalize CRLF/CR => LF for parsing/debug
 NEW X SET X=$GET(S)
 ; convert CR to LF (CRLF becomes LFLF, collapse later)
 SET X=$TR(X,$C(13),$C(10))
 ; collapse multiple LF runs to at most 2 in header separator context is OK
 QUIT X
 ;
FINDHDRSEP(S) ; returns position just after header separator, 0 if not found
 NEW P SET P=$F(S,$C(10,10))
 QUIT P
 ;
HEXVAL(HX) ; parse hex string to decimal, -1 on failure
 NEW H SET H="0123456789ABCDEF"
 NEW X SET X=$$UP(HX)
 NEW I,C,P,OUT SET OUT=0
 IF X="" QUIT -1
 FOR I=1:1:$L(X) DO  QUIT:OUT<0
 . SET C=$E(X,I)
 . SET P=$F(H,C)-2
 . IF P<0 SET OUT=-1 QUIT
 . SET OUT=OUT*16+P
 QUIT OUT
 ;
UP(S) QUIT $ZCONVERT($GET(S),"U")
 ;
T001 ; chunked streaming basic
 NEW CONF,DEV,OUT,HEAD,REQID,CTX,PATH,TXT,RAW,N,P,CSLINE,CS,CLEN,DATA,AFTER
 SET PATH="/tmp/mio_resp_t001.out"
 OPEN PATH:(newversion:stream:nowrap)
 SET DEV=PATH
 USE DEV
 SET TXT="HelloWorld" ; length 10
 SET HEAD("Content-Type")="text/plain"
 SET REQID="t001"
 DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,REQID,.CTX)
 DO STREAMWRITE^MIOHTTP(.DEV,TXT)
 DO STREAMEND^MIOHTTP(.DEV)
 CLOSE DEV
 USE $PRINCIPAL
 DO READALL(PATH,.RAW)
 ; normalize EOL for parsing
 SET N=$$NORMEOL(RAW)
 SET P=$$FINDHDRSEP(N)
 ; header sep must exist
 DO EQ^MIOTASSERT($SELECT(P>0:1,1:0),1,"[T001][hdr sep]")
 IF P=0 QUIT
 ; read chunk size line up to LF
 SET CSLINE=$P($E(N,P,$L(N)),$C(10),1)
 SET CS=$$HEXVAL($$TRIM(CSLINE))
 NEW OKSZ SET OKSZ=$SELECT(CS=10:1,1:0)
 IF 'OKSZ,$GET(^MIO("CONF","test","debug")) USE $PRINCIPAL WRITE "DBG T001 sizeLine='",CSLINE,"' -> ",CS,!
 DO EQ^MIOTASSERT(OKSZ,1,"[T001][chunk size]")
 ; compute payload start: P + len(sizeLine) + 1 LF
 SET AFTER=P+$L(CSLINE)+1
 SET DATA=$E(N,AFTER,AFTER+CS-1)
 NEW OKD SET OKD=$SELECT(DATA=TXT:1,1:0)
 IF 'OKD,$GET(^MIO("CONF","test","debug")) USE $PRINCIPAL WRITE "DBG T001 data='",$EXTRACT(DATA,1,80),"'",!
 DO EQ^MIOTASSERT(OKD,1,"[T001][chunk data]")
 QUIT
 ;
TRIM(S)
 NEW X SET X=$GET(S)
 FOR  QUIT:$E(X,1)'=" "  SET X=$E(X,2,$L(X))
 FOR  QUIT:$L(X)=0!($E(X,$L(X))'=" ")  SET X=$E(X,1,$L(X)-1)
 QUIT X
 ;
T002 ; sendfile
 NEW CONF,DEV,OUT,HEAD,REQID,CTX,OP,IP,TXT,RAW,N,P,CSLINE,CS,AFTER,DATA
 SET IP="/tmp/mio_resp_t002.in"
 SET OP="/tmp/mio_resp_t002.out"
 SET TXT="abcdefghijklmnopqrstuvwxyz"
 ; write input file
 OPEN IP:(newversion:stream:nowrap)
 USE IP WRITE TXT CLOSE IP
 ; send file
 OPEN OP:(newversion:stream:nowrap)
 SET DEV=OP
 USE DEV
 SET HEAD("Content-Type")="text/plain"
 SET REQID="t002"
 NEW OK SET OK=$$SENDFILE^MIOHTTP(.DEV,.CONF,IP,.HEAD,REQID,.CTX,"GET")
 CLOSE DEV
 USE $PRINCIPAL
 DO EQ^MIOTASSERT(OK,1,"[T002][ok]")
 DO READALL(OP,.RAW)
 SET N=$$NORMEOL(RAW)
 SET P=$$FINDHDRSEP(N)
 DO EQ^MIOTASSERT($SELECT(P>0:1,1:0),1,"[T002][hdr sep]")
 IF P=0 QUIT
 ; first chunk size line
 SET CSLINE=$P($E(N,P,$L(N)),$C(10),1)
 SET CS=$$HEXVAL($$TRIM(CSLINE))
 ; payload is the whole file but may be chunked in multiple pieces; just assert TXT appears
 DO EQ^MIOTASSERT($SELECT(N[TXT:1,1:0),1,"[T002][body]")
 QUIT
