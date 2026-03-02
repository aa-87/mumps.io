MIOHTTPRESPT ; Response streaming + sendfile tests
 ;
 ; Run:
 ;   YDB>ZL "MIOHTTP_unified.m","MIOHTTPRESPT.m","MIOTASSERT.m"
 ;   YDB>D ^MIOHTTPRESPT
 ;
 ; Notes:
 ; - Uses file devices as output.
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
T001 ; chunked streaming basic
 NEW CONF,DEV,OUT,HEAD,REQID,CTX,PATH,TXT,CRLF
 SET CRLF=$C(13,10)
 SET PATH="/tmp/mio_resp_t001.out"
 OPEN PATH:(newversion:stream:nowrap)
 SET DEV=PATH
 USE DEV
 SET TXT="HelloWorld" ; 10 bytes => hex A
 SET HEAD("Content-Type")="text/plain"
 SET REQID="t001"
 DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,REQID,.CTX)
 DO STREAMWRITE^MIOHTTP(.DEV,TXT)
 DO STREAMEND^MIOHTTP(.DEV)
 CLOSE DEV
 USE $PRINCIPAL
 DO READALL(PATH,.OUT)
 DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 200 OK":1,1:0),1,"[T001][status]")
 DO EQ^MIOTASSERT($SELECT(OUT["Transfer-Encoding: chunked":1,1:0),1,"[T001][te]")
 DO EQ^MIOTASSERT($SELECT(OUT[("A"_CRLF_TXT_CRLF):1,1:0),1,"[T001][chunk]")
 QUIT
 ;
T002 ; sendfile
 NEW CONF,DEV,OUT,HEAD,REQID,CTX,OP,IP,TXT
 SET IP="/tmp/mio_resp_t002.in"
 SET OP="/tmp/mio_resp_t002.out"
 SET TXT="abcdefghijklmnopqrstuvwxyz"
 OPEN IP:(newversion:stream:nowrap)
 USE IP WRITE TXT CLOSE IP
 OPEN OP:(newversion:stream:nowrap)
 SET DEV=OP
 USE DEV
 SET HEAD("Content-Type")="text/plain"
 SET REQID="t002"
 NEW OK SET OK=$$SENDFILE^MIOHTTP(.DEV,.CONF,IP,.HEAD,REQID,.CTX,"GET")
 CLOSE DEV
 DO EQ^MIOTASSERT(OK,1,"[T002][ok]")
 DO READALL(OP,.OUT)
 DO EQ^MIOTASSERT($SELECT(OUT["Transfer-Encoding: chunked":1,1:0),1,"[T002][te]")
 DO EQ^MIOTASSERT($SELECT(OUT[TXT:1,1:0),1,"[T002][body]")
 QUIT
