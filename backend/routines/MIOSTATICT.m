MIOSTATICT ; Static file handler tests
 ;
 ; Run:
 ;   YDB>ZL "MIOHTTP_unified.m","MIOSTATIC.m","MIOSTATICT.m","MIOTASSERT.m"
 ;   YDB>D ^MIOSTATICT
 ;
 NEW $ET SET $ET="DO STERR^MIOSTATICT"
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
T001 ; GET existing file
 NEW CONF,REQ,CTX,DEV,OUT,ROOT,FP,OP,FN
 SET ROOT="/tmp"
 SET FN="mio_static_t001_"_$J_".txt"
 SET FP=ROOT_"/"_FN
 SET OP="/tmp/mio_static_t001.out"
 ; create file
 OPEN FP:(newversion:stream:nowrap)
 USE FP WRITE "hi" CLOSE FP
 ;
 SET CONF("server","static","enabled")=1
 SET CONF("server","static","root")=ROOT
 SET CONF("server","static","mount")="/static"
 ;
 KILL REQ,CTX
 SET REQ("method")="GET"
 SET REQ("path")="/static/"_FN
 SET REQ("params","path")=FN
 SET CTX("request_id")="st001"
 ;
 OPEN OP:(newversion:stream:nowrap)
 SET DEV=OP
 USE DEV
 DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
 CLOSE DEV
 USE $PRINCIPAL
 DO READALL(OP,.OUT)
 DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 200 OK":1,1:0),1,"[T001][status]")
 DO EQ^MIOTASSERT($SELECT(OUT["hi":1,1:0),1,"[T001][body]")
 QUIT
 ;
T002 ; traversal rejected -> 404
 NEW CONF,REQ,CTX,DEV,OUT,ROOT,OP
 SET ROOT="/tmp"
 SET OP="/tmp/mio_static_t002.out"
 ;
 SET CONF("server","static","enabled")=1
 SET CONF("server","static","root")=ROOT
 SET CONF("server","static","mount")="/static"
 ;
 KILL REQ,CTX
 SET REQ("method")="GET"
 SET REQ("path")="/static/../secret.txt"
 SET REQ("params","path")="../secret.txt"
 SET CTX("request_id")="st002"
 ;
 OPEN OP:(newversion:stream:nowrap)
 SET DEV=OP
 USE DEV
 DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
 CLOSE DEV
 USE $PRINCIPAL
 DO READALL(OP,.OUT)
 DO EQ^MIOTASSERT($SELECT(OUT["404":1,1:0),1,"[T002][status]")
 QUIT
