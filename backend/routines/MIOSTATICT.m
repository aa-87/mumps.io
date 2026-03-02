MIOSTATICT ; Static file handler tests (includes ETag 304)
	;
	; Run:
	;   YDB>ZL "MIOHTTP.m","MIOSTATIC.m","MIOSTATICT.m","MIOTASSERT.m"
	;   YDB>D ^MIOSTATICT
	;
	NEW $ET SET $ET="DO STERR^MIOSTATICT"
	DO T001
	DO T002
	DO T003
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
	NEW CONF,REQ,CTX,DEV,OUT,ROOT,FP,OP
	SET ROOT="tmp"
	SET FP=ROOT_"/hello.txt"
	SET OP="tmp/mio_static_t001.out"
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
	SET REQ("path")="/static/hello.txt"
	SET REQ("params","path")="hello.txt"
	SET CTX("request_id")="st001"
	;
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
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
	SET ROOT="tmp"
	SET OP="tmp/mio_static_t002.out"
	OPEN (ROOT_"/index.html"):(newversion:stream:nowrap)
	USE (ROOT_"/index.html") WRITE "ok" CLOSE (ROOT_"/index.html")
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
	SET DEV=OP USE DEV
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV
	USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["404":1,1:0),1,"[T002][status]")
	QUIT
	;
T003 ; If-None-Match -> 304 no body
	NEW CONF,REQ,CTX,DEV,OUT,ROOT,FP,OP,ET,NORM,P1
	SET ROOT="tmp"
	SET FP=ROOT_"/hello.txt"
	; create file
	OPEN FP:(newversion:stream:nowrap)
	USE FP WRITE "hi" CLOSE FP
	;
	SET CONF("server","static","enabled")=1
	SET CONF("server","static","root")=ROOT
	SET CONF("server","static","mount")="/static"
	SET CONF("server","static","maxEtagBytes")=1048576
	SET CONF("server","static","etagCacheSeconds")=60
	;
	; First request: capture ETag
	SET OP="tmp/mio_static_t003a.out"
	KILL REQ,CTX,OUT
	SET REQ("method")="GET"
	SET REQ("path")="/static/hello.txt"
	SET REQ("params","path")="hello.txt"
	SET CTX("request_id")="st003a"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV
	USE $PRINCIPAL
	DO READALL(OP,.OUT)
	SET NORM=$TR(OUT,$C(13),$C(10))
	SET P1=$P(NORM,"ETag: ",2)
	SET ET=$P(P1,$C(10),1)
	DO EQ^MIOTASSERT($SELECT(ET'="":1,1:0),1,"[T003][etag present]")
	;
	; Second request: If-None-Match
	SET OP="tmp/mio_static_t003b.out"
	KILL REQ,CTX,OUT
	SET REQ("method")="GET"
	SET REQ("path")="/static/hello.txt"
	SET REQ("params","path")="hello.txt"
	SET REQ("hdr","if-none-match")=ET
	SET CTX("request_id")="st003b"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV
	USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["304":1,1:0),1,"[T003][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["hi":1,1:0),0,"[T003][no body]")
	QUIT
	;