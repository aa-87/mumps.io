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
	DO T004
	DO T005
	DO T006
	DO T007
	DO T008
	DO T009
	DO T010
	DO T011
	QUIT
	;
STERR
	USE $PRINCIPAL WRITE "ERR ",$ZSTATUS,!
	QUIT
	;
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
	;
T004 ; Range 0-0 -> 206 and first byte
	NEW CONF,REQ,CTX,DEV,OUT,ROOT,FP,OP
	SET ROOT="tmp"
	SET FP=ROOT_"/hello.txt"
	SET OP="tmp/mio_static_t004.out"
	OPEN FP:(newversion:stream:nowrap)
	USE FP WRITE "hi" CLOSE FP
	;
	SET CONF("server","static","enabled")=1
	SET CONF("server","static","root")=ROOT
	SET CONF("server","static","mount")="/static"
	;
	KILL REQ,CTX,OUT
	SET REQ("method")="GET"
	SET REQ("path")="/static/hello.txt"
	SET REQ("params","path")="hello.txt"
	SET REQ("hdr","range")="bytes=0-0"
	SET CTX("request_id")="st004"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV
	USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["206":1,1:0),1,"[T004][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Range: bytes 0-0/2":1,1:0),1,"[T004][content-range]")
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Length: 1":1,1:0),1,"[T004][content-length]")
	DO EQ^MIOTASSERT($SELECT(OUT["h":1,1:0),1,"[T004][body]")
	QUIT
	;
T005 ; Range suffix -1 -> last byte
	NEW CONF,REQ,CTX,DEV,OUT,ROOT,FP,OP
	SET ROOT="tmp"
	SET FP=ROOT_"/hello.txt"
	SET OP="tmp/mio_static_t005.out"
	OPEN FP:(newversion:stream:nowrap)
	USE FP WRITE "hi" CLOSE FP
	;
	SET CONF("server","static","enabled")=1
	SET CONF("server","static","root")=ROOT
	SET CONF("server","static","mount")="/static"
	;
	KILL REQ,CTX,OUT
	SET REQ("method")="GET"
	SET REQ("path")="/static/hello.txt"
	SET REQ("params","path")="hello.txt"
	SET REQ("hdr","range")="bytes=-1"
	SET CTX("request_id")="st005"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV
	USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["206":1,1:0),1,"[T005][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Range: bytes 1-1/2":1,1:0),1,"[T005][content-range]")
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Length: 1":1,1:0),1,"[T005][content-length]")
	DO EQ^MIOTASSERT($SELECT(OUT["i":1,1:0),1,"[T005][body]")
	QUIT
	;
T006 ; Invalid range -> 416
	NEW CONF,REQ,CTX,DEV,OUT,ROOT,FP,OP
	SET ROOT="tmp"
	SET FP=ROOT_"/hello.txt"
	SET OP="tmp/mio_static_t006.out"
	OPEN FP:(newversion:stream:nowrap)
	USE FP WRITE "hi" CLOSE FP
	;
	SET CONF("server","static","enabled")=1
	SET CONF("server","static","root")=ROOT
	SET CONF("server","static","mount")="/static"
	;
	KILL REQ,CTX,OUT
	SET REQ("method")="GET"
	SET REQ("path")="/static/hello.txt"
	SET REQ("params","path")="hello.txt"
	SET REQ("hdr","range")="bytes=10-11"
	SET CTX("request_id")="st006"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV
	USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["416":1,1:0),1,"[T006][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Range: bytes */2":1,1:0),1,"[T006][content-range]")
	QUIT
	;
	; (T001-T006 unchanged in your tree)
	;
T007 ; If-Modified-Since -> 304 (server-known mtime)
	KILL ^MIO("STATIC","META")
	;NEW CONF,REQ,CTX,DEV,OUT,ROOT,FP,OP,NORM,LM,P1,HD,HS
	SET ROOT="tmp"
	SET FP=ROOT_"/hello.txt"
	OPEN FP:(newversion:stream:nowrap)
	USE FP WRITE "hi" CLOSE FP
	SET CONF("server","static","enabled")=1
	SET CONF("server","static","root")=ROOT
	SET CONF("server","static","mount")="/static"
	SET HD=+$P($H,",",1),HS=+$P($H,",",2)
	DO SETMTIME^MIOSTATIC(FP,HD,HS)
	;
	; First request: capture Last-Modified
	SET OP=ROOT_"/mio_static_t007a.out"
	KILL REQ,CTX,OUT
	SET REQ("method")="GET"
	SET REQ("path")="/static/hello.txt"
	SET REQ("params","path")="hello.txt"
	SET CTX("request_id")="st007a"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	SET NORM=$TR(OUT,$C(13),$C(10))
	SET P1=$P(NORM,"Last-Modified: ",2)
	SET LM=$P(P1,$C(10),1)
	DO EQ^MIOTASSERT($SELECT(LM'="":1,1:0),1,"[T007][last-modified present]")
	;
	; Second request: If-Modified-Since -> 304 and no body
	SET OP=ROOT_"/mio_static_t007b.out"
	KILL REQ,CTX,OUT
	SET REQ("method")="GET"
	SET REQ("path")="/static/hello.txt"
	SET REQ("params","path")="hello.txt"
	SET REQ("hdr","if-modified-since")=LM
	SET CTX("request_id")="st007b"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["304":1,1:0),1,"[T007][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["hi":1,1:0),0,"[T007][no body]")
	QUIT
	;
T008 ; /static (no slash) redirects to /static/
	NEW CONF,REQ,CTX,DEV,OUT,ROOT,OP
	SET ROOT="tmp"
	SET OP="tmp/mio_static_t008.out"
	;
	SET CONF("server","static","enabled")=1
	SET CONF("server","static","root")=ROOT
	SET CONF("server","static","mount")="/static"
	;
	KILL REQ,CTX,OUT
	SET REQ("method")="GET"
	SET REQ("path")="/static"
	SET REQ("params","path")=""
	SET CTX("request_id")="st008"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV
	USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["301":1,1:0),1,"[T008][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["Location: /static/":1,1:0),1,"[T008][location]")
	QUIT
	;
T009 ; GET /static/ serves configured index
	NEW CONF,REQ,CTX,DEV,OUT,ROOT,FP,OP,IDX
	SET ROOT="tmp"
	SET IDX="mio_static_index9.html"
	SET FP=ROOT_"/"_IDX
	SET OP="tmp/mio_static_t009.out"
	OPEN FP:(newversion:stream:nowrap)
	USE FP WRITE "home9" CLOSE FP
	;
	SET CONF("server","static","enabled")=1
	SET CONF("server","static","root")=ROOT
	SET CONF("server","static","mount")="/static"
	SET CONF("server","static","index")=IDX
	;
	KILL REQ,CTX,OUT
	SET REQ("method")="GET"
	SET REQ("path")="/static/"
	SET REQ("params","path")=""
	SET CTX("request_id")="st009"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV
	USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 200 OK":1,1:0),1,"[T009][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["home9":1,1:0),1,"[T009][body]")
	QUIT
	;
T010 ; Directory listing when index missing and listing enabled
	NEW CONF,REQ,CTX,DEV,OUT,ROOT,OP
	SET ROOT="tmp"
	SET OP="tmp/mio_static_t010.out"
	; create a couple files in root
	OPEN (ROOT_"/mio_dl_a.txt"):(newversion:stream:nowrap)
	USE (ROOT_"/mio_dl_a.txt") WRITE "a" CLOSE (ROOT_"/mio_dl_a.txt")
	OPEN (ROOT_"/mio_dl_b.txt"):(newversion:stream:nowrap)
	USE (ROOT_"/mio_dl_b.txt") WRITE "b" CLOSE (ROOT_"/mio_dl_b.txt")
	;
	SET CONF("server","static","enabled")=1
	SET CONF("server","static","root")=ROOT
	SET CONF("server","static","mount")="/static"
	SET CONF("server","static","index")="mio_static_noindex_t010.html"
	SET CONF("server","static","dirListing","enabled")=1
	SET CONF("server","static","dirListing","maxEntries")=200
	;
	KILL REQ,CTX,OUT
	SET REQ("method")="GET"
	SET REQ("path")="/static/"
	SET REQ("params","path")=""
	SET CTX("request_id")="st010"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV
	USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 200 OK":1,1:0),1,"[T010][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["Transfer-Encoding: chunked":1,1:0),1,"[T010][chunked]")
	DO EQ^MIOTASSERT($SELECT(OUT["mio_dl_a.txt":1,1:0),1,"[T010][a present]")
	DO EQ^MIOTASSERT($SELECT(OUT["mio_dl_b.txt":1,1:0),1,"[T010][b present]")
	QUIT
	;
T011 ; /static/ missing index and listing disabled -> 404
	NEW CONF,REQ,CTX,DEV,OUT,ROOT,OP
	SET ROOT="tmp"
	SET OP="tmp/mio_static_t011.out"
	SET CONF("server","static","enabled")=1
	SET CONF("server","static","root")=ROOT
	SET CONF("server","static","mount")="/static"
	SET CONF("server","static","index")="mio_static_noindex_t011.html"
	;
	KILL REQ,CTX,OUT
	SET REQ("method")="GET"
	SET REQ("path")="/static/"
	SET REQ("params","path")=""
	SET CTX("request_id")="st011"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV
	USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["404":1,1:0),1,"[T011][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["MIOSTATIC":1,1:0),1,"[T011][routine]")
	QUIT