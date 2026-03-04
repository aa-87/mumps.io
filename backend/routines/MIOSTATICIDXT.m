MIOSTATICIDXT ; Static directory index + listing tests (ROI #7)
	;
	; Run:
	;   YDB>ZL "MIOHTTP.m","MIOSTATIC.m","MIOSTATICIDXT.m","MIOTASSERT.m"
	;   YDB>D ^MIOSTATICIDXT
	;
	NEW $ET SET $ET="DO STERR^MIOSTATICIDXT"
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
	OPEN PATH:(readonly:stream:nowrap)
	USE PATH
	NEW X
	FOR  READ X#16384  QUIT:$ZEOF  SET OUT=OUT_X
	CLOSE PATH
	USE OIO
	QUIT
	;
HAS(STR,SUB) QUIT $SELECT($GET(STR)[$GET(SUB):1,1:0)
	;
BASECONF(CONF)
	KILL CONF
	SET CONF("server","static","enabled")=1
	SET CONF("server","static","mount")="/static"
	SET CONF("server","static","root")="."  ; secure relative root for tests
	QUIT
	;
CALL(OUTPATH,CONF,REQ,CTX,OUT)
	OPEN OUTPATH:(newversion:stream:nowrap)
	NEW DEV SET DEV=OUTPATH USE DEV
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OUTPATH,.OUT)
	QUIT
	;
T001 ; directory index served even without trailing slash
	NEW CONF,REQ,CTX,OUT,OP,BASE,IDXFP
	DO BASECONF(.CONF)
	SET BASE="tmp"
	SET IDXFP=BASE_"/mio_idx_"_$J_".html"
	; ensure tmp exists by creating index file
	OPEN IDXFP:(newversion:stream:nowrap) USE IDXFP WRITE "hello index" CLOSE IDXFP
	SET CONF("server","static","index")=$P(IDXFP,"/",$L(IDXFP,"/"))
	KILL REQ,CTX
	SET REQ("method")="GET",REQ("path")="/static/tmp",REQ("params","path")="tmp",REQ("httpver")="HTTP/1.1"
	SET CTX("request_id")="sdx001"
	SET OP="tmp/mio_static_idx_t001_"_$J_".out"
	DO CALL(OP,.CONF,.REQ,.CTX,.OUT)
	DO EQ^MIOTASSERT($$HAS(OUT,"HTTP/1.1 200"),1,"[T001][status]")
	DO EQ^MIOTASSERT($$HAS(OUT,"hello index"),1,"[T001][body]")
	QUIT
	;
T002 ; no index and listing disabled -> 404
	NEW CONF,REQ,CTX,OUT,OP
	DO BASECONF(.CONF)
	SET CONF("server","static","index")="__no_such_index_"_$J_".html"
	SET CONF("server","static","dirListing","enabled")=0
	KILL REQ,CTX
	SET REQ("method")="GET",REQ("path")="/static/tmp/",REQ("params","path")="tmp/",REQ("httpver")="HTTP/1.1"
	SET CTX("request_id")="sdx002"
	SET OP="tmp/mio_static_idx_t002_"_$J_".out"
	DO CALL(OP,.CONF,.REQ,.CTX,.OUT)
	DO EQ^MIOTASSERT($$HAS(OUT,"HTTP/1.1 404"),1,"[T002][status]")
	QUIT
	;
T003 ; no index and listing enabled -> HTML
	;NEW CONF,REQ,CTX,OUT,OP,FP
	DO BASECONF(.CONF)
	SET CONF("server","static","index")="__no_such_index_"_$J_".html"
	SET CONF("server","static","dirListing","enabled")=1
	; create a file to list
	SET FP="tmp/mio_list_"_$J_".txt"
	OPEN FP:(newversion:stream:nowrap) USE FP WRITE "x" CLOSE FP
	KILL REQ,CTX
	SET REQ("method")="GET",REQ("path")="/static/tmp/",REQ("params","path")="tmp/",REQ("httpver")="HTTP/1.1"
	SET CTX("request_id")="sdx003"
	SET OP="tmp/mio_static_idx_t003_"_$J_".out"
	DO CALL(OP,.CONF,.REQ,.CTX,.OUT)
	DO EQ^MIOTASSERT($$HAS(OUT,"HTTP/1.1 200"),1,"[T003][status]")
	DO EQ^MIOTASSERT($$HAS(OUT,"Content-Type: text/html"),1,"[T003][ctype]")
	DO EQ^MIOTASSERT($$HAS(OUT,$P(FP,"/",$L(FP,"/"))),1,"[T003][body]")
	QUIT
	;