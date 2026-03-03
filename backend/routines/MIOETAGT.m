MIOETAGT ; Static ETag persistence + invalidation tests (ROI #2)
	;
	; Run:
	;   YDB>ZL "MIOHTTP.m","MIOSTATIC.m","MIOETAGT.m","MIOTASSERT.m"
	;   YDB>D ^MIOETAGT
	;
	NEW $ET SET $ET="DO STERR^MIOETAGT"
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
	OPEN PATH:(readonly:stream:nowrap)
	USE PATH
	NEW X
	FOR  READ X#16384 QUIT:$ZEOF  SET OUT=OUT_X
	CLOSE PATH
	USE OIO
	QUIT
	;
CAPETAG(OUT)
	NEW NORM,P1,ET
	SET NORM=$TR($GET(OUT),$C(13),$C(10))
	SET P1=$P(NORM,"ETag: ",2)
	SET ET=$P(P1,$C(10),1)
	QUIT ET
	;
T001 ; ETag persisted and stable even if short cache is cleared
	KILL ^MIO("STATIC","META")
	KILL ^MIO("STATIC","ETAG")
	NEW CONF,REQ,CTX,DEV,OUT,ROOT,FN,FS,OP,ET1,ET2,HD,HS
	SET ROOT="/tmp"
	SET FN="mio_etag_t001_"_$J_"_"_$P($H,",",2)_".txt"
	SET FS=ROOT_"/"_FN
	SET OP="tmp/mio_etag_t001_"_$J_".out"
	;
	OPEN FS:(newversion:stream:nowrap)
	USE FS WRITE "alpha" CLOSE FS
	SET HD=+$P($H,",",1),HS=+$P($H,",",2)
	DO SETMTIME^MIOSTATIC(FS,HD,HS)
	;
	SET CONF("server","static","enabled")=1
	SET CONF("server","static","root")=ROOT
	SET CONF("server","static","mount")="/static"
	SET CONF("server","static","maxEtagBytes")=1048576
	SET CONF("server","static","etagCacheSeconds")=999999
	;
	KILL REQ,CTX,OUT
	SET REQ("method")="GET"
	SET REQ("path")="/static/"_FN
	SET REQ("params","path")=FN
	SET CTX("request_id")="etag001"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	SET ET1=$$CAPETAG(.OUT)
	DO OK^MIOTASSERT($SELECT(ET1'="":1,1:0),"[T001] etag present")
	DO EQ^MIOTASSERT($GET(^MIO("STATIC","ETAG",FS)),ET1,"[T001] persisted etag")
	;
	; Clear only the short cache (simulate restart/ttl expiry) and ensure stable reuse.;
	KILL ^MIO("STATIC","META",FS,"etag")
	KILL ^MIO("STATIC","META",FS,"etagid")
	KILL ^MIO("STATIC","META",FS,"tsd")
	KILL ^MIO("STATIC","META",FS,"tss")
	;
	SET OP="tmp/mio_etag_t001b_"_$J_".out"
	KILL REQ,CTX,OUT
	SET REQ("method")="GET"
	SET REQ("path")="/static/"_FN
	SET REQ("params","path")=FN
	SET CTX("request_id")="etag001b"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	SET ET2=$$CAPETAG(.OUT)
	DO EQ^MIOTASSERT(ET2,ET1,"[T001] stable etag after cache clear")
	QUIT
	;
T002 ; Identity change (mtime updated) invalidates cached ETag even with long TTL
	KILL ^MIO("STATIC","META")
	KILL ^MIO("STATIC","ETAG")
	NEW CONF,REQ,CTX,DEV,OUT,ROOT,FN,FS,OP,ET1,ET2,HD,HS
	SET ROOT="/tmp"
	SET FN="mio_etag_t002_"_$J_"_"_$P($H,",",2)_".txt"
	SET FS=ROOT_"/"_FN
	;
	OPEN FS:(newversion:stream:nowrap)
	USE FS WRITE "alpha" CLOSE FS
	SET HD=+$P($H,",",1),HS=+$P($H,",",2)
	DO SETMTIME^MIOSTATIC(FS,HD,HS)
	;
	SET CONF("server","static","enabled")=1
	SET CONF("server","static","root")=ROOT
	SET CONF("server","static","mount")="/static"
	SET CONF("server","static","maxEtagBytes")=1048576
	SET CONF("server","static","etagCacheSeconds")=999999
	;
	; First request -> ET1
	SET OP="tmp/mio_etag_t002a_"_$J_".out"
	KILL REQ,CTX,OUT
	SET REQ("method")="GET"
	SET REQ("path")="/static/"_FN
	SET REQ("params","path")=FN
	SET CTX("request_id")="etag002a"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	SET ET1=$$CAPETAG(.OUT)
	DO OK^MIOTASSERT($SELECT(ET1'="":1,1:0),"[T002] etag present")
	;
	; Modify file content + bump server-known mtime.;
	OPEN FS:(newversion:stream:nowrap)
	USE FS WRITE "alpha-beta" CLOSE FS
	DO SETMTIME^MIOSTATIC(FS,HD,HS+1)
	;
	; Second request -> ET2 should differ even though TTL is huge.;
	SET OP="tmp/mio_etag_t002b_"_$J_".out"
	KILL REQ,CTX,OUT
	SET REQ("method")="GET"
	SET REQ("path")="/static/"_FN
	SET REQ("params","path")=FN
	SET CTX("request_id")="etag002b"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	SET ET2=$$CAPETAG(.OUT)
	DO NE^MIOTASSERT(ET2,ET1,"[T002] etag changed after identity change")
	DO EQ^MIOTASSERT($GET(^MIO("STATIC","ETAG",FS)),ET2,"[T002] persisted updated etag")
	;
	; If-None-Match old -> must NOT return 304
	SET OP="tmp/mio_etag_t002c_"_$J_".out"
	KILL REQ,CTX,OUT
	SET REQ("method")="GET"
	SET REQ("path")="/static/"_FN
	SET REQ("params","path")=FN
	SET REQ("hdr","if-none-match")=ET1
	SET CTX("request_id")="etag002c"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO OK^MIOTASSERT($SELECT(OUT["HTTP/1.1 200 OK":1,1:0),"[T002] old etag does not 304")
	QUIT
	;