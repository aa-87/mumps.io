MIOSTATICZTT ; Static precompressed assets tests (br/gz negotiation)
	;
	; Run:
	;   YDB>ZL "MIOHTTP.m","MIOSTATIC.m","MIOSTATICZTT.m","MIOTASSERT.m"
	;   YDB>D ^MIOSTATICZTT
	;
	NEW $ET SET $ET="DO STERR^MIOSTATICZTT"
	DO T001
	DO T002
	DO T003
	DO T004
	DO T005
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
HAS(STR,SUB) QUIT $SELECT($GET(STR)[$GET(SUB):1,1:0)
	;
MKFILES(ROOT,NAME,PLAIN,BR,GZ,MAKEBR,MAKEGZ)
	NEW FP SET FP=ROOT_"/"_NAME_".txt"
	NEW FPBR SET FPBR=FP_".br"
	NEW FPGZ SET FPGZ=FP_".gz"
	OPEN FP:(newversion:stream:nowrap) USE FP WRITE $GET(PLAIN) CLOSE FP
	IF +$GET(MAKEBR,1) DO
	. OPEN FPBR:(newversion:stream:nowrap) USE FPBR WRITE $GET(BR) CLOSE FPBR
	IF +$GET(MAKEGZ,1) DO
	. OPEN FPGZ:(newversion:stream:nowrap) USE FPGZ WRITE $GET(GZ) CLOSE FPGZ
	QUIT FP
	;
BASECONF(CONF)
	KILL CONF
	SET CONF("server","static","enabled")=1
	SET CONF("server","static","root")="/tmp"
	SET CONF("server","static","mount")="/static"
	SET CONF("server","static","precompressed","enabled")=1
	SET CONF("server","static","precompressed","allowRangeEncoded")=0
	QUIT
	;
CALL(DEV,CONF,REQ,CTX,OUTPATH,OUT)
	OPEN OUTPATH:(newversion:stream:nowrap)
	SET DEV=OUTPATH USE DEV
	DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OUTPATH,.OUT)
	QUIT
	;
T001 ; br preferred when present
	NEW CONF,REQ,CTX,DEV,OUT,NAME,FP,OP
	DO BASECONF(.CONF)
	SET NAME="miostatic_ztt1_"_$J_"_"_$P($H,",",2)
	SET FP=$$MKFILES("/tmp",NAME,"plain","brdata","gzdata",1,1)
	SET OP="tmp/mio_static_ztt1_"_$J_".out"
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/static/"_NAME_".txt"
	SET REQ("params","path")=NAME_".txt"
	SET REQ("hdr","accept-encoding")="br, gzip"
	SET CTX("request_id")="ztt001"
	DO CALL(.DEV,.CONF,.REQ,.CTX,OP,.OUT)
	DO EQ^MIOTASSERT($$HAS(OUT,"HTTP/1.1 200 OK"),1,"[T001][status]")
	DO EQ^MIOTASSERT($$HAS(OUT,"Content-Encoding: br"),1,"[T001][encoding br]")
	DO EQ^MIOTASSERT($$HAS(OUT,"Vary: Accept-Encoding"),1,"[T001][vary]")
	DO EQ^MIOTASSERT($$HAS(OUT,"text/plain"),1,"[T001][content-type]")
	DO EQ^MIOTASSERT($$HAS(OUT,"brdata"),1,"[T001][body]")
	QUIT
	;
T002 ; q=0 disables br, gzip served
	NEW CONF,REQ,CTX,DEV,OUT,NAME,FP,OP
	DO BASECONF(.CONF)
	SET NAME="miostatic_ztt2_"_$J_"_"_$P($H,",",2)
	SET FP=$$MKFILES("/tmp",NAME,"plain","brdata","gzdata",1,1)
	SET OP="tmp/mio_static_ztt2_"_$J_".out"
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/static/"_NAME_".txt"
	SET REQ("params","path")=NAME_".txt"
	SET REQ("hdr","accept-encoding")="br;q=0, gzip"
	SET CTX("request_id")="ztt002"
	DO CALL(.DEV,.CONF,.REQ,.CTX,OP,.OUT)
	DO EQ^MIOTASSERT($$HAS(OUT,"HTTP/1.1 200 OK"),1,"[T002][status]")
	DO EQ^MIOTASSERT($$HAS(OUT,"Content-Encoding: gzip"),1,"[T002][encoding gzip]")
	DO EQ^MIOTASSERT($$HAS(OUT,"gzdata"),1,"[T002][body]")
	QUIT
	;
T003 ; no Accept-Encoding -> original (no Content-Encoding), still Vary present
	;NEW CONF,REQ,CTX,DEV,OUT,NAME,FP,OP
	DO BASECONF(.CONF)
	SET NAME="miostatic_ztt3_"_$J_"_"_$P($H,",",2)
	SET FP=$$MKFILES("/tmp",NAME,"plain","brdata","gzdata",1,1)
	SET OP="tmp/mio_static_ztt3_"_$J_".out"
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/static/"_NAME_".txt"
	SET REQ("params","path")=NAME_".txt"
	SET CTX("request_id")="ztt003"
	DO CALL(.DEV,.CONF,.REQ,.CTX,OP,.OUT)
	DO EQ^MIOTASSERT($$HAS(OUT,"HTTP/1.1 200 OK"),1,"[T003][status]")
	DO EQ^MIOTASSERT($$HAS(OUT,"Content-Encoding:"),0,"[T003][no encoding]")
	DO EQ^MIOTASSERT($$HAS(OUT,"Vary: Accept-Encoding"),1,"[T003][vary]")
	DO EQ^MIOTASSERT($$HAS(OUT,"plain"),1,"[T003][body]")
	QUIT
	;
T004 ; Range request should not serve encoded variant (default)
	NEW CONF,REQ,CTX,DEV,OUT,NAME,FP,OP
	DO BASECONF(.CONF)
	SET NAME="miostatic_ztt4_"_$J_"_"_$P($H,",",2)
	SET FP=$$MKFILES("/tmp",NAME,"plain","brdata","gzdata",1,1)
	SET OP="tmp/mio_static_ztt4_"_$J_".out"
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/static/"_NAME_".txt"
	SET REQ("params","path")=NAME_".txt"
	SET REQ("hdr","accept-encoding")="br, gzip"
	SET REQ("hdr","range")="bytes=0-1"
	SET CTX("request_id")="ztt004"
	DO CALL(.DEV,.CONF,.REQ,.CTX,OP,.OUT)
	DO EQ^MIOTASSERT($$HAS(OUT,"HTTP/1.1 206 Partial Content"),1,"[T004][status 206]")
	DO EQ^MIOTASSERT($$HAS(OUT,"Content-Encoding:"),0,"[T004][no encoding]")
	DO EQ^MIOTASSERT($$HAS(OUT,"pl"),1,"[T004][body range]")
	QUIT
	;
T005 ; br missing -> fallback to gzip when accepted and present
	NEW CONF,REQ,CTX,DEV,OUT,NAME,FP,OP
	DO BASECONF(.CONF)
	SET NAME="miostatic_ztt5_"_$J_"_"_$P($H,",",2)
	; create only gzip sidecar
	SET FP=$$MKFILES("/tmp",NAME,"plain","brdata","gzdata",0,1)
	SET OP="tmp/mio_static_ztt5_"_$J_".out"
	KILL REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/static/"_NAME_".txt"
	SET REQ("params","path")=NAME_".txt"
	SET REQ("hdr","accept-encoding")="br, gzip"
	SET CTX("request_id")="ztt005"
	DO CALL(.DEV,.CONF,.REQ,.CTX,OP,.OUT)
	DO EQ^MIOTASSERT($$HAS(OUT,"HTTP/1.1 200 OK"),1,"[T005][status]")
	DO EQ^MIOTASSERT($$HAS(OUT,"Content-Encoding: gzip"),1,"[T005][encoding gzip]")
	DO EQ^MIOTASSERT($$HAS(OUT,"gzdata"),1,"[T005][body]")
	QUIT
	;
	;