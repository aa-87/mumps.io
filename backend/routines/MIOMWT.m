MIOMWT ; Middleware pipeline tests (router-level before/after)
	;
	; Run:
	;   YDB>ZL "MIOHTTP.m","MIOROUTE.m","MIOMWT.m","MIOTASSERT.m"
	;   YDB>D ^MIOMWT
	;
	NEW $ET SET $ET="DO STERR^MIOMWT"
	DO T001
	DO T002
	DO T003
	QUIT
	;
STERR
	USE $PRINCIPAL WRITE "ERR ",$ZSTATUS,!
	QUIT
	;
RESET
	KILL ^MIO("ROUTE")
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
T001 ; before/handler/after order is deterministic
	DO RESET
	DO ADD^MIOROUTE("GET","/mw","H1^MIOMWT")
	DO COMPILE^MIOROUTE
	NEW CONF,REQ,CTX,DEV,OUT,OP
	KILL CONF,REQ,CTX
	SET CONF("server","middleware","before",1)="B1^MIOMWT"
	SET CONF("server","middleware","before",2)="B2^MIOMWT"
	SET CONF("server","middleware","after",1)="A1^MIOMWT"
	SET CONF("server","middleware","after",2)="A2^MIOMWT"
	SET REQ("method")="GET"
	SET REQ("path")="/mw"
	SET CTX("request_id")="mw001"
	SET OP="tmp/mio_mw_t001.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV
	USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T001][status]")
	DO EQ^MIOTASSERT($GET(CTX("mwtrace")),"b1,b2,h,a1,a2,","[T001][trace]")
	QUIT
	;
T002 ; before middleware can reject and router writes JSON error (no handler)
	DO RESET
	DO ADD^MIOROUTE("GET","/mwdeny","H1^MIOMWT")
	DO COMPILE^MIOROUTE
	NEW CONF,REQ,CTX,DEV,OUT,OP
	KILL CONF,REQ,CTX
	SET CONF("server","middleware","before",1)="DENY^MIOMWT"
	SET REQ("method")="GET"
	SET REQ("path")="/mwdeny"
	SET CTX("request_id")="mw002"
	SET OP="tmp/mio_mw_t002.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV
	USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["403":1,1:0),1,"[T002][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["denied":1,1:0),1,"[T002][error]")
	DO EQ^MIOTASSERT($SELECT(OUT["MIOMWT":1,1:0),1,"[T002][routine]")
	DO EQ^MIOTASSERT($SELECT($GET(CTX("mwtrace"))["deny,":1,1:0),1,"[T002][trace]")
	QUIT
	;
T003 ; per-route meta middleware list (mw_before)
	DO RESET
	NEW META
	SET META("mw_before")="B1^MIOMWT, B2^MIOMWT"
	DO ADDM^MIOROUTE("GET","/mwmeta","H1^MIOMWT",.META)
	DO COMPILE^MIOROUTE
	NEW CONF,REQ,CTX,DEV,OUT,OP
	KILL CONF,REQ,CTX
	SET REQ("method")="GET"
	SET REQ("path")="/mwmeta"
	SET CTX("request_id")="mw003"
	SET OP="tmp/mio_mw_t003.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV
	USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[T003][status]")
	DO EQ^MIOTASSERT($GET(CTX("mwtrace")),"b1,b2,h,","[T003][trace]")
	QUIT
	;
; ---- middleware/handler fixtures ----
B1(DEV,CONF,REQ,CTX,ERR)
	SET CTX("mwtrace")=$GET(CTX("mwtrace"))_"b1,"
	QUIT 1
B2(DEV,CONF,REQ,CTX,ERR)
	SET CTX("mwtrace")=$GET(CTX("mwtrace"))_"b2,"
	QUIT 1
A1(DEV,CONF,REQ,CTX,ERR)
	SET CTX("mwtrace")=$GET(CTX("mwtrace"))_"a1,"
	QUIT
A2(DEV,CONF,REQ,CTX,ERR)
	SET CTX("mwtrace")=$GET(CTX("mwtrace"))_"a2,"
	QUIT
DENY(DEV,CONF,REQ,CTX,ERR)
	SET CTX("mwtrace")=$GET(CTX("mwtrace"))_"deny,"
	SET ERR("routine")="MIOMWT"
	SET ERR("error")="denied"
	SET ERR("status")=403
	QUIT 0
H1(DEV,CONF,REQ,CTX)
	SET CTX("mwtrace")=$GET(CTX("mwtrace"))_"h,"
	NEW OBJ
	SET OBJ("ok")=1
	SET OBJ("trace")=$GET(CTX("mwtrace"))
	SET OBJ("routine")="MIOMWT"
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
