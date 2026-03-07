MIOERRCT ; Error Center tests (quiet on success).;
;
; Run:
;   YDB>D ^MIOERRCT
;
START ;
	DO T001
	DO T002
	DO T003
	DO T004
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
T001 ; PUSH + GET ordering
	NEW CONF,REQ,CTX,ERR,OUT,NEXT
	KILL ^MIO("ERR")
	DO CLEAR^MIOERRC
	SET CONF("server","errors","enabled")=1
	SET CONF("server","errors","maxEntries")=100
	SET CONF("server","errors","capture4xx")=1
	SET CONF("server","errors","capture404")=1
	;
	KILL REQ,CTX,ERR
	SET REQ("method")="GET",REQ("path")="/x"
	SET CTX("request_id")="rid1",CTX("remote_addr")="1.2.3.4",CTX("route")="/x",CTX("status")=401
	SET ERR("routine")="MIOAUTH",ERR("error")="api_key_missing",ERR("status")=401
	DO PUSH^MIOERRC(.CONF,.REQ,.CTX,.ERR,"request")
	;
	KILL REQ,CTX,ERR
	SET REQ("method")="POST",REQ("path")="/y"
	SET CTX("request_id")="rid2",CTX("remote_addr")="1.2.3.4",CTX("route")="/y",CTX("status")=500
	SET ERR("routine")="MIOROUTE",ERR("error")="handler_crash",ERR("status")=500
	DO PUSH^MIOERRC(.CONF,.REQ,.CTX,.ERR,"handler")
	;
	KILL OUT SET NEXT=0
	DO GET^MIOERRC(.CONF,0,2,.OUT,.NEXT)
	DO OK^MIOTASSERT($GET(OUT(1,"request_id"))="rid2","[T001][most recent first]")
	DO OK^MIOTASSERT($GET(OUT(2,"request_id"))="rid1","[T001][second recent]")
	QUIT
	;
T002 ; Ring wrap is deterministic
	NEW CONF,REQ,CTX,ERR,OUT,NEXT
	DO CLEAR^MIOERRC
	SET CONF("server","errors","enabled")=1
	SET CONF("server","errors","maxEntries")=2
	SET CONF("server","errors","capture4xx")=1
	SET CONF("server","errors","capture404")=1
	NEW I
	FOR I=1:1:3 DO
	. KILL REQ,CTX,ERR
	. SET REQ("method")="GET",REQ("path")="/w"_I
	. SET CTX("request_id")="ridw"_I,CTX("status")=500
	. SET ERR("routine")="T",ERR("error")="e"_I,ERR("status")=500
	. DO PUSH^MIOERRC(.CONF,.REQ,.CTX,.ERR,"request")
	KILL OUT SET NEXT=0
	DO GET^MIOERRC(.CONF,0,5,.OUT,.NEXT)
	DO OK^MIOTASSERT($GET(OUT(1,"request_id"))="ridw3","[T002][latest kept]")
	DO OK^MIOTASSERT($GET(OUT(2,"request_id"))="ridw2","[T002][2nd latest kept]")
	QUIT
	;
T003 ; /debug/errors output is JSON and contains entry
	NEW CONF,REQ,CTX,ERR,OUTTXT,OP,DEV
	DO CLEAR^MIOERRC
	SET CONF("server","errors","enabled")=1
	SET CONF("server","errors","maxEntries")=200
	SET CONF("server","errors","capture4xx")=1
	SET CONF("server","errors","capture404")=1
	;
	KILL REQ,CTX,ERR
	SET REQ("method")="GET",REQ("path")="/"
	SET CTX("request_id")="rid-json",CTX("status")=401
	SET ERR("routine")="MIOAUTH",ERR("error")="api_key_missing",ERR("status")=401
	DO PUSH^MIOERRC(.CONF,.REQ,.CTX,.ERR,"request")
	;
	KILL REQ,CTX
	SET REQ("method")="GET",REQ("path")="/debug/errors"
	SET REQ("query","limit")="10"
	SET CTX("request_id")="rid-out"
	SET OP="tmp/mioerrct_t003_"_$J_".out"
	OPEN OP:(newversion:stream:nowrap) USE OP
	DO ERRORS^MIOERRC(.OP,.CONF,.REQ,.CTX)
	CLOSE OP USE $PRINCIPAL
	DO READALL(OP,.OUTTXT)
	DO OK^MIOTASSERT(OUTTXT["HTTP/1.1 200","[T003][status]")
	DO OK^MIOTASSERT(OUTTXT["""errors"":","[T003][errors key]")
	DO OK^MIOTASSERT(OUTTXT["""api_key_missing""","[T003][contains error]")
	QUIT
	;
T004 ; /debug/config redacts secrets
	NEW CONF,REQ,CTX,OUTTXT,OP
	DO CLEAR^MIOERRC
	; build minimal config with secrets
	SET CONF("server","errors","enabled")=1
	SET CONF("auth","enabled")=1
	SET CONF("auth","apiKey","value")="secret123"
	SET CONF("auth","jwt","secret")="jwtsecret"
	;
	KILL REQ,CTX
	SET REQ("method")="GET",REQ("path")="/debug/config"
	SET REQ("query","full")="1"
	SET CTX("request_id")="rid-cfg"
	SET OP="tmp/mioerrct_t004_"_$J_".out"
	OPEN OP:(newversion:stream:nowrap) USE OP
	DO CONFIG^MIOERRC(.OP,.CONF,.REQ,.CTX)
	CLOSE OP USE $PRINCIPAL
	DO READALL(OP,.OUTTXT)
	DO OK^MIOTASSERT(OUTTXT["HTTP/1.1 200","[T004][status]")
	DO OK^MIOTASSERT(OUTTXT'["secret123","[T004][apiKey redacted]")
	DO OK^MIOTASSERT(OUTTXT'["jwtsecret","[T004][jwt redacted]")
	DO OK^MIOTASSERT(OUTTXT["***","[T004][shows redaction marker]")
	QUIT
	;
