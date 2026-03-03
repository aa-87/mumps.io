MIORATET ; Tests for MIORATE (ROI #6)
;
; Quiet on success.
;
START
	DO ALL
	QUIT
	;
ALL
	DO T001
	DO T002
	QUIT
	;
T001
	; Disabled -> always allow
	NEW CONF,CTX,REQ,ERR,OK
	KILL CONF
	SET CONF("server","rate","enabled")=0
	SET CTX("remote_addr")="10.0.0.1"
	SET OK=$$ALLOW^MIORATE(.CONF,.CTX,.REQ,.ERR)
	DO EQ^MIOTASSERT(OK,1,"[T001] disabled allow")
	DO EQ^MIOTASSERT($DATA(ERR),0,"[T001] disabled no err")
	QUIT
	;
T002
	; Token bucket: burst 4, rps 2
	NEW CONF,CTX,REQ,ERR,OK,I
	KILL CONF
	SET CONF("server","rate","enabled")=1
	SET CONF("server","rate","perIp","rps")=2
	SET CONF("server","rate","perIp","burst")=4
	SET CONF("server","rate","perIp","ttlSeconds")=3600
	SET CONF("server","rate","_testNow")=1000
	SET CTX("remote_addr")="1.2.3.4"
	DO CLRIP^MIORATE(CTX("remote_addr"))
	;
	; First 4 allowed
	FOR I=1:1:4 DO
	. KILL ERR
	. SET OK=$$ALLOW^MIORATE(.CONF,.CTX,.REQ,.ERR)
	. DO EQ^MIOTASSERT(OK,1,"[T002] burst allow #"_I)
	;
	; 5th rejected
	KILL ERR
	SET OK=$$ALLOW^MIORATE(.CONF,.CTX,.REQ,.ERR)
	DO EQ^MIOTASSERT(OK,0,"[T002] reject")
	DO EQ^MIOTASSERT($GET(ERR("error")),"rate_limited","[T002] err code")
	DO EQ^MIOTASSERT($GET(ERR("routine")),"MIORATE","[T002] routine")
	DO EQ^MIOTASSERT(+$GET(ERR("status")),429,"[T002] status")
	;
	; Advance 1 second -> refill 2 tokens, should allow
	SET CONF("server","rate","_testNow")=1001
	KILL ERR
	SET OK=$$ALLOW^MIORATE(.CONF,.CTX,.REQ,.ERR)
	DO EQ^MIOTASSERT(OK,1,"[T002] refill allow")
	QUIT
