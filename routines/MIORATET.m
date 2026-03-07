MIORATET ; Tests for MIORATE rate limiting (ROI #6)
;
; Run:
;   YDB>D START^MIORATET
;
; Notes
; - Quiet on success.;
;	
	D START
	QUIT
	;
	;
START
	DO T001
	DO T002
	DO T003
	DO T004
	DO T005
	DO T006
	QUIT
	;
	;
T001 ; allow within burst
	NEW CONF,CTX,REQ,ERR,OK
	DO CLEAR^MIORATE
	SET CONF("server","rate","enabled")=1
	SET CONF("server","rate","rps")=10
	SET CONF("server","rate","burst")=2
	SET CTX("remote_addr")="1.1.1.1"
	SET OK=$$ALLOWAT^MIORATE(.CONF,"1.1.1.1",1000,10,2,.ERR)
	DO EQ^MIOTASSERT(OK,1,"[T001][allow1]")
	SET OK=$$ALLOWAT^MIORATE(.CONF,"1.1.1.1",1000,10,2,.ERR)
	DO EQ^MIOTASSERT(OK,1,"[T001][allow2]")
	QUIT
	;
	;
T002 ; deny when burst exhausted; retry-after deterministic
	NEW CONF,ERR,OK
	DO CLEAR^MIORATE
	SET CONF("server","rate","enabled")=1
	SET OK=$$ALLOWAT^MIORATE(.CONF,"2.2.2.2",2000,2,1,.ERR)
	DO EQ^MIOTASSERT(OK,1,"[T002][allow]")
	SET OK=$$ALLOWAT^MIORATE(.CONF,"2.2.2.2",2000,2,1,.ERR)
	DO EQ^MIOTASSERT(OK,0,"[T002][deny]")
	DO EQ^MIOTASSERT($GET(ERR("status")),429,"[T002][status]")
	DO EQ^MIOTASSERT($GET(ERR("routine")),"MIORATE","[T002][routine]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"rate_limited","[T002][error]")
	DO EQ^MIOTASSERT($GET(ERR("retry_after")),1,"[T002][retry]")
	QUIT
	;
	;
T003 ; refill after time passes
	NEW CONF,ERR,OK
	DO CLEAR^MIORATE
	SET CONF("server","rate","enabled")=1
	SET OK=$$ALLOWAT^MIORATE(.CONF,"3.3.3.3",3000,1,1,.ERR)
	DO EQ^MIOTASSERT(OK,1,"[T003][allow1]")
	SET OK=$$ALLOWAT^MIORATE(.CONF,"3.3.3.3",3000,1,1,.ERR)
	DO EQ^MIOTASSERT(OK,0,"[T003][deny]")
	SET OK=$$ALLOWAT^MIORATE(.CONF,"3.3.3.3",3001,1,1,.ERR)
	DO EQ^MIOTASSERT(OK,1,"[T003][allow2]")
	QUIT
	;
	;
T004 ; different IPs isolated
	NEW CONF,ERR,OK
	DO CLEAR^MIORATE
	SET CONF("server","rate","enabled")=1
	SET OK=$$ALLOWAT^MIORATE(.CONF,"4.4.4.4",4000,1,1,.ERR)
	DO EQ^MIOTASSERT(OK,1,"[T004][ip1 allow]")
	SET OK=$$ALLOWAT^MIORATE(.CONF,"4.4.4.4",4000,1,1,.ERR)
	DO EQ^MIOTASSERT(OK,0,"[T004][ip1 deny]")
	SET OK=$$ALLOWAT^MIORATE(.CONF,"5.5.5.5",4000,1,1,.ERR)
	DO EQ^MIOTASSERT(OK,1,"[T004][ip2 allow]")
	QUIT
	;
	;
T005 ; exempt list bypass
	NEW CONF,CTX,REQ,ERR,OK
	DO CLEAR^MIORATE
	SET CONF("server","rate","enabled")=1
	SET CONF("server","rate","rps")=1
	SET CONF("server","rate","burst")=1
	SET CONF("server","rate","exempt","9.9.9.9")=1
	SET CTX("remote_addr")="9.9.9.9"
	SET OK=$$ALLOW^MIORATE(.CONF,.CTX,.REQ,.ERR)
	DO EQ^MIOTASSERT(OK,1,"[T005][exempt allow]")
	QUIT
	;
	;
T006 ; trustProxy uses X-Forwarded-For first entry
	NEW CONF,CTX,REQ,ERR,OK
	DO CLEAR^MIORATE
	SET CONF("server","rate","enabled")=1
	SET CONF("server","rate","trustProxy")=1
	SET CONF("server","rate","rps")=100000
	SET CONF("server","rate","burst")=1
	SET CTX("remote_addr")="7.7.7.7"
	SET REQ("hdr","x-forwarded-for")="6.6.6.6, 7.7.7.7"
	SET OK=$$ALLOW^MIORATE(.CONF,.CTX,.REQ,.ERR)
	DO EQ^MIOTASSERT(OK,1,"[T006][allow1]")
	SET OK=$$ALLOW^MIORATE(.CONF,.CTX,.REQ,.ERR)
	DO EQ^MIOTASSERT(OK,0,"[T006][deny]")
	DO EQ^MIOTASSERT($GET(ERR("status")),429,"[T006][status]")
	QUIT
	;
	;