MIORATE ; Per-IP token bucket rate limiter (globals-only, deterministic)
;
; Purpose
;   Fast, deterministic per-IP rate limiting using globals only.
;   Designed for MIOD (before routing) and for tests via ALLOWAT.
;
; Public API
;   $$ALLOW(.CONF,.CTX,.REQ,.ERR)  -> 1 allow, 0 deny (sets ERR)
;
; Internal (tests)
;   $$ALLOWAT(.CONF,IP,NOW,RPS,BURST,.ERR) -> 1/0
;   CLEAR  -> clears limiter state
;
; Errors (when denied)
;   ERR("routine")="MIORATE"
;   ERR("error")="rate_limited"
;   ERR("status")=429
;   ERR("retry_after")=<seconds>
;
; Config (optional)
;   CONF("server","rate","enabled")=1
;   CONF("server","rate","rps")=10
;   CONF("server","rate","burst")=20
;   CONF("server","rate","trustProxy")=0
;   CONF("server","rate","exempt",ip)=1
;
; Storage
;   ^MIO("RATE","ip",ip,"t")   = last timestamp (absolute seconds)
;   ^MIO("RATE","ip",ip,"tok") = tokens in milli-tokens (integer)
;
	; ROI #6 (YottaDB/GT.M)
	;

ALLOW(CONF,CTX,REQ,ERR)
	KILL ERR
	; Disabled => allow
	IF +$GET(CONF("server","rate","enabled"),0)=0 QUIT 1
	NEW RPS,BURST
	SET RPS=+$GET(CONF("server","rate","rps"),10)
	SET BURST=+$GET(CONF("server","rate","burst"),20)
	; Fail-open on misconfig
	IF RPS<1!(BURST<1) QUIT 1
	NEW IP SET IP=$$IP(.CONF,.CTX,.REQ)
	IF IP="" QUIT 1
	IF $GET(CONF("server","rate","exempt",IP)) QUIT 1
	NEW NOW SET NOW=$$NOWSEC()
	QUIT $$ALLOWAT(.CONF,IP,NOW,RPS,BURST,.ERR)
	;

ALLOWAT(CONF,IP,NOW,RPS,BURST,ERR)
	; Deterministic token bucket using integer milli-tokens.
	KILL ERR
	NEW KEY SET KEY=$NAME(^MIO("RATE","ip",IP))
	; Best-effort lock; fail-open if contention
	LOCK +@KEY:0
	IF '$TEST QUIT 1
	NEW TOKM,LAST
	SET TOKM=+$GET(@KEY@("tok"),BURST*1000)
	SET LAST=+$GET(@KEY@("t"),NOW)
	IF LAST>NOW SET LAST=NOW
	NEW ELAP SET ELAP=NOW-LAST
	IF ELAP>0 DO
	. NEW ADDM SET ADDM=ELAP*(RPS*1000)
	. SET TOKM=TOKM+ADDM
	. NEW MAXM SET MAXM=BURST*1000
	. IF TOKM>MAXM SET TOKM=MAXM
	. SET LAST=NOW
	; Consume 1 token (1000 milli)
	IF TOKM'<1000 DO  QUIT 1
	. SET TOKM=TOKM-1000
	. SET @KEY@("tok")=TOKM
	. SET @KEY@("t")=LAST
	. LOCK -@KEY
	; Deny
	NEW NEEDM SET NEEDM=1000-TOKM
	NEW RPSM SET RPSM=RPS*1000
	NEW RETRY SET RETRY=$$CEILDIV(NEEDM,RPSM)
	IF RETRY<1 SET RETRY=1
	SET @KEY@("tok")=TOKM
	SET @KEY@("t")=LAST
	LOCK -@KEY
	SET ERR("routine")="MIORATE"
	SET ERR("error")="rate_limited"
	SET ERR("status")=429
	SET ERR("retry_after")=RETRY
	SET ERR("limit_rps")=RPS
	SET ERR("burst")=BURST
	SET ERR("remaining")=$SELECT(TOKM>0:(TOKM\1000),1:0)
	QUIT 0
	;

CLEAR
	KILL ^MIO("RATE")
	QUIT
	;

IP(CONF,CTX,REQ)
	NEW IP
	SET IP=$GET(CTX("remote_addr"))
	IF IP="" SET IP=$GET(REQ("remote_addr"))
	IF +$GET(CONF("server","rate","trustProxy"),0) DO
	. NEW XFF SET XFF=$GET(REQ("hdr","x-forwarded-for"))
	. IF XFF="" QUIT
	. NEW FIRST SET FIRST=$$TRIM($PIECE(XFF,",",1))
	. IF FIRST'="" SET IP=FIRST
	QUIT IP
	;

NOWSEC()
	NEW H SET H=$HOROLOG
	QUIT ($PIECE(H,",",1)*86400)+$PIECE(H,",",2)
	;

CEILDIV(A,B)
	; ceil(A/B), integers
	IF B<1 QUIT 0
	IF A'>0 QUIT 0
	QUIT (A+B-1)\B
	;

TRIM(S)
	NEW X SET X=$GET(S)
	FOR  QUIT:$EXTRACT(X,1)'=" "  SET X=$EXTRACT(X,2,$L(X))
	FOR  QUIT:$L(X)=0  QUIT:$EXTRACT(X,$L(X))'=" "  SET X=$EXTRACT(X,1,$L(X)-1)
	QUIT X
	;
