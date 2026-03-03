MIORATE ; Rate limiting / basic DoS controls (ROI #6)
;
; Purpose
;   Per-IP token bucket rate limiting with minimal overhead.
;
; Design
;   - Uses ^MIO("RATE","IP",ip)=lastSec^tokensMilli
;   - tokensMilli is tokens * 1000 (fixed-point)
;   - Rate (rps) and burst are configurable.
;   - Lock per-IP key to keep updates atomic.
;
; Config
;   CONF("server","rate","enabled")            default 0
;   CONF("server","rate","perIp","rps")          default 10
;   CONF("server","rate","perIp","burst")        default 20
;   CONF("server","rate","perIp","ttlSeconds")   default 3600 (resets bucket if idle beyond ttl)
;   CONF("server","rate","_testNow")              (tests only) overrides nowSec
;
; Public
;   ALLOW(CONF,CTX,REQ,ERR) -> 1 allow, 0 reject and sets ERR("routine"),ERR("error"),ERR("status")
;
ALLOW(CONF,CTX,REQ,ERR)
	KILL ERR
	IF '+$GET(CONF("server","rate","enabled"),0) QUIT 1
	NEW IP SET IP=$GET(CTX("remote_addr"))
	IF IP="" SET IP="unknown"
	NEW RPS SET RPS=+$GET(CONF("server","rate","perIp","rps"),10)
	NEW BURST SET BURST=+$GET(CONF("server","rate","perIp","burst"),20)
	IF RPS'>0 QUIT 1
	IF BURST<1 SET BURST=1
	NEW TTL SET TTL=+$GET(CONF("server","rate","perIp","ttlSeconds"),3600)
	IF TTL<1 SET TTL=3600
	NEW NOW SET NOW=$$NOWSEC(.CONF)
	NEW KEY SET KEY=$NAME(^MIO("RATE","IP",IP))
	LOCK +@KEY:0
	IF '$TEST QUIT 1  ; fail-open to avoid blocking the server
	NEW REC SET REC=$GET(@KEY)
	NEW LAST SET LAST=+$PIECE(REC,"^",1)
	NEW TOK SET TOK=+$PIECE(REC,"^",2)
	NEW CAP SET CAP=(BURST*1000)
	IF LAST'>0 SET LAST=NOW,TOK=CAP
	NEW DT SET DT=NOW-LAST
	IF DT<0 SET DT=0
	; Reset bucket after long idle (avoids stale low-token states)
	IF DT>TTL SET DT=0,TOK=CAP,LAST=NOW
	; Refill
	NEW ADD SET ADD=(DT*RPS*1000)
	SET TOK=TOK+ADD
	IF TOK>CAP SET TOK=CAP
	; Consume one token
	IF TOK<1000 DO  QUIT 0
	. SET @KEY=NOW_"^"_TOK
	. LOCK -@KEY
	. SET ERR("routine")="MIORATE"
	. SET ERR("error")="rate_limited"
	. SET ERR("status")=429
	. SET ERR("retry_after")=1
	SET TOK=TOK-1000
	SET @KEY=NOW_"^"_TOK
	LOCK -@KEY
	QUIT 1
	;
NOWSEC(CONF)
	NEW T SET T=$GET(CONF("server","rate","_testNow"))
	IF T'="" QUIT +T
	NEW H SET H=$H
	QUIT (($PIECE(H,",",1)*86400)+$PIECE(H,",",2))
	;
CLRIP(IP)
	; Test/helper: clear one IP bucket
	KILL ^MIO("RATE","IP",$GET(IP))
	QUIT
	;
GC(CONF,MAX)
	; Best-effort garbage collection for per-IP buckets.
	; Deletes up to MAX entries that have been idle longer than ttlDeleteSeconds.
	; Not used on hot path; safe to run periodically.
	NEW LIM SET LIM=+$GET(MAX,100)
	IF LIM<1 QUIT
	NEW TTLDEL SET TTLDEL=+$GET(CONF("server","rate","perIp","ttlDeleteSeconds"),86400)
	IF TTLDEL<60 SET TTLDEL=86400
	NEW NOW SET NOW=$$NOWSEC(.CONF)
	NEW IP SET IP=""
	FOR  SET IP=$ORDER(^MIO("RATE","IP",IP)) QUIT:IP=""!(LIM<1)  DO
	. NEW REC SET REC=$GET(^MIO("RATE","IP",IP))
	. NEW LAST SET LAST=+$PIECE(REC,"^",1)
	. IF LAST>0,(NOW-LAST)>TTLDEL DO
	. . KILL ^MIO("RATE","IP",IP)
	. . SET LIM=LIM-1
	QUIT
