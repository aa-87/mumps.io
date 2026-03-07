MIODOST ; Tests for connection-level DoS hardening (MIODOS).;
;
; Run:
;   YDB>D ^MIODOST
;
START
    NEW CONF,CTX1,CTX2,CTX3,ERR1,ERR2,ERR3
    KILL ^MIO("DOS")

    ; T001: active connection cap enforced deterministically
    KILL CONF SET CONF("server","dos","maxActiveConns")=1
    NEW OK1 SET OK1=$$CONNOPEN^MIODOS(.CONF,.CTX1,.ERR1)
    DO EQ^MIOTASSERT(OK1,1,"[T001][open1]")
    NEW OK2 SET OK2=$$CONNOPEN^MIODOS(.CONF,.CTX2,.ERR2)
    DO EQ^MIOTASSERT(OK2,0,"[T001][open2 denied]")
    DO EQ^MIOTASSERT($GET(ERR2("error")),"too_many_connections","[T001][err]")
    DO EQ^MIOTASSERT($GET(ERR2("routine")),"MIODOS","[T001][routine]")
    DO EQ^MIOTASSERT(+$GET(ERR2("status")),503,"[T001][status]")
    DO CONNCLOSE^MIODOS(.CTX1)
    ; after close, should admit again
    NEW OK3 SET OK3=$$CONNOPEN^MIODOS(.CONF,.CTX3,.ERR3)
    DO EQ^MIOTASSERT(OK3,1,"[T001][open3]")

    ; T002: connection lifetime expiry
    SET CONF("server","dos","maxConnSeconds")=1
    ; force t0 to be >2 seconds ago
    SET CTX3("dos","conn_t0us")=$$TSUS^MIOMET()-2000000
    DO EQ^MIOTASSERT($$CONNEXPIRED^MIODOS(.CONF,.CTX3),1,"[T002][expired]")
    DO CONNCLOSE^MIODOS(.CTX3)

    ; Cleanup
    KILL ^MIO("DOS")
    QUIT
