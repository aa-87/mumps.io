MIOROUTE ; URL router for HTTP and WebSocket routes.
; API STABILITY
; Public API labels are documented in docs/routines.
; Undocumented labels are internal.
;
; Purpose
; URL router for HTTP and WebSocket routes.
;
; Responsibilities
; - Enforce request lifecycle.
; - Keep work bounded.
; - Fail safely.
;
; Entry Points
; - INIT
; - ADDWS
; - ADDWSM
; - ADD
; - ADDM
; - COMPILE
; - ADDTRIE
; - NORM
; - MATCH
; - PREMATCH
; - GETMETA
; - DISPATCH
; - HEALTH
; - PING
; - WS
;
; Globals Used
; - ^MIO("ROUTE",...)
;
; Notes
; Keep comments short.
; Do not log secrets.
;
 ; YottaDB/GT.M
 ;
 ; Public:
 ;   DO INIT^MIOROUTE           ; reset routes and add core routes
 ;   DO ADD^MIOROUTE(m,p,h)     ; add route
 ;   DO ADDM^MIOROUTE(m,p,h,.meta) ; add route with metadata
 ;   DO ADDWS^MIOROUTE(p,h)     ; add WebSocket route (Upgrade requests)
 ;   DO ADDWSM^MIOROUTE(p,h,.meta) ; add WebSocket route with metadata
 ;   DO COMPILE^MIOROUTE        ; compile RAW into TRIE
 ;   SET ok=$$MATCH^MIOROUTE(m,path,.params,.handler,.routepat)
 ;   DO PREMATCH^MIOROUTE(.REQ,.CTX) ; store match result for current request
 ;   DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX) ; dispatch (uses PREMATCH if present)
 ;
; Entry point
; See docs/routines for details.
INIT ;
    KILL ^MIO("ROUTE")
    ; Core routes
    DO ADD("GET","/healthz","HEALTH^MIOROUTE")
    DO ADD("GET","/api/ping","PING^MIOROUTE")
    ; WebSocket endpoints should be registered under method "WS" so they only match Upgrade requests.
    DO ADDWS("/ws","ACCEPT^MIOWS")
    ; Keep legacy GET /ws handler for compatibility (will attempt upgrade if client requests it)
    DO ADD("GET","/ws","WS^MIOROUTE")
    DO ADD("GET","/bench","BENCH^MIOBENCH")
    DO ADD("GET","/metrics","METRICS^MIOMET")
    QUIT

; Entry point
; See docs/routines for details.
ADDWS(PATH,HANDLER)
    DO ADD("WS",PATH,HANDLER)
    QUIT

; Entry point
; See docs/routines for details.
ADDWSM(PATH,HANDLER,META)
    DO ADDM("WS",PATH,HANDLER,.META)
    QUIT

; Entry point
; See docs/routines for details.
ADD(METHOD,PATH,HANDLER)
    SET ^MIO("ROUTE","RAW",METHOD,PATH)=HANDLER
    KILL ^MIO("ROUTE","META",METHOD,PATH)
    QUIT

; Entry point
; See docs/routines for details.
ADDM(METHOD,PATH,HANDLER,META)
    SET ^MIO("ROUTE","RAW",METHOD,PATH)=HANDLER
    KILL ^MIO("ROUTE","META",METHOD,PATH)
    NEW K SET K=""
    FOR  SET K=$ORDER(META(K)) QUIT:K=""  DO
    . SET ^MIO("ROUTE","META",METHOD,PATH,K)=META(K)
    QUIT

; Entry point
; See docs/routines for details.
COMPILE ;
    KILL ^MIO("ROUTE","TRIE")
    NEW M,P,H
    SET M=""
    FOR  SET M=$ORDER(^MIO("ROUTE","RAW",M)) QUIT:M=""  DO
    . SET P=""
    . FOR  SET P=$ORDER(^MIO("ROUTE","RAW",M,P)) QUIT:P=""  DO
    . . SET H=$GET(^MIO("ROUTE","RAW",M,P))
    . . DO ADDTRIE(M,P,H)
    QUIT

; Entry point
; See docs/routines for details.
ADDTRIE(METHOD,PATH,HANDLER)
    NEW NODE SET NODE=$NAME(^MIO("ROUTE","TRIE",METHOD))
    NEW I,SEG,NPATH SET NPATH=$$NORM(PATH)
    FOR I=1:1:$LENGTH(NPATH,"/") DO
    . SET SEG=$PIECE(NPATH,"/",I)
    . IF SEG="" QUIT
    . IF $EXTRACT(SEG,1)=":" DO
    . . ; param node stored at "*"
    . . SET @NODE@("*","$PN")=$EXTRACT(SEG,2,999)
    . . SET NODE=$NAME(@NODE@("*"))
    . ELSE  DO
    . . SET NODE=$NAME(@NODE@(SEG))
    SET @NODE@("$HANDLER")=HANDLER
    SET @NODE@("$ROUTE")=PATH
    QUIT

; Entry point
; See docs/routines for details.
NORM(P)
    ; normalize leading slash, strip trailing slash (except root)
    NEW X SET X=$GET(P)
    IF X="" QUIT "/"
    IF $EXTRACT(X,1)'="/" SET X="/"_X
    IF $LENGTH(X)>1,$EXTRACT(X,$LENGTH(X))="/" SET X=$EXTRACT(X,1,$LENGTH(X)-1)
    QUIT X

; Entry point
; See docs/routines for details.
MATCH(METHOD,PATH,PARAMS,HANDLER,ROUTEPAT)
    KILL PARAMS
    SET HANDLER="",ROUTEPAT=""
    NEW NODE SET NODE=$NAME(^MIO("ROUTE","TRIE",METHOD))
    IF '$DATA(@NODE) QUIT 0
    NEW I,SEG,NPATH SET NPATH=$$NORM(PATH)
    FOR I=1:1:$LENGTH(NPATH,"/") DO  QUIT:NODE=""
    . SET SEG=$PIECE(NPATH,"/",I)
    . IF SEG="" QUIT
    . IF $DATA(@NODE@(SEG)) DO
    . . SET NODE=$NAME(@NODE@(SEG))
    . ELSE  IF $DATA(@NODE@("*")) DO
    . . NEW PN SET PN=$GET(@NODE@("*","$PN"))
    . . IF PN'="" SET PARAMS(PN)=SEG
    . . SET NODE=$NAME(@NODE@("*"))
    . ELSE  SET NODE="" QUIT
    IF NODE="" QUIT 0
    SET HANDLER=$GET(@NODE@("$HANDLER"))
    SET ROUTEPAT=$GET(@NODE@("$ROUTE"))
    IF HANDLER="" QUIT 0
    QUIT 1

; Entry point
; See docs/routines for details.
PREMATCH(REQ,CTX)
    KILL CTX("match")
    NEW PARAMS,H,RP,OK
    SET OK=$$MATCH($GET(REQ("method")),$GET(REQ("path")),.PARAMS,.H,.RP)
    SET CTX("match","ok")=OK
    IF 'OK QUIT
    MERGE CTX("match","params")=PARAMS
    SET CTX("match","handler")=H
    SET CTX("match","route")=RP
    QUIT

; Entry point
; See docs/routines for details.
GETMETA(METHOD,ROUTEPAT,META)
    KILL META
    NEW K SET K=""
    FOR  SET K=$ORDER(^MIO("ROUTE","META",METHOD,ROUTEPAT,K)) QUIT:K=""  DO
    . SET META(K)=$GET(^MIO("ROUTE","META",METHOD,ROUTEPAT,K))
    QUIT

; Entry point
; See docs/routines for details.
DISPATCH(DEV,CONF,REQ,CTX)
    NEW OK,H,RP,PARAMS
    IF $GET(CTX("match","ok"))=1 DO
    . SET OK=1,H=$GET(CTX("match","handler")),RP=$GET(CTX("match","route"))
    . MERGE PARAMS=CTX("match","params")
    ELSE  DO
    . SET OK=$$MATCH($GET(REQ("method")),$GET(REQ("path")),.PARAMS,.H,.RP)
    IF 'OK DO  QUIT
    . NEW OBJ SET OBJ("error")="not_found",OBJ("request_id")=$GET(CTX("request_id"))
    . DO RESPJSONX^MIOHTTP(.DEV,.CONF,404,.OBJ,$GET(CTX("request_id")),.CTX)
    . SET CTX("status")=404,CTX("route")="(not_found)"
    NEW TAG SET TAG=$PIECE(H,"^",1),RTN=$PIECE(H,"^",2)
    ; attach route + params to CTX/REQ
    SET CTX("route")=RP
    MERGE REQ("params")=PARAMS
    ; call handler: TAG^RTN(.DEV,.CONF,.REQ,.CTX)
    NEW XEC SET XEC="DO "_TAG_"^"_RTN_"(.DEV,.CONF,.REQ,.CTX)"
    XECUTE XEC
    QUIT

; ---- core handlers ----
HEALTH(DEV,CONF,REQ,CTX)
    NEW H SET H("Content-Type")="text/plain"
    DO RESPX^MIOHTTP(.DEV,.CONF,200,.H,"ok",$GET(CTX("request_id")),.CTX)
    SET CTX("status")=200
    QUIT

; Entry point
; See docs/routines for details.
PING(DEV,CONF,REQ,CTX)
    NEW OBJ SET OBJ("ok")=1,OBJ("ts")=$HOROLOG
    DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
    SET CTX("status")=200
    QUIT

; Entry point
; See docs/routines for details.
WS(DEV,CONF,REQ,CTX)
    ; generic websocket endpoint (echo)
    DO ACCEPT^MIOWS(.DEV,.CONF,.REQ,.CTX)
    QUIT
