MIOROUTE ; URL router for HTTP and WebSocket routes.;
;
; Production router for the MIO web server.;
;
; Routing model
; - Segment trie per METHOD.;
; - Segment types:
;     static:   /users/me
;     param:    /users/:id
;     wildcard: /static/*path   (catch-all, MUST be last segment)
;
; Precedence per segment
;   static > param > wildcard
;
; Policy knobs (optional, defaults preserve legacy behavior):
;   ^MIO("CONF","server","routing","ignoreTrailingSlash") = 1|0 (default 1)
;   ^MIO("CONF","server","routing","plusAsSpaceInPath")   = 1|0 (default 1)
;
; Notes on 405
;   We only return 405 if the same concrete path matches a NON-wildcard route
;   for at least one other method. Wildcard-only matches do NOT trigger 405.;
;
; Globals
;   ^MIO("ROUTE","RAW",method,path)=handler
;   ^MIO("ROUTE","META",method,path,key)=value
;   ^MIO("ROUTE","SEQ")=n
;   ^MIO("ROUTE","ORDER",method,seq)=path        ; registration order
;   ^MIO("ROUTE","LAST",method,path)=seq         ; last definition wins
;   ^MIO("ROUTE","TRIE",method,...)              ; compiled trie
;   ^MIO("ROUTE","COMPILE",...)                  ; compile report
;
; ---------------------------------------------------------------------
	;
INIT ;
	KILL ^MIO("ROUTE")
	; Core routes
	DO ADD("GET","/healthz","HEALTH^MIOROUTE")
	DO ADD("GET","/readyz","READY^MIOHEALTH")
	DO ADD("GET","/api/ping","PING^MIOROUTE")
	; WebSocket endpoints should be registered under method "WS"
	DO ADDWS("/ws","ACCEPT^MIOWS")
	; Legacy GET /ws (attempt upgrade)
	DO ADD("GET","/ws","WS^MIOROUTE")
	DO ADD("GET","/bench","BENCH^MIOBENCH")
	DO ADD("GET","/metrics","METRICS^MIOMET")
	QUIT
	;
ADDWS(PATH,HANDLER)
	DO ADD("WS",PATH,HANDLER)
	QUIT
	;
ADDWSM(PATH,HANDLER,META)
	DO ADDM("WS",PATH,HANDLER,.META)
	QUIT
	;
ADD(METHOD,PATH,HANDLER)
	SET ^MIO("ROUTE","RAW",METHOD,PATH)=HANDLER
	KILL ^MIO("ROUTE","META",METHOD,PATH)
	DO ORDADD(METHOD,PATH)
	QUIT
	;
ADDM(METHOD,PATH,HANDLER,META)
	SET ^MIO("ROUTE","RAW",METHOD,PATH)=HANDLER
	KILL ^MIO("ROUTE","META",METHOD,PATH)
	NEW K SET K=""
	FOR  SET K=$ORDER(META(K)) QUIT:K=""  DO
	. SET ^MIO("ROUTE","META",METHOD,PATH,K)=META(K)
	DO ORDADD(METHOD,PATH)
	QUIT
	;
; Record registration order and "last wins" marker.;
; Keeps compile deterministic and supports safe re-definition.;
ORDADD(METHOD,PATH)
	NEW S SET S=$INCREMENT(^MIO("ROUTE","SEQ"))
	SET ^MIO("ROUTE","ORDER",METHOD,S)=PATH
	SET ^MIO("ROUTE","LAST",METHOD,PATH)=S
	QUIT
	;
COMPILE ;
	NEW ERR,OK
	SET OK=$$COMPILEX(.ERR)
	KILL ^MIO("ROUTE","COMPILE")
	SET ^MIO("ROUTE","COMPILE","ok")=OK
	MERGE ^MIO("ROUTE","COMPILE","err")=ERR
	QUIT
	;
; Compile RAW into TRIE.;
; Returns 1 if ok, else 0. Populates ERR().;
COMPILEX(ERR)
	KILL ERR
	SET ERR("routine")="MIOROUTE"
	KILL ^MIO("ROUTE","TRIE")
	NEW OK SET OK=1
	;
	IF $DATA(^MIO("ROUTE","ORDER")) DO COMPO QUIT OK
	DO COMPF
	QUIT OK
	;
COMPO ; compile using ORDER/LAST (registration order, last definition wins)
	NEW M,S,P,H,OK2
	SET M=""
	FOR  SET M=$ORDER(^MIO("ROUTE","ORDER",M)) QUIT:M=""  DO
	. SET S=0
	. FOR  SET S=$ORDER(^MIO("ROUTE","ORDER",M,S)) QUIT:'S  DO
	. . SET P=$GET(^MIO("ROUTE","ORDER",M,S)) QUIT:P=""
	. . IF $GET(^MIO("ROUTE","LAST",M,P))'=S QUIT  ; stale
	. . SET H=$GET(^MIO("ROUTE","RAW",M,P))
	. . IF H="" DO  QUIT
	. . . DO ERRADD(.ERR,"empty_handler",M,P,"")
	. . . SET OK=0
	. . SET OK2=$$ADDTRIE2(M,P,H,.ERR)
	. . IF 'OK2 SET OK=0
	QUIT
	;
COMPF ; fallback: compile by RAW collation (older data)
	NEW M,P,H,OK2
	SET M=""
	FOR  SET M=$ORDER(^MIO("ROUTE","RAW",M)) QUIT:M=""  DO
	. SET P=""
	. FOR  SET P=$ORDER(^MIO("ROUTE","RAW",M,P)) QUIT:P=""  DO
	. . SET H=$GET(^MIO("ROUTE","RAW",M,P))
	. . IF H="" DO  QUIT
	. . . DO ERRADD(.ERR,"empty_handler",M,P,"")
	. . . SET OK=0
	. . SET OK2=$$ADDTRIE2(M,P,H,.ERR)
	. . IF 'OK2 SET OK=0
	QUIT
ADDTRIE(METHOD,PATH,HANDLER)
	NEW ERR
	DO ADDTRIE2(METHOD,PATH,HANDLER,.ERR)
	QUIT
	;
; Internal: add to trie with validation and conflict detection.;
; Returns 1 on success, 0 on error (route skipped).;
ADDTRIE2(METHOD,PATH,HANDLER,ERR)
	NEW NODE SET NODE=$NAME(^MIO("ROUTE","TRIE",METHOD))
	NEW I,SEG,NPATH,SEGCNT
	SET NPATH=$$NORM(PATH)
	SET SEGCNT=$LENGTH(NPATH,"/")
	FOR I=1:1:SEGCNT DO  QUIT:NODE=""
	. SET SEG=$PIECE(NPATH,"/",I)
	. IF SEG="" QUIT
	. ; param segment
	. IF $EXTRACT(SEG,1)=":" DO  QUIT
	. . NEW PN SET PN=$EXTRACT(SEG,2,999)
	. . IF PN="" DO  SET NODE="" QUIT
	. . . DO ERRADD(.ERR,"invalid_param",METHOD,PATH,"empty_param_name")
	. . ; param node stored at "*"
	. . IF $DATA(@NODE@("*","$PN")),$GET(@NODE@("*","$PN"))'=PN DO  SET NODE="" QUIT
	. . . DO ERRADD(.ERR,"param_conflict",METHOD,PATH,"existing="_$GET(@NODE@("*","$PN"))_",new="_PN)
	. . SET @NODE@("*","$PN")=PN
	. . SET NODE=$NAME(@NODE@("*"))
	. ; wildcard segment (catch-all) must be last
	. IF $EXTRACT(SEG,1)="*" DO  QUIT
	. . NEW PN SET PN=$EXTRACT(SEG,2,999)
	. . IF PN="" SET PN="splat"
	. . NEW J,LASTOK SET LASTOK=1
	. . FOR J=I+1:1:SEGCNT IF $PIECE(NPATH,"/",J)'="" SET LASTOK=0
	. . IF 'LASTOK DO  SET NODE="" QUIT
	. . . DO ERRADD(.ERR,"wildcard_not_last",METHOD,PATH,"segment="_SEG)
	. . IF $DATA(@NODE@("$WC","$HANDLER")) DO  SET NODE="" QUIT
	. . . DO ERRADD(.ERR,"wildcard_conflict",METHOD,PATH,"existing="_$GET(@NODE@("$WC","$ROUTE")))
	. . SET @NODE@("$WC","$PN")=PN
	. . SET NODE=$NAME(@NODE@("$WC"))
	. . SET I=SEGCNT
	. ; static segment
	. SET NODE=$NAME(@NODE@(SEG))
	;
	IF NODE="" QUIT 0
	;
	; leaf already has a handler:
	; - same route pattern: allow override
	; - different route pattern: conflict
	IF $DATA(@NODE@("$HANDLER")) QUIT $$LEAFUPD(NODE,METHOD,PATH,HANDLER,.ERR)
	;
	SET @NODE@("$HANDLER")=HANDLER
	SET @NODE@("$ROUTE")=PATH
	QUIT 1
	;
LEAFUPD(NODE,METHOD,PATH,HANDLER,ERR)
	NEW EX SET EX=$GET(@NODE@("$ROUTE"))
	IF EX'="",EX'=PATH DO ERRADD(.ERR,"leaf_conflict",METHOD,PATH,"existing="_EX) QUIT 0
	SET @NODE@("$HANDLER")=HANDLER
	SET @NODE@("$ROUTE")=PATH
	QUIT 1
	;
NORM(P)
	NEW X SET X=$GET(P)
	IF X="" QUIT "/"
	IF $EXTRACT(X,1)'="/" SET X="/"_X
	IF $$IGNORETS() DO
	. IF $LENGTH(X)>1,$EXTRACT(X,$LENGTH(X))="/" SET X=$EXTRACT(X,1,$LENGTH(X)-1)
	ELSE  DO
	. IF $LENGTH(X)>1,$EXTRACT(X,$LENGTH(X))="/" SET X=$EXTRACT(X,1,$LENGTH(X)-1)_"/$TS"
	QUIT X
	;
IGNORETS()
	NEW V SET V=$GET(^MIO("CONF","server","routing","ignoreTrailingSlash"))
	IF V="" QUIT 1
	QUIT +V
	;
PLUSPATH()
	NEW V SET V=$GET(^MIO("CONF","server","routing","plusAsSpaceInPath"))
	IF V="" QUIT 1
	QUIT +V
	;
;
; Strip query string from a path (defensive; router expects path-only).;
PATHONLY(P)
	QUIT $PIECE($GET(P),"?",1)
	;
; URL-decode for querystrings/forms (always '+' => space, %HH => byte).;
; Invalid % sequences are preserved literally.;
URLDEC(S)
	NEW Y,OUT,I,L,C,HEX,B
	SET Y=$TRANSLATE($GET(S),"+"," ")
	SET OUT="",L=$LENGTH(Y),I=1
	FOR  QUIT:I>L  DO
	. SET C=$EXTRACT(Y,I)
	. IF C="%",(I+2)'>L DO  QUIT
	. . SET HEX=$EXTRACT(Y,I+1,I+2)
	. . SET B=$$HEX2DEC(HEX)
	. . IF B'<0 SET OUT=OUT_$CHAR(B),I=I+3 QUIT
	. . SET OUT=OUT_"%",I=I+1
	. SET OUT=OUT_C
	. SET I=I+1
	QUIT OUT
	;
HEX2DEC(HH)
	NEW A,B
	SET A=$$HEXVAL($EXTRACT($GET(HH),1))
	SET B=$$HEXVAL($EXTRACT($GET(HH),2))
	IF A<0!(B<0) QUIT -1
	QUIT (A*16)+B
	;
HEXVAL(C)
	NEW U,P
	SET U=$ZCONVERT($GET(C),"U")
	SET P=$FIND("0123456789ABCDEF",U)
	QUIT $SELECT(P=0:-1,1:P-2)
	;
; Decode a PATH segment (fast path if no decoding needed).;
	;
SEGDEC(S)
	NEW HASP,PL
	SET HASP=(S["%")
	SET PL=$$PLUSPATH()
	; fast path: no percent, and either no plus decoding or no '+' present
	IF 'HASP,(('PL)!(S'["+")) QUIT S
	IF PL QUIT $$URLDEC(S)
	IF 'HASP QUIT S
	QUIT $$URLDECPATH(S)
	;
URLDECPATH(S)
	NEW I,C,OUT,H,D
	SET OUT=""
	FOR I=1:1:$LENGTH($GET(S)) DO
	. SET C=$EXTRACT(S,I)
	. IF C'="%" SET OUT=OUT_C QUIT
	. SET H=$EXTRACT(S,I+1,I+2)
	. IF $LENGTH(H)=2 DO  QUIT
	. . SET D=$$HEX2DEC(H)
	. . IF D'<0 SET OUT=OUT_$CHAR(D),I=I+2 QUIT
	. . SET OUT=OUT_"%"
	. SET OUT=OUT_"%"
	QUIT OUT
	;
; Public matcher (compatible signature).;
MATCH(METHOD,PATH,PARAMS,HANDLER,ROUTEPAT)
	NEW FLAGS
	QUIT $$MATCHX(METHOD,PATH,.PARAMS,.HANDLER,.ROUTEPAT,.FLAGS)
	;
; Extended matcher.;
; FLAGS("wild")=1 if wildcard branch used.;
; FLAGS("param")=1 if param branch used.;
MATCHX(METHOD,PATH,PARAMS,HANDLER,ROUTEPAT,FLAGS)
	; Backtracking matcher.;
	; Allows falling back from a higher-precedence branch (static/param) to a lower one
	; when the higher-precedence route cannot consume the full path.;
	;
	KILL PARAMS,FLAGS
	SET HANDLER="",ROUTEPAT=""
	SET PATH=$$PATHONLY(PATH)
	NEW NPATH,SEGCNT,NODE
	SET NODE=$NAME(^MIO("ROUTE","TRIE",METHOD))
	IF '$DATA(@NODE) QUIT 0
	SET NPATH=$$NORM(PATH)
	SET SEGCNT=$LENGTH(NPATH,"/")
	NEW I,SEG,STATIC,PN,REST
	NEW FB,FBN,PLST,PNUM
	NEW FAIL
	SET I=1,FBN=0,PNUM=0,FAIL=0
	;
	; Outer loop: attempt match, backtracking as needed.;
	FOR  QUIT:FAIL  DO
	. ; Traverse segments until end, or until we must backtrack.;
	. FOR  QUIT:(I>SEGCNT)!(FAIL)  DO
	. . SET SEG=$PIECE(NPATH,"/",I)
	. . IF SEG="" SET I=I+1 QUIT
	. . SET SEG=$$SEGDEC(SEG)
	. . ; Record fallback branches (LIFO). Push wildcard first, then param.;
	. . IF $DATA(@NODE@("$WC")) DO
	. . . SET FBN=FBN+1
	. . . SET FB(FBN,"type")="wild"
	. . . SET FB(FBN,"node")=$NAME(@NODE@("$WC"))
	. . . SET FB(FBN,"i")=I
	. . . SET FB(FBN,"pnum")=PNUM
	. . . SET FB(FBN,"pn")=$GET(@NODE@("$WC","$PN")) IF FB(FBN,"pn")="" SET FB(FBN,"pn")="splat"
	. . SET STATIC=$DATA(@NODE@(SEG))
	. . IF STATIC,$DATA(@NODE@("*")) DO
	. . . SET FBN=FBN+1
	. . . SET FB(FBN,"type")="param"
	. . . SET FB(FBN,"node")=$NAME(@NODE@("*"))
	. . . SET FB(FBN,"i")=I+1
	. . . SET FB(FBN,"pnum")=PNUM
	. . . SET FB(FBN,"pn")=$GET(@NODE@("*","$PN"))
	. . . SET FB(FBN,"seg")=SEG
	. . ; Choose branch by precedence.;
	. . IF STATIC DO  QUIT
	. . . SET NODE=$NAME(@NODE@(SEG))
	. . . SET I=I+1
	. . IF $DATA(@NODE@("*")) DO  QUIT
	. . . SET PN=$GET(@NODE@("*","$PN"))
	. . . IF PN'="" DO PSET(PN,SEG,.PARAMS,.PLST,.PNUM)
	. . . SET FLAGS("param")=1
	. . . SET NODE=$NAME(@NODE@("*"))
	. . . SET I=I+1
	. . IF $DATA(@NODE@("$WC")) DO  QUIT
	. . . SET PN=$GET(@NODE@("$WC","$PN")) IF PN="" SET PN="splat"
	. . . SET REST=$$RESTPATH(NPATH,I,SEGCNT)
	. . . DO PSET(PN,REST,.PARAMS,.PLST,.PNUM)
	. . . SET FLAGS("wild")=1
	. . . SET NODE=$NAME(@NODE@("$WC"))
	. . . SET I=SEGCNT+1
	. . ; No branch matched: backtrack.;
	. . NEW BOK DO BKT(.I,.NODE,NPATH,SEGCNT,.PARAMS,.PLST,.PNUM,.FB,.FBN,.FLAGS,.BOK)
	. . IF 'BOK SET FAIL=1
	. IF FAIL QUIT
	. ; End of path. Accept only if leaf has handler, else backtrack.;
	. SET HANDLER=$GET(@NODE@("$HANDLER"))
	. SET ROUTEPAT=$GET(@NODE@("$ROUTE"))
	. IF HANDLER'="" SET FAIL=2 QUIT
	. ; Allow wildcard child to match empty remainder.;
	. IF $DATA(@NODE@("$WC","$HANDLER")) DO  SET FAIL=2 QUIT
	. . SET PN=$GET(@NODE@("$WC","$PN")) IF PN="" SET PN="splat"
	. . DO PSET(PN,"",.PARAMS,.PLST,.PNUM)
	. . SET FLAGS("wild")=1
	. . SET NODE=$NAME(@NODE@("$WC"))
	. . SET HANDLER=$GET(@NODE@("$HANDLER"))
	. . SET ROUTEPAT=$GET(@NODE@("$ROUTE"))
	. ; No handler: backtrack and try another branch.;
	. NEW BOK DO BKT(.I,.NODE,NPATH,SEGCNT,.PARAMS,.PLST,.PNUM,.FB,.FBN,.FLAGS,.BOK)
	. IF 'BOK SET FAIL=1
	;
	IF FAIL'=2 QUIT 0
	QUIT 1
	;
	; Set a param value and track insertion order for backtracking.;
PSET(PN,VAL,PARAMS,PLST,PNUM)
	IF '$DATA(PARAMS(PN)) SET PNUM=PNUM+1,PLST(PNUM)=PN
	SET PARAMS(PN)=VAL
	QUIT
	;
	; Clear params back to snapshot OLDPNUM.;
PCLR(PARAMS,PLST,PNUM,OLDPNUM)
	NEW J
	FOR J=PNUM:-1:(OLDPNUM+1) DO
	. KILL PARAMS(PLST(J))
	. KILL PLST(J)
	SET PNUM=OLDPNUM
	QUIT
	;
	; Backtrack to the most recent fallback.;
	; Returns BOK=1 if resumed, else BOK=0 if no fallbacks remain.;
BKT(I,NODE,NPATH,SEGCNT,PARAMS,PLST,PNUM,FB,FBN,FLAGS,BOK)
	SET BOK=0
	FOR  QUIT:FBN<1  DO  QUIT:BOK
	. NEW T,OLD,PN,REST
	. SET T=$GET(FB(FBN,"type"))
	. SET NODE=$GET(FB(FBN,"node"))
	. SET I=+$GET(FB(FBN,"i"))
	. SET OLD=+$GET(FB(FBN,"pnum"))
	. DO PCLR(.PARAMS,.PLST,.PNUM,OLD)
	. IF T="param" DO
	. . SET PN=$GET(FB(FBN,"pn"))
	. . IF PN'="" DO PSET(PN,$GET(FB(FBN,"seg")),.PARAMS,.PLST,.PNUM)
	. . SET FLAGS("param")=1
	. ELSE  IF T="wild" DO
	. . SET PN=$GET(FB(FBN,"pn")) IF PN="" SET PN="splat"
	. . SET REST=$$RESTPATH(NPATH,+$GET(FB(FBN,"i")),SEGCNT)
	. . DO PSET(PN,REST,.PARAMS,.PLST,.PNUM)
	. . SET FLAGS("wild")=1
	. . SET I=SEGCNT+1
	. KILL FB(FBN)
	. SET FBN=FBN-1
	. SET BOK=1
	QUIT
	;
RESTPATH(NPATH,START,SEGCNT)
	NEW J,SEG,OUT
	SET OUT=""
	FOR J=START:1:SEGCNT DO
	. SET SEG=$PIECE(NPATH,"/",J)
	. IF SEG="" QUIT
	. SET SEG=$$SEGDEC(SEG)
	. IF OUT="" SET OUT=SEG
	. ELSE  SET OUT=OUT_"/"_SEG
	QUIT OUT
	;
ERRADD(ERR,TYPE,METHOD,PATH,INFO)
	NEW N SET N=$GET(ERR("n"))+1
	SET ERR("n")=N
	SET ERR(N,"routine")="MIOROUTE"
	SET ERR(N,"type")=$GET(TYPE)
	SET ERR(N,"method")=$GET(METHOD)
	SET ERR(N,"path")=$GET(PATH)
	SET ERR(N,"info")=$GET(INFO)
	QUIT
	;
PREMATCH(REQ,CTX)
	KILL CTX("match")
	NEW PARAMS,H,RP,OK
	SET OK=$$MATCH($GET(REQ("method")),$$PATHONLY($GET(REQ("path"))),.PARAMS,.H,.RP)
	SET CTX("match","ok")=OK
	IF 'OK QUIT
	MERGE CTX("match","params")=PARAMS
	SET CTX("match","handler")=H
	SET CTX("match","route")=RP
	QUIT
	;
GETMETA(METHOD,ROUTEPAT,META)
	KILL META
	NEW K SET K=""
	FOR  SET K=$ORDER(^MIO("ROUTE","META",METHOD,ROUTEPAT,K)) QUIT:K=""  DO
	. SET META(K)=$GET(^MIO("ROUTE","META",METHOD,ROUTEPAT,K))
	QUIT
	;
; 405 Allow computation.;
; Only counts allowed methods that match without wildcard.;
FINDALLOWED(PATH,CURRENT,ALLOW)
	KILL ALLOW
	NEW M SET M=""
	FOR  SET M=$ORDER(^MIO("ROUTE","TRIE",M)) QUIT:M=""  DO
	. IF M=CURRENT QUIT
	. IF M="WS" QUIT
	. NEW P,H,RP,OK,FL
	. SET OK=$$MATCHX(M,PATH,.P,.H,.RP,.FL)
	. IF 'OK QUIT
	. IF $GET(FL("wild")) QUIT
	. SET ALLOW(M)=1
	QUIT $DATA(ALLOW)>0
	;
DISPATCH(DEV,CONF,REQ,CTX)
	NEW OK,H,RP,PARAMS,METHOD
	; Request timing base (microseconds) for metrics/logging
	IF +$GET(CTX("t0us"))<1 SET CTX("t0us")=$$TSUS^MIOMET()
	; Fast path: use PREMATCH results when available
	IF $GET(CTX("match","ok"))=1 DO
	. SET OK=1,H=$GET(CTX("match","handler")),RP=$GET(CTX("match","route"))
	. MERGE PARAMS=CTX("match","params")
	ELSE  DO
	. SET OK=$$MATCH($GET(REQ("method")),$$PATHONLY($GET(REQ("path"))),.PARAMS,.H,.RP)
	SET METHOD=$GET(REQ("method"))
	;
	; No route match -> 405 (when non-wildcard match exists for another method) else 404
	IF 'OK DO
	. NEW ALLOW,ANY,ASTR,M,HEAD,OBJ,BODY
	. NEW MWERR,MWOK,NWONOK,ABORT
	. SET ABORT=0
	. ; Run global middleware (if configured) even on 404/405
	. SET NWONOK=$$MWANY(.CONF,METHOD,"")
	. IF NWONOK DO
	. . SET MWOK=$$MWBEFORE(.DEV,.CONF,.REQ,.CTX,METHOD,"",.MWERR)
	. . IF 'MWOK DO
	. . . IF +$GET(CTX("status"))<1 DO MWRESPERR(.DEV,.CONF,.REQ,.CTX,.MWERR)
	. . . DO MWAFTER(.DEV,.CONF,.REQ,.CTX,METHOD,"",.MWERR)
	. . . SET ABORT=1
	. IF ABORT QUIT
	. ;
	. SET ANY=$$FINDALLOWED($GET(REQ("path")),$GET(REQ("method")),.ALLOW)
	. IF ANY DO
	. . SET ASTR="",M=""
	. . FOR  SET M=$ORDER(ALLOW(M)) QUIT:M=""  SET ASTR=ASTR_$SELECT(ASTR'="":", ",1:"")_M
	. . SET HEAD("Content-Type")="application/json"
	. . SET HEAD("Allow")=ASTR
	. . SET OBJ("error")="method_not_allowed"
	. . SET OBJ("allowed")=ASTR
	. . SET OBJ("routine")="MIOROUTE"
	. . SET OBJ("request_id")=$GET(CTX("request_id"))
	. . SET BODY=$$EN^MIOJSON1(.OBJ)
	. . DO RESPX^MIOHTTP(.DEV,.CONF,405,.HEAD,BODY,$GET(CTX("request_id")),.CTX)
	. . SET CTX("route")="(method_not_allowed)"
	. . SET CTX("error")="method_not_allowed"
	. ELSE  DO
	. . SET OBJ("error")="not_found"
	. . SET OBJ("routine")="MIOROUTE"
	. . SET OBJ("request_id")=$GET(CTX("request_id"))
	. . DO RESPJSONX^MIOHTTP(.DEV,.CONF,404,.OBJ,$GET(CTX("request_id")),.CTX)
	. . SET CTX("route")="(not_found)"
	. . SET CTX("error")="not_found"
	. ;
	. IF NWONOK DO MWAFTER(.DEV,.CONF,.REQ,.CTX,METHOD,"",.MWERR)
	IF 'OK QUIT
	;
	; Matched route
	SET CTX("route")=RP
	MERGE REQ("params")=PARAMS
	;
	NEW TAG,RTN
	SET TAG=$PIECE($GET(H),"^",1),RTN=$PIECE($GET(H),"^",2)
	IF TAG=""!(RTN="") DO  QUIT
	. NEW EOBJ
	. SET EOBJ("error")="empty_handler"
	. SET EOBJ("routine")="MIOROUTE"
	. SET EOBJ("request_id")=$GET(CTX("request_id"))
	. DO RESPJSONX^MIOHTTP(.DEV,.CONF,500,.EOBJ,$GET(CTX("request_id")),.CTX)
	. SET CTX("status")=500
	. SET CTX("route")="(empty_handler)"
	;
	NEW MWERR,MWOK,NWONOK,ABORT
	SET ABORT=0
	SET NWONOK=$$MWANY(.CONF,METHOD,RP)
	IF NWONOK DO
	. SET MWOK=$$MWBEFORE(.DEV,.CONF,.REQ,.CTX,METHOD,RP,.MWERR)
	. IF 'MWOK DO
	. . IF +$GET(CTX("status"))<1 DO MWRESPERR(.DEV,.CONF,.REQ,.CTX,.MWERR)
	. . SET CTX("error")=$GET(MWERR("error"))
	. . DO MWAFTER(.DEV,.CONF,.REQ,.CTX,METHOD,RP,.MWERR)
	. . SET ABORT=1
	IF ABORT QUIT
	;
	; Handler timing (microseconds)
	SET CTX("met","h0us")=$$TSUS^MIOMET()
	DO @(TAG_"^"_RTN_"(.DEV,.CONF,.REQ,.CTX)")
	SET CTX("met","h1us")=$$TSUS^MIOMET()
	IF +$GET(CTX("met","h0us"))>0,+$GET(CTX("met","h1us"))'>+$GET(CTX("met","h0us")) DO
	. SET CTX("met","handler_ms")=((CTX("met","h1us")-CTX("met","h0us"))/1000)
	IF NWONOK DO MWAFTER(.DEV,.CONF,.REQ,.CTX,METHOD,RP,.MWERR)
	QUIT
	;
	;
; ---- middleware pipeline (ROI #8) -------------------------------------
MWANY(CONF,METHOD,ROUTEPAT)
	NEW X SET X=0
	IF $DATA(CONF("server","middleware","before")) SET X=1
	IF $DATA(CONF("server","middleware","after")) SET X=1
	IF X QUIT 1
	IF $GET(METHOD)'="",$GET(ROUTEPAT)'="" DO
	. IF $DATA(^MIO("ROUTE","META",METHOD,ROUTEPAT,"mw_before")) SET X=1
	. IF $DATA(^MIO("ROUTE","META",METHOD,ROUTEPAT,"mw_after")) SET X=1
	QUIT X
	;
MWLIST(CONF,METHOD,ROUTEPAT,PHASE,LIST)
	KILL LIST
	NEW N SET N=0
	NEW I SET I=""
	FOR  SET I=$ORDER(CONF("server","middleware",PHASE,I)) QUIT:I=""  DO
	. NEW E SET E=$GET(CONF("server","middleware",PHASE,I))
	. IF E'="" SET N=N+1,LIST(N)=E
	NEW STR SET STR=$GET(^MIO("ROUTE","META",METHOD,ROUTEPAT,"mw_"_PHASE))
	IF STR'="" DO
	. NEW J,E
	. FOR J=1:1:$L(STR,",") DO
	. . SET E=$$TRIM^MIOHTTP($P(STR,",",J))
	. . IF E'="" SET N=N+1,LIST(N)=E
	QUIT
	;
	; Execute ENT="TAG^RTN" as an extrinsic: OK=$$TAG^RTN(.DEV,.CONF,.REQ,.CTX,.ERR)
MWEX(ENT,DEV,CONF,REQ,CTX,ERR)
	NEW TAG,RTN,CMD,OK
	SET OK=0
	SET TAG=$PIECE($GET(ENT),"^",1),RTN=$PIECE($GET(ENT),"^",2)
	IF TAG=""!(RTN="") DO  QUIT 0
	. SET ERR("routine")="MIOROUTE",ERR("error")="middleware_bad_entry",ERR("status")=500
	IF '$$ISID(TAG)!'$$ISID(RTN) DO  QUIT 0
	. SET ERR("routine")="MIOROUTE",ERR("error")="middleware_bad_entry",ERR("status")=500
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" SET ERR(""routine"")=""MIOROUTE"" SET ERR(""error"")=""middleware_exception|""_$ZSTATUS SET ERR(""status"")=500 SET OK=0"
	SET CMD="OK=$$"_TAG_"^"_RTN_"(.DEV,.CONF,.REQ,.CTX,.ERR)",@CMD
	;XECUTE CMD
	QUIT +$GET(OK)
	;
ISID(S)
	NEW I,C,OK
	SET S=$GET(S)
	IF S="" QUIT 0
	SET C=$EXTRACT(S,1)
	SET OK=$SELECT((C?1A)!(C="%"):1,1:0)
	IF 'OK QUIT 0
	FOR I=2:1:$LENGTH(S) DO  QUIT:'OK
	. SET C=$EXTRACT(S,I)
	. IF '(C?1AN) SET OK=0
	QUIT OK
	;
MWBEFORE(DEV,CONF,REQ,CTX,METHOD,ROUTEPAT,ERR)
	KILL ERR
	NEW L
	DO MWLIST(.CONF,$GET(METHOD),$GET(ROUTEPAT),"before",.L)
	IF '$DATA(L) QUIT 1
	NEW I,ENT,OK
	SET OK=1
	SET I=0
	FOR  SET I=$ORDER(L(I)) QUIT:I=""  DO  QUIT:'OK
	. SET ENT=$GET(L(I))
	. IF ENT="" QUIT
	. SET OK=$$MWEX(ENT,.DEV,.CONF,.REQ,.CTX,.ERR)
	. IF +OK'=1 DO
	. . IF $GET(ERR("routine"))="" SET ERR("routine")=$PIECE(ENT,"^",2)
	. . IF $GET(ERR("error"))="" SET ERR("error")="middleware_reject"
	. . IF '$DATA(ERR("status")) SET ERR("status")=403
	. . SET OK=0
	QUIT OK
	;
MWAFTER(DEV,CONF,REQ,CTX,METHOD,ROUTEPAT,ERR)
	NEW L
	DO MWLIST(.CONF,$GET(METHOD),$GET(ROUTEPAT),"after",.L)
	IF '$DATA(L) QUIT
	NEW I,ENT,TAG,RTN,CMD
	SET I=0
	FOR  SET I=$ORDER(L(I)) QUIT:I=""  DO
	. SET ENT=$GET(L(I))
	. IF ENT="" QUIT
	. SET TAG=$PIECE(ENT,"^",1),RTN=$PIECE(ENT,"^",2)
	. IF TAG=""!(RTN="") QUIT
	. IF '$$ISID(TAG)!'$$ISID(RTN) QUIT
	. NEW $ETRAP SET $ETRAP="SET $ECODE="""""
	. SET CMD=TAG_"^"_RTN_"(.DEV,.CONF,.REQ,.CTX,.ERR)" DO @CMD
	. ;XECUTE CMD
	QUIT
	;
MWRESPERR(DEV,CONF,REQ,CTX,ERR)
	NEW S SET S=+$GET(ERR("status"),500)
	NEW OBJ
	SET OBJ("error")=$GET(ERR("error"),"middleware_error")
	SET OBJ("routine")=$GET(ERR("routine"),"MIOROUTE")
	SET OBJ("request_id")=$GET(CTX("request_id"))
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,S,.OBJ,$GET(CTX("request_id")),.CTX)
	QUIT
	;
; ---- core handlers ----
	;
HEALTH(DEV,CONF,REQ,CTX)
	NEW H SET H("Content-Type")="text/plain"
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.H,"ok",$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
PING(DEV,CONF,REQ,CTX)
	NEW OBJ
	SET OBJ("ok")=1
	SET OBJ("ts")=$HOROLOG
	SET OBJ("routine")="MIOROUTE"
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
WS(DEV,CONF,REQ,CTX)
	DO ACCEPT^MIOWS(.DEV,.CONF,.REQ,.CTX)
	QUIT
	;