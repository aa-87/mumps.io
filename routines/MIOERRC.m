MIOERRC ; Error Center + diagnostics endpoints (globals-backed).;
; API STABILITY
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; PURPOSE
; Capture request/parse/middleware/handler error events into a deterministic ring buffer
; stored in globals, and expose diagnostics endpoints behind auth (/debug/*).;
;
; ROUTES (optional)
;   GET /debug/errors
;   GET /debug/config
;
; CONFIG (defaults shown)
;   CONF("server","errors","enabled")=1
;   CONF("server","errors","maxEntries")=2000
;   CONF("server","errors","capture4xx")=1
;   CONF("server","errors","capture404")=0
;   CONF("server","errors","configMaxNodes")=5000
;   CONF("server","errors","configMaxDepth")=8
;
; GLOBALS
;   ^MIO("ERR","seq")                  - global monotonic sequence
;   ^MIO("ERR","ring",slot,...)        - ring entries
;   ^MIO("ERR","max")                  - last used max entries (informational)
;
; ENTRY POINTS
;   REG(CONF)                          - register /debug endpoints
;   EN(CONF)                           - enabled?
;   PUSH(CONF,REQ,CTX,ERR,PHASE)       - record an event (best effort)
;   CAPREQ(CONF,REQ,CTX)               - convenience: record request error based on CTX
;   CLEAR()                            - clear ring (tests)
;
REG(CONF) ;
	DO ADD^MIOROUTE("GET","/debug/errors","ERRORS^MIOERRC")
	DO ADD^MIOROUTE("GET","/debug/config","CONFIG^MIOERRC")
	QUIT
	;
EN(CONF) QUIT +$GET(CONF("server","errors","enabled"),1)
	;
MAX(CONF)
	NEW M SET M=+$GET(CONF("server","errors","maxEntries"),2000)
	IF M<100 SET M=100
	SET ^MIO("ERR","max")=M
	QUIT M
	;
CAP4XX(CONF) QUIT +$GET(CONF("server","errors","capture4xx"),1)
CAP404(CONF) QUIT +$GET(CONF("server","errors","capture404"),0)
	;
TSUS()
	; Prefer MIOMET if present
	IF $TEXT(TSUS^MIOMET)'="" QUIT $$TSUS^MIOMET()
	; Fallback: coarse microseconds from $H
	NEW D,S SET D=+$P($H,",",1),S=+$P($H,",",2)
	QUIT ((D*86400)+S)*1000000
	;
SHOULD(CONF,CTX,ERR)
	NEW ST SET ST=+$GET(CTX("status"))
	IF ST=0 SET ST=+$GET(ERR("status"))
	NEW EC SET EC=$GET(ERR("error")) IF EC="" SET EC=$GET(CTX("error"))
	IF ST<400,EC="" QUIT:$QUIT 0 QUIT
	IF ST=404,'$$CAP404(.CONF) QUIT:$QUIT 0 QUIT
	IF ST>=500 QUIT:$QUIT 1 QUIT
	IF '$$CAP4XX(.CONF) QUIT:$QUIT 0 QUIT
	QUIT:$QUIT 1 QUIT
	;
PUSH(CONF,REQ,CTX,ERR,PHASE)
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" QUIT:$QUIT 0  QUIT"
	IF '$$EN(.CONF) QUIT 0
	IF '$$SHOULD(.CONF,.CTX,.ERR) QUIT 0
	NEW MAX SET MAX=$$MAX(.CONF)
	NEW SEQ SET SEQ=$INCREMENT(^MIO("ERR","seq"))
	NEW SLOT SET SLOT=((SEQ-1)#MAX)+1
	NEW TS SET TS=$$TSUS()
	NEW RID SET RID=$GET(CTX("request_id")) IF RID="" SET RID=$GET(REQ("id"))
	NEW RA SET RA=$GET(CTX("remote_addr"))
	NEW MM SET MM=$GET(REQ("http_method")) IF MM="" SET MM=$GET(REQ("method"))
	NEW PATH SET PATH=$GET(REQ("path"))
	NEW RT SET RT=$GET(CTX("route"))
	NEW ST SET ST=+$GET(CTX("status")) IF ST=0 SET ST=+$GET(ERR("status"))
	IF ST=0,$TEXT(STATUS4ERR^MIOHTTP)'="" SET ST=$$STATUS4ERR^MIOHTTP(.ERR)
	NEW ER SET ER=$GET(ERR("error")) IF ER="" SET ER=$GET(CTX("error")) IF ER="" SET ER=$GET(CTX("err","error"))
	NEW ROU SET ROU=$GET(ERR("routine")) IF ROU="" SET ROU=$GET(CTX("err","routine")) IF ROU="" SET ROU="unknown"
	NEW PH SET PH=$GET(PHASE) IF PH="" SET PH="request"
	;
	KILL ^MIO("ERR","ring",SLOT)
	SET ^MIO("ERR","ring",SLOT,"seq")=SEQ
	SET ^MIO("ERR","ring",SLOT,"ts_us")=TS
	IF RID'="" SET ^MIO("ERR","ring",SLOT,"request_id")=RID
	IF RA'="" SET ^MIO("ERR","ring",SLOT,"remote_addr")=RA
	IF MM'="" SET ^MIO("ERR","ring",SLOT,"method")=MM
	IF PATH'="" SET ^MIO("ERR","ring",SLOT,"path")=PATH
	IF RT'="" SET ^MIO("ERR","ring",SLOT,"route")=RT
	IF ST SET ^MIO("ERR","ring",SLOT,"status")=ST
	IF ER'="" SET ^MIO("ERR","ring",SLOT,"error")=ER
	IF ROU'="" SET ^MIO("ERR","ring",SLOT,"routine")=ROU
	SET ^MIO("ERR","ring",SLOT,"phase")=PH
	; Light extra context (never store secrets)
	IF $GET(CTX("met","total_ms"))'="" SET ^MIO("ERR","ring",SLOT,"total_ms")=+CTX("met","total_ms")
	IF $GET(CTX("bytes_in"))'="" SET ^MIO("ERR","ring",SLOT,"bytes_in")=+CTX("bytes_in")
	IF $GET(CTX("bytes_out"))'="" SET ^MIO("ERR","ring",SLOT,"bytes_out")=+CTX("bytes_out")
	QUIT:$QUIT 1
	QUIT
	;
CAPREQ(CONF,REQ,CTX)
	NEW ERR
	SET ERR("routine")=$GET(CTX("err","routine"))
	SET ERR("error")=$GET(CTX("error"))
	IF ERR("error")="" SET ERR("error")=$GET(CTX("err","error"))
	SET ERR("status")=+$GET(CTX("status"))
	DO PUSH(.CONF,.REQ,.CTX,.ERR,"request")
	QUIT
	;
CLEAR()
	KILL ^MIO("ERR")
	QUIT
	;
; ------------------------ Diagnostics Endpoints ---------------------------
ERRORS(DEV,CONF,REQ,CTX)
	NEW LIM SET LIM=$$QNUM(.REQ,"limit",50,1,200)
	NEW FROM SET FROM=$$QNUM(.REQ,"from",0,0,999999999999)
	NEW NEXT SET NEXT=0
	NEW OUT KILL OUT
	DO GET(.CONF,FROM,LIM,.OUT,.NEXT)
	NEW HEAD SET HEAD("Content-Type")="application/json"
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,$GET(CTX("request_id")),.CTX)
	NEW B SET B=""
	DO JACC(.DEV,.B,"{""ok"":true,""from"":"_FROM_",""limit"":"_LIM_",""next_from"":"_NEXT_",""errors"":[")
	NEW I,K SET I=0
	FOR  SET I=$ORDER(OUT(I)) QUIT:'I  DO
	. IF I>1 DO JACC(.DEV,.B,",")
	. M K=OUT(I) DO JOUTERR(.DEV,.B,.K) K OUT(I) M OUT(I)=K
	DO JACC(.DEV,.B,"]}")
	DO JFLUSH(.DEV,.B)
	DO STREAMEND^MIOHTTP(.DEV)
	QUIT
	;
CONFIG(DEV,CONF,REQ,CTX)
	NEW FULL SET FULL=$$QNUM(.REQ,"full",0,0,1)
	NEW MAXN SET MAXN=+$GET(CONF("server","errors","configMaxNodes"),5000) IF MAXN<500 SET MAXN=500
	NEW MAXD SET MAXD=+$GET(CONF("server","errors","configMaxDepth"),8) IF MAXD<3 SET MAXD=3
	NEW RC KILL RC
	DO REDACT(.CONF,.RC)
	NEW HEAD SET HEAD("Content-Type")="application/json"
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,$GET(CTX("request_id")),.CTX)
	NEW B SET B=""
	DO JACC(.DEV,.B,"{""ok"":true,""full"":"_FULL_",""config"":")
	NEW CNT SET CNT=0
	IF 'FULL DO  ; summary
	. NEW S KILL S
	. SET S("server","http","limits")=""
	. SET S("server","static")=""
	. SET S("server","metrics","enabled")=$GET(RC("server","metrics","enabled"))
	. SET S("server","log","access","enabled")=$GET(RC("server","log","access","enabled"))
	. SET S("auth","enabled")=$GET(RC("auth","enabled"))
	. SET S("auth","protectMode")=$GET(RC("auth","protectMode"))
	. DO JOUT(.DEV,.B,.S,1,3,.CNT,800)
	ELSE  DO
	. DO JOUT(.DEV,.B,.RC,1,MAXD,.CNT,MAXN)
	DO JACC(.DEV,.B,"}")
	DO JFLUSH(.DEV,.B)
	DO STREAMEND^MIOHTTP(.DEV)
	QUIT
	;
; ------------------------ Ring Retrieval ----------------------------------
GET(CONF,FROM,LIM,OUT,NEXT)
	NEW MAX SET MAX=$$MAX(.CONF)
	NEW CUR SET CUR=+$GET(^MIO("ERR","seq"))
	IF FROM>0,CUR>FROM SET CUR=FROM
	NEW N SET N=0,NEXT=0
	FOR  QUIT:CUR<1  QUIT:N'<LIM  DO
	. NEW SLOT SET SLOT=((CUR-1)#MAX)+1
	. IF $GET(^MIO("ERR","ring",SLOT,"seq"))'=CUR SET CUR=CUR-1 QUIT
	. SET N=N+1
	. NEW K SET K=""
	. KILL OUT(N)
	. FOR  SET K=$ORDER(^MIO("ERR","ring",SLOT,K)) QUIT:K=""  DO
	. . SET OUT(N,K)=^MIO("ERR","ring",SLOT,K)
	. SET CUR=CUR-1
	IF CUR>0 SET NEXT=CUR
	QUIT
	;
; ------------------------ JSON Writers ------------------------------------
JOUTERR(DEV,B,E)
	DO JACC(.DEV,.B,"{")
	DO JPAIR(.DEV,.B,"seq",+$GET(E("seq")),1)
	DO JPAIR(.DEV,.B,"ts_us",+$GET(E("ts_us")),1)
	DO JPAIR(.DEV,.B,"request_id",$GET(E("request_id")),1)
	DO JPAIR(.DEV,.B,"remote_addr",$GET(E("remote_addr")),1)
	DO JPAIR(.DEV,.B,"method",$GET(E("method")),1)
	DO JPAIR(.DEV,.B,"path",$GET(E("path")),1)
	DO JPAIR(.DEV,.B,"route",$GET(E("route")),1)
	DO JPAIR(.DEV,.B,"status",+$GET(E("status")),1)
	DO JPAIR(.DEV,.B,"routine",$GET(E("routine")),1)
	DO JPAIR(.DEV,.B,"error",$GET(E("error")),1)
	DO JPAIR(.DEV,.B,"phase",$GET(E("phase")),0)
	DO JACC(.DEV,.B,"}")
	QUIT
	;
JPAIR(DEV,B,K,V,COMMA)
	IF COMMA DO JACC(.DEV,.B,",")
	DO JACC(.DEV,.B,""""_$$JESC(K)_""":")
	IF $$ISNUM(V) DO JACC(.DEV,.B,+V) QUIT
	DO JACC(.DEV,.B,""""_$$JESC($GET(V))_"""")
	QUIT
	;
ISNUM(V)
	NEW S SET S=$GET(V)
	IF S="" QUIT 0
	IF S?1"-".N QUIT 1
	IF S?1N.N QUIT 1
	IF S?1N.N1"."1N.N QUIT 1
	IF S?1"-"1N.N1"."1N.N QUIT 1
	QUIT 0
	;
JACC(DEV,B,S)
	SET B=B_$GET(S)
	IF $L(B)>2048 DO STREAMWRITE^MIOHTTP(.DEV,B) SET B=""
	QUIT
	;
JFLUSH(DEV,B)
	IF $GET(B)'="" DO STREAMWRITE^MIOHTTP(.DEV,B) SET B=""
	QUIT
	;
JESC(S)
	NEW I,C,O SET O=""
	SET S=$GET(S)
	FOR I=1:1:$L(S) DO
	. SET C=$E(S,I)
	. IF C="\" SET O=O_"\\"
	. ELSE  IF C="""" SET O=O_"\\"""
	. ELSE  IF $A(C)<32 DO  ; control
	. . NEW H SET H=$$HEX2($A(C))
	. . SET O=O_"\u00"_H
	. ELSE  SET O=O_C
	QUIT O
	;
HEX2(N)
	NEW H SET H="0123456789ABCDEF"
	QUIT $E(H,(N\16)+1)_$E(H,(N#16)+1)
	;
QNUM(REQ,K,DEF,MIN,MAX)
	NEW V SET V=$$QGET(.REQ,K,"")
	IF V="" QUIT DEF
	IF '(V?1N.N) QUIT DEF
	IF V<MIN QUIT MIN
	IF V>MAX QUIT MAX
	QUIT +V
	;
QGET(REQ,K,DEF)
	NEW V SET V=""
	; Common shapes
	IF $DATA(REQ("query",K)) SET V=REQ("query",K)
	ELSE  IF $DATA(REQ("qs",K)) SET V=REQ("qs",K)
	ELSE  IF $DATA(REQ("params",K)) SET V=REQ("params",K)
	ELSE  IF $DATA(REQ("query")) DO  ; query string raw: a=b&c=d
	. SET V=$$QSGET($GET(REQ("query")),K)
	IF V="" SET V=$GET(DEF)
	QUIT V
	;
QSGET(QS,K)
	NEW P,I,KV,KK,V SET V=""
	IF QS="" QUIT ""
	FOR I=1:1:$L(QS,"&") DO  QUIT:V'=""
	. SET KV=$P(QS,"&",I)
	. SET KK=$P(KV,"=",1)
	. IF KK=K SET V=$P(KV,"=",2,999)
	QUIT V
	;
; ---------------------- Config Redaction ----------------------------------
REDACT(IN,OUT)
	NEW REF SET REF=$NA(IN)
	NEW Q SET Q=REF
	FOR  SET Q=$Q(@Q) QUIT:Q=""  QUIT:$E(Q,1,$L(REF))'=REF  DO
	. NEW SUBS,DEP,I
	. SET DEP=$QL(Q)-$QL(REF)
	. IF DEP<1 QUIT
	. KILL SUBS
	. FOR I=1:1:DEP SET SUBS(I)=$QS(Q,$QL(REF)+I)
	. NEW VAL SET VAL=@Q
	. IF $$SENS(.SUBS,DEP) SET VAL="***"
	. DO SETOUT($NA(OUT),.SUBS,DEP,VAL)
	QUIT
	;
SENS(SUBS,DEP)
	; If any subscript indicates secrets, redact.;
	NEW I,K,KL SET KL=""
	FOR I=1:1:DEP DO  QUIT:KL'=""
	. SET K=$$LOW($GET(SUBS(I)))
	. IF K["password" SET KL=1 QUIT
	. IF K["secret" SET KL=1 QUIT
	. IF K["token" SET KL=1 QUIT
	. IF K["apikey" SET KL=1 QUIT
	. IF K["api_key" SET KL=1 QUIT
	. IF K["private" SET KL=1 QUIT
	. IF K["jwt" SET KL=1 QUIT
	. IF K["bearer" SET KL=1 QUIT
	. IF K["cookie"&(K["secret") SET KL=1 QUIT
	QUIT +$GET(KL)
	;
LOW(S)
	QUIT $$LOW^MIOHTTP($GET(S))
	;
SETOUT(ROOT,SUBS,DEP,VAL)
	NEW I,REF SET REF=ROOT
	FOR I=1:1:DEP-1 DO  
	. SET REF=$NA(@REF@(SUBS(I)))
	. SET @REF@(SUBS(DEP))=VAL
	QUIT
	;
; Stream JSON for a M array (object) with depth/node limits.;
JOUT(DEV,B,A,DEP,MAXD,CNT,MAXN)
	IF DEP>MAXD DO  QUIT
	. DO JACC(.DEV,.B,"""__truncated_depth"":true")
	IF CNT>MAXN DO  QUIT
	. DO JACC(.DEV,.B,"""__truncated_nodes"":true")
	DO JACC(.DEV,.B,"{")
	NEW FIRST SET FIRST=1
	NEW K SET K=""
	FOR  SET K=$ORDER(A(K)) QUIT:K=""  DO  QUIT:CNT>MAXN
	. SET CNT=CNT+1
	. IF 'FIRST DO JACC(.DEV,.B,",")
	. SET FIRST=0
	. DO JACC(.DEV,.B,""""_$$JESC(K)_""":")
	. NEW HASV SET HASV=$DATA(A(K))#2
	. NEW HASC SET HASC=$ORDER(A(K,""))'=""
	. IF HASC DO  QUIT
	. . ; If node has both value and children, include __value
	. . IF HASV DO
	. . . NEW T KILL T
	. . . SET T("__value")=A(K)
	. . . MERGE T=A(K)
	. . . DO JOUT(.DEV,.B,.T,DEP+1,MAXD,.CNT,MAXN)
	. . ELSE  N TT M TT=A(K) DO JOUT(.DEV,.B,.TT,DEP+1,MAXD,.CNT,MAXN) K A(K) M A(K)=TT
	. ; Leaf value
	. NEW V SET V=A(K)
	. IF $$ISNUM(V) DO JACC(.DEV,.B,+V) QUIT
	. DO JACC(.DEV,.B,""""_$$JESC(V)_"""")
	DO JACC(.DEV,.B,"}")
	QUIT
	;