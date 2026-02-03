MIOMET ; Metrics collection and Prometheus export.;
; API STABILITY
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; Purpose
; Metrics collection and Prometheus export.;
;
; Responsibilities
; - Collect operational data.;
; - Export metrics.;
; - Enforce retention policies.;
;
; Entry Points
; - BUCKETS
; - TSUS
; - OBS
; - BUFADD
; - FLUSHJOB
; - FLUSH
; - INCREQ
; - INCLAT
; - INCLATB
; - INCSUM
; - INCCNT
; - BUCKETLE
; - NOWMIN
; - METRICS
; - ESC
; - REPL
;
; Globals Used
; - ^MIO("MET",...)
;
; Notes
; Keep comments short.;
; Do not log secrets.;
;
	; Metrics (Prometheus text format)
	; Focus: low overhead, bounded growth, stability-first.;
	;
	; Storage:
	;   ^MIO("MET","REQ",method,route,status)=count
	;   ^MIO("MET","LAT",method,route,le)=count   ; non-cumulative bucket counts
	;   ^MIO("MET","SUMMS",method,route)=sum_ms
	;   ^MIO("MET","COUNT",method,route)=count
	;
	; Buckets are in milliseconds, stored as strings: 5,10,25,50,...,"inf"
	;
; Entry point
; See docs/routines for details.;
BUCKETS(LST) ; build bucket list by reference
	KILL LST
	SET LST(1)=5,LST(2)=10,LST(3)=25,LST(4)=50,LST(5)=100
	SET LST(6)=250,LST(7)=500,LST(8)=1000,LST(9)=2500
	SET LST(10)=5000,LST(11)=10000,LST(12)="inf"
	QUIT
	;
; Entry point
; See docs/routines for details.;
TSUS() Q $ZUT
	;	
		; timestamp in microseconds (coarse but good for deltas)
	; Use $HOROLOG days + time-of-day from $ZTIMESTAMP if available.;
	;NEW H SET H=$HOROLOG
	;NEW DAYS,SEC SET DAYS=$PIECE(H,",",1),SEC=$PIECE(H,",",2)
	;NEW US SET US=(DAYS*86400+SEC)*1000000
	;NEW ZTS
	; $ZTIMESTAMP exists on YottaDB/GT.M; if not, we keep second resolution.;
	;SET ZTS=$GET($ZTIMESTAMP,"")
	;IF ZTS'="" DO
	;. ; ZTS like: 2026-01-14T12:34:56.123456-05:00 (format may vary)
	;. NEW T SET T=$PIECE(ZTS,"T",2)
	;. NEW HMS SET HMS=$PIECE(T,"-",1)
	;. NEW TIME SET TIME=$PIECE(HMS,"+",1)
	;. NEW HH,MM,SS,FR
	;. SET HH=+$PIECE(TIME,":",1)
	;. SET MM=+$PIECE(TIME,":",2)
	;. NEW S3 SET S3=$PIECE(TIME,":",3)
	;. SET SS=+$PIECE(S3,".",1)
	;. SET FR=$PIECE(S3,".",2)
	;. IF FR="" SET FR=0
	;. ; normalize FR to 6 digits
	;. SET FR=$EXTRACT(FR_"000000",1,6)
	;. SET US=(DAYS*86400+(HH*3600)+(MM*60)+SS)*1000000+(+FR)
	;QUIT US
	;
; Entry point
; See docs/routines for details.;
OBS(METHOD,ROUTE,STATUS,LATMS)
	; Observe a completed request.;
	; If metrics buffering is enabled, write into per-worker buffer and flush periodically.;
	NEW M,R,S SET M=$GET(METHOD,""),R=$GET(ROUTE,""),S=$GET(STATUS,"")
	IF M="" SET M="UNKNOWN"
	IF R="" SET R="unknown"
	IF S="" SET S="0"
	;
	NEW DOBUF SET DOBUF=$GET(^MIO("CONF","metrics","buffered"),1)
	IF DOBUF DO  QUIT
	. DO BUFADD(M,R,S,+LATMS)
	;
	; Direct write mode (lowest complexity)
	DO INCREQ(M,R,S)
	DO INCLAT(M,R,+LATMS)
	QUIT
	;
; Entry point
; See docs/routines for details.;
BUFADD(M,R,S,LATMS)
	; Buffer metrics deltas into ^MIO("MET","BUF",$J,...) and flush on thresholds.;
	NEW J SET J=$J
	SET ^MIO("MET","BUF",J,"N")=$GET(^MIO("MET","BUF",J,"N"))+1
	SET ^MIO("MET","BUF",J,"LASTUS")=$$TSUS()
	SET ^MIO("MET","BUF",J,"REQ",M,R,S)=$GET(^MIO("MET","BUF",J,"REQ",M,R,S))+1
	SET ^MIO("MET","BUF",J,"SUMMS",M,R)=$GET(^MIO("MET","BUF",J,"SUMMS",M,R))+(+LATMS)
	SET ^MIO("MET","BUF",J,"COUNT",M,R)=$GET(^MIO("MET","BUF",J,"COUNT",M,R))+1
	;
	; Windowed counters (bounded by cleanup)
	IF $GET(^MIO("CONF","metrics","windowEnabled"),1) DO
	. NEW MIN SET MIN=$$NOWMIN()
	. SET ^MIO("MET","WIN",MIN,"REQ",M,R,S)=$GET(^MIO("MET","WIN",MIN,"REQ",M,R,S))+1
	;
	; Histogram bucket selection
	NEW LE SET LE=$$BUCKETLE(+LATMS)
	SET ^MIO("MET","BUF",J,"LAT",M,R,LE)=$GET(^MIO("MET","BUF",J,"LAT",M,R,LE))+1
	;
	; Flush policy
	NEW FE SET FE=+$GET(^MIO("CONF","metrics","flushEvery"),200)
	NEW IVMS SET IVMS=+$GET(^MIO("CONF","metrics","flushIntervalMs"),1000)
	NEW LAST SET LAST=+$GET(^MIO("MET","BUF",J,"FLUSHUS"))
	NEW NOW SET NOW=$$TSUS()
	NEW N SET N=+$GET(^MIO("MET","BUF",J,"N"))
	IF LAST=0 SET LAST=NOW
	IF (N'<FE)&(((NOW-LAST)/1000)'>IVMS) QUIT
	DO FLUSHJOB()
	QUIT
	;
; Entry point
; See docs/routines for details.;
FLUSHJOB()
	; Flush buffered metrics for current worker job ($J) into main counters.;
	DO FLUSH($J)
	QUIT
	;
; Entry point
; See docs/routines for details.;
FLUSH(J)
	NEW M,R,S,LE
	; Requests
	SET M="" FOR  SET M=$ORDER(^MIO("MET","BUF",J,"REQ",M)) QUIT:M=""  DO
	. SET R="" FOR  SET R=$ORDER(^MIO("MET","BUF",J,"REQ",M,R)) QUIT:R=""  DO
	. . SET S="" FOR  SET S=$ORDER(^MIO("MET","BUF",J,"REQ",M,R,S)) QUIT:S=""  DO
	. . . NEW D SET D=+$GET(^MIO("MET","BUF",J,"REQ",M,R,S))
	. . . IF D>0 DO INCREQ(M,R,S,D)
	;
	; Histogram + sums
	SET M="" FOR  SET M=$ORDER(^MIO("MET","BUF",J,"LAT",M)) QUIT:M=""  DO
	. SET R="" FOR  SET R=$ORDER(^MIO("MET","BUF",J,"LAT",M,R)) QUIT:R=""  DO
	. . SET LE="" FOR  SET LE=$ORDER(^MIO("MET","BUF",J,"LAT",M,R,LE)) QUIT:LE=""  DO
	. . . NEW D SET D=+$GET(^MIO("MET","BUF",J,"LAT",M,R,LE))
	. . . IF D>0 DO INCLATB(M,R,LE,D)
	;
	SET M="" FOR  SET M=$ORDER(^MIO("MET","BUF",J,"SUMMS",M)) QUIT:M=""  DO
	. SET R="" FOR  SET R=$ORDER(^MIO("MET","BUF",J,"SUMMS",M,R)) QUIT:R=""  DO
	. . NEW D SET D=+$GET(^MIO("MET","BUF",J,"SUMMS",M,R))
	. . IF D>0 DO INCSUM(M,R,D)
	;
	SET M="" FOR  SET M=$ORDER(^MIO("MET","BUF",J,"COUNT",M)) QUIT:M=""  DO
	. SET R="" FOR  SET R=$ORDER(^MIO("MET","BUF",J,"COUNT",M,R)) QUIT:R=""  DO
	. . NEW D SET D=+$GET(^MIO("MET","BUF",J,"COUNT",M,R))
	. . IF D>0 DO INCCNT(M,R,D)
	;
	; Reset buffer
	KILL ^MIO("MET","BUF",J)
	QUIT
	;
; Entry point
; See docs/routines for details.;
INCREQ(M,R,S,D)
	IF $GET(D)="" SET D=1
	I $INCREMENT(^MIO("MET","REQ",M,R,S),D)
	QUIT
	;
; Entry point
; See docs/routines for details.;
INCLAT(M,R,LATMS)
	NEW LE SET LE=$$BUCKETLE(+LATMS)
	DO INCLATB(M,R,LE,1)
	DO INCSUM(M,R,+LATMS)
	DO INCCNT(M,R,1)
	QUIT
	;
; Entry point
; See docs/routines for details.;
INCLATB(M,R,LE,D)
	IF $GET(D)="" SET D=1
	I $INCREMENT(^MIO("MET","LAT",M,R,LE),D)
	QUIT
	;
; Entry point
; See docs/routines for details.;
INCSUM(M,R,D)
	I $INCREMENT(^MIO("MET","SUMMS",M,R),+D)
	QUIT
	;
; Entry point
; See docs/routines for details.;
INCCNT(M,R,D)
	I $INCREMENT(^MIO("MET","COUNT",M,R),+D)
	QUIT
	;
; Entry point
; See docs/routines for details.;
BUCKETLE(LATMS)
	NEW LST DO BUCKETS(.LST)
	NEW I,LE SET LE="inf"
	FOR I=1:1 QUIT:'$DATA(LST(I))  DO  QUIT:LE'="inf"
	. NEW LIM SET LIM=LST(I)
	. IF LIM="inf" SET LE="inf" QUIT
	. IF LATMS'>LIM SET LE=LIM QUIT
	QUIT LE
	;
; Entry point
; See docs/routines for details.;
NOWMIN()
	NEW H SET H=$HOROLOG
	NEW DAYS,SEC SET DAYS=+$PIECE(H,",",1),SEC=+$PIECE(H,",",2)
	QUIT (DAYS*1440)+(SEC\60)
	;
	;
; Entry point
; See docs/routines for details.;
METRICS(DEV,CONF,REQ,CTX) ; handler for /metrics
	IF '$S($G(CONF("metrics","enabled"))="true":1,1:+$G(CONF("metrics","enabled"))) DO  QUIT
	. NEW OBJ SET OBJ("error")="metrics_disabled",OBJ("request_id")=$GET(CTX("request_id"))
	. DO RESPJSON^MIOHTTP(.DEV,.CONF,404,.OBJ,$GET(CTX("request_id")))
	NEW HEAD SET HEAD("Content-Type")="text/plain; version=0.0.4"
	; Render into BODY (simple; fine for early versions)
	NEW BODY SET BODY=""
	SET BODY=BODY_"# HELP mws_requests_total Total HTTP requests by method, route, status"_$CHAR(10)
	SET BODY=BODY_"# TYPE mws_requests_total counter"_$CHAR(10)
	NEW M,R,S
	SET M=""
	FOR  SET M=$ORDER(^MIO("MET","REQ",M)) QUIT:M=""  DO
	. SET R=""
	. FOR  SET R=$ORDER(^MIO("MET","REQ",M,R)) QUIT:R=""  DO
	. . SET S=""
	. . FOR  SET S=$ORDER(^MIO("MET","REQ",M,R,S)) QUIT:S=""  DO
	. . . NEW V SET V=+$GET(^MIO("MET","REQ",M,R,S))
	. . . SET BODY=BODY_"mws_requests_total{method="""_M_""",route="""_$$ESC(R)_""",status="""_S_"""} "_V_$CHAR(10)
	SET BODY=BODY_$CHAR(10)
	SET BODY=BODY_"# HELP mws_request_duration_ms Request duration histogram (milliseconds)"_$CHAR(10)
	SET BODY=BODY_"# TYPE mws_request_duration_ms histogram"_$CHAR(10)
	; For each (method,route) output cumulative buckets + sum + count
	SET M=""
	FOR  SET M=$ORDER(^MIO("MET","COUNT",M)) QUIT:M=""  DO
	. SET R=""
	. FOR  SET R=$ORDER(^MIO("MET","COUNT",M,R)) QUIT:R=""  DO
	. . NEW LST DO BUCKETS(.LST)
	. . NEW CUM SET CUM=0
	. . NEW I,LE
	. . FOR I=1:1 QUIT:'$DATA(LST(I))  DO
	. . . SET LE=LST(I)
	. . . SET CUM=CUM+(+$GET(^MIO("MET","LAT",M,R,LE)))
	. . . SET BODY=BODY_"mws_request_duration_ms_bucket{method="""_M_""",route="""_$$ESC(R)_""",le="""_LE_"""} "_CUM_$CHAR(10)
	. . NEW SUM SET SUM=+$GET(^MIO("MET","SUMMS",M,R))
	. . NEW CNT SET CNT=+$GET(^MIO("MET","COUNT",M,R))
	. . SET BODY=BODY_"mws_request_duration_ms_sum{method="""_M_""",route="""_$$ESC(R)_"""} "_SUM_$CHAR(10)
	. . SET BODY=BODY_"mws_request_duration_ms_count{method="""_M_""",route="""_$$ESC(R)_"""} "_CNT_$CHAR(10)
	DO RESP^MIOHTTP(.DEV,.CONF,200,.HEAD,BODY,$GET(CTX("request_id")))
	QUIT
	;
; Entry point
; See docs/routines for details.;
ESC(S) ; escape backslash and quotes for Prometheus label values
	NEW X SET X=$GET(S,"")
	; backslash first
	SET X=$$REPL(X,"\\","\\\\")
	SET X=$$REPL(X,"""","\\\""")
	QUIT X
	;
; Entry point
; See docs/routines for details.;
REPL(S,F,R)
	NEW OUT SET OUT=""
	NEW I
	FOR I=1:1:$LENGTH(S,F) DO
	. SET OUT=OUT_$PIECE(S,F,I)
	. IF I<$LENGTH(S,F) SET OUT=OUT_R
	QUIT OUT
	;