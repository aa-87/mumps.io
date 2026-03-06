MIOPERF ; Performance harness + regression gates (deterministic) ; 2026-03-06
	; ---------------------------------------------------------------------------
	; Goals:
	; - Provide lightweight, MAXSTRING-safe performance harness.;
	; - Deterministic regression "gates" that are robust across machines:
	;     * Scaling gates (ratio between N and 2N loops) to catch accidental O(N^2)
	;     * Absolute sanity gates (very generous) to catch catastrophic slowdowns
	; - No ZSYSTEM. No GOTO. Quiet (no writes).;
	; - Does not require persistent baseline to be useful in CI.;
	;
	; Public:
	;   TSUS()                  - best-effort timestamp in microseconds (monotonic-ish)
	;   RUN(NAME,CALL,ITERS,.R) - run CALL (entryref "TAG^RTN") ITERS times, fill R(...)
	;   SCALE(NAME,CALL,N,.R)   - run N and 2N and compute ratio, fill R(...)
	;   GATE(.CONF,.R,.ERR)     - apply gates to results R for one test case
	;
	; Result structure (R):
	;   R("name")=NAME
	;   R("iters")=N
	;   R("us_total")=...;
	;   R("us_per_iter")=...;
	;   R("scale","n")=N
	;   R("scale","2n")=2N
	;   R("scale","ratio")=...;
	;
	; Gates (CONF("server","perf",...)):
	;   enabled=1               - when 0/empty, GATE always passes
	;   maxRatio=3.5            - scaling ratio upper bound (default 3.5)
	;   maxTotalUs=2000000      - per-case absolute upper bound (default 2s)
	;   maxUsPerIter=5000       - absolute upper bound per iteration (default 5ms)
	;
	; Notes:
	; - CALL must be a DO entryref with no args:
	;     PERFJWT^MIOPERFT  ; or PERFROUTE^MIOPERFT etc.;
	;
	; ---------------------------------------------------------------------------
	QUIT
	;
TSUS()
	; Prefer MIOMET's microsecond clock if present.;
	IF $TEXT(TSUS^MIOMET)'="" QUIT $$TSUS^MIOMET()
	; Fallback: $H seconds resolution -> microseconds (coarse).;
	NEW D,S SET D=+$P($H,",",1),S=+$P($H,",",2)
	QUIT ((D*86400)+S)*1000000
	;
RUN(NAME,CALL,ITERS,R)
	KILL R
	SET R("name")=$GET(NAME)
	SET R("iters")=+$GET(ITERS)
	NEW N SET N=R("iters") IF N'>0 SET N=1,R("iters")=1
	NEW T0,T1,I
	NEW $ETRAP SET $ETRAP="DO TRAP^MIOPERF(.R) SET $EC="""" QUIT:$QUIT 0  QUIT"
	SET T0=$$TSUS()
	FOR I=1:1:N DO
	. DO @CALL
	SET T1=$$TSUS()
	SET R("us_total")=T1-T0
	IF R("us_total")<0 SET R("us_total")=0
	SET R("us_per_iter")=R("us_total")/N
	QUIT:$QUIT 1
	QUIT
	;
SCALE(NAME,CALL,N,R)
	KILL R
	NEW R1,R2
	DO RUN(NAME,CALL,+$GET(N),.R1)
	DO RUN(NAME,CALL,2*(+$GET(N)),.R2)
	MERGE R=R1
	SET R("scale","n")=R1("iters")
	SET R("scale","2n")=R2("iters")
	SET R("scale","us_n")=R1("us_total")
	SET R("scale","us_2n")=R2("us_total")
	IF R1("us_total")>0 SET R("scale","ratio")=R2("us_total")/R1("us_total")
	ELSE  SET R("scale","ratio")=0
	QUIT:$QUIT 1
	QUIT
	;
GATE(CONF,R,ERR)
	KILL ERR
	IF +$GET(CONF("server","perf","enabled"),0)'=1 QUIT 1
	NEW MAXR,MAXT,MAXI
	SET MAXR=+$GET(CONF("server","perf","maxRatio"),3.5)
	IF MAXR<1 SET MAXR=3.5
	SET MAXT=+$GET(CONF("server","perf","maxTotalUs"),2000000)
	IF MAXT<10000 SET MAXT=2000000
	SET MAXI=+$GET(CONF("server","perf","maxUsPerIter"),5000)
	IF MAXI<100 SET MAXI=5000
	;
	NEW OK SET OK=1 D
	. IF $DATA(R("scale","ratio")) DO
	. . IF R("scale","ratio")>MAXR SET OK=0 DO ESET(.ERR,"MIOPERF","perf_ratio_regression",500) QUIT
	. IF OK,$GET(R("us_total"))>MAXT SET OK=0 DO ESET(.ERR,"MIOPERF","perf_total_regression",500) QUIT
	. IF OK,$GET(R("us_per_iter"))>MAXI SET OK=0 DO ESET(.ERR,"MIOPERF","perf_iter_regression",500) QUIT
	QUIT OK
	;
TRAP(R)
	SET R("trap")=1
	SET R("zstatus")=$ZSTATUS
	QUIT
	;
ESET(ERR,RTN,CODE,STATUS)
	KILL ERR
	SET ERR("routine")=$GET(RTN)
	SET ERR("error")=$GET(CODE)
	IF $GET(STATUS)'="" SET ERR("status")=+STATUS
	QUIT
	;