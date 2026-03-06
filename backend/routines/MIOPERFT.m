MIOPERFT ; Performance harness tests + regression gates ; 2026-03-06
	; ---------------------------------------------------------------------------
	; These tests are designed to be stable across machines.;
	; They DO NOT enforce tight absolute times by default.;
	;
	; - Smoke perf cases always run and must not error.;
	; - Regression gates are enabled only when:
	;     ^MIO("CONF","server","perf","enabled")=1
	;
	; Requires: MIOTASSERT, and whichever routines exist in your baseline.;
	; Quiet on success.;
	;
	DO T001
	DO T002
	DO T003
	DO T004
	DO T005
	DO T006
	DO T007
	DO T008
	DO T009
	DO T010
	DO T011
	DO T012
	DO T013
	DO T014
	DO T015
	DO T016
	DO T017
	DO T018
	DO T019
	DO T020
	QUIT
	;
PERFNOOP
	QUIT
	;
PERFTRIM
	NEW X SET X=$$TRIM^MIOHTTP("  abc  ")
	QUIT
	;
PERFLOW
	NEW X SET X=$$LOW^MIOHTTP("HeAdEr")
	QUIT
	;
PERFSTATICJOIN
	NEW OK,OUT
	SET OK=$$SAFEJOIN^MIOSTATIC("/tmp","a/b.txt","index.html",.OUT)
	QUIT
	;
TOK1()
	QUIT "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1MSIsInJvbGVzIjoiYWRtaW4sdXNlciIsImV4cCI6NTg0MzY1NDE4MH0.3pl8pKUeb_PJLH7r4zO19MOFL17osRbn-xRFzvifrs0"
	;
PERFJWT
	IF $TEXT(VERIFY^MIOAUTHJWT)="" QUIT
	NEW CONF,CTX,ERR,CLAIM,OK
	SET CONF("auth","jwt","hmacSecret")="s3cr3t"
	SET CTX("hdr","authorization")="Bearer "_$$TOK1()
	SET OK=$$VERIFY^MIOAUTHJWT(.CONF,.CTX,.CLAIM,.ERR)
	QUIT
	;
PERFROUTEDISP
	IF $TEXT(DISPATCH^MIOROUTE)="" QUIT
	NEW CONF,REQ,CTX,ERR
	SET REQ("method")="GET",REQ("path")="/p"
	SET CTX("route")="/p"
	SET CTX("handler")="H001^MIOPERFT"
	;S DEV=$PRINCIPAL
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	QUIT
	;
H001(DEV,CONF,REQ,CTX)
	SET CTX("_h")=1
	QUIT
	;
T001 ; RUN works (noop)
	NEW R,OP
	SET OP="tmp/mio_perf_t001.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RUN^MIOPERF("noop","PERFNOOP^MIOPERFT",1000,.R)
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($GET(R("trap"),0),0,"[T001][no trap]")
	DO OK^MIOTASSERT($GET(R("us_total"))'<0,"[T001][time]")
	QUIT
	;
T002 ; SCALE ratio present
	NEW R
	SET OP="tmp/mio_perf_t002.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO SCALE^MIOPERF("noop","PERFNOOP^MIOPERFT",2000,.R)
	CLOSE DEV USE $PRINCIPAL
	DO OK^MIOTASSERT($DATA(R("scale","ratio")),"[T002][ratio present]")
	DO OK^MIOTASSERT(R("scale","ratio")>0,"[T002][ratio >0]")
	QUIT
	;
T003 ; Gate disabled passes
	NEW CONF,R,ERR,OP
	SET OP="tmp/mio_perf_t003.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO SCALE^MIOPERF("noop","PERFNOOP^MIOPERFT",2000,.R)
	CLOSE DEV USE $PRINCIPAL
	DO OK^MIOTASSERT($$GATE^MIOPERF(.CONF,.R,.ERR)=1,"[T003][gate off pass]")
	QUIT
	;
T004 ; Gate enabled passes for noop (generous)
	NEW CONF,R,ERR,OP
	SET OP="tmp/mio_perf_t004.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	SET CONF("server","perf","enabled")=1
	DO SCALE^MIOPERF("noop","PERFNOOP^MIOPERFT",2000,.R)
	CLOSE DEV USE $PRINCIPAL
	DO OK^MIOTASSERT($$GATE^MIOPERF(.CONF,.R,.ERR)=1,"[T004][gate pass]")
	QUIT
	;
T005 ; Smoke perf: TRIM runs
	IF $TEXT(TRIM^MIOHTTP)="" QUIT
	NEW R,OP
	SET OP="tmp/mio_perf_t005.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RUN^MIOPERF("trim","PERFTRIM^MIOPERFT",20000,.R)
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($GET(R("trap"),0),0,"[T005][no trap]")
	QUIT
	;
T006 ; Smoke perf: LOW runs
	IF $TEXT(LOW^MIOHTTP)="" QUIT
	NEW OP SET OP="tmp/mio_perf_t006.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	NEW R
	DO RUN^MIOPERF("low","PERFLOW^MIOPERFT",20000,.R)
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($GET(R("trap"),0),0,"[T006][no trap]")
	QUIT
	;
T007 ; Smoke perf: SAFEJOIN runs
	IF $TEXT(SAFEJOIN^MIOSTATIC)="" QUIT
	NEW R,OP
	SET OP="tmp/mio_perf_t007.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RUN^MIOPERF("safejoin","PERFSTATICJOIN^MIOPERFT",20000,.R)
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($GET(R("trap"),0),0,"[T007][no trap]")
	QUIT
	;
T008 ; Smoke perf: JWT verify runs (if present)
	IF $TEXT(VERIFY^MIOAUTHJWT)="" QUIT
	NEW R,OP
	SET OP="tmp/mio_perf_t008.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RUN^MIOPERF("jwt","PERFJWT^MIOPERFT",500,.R)
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($GET(R("trap"),0),0,"[T008][no trap]")
	QUIT
	;
T009 ; Gate enabled: JWT scaling
	IF $TEXT(VERIFY^MIOAUTHJWT)="" QUIT
	NEW CONF,R,ERR,OP
	SET OP="tmp/mio_perf_t009.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	SET CONF("server","perf","enabled")=1
	DO SCALE^MIOPERF("jwt","PERFJWT^MIOPERFT",200,.R)
	CLOSE DEV USE $PRINCIPAL
	DO OK^MIOTASSERT($$GATE^MIOPERF(.CONF,.R,.ERR)=1,"[T009][jwt gate]")
	QUIT
	;
T010 ; Smoke perf: router dispatch runs
	IF $TEXT(DISPATCH^MIOROUTE)="" QUIT
	NEW R,OP
	SET OP="tmp/mio_perf_t010.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RUN^MIOPERF("route","PERFROUTEDISP^MIOPERFT",5000,.R)
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($GET(R("trap"),0),0,"[T010][no trap]")
	QUIT
	;
T011 ; Gate enabled: router dispatch scaling
	IF $TEXT(DISPATCH^MIOROUTE)="" QUIT
	NEW CONF,R,ERR,OP
	SET OP="tmp/mio_perf_t011.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	SET CONF("server","perf","enabled")=1
	DO SCALE^MIOPERF("route","PERFROUTEDISP^MIOPERFT",2000,.R)
	CLOSE DEV USE $PRINCIPAL
	DO OK^MIOTASSERT($$GATE^MIOPERF(.CONF,.R,.ERR)=1,"[T011][route gate]")
	QUIT
	;
T012 ; Correctness: SAFEJOIN rejects traversal
	IF $TEXT(SAFEJOIN^MIOSTATIC)="" QUIT
	NEW OK,OUT
	SET OK=$$SAFEJOIN^MIOSTATIC("/tmp","../x","index.html",.OUT)
	DO EQ^MIOTASSERT(OK,0,"[T012][no traversal]")
	QUIT
	;
T013 ; Correctness: LOW stable
	IF $TEXT(LOW^MIOHTTP)="" QUIT
	DO EQ^MIOTASSERT($$LOW^MIOHTTP("HeLLo"),"hello","[T013][low]")
	QUIT
	;
T014 ; Correctness: TRIM stable
	IF $TEXT(TRIM^MIOHTTP)="" QUIT
	DO EQ^MIOTASSERT($$TRIM^MIOHTTP("  a b  "),"a b","[T014][trim]")
	QUIT
	;
T015 ; Custom gates accepted
	NEW CONF,R,ERR,OP
	SET CONF("server","perf","enabled")=1
	SET CONF("server","perf","maxRatio")=10
	SET CONF("server","perf","maxTotalUs")=99999999
	SET CONF("server","perf","maxUsPerIter")=999999
	SET OP="tmp/mio_perf_t015.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO SCALE^MIOPERF("noop","PERFNOOP^MIOPERFT",5000,.R)
	CLOSE DEV USE $PRINCIPAL
	DO OK^MIOTASSERT($$GATE^MIOPERF(.CONF,.R,.ERR)=1,"[T015][custom gate pass]")
	QUIT
	;
T016 ; Trap capture works
	NEW R,OP
	SET OP="tmp/mio_perf_t016.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RUN^MIOPERF("boom","PERFBOOM^MIOPERFT",1,.R)
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($GET(R("trap"),0),1,"[T016][trap set]")
	DO OK^MIOTASSERT($GET(R("zstatus"))'="","[T016][zstatus]")
	QUIT
	;
PERFBOOM
	NEW X SET X=1/0
	QUIT
	;
T017 ; SCALE sets keys
	NEW R,OP
	SET OP="tmp/mio_perf_t017.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO SCALE^MIOPERF("noop","PERFNOOP^MIOPERFT",10,.R)
	CLOSE DEV USE $PRINCIPAL
	DO OK^MIOTASSERT($DATA(R("scale","us_n")),"[T017][us_n]")
	DO OK^MIOTASSERT($DATA(R("scale","us_2n")),"[T017][us_2n]")
	QUIT
	;
T018 ; Total time non-negative
	NEW R,OP
	SET OP="tmp/mio_perf_t018.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RUN^MIOPERF("noop","PERFNOOP^MIOPERFT",1,.R)
	CLOSE DEV USE $PRINCIPAL
	DO OK^MIOTASSERT(R("us_total")'<0,"[T018][nonneg]")
	QUIT
	;
T019 ; Per-iter exists
	NEW R,OP
	SET OP="tmp/mio_perf_t019.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RUN^MIOPERF("noop","PERFNOOP^MIOPERFT",3,.R)
	CLOSE DEV USE $PRINCIPAL
	DO OK^MIOTASSERT($DATA(R("us_per_iter")),"[T019][us_per_iter]")
	QUIT
	;
T020 ; Optional: MIOTPL render smoke (skip if missing)
	IF $TEXT(RENDER^MIOTPL)="" QUIT
	NEW R,OP
	SET OP="tmp/mio_perf_t020.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO SCALE^MIOPERF("tpl","PERFTPL^MIOPERFT",200,.R)
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($GET(R("trap"),0),0,"[T020][no trap]")
	QUIT
	;
PERFTPL
	NEW CONF,CTX,OUT,ERR
	SET CONF("server","templateDir")="templates"
	SET CTX("name")="World"
	DO RENDER^MIOTPL("__perf_inline",.CONF,.CTX,.OUT,.ERR)
	QUIT
	;