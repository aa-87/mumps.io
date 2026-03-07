MIOMETT ; Metrics/Timing ROI (#1) tests (MIOMET)
	;
	; Run:
	;   YDB>ZL "MIOHTTP.m","MIOMET.m","MIOTASSERT.m","MIOMETT.m"
	;   YDB>D ^MIOMETT
	;
	NEW $ET SET $ET="DO STERR^MIOMETT"
	DO T001
	DO T002
	QUIT
	;
STERR
	USE $PRINCIPAL WRITE "ERR ",$ZSTATUS,!
	QUIT
	;
READALL(PATH,OUT)
	NEW OIO SET OIO=$IO
	SET OUT=""
	NEW DEV SET DEV=PATH
	OPEN DEV:(readonly:stream:nowrap)
	USE DEV
	NEW X
	FOR  READ X#16384  QUIT:$ZEOF  SET OUT=OUT_X
	CLOSE DEV
	USE OIO
	QUIT
	;
RESET
	; Keep tests deterministic
	KILL ^MIO("MET")
	QUIT
	;

T001 ; OBSX updates parse/handler/bytes/status/errors
	DO RESET
	NEW OB SET OB=$GET(^MIO("CONF","metrics","buffered"))
	SET ^MIO("CONF","metrics","buffered")=0
	;
	DO OBSX^MIOMET("GET","/a",200,12,2,8,10,20,"")
	DO EQ^MIOTASSERT(+$GET(^MIO("MET","REQ","GET","/a",200)),1,"[T001][req count]")
	DO EQ^MIOTASSERT(+$GET(^MIO("MET","PARSE","COUNT","GET","/a")),1,"[T001][parse count]")
	DO EQ^MIOTASSERT(+$GET(^MIO("MET","HAND","COUNT","GET","/a")),1,"[T001][handler count]")
	DO EQ^MIOTASSERT(+$GET(^MIO("MET","BYTES","in","GET","/a")),10,"[T001][bytes in]")
	DO EQ^MIOTASSERT(+$GET(^MIO("MET","BYTES","out","GET","/a")),20,"[T001][bytes out]")
	DO EQ^MIOTASSERT(+$GET(^MIO("MET","STATUS","2xx")),1,"[T001][status bucket 2xx]")
	DO EQ^MIOTASSERT($SELECT($DATA(^MIO("MET","ERR")):0,1:1),1,"[T001][no errors]")
	;
	; Buckets (2ms->5, 8ms->10, 12ms->25)
	DO EQ^MIOTASSERT(+$GET(^MIO("MET","PARSE","LAT","GET","/a",5)),1,"[T001][parse bucket]")
	DO EQ^MIOTASSERT(+$GET(^MIO("MET","HAND","LAT","GET","/a",10)),1,"[T001][handler bucket]")
	DO EQ^MIOTASSERT(+$GET(^MIO("MET","LAT","GET","/a",25)),1,"[T001][total bucket]")
	;
	; With error
	DO OBSX^MIOMET("GET","(not_found)",404,5,1,0,0,5,"not_found")
	DO EQ^MIOTASSERT(+$GET(^MIO("MET","STATUS","4xx")),1,"[T001][status bucket 4xx]")
	DO EQ^MIOTASSERT(+$GET(^MIO("MET","ERR","not_found")),1,"[T001][err counter]")
	;
	SET ^MIO("CONF","metrics","buffered")=OB
	QUIT
	;

T002 ; /metrics export includes new series and is streamed (chunked)
	DO RESET
	NEW CONF,REQ,CTX,DEV,OUT,OP
	KILL CONF,REQ,CTX
	SET CONF("server","metrics","enabled")=1
	SET CTX("request_id")="met002"
	; Seed a single observation so series exist
	NEW OB SET OB=$GET(^MIO("CONF","metrics","buffered"))
	SET ^MIO("CONF","metrics","buffered")=0
	DO OBSX^MIOMET("GET","/m",200,15,3,9,1,2,"")
	SET ^MIO("CONF","metrics","buffered")=OB
	;
	SET OP="tmp/mio_met_t002.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO METRICS^MIOMET(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV
	USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Transfer-Encoding: chunked":1,1:0),1,"[T002][chunked]")
	DO EQ^MIOTASSERT($SELECT(OUT["mws_parse_duration_ms_bucket":1,1:0),1,"[T002][parse metric]")
	DO EQ^MIOTASSERT($SELECT(OUT["mws_handler_duration_ms_bucket":1,1:0),1,"[T002][handler metric]")
	DO EQ^MIOTASSERT($SELECT(OUT["mws_request_bytes_in_total":1,1:0),1,"[T002][bytes in metric]")
	DO EQ^MIOTASSERT($SELECT(OUT["mws_responses_total":1,1:0),1,"[T002][status buckets metric]")
	DO EQ^MIOTASSERT($SELECT(OUT["mws_errors_total":1,1:0),1,"[T002][errors metric]")
	QUIT
	;
