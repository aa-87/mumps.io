MIOIDET003 ; MIOIDE websocket debugger route and context tests
	D START Q
	;
START(FAIL)
	N TOP,LOCAL
	S TOP='$D(FAIL),LOCAL=0
	D T001(.LOCAL)
	D T010(.LOCAL)
	I TOP D  Q
	. I 'LOCAL W !,"OK - MIOIDET003"
	I LOCAL S FAIL=1
	Q
	;
T001(FAIL)
	N CONF,REQ,CTX,TCTX
	D CONFDEF^MIOIDE(.CONF)
	D BUILDHOME^MIOIDED(.CONF,.REQ,.CTX,.TCTX)
	D EQ^MIOIDET000(.FAIL,"[T001][debug enabled]",+$G(CONF("mioide","debug","enabled")),1)
	D EQ^MIOIDET000(.FAIL,"[T001][debug api]",$G(TCTX("debugApiBase")),"/mioide/api/debug")
	D EQ^MIOIDET000(.FAIL,"[T001][debug ws]",$G(TCTX("debugWsBase")),"/mioide/ws/debug")
	Q
	;
T010(FAIL)
	N CONF
	K ^MIO("ROUTE","RAW","POST","/mioide/api/debug/sessions")
	K ^MIO("ROUTE","RAW","GET","/mioide/api/debug/sessions/:sid")
	K ^MIO("ROUTE","RAW","WS","/mioide/ws/debug/:sid")
	D CONFDEF^MIOIDE(.CONF)
	D REG^MIOIDE(.CONF)
	D EQ^MIOIDET000(.FAIL,"[T010][dbg start]",$G(^MIO("ROUTE","RAW","POST","/mioide/api/debug/sessions")),"DBGSTART^MIOIDER")
	D EQ^MIOIDET000(.FAIL,"[T010][dbg snap]",$G(^MIO("ROUTE","RAW","GET","/mioide/api/debug/sessions/:sid")),"DBGSNAP^MIOIDER")
	D EQ^MIOIDET000(.FAIL,"[T010][dbg ws]",$G(^MIO("ROUTE","RAW","WS","/mioide/ws/debug/:sid")),"WSDBG^MIOIDER")
	Q
	;