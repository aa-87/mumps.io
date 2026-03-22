MIOIDET005 ; MIOIDE ROI 3A config and registration coverage
	D START Q
	;
START(FAIL)
	N TOP,LOCAL
	S TOP='$D(FAIL),LOCAL=0
	D T001(.LOCAL)
	D T010(.LOCAL)
	D T020(.LOCAL)
	D T030(.LOCAL)
	I TOP D  Q
	. I 'LOCAL W !,"OK - MIOIDET005"
	I LOCAL S FAIL=1
	Q
	;
T001(FAIL)
	N CONF,REQ,CTX,TCTX
	D RESETIDE^MIOIDET000
	D CONFDEF^MIOIDE(.CONF)
	S CONF("mioide","theme","default")="light"
	S CONF("mioide","save","enabled")=0
	S CONF("mioide","compile","enabled")=0
	S CONF("mioide","run","enabled")=0
	D MKFIX^MIOIDET000(.CONF)
	S REQ("query","name")="MIOIDXT1"
	D BUILDHOME^MIOIDED(.CONF,.REQ,.CTX,.TCTX)
	D EQ^MIOIDET000(.FAIL,"[T001][theme mode]",$G(TCTX("themeMode")),"light")
	D EQ^MIOIDET000(.FAIL,"[T001][save flag]",+$G(TCTX("saveEnabled")),0)
	D EQ^MIOIDET000(.FAIL,"[T001][compile flag]",+$G(TCTX("compileEnabled")),0)
	D EQ^MIOIDET000(.FAIL,"[T001][run flag]",+$G(TCTX("runEnabled")),0)
	D EQ^MIOIDET000(.FAIL,"[T001][debug api]",$G(TCTX("debugApiBase")),"/mioide/api/debug")
	D EQ^MIOIDET000(.FAIL,"[T001][events url]",$G(TCTX("wsEventsUrl")),"/mioide/ws/events")
	D EQ^MIOIDET000(.FAIL,"[T001][terminal url]",$G(TCTX("wsTerminalUrl")),"/mioide/ws/terminal")
	D GT^MIOIDET000(.FAIL,"[T001][routine count]",+$G(TCTX("routineCount")),0)
	Q
	;
T010(FAIL)
	N CONF
	D RESETIDE^MIOIDET000
	D CONFDEF^MIOIDE(.CONF)
	S CONF("mioide","authRequired")=0
	S CONF("mioide","roles")="tester"
	D REG^MIOIDE(.CONF)
	D EQ^MIOIDET000(.FAIL,"[T010][home route]",$G(^MIO("ROUTE","RAW","GET","/mioide")),"HOME^MIOIDER")
	D EQ^MIOIDET000(.FAIL,"[T010][auth off]",+$G(^MIO("ROUTE","META","GET","/mioide","authRequired")),0)
	D EQ^MIOIDET000(.FAIL,"[T010][roles]",$G(^MIO("ROUTE","META","GET","/mioide","roles")),"tester")
	D EQ^MIOIDET000(.FAIL,"[T010][ws auth off]",+$G(^MIO("ROUTE","META","WS","/mioide/ws/events","authRequired")),0)
	Q
	;
T020(FAIL)
	N CONF
	D RESETIDE^MIOIDET000
	D CONFDEF^MIOIDE(.CONF)
	S CONF("mioide","ws","enabled")=0
	D REG^MIOIDE(.CONF)
	D EQ^MIOIDET000(.FAIL,"[T020][home route]",$G(^MIO("ROUTE","RAW","GET","/mioide")),"HOME^MIOIDER")
	D EQ^MIOIDET000(.FAIL,"[T020][events absent]",$G(^MIO("ROUTE","RAW","WS","/mioide/ws/events")),"")
	D EQ^MIOIDET000(.FAIL,"[T020][terminal absent]",$G(^MIO("ROUTE","RAW","WS","/mioide/ws/terminal")),"")
	Q
	;
T030(FAIL)
	N CONF
	D CONFDEF^MIOIDE(.CONF)
	D EQ^MIOIDET000(.FAIL,"[T030][ws enabled]",+$G(CONF("mioide","ws","enabled")),1)
	D EQ^MIOIDET000(.FAIL,"[T030][debug enabled]",+$G(CONF("mioide","debug","enabled")),1)
	D EQ^MIOIDET000(.FAIL,"[T030][debug retain]",+$G(CONF("mioide","debug","sessionRetain")),20)
	D EQ^MIOIDET000(.FAIL,"[T030][breakpoint limit]",+$G(CONF("mioide","debug","breakpointLimit")),256)
	D EQ^MIOIDET000(.FAIL,"[T030][terminal enabled]",+$G(CONF("mioide","terminal","enabled")),1)
	D EQ^MIOIDET000(.FAIL,"[T030][term input max]",+$G(CONF("mioide","terminal","maxInputBytes")),8192)
	Q
	;
