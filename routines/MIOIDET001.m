MIOIDET001 ; MIOIDE bootstrap and route tests
	D START Q
	;
START(FAIL)
	N TOP,LOCAL
	S TOP='$D(FAIL),LOCAL=0
	D T001(.LOCAL)
	D T010(.LOCAL)
	I TOP D  Q
	. I 'LOCAL W !,"OK - MIOIDET001"
	I LOCAL S FAIL=1
	Q
	;
T001(FAIL)
	N CONF
	D CONFDEF^MIOIDE(.CONF)
	D EQ^MIOIDET000(.FAIL,"[T001][enabled]",+$G(CONF("mioide","enabled")),1)
	D EQ^MIOIDET000(.FAIL,"[T001][auth]",+$G(CONF("mioide","authRequired")),1)
	D EQ^MIOIDET000(.FAIL,"[T001][ws enabled]",+$G(CONF("mioide","ws","enabled")),1)
	D EQ^MIOIDET000(.FAIL,"[T001][events path]",$G(CONF("mioide","ws","eventsPath")),"/mioide/ws/events")
	D EQ^MIOIDET000(.FAIL,"[T001][terminal path]",$G(CONF("mioide","ws","terminalPath")),"/mioide/ws/terminal")
	D EQ^MIOIDET000(.FAIL,"[T001][debug enabled]",+$G(CONF("mioide","debug","enabled")),1)
	Q
	;
T010(FAIL)
	N CONF
	K ^MIO("ROUTE","RAW","GET","/mioide")
	K ^MIO("ROUTE","RAW","WS","/mioide/ws/events")
	K ^MIO("ROUTE","RAW","WS","/mioide/ws/terminal")
	K ^MIO("ROUTE","RAW","POST","/mioide/api/debug/sessions")
	K ^MIO("ROUTE","RAW","GET","/mioide/api/debug/sessions/:sid")
	D CONFDEF^MIOIDE(.CONF)
	D REG^MIOIDE(.CONF)
	D EQ^MIOIDET000(.FAIL,"[T010][home]",$G(^MIO("ROUTE","RAW","GET","/mioide")),"HOME^MIOIDER")
	D EQ^MIOIDET000(.FAIL,"[T010][ws events]",$G(^MIO("ROUTE","RAW","WS","/mioide/ws/events")),"EVENTS^MIOIDEWS")
	D EQ^MIOIDET000(.FAIL,"[T010][ws terminal]",$G(^MIO("ROUTE","RAW","WS","/mioide/ws/terminal")),"TERMINAL^MIOIDEWS")
	D EQ^MIOIDET000(.FAIL,"[T010][ws persistent]",+$G(^MIO("ROUTE","META","WS","/mioide/ws/events","wsPersistent")),1)
	D EQ^MIOIDET000(.FAIL,"[T010][auth required]",+$G(^MIO("ROUTE","META","GET","/mioide","authRequired")),1)
	D EQ^MIOIDET000(.FAIL,"[T010][debug start]",$G(^MIO("ROUTE","RAW","POST","/mioide/api/debug/sessions")),"APIDBGST^MIOIDER")
	D EQ^MIOIDET000(.FAIL,"[T010][debug snap]",$G(^MIO("ROUTE","RAW","GET","/mioide/api/debug/sessions/:sid")),"APIDBGSN^MIOIDER")
	Q
	;