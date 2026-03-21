MIOIDET001 ; MIOIDE config and route tests
	D START Q
	;
START(FAIL)
	N TOP,LOCAL
	S TOP='$D(FAIL),LOCAL=0
	D T001(.LOCAL)
	D T010(.LOCAL)
	D T020(.LOCAL)
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
	D EQ^MIOIDET000(.FAIL,"[T001][roles]",$G(CONF("mioide","roles")),"developer,admin")
	D EQ^MIOIDET000(.FAIL,"[T001][routine dir]",$G(CONF("mioide","routineDir")),"routines")
	D EQ^MIOIDET000(.FAIL,"[T001][template dir]",$G(CONF("server","templateDir")),"templates")
	D EQ^MIOIDET000(.FAIL,"[T001][theme]",$G(CONF("mioide","theme","default")),"dark")
	Q
	;
T010(FAIL)
	N CONF
	K ^MIO("ROUTE","RAW","GET","/mioide")
	K ^MIO("ROUTE","RAW","GET","/mioide/api/routines")
	K ^MIO("ROUTE","RAW","GET","/mioide/api/routines/:name/source")
	K ^MIO("ROUTE","RAW","PUT","/mioide/api/routines/:name/source")
	K ^MIO("ROUTE","RAW","POST","/mioide/api/routines/:name/compile")
	K ^MIO("ROUTE","RAW","POST","/mioide/api/routines/:name/run")
	D CONFDEF^MIOIDE(.CONF)
	S CONF("mioide","authRequired")=0
	D REG^MIOIDE(.CONF)
	D EQ^MIOIDET000(.FAIL,"[T010][home]",$G(^MIO("ROUTE","RAW","GET","/mioide")),"HOME^MIOIDER")
	D EQ^MIOIDET000(.FAIL,"[T010][list]",$G(^MIO("ROUTE","RAW","GET","/mioide/api/routines")),"APIRTN^MIOIDER")
	D EQ^MIOIDET000(.FAIL,"[T010][load]",$G(^MIO("ROUTE","RAW","GET","/mioide/api/routines/:name/source")),"APILOAD^MIOIDER")
	D EQ^MIOIDET000(.FAIL,"[T010][save]",$G(^MIO("ROUTE","RAW","PUT","/mioide/api/routines/:name/source")),"APISAVE^MIOIDER")
	D EQ^MIOIDET000(.FAIL,"[T010][compile]",$G(^MIO("ROUTE","RAW","POST","/mioide/api/routines/:name/compile")),"APICOMP^MIOIDER")
	D EQ^MIOIDET000(.FAIL,"[T010][run]",$G(^MIO("ROUTE","RAW","POST","/mioide/api/routines/:name/run")),"APIRUN^MIOIDER")
	D EQ^MIOIDET000(.FAIL,"[T010][auth required]",+$G(^MIO("ROUTE","META","GET","/mioide","authRequired")),0)
	Q
	;
T020(FAIL)
	N CONF
	K ^MIO("ROUTE","RAW","GET","/mioide")
	D CONFDEF^MIOIDE(.CONF)
	D REG^MIOIDE(.CONF)
	D EQ^MIOIDET000(.FAIL,"[T020][auth default]",+$G(^MIO("ROUTE","META","GET","/mioide","authRequired")),1)
	Q
	;
