MIOUIT010 ; demo route registration tests
 D START Q
 ;
START(FAIL)
 N LOCAL,TOP
 S TOP='$D(FAIL),LOCAL=0
 D T001(.LOCAL)
 D T010(.LOCAL)
 I TOP D  Q
 . I 'LOCAL W !,"OK - MIOUIT010"
 I LOCAL S FAIL=1
 Q
 ;
T001(FAIL)
 N CONF
 K ^MIO("ROUTE","RAW","GET","/mioui")
 K ^MIO("ROUTE","RAW","GET","/mioui/components")
 K ^MIO("ROUTE","RAW","GET","/mioui/tables")
 K ^MIO("ROUTE","RAW","GET","/mioui/forms")
 K ^MIO("ROUTE","RAW","GET","/mioui/export")
 K ^MIO("ROUTE","RAW","GET","/mioui/billing")
 K ^MIO("ROUTE","RAW","GET","/mioui/workflows")
 K ^MIO("ROUTE","RAW","GET","/mioui/trace")
 K ^MIO("ROUTE","RAW","GET","/mioui/premium")
 K ^MIO("ROUTE","RAW","GET","/mioui/large-table")
 K ^MIO("ROUTE","RAW","GET","/mioui/auth-forms")
 D REG^MIOUIDEMO(.CONF)
 D REG^MIOUIAFM(.CONF)
 D EQ^MIOUIT000(.FAIL,"[T001][home target]",$G(^MIO("ROUTE","RAW","GET","/mioui")),"HOME^MIOUIDEMO")
 D EQ^MIOUIT000(.FAIL,"[T001][components target]",$G(^MIO("ROUTE","RAW","GET","/mioui/components")),"COMP^MIOUIDEMO")
 D EQ^MIOUIT000(.FAIL,"[T001][tables target]",$G(^MIO("ROUTE","RAW","GET","/mioui/tables")),"TABLES^MIOUIDEMO")
 D EQ^MIOUIT000(.FAIL,"[T001][forms target]",$G(^MIO("ROUTE","RAW","GET","/mioui/forms")),"FORMS^MIOUIDEMO")
 D EQ^MIOUIT000(.FAIL,"[T001][export target]",$G(^MIO("ROUTE","RAW","GET","/mioui/export")),"EXPORT^MIOUIDEMO")
 D EQ^MIOUIT000(.FAIL,"[T001][billing target]",$G(^MIO("ROUTE","RAW","GET","/mioui/billing")),"BILLING^MIOUIDEMO")
 D EQ^MIOUIT000(.FAIL,"[T001][workflows target]",$G(^MIO("ROUTE","RAW","GET","/mioui/workflows")),"WORKFLOWS^MIOUIDEMO")
 D EQ^MIOUIT000(.FAIL,"[T001][trace target]",$G(^MIO("ROUTE","RAW","GET","/mioui/trace")),"TRACE^MIOUIDEMO")
 D EQ^MIOUIT000(.FAIL,"[T001][premium target]",$G(^MIO("ROUTE","RAW","GET","/mioui/premium")),"PREMIUM^MIOUIDEMO")
 D EQ^MIOUIT000(.FAIL,"[T001][large table target]",$G(^MIO("ROUTE","RAW","GET","/mioui/large-table")),"LARGETABLE^MIOUIDEMO")
 D EQ^MIOUIT000(.FAIL,"[T001][auth forms target]",$G(^MIO("ROUTE","RAW","GET","/mioui/auth-forms")),"AUTHFORMS^MIOUIAFM")
 Q
 ;
T010(FAIL)
 D EQ^MIOUIT000(.FAIL,"[T010][home auth]",+$G(^MIO("ROUTE","META","GET","/mioui","authRequired")),0)
 D EQ^MIOUIT000(.FAIL,"[T010][components auth]",+$G(^MIO("ROUTE","META","GET","/mioui/components","authRequired")),0)
 D EQ^MIOUIT000(.FAIL,"[T010][tables auth]",+$G(^MIO("ROUTE","META","GET","/mioui/tables","authRequired")),0)
 D EQ^MIOUIT000(.FAIL,"[T010][forms auth]",+$G(^MIO("ROUTE","META","GET","/mioui/forms","authRequired")),0)
 D EQ^MIOUIT000(.FAIL,"[T010][export auth]",+$G(^MIO("ROUTE","META","GET","/mioui/export","authRequired")),0)
 D EQ^MIOUIT000(.FAIL,"[T010][billing auth]",+$G(^MIO("ROUTE","META","GET","/mioui/billing","authRequired")),0)
 D EQ^MIOUIT000(.FAIL,"[T010][workflows auth]",+$G(^MIO("ROUTE","META","GET","/mioui/workflows","authRequired")),0)
 D EQ^MIOUIT000(.FAIL,"[T010][trace auth]",+$G(^MIO("ROUTE","META","GET","/mioui/trace","authRequired")),0)
 D EQ^MIOUIT000(.FAIL,"[T010][premium auth]",+$G(^MIO("ROUTE","META","GET","/mioui/premium","authRequired")),0)
 D EQ^MIOUIT000(.FAIL,"[T010][large table auth]",+$G(^MIO("ROUTE","META","GET","/mioui/large-table","authRequired")),0)
 D EQ^MIOUIT000(.FAIL,"[T010][auth forms auth]",+$G(^MIO("ROUTE","META","GET","/mioui/auth-forms","authRequired")),0)
 Q
 ;
