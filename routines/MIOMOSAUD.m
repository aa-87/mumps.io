MIOMOSAUD ; MIOMOS audit helpers
	QUIT
	;
EVENT(NAME,CTX,STATE)
	NEW ID
	SET ID=$INCREMENT(^MIO("MIOMOS","AUDIT","SEQ"))
	SET ^MIO("MIOMOS","AUDIT",ID,"ts")=$$NOWISO^MIOUTIL()
	SET ^MIO("MIOMOS","AUDIT",ID,"event")=$GET(NAME)
	SET ^MIO("MIOMOS","AUDIT",ID,"requestId")=$GET(CTX("request_id"))
	SET ^MIO("MIOMOS","AUDIT",ID,"route")=$GET(CTX("route"))
	SET ^MIO("MIOMOS","AUDIT",ID,"principal")=$GET(STATE("principal"))
	SET ^MIO("MIOMOS","AUDIT",ID,"sessionId")=$GET(STATE("sessionId"))
	SET ^MIO("MIOMOS","AUDIT",ID,"profile")=$GET(STATE("profile"))
	QUIT
	;
