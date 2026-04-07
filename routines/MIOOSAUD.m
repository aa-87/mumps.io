MIOOSAUD ; MIOOS auth audit helpers
	QUIT
	;
EVENT(NAME,CTX,STATE,DETAIL,OUTCOME,SUBJECT,PROVIDER)
	NEW ID,NOWD,NOWS,CORR,PRIN,SESS,PROF
	SET ID=$INCREMENT(^MIO("MIOOS","AUDIT","SEQ"))
	SET NOWD=+$PIECE($HOROLOG,",",1),NOWS=+$PIECE($HOROLOG,",",2)
	SET CORR=$$CORRID(.CTX,.STATE)
	SET PRIN=$SELECT($GET(STATE("principal"))'="":$GET(STATE("principal")),1:$GET(SUBJECT))
	SET SESS=$GET(STATE("sessionId"))
	SET PROF=$GET(STATE("profile"))
	SET ^MIO("MIOOS","AUDIT",ID,"ts")=$$NOWISO^MIOUTIL()
	SET ^MIO("MIOOS","AUDIT",ID,"day")=NOWD
	SET ^MIO("MIOOS","AUDIT",ID,"sec")=NOWS
	SET ^MIO("MIOOS","AUDIT",ID,"event")=$GET(NAME)
	SET ^MIO("MIOOS","AUDIT",ID,"detail")=$$DETAIL($GET(DETAIL))
	SET ^MIO("MIOOS","AUDIT",ID,"outcome")=$GET(OUTCOME)
	SET ^MIO("MIOOS","AUDIT",ID,"subject")=$GET(SUBJECT)
	SET ^MIO("MIOOS","AUDIT",ID,"provider")=$GET(PROVIDER)
	SET ^MIO("MIOOS","AUDIT",ID,"requestId")=$GET(CTX("request_id"))
	SET ^MIO("MIOOS","AUDIT",ID,"correlationId")=CORR
	SET ^MIO("MIOOS","AUDIT",ID,"route")=$GET(CTX("route"))
	SET ^MIO("MIOOS","AUDIT",ID,"principal")=PRIN
	SET ^MIO("MIOOS","AUDIT",ID,"sessionId")=SESS
	SET ^MIO("MIOOS","AUDIT",ID,"profile")=PROF
	QUIT
	;
DETAIL(X)
	SET X=$GET(X)
	IF $LENGTH(X)>240 SET X=$EXTRACT(X,1,240)
	QUIT X
	;
CORRID(CTX,STATE)
	NEW X
	SET X=$GET(CTX("request_id")) IF X'="" QUIT X
	SET X=$GET(CTX("auth","claims","sid")) IF X'="" QUIT X
	SET X=$GET(STATE("sessionId")) IF X'="" QUIT X
	QUIT "mioos-audit-unknown"
	;
COUNT()
	NEW ID,N
	SET (ID,N)=0
	FOR  SET ID=$ORDER(^MIO("MIOOS","AUDIT",ID)) QUIT:ID=""  DO
	. IF +ID'>0 QUIT
	. SET N=N+1
	QUIT N
	;
TAIL(STATE,CONF,LIMIT,OUT,ERR)
	NEW LAST,ID,N,SCP,PRIN
	KILL OUT,ERR
	SET ERR("routine")="MIOOSAUD"
	SET LIMIT=+$GET(LIMIT,+$GET(CONF("mioos","audit","reportLimit"),20)) IF LIMIT<1 SET LIMIT=20
	SET SCP=$$SCOPE(.STATE),PRIN=$GET(STATE("principal"))
	SET OUT("scope")=SCP
	SET OUT("principal")=PRIN
	SET LAST=+$GET(^MIO("MIOOS","AUDIT","SEQ"))
	SET N=0
	FOR ID=LAST:-1:1 QUIT:N'<LIMIT  DO
	. IF '$DATA(^MIO("MIOOS","AUDIT",ID)) QUIT
	. IF '$$ALLOW(ID,SCP,PRIN) QUIT
	. SET N=N+1
	. DO MERGE1(ID,$NAME(OUT("entries",N)))
	SET OUT("count")=N
	QUIT 1
	;
REPORT(STATE,CONF,OUT,ERR)
	NEW ID,LIMIT,SCP,PRIN,WIN,NOWD,NOWS,DAY,SEC,AGE,E,O,P,TMP
	KILL OUT,ERR
	SET ERR("routine")="MIOOSAUD"
	SET LIMIT=+$GET(CONF("mioos","audit","reportLimit"),50) IF LIMIT<1 SET LIMIT=50
	SET WIN=+$GET(CONF("mioos","audit","reportWindowDays"),30) IF WIN<1 SET WIN=30
	SET SCP=$$SCOPE(.STATE),PRIN=$GET(STATE("principal"))
	SET NOWD=+$PIECE($HOROLOG,",",1),NOWS=+$PIECE($HOROLOG,",",2)
	SET OUT("scope")=SCP
	SET OUT("principal")=PRIN
	SET OUT("limit")=LIMIT
	SET OUT("windowDays")=WIN
	SET OUT("retainDays")=+$GET(CONF("mioos","audit","retainDays"),365)
	SET (OUT("count"),OUT("outcomes","success"),OUT("outcomes","failure"),OUT("outcomes","denied"))=0
	SET (OUT("providers","local"),OUT("providers","framework"))=0
	SET ID=0
	FOR  SET ID=$ORDER(^MIO("MIOOS","AUDIT",ID)) QUIT:ID=""  DO
	. IF +ID'>0 QUIT
	. IF '$$ALLOW(ID,SCP,PRIN) QUIT
	. SET DAY=+$GET(^MIO("MIOOS","AUDIT",ID,"day")),SEC=+$GET(^MIO("MIOOS","AUDIT",ID,"sec"))
	. SET AGE=$$AGESEC(DAY,SEC,NOWD,NOWS)
	. IF AGE>(WIN*86400) QUIT
	. SET OUT("count")=OUT("count")+1
	. SET O=$GET(^MIO("MIOOS","AUDIT",ID,"outcome")) IF O'="" SET OUT("outcomes",O)=+$GET(OUT("outcomes",O))+1
	. SET P=$GET(^MIO("MIOOS","AUDIT",ID,"provider")) IF P'="" SET OUT("providers",P)=+$GET(OUT("providers",P))+1
	. SET E=$GET(^MIO("MIOOS","AUDIT",ID,"event")) IF E'="" SET OUT("events",E)=+$GET(OUT("events",E))+1
	IF '$$TAIL(.STATE,.CONF,LIMIT,.TMP,.ERR) QUIT 0
	MERGE OUT("entries")=TMP("entries")
	QUIT 1
	;
EXPORT(STATE,CONF,LIMIT,OUT,ERR)
	NEW TMP
	KILL OUT,ERR
	SET ERR("routine")="MIOOSAUD"
	IF '$$TAIL(.STATE,.CONF,+$GET(LIMIT),.TMP,.ERR) QUIT 0
	MERGE OUT=TMP
	SET OUT("exportedAt")=$$NOWISO^MIOUTIL()
	QUIT 1
	;
MERGE1(ID,ROOT)
	SET @ROOT@("id")=ID
	SET @ROOT@("ts")=$GET(^MIO("MIOOS","AUDIT",ID,"ts"))
	SET @ROOT@("event")=$GET(^MIO("MIOOS","AUDIT",ID,"event"))
	SET @ROOT@("detail")=$GET(^MIO("MIOOS","AUDIT",ID,"detail"))
	SET @ROOT@("outcome")=$GET(^MIO("MIOOS","AUDIT",ID,"outcome"))
	SET @ROOT@("subject")=$GET(^MIO("MIOOS","AUDIT",ID,"subject"))
	SET @ROOT@("provider")=$GET(^MIO("MIOOS","AUDIT",ID,"provider"))
	SET @ROOT@("principal")=$GET(^MIO("MIOOS","AUDIT",ID,"principal"))
	SET @ROOT@("sessionId")=$GET(^MIO("MIOOS","AUDIT",ID,"sessionId"))
	SET @ROOT@("route")=$GET(^MIO("MIOOS","AUDIT",ID,"route"))
	SET @ROOT@("correlationId")=$GET(^MIO("MIOOS","AUDIT",ID,"correlationId"))
	QUIT
	;
ALLOW(ID,SCP,PRIN)
	IF $GET(SCP)="all" QUIT 1
	QUIT $SELECT($GET(^MIO("MIOOS","AUDIT",ID,"principal"))=$GET(PRIN):1,1:0)
	;
SCOPE(STATE)
	IF $$HASROLE($GET(STATE("roles")),"admin") QUIT "all"
	QUIT "self"
	;
HASROLE(CSV,ROLE)
	NEW I,X,FOUND
	SET FOUND=0
	FOR I=1:1:$LENGTH($GET(CSV),",") DO  QUIT:FOUND
	. SET X=$$LOW^MIOUTIL($$TRIM^MIOUTIL($PIECE($GET(CSV),",",I)))
	. IF X=$$LOW^MIOUTIL($GET(ROLE)) SET FOUND=1
	QUIT FOUND
	;
AGESEC(D1,S1,D2,S2)
	IF (+$GET(D1)=0),(+$GET(S1)=0) QUIT 0
	QUIT (((+$GET(D2)-+$GET(D1))*86400)+(+$GET(S2)-+$GET(S1)))
	;
