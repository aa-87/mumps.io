MIOJWT ; Shared JWT facade over MIOSJWT
	QUIT
	;
MAKEHS256(CONF,CLAIMS,TOKEN,ERR)
	NEW SECRET,JSON
	KILL ERR SET TOKEN=""
	SET ERR("routine")="MIOJWT"
	SET SECRET=$$SECRET(.CONF,.ERR)
	IF SECRET="" QUIT 0
	SET JSON=$$EN^MIOJSON1(.CLAIMS)
	IF JSON="" SET ERR("error")="jwt_payload_encode_failed" QUIT 0
	SET TOKEN=$$MAKEHS256^MIOSJWT(JSON,SECRET)
	IF TOKEN="" SET ERR("error")="jwt_issue_failed" QUIT 0
	QUIT 1
	;
VERIFYHS256(CONF,TOKEN,CLAIMS,ERR)
	NEW SECRET,OUT,OK
	KILL ERR,CLAIMS
	SET ERR("routine")="MIOJWT"
	IF $GET(TOKEN)="" SET ERR("error")="jwt_missing" QUIT 0
	SET SECRET=$$SECRET(.CONF,.ERR)
	IF SECRET="" QUIT 0
	SET OK=$$VERIFYHS256^MIOSJWT(TOKEN,SECRET,.OUT)
	IF 'OK SET ERR("error")=$GET(OUT("err"),"jwt_invalid") QUIT 0
	IF '$$DECODE^MIOJSON($GET(OUT("payload")),.CLAIMS,.ERR) DO  QUIT 0
	. SET ERR("routine")="MIOJWT"
	. IF $GET(ERR("error"))="" SET ERR("error")="jwt_payload_decode_failed"
	QUIT 1
	;
SECRET(CONF,ERR)
	NEW SECRET
	SET SECRET=$GET(CONF("auth","jwt","hmacSecret"))
	IF SECRET'="" QUIT SECRET
	SET SECRET=$GET(CONF("auth","session","hmacSecret"))
	IF SECRET'="" QUIT SECRET
	SET SECRET=$GET(CONF("miomos","localAuth","hmacSecret"))
	IF SECRET'="" DO  QUIT SECRET
	. SET CONF("auth","jwt","hmacSecret")=SECRET
	SET SECRET=$GET(^MIO("AUTH","JWT","HS256","secret"))
	IF SECRET="" DO
	. SET SECRET="miojwt-"_$$UUID^MIOUTIL()
	. SET ^MIO("AUTH","JWT","HS256","secret")=SECRET
	. SET ^MIO("AUTH","JWT","HS256","createdAt")=$$NOWISO^MIOUTIL()
	SET CONF("auth","jwt","hmacSecret")=SECRET
	QUIT SECRET
	;
NOW()
	QUIT $$NOW^MIOSJWT()
	;
