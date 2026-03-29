MIOMOSCHAT ; MIOMOS collaboration chat helpers
	QUIT
	;
SEND(STATE,ROOM,TEXT,MSG,ERR)
	NEW ID,CLEAN
	KILL ERR,MSG
	SET ERR("routine")="MIOMOSCHAT"
	SET ROOM=$$ROOM($GET(ROOM))
	SET CLEAN=$$TEXT($GET(TEXT))
	IF CLEAN="" SET ERR("error")="chat_text_missing" QUIT 0
	SET ID=$INCREMENT(^MIO("MIOMOS","CHAT",ROOM,"SEQ"))
	SET ^MIO("MIOMOS","CHAT",ROOM,ID,"ts")=$$NOWISO^MIOUTIL()
	SET ^MIO("MIOMOS","CHAT",ROOM,ID,"principal")=$GET(STATE("principal"))
	SET ^MIO("MIOMOS","CHAT",ROOM,ID,"userName")=$GET(STATE("userName"))
	SET ^MIO("MIOMOS","CHAT",ROOM,ID,"text")=CLEAN
	SET MSG("id")=ID,MSG("room")=ROOM,MSG("ts")=$GET(^MIO("MIOMOS","CHAT",ROOM,ID,"ts"))
	SET MSG("principal")=$GET(STATE("principal")),MSG("userName")=$GET(STATE("userName")),MSG("text")=CLEAN
	QUIT 1
	;
FETCH(ROOM,LIMIT,OUT)
	NEW LAST,ID,N
	KILL OUT
	SET ROOM=$$ROOM($GET(ROOM))
	SET LIMIT=+$GET(LIMIT,20) IF LIMIT<1 SET LIMIT=20
	SET LAST=+$GET(^MIO("MIOMOS","CHAT",ROOM,"SEQ"))
	SET N=0
	FOR ID=LAST:-1:1 QUIT:N'<LIMIT  DO
	. IF '$DATA(^MIO("MIOMOS","CHAT",ROOM,ID)) QUIT
	. SET N=N+1
	. SET OUT(N,"id")=ID
	. SET OUT(N,"room")=ROOM
	. SET OUT(N,"ts")=$GET(^MIO("MIOMOS","CHAT",ROOM,ID,"ts"))
	. SET OUT(N,"principal")=$GET(^MIO("MIOMOS","CHAT",ROOM,ID,"principal"))
	. SET OUT(N,"userName")=$GET(^MIO("MIOMOS","CHAT",ROOM,ID,"userName"))
	. SET OUT(N,"text")=$GET(^MIO("MIOMOS","CHAT",ROOM,ID,"text"))
	DO REVERSE(.OUT)
	QUIT
	;
SNAPSHOT(ROOM,LIMIT,JSON)
	NEW OBJ,ARR,N
	DO FETCH($GET(ROOM),+$GET(LIMIT,20),.ARR)
	SET OBJ("ok")=1,OBJ("event")="chat.snapshot",OBJ("room")=$$ROOM($GET(ROOM))
	SET N=0
	FOR  SET N=$ORDER(ARR(N)) QUIT:N=""  DO
	. SET OBJ("messages",N,"id")=$GET(ARR(N,"id"))
	. SET OBJ("messages",N,"room")=$GET(ARR(N,"room"))
	. SET OBJ("messages",N,"ts")=$GET(ARR(N,"ts"))
	. SET OBJ("messages",N,"principal")=$GET(ARR(N,"principal"))
	. SET OBJ("messages",N,"userName")=$GET(ARR(N,"userName"))
	. SET OBJ("messages",N,"text")=$GET(ARR(N,"text"))
	SET JSON=$$EN^MIOJSON1(.OBJ)
	QUIT
	;
MESSAGE(MSG,JSON)
	NEW OBJ
	SET OBJ("ok")=1,OBJ("event")="chat.message"
	MERGE OBJ("message")=MSG
	SET JSON=$$EN^MIOJSON1(.OBJ)
	QUIT
	;
ROOM(ROOM)
	SET ROOM=$$TRIM^MIOUTIL($GET(ROOM))
	IF ROOM="" SET ROOM="general"
	QUIT ROOM
	;
TEXT(X)
	SET X=$TR($GET(X),$CHAR(13,10),"  ")
	SET X=$$TRIM^MIOUTIL(X)
	IF $LENGTH(X)>500 SET X=$EXTRACT(X,1,500)
	QUIT X
	;
REVERSE(OUT)
	NEW TMP,N,M
	MERGE TMP=OUT
	KILL OUT
	SET N=0,M=""
	FOR  SET M=$ORDER(TMP(M),-1) QUIT:M=""  DO
	. SET N=N+1
	. MERGE OUT(N)=TMP(M)
	QUIT
	;
	;
ROOMS(STATE,OUT)
	KILL OUT
	SET OUT(1,"key")="general",OUT(1,"label")="General"
	SET OUT(2,"key")="ops",OUT(2,"label")="Operations"
	IF $$HAS^MIOMOSPERM(.STATE,"chat.moderate")!$$HAS^MIOMOSPERM(.STATE,"admin.users.view") SET OUT(3,"key")="admin",OUT(3,"label")="Admin"
	QUIT
	;
CANUSE(STATE,ROOM)
	SET ROOM=$$ROOM($GET(ROOM))
	IF ROOM="general" QUIT $$HAS^MIOMOSPERM(.STATE,"chat.use")
	IF ROOM="ops" QUIT $$HAS^MIOMOSPERM(.STATE,"chat.use")
	IF ROOM="admin" QUIT $$HAS^MIOMOSPERM(.STATE,"chat.moderate")!$$HAS^MIOMOSPERM(.STATE,"admin.users.view")
	QUIT 0
	;
ROSTER(STATE,OUT)
	NEW SID,N,USER,ROLES
	KILL OUT
	SET SID="",N=0
	FOR  SET SID=$ORDER(^MIO("MIOMOS","SESSION","REG",SID)) QUIT:SID=""  DO
	. SET USER=$GET(^MIO("MIOMOS","SESSION","REG",SID,"userName"))
	. SET ROLES=$GET(^MIO("MIOMOS","SESSION","REG",SID,"roles"))
	. SET N=N+1
	. SET OUT(N,"sessionId")=SID
	. SET OUT(N,"principal")=$GET(^MIO("MIOMOS","SESSION","REG",SID,"principal"))
	. SET OUT(N,"userName")=$SELECT(USER'="":USER,1:$GET(^MIO("MIOMOS","SESSION","REG",SID,"principal"),"User"))
	. SET OUT(N,"roles")=ROLES
	. SET OUT(N,"roleLabel")=$$ROLELABEL^MIOMOSPERM(ROLES)
	. SET OUT(N,"isCurrent")=$SELECT(SID=$GET(STATE("sessionId")):1,1:0)
	QUIT
	;
