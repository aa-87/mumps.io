MIOMOSADMIN ; MIOMOS admin helpers
	QUIT
	;
COUNTS(OUT)
	NEW U,I,R,NOWD,NOWS
	KILL OUT
	SET (OUT("users"),OUT("enabled"),OUT("disabled"),OUT("locked"),OUT("invites"),OUT("resets"))=0
	SET NOWD=+$PIECE($HOROLOG,",",1),NOWS=+$PIECE($HOROLOG,",",2)
	SET U=""
	FOR  SET U=$ORDER(^MIO("MIOMOS","USER",U)) QUIT:U=""  DO
	. SET OUT("users")=OUT("users")+1
	. IF +$GET(^MIO("MIOMOS","USER",U,"enabled"),1)=1 SET OUT("enabled")=OUT("enabled")+1
	. IF +$GET(^MIO("MIOMOS","USER",U,"enabled"),1)'=1 SET OUT("disabled")=OUT("disabled")+1
	. IF $$AGESEC(NOWD,NOWS,+$GET(^MIO("MIOMOS","USER",U,"lockedUntilDay")),+$GET(^MIO("MIOMOS","USER",U,"lockedUntilSec")))>0 SET OUT("locked")=OUT("locked")+1
	SET I=""
	FOR  SET I=$ORDER(^MIO("MIOMOS","AUTH","INVITE",I)) QUIT:I=""  DO
	. IF $GET(^MIO("MIOMOS","AUTH","INVITE",I,"usedAt"))="" SET OUT("invites")=OUT("invites")+1
	SET R=""
	FOR  SET R=$ORDER(^MIO("MIOMOS","AUTH","RESET",R)) QUIT:R=""  DO
	. IF $GET(^MIO("MIOMOS","AUTH","RESET",R,"usedAt"))="" SET OUT("resets")=OUT("resets")+1
	QUIT
	;
USERLIST(LIMIT,OUT)
	NEW U,N,NOWD,NOWS
	KILL OUT
	SET LIMIT=+$GET(LIMIT,20) IF LIMIT<1 SET LIMIT=20
	SET N=0,NOWD=+$PIECE($HOROLOG,",",1),NOWS=+$PIECE($HOROLOG,",",2)
	SET U=""
	FOR  SET U=$ORDER(^MIO("MIOMOS","USER",U)) QUIT:U=""  DO  QUIT:N'<LIMIT
	. SET N=N+1
	. SET OUT(N,"principal")=U
	. SET OUT(N,"userName")=$GET(^MIO("MIOMOS","USER",U,"userName"),U)
	. SET OUT(N,"roles")=$GET(^MIO("MIOMOS","USER",U,"roles"))
	. SET OUT(N,"enabled")=+$GET(^MIO("MIOMOS","USER",U,"enabled"),1)
	. SET OUT(N,"failedCount")=+$GET(^MIO("MIOMOS","USER",U,"failedCount"))
	. SET OUT(N,"createdAt")=$GET(^MIO("MIOMOS","USER",U,"createdAt"))
	. SET OUT(N,"lastFailedAt")=$GET(^MIO("MIOMOS","USER",U,"lastFailedAt"))
	. SET OUT(N,"locked")=$SELECT($$AGESEC(NOWD,NOWS,+$GET(^MIO("MIOMOS","USER",U,"lockedUntilDay")),+$GET(^MIO("MIOMOS","USER",U,"lockedUntilSec")))>0:1,1:0)
	QUIT
	;
INVITELIST(LIMIT,OUT)
	NEW I,N
	KILL OUT
	SET LIMIT=+$GET(LIMIT,10) IF LIMIT<1 SET LIMIT=10
	SET I="",N=0
	FOR  SET I=$ORDER(^MIO("MIOMOS","AUTH","INVITE",I),-1) QUIT:I=""  DO  QUIT:N'<LIMIT
	. IF '$DATA(^MIO("MIOMOS","AUTH","INVITE",I)) QUIT
	. SET N=N+1
	. SET OUT(N,"token")=I
	. SET OUT(N,"label")=$GET(^MIO("MIOMOS","AUTH","INVITE",I,"label"))
	. SET OUT(N,"roles")=$GET(^MIO("MIOMOS","AUTH","INVITE",I,"roles"))
	. SET OUT(N,"createdBy")=$GET(^MIO("MIOMOS","AUTH","INVITE",I,"createdBy"))
	. SET OUT(N,"createdAt")=$GET(^MIO("MIOMOS","AUTH","INVITE",I,"createdAt"))
	. SET OUT(N,"usedBy")=$GET(^MIO("MIOMOS","AUTH","INVITE",I,"usedBy"))
	QUIT
	;
RESETLIST(LIMIT,OUT)
	NEW I,N
	KILL OUT
	SET LIMIT=+$GET(LIMIT,10) IF LIMIT<1 SET LIMIT=10
	SET I="",N=0
	FOR  SET I=$ORDER(^MIO("MIOMOS","AUTH","RESET",I),-1) QUIT:I=""  DO  QUIT:N'<LIMIT
	. IF '$DATA(^MIO("MIOMOS","AUTH","RESET",I)) QUIT
	. SET N=N+1
	. SET OUT(N,"token")=I
	. SET OUT(N,"principal")=$GET(^MIO("MIOMOS","AUTH","RESET",I,"principal"))
	. SET OUT(N,"createdBy")=$GET(^MIO("MIOMOS","AUTH","RESET",I,"createdBy"))
	. SET OUT(N,"createdAt")=$GET(^MIO("MIOMOS","AUTH","RESET",I,"createdAt"))
	. SET OUT(N,"usedAt")=$GET(^MIO("MIOMOS","AUTH","RESET",I,"usedAt"))
	QUIT
	;
AGESEC(D1,S1,D2,S2)
	IF (+$GET(D2)=0),(+$GET(S2)=0) QUIT 999999999
	QUIT (((+$GET(D2)-+$GET(D1))*86400)+(+$GET(S2)-+$GET(S1)))
	;
