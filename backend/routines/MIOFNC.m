MIOFNC ; MUMPS.IO - Form / URL helper functions
	;
	; Decode application/x-www-form-urlencoded into an M array.;
	;
	; Entry points:
	;   DO DECODEFORM^MIOFNC(IN,.OUT)
	;
	; Output rules:
	;   OUT(name)=value                      (first occurrence)
	;   OUT(name,0)=n, OUT(name,1..n)=...    (if repeated key appears)
	;
	QUIT
	;
DECODEFORM(IN,OUT) ; Decode x-www-form-urlencoded string IN into OUT array
	; IN   = "a=1&b=two+words&c=%7B%7D"
	; OUT  (by reference) result array
	NEW i,pair,eq,kEnc,vEnc,k,v
	KILL OUT
	SET IN=$GET(IN)
	;
	; Some clients may use ';' as a separator (legacy); normalize to '&'
	SET IN=$TRANSLATE(IN,";","&")
	;
	FOR i=1:1:$LENGTH(IN,"&") DO
	. SET pair=$PIECE(IN,"&",i)
	. QUIT:pair=""
	. SET eq=$FIND(pair,"=")
	. IF eq>0 DO
	. . SET kEnc=$EXTRACT(pair,1,eq-2)
	. . SET vEnc=$EXTRACT(pair,eq,$LENGTH(pair))
	. ELSE  DO
	. . SET kEnc=pair
	. . SET vEnc=""
	. SET k=$$URLDEC(kEnc)
	. SET v=$$URLDEC(vEnc)
	. DO SETKV(.OUT,k,v)
	QUIT
	;
SETKV(OUT,KEY,VAL) ; Store KEY=VAL into OUT, preserving duplicates
	NEW cnt
	QUIT:$GET(KEY)=""
	;
	IF '$DATA(OUT(KEY)) DO  QUIT
	. SET OUT(KEY)=VAL
	;
	SET cnt=$GET(OUT(KEY,0))
	IF cnt="" DO  QUIT
	. ; first duplicate: preserve original scalar as OUT(KEY,1)
	. SET OUT(KEY,0)=2
	. SET OUT(KEY,1)=$GET(OUT(KEY))
	. SET OUT(KEY,2)=VAL
	;
	SET cnt=cnt+1
	SET OUT(KEY,0)=cnt
	SET OUT(KEY,cnt)=VAL
	QUIT
	;
URLDEC(X) ; Extrinsic: URL-decode ( '+' => ' ', %HH => byte )
	NEW Y,OUT,I,L,C,HEX,B
	SET Y=$TRANSLATE($GET(X),"+"," ")
	SET OUT=""
	SET L=$LENGTH(Y)
	SET I=1
	FOR  QUIT:I>L  DO
	. SET C=$EXTRACT(Y,I)
	. IF C="%",(I+2)'>L DO  QUIT
	. . SET HEX=$EXTRACT(Y,I+1,I+2)
	. . IF $$ISHEX2(HEX) DO
	. . . SET B=$$HEX2DEC(HEX)
	. . . SET OUT=OUT_$ZCHAR(B)
	. . . SET I=I+3
	. . ELSE  DO
	. . . SET OUT=OUT_C
	. . . SET I=I+1
	. ELSE  DO
	. . SET OUT=OUT_C
	. . SET I=I+1
	QUIT OUT
ISHEX2(HH) ; 1 if HH is exactly two hex digits
	NEW ok
	SET ok=1
	IF $L($G(HH))'=2 SET ok=0
	ELSE  IF $$HEXVAL($E(HH,1))<0 SET ok=0
	ELSE  IF $$HEXVAL($E(HH,2))<0 SET ok=0
	QUIT ok
HEXVAL(C) ; "A"->10, "f"->15, non-hex -> -1
	NEW U,P
	SET U=$ZCONVERT($GET(C),"U")
	SET P=$FIND("0123456789ABCDEF",U)
	QUIT $SELECT(P=0:-1,1:P-2)
HEX2DEC(HH) ; "7F" -> 127
	NEW a,b
	SET a=$$HEXVAL($EXTRACT(HH,1))
	SET b=$$HEXVAL($EXTRACT(HH,2))
	QUIT (a*16)+b
	;