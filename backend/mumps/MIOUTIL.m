MIOUTIL ; Shared helpers. Encoding, ids, time, and small utilities.;
; API STABILITY
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; Purpose
; Shared helpers. Encoding, ids, time, and small utilities.;
;
; Responsibilities
; - Provide shared helpers.;
; - Keep behavior deterministic.;
;
; Entry Points
; - NOWISO
; - SEC2HMS
; - PAD2
; - UUID
; - HEX
; - DEC2HEX
; - TRIM
; - HEX2DEC
; - UTF8ENC
; - NOWMS
;
; Notes
; Keep comments short.;
; Do not log secrets.;
;
	; Generated V1-01 (YottaDB)
	;
	; Utility helpers kept ASCII-only for portability across GT.M/YottaDB terminals.;
	;
; Entry point
; See docs/routines for details.;
NOWISO() ; Timestamp (UTC-ish) using $HOROLOG + $ZDATE
	NEW H,DATE,TIME
	SET H=$HOROLOG
	SET DATE=$PIECE(H,",",1),TIME=$PIECE(H,",",2)
	NEW D SET D=$ZDATE(DATE,"YYYY-MM-DD")
	NEW T SET T=$$SEC2HMS(TIME)
	QUIT D_"T"_T_"Z"
	;
; Entry point
; See docs/routines for details.;
SEC2HMS(S)
	NEW HH,MM,SS
	SET HH=S\3600
	SET MM=(S#3600)\60
	SET SS=S#60
	QUIT $$PAD2(HH)_":"_$$PAD2(MM)_":"_$$PAD2(SS)
	;
; Entry point
; See docs/routines for details.;
PAD2(N)
	IF N<10 QUIT "0"_N
	QUIT N
	;
; Entry point
; See docs/routines for details.;
UUID()
	; Lightweight pseudo-UUID (not cryptographic). Fine for request IDs.;
	; Format: 8-4-4-4-12 hex
	NEW A,B,C,D,E
	SET A=$$HEX($RANDOM(65535),4)_$$HEX($RANDOM(65535),4)
	SET B=$$HEX($RANDOM(65535),4)
	SET C=$$HEX($RANDOM(65535),4)
	SET D=$$HEX($RANDOM(65535),4)
	SET E=$$HEX($RANDOM(65535),4)_$$HEX($RANDOM(65535),4)_$$HEX($RANDOM(65535),4)
	QUIT A_"-"_B_"-"_C_"-"_D_"-"_E
	;
; Entry point
; See docs/routines for details.;
HEX(N,W)
	NEW H SET H=$$DEC2HEX(N)
	FOR  QUIT:$LENGTH(H)'<W  SET H="0"_H
	QUIT H
	;
; Entry point
; See docs/routines for details.;
DEC2HEX(N)
	NEW D,H SET H=""
	IF N=0 QUIT "0"
	FOR  QUIT:N=0  DO
	. SET D=N#16
	. SET N=N\16
	. SET H=$EXTRACT("0123456789abcdef",D+1)_H
	QUIT H
	;
; Entry point
; See docs/routines for details.;
TRIM(S)
	NEW X SET X=S
	FOR  QUIT:$EXTRACT(X,1)'=" "  SET X=$EXTRACT(X,2,$LENGTH(X))
	FOR  QUIT:$EXTRACT(X,$LENGTH(X))'=" "  SET X=$EXTRACT(X,1,$LENGTH(X)-1)
	QUIT X
	;
; ---- JSON/Unicode helpers ----
	;
; Entry point
; See docs/routines for details.;
HEX2DEC(HX) ; returns -1 on invalid
	NEW I,C,V,RES
	SET RES=0
	IF $LENGTH(HX)=0 QUIT -1
	FOR I=1:1:$LENGTH(HX) DO  QUIT:RES<0
	. SET C=$EXTRACT(HX,I)
	. SET V=$FIND("0123456789abcdef",$ZCONVERT(C,"L"))-2
	. IF V<0 SET RES=-1 QUIT
	. SET RES=(RES*16)+V
	QUIT RES
	;
; Entry point
; See docs/routines for details.;
UTF8ENC(CP) ; encode Unicode codepoint -> UTF-8 bytes (string)
	; Reject invalid ranges
	IF CP<0 QUIT ""
	IF (CP>=55296),(CP<=57343) QUIT ""  ; surrogate code points invalid as scalars
	IF CP>1114111 QUIT ""
	IF CP<128 QUIT $CHAR(CP)
	IF CP<2048 QUIT $CHAR(192+(CP\64))_$CHAR(128+(CP#64))
	IF CP<65536 QUIT $CHAR(224+(CP\4096))_$CHAR(128+((CP\64)#64))_$CHAR(128+(CP#64))
	QUIT $CHAR(240+(CP\262144))_$CHAR(128+((CP\4096)#64))_$CHAR(128+((CP\64)#64))_$CHAR(128+(CP#64))
	;
; Entry point
; See docs/routines for details.;
NOWMS() ; coarse milliseconds using $HOROLOG
	NEW H,S
	SET H=$HOROLOG,S=$PIECE(H,",",2)
	QUIT (S*1000)
	;
URLDEC(S) ;
	; URL decode.;
	; Converts %HH and + to spaces.;
	NEW I,C,OUT,H
	SET OUT=""
	FOR I=1:1:$L(S) DO
	. SET C=$E(S,I)
	. IF C="+" SET OUT=OUT_" " QUIT
	. IF C="%" DO  QUIT
	. . SET H=$E(S,I+1,I+2)
	. . IF $L(H)=2 SET OUT=OUT_$C($$H2D^MIOUTIL(H)),I=I+2 QUIT
	. . SET OUT=OUT_C
	. SET OUT=OUT_C
	QUIT OUT
	;
H2D(H) ;
	NEW A,B
	SET A=$$HX($E(H,1)),B=$$HX($E(H,2))
	QUIT (A*16)+B
	;
HX(C) ;
	IF C?1N QUIT +C
	SET C=$ZCONVERT(C,"U")
	IF C="A" QUIT 10
	IF C="B" QUIT 11
	IF C="C" QUIT 12
	IF C="D" QUIT 13
	IF C="E" QUIT 14
	IF C="F" QUIT 15
	QUIT 0
	;
READFILE(PATH,OUT,ERR) ;
	; Read a text file into OUT() by line.;
	NEW POP
	OPEN PATH:(readonly):1 ELSE  DO  QUIT 0
	. SET ERR("error")="open_failed"
	USE PATH
	NEW I,LINE SET I=0
	FOR  READ LINE QUIT:$ZEOF  DO
	. SET I=I+1
	. SET OUT(I)=LINE
	CLOSE PATH
	QUIT 1
	;
LC(S) ;
	QUIT $ZCONVERT($GET(S),"L")
	;
URLE(S) ;
	; URL encode.;
	NEW I,C,OUT
	SET OUT=""
	FOR I=1:1:$L($G(S)) DO
	. SET C=$E(S,I)
	. IF C?1AN SET OUT=OUT_C QUIT
	. IF C=" " SET OUT=OUT_"+" QUIT
	. SET OUT=OUT_"%"_$$D2H^MIOUTIL($ASCII(C))
	QUIT OUT
	;
D2H(N) ;
	; Decimal 0-255 to 2-digit hex.;
	NEW H SET H="0123456789ABCDEF"
	QUIT $E(H,(N\16)+1)_$E(H,(N#16)+1)
	;
EPOCHS() ;
	; Unix epoch seconds.;
	; $HOROLOG day 0 is 1840-12-31.;
	; Unix epoch is 1970-01-01.;
	NEW H,DAY,SEC,OFF
	SET H=$HOROLOG
	SET DAY=+$PIECE(H,",",1)
	SET SEC=+$PIECE(H,",",2)
	SET OFF=47117
	QUIT ((DAY-OFF)*86400)+SEC
	;
EPOCHMS() ;
	; Unix epoch milliseconds (coarse).;
	QUIT ($$EPOCHS()*1000)
	;
ISO8601() ;
	NEW H,DAYS,SECS,RD
	NEW N,QC,DQC,CENT,DCENT,QUAD,DQUAD,YINDEX
	NEW Y,M,D,DOY,MLEN,I
	NEW HOUR,MIN,SEC
	;
	; ---------------------------
	; Get $H
	; ---------------------------
	SET H=$H
	SET DAYS=+H
	SET SECS=$P(H,",",2)
	;
	; ---------------------------
	; Convert $H-days to Rata Die (RD)
	; RD 1 = 0001-01-01
	; $H day 0 = 1840-12-31
	; RD(1840-12-31) = 672046
	; ---------------------------
	SET RD=672046+DAYS
	;
	; ---------------------------
	; RD -> Gregorian Y-M-D (all integer math)
	; ---------------------------
	SET N=RD-1
	SET QC=N\146097,DQC=N#146097
	SET CENT=DQC\36524,DCENT=DQC#36524
	SET QUAD=DCENT\1461,DQUAD=DCENT#1461
	SET YINDEX=DQUAD\365
	;
	SET Y=(QC*400)+(CENT*100)+(QUAD*4)+YINDEX+1
	IF (CENT=4)!(YINDEX=4) SET Y=Y-1
	;
	; Day-of-year
	SET DOY=RD-($$DBY(Y)+1)+1
	;
	; Month/day from DOY
	SET MLEN(1)=31,MLEN(2)=28,MLEN(3)=31,MLEN(4)=30,MLEN(5)=31,MLEN(6)=30
	SET MLEN(7)=31,MLEN(8)=31,MLEN(9)=30,MLEN(10)=31,MLEN(11)=30,MLEN(12)=31
	IF $$ISLEAP(Y) SET MLEN(2)=29
	;
	SET M=1
	FOR  QUIT:DOY'>MLEN(M)  SET DOY=DOY-MLEN(M),M=M+1
	SET D=DOY
	;
	; ---------------------------
	; Time (SECS since midnight)
	; ---------------------------
	SET HOUR=SECS\3600
	SET MIN=(SECS#3600)\60
	SET SEC=SECS#60
	;
	; ---------------------------
	; ISO-8601
	; ---------------------------
	QUIT $$Z(Y,4)_"-"_$$Z(M,2)_"-"_$$Z(D,2)_"T"_$$Z(HOUR,2)_":"_$$Z(MIN,2)_":"_$$Z(SEC,2)
	;
	; end ISO8601
	;
	;
; Days before Jan 1 of year Y (Rata Die base)
DBY(Y) ;
	NEW Y1
	SET Y1=Y-1
	QUIT (365*Y1)+(Y1\4)-(Y1\100)+(Y1\400)
	;
ISLEAP(Y) ;
	QUIT '(Y#4)&((Y#100)!'(Y#400))
	;
Z(N,L) ;
	NEW S
	SET S=N
	FOR  QUIT:$L(S)'<L  SET S="0"_S
	QUIT S
	;
YEAR() Q "20"_$PIECE($ZDATE($HOROLOG),"/",3)
	;
ESC(X) Q $$ESC^MIOJSON2(X)
	;
REPLACE(s,f,t)
	i $tr(s,f)=s q s
	n o,i s o="" f i=1:1:$l(s,f)  s o=o_$s(i<$l(s,f):$p(s,f,i)_t,1:$p(s,f,i))
	q o