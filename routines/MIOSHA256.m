MIOSHA256 ; Pure MUMPS SHA-256 / HMAC-SHA256
	;
	; Public entry points
	;   $$SHA256^MIOSHA256(DATA)        -> 64-char lowercase hex digest
	;   $$HMAC^MIOSHA256(KEY,DATA)      -> 64-char lowercase hex HMAC-SHA256
	;   $$HMACHEX^MIOSHA256(KEYHEX,DATA)-> 64-char lowercase hex HMAC-SHA256, hex key input
	;   $$HEX2RAW^MIOSHA256(HEX)        -> raw bytes from hex
	;   $$RAW2HEX^MIOSHA256(BIN)        -> lowercase hex from raw bytes
	;
	; Notes
	; - Pure MUMPS implementation; no shell calls, no external libraries.;
	; - Optimized for YottaDB / GT.M style runtimes.;
	; - Input strings are treated as raw byte strings.;
	;
	Q
	;
SHA256(DATA) ;
	N J,I,ML,PAD,BITLEN,HI,LO,OFF,T
	N A,B,C,D,E,F,G,H,T1,T2
	N W,HV,OUT,BLK
	D INIT
	;
	S ML=$L($G(DATA))
	S DATA=$G(DATA)_$C(128)
	S PAD=((56-((ML+1)#64))+64)#64
	I PAD>0 S DATA=DATA_$$REPEAT($C(0),PAD)
	;
	; append 64-bit big-endian bit length
	S BITLEN=ML*8
	S HI=(BITLEN\4294967296)#4294967296
	S LO=BITLEN#4294967296
	S DATA=DATA_$$BE32(HI)_$$BE32(LO)
	;
	; initial hash values
	F I=0:1:7 S HV(I)=^MIO("MIOSHA256","IV",I)
	;
	F OFF=1:64:$L(DATA) D
	. ; message schedule
	. F T=0:1:15 S W(T)=$$GET32(DATA,OFF+(T*4))
	. F T=16:1:63 D
	. . S W(T)=$$U32($$SSIG1(W(T-2))+W(T-7)+$$SSIG0(W(T-15))+W(T-16))
	. ;
	. S A=HV(0),B=HV(1),C=HV(2),D=HV(3)
	. S E=HV(4),F=HV(5),G=HV(6),H=HV(7)
	. ;
	. F T=0:1:63 D
	. . S T1=$$U32(H+$$BSIG1(E)+$$CH(E,F,G)+^MIO("MIOSHA256","K",T)+W(T))
	. . S T2=$$U32($$BSIG0(A)+$$MAJ(A,B,C))
	. . S H=G
	. . S G=F
	. . S F=E
	. . S E=$$U32(D+T1)
	. . S D=C
	. . S C=B
	. . S B=A
	. . S A=$$U32(T1+T2)
	. ;
	. S HV(0)=$$U32(HV(0)+A)
	. S HV(1)=$$U32(HV(1)+B)
	. S HV(2)=$$U32(HV(2)+C)
	. S HV(3)=$$U32(HV(3)+D)
	. S HV(4)=$$U32(HV(4)+E)
	. S HV(5)=$$U32(HV(5)+F)
	. S HV(6)=$$U32(HV(6)+G)
	. S HV(7)=$$U32(HV(7)+H)
	;
	S OUT=""
	F I=0:1:7 S OUT=OUT_$$HEX8(HV(I))
	Q OUT
	;
HMAC(KEY,DATA) ;
	N BKEY,IPAD,OPAD,I,LEN
	D INIT
	S BKEY=$G(KEY)
	;
	; RFC 2104 / 4231 key normalization
	I $L(BKEY)>64 S BKEY=$$HEX2RAW($$SHA256(BKEY))
	I $L(BKEY)<64 S BKEY=BKEY_$$REPEAT($C(0),64-$L(BKEY))
	;
	S IPAD="",OPAD=""
	F I=1:1:64 D
	. S LEN=$A(BKEY,I)
	. S IPAD=IPAD_$C(^MIO("MIOSHA256","xor",LEN,54))
	. S OPAD=OPAD_$C(^MIO("MIOSHA256","xor",LEN,92))
	;
	Q $$SHA256(OPAD_$$HEX2RAW($$SHA256(IPAD_$G(DATA))))
	;
HMACHEX(KEYHEX,DATA) ;
	Q $$HMAC($$HEX2RAW($G(KEYHEX)),$G(DATA))
	;
	; =========================
	; Internal helpers
	; =========================
	;
INIT ;
	N A,B,I,X,LIST,CNT
	I $G(^MIO("MIOSHA256","READY")) Q
	K ^MIO("MIOSHA256")
	;
	; powers of two
	S ^MIO("MIOSHA256","P2",0)=1
	F I=1:1:32 S ^MIO("MIOSHA256","P2",I)=^MIO("MIOSHA256","P2",I-1)*2
	;
	; bytewise XOR / AND lookup tables
	F A=0:1:255 D
	. F B=0:1:255 D
	. . S ^MIO("MIOSHA256","xor",A,B)=$$XORB(A,B)
	. . S ^MIO("MIOSHA256","and",A,B)=$$ANDB(A,B)
	;
	; initial hash values
	S LIST="6a09e667,bb67ae85,3c6ef372,a54ff53a,510e527f,9b05688c,1f83d9ab,5be0cd19"
	F I=1:1:8 S ^MIO("MIOSHA256","IV",I-1)=$$HEX2DEC($P(LIST,",",I))
	;
	; round constants
	S LIST="428a2f98,71374491,b5c0fbcf,e9b5dba5,3956c25b,59f111f1,923f82a4,ab1c5ed5"
	S LIST=LIST_",d807aa98,12835b01,243185be,550c7dc3,72be5d74,80deb1fe,9bdc06a7,c19bf174"
	S LIST=LIST_",e49b69c1,efbe4786,0fc19dc6,240ca1cc,2de92c6f,4a7484aa,5cb0a9dc,76f988da"
	S LIST=LIST_",983e5152,a831c66d,b00327c8,bf597fc7,c6e00bf3,d5a79147,06ca6351,14292967"
	S LIST=LIST_",27b70a85,2e1b2138,4d2c6dfc,53380d13,650a7354,766a0abb,81c2c92e,92722c85"
	S LIST=LIST_",a2bfe8a1,a81a664b,c24b8b70,c76c51a3,d192e819,d6990624,f40e3585,106aa070"
	S LIST=LIST_",19a4c116,1e376c08,2748774c,34b0bcb5,391c0cb3,4ed8aa4a,5b9cca4f,682e6ff3"
	S LIST=LIST_",748f82ee,78a5636f,84c87814,8cc70208,90befffa,a4506ceb,bef9a3f7,c67178f2"
	F I=1:1:64 S ^MIO("MIOSHA256","K",I-1)=$$HEX2DEC($P(LIST,",",I))
	;
	S ^MIO("MIOSHA256","READY")=1
	Q
	;
U32(X) ;
	Q X#4294967296
	;
GET32(S,P) ;
	N B1,B2,B3,B4
	S B1=$A(S,P),B2=$A(S,P+1),B3=$A(S,P+2),B4=$A(S,P+3)
	Q ((((B1*256)+B2)*256+B3)*256)+B4
	;
BE32(N) ;
	N B1,B2,B3,B4
	S B1=(N\16777216)#256
	S B2=(N\65536)#256
	S B3=(N\256)#256
	S B4=N#256
	Q $C(B1,B2,B3,B4)
	;
ROTR(X,N) ;
	N LOW
	I N=0 Q $$U32(X)
	S LOW=X#^MIO("MIOSHA256","P2",N)
	Q $$U32((X\^MIO("MIOSHA256","P2",N))+(LOW*^MIO("MIOSHA256","P2",32-N)))
	;
SHR(X,N) ;
	Q X\^MIO("MIOSHA256","P2",N)
	;
XOR(X,Y) ;
	N A0,A1,A2,A3,B0,B1,B2,B3
	S A0=(X\16777216)#256,A1=(X\65536)#256,A2=(X\256)#256,A3=X#256
	S B0=(Y\16777216)#256,B1=(Y\65536)#256,B2=(Y\256)#256,B3=Y#256
	Q (^MIO("MIOSHA256","xor",A0,B0)*16777216)+(^MIO("MIOSHA256","xor",A1,B1)*65536)+(^MIO("MIOSHA256","xor",A2,B2)*256)+^MIO("MIOSHA256","xor",A3,B3)
	;
AND(X,Y) ;
	N A0,A1,A2,A3,B0,B1,B2,B3
	S A0=(X\16777216)#256,A1=(X\65536)#256,A2=(X\256)#256,A3=X#256
	S B0=(Y\16777216)#256,B1=(Y\65536)#256,B2=(Y\256)#256,B3=Y#256
	Q (^MIO("MIOSHA256","and",A0,B0)*16777216)+(^MIO("MIOSHA256","and",A1,B1)*65536)+(^MIO("MIOSHA256","and",A2,B2)*256)+^MIO("MIOSHA256","and",A3,B3)
	;
NOT32(X) ;
	Q 4294967295-X
	;
CH(X,Y,Z) ;
	Q $$XOR($$AND(X,Y),$$AND($$NOT32(X),Z))
	;
MAJ(X,Y,Z) ;
	Q $$XOR($$XOR($$AND(X,Y),$$AND(X,Z)),$$AND(Y,Z))
	;
BSIG0(X) ;
	Q $$XOR($$XOR($$ROTR(X,2),$$ROTR(X,13)),$$ROTR(X,22))
	;
BSIG1(X) ;
	Q $$XOR($$XOR($$ROTR(X,6),$$ROTR(X,11)),$$ROTR(X,25))
	;
SSIG0(X) ;
	Q $$XOR($$XOR($$ROTR(X,7),$$ROTR(X,18)),$$SHR(X,3))
	;
SSIG1(X) ;
	Q $$XOR($$XOR($$ROTR(X,17),$$ROTR(X,19)),$$SHR(X,10))
	;
XORB(A,B) ;
	N I,AA,BB,R,BIT
	S R=0
	F I=0:1:7 D
	. S BIT=^MIO("MIOSHA256","P2",I)
	. S AA=(A\BIT)#2
	. S BB=(B\BIT)#2
	. I AA'=BB S R=R+BIT
	Q R
	;
ANDB(A,B) ;
	N I,AA,BB,R,BIT
	S R=0
	F I=0:1:7 D
	. S BIT=^MIO("MIOSHA256","P2",I)
	. S AA=(A\BIT)#2
	. S BB=(B\BIT)#2
	. I AA,BB S R=R+BIT
	Q R
	;
HEX8(N) ;
	N H,I,R,D
	S H="0123456789abcdef",R=""
	F I=7:-1:0 D
	. S D=(N\(^MIO("MIOSHA256","P2",I*4)))#16
	. S R=R_$E(H,D+1)
	Q R
	;
HEX2DEC(H) ;
	N I,C,V,R
	S H=$$LOW($G(H)),R=0
	F I=1:1:$L(H) D
	. S C=$E(H,I)
	. S V=$F("0123456789abcdef",C)-2
	. I V<0 S V=0
	. S R=(R*16)+V
	Q R
	;
HEX2RAW(H) ;
	N I,R
	S H=$$LOW($TR($G(H)," ","")),R=""
	I $L(H)#2 S H="0"_H
	F I=1:2:$L(H) S R=R_$C($$HEX2DEC($E(H,I,I+1)))
	Q R
	;
RAW2HEX(BIN) ;
	N I,R
	S R=""
	F I=1:1:$L($G(BIN)) S R=R_$$HEX2($A(BIN,I))
	Q R
	;
HEX2(N) ;
	N H
	S H="0123456789abcdef"
	Q $E(H,(N\16)+1)_$E(H,(N#16)+1)
	;
LOW(S) ;
	N I,C,R
	S R=""
	F I=1:1:$L($G(S)) D
	. S C=$A(S,I)
	. I C>64,C<91 S R=R_$C(C+32) Q
	. S R=R_$E(S,I)
	Q R
	;
REPEAT(CH,N) ;
	N I,R
	S R=""
	F I=1:1:N S R=R_CH
	Q R
	;