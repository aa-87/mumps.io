MIOSHA256 ; Pure MUMPS SHA-256 / HMAC-SHA256
	;
	; Public entry points
	;   $$SHA256^MIOSHA256(DATA)          -> 64-char lowercase hex digest
	;   $$SHA256RAW^MIOSHA256(DATA)       -> 32 raw digest bytes
	;   $$SHA256REF^MIOSHA256(REF)        -> 64-char lowercase hex digest from ref root
	;   $$SHA256REFRAW^MIOSHA256(REF)     -> 32 raw digest bytes from ref root
	;   $$HMAC^MIOSHA256(KEY,DATA)        -> 64-char lowercase hex HMAC-SHA256
	;   $$HMACRAW^MIOSHA256(KEY,DATA)     -> 32 raw HMAC-SHA256 bytes
	;   $$HMACHEX^MIOSHA256(KEYHEX,DATA)  -> 64-char lowercase hex HMAC-SHA256, hex key input
	;   $$HEX2RAW^MIOSHA256(HEX)          -> raw bytes from hex
	;   $$RAW2HEX^MIOSHA256(BIN)          -> lowercase hex from raw bytes
	;
	; Notes
	; - Pure MUMPS implementation; no shell calls, no external libraries.
	; - Input strings are treated as byte strings.
	; - Streaming update/final flow avoids building one giant padded message copy.
	;
	Q
	;
SHA256(DATA) ;
	Q $$RAW2HEX($$SHA256RAW($G(DATA)))
	;
SHA256RAW(DATA) ;
	N CTX
	D CTXINIT(.CTX)
	D UPDATE($G(DATA),.CTX)
	Q $$FINAL(.CTX)
	;
SHA256REF(REF) ;
	Q $$RAW2HEX($$SHA256REFRAW($G(REF)))
	;
SHA256REFRAW(REF) ;
	N ROOT,PREFIX,NODE,CTX
	D CTXINIT(.CTX)
	S ROOT=$G(REF)
	I ROOT="" Q $$FINAL(.CTX)
	I $D(@ROOT)#10 D UPDATE($G(@ROOT),.CTX)
	S PREFIX=$$REFPFX(ROOT)
	S NODE=$Q(@ROOT)
	F  Q:NODE=""  Q:$E(NODE,1,$L(PREFIX))'=PREFIX  D  S NODE=$Q(@NODE)
	. I $D(@NODE)#10 D UPDATE($G(@NODE),.CTX)
	Q $$FINAL(.CTX)
	;
REFPFX(ROOT) ;
	N LAST
	S ROOT=$G(ROOT)
	I ROOT="" Q ""
	S LAST=$E(ROOT,$L(ROOT))
	I LAST=")",ROOT["(" Q $E(ROOT,1,$L(ROOT)-1)_","
	Q ROOT_"("
	;
HMAC(KEY,DATA) ;
	Q $$RAW2HEX($$HMACRAW($G(KEY),$G(DATA)))
	;
HMACRAW(KEY,DATA) ;
	N BKEY,IPAD,OPAD,I,B,INNER
	D INIT
	S BKEY=$G(KEY)
	I $L(BKEY)>64 S BKEY=$$SHA256RAW(BKEY)
	I $L(BKEY)<64 S BKEY=BKEY_$$REPEAT($C(0),64-$L(BKEY))
	S IPAD="",OPAD=""
	F I=1:1:64 D
	. S B=$A(BKEY,I)
	. S IPAD=IPAD_$C(^MIO("MIOSHA256","xor",B,54))
	. S OPAD=OPAD_$C(^MIO("MIOSHA256","xor",B,92))
	S INNER=$$SHA256RAW(IPAD_$G(DATA))
	Q $$SHA256RAW(OPAD_INNER)
	;
HMACHEX(KEYHEX,DATA) ;
	Q $$HMAC($$HEX2RAW($G(KEYHEX)),$G(DATA))
	;
CTXINIT(CTX) ;
	N I
	D INIT
	K CTX
	F I=0:1:7 S CTX("H",I)=^MIO("MIOSHA256","IV",I)
	F I=0:1:63 S CTX("K",I)=^MIO("MIOSHA256","K",I)
	S CTX("ML")=0
	S CTX("BUF")=""
	Q
	;
UPDATE(DATA,CTX) ;
	N WORK,WLEN,PROC,OFF
	S DATA=$G(DATA)
	I DATA="" Q
	S CTX("ML")=+$G(CTX("ML"))+$L(DATA)
	S WORK=$G(CTX("BUF"))_DATA
	S WLEN=$L(WORK),PROC=(WLEN\64)*64
	F OFF=1:64:PROC D COMPRESS($E(WORK,OFF,OFF+63),.CTX)
	S CTX("BUF")=$E(WORK,PROC+1,WLEN)
	Q
	;
FINAL(CTX) ;
	N BUF,ML,PAD,BITLEN,HI,LO,OFF
	S BUF=$G(CTX("BUF")),ML=+$G(CTX("ML"))
	S BUF=BUF_$C(128)
	S PAD=((56-((ML+1)#64))+64)#64
	I PAD>0 S BUF=BUF_$$REPEAT($C(0),PAD)
	S BITLEN=ML*8
	S HI=(BITLEN\4294967296)#4294967296
	S LO=BITLEN#4294967296
	S BUF=BUF_$$BE32(HI)_$$BE32(LO)
	F OFF=1:64:$L(BUF) D COMPRESS($E(BUF,OFF,OFF+63),.CTX)
	Q $$DIGESTRAW(.CTX)
	;
DIGESTRAW(CTX) ;
	N I,OUT
	S OUT=""
	F I=0:1:7 S OUT=OUT_$$BE32(+$G(CTX("H",I)))
	Q OUT
	;
COMPRESS(BLK,CTX) ;
	N T,W,A,B,C,D,E,F,G,H,T1,T2
	F T=0:1:15 S W(T)=$$GET32(BLK,(T*4)+1)
	F T=16:1:63 S W(T)=$$U32($$SSIG1(W(T-2))+W(T-7)+$$SSIG0(W(T-15))+W(T-16))
	S A=CTX("H",0),B=CTX("H",1),C=CTX("H",2),D=CTX("H",3)
	S E=CTX("H",4),F=CTX("H",5),G=CTX("H",6),H=CTX("H",7)
	F T=0:1:63 D
	. S T1=$$U32(H+$$BSIG1(E)+$$CH(E,F,G)+CTX("K",T)+W(T))
	. S T2=$$U32($$BSIG0(A)+$$MAJ(A,B,C))
	. S H=G,G=F,F=E,E=$$U32(D+T1),D=C,C=B,B=A,A=$$U32(T1+T2)
	S CTX("H",0)=$$U32(CTX("H",0)+A)
	S CTX("H",1)=$$U32(CTX("H",1)+B)
	S CTX("H",2)=$$U32(CTX("H",2)+C)
	S CTX("H",3)=$$U32(CTX("H",3)+D)
	S CTX("H",4)=$$U32(CTX("H",4)+E)
	S CTX("H",5)=$$U32(CTX("H",5)+F)
	S CTX("H",6)=$$U32(CTX("H",6)+G)
	S CTX("H",7)=$$U32(CTX("H",7)+H)
	Q
	;
	; =========================
	; Internal helpers
	; =========================
	;
INIT ;
	N A,B,I,LIST
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
	N R,UNIT
	S R="",UNIT=$G(CH),N=+$G(N)
	F  Q:N<1  D
	. I N#2 S R=R_UNIT
	. S N=N\2
	. I N>0 S UNIT=UNIT_UNIT
	Q R
	;
