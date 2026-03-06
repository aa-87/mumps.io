MIOSJWT ; JWT HS256 helpers built on MIOSHA256
	;
	; Public entry points
	;
	;   $$B64URLE^MIOSJWT(RAW)                      -> Base64URL encoded string
	;   $$B64URLD^MIOSJWT(TXT)                      -> raw decoded bytes
	;   $$SIGNHS256^MIOSJWT(INPUT,SECRET)           -> Base64URL(signature)
	;   $$MAKEHS256^MIOSJWT(PAYJSON,SECRET)         -> JWT using default HS256 header
	;   $$MAKEJWT^MIOSJWT(HDRJSON,PAYJSON,SECRET)   -> JWT from explicit header/payload JSON
	;   $$VERIFYHS256^MIOSJWT(TOKEN,SECRET,.OUT)    -> 1/0, OUT(...) populated
	;   $$SPLIT^MIOSJWT(TOKEN,.OUT)                 -> 1/0
	;   $$NOW^MIOSJWT()                             -> current unix epoch seconds (local->$H based)
	;   $$VALIDATE^MIOSJWT(.PAYLOAD,.ERR)           -> validates exp/nbf/iat if present
	;
	; OUT from VERIFYHS256:
	;   OUT("ok")=1|0
	;   OUT("err")=""
	;   OUT("signingInput")=<header64.payload64>
	;   OUT("header64")=<...>
	;   OUT("payload64")=<...>
	;   OUT("sig64")=<...>
	;   OUT("header")=<decoded json text>
	;   OUT("payload")=<decoded json text>
	;   OUT("sigCalc")=<computed base64url sig>
	;
	; Notes
	; - Pure MUMPS, no external libs.;
	; - JSON is treated as opaque text except optional exp/nbf/iat extraction.;
	; - Claim extraction is intentionally lightweight and expects numeric JSON values.;
	;
	Q
	;
	; =========================
	; High-level JWT helpers
	; =========================
	;
MAKEHS256(PAYJSON,SECRET) ;
	Q $$MAKEJWT("{""alg"":""HS256"",""typ"":""JWT""}",$G(PAYJSON),$G(SECRET))
	;
MAKEJWT(HDRJSON,PAYJSON,SECRET) ;
	N H64,P64,INPUT,S64
	S H64=$$B64URLE($G(HDRJSON))
	S P64=$$B64URLE($G(PAYJSON))
	S INPUT=H64_"."_P64
	S S64=$$SIGNHS256(INPUT,$G(SECRET))
	Q INPUT_"."_S64
	;
SIGNHS256(INPUT,SECRET) ;
	N HEX,RAW
	S HEX=$$HMAC^MIOSHA256($G(SECRET),$G(INPUT))
	S RAW=$$HEX2RAW^MIOSHA256(HEX)
	Q $$B64URLE(RAW)
	;
VERIFYHS256(TOKEN,SECRET,OUT) ;
	N OK,ERR
	K OUT
	S OUT("ok")=0,OUT("err")=""
	;
	S OK=$$SPLIT($G(TOKEN),.OUT)
	I 'OK S OUT("err")="token_format" Q 0
	;
	S OUT("header")=$$B64URLD(OUT("header64"))
	S OUT("payload")=$$B64URLD(OUT("payload64"))
	S OUT("signingInput")=OUT("header64")_"."_OUT("payload64")
	S OUT("sigCalc")=$$SIGNHS256(OUT("signingInput"),$G(SECRET))
	;
	I OUT("sig64")'=OUT("sigCalc") S OUT("err")="bad_signature" Q 0
	;
	I $$HASHS256HDR(OUT("header"))=0 S OUT("err")="alg_not_hs256" Q 0
	;
	N T M T=OUT("claims")
	S OK=$$PARSECLAIMS(OUT("payload"),.T)
	K OUT("claims") M OUT("claims")=T
	I 'OK S OUT("err")="claims_parse" Q 0
	K T M T=OUT("claims")
	S OK=$$VALIDATE(.T,.ERR) 
	K OUT("claims") M OUT("claims")=T
	I 'OK S OUT("err")=ERR Q 0
	;
	S OUT("ok")=1
	Q 1
	;
SPLIT(TOKEN,OUT) ;
	N P1,P2,P3
	K OUT
	S P1=$P($G(TOKEN),".",1)
	S P2=$P($G(TOKEN),".",2)
	S P3=$P($G(TOKEN),".",3)
	I P1=""!(P2="")!(P3="") Q 0
	I $L(TOKEN,".")'=3 Q 0
	S OUT("header64")=P1
	S OUT("payload64")=P2
	S OUT("sig64")=P3
	Q 1
	;
VALIDATE(PAYLOAD,ERR) ;
	N NOW,EXP,NBF,IAT
	S ERR=""
	S NOW=$$NOW()
	;
	S EXP=+$G(PAYLOAD("exp"))
	I EXP>0,EXP<NOW S ERR="token_expired" Q 0
	;
	S NBF=+$G(PAYLOAD("nbf"))
	I NBF>0,NBF>NOW S ERR="token_not_yet_valid" Q 0
	;
	S IAT=+$G(PAYLOAD("iat"))
	I IAT>0,IAT>(NOW+300) S ERR="token_issued_in_future" Q 0
	;
	Q 1
	;
	; =========================
	; Time helpers
	; =========================
	;
NOW() ;
	; Unix epoch seconds from $H
	; $H days are since 1840-12-31, unix epoch begins 1970-01-01
	Q (($P($H,",",1)-47117)*86400)+$P($H,",",2)
	;
	; =========================
	; JSON/light parsing helpers
	; =========================
	;
HASHS256HDR(JSON) ;
	N S
	S S=$$NOSP($G(JSON))
	I S["""alg"":""HS256""" Q 1
	Q 0
	;
PARSECLAIMS(JSON,OUT) ;
	; Lightweight extraction for numeric claims only: exp,nbf,iat
	; Leaves other claims untouched; verification can still succeed if absent.;
	K OUT
	S OUT("exp")=$$JSONNUM($G(JSON),"exp")
	S OUT("nbf")=$$JSONNUM($G(JSON),"nbf")
	S OUT("iat")=$$JSONNUM($G(JSON),"iat")
	Q 1
	;
JSONNUM(JSON,KEY) ;
	N S,P,C,I,N,CH
	S S=$G(JSON)
	S P=$F(S,""""_KEY_""":")
	I 'P Q ""
	;
	; skip whitespace
	F I=P:1:$L(S) Q:$E(S,I)'?1P&($E(S,I)'=" ")
	; the above is too broad on some implementations, so do an explicit pass below
	S I=P
	F  Q:I>$L(S)  S CH=$E(S,I) Q:(CH'=" ")&(CH'=$C(9))&(CH'=$C(10))&(CH'=$C(13))  S I=I+1
	;
	S N=""
	I $E(S,I)="-" S N="-",I=I+1
	F  Q:I>$L(S)  S CH=$E(S,I) Q:CH'?1N  S N=N_CH,I=I+1
	I N=""!(N="-") Q ""
	Q +N
	;
NOSP(S) ;
	N I,R,C
	S R=""
	F I=1:1:$L($G(S)) S C=$E(S,I) I C'=" ",C'=$C(9),C'=$C(10),C'=$C(13) S R=R_C
	Q R
	;
	; =========================
	; Base64URL
	; =========================
	;
B64URLE(RAW) ;
	N B64
	S B64=$$B64E($G(RAW))
	S B64=$TR(B64,"+/","-_")
	F  Q:$E(B64,$L(B64))'="="  S B64=$E(B64,1,$L(B64)-1)
	Q B64
	;
B64URLD(TXT) ;
	N S,M
	S S=$TR($G(TXT),"-_","+/")
	S M=$L(S)#4
	I M=2 S S=S_"=="
	I M=3 S S=S_"="
	I M=1 Q ""
	Q $$B64D(S)
	;
B64E(RAW) ;
	N TBL,L,I,B1,B2,B3,N1,N2,N3,N4,OUT
	S TBL="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	S OUT="",L=$L($G(RAW))
	F I=1:3:L D
	. S B1=$A(RAW,I)
	. S B2=$A(RAW,I+1)
	. S B3=$A(RAW,I+2)
	. I I+1>L D  Q
	. . S N1=B1\4
	. . S N2=((B1#4)*16)
	. . S OUT=OUT_$E(TBL,N1+1)_$E(TBL,N2+1)_"=="
	. I I+2>L D  Q
	. . S N1=B1\4
	. . S N2=((B1#4)*16)+(B2\16)
	. . S N3=((B2#16)*4)
	. . S OUT=OUT_$E(TBL,N1+1)_$E(TBL,N2+1)_$E(TBL,N3+1)_"="
	. S N1=B1\4
	. S N2=((B1#4)*16)+(B2\16)
	. S N3=((B2#16)*4)+(B3\64)
	. S N4=B3#64
	. S OUT=OUT_$E(TBL,N1+1)_$E(TBL,N2+1)_$E(TBL,N3+1)_$E(TBL,N4+1)
	Q OUT
	;
B64D(TXT) ;
	N OUT,TBL,I,C1,C2,C3,C4,V1,V2,V3,V4,B1,B2,B3
	S TBL="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	S OUT=""
	F I=1:4:$L($G(TXT)) D
	. S C1=$E(TXT,I),C2=$E(TXT,I+1),C3=$E(TXT,I+2),C4=$E(TXT,I+3)
	. S V1=$$B64VAL(C1,TBL),V2=$$B64VAL(C2,TBL)
	. I (V1<0)!(V2<0) Q
	. S B1=(V1*4)+(V2\16)
	. S OUT=OUT_$C(B1)
	. I C3="=" Q
	. S V3=$$B64VAL(C3,TBL) I V3<0 Q
	. S B2=((V2#16)*16)+(V3\4)
	. S OUT=OUT_$C(B2)
	. I C4="=" Q
	. S V4=$$B64VAL(C4,TBL) I V4<0 Q
	. S B3=((V3#4)*64)+V4
	. S OUT=OUT_$C(B3)
	Q OUT
	;
B64VAL(C,TBL) ;
	I C="" Q -1
	Q $F(TBL,C)-2
	;
	; =========================
	; Convenience JSON helpers
	; =========================
	;
DEFHDR() ;
	Q "{""alg"":""HS256"",""typ"":""JWT""}"
	;
PAYLOAD(SUB,NAME,ROLE,EXP,IAT,NBF) ;
	; convenience helper for simple payload assembly
	; numeric claims included only if >0
	N S,SEP
	S S="{",SEP=""
	I $G(SUB)'="" S S=S_"""sub"":"""_$$JESC(SUB)_"""",SEP=","
	I $G(NAME)'="" S S=S_SEP_"""name"":"""_$$JESC(NAME)_"""",SEP=","
	I $G(ROLE)'="" S S=S_SEP_"""role"":"""_$$JESC(ROLE)_"""",SEP=","
	I +$G(EXP)>0 S S=S_SEP_"""exp"":"_(+EXP),SEP=","
	I +$G(IAT)>0 S S=S_SEP_"""iat"":"_(+IAT),SEP=","
	I +$G(NBF)>0 S S=S_SEP_"""nbf"":"_(+NBF),SEP=","
	S S=S_"}"
	Q S
	;
JESC(S) ;
	N I,C,R,A
	S R=""
	F I=1:1:$L($G(S)) D
	. S C=$E(S,I),A=$A(C)
	. I C="\" S R=R_"\\"
	. E  I C="""" S R=R_"\"""
	. E  I A=8 S R=R_"\b"
	. E  I A=9 S R=R_"\t"
	. E  I A=10 S R=R_"\n"
	. E  I A=12 S R=R_"\f"
	. E  I A=13 S R=R_"\r"
	. E  S R=R_C
	Q R
	;