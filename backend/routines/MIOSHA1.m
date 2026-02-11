MIOWSSHA ; MIO WebSocket SHA1 + Accept helper (MUMPS Implementation)
	; AA 1/20/26
	; V 1.0
	;#################################################################
	;#                                                               #
	;# Copyright (c) 2025 Ahmed Khaled Abdelrazek                    #
	;# All rights reserved.                                          #
	;#                                                               #
	;#   This source code contains the intellectual property         #
	;#   of its copyright holder(s), and is made available           #
	;#   under a license.  If you do not know the terms of           #
	;#   the license, please stop and do not read further.           #
	;#                                                               #
	;#################################################################
	; Public:
	;   $$SHA1HEX(text)  -> 40 hex chars
	;   $$SHA1RAW(text)  -> 20-byte binary string
	;   $$WSACCEPT(secKey) -> Sec-WebSocket-Accept header value
	;
SELFTEST
	N $ET S $ET="G ETSOCK^MIOWS"
	S %WTCP=""
	N secKey,expect,got
	S secKey="dGhlIHNhbXBsZSBub25jZQ=="
	S expect="s3pPLMBiTxaQ9kYGzzhZRbK+xOo="
	S got=$$WSACCEPT(secKey)
	W !,"Expected: ",expect,!
	W "Got     : ",got,!
	W "PASS?   : ",$S(got=expect:"YES",1:"NO"),!
	Q
SELFTEST2
	N secKey,expect,got
	S secKey="dGhlIHNhbXBsZSBub25jZQ=="
	S expect="s3pPLMBiTxaQ9kYGzzhZRbK+xOo="
	S got=$$GENWS^MIOWS(secKey)
	W !,"Expected: ",expect,!
	W "Got     : ",got,!
	W "PASS?   : ",$S(got=expect:"YES",1:"NO"),!
	Q
WSACCEPT(secKey) ;
	N guid S guid="258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
	Q $$B64ENC($$SHA1RAW(secKey_guid))
SHA1HEX(msg) ;
	N raw S raw=$$SHA1RAW(msg)
	Q $$BIN2HEX(raw)
SHA1RAW(msg) ;
	N h0,h1,h2,h3,h4
	N mlBits,bytes,rem,padLen,blk,msg2,off
	N w,i,a,b,c,d,e,f,k,temp
	S h0=$$U32(1732584193)   ; 0x67452301
	S h1=$$U32(4023233417)   ; 0xEFCDAB89
	S h2=$$U32(2562383102)   ; 0x98BADCFE
	S h3=$$U32(271733878)    ; 0x10325476
	S h4=$$U32(3285377520)   ; 0xC3D2E1F0
	S bytes=$L(msg)
	S mlBits=$$U32(bytes*8)
	N mlHi ;S mlHi=$$U32((bytes\536870912))
	S mlHi=0,mlBits=$$U32(bytes*8)
	S rem=(bytes+1)#64
	S padLen=$S(rem'>56:56-rem,1:56+64-rem)
	S msg2=msg_$$ZCH(128)
	F i=1:1:padLen S msg2=msg2_$$ZCH(0)
	S msg2=msg2_$$U32BE(mlHi)_$$U32BE(mlBits)
	F off=1:64:$L(msg2) D
	. S blk=$E(msg2,off,off+63)
	. K w
	. F i=0:1:15 S w(i)=$$U32($$BE32(blk,(i*4)+1))
	. F i=16:1:79 S w(i)=$$ROTL($$XOR4(w(i-3),w(i-8),w(i-14),w(i-16)),1)
	. S a=h0,b=h1,c=h2,d=h3,e=h4
	. F i=0:1:79 D
	. . I i<20 S f=$$OR($$AND(b,c),$$AND($$NOT(b),d)),k=$$U32(1518500249)  
	. . E  I i<40 S f=$$XOR3(b,c,d),k=$$U32(1859775393)                
	. . E  I i<60 S f=$$OR3($$AND(b,c),$$AND(b,d),$$AND(c,d)),k=$$U32(2400959708)
	. . E  S f=$$XOR3(b,c,d),k=$$U32(3395469782)                        
	. . S temp=$$ADD5($$ROTL(a,5),f,e,k,w(i))
	. . S e=d,d=c,c=$$ROTL(b,30),b=a,a=temp
	. S h0=$$ADD(h0,a),h1=$$ADD(h1,b),h2=$$ADD(h2,c),h3=$$ADD(h3,d),h4=$$ADD(h4,e)
	Q $$U32BE(h0)_$$U32BE(h1)_$$U32BE(h2)_$$U32BE(h3)_$$U32BE(h4)
ZCH(n) Q $ZCHAR(n)
ZAS(c) Q $ZASCII(c)
BE32(s,pos)
	N b1,b2,b3,b4
	S b1=$$ZAS($E(s,pos)),b2=$$ZAS($E(s,pos+1)),b3=$$ZAS($E(s,pos+2)),b4=$$ZAS($E(s,pos+3))
	Q $$U32((b1*16777216)+(b2*65536)+(b3*256)+b4)
U32BE(x) ;
	N b1,b2,b3,b4,n
	S n=$$U32(x)
	S b1=(n\16777216)#256
	S b2=(n\65536)#256
	S b3=(n\256)#256
	S b4=n#256
	Q $$ZCH(b1)_$$ZCH(b2)_$$ZCH(b3)_$$ZCH(b4)
BIN2HEX(bin) ;
	N out,i,b,hex
	S hex="0123456789abcdef",out=""
	F i=1:1:$L(bin) D
	. S b=$$ZAS($E(bin,i))
	. S out=out_$E(hex,(b\16)+1)_$E(hex,(b#16)+1)
	Q out
U32(x) 
	N y S y=x#4294967296
	I y<0 S y=y+4294967296
	Q y
ADD(x,y) Q $$U32(x+y)
ADD5(a,b,c,d,e) Q $$U32(a+b+c+d+e)
XOR3(a,b,c) Q $$XOR2($$XOR2(a,b),c)
XOR4(a,b,c,d) Q $$XOR2($$XOR2($$XOR2(a,b),c),d)
OR3(a,b,c) Q $$OR($$OR(a,b),c)
POW2(n)
	N t S t="1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,"
	s t=t_"16384,32768,65536,131072,262144,524288,1048576,2097152,"
	s t=t_"4194304,8388608,16777216,33554432,67108864,134217728,"
	s t=t_"268435456,536870912,1073741824,2147483648"
	Q +$P(t,",",n+1)
BIT(x,i)
	N p S p=$$POW2(i)
	Q ((x\p)#2)
AND(x,y)
	N r,i S x=$$U32(x),y=$$U32(y),r=0
	F i=0:1:31 I $$BIT(x,i),$$BIT(y,i) S r=r+$$POW2(i)
	Q $$U32(r)
OR(x,y)
	N r,i,bx,by S x=$$U32(x),y=$$U32(y),r=0
	F i=0:1:31 D
	. S bx=$$BIT(x,i),by=$$BIT(y,i)
	. I (bx!by) S r=r+$$POW2(i)
	Q $$U32(r)
XOR2(x,y)
	N r,i,bx,by S x=$$U32(x),y=$$U32(y),r=0
	F i=0:1:31 D
	. S bx=$$BIT(x,i),by=$$BIT(y,i)
	. I (bx+by)=1 S r=r+$$POW2(i)
	Q $$U32(r)
NOT(x)
	Q $$U32(4294967295-$$U32(x))
ROTL(x,n)
	N v,nn,r,i,src
	S v=$$U32(x),nn=n#32
	I nn=0 Q v
	S r=0
	F i=0:1:31 D
	. S src=i-nn
	. I src<0 S src=src+32
	. I $$BIT(v,src) S r=r+$$POW2(i)
	Q $$U32(r)
B64ENC(bin)
	N tbl,out,i,len,b1,b2,b3,pad,c1,c2,c3,c4
	S tbl="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	S out="",len=$L(bin)
	F i=1:3:len D
	. S b1=$$ZAS($E(bin,i))
	. S b2=$S(i+1'>len:$$ZAS($E(bin,i+1)),1:-1)
	. S b3=$S(i+2'>len:$$ZAS($E(bin,i+2)),1:-1)
	. I b2=-1 S pad=2,b2=0,b3=0
	. E  I b3=-1 S pad=1,b3=0
	. E  S pad=0
	. S c1=$E(tbl,(b1\4)+1)
	. S c2=$E(tbl,(((b1#4)*16)+(b2\16))+1)
	. S c3=$S(pad=2:"=",1:$E(tbl,(((b2#16)*4)+(b3\64))+1))
	. S c4=$S(pad>0:"=",1:$E(tbl,(b3#64)+1))
	. S out=out_c1_c2_c3_c4
	Q out