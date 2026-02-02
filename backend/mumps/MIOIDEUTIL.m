MIOIDEUTIL ; MIO IDE - shared utilities (time, ids, strings)
 ;
 ; Copyright (c) MUMPS.IO
 ; SPDX-License-Identifier: MIT
 ;
 ; This routine contains small, dependency-free helpers used by the
 ; WebSocket RPC layer and language services.
 ;
 Q
 ;
NOWISO() ; -> ISO-8601-ish timestamp (UTC preferred if supported)
 ; Returns: YYYY-MM-DDTHH:MM:SSZ  (or local time if UTC not available)
 N y,m,d,hh,mm,ss,z
 ; Prefer $ZTIMESTAMP if available (YottaDB)
 I $T($ZTIMESTAMP)'="" Q $$ZTSISO()
 ; Fallback: $H
 D H2DT($H,.y,.m,.d,.hh,.mm,.ss)
 S z="Z"
 Q $$PAD(y,4)_"-"_$$PAD(m,2)_"-"_$$PAD(d,2)_"T"_$$PAD(hh,2)_":"_$$PAD(mm,2)_":"_$$PAD(ss,2)_z
 ;
ZTSISO() ;
 ; YottaDB: $ZTIMESTAMP can render various formats; keep it simple.
 N ts S ts=$ZTIMESTAMP
 Q ts
 ;
UUID() ; -> 32 hex chars (best-effort, not cryptographic)
 ; Uses $R; good enough for session ids and request correlation.
 N i,s
 S s=""
 F i=1:1:32 S s=s_$$HEX($R(16))
 Q s
 ;
HEX(n) ; 0..15 -> "0".."f"
 Q $E("0123456789abcdef",n+1)
 ;
PAD(n,w) ; left pad integer n with zeros to width w
 N s S s=$TR($J(n,0)," ","")
 Q $E($TR($J("",w-$L(s))," ","0"),1,(w-$L(s)))_s
 ;
H2DT(h,y,m,d,hh,mm,ss) ; $H -> date/time parts (local)
 ; Minimal conversion without timezone correctness; good for logs.
 N days,secs,a,b,c,dd,e,f
 S days=+$P(h,",",1),secs=+$P(h,",",2)
 S hh=secs\3600,mm=(secs#3600)\60,ss=secs#60
 ; Convert Mumps days since 1840-12-31 to Gregorian date.
 ; days0 is days since 0000-03-01
 N z S z=days+672411  ; constant adjusts to 0000-03-01
 S a=z+32044
 S b=(4*a+3)\146097
 S c=a-(146097*b)\4
 S dd=(4*c+3)\1461
 S e=c-(1461*dd)\4
 S f=(5*e+2)\153
 S d=e-(153*f+2)\5+1
 S m=f+3-12*(f\10)
 S y=100*b+dd-4800+(f\10)
 Q
 ;
SAFESTR(s) ; escape for JSON string value (no surrounding quotes)
 ; Minimal JSON escaping: backslash, quote, control chars.
 N out,i,ch,asc
 S out=""
 F i=1:1:$L(s) S ch=$E(s,i) D
 . I ch="\" S out=out_"\\" Q
 . I ch="""" S out=out_"\\"" Q
 . S asc=$A(ch)
 . I asc<32 S out=out_"\u"_$$HEX4(asc) Q
 . S out=out_ch
 Q out
 ;
HEX4(n) ; 0..65535 -> 4 hex chars
 N a,b,c,d
 S a=n\4096,b=(n#4096)\256,c=(n#256)\16,d=n#16
 Q $$HEX(a)_$$HEX(b)_$$HEX(c)_$$HEX(d)
