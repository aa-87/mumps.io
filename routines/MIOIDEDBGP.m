MIOIDEDBGP ; MIOIDE debugger payload helpers
	Q
	;
PAYLOAD(BODY,CMD,ARG)
	N POS,KEY,VAL
	K ARG
	S CMD=""
	S ARG("expr")=""
	S POS=1
	D SKIP(.BODY,.POS)
	I $E($G(BODY),POS)="{" S POS=POS+1
	F  D  Q:POS>$L($G(BODY))
	. D SKIP(.BODY,.POS)
	. I POS>$L($G(BODY)) Q
	. I $E(BODY,POS)="}" S POS=POS+1 Q
	. S KEY=$$GETSTR(.BODY,.POS)
	. I KEY="" S POS=$L(BODY)+1 Q
	. D SKIP(.BODY,.POS)
	. I $E(BODY,POS)=":" S POS=POS+1
	. D SKIP(.BODY,.POS)
	. S VAL=$$GETVAL(.BODY,.POS)
	. D SETKV(.CMD,.ARG,KEY,VAL)
	. D SKIP(.BODY,.POS)
	. I $E(BODY,POS)="," S POS=POS+1 Q
	. I $E(BODY,POS)="}" S POS=POS+1 Q
	Q:$Q 1 Q
	;
SETKV(CMD,ARG,KEY,VAL)
	N K
	S K=$$LOW(KEY)
	I K="cmd" S CMD=VAL Q
	I K="line" S ARG("line")=+VAL Q
	S ARG(K)=VAL
	Q
	;
GETVAL(BODY,POS)
	N CH,OUT
	S CH=$E($G(BODY),POS)
	I CH="""" Q $$GETSTR(.BODY,.POS)
	S OUT=$$GETRAW(.BODY,.POS)
	I OUT="true" Q 1
	I OUT="false" Q 0
	I OUT="null" Q ""
	I OUT?1"-".N Q +OUT
	I OUT?.N Q +OUT
	Q OUT
	;
GETRAW(BODY,POS)
	N OUT,CH
	S OUT=""
	F  Q:POS>$L($G(BODY))  D  Q:CH=","!(CH="}")
	. S CH=$E(BODY,POS)
	. I CH=","!(CH="}") Q
	. S OUT=OUT_CH,POS=POS+1
	Q $$TRIM(OUT)
	;
GETSTR(BODY,POS)
	N OUT,CH,NXT
	S OUT=""
	I $E($G(BODY),POS)'="""" Q ""
	S POS=POS+1
	F  Q:POS>$L($G(BODY))  D  Q:CH=""""
	. S CH=$E(BODY,POS)
	. I CH="\\" D  Q
	. . S NXT=$E(BODY,POS+1)
	. . I NXT="\"" S OUT=OUT_"\"",POS=POS+2 Q
	. . I NXT="\\" S OUT=OUT_"\\",POS=POS+2 Q
	. . I NXT="/" S OUT=OUT_"/",POS=POS+2 Q
	. . I NXT="b" S OUT=OUT_$C(8),POS=POS+2 Q
	. . I NXT="f" S OUT=OUT_$C(12),POS=POS+2 Q
	. . I NXT="n" S OUT=OUT_$C(10),POS=POS+2 Q
	. . I NXT="r" S OUT=OUT_$C(13),POS=POS+2 Q
	. . I NXT="t" S OUT=OUT_$C(9),POS=POS+2 Q
	. . S OUT=OUT_NXT,POS=POS+2
	. I CH="""" S POS=POS+1 Q
	. S OUT=OUT_CH,POS=POS+1
	Q OUT
	;
SKIP(BODY,POS)
	N CH
	F  Q:POS>$L($G(BODY))  D  Q:CH'=" "&(CH'=$C(9))&(CH'=$C(10))&(CH'=$C(13))
	. S CH=$E(BODY,POS)
	. I CH=" "!(CH=$C(9))!(CH=$C(10))!(CH=$C(13)) S POS=POS+1 Q
	Q
	;
TRIM(X)
	N Y
	S Y=$G(X)
	F  Q:$E(Y,1)'=" "  S Y=$E(Y,2,$L(Y))
	F  Q:$E(Y,$L(Y))'=" "  S Y=$E(Y,1,$L(Y)-1)
	Q Y
	;
LOW(X)
	Q $ZCONVERT($G(X),"L")
	;
PUBLISH(SID,TYPE,CONF,DATA,JSON)
	N EVT,SEQ
	K EVT
	S SEQ=$$NEXTSEQ^MIOIDEDBGS(SID)
	S EVT("ok")=1
	S EVT("type")=$G(TYPE)
	S EVT("sid")=$G(SID)
	S EVT("seq")=SEQ
	S EVT("ts")=$H
	M EVT("session")=DATA
	S JSON=$$EN^MIOJSON1(.EVT)
	D STOREEVT^MIOIDEDBGS(SID,SEQ,$G(TYPE),JSON,.CONF)
	Q
	;
ERRJSON(SID,CODE,MSG)
	N EVT
	S EVT("ok")=0,EVT("sid")=$G(SID),EVT("error")=$G(CODE),EVT("message")=$G(MSG),EVT("ts")=$H
	Q $$EN^MIOJSON1(.EVT)
	;