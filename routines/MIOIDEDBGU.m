MIOIDEDBGU ; MIOIDE debugger utilities
	Q
	;
NEWID()
	N H1,H2
	S H1=$P($H,",",1),H2=$P($H,",",2)
	Q "DBG"_$J_"-"_H1_"-"_H2_"-"_$R(1000000)
	;
NOW()
	Q $H
	;
MAXLINE(TXT)
	N I,CNT
	S CNT=1
	I $G(TXT)="" Q 1
	F I=1:1:$L(TXT) I $A(TXT,I)=10 S CNT=CNT+1
	Q CNT
	;
TRIM(X)
	N Y
	S Y=$G(X)
	F  Q:$E(Y,1)'=" "  S Y=$E(Y,2,$L(Y))
	F  Q:$E(Y,$L(Y))'=" "  S Y=$E(Y,1,$L(Y)-1)
	Q Y
	;
JSONSTR(X)
	Q $$ENQ($G(X))
	;
ENQ(X)
	N Y
	S Y=$TR($G(X),""""_$C(13),"\\"" ")
	S Y=$TR(Y,$C(10)," ")
	Q Y
	;
FIELD(JSON,KEY)
	N LOW,POS,START,CH,OUT,STOP
	S LOW=$ZCONVERT($G(JSON),"L")
	S KEY=$ZCONVERT($G(KEY),"L")
	S POS=$F(LOW,""""_KEY_""":")
	I 'POS Q ""
	S START=POS
	F  Q:START>$L(JSON)  Q:$E(JSON,START)'=" "  S START=START+1
	I START>$L(JSON) Q ""
	S CH=$E(JSON,START)
	I CH="""" D  Q OUT
	. N I,ESC,C,STOP
	. S OUT="",ESC=0,STOP=0
	. F I=START+1:1:$L(JSON) S C=$E(JSON,I) D  Q:STOP
	. . I ESC S OUT=OUT_C,ESC=0 Q
	. . I C="""" S ESC=1 Q
	. . I C="""" S STOP=1 Q
	. . S OUT=OUT_C
	S OUT="",STOP=0
	F  Q:START>$L(JSON)  D  Q:STOP
	. S CH=$E(JSON,START)
	. S STOP=(CH=",")!(CH="}")!(CH="]")
	. I 'STOP S OUT=OUT_CH,START=START+1
	Q $$TRIM(OUT)
	;
NUM(X,DEF)
	N Y
	S Y=+$G(X)
	I Y=0,$G(X)'=0 Q +$G(DEF)
	Q Y
	;
SAFEEVAL(EXPR)
	S EXPR=$$TRIM($G(EXPR))
	I EXPR="$JOB" Q 1
	I EXPR="$HOROLOG" Q 1
	I $E(EXPR)="^",$$SAFEGL(EXPR) Q 1
	Q 0
	;
SAFEGL(EXPR)
	N I,C,OK
	S OK=1,EXPR=$G(EXPR)
	I EXPR="" Q 0
	I $E(EXPR)'="^" Q 0
	F I=2:1:$L(EXPR) S C=$E(EXPR,I) I C'?1A,C'?1N,C'?1P S OK=0 Q
	Q OK
	;
CMDOK(CMD)
	N X
	S X=$ZCONVERT($G(CMD),"L")
	I X="snap" Q 1
	I X="continue" Q 1
	I X="step_into" Q 1
	I X="step_over" Q 1
	I X="stop" Q 1
	I X="toggle_breakpoint" Q 1
	I X="watch_add" Q 1
	I X="watch_del" Q 1
	I X="eval" Q 1
	Q 0
	;
	;