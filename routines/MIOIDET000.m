MIOIDET000 ; MIOIDE shared test helpers
	Q
	;
EQ(FAIL,LABEL,GOT,EXP)
	I $G(GOT)=$G(EXP) Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
	Q
	;
HAS(FAIL,LABEL,TXT,TOKEN)
	I $G(TXT)[$G(TOKEN) Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": missing token=",$G(TOKEN)
	Q
	;
TRUE(FAIL,LABEL,VAL)
	I +$G(VAL)=1 Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": got=",+$G(VAL)," expected=1"
	Q
	;
FALSE(FAIL,LABEL,VAL)
	I '+$G(VAL) Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": got=",+$G(VAL)," expected=0"
	Q
	;
GE(FAIL,LABEL,GOT,MIN)
	I +$G(GOT)'<+$G(MIN) Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": got=",+$G(GOT)," expected>=",+$G(MIN)
	Q
	;
GT(FAIL,LABEL,GOT,MIN)
	I +$G(GOT)>+$G(MIN) Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": got=",+$G(GOT)," expected>",+$G(MIN)
	Q
	;
NODE(FAIL,LABEL,VAL)
	I +$G(VAL)>0 Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": node missing"
	Q
	;
RESETDBG()
	D RESET^MIOIDEDBG
	Q
	;
OLDTS(SEC)
	N T,D,S
	S T=$H
	S D=+$P(T,",",1),S=+$P(T,",",2)-+$G(SEC)
	F  Q:S'<0  S D=D-1,S=S+86400
	Q D_","_S
	;
