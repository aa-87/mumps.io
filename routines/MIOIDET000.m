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
GE(FAIL,LABEL,GOT,MIN)
	I +$G(GOT)'<+$G(MIN) Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": got=",+$G(GOT)," expected>=",+$G(MIN)
	Q
	;
RESETDBG()
	D RESET^MIOIDEDBG
	Q
	;
