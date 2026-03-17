MIOUIT000 ; MIOUI shared test helpers
	Q
	;
EQ(FAIL,LABEL,GOT,EXP)
	I $G(GOT)=$G(EXP) Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
	Q
	;
TRUE(FAIL,LABEL,VAL)
	I +$G(VAL)=1 Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": got=",+$G(VAL)," expected=1"
	Q
	;
NOTEMPTY(FAIL,LABEL,VAL)
	I $G(VAL)'="" Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": value is empty"
	Q
	;
CONTAINS(FAIL,LABEL,TEXT,NEED)
	I $G(TEXT)[$G(NEED) Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": missing token=",$G(NEED)
	Q
HAS(FAIL,LABEL,TEXT,NEED)
	I $G(TEXT)[$G(NEED) Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": missing token=",$G(NEED)
	Q
	;
GE(FAIL,LABEL,GOT,EXP)
	I +$G(GOT)'<+$G(EXP) Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": got=",+$G(GOT)," expected>=",+$G(EXP)
	Q
	;
	;