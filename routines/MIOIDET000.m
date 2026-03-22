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
HASNOT(FAIL,LABEL,TXT,TOKEN)
	I $G(TXT)'[$G(TOKEN) Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": unexpected token=",$G(TOKEN)
	Q
	;
TRUE(FAIL,LABEL,VAL)
	I +$G(VAL)=1 Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": got=",+$G(VAL)," expected=1"
	Q
	;
FALSE(FAIL,LABEL,VAL)
	I +$G(VAL)=0 Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": got=",+$G(VAL)," expected=0"
	Q
	;
GT(FAIL,LABEL,GOT,MIN)
	I +$G(GOT)>+$G(MIN) Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": got=",+$G(GOT)," expected > ",+$G(MIN)
	Q
	;
GE(FAIL,LABEL,GOT,MIN)
	I +$G(GOT)'<+$G(MIN) Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": got=",+$G(GOT)," expected >= ",+$G(MIN)
	Q
	;
GE2(FAIL,LABEL,GOT,MIN)
	I +$G(GOT)'<+$G(MIN) Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": got=",+$G(GOT)," expected >= ",+$G(MIN)
	Q
	;
NODE(FAIL,LABEL,VAL)
	I +$G(VAL)>0 Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": expected node to exist"
	Q
	;
RESETIDE()
	K ^MIO("MIOIDE")
	K ^MIO("CONF","mioide","events","retain")
	D CLEARRT
	Q
	;
RESETDBG()
	I $T(RESET^MIOIDBG)'="" D RESET^MIOIDBG(1) Q
	K ^MIO("MIOIDE","DBG")
	K ^MIO("MIOIDE","EV")
	Q
	;
RESETWS()
	K ^MIO("MIOIDE","EV")
	K ^MIO("CONF","mioide","events","retain")
	Q
	;
CLEARRT()
	K ^MIO("ROUTE","RAW","GET","/mioide")
	K ^MIO("ROUTE","RAW","GET","/mioide/api/routines")
	K ^MIO("ROUTE","RAW","GET","/mioide/api/routines/:name/source")
	K ^MIO("ROUTE","RAW","PUT","/mioide/api/routines/:name/source")
	K ^MIO("ROUTE","RAW","POST","/mioide/api/routines/:name/compile")
	K ^MIO("ROUTE","RAW","POST","/mioide/api/routines/:name/run")
	K ^MIO("ROUTE","RAW","GET","/mioide/api/search")
	K ^MIO("ROUTE","RAW","GET","/mioide/api/snippets")
	K ^MIO("ROUTE","RAW","POST","/mioide/api/debug/sessions")
	K ^MIO("ROUTE","RAW","GET","/mioide/api/debug/sessions/:sid")
	K ^MIO("ROUTE","RAW","POST","/mioide/api/debug/sessions/:sid/command")
	K ^MIO("ROUTE","RAW","GET","/mioide/api/debug/routines/:name/breakpoints")
	K ^MIO("ROUTE","RAW","POST","/mioide/api/debug/routines/:name/breakpoints/:line/toggle")
	K ^MIO("ROUTE","RAW","POST","/mioide/api/debug/sessions/:sid/watches")
	K ^MIO("ROUTE","RAW","POST","/mioide/api/debug/sessions/:sid/watches/:idx/remove")
	K ^MIO("ROUTE","RAW","POST","/mioide/api/debug/sessions/:sid/eval")
	K ^MIO("ROUTE","RAW","WS","/mioide/ws/events")
	K ^MIO("ROUTE","RAW","WS","/mioide/ws/terminal")
	K ^MIO("ROUTE","META","GET","/mioide")
	K ^MIO("ROUTE","META","WS","/mioide/ws/events")
	K ^MIO("ROUTE","META","WS","/mioide/ws/terminal")
	Q
	;
MKFIX(CONF)
	N LF,T1,T2,T3,T4,T5,X,ERR
	S LF=$C(10)
	S T1="MIOIDXT1 ; ROI3A fixture one"_LF_" S X=1"_LF_" W ""ROI3A_ALPHA_UNIQUE"""_LF_" Q"
	S T2="MIOIDXT2 ; ROI3A fixture two"_LF_" S Y=2"_LF_" W ""BETA"""_LF_" Q"
	S T3="MIOIDXT3 ; ROI3A fixture three"_LF_" S Z=3"_LF_" W ""GAMMA ROI3A_ALPHA_UNIQUE"""_LF_" Q"
	S T4="ZZIDXT1 ; blocked run fixture"_LF_" W ""BLOCKED"""_LF_" Q"
	S T5="MIOIDXT9 ; multiline preserve"_LF_" S A=1"_LF_" W ""LINE2"""_LF_" Q"
	S X=$$SAVETEXT^MIOIDED("MIOIDXT1",T1,.CONF,.ERR)
	S X=$$SAVETEXT^MIOIDED("MIOIDXT2",T2,.CONF,.ERR)
	S X=$$SAVETEXT^MIOIDED("MIOIDXT3",T3,.CONF,.ERR)
	S X=$$SAVETEXT^MIOIDED("ZZIDXT1",T4,.CONF,.ERR)
	S X=$$SAVETEXT^MIOIDED("MIOIDXT9",T5,.CONF,.ERR)
	D MKLONG(.CONF)
	Q
	;
MKLONG(CONF)
	N LF,TXT,I,X,ERR
	S LF=$C(10)
	S TXT="MIOIDXL1 ; long fixture"
	F I=1:1:40 S TXT=TXT_LF_" W ""ROW"_I_"-ABCDEFGHIJKLMNOPQRSTUVWXYZ"""
	S TXT=TXT_LF_" Q"
	S X=$$SAVETEXT^MIOIDED("MIOIDXL1",TXT,.CONF,.ERR)
	Q
	;
