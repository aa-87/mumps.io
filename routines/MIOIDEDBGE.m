MIOIDEDBGE ; MIOIDE debugger engine with hardened state handling
	Q
	;
START(SID,CONF,RES)
	Q $$SNAP(SID,.CONF,.RES)
	;
CMD(SID,CMD,ARG,CONF,RES)
	N RTN,LINE,MAX,NXT,STS
	K RES
	I '$$EXISTS^MIOIDEDBGS($G(SID)) S RES("ok")=0,RES("error")="missing_session" Q 0
	D TOUCH^MIOIDEDBGS(SID)
	S CMD=$ZCONVERT($G(CMD),"L")
	S STS=$$GET^MIOIDEDBGS(SID,"status")
	I CMD="snap" Q $$SNAP(SID,.CONF,.RES)
	I CMD="stop" D  Q $$SNAP(SID,.CONF,.RES)
	. D SETSTAT^MIOIDEDBGS(SID,"terminated","stopped")
	I STS="terminated"!(STS="faulted") S RES("ok")=0,RES("error")="session_closed",RES("status")=STS Q 0
	S RTN=$$GET^MIOIDEDBGS(SID,"routine")
	S LINE=+$$GET^MIOIDEDBGS(SID,"line")
	S MAX=+$$GET^MIOIDEDBGS(SID,"maxline") I MAX<1 S MAX=1
	I CMD="step_into"!(CMD="step_over") D  Q $$SNAP(SID,.CONF,.RES)
	. D SETSTAT^MIOIDEDBGS(SID,"stepping",CMD)
	. S NXT=$S(LINE<MAX:LINE+1,1:MAX)
	. D SET^MIOIDEDBGS(SID,"line",NXT)
	. I LINE'<MAX D SETSTAT^MIOIDEDBGS(SID,"terminated","end_of_routine") Q
	. D SETSTAT^MIOIDEDBGS(SID,"paused",$S(CMD="step_into":"step_into",1:"step_over"))
	I CMD="continue" D  Q $$SNAP(SID,.CONF,.RES)
	. D SETSTAT^MIOIDEDBGS(SID,"running","continue")
	. S NXT=$$NEXTBP(SID,RTN,LINE,MAX)
	. I NXT>0 D  Q
	. . D SET^MIOIDEDBGS(SID,"line",NXT)
	. . D SETSTAT^MIOIDEDBGS(SID,"paused","breakpoint")
	. D SET^MIOIDEDBGS(SID,"line",MAX)
	. D SETSTAT^MIOIDEDBGS(SID,"terminated","end_of_routine")
	S RES("ok")=0,RES("error")="invalid_command"
	Q 0
	;
TOGBP(SID,RTN,LINE,CONF,RES)
	N ON,LIMIT,CNT,BP
	K RES
	I '$$EXISTS^MIOIDEDBGS($G(SID)) S RES("ok")=0,RES("error")="missing_session" Q 0
	I '$$ISRTN^MIOIDED($G(RTN)) S RES("ok")=0,RES("error")="invalid_routine" Q 0
	I +$G(LINE)<1 S RES("ok")=0,RES("error")="invalid_line" Q 0
	S LIMIT=+$G(CONF("mioide","debug","breakpointLimit"),256)
	D BPARY^MIOIDEDBGS(SID,.BP)
	S CNT=0 F  S CNT=$O(BP(CNT)) Q:'CNT
	I '$$HASBP^MIOIDEDBGS(SID,RTN,+LINE),CNT'<LIMIT S RES("ok")=0,RES("error")="breakpoint_limit" Q 0
	S ON='$$HASBP^MIOIDEDBGS(SID,RTN,+LINE)
	D SETBP^MIOIDEDBGS(SID,RTN,+LINE,ON)
	D TOUCH^MIOIDEDBGS(SID)
	S RES("ok")=1,RES("enabled")=ON,RES("routine")=RTN,RES("line")=+LINE
	Q 1
	;
ADDWATCH(SID,EXPR,CONF,RES)
	N IDX
	K RES
	I '$$EXISTS^MIOIDEDBGS($G(SID)) S RES("ok")=0,RES("error")="missing_session" Q 0
	S EXPR=$G(EXPR)
	I EXPR="" S RES("ok")=0,RES("error")="missing_expr" Q 0
	S IDX=$$ADDWATCH^MIOIDEDBGS(SID,EXPR)
	D TOUCH^MIOIDEDBGS(SID)
	S RES("ok")=1,RES("idx")=IDX,RES("expr")=EXPR
	Q 1
	;
DELWATCH(SID,EXPR,CONF,RES)
	N IDX
	K RES
	I '$$EXISTS^MIOIDEDBGS($G(SID)) S RES("ok")=0,RES("error")="missing_session" Q 0
	S IDX=$$DELWATCH^MIOIDEDBGS(SID,$G(EXPR))
	D TOUCH^MIOIDEDBGS(SID)
	S RES("ok")=$S(IDX>0:1,1:0)
	S RES("idx")=IDX,RES("expr")=$G(EXPR)
	I 'IDX S RES("error")="watch_not_found"
	Q IDX>0
	;
EVAL(SID,EXPR,CONF,RES)
	N VAL,ERR
	K RES
	I '$$EXISTS^MIOIDEDBGS($G(SID)) S RES("ok")=0,RES("error")="missing_session" Q 0
	I '$$SAFEEVAL^MIOIDEDBGU($G(EXPR)) S RES("ok")=0,RES("error")="expr_not_allowed" Q 0
	D EVALEXPR($G(EXPR),.VAL,.ERR)
	I $D(ERR) S RES("ok")=0 M RES=ERR Q 0
	D TOUCH^MIOIDEDBGS(SID)
	S RES("ok")=1,RES("expr")=$G(EXPR),RES("value")=VAL
	Q 1
	;
SNAP(SID,CONF,RES)
	N RTN,ENTRY,LINE,MAX,STS,WHY,BP,W,I,VAL,ERR,TXT
	K RES
	I '$$EXISTS^MIOIDEDBGS($G(SID)) S RES("ok")=0,RES("error")="missing_session" Q:$Q 0 Q
	D TOUCH^MIOIDEDBGS(SID)
	S RES("ok")=1
	S RES("sid")=SID
	S RES("client")=$$GET^MIOIDEDBGS(SID,"client")
	S RTN=$$GET^MIOIDEDBGS(SID,"routine")
	S ENTRY=$$GET^MIOIDEDBGS(SID,"entry")
	S LINE=+$$GET^MIOIDEDBGS(SID,"line")
	S MAX=+$$GET^MIOIDEDBGS(SID,"maxline")
	S STS=$$GET^MIOIDEDBGS(SID,"status")
	S WHY=$$GET^MIOIDEDBGS(SID,"reason")
	S RES("routine")=RTN,RES("entry")=ENTRY,RES("line")=LINE,RES("maxline")=MAX
	S RES("status")=STS,RES("reason")=WHY
	S RES("seq")=+$$GET^MIOIDEDBGS(SID,"seq")
	S RES("cmdSeq")=+$$GET^MIOIDEDBGS(SID,"cmdSeq")
	S RES("createdTs")=$G(^MIO("MIOIDE","DBG","SESSION",SID,"createdTs"))
	S RES("updatedTs")=$G(^MIO("MIOIDE","DBG","SESSION",SID,"updatedTs"))
	S RES("lastSeenTs")=$G(^MIO("MIOIDE","DBG","SESSION",SID,"lastSeenTs"))
	S RES("eventCount")=$$EVCOUNT^MIOIDEDBGS(SID)
	S RES("cmdCount")=$$CMDCOUNT^MIOIDEDBGS(SID)
	S RES("frame",1,"routine")=RTN
	S RES("frame",1,"line")=LINE
	S RES("frame",1,"entry")=ENTRY
	D GETLINE(RTN,LINE,.CONF,.TXT)
	S RES("currentText")=$G(TXT)
	D BPARY^MIOIDEDBGS(SID,.BP) M RES("breakpoint")=BP
	D WATCHARY^MIOIDEDBGS(SID,.W)
	S I=0
	F  S I=$O(W(I)) Q:'I  D
	. S RES("watch",I,"expr")=$G(W(I,"expr"))
	. D EVALEXPR($G(W(I,"expr")),.VAL,.ERR)
	. I $D(ERR) S RES("watch",I,"error")=$G(ERR("error")) K ERR
	. E  S RES("watch",I,"value")=VAL
	Q:$Q 1 Q
	Q
	;
GETLINE(RTN,LINE,CONF,TXT)
	N SRC,ERR,I,FROM,TO
	S TXT=""
	D GETSRCTXT^MIOIDED($G(RTN),.CONF,1048576,.SRC,.ERR)
	I $D(ERR) Q
	S FROM=1
	F I=1:1:+$G(LINE)-1 S FROM=$F(SRC,$C(10),FROM) I 'FROM Q
	I 'FROM Q
	S TO=$F(SRC,$C(10),FROM)
	I 'TO S TXT=$E(SRC,FROM,$L(SRC)) Q
	S TXT=$E(SRC,FROM,TO-2)
	Q
	;
EVALEXPR(EXPR,VAL,ERR)
	K ERR S VAL=""
	S EXPR=$G(EXPR)
	I EXPR="$JOB" S VAL=$J Q
	I EXPR="$HOROLOG" S VAL=$H Q
	I $E(EXPR)="^",$$SAFEGL^MIOIDEDBGU(EXPR) S VAL=$G(@EXPR) Q
	S ERR("error")="expr_not_allowed"
	Q
	;
NEXTBP(SID,RTN,CUR,MAX)
	N LINE
	S LINE=CUR
	F  S LINE=$O(^MIO("MIOIDE","DBG","SESSION",SID,"BP",RTN,LINE)) Q:'LINE  I LINE>CUR Q
	Q $S(+LINE>CUR:+LINE,1:0)
	;
