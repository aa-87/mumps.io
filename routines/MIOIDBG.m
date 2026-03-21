MIOIDBG ; MIOIDE debugger foundation
	Q
	;
START(RTN,ENTRY,REQ,CONF,RES)
	N SID,LINES,ERR,LINE,CLI,OK
	K RES
	S RES("ok")=0
	S RES("routine")=$G(RTN)
	S RES("entry")=$G(ENTRY)
	I '$G(CONF("mioide","debug","enabled")) S RES("error")="debug_disabled" Q:$Q 0 Q
	I '$$ISRTN^MIOIDED($G(RTN)) S RES("error")="invalid_routine" Q:$Q 0 Q
	D SRCLINES(RTN,.CONF,.LINES,.ERR)
	I $D(ERR("error")) M RES=ERR Q:$Q 0 Q
	S LINE=$$FIRSTLN(.LINES)
	I LINE<1 S RES("error")="empty_source" Q:$Q 0 Q
	S SID=$$RID^MIOIDEWS()
	S CLI=$$CLIENT^MIOIDEWS(.REQ)
	K ^MIO("MIOIDE","DBG","SESSION",SID)
	S ^MIO("MIOIDE","DBG","SESSION",SID,"routine")=RTN
	S ^MIO("MIOIDE","DBG","SESSION",SID,"entry")=$G(ENTRY)
	S ^MIO("MIOIDE","DBG","SESSION",SID,"line")=LINE
	S ^MIO("MIOIDE","DBG","SESSION",SID,"maxline")=+$O(LINES(""),-1)
	S ^MIO("MIOIDE","DBG","SESSION",SID,"status")="paused"
	S ^MIO("MIOIDE","DBG","SESSION",SID,"reason")="entry"
	S ^MIO("MIOIDE","DBG","SESSION",SID,"client")=CLI
	S OK=$$SNAP(SID,.CONF,.RES)
	I 'OK Q:$Q 0 Q
	S RES("started")=1
	D PUBLISH(SID,CLI,"debug",RTN,"paused","Debug session started",.RES)
	Q:$Q +$G(RES("ok"))
	Q
	;
SNAP(SID,CONF,RES)
	N RTN,ENTRY,LINE,MAXL,STATUS,REASON,CLI,LINES,ERR,IDX,EXPR,VAL,VERR,BPS,NEXT,FIRST
	K RES
	S RES("ok")=0
	I '$$SAFEID^MIOIDEWS($G(SID)) S RES("error")="invalid_session" Q:$Q 0 Q
	I '$D(^MIO("MIOIDE","DBG","SESSION",SID)) S RES("error")="session_not_found" Q:$Q 0 Q
	S RTN=$G(^MIO("MIOIDE","DBG","SESSION",SID,"routine"))
	S ENTRY=$G(^MIO("MIOIDE","DBG","SESSION",SID,"entry"))
	S LINE=+$G(^MIO("MIOIDE","DBG","SESSION",SID,"line"))
	S MAXL=+$G(^MIO("MIOIDE","DBG","SESSION",SID,"maxline"))
	S STATUS=$G(^MIO("MIOIDE","DBG","SESSION",SID,"status"))
	S REASON=$G(^MIO("MIOIDE","DBG","SESSION",SID,"reason"))
	S CLI=$G(^MIO("MIOIDE","DBG","SESSION",SID,"client"))
	D SRCLINES(RTN,.CONF,.LINES,.ERR)
	I $D(ERR("error")) M RES=ERR Q:$Q 0 Q
	S FIRST=$$FIRSTLN(.LINES)
	S NEXT=$$NEXTBP(RTN,LINE)
	S RES("ok")=1
	S RES("sid")=SID
	S RES("routine")=RTN
	S RES("entry")=ENTRY
	S RES("line")=LINE
	S RES("maxline")=MAXL
	S RES("status")=STATUS
	S RES("reason")=REASON
	S RES("clientId")=CLI
	S RES("currentText")=$G(LINES(LINE))
	S RES("firstLine")=FIRST
	S RES("nextBreakpoint")=NEXT
	S RES("frame",1,"name")=$S(ENTRY'="":ENTRY_"^"_RTN,1:RTN_"+"_LINE)
	S RES("frame",1,"detail")="Interactive debug frame"
	S RES("frame",1,"isActive")=1
	S RES("frame",2,"name")="MIOIDE debugger"
	S RES("frame",2,"detail")="Source-mapped stepping foundation"
	D LISTBP(RTN,.BPS)
	S IDX=0
	F  S IDX=$O(BPS(IDX)) Q:'IDX  M RES("breakpoint",IDX)=BPS(IDX)
	S IDX=0
	F  S IDX=$O(^MIO("MIOIDE","DBG","SESSION",SID,"watch",IDX)) Q:'IDX  D
	. S EXPR=$G(^MIO("MIOIDE","DBG","SESSION",SID,"watch",IDX,"expr"))
	. K VERR S VAL=$$WATCHVAL(EXPR,.VERR)
	. S RES("watch",IDX)=EXPR
	. S RES("watch",IDX,"expr")=EXPR
	. S RES("watch",IDX,"value")=$S($D(VERR("error")):$G(VERR("error")),1:VAL)
	Q:$Q 1
	Q
	;
CMD(SID,CMD,REQ,CONF,RES)
	N RTN,LINE,NEWL,CLI,OK
	K RES
	I '$$SAFEID^MIOIDEWS($G(SID)) S RES("ok")=0,RES("error")="invalid_session" Q:$Q 0 Q
	I '$D(^MIO("MIOIDE","DBG","SESSION",SID)) S RES("ok")=0,RES("error")="session_not_found" Q:$Q 0 Q
	S CMD=$$LOW($G(CMD))
	S RTN=$G(^MIO("MIOIDE","DBG","SESSION",SID,"routine"))
	S LINE=+$G(^MIO("MIOIDE","DBG","SESSION",SID,"line"))
	S CLI=$G(^MIO("MIOIDE","DBG","SESSION",SID,"client")) I CLI="" S CLI=$$CLIENT^MIOIDEWS(.REQ)
	I CMD="pause" D  G CMDQ
	. S ^MIO("MIOIDE","DBG","SESSION",SID,"status")="paused"
	. S ^MIO("MIOIDE","DBG","SESSION",SID,"reason")="pause"
	I CMD="stop" D  G CMDQ
	. S ^MIO("MIOIDE","DBG","SESSION",SID,"status")="terminated"
	. S ^MIO("MIOIDE","DBG","SESSION",SID,"reason")="stop"
	I (CMD="stepinto")!(CMD="stepover") D  G CMDQ
	. S NEWL=$$NEXTLN(RTN,LINE,.CONF)
	. I NEWL<1 D  Q
	. . S ^MIO("MIOIDE","DBG","SESSION",SID,"status")="terminated"
	. . S ^MIO("MIOIDE","DBG","SESSION",SID,"reason")="eof"
	. S ^MIO("MIOIDE","DBG","SESSION",SID,"line")=NEWL
	. S ^MIO("MIOIDE","DBG","SESSION",SID,"status")="paused"
	. S ^MIO("MIOIDE","DBG","SESSION",SID,"reason")=CMD
	I CMD="continue" D  G CMDQ
	. S NEWL=$$NEXTBP(RTN,LINE)
	. I NEWL<1 D  Q
	. . S NEWL=$$NEXTLN(RTN,LINE,.CONF)
	. . I NEWL<1 S ^MIO("MIOIDE","DBG","SESSION",SID,"status")="terminated",^MIO("MIOIDE","DBG","SESSION",SID,"reason")="eof" Q
	. . F  Q:NEWL<1  Q:$D(^MIO("MIOIDE","DBG","BP",RTN,NEWL))  S NEWL=$$NEXTLN(RTN,NEWL,.CONF)
	. . I NEWL<1 S ^MIO("MIOIDE","DBG","SESSION",SID,"status")="terminated",^MIO("MIOIDE","DBG","SESSION",SID,"reason")="eof" Q
	. S ^MIO("MIOIDE","DBG","SESSION",SID,"line")=NEWL
	. S ^MIO("MIOIDE","DBG","SESSION",SID,"status")="paused"
	. S ^MIO("MIOIDE","DBG","SESSION",SID,"reason")=$S($D(^MIO("MIOIDE","DBG","BP",RTN,NEWL)):"breakpoint",1:"continue")
	S RES("ok")=0,RES("error")="invalid_command" Q 0
CMDQ	S OK=$$SNAP(SID,.CONF,.RES)
	I 'OK Q:$Q 0 Q
	D PUBLISH(SID,CLI,"debug",RTN,$G(RES("status")),"Debug state updated",.RES)
	Q:$Q +$G(RES("ok"))
	Q
	;
TOGBP(RTN,LINE,REQ,CONF,RES)
	N CLI
	K RES
	S CLI=$$CLIENT^MIOIDEWS(.REQ)
	I '$$ISRTN^MIOIDED($G(RTN)) S RES("ok")=0,RES("error")="invalid_routine" Q:$Q 0 Q
	S LINE=+$G(LINE)
	I LINE<1 S RES("ok")=0,RES("error")="invalid_line" Q:$Q 0 Q
	I $D(^MIO("MIOIDE","DBG","BP",RTN,LINE)) K ^MIO("MIOIDE","DBG","BP",RTN,LINE) S RES("enabled")=0
	E  S ^MIO("MIOIDE","DBG","BP",RTN,LINE)=1 S RES("enabled")=1
	S RES("ok")=1,RES("routine")=RTN,RES("line")=LINE,RES("type")="breakpoint"
	D PUBLISH("",CLI,"breakpoint",RTN,$S(RES("enabled"):"enabled",1:"disabled"),"Breakpoint toggled",.RES)
	Q:$Q 1
	Q
	;
LISTBP(RTN,OUT)
	N LINE,IDX
	K OUT
	S LINE=0,IDX=0
	F  S LINE=$O(^MIO("MIOIDE","DBG","BP",$G(RTN),LINE)) Q:'LINE  D
	. S IDX=IDX+1
	. S OUT(IDX,"line")=LINE
	. S OUT(IDX,"loc")=$G(RTN)_"+"_LINE
	. S OUT(IDX,"enabled")=1
	. S OUT(IDX,"detail")="Persistent breakpoint"
	Q
	;
ADDWATCH(SID,EXPR,REQ,CONF,RES)
	N IDX,CLI,OK
	K RES
	S CLI=$$CLIENT^MIOIDEWS(.REQ)
	I '$$SAFEID^MIOIDEWS($G(SID)) S RES("ok")=0,RES("error")="invalid_session" Q:$Q 0 Q
	I '$D(^MIO("MIOIDE","DBG","SESSION",SID)) S RES("ok")=0,RES("error")="session_not_found" Q:$Q 0 Q
	S EXPR=$$TRIM($G(EXPR))
	I EXPR="" S RES("ok")=0,RES("error")="empty_expression" Q:$Q 0 Q
	S IDX=$INCREMENT(^MIO("MIOIDE","DBG","SESSION",SID,"watchSeq"))
	S ^MIO("MIOIDE","DBG","SESSION",SID,"watch",IDX,"expr")=EXPR
	S OK=$$SNAP(SID,.CONF,.RES)
	I 'OK Q:$Q 0 Q
	D PUBLISH(SID,CLI,"watch",$G(^MIO("MIOIDE","DBG","SESSION",SID,"routine")),"updated","Watch added",.RES)
	Q:$Q +$G(RES("ok"))
	Q
	;
DELWATCH(SID,IDX,REQ,CONF,RES)
	N CLI,OK
	K RES
	S CLI=$$CLIENT^MIOIDEWS(.REQ)
	I '$$SAFEID^MIOIDEWS($G(SID)) S RES("ok")=0,RES("error")="invalid_session" Q:$Q 0 Q
	I '$D(^MIO("MIOIDE","DBG","SESSION",SID)) S RES("ok")=0,RES("error")="session_not_found" Q:$Q 0 Q
	S IDX=+$G(IDX)
	I IDX<1 S RES("ok")=0,RES("error")="invalid_watch" Q:$Q 0 Q
	K ^MIO("MIOIDE","DBG","SESSION",SID,"watch",IDX)
	S OK=$$SNAP(SID,.CONF,.RES)
	I 'OK Q:$Q 0 Q
	D PUBLISH(SID,CLI,"watch",$G(^MIO("MIOIDE","DBG","SESSION",SID,"routine")),"updated","Watch removed",.RES)
	Q:$Q +$G(RES("ok"))
	Q
	;
EVAL(SID,EXPR,REQ,CONF,RES)
	N VAL,ERR,CLI
	K RES
	S CLI=$$CLIENT^MIOIDEWS(.REQ)
	I '$$SAFEID^MIOIDEWS($G(SID)) S RES("ok")=0,RES("error")="invalid_session" Q:$Q 0 Q
	I '$D(^MIO("MIOIDE","DBG","SESSION",SID)) S RES("ok")=0,RES("error")="session_not_found" Q:$Q 0 Q
	S EXPR=$$TRIM($G(EXPR))
	I EXPR="" S RES("ok")=0,RES("error")="empty_expression" Q:$Q 0 Q
	S VAL=$$WATCHVAL(EXPR,.ERR)
	I $D(ERR("error")) M RES=ERR S RES("ok")=0 Q:$Q 0 Q
	S RES("ok")=1,RES("sid")=SID,RES("expr")=EXPR,RES("value")=VAL
	D PUBLISH(SID,CLI,"debug_eval",$G(^MIO("MIOIDE","DBG","SESSION",SID,"routine")),"ok","Expression evaluated",.RES)
	Q:$Q 1
	Q
	;
WATCHVAL(EXPR,ERR)
	N VAL
	K ERR
	S EXPR=$$TRIM($G(EXPR))
	I EXPR="$JOB" Q $J
	I EXPR="$HOROLOG" Q $H
	I $E(EXPR,1)="^" D  Q VAL
	. I '$$SAFEGREF(EXPR) S ERR("error")="invalid_expression" Q
	. S VAL=$G(@EXPR)
	I $$ISID^MIOIDED(EXPR) Q "<runtime local unavailable>"
	S ERR("error")="unsupported_expression"
	Q ""
	;
SRCLINES(RTN,CONF,OUT,ERR)
	N TXT,I,CNT,PART,MAX
	K OUT,ERR
	S MAX=+$G(CONF("mioide","editor","maxInitialBytes"),262144)
	D GETSRCTXT^MIOIDED(RTN,.CONF,MAX,.TXT,.ERR)
	I $D(ERR("error")) Q
	S CNT=$L(TXT,$C(10))
	F I=1:1:CNT S OUT(I)=$P(TXT,$C(10),I)
	Q
	;
FIRSTLN(LINES)
	N I
	S I=0
	F  S I=$O(LINES(I)) Q:'I  I $$HASCODE($G(LINES(I))) Q
	Q +$G(I)
	;
NEXTLN(RTN,LINE,CONF)
	N LINES,ERR,I
	D SRCLINES(RTN,.CONF,.LINES,.ERR)
	I $D(ERR("error")) Q -1
	S I=+$G(LINE)
	F  S I=$O(LINES(I)) Q:'I  I $$HASCODE($G(LINES(I))) Q
	Q $S(+I>0:I,1:-1)
	;
NEXTBP(RTN,LINE)
	N X
	S X=$O(^MIO("MIOIDE","DBG","BP",$G(RTN),+$G(LINE)))
	Q $S(+X>0:+X,1:-1)
	;
HASCODE(LINE)
	S LINE=$$TRIM($G(LINE))
	I LINE="" Q 0
	I $E(LINE)=";" Q 0
	Q 1
	;
SAFEGREF(X)
	N I,C,OK
	S X=$G(X)
	I X="" Q 0
	I $E(X,1)'="^" Q 0
	S OK=1
	F I=2:1:$L(X) Q:'OK  D
	. S C=$E(X,I)
	. I "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789%(),_-"'[C S OK=0
	Q OK
	;
RESET(TESTONLY)
	K ^MIO("MIOIDE","DBG")
	I $G(TESTONLY) K ^MIO("MIOIDE","EV")
	Q
	;
PUBLISH(SID,CLI,TYPE,RTN,STATUS,MESSAGE,DATA)
	N EV
	I $G(CLI)="",$$SAFEID^MIOIDEWS($G(SID)) S CLI=$G(^MIO("MIOIDE","DBG","SESSION",SID,"client"))
	I '$$SAFEID^MIOIDEWS($G(CLI)) Q
	S EV("type")=$G(TYPE)
	S EV("sid")=$G(SID)
	S EV("routine")=$G(RTN)
	S EV("status")=$G(STATUS)
	S EV("message")=$G(MESSAGE)
	I $D(DATA("line")) S EV("line")=$G(DATA("line"))
	I $D(DATA("reason")) S EV("reason")=$G(DATA("reason"))
	D PUB^MIOIDEWS(CLI,.EV)
	Q
	;
LOW(X)
	Q $ZCONVERT($G(X),"L")
	;
TRIM(X)
	Q $$RTRIM($$LTRIM($G(X)))
	;
LTRIM(X)
	F  Q:$E(X,1)'=" "  S X=$E(X,2,$L(X))
	Q X
	;
RTRIM(X)
	F  Q:X=""  Q:$E(X,$L(X))'=" "  S X=$E(X,1,$L(X)-1)
	Q X
	;
	;