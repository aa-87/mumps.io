MIOIDEWS ; MIOIDE WebSocket terminal and event bus
	Q
	;
REG(CONF)
	N EN,META
	S EN=+$G(CONF("mioide","ws","enabled"),1)
	I EN'=1 Q
	K META
	S META("authRequired")=+$G(CONF("mioide","authRequired"),1)
	S META("roles")=$G(CONF("mioide","roles"),"developer,admin")
	S META("wsPersistent")=1
	D ADDWSM^MIOROUTE($G(CONF("mioide","ws","eventsPath"),"/mioide/ws/events"),"EVENTS^MIOIDEWS",.META)
	D ADDWSM^MIOROUTE($G(CONF("mioide","ws","terminalPath"),"/mioide/ws/terminal"),"TERMINAL^MIOIDEWS",.META)
	Q
	;
PUBREQ(REQ,KIND,RTN,STATUS,MESSAGE,DATA)
	N CID,EV
	S CID=$$CLIENT(.REQ)
	I CID="" Q
	S EV("type")=KIND
	S EV("routine")=$G(RTN)
	S EV("status")=$G(STATUS)
	S EV("message")=$G(MESSAGE)
	I $D(DATA("output")) S EV("output")=$E($G(DATA("output")),1,4096)
	I $D(DATA("error")) S EV("error")=$G(DATA("error"))
	D PUB(CID,.EV)
	Q
	;
CLIENT(REQ)
	N CID
	S CID=$G(REQ("hdr","x-mioide-client"))
	I CID="" S CID=$G(REQ("query","client"))
	Q $S($$SAFEID(CID):CID,1:"")
	;
PUB(CID,EV)
	N KEEP,SEQ,KEY
	I '$$SAFEID($G(CID)) Q
	S KEEP=+$G(^MIO("CONF","mioide","events","retain"),200)
	I KEEP<10 S KEEP=200
	S SEQ=$INCREMENT(^MIO("MIOIDE","EV",CID,"seq"))
	S ^MIO("MIOIDE","EV",CID,SEQ,"ts")=$H
	S KEY=""
	F  S KEY=$O(EV(KEY)) Q:KEY=""  S ^MIO("MIOIDE","EV",CID,SEQ,KEY)=$G(EV(KEY))
	K ^MIO("MIOIDE","EV",CID,SEQ-KEEP)
	Q
	;
NEXTEV(CID,LAST,EV)
	N N,KEY
	K EV
	I '$$SAFEID($G(CID)) Q 0
	S N=$O(^MIO("MIOIDE","EV",CID,+$G(LAST)))
	I 'N Q 0
	S KEY=""
	F  S KEY=$O(^MIO("MIOIDE","EV",CID,N,KEY)) Q:KEY=""  S EV(KEY)=$G(^MIO("MIOIDE","EV",CID,N,KEY))
	S EV("seq")=N
	Q 1
	;
EVENTS(DEV,CONF,REQ,CTX)
	N CID,HELLO,ERR,S,MSG,OPC,OBJ,LAST,PING,I,EV
	S CTX("ws","keep_open")=1
	S CID=""
	D INITJSON(.CTX,.HELLO,.ERR)
	I '$D(ERR),$$SAFEID($G(HELLO("clientId"))) S CID=$G(HELLO("clientId"))
	I CID="" S CID=$$RID()
	S LAST=0,PING=0
	S OBJ("type")="hello",OBJ("channel")="events",OBJ("clientId")=CID,OBJ("message")="events_connected"
	D SENDOBJ(.DEV,.OBJ)
	D INITSTATE^MIOWS(.S,.CONF) S S("to")=1
	F  D  Q:$G(CTX("stop"))
	. F  Q:'$$NEXTEV(CID,.LAST,.EV)  D
	. . D SENDOBJ(.DEV,.EV)
	. . S LAST=+$G(EV("seq"))
	. K ERR,MSG,OPC
	. I '$$READMSG^MIOWS(.DEV,.S,.OPC,.MSG,.ERR) D  Q
	. . I $D(ERR("closed")) S CTX("stop")=1 Q
	. . I $D(ERR("error")) D  S CTX("stop")=1 Q
	. . . S OBJ("type")="error",OBJ("message")=$G(ERR("error")) D SENDOBJ(.DEV,.OBJ)
	. . S PING=PING+1 I PING'<+$G(CONF("mioide","ws","pingSeconds"),20) D  S PING=0
	. . . K OBJ S OBJ("type")="ping",OBJ("channel")="events" D SENDOBJ(.DEV,.OBJ)
	. D PARSE(.MSG,.OBJ,.ERR)
	. I $D(ERR) Q
	. I $G(OBJ("cmd"))="ping" K EV S EV("type")="pong",EV("channel")="events" D SENDOBJ(.DEV,.EV) Q
	. I $$SAFEID($G(OBJ("clientId"))) S CID=$G(OBJ("clientId"))
	D SENDCLOSE^MIOWS(.DEV,"",1000)
	S CTX("stop")=1
	Q
	;
TERMINAL(DEV,CONF,REQ,CTX)
	N HELLO,ERR,S,MSG,OPC,STATE,OUT,OBJ
	S CTX("ws","keep_open")=1
	S STATE("sid")=$$RID()
	S STATE("clientId")=""
	S STATE("prompt")="YDB> "
	D INITJSON(.CTX,.HELLO,.ERR)
	I '$D(ERR),$$SAFEID($G(HELLO("clientId"))) S STATE("clientId")=$G(HELLO("clientId"))
	I '$G(CONF("mioide","terminal","enabled")) D  Q
	. S OBJ("type")="error",OBJ("message")="terminal_disabled" D SENDOBJ(.DEV,.OBJ)
	. D SENDCLOSE^MIOWS(.DEV,"",1008)
	. S CTX("stop")=1
	D BANNER(.DEV,.STATE)
	D INITSTATE^MIOWS(.S,.CONF) S S("to")=+$G(CONF("mioide","terminal","idleSeconds"),1)
	F  D  Q:$G(CTX("stop"))
	. K ERR,MSG,OPC
	. I '$$READMSG^MIOWS(.DEV,.S,.OPC,.MSG,.ERR) D  Q
	. . I $D(ERR("closed")) S CTX("stop")=1 Q
	. . I $D(ERR("error")) D  S CTX("stop")=1 Q
	. . . K OBJ S OBJ("type")="error",OBJ("message")=$G(ERR("error")) D SENDOBJ(.DEV,.OBJ)
	. D TERMMSG(.DEV,.CONF,.REQ,.CTX,.STATE,.MSG)
	D SENDCLOSE^MIOWS(.DEV,"",1000)
	S CTX("stop")=1
	Q
	;
BANNER(DEV,STATE)
	N OBJ
	S OBJ("type")="hello",OBJ("channel")="terminal",OBJ("sid")=$G(STATE("sid")),OBJ("message")="terminal_connected"
	D SENDOBJ(.DEV,.OBJ)
	S OBJ("type")="output",OBJ("data")="MIOIDE terminal session"_$C(13,10)
	D SENDOBJ(.DEV,.OBJ)
	S OBJ("data")="Type help for commands or enter M code."_$C(13,10)
	D SENDOBJ(.DEV,.OBJ)
	S OBJ("type")="prompt",OBJ("data")=$G(STATE("prompt"),"YDB> ")
	D SENDOBJ(.DEV,.OBJ)
	Q
	;
TERMMSG(DEV,CONF,REQ,CTX,STATE,RAW)
	N OBJ,ERR,CMD,LINE,RTN,ENTRY,RES,OUT
	D PARSE(.RAW,.OBJ,.ERR)
	I $D(ERR) S LINE=$$TRIM($G(RAW)) Q:LINE=""  D  Q
	. D EXECLINE(.DEV,.CONF,.REQ,.STATE,LINE)
	S CMD=$$LOW($G(OBJ("cmd")))
	I CMD="resize" Q
	I CMD="ping" K RES S RES("type")="pong",RES("channel")="terminal" D SENDOBJ(.DEV,.RES) Q
	I CMD="clear" K RES S RES("type")="clear" D SENDOBJ(.DEV,.RES) D PROMPT(.DEV,.STATE) Q
	I CMD="exit"!(CMD="quit") S CTX("stop")=1 Q
	S LINE=$G(OBJ("data"))
	I LINE="" S LINE=$G(OBJ("line"))
	S LINE=$$TRIM(LINE)
	I LINE="" D PROMPT(.DEV,.STATE) Q
	D EXECLINE(.DEV,.CONF,.REQ,.STATE,LINE)
	Q
	;
EXECLINE(DEV,CONF,REQ,STATE,LINE)
	N UP,RTN,ENTRY,RES,OUT,ERR,OBJ
	S UP=$$LOW($$TRIM(LINE))
	I UP="help" D  Q
	. S OBJ("type")="output",OBJ("data")="Commands: help, clear, :compile ROUTINE, :run ROUTINE [ENTRY], :load ROUTINE, :quit"_$C(13,10)
	. D SENDOBJ(.DEV,.OBJ)
	. D PROMPT(.DEV,.STATE)
	I UP="clear"!(UP="cls") D  Q
	. K OBJ S OBJ("type")="clear" D SENDOBJ(.DEV,.OBJ)
	. D PROMPT(.DEV,.STATE)
	I $E(LINE,1,9)=":compile " D  Q
	. S RTN=$$TRIM($E(LINE,10,999))
	. D COMPILE^MIOIDED(RTN,.CONF,.RES)
	. D TERMRES(.DEV,.STATE,"compile",RTN,.RES)
	. D PUBTERM(.REQ,.STATE,"compile",RTN,.RES)
	I $E(LINE,1,5)=":run " D  Q
	. S RTN=$$TRIM($P($E(LINE,6,999)," ",1))
	. S ENTRY=$$TRIM($P($E(LINE,6,999)," ",2,99))
	. D RUN^MIOIDED(RTN,ENTRY,.CONF,.RES)
	. D TERMRES(.DEV,.STATE,"run",RTN,.RES)
	. D PUBTERM(.REQ,.STATE,"run",RTN,.RES)
	I $E(LINE,1,6)=":load " D  Q
	. S RTN=$$TRIM($E(LINE,7,999))
	. S OUT="" K ERR
	. I '$$LOADSRC^MIOIDED(RTN,.CONF,.OUT,.ERR) D  Q
	. . S OBJ("type")="output",OBJ("data")="load failed: "_$G(ERR("error"),"not_found")_$C(13,10)
	. . D SENDOBJ(.DEV,.OBJ)
	. . D PROMPT(.DEV,.STATE)
	. S OBJ("type")="output",OBJ("data")=OUT_$C(13,10)
	. D SENDOBJ(.DEV,.OBJ)
	. D PROMPT(.DEV,.STATE)
	I UP=":quit"!(UP=":exit") D  Q
	. S OBJ("type")="output",OBJ("data")="session closing"_$C(13,10)
	. D SENDOBJ(.DEV,.OBJ)
	I '$$TERMSAFE(LINE,.CONF,.ERR) D  Q
	. S OBJ("type")="output",OBJ("data")="blocked: "_$G(ERR("error"),"command_not_allowed")_$C(13,10)
	. D SENDOBJ(.DEV,.OBJ)
	. D PROMPT(.DEV,.STATE)
	S OUT="" K ERR
	I '$$EXECBUF^MIOIDED(LINE,.CONF,.OUT,.ERR) D  Q
	. S OBJ("type")="output",OBJ("data")="error: "_$G(ERR("error"),"xecute_failed")_$S($G(ERR("zstatus"))'="":" - "_$G(ERR("zstatus")),1:"")_$C(13,10)
	. D SENDOBJ(.DEV,.OBJ)
	. D PROMPT(.DEV,.STATE)
	S OBJ("type")="output",OBJ("data")=$S(OUT="":"(no output)",1:OUT)_$C(13,10)
	D SENDOBJ(.DEV,.OBJ)
	D PROMPT(.DEV,.STATE)
	Q
	;
TERMRES(DEV,STATE,KIND,RTN,RES)
	N OBJ,T
	S T=$S($G(RES("ok")):$S(KIND="compile":"compiled",1:"completed"),1:$G(RES("error"),"failed"))
	S OBJ("type")="output"
	S OBJ("data")=KIND_" "_$G(RTN)_": "_T_$C(13,10)
	I KIND="run",$G(RES("output"))'="" S OBJ("data")=OBJ("data")_$G(RES("output"))_$C(13,10)
	I '$G(RES("ok")),$G(RES("zstatus"))'="" S OBJ("data")=OBJ("data")_$G(RES("zstatus"))_$C(13,10)
	D SENDOBJ(.DEV,.OBJ)
	D PROMPT(.DEV,.STATE)
	Q
	;
PUBTERM(REQ,STATE,KIND,RTN,RES)
	N EV,CID
	S CID=$G(STATE("clientId")) I CID="" S CID=$$CLIENT(.REQ)
	I CID="" Q
	S EV("type")=KIND
	S EV("routine")=$G(RTN)
	S EV("status")=$S($G(RES("ok")):$S(KIND="compile":"compiled",1:"completed"),1:$G(RES("error"),"failed"))
	S EV("message")=KIND_" "_$G(RTN)
	I $D(RES("output")) S EV("output")=$E($G(RES("output")),1,4096)
	I $D(RES("error")) S EV("error")=$G(RES("error"))
	D PUB(CID,.EV)
	Q
	;
PROMPT(DEV,STATE)
	N OBJ
	S OBJ("type")="prompt",OBJ("data")=$G(STATE("prompt"),"YDB> ")
	D SENDOBJ(.DEV,.OBJ)
	Q
	;
TERMSAFE(LINE,CONF,ERR)
	N UP,BAD,I
	K ERR
	I '$G(CONF("mioide","terminal","allowXecute")) S ERR("error")="xecute_disabled" Q 0
	I $L($G(LINE))>+$G(CONF("mioide","terminal","maxInputBytes"),8192) S ERR("error")="input_too_large" Q 0
	S UP=$$LOW($$TRIM(LINE))
	F I=1:1 S BAD=$P("read,open,use,close,job,hang,zsystem,zsy,halt,tstart,tcommit,trestart,trollback",",",I) Q:BAD=""  D  Q:$D(ERR)
	. I $E(UP,1,$L(BAD))=BAD S ERR("error")="command_not_allowed"
	Q $S($D(ERR):0,1:1)
	;
INITJSON(CTX,OBJ,ERR)
	K OBJ,ERR,TARR
	I $G(CTX("payload"))="" S ERR("error")="empty_payload" Q
	M TARR=CTX("payload")
	D PARSE(.TARR,.OBJ,.ERR)
	Q
	;
PARSE(RAW,OBJ,ERR)
	K OBJ,ERR
	D DECODE^MIOJSON($G(RAW),.OBJ,.ERR)
	Q
	;
SENDOBJ(DEV,OBJ)
	N TXT
	S TXT=$$EN^MIOJSON1(.OBJ)
	D SENDTEXT^MIOWS(.DEV,TXT)
	Q
	;
RID()
	Q $TR($H,",","")_"-"_$TR($J($R(1000000),6)," ","0")
	;
SAFEID(X)
	N I,C
	S X=$G(X)
	I X="" Q 0
	F I=1:1:$L(X) D  Q:$D(C)
	. I "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"'[$E(X,I) S C=1
	Q '$D(C)
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
	F  Q:$E(X,$L(X))'=" "  S X=$E(X,1,$L(X)-1) Q:X=""
	Q X
	;