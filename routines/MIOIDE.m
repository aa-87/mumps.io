MIOIDE ; MIOIDE - Monaco-backed SSR IDE bootstrap for MUMPS.IO
	Q
	;
CONFDEF(CONF)
	I '$D(CONF("mioide","enabled")) S CONF("mioide","enabled")=1
	I '$D(CONF("mioide","authRequired")) S CONF("mioide","authRequired")=1
	I $G(CONF("mioide","roles"))="" S CONF("mioide","roles")="developer,admin"
	I $G(CONF("mioide","routineDir"))="" S CONF("mioide","routineDir")="routines"
	I $G(CONF("mioide","tempDir"))="" S CONF("mioide","tempDir")="tmp"
	I '$D(CONF("mioide","explorer","limit")) S CONF("mioide","explorer","limit")=250
	I '$D(CONF("mioide","search","limit")) S CONF("mioide","search","limit")=60
	I '$D(CONF("mioide","editor","maxInitialBytes")) S CONF("mioide","editor","maxInitialBytes")=262144
	I '$D(CONF("mioide","save","enabled")) S CONF("mioide","save","enabled")=1
	I '$D(CONF("mioide","compile","enabled")) S CONF("mioide","compile","enabled")=1
	I '$D(CONF("mioide","run","enabled")) S CONF("mioide","run","enabled")=1
	I '$D(CONF("mioide","run","maxOutputBytes")) S CONF("mioide","run","maxOutputBytes")=131072
	I '$D(CONF("mioide","run","allowPrefix",1)) S CONF("mioide","run","allowPrefix",1)="MIO"
	I '$D(CONF("mioide","run","allowPrefix",2)) S CONF("mioide","run","allowPrefix",2)="MIOIDE"
	I '$D(CONF("mioide","theme","default")) S CONF("mioide","theme","default")="dark"
	I '$D(CONF("mioide","debug","enabled")) S CONF("mioide","debug","enabled")=1
	I '$D(CONF("mioide","debug","breakpointLimit")) S CONF("mioide","debug","breakpointLimit")=256
	I '$D(CONF("mioide","debug","sessionRetain")) S CONF("mioide","debug","sessionRetain")=32
	I '$D(CONF("mioide","debug","eventRetain")) S CONF("mioide","debug","eventRetain")=64
	I '$D(CONF("mioide","debug","idleSeconds")) S CONF("mioide","debug","idleSeconds")=900
	I '$D(CONF("mioide","debug","wsPath")) S CONF("mioide","debug","wsPath")="/mioide/ws/debug"
	I '$D(CONF("mioide","debug","apiBase")) S CONF("mioide","debug","apiBase")="/mioide/api/debug"
	I '$D(CONF("websocket","idleTimeoutSeconds")) S CONF("websocket","idleTimeoutSeconds")=3600
	I '$D(CONF("websocket","maxFrameBytes")) S CONF("websocket","maxFrameBytes")=65536
	I '$D(CONF("websocket","maxMessageBytes")) S CONF("websocket","maxMessageBytes")=262144
	I '$D(CONF("mioide","ws","enabled")) S CONF("mioide","ws","enabled")=1
	I $G(CONF("mioide","ws","eventsPath"))="" S CONF("mioide","ws","eventsPath")="/mioide/ws/events"
	I $G(CONF("mioide","ws","terminalPath"))="" S CONF("mioide","ws","terminalPath")="/mioide/ws/terminal"
	I '$D(CONF("mioide","ws","pingSeconds")) S CONF("mioide","ws","pingSeconds")=20
	I '$D(CONF("mioide","terminal","enabled")) S CONF("mioide","terminal","enabled")=1
	I '$D(CONF("mioide","terminal","idleSeconds")) S CONF("mioide","terminal","idleSeconds")=1
	I '$D(CONF("mioide","terminal","maxInputBytes")) S CONF("mioide","terminal","maxInputBytes")=8192
	I '$D(CONF("mioide","terminal","maxOutputBytes")) S CONF("mioide","terminal","maxOutputBytes")=65536
	I '$D(CONF("mioide","terminal","allowXecute")) S CONF("mioide","terminal","allowXecute")=1
	I $G(CONF("server","templateDir"))="" S CONF("server","templateDir")="templates"
	I $G(CONF("templates","root"))="" S CONF("templates","root")=$G(CONF("server","templateDir"))_"/"
	I $G(CONF("templates","ext"))="" S CONF("templates","ext")=""
	Q
	;
INIT(CONF)
	D CONFDEF(.CONF)
	D START^MIOTPL(.CONF)
	Q
	;
REG(CONF)
	N EN
	D INIT(.CONF)
	S EN=$S($G(CONF("mioide","enabled"))="true":1,1:+$G(CONF("mioide","enabled")))
	I EN'=1 Q
	D REG^MIOIDER(.CONF)
	D REG^MIOIDEWS(.CONF)
	Q
	;
VERSION()
	Q "0.2.0"
	;
BUILD()
	Q "2026-03-22 websocket debugger transport"
	;
BANNER()
	Q "MIOIDE "_$$VERSION()_" ("_$$BUILD()_")"
	;
