MIOIDE ; MIOIDE - Monaco-backed SSR IDE bootstrap for MUMPS.IO
	Q
	;
CONFDEF(CONF)
	S CONF("mioide","authRequired")=0
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
	Q
	;
VERSION()
	Q "0.1.4"
	;
BUILD()
	Q "2026-03-21 roi1 docked terminal palette floating tools"
	;
BANNER()
	Q "MIOIDE "_$$VERSION()_" ("_$$BUILD()_")"
	;
	;