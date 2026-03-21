MIOIDET002 ; MIOIDE helper and context tests
	D START Q
	;
START(FAIL)
	N TOP,LOCAL
	S TOP='$D(FAIL),LOCAL=0
	D T001(.LOCAL)
	D T010(.LOCAL)
	D T020(.LOCAL)
	D T030(.LOCAL)
	I TOP D  Q
	. I 'LOCAL W !,"OK - MIOIDET002"
	I LOCAL S FAIL=1
	Q
	;
T001(FAIL)
	N CONF,REQ,CTX,TCTX
	D CONFDEF^MIOIDE(.CONF)
	D BUILDHOME^MIOIDED(.CONF,.REQ,.CTX,.TCTX)
	D EQ^MIOIDET000(.FAIL,"[T001][heading]",$G(TCTX("heading")),"MIOIDE Debug Workbench")
	D HAS^MIOIDET000(.FAIL,"[T001][terminal intro]",$G(TCTX("terminalIntro")),"Xterm.js")
	D EQ^MIOIDET000(.FAIL,"[T001][palette reload]",$G(TCTX("palette",2,"id")),"reload")
	D EQ^MIOIDET000(.FAIL,"[T001][palette new terminal]",$G(TCTX("palette",5,"id")),"newterm")
	D EQ^MIOIDET000(.FAIL,"[T001][activity output]",$G(TCTX("activity",6,"id")),"output")
	D EQ^MIOIDET000(.FAIL,"[T001][activity terminal]",$G(TCTX("activity",7,"id")),"terminal")
	D TRUE^MIOIDET000(.FAIL,"[T001][has active name]",$L($G(TCTX("activeName")))>0)
	D HAS^MIOIDET000(.FAIL,"[T001][command label]",$G(TCTX("commandBarLabel")),"Command Palette")
	Q
	;
T010(FAIL)
	N CONF,RTNS
	D CONFDEF^MIOIDE(.CONF)
	D LISTRTN^MIOIDED(.CONF,"MIOIDE",.RTNS)
	D EQ^MIOIDET000(.FAIL,"[T010][first]",$G(RTNS(1,"name")),"MIOIDE")
	D EQ^MIOIDET000(.FAIL,"[T010][second]",$G(RTNS(2,"name")),"MIOIDED")
	D HAS^MIOIDET000(.FAIL,"[T010][path]",$G(RTNS(1,"path")),".m")
	Q
	;
T020(FAIL)
	N CONF,TXT,ERR,LF,OK
	D CONFDEF^MIOIDE(.CONF)
	S CONF("mioide","routineDir")="tmp"
	S OK=$$SAVETEXT^MIOIDED("MIOIDXA1","MIOIDXA1 ; test fixture"_$C(10)_" S X=1"_$C(10)_" Q",.CONF,.ERR)
	D TRUE^MIOIDET000(.FAIL,"[T020][save fixture]",OK)
	D GETSRCTXT^MIOIDED("MIOIDXA1",.CONF,4096,.TXT,.ERR)
	D HAS^MIOIDET000(.FAIL,"[T020][first line]",TXT,"MIOIDXA1 ; test fixture")
	D HAS^MIOIDET000(.FAIL,"[T020][middle line]",TXT,"S X=1")
	S LF=$L(TXT,$C(10))
	D EQ^MIOIDET000(.FAIL,"[T020][line count]",LF,3)
	Q
	;
T030(FAIL)
	N CONF,RES
	D CONFDEF^MIOIDE(.CONF)
	S CONF("mioide","compile","enabled")=0
	D COMPILE^MIOIDED("MIOIDE",.CONF,.RES)
	D EQ^MIOIDET000(.FAIL,"[T030][compile disabled]",$G(RES("error")),"compile_disabled")
	Q
	;
	;