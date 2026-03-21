MIOIDET002 ; MIOIDE render and helper tests
	D START Q
	;
START(FAIL)
	N TOP,LOCAL
	S TOP='$D(FAIL),LOCAL=0
	D T001(.LOCAL)
	D T010(.LOCAL)
	D T020(.LOCAL)
	I TOP D  Q
	. I 'LOCAL W !,"OK - MIOIDET002"
	I LOCAL S FAIL=1
	Q
	;
T001(FAIL)
	N CONF,REQ,CTX,TCTX,OUT,ERR
	D CONFDEF^MIOIDE(.CONF)
	S CONF("mioide","routineDir")="routines"
	D MKFIX(.CONF)
	S REQ("query","name")="MIOIDE"
	D BUILDHOME^MIOIDED(.CONF,.REQ,.CTX,.TCTX)
	D RENDER^MIOIDER(.CONF,.TCTX,.OUT,.ERR)
	D TRUE^MIOIDET000(.FAIL,"[T001][render ok]",'$D(ERR))
	D HAS^MIOIDET000(.FAIL,"[T001][heading]",OUT,"MIOIDE Debug Workbench")
	D HAS^MIOIDET000(.FAIL,"[T001][terminal ws]",OUT,"/mioide/ws/terminal")
	D HAS^MIOIDET000(.FAIL,"[T001][events ws]",OUT,"/mioide/ws/events")
	D HAS^MIOIDET000(.FAIL,"[T001][xterm]",OUT,"xterm")
	D HAS^MIOIDET000(.FAIL,"[T001][debug start]",OUT,"Start")
	D HAS^MIOIDET000(.FAIL,"[T001][debug step]",OUT,"Step Into")
	D HAS^MIOIDET000(.FAIL,"[T001][debug api]",OUT,"/mioide/api/debug")
	Q
	;
T010(FAIL)
	N CONF,RTNS
	D CONFDEF^MIOIDE(.CONF)
	D LISTRTN^MIOIDED(.CONF,"MIOIDE",.RTNS)
	D EQ^MIOIDET000(.FAIL,"[T010][first]",$G(RTNS(1,"name")),"MIOIDE")
	D EQ^MIOIDET000(.FAIL,"[T010][second]",$G(RTNS(2,"name")),"MIOIDED")
	Q
	;
T020(FAIL)
	N CONF,TXT,ERR,RES
	D CONFDEF^MIOIDE(.CONF)
	S CONF("mioide","routineDir")="routines"
	D MKFIX(.CONF)
	D GETSRCTXT^MIOIDED("MIOIDXA1",.CONF,4096,.TXT,.ERR)
	D HAS^MIOIDET000(.FAIL,"[T020][text]",TXT,"MIOIDXA1 ; test fixture")
	S CONF("mioide","compile","enabled")=0
	D COMPILE^MIOIDED("MIOIDXA1",.CONF,.RES)
	D EQ^MIOIDET000(.FAIL,"[T020][compile disabled]",$G(RES("error")),"compile_disabled")
	Q
	;
MKFIX(CONF)
	N X,ERR
	S X=$$SAVETEXT^MIOIDED("MIOIDXA1","MIOIDXA1 ; test fixture"_$C(10)_" Q",.CONF,.ERR)
	S X=$$SAVETEXT^MIOIDED("MIOIDXA2","MIOIDXA2 ; test fixture"_$C(10)_" Q",.CONF,.ERR)
	Q
	;