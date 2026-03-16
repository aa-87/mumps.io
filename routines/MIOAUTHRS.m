MIOAUTHRS ; OpenSSL-backed default RS256 verifier for MIOAUTHJWT
	;
	; Public API
	;   $$INIT(.CONF,.ERR) -> 1/0
	;   $$HASCFG(.CONF) -> 1/0
	;   $$VERIFYOSSL(DATA,SIGBIN,.CONF,.CTX,.HOBJ,.POBJ,.ERR) -> 1/0
	;   $$VERIFYJWT(DATA,S64,.CONF,.CTX,.HOBJ,.POBJ,.ERR) -> 1/0
	;
	QUIT
	;
INIT(CONF,ERR)
	KILL ERR
	IF '$$HASCFG(.CONF) QUIT 1
	IF $GET(CONF("auth","jwt","rs256Verify"))="" SET CONF("auth","jwt","rs256Verify")="VERIFYOSSL^MIOAUTHRS"
	IF $$HASOPENSSL(.CONF,.ERR) QUIT 1
	IF $GET(CONF("auth","jwt","rs256InstallCmd"))'="" DO
	. IF $$TRYINSTALL(.CONF,.ERR),$$HASOPENSSL(.CONF,.ERR) QUIT
	QUIT $SELECT($DATA(ERR):0,1:1)
	;
HASCFG(CONF)
	IF $GET(CONF("auth","jwt","rs256PublicKeyPem"))'="" QUIT 1
	IF $GET(CONF("auth","jwt","rs256PublicKeyFile"))'="" QUIT 1
	IF $DATA(CONF("auth","jwt","rs256PublicKeyPemByKid")) QUIT 1
	IF $DATA(CONF("auth","jwt","rs256PublicKeyFileByKid")) QUIT 1
	QUIT 0
	;
VERIFYJWT(DATA,S64,CONF,CTX,HOBJ,POBJ,ERR)
	KILL ERR
	NEW MODE,KEYVAL,WORK,BASE,DATAFILE,SIG64FILE,SIGFILE,PUBFILE,OWNPUB,OUT,RC,OSSL
	IF '$$HASOPENSSL(.CONF,.ERR) QUIT 0
	IF '$$GETKEY(.CONF,.HOBJ,.POBJ,.MODE,.KEYVAL,.ERR) QUIT 0
	SET WORK=$$WORKDIR(.CONF)
	SET BASE=$$TMPBASE(WORK)
	SET DATAFILE=BASE_".dat"
	SET SIG64FILE=BASE_".sig.b64"
	SET SIGFILE=BASE_".sig"
	SET OWNPUB=0,PUBFILE=""
	IF MODE="pem" DO
	. SET PUBFILE=BASE_".pub.pem",OWNPUB=1
	. DO WTXT(PUBFILE,KEYVAL,.ERR)
	IF $DATA(ERR) QUIT 0
	IF MODE="file" DO
	. SET PUBFILE=KEYVAL
	. IF '$$FILEOK(PUBFILE) SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_rs256_key_missing",ERR("status")=401
	IF $DATA(ERR) QUIT 0
	DO WTXT(DATAFILE,DATA,.ERR)
	IF $DATA(ERR) DO CLEAN(DATAFILE,SIG64FILE,SIGFILE,PUBFILE,OWNPUB) QUIT 0
	DO WTXT(SIG64FILE,$$URL2STD($GET(S64)),.ERR)
	IF $DATA(ERR) DO CLEAN(DATAFILE,SIG64FILE,SIGFILE,PUBFILE,OWNPUB) QUIT 0
	SET OSSL=$$OSSL(.CONF)
	SET RC=$$RUNVERIFY(OSSL,DATAFILE,SIG64FILE,SIGFILE,PUBFILE,.OUT)
	DO CLEAN(DATAFILE,SIG64FILE,SIGFILE,PUBFILE,OWNPUB)
	IF RC=0 QUIT 1
	IF RC<0 DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_rs256_verify_failed",ERR("status")=401
	. SET ERR("detail")=$GET(OUT)
	IF $$ISSIGFAIL($GET(OUT)) DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_bad_signature",ERR("status")=401
	. SET ERR("detail")=$GET(OUT)
	SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_rs256_verify_failed",ERR("status")=401
	SET ERR("detail")=$GET(OUT)
	QUIT 0
	;
VERIFYOSSL(DATA,SIGBIN,CONF,CTX,HOBJ,POBJ,ERR)
	KILL ERR
	NEW S64
	SET S64=$GET(CONF("auth","jwt","_sig64"))
	IF S64="" SET S64=$GET(CTX("auth","jwt","sig64"))
	IF S64'="" QUIT $$VERIFYJWT(DATA,S64,.CONF,.CTX,.HOBJ,.POBJ,.ERR)
	SET S64=$$B64EURL^MIOAUTHJWT($GET(SIGBIN))
	QUIT $$VERIFYJWT(DATA,S64,.CONF,.CTX,.HOBJ,.POBJ,.ERR)
	;
GETKEY(CONF,HOBJ,POBJ,MODE,KEYVAL,ERR)
	KILL ERR
	SET MODE="",KEYVAL=""
	IF $GET(CONF("auth","jwt","rs256PublicKeyPem"))'="" SET MODE="pem",KEYVAL=$GET(CONF("auth","jwt","rs256PublicKeyPem")) QUIT 1
	IF $GET(CONF("auth","jwt","rs256PublicKeyFile"))'="" SET MODE="file",KEYVAL=$GET(CONF("auth","jwt","rs256PublicKeyFile")) QUIT 1
	NEW KID SET KID=$GET(HOBJ("kid"))
	IF KID'="",$GET(CONF("auth","jwt","rs256PublicKeyPemByKid",KID))'="" SET MODE="pem",KEYVAL=$GET(CONF("auth","jwt","rs256PublicKeyPemByKid",KID)) QUIT 1
	IF KID'="",$GET(CONF("auth","jwt","rs256PublicKeyFileByKid",KID))'="" SET MODE="file",KEYVAL=$GET(CONF("auth","jwt","rs256PublicKeyFileByKid",KID)) QUIT 1
	SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_rs256_key_missing",ERR("status")=401
	QUIT 0
	;
HASOPENSSL(CONF,ERR)
	KILL ERR
	IF +$GET(CONF("auth","jwt","rs256OpenSSLOk"))=1 QUIT 1
	NEW OUT,RC,CMD,OSSL
	SET OSSL=$$OSSL(.CONF)
	SET CMD=$$SQ(OSSL)_" version >/dev/null 2>&1; RC=$?; printf '__MIO_RC__:%s\n' ""$RC"""
	IF '$$EXEC(CMD,.OUT,.ERR) QUIT 0
	SET RC=$$PARSERC(OUT)
	IF RC=0 SET CONF("auth","jwt","rs256OpenSSLOk")=1 QUIT 1
	SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_rs256_openssl_missing",ERR("status")=401
	DO INSTALLHINT(.ERR)
	QUIT 0
	;
TRYINSTALL(CONF,ERR)
	KILL ERR
	NEW CMD,OUT,RC
	SET CMD=$GET(CONF("auth","jwt","rs256InstallCmd"))
	IF CMD="" QUIT 0
	IF '$$EXEC(CMD,.OUT,.ERR) QUIT 0
	SET RC=$$PARSERC(OUT)
	IF RC<0 SET RC=0
	KILL CONF("auth","jwt","rs256OpenSSLOk")
	IF RC'=0 DO
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_rs256_install_failed",ERR("status")=500
	. SET ERR("detail")=OUT
	. DO INSTALLHINT(.ERR)
	QUIT $SELECT(RC=0:1,1:0)
	;
INSTALLHINT(ERR)
	SET ERR("install","debian")="sudo apt-get update && sudo apt-get install -y openssl"
	SET ERR("install","ubuntu")=ERR("install","debian")
	SET ERR("install","rhel")="sudo dnf install -y openssl || sudo yum install -y openssl"
	SET ERR("install","alpine")="sudo apk add openssl"
	SET ERR("install","macos")="brew install openssl"
	QUIT
	;
OSSL(CONF)
	NEW X SET X=$GET(CONF("auth","jwt","rs256OpenSSLPath"))
	IF X="" SET X="openssl"
	QUIT X
	;
WORKDIR(CONF)
	NEW X,WD
	SET X=$GET(CONF("auth","jwt","rs256WorkDir"))
	IF X="" SET X="tmp"
	IF $EXTRACT(X,1)="/" QUIT X
	SET WD=$ZDIRECTORY
	IF WD="" QUIT X
	QUIT $$JOIN(WD,X)
	;
TMPBASE(WORK)
	NEW NAME
	SET NAME="mioauthrs-"_$JOB_"-"_$PIECE($HOROLOG,",",1)_"-"_$PIECE($HOROLOG,",",2)_"-"_$R(1000000)
	QUIT $$JOIN(WORK,NAME)
	;
JOIN(DIR,NAME)
	NEW D SET D=$GET(DIR)
	IF D="" QUIT $GET(NAME)
	IF $EXTRACT(D,$L(D))="/" QUIT D_$GET(NAME)
	QUIT D_"/"_$GET(NAME)
	;
FILEOK(PATH)
	NEW DEV,OK
	SET DEV=$GET(PATH),OK=0
	IF DEV="" QUIT 0
	OPEN DEV:(readonly:stream:nowrap):0
	IF $TEST SET OK=1 CLOSE DEV
	QUIT OK
	;
WTXT(PATH,TXT,ERR)
	KILL ERR
	NEW DEV,OIO,I,L,CHUNK
	SET DEV=$GET(PATH)
	IF DEV="" DO  QUIT
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_rs256_tempfile"
	SET OIO=$IO
	OPEN DEV:(newversion:stream:nowrap:chset="M"):5
	IF '$TEST DO  QUIT
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_rs256_tempfile"
	USE DEV
	SET L=$L($GET(TXT))
	FOR I=1:4096:L DO
	. SET CHUNK=$E(TXT,I,I+4095)
	. WRITE CHUNK
	CLOSE DEV
	USE OIO
	QUIT
	;
RUNVERIFY(OSSL,DATAFILE,SIG64FILE,SIGFILE,PUBFILE,OUT)
	NEW RC
	SET OUT=""
	SET RC=$$DECSIG(OSSL,SIG64FILE,SIGFILE,.OUT)
	IF RC'=0 QUIT RC
	QUIT $$VERIFYFILE(OSSL,DATAFILE,SIGFILE,PUBFILE,.OUT)
	;
DECSIG(OSSL,SIG64FILE,SIGFILE,OUT)
	NEW CMD,RC,ERRX
	SET OUT=""
	SET CMD="if command -v base64 >/dev/null 2>&1; then base64 -d < "_$$SQ(SIG64FILE)_" > "_$$SQ(SIGFILE)_" 2>/dev/null; RC=$?; else RC=127; fi; printf '__MIO_RC__:%s\n' ""$RC"""
	IF '$$EXEC(CMD,.OUT,.ERRX) QUIT -1
	SET RC=$$PARSERC(OUT)
	IF RC=0 QUIT 0
	SET CMD="if command -v base64 >/dev/null 2>&1; then base64 -D -i "_$$SQ(SIG64FILE)_" -o "_$$SQ(SIGFILE)_" >/dev/null 2>&1; RC=$?; else RC=127; fi; printf '__MIO_RC__:%s\n' ""$RC"""
	IF '$$EXEC(CMD,.OUT,.ERRX) QUIT -1
	SET RC=$$PARSERC(OUT)
	IF RC=0 QUIT 0
	SET CMD=$$SQ(OSSL)_" enc -base64 -d -A -in "_$$SQ(SIG64FILE)_" -out "_$$SQ(SIGFILE)_" >/dev/null 2>&1; printf '__MIO_RC__:%s\n' ""$?"""
	IF '$$EXEC(CMD,.OUT,.ERRX) QUIT -1
	SET RC=$$PARSERC(OUT)
	IF RC=0 QUIT 0
	SET CMD=$$SQ(OSSL)_" base64 -d -A -in "_$$SQ(SIG64FILE)_" -out "_$$SQ(SIGFILE)_" >/dev/null 2>&1; printf '__MIO_RC__:%s\n' ""$?"""
	IF '$$EXEC(CMD,.OUT,.ERRX) QUIT -1
	QUIT $$PARSERC(OUT)
	;
VERIFYFILE(OSSL,DATAFILE,SIGFILE,PUBFILE,OUT)
	NEW CMD,ERRX
	SET OUT=""
	SET CMD=$$SQ(OSSL)_" dgst -sha256 -verify "_$$SQ(PUBFILE)_" -signature "_$$SQ(SIGFILE)_" "_$$SQ(DATAFILE)_" 2>&1; printf '__MIO_RC__:%s\n' ""$?"""
	IF '$$EXEC(CMD,.OUT,.ERRX) QUIT -1
	QUIT $$PARSERC(OUT)
	;
CLEAN(DATAFILE,SIG64FILE,SIGFILE,PUBFILE,OWNPUB)
	NEW CMD,OUT,ERR2
	SET CMD="rm -f "_$$SQ($GET(DATAFILE))_" "_$$SQ($GET(SIG64FILE))_" "_$$SQ($GET(SIGFILE))
	IF +$GET(OWNPUB)=1 SET CMD=CMD_" "_$$SQ($GET(PUBFILE))
	DO EXEC(CMD,.OUT,.ERR2)
	QUIT
	;
EXEC(CMD,OUT,ERR)
	KILL ERR
	NEW DEV,OIO,X
	SET OUT="",DEV="pipe"
	OPEN DEV:(command=CMD:shell="/bin/sh"):10:"pipe"
	IF '$TEST DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_rs256_pipe_open"
	SET OIO=$IO
	USE DEV
	FOR  READ X#4096:10 DO  QUIT:$ZEOF!$DATA(ERR)
	. IF '$TEST SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_rs256_pipe_timeout" QUIT
	. SET OUT=OUT_X
	CLOSE DEV
	USE OIO
	QUIT:$QUIT '$DATA(ERR)
	QUIT
	;
PARSERC(OUT)
	NEW POS,X
	SET X=$GET(OUT)
	SET POS=$F(X,"__MIO_RC__:")
	IF POS<1 QUIT -1
	QUIT +$E(X,POS,$L(X))
	;
SQ(S)
	NEW X,Y,I,C
	SET X=$GET(S),Y=$C(39)
	FOR I=1:1:$L(X) DO
	. SET C=$E(X,I)
	. IF C=$C(39) SET Y=Y_$C(39,34,39,34,39) QUIT
	. SET Y=Y_C
	QUIT Y_$C(39)
	;
ISSIGFAIL(OUT)
	NEW X
	SET X=$GET(OUT)
	IF X["Verification failure" QUIT 1
	IF X["bad signature" QUIT 1
	IF X["rsa_verify" QUIT 1
	IF X["ossl_rsa_verify" QUIT 1
	QUIT 0
	;
URL2STD(X)
	NEW P
	SET X=$TRANSLATE($GET(X),"-_","+/")
	SET P=$L(X)#4
	IF P=2 SET X=X_"=="
	IF P=3 SET X=X_"="
	QUIT X
	;