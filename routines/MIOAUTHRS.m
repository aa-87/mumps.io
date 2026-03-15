MIOAUTHRS ; OpenSSL-backed default RS256 verifier for MIOAUTHJWT
	;
	; Public API
	;   $$INIT(.CONF,.ERR) -> 1/0
	;   $$HASCFG(.CONF) -> 1/0
	;   $$VERIFYOSSL(DATA,SIGBIN,.CONF,.CTX,.HOBJ,.POBJ,.ERR) -> 1/0
	;
	; Config
	;   CONF("auth","jwt","rs256Verify")="VERIFYOSSL^MIOAUTHRS"
	;   CONF("auth","jwt","rs256PublicKeyPem")=<PEM text>
	;   CONF("auth","jwt","rs256PublicKeyFile")=<path>
	;   CONF("auth","jwt","rs256PublicKeyPemByKid",kid)=<PEM text>
	;   CONF("auth","jwt","rs256PublicKeyFileByKid",kid)=<path>
	;   CONF("auth","jwt","rs256OpenSSLPath")=<openssl path>
	;   CONF("auth","jwt","rs256WorkDir")=<temp dir>
	;   CONF("auth","jwt","rs256InstallCmd")=<optional shell command>
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
VERIFYOSSL(DATA,SIGBIN,CONF,CTX,HOBJ,POBJ,ERR)
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
	IF MODE="pem" DO  QUIT:$DATA(ERR) 0
	. SET PUBFILE=BASE_".pub.pem",OWNPUB=1
	. DO WTXT(PUBFILE,KEYVAL,.ERR)
	IF MODE="file" DO  QUIT:$DATA(ERR) 0
	. SET PUBFILE=KEYVAL
	. IF '$$FILEOK(PUBFILE) DO
	. . SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_rs256_key_missing",ERR("status")=401
	DO WTXT(DATAFILE,DATA,.ERR)
	IF $DATA(ERR) QUIT 0
	DO WTXT(SIG64FILE,$$B64STD(SIGBIN),.ERR)
	IF $DATA(ERR) QUIT 0
	SET OSSL=$$OSSL(.CONF)
	IF '$$RUNVERIFY(OSSL,DATAFILE,SIG64FILE,SIGFILE,PUBFILE,OWNPUB,.OUT,.ERR) QUIT 0
	SET RC=$$PARSERC(OUT)
	IF RC<0 DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_rs256_verify_failed",ERR("status")=401
	IF RC'=0 DO  QUIT 0
	. SET ERR("routine")="MIOAUTHJWT",ERR("error")="jwt_bad_signature",ERR("status")=401
	QUIT 1
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
	NEW X SET X=$GET(CONF("auth","jwt","rs256WorkDir"))
	IF X="" SET X="tmp"
	QUIT X
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
	OPEN DEV:(newversion:stream:nowrap):5
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
RUNVERIFY(OSSL,DATAFILE,SIG64FILE,SIGFILE,PUBFILE,OWNPUB,OUT,ERR)
	KILL ERR
	NEW CMD,CLEAN
	SET OUT=""
	SET CLEAN="rm -f "_$$SQ(DATAFILE)_" "_$$SQ(SIG64FILE)_" "_$$SQ(SIGFILE)
	IF +$GET(OWNPUB)=1 SET CLEAN=CLEAN_" "_$$SQ(PUBFILE)
	SET CMD=$$SQ(OSSL)_" base64 -d -A -in "_$$SQ(SIG64FILE)_" -out "_$$SQ(SIGFILE)_" >/dev/null 2>&1"
	SET CMD=CMD_" && "_$$SQ(OSSL)_" dgst -sha256 -verify "_$$SQ(PUBFILE)_" -signature "_$$SQ(SIGFILE)_" "_$$SQ(DATAFILE)_" >/dev/null 2>&1"
	SET CMD=CMD_" ; RC=$?; "_CLEAN_" >/dev/null 2>&1; printf '__MIO_RC__:%s\n' ""$RC"""
	QUIT $$EXEC(CMD,.OUT,.ERR)
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
	QUIT '$DATA(ERR)
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
B64STD(BIN)
	NEW X,P
	SET X=$$B64EURL^MIOAUTHJWT($GET(BIN))
	SET X=$TRANSLATE(X,"-_","+/")
	SET P=$L(X)#4
	IF P=2 SET X=X_"=="
	IF P=3 SET X=X_"="
	QUIT X
