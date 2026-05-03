MIOOSPAT ; MIOOS patient registration table helpers
	QUIT
	;
INIT(ROOT)
	NEW I
	IF $GET(ROOT)="" QUIT
	DO ADDCOL(ROOT,"email","Email","text",190,"Contact",0,1)
	DO ADDCOL(ROOT,"address1","Address","text",240,"Contact",0,1)
	DO ADDCOL(ROOT,"city","City","text",150,"Contact",0,1)
	DO ADDCOL(ROOT,"state","State","select",90,"Contact",0,1)
	DO ADDCOL(ROOT,"zip","ZIP","text",100,"Contact",0,1)
	DO ADDCOL(ROOT,"consent","Consent","select",110,"Administrative",0,1)
	DO ADDCOL(ROOT,"emergencyContact","Emergency contact","text",220,"Contact",0,1)
	DO ADDCOL(ROOT,"notes","Notes","textarea",280,"Care",0,1)
	DO ADDCOL(ROOT,"updatedAt","Updated","date",130,"Administrative",0,0)
	SET @ROOT@("meta","contract")="mioos-patient-registration-v1"
	SET @ROOT@("meta","description")="Patient registration sample backed by MIOOSTBL persistence"
	SET @ROOT@("meta","hipaaNote")="HIPAA-ready architecture pattern only; deployment controls are still required."
	SET @ROOT@("features","patientRegistration")=1
	SET @ROOT@("features","auditStatus")=1
	SET @ROOT@("validation","routine")="VALPAT^MIOOSPAT"
	DO VR(ROOT,"mrn",1,32,"MRN is required")
	DO VR(ROOT,"lastName",1,80,"Last name is required")
	DO VR(ROOT,"firstName",1,80,"First name is required")
	DO VR(ROOT,"dob",1,10,"Date of birth is required") SET @ROOT@("validation","fields","dob","date")=1
	DO VR(ROOT,"phone",1,32,"Phone is required")
	DO VR(ROOT,"email",0,160,"")
	DO VR(ROOT,"address1",0,160,"")
	DO VR(ROOT,"city",0,80,"")
	DO VR(ROOT,"state",0,2,"")
	DO VR(ROOT,"zip",0,12,"")
	DO VR(ROOT,"primaryProvider",1,120,"Provider is required")
	DO VR(ROOT,"emergencyContact",0,160,"")
	DO VR(ROOT,"notes",0,2048,"")
	DO ENUM(ROOT,"status","Active","Pending","Inactive","Archived")
	DO ENUM(ROOT,"consent","Yes","No","Unknown","")
	DO STATES(ROOT,"state")
	SET I=0 FOR  SET I=$ORDER(@ROOT@("schema","columns",I)) QUIT:I'>0  DO
	. IF $GET(@ROOT@("schema","columns",I,"key"))="status" SET @ROOT@("schema","columns",I,"type")="select"
	. IF $GET(@ROOT@("schema","columns",I,"key"))="consent" SET @ROOT@("schema","columns",I,"type")="select"
	. IF $GET(@ROOT@("schema","columns",I,"key"))="state" SET @ROOT@("schema","columns",I,"type")="select"
	. IF $GET(@ROOT@("schema","columns",I,"key"))="notes" SET @ROOT@("schema","columns",I,"type")="textarea"
	. IF $GET(@ROOT@("schema","columns",I,"key"))="updatedAt" SET @ROOT@("schema","columns",I,"editable")=0
	DO ROWDEFAULTS(ROOT)
	QUIT
	;
ADDCOL(ROOT,KEY,LABEL,TYPE,WIDTH,GROUP,REQUIRED,EDITABLE)
	NEW I,N
	SET I=0 FOR  SET I=$ORDER(@ROOT@("schema","columns",I)) QUIT:I'>0  IF $GET(@ROOT@("schema","columns",I,"key"))=KEY QUIT
	IF I>0 QUIT
	SET N=$ORDER(@ROOT@("schema","columns",""),-1)+1
	SET @ROOT@("schema","columns",N,"key")=KEY
	SET @ROOT@("schema","columns",N,"data")=KEY
	SET @ROOT@("schema","columns",N,"name")=KEY
	SET @ROOT@("schema","columns",N,"label")=LABEL
	SET @ROOT@("schema","columns",N,"type")=TYPE
	SET @ROOT@("schema","columns",N,"width")=WIDTH
	SET @ROOT@("schema","columns",N,"group")=GROUP
	SET @ROOT@("schema","columns",N,"required")=+REQUIRED
	SET @ROOT@("schema","columns",N,"editable")=+EDITABLE
	SET @ROOT@("schema","columns",N,"searchable")=1
	SET @ROOT@("schema","columns",N,"orderable")=1
	SET @ROOT@("schema","columns",N,"resizable")=1
	QUIT
	;
VR(ROOT,KEY,REQ,MAX,MSG)
	IF +$GET(REQ) SET @ROOT@("validation","fields",KEY,"required")=1
	IF +$GET(MAX)>0 SET @ROOT@("validation","fields",KEY,"maxLength")=+MAX
	IF $GET(MSG)'="" SET @ROOT@("validation","fields",KEY,"message")=MSG
	QUIT
	;
ENUM(ROOT,KEY,A,B,C,D)
	KILL @ROOT@("validation","fields",KEY,"enum")
	IF $GET(A)'="" SET @ROOT@("validation","fields",KEY,"enum",1)=A
	IF $GET(B)'="" SET @ROOT@("validation","fields",KEY,"enum",2)=B
	IF $GET(C)'="" SET @ROOT@("validation","fields",KEY,"enum",3)=C
	IF $GET(D)'="" SET @ROOT@("validation","fields",KEY,"enum",4)=D
	QUIT
	;
STATES(ROOT,KEY)
	NEW LIST,I,V
	SET LIST="AL,AK,AZ,AR,CA,CO,CT,DE,DC,FL,GA,HI,IA,ID,IL,IN,KS,KY,LA,MA,MD,ME,MI,MN,MO,MS,MT,NC,ND,NE,NH,NJ,NM,NV,NY,OH,OK,OR,PA,RI,SC,SD,TN,TX,UT,VA,VT,WA,WI,WV,WY"
	KILL @ROOT@("validation","fields",KEY,"enum")
	FOR I=1:1:$LENGTH(LIST,",") SET V=$PIECE(LIST,",",I),@ROOT@("validation","fields",KEY,"enum",I)=V
	QUIT
	;
ROWDEFAULTS(ROOT)
	NEW I,MRN,FIRST,LAST
	SET I=0 FOR  SET I=$ORDER(@ROOT@("rows",I)) QUIT:I'>0  DO
	. SET MRN=$GET(@ROOT@("rows",I,"mrn")) IF MRN'="" SET @ROOT@("rows",I,"id")=MRN
	. SET FIRST=$GET(@ROOT@("rows",I,"firstName")),LAST=$GET(@ROOT@("rows",I,"lastName"))
	. IF $GET(@ROOT@("rows",I,"email"))="" SET @ROOT@("rows",I,"email")=$$EMAIL(FIRST,LAST)
	. IF $GET(@ROOT@("rows",I,"address1"))="" SET @ROOT@("rows",I,"address1")="100 Example Way"
	. IF $GET(@ROOT@("rows",I,"city"))="" SET @ROOT@("rows",I,"city")="Demo City"
	. IF $GET(@ROOT@("rows",I,"state"))="" SET @ROOT@("rows",I,"state")="NY"
	. IF $GET(@ROOT@("rows",I,"zip"))="" SET @ROOT@("rows",I,"zip")="10001"
	. IF $GET(@ROOT@("rows",I,"consent"))="" SET @ROOT@("rows",I,"consent")="Unknown"
	. IF $GET(@ROOT@("rows",I,"emergencyContact"))="" SET @ROOT@("rows",I,"emergencyContact")="Sample contact"
	. IF $GET(@ROOT@("rows",I,"notes"))="" SET @ROOT@("rows",I,"notes")="Synthetic patient registration sample row."
	. IF $GET(@ROOT@("rows",I,"updatedAt"))="" SET @ROOT@("rows",I,"updatedAt")=$PIECE($$NOWISO^MIOUTIL(),"T",1)
	. SET @ROOT@("rows",I,"_expand","title")="Patient summary"
	. SET @ROOT@("rows",I,"_expand","body")="MRN "_MRN_" — "_FIRST_" "_LAST_". Synthetic sample only."
	QUIT
	;
EMAIL(FIRST,LAST)
	NEW X
	SET X=$$LOW^MIOUTIL($GET(FIRST)_"."_$GET(LAST))
	IF X="." SET X="sample.patient"
	QUIT X_"@example.invalid"
	;
PATMETA(OUT)
	SET OUT("features","patientRegistration")=1
	SET OUT("features","auditStatus")=1
	SET OUT("patientRegistration","contract")="mioos-patient-registration-v1"
	SET OUT("patientRegistration","title")="Patient Registration"
	SET OUT("patientRegistration","notice")="Synthetic sample data only. HIPAA-ready architecture still requires deployment controls."
	SET OUT("patientRegistration","statusMessage")="Rows persist through MIOOSTBL and patient mutations are audit-marked."
	QUIT
	;
VALPAT(IN,ERR,ROOT)
	NEW OK
	SET OK=1
	IF '$DATA(IN("row")) QUIT 1
	IF '$$VALFIELD("mrn",$GET(IN("row","mrn")),.ERR,ROOT) SET OK=0
	IF '$$VALFIELD("firstName",$GET(IN("row","firstName")),.ERR,ROOT) SET OK=0
	IF '$$VALFIELD("lastName",$GET(IN("row","lastName")),.ERR,ROOT) SET OK=0
	IF '$$VALFIELD("dob",$GET(IN("row","dob")),.ERR,ROOT) SET OK=0
	IF '$$VALFIELD("phone",$GET(IN("row","phone")),.ERR,ROOT) SET OK=0
	IF '$$VALFIELD("email",$GET(IN("row","email")),.ERR,ROOT) SET OK=0
	IF '$$VALFIELD("state",$GET(IN("row","state")),.ERR,ROOT) SET OK=0
	IF '$$VALFIELD("zip",$GET(IN("row","zip")),.ERR,ROOT) SET OK=0
	IF 'OK,$GET(ERR("message"))="" SET ERR("message")="Please fix the highlighted patient registration fields"
	QUIT OK
	;
VALFIELD(KEY,VAL,ERR,ROOT)
	NEW K,V
	SET K=$GET(KEY),V=$GET(VAL)
	IF K="mrn",V'="",'$$MRNOK(V) DO ADDERR(.ERR,K,"Use letters, numbers, and hyphens for MRN") QUIT 0
	IF K="email",V'="",'$$EMAILOK(V) DO ADDERR(.ERR,K,"Enter a valid email address") QUIT 0
	IF K="phone",V'="",'$$PHONEOK(V) DO ADDERR(.ERR,K,"Enter a valid phone number") QUIT 0
	IF K="zip",V'="",'$$ZIPOK(V) DO ADDERR(.ERR,K,"Enter a valid ZIP code") QUIT 0
	IF K="state",V'="",$LENGTH(V)'=2 DO ADDERR(.ERR,K,"Use a two-letter state code") QUIT 0
	QUIT 1
	;
MRNOK(X)
	NEW I,C,Q S Q=1
	IF $LENGTH($GET(X))<3 QUIT 0
	FOR I=1:1:$LENGTH(X) SET C=$EXTRACT(X,I) IF (C'?1AN)&(C'="-") S Q=0 Q
	QUIT Q
	;
EMAILOK(X)
	IF $LENGTH($GET(X))>160 QUIT 0
	IF X'?1.E1"@"1.E1"."1.E QUIT 0
	QUIT 1
	;
PHONEOK(X)
	NEW I,C,D,BAD
	SET D=0,BAD=0
	FOR I=1:1:$LENGTH($GET(X)) SET C=$EXTRACT(X,I) DO
	. IF C?1N SET D=D+1 QUIT
	. IF " +-()."'[C SET BAD=1
	IF BAD QUIT 0
	QUIT $SELECT(D>6:1,1:0)
	;
ZIPOK(X)
	IF X?5N QUIT 1
	IF X?5N1"-"4N QUIT 1
	QUIT 0
	;
ADDERR(ERR,KEY,MSG)
	SET ERR("error")="validation_failed"
	SET ERR("field")=$GET(KEY)
	SET ERR("fieldErrors",KEY)=$GET(MSG,"Invalid value")
	IF $GET(ERR("message"))="" SET ERR("message")=$GET(MSG,"Invalid value")
	QUIT
	;
AUDPAT(STATE,CONF,ACTION,IN,OUT,OK,ERR)
	NEW USER,ROOT,N,ID,OUTCOME,DETAIL,CTX
	SET USER=$GET(STATE("principal"),"guest") IF USER="" SET USER="guest"
	SET ROOT=$NAME(^MIO("MIOOS","PATIENT","AUDIT",USER))
	SET N=$ORDER(@ROOT@(""),-1)+1
	SET ID=$GET(IN("row","mrn"),$GET(IN("row","id"),$GET(IN("rowId"),$GET(IN("id"),$GET(OUT("mutated","rowId"))))))
	SET OUTCOME=$SELECT(+OK:"success",1:"failure")
	SET DETAIL=$GET(ACTION)_$SELECT(ID'="":" "_ID,1:"")
	SET @ROOT@(N,"at")=$$NOWISO^MIOUTIL()
	SET @ROOT@(N,"action")=$GET(ACTION)
	SET @ROOT@(N,"outcome")=OUTCOME
	SET @ROOT@(N,"patientId")=ID
	SET @ROOT@(N,"principal")=USER
	SET @ROOT@(N,"message")=$GET(OUT("message"),$GET(ERR("message")))
	KILL CTX SET CTX("route")="patient-registration-table"
	DO EVENT^MIOOSAUD("patient.registration.table",.CTX,.STATE,DETAIL,OUTCOME,ID,"mioos")
	QUIT
	;
	;