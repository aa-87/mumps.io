MIOOSPAT ; MIOOS patient registration table helpers
	QUIT
	;
INIT(ROOT)
	NEW I
	IF $GET(ROOT)="" QUIT
	DO ADDCOL(ROOT,"email","Email","text",190,"Contact",1,1)
	DO ADDCOL(ROOT,"address1","Address","text",240,"Contact",0,1)
	DO ADDCOL(ROOT,"city","City","text",150,"Contact",0,1)
	DO ADDCOL(ROOT,"state","State","select",90,"Contact",1,1)
	DO ADDCOL(ROOT,"zip","ZIP","text",100,"Contact",1,1)
	DO ADDCOL(ROOT,"emergencyContact","Emergency contact","text",220,"Emergency",0,1)
	DO ADDCOL(ROOT,"emergencyPhone","Emergency phone","text",150,"Emergency",0,1)
	DO ADDCOL(ROOT,"consent","Consent","select",110,"Consent",1,1)
	DO ADDCOL(ROOT,"consentDate","Consent date","date",130,"Consent",0,1)
	DO ADDCOL(ROOT,"notes","Notes","textarea",280,"Notes",0,1)
	DO ADDCOL(ROOT,"createdAt","Created","date",130,"Audit",0,0)
	DO ADDCOL(ROOT,"updatedAt","Updated","date",130,"Audit",0,0)
	DO ADDCOL(ROOT,"updatedBy","Updated by","text",130,"Audit",0,0)
	SET @ROOT@("meta","contract")="mioos-patient-registration-v2"
	SET @ROOT@("meta","description")="Patient registration intake workflow backed by MIOOSTBL persistence"
	SET @ROOT@("meta","hipaaNote")="HIPAA-ready architecture pattern only; deployment controls are still required."
	SET @ROOT@("features","patientRegistration")=1
	SET @ROOT@("features","auditStatus")=1
	SET @ROOT@("features","intakeWorkflow")=1
	SET @ROOT@("features","duplicateDetection")=1
	SET @ROOT@("features","statusTransitions")=1
	SET @ROOT@("validation","routine")="VALPAT^MIOOSPAT"
	DO VR(ROOT,"mrn",1,32,"MRN is required")
	DO VR(ROOT,"lastName",1,80,"Last name is required")
	DO VR(ROOT,"firstName",1,80,"First name is required")
	DO VR(ROOT,"dob",1,10,"Date of birth is required") SET @ROOT@("validation","fields","dob","date")=1
	DO VR(ROOT,"phone",1,32,"Phone is required")
	DO VR(ROOT,"email",1,160,"Email is required")
	DO VR(ROOT,"address1",0,160,"")
	DO VR(ROOT,"city",0,80,"")
	DO VR(ROOT,"state",1,2,"State is required")
	DO VR(ROOT,"zip",1,12,"ZIP is required")
	DO VR(ROOT,"primaryProvider",1,120,"Provider is required")
	DO VR(ROOT,"emergencyContact",0,160,"")
	DO VR(ROOT,"emergencyPhone",0,32,"")
	DO VR(ROOT,"status",1,32,"Status is required")
	DO VR(ROOT,"consent",1,16,"Consent is required")
	DO VR(ROOT,"consentDate",0,10,"") SET @ROOT@("validation","fields","consentDate","date")=1
	DO VR(ROOT,"notes",0,2048,"")
	DO ENUM(ROOT,"status","Draft","Pending Review","Active","Inactive")
	DO ENUM(ROOT,"consent","Yes","No","Unknown","")
	DO STATES(ROOT,"state")
	SET I=0 FOR  SET I=$ORDER(@ROOT@("schema","columns",I)) QUIT:I'>0  DO
	. IF $GET(@ROOT@("schema","columns",I,"key"))="status" SET @ROOT@("schema","columns",I,"type")="select"
	. IF $GET(@ROOT@("schema","columns",I,"key"))="consent" SET @ROOT@("schema","columns",I,"type")="select"
	. IF $GET(@ROOT@("schema","columns",I,"key"))="state" SET @ROOT@("schema","columns",I,"type")="select"
	. IF $GET(@ROOT@("schema","columns",I,"key"))="notes" SET @ROOT@("schema","columns",I,"type")="textarea"
	. IF $GET(@ROOT@("schema","columns",I,"key"))="createdAt" SET @ROOT@("schema","columns",I,"editable")=0
	. IF $GET(@ROOT@("schema","columns",I,"key"))="updatedAt" SET @ROOT@("schema","columns",I,"editable")=0
	. IF $GET(@ROOT@("schema","columns",I,"key"))="updatedBy" SET @ROOT@("schema","columns",I,"editable")=0
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
	NEW I,MRN,FIRST,LAST,TODAY
	SET TODAY=$$TODAY()
	SET I=0 FOR  SET I=$ORDER(@ROOT@("rows",I)) QUIT:I'>0  DO
	. SET MRN=$GET(@ROOT@("rows",I,"mrn")) IF MRN'="" SET @ROOT@("rows",I,"id")=MRN
	. SET FIRST=$GET(@ROOT@("rows",I,"firstName")),LAST=$GET(@ROOT@("rows",I,"lastName"))
	. IF $GET(@ROOT@("rows",I,"status"))="Pending" SET @ROOT@("rows",I,"status")="Pending Review"
	. IF $GET(@ROOT@("rows",I,"status"))="" SET @ROOT@("rows",I,"status")="Draft"
	. IF $GET(@ROOT@("rows",I,"email"))="" SET @ROOT@("rows",I,"email")=$$EMAIL(FIRST,LAST)
	. IF $GET(@ROOT@("rows",I,"address1"))="" SET @ROOT@("rows",I,"address1")="100 Example Way"
	. IF $GET(@ROOT@("rows",I,"city"))="" SET @ROOT@("rows",I,"city")="Demo City"
	. IF $GET(@ROOT@("rows",I,"state"))="" SET @ROOT@("rows",I,"state")="NY"
	. IF $GET(@ROOT@("rows",I,"zip"))="" SET @ROOT@("rows",I,"zip")="10001"
	. IF $GET(@ROOT@("rows",I,"consent"))="" SET @ROOT@("rows",I,"consent")=$SELECT($GET(@ROOT@("rows",I,"status"))="Active":"Yes",1:"Unknown")
	. IF $GET(@ROOT@("rows",I,"consent"))="Yes",$GET(@ROOT@("rows",I,"consentDate"))="" SET @ROOT@("rows",I,"consentDate")=TODAY
	. IF $GET(@ROOT@("rows",I,"emergencyContact"))="" SET @ROOT@("rows",I,"emergencyContact")="Sample contact"
	. IF $GET(@ROOT@("rows",I,"emergencyPhone"))="" SET @ROOT@("rows",I,"emergencyPhone")="555-0199"
	. IF $GET(@ROOT@("rows",I,"notes"))="" SET @ROOT@("rows",I,"notes")="Synthetic patient registration sample row."
	. IF $GET(@ROOT@("rows",I,"createdAt"))="" SET @ROOT@("rows",I,"createdAt")=TODAY
	. IF $GET(@ROOT@("rows",I,"updatedAt"))="" SET @ROOT@("rows",I,"updatedAt")=TODAY
	. DO ROWEXP(ROOT,I)
	QUIT
	;
ROWEXP(ROOT,I)
	NEW MRN,FIRST,LAST,STATUS,DUP
	SET MRN=$GET(@ROOT@("rows",I,"mrn")),FIRST=$GET(@ROOT@("rows",I,"firstName")),LAST=$GET(@ROOT@("rows",I,"lastName")),STATUS=$GET(@ROOT@("rows",I,"status"))
	SET DUP=$$DUPDEM(ROOT,FIRST,LAST,$GET(@ROOT@("rows",I,"dob")),MRN)
	SET @ROOT@("rows",I,"_expand","title")="Patient intake summary"
	SET @ROOT@("rows",I,"_expand","body")="MRN "_MRN_" — "_FIRST_" "_LAST_". Status: "_STATUS_$SELECT(DUP'="":". Duplicate candidate: "_DUP,1:".")
	QUIT
	;
EMAIL(FIRST,LAST)
	NEW X
	SET X=$$LOW^MIOUTIL($GET(FIRST)_"."_$GET(LAST))
	IF X="." SET X="sample.patient"
	QUIT X_"@example.invalid"
	;
PATMETA(OUT,ROOT)
	NEW DUPS
	SET OUT("features","patientRegistration")=1
	SET OUT("features","auditStatus")=1
	SET OUT("features","validationSummary")=1
	SET OUT("features","duplicateDetection")=1
	SET OUT("patientRegistration","contract")="mioos-patient-registration-v2"
	SET OUT("patientRegistration","title")="Patient Registration"
	SET OUT("patientRegistration","notice")="Synthetic sample data only. HIPAA-ready architecture still requires deployment controls."
	SET OUT("patientRegistration","statusMessage")="Guided intake uses server-side MUMPS validation, duplicate warnings, status transitions, and audit markers."
	SET OUT("patientRegistration","workflow",1)="Draft"
	SET OUT("patientRegistration","workflow",2)="Pending Review"
	SET OUT("patientRegistration","workflow",3)="Active"
	SET OUT("patientRegistration","workflow",4)="Inactive"
	SET OUT("patientRegistration","required",1)="Demographics"
	SET OUT("patientRegistration","required",2)="Contact information"
	SET OUT("patientRegistration","required",3)="Consent/status"
	IF $GET(ROOT)'="" SET DUPS=$$DUPCOUNT(ROOT),OUT("patientRegistration","duplicateCandidateCount")=DUPS
	QUIT
	;
VALPAT(IN,ERR,ROOT)
	NEW OK,ID,OLD,STATUS,CONSENT
	SET OK=1
	IF '$DATA(IN("row")) QUIT 1
	SET ID=$GET(IN("row","id"),$GET(IN("row","mrn")))
	IF ID="" SET ID=$GET(IN("row","mrn"))
	SET OLD=$$OLDSTAT(ROOT,ID)
	SET STATUS=$GET(IN("row","status")),CONSENT=$GET(IN("row","consent"))
	IF '$$VALFIELD("mrn",$GET(IN("row","mrn")),.ERR,ROOT) SET OK=0
	IF '$$VALFIELD("firstName",$GET(IN("row","firstName")),.ERR,ROOT) SET OK=0
	IF '$$VALFIELD("lastName",$GET(IN("row","lastName")),.ERR,ROOT) SET OK=0
	IF '$$VALFIELD("dob",$GET(IN("row","dob")),.ERR,ROOT) SET OK=0
	IF '$$VALFIELD("phone",$GET(IN("row","phone")),.ERR,ROOT) SET OK=0
	IF '$$VALFIELD("email",$GET(IN("row","email")),.ERR,ROOT) SET OK=0
	IF '$$VALFIELD("state",$GET(IN("row","state")),.ERR,ROOT) SET OK=0
	IF '$$VALFIELD("zip",$GET(IN("row","zip")),.ERR,ROOT) SET OK=0
	IF '$$VALFIELD("emergencyPhone",$GET(IN("row","emergencyPhone")),.ERR,ROOT) SET OK=0
	IF '$$VALFIELD("consentDate",$GET(IN("row","consentDate")),.ERR,ROOT) SET OK=0
	IF $GET(IN("row","dob"))'="",$GET(IN("row","dob"))]$$TODAY() DO ADDERR(.ERR,"dob","DOB cannot be in the future") SET OK=0
	IF $GET(IN("row","mrn"))'="",$$DUPMRN(ROOT,$GET(IN("row","mrn")),ID) DO ADDERR(.ERR,"mrn","MRN already exists") SET OK=0
	IF '$$STATUSOK(OLD,STATUS,.ERR) SET OK=0
	IF STATUS="Active",CONSENT'="Yes" DO ADDERR(.ERR,"consent","Consent must be Yes before activation") SET OK=0
	IF CONSENT="Yes",$GET(IN("row","consentDate"))="" DO ADDERR(.ERR,"consentDate","Consent date is required when consent is Yes") SET OK=0
	IF 'OK,$GET(ERR("message"))="" SET ERR("message")="Please fix the highlighted patient registration fields"
	QUIT OK
	;
VALFIELD(KEY,VAL,ERR,ROOT)
	NEW K,V
	SET K=$GET(KEY),V=$GET(VAL)
	IF K="mrn",V'="",'$$MRNOK(V) DO ADDERR(.ERR,K,"Use letters, numbers, and hyphens for MRN") QUIT 0
	IF K="email",V'="",'$$EMAILOK(V) DO ADDERR(.ERR,K,"Enter a valid email address") QUIT 0
	IF K="phone",V'="",'$$PHONEOK(V) DO ADDERR(.ERR,K,"Enter a valid phone number") QUIT 0
	IF K="emergencyPhone",V'="",'$$PHONEOK(V) DO ADDERR(.ERR,K,"Enter a valid emergency phone number") QUIT 0
	IF K="zip",V'="",'$$ZIPOK(V) DO ADDERR(.ERR,K,"Enter a valid ZIP code") QUIT 0
	IF K="state",V'="",$LENGTH(V)'=2 DO ADDERR(.ERR,K,"Use a two-letter state code") QUIT 0
	IF K="dob",V'="",'$$DATEOK^MIOOSTBL(V) DO ADDERR(.ERR,K,"Use a valid YYYY-MM-DD date") QUIT 0
	IF K="consentDate",V'="",'$$DATEOK^MIOOSTBL(V) DO ADDERR(.ERR,K,"Use a valid consent date") QUIT 0
	IF K="dob",V'="",V]$$TODAY() DO ADDERR(.ERR,K,"DOB cannot be in the future") QUIT 0
	QUIT 1
	;
VALSTATCELL(ID,VAL,ERR,ROOT)
	NEW OLD
	SET OLD=$$OLDSTAT(ROOT,$GET(ID))
	QUIT $$STATUSOK(OLD,$GET(VAL),.ERR)
	;
STATUSOK(FROM,TO,ERR)
	SET FROM=$$STATUS(FROM),TO=$$STATUS(TO)
	IF TO="" DO ADDERR(.ERR,"status","Status is required") QUIT 0
	IF FROM="" QUIT 1
	IF FROM=TO QUIT 1
	IF FROM="Draft",TO="Pending Review" QUIT 1
	IF FROM="Draft",TO="Inactive" QUIT 1
	IF FROM="Pending Review",TO="Active" QUIT 1
	IF FROM="Pending Review",TO="Draft" QUIT 1
	IF FROM="Pending Review",TO="Inactive" QUIT 1
	IF FROM="Active",TO="Inactive" QUIT 1
	IF FROM="Active",TO="Pending Review" QUIT 1
	IF FROM="Inactive",TO="Active" QUIT 1
	DO ADDERR(.ERR,"status","Invalid status transition from "_FROM_" to "_TO)
	QUIT 0
	;
STATUS(X)
	NEW Y
	SET Y=$GET(X)
	IF Y="Pending" SET Y="Pending Review"
	QUIT Y
	;
OLDSTAT(ROOT,ID)
	NEW I,OLD
	SET OLD="",I=0 FOR  SET I=$ORDER(@ROOT@("rows",I)) QUIT:I'>0!(OLD'="")  DO
	. IF $GET(@ROOT@("rows",I,"id"))=$GET(ID)!($GET(@ROOT@("rows",I,"mrn"))=$GET(ID)) SET OLD=$GET(@ROOT@("rows",I,"status"))
	QUIT $$STATUS(OLD)
	;
POSTPAT(ROOT,ACTION,IN,OUT,STATE)
	NEW ID,I,KEY,USER,TODAY,DUP
	IF $GET(ACTION)'="row.save",$GET(ACTION)'="row.add",$GET(ACTION)'="row.update",$GET(ACTION)'="cell.save" QUIT
	SET USER=$GET(STATE("principal"),"guest") IF USER="" SET USER="guest"
	SET ID=$GET(IN("row","id"),$GET(IN("row","mrn"),$GET(IN("rowId"),$GET(IN("id")))))
	IF ID="" QUIT
	SET TODAY=$$TODAY()
	SET I=0 FOR  SET I=$ORDER(@ROOT@("rows",I)) QUIT:I'>0  DO
	. IF $GET(@ROOT@("rows",I,"id"))'=ID,$GET(@ROOT@("rows",I,"mrn"))'=ID QUIT
	. IF $GET(@ROOT@("rows",I,"status"))="" SET @ROOT@("rows",I,"status")="Draft"
	. IF $GET(@ROOT@("rows",I,"createdAt"))="" SET @ROOT@("rows",I,"createdAt")=TODAY
	. IF $GET(@ROOT@("rows",I,"createdBy"))="" SET @ROOT@("rows",I,"createdBy")=USER
	. SET @ROOT@("rows",I,"updatedAt")=TODAY
	. SET @ROOT@("rows",I,"updatedBy")=USER
	. IF $GET(@ROOT@("rows",I,"consent"))="Yes",$GET(@ROOT@("rows",I,"consentDate"))="" SET @ROOT@("rows",I,"consentDate")=TODAY
	. DO ROWEXP(ROOT,I)
	DO DUPWARN(ROOT,.IN,.OUT)
	QUIT
	;
DUPWARN(ROOT,IN,OUT)
	NEW ID,MRN,FIRST,LAST,DOB,EMAIL,PHONE,DUP,N
	SET ID=$GET(IN("row","id"),$GET(IN("row","mrn"),$GET(IN("rowId"),$GET(IN("id")))))
	SET MRN=$GET(IN("row","mrn")),FIRST=$GET(IN("row","firstName")),LAST=$GET(IN("row","lastName")),DOB=$GET(IN("row","dob")),EMAIL=$GET(IN("row","email")),PHONE=$GET(IN("row","phone"))
	SET N=0
	SET DUP=$$DUPDEM(ROOT,FIRST,LAST,DOB,ID) IF DUP'="" SET N=N+1,OUT("warnings","duplicateCandidates",N,"reason")="same_name_dob",OUT("warnings","duplicateCandidates",N,"patientId")=DUP
	SET DUP=$$DUPCONTACT(ROOT,"email",EMAIL,ID) IF DUP'="" SET N=N+1,OUT("warnings","duplicateCandidates",N,"reason")="same_email",OUT("warnings","duplicateCandidates",N,"patientId")=DUP
	SET DUP=$$DUPCONTACT(ROOT,"phone",PHONE,ID) IF DUP'="" SET N=N+1,OUT("warnings","duplicateCandidates",N,"reason")="same_phone",OUT("warnings","duplicateCandidates",N,"patientId")=DUP
	IF N>0 SET OUT("warnings","duplicateCount")=N
	QUIT
	;
DUPCOUNT(ROOT)
	NEW I,COUNT,DUP
	SET COUNT=0,I=0 FOR  SET I=$ORDER(@ROOT@("rows",I)) QUIT:I'>0  DO
	. SET DUP=$$DUPDEM(ROOT,$GET(@ROOT@("rows",I,"firstName")),$GET(@ROOT@("rows",I,"lastName")),$GET(@ROOT@("rows",I,"dob")),$GET(@ROOT@("rows",I,"id")))
	. IF DUP'="" SET COUNT=COUNT+1
	QUIT COUNT
	;
DUPMRN(ROOT,MRN,ID)
	NEW I,FOUND,CAN
	SET FOUND=0,CAN=$$CANON(MRN)
	IF CAN="" QUIT 0
	SET I=0 FOR  SET I=$ORDER(@ROOT@("rows",I)) QUIT:I'>0!(FOUND)  DO
	. IF $GET(@ROOT@("rows",I,"id"))=$GET(ID)!($GET(@ROOT@("rows",I,"mrn"))=$GET(ID)) QUIT
	. IF $$CANON($GET(@ROOT@("rows",I,"mrn")))=CAN SET FOUND=1
	QUIT FOUND
	;
DUPDEM(ROOT,FIRST,LAST,DOB,ID)
	NEW I,FOUND,KEY
	SET FOUND=""
	IF $GET(FIRST)=""!($GET(LAST)="")!($GET(DOB)="") QUIT ""
	SET KEY=$$CANON(FIRST)_"|"_$$CANON(LAST)_"|"_$GET(DOB)
	SET I=0 FOR  SET I=$ORDER(@ROOT@("rows",I)) QUIT:I'>0!(FOUND'="")  DO
	. IF $GET(@ROOT@("rows",I,"id"))=$GET(ID)!($GET(@ROOT@("rows",I,"mrn"))=$GET(ID)) QUIT
	. IF ($$CANON($GET(@ROOT@("rows",I,"firstName")))_"|"_$$CANON($GET(@ROOT@("rows",I,"lastName")))_"|"_$GET(@ROOT@("rows",I,"dob")))=KEY SET FOUND=$GET(@ROOT@("rows",I,"id"),$GET(@ROOT@("rows",I,"mrn")))
	QUIT FOUND
	;
DUPCONTACT(ROOT,KEY,VAL,ID)
	NEW I,FOUND,CAN
	SET FOUND="",CAN=$$CANON($GET(VAL))
	IF CAN="" QUIT ""
	SET I=0 FOR  SET I=$ORDER(@ROOT@("rows",I)) QUIT:I'>0!(FOUND'="")  DO
	. IF $GET(@ROOT@("rows",I,"id"))=$GET(ID)!($GET(@ROOT@("rows",I,"mrn"))=$GET(ID)) QUIT
	. IF $$CANON($GET(@ROOT@("rows",I,KEY)))=CAN SET FOUND=$GET(@ROOT@("rows",I,"id"),$GET(@ROOT@("rows",I,"mrn")))
	QUIT FOUND
	;
CANON(X)
	QUIT $$LOW^MIOUTIL($$TRIM^MIOUTIL($GET(X)))
	;
TODAY()
	QUIT $PIECE($$NOWISO^MIOUTIL(),"T",1)
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
	NEW USER,ROOT,N,ID,OUTCOME,DETAIL,CTX,STATUS
	SET USER=$GET(STATE("principal"),"guest") IF USER="" SET USER="guest"
	SET ROOT=$NAME(^MIO("MIOOS","PATIENT","AUDIT",USER))
	SET N=$ORDER(@ROOT@(""),-1)+1
	SET ID=$GET(IN("row","mrn"),$GET(IN("row","id"),$GET(IN("rowId"),$GET(IN("id"),$GET(OUT("mutated","rowId"))))))
	SET STATUS=$GET(IN("row","status"),$GET(IN("value")))
	SET OUTCOME=$SELECT(+OK:"success",1:"failure")
	SET DETAIL=$GET(ACTION)_$SELECT(ID'="":" "_ID,1:"")_$SELECT(STATUS'="":" status="_STATUS,1:"")
	SET @ROOT@(N,"at")=$$NOWISO^MIOUTIL()
	SET @ROOT@(N,"action")=$GET(ACTION)
	SET @ROOT@(N,"outcome")=OUTCOME
	SET @ROOT@(N,"patientId")=ID
	SET @ROOT@(N,"status")=STATUS
	SET @ROOT@(N,"principal")=USER
	SET @ROOT@(N,"message")=$GET(OUT("message"),$GET(ERR("message")))
	KILL CTX SET CTX("route")="patient-registration-table"
	DO EVENT^MIOOSAUD("patient.registration.table",.CTX,.STATE,DETAIL,OUTCOME,ID,"mioos")
	QUIT
	;
