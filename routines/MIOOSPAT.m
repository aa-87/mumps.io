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
	DO ADDCOL(ROOT,"reviewQueue","Review queue","select",150,"Review",0,0)
	DO ADDCOL(ROOT,"duplicateStatus","Duplicate status","select",150,"Review",0,1)
	DO ADDCOL(ROOT,"duplicateOf","Duplicate of","text",130,"Review",0,1)
	DO ADDCOL(ROOT,"missingConsent","Missing consent","boolean",120,"Review",0,0)
	DO ADDCOL(ROOT,"reviewNote","Review note","textarea",260,"Review",0,1)
	DO ADDCOL(ROOT,"lastReviewAt","Last review","date",130,"Review",0,0)
	DO ADDCOL(ROOT,"reviewedBy","Reviewed by","text",130,"Review",0,0)
	DO ADDCOL(ROOT,"notes","Notes","textarea",280,"Notes",0,1)
	DO ADDCOL(ROOT,"createdAt","Created","date",130,"Audit",0,0)
	DO ADDCOL(ROOT,"createdBy","Created by","text",130,"Audit",0,0)
	DO ADDCOL(ROOT,"updatedAt","Updated","date",130,"Audit",0,0)
	DO ADDCOL(ROOT,"updatedBy","Updated by","text",130,"Audit",0,0)
	SET @ROOT@("meta","contract")="mioos-patient-registration-v4"
	SET @ROOT@("meta","description")="Patient registration review queues, search, and duplicate-resolution workflow backed by MIOOSTBL persistence"
	SET @ROOT@("meta","hipaaNote")="HIPAA-ready architecture pattern only; deployment controls are still required."
	SET @ROOT@("features","patientRegistration")=1
	SET @ROOT@("features","auditStatus")=1
	SET @ROOT@("features","intakeWorkflow")=1
	SET @ROOT@("features","duplicateDetection")=1
	SET @ROOT@("features","statusTransitions")=1
	SET @ROOT@("features","reviewQueues")=1
	SET @ROOT@("features","duplicateResolution")=1
	SET @ROOT@("features","patientSearch")=1
	SET @ROOT@("features","importExport")=1
	SET @ROOT@("features","reconciliation")=1
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
	DO VR(ROOT,"reviewNote",0,2048,"")
	DO VR(ROOT,"notes",0,2048,"")
	DO ENUM(ROOT,"status","Draft","Pending Review","Active","Inactive")
	DO ENUM(ROOT,"consent","Yes","No","Unknown","")
	DO ENUM(ROOT,"duplicateStatus","None","Candidate","Duplicate","Not duplicate")
	DO STATES(ROOT,"state")
	SET I=0 FOR  SET I=$ORDER(@ROOT@("schema","columns",I)) QUIT:I'>0  DO
	. IF $GET(@ROOT@("schema","columns",I,"key"))="status" SET @ROOT@("schema","columns",I,"type")="select"
	. IF $GET(@ROOT@("schema","columns",I,"key"))="consent" SET @ROOT@("schema","columns",I,"type")="select"
	. IF $GET(@ROOT@("schema","columns",I,"key"))="state" SET @ROOT@("schema","columns",I,"type")="select"
	. IF $GET(@ROOT@("schema","columns",I,"key"))="duplicateStatus" SET @ROOT@("schema","columns",I,"type")="select"
	. IF $GET(@ROOT@("schema","columns",I,"key"))="notes" SET @ROOT@("schema","columns",I,"type")="textarea"
	. IF $GET(@ROOT@("schema","columns",I,"key"))="reviewNote" SET @ROOT@("schema","columns",I,"type")="textarea"
	. IF $GET(@ROOT@("schema","columns",I,"key"))="reviewQueue" SET @ROOT@("schema","columns",I,"editable")=0
	. IF $GET(@ROOT@("schema","columns",I,"key"))="missingConsent" SET @ROOT@("schema","columns",I,"editable")=0
	. IF $GET(@ROOT@("schema","columns",I,"key"))="createdAt" SET @ROOT@("schema","columns",I,"editable")=0
	. IF $GET(@ROOT@("schema","columns",I,"key"))="createdBy" SET @ROOT@("schema","columns",I,"editable")=0
	. IF $GET(@ROOT@("schema","columns",I,"key"))="updatedAt" SET @ROOT@("schema","columns",I,"editable")=0
	. IF $GET(@ROOT@("schema","columns",I,"key"))="updatedBy" SET @ROOT@("schema","columns",I,"editable")=0
	. IF $GET(@ROOT@("schema","columns",I,"key"))="lastReviewAt" SET @ROOT@("schema","columns",I,"editable")=0
	. IF $GET(@ROOT@("schema","columns",I,"key"))="reviewedBy" SET @ROOT@("schema","columns",I,"editable")=0
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
	. IF $GET(@ROOT@("rows",I,"consent"))="" SET @ROOT@("rows",I,"consent")=$SELECT($GET(@ROOT@("rows",I,"status"))="Active":"Yes",$GET(@ROOT@("rows",I,"status"))="Pending Review":"No",1:"Unknown")
	. IF $GET(@ROOT@("rows",I,"consent"))="Yes",$GET(@ROOT@("rows",I,"consentDate"))="" SET @ROOT@("rows",I,"consentDate")=TODAY
	. IF $GET(@ROOT@("rows",I,"emergencyContact"))="" SET @ROOT@("rows",I,"emergencyContact")="Sample contact"
	. IF $GET(@ROOT@("rows",I,"emergencyPhone"))="" SET @ROOT@("rows",I,"emergencyPhone")="555-0199"
	. IF $GET(@ROOT@("rows",I,"notes"))="" SET @ROOT@("rows",I,"notes")="Synthetic patient registration sample row."
	. IF $GET(@ROOT@("rows",I,"createdAt"))="" SET @ROOT@("rows",I,"createdAt")=TODAY
	. IF $GET(@ROOT@("rows",I,"updatedAt"))="" SET @ROOT@("rows",I,"updatedAt")=TODAY
	. DO REVIEWROW(ROOT,I)
	QUIT
	;
REVIEWROW(ROOT,I)
	NEW MRN,FIRST,LAST,DOB,DUP,STATUS,CONSENT,MISS
	SET MRN=$GET(@ROOT@("rows",I,"mrn"),$GET(@ROOT@("rows",I,"id")))
	SET FIRST=$GET(@ROOT@("rows",I,"firstName")),LAST=$GET(@ROOT@("rows",I,"lastName")),DOB=$GET(@ROOT@("rows",I,"dob"))
	SET STATUS=$$STATUS($GET(@ROOT@("rows",I,"status"))) SET @ROOT@("rows",I,"status")=STATUS
	SET CONSENT=$GET(@ROOT@("rows",I,"consent"))
	SET MISS=$SELECT(STATUS="Active"&(CONSENT'="Yes"):"true",CONSENT="Unknown":"true",1:"false")
	SET @ROOT@("rows",I,"missingConsent")=MISS
	SET DUP=$$DUPDEM(ROOT,FIRST,LAST,DOB,MRN)
	IF $GET(@ROOT@("rows",I,"duplicateStatus"))="" SET @ROOT@("rows",I,"duplicateStatus")=$SELECT(DUP'="":"Candidate",1:"None")
	IF DUP'="",$GET(@ROOT@("rows",I,"duplicateOf"))="" SET @ROOT@("rows",I,"duplicateOf")=DUP
	SET @ROOT@("rows",I,"reviewQueue")=$$QUEUE(ROOT,I)
	DO ROWEXP(ROOT,I)
	QUIT
	;
QUEUE(ROOT,I)
	NEW STATUS,DUP,MISS
	SET STATUS=$$STATUS($GET(@ROOT@("rows",I,"status")))
	SET DUP=$GET(@ROOT@("rows",I,"duplicateStatus")),MISS=$$LOW^MIOUTIL($GET(@ROOT@("rows",I,"missingConsent")))
	IF DUP="Duplicate" QUIT "Needs Correction"
	IF DUP="Candidate" QUIT "Needs Correction"
	IF MISS="true" QUIT "Needs Correction"
	IF STATUS="Draft" QUIT "Drafts"
	IF STATUS="Pending Review" QUIT "Pending Review"
	IF STATUS="Active" QUIT "Active"
	IF STATUS="Inactive" QUIT "Inactive"
	QUIT "Needs Correction"
	;
ROWEXP(ROOT,I)
	NEW MRN,FIRST,LAST,STATUS,DUP,QUEUE
	SET MRN=$GET(@ROOT@("rows",I,"mrn")),FIRST=$GET(@ROOT@("rows",I,"firstName")),LAST=$GET(@ROOT@("rows",I,"lastName"))
	SET STATUS=$GET(@ROOT@("rows",I,"status")),DUP=$GET(@ROOT@("rows",I,"duplicateOf")),QUEUE=$GET(@ROOT@("rows",I,"reviewQueue"))
	SET @ROOT@("rows",I,"_expand","title")="Patient review summary"
	SET @ROOT@("rows",I,"_expand","body")="MRN "_MRN_" — "_FIRST_" "_LAST_". Status: "_STATUS_". Queue: "_QUEUE_$SELECT(DUP'="":". Duplicate candidate: "_DUP,1:".")
	QUIT
	;
EMAIL(FIRST,LAST)
	NEW X
	SET X=$$LOW^MIOUTIL($GET(FIRST)_"."_$GET(LAST))
	IF X="." SET X="sample.patient"
	QUIT X_"@example.invalid"
	;
PATMETA(OUT,ROOT)
	NEW Q
	SET OUT("features","patientRegistration")=1
	SET OUT("features","auditStatus")=1
	SET OUT("features","validationSummary")=1
	SET OUT("features","duplicateDetection")=1
	SET OUT("features","reviewQueues")=1
	SET OUT("features","duplicateResolution")=1
	SET OUT("features","patientSearch")=1
	SET OUT("features","intakeWorkflow")=1
	SET OUT("features","importExport")=1
	SET OUT("features","reconciliation")=1
	SET OUT("features","statusTransitions")=1
	SET OUT("patientRegistration","contract")="mioos-patient-registration-v4"
	SET OUT("patientRegistration","title")="Patient Registration"
	SET OUT("patientRegistration","entryPoint")="Start Menu > Patient Registration or App Catalogue > Healthcare > Patient Registration"
	SET OUT("patientRegistration","notice")="Synthetic sample data only. HIPAA-ready architecture still requires deployment controls."
	SET OUT("patientRegistration","statusMessage")="Search patients, triage review queues, and resolve duplicate candidates through server-side MUMPS actions."
	SET OUT("patientRegistration","workflow",1)="Draft"
	SET OUT("patientRegistration","workflow",2)="Pending Review"
	SET OUT("patientRegistration","workflow",3)="Needs Correction"
	SET OUT("patientRegistration","workflow",4)="Active"
	KILL Q DO QUEUEMETA(ROOT,.Q)
	MERGE OUT("patientRegistration","reviewQueues")=Q("reviewQueues")
	MERGE OUT("patientRegistration","queueCounts")=Q("queueCounts")
	SET OUT("patientRegistration","duplicateCandidateCount")=+$GET(Q("queueCounts","duplicateCandidates"))
	SET OUT("rowActions",4,"key")="patient.duplicate.mark",OUT("rowActions",4,"label")="Mark duplicate"
	SET OUT("rowActions",5,"key")="patient.duplicate.clear",OUT("rowActions",5,"label")="Not duplicate"
	SET OUT("rowActions",6,"key")="patient.review.needs-correction",OUT("rowActions",6,"label")="Needs correction"
	SET OUT("rowActions",7,"key")="patient.review.pending",OUT("rowActions",7,"label")="Send to review"
	SET OUT("rowActions",8,"key")="patient.review.active",OUT("rowActions",8,"label")="Mark active"
	SET OUT("rowActions",9,"key")="patient.review.inactive",OUT("rowActions",9,"label")="Mark inactive"
	SET OUT("bulkActions",3,"key")="patient.bulk.pending",OUT("bulkActions",3,"label")="Send selected to review"
	SET OUT("bulkActions",4,"key")="patient.bulk.needs-correction",OUT("bulkActions",4,"label")="Flag selected"
	SET OUT("bulkActions",5,"key")="patient.bulk.active",OUT("bulkActions",5,"label")="Mark selected active"
	SET OUT("bulkActions",6,"key")="patient.export.selected",OUT("bulkActions",6,"label")="Export selected patients"
	QUIT
	;
QUEUEMETA(ROOT,Q)
	NEW I,KEY,COUNT,DUP
	KILL Q
	DO QDEF(.Q,1,"All","","")
	DO QDEF(.Q,2,"Drafts","reviewQueue","Drafts")
	DO QDEF(.Q,3,"Pending Review","reviewQueue","Pending Review")
	DO QDEF(.Q,4,"Needs Correction","reviewQueue","Needs Correction")
	DO QDEF(.Q,5,"Active","reviewQueue","Active")
	SET I=0 FOR  SET I=$ORDER(@ROOT@("rows",I)) QUIT:I'>0  DO
	. DO REVIEWROW(ROOT,I)
	. SET KEY=$GET(@ROOT@("rows",I,"reviewQueue")) IF KEY="" SET KEY="Needs Correction"
	. SET Q("queueCounts",KEY)=+$GET(Q("queueCounts",KEY))+1
	. IF $GET(@ROOT@("rows",I,"duplicateStatus"))="Candidate" SET Q("queueCounts","duplicateCandidates")=+$GET(Q("queueCounts","duplicateCandidates"))+1
	QUIT
	;
QDEF(Q,N,LABEL,FIELD,VALUE)
	SET Q("reviewQueues",N,"key")=$SELECT(VALUE'="":VALUE,1:"all")
	SET Q("reviewQueues",N,"label")=LABEL
	IF FIELD'="" SET Q("reviewQueues",N,"filter",FIELD,"mode")="include",Q("reviewQueues",N,"filter",FIELD,"value")=VALUE,Q("reviewQueues",N,"filter",FIELD,"values",1)=VALUE
	QUIT
	;
ADDDEF(ROOT,ACTION,IN,STATE)
	NEW A,Q,MRN
	SET A=$$LOW^MIOUTIL($GET(ACTION))
	IF A'="row.save",A'="row.add",A'="row.update" QUIT
	SET Q=$GET(IN("reviewQueue"),$GET(IN("row","reviewQueue")))
	IF Q="" SET Q=$GET(IN("queue"))
	IF Q="" QUIT
	IF $GET(IN("row","status"))="" DO
	. IF Q="Pending Review" SET IN("row","status")="Pending Review"
	. IF Q="Active" SET IN("row","status")="Active"
	. IF Q="Drafts" SET IN("row","status")="Draft"
	. IF Q="Needs Correction" SET IN("row","status")="Draft"
	IF ($GET(IN("row","consent"))="")!((Q="Drafts")&($GET(IN("row","consent"))="Unknown")) DO
	. IF Q="Pending Review" SET IN("row","consent")="No"
	. IF Q="Active" SET IN("row","consent")="Yes"
	. IF Q="Drafts" SET IN("row","consent")="No"
	. IF Q="Needs Correction" SET IN("row","consent")="Unknown"
	IF $GET(IN("row","duplicateStatus"))="" SET IN("row","duplicateStatus")="None"
	SET MRN=$GET(IN("row","mrn")) IF MRN'="",$GET(IN("row","id"))="" SET IN("row","id")=MRN
	QUIT
	;
CANLAUNCH(STATE)
	QUIT $$CAN(.STATE,"read")
	;
CAN(STATE,ACTION)
	NEW A
	SET A=$$PERMACT($GET(ACTION))
	IF '+$GET(STATE("authenticated"),0) QUIT 0
	IF $$ROLE(.STATE,"admin") QUIT 1
	IF $$ROLE(.STATE,"developer") QUIT 1
	IF $$ROLE(.STATE,"patient-admin") QUIT 1
	IF A="read",$$ROLE(.STATE,"patient-read") QUIT 1
	IF A="read",$$ROLE(.STATE,"patient-reader") QUIT 1
	IF A="read",$$ROLE(.STATE,"patient-readonly") QUIT 1
	IF A="read",$$ROLE(.STATE,"auditor") QUIT 1
	IF A="audit",$$ROLE(.STATE,"auditor") QUIT 1
	IF A="read",$$ROLE(.STATE,"clinician") QUIT 1
	IF A="read",$$ROLE(.STATE,"registrar") QUIT 1
	IF A="write",$$ROLE(.STATE,"clinician") QUIT 1
	IF A="create",$$ROLE(.STATE,"registrar") QUIT 1
	IF A="write",$$ROLE(.STATE,"registrar") QUIT 1
	IF A="review",$$ROLE(.STATE,"registrar") QUIT 1
	IF A="export",$$ROLE(.STATE,"registrar") QUIT 0
	IF A="delete",$$ROLE(.STATE,"registrar") QUIT 0
	IF A="export",$$ROLE(.STATE,"clinician") QUIT 0
	IF A="delete",$$ROLE(.STATE,"clinician") QUIT 0
	QUIT 0
	;
ALLOW(STATE,ACTION,ERR)
	NEW PERM
	SET PERM=$$PERMACT($GET(ACTION))
	IF $$CAN(.STATE,PERM) QUIT 1
	SET ERR("error")="patient_access_denied"
	SET ERR("message")="Patient Registration access denied for "_PERM
	SET ERR("dataset")="patient-registration"
	SET ERR("permission")=PERM
	DO DENYAUD(.STATE,PERM,.ERR)
	QUIT 0
	;
PERMACT(ACTION)
	NEW A
	SET A=$$LOW^MIOUTIL($GET(ACTION))
	IF A="" QUIT "read"
	IF A="query" QUIT "read"
	IF A="read" QUIT "read"
	IF A="rows.export"!(A="export")!(A="patient.export.selected") QUIT "export"
	IF A="row.delete"!(A="rows.delete")!(A="bulk.delete") QUIT "delete"
	IF A="row.add" QUIT "create"
	IF A="row.save"!(A="row.update")!(A="cell.save") QUIT "write"
	IF A="patient.duplicate.mark"!(A="patient.duplicate.clear") QUIT "review"
	IF A="patient.review.needs-correction"!(A="patient.review.pending")!(A="patient.review.draft")!(A="patient.review.active")!(A="patient.review.inactive") QUIT "review"
	IF A="patient.bulk.pending"!(A="patient.bulk.needs-correction")!(A="patient.bulk.active") QUIT "review"
	IF A="patient.import.preview" QUIT "read"
	IF A="patient.import.commit" QUIT "create"
	IF A="patient.reconcile.report" QUIT "review"
	QUIT "write"
	;
MASKED(STATE)
	IF $$CAN(.STATE,"write") QUIT 0
	IF $$CAN(.STATE,"read") QUIT 1
	QUIT 0
	;
MASKOUT(OUT,STATE)
	NEW I
	IF '$$MASKED(.STATE) QUIT
	SET OUT("features","phiMasked")=1
	SET OUT("patientRegistration","phiMasked")=1
	SET I=0 FOR  SET I=$ORDER(OUT("rows",I)) QUIT:I'>0  DO MASKROW($NAME(OUT("rows",I)))
	IF $DATA(OUT("data")) SET I=0 FOR  SET I=$ORDER(OUT("data",I)) QUIT:I'>0  DO MASKROW($NAME(OUT("data",I)))
	QUIT
	;
MASKROW(ROOT)
	IF $GET(ROOT)="" QUIT
	IF $GET(@ROOT@("mrn"))'="" SET @ROOT@("mrn")=$$MASKMRN($GET(@ROOT@("mrn")))
	IF $GET(@ROOT@("firstName"))'="" SET @ROOT@("firstName")=$EXTRACT($GET(@ROOT@("firstName")),1)_"."
	IF $GET(@ROOT@("lastName"))'="" SET @ROOT@("lastName")=$EXTRACT($GET(@ROOT@("lastName")),1)_"."
	IF $GET(@ROOT@("dob"))'="" SET @ROOT@("dob")="masked"
	IF $GET(@ROOT@("phone"))'="" SET @ROOT@("phone")="masked"
	IF $GET(@ROOT@("email"))'="" SET @ROOT@("email")="masked@example.invalid"
	IF $GET(@ROOT@("address1"))'="" SET @ROOT@("address1")="masked"
	IF $GET(@ROOT@("emergencyContact"))'="" SET @ROOT@("emergencyContact")="masked"
	IF $GET(@ROOT@("emergencyPhone"))'="" SET @ROOT@("emergencyPhone")="masked"
	QUIT
	;
MASKMRN(X)
	NEW L
	SET L=$LENGTH($GET(X))
	IF L<3 QUIT "***"
	QUIT "***"_$EXTRACT($GET(X),L-1,L)
	;
ROLE(STATE,ROLE)
	NEW I,X,WANT
	SET WANT=$$LOW^MIOUTIL($GET(ROLE))
	FOR I=1:1:$LENGTH($GET(STATE("roles")),",") DO  QUIT:$GET(X)=WANT
	. SET X=$$LOW^MIOUTIL($$TRIM^MIOUTIL($PIECE($GET(STATE("roles")),",",I)))
	QUIT $SELECT($GET(X)=WANT:1,1:0)
	;
DENYAUD(STATE,ACTION,ERR)
	NEW USER,NOW,N
	SET USER=$GET(STATE("principal"),"guest") IF USER="" SET USER="guest"
	SET NOW=$$NOWISO^MIOUTIL()
	SET N=$ORDER(^MIO("MIOOS","PATIENT","AUDIT",USER,""),-1)+1
	SET ^MIO("MIOOS","PATIENT","AUDIT",USER,N,"action")="denied:"_$GET(ACTION)
	SET ^MIO("MIOOS","PATIENT","AUDIT",USER,N,"ok")=0
	SET ^MIO("MIOOS","PATIENT","AUDIT",USER,N,"when")=NOW
	SET ^MIO("MIOOS","PATIENT","AUDIT",USER,N,"error")=$GET(ERR("error"),"patient_access_denied")
	QUIT
	;
VALPAT(IN,ERR,ROOT)
	NEW OK,ID,OLD,STATUS,CONSENT
	SET OK=1
	IF '$DATA(IN("row")) QUIT 1
	SET ID=$GET(IN("row","id"),$GET(IN("row","mrn")))
	SET OLD=$$OLDSTAT(ROOT,ID)
	SET STATUS=$$STATUS($GET(IN("row","status"))),CONSENT=$GET(IN("row","consent"))
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
	IF Y="Archived" SET Y="Inactive"
	QUIT Y
	;
OLDSTAT(ROOT,ID)
	NEW I,OLD
	SET OLD="",I=0 FOR  SET I=$ORDER(@ROOT@("rows",I)) QUIT:I'>0!(OLD'="")  DO
	. IF $GET(@ROOT@("rows",I,"id"))=$GET(ID)!($GET(@ROOT@("rows",I,"mrn"))=$GET(ID)) SET OLD=$GET(@ROOT@("rows",I,"status"))
	QUIT $$STATUS(OLD)
	;
VALPACT(ACTION,IN,ERR)
	NEW A,I,SEEN
	SET A=$$LOW^MIOUTIL($GET(ACTION))
	IF A="patient.import.preview"!(A="patient.import.commit") DO  QUIT $SELECT($GET(ERR("error"))="":1,1:0)
	. IF $GET(IN("csv"))="" SET ERR("error")="csv_missing",ERR("message")="Paste patient CSV before preview or import."
	IF A="patient.reconcile.report" QUIT 1
	IF A="patient.bulk.pending"!(A="patient.bulk.needs-correction")!(A="patient.export.selected") DO  QUIT $SELECT($GET(ERR("error"))="":1,1:0)
	. SET SEEN=0,I=0 FOR  SET I=$ORDER(IN("ids",I)) QUIT:I'>0!($GET(ERR("error"))'="")  DO
	. . SET SEEN=1 IF $GET(IN("ids",I))="" SET ERR("error")="row_id_missing"
	. IF 'SEEN SET ERR("error")="row_ids_missing"
	IF $GET(IN("rowId"),$GET(IN("id")))="" SET ERR("error")="row_id_missing" QUIT 0
	QUIT 1
	;
PATACTION(ROOT,ACTION,IN,OUT,STATE)
	NEW A,ID,I,COUNT
	SET A=$$LOW^MIOUTIL($GET(ACTION))
	IF A="patient.import.preview" DO IMPPARSE(ROOT,$GET(IN("csv")),.OUT,0,.STATE) QUIT
	IF A="patient.import.commit" DO IMPPARSE(ROOT,$GET(IN("csv")),.OUT,1,.STATE) QUIT
	IF A="patient.reconcile.report" DO RECON(ROOT,.OUT,.STATE) QUIT
	IF A="patient.export.selected" DO PATEXP(ROOT,.IN,.OUT,.STATE) QUIT
	IF A="patient.duplicate.mark" DO  QUIT
	. SET ID=$GET(IN("rowId"),$GET(IN("id"))) DO MARKDUP(ROOT,ID,"Duplicate",.OUT,.STATE)
	IF A="patient.duplicate.clear" DO  QUIT
	. SET ID=$GET(IN("rowId"),$GET(IN("id"))) DO MARKDUP(ROOT,ID,"Not duplicate",.OUT,.STATE)
	IF A="patient.review.needs-correction" DO  QUIT
	. SET ID=$GET(IN("rowId"),$GET(IN("id"))) DO SETQUEUE(ROOT,ID,"Needs Correction",.OUT,.STATE)
	IF A="patient.review.pending" DO  QUIT
	. SET ID=$GET(IN("rowId"),$GET(IN("id"))) DO SETSTATUS(ROOT,ID,"Pending Review",.OUT,.STATE)
	IF A="patient.review.active" DO  QUIT
	. SET ID=$GET(IN("rowId"),$GET(IN("id"))) DO SETACTIVE(ROOT,ID,.OUT,.STATE)
	IF A="patient.review.inactive" DO  QUIT
	. SET ID=$GET(IN("rowId"),$GET(IN("id"))) DO SETSTATUS(ROOT,ID,"Inactive",.OUT,.STATE)
	IF A="patient.review.draft" DO  QUIT
	. SET ID=$GET(IN("rowId"),$GET(IN("id"))) DO SETSTATUS(ROOT,ID,"Draft",.OUT,.STATE)
	IF A="patient.bulk.pending"!(A="patient.bulk.needs-correction")!(A="patient.bulk.active") DO  QUIT
	. SET COUNT=0,I=0 FOR  SET I=$ORDER(IN("ids",I)) QUIT:I'>0  DO
	. . SET ID=$GET(IN("ids",I)) QUIT:ID=""
	. . IF A="patient.bulk.pending" DO SETSTATUS(ROOT,ID,"Pending Review",.OUT,.STATE)
	. . IF A="patient.bulk.needs-correction" DO SETQUEUE(ROOT,ID,"Needs Correction",.OUT,.STATE)
	. . IF A="patient.bulk.active" DO SETACTIVE(ROOT,ID,.OUT,.STATE)
	. . SET COUNT=COUNT+1
	. SET OUT("mutated","count")=COUNT
	QUIT
	;

IMPPARSE(ROOT,CSV,OUT,COMMIT,STATE)
	NEW TEXT,HDR,I,LINE,ROW,VIN,VERR,VALID,INVALID,IMPORTED,ID,POS
	SET TEXT=$TRANSLATE($GET(CSV),$CHAR(13),"")
	SET HDR=$PIECE(TEXT,$CHAR(10),1)
	SET VALID=0,INVALID=0,IMPORTED=0
	IF HDR="" SET OUT("error")="csv_header_missing",OUT("message")="CSV header row is required" QUIT
	FOR I=2:1:$LENGTH(TEXT,$CHAR(10)) DO
	. SET LINE=$PIECE(TEXT,$CHAR(10),I) QUIT:$$TRIM^MIOUTIL(LINE)=""
	. KILL ROW,VIN,VERR DO CSVROW(HDR,LINE,.ROW)
	. MERGE VIN("row")=ROW
	. IF $GET(VIN("row","id"))="" SET VIN("row","id")=$GET(VIN("row","mrn"))
	. DO ADDDEF(ROOT,"row.save",.VIN,.STATE)
	. IF $$VALPAT(.VIN,.VERR,ROOT) DO
	. . SET VALID=VALID+1 MERGE OUT("importPreview","valid",VALID)=VIN("row")
	. . IF +$GET(COMMIT) DO
	. . . SET ID=$GET(VIN("row","id"),$GET(VIN("row","mrn"))) IF ID="" SET ID="PAT-"_($ORDER(@ROOT@("rows",""),-1)+1)
	. . . SET POS=$$ROWIDX(ROOT,ID) IF POS'>0 SET POS=$ORDER(@ROOT@("rows",""),-1)+1
	. . . KILL @ROOT@("rows",POS) MERGE @ROOT@("rows",POS)=VIN("row") SET @ROOT@("rows",POS,"id")=ID
	. . . DO STAMP(ROOT,POS,.STATE),REVIEWROW(ROOT,POS) SET IMPORTED=IMPORTED+1
	. ELSE  DO
	. . SET INVALID=INVALID+1,OUT("importPreview","invalid",INVALID,"line")=I MERGE OUT("importPreview","invalid",INVALID,"fieldErrors")=VERR("fieldErrors") SET OUT("importPreview","invalid",INVALID,"message")=$GET(VERR("message"),"Validation failed")
	SET OUT("importPreview","validCount")=VALID
	SET OUT("importPreview","invalidCount")=INVALID
	SET OUT("importPreview","committedCount")=IMPORTED
	SET OUT("mutated","patientImport")=$SELECT(+COMMIT:IMPORTED,1:0)
	SET OUT("message")=$SELECT(+COMMIT:"Patient import committed",1:"Patient import preview ready")
	QUIT
	;
CSVROW(HDR,LINE,ROW)
	NEW I,KEY,VAL
	KILL ROW
	FOR I=1:1:$LENGTH(HDR,",") DO
	. SET KEY=$$TRIM^MIOUTIL($PIECE(HDR,",",I)),VAL=$$TRIM^MIOUTIL($PIECE(LINE,",",I))
	. SET KEY=$$KEY^MIOOSTBL(KEY) IF KEY'="" SET ROW(KEY)=VAL
	QUIT
	;
RECON(ROOT,OUT,STATE)
	NEW I,J,COUNT,ID1,ID2,REASON
	SET COUNT=0
	SET I=0 FOR  SET I=$ORDER(@ROOT@("rows",I)) QUIT:I'>0  DO
	. SET J=I FOR  SET J=$ORDER(@ROOT@("rows",J)) QUIT:J'>0  DO
	. . SET REASON=$$RECREASON(ROOT,I,J) QUIT:REASON=""
	. . SET COUNT=COUNT+1,ID1=$GET(@ROOT@("rows",I,"id"),$GET(@ROOT@("rows",I,"mrn"))),ID2=$GET(@ROOT@("rows",J,"id"),$GET(@ROOT@("rows",J,"mrn")))
	. . SET OUT("reconciliation","candidates",COUNT,"leftId")=ID1,OUT("reconciliation","candidates",COUNT,"rightId")=ID2,OUT("reconciliation","candidates",COUNT,"reason")=REASON
	SET OUT("reconciliation","candidateCount")=COUNT
	SET OUT("mutated","reconciliation")=COUNT
	SET OUT("message")="Patient reconciliation report ready"
	QUIT
	;
RECREASON(ROOT,I,J)
	IF $GET(@ROOT@("rows",I,"mrn"))'="",$$CANON($GET(@ROOT@("rows",I,"mrn")))=$$CANON($GET(@ROOT@("rows",J,"mrn"))) QUIT "duplicate_mrn"
	IF $GET(@ROOT@("rows",I,"firstName"))'="",$GET(@ROOT@("rows",I,"lastName"))'="",$GET(@ROOT@("rows",I,"dob"))'="",($$CANON($GET(@ROOT@("rows",I,"firstName")))_"|"_$$CANON($GET(@ROOT@("rows",I,"lastName")))_"|"_$GET(@ROOT@("rows",I,"dob")))=($$CANON($GET(@ROOT@("rows",J,"firstName")))_"|"_$$CANON($GET(@ROOT@("rows",J,"lastName")))_"|"_$GET(@ROOT@("rows",J,"dob"))) QUIT "same_name_dob"
	IF $GET(@ROOT@("rows",I,"email"))'="",$$CANON($GET(@ROOT@("rows",I,"email")))=$$CANON($GET(@ROOT@("rows",J,"email"))) QUIT "same_email"
	IF $GET(@ROOT@("rows",I,"phone"))'="",$$CANON($GET(@ROOT@("rows",I,"phone")))=$$CANON($GET(@ROOT@("rows",J,"phone"))) QUIT "same_phone"
	QUIT ""
	;
PATEXP(ROOT,IN,OUT,STATE)
	NEW I,ID,COUNT
	SET COUNT=0,I=0 FOR  SET I=$ORDER(IN("ids",I)) QUIT:I'>0  DO
	. SET ID=$GET(IN("ids",I)) QUIT:ID=""
	. SET COUNT=COUNT+1,OUT("patientExport","ids",COUNT)=ID
	SET OUT("patientExport","count")=COUNT
	SET OUT("patientExport","message")="Use rows.export for CSV bytes; this action records patient export intent and permission checks."
	SET OUT("mutated","patientExport")=COUNT
	SET OUT("message")="Patient export authorized"
	QUIT
	;
MARKDUP(ROOT,ID,STATUS,OUT,STATE)
	NEW I,DUP
	SET I=$$ROWIDX(ROOT,ID) IF I'>0 QUIT
	SET @ROOT@("rows",I,"duplicateStatus")=STATUS
	IF STATUS="Duplicate" DO
	. SET DUP=$GET(@ROOT@("rows",I,"duplicateOf")) IF DUP="" SET DUP=$$DUPDEM(ROOT,$GET(@ROOT@("rows",I,"firstName")),$GET(@ROOT@("rows",I,"lastName")),$GET(@ROOT@("rows",I,"dob")),ID)
	. IF DUP'="" SET @ROOT@("rows",I,"duplicateOf")=DUP
	. SET @ROOT@("rows",I,"reviewNote")="Marked as duplicate candidate."
	IF STATUS="Not duplicate" DO
	. SET @ROOT@("rows",I,"duplicateOf")=""
	. SET @ROOT@("rows",I,"reviewNote")="Marked as not duplicate."
	DO STAMP(ROOT,I,.STATE),REVIEWROW(ROOT,I)
	SET OUT("mutated","rowId")=ID,OUT("mutated","patientAction")="duplicate",OUT("message")="Duplicate status updated"
	QUIT
	;
SETQUEUE(ROOT,ID,QUEUE,OUT,STATE)
	NEW I
	SET I=$$ROWIDX(ROOT,ID) IF I'>0 QUIT
	SET @ROOT@("rows",I,"reviewQueue")=QUEUE
	SET @ROOT@("rows",I,"reviewNote")=$GET(@ROOT@("rows",I,"reviewNote"))_$SELECT($GET(@ROOT@("rows",I,"reviewNote"))'="":" ",1:"")_"Needs correction review flag set."
	DO STAMP(ROOT,I,.STATE)
	SET OUT("mutated","rowId")=ID,OUT("mutated","patientAction")="reviewQueue",OUT("message")="Patient review queue updated"
	QUIT
	;
SETACTIVE(ROOT,ID,OUT,STATE)
	NEW I
	SET I=$$ROWIDX(ROOT,ID) IF I'>0 QUIT
	SET @ROOT@("rows",I,"consent")="Yes"
	SET @ROOT@("rows",I,"status")="Active"
	SET @ROOT@("rows",I,"reviewNote")=$GET(@ROOT@("rows",I,"reviewNote"))_$SELECT($GET(@ROOT@("rows",I,"reviewNote"))'="":" ",1:"")_"Marked active through reviewed patient action."
	DO STAMP(ROOT,I,.STATE),REVIEWROW(ROOT,I)
	SET OUT("mutated","rowId")=ID,OUT("mutated","patientAction")="active",OUT("message")="Patient marked active"
	QUIT
	;
SETSTATUS(ROOT,ID,STATUS,OUT,STATE)
	NEW I
	SET I=$$ROWIDX(ROOT,ID) IF I'>0 QUIT
	SET @ROOT@("rows",I,"status")=STATUS
	DO STAMP(ROOT,I,.STATE),REVIEWROW(ROOT,I)
	SET OUT("mutated","rowId")=ID,OUT("mutated","patientAction")="status",OUT("message")="Patient status updated"
	QUIT
	;
STAMP(ROOT,I,STATE)
	NEW USER,TODAY
	SET USER=$GET(STATE("principal"),"guest") IF USER="" SET USER="guest"
	SET TODAY=$$TODAY()
	IF $GET(@ROOT@("rows",I,"createdAt"))="" SET @ROOT@("rows",I,"createdAt")=TODAY
	IF $GET(@ROOT@("rows",I,"createdBy"))="" SET @ROOT@("rows",I,"createdBy")=USER
	SET @ROOT@("rows",I,"updatedAt")=TODAY
	SET @ROOT@("rows",I,"updatedBy")=USER
	SET @ROOT@("rows",I,"lastReviewAt")=TODAY
	SET @ROOT@("rows",I,"reviewedBy")=USER
	QUIT
	;
ROWIDX(ROOT,ID)
	NEW I,FOUND
	SET FOUND=0,I=0 FOR  SET I=$ORDER(@ROOT@("rows",I)) QUIT:I'>0!(FOUND)  DO
	. IF $GET(@ROOT@("rows",I,"id"))=$GET(ID)!($GET(@ROOT@("rows",I,"mrn"))=$GET(ID)) SET FOUND=I
	QUIT FOUND
	;
POSTPAT(ROOT,ACTION,IN,OUT,STATE)
	NEW ID,I,USER,TODAY
	IF $GET(ACTION)'="row.save",$GET(ACTION)'="row.add",$GET(ACTION)'="row.update",$GET(ACTION)'="cell.save" QUIT
	SET USER=$GET(STATE("principal"),"guest") IF USER="" SET USER="guest"
	SET ID=$GET(IN("row","id"),$GET(IN("row","mrn"),$GET(IN("rowId"),$GET(IN("id")))))
	IF ID="" QUIT
	SET TODAY=$$TODAY()
	SET I=0 FOR  SET I=$ORDER(@ROOT@("rows",I)) QUIT:I'>0  DO
	. IF $GET(@ROOT@("rows",I,"id"))'=ID,$GET(@ROOT@("rows",I,"mrn"))'=ID QUIT
	. IF $GET(@ROOT@("rows",I,"createdAt"))="" SET @ROOT@("rows",I,"createdAt")=TODAY
	. IF $GET(@ROOT@("rows",I,"createdBy"))="" SET @ROOT@("rows",I,"createdBy")=USER
	. SET @ROOT@("rows",I,"updatedAt")=TODAY
	. SET @ROOT@("rows",I,"updatedBy")=USER
	. IF $GET(@ROOT@("rows",I,"consent"))="Yes",$GET(@ROOT@("rows",I,"consentDate"))="" SET @ROOT@("rows",I,"consentDate")=TODAY
	. DO REVIEWROW(ROOT,I)
	DO DUPWARN(ROOT,.IN,.OUT)
	QUIT
	;
DUPWARN(ROOT,IN,OUT)
	NEW ID,FIRST,LAST,DOB,EMAIL,PHONE,DUP,N
	SET ID=$GET(IN("row","id"),$GET(IN("row","mrn"),$GET(IN("rowId"),$GET(IN("id")))))
	SET FIRST=$GET(IN("row","firstName")),LAST=$GET(IN("row","lastName")),DOB=$GET(IN("row","dob")),EMAIL=$GET(IN("row","email")),PHONE=$GET(IN("row","phone"))
	SET N=0
	SET DUP=$$DUPDEM(ROOT,FIRST,LAST,DOB,ID) IF DUP'="" SET N=N+1,OUT("warnings","duplicateCandidates",N,"reason")="same_name_dob",OUT("warnings","duplicateCandidates",N,"patientId")=DUP
	SET DUP=$$DUPCONTACT(ROOT,"email",EMAIL,ID) IF DUP'="" SET N=N+1,OUT("warnings","duplicateCandidates",N,"reason")="same_email",OUT("warnings","duplicateCandidates",N,"patientId")=DUP
	SET DUP=$$DUPCONTACT(ROOT,"phone",PHONE,ID) IF DUP'="" SET N=N+1,OUT("warnings","duplicateCandidates",N,"reason")="same_phone",OUT("warnings","duplicateCandidates",N,"patientId")=DUP
	IF N>0 SET OUT("warnings","duplicateCount")=N
	QUIT
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
	NEW I,C,Q SET Q=1
	IF $LENGTH($GET(X))<3 QUIT 0
	FOR I=1:1:$LENGTH(X) SET C=$EXTRACT(X,I) IF (C'?1AN)&(C'="-") SET Q=0 QUIT
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
	;