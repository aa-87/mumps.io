MIOOSPERM ; MIOOS HIPAA-aligned permissions registry
	QUIT
	;
INIT(CONF)
	IF +$GET(^MIO("MIOOS","PERM","BOOTSTRAPPED"))=1 QUIT
	KILL ^MIO("MIOOS","PERM")
	DO PERM("mioos.permissions.view","View permissions","Security","Read permission catalog and effective access",0,0)
	DO PERM("mioos.permissions.edit","Edit permissions","Security","Create and update permissions, groups, profiles, and assignments",0,0)
	DO PERM("mioos.permissions.admin","Administer permissions","Security","Full permissions administration and assignment",0,1)
	DO PERM("mioos.permissions.audit","View permission audit","Security","Review permission audit logs",0,0)
	DO PERM("mioos.modules.run","Run UI modules","Modules","Launch enabled internal or user-created UI modules",0,0)
	DO PERM("mioos.modules.admin","Administer UI modules","Modules","Manage module catalog and user module manifests",0,0)
	DO PERM("mioos.table.query","Query backend tables","Tables","Run backend table queries through WebSocket module transport",0,0)
	DO PERM("mioos.phi.read","Read PHI","HIPAA","Read protected health information using minimum necessary access",1,0)
	DO PERM("mioos.phi.write","Write PHI","HIPAA","Create or update protected health information",1,0)
	DO PERM("mioos.phi.export","Export PHI","HIPAA","Export protected health information",1,1)
	DO PERM("mioos.phi.breakglass","Emergency PHI access","HIPAA","Emergency break-glass PHI access with mandatory audit trail",1,1)
	DO GROUP("administrators","Administrators","Full system and security administration",1)
	DO GPERM("administrators","mioos.permissions.view")
	DO GPERM("administrators","mioos.permissions.edit")
	DO GPERM("administrators","mioos.permissions.admin")
	DO GPERM("administrators","mioos.permissions.audit")
	DO GPERM("administrators","mioos.modules.run")
	DO GPERM("administrators","mioos.modules.admin")
	DO GPERM("administrators","mioos.table.query")
	DO GPERM("administrators","mioos.phi.read")
	DO GPERM("administrators","mioos.phi.write")
	DO GPERM("administrators","mioos.phi.export")
	DO GPERM("administrators","mioos.phi.breakglass")
	DO GROUP("clinicians","Clinicians","Minimum-necessary clinical access",0)
	DO GPERM("clinicians","mioos.modules.run")
	DO GPERM("clinicians","mioos.table.query")
	DO GPERM("clinicians","mioos.phi.read")
	DO GROUP("auditors","Auditors","Read-only audit and compliance review",0)
	DO GPERM("auditors","mioos.permissions.view")
	DO GPERM("auditors","mioos.permissions.audit")
	DO PROFILE("hipaa-admin","HIPAA Security Administrator","Administrative profile for permission governance",1,1,1)
	DO PGRP("hipaa-admin","administrators")
	DO PROFILE("minimum-necessary","Minimum Necessary Clinical","Clinical access limited to read-only PHI and module execution",0,1,0)
	DO PGRP("minimum-necessary","clinicians")
	DO PROFILE("audit-review","Audit Review","Read-only permission audit access",0,0,0)
	DO PGRP("audit-review","auditors")
	DO ASSIGN("role","admin","hipaa-admin","system bootstrap")
	DO ASSIGN("role","clinician","minimum-necessary","system bootstrap")
	DO ASSIGN("role","auditor","audit-review","system bootstrap")
	SET ^MIO("MIOOS","PERM","BOOTSTRAPPED")=1
	QUIT
	;
PERM(KEY,NAME,CAT,DESC,PHI,SENSITIVE)
	SET ^MIO("MIOOS","PERM","PERMISSION",KEY,"key")=KEY
	SET ^MIO("MIOOS","PERM","PERMISSION",KEY,"name")=NAME
	SET ^MIO("MIOOS","PERM","PERMISSION",KEY,"category")=CAT
	SET ^MIO("MIOOS","PERM","PERMISSION",KEY,"description")=DESC
	SET ^MIO("MIOOS","PERM","PERMISSION",KEY,"phi")=+PHI
	SET ^MIO("MIOOS","PERM","PERMISSION",KEY,"sensitive")=+SENSITIVE
	QUIT
	;
GROUP(KEY,NAME,DESC,SYSTEM)
	SET ^MIO("MIOOS","PERM","GROUP",KEY,"key")=KEY
	SET ^MIO("MIOOS","PERM","GROUP",KEY,"name")=NAME
	SET ^MIO("MIOOS","PERM","GROUP",KEY,"description")=DESC
	SET ^MIO("MIOOS","PERM","GROUP",KEY,"system")=+SYSTEM
	QUIT
	;
GPERM(GROUP,PERM)
	SET ^MIO("MIOOS","PERM","GROUP",GROUP,"permissions",PERM)=1
	QUIT
	;
PROFILE(KEY,NAME,DESC,SYSTEM,MINNEC,BREAK)
	SET ^MIO("MIOOS","PERM","PROFILE",KEY,"key")=KEY
	SET ^MIO("MIOOS","PERM","PROFILE",KEY,"name")=NAME
	SET ^MIO("MIOOS","PERM","PROFILE",KEY,"description")=DESC
	SET ^MIO("MIOOS","PERM","PROFILE",KEY,"system")=+SYSTEM
	SET ^MIO("MIOOS","PERM","PROFILE",KEY,"minimumNecessary")=+MINNEC
	SET ^MIO("MIOOS","PERM","PROFILE",KEY,"breakGlassAllowed")=+BREAK
	QUIT
	;
PGRP(PROFILE,GROUP)
	SET ^MIO("MIOOS","PERM","PROFILE",PROFILE,"groups",GROUP)=1
	QUIT
	;
ASSIGN(TYPE,PRINCIPAL,PROFILE,REASON)
	NEW ID,NOW
	SET ID=TYPE_":"_PRINCIPAL_":"_PROFILE
	SET NOW=$HOROLOG
	SET ^MIO("MIOOS","PERM","ASSIGN",ID,"id")=ID
	SET ^MIO("MIOOS","PERM","ASSIGN",ID,"principalType")=TYPE
	SET ^MIO("MIOOS","PERM","ASSIGN",ID,"principal")=PRINCIPAL
	SET ^MIO("MIOOS","PERM","ASSIGN",ID,"profileKey")=PROFILE
	SET ^MIO("MIOOS","PERM","ASSIGN",ID,"reason")=$GET(REASON)
	SET ^MIO("MIOOS","PERM","ASSIGN",ID,"createdAt")=NOW
	QUIT
	;
ISADMIN(STATE)
	NEW R
	SET R=","_$GET(STATE("roles"))_"," IF R[",admin," QUIT 1
	QUIT $$HAS(.STATE,"mioos.permissions.admin")
	;
HAS(STATE,PERMISSION)
	NEW OUT,ERR,I,FOUND
	KILL OUT,ERR
	SET FOUND=0
	DO EFFECTIVE(.STATE,.OUT,.ERR)
	SET I=0 FOR  SET I=$ORDER(OUT("permissions",I)) QUIT:I'>0  DO  QUIT:FOUND
	. IF $GET(OUT("permissions",I,"key"))=PERMISSION SET FOUND=1
	QUIT FOUND
	;
EFFECTIVE(STATE,OUT,ERR)
	NEW USER,ROLES,ROLE,IDX,ID,PROFILE,GROUP,PERM,N,GSEEN,PSEEN,PERMSEEN
	KILL OUT,ERR,GSEEN,PSEEN,PERMSEEN
	SET ERR("routine")="MIOOSPERM"
	SET USER=$GET(STATE("principal"),"guest")
	SET OUT("principal")=USER
	SET OUT("hipaa","minimumNecessary")=1
	SET OUT("hipaa","auditRequired")=1
	SET ID="" FOR  SET ID=$ORDER(^MIO("MIOOS","PERM","ASSIGN",ID)) QUIT:ID=""  DO
	. IF $GET(^MIO("MIOOS","PERM","ASSIGN",ID,"principalType"))="user",$GET(^MIO("MIOOS","PERM","ASSIGN",ID,"principal"))=USER DO ADDPROF($GET(^MIO("MIOOS","PERM","ASSIGN",ID,"profileKey")),.PSEEN,.GSEEN,.PERMSEEN)
	SET ROLES=$GET(STATE("roles"))
	FOR IDX=1:1:$LENGTH(ROLES,",") DO
	. SET ROLE=$PIECE(ROLES,",",IDX) QUIT:ROLE=""
	. SET ID="" FOR  SET ID=$ORDER(^MIO("MIOOS","PERM","ASSIGN",ID)) QUIT:ID=""  DO
	. . IF $GET(^MIO("MIOOS","PERM","ASSIGN",ID,"principalType"))="role",$GET(^MIO("MIOOS","PERM","ASSIGN",ID,"principal"))=ROLE DO ADDPROF($GET(^MIO("MIOOS","PERM","ASSIGN",ID,"profileKey")),.PSEEN,.GSEEN,.PERMSEEN)
	SET N=0,PROFILE="" FOR  SET PROFILE=$ORDER(PSEEN(PROFILE)) QUIT:PROFILE=""  DO
	. SET N=N+1,OUT("profiles",N,"key")=PROFILE,OUT("profiles",N,"name")=$GET(^MIO("MIOOS","PERM","PROFILE",PROFILE,"name"))
	SET N=0,GROUP="" FOR  SET GROUP=$ORDER(GSEEN(GROUP)) QUIT:GROUP=""  DO
	. SET N=N+1,OUT("groups",N,"key")=GROUP,OUT("groups",N,"name")=$GET(^MIO("MIOOS","PERM","GROUP",GROUP,"name"))
	SET N=0,PERM="" FOR  SET PERM=$ORDER(PERMSEEN(PERM)) QUIT:PERM=""  DO
	. SET N=N+1,OUT("permissions",N,"key")=PERM,OUT("permissions",N,"name")=$GET(^MIO("MIOOS","PERM","PERMISSION",PERM,"name")),OUT("permissions",N,"phi")=+$GET(^MIO("MIOOS","PERM","PERMISSION",PERM,"phi"))
	SET OUT("ok")=1
	QUIT 1
	;
ADDPROF(PROFILE,PSEEN,GSEEN,PERMSEEN)
	NEW GROUP,PERM
	IF PROFILE="" QUIT
	SET PSEEN(PROFILE)=1
	SET GROUP="" FOR  SET GROUP=$ORDER(^MIO("MIOOS","PERM","PROFILE",PROFILE,"groups",GROUP)) QUIT:GROUP=""  DO
	. SET GSEEN(GROUP)=1
	. SET PERM="" FOR  SET PERM=$ORDER(^MIO("MIOOS","PERM","GROUP",GROUP,"permissions",PERM)) QUIT:PERM=""  SET PERMSEEN(PERM)=1
	QUIT
	;
TABLE(STATE,CONF,DATASET,ROWS,SCHEMA,ERR)
	KILL ROWS,SCHEMA,ERR
	SET ERR("routine")="MIOOSPERM"
	DO INIT(.CONF)
	IF DATASET="permissions" DO TP(.ROWS,.SCHEMA) QUIT 1
	IF DATASET="permission-groups" DO TG(.ROWS,.SCHEMA) QUIT 1
	IF DATASET="permission-profiles" DO TPROF(.ROWS,.SCHEMA) QUIT 1
	IF DATASET="permission-assignments" DO TA(.ROWS,.SCHEMA) QUIT 1
	IF DATASET="permission-audit" DO TAUD(.ROWS,.SCHEMA) QUIT 1
	SET ERR("error")="permission_dataset_unknown"
	QUIT 0
	;
COL(SCHEMA,N,KEY,LABEL,TYPE,WIDTH,HIDDEN,SORTABLE)
	SET SCHEMA("columns",N,"key")=KEY,SCHEMA("columns",N,"label")=LABEL,SCHEMA("columns",N,"type")=TYPE
	SET SCHEMA("columns",N,"width")=WIDTH,SCHEMA("columns",N,"hidden")=+HIDDEN,SCHEMA("columns",N,"sortable")=+SORTABLE,SCHEMA("columns",N,"resizable")=1
	QUIT
	;
TP(ROWS,SCHEMA)
	NEW K,N
	DO COL(.SCHEMA,1,"key","Permission","text",240,0,1),COL(.SCHEMA,2,"name","Name","text",220,0,1),COL(.SCHEMA,3,"category","Category","text",130,0,1),COL(.SCHEMA,4,"phi","PHI","badge",80,0,1),COL(.SCHEMA,5,"sensitive","Sensitive","badge",110,0,1),COL(.SCHEMA,6,"description","Description","text",360,0,0)
	SET N=0,K="" FOR  SET K=$ORDER(^MIO("MIOOS","PERM","PERMISSION",K)) QUIT:K=""  DO
	. SET N=N+1,ROWS(N,"id")=K,ROWS(N,"key")=K,ROWS(N,"name")=$GET(^MIO("MIOOS","PERM","PERMISSION",K,"name")),ROWS(N,"category")=$GET(^MIO("MIOOS","PERM","PERMISSION",K,"category")),ROWS(N,"phi")=+$GET(^MIO("MIOOS","PERM","PERMISSION",K,"phi")),ROWS(N,"sensitive")=+$GET(^MIO("MIOOS","PERM","PERMISSION",K,"sensitive")),ROWS(N,"description")=$GET(^MIO("MIOOS","PERM","PERMISSION",K,"description"))
	QUIT
	;
TG(ROWS,SCHEMA)
	NEW K,N,C,P
	DO COL(.SCHEMA,1,"key","Group","text",220,0,1),COL(.SCHEMA,2,"name","Name","text",220,0,1),COL(.SCHEMA,3,"permissionCount","Permissions","text",120,0,1),COL(.SCHEMA,4,"system","System","badge",100,0,1),COL(.SCHEMA,5,"description","Description","text",360,0,0)
	SET N=0,K="" FOR  SET K=$ORDER(^MIO("MIOOS","PERM","GROUP",K)) QUIT:K=""  DO
	. SET C=0,P="" FOR  SET P=$ORDER(^MIO("MIOOS","PERM","GROUP",K,"permissions",P)) QUIT:P=""  SET C=C+1
	. SET N=N+1,ROWS(N,"id")=K,ROWS(N,"key")=K,ROWS(N,"name")=$GET(^MIO("MIOOS","PERM","GROUP",K,"name")),ROWS(N,"permissionCount")=C,ROWS(N,"system")=+$GET(^MIO("MIOOS","PERM","GROUP",K,"system")),ROWS(N,"description")=$GET(^MIO("MIOOS","PERM","GROUP",K,"description"))
	QUIT
	;
TPROF(ROWS,SCHEMA)
	NEW K,N,C,G
	DO COL(.SCHEMA,1,"key","Profile","text",220,0,1),COL(.SCHEMA,2,"name","Name","text",220,0,1),COL(.SCHEMA,3,"groupCount","Groups","text",100,0,1),COL(.SCHEMA,4,"minimumNecessary","Minimum Necessary","badge",160,0,1),COL(.SCHEMA,5,"breakGlassAllowed","Break Glass","badge",120,0,1),COL(.SCHEMA,6,"description","Description","text",360,0,0)
	SET N=0,K="" FOR  SET K=$ORDER(^MIO("MIOOS","PERM","PROFILE",K)) QUIT:K=""  DO
	. SET C=0,G="" FOR  SET G=$ORDER(^MIO("MIOOS","PERM","PROFILE",K,"groups",G)) QUIT:G=""  SET C=C+1
	. SET N=N+1,ROWS(N,"id")=K,ROWS(N,"key")=K,ROWS(N,"name")=$GET(^MIO("MIOOS","PERM","PROFILE",K,"name")),ROWS(N,"groupCount")=C,ROWS(N,"minimumNecessary")=+$GET(^MIO("MIOOS","PERM","PROFILE",K,"minimumNecessary")),ROWS(N,"breakGlassAllowed")=+$GET(^MIO("MIOOS","PERM","PROFILE",K,"breakGlassAllowed")),ROWS(N,"description")=$GET(^MIO("MIOOS","PERM","PROFILE",K,"description"))
	QUIT
	;
TA(ROWS,SCHEMA)
	NEW K,N
	DO COL(.SCHEMA,1,"id","Assignment","text",280,0,1),COL(.SCHEMA,2,"principalType","Type","text",100,0,1),COL(.SCHEMA,3,"principal","Principal","text",180,0,1),COL(.SCHEMA,4,"profileKey","Profile","text",180,0,1),COL(.SCHEMA,5,"reason","Reason","text",260,0,0),COL(.SCHEMA,6,"createdAt","Created","text",160,0,1)
	SET N=0,K="" FOR  SET K=$ORDER(^MIO("MIOOS","PERM","ASSIGN",K)) QUIT:K=""  DO
	. SET N=N+1,ROWS(N,"id")=K,ROWS(N,"principalType")=$GET(^MIO("MIOOS","PERM","ASSIGN",K,"principalType")),ROWS(N,"principal")=$GET(^MIO("MIOOS","PERM","ASSIGN",K,"principal")),ROWS(N,"profileKey")=$GET(^MIO("MIOOS","PERM","ASSIGN",K,"profileKey")),ROWS(N,"reason")=$GET(^MIO("MIOOS","PERM","ASSIGN",K,"reason")),ROWS(N,"createdAt")=$GET(^MIO("MIOOS","PERM","ASSIGN",K,"createdAt"))
	QUIT
	;
TAUD(ROWS,SCHEMA)
	NEW I,N
	DO COL(.SCHEMA,1,"id","Event","text",100,0,1),COL(.SCHEMA,2,"action","Action","text",150,0,1),COL(.SCHEMA,3,"actor","Actor","text",160,0,1),COL(.SCHEMA,4,"target","Target","text",220,0,1),COL(.SCHEMA,5,"reason","Reason","text",260,0,0),COL(.SCHEMA,6,"at","Timestamp","text",160,0,1)
	SET N=0,I=0 FOR  SET I=$ORDER(^MIO("MIOOS","PERM","AUDIT",I)) QUIT:I'>0  DO
	. SET N=N+1,ROWS(N,"id")=I,ROWS(N,"action")=$GET(^MIO("MIOOS","PERM","AUDIT",I,"action")),ROWS(N,"actor")=$GET(^MIO("MIOOS","PERM","AUDIT",I,"actor")),ROWS(N,"target")=$GET(^MIO("MIOOS","PERM","AUDIT",I,"target")),ROWS(N,"reason")=$GET(^MIO("MIOOS","PERM","AUDIT",I,"reason")),ROWS(N,"at")=$GET(^MIO("MIOOS","PERM","AUDIT",I,"at"))
	QUIT
	;
UPSERT(STATE,CONF,TREE,OUT,ERR)
	NEW KIND,KEY,NAME,DESC,CAT
	KILL OUT,ERR SET ERR("routine")="MIOOSPERM"
	DO INIT(.CONF)
	IF '$$ISADMIN(.STATE) SET ERR("error")="permission_denied" QUIT 0
	SET KIND=$GET(TREE("kind")),KEY=$GET(TREE("key")),NAME=$GET(TREE("name")),DESC=$GET(TREE("description")),CAT=$GET(TREE("category"))
	IF KEY="" SET ERR("error")="key_required" QUIT 0
	IF NAME="" SET NAME=KEY
	IF KIND="permission" DO PERM(KEY,NAME,$SELECT(CAT'="":CAT,1:"Custom"),DESC,+$GET(TREE("phi")),+$GET(TREE("sensitive")))
	IF KIND="group" DO GROUP(KEY,NAME,DESC,0)
	IF KIND="profile" DO PROFILE(KEY,NAME,DESC,0,+$GET(TREE("minimumNecessary"),1),+$GET(TREE("breakGlassAllowed"),0))
	IF KIND'="permission",KIND'="group",KIND'="profile" SET ERR("error")="kind_invalid" QUIT 0
	DO AUDIT(.STATE,"permission.upsert",KIND_":"_KEY,$GET(TREE("reason")))
	SET OUT("ok")=1,OUT("kind")=KIND,OUT("key")=KEY
	QUIT 1
	;
DELETE(STATE,CONF,TREE,OUT,ERR)
	NEW KIND,KEY
	KILL OUT,ERR SET ERR("routine")="MIOOSPERM"
	DO INIT(.CONF)
	IF '$$ISADMIN(.STATE) SET ERR("error")="permission_denied" QUIT 0
	SET KIND=$GET(TREE("kind")),KEY=$GET(TREE("key")) IF KEY="" SET ERR("error")="key_required" QUIT 0
	IF KIND="permission" KILL ^MIO("MIOOS","PERM","PERMISSION",KEY)
	IF KIND="group" KILL ^MIO("MIOOS","PERM","GROUP",KEY)
	IF KIND="profile" KILL ^MIO("MIOOS","PERM","PROFILE",KEY)
	IF KIND="assignment" KILL ^MIO("MIOOS","PERM","ASSIGN",KEY)
	IF KIND'="permission",KIND'="group",KIND'="profile",KIND'="assignment" SET ERR("error")="kind_invalid" QUIT 0
	DO AUDIT(.STATE,"permission.delete",KIND_":"_KEY,$GET(TREE("reason")))
	SET OUT("ok")=1,OUT("deleted")=1,OUT("kind")=KIND,OUT("key")=KEY
	QUIT 1
	;
ASSIGNCMD(STATE,CONF,TREE,OUT,ERR)
	NEW TYPE,PRINCIPAL,PROFILE
	KILL OUT,ERR SET ERR("routine")="MIOOSPERM"
	DO INIT(.CONF)
	IF '$$ISADMIN(.STATE) SET ERR("error")="permission_denied" QUIT 0
	SET TYPE=$GET(TREE("principalType"),"user"),PRINCIPAL=$GET(TREE("principal")),PROFILE=$GET(TREE("profileKey"))
	IF PRINCIPAL="" SET ERR("error")="principal_required" QUIT 0
	IF PROFILE="" SET ERR("error")="profile_required" QUIT 0
	IF '$DATA(^MIO("MIOOS","PERM","PROFILE",PROFILE)) SET ERR("error")="profile_unknown" QUIT 0
	DO ASSIGN(TYPE,PRINCIPAL,PROFILE,$GET(TREE("reason")))
	DO AUDIT(.STATE,"permission.assign",TYPE_":"_PRINCIPAL_":"_PROFILE,$GET(TREE("reason")))
	SET OUT("ok")=1,OUT("assigned")=1,OUT("principalType")=TYPE,OUT("principal")=PRINCIPAL,OUT("profileKey")=PROFILE
	QUIT 1
	;
AUDIT(STATE,ACTION,TARGET,REASON)
	NEW N
	SET N=$INCREMENT(^MIO("MIOOS","PERM","AUDIT"))
	SET ^MIO("MIOOS","PERM","AUDIT",N,"id")=N
	SET ^MIO("MIOOS","PERM","AUDIT",N,"action")=$GET(ACTION)
	SET ^MIO("MIOOS","PERM","AUDIT",N,"target")=$GET(TARGET)
	SET ^MIO("MIOOS","PERM","AUDIT",N,"actor")=$GET(STATE("principal"),"system")
	SET ^MIO("MIOOS","PERM","AUDIT",N,"reason")=$GET(REASON)
	SET ^MIO("MIOOS","PERM","AUDIT",N,"at")=$HOROLOG
	QUIT
	;
