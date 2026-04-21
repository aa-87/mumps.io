MIOOSPERM ; MIOOS shell and module permissions
	QUIT
	;
INIT(STATE,CONF)
	NEW I,ID,TITLE,TARGET
	DO ENSURE(.STATE,"system:permissions-report","Permission report","system","",1,0,"view,report")
	DO ENSURE(.STATE,"system:permissions-save","Permission editor","system","admin",0,0,"edit,manage")
	DO ENSURE(.STATE,"system:module-install-user","User module install","system","",1,0,"install,edit")
	DO ENSURE(.STATE,"system:module-install-system","System module install","system","admin",0,0,"install,manage")
	DO ENSURE(.STATE,"system:module-remove","Module removal","system","admin",0,0,"uninstall,manage")
	DO ENSURE(.STATE,"app:my-computer","My Computer","app","",1,1,"view,run,preview")
	DO ENSURE(.STATE,"app:documents","My Documents","app","",1,1,"view,run,preview")
	DO ENSURE(.STATE,"app:control-panel","Control Panel","app","",1,1,"view,run,edit")
	DO ENSURE(.STATE,"app:terminal","Terminal","app","",1,1,"view,run")
	DO ENSURE(.STATE,"app:theme-studio","Theme Studio","app","",1,1,"view,run,edit,preview")
	DO ENSURE(.STATE,"app:transfers","Transfers","app","",1,1,"view,run,preview")
	DO ENSURE(.STATE,"app:diagnostics","Diagnostics","app","",1,1,"view,run,report")
	DO ENSURE(.STATE,"app:app-catalog","App Catalog","app","",1,1,"view,run,install,preview")
	DO ENSURE(.STATE,"app:security-center","Security Center","app","",1,1,"view,run,report")
	DO ENSURE(.STATE,"app:debug-center","Debug Center","app","admin,developer",0,0,"view,run,report")
	SET I=0 FOR  SET I=$ORDER(STATE("modules",I)) QUIT:I'>0  DO
	. SET ID=$GET(STATE("modules",I,"id")) QUIT:ID=""
	. SET TITLE=$GET(STATE("modules",I,"title"),ID)
	. SET TARGET="module:"_ID
	. DO ENSURE(.STATE,TARGET,TITLE,"module","",1,1,"view,run,preview")
	QUIT
	;
ENSURE(STATE,TARGET,TITLE,TYPE,ROLES,AUTHOK,GUESTOK,ACTIONS)
	NEW ROOT
	SET ROOT=$NAME(^MIO("MIOOS","PERM","TARGET",$GET(TARGET)))
	SET @ROOT@("target")=$GET(TARGET)
	SET @ROOT@("title")=$GET(TITLE)
	SET @ROOT@("type")=$GET(TYPE)
	IF $GET(@ROOT@("roles"))="" SET @ROOT@("roles")=$$NORMCSV($GET(ROLES))
	IF '$DATA(@ROOT@("allowAuthenticated")) SET @ROOT@("allowAuthenticated")=+$GET(AUTHOK)
	IF '$DATA(@ROOT@("allowGuest")) SET @ROOT@("allowGuest")=+$GET(GUESTOK)
	IF $GET(@ROOT@("actions"))="" SET @ROOT@("actions")=$$NORMCSV($GET(ACTIONS))
	IF '$DATA(@ROOT@("enabled")) SET @ROOT@("enabled")=1
	QUIT
	;
ALLOW(STATE,TARGET,ACTION)
	NEW ROOT,ACT
	SET ROOT=$NAME(^MIO("MIOOS","PERM","TARGET",$GET(TARGET)))
	SET ACT=$$LOW^MIOUTIL($$TRIM^MIOUTIL($GET(ACTION)))
	IF '$DATA(@ROOT) QUIT 0
	IF +$GET(@ROOT@("enabled"))'=1 QUIT 0
	IF '$$INCSV($GET(@ROOT@("actions")),ACT) QUIT 0
	IF +$GET(STATE("authAdmin"),0)=1 QUIT 1
	IF $GET(STATE("principal"))="guest",+$GET(@ROOT@("allowGuest"))=1 QUIT 1
	IF +$GET(STATE("authenticated"),0)=1,+$GET(@ROOT@("allowAuthenticated"))=1 QUIT 1
	IF $$INTERSECT($GET(STATE("roles")),$GET(@ROOT@("roles"))) QUIT 1
	QUIT 0
	;
REPORT(STATE,CONF,OUT,ERR)
	NEW TARGET,N
	KILL OUT,ERR
	SET ERR("routine")="MIOOSPERM"
	SET OUT("enabled")=1
	SET OUT("editable")=+$GET(STATE("authAdmin"),0)
	SET OUT("principal")=$GET(STATE("principal"),"guest")
	SET OUT("scope")=$SELECT(+$GET(STATE("authAdmin"),0)=1:"all",1:"effective")
	SET OUT("model")="shell-target-action-matrix"
	SET OUT("adminRole")=$GET(CONF("mioos","auth","management","adminRole"),"admin")
	DO ACTIONS($NAME(OUT("actions")))
	SET (N,OUT("count"))=0
	SET TARGET="" FOR  SET TARGET=$ORDER(^MIO("MIOOS","PERM","TARGET",TARGET)) QUIT:TARGET=""  DO
	. SET N=N+1
	. DO ROW(.STATE,TARGET,$NAME(OUT("entries",N)))
	. SET OUT("count")=N
	QUIT 1
	;
SAVE(STATE,CONF,TREE,OUT,ERR)
	NEW TARGET,ROOT,ACTS
	KILL OUT,ERR
	SET ERR("routine")="MIOOSPERM"
	IF +$GET(STATE("authAdmin"),0)'=1 SET ERR("error")="access_denied" QUIT 0
	SET TARGET=$$TRIM^MIOUTIL($GET(TREE("target")))
	IF TARGET="" SET ERR("error")="target_missing" QUIT 0
	SET ROOT=$NAME(^MIO("MIOOS","PERM","TARGET",TARGET))
	IF '$DATA(@ROOT) SET @ROOT@("target")=TARGET
	IF $GET(TREE("title"))'="" SET @ROOT@("title")=$GET(TREE("title"))
	IF $GET(TREE("type"))'="" SET @ROOT@("type")=$GET(TREE("type"))
	SET @ROOT@("roles")=$$NORMCSV($GET(TREE("roles")))
	SET @ROOT@("allowAuthenticated")=+$GET(TREE("allowAuthenticated"))
	SET @ROOT@("allowGuest")=+$GET(TREE("allowGuest"))
	SET @ROOT@("enabled")=+$SELECT($DATA(TREE("enabled")):$GET(TREE("enabled")),1:1)
	SET ACTS=$GET(TREE("actionsCsv")) IF ACTS="" SET ACTS=$$TREEACT(.TREE)
	SET @ROOT@("actions")=$$NORMCSV(ACTS)
	SET @ROOT@("updatedAt")=$$NOWISO^MIOUTIL()
	SET @ROOT@("updatedBy")=$GET(STATE("principal"),"admin")
	SET OUT("saved")=1
	SET OUT("target")=TARGET
	DO ROW(.STATE,TARGET,$NAME(OUT("entry")))
	QUIT 1
	;
TREEACT(TREE)
	NEW I,X,OUT
	SET (I,OUT)=""
	FOR  SET I=$ORDER(TREE("actions",I)) QUIT:I=""  DO
	. SET X=$$LOW^MIOUTIL($$TRIM^MIOUTIL($GET(TREE("actions",I))))
	. QUIT:X=""
	. IF '$$INCSV(OUT,X) SET OUT=$SELECT(OUT="":X,1:OUT_","_X)
	QUIT OUT
	;
ROW(STATE,TARGET,ROOT)
	NEW R,ACTION,ACTCSV
	SET R=$NAME(^MIO("MIOOS","PERM","TARGET",$GET(TARGET)))
	KILL @ROOT
	SET @ROOT@("target")=$GET(TARGET)
	SET @ROOT@("title")=$GET(@R@("title"),$GET(TARGET))
	SET @ROOT@("type")=$GET(@R@("type"),"system")
	SET @ROOT@("roles")=$GET(@R@("roles"))
	SET @ROOT@("allowAuthenticated")=+$GET(@R@("allowAuthenticated"))
	SET @ROOT@("allowGuest")=+$GET(@R@("allowGuest"))
	SET @ROOT@("enabled")=+$GET(@R@("enabled"),1)
	SET ACTCSV=$GET(@R@("actions"))
	SET @ROOT@("actionsCsv")=ACTCSV
	SET @ROOT@("updatedAt")=$GET(@R@("updatedAt"))
	SET @ROOT@("updatedBy")=$GET(@R@("updatedBy"))
	SET @ROOT@("editable")=+$GET(STATE("authAdmin"),0)
	SET ACTION="view" F  Q:ACTION=""  DO  SET ACTION=$$NEXTACT(ACTION)
	. SET @ROOT@(ACTION)=+$$ALLOW(.STATE,$GET(TARGET),ACTION)
	QUIT
	;
NEXTACT(ACT)
	IF ACT="view" QUIT "run"
	IF ACT="run" QUIT "edit"
	IF ACT="edit" QUIT "preview"
	IF ACT="preview" QUIT "report"
	IF ACT="report" QUIT "install"
	IF ACT="install" QUIT "uninstall"
	IF ACT="uninstall" QUIT "manage"
	QUIT ""
	;
ACTIONS(ROOT)
	KILL @ROOT
	SET @ROOT@(1)="view"
	SET @ROOT@(2)="run"
	SET @ROOT@(3)="edit"
	SET @ROOT@(4)="preview"
	SET @ROOT@(5)="report"
	SET @ROOT@(6)="install"
	SET @ROOT@(7)="uninstall"
	SET @ROOT@(8)="manage"
	QUIT
	;
NORMCSV(CSV)
	NEW I,X,OUT
	SET OUT=""
	FOR I=1:1:$LENGTH($GET(CSV),",") DO
	. SET X=$$LOW^MIOUTIL($$TRIM^MIOUTIL($PIECE($GET(CSV),",",I)))
	. QUIT:X=""
	. IF '$$INCSV(OUT,X) SET OUT=$SELECT(OUT="":X,1:OUT_","_X)
	QUIT OUT
	;
INCSV(CSV,NEED)
	NEW I,X,FOUND
	SET NEED=$$LOW^MIOUTIL($$TRIM^MIOUTIL($GET(NEED)))
	IF NEED="" QUIT 0
	SET FOUND=0
	FOR I=1:1:$LENGTH($GET(CSV),",") DO  QUIT:FOUND
	. SET X=$$LOW^MIOUTIL($$TRIM^MIOUTIL($PIECE($GET(CSV),",",I)))
	. IF X=NEED SET FOUND=1
	QUIT FOUND
	;
INTERSECT(LEFT,RIGHT)
	NEW I,X,FOUND
	SET FOUND=0
	FOR I=1:1:$LENGTH($GET(LEFT),",") DO  QUIT:FOUND
	. SET X=$$LOW^MIOUTIL($$TRIM^MIOUTIL($PIECE($GET(LEFT),",",I)))
	. QUIT:X=""
	. IF $$INCSV($GET(RIGHT),X) SET FOUND=1
	QUIT FOUND
	;
