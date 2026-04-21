MIOOSMOD ; MIOOS custom module registry and installer
	QUIT
	;
LOAD(STATE,CONF)
	NEW USER,N
	SET N=+$GET(STATE("moduleCount"),0)
	DO LOADSYS(.STATE,.N)
	SET USER=$GET(STATE("principal"))
	IF USER'="",USER'="guest" DO LOADUSR(.STATE,.N,USER)
	SET STATE("moduleCount")=N
	QUIT
	;
LOADSYS(STATE,N)
	NEW ID
	SET ID="" FOR  SET ID=$ORDER(^MIO("MIOOS","MODULE","MANIFEST","system",ID)) QUIT:ID=""  DO
	. DO LOADONE(.STATE,.N,"system","",ID)
	QUIT
	;
LOADUSR(STATE,N,USER)
	NEW ID
	SET ID="" FOR  SET ID=$ORDER(^MIO("MIOOS","MODULE","MANIFEST","user",$GET(USER),ID)) QUIT:ID=""  DO
	. DO LOADONE(.STATE,.N,"user",$GET(USER),ID)
	QUIT
	;
LOADONE(STATE,N,SCOPE,OWNER,ID)
	NEW ROOT
	SET ROOT=$$ROOT($GET(SCOPE),$GET(OWNER),$GET(ID))
	QUIT:'$DATA(@ROOT)
	QUIT:+$GET(@ROOT@("enabled"),1)'=1
	SET N=N+1
	SET STATE("modules",N,"id")=$GET(ID)
	SET STATE("modules",N,"appKey")=$SELECT($GET(@ROOT@("appKey"))'="":$GET(@ROOT@("appKey")),1:$GET(ID))
	SET STATE("modules",N,"windowId")=$SELECT($GET(@ROOT@("windowId"))'="":$GET(@ROOT@("windowId")),1:"win-"_$GET(ID))
	SET STATE("modules",N,"title")=$GET(@ROOT@("title"),$GET(ID))
	SET STATE("modules",N,"subtitle")=$GET(@ROOT@("subtitle"))
	SET STATE("modules",N,"description")=$GET(@ROOT@("description"))
	SET STATE("modules",N,"icon")=$SELECT($GET(@ROOT@("icon"))'="":$GET(@ROOT@("icon")),1:"🧩")
	SET STATE("modules",N,"category")=$SELECT($GET(@ROOT@("category"))'="":$GET(@ROOT@("category")),1:"general")
	SET STATE("modules",N,"version")=$SELECT($GET(@ROOT@("version"))'="":$GET(@ROOT@("version")),1:"1.0")
	SET STATE("modules",N,"kind")="module"
	SET STATE("modules",N,"surface")=$SELECT($GET(@ROOT@("surface"))'="":$GET(@ROOT@("surface")),1:"generic")
	SET STATE("modules",N,"windowTitle")=$SELECT($GET(@ROOT@("windowTitle"))'="":$GET(@ROOT@("windowTitle")),1:$GET(@ROOT@("title"),$GET(ID)))
	SET STATE("modules",N,"installed")=1
	SET STATE("modules",N,"enabled")=1
	SET STATE("modules",N,"builtIn")=0
	SET STATE("modules",N,"singleton")=+$GET(@ROOT@("singleton"),1)
	SET STATE("modules",N,"launcherEnabled")=+$GET(@ROOT@("launcherEnabled"),1)
	SET STATE("modules",N,"scope")=$GET(SCOPE)
	SET STATE("modules",N,"owner")=$GET(OWNER)
	SET STATE("modules",N,"permissionsTarget")="module:"_$GET(ID)
	MERGE STATE("modules",N,"cards")=@ROOT@("cards")
	MERGE STATE("modules",N,"params")=@ROOT@("params")
	QUIT
	;
INSTALL(STATE,CONF,TREE,OUT,ERR)
	NEW USER,SCOPE,ID,ROOT,OWNER
	KILL OUT,ERR
	SET ERR("routine")="MIOOSMOD"
	IF +$GET(STATE("authenticated"),0)'=1 SET ERR("error")="login_required" QUIT 0
	SET USER=$GET(STATE("principal"))
	IF USER=""!(USER="guest") SET ERR("error")="login_required" QUIT 0
	SET SCOPE=$$LOW^MIOUTIL($$TRIM^MIOUTIL($GET(TREE("scope")))) IF SCOPE="" SET SCOPE="user"
	IF (SCOPE'="user"),(SCOPE'="system") SET ERR("error")="scope_invalid" QUIT 0
	IF SCOPE="system",+$GET(STATE("authAdmin"),0)'=1 SET ERR("error")="access_denied" QUIT 0
	SET ID=$$CANONID($GET(TREE("id"))) IF ID="" SET ERR("error")="module_id_invalid" QUIT 0
	SET OWNER=$SELECT(SCOPE="system":"",1:USER)
	SET ROOT=$$ROOT(SCOPE,OWNER,ID)
	SET @ROOT@("id")=ID
	SET @ROOT@("appKey")=$$APPKEY($GET(TREE("appKey")),ID)
	SET @ROOT@("windowId")=$$WINID($GET(TREE("windowId")),ID)
	SET @ROOT@("title")=$SELECT($GET(TREE("title"))'="":$GET(TREE("title")),1:ID)
	SET @ROOT@("subtitle")=$GET(TREE("subtitle"))
	SET @ROOT@("description")=$GET(TREE("description"))
	SET @ROOT@("icon")=$SELECT($GET(TREE("icon"))'="":$GET(TREE("icon")),1:"🧩")
	SET @ROOT@("category")=$SELECT($GET(TREE("category"))'="":$$LOW^MIOUTIL($GET(TREE("category"))),1:"general")
	SET @ROOT@("version")=$SELECT($GET(TREE("version"))'="":$GET(TREE("version")),1:"1.0")
	SET @ROOT@("surface")=$$SURFACE($GET(TREE("surface")))
	SET @ROOT@("windowTitle")=$SELECT($GET(TREE("windowTitle"))'="":$GET(TREE("windowTitle")),1:$GET(@ROOT@("title")))
	SET @ROOT@("enabled")=+$SELECT($DATA(TREE("enabled")):$GET(TREE("enabled")),1:1)
	SET @ROOT@("launcherEnabled")=+$SELECT($DATA(TREE("launcherEnabled")):$GET(TREE("launcherEnabled")),1:1)
	SET @ROOT@("singleton")=+$SELECT($DATA(TREE("singleton")):$GET(TREE("singleton")),1:1)
	SET @ROOT@("scope")=$GET(SCOPE)
	SET @ROOT@("owner")=$GET(OWNER)
	SET @ROOT@("updatedAt")=$$NOWISO^MIOUTIL()
	SET @ROOT@("updatedBy")=USER
	IF $GET(@ROOT@("createdAt"))="" SET @ROOT@("createdAt")=$$NOWISO^MIOUTIL()
	KILL @ROOT@("cards") MERGE @ROOT@("cards")=TREE("cards")
	KILL @ROOT@("params") MERGE @ROOT@("params")=TREE("params")
	SET OUT("installed")=1
	SET OUT("scope")=$GET(SCOPE)
	SET OUT("moduleId")=ID
	SET OUT("owner")=$GET(OWNER)
	SET OUT("surface")=$GET(@ROOT@("surface"))
	QUIT 1
	;
REMOVE(STATE,CONF,TREE,OUT,ERR)
	NEW ID,SCOPE,USER,ROOT,OWNER
	KILL OUT,ERR
	SET ERR("routine")="MIOOSMOD"
	SET ID=$$CANONID($GET(TREE("id"))) IF ID="" SET ERR("error")="module_id_missing" QUIT 0
	SET USER=$GET(STATE("principal"),"guest")
	SET SCOPE=$$LOW^MIOUTIL($$TRIM^MIOUTIL($GET(TREE("scope"))))
	SET ROOT="",OWNER=""
	IF SCOPE="system" DO
	. IF +$GET(STATE("authAdmin"),0)'=1 SET ERR("error")="access_denied" QUIT
	. SET ROOT=$$ROOT("system","",ID),OWNER="",SCOPE="system"
	ELSE  IF SCOPE="user" DO
	. SET OWNER=$SELECT($GET(TREE("owner"))'="":$GET(TREE("owner")),1:USER)
	. IF OWNER'=USER,+$GET(STATE("authAdmin"),0)'=1 SET ERR("error")="access_denied" QUIT
	. SET ROOT=$$ROOT("user",OWNER,ID)
	. IF '$DATA(@ROOT),+$GET(STATE("authAdmin"),0)=1 SET OWNER=$$FINDOWNER(ID),ROOT=$$ROOT("user",OWNER,ID)
	ELSE  DO
	. SET ROOT=$$ROOT("user",USER,ID),OWNER=USER,SCOPE="user"
	. IF '$DATA(@ROOT),+$GET(STATE("authAdmin"),0)=1 SET ROOT=$$ROOT("system","",ID),OWNER="",SCOPE="system"
	. IF '$DATA(@ROOT),+$GET(STATE("authAdmin"),0)=1 SET OWNER=$$FINDOWNER(ID),ROOT=$$ROOT("user",OWNER,ID),SCOPE="user"
	IF $GET(ERR("error"))'="" QUIT 0
	IF ROOT=""!('$DATA(@ROOT)) SET ERR("error")="module_not_found" QUIT 0
	IF SCOPE="system",+$GET(STATE("authAdmin"),0)'=1 SET ERR("error")="access_denied" QUIT 0
	KILL @ROOT
	SET OUT("removed")=1
	SET OUT("moduleId")=ID
	SET OUT("scope")=$GET(SCOPE)
	SET OUT("owner")=$GET(OWNER)
	QUIT 1
	;
ROOT(SCOPE,OWNER,ID)
	IF $GET(SCOPE)="system" QUIT $NAME(^MIO("MIOOS","MODULE","MANIFEST","system",$GET(ID)))
	QUIT $NAME(^MIO("MIOOS","MODULE","MANIFEST","user",$GET(OWNER),$GET(ID)))
	;
FINDOWNER(ID)
	NEW USER,FOUND
	SET (USER,FOUND)=""
	FOR  SET USER=$ORDER(^MIO("MIOOS","MODULE","MANIFEST","user",USER)) QUIT:USER=""  DO  QUIT:FOUND'=""
	. IF $DATA(^MIO("MIOOS","MODULE","MANIFEST","user",USER,$GET(ID))) SET FOUND=USER
	QUIT FOUND
	;
CANONID(ID)
	NEW X,I,C,OUT
	SET X=$$LOW^MIOUTIL($$TRIM^MIOUTIL($GET(ID)))
	SET OUT=""
	FOR I=1:1:$LENGTH(X) DO
	. SET C=$EXTRACT(X,I)
	. IF (C?1AN)!(C="-")!(C="_") SET OUT=OUT_C
	IF OUT="" QUIT ""
	IF $EXTRACT(OUT,1,7)'="module-" SET OUT="module-"_OUT
	QUIT OUT
	;
APPKEY(X,ID)
	NEW Y
	SET Y=$$LOW^MIOUTIL($$TRIM^MIOUTIL($GET(X)))
	IF Y="" QUIT $GET(ID)
	QUIT $$CANONID(Y)
	;
WINID(X,ID)
	NEW Y
	SET Y=$$LOW^MIOUTIL($$TRIM^MIOUTIL($GET(X)))
	IF Y="" QUIT "win-"_$GET(ID)
	QUIT $$CANONID(Y)
	;
SURFACE(X)
	NEW Y
	SET Y=$$LOW^MIOUTIL($$TRIM^MIOUTIL($GET(X)))
	IF Y="" QUIT "generic"
	IF ",generic,notes-board,ops-overview,dashboard,records,reports,viewer,"[(","_Y_",") QUIT Y
	QUIT "generic"
	;
