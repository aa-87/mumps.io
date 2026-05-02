MIOOSMOD ; MIOOS UI module registry
	QUIT
	;
LOAD(STATE,CONF)
	NEW OUT,ERR
	KILL OUT,ERR,STATE("modules"),STATE("uiModules")
	IF '$$CATALOG(.STATE,.CONF,.OUT,.ERR) DO  QUIT
	. SET STATE("moduleCount")=0
	. SET STATE("uiModules","ok")=0
	. SET STATE("uiModules","error")=$GET(ERR("error"),"module_catalog_failed")
	MERGE STATE("uiModules")=OUT
	MERGE STATE("modules")=OUT("modules")
	SET STATE("moduleCount")=+$GET(OUT("moduleCount"),0)
	SET STATE("moduleManifestVersion")=+$GET(OUT("manifestVersion"),1)
	SET STATE("moduleAppCatalogEnabled")=+$GET(CONF("mioos","modules","appCatalogEnabled"),1)
	SET STATE("moduleSystemEnabled")=+$GET(CONF("mioos","modules","enabled"),1)
	QUIT
	;
CATALOG(STATE,CONF,OUT,ERR)
	KILL OUT,ERR
	SET OUT("ok")=1
	SET OUT("contract")="mioos-ui-module-v1"
	SET OUT("manifestVersion")=1
	SET OUT("sources",1)="internal"
	SET OUT("sources",2)="user"
	SET OUT("componentCount")=0
	SET OUT("moduleCount")=0
	DO INTERNAL(.OUT,.CONF)
	DO USER(.STATE,.OUT)
	QUIT 1
	;
INTERNAL(OUT,CONF)
	NEW C,M,TROUTE
	SET TROUTE=$GET(CONF("mioos","route","tableQuery"),"/api/mioos/table/query")
	SET C=+$GET(OUT("componentCount"))+1,OUT("componentCount")=C
	SET OUT("components",C,"key")="table"
	SET OUT("components",C,"name")="mioos-full-table"
	SET OUT("components",C,"title")="Backend Table"
	SET OUT("components",C,"surface")="mioos-surface-table"
	SET OUT("components",C,"source")="internal"
	SET OUT("components",C,"owner")="MIOOS"
	SET OUT("components",C,"description")="Backend-paginated, sortable, hideable, groupable, expandable, action-capable table."
	SET OUT("components",C,"script")="/public/mioos/app/mioos_table.js"
	SET OUT("components",C,"backend")="MIOOSTBL"
	SET OUT("components",C,"queryCommand")="table.query"
	SET OUT("components",C,"queryRoute")=TROUTE
	SET OUT("components",C,"transport")="mixed-http-websocket"
	SET OUT("components",C,"features",1)="backend-query"
	SET OUT("components",C,"features",2)="pagination"
	SET OUT("components",C,"features",3)="column-sort"
	SET OUT("components",C,"features",4)="column-visibility"
	SET OUT("components",C,"features",5)="column-grouping"
	SET OUT("components",C,"features",6)="expansion-rows"
	SET OUT("components",C,"features",7)="row-actions"
	SET OUT("components",C,"features",8)="bulk-actions"
	SET OUT("components",C,"features",9)="resizable-columns"
	SET OUT("components",C,"features",10)="resettable-state"
	SET M=+$GET(OUT("moduleCount"))+1,OUT("moduleCount")=M
	SET OUT("modules",M,"id")="mioos.ui.modules"
	SET OUT("modules",M,"key")="app-catalog"
	SET OUT("modules",M,"appKey")="app-catalog"
	SET OUT("modules",M,"title")="App Catalogue"
	SET OUT("modules",M,"description")="Catalogue and launcher for internal and user-created MIOOS UI modules."
	SET OUT("modules",M,"category")="Development"
	SET OUT("modules",M,"icon")="▦"
	SET OUT("modules",M,"source")="internal"
	SET OUT("modules",M,"builtIn")=1
	SET OUT("modules",M,"componentKey")="module-catalog"
	SET OUT("modules",M,"surface")="mioos-surface-ui-modules"
	SET M=+$GET(OUT("moduleCount"))+1,OUT("moduleCount")=M
	SET OUT("modules",M,"id")="mioos.ui.table"
	SET OUT("modules",M,"key")="mioos.ui.table"
	SET OUT("modules",M,"appKey")="mioos.ui.table"
	SET OUT("modules",M,"title")="Backend Table"
	SET OUT("modules",M,"description")="First reusable UI module component; renders MIOOSTBL datasets."
	SET OUT("modules",M,"category")="Components"
	SET OUT("modules",M,"icon")="▤"
	SET OUT("modules",M,"source")="internal"
	SET OUT("modules",M,"builtIn")=1
	SET OUT("modules",M,"componentKey")="table"
	SET OUT("modules",M,"surface")="mioos-surface-table"
	SET OUT("modules",M,"tableState","id")="mioos-ui-module-table-example"
	SET OUT("modules",M,"tableState","title")="Sample Table"
	SET OUT("modules",M,"tableState","dataset")="demo"
	SET OUT("examples",1,"key")="table"
	SET OUT("examples",1,"title")="Sample Table"
	SET OUT("examples",1,"path")="examples/mioos_modules/table"
	SET C=+$GET(OUT("componentCount"))+1,OUT("componentCount")=C
	SET OUT("components",C,"key")="permissions"
	SET OUT("components",C,"name")="mioos-permissions-admin"
	SET OUT("components",C,"title")="Permissions Admin"
	SET OUT("components",C,"surface")="mioos-surface-permissions"
	SET OUT("components",C,"source")="internal"
	SET OUT("components",C,"owner")="MIOOS"
	SET OUT("components",C,"description")="HIPAA-aligned permission, group, profile, assignment, and audit administration backed by reusable tables."
	SET OUT("components",C,"script")="/public/mioos/app/mioos_permissions.js"
	SET OUT("components",C,"transport")="mixed-http-websocket"
	SET OUT("components",C,"commands",1)="permission.upsert"
	SET OUT("components",C,"commands",2)="permission.delete"
	SET OUT("components",C,"commands",3)="permission.assign"
	SET OUT("components",C,"commands",4)="permission.effective"
	SET M=+$GET(OUT("moduleCount"))+1,OUT("moduleCount")=M
	SET OUT("modules",M,"id")="mioos.permissions.admin"
	SET OUT("modules",M,"key")="mioos.permissions.admin"
	SET OUT("modules",M,"appKey")="mioos.permissions.admin"
	SET OUT("modules",M,"title")="Permissions"
	SET OUT("modules",M,"description")="Administer HIPAA-aligned permissions, permission groups, profiles, assignments, and audit trail."
	SET OUT("modules",M,"category")="Security"
	SET OUT("modules",M,"icon")="🛡"
	SET OUT("modules",M,"source")="internal"
	SET OUT("modules",M,"builtIn")=1
	SET OUT("modules",M,"componentKey")="permissions"
	SET OUT("modules",M,"surface")="mioos-surface-permissions"
	SET OUT("modules",M,"requiredPermission")="mioos.permissions.admin"
	SET OUT("examples",2,"key")="permissions"
	SET OUT("examples",2,"title")="Permissions Admin Example"
	SET OUT("examples",2,"path")="examples/mioos_modules/permissions"
	SET OUT("examples",2,"componentKey")="permissions"
	QUIT
	;
USER(STATE,OUT)
	NEW USER,ROOT,KEY,M
	SET USER=$GET(STATE("principal"),"guest")
	IF USER="" SET USER="guest"
	SET ROOT=$NAME(^MIO("MIOOS","MODULE","USER",USER))
	SET KEY="" FOR  SET KEY=$ORDER(@ROOT@(KEY)) QUIT:KEY=""  DO
	. SET M=+$GET(OUT("moduleCount"))+1,OUT("moduleCount")=M
	. SET OUT("modules",M,"id")=KEY
	. SET OUT("modules",M,"key")=$GET(@ROOT@(KEY,"key"),KEY)
	. SET OUT("modules",M,"appKey")=$GET(@ROOT@(KEY,"appKey"),$GET(@ROOT@(KEY,"key"),KEY))
	. SET OUT("modules",M,"title")=$GET(@ROOT@(KEY,"title"),KEY)
	. SET OUT("modules",M,"description")=$GET(@ROOT@(KEY,"description"),"User-created UI module")
	. SET OUT("modules",M,"category")=$GET(@ROOT@(KEY,"category"),"User")
	. SET OUT("modules",M,"icon")=$GET(@ROOT@(KEY,"icon"),"▣")
	. SET OUT("modules",M,"source")="user"
	. SET OUT("modules",M,"componentKey")=$GET(@ROOT@(KEY,"componentKey"),"module-card")
	. SET OUT("modules",M,"surface")=$GET(@ROOT@(KEY,"surface"),"mioos-surface-ui-module")
	. IF $DATA(@ROOT@(KEY,"config")) MERGE OUT("modules",M,"config")=@ROOT@(KEY,"config")
	QUIT
	;
