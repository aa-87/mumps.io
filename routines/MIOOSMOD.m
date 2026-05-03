MIOOSMOD ; MIOOS UI module registry
	QUIT
	;
LOAD(STATE,CONF)
	NEW OUT,ERR
	KILL OUT,ERR,STATE("modules"),STATE("uiModules")
	IF '+$GET(CONF("mioos","modules","enabled"),0) DO DISABLED(.STATE) QUIT
	IF '+$GET(CONF("mioos","modules","appCatalogEnabled"),0) DO DISABLED(.STATE) QUIT
	IF '$$CATALOG(.STATE,.CONF,.OUT,.ERR) DO  QUIT
	. SET STATE("moduleCount")=0
	. SET STATE("uiModules","ok")=0
	. SET STATE("uiModules","error")=$GET(ERR("error"),"module_catalog_failed")
	MERGE STATE("uiModules")=OUT
	MERGE STATE("modules")=OUT("modules")
	SET STATE("moduleCount")=+$GET(OUT("moduleCount"),0)
	SET STATE("moduleManifestVersion")=+$GET(OUT("manifestVersion"),1)
	SET STATE("moduleAppCatalogEnabled")=1
	SET STATE("moduleSystemEnabled")=1
	QUIT
	;
DISABLED(STATE)
	KILL STATE("modules"),STATE("uiModules")
	SET STATE("moduleCount")=0
	SET STATE("uiModules","ok")=1
	SET STATE("uiModules","contract")="mioos-ui-module-v1"
	SET STATE("uiModules","manifestVersion")=+$GET(STATE("moduleManifestVersion"),1)
	SET STATE("uiModules","moduleCount")=0
	SET STATE("uiModules","componentCount")=0
	SET STATE("uiModules","disabled")=1
	SET STATE("moduleSystemEnabled")=0
	SET STATE("moduleAppCatalogEnabled")=0
	QUIT
	;
CATALOG(STATE,CONF,OUT,ERR)
	NEW TIN,TOUT,TERR
	KILL OUT,ERR
	SET OUT("ok")=1
	SET OUT("contract")="mioos-ui-module-v1"
	SET OUT("manifestVersion")=1
	SET OUT("sources",1)="internal"
	SET OUT("sources",2)="user"
	SET OUT("componentCount")=0
	SET OUT("moduleCount")=0
	DO INTERNAL(.OUT)
	DO USER(.STATE,.OUT)
	KILL TIN,TOUT,TERR
	SET TIN("action")="list"
	IF $$LIST^MIOOSMTBL(.STATE,.CONF,.TIN,.TOUT,.TERR) DO
	. SET OUT("tableModuleLibrary","contract")=$GET(TOUT("contract"),"mioos-table-module-library-v1")
	. SET OUT("tableModuleLibrary","count")=+$GET(TOUT("count"),0)
	. IF $DATA(TOUT("definitions")) MERGE OUT("tableDefinitions")=TOUT("definitions")
	QUIT 1
	;
INTERNAL(OUT)
	NEW C,M
	SET C=+$GET(OUT("componentCount"))+1,OUT("componentCount")=C
	SET OUT("components",C,"key")="table"
	SET OUT("components",C,"name")="mioos-full-table"
	SET OUT("components",C,"title")="Advanced Backend Table"
	SET OUT("components",C,"surface")="mioos-surface-table"
	SET OUT("components",C,"source")="internal"
	SET OUT("components",C,"owner")="MIOOS"
	SET OUT("components",C,"description")="Server-side MUMPS table with WebSocket query, HTTP-safe mutations, dense layouts, server pagination, sorting, select-all, bulk actions, CRUD, resizing, column reorder, fixed columns, and massive datasets."
	SET OUT("components",C,"script")="/public/mioos/app/mioos_table.js"
	SET OUT("components",C,"backend")="MIOOSTBL"
	SET OUT("components",C,"queryRoute")="/api/mioos/table/query"
	SET OUT("components",C,"mutateRoute")="/api/mioos/table/mutate"
	SET OUT("components",C,"features",1)="backend-query"
	SET OUT("components",C,"features",2)="server-sorting"
	SET OUT("components",C,"features",3)="select-all-visible"
	SET OUT("components",C,"features",4)="bulk-actions"
	SET OUT("components",C,"features",5)="row-crud"
	SET OUT("components",C,"features",6)="column-crud"
	SET OUT("components",C,"features",7)="resizable-columns"
	SET OUT("components",C,"features",8)="server-query"
	SET OUT("components",C,"features",9)="http-safe-mutations"
	SET OUT("components",C,"features",10)="column-reorder"
	SET OUT("components",C,"features",11)="fixed-columns"
	SET C=+$GET(OUT("componentCount"))+1,OUT("componentCount")=C
	SET OUT("components",C,"key")="table-showcase"
	SET OUT("components",C,"name")="mioos-surface-table-showcase"
	SET OUT("components",C,"title")="Table Variations"
	SET OUT("components",C,"surface")="mioos-surface-table-showcase"
	SET OUT("components",C,"source")="internal"
	SET OUT("components",C,"owner")="MIOOS"
	SET OUT("components",C,"description")="Simple-to-advanced MUMPS table contracts for backend developers."
	SET OUT("components",C,"script")="/public/mioos/app/mioos_table.js"
	SET OUT("components",C,"features",1)="table-variants"
	SET OUT("components",C,"features",2)="copyable-code"
	SET C=+$GET(OUT("componentCount"))+1,OUT("componentCount")=C
	SET OUT("components",C,"key")="permissions"
	SET OUT("components",C,"name")="mioos-surface-permissions"
	SET OUT("components",C,"title")="Permissions UI"
	SET OUT("components",C,"surface")="mioos-surface-permissions"
	SET OUT("components",C,"source")="internal"
	SET OUT("components",C,"owner")="MIOOS"
	SET OUT("components",C,"description")="Permission tabs, role matrix, and audit sample for module developers."
	SET OUT("components",C,"script")="/public/mioos/app/mioos_permissions.js"
	SET C=+$GET(OUT("componentCount"))+1,OUT("componentCount")=C
	SET OUT("components",C,"key")="ui-elements"
	SET OUT("components",C,"name")="mioos-surface-ui-elements"
	SET OUT("components",C,"title")="UI + Form Elements"
	SET OUT("components",C,"surface")="mioos-surface-ui-elements"
	SET OUT("components",C,"source")="internal"
	SET OUT("components",C,"owner")="MIOOS"
	SET OUT("components",C,"description")="Interactive component gallery covering inputs, choices, validation, upload metadata, toasts, dialogs, sections, and module-safe form composition."
	SET OUT("components",C,"script")="/public/mioos/app/mioos_modules.js"
	SET OUT("components",C,"features",1)="interactive-forms"
	SET OUT("components",C,"features",2)="validation-states"
	SET OUT("components",C,"features",3)="modal-confirmation"
	SET OUT("components",C,"features",4)="http-upload-pattern"
	SET M=+$GET(OUT("moduleCount"))+1,OUT("moduleCount")=M
	SET OUT("modules",M,"id")="mioos.ui.modules"
	SET OUT("modules",M,"key")="app-catalog"
	SET OUT("modules",M,"appKey")="app-catalog"
	SET OUT("modules",M,"title")="App Catalogue"
	SET OUT("modules",M,"description")="Catalog and launcher for internal and user-created MIOOS UI modules."
	SET OUT("modules",M,"category")="Development"
	SET OUT("modules",M,"icon")="▦"
	SET OUT("modules",M,"source")="internal"
	SET OUT("modules",M,"builtIn")=1
	SET OUT("modules",M,"componentKey")="module-catalog"
	SET OUT("modules",M,"surface")="mioos-surface-ui-modules"
	SET M=+$GET(OUT("moduleCount"))+1,OUT("moduleCount")=M
	SET OUT("modules",M,"id")="mioos.ui.table.samples"
	SET OUT("modules",M,"key")="table-samples"
	SET OUT("modules",M,"appKey")="table-samples"
	SET OUT("modules",M,"title")="Table Samples"
	SET OUT("modules",M,"description")="Simple-to-advanced table variations with copyable MUMPS contracts."
	SET OUT("modules",M,"category")="Samples"
	SET OUT("modules",M,"icon")="▤"
	SET OUT("modules",M,"source")="internal"
	SET OUT("modules",M,"builtIn")=1
	SET OUT("modules",M,"componentKey")="table-showcase"
	SET OUT("modules",M,"surface")="mioos-surface-table-showcase"
	DO ADDTABLE(.OUT,"mioos.ui.table.massive","table-massive","Massive Dataset Table","Large synthetic dataset for pagination and sorting validation.","Samples","▥","massive")
	DO ADDTABLE(.OUT,"mioos.ui.patient.registration","patient-registration","Patient Registration","Detailed patient registration sample backed by MIOOSTBL persistence.","Healthcare","🏥","patient-registration")
	SET M=+$GET(OUT("moduleCount"))+1,OUT("moduleCount")=M
	SET OUT("modules",M,"id")="mioos.ui.elements"
	SET OUT("modules",M,"key")="ui-elements"
	SET OUT("modules",M,"appKey")="ui-elements"
	SET OUT("modules",M,"title")="UI + Form Elements"
	SET OUT("modules",M,"description")="Interactive, stateful component gallery for module developers."
	SET OUT("modules",M,"category")="Samples"
	SET OUT("modules",M,"icon")="🧩"
	SET OUT("modules",M,"source")="internal"
	SET OUT("modules",M,"builtIn")=1
	SET OUT("modules",M,"componentKey")="ui-elements"
	SET OUT("modules",M,"surface")="mioos-surface-ui-elements"
	SET M=+$GET(OUT("moduleCount"))+1,OUT("moduleCount")=M
	SET OUT("modules",M,"id")="mioos.ui.permissions"
	SET OUT("modules",M,"key")="permissions"
	SET OUT("modules",M,"appKey")="permissions"
	SET OUT("modules",M,"title")="Permissions UI"
	SET OUT("modules",M,"description")="Tabbed permission matrix and audit sample."
	SET OUT("modules",M,"category")="Security"
	SET OUT("modules",M,"icon")="🛡"
	SET OUT("modules",M,"source")="internal"
	SET OUT("modules",M,"builtIn")=1
	SET OUT("modules",M,"componentKey")="permissions"
	SET OUT("modules",M,"surface")="mioos-surface-permissions"
	SET OUT("examples",1,"key")="table"
	SET OUT("examples",1,"title")="Advanced Table Samples"
	SET OUT("examples",1,"path")="examples/mioos_modules/table"
	SET OUT("examples",1,"componentKey")="table-showcase"
	SET OUT("examples",1,"surface")="mioos-surface-table-showcase"
	SET OUT("examples",2,"key")="ui-elements"
	SET OUT("examples",2,"title")="UI + Form Elements"
	SET OUT("examples",2,"path")="examples/mioos_modules/ui_elements"
	SET OUT("examples",2,"componentKey")="ui-elements"
	SET OUT("examples",2,"surface")="mioos-surface-ui-elements"
	SET OUT("examples",3,"key")="patient-registration"
	SET OUT("examples",3,"title")="Patient Registration"
	SET OUT("examples",3,"path")="examples/mioos_modules/patient_registration"
	SET OUT("examples",3,"componentKey")="table"
	QUIT
	;
ADDTABLE(OUT,ID,KEY,TITLE,DESC,CAT,ICON,DATASET)
	NEW M
	SET M=+$GET(OUT("moduleCount"))+1,OUT("moduleCount")=M
	SET OUT("modules",M,"id")=ID
	SET OUT("modules",M,"key")=KEY
	SET OUT("modules",M,"appKey")=KEY
	SET OUT("modules",M,"title")=TITLE
	SET OUT("modules",M,"description")=DESC
	SET OUT("modules",M,"category")=CAT
	SET OUT("modules",M,"icon")=ICON
	SET OUT("modules",M,"source")="internal"
	SET OUT("modules",M,"builtIn")=1
	SET OUT("modules",M,"componentKey")="table"
	SET OUT("modules",M,"surface")="mioos-surface-table"
	SET OUT("modules",M,"tableState","id")=KEY_"-table"
	SET OUT("modules",M,"tableState","title")=TITLE
	SET OUT("modules",M,"tableState","dataset")=DATASET
	IF DATASET="patient-registration" DO
	. SET OUT("modules",M,"tableState","config","contract")="mioos-advanced-table-v8"
	. SET OUT("modules",M,"tableState","config","defaultPageSize")=25
	. SET OUT("modules",M,"tableState","config","defaultSort","column")="lastName"
	. SET OUT("modules",M,"tableState","config","defaultSort","direction")="ascending"
	. SET OUT("modules",M,"tableState","config","features","cellEditing")=1
	. SET OUT("modules",M,"tableState","config","features","columnReorder")=1
	. SET OUT("modules",M,"tableState","config","features","fixedColumns")=1
	. SET OUT("modules",M,"tableState","config","features","rowDetails")=1
	. SET OUT("modules",M,"tableState","config","features","filters")=1
	. SET OUT("modules",M,"tableState","config","features","grouping")=1
	. SET OUT("modules",M,"tableState","config","fixedColumns","start")=1
	. SET OUT("modules",M,"tableState","config","fixedColumns","end")=0
	. SET OUT("modules",M,"capabilities","patient-registration")=1
	. SET OUT("modules",M,"capabilities","intake-workflow")=1
	. SET OUT("modules",M,"capabilities","duplicate-detection")=1
	. SET OUT("modules",M,"capabilities","status-transitions")=1
	IF DATASET="massive" DO
	. SET OUT("modules",M,"tableState","config","contract")="mioos-advanced-table-v8"
	. SET OUT("modules",M,"tableState","config","defaultPageSize")=100
	. SET OUT("modules",M,"tableState","config","defaultSort","column")="id"
	. SET OUT("modules",M,"tableState","config","defaultSort","direction")="ascending"
	. SET OUT("modules",M,"tableState","config","features","rowCrud")=0
	. SET OUT("modules",M,"tableState","config","features","columnCrud")=0
	. SET OUT("modules",M,"tableState","config","features","selection")=0
	. SET OUT("modules",M,"tableState","config","features","bulkActions")=0
	. SET OUT("modules",M,"tableState","config","features","rowDetails")=0
	. SET OUT("modules",M,"tableState","config","features","columnReorder")=0
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
	. IF $GET(@ROOT@(KEY,"dataset"))'="" SET OUT("modules",M,"dataset")=$GET(@ROOT@(KEY,"dataset"))
	. IF $DATA(@ROOT@(KEY,"tableState")) MERGE OUT("modules",M,"tableState")=@ROOT@(KEY,"tableState")
	. IF $DATA(@ROOT@(KEY,"config")) MERGE OUT("modules",M,"config")=@ROOT@(KEY,"config")
	. IF $DATA(@ROOT@(KEY,"capabilities")) MERGE OUT("modules",M,"capabilities")=@ROOT@(KEY,"capabilities")
	QUIT
	;
