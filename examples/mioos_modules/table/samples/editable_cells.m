TEDITCEL ; Editable cell table sample with a MUMPS callback
 ; Globals: ^MIO("MIOOS","TABLE",USER,"sample-editable-cells",...)
SEED(USER)
 NEW ROOT,MOD
 SET USER=$GET(USER,"admin"),ROOT=$NAME(^MIO("MIOOS","TABLE",USER,"sample-editable-cells"))
 KILL @ROOT
 SET @ROOT@("schema","columns",1,"key")="id",@ROOT@("schema","columns",1,"label")="ID",@ROOT@("schema","columns",1,"type")="text",@ROOT@("schema","columns",1,"editable")=0
 SET @ROOT@("schema","columns",2,"key")="summary",@ROOT@("schema","columns",2,"label")="Summary",@ROOT@("schema","columns",2,"type")="text",@ROOT@("schema","columns",2,"editable")=1
 SET @ROOT@("schema","columns",3,"key")="status",@ROOT@("schema","columns",3,"label")="Status",@ROOT@("schema","columns",3,"type")="select",@ROOT@("schema","columns",3,"editable")=1,@ROOT@("schema","columns",3,"cellCallback")="STATUS^TEDITCEL"
 SET @ROOT@("schema","columns",4,"key")="notes",@ROOT@("schema","columns",4,"label")="Notes",@ROOT@("schema","columns",4,"type")="textarea",@ROOT@("schema","columns",4,"editable")=1
 SET @ROOT@("rows",1,"id")="ec-1",@ROOT@("rows",1,"summary")="Click a cell",@ROOT@("rows",1,"status")="Draft",@ROOT@("rows",1,"notes")="Textarea cell"
 SET @ROOT@("validation","fields","summary","required")=1
 SET @ROOT@("validation","fields","status","enum",1)="Draft",@ROOT@("validation","fields","status","enum",2)="Ready",@ROOT@("validation","fields","status","enum",3)="Blocked"
 KILL MOD SET MOD("componentKey")="table",MOD("surface")="mioos-surface-table",MOD("icon")="✎",MOD("title")="Editable Cells"
 SET MOD("tableState","dataset")="sample-editable-cells",MOD("tableState","config","contract")="mioos-advanced-table-v8"
 SET MOD("tableState","config","features","cellEditing")=1,MOD("tableState","config","features","rowCrud")=1
 QUIT
STATUS(STATE,DATASET,ROWID,COLUMN,VALUE,OUT,ERR)
 IF VALUE="Blocked" DO  QUIT 0
 . SET ERR("error")="validation_failed",ERR("field")=COLUMN,ERR("message")="Blocked is not allowed in this sample",ERR("fieldErrors",COLUMN)="Blocked is not allowed in this sample"
 SET OUT("value")=VALUE
 QUIT 1
 ; Run: ZLINK "TEDITCEL" DO SEED^TEDITCEL("admin") ZLINK "MIOOSTBL" ZLINK "MIOOST" DO ^MIOOST
 ; Open: sign in as USER, choose Editable Cells from App Catalogue/desktop.
