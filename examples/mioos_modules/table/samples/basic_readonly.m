TBASICRO ; Basic read-only MIOOS table sample
 ; Edit this routine or copy the SET blocks into your module seed routine.
 ; Globals: ^MIO("MIOOS","TABLE",USER,"sample-readonly",...)
SEED(USER)
 NEW ROOT,MOD
 SET USER=$GET(USER,"admin")
 SET ROOT=$NAME(^MIO("MIOOS","TABLE",USER,"sample-readonly"))
 KILL @ROOT
 SET @ROOT@("schema","columns",1,"key")="id",@ROOT@("schema","columns",1,"label")="ID",@ROOT@("schema","columns",1,"type")="text",@ROOT@("schema","columns",1,"width")=120
 SET @ROOT@("schema","columns",2,"key")="title",@ROOT@("schema","columns",2,"label")="Title",@ROOT@("schema","columns",2,"type")="text",@ROOT@("schema","columns",2,"width")=260
 SET @ROOT@("schema","columns",3,"key")="status",@ROOT@("schema","columns",3,"label")="Status",@ROOT@("schema","columns",3,"type")="select",@ROOT@("schema","columns",3,"width")=120
 SET @ROOT@("rows",1,"id")="ro-1",@ROOT@("rows",1,"title")="Read-only sample",@ROOT@("rows",1,"status")="Open"
 SET @ROOT@("rows",2,"id")="ro-2",@ROOT@("rows",2,"title")="No actions column",@ROOT@("rows",2,"status")="Done"
 SET @ROOT@("validation","fields","status","enum",1)="Open",@ROOT@("validation","fields","status","enum",2)="Done"
 ; Register an App Catalogue/desktop module entry. Persist MOD through your module registry routine.
 KILL MOD
 SET MOD("key")="sample-readonly"
 SET MOD("title")="Read-only Table"
 SET MOD("icon")="▦"
 SET MOD("componentKey")="table"
 SET MOD("surface")="mioos-surface-table"
 SET MOD("tableState","dataset")="sample-readonly"
 SET MOD("tableState","config","contract")="mioos-advanced-table-v8"
 SET MOD("tableState","config","features","rowCrud")=0
 SET MOD("tableState","config","features","columnCrud")=0
 SET MOD("tableState","config","features","selection")=0
 SET MOD("tableState","config","features","bulkActions")=0
 SET MOD("tableState","config","features","rowDetails")=0
 QUIT
 ; Run: ZLINK "TBASICRO" DO SEED^TBASICRO("admin") ZLINK "MIOOST" DO ^MIOOST
 ; Open: sign in as USER, open App Catalogue, choose Read-only Table.
