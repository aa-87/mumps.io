TGROUPFX ; Grouping, column visibility, reorder, and fixed-columns sample
SEED(USER)
 NEW ROOT,MOD
 SET USER=$GET(USER,"admin"),ROOT=$NAME(^MIO("MIOOS","TABLE",USER,"sample-group-fixed"))
 KILL @ROOT
 SET @ROOT@("schema","columns",1,"key")="id",@ROOT@("schema","columns",1,"label")="ID",@ROOT@("schema","columns",1,"type")="text",@ROOT@("schema","columns",1,"group")="Identity"
 SET @ROOT@("schema","columns",2,"key")="status",@ROOT@("schema","columns",2,"label")="Status",@ROOT@("schema","columns",2,"type")="select",@ROOT@("schema","columns",2,"group")="State"
 SET @ROOT@("schema","columns",3,"key")="owner",@ROOT@("schema","columns",3,"label")="Owner",@ROOT@("schema","columns",3,"type")="text",@ROOT@("schema","columns",3,"group")="State"
 SET @ROOT@("schema","columns",4,"key")="summary",@ROOT@("schema","columns",4,"label")="Summary",@ROOT@("schema","columns",4,"type")="text",@ROOT@("schema","columns",4,"group")="Details"
 SET @ROOT@("schema","fixedColumns","start")=1,@ROOT@("schema","fixedColumns","end")=0
 SET @ROOT@("rows",1,"id")="gf-1",@ROOT@("rows",1,"status")="Open",@ROOT@("rows",1,"owner")="Desk",@ROOT@("rows",1,"summary")="Grouped row"
 SET @ROOT@("rows",2,"id")="gf-2",@ROOT@("rows",2,"status")="Open",@ROOT@("rows",2,"owner")="Clinic",@ROOT@("rows",2,"summary")="Second row"
 SET @ROOT@("validation","fields","status","enum",1)="Open",@ROOT@("validation","fields","status","enum",2)="Done"
 KILL MOD SET MOD("componentKey")="table",MOD("surface")="mioos-surface-table",MOD("icon")="▤",MOD("title")="Grouped Fixed Table"
 SET MOD("tableState","dataset")="sample-group-fixed",MOD("tableState","config","contract")="mioos-advanced-table-v8"
 SET MOD("tableState","config","features","grouping")=1,MOD("tableState","config","features","columnPicker")=1
 SET MOD("tableState","config","features","columnReorder")=1,MOD("tableState","config","features","fixedColumns")=1
 SET MOD("tableState","config","fixedColumns","start")=1,MOD("tableState","config","fixedColumns","end")=0
 QUIT
 ; Open the Columns modal to hide/show columns, reorder them, and save fixed start/end counts.
 ; Run: ZLINK "TGROUPFX" DO SEED^TGROUPFX("admin") ZLINK "MIOOST" DO ^MIOOST
