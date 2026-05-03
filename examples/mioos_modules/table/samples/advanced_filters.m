TFILTERS ; Advanced filter sample table
SEED(USER)
 NEW ROOT
 SET USER=$GET(USER,"admin"),ROOT=$NAME(^MIO("MIOOS","TABLE",USER,"sample-filters"))
 KILL @ROOT
 SET @ROOT@("schema","columns",1,"key")="id",@ROOT@("schema","columns",1,"label")="ID",@ROOT@("schema","columns",1,"type")="text"
 SET @ROOT@("schema","columns",2,"key")="name",@ROOT@("schema","columns",2,"label")="Name",@ROOT@("schema","columns",2,"type")="text"
 SET @ROOT@("schema","columns",3,"key")="status",@ROOT@("schema","columns",3,"label")="Status",@ROOT@("schema","columns",3,"type")="select"
 SET @ROOT@("schema","columns",4,"key")="owner",@ROOT@("schema","columns",4,"label")="Owner",@ROOT@("schema","columns",4,"type")="text"
 SET @ROOT@("schema","columns",5,"key")="updated",@ROOT@("schema","columns",5,"label")="Updated",@ROOT@("schema","columns",5,"type")="date"
 SET @ROOT@("rows",1,"id")="f-1",@ROOT@("rows",1,"name")="Alpha intake",@ROOT@("rows",1,"status")="Open",@ROOT@("rows",1,"owner")="MIOOS",@ROOT@("rows",1,"updated")="2026-05-01"
 SET @ROOT@("rows",2,"id")="f-2",@ROOT@("rows",2,"name")="Beta review",@ROOT@("rows",2,"status")="Done",@ROOT@("rows",2,"owner")="QA",@ROOT@("rows",2,"updated")="2026-04-20"
 SET @ROOT@("rows",3,"id")="f-3",@ROOT@("rows",3,"name")="Gamma blank",@ROOT@("rows",3,"status")="Open",@ROOT@("rows",3,"owner")="",@ROOT@("rows",3,"updated")="2026-04-01"
 SET @ROOT@("validation","fields","status","enum",1)="Open",@ROOT@("validation","fields","status","enum",2)="Done"
 SET @ROOT@("validation","fields","updated","date")=1
 QUIT
 ; Use Advanced Filters in the table UI: include, exclude, contains, starts, ends, range, blank, and not blank.
 ; Module config: SET MOD("tableState","config","features","filters")=1
 ; Run: ZLINK "TFILTERS" DO SEED^TFILTERS("admin") ZLINK "MIOOST" DO ^MIOOST
