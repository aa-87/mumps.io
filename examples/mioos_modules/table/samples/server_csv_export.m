TCSVEXP ; Selected-row server CSV export sample
SEED(USER)
 NEW ROOT
 SET USER=$GET(USER,"admin"),ROOT=$NAME(^MIO("MIOOS","TABLE",USER,"sample-export"))
 KILL @ROOT
 SET @ROOT@("schema","columns",1,"key")="id",@ROOT@("schema","columns",1,"label")="ID",@ROOT@("schema","columns",1,"type")="text"
 SET @ROOT@("schema","columns",2,"key")="name",@ROOT@("schema","columns",2,"label")="Name",@ROOT@("schema","columns",2,"type")="text"
 SET @ROOT@("schema","columns",3,"key")="amount",@ROOT@("schema","columns",3,"label")="Amount",@ROOT@("schema","columns",3,"type")="number"
 SET @ROOT@("rows",1,"id")="x-1",@ROOT@("rows",1,"name")="Export me",@ROOT@("rows",1,"amount")=10
 SET @ROOT@("rows",2,"id")="x-2",@ROOT@("rows",2,"name")="Do not export unless selected",@ROOT@("rows",2,"amount")=20
 SET @ROOT@("validation","fields","amount","numeric")=1
 QUIT
TEST(USER)
 NEW STATE,CONF,IN,OUT,ERR
 DO CONFDEF^MIOOS(.CONF)
 SET STATE("principal")=$GET(USER,"admin")
 SET IN("dataset")="sample-export",IN("action")="rows.export",IN("ids",1)="x-1"
 DO MUTATE^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR)
 ; OUT("export","csv") now contains only x-1.
 QUIT
 ; Module config: enable selection and bulkActions. The browser sends rows.export with selected IDs only.
 ; Run: ZLINK "TCSVEXP" DO SEED^TCSVEXP("admin") DO TEST^TCSVEXP("admin") ZLINK "MIOOST" DO ^MIOOST
