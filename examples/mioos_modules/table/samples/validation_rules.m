TVALRULE ; Table validation rules sample
 ; Covers required, maxLength, enum/select, multiselect, boolean, date, number, numeric range, row hook, and cell callback.
SEED(USER)
 NEW ROOT
 SET USER=$GET(USER,"admin"),ROOT=$NAME(^MIO("MIOOS","TABLE",USER,"sample-validation"))
 KILL @ROOT
 SET @ROOT@("schema","columns",1,"key")="id",@ROOT@("schema","columns",1,"label")="ID",@ROOT@("schema","columns",1,"type")="text",@ROOT@("schema","columns",1,"editable")=0
 SET @ROOT@("schema","columns",2,"key")="name",@ROOT@("schema","columns",2,"label")="Name",@ROOT@("schema","columns",2,"type")="text"
 SET @ROOT@("schema","columns",3,"key")="status",@ROOT@("schema","columns",3,"label")="Status",@ROOT@("schema","columns",3,"type")="select"
 SET @ROOT@("schema","columns",4,"key")="tags",@ROOT@("schema","columns",4,"label")="Tags",@ROOT@("schema","columns",4,"type")="multiselect"
 SET @ROOT@("schema","columns",5,"key")="consent",@ROOT@("schema","columns",5,"label")="Consent",@ROOT@("schema","columns",5,"type")="boolean"
 SET @ROOT@("schema","columns",6,"key")="reviewDate",@ROOT@("schema","columns",6,"label")="Review Date",@ROOT@("schema","columns",6,"type")="date"
 SET @ROOT@("schema","columns",7,"key")="score",@ROOT@("schema","columns",7,"label")="Score",@ROOT@("schema","columns",7,"type")="number",@ROOT@("schema","columns",7,"cellCallback")="SCORE^TVALRULE"
 SET @ROOT@("rows",1,"id")="val-1",@ROOT@("rows",1,"name")="Valid row",@ROOT@("rows",1,"status")="Active",@ROOT@("rows",1,"tags")="Core|Ops",@ROOT@("rows",1,"consent")="true",@ROOT@("rows",1,"reviewDate")="2026-05-02",@ROOT@("rows",1,"score")=80
 SET @ROOT@("validation","fields","name","required")=1,@ROOT@("validation","fields","name","maxLength")=60
 SET @ROOT@("validation","fields","status","enum",1)="Active",@ROOT@("validation","fields","status","enum",2)="Pending"
 SET @ROOT@("validation","fields","tags","multiselect")=1,@ROOT@("validation","fields","tags","enum",1)="Core",@ROOT@("validation","fields","tags","enum",2)="Ops"
 SET @ROOT@("validation","fields","consent","boolean")=1
 SET @ROOT@("validation","fields","reviewDate","date")=1
 SET @ROOT@("validation","fields","score","numeric")=1,@ROOT@("validation","fields","score","min")=0,@ROOT@("validation","fields","score","max")=100
 SET @ROOT@("validation","routine")="ROW^TVALRULE"
 QUIT
ROW(IN,ERR,ROOT)
 IF $GET(IN("row","name"))="Reject" DO  QUIT 0
 . SET ERR("error")="validation_failed",ERR("field")="name",ERR("message")="Rejected by row hook",ERR("fieldErrors","name")="Rejected by row hook"
 QUIT 1
SCORE(STATE,DATASET,ROWID,COLUMN,VALUE,OUT,ERR)
 IF +VALUE<50 DO  QUIT 0
 . SET ERR("error")="validation_failed",ERR("field")=COLUMN,ERR("message")="Score must be at least 50",ERR("fieldErrors",COLUMN)="Score must be at least 50"
 QUIT 1
 ; Module: componentKey=table, surface=mioos-surface-table, tableState.dataset=sample-validation.
 ; Run: ZLINK "TVALRULE" DO SEED^TVALRULE("admin") ZLINK "MIOOST" DO ^MIOOST
