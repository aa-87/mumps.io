MIOOSTBLC ; MIOOS advanced table backend contract tests
	QUIT
	;
RUN
	DO TQRY
	DO TMUT
	DO TVAL
	DO TFILT
	DO TFEAT
	DO TREG
	QUIT
	;
SETUP(STATE,CONF,ROOT)
	KILL STATE,CONF
	DO CONFDEF^MIOOS(.CONF)
	SET CONF("mioos","table","maxPageSize")=250
	SET CONF("mioos","table","maxFieldChars")=256
	SET STATE("principal")="roi68a"
	SET STATE("authenticated")=1
	SET ROOT=$$ROOT^MIOOSTBL(.STATE,"contract")
	KILL @ROOT
	DO ENSURE^MIOOSTBL(.STATE,"contract")
	DO AUGMENT(ROOT)
	QUIT
	;
AUGMENT(ROOT)
	NEW N
	SET N=$ORDER(@ROOT@("schema","columns",""),-1)
	DO COLR^MIOOSTBL(ROOT,N+1,"score","Score","number",90,0,1,"Metrics")
	DO COLR^MIOOSTBL(ROOT,N+2,"active","Active","boolean",90,0,1,"State")
	DO COLR^MIOOSTBL(ROOT,N+3,"tags","Tags","multiselect",160,0,1,"State")
	SET @ROOT@("rows",1,"score")=11,@ROOT@("rows",1,"active")="true",@ROOT@("rows",1,"tags")="Core|Urgent"
	SET @ROOT@("rows",2,"score")=22,@ROOT@("rows",2,"active")="false",@ROOT@("rows",2,"tags")="Core"
	SET @ROOT@("rows",3,"score")=33,@ROOT@("rows",3,"active")="true",@ROOT@("rows",3,"tags")="UX"
	SET @ROOT@("rows",4,"score")=44,@ROOT@("rows",4,"active")="false",@ROOT@("rows",4,"tags")="Ops"
	SET @ROOT@("rows",5,"id")="demo-5",@ROOT@("rows",5,"name")="Blank owner",@ROOT@("rows",5,"status")="Open",@ROOT@("rows",5,"owner")="",@ROOT@("rows",5,"priority")="Low",@ROOT@("rows",5,"updated")="2026-04-20",@ROOT@("rows",5,"notes")="Blank owner regression row",@ROOT@("rows",5,"score")=55,@ROOT@("rows",5,"active")="true",@ROOT@("rows",5,"tags")="Ops"
	SET @ROOT@("validation","fields","name","required")=1
	SET @ROOT@("validation","fields","status","enum",1)="Open"
	SET @ROOT@("validation","fields","status","enum",2)="Done"
	SET @ROOT@("validation","fields","status","enum",3)="Review"
	SET @ROOT@("validation","fields","updated","date")=1
	SET @ROOT@("validation","fields","owner","maxLength")=12
	SET @ROOT@("validation","fields","score","numeric")=1
	SET @ROOT@("validation","fields","score","min")=0
	SET @ROOT@("validation","fields","score","max")=100
	SET @ROOT@("validation","fields","active","boolean")=1
	SET @ROOT@("validation","fields","tags","multiselect")=1
	SET @ROOT@("validation","fields","tags","enum",1)="Core"
	SET @ROOT@("validation","fields","tags","enum",2)="Urgent"
	SET @ROOT@("validation","fields","tags","enum",3)="UX"
	SET @ROOT@("validation","fields","tags","enum",4)="Ops"
	SET @ROOT@("validation","routine")="VALTEST^MIOOSTBLC"
	SET @ROOT@("schema","columns",3,"cellCallback")="CELLTEST^MIOOSTBLC"
	QUIT
	;
TQRY
	NEW STATE,CONF,ROOT,IN,OUT,ERR
	DO SETUP(.STATE,.CONF,.ROOT)
	SET IN("dataset")="contract",IN("draw")=68,IN("page")=1,IN("pageSize")=2
	SET IN("groupByColumns",1)="status",IN("groupByColumns",2)="owner"
	DO OK^MIOTASSERT($$QUERY^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR),"[MIOSTBLC][TQRY][query ok]")
	DO EQ^MIOTASSERT($GET(OUT("ok")),1,"[MIOSTBLC][TQRY][ok]")
	DO EQ^MIOTASSERT($GET(OUT("contract")),"mioos-advanced-table-v8","[MIOSTBLC][TQRY][contract]")
	DO EQ^MIOTASSERT($GET(OUT("dataset")),"contract","[MIOSTBLC][TQRY][dataset]")
	DO EQ^MIOTASSERT($GET(OUT("draw")),68,"[MIOSTBLC][TQRY][draw]")
	DO EQ^MIOTASSERT($GET(OUT("recordsTotal")),5,"[MIOSTBLC][TQRY][records total]")
	DO EQ^MIOTASSERT($GET(OUT("recordsFiltered")),5,"[MIOSTBLC][TQRY][records filtered]")
	DO OK^MIOTASSERT($DATA(OUT("schema","columns",1,"key")),"[MIOSTBLC][TQRY][schema columns]")
	DO EQ^MIOTASSERT($$COUNTROWS(.OUT),2,"[MIOSTBLC][TQRY][page rows only]")
	DO OK^MIOTASSERT($DATA(OUT("groups",1,"key")),"[MIOSTBLC][TQRY][groups]")
	DO EQ^MIOTASSERT($GET(OUT("pagination","page")),1,"[MIOSTBLC][TQRY][page]")
	DO EQ^MIOTASSERT($GET(OUT("pagination","pageSize")),2,"[MIOSTBLC][TQRY][page size]")
	DO EQ^MIOTASSERT($GET(OUT("pagination","totalRows")),5,"[MIOSTBLC][TQRY][pagination total]")
	DO EQ^MIOTASSERT($GET(OUT("pagination","filteredRows")),5,"[MIOSTBLC][TQRY][pagination filtered]")
	DO EQ^MIOTASSERT($GET(OUT("pagination","pageRows")),2,"[MIOSTBLC][TQRY][pagination page rows]")
	DO EQ^MIOTASSERT($GET(OUT("pagination","pageCount")),3,"[MIOSTBLC][TQRY][pagination page count]")
	DO EQ^MIOTASSERT($GET(OUT("features","serverPagination")),1,"[MIOSTBLC][TQRY][feature pagination]")
	DO OK^MIOTASSERT($DATA(OUT("rowActions",1,"key")),"[MIOSTBLC][TQRY][row actions]")
	DO OK^MIOTASSERT($DATA(OUT("bulkActions",1,"key")),"[MIOSTBLC][TQRY][bulk actions]")
	DO EQ^MIOTASSERT($DATA(OUT("data")),0,"[MIOSTBLC][TQRY][no data alias]")
	KILL OUT,ERR SET IN("includeDataAlias")="true"
	DO OK^MIOTASSERT($$QUERY^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR),"[MIOSTBLC][TQRY][query alias ok]")
	DO EQ^MIOTASSERT($GET(OUT("data",1,"id")),$GET(OUT("rows",1,"id")),"[MIOSTBLC][TQRY][data alias explicit]")
	KILL IN,OUT,ERR SET IN("dataset")="contract",IN("page")=99,IN("pageSize")=2
	DO OK^MIOTASSERT($$QUERY^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR),"[MIOSTBLC][TQRY][clamp ok]")
	DO EQ^MIOTASSERT($GET(OUT("pagination","page")),3,"[MIOSTBLC][TQRY][page jump clamps]")
	KILL IN,OUT,ERR SET IN("dataset")="massive",IN("page")=2,IN("pageSize")=3,IN("sortBy")="id"
	DO OK^MIOTASSERT($$QUERY^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR),"[MIOSTBLC][TQRY][massive ok]")
	DO EQ^MIOTASSERT($GET(OUT("recordsTotal")),10000,"[MIOSTBLC][TQRY][massive total]")
	DO EQ^MIOTASSERT($$COUNTROWS(.OUT),3,"[MIOSTBLC][TQRY][massive page only]")
	DO EQ^MIOTASSERT($DATA(OUT("rows",4)),0,"[MIOSTBLC][TQRY][massive no extra browser payload]")
	QUIT
	;
TMUT
	NEW STATE,CONF,ROOT,IN,OUT,ERR
	DO SETUP(.STATE,.CONF,.ROOT)
	SET IN("dataset")="contract",IN("action")="column.visibility",IN("columnKey")="priority",IN("hidden")="true"
	DO OK^MIOTASSERT($$MUTATE^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR),"[MIOSTBLC][TMUT][visibility ok]")
	DO OK^MIOTASSERT($$ACK(.OUT,"column.visibility"),"[MIOSTBLC][TMUT][visibility ack]")
	DO EQ^MIOTASSERT($DATA(OUT("rows"))+$DATA(OUT("schema")),0,"[MIOSTBLC][TMUT][visibility small ack]")
	KILL IN,OUT,ERR SET IN("dataset")="contract",IN("action")="row.save"
	SET IN("row","id")="demo-10",IN("row","name")="Saved row",IN("row","status")="Open",IN("row","owner")="QA",IN("row","priority")="Low",IN("row","updated")="2026-05-02",IN("row","score")=10,IN("row","active")="true",IN("row","tags")="Core|UX"
	DO OK^MIOTASSERT($$MUTATE^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR),"[MIOSTBLC][TMUT][row save ok]")
	DO OK^MIOTASSERT($$ACK(.OUT,"row.save"),"[MIOSTBLC][TMUT][row save ack]")
	KILL IN,OUT,ERR SET IN("dataset")="contract",IN("action")="cell.save",IN("rowId")="demo-1",IN("columnKey")="owner",IN("value")="trim"
	DO OK^MIOTASSERT($$MUTATE^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR),"[MIOSTBLC][TMUT][cell save ok]")
	DO OK^MIOTASSERT($$ACK(.OUT,"cell.save"),"[MIOSTBLC][TMUT][cell save ack]")
	DO EQ^MIOTASSERT($GET(@ROOT@("rows",1,"owner")),"trimmed","[MIOSTBLC][TMUT][cell callback can normalize]")
	KILL IN,OUT,ERR SET IN("dataset")="contract",IN("action")="column.option.add",IN("columnKey")="status",IN("value")="Blocked"
	DO OK^MIOTASSERT($$MUTATE^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR),"[MIOSTBLC][TMUT][option add ok]")
	DO EQ^MIOTASSERT($GET(OUT("mutated","value")),"Blocked","[MIOSTBLC][TMUT][option deterministic]")
	KILL IN,OUT,ERR SET IN("dataset")="contract",IN("action")="column.reorder"
	SET IN("columns",1,"key")="status",IN("columns",2,"key")="name",IN("columns",3,"key")="owner",IN("columns",4,"key")="priority",IN("columns",5,"key")="updated",IN("columns",6,"key")="score",IN("columns",7,"key")="active",IN("columns",8,"key")="tags"
	DO OK^MIOTASSERT($$MUTATE^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR),"[MIOSTBLC][TMUT][reorder ok]")
	DO EQ^MIOTASSERT($GET(@ROOT@("schema","columns",1,"key")),"status","[MIOSTBLC][TMUT][reorder persisted]")
	KILL IN,OUT,ERR SET IN("dataset")="contract",IN("action")="column.fixed",IN("fixedColumns","start")=2,IN("fixedColumns","end")=1
	DO OK^MIOTASSERT($$MUTATE^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR),"[MIOSTBLC][TMUT][fixed ok]")
	DO EQ^MIOTASSERT($GET(@ROOT@("schema","fixedColumns","start")),2,"[MIOSTBLC][TMUT][fixed persisted]")
	KILL IN,OUT,ERR SET IN("dataset")="contract",IN("action")="rows.export",IN("ids",1)="demo-1",IN("ids",2)="demo-3"
	DO OK^MIOTASSERT($$MUTATE^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR),"[MIOSTBLC][TMUT][export ok]")
	DO EQ^MIOTASSERT($GET(OUT("exportOnly")),1,"[MIOSTBLC][TMUT][export only]")
	DO EQ^MIOTASSERT($GET(OUT("export","rowCount")),2,"[MIOSTBLC][TMUT][selected export count]")
	DO EQ^MIOTASSERT($SELECT($GET(OUT("export","csv"))["demo-2":1,1:0),0,"[MIOSTBLC][TMUT][selected export excludes unselected]")
	QUIT
	;
TVAL
	NEW STATE,CONF,ROOT,IN,OUT,ERR
	DO SETUP(.STATE,.CONF,.ROOT)
	DO BADROW(.STATE,.CONF,"name","","name","[MIOSTBLC][TVAL][required]")
	DO BADROW(.STATE,.CONF,"owner","OwnerNameTooLong","owner","[MIOSTBLC][TVAL][max length]")
	DO BADROW(.STATE,.CONF,"status","NotAStatus","status","[MIOSTBLC][TVAL][enum]")
	DO BADROW(.STATE,.CONF,"tags","Core|Bad","tags","[MIOSTBLC][TVAL][multiselect]")
	DO BADROW(.STATE,.CONF,"active","maybe","active","[MIOSTBLC][TVAL][boolean]")
	DO BADROW(.STATE,.CONF,"updated","2026-02-31","updated","[MIOSTBLC][TVAL][strict date]")
	DO BADROW(.STATE,.CONF,"score","abc","score","[MIOSTBLC][TVAL][numeric]")
	DO BADROW(.STATE,.CONF,"score",101,"score","[MIOSTBLC][TVAL][numeric range]")
	DO BADROW(.STATE,.CONF,"name","HookReject","name","[MIOSTBLC][TVAL][row hook]")
	KILL IN,OUT,ERR SET IN("dataset")="contract",IN("action")="cell.save",IN("rowId")="demo-1",IN("columnKey")="owner",IN("value")="badcell"
	DO EQ^MIOTASSERT($$MUTATE^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR),0,"[MIOSTBLC][TVAL][cell callback rejects]")
	DO EQ^MIOTASSERT($GET(ERR("field")),"owner","[MIOSTBLC][TVAL][cell callback field]")
	DO EQ^MIOTASSERT($GET(IN("value")),"badcell","[MIOSTBLC][TVAL][cell input preserved]")
	QUIT
	;
BADROW(STATE,CONF,FIELD,VALUE,ERRFIELD,DESC)
	NEW IN,OUT,ERR
	SET IN("dataset")="contract",IN("action")="row.save"
	SET IN("row","id")="bad-"_FIELD,IN("row","name")="Good",IN("row","status")="Open",IN("row","owner")="QA",IN("row","priority")="Low",IN("row","updated")="2026-05-02",IN("row","score")=10,IN("row","active")="true",IN("row","tags")="Core"
	SET IN("row",FIELD)=VALUE
	DO EQ^MIOTASSERT($$MUTATE^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR),0,DESC_" mutation fails")
	DO OK^MIOTASSERT($DATA(ERR("fieldErrors",ERRFIELD)),DESC_" field error")
	DO EQ^MIOTASSERT($GET(IN("row",FIELD)),VALUE,DESC_" input preserved")
	QUIT
	;
TFILT
	NEW STATE,CONF,ROOT,IN,OUT,ERR
	DO SETUP(.STATE,.CONF,.ROOT)
	KILL IN SET IN("dataset")="contract",IN("search")="Audit" DO QCOUNT(.STATE,.CONF,.IN,1,"[MIOSTBLC][TFILT][search]")
	KILL IN SET IN("dataset")="contract",IN("filters","status","mode")="include",IN("filters","status","value")="Open" DO QCOUNT(.STATE,.CONF,.IN,3,"[MIOSTBLC][TFILT][include]")
	KILL IN SET IN("dataset")="contract",IN("filters","status","mode")="exclude",IN("filters","status","value")="Open" DO QCOUNT(.STATE,.CONF,.IN,2,"[MIOSTBLC][TFILT][exclude]")
	KILL IN SET IN("dataset")="contract",IN("filters","name","mode")="contains",IN("filters","name","value")="grid" DO QCOUNT(.STATE,.CONF,.IN,1,"[MIOSTBLC][TFILT][contains]")
	KILL IN SET IN("dataset")="contract",IN("filters","owner","mode")="starts",IN("filters","owner","value")="MIO" DO QCOUNT(.STATE,.CONF,.IN,1,"[MIOSTBLC][TFILT][starts]")
	KILL IN SET IN("dataset")="contract",IN("filters","owner","mode")="ends",IN("filters","owner","value")="S" DO QCOUNT(.STATE,.CONF,.IN,2,"[MIOSTBLC][TFILT][ends]")
	KILL IN SET IN("dataset")="contract",IN("filters","updated","mode")="range",IN("filters","updated","from")="2026-04-28",IN("filters","updated","to")="2026-05-02" DO QCOUNT(.STATE,.CONF,.IN,3,"[MIOSTBLC][TFILT][range]")
	KILL IN SET IN("dataset")="contract",IN("filters","owner","mode")="blank" DO QCOUNT(.STATE,.CONF,.IN,1,"[MIOSTBLC][TFILT][blank]")
	KILL IN SET IN("dataset")="contract",IN("filters","owner","mode")="notblank" DO QCOUNT(.STATE,.CONF,.IN,4,"[MIOSTBLC][TFILT][not blank]")
	KILL IN,OUT,ERR SET IN("dataset")="contract",IN("sortBy")="updated",IN("sortDir")="descending",IN("groupByColumns",1)="status",IN("groupByColumns",2)="owner",IN("page")=1,IN("pageSize")=2
	DO OK^MIOTASSERT($$QUERY^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR),"[MIOSTBLC][TFILT][sort group ok]")
	DO EQ^MIOTASSERT($GET(OUT("rows",1,"updated")),"2026-05-01","[MIOSTBLC][TFILT][sort by named column]")
	DO OK^MIOTASSERT($DATA(OUT("groups",1,"label")),"[MIOSTBLC][TFILT][multi-column groups]")
	DO OK^MIOTASSERT($$COLVISIBLE(.OUT,"status"),"[MIOSTBLC][TFILT][grouped column visible]")
	DO EQ^MIOTASSERT($GET(OUT("pagination","pageRows")),2,"[MIOSTBLC][TFILT][grouping stable under pagination]")
	QUIT
	;
QCOUNT(STATE,CONF,IN,EXPECT,DESC)
	NEW OUT,ERR
	DO OK^MIOTASSERT($$QUERY^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR),DESC_" ok")
	DO EQ^MIOTASSERT($GET(OUT("recordsFiltered")),EXPECT,DESC_" filtered count")
	QUIT
	;
TFEAT
	NEW STATE,CONF,ROOT,IN,OUT,ERR
	DO SETUP(.STATE,.CONF,.ROOT)
	SET IN("dataset")="massive",IN("page")=1,IN("pageSize")=25
	DO OK^MIOTASSERT($$QUERY^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR),"[MIOSTBLC][TFEAT][read only ok]")
	DO EQ^MIOTASSERT($GET(OUT("features","actionRows")),0,"[MIOSTBLC][TFEAT][readonly actions off]")
	DO EQ^MIOTASSERT($GET(OUT("features","selection")),0,"[MIOSTBLC][TFEAT][readonly selection off]")
	DO EQ^MIOTASSERT($GET(OUT("features","bulkActions")),0,"[MIOSTBLC][TFEAT][readonly bulk off]")
	DO EQ^MIOTASSERT($DATA(OUT("rowActions")),0,"[MIOSTBLC][TFEAT][readonly no row actions]")
	DO SETUP(.STATE,.CONF,.ROOT)
	KILL IN,OUT,ERR SET IN("dataset")="contract",IN("action")="column.fixed",IN("start")=1,IN("end")=1
	DO OK^MIOTASSERT($$MUTATE^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR),"[MIOSTBLC][TFEAT][fixed before reorder]")
	KILL IN,OUT,ERR SET IN("dataset")="contract",IN("action")="column.visibility",IN("columnKey")="priority",IN("hidden")=1
	DO OK^MIOTASSERT($$MUTATE^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR),"[MIOSTBLC][TFEAT][hide with fixed]")
	KILL IN,OUT,ERR SET IN("dataset")="contract",IN("action")="cell.save",IN("rowId")="demo-2",IN("columnKey")="owner",IN("value")="QA2"
	DO OK^MIOTASSERT($$MUTATE^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR),"[MIOSTBLC][TFEAT][cell after refetch path]")
	KILL IN,OUT,ERR SET IN("dataset")="contract",IN("search")="Explorer",IN("sortBy")="owner"
	DO OK^MIOTASSERT($$QUERY^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR),"[MIOSTBLC][TFEAT][query after edit]")
	DO EQ^MIOTASSERT($GET(OUT("rows",1,"owner")),"QA2","[MIOSTBLC][TFEAT][editable after sort filter]")
	DO EQ^MIOTASSERT($GET(OUT("schema","fixedColumns","start")),1,"[MIOSTBLC][TFEAT][fixed metadata after hide]")
	DO EQ^MIOTASSERT($GET(OUT("schema","columns",4,"hidden")),1,"[MIOSTBLC][TFEAT][hidden column retained for reorder controls]")
	QUIT
	;
TREG
	DO EQ^MIOTASSERT($$FILEHAS^MIOOST("public/mioos/app/mioos_table.js","vm.backendTableNormalizeFixedColumns"),0,"[MIOSTBLC][TREG][no vm fixed column regression]")
	DO OK^MIOTASSERT($$FILEHAS^MIOOST("public/mioos/app/mioos_table.js","this.backendTableNormalizeFixedColumns"),"[MIOSTBLC][TREG][fixed normalize scoped]")
	DO OK^MIOTASSERT($$FILEHAS^MIOOST("public/mioos/app/mioos_table.js","@pointerdown.stop"),"[MIOSTBLC][TREG][modal close does not drag]")
	DO EQ^MIOTASSERT($$FILEHAS^MIOOST("public/mioos/app/mioos_table.js","prompt("),0,"[MIOSTBLC][TREG][no prompt]")
	DO EQ^MIOTASSERT($$FILEHAS^MIOOST("public/mioos/app/mioos_table.js","confirm("),0,"[MIOSTBLC][TREG][no confirm]")
	DO OK^MIOTASSERT($$FILEHAS^MIOOST("public/mioos/app/mioos_table.js","mioos-table-loading-line"),"[MIOSTBLC][TREG][bar loading]")
	DO EQ^MIOTASSERT($$FILEHAS^MIOOST("public/mioos/app/mioos_table.js","Loading rows from server"),0,"[MIOSTBLC][TREG][no layout loading text]")
	DO OK^MIOTASSERT($$FILEHAS^MIOOST("routines/MIOOSAPI.m","MUTATE^MIOOSTBL"),"[MIOSTBLC][TREG][http uses backend]")
	DO OK^MIOTASSERT($$FILEHAS^MIOOST("routines/MIOOSWS.m","MUTATE^MIOOSTBL"),"[MIOSTBLC][TREG][ws uses backend]")
	DO OK^MIOTASSERT($$FILEHAS^MIOOST("routines/MIOOSAPI.m","mutationOnly")&$$FILEHAS^MIOOST("routines/MIOOSAPI.m","refetch")&$$FILEHAS^MIOOST("routines/MIOOSAPI.m","fieldErrors"),"[MIOSTBLC][TREG][http deterministic failure json]")
	DO OK^MIOTASSERT($$FILEHAS^MIOOST("routines/MIOOSWS.m","mutationOnly")&$$FILEHAS^MIOOST("routines/MIOOSWS.m","refetch")&$$FILEHAS^MIOOST("routines/MIOOSWS.m","fieldErrors"),"[MIOSTBLC][TREG][ws deterministic failure json]")
	DO OK^MIOTASSERT($$FILEHAS^MIOOST("docs/mioos/ROI_68A_Table_Backend_Contract_Tests_and_Samples.md","ROI 68A"),"[MIOSTBLC][TREG][roi docs]")
	DO OK^MIOTASSERT($$FILEHAS^MIOOST("examples/mioos_modules/table/README.md","Sample matrix"),"[MIOSTBLC][TREG][sample matrix docs]")
	QUIT
	;
ACK(OUT,ACTION)
	IF $GET(OUT("ok"))'=1 QUIT 0
	IF $GET(OUT("action"))'=ACTION QUIT 0
	IF $GET(OUT("mutationOnly"))'=1 QUIT 0
	IF $DATA(OUT("rows")) QUIT 0
	IF $DATA(OUT("schema")) QUIT 0
	QUIT 1
	;
COUNTROWS(OUT)
	NEW I,N SET (I,N)=0 FOR  SET I=$ORDER(OUT("rows",I)) QUIT:I'>0  SET N=N+1
	QUIT N
	;
COLVISIBLE(OUT,KEY)
	NEW I,OK SET (I,OK)=0 FOR  SET I=$ORDER(OUT("schema","columns",I)) QUIT:I'>0!(OK)  IF $GET(OUT("schema","columns",I,"key"))=KEY SET OK=1
	QUIT OK
	;
VALTEST(IN,ERR,ROOT)
	IF $GET(IN("row","name"))="HookReject" DO  QUIT 0
	. SET ERR("error")="validation_failed",ERR("field")="name",ERR("message")="Row hook rejected the row",ERR("fieldErrors","name")="Row hook rejected the row"
	QUIT 1
	;
CELLTEST(STATE,DATASET,ID,KEY,VAL,OUT,ERR)
	IF $GET(VAL)="badcell" DO  QUIT 0
	. SET ERR("error")="validation_failed",ERR("field")=KEY,ERR("message")="Cell callback rejected value",ERR("fieldErrors",KEY)="Cell callback rejected value"
	IF $GET(VAL)="trim" SET OUT("value")="trimmed"
	QUIT 1
	;
