MIOOSTBL ; MIOOS backend table query and mutation engine
	QUIT
	;
QUERY(STATE,CONF,IN,OUT,ERR)
	NEW DATASET,ROWS,SCHEMA,WORK,TOTAL,FILTERED,PAGE,PSIZE,SORTBY,SORTDIR,GROUPBY
	KILL OUT,ERR,ROWS,SCHEMA,WORK
	SET ERR("routine")="MIOOSTBL"
	SET DATASET=$$DATASET($GET(IN("dataset"),"demo"))
	IF DATASET="vfs" DO
	. IF '$$VFS(.STATE,.IN,.ROWS,.SCHEMA,.ERR) SET DATASET=""
	IF DATASET'="vfs",DATASET'="" DO LOADDATA(.STATE,DATASET,.ROWS,.SCHEMA)
	IF DATASET="" QUIT 0
	SET PAGE=+$GET(IN("page"),1) IF PAGE<1 SET PAGE=1
	SET PSIZE=+$GET(IN("pageSize"),25) IF PSIZE<1 SET PSIZE=25
	IF PSIZE>+$GET(CONF("mioos","table","maxPageSize"),250) SET PSIZE=+$GET(CONF("mioos","table","maxPageSize"),250)
	SET SORTBY=$GET(IN("sort","column"),$GET(IN("sortBy"),"name"))
	SET SORTDIR=$$LOW^MIOUTIL($GET(IN("sort","direction"),$GET(IN("sortDir"),"ascending")))
	IF SORTDIR'="descending" SET SORTDIR="ascending"
	DO FILTER(.ROWS,.IN,.WORK,.TOTAL,.FILTERED)
	IF SORTBY'="" DO SORT(.WORK,SORTBY,SORTDIR)
	MERGE OUT("schema","columns")=SCHEMA("columns")
	DO ACTIONS(.OUT)
	DO PAGE(.WORK,.OUT,PAGE,PSIZE,TOTAL,FILTERED)
	SET GROUPBY=$GET(IN("groupBy"))
	IF GROUPBY'="" DO GROUPS(.WORK,GROUPBY,.OUT)
	SET OUT("ok")=1
	SET OUT("dataset")=DATASET
	SET OUT("features","serverPagination")=1
	SET OUT("features","serverSorting")=1
	SET OUT("features","columnVisibility")=1
	SET OUT("features","columnGrouping")=1
	SET OUT("features","expansionRows")=1
	SET OUT("features","actionRows")=1
	SET OUT("features","bulkActions")=1
	SET OUT("features","selection")=1
	SET OUT("features","filtering")=1
	SET OUT("features","crudRows")=1
	SET OUT("features","crudColumns")=1
	SET OUT("features","resizableColumns")=1
	QUIT 1
	;
MUTATE(STATE,CONF,IN,OUT,ERR)
	NEW DATASET,ACTION,ROOT,ID,KEY,I,N,FOUND,ROW,COL
	KILL OUT,ERR
	SET ERR("routine")="MIOOSTBL"
	SET DATASET=$$DATASET($GET(IN("dataset"),"demo"))
	IF DATASET="vfs" SET ERR("error")="vfs_table_read_only" QUIT 0
	IF DATASET="massive" SET ERR("error")="massive_table_read_only" QUIT 0
	SET ACTION=$$LOW^MIOUTIL($GET(IN("action"),$GET(IN("op"),"")))
	IF ACTION="" SET ERR("error")="table_action_missing" QUIT 0
	IF ACTION'["." SET ERR("error")="table_action_invalid" QUIT 0
	SET ROOT=$$ROOT(.STATE,DATASET)
	DO ENSURE(.STATE,DATASET)
	IF ACTION="row.save"!(ACTION="row.add")!(ACTION="row.update") DO
	. SET ID=$GET(IN("row","id"))
	. IF ID="" SET ID=DATASET_"-"_$TR($$UUID^MIOUTIL(),"-","")
	. SET FOUND=0,I=0 FOR  SET I=$ORDER(@ROOT@("rows",I)) QUIT:I'>0  IF $GET(@ROOT@("rows",I,"id"))=ID SET FOUND=I
	. IF FOUND'>0 SET FOUND=$ORDER(@ROOT@("rows",""),-1)+1
	. KILL @ROOT@("rows",FOUND)
	. MERGE @ROOT@("rows",FOUND)=IN("row")
	. SET @ROOT@("rows",FOUND,"id")=ID
	. SET OUT("mutated","rowId")=ID
	IF ACTION="row.delete" DO
	. SET ID=$GET(IN("rowId"),$GET(IN("id"),$GET(IN("row","id"))))
	. IF ID="" QUIT
	. SET I=0 FOR  SET I=$ORDER(@ROOT@("rows",I)) QUIT:I'>0  IF $GET(@ROOT@("rows",I,"id"))=ID KILL @ROOT@("rows",I) SET OUT("mutated","deleted",ID)=1
	IF ACTION="rows.delete"!(ACTION="bulk.delete") DO
	. SET N=0,I=0 FOR  SET I=$ORDER(IN("ids",I)) QUIT:I'>0  DO
	. . SET ID=$GET(IN("ids",I)) QUIT:ID=""
	. . SET ROW=0 FOR  SET ROW=$ORDER(@ROOT@("rows",ROW)) QUIT:ROW'>0  IF $GET(@ROOT@("rows",ROW,"id"))=ID KILL @ROOT@("rows",ROW) SET N=N+1 QUIT
	. SET OUT("mutated","deletedCount")=N
	IF ACTION="column.save"!(ACTION="column.add")!(ACTION="column.update") DO
	. SET KEY=$$KEY($GET(IN("column","key")))
	. IF KEY="" SET KEY="col"_($ORDER(@ROOT@("schema","columns",""),-1)+1)
	. SET FOUND=0,I=0 FOR  SET I=$ORDER(@ROOT@("schema","columns",I)) QUIT:I'>0  IF $GET(@ROOT@("schema","columns",I,"key"))=KEY SET FOUND=I
	. IF FOUND'>0 SET FOUND=$ORDER(@ROOT@("schema","columns",""),-1)+1
	. KILL @ROOT@("schema","columns",FOUND)
	. MERGE @ROOT@("schema","columns",FOUND)=IN("column")
	. SET @ROOT@("schema","columns",FOUND,"key")=KEY
	. IF $GET(@ROOT@("schema","columns",FOUND,"label"))="" SET @ROOT@("schema","columns",FOUND,"label")=KEY
	. IF +$GET(@ROOT@("schema","columns",FOUND,"width"))<1 SET @ROOT@("schema","columns",FOUND,"width")=140
	. IF $GET(@ROOT@("schema","columns",FOUND,"type"))="" SET @ROOT@("schema","columns",FOUND,"type")="text"
	. SET @ROOT@("schema","columns",FOUND,"resizable")=1
	. SET OUT("mutated","columnKey")=KEY
	IF ACTION="column.delete" DO
	. SET KEY=$GET(IN("columnKey"),$GET(IN("key"),$GET(IN("column","key"))))
	. IF KEY="" QUIT
	. SET I=0 FOR  SET I=$ORDER(@ROOT@("schema","columns",I)) QUIT:I'>0  IF $GET(@ROOT@("schema","columns",I,"key"))=KEY KILL @ROOT@("schema","columns",I)
	. SET I=0 FOR  SET I=$ORDER(@ROOT@("rows",I)) QUIT:I'>0  KILL @ROOT@("rows",I,KEY)
	. SET OUT("mutated","columnDeleted")=KEY
	IF ACTION="column.resize" DO
	. SET KEY=$$KEY($GET(IN("columnKey"),$GET(IN("key"))))
	. SET I=0 FOR  SET I=$ORDER(@ROOT@("schema","columns",I)) QUIT:I'>0  IF $GET(@ROOT@("schema","columns",I,"key"))=KEY SET @ROOT@("schema","columns",I,"width")=$SELECT(+$GET(IN("width"))>40:+$GET(IN("width")),1:80)
	. SET OUT("mutated","columnResized")=KEY
	IF ACTION="column.visibility" DO
	. SET KEY=$$KEY($GET(IN("columnKey"),$GET(IN("key"))))
	. IF KEY="" QUIT
	. SET I=0 FOR  SET I=$ORDER(@ROOT@("schema","columns",I)) QUIT:I'>0  IF $GET(@ROOT@("schema","columns",I,"key"))=KEY SET @ROOT@("schema","columns",I,"hidden")=$SELECT(+$GET(IN("hidden")):1,1:0)
	. SET OUT("mutated","columnVisibility")=KEY
	IF '$DATA(OUT("mutated")) SET ERR("error")="unsupported_table_action" QUIT 0
	SET OUT("ok")=1,OUT("action")=ACTION
	DO QUERY(.STATE,.CONF,.IN,.OUT,.ERR)
	QUIT 1
	;
KEY(X)
	NEW Y,I,C,Q S Q=0
	SET Y=$GET(X)
	IF Y="" QUIT ""
	IF $EXTRACT(Y)?1N QUIT ""
	FOR I=1:1:$LENGTH(Y) SET C=$EXTRACT(Y,I) IF C'?1AN,C'="_" S Q=1 QUIT
	IF Q QUIT ""
	QUIT $EXTRACT(Y,1,64)
	;
DATASET(X)
	NEW Y
	SET Y=$$LOW^MIOUTIL($GET(X))
	IF Y="" SET Y="demo"
	IF Y="table" SET Y="demo"
	IF Y="sample" SET Y="demo"
	IF Y="sample-table" SET Y="demo"
	IF Y="patient_registration" SET Y="patient-registration"
	IF Y="patients" SET Y="patient-registration"
	QUIT Y
	;
ROOT(STATE,DATASET)
	NEW USER
	SET USER=$GET(STATE("principal"),"guest") IF USER="" SET USER="guest"
	QUIT $NAME(^MIO("MIOOS","TABLE",USER,DATASET))
	;
LOADDATA(STATE,DATASET,ROWS,SCHEMA)
	NEW ROOT,I,N
	KILL ROWS,SCHEMA
	IF DATASET="massive" DO MASSIVE(.ROWS,.SCHEMA) QUIT
	SET ROOT=$$ROOT(.STATE,DATASET)
	DO ENSURE(.STATE,DATASET)
	MERGE SCHEMA=@ROOT@("schema")
	SET (I,N)=0 FOR  SET I=$ORDER(@ROOT@("rows",I)) QUIT:I'>0  DO
	. SET N=N+1 MERGE ROWS(N)=@ROOT@("rows",I)
	QUIT
	;
ENSURE(STATE,DATASET)
	NEW ROOT
	SET ROOT=$$ROOT(.STATE,DATASET)
	IF $DATA(@ROOT@("schema","columns")),$DATA(@ROOT@("rows")) QUIT
	KILL @ROOT
	IF DATASET="patient-registration" DO SEEDPAT(.STATE,ROOT) QUIT
	IF DATASET="ui-elements" DO SEEDUI(.STATE,ROOT) QUIT
	DO SEEDDEMO(.STATE,ROOT)
	QUIT
	;
SEEDDEMO(STATE,ROOT)
	DO COLR(ROOT,1,"name","Name","text",220,0,1,"Identity")
	DO COLR(ROOT,2,"status","Status","badge",120,0,1,"State")
	DO COLR(ROOT,3,"owner","Owner","text",150,0,1,"Ownership")
	DO COLR(ROOT,4,"priority","Priority","text",110,0,1,"State")
	DO COLR(ROOT,5,"updated","Updated","date",150,0,1,"Timeline")
	DO ROWR(ROOT,1,"demo-1","Audit backlog","Open","MIOOS","High","2026-05-01","Security and audit work items")
	DO ROWR(ROOT,2,"demo-2","Explorer grid","Done","Shell","Medium","2026-04-30","Resizable table source inspiration")
	DO ROWR(ROOT,3,"demo-3","Transfer manager","Open","VFS","High","2026-04-28","Upload and download transfer controls")
	DO ROWR(ROOT,4,"demo-4","Theme studio","Review","UI","Medium","2026-04-27","Customization and wallpaper persistence")
	QUIT
	;
SEEDPAT(STATE,ROOT)
	DO COLR(ROOT,1,"mrn","MRN","text",120,0,1,"Identity")
	DO COLR(ROOT,2,"lastName","Last name","text",150,0,1,"Identity")
	DO COLR(ROOT,3,"firstName","First name","text",150,0,1,"Identity")
	DO COLR(ROOT,4,"dob","DOB","date",120,0,1,"Demographics")
	DO COLR(ROOT,5,"phone","Phone","text",150,0,1,"Contact")
	DO COLR(ROOT,6,"status","Status","badge",110,0,1,"Care")
	DO COLR(ROOT,7,"primaryProvider","Provider","text",170,0,1,"Care")
	DO PATROW(ROOT,1,"PAT-1001","Garcia","Elena","1984-04-12","555-0101","Active","Dr. Shaw")
	DO PATROW(ROOT,2,"PAT-1002","Brown","Marcus","1972-09-03","555-0102","Pending","Dr. Singh")
	DO PATROW(ROOT,3,"PAT-1003","Chen","Avery","1991-12-21","555-0103","Active","Dr. Ortiz")
	QUIT
	;
SEEDUI(STATE,ROOT)
	DO COLR(ROOT,1,"element","Element","text",170,0,1,"Control")
	DO COLR(ROOT,2,"type","Type","badge",120,0,1,"Control")
	DO COLR(ROOT,3,"purpose","Purpose","text",320,0,1,"Documentation")
	DO COLR(ROOT,4,"sampleValue","Sample value","text",180,0,1,"Example")
	DO UIR(ROOT,1,"Text input","input","Single-line names, identifiers, and lookup fields","Jane Doe")
	DO UIR(ROOT,2,"Textarea","textarea","Clinical notes and long-form comments","Patient reports...")
	DO UIR(ROOT,3,"Select","select","Coded values such as status and priority","Active")
	DO UIR(ROOT,4,"Checkbox","checkbox","Boolean consent, flags, and bulk row selection","checked")
	DO UIR(ROOT,5,"Date","date","DOB, appointment date, review date","2026-05-02")
	QUIT
	;
MASSIVE(ROWS,SCHEMA)
	NEW I
	KILL ROWS,SCHEMA
	DO COL(.SCHEMA,1,"id","ID","text",110,0,1,"Identity")
	DO COL(.SCHEMA,2,"name","Name","text",210,0,1,"Identity")
	DO COL(.SCHEMA,3,"status","Status","badge",120,0,1,"State")
	DO COL(.SCHEMA,4,"owner","Owner","text",150,0,1,"Ownership")
	DO COL(.SCHEMA,5,"score","Score","number",90,0,1,"Metrics")
	DO COL(.SCHEMA,6,"updated","Updated","date",150,0,1,"Timeline")
	FOR I=1:1:10000 DO
	. SET ROWS(I,"id")="mass-"_I
	. SET ROWS(I,"name")="Massive dataset row "_I
	. SET ROWS(I,"status")=$SELECT(I#5=0:"Review",I#3=0:"Pending",1:"Active")
	. SET ROWS(I,"owner")="Worker "_(I#17)
	. SET ROWS(I,"score")=I#100
	. SET ROWS(I,"updated")="2026-05-"_$JUSTIFY(((I#28)+1),2)
	. SET ROWS(I,"_expand","title")="Generated row"
	. SET ROWS(I,"_expand","body")="Synthetic row for performance and pagination testing."
	QUIT
	;
COLR(ROOT,N,KEY,LABEL,TYPE,WIDTH,HIDDEN,SORTABLE,GROUP)
	SET @ROOT@("schema","columns",N,"key")=KEY
	SET @ROOT@("schema","columns",N,"label")=LABEL
	SET @ROOT@("schema","columns",N,"type")=TYPE
	SET @ROOT@("schema","columns",N,"width")=+WIDTH
	SET @ROOT@("schema","columns",N,"hidden")=+HIDDEN
	SET @ROOT@("schema","columns",N,"sortable")=+SORTABLE
	SET @ROOT@("schema","columns",N,"resizable")=1
	SET @ROOT@("schema","columns",N,"group")=$GET(GROUP)
	QUIT
	;
ROWR(ROOT,N,ID,NAME,STATUS,OWNER,PRIORITY,UPDATED,BODY)
	SET @ROOT@("rows",N,"id")=ID
	SET @ROOT@("rows",N,"name")=NAME
	SET @ROOT@("rows",N,"status")=STATUS
	SET @ROOT@("rows",N,"owner")=OWNER
	SET @ROOT@("rows",N,"priority")=PRIORITY
	SET @ROOT@("rows",N,"updated")=UPDATED
	SET @ROOT@("rows",N,"_expand","title")="Notes"
	SET @ROOT@("rows",N,"_expand","body")=BODY
	QUIT
	;
PATROW(ROOT,N,MRN,LAST,FIRST,DOB,PHONE,STATUS,PROV)
	SET @ROOT@("rows",N,"id")=MRN
	SET @ROOT@("rows",N,"mrn")=MRN
	SET @ROOT@("rows",N,"lastName")=LAST
	SET @ROOT@("rows",N,"firstName")=FIRST
	SET @ROOT@("rows",N,"dob")=DOB
	SET @ROOT@("rows",N,"phone")=PHONE
	SET @ROOT@("rows",N,"status")=STATUS
	SET @ROOT@("rows",N,"primaryProvider")=PROV
	SET @ROOT@("rows",N,"_expand","title")="Patient summary"
	SET @ROOT@("rows",N,"_expand","body")="MRN "_MRN_" — "_FIRST_" "_LAST_"."
	QUIT
	;
UIR(ROOT,N,EL,TYPE,PURPOSE,VAL)
	SET @ROOT@("rows",N,"id")="ui-"_N
	SET @ROOT@("rows",N,"element")=EL
	SET @ROOT@("rows",N,"type")=TYPE
	SET @ROOT@("rows",N,"purpose")=PURPOSE
	SET @ROOT@("rows",N,"sampleValue")=VAL
	SET @ROOT@("rows",N,"_expand","title")="Implementation note"
	SET @ROOT@("rows",N,"_expand","body")="Use this sample as a form control building block in MIOOS modules."
	QUIT
	;
VFS(STATE,IN,ROWS,SCHEMA,ERR)
	NEW LIST,PID,I,N
	KILL ROWS,SCHEMA
	SET PID=$SELECT($GET(IN("folderId"))'="":$GET(IN("folderId")),$GET(IN("parent"))'="":$GET(IN("parent")),1:$$DESKTOPID^MIOOSFS())
	IF '$$LIST^MIOOSFS(.STATE,PID,.LIST,.ERR) QUIT 0
	DO VFSSCHEMA(.SCHEMA)
	SET I=0,N=0 FOR  SET I=$ORDER(LIST("entries",I)) QUIT:I'>0  DO
	. SET N=N+1
	. SET ROWS(N,"id")=$GET(LIST("entries",I,"id"))
	. SET ROWS(N,"name")=$GET(LIST("entries",I,"name"))
	. SET ROWS(N,"type")=$GET(LIST("entries",I,"kind"))
	. SET ROWS(N,"mime")=$GET(LIST("entries",I,"mime"))
	. SET ROWS(N,"size")=+$GET(LIST("entries",I,"size"))
	. SET ROWS(N,"sizeLabel")=$GET(LIST("entries",I,"sizeLabel"))
	. SET ROWS(N,"modified")=$GET(LIST("entries",I,"modifiedLabel"),$GET(LIST("entries",I,"modifiedAt")))
	. SET ROWS(N,"owner")=$GET(LIST("entries",I,"owner"))
	. SET ROWS(N,"path")=$GET(LIST("entries",I,"path"))
	. SET ROWS(N,"_expand","title")="Details"
	. SET ROWS(N,"_expand","body")="Path: "_$GET(LIST("entries",I,"path"))_" | MIME: "_$GET(LIST("entries",I,"mime"))
	QUIT 1
	;
VFSSCHEMA(SCHEMA)
	KILL SCHEMA
	DO COL(.SCHEMA,1,"name","Name","text",260,0,1,"File")
	DO COL(.SCHEMA,2,"type","Type","text",140,0,1,"File")
	DO COL(.SCHEMA,3,"sizeLabel","Size","text",110,0,1,"Metadata")
	DO COL(.SCHEMA,4,"modified","Modified","text",170,0,1,"Metadata")
	DO COL(.SCHEMA,5,"owner","Owner","text",140,1,1,"Security")
	DO COL(.SCHEMA,6,"path","Path","text",320,1,1,"File")
	QUIT
	;
COL(SCHEMA,N,KEY,LABEL,TYPE,WIDTH,HIDDEN,SORTABLE,GROUP)
	SET SCHEMA("columns",N,"key")=KEY
	SET SCHEMA("columns",N,"label")=LABEL
	SET SCHEMA("columns",N,"type")=TYPE
	SET SCHEMA("columns",N,"width")=+WIDTH
	SET SCHEMA("columns",N,"hidden")=+HIDDEN
	SET SCHEMA("columns",N,"sortable")=+SORTABLE
	SET SCHEMA("columns",N,"resizable")=1
	SET SCHEMA("columns",N,"group")=$GET(GROUP)
	QUIT
	;
FILTER(ROWS,IN,WORK,TOTAL,FILTERED)
	NEW I,N,SEARCH
	KILL WORK
	SET (TOTAL,FILTERED,N)=0,SEARCH=$$LOW^MIOUTIL($GET(IN("search")))
	SET I=0 FOR  SET I=$ORDER(ROWS(I)) QUIT:I'>0  DO
	. SET TOTAL=TOTAL+1
	. IF SEARCH'="",'$$MATCH(.ROWS,I,SEARCH) QUIT
	. SET N=N+1,FILTERED=FILTERED+1
	. MERGE WORK(N)=ROWS(I)
	QUIT
	;
MATCH(ROWS,I,SEARCH)
	NEW KEY,VAL
	SET KEY="" FOR  SET KEY=$ORDER(ROWS(I,KEY)) QUIT:KEY=""  DO
	. IF $EXTRACT(KEY,1)="_" QUIT
	. SET VAL=$$LOW^MIOUTIL($GET(ROWS(I,KEY)))
	. IF VAL[SEARCH SET SEARCH=""
	QUIT $SELECT(SEARCH="":1,1:0)
	;
SORT(WORK,KEY,DIR)
	NEW I,J,N
	SET N=$ORDER(WORK(""),-1)
	FOR I=1:1:N-1 DO
	. FOR J=I+1:1:N DO
	. . IF $$CMP($GET(WORK(I,KEY)),$GET(WORK(J,KEY)),DIR) DO SWAP(.WORK,I,J)
	QUIT
	;
CMP(A,B,DIR)
	SET A=$$LOW^MIOUTIL($GET(A)),B=$$LOW^MIOUTIL($GET(B))
	IF DIR="descending" QUIT B]A
	QUIT A]B
	;
SWAP(WORK,I,J)
	NEW TMP
	MERGE TMP=WORK(I)
	KILL WORK(I) MERGE WORK(I)=WORK(J)
	KILL WORK(J) MERGE WORK(J)=TMP
	KILL TMP
	QUIT
	;
PAGE(WORK,OUT,PAGE,PSIZE,TOTAL,FILTERED)
	NEW START,END,I,N
	SET START=((PAGE-1)*PSIZE)+1,END=PAGE*PSIZE,N=0
	SET I=START-1 FOR  SET I=$ORDER(WORK(I)) QUIT:I'>0!(I>END)  DO
	. SET N=N+1
	. MERGE OUT("rows",N)=WORK(I)
	SET OUT("pagination","page")=PAGE
	SET OUT("pagination","pageSize")=PSIZE
	SET OUT("pagination","totalRows")=TOTAL
	SET OUT("pagination","filteredRows")=FILTERED
	SET OUT("pagination","pageRows")=N
	SET OUT("pagination","pageCount")=$SELECT(FILTERED=0:1,1:((FILTERED+PSIZE-1)\PSIZE))
	QUIT
	;
GROUPS(WORK,KEY,OUT)
	NEW I,G,N,VAL
	KILL OUT("groups")
	SET I=0 FOR  SET I=$ORDER(WORK(I)) QUIT:I'>0  DO
	. SET VAL=$GET(WORK(I,KEY)) IF VAL="" SET VAL="(blank)"
	. SET G=$ORDER(OUT("groups","byValue",VAL,0))
	. IF G'>0 DO
	. . SET N=$ORDER(OUT("groups",""),-1)+1
	. . SET OUT("groups",N,"key")=VAL,OUT("groups",N,"label")=VAL,OUT("groups",N,"count")=0
	. . SET OUT("groups","byValue",VAL,N)=""
	. . SET G=N
	. SET OUT("groups",G,"count")=+$GET(OUT("groups",G,"count"))+1
	KILL OUT("groups","byValue")
	QUIT
	;
ACTIONS(OUT)
	SET OUT("rowActions",1,"key")="edit",OUT("rowActions",1,"label")="Edit"
	SET OUT("rowActions",2,"key")="duplicate",OUT("rowActions",2,"label")="Duplicate"
	SET OUT("rowActions",3,"key")="delete",OUT("rowActions",3,"label")="Delete"
	SET OUT("bulkActions",1,"key")="export",OUT("bulkActions",1,"label")="Export selected"
	SET OUT("bulkActions",2,"key")="bulk.delete",OUT("bulkActions",2,"label")="Delete selected"
	QUIT
	;
	;