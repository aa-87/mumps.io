MIOOSTBL ; MIOOS backend table query and mutation engine
	QUIT
	;
QUERY(STATE,CONF,IN,OUT,ERR)
	NEW DATASET,ROWS,SCHEMA,WORK,TOTAL,FILTERED,PAGE,PSIZE,SORTBY,SORTDIR,DRAW,START,LENGTH,GROUPN,GROUPKEYS
	NEW $ETRAP,$ESTACK SET $ETRAP="GOTO ERRQ^MIOOSTBL"
	KILL OUT,ERR,ROWS,SCHEMA,WORK,GROUPKEYS
	SET ERR("routine")="MIOOSTBL"
	SET DATASET=$$DATASET($GET(IN("dataset"),"demo"))
	IF DATASET="massive" DO MASSIVEQ(.IN,.OUT,.CONF) QUIT 1
	IF DATASET="vfs" DO
	. IF '$$VFS(.STATE,.IN,.ROWS,.SCHEMA,.ERR) SET DATASET=""
	IF DATASET'="vfs",DATASET'="" DO LOADDATA(.STATE,DATASET,.ROWS,.SCHEMA)
	IF DATASET="" QUIT 0
	SET DRAW=+$GET(IN("draw"),$GET(IN("dt","draw"),0))
	SET LENGTH=+$GET(IN("length"),+$GET(IN("dt","length"),0))
	SET START=+$GET(IN("start"),+$GET(IN("dt","start"),0))
	SET PAGE=+$GET(IN("page"),0)
	SET PSIZE=+$GET(IN("pageSize"),0)
	IF PSIZE<1,LENGTH>0 SET PSIZE=LENGTH
	IF PSIZE<1 SET PSIZE=25
	IF PAGE<1,START>0 SET PAGE=(START\PSIZE)+1
	IF PAGE<1 SET PAGE=1
	IF PSIZE>+$GET(CONF("mioos","table","maxPageSize"),250) SET PSIZE=+$GET(CONF("mioos","table","maxPageSize"),250)
	SET SORTBY=$GET(IN("sort","column"),$GET(IN("sortBy"),"name"))
	SET SORTDIR=$$LOW^MIOUTIL($GET(IN("sort","direction"),$GET(IN("sortDir"),"ascending")))
	IF SORTDIR'="descending" SET SORTDIR="ascending"
	DO FILTER(.ROWS,.IN,.WORK,.TOTAL,.FILTERED)
	IF SORTBY'="" DO SORT(.WORK,SORTBY,SORTDIR)
	IF FILTERED=0 SET PAGE=1
	IF FILTERED>0,PAGE>((FILTERED+PSIZE-1)\PSIZE) SET PAGE=((FILTERED+PSIZE-1)\PSIZE)
	MERGE OUT("schema","columns")=SCHEMA("columns")
	DO ACTIONS(.OUT,$SELECT(DATASET="vfs":1,1:0))
	DO PAGE(.WORK,.OUT,PAGE,PSIZE,TOTAL,FILTERED)
	SET GROUPN=$$GROUPREQ(.IN,.GROUPKEYS)
	IF GROUPN>0 DO GROUPS(.WORK,.GROUPKEYS,.OUT)
	SET OUT("ok")=1
	SET OUT("contract")="mioos-advanced-table-v8"
	SET OUT("dataset")=DATASET
	IF GROUPN>0 MERGE OUT("groupByColumns")=GROUPKEYS
	SET OUT("features","serverPagination")=1
	SET OUT("features","serverSorting")=1
	SET OUT("features","columnVisibility")=1
	SET OUT("features","columnGrouping")=1
	SET OUT("features","expansionRows")=1
	SET OUT("features","actionRows")=1
	SET OUT("features","bulkActions")=1
	SET OUT("features","selection")=1
	SET OUT("features","filtering")=1
	SET OUT("features","crudRows")=$SELECT(DATASET="vfs":0,1:1)
	SET OUT("features","crudColumns")=$SELECT(DATASET="vfs":0,1:1)
	SET OUT("features","resizableColumns")=1
	SET OUT("draw")=DRAW
	SET OUT("recordsTotal")=TOTAL
	SET OUT("recordsFiltered")=FILTERED
	DO DATAALIAS(.IN,.OUT)
	QUIT 1
ERRQ
	SET $ECODE=""
	SET ERR("routine")="MIOOSTBL",ERR("error")="table_query_runtime_error",ERR("detail")=$ZSTATUS
	QUIT 0
	;
MUTATE(STATE,CONF,IN,OUT,ERR)
	NEW DATASET,ACTION,ROOT,ID,KEY,I,N,FOUND,ROW,COL
	NEW $ETRAP,$ESTACK SET $ETRAP="GOTO ERRM^MIOOSTBL"
	KILL OUT,ERR
	SET ERR("routine")="MIOOSTBL"
	SET DATASET=$$DATASET($GET(IN("dataset"),"demo"))
	IF DATASET="vfs" SET ERR("error")="vfs_table_read_only" QUIT 0
	IF DATASET="massive" SET ERR("error")="massive_table_read_only" QUIT 0
	SET ACTION=$$LOW^MIOUTIL($GET(IN("action"),$GET(IN("op"),"")))
	IF ACTION="" SET ERR("error")="table_action_missing" QUIT 0
	IF ACTION'["." SET ERR("error")="table_action_invalid" QUIT 0
	IF '$$VALIDATE(.STATE,.CONF,DATASET,ACTION,.IN,.ERR) QUIT 0
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
	SET OUT("ok")=1
	SET OUT("dataset")=DATASET
	SET OUT("action")=ACTION
	SET OUT("mutationOnly")=1
	SET OUT("refetch")=1
	SET OUT("message")=$$MSG(ACTION)
	QUIT 1
ERRM
	SET $ECODE=""
	SET ERR("routine")="MIOOSTBL",ERR("error")="table_mutation_runtime_error",ERR("detail")=$ZSTATUS
	QUIT 0
	;
VALIDATE(STATE,CONF,DATASET,ACTION,IN,ERR)
	KILL ERR("field")
	IF ACTION="row.save"!(ACTION="row.add")!(ACTION="row.update") QUIT $$VALROW(.CONF,.IN,.ERR)
	IF ACTION="row.delete" QUIT $$VALID($GET(IN("rowId"),$GET(IN("id"),$GET(IN("row","id")))),.ERR)
	IF ACTION="rows.delete"!(ACTION="bulk.delete") QUIT $$VALIDS(.IN,.ERR)
	IF ACTION="column.save"!(ACTION="column.add")!(ACTION="column.update") QUIT $$VALCOL(.CONF,.IN,.ERR)
	IF ACTION="column.delete"!(ACTION="column.resize")!(ACTION="column.visibility") QUIT $$VALKEY($GET(IN("columnKey"),$GET(IN("key"),$GET(IN("column","key")))),.ERR)
	SET ERR("error")="unsupported_table_action" QUIT 0
	;
VALROW(CONF,IN,ERR)
	NEW KEY,VAL,MAX
	SET MAX=+$GET(CONF("mioos","table","maxFieldChars"),2048) IF MAX<128 SET MAX=128
	IF '$DATA(IN("row")) SET ERR("error")="row_missing" QUIT 0
	SET KEY="" FOR  SET KEY=$ORDER(IN("row",KEY)) QUIT:KEY=""!($GET(ERR("error"))'="")  DO
	. IF $EXTRACT(KEY,1)="_" KILL IN("row",KEY) QUIT
	. IF $$KEY(KEY)'=KEY SET ERR("error")="validation_failed",ERR("message")="Invalid row field",ERR("field")=KEY,ERR("fieldErrors",KEY)="Invalid field key" QUIT
	. SET VAL=$GET(IN("row",KEY))
	. IF $LENGTH(VAL)>MAX SET ERR("error")="validation_failed",ERR("message")="Field is too long",ERR("field")=KEY,ERR("fieldErrors",KEY)="Maximum length exceeded",ERR("code")="field_too_long" QUIT
	IF $GET(ERR("error"))'="" QUIT 0
	QUIT 1
	;
VALID(ID,ERR)
	IF $GET(ID)="" SET ERR("error")="row_id_missing" QUIT 0
	IF $LENGTH(ID)>128 SET ERR("error")="row_id_too_long" QUIT 0
	QUIT 1
	;
VALIDS(IN,ERR)
	NEW I,SEEN
	SET SEEN=0,I=0 FOR  SET I=$ORDER(IN("ids",I)) QUIT:I'>0!($GET(ERR("error"))'="")  DO
	. SET SEEN=1 IF '$$VALID($GET(IN("ids",I)),.ERR) QUIT
	IF $GET(ERR("error"))'="" QUIT 0
	IF 'SEEN SET ERR("error")="row_ids_missing" QUIT 0
	QUIT 1
	;
VALCOL(CONF,IN,ERR)
	NEW KEY,LABEL,WIDTH
	SET KEY=$$KEY($GET(IN("column","key")))
	IF KEY="" SET ERR("error")="invalid_column_key" QUIT 0
	SET IN("column","key")=KEY
	SET LABEL=$GET(IN("column","label")) IF LABEL="" SET IN("column","label")=KEY
	IF $LENGTH($GET(IN("column","label")))>80 SET IN("column","label")=$EXTRACT(IN("column","label"),1,80)
	SET WIDTH=+$GET(IN("column","width")) IF WIDTH<48 SET WIDTH=120
	IF WIDTH>800 SET WIDTH=800
	SET IN("column","width")=WIDTH
	IF $GET(IN("column","type"))="" SET IN("column","type")="text"
	QUIT 1
	;
VALKEY(KEY,ERR)
	SET KEY=$$KEY($GET(KEY))
	IF KEY="" SET ERR("error")="invalid_column_key" QUIT 0
	QUIT 1
	;

KEY(X)
	NEW Y,I,C,Q S Q=0
	SET Y=$GET(X)
	IF Y="" QUIT ""
	IF $EXTRACT(Y)?1N QUIT ""
	FOR I=1:1:$LENGTH(Y) SET C=$EXTRACT(Y,I) IF (C'?1AN)&(C'="_") S Q=1 QUIT
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
	DO COLR(ROOT,5,"updated","Updated","date",150,0,1,"")
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
MASSIVEQ(IN,OUT,CONF)
	NEW SCHEMA,TOTAL,FILTERED,PAGE,PSIZE,DRAW,START,LENGTH,SORTBY,SORTDIR,SEARCH,I,VAL,IDX,SEQ,N,SKIP,GROUPN,GROUPKEYS,ROWVIEW
	KILL OUT,SCHEMA,IDX,GROUPKEYS
	SET TOTAL=10000,FILTERED=0
	DO MASSIVESC(.SCHEMA)
	MERGE OUT("schema","columns")=SCHEMA("columns")
	SET DRAW=+$GET(IN("draw"),$GET(IN("dt","draw"),0))
	SET LENGTH=+$GET(IN("length"),+$GET(IN("dt","length"),0))
	SET START=+$GET(IN("start"),+$GET(IN("dt","start"),0))
	SET PAGE=+$GET(IN("page"),0),PSIZE=+$GET(IN("pageSize"),0)
	IF PSIZE<1,LENGTH>0 SET PSIZE=LENGTH
	IF PSIZE<1 SET PSIZE=25
	IF PAGE<1,START>0 SET PAGE=(START\PSIZE)+1
	IF PAGE<1 SET PAGE=1
	IF PSIZE>+$GET(CONF("mioos","table","maxPageSize"),250) SET PSIZE=+$GET(CONF("mioos","table","maxPageSize"),250)
	SET SORTBY=$GET(IN("sort","column"),$GET(IN("sortBy"),"id"))
	SET SORTDIR=$$LOW^MIOUTIL($GET(IN("sort","direction"),$GET(IN("sortDir"),"ascending")))
	IF SORTDIR'="descending" SET SORTDIR="ascending"
	SET SEARCH=$$LOW^MIOUTIL($GET(IN("search")))
	IF $$MASSFAST(.IN,SEARCH,SORTBY) DO MASSFASTQ(.IN,.OUT,TOTAL,PAGE,PSIZE,DRAW,SORTDIR) QUIT
	FOR I=1:1:TOTAL IF $$MASSOK(I,.IN,SEARCH) DO
	. SET FILTERED=FILTERED+1
	. SET VAL=$$MASSKEY(I,SORTBY)
	. SET IDX(VAL,I)=""
	IF FILTERED=0 SET PAGE=1
	IF FILTERED>0,PAGE>((FILTERED+PSIZE-1)\PSIZE) SET PAGE=((FILTERED+PSIZE-1)\PSIZE)
	SET SKIP=(PAGE-1)*PSIZE,(SEQ,N)=0
	IF SORTDIR="descending" DO
	. SET VAL="" FOR  SET VAL=$ORDER(IDX(VAL),-1) QUIT:VAL=""  DO  QUIT:N'<PSIZE
	. . SET I="" FOR  SET I=$ORDER(IDX(VAL,I),-1) QUIT:I=""  DO  QUIT:N'<PSIZE
	. . . SET SEQ=SEQ+1 IF SEQ'>SKIP QUIT
	. . . SET N=N+1 DO MASSROW(.OUT,N,I)
	IF SORTDIR'="descending" DO
	. SET VAL="" FOR  SET VAL=$ORDER(IDX(VAL)) QUIT:VAL=""  DO  QUIT:N'<PSIZE
	. . SET I="" FOR  SET I=$ORDER(IDX(VAL,I)) QUIT:I=""  DO  QUIT:N'<PSIZE
	. . . SET SEQ=SEQ+1 IF SEQ'>SKIP QUIT
	. . . SET N=N+1 DO MASSROW(.OUT,N,I)
	DO ACTIONS(.OUT,1)
	SET GROUPN=$$GROUPREQ(.IN,.GROUPKEYS)
	IF GROUPN>0 DO
	. KILL ROWVIEW
	. MERGE ROWVIEW=OUT("rows")
	. DO GROUPS(.ROWVIEW,.GROUPKEYS,.OUT)
	SET OUT("ok")=1
	SET OUT("contract")="mioos-advanced-table-v8"
	SET OUT("dataset")="massive"
	IF GROUPN>0 MERGE OUT("groupByColumns")=GROUPKEYS
	SET OUT("features","serverPagination")=1
	SET OUT("features","serverSorting")=1
	SET OUT("features","columnVisibility")=1
	SET OUT("features","columnGrouping")=1
	SET OUT("features","expansionRows")=0
	SET OUT("features","actionRows")=0
	SET OUT("features","bulkActions")=0
	SET OUT("features","selection")=0
	SET OUT("features","filtering")=1
	SET OUT("features","crudRows")=0
	SET OUT("features","crudColumns")=0
	SET OUT("features","resizableColumns")=1
	SET OUT("features","readOnly")=1
	SET OUT("draw")=DRAW
	SET OUT("recordsTotal")=TOTAL
	SET OUT("recordsFiltered")=FILTERED
	DO DATAALIAS(.IN,.OUT)
	SET OUT("pagination","page")=PAGE
	SET OUT("pagination","pageSize")=PSIZE
	SET OUT("pagination","totalRows")=TOTAL
	SET OUT("pagination","filteredRows")=FILTERED
	SET OUT("pagination","pageRows")=N
	SET OUT("pagination","pageCount")=$SELECT(FILTERED=0:1,1:((FILTERED+PSIZE-1)\PSIZE))
	QUIT
	;
MASSIVESC(SCHEMA)
	KILL SCHEMA
	DO COL(.SCHEMA,1,"id","ID","text",96,0,1,"Identity")
	DO COL(.SCHEMA,2,"name","Name","text",220,0,1,"Identity")
	DO COL(.SCHEMA,3,"status","Status","badge",110,0,1,"State")
	DO COL(.SCHEMA,4,"owner","Owner","text",130,0,1,"Ownership")
	DO COL(.SCHEMA,5,"score","Score","number",82,0,1,"Metrics")
	DO COL(.SCHEMA,6,"updated","Updated","date",126,0,1,"")
	QUIT
	;
MASSROW(OUT,N,I)
	SET OUT("rows",N,"id")=$$MASSVAL(I,"id")
	SET OUT("rows",N,"name")=$$MASSVAL(I,"name")
	SET OUT("rows",N,"status")=$$MASSVAL(I,"status")
	SET OUT("rows",N,"owner")=$$MASSVAL(I,"owner")
	SET OUT("rows",N,"score")=$$MASSVAL(I,"score")
	SET OUT("rows",N,"updated")=$$MASSVAL(I,"updated")
	SET OUT("rows",N,"_expand","title")="Generated row"
	SET OUT("rows",N,"_expand","body")="Synthetic read-only row for server-side pagination testing."
	QUIT
	;
MASSFAST(IN,SEARCH,SORTBY)
	NEW KEY
	IF $GET(SEARCH)'="" QUIT 0
	IF $DATA(IN("filters")) QUIT 0
	SET KEY=$$LOW^MIOUTIL($GET(SORTBY))
	IF KEY="" QUIT 1
	IF KEY="id" QUIT 1
	IF KEY="name" QUIT 1
	QUIT 0
	;
MASSFASTQ(IN,OUT,TOTAL,PAGE,PSIZE,DRAW,SORTDIR)
	NEW PAGECOUNT,SKIP,N,I,STEP,GROUPN,GROUPKEYS,ROWVIEW
	SET PAGECOUNT=$SELECT(TOTAL=0:1,1:((TOTAL+PSIZE-1)\PSIZE))
	IF PAGE<1 SET PAGE=1
	IF PAGE>PAGECOUNT SET PAGE=PAGECOUNT
	SET SKIP=(PAGE-1)*PSIZE,N=0
	IF SORTDIR="descending" DO
	. SET I=TOTAL-SKIP+1 FOR  SET I=I-1 QUIT:I<1!(N'<PSIZE)  SET N=N+1 DO MASSROW(.OUT,N,I)
	IF SORTDIR'="descending" DO
	. SET I=SKIP FOR  SET I=I+1 QUIT:I>TOTAL!(N'<PSIZE)  SET N=N+1 DO MASSROW(.OUT,N,I)
	DO ACTIONS(.OUT,1)
	SET GROUPN=$$GROUPREQ(.IN,.GROUPKEYS)
	IF GROUPN>0 DO
	. KILL ROWVIEW
	. MERGE ROWVIEW=OUT("rows")
	. DO GROUPS(.ROWVIEW,.GROUPKEYS,.OUT)
	SET OUT("ok")=1
	SET OUT("contract")="mioos-advanced-table-v8"
	SET OUT("dataset")="massive"
	IF GROUPN>0 MERGE OUT("groupByColumns")=GROUPKEYS
	SET OUT("features","serverPagination")=1
	SET OUT("features","serverSorting")=1
	SET OUT("features","columnVisibility")=1
	SET OUT("features","columnGrouping")=1
	SET OUT("features","expansionRows")=0
	SET OUT("features","actionRows")=0
	SET OUT("features","bulkActions")=0
	SET OUT("features","selection")=0
	SET OUT("features","filtering")=1
	SET OUT("features","crudRows")=0
	SET OUT("features","crudColumns")=0
	SET OUT("features","resizableColumns")=1
	SET OUT("features","readOnly")=1
	SET OUT("draw")=DRAW
	SET OUT("recordsTotal")=TOTAL
	SET OUT("recordsFiltered")=TOTAL
	DO DATAALIAS(.IN,.OUT)
	SET OUT("pagination","page")=PAGE
	SET OUT("pagination","pageSize")=PSIZE
	SET OUT("pagination","totalRows")=TOTAL
	SET OUT("pagination","filteredRows")=TOTAL
	SET OUT("pagination","pageRows")=N
	SET OUT("pagination","pageCount")=PAGECOUNT
	QUIT
	;
MASSOK(I,IN,SEARCH)
	NEW KEY,VAL,NEED,OK,J,SEEN,KEYS
	IF $GET(SEARCH)'="" DO  IF SEARCH'="" QUIT 0
	. SET KEYS(1)="id",KEYS(2)="name",KEYS(3)="status",KEYS(4)="owner",KEYS(5)="score",KEYS(6)="updated"
	. SET J=0 FOR  SET J=$ORDER(KEYS(J)) QUIT:J'>0  DO  QUIT:SEARCH=""
	. . SET KEY=KEYS(J)
	. . IF $$LOW^MIOUTIL($$MASSVAL(I,KEY))[SEARCH SET SEARCH=""
	SET SEEN=0,OK=1
	SET KEY="" FOR  SET KEY=$ORDER(IN("filters",KEY)) QUIT:KEY=""  DO  QUIT:'OK
	. SET SEEN=1,OK=0,VAL=$$LOW^MIOUTIL($$MASSVAL(I,KEY))
	. IF $DATA(IN("filters",KEY))=1 DO  QUIT
	. . SET NEED=$$LOW^MIOUTIL($GET(IN("filters",KEY)))
	. . IF NEED="" SET OK=1 QUIT
	. . IF VAL=NEED SET OK=1
	. SET J=0 FOR  SET J=$ORDER(IN("filters",KEY,J)) QUIT:J'>0  DO
	. . SET NEED=$$LOW^MIOUTIL($GET(IN("filters",KEY,J)))
	. . IF NEED="" SET OK=1
	. . IF VAL=NEED SET OK=1
	QUIT $SELECT('SEEN:1,OK:1,1:0)
	;
MASSKEY(I,KEY)
	SET KEY=$$LOW^MIOUTIL($GET(KEY))
	IF KEY="score" QUIT $$PAD(+$GET(I)#100,6)
	IF KEY="id" QUIT $$PAD(+I,8)
	IF KEY="name" QUIT "massive dataset row "_$$PAD(+I,8)
	IF KEY="owner" QUIT "worker "_$$PAD((+I#17),4)_":"_$$PAD(+I,8)
	IF KEY="updated" QUIT $$MASSVAL(I,"updated")_":"_$$PAD(+I,8)
	IF KEY="status" QUIT $$LOW^MIOUTIL($$MASSVAL(I,"status"))_":"_$$PAD(+I,8)
	QUIT $$PAD(+I,8)
	;
MASSVAL(I,KEY)
	SET KEY=$$LOW^MIOUTIL($GET(KEY))
	IF KEY="id" QUIT "mass-"_I
	IF KEY="name" QUIT "Massive dataset row "_I
	IF KEY="status" QUIT $SELECT(I#5=0:"Review",I#3=0:"Pending",1:"Active")
	IF KEY="owner" QUIT "Worker "_(I#17)
	IF KEY="score" QUIT I#100
	IF KEY="updated" QUIT "2026-05-"_$$PAD(((I#28)+1),2)
	QUIT ""
	;
PAD(N,W)
	QUIT $TRANSLATE($JUSTIFY(+N,+$GET(W,8))," ","0")
	;
MASSIVE(ROWS,SCHEMA)
	NEW I
	KILL ROWS,SCHEMA
	DO COL(.SCHEMA,1,"id","ID","text",110,0,1,"Identity")
	DO COL(.SCHEMA,2,"name","Name","text",210,0,1,"Identity")
	DO COL(.SCHEMA,3,"status","Status","badge",120,0,1,"State")
	DO COL(.SCHEMA,4,"owner","Owner","text",150,0,1,"Ownership")
	DO COL(.SCHEMA,5,"score","Score","number",90,0,1,"Metrics")
	DO COL(.SCHEMA,6,"updated","Updated","date",150,0,1,"")
	FOR I=1:1:10000 DO
	. SET ROWS(I,"id")="mass-"_I
	. SET ROWS(I,"name")="Massive dataset row "_I
	. SET ROWS(I,"status")=$SELECT(I#5=0:"Review",I#3=0:"Pending",1:"Active")
	. SET ROWS(I,"owner")="Worker "_(I#17)
	. SET ROWS(I,"score")=I#100
	. SET ROWS(I,"updated")="2026-05-"_$$PAD(((I#28)+1),2)
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
	. IF '$$FILTEROK(.ROWS,I,.IN) QUIT
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
FILTEROK(ROWS,I,IN)
	NEW KEY,VAL,NEED,OK,J,SEEN
	SET SEEN=0,OK=1
	SET KEY="" FOR  SET KEY=$ORDER(IN("filters",KEY)) QUIT:KEY=""  DO  QUIT:'OK
	. SET SEEN=1,OK=0,VAL=$$LOW^MIOUTIL($GET(ROWS(I,KEY)))
	. IF $DATA(IN("filters",KEY))=1 DO  QUIT
	. . SET NEED=$$LOW^MIOUTIL($GET(IN("filters",KEY)))
	. . IF NEED="" SET OK=1 QUIT
	. . IF VAL=NEED SET OK=1
	. SET J=0 FOR  SET J=$ORDER(IN("filters",KEY,J)) QUIT:J'>0  DO
	. . SET NEED=$$LOW^MIOUTIL($GET(IN("filters",KEY,J)))
	. . IF NEED="" SET OK=1
	. . IF VAL=NEED SET OK=1
	. IF 'OK QUIT
	QUIT $SELECT('SEEN:1,OK:1,1:0)
	;
SORT(WORK,KEY,DIR)
	NEW I,N,VAL,IDX,ORDER,OUT,SEQ
	SET I=0 FOR  SET I=$ORDER(WORK(I)) QUIT:I'>0  DO
	. SET VAL=$$SORTKEY($GET(WORK(I,KEY)))
	. SET IDX(VAL,I)=""
	KILL OUT SET SEQ=0
	IF DIR="descending" DO
	. SET VAL="" FOR  SET VAL=$ORDER(IDX(VAL),-1) QUIT:VAL=""  DO
	. . SET I="" FOR  SET I=$ORDER(IDX(VAL,I),-1) QUIT:I=""  DO
	. . . SET SEQ=SEQ+1 MERGE OUT(SEQ)=WORK(I)
	IF DIR'="descending" DO
	. SET VAL="" FOR  SET VAL=$ORDER(IDX(VAL)) QUIT:VAL=""  DO
	. . SET I="" FOR  SET I=$ORDER(IDX(VAL,I)) QUIT:I=""  DO
	. . . SET SEQ=SEQ+1 MERGE OUT(SEQ)=WORK(I)
	KILL WORK MERGE WORK=OUT
	QUIT
	;
SORTKEY(X)
	NEW Y
	SET Y=$$LOW^MIOUTIL($GET(X))
	IF Y="" SET Y=" "
	QUIT $EXTRACT(Y,1,180)
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
GROUPREQ(IN,KEYS)
	NEW I,N,KEY
	KILL KEYS SET N=0
	SET I=0 FOR  SET I=$ORDER(IN("groupByColumns",I)) QUIT:I'>0  DO
	. SET KEY=$$KEY($GET(IN("groupByColumns",I)))
	. IF KEY'="" SET N=N+1,KEYS(N)=KEY
	IF N'>0 DO
	. SET KEY=$$KEY($GET(IN("groupBy")))
	. IF KEY'="" SET N=1,KEYS(1)=KEY
	QUIT N
	;
GROUPS(WORK,KEYS,OUT)
	NEW I,J,G,N,VAL,GKEY,GLABEL,KEY,SEP
	KILL OUT("groups")
	SET I=0 FOR  SET I=$ORDER(WORK(I)) QUIT:I'>0  DO
	. SET (GKEY,GLABEL)="",SEP=""
	. SET J=0 FOR  SET J=$ORDER(KEYS(J)) QUIT:J'>0  DO
	. . SET KEY=$GET(KEYS(J)),VAL=$GET(WORK(I,KEY)) IF VAL="" SET VAL="(blank)"
	. . SET GKEY=GKEY_SEP_KEY_"="_VAL,GLABEL=GLABEL_SEP_VAL,SEP=" / "
	. IF GKEY="" SET GKEY="(all)",GLABEL="(all)"
	. SET G=$ORDER(OUT("groups","byValue",GKEY,0))
	. IF G'>0 DO
	. . SET N=$ORDER(OUT("groups",""),-1)+1
	. . SET OUT("groups",N,"key")=GKEY,OUT("groups",N,"label")=GLABEL,OUT("groups",N,"count")=0
	. . SET J=0 FOR  SET J=$ORDER(KEYS(J)) QUIT:J'>0  SET OUT("groups",N,"columns",J)=$GET(KEYS(J))
	. . SET OUT("groups","byValue",GKEY,N)=""
	. . SET G=N
	. SET OUT("groups",G,"count")=+$GET(OUT("groups",G,"count"))+1
	KILL OUT("groups","byValue")
	QUIT
	;
DATAALIAS(IN,OUT)
	IF +$GET(IN("includeDataAlias")) MERGE OUT("data")=OUT("rows")
	QUIT
	;
MSG(ACTION)
	IF ACTION="column.visibility" QUIT "Column visibility updated"
	IF ACTION="column.resize" QUIT "Column width updated"
	IF ACTION="column.save"!(ACTION="column.add")!(ACTION="column.update") QUIT "Column saved"
	IF ACTION="column.delete" QUIT "Column deleted"
	IF ACTION="row.delete" QUIT "Row deleted"
	IF ACTION="rows.delete"!(ACTION="bulk.delete") QUIT "Rows deleted"
	IF ACTION="row.save"!(ACTION="row.add")!(ACTION="row.update") QUIT "Row saved"
	QUIT "Table mutation applied"
	;
ACTIONS(OUT,READONLY)
	KILL OUT("rowActions"),OUT("bulkActions")
	IF +$GET(READONLY) QUIT
	SET OUT("rowActions",1,"key")="edit",OUT("rowActions",1,"label")="Edit"
	SET OUT("rowActions",2,"key")="duplicate",OUT("rowActions",2,"label")="Duplicate"
	SET OUT("rowActions",3,"key")="delete",OUT("rowActions",3,"label")="Delete"
	SET OUT("bulkActions",1,"key")="export",OUT("bulkActions",1,"label")="Export selected"
	SET OUT("bulkActions",2,"key")="bulk.delete",OUT("bulkActions",2,"label")="Delete selected"
	QUIT
	;	;