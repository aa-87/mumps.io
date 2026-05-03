MIOOSTBL ; MIOOS backend table query and mutation engine
	QUIT
	;
QUERY(STATE,CONF,IN,OUT,ERR)
	NEW DATASET,ROWS,SCHEMA,WORK,TOTAL,FILTERED,PAGE,PSIZE,SORTBY,SORTDIR,GROUPBY,DRAW,START,LENGTH,GROUPKEYS,GROUPN,ROOT
	NEW $ETRAP,$ESTACK SET $ETRAP="GOTO ERRQ^MIOOSTBL"
	KILL OUT,ERR,ROWS,SCHEMA,WORK
	SET ERR("routine")="MIOOSTBL"
	SET DATASET=$$DATASET($GET(IN("dataset"),"demo"))
	IF DATASET="massive" DO MASSIVEQ(.IN,.OUT,.CONF) QUIT 1
	IF DATASET="vfs" DO
	. IF '$$VFS(.STATE,.IN,.ROWS,.SCHEMA,.ERR) SET DATASET=""
	IF DATASET="patient-registration",'$$ALLOW^MIOOSPAT(.STATE,"query",.ERR) QUIT 0
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
	IF DATASET'="vfs" DO
	. SET ROOT=$$ROOT(.STATE,DATASET)
	. DO METASC(ROOT,.SCHEMA)
	. DO FIXSC(ROOT,.SCHEMA,.OUT)
	MERGE OUT("schema","columns")=SCHEMA("columns")
	IF DATASET'="vfs" DO
	. IF $DATA(@ROOT@("validation","fields")) MERGE OUT("validation","fields")=@ROOT@("validation","fields")
	DO ACTIONS(.OUT,$SELECT(DATASET="vfs":1,1:0))
	DO PAGE(.WORK,.OUT,PAGE,PSIZE,TOTAL,FILTERED)
	DO GROUPIN(.IN,.GROUPKEYS,.GROUPN)
	IF GROUPN>0 DO GROUPSM(.WORK,.GROUPKEYS,.OUT)
	SET OUT("ok")=1
	SET OUT("dataset")=DATASET
	SET OUT("contract")="mioos-advanced-table-v8"
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
	SET OUT("features","cellEditing")=$SELECT(DATASET="vfs":0,1:1)
	SET OUT("features","columnReorder")=$SELECT(DATASET="vfs":0,1:1)
	SET OUT("features","fixedColumns")=$SELECT(DATASET="vfs":0,1:1)
	IF DATASET="patient-registration" DO PATMETA^MIOOSPAT(.OUT,ROOT)
	SET OUT("draw")=DRAW
	SET OUT("recordsTotal")=TOTAL
	SET OUT("recordsFiltered")=FILTERED
	IF $$TRUTH($GET(IN("includeDataAlias"))) MERGE OUT("data")=OUT("rows")
	IF DATASET="patient-registration" DO MASKOUT^MIOOSPAT(.OUT,.STATE)
	QUIT 1
ERRQ
	SET $ECODE=""
	SET ERR("routine")="MIOOSTBL",ERR("error")="table_query_runtime_error",ERR("detail")=$ZSTATUS
	QUIT 0
	;
MUTATE(STATE,CONF,IN,OUT,ERR)
	NEW DATASET,ACTION,ROOT,ID,KEY,ORIG,I,N,FOUND,ROW,COL,OPTVAL,VAL,CBOUT
	NEW $ETRAP,$ESTACK SET $ETRAP="GOTO ERRM^MIOOSTBL"
	KILL OUT,ERR
	SET ERR("routine")="MIOOSTBL"
	SET DATASET=$$DATASET($GET(IN("dataset"),"demo"))
	IF DATASET="vfs" SET ERR("error")="vfs_table_read_only" QUIT 0
	IF DATASET="massive" SET ERR("error")="massive_table_read_only" QUIT 0
	SET ACTION=$$LOW^MIOUTIL($GET(IN("action"),$GET(IN("op"),"")))
	IF ACTION="" SET ERR("error")="table_action_missing" QUIT 0
	IF ACTION'["." SET ERR("error")="table_action_invalid" QUIT 0
	IF DATASET="patient-registration",'$$ALLOW^MIOOSPAT(.STATE,ACTION,.ERR) QUIT 0
	SET ROOT=$$ROOT(.STATE,DATASET)
	DO ENSURE(.STATE,DATASET)
	IF DATASET="patient-registration" DO ADDDEF^MIOOSPAT(ROOT,ACTION,.IN,.STATE)
	IF '$$VALIDATE(.STATE,.CONF,DATASET,ACTION,.IN,.ERR) DO  QUIT 0
	. IF DATASET="patient-registration" DO AUDPAT^MIOOSPAT(.STATE,.CONF,ACTION,.IN,.OUT,0,.ERR)
	IF ACTION="row.save"!(ACTION="row.add")!(ACTION="row.update") DO
	. SET ID=$GET(IN("row","id"))
	. IF DATASET="patient-registration",$GET(IN("row","mrn"))'="" SET ID=$GET(IN("row","mrn")),IN("row","id")=ID
	. IF ID="" SET ID=DATASET_"-"_$TR($$UUID^MIOUTIL(),"-","")
	. SET FOUND=0,I=0 FOR  SET I=$ORDER(@ROOT@("rows",I)) QUIT:I'>0  IF $GET(@ROOT@("rows",I,"id"))=ID SET FOUND=I
	. IF FOUND'>0 SET FOUND=$ORDER(@ROOT@("rows",""),-1)+1
	. KILL @ROOT@("rows",FOUND)
	. MERGE @ROOT@("rows",FOUND)=IN("row")
	. SET @ROOT@("rows",FOUND,"id")=ID
	. IF $GET(@ROOT@("rows",FOUND,"notes"))'="" SET @ROOT@("rows",FOUND,"_expand","title")="Notes",@ROOT@("rows",FOUND,"_expand","body")=$GET(@ROOT@("rows",FOUND,"notes"))
	. SET OUT("mutated","rowId")=ID
	IF ACTION="cell.save" DO
	. SET ID=$GET(IN("rowId"),$GET(IN("id")))
	. SET KEY=$$KEY($GET(IN("columnKey"),$GET(IN("key"))))
	. SET VAL=$GET(IN("value"))
	. KILL CBOUT
	. IF '$$CELLCB(.STATE,ROOT,DATASET,ID,KEY,.VAL,.CBOUT,.ERR) QUIT
	. SET FOUND=0,I=0 FOR  SET I=$ORDER(@ROOT@("rows",I)) QUIT:I'>0  IF $GET(@ROOT@("rows",I,"id"))=ID SET FOUND=I
	. IF FOUND'>0 SET ERR("error")="row_id_missing",ERR("message")="Row not found" QUIT
	. SET @ROOT@("rows",FOUND,KEY)=VAL
	. IF DATASET="patient-registration",KEY="status" SET @ROOT@("rows",FOUND,"status")=$$STATUS^MIOOSPAT(VAL)
	. IF KEY="notes" SET @ROOT@("rows",FOUND,"_expand","title")="Notes",@ROOT@("rows",FOUND,"_expand","body")=VAL
	. SET OUT("mutated","rowId")=ID,OUT("mutated","columnKey")=KEY
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
	. SET ORIG=$$KEY($GET(IN("originalKey"),$GET(IN("column","originalKey"))))
	. SET KEY=$$KEY($GET(IN("column","key")))
	. IF ORIG'="" SET KEY=ORIG,IN("column","key")=ORIG
	. IF KEY="" SET KEY="col"_($ORDER(@ROOT@("schema","columns",""),-1)+1)
	. SET FOUND=0,I=0 FOR  SET I=$ORDER(@ROOT@("schema","columns",I)) QUIT:I'>0  IF $GET(@ROOT@("schema","columns",I,"key"))=KEY SET FOUND=I
	. IF FOUND'>0 SET FOUND=$ORDER(@ROOT@("schema","columns",""),-1)+1
	. KILL @ROOT@("schema","columns",FOUND)
	. MERGE @ROOT@("schema","columns",FOUND)=IN("column")
	. KILL @ROOT@("schema","columns",FOUND,"originalKey")
	. SET @ROOT@("schema","columns",FOUND,"key")=KEY
	. IF $GET(@ROOT@("schema","columns",FOUND,"label"))="" SET @ROOT@("schema","columns",FOUND,"label")=KEY
	. IF +$GET(@ROOT@("schema","columns",FOUND,"width"))<1 SET @ROOT@("schema","columns",FOUND,"width")=140
	. IF $GET(@ROOT@("schema","columns",FOUND,"type"))="" SET @ROOT@("schema","columns",FOUND,"type")="text"
	. SET @ROOT@("schema","columns",FOUND,"resizable")=1
	. IF '$DATA(@ROOT@("schema","columns",FOUND,"editable")) SET @ROOT@("schema","columns",FOUND,"editable")=$SELECT(KEY="id":0,1:1)
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
	. SET I=0 FOR  SET I=$ORDER(@ROOT@("schema","columns",I)) QUIT:I'>0  IF $GET(@ROOT@("schema","columns",I,"key"))=KEY SET @ROOT@("schema","columns",I,"hidden")=$SELECT($$TRUTH($GET(IN("hidden"))):1,1:0)
	. SET OUT("mutated","columnVisibility")=KEY
	IF ACTION="column.reorder" DO REORDER(ROOT,.IN,.OUT)
	IF ACTION="column.fixed" DO FIXED(ROOT,.IN,.OUT)
	IF ACTION="column.option.add" DO
	. SET KEY=$$KEY($GET(IN("columnKey"),$GET(IN("key"))))
	. SET OPTVAL=$GET(IN("value"),$GET(IN("option","value")))
	. IF (KEY="")!(OPTVAL="") QUIT
	. IF '$$OPTEXISTS(ROOT,KEY,OPTVAL) DO
	. . SET N=$ORDER(@ROOT@("validation","fields",KEY,"enum",""),-1)+1
	. . SET @ROOT@("validation","fields",KEY,"enum",N)=OPTVAL
	. . SET I=0 FOR  SET I=$ORDER(@ROOT@("schema","columns",I)) QUIT:I'>0  IF $GET(@ROOT@("schema","columns",I,"key"))=KEY SET @ROOT@("schema","columns",I,"options",N)=OPTVAL
	. SET OUT("mutated","columnOption")=KEY,OUT("mutated","value")=OPTVAL
	IF DATASET="patient-registration",$EXTRACT(ACTION,1,8)="patient." DO PATACTION^MIOOSPAT(ROOT,ACTION,.IN,.OUT,.STATE)
	IF DATASET="patient-registration" DO POSTPAT^MIOOSPAT(ROOT,ACTION,.IN,.OUT,.STATE)
	IF ACTION="rows.export"!(ACTION="export") DO EXPORT(.STATE,DATASET,ROOT,.IN,.OUT)
	IF $GET(ERR("error"))'="" QUIT 0
	IF '$DATA(OUT("mutated")),'$DATA(OUT("export")) SET ERR("error")="unsupported_table_action" QUIT 0
	IF $DATA(OUT("export")) DO  QUIT 1
	. SET OUT("ok")=1,OUT("dataset")=DATASET,OUT("action")=ACTION,OUT("exportOnly")=1,OUT("message")=$GET(OUT("message"),"CSV export generated")
	. IF DATASET="patient-registration" DO AUDPAT^MIOOSPAT(.STATE,.CONF,ACTION,.IN,.OUT,1,.ERR)
	SET OUT("ok")=1,OUT("dataset")=DATASET,OUT("action")=ACTION,OUT("mutationOnly")=1,OUT("refetch")=1,OUT("message")=$GET(OUT("message"),$$MMSG(ACTION))
	IF DATASET="patient-registration" DO AUDPAT^MIOOSPAT(.STATE,.CONF,ACTION,.IN,.OUT,1,.ERR)
	QUIT 1
ERRM
	SET $ECODE=""
	SET ERR("routine")="MIOOSTBL",ERR("error")="table_mutation_runtime_error",ERR("detail")=$ZSTATUS
	QUIT 0
	;
VALIDATE(STATE,CONF,DATASET,ACTION,IN,ERR)
	KILL ERR("field"),ERR("fieldErrors")
	IF ACTION="row.save"!(ACTION="row.add")!(ACTION="row.update") QUIT $$VALROW(.STATE,DATASET,.CONF,.IN,.ERR)
	IF ACTION="cell.save" QUIT $$VALCELL(.STATE,DATASET,.CONF,.IN,.ERR)
	IF ACTION="row.delete" QUIT $$VALID($GET(IN("rowId"),$GET(IN("id"),$GET(IN("row","id")))),.ERR)
	IF ACTION="rows.delete"!(ACTION="bulk.delete") QUIT $$VALIDS(.IN,.ERR)
	IF ACTION="rows.export"!(ACTION="export") QUIT $$VALIDS(.IN,.ERR)
	IF ACTION="column.save"!(ACTION="column.add")!(ACTION="column.update") QUIT $$VALCOL(.CONF,.IN,.ERR)
	IF ACTION="column.delete"!(ACTION="column.resize")!(ACTION="column.visibility") QUIT $$VALKEY($GET(IN("columnKey"),$GET(IN("key"),$GET(IN("column","key")))),.ERR)
	IF ACTION="column.option.add" QUIT $$VALOPT(.IN,.ERR)
	IF ACTION="column.reorder" QUIT $$VALORDER($$ROOT(.STATE,DATASET),.IN,.ERR)
	IF ACTION="column.fixed" QUIT $$VALFIXED($$ROOT(.STATE,DATASET),.IN,.ERR)
	IF DATASET="patient-registration",$EXTRACT(ACTION,1,8)="patient." QUIT $$VALPACT^MIOOSPAT(ACTION,.IN,.ERR)
	SET ERR("error")="unsupported_table_action" QUIT 0
	;
VALROW(STATE,DATASET,CONF,IN,ERR)
	NEW KEY,VAL,MAX,ROOT
	SET MAX=+$GET(CONF("mioos","table","maxFieldChars"),2048) IF MAX<128 SET MAX=128
	IF '$DATA(IN("row")) SET ERR("error")="row_missing",ERR("message")="Row payload is required" QUIT 0
	SET KEY="" FOR  SET KEY=$ORDER(IN("row",KEY)) QUIT:KEY=""!($GET(ERR("error"))'="")  DO
	. IF $EXTRACT(KEY,1)="_" KILL IN("row",KEY) QUIT
	. IF $$KEY(KEY)'=KEY SET ERR("error")="invalid_row_field",ERR("field")=KEY,ERR("message")="Invalid row field" QUIT
	. SET VAL=$GET(IN("row",KEY))
	. IF $LENGTH(VAL)>MAX DO ADDERR(.ERR,KEY,"Value is too long") SET ERR("error")="field_too_long" QUIT
	IF $GET(ERR("error"))'="" QUIT 0
	SET ROOT=$$ROOT(.STATE,DATASET)
	IF '$$VALRULES(ROOT,.IN,.ERR) QUIT 0
	QUIT 1
	;
VALRULES(ROOT,IN,ERR)
	NEW KEY,VAL,MAX,MIN,OK
	SET OK=1
	SET KEY="" FOR  SET KEY=$ORDER(@ROOT@("validation","fields",KEY)) QUIT:KEY=""  DO
	. SET VAL=$GET(IN("row",KEY))
	. IF +$GET(@ROOT@("validation","fields",KEY,"required")),VAL="" DO ADDERR(.ERR,KEY,$GET(@ROOT@("validation","fields",KEY,"message"),"Required")) SET OK=0 QUIT
	. SET MAX=+$GET(@ROOT@("validation","fields",KEY,"maxLength")) IF MAX>0,$LENGTH(VAL)>MAX DO ADDERR(.ERR,KEY,"Maximum length is "_MAX) SET OK=0 QUIT
	. IF $DATA(@ROOT@("validation","fields",KEY,"enum")),VAL'="",'+$GET(@ROOT@("validation","fields",KEY,"multiselect")),'$$VALENUM(ROOT,KEY,VAL) DO ADDERR(.ERR,KEY,"Value is not allowed") SET OK=0 QUIT
	. IF +$GET(@ROOT@("validation","fields",KEY,"multiselect")),VAL'="",'$$VALMULT(ROOT,KEY,VAL) DO ADDERR(.ERR,KEY,"One or more selected values are not allowed") SET OK=0 QUIT
	. IF +$GET(@ROOT@("validation","fields",KEY,"boolean")),VAL'="",'$$VALBOOL(VAL) DO ADDERR(.ERR,KEY,"Choose true or false") SET OK=0 QUIT
	. IF +$GET(@ROOT@("validation","fields",KEY,"date")),VAL'="",'$$DATEOK(VAL) DO ADDERR(.ERR,KEY,"Use a valid YYYY-MM-DD date") SET OK=0 QUIT
	. IF +$GET(@ROOT@("validation","fields",KEY,"numeric")),VAL'="",'$$ISNUM(VAL) DO ADDERR(.ERR,KEY,"Enter a number") SET OK=0 QUIT
	. IF +$GET(@ROOT@("validation","fields",KEY,"numeric")),VAL'="",'$$VALRANGE(ROOT,KEY,VAL,.ERR) SET OK=0 QUIT
	IF OK,'$$ROWCB(ROOT,.IN,.ERR) SET OK=0
	IF 'OK,$GET(ERR("message"))="" SET ERR("message")="Please fix the highlighted fields"
	QUIT OK
	;
VALENUM(ROOT,KEY,VAL)
	NEW I,OK
	SET OK=0,I=0 FOR  SET I=$ORDER(@ROOT@("validation","fields",KEY,"enum",I)) QUIT:I'>0!(OK)  DO
	. IF $$LOW^MIOUTIL($GET(@ROOT@("validation","fields",KEY,"enum",I)))=$$LOW^MIOUTIL($GET(VAL)) SET OK=1
	QUIT OK
	;
VALMULT(ROOT,KEY,VAL)
	NEW I,PART,OK,ALL,SEP
	SET ALL=1,SEP=$SELECT($GET(VAL)["|":"|",$GET(VAL)[";":";",1:",")
	FOR I=1:1:$LENGTH($GET(VAL),SEP) DO  QUIT:'ALL
	. SET PART=$$TRIM^MIOUTIL($PIECE($GET(VAL),SEP,I))
	. IF PART="" QUIT
	. IF '$$VALENUM(ROOT,KEY,PART) SET ALL=0
	QUIT ALL
	;
VALBOOL(X)
	NEW Y
	SET Y=$$LOW^MIOUTIL($GET(X))
	IF Y="true"!(Y="false") QUIT 1
	IF Y="yes"!(Y="no") QUIT 1
	IF Y="on"!(Y="off") QUIT 1
	IF Y="1"!(Y="0") QUIT 1
	QUIT 0
	;
VALRANGE(ROOT,KEY,VAL,ERR)
	NEW MIN,MAX
	SET MIN=$GET(@ROOT@("validation","fields",KEY,"min"),$GET(@ROOT@("validation","fields",KEY,"minValue")))
	SET MAX=$GET(@ROOT@("validation","fields",KEY,"max"),$GET(@ROOT@("validation","fields",KEY,"maxValue")))
	IF MIN'="",+VAL<+MIN DO ADDERR(.ERR,KEY,"Minimum value is "_MIN) QUIT 0
	IF MAX'="",+VAL>+MAX DO ADDERR(.ERR,KEY,"Maximum value is "_MAX) QUIT 0
	QUIT 1
	;
ROWCB(ROOT,IN,ERR)
	NEW CB,X,OK
	SET CB=$GET(@ROOT@("validation","routine"))
	IF CB="" QUIT 1
	IF '$$CBACK(CB) SET ERR("error")="invalid_validation_routine",ERR("message")="Invalid validation routine" QUIT 0
	SET OK=0,X="SET OK=$$"_CB_"(.IN,.ERR,ROOT)"
	XECUTE X
	IF 'OK DO
	. IF $GET(ERR("error"))="" SET ERR("error")="validation_failed"
	. IF $GET(ERR("message"))="" SET ERR("message")="Row validation hook rejected the value"
	QUIT OK
	;
DATEOK(X)
	NEW Y,M,D,MAX,LEAP
	IF $GET(X)'?4N1"-"2N1"-"2N QUIT 0
	SET Y=+$EXTRACT(X,1,4),M=+$EXTRACT(X,6,7),D=+$EXTRACT(X,9,10)
	IF Y<1800!(Y>2999) QUIT 0
	IF M<1!(M>12) QUIT 0
	SET LEAP=$SELECT(Y#400=0:1,Y#100=0:0,Y#4=0:1,1:0)
	SET MAX=$SELECT(M=2:28+LEAP,M=4:30,M=6:30,M=9:30,M=11:30,1:31)
	IF D<1!(D>MAX) QUIT 0
	QUIT 1
	;
ISNUM(X)
	IF $GET(X)="" QUIT 0
	IF $GET(X)=+$GET(X) QUIT 1
	QUIT 0
	;
ADDERR(ERR,KEY,MSG)
	SET ERR("error")="validation_failed",ERR("field")=$GET(KEY)
	SET ERR("fieldErrors",KEY)=$GET(MSG,"Invalid value")
	IF $GET(ERR("message"))="" SET ERR("message")=$GET(MSG,"Invalid value")
	QUIT
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
VALCELL(STATE,DATASET,CONF,IN,ERR)
	NEW ROOT,KEY,ID,VAL,MAX,CI,CTYPE
	SET ROOT=$$ROOT(.STATE,DATASET)
	SET ID=$GET(IN("rowId"),$GET(IN("id")))
	IF ID="" SET ERR("error")="row_id_missing",ERR("message")="Choose a row to edit" QUIT 0
	SET KEY=$$KEY($GET(IN("columnKey"),$GET(IN("key"))))
	IF KEY="" SET ERR("error")="invalid_column_key",ERR("message")="Choose a valid column" QUIT 0
	SET CI=$$COLIDX(ROOT,KEY)
	IF CI'>0 SET ERR("error")="invalid_column_key",ERR("field")=KEY,ERR("message")="Column not found" QUIT 0
	IF KEY="id" SET ERR("error")="cell_read_only",ERR("field")=KEY,ERR("message")="ID cells are read-only" QUIT 0
	IF $DATA(@ROOT@("schema","columns",CI,"editable")),+$GET(@ROOT@("schema","columns",CI,"editable"))=0 SET ERR("error")="cell_read_only",ERR("field")=KEY,ERR("message")="This cell is read-only" QUIT 0
	SET MAX=+$GET(CONF("mioos","table","maxFieldChars"),2048) IF MAX<128 SET MAX=128
	SET VAL=$GET(IN("value"))
	IF $LENGTH(VAL)>MAX DO ADDERR(.ERR,KEY,"Value is too long") QUIT 0
	IF '$$VALCELLR(ROOT,DATASET,ID,KEY,VAL,.ERR) QUIT 0
	QUIT 1
	;
VALCELLR(ROOT,DATASET,ID,KEY,VAL,ERR)
	NEW MAX,OK
	SET OK=1
	IF +$GET(@ROOT@("validation","fields",KEY,"required")),VAL="" DO ADDERR(.ERR,KEY,$GET(@ROOT@("validation","fields",KEY,"message"),"Required")) QUIT 0
	SET MAX=+$GET(@ROOT@("validation","fields",KEY,"maxLength")) IF MAX>0,$LENGTH(VAL)>MAX DO ADDERR(.ERR,KEY,"Maximum length is "_MAX) QUIT 0
	IF $DATA(@ROOT@("validation","fields",KEY,"enum")),VAL'="",'+$GET(@ROOT@("validation","fields",KEY,"multiselect")),'$$VALENUM(ROOT,KEY,VAL) DO ADDERR(.ERR,KEY,"Value is not allowed") QUIT 0
	IF +$GET(@ROOT@("validation","fields",KEY,"multiselect")),VAL'="",'$$VALMULT(ROOT,KEY,VAL) DO ADDERR(.ERR,KEY,"One or more selected values are not allowed") QUIT 0
	IF +$GET(@ROOT@("validation","fields",KEY,"boolean")),VAL'="",'$$VALBOOL(VAL) DO ADDERR(.ERR,KEY,"Choose true or false") QUIT 0
	IF +$GET(@ROOT@("validation","fields",KEY,"date")),VAL'="",'$$DATEOK(VAL) DO ADDERR(.ERR,KEY,"Use a valid YYYY-MM-DD date") QUIT 0
	IF +$GET(@ROOT@("validation","fields",KEY,"numeric")),VAL'="",'$$ISNUM(VAL) DO ADDERR(.ERR,KEY,"Enter a number") QUIT 0
	IF +$GET(@ROOT@("validation","fields",KEY,"numeric")),VAL'="",'$$VALRANGE(ROOT,KEY,VAL,.ERR) QUIT 0
	IF DATASET="patient-registration",KEY="status",'$$VALSTATCELL^MIOOSPAT(ID,VAL,.ERR,ROOT) QUIT 0
	IF $GET(@ROOT@("validation","routine"))="VALPAT^MIOOSPAT",'$$VALFIELD^MIOOSPAT(KEY,VAL,.ERR,ROOT) QUIT 0
	QUIT OK
	;
COLIDX(ROOT,KEY)
	NEW I,FOUND
	SET FOUND=0,I=0 FOR  SET I=$ORDER(@ROOT@("schema","columns",I)) QUIT:I'>0!(FOUND)  IF $GET(@ROOT@("schema","columns",I,"key"))=KEY SET FOUND=I
	QUIT FOUND
	;
CELLCB(STATE,ROOT,DATASET,ID,KEY,VAL,OUT,ERR)
	NEW CI,CB,X,OK
	SET CI=$$COLIDX(ROOT,KEY),CB=$GET(@ROOT@("schema","columns",CI,"cellCallback"))
	IF CB="" QUIT 1
	IF '$$CBACK(CB) SET ERR("error")="invalid_cell_callback",ERR("field")=KEY,ERR("message")="Invalid cell callback" QUIT 0
	KILL OUT SET OK=0
	SET X="SET OK=$$"_CB_"(.STATE,DATASET,ID,KEY,.VAL,.OUT,.ERR)"
	XECUTE X
	IF 'OK DO  QUIT 0
	. IF $GET(ERR("error"))="" SET ERR("error")="validation_failed"
	. IF $GET(ERR("field"))="" SET ERR("field")=KEY
	. IF $GET(ERR("message"))="" SET ERR("message")="Cell callback rejected the value"
	. IF '$DATA(ERR("fieldErrors",KEY)) SET ERR("fieldErrors",KEY)=$GET(ERR("message"))
	IF $DATA(OUT("value")) SET VAL=$GET(OUT("value"))
	QUIT 1
	;
CBACK(X)
	NEW L,R,I,C,OK
	SET L=$PIECE($GET(X),"^",1),R=$PIECE($GET(X),"^",2),OK=1
	IF (L="")!(R="") QUIT 0
	FOR I=1:1:$LENGTH(L) SET C=$EXTRACT(L,I) IF (C'?1AN)&(C'="%") SET OK=0
	IF 'OK QUIT 0
	FOR I=1:1:$LENGTH(R) SET C=$EXTRACT(R,I) IF (C'?1AN)&(C'="%") SET OK=0
	QUIT OK
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
VALOPT(IN,ERR)
	NEW KEY,VAL
	SET KEY=$$KEY($GET(IN("columnKey"),$GET(IN("key"))))
	SET VAL=$GET(IN("value"),$GET(IN("option","value")))
	IF KEY="" SET ERR("error")="invalid_column_key",ERR("message")="Choose a valid column" QUIT 0
	IF VAL="" SET ERR("error")="option_value_missing",ERR("field")=KEY,ERR("message")="Option value is required" QUIT 0
	IF $LENGTH(VAL)>120 SET ERR("error")="option_value_too_long",ERR("field")=KEY,ERR("message")="Option value is too long" QUIT 0
	QUIT 1
	;
VALORDER(ROOT,IN,ERR)
	NEW I,KEY,IDX,COUNT,SEEN,EXIST
	SET (COUNT,EXIST)=0
	SET I=0 FOR  SET I=$ORDER(@ROOT@("schema","columns",I)) QUIT:I'>0  SET EXIST=EXIST+1
	SET I=0 FOR  SET I=$ORDER(IN("columns",I)) QUIT:I'>0!($GET(ERR("error"))'="")  DO
	. SET KEY=$$KEY($GET(IN("columns",I,"key")))
	. IF KEY="" SET ERR("error")="invalid_column_key",ERR("message")="Column reorder contains an invalid key" QUIT
	. IF $DATA(SEEN(KEY)) SET ERR("error")="duplicate_column_key",ERR("message")="Column reorder contains duplicate key "_KEY QUIT
	. SET IDX=$$COLIDX(ROOT,KEY)
	. IF IDX'>0 SET ERR("error")="unknown_column_key",ERR("message")="Column reorder contains unknown key "_KEY QUIT
	. SET SEEN(KEY)=1,COUNT=COUNT+1
	IF $GET(ERR("error"))'="" QUIT 0
	IF COUNT'>0 SET ERR("error")="column_order_missing",ERR("message")="Column reorder payload is required" QUIT 0
	IF EXIST>0,COUNT'=EXIST SET ERR("error")="column_order_incomplete",ERR("message")="Column reorder must include every column" QUIT 0
	QUIT 1
	;
FIXSC(ROOT,SCHEMA,OUT)
	NEW I,COUNT,START,END
	SET COUNT=0,I=0 FOR  SET I=$ORDER(SCHEMA("columns",I)) QUIT:I'>0  SET COUNT=COUNT+1
	SET START=+$GET(@ROOT@("schema","fixedColumns","start"),+$GET(@ROOT@("features","fixedStart"),0))
	SET END=+$GET(@ROOT@("schema","fixedColumns","end"),+$GET(@ROOT@("features","fixedEnd"),0))
	IF START<0 SET START=0
	IF END<0 SET END=0
	IF START>COUNT SET START=COUNT
	IF END>(COUNT-START) SET END=COUNT-START
	SET SCHEMA("fixedColumns","start")=START,SCHEMA("fixedColumns","end")=END
	SET OUT("schema","fixedColumns","start")=START,OUT("schema","fixedColumns","end")=END
	SET OUT("fixedColumns","start")=START,OUT("fixedColumns","end")=END
	QUIT
	;
VALFIXED(ROOT,IN,ERR)
	NEW START,END,COUNT,I
	SET COUNT=0,I=0 FOR  SET I=$ORDER(@ROOT@("schema","columns",I)) QUIT:I'>0  SET COUNT=COUNT+1
	SET START=+$GET(IN("fixedColumns","start"),+$GET(IN("start"),0))
	SET END=+$GET(IN("fixedColumns","end"),+$GET(IN("end"),0))
	IF START<0 SET ERR("error")="fixed_columns_invalid",ERR("message")="Fixed start columns cannot be negative" QUIT 0
	IF END<0 SET ERR("error")="fixed_columns_invalid",ERR("message")="Fixed end columns cannot be negative" QUIT 0
	IF COUNT>0,START+END>COUNT SET ERR("error")="fixed_columns_invalid",ERR("message")="Fixed start and end columns cannot exceed visible schema columns" QUIT 0
	QUIT 1
	;
FIXED(ROOT,IN,OUT)
	NEW START,END,COUNT,I
	SET COUNT=0,I=0 FOR  SET I=$ORDER(@ROOT@("schema","columns",I)) QUIT:I'>0  SET COUNT=COUNT+1
	SET START=+$GET(IN("fixedColumns","start"),+$GET(IN("start"),0))
	SET END=+$GET(IN("fixedColumns","end"),+$GET(IN("end"),0))
	IF START<0 SET START=0
	IF END<0 SET END=0
	IF START>COUNT SET START=COUNT
	IF END>(COUNT-START) SET END=COUNT-START
	SET @ROOT@("schema","fixedColumns","start")=START
	SET @ROOT@("schema","fixedColumns","end")=END
	SET OUT("mutated","fixedColumns","start")=START
	SET OUT("mutated","fixedColumns","end")=END
	QUIT
	;
OPTEXISTS(ROOT,KEY,VAL)
	NEW I,OK
	SET OK=0,I=0 FOR  SET I=$ORDER(@ROOT@("validation","fields",KEY,"enum",I)) QUIT:I'>0!(OK)  DO
	. IF $$LOW^MIOUTIL($GET(@ROOT@("validation","fields",KEY,"enum",I)))=$$LOW^MIOUTIL($GET(VAL)) SET OK=1
	QUIT OK
	;
TRUTH(X)
	NEW Y
	SET Y=$$LOW^MIOUTIL($GET(X))
	IF Y="true" QUIT 1
	IF Y="yes" QUIT 1
	IF Y="on" QUIT 1
	IF Y="1" QUIT 1
	QUIT 0
	;
MMSG(ACTION)
	IF ACTION="row.save"!(ACTION="row.add")!(ACTION="row.update") QUIT "Row saved"
	IF ACTION="cell.save" QUIT "Cell saved"
	IF ACTION="row.delete" QUIT "Row deleted"
	IF ACTION="rows.delete"!(ACTION="bulk.delete") QUIT "Rows deleted"
	IF ACTION="rows.export"!(ACTION="export") QUIT "CSV export generated"
	IF ACTION="column.visibility" QUIT "Column visibility updated"
	IF ACTION="column.resize" QUIT "Column resized"
	IF ACTION="column.save"!(ACTION="column.add")!(ACTION="column.update") QUIT "Column saved"
	IF ACTION="column.delete" QUIT "Column deleted"
	IF ACTION="column.option.add" QUIT "Column option added"
	IF ACTION="column.reorder" QUIT "Column order saved"
	IF ACTION="column.fixed" QUIT "Fixed columns updated"
	QUIT "Table updated"
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
	IF $DATA(@ROOT@("schema","columns")),$DATA(@ROOT@("rows")) DO BACKFILL(ROOT,DATASET) QUIT
	KILL @ROOT
	IF DATASET="patient-registration" DO SEEDPAT(.STATE,ROOT),BACKFILL(ROOT,DATASET) QUIT
	IF DATASET="ui-elements" DO SEEDUI(.STATE,ROOT) QUIT
	DO SEEDDEMO(.STATE,ROOT),BACKFILL(ROOT,DATASET)
	QUIT
	;
BACKFILL(ROOT,DATASET)
	NEW I,N
	IF DATASET="demo" DO
	. IF '$$HASC(ROOT,"notes") SET N=$ORDER(@ROOT@("schema","columns",""),-1)+1 DO COLR(ROOT,N,"notes","Notes","textarea",260,0,1,"Details")
	. SET I=0 FOR  SET I=$ORDER(@ROOT@("rows",I)) QUIT:I'>0  IF $GET(@ROOT@("rows",I,"notes"))="",$GET(@ROOT@("rows",I,"_expand","body"))'="" SET @ROOT@("rows",I,"notes")=$GET(@ROOT@("rows",I,"_expand","body"))
	. IF '$DATA(@ROOT@("validation")) DO SEEDVALD(ROOT)
	. DO SETCTYPE(ROOT,"status","select"),SETCTYPE(ROOT,"updated","date"),SETCTYPE(ROOT,"notes","textarea"),SETEDIT(ROOT)
	IF DATASET="patient-registration" DO
	. IF '$DATA(@ROOT@("validation")) DO SEEDVALP(ROOT)
	. DO SETCTYPE(ROOT,"dob","date"),SETCTYPE(ROOT,"status","select"),SETEDIT(ROOT)
	. DO INIT^MIOOSPAT(ROOT)
	QUIT
	;
SEEDVALD(ROOT)
	SET @ROOT@("validation","fields","name","required")=1
	SET @ROOT@("validation","fields","name","message")="Name is required"
	SET @ROOT@("validation","fields","status","enum",1)="Open"
	SET @ROOT@("validation","fields","status","enum",2)="Done"
	SET @ROOT@("validation","fields","status","enum",3)="Review"
	SET @ROOT@("validation","fields","status","enum",4)="Active"
	SET @ROOT@("validation","fields","status","enum",5)="Pending"
	SET @ROOT@("validation","fields","updated","date")=1
	SET @ROOT@("validation","fields","notes","maxLength")=2048
	QUIT
	;
SEEDVALP(ROOT)
	SET @ROOT@("validation","fields","mrn","required")=1
	SET @ROOT@("validation","fields","lastName","required")=1
	SET @ROOT@("validation","fields","firstName","required")=1
	SET @ROOT@("validation","fields","dob","required")=1
	SET @ROOT@("validation","fields","dob","date")=1
	SET @ROOT@("validation","fields","status","enum",1)="Active"
	SET @ROOT@("validation","fields","status","enum",2)="Pending"
	SET @ROOT@("validation","fields","status","enum",3)="Inactive"
	QUIT
	;
METASC(ROOT,SCHEMA)
	NEW I,J,KEY,N
	SET I=0 FOR  SET I=$ORDER(SCHEMA("columns",I)) QUIT:I'>0  DO
	. SET KEY=$GET(SCHEMA("columns",I,"key")) QUIT:KEY=""
	. IF +$GET(@ROOT@("validation","fields",KEY,"required")) SET SCHEMA("columns",I,"required")=1
	. IF +$GET(@ROOT@("validation","fields",KEY,"date")) SET SCHEMA("columns",I,"type")="date"
	. IF +$GET(@ROOT@("validation","fields",KEY,"numeric")) SET SCHEMA("columns",I,"type")="number"
	. IF +$GET(@ROOT@("validation","fields",KEY,"boolean")) SET SCHEMA("columns",I,"type")="boolean"
	. IF +$GET(@ROOT@("validation","fields",KEY,"multiselect")) SET SCHEMA("columns",I,"type")="multiselect"
	. IF KEY="notes" SET SCHEMA("columns",I,"type")="textarea"
	. IF $DATA(@ROOT@("validation","fields",KEY,"enum")) DO
	. . IF $GET(SCHEMA("columns",I,"type"))'="multiselect" SET SCHEMA("columns",I,"type")="select"
	. . KILL SCHEMA("columns",I,"options")
	. . SET J=0,N=0 FOR  SET J=$ORDER(@ROOT@("validation","fields",KEY,"enum",J)) QUIT:J'>0  DO
	. . . SET N=N+1,SCHEMA("columns",I,"options",N)=$GET(@ROOT@("validation","fields",KEY,"enum",J))
	QUIT
	;
SETCTYPE(ROOT,KEY,TYPE)
	NEW I
	SET I=0 FOR  SET I=$ORDER(@ROOT@("schema","columns",I)) QUIT:I'>0  IF $GET(@ROOT@("schema","columns",I,"key"))=$GET(KEY) SET @ROOT@("schema","columns",I,"type")=$GET(TYPE)
	QUIT
	;
SETEDIT(ROOT)
	NEW I,KEY
	SET I=0 FOR  SET I=$ORDER(@ROOT@("schema","columns",I)) QUIT:I'>0  DO
	. SET KEY=$GET(@ROOT@("schema","columns",I,"key"))
	. SET @ROOT@("schema","columns",I,"editable")=$SELECT(KEY="id":0,1:1)
	QUIT
	;
HASC(ROOT,KEY)
	NEW I,OK
	SET OK=0,I=0 FOR  SET I=$ORDER(@ROOT@("schema","columns",I)) QUIT:I'>0!(OK)  DO
	. IF $GET(@ROOT@("schema","columns",I,"key"))=KEY SET OK=1
	QUIT OK
	;
REORDER(ROOT,IN,OUT)
	NEW I,J,KEY,IDX,TMP
	KILL TMP
	SET (I,J)=0 FOR  SET I=$ORDER(IN("columns",I)) QUIT:I'>0  DO
	. SET KEY=$$KEY($GET(IN("columns",I,"key"))) QUIT:KEY=""
	. SET IDX=$$COLIDX(ROOT,KEY) QUIT:IDX'>0
	. SET J=J+1
	. MERGE TMP(J)=@ROOT@("schema","columns",IDX)
	. SET TMP(J,"key")=KEY
	KILL @ROOT@("schema","columns")
	MERGE @ROOT@("schema","columns")=TMP
	SET OUT("mutated","columnOrder")=J
	QUIT
	;
EXPORT(STATE,DATASET,ROOT,IN,OUT)
	NEW I,J,KEY,LINE,CSV,COUNT,ID,R
	KILL OUT
	SET CSV="",COUNT=0
	SET I=0,J=0 FOR  SET I=$ORDER(@ROOT@("schema","columns",I)) QUIT:I'>0  DO
	. SET KEY=$GET(@ROOT@("schema","columns",I,"key")) QUIT:KEY=""
	. IF $$TRUTH($GET(@ROOT@("schema","columns",I,"hidden"))) QUIT
	. SET J=J+1,OUT("export","columns",J,"key")=KEY,OUT("export","columns",J,"label")=$GET(@ROOT@("schema","columns",I,"label"),KEY)
	SET LINE="",I=0 FOR  SET I=$ORDER(OUT("export","columns",I)) QUIT:I'>0  DO
	. SET LINE=LINE_$SELECT(LINE'="":",",1:"")_$$CSVESC($GET(OUT("export","columns",I,"label")))
	SET CSV=LINE_$CHAR(13,10)
	SET R=0 FOR  SET R=$ORDER(@ROOT@("rows",R)) QUIT:R'>0  DO
	. SET ID=$GET(@ROOT@("rows",R,"id")) QUIT:ID=""
	. IF '$$IDSEL(.IN,ID) QUIT
	. SET LINE="",I=0 FOR  SET I=$ORDER(OUT("export","columns",I)) QUIT:I'>0  DO
	. . SET KEY=$GET(OUT("export","columns",I,"key"))
	. . SET LINE=LINE_$SELECT(LINE'="":",",1:"")_$$CSVESC($GET(@ROOT@("rows",R,KEY)))
	. SET CSV=CSV_LINE_$CHAR(13,10),COUNT=COUNT+1
	SET OUT("export","fileName")=DATASET_"_selected_rows.csv"
	SET OUT("export","contentType")="text/csv"
	SET OUT("export","csv")=CSV
	SET OUT("export","rowCount")=COUNT
	SET OUT("message")=COUNT_" row(s) exported"
	QUIT
	;
IDSEL(IN,ID)
	NEW I,OK
	SET OK=0,I=0 FOR  SET I=$ORDER(IN("ids",I)) QUIT:I'>0!(OK)  IF $GET(IN("ids",I))=$GET(ID) SET OK=1
	QUIT OK
	;
CSVESC(X)
	NEW Y,I,C,O,NEED
	SET Y=$GET(X),NEED=0
	IF Y["," SET NEED=1
	IF Y[$CHAR(34) SET NEED=1
	IF Y[$CHAR(10) SET NEED=1
	IF Y[$CHAR(13) SET NEED=1
	SET O="" FOR I=1:1:$LENGTH(Y) SET C=$EXTRACT(Y,I),O=O_$SELECT(C=$CHAR(34):$CHAR(34)_$CHAR(34),1:C)
	SET Y=O
	IF NEED SET Y=$CHAR(34)_Y_$CHAR(34)
	QUIT Y
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
	DO INIT^MIOOSPAT(ROOT)
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
	NEW SCHEMA,TOTAL,FILTERED,PAGE,PSIZE,DRAW,START,LENGTH,SORTBY,SORTDIR,SEARCH,I,VAL,IDX,SEQ,N,SKIP
	KILL OUT,SCHEMA,IDX
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
	IF $$MASSFAST(.IN,SEARCH,SORTBY) DO MASSFASTQ(.OUT,TOTAL,PAGE,PSIZE,DRAW,SORTDIR) QUIT
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
	SET OUT("ok")=1
	SET OUT("dataset")="massive"
	SET OUT("contract")="mioos-advanced-table-v8"
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
	SET OUT("features","cellEditing")=0
	SET OUT("features","fixedColumns")=0
	SET OUT("features","readOnly")=1
	SET OUT("draw")=DRAW
	SET OUT("recordsTotal")=TOTAL
	SET OUT("recordsFiltered")=FILTERED
	IF $$TRUTH($GET(IN("includeDataAlias"))) MERGE OUT("data")=OUT("rows")
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
MASSFASTQ(OUT,TOTAL,PAGE,PSIZE,DRAW,SORTDIR)
	NEW PAGECOUNT,SKIP,N,I,STEP
	SET PAGECOUNT=$SELECT(TOTAL=0:1,1:((TOTAL+PSIZE-1)\PSIZE))
	IF PAGE<1 SET PAGE=1
	IF PAGE>PAGECOUNT SET PAGE=PAGECOUNT
	SET SKIP=(PAGE-1)*PSIZE,N=0
	IF SORTDIR="descending" DO
	. SET I=TOTAL-SKIP+1 FOR  SET I=I-1 QUIT:I<1!(N'<PSIZE)  SET N=N+1 DO MASSROW(.OUT,N,I)
	IF SORTDIR'="descending" DO
	. SET I=SKIP FOR  SET I=I+1 QUIT:I>TOTAL!(N'<PSIZE)  SET N=N+1 DO MASSROW(.OUT,N,I)
	DO ACTIONS(.OUT,1)
	KILL OUT("bulkActions")
	SET OUT("ok")=1
	SET OUT("dataset")="massive"
	SET OUT("contract")="mioos-advanced-table-v8"
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
	SET OUT("features","cellEditing")=0
	SET OUT("features","fixedColumns")=0
	SET OUT("features","readOnly")=1
	SET OUT("draw")=DRAW
	SET OUT("recordsTotal")=TOTAL
	SET OUT("recordsFiltered")=TOTAL
	IF $$TRUTH($GET(IN("includeDataAlias"))) MERGE OUT("data")=OUT("rows")
	SET OUT("pagination","page")=PAGE
	SET OUT("pagination","pageSize")=PSIZE
	SET OUT("pagination","totalRows")=TOTAL
	SET OUT("pagination","filteredRows")=TOTAL
	SET OUT("pagination","pageRows")=N
	SET OUT("pagination","pageCount")=PAGECOUNT
	QUIT
	;
MASSOK(I,IN,SEARCH)
	NEW KEY,J,KEYS,OK
	IF $GET(SEARCH)'="" DO  IF SEARCH'="" QUIT 0
	. SET KEYS(1)="id",KEYS(2)="name",KEYS(3)="status",KEYS(4)="owner",KEYS(5)="score",KEYS(6)="updated"
	. SET J=0 FOR  SET J=$ORDER(KEYS(J)) QUIT:J'>0  DO  QUIT:SEARCH=""
	. . SET KEY=KEYS(J)
	. . IF $$LOW^MIOUTIL($$MASSVAL(I,KEY))[SEARCH SET SEARCH=""
	SET OK=1,KEY="" FOR  SET KEY=$ORDER(IN("filters",KEY)) QUIT:KEY=""  DO  QUIT:'OK
	. IF '$$FILTERVAL($$MASSVAL(I,KEY),.IN,KEY) SET OK=0
	QUIT OK
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
	SET @ROOT@("schema","columns",N,"editable")=$SELECT(KEY="id":0,1:1)
	QUIT
	;
ROWR(ROOT,N,ID,NAME,STATUS,OWNER,PRIORITY,UPDATED,BODY)
	SET @ROOT@("rows",N,"id")=ID
	SET @ROOT@("rows",N,"name")=NAME
	SET @ROOT@("rows",N,"status")=STATUS
	SET @ROOT@("rows",N,"owner")=OWNER
	SET @ROOT@("rows",N,"priority")=PRIORITY
	SET @ROOT@("rows",N,"updated")=UPDATED
	SET @ROOT@("rows",N,"notes")=BODY
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
	SET SCHEMA("columns",N,"editable")=$SELECT(KEY="id":0,1:1)
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
	NEW KEY,OK
	SET OK=1,KEY="" FOR  SET KEY=$ORDER(IN("filters",KEY)) QUIT:KEY=""  DO  QUIT:'OK
	. IF '$$FILTERVAL($GET(ROWS(I,KEY)),.IN,KEY) SET OK=0
	QUIT OK
	;
FILTERVAL(VALUE,IN,KEY)
	NEW MODE,VAL,FROM,TO,J,NEED,HIT
	SET MODE=$$LOW^MIOUTIL($GET(IN("filters",KEY,"mode")))
	IF MODE="" SET MODE=$$LOW^MIOUTIL($GET(IN("filters",KEY,"op")))
	IF MODE="" SET MODE="include"
	SET VAL=$$LOW^MIOUTIL($GET(VALUE)),HIT=0
	IF MODE="blank" QUIT $SELECT(VAL="":1,1:0)
	IF (MODE="notblank")!(MODE="not_blank") QUIT $SELECT(VAL'="":1,1:0)
	IF MODE="range" DO  QUIT HIT
	. SET FROM=$GET(IN("filters",KEY,"from")),TO=$GET(IN("filters",KEY,"to")),HIT=1
	. IF FROM'="",$$FCOMP(VALUE,FROM)<0 SET HIT=0
	. IF TO'="",$$FCOMP(VALUE,TO)>0 SET HIT=0
	IF $DATA(IN("filters",KEY,"values")) DO
	. SET J=0 FOR  SET J=$ORDER(IN("filters",KEY,"values",J)) QUIT:J'>0!(HIT)  DO
	. . SET NEED=$$LOW^MIOUTIL($GET(IN("filters",KEY,"values",J)))
	. . IF NEED="" SET HIT=1 QUIT
	. . IF MODE="contains",VAL[NEED SET HIT=1 QUIT
	. . IF MODE="starts",$EXTRACT(VAL,1,$LENGTH(NEED))=NEED SET HIT=1 QUIT
	. . IF MODE="ends",$EXTRACT(VAL,$LENGTH(VAL)-$LENGTH(NEED)+1,$LENGTH(VAL))=NEED SET HIT=1 QUIT
	. . IF VAL=NEED SET HIT=1
	IF '$DATA(IN("filters",KEY,"values")) DO
	. SET NEED=$$LOW^MIOUTIL($GET(IN("filters",KEY,"value"),$GET(IN("filters",KEY))))
	. IF NEED="" SET HIT=1 QUIT
	. IF MODE="contains",VAL[NEED SET HIT=1 QUIT
	. IF MODE="starts",$EXTRACT(VAL,1,$LENGTH(NEED))=NEED SET HIT=1 QUIT
	. IF MODE="ends",$EXTRACT(VAL,$LENGTH(VAL)-$LENGTH(NEED)+1,$LENGTH(VAL))=NEED SET HIT=1 QUIT
	. IF VAL=NEED SET HIT=1
	IF MODE="exclude" QUIT 'HIT
	QUIT HIT
	;
FCOMP(A,B)
	IF $$ISNUM(A),$$ISNUM(B) QUIT $SELECT(+A<+B:-1,+A>+B:1,1:0)
	SET A=$$LOW^MIOUTIL($GET(A)),B=$$LOW^MIOUTIL($GET(B))
	QUIT $SELECT(A]B:1,B]A:-1,1:0)
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
GROUPIN(IN,KEYS,N)
	NEW I,KEY
	KILL KEYS SET N=0
	SET I=0 FOR  SET I=$ORDER(IN("groupByColumns",I)) QUIT:I'>0  DO
	. SET KEY=$$KEY($GET(IN("groupByColumns",I))) IF KEY'="" SET N=N+1,KEYS(N)=KEY
	IF N=0,$GET(IN("groupBy"))'="" SET KEY=$$KEY($GET(IN("groupBy"))) IF KEY'="" SET N=1,KEYS(1)=KEY
	QUIT
	;
GROUPSM(WORK,KEYS,OUT)
	NEW I,J,G,N,VAL,LABEL
	KILL OUT("groups")
	SET I=0 FOR  SET I=$ORDER(WORK(I)) QUIT:I'>0  DO
	. SET LABEL="",J=0 FOR  SET J=$ORDER(KEYS(J)) QUIT:J'>0  DO
	. . SET VAL=$GET(WORK(I,KEYS(J))) IF VAL="" SET VAL="(blank)"
	. . SET LABEL=LABEL_$SELECT(LABEL'="":" / ",1:"")_VAL
	. SET G=$ORDER(OUT("groups","byValue",LABEL,0))
	. IF G'>0 DO
	. . SET N=$ORDER(OUT("groups",""),-1)+1
	. . SET OUT("groups",N,"key")=LABEL,OUT("groups",N,"label")=LABEL,OUT("groups",N,"count")=0
	. . SET OUT("groups","byValue",LABEL,N)=""
	. . SET G=N
	. SET OUT("groups",G,"count")=+$GET(OUT("groups",G,"count"))+1
	KILL OUT("groups","byValue")
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
ACTIONS(OUT,READONLY)
	KILL OUT("rowActions"),OUT("bulkActions")
	IF +$GET(READONLY) DO  QUIT
	. SET OUT("bulkActions",1,"key")="export",OUT("bulkActions",1,"label")="Export selected"
	SET OUT("rowActions",1,"key")="edit",OUT("rowActions",1,"label")="Edit"
	SET OUT("rowActions",2,"key")="duplicate",OUT("rowActions",2,"label")="Duplicate"
	SET OUT("rowActions",3,"key")="delete",OUT("rowActions",3,"label")="Delete"
	SET OUT("bulkActions",1,"key")="export",OUT("bulkActions",1,"label")="Export selected"
	SET OUT("bulkActions",2,"key")="bulk.delete",OUT("bulkActions",2,"label")="Delete selected"
	QUIT
	;	;