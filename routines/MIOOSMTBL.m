MIOOSMTBL ; MIOOS table-backed module definition service
	QUIT
	;
HANDLE(STATE,CONF,IN,OUT,ERR)
	NEW ACTION
	KILL OUT,ERR
	SET ERR("routine")="MIOOSMTBL"
	SET ACTION=$$LOW^MIOUTIL($GET(IN("action"),"list"))
	IF ACTION="list" QUIT $$LIST(.STATE,.CONF,.IN,.OUT,.ERR)
	IF ACTION="save" QUIT $$SAVE(.STATE,.CONF,.IN,.OUT,.ERR)
	IF ACTION="preview" QUIT $$PREVIEW(.STATE,.CONF,.IN,.OUT,.ERR)
	IF ACTION="export" QUIT $$EXPORT(.STATE,.CONF,.IN,.OUT,.ERR)
	IF ACTION="import" QUIT $$IMPORT(.STATE,.CONF,.IN,.OUT,.ERR)
	IF ACTION="revisions" QUIT $$REVS(.STATE,.CONF,.IN,.OUT,.ERR)
	IF ACTION="rollback" QUIT $$ROLLBACK(.STATE,.CONF,.IN,.OUT,.ERR)
	SET ERR("error")="module_table_action_unsupported",ERR("message")="Unsupported table module action"
	QUIT 0
	;
LIST(STATE,CONF,IN,OUT,ERR)
	NEW ROOT,KEY,N,Q,CAT
	KILL OUT
	SET OUT("ok")=1,OUT("contract")="mioos-table-module-library-v1",OUT("action")="list",OUT("count")=0
	SET ROOT=$$ROOT(.STATE),Q=$$LOW^MIOUTIL($GET(IN("q"))),CAT=$GET(IN("category"))
	SET KEY="" FOR  SET KEY=$ORDER(@ROOT@(KEY)) QUIT:KEY=""  DO
	. IF $GET(@ROOT@(KEY,"deleted")) QUIT
	. IF CAT'="",CAT'="all",$GET(@ROOT@(KEY,"category"))'=CAT QUIT
	. IF Q'="",$$LOW^MIOUTIL(KEY_" "_$GET(@ROOT@(KEY,"title"))_" "_$GET(@ROOT@(KEY,"description"))_" "_$GET(@ROOT@(KEY,"dataset"))_" "_$GET(@ROOT@(KEY,"category")))'[Q QUIT
	. SET N=+$GET(OUT("count"))+1,OUT("count")=N
	. DO DEFROW(ROOT,KEY,$NAME(OUT("definitions",N)))
	QUIT 1
	;
SAVE(STATE,CONF,IN,OUT,ERR)
	NEW DEF,KEY,ROOT,EXISTS
	KILL OUT,DEF
	IF $DATA(IN("definition")) MERGE DEF=IN("definition")
	IF '$DATA(IN("definition")) MERGE DEF=IN
	IF '$$VALIDDEF(.DEF,.ERR) QUIT 0
	SET KEY=$GET(DEF("key")),ROOT=$$ROOT(.STATE)
	SET EXISTS=$DATA(@ROOT@(KEY))
	IF EXISTS DO SNAP(.STATE,KEY,"save")
	DO STORE(.STATE,.DEF)
	DO INSTALL(.STATE,.DEF)
	DO AUDIT(.STATE,KEY,"save")
	SET OUT("ok")=1,OUT("contract")="mioos-table-module-library-v1",OUT("action")="save",OUT("key")=KEY,OUT("dataset")=$GET(DEF("dataset")),OUT("saved")=1,OUT("registered")=1,OUT("revisionCreated")=EXISTS,OUT("message")="Table module saved and registered"
	QUIT 1
	;
PREVIEW(STATE,CONF,IN,OUT,ERR)
	NEW DEF,N,I
	KILL OUT,DEF
	IF $DATA(IN("definition")) MERGE DEF=IN("definition")
	IF '$DATA(IN("definition")) MERGE DEF=IN
	IF '$$VALIDDEF(.DEF,.ERR) QUIT 0
	SET OUT("ok")=1,OUT("contract")="mioos-table-module-library-v1",OUT("action")="preview",OUT("dryRun")=1
	DO MANIFEST(.DEF,$NAME(OUT("module")))
	MERGE OUT("query","schema")=DEF("schema")
	SET OUT("query","ok")=1,OUT("query","dataset")=$GET(DEF("dataset")),OUT("query","recordsTotal")=0,OUT("query","recordsFiltered")=0
	SET N=0,I=0 FOR  SET I=$ORDER(DEF("rows",I)) QUIT:I'>0!(N>9)  DO
	. SET N=N+1 MERGE OUT("query","rows",N)=DEF("rows",I)
	SET OUT("query","recordsTotal")=N,OUT("query","recordsFiltered")=N,OUT("query","pagination","page")=1,OUT("query","pagination","pageSize")=10,OUT("query","pagination","totalRows")=N,OUT("query","pagination","filteredRows")=N,OUT("query","pagination","pageRows")=N,OUT("query","pagination","pageCount")=1
	QUIT 1
	;
EXPORT(STATE,CONF,IN,OUT,ERR)
	NEW KEY,ROOT
	KILL OUT
	SET KEY=$$KEY($GET(IN("key"),$GET(IN("moduleKey"))))
	IF KEY="" SET ERR("error")="module_key_missing",ERR("message")="Module key is required" QUIT 0
	SET ROOT=$$ROOT(.STATE)
	IF '$DATA(@ROOT@(KEY)) SET ERR("error")="module_not_found",ERR("message")="Table module was not found" QUIT 0
	SET OUT("ok")=1,OUT("contract")="mioos-table-module-library-v1",OUT("action")="export",OUT("key")=KEY,OUT("exportOnly")=1
	MERGE OUT("definition")=@ROOT@(KEY)
	KILL OUT("definition","audit"),OUT("definition","deleted")
	SET OUT("fileName")=KEY_"_table_module.json",OUT("contentType")="application/json",OUT("message")="Table module definition exported"
	QUIT 1
	;
IMPORT(STATE,CONF,IN,OUT,ERR)
	NEW DEF
	KILL DEF
	IF $DATA(IN("definition")) MERGE DEF=IN("definition")
	IF '$DATA(IN("definition")) MERGE DEF=IN
	IF $GET(IN("newKey"))'="" SET DEF("key")=$GET(IN("newKey"))
	IF '$$VALIDDEF(.DEF,.ERR) QUIT 0
	MERGE IN("definition")=DEF
	SET IN("action")="save"
	QUIT $$SAVE(.STATE,.CONF,.IN,.OUT,.ERR)
	;
REVS(STATE,CONF,IN,OUT,ERR)
	NEW KEY,RROOT,REV,N
	KILL OUT
	SET KEY=$$KEY($GET(IN("key"),$GET(IN("moduleKey"))))
	IF KEY="" SET ERR("error")="module_key_missing",ERR("message")="Module key is required" QUIT 0
	SET RROOT=$$REVROOT(.STATE,KEY)
	SET OUT("ok")=1,OUT("contract")="mioos-table-module-library-v1",OUT("action")="revisions",OUT("key")=KEY,OUT("count")=0
	SET REV="" FOR  SET REV=$ORDER(@RROOT@(REV),-1) QUIT:REV=""  DO
	. SET N=+$GET(OUT("count"))+1,OUT("count")=N
	. SET OUT("revisions",N,"id")=REV,OUT("revisions",N,"createdH")=$GET(@RROOT@(REV,"createdH")),OUT("revisions",N,"reason")=$GET(@RROOT@(REV,"reason")),OUT("revisions",N,"title")=$GET(@RROOT@(REV,"definition","title"))
	QUIT 1
	;
ROLLBACK(STATE,CONF,IN,OUT,ERR)
	NEW KEY,REV,RROOT,DEF
	KILL OUT,DEF
	SET KEY=$$KEY($GET(IN("key"),$GET(IN("moduleKey")))),REV=$GET(IN("revisionId"),$GET(IN("revision")))
	IF KEY="" SET ERR("error")="module_key_missing",ERR("message")="Module key is required" QUIT 0
	IF REV="" SET ERR("error")="revision_missing",ERR("message")="Revision id is required" QUIT 0
	SET RROOT=$$REVROOT(.STATE,KEY)
	IF '$DATA(@RROOT@(REV,"definition")) SET ERR("error")="revision_not_found",ERR("message")="Revision was not found" QUIT 0
	DO SNAP(.STATE,KEY,"rollback")
	MERGE DEF=@RROOT@(REV,"definition")
	IF '$$VALIDDEF(.DEF,.ERR) QUIT 0
	DO STORE(.STATE,.DEF)
	DO INSTALL(.STATE,.DEF)
	DO AUDIT(.STATE,KEY,"rollback")
	SET OUT("ok")=1,OUT("contract")="mioos-table-module-library-v1",OUT("action")="rollback",OUT("key")=KEY,OUT("revisionId")=REV,OUT("rolledBack")=1,OUT("registered")=1,OUT("message")="Table module rolled back and registered"
	QUIT 1
	;
VALIDDEF(DEF,ERR)
	NEW KEY,DATASET,TITLE,I,COLKEY,SEEN,ERRS
	KILL ERR("fieldErrors")
	SET ERRS=0
	SET KEY=$$KEY($GET(DEF("key"))) IF KEY="" DO FERR(.ERR,"key","Use a stable key with letters, numbers, or underscores") SET ERRS=1
	SET DATASET=$$KEY($GET(DEF("dataset"))) IF DATASET="" SET DATASET=KEY
	SET TITLE=$GET(DEF("title")) IF TITLE="" DO FERR(.ERR,"title","Title is required") SET ERRS=1
	IF $LENGTH(TITLE)>80 SET DEF("title")=$EXTRACT(TITLE,1,80)
	SET DEF("key")=KEY,DEF("dataset")=DATASET
	IF $GET(DEF("category"))="" SET DEF("category")="User"
	IF $GET(DEF("icon"))="" SET DEF("icon")="▤"
	IF $GET(DEF("description"))="" SET DEF("description")="User-created table-backed module"
	IF $GET(DEF("componentKey"))="" SET DEF("componentKey")="table"
	IF $GET(DEF("surface"))="" SET DEF("surface")="mioos-surface-table"
	IF '$DATA(DEF("schema","columns")) DO FERR(.ERR,"schema.columns","At least one column is required") SET ERRS=1
	KILL SEEN
	SET I=0 FOR  SET I=$ORDER(DEF("schema","columns",I)) QUIT:I'>0  DO
	. SET COLKEY=$$KEY($GET(DEF("schema","columns",I,"key")))
	. IF COLKEY="" DO FERR(.ERR,"schema.columns."_I_".key","Column key is required") SET ERRS=1 QUIT
	. IF $DATA(SEEN(COLKEY)) DO FERR(.ERR,"schema.columns."_I_".key","Column key must be unique") SET ERRS=1 QUIT
	. SET SEEN(COLKEY)=1,DEF("schema","columns",I,"key")=COLKEY
	. IF $GET(DEF("schema","columns",I,"label"))="" SET DEF("schema","columns",I,"label")=COLKEY
	. IF $GET(DEF("schema","columns",I,"type"))="" SET DEF("schema","columns",I,"type")="text"
	. IF +$GET(DEF("schema","columns",I,"width"))<48 SET DEF("schema","columns",I,"width")=140
	. IF $GET(DEF("schema","columns",I,"resizable"))="" SET DEF("schema","columns",I,"resizable")=1
	IF ERRS SET ERR("error")="validation_failed",ERR("message")="Table module definition has validation errors" QUIT 0
	QUIT 1
	;
STORE(STATE,DEF)
	NEW ROOT,KEY
	SET ROOT=$$ROOT(.STATE),KEY=$GET(DEF("key"))
	KILL @ROOT@(KEY)
	MERGE @ROOT@(KEY)=DEF
	SET @ROOT@(KEY,"updatedH")=$HOROLOG,@ROOT@(KEY,"source")="user",@ROOT@(KEY,"libraryContract")="mioos-table-module-library-v1"
	QUIT
	;
INSTALL(STATE,DEF)
	NEW USER,MROOT,TROOT,KEY,DATASET
	SET USER=$$USER(.STATE),KEY=$GET(DEF("key")),DATASET=$GET(DEF("dataset"))
	SET MROOT=$NAME(^MIO("MIOOS","MODULE","USER",USER)),TROOT=$NAME(^MIO("MIOOS","TABLE",USER,DATASET))
	KILL @MROOT@(KEY)
	DO MANIFEST(.DEF,$NAME(@MROOT@(KEY)))
	KILL @TROOT
	MERGE @TROOT@("schema")=DEF("schema")
	IF $DATA(DEF("validation")) MERGE @TROOT@("validation")=DEF("validation")
	IF $DATA(DEF("rows")) MERGE @TROOT@("rows")=DEF("rows")
	IF '$DATA(@TROOT@("rows")) SET @TROOT@("rows",0)=0
	QUIT
	;
MANIFEST(DEF,DEST)
	KILL @DEST
	SET @DEST@("id")=$GET(DEF("key")),@DEST@("key")=$GET(DEF("key")),@DEST@("appKey")=$GET(DEF("key"))
	SET @DEST@("title")=$GET(DEF("title")),@DEST@("description")=$GET(DEF("description")),@DEST@("category")=$GET(DEF("category")),@DEST@("icon")=$GET(DEF("icon"))
	SET @DEST@("source")="user",@DEST@("builtIn")=0,@DEST@("userCreated")=1,@DEST@("componentKey")="table",@DEST@("surface")="mioos-surface-table"
	SET @DEST@("dataset")=$GET(DEF("dataset"))
	SET @DEST@("tableState","id")=$GET(DEF("key"))_"-table",@DEST@("tableState","title")=$GET(DEF("title")),@DEST@("tableState","dataset")=$GET(DEF("dataset"))
	SET @DEST@("tableState","config","contract")="mioos-advanced-table-v8"
	SET @DEST@("tableState","config","features","rowCrud")=1,@DEST@("tableState","config","features","columnCrud")=1,@DEST@("tableState","config","features","selection")=1,@DEST@("tableState","config","features","bulkActions")=1,@DEST@("tableState","config","features","columnReorder")=1
	QUIT
	;
DEFROW(ROOT,KEY,DEST)
	KILL @DEST
	SET @DEST@("key")=KEY,@DEST@("id")=KEY,@DEST@("title")=$GET(@ROOT@(KEY,"title")),@DEST@("dataset")=$GET(@ROOT@(KEY,"dataset")),@DEST@("description")=$GET(@ROOT@(KEY,"description")),@DEST@("category")=$GET(@ROOT@(KEY,"category")),@DEST@("icon")=$GET(@ROOT@(KEY,"icon")),@DEST@("updatedH")=$GET(@ROOT@(KEY,"updatedH")),@DEST@("source")="user",@DEST@("userCreated")=1
	QUIT
	;
SNAP(STATE,KEY,WHY)
	NEW ROOT,RROOT,REV
	SET ROOT=$$ROOT(.STATE),RROOT=$$REVROOT(.STATE,KEY)
	IF '$DATA(@ROOT@(KEY)) QUIT
	SET REV=$TRANSLATE($HOROLOG,",","-")_"-"_($ORDER(@RROOT@(""),-1)+1)
	KILL @RROOT@(REV)
	SET @RROOT@(REV,"createdH")=$HOROLOG,@RROOT@(REV,"reason")=$GET(WHY)
	MERGE @RROOT@(REV,"definition")=@ROOT@(KEY)
	QUIT
	;
AUDIT(STATE,KEY,ACTION)
	NEW ROOT,N
	SET ROOT=$$ROOT(.STATE),N=$ORDER(@ROOT@(KEY,"audit",""),-1)+1
	SET @ROOT@(KEY,"audit",N,"action")=$GET(ACTION),@ROOT@(KEY,"audit",N,"atH")=$HOROLOG,@ROOT@(KEY,"audit",N,"principal")=$$USER(.STATE)
	QUIT
	;
FERR(ERR,FIELD,MSG)
	SET ERR("fieldErrors",FIELD)=MSG
	IF $GET(ERR("field"))="" SET ERR("field")=FIELD
	IF $GET(ERR("message"))="" SET ERR("message")=MSG
	QUIT
	;
KEY(X)
	QUIT $$KEY^MIOOSTBL($GET(X))
	;
USER(STATE)
	NEW USER
	SET USER=$GET(STATE("principal"),"guest") IF USER="" SET USER="guest"
	QUIT USER
	;
ROOT(STATE)
	QUIT $NAME(^MIO("MIOOS","TABLEMOD","USER",$$USER(.STATE)))
	;
REVROOT(STATE,KEY)
	QUIT $NAME(^MIO("MIOOS","TABLEMOD","REV",$$USER(.STATE),$GET(KEY)))
	;
