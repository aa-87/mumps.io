MIOOSTBL ; MIOOS backend table query engine
	QUIT
	;
QUERY(STATE,CONF,IN,OUT,ERR)
	NEW DATASET,ROWS,SCHEMA,WORK,TOTAL,FILTERED,PAGE,PSIZE,SORTBY,SORTDIR,GROUPBY
	KILL OUT,ERR,ROWS,SCHEMA,WORK
	SET ERR("routine")="MIOOSTBL"
	SET DATASET=$$LOW^MIOUTIL($GET(IN("dataset"),"demo"))
	IF DATASET="" SET DATASET="demo"
	IF DATASET="vfs" DO
	. IF '$$VFS(.STATE,.IN,.ROWS,.SCHEMA,.ERR) SET DATASET=""
	IF DATASET'="vfs",DATASET'="" DO DEMO(.ROWS,.SCHEMA)
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
	SET OUT("features","selection")=1
	SET OUT("features","filtering")=1
	QUIT 1
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
	DO COL(.SCHEMA,1,"name","Name","text",260,0,1)
	DO COL(.SCHEMA,2,"type","Type","text",140,0,1)
	DO COL(.SCHEMA,3,"sizeLabel","Size","text",110,0,1)
	DO COL(.SCHEMA,4,"modified","Modified","text",170,0,1)
	DO COL(.SCHEMA,5,"owner","Owner","text",140,1,1)
	DO COL(.SCHEMA,6,"path","Path","text",320,1,1)
	QUIT
	;
DEMO(ROWS,SCHEMA)
	KILL ROWS,SCHEMA
	DO COL(.SCHEMA,1,"name","Name","text",220,0,1)
	DO COL(.SCHEMA,2,"status","Status","badge",120,0,1)
	DO COL(.SCHEMA,3,"owner","Owner","text",150,0,1)
	DO COL(.SCHEMA,4,"priority","Priority","text",110,0,1)
	DO COL(.SCHEMA,5,"updated","Updated","date",150,0,1)
	DO ROW(.ROWS,1,"Audit backlog","Open","MIOOS","High","2026-05-01","Security and audit work items")
	DO ROW(.ROWS,2,"Explorer grid","Done","Shell","Medium","2026-04-30","Resizable table source inspiration")
	DO ROW(.ROWS,3,"Transfer manager","Open","VFS","High","2026-04-28","Upload and download transfer controls")
	DO ROW(.ROWS,4,"Theme studio","Review","UI","Medium","2026-04-27","Customization and wallpaper persistence")
	QUIT
	;
COL(SCHEMA,N,KEY,LABEL,TYPE,WIDTH,HIDDEN,SORTABLE)
	SET SCHEMA("columns",N,"key")=KEY
	SET SCHEMA("columns",N,"label")=LABEL
	SET SCHEMA("columns",N,"type")=TYPE
	SET SCHEMA("columns",N,"width")=+WIDTH
	SET SCHEMA("columns",N,"hidden")=+HIDDEN
	SET SCHEMA("columns",N,"sortable")=+SORTABLE
	SET SCHEMA("columns",N,"resizable")=1
	QUIT
	;
ROW(ROWS,N,NAME,STATUS,OWNER,PRIORITY,UPDATED,BODY)
	SET ROWS(N,"id")="demo-"_N
	SET ROWS(N,"name")=NAME
	SET ROWS(N,"status")=STATUS
	SET ROWS(N,"owner")=OWNER
	SET ROWS(N,"priority")=PRIORITY
	SET ROWS(N,"updated")=UPDATED
	SET ROWS(N,"_expand","title")="Notes"
	SET ROWS(N,"_expand","body")=BODY
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
	IF DIR="descending" QUIT A]B
	QUIT B]A
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
	NEW START,END,I,N,ROW
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
	SET OUT("rowActions",1,"key")="open",OUT("rowActions",1,"label")="Open"
	SET OUT("rowActions",2,"key")="edit",OUT("rowActions",2,"label")="Edit"
	SET OUT("rowActions",3,"key")="delete",OUT("rowActions",3,"label")="Delete"
	SET OUT("bulkActions",1,"key")="export",OUT("bulkActions",1,"label")="Export selected"
	SET OUT("bulkActions",2,"key")="archive",OUT("bulkActions",2,"label")="Archive selected"
	QUIT
