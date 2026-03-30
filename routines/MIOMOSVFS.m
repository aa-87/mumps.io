MIOMOSVFS ; MIOMOS virtual filesystem helpers
	QUIT
	;
ENSURE(PRINCIPAL,USERNAME)
	IF $GET(PRINCIPAL)="" QUIT:$Q 0 Q
	IF +$GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"meta","seeded"))=1 QUIT:$Q 1 Q
	DO SEED(PRINCIPAL,$GET(USERNAME))
	QUIT:$Q 1 Q
	;
SEED(PRINCIPAL,USERNAME)
	NEW ROOT,NOW
	SET ROOT=$NAME(^MIO("MIOMOS","VFS","USER",PRINCIPAL))
	KILL @ROOT
	SET NOW=$$NOWISO^MIOUTIL()
	SET @ROOT@("meta","seeded")=1
	SET @ROOT@("meta","principal")=$GET(PRINCIPAL)
	SET @ROOT@("meta","userName")=$GET(USERNAME)
	SET @ROOT@("meta","createdAt")=NOW
	SET @ROOT@("meta","storage")="globals-only"
	SET @ROOT@("meta","ownership")="per-user"
	DO MKDIR(ROOT,"downloads","Downloads","my-documents",101,"DIR","Folder","Downloaded files staged for browser save actions.",0,1,0,NOW)
	DO MKDIR(ROOT,"uploads","Uploads","my-documents",102,"UPL","Folder","Incoming browser drops and picker uploads land here.",1,1,0,NOW)
	DO MKDIR(ROOT,"projects","Projects","my-documents",103,"PRJ","Folder","Personal work folders, snippets, and analyst artifacts.",1,1,0,NOW)
	DO MKDIR(ROOT,"routines","Routines","my-computer",111,"RTN","Folder","Virtual routine views and MUMPS development entry points.",0,1,0,NOW)
	DO MKDIR(ROOT,"globals-browser","Globals Browser","my-computer",112,"GBL","Folder","Read-only global structure snapshots for the desktop shell.",0,1,0,NOW)
	DO MKDIR(ROOT,"terminal-shortcuts","Terminal Shortcuts","my-computer",113,"CMD","Folder","Launch targets and shell shortcuts for operator workflows.",0,1,0,NOW)
	DO MKDIR(ROOT,"team-share","Team Share","my-network-places",121,"LAN","Folder","Shared collaboration artifacts and operator handoff files.",0,1,0,NOW)
	DO MKDIR(ROOT,"theme-packs","Theme Packs","ui-samples",131,"ART","Folder","XP shell samples, gradients, and chrome references.",1,1,0,NOW)
	DO MKFILE(ROOT,"welcome-note","Welcome Note.txt","my-documents",201,"TXT","Text","txt",2304,"text/plain","Globals-backed per-user storage begins here.",1,NOW)
	DO MKFILE(ROOT,"layout-state","Desktop Layout.json","my-documents",202,"JSN","Config","json",1792,"application/json","Saved window and desktop layout snapshots.",1,NOW)
	DO MKFILE(ROOT,"dropzone-readme","Browser Drop Readme.txt","uploads",211,"TXT","Text","txt",1536,"text/plain","ROI 168 will wire browser drop and picker upload into this virtual folder.",1,NOW)
	DO MKFILE(ROOT,"claims-export-sample","Claims Export.csv","downloads",212,"CSV","Data","csv",6144,"text/csv","Sample browser-download artifact staged from the VFS.",1,NOW)
	DO MKFILE(ROOT,"project-handbook","Project Handbook.md","projects",213,"DOC","Document","md",4096,"text/markdown","Developer notes for the XP shell roadmap.",1,NOW)
	DO MKFILE(ROOT,"routine-index","Routine Index.m","routines",221,"M","Routine","m",3584,"text/plain","Virtual routine manifest for the MUMPS development platform.",1,NOW)
	DO MKFILE(ROOT,"global-map","Global Map.gbl","globals-browser",222,"GBL","Snapshot","gbl",2688,"text/plain","Read-only global map exported into the shell VFS.",1,NOW)
	DO MKFILE(ROOT,"open-ydb","Open YDB.cmd","terminal-shortcuts",223,"CMD","Shortcut","cmd",1024,"text/plain","Launch the standard YottaDB terminal surface.",1,NOW)
	DO MKFILE(ROOT,"team-status","Team Status.url","team-share",231,"URL","Link","url",640,"text/uri-list","Shared collaboration status shortcut.",1,NOW)
	DO MKFILE(ROOT,"xp-shell-notes","XP Shell Notes.md","theme-packs",241,"ART","Document","md",3328,"text/markdown","Notes for shell chrome, icon, and explorer fidelity.",1,NOW)
	QUIT
	;
MKDIR(ROOT,KEY,TITLE,PARENT,ORD,ICON,BADGE,SUMMARY,UPLOAD,DOWNLOAD,DRAGOUT,MODIFIED)
	SET @ROOT@("dir",KEY,"key")=$GET(KEY)
	SET @ROOT@("dir",KEY,"title")=$GET(TITLE)
	SET @ROOT@("dir",KEY,"parentKey")=$GET(PARENT)
	SET @ROOT@("dir",KEY,"order")=+$GET(ORD)
	SET @ROOT@("dir",KEY,"icon")=$GET(ICON)
	SET @ROOT@("dir",KEY,"badge")=$GET(BADGE)
	SET @ROOT@("dir",KEY,"summary")=$GET(SUMMARY)
	SET @ROOT@("dir",KEY,"path")=$$PATH(KEY,ROOT)
	SET @ROOT@("dir",KEY,"kind")="directory"
	SET @ROOT@("dir",KEY,"vfsEntry")=1
	SET @ROOT@("dir",KEY,"uploadAllowed")=+$GET(UPLOAD)
	SET @ROOT@("dir",KEY,"downloadAllowed")=+$GET(DOWNLOAD)
	SET @ROOT@("dir",KEY,"dragOutAllowed")=+$GET(DRAGOUT)
	SET @ROOT@("dir",KEY,"modifiedAt")=$GET(MODIFIED)
	QUIT
	;
MKFILE(ROOT,KEY,TITLE,PARENT,ORD,ICON,BADGE,EXT,SIZE,MIME,SUMMARY,DOWNLOAD,MODIFIED)
	SET @ROOT@("file",KEY,"key")=$GET(KEY)
	SET @ROOT@("file",KEY,"title")=$GET(TITLE)
	SET @ROOT@("file",KEY,"parentKey")=$GET(PARENT)
	SET @ROOT@("file",KEY,"order")=+$GET(ORD)
	SET @ROOT@("file",KEY,"icon")=$GET(ICON)
	SET @ROOT@("file",KEY,"badge")=$GET(BADGE)
	SET @ROOT@("file",KEY,"extension")=$GET(EXT)
	SET @ROOT@("file",KEY,"sizeBytes")=+$GET(SIZE)
	SET @ROOT@("file",KEY,"sizeLabel")=$$SIZELBL(+$GET(SIZE))
	SET @ROOT@("file",KEY,"mime")=$GET(MIME)
	SET @ROOT@("file",KEY,"summary")=$GET(SUMMARY)
	SET @ROOT@("file",KEY,"kind")="file"
	SET @ROOT@("file",KEY,"vfsEntry")=1
	SET @ROOT@("file",KEY,"downloadAllowed")=+$GET(DOWNLOAD)
	SET @ROOT@("file",KEY,"dragOutAllowed")=0
	SET @ROOT@("file",KEY,"modifiedAt")=$GET(MODIFIED)
	QUIT
	;
PATH(KEY,ROOT)
	NEW TITLE,PARENT
	SET TITLE=$GET(@ROOT@("dir",KEY,"title"),$GET(@ROOT@("file",KEY,"title"),$GET(KEY)))
	SET PARENT=$GET(@ROOT@("dir",KEY,"parentKey"),$GET(@ROOT@("file",KEY,"parentKey"),""))
	IF PARENT="" QUIT "Desktop\\"_TITLE
	IF PARENT="my-documents" QUIT "Desktop\\My Documents\\"_TITLE
	IF PARENT="my-computer" QUIT "Desktop\\My Computer\\"_TITLE
	IF PARENT="my-network-places" QUIT "Desktop\\My Network Places\\"_TITLE
	IF PARENT="ui-samples" QUIT "Desktop\\UI Samples\\"_TITLE
	IF PARENT="downloads" QUIT "Desktop\\My Documents\\Downloads\\"_TITLE
	IF PARENT="uploads" QUIT "Desktop\\My Documents\\Uploads\\"_TITLE
	IF PARENT="projects" QUIT "Desktop\\My Documents\\Projects\\"_TITLE
	IF PARENT="routines" QUIT "Desktop\\My Computer\\Routines\\"_TITLE
	IF PARENT="globals-browser" QUIT "Desktop\\My Computer\\Globals Browser\\"_TITLE
	IF PARENT="terminal-shortcuts" QUIT "Desktop\\My Computer\\Terminal Shortcuts\\"_TITLE
	IF PARENT="team-share" QUIT "Desktop\\My Network Places\\Team Share\\"_TITLE
	IF PARENT="theme-packs" QUIT "Desktop\\UI Samples\\Theme Packs\\"_TITLE
	QUIT "Desktop\\"_TITLE
	;
SIZELBL(BYTES)
	NEW N
	SET N=+$GET(BYTES)
	IF N<1024 QUIT N_" B"
	IF N<1048576 QUIT $JUSTIFY(N/1024,0,1)_" KB"
	QUIT $JUSTIFY(N/1048576,0,1)_" MB"
	;
BOOT(PRINCIPAL,CONF,ROOT)
	NEW SUM
	KILL @ROOT
	DO ENSURE($GET(PRINCIPAL),"")
	DO SUMMARY(PRINCIPAL,.SUM)
	SET @ROOT@("enabled")=+$GET(CONF("miomos","vfs","enabled"),1)
	SET @ROOT@("storage")=$GET(CONF("miomos","vfs","storage"),"globals-only")
	SET @ROOT@("ownership")=$GET(CONF("miomos","vfs","ownership"),"per-user")
	SET @ROOT@("uploadModel")=$GET(CONF("miomos","vfs","uploadModel"),"browser-drop-or-picker")
	SET @ROOT@("downloadModel")=$GET(CONF("miomos","vfs","downloadModel"),"browser-save")
	SET @ROOT@("dragOutModel")=$GET(CONF("miomos","vfs","dragOutModel"),"permission-gated-progressive-enhancement")
	SET @ROOT@("permissionModel")="directory-flags"
	SET @ROOT@("summary","totalFiles")=+$GET(SUM("totalFiles"))
	SET @ROOT@("summary","totalDirectories")=+$GET(SUM("totalDirectories"))
	SET @ROOT@("summary","totalBytes")=+$GET(SUM("totalBytes"))
	SET @ROOT@("summary","sizeLabel")=$$SIZELBL(+$GET(SUM("totalBytes")))
	DO ROOTS(PRINCIPAL,ROOT)
	SET @ROOT@("roadmap",1,"roi")=168,@ROOT@("roadmap",1,"title")="Browser drop and picker upload",@ROOT@("roadmap",1,"copy")="Upload files into the VFS from desktop drop targets and file pickers without touching local disk on the server."
	SET @ROOT@("roadmap",2,"roi")=169,@ROOT@("roadmap",2,"title")="Browser download and drag-out bridge",@ROOT@("roadmap",2,"copy")="Download VFS artifacts back to the browser with explicit permission-aware save flows and drag-out where the browser permits it."
	QUIT
	;
VIEW(PRINCIPAL,CONF,ROOT)
	NEW SUM,N,KEY
	KILL @ROOT
	DO BOOT($GET(PRINCIPAL),.CONF,ROOT)
	SET N=0
	SET KEY=""
	FOR  SET KEY=$ORDER(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY)) QUIT:KEY=""  DO
	. SET N=N+1
	. DO PUTDIR(PRINCIPAL,KEY,ROOT,N)
	SET KEY=""
	FOR  SET KEY=$ORDER(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY)) QUIT:KEY=""  DO
	. SET N=N+1
	. DO PUTFILE(PRINCIPAL,KEY,ROOT,N)
	SET @ROOT@("entryCount")=N
	QUIT
	;
ROOTS(PRINCIPAL,ROOT)
	SET @ROOT@("roots",1,"key")="my-documents",@ROOT@("roots",1,"label")="My Documents",@ROOT@("roots",1,"uploadAllowed")=1,@ROOT@("roots",1,"downloadAllowed")=1,@ROOT@("roots",1,"dragOutAllowed")=0,@ROOT@("roots",1,"copy")="Primary per-user document root backed by MUMPS globals."
	SET @ROOT@("roots",2,"key")="my-computer",@ROOT@("roots",2,"label")="My Computer",@ROOT@("roots",2,"uploadAllowed")=0,@ROOT@("roots",2,"downloadAllowed")=1,@ROOT@("roots",2,"dragOutAllowed")=0,@ROOT@("roots",2,"copy")="Development-oriented virtual drives for routines, globals, and terminal shortcuts."
	SET @ROOT@("roots",3,"key")="my-network-places",@ROOT@("roots",3,"label")="My Network Places",@ROOT@("roots",3,"uploadAllowed")=0,@ROOT@("roots",3,"downloadAllowed")=1,@ROOT@("roots",3,"dragOutAllowed")=0,@ROOT@("roots",3,"copy")="Shared collaboration surfaces and virtual links."
	SET @ROOT@("roots",4,"key")="ui-samples",@ROOT@("roots",4,"label")="UI Samples",@ROOT@("roots",4,"uploadAllowed")=1,@ROOT@("roots",4,"downloadAllowed")=1,@ROOT@("roots",4,"dragOutAllowed")=0,@ROOT@("roots",4,"copy")="Theme packs and shell chrome examples stored in globals."
	QUIT
	;
PUTDIR(PRINCIPAL,KEY,ROOT,N)
	NEW BASE
	SET BASE=$NAME(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY))
	SET @ROOT@("entries",N,"key")=$GET(@BASE@("key"))
	SET @ROOT@("entries",N,"title")=$GET(@BASE@("title"))
	SET @ROOT@("entries",N,"parentKey")=$GET(@BASE@("parentKey"))
	SET @ROOT@("entries",N,"order")=+$GET(@BASE@("order"))
	SET @ROOT@("entries",N,"icon")=$GET(@BASE@("icon"))
	SET @ROOT@("entries",N,"badge")=$GET(@BASE@("badge"))
	SET @ROOT@("entries",N,"summary")=$GET(@BASE@("summary"))
	SET @ROOT@("entries",N,"path")=$GET(@BASE@("path"))
	SET @ROOT@("entries",N,"kind")="directory"
	SET @ROOT@("entries",N,"vfsEntry")=1
	SET @ROOT@("entries",N,"uploadAllowed")=+$GET(@BASE@("uploadAllowed"))
	SET @ROOT@("entries",N,"downloadAllowed")=+$GET(@BASE@("downloadAllowed"))
	SET @ROOT@("entries",N,"dragOutAllowed")=+$GET(@BASE@("dragOutAllowed"))
	SET @ROOT@("entries",N,"modifiedAt")=$GET(@BASE@("modifiedAt"))
	QUIT
	;
PUTFILE(PRINCIPAL,KEY,ROOT,N)
	NEW BASE
	SET BASE=$NAME(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY))
	SET @ROOT@("entries",N,"key")=$GET(@BASE@("key"))
	SET @ROOT@("entries",N,"title")=$GET(@BASE@("title"))
	SET @ROOT@("entries",N,"parentKey")=$GET(@BASE@("parentKey"))
	SET @ROOT@("entries",N,"order")=+$GET(@BASE@("order"))
	SET @ROOT@("entries",N,"icon")=$GET(@BASE@("icon"))
	SET @ROOT@("entries",N,"badge")=$GET(@BASE@("badge"))
	SET @ROOT@("entries",N,"summary")=$GET(@BASE@("summary"))
	SET @ROOT@("entries",N,"path")=$GET(@BASE@("path"))
	SET @ROOT@("entries",N,"kind")="file"
	SET @ROOT@("entries",N,"vfsEntry")=1
	SET @ROOT@("entries",N,"extension")=$GET(@BASE@("extension"))
	SET @ROOT@("entries",N,"sizeBytes")=+$GET(@BASE@("sizeBytes"))
	SET @ROOT@("entries",N,"sizeLabel")=$GET(@BASE@("sizeLabel"))
	SET @ROOT@("entries",N,"mime")=$GET(@BASE@("mime"))
	SET @ROOT@("entries",N,"downloadAllowed")=+$GET(@BASE@("downloadAllowed"))
	SET @ROOT@("entries",N,"dragOutAllowed")=+$GET(@BASE@("dragOutAllowed"))
	SET @ROOT@("entries",N,"modifiedAt")=$GET(@BASE@("modifiedAt"))
	QUIT
	;
SUMMARY(PRINCIPAL,OUT)
	NEW KEY
	KILL OUT
	SET KEY=""
	FOR  SET KEY=$ORDER(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY)) QUIT:KEY=""  SET OUT("totalDirectories")=+$GET(OUT("totalDirectories"))+1
	SET KEY=""
	FOR  SET KEY=$ORDER(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY)) QUIT:KEY=""  DO
	. SET OUT("totalFiles")=+$GET(OUT("totalFiles"))+1
	. SET OUT("totalBytes")=+$GET(OUT("totalBytes"))+$GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY,"sizeBytes"))
	QUIT
	;
	;
UPLOAD(PRINCIPAL,PARENTKEY,PARENTTITLE,FILENAME,MIME,REF,OUT,ERR)
	NEW ROOT,SAFE,EXT,KEY,SIZE,I,NODE,ORDER,TITLE
	KILL OUT
	SET PRINCIPAL=$GET(PRINCIPAL)
	IF PRINCIPAL="" SET ERR("routine")="MIOMOSVFS",ERR("error")="principal_missing",ERR("status")=401 QUIT 0
	DO ENSURE(PRINCIPAL,"")
	SET ROOT=$NAME(^MIO("MIOMOS","VFS","USER",PRINCIPAL))
	SET PARENTKEY=$GET(PARENTKEY)
	SET PARENTTITLE=$GET(PARENTTITLE)
	IF '$$ENSUREPARENT(PRINCIPAL,PARENTKEY,PARENTTITLE,.ERR) QUIT 0
	IF '$$DIRUPLOADOK(PRINCIPAL,PARENTKEY) SET ERR("routine")="MIOMOSVFS",ERR("error")="upload_forbidden",ERR("detail")=PARENTKEY,ERR("status")=403 QUIT 0
	SET SAFE=$$SAFENAME($GET(FILENAME))
	IF SAFE="" SET SAFE="Upload.bin"
	SET TITLE=SAFE
	SET EXT=$$EXT(SAFE)
	SET KEY="file-"_$TR($$UUID^MIOUTIL(),"-","")
	SET ORDER=$$NEXTORD(PRINCIPAL,PARENTKEY)
	SET SIZE=0
	SET @ROOT@("file",KEY,"key")=KEY
	SET @ROOT@("file",KEY,"title")=TITLE
	SET @ROOT@("file",KEY,"parentKey")=PARENTKEY
	SET @ROOT@("file",KEY,"order")=ORDER
	SET @ROOT@("file",KEY,"icon")=$$ICON(EXT,$GET(MIME))
	SET @ROOT@("file",KEY,"badge")=$$BADGE(EXT,$GET(MIME))
	SET @ROOT@("file",KEY,"extension")=EXT
	SET @ROOT@("file",KEY,"mime")=$GET(MIME,"application/octet-stream")
	SET @ROOT@("file",KEY,"summary")="Uploaded from browser into virtual storage."
	SET @ROOT@("file",KEY,"kind")="file"
	SET @ROOT@("file",KEY,"vfsEntry")=1
	SET @ROOT@("file",KEY,"downloadAllowed")=1
	SET @ROOT@("file",KEY,"dragOutAllowed")=0
	SET @ROOT@("file",KEY,"modifiedAt")="Today"
	SET I=0,NODE=0
	FOR  SET I=$ORDER(@REF@(I)) QUIT:'I  DO
	. SET NODE=NODE+1
	. SET @ROOT@("blob",KEY,NODE)=$GET(@REF@(I))
	. SET SIZE=SIZE+$L($GET(@REF@(I)))
	SET @ROOT@("file",KEY,"sizeBytes")=SIZE
	SET @ROOT@("file",KEY,"sizeLabel")=$$SIZELBL(SIZE)
	SET @ROOT@("file",KEY,"path")=$$PATH(KEY,ROOT)
	DO GETFILE(PRINCIPAL,KEY,$NAME(OUT("entry")))
	QUIT 1
	;
ENSUREPARENT(PRINCIPAL,PARENTKEY,PARENTTITLE,ERR)
	NEW ROOT
	SET ROOT=$NAME(^MIO("MIOMOS","VFS","USER",PRINCIPAL))
	IF $DATA(@ROOT@("dir",PARENTKEY)) QUIT 1
	IF $EXTRACT($GET(PARENTKEY),1,7)="folder-" DO  QUIT 1
	. DO MKDIR(ROOT,PARENTKEY,$SELECT($GET(PARENTTITLE)'="":PARENTTITLE,1:"Folder"),"",900+$$COUNTDIR(PRINCIPAL),"DIR","Folder","Desktop folder backed by virtual storage.",1,1,0,"Today")
	SET ERR("routine")="MIOMOSVFS",ERR("error")="parent_missing",ERR("detail")=$GET(PARENTKEY),ERR("status")=404
	QUIT 0
	;
DIRUPLOADOK(PRINCIPAL,PARENTKEY)
	IF $EXTRACT($GET(PARENTKEY),1,7)="folder-" QUIT 1
	QUIT +$GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",PARENTKEY,"uploadAllowed"))
	;
COUNTDIR(PRINCIPAL)
	NEW N,KEY SET N=0,KEY=""
	FOR  SET KEY=$ORDER(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY)) QUIT:KEY=""  SET N=N+1
	QUIT N
	;
NEXTORD(PRINCIPAL,PARENTKEY)
	NEW MAX,KEY
	SET MAX=0,KEY=""
	FOR  SET KEY=$ORDER(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY)) QUIT:KEY=""  DO
	. IF $GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY,"parentKey"))=$GET(PARENTKEY) SET MAX=$SELECT(+$GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY,"order"))>MAX:+$GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY,"order")),1:MAX)
	FOR  SET KEY=$ORDER(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY)) QUIT:KEY=""  DO
	. IF $GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY,"parentKey"))=$GET(PARENTKEY) SET MAX=$SELECT(+$GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY,"order"))>MAX:+$GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY,"order")),1:MAX)
	QUIT MAX+1
	;
SAFENAME(NAME)
	NEW X,I,C,OUT
	SET X=$PIECE($GET(NAME),"/",$L($GET(NAME),"/"))
	SET X=$PIECE(X,"\",$L(X,"\"))
	SET OUT=""
	FOR I=1:1:$L(X) SET C=$E(X,I) DO
	. IF $A(C)<32 QUIT
	. IF C=":"!(C="*")!(C="?")!(C="""")!(C="<")!(C=">")!(C="|") QUIT
	. SET OUT=OUT_C
	QUIT OUT
	;
EXT(NAME)
	NEW X,P
	SET X=$GET(NAME)
	IF X'["." QUIT ""
	SET P=$PIECE(X,".",$L(X,"."))
	QUIT $ZCONVERT(P,"L")
	;
ICON(EXT,MIME)
	IF $GET(MIME)["text/plain" QUIT "TXT"
	IF $GET(MIME)["json" QUIT "JSN"
	IF $GET(MIME)["csv" QUIT "CSV"
	IF $GET(EXT)'="" QUIT $EXTRACT($ZCONVERT(EXT,"U")_"DOC",1,3)
	QUIT "DOC"
	;
BADGE(EXT,MIME)
	IF $GET(MIME)["text/plain" QUIT "Text"
	IF $GET(MIME)["json" QUIT "Config"
	IF $GET(MIME)["csv" QUIT "Data"
	IF $GET(EXT)="md" QUIT "Document"
	QUIT "File"
	;
GETFILE(PRINCIPAL,KEY,ROOT)
	NEW BASE
	KILL @ROOT
	SET BASE=$NAME(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY))
	SET @ROOT@("key")=$GET(@BASE@("key"))
	SET @ROOT@("title")=$GET(@BASE@("title"))
	SET @ROOT@("parentKey")=$GET(@BASE@("parentKey"))
	SET @ROOT@("order")=+$GET(@BASE@("order"))
	SET @ROOT@("icon")=$GET(@BASE@("icon"))
	SET @ROOT@("badge")=$GET(@BASE@("badge"))
	SET @ROOT@("summary")=$GET(@BASE@("summary"))
	SET @ROOT@("path")=$GET(@BASE@("path"))
	SET @ROOT@("kind")="file"
	SET @ROOT@("vfsEntry")=1
	SET @ROOT@("extension")=$GET(@BASE@("extension"))
	SET @ROOT@("sizeBytes")=+$GET(@BASE@("sizeBytes"))
	SET @ROOT@("sizeLabel")=$GET(@BASE@("sizeLabel"))
	SET @ROOT@("mime")=$GET(@BASE@("mime"))
	SET @ROOT@("downloadAllowed")=+$GET(@BASE@("downloadAllowed"))
	SET @ROOT@("dragOutAllowed")=+$GET(@BASE@("dragOutAllowed"))
	SET @ROOT@("modifiedAt")=$GET(@BASE@("modifiedAt"))
	QUIT
	;
	;