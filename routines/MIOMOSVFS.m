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
	SET @ROOT@("meta","platformProfile")="xp-replica-mumps-development"
	DO MKDIR(ROOT,"downloads","Downloads","my-documents",101,"DIR","Folder","Downloaded files staged for browser save actions.",0,1,1,NOW,1)
	DO MKDIR(ROOT,"uploads","Uploads","my-documents",102,"UPL","Folder","Incoming browser drops and picker uploads land here.",1,1,0,NOW,1)
	DO MKDIR(ROOT,"projects","Projects","my-documents",103,"PRJ","Folder","Personal work folders, snippets, and analyst artifacts.",1,1,0,NOW,1)
	DO MKDIR(ROOT,"routines","Routines","my-computer",111,"RTN","Folder","Virtual routine views and MUMPS development entry points.",0,1,0,NOW,1)
	DO MKDIR(ROOT,"globals-browser","Globals Browser","my-computer",112,"GBL","Folder","Read-only global structure snapshots for the desktop shell.",0,1,0,NOW,1)
	DO MKDIR(ROOT,"terminal-shortcuts","Terminal Shortcuts","my-computer",113,"CMD","Folder","Launch targets and shell shortcuts for operator workflows.",0,1,0,NOW,1)
	DO MKDIR(ROOT,"team-share","Team Share","my-network-places",121,"LAN","Folder","Shared collaboration artifacts and operator handoff files.",0,1,0,NOW,1)
	DO MKDIR(ROOT,"theme-packs","Theme Packs","ui-samples",131,"ART","Folder","XP shell samples, gradients, and chrome references.",1,1,0,NOW,1)
	DO MKFILE(ROOT,"welcome-note","Welcome Note.txt","my-documents",201,"TXT","Text","txt",0,"text/plain","Globals-backed per-user storage begins here.",1,NOW)
	DO SEEDBLOB(ROOT,"welcome-note","Welcome to MIOMOS. This per-user file lives entirely in globals and never touches server disk.")
	DO MKFILE(ROOT,"layout-state","Desktop Layout.json","my-documents",202,"JSN","Config","json",0,"application/json","Saved window and desktop layout snapshots.",1,NOW)
	DO SEEDBLOB(ROOT,"layout-state","{""layout"":{""windows"":[]},""source"":""seed""}")
	DO MKFILE(ROOT,"dropzone-readme","Browser Drop Readme.txt","uploads",211,"TXT","Text","txt",0,"text/plain","Browser drops and picker uploads land in this folder.",1,NOW)
	DO SEEDBLOB(ROOT,"dropzone-readme","Drop files here from the browser to store them in globals-backed per-user virtual storage.")
	DO MKFILE(ROOT,"claims-export-sample","Claims Export.csv","downloads",212,"CSV","Data","csv",0,"text/csv","Sample browser-download artifact staged from the VFS.",1,NOW)
	DO SEEDBLOB(ROOT,"claims-export-sample","claim_id,status"_$CHAR(10)_"837P-24081,Ready")
	DO MKFILE(ROOT,"project-handbook","Project Handbook.md","projects",213,"DOC","Document","md",0,"text/markdown","Developer notes for the XP shell roadmap.",1,NOW)
	DO SEEDBLOB(ROOT,"project-handbook","# MIOMOS"_$CHAR(10)_"This virtual file system is the backbone of the XP-style MUMPS development shell.")
	DO MKFILE(ROOT,"routine-index","Routine Index.m","routines",221,"M","Routine","m",0,"text/plain","Virtual routine manifest for the MUMPS development platform.",1,NOW)
	DO SEEDBLOB(ROOT,"routine-index","ROUTINES ; Seeded example"_$CHAR(10)_" WRITE ""MIOMOS"",!")
	DO MKFILE(ROOT,"global-map","Global Map.gbl","globals-browser",222,"GBL","Snapshot","gbl",0,"text/plain","Read-only global map exported into the shell VFS.",1,NOW)
	DO SEEDBLOB(ROOT,"global-map","^MIO(""MIOMOS"")")
	DO MKFILE(ROOT,"open-ydb","Open YDB.cmd","terminal-shortcuts",223,"CMD","Shortcut","cmd",0,"text/plain","Launch the standard YottaDB terminal surface.",1,NOW)
	DO SEEDBLOB(ROOT,"open-ydb","terminal.open")
	DO MKFILE(ROOT,"team-status","Team Status.url","team-share",231,"URL","Link","url",0,"text/uri-list","Shared collaboration status shortcut.",1,NOW)
	DO SEEDBLOB(ROOT,"team-status","https://localhost/miomos")
	DO MKFILE(ROOT,"xp-shell-notes","XP Shell Notes.md","theme-packs",241,"ART","Document","md",0,"text/markdown","Notes for shell chrome, icon, and explorer fidelity.",1,NOW)
	DO SEEDBLOB(ROOT,"xp-shell-notes","The shell should feel like a polished Windows XP development workstation built for MUMPS work.")
	QUIT
	;
SEEDBLOB(ROOT,KEY,TEXT)
	NEW PART,SIZE
	KILL @ROOT@("blob",KEY)
	SET PART=$GET(TEXT)
	SET @ROOT@("blob",KEY,1)=PART
	SET SIZE=$L(PART)
	SET @ROOT@("file",KEY,"sizeBytes")=SIZE
	SET @ROOT@("file",KEY,"sizeLabel")=$$SIZELBL(SIZE)
	QUIT
	;
MKDIR(ROOT,KEY,TITLE,PARENT,ORD,ICON,BADGE,SUMMARY,UPLOAD,DOWNLOAD,DRAGOUT,MODIFIED,SYSTEMOWNED)
	SET @ROOT@("dir",KEY,"key")=$GET(KEY)
	SET @ROOT@("dir",KEY,"title")=$GET(TITLE)
	SET @ROOT@("dir",KEY,"parentKey")=$GET(PARENT)
	SET @ROOT@("dir",KEY,"order")=+$GET(ORD)
	SET @ROOT@("dir",KEY,"icon")=$GET(ICON)
	SET @ROOT@("dir",KEY,"badge")=$GET(BADGE)
	SET @ROOT@("dir",KEY,"summary")=$GET(SUMMARY)
	SET @ROOT@("dir",KEY,"kind")="directory"
	SET @ROOT@("dir",KEY,"vfsEntry")=1
	SET @ROOT@("dir",KEY,"uploadAllowed")=+$GET(UPLOAD)
	SET @ROOT@("dir",KEY,"downloadAllowed")=+$GET(DOWNLOAD)
	SET @ROOT@("dir",KEY,"dragOutAllowed")=+$GET(DRAGOUT)
	SET @ROOT@("dir",KEY,"modifiedAt")=$GET(MODIFIED)
	SET @ROOT@("dir",KEY,"systemOwned")=+$GET(SYSTEMOWNED)
	SET @ROOT@("dir",KEY,"path")=$$PATH(KEY,ROOT)
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
	SET @ROOT@("file",KEY,"dragOutAllowed")=+$GET(DOWNLOAD)
	SET @ROOT@("file",KEY,"modifiedAt")=$GET(MODIFIED)
	SET @ROOT@("file",KEY,"path")=$$PATH(KEY,ROOT)
	QUIT
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
	SET @ROOT@("permissionModel")="directory-flags-and-per-user-globals"
	SET @ROOT@("platformRole")="xp-replica-mumps-development-environment"
	SET @ROOT@("summary","totalFiles")=+$GET(SUM("totalFiles"))
	SET @ROOT@("summary","totalDirectories")=+$GET(SUM("totalDirectories"))
	SET @ROOT@("summary","totalBytes")=+$GET(SUM("totalBytes"))
	SET @ROOT@("summary","sizeLabel")=$$SIZELBL(+$GET(SUM("totalBytes")))
	DO ROOTS(PRINCIPAL,ROOT)
	DO LISTALL(PRINCIPAL,ROOT)
	SET @ROOT@("roadmap",1,"roi")=64,@ROOT@("roadmap",1,"title")="Globals-backed VFS transfer hardening",@ROOT@("roadmap",1,"copy")="Complete the upload, download, recycle, rename, move, and restore contract over per-user globals with detailed tests."
	SET @ROOT@("roadmap",2,"roi")=65,@ROOT@("roadmap",2,"title")="MUMPS-first file type workflows",@ROOT@("roadmap",2,"copy")="Promote text, JSON, CSV, M routine, and globals-snapshot files into first-class shell experiences."
	SET @ROOT@("roadmap",3,"roi")=66,@ROOT@("roadmap",3,"title")="Debugger foundation",@ROOT@("roadmap",3,"copy")="Add a server-authored debugger contract for routines, breakpoints, call stack, and watch surfaces."
	QUIT
	;
VIEW(PRINCIPAL,CONF,ROOT)
	DO BOOT($GET(PRINCIPAL),.CONF,ROOT)
	QUIT
	;
CATALOG(PRINCIPAL,CONF,ROOT)
	DO VIEW($GET(PRINCIPAL),.CONF,ROOT)
	QUIT
	;
LISTALL(PRINCIPAL,ROOT)
	NEW N,KEY
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
	SET @ROOT@("roots",5,"key")="recycle-bin",@ROOT@("roots",5,"label")="Recycle Bin",@ROOT@("roots",5,"uploadAllowed")=0,@ROOT@("roots",5,"downloadAllowed")=1,@ROOT@("roots",5,"dragOutAllowed")=0,@ROOT@("roots",5,"copy")="Soft-deleted per-user VFS entries can be restored or permanently removed here."
	QUIT
	;
PUTDIR(PRINCIPAL,KEY,ROOT,N)
	DO COPYDIR(PRINCIPAL,KEY,$NAME(@ROOT@("entries",N)))
	QUIT
	;
PUTFILE(PRINCIPAL,KEY,ROOT,N)
	DO COPYFILE(PRINCIPAL,KEY,$NAME(@ROOT@("entries",N)))
	QUIT
	;
COPYDIR(PRINCIPAL,KEY,ROOT)
	NEW BASE,STOREROOT
	KILL @ROOT
	SET BASE=$NAME(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY))
	IF '$DATA(@BASE) QUIT
	MERGE @ROOT=@BASE
	SET STOREROOT=$NAME(^MIO("MIOMOS","VFS","USER",PRINCIPAL))
	SET @ROOT@("kind")="directory"
	SET @ROOT@("vfsEntry")=1
	SET @ROOT@("path")=$$PATH(KEY,STOREROOT)
	QUIT
	;
COPYFILE(PRINCIPAL,KEY,ROOT)
	NEW BASE,STOREROOT
	KILL @ROOT
	SET BASE=$NAME(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY))
	IF '$DATA(@BASE) QUIT
	MERGE @ROOT=@BASE
	SET STOREROOT=$NAME(^MIO("MIOMOS","VFS","USER",PRINCIPAL))
	SET @ROOT@("kind")="file"
	SET @ROOT@("vfsEntry")=1
	SET @ROOT@("path")=$$PATH(KEY,STOREROOT)
	QUIT
	;
GETDIR(PRINCIPAL,KEY,ROOT)
	DO COPYDIR(PRINCIPAL,KEY,ROOT)
	QUIT
	;
GETFILE(PRINCIPAL,KEY,ROOT)
	DO COPYFILE(PRINCIPAL,KEY,ROOT)
	QUIT
	;
GETENTRY(PRINCIPAL,KEY,ROOT)
	NEW KIND
	SET KIND=$$ENTRYKIND(PRINCIPAL,KEY)
	IF KIND="directory" DO GETDIR(PRINCIPAL,KEY,ROOT) QUIT
	IF KIND="file" DO GETFILE(PRINCIPAL,KEY,ROOT) QUIT
	KILL @ROOT
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
UPLOAD(PRINCIPAL,PARENTKEY,PARENTTITLE,FILENAME,MIME,REF,OUT,ERR)
	NEW ROOT,SAFE,EXTN,KEY,SIZE,I,NODE,ORDER,TITLE
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
	SET TITLE=$$UNIQUETITLE(PRINCIPAL,PARENTKEY,SAFE,"file","")
	SET EXTN=$$EXT(TITLE)
	SET KEY="file-"_$TR($$UUID^MIOUTIL(),"-","")
	SET ORDER=$$NEXTORD(PRINCIPAL,PARENTKEY)
	SET SIZE=0
	DO MKFILE(ROOT,KEY,TITLE,PARENTKEY,ORDER,$$ICON(EXTN,$GET(MIME)),$$BADGE(EXTN,$GET(MIME)),EXTN,0,$GET(MIME,"application/octet-stream"),"Uploaded from browser into virtual storage.",1,"Today")
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
DOWNLOAD(PRINCIPAL,KEY,OUT,ERR)
	NEW ROOT,I
	KILL OUT
	IF $GET(PRINCIPAL)="" SET ERR("routine")="MIOMOSVFS",ERR("error")="principal_missing",ERR("status")=401 QUIT 0
	SET ROOT=$NAME(^MIO("MIOMOS","VFS","USER",PRINCIPAL))
	IF '$DATA(@ROOT@("file",KEY)) SET ERR("routine")="MIOMOSVFS",ERR("error")="file_missing",ERR("detail")=$GET(KEY),ERR("status")=404 QUIT 0
	IF '+$GET(@ROOT@("file",KEY,"downloadAllowed")) SET ERR("routine")="MIOMOSVFS",ERR("error")="download_forbidden",ERR("detail")=$GET(KEY),ERR("status")=403 QUIT 0
	DO GETFILE(PRINCIPAL,KEY,$NAME(OUT("entry")))
	SET I=0
	FOR  SET I=$ORDER(@ROOT@("blob",KEY,I)) QUIT:'I  SET OUT("blob",I)=$GET(@ROOT@("blob",KEY,I))
	QUIT 1
	;
MKDIRCMD(PRINCIPAL,PARENTKEY,PARENTTITLE,TITLE,OUT,ERR)
	NEW ROOT,SAFE,KEY,ORDER
	KILL OUT
	IF $GET(PRINCIPAL)="" SET ERR("routine")="MIOMOSVFS",ERR("error")="principal_missing",ERR("status")=401 QUIT 0
	DO ENSURE(PRINCIPAL,"")
	IF '$$ENSUREPARENT(PRINCIPAL,$GET(PARENTKEY),$GET(PARENTTITLE),.ERR) QUIT 0
	SET ROOT=$NAME(^MIO("MIOMOS","VFS","USER",PRINCIPAL))
	SET SAFE=$$SAFENAME($GET(TITLE))
	IF SAFE="" SET SAFE="New Folder"
	SET SAFE=$$UNIQUETITLE(PRINCIPAL,$GET(PARENTKEY),SAFE,"directory","")
	SET KEY="dir-"_$TR($$UUID^MIOUTIL(),"-","")
	SET ORDER=$$NEXTORD(PRINCIPAL,$GET(PARENTKEY))
	DO MKDIR(ROOT,KEY,SAFE,$GET(PARENTKEY),ORDER,"DIR","Folder","Folder created in virtual storage.",1,1,0,"Today")
	DO GETDIR(PRINCIPAL,KEY,$NAME(OUT))
	QUIT 1
	;
RENAME(PRINCIPAL,KEY,TITLE,OUT,ERR)
	NEW KIND,BASE,PARENT,SAFE,EXTN
	KILL OUT
	SET KIND=$$ENTRYKIND(PRINCIPAL,$GET(KEY))
	IF KIND="" SET ERR("routine")="MIOMOSVFS",ERR("error")="entry_missing",ERR("detail")=$GET(KEY),ERR("status")=404 QUIT 0
	IF KIND="directory" DO
	. IF $$IMMUTABLEDIR(PRINCIPAL,$GET(KEY)) SET ERR("routine")="MIOMOSVFS",ERR("error")="system_entry_forbidden",ERR("detail")=$GET(KEY),ERR("status")=403
	IF $DATA(ERR) QUIT 0
	SET BASE=$$BASE(PRINCIPAL,$GET(KEY),KIND)
	SET PARENT=$GET(@BASE@("parentKey"))
	SET SAFE=$$SAFENAME($GET(TITLE))
	IF SAFE="" SET SAFE=$SELECT(KIND="directory":"New Folder",1:"New File")
	SET SAFE=$$UNIQUETITLE(PRINCIPAL,PARENT,SAFE,KIND,$GET(KEY))
	SET @BASE@("title")=SAFE
	SET @BASE@("modifiedAt")="Today"
	IF KIND="file" DO
	. SET EXTN=$$EXT(SAFE)
	. SET @BASE@("extension")=EXTN
	. SET @BASE@("icon")=$$ICON(EXTN,$GET(@BASE@("mime")))
	. SET @BASE@("badge")=$$BADGE(EXTN,$GET(@BASE@("mime")))
	DO REPATH(PRINCIPAL,$GET(KEY),KIND)
	DO GETENTRY(PRINCIPAL,$GET(KEY),$NAME(OUT))
	QUIT 1
	;
DELETE(PRINCIPAL,KEY,MODE,OUT,ERR)
	NEW KIND,BASE,PARENT,TTL
	KILL OUT
	SET KIND=$$ENTRYKIND(PRINCIPAL,$GET(KEY))
	IF KIND="" SET ERR("routine")="MIOMOSVFS",ERR("error")="entry_missing",ERR("detail")=$GET(KEY),ERR("status")=404 QUIT 0
	IF KIND="directory" DO
	. IF $$IMMUTABLEDIR(PRINCIPAL,$GET(KEY)) SET ERR("routine")="MIOMOSVFS",ERR("error")="system_entry_forbidden",ERR("detail")=$GET(KEY),ERR("status")=403
	IF $DATA(ERR) QUIT 0
	SET BASE=$$BASE(PRINCIPAL,$GET(KEY),KIND)
	IF $$LOW($GET(MODE))="permanent" DO  QUIT 1
	. DO PURGEENTRY(PRINCIPAL,$GET(KEY),KIND)
	. SET OUT("removed")=1,OUT("mode")="permanent",OUT("key")=$GET(KEY)
	SET PARENT=$GET(@BASE@("parentKey"))
	IF PARENT="recycle-bin" DO GETENTRY(PRINCIPAL,$GET(KEY),$NAME(OUT)) QUIT 1
	SET @BASE@("recycle","originalParentKey")=PARENT
	SET @BASE@("recycle","originalTitle")=$GET(@BASE@("title"))
	SET TTL=$$UNIQUETITLE(PRINCIPAL,"recycle-bin",$GET(@BASE@("title")),KIND,$GET(KEY))
	SET @BASE@("title")=TTL
	SET @BASE@("parentKey")="recycle-bin"
	SET @BASE@("modifiedAt")="Today"
	DO REPATH(PRINCIPAL,$GET(KEY),KIND)
	DO GETENTRY(PRINCIPAL,$GET(KEY),$NAME(OUT))
	QUIT 1
	;
MOVE(PRINCIPAL,KEY,TARGETPARENTKEY,OPERATION,OUT,ERR)
	NEW KIND,BASE,TITLE
	KILL OUT
	SET KIND=$$ENTRYKIND(PRINCIPAL,$GET(KEY))
	IF KIND="" SET ERR("routine")="MIOMOSVFS",ERR("error")="entry_missing",ERR("detail")=$GET(KEY),ERR("status")=404 QUIT 0
	IF $$LOW($GET(OPERATION,"move"))'="move" SET ERR("routine")="MIOMOSVFS",ERR("error")="operation_unsupported",ERR("detail")=$GET(OPERATION),ERR("status")=400 QUIT 0
	IF '$$ENSUREPARENT(PRINCIPAL,$GET(TARGETPARENTKEY),"",.ERR) QUIT 0
	IF KIND="directory",$$ISDESC(PRINCIPAL,$GET(KEY),$GET(TARGETPARENTKEY)) SET ERR("routine")="MIOMOSVFS",ERR("error")="invalid_move_target",ERR("detail")=$GET(TARGETPARENTKEY),ERR("status")=409 QUIT 0
	IF KIND="directory" DO
	. IF $$IMMUTABLEDIR(PRINCIPAL,$GET(KEY)) SET ERR("routine")="MIOMOSVFS",ERR("error")="system_entry_forbidden",ERR("detail")=$GET(KEY),ERR("status")=403
	IF $DATA(ERR) QUIT 0
	SET BASE=$$BASE(PRINCIPAL,$GET(KEY),KIND)
	IF $GET(@BASE@("parentKey"))=$GET(TARGETPARENTKEY) DO GETENTRY(PRINCIPAL,$GET(KEY),$NAME(OUT)) QUIT 1
	SET TITLE=$$UNIQUETITLE(PRINCIPAL,$GET(TARGETPARENTKEY),$GET(@BASE@("title")),KIND,$GET(KEY))
	SET @BASE@("title")=TITLE
	SET @BASE@("parentKey")=$GET(TARGETPARENTKEY)
	SET @BASE@("modifiedAt")="Today"
	DO REPATH(PRINCIPAL,$GET(KEY),KIND)
	DO GETENTRY(PRINCIPAL,$GET(KEY),$NAME(OUT))
	QUIT 1
	;
RESTORE(PRINCIPAL,KEY,OUT,ERR)
	NEW KIND,BASE,TARGET,TITLE
	KILL OUT
	SET KIND=$$ENTRYKIND(PRINCIPAL,$GET(KEY))
	IF KIND="" SET ERR("routine")="MIOMOSVFS",ERR("error")="entry_missing",ERR("detail")=$GET(KEY),ERR("status")=404 QUIT 0
	SET BASE=$$BASE(PRINCIPAL,$GET(KEY),KIND)
	SET TARGET=$GET(@BASE@("recycle","originalParentKey"),"my-documents")
	IF '$$TARGETOK(PRINCIPAL,TARGET) SET TARGET="my-documents"
	SET TITLE=$$UNIQUETITLE(PRINCIPAL,TARGET,$GET(@BASE@("recycle","originalTitle"),$GET(@BASE@("title"))),KIND,$GET(KEY))
	SET @BASE@("title")=TITLE
	SET @BASE@("parentKey")=TARGET
	KILL @BASE@("recycle")
	SET @BASE@("modifiedAt")="Today"
	DO REPATH(PRINCIPAL,$GET(KEY),KIND)
	DO GETENTRY(PRINCIPAL,$GET(KEY),$NAME(OUT))
	QUIT 1
	;
EMPTYBIN(PRINCIPAL,OUT,ERR)
	NEW KEY,REMOVED,N,FILES,DIRS
	KILL OUT
	SET (REMOVED,N)=0,KEY=""
	FOR  SET KEY=$ORDER(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY)) QUIT:KEY=""  DO
	. IF $GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY,"parentKey"))="recycle-bin" SET N=N+1,FILES(N)=KEY
	SET KEY=""
	FOR  SET KEY=$ORDER(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY)) QUIT:KEY=""  DO
	. IF $GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY,"parentKey"))="recycle-bin" SET N=N+1,DIRS(N)=KEY
	SET N=0
	FOR  SET N=$ORDER(FILES(N)) QUIT:'N  DO
	. DO PURGEENTRY(PRINCIPAL,FILES(N),"file")
	. SET REMOVED=REMOVED+1
	SET N=0
	FOR  SET N=$ORDER(DIRS(N)) QUIT:'N  DO
	. DO PURGEENTRY(PRINCIPAL,DIRS(N),"directory")
	. SET REMOVED=REMOVED+1
	SET OUT("emptied")=1
	SET OUT("removedCount")=REMOVED
	SET OUT("key")="recycle-bin"
	QUIT 1
	;
PURGEENTRY(PRINCIPAL,KEY,KIND)
	IF $GET(KIND)="" SET KIND=$$ENTRYKIND(PRINCIPAL,$GET(KEY))
	IF KIND="file" DO  QUIT
	. KILL ^MIO("MIOMOS","VFS","USER",PRINCIPAL,"blob",KEY)
	. KILL ^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY)
	IF KIND="directory" DO
	. DO PURGEDIR(PRINCIPAL,$GET(KEY))
	QUIT
	;
PURGEDIR(PRINCIPAL,DIRKEY)
	NEW KEY
	SET KEY=""
	FOR  SET KEY=$ORDER(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY)) QUIT:KEY=""  DO
	. IF $GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY,"parentKey"))=$GET(DIRKEY) DO PURGEENTRY(PRINCIPAL,KEY,"file")
	SET KEY=""
	FOR  SET KEY=$ORDER(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY)) QUIT:KEY=""  DO
	. IF $GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY,"parentKey"))=$GET(DIRKEY) DO PURGEENTRY(PRINCIPAL,KEY,"directory")
	KILL ^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",DIRKEY)
	QUIT
	;
REPATH(PRINCIPAL,KEY,KIND)
	NEW BASE,ROOT,CHILD
	SET ROOT=$NAME(^MIO("MIOMOS","VFS","USER",PRINCIPAL))
	SET BASE=$$BASE(PRINCIPAL,$GET(KEY),$GET(KIND))
	IF BASE="" QUIT
	SET @BASE@("path")=$$PATH($GET(KEY),ROOT)
	IF $GET(KIND)'="directory" QUIT
	SET CHILD=""
	FOR  SET CHILD=$ORDER(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",CHILD)) QUIT:CHILD=""  DO
	. IF $GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",CHILD,"parentKey"))=$GET(KEY) DO REPATH(PRINCIPAL,CHILD,"file")
	SET CHILD=""
	FOR  SET CHILD=$ORDER(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",CHILD)) QUIT:CHILD=""  DO
	. IF $GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",CHILD,"parentKey"))=$GET(KEY) DO REPATH(PRINCIPAL,CHILD,"directory")
	QUIT
	;
ENTRYKIND(PRINCIPAL,KEY)
	IF $DATA(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY)) QUIT "directory"
	IF $DATA(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY)) QUIT "file"
	QUIT ""
	;
BASE(PRINCIPAL,KEY,KIND)
	IF $GET(KIND)="directory" QUIT $NAME(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY))
	IF $GET(KIND)="file" QUIT $NAME(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY))
	QUIT ""
	;
SYSTEMDIR(KEY)
	NEW SYS
	SET SYS=",downloads,uploads,projects,routines,globals-browser,terminal-shortcuts,team-share,theme-packs,"
	QUIT SYS[","_$GET(KEY)_","
	;
IMMUTABLEDIR(PRINCIPAL,KEY)
	NEW DIRKEY
	SET DIRKEY=$GET(KEY)
	IF $$USERDIRKEY(DIRKEY) QUIT 0
	IF $$SYSTEMDIR(DIRKEY) QUIT 1
	IF +$GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",DIRKEY,"systemOwned")) QUIT 1
	QUIT 0
	;
USERDIRKEY(KEY)
	NEW X
	SET X=$GET(KEY)
	IF $EXTRACT(X,1,4)="dir-" QUIT 1
	IF $EXTRACT(X,1,7)="folder-" QUIT 1
	QUIT 0
	;
ENSUREPARENT(PRINCIPAL,PARENTKEY,PARENTTITLE,ERR)
	NEW ROOT
	SET ROOT=$NAME(^MIO("MIOMOS","VFS","USER",PRINCIPAL))
	IF $$ROOTLABEL($GET(PARENTKEY))'="" QUIT 1
	IF $DATA(@ROOT@("dir",PARENTKEY)) QUIT 1
	IF $EXTRACT($GET(PARENTKEY),1,7)="folder-" DO  QUIT 1
	. DO MKDIR(ROOT,PARENTKEY,$SELECT($GET(PARENTTITLE)'="":$GET(PARENTTITLE),1:"Folder"),"my-documents",900+$$COUNTDIR(PRINCIPAL),"DIR","Folder","Desktop folder backed by virtual storage.",1,1,0,"Today")
	SET ERR("routine")="MIOMOSVFS",ERR("error")="parent_missing",ERR("detail")=$GET(PARENTKEY),ERR("status")=404
	QUIT 0
	;
TARGETOK(PRINCIPAL,TARGET)
	IF $$ROOTLABEL($GET(TARGET))'="" QUIT 1
	QUIT +$DATA(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",TARGET))
	;
DIRUPLOADOK(PRINCIPAL,PARENTKEY)
	IF $EXTRACT($GET(PARENTKEY),1,7)="folder-" QUIT 1
	IF $$ROOTLABEL($GET(PARENTKEY))'="" QUIT $$ROOTUPLOADOK($GET(PARENTKEY))
	QUIT +$GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",PARENTKEY,"uploadAllowed"))
	;
ROOTUPLOADOK(KEY)
	IF $GET(KEY)="my-documents" QUIT 1
	IF $GET(KEY)="ui-samples" QUIT 1
	QUIT 0
	;
ISDESC(PRINCIPAL,KEY,TARGET)
	NEW CUR,ROOT,FOUND
	SET ROOT=$NAME(^MIO("MIOMOS","VFS","USER",PRINCIPAL))
	SET CUR=$GET(TARGET),FOUND=0
	FOR  QUIT:CUR=""!(FOUND)  DO
	. IF CUR=$GET(KEY) SET FOUND=1 QUIT
	. IF $$ROOTLABEL(CUR)'="" SET CUR="" QUIT
	. IF '$DATA(@ROOT@("dir",CUR)) SET CUR="" QUIT
	. SET CUR=$GET(@ROOT@("dir",CUR,"parentKey"))
	QUIT FOUND
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
	SET KEY=""
	FOR  SET KEY=$ORDER(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY)) QUIT:KEY=""  DO
	. IF $GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY,"parentKey"))=$GET(PARENTKEY) SET MAX=$SELECT(+$GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY,"order"))>MAX:+$GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY,"order")),1:MAX)
	QUIT MAX+1
	;
UNIQUETITLE(PRINCIPAL,PARENTKEY,TITLE,KIND,SKIPKEY)
	NEW BASE,EXTN,N,CAND
	SET TITLE=$GET(TITLE)
	IF TITLE="" SET TITLE=$SELECT($GET(KIND)="directory":"New Folder",1:"New File")
	IF $GET(KIND)="file" DO
	. SET EXTN=$$EXT(TITLE)
	. SET BASE=$SELECT(EXTN'="":$EXTRACT(TITLE,1,$L(TITLE)-$L(EXTN)-1),1:TITLE)
	ELSE  SET BASE=TITLE,EXTN=""
	SET CAND=TITLE,N=1
	FOR  QUIT:'$$TITLEUSED(PRINCIPAL,$GET(PARENTKEY),CAND,$GET(SKIPKEY))  DO
	. SET N=N+1
	. IF $GET(KIND)="file",EXTN'="" SET CAND=BASE_" ("_N_")."_EXTN QUIT
	. IF $GET(KIND)="file" SET CAND=BASE_" ("_N_")" QUIT
	. SET CAND=BASE_" ("_N_")"
	QUIT CAND
	;
TITLEUSED(PRINCIPAL,PARENTKEY,TITLE,SKIPKEY)
	NEW KEY,LOWT,HIT
	SET LOWT=$$LOW($GET(TITLE)),HIT=0
	SET KEY=""
	FOR  SET KEY=$ORDER(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY)) QUIT:KEY=""!(HIT)  DO
	. IF KEY=$GET(SKIPKEY) QUIT
	. IF $GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY,"parentKey"))'=$GET(PARENTKEY) QUIT
	. IF $$LOW($GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY,"title")))=LOWT SET HIT=1
	IF HIT QUIT 1
	SET KEY=""
	FOR  SET KEY=$ORDER(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY)) QUIT:KEY=""!(HIT)  DO
	. IF KEY=$GET(SKIPKEY) QUIT
	. IF $GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY,"parentKey"))'=$GET(PARENTKEY) QUIT
	. IF $$LOW($GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY,"title")))=LOWT SET HIT=1
	QUIT HIT
	;
PATH(KEY,ROOT)
	NEW TITLE,PARENT
	SET TITLE=$GET(@ROOT@("dir",KEY,"title"),$GET(@ROOT@("file",KEY,"title"),$GET(KEY)))
	SET PARENT=$GET(@ROOT@("dir",KEY,"parentKey"),$GET(@ROOT@("file",KEY,"parentKey"),""))
	IF PARENT="" QUIT "Desktop\"_TITLE
	QUIT $$DIRPATH(ROOT,PARENT)_TITLE
	;
DIRPATH(ROOT,DIRKEY)
	NEW LABEL,TITLE,PARENT
	IF $GET(DIRKEY)="" QUIT "Desktop\"
	SET LABEL=$$ROOTLABEL($GET(DIRKEY))
	IF LABEL'="" QUIT "Desktop\"_LABEL_"\"
	IF '$DATA(@ROOT@("dir",DIRKEY)) QUIT "Desktop\"
	SET TITLE=$GET(@ROOT@("dir",DIRKEY,"title"),$GET(DIRKEY))
	SET PARENT=$GET(@ROOT@("dir",DIRKEY,"parentKey"))
	QUIT $$DIRPATH(ROOT,PARENT)_TITLE_"\"
	;
ROOTLABEL(KEY)
	IF $GET(KEY)="my-documents" QUIT "My Documents"
	IF $GET(KEY)="my-computer" QUIT "My Computer"
	IF $GET(KEY)="my-network-places" QUIT "My Network Places"
	IF $GET(KEY)="ui-samples" QUIT "UI Samples"
	IF $GET(KEY)="recycle-bin" QUIT "Recycle Bin"
	QUIT ""
	;
SIZELBL(BYTES)
	NEW N
	SET N=+$GET(BYTES)
	IF N<1024 QUIT N_" B"
	IF N<1048576 QUIT $JUSTIFY(N/1024,0,1)_" KB"
	QUIT $JUSTIFY(N/1048576,0,1)_" MB"
	;
SAFENAME(NAME)
	NEW X,I,C,OUT
	SET X=$PIECE($GET(NAME),"/",$L($GET(NAME),"/"))
	SET X=$PIECE(X,"\\",$L(X,"\\"))
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
	IF $GET(EXT)="md" QUIT "DOC"
	IF $GET(EXT)="m" QUIT "M"
	IF $GET(EXT)="gbl" QUIT "GBL"
	IF $GET(EXT)="url" QUIT "URL"
	IF $GET(EXT)'="" QUIT $EXTRACT($ZCONVERT(EXT,"U")_"DOC",1,3)
	QUIT "DOC"
	;
BADGE(EXT,MIME)
	IF $GET(MIME)["text/plain" QUIT "Text"
	IF $GET(MIME)["json" QUIT "Config"
	IF $GET(MIME)["csv" QUIT "Data"
	IF $GET(EXT)="md" QUIT "Document"
	IF $GET(EXT)="m" QUIT "Routine"
	IF $GET(EXT)="gbl" QUIT "Snapshot"
	IF $GET(EXT)="url" QUIT "Link"
	QUIT "File"
	;
LOW(X)
	QUIT $TR($GET(X),"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")
	;
	;