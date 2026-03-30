MIOMOSCMD ; MIOMOS command execution boundary
	QUIT
	;
EXEC(STATE,CONF,TREE,OUT,ERR)
	NEW CMD,RAW,LAYOUT,VIEW
	KILL OUT,ERR
	SET ERR("routine")="MIOMOSCMD"
	SET CMD=$$LOW($$TRIM^MIOUTIL($GET(TREE("command"))))
	IF CMD="",$GET(TREE("action"))'="" SET CMD=$$LOW($$TRIM^MIOUTIL($GET(TREE("action"))))
	IF CMD="" SET ERR("error")="command_missing",ERR("status")=400 QUIT 0
	IF CMD="desktop.ping" DO  QUIT 1
	. SET OUT("command")=CMD
	. SET OUT("pong")=1
	. SET OUT("sessionId")=$GET(STATE("sessionId"))
	IF CMD="layout.save" DO  QUIT 1
	. SET RAW=$GET(TREE("layoutJson"))
	. IF RAW="",$DATA(TREE("layout")) DO
	. . MERGE LAYOUT=TREE("layout")
	. . SET RAW=$$EN^MIOJSON1(.LAYOUT)
	. IF RAW="" SET RAW="{}"
	. DO SAVELAYOUT^MIOMOSST($GET(STATE("sessionId")),RAW)
	. SET OUT("command")=CMD
	. SET OUT("saved")=1
	IF CMD="theme.quick" QUIT $$THEME(.STATE,.TREE,.OUT,.ERR)
	IF CMD="settings.save" QUIT $$SETSAVE(.STATE,.TREE,.OUT,.ERR)
	IF CMD="session.ui.save" QUIT $$UISAVE(.STATE,.TREE,.OUT,.ERR)
	IF CMD="view.refresh" DO  QUIT 1
	. DO BUILD^MIOMOSVM(.STATE,.CONF,.VIEW)
	. MERGE OUT("view")=VIEW
	. SET OUT("command")=CMD
	IF CMD="wm.layout.apply" QUIT $$WMLAYOUT(.STATE,.CONF,.TREE,.OUT,.ERR)
	IF CMD="terminal.open" QUIT $$TERMOPEN(.STATE,.CONF,.TREE,.OUT,.ERR)
	IF CMD="terminal.input" QUIT $$TERMINPUT(.STATE,.TREE,.OUT,.ERR)
	IF CMD="terminal.reattach" QUIT $$TERMREATT(.STATE,.CONF,.TREE,.OUT,.ERR)
	IF CMD="terminal.close" QUIT $$TERMCLOSE(.STATE,.TREE,.OUT,.ERR)
	IF CMD="terminal.poll" QUIT $$TERMPOLL(.STATE,.TREE,.OUT,.ERR)
	IF CMD="terminal.resize" QUIT $$TERMRESZ(.STATE,.TREE,.OUT,.ERR)
	IF CMD="vfs.list"!(CMD="filesystem.list") QUIT $$VFSLIST(.STATE,.CONF,.TREE,.OUT,.ERR)
	IF CMD="vfs.mkdir"!(CMD="filesystem.mkdir") QUIT $$VFSMKDIR(.STATE,.CONF,.TREE,.OUT,.ERR)
	IF CMD="vfs.rename"!(CMD="vfs.entry.rename")!(CMD="filesystem.rename") QUIT $$VFSREN(.STATE,.CONF,.TREE,.OUT,.ERR)
	IF CMD="vfs.delete"!(CMD="vfs.entry.delete")!(CMD="vfs.recycle.move")!(CMD="filesystem.delete") QUIT $$VFSDEL(.STATE,.CONF,.TREE,.OUT,.ERR)
	IF CMD="vfs.move"!(CMD="vfs.entry.move")!(CMD="filesystem.move") QUIT $$VFSMOVE(.STATE,.CONF,.TREE,.OUT,.ERR)
	IF CMD="vfs.recycle.restore"!(CMD="vfs.restore")!(CMD="filesystem.restore") QUIT $$VFSREST(.STATE,.CONF,.TREE,.OUT,.ERR)
	IF CMD="vfs.recycle.empty"!(CMD="vfs.empty")!(CMD="filesystem.empty") QUIT $$VFSEMPTY(.STATE,.CONF,.TREE,.OUT,.ERR)
	SET ERR("error")="command_unsupported",ERR("detail")=CMD,ERR("status")=400
	QUIT 0
	;
THEME(STATE,TREE,OUT,ERR)
	NEW SAVE,CUR
	IF '$$HAS^MIOMOSPERM(.STATE,"settings.self") SET ERR("error")="forbidden",ERR("detail")="settings.self",ERR("status")=403 QUIT 0
	SET SAVE("themeKey")=$GET(TREE("themeKey"))
	IF SAVE("themeKey")="" SET ERR("error")="theme_missing",ERR("status")=400 QUIT 0
	IF '$$SAVE^MIOMOSSET($GET(STATE("principal")),.SAVE,.CUR,.ERR) SET ERR("status")=400 QUIT 0
	MERGE OUT("settings")=CUR
	SET OUT("command")="theme.quick"
	QUIT 1
	;
SETSAVE(STATE,TREE,OUT,ERR)
	NEW CUR
	IF '$$HAS^MIOMOSPERM(.STATE,"settings.self") SET ERR("error")="forbidden",ERR("detail")="settings.self",ERR("status")=403 QUIT 0
	IF '$$SAVE^MIOMOSSET($GET(STATE("principal")),.TREE,.CUR,.ERR) SET ERR("status")=400 QUIT 0
	MERGE OUT("settings")=CUR
	SET OUT("command")="settings.save"
	QUIT 1
	;
UISAVE(STATE,TREE,OUT,ERR)
	NEW SAVE,RAW,UI
	IF '$$HAS^MIOMOSPERM(.STATE,"settings.self") SET ERR("error")="forbidden",ERR("detail")="settings.self",ERR("status")=403 QUIT 0
	SET SAVE("menuOpen")=+$GET(TREE("menuOpen"))
	SET SAVE("activeWindowId")=$GET(TREE("activeWindowId"))
	SET SAVE("focusedAppKey")=$GET(TREE("focusedAppKey"))
	SET SAVE("layoutMode")=$GET(TREE("layoutMode"))
	SET SAVE("lastCommandName")=$GET(TREE("lastCommandName"))
	SET SAVE("terminalId")=$GET(TREE("terminalId"))
	SET SAVE("reason")=$GET(TREE("reason"))
	SET SAVE("startMenuSection")=$GET(TREE("startMenuSection"))
	SET SAVE("startMenuQuery")=$GET(TREE("startMenuQuery"))
	SET SAVE("shellSurface")=$GET(TREE("shellSurface"))
	SET RAW=$$EN^MIOJSON1(.SAVE)
	IF '$$SAVEUIOK^MIOMOSST($GET(STATE("sessionId")),RAW) SET ERR("error")="ui_state_save_failed",ERR("status")=400 QUIT 0
	DO LOADUI^MIOMOSST($GET(STATE("sessionId")),.UI)
	MERGE OUT("ui")=UI
	SET OUT("saved")=1
	SET OUT("command")="session.ui.save"
	QUIT 1
	;
PUTVFS(STATE,CONF,OUT)
	DO CATALOG^MIOMOSVFS($GET(STATE("principal")),.CONF,$NAME(OUT("vfs")))
	QUIT
	;
VFSLIST(STATE,CONF,TREE,OUT,ERR)
	DO PUTVFS(.STATE,.CONF,.OUT)
	SET OUT("command")="vfs.list"
	SET OUT("parentKey")=$$VFSPARENT(.TREE)
	QUIT 1
	;
VFSMKDIR(STATE,CONF,TREE,OUT,ERR)
	NEW ITEM,PRINCIPAL,PARENTKEY,PARENTTITLE,TITLE
	SET PRINCIPAL=$GET(STATE("principal"))
	SET PARENTKEY=$$VFSPARENT(.TREE)
	SET PARENTTITLE=$$VFSPARENTTITLE(.TREE)
	SET TITLE=$$VFSTITLE(.TREE)
	IF '$$MKDIRCMD^MIOMOSVFS(PRINCIPAL,PARENTKEY,PARENTTITLE,TITLE,.ITEM,.ERR) QUIT 0
	MERGE OUT("entry")=ITEM
	SET OUT("command")="vfs.mkdir"
	QUIT 1
	;
VFSREN(STATE,CONF,TREE,OUT,ERR)
	NEW ITEM
	IF '$$WSRENAME($GET(STATE("principal")),.TREE,.ITEM,.ERR) QUIT 0
	MERGE OUT("entry")=ITEM
	SET OUT("command")="vfs.rename"
	QUIT 1
	;
VFSDEL(STATE,CONF,TREE,OUT,ERR)
	NEW ITEM
	IF '$$WSDELETE($GET(STATE("principal")),.TREE,.ITEM,.ERR) QUIT 0
	MERGE OUT("entry")=ITEM
	SET OUT("command")="vfs.delete"
	QUIT 1
	;
VFSMOVE(STATE,CONF,TREE,OUT,ERR)
	NEW ITEM
	IF '$$WSMOVE($GET(STATE("principal")),.TREE,.ITEM,.ERR) QUIT 0
	MERGE OUT("entry")=ITEM
	SET OUT("command")="vfs.move"
	QUIT 1
	;
VFSREST(STATE,CONF,TREE,OUT,ERR)
	NEW ITEM
	IF '$$WSRESTORE($GET(STATE("principal")),.TREE,.ITEM,.ERR) QUIT 0
	MERGE OUT("entry")=ITEM
	SET OUT("command")="vfs.recycle.restore"
	QUIT 1
	;
VFSEMPTY(STATE,CONF,TREE,OUT,ERR)
	NEW ITEM
	IF '$$WSEMPTY($GET(STATE("principal")),.ITEM,.ERR) QUIT 0
	MERGE OUT("entry")=ITEM
	SET OUT("command")="vfs.recycle.empty"
	QUIT 1
	;
WSRENAME(PRINCIPAL,TREE,OUT,ERR)
	NEW KEY,TITLE,KIND,BASE,PARENT,SAFE,EXTN
	KILL OUT,ERR
	DO ENSURE^MIOMOSVFS(PRINCIPAL,"")
	SET ERR("routine")="MIOMOSCMD"
	SET KEY=$$VFSKEY(.TREE)
	SET TITLE=$$VFSTITLE(.TREE)
	IF KEY="" SET ERR("error")="key_missing",ERR("status")=400 QUIT 0
	SET KIND=$$ENTRYKIND^MIOMOSVFS(PRINCIPAL,KEY)
	IF KIND="" SET ERR("error")="entry_missing",ERR("detail")=KEY,ERR("status")=404 QUIT 0
	IF KIND="directory",$$BLOCKDIR(KEY) SET ERR("error")="system_entry_forbidden",ERR("detail")=KEY,ERR("status")=403 QUIT 0
	SET BASE=$$BASE^MIOMOSVFS(PRINCIPAL,KEY,KIND)
	IF BASE="" SET ERR("error")="entry_missing",ERR("detail")=KEY,ERR("status")=404 QUIT 0
	SET PARENT=$GET(@BASE@("parentKey"))
	SET SAFE=$$SAFENAME^MIOMOSVFS(TITLE)
	IF SAFE="" SET SAFE=$SELECT(KIND="directory":"New Folder",1:"New File")
	SET SAFE=$$UNIQUETITLE^MIOMOSVFS(PRINCIPAL,PARENT,SAFE,KIND,KEY)
	SET @BASE@("title")=SAFE
	SET @BASE@("modifiedAt")="Today"
	IF KIND="file" DO
	. SET EXTN=$$EXT^MIOMOSVFS(SAFE)
	. SET @BASE@("extension")=EXTN
	. SET @BASE@("icon")=$$ICON^MIOMOSVFS(EXTN,$GET(@BASE@("mime")))
	. SET @BASE@("badge")=$$BADGE^MIOMOSVFS(EXTN,$GET(@BASE@("mime")))
	DO REPATH^MIOMOSVFS(PRINCIPAL,KEY,KIND)
	DO GETENTRY^MIOMOSVFS(PRINCIPAL,KEY,$NAME(OUT))
	QUIT 1
	;
WSDELETE(PRINCIPAL,TREE,OUT,ERR)
	NEW KEY,MODE,KIND,BASE,PARENT,TTL
	KILL OUT,ERR
	DO ENSURE^MIOMOSVFS(PRINCIPAL,"")
	SET ERR("routine")="MIOMOSCMD"
	SET KEY=$$VFSKEY(.TREE)
	SET MODE=$$VFSMODE(.TREE)
	IF KEY="" SET ERR("error")="key_missing",ERR("status")=400 QUIT 0
	SET KIND=$$ENTRYKIND^MIOMOSVFS(PRINCIPAL,KEY)
	IF KIND="" SET ERR("error")="entry_missing",ERR("detail")=KEY,ERR("status")=404 QUIT 0
	IF KIND="directory",$$BLOCKDIR(KEY) SET ERR("error")="system_entry_forbidden",ERR("detail")=KEY,ERR("status")=403 QUIT 0
	SET BASE=$$BASE^MIOMOSVFS(PRINCIPAL,KEY,KIND)
	IF BASE="" SET ERR("error")="entry_missing",ERR("detail")=KEY,ERR("status")=404 QUIT 0
	IF $$LOW(MODE)="permanent" DO  QUIT 1
	. DO PURGEENTRY^MIOMOSVFS(PRINCIPAL,KEY,KIND)
	. SET OUT("removed")=1,OUT("mode")="permanent",OUT("key")=KEY
	SET PARENT=$GET(@BASE@("parentKey"))
	IF PARENT="recycle-bin" DO GETENTRY^MIOMOSVFS(PRINCIPAL,KEY,$NAME(OUT)) QUIT 1
	SET @BASE@("recycle","originalParentKey")=PARENT
	SET @BASE@("recycle","originalTitle")=$GET(@BASE@("title"))
	SET TTL=$$UNIQUETITLE^MIOMOSVFS(PRINCIPAL,"recycle-bin",$GET(@BASE@("title")),KIND,KEY)
	SET @BASE@("title")=TTL
	SET @BASE@("parentKey")="recycle-bin"
	SET @BASE@("modifiedAt")="Today"
	DO REPATH^MIOMOSVFS(PRINCIPAL,KEY,KIND)
	DO GETENTRY^MIOMOSVFS(PRINCIPAL,KEY,$NAME(OUT))
	QUIT 1
	;
WSMOVE(PRINCIPAL,TREE,OUT,ERR)
	NEW KEY,TARGETPARENTKEY,OPERATION,KIND,BASE,TITLE
	KILL OUT,ERR
	DO ENSURE^MIOMOSVFS(PRINCIPAL,"")
	SET ERR("routine")="MIOMOSCMD"
	SET KEY=$$VFSKEY(.TREE)
	SET TARGETPARENTKEY=$$VFSTARGET(.TREE)
	SET OPERATION=$$VFSOP(.TREE)
	IF KEY="" SET ERR("error")="key_missing",ERR("status")=400 QUIT 0
	IF TARGETPARENTKEY="" SET ERR("error")="target_parent_missing",ERR("status")=400 QUIT 0
	SET KIND=$$ENTRYKIND^MIOMOSVFS(PRINCIPAL,KEY)
	IF KIND="" SET ERR("error")="entry_missing",ERR("detail")=KEY,ERR("status")=404 QUIT 0
	IF $$LOW($SELECT(OPERATION'="":OPERATION,1:"move"))'="move" SET ERR("error")="operation_unsupported",ERR("detail")=OPERATION,ERR("status")=400 QUIT 0
	IF '$$ENSUREPARENT^MIOMOSVFS(PRINCIPAL,TARGETPARENTKEY,"",.ERR) SET ERR("routine")="MIOMOSCMD" QUIT 0
	IF KIND="directory",$$ISDESC^MIOMOSVFS(PRINCIPAL,KEY,TARGETPARENTKEY) SET ERR("error")="invalid_move_target",ERR("detail")=TARGETPARENTKEY,ERR("status")=409 QUIT 0
	IF KIND="directory",$$BLOCKDIR(KEY) SET ERR("error")="system_entry_forbidden",ERR("detail")=KEY,ERR("status")=403 QUIT 0
	SET BASE=$$BASE^MIOMOSVFS(PRINCIPAL,KEY,KIND)
	IF BASE="" SET ERR("error")="entry_missing",ERR("detail")=KEY,ERR("status")=404 QUIT 0
	IF $GET(@BASE@("parentKey"))=TARGETPARENTKEY DO GETENTRY^MIOMOSVFS(PRINCIPAL,KEY,$NAME(OUT)) QUIT 1
	SET TITLE=$$UNIQUETITLE^MIOMOSVFS(PRINCIPAL,TARGETPARENTKEY,$GET(@BASE@("title")),KIND,KEY)
	SET @BASE@("title")=TITLE
	SET @BASE@("parentKey")=TARGETPARENTKEY
	SET @BASE@("modifiedAt")="Today"
	DO REPATH^MIOMOSVFS(PRINCIPAL,KEY,KIND)
	DO GETENTRY^MIOMOSVFS(PRINCIPAL,KEY,$NAME(OUT))
	QUIT 1
	;
WSRESTORE(PRINCIPAL,TREE,OUT,ERR)
	NEW KEY,KIND,BASE,TARGET,TITLE
	KILL OUT,ERR
	DO ENSURE^MIOMOSVFS(PRINCIPAL,"")
	SET ERR("routine")="MIOMOSCMD"
	SET KEY=$$VFSKEY(.TREE)
	IF KEY="" SET ERR("error")="key_missing",ERR("status")=400 QUIT 0
	SET KIND=$$ENTRYKIND^MIOMOSVFS(PRINCIPAL,KEY)
	IF KIND="" SET ERR("error")="entry_missing",ERR("detail")=KEY,ERR("status")=404 QUIT 0
	SET BASE=$$BASE^MIOMOSVFS(PRINCIPAL,KEY,KIND)
	IF BASE="" SET ERR("error")="entry_missing",ERR("detail")=KEY,ERR("status")=404 QUIT 0
	SET TARGET=$GET(@BASE@("recycle","originalParentKey"),"my-documents")
	IF '$$TARGETOK^MIOMOSVFS(PRINCIPAL,TARGET) SET TARGET="my-documents"
	SET TITLE=$$UNIQUETITLE^MIOMOSVFS(PRINCIPAL,TARGET,$GET(@BASE@("recycle","originalTitle"),$GET(@BASE@("title"))),KIND,KEY)
	SET @BASE@("title")=TITLE
	SET @BASE@("parentKey")=TARGET
	KILL @BASE@("recycle")
	SET @BASE@("modifiedAt")="Today"
	DO REPATH^MIOMOSVFS(PRINCIPAL,KEY,KIND)
	DO GETENTRY^MIOMOSVFS(PRINCIPAL,KEY,$NAME(OUT))
	QUIT 1
	;
WSEMPTY(PRINCIPAL,OUT,ERR)
	NEW KEY,REMOVED,N,FILES,DIRS
	KILL OUT,ERR
	DO ENSURE^MIOMOSVFS(PRINCIPAL,"")
	SET ERR("routine")="MIOMOSCMD"
	SET (REMOVED,N)=0,KEY=""
	FOR  SET KEY=$ORDER(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY)) QUIT:KEY=""  DO
	. IF $GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"file",KEY,"parentKey"))="recycle-bin" SET N=N+1,FILES(N)=KEY
	SET N=0
	FOR  SET KEY=$ORDER(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY)) QUIT:KEY=""  DO
	. IF $GET(^MIO("MIOMOS","VFS","USER",PRINCIPAL,"dir",KEY,"parentKey"))="recycle-bin" SET N=N+1,DIRS(N)=KEY
	SET N=0
	FOR  SET N=$ORDER(FILES(N)) QUIT:'N  DO
	. DO PURGEENTRY^MIOMOSVFS(PRINCIPAL,FILES(N),"file")
	. SET REMOVED=REMOVED+1
	SET N=0
	FOR  SET N=$ORDER(DIRS(N)) QUIT:'N  DO
	. DO PURGEENTRY^MIOMOSVFS(PRINCIPAL,DIRS(N),"directory")
	. SET REMOVED=REMOVED+1
	SET OUT("emptied")=1
	SET OUT("removedCount")=REMOVED
	SET OUT("key")="recycle-bin"
	QUIT 1
	;
VFSKEY(TREE)
	QUIT $$PICK(.TREE,"key,entryKey,itemKey,folderKey,selectedKey,sourceKey")
	;
VFSTITLE(TREE)
	QUIT $$PICK(.TREE,"title,newTitle,name,entryTitle,folderTitle")
	;
VFSPARENT(TREE)
	QUIT $$PICK(.TREE,"parentKey,currentFolderKey,folderKey,targetKey")
	;
VFSPARENTTITLE(TREE)
	QUIT $$PICK(.TREE,"parentTitle,currentFolderTitle,folderTitle,targetTitle")
	;
VFSTARGET(TREE)
	QUIT $$PICK(.TREE,"targetParentKey,destinationKey,targetKey,dropTargetKey,parentKey")
	;
VFSMODE(TREE)
	QUIT $$PICK(.TREE,"mode,deleteMode")
	;
VFSOP(TREE)
	NEW X
	SET X=$$PICK(.TREE,"operation,mode")
	IF X="" SET X="move"
	QUIT X
	;
PICK(TREE,CSV)
	NEW I,NM,VAL
	FOR I=1:1:$L(CSV,",") DO  QUIT:VAL'=""
	. SET NM=$$TRIM^MIOUTIL($P(CSV,",",I))
	. QUIT:NM=""
	. SET VAL=$GET(TREE(NM))
	QUIT $GET(VAL)
	;
BLOCKDIR(KEY)
	NEW X,SYS
	SET X=$GET(KEY)
	IF $EXTRACT(X,1,4)="dir-" QUIT 0
	IF $EXTRACT(X,1,7)="folder-" QUIT 0
	SET SYS=",downloads,uploads,projects,routines,globals-browser,terminal-shortcuts,team-share,theme-packs,"
	QUIT SYS[","_X_","
	;
LOW(X)
	NEW Y
	SET Y=$TR($GET(X),"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")
	QUIT Y
	;
WMLAYOUT(STATE,CONF,TREE,OUT,ERR)
	NEW PRESET,WIN
	IF '$$HAS^MIOMOSPERM(.STATE,"settings.self") SET ERR("error")="forbidden",ERR("detail")="settings.self",ERR("status")=403 QUIT 0
	SET PRESET=$GET(TREE("windowPreset")) IF PRESET="" SET PRESET=$GET(STATE("windowPreset"),"analyst")
	IF '$$SAVE^MIOMOSWM($GET(STATE("principal")),.TREE,.WIN,.ERR) SET ERR("status")=400 QUIT 0
	DO DEFAULTWINS^MIOMOSWM($NAME(OUT("windows")),PRESET)
	SET OUT("command")="wm.layout.apply"
	SET OUT("windowPreset")=PRESET
	QUIT 1
	;
TERMOPEN(STATE,CONF,TREE,OUT,ERR)
	NEW TERMOUT,TERMID,COLS,ROWS
	IF '$$HAS^MIOMOSPERM(.STATE,"terminal.use") SET ERR("error")="forbidden",ERR("detail")="terminal.use",ERR("status")=403 QUIT 0
	SET TERMID=$GET(TREE("terminalId"))
	IF $$BOOL($GET(TREE("forceNew"))) SET TERMID="__new__"
	SET COLS=$$COLS^MIOMOSTERM(+$GET(TREE("cols")))
	SET ROWS=$$ROWS^MIOMOSTERM(+$GET(TREE("rows")))
	IF COLS>0 SET STATE("terminal","cols")=COLS
	IF ROWS>0 SET STATE("terminal","rows")=ROWS
	IF '$$OPEN^MIOMOSTPIPE(.STATE,.CONF,TERMID,.TERMOUT,.ERR) SET ERR("status")=400 QUIT 0
	MERGE OUT("terminal")=TERMOUT
	SET OUT("command")="terminal.open"
	QUIT 1
	;
TERMREATT(STATE,CONF,TREE,OUT,ERR)
	NEW TERMOUT
	IF '$$HAS^MIOMOSPERM(.STATE,"terminal.use") SET ERR("error")="forbidden",ERR("detail")="terminal.use",ERR("status")=403 QUIT 0
	IF '$$REATTACH^MIOMOSTPIPE(.STATE,.CONF,$GET(TREE("terminalId")),.TERMOUT,.ERR) SET ERR("status")=400 QUIT 0
	MERGE OUT("terminal")=TERMOUT
	SET OUT("command")="terminal.reattach"
	QUIT 1
	;
TERMINPUT(STATE,TREE,OUT,ERR)
	NEW TERMOUT,DATA
	IF '$$HAS^MIOMOSPERM(.STATE,"terminal.use") SET ERR("error")="forbidden",ERR("detail")="terminal.use",ERR("status")=403 QUIT 0
	SET DATA=$SELECT($DATA(TREE("line")):$$TERMNL($GET(TREE("line"))),1:$GET(TREE("data")))
	IF '$$INPUT^MIOMOSTPIPE(.STATE,$GET(TREE("terminalId")),DATA,.TERMOUT,.ERR) SET ERR("status")=400 QUIT 0
	MERGE OUT("terminal")=TERMOUT
	SET OUT("command")="terminal.input"
	QUIT 1
	;
TERMCLOSE(STATE,TREE,OUT,ERR)
	NEW TERMOUT
	IF '$$HAS^MIOMOSPERM(.STATE,"terminal.use") SET ERR("error")="forbidden",ERR("detail")="terminal.use",ERR("status")=403 QUIT 0
	IF '$$CLOSE^MIOMOSTPIPE(.STATE,$GET(TREE("terminalId")),.TERMOUT,.ERR) SET ERR("status")=400 QUIT 0
	MERGE OUT("terminal")=TERMOUT
	SET OUT("command")="terminal.close"
	QUIT 1
	;
TERMPOLL(STATE,TREE,OUT,ERR)
	NEW TERMOUT
	IF '$$HAS^MIOMOSPERM(.STATE,"terminal.use") SET ERR("error")="forbidden",ERR("detail")="terminal.use",ERR("status")=403 QUIT 0
	IF '$$POLL^MIOMOSTPIPE(.STATE,$GET(TREE("terminalId")),.TERMOUT,.ERR) SET ERR("status")=400 QUIT 0
	MERGE OUT("terminal")=TERMOUT
	SET OUT("command")="terminal.poll"
	QUIT 1
	;
TERMRESZ(STATE,TREE,OUT,ERR)
	NEW TERMOUT
	IF '$$HAS^MIOMOSPERM(.STATE,"terminal.use") SET ERR("error")="forbidden",ERR("detail")="terminal.use",ERR("status")=403 QUIT 0
	IF '$$RESIZE^MIOMOSTPIPE(.STATE,$GET(TREE("terminalId")),+$GET(TREE("cols")),+$GET(TREE("rows")),.TERMOUT,.ERR) SET ERR("status")=400 QUIT 0
	MERGE OUT("terminal")=TERMOUT
	SET OUT("command")="terminal.resize"
	QUIT 1
	;
TERMNL(X)
	NEW Y
	SET Y=$GET(X)
	IF Y="" QUIT $CHAR(10)
	IF $EXTRACT(Y,$LENGTH(Y))=$CHAR(10) QUIT Y
	IF $EXTRACT(Y,$LENGTH(Y))=$CHAR(13) QUIT Y
	QUIT Y_$CHAR(10)
	;
BOOL(X)
	NEW V
	SET V=$ZCONVERT($$TRIM^MIOUTIL($GET(X)),"L")
	IF V="true" QUIT 1
	IF V="yes" QUIT 1
	IF V="on" QUIT 1
	QUIT $SELECT(+$GET(X):1,1:0)
	;
	;