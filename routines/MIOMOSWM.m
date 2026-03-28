MIOMOSWM ; MIOMOS window manager, layout, and motion catalog
	QUIT
	;
LOAD(STATE,CONF)
	NEW USER
	SET USER=$GET(STATE("principal"))
	SET STATE("windowPreset")=$$GETP(USER,"windowPreset",$GET(CONF("miomos","wm","defaultPreset"),"analyst"))
	IF '$$PRESETOK($GET(STATE("windowPreset"))) SET STATE("windowPreset")="analyst"
	SET STATE("snapMode")=$$GETP(USER,"snapMode",$GET(CONF("miomos","wm","defaultSnapMode"),"quadrant"))
	IF '$$SNAPOK($GET(STATE("snapMode"))) SET STATE("snapMode")="quadrant"
	SET STATE("motionProfile")=$$GETP(USER,"motionProfile",$GET(CONF("miomos","wm","defaultMotionProfile"),"standard"))
	IF '$$MOTIONOK($GET(STATE("motionProfile"))) SET STATE("motionProfile")="standard"
	SET STATE("titlebarStyle")=$$GETP(USER,"titlebarStyle",$GET(CONF("miomos","wm","defaultTitlebarStyle"),"accent"))
	IF $$TITLESTYLE($GET(STATE("titlebarStyle")))="" SET STATE("titlebarStyle")="accent"
	QUIT
	;
SAVE(USER,TREE,OUT,ERR)
	NEW VAL
	KILL OUT
	SET ERR("routine")="MIOMOSWM"
	IF $GET(USER)="" SET ERR("error")="principal_missing" QUIT 0
	IF $DATA(TREE("windowPreset")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$PRESETOK($GET(TREE("windowPreset"))) IF 'VAL SET ERR("error")="window_preset_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"windowPreset")=$GET(TREE("windowPreset"))
	IF $DATA(TREE("snapMode")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$SNAPOK($GET(TREE("snapMode"))) IF 'VAL SET ERR("error")="snap_mode_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"snapMode")=$GET(TREE("snapMode"))
	IF $DATA(TREE("motionProfile")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$MOTIONOK($GET(TREE("motionProfile"))) IF 'VAL SET ERR("error")="motion_profile_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"motionProfile")=$GET(TREE("motionProfile"))
	IF $DATA(TREE("titlebarStyle")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$TITLESTYLE($GET(TREE("titlebarStyle"))) IF VAL="" SET ERR("error")="titlebar_style_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"titlebarStyle")=VAL
	SET ^MIO("MIOMOS","PREF",USER,"wmSavedAt")=$$NOWISO^MIOUTIL()
	QUIT 1
	;
PUTBOOT(ROOT,STATE,CONF)
	KILL @ROOT
	SET @ROOT@("windowPreset")=$GET(STATE("windowPreset"),"analyst")
	SET @ROOT@("snapMode")=$GET(STATE("snapMode"),"quadrant")
	SET @ROOT@("motionProfile")=$GET(STATE("motionProfile"),"standard")
	SET @ROOT@("titlebarStyle")=$GET(STATE("titlebarStyle"),"accent")
	DO CATALOG($NAME(@ROOT@("catalog")))
	DO ACTIONS($NAME(@ROOT@("actions")))
	QUIT
	;
CATALOG(ROOT)
	KILL @ROOT
	DO OPTS($NAME(@ROOT@("windowPresets")),"analyst^Analyst Workspace,terminal^Terminal Focus,review^Review Console,operations^Operations Wall")
	DO OPTS($NAME(@ROOT@("snapModes")),"edge^Edge Snap,quadrant^Quadrant Snap,grid^Grid + Quadrant,off^Off")
	DO OPTS($NAME(@ROOT@("motionProfiles")),"reduced^Reduced,standard^Standard,polished^Polished")
	DO OPTS($NAME(@ROOT@("titlebarStyles")),"accent^Accent,solid^Solid,glass^Glass,contrast^Contrast")
	QUIT
	;
ACTIONS(ROOT)
	KILL @ROOT
	SET @ROOT@(1,"key")="tile",@ROOT@(1,"label")="Tile windows",@ROOT@(1,"subtitle")="Fit visible windows to a clean grid",@ROOT@(1,"shortcut")="Alt+G"
	SET @ROOT@(2,"key")="cascade",@ROOT@(2,"label")="Cascade windows",@ROOT@(2,"subtitle")="Offset open windows for quick review",@ROOT@(2,"shortcut")="Alt+C"
	SET @ROOT@(3,"key")="minimizeAll",@ROOT@(3,"label")="Minimize all",@ROOT@(3,"subtitle")="Clear the workspace quickly",@ROOT@(3,"shortcut")="Alt+N"
	SET @ROOT@(4,"key")="restoreAll",@ROOT@(4,"label")="Restore all",@ROOT@(4,"subtitle")="Bring every surface back",@ROOT@(4,"shortcut")="Alt+R"
	SET @ROOT@(5,"key")="focusTerminal",@ROOT@(5,"label")="Focus terminal",@ROOT@(5,"subtitle")="Jump to the YDB console",@ROOT@(5,"shortcut")="Alt+T"
	QUIT
	;
DEFAULTWINS(ROOT,PRESET)
	NEW USEIND
	SET USEIND=$SELECT($GET(ROOT)'="":1,1:0)
	IF USEIND KILL @ROOT
	IF 'USEIND KILL ROOT
	SET PRESET=$SELECT($$PRESETOK($GET(PRESET)):$GET(PRESET),1:"analyst")
	IF PRESET="terminal" DO  QUIT
	. DO SETWIN(.ROOT,USEIND,1,"win-workspace","workspace","Workspace",14,14,990,640,6,"normal")
	. DO SETWIN(.ROOT,USEIND,2,"win-collaboration","collaboration","Chat",1018,14,360,300,4,"minimized")
	. DO SETWIN(.ROOT,USEIND,3,"win-security","security","Security",1018,324,360,330,3,"minimized")
	. DO SETWIN(.ROOT,USEIND,4,"win-admin","admin","Admin",180,62,820,520,5,"minimized")
	. DO SETWIN(.ROOT,USEIND,5,"win-settings","settings","Settings",210,84,760,560,7,"minimized")
	. DO SETWIN(.ROOT,USEIND,6,"win-terminal","terminal","Terminal",70,60,1310,700,8,"minimized")
	IF PRESET="review" DO  QUIT
	. DO SETWIN(.ROOT,USEIND,1,"win-workspace","workspace","Workspace",20,16,860,650,6,"normal")
	. DO SETWIN(.ROOT,USEIND,2,"win-collaboration","collaboration","Chat",894,16,486,260,4,"minimized")
	. DO SETWIN(.ROOT,USEIND,3,"win-security","security","Security",894,288,486,378,5,"minimized")
	. DO SETWIN(.ROOT,USEIND,4,"win-admin","admin","Admin",118,70,880,560,3,"minimized")
	. DO SETWIN(.ROOT,USEIND,5,"win-settings","settings","Settings",160,88,780,560,7,"minimized")
	. DO SETWIN(.ROOT,USEIND,6,"win-terminal","terminal","Terminal",90,76,1080,600,8,"minimized")
	IF PRESET="operations" DO  QUIT
	. DO SETWIN(.ROOT,USEIND,1,"win-workspace","workspace","Workspace",16,14,930,650,6,"normal")
	. DO SETWIN(.ROOT,USEIND,2,"win-collaboration","collaboration","Chat",958,14,420,260,4,"normal")
	. DO SETWIN(.ROOT,USEIND,3,"win-security","security","Security",958,286,420,230,5,"normal")
	. DO SETWIN(.ROOT,USEIND,4,"win-admin","admin","Admin",958,528,420,176,3,"minimized")
	. DO SETWIN(.ROOT,USEIND,5,"win-settings","settings","Settings",170,76,820,560,2,"minimized")
	. DO SETWIN(.ROOT,USEIND,6,"win-terminal","terminal","Terminal",120,92,1180,600,7,"minimized")
	DO SETWIN(.ROOT,USEIND,1,"win-workspace","workspace","Workspace",16,14,1180,690,6,"normal")
	DO SETWIN(.ROOT,USEIND,2,"win-collaboration","collaboration","Chat",940,44,420,430,3,"minimized")
	DO SETWIN(.ROOT,USEIND,3,"win-security","security","Security",970,488,390,258,2,"minimized")
	DO SETWIN(.ROOT,USEIND,4,"win-admin","admin","Admin",220,68,820,520,4,"minimized")
	DO SETWIN(.ROOT,USEIND,5,"win-settings","settings","Settings",240,88,760,560,5,"minimized")
	DO SETWIN(.ROOT,USEIND,6,"win-terminal","terminal","Terminal",110,80,1180,620,7,"minimized")
	QUIT
	;
SETWIN(ROOT,USEIND,N,ID,APPKEY,TITLE,LEFT,TOP,WIDTH,HEIGHT,Z,STATE)
	IF USEIND DO  QUIT
	. SET @ROOT@(N,"id")=ID,@ROOT@(N,"appKey")=APPKEY,@ROOT@(N,"title")=TITLE,@ROOT@(N,"left")=LEFT,@ROOT@(N,"top")=TOP,@ROOT@(N,"width")=WIDTH,@ROOT@(N,"height")=HEIGHT,@ROOT@(N,"z")=Z,@ROOT@(N,"state")=STATE
	SET ROOT(N,"id")=ID,ROOT(N,"appKey")=APPKEY,ROOT(N,"title")=TITLE,ROOT(N,"left")=LEFT,ROOT(N,"top")=TOP,ROOT(N,"width")=WIDTH,ROOT(N,"height")=HEIGHT,ROOT(N,"z")=Z,ROOT(N,"state")=STATE
	QUIT
	;
GETP(USER,KEY,DEF)
	NEW X
	SET X=$GET(^MIO("MIOMOS","PREF",$GET(USER),$GET(KEY)))
	IF X'="" QUIT X
	QUIT $GET(DEF)
	;
PRESETOK(X)
	SET X=$$TRIM^MIOUTIL($GET(X))
	QUIT $SELECT((X="analyst")!(X="terminal")!(X="review")!(X="operations"):1,1:0)
	;
SNAPOK(X)
	SET X=$$TRIM^MIOUTIL($GET(X))
	QUIT $SELECT((X="edge")!(X="quadrant")!(X="grid")!(X="off"):1,1:0)
	;
MOTIONOK(X)
	SET X=$$TRIM^MIOUTIL($GET(X))
	QUIT $SELECT((X="reduced")!(X="standard")!(X="polished"):1,1:0)
	;
TITLESTYLE(X)
	SET X=$$TRIM^MIOUTIL($GET(X))
	IF (X="accent")!(X="solid")!(X="glass")!(X="contrast") QUIT X
	QUIT ""
	;
OPTS(ROOT,CSV)
	NEW I,N,ITEM
	KILL @ROOT
	SET N=0
	FOR I=1:1:$LENGTH($GET(CSV),",") DO
	. SET ITEM=$PIECE(CSV,",",I)
	. IF ITEM="" QUIT
	. SET N=N+1
	. SET @ROOT@(N,"key")=$PIECE(ITEM,"^",1)
	. SET @ROOT@(N,"label")=$PIECE(ITEM,"^",2)
	QUIT
