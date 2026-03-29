MIOMOSSET ; MIOMOS desktop settings and preference catalog
	QUIT
	;
LOAD(STATE,CONF)
	NEW USER,THEME,VAL,APP
	SET USER=$GET(STATE("principal"))
	SET STATE("themeKey")=$$CURRENT^MIOMOSTH(.STATE,.CONF)
	SET STATE("fontFamily")=$$GETP(USER,"fontFamily",$GET(CONF("miomos","settings","default","fontFamily"),"Segoe UI"))
	SET STATE("fontSize")=+$$GETP(USER,"fontSize",$GET(CONF("miomos","settings","default","fontSize"),13))
	IF STATE("fontSize")<12 SET STATE("fontSize")=13
	SET STATE("titleAccent")=$$GETP(USER,"titleAccent",$GET(CONF("miomos","settings","default","titleAccent"),"theme"))
	SET STATE("iconStyle")=$$GETP(USER,"iconStyle",$GET(CONF("miomos","settings","default","iconStyle"),"glass"))
	SET STATE("wallpaper")=$$GETP(USER,"wallpaper",$GET(CONF("miomos","desktop","wallpaper"),"midnight-clinic"))
	SET STATE("density")=$$GETP(USER,"density",$GET(CONF("miomos","desktop","density"),"dense"))
	SET STATE("animations")=$$ANIMLOAD($$GETP(USER,"animations",$GET(CONF("miomos","settings","default","animations"),"standard")))
	SET STATE("fontScaleClass")=$$FONTSCALE(+$GET(STATE("fontSize"),13))
	DO THEME^MIOMOSTH($GET(STATE("themeKey")),.THEME)
	SET STATE("themeMode")=$GET(THEME("mode"),"dark")
	SET STATE("titleAccentValue")=$$TITLEVAL($GET(STATE("titleAccent")),.THEME)
	DO LOADTERM^MIOMOSTERM(.STATE,.CONF)
	DO LOAD^MIOMOSWM(.STATE,.CONF)
	FOR APP="workspace","collaboration","security","admin","settings","terminal" DO
	. SET VAL=$GET(^MIO("MIOMOS","PREF",USER,"icon",APP))
	. IF VAL="" SET VAL=$$ICONSTYLE($GET(STATE("iconStyle")),APP)
	. SET STATE("icon",APP)=VAL
	NEW DEF
	SET DEF("startMenuSection")=$GET(CONF("miomos","settings","shell","startMenuSection"),"Pinned")
	SET DEF("showClockSeconds")=+$GET(CONF("miomos","settings","shell","showClockSeconds"),0)
	SET DEF("showTrayLabels")=+$GET(CONF("miomos","settings","shell","showTrayLabels"),1)
	SET DEF("chatRoom")=$GET(CONF("miomos","chat","defaultRoom"),"general")
	SET DEF("chatLimit")=+$GET(CONF("miomos","chat","messageLimit"),20)
	SET DEF("terminalLaunchMode")=$GET(CONF("miomos","settings","shell","terminalLaunchMode"),"resume-last")
	SET DEF("quickLaunch")=$GET(CONF("miomos","settings","shell","quickLaunch"),"workspace,collaboration,terminal")
	SET STATE("shell","startMenuSection")=$$SHELLSECTIONOK($$GETS(USER,"startMenuSection",DEF("startMenuSection")),DEF("startMenuSection"))
	SET STATE("shell","showClockSeconds")=+$GET(^MIO("MIOMOS","PREF",USER,"shell","showClockSeconds"),DEF("showClockSeconds"))
	SET STATE("shell","showTrayLabels")=+$GET(^MIO("MIOMOS","PREF",USER,"shell","showTrayLabels"),DEF("showTrayLabels"))
	SET STATE("shell","chatRoom")=$$CHATROOMOK($$GETS(USER,"chatRoom",DEF("chatRoom")),DEF("chatRoom"))
	SET STATE("shell","chatLimit")=$$CHATLIMIT(+$GET(^MIO("MIOMOS","PREF",USER,"shell","chatLimit"),DEF("chatLimit")))
	SET STATE("shell","terminalLaunchMode")=$$LAUNCHMODEOK($$GETS(USER,"terminalLaunchMode",DEF("terminalLaunchMode")),DEF("terminalLaunchMode"))
	SET STATE("shell","quickLaunch")=$$QUICKCSV($$GETS(USER,"quickLaunch",DEF("quickLaunch")),DEF("quickLaunch"))
	QUIT
	;
GETP(USER,KEY,DEF)
	NEW X
	SET X=$GET(^MIO("MIOMOS","PREF",$GET(USER),$GET(KEY)))
	IF X'="" QUIT X
	QUIT $GET(DEF)
	;
GETS(USER,KEY,DEF)
	NEW X
	SET X=$GET(^MIO("MIOMOS","PREF",$GET(USER),"shell",$GET(KEY)))
	IF X'="" QUIT X
	QUIT $GET(DEF)
	;
SAVE(USER,TREE,OUT,ERR)
	NEW THEME,VAL,APP,ROOT
	KILL ERR,OUT
	SET ERR("routine")="MIOMOSSET"
	IF $GET(USER)="" SET ERR("error")="principal_missing" QUIT 0
	SET THEME=$GET(TREE("themeKey"))
	IF THEME'="" DO  QUIT:$GET(ERR("error"))'=""
	. IF '$$SAVE^MIOMOSTH(USER,THEME,.ERR) QUIT
	IF $DATA(TREE("fontFamily")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$FONTOK($GET(TREE("fontFamily"))) IF VAL="" SET ERR("error")="font_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"fontFamily")=VAL
	IF $DATA(TREE("fontSize")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$FONTSIZE(+$GET(TREE("fontSize"))) IF VAL<1 SET ERR("error")="font_size_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"fontSize")=VAL
	IF $DATA(TREE("titleAccent")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$TITLEOK($GET(TREE("titleAccent"))) IF VAL="" SET ERR("error")="title_accent_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"titleAccent")=VAL
	IF $DATA(TREE("iconStyle")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$ICONSTYLEOK($GET(TREE("iconStyle"))) IF VAL="" SET ERR("error")="icon_style_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"iconStyle")=VAL
	IF $DATA(TREE("wallpaper")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$WALLPAPEROK($GET(TREE("wallpaper"))) IF VAL="" SET ERR("error")="wallpaper_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"wallpaper")=VAL
	IF $DATA(TREE("density")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$DENSITYOK($GET(TREE("density"))) IF VAL="" SET ERR("error")="density_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"density")=VAL
	IF $DATA(TREE("animations")) DO  QUIT:$GET(ERR("error"))'=""
	. SET VAL=$$ANIMOK($GET(TREE("animations"))) IF VAL="" SET ERR("error")="animations_invalid" QUIT
	. SET ^MIO("MIOMOS","PREF",USER,"animations")=VAL
	IF $DATA(TREE("icons")) DO
	. FOR APP="workspace","collaboration","security","admin","settings","terminal" DO
	. . IF '$DATA(TREE("icons",APP)) QUIT
	. . SET VAL=$$ICONTXT($GET(TREE("icons",APP)))
	. . IF VAL="" KILL ^MIO("MIOMOS","PREF",USER,"icon",APP) QUIT
	. . SET ^MIO("MIOMOS","PREF",USER,"icon",APP)=VAL
	IF $DATA(TREE("terminal")) DO  QUIT:$GET(ERR("error"))'=""
	. NEW TERM,TERMOUT
	. MERGE TERM=TREE("terminal")
	. IF '$$SAVEPROF^MIOMOSTERM(USER,.TERM,.TERMOUT,.ERR) QUIT
	IF $DATA(TREE("windowPreset"))!$DATA(TREE("snapMode"))!$DATA(TREE("motionProfile"))!$DATA(TREE("titlebarStyle")) DO  QUIT:$GET(ERR("error"))'=""
	. NEW WMOUT,WMERR
	. IF '$$SAVE^MIOMOSWM(USER,.TREE,.WMOUT,.WMERR) MERGE ERR=WMERR QUIT
	IF $DATA(TREE("shell")) DO  QUIT:$GET(ERR("error"))'=""
	. IF $DATA(TREE("shell","startMenuSection")) DO
	. . SET VAL=$$SHELLSECTIONOK($GET(TREE("shell","startMenuSection")),"") IF VAL="" SET ERR("error")="start_menu_section_invalid" QUIT
	. . SET ^MIO("MIOMOS","PREF",USER,"shell","startMenuSection")=VAL
	. IF $DATA(TREE("shell","showClockSeconds")) SET ^MIO("MIOMOS","PREF",USER,"shell","showClockSeconds")=+$GET(TREE("shell","showClockSeconds"))
	. IF $DATA(TREE("shell","showTrayLabels")) SET ^MIO("MIOMOS","PREF",USER,"shell","showTrayLabels")=+$GET(TREE("shell","showTrayLabels"))
	. IF $DATA(TREE("shell","chatRoom")) DO
	. . SET VAL=$$CHATROOMOK($GET(TREE("shell","chatRoom")),"") IF VAL="" SET ERR("error")="chat_room_invalid" QUIT
	. . SET ^MIO("MIOMOS","PREF",USER,"shell","chatRoom")=VAL
	. IF $DATA(TREE("shell","chatLimit")) DO
	. . SET VAL=$$CHATLIMIT(+$GET(TREE("shell","chatLimit"))) IF VAL<1 SET ERR("error")="chat_limit_invalid" QUIT
	. . SET ^MIO("MIOMOS","PREF",USER,"shell","chatLimit")=VAL
	. IF $DATA(TREE("shell","terminalLaunchMode")) DO
	. . SET VAL=$$LAUNCHMODEOK($GET(TREE("shell","terminalLaunchMode")),"") IF VAL="" SET ERR("error")="terminal_launch_mode_invalid" QUIT
	. . SET ^MIO("MIOMOS","PREF",USER,"shell","terminalLaunchMode")=VAL
	. IF $DATA(TREE("shell","quickLaunch")) DO
	. . SET VAL=$$QUICKCSV($GET(TREE("shell","quickLaunch")),"") IF VAL="" SET ERR("error")="quick_launch_invalid" QUIT
	. . SET ^MIO("MIOMOS","PREF",USER,"shell","quickLaunch")=VAL
	SET ^MIO("MIOMOS","PREF",USER,"savedAt")=$$NOWISO^MIOUTIL()
	DO CURRENT(USER,.OUT)
	QUIT 1
	;
CURRENT(USER,OUT)
	NEW STATE,CONF
	KILL OUT
	SET STATE("principal")=$GET(USER)
	SET CONF("miomos","theme","default")="midnight-professional"
	SET CONF("miomos","desktop","wallpaper")="midnight-clinic"
	SET CONF("miomos","desktop","density")="dense"
	DO LOAD(.STATE,.CONF)
	MERGE OUT("current")=STATE
	NEW THEME
	DO THEME^MIOMOSTH($GET(STATE("themeKey")),.THEME)
	MERGE OUT("current","theme")=THEME
	SET OUT("current","windowPreset")=$GET(STATE("windowPreset"))
	SET OUT("current","snapMode")=$GET(STATE("snapMode"))
	SET OUT("current","motionProfile")=$GET(STATE("motionProfile"))
	SET OUT("current","titlebarStyle")=$GET(STATE("titlebarStyle"))
	DO CATALOG($NAME(OUT("catalog")))
	QUIT
	;
PUTBOOT(ROOT,STATE,CONF)
	NEW CUR
	DO CURRENT($GET(STATE("principal")),.CUR)
	MERGE @ROOT@("current")=CUR("current")
	MERGE @ROOT@("catalog")=CUR("catalog")
	QUIT
	;
CATALOG(ROOT)
	KILL @ROOT
	DO CATALOG^MIOMOSTH($NAME(@ROOT@("themes")))
	DO OPTS($NAME(@ROOT@("fonts")),"Segoe UI^Segoe UI,Inter^Inter,IBM Plex Sans^IBM Plex Sans,JetBrains Mono^JetBrains Mono")
	DO INTOPTS($NAME(@ROOT@("fontSizes")),12,18)
	DO VALUEOPTS($NAME(@ROOT@("titleAccents")),"theme^Theme Accent^#5f8dff,blue^Blue^#5f8dff,teal^Teal^#14b8a6,violet^Violet^#8b5cf6,rose^Rose^#f43f5e,slate^Slate^#64748b,gold^Gold^#d4a514")
	DO OPTS($NAME(@ROOT@("iconStyles")),"glass^Glass,classic^Classic,minimal^Minimal,contrast^Contrast")
	DO OPTS($NAME(@ROOT@("densities")),"compact^Compact,dense^Dense,comfortable^Comfortable")
	DO OPTS($NAME(@ROOT@("wallpapers")),"midnight-clinic^Midnight Clinic,slate-grid^Slate Grid,aurora-blue^Aurora Blue,contrast-grid^Contrast Grid,soft-grid^Soft Grid")
	DO OPTS($NAME(@ROOT@("animations")),"off^Off,standard^Standard,full^Full")
	DO OPTS($NAME(@ROOT@("accessibilityPresets")),"balanced^Balanced,high-contrast^High Contrast,quiet-focus^Quiet Focus,large-text^Large Text")
	DO CATALOG^MIOMOSTERM($NAME(@ROOT@("terminal")))
	DO CATALOG^MIOMOSWM($NAME(@ROOT@("windowManager")))
	DO SHELLCAT($NAME(@ROOT@("shell")))
	QUIT
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
	;
VALUEOPTS(ROOT,CSV)
	NEW I,N,ITEM
	KILL @ROOT
	SET N=0
	FOR I=1:1:$LENGTH($GET(CSV),",") DO
	. SET ITEM=$PIECE(CSV,",",I)
	. IF ITEM="" QUIT
	. SET N=N+1
	. SET @ROOT@(N,"key")=$PIECE(ITEM,"^",1)
	. SET @ROOT@(N,"label")=$PIECE(ITEM,"^",2)
	. SET @ROOT@(N,"value")=$PIECE(ITEM,"^",3)
	QUIT
	;
INTOPTS(ROOT,START,STOP)
	NEW N,V
	KILL @ROOT
	SET N=0
	FOR V=+START:1:+STOP DO
	. SET N=N+1
	. SET @ROOT@(N,"key")=V
	. SET @ROOT@(N,"label")=V_" px"
	QUIT
	;
SHELLCAT(ROOT)
	KILL @ROOT
	DO OPTS($NAME(@ROOT@("startMenuSections")),"Pinned^Pinned,Directories^Directories,Applications^Applications,System^System")
	DO BOOL($NAME(@ROOT@("showClockSeconds")),"Show seconds","Hide seconds")
	DO BOOL($NAME(@ROOT@("showTrayLabels")),"Show tray labels","Hide tray labels")
	DO OPTS($NAME(@ROOT@("chatRooms")),"general^General,ops^Operations,admin^Admin")
	DO OPTS($NAME(@ROOT@("chatLimits")),"15^15 messages,20^20 messages,30^30 messages,50^50 messages")
	DO OPTS($NAME(@ROOT@("terminalLaunchModes")),"resume-last^Resume last session,new-session^Always new session,multi-session^Multi-session tabs")
	DO OPTS($NAME(@ROOT@("quickLaunchApps")),"workspace^Workspace,collaboration^Chat,terminal^Terminal,settings^Settings,security^Security,admin^Admin,ui-library^UI Library")
	QUIT
	;
BOOL(ROOT,ONLBL,OFFLBL)
	KILL @ROOT
	SET @ROOT@(1,"key")=1,@ROOT@(1,"label")=$GET(ONLBL,"On")
	SET @ROOT@(2,"key")=0,@ROOT@(2,"label")=$GET(OFFLBL,"Off")
	QUIT
	;
FONTOK(X)
	SET X=$$TRIM^MIOUTIL($GET(X))
	IF X="Segoe UI" QUIT X
	IF X="Inter" QUIT X
	IF X="IBM Plex Sans" QUIT X
	IF X="JetBrains Mono" QUIT X
	QUIT ""
	;
FONTSIZE(N)
	IF N<12 QUIT 0
	IF N>18 QUIT 0
	QUIT N
	;
TITLEOK(X)
	SET X=$$TRIM^MIOUTIL($GET(X))
	IF X="theme"!(X="blue")!(X="teal")!(X="violet")!(X="rose")!(X="slate")!(X="gold") QUIT X
	QUIT ""
	;
TITLEVAL(KEY,THEME)
	IF $GET(KEY)="theme" QUIT $GET(THEME("accent"),"#5f8dff")
	IF KEY="blue" QUIT "#5f8dff"
	IF KEY="teal" QUIT "#14b8a6"
	IF KEY="violet" QUIT "#8b5cf6"
	IF KEY="rose" QUIT "#f43f5e"
	IF KEY="slate" QUIT "#64748b"
	IF KEY="gold" QUIT "#d4a514"
	QUIT $GET(THEME("accent"),"#5f8dff")
	;
ICONSTYLEOK(X)
	SET X=$$TRIM^MIOUTIL($GET(X))
	IF X="glass"!(X="classic")!(X="minimal")!(X="contrast") QUIT X
	QUIT ""
	;
WALLPAPEROK(X)
	SET X=$$TRIM^MIOUTIL($GET(X))
	IF X="midnight-clinic"!(X="slate-grid")!(X="aurora-blue")!(X="contrast-grid")!(X="soft-grid") QUIT X
	QUIT ""
	;
DENSITYOK(X)
	SET X=$$TRIM^MIOUTIL($GET(X))
	IF X="compact"!(X="dense")!(X="comfortable") QUIT X
	QUIT ""
	;

ANIMLOAD(X)
	SET X=$$TRIM^MIOUTIL($GET(X))
	IF X="reduced" QUIT "standard"
	IF X="" QUIT "standard"
	QUIT $$ANIMOK(X)
	;
ANIMOK(X)
	SET X=$$TRIM^MIOUTIL($GET(X))
	IF X="full"!(X="standard")!(X="off") QUIT X
	QUIT ""
	;
ICONTXT(X)
	SET X=$$TRIM^MIOUTIL($GET(X))
	IF $LENGTH(X)>3 SET X=$EXTRACT(X,1,3)
	QUIT X
	;
ICONSTYLE(STYLE,APP)
	NEW D
	IF $GET(STYLE)="classic" DO  QUIT D
	. IF APP="workspace" SET D="[]" QUIT
	. IF APP="collaboration" SET D="CH" QUIT
	. IF APP="security" SET D="SC" QUIT
	. IF APP="admin" SET D="AD" QUIT
	. IF APP="settings" SET D="ST" QUIT
	. IF APP="terminal" SET D="TR" QUIT
	IF $GET(STYLE)="minimal" DO  QUIT D
	. IF APP="workspace" SET D="W" QUIT
	. IF APP="collaboration" SET D="C" QUIT
	. IF APP="security" SET D="S" QUIT
	. IF APP="admin" SET D="A" QUIT
	. IF APP="settings" SET D="T" QUIT
	. IF APP="terminal" SET D="R" QUIT
	IF $GET(STYLE)="contrast" DO  QUIT D
	. IF APP="workspace" SET D="#" QUIT
	. IF APP="collaboration" SET D="@" QUIT
	. IF APP="security" SET D="!" QUIT
	. IF APP="admin" SET D="+" QUIT
	. IF APP="settings" SET D="=" QUIT
	. IF APP="terminal" SET D=">_" QUIT
	IF APP="workspace" QUIT "W"
	IF APP="collaboration" QUIT "C"
	IF APP="security" QUIT "S"
	IF APP="admin" QUIT "A"
	IF APP="settings" QUIT "T"
	IF APP="terminal" QUIT ">_"
	QUIT "?"
	;
FONTSCALE(SIZE)
	IF +$GET(SIZE)'>12 QUIT "is-tight"
	IF +$GET(SIZE)'<15 QUIT "is-large"
	QUIT "is-normal"
	;
	;
SHELLSECTIONOK(X,DEF)
	SET X=$$TRIM^MIOUTIL($GET(X))
	IF X="Pinned"!(X="Directories")!(X="Applications")!(X="System") QUIT X
	QUIT $GET(DEF)
	;
CHATROOMOK(X,DEF)
	SET X=$$TRIM^MIOUTIL($GET(X))
	IF X="general"!(X="ops")!(X="admin") QUIT X
	QUIT $GET(DEF)
	;
CHATLIMIT(N)
	IF N<1 QUIT 20
	IF N>100 QUIT 100
	QUIT N
	;
LAUNCHMODEOK(X,DEF)
	SET X=$$TRIM^MIOUTIL($GET(X))
	IF X="resume-last"!(X="new-session")!(X="multi-session") QUIT X
	QUIT $GET(DEF)
	;
QUICKCSV(X,DEF)
	NEW OUT,I,APP,VAL,USED,CNT
	SET X=$$TRIM^MIOUTIL($GET(X))
	IF X="" SET X=$GET(DEF)
	SET OUT="",CNT=0
	FOR I=1:1:$LENGTH(X,",") DO  QUIT:CNT>3
	. SET APP=$$TRIM^MIOUTIL($PIECE(X,",",I))
	. SET VAL=$$QUICKAPP(APP)
	. IF VAL="" QUIT
	. IF $DATA(USED(VAL)) QUIT
	. SET USED(VAL)=1,CNT=CNT+1
	. SET OUT=OUT_$SELECT(OUT'="":",",1:"")_VAL
	IF OUT="" QUIT $GET(DEF)
	QUIT OUT
	;
QUICKAPP(X)
	SET X=$$TRIM^MIOUTIL($GET(X))
	IF X="workspace"!(X="collaboration")!(X="terminal")!(X="settings")!(X="security")!(X="admin")!(X="ui-library") QUIT X
	QUIT ""
	;
