MIOOSTH ; MIOOS theme persistence and SSR helpers
	QUIT
	;
ROOT(USER)
	NEW NAME
	SET NAME=$SELECT($GET(USER)'="":$GET(USER),1:"guest")
	QUIT $NAME(^MIO("MIOOS","PREF",NAME,"theme"))
	;
DEFAULTKEY(CONF)
	QUIT $SELECT($GET(CONF("mioos","desktop","theme"))'="":$GET(CONF("mioos","desktop","theme")),1:"xp-classic-blue")
	;
MAPID(KEY)
	NEW ID
	SET ID=$SELECT($GET(KEY)="xp-classic-blue":"vintage",$GET(KEY)="win7-aero":"glow",$GET(KEY)="mac-slate":"curve",$GET(KEY)="ubuntu-amber":"panel",1:"")
	QUIT ID
	;
MAPKEY(ID,BASE)
	NEW KEY
	SET KEY=$SELECT($GET(ID)="vintage":"xp-classic-blue",$GET(ID)="glow":"win7-aero",$GET(ID)="curve":"mac-slate",$GET(ID)="panel":"ubuntu-amber",1:"")
	IF KEY'="" QUIT KEY
	SET KEY=$SELECT($GET(BASE)="xp":"xp-classic-blue",$GET(BASE)="mac":"mac-slate",$GET(BASE)="ubuntu":"ubuntu-amber",1:"win7-aero")
	QUIT KEY
	;
LOAD(STATE,CONF)
	NEW USER,ROOTREF
	SET USER=$SELECT($GET(STATE("principal"))'="":$GET(STATE("principal")),1:"guest")
	SET ROOTREF=$$ROOT(USER)
	SET STATE("themeKey")=$SELECT($GET(@ROOTREF@("themeKey"))'="":$GET(@ROOTREF@("themeKey")),1:$$DEFAULTKEY(.CONF))
	KILL STATE("themeProfile")
	SET STATE("themeProfileLoaded")=0
	IF $DATA(@ROOTREF@("profile"))>1 DO
	. MERGE STATE("themeProfile")=@ROOTREF@("profile")
	. SET STATE("themeProfileLoaded")=1
	IF $GET(STATE("themeProfile","id"))="" SET STATE("themeProfile","id")=$$MAPID($GET(STATE("themeKey")))
	IF $GET(STATE("themeProfile","base"))="" SET STATE("themeProfile","base")=$$BASE($GET(STATE("themeProfile","id")),$GET(STATE("themeKey")))
	QUIT:$QUIT 1
	QUIT
	;
SAVE(STATE,CONF,TREE,OUT,ERR)
	NEW USER,ROOTREF,KEY,ID,BASE
	KILL ERR,OUT
	SET ERR("routine")="MIOOSTH"
	SET USER=$SELECT($GET(STATE("principal"))'="":$GET(STATE("principal")),1:"guest")
	IF USER="" SET ERR("error")="principal_missing" QUIT 0
	SET ID=$GET(TREE("theme","id"))
	SET BASE=$GET(TREE("theme","base"))
	SET KEY=$SELECT($GET(TREE("themeKey"))'="":$GET(TREE("themeKey")),1:$$MAPKEY(ID,BASE))
	IF KEY="" SET KEY=$$DEFAULTKEY(.CONF)
	SET ROOTREF=$$ROOT(USER)
	KILL @ROOTREF
	SET @ROOTREF@("themeKey")=KEY
	SET @ROOTREF@("savedAt")=$$NOWISO^MIOUTIL()
	MERGE @ROOTREF@("profile")=TREE("theme")
	SET @ROOTREF@("profile","id")=$SELECT($GET(@ROOTREF@("profile","id"))'="":$GET(@ROOTREF@("profile","id")),1:$$MAPID(KEY))
	SET @ROOTREF@("profile","base")=$SELECT($GET(@ROOTREF@("profile","base"))'="":$GET(@ROOTREF@("profile","base")),1:$$BASE($GET(@ROOTREF@("profile","id")),KEY))
	MERGE STATE("themeProfile")=@ROOTREF@("profile")
	SET STATE("themeProfileLoaded")=1
	SET STATE("themeKey")=KEY
	DO DESCRIBE(.STATE,.OUT)
	SET OUT("saved")=1
	SET OUT("user")=USER
	QUIT 1
	;
LOADCMD(STATE,CONF,OUT,ERR)
	KILL ERR,OUT
	SET ERR("routine")="MIOOSTH"
	DO LOAD(.STATE,.CONF)
	DO DESCRIBE(.STATE,.OUT)
	SET OUT("loaded")=1
	QUIT 1
	;
DESCRIBE(STATE,OUT)
	KILL OUT("current")
	MERGE OUT("current")=STATE("themeProfile")
	SET OUT("themeKey")=$GET(STATE("themeKey"))
	SET OUT("themeRootClass")=$$ROOTCLASS(.STATE)
	SET OUT("themeBase")=$$ATTR(.STATE,"base")
	SET OUT("themeTaskbarPosition")=$$ATTR(.STATE,"taskbarPosition")
	SET OUT("themeTaskbarButtonStyle")=$$ATTR(.STATE,"taskbarButtonStyle")
	SET OUT("themeStartMenuStyle")=$$ATTR(.STATE,"startMenuStyle")
	SET OUT("themeBootCss")=$$BOOTCSS(.STATE)
	QUIT
	;
DESKDATA(STATE,DATA)
	SET DATA("themeRootClass")=$$ROOTCLASS(.STATE)
	SET DATA("themeBase")=$$ATTR(.STATE,"base")
	SET DATA("themeTaskbarPosition")=$$ATTR(.STATE,"taskbarPosition")
	SET DATA("themeTaskbarButtonStyle")=$$ATTR(.STATE,"taskbarButtonStyle")
	SET DATA("themeStartMenuStyle")=$$ATTR(.STATE,"startMenuStyle")
	SET DATA("themeBootCss")=$$BOOTCSS(.STATE)
	QUIT
	;
BASE(ID,KEY)
	NEW OUT
	SET OUT=$SELECT($GET(ID)="vintage":"xp",$GET(ID)="curve":"mac",$GET(ID)="panel":"ubuntu",$GET(ID)="glow":"win7",1:"")
	IF OUT'="" QUIT OUT
	SET OUT=$SELECT($GET(KEY)="xp-classic-blue":"xp",$GET(KEY)="mac-slate":"mac",$GET(KEY)="ubuntu-amber":"ubuntu",1:"win7")
	QUIT OUT
	;
ATTR(STATE,NAME)
	NEW ROOT
	SET ROOT=$NAME(STATE("themeProfile"))
	IF '$DATA(@ROOT) QUIT $SELECT($GET(NAME)="base":$$BASE("",$GET(STATE("themeKey"))),$GET(NAME)="taskbarPosition":"bottom",$GET(NAME)="taskbarButtonStyle":"xp",$GET(NAME)="startMenuStyle":"classic",1:"")
	IF $GET(NAME)="base" QUIT $SELECT($GET(@ROOT@("base"))'="":$GET(@ROOT@("base")),1:$$BASE($GET(@ROOT@("id")),$GET(STATE("themeKey"))))
	IF $GET(NAME)="taskbarPosition" QUIT $SELECT($GET(@ROOT@("taskbarConfig","position"))'="":$GET(@ROOT@("taskbarConfig","position")),1:"bottom")
	IF $GET(NAME)="taskbarButtonStyle" QUIT $SELECT($GET(@ROOT@("taskbarConfig","buttonStyle"))'="":$GET(@ROOT@("taskbarConfig","buttonStyle")),1:"xp")
	IF $GET(NAME)="startMenuStyle" QUIT $SELECT($GET(@ROOT@("startMenuConfig","style"))'="":$GET(@ROOT@("startMenuConfig","style")),1:"classic")
	QUIT ""
	;
ROOTCLASS(STATE)
	NEW ROOT,CLS,BASE,NAME
	SET CLS=""
	SET ROOT=$NAME(STATE("themeProfile"))
	SET BASE=$$ATTR(.STATE,"base")
	IF $DATA(@ROOT)>1 DO
	. IF +$GET(@ROOT@("darkEnabled"))=1 SET CLS=$$ADDCLS(CLS,"theme-dark-mode")
	SET CLS=$$ADDCLS(CLS,"theme-base-"_BASE)
	IF $DATA(@ROOT)>1 DO
	. SET NAME="" FOR  SET NAME=$ORDER(@ROOT@("classModifiers",NAME)) QUIT:NAME=""  DO
	. . SET CLS=$$ADDCLS(CLS,"theme-mod-"_$$CLASSSAFE($GET(@ROOT@("classModifiers",NAME))))
	QUIT CLS
	;
ADDCLS(CLS,NAME)
	IF $GET(NAME)="" QUIT $GET(CLS)
	IF $GET(CLS)="" QUIT NAME
	QUIT CLS_" "_NAME
	;
CLASSSAFE(NAME)
	NEW OUT,I,CH
	SET OUT=""
	FOR I=1:1:$LENGTH($GET(NAME)) DO
	. SET CH=$EXTRACT($GET(NAME),I)
	. IF CH?1AN SET OUT=OUT_CH QUIT
	. IF CH="-"!(CH="_") SET OUT=OUT_CH QUIT
	. SET OUT=OUT_"-"
	QUIT $$LOW^MIOUTIL(OUT)
	;
BOOTCSS(STATE)
	NEW ROOT,BUF,KEY,VAL,HEIGHT,MWIDTH,IFONT,TSTYLE,LPAPER,DPAPER,BG,TXT
	SET ROOT=$NAME(STATE("themeProfile"))
	IF $DATA(@ROOT)'>1 QUIT ""
	SET TXT="#mioosRoot{"
	SET KEY="" FOR  SET KEY=$ORDER(@ROOT@("cssVars",KEY)) QUIT:KEY=""  DO
	. SET VAL=$GET(@ROOT@("cssVars",KEY))
	. IF VAL'="" SET TXT=TXT_KEY_":"_VAL_";"
	SET IFONT=$GET(@ROOT@("fontStack")) IF IFONT'="" SET TXT=TXT_"--font-ui:"_IFONT_";"
	SET HEIGHT=+$GET(@ROOT@("taskbarConfig","height")) IF HEIGHT>0 SET TXT=TXT_"--taskbar-height:"_HEIGHT_"px;"
	SET MWIDTH=+$GET(@ROOT@("startMenuConfig","width")) IF MWIDTH>0 SET TXT=TXT_"--start-menu-width:"_MWIDTH_"px;"
	SET TSTYLE=$GET(@ROOT@("startMenuConfig","accentColor")) IF TSTYLE'="" SET TXT=TXT_"--start-menu-accent:"_TSTYLE_";"
	SET DPAPER=$$WALLPAPER($GET(@ROOT@("wallpaperPreset")),$GET(@ROOT@("wallpaperUrl")))
	IF DPAPER'="" SET TXT=TXT_"--desktop-wallpaper:"_DPAPER_";"
	SET LPAPER=$$WALLPAPER($GET(@ROOT@("loginScreenConfig","wallpaperPreset")),$GET(@ROOT@("loginScreenConfig","wallpaperUrl")))
	IF LPAPER="" SET LPAPER=DPAPER
	IF LPAPER'="" SET TXT=TXT_"--login-wallpaper:"_LPAPER_";"
	SET TXT=TXT_"}"
	SET BG=$GET(@ROOT@("cssVars","--desktop-bg"))
	IF BG'="" SET TXT=TXT_"body{background:"_BG_";}"
	QUIT TXT
	;
WALLPAPER(PRESET,URL)
	NEW OUT
	SET PRESET=$GET(PRESET)
	IF (PRESET="custom-upload")!(PRESET="custom-url") DO  QUIT OUT
	. SET OUT=$SELECT($GET(URL)'="":"url("_$GET(URL)_")",1:"")
	IF PRESET="meadow" QUIT "linear-gradient(180deg, rgba(255,255,255,0.14) 0%, rgba(255,255,255,0) 28%), linear-gradient(180deg, #8acb59 0%, #6fb14a 42%, #3e7b35 100%)"
	IF PRESET="aurora" QUIT "radial-gradient(circle at top, rgba(147,197,253,0.26), transparent 30%), linear-gradient(180deg, #16385c 0%, #23476d 36%, #3a6288 100%)"
	IF PRESET="graphite" QUIT "linear-gradient(180deg, #6c7a89 0%, #313b48 100%)"
	IF PRESET="ember" QUIT "linear-gradient(180deg, #6e2d35 0%, #2d2c54 100%)"
	QUIT ""
	;