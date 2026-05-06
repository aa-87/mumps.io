MIOOSTHEME ; MIOOS globals-backed theme profiles
	QUIT
	;
USERKEY(STATE)
	NEW KEY
	SET KEY=$$TRIM^MIOUTIL($GET(STATE("principal")))
	IF KEY="" SET KEY=$$TRIM^MIOUTIL($GET(STATE("userName")))
	IF KEY="" SET KEY="guest"
	QUIT $$LOW^MIOUTIL(KEY)
	;
NEXTKEY(USER)
	NEW N
	SET N=$INCREMENT(^MIO("MIOOS","THEME","SEQ",$GET(USER)))
	QUIT "theme-"_N
	;

ACTIVE(STATE,OUT)
	NEW USER,KEY
	KILL OUT
	SET USER=$$USERKEY(.STATE)
	SET KEY=$GET(^MIO("MIOOS","THEME","ACTIVE",USER))
	IF KEY="" QUIT 0
	IF '$DATA(^MIO("MIOOS","THEME","PROFILE",USER,KEY)) QUIT 0
	MERGE OUT=^MIO("MIOOS","THEME","PROFILE",USER,KEY)
	SET OUT("key")=KEY
	QUIT 1
	;
LOAD(STATE,CONF,OUT,ERR)
	NEW USER,KEY,IDX,ACTIVE,REQKEY
	SET USER=$$USERKEY(.STATE)
	SET REQKEY=$GET(STATE("themeRequest","key"))
	KILL OUT
	SET OUT("ok")=1,OUT("user")=USER
	SET ACTIVE=$GET(^MIO("MIOOS","THEME","ACTIVE",USER))
	IF ACTIVE'="",+$GET(STATE("authenticated")),$DATA(^MIO("MIOOS","THEME","PROFILE",USER,ACTIVE)) DO PUBLOGIN(.STATE,USER,ACTIVE,$NAME(^MIO("MIOOS","THEME","PROFILE",USER,ACTIVE)))
	SET OUT("activeKey")=ACTIVE
	IF REQKEY="" SET REQKEY=ACTIVE
	IF REQKEY'="",$DATA(^MIO("MIOOS","THEME","PROFILE",USER,REQKEY)) DO
	. MERGE OUT("profile")=^MIO("MIOOS","THEME","PROFILE",USER,REQKEY)
	. SET OUT("profileKey")=REQKEY
	SET KEY="",IDX=0
	FOR  SET KEY=$ORDER(^MIO("MIOOS","THEME","PROFILE",USER,KEY)) QUIT:KEY=""  DO
	. SET IDX=IDX+1
	. SET OUT("profiles",IDX,"key")=KEY
	. SET OUT("profiles",IDX,"name")=$GET(^MIO("MIOOS","THEME","PROFILE",USER,KEY,"name"))
	. SET OUT("profiles",IDX,"family")=$GET(^MIO("MIOOS","THEME","PROFILE",USER,KEY,"family"))
	. SET OUT("profiles",IDX,"mode")=$GET(^MIO("MIOOS","THEME","PROFILE",USER,KEY,"mode"))
	. MERGE OUT("profiles",IDX,"data")=^MIO("MIOOS","THEME","PROFILE",USER,KEY)
	QUIT 1
	;
SAVE(STATE,CONF,IN,OUT,ERR)
	NEW USER,KEY,ACTIVATE,ROOT,WID
	SET USER=$$USERKEY(.STATE)
	SET KEY=$GET(IN("key"))
	IF KEY="" SET KEY=$$NEXTKEY(USER)
	SET ACTIVATE=+$GET(IN("activate"))
	SET ROOT=$NAME(^MIO("MIOOS","THEME","PROFILE",USER,KEY))
	KILL @ROOT
	IF $DATA(IN("profile")) MERGE @ROOT=IN("profile")
	ELSE  MERGE @ROOT=IN
	SET @ROOT@("key")=KEY
	DO MODEFIX(ROOT)
	SET WID=$$PROMOTEW(.STATE,.CONF,USER,KEY,ROOT,ACTIVATE)
	IF ACTIVATE DO
	. SET ^MIO("MIOOS","THEME","ACTIVE",USER)=KEY
	. DO PUBLOGIN(.STATE,USER,KEY,ROOT)
	KILL OUT
	SET OUT("ok")=1,OUT("saved")=1,OUT("key")=KEY,OUT("activeKey")=$GET(^MIO("MIOOS","THEME","ACTIVE",USER))
	IF WID'="" SET OUT("wallpaperId")=WID
	MERGE OUT("profile")=@ROOT
	QUIT 1
	;
DELETE(STATE,CONF,IN,OUT,ERR)
	NEW USER,KEY,ROOT,ACTIVE,PUBKEY,PID
	SET ERR("routine")="MIOOSTHEME"
	SET USER=$$USERKEY(.STATE),KEY=$GET(IN("key"))
	IF KEY="" SET KEY=$GET(STATE("themeRequest","key"))
	IF KEY="" SET ERR("error")="theme_key_missing" QUIT 0
	IF KEY="glow"!(KEY="vintage")!(KEY="curve")!(KEY="panel")!(KEY="windows-xp")!(KEY="windows-7")!(KEY="mac-os")!(KEY="ubuntu") SET ERR("error")="built_in_theme_locked" QUIT 0
	SET ROOT=$NAME(^MIO("MIOOS","THEME","PROFILE",USER,KEY))
	IF '$DATA(@ROOT) SET ERR("error")="theme_not_found" QUIT 0
	IF +$GET(@ROOT@("locked")) SET ERR("error")="built_in_theme_locked" QUIT 0
	SET ACTIVE=$GET(^MIO("MIOOS","THEME","ACTIVE",USER))
	SET PUBKEY=$GET(^MIO("MIOOS","THEME","PUBLIC","LOGIN","key"))
	KILL @ROOT
	IF ACTIVE=KEY KILL ^MIO("MIOOS","THEME","ACTIVE",USER)
	IF PUBKEY=KEY KILL ^MIO("MIOOS","THEME","PUBLIC","LOGIN"),^MIO("MIOOS","THEME","PUBLIC","LOGINUSER",USER)
	SET PID="" FOR  SET PID=$ORDER(^MIO("MIOOS","THEME","PUBLICASSET",PID)) QUIT:PID=""  IF $PIECE($GET(^MIO("MIOOS","THEME","PUBLICASSET",PID)),"^",3)=KEY KILL ^MIO("MIOOS","THEME","PUBLICASSET",PID)
	KILL OUT
	SET OUT("ok")=1,OUT("deleted")=1,OUT("key")=KEY,OUT("activeKey")=$GET(^MIO("MIOOS","THEME","ACTIVE",USER)),OUT("fallbackKey")="glow"
	QUIT 1
	;
MODEFIX(ROOT)
	NEW MODE,DEF,DARK
	SET MODE=$GET(@ROOT@("mode"))
	IF MODE="" SET MODE=$GET(@ROOT@("activeMode"))
	IF MODE="" SET MODE=$GET(@ROOT@("themeConfig","mode"))
	IF MODE="" SET MODE=$GET(@ROOT@("themeConfig","activeMode"))
	SET DEF=$GET(@ROOT@("defaultVariant"))
	IF DEF="" SET DEF=$GET(@ROOT@("themeConfig","defaultVariant"))
	SET DARK=+$GET(@ROOT@("themeConfig","darkEnabled"))
	IF MODE="",DEF="dark" SET MODE="dark"
	IF MODE="",DARK SET MODE="dark"
	IF MODE="" SET MODE="light"
	IF MODE'="dark" SET MODE="light"
	SET @ROOT@("mode")=MODE,@ROOT@("activeMode")=MODE,@ROOT@("defaultVariant")=MODE
	SET @ROOT@("themeConfig","mode")=MODE
	SET @ROOT@("themeConfig","activeMode")=MODE
	SET @ROOT@("themeConfig","defaultVariant")=MODE
	IF MODE="dark" SET @ROOT@("themeConfig","darkEnabled")=1
	IF MODE="dark",'$DATA(@ROOT@("variants","dark")),$DATA(@ROOT@("themeConfig","variants","dark")) MERGE @ROOT@("variants","dark")=@ROOT@("themeConfig","variants","dark")
	IF MODE="dark",'$DATA(@ROOT@("themeConfig","variants","dark")),$DATA(@ROOT@("variants","dark")) MERGE @ROOT@("themeConfig","variants","dark")=@ROOT@("variants","dark")
	IF MODE="dark",'$DATA(@ROOT@("variants","dark")) SET @ROOT@("variants","dark","mode")="dark"
	IF MODE="dark",'$DATA(@ROOT@("themeConfig","variants","dark")) SET @ROOT@("themeConfig","variants","dark","mode")="dark"
	QUIT
	;
ASSETID(ROOT)
	NEW A,URL
	SET A=$GET(@ROOT@("desktop","wallpaperAssetId"))
	IF A="" SET A=$GET(@ROOT@("wallpaperAssetId"))
	IF A="" SET A=$GET(@ROOT@("themeConfig","wallpaperAssetId"))
	IF A'="" QUIT A
	SET URL=$GET(@ROOT@("desktop","wallpaperUrl"))
	IF URL="" SET URL=$GET(@ROOT@("wallpaperUrl"))
	IF URL="" SET URL=$GET(@ROOT@("themeConfig","wallpaperUrl"))
	IF URL'["/api/mioos/theme-asset" QUIT ""
	SET A=$PIECE($PIECE(URL,"id=",2),"&",1)
	SET A=$PIECE(A,"#",1)
	QUIT A
	;
BLOBURL(STATE,ID)
	QUIT $GET(STATE("fsBlobPath"),"/api/mioos/fs/blob")_"?id="_$GET(ID)
	;
EXT(MIME,FN)
	NEW L,E
	SET L=$$LOW^MIOUTIL($GET(FN))
	IF L["." DO  QUIT E
	. SET E="."_$PIECE(L,".",$L(L,"."))
	. IF $L(E)>8 SET E=""
	. IF E="." SET E=""
	SET MIME=$$LOW^MIOUTIL($GET(MIME))
	IF MIME["png" QUIT ".png"
	IF MIME["jpeg" QUIT ".jpg"
	IF MIME["jpg" QUIT ".jpg"
	IF MIME["gif" QUIT ".gif"
	IF MIME["webp" QUIT ".webp"
	IF MIME["svg" QUIT ".svg"
	QUIT ".bin"
	;
SAFE(S)
	NEW I,C,A,O
	SET S=$GET(S),O=""
	FOR I=1:1:$L(S) DO
	. SET C=$E(S,I),A=$ASCII(C)
	. IF ((A>47)&(A<58))!((A>64)&(A<91))!((A>96)&(A<123))!(C="-")!(C="_") SET O=O_C
	IF O="" SET O="active"
	QUIT O
	;

ASSETURLID(URL)
	NEW ID
	SET URL=$GET(URL)
	IF URL'["/api/mioos/theme-asset" QUIT ""
	SET ID=$PIECE($PIECE(URL,"id=",2),"&",1)
	SET ID=$PIECE(ID,"#",1)
	QUIT ID
	;
PUBLOGIN(STATE,USER,KEY,ROOT)
	NEW PUB,UPUB,FIELD,URL,ID
	SET PUB=$NAME(^MIO("MIOOS","THEME","PUBLIC","LOGIN"))
	SET UPUB=$NAME(^MIO("MIOOS","THEME","PUBLIC","LOGINUSER",$GET(USER)))
	KILL @PUB,@UPUB
	DO PUBBASE(ROOT,PUB,USER,KEY)
	DO PUBLCFG(.STATE,ROOT,PUB,0)
	DO PUBBASE(ROOT,UPUB,USER,KEY)
	DO PUBLCFG(.STATE,ROOT,UPUB,1)
	FOR FIELD="wallpaperUrl","avatarUrl","warningImageUrl" DO
	. SET URL=$GET(@ROOT@("loginScreenConfig",FIELD))
	. SET ID=$$ASSETURLID(URL)
	. IF ID'="",$$SAFE(ID)=ID SET ^MIO("MIOOS","THEME","PUBLICASSET",ID)=USER_"^"_FIELD_"^"_KEY
	QUIT
	;
PUBBASE(ROOT,DEST,USER,KEY)
	NEW FIELD
	KILL @DEST
	SET @DEST@("owner")=USER,@DEST@("key")=KEY,@DEST@("publicLogin")=1
	FOR FIELD="id","name","family","base","mode","activeMode","defaultVariant","fontStack","density" SET @DEST@(FIELD)=$GET(@ROOT@(FIELD))
	IF $DATA(@ROOT@("cssVars")) MERGE @DEST@("cssVars")=@ROOT@("cssVars")
	IF $DATA(@ROOT@("themeConfig","cssVars")) MERGE @DEST@("themeConfig","cssVars")=@ROOT@("themeConfig","cssVars")
	QUIT
	;
PUBLCFG(STATE,ROOT,DEST,SPEC)
	NEW FIELD,SEC,URL,ID
	SET @DEST@("loginScreenConfig","publicLogin")=1
	FOR FIELD="loginBoxStyle","avatarSize","desktopWidth","mobileWidth","textColor","warningTitle","privacyNotice","disclaimer" SET @DEST@("loginScreenConfig",FIELD)=$GET(@ROOT@("loginScreenConfig",FIELD))
	SET @DEST@("loginScreenConfig","wallpaperUrl")=$$PUBURL(.STATE,$GET(@ROOT@("loginScreenConfig","wallpaperUrl")))
	IF +$GET(SPEC) DO
	. SET @DEST@("loginScreenConfig","avatarUrl")=$$PUBURL(.STATE,$GET(@ROOT@("loginScreenConfig","avatarUrl")))
	. SET ID=$$ASSETURLID($GET(@ROOT@("loginScreenConfig","avatarUrl"))) IF ID'="",$$SAFE(ID)=ID SET @DEST@("loginScreenConfig","avatarAssetId")=ID
	. SET @DEST@("loginScreenConfig","warningImageUrl")=$$PUBURL(.STATE,$GET(@ROOT@("loginScreenConfig","warningImageUrl")))
	. SET ID=$$ASSETURLID($GET(@ROOT@("loginScreenConfig","warningImageUrl"))) IF ID'="",$$SAFE(ID)=ID SET @DEST@("loginScreenConfig","warningImageAssetId")=ID
	ELSE  DO
	. SET @DEST@("loginScreenConfig","avatarUrl")=""
	. SET @DEST@("loginScreenConfig","avatarAssetId")=""
	. SET @DEST@("loginScreenConfig","warningImageUrl")=""
	. SET @DEST@("loginScreenConfig","warningImageAssetId")=""
	FOR SEC="loginBackground","loginCard","loginButton" IF $DATA(@ROOT@("customElementCss",SEC)) MERGE @DEST@("customElementCss",SEC)=@ROOT@("customElementCss",SEC)
	IF +$GET(SPEC) DO
	. FOR SEC="loginAvatar","loginNotice" IF $DATA(@ROOT@("customElementCss",SEC)) MERGE @DEST@("customElementCss",SEC)=@ROOT@("customElementCss",SEC)
	QUIT
	;
PUBURL(STATE,URL)
	NEW ID,ROUTE
	SET URL=$GET(URL)
	IF URL="" QUIT ""
	IF URL["data:" QUIT ""
	SET ID=$$ASSETURLID(URL)
	IF ID'="",$$SAFE(ID)=ID DO  QUIT ROUTE_"?id="_ID
	. SET ROUTE=$GET(STATE("themePublicAssetPath"),"/api/mioos/theme-public-asset")
	IF ID'="" QUIT ""
	IF URL["/api/mioos/theme-asset" QUIT ""
	IF URL["/api/mioos/fs/blob" QUIT ""
	QUIT URL
	;
LOGINPUBLIC(CONF,USER,OUT,ERR)
	KILL OUT
	SET OUT("ok")=1,OUT("stage")="password",OUT("loginThemeScope")="common-plus-login-specific",OUT("enumerationSafe")=1
	IF $DATA(^MIO("MIOOS","THEME","PUBLIC","LOGIN")) MERGE OUT("profile")=^MIO("MIOOS","THEME","PUBLIC","LOGIN")
	IF $GET(USER)'="",$DATA(^MIO("MIOOS","THEME","PUBLIC","LOGINUSER",USER)) DO
	. MERGE OUT("specificProfile")=^MIO("MIOOS","THEME","PUBLIC","LOGINUSER",USER)
	. MERGE OUT("profile")=^MIO("MIOOS","THEME","PUBLIC","LOGINUSER",USER)
	IF '$DATA(OUT("profile")) SET OUT("profile","publicLogin")=1,OUT("profile","loginScreenConfig","publicLogin")=1
	QUIT 1
	;
PUBLICLD(OUT)
	KILL OUT
	IF '$DATA(^MIO("MIOOS","THEME","PUBLIC","LOGIN")) QUIT 0
	MERGE OUT("profile")=^MIO("MIOOS","THEME","PUBLIC","LOGIN")
	SET OUT("ok")=1,OUT("profileKey")=$GET(^MIO("MIOOS","THEME","PUBLIC","LOGIN","key"))
	QUIT 1
	;
PUBLICAS(ID,USER,ROOT)
	NEW REC
	SET ID=$GET(ID)
	IF ID="" QUIT 0
	IF $$SAFE(ID)'=ID QUIT 0
	SET REC=$GET(^MIO("MIOOS","THEME","PUBLICASSET",ID))
	IF REC="" QUIT 0
	SET USER=$PIECE(REC,"^",1)
	IF USER="" QUIT 0
	SET ROOT=$NAME(^MIO("MIOOS","THEMEASSET",USER,$GET(ID)))
	QUIT $SELECT($GET(@ROOT@("META"))'="":1,1:0)
	;
PROMOTEW(STATE,CONF,USER,KEY,ROOT,ACTIVE)
	NEW ASSET,AROOT,META,MIME,FN,DESK,ID,NAME,NOW,OWNER,ROLES,CHUNK,IDX,CH,SIZE,U,SEG,BUF
	SET ASSET=$$ASSETID(ROOT)
	IF ASSET="" QUIT ""
	SET AROOT=$NAME(^MIO("MIOOS","THEMEASSET",USER,ASSET))
	SET META=$GET(@AROOT@("META"))
	IF META="",$GET(STATE("principal"))'="",$GET(STATE("principal"))'=USER DO
	. SET AROOT=$NAME(^MIO("MIOOS","THEMEASSET",$GET(STATE("principal")),ASSET))
	. SET META=$GET(@AROOT@("META"))
	IF META="" QUIT ""
	SET DESK=$$DESKTOPID^MIOOSFS()
	IF DESK="" QUIT ""
	SET MIME=$PIECE(META,"^",1) IF MIME="" SET MIME="application/octet-stream"
	SET FN=$PIECE(META,"^",2)
	SET NAME="mioos-wallpaper-"_$$SAFE(KEY)_$$EXT(MIME,FN)
	SET NOW=$HOROLOG,OWNER=$GET(STATE("principal"),"guest"),ROLES=$GET(STATE("roles"),"guest"),CHUNK=$$CHUNK^MIOOSFS(.CONF),U="^"
	SET ID=$GET(^MIO("MIOOS","FS","CHILD",DESK,NAME))
	IF ID'="",('$$EXISTS^MIOOSFS(ID)!($$FIELD^MIOOSFS(ID,1)'="file")) DO
	. KILL ^MIO("MIOOS","FS","CHILD",DESK,NAME)
	. SET ID=""
	IF ID="" DO
	. SET ID=$$NEXTID^MIOOSFS()
	. DO SAVEENTRY^MIOOSFS(ID,"file",DESK,NAME,MIME,0,NOW,NOW,OWNER,ROLES,1,1,1)
	. SET ^MIO("MIOOS","FS","CHILD",DESK,NAME)=ID
	KILL ^MIO("MIOOS","FS","DATA",ID),^MIO("MIOOS","FS","HASH",ID)
	DO SETCHUNK^MIOOSFS(ID,CHUNK)
	SET SIZE=0,IDX=0,SEG=0,BUF=""
	FOR  SET IDX=$ORDER(@AROOT@("DATA",IDX)) QUIT:IDX'>0  DO
	. SET CH=$GET(@AROOT@("DATA",IDX))
	. SET SIZE=SIZE+$ZLENGTH(CH),BUF=BUF_CH
	. FOR  QUIT:$ZLENGTH(BUF)<CHUNK  DO
	. . SET SEG=SEG+1
	. . SET ^MIO("MIOOS","FS","DATA",ID,SEG)=$ZEXTRACT(BUF,1,CHUNK)
	. . SET BUF=$ZEXTRACT(BUF,CHUNK+1,$ZLENGTH(BUF))
	IF SIZE=0 SET ^MIO("MIOOS","FS","DATA",ID,1)=""
	ELSE  IF BUF'="" SET SEG=SEG+1,^MIO("MIOOS","FS","DATA",ID,SEG)=BUF
	SET $PIECE(^MIO("MIOOS","FS","ENTRY",ID),U,1)="file"
	SET $PIECE(^MIO("MIOOS","FS","ENTRY",ID),U,2)=DESK
	SET $PIECE(^MIO("MIOOS","FS","ENTRY",ID),U,3)=NAME
	SET $PIECE(^MIO("MIOOS","FS","ENTRY",ID),U,4)=MIME
	SET $PIECE(^MIO("MIOOS","FS","ENTRY",ID),U,5)=SIZE
	SET $PIECE(^MIO("MIOOS","FS","ENTRY",ID),U,7)=NOW
	DO SETMETAFLD^MIOOSFS(ID,"hidden",1)
	DO SETMETAFLD^MIOOSFS(ID,"system",1)
	DO SETMETAFLD^MIOOSFS(ID,"themeWallpaper",1)
	DO SETMETAFLD^MIOOSFS(ID,"sourceAsset",ASSET)
	SET @ROOT@("desktop","wallpaperId")=ID
	SET @ROOT@("desktop","wallpaperUrl")=$$BLOBURL(.STATE,ID)_"&v="_$PIECE(NOW,",",1)_"-"_$PIECE(NOW,",",2)
	IF +$GET(ACTIVE) DO SETMETAFLD^MIOOSFS(DESK,"wallpaperId",ID)
	QUIT ID
