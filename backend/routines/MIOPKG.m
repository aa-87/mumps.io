MIOPKG ; Package catalog and index.;
; API STABILITY
; Public API labels are documented in docs/routines.;
; Undocumented labels are internal.;
;
; PURPOSE
; Maintain a package catalog in globals.;
; Support version history per package.;
; Build indexes for browsing.;
;
; PUBLIC ENTRY POINTS
; ENSURE   - Ensure catalog is ready.;
; LOAD     - Load catalog from JSON file.;
; REIDX    - Rebuild indexes from latest versions.;
; PUBLISH  - Publish a new version record and update latest.;
; UPSERT   - Upsert latest package metadata (admin use).;
; DELETE   - Remove a package.;
; GETVER   - Get a specific version into OUT.;
; LISTVERS - List versions for a slug.;
; LATEST   - Get latest version string.;
; LISTCATS - List categories.;
; LISTTAGS - List tags.;
	;
ENSURE(CONF) ;
	IF $GET(^MIO("PKG","READY"))=1 QUIT
	DO LOAD(.CONF)
	QUIT
	;
LOAD(CONF) ;
	NEW PATH SET PATH="data/packages.json"
	IF $DATA(CONF("packages","catalogPath")) SET PATH=CONF("packages","catalogPath")
	;
	NEW LINES,ERR
	IF '$$READFILE^MIOUTIL(PATH,.LINES,.ERR) DO  QUIT
	. SET ^MIO("PKG","READY")=0
	;
	NEW JSON,I SET JSON="",I=0
	FOR  SET I=$ORDER(LINES(I)) QUIT:I=""  SET JSON=JSON_LINES(I)_$C(10)
	;
	NEW OBJ
	IF '$$DECODE^MIOJSON(.JSON,.OBJ,.ERR) DO  QUIT
	. SET ^MIO("PKG","READY")=0
	;
	KILL ^MIO("PKG")
	NEW P SET P=0
	FOR  SET P=$ORDER(OBJ("packages",P)) QUIT:P=""  DO
	. NEW SLUG SET SLUG=$GET(OBJ("packages",P,"slug")) IF SLUG="" QUIT
	. NEW PKG KILL PKG
	. NEW KEY FOR KEY="slug","name","category","version","license","maintainer","summary","description","install","docsUrl","repoUrl","tier","price","downloads","featured","updatedMs" DO
	. . SET PKG(KEY)=$GET(OBJ("packages",P,KEY))
	. IF $GET(PKG("tier"))="" SET PKG("tier")="community"
	. IF $GET(PKG("price"))="" SET PKG("price")=$SELECT($$LC^MIOUTIL(PKG("tier"))="pro":"$29/mo",1:"Free")
	. IF $GET(PKG("downloads"))="" SET PKG("downloads")=0
	. IF $GET(PKG("featured"))="" SET PKG("featured")=0
	. IF $GET(PKG("updatedMs"))="" SET PKG("updatedMs")=$$EPOCHMS^MIOUTIL()
	. NEW T SET T=""
	. FOR  SET T=$ORDER(OBJ("packages",P,"tags",T)) QUIT:T=""  DO
	. . SET PKG("tags",T)=$GET(OBJ("packages",P,"tags",T))
	. DO PUBLISH(.PKG,.ERR)
	;
	DO REIDX
	SET ^MIO("PKG","READY")=1
	QUIT
	;
REIDX ;
	KILL ^MIO("PKG","IDX")
	NEW SLUG SET SLUG=""
	FOR  SET SLUG=$ORDER(^MIO("PKG","ITEM",SLUG)) QUIT:SLUG=""  DO
	. SET ^MIO("PKG","IDX","ALL",SLUG)=1
	. NEW CAT SET CAT=$GET(^MIO("PKG","ITEM",SLUG,"category"))
	. IF CAT'="" SET ^MIO("PKG","IDX","CAT",CAT,SLUG)=1
	. NEW TIER SET TIER=$$LC^MIOUTIL($GET(^MIO("PKG","ITEM",SLUG,"tier")))
	. IF TIER'="" SET ^MIO("PKG","IDX","TIER",TIER,SLUG)=1
	. NEW TAG SET TAG=""
	. FOR  SET TAG=$ORDER(^MIO("PKG","ITEM",SLUG,"tag",TAG)) QUIT:TAG=""  SET ^MIO("PKG","IDX","TAG",TAG,SLUG)=1
	. IF +$GET(^MIO("PKG","ITEM",SLUG,"featured"))=1 SET ^MIO("PKG","IDX","FEATURED",SLUG)=1
	QUIT
	;
PUBLISH(PKG,ERR) ;
	KILL ERR
	NEW SLUG,VER SET SLUG=$GET(PKG("slug")),VER=$GET(PKG("version"))
	IF SLUG="" SET ERR("error")="missing_slug" QUIT 0
	IF VER="" SET ERR("error")="missing_version" QUIT 0
	;
	KILL ^MIO("PKG","VER",SLUG,VER)
	NEW KEY FOR KEY="name","category","version","license","maintainer","summary","description","install","docsUrl","repoUrl","tier","price","downloads","featured","updatedMs" DO
	. IF $DATA(PKG(KEY)) SET ^MIO("PKG","VER",SLUG,VER,KEY)=PKG(KEY)
	;
	KILL ^MIO("PKG","VER",SLUG,VER,"tag")
	NEW I,T
	IF $DATA(PKG("tags")) DO
	. SET I=0
	. FOR  SET I=$ORDER(PKG("tags",I)) QUIT:I=""  DO
	. . SET T=$$LC^MIOUTIL($GET(PKG("tags",I)))
	. . IF T'="" SET ^MIO("PKG","VER",SLUG,VER,"tag",T)=1
	ELSE  IF $DATA(PKG("tag")) DO
	. SET T=""
	. FOR  SET T=$ORDER(PKG("tag",T)) QUIT:T=""  SET ^MIO("PKG","VER",SLUG,VER,"tag",$$LC^MIOUTIL(T))=1
	;
	NEW CUR SET CUR=$GET(^MIO("PKG","LATEST",SLUG))
	IF CUR=""!($$CMP^MIOSEMVER(VER,CUR)=1) DO
	. SET ^MIO("PKG","LATEST",SLUG)=VER
	. DO APPLYLATEST(SLUG,VER)
	;
	SET ^MIO("PKG","VERS",SLUG,VER)=1
	;
	DO REIDX
	SET ^MIO("PKG","READY")=1
	QUIT 1
	;
APPLYLATEST(SLUG,VER) ;
	KILL ^MIO("PKG","ITEM",SLUG)
	SET ^MIO("PKG","ITEM",SLUG,"slug")=SLUG
	NEW KEY
	FOR KEY="name","category","version","license","maintainer","summary","description","install","docsUrl","repoUrl","tier","price","downloads","featured","updatedMs" DO
	. SET ^MIO("PKG","ITEM",SLUG,KEY)=$GET(^MIO("PKG","VER",SLUG,VER,KEY))
	KILL ^MIO("PKG","ITEM",SLUG,"tag")
	NEW T SET T=""
	FOR  SET T=$ORDER(^MIO("PKG","VER",SLUG,VER,"tag",T)) QUIT:T=""  SET ^MIO("PKG","ITEM",SLUG,"tag",T)=1
	QUIT
	;
UPSERT(PKG,ERR) ;
	KILL ERR
	NEW SLUG SET SLUG=$GET(PKG("slug"))
	IF SLUG="" SET ERR("error")="missing_slug" QUIT 0
	KILL ^MIO("PKG","ITEM",SLUG)
	SET ^MIO("PKG","ITEM",SLUG,"slug")=SLUG
	NEW KEY FOR KEY="name","category","version","license","maintainer","summary","description","install","docsUrl","repoUrl","tier","price","downloads","featured","updatedMs" DO
	. IF $DATA(PKG(KEY)) SET ^MIO("PKG","ITEM",SLUG,KEY)=PKG(KEY)
	KILL ^MIO("PKG","ITEM",SLUG,"tag")
	NEW I,T
	IF $DATA(PKG("tags")) DO
	. SET I=0
	. FOR  SET I=$ORDER(PKG("tags",I)) QUIT:I=""  DO
	. . SET T=$$LC^MIOUTIL($GET(PKG("tags",I)))
	. . IF T'="" SET ^MIO("PKG","ITEM",SLUG,"tag",T)=1
	DO REIDX
	SET ^MIO("PKG","READY")=1
	QUIT 1
	;
DELETE(SLUG,ERR) ;
	KILL ERR
	IF SLUG="" SET ERR("error")="missing_slug" QUIT 0
	KILL ^MIO("PKG","ITEM",SLUG)
	KILL ^MIO("PKG","VER",SLUG)
	KILL ^MIO("PKG","VERS",SLUG)
	KILL ^MIO("PKG","LATEST",SLUG)
	DO REIDX
	QUIT 1
	;
GETVER(SLUG,VER,OUT,ERR) ;
	KILL OUT,ERR
	IF SLUG="" SET ERR("error")="missing_slug" QUIT 0
	IF VER="" SET ERR("error")="missing_version" QUIT 0
	IF '$DATA(^MIO("PKG","VER",SLUG,VER)) SET ERR("error")="not_found" QUIT 0
	NEW KEY
	SET OUT("slug")=SLUG
	FOR KEY="name","category","version","license","maintainer","summary","description","install","docsUrl","repoUrl","tier","price","downloads","featured","updatedMs" DO
	. SET OUT(KEY)=$GET(^MIO("PKG","VER",SLUG,VER,KEY))
	NEW T,I SET T="",I=0
	FOR  SET T=$ORDER(^MIO("PKG","VER",SLUG,VER,"tag",T)) QUIT:T=""  DO
	. SET I=I+1
	. SET OUT("tags",I)=T
	QUIT 1
	;
LISTVERS(SLUG,OUT) ;
	KILL OUT
	NEW V SET V="",I=0
	NEW ORDER
	FOR  SET V=$ORDER(^MIO("PKG","VERS",SLUG,V)) QUIT:V=""  DO
	. SET ORDER($$NORM^MIOSEMVER(V),V)=1
	NEW K SET K=""
	FOR  SET K=$ORDER(ORDER(K),-1) QUIT:K=""  DO
	. NEW V2 SET V2=""
	. FOR  SET V2=$ORDER(ORDER(K,V2)) QUIT:V2=""  DO
	. . SET I=I+1
	. . SET OUT(I)=V2
	QUIT
	;
LATEST(SLUG) ;
	QUIT $GET(^MIO("PKG","LATEST",SLUG))
	;
LISTCATS(OUT) ;
	NEW CAT SET CAT="",I=0
	FOR  SET CAT=$ORDER(^MIO("PKG","IDX","CAT",CAT)) QUIT:CAT=""  DO
	. SET I=I+1
	. SET OUT(I)=CAT
	QUIT
	;
LISTTAGS(OUT,MAX) ;
	NEW TAG SET TAG="",I=0
	FOR  SET TAG=$ORDER(^MIO("PKG","IDX","TAG",TAG)) QUIT:TAG=""  DO  QUIT:($GET(MAX)>0)&(I'<MAX)
	. SET I=I+1
	. SET OUT(I)=TAG
	QUIT
	;