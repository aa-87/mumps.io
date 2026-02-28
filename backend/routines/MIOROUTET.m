MIOROUTET ; MIOROUTE test suite (router)
;
; Run:
;   YDB>D ^MIOROUTET
;
; Output:
;   Prints only FAIL lines. No output means pass.;
;
; Depends:
;   MIOROUTE, MIOTASSERT
;
; ---------------------------------------------------------------------
	DO T001
	DO T002
	DO T003
	DO T004
	DO T005
	DO T006
	DO T007
	DO T008
	DO T009
	DO T010
	DO T011
	DO T012
	DO T013
	DO T014
	DO T015
	DO T016
	DO T017
	DO T018
	DO T019
	DO T020
	DO T021
	DO T022
	DO T023
	DO T024
	DO T025
	DO T026
	DO T027
	DO T028
	DO T029
	DO T030
	DO T031
	DO T032
	DO T033
	DO T034
	DO T035
	DO T036
	DO T037
	DO T038
	QUIT
	;
; ---------------------------------------------------------------------
; helpers
	;
RESET ;
	KILL ^MIO("ROUTE")
	KILL ^MIO("CONF","server","routing")
	QUIT
	;
COMPILE ;
	DO COMPILE^MIOROUTE
	QUIT
	;
FILEHAS(PATH,NEED)
	NEW OK,LINE
	SET OK=0
	OPEN PATH:(readonly):1 ELSE  QUIT 0
	USE PATH
	FOR  READ LINE QUIT:$ZEOF  DO  QUIT:OK
	. IF LINE[NEED SET OK=1
	CLOSE PATH
	QUIT OK
	;
; Assert MATCH
AMATCH(DESC,METHOD,PATH,EXPOK,EXPH,EXPRP,EP) ;
	NEW P,H,RP,OK,KEY
	KILL P
	SET OK=$$MATCH^MIOROUTE($GET(METHOD),$GET(PATH),.P,.H,.RP)
	DO EQ^MIOTASSERT(+OK,+$GET(EXPOK),DESC_": ok")
	IF +$GET(EXPOK)'=1 QUIT
	DO EQ^MIOTASSERT($GET(H),$GET(EXPH),DESC_": handler")
	DO EQ^MIOTASSERT($GET(RP),$GET(EXPRP),DESC_": route")
	SET KEY=""
	FOR  SET KEY=$ORDER(EP(KEY)) QUIT:KEY=""  DO
	. DO EQ^MIOTASSERT($GET(P(KEY)),$GET(EP(KEY)),DESC_": param "_KEY)
	QUIT
	;
; ---------------------------------------------------------------------
; tests
	;
T001 ; INIT + compile + core matches
	DO RESET
	DO INIT^MIOROUTE
	DO COMPILE
	NEW EP
	KILL EP DO AMATCH("[T001][core][healthz]","GET","/healthz",1,"HEALTH^MIOROUTE","/healthz",.EP)
	KILL EP DO AMATCH("[T001][core][ping]","GET","/api/ping",1,"PING^MIOROUTE","/api/ping",.EP)
	KILL EP DO AMATCH("[T001][core][ws GET]","GET","/ws",1,"WS^MIOROUTE","/ws",.EP)
	KILL EP DO AMATCH("[T001][core][ws WS]","WS","/ws",1,"ACCEPT^MIOWS","/ws",.EP)
	QUIT
	;
T002 ; NORM default: ignoreTrailingSlash=1
	DO RESET
	DO EQ^MIOTASSERT($$NORM^MIOROUTE(""),"/","[T002][norm][empty]")
	DO EQ^MIOTASSERT($$NORM^MIOROUTE("/"),"/","[T002][norm][root]")
	DO EQ^MIOTASSERT($$NORM^MIOROUTE("a"),"/a","[T002][norm][lead]")
	DO EQ^MIOTASSERT($$NORM^MIOROUTE("/a/"),"/a","[T002][norm][trail]")
	QUIT
	;
T003 ; MATCH requires COMPILE
	DO RESET
	DO ADD^MIOROUTE("GET","/x","H1^MIOROUTET")
	NEW P,H,RP,OK
	KILL P SET OK=$$MATCH^MIOROUTE("GET","/x",.P,.H,.RP)
	DO EQ^MIOTASSERT(+OK,0,"[T003][before compile]")
	DO COMPILE
	KILL P SET OK=$$MATCH^MIOROUTE("GET","/x",.P,.H,.RP)
	DO EQ^MIOTASSERT(+OK,1,"[T003][after compile]")
	QUIT
	;
T004 ; static + normalization
	DO RESET
	DO ADD^MIOROUTE("GET","/foo","H1^MIOROUTET")
	DO COMPILE
	NEW EP
	KILL EP DO AMATCH("[T004][static][exact]","GET","/foo",1,"H1^MIOROUTET","/foo",.EP)
	KILL EP DO AMATCH("[T004][static][no slash]","GET","foo",1,"H1^MIOROUTET","/foo",.EP)
	KILL EP DO AMATCH("[T004][static][trail]","GET","/foo/",1,"H1^MIOROUTET","/foo",.EP)
	QUIT
	;
T005 ; param capture
	DO RESET
	DO ADD^MIOROUTE("GET","/users/:id","H1^MIOROUTET")
	DO COMPILE
	NEW EP SET EP("id")="123"
	DO AMATCH("[T005][param]","GET","/users/123",1,"H1^MIOROUTET","/users/:id",.EP)
	QUIT
	;
T006 ; precedence: static > param
	DO RESET
	DO ADD^MIOROUTE("GET","/users/:id","H1^MIOROUTET")
	DO ADD^MIOROUTE("GET","/users/me","H2^MIOROUTET")
	DO COMPILE
	NEW EP
	KILL EP DO AMATCH("[T006][precedence][static]","GET","/users/me",1,"H2^MIOROUTET","/users/me",.EP)
	KILL EP SET EP("id")="42" DO AMATCH("[T006][precedence][param]","GET","/users/42",1,"H1^MIOROUTET","/users/:id",.EP)
	QUIT
	;
T007 ; method separation
	DO RESET
	DO ADD^MIOROUTE("GET","/x","H1^MIOROUTET")
	DO ADD^MIOROUTE("POST","/x","H2^MIOROUTET")
	DO COMPILE
	NEW EP
	KILL EP DO AMATCH("[T007][GET]","GET","/x",1,"H1^MIOROUTET","/x",.EP)
	KILL EP DO AMATCH("[T007][POST]","POST","/x",1,"H2^MIOROUTET","/x",.EP)
	QUIT
	;
T008 ; wildcard capture + precedence (static > wildcard)
	DO RESET
	DO ADD^MIOROUTE("GET","/static/*path","H1^MIOROUTET")
	DO ADD^MIOROUTE("GET","/static/me","H2^MIOROUTET")
	DO COMPILE
	NEW EP
	KILL EP DO AMATCH("[T008][wild][static wins]","GET","/static/me",1,"H2^MIOROUTET","/static/me",.EP)
	KILL EP SET EP("path")="a/b" DO AMATCH("[T008][wild][capture]","GET","/static/a/b",1,"H1^MIOROUTET","/static/*path",.EP)
	KILL EP SET EP("path")="" DO AMATCH("[T008][wild][empty]","GET","/static",1,"H1^MIOROUTET","/static/*path",.EP)
	QUIT
	;
T009 ; 405 Method Not Allowed for non-wildcard matches
	DO RESET
	DO ADD^MIOROUTE("GET","/m","H1^MIOROUTET")
	DO ADD^MIOROUTE("POST","/m","H2^MIOROUTET")
	DO COMPILE
	NEW DEV,CONF,REQ,CTX,OUTP
	SET OUTP="/tmp/mioroutet_405.out"
	OPEN OUTP:(NEWVERSION):1 ELSE  DO  QUIT
	. DO OK^MIOTASSERT(0,"[T009][open]")
	SET DEV=OUTP
	SET REQ("method")="PUT",REQ("path")="/m"
	SET CTX("request_id")="rid-405"
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE OUTP
	DO EQ^MIOTASSERT($GET(CTX("status")),405,"[T009][status 405]")
	DO OK^MIOTASSERT($$FILEHAS(OUTP,"Allow:"),"[T009][Allow header]")
	DO OK^MIOTASSERT($$FILEHAS(OUTP,"method_not_allowed"),"[T009][method_not_allowed body]")
	DO OK^MIOTASSERT($$FILEHAS(OUTP,"MIOROUTE"),"[T009][routine in body]")
	QUIT
	;
T010 ; Not found must be 404 (even if other methods have ONLY wildcard matches)
	DO RESET
	; GET has a catch-all fallback (common SPA pattern)
	DO ADD^MIOROUTE("GET","/*path","H1^MIOROUTET")
	DO COMPILE
	NEW DEV,CONF,REQ,CTX,OUTP
	SET OUTP="/tmp/mioroutet_404.out"
	OPEN OUTP:(NEWVERSION):1 ELSE  DO  QUIT
	. DO OK^MIOTASSERT(0,"[T010][open]")
	SET DEV=OUTP
	SET REQ("method")="POST",REQ("path")="/nope"
	SET CTX("request_id")="rid-404"
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE OUTP
	DO EQ^MIOTASSERT($GET(CTX("status")),404,"[T010][status 404]")
	DO OK^MIOTASSERT($$FILEHAS(OUTP,"not_found"),"[T010][not_found body]")
	DO OK^MIOTASSERT($$FILEHAS(OUTP,"MIOROUTE"),"[T010][routine in body]")
	QUIT
	;
T011 ; plusAsSpaceInPath policy off: keep '+'
	DO RESET
	SET ^MIO("CONF","server","routing","plusAsSpaceInPath")=0
	DO ADD^MIOROUTE("GET","/:x","H1^MIOROUTET")
	DO COMPILE
	NEW EP SET EP("x")="a+b"
	DO AMATCH("[T011][plus literal]","GET","/a+b",1,"H1^MIOROUTET","/:x",.EP)
	QUIT
	;
T012 ; ignoreTrailingSlash policy off: /a and /a/ distinct
	DO RESET
	SET ^MIO("CONF","server","routing","ignoreTrailingSlash")=0
	DO ADD^MIOROUTE("GET","/a","H1^MIOROUTET")
	DO ADD^MIOROUTE("GET","/a/","H2^MIOROUTET")
	DO COMPILE
	NEW EP
	KILL EP DO AMATCH("[T012][ts no slash]","GET","/a",1,"H1^MIOROUTET","/a",.EP)
	KILL EP DO AMATCH("[T012][ts with slash]","GET","/a/",1,"H2^MIOROUTET","/a/",.EP)
	QUIT
	;
T013 ; metadata add/get/clear
	DO RESET
	NEW META SET META("authRequired")=1,META("scope")="admin"
	DO ADDM^MIOROUTE("GET","/secure/:id","H1^MIOROUTET",.META)
	DO COMPILE
	NEW EP SET EP("id")="9"
	DO AMATCH("[T013][meta match]","GET","/secure/9",1,"H1^MIOROUTET","/secure/:id",.EP)
	NEW M2 DO GETMETA^MIOROUTE("GET","/secure/:id",.M2)
	DO EQ^MIOTASSERT($GET(M2("authRequired")),1,"[T013][meta authRequired]")
	DO EQ^MIOTASSERT($GET(M2("scope")),"admin","[T013][meta scope]")
	DO ADD^MIOROUTE("GET","/secure/:id","H2^MIOROUTET")
	DO COMPILE
	KILL M2 DO GETMETA^MIOROUTE("GET","/secure/:id",.M2)
	DO EQ^MIOTASSERT($DATA(M2),0,"[T013][meta cleared]")
	QUIT
	;
T014 ; PREMATCH stores match
	DO RESET
	DO ADD^MIOROUTE("GET","/p/:x","H1^MIOROUTET")
	DO COMPILE
	NEW REQ,CTX
	SET REQ("method")="GET",REQ("path")="/p/abc"
	DO PREMATCH^MIOROUTE(.REQ,.CTX)
	DO EQ^MIOTASSERT($GET(CTX("match","ok")),1,"[T014][ok]")
	DO EQ^MIOTASSERT($GET(CTX("match","handler")),"H1^MIOROUTET","[T014][handler]")
	DO EQ^MIOTASSERT($GET(CTX("match","params","x")),"abc","[T014][param]")
	QUIT
	;
T015 ; DISPATCH success invokes handler and merges params
	DO RESET
	DO ADD^MIOROUTE("GET","/hello/:name","HHELLO^MIOROUTET")
	DO COMPILE
	NEW DEV,CONF,REQ,CTX
	SET DEV=0
	SET REQ("method")="GET",REQ("path")="/hello/Ahmed"
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	DO EQ^MIOTASSERT($GET(CTX("called")),"HHELLO","[T015][called]")
	DO EQ^MIOTASSERT($GET(REQ("params","name")),"Ahmed","[T015][param merged]")
	QUIT
	;
T016 ; recompile: no stale routes (ORDER/LAST)
	DO RESET
	DO ADD^MIOROUTE("GET","/a","H1^MIOROUTET")
	DO COMPILE
	NEW P,H,RP,OK
	KILL P SET OK=$$MATCH^MIOROUTE("GET","/a",.P,.H,.RP)
	DO EQ^MIOTASSERT(+OK,1,"[T016][a exists]")
	; redefine a -> H2 (same path)
	DO ADD^MIOROUTE("GET","/a","H2^MIOROUTET")
	DO COMPILE
	KILL P SET OK=$$MATCH^MIOROUTE("GET","/a",.P,.H,.RP)
	DO EQ^MIOTASSERT(H,"H2^MIOROUTET","[T016][redefine uses last]")
	QUIT
	;
T017 ; wildcard must be last (compile error)
	DO RESET
	DO ADD^MIOROUTE("GET","/x/*p/y","H1^MIOROUTET")
	DO COMPILE
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","COMPILE","ok")),0,"[T017][compile ok=0]")
	QUIT
	;
T018 ; invalid param name (compile error)
	DO RESET
	DO ADD^MIOROUTE("GET","/x/:","H1^MIOROUTET")
	DO COMPILE
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","COMPILE","ok")),0,"[T018][compile ok=0]")
	QUIT
	;
T019 ; param name conflict at same node (compile error + first route wins)
	DO RESET
	DO ADD^MIOROUTE("GET","/u/:id","H1^MIOROUTET")
	DO ADD^MIOROUTE("GET","/u/:name","H2^MIOROUTET")
	DO COMPILE
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","COMPILE","ok")),0,"[T019][compile ok=0]")
	NEW EP SET EP("id")="7"
	DO AMATCH("[HANDLER][T019][match first]","GET","/u/7",1,"H1^MIOROUTET","/u/:id",.EP)
	QUIT
	;
	;
	;
T020 ; leaf normalization conflict: "/a" vs "a" should be compile error (same normalized leaf, different raw route strings)
	DO RESET
	DO ADD^MIOROUTE("GET","/a","H1^MIOROUTET")
	DO ADD^MIOROUTE("GET","a","H2^MIOROUTET")
	DO COMPILE
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","COMPILE","ok")),0,"[T020][compile ok=0]")
	; route still must match deterministically (conflicting route is skipped; first route wins)
	NEW EP
	KILL EP DO AMATCH("[T020][match]","GET","/a",1,"H1^MIOROUTET","/a",.EP)
	QUIT
	;
T021 ; wildcard conflict at same node: only one wildcard route allowed per node
	DO RESET
	DO ADD^MIOROUTE("GET","/a/*p","H1^MIOROUTET")
	DO ADD^MIOROUTE("GET","/a/*q","H2^MIOROUTET")
	DO COMPILE
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","COMPILE","ok")),0,"[T021][compile ok=0]")
	QUIT
	;
T022 ; wildcard default param name "splat" when pattern is "*"
	DO RESET
	DO ADD^MIOROUTE("GET","/w/*","H1^MIOROUTET")
	DO COMPILE
	NEW EP SET EP("splat")="a/b"
	DO AMATCH("[T022][wild][default name]","GET","/w/a/b",1,"H1^MIOROUTET","/w/*",.EP)
	QUIT
	;
T023 ; precedence: param > wildcard (and wildcard matches deeper paths)
	DO RESET
	DO ADD^MIOROUTE("GET","/x/:id","H1^MIOROUTET")
	DO ADD^MIOROUTE("GET","/x/*path","H2^MIOROUTET")
	DO COMPILE
	NEW EP SET EP("id")="abc"
	DO AMATCH("[T023][param over wild]","GET","/x/abc",1,"H1^MIOROUTET","/x/:id",.EP)
	KILL EP SET EP("path")="abc/def"
	DO AMATCH("[T023][wild for deep]","GET","/x/abc/def",1,"H2^MIOROUTET","/x/*path",.EP)
	QUIT
	;
T024 ; invalid percent sequences preserved (plusAsSpaceInPath=0 so we use URLDECPATH)
	DO RESET
	SET ^MIO("CONF","server","routing","plusAsSpaceInPath")=0
	DO ADD^MIOROUTE("GET","/:x","H1^MIOROUTET")
	DO COMPILE
	NEW EP SET EP("x")="%ZZ"
	DO AMATCH("[T024][bad % preserved]","GET","/%ZZ",1,"H1^MIOROUTET","/:x",.EP)
	QUIT
	;
T025 ; multiple slashes in request path should not crash; empty segments are skipped
	DO RESET
	DO ADD^MIOROUTE("GET","/a/:x/b","H1^MIOROUTET")
	DO COMPILE
	NEW EP SET EP("x")="z"
	DO AMATCH("[T025][double slash]","GET","/a//z/b",1,"H1^MIOROUTET","/a/:x/b",.EP)
	QUIT
	;
T026 ; root wildcard should match "/" and capture empty remainder
	DO RESET
	DO ADD^MIOROUTE("GET","/*path","H1^MIOROUTET")
	DO COMPILE
	NEW EP SET EP("path")=""
	DO AMATCH("[T026][root wild empty]","GET","/",1,"H1^MIOROUTET","/*path",.EP)
	QUIT
	;
T027 ; 405 should ignore WS routes when computing Allow
	DO RESET
	DO ADD^MIOROUTE("WS","/sock","H1^MIOROUTET")
	DO ADD^MIOROUTE("GET","/sock","H2^MIOROUTET")
	DO COMPILE
	NEW DEV,CONF,REQ,CTX,OUTP
	SET OUTP="/tmp/mioroutet_405_ws.out"
	OPEN OUTP:(NEWVERSION):1 ELSE  DO  QUIT
	. DO OK^MIOTASSERT(0,"[T027][open]")
	SET DEV=OUTP
	SET REQ("method")="POST",REQ("path")="/sock"
	SET CTX("request_id")="rid-405-ws"
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE OUTP
	DO EQ^MIOTASSERT($GET(CTX("status")),405,"[T027][status 405]")
	DO OK^MIOTASSERT($$FILEHAS(OUTP,"Allow: GET"),"[T027][Allow GET only]")
	QUIT
	;
T028 ; 405 should NOT include wildcard-only matches in Allow
	DO RESET
	; common: GET catch-all for SPA
	DO ADD^MIOROUTE("GET","/*path","H1^MIOROUTET")
	; explicit POST route
	DO ADD^MIOROUTE("POST","/m","H2^MIOROUTET")
	DO COMPILE
	NEW DEV,CONF,REQ,CTX,OUTP
	SET OUTP="/tmp/mioroutet_405_wild_ignore.out"
	OPEN OUTP:(NEWVERSION):1 ELSE  DO  QUIT
	. DO OK^MIOTASSERT(0,"[T028][open]")
	SET DEV=OUTP
	SET REQ("method")="PUT",REQ("path")="/m"
	SET CTX("request_id")="rid-405-wild"
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE OUTP
	DO EQ^MIOTASSERT($GET(CTX("status")),405,"[T028][status 405]")
	DO OK^MIOTASSERT($$FILEHAS(OUTP,"Allow: POST"),"[T028][Allow POST only]")
	QUIT
	;
T029 ; compile error records must include routine name at root and per-entry
	DO RESET
	DO ADD^MIOROUTE("GET","/x/*p/y","H1^MIOROUTET") ; invalid: wildcard not last
	DO COMPILE
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","COMPILE","ok")),0,"[T029][compile ok=0]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","COMPILE","err","routine")),"MIOROUTE","[T029][root routine]")
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","COMPILE","err",1,"routine")),"MIOROUTE","[T029][entry routine]")
	QUIT
	;
T030 ; empty handler should cause compile error
	DO RESET
	DO ADD^MIOROUTE("GET","/empty","")
	DO COMPILE
	DO EQ^MIOTASSERT($GET(^MIO("ROUTE","COMPILE","ok")),0,"[T030][compile ok=0]")
	QUIT
	;
T031 ; stress: compile many routes and match quickly (no correctness regression)
	DO RESET
	NEW I,P
	FOR I=1:1:1500 DO
	. SET P="/s/"_I
	. DO ADD^MIOROUTE("GET",P,"H1^MIOROUTET")
	. SET P="/p/"_I_"/:id"
	. DO ADD^MIOROUTE("GET",P,"H2^MIOROUTET")
	DO COMPILE
	NEW EP SET EP("id")="xyz"
	DO AMATCH("[T031][stress match]","GET","/p/1499/xyz",1,"H2^MIOROUTET","/p/1499/:id",.EP)
	QUIT
	;
T032 ; url decoding of spaces and plus (policy on)
	DO RESET
	SET ^MIO("CONF","server","routing","plusAsSpaceInPath")=1
	DO ADD^MIOROUTE("GET","/:x","H1^MIOROUTET")
	DO COMPILE
	NEW EP SET EP("x")="a b"
	DO AMATCH("[T032][%20]","GET","/a%20b",1,"H1^MIOROUTET","/:x",.EP)
	KILL EP SET EP("x")="a b"
	DO AMATCH("[T032][+]","GET","/a+b",1,"H1^MIOROUTET","/:x",.EP)
	QUIT
	;
T033 ; DISPATCH should use CTX("match") cache when present
	DO RESET
	DO ADD^MIOROUTE("GET","/c/:x","HCACHE^MIOROUTET")
	DO COMPILE
	NEW DEV,CONF,REQ,CTX
	SET DEV=0
	SET REQ("method")="GET",REQ("path")="/c/ok"
	DO PREMATCH^MIOROUTE(.REQ,.CTX)
	; mutate request path after prematch; dispatch should still call cached handler and cached params
	SET REQ("path")="/c/nope"
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	DO EQ^MIOTASSERT($GET(CTX("called")),"HCACHE","[T033][called cached handler]")
	DO EQ^MIOTASSERT($GET(REQ("params","x")),"ok","[T033][cached param]")
	QUIT
	;
T034 ; MATCH must clear PARAMS between calls (no leakage)
	DO RESET
	DO ADD^MIOROUTE("GET","/a/:x","H1^MIOROUTET")
	DO ADD^MIOROUTE("GET","/b/:y","H2^MIOROUTET")
	DO COMPILE
	NEW P,H,RP,OK
	KILL P SET OK=$$MATCH^MIOROUTE("GET","/a/one",.P,.H,.RP)
	DO EQ^MIOTASSERT($GET(P("x")),"one","[T034][first x]")
	; call again reusing same P array
	SET OK=$$MATCH^MIOROUTE("GET","/b/two",.P,.H,.RP)
	DO EQ^MIOTASSERT($GET(P("y")),"two","[T034][second y]")
	DO EQ^MIOTASSERT($DATA(P("x")),0,"[T034][x cleared]")
	QUIT
	;
T035 ; UTF-8 percent bytes should not crash; match should succeed
	DO RESET
	SET ^MIO("CONF","server","routing","plusAsSpaceInPath")=0
	DO ADD^MIOROUTE("GET","/:x","H1^MIOROUTET")
	DO COMPILE
	NEW P,H,RP,OK
	KILL P SET OK=$$MATCH^MIOROUTE("GET","/%E2%9C%93",.P,.H,.RP)
	DO EQ^MIOTASSERT(+OK,1,"[T035][match ok]")
	QUIT
	;
	;
T036 ; MIOROUTE must expose URLDEC for MIOHTTP query parsing
	DO OK^MIOTASSERT($TEXT(URLDEC^MIOROUTE)'="","[T036][URLDEC label exists]")
	DO EQ^MIOTASSERT($$URLDEC^MIOROUTE("a+b%20c"),"a b c","[T036][decode + and %]")
	DO EQ^MIOTASSERT($$URLDEC^MIOROUTE("%ZZ"),"%ZZ","[T036][invalid % preserved]")
	QUIT
	;
T037 ; Integration: MIOHTTP request line parsing with querystring (includes empty values)
	NEW REQ,ERR,LINE
	KILL REQ,ERR
	SET LINE="GET /plgd?q=&sort=updated&per=18&fav=0&view=grid HTTP/1.1"
	DO PARSEREQLINE^MIOHTTP(LINE,.REQ,.ERR)
	DO EQ^MIOTASSERT($DATA(ERR),0,"[T037][no ERR]")
	DO EQ^MIOTASSERT($GET(REQ("method")),"GET","[T037][method]")
	DO EQ^MIOTASSERT($GET(REQ("path")),"/plgd","[T037][path]")
	DO EQ^MIOTASSERT($GET(REQ("query","sort")),"updated","[T037][sort]")
	DO EQ^MIOTASSERT($GET(REQ("query","per")),"18","[T037][per]")
	DO EQ^MIOTASSERT($GET(REQ("query","fav")),"0","[T037][fav]")
	DO EQ^MIOTASSERT($GET(REQ("query","view")),"grid","[T037][view]")
	DO EQ^MIOTASSERT($DATA(REQ("query","q")),1,"[T037][q key present]")
	DO EQ^MIOTASSERT($GET(REQ("query","q")),"","[T037][q empty]")
	QUIT
	;
T038 ; Router must match even if caller accidentally passes querystring in REQ("path")
	DO RESET
	DO ADD^MIOROUTE("GET","/plgd","H1^MIOROUTET")
	DO COMPILE
	NEW REQ,CTX
	SET REQ("method")="GET"
	; defensive: include query on path to mimic real-world bugs
	SET REQ("path")="/plgd?q=&sort=updated&per=18&fav=0&view=grid"
	DO PREMATCH^MIOROUTE(.REQ,.CTX)
	DO EQ^MIOTASSERT($GET(CTX("match","ok")),1,"[T038][prematch ok]")
	DO EQ^MIOTASSERT($GET(CTX("match","route")),"/plgd","[T038][route]")
	DO EQ^MIOTASSERT($GET(CTX("match","handler")),"H1^MIOROUTET","[T038][handler]")
	QUIT
	;
; ---------------------------------------------------------------------
; handlers
	;
H1(DEV,CONF,REQ,CTX)
	SET CTX("called")="H1"
	QUIT
	;
H2(DEV,CONF,REQ,CTX)
	SET CTX("called")="H2"
	QUIT
	;
HHELLO(DEV,CONF,REQ,CTX)
	SET CTX("called")="HHELLO"
	QUIT
	;
HCACHE(DEV,CONF,REQ,CTX)
	SET CTX("called")="HCACHE"
	QUIT
	;