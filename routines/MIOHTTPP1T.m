MIOHTTPP1T ; MIOHTTP parser/helper tests - patch 1
	;
	; Run:
	;   YDB>ZL "MIOHTTP.m","MIOHTTPP1T.m","MIOTASSERT.m"
	;   YDB>D ^MIOHTTPP1T
	;
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
	QUIT
	;
T001 ; PARSEREQLINE basic GET
	NEW REQ,ERR
	KILL REQ,ERR
	DO PARSEREQLINE^MIOHTTP("GET /hello HTTP/1.1",.REQ,.ERR)
	DO EQ^MIOTASSERT($GET(REQ("method")),"GET","[T001][method]")
	DO EQ^MIOTASSERT($GET(REQ("path")),"/hello","[T001][path]")
	DO EQ^MIOTASSERT($GET(REQ("httpver")),"HTTP/1.1","[T001][ver]")
	QUIT
	;
T002 ; PARSEREQLINE with query string
	NEW REQ,ERR
	KILL REQ,ERR
	DO PARSEREQLINE^MIOHTTP("GET /search?q=test&sort=asc HTTP/1.1",.REQ,.ERR)
	DO EQ^MIOTASSERT($GET(REQ("path")),"/search","[T002][path]")
	DO EQ^MIOTASSERT($GET(REQ("query","q")),"test","[T002][q]")
	DO EQ^MIOTASSERT($GET(REQ("query","sort")),"asc","[T002][sort]")
	QUIT
	;
T003 ; PARSEREQLINE preserves rawpath
	NEW REQ,ERR
	KILL REQ,ERR
	DO PARSEREQLINE^MIOHTTP("POST /api/items?id=9 HTTP/1.0",.REQ,.ERR)
	DO EQ^MIOTASSERT($GET(REQ("rawpath")),"/api/items?id=9","[T003][rawpath]")
	DO EQ^MIOTASSERT($GET(REQ("httpver")),"HTTP/1.0","[T003][ver]")
	QUIT
	;
T004 ; PARSEREQLINE bad request line missing version
	NEW REQ,ERR
	KILL REQ,ERR
	DO PARSEREQLINE^MIOHTTP("GET /onlytwo",.REQ,.ERR)
	DO EQ^MIOTASSERT($GET(ERR("error")),"bad_request_line","[T004][err]")
	QUIT
	;
T005 ; PARSEREQLINE bad request line missing path
	NEW REQ,ERR
	KILL REQ,ERR
	DO PARSEREQLINE^MIOHTTP("GET  HTTP/1.1",.REQ,.ERR)
	DO EQ^MIOTASSERT($GET(ERR("error")),"bad_request_line","[T005][err]")
	QUIT
	;
T006 ; PARSEQRY empty query value
	NEW REQ
	KILL REQ
	DO PARSEQRY^MIOHTTP("/x?a=&b=2",.REQ)
	DO EQ^MIOTASSERT($GET(REQ("query","a")),"","[T006][a]")
	DO EQ^MIOTASSERT($GET(REQ("query","b")),"2","[T006][b]")
	QUIT
	;
T007 ; PARSEQRY repeated ampersands and empty pieces
	NEW REQ
	KILL REQ
	DO PARSEQRY^MIOHTTP("/x?a=1&&b=2&",.REQ)
	DO EQ^MIOTASSERT($GET(REQ("query","a")),"1","[T007][a]")
	DO EQ^MIOTASSERT($GET(REQ("query","b")),"2","[T007][b]")
	QUIT
	;
T008 ; URLDECQ plus becomes space
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("hello+world"),"hello world","[T008][plus]")
	QUIT
	;
T009 ; URLDECQ %20 decode
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("a%20b"),"a b","[T009][pct20]")
	QUIT
	;
T010 ; URLDECQ mixed plus and percent
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("A+%2B+B"),"A + B","[T010][mixed]")
	QUIT
	;
T011 ; URLDECQ invalid percent is preserved
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("bad%XZok"),"bad%XZok","[T011][invalid pct]")
	QUIT
	;
T012 ; URLDECQ short trailing percent is preserved
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("abc%"),"abc%","[T012][short pct]")
	QUIT
	;
T013 ; HEXVAL upper hex
	DO EQ^MIOTASSERT($$HEXVAL^MIOHTTP("A"),10,"[T013][A]")
	DO EQ^MIOTASSERT($$HEXVAL^MIOHTTP("F"),15,"[T013][F]")
	QUIT
	;
T014 ; HEXVAL lower hex
	DO EQ^MIOTASSERT($$HEXVAL^MIOHTTP("a"),10,"[T014][a]")
	DO EQ^MIOTASSERT($$HEXVAL^MIOHTTP("f"),15,"[T014][f]")
	QUIT
	;
T015 ; HEXVAL invalid char
	DO EQ^MIOTASSERT($$HEXVAL^MIOHTTP("G"),-1,"[T015][invalid]")
	QUIT
	;
T016 ; HEX2DEC valid pairs
	DO EQ^MIOTASSERT($$HEX2DEC^MIOHTTP("00"),0,"[T016][00]")
	DO EQ^MIOTASSERT($$HEX2DEC^MIOHTTP("0A"),10,"[T016][0A]")
	DO EQ^MIOTASSERT($$HEX2DEC^MIOHTTP("FF"),255,"[T016][FF]")
	QUIT
	;
T017 ; HEX2DEC invalid pair
	DO EQ^MIOTASSERT($$HEX2DEC^MIOHTTP("G1"),-1,"[T017][invalid]")
	QUIT
	;
T018 ; HEXSTR2DEC valid chunk sizes
	DO EQ^MIOTASSERT($$HEXSTR2DEC^MIOHTTP("4"),4,"[T018][4]")
	DO EQ^MIOTASSERT($$HEXSTR2DEC^MIOHTTP("1A"),26,"[T018][1A]")
	DO EQ^MIOTASSERT($$HEXSTR2DEC^MIOHTTP("1a"),26,"[T018][1a]")
	QUIT
	;
T019 ; HEXSTR2DEC invalid/too long
	DO EQ^MIOTASSERT($$HEXSTR2DEC^MIOHTTP(""),-1,"[T019][empty]")
	DO EQ^MIOTASSERT($$HEXSTR2DEC^MIOHTTP("XYZ"),-1,"[T019][bad]")
	DO EQ^MIOTASSERT($$HEXSTR2DEC^MIOHTTP("123456789"),-1,"[T019][too long]")
	QUIT
	;
T020 ; HTOK valid header names
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("content-type"),1,"[T020][content-type]")
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("x_test"),1,"[T020][x_test]")
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("x.y"),1,"[T020][x.y]")
	QUIT
	;
T021 ; HTOK invalid header names
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP(""),0,"[T021][empty]")
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("bad name"),0,"[T021][space]")
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("bad@name"),0,"[T021][at]")
	QUIT
	;
T022 ; HVALOK accepts normal printable and tab
	DO EQ^MIOTASSERT($$HVALOK^MIOHTTP("text/plain"),1,"[T022][plain]")
	DO EQ^MIOTASSERT($$HVALOK^MIOHTTP("a"_$C(9)_"b"),1,"[T022][tab]")
	QUIT
	;
T023 ; HVALOK rejects ctl chars
	DO EQ^MIOTASSERT($$HVALOK^MIOHTTP("a"_$C(1)_"b"),0,"[T023][ctl]")
	DO EQ^MIOTASSERT($$HVALOK^MIOHTTP("a"_$C(127)_"b"),0,"[T023][del]")
	QUIT
	;
T024 ; TE helpers basic behavior
	DO EQ^MIOTASSERT($$TEOK^MIOHTTP("chunked"),1,"[T024][teok chunked]")
	DO EQ^MIOTASSERT($$TEOK^MIOHTTP("identity"),1,"[T024][teok identity]")
	DO EQ^MIOTASSERT($$TEOK^MIOHTTP("gzip"),0,"[T024][teok gzip]")
	DO EQ^MIOTASSERT($$TEHAS^MIOHTTP("gzip, chunked","chunked"),1,"[T024][tehas]")
	DO EQ^MIOTASSERT($$TECHUNKLAST^MIOHTTP("identity, chunked"),1,"[T024][chunk last]")
	DO EQ^MIOTASSERT($$TECHUNKLAST^MIOHTTP("chunked, identity"),0,"[T024][chunk not last]")
	QUIT
	;
T025 ; LIM STATUS4ERR TRIM LOW helpers
	NEW CONF,ERR
	KILL CONF,ERR
	SET CONF("server","limits","maxHeaderBytes")=123
	DO EQ^MIOTASSERT($$LIM^MIOHTTP(.CONF,"maxHeaderBytes",9),123,"[T025][lim]")
	SET ERR("error")="headers_too_large"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),431,"[T025][status]")
	DO EQ^MIOTASSERT($$TRIM^MIOHTTP("  abc  "),"abc","[T025][trim]")
	DO EQ^MIOTASSERT($$LOW^MIOHTTP("AbC"),"abc","[T025][low]")
	QUIT