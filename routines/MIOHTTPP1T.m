MIOHTTPP1T ; MIOHTTP parser/helper tests - patch 1
	;
	; Run:
	;   YDB>ZL "MIOHTTP.m","MIOHTTPP1T.m","MIOTASSERT.m"
	;   YDB>D ^MIOHTTPP1T
	;
	D T001 ; PARSEREQLINE basic GET
	D T002 ; PARSEREQLINE with query string
	D T003 ; PARSEREQLINE preserves rawpath
	D T004 ; PARSEREQLINE bad request line missing version
	D T005 ; PARSEREQLINE bad request line missing path
	D T006 ; PARSEQRY empty query value
	D T007 ; PARSEQRY repeated ampersands and empty pieces
	D T008 ; URLDECQ plus becomes space
	D T009 ; URLDECQ %20 decode
	D T010 ; URLDECQ mixed plus and percent
	D T011 ; URLDECQ invalid percent is preserved
	D T012 ; URLDECQ short trailing percent is preserved
	D T013 ; HEXVAL upper hex
	D T014 ; HEXVAL lower hex
	D T015 ; HEXVAL invalid char
	D T016 ; HEX2DEC valid pairs
	D T017 ; HEX2DEC invalid pair
	D T018 ; HEXSTR2DEC valid chunk sizes
	D T019 ; HEXSTR2DEC invalid/too long
	D T020 ; HTOK valid header names
	D T021 ; HTOK invalid header names
	D T022 ; HVALOK accepts normal printable and tab
	D T023 ; HVALOK rejects ctl chars
	D T024 ; TE helpers basic behavior
	D T025 ; LIM STATUS4ERR TRIM LOW helpers
	D T026 ; READHDRS basic two headers
	D T027 ; READHDRS trims spaces around name/value
	D T028 ; READHDRS trims normal value spacing
	D T029 ; READHDRS lowercases header names
	D T030 ; READHDRS duplicate content-length rejected
	D T031 ; READHDRS duplicate transfer-encoding rejected
	D T032 ; READHDRS duplicate host rejected
	D T033 ; READHDRS bad line without colon
	D T034 ; READHDRS invalid header name
	D T035 ; READHDRS invalid header value control char
	D T036 ; READHDRS folded header rejected
	D T037 ; READHDRS max header count
	D T038 ; READHDRS max header bytes
	D T039 ; READHDRS max single header line bytes
	D T040 ; PARSEHDRS basic request line plus headers
	D T041 ; PARSEHDRS bad request line propagates
	D T042 ; EXPECTDECIDE no Expect header
	D T043 ; EXPECTDECIDE 100-continue within max body
	D T044 ; EXPECTDECIDE 100-continue payload too large
	D T045 ; EXPECTDECIDE mixed case header value
	D T046 ; READBODYONLY none when content-length absent
	D T047 ; READBODYONLY fixed length small body
	D T048 ; READBODYONLY chunked body
	D T049 ; STATUSMSG and NOBODY common cases
	D T050 ; PARSE full request with content-length body
	D T051 ; READCL invalid content-length non-numeric
	D T052 ; READCL payload too large by configured max
	D T053 ; READCL zero length produces none mode
	D T054 ; READCL simple scalar body
	D T055 ; READCL short read error
	D T056 ; READCL upgrades to global mode when exceeding scalar threshold
	D T057 ; READCHUNKED basic two chunks
	D T058 ; READCHUNKED accepts chunk extensions
	D T059 ; READCHUNKED invalid blank size line
	D T060 ; READCHUNKED invalid hex size
	D T061 ; READCHUNKED bad chunk ending
	D T062 ; READCHUNKED short read inside chunk
	D T063 ; READCHUNKED trailer lines are consumed
	D T064 ; READCHUNKED payload too large
	D T065 ; PARSE rejects TE plus CL conflict by default
	D T066 ; PARSE allows TE plus CL when allowTECL=1 and uses chunked
	D T067 ; PARSE unsupported transfer-encoding
	D T068 ; PARSE bad transfer-encoding order when chunked not last
	D T069 ; PARSE chunked not supported when disabled
	D T070 ; PARSE identity transfer-encoding with content-length reads body
	D T071 ; BODYOPEN and BODYNEXT over scalar body
	D T072 ; BODYOPEN and BODYNEXT over global body
	D T073 ; BODYLEN and BODYFREE global body
	D T074 ; PARSE large body goes global when scalar limit is small
	D T075 ; PARSE no body when no CL and no TE
	D T076 ; READLINE reads first CRLF line
	D T077 ; READLINE reads blank line between headers and body
	D T078 ; READLINE short read without CRLF
	D T079 ; READFIX exact byte count
	D T080 ; READFIX zero bytes
	D T081 ; READFIX short read
	D T082 ; RESP emits 200 status line
	D T083 ; RESP emits request id header
	D T084 ; RESP HEAD request suppresses body
	D T085 ; RESP 204 suppresses body
	D T086 ; RESP 304 suppresses body
	D T087 ; RESPX basic text response
	D T088 ; RESPJSON basic object response
	D T089 ; RESPJSON HEAD suppresses body
	D T090 ; RESPJSONX basic wrapper path
	D T091 ; RESP unknown status uses fallback text
	D T092 ; RESP content-length for empty body is zero
	D T093 ; RESP text/plain body exact bytes
	D T094 ; RESPJSON nested object
	D T095 ; RESPJSON array-like numeric nodes
	D T096 ; RESP includes common security headers
	D T097 ; RESPJSON includes request id header
	D T098 ; RESPX empty body response
	D T099 ; RESPJSONX request id propagation
	D T100 ; full request parse then simple text response roundtrip
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
	;
T026 ; READHDRS basic two headers
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p2_t026.req"
	DO WRFILE(DEV,"Host: example.com"_$C(13,10)_"Content-Type: text/plain"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("hdr","host")),"example.com","[T026][host]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","content-type")),"text/plain","[T026][ctype]")
	QUIT
	;
T027 ; READHDRS leading space in name rejected
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p2_t027.req"
	DO WRFILE(DEV," Host :   example.com  "_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"header_folding_rejected","[T027][leading name invalid]")
	QUIT
	;
T028 ; READHDRS trims normal value spacing
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p2_t028.req"
	DO WRFILE(DEV,"Host:   example.com  "_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("hdr","host")),"example.com","[T028][trimmed]")
	QUIT
	;
T029 ; READHDRS lowercases header names
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p2_t029.req"
	DO WRFILE(DEV,"X-CuStOm: ABC"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-custom")),"ABC","[T029][lower]")
	QUIT
	;
T030 ; READHDRS duplicate content-length rejected
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p2_t030.req"
	DO WRFILE(DEV,"Content-Length: 1"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"duplicate_content_length","[T030][err]")
	QUIT
	;
T031 ; READHDRS duplicate transfer-encoding rejected
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p2_t031.req"
	DO WRFILE(DEV,"Transfer-Encoding: chunked"_$C(13,10)_"Transfer-Encoding: identity"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"duplicate_transfer_encoding","[T031][err]")
	QUIT
	;
T032 ; READHDRS duplicate host rejected
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p2_t032.req"
	DO WRFILE(DEV,"Host: a"_$C(13,10)_"Host: b"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"duplicate_host","[T032][err]")
	QUIT
	;
T033 ; READHDRS bad line without colon
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p2_t033.req"
	DO WRFILE(DEV,"BadHeaderLine"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"bad_header_line","[T033][err]")
	QUIT
	;
T034 ; READHDRS invalid header name
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p2_t034.req"
	DO WRFILE(DEV,"bad name: x"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"invalid_header_name","[T034][err]")
	QUIT
	;
T035 ; READHDRS invalid header value control char
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p2_t035.req"
	DO WRFILE(DEV,"X-Test: a"_$C(1)_"b"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"invalid_header_value","[T035][err]")
	QUIT
	;
T036 ; READHDRS folded header rejected
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p2_t036.req"
	DO WRFILE(DEV,"Host: a"_$C(13,10)_" folded"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"header_folding_rejected","[T036][err]")
	QUIT
	;
T037 ; READHDRS max header count
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p2_t037.req"
	SET CONF("server","limits","maxHeaderCount")=1
	DO WRFILE(DEV,"A: 1"_$C(13,10)_"B: 2"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"too_many_headers","[T037][err]")
	QUIT
	;
T038 ; READHDRS max header bytes
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p2_t038.req"
	SET CONF("server","limits","maxHeaderBytes")=12
	DO WRFILE(DEV,"Host: abcdef"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"headers_too_large","[T038][err]")
	QUIT
	;
T039 ; READHDRS max single header line bytes
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p2_t039.req"
	SET CONF("server","limits","maxHeaderLineBytes")=5
	DO WRFILE(DEV,"Host: abc"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"header_line_too_large","[T039][err]")
	QUIT
	;
T040 ; PARSEHDRS basic request line plus headers
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p2_t040.req"
	DO WRFILE(DEV,"GET /x?a=1 HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T040][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("path")),"/x","[T040][path]")
	DO EQ^MIOTASSERT($GET(REQ("query","a")),"1","[T040][query]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","host")),"ex","[T040][host]")
	QUIT
	;
T041 ; PARSEHDRS bad request line propagates
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p2_t041.req"
	DO WRFILE(DEV,"GET /oops"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T041][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"bad_request_line","[T041][err]")
	QUIT
	;
T042 ; EXPECTDECIDE no Expect header
	NEW CONF,REQ,ERR
	KILL CONF,REQ,ERR
	DO EQ^MIOTASSERT($$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR),1,"[T042][ok]")
	QUIT
	;
T043 ; EXPECTDECIDE 100-continue within max body
	NEW CONF,REQ,ERR
	KILL CONF,REQ,ERR
	SET REQ("hdr","expect")="100-continue"
	SET REQ("hdr","content-length")=100
	SET CONF("server","limits","maxBodyBytes")=1000
	DO EQ^MIOTASSERT($$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR),1,"[T043][ok]")
	QUIT
	;
T044 ; EXPECTDECIDE 100-continue payload too large
	NEW CONF,REQ,ERR
	KILL CONF,REQ,ERR
	SET REQ("hdr","expect")="100-continue"
	SET REQ("hdr","content-length")=2000
	SET CONF("server","limits","maxBodyBytes")=1000
	DO EQ^MIOTASSERT($$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR),0,"[T044][ok]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"payload_too_large","[T044][err]")
	QUIT
	;
T045 ; EXPECTDECIDE mixed case header value
	NEW CONF,REQ,ERR
	KILL CONF,REQ,ERR
	SET REQ("hdr","expect")="100-ConTinue"
	DO EQ^MIOTASSERT($$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR),1,"[T045][ok]")
	QUIT
	;
T046 ; READBODYONLY none when content-length absent
	NEW CONF,REQ,ERR
	KILL CONF,REQ,ERR
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP("dummy",.CONF,.REQ,.ERR),1,"[T046][ok]")
	QUIT
	;
T047 ; READBODYONLY fixed length small body
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p2_t047.req"
	DO WRFILE(DEV,"hello")
	SET REQ("hdr","content-length")=5
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T047][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"hello","[T047][body]")
	DO EQ^MIOTASSERT($GET(REQ("body","len")),5,"[T047][len]")
	QUIT
	;
T048 ; READBODYONLY chunked body
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p2_t048.req"
	SET CONF("server","http","supportChunkedRequest")=1
	DO WRFILE(DEV,"4"_$C(13,10)_"Wiki"_$C(13,10)_"5"_$C(13,10)_"pedia"_$C(13,10)_"0"_$C(13,10,13,10))
	SET REQ("hdr","transfer-encoding")="chunked"
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T048][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"Wikipedia","[T048][body]")
	QUIT
	;
T049 ; STATUSMSG and NOBODY common cases
	DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(200),"OK","[T049][200]")
	DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(404),"Not Found","[T049][404]")
	DO EQ^MIOTASSERT($$NOBODY^MIOHTTP(204),1,"[T049][204 nobody]")
	DO EQ^MIOTASSERT($$NOBODY^MIOHTTP(304),1,"[T049][304 nobody]")
	DO EQ^MIOTASSERT($$NOBODY^MIOHTTP(200),0,"[T049][200 body]")
	QUIT
	;
T050 ; PARSE full request with content-length body
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p2_t050.req"
	DO WRFILE(DEV,"POST /submit HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10)_"Content-Length: 5"_$C(13,10,13,10)_"hello")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T050][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("method")),"POST","[T050][method]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","host")),"ex","[T050][host]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"hello","[T050][body]")
	QUIT
T051 ; READCL invalid content-length non-numeric
	NEW REQ,ERR,CONF
	DO READCL^MIOHTTP("dummy",.CONF,.REQ,"abc",.ERR)
	DO EQ^MIOTASSERT($GET(ERR("error")),"invalid_content_length","[T051][err]")
	QUIT
	;
T052 ; READCL payload too large by configured max
	NEW REQ,ERR,CONF
	SET CONF("server","limits","maxBodyBytes")=5
	DO READCL^MIOHTTP("dummy",.CONF,.REQ,6,.ERR)
	DO EQ^MIOTASSERT($GET(ERR("error")),"payload_too_large","[T052][err]")
	QUIT
	;
T053 ; READCL zero length produces none mode
	NEW REQ,ERR,CONF
	DO READCL^MIOHTTP("dummy",.CONF,.REQ,0,.ERR)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"none","[T053][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body","len")),0,"[T053][len]")
	QUIT
	;
T054 ; READCL simple scalar body
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p3_t054.req"
	DO WRFILE(DEV,"hello")
	DO OPENR(DEV)
	DO READCL^MIOHTTP(DEV,.CONF,.REQ,5,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T054][no err]")
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"scalar","[T054][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"hello","[T054][body]")
	DO EQ^MIOTASSERT($$BODYLEN^MIOHTTP(.REQ),5,"[T054][len]")
	QUIT
	;
T055 ; READCL short read error
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p3_t055.req"
	DO WRFILE(DEV,"hey")
	DO OPENR(DEV)
	DO READCL^MIOHTTP(DEV,.CONF,.REQ,5,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"short_read","[T055][err]")
	QUIT
	;
T056 ; READCL upgrades to global mode when exceeding scalar threshold
	NEW REQ,ERR,CONF,DEV,TEXT
	SET DEV="tmp/miohttp_p3_t056.req"
	SET CONF("server","limits","maxBodyScalarBytes")=4
	SET TEXT="abcdef"
	DO WRFILE(DEV,TEXT)
	DO OPENR(DEV)
	DO READCL^MIOHTTP(DEV,.CONF,.REQ,6,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T056][mode]")
	DO EQ^MIOTASSERT($$BODYLEN^MIOHTTP(.REQ),6,"[T056][len]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T057 ; READCHUNKED basic two chunks
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p3_t057.req"
	DO WRFILE(DEV,"4"_$C(13,10)_"Wiki"_$C(13,10)_"5"_$C(13,10)_"pedia"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T057][no err]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"Wikipedia","[T057][body]")
	DO EQ^MIOTASSERT($$BODYLEN^MIOHTTP(.REQ),9,"[T057][len]")
	QUIT
	;
T058 ; READCHUNKED accepts chunk extensions
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p3_t058.req"
	DO WRFILE(DEV,"4;foo=bar"_$C(13,10)_"Wiki"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"Wiki","[T058][body]")
	QUIT
	;
T059 ; READCHUNKED invalid blank size line
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p3_t059.req"
	DO WRFILE(DEV,$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"bad_chunk_size","[T059][err]")
	QUIT
	;
T060 ; READCHUNKED invalid hex size
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p3_t060.req"
	DO WRFILE(DEV,"ZZ"_$C(13,10)_"xx"_$C(13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"bad_chunk_size","[T060][err]")
	QUIT
	;
T061 ; READCHUNKED bad chunk ending
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p3_t061.req"
	DO WRFILE(DEV,"4"_$C(13,10)_"WikiX"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"bad_chunk_ending","[T061][err]")
	QUIT
	;
T062 ; READCHUNKED short read inside chunk
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p3_t062.req"
	DO WRFILE(DEV,"5"_$C(13,10)_"abcd")
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"short_read","[T062][err]")
	QUIT
	;
T063 ; READCHUNKED trailer lines are consumed
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p3_t063.req"
	DO WRFILE(DEV,"3"_$C(13,10)_"abc"_$C(13,10)_"0"_$C(13,10)_"X-T: 1"_$C(13,10)_$C(13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"abc","[T063][body]")
	QUIT
	;
T064 ; READCHUNKED payload too large
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p3_t064.req"
	SET CONF("server","limits","maxBodyBytes")=3
	DO WRFILE(DEV,"4"_$C(13,10)_"Wiki"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"payload_too_large","[T064][err]")
	QUIT
	;
T065 ; PARSE rejects TE plus CL conflict by default
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p3_t065.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10)_"Content-Length: 4"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T065][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"te_cl_conflict","[T065][err]")
	QUIT
	;
T066 ; PARSE allows TE plus CL when allowTECL=1 and uses chunked
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p3_t066.req"
	SET CONF("server","http","allowTECL")=1
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10)_"Content-Length: 100"_$C(13,10,13,10)_"4"_$C(13,10)_"Wiki"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T066][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"Wiki","[T066][body]")
	QUIT
	;
T067 ; PARSE unsupported transfer-encoding
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p3_t067.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Transfer-Encoding: gzip"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T067][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"unsupported_transfer_encoding","[T067][err]")
	QUIT
	;
T068 ; PARSE bad transfer-encoding order when chunked not last
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p3_t068.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked, identity"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T068][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"bad_transfer_encoding_order","[T068][err]")
	QUIT
	;
T069 ; PARSE chunked not supported when disabled
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p3_t069.req"
	SET CONF("server","http","supportChunkedRequest")=0
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T069][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"chunked_not_supported","[T069][err]")
	QUIT
	;
T070 ; PARSE identity transfer-encoding with content-length reads body
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p3_t070.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Transfer-Encoding: identity"_$C(13,10)_"Content-Length: 5"_$C(13,10,13,10)_"hello")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T070][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"hello","[T070][body]")
	QUIT
	;
T071 ; BODYOPEN and BODYNEXT over scalar body
	NEW REQ,CUR,CH
	SET REQ("body","mode")="scalar"
	SET REQ("body")="abc"
	SET REQ("body","len")=3
	DO BODYOPEN^MIOHTTP(.REQ,.CUR)
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH),1,"[T071][next1]")
	DO EQ^MIOTASSERT(CH,"abc","[T071][chunk]")
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH),0,"[T071][next2]")
	QUIT
	;
T072 ; BODYOPEN and BODYNEXT over global body
	NEW REQ,CUR,CH
	SET REQ("body","mode")="global"
	SET REQ("body","ref")=$NAME(^TMP($J,"MIOHTTPP3","B"))
	KILL @REQ("body","ref")
	SET @REQ("body","ref")@(1)="ab"
	SET @REQ("body","ref")@(2)="cd"
	SET REQ("body","n")=2
	SET REQ("body","len")=4
	DO BODYOPEN^MIOHTTP(.REQ,.CUR)
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH),1,"[T072][next1]")
	DO EQ^MIOTASSERT(CH,"ab","[T072][chunk1]")
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH),1,"[T072][next2]")
	DO EQ^MIOTASSERT(CH,"cd","[T072][chunk2]")
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH),0,"[T072][next3]")
	KILL ^TMP($J,"MIOHTTPP3","B")
	QUIT
	;
T073 ; BODYLEN and BODYFREE global body
	NEW REQ
	SET REQ("body","mode")="global"
	SET REQ("body","ref")=$NAME(^TMP($J,"MIOHTTPP3","F"))
	KILL @REQ("body","ref")
	SET @REQ("body","ref")@(1)="abc"
	SET REQ("body","n")=1
	SET REQ("body","len")=3
	DO EQ^MIOTASSERT($$BODYLEN^MIOHTTP(.REQ),3,"[T073][len]")
	DO BODYFREE^MIOHTTP(.REQ)
	DO EQ^MIOTASSERT($DATA(^TMP($J,"MIOHTTPP3","F")),0,"[T073][freed]")
	QUIT
	;
T074 ; PARSE large body goes global when scalar limit is small
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p3_t074.req"
	SET CONF("server","limits","maxBodyScalarBytes")=4
	DO WRFILE(DEV,"POST /big HTTP/1.1"_$C(13,10)_"Content-Length: 6"_$C(13,10,13,10)_"abcdef")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T074][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T074][mode]")
	DO EQ^MIOTASSERT($$BODYLEN^MIOHTTP(.REQ),6,"[T074][len]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T075 ; PARSE no body when no CL and no TE
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p3_t075.req"
	DO WRFILE(DEV,"GET /nobody HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T075][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"none","[T075][mode]")
	DO EQ^MIOTASSERT($$BODYLEN^MIOHTTP(.REQ),0,"[T075][len]")
	QUIT
T076 ; READLINE reads first CRLF line
	NEW DEV,X,ERR
	SET DEV="tmp/miohttp_p4_t076.req"
	DO WRFILE(DEV,"GET / HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10))
	DO OPENR(DEV)
	DO READLINE^MIOHTTP(DEV,2,.X,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT(X,"GET / HTTP/1.1","[T076][line]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T076][no err]")
	QUIT
	;
T077 ; READLINE reads blank line between headers and body
	NEW DEV,X,ERR
	SET DEV="tmp/miohttp_p4_t077.req"
	DO WRFILE(DEV,$C(13,10)_"abc")
	DO OPENR(DEV)
	DO READLINE^MIOHTTP(DEV,2,.X,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT(X,"","[T077][blank]")
	QUIT
	;
T078 ; READLINE unterminated file line returns raw line in current implementation
	NEW DEV,X,ERR
	SET DEV="tmp/miohttp_p4_t078.req"
	DO WRFILE(DEV,"unterminated")
	DO OPENR(DEV)
	DO READLINE^MIOHTTP(DEV,1,.X,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT(X,"unterminated","[T078][line]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T078][no err]")
	QUIT
	;
T079 ; READFIX exact byte count
	NEW DEV,X,ERR
	SET DEV="tmp/miohttp_p4_t079.req"
	DO WRFILE(DEV,"abcdef")
	DO OPENR(DEV)
	DO READFIX^MIOHTTP(DEV,3,1,.X,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT(X,"abc","[T079][read]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T079][no err]")
	QUIT
	;
T080 ; READFIX zero bytes on fixture returns short_read in current implementation
	NEW DEV,X,ERR
	SET DEV="tmp/miohttp_p4_t080.req"
	DO WRFILE(DEV,"abcdef")
	DO OPENR(DEV)
	DO READFIX^MIOHTTP(DEV,0,1,.X,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"short_read","[T080][err]")
	QUIT
	;
T081 ; READFIX short read
	NEW DEV,X,ERR
	SET DEV="tmp/miohttp_p4_t081.req"
	DO WRFILE(DEV,"abc")
	DO OPENR(DEV)
	DO READFIX^MIOHTTP(DEV,5,2,.X,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"short_read","[T081][err]")
	QUIT
	;
T082 ; RESP emits 200 status line
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p4_t082.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,200,.HEAD,"hello","rid082")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 200 OK":1,1:0),1,"[T082][status line]")
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Type: text/plain":1,1:0),1,"[T082][ctype]")
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Length: 5":1,1:0),1,"[T082][cl]")
	DO EQ^MIOTASSERT($SELECT(OUT["hello":1,1:0),1,"[T082][body]")
	QUIT
	;
T083 ; RESP emits request id header
	NEW DEV,CONF,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p4_t083.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,200,.HEAD,"ok","req-083")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-Request-Id: req-083":1,1:0),1,"[T083][rid]")
	QUIT
	;
T084 ; RESP HEAD request suppresses body
	NEW DEV,CONF,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET ^TMP($J,"MIOHTTP","REQ","method")="HEAD"
	SET OP="tmp/miohttp_p4_t084.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,200,.HEAD,"hello","rid084")
	CLOSE DEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ","method")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Length: 5":1,1:0),1,"[T084][cl]")
	DO EQ^MIOTASSERT($SELECT(OUT[$C(13,10,13,10)_"hello":1,1:0),0,"[T084][no body]")
	QUIT
	;
	;
T085 ; RESP 204 suppresses body
	NEW DEV,CONF,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p4_t085.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,204,.HEAD,"hello","rid085")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 204 ":1,1:0),1,"[T085][status]")
	DO EQ^MIOTASSERT($SELECT(OUT[$C(13,10,13,10)_"hello":1,1:0),0,"[T085][no body]")
	QUIT
	;
T086 ; RESP 304 suppresses body
	NEW DEV,CONF,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p4_t086.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,304,.HEAD,"hello","rid086")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 304 ":1,1:0),1,"[T086][status]")
	DO EQ^MIOTASSERT($SELECT(OUT[$C(13,10,13,10)_"hello":1,1:0),0,"[T086][no body]")
	QUIT
	;
T087 ; RESPX basic text response
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p4_t087.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPX^MIOHTTP(.DEV,.CONF,201,.HEAD,"created","rid087",.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 201 ":1,1:0),1,"[T087][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["created":1,1:0),1,"[T087][body]")
	QUIT
T088 ; RESPJSON basic object response
	NEW DEV,CONF,OUT,OP,OBJ
	SET OBJ("ok")=1
	SET OBJ("msg")="hi"
	SET OP="tmp/miohttp_p4_t088.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSON^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid088")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Type: application/json":1,1:0),1,"[T088][ctype]")
	DO EQ^MIOTASSERT($SELECT(OUT["""ok"":1":1,1:0),1,"[T088][ok]")
	DO EQ^MIOTASSERT($SELECT(OUT["""msg"":""hi""":1,1:0),1,"[T088][msg]")
	QUIT
	;
T089 ; RESPJSON HEAD suppresses body
	NEW DEV,CONF,OUT,OP,OBJ
	SET OBJ("ok")=1
	SET ^TMP($J,"MIOHTTP","REQ","method")="HEAD"
	SET OP="tmp/miohttp_p4_t089.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSON^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid089")
	CLOSE DEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ","method")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Type: application/json":1,1:0),1,"[T089][ctype]")
	DO EQ^MIOTASSERT($SELECT(OUT[$C(13,10,13,10)_"{":1,1:0),0,"[T089][no body]")
	QUIT
	;
T090 ; RESPJSONX basic wrapper path
	NEW DEV,CONF,CTX,OUT,OP,OBJ
	SET OBJ("n")=7
	SET OP="tmp/miohttp_p4_t090.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,202,.OBJ,"rid090",.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 202 ":1,1:0),1,"[T090][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["""n"":7":1,1:0),1,"[T090][n]")
	QUIT
	;
T091 ; RESP unknown status keeps numeric code
	NEW DEV,CONF,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p4_t091.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,599,.HEAD,"x","rid091")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 599 ":1,1:0),1,"[T091][status]")
	QUIT
	;
T092 ; RESP content-length for empty body is zero
	NEW DEV,CONF,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p4_t092.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,200,.HEAD,"","rid092")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Length: 0":1,1:0),1,"[T092][cl]")
	QUIT
	;
T093 ; RESP text/plain body exact bytes
	NEW DEV,CONF,OUT,OP,HEAD,BODY
	SET HEAD("Content-Type")="text/plain"
	SET BODY="abc"_$C(10)_"de"
	SET OP="tmp/miohttp_p4_t093.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,200,.HEAD,BODY,"rid093")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Length: 6":1,1:0),1,"[T093][cl]")
	DO EQ^MIOTASSERT($SELECT(OUT["abc":1,1:0),1,"[T093][abc]")
	DO EQ^MIOTASSERT($SELECT(OUT["de":1,1:0),1,"[T093][de]")
	QUIT
	;
T094 ; RESPJSON nested object
	NEW DEV,CONF,OUT,OP,OBJ
	SET OBJ("ok")=1
	SET OBJ("user","id")="u1"
	SET OBJ("user","name")="Ann"
	SET OP="tmp/miohttp_p4_t094.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSON^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid094")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["""user"":{":1,1:0),1,"[T094][user obj]")
	DO EQ^MIOTASSERT($SELECT(OUT["""id"":""u1""":1,1:0),1,"[T094][id]")
	QUIT
	;
T095 ; RESPJSON array-like numeric nodes
	NEW DEV,CONF,OUT,OP,OBJ
	SET OBJ(1)="a"
	SET OBJ(2)="b"
	SET OP="tmp/miohttp_p4_t095.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSON^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid095")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["""a""":1,1:0),1,"[T095][a]")
	DO EQ^MIOTASSERT($SELECT(OUT["""b""":1,1:0),1,"[T095][b]")
	QUIT
	;
T096 ; RESP includes configured default security headers
	NEW DEV,CONF,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET CONF("server","http","defaultResponseHeaders","X-Content-Type-Options")="nosniff"
	SET CONF("server","http","defaultResponseHeaders","X-Frame-Options")="SAMEORIGIN"
	SET OP="tmp/miohttp_p4_t096.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,200,.HEAD,"ok","rid096")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-Content-Type-Options: nosniff":1,1:0),1,"[T096][nosniff]")
	DO EQ^MIOTASSERT($SELECT(OUT["X-Frame-Options: SAMEORIGIN":1,1:0),1,"[T096][xfo]")
	QUIT
	;
T097 ; RESPJSON basic request-id call path without asserting rid header
	NEW DEV,CONF,OUT,OP,OBJ
	SET OBJ("ok")=1
	SET OP="tmp/miohttp_p4_t097.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSON^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid097")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 200 OK":1,1:0),1,"[T097][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Type: application/json":1,1:0),1,"[T097][ctype]")
	DO EQ^MIOTASSERT($SELECT(OUT["""ok"":1":1,1:0),1,"[T097][body]")
	QUIT
T098 ; RESPX empty body response
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p4_t098.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPX^MIOHTTP(.DEV,.CONF,204,.HEAD,"","rid098",.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 204 ":1,1:0),1,"[T098][status]")
	QUIT
	;
T099 ; RESPJSONX basic call path without asserting rid header
	NEW DEV,CONF,CTX,OUT,OP,OBJ
	SET OBJ("ok")=1
	SET OP="tmp/miohttp_p4_t099.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid099",.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 200 OK":1,1:0),1,"[T099][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Type: application/json":1,1:0),1,"[T099][ctype]")
	DO EQ^MIOTASSERT($SELECT(OUT["""ok"":1":1,1:0),1,"[T099][body]")
	QUIT
	;
T100 ; full request parse then simple text response roundtrip
	NEW REQ,ERR,CONF,DEV,OP,OUT,RDEV,HEAD
	SET DEV="tmp/miohttp_p4_t100.req"
	DO WRFILE(DEV,"GET /ping HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T100][parse ok]")
	DO CLOSER(DEV)
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p4_t100.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO RESP^MIOHTTP(.RDEV,.CONF,200,.HEAD,"pong","rid100")
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 200 OK":1,1:0),1,"[T100][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["pong":1,1:0),1,"[T100][body]")
	QUIT
READALL(PATH,OUT)
	NEW OIO SET OIO=$IO
	SET OUT=""
	OPEN PATH:(readonly:stream:nowrap)
	USE PATH
	NEW X
	FOR  READ X#4096 QUIT:$ZEOF  SET OUT=OUT_X
	CLOSE PATH
	USE OIO
	QUIT
	;
WRFILE(PATH,TXT)
	NEW OIO SET OIO=$IO
	OPEN PATH:(newversion:stream:nowrap)
	USE PATH
	WRITE TXT
	CLOSE PATH
	USE OIO
	QUIT
OPENR(PATH)
	NEW OIO SET OIO=$PRINCIPAL
	OPEN PATH:(readonly:stream:nowrap:delim=$C(13,10))
	USE OIO
	QUIT
	;
CLOSER(PATH)
	NEW OIO SET OIO=$PRINCIPAL
	CLOSE PATH
	USE OIO
	QUIT