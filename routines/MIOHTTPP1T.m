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
	D T101 ; CURMETH default is get
	D T102 ; CURMETH reads lowercase method slot
	D T103 ; CURMETH falls back to uppercase METHOD slot
	D T104 ; NOBODY for 1xx/204/205/304
	D T105 ; BODYINIT scalar expected length
	D T106 ; BODYINIT global expected length
	D T107 ; BODYAPPEND scalar under threshold
	D T108 ; BODYAPPEND triggers upgrade to global
	D T109 ; BODYAPPG appends two global chunks
	D T110 ; BODYUP preserves prior scalar bytes
	D T111 ; KILLBODYVAL removes scalar value but keeps descendants
	D T112 ; STREAMBEGIN sets chunked for normal 200
	D T113 ; STREAMBEGIN for HEAD suppresses body writes
	D T114 ; STREAMBEGIN for 204 uses content-length 0 not chunked
	D T115 ; STREAMWRITE emits one chunk
	D T116 ; STREAMWRITE ignores empty data
	D T117 ; STREAMEND writes final zero chunk when chunked
	D T118 ; WRESP stream byte accounting increments
	D T119 ; HEXOUT basic values
	D T120 ; SENDFILE GET streams file content
	D T121 ; SENDFILE HEAD suppresses file body
	D T122 ; SENDFILE missing path fails
	D T123 ; SENDFILE open failure reports error
	D T124 ; STREAMBEGIN merges default response headers
	D T125 ; STREAMBEGIN records ctx status
	D T126 ; SEND100 emits continue response
	D T127 ; STATUS4ERR payload too large
	D T128 ; STATUS4ERR headers too large
	D T129 ; STATUS4ERR too many headers
	D T130 ; STATUS4ERR read timeout
	D T131 ; STATUS4ERR fallback to 400
	D T132 ; LIM returns configured value
	D T133 ; LIM falls back to default
	D T134 ; TRIM left right and all-space
	D T135 ; LOW letters digits punctuation
	D T136 ; HTOK accepts common token chars
	D T137 ; HTOK rejects separators and ctl
	D T138 ; HVALOK accepts empty and visible ascii
	D T139 ; HVALOK rejects CR LF
	D T140 ; PARSEQRY decodes spaces and slash in values
	D T141 ; URLDECQ percent plus percent
	D T142 ; PARSE simple GET HTTP/1.0 no host
	D T143 ; PARSE GET with multiple query params
	D T144 ; PARSE POST empty body with CL 0
	D T145 ; PARSE POST normal scalar body and body iterator
	D T146 ; PARSE chunked body end-to-end
	D T147 ; PARSE host and content-type together
	D T148 ; PARSE query path plus body
	D T149 ; PARSE large scalar threshold forces global body
	D T150 ; RESP with configured default response header
	D T151 ; PARSE PUT request with body
	D T152 ; PARSE DELETE request no body
	D T153 ; PARSE PATCH request with query and body
	D T154 ; PARSE query params with empty and encoded values
	D T155 ; PARSE duplicate normal header last one wins
	D T156 ; PARSE accepts transfer-encoding identity
	D T157 ; PARSE chunked with two chunks end-to-end
	D T158 ; PARSE chunked with trailer lines
	D T159 ; PARSE payload too large from content-length
	D T160 ; EXPECTDECIDE with mixed-case expect and exact max body
	D T161 ; EXPECTDECIDE with unknown expect value passes through current behavior
	D T162 ; STATUSMSG common statuses
	D T163 ; RESP merges explicit and default headers
	D T164 ; RESPJSON with default headers
	D T165 ; STREAMWRITE two chunks
	D T166 ; STREAMWRITE updates byte count across multiple writes
	D T167 ; SENDFILE with default headers
	D T168 ; SENDFILE explicit method argument HEAD suppresses body
	D T169 ; BODYAPPEND multiple scalar appends stay scalar
	D T170 ; BODYAPPEND after upgrade keeps total length
	D T171 ; PARSE HTTP/1.1 path only no headers
	D T172 ; PARSE header value with tabs
	D T173 ; PARSE content-length with leading zeros
	D T174 ; RESPJSONX nested object
	D T175 ; RESPX with default and explicit headers
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
T101 ; CURMETH default is get
	KILL ^TMP($J,"MIOHTTP","REQ")
	DO EQ^MIOTASSERT($$CURMETH^MIOHTTP(),"get","[T101][default]")
	QUIT
	;
T102 ; CURMETH reads lowercase method slot
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="POST"
	DO EQ^MIOTASSERT($$CURMETH^MIOHTTP(),"post","[T102][post]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T103 ; CURMETH falls back to uppercase METHOD slot
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","METHOD")="HEAD"
	DO EQ^MIOTASSERT($$CURMETH^MIOHTTP(),"head","[T103][head]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T104 ; NOBODY for 1xx/204/205/304
	DO EQ^MIOTASSERT($$NOBODY^MIOHTTP(101),1,"[T104][101]")
	DO EQ^MIOTASSERT($$NOBODY^MIOHTTP(204),1,"[T104][204]")
	DO EQ^MIOTASSERT($$NOBODY^MIOHTTP(205),1,"[T104][205]")
	DO EQ^MIOTASSERT($$NOBODY^MIOHTTP(304),1,"[T104][304]")
	DO EQ^MIOTASSERT($$NOBODY^MIOHTTP(200),0,"[T104][200]")
	QUIT
	;
T105 ; BODYINIT scalar expected length
	NEW REQ,CONF
	KILL REQ,CONF
	SET CONF("server","limits","maxBodyScalarBytes")=10
	DO BODYINIT^MIOHTTP(.REQ,.CONF,5)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"scalar","[T105][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body","len")),0,"[T105][len]")
	QUIT
	;
T106 ; BODYINIT global expected length
	NEW REQ,CONF
	KILL REQ,CONF
	SET CONF("server","limits","maxBodyScalarBytes")=4
	DO BODYINIT^MIOHTTP(.REQ,.CONF,6)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T106][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body","ref"))'="",1,"[T106][ref]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T107 ; BODYAPPEND scalar under threshold
	NEW REQ,CONF,ERR
	KILL REQ,CONF,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=10
	DO BODYINIT^MIOHTTP(.REQ,.CONF,2)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"ab",.ERR)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"scalar","[T107][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"ab","[T107][body]")
	DO EQ^MIOTASSERT($GET(REQ("body","len")),2,"[T107][len]")
	QUIT
	;
T108 ; BODYAPPEND triggers upgrade to global
	NEW REQ,CONF,ERR
	KILL REQ,CONF,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=3
	DO BODYINIT^MIOHTTP(.REQ,.CONF,2)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"ab",.ERR)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"cd",.ERR)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T108][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body","n")),2,"[T108][n]")
	DO EQ^MIOTASSERT($GET(REQ("body","len")),4,"[T108][len]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T109 ; BODYAPPG appends two global chunks
	NEW REQ
	KILL REQ
	SET REQ("body","mode")="global"
	SET REQ("body","ref")=$NAME(^TMP($J,"MIOHTTPP5","G1"))
	SET REQ("body","n")=0
	KILL ^TMP($J,"MIOHTTPP5","G1")
	DO BODYAPPG^MIOHTTP(.REQ,"ab")
	DO BODYAPPG^MIOHTTP(.REQ,"cd")
	DO EQ^MIOTASSERT($GET(REQ("body","n")),2,"[T109][n]")
	DO EQ^MIOTASSERT($GET(^TMP($J,"MIOHTTPP5","G1",1)),"ab","[T109][1]")
	DO EQ^MIOTASSERT($GET(^TMP($J,"MIOHTTPP5","G1",2)),"cd","[T109][2]")
	KILL ^TMP($J,"MIOHTTPP5","G1")
	QUIT
	;
T110 ; BODYUP preserves prior scalar bytes
	NEW REQ,CONF
	KILL REQ,CONF
	SET REQ("body")="abc"
	SET REQ("body","len")=3
	SET CONF("server","limits","maxBodyScalarBytes")=2
	DO BODYUP^MIOHTTP(.REQ,.CONF)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T110][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body","len")),3,"[T110][len]")
	DO EQ^MIOTASSERT($GET(@REQ("body","ref")@(1)),"abc","[T110][chunk]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T111 ; KILLBODYVAL removes scalar value but keeps descendants
	NEW REQ
	KILL REQ
	SET REQ("body")="abc"
	SET REQ("body","mode")="global"
	SET REQ("body","len")=3
	DO KILLBODYVAL^MIOHTTP(.REQ)
	DO EQ^MIOTASSERT($DATA(REQ("body")),10,"[T111][no scalar has descendants]")
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T111][mode]")
	QUIT
	;
T112 ; STREAMBEGIN sets chunked for normal 200
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p5_t112.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid112",.CTX)
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Transfer-Encoding: chunked":1,1:0),1,"[T112][chunked]")
	DO EQ^MIOTASSERT($SELECT(OUT["X-Request-Id: rid112":1,1:0),1,"[T112][rid]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T113 ; STREAMBEGIN for HEAD suppresses body writes
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="HEAD"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p5_t113.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid113",.CTX)
	DO STREAMWRITE^MIOHTTP(.DEV,"hello")
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["hello":1,1:0),0,"[T113][no body]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T114 ; STREAMBEGIN for 204 uses content-length 0 not chunked
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p5_t114.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,204,.HEAD,"rid114",.CTX)
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Length: 0":1,1:0),1,"[T114][cl0]")
	DO EQ^MIOTASSERT($SELECT(OUT["Transfer-Encoding: chunked":1,1:0),0,"[T114][not chunked]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T115 ; STREAMWRITE emits one chunk
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p5_t115.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid115",.CTX)
	DO STREAMWRITE^MIOHTTP(.DEV,"abc")
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["3"_$C(13,10)_"abc"_$C(13,10):1,1:0),1,"[T115][chunk]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T116 ; STREAMWRITE ignores empty data
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p5_t116.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid116",.CTX)
	DO STREAMWRITE^MIOHTTP(.DEV,"")
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["0"_$C(13,10,13,10):1,1:0),1,"[T116][end only]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T117 ; STREAMEND writes final zero chunk when chunked
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p5_t117.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid117",.CTX)
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["0"_$C(13,10,13,10):1,1:0),1,"[T117][zero chunk]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T118 ; WRESP stream byte accounting increments
	NEW DEV,OUT,OP
	SET OP="tmp/miohttp_p5_t118.out"
	KILL ^TMP($J,"MIOHTTP","STREAM")
	SET ^TMP($J,"MIOHTTP","STREAM","active")=1
	SET ^TMP($J,"MIOHTTP","STREAM","bytes")=0
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO WRESP^MIOHTTP(.DEV,"abc")
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($GET(^TMP($J,"MIOHTTP","STREAM","bytes")),3,"[T118][bytes]")
	KILL ^TMP($J,"MIOHTTP","STREAM")
	QUIT
	;
T119 ; HEXOUT basic values
	DO EQ^MIOTASSERT($$HEXOUT^MIOHTTP(0),"0","[T119][0]")
	DO EQ^MIOTASSERT($$HEXOUT^MIOHTTP(10),"A","[T119][10]")
	DO EQ^MIOTASSERT($$HEXOUT^MIOHTTP(31),"1F","[T119][31]")
	QUIT
	;
T120 ; SENDFILE GET streams file content
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p5_t120.txt"
	DO WRFILE(FP,"hello world")
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p5_t120.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid120",.CTX,"GET"),1,"[T120][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["hello world":1,1:0),1,"[T120][body]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T121 ; SENDFILE HEAD suppresses file body
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p5_t121.txt"
	DO WRFILE(FP,"hello world")
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="HEAD"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p5_t121.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid121",.CTX,"HEAD"),1,"[T121][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["hello world":1,1:0),0,"[T121][no body]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T122 ; SENDFILE missing path fails
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	SET OP="tmp/miohttp_p5_t122.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,"",.HEAD,"rid122",.CTX,"GET"),0,"[T122][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($GET(CTX("err","error")),"file_not_specified","[T122][err]")
	QUIT
	;
T123 ; SENDFILE open failure reports error
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	SET OP="tmp/miohttp_p5_t123.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,"tmp/no_such_file_123.txt",.HEAD,"rid123",.CTX,"GET"),0,"[T123][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($GET(CTX("err","error")),"open_failed","[T123][err]")
	QUIT
	;
T124 ; STREAMBEGIN merges default response headers
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET CONF("server","http","defaultResponseHeaders","X-Test")="abc"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p5_t124.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid124",.CTX)
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-Test: abc":1,1:0),1,"[T124][default hdr]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T125 ; STREAMBEGIN records ctx status
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p5_t125.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,206,.HEAD,"rid125",.CTX)
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($GET(CTX("status")),206,"[T125][ctx status]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
T126 ; SEND100 emits continue response
	NEW DEV,OUT,OP
	SET OP="tmp/miohttp_p6_t126.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO SEND100^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 100 Continue":1,1:0),1,"[T126][status]")
	QUIT
	;
T127 ; STATUS4ERR payload too large
	NEW ERR
	SET ERR("error")="payload_too_large"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),413,"[T127][413]")
	QUIT
	;
T128 ; STATUS4ERR headers too large
	NEW ERR
	SET ERR("error")="headers_too_large"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),431,"[T128][431]")
	QUIT
	;
T129 ; STATUS4ERR too many headers
	NEW ERR
	SET ERR("error")="too_many_headers"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),431,"[T129][431]")
	QUIT
	;
T130 ; STATUS4ERR read timeout
	NEW ERR
	SET ERR("error")="read_timeout"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),408,"[T130][408]")
	QUIT
	;
T131 ; STATUS4ERR fallback to 400
	NEW ERR
	SET ERR("error")="something_unknown"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),400,"[T131][400]")
	QUIT
	;
T132 ; LIM returns configured value
	NEW CONF
	SET CONF("server","limits","maxBodyBytes")=999
	DO EQ^MIOTASSERT($$LIM^MIOHTTP(.CONF,"maxBodyBytes",123),999,"[T132][configured]")
	QUIT
	;
T133 ; LIM falls back to default
	NEW CONF
	KILL CONF
	DO EQ^MIOTASSERT($$LIM^MIOHTTP(.CONF,"maxBodyBytes",123),123,"[T133][default]")
	QUIT
	;
T134 ; TRIM left right and all-space
	DO EQ^MIOTASSERT($$TRIM^MIOHTTP("  abc"),"abc","[T134][left]")
	DO EQ^MIOTASSERT($$TRIM^MIOHTTP("abc  "),"abc","[T134][right]")
	DO EQ^MIOTASSERT($$TRIM^MIOHTTP("   "),"","[T134][all space]")
	QUIT
	;
T135 ; LOW letters digits punctuation
	DO EQ^MIOTASSERT($$LOW^MIOHTTP("ABCxyz"),"abcxyz","[T135][letters]")
	DO EQ^MIOTASSERT($$LOW^MIOHTTP("A1-B_."),"a1-b_.","[T135][mixed]")
	QUIT
	;
T136 ; HTOK accepts common token chars
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("x-tag"),1,"[T136][dash]")
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("x_tag"),1,"[T136][underscore]")
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("x.tag"),1,"[T136][dot]")
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("x~tag"),1,"[T136][tilde]")
	QUIT
	;
T137 ; HTOK rejects separators and ctl
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("x:tag"),0,"[T137][colon]")
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("x(tag)"),0,"[T137][paren]")
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("x"_$C(9)_"tag"),0,"[T137][tab]")
	QUIT
	;
T138 ; HVALOK accepts empty and visible ascii
	DO EQ^MIOTASSERT($$HVALOK^MIOHTTP(""),1,"[T138][empty]")
	DO EQ^MIOTASSERT($$HVALOK^MIOHTTP("gzip, deflate"),1,"[T138][csv]")
	DO EQ^MIOTASSERT($$HVALOK^MIOHTTP("abc-123_/;=."),1,"[T138][visible]")
	QUIT
	;
T139 ; HVALOK rejects CR LF
	DO EQ^MIOTASSERT($$HVALOK^MIOHTTP("a"_$C(13)_"b"),0,"[T139][cr]")
	DO EQ^MIOTASSERT($$HVALOK^MIOHTTP("a"_$C(10)_"b"),0,"[T139][lf]")
	QUIT
	;
T140 ; PARSEQRY decodes spaces and slash in values
	NEW REQ
	KILL REQ
	DO PARSEQRY^MIOHTTP("/x?a=hello+world&b=a%2Fb",.REQ)
	DO EQ^MIOTASSERT($GET(REQ("query","a")),"hello world","[T140][a]")
	DO EQ^MIOTASSERT($GET(REQ("query","b")),"a/b","[T140][b]")
	QUIT
	;
T141 ; URLDECQ percent plus percent
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("%2B+%2F"),"+ /","[T141][decode]")
	QUIT
	;
T142 ; PARSE simple GET HTTP/1.0 no host
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p6_t142.req"
	DO WRFILE(DEV,"GET /legacy HTTP/1.0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T142][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("httpver")),"HTTP/1.0","[T142][ver]")
	DO EQ^MIOTASSERT($GET(REQ("path")),"/legacy","[T142][path]")
	QUIT
	;
T143 ; PARSE GET with multiple query params
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p6_t143.req"
	DO WRFILE(DEV,"GET /items?page=2&sort=asc HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T143][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("query","page")),"2","[T143][page]")
	DO EQ^MIOTASSERT($GET(REQ("query","sort")),"asc","[T143][sort]")
	QUIT
	;
T144 ; PARSE POST empty body with CL 0
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p6_t144.req"
	DO WRFILE(DEV,"POST /empty HTTP/1.1"_$C(13,10)_"Content-Length: 0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T144][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"none","[T144][mode]")
	DO EQ^MIOTASSERT($$BODYLEN^MIOHTTP(.REQ),0,"[T144][len]")
	QUIT
	;
T145 ; PARSE POST normal scalar body and body iterator
	NEW CONF,REQ,ERR,DEV,CUR,CH
	SET DEV="tmp/miohttp_p6_t145.req"
	DO WRFILE(DEV,"POST /echo HTTP/1.1"_$C(13,10)_"Content-Length: 3"_$C(13,10,13,10)_"hey")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T145][ok]")
	DO CLOSER(DEV)
	DO BODYOPEN^MIOHTTP(.REQ,.CUR)
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH),1,"[T145][next]")
	DO EQ^MIOTASSERT(CH,"hey","[T145][chunk]")
	QUIT
	;
T146 ; PARSE chunked body end-to-end
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","http","supportChunkedRequest")=1
	SET DEV="tmp/miohttp_p6_t146.req"
	DO WRFILE(DEV,"POST /chunk HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10,13,10)_"3"_$C(13,10)_"abc"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T146][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"abc","[T146][body]")
	QUIT
	;
T147 ; PARSE host and content-type together
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p6_t147.req"
	DO WRFILE(DEV,"POST /form HTTP/1.1"_$C(13,10)_"Host: example.com"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: 3"_$C(13,10,13,10)_"a=1")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T147][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("hdr","host")),"example.com","[T147][host]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","content-type")),"application/x-www-form-urlencoded","[T147][ctype]")
	QUIT
	;
T148 ; PARSE query path plus body
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p6_t148.req"
	DO WRFILE(DEV,"POST /submit?id=9 HTTP/1.1"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10)_"ok")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T148][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("path")),"/submit","[T148][path]")
	DO EQ^MIOTASSERT($GET(REQ("query","id")),"9","[T148][id]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"ok","[T148][body]")
	QUIT
	;
T149 ; PARSE large scalar threshold forces global body
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","limits","maxBodyScalarBytes")=2
	SET DEV="tmp/miohttp_p6_t149.req"
	DO WRFILE(DEV,"POST /up HTTP/1.1"_$C(13,10)_"Content-Length: 4"_$C(13,10,13,10)_"abcd")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T149][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T149][mode]")
	DO EQ^MIOTASSERT($$BODYLEN^MIOHTTP(.REQ),4,"[T149][len]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T150 ; RESP with configured default response header
	NEW DEV,CONF,OUT,OP,HEAD
	SET CONF("server","http","defaultResponseHeaders","X-App")="mio"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p6_t150.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,200,.HEAD,"ok","rid150")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: mio":1,1:0),1,"[T150][x-app]")
	QUIT
T151 ; PARSE PUT request with body
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p7_t151.req"
	DO WRFILE(DEV,"PUT /item/1 HTTP/1.1"_$C(13,10)_"Content-Length: 3"_$C(13,10,13,10)_"abc")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T151][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("method")),"PUT","[T151][method]")
	DO EQ^MIOTASSERT($GET(REQ("path")),"/item/1","[T151][path]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"abc","[T151][body]")
	QUIT
	;
T152 ; PARSE DELETE request no body
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p7_t152.req"
	DO WRFILE(DEV,"DELETE /item/1 HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T152][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("method")),"DELETE","[T152][method]")
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"none","[T152][mode]")
	QUIT
	;
T153 ; PARSE PATCH request with query and body
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p7_t153.req"
	DO WRFILE(DEV,"PATCH /thing?id=7 HTTP/1.1"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10)_"ok")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T153][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("query","id")),"7","[T153][id]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"ok","[T153][body]")
	QUIT
	;
T154 ; PARSE query params with empty and encoded values
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p7_t154.req"
	DO WRFILE(DEV,"GET /q?a=&b=hello+world&c=x%2Fy HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T154][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("query","a")),"","[T154][a]")
	DO EQ^MIOTASSERT($GET(REQ("query","b")),"hello world","[T154][b]")
	DO EQ^MIOTASSERT($GET(REQ("query","c")),"x/y","[T154][c]")
	QUIT
	;
T155 ; PARSE duplicate normal header last one wins
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p7_t155.req"
	DO WRFILE(DEV,"GET /x HTTP/1.1"_$C(13,10)_"X-Test: a"_$C(13,10)_"X-Test: b"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T155][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-test")),"b","[T155][x-test]")
	QUIT
	;
T156 ; PARSE accepts transfer-encoding identity
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p7_t156.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Transfer-Encoding: identity"_$C(13,10)_"Content-Length: 4"_$C(13,10,13,10)_"test")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T156][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"test","[T156][body]")
	QUIT
	;
T157 ; PARSE chunked with two chunks end-to-end
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","http","supportChunkedRequest")=1
	SET DEV="tmp/miohttp_p7_t157.req"
	DO WRFILE(DEV,"POST /c HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10,13,10)_"2"_$C(13,10)_"ab"_$C(13,10)_"3"_$C(13,10)_"cde"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T157][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"abcde","[T157][body]")
	QUIT
	;
T158 ; PARSE chunked with trailer lines
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","http","supportChunkedRequest")=1
	SET DEV="tmp/miohttp_p7_t158.req"
	DO WRFILE(DEV,"POST /c HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10,13,10)_"1"_$C(13,10)_"x"_$C(13,10)_"0"_$C(13,10)_"X-T: 1"_$C(13,10)_$C(13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T158][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"x","[T158][body]")
	QUIT
	;
T159 ; PARSE payload too large from content-length
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","limits","maxBodyBytes")=2
	SET DEV="tmp/miohttp_p7_t159.req"
	DO WRFILE(DEV,"POST /big HTTP/1.1"_$C(13,10)_"Content-Length: 3"_$C(13,10,13,10)_"abc")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T159][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"payload_too_large","[T159][err]")
	QUIT
	;
T160 ; EXPECTDECIDE with mixed-case expect and exact max body
	NEW CONF,REQ,ERR
	SET REQ("hdr","expect")="100-ConTinue"
	SET REQ("hdr","content-length")=10
	SET CONF("server","limits","maxBodyBytes")=10
	DO EQ^MIOTASSERT($$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR),1,"[T160][ok]")
	QUIT
	;
T161 ; EXPECTDECIDE with unknown expect value passes through current behavior
	NEW CONF,REQ,ERR
	SET REQ("hdr","expect")="something-else"
	DO EQ^MIOTASSERT($$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR),1,"[T161][ok]")
	QUIT
	;
T162 ; STATUSMSG common statuses
	DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(400),"Bad Request","[T162][400]")
	DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(401),"Unauthorized","[T162][401]")
	DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(405),"Method Not Allowed","[T162][405]")
	DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(500),"Internal Server Error","[T162][500]")
	QUIT
	;
T163 ; RESP merges explicit and default headers
	NEW DEV,CONF,OUT,OP,HEAD
	SET CONF("server","http","defaultResponseHeaders","X-App")="mio"
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("X-Extra")="yes"
	SET OP="tmp/miohttp_p7_t163.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,200,.HEAD,"ok","rid163")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: mio":1,1:0),1,"[T163][x-app]")
	DO EQ^MIOTASSERT($SELECT(OUT["X-Extra: yes":1,1:0),1,"[T163][x-extra]")
	QUIT
	;
T164 ; RESPJSON with default headers
	NEW DEV,CONF,OUT,OP,OBJ
	SET CONF("server","http","defaultResponseHeaders","X-App")="mio"
	SET OBJ("ok")=1
	SET OP="tmp/miohttp_p7_t164.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSON^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid164")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: mio":1,1:0),1,"[T164][x-app]")
	DO EQ^MIOTASSERT($SELECT(OUT["""ok"":1":1,1:0),1,"[T164][body]")
	QUIT
	;
T165 ; STREAMWRITE two chunks
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p7_t165.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid165",.CTX)
	DO STREAMWRITE^MIOHTTP(.DEV,"ab")
	DO STREAMWRITE^MIOHTTP(.DEV,"cde")
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["2"_$C(13,10)_"ab"_$C(13,10):1,1:0),1,"[T165][chunk1]")
	DO EQ^MIOTASSERT($SELECT(OUT["3"_$C(13,10)_"cde"_$C(13,10):1,1:0),1,"[T165][chunk2]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T166 ; STREAMWRITE updates byte count across multiple writes
	NEW DEV,CONF,CTX,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p7_t166.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid166",.CTX)
	DO STREAMWRITE^MIOHTTP(.DEV,"ab")
	DO STREAMWRITE^MIOHTTP(.DEV,"cde")
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($GET(^TMP($J,"MIOHTTP","STREAM","bytes"))>0,1,"[T166][bytes tracked]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	KILL ^TMP($J,"MIOHTTP","STREAM")
	QUIT
	;
T167 ; SENDFILE with default headers
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p7_t167.txt"
	DO WRFILE(FP,"file-body")
	SET CONF("server","http","defaultResponseHeaders","X-App")="mio"
	SET HEAD("Content-Type")="text/plain"
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET OP="tmp/miohttp_p7_t167.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid167",.CTX,"GET"),1,"[T167][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: mio":1,1:0),1,"[T167][x-app]")
	DO EQ^MIOTASSERT($SELECT(OUT["file-body":1,1:0),1,"[T167][body]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T168 ; SENDFILE explicit method argument HEAD suppresses body
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p7_t168.txt"
	DO WRFILE(FP,"file-body")
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p7_t168.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid168",.CTX,"HEAD"),1,"[T168][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["file-body":1,1:0),0,"[T168][no body]")
	QUIT
	;
T169 ; BODYAPPEND multiple scalar appends stay scalar
	NEW REQ,CONF,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=10
	DO BODYINIT^MIOHTTP(.REQ,.CONF,0)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"ab",.ERR)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"cd",.ERR)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"scalar","[T169][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"abcd","[T169][body]")
	QUIT
	;
T170 ; BODYAPPEND after upgrade keeps total length
	NEW REQ,CONF,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=2
	DO BODYINIT^MIOHTTP(.REQ,.CONF,0)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"ab",.ERR)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"cd",.ERR)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"ef",.ERR)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T170][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body","len")),6,"[T170][len]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T171 ; PARSE HTTP/1.1 path only no headers
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p7_t171.req"
	DO WRFILE(DEV,"GET /bare HTTP/1.1"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T171][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("path")),"/bare","[T171][path]")
	QUIT
	;
T172 ; PARSE header value with tabs
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p7_t172.req"
	DO WRFILE(DEV,"GET /x HTTP/1.1"_$C(13,10)_"X-Test: a"_$C(9)_"b"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T172][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-test")),"a"_$C(9)_"b","[T172][x-test]")
	QUIT
	;
T173 ; PARSE content-length with leading zeros
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p7_t173.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Content-Length: 0003"_$C(13,10,13,10)_"abc")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T173][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"abc","[T173][body]")
	QUIT
	;
T174 ; RESPJSONX nested object
	NEW DEV,CONF,CTX,OUT,OP,OBJ
	SET OBJ("user","id")="u1"
	SET OBJ("user","role")="admin"
	SET OP="tmp/miohttp_p7_t174.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid174",.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["""user"":{":1,1:0),1,"[T174][user]")
	DO EQ^MIOTASSERT($SELECT(OUT["""id"":""u1""":1,1:0),1,"[T174][id]")
	QUIT
	;
T175 ; RESPX with default and explicit headers
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	SET CONF("server","http","defaultResponseHeaders","X-App")="mio"
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("X-Mode")="test"
	SET OP="tmp/miohttp_p7_t175.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,"ok","rid175",.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: mio":1,1:0),1,"[T175][x-app]")
	DO EQ^MIOTASSERT($SELECT(OUT["X-Mode: test":1,1:0),1,"[T175][x-mode]")
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