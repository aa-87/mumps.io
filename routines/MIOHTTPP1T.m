MIOHTTPP1T ; MIOHTTP parser/helper tests
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
	D T176 ; PARSE invalid content-length alpha
	D T177 ; PARSE invalid content-length negative
	D T178 ; PARSE invalid content-length with spaces inside
	D T179 ; PARSE duplicate host rejected end-to-end
	D T180 ; PARSE duplicate content-length rejected end-to-end
	D T181 ; PARSE duplicate transfer-encoding rejected end-to-end
	D T182 ; PARSE invalid header name end-to-end
	D T183 ; PARSE invalid header value end-to-end
	D T184 ; PARSE folded header rejected end-to-end
	D T185 ; READCHUNKED zero chunk only produces empty body
	D T186 ; READCHUNKED lower hex size
	D T187 ; READCHUNKED upper hex size
	D T188 ; READCHUNKED bad final trailer termination
	D T189 ; READCHUNKED empty chunk data line for nonzero size
	D T190 ; PARSE chunked short read end-to-end
	D T191 ; PARSE chunked bad ending end-to-end
	D T192 ; PARSE chunked payload too large end-to-end
	D T193 ; SENDFILE empty file GET
	D T194 ; SENDFILE explicit default header plus explicit header
	D T195 ; STREAMBEGIN HEAD plus 204 has no chunked
	D T196 ; STREAMWRITE empty after nonempty keeps prior chunk only
	D T197 ; STATUS4ERR bad header line maps 400
	D T198 ; STATUS4ERR invalid header name maps 400
	D T199 ; STATUS4ERR invalid header value maps 400
	D T200 ; PARSE with unknown but valid custom header and body
	D T201 ; PARSEREQLINE OPTIONS *
	D T202 ; PARSEREQLINE CONNECT authority-form preserved as path
	D T203 ; PARSEQRY last repeated key wins
	D T204 ; URLDECQ preserves plus encoded as %2B
	D T205 ; HEXSTR2DEC long valid value
	D T206 ; READCHUNKED empty chunk extension value accepted
	D T207 ; READCHUNKED many one-byte chunks
	D T208 ; PARSE unsupported TE matrix compress
	D T209 ; PARSE unsupported TE matrix gzip,chunked
	D T210 ; PARSE chunked identity order valid when chunked last
	D T211 ; PARSE max header count exact boundary passes
	D T212 ; PARSE max header bytes exact boundary passes
	D T213 ; PARSE max header line bytes exact boundary passes
	D T214 ; BODYOPEN scalar empty then BODYNEXT false
	D T215 ; BODYFREE scalar mode harmless
	D T216 ; STREAMBEGIN 304 not chunked
	D T217 ; RESP explicit header overrides default same key
	D T218 ; RESPJSON empty object body
	D T219 ; RESPJSONX empty object body
	D T220 ; SEND100 followed by normal response same device
	D T221 ; PARSE bodyless GET with content-type only
	D T222 ; PARSE query only empty value after question mark
	D T223 ; URLDECQ mixed invalid and valid percent sequences
	D T224 ; HTOK accepts apostrophe and star
	D T225 ; HVALOK accepts tab-separated visible tokens
	D T226 ; PARSE repeated simple GETs remain stable
	D T227 ; PARSE repeated content-length requests remain stable
	D T228 ; PARSE repeated chunked requests remain stable
	D T229 ; BODY iterator over scalar body twice with fresh cursor
	D T230 ; BODY iterator over global body twice with fresh cursor
	D T231 ; STREAMBEGIN plus multiple writes plus end
	D T232 ; STREAMBEGIN with default and explicit headers repeated
	D T233 ; RESP repeated writes stable
	D T234 ; RESPJSON repeated writes stable
	D T235 ; SENDFILE repeated GETs stable
	D T236 ; SENDFILE HEAD repeated suppresses body
	D T237 ; STATUS4ERR mapping matrix more cases
	D T238 ; STATUS4ERR mapping chunk/body cases
	D T239 ; LIM multiple keys defaults and configured
	D T240 ; TRIM tabs are not stripped, spaces are stripped
	D T241 ; LOW leaves symbols unchanged
	D T242 ; HTOK matrix more valid tokens
	D T243 ; HTOK matrix more invalid tokens
	D T244 ; HVALOK visible boundary chars
	D T245 ; HVALOK rejects nul
	D T246 ; PARSE multiple normal headers plus body
	D T247 ; PARSE query and repeated header reuse after prior parse
	D T248 ; RESPX with empty body 200 still CL 0
	D T249 ; RESPJSONX with default headers
	D T250 ; full parse then BODY iterator then BODYFREE for global body
	D T251 ; PARSE loop matrix GET/POST/PUT
	D T252 ; PARSE loop matrix query extraction
	D T253 ; PARSE loop matrix bodyless methods stay none
	D T254 ; PARSE repeated invalid content-length remains stable
	D T255 ; PARSE repeated duplicate host remains stable
	D T256 ; RESP status matrix
	D T257 ; RESPJSON scalar matrix
	D T258 ; STREAM matrix multiple payload sizes
	D T259 ; STREAM HEAD matrix suppresses bodies
	D T260 ; SENDFILE size matrix GET
	D T261 ; SENDFILE size matrix HEAD
	D T262 ; BODYAPPEND upgrade matrix
	D T263 ; STATUS4ERR matrix repeated
	D T264 ; STATUSMSG matrix repeated
	D T265 ; HTOK repeated valid values
	D T266 ; HVALOK repeated invalid values
	D T267 ; URLDECQ matrix
	D T268 ; PARSEQRY matrix
	D T269 ; PARSE and CURMETH isolation
	D T270 ; RESP explicit header override confirmed
	D T271 ; RESPJSON explicit default header merge confirmed
	D T272 ; STREAMBEGIN records ctx status repeatedly
	D T273 ; READCHUNKED repeated small bodies stable
	D T274 ; READCL repeated exact bodies stable
	D T275 ; PARSE then RESP roundtrip matrix
	D T276 ; PARSE repeated empty query marker stable
	D T277 ; PARSE repeated encoded query values stable
	D T278 ; BODYINIT zero expected length with small scalar limit
	D T279 ; BODYAPPEND empty append keeps scalar state
	D T280 ; BODYAPPEND exact scalar threshold remains scalar
	D T281 ; BODYUP on already-global body stays global
	D T282 ; BODYLEN none mode zero
	D T283 ; BODYLEN scalar mode exact
	D T284 ; BODYLEN global mode exact
	D T285 ; READCL exact threshold to global config still scalar
	D T286 ; READCL above threshold to global config goes global
	D T287 ; READCHUNKED exact maxBodyBytes boundary passes
	D T288 ; PARSE exact maxBodyBytes boundary passes
	D T289 ; STREAMBEGIN explicit header overrides default same key
	D T290 ; RESPJSON explicit header with default merge
	D T291 ; RESPJSON nested numeric and string fields
	D T292 ; RESPJSONX nested numeric and string fields
	D T293 ; SENDFILE missing file repeated stable
	D T294 ; SENDFILE with explicit method GET independent of CURMETH
	D T295 ; SENDFILE with explicit method HEAD independent of CURMETH
	D T296 ; STATUS4ERR repeated unknown fallback stays 400
	D T297 ; TE helpers matrix
	D T298 ; TECHUNKLAST matrix
	D T299 ; TEOK matrix
	D T300 ; mixed parse sequence with valid then invalid then valid
	D T301 ; PARSEREQLINE GET root
	D T302 ; PARSEREQLINE POST nested path
	D T303 ; PARSEREQLINE PATCH with query
	D T304 ; PARSEREQLINE HTTP/1.0 root
	D T305 ; PARSEREQLINE rawpath preserved with query
	D T306 ; PARSE host header case preserved in value and lowercased in name
	D T307 ; PARSE content-type plus bodyless GET
	D T308 ; PARSE x headers plus query plus body
	D T309 ; PARSE repeated custom header last wins stable
	D T310 ; PARSE fixed body with exact scalar threshold
	D T311 ; PARSE fixed body above scalar threshold goes global
	D T312 ; READCHUNKED iterator on scalar result
	D T313 ; READCHUNKED global threshold path
	D T314 ; RESP 205 body suppression
	D T315 ; RESP HEAD plus 204 still no body
	D T316 ; RESPJSON HEAD plus 204 no body
	D T317 ; STREAMBEGIN 205 not chunked
	D T318 ; STREAM multiple empty writes around data
	D T319 ; RESP default header matrix two defaults
	D T320 ; RESPJSON default header matrix two defaults
	D T321 ; SENDFILE default header matrix
	D T322 ; CURMETH uppercase fallback repeated
	D T323 ; URLDECQ repeated invalid tail preserved
	D T324 ; HEXOUT matrix small values
	D T325 ; mixed valid-invalid-valid chunked parse sequence
	D T326 ; READHDRS single host header direct
	D T327 ; READHDRS multiple simple headers direct
	D T328 ; READHDRS empty header block direct
	D T329 ; READHDRS header line bytes exact boundary
	D T330 ; READHDRS header bytes exact boundary
	D T331 ; PARSEHDRS with request line only
	D T332 ; PARSEHDRS with request line plus headers
	D T333 ; PARSEHDRS bad header after valid request line
	D T334 ; READLINE repeated lines direct
	D T335 ; READLINE blank then text
	D T336 ; READFIX repeated sequential reads
	D T337 ; READFIX final short read after exact read
	D T338 ; WRESP byte count off when stream inactive
	D T339 ; WRESP byte count accumulates when stream active
	D T340 ; RESP explicit content-type text html
	D T341 ; RESPJSON content-length present
	D T342 ; RESPX updates ctx status
	D T343 ; RESPJSONX updates ctx status
	D T344 ; STREAMBEGIN updates ctx status
	D T345 ; SENDFILE updates ctx status on success
	D T346 ; SENDFILE default plus explicit override
	D T347 ; PARSE then RESPJSON roundtrip
	D T348 ; PARSEHEADERS then READBODYONLY split flow
	D T349 ; PARSEHDRS then READBODYONLY chunked split flow
	D T350 ; mixed direct helper sequence stable
	D T351 ; READHDRS trims value with inner spaces preserved
	D T352 ; READHDRS header count exact one
	D T353 ; READHDRS duplicate normal header last wins direct
	D T354 ; PARSEHDRS request line with OPTIONS star and headers
	D T355 ; PARSEHDRS request line with CONNECT authority form
	D T356 ; EXPECTDECIDE exact payload boundary with explicit expect lower
	D T357 ; EXPECTDECIDE payload too large by one
	D T358 ; EXPECTDECIDE no content-length but expect still ok
	D T359 ; SEND100 repeated writes stable
	D T360 ; STREAMBEGIN GET 200 emits rid and chunked
	D T361 ; STREAMBEGIN HEAD 200 no body on write
	D T362 ; STREAMBEGIN explicit header override over default
	D T363 ; STREAMWRITE byte accounting across three writes
	D T364 ; STREAMEND final zero chunk present after writes
	D T365 ; SENDFILE explicit method GET with default headers
	D T366 ; SENDFILE explicit method HEAD with default headers
	D T367 ; SENDFILE explicit header override over default
	D T368 ; READLINE eof after complete line then timeout on next
	D T369 ; READFIX exact full file then short read
	D T370 ; HTOK larger valid matrix
	D T371 ; HVALOK larger valid matrix
	D T372 ; LOW and TRIM combined stability
	D T373 ; PARSEHDRS then EXPECTDECIDE normal flow
	D T374 ; PARSEHDRS then EXPECTDECIDE payload too large
	D T375 ; SEND100 then STREAMBEGIN same device
	D T376 ; READCHUNKED three chunks joined
	D T377 ; READCHUNKED empty trailers after zero chunk
	D T378 ; READCHUNKED chunk extension with multiple attrs
	D T379 ; READCHUNKED bad mixed hex chars
	D T380 ; READCHUNKED missing zero chunk terminator
	D T381 ; READCL zero length stable
	D T382 ; READCL one byte scalar
	D T383 ; BODYAPPEND scalar then BODYUP explicit
	D T384 ; BODYAPPEND global after upgrade stores chunks
	D T385 ; BODYOPEN global empty then no next
	D T386 ; STATUS4ERR short_read fallback
	D T387 ; STATUS4ERR bad transfer encoding order
	D T388 ; STATUS4ERR duplicate transfer encoding
	D T389 ; STATUSMSG additional known statuses
	D T390 ; STATUSMSG unknown stays empty phrase path
	D T391 ; PARSE then RESP text roundtrip path echo
	D T392 ; PARSE then RESPJSON roundtrip method echo
	D T393 ; PARSE chunked then RESPJSONX body len echo
	D T394 ; STREAM then READALL contains status and chunks
	D T395 ; SENDFILE then READALL contains status and content
	D T396 ; HEXSTR2DEC lowercase long valid
	D T397 ; HEX2DEC lowercase pair
	D T398 ; LOW repeated stable
	D T399 ; TRIM repeated stable
	D T400 ; mixed parsehdrs readbodyonly respjsonx full split roundtrip
	D T401 ; READHDRS host plus content-length direct
	D T402 ; READHDRS transfer-encoding identity direct
	D T403 ; PARSEHDRS preserves rawpath with query
	D T404 ; PARSEHDRS invalid request line only
	D T405 ; READBODYONLY with content-length after PARSEHDRS
	D T406 ; READBODYONLY with no body headers remains none
	D T407 ; READBODYONLY with chunked request direct
	D T408 ; BODYOPEN none mode then repeated BODYNEXT false
	D T409 ; BODYNEXT scalar second call false
	D T410 ; BODYNEXT global exhausts correctly
	D T411 ; RESP 101 no body
	D T412 ; RESPJSON 304 no body
	D T413 ; RESPX 304 updates ctx status
	D T414 ; RESPJSONX 304 updates ctx status
	D T415 ; STREAMBEGIN 101 not chunked
	D T416 ; STREAMBEGIN 200 then two empty writes only zero chunk
	D T417 ; SENDFILE with explicit extra header
	D T418 ; SENDFILE with two default headers
	D T419 ; HTOK empty false
	D T420 ; HVALOK DEL false
	D T421 ; HEXVAL numeric chars
	D T422 ; HEXVAL invalid punctuation
	D T423 ; URLDECQ empty input
	D T424 ; PARSEQRY no question mark leaves empty query map
	D T425 ; mixed parse resp sendfile sequence stable
	D T426 ; READCHUNKED invalid size with leading space
	D T427 ; READCHUNKED invalid size with trailing space
	D T428 ; READCHUNKED invalid empty extension delimiter
	D T429 ; READCHUNKED size zero with extension valid
	D T430 ; READCHUNKED two chunks with trailer and blank line
	D T431 ; READCHUNKED global threshold exact stays scalar
	D T432 ; READCHUNKED global threshold plus one goes global
	D T433 ; BODYAPPEND scalar many small appends
	D T434 ; BODYAPPEND empty then nonempty then empty
	D T435 ; BODYUP from empty scalar to global
	D T436 ; BODYFREE global twice harmless
	D T437 ; PARSEHDRS expect continue normal
	D T438 ; PARSEHDRS expect mixed case preserved
	D T439 ; PARSEHDRS then EXPECTDECIDE then SEND100 flow
	D T440 ; PARSEHDRS then EXPECTDECIDE deny no SEND100
	D T441 ; RESP repeated body suppression for HEAD
	D T442 ; RESPJSON repeated body suppression for HEAD
	D T443 ; STREAM repeated with same payload stable
	D T444 ; STREAM 204 repeated no chunked
	D T445 ; SENDFILE repeated explicit header override stable
	D T446 ; STATUS4ERR repeated bad_chunk_size stable
	D T447 ; STATUSMSG repeated 200 stable
	D T448 ; PARSE then BODY iterator on global body repeated
	D T449 ; PARSEHDRS READBODYONLY RESP text split flow repeated
	D T450 ; mixed chunk parse send100 stream flow
	D T451 ; READLINE three sequential lines
	D T452 ; READLINE blank blank text
	D T453 ; READFIX split exact into 1 1 1
	D T454 ; READFIX split exact into 2 then 2
	D T455 ; READFIX empty file immediate short path
	D T456 ; READHDRS maxHeaderCount exact two
	D T457 ; READHDRS maxHeaderLineBytes over by one fails
	D T458 ; READHDRS maxHeaderBytes over by one fails
	D T459 ; PARSEHDRS bad header line after valid one
	D T460 ; PARSEHDRS duplicate host direct
	D T461 ; PARSEHDRS duplicate content-length direct
	D T462 ; PARSEHDRS duplicate transfer-encoding direct
	D T463 ; PARSE invalid header value end-to-end again
	D T464 ; PARSE invalid header folding end-to-end again
	D T465 ; RESP default plus two explicit headers
	D T466 ; RESPJSON default plus custom explicit ctype path
	D T467 ; STREAMBEGIN default plus two explicit headers
	D T468 ; STREAM header override repeated
	D T469 ; READBODYONLY CL zero after parsehdrs
	D T470 ; READBODYONLY CL too large after parsehdrs
	D T471 ; READBODYONLY chunked disabled after parsehdrs
	D T472 ; STATUS4ERR read timeout again
	D T473 ; STATUS4ERR headers too large again
	D T474 ; STATUSMSG 501 and 503
	D T475 ; mixed parsehdrs expect send100 readbody stream sequence
	D T476 ; PARSEREQLINE encoded query values
	D T477 ; PARSEREQLINE repeated query key last wins
	D T478 ; PARSEREQLINE empty query pair
	D T479 ; PARSEREQLINE question mark only
	D T480 ; PARSE TE chunked with allowTECL and CL zero
	D T481 ; PARSE TE identity with no CL gives no body
	D T482 ; PARSE TE chunked only with empty body
	D T483 ; PARSE unsupported TE compress, chunked
	D T484 ; PARSE TE chunked not last in longer list
	D T485 ; BODYAPPEND threshold boundary one below stays scalar
	D T486 ; BODYAPPEND threshold exact stays scalar
	D T487 ; BODYAPPEND threshold plus one upgrades
	D T488 ; READCL above maxBodyBytes denied
	D T489 ; READCL exact maxBodyBytes allowed
	D T490 ; PARSE simple GET then RESPX text
	D T491 ; PARSE simple GET then RESPJSONX path
	D T492 ; PARSE POST body then STREAM response echoes size
	D T493 ; READHDRS preserves tab in value
	D T494 ; PARSEHDRS path only HTTP/1.0
	D T495 ; PARSE full request with host and empty body cl0
	D T496 ; SENDFILE then RESP on separate device sequence
	D T497 ; STATUSMSG 405 and 500
	D T498 ; STATUS4ERR bad_header_line and invalid_content_length
	D T499 ; URLDECQ preserved invalid escape in middle
	D T500 ; mixed parse split response file flow
	D T501 ; common GET home page parse
	D T502 ; common GET asset with query cache buster
	D T503 ; common HEAD request for health endpoint
	D T504 ; common JSON API response helper
	D T505 ; common plain text health response
	D T506 ; common form POST parse username password body
	D T507 ; common form POST with encoded spaces and slash
	D T508 ; common form POST with empty optional field
	D T509 ; split flow form parsehdrs then readbodyonly
	D T510 ; common multipart not auto-decoded by http layer
	D T511 ; common search query parse
	D T512 ; common file download via sendfile
	D T513 ; common file HEAD download suppresses body
	D T514 ; common upload expect continue accepted
	D T515 ; common upload expect continue denied when too large
	D T516 ; common chunked form body parse
	D T517 ; common html response with defaults
	D T518 ; common streaming text response two chunks
	D T519 ; form fragment decode helper name field
	D T520 ; form fragment decode helper encoded equals and ampersand
	D T521 ; common parse then json echo response
	D T522 ; common login form split flow and text response
	D T523 ; common empty form body cl0
	D T524 ; common form body boundary exact scalar threshold
	D T525 ; common form body boundary above scalar threshold
	D T526 ; common signup form parse
	D T527 ; common contact form parse
	D T528 ; common settings form with booleans
	D T529 ; common search filters parse
	D T530 ; common pagination query parse
	D T531 ; common redirect style response 303
	D T532 ; common redirect style response 302
	D T533 ; post submit json response helper
	D T534 ; common login form split flow then json response
	D T535 ; common comment form small scalar body
	D T536 ; common comment form large body goes global
	D T537 ; common upload endpoint with fixed body
	D T538 ; common chunked upload endpoint
	D T539 ; common api post then stream response
	D T540 ; form field fragment decode simple pair
	D T541 ; form field fragment decode spaces
	D T542 ; form field fragment decode slash and question mark
	D T543 ; common GET profile query parse
	D T544 ; common GET filter query with repeated key last wins
	D T545 ; common create form then redirect response
	D T546 ; common delete request parse
	D T547 ; common patch form parse
	D T548 ; common put body parse
	D T549 ; common form submit expect continue full flow
	D T550 ; common final file download after form flow
	D T551 ; profile form with encoded email and display name
	D T552 ; settings form with timezone and language
	D T553 ; password reset form with token
	D T554 ; newsletter subscribe form
	D T555 ; checkout form with encoded address
	D T556 ; dashboard query with multiple filters
	D T557 ; search query with encoded slash and plus
	D T558 ; navigation request for nested docs path
	D T559 ; common success json payload after form submit
	D T560 ; common redirect after signup
	D T561 ; common redirect after logout
	D T562 ; split flow settings form then text response
	D T563 ; split flow profile form then json response
	D T564 ; common report download sendfile with default header
	D T565 ; common report download head only
	D T566 ; common query with page sort dir
	D T567 ; common GET with encoded tag and slash
	D T568 ; form field helper repeated key fragment decode
	D T569 ; form field helper plus and percent combo
	D T570 ; common empty search query value
	D T571 ; common file api fixed binary-like upload
	D T572 ; common api GET then stream json-like text
	D T573 ; common save form with expect continue split flow
	D T574 ; common response with request id header
	D T575 ; common final roundtrip parse form then sendfile
	D T576 ; auth login form with remember me
	D T577 ; auth forgot password form
	D T578 ; auth reset password form with token and next
	D T579 ; account delete confirmation form
	D T580 ; settings notifications form split flow
	D T581 ; profile avatar upload fixed binary body
	D T582 ; search with phrase and category filters
	D T583 ; dashboard navigation query with section and mode
	D T584 ; redirect after login success
	D T585 ; redirect after logout success
	D T586 ; json success payload with redirect and ok
	D T587 ; json failure payload common pattern
	D T588 ; report export request parse with query
	D T589 ; export download sendfile common case
	D T590 ; export head download no body
	D T591 ; common chunked form submit split flow
	D T592 ; common stream response after search request
	D T593 ; common form helper decode encoded slash in return url
	D T594 ; common form helper decode plus and comma
	D T595 ; common GET with empty optional filters
	D T596 ; common HEAD request to export route
	D T597 ; common profile form body exact scalar threshold
	D T598 ; common profile form body above scalar threshold
	D T599 ; common final json response after auth flow
	D T600 ; final common roundtrip form parse then redirect response
	D T601 ; MEDIATYPE plain
	D T602 ; MEDIATYPE strips params and lowers
	D T603 ; CTPARAM charset
	D T604 ; CTPARAM quoted boundary
	D T605 ; ISFORM exact type
	D T606 ; ISFORM with charset
	D T607 ; ISJSON exact
	D T608 ; ISJSON vendor subtype
	D T609 ; PARSEFORM scalar simple
	D T610 ; PARSEFORM repeated keys
	D T611 ; PARSEFORM blank value
	D T612 ; PARSEFORM decodes spaces and slash
	D T613 ; PARSEFORM global body across chunk boundaries
	D T614 ; PARSEFORM non-form type rejected
	D T615 ; REDIRECT default status
	D T616 ; REDIRECT explicit status
	D T617 ; RESPTEXT helper
	D T618 ; RESPERR helper
	D T619 ; STATUSMSG added phrases
	D T620 ; CTPARAM missing returns empty
	D T621 ; TARGETKIND origin
	D T622 ; TARGETKIND asterisk
	D T623 ; TARGETKIND authority
	D T624 ; PARSEHDRS GET metadata none/origin
	D T625 ; PARSEHDRS POST form metadata CL
	D T626 ; PARSEHDRS JSON metadata
	D T627 ; PARSEHDRS chunked metadata
	D T628 ; PARSE full GET metadata none
	D T629 ; PARSE full POST CL body metadata
	D T630 ; PARSE full POST CL zero metadata
	D T631 ; PARSE full chunked metadata
	D T632 ; READBODYONLY updates CL metadata
	D T633 ; READBODYONLY updates chunked metadata
	D T634 ; PARSE CONNECT metadata authority
	D T635 ; PARSE OPTIONS star metadata asterisk
	D T636 ; PARSE full form metadata isForm
	D T637 ; PARSE full json metadata isJSON
	D T638 ; PARSE TE identity with CL metadata
	D T639 ; PARSE TE identity no CL metadata none
	D T640 ; PARSE query request keeps origin metadata
	D T641 ; BODYFRAMING none
	D T642 ; BODYFRAMING content-length
	D T643 ; BODYFRAMING chunked
	D T644 ; BODYFRAMING identity plus content-length
	D T645 ; BODYFRAMING te cl conflict by default
	D T646 ; BODYFRAMING te cl allowed when enabled
	D T647 ; BODYFRAMING bad te order
	D T648 ; STRICTREQ missing host on http11 origin
	D T649 ; STRICTREQ non-strict allows missing host
	D T650 ; STRICTREQ options star valid
	D T651 ; STRICTREQ get star invalid
	D T652 ; STRICTREQ connect authority valid
	D T653 ; STRICTREQ get authority invalid
	D T654 ; PARSE strict missing host fails
	D T655 ; PARSE strict host present passes
	D T656 ; PARSEHDRS strict options star passes
	D T657 ; PARSEHDRS strict invalid origin target fails
	D T658 ; READBODYONLY chunked uses framing helper
	D T659 ; READBODYONLY cl zero sets no body but framing content-length
	D T660 ; PARSE te identity no cl yields none framing	
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
T176 ; PARSE invalid content-length alpha
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p8_t176.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Content-Length: abc"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T176][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"invalid_content_length","[T176][err]")
	QUIT
	;
T177 ; PARSE invalid content-length negative
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p8_t177.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Content-Length: -1"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T177][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"invalid_content_length","[T177][err]")
	QUIT
	;
T178 ; PARSE invalid content-length with spaces inside
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p8_t178.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Content-Length: 1 2"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T178][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"invalid_content_length","[T178][err]")
	QUIT
	;
T179 ; PARSE duplicate host rejected end-to-end
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p8_t179.req"
	DO WRFILE(DEV,"GET /x HTTP/1.1"_$C(13,10)_"Host: a"_$C(13,10)_"Host: b"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T179][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"duplicate_host","[T179][err]")
	QUIT
	;
T180 ; PARSE duplicate content-length rejected end-to-end
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p8_t180.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Content-Length: 1"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T180][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"duplicate_content_length","[T180][err]")
	QUIT
	;
T181 ; PARSE duplicate transfer-encoding rejected end-to-end
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p8_t181.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10)_"Transfer-Encoding: identity"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T181][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"duplicate_transfer_encoding","[T181][err]")
	QUIT
	;
T182 ; PARSE invalid header name end-to-end
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p8_t182.req"
	DO WRFILE(DEV,"GET /x HTTP/1.1"_$C(13,10)_"Bad Name: y"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T182][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"invalid_header_name","[T182][err]")
	QUIT
	;
T183 ; PARSE invalid header value end-to-end
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p8_t183.req"
	DO WRFILE(DEV,"GET /x HTTP/1.1"_$C(13,10)_"X-Test: a"_$C(1)_"b"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T183][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"invalid_header_value","[T183][err]")
	QUIT
	;
T184 ; PARSE folded header rejected end-to-end
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p8_t184.req"
	DO WRFILE(DEV,"GET /x HTTP/1.1"_$C(13,10)_"X-Test: a"_$C(13,10)_" next"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T184][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"header_folding_rejected","[T184][err]")
	QUIT
	;
T185 ; READCHUNKED zero chunk only produces empty body
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p8_t185.req"
	DO WRFILE(DEV,"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T185][no err]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"","[T185][body]")
	DO EQ^MIOTASSERT($$BODYLEN^MIOHTTP(.REQ),0,"[T185][len]")
	QUIT
	;
T186 ; READCHUNKED lower hex size
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p8_t186.req"
	DO WRFILE(DEV,"a"_$C(13,10)_"0123456789"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T186][no err]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"0123456789","[T186][body]")
	QUIT
	;
T187 ; READCHUNKED upper hex size
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p8_t187.req"
	DO WRFILE(DEV,"A"_$C(13,10)_"0123456789"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T187][no err]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"0123456789","[T187][body]")
	QUIT
	;
T188 ; READCHUNKED accepts trailer line followed by extra partial data in current implementation
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p8_t188.req"
	DO WRFILE(DEV,"1"_$C(13,10)_"a"_$C(13,10)_"0"_$C(13,10)_"X-T: 1"_$C(13,10)_"bad")
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T188][no err]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"a","[T188][body]")
	DO EQ^MIOTASSERT($GET(REQ("body","len")),1,"[T188][len]")
	QUIT
	;
T189 ; READCHUNKED empty chunk data line for nonzero size
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p8_t189.req"
	DO WRFILE(DEV,"1"_$C(13,10)_$C(13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error"))'="",1,"[T189][some err]")
	QUIT
	;
T190 ; PARSE chunked short read end-to-end
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","http","supportChunkedRequest")=1
	SET DEV="tmp/miohttp_p8_t190.req"
	DO WRFILE(DEV,"POST /c HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10,13,10)_"5"_$C(13,10)_"abc")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T190][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error"))'="",1,"[T190][some err]")
	QUIT
	;
T191 ; PARSE chunked bad ending end-to-end
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","http","supportChunkedRequest")=1
	SET DEV="tmp/miohttp_p8_t191.req"
	DO WRFILE(DEV,"POST /c HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10,13,10)_"2"_$C(13,10)_"abX"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T191][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"bad_chunk_ending","[T191][err]")
	QUIT
	;
T192 ; PARSE chunked payload too large end-to-end
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","http","supportChunkedRequest")=1
	SET CONF("server","limits","maxBodyBytes")=2
	SET DEV="tmp/miohttp_p8_t192.req"
	DO WRFILE(DEV,"POST /c HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10,13,10)_"3"_$C(13,10)_"abc"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T192][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"payload_too_large","[T192][err]")
	QUIT
	;
T193 ; SENDFILE empty file GET
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p8_t193.txt"
	DO WRFILE(FP,"")
	SET HEAD("Content-Type")="text/plain"
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET OP="tmp/miohttp_p8_t193.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid193",.CTX,"GET"),1,"[T193][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 200 OK":1,1:0),1,"[T193][status]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T194 ; SENDFILE explicit default header plus explicit header
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p8_t194.txt"
	DO WRFILE(FP,"abc")
	SET CONF("server","http","defaultResponseHeaders","X-App")="mio"
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("X-Mode")="file"
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET OP="tmp/miohttp_p8_t194.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid194",.CTX,"GET"),1,"[T194][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: mio":1,1:0),1,"[T194][x-app]")
	DO EQ^MIOTASSERT($SELECT(OUT["X-Mode: file":1,1:0),1,"[T194][x-mode]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T195 ; STREAMBEGIN HEAD plus 204 has no chunked
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="HEAD"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p8_t195.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,204,.HEAD,"rid195",.CTX)
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Transfer-Encoding: chunked":1,1:0),0,"[T195][not chunked]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T196 ; STREAMWRITE empty after nonempty keeps prior chunk only
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p8_t196.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid196",.CTX)
	DO STREAMWRITE^MIOHTTP(.DEV,"ab")
	DO STREAMWRITE^MIOHTTP(.DEV,"")
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["2"_$C(13,10)_"ab"_$C(13,10):1,1:0),1,"[T196][chunk]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T197 ; STATUS4ERR bad header line maps 400
	NEW ERR
	SET ERR("error")="bad_header_line"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),400,"[T197][400]")
	QUIT
	;
T198 ; STATUS4ERR invalid header name maps 400
	NEW ERR
	SET ERR("error")="invalid_header_name"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),400,"[T198][400]")
	QUIT
	;
T199 ; STATUS4ERR invalid header value maps 400
	NEW ERR
	SET ERR("error")="invalid_header_value"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),400,"[T199][400]")
	QUIT
	;
T200 ; PARSE with unknown but valid custom header and body
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p8_t200.req"
	DO WRFILE(DEV,"POST /custom HTTP/1.1"_$C(13,10)_"X-Feature: on"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10)_"ok")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T200][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-feature")),"on","[T200][hdr]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"ok","[T200][body]")
	QUIT
T201 ; PARSEREQLINE OPTIONS *
	NEW REQ,ERR
	DO PARSEREQLINE^MIOHTTP("OPTIONS * HTTP/1.1",.REQ,.ERR)
	DO EQ^MIOTASSERT($GET(REQ("method")),"OPTIONS","[T201][method]")
	DO EQ^MIOTASSERT($GET(REQ("path")),"*","[T201][path]")
	QUIT
	;
T202 ; PARSEREQLINE CONNECT authority-form preserved as path
	NEW REQ,ERR
	DO PARSEREQLINE^MIOHTTP("CONNECT example.com:443 HTTP/1.1",.REQ,.ERR)
	DO EQ^MIOTASSERT($GET(REQ("method")),"CONNECT","[T202][method]")
	DO EQ^MIOTASSERT($GET(REQ("path")),"example.com:443","[T202][path]")
	QUIT
	;
T203 ; PARSEQRY last repeated key wins
	NEW REQ
	DO PARSEQRY^MIOHTTP("/x?a=1&a=2",.REQ)
	DO EQ^MIOTASSERT($GET(REQ("query","a")),"2","[T203][a]")
	QUIT
	;
T204 ; URLDECQ preserves plus encoded as %2B
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("a%2Bb"),"a+b","[T204][plus]")
	QUIT
	;
T205 ; HEXSTR2DEC long valid value
	DO EQ^MIOTASSERT($$HEXSTR2DEC^MIOHTTP("7FFFFFFF"),2147483647,"[T205][hex]")
	QUIT
	;
T206 ; READCHUNKED empty chunk extension value accepted
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p9_t206.req"
	DO WRFILE(DEV,"2;foo="_$C(13,10)_"ab"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T206][no err]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"ab","[T206][body]")
	QUIT
	;
T207 ; READCHUNKED many one-byte chunks
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p9_t207.req"
	DO WRFILE(DEV,"1"_$C(13,10)_"a"_$C(13,10)_"1"_$C(13,10)_"b"_$C(13,10)_"1"_$C(13,10)_"c"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"abc","[T207][body]")
	QUIT
	;
T208 ; PARSE unsupported TE matrix compress
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p9_t208.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Transfer-Encoding: compress"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T208][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"unsupported_transfer_encoding","[T208][err]")
	QUIT
	;
T209 ; PARSE unsupported TE matrix gzip,chunked
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p9_t209.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Transfer-Encoding: gzip, chunked"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T209][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"unsupported_transfer_encoding","[T209][err]")
	QUIT
	;
T210 ; PARSE chunked identity order valid when chunked last
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","http","supportChunkedRequest")=1
	SET DEV="tmp/miohttp_p9_t210.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Transfer-Encoding: identity, chunked"_$C(13,10,13,10)_"2"_$C(13,10)_"ok"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T210][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"ok","[T210][body]")
	QUIT
	;
T211 ; PARSE max header count exact boundary passes
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","limits","maxHeaderCount")=2
	SET DEV="tmp/miohttp_p9_t211.req"
	DO WRFILE(DEV,"GET /x HTTP/1.1"_$C(13,10)_"A: 1"_$C(13,10)_"B: 2"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T211][ok]")
	DO CLOSER(DEV)
	QUIT
	;
T212 ; PARSE max header bytes exact boundary passes
	NEW CONF,REQ,ERR,DEV,TXT
	SET TXT="GET /x HTTP/1.1"_$C(13,10)_"A: 1"_$C(13,10,13,10)
	SET CONF("server","limits","maxHeaderBytes")=$L("A: 1")+2
	SET DEV="tmp/miohttp_p9_t212.req"
	DO WRFILE(DEV,TXT)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T212][ok]")
	DO CLOSER(DEV)
	QUIT
	;
T213 ; PARSE max header line bytes exact boundary passes
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","limits","maxHeaderLineBytes")=$L("A: 1")
	SET DEV="tmp/miohttp_p9_t213.req"
	DO WRFILE(DEV,"GET /x HTTP/1.1"_$C(13,10)_"A: 1"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T213][ok]")
	DO CLOSER(DEV)
	QUIT
	;
T214 ; BODYOPEN scalar empty then BODYNEXT false
	NEW REQ,CUR,CH
	SET REQ("body","mode")="none"
	SET REQ("body","len")=0
	DO BODYOPEN^MIOHTTP(.REQ,.CUR)
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH),0,"[T214][next]")
	QUIT
	;
T215 ; BODYFREE scalar mode clears scalar body state
	NEW REQ
	SET REQ("body","mode")="scalar"
	SET REQ("body")="abc"
	SET REQ("body","len")=3
	DO BODYFREE^MIOHTTP(.REQ)
	DO EQ^MIOTASSERT($GET(REQ("body")),"","[T215][scalar cleared]")
	DO EQ^MIOTASSERT($GET(REQ("body","len"),0),0,"[T215][len]")
	QUIT
	;
T216 ; STREAMBEGIN 304 not chunked
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p9_t216.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,304,.HEAD,"rid216",.CTX)
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Transfer-Encoding: chunked":1,1:0),0,"[T216][not chunked]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T217 ; RESP explicit header overrides default same key
	NEW DEV,CONF,OUT,OP,HEAD
	SET CONF("server","http","defaultResponseHeaders","X-App")="default"
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("X-App")="explicit"
	SET OP="tmp/miohttp_p9_t217.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,200,.HEAD,"ok","rid217")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: explicit":1,1:0),1,"[T217][explicit]")
	QUIT
	;
T218 ; RESPJSON empty object body
	NEW DEV,CONF,OUT,OP,OBJ
	KILL OBJ
	SET OP="tmp/miohttp_p9_t218.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSON^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid218")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["{}":1,1:0),1,"[T218][json]")
	QUIT
	;
T219 ; RESPJSONX empty object body
	NEW DEV,CONF,CTX,OUT,OP,OBJ
	KILL OBJ
	SET OP="tmp/miohttp_p9_t219.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid219",.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["{}":1,1:0),1,"[T219][json]")
	QUIT
	;
T220 ; SEND100 followed by normal response same device
	NEW DEV,CONF,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p9_t220.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO SEND100^MIOHTTP(.DEV)
	DO RESP^MIOHTTP(.DEV,.CONF,200,.HEAD,"ok","rid220")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["100 Continue":1,1:0),1,"[T220][100]")
	DO EQ^MIOTASSERT($SELECT(OUT["200 OK":1,1:0),1,"[T220][200]")
	QUIT
	;
T221 ; PARSE bodyless GET with content-type only
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p9_t221.req"
	DO WRFILE(DEV,"GET /x HTTP/1.1"_$C(13,10)_"Content-Type: text/plain"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T221][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("hdr","content-type")),"text/plain","[T221][ctype]")
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"none","[T221][mode]")
	QUIT
	;
T222 ; PARSE query only empty value after question mark
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p9_t222.req"
	DO WRFILE(DEV,"GET /x? HTTP/1.1"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T222][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("path")),"/x","[T222][path]")
	QUIT
	;
T223 ; URLDECQ mixed invalid and valid percent sequences
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("a%2Fb%XZc"),"a/b%XZc","[T223][decode]")
	QUIT
	;
T224 ; HTOK accepts apostrophe and star
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("x'y*"),1,"[T224][token]")
	QUIT
	;
T225 ; HVALOK accepts tab-separated visible tokens
	DO EQ^MIOTASSERT($$HVALOK^MIOHTTP("abc"_$C(9)_"def"),1,"[T225][tab]")
	QUIT
T226 ; PARSE repeated simple GETs remain stable
	NEW I,CONF,REQ,ERR,DEV
	FOR I=1:1:3 DO
	. SET DEV="tmp/miohttp_p10_t226-"_I_".req"
	. DO WRFILE(DEV,"GET /ping HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	. KILL REQ,ERR
	. DO OPENR(DEV)
	. DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T226]["_I_"][ok]")
	. DO CLOSER(DEV)
	. DO EQ^MIOTASSERT($GET(REQ("path")),"/ping","[T226]["_I_"][path]")
	QUIT
	;
T227 ; PARSE repeated content-length requests remain stable
	NEW I,CONF,REQ,ERR,DEV
	FOR I=1:1:3 DO
	. SET DEV="tmp/miohttp_p10_t227-"_I_".req"
	. DO WRFILE(DEV,"POST /echo HTTP/1.1"_$C(13,10)_"Content-Length: 3"_$C(13,10,13,10)_"hey")
	. KILL REQ,ERR
	. DO OPENR(DEV)
	. DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T227]["_I_"][ok]")
	. DO CLOSER(DEV)
	. DO EQ^MIOTASSERT($GET(REQ("body")),"hey","[T227]["_I_"][body]")
	QUIT
	;
T228 ; PARSE repeated chunked requests remain stable
	NEW I,CONF,REQ,ERR,DEV
	SET CONF("server","http","supportChunkedRequest")=1
	FOR I=1:1:3 DO
	. SET DEV="tmp/miohttp_p10_t228-"_I_".req"
	. DO WRFILE(DEV,"POST /c HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10,13,10)_"2"_$C(13,10)_"ok"_$C(13,10)_"0"_$C(13,10,13,10))
	. KILL REQ,ERR
	. DO OPENR(DEV)
	. DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T228]["_I_"][ok]")
	. DO CLOSER(DEV)
	. DO EQ^MIOTASSERT($GET(REQ("body")),"ok","[T228]["_I_"][body]")
	QUIT
	;
T229 ; BODY iterator over scalar body twice with fresh cursor
	NEW REQ,C1,C2,CH
	SET REQ("body","mode")="scalar"
	SET REQ("body")="xyz"
	SET REQ("body","len")=3
	DO BODYOPEN^MIOHTTP(.REQ,.C1)
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.C1,.CH),1,"[T229][next1]")
	DO EQ^MIOTASSERT(CH,"xyz","[T229][chunk1]")
	DO BODYOPEN^MIOHTTP(.REQ,.C2)
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.C2,.CH),1,"[T229][next2]")
	DO EQ^MIOTASSERT(CH,"xyz","[T229][chunk2]")
	QUIT
	;
T230 ; BODY iterator over global body twice with fresh cursor
	NEW REQ,C1,C2,CH
	SET REQ("body","mode")="global"
	SET REQ("body","ref")=$NAME(^TMP($J,"MIOHTTPP10","T230"))
	KILL ^TMP($J,"MIOHTTPP10","T230")
	SET @REQ("body","ref")@(1)="ab"
	SET @REQ("body","ref")@(2)="cd"
	SET REQ("body","n")=2
	SET REQ("body","len")=4
	DO BODYOPEN^MIOHTTP(.REQ,.C1)
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.C1,.CH),1,"[T230][c1-1]")
	DO EQ^MIOTASSERT(CH,"ab","[T230][chunk1]")
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.C1,.CH),1,"[T230][c1-2]")
	DO EQ^MIOTASSERT(CH,"cd","[T230][chunk2]")
	DO BODYOPEN^MIOHTTP(.REQ,.C2)
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.C2,.CH),1,"[T230][c2-1]")
	DO EQ^MIOTASSERT(CH,"ab","[T230][chunk3]")
	KILL ^TMP($J,"MIOHTTPP10","T230")
	QUIT
	;
T231 ; STREAMBEGIN plus multiple writes plus end
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p10_t231.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid231",.CTX)
	DO STREAMWRITE^MIOHTTP(.DEV,"one")
	DO STREAMWRITE^MIOHTTP(.DEV,"two")
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["3"_$C(13,10)_"one"_$C(13,10):1,1:0),1,"[T231][one]")
	DO EQ^MIOTASSERT($SELECT(OUT["3"_$C(13,10)_"two"_$C(13,10):1,1:0),1,"[T231][two]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T232 ; STREAMBEGIN with default and explicit headers repeated
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET CONF("server","http","defaultResponseHeaders","X-App")="mio"
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("X-Mode")="stream"
	SET OP="tmp/miohttp_p10_t232.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid232",.CTX)
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: mio":1,1:0),1,"[T232][x-app]")
	DO EQ^MIOTASSERT($SELECT(OUT["X-Mode: stream":1,1:0),1,"[T232][x-mode]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T233 ; RESP repeated writes stable
	NEW I,DEV,CONF,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	FOR I=1:1:3 DO
	. SET OP="tmp/miohttp_p10_t233-"_I_".out"
	. OPEN OP:(newversion:stream:nowrap)
	. SET DEV=OP USE DEV
	. DO RESP^MIOHTTP(.DEV,.CONF,200,.HEAD,"ok","rid233-"_I)
	. CLOSE DEV USE $PRINCIPAL
	. DO READALL(OP,.OUT)
	. DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 200 OK":1,1:0),1,"[T233]["_I_"][status]")
	. DO EQ^MIOTASSERT($SELECT(OUT["ok":1,1:0),1,"[T233]["_I_"][body]")
	QUIT
	;
T234 ; RESPJSON repeated writes stable
	NEW I,DEV,CONF,OUT,OP,OBJ
	SET OBJ("ok")=1
	FOR I=1:1:3 DO
	. SET OP="tmp/miohttp_p10_t234-"_I_".out"
	. OPEN OP:(newversion:stream:nowrap)
	. SET DEV=OP USE DEV
	. DO RESPJSON^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid234-"_I)
	. CLOSE DEV USE $PRINCIPAL
	. DO READALL(OP,.OUT)
	. DO EQ^MIOTASSERT($SELECT(OUT["""ok"":1":1,1:0),1,"[T234]["_I_"][json]")
	QUIT
	;
T235 ; SENDFILE repeated GETs stable
	NEW I,DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p10_t235.txt"
	DO WRFILE(FP,"repeat-file")
	SET HEAD("Content-Type")="text/plain"
	FOR I=1:1:2 DO
	. KILL ^TMP($J,"MIOHTTP","REQ")
	. SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	. SET OP="tmp/miohttp_p10_t235-"_I_".out"
	. OPEN OP:(newversion:stream:nowrap)
	. SET DEV=OP USE DEV
	. DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid235-"_I,.CTX,"GET"),1,"[T235]["_I_"][ok]")
	. CLOSE DEV USE $PRINCIPAL
	. DO READALL(OP,.OUT)
	. DO EQ^MIOTASSERT($SELECT(OUT["repeat-file":1,1:0),1,"[T235]["_I_"][body]")
	QUIT
	;
T236 ; SENDFILE HEAD repeated suppresses body
	NEW I,DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p10_t236.txt"
	DO WRFILE(FP,"repeat-file")
	SET HEAD("Content-Type")="text/plain"
	FOR I=1:1:2 DO
	. SET OP="tmp/miohttp_p10_t236-"_I_".out"
	. OPEN OP:(newversion:stream:nowrap)
	. SET DEV=OP USE DEV
	. DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid236-"_I,.CTX,"HEAD"),1,"[T236]["_I_"][ok]")
	. CLOSE DEV USE $PRINCIPAL
	. DO READALL(OP,.OUT)
	. DO EQ^MIOTASSERT($SELECT(OUT["repeat-file":1,1:0),0,"[T236]["_I_"][no body]")
	QUIT
	;
T237 ; STATUS4ERR mapping matrix more cases
	NEW ERR
	SET ERR("error")="bad_request_line"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),400,"[T237][bad_request_line]")
	SET ERR("error")="duplicate_host"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),400,"[T237][duplicate_host]")
	SET ERR("error")="duplicate_content_length"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),400,"[T237][duplicate_cl]")
	SET ERR("error")="te_cl_conflict"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),400,"[T237][te_cl]")
	QUIT
	;
T238 ; STATUS4ERR mapping chunk/body cases
	NEW ERR
	SET ERR("error")="bad_chunk_size"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),400,"[T238][bad_chunk_size]")
	SET ERR("error")="bad_chunk_ending"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),400,"[T238][bad_chunk_ending]")
	SET ERR("error")="unsupported_transfer_encoding"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),501,"[T238][unsupported_te]")
	SET ERR("error")="chunked_not_supported"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),400,"[T238][chunked_not_supported]")
	QUIT
	;
T239 ; LIM multiple keys defaults and configured
	NEW CONF
	SET CONF("server","limits","maxHeaderCount")=77
	DO EQ^MIOTASSERT($$LIM^MIOHTTP(.CONF,"maxHeaderCount",5),77,"[T239][count]")
	DO EQ^MIOTASSERT($$LIM^MIOHTTP(.CONF,"maxHeaderBytes",1234),1234,"[T239][fallback]")
	QUIT
	;
T240 ; TRIM tabs are not stripped, spaces are stripped
	DO EQ^MIOTASSERT($$TRIM^MIOHTTP(" "_$C(9)_"a "),$C(9)_"a","[T240][trim]")
	QUIT
	;
T241 ; LOW leaves symbols unchanged
	DO EQ^MIOTASSERT($$LOW^MIOHTTP("[]{}-_=+"),"[]{}-_=+","[T241][symbols]")
	QUIT
	;
T242 ; HTOK matrix more valid tokens
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("A"),1,"[T242][A]")
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("Z9"),1,"[T242][Z9]")
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("!#$%&'*+-.^_`|~"),1,"[T242][symbols]")
	QUIT
	;
T243 ; HTOK matrix more invalid tokens
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("a,b"),0,"[T243][comma]")
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("a;b"),0,"[T243][semi]")
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("""a"),0,"[T243][quote]")
	QUIT
	;
T244 ; HVALOK visible boundary chars
	DO EQ^MIOTASSERT($$HVALOK^MIOHTTP(" !~"),1,"[T244][visible]")
	QUIT
	;
T245 ; HVALOK rejects nul
	DO EQ^MIOTASSERT($$HVALOK^MIOHTTP("a"_$C(0)_"b"),0,"[T245][nul]")
	QUIT
	;
T246 ; PARSE multiple normal headers plus body
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p10_t246.req"
	DO WRFILE(DEV,"POST /multi HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10)_"X-A: 1"_$C(13,10)_"X-B: 2"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10)_"ok")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T246][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-a")),"1","[T246][x-a]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-b")),"2","[T246][x-b]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"ok","[T246][body]")
	QUIT
	;
T247 ; PARSE query and repeated header reuse after prior parse
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p10_t247.req"
	DO WRFILE(DEV,"GET /reuse?a=1 HTTP/1.1"_$C(13,10)_"X-T: old"_$C(13,10)_"X-T: new"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T247][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("query","a")),"1","[T247][a]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-t")),"new","[T247][x-t]")
	QUIT
	;
T248 ; RESPX with empty body 200 still CL 0
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p10_t248.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,"","rid248",.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Length: 0":1,1:0),1,"[T248][cl]")
	QUIT
	;
T249 ; RESPJSONX with default headers
	NEW DEV,CONF,CTX,OUT,OP,OBJ
	SET CONF("server","http","defaultResponseHeaders","X-App")="mio"
	SET OBJ("ok")=1
	SET OP="tmp/miohttp_p10_t249.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid249",.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: mio":1,1:0),1,"[T249][x-app]")
	DO EQ^MIOTASSERT($SELECT(OUT["""ok"":1":1,1:0),1,"[T249][body]")
	QUIT
	;
T250 ; full parse then BODY iterator then BODYFREE for global body
	NEW CONF,REQ,ERR,DEV,CUR,CH
	SET CONF("server","limits","maxBodyScalarBytes")=2
	SET DEV="tmp/miohttp_p10_t250.req"
	DO WRFILE(DEV,"POST /big HTTP/1.1"_$C(13,10)_"Content-Length: 4"_$C(13,10,13,10)_"abcd")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T250][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T250][mode]")
	DO BODYOPEN^MIOHTTP(.REQ,.CUR)
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH),1,"[T250][next]")
	DO EQ^MIOTASSERT(CH'="",1,"[T250][chunk]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
T251 ; PARSE loop matrix GET/POST/PUT
	NEW I,CONF,REQ,ERR,DEV,TXT,METH
	SET METH(1)="GET",TXT(1)="GET /g HTTP/1.1"_$C(13,10,13,10)
	SET METH(2)="POST",TXT(2)="POST /p HTTP/1.1"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10)_"ok"
	SET METH(3)="PUT",TXT(3)="PUT /u HTTP/1.1"_$C(13,10)_"Content-Length: 3"_$C(13,10,13,10)_"hey"
	FOR I=1:1:3 DO
	. SET DEV="tmp/miohttp_p11_t251-"_I_".req"
	. DO WRFILE(DEV,TXT(I))
	. KILL REQ,ERR
	. DO OPENR(DEV)
	. DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T251]["_I_"][ok]")
	. DO CLOSER(DEV)
	. DO EQ^MIOTASSERT($GET(REQ("method")),METH(I),"[T251]["_I_"][method]")
	QUIT
	;
T252 ; PARSE loop matrix query extraction
	NEW I,CONF,REQ,ERR,DEV,TXT,VAL
	SET TXT(1)="GET /x?a=1 HTTP/1.1"_$C(13,10,13,10),VAL(1)="1"
	SET TXT(2)="GET /x?a=two HTTP/1.1"_$C(13,10,13,10),VAL(2)="two"
	SET TXT(3)="GET /x?a=hello+world HTTP/1.1"_$C(13,10,13,10),VAL(3)="hello world"
	FOR I=1:1:3 DO
	. SET DEV="tmp/miohttp_p11_t252-"_I_".req"
	. DO WRFILE(DEV,TXT(I))
	. KILL REQ,ERR
	. DO OPENR(DEV)
	. DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T252]["_I_"][ok]")
	. DO CLOSER(DEV)
	. DO EQ^MIOTASSERT($GET(REQ("query","a")),VAL(I),"[T252]["_I_"][a]")
	QUIT
	;
T253 ; PARSE loop matrix bodyless methods stay none
	NEW I,CONF,REQ,ERR,DEV,TXT
	SET TXT(1)="GET /a HTTP/1.1"_$C(13,10,13,10)
	SET TXT(2)="DELETE /b HTTP/1.1"_$C(13,10,13,10)
	SET TXT(3)="OPTIONS * HTTP/1.1"_$C(13,10,13,10)
	FOR I=1:1:3 DO
	. SET DEV="tmp/miohttp_p11_t253-"_I_".req"
	. DO WRFILE(DEV,TXT(I))
	. KILL REQ,ERR
	. DO OPENR(DEV)
	. DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T253]["_I_"][ok]")
	. DO CLOSER(DEV)
	. DO EQ^MIOTASSERT($GET(REQ("body","mode")),"none","[T253]["_I_"][mode]")
	QUIT
	;
T254 ; PARSE repeated invalid content-length remains stable
	NEW I,CONF,REQ,ERR,DEV
	FOR I=1:1:3 DO
	. SET DEV="tmp/miohttp_p11_t254-"_I_".req"
	. DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Content-Length: bad"_$C(13,10,13,10))
	. KILL REQ,ERR
	. DO OPENR(DEV)
	. DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T254]["_I_"][ok]")
	. DO CLOSER(DEV)
	. DO EQ^MIOTASSERT($GET(ERR("error")),"invalid_content_length","[T254]["_I_"][err]")
	QUIT
	;
T255 ; PARSE repeated duplicate host remains stable
	NEW I,CONF,REQ,ERR,DEV
	FOR I=1:1:3 DO
	. SET DEV="tmp/miohttp_p11_t255-"_I_".req"
	. DO WRFILE(DEV,"GET /x HTTP/1.1"_$C(13,10)_"Host: a"_$C(13,10)_"Host: b"_$C(13,10,13,10))
	. KILL REQ,ERR
	. DO OPENR(DEV)
	. DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T255]["_I_"][ok]")
	. DO CLOSER(DEV)
	. DO EQ^MIOTASSERT($GET(ERR("error")),"duplicate_host","[T255]["_I_"][err]")
	QUIT
	;
T256 ; RESP status matrix
	NEW I,DEV,CONF,OUT,OP,HEAD,ST
	SET HEAD("Content-Type")="text/plain"
	SET ST(1)=200,ST(2)=400,ST(3)=404
	FOR I=1:1:3 DO
	. SET OP="tmp/miohttp_p11_t256-"_I_".out"
	. OPEN OP:(newversion:stream:nowrap)
	. SET DEV=OP USE DEV
	. DO RESP^MIOHTTP(.DEV,.CONF,ST(I),.HEAD,"ok","rid256-"_I)
	. CLOSE DEV USE $PRINCIPAL
	. DO READALL(OP,.OUT)
	. DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 "_ST(I):1,1:0),1,"[T256]["_I_"][status]")
	QUIT
	;
T257 ; RESPJSON scalar matrix
	NEW I,DEV,CONF,OUT,OP,OBJ
	FOR I=1:1:3 DO
	. KILL OBJ
	. SET OBJ("n")=I
	. SET OP="tmp/miohttp_p11_t257-"_I_".out"
	. OPEN OP:(newversion:stream:nowrap)
	. SET DEV=OP USE DEV
	. DO RESPJSON^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid257-"_I)
	. CLOSE DEV USE $PRINCIPAL
	. DO READALL(OP,.OUT)
	. DO EQ^MIOTASSERT($SELECT(OUT["""n"":"_I:1,1:0),1,"[T257]["_I_"][json]")
	QUIT
	;
T258 ; STREAM matrix multiple payload sizes
	NEW I,DEV,CONF,CTX,OUT,OP,HEAD,DATA
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET DATA(1)="a",DATA(2)="ab",DATA(3)="abc"
	FOR I=1:1:3 DO
	. SET OP="tmp/miohttp_p11_t258-"_I_".out"
	. OPEN OP:(newversion:stream:nowrap)
	. SET DEV=OP USE DEV
	. DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid258-"_I,.CTX)
	. DO STREAMWRITE^MIOHTTP(.DEV,DATA(I))
	. DO STREAMEND^MIOHTTP(.DEV)
	. CLOSE DEV USE $PRINCIPAL
	. DO READALL(OP,.OUT)
	. DO EQ^MIOTASSERT($SELECT(OUT[$$HEXOUT^MIOHTTP($L(DATA(I)))_$C(13,10)_DATA(I):1,1:0),1,"[T258]["_I_"][chunk]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T259 ; STREAM HEAD matrix suppresses bodies
	NEW I,DEV,CONF,CTX,OUT,OP,HEAD,DATA
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="HEAD"
	SET HEAD("Content-Type")="text/plain"
	SET DATA(1)="aD",DATA(2)="ab"
	FOR I=1:1:2 DO
	. SET OP="tmp/miohttp_p11_t259-"_I_".out"
	. OPEN OP:(newversion:stream:nowrap)
	. SET DEV=OP USE DEV
	. DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid259-"_I,.CTX)
	. DO STREAMWRITE^MIOHTTP(.DEV,DATA(I))
	. DO STREAMEND^MIOHTTP(.DEV)
	. CLOSE DEV USE $PRINCIPAL
	. DO READALL(OP,.OUT)
	. DO EQ^MIOTASSERT($SELECT(OUT[DATA(I):1,1:0),0,"[T259]["_I_"][no body]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T260 ; SENDFILE size matrix GET
	NEW I,DEV,CONF,CTX,OUT,OP,HEAD,FP,TXT
	SET HEAD("Content-Type")="text/plain"
	SET TXT(1)="a",TXT(2)="ab",TXT(3)="abc"
	FOR I=1:1:3 DO
	. SET FP="tmp/miohttp_p11_t260-"_I_".txt"
	. DO WRFILE(FP,TXT(I))
	. KILL ^TMP($J,"MIOHTTP","REQ")
	. SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	. SET OP="tmp/miohttp_p11_t260-"_I_".out"
	. OPEN OP:(newversion:stream:nowrap)
	. SET DEV=OP USE DEV
	. DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid260-"_I,.CTX,"GET"),1,"[T260]["_I_"][ok]")
	. CLOSE DEV USE $PRINCIPAL
	. DO READALL(OP,.OUT)
	. DO EQ^MIOTASSERT($SELECT(OUT[TXT(I):1,1:0),1,"[T260]["_I_"][body]")
	QUIT
	;
T261 ; SENDFILE size matrix HEAD
	NEW I,DEV,CONF,CTX,OUT,OP,HEAD,FP,TXT
	SET HEAD("Content-Type")="text/plain"
	SET TXT(1)="aaaa",TXT(2)="abbb"
	FOR I=1:1:2 DO
	. SET FP="tmp/miohttp_p11_t261-"_I_".txt"
	. DO WRFILE(FP,TXT(I))
	. SET OP="tmp/miohttp_p11_t261-"_I_".out"
	. OPEN OP:(newversion:stream:nowrap)
	. SET DEV=OP USE DEV
	. DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid261-"_I,.CTX,"HEAD"),1,"[T261]["_I_"][ok]")
	. CLOSE DEV USE $PRINCIPAL
	. DO READALL(OP,.OUT)
	. DO EQ^MIOTASSERT($SELECT(OUT[TXT(I):1,1:0),0,"[T261]["_I_"][no body]")
	QUIT
	;
T262 ; BODYAPPEND upgrade matrix
	NEW I,REQ,CONF,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=2
	FOR I=1:1:3 DO
	. KILL REQ,ERR
	. DO BODYINIT^MIOHTTP(.REQ,.CONF,0)
	. DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"ab",.ERR)
	. IF I>1 DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"cd",.ERR)
	. IF I>2 DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"ef",.ERR)
	. IF I=1 DO EQ^MIOTASSERT($GET(REQ("body","mode")),"scalar","[T262][1][scalar]")
	. IF I=2 DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T262][2][global]")
	. IF I=3 DO EQ^MIOTASSERT($GET(REQ("body","len")),6,"[T262][3][len]")
	. DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T263 ; STATUS4ERR matrix repeated
	NEW I,ERR,NAME,EXP
	SET NAME(1)="payload_too_large",EXP(1)=413
	SET NAME(2)="headers_too_large",EXP(2)=431
	SET NAME(3)="too_many_headers",EXP(3)=431
	SET NAME(4)="read_timeout",EXP(4)=408
	FOR I=1:1:4 DO
	. KILL ERR
	. SET ERR("error")=NAME(I)
	. DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),EXP(I),"[T263]["_I_"][map]")
	QUIT
	;
T264 ; STATUSMSG matrix repeated
	DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(200),"OK","[T264][200]")
	DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(400),"Bad Request","[T264][400]")
	DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(404),"Not Found","[T264][404]")
	DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(503),"Service Unavailable","[T264][503]")
	QUIT
	;
T265 ; HTOK repeated valid values
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("host"),1,"[T265][host]")
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("x-custom-1"),1,"[T265][custom]")
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("etag"),1,"[T265][etag]")
	QUIT
	;
T266 ; HVALOK repeated invalid values
	DO EQ^MIOTASSERT($$HVALOK^MIOHTTP("a"_$C(0)_"b"),0,"[T266][nul]")
	DO EQ^MIOTASSERT($$HVALOK^MIOHTTP("a"_$C(13)_"b"),0,"[T266][cr]")
	DO EQ^MIOTASSERT($$HVALOK^MIOHTTP("a"_$C(10)_"b"),0,"[T266][lf]")
	QUIT
	;
T267 ; URLDECQ matrix
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("a+b"),"a b","[T267][plus]")
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("%41"),"A","[T267][A]")
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("%2F"),"/","[T267][slash]")
	QUIT
	;
T268 ; PARSEQRY matrix
	NEW REQ
	DO PARSEQRY^MIOHTTP("/x?a=1&b=2&c=3",.REQ)
	DO EQ^MIOTASSERT($GET(REQ("query","a")),"1","[T268][a]")
	DO EQ^MIOTASSERT($GET(REQ("query","b")),"2","[T268][b]")
	DO EQ^MIOTASSERT($GET(REQ("query","c")),"3","[T268][c]")
	QUIT
	;
T269 ; PARSE and CURMETH isolation
	NEW CONF,REQ,ERR,DEV
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET DEV="tmp/miohttp_p11_t269.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10)_"ok")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T269][ok]")
	DO CLOSER(DEV)
	SET ^TMP($J,"MIOHTTP","REQ","method")=$GET(REQ("method"))
	DO EQ^MIOTASSERT($$CURMETH^MIOHTTP(),"post","[T269][curmeth]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T270 ; RESP explicit header override confirmed
	NEW DEV,CONF,OUT,OP,HEAD
	SET CONF("server","http","defaultResponseHeaders","X-App")="default"
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("X-App")="explicit"
	SET OP="tmp/miohttp_p11_t270.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,200,.HEAD,"ok","rid270")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: explicit":1,1:0),1,"[T270][explicit]")
	QUIT
	;
T271 ; RESPJSON explicit default header merge confirmed
	NEW DEV,CONF,OUT,OP,OBJ
	SET CONF("server","http","defaultResponseHeaders","X-App")="mio"
	SET OBJ("ok")=1
	SET OP="tmp/miohttp_p11_t271.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSON^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid271")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: mio":1,1:0),1,"[T271][x-app]")
	QUIT
	;
T272 ; STREAMBEGIN records ctx status repeatedly
	NEW I,DEV,CONF,CTX,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	FOR I=1:1:2 DO
	. SET OP="tmp/miohttp_p11_t272-"_I_".out"
	. OPEN OP:(newversion:stream:nowrap)
	. SET DEV=OP USE DEV
	. DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,206,.HEAD,"rid272-"_I,.CTX)
	. DO STREAMEND^MIOHTTP(.DEV)
	. CLOSE DEV USE $PRINCIPAL
	. DO EQ^MIOTASSERT($GET(CTX("status")),206,"[T272]["_I_"][status]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T273 ; READCHUNKED repeated small bodies stable
	NEW I,CONF,REQ,ERR,DEV
	FOR I=1:1:3 DO
	. SET DEV="tmp/miohttp_p11_t273-"_I_".req"
	. DO WRFILE(DEV,"1"_$C(13,10)_"x"_$C(13,10)_"0"_$C(13,10,13,10))
	. KILL REQ,ERR
	. DO OPENR(DEV)
	. DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	. DO CLOSER(DEV)
	. DO EQ^MIOTASSERT($GET(ERR("error")),"","[T273]["_I_"][no err]")
	. DO EQ^MIOTASSERT($GET(REQ("body")),"x","[T273]["_I_"][body]")
	QUIT
	;
T274 ; READCL repeated exact bodies stable
	NEW I,CONF,REQ,ERR,DEV
	FOR I=1:1:3 DO
	. SET DEV="tmp/miohttp_p11_t274-"_I_".req"
	. DO WRFILE(DEV,"abcd")
	. KILL REQ,ERR
	. DO OPENR(DEV)
	. DO READCL^MIOHTTP(DEV,.CONF,.REQ,4,.ERR)
	. DO CLOSER(DEV)
	. DO EQ^MIOTASSERT($GET(ERR("error")),"","[T274]["_I_"][no err]")
	. DO EQ^MIOTASSERT($GET(REQ("body","len")),4,"[T274]["_I_"][len]")
	QUIT
	;
T275 ; PARSE then RESP roundtrip matrix
	NEW I,CONF,REQ,ERR,DEV,OP,OUT,RDEV,HEAD,PATH
	SET PATH(1)="/a",PATH(2)="/b"
	FOR I=1:1:2 DO
	. SET DEV="tmp/miohttp_p11_t275-"_I_".req"
	. DO WRFILE(DEV,"GET "_PATH(I)_" HTTP/1.1"_$C(13,10,13,10))
	. KILL REQ,ERR
	. DO OPENR(DEV)
	. DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T275]["_I_"][parse]")
	. DO CLOSER(DEV)
	. SET HEAD("Content-Type")="text/plain"
	. SET OP="tmp/miohttp_p11_t275-"_I_".out"
	. OPEN OP:(newversion:stream:nowrap)
	. SET RDEV=OP USE RDEV
	. DO RESP^MIOHTTP(.RDEV,.CONF,200,.HEAD,"ok","rid275-"_I)
	. CLOSE RDEV USE $PRINCIPAL
	. DO READALL(OP,.OUT)
	. DO EQ^MIOTASSERT($SELECT(OUT["200 OK":1,1:0),1,"[T275]["_I_"][resp]")
	QUIT
T276 ; PARSE repeated empty query marker stable
	NEW I,CONF,REQ,ERR,DEV
	FOR I=1:1:3 DO
	. SET DEV="tmp/miohttp_p12_t276-"_I_".req"
	. DO WRFILE(DEV,"GET /x? HTTP/1.1"_$C(13,10,13,10))
	. KILL REQ,ERR
	. DO OPENR(DEV)
	. DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T276]["_I_"][ok]")
	. DO CLOSER(DEV)
	. DO EQ^MIOTASSERT($GET(REQ("path")),"/x","[T276]["_I_"][path]")
	QUIT
	;
T277 ; PARSE repeated encoded query values stable
	NEW I,CONF,REQ,ERR,DEV
	FOR I=1:1:3 DO
	. SET DEV="tmp/miohttp_p12_t277-"_I_".req"
	. DO WRFILE(DEV,"GET /q?a=%2F&b=hello+world HTTP/1.1"_$C(13,10,13,10))
	. KILL REQ,ERR
	. DO OPENR(DEV)
	. DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T277]["_I_"][ok]")
	. DO CLOSER(DEV)
	. DO EQ^MIOTASSERT($GET(REQ("query","a")),"/","[T277]["_I_"][a]")
	. DO EQ^MIOTASSERT($GET(REQ("query","b")),"hello world","[T277]["_I_"][b]")
	QUIT
	;
T278 ; BODYINIT zero expected length with small scalar limit
	NEW REQ,CONF
	SET CONF("server","limits","maxBodyScalarBytes")=1
	DO BODYINIT^MIOHTTP(.REQ,.CONF,0)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"scalar","[T278][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body","len")),0,"[T278][len]")
	QUIT
	;
T279 ; BODYAPPEND empty append keeps scalar state
	NEW REQ,CONF,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=10
	DO BODYINIT^MIOHTTP(.REQ,.CONF,0)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"",.ERR)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"scalar","[T279][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body","len")),0,"[T279][len]")
	QUIT
	;
T280 ; BODYAPPEND exact scalar threshold remains scalar
	NEW REQ,CONF,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=4
	DO BODYINIT^MIOHTTP(.REQ,.CONF,0)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"ab",.ERR)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"cd",.ERR)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"scalar","[T280][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"abcd","[T280][body]")
	QUIT
	;
T281 ; BODYUP on already-global body stays global
	NEW REQ,CONF
	SET REQ("body","mode")="global"
	SET REQ("body","ref")=$NAME(^TMP($J,"MIOHTTPP12","T281"))
	SET REQ("body","n")=1
	SET REQ("body","len")=2
	SET ^TMP($J,"MIOHTTPP12","T281",1)="ab"
	DO BODYUP^MIOHTTP(.REQ,.CONF)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T281][mode]")
	DO EQ^MIOTASSERT($GET(^TMP($J,"MIOHTTPP12","T281",1)),"ab","[T281][chunk]")
	KILL ^TMP($J,"MIOHTTPP12","T281")
	QUIT
	;
T282 ; BODYLEN none mode zero
	NEW REQ
	SET REQ("body","mode")="none"
	SET REQ("body","len")=0
	DO EQ^MIOTASSERT($$BODYLEN^MIOHTTP(.REQ),0,"[T282][len]")
	QUIT
	;
T283 ; BODYLEN scalar mode exact
	NEW REQ
	SET REQ("body","mode")="scalar"
	SET REQ("body")="hello"
	SET REQ("body","len")=5
	DO EQ^MIOTASSERT($$BODYLEN^MIOHTTP(.REQ),5,"[T283][len]")
	QUIT
	;
T284 ; BODYLEN global mode exact
	NEW REQ
	SET REQ("body","mode")="global"
	SET REQ("body","ref")=$NAME(^TMP($J,"MIOHTTPP12","T284"))
	SET REQ("body","n")=2
	SET REQ("body","len")=7
	SET ^TMP($J,"MIOHTTPP12","T284",1)="abc"
	SET ^TMP($J,"MIOHTTPP12","T284",2)="defg"
	DO EQ^MIOTASSERT($$BODYLEN^MIOHTTP(.REQ),7,"[T284][len]")
	KILL ^TMP($J,"MIOHTTPP12","T284")
	QUIT
	;
T285 ; READCL exact threshold to global config still scalar
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p12_t285.req"
	SET CONF("server","limits","maxBodyScalarBytes")=4
	DO WRFILE(DEV,"abcd")
	DO OPENR(DEV)
	DO READCL^MIOHTTP(DEV,.CONF,.REQ,4,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"scalar","[T285][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"abcd","[T285][body]")
	QUIT
	;
T286 ; READCL above threshold to global config goes global
	NEW REQ,ERR,CONF,DEV
	SET DEV="tmp/miohttp_p12_t286.req"
	SET CONF("server","limits","maxBodyScalarBytes")=4
	DO WRFILE(DEV,"abcde")
	DO OPENR(DEV)
	DO READCL^MIOHTTP(DEV,.CONF,.REQ,5,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T286][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body","len")),5,"[T286][len]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T287 ; READCHUNKED exact maxBodyBytes boundary passes
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","limits","maxBodyBytes")=3
	SET DEV="tmp/miohttp_p12_t287.req"
	DO WRFILE(DEV,"3"_$C(13,10)_"abc"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T287][no err]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"abc","[T287][body]")
	QUIT
	;
T288 ; PARSE exact maxBodyBytes boundary passes
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","limits","maxBodyBytes")=3
	SET DEV="tmp/miohttp_p12_t288.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Content-Length: 3"_$C(13,10,13,10)_"abc")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T288][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"abc","[T288][body]")
	QUIT
	;
T289 ; STREAMBEGIN explicit header overrides default same key
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET CONF("server","http","defaultResponseHeaders","X-App")="default"
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("X-App")="explicit"
	SET OP="tmp/miohttp_p12_t289.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid289",.CTX)
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: explicit":1,1:0),1,"[T289][explicit]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T290 ; RESPJSON explicit header with default merge
	NEW DEV,CONF,OUT,OP,OBJ
	SET CONF("server","http","defaultResponseHeaders","X-App")="mio"
	SET OBJ("ok")=1
	SET OP="tmp/miohttp_p12_t290.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSON^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid290")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Type: application/json":1,1:0),1,"[T290][ctype]")
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: mio":1,1:0),1,"[T290][x-app]")
	QUIT
	;
T291 ; RESPJSON nested numeric and string fields
	NEW DEV,CONF,OUT,OP,OBJ
	SET OBJ("n")=9
	SET OBJ("s")="txt"
	SET OP="tmp/miohttp_p12_t291.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSON^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid291")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["""n"":9":1,1:0),1,"[T291][n]")
	DO EQ^MIOTASSERT($SELECT(OUT["""s"":""txt""":1,1:0),1,"[T291][s]")
	QUIT
	;
T292 ; RESPJSONX nested numeric and string fields
	NEW DEV,CONF,CTX,OUT,OP,OBJ
	SET OBJ("n")=9
	SET OBJ("s")="txt"
	SET OP="tmp/miohttp_p12_t292.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid292",.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["""n"":9":1,1:0),1,"[T292][n]")
	DO EQ^MIOTASSERT($SELECT(OUT["""s"":""txt""":1,1:0),1,"[T292][s]")
	QUIT
	;
T293 ; SENDFILE missing file repeated stable
	NEW I,DEV,CONF,CTX,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	FOR I=1:1:2 DO
	. SET OP="tmp/miohttp_p12_t293-"_I_".out"
	. OPEN OP:(newversion:stream:nowrap)
	. SET DEV=OP USE DEV
	. DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,"tmp/no_such_p12_"_I_".txt",.HEAD,"rid293-"_I,.CTX,"GET"),0,"[T293]["_I_"][ok]")
	. CLOSE DEV USE $PRINCIPAL
	. DO EQ^MIOTASSERT($GET(CTX("err","error")),"open_failed","[T293]["_I_"][err]")
	QUIT
	;
T294 ; SENDFILE with explicit method GET independent of CURMETH
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p12_t294.txt"
	DO WRFILE(FP,"body294")
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="HEAD"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p12_t294.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid294",.CTX,"GET"),1,"[T294][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["body294":1,1:0),1,"[T294][body]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T295 ; SENDFILE with explicit method HEAD independent of CURMETH
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p12_t295.txt"
	DO WRFILE(FP,"body295")
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p12_t295.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid295",.CTX,"HEAD"),1,"[T295][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["body295":1,1:0),0,"[T295][no body]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T296 ; STATUS4ERR repeated unknown fallback stays 400
	NEW I,ERR
	FOR I=1:1:3 DO
	. SET ERR("error")="unknown_"_I
	. DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),400,"[T296]["_I_"][400]")
	QUIT
	;
T297 ; TE helpers matrix
	DO EQ^MIOTASSERT($$TEHAS^MIOHTTP("identity, chunked","identity"),1,"[T297][has identity]")
	DO EQ^MIOTASSERT($$TEHAS^MIOHTTP("identity, chunked","chunked"),1,"[T297][has chunked]")
	DO EQ^MIOTASSERT($$TEHAS^MIOHTTP("identity","chunked"),0,"[T297][no chunked]")
	QUIT
	;
T298 ; TECHUNKLAST matrix
	DO EQ^MIOTASSERT($$TECHUNKLAST^MIOHTTP("chunked"),1,"[T298][chunked only]")
	DO EQ^MIOTASSERT($$TECHUNKLAST^MIOHTTP("identity, chunked"),1,"[T298][chunked last]")
	DO EQ^MIOTASSERT($$TECHUNKLAST^MIOHTTP("chunked, identity"),0,"[T298][chunked not last]")
	QUIT
	;
T299 ; TEOK matrix
	DO EQ^MIOTASSERT($$TEOK^MIOHTTP("identity"),1,"[T299][identity]")
	DO EQ^MIOTASSERT($$TEOK^MIOHTTP("chunked"),1,"[T299][chunked]")
	DO EQ^MIOTASSERT($$TEOK^MIOHTTP("gzip"),0,"[T299][gzip]")
	QUIT
	;
T300 ; mixed parse sequence with valid then invalid then valid
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p12_t300a.req"
	DO WRFILE(DEV,"GET /ok HTTP/1.1"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T300][a ok]")
	DO CLOSER(DEV)
	SET DEV="tmp/miohttp_p12_t300b.req"
	DO WRFILE(DEV,"POST /bad HTTP/1.1"_$C(13,10)_"Content-Length: bad"_$C(13,10,13,10))
	KILL REQ,ERR
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T300][b ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"invalid_content_length","[T300][b err]")
	SET DEV="tmp/miohttp_p12_t300c.req"
	DO WRFILE(DEV,"GET /ok2 HTTP/1.1"_$C(13,10,13,10))
	KILL REQ,ERR
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T300][c ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("path")),"/ok2","[T300][c path]")
	QUIT
T301 ; PARSEREQLINE GET root
	NEW REQ,ERR
	DO PARSEREQLINE^MIOHTTP("GET / HTTP/1.1",.REQ,.ERR)
	DO EQ^MIOTASSERT($GET(REQ("method")),"GET","[T301][method]")
	DO EQ^MIOTASSERT($GET(REQ("path")),"/","[T301][path]")
	QUIT
	;
T302 ; PARSEREQLINE POST nested path
	NEW REQ,ERR
	DO PARSEREQLINE^MIOHTTP("POST /api/v1/items HTTP/1.1",.REQ,.ERR)
	DO EQ^MIOTASSERT($GET(REQ("method")),"POST","[T302][method]")
	DO EQ^MIOTASSERT($GET(REQ("path")),"/api/v1/items","[T302][path]")
	QUIT
	;
T303 ; PARSEREQLINE PATCH with query
	NEW REQ,ERR
	DO PARSEREQLINE^MIOHTTP("PATCH /thing?id=9&ok=1 HTTP/1.1",.REQ,.ERR)
	DO EQ^MIOTASSERT($GET(REQ("path")),"/thing","[T303][path]")
	DO EQ^MIOTASSERT($GET(REQ("query","id")),"9","[T303][id]")
	DO EQ^MIOTASSERT($GET(REQ("query","ok")),"1","[T303][ok]")
	QUIT
	;
T304 ; PARSEREQLINE HTTP/1.0 root
	NEW REQ,ERR
	DO PARSEREQLINE^MIOHTTP("HEAD / HTTP/1.0",.REQ,.ERR)
	DO EQ^MIOTASSERT($GET(REQ("httpver")),"HTTP/1.0","[T304][ver]")
	DO EQ^MIOTASSERT($GET(REQ("method")),"HEAD","[T304][method]")
	QUIT
	;
T305 ; PARSEREQLINE rawpath preserved with query
	NEW REQ,ERR
	DO PARSEREQLINE^MIOHTTP("GET /x?a=1&b=2 HTTP/1.1",.REQ,.ERR)
	DO EQ^MIOTASSERT($GET(REQ("rawpath")),"/x?a=1&b=2","[T305][rawpath]")
	QUIT
	;
T306 ; PARSE host header case preserved in value and lowercased in name
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p13_t306.req"
	DO WRFILE(DEV,"GET /x HTTP/1.1"_$C(13,10)_"HoSt: Example.COM"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T306][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("hdr","host")),"Example.COM","[T306][host]")
	QUIT
	;
T307 ; PARSE content-type plus bodyless GET
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p13_t307.req"
	DO WRFILE(DEV,"GET /plain HTTP/1.1"_$C(13,10)_"Content-Type: text/plain"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T307][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("hdr","content-type")),"text/plain","[T307][ctype]")
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"none","[T307][mode]")
	QUIT
	;
T308 ; PARSE x headers plus query plus body
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p13_t308.req"
	DO WRFILE(DEV,"POST /submit?a=1 HTTP/1.1"_$C(13,10)_"X-A: 7"_$C(13,10)_"X-B: 8"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10)_"ok")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T308][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("query","a")),"1","[T308][a]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-a")),"7","[T308][x-a]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-b")),"8","[T308][x-b]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"ok","[T308][body]")
	QUIT
	;
T309 ; PARSE repeated custom header last wins stable
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p13_t309.req"
	DO WRFILE(DEV,"GET /x HTTP/1.1"_$C(13,10)_"X-Mode: one"_$C(13,10)_"X-Mode: two"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T309][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-mode")),"two","[T309][mode]")
	QUIT
	;
T310 ; PARSE fixed body with exact scalar threshold
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","limits","maxBodyScalarBytes")=3
	SET DEV="tmp/miohttp_p13_t310.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Content-Length: 3"_$C(13,10,13,10)_"hey")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T310][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"scalar","[T310][mode]")
	QUIT
	;
T311 ; PARSE fixed body above scalar threshold goes global
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","limits","maxBodyScalarBytes")=3
	SET DEV="tmp/miohttp_p13_t311.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Content-Length: 4"_$C(13,10,13,10)_"heyy")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T311][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T311][mode]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T312 ; READCHUNKED iterator on scalar result
	NEW CONF,REQ,ERR,DEV,CUR,CH
	SET DEV="tmp/miohttp_p13_t312.req"
	DO WRFILE(DEV,"2"_$C(13,10)_"ab"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO BODYOPEN^MIOHTTP(.REQ,.CUR)
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH),1,"[T312][next]")
	DO EQ^MIOTASSERT(CH,"ab","[T312][chunk]")
	QUIT
	;
T313 ; READCHUNKED global threshold path
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","limits","maxBodyScalarBytes")=2
	SET DEV="tmp/miohttp_p13_t313.req"
	DO WRFILE(DEV,"2"_$C(13,10)_"ab"_$C(13,10)_"2"_$C(13,10)_"cd"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T313][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body","len")),4,"[T313][len]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T314 ; RESP 205 body suppression
	NEW DEV,CONF,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p13_t314.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,205,.HEAD,"abc","rid314")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 205 ":1,1:0),1,"[T314][status]")
	DO EQ^MIOTASSERT($SELECT(OUT[$C(13,10,13,10)_"abc":1,1:0),0,"[T314][no body]")
	QUIT
	;
T315 ; RESP HEAD plus 204 still no body
	NEW DEV,CONF,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="HEAD"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p13_t315.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,204,.HEAD,"abc","rid315")
	CLOSE DEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT[$C(13,10,13,10)_"abc":1,1:0),0,"[T315][no body]")
	QUIT
	;
T316 ; RESPJSON HEAD plus 204 no body
	NEW DEV,CONF,OUT,OP,OBJ
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="HEAD"
	SET OBJ("ok")=1
	SET OP="tmp/miohttp_p13_t316.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSON^MIOHTTP(.DEV,.CONF,204,.OBJ,"rid316")
	CLOSE DEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT[$C(13,10,13,10)_"{":1,1:0),0,"[T316][no body]")
	QUIT
	;
T317 ; STREAMBEGIN 205 not chunked
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p13_t317.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,205,.HEAD,"rid317",.CTX)
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Transfer-Encoding: chunked":1,1:0),0,"[T317][not chunked]")
	QUIT
	;
T318 ; STREAM multiple empty writes around data
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p13_t318.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid318",.CTX)
	DO STREAMWRITE^MIOHTTP(.DEV,"")
	DO STREAMWRITE^MIOHTTP(.DEV,"ab")
	DO STREAMWRITE^MIOHTTP(.DEV,"")
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["2"_$C(13,10)_"ab"_$C(13,10):1,1:0),1,"[T318][chunk]")
	QUIT
	;
T319 ; RESP default header matrix two defaults
	NEW DEV,CONF,OUT,OP,HEAD
	SET CONF("server","http","defaultResponseHeaders","X-A")="1"
	SET CONF("server","http","defaultResponseHeaders","X-B")="2"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p13_t319.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,200,.HEAD,"ok","rid319")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-A: 1":1,1:0),1,"[T319][x-a]")
	DO EQ^MIOTASSERT($SELECT(OUT["X-B: 2":1,1:0),1,"[T319][x-b]")
	QUIT
	;
T320 ; RESPJSON default header matrix two defaults
	NEW DEV,CONF,OUT,OP,OBJ
	SET CONF("server","http","defaultResponseHeaders","X-A")="1"
	SET CONF("server","http","defaultResponseHeaders","X-B")="2"
	SET OBJ("ok")=1
	SET OP="tmp/miohttp_p13_t320.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSON^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid320")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-A: 1":1,1:0),1,"[T320][x-a]")
	DO EQ^MIOTASSERT($SELECT(OUT["X-B: 2":1,1:0),1,"[T320][x-b]")
	QUIT
	;
T321 ; SENDFILE default header matrix
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p13_t321.txt"
	DO WRFILE(FP,"321")
	SET CONF("server","http","defaultResponseHeaders","X-A")="1"
	SET CONF("server","http","defaultResponseHeaders","X-B")="2"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p13_t321.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid321",.CTX,"GET"),1,"[T321][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-A: 1":1,1:0),1,"[T321][x-a]")
	DO EQ^MIOTASSERT($SELECT(OUT["X-B: 2":1,1:0),1,"[T321][x-b]")
	QUIT
	;
T322 ; CURMETH uppercase fallback repeated
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","METHOD")="DELETE"
	DO EQ^MIOTASSERT($$CURMETH^MIOHTTP(),"delete","[T322][delete]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","METHOD")="PATCH"
	DO EQ^MIOTASSERT($$CURMETH^MIOHTTP(),"patch","[T322][patch]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T323 ; URLDECQ repeated invalid tail preserved
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("abc%"),"abc%","[T323][pct]")
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("abc%X"),"abc%X","[T323][pctx]")
	QUIT
	;
T324 ; HEXOUT matrix small values
	DO EQ^MIOTASSERT($$HEXOUT^MIOHTTP(1),"1","[T324][1]")
	DO EQ^MIOTASSERT($$HEXOUT^MIOHTTP(15),"F","[T324][15]")
	DO EQ^MIOTASSERT($$HEXOUT^MIOHTTP(16),"10","[T324][16]")
	QUIT
	;
T325 ; mixed valid-invalid-valid chunked parse sequence
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","http","supportChunkedRequest")=1
	SET DEV="tmp/miohttp_p13_t325a.req"
	DO WRFILE(DEV,"POST /c HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10,13,10)_"1"_$C(13,10)_"a"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T325][a ok]")
	DO CLOSER(DEV)
	SET DEV="tmp/miohttp_p13_t325b.req"
	DO WRFILE(DEV,"POST /c HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10,13,10)_"ZZ"_$C(13,10))
	KILL REQ,ERR
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T325][b ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"bad_chunk_size","[T325][b err]")
	SET DEV="tmp/miohttp_p13_t325c.req"
	DO WRFILE(DEV,"POST /c HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10,13,10)_"1"_$C(13,10)_"z"_$C(13,10)_"0"_$C(13,10,13,10))
	KILL REQ,ERR
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T325][c ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"z","[T325][c body]")
	QUIT
T326 ; READHDRS single host header direct
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p14_t326.req"
	DO WRFILE(DEV,"Host: example.com"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T326][no err]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","host")),"example.com","[T326][host]")
	QUIT
	;
T327 ; READHDRS multiple simple headers direct
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p14_t327.req"
	DO WRFILE(DEV,"Host: ex"_$C(13,10)_"X-A: 1"_$C(13,10)_"X-B: 2"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("hdr","host")),"ex","[T327][host]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-a")),"1","[T327][x-a]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-b")),"2","[T327][x-b]")
	QUIT
	;
T328 ; READHDRS empty header block direct
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p14_t328.req"
	DO WRFILE(DEV,$C(13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T328][no err]")
	DO EQ^MIOTASSERT($DATA(REQ("hdr")),0,"[T328][no hdr]")
	QUIT
	;
T329 ; READHDRS header line bytes exact boundary
	NEW CONF,REQ,ERR,DEV,LINE
	SET LINE="X-A: 1"
	SET CONF("server","limits","maxHeaderLineBytes")=$L(LINE)
	SET DEV="tmp/miohttp_p14_t329.req"
	DO WRFILE(DEV,LINE_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T329][no err]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-a")),"1","[T329][x-a]")
	QUIT
	;
T330 ; READHDRS header bytes exact boundary
	NEW CONF,REQ,ERR,DEV,LINE
	SET LINE="X-A: 1"
	SET CONF("server","limits","maxHeaderBytes")=$L(LINE)+2
	SET DEV="tmp/miohttp_p14_t330.req"
	DO WRFILE(DEV,LINE_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T330][no err]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-a")),"1","[T330][x-a]")
	QUIT
	;
T331 ; PARSEHDRS with request line only
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p14_t331.req"
	DO WRFILE(DEV,"GET /solo HTTP/1.1"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T331][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("method")),"GET","[T331][method]")
	DO EQ^MIOTASSERT($GET(REQ("path")),"/solo","[T331][path]")
	QUIT
	;
T332 ; PARSEHDRS with request line plus headers
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p14_t332.req"
	DO WRFILE(DEV,"GET /hdr HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10)_"X-T: 9"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T332][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("hdr","host")),"ex","[T332][host]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-t")),"9","[T332][x-t]")
	QUIT
	;
T333 ; PARSEHDRS bad header after valid request line
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p14_t333.req"
	DO WRFILE(DEV,"GET /hdr HTTP/1.1"_$C(13,10)_"Bad Header: x"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T333][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"invalid_header_name","[T333][err]")
	QUIT
	;
T334 ; READLINE repeated lines direct
	NEW DEV,X,ERR
	SET DEV="tmp/miohttp_p14_t334.req"
	DO WRFILE(DEV,"one"_$C(13,10)_"two"_$C(13,10))
	DO OPENR(DEV)
	DO READLINE^MIOHTTP(DEV,1,.X,.ERR)
	DO EQ^MIOTASSERT(X,"one","[T334][one]")
	DO READLINE^MIOHTTP(DEV,1,.X,.ERR)
	DO EQ^MIOTASSERT(X,"two","[T334][two]")
	DO CLOSER(DEV)
	QUIT
	;
T335 ; READLINE blank then text
	NEW DEV,X,ERR
	SET DEV="tmp/miohttp_p14_t335.req"
	DO WRFILE(DEV,$C(13,10)_"abc"_$C(13,10))
	DO OPENR(DEV)
	DO READLINE^MIOHTTP(DEV,1,.X,.ERR)
	DO EQ^MIOTASSERT(X,"","[T335][blank]")
	DO READLINE^MIOHTTP(DEV,1,.X,.ERR)
	DO EQ^MIOTASSERT(X,"abc","[T335][abc]")
	DO CLOSER(DEV)
	QUIT
	;
T336 ; READFIX repeated sequential reads
	NEW DEV,X,ERR
	SET DEV="tmp/miohttp_p14_t336.req"
	DO WRFILE(DEV,"abcdef")
	DO OPENR(DEV)
	DO READFIX^MIOHTTP(DEV,2,1,.X,.ERR)
	DO EQ^MIOTASSERT(X,"ab","[T336][ab]")
	DO READFIX^MIOHTTP(DEV,2,1,.X,.ERR)
	DO EQ^MIOTASSERT(X,"cd","[T336][cd]")
	DO CLOSER(DEV)
	QUIT
	;
T337 ; READFIX final short read after exact read
	NEW DEV,X,ERR
	SET DEV="tmp/miohttp_p14_t337.req"
	DO WRFILE(DEV,"ab")
	DO OPENR(DEV)
	DO READFIX^MIOHTTP(DEV,2,1,.X,.ERR)
	DO EQ^MIOTASSERT(X,"ab","[T337][ab]")
	DO READFIX^MIOHTTP(DEV,1,1,.X,.ERR)
	DO EQ^MIOTASSERT($GET(ERR("error"))="short_read",1,"[T337][short]")
	DO CLOSER(DEV)
	QUIT
	;
T338 ; WRESP byte count off when stream inactive
	NEW DEV,OP
	KILL ^TMP($J,"MIOHTTP","STREAM")
	SET OP="tmp/miohttp_p14_t338.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO WRESP^MIOHTTP(.DEV,"abc")
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($DATA(^TMP($J,"MIOHTTP","STREAM","bytes")),0,"[T338][no bytes]")
	QUIT
	;
T339 ; WRESP byte count accumulates when stream active
	NEW DEV,OP
	KILL ^TMP($J,"MIOHTTP","STREAM")
	SET ^TMP($J,"MIOHTTP","STREAM","active")=1
	SET ^TMP($J,"MIOHTTP","STREAM","bytes")=0
	SET OP="tmp/miohttp_p14_t339.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO WRESP^MIOHTTP(.DEV,"ab")
	DO WRESP^MIOHTTP(.DEV,"cde")
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($GET(^TMP($J,"MIOHTTP","STREAM","bytes")),5,"[T339][bytes]")
	KILL ^TMP($J,"MIOHTTP","STREAM")
	QUIT
	;
T340 ; RESP explicit content-type text html
	NEW DEV,CONF,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/html"
	SET OP="tmp/miohttp_p14_t340.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,200,.HEAD,"<b>x</b>","rid340")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Type: text/html":1,1:0),1,"[T340][ctype]")
	QUIT
	;
T341 ; RESPJSON content-length present
	NEW DEV,CONF,OUT,OP,OBJ
	SET OBJ("ok")=1
	SET OP="tmp/miohttp_p14_t341.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSON^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid341")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Length: ":1,1:0),1,"[T341][cl]")
	QUIT
	;
T342 ; RESPX updates ctx status
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p14_t342.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPX^MIOHTTP(.DEV,.CONF,202,.HEAD,"ok","rid342",.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($GET(CTX("status")),202,"[T342][ctx status]")
	QUIT
	;
T343 ; RESPJSONX updates ctx status
	NEW DEV,CONF,CTX,OUT,OP,OBJ
	SET OBJ("ok")=1
	SET OP="tmp/miohttp_p14_t343.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,202,.OBJ,"rid343",.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($GET(CTX("status")),202,"[T343][ctx status]")
	QUIT
	;
T344 ; STREAMBEGIN updates ctx status
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p14_t344.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,201,.HEAD,"rid344",.CTX)
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($GET(CTX("status")),201,"[T344][ctx status]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T345 ; SENDFILE updates ctx status on success
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p14_t345.txt"
	DO WRFILE(FP,"345")
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p14_t345.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid345",.CTX,"GET"),1,"[T345][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($GET(CTX("status")),200,"[T345][ctx status]")
	QUIT
	;
T346 ; SENDFILE default plus explicit override
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p14_t346.txt"
	DO WRFILE(FP,"346")
	SET CONF("server","http","defaultResponseHeaders","X-App")="default"
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("X-App")="explicit"
	SET OP="tmp/miohttp_p14_t346.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid346",.CTX,"GET"),1,"[T346][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: explicit":1,1:0),1,"[T346][explicit]")
	QUIT
	;
T347 ; PARSE then RESPJSON roundtrip
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,OBJ
	SET DEV="tmp/miohttp_p14_t347.req"
	DO WRFILE(DEV,"GET /json HTTP/1.1"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T347][parse]")
	DO CLOSER(DEV)
	SET OBJ("path")=$GET(REQ("path"))
	SET OP="tmp/miohttp_p14_t347.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO RESPJSON^MIOHTTP(.RDEV,.CONF,200,.OBJ,"rid347")
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["""path"":""\/json""":1,1:0),1,"[T347][json]")
	QUIT
	;
T348 ; PARSEHEADERS then READBODYONLY split flow
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p14_t348.req"
	DO WRFILE(DEV,"POST /split HTTP/1.1"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10)_"ok")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T348][hdrs]")
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T348][bodyonly]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"ok","[T348][body]")
	QUIT
	;
T349 ; PARSEHDRS then READBODYONLY chunked split flow
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","http","supportChunkedRequest")=1
	SET DEV="tmp/miohttp_p14_t349.req"
	DO WRFILE(DEV,"POST /splitc HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10,13,10)_"2"_$C(13,10)_"ok"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T349][hdrs]")
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T349][bodyonly]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"ok","[T349][body]")
	QUIT
	;
T350 ; mixed direct helper sequence stable
	NEW REQ,ERR
	DO PARSEREQLINE^MIOHTTP("GET /mix?a=1 HTTP/1.1",.REQ,.ERR)
	DO EQ^MIOTASSERT($GET(REQ("query","a")),"1","[T350][query]")
	DO EQ^MIOTASSERT($$LOW^MIOHTTP("AbC"),"abc","[T350][low]")
	DO EQ^MIOTASSERT($$TRIM^MIOHTTP("  x  "),"x","[T350][trim]")
	DO EQ^MIOTASSERT($$HEXOUT^MIOHTTP(31),"1F","[T350][hexout]")
	QUIT
T351 ; READHDRS trims value with inner spaces preserved
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p15_t351.req"
	DO WRFILE(DEV,"X-Test:  a  b  "_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T351][no err]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-test")),"a  b","[T351][value]")
	QUIT
	;
T352 ; READHDRS header count exact one
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","limits","maxHeaderCount")=1
	SET DEV="tmp/miohttp_p15_t352.req"
	DO WRFILE(DEV,"X-A: 1"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T352][no err]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-a")),"1","[T352][x-a]")
	QUIT
	;
T353 ; READHDRS duplicate normal header last wins direct
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p15_t353.req"
	DO WRFILE(DEV,"X-A: 1"_$C(13,10)_"X-A: 2"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T353][no err]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-a")),"2","[T353][last wins]")
	QUIT
	;
T354 ; PARSEHDRS request line with OPTIONS star and headers
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p15_t354.req"
	DO WRFILE(DEV,"OPTIONS * HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T354][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("path")),"*","[T354][path]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","host")),"ex","[T354][host]")
	QUIT
	;
T355 ; PARSEHDRS request line with CONNECT authority form
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p15_t355.req"
	DO WRFILE(DEV,"CONNECT ex:443 HTTP/1.1"_$C(13,10)_"X-A: 1"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T355][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("path")),"ex:443","[T355][path]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-a")),"1","[T355][x-a]")
	QUIT
	;
T356 ; EXPECTDECIDE exact payload boundary with explicit expect lower
	NEW CONF,REQ,ERR
	SET REQ("hdr","expect")="100-continue"
	SET REQ("hdr","content-length")=5
	SET CONF("server","limits","maxBodyBytes")=5
	DO EQ^MIOTASSERT($$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR),1,"[T356][ok]")
	QUIT
	;
T357 ; EXPECTDECIDE payload too large by one
	NEW CONF,REQ,ERR
	SET REQ("hdr","expect")="100-continue"
	SET REQ("hdr","content-length")=6
	SET CONF("server","limits","maxBodyBytes")=5
	DO EQ^MIOTASSERT($$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR),0,"[T357][ok]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"payload_too_large","[T357][err]")
	QUIT
	;
T358 ; EXPECTDECIDE no content-length but expect still ok
	NEW CONF,REQ,ERR
	SET REQ("hdr","expect")="100-continue"
	DO EQ^MIOTASSERT($$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR),1,"[T358][ok]")
	QUIT
	;
T359 ; SEND100 repeated writes stable
	NEW I,DEV,OUT,OP
	FOR I=1:1:2 DO
	. SET OP="tmp/miohttp_p15_t359-"_I_".out"
	. OPEN OP:(newversion:stream:nowrap)
	. SET DEV=OP USE DEV
	. DO SEND100^MIOHTTP(.DEV)
	. CLOSE DEV USE $PRINCIPAL
	. DO READALL(OP,.OUT)
	. DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 100 Continue":1,1:0),1,"[T359]["_I_"][100]")
	QUIT
	;
T360 ; STREAMBEGIN GET 200 emits rid and chunked
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p15_t360.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid360",.CTX)
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-Request-Id: rid360":1,1:0),1,"[T360][rid]")
	DO EQ^MIOTASSERT($SELECT(OUT["Transfer-Encoding: chunked":1,1:0),1,"[T360][chunked]")
	QUIT
	;
T361 ; STREAMBEGIN HEAD 200 no body on write
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="HEAD"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p15_t361.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid361",.CTX)
	DO STREAMWRITE^MIOHTTP(.DEV,"abcdef")
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["abcdef":1,1:0),0,"[T361][no body]")
	QUIT
	;
T362 ; STREAMBEGIN explicit header override over default
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET CONF("server","http","defaultResponseHeaders","X-App")="default"
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("X-App")="explicit"
	SET OP="tmp/miohttp_p15_t362.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid362",.CTX)
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: explicit":1,1:0),1,"[T362][explicit]")
	QUIT
	;
T363 ; STREAMWRITE byte accounting across three writes
	NEW DEV,CONF,CTX,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ"),^TMP($J,"MIOHTTP","STREAM")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p15_t363.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid363",.CTX)
	DO STREAMWRITE^MIOHTTP(.DEV,"a")
	DO STREAMWRITE^MIOHTTP(.DEV,"bb")
	DO STREAMWRITE^MIOHTTP(.DEV,"ccc")
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($GET(^TMP($J,"MIOHTTP","STREAM","bytes"))>0,1,"[T363][bytes]")
	KILL ^TMP($J,"MIOHTTP","REQ"),^TMP($J,"MIOHTTP","STREAM")
	QUIT
	;
T364 ; STREAMEND final zero chunk present after writes
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p15_t364.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid364",.CTX)
	DO STREAMWRITE^MIOHTTP(.DEV,"ab")
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["0"_$C(13,10,13,10):1,1:0),1,"[T364][zero]")
	QUIT
	;
T365 ; SENDFILE explicit method GET with default headers
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p15_t365.txt"
	DO WRFILE(FP,"body365")
	SET CONF("server","http","defaultResponseHeaders","X-App")="mio"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p15_t365.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid365",.CTX,"GET"),1,"[T365][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: mio":1,1:0),1,"[T365][x-app]")
	DO EQ^MIOTASSERT($SELECT(OUT["body365":1,1:0),1,"[T365][body]")
	QUIT
	;
T366 ; SENDFILE explicit method HEAD with default headers
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p15_t366.txt"
	DO WRFILE(FP,"body366")
	SET CONF("server","http","defaultResponseHeaders","X-App")="mio"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p15_t366.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid366",.CTX,"HEAD"),1,"[T366][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: mio":1,1:0),1,"[T366][x-app]")
	DO EQ^MIOTASSERT($SELECT(OUT["body366":1,1:0),0,"[T366][no body]")
	QUIT
	;
T367 ; SENDFILE explicit header override over default
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p15_t367.txt"
	DO WRFILE(FP,"body367")
	SET CONF("server","http","defaultResponseHeaders","X-App")="default"
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("X-App")="explicit"
	SET OP="tmp/miohttp_p15_t367.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid367",.CTX,"GET"),1,"[T367][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: explicit":1,1:0),1,"[T367][explicit]")
	QUIT
	;
T368 ; READLINE eof after complete line
	NEW DEV,X,ERR
	SET DEV="tmp/miohttp_p15_t368.req"
	DO WRFILE(DEV,"one"_$C(13,10))
	DO OPENR(DEV)
	DO READLINE^MIOHTTP(DEV,1,.X,.ERR)
	DO EQ^MIOTASSERT(X,"one","[T368][one]")
	DO CLOSER(DEV)
	QUIT
	;
T369 ; READFIX exact full file then short read
	NEW DEV,X,ERR
	SET DEV="tmp/miohttp_p15_t369.req"
	DO WRFILE(DEV,"abcd")
	DO OPENR(DEV)
	DO READFIX^MIOHTTP(DEV,4,1,.X,.ERR)
	DO EQ^MIOTASSERT(X,"abcd","[T369][abcd]")
	KILL ERR
	DO READFIX^MIOHTTP(DEV,1,1,.X,.ERR)
	DO EQ^MIOTASSERT($GET(ERR("error"))'="",1,"[T369][some err]")
	DO CLOSER(DEV)
	QUIT
	;
T370 ; HTOK larger valid matrix
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("If-None-Match"),1,"[T370][if-none-match]")
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("X123"),1,"[T370][x123]")
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP("a_b-c.d"),1,"[T370][mixed]")
	QUIT
	;
T371 ; HVALOK larger valid matrix
	DO EQ^MIOTASSERT($$HVALOK^MIOHTTP("text/plain; charset=utf-8"),1,"[T371][ctype]")
	DO EQ^MIOTASSERT($$HVALOK^MIOHTTP("gzip, deflate, br"),1,"[T371][enc]")
	QUIT
	;
T372 ; LOW and TRIM combined stability
	DO EQ^MIOTASSERT($$LOW^MIOHTTP($$TRIM^MIOHTTP("  AbC  ")),"abc","[T372][combo]")
	QUIT
	;
T373 ; PARSEHDRS then EXPECTDECIDE normal flow
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","limits","maxBodyBytes")=10
	SET DEV="tmp/miohttp_p15_t373.req"
	DO WRFILE(DEV,"POST /exp HTTP/1.1"_$C(13,10)_"Expect: 100-continue"_$C(13,10)_"Content-Length: 5"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T373][hdrs]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR),1,"[T373][expect]")
	QUIT
	;
T374 ; PARSEHDRS then EXPECTDECIDE payload too large
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","limits","maxBodyBytes")=4
	SET DEV="tmp/miohttp_p15_t374.req"
	DO WRFILE(DEV,"POST /exp HTTP/1.1"_$C(13,10)_"Expect: 100-continue"_$C(13,10)_"Content-Length: 5"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T374][hdrs]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR),0,"[T374][expect]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"payload_too_large","[T374][err]")
	QUIT
	;
T375 ; SEND100 then STREAMBEGIN same device
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p15_t375.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO SEND100^MIOHTTP(.DEV)
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid375",.CTX)
	DO STREAMWRITE^MIOHTTP(.DEV,"ok")
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["100 Continue":1,1:0),1,"[T375][100]")
	DO EQ^MIOTASSERT($SELECT(OUT["Transfer-Encoding: chunked":1,1:0),1,"[T375][chunked]")
	DO EQ^MIOTASSERT($SELECT(OUT["2"_$C(13,10)_"ok":1,1:0),1,"[T375][chunk]")
	QUIT
T376 ; READCHUNKED three chunks joined
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p16_t376.req"
	DO WRFILE(DEV,"1"_$C(13,10)_"a"_$C(13,10)_"2"_$C(13,10)_"bc"_$C(13,10)_"3"_$C(13,10)_"def"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T376][no err]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"abcdef","[T376][body]")
	QUIT
	;
T377 ; READCHUNKED empty trailers after zero chunk
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p16_t377.req"
	DO WRFILE(DEV,"1"_$C(13,10)_"x"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T377][no err]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"x","[T377][body]")
	QUIT
	;
T378 ; READCHUNKED chunk extension with multiple attrs
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p16_t378.req"
	DO WRFILE(DEV,"2;a=1;b=2"_$C(13,10)_"ok"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T378][no err]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"ok","[T378][body]")
	QUIT
	;
T379 ; READCHUNKED bad mixed hex chars
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p16_t379.req"
	DO WRFILE(DEV,"1G"_$C(13,10)_"x"_$C(13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"bad_chunk_size","[T379][err]")
	QUIT
	;
T380 ; READCHUNKED missing zero chunk terminator
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p16_t380.req"
	DO WRFILE(DEV,"1"_$C(13,10)_"x"_$C(13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error"))'="",1,"[T380][some err]")
	QUIT
	;
T381 ; READCL zero length stable
	NEW CONF,REQ,ERR
	DO READCL^MIOHTTP("dummy",.CONF,.REQ,0,.ERR)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T381][no err]")
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"none","[T381][mode]")
	QUIT
	;
T382 ; READCL one byte scalar
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p16_t382.req"
	DO WRFILE(DEV,"z")
	DO OPENR(DEV)
	DO READCL^MIOHTTP(DEV,.CONF,.REQ,1,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T382][no err]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"z","[T382][body]")
	QUIT
	;
T383 ; BODYAPPEND scalar then BODYUP explicit
	NEW CONF,REQ,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=100
	DO BODYINIT^MIOHTTP(.REQ,.CONF,0)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"abc",.ERR)
	DO BODYUP^MIOHTTP(.REQ,.CONF)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T383][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body","len")),3,"[T383][len]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T384 ; BODYAPPEND global after upgrade stores chunks
	NEW CONF,REQ,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=2
	DO BODYINIT^MIOHTTP(.REQ,.CONF,0)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"ab",.ERR)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"cd",.ERR)
	DO EQ^MIOTASSERT($GET(REQ("body","n"))=2,1,"[T384][n]")
	DO EQ^MIOTASSERT($GET(REQ("body","len")),4,"[T384][len]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T385 ; BODYOPEN global empty then no next
	NEW REQ,CUR,CH
	SET REQ("body","mode")="global"
	SET REQ("body","ref")=$NAME(^TMP($J,"MIOHTTPP16","T385"))
	KILL ^TMP($J,"MIOHTTPP16","T385")
	SET REQ("body","n")=0
	SET REQ("body","len")=0
	DO BODYOPEN^MIOHTTP(.REQ,.CUR)
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH),0,"[T385][next]")
	KILL ^TMP($J,"MIOHTTPP16","T385")
	QUIT
	;
T386 ; STATUS4ERR short_read fallback
	NEW ERR
	SET ERR("error")="short_read"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),400,"[T386][400]")
	QUIT
	;
T387 ; STATUS4ERR bad transfer encoding order
	NEW ERR
	SET ERR("error")="bad_transfer_encoding_order"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),400,"[T387][400]")
	QUIT
	;
T388 ; STATUS4ERR duplicate transfer encoding
	NEW ERR
	SET ERR("error")="duplicate_transfer_encoding"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),400,"[T388][400]")
	QUIT
	;
T389 ; STATUSMSG additional known statuses
	DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(408),"Request Timeout","[T389][408]")
	DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(413),"Payload Too Large","[T389][413]")
	DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(431),"Request Header Fields Too Large","[T389][431]")
	QUIT
	;
T390 ; STATUSMSG unknown stays empty phrase path
	DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(299),"","[T390][299]")
	QUIT
	;
T391 ; PARSE then RESP text roundtrip path echo
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,HEAD
	SET DEV="tmp/miohttp_p16_t391.req"
	DO WRFILE(DEV,"GET /echo391 HTTP/1.1"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T391][parse]")
	DO CLOSER(DEV)
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p16_t391.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO RESP^MIOHTTP(.RDEV,.CONF,200,.HEAD,$GET(REQ("path")),"rid391")
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["/echo391":1,1:0),1,"[T391][body]")
	QUIT
	;
T392 ; PARSE then RESPJSON roundtrip method echo
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,OBJ
	SET DEV="tmp/miohttp_p16_t392.req"
	DO WRFILE(DEV,"POST /echo392 HTTP/1.1"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10)_"ok")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T392][parse]")
	DO CLOSER(DEV)
	SET OBJ("method")=$GET(REQ("method"))
	SET OBJ("body")=$GET(REQ("body"))
	SET OP="tmp/miohttp_p16_t392.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO RESPJSON^MIOHTTP(.RDEV,.CONF,200,.OBJ,"rid392")
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["""method"":""POST""":1,1:0),1,"[T392][method]")
	DO EQ^MIOTASSERT($SELECT(OUT["""body"":""ok""":1,1:0),1,"[T392][body]")
	QUIT
	;
T393 ; PARSE chunked then RESPJSONX body len echo
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,OBJ,CTX
	SET CONF("server","http","supportChunkedRequest")=1
	SET DEV="tmp/miohttp_p16_t393.req"
	DO WRFILE(DEV,"POST /c HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10,13,10)_"3"_$C(13,10)_"abc"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T393][parse]")
	DO CLOSER(DEV)
	SET OBJ("len")=$$BODYLEN^MIOHTTP(.REQ)
	SET OP="tmp/miohttp_p16_t393.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO RESPJSONX^MIOHTTP(.RDEV,.CONF,200,.OBJ,"rid393",.CTX)
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["""len"":3":1,1:0),1,"[T393][len]")
	QUIT
	;
T394 ; STREAM then READALL contains status and chunks
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p16_t394.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid394",.CTX)
	DO STREAMWRITE^MIOHTTP(.DEV,"xy")
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 200 OK":1,1:0),1,"[T394][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["2"_$C(13,10)_"xy":1,1:0),1,"[T394][chunk]")
	QUIT
	;
T395 ; SENDFILE then READALL contains status and content
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p16_t395.txt"
	DO WRFILE(FP,"txt395")
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p16_t395.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid395",.CTX,"GET"),1,"[T395][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 200 OK":1,1:0),1,"[T395][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["txt395":1,1:0),1,"[T395][body]")
	QUIT
	;
T396 ; HEXSTR2DEC lowercase long valid
	DO EQ^MIOTASSERT($$HEXSTR2DEC^MIOHTTP("ff"),255,"[T396][ff]")
	DO EQ^MIOTASSERT($$HEXSTR2DEC^MIOHTTP("10"),16,"[T396][10]")
	QUIT
	;
T397 ; HEX2DEC lowercase pair
	DO EQ^MIOTASSERT($$HEX2DEC^MIOHTTP("af"),175,"[T397][af]")
	QUIT
	;
T398 ; LOW repeated stable
	DO EQ^MIOTASSERT($$LOW^MIOHTTP("MiXeD"),"mixed","[T398][mixed]")
	DO EQ^MIOTASSERT($$LOW^MIOHTTP("UPPER"),"upper","[T398][upper]")
	QUIT
	;
T399 ; TRIM repeated stable
	DO EQ^MIOTASSERT($$TRIM^MIOHTTP(" x"),"x","[T399][left]")
	DO EQ^MIOTASSERT($$TRIM^MIOHTTP("x "),"x","[T399][right]")
	QUIT
	;
T400 ; mixed parsehdrs readbodyonly respjsonx full split roundtrip
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,OBJ,CTX
	SET DEV="tmp/miohttp_p16_t400.req"
	DO WRFILE(DEV,"POST /split400 HTTP/1.1"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10)_"ok")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T400][hdrs]")
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T400][body]")
	DO CLOSER(DEV)
	SET OBJ("path")=$GET(REQ("path"))
	SET OBJ("body")=$GET(REQ("body"))
	SET OP="tmp/miohttp_p16_t400.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO RESPJSONX^MIOHTTP(.RDEV,.CONF,200,.OBJ,"rid400",.CTX)
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["""path"":""\/split400""":1,1:0),1,"[T400][path]")
	DO EQ^MIOTASSERT($SELECT(OUT["""body"":""ok""":1,1:0),1,"[T400][body]")
	QUIT
T401 ; READHDRS host plus content-length direct
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p17_t401.req"
	DO WRFILE(DEV,"Host: ex"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T401][no err]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","host")),"ex","[T401][host]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","content-length")),"2","[T401][cl]")
	QUIT
	;
T402 ; READHDRS transfer-encoding identity direct
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p17_t402.req"
	DO WRFILE(DEV,"Transfer-Encoding: identity"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T402][no err]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","transfer-encoding")),"identity","[T402][te]")
	QUIT
	;
T403 ; PARSEHDRS preserves rawpath with query
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p17_t403.req"
	DO WRFILE(DEV,"GET /r?q=1 HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T403][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("rawpath")),"/r?q=1","[T403][rawpath]")
	QUIT
	;
T404 ; PARSEHDRS invalid request line only
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p17_t404.req"
	DO WRFILE(DEV,"BROKEN"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T404][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"bad_request_line","[T404][err]")
	QUIT
	;
T405 ; READBODYONLY with content-length after PARSEHDRS
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p17_t405.req"
	DO WRFILE(DEV,"POST /rb HTTP/1.1"_$C(13,10)_"Content-Length: 3"_$C(13,10,13,10)_"hey")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T405][hdrs]")
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T405][body]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"hey","[T405][body]")
	QUIT
	;
T406 ; READBODYONLY with no body headers remains none
	NEW CONF,REQ,ERR
	KILL CONF,REQ,ERR
	SET REQ("method")="GET"
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP("dummy",.CONF,.REQ,.ERR),1,"[T406][ok]")
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"none","[T406][mode]")
	QUIT
	;
T407 ; READBODYONLY with chunked request direct
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","http","supportChunkedRequest")=1
	SET DEV="tmp/miohttp_p17_t407.req"
	DO WRFILE(DEV,"2"_$C(13,10)_"ok"_$C(13,10)_"0"_$C(13,10,13,10))
	SET REQ("hdr","transfer-encoding")="chunked"
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T407][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"ok","[T407][body]")
	QUIT
	;
T408 ; BODYOPEN none mode then repeated BODYNEXT false
	NEW REQ,CUR,CH
	SET REQ("body","mode")="none"
	SET REQ("body","len")=0
	DO BODYOPEN^MIOHTTP(.REQ,.CUR)
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH),0,"[T408][next1]")
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH),0,"[T408][next2]")
	QUIT
	;
T409 ; BODYNEXT scalar second call false
	NEW REQ,CUR,CH
	SET REQ("body","mode")="scalar"
	SET REQ("body")="abc"
	SET REQ("body","len")=3
	DO BODYOPEN^MIOHTTP(.REQ,.CUR)
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH),1,"[T409][next1]")
	DO EQ^MIOTASSERT(CH,"abc","[T409][chunk]")
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH),0,"[T409][next2]")
	QUIT
	;
T410 ; BODYNEXT global exhausts correctly
	NEW REQ,CUR,CH
	SET REQ("body","mode")="global"
	SET REQ("body","ref")=$NAME(^TMP($J,"MIOHTTPP17","T410"))
	KILL ^TMP($J,"MIOHTTPP17","T410")
	SET ^TMP($J,"MIOHTTPP17","T410",1)="aa"
	SET ^TMP($J,"MIOHTTPP17","T410",2)="bb"
	SET REQ("body","n")=2
	SET REQ("body","len")=4
	DO BODYOPEN^MIOHTTP(.REQ,.CUR)
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH),1,"[T410][next1]")
	DO EQ^MIOTASSERT(CH,"aa","[T410][chunk1]")
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH),1,"[T410][next2]")
	DO EQ^MIOTASSERT(CH,"bb","[T410][chunk2]")
	DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH),0,"[T410][next3]")
	KILL ^TMP($J,"MIOHTTPP17","T410")
	QUIT
	;
T411 ; RESP 101 no body
	NEW DEV,CONF,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p17_t411.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,101,.HEAD,"abc","rid411")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 101 Switching Protocols":1,1:0),1,"[T411][status]")
	DO EQ^MIOTASSERT($SELECT(OUT[$C(13,10,13,10)_"abc":1,1:0),0,"[T411][no body]")
	QUIT
	;
T412 ; RESPJSON 304 no body
	NEW DEV,CONF,OUT,OP,OBJ
	SET OBJ("ok")=1
	SET OP="tmp/miohttp_p17_t412.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSON^MIOHTTP(.DEV,.CONF,304,.OBJ,"rid412")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT[$C(13,10,13,10)_"{":1,1:0),0,"[T412][no body]")
	QUIT
	;
T413 ; RESPX 304 updates ctx status
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p17_t413.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPX^MIOHTTP(.DEV,.CONF,304,.HEAD,"x","rid413",.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($GET(CTX("status")),304,"[T413][ctx]")
	QUIT
	;
T414 ; RESPJSONX 304 updates ctx status
	NEW DEV,CONF,CTX,OUT,OP,OBJ
	SET OBJ("ok")=1
	SET OP="tmp/miohttp_p17_t414.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,304,.OBJ,"rid414",.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO EQ^MIOTASSERT($GET(CTX("status")),304,"[T414][ctx]")
	QUIT
	;
T415 ; STREAMBEGIN 101 not chunked
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Upgrade")="websocket"
	SET OP="tmp/miohttp_p17_t415.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,101,.HEAD,"rid415",.CTX)
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Transfer-Encoding: chunked":1,1:0),0,"[T415][not chunked]")
	QUIT
	;
T416 ; STREAMBEGIN 200 then two empty writes only zero chunk
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p17_t416.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid416",.CTX)
	DO STREAMWRITE^MIOHTTP(.DEV,"")
	DO STREAMWRITE^MIOHTTP(.DEV,"")
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["0"_$C(13,10,13,10):1,1:0),1,"[T416][zero]")
	QUIT
	;
T417 ; SENDFILE with explicit extra header
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p17_t417.txt"
	DO WRFILE(FP,"body417")
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("X-Extra")="yes"
	SET OP="tmp/miohttp_p17_t417.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid417",.CTX,"GET"),1,"[T417][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-Extra: yes":1,1:0),1,"[T417][x-extra]")
	QUIT
	;
T418 ; SENDFILE with two default headers
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p17_t418.txt"
	DO WRFILE(FP,"body418")
	SET CONF("server","http","defaultResponseHeaders","X-A")="1"
	SET CONF("server","http","defaultResponseHeaders","X-B")="2"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p17_t418.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid418",.CTX,"GET"),1,"[T418][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-A: 1":1,1:0),1,"[T418][x-a]")
	DO EQ^MIOTASSERT($SELECT(OUT["X-B: 2":1,1:0),1,"[T418][x-b]")
	QUIT
	;
T419 ; HTOK empty false
	DO EQ^MIOTASSERT($$HTOK^MIOHTTP(""),0,"[T419][empty]")
	QUIT
	;
T420 ; HVALOK DEL false
	DO EQ^MIOTASSERT($$HVALOK^MIOHTTP("a"_$C(127)_"b"),0,"[T420][del]")
	QUIT
	;
T421 ; HEXVAL numeric chars
	DO EQ^MIOTASSERT($$HEXVAL^MIOHTTP("0"),0,"[T421][0]")
	DO EQ^MIOTASSERT($$HEXVAL^MIOHTTP("9"),9,"[T421][9]")
	QUIT
	;
T422 ; HEXVAL invalid punctuation
	DO EQ^MIOTASSERT($$HEXVAL^MIOHTTP("-"),-1,"[T422][-]")
	QUIT
	;
T423 ; URLDECQ empty input
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP(""),"","[T423][empty]")
	QUIT
	;
T424 ; PARSEQRY no question mark leaves empty query map
	NEW REQ
	DO PARSEQRY^MIOHTTP("/plain",.REQ)
	DO EQ^MIOTASSERT($DATA(REQ("query")),0,"[T424][no query]")
	QUIT
	;
T425 ; mixed parse resp sendfile sequence stable
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,HEAD,FP,CTX
	SET DEV="tmp/miohttp_p17_t425.req"
	DO WRFILE(DEV,"GET /seq425 HTTP/1.1"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T425][parse]")
	DO CLOSER(DEV)
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p17_t425a.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO RESP^MIOHTTP(.RDEV,.CONF,200,.HEAD,"ok","rid425a")
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["ok":1,1:0),1,"[T425][resp]")
	SET FP="tmp/miohttp_p17_t425.txt"
	DO WRFILE(FP,"file425")
	SET OP="tmp/miohttp_p17_t425b.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.RDEV,.CONF,FP,.HEAD,"rid425b",.CTX,"GET"),1,"[T425][sendfile]")
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["file425":1,1:0),1,"[T425][file]")
	QUIT
T426 ; READCHUNKED invalid size with leading space
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p18_t426.req"
	DO WRFILE(DEV," 1"_$C(13,10)_"a"_$C(13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"bad_chunk_size","[T426][err]")
	QUIT
	;
T427 ; READCHUNKED invalid size with trailing space
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p18_t427.req"
	DO WRFILE(DEV,"1 "_$C(13,10)_"a"_$C(13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"bad_chunk_size","[T427][err]")
	QUIT
	;
T428 ; READCHUNKED invalid empty extension delimiter
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p18_t428.req"
	DO WRFILE(DEV,";"_$C(13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"bad_chunk_size","[T428][err]")
	QUIT
	;
T429 ; READCHUNKED size zero with extension valid
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p18_t429.req"
	DO WRFILE(DEV,"0;done=yes"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T429][no err]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"","[T429][body]")
	QUIT
	;
T430 ; READCHUNKED two chunks with trailer and blank line
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p18_t430.req"
	DO WRFILE(DEV,"1"_$C(13,10)_"a"_$C(13,10)_"1"_$C(13,10)_"b"_$C(13,10)_"0"_$C(13,10)_"X-T: ok"_$C(13,10)_$C(13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T430][no err]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"ab","[T430][body]")
	QUIT
	;
T431 ; READCHUNKED global threshold exact stays scalar
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","limits","maxBodyScalarBytes")=3
	SET DEV="tmp/miohttp_p18_t431.req"
	DO WRFILE(DEV,"1"_$C(13,10)_"a"_$C(13,10)_"2"_$C(13,10)_"bc"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"scalar","[T431][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"abc","[T431][body]")
	QUIT
	;
T432 ; READCHUNKED global threshold plus one goes global
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","limits","maxBodyScalarBytes")=3
	SET DEV="tmp/miohttp_p18_t432.req"
	DO WRFILE(DEV,"2"_$C(13,10)_"ab"_$C(13,10)_"2"_$C(13,10)_"cd"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READCHUNKED^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T432][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body","len")),4,"[T432][len]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T433 ; BODYAPPEND scalar many small appends
	NEW CONF,REQ,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=10
	DO BODYINIT^MIOHTTP(.REQ,.CONF,0)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"a",.ERR)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"b",.ERR)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"c",.ERR)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"scalar","[T433][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"abc","[T433][body]")
	QUIT
	;
T434 ; BODYAPPEND empty then nonempty then empty
	NEW CONF,REQ,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=10
	DO BODYINIT^MIOHTTP(.REQ,.CONF,0)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"",.ERR)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"ab",.ERR)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"",.ERR)
	DO EQ^MIOTASSERT($GET(REQ("body")),"ab","[T434][body]")
	DO EQ^MIOTASSERT($GET(REQ("body","len")),2,"[T434][len]")
	QUIT
	;
T435 ; BODYUP from empty scalar to global
	NEW CONF,REQ
	SET CONF("server","limits","maxBodyScalarBytes")=1
	SET REQ("body")=""
	SET REQ("body","len")=0
	DO BODYUP^MIOHTTP(.REQ,.CONF)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T435][mode]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T436 ; BODYFREE global twice harmless
	NEW REQ
	SET REQ("body","mode")="global"
	SET REQ("body","ref")=$NAME(^TMP($J,"MIOHTTPP18","T436"))
	KILL ^TMP($J,"MIOHTTPP18","T436")
	SET ^TMP($J,"MIOHTTPP18","T436",1)="ab"
	SET REQ("body","n")=1
	SET REQ("body","len")=2
	DO BODYFREE^MIOHTTP(.REQ)
	DO BODYFREE^MIOHTTP(.REQ)
	DO EQ^MIOTASSERT($DATA(^TMP($J,"MIOHTTPP18","T436")),0,"[T436][freed]")
	QUIT
	;
T437 ; PARSEHDRS expect continue normal
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p18_t437.req"
	DO WRFILE(DEV,"POST /exp HTTP/1.1"_$C(13,10)_"Expect: 100-continue"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T437][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("hdr","expect")),"100-continue","[T437][expect]")
	QUIT
	;
T438 ; PARSEHDRS expect mixed case preserved
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p18_t438.req"
	DO WRFILE(DEV,"POST /exp HTTP/1.1"_$C(13,10)_"Expect: 100-ConTinue"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T438][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("hdr","expect")),"100-ConTinue","[T438][expect]")
	QUIT
	;
T439 ; PARSEHDRS then EXPECTDECIDE then SEND100 flow
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV
	SET CONF("server","limits","maxBodyBytes")=3
	SET DEV="tmp/miohttp_p18_t439.req"
	DO WRFILE(DEV,"POST /flow HTTP/1.1"_$C(13,10)_"Expect: 100-continue"_$C(13,10)_"Content-Length: 3"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T439][hdrs]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR),1,"[T439][expect]")
	SET OP="tmp/miohttp_p18_t439.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO SEND100^MIOHTTP(.RDEV)
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["100 Continue":1,1:0),1,"[T439][100]")
	QUIT
	;
T440 ; PARSEHDRS then EXPECTDECIDE deny no SEND100
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","limits","maxBodyBytes")=2
	SET DEV="tmp/miohttp_p18_t440.req"
	DO WRFILE(DEV,"POST /flow HTTP/1.1"_$C(13,10)_"Expect: 100-continue"_$C(13,10)_"Content-Length: 3"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T440][hdrs]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR),0,"[T440][expect]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"payload_too_large","[T440][err]")
	QUIT
	;
T441 ; RESP repeated body suppression for HEAD
	NEW I,DEV,CONF,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="HEAD"
	SET HEAD("Content-Type")="text/plain"
	FOR I=1:1:2 DO
	. SET OP="tmp/miohttp_p18_t441-"_I_".out"
	. OPEN OP:(newversion:stream:nowrap)
	. SET DEV=OP USE DEV
	. DO RESP^MIOHTTP(.DEV,.CONF,200,.HEAD,"abc","rid441-"_I)
	. CLOSE DEV USE $PRINCIPAL
	. DO READALL(OP,.OUT)
	. DO EQ^MIOTASSERT($SELECT(OUT[$C(13,10,13,10)_"abc":1,1:0),0,"[T441]["_I_"][no body]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T442 ; RESPJSON repeated body suppression for HEAD
	NEW I,DEV,CONF,OUT,OP,OBJ
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="HEAD"
	SET OBJ("ok")=1
	FOR I=1:1:2 DO
	. SET OP="tmp/miohttp_p18_t442-"_I_".out"
	. OPEN OP:(newversion:stream:nowrap)
	. SET DEV=OP USE DEV
	. DO RESPJSON^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid442-"_I)
	. CLOSE DEV USE $PRINCIPAL
	. DO READALL(OP,.OUT)
	. DO EQ^MIOTASSERT($SELECT(OUT[$C(13,10,13,10)_"{":1,1:0),0,"[T442]["_I_"][no body]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T443 ; STREAM repeated with same payload stable
	NEW I,DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET HEAD("Content-Type")="text/plain"
	FOR I=1:1:2 DO
	. SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	. SET OP="tmp/miohttp_p18_t443-"_I_".out"
	. OPEN OP:(newversion:stream:nowrap)
	. SET DEV=OP USE DEV
	. DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid443-"_I,.CTX)
	. DO STREAMWRITE^MIOHTTP(.DEV,"ok")
	. DO STREAMEND^MIOHTTP(.DEV)
	. CLOSE DEV USE $PRINCIPAL
	. DO READALL(OP,.OUT)
	. DO EQ^MIOTASSERT($SELECT(OUT["2"_$C(13,10)_"ok":1,1:0),1,"[T443]["_I_"][chunk]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T444 ; STREAM 204 repeated no chunked
	NEW I,DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET HEAD("Content-Type")="text/plain"
	FOR I=1:1:2 DO
	. SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	. SET OP="tmp/miohttp_p18_t444-"_I_".out"
	. OPEN OP:(newversion:stream:nowrap)
	. SET DEV=OP USE DEV
	. DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,204,.HEAD,"rid444-"_I,.CTX)
	. DO STREAMEND^MIOHTTP(.DEV)
	. CLOSE DEV USE $PRINCIPAL
	. DO READALL(OP,.OUT)
	. DO EQ^MIOTASSERT($SELECT(OUT["Transfer-Encoding: chunked":1,1:0),0,"[T444]["_I_"][not chunked]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T445 ; SENDFILE repeated explicit header override stable
	NEW I,DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p18_t445.txt"
	DO WRFILE(FP,"file445")
	SET CONF("server","http","defaultResponseHeaders","X-App")="default"
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("X-App")="explicit"
	FOR I=1:1:2 DO
	. SET OP="tmp/miohttp_p18_t445-"_I_".out"
	. OPEN OP:(newversion:stream:nowrap)
	. SET DEV=OP USE DEV
	. DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid445-"_I,.CTX,"GET"),1,"[T445]["_I_"][ok]")
	. CLOSE DEV USE $PRINCIPAL
	. DO READALL(OP,.OUT)
	. DO EQ^MIOTASSERT($SELECT(OUT["X-App: explicit":1,1:0),1,"[T445]["_I_"][explicit]")
	QUIT
	;
T446 ; STATUS4ERR repeated bad_chunk_size stable
	NEW I,ERR
	FOR I=1:1:3 DO
	. SET ERR("error")="bad_chunk_size"
	. DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),400,"[T446]["_I_"][400]")
	QUIT
	;
T447 ; STATUSMSG repeated 200 stable
	NEW I
	FOR I=1:1:3 DO
	. DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(200),"OK","[T447]["_I_"][ok]")
	QUIT
	;
T448 ; PARSE then BODY iterator on global body repeated
	NEW I,CONF,REQ,ERR,DEV,CUR,CH
	SET CONF("server","limits","maxBodyScalarBytes")=2
	FOR I=1:1:2 DO
	. SET DEV="tmp/miohttp_p18_t448-"_I_".req"
	. DO WRFILE(DEV,"POST /g HTTP/1.1"_$C(13,10)_"Content-Length: 4"_$C(13,10,13,10)_"abcd")
	. KILL REQ,ERR
	. DO OPENR(DEV)
	. DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T448]["_I_"][parse]")
	. DO CLOSER(DEV)
	. DO BODYOPEN^MIOHTTP(.REQ,.CUR)
	. DO EQ^MIOTASSERT($$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH),1,"[T448]["_I_"][next]")
	. DO EQ^MIOTASSERT(CH'="",1,"[T448]["_I_"][chunk]")
	. DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T449 ; PARSEHDRS READBODYONLY RESP text split flow repeated
	NEW I,CONF,REQ,ERR,DEV,OP,OUT,RDEV,HEAD
	FOR I=1:1:2 DO
	. SET DEV="tmp/miohttp_p18_t449-"_I_".req"
	. DO WRFILE(DEV,"POST /s HTTP/1.1"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10)_"ok")
	. KILL REQ,ERR
	. DO OPENR(DEV)
	. DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T449]["_I_"][hdrs]")
	. DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T449]["_I_"][body]")
	. DO CLOSER(DEV)
	. SET HEAD("Content-Type")="text/plain"
	. SET OP="tmp/miohttp_p18_t449-"_I_".out"
	. OPEN OP:(newversion:stream:nowrap)
	. SET RDEV=OP USE RDEV
	. DO RESP^MIOHTTP(.RDEV,.CONF,200,.HEAD,$GET(REQ("body")),"rid449-"_I)
	. CLOSE RDEV USE $PRINCIPAL
	. DO READALL(OP,.OUT)
	. DO EQ^MIOTASSERT($SELECT(OUT["ok":1,1:0),1,"[T449]["_I_"][resp]")
	QUIT
	;
T450 ; mixed chunk parse send100 stream flow
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,HEAD,CTX
	SET CONF("server","http","supportChunkedRequest")=1
	SET DEV="tmp/miohttp_p18_t450.req"
	DO WRFILE(DEV,"POST /flow450 HTTP/1.1"_$C(13,10)_"Expect: 100-continue"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10,13,10)_"2"_$C(13,10)_"ok"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T450][hdrs]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR),1,"[T450][expect]")
	SET OP="tmp/miohttp_p18_t450.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO SEND100^MIOHTTP(.RDEV)
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	DO STREAMBEGIN^MIOHTTP(.RDEV,.CONF,200,.HEAD,"rid450",.CTX)
	DO STREAMWRITE^MIOHTTP(.RDEV,"ok")
	DO STREAMEND^MIOHTTP(.RDEV)
	CLOSE RDEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["100 Continue":1,1:0),1,"[T450][100]")
	DO EQ^MIOTASSERT($SELECT(OUT["2"_$C(13,10)_"ok":1,1:0),1,"[T450][chunk]")
	QUIT
T451 ; READLINE three sequential lines
	NEW DEV,X,ERR
	SET DEV="tmp/miohttp_p19_t451.req"
	DO WRFILE(DEV,"one"_$C(13,10)_"two"_$C(13,10)_"three"_$C(13,10))
	DO OPENR(DEV)
	DO READLINE^MIOHTTP(DEV,1,.X,.ERR)
	DO EQ^MIOTASSERT(X,"one","[T451][one]")
	DO READLINE^MIOHTTP(DEV,1,.X,.ERR)
	DO EQ^MIOTASSERT(X,"two","[T451][two]")
	DO READLINE^MIOHTTP(DEV,1,.X,.ERR)
	DO EQ^MIOTASSERT(X,"three","[T451][three]")
	DO CLOSER(DEV)
	QUIT
	;
T452 ; READLINE blank blank text
	NEW DEV,X,ERR
	SET DEV="tmp/miohttp_p19_t452.req"
	DO WRFILE(DEV,$C(13,10)_$C(13,10)_"x"_$C(13,10))
	DO OPENR(DEV)
	DO READLINE^MIOHTTP(DEV,1,.X,.ERR)
	DO EQ^MIOTASSERT(X,"","[T452][blank1]")
	DO READLINE^MIOHTTP(DEV,1,.X,.ERR)
	DO EQ^MIOTASSERT(X,"","[T452][blank2]")
	DO READLINE^MIOHTTP(DEV,1,.X,.ERR)
	DO EQ^MIOTASSERT(X,"x","[T452][x]")
	DO CLOSER(DEV)
	QUIT
	;
T453 ; READFIX split exact into 1 1 1
	NEW DEV,X,ERR
	SET DEV="tmp/miohttp_p19_t453.req"
	DO WRFILE(DEV,"abc")
	DO OPENR(DEV)
	DO READFIX^MIOHTTP(DEV,1,1,.X,.ERR)
	DO EQ^MIOTASSERT(X,"a","[T453][a]")
	DO READFIX^MIOHTTP(DEV,1,1,.X,.ERR)
	DO EQ^MIOTASSERT(X,"b","[T453][b]")
	DO READFIX^MIOHTTP(DEV,1,1,.X,.ERR)
	DO EQ^MIOTASSERT(X,"c","[T453][c]")
	DO CLOSER(DEV)
	QUIT
	;
T454 ; READFIX split exact into 2 then 2
	NEW DEV,X,ERR
	SET DEV="tmp/miohttp_p19_t454.req"
	DO WRFILE(DEV,"abcd")
	DO OPENR(DEV)
	DO READFIX^MIOHTTP(DEV,2,1,.X,.ERR)
	DO EQ^MIOTASSERT(X,"ab","[T454][ab]")
	DO READFIX^MIOHTTP(DEV,2,1,.X,.ERR)
	DO EQ^MIOTASSERT(X,"cd","[T454][cd]")
	DO CLOSER(DEV)
	QUIT
	;
T455 ; READFIX empty file immediate short path
	NEW DEV,X,ERR
	SET DEV="tmp/miohttp_p19_t455.req"
	DO WRFILE(DEV,"")
	DO OPENR(DEV)
	DO READFIX^MIOHTTP(DEV,1,1,.X,.ERR)
	DO EQ^MIOTASSERT($GET(ERR("error"))'="",1,"[T455][some err]")
	DO CLOSER(DEV)
	QUIT
	;
T456 ; READHDRS maxHeaderCount exact two
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","limits","maxHeaderCount")=2
	SET DEV="tmp/miohttp_p19_t456.req"
	DO WRFILE(DEV,"X-A: 1"_$C(13,10)_"X-B: 2"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T456][no err]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-a")),"1","[T456][x-a]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-b")),"2","[T456][x-b]")
	QUIT
	;
T457 ; READHDRS maxHeaderLineBytes over by one fails
	NEW CONF,REQ,ERR,DEV,LINE
	SET LINE="X-Long: 12"
	SET CONF("server","limits","maxHeaderLineBytes")=$L(LINE)-1
	SET DEV="tmp/miohttp_p19_t457.req"
	DO WRFILE(DEV,LINE_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"header_line_too_large","[T457][err]")
	QUIT
	;
T458 ; READHDRS maxHeaderBytes over by one fails
	NEW CONF,REQ,ERR,DEV,LINE
	SET LINE="X-A: 1"
	SET CONF("server","limits","maxHeaderBytes")=$L(LINE)+1
	SET DEV="tmp/miohttp_p19_t458.req"
	DO WRFILE(DEV,LINE_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"headers_too_large","[T458][err]")
	QUIT
	;
T459 ; PARSEHDRS bad header line after valid one
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p19_t459.req"
	DO WRFILE(DEV,"GET /x HTTP/1.1"_$C(13,10)_"X-A: 1"_$C(13,10)_"Broken"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T459][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"bad_header_line","[T459][err]")
	QUIT
	;
T460 ; PARSEHDRS duplicate host direct
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p19_t460.req"
	DO WRFILE(DEV,"GET /x HTTP/1.1"_$C(13,10)_"Host: a"_$C(13,10)_"Host: b"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T460][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"duplicate_host","[T460][err]")
	QUIT
	;
T461 ; PARSEHDRS duplicate content-length direct
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p19_t461.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Content-Length: 1"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T461][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"duplicate_content_length","[T461][err]")
	QUIT
	;
T462 ; PARSEHDRS duplicate transfer-encoding direct
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p19_t462.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10)_"Transfer-Encoding: identity"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T462][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"duplicate_transfer_encoding","[T462][err]")
	QUIT
	;
T463 ; PARSE invalid header value end-to-end again
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p19_t463.req"
	DO WRFILE(DEV,"GET /x HTTP/1.1"_$C(13,10)_"X-A: a"_$C(1)_"b"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T463][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"invalid_header_value","[T463][err]")
	QUIT
	;
T464 ; PARSE invalid header folding end-to-end again
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p19_t464.req"
	DO WRFILE(DEV,"GET /x HTTP/1.1"_$C(13,10)_"X-A: 1"_$C(13,10)_" 2"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T464][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"header_folding_rejected","[T464][err]")
	QUIT
	;
T465 ; RESP default plus two explicit headers
	NEW DEV,CONF,OUT,OP,HEAD
	SET CONF("server","http","defaultResponseHeaders","X-App")="mio"
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("X-A")="1"
	SET HEAD("X-B")="2"
	SET OP="tmp/miohttp_p19_t465.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,200,.HEAD,"ok","rid465")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: mio":1,1:0),1,"[T465][x-app]")
	DO EQ^MIOTASSERT($SELECT(OUT["X-A: 1":1,1:0),1,"[T465][x-a]")
	DO EQ^MIOTASSERT($SELECT(OUT["X-B: 2":1,1:0),1,"[T465][x-b]")
	QUIT
	;
T466 ; RESPJSON default plus custom explicit ctype path
	NEW DEV,CONF,OUT,OP,OBJ
	SET CONF("server","http","defaultResponseHeaders","X-App")="mio"
	SET OBJ("ok")=1
	SET OP="tmp/miohttp_p19_t466.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSON^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid466")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Type: application/json":1,1:0),1,"[T466][ctype]")
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: mio":1,1:0),1,"[T466][x-app]")
	QUIT
	;
T467 ; STREAMBEGIN default plus two explicit headers
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET CONF("server","http","defaultResponseHeaders","X-App")="mio"
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("X-A")="1"
	SET HEAD("X-B")="2"
	SET OP="tmp/miohttp_p19_t467.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid467",.CTX)
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: mio":1,1:0),1,"[T467][x-app]")
	DO EQ^MIOTASSERT($SELECT(OUT["X-A: 1":1,1:0),1,"[T467][x-a]")
	DO EQ^MIOTASSERT($SELECT(OUT["X-B: 2":1,1:0),1,"[T467][x-b]")
	QUIT
	;
T468 ; STREAM header override repeated
	NEW I,DEV,CONF,CTX,OUT,OP,HEAD
	SET CONF("server","http","defaultResponseHeaders","X-App")="default"
	FOR I=1:1:2 DO
	. KILL ^TMP($J,"MIOHTTP","REQ")
	. SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	. KILL HEAD
	. SET HEAD("Content-Type")="text/plain"
	. SET HEAD("X-App")="explicit"
	. SET OP="tmp/miohttp_p19_t468-"_I_".out"
	. OPEN OP:(newversion:stream:nowrap)
	. SET DEV=OP USE DEV
	. DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid468-"_I,.CTX)
	. DO STREAMEND^MIOHTTP(.DEV)
	. CLOSE DEV USE $PRINCIPAL
	. DO READALL(OP,.OUT)
	. DO EQ^MIOTASSERT($SELECT(OUT["X-App: explicit":1,1:0),1,"[T468]["_I_"][explicit]")
	KILL ^TMP($J,"MIOHTTP","REQ")
	QUIT
	;
T469 ; READBODYONLY CL zero after parsehdrs
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p19_t469.req"
	DO WRFILE(DEV,"POST /z HTTP/1.1"_$C(13,10)_"Content-Length: 0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T469][hdrs]")
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T469][body]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"none","[T469][mode]")
	QUIT
	;
T470 ; READBODYONLY CL too large after parsehdrs
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","limits","maxBodyBytes")=1
	SET DEV="tmp/miohttp_p19_t470.req"
	DO WRFILE(DEV,"POST /z HTTP/1.1"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10)_"ok")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T470][hdrs]")
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T470][body]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"payload_too_large","[T470][err]")
	QUIT
	;
T471 ; READBODYONLY chunked disabled after parsehdrs
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","http","supportChunkedRequest")=0
	SET DEV="tmp/miohttp_p19_t471.req"
	DO WRFILE(DEV,"POST /z HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10,13,10)_"2"_$C(13,10)_"ok"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T471][hdrs]")
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T471][body]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"chunked_not_supported","[T471][err]")
	QUIT
	;
T472 ; STATUS4ERR read timeout again
	NEW ERR
	SET ERR("error")="read_timeout"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),408,"[T472][408]")
	QUIT
	;
T473 ; STATUS4ERR headers too large again
	NEW ERR
	SET ERR("error")="headers_too_large"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),431,"[T473][431]")
	QUIT
	;
T474 ; STATUSMSG 501 and 503
	DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(501),"Not Implemented","[T474][501]")
	DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(503),"Service Unavailable","[T474][503]")
	QUIT
	;
T475 ; mixed parsehdrs expect send100 readbody stream sequence
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,HEAD,CTX
	SET CONF("server","limits","maxBodyBytes")=2
	SET DEV="tmp/miohttp_p19_t475.req"
	DO WRFILE(DEV,"POST /m HTTP/1.1"_$C(13,10)_"Expect: 100-continue"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10)_"ok")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T475][hdrs]")
	DO EQ^MIOTASSERT($$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR),1,"[T475][expect]")
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T475][body]")
	DO CLOSER(DEV)
	SET OP="tmp/miohttp_p19_t475.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO SEND100^MIOHTTP(.RDEV)
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	DO STREAMBEGIN^MIOHTTP(.RDEV,.CONF,200,.HEAD,"rid475",.CTX)
	DO STREAMWRITE^MIOHTTP(.RDEV,$GET(REQ("body")))
	DO STREAMEND^MIOHTTP(.RDEV)
	CLOSE RDEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["2"_$C(13,10)_"ok":1,1:0),1,"[T475][chunk]")
	QUIT
T476 ; PARSEREQLINE encoded query values
	NEW REQ,ERR
	DO PARSEREQLINE^MIOHTTP("GET /x?a=%2F&b=hello+world HTTP/1.1",.REQ,.ERR)
	DO EQ^MIOTASSERT($GET(REQ("path")),"/x","[T476][path]")
	DO EQ^MIOTASSERT($GET(REQ("query","a")),"/","[T476][a]")
	DO EQ^MIOTASSERT($GET(REQ("query","b")),"hello world","[T476][b]")
	QUIT
	;
T477 ; PARSEREQLINE repeated query key last wins
	NEW REQ,ERR
	DO PARSEREQLINE^MIOHTTP("GET /x?a=1&a=2 HTTP/1.1",.REQ,.ERR)
	DO EQ^MIOTASSERT($GET(REQ("query","a")),"2","[T477][a]")
	QUIT
	;
T478 ; PARSEREQLINE empty query pair
	NEW REQ,ERR
	DO PARSEREQLINE^MIOHTTP("GET /x?a=&b=2 HTTP/1.1",.REQ,.ERR)
	DO EQ^MIOTASSERT($GET(REQ("query","a")),"","[T478][a]")
	DO EQ^MIOTASSERT($GET(REQ("query","b")),"2","[T478][b]")
	QUIT
	;
T479 ; PARSEREQLINE question mark only
	NEW REQ,ERR
	DO PARSEREQLINE^MIOHTTP("GET /x? HTTP/1.1",.REQ,.ERR)
	DO EQ^MIOTASSERT($GET(REQ("path")),"/x","[T479][path]")
	QUIT
	;
T480 ; PARSE TE chunked with allowTECL and CL zero
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","http","allowTECL")=1
	SET CONF("server","http","supportChunkedRequest")=1
	SET DEV="tmp/miohttp_p20_t480.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10)_"Content-Length: 0"_$C(13,10,13,10)_"2"_$C(13,10)_"ok"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T480][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"ok","[T480][body]")
	QUIT
	;
T481 ; PARSE TE identity with no CL gives no body
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p20_t481.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Transfer-Encoding: identity"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T481][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"none","[T481][mode]")
	QUIT
	;
T482 ; PARSE TE chunked only with empty body
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","http","supportChunkedRequest")=1
	SET DEV="tmp/miohttp_p20_t482.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10,13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T482][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($$BODYLEN^MIOHTTP(.REQ),0,"[T482][len]")
	QUIT
	;
T483 ; PARSE unsupported TE compress, chunked
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p20_t483.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Transfer-Encoding: compress, chunked"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T483][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"unsupported_transfer_encoding","[T483][err]")
	QUIT
	;
T484 ; PARSE TE chunked not last in longer list
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p20_t484.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Transfer-Encoding: identity, chunked, identity"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T484][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"bad_transfer_encoding_order","[T484][err]")
	QUIT
	;
T485 ; BODYAPPEND threshold boundary one below stays scalar
	NEW CONF,REQ,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=5
	DO BODYINIT^MIOHTTP(.REQ,.CONF,0)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"ab",.ERR)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"cd",.ERR)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"scalar","[T485][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"abcd","[T485][body]")
	QUIT
	;
T486 ; BODYAPPEND threshold exact stays scalar
	NEW CONF,REQ,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=4
	DO BODYINIT^MIOHTTP(.REQ,.CONF,0)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"ab",.ERR)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"cd",.ERR)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"scalar","[T486][mode]")
	QUIT
	;
T487 ; BODYAPPEND threshold plus one upgrades
	NEW CONF,REQ,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=4
	DO BODYINIT^MIOHTTP(.REQ,.CONF,0)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"ab",.ERR)
	DO BODYAPPEND^MIOHTTP(.REQ,.CONF,"cde",.ERR)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T487][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body","len")),5,"[T487][len]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T488 ; READCL above maxBodyBytes denied
	NEW CONF,REQ,ERR
	SET CONF("server","limits","maxBodyBytes")=3
	DO READCL^MIOHTTP("dummy",.CONF,.REQ,4,.ERR)
	DO EQ^MIOTASSERT($GET(ERR("error")),"payload_too_large","[T488][err]")
	QUIT
	;
T489 ; READCL exact maxBodyBytes allowed
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","limits","maxBodyBytes")=4
	SET DEV="tmp/miohttp_p20_t489.req"
	DO WRFILE(DEV,"abcd")
	DO OPENR(DEV)
	DO READCL^MIOHTTP(DEV,.CONF,.REQ,4,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"","[T489][no err]")
	DO EQ^MIOTASSERT($GET(REQ("body")),"abcd","[T489][body]")
	QUIT
	;
T490 ; PARSE simple GET then RESPX text
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,HEAD,CTX
	SET DEV="tmp/miohttp_p20_t490.req"
	DO WRFILE(DEV,"GET /rx HTTP/1.1"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T490][parse]")
	DO CLOSER(DEV)
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p20_t490.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO RESPX^MIOHTTP(.RDEV,.CONF,200,.HEAD,$GET(REQ("path")),"rid490",.CTX)
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["/rx":1,1:0),1,"[T490][body]")
	QUIT
	;
T491 ; PARSE simple GET then RESPJSONX path
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,OBJ,CTX
	SET DEV="tmp/miohttp_p20_t491.req"
	DO WRFILE(DEV,"GET /jsonx HTTP/1.1"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T491][parse]")
	DO CLOSER(DEV)
	SET OBJ("path")=$GET(REQ("path"))
	SET OP="tmp/miohttp_p20_t491.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO RESPJSONX^MIOHTTP(.RDEV,.CONF,200,.OBJ,"rid491",.CTX)
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["""path"":""\/jsonx""":1,1:0),1,"[T491][json]")
	QUIT
	;
T492 ; PARSE POST body then STREAM response echoes size
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,HEAD,CTX
	SET DEV="tmp/miohttp_p20_t492.req"
	DO WRFILE(DEV,"POST /s HTTP/1.1"_$C(13,10)_"Content-Length: 3"_$C(13,10,13,10)_"hey")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T492][parse]")
	DO CLOSER(DEV)
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p20_t492.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	DO STREAMBEGIN^MIOHTTP(.RDEV,.CONF,200,.HEAD,"rid492",.CTX)
	DO STREAMWRITE^MIOHTTP(.RDEV,$J($$BODYLEN^MIOHTTP(.REQ),1,0))
	DO STREAMEND^MIOHTTP(.RDEV)
	CLOSE RDEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["1"_$C(13,10)_"3":1,1:0),1,"[T492][chunk]")
	QUIT
	;
T493 ; READHDRS preserves tab in value
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p20_t493.req"
	DO WRFILE(DEV,"X-A: a"_$C(9)_"b"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO READHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("hdr","x-a")),"a"_$C(9)_"b","[T493][value]")
	QUIT
	;
T494 ; PARSEHDRS path only HTTP/1.0
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p20_t494.req"
	DO WRFILE(DEV,"GET /old HTTP/1.0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T494][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("httpver")),"HTTP/1.0","[T494][ver]")
	QUIT
	;
T495 ; PARSE full request with host and empty body cl0
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p20_t495.req"
	DO WRFILE(DEV,"POST /e HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10)_"Content-Length: 0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T495][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("hdr","host")),"ex","[T495][host]")
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"none","[T495][mode]")
	QUIT
	;
T496 ; SENDFILE then RESP on separate device sequence
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP,RDEV
	SET FP="tmp/miohttp_p20_t496.txt"
	DO WRFILE(FP,"f496")
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p20_t496a.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid496a",.CTX,"GET"),1,"[T496][sendfile]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["f496":1,1:0),1,"[T496][file]")
	SET OP="tmp/miohttp_p20_t496b.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO RESP^MIOHTTP(.RDEV,.CONF,200,.HEAD,"ok","rid496b")
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["ok":1,1:0),1,"[T496][resp]")
	QUIT
	;
T497 ; STATUSMSG 405 and 500
	DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(405),"Method Not Allowed","[T497][405]")
	DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(500),"Internal Server Error","[T497][500]")
	QUIT
	;
T498 ; STATUS4ERR bad_header_line and invalid_content_length
	NEW ERR
	SET ERR("error")="bad_header_line"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),400,"[T498][bad header]")
	SET ERR("error")="invalid_content_length"
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),400,"[T498][bad cl]")
	QUIT
	;
T499 ; URLDECQ preserved invalid escape in middle
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("a%XZb"),"a%XZb","[T499][decode]")
	QUIT
	;
T500 ; mixed parse split response file flow
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,HEAD,OBJ,CTX,FP
	SET DEV="tmp/miohttp_p20_t500.req"
	DO WRFILE(DEV,"POST /five HTTP/1.1"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10)_"ok")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T500][hdrs]")
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T500][body]")
	DO CLOSER(DEV)
	SET OBJ("body")=$GET(REQ("body"))
	SET OP="tmp/miohttp_p20_t500a.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO RESPJSONX^MIOHTTP(.RDEV,.CONF,200,.OBJ,"rid500a",.CTX)
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["""body"":""ok""":1,1:0),1,"[T500][json]")
	SET FP="tmp/miohttp_p20_t500.txt"
	DO WRFILE(FP,"done500")
	SET OP="tmp/miohttp_p20_t500b.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	SET HEAD("Content-Type")="text/plain"
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.RDEV,.CONF,FP,.HEAD,"rid500b",.CTX,"GET"),1,"[T500][sendfile]")
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["done500":1,1:0),1,"[T500][file]")
	QUIT
T501 ; common GET home page parse
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p21_t501.req"
	DO WRFILE(DEV,"GET / HTTP/1.1"_$C(13,10)_"Host: example.com"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T501][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("method")),"GET","[T501][method]")
	DO EQ^MIOTASSERT($GET(REQ("path")),"/","[T501][path]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","host")),"example.com","[T501][host]")
	QUIT
	;
T502 ; common GET asset with query cache buster
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p21_t502.req"
	DO WRFILE(DEV,"GET /app.js?v=42 HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T502][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("path")),"/app.js","[T502][path]")
	DO EQ^MIOTASSERT($GET(REQ("query","v")),"42","[T502][v]")
	QUIT
	;
T503 ; common HEAD request for health endpoint
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p21_t503.req"
	DO WRFILE(DEV,"HEAD /health HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T503][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("method")),"HEAD","[T503][method]")
	DO EQ^MIOTASSERT($GET(REQ("path")),"/health","[T503][path]")
	QUIT
	;
T504 ; common JSON API response helper
	NEW DEV,CONF,OUT,OP,OBJ
	SET OBJ("ok")=1
	SET OBJ("route")="/api/ping"
	SET OP="tmp/miohttp_p21_t504.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSON^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid504")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 200 OK":1,1:0),1,"[T504][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Type: application/json":1,1:0),1,"[T504][ctype]")
	DO EQ^MIOTASSERT($SELECT(OUT["""route"":""\/api\/ping""":1,1:0),1,"[T504][route]")
	QUIT
	;
T505 ; common plain text health response
	NEW DEV,CONF,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p21_t505.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,200,.HEAD,"OK","rid505")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Length: 2":1,1:0),1,"[T505][cl]")
	DO EQ^MIOTASSERT($SELECT(OUT["OK":1,1:0),1,"[T505][body]")
	QUIT
	;
T506 ; common form POST parse username password body
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="username=alice&password=secret"
	SET DEV="tmp/miohttp_p21_t506.req"
	DO WRFILE(DEV,"POST /login HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T506][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("path")),"/login","[T506][path]")
	DO EQ^MIOTASSERT($GET(REQ("hdr","content-type")),"application/x-www-form-urlencoded","[T506][ctype]")
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T506][body]")
	QUIT
	;
T507 ; common form POST with encoded spaces and slash
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="name=Alice+Smith&next=%2Fdashboard"
	SET DEV="tmp/miohttp_p21_t507.req"
	DO WRFILE(DEV,"POST /login HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T507][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T507][body]")
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("Alice+Smith"),"Alice Smith","[T507][name decode]")
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("%2Fdashboard"),"/dashboard","[T507][next decode]")
	QUIT
	;
T508 ; common form POST with empty optional field
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="email=a%40b.com&phone="
	SET DEV="tmp/miohttp_p21_t508.req"
	DO WRFILE(DEV,"POST /profile HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T508][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T508][body]")
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("a%40b.com"),"a@b.com","[T508][email decode]")
	QUIT
	;
T509 ; split flow form parsehdrs then readbodyonly
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="title=Hello+World&published=1"
	SET DEV="tmp/miohttp_p21_t509.req"
	DO WRFILE(DEV,"POST /posts HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T509][hdrs]")
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T509][body]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("hdr","content-type")),"application/x-www-form-urlencoded","[T509][ctype]")
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T509][body]")
	QUIT
	;
T510 ; common multipart not auto-decoded by http layer
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="field1=value1&field2=value2"
	SET DEV="tmp/miohttp_p21_t510.req"
	DO WRFILE(DEV,"POST /submit HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded; charset=utf-8"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T510][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("hdr","content-type")),"application/x-www-form-urlencoded; charset=utf-8","[T510][ctype]")
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T510][body]")
	QUIT
	;
T511 ; common search query parse
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p21_t511.req"
	DO WRFILE(DEV,"GET /search?q=hello+world&tag=mumps HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T511][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("query","q")),"hello world","[T511][q]")
	DO EQ^MIOTASSERT($GET(REQ("query","tag")),"mumps","[T511][tag]")
	QUIT
	;
T512 ; common file download via sendfile
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p21_t512.txt"
	DO WRFILE(FP,"download-body")
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p21_t512.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid512",.CTX,"GET"),1,"[T512][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["download-body":1,1:0),1,"[T512][body]")
	QUIT
	;
T513 ; common file HEAD download suppresses body
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p21_t513.txt"
	DO WRFILE(FP,"download-body")
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p21_t513.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid513",.CTX,"HEAD"),1,"[T513][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["download-body":1,1:0),0,"[T513][no body]")
	QUIT
	;
T514 ; common upload expect continue accepted
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","limits","maxBodyBytes")=20
	SET DEV="tmp/miohttp_p21_t514.req"
	DO WRFILE(DEV,"POST /upload HTTP/1.1"_$C(13,10)_"Expect: 100-continue"_$C(13,10)_"Content-Length: 10"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T514][hdrs]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR),1,"[T514][expect]")
	QUIT
	;
T515 ; common upload expect continue denied when too large
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","limits","maxBodyBytes")=5
	SET DEV="tmp/miohttp_p21_t515.req"
	DO WRFILE(DEV,"POST /upload HTTP/1.1"_$C(13,10)_"Expect: 100-continue"_$C(13,10)_"Content-Length: 10"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T515][hdrs]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR),0,"[T515][expect]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"payload_too_large","[T515][err]")
	QUIT
	;
T516 ; common chunked form body parse
	NEW CONF,REQ,ERR,DEV,BODY
	SET CONF("server","http","supportChunkedRequest")=1
	SET BODY="a=1&b=2"
	SET DEV="tmp/miohttp_p21_t516.req"
	DO WRFILE(DEV,"POST /form HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10,13,10)_"7"_$C(13,10)_BODY_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T516][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T516][body]")
	QUIT
	;
T517 ; common html response with defaults
	NEW DEV,CONF,OUT,OP,HEAD
	SET CONF("server","http","defaultResponseHeaders","X-App")="mio"
	SET HEAD("Content-Type")="text/html"
	SET OP="tmp/miohttp_p21_t517.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,200,.HEAD,"<h1>Home</h1>","rid517")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Type: text/html":1,1:0),1,"[T517][ctype]")
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: mio":1,1:0),1,"[T517][x-app]")
	QUIT
	;
T518 ; common streaming text response two chunks
	NEW DEV,CONF,CTX,OUT,OP,HEAD
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p21_t518.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,200,.HEAD,"rid518",.CTX)
	DO STREAMWRITE^MIOHTTP(.DEV,"hello ")
	DO STREAMWRITE^MIOHTTP(.DEV,"world")
	DO STREAMEND^MIOHTTP(.DEV)
	CLOSE DEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["6"_$C(13,10)_"hello ":1,1:0),1,"[T518][chunk1]")
	DO EQ^MIOTASSERT($SELECT(OUT["5"_$C(13,10)_"world":1,1:0),1,"[T518][chunk2]")
	QUIT
	;
T519 ; form fragment decode helper name field
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("first=Alice+Smith"),"first=Alice Smith","[T519][decode]")
	QUIT
	;
T520 ; form fragment decode helper encoded equals and ampersand
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("note=a%3Db%26c"),"note=a=b&c","[T520][decode]")
	QUIT
	;
T521 ; common parse then json echo response
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,OBJ
	SET DEV="tmp/miohttp_p21_t521.req"
	DO WRFILE(DEV,"GET /user?id=42 HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T521][parse]")
	DO CLOSER(DEV)
	SET OBJ("path")=$GET(REQ("path"))
	SET OBJ("id")=$GET(REQ("query","id"))
	SET OP="tmp/miohttp_p21_t521.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO RESPJSON^MIOHTTP(.RDEV,.CONF,200,.OBJ,"rid521")
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["""path"":""\/user""":1,1:0),1,"[T521][path]")
	DO EQ^MIOTASSERT($SELECT(OUT["""id"":42":1,1:0),1,"[T521][id]")
	QUIT
	;
T522 ; common login form split flow and text response
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,HEAD,BODY
	SET BODY="username=alice&password=secret"
	SET DEV="tmp/miohttp_p21_t522.req"
	DO WRFILE(DEV,"POST /login HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T522][hdrs]")
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T522][body]")
	DO CLOSER(DEV)
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p21_t522.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO RESP^MIOHTTP(.RDEV,.CONF,200,.HEAD,"logged-in","rid522")
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["logged-in":1,1:0),1,"[T522][resp]")
	QUIT
	;
T523 ; common empty form body cl0
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p21_t523.req"
	DO WRFILE(DEV,"POST /form HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: 0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T523][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"none","[T523][mode]")
	QUIT
	;
T524 ; common form body boundary exact scalar threshold
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="a=1&b=2"
	SET CONF("server","limits","maxBodyScalarBytes")=$L(BODY)
	SET DEV="tmp/miohttp_p21_t524.req"
	DO WRFILE(DEV,"POST /form HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T524][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"scalar","[T524][mode]")
	QUIT
	;
T525 ; common form body boundary above scalar threshold
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="a=1&b=2"
	SET CONF("server","limits","maxBodyScalarBytes")=$L(BODY)-1
	SET DEV="tmp/miohttp_p21_t525.req"
	DO WRFILE(DEV,"POST /form HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T525][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T525][mode]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
T526 ; common signup form parse
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="email=test%40example.com&password=secret123"
	SET DEV="tmp/miohttp_p22_t526.req"
	DO WRFILE(DEV,"POST /signup HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T526][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("path")),"/signup","[T526][path]")
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T526][body]")
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("test%40example.com"),"test@example.com","[T526][email]")
	QUIT
	;
T527 ; common contact form parse
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="name=Alice+Jones&message=Hello+there"
	SET DEV="tmp/miohttp_p22_t527.req"
	DO WRFILE(DEV,"POST /contact HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T527][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T527][body]")
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("Alice+Jones"),"Alice Jones","[T527][name]")
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("Hello+there"),"Hello there","[T527][msg]")
	QUIT
	;
T528 ; common settings form with booleans
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="email_alerts=1&sms_alerts=0&theme=dark"
	SET DEV="tmp/miohttp_p22_t528.req"
	DO WRFILE(DEV,"POST /settings HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T528][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T528][body]")
	QUIT
	;
T529 ; common search filters parse
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p22_t529.req"
	DO WRFILE(DEV,"GET /items?q=red+shoes&size=10&sort=price HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T529][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("query","q")),"red shoes","[T529][q]")
	DO EQ^MIOTASSERT($GET(REQ("query","size")),"10","[T529][size]")
	DO EQ^MIOTASSERT($GET(REQ("query","sort")),"price","[T529][sort]")
	QUIT
	;
T530 ; common pagination query parse
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p22_t530.req"
	DO WRFILE(DEV,"GET /posts?page=3&limit=25 HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T530][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("query","page")),"3","[T530][page]")
	DO EQ^MIOTASSERT($GET(REQ("query","limit")),"25","[T530][limit]")
	QUIT
	;
T531 ; common redirect style response 303
	NEW DEV,CONF,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("Location")="/thanks"
	SET OP="tmp/miohttp_p22_t531.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,303,.HEAD,"See Other","rid531")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 303 ":1,1:0),1,"[T531][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["Location: /thanks":1,1:0),1,"[T531][location]")
	QUIT
	;
T532 ; common redirect style response 302
	NEW DEV,CONF,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("Location")="/login"
	SET OP="tmp/miohttp_p22_t532.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,302,.HEAD,"Found","rid532")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 302 ":1,1:0),1,"[T532][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["Location: /login":1,1:0),1,"[T532][location]")
	QUIT
	;
T533 ; post submit json response helper
	NEW DEV,CONF,OUT,OP,OBJ
	SET OBJ("ok")=1
	SET OBJ("redirect")="/dashboard"
	SET OP="tmp/miohttp_p22_t533.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSON^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid533")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["""redirect"":""\/dashboard""":1,1:0),1,"[T533][redirect]")
	QUIT
	;
T534 ; common login form split flow then json response
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,OBJ,BODY
	SET BODY="username=alice&password=secret"
	SET DEV="tmp/miohttp_p22_t534.req"
	DO WRFILE(DEV,"POST /login HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T534][hdrs]")
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T534][body]")
	DO CLOSER(DEV)
	SET OBJ("path")=$GET(REQ("path"))
	SET OBJ("body")=$GET(REQ("body"))
	SET OP="tmp/miohttp_p22_t534.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO RESPJSON^MIOHTTP(.RDEV,.CONF,200,.OBJ,"rid534")
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["""path"":""\/login""":1,1:0),1,"[T534][path]")
	DO EQ^MIOTASSERT($SELECT(OUT["""body"":"""_BODY_"""":1,1:0),1,"[T534][body]")
	QUIT
	;
T535 ; common comment form small scalar body
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="text=Nice+post"
	SET CONF("server","limits","maxBodyScalarBytes")=50
	SET DEV="tmp/miohttp_p22_t535.req"
	DO WRFILE(DEV,"POST /comments HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T535][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"scalar","[T535][mode]")
	QUIT
	;
T536 ; common comment form large body goes global
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="text=This+is+a+longer+comment"
	SET CONF("server","limits","maxBodyScalarBytes")=5
	SET DEV="tmp/miohttp_p22_t536.req"
	DO WRFILE(DEV,"POST /comments HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T536][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T536][mode]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T537 ; common upload endpoint with fixed body
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="abcdef"
	SET DEV="tmp/miohttp_p22_t537.req"
	DO WRFILE(DEV,"POST /upload HTTP/1.1"_$C(13,10)_"Content-Type: application/octet-stream"_$C(13,10)_"Content-Length: 6"_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T537][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T537][body]")
	QUIT
	;
T538 ; common chunked upload endpoint
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","http","supportChunkedRequest")=1
	SET DEV="tmp/miohttp_p22_t538.req"
	DO WRFILE(DEV,"POST /upload HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10)_"Content-Type: application/octet-stream"_$C(13,10,13,10)_"3"_$C(13,10)_"abc"_$C(13,10)_"3"_$C(13,10)_"def"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T538][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"abcdef","[T538][body]")
	QUIT
	;
T539 ; common api post then stream response
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,HEAD,CTX,BODY
	SET BODY="name=api+client"
	SET DEV="tmp/miohttp_p22_t539.req"
	DO WRFILE(DEV,"POST /api/submit HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T539][parse]")
	DO CLOSER(DEV)
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p22_t539.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	DO STREAMBEGIN^MIOHTTP(.RDEV,.CONF,200,.HEAD,"rid539",.CTX)
	DO STREAMWRITE^MIOHTTP(.RDEV,"saved")
	DO STREAMEND^MIOHTTP(.RDEV)
	CLOSE RDEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["5"_$C(13,10)_"saved":1,1:0),1,"[T539][chunk]")
	QUIT
	;
T540 ; form field fragment decode simple pair
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("username=alice"),"username=alice","[T540][decode]")
	QUIT
	;
T541 ; form field fragment decode spaces
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("city=New+York"),"city=New York","[T541][decode]")
	QUIT
	;
T542 ; form field fragment decode slash and question mark
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("next=%2Fhome%3Ftab%3D1"),"next=/home?tab=1","[T542][decode]")
	QUIT
	;
T543 ; common GET profile query parse
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p22_t543.req"
	DO WRFILE(DEV,"GET /profile?tab=settings HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T543][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("query","tab")),"settings","[T543][tab]")
	QUIT
	;
T544 ; common GET filter query with repeated key last wins
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p22_t544.req"
	DO WRFILE(DEV,"GET /items?category=one&category=two HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T544][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("query","category")),"two","[T544][category]")
	QUIT
	;
T545 ; common create form then redirect response
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,HEAD,BODY
	SET BODY="title=New+Post"
	SET DEV="tmp/miohttp_p22_t545.req"
	DO WRFILE(DEV,"POST /posts HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T545][parse]")
	DO CLOSER(DEV)
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("Location")="/posts/1"
	SET OP="tmp/miohttp_p22_t545.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO RESP^MIOHTTP(.RDEV,.CONF,303,.HEAD,"See Other","rid545")
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Location: /posts/1":1,1:0),1,"[T545][location]")
	QUIT
	;
T546 ; common delete request parse
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p22_t546.req"
	DO WRFILE(DEV,"DELETE /posts/1 HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T546][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("method")),"DELETE","[T546][method]")
	QUIT
	;
T547 ; common patch form parse
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="display_name=Alice+J"
	SET DEV="tmp/miohttp_p22_t547.req"
	DO WRFILE(DEV,"PATCH /profile HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T547][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("method")),"PATCH","[T547][method]")
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T547][body]")
	QUIT
	;
T548 ; common put body parse
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="abcdef"
	SET DEV="tmp/miohttp_p22_t548.req"
	DO WRFILE(DEV,"PUT /files/1 HTTP/1.1"_$C(13,10)_"Content-Length: 6"_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T548][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("method")),"PUT","[T548][method]")
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T548][body]")
	QUIT
	;
T549 ; common form submit expect continue full flow
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,BODY
	SET BODY="a=1&b=2"
	SET CONF("server","limits","maxBodyBytes")=50
	SET DEV="tmp/miohttp_p22_t549.req"
	DO WRFILE(DEV,"POST /form HTTP/1.1"_$C(13,10)_"Expect: 100-continue"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T549][hdrs]")
	DO EQ^MIOTASSERT($$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR),1,"[T549][expect]")
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T549][body]")
	DO CLOSER(DEV)
	SET OP="tmp/miohttp_p22_t549.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO SEND100^MIOHTTP(.RDEV)
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["100 Continue":1,1:0),1,"[T549][100]")
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T549][body content]")
	QUIT
	;
T550 ; common final file download after form flow
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p22_t550.txt"
	DO WRFILE(FP,"report-ready")
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p22_t550.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid550",.CTX,"GET"),1,"[T550][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["report-ready":1,1:0),1,"[T550][body]")
	QUIT
T551 ; profile form with encoded email and display name
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="display_name=Alice+Smith&email=alice%40example.com"
	SET DEV="tmp/miohttp_p23_t551.req"
	DO WRFILE(DEV,"POST /profile HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T551][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T551][body]")
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("display_name=Alice+Smith"),"display_name=Alice Smith","[T551][name]")
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("email=alice%40example.com"),"email=alice@example.com","[T551][email]")
	QUIT
	;
T552 ; settings form with timezone and language
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="timezone=America%2FNew_York&language=en"
	SET DEV="tmp/miohttp_p23_t552.req"
	DO WRFILE(DEV,"POST /settings HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T552][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T552][body]")
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("timezone=America%2FNew_York"),"timezone=America/New_York","[T552][tz]")
	QUIT
	;
T553 ; password reset form with token
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="token=abc123&password=newpass"
	SET DEV="tmp/miohttp_p23_t553.req"
	DO WRFILE(DEV,"POST /reset HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T553][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("path")),"/reset","[T553][path]")
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T553][body]")
	QUIT
	;
T554 ; newsletter subscribe form
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="email=subscriber%40example.com"
	SET DEV="tmp/miohttp_p23_t554.req"
	DO WRFILE(DEV,"POST /subscribe HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T554][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP(BODY),"email=subscriber@example.com","[T554][decode]")
	QUIT
	;
T555 ; checkout form with encoded address
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="address=123+Main+St&city=New+York&zip=10001"
	SET DEV="tmp/miohttp_p23_t555.req"
	DO WRFILE(DEV,"POST /checkout HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T555][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T555][body]")
	QUIT
	;
T556 ; dashboard query with multiple filters
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p23_t556.req"
	DO WRFILE(DEV,"GET /dashboard?tab=activity&range=30d&team=core HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T556][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("query","tab")),"activity","[T556][tab]")
	DO EQ^MIOTASSERT($GET(REQ("query","range")),"30d","[T556][range]")
	DO EQ^MIOTASSERT($GET(REQ("query","team")),"core","[T556][team]")
	QUIT
	;
T557 ; search query with encoded slash and plus
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p23_t557.req"
	DO WRFILE(DEV,"GET /search?q=MUMPS%2FHTTP+tests HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T557][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("query","q")),"MUMPS/HTTP tests","[T557][q]")
	QUIT
	;
T558 ; navigation request for nested docs path
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p23_t558.req"
	DO WRFILE(DEV,"GET /docs/guides/http HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T558][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("path")),"/docs/guides/http","[T558][path]")
	QUIT
	;
T559 ; common success json payload after form submit
	NEW DEV,CONF,OUT,OP,OBJ
	SET OBJ("ok")=1
	SET OBJ("message")="saved"
	SET OP="tmp/miohttp_p23_t559.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSON^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid559")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["""message"":""saved""":1,1:0),1,"[T559][msg]")
	QUIT
	;
T560 ; common redirect after signup
	NEW DEV,CONF,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("Location")="/welcome"
	SET OP="tmp/miohttp_p23_t560.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,303,.HEAD,"See Other","rid560")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Location: /welcome":1,1:0),1,"[T560][location]")
	QUIT
	;
T561 ; common redirect after logout
	NEW DEV,CONF,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("Location")="/"
	SET OP="tmp/miohttp_p23_t561.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,302,.HEAD,"Found","rid561")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Location: /":1,1:0),1,"[T561][location]")
	QUIT
	;
T562 ; split flow settings form then text response
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,HEAD,BODY
	SET BODY="theme=dark&density=compact"
	SET DEV="tmp/miohttp_p23_t562.req"
	DO WRFILE(DEV,"POST /settings HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T562][hdrs]")
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T562][body]")
	DO CLOSER(DEV)
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p23_t562.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO RESP^MIOHTTP(.RDEV,.CONF,200,.HEAD,"saved","rid562")
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["saved":1,1:0),1,"[T562][resp]")
	QUIT
	;
T563 ; split flow profile form then json response
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,OBJ,BODY
	SET BODY="display_name=Alice+J"
	SET DEV="tmp/miohttp_p23_t563.req"
	DO WRFILE(DEV,"POST /profile HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T563][hdrs]")
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T563][body]")
	DO CLOSER(DEV)
	SET OBJ("ok")=1
	SET OBJ("body")=$GET(REQ("body"))
	SET OP="tmp/miohttp_p23_t563.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO RESPJSON^MIOHTTP(.RDEV,.CONF,200,.OBJ,"rid563")
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["""body"":"""_BODY_"""":1,1:0),1,"[T563][body]")
	QUIT
	;
T564 ; common report download sendfile with default header
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p23_t564.txt"
	DO WRFILE(FP,"monthly-report")
	SET CONF("server","http","defaultResponseHeaders","X-App")="mio"
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p23_t564.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid564",.CTX,"GET"),1,"[T564][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["monthly-report":1,1:0),1,"[T564][body]")
	DO EQ^MIOTASSERT($SELECT(OUT["X-App: mio":1,1:0),1,"[T564][x-app]")
	QUIT
	;
T565 ; common report download head only
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p23_t565.txt"
	DO WRFILE(FP,"monthly-report")
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p23_t565.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid565",.CTX,"HEAD"),1,"[T565][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["monthly-report":1,1:0),0,"[T565][no body]")
	QUIT
	;
T566 ; common query with page sort dir
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p23_t566.req"
	DO WRFILE(DEV,"GET /users?page=2&sort=name&dir=asc HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T566][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("query","page")),"2","[T566][page]")
	DO EQ^MIOTASSERT($GET(REQ("query","sort")),"name","[T566][sort]")
	DO EQ^MIOTASSERT($GET(REQ("query","dir")),"asc","[T566][dir]")
	QUIT
	;
T567 ; common GET with encoded tag and slash
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p23_t567.req"
	DO WRFILE(DEV,"GET /repos?tag=alpha%2Fbeta&view=grid HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T567][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("query","tag")),"alpha/beta","[T567][tag]")
	DO EQ^MIOTASSERT($GET(REQ("query","view")),"grid","[T567][view]")
	QUIT
	;
T568 ; form field helper repeated key fragment decode
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("tag=one&tag=two"),"tag=one&tag=two","[T568][decode]")
	QUIT
	;
T569 ; form field helper plus and percent combo
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("note=Hello+%26+Bye"),"note=Hello & Bye","[T569][decode]")
	QUIT
	;
T570 ; common empty search query value
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p23_t570.req"
	DO WRFILE(DEV,"GET /search?q= HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T570][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("query","q")),"","[T570][q]")
	QUIT
	;
T571 ; common file api fixed binary-like upload
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="1234567890"
	SET DEV="tmp/miohttp_p23_t571.req"
	DO WRFILE(DEV,"POST /api/upload HTTP/1.1"_$C(13,10)_"Content-Type: application/octet-stream"_$C(13,10)_"Content-Length: 10"_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T571][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T571][body]")
	QUIT
	;
T572 ; common api GET then stream json-like text
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,HEAD,CTX
	SET DEV="tmp/miohttp_p23_t572.req"
	DO WRFILE(DEV,"GET /api/status HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T572][parse]")
	DO CLOSER(DEV)
	SET HEAD("Content-Type")="application/json"
	SET OP="tmp/miohttp_p23_t572.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	DO STREAMBEGIN^MIOHTTP(.RDEV,.CONF,200,.HEAD,"rid572",.CTX)
	DO STREAMWRITE^MIOHTTP(.RDEV,"{""ok"":1}")
	DO STREAMEND^MIOHTTP(.RDEV)
	CLOSE RDEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["8"_$C(13,10)_"{""ok"":1}":1,1:0),1,"[T572][chunk]")
	QUIT
	;
T573 ; common save form with expect continue split flow
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="title=Draft&body=Text"
	SET CONF("server","limits","maxBodyBytes")=100
	SET DEV="tmp/miohttp_p23_t573.req"
	DO WRFILE(DEV,"POST /drafts HTTP/1.1"_$C(13,10)_"Expect: 100-continue"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T573][hdrs]")
	DO EQ^MIOTASSERT($$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR),1,"[T573][expect]")
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T573][body]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T573][body content]")
	QUIT
	;
T574 ; common response with request id header
	NEW DEV,CONF,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p23_t574.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,200,.HEAD,"done","rid574")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["X-Request-Id: rid574":1,1:0),1,"[T574][rid]")
	QUIT
	;
T575 ; common final roundtrip parse form then sendfile
	NEW CONF,REQ,ERR,DEV,FP,OP,OUT,RDEV,HEAD,CTX,BODY
	SET BODY="export=1&format=txt"
	SET DEV="tmp/miohttp_p23_t575.req"
	DO WRFILE(DEV,"POST /exports HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T575][parse]")
	DO CLOSER(DEV)
	SET FP="tmp/miohttp_p23_t575.txt"
	DO WRFILE(FP,"export-ready")
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p23_t575.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.RDEV,.CONF,FP,.HEAD,"rid575",.CTX,"GET"),1,"[T575][sendfile]")
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["export-ready":1,1:0),1,"[T575][file]")
	QUIT
T576 ; auth login form with remember me
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="username=alice&password=secret&remember=1"
	SET DEV="tmp/miohttp_p24_t576.req"
	DO WRFILE(DEV,"POST /auth/login HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T576][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("path")),"/auth/login","[T576][path]")
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T576][body]")
	QUIT
	;
T577 ; auth forgot password form
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="email=reset%40example.com"
	SET DEV="tmp/miohttp_p24_t577.req"
	DO WRFILE(DEV,"POST /auth/forgot HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T577][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP(BODY),"email=reset@example.com","[T577][decode]")
	QUIT
	;
T578 ; auth reset password form with token and next
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="token=abc123&password=secret2&next=%2Fdashboard"
	SET DEV="tmp/miohttp_p24_t578.req"
	DO WRFILE(DEV,"POST /auth/reset HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T578][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T578][body]")
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("next=%2Fdashboard"),"next=/dashboard","[T578][next]")
	QUIT
	;
T579 ; account delete confirmation form
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="confirm=yes"
	SET DEV="tmp/miohttp_p24_t579.req"
	DO WRFILE(DEV,"POST /account/delete HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T579][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T579][body]")
	QUIT
	;
T580 ; settings notifications form split flow
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="email=1&push=1&weekly=0"
	SET DEV="tmp/miohttp_p24_t580.req"
	DO WRFILE(DEV,"POST /settings/notifications HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T580][hdrs]")
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T580][body]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T580][body content]")
	QUIT
	;
T581 ; profile avatar upload fixed binary body
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="PNGDATA"
	SET DEV="tmp/miohttp_p24_t581.req"
	DO WRFILE(DEV,"POST /profile/avatar HTTP/1.1"_$C(13,10)_"Content-Type: application/octet-stream"_$C(13,10)_"Content-Length: 7"_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T581][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T581][body]")
	QUIT
	;
T582 ; search with phrase and category filters
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p24_t582.req"
	DO WRFILE(DEV,"GET /search?q=project+notes&category=docs&owner=alice HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T582][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("query","q")),"project notes","[T582][q]")
	DO EQ^MIOTASSERT($GET(REQ("query","category")),"docs","[T582][category]")
	DO EQ^MIOTASSERT($GET(REQ("query","owner")),"alice","[T582][owner]")
	QUIT
	;
T583 ; dashboard navigation query with section and mode
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p24_t583.req"
	DO WRFILE(DEV,"GET /dashboard?section=reports&mode=compact HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T583][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("query","section")),"reports","[T583][section]")
	DO EQ^MIOTASSERT($GET(REQ("query","mode")),"compact","[T583][mode]")
	QUIT
	;
T584 ; redirect after login success
	NEW DEV,CONF,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("Location")="/dashboard"
	SET OP="tmp/miohttp_p24_t584.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,303,.HEAD,"See Other","rid584")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Location: /dashboard":1,1:0),1,"[T584][location]")
	QUIT
	;
T585 ; redirect after logout success
	NEW DEV,CONF,OUT,OP,HEAD
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("Location")="/goodbye"
	SET OP="tmp/miohttp_p24_t585.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESP^MIOHTTP(.DEV,.CONF,302,.HEAD,"Found","rid585")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Location: /goodbye":1,1:0),1,"[T585][location]")
	QUIT
	;
T586 ; json success payload with redirect and ok
	NEW DEV,CONF,OUT,OP,OBJ
	SET OBJ("ok")=1
	SET OBJ("redirect")="/home"
	SET OBJ("status")="saved"
	SET OP="tmp/miohttp_p24_t586.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSON^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid586")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["""ok"":1":1,1:0),1,"[T586][ok]")
	DO EQ^MIOTASSERT($SELECT(OUT["""redirect"":""\/home""":1,1:0),1,"[T586][redirect]")
	QUIT
	;
T587 ; json failure payload common pattern
	NEW DEV,CONF,OUT,OP,OBJ
	SET OBJ("ok")=0
	SET OBJ("error")="validation_failed"
	SET OP="tmp/miohttp_p24_t587.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSON^MIOHTTP(.DEV,.CONF,400,.OBJ,"rid587")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 400 Bad Request":1,1:0),1,"[T587][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["""error"":""validation_failed""":1,1:0),1,"[T587][error]")
	QUIT
	;
T588 ; report export request parse with query
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p24_t588.req"
	DO WRFILE(DEV,"GET /exports/report?month=2026-03&format=csv HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T588][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("query","month")),"2026-03","[T588][month]")
	DO EQ^MIOTASSERT($GET(REQ("query","format")),"csv","[T588][format]")
	QUIT
	;
T589 ; export download sendfile common case
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p24_t589.txt"
	DO WRFILE(FP,"csv,data")
	SET HEAD("Content-Type")="text/csv"
	SET OP="tmp/miohttp_p24_t589.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid589",.CTX,"GET"),1,"[T589][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["csv,data":1,1:0),1,"[T589][body]")
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Type: text/csv":1,1:0),1,"[T589][ctype]")
	QUIT
	;
T590 ; export head download no body
	NEW DEV,CONF,CTX,OUT,OP,HEAD,FP
	SET FP="tmp/miohttp_p24_t590.txt"
	DO WRFILE(FP,"csv,data")
	SET HEAD("Content-Type")="text/csv"
	SET OP="tmp/miohttp_p24_t590.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO EQ^MIOTASSERT($$SENDFILE^MIOHTTP(.DEV,.CONF,FP,.HEAD,"rid590",.CTX,"HEAD"),1,"[T590][ok]")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["csv,data":1,1:0),0,"[T590][no body]")
	QUIT
	;
T591 ; common chunked form submit split flow
	NEW CONF,REQ,ERR,DEV,BODY
	SET CONF("server","http","supportChunkedRequest")=1
	SET BODY="x=1&y=2"
	SET DEV="tmp/miohttp_p24_t591.req"
	DO WRFILE(DEV,"POST /submit HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10,13,10)_"7"_$C(13,10)_BODY_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T591][hdrs]")
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T591][body]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),BODY,"[T591][body content]")
	QUIT
	;
T592 ; common stream response after search request
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,HEAD,CTX
	SET DEV="tmp/miohttp_p24_t592.req"
	DO WRFILE(DEV,"GET /search?q=alpha HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T592][parse]")
	DO CLOSER(DEV)
	SET HEAD("Content-Type")="text/plain"
	SET OP="tmp/miohttp_p24_t592.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	KILL ^TMP($J,"MIOHTTP","REQ")
	SET ^TMP($J,"MIOHTTP","REQ","method")="GET"
	DO STREAMBEGIN^MIOHTTP(.RDEV,.CONF,200,.HEAD,"rid592",.CTX)
	DO STREAMWRITE^MIOHTTP(.RDEV,"results")
	DO STREAMEND^MIOHTTP(.RDEV)
	CLOSE RDEV USE $PRINCIPAL
	KILL ^TMP($J,"MIOHTTP","REQ")
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["7"_$C(13,10)_"results":1,1:0),1,"[T592][chunk]")
	QUIT
	;
T593 ; common form helper decode encoded slash in return url
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("return_to=%2Fsettings%2Fprofile"),"return_to=/settings/profile","[T593][decode]")
	QUIT
	;
T594 ; common form helper decode plus and comma
	DO EQ^MIOTASSERT($$URLDECQ^MIOHTTP("tags=one%2Ctwo+three"),"tags=one,two three","[T594][decode]")
	QUIT
	;
T595 ; common GET with empty optional filters
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p24_t595.req"
	DO WRFILE(DEV,"GET /items?tag=&owner=alice HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T595][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("query","tag")),"","[T595][tag]")
	DO EQ^MIOTASSERT($GET(REQ("query","owner")),"alice","[T595][owner]")
	QUIT
	;
T596 ; common HEAD request to export route
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p24_t596.req"
	DO WRFILE(DEV,"HEAD /exports/report HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T596][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("method")),"HEAD","[T596][method]")
	QUIT
	;
T597 ; common profile form body exact scalar threshold
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="a=1&b=2&c=3"
	SET CONF("server","limits","maxBodyScalarBytes")=$L(BODY)
	SET DEV="tmp/miohttp_p24_t597.req"
	DO WRFILE(DEV,"POST /profile HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T597][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"scalar","[T597][mode]")
	QUIT
	;
T598 ; common profile form body above scalar threshold
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="a=1&b=2&c=3"
	SET CONF("server","limits","maxBodyScalarBytes")=$L(BODY)-1
	SET DEV="tmp/miohttp_p24_t598.req"
	DO WRFILE(DEV,"POST /profile HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T598][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T598][mode]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T599 ; common final json response after auth flow
	NEW DEV,CONF,OUT,OP,OBJ
	SET OBJ("ok")=1
	SET OBJ("user")="alice"
	SET OBJ("redirect")="/dashboard"
	SET OP="tmp/miohttp_p24_t599.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPJSON^MIOHTTP(.DEV,.CONF,200,.OBJ,"rid599")
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["""user"":""alice""":1,1:0),1,"[T599][user]")
	DO EQ^MIOTASSERT($SELECT(OUT["""redirect"":""\/dashboard""":1,1:0),1,"[T599][redirect]")
	QUIT
	;
T600 ; final common roundtrip form parse then redirect response
	NEW CONF,REQ,ERR,DEV,OP,OUT,RDEV,HEAD,BODY
	SET BODY="username=alice&password=secret"
	SET DEV="tmp/miohttp_p24_t600.req"
	DO WRFILE(DEV,"POST /auth/login HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T600][hdrs]")
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T600][body]")
	DO CLOSER(DEV)
	SET HEAD("Content-Type")="text/plain"
	SET HEAD("Location")="/dashboard"
	SET OP="tmp/miohttp_p24_t600.out"
	OPEN OP:(newversion:stream:nowrap)
	SET RDEV=OP USE RDEV
	DO RESP^MIOHTTP(.RDEV,.CONF,303,.HEAD,"See Other","rid600")
	CLOSE RDEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Location: /dashboard":1,1:0),1,"[T600][location]")
	QUIT
T601 ; MEDIATYPE plain
	DO EQ^MIOTASSERT($$MEDIATYPE^MIOHTTP("application/json"),"application/json","[T601][mt]")
	QUIT
	;
T602 ; MEDIATYPE strips params and lowers
	DO EQ^MIOTASSERT($$MEDIATYPE^MIOHTTP("Application/X-WWW-Form-Urlencoded; charset=utf-8"),"application/x-www-form-urlencoded","[T602][mt]")
	QUIT
	;
T603 ; CTPARAM charset
	DO EQ^MIOTASSERT($$CTPARAM^MIOHTTP("application/json; charset=utf-8","charset"),"utf-8","[T603][charset]")
	QUIT
	;
T604 ; CTPARAM quoted boundary
	DO EQ^MIOTASSERT($$CTPARAM^MIOHTTP("multipart/form-data; boundary=""abc123""","boundary"),"""abc123""","[T604][boundary]")
	QUIT
	;
T605 ; ISFORM exact type
	NEW REQ
	SET REQ("hdr","content-type")="application/x-www-form-urlencoded"
	DO EQ^MIOTASSERT($$ISFORM^MIOHTTP(.REQ),1,"[T605][isform]")
	QUIT
	;
T606 ; ISFORM with charset
	NEW REQ
	SET REQ("hdr","content-type")="application/x-www-form-urlencoded; charset=utf-8"
	DO EQ^MIOTASSERT($$ISFORM^MIOHTTP(.REQ),1,"[T606][isform]")
	QUIT
	;
T607 ; ISJSON exact
	NEW REQ
	SET REQ("hdr","content-type")="application/json"
	DO EQ^MIOTASSERT($$ISJSON^MIOHTTP(.REQ),1,"[T607][isjson]")
	QUIT
	;
T608 ; ISJSON vendor subtype
	NEW REQ
	SET REQ("hdr","content-type")="application/problem+json"
	DO EQ^MIOTASSERT($$ISJSON^MIOHTTP(.REQ),1,"[T608][isjson]")
	QUIT
	;
T609 ; PARSEFORM scalar simple
	NEW REQ,OUT,ERR
	SET REQ("hdr","content-type")="application/x-www-form-urlencoded"
	SET REQ("body","mode")="scalar"
	SET REQ("body")="a=1&b=two"
	SET REQ("body","len")=9
	DO EQ^MIOTASSERT($$PARSEFORM^MIOHTTP(.REQ,.OUT,.ERR),1,"[T609][ok]")
	DO EQ^MIOTASSERT($GET(OUT("a")),"1","[T609][a]")
	DO EQ^MIOTASSERT($GET(OUT("b")),"two","[T609][b]")
	QUIT
	;
T610 ; PARSEFORM repeated keys
	NEW REQ,OUT,ERR
	SET REQ("hdr","content-type")="application/x-www-form-urlencoded"
	SET REQ("body","mode")="scalar"
	SET REQ("body")="tag=one++&tag=two++&tag=three&tag=four+"
	SET REQ("body","len")=$LENGTH(REQ("body"))
	DO EQ^MIOTASSERT($$PARSEFORM^MIOHTTP(.REQ,.OUT,.ERR),1,"[T610][ok]")
	DO EQ^MIOTASSERT($GET(OUT("tag")),"four ","[T610][last]")
	DO EQ^MIOTASSERT($GET(OUT("tag",0)),4,"[T610][count]")
	DO EQ^MIOTASSERT($GET(OUT("tag",1)),"one  ","[T610][1]")
	DO EQ^MIOTASSERT($GET(OUT("tag",2)),"two  ","[T610][2]")
	DO EQ^MIOTASSERT($GET(OUT("tag",3)),"three","[T610][3]")
	DO EQ^MIOTASSERT($GET(OUT("tag",4)),"four ","[T610][4]")
	QUIT
	;
T611 ; PARSEFORM blank value
	NEW REQ,OUT,ERR
	SET REQ("hdr","content-type")="application/x-www-form-urlencoded"
	SET REQ("body","mode")="scalar"
	SET REQ("body")="phone="
	SET REQ("body","len")=6
	DO EQ^MIOTASSERT($$PARSEFORM^MIOHTTP(.REQ,.OUT,.ERR),1,"[T611][ok]")
	DO EQ^MIOTASSERT($GET(OUT("phone")),"","[T611][blank]")
	QUIT
	;
T612 ; PARSEFORM decodes spaces and slash
	NEW REQ,OUT,ERR
	SET REQ("hdr","content-type")="application/x-www-form-urlencoded"
	SET REQ("body","mode")="scalar"
	SET REQ("body")="name=Alice+Smith&next=%2Fdashboard"
	SET REQ("body","len")=$LENGTH(REQ("body"))
	DO EQ^MIOTASSERT($$PARSEFORM^MIOHTTP(.REQ,.OUT,.ERR),1,"[T612][ok]")
	DO EQ^MIOTASSERT($GET(OUT("name")),"Alice Smith","[T612][name]")
	DO EQ^MIOTASSERT($GET(OUT("next")),"/dashboard","[T612][next]")
	QUIT
	;
T613 ; PARSEFORM global body across chunk boundaries
	NEW REQ,OUT,ERR,REF
	SET REQ("hdr","content-type")="application/x-www-form-urlencoded"
	SET REQ("body","mode")="global"
	SET REF=$NAME(^TMP($J,"MIOHTTPP25","T613"))
	KILL @REF
	SET REQ("body","ref")=REF
	SET @REF@(1)="name=Ali"
	SET @REF@(2)="ce+Smith&tag"
	SET @REF@(3)="=mumps"
	SET REQ("body","n")=3
	SET REQ("body","len")=$LENGTH(@REF@(1))+$LENGTH(@REF@(2))+$LENGTH(@REF@(3))
	DO EQ^MIOTASSERT($$PARSEFORM^MIOHTTP(.REQ,.OUT,.ERR),1,"[T613][ok]")
	DO EQ^MIOTASSERT($GET(OUT("name")),"Alice Smith","[T613][name]")
	DO EQ^MIOTASSERT($GET(OUT("tag")),"mumps","[T613][tag]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T614 ; PARSEFORM non-form type rejected
	NEW REQ,OUT,ERR
	SET REQ("hdr","content-type")="application/json"
	SET REQ("body","mode")="scalar"
	SET REQ("body")="{}"
	SET REQ("body","len")=2
	DO EQ^MIOTASSERT($$PARSEFORM^MIOHTTP(.REQ,.OUT,.ERR),0,"[T614][ok]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"not_form_content_type","[T614][err]")
	QUIT
	;
T615 ; REDIRECT default status
	NEW DEV,CONF,CTX,OUT,OP
	SET OP="tmp/miohttp_p25_t615.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO REDIRECT^MIOHTTP(.DEV,.CONF,"/home","","rid615",.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 303 See Other":1,1:0),1,"[T615][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["Location: /home":1,1:0),1,"[T615][location]")
	QUIT
	;
T616 ; REDIRECT explicit status
	NEW DEV,CONF,CTX,OUT,OP
	SET OP="tmp/miohttp_p25_t616.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO REDIRECT^MIOHTTP(.DEV,.CONF,"/login",302,"rid616",.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 302 Found":1,1:0),1,"[T616][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["Location: /login":1,1:0),1,"[T616][location]")
	QUIT
	;
T617 ; RESPTEXT helper
	NEW DEV,CONF,CTX,OUT,OP
	SET OP="tmp/miohttp_p25_t617.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPTEXT^MIOHTTP(.DEV,.CONF,200,"hello","rid617",.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["Content-Type: text/plain; charset=utf-8":1,1:0),1,"[T617][ctype]")
	DO EQ^MIOTASSERT($SELECT(OUT["hello":1,1:0),1,"[T617][body]")
	QUIT
	;
T618 ; RESPERR helper
	NEW DEV,CONF,CTX,OUT,OP
	SET OP="tmp/miohttp_p25_t618.out"
	OPEN OP:(newversion:stream:nowrap)
	SET DEV=OP USE DEV
	DO RESPERR^MIOHTTP(.DEV,.CONF,422,"validation_failed","bad email","rid618",.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["HTTP/1.1 422 Unprocessable Entity":1,1:0),1,"[T618][status]")
	DO EQ^MIOTASSERT($SELECT(OUT["""error"":""validation_failed""":1,1:0),1,"[T618][error]")
	DO EQ^MIOTASSERT($SELECT(OUT["""message"":""bad email""":1,1:0),1,"[T618][message]")
	QUIT
	;
T619 ; STATUSMSG added phrases
	DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(201),"Created","[T619][201]")
	DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(303),"See Other","[T619][303]")
	DO EQ^MIOTASSERT($$STATUSMSG^MIOHTTP(422),"Unprocessable Entity","[T619][422]")
	QUIT
	;
T620 ; CTPARAM missing returns empty
	DO EQ^MIOTASSERT($$CTPARAM^MIOHTTP("application/json; charset=utf-8","boundary"),"","[T620][empty]")
	QUIT
T621 ; TARGETKIND origin
	NEW REQ
	SET REQ("method")="GET",REQ("path")="/x"
	DO EQ^MIOTASSERT($$TARGETKIND^MIOHTTP(.REQ),"origin","[T621][kind]")
	QUIT
	;
T622 ; TARGETKIND asterisk
	NEW REQ
	SET REQ("method")="OPTIONS",REQ("path")="*"
	DO EQ^MIOTASSERT($$TARGETKIND^MIOHTTP(.REQ),"asterisk","[T622][kind]")
	QUIT
	;
T623 ; TARGETKIND authority
	NEW REQ
	SET REQ("method")="CONNECT",REQ("path")="example.com:443"
	DO EQ^MIOTASSERT($$TARGETKIND^MIOHTTP(.REQ),"authority","[T623][kind]")
	QUIT
	;
T624 ; PARSEHDRS GET metadata none/origin
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p26_t624.req"
	DO WRFILE(DEV,"GET /home HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T624][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("meta","targetKind")),"origin","[T624][kind]")
	DO EQ^MIOTASSERT($GET(REQ("meta","bodyFraming")),"none","[T624][framing]")
	DO EQ^MIOTASSERT($GET(REQ("meta","hasBody")),0,"[T624][hasBody]")
	QUIT
	;
T625 ; PARSEHDRS POST form metadata CL
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p26_t625.req"
	DO WRFILE(DEV,"POST /form HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: 7"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T625][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("meta","contentLength")),"7","[T625][cl]")
	DO EQ^MIOTASSERT($GET(REQ("meta","bodyFraming")),"content-length","[T625][framing]")
	DO EQ^MIOTASSERT($GET(REQ("meta","hasBody")),1,"[T625][hasBody]")
	DO EQ^MIOTASSERT($GET(REQ("meta","isForm")),1,"[T625][isForm]")
	QUIT
	;
T626 ; PARSEHDRS JSON metadata
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p26_t626.req"
	DO WRFILE(DEV,"POST /api HTTP/1.1"_$C(13,10)_"Content-Type: application/json"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T626][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("meta","isJSON")),1,"[T626][isJSON]")
	QUIT
	;
T627 ; PARSEHDRS chunked metadata
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p26_t627.req"
	DO WRFILE(DEV,"POST /up HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T627][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("meta","transferEncoding")),"chunked","[T627][te]")
	DO EQ^MIOTASSERT($GET(REQ("meta","bodyFraming")),"chunked","[T627][framing]")
	DO EQ^MIOTASSERT($GET(REQ("meta","hasBody")),1,"[T627][hasBody]")
	QUIT
	;
T628 ; PARSE full GET metadata none
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p26_t628.req"
	DO WRFILE(DEV,"GET /ping HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T628][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("meta","bodyFraming")),"none","[T628][framing]")
	DO EQ^MIOTASSERT($GET(REQ("meta","hasBody")),0,"[T628][hasBody]")
	QUIT
	;
T629 ; PARSE full POST CL body metadata
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p26_t629.req"
	DO WRFILE(DEV,"POST /echo HTTP/1.1"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10)_"ok")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T629][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("meta","bodyFraming")),"content-length","[T629][framing]")
	DO EQ^MIOTASSERT($GET(REQ("meta","hasBody")),1,"[T629][hasBody]")
	QUIT
	;
T630 ; PARSE full POST CL zero metadata
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p26_t630.req"
	DO WRFILE(DEV,"POST /empty HTTP/1.1"_$C(13,10)_"Content-Length: 0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T630][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("meta","bodyFraming")),"content-length","[T630][framing]")
	DO EQ^MIOTASSERT($GET(REQ("meta","hasBody")),0,"[T630][hasBody]")
	QUIT
	;
T631 ; PARSE full chunked metadata
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","http","supportChunkedRequest")=1
	SET DEV="tmp/miohttp_p26_t631.req"
	DO WRFILE(DEV,"POST /c HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10,13,10)_"2"_$C(13,10)_"ok"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T631][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("meta","bodyFraming")),"chunked","[T631][framing]")
	DO EQ^MIOTASSERT($GET(REQ("meta","hasBody")),1,"[T631][hasBody]")
	QUIT
	;
T632 ; READBODYONLY updates CL metadata
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p26_t632.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10)_"ok")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T632][hdrs]")
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T632][body]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("meta","bodyFraming")),"content-length","[T632][framing]")
	DO EQ^MIOTASSERT($GET(REQ("meta","hasBody")),1,"[T632][hasBody]")
	QUIT
	;
T633 ; READBODYONLY updates chunked metadata
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","http","supportChunkedRequest")=1
	SET DEV="tmp/miohttp_p26_t633.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Transfer-Encoding: chunked"_$C(13,10,13,10)_"2"_$C(13,10)_"ok"_$C(13,10)_"0"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T633][hdrs]")
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T633][body]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("meta","bodyFraming")),"chunked","[T633][framing]")
	QUIT
	;
T634 ; PARSE CONNECT metadata authority
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p26_t634.req"
	DO WRFILE(DEV,"CONNECT example.com:443 HTTP/1.1"_$C(13,10)_"Host: example.com"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T634][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("meta","targetKind")),"authority","[T634][kind]")
	QUIT
	;
T635 ; PARSE OPTIONS star metadata asterisk
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p26_t635.req"
	DO WRFILE(DEV,"OPTIONS * HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T635][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("meta","targetKind")),"asterisk","[T635][kind]")
	QUIT
	;
T636 ; PARSE full form metadata isForm
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="a=1&b=2"
	SET DEV="tmp/miohttp_p26_t636.req"
	DO WRFILE(DEV,"POST /form HTTP/1.1"_$C(13,10)_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)_"Content-Length: "_$L(BODY)_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T636][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("meta","isForm")),1,"[T636][isForm]")
	QUIT
	;
T637 ; PARSE full json metadata isJSON
	NEW CONF,REQ,ERR,DEV,BODY
	SET BODY="{}"
	SET DEV="tmp/miohttp_p26_t637.req"
	DO WRFILE(DEV,"POST /api HTTP/1.1"_$C(13,10)_"Content-Type: application/json"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10)_BODY)
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T637][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("meta","isJSON")),1,"[T637][isJSON]")
	QUIT
	;
T638 ; PARSE TE identity with CL metadata
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p26_t638.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Transfer-Encoding: identity"_$C(13,10)_"Content-Length: 2"_$C(13,10,13,10)_"ok")
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T638][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("meta","transferEncoding")),"identity","[T638][te]")
	DO EQ^MIOTASSERT($GET(REQ("meta","bodyFraming")),"content-length","[T638][framing]")
	QUIT
	;
T639 ; PARSE TE identity no CL metadata none
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p26_t639.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Transfer-Encoding: identity"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T639][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("meta","transferEncoding")),"identity","[T639][te]")
	DO EQ^MIOTASSERT($GET(REQ("meta","bodyFraming")),"none","[T639][framing]")
	DO EQ^MIOTASSERT($GET(REQ("meta","hasBody")),0,"[T639][hasBody]")
	QUIT
	;
T640 ; PARSE query request keeps origin metadata
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p26_t640.req"
	DO WRFILE(DEV,"GET /items?page=2 HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T640][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("meta","targetKind")),"origin","[T640][kind]")
	DO EQ^MIOTASSERT($GET(REQ("query","page")),"2","[T640][page]")
	QUIT
T641 ; BODYFRAMING none
	NEW CONF,REQ,ERR
	DO SETMETABASE^MIOHTTP(.REQ)
	DO EQ^MIOTASSERT($$BODYFRAMING^MIOHTTP(.CONF,.REQ,.ERR),"none","[T621][fr]")
	QUIT
	;
T642 ; BODYFRAMING content-length
	NEW CONF,REQ,ERR
	SET REQ("hdr","content-length")="5"
	DO SETMETABASE^MIOHTTP(.REQ)
	DO EQ^MIOTASSERT($$BODYFRAMING^MIOHTTP(.CONF,.REQ,.ERR),"content-length","[T622][fr]")
	QUIT
	;
T643 ; BODYFRAMING chunked
	NEW CONF,REQ,ERR
	SET REQ("hdr","transfer-encoding")="chunked"
	DO SETMETABASE^MIOHTTP(.REQ)
	DO EQ^MIOTASSERT($$BODYFRAMING^MIOHTTP(.CONF,.REQ,.ERR),"chunked","[T623][fr]")
	QUIT
	;
T644 ; BODYFRAMING identity plus content-length
	NEW CONF,REQ,ERR
	SET REQ("hdr","transfer-encoding")="identity"
	SET REQ("hdr","content-length")="4"
	DO SETMETABASE^MIOHTTP(.REQ)
	DO EQ^MIOTASSERT($$BODYFRAMING^MIOHTTP(.CONF,.REQ,.ERR),"content-length","[T624][fr]")
	QUIT
	;
T645 ; BODYFRAMING te cl conflict by default
	NEW CONF,REQ,ERR
	SET REQ("hdr","transfer-encoding")="chunked"
	SET REQ("hdr","content-length")="4"
	DO SETMETABASE^MIOHTTP(.REQ)
	DO EQ^MIOTASSERT($$BODYFRAMING^MIOHTTP(.CONF,.REQ,.ERR),"","[T625][fr]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"te_cl_conflict","[T625][err]")
	QUIT
	;
T646 ; BODYFRAMING te cl allowed when enabled
	NEW CONF,REQ,ERR
	SET CONF("server","http","allowTECL")=1
	SET REQ("hdr","transfer-encoding")="chunked"
	SET REQ("hdr","content-length")="4"
	DO SETMETABASE^MIOHTTP(.REQ)
	DO EQ^MIOTASSERT($$BODYFRAMING^MIOHTTP(.CONF,.REQ,.ERR),"chunked","[T626][fr]")
	QUIT
	;
T647 ; BODYFRAMING bad te order
	NEW CONF,REQ,ERR
	SET REQ("hdr","transfer-encoding")="chunked, identity"
	DO SETMETABASE^MIOHTTP(.REQ)
	DO EQ^MIOTASSERT($$BODYFRAMING^MIOHTTP(.CONF,.REQ,.ERR),"","[T627][fr]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"bad_transfer_encoding_order","[T627][err]")
	QUIT
	;
T648 ; STRICTREQ missing host on http11 origin
	NEW CONF,REQ,ERR
	SET CONF("server","http","strict")=1
	SET REQ("method")="GET",REQ("path")="/x",REQ("httpver")="HTTP/1.1"
	DO SETMETABASE^MIOHTTP(.REQ)
	DO EQ^MIOTASSERT($$STRICTREQ^MIOHTTP(.CONF,.REQ,.ERR),0,"[T628][ok]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"missing_host","[T628][err]")
	QUIT
	;
T649 ; STRICTREQ non-strict allows missing host
	NEW CONF,REQ,ERR
	SET REQ("method")="GET",REQ("path")="/x",REQ("httpver")="HTTP/1.1"
	DO SETMETABASE^MIOHTTP(.REQ)
	DO EQ^MIOTASSERT($$STRICTREQ^MIOHTTP(.CONF,.REQ,.ERR),1,"[T629][ok]")
	QUIT
	;
T650 ; STRICTREQ options star valid
	NEW CONF,REQ,ERR
	SET CONF("server","http","strict")=1
	SET REQ("method")="OPTIONS",REQ("path")="*",REQ("httpver")="HTTP/1.1",REQ("hdr","host")="ex"
	DO SETMETABASE^MIOHTTP(.REQ)
	DO EQ^MIOTASSERT($$STRICTREQ^MIOHTTP(.CONF,.REQ,.ERR),1,"[T630][ok]")
	QUIT
	;
T651 ; STRICTREQ get star invalid
	NEW CONF,REQ,ERR
	SET CONF("server","http","strict")=1
	SET REQ("method")="GET",REQ("path")="*",REQ("httpver")="HTTP/1.1",REQ("hdr","host")="ex"
	DO SETMETABASE^MIOHTTP(.REQ)
	DO EQ^MIOTASSERT($$STRICTREQ^MIOHTTP(.CONF,.REQ,.ERR),0,"[T631][ok]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"invalid_request_target","[T631][err]")
	QUIT
	;
T652 ; STRICTREQ connect authority valid
	NEW CONF,REQ,ERR
	SET CONF("server","http","strict")=1
	SET REQ("method")="CONNECT",REQ("path")="example.com:443",REQ("httpver")="HTTP/1.1"
	DO SETMETABASE^MIOHTTP(.REQ)
	DO EQ^MIOTASSERT($$STRICTREQ^MIOHTTP(.CONF,.REQ,.ERR),1,"[T632][ok]")
	QUIT
	;
T653 ; STRICTREQ get authority invalid
	NEW CONF,REQ,ERR
	SET CONF("server","http","strict")=1
	SET REQ("method")="GET",REQ("path")="example.com:443",REQ("httpver")="HTTP/1.1"
	DO SETMETABASE^MIOHTTP(.REQ)
	DO EQ^MIOTASSERT($$STRICTREQ^MIOHTTP(.CONF,.REQ,.ERR),0,"[T633][ok]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"missing_host","[T633][err]")
	QUIT
	;
T654 ; PARSE strict missing host fails
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","http","strict")=1
	SET DEV="tmp/miohttp_p27_t634.req"
	DO WRFILE(DEV,"GET /secure HTTP/1.1"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T634][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"missing_host","[T634][err]")
	QUIT
	;
T655 ; PARSE strict host present passes
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","http","strict")=1
	SET DEV="tmp/miohttp_p27_t635.req"
	DO WRFILE(DEV,"GET /secure HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T635][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("meta","targetKind")),"origin","[T635][tk]")
	DO EQ^MIOTASSERT($GET(REQ("meta","bodyFraming")),"none","[T635][fr]")
	QUIT
	;
T656 ; PARSEHDRS strict options star passes
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","http","strict")=1
	SET DEV="tmp/miohttp_p27_t636.req"
	DO WRFILE(DEV,"OPTIONS * HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T636][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("meta","targetKind")),"asterisk","[T636][tk]")
	QUIT
	;
T657 ; PARSEHDRS strict invalid origin target fails
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","http","strict")=1
	SET DEV="tmp/miohttp_p27_t637.req"
	DO WRFILE(DEV,"GET abc HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSEHDRS^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T637][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"invalid_request_target","[T637][err]")
	QUIT
	;
T658 ; READBODYONLY chunked uses framing helper
	NEW CONF,REQ,ERR,DEV
	SET CONF("server","http","supportChunkedRequest")=1
	SET DEV="tmp/miohttp_p27_t638.req"
	DO WRFILE(DEV,"2"_$C(13,10)_"ok"_$C(13,10)_"0"_$C(13,10,13,10))
	SET REQ("method")="POST",REQ("path")="/x",REQ("httpver")="HTTP/1.1",REQ("hdr","transfer-encoding")="chunked"
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T638][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body")),"ok","[T638][body]")
	DO EQ^MIOTASSERT($GET(REQ("meta","bodyFraming")),"chunked","[T638][fr]")
	QUIT
	;
T659 ; READBODYONLY cl zero sets no body but framing content-length
	NEW CONF,REQ,ERR
	SET REQ("method")="POST",REQ("path")="/x",REQ("httpver")="HTTP/1.1",REQ("hdr","content-length")="0"
	DO EQ^MIOTASSERT($$READBODYONLY^MIOHTTP("dummy",.CONF,.REQ,.ERR),1,"[T639][ok]")
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"none","[T639][mode]")
	DO EQ^MIOTASSERT($GET(REQ("meta","bodyFraming")),"content-length","[T639][fr]")
	QUIT
	;
T660 ; PARSE te identity no cl yields none framing
	NEW CONF,REQ,ERR,DEV
	SET DEV="tmp/miohttp_p27_t640.req"
	DO WRFILE(DEV,"POST /x HTTP/1.1"_$C(13,10)_"Host: ex"_$C(13,10)_"Transfer-Encoding: identity"_$C(13,10,13,10))
	DO OPENR(DEV)
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T640][ok]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("meta","bodyFraming")),"none","[T640][fr]")
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