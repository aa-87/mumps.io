MIOHTTPT ; MIOHTTP test suite (request parsing + streaming bodies)
;
; Run:
;   YDB>ZL "MIOHTTP.m","MIOHTTPT.m","MIOTASSERT.m","MIOUTIL.m","MIOROUTE.m","MIOSOCK.m"
;   YDB>D ^MIOHTTPT
;
; Notes
; - Uses files as the "socket" device.;
; - Prints only FAIL lines.;
;
	NEW DEBUG SET DEBUG=$GET(^MIO("CONF","test","debug"),0)
	; Set ^MIO("CONF","test","debug")=1 to print extra diagnostics on failures.;
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
	QUIT
	;
; ---------------- helpers ----------------
	;
TMPPATH(NAME)
	QUIT "/tmp/"_NAME_"_"_$J_".req"
	;
WRFILE(PATH,TXT)
	NEW DEV SET DEV=PATH
	OPEN DEV:(newversion:stream:nowrap)
	USE DEV WRITE TXT
	CLOSE DEV
	QUIT
	;
OPENR(PATH)
	NEW DEV SET DEV=PATH
	OPEN DEV:(readonly:stream)
	USE DEV:(delim=$C(13,10))
	QUIT DEV
	;
CLOSER(DEV)
	CLOSE DEV
	QUIT
	;
SLURP(REQ,OUT)
	NEW CUR,CH
	SET OUT=""
	DO BODYOPEN^MIOHTTP(.REQ,.CUR)
	FOR  QUIT:'$$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH)  SET OUT=OUT_CH
	QUIT
	;
; ---------------- tests ----------------
	;
T001 ; GET /plgd?... query parsing
	NEW CONF,REQ,ERR,DEV,PATH,TXT
	KILL CONF,REQ,ERR
	SET PATH=$$TMPPATH("t001")
	SET TXT="GET /plgd?q=&sort=updated&per=18&fav=0&view=grid HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t001"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T001][parse]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("path")),"/plgd","[T001][path]")
	DO EQ^MIOTASSERT($GET(REQ("query","sort")),"updated","[T001][q sort]")
	DO EQ^MIOTASSERT($GET(REQ("query","per")),"18","[T001][q per]")
	DO EQ^MIOTASSERT($GET(REQ("query","fav")),"0","[T001][q fav]")
	DO EQ^MIOTASSERT($GET(REQ("query","view")),"grid","[T001][q view]")
	DO EQ^MIOTASSERT($DATA(REQ("query","q"))>0,1,"[T001][q present]")
	QUIT
	;
T002 ; POST small body -> scalar
	NEW CONF,REQ,ERR,DEV,PATH,TXT,B
	KILL CONF,REQ,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=1024
	SET PATH=$$TMPPATH("t002")
	SET B="hello=world"
	SET TXT="POST /submit HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Content-Type: application/x-www-form-urlencoded"_$C(13,10)
	SET TXT=TXT_"Content-Length: "_$L(B)_$C(13,10)_$C(13,10)
	SET TXT=TXT_B
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t002"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T002][parse]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"scalar","[T002][mode]")
	DO EQ^MIOTASSERT($GET(REQ("body")),B,"[T002][body]")
	DO EQ^MIOTASSERT($$BODYLEN^MIOHTTP(.REQ),$L(B),"[T002][len]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T003 ; POST large body -> global chunks (trigger via small maxBodyScalarBytes)
	NEW CONF,REQ,ERR,DEV,PATH,TXT,B,OUT
	KILL CONF,REQ,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=16
	SET CONF("server","http","readBodyChunkBytes")=10
	SET PATH=$$TMPPATH("t003")
	SET B="abcdefghijklmnopqrstuvwxyz0123456789" ; 36 bytes
	SET TXT="POST /big HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Content-Length: "_$L(B)_$C(13,10)_$C(13,10)
	SET TXT=TXT_B
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t003"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T003][parse]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T003][mode]")
	; In global mode there should be NO scalar value at REQ("body"), but descendants exist.;
	DO EQ^MIOTASSERT(($DATA(REQ("body"))#2),0,"[T003][no scalar body]")
	DO OK^MIOTASSERT($GET(REQ("body","ref"))'="","[T003][ref]")
	DO SLURP(.REQ,.OUT)
	DO EQ^MIOTASSERT(OUT,B,"[T003][slurp]")
	DO EQ^MIOTASSERT($$BODYLEN^MIOHTTP(.REQ),$L(B),"[T003][len]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T004 ; Chunked small -> scalar
	NEW CONF,REQ,ERR,DEV,PATH,TXT,OUT
	KILL CONF,REQ,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=64
	SET PATH=$$TMPPATH("t004")
	SET TXT="POST /c HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Transfer-Encoding: chunked"_$C(13,10)_$C(13,10)
	SET TXT=TXT_"4"_$C(13,10)_"Wiki"_$C(13,10)
	SET TXT=TXT_"5"_$C(13,10)_"pedia"_$C(13,10)
	SET TXT=TXT_"0"_$C(13,10)_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t004"
	NEW OK SET OK=$$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	IF 'OK,DEBUG DO DUMPERR("T004",PATH,.ERR,.REQ)
	DO EQ^MIOTASSERT(OK,1,"[T004][parse]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"scalar","[T004][mode]")
	DO SLURP(.REQ,.OUT)
	DO EQ^MIOTASSERT(OUT,"Wikipedia","[T004][body]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T005 ; Chunked triggers upgrade -> global
	NEW CONF,REQ,ERR,DEV,PATH,TXT,OUT
	KILL CONF,REQ,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=8
	SET PATH=$$TMPPATH("t005")
	SET TXT="POST /c HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Transfer-Encoding: chunked"_$C(13,10)_$C(13,10)
	SET TXT=TXT_"4"_$C(13,10)_"Wiki"_$C(13,10)
	SET TXT=TXT_"5"_$C(13,10)_"pedia"_$C(13,10)
	SET TXT=TXT_"0"_$C(13,10)_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t005"
	NEW OK SET OK=$$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	IF 'OK,DEBUG DO DUMPERR("T005",PATH,.ERR,.REQ)
	DO EQ^MIOTASSERT(OK,1,"[T005][parse]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T005][mode]")
	DO SLURP(.REQ,.OUT)
	DO EQ^MIOTASSERT(OUT,"Wikipedia","[T005][body]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T006 ; Chunked invalid size -> error includes routine
	NEW CONF,REQ,ERR,DEV,PATH,TXT
	KILL CONF,REQ,ERR
	SET PATH=$$TMPPATH("t006")
	SET TXT="POST /c HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Transfer-Encoding: chunked"_$C(13,10)_$C(13,10)
	SET TXT=TXT_"Z"_$C(13,10)_"oops"_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t006"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T006][parse fails]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"bad_chunk_size","[T006][err]")
	DO EQ^MIOTASSERT($GET(ERR("routine")),"MIOHTTP","[T006][routine]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T007 ; Invalid Content-Length
	NEW CONF,REQ,ERR,DEV,PATH,TXT
	KILL CONF,REQ,ERR
	SET PATH=$$TMPPATH("t007")
	SET TXT="POST /x HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Content-Length: abc"_$C(13,10)_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t007"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T007][parse fails]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"invalid_content_length","[T007][err]")
	DO EQ^MIOTASSERT($GET(ERR("routine")),"MIOHTTP","[T007][routine]")
	QUIT
	;
T008 ; Payload too large (Content-Length > maxBodyBytes)
	NEW CONF,REQ,ERR,DEV,PATH,TXT,B
	KILL CONF,REQ,ERR
	SET CONF("server","limits","maxBodyBytes")=10
	SET PATH=$$TMPPATH("t008")
	SET B="01234567890" ; 11 bytes
	SET TXT="POST /x HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Content-Length: "_$L(B)_$C(13,10)_$C(13,10)
	SET TXT=TXT_B
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t008"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T008][parse fails]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"payload_too_large","[T008][err]")
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),413,"[T008][status]")
	QUIT
	;
T009 ; Short read
	NEW CONF,REQ,ERR,DEV,PATH,TXT,B
	KILL CONF,REQ,ERR
	SET PATH=$$TMPPATH("t009")
	SET B="abc" ; 3 bytes
	SET TXT="POST /x HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Content-Length: 5"_$C(13,10)_$C(13,10)
	SET TXT=TXT_B
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t009"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T009][parse fails]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"short_read","[T009][err]")
	DO EQ^MIOTASSERT($GET(ERR("routine")),"MIOHTTP","[T009][routine]")
	QUIT
	;
T010 ; Iterator behavior
	NEW CONF,REQ,ERR,DEV,PATH,TXT,B,CUR,CH,COUNT
	KILL CONF,REQ,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=16
	; Force small chunks so this test is deterministic
	SET CONF("server","http","readBodyChunkBytes")=10
	SET PATH=$$TMPPATH("t010")
	SET B="abcdefghijklmnopqrstuvwxyz0123456789"
	SET TXT="POST /big HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Content-Length: "_$L(B)_$C(13,10)_$C(13,10)
	SET TXT=TXT_B
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t010"
	NEW OK SET OK=$$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	IF 'OK,DEBUG DO DUMPERR("T010",PATH,.ERR,.REQ)
	DO EQ^MIOTASSERT(OK,1,"[T010][parse]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T010][mode]")
	SET COUNT=0
	DO BODYOPEN^MIOHTTP(.REQ,.CUR)
	FOR  QUIT:'$$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH)  DO
	. SET COUNT=COUNT+1
	. DO OK^MIOTASSERT($L(CH)>0,"[T010][chunk non-empty]")
	IF '(COUNT>1),DEBUG DO DUMPERR("T010-multi",PATH,.ERR,.REQ)
	DO OK^MIOTASSERT(COUNT>1,"[T010][multiple chunks]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
T011 ; Query decode: '+' and %XX
	NEW CONF,REQ,ERR,DEV,PATH,TXT
	KILL CONF,REQ,ERR
	SET PATH=$$TMPPATH("t011")
	SET TXT="GET /q?x=a+b&y=%2B&z=%26&empty=&noval HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t011"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T011][parse]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("query","x")),"a b","[T011][x]")
	DO EQ^MIOTASSERT($GET(REQ("query","y")),"+","[T011][y]")
	DO EQ^MIOTASSERT($GET(REQ("query","z")),"&","[T011][z]")
	DO EQ^MIOTASSERT($DATA(REQ("query","empty"))>0,1,"[T011][empty present]")
	DO EQ^MIOTASSERT($GET(REQ("query","empty")),"","[T011][empty value]")
	DO EQ^MIOTASSERT($DATA(REQ("query","noval"))>0,1,"[T011][noval present]")
	DO EQ^MIOTASSERT($GET(REQ("query","noval")),"","[T011][noval value]")
	QUIT
	;
T012 ; Request line too large
	NEW CONF,REQ,ERR,DEV,PATH,TXT
	KILL CONF,REQ,ERR
	SET CONF("server","limits","maxRequestLineBytes")=20
	SET PATH=$$TMPPATH("t012")
	SET TXT="GET /this/is/too/long HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t012"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T012][parse fails]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"request_line_too_large","[T012][err]")
	DO EQ^MIOTASSERT($GET(ERR("routine")),"MIOHTTP","[T012][routine]")
	QUIT
	;
T013 ; Headers too large (maxHeaderBytes)
	NEW CONF,REQ,ERR,DEV,PATH,TXT
	KILL CONF,REQ,ERR
	SET CONF("server","limits","maxHeaderBytes")=20
	SET PATH=$$TMPPATH("t013")
	SET TXT="GET /h HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"X: 12345678901234567890"_$C(13,10)_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t013"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T013][parse fails]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"headers_too_large","[T013][err]")
	QUIT
	;
T014 ; Too many headers
	NEW CONF,REQ,ERR,DEV,PATH,TXT
	KILL CONF,REQ,ERR
	SET CONF("server","limits","maxHeaderCount")=1
	SET PATH=$$TMPPATH("t014")
	SET TXT="GET /h HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"X: 1"_$C(13,10)_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t014"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T014][parse fails]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"too_many_headers","[T014][err]")
	QUIT
	;
T015 ; Header folding rejected
	NEW CONF,REQ,ERR,DEV,PATH,TXT
	KILL CONF,REQ,ERR
	SET PATH=$$TMPPATH("t015")
	SET TXT="GET /h HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"X: a"_$C(13,10)_$C(9)_"b"_$C(13,10)_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t015"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T015][parse fails]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"header_folding_rejected","[T015][err]")
	QUIT
	;
T016 ; Invalid content-length
	NEW CONF,REQ,ERR,DEV,PATH,TXT
	KILL CONF,REQ,ERR
	SET PATH=$$TMPPATH("t016")
	SET TXT="POST /cl HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Content-Length: abc"_$C(13,10)_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t016"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T016][parse fails]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"invalid_content_length","[T016][err]")
	QUIT
	;
T017 ; Payload too large (Content-Length)
	NEW CONF,REQ,ERR,DEV,PATH,TXT,B
	KILL CONF,REQ,ERR
	SET CONF("server","limits","maxBodyBytes")=5
	SET PATH=$$TMPPATH("t017")
	SET B="hello=world"
	SET TXT="POST /big HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Content-Length: "_$L(B)_$C(13,10)_$C(13,10)_B
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t017"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T017][parse fails]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"payload_too_large","[T017][err]")
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),413,"[T017][status]")
	QUIT
	;
T018 ; Unsupported Transfer-Encoding token
	NEW CONF,REQ,ERR,DEV,PATH,TXT
	KILL CONF,REQ,ERR
	SET PATH=$$TMPPATH("t018")
	SET TXT="POST /te HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Transfer-Encoding: gzip"_$C(13,10)_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t018"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T018][parse fails]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"unsupported_transfer_encoding","[T018][err]")
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),501,"[T018][status]")
	QUIT
	;
T019 ; Chunked not supported flag
	NEW CONF,REQ,ERR,DEV,PATH,TXT
	KILL CONF,REQ,ERR
	SET CONF("server","http","supportChunkedRequest")=0
	SET PATH=$$TMPPATH("t019")
	SET TXT="POST /c HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Transfer-Encoding: chunked"_$C(13,10)_$C(13,10)
	SET TXT=TXT_"4"_$C(13,10)_"Wiki"_$C(13,10)_"0"_$C(13,10)_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t019"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),0,"[T019][parse fails]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"chunked_not_supported","[T019][err]")
	QUIT
	;
T020 ; Chunked with extensions -> Wikipedia
	NEW CONF,REQ,ERR,DEV,PATH,TXT,OUT
	KILL CONF,REQ,ERR
	SET PATH=$$TMPPATH("t020")
	SET TXT="POST /c HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Transfer-Encoding: chunked"_$C(13,10)_$C(13,10)
	SET TXT=TXT_"4;foo=bar"_$C(13,10)_"Wiki"_$C(13,10)
	SET TXT=TXT_"5;bar=baz"_$C(13,10)_"pedia"_$C(13,10)
	SET TXT=TXT_"0"_$C(13,10)_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t020"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T020][parse]")
	DO CLOSER(DEV)
	DO SLURP(.REQ,.OUT)
	DO EQ^MIOTASSERT(OUT,"Wikipedia","[T020][body]")
	QUIT
	;
T021 ; Chunked uppercase hex + trailer headers
	NEW CONF,REQ,ERR,DEV,PATH,TXT,OUT
	KILL CONF,REQ,ERR
	SET PATH=$$TMPPATH("t021")
	SET TXT="POST /c HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Transfer-Encoding: chunked"_$C(13,10)_$C(13,10)
	SET TXT=TXT_"A"_$C(13,10)_"0123456789"_$C(13,10)
	SET TXT=TXT_"0"_$C(13,10)_"Foo: bar"_$C(13,10)_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t021"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T021][parse]")
	DO CLOSER(DEV)
	DO SLURP(.REQ,.OUT)
	DO EQ^MIOTASSERT(OUT,"0123456789","[T021][body]")
	QUIT
	;
T022 ; Fixed-length upgrade boundary (CL > maxBodyScalarBytes)
	NEW CONF,REQ,ERR,DEV,PATH,TXT,B,OUT
	KILL CONF,REQ,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=8
	SET PATH=$$TMPPATH("t022")
	SET B="Wikipedia"
	SET TXT="POST /cl HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Content-Length: "_$L(B)_$C(13,10)_$C(13,10)_B
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t022"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T022][parse]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T022][mode]")
	DO SLURP(.REQ,.OUT)
	DO EQ^MIOTASSERT(OUT,"Wikipedia","[T022][body]")
	QUIT
	;
T023 ; Global mode has no scalar value at REQ("body")
	NEW CONF,REQ,ERR,DEV,PATH,TXT,B
	KILL CONF,REQ,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=1
	SET PATH=$$TMPPATH("t023")
	SET B="abcd"
	SET TXT="POST /cl HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Content-Length: "_$L(B)_$C(13,10)_$C(13,10)_B
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t023"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T023][parse]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T023][mode]")
	DO EQ^MIOTASSERT(($DATA(REQ("body"))#2),0,"[T023][no scalar body]")
	QUIT
	;
T024 ; Multiple chunks in global store (readBodyChunkBytes)
	NEW CONF,REQ,ERR,DEV,PATH,TXT,B,OUT
	KILL CONF,REQ,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=1
	SET CONF("server","http","readBodyChunkBytes")=3
	SET PATH=$$TMPPATH("t024")
	SET B="abcdefghi"
	SET TXT="POST /cl HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Content-Length: "_$L(B)_$C(13,10)_$C(13,10)_B
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t024"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T024][parse]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","n"))>1,1,"[T024][n>1]")
	DO SLURP(.REQ,.OUT)
	DO EQ^MIOTASSERT(OUT,B,"[T024][slurp]")
	QUIT
	;
T025 ; BODYFREE clears global store
	NEW CONF,REQ,ERR,DEV,PATH,TXT,B,REF
	KILL CONF,REQ,ERR
	SET CONF("server","limits","maxBodyScalarBytes")=1
	SET PATH=$$TMPPATH("t025")
	SET B="abcdef"
	SET TXT="POST /cl HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Content-Length: "_$L(B)_$C(13,10)_$C(13,10)_B
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="t025"
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T025][parse]")
	DO CLOSER(DEV)
	SET REF=$GET(REQ("body","ref"))
	DO BODYFREE^MIOHTTP(.REQ)
	IF REF'="" DO EQ^MIOTASSERT($DATA(@REF),0,"[T025][ref killed]")
	DO EQ^MIOTASSERT($DATA(REQ("body")),0,"[T025][req body cleared]")
	QUIT
	;
	;
DUMPERR(TAG,PATH,ERR,REQ)
	; Print debug info for a failing parse (guarded by DEBUG in caller).;
	USE $PRINCIPAL
	WRITE "DBG ",TAG," file=",$GET(PATH),!
	IF $DATA(ERR) ZWRITE ERR
	IF $DATA(REQ) ZWRITE REQ ;("hdr"),REQ("body","mode"),REQ("body","len")
	QUIT
	;