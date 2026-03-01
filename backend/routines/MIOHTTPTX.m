MIOHTTPTX ; Extended MIOHTTP test suite (enterprise edge cases)
 ;
 ; Run:
 ;   YDB>ZL "MIOHTTP.m","MIOHTTPT.m","MIOHTTPTX.m","MIOTASSERT.m","MIOSOCK.m"
 ;   YDB>D ^MIOHTTPT
 ;   YDB>D ^MIOHTTPTX
 ;
 ; Notes
 ; - Uses files as the "socket" device.
 ; - Prints only FAIL lines.
 ;
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
