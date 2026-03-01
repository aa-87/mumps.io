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
	DO T001 ZWR:$D(ERR) ERR 
	DO T002 ZWR:$D(ERR) ERR
	DO T003 ZWR:$D(ERR) ERR
	DO T004 ZWR:$D(ERR) ERR
	DO T005 ZWR:$D(ERR) ERR
	DO T006 ZWR:$D(ERR) ERR
	DO T007 ZWR:$D(ERR) ERR
	DO T008 ZWR:$D(ERR) ERR
	DO T009 ZWR:$D(ERR) ERR
	DO T010 ZWR:$D(ERR) ERR
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
	NEW CONF,REQ,DEV,PATH,TXT
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
	NEW CONF,REQ,DEV,PATH,TXT,B
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
	NEW CONF,REQ,DEV,PATH,TXT,B,OUT
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
	NEW CONF,REQ,DEV,PATH,TXT,OUT
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
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T004][parse]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"scalar","[T004][mode]")
	DO SLURP(.REQ,.OUT)
	DO EQ^MIOTASSERT(OUT,"Wikipedia","[T004][body]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T005 ; Chunked triggers upgrade -> global
	NEW CONF,REQ,DEV,PATH,TXT,OUT
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
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T005][parse]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T005][mode]")
	DO SLURP(.REQ,.OUT)
	DO EQ^MIOTASSERT(OUT,"Wikipedia","[T005][body]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;
T006 ; Chunked invalid size -> error includes routine
	NEW CONF,REQ,DEV,PATH,TXT
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
	NEW CONF,REQ,DEV,PATH,TXT
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
	NEW CONF,REQ,DEV,PATH,TXT,B
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
	NEW CONF,REQ,DEV,PATH,TXT,B
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
	NEW CONF,REQ,DEV,PATH,TXT,B,CUR,CH,COUNT
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
	DO EQ^MIOTASSERT($$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR),1,"[T010][parse]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(REQ("body","mode")),"global","[T010][mode]")
	SET COUNT=0
	DO BODYOPEN^MIOHTTP(.REQ,.CUR)
	FOR  QUIT:'$$BODYNEXT^MIOHTTP(.REQ,.CUR,.CH)  DO
	. SET COUNT=COUNT+1
	. DO OK^MIOTASSERT($L(CH)>0,"[T010][chunk non-empty]")
	DO OK^MIOTASSERT(COUNT>1,"[T010][multiple chunks]")
	DO BODYFREE^MIOHTTP(.REQ)
	QUIT
	;