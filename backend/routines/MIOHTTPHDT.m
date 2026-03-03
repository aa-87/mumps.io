MIOHTTPHDT ; MIOHTTP hardening tests (request smuggling defenses)
;
; Run:
;   YDB>ZL "MIOHTTP.m","MIOHTTPHDT.m","MIOTASSERT.m","MIOSOCK.m"
;   YDB>D ^MIOHTTPHDT
;
; Notes
; - Uses files as the "socket" device (like MIOHTTPT).
; - Quiet on success; prints only FAIL lines.
;
	NEW DEBUG SET DEBUG=$GET(^MIO("CONF","test","debug"),0)
	DO T001
	DO T002
	DO T003
	DO T004
	DO T005
	DO T006
	DO T007
	DO T008
	QUIT
	;
; ---------------- helpers ----------------
	;
TMPPATH(NAME)
	QUIT "tmp/miohttphdt_"_NAME_"_"_$J_"_"_$P($H,",",2)_".req"
	;
WRFILE(PATH,TXT)
	NEW DEV SET DEV=PATH
	OPEN DEV:(new:stream:nowrap):1 ELSE  QUIT
	USE DEV WRITE TXT
	CLOSE DEV
	QUIT
	;
OPENR(PATH)
	NEW DEV SET DEV=PATH
	OPEN DEV:(readonly:stream):1 ELSE  QUIT ""
	USE DEV:(delim=$C(13,10))
	QUIT DEV
	;
CLOSER(DEV)
	IF $GET(DEV)'="" CLOSE DEV
	QUIT
	;
DUMPERR(TAG,PATH,ERR,REQ)
	; Only called when DEBUG=1 and the test failed.
	W "\n[DEBUG] ",TAG," file=",PATH,"\n"
	ZWR ERR,REQ
	QUIT
	;
; ---------------- tests ----------------
	;
T001 ; TE:chunked + Content-Length => te_cl_conflict
	NEW CONF,REQ,ERR,DEV,PATH,TXT
	KILL CONF,REQ,ERR
	SET PATH=$$TMPPATH("t001")
	SET TXT="POST /x HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Transfer-Encoding: chunked"_$C(13,10)
	SET TXT=TXT_"Content-Length: 5"_$C(13,10)_$C(13,10)
	SET TXT=TXT_"0"_$C(13,10)_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="hdt001"
	NEW OK SET OK=$$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	IF OK,DEBUG DO DUMPERR("T001(unexpected ok)",PATH,.ERR,.REQ)
	DO EQ^MIOTASSERT(OK,0,"[T001][parse fails]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"te_cl_conflict","[T001][err]")
	DO EQ^MIOTASSERT($GET(ERR("routine")),"MIOHTTP","[T001][routine]")
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),400,"[T001][status]")
	QUIT
	;
T002 ; Duplicate Content-Length => duplicate_content_length
	NEW CONF,REQ,ERR,DEV,PATH,TXT
	KILL CONF,REQ,ERR
	SET PATH=$$TMPPATH("t002")
	SET TXT="POST /x HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Content-Length: 1"_$C(13,10)
	SET TXT=TXT_"Content-Length: 1"_$C(13,10)_$C(13,10)
	SET TXT=TXT_"A"
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="hdt002"
	NEW OK SET OK=$$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	IF OK,DEBUG DO DUMPERR("T002(unexpected ok)",PATH,.ERR,.REQ)
	DO EQ^MIOTASSERT(OK,0,"[T002][parse fails]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"duplicate_content_length","[T002][err]")
	DO EQ^MIOTASSERT($GET(ERR("routine")),"MIOHTTP","[T002][routine]")
	QUIT
	;
T003 ; Duplicate Transfer-Encoding => duplicate_transfer_encoding
	NEW CONF,REQ,ERR,DEV,PATH,TXT
	KILL CONF,REQ,ERR
	SET PATH=$$TMPPATH("t003")
	SET TXT="POST /c HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Transfer-Encoding: chunked"_$C(13,10)
	SET TXT=TXT_"Transfer-Encoding: chunked"_$C(13,10)_$C(13,10)
	SET TXT=TXT_"0"_$C(13,10)_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="hdt003"
	NEW OK SET OK=$$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	IF OK,DEBUG DO DUMPERR("T003(unexpected ok)",PATH,.ERR,.REQ)
	DO EQ^MIOTASSERT(OK,0,"[T003][parse fails]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"duplicate_transfer_encoding","[T003][err]")
	DO EQ^MIOTASSERT($GET(ERR("routine")),"MIOHTTP","[T003][routine]")
	QUIT
	;
T004 ; obs-fold rejection
	NEW CONF,REQ,ERR,DEV,PATH,TXT
	KILL CONF,REQ,ERR
	SET PATH=$$TMPPATH("t004")
	SET TXT="GET / HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"X-Test: a"_$C(13,10)
	SET TXT=TXT_" b"_$C(13,10)_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="hdt004"
	NEW OK SET OK=$$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	IF OK,DEBUG DO DUMPERR("T004(unexpected ok)",PATH,.ERR,.REQ)
	DO EQ^MIOTASSERT(OK,0,"[T004][parse fails]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"header_folding_rejected","[T004][err]")
	DO EQ^MIOTASSERT($GET(ERR("routine")),"MIOHTTP","[T004][routine]")
	QUIT
	;
T005 ; header line too large
	NEW CONF,REQ,ERR,DEV,PATH,TXT
	KILL CONF,REQ,ERR
	SET CONF("server","limits","maxHeaderLineBytes")=20
	SET PATH=$$TMPPATH("t005")
	SET TXT="GET / HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	; length intentionally > 20
	SET TXT=TXT_"X-Long: 1234567890123456789012345"_$C(13,10)_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="hdt005"
	NEW OK SET OK=$$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	IF OK,DEBUG DO DUMPERR("T005(unexpected ok)",PATH,.ERR,.REQ)
	DO EQ^MIOTASSERT(OK,0,"[T005][parse fails]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"header_line_too_large","[T005][err]")
	DO EQ^MIOTASSERT($$STATUS4ERR^MIOHTTP(.ERR),431,"[T005][status]")
	QUIT
	;
T006 ; bad header line (missing ':')
	NEW CONF,REQ,ERR,DEV,PATH,TXT
	KILL CONF,REQ,ERR
	SET PATH=$$TMPPATH("t006")
	SET TXT="GET / HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"BadHeader"_$C(13,10)_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="hdt006"
	NEW OK SET OK=$$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	IF OK,DEBUG DO DUMPERR("T006(unexpected ok)",PATH,.ERR,.REQ)
	DO EQ^MIOTASSERT(OK,0,"[T006][parse fails]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"bad_header_line","[T006][err]")
	DO EQ^MIOTASSERT($GET(ERR("routine")),"MIOHTTP","[T006][routine]")
	QUIT
	;
T007 ; invalid header name token
	NEW CONF,REQ,ERR,DEV,PATH,TXT
	KILL CONF,REQ,ERR
	SET PATH=$$TMPPATH("t007")
	SET TXT="GET / HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Bad@Name: x"_$C(13,10)_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="hdt007"
	NEW OK SET OK=$$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	IF OK,DEBUG DO DUMPERR("T007(unexpected ok)",PATH,.ERR,.REQ)
	DO EQ^MIOTASSERT(OK,0,"[T007][parse fails]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"invalid_header_name","[T007][err]")
	DO EQ^MIOTASSERT($GET(ERR("routine")),"MIOHTTP","[T007][routine]")
	QUIT
	;
T008 ; TE order: chunked must be last when strictTE=1 (default)
	NEW CONF,REQ,ERR,DEV,PATH,TXT
	KILL CONF,REQ,ERR
	SET PATH=$$TMPPATH("t008")
	SET TXT="POST /c HTTP/1.1"_$C(13,10)
	SET TXT=TXT_"Host: example"_$C(13,10)
	SET TXT=TXT_"Transfer-Encoding: chunked, identity"_$C(13,10)_$C(13,10)
	SET TXT=TXT_"0"_$C(13,10)_$C(13,10)
	DO WRFILE(PATH,TXT)
	SET DEV=$$OPENR(PATH)
	SET REQ("id")="hdt008"
	NEW OK SET OK=$$PARSE^MIOHTTP(DEV,.CONF,.REQ,.ERR)
	IF OK,DEBUG DO DUMPERR("T008(unexpected ok)",PATH,.ERR,.REQ)
	DO EQ^MIOTASSERT(OK,0,"[T008][parse fails]")
	DO CLOSER(DEV)
	DO EQ^MIOTASSERT($GET(ERR("error")),"bad_transfer_encoding_order","[T008][err]")
	DO EQ^MIOTASSERT($GET(ERR("routine")),"MIOHTTP","[T008][routine]")
	QUIT
