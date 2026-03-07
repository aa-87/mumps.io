MIOHTTPMPUTT ; Multipart streaming tests (ROI + production cases)
	;
	; Run:
	;   YDB>ZL "MIOHTTP.m","MIOHTTPMPU.m","MIOHTTPMPUTT.m","MIOTASSERT.m"
	;   YDB>D ^MIOHTTPMPUTT
	;
	NEW DBG SET DBG=+$GET(^MIO("CONF","test","debug"))
	DO T001(DBG)
	DO T002(DBG)
	DO T003(DBG)
	DO T004(DBG)
	DO T005(DBG)
	DO T006(DBG)
	DO T007(DBG)
	DO T008(DBG)
	DO T009(DBG)
	DO T010(DBG)
	DO T011(DBG)
	DO T012(DBG)
	DO T013(DBG)
	NEW CONF,REQ,ERR,MP,OUTER,INNER,CRLF,CT,OK,DATA1,DATA2,SUB
	KILL CONF,ERR,MP,SUB
	SET CONF("server","multipart","enableNested")=1
	SET CRLF=$$CRLF()
	SET DATA1="one",DATA2="two"
	; inner multipart/mixed
	SET INNER="--inb"_CRLF
	SET INNER=INNER_"Content-Disposition: attachment; filename=""a.txt"""_CRLF_CRLF_DATA1_CRLF
	SET INNER=INNER_"--inb"_CRLF
	SET INNER=INNER_"Content-Disposition: attachment; filename=""b.txt"""_CRLF_CRLF_DATA2_CRLF
	SET INNER=INNER_"--inb--"_CRLF
	; outer multipart/form-data with one part holding inner
	SET OUTER="--outb"_CRLF
	SET OUTER=OUTER_"Content-Disposition: form-data; name=""mix"""_CRLF
	SET OUTER=OUTER_"Content-Type: multipart/mixed; boundary=inb"_CRLF_CRLF
	SET OUTER=OUTER_INNER
	SET OUTER=OUTER_"--outb--"_CRLF
	SET CT="multipart/form-data; boundary=outb"
	DO SETREQ(.REQ,"T013",CT,"scalar",OUTER,0)
	SET OK=$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR)
	IF 'OK DO FAILDBG(DBG,"T013",.ERR,.MP,.REQ)
	DO EQ^MIOTASSERT(OK,1,"[T013][parse mp]")
	; bring nested result into SUB for safe calls/refs
	MERGE SUB=MP("part",1,"sub")
	IF DBG,$GET(SUB("error"))'="" USE $PRINCIPAL WRITE "DBG T013 sub error=",SUB("error")," routine=",SUB("routine"),!
	DO EQ^MIOTASSERT($GET(SUB("parts")),2,"[T013][sub parts]")
	DO EQ^MIOTASSERT($GET(SUB("part",1,"filename")),"a.txt","[T013][sub a filename]")
	DO EQ^MIOTASSERT($$PARTSLURP^MIOHTTPMPU(.SUB,1,.CONF),DATA1,"[T013][sub a data]")
	DO EQ^MIOTASSERT($GET(SUB("part",2,"filename")),"b.txt","[T013][sub b filename]")
	DO EQ^MIOTASSERT($$PARTSLURP^MIOHTTPMPU(.SUB,2,.CONF),DATA2,"[T013][sub b data]")
	DO FREE^MIOHTTPMPU(.MP)
	QUIT
	;
CRLF() QUIT $C(13,10)
	;
SETREQ(REQ,ID,CT,MODE,BODY,CHSZ) ;
	KILL REQ
	SET REQ("id")=ID
	SET REQ("method")="POST"
	SET REQ("path")="/u"
	SET REQ("hdr","content-type")=CT
	KILL REQ("body")
	IF $GET(MODE,"scalar")="scalar" DO  QUIT
	. SET REQ("body","mode")="scalar"
	. SET REQ("body")=BODY
	. SET REQ("body","len")=$L(BODY)
	;
	NEW REF SET REF=$NA(^TMP($J,"MIOHTTP","BODY",ID))
	KILL @REF
	SET REQ("body","mode")="global"
	SET REQ("body","ref")=REF
	SET REQ("body","n")=0
	SET REQ("body","len")=0
	NEW OFF,N,PIECE
	SET CHSZ=+$GET(CHSZ,17) IF CHSZ<1 SET CHSZ=17
	SET OFF=1,N=0
	FOR  QUIT:OFF>$L(BODY)  DO
	. SET PIECE=$E(BODY,OFF,OFF+CHSZ-1)
	. SET OFF=OFF+CHSZ
	. SET N=N+1
	. SET @REF@(N)=PIECE
	. SET REQ("body","len")=REQ("body","len")+$L(PIECE)
	SET REQ("body","n")=N
	QUIT
	;
MPSLURP(MP,IDX,OUT,CONF)
	NEW CUR,CH
	SET OUT=""
	DO PARTOPEN^MIOHTTPMPU(.MP,IDX,.CUR,.CONF)
	FOR  QUIT:'$$PARTNEXT^MIOHTTPMPU(.MP,IDX,.CUR,.CH)  SET OUT=OUT_CH
	DO ITCLOSE^MIOHTTPMPU(.CUR)
	QUIT
	;
FAILDBG(DBG,TAG,ERR,MP,REQ)
	IF 'DBG QUIT
	USE $PRINCIPAL
	WRITE "DBG ",TAG," FAIL",!
	ZWRITE ERR
	ZWRITE MP
	WRITE "DBG REQ body.mode=",$GET(REQ("body","mode"))," len=",$GET(REQ("body","len")),!
	IF $GET(REQ("body","mode"))="scalar" WRITE "DBG REQ body head=",$EXTRACT($GET(REQ("body")),1,140),!
	IF $GET(REQ("body","mode"))="global" WRITE "DBG REQ body ref=",$GET(REQ("body","ref"))," n=",$GET(REQ("body","n")),!
	QUIT
	;
READFILE(PATH,OUT)
	SET OUT=""
	NEW DEV SET DEV=PATH
	OPEN DEV:(readonly:stream:nowrap)
	USE DEV
	NEW X
	FOR  READ X#16384  QUIT:$ZEOF  SET OUT=OUT_X
	CLOSE DEV
	QUIT
	;
T001(DBG)
	NEW CONF,REQ,ERR,MP,B,CRLF,BODY,CT,OK
	KILL CONF,ERR,MP
	SET CRLF=$$CRLF(),B="bnd1"
	SET BODY="--"_B_CRLF
	SET BODY=BODY_"Content-Disposition: form-data; name=""a"""_CRLF_CRLF_"1"_CRLF
	SET BODY=BODY_"--"_B_CRLF
	SET BODY=BODY_"Content-Disposition: form-data; name=""b"""_CRLF_CRLF_"two"_CRLF
	SET BODY=BODY_"--"_B_"--"_CRLF
	SET CT="multipart/form-data; boundary="_B
	DO SETREQ(.REQ,"T001",CT,"scalar",BODY,0)
	SET OK=$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR)
	IF 'OK DO FAILDBG(DBG,"T001",.ERR,.MP,.REQ)
	DO EQ^MIOTASSERT(OK,1,"[T001][parse mp]")
	DO EQ^MIOTASSERT($GET(MP("parts")),2,"[T001][parts]")
	DO EQ^MIOTASSERT($GET(MP("field","a")),"1","[T001][a]")
	DO EQ^MIOTASSERT($GET(MP("field","b")),"two","[T001][b]")
	DO FREE^MIOHTTPMPU(.MP)
	QUIT
	;
T002(DBG)
	NEW CONF,REQ,ERR,MP,B,CRLF,BODY,CT,OK,OUT
	KILL CONF,ERR,MP
	SET CRLF=$$CRLF(),B="bnd2"
	SET BODY="--"_B_CRLF
	SET BODY=BODY_"Content-Disposition: form-data; name=""file""; filename=""a.txt"""_CRLF
	SET BODY=BODY_"Content-Type: text/plain"_CRLF_CRLF_"hello"_CRLF
	SET BODY=BODY_"--"_B_"--"_CRLF
	SET CT="multipart/form-data; boundary="_B
	DO SETREQ(.REQ,"T002",CT,"scalar",BODY,0)
	SET OK=$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR)
	IF 'OK DO FAILDBG(DBG,"T002",.ERR,.MP,.REQ)
	DO EQ^MIOTASSERT(OK,1,"[T002][parse mp]")
	DO EQ^MIOTASSERT($GET(MP("part",1,"filename")),"a.txt","[T002][filename]")
	DO MPSLURP(.MP,1,.OUT,.CONF)
	DO EQ^MIOTASSERT(OUT,"hello","[T002][data]")
	DO FREE^MIOHTTPMPU(.MP)
	QUIT
	;
T003(DBG)
	NEW CONF,REQ,ERR,MP,B,CRLF,BODY,CT,OK,OUT
	KILL CONF,ERR,MP
	SET CONF("server","limits","maxMultipartPartScalarBytes")=8
	SET CRLF=$$CRLF(),B="bnd3"
	SET BODY="--"_B_CRLF
	SET BODY=BODY_"Content-Disposition: form-data; name=""x"""_CRLF_CRLF_"Wikipedia"_CRLF
	SET BODY=BODY_"--"_B_"--"_CRLF
	SET CT="multipart/form-data; boundary="_B
	DO SETREQ(.REQ,"T003",CT,"scalar",BODY,0)
	SET OK=$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR)
	IF 'OK DO FAILDBG(DBG,"T003",.ERR,.MP,.REQ)
	DO EQ^MIOTASSERT(OK,1,"[T003][parse mp]")
	DO EQ^MIOTASSERT($GET(MP("part",1,"mode")),"global","[T003][mode]")
	DO MPSLURP(.MP,1,.OUT,.CONF)
	DO EQ^MIOTASSERT(OUT,"Wikipedia","[T003][data]")
	DO FREE^MIOHTTPMPU(.MP)
	QUIT
	;
T004(DBG)
	NEW CONF,REQ,ERR,MP,B,CRLF,BODY,CT,OK
	KILL CONF,ERR,MP
	SET CRLF=$$CRLF(),B="bnd4"
	SET BODY="--"_B_CRLF_"Content-Disposition: form-data; name=""a"""_CRLF_CRLF_"1"_CRLF_"--"_B_"--"_CRLF
	SET CT="multipart/form-data; boundary="""_B_""""
	DO SETREQ(.REQ,"T004",CT,"scalar",BODY,0)
	SET OK=$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR)
	IF 'OK DO FAILDBG(DBG,"T004",.ERR,.MP,.REQ)
	DO EQ^MIOTASSERT(OK,1,"[T004][parse mp]")
	DO EQ^MIOTASSERT($GET(MP("field","a")),"1","[T004][a]")
	DO FREE^MIOHTTPMPU(.MP)
	QUIT
	;
T005(DBG)
	NEW CONF,REQ,ERR,MP,CT,OK
	KILL CONF,ERR,MP
	SET CT="multipart/form-data"
	DO SETREQ(.REQ,"T005",CT,"scalar","",0)
	SET OK=$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR)
	DO EQ^MIOTASSERT(OK,0,"[T005][parse mp fails]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"missing_boundary","[T005][err]")
	QUIT
	;
T006(DBG)
	NEW CONF,REQ,ERR,MP,B,CRLF,BODY,CT,OK
	KILL CONF,ERR,MP
	SET CRLF=$$CRLF(),B="bnd6"
	SET BODY="--"_B_CRLF
	SET BODY=BODY_"Content-Disposition: form-data; name=""a"""_CRLF
	SET BODY=BODY_"X: 1"_CRLF_$C(9)_"fold"_CRLF_CRLF_"1"_CRLF
	SET BODY=BODY_"--"_B_"--"_CRLF
	SET CT="multipart/form-data; boundary="_B
	DO SETREQ(.REQ,"T006",CT,"scalar",BODY,0)
	SET OK=$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR)
	DO EQ^MIOTASSERT(OK,0,"[T006][parse mp fails]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"header_folding_rejected","[T006][err]")
	QUIT
	;
T007(DBG)
	NEW CONF,REQ,ERR,MP,B,CRLF,BODY,CT,OK
	KILL CONF,ERR,MP
	SET CONF("server","limits","maxMultipartParts")=1
	SET CRLF=$$CRLF(),B="bnd7"
	SET BODY="--"_B_CRLF_"Content-Disposition: form-data; name=""a"""_CRLF_CRLF_"1"_CRLF
	SET BODY=BODY_"--"_B_CRLF_"Content-Disposition: form-data; name=""b"""_CRLF_CRLF_"2"_CRLF
	SET BODY=BODY_"--"_B_"--"_CRLF
	SET CT="multipart/form-data; boundary="_B
	DO SETREQ(.REQ,"T007",CT,"scalar",BODY,0)
	SET OK=$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR)
	DO EQ^MIOTASSERT(OK,0,"[T007][parse mp fails]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"too_many_parts","[T007][err]")
	QUIT
	;
T008(DBG)
	NEW CONF,REQ,ERR,MP,B,CRLF,BODY,CT,OK
	KILL CONF,ERR,MP
	SET CRLF=$$CRLF(),B="bnd8"
	SET BODY="--"_B_CRLF_"Content-Disposition: form-data; name=""a"""_CRLF_CRLF_"1"_CRLF_"--"_B_"--"_CRLF
	SET CT="multipart/form-data; boundary="_B
	DO SETREQ(.REQ,"T008",CT,"global",BODY,7)
	SET OK=$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR)
	IF 'OK DO FAILDBG(DBG,"T008",.ERR,.MP,.REQ)
	DO EQ^MIOTASSERT(OK,1,"[T008][parse mp]")
	DO EQ^MIOTASSERT($GET(MP("field","a")),"1","[T008][a]")
	DO FREE^MIOHTTPMPU(.MP)
	QUIT
	;
T009(DBG)
	NEW CONF,REQ,ERR,MP,B,CRLF,BODY,CT,OK
	KILL CONF,ERR,MP
	SET CONF("server","limits","maxMultipartPartBytes")=3
	SET CRLF=$$CRLF(),B="bnd9"
	SET BODY="--"_B_CRLF_"Content-Disposition: form-data; name=""a"""_CRLF_CRLF_"abcd"_CRLF_"--"_B_"--"_CRLF
	SET CT="multipart/form-data; boundary="_B
	DO SETREQ(.REQ,"T009",CT,"scalar",BODY,0)
	SET OK=$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR)
	DO EQ^MIOTASSERT(OK,0,"[T009][parse mp fails]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"part_too_large","[T009][err]")
	QUIT
	;
T010(DBG)
	NEW CONF,REQ,ERR,MP,B,CRLF,BODY,CT,OK,DATA,OUT,P
	KILL CONF,ERR,MP
	SET CONF("server","limits","maxMultipartPartScalarBytes")=4
	SET CONF("server","multipart","maxMultipartSpoolBytes")=10
	SET CONF("server","multipart","spoolDir")="/tmp"
	SET CRLF=$$CRLF(),B="bnd10"
	SET DATA="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	SET BODY="--"_B_CRLF
	SET BODY=BODY_"Content-Disposition: form-data; name=""file""; filename=""big.bin"""_CRLF
	SET BODY=BODY_"Content-Type: application/octet-stream"_CRLF_CRLF_DATA_CRLF
	SET BODY=BODY_"--"_B_"--"_CRLF
	SET CT="multipart/form-data; boundary="_B
	DO SETREQ(.REQ,"T010",CT,"scalar",BODY,0)
	SET OK=$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR)
	IF 'OK DO FAILDBG(DBG,"T010",.ERR,.MP,.REQ)
	DO EQ^MIOTASSERT(OK,1,"[T010][parse mp]")
	DO EQ^MIOTASSERT($GET(MP("part",1,"mode")),"spool","[T010][mode]")
	SET P=$GET(MP("part",1,"path"))
	DO EQ^MIOTASSERT($SELECT(P'="":1,1:0),1,"[T010][path]")
	DO READFILE(P,.OUT)
	DO EQ^MIOTASSERT(OUT,DATA,"[T010][spooled data]")
	DO FREE^MIOHTTPMPU(.MP)
	QUIT
	;
T011(DBG)
	NEW CONF,REQ,ERR,MP,B,CRLF,BODY,CT,OK,DATA,OUT
	KILL CONF,ERR,MP
	SET CONF("server","multipart","zeroCopyFileParts")=1
	SET CRLF=$$CRLF(),B="bnd11"
	SET DATA="Wikipedia"
	SET BODY="--"_B_CRLF
	SET BODY=BODY_"Content-Disposition: form-data; name=""file""; filename=""a.txt"""_CRLF
	SET BODY=BODY_"Content-Type: text/plain"_CRLF_CRLF_DATA_CRLF
	SET BODY=BODY_"--"_B_"--"_CRLF
	SET CT="multipart/form-data; boundary="_B
	DO SETREQ(.REQ,"T011",CT,"global",BODY,5)
	SET OK=$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR)
	IF 'OK DO FAILDBG(DBG,"T011",.ERR,.MP,.REQ)
	DO EQ^MIOTASSERT(OK,1,"[T011][parse mp]")
	DO EQ^MIOTASSERT($GET(MP("part",1,"mode")),"zref","[T011][mode]")
	DO MPSLURP(.MP,1,.OUT,.CONF)
	DO EQ^MIOTASSERT(OUT,DATA,"[T011][zref data]")
	DO FREE^MIOHTTPMPU(.MP)
	QUIT
	;
T012(DBG)
	NEW CONF,REQ,ERR,MP,B,CRLF,BODY,CT,OK
	KILL CONF,ERR,MP
	SET CONF("server","multipart","allowTypes")="text/plain"
	SET CRLF=$$CRLF(),B="bnd12"
	SET BODY="--"_B_CRLF
	SET BODY=BODY_"Content-Disposition: form-data; name=""file""; filename=""a.bin"""_CRLF
	SET BODY=BODY_"Content-Type: application/octet-stream"_CRLF_CRLF_"x"_CRLF
	SET BODY=BODY_"--"_B_"--"_CRLF
	SET CT="multipart/form-data; boundary="_B
	DO SETREQ(.REQ,"T012",CT,"scalar",BODY,0)
	SET OK=$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR)
	DO EQ^MIOTASSERT(OK,0,"[T012][parse mp fails]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"disallowed_content_type","[T012][err]")
	QUIT
	;
T013(DBG)
	NEW CONF,REQ,ERR,MP,OUTER,INNER,CRLF,CT,OK,DATA1,DATA2
	KILL CONF,ERR,MP
	SET CONF("server","multipart","enableNested")=1
	SET CRLF=$$CRLF()
	SET DATA1="one",DATA2="two"
	SET INNER="--inb"_CRLF
	SET INNER=INNER_"Content-Disposition: attachment; filename=""a.txt"""_CRLF_CRLF_DATA1_CRLF
	SET INNER=INNER_"--inb"_CRLF
	SET INNER=INNER_"Content-Disposition: attachment; filename=""b.txt"""_CRLF_CRLF_DATA2_CRLF
	SET INNER=INNER_"--inb--"_CRLF
	SET OUTER="--outb"_CRLF
	SET OUTER=OUTER_"Content-Disposition: form-data; name=""mix"""_CRLF
	SET OUTER=OUTER_"Content-Type: multipart/mixed; boundary=inb"_CRLF_CRLF
	SET OUTER=OUTER_INNER
	SET OUTER=OUTER_"--outb--"_CRLF
	SET CT="multipart/form-data; boundary=outb"
	DO SETREQ(.REQ,"T013",CT,"scalar",OUTER,0)
	SET OK=$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR)
	IF 'OK DO FAILDBG(DBG,"T013",.ERR,.MP,.REQ)
	DO EQ^MIOTASSERT(OK,1,"[T013][parse mp]")
	DO EQ^MIOTASSERT($GET(MP("part",1,"sub","parts")),2,"[T013][sub parts]")
	DO EQ^MIOTASSERT($GET(MP("part",1,"sub","part",1,"filename")),"a.txt","[T013][sub a filename]")
	N TT M TT=MP("part",1,"sub")
	DO EQ^MIOTASSERT($$PARTSLURP^MIOHTTPMPU(.TT,1,.CONF),DATA1,"[T013][sub a data]")
	DO EQ^MIOTASSERT($GET(MP("part",1,"sub","part",2,"filename")),"b.txt","[T013][sub b filename]")
	DO EQ^MIOTASSERT($$PARTSLURP^MIOHTTPMPU(.TT,2,.CONF),DATA2,"[T013][sub b data]")
	DO FREE^MIOHTTPMPU(.MP)
	QUIT
	;