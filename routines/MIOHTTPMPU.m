MIOHTTPMPU ; Multipart/form-data streaming parser (MAXSTRING-safe)
	;
	; MUMPS.IO - Multipart parser built on top of MIOHTTP request body model.;
	;
	; Goals
	; - Stream-safe: no MAXSTRING risk by default (scalar->global->spool).;
	; - High performance: single pass with a small rolling tail buffer.;
	; - Production hardening: reject header folding; configurable limits.;
	;
	; Linkage to MIOHTTP
	; - MIOHTTP fills REQ("hdr",...) and stores the request body in:
	;     Scalar: REQ("body"), REQ("body","mode")="scalar"
	;     Global: REQ("body","mode")="global", REQ("body","ref"), REQ("body","n")
	; - MIOHTTPMPU consumes only REQ("body",...) using internal iterators.;
	;
	; ROI features implemented
	; - Disk spooling for big file parts:
	;     CONF("server","multipart","spoolDir") default "/tmp"
	;     CONF("server","multipart","maxMultipartSpoolBytes") default 0 (disabled)
	; - Zero-copy part references (file parts, request body must be global):
	;     CONF("server","multipart","zeroCopyFileParts") default 0
	;     Stores MP("part",i,"mode")="zref", plus zref metadata.;
	; - Per-part content-type allowlist:
	;     CONF("server","multipart","allowTypes")="text/plain,image/*"
	;     or CONF("server","multipart","allow",type)=1
	; - Nested multipart/mixed (and other multipart/*):
	;     CONF("server","multipart","enableNested") default 0
	;     CONF("server","multipart","maxDepth") default 3
	;
	; Public
	;   $$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR) -> 1/0
	;   FREE^MIOHTTPMPU(.MP)
	;   PARTOPEN^MIOHTTPMPU(.MP,IDX,.CUR,.CONF)
	;   $$PARTNEXT^MIOHTTPMPU(.MP,IDX,.CUR,.CH) -> 1/0
	;   $$PARTSLURP^MIOHTTPMPU(.MP,IDX,.CONF) -> string (small parts)
	;
	Q
	;
PARSE(CONF,REQ,MP,ERR) ;
	QUIT $$PARSEDEP(.CONF,.REQ,.MP,.ERR,0)
	;
PARSEDEP(CONF,REQ,MP,ERR,DEP) ;
	KILL MP,ERR
	NEW RTN SET RTN="MIOHTTPMPU"
	;
	NEW CT SET CT=$GET(REQ("hdr","content-type"))
	IF CT="" DO  QUIT 0
	. DO SETERR(.ERR,RTN,"missing_content_type")
	;
	NEW BND IF '$$BOUNDARY(CT,.BND) DO  QUIT 0
	. DO SETERR(.ERR,RTN,"missing_boundary")
	;
	NEW MAXDEP SET MAXDEP=+$GET(CONF("server","multipart","maxDepth"),3)
	IF MAXDEP<0 SET MAXDEP=0
	IF DEP>MAXDEP DO  QUIT 0
	. DO SETERR(.ERR,RTN,"nested_too_deep")
	;
	NEW RID SET RID=$GET(REQ("id")) IF RID="" SET RID=$J
	SET MP("id")=RID
	SET MP("boundary")=BND
	SET MP("ok")=0
	SET MP("parts")=0
	;
	; Limits
	NEW MAXP SET MAXP=+$GET(CONF("server","limits","maxMultipartParts"),200) IF MAXP<1 SET MAXP=200
	NEW MAXH SET MAXH=+$GET(CONF("server","limits","maxMultipartHeaderBytes"),32768) IF MAXH<512 SET MAXH=32768
	NEW MAXPH SET MAXPH=+$GET(CONF("server","limits","maxMultipartHeaders"),80) IF MAXPH<8 SET MAXPH=80
	NEW MAXPART SET MAXPART=+$GET(CONF("server","limits","maxMultipartPartBytes"),0) ; 0 => unlimited
	NEW MAXSC SET MAXSC=+$GET(CONF("server","limits","maxMultipartPartScalarBytes"),10485760) IF MAXSC<1 SET MAXSC=10485760
	;
	; Spooling options
	NEW SPOOLMAX SET SPOOLMAX=+$GET(CONF("server","multipart","maxMultipartSpoolBytes"),0) ; 0 disabled
	NEW SPOOLDIR SET SPOOLDIR=$GET(CONF("server","multipart","spoolDir"),"/tmp")
	;
	; Zero-copy (file parts only)
	NEW ZCFILE SET ZCFILE=+$GET(CONF("server","multipart","zeroCopyFileParts"),0)
	;
	; Nested multipart
	NEW NEST SET NEST=+$GET(CONF("server","multipart","enableNested"),0)
	;
	NEW BD0 SET BD0="--"_BND
	NEW KEEP SET KEEP=$L(BD0)+32  ; tail to avoid split
	;
	; Body iterator over REQ("body",...)
	NEW CUR,CH,OK
	DO ITOPEN(.REQ,.CUR,.CONF)
	NEW BUF SET BUF=""
	NEW STATE SET STATE="preamble"
	NEW DONE SET DONE=0
	NEW ABS SET ABS=1  ; absolute 1-based offset of BUF(1) in underlying body stream
	;
	NEW PNUM SET PNUM=0
	NEW PN,PFN,PCT SET PN="",PFN="",PCT=""
	NEW HBYTES,HCOUNT SET HBYTES=0,HCOUNT=0
	;
	FOR  QUIT:DONE  DO  QUIT:$DATA(ERR("error"))
	. SET OK=$$ITNEXT(.REQ,.CUR,.CH,.CONF)
	. IF 'OK SET DONE=1
	. ELSE  SET BUF=BUF_CH
	. ; advance machine as far as possible
	. FOR  QUIT:$DATA(ERR("error"))  QUIT:$$STEP(.STATE,.BUF,.ABS,BD0,KEEP,.CONF,.REQ,.MP,.PNUM,.PN,.PFN,.PCT,.HBYTES,.HCOUNT,MAXP,MAXH,MAXPH,MAXPART,MAXSC,SPOOLMAX,SPOOLDIR,ZCFILE,NEST,DEP,.ERR,RTN)=0
	;
	; Close iterator resources
	DO ITCLOSE(.CUR)
	;
	IF $DATA(ERR("error")) DO FREE(.MP) QUIT 0
	IF $GET(MP("ok"))'=1 DO  DO FREE(.MP) QUIT 0
	. DO SETERR(.ERR,RTN,"incomplete_multipart")
	QUIT 1
	;
STEP(STATE,BUF,ABS,BD0,KEEP,CONF,REQ,MP,PNUM,PN,PFN,PCT,HBYTES,HCOUNT,MAXP,MAXH,MAXPH,MAXPART,MAXSC,SPOOLMAX,SPOOLDIR,ZCFILE,NEST,DEP,ERR,RTN) ;
	IF STATE="preamble" QUIT $$STEPPRE(.STATE,.BUF,.ABS,BD0,.MP,.ERR,RTN)
	IF STATE="headers"  QUIT $$STEPHDR(.STATE,.BUF,.ABS,.MP,.PN,.PFN,.PCT,.HBYTES,.HCOUNT,MAXH,MAXPH,.ERR,RTN)
	IF STATE="data"     QUIT $$STEPDATA(.STATE,.BUF,.ABS,BD0,KEEP,.CONF,.REQ,.MP,.PNUM,.PN,.PFN,.PCT,MAXP,MAXPART,MAXSC,SPOOLMAX,SPOOLDIR,ZCFILE,NEST,DEP,.ERR,RTN)
	QUIT 0
	;
; ---------- line + boundary helpers (LF tolerant; strips optional CR) ----------
NEXTLF(BUF,FROM) ;
	NEW P SET P=$F(BUF,$C(10),FROM)
	IF P=0 QUIT 0
	QUIT P-1
	;
GETLINE(BUF,FROM,LINE,NEXT) ;
	NEW LFP SET LFP=$$NEXTLF(BUF,FROM)
	IF LFP=0 QUIT 0
	SET LINE=$E(BUF,FROM,LFP-1)
	IF $L(LINE),$E(LINE,$L(LINE))=$C(13) SET LINE=$E(LINE,1,$L(LINE)-1)
	SET NEXT=LFP+1
	QUIT 1
	;
FINDBOUND(BUF,BD0,FROM,BPOS) ;
	NEW S SET S=FROM
	NEW F,P
	FOR  DO  QUIT:S=0  QUIT:$DATA(BPOS)
	. SET F=$F(BUF,BD0,S)
	. IF F=0 SET S=0 QUIT
	. SET P=F-$L(BD0)
	. IF P=1 SET BPOS=P QUIT
	. IF $E(BUF,P-1)=$C(10) SET BPOS=P QUIT
	. SET S=F
	QUIT $SELECT($DATA(BPOS):1,1:0)
	;
BOUNDLINE(BUF,BD0,BPOS,CLOSE,AFTER) ;
	NEW LINE,NEXT,OK
	SET OK=$$GETLINE(BUF,BPOS,.LINE,.NEXT) IF 'OK QUIT 0
	IF $E(LINE,1,$L(BD0))'=BD0 QUIT 0
	NEW TAIL SET TAIL=$E(LINE,$L(BD0)+1,999)
	SET CLOSE=$SELECT($E(TAIL,1,2)="--":1,1:0)
	SET AFTER=NEXT
	QUIT 1
	;
TRIMBUF(BUF,ABS,START) ;
	; Drop prefix up to START (1-based) and advance ABS
	NEW D SET D=START-1
	IF D>0 SET BUF=$E(BUF,START,999999),ABS=ABS+D
	QUIT
	;
; ------------------ state: preamble ------------------
STEPPRE(STATE,BUF,ABS,BD0,MP,ERR,RTN) ;
	NEW BPOS KILL BPOS
	IF '$$FINDBOUND(BUF,BD0,1,.BPOS) QUIT 0
	NEW CLOSE,AFTER
	IF '$$BOUNDLINE(BUF,BD0,BPOS,.CLOSE,.AFTER) QUIT 0
	DO TRIMBUF(.BUF,.ABS,AFTER)
	IF CLOSE DO  QUIT 1
	. SET MP("ok")=1,STATE="done"
	SET STATE="headers"
	QUIT 1
	;
; ------------------ state: headers ------------------
STEPHDR(STATE,BUF,ABS,MP,PN,PFN,PCT,HBYTES,HCOUNT,MAXH,MAXPH,ERR,RTN) ;
	NEW LINE,NEXT,OK
	SET OK=$$GETLINE(BUF,1,.LINE,.NEXT) IF 'OK QUIT 0
	DO TRIMBUF(.BUF,.ABS,NEXT)
	;
	IF LINE="" DO  QUIT 1
	. SET HBYTES=0,HCOUNT=0
	. SET STATE="data"
	;
	IF $E(LINE,1)=" "!(($E(LINE,1)=$C(9))) DO  QUIT 1
	. DO SETERR(.ERR,RTN,"header_folding_rejected")
	;
	SET HBYTES=HBYTES+$L(LINE)+2
	IF HBYTES>MAXH DO  QUIT 1
	. DO SETERR(.ERR,RTN,"part_headers_too_large")
	SET HCOUNT=HCOUNT+1
	IF HCOUNT>MAXPH DO  QUIT 1
	. DO SETERR(.ERR,RTN,"too_many_part_headers")
	;
	NEW K,V
	SET K=$$LOW($$TRIM($P(LINE,":",1)))
	SET V=$$TRIM($P(LINE,":",2,999))
	IF K="" QUIT 1
	SET MP("cur","hdr",K)=V
	IF K="content-disposition" DO PARSECD(V,.PN,.PFN)
	IF K="content-type" SET PCT=V
	QUIT 1
	;
; ------------------ state: data ------------------
STEPDATA(STATE,BUF,ABS,BD0,KEEP,CONF,REQ,MP,PNUM,PN,PFN,PCT,MAXP,MAXPART,MAXSC,SPOOLMAX,SPOOLDIR,ZCFILE,NEST,DEP,ERR,RTN) ;
	IF '$DATA(MP("cur","init")) DO
	. SET PNUM=PNUM+1
	. IF PNUM>MAXP DO  QUIT
	. . DO SETERR(.ERR,RTN,"too_many_parts")
	. SET MP("parts")=PNUM
	. NEW CT SET CT=$GET(PCT)
	. IF CT="" SET CT=$SELECT($GET(PFN)'="":"application/octet-stream",1:"text/plain")
	. IF '$$ALLOWCT(.CONF,CT,$GET(PFN)'="") DO  QUIT
	. . DO SETERR(.ERR,RTN,"disallowed_content_type")
	. SET MP("part",PNUM,"name")=$GET(PN)
	. SET MP("part",PNUM,"filename")=$GET(PFN)
	. SET MP("part",PNUM,"ctype")=CT
	. NEW HK SET HK=""
	. FOR  SET HK=$O(MP("cur","hdr",HK)) Q:HK=""  SET MP("part",PNUM,"hdr",HK)=MP("cur","hdr",HK)
	. KILL MP("cur","hdr")
	. DO PINIT(.CONF,.REQ,.MP,PNUM,MAXSC,SPOOLMAX,SPOOLDIR,ZCFILE,.ABS)
	. SET MP("cur","init")=1
	;
	NEW BPOS KILL BPOS
	IF $$FINDBOUND(BUF,BD0,1,.BPOS)  QUIT $$HITBOUND(.STATE,.BUF,.ABS,BD0,BPOS,.CONF,.REQ,.MP,PNUM,.PN,.PFN,.PCT,MAXPART,MAXSC,SPOOLMAX,SPOOLDIR,NEST,DEP,.ERR,RTN)
	;
	IF $L(BUF)>KEEP DO  QUIT 1
	. NEW FL SET FL=$L(BUF)-KEEP
	. NEW DATA SET DATA=$E(BUF,1,FL)
	. DO TRIMBUF(.BUF,.ABS,FL+1)
	. IF DATA'="" DO PAPPEND(.CONF,.MP,PNUM,DATA,MAXPART,MAXSC,SPOOLMAX,SPOOLDIR,.ERR,RTN)
	QUIT 0
	;
HITBOUND(STATE,BUF,ABS,BD0,BPOS,CONF,REQ,MP,PNUM,PN,PFN,PCT,MAXPART,MAXSC,SPOOLMAX,SPOOLDIR,NEST,DEP,ERR,RTN) ;
	NEW CLOSE,AFTER
	IF '$$BOUNDLINE(BUF,BD0,BPOS,.CLOSE,.AFTER) QUIT 0
	;
	NEW END SET END=BPOS-2
	IF END>=1,$E(BUF,END)=$C(13) SET END=END-1
	NEW DATA SET DATA=$S(END>=1:$E(BUF,1,END),1:"")
	IF DATA'="" DO PAPPEND(.CONF,.MP,PNUM,DATA,MAXPART,MAXSC,SPOOLMAX,SPOOLDIR,.ERR,RTN)
	IF $DATA(ERR("error")) QUIT 1
	;
	IF $GET(MP("part",PNUM,"mode"))="zref" DO
	. SET MP("part",PNUM,"zend")=ABS+$L(DATA)
	. SET MP("part",PNUM,"len")=MP("part",PNUM,"zend")-MP("part",PNUM,"zstart")
	;
	DO TRIMBUF(.BUF,.ABS,AFTER)
	DO PFINAL(.CONF,.REQ,.MP,PNUM,.PN,.PFN,.PCT,NEST,DEP,.ERR,RTN)
	KILL MP("cur","init")
	IF $DATA(ERR("error")) QUIT 1
	;
	IF CLOSE DO  QUIT 1
	. SET MP("ok")=1,STATE="done"
	SET STATE="headers"
	QUIT 1
	;
; ---------- storage ----------
PINIT(CONF,REQ,MP,IDX,MAXSC,SPOOLMAX,SPOOLDIR,ZCFILE,ABS) ;
	SET MP("part",IDX,"len")=0
	SET MP("part",IDX,"mode")="scalar"
	IF $GET(MP("part",IDX,"filename"))'="",$GET(REQ("body","mode"))="global",ZCFILE DO
	. SET MP("part",IDX,"mode")="zref"
	. SET MP("part",IDX,"zref")=$GET(REQ("body","ref"))
	. SET MP("part",IDX,"zn")=+$GET(REQ("body","n"))
	. SET MP("part",IDX,"zstart")=ABS
	. SET MP("part",IDX,"zend")=ABS
	QUIT
	;
PAPPEND(CONF,MP,IDX,DATA,MAXPART,MAXSC,SPOOLMAX,SPOOLDIR,ERR,RTN) ;
	NEW LEN SET LEN=+$GET(MP("part",IDX,"len"))
	NEW NEWLEN SET NEWLEN=LEN+$L(DATA)
	IF MAXPART>0,NEWLEN>MAXPART DO  QUIT
	. DO SETERR(.ERR,RTN,"part_too_large")
	;
	NEW MODE SET MODE=$GET(MP("part",IDX,"mode"),"scalar")
	IF MODE="zref" DO  QUIT
	. SET MP("part",IDX,"len")=NEWLEN
	IF MODE="spool" DO  QUIT
	. DO SPOOLWRITE(.MP,IDX,DATA,.ERR,RTN)
	. IF $DATA(ERR("error")) QUIT
	. SET MP("part",IDX,"len")=NEWLEN
	;
	NEW LIM SET LIM=+$GET(CONF("server","limits","maxMultipartPartScalarBytes"),MAXSC)
	IF LIM<1 SET LIM=MAXSC
	;
	IF MODE="scalar" DO  QUIT
	. IF NEWLEN'>LIM DO
	. . SET MP("part",IDX,"data")=$GET(MP("part",IDX,"data"))_DATA
	. . SET MP("part",IDX,"len")=NEWLEN
	. ELSE  DO
	. . NEW OLD SET OLD=$GET(MP("part",IDX,"data"))
	. . DO PTOGLOBAL(.MP,IDX)
	. . IF OLD'="" DO PGAPPEND(.MP,IDX,OLD)
	. . DO PGAPPEND(.MP,IDX,DATA)
	. . SET MP("part",IDX,"len")=NEWLEN
	. IF $GET(MP("part",IDX,"filename"))'="",SPOOLMAX>0,NEWLEN>SPOOLMAX DO
	. . DO TOSPOOL(.CONF,.MP,IDX,SPOOLDIR,.ERR,RTN)
	IF MODE="global" DO
	. DO PGAPPEND(.MP,IDX,DATA)
	. SET MP("part",IDX,"len")=NEWLEN
	. IF $GET(MP("part",IDX,"filename"))'="",SPOOLMAX>0,NEWLEN>SPOOLMAX DO
	. . DO TOSPOOL(.CONF,.MP,IDX,SPOOLDIR,.ERR,RTN)
	QUIT
	;
PTOGLOBAL(MP,IDX) ;
	NEW RID SET RID=$GET(MP("id"))
	NEW REF SET REF=$NA(^TMP($J,"MIOHTTPMPU","PART",RID,IDX))
	KILL @REF
	KILL MP("part",IDX,"data")
	SET MP("part",IDX,"mode")="global"
	SET MP("part",IDX,"ref")=REF
	SET MP("part",IDX,"n")=0
	QUIT
	;
PGAPPEND(MP,IDX,DATA) ;
	NEW REF SET REF=$GET(MP("part",IDX,"ref"))
	NEW N SET N=+$GET(MP("part",IDX,"n"))+1
	SET @REF@(N)=DATA
	SET MP("part",IDX,"n")=N
	QUIT
	;
TOSPOOL(CONF,MP,IDX,SPOOLDIR,ERR,RTN) ;
	NEW PATH SET PATH=$$SPOOLPATH(.MP,IDX,SPOOLDIR)
	NEW DEV SET DEV=PATH
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" DO SETERR(.ERR,RTN,""spool_open_failed"") QUIT"
	OPEN DEV:(newversion:stream:nowrap)
	USE DEV
	IF $GET(MP("part",IDX,"mode"))="scalar" WRITE $GET(MP("part",IDX,"data"))
	ELSE  IF $GET(MP("part",IDX,"mode"))="global" DO
	. NEW REF SET REF=$GET(MP("part",IDX,"ref"))
	. NEW I FOR I=1:1:+$GET(MP("part",IDX,"n")) WRITE $GET(@REF@(I))
	. IF REF'="" KILL @REF
	KILL MP("part",IDX,"data"),MP("part",IDX,"ref"),MP("part",IDX,"n")
	SET MP("part",IDX,"mode")="spool"
	SET MP("part",IDX,"path")=PATH
	SET MP("part",IDX,"spoolDev")=DEV
	QUIT
	;
SPOOLWRITE(MP,IDX,DATA,ERR,RTN) ;
	NEW DEV SET DEV=$GET(MP("part",IDX,"spoolDev"))
	IF DEV="" DO  QUIT
	. DO SETERR(.ERR,RTN,"spool_write_failed")
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" DO SETERR(.ERR,RTN,""spool_write_failed"") QUIT"
	USE DEV WRITE DATA
	QUIT
	;
SPOOLCLOSE(MP,IDX) ;
	NEW DEV SET DEV=$GET(MP("part",IDX,"spoolDev"))
	IF DEV="" QUIT
	NEW $ETRAP SET $ETRAP="SET $ECODE="""" QUIT"
	CLOSE DEV
	KILL MP("part",IDX,"spoolDev")
	QUIT
	;
SPOOLPATH(MP,IDX,DIR) ;
	NEW RID SET RID=$GET(MP("id"))
	NEW D SET D=$GET(DIR) IF D="" SET D="/tmp"
	IF $E(D,$L(D))="/" SET D=$E(D,1,$L(D)-1)
	QUIT D_"/mio-mpu-"_$J_"-"_RID_"-"_IDX_".part"
	;
; ---------- finalize + nested ----------
PFINAL(CONF,REQ,MP,IDX,PN,PFN,PCT,NEST,DEP,ERR,RTN) ;
	IF $GET(MP("part",IDX,"mode"))="spool" DO SPOOLCLOSE(.MP,IDX)
	;
	IF NEST DO
	. NEW CT SET CT=$GET(MP("part",IDX,"ctype"))
	. IF $$ISMULTI(CT) DO
	. . NEW SUBREQ,SUB,SE
	. . KILL SUBREQ,SUB,SE
	. . SET SUBREQ("id")=$GET(MP("id"))_"."_IDX
	. . SET SUBREQ("hdr","content-type")=CT
	. . DO SETSUBBODY(.MP,IDX,.SUBREQ,.REQ)
	. . NEW OK SET OK=$$PARSEDEP(.CONF,.SUBREQ,.SUB,.SE,DEP+1)
	. . IF OK DO MERGESUB(.MP,IDX,.SUB)
	. . ELSE  DO
	. . . SET MP("part",IDX,"sub","error")=$GET(SE("error"))
	. . . SET MP("part",IDX,"sub","routine")=$GET(SE("routine"))
	;
	IF $GET(MP("part",IDX,"filename"))="" DO
	. NEW FMAX SET FMAX=+$GET(CONF("server","multipart","maxFieldScalarBytes"),8192)
	. IF FMAX<1 SET FMAX=8192
	. IF +$GET(MP("part",IDX,"len"))'>FMAX SET MP("field",$GET(MP("part",IDX,"name")))=$$PARTSLURP(.MP,IDX,.CONF)
	;
	SET PN="",PFN="",PCT=""
	QUIT
	;
ISMULTI(CT) ;
	NEW L SET L=$$LOW(CT)
	QUIT $SELECT(L["multipart/":1,1:0)
	;
SETSUBBODY(MP,IDX,SUBREQ,REQ) ;
	; Map part storage to a REQ("body",...) model for nested parse.;
	; For nested multipart, we must ensure the body ends with a line terminator so the
	; closing boundary line is always parseable even if the outer parser trimmed the CRLF
	; that precedes the outer boundary.;
	NEW MODE SET MODE=$GET(MP("part",IDX,"mode"))
	NEW APP SET APP=""
	NEW CONF M CONF=^MIO("CONF")
	; If small enough, prefer scalar (simplifies nested parsing).;
	NEW LIM SET LIM=+$GET(^MIO("CONF","server","multipart","maxNestedScalarBytes"),1048576)
	IF LIM<1 SET LIM=1048576
	IF +$GET(MP("part",IDX,"len"))'>LIM DO  QUIT
	. NEW BODY SET BODY=$$PARTSLURP(.MP,IDX,.CONF)
	. ; ensure ends with LF
	. IF BODY'="",($E(BODY,$L(BODY))'=$C(10)) SET BODY=BODY_$C(13,10)
	. SET SUBREQ("body","mode")="scalar"
	. SET SUBREQ("body")=BODY
	. SET SUBREQ("body","len")=$L(BODY)
	;
	; Large nested: keep original mode and add optional append.;
	IF MODE="scalar" DO  QUIT
	. SET SUBREQ("body","mode")="scalar"
	. SET SUBREQ("body")=$GET(MP("part",IDX,"data"))
	. SET SUBREQ("body","len")=+$GET(MP("part",IDX,"len"))
	. IF $GET(SUBREQ("body"))'="",($E(SUBREQ("body"),$L(SUBREQ("body")))'=$C(10)) SET SUBREQ("body","append")=$C(13,10)
	IF MODE="global" DO  QUIT
	. SET SUBREQ("body","mode")="global"
	. SET SUBREQ("body","ref")=$GET(MP("part",IDX,"ref"))
	. SET SUBREQ("body","n")=+$GET(MP("part",IDX,"n"))
	. SET SUBREQ("body","len")=+$GET(MP("part",IDX,"len"))
	. NEW LAST SET LAST=$GET(@SUBREQ("body","ref")@(SUBREQ("body","n")))
	. IF LAST'="",($E(LAST,$L(LAST))'=$C(10)) SET SUBREQ("body","append")=$C(13,10)
	IF MODE="spool" DO  QUIT
	. SET SUBREQ("body","mode")="spool"
	. SET SUBREQ("body","path")=$GET(MP("part",IDX,"path"))
	. SET SUBREQ("body","len")=+$GET(MP("part",IDX,"len"))
	. ; safe: always allow an append for nested parsing
	. SET SUBREQ("body","append")=$C(13,10)
	IF MODE="zref" DO  QUIT
	. SET SUBREQ("body","mode")="zref"
	. SET SUBREQ("body","ref")=$GET(MP("part",IDX,"zref"))
	. SET SUBREQ("body","n")=+$GET(MP("part",IDX,"zn"))
	. SET SUBREQ("body","start")=+$GET(MP("part",IDX,"zstart"))
	. SET SUBREQ("body","end")=+$GET(MP("part",IDX,"zend"))
	. SET SUBREQ("body","len")=+$GET(MP("part",IDX,"len"))
	. SET SUBREQ("body","append")=$C(13,10)
	QUIT
	;
MERGESUB(MP,IDX,SUB) ;
	MERGE MP("part",IDX,"sub")=SUB
	QUIT
	;
; ---------- allowlist ----------
ALLOWCT(CONF,CT,ISFILE) ;
	NEW HAS SET HAS=0
	NEW X SET X=$GET(CONF("server","multipart","allowTypes"))
	IF X'="" SET HAS=1
	IF $DATA(CONF("server","multipart","allow")) SET HAS=1
	IF 'HAS QUIT 1
	NEW LCT SET LCT=$$LOW(CT)
	IF $DATA(CONF("server","multipart","allow",LCT)) QUIT 1
	NEW I,IT
	FOR I=1:1:$L(X,",") DO
	. SET IT=$$LOW($$TRIM($P(X,",",I)))
	. IF IT="" QUIT
	. IF IT=LCT SET HAS=2
	. IF IT["/*",$P(IT,"/",1)=$P(LCT,"/",1) SET HAS=2
	IF HAS=2 QUIT 1
	QUIT 0
	;
; ---------- iterators over REQ("body",...) ----------
ITOPEN(REQ,CUR,CONF) ;
	KILL CUR
	NEW MODE SET MODE=$GET(REQ("body","mode"))
	IF MODE="" SET MODE=$SELECT($DATA(REQ("body")):"scalar",1:"none")
	SET CUR("mode")=MODE
	IF MODE="scalar" SET CUR("sent")=0 QUIT
	IF MODE="global" DO  QUIT
	. SET CUR("ref")=$GET(REQ("body","ref"))
	. SET CUR("i")=0
	. SET CUR("n")=+$GET(REQ("body","n"))
	IF MODE="spool" DO  QUIT
	. NEW PATH SET PATH=$GET(REQ("body","path"))
	. SET CUR("path")=PATH
	. SET CUR("chunk")=+$GET(CONF("server","multipart","spoolReadChunkBytes"),16384) IF CUR("chunk")<1 SET CUR("chunk")=16384
	. NEW $ETRAP SET $ETRAP="SET $ECODE="""" SET CUR(""eof"")=1 QUIT"
	. OPEN PATH:(readonly:stream:nowrap)
	. USE PATH
	. SET CUR("dev")=PATH
	. SET CUR("eof")=0
	IF MODE="zref" DO  QUIT
	. SET CUR("ref")=$GET(REQ("body","ref"))
	. SET CUR("n")=+$GET(REQ("body","n"))
	. SET CUR("start")=+$GET(REQ("body","start"))
	. SET CUR("end")=+$GET(REQ("body","end"))
	. IF CUR("end")'>0 SET CUR("end")=CUR("start")
	. SET CUR("rem")=CUR("end")-CUR("start")
	. SET CUR("chunk")=+$GET(CONF("server","multipart","zrefReadChunkBytes"),16384) IF CUR("chunk")<1 SET CUR("chunk")=16384
	. NEW I,TOT,SLEN SET TOT=0,CUR("i")=0,CUR("pos")=1
	. FOR I=1:1:CUR("n") DO  QUIT:CUR("i")>0
	. . SET SLEN=$L($GET(@CUR("ref")@(I)))
	. . IF TOT+SLEN'<CUR("start") DO
	. . . SET CUR("i")=I
	. . . SET CUR("pos")=CUR("start")-TOT
	. . SET TOT=TOT+SLEN
	QUIT
	;
ITNEXT(REQ,CUR,CH,CONF) ;
	SET CH=""
	NEW MODE SET MODE=$GET(CUR("mode"))
	IF MODE="none" QUIT 0
	IF MODE="scalar" DO  QUIT $SELECT(CH'="":1,1:0)
	. IF $GET(CUR("sent"))=1 QUIT
	. SET CUR("sent")=1
	. SET CH=$GET(REQ("body"))
	IF MODE="global" DO  QUIT $SELECT(CH'="":1,1:0)
	. NEW I SET I=$GET(CUR("i"))+1
	. IF I>+$GET(CUR("n")) QUIT
	. SET CUR("i")=I
	. NEW REF SET REF=$GET(CUR("ref")) IF REF="" QUIT
	. SET CH=$GET(@REF@(I))
	IF MODE="spool" DO  QUIT $SELECT(CH'="":1,1:0)
	. IF $GET(CUR("eof")) QUIT
	. NEW DEV SET DEV=$GET(CUR("dev"))
	. NEW SZ SET SZ=+$GET(CUR("chunk"),16384)
	. NEW X
	. NEW $ETRAP SET $ETRAP="SET $ECODE="""" SET CUR(""eof"")=1 SET CH="""" QUIT"
	. USE DEV READ X#SZ
	. IF $ZEOF SET CUR("eof")=1
	. SET CH=X
	IF MODE="zref"  QUIT $$ZREFNEXT(.CUR,.CH)
	QUIT 0
	;
ZREFNEXT(CUR,CH) ;
	SET CH=""
	IF $GET(CUR("rem"))'>0 QUIT 0
	NEW REF SET REF=$GET(CUR("ref")) IF REF="" QUIT 0
	NEW I SET I=+$GET(CUR("i")) IF I<1 QUIT 0
	NEW POS SET POS=+$GET(CUR("pos")) IF POS<1 SET POS=1
	NEW N SET N=+$GET(CUR("n"))
	NEW SZ SET SZ=+$GET(CUR("chunk"),16384)
	NEW NEED SET NEED=$SELECT(CUR("rem")>SZ:SZ,1:CUR("rem"))
	NEW OUT SET OUT=""
	NEW TAKE,SLEN,AV
	FOR  QUIT:NEED'>0  DO  QUIT:I>N
	. SET SLEN=$L($GET(@REF@(I)))
	. SET AV=SLEN-POS+1
	. IF AV<1 SET I=I+1,POS=1 QUIT
	. SET TAKE=$SELECT(AV>NEED:NEED,1:AV)
	. SET OUT=OUT_$E($GET(@REF@(I)),POS,POS+TAKE-1)
	. SET NEED=NEED-TAKE
	. SET POS=POS+TAKE
	. IF POS>SLEN SET I=I+1,POS=1
	SET CUR("i")=I
	SET CUR("pos")=POS
	SET CUR("rem")=CUR("rem")-$L(OUT)
	SET CH=OUT
	QUIT $SELECT(CH'="":1,1:0)
	;
ITCLOSE(CUR) ;
	IF $GET(CUR("mode"))="spool",$GET(CUR("dev"))'="" DO
	. NEW $ETRAP SET $ETRAP="SET $ECODE="""" QUIT"
	. CLOSE CUR("dev")
	KILL CUR
	QUIT
	;
; ---------- part iteration + slurp ----------
PARTOPEN(MP,IDX,CUR,CONF) ;
	KILL CUR
	SET CUR("mode")=$GET(MP("part",IDX,"mode"))
	SET CUR("i")=0
	IF CUR("mode")="spool" DO
	. SET CUR("path")=$GET(MP("part",IDX,"path"))
	. SET CUR("chunk")=+$GET(CONF("server","multipart","spoolReadChunkBytes"),16384) IF CUR("chunk")<1 SET CUR("chunk")=16384
	. NEW $ETRAP SET $ETRAP="SET $ECODE="""" SET CUR(""eof"")=1 QUIT"
	. OPEN CUR("path"):(readonly:stream:nowrap)
	. USE CUR("path")
	. SET CUR("dev")=CUR("path"),CUR("eof")=0
	IF CUR("mode")="zref" DO
	. SET CUR("ref")=$GET(MP("part",IDX,"zref"))
	. SET CUR("n")=+$GET(MP("part",IDX,"zn"))
	. SET CUR("start")=+$GET(MP("part",IDX,"zstart"))
	. SET CUR("end")=+$GET(MP("part",IDX,"zend"))
	. SET CUR("rem")=CUR("end")-CUR("start")
	. SET CUR("chunk")=+$GET(CONF("server","multipart","zrefReadChunkBytes"),16384) IF CUR("chunk")<1 SET CUR("chunk")=16384
	. NEW I,TOT,SLEN SET TOT=0,CUR("i")=0,CUR("pos")=1
	. FOR I=1:1:CUR("n") DO  QUIT:CUR("i")>0
	. . SET SLEN=$L($GET(@CUR("ref")@(I)))
	. . IF TOT+SLEN'<CUR("start") DO
	. . . SET CUR("i")=I
	. . . SET CUR("pos")=CUR("start")-TOT
	. . SET TOT=TOT+SLEN
	QUIT
	;
PARTNEXT(MP,IDX,CUR,CH) ;
	SET CH=""
	NEW MODE SET MODE=$GET(CUR("mode"))
	IF MODE="scalar" DO  QUIT $SELECT(CH'="":1,1:0)
	. IF $GET(CUR("i"))=0 DO
	. . SET CUR("i")=1
	. . SET CH=$GET(MP("part",IDX,"data"))
	IF MODE="global" DO  QUIT $SELECT(CH'="":1,1:0)
	. NEW REF SET REF=$GET(MP("part",IDX,"ref"))
	. NEW I SET I=$GET(CUR("i"))+1
	. IF REF="" QUIT
	. IF '$DATA(@REF@(I)) QUIT
	. SET CUR("i")=I,CH=@REF@(I)
	IF MODE="spool" DO  QUIT $SELECT(CH'="":1,1:0)
	. IF $GET(CUR("eof")) QUIT
	. NEW DEV SET DEV=$GET(CUR("dev"))
	. NEW SZ SET SZ=+$GET(CUR("chunk"),16384)
	. NEW X
	. NEW $ETRAP SET $ETRAP="SET $ECODE="""" SET CUR(""eof"")=1 SET CH="""" QUIT"
	. USE DEV READ X#SZ
	. IF $ZEOF SET CUR("eof")=1
	. SET CH=X
	IF MODE="zref"  QUIT $$ZREFNEXT(.CUR,.CH)
	QUIT 0
	;
PARTSLURP(MP,IDX,CONF) ;
	NEW MODE SET MODE=$GET(MP("part",IDX,"mode"))
	IF MODE="scalar" QUIT $GET(MP("part",IDX,"data"))
	NEW CUR,CH,OUT SET OUT=""
	DO PARTOPEN(.MP,IDX,.CUR,.CONF)
	FOR  QUIT:'$$PARTNEXT(.MP,IDX,.CUR,.CH)  SET OUT=OUT_CH
	DO ITCLOSE(.CUR)
	QUIT OUT
	;
FREE(MP) ;
	NEW I,REF,PATH
	FOR I=1:1:+$GET(MP("parts")) DO
	. IF $GET(MP("part",I,"mode"))="global" DO
	. . SET REF=$GET(MP("part",I,"ref")) IF REF'="" KILL @REF
	. IF $GET(MP("part",I,"mode"))="spool" DO
	. . IF +$GET(^MIO("CONF","server","multipart","keepSpoolFiles")) QUIT
	. . SET PATH=$GET(MP("part",I,"path")) IF PATH="" QUIT
	. . NEW $ETRAP SET $ETRAP="SET $ECODE="""" QUIT"
	. . OPEN PATH:(readonly) CLOSE PATH:DELETE
	KILL MP
	QUIT
	;
; ---------- parsing helpers ----------
BOUNDARY(CT,BND) ;
	NEW LCT SET LCT=$$LOW(CT)
	IF LCT'["multipart/" QUIT 0
	NEW I,TOK,K,V
	FOR I=1:1:$L(CT,";") DO
	. SET TOK=$$TRIM($P(CT,";",I))
	. SET K=$$LOW($$TRIM($P(TOK,"=",1)))
	. IF K'="boundary" QUIT
	. SET V=$$TRIM($P(TOK,"=",2,999))
	. IF $E(V,1)="""" SET V=$E(V,2,999)
	. IF $E(V,$L(V))="""" SET V=$E(V,1,$L(V)-1)
	. SET BND=V
	QUIT $SELECT($GET(BND)'="":1,1:0)
	;
PARSECD(V,PN,PFN) ;
	NEW I,TOK,K,VAL
	FOR I=1:1:$L(V,";") DO
	. SET TOK=$$TRIM($P(V,";",I))
	. SET K=$$LOW($$TRIM($P(TOK,"=",1)))
	. SET VAL=$$TRIM($P(TOK,"=",2,999))
	. IF $E(VAL,1)="""" SET VAL=$E(VAL,2,999)
	. IF $E(VAL,$L(VAL))="""" SET VAL=$E(VAL,1,$L(VAL)-1)
	. IF K="name" SET PN=VAL
	. IF K="filename" SET PFN=VAL
	QUIT
	;
SETERR(ERR,RTN,CODE) ;
	SET ERR("routine")=RTN
	SET ERR("error")=CODE
	QUIT
	;
LOW(S) QUIT $ZCONVERT($GET(S),"L")
TRIM(S) ;
	NEW X SET X=$GET(S)
	FOR  QUIT:$E(X,1)'=" "  SET X=$E(X,2,$L(X))
	FOR  QUIT:$L(X)=0!($E(X,$L(X))'=" ")  SET X=$E(X,1,$L(X)-1)
	QUIT X
	;