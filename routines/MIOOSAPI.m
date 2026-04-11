MIOOSAPI ; MIOOS API routes
	QUIT
	;
BOOTSTRAP(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,OBJ
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"bootstrap_state_error",$GET(ERR("error"),"bootstrap_state_error"),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	DO BOOTARY^MIOOSST(.STATE,.CONF,.OBJ)
	SET OBJ("ok")=1
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
VIEW(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,OBJ
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"view_state_error",$GET(ERR("error"),"view_state_error"),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	DO BUILD^MIOOSVM(.STATE,.CONF,.OBJ)
	SET OBJ("ok")=1
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
SIGNIN(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,TOKEN,OBJ,HEAD,JSON,USER,POLICY
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$SIGNIN^MIOOSAUTH(.CONF,$GET(TREE("username")),$GET(TREE("password")),.TOKEN,.ERR) DO  QUIT
	. IF $GET(ERR("error"))="password_change_required" DO  QUIT
	. . SET USER=$GET(ERR("username"),$$CANON^MIOOSAUTH($GET(TREE("username"))))
	. . DO PWPOLICY^MIOOSAUTH(.CONF,.POLICY)
	. . SET OBJ("ok")=1,OBJ("requiresPasswordChange")=1,OBJ("username")=USER,OBJ("changeToken")=$GET(ERR("changeToken"))
	. . MERGE OBJ("passwordStatus")=ERR("passwordStatus")
	. . MERGE OBJ("passwordPolicy")=POLICY
	. . DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	. . SET CTX("status")=200
	. DO RESPERR(.DEV,.CONF,401,"signin_failed",$GET(ERR("error")),.CTX)
	SET USER=$$CANON^MIOOSAUTH($GET(TREE("username")))
	SET OBJ("ok")=1,OBJ("tokenIssued")=1,OBJ("username")=USER
	SET JSON=$$EN^MIOJSON1(.OBJ)
	SET HEAD("Content-Type")="application/json; charset=utf-8"
	SET HEAD("Set-Cookie")=$$COOKIEHDR^MIOOSAUTH(.CONF,TOKEN,0)
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,JSON,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
CHANGEPASSWORD(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,TOKEN,OBJ,HEAD,JSON
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF $GET(TREE("newPassword"))'=$GET(TREE("confirmPassword")) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"password_change_failed","password_confirmation_mismatch",.CTX)
	IF '$$CHANGEPASSWORD^MIOOSAUTH(.CONF,$GET(TREE("changeToken")),$GET(TREE("newPassword")),.TOKEN,.OBJ,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"password_change_failed",$GET(ERR("error")),.CTX)
	SET OBJ("ok")=1,OBJ("tokenIssued")=1
	SET JSON=$$EN^MIOJSON1(.OBJ)
	SET HEAD("Content-Type")="application/json; charset=utf-8"
	SET HEAD("Set-Cookie")=$$COOKIEHDR^MIOOSAUTH(.CONF,TOKEN,0)
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,JSON,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
SIGNOUT(DEV,CONF,REQ,CTX)
	NEW OBJ,HEAD,JSON
	DO SIGNOUT^MIOOSAUTH(.CONF,.REQ,.CTX)
	SET OBJ("ok")=1,OBJ("signedOut")=1
	SET JSON=$$EN^MIOJSON1(.OBJ)
	SET HEAD("Content-Type")="application/json; charset=utf-8"
	SET HEAD("Set-Cookie")=$$COOKIEHDR^MIOOSAUTH(.CONF,"",1)
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,JSON,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
AUTHREFRESH(DEV,CONF,REQ,CTX)
	NEW ERR,TOKEN,OBJ,HEAD,JSON
	IF '$$REFRESH^MIOOSAUTH(.CONF,.REQ,.CTX,.TOKEN,.OBJ,.ERR) DO  QUIT
	. SET HEAD("Content-Type")="application/json; charset=utf-8"
	. SET HEAD("Set-Cookie")=$$COOKIEHDR^MIOOSAUTH(.CONF,"",1)
	. SET OBJ("ok")=0,OBJ("error")="auth_refresh_failed",OBJ("detail")=$GET(ERR("error"),"login_required"),OBJ("routine")="MIOOSAPI"
	. DO RESPX^MIOHTTP(.DEV,.CONF,401,.HEAD,$$EN^MIOJSON1(.OBJ),$GET(CTX("request_id")),.CTX)
	. SET CTX("status")=401
	SET JSON=$$EN^MIOJSON1(.OBJ)
	SET HEAD("Content-Type")="application/json; charset=utf-8"
	SET HEAD("Set-Cookie")=$$COOKIEHDR^MIOOSAUTH(.CONF,TOKEN,0)
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,JSON,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
GUESTSIGNIN(DEV,CONF,REQ,CTX)
	NEW ERR,TOKEN,OBJ,HEAD,JSON
	IF '$$GUESTSIGNIN^MIOOSAUTH(.CONF,.TOKEN,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"guest_signin_failed",$GET(ERR("error")),.CTX)
	SET OBJ("ok")=1,OBJ("tokenIssued")=1,OBJ("guest")=1,OBJ("username")="guest"
	SET JSON=$$EN^MIOJSON1(.OBJ)
	SET HEAD("Content-Type")="application/json; charset=utf-8"
	SET HEAD("Set-Cookie")=$$COOKIEHDR^MIOOSAUTH(.CONF,TOKEN,0)
	DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,JSON,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
AUDITX(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,OBJ,LIMIT
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"audit_state_error",$GET(ERR("error"),"audit_state_error"),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	SET LIMIT=+$GET(REQ("query","limit"),+$GET(CONF("mioos","audit","reportLimit"),50))
	IF LIMIT<1 SET LIMIT=+$GET(CONF("mioos","audit","reportLimit"),50)
	IF '$$EXPORT^MIOOSAUD(.STATE,.CONF,LIMIT,.OBJ,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"audit_export_failed",$GET(ERR("error"),"audit_export_failed"),.CTX)
	SET OBJ("ok")=1
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
PARSEBODY(REQ,TREE,ERR)
	NEW MODE,REF,TXT,Q S Q=1
	SET MODE=$GET(REQ("body","mode"),"scalar")
	IF MODE="scalar" D  Q Q
	. S TXT=$GET(REQ("body"))
	. I TXT="" SET ERR("routine")="MIOOSAPI",ERR("error")="body_missing" S Q=0 Q
	. I '$$DECODE^MIOJSON(TXT,.TREE,.ERR) SET ERR("routine")="MIOOSAPI" S Q=0 Q
	;
	IF MODE'="global" S ERR("error")="invalid_request_body_mode" S Q=0 Q Q
	;	
	S REF=$GET(REQ("body","ref"))
	I REF="" S ERR("error")="invalid_request_body_ref" S Q=0 Q Q
	;	
	D DECODE^MIOJSON2(REF,$NA(TREE),$NA(ERR))
	;
	Q 1
	;
BODYTXT(REQ)
	NEW MODE,REF,N,I,TXT
	SET MODE=$GET(REQ("body","mode"),"scalar")
	IF MODE="scalar" QUIT $GET(REQ("body"))
	IF MODE'="global" QUIT ""
	SET REF=$GET(REQ("body","ref"))
	IF REF="" QUIT ""
	SET N=+$GET(REQ("body","n")),TXT=""
	FOR I=1:1:N SET TXT=TXT_$GET(@REF@(I))
	QUIT TXT
	;
REQUIREAUTH(DEV,CONF,CTX,STATE)
	IF +$GET(STATE("authRequired"),0)'=1 QUIT 1
	IF +$GET(STATE("authenticated"),0)=1 QUIT 1
	DO RESPERR(.DEV,.CONF,401,"login_required","login_required",.CTX)
	QUIT 0
	;
RESPERR(DEV,CONF,STATUS,CODE,DETAIL,CTX)
	NEW OBJ
	SET OBJ("ok")=0,OBJ("error")=$GET(CODE),OBJ("detail")=$GET(DETAIL),OBJ("routine")="MIOOSAPI"
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,+$GET(STATUS),.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=+$GET(STATUS)
	QUIT
	;
FSLIST(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,STATE,OUT
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fs_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	IF '$$LIST^MIOOSFS(.STATE,$SELECT($GET(TREE("parent"))'="":$GET(TREE("parent")),1:"root"),.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_list_failed",$GET(ERR("error")),.CTX)
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
FSREAD(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,STATE,OUT,ID
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fs_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	SET ID=$SELECT($GET(TREE("id"))'="":$GET(TREE("id")),1:$GET(TREE("path")))
	IF '$$READ^MIOOSFS(.STATE,ID,.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_read_failed",$GET(ERR("error")),.CTX)
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
FSWRITE(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,STATE,OUT
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fs_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	IF '$$WRITE^MIOOSFS(.STATE,$SELECT($GET(TREE("parent"))'="":$GET(TREE("parent")),1:"root"),$GET(TREE("name")),$GET(TREE("content")),$GET(TREE("mime"),"text/plain"),.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_write_failed",$GET(ERR("error")),.CTX)
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
FSUPLOAD(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,OUT,MP,CT,IDX,PARENT,NAME,MIME
	SET ERR("routine")="MIOOSAPI"
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fs_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	SET CT=$$LOW^MIOUTIL($GET(REQ("hdr","content-type")))
	IF CT'["multipart/form-data" DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_upload_content_type","multipart_required",.CTX)
	IF '$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_multipart",$GET(ERR("error"),"invalid_multipart"),.CTX)
	SET IDX=$$UPLOADFILE(.MP)
	IF IDX<1 DO  QUIT
	. DO FREE^MIOHTTPMPU(.MP)
	. DO RESPERR(.DEV,.CONF,400,"upload_file_missing","upload_file_missing",.CTX)
	SET PARENT=$GET(MP("field","parent"))
	IF PARENT="" SET PARENT=$GET(STATE("fsHomeId"),"root")
	SET NAME=$$UPLOADNAME(.MP,IDX)
	SET MIME=$GET(MP("part",IDX,"ctype")) IF MIME="" SET MIME="application/octet-stream"
	IF '$$WRITEPART^MIOOSFS(.STATE,PARENT,NAME,MIME,.MP,IDX,.OUT,.ERR) DO  QUIT
	. DO FREE^MIOHTTPMPU(.MP)
	. DO RESPERR(.DEV,.CONF,403,"fs_upload_failed",$GET(ERR("error"),"fs_upload_failed"),.CTX)
	DO FREE^MIOHTTPMPU(.MP)
	SET OUT("ok")=1,OUT("uploaded")=1
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
UPLOADFILE(MP)
	NEW I,OUT
	SET I=0,OUT=0
	FOR  SET I=$ORDER(MP("part",I)) QUIT:I'>0  DO  QUIT:OUT>0
	. IF $GET(MP("part",I,"filename"))'="" SET OUT=I
	QUIT OUT
	;
UPLOADNAME(MP,IDX)
	NEW X
	SET X=$GET(MP("part",+$GET(IDX),"filename"))
	IF X="" SET X=$GET(MP("part",+$GET(IDX),"name"),"upload.bin")
	IF X["/" SET X=$PIECE(X,"/",$L(X,"/"))
	IF X[$CHAR(92) SET X=$PIECE(X,$CHAR(92),$L(X,$CHAR(92)))
	IF X="" SET X="upload.bin"
	QUIT X
	;
FSUPBEGIN(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,STATE,OUT,PARENT,NAME,MIME,TOTAL,ENC
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fs_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	SET PARENT=$SELECT($GET(TREE("parent"))'="":$GET(TREE("parent")),1:$GET(STATE("fsHomeId"),"root"))
	SET NAME=$GET(TREE("name")),MIME=$GET(TREE("mime"),"application/octet-stream")
	SET TOTAL=+$GET(TREE("totalBytes")),ENC=$GET(TREE("encoding"),"base64")
	IF '$$BEGIN^MIOOSFSUP(.STATE,.CONF,PARENT,NAME,MIME,TOTAL,ENC,.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_upload_begin_failed",$GET(ERR("error")),.CTX)
	SET OUT("ok")=1
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
FSUPCHUNK(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,STATE,OUT
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fs_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	IF '$$CHUNK^MIOOSFSUP(.STATE,.CONF,$GET(TREE("uploadId")),+$GET(TREE("index")),$GET(TREE("data")),+$GET(TREE("bytes")),.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_upload_chunk_failed",$GET(ERR("error")),.CTX)
	SET OUT("ok")=1
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
FSUPSTATUS(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,STATE,OUT
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fs_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	IF '$$STATUS^MIOOSFSUP(.STATE,.CONF,$GET(TREE("uploadId")),.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_upload_status_failed",$GET(ERR("error")),.CTX)
	SET OUT("ok")=1
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
FSUPCOMMIT(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,STATE,OUT
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fs_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	IF '$$COMMIT^MIOOSFSUP(.STATE,.CONF,$GET(TREE("uploadId")),.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_upload_commit_failed",$GET(ERR("error")),.CTX)
	SET OUT("ok")=1
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
FSUPABORT(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,STATE,OUT
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fs_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	IF '$$ABORT^MIOOSFSUP(.STATE,.CONF,$GET(TREE("uploadId")),.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_upload_abort_failed",$GET(ERR("error")),.CTX)
	SET OUT("ok")=1
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
FSCOPY(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,STATE,OUT
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fs_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	IF '$$COPY^MIOOSFS(.STATE,$GET(TREE("id")),$GET(TREE("parent")),$GET(TREE("name")),.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_copy_failed",$GET(ERR("error")),.CTX)
	SET OUT("ok")=1
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
FSMKDIR(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,STATE,OUT
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fs_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	IF '$$MKDIR^MIOOSFS(.STATE,$SELECT($GET(TREE("parent"))'="":$GET(TREE("parent")),1:"root"),$GET(TREE("name")),.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_mkdir_failed",$GET(ERR("error")),.CTX)
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
FSHASH(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,STATE,OUT,ID
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fs_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	SET ID=$SELECT($GET(TREE("id"))'="":$GET(TREE("id")),1:$GET(TREE("path")))
	IF '$$HASH^MIOOSFS(.STATE,ID,.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_hash_failed",$GET(ERR("error")),.CTX)
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
FSSEARCH(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,STATE,OUT
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fs_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	IF '$$SEARCH^MIOOSFS(.STATE,$SELECT($GET(TREE("parent"))'="":$GET(TREE("parent")),1:"root"),$GET(TREE("query")),+$GET(TREE("recurse")),+$GET(TREE("limit")),.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_search_failed",$GET(ERR("error")),.CTX)
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
FSMETA(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,STATE,OUT,ID
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fs_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	SET ID=$SELECT($GET(TREE("id"))'="":$GET(TREE("id")),1:$GET(TREE("path")))
	IF '$$META^MIOOSFS(.STATE,ID,.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_meta_failed",$GET(ERR("error")),.CTX)
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
FSRENAME(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,STATE,OUT
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fs_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	IF '$$RENAME^MIOOSFS(.STATE,$GET(TREE("id")),$GET(TREE("name")),.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_rename_failed",$GET(ERR("error")),.CTX)
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
FSMOVE(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,STATE,OUT
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fs_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	IF '$$MOVE^MIOOSFS(.STATE,$GET(TREE("id")),$GET(TREE("parent")),.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_move_failed",$GET(ERR("error")),.CTX)
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
FSDELETE(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,STATE,OUT
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fs_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	IF '$$DELETE^MIOOSFS(.STATE,$GET(TREE("id")),.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_delete_failed",$GET(ERR("error")),.CTX)
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
	;
FSDOWNLOAD(DEV,CONF,REQ,CTX)
	DO FSBLOB(.DEV,.CONF,.REQ,.CTX,"attachment")
	QUIT
	;
FSPREVIEW(DEV,CONF,REQ,CTX)
	DO FSBLOB(.DEV,.CONF,.REQ,.CTX,"inline")
	QUIT
	;
FSBLOB(DEV,CONF,REQ,CTX,DISPOSITION)
	NEW META,ERR,HEAD,STATUS,TOTAL,START,END,COUNT,CHUNK,POS,NEED,SLICE,READ,FERR
	IF '$$FSFILECTX(.CONF,.REQ,.CTX,.META,.ERR,$GET(DISPOSITION)) DO  QUIT
	. DO FSRESPERR(.DEV,.CONF,.CTX,.ERR)
	SET STATUS=+$GET(META("status"),200)
	SET TOTAL=+$GET(META("size"),0)
	SET START=+$GET(META("start"),0)
	SET END=+$GET(META("end"),$SELECT(TOTAL>0:TOTAL-1,1:0))
	SET COUNT=+$GET(META("count"),0)
	SET HEAD("Content-Type")=$GET(META("mime"),"application/octet-stream")
	SET HEAD("Accept-Ranges")="bytes"
	SET HEAD("Cache-Control")="private, no-store, max-age=0"
	SET HEAD("Pragma")="no-cache"
	SET HEAD("X-Content-Type-Options")="nosniff"
	IF $GET(META("disposition"))'="" SET HEAD("Content-Disposition")=$GET(META("disposition"))
	IF STATUS=206 SET HEAD("Content-Range")="bytes "_START_"-"_END_"/"_TOTAL
	DO STREAMBEGIN^MIOHTTP(.DEV,.CONF,STATUS,.HEAD,$GET(CTX("request_id")),.CTX,$GET(REQ("method")))
	IF COUNT<1 DO  QUIT
	. DO STREAMEND^MIOHTTP(.DEV)
	. DO FSCTXMETA(.CTX,$GET(DISPOSITION),STATUS,START,END,COUNT,TOTAL)
	SET CHUNK=+$GET(CONF("mioos","download","httpChunkBytes"),1048576)
	IF CHUNK<1024 SET CHUNK=1024
	IF CHUNK>1048576 SET CHUNK=1048576
	SET POS=START
	FOR  QUIT:POS>END  DO
	. SET NEED=END-POS+1 IF NEED>CHUNK SET NEED=CHUNK
	. KILL FERR SET SLICE="",READ=0
	. IF '$$READRANGE^MIOOSFS($GET(META("id")),POS,NEED,.SLICE,.READ,.FERR) SET POS=END+1 QUIT
	. IF READ<1 SET POS=END+1 QUIT
	. DO STREAMWRITE^MIOHTTP(.DEV,SLICE)
	. SET POS=POS+READ
	DO STREAMEND^MIOHTTP(.DEV)
	DO FSCTXMETA(.CTX,$GET(DISPOSITION),STATUS,START,END,COUNT,TOTAL)
	QUIT
	;
FSFILECTX(CONF,REQ,CTX,OUT,ERR,DISPOSITION)
	NEW STATE,SERR,ID,RID,TOTAL,MIME,NAME,RNG,RS,RE,STATUS
	KILL OUT
	SET ERR("routine")="MIOOSAPI"
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.SERR) DO  QUIT 0
	. SET ERR("status")=500,ERR("error")=$GET(SERR("error"),"fs_state_error"),ERR("code")="fs_state_error"
	SET ID=$GET(REQ("query","id")) IF ID="" SET ID=$GET(REQ("query","path"))
	IF ID="" DO  QUIT 0
	. SET ERR("status")=400,ERR("error")="file_missing",ERR("code")="file_missing"
	IF '$$RESOLVE^MIOOSFS(ID,.RID,.SERR) DO  QUIT 0
	. SET ERR("status")=404,ERR("error")=$GET(SERR("error"),"not_found"),ERR("code")="not_found"
	IF '$$CAN^MIOOSFS(RID,.STATE,"read") DO  QUIT 0
	. SET ERR("status")=403,ERR("error")="access_denied",ERR("code")="access_denied"
	IF $$FIELD^MIOOSFS(RID,1)'="file" DO  QUIT 0
	. SET ERR("status")=400,ERR("error")="not_file",ERR("code")="not_file"
	SET TOTAL=+$$FIELD^MIOOSFS(RID,5)
	SET MIME=$$FIELD^MIOOSFS(RID,4) IF MIME="" SET MIME="application/octet-stream"
	SET NAME=$$FIELD^MIOOSFS(RID,3) IF NAME="" SET NAME="download.bin"
	SET STATUS=200,RS=0,RE=$SELECT(TOTAL>0:TOTAL-1,1:0)
	SET RNG=$GET(REQ("hdr","range")) IF RNG="" SET RNG=$GET(REQ("hdr","Range"))
	IF RNG'="" DO
	. IF '$$PARSERANGE^MIOSTATIC(RNG,TOTAL,.RS,.RE) SET STATUS=416,ERR("status")=416,ERR("error")="range_not_satisfiable",ERR("code")="range_not_satisfiable",ERR("total")=TOTAL QUIT
	. SET STATUS=206
	IF STATUS=416 QUIT 0
	SET OUT("id")=RID
	SET OUT("name")=NAME
	SET OUT("path")=$$PATH^MIOOSFS(RID)
	SET OUT("mime")=MIME
	SET OUT("size")=TOTAL
	SET OUT("status")=STATUS
	SET OUT("start")=RS
	SET OUT("end")=RE
	SET OUT("count")=$SELECT(TOTAL<1:0,1:(RE-RS)+1)
	SET OUT("dispositionMode")=$SELECT($GET(DISPOSITION)'="":$GET(DISPOSITION),1:"attachment")
	SET OUT("disposition")=$$DISPHDR(NAME,$GET(OUT("dispositionMode")))
	QUIT 1
	;
FSCTXMETA(CTX,DISPOSITION,STATUS,START,END,COUNT,TOTAL)
	NEW ROOT
	SET CTX("status")=+$GET(STATUS)
	SET ROOT=$SELECT($$LOW^MIOUTIL($GET(DISPOSITION))="inline":"fsPreview",1:"fsDownload")
	SET CTX(ROOT,"status")=+$GET(STATUS)
	SET CTX(ROOT,"start")=+$GET(START)
	SET CTX(ROOT,"end")=+$GET(END)
	SET CTX(ROOT,"count")=+$GET(COUNT)
	SET CTX(ROOT,"total")=+$GET(TOTAL)
	QUIT
	;
FSRESPERR(DEV,CONF,CTX,ERR)
	NEW STATUS,HEAD
	SET STATUS=+$GET(ERR("status"),500)
	IF STATUS=416 DO  QUIT
	. SET HEAD("Content-Range")="bytes */"_+$GET(ERR("total"),0)
	. DO RESPX^MIOHTTP(.DEV,.CONF,416,.HEAD,"",$GET(CTX("request_id")),.CTX)
	. SET CTX("status")=416
	DO RESPERR(.DEV,.CONF,STATUS,$GET(ERR("code"),$GET(ERR("error"),"request_failed")),$GET(ERR("error"),"request_failed"),.CTX)
	QUIT
	;
DISPHDR(NAME,MODE)
	NEW SAFE,KIND
	SET SAFE=$$SAFEFNAME($GET(NAME))
	SET KIND=$SELECT($$LOW^MIOUTIL($GET(MODE))="inline":"inline",1:"attachment")
	QUIT KIND_"; filename="_$CHAR(34)_SAFE_$CHAR(34)
	;
SAFEFNAME(NAME)
	NEW X
	SET X=$GET(NAME)
	IF X="" SET X="download.bin"
	SET X=$TRANSLATE(X,$CHAR(13,10,9)_$CHAR(34),"")
	IF X["/" SET X=$PIECE(X,"/",$L(X,"/"))
	IF X[$CHAR(92) SET X=$PIECE(X,$CHAR(92),$L(X,$CHAR(92)))
	IF X="" SET X="download.bin"
	QUIT X
	;
	;