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
GUESTSIGNIN(DEV,CONF,REQ,CTX)
	NEW ERR,TOKEN
	IF '$$GUESTSIGNIN^MIOOSAUTH(.CONF,.TOKEN,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"guest_signin_failed",$GET(ERR("error")),.CTX)
	DO RESPERR(.DEV,.CONF,403,"guest_signin_failed","guest_login_disabled",.CTX)
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
	NEW JSON
	SET JSON=$$BODYTXT(.REQ)
	IF JSON="" SET ERR("routine")="MIOOSAPI",ERR("error")="body_missing" QUIT 0
	IF '$$DECODE^MIOJSON(JSON,.TREE,.ERR) SET ERR("routine")="MIOOSAPI" QUIT 0
	QUIT 1
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
	;
HDR(REQ,NAME)
	QUIT $GET(REQ("hdr",$$LOW^MIOUTIL($GET(NAME))))
	;
BODYRAW(REQ)
	NEW MODE,REF,N,I,TXT
	SET MODE=$GET(REQ("body","mode"),"scalar")
	IF MODE="scalar" QUIT $GET(REQ("body"))
	IF MODE'="global" QUIT ""
	SET REF=$GET(REQ("body","ref")) IF REF="" QUIT ""
	SET N=+$GET(REQ("body","n")),TXT=""
	FOR I=1:1:N SET TXT=TXT_$GET(@REF@(I))
	QUIT TXT
	;
FSUPBEGIN(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,STATE,OUT,PARENT,NAME,MIME,TOTAL,ENC
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fsup_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	SET PARENT=$SELECT($GET(TREE("parent"))'="":$GET(TREE("parent")),1:"root")
	SET NAME=$GET(TREE("name"))
	SET MIME=$GET(TREE("mime"),"application/octet-stream")
	SET TOTAL=+$GET(TREE("totalBytes"))
	SET ENC=$GET(TREE("encoding"),$SELECT($GET(CONF("mioos","upload","chunkTransport"))="http-binary":"binary",1:"base64-dataurl"))
	IF '$$BEGIN^MIOOSFSUP(.STATE,.CONF,PARENT,NAME,MIME,TOTAL,ENC,.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_upload_begin_failed",$GET(ERR("error")),.CTX)
	SET OUT("transport")=$GET(CONF("mioos","upload","chunkTransport"),"http-binary")
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
FSUPCHUNK(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,STATE,OUT,CT,UPID,IDX,BYTES,DATA
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fsup_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	SET CT=$$LOW^MIOUTIL($GET(REQ("hdr","content-type")))
	IF CT["application/json" DO  QUIT
	. IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. . DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	. IF '$$CHUNK^MIOOSFSUP(.STATE,.CONF,$GET(TREE("uploadId")),+$GET(TREE("index")),$GET(TREE("data")),+$GET(TREE("bytes")),.OUT,.ERR) DO  QUIT
	. . DO RESPERR(.DEV,.CONF,403,"fs_upload_chunk_failed",$GET(ERR("error")),.CTX)
	. DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	. SET CTX("status")=200
	SET UPID=$$HDR(.REQ,"x-mioos-upload-id")
	SET IDX=+$$HDR(.REQ,"x-mioos-upload-index")
	SET BYTES=+$$HDR(.REQ,"x-mioos-upload-bytes")
	SET DATA=$$BODYRAW(.REQ)
	IF BYTES<1 SET BYTES=$$BODYLEN^MIOHTTP(.REQ)
	IF '$$CHUNK^MIOOSFSUP(.STATE,.CONF,UPID,IDX,DATA,BYTES,.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_upload_chunk_failed",$GET(ERR("error")),.CTX)
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
FSUPSTATUS(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,STATE,OUT
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fsup_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	IF '$$STATUS^MIOOSFSUP(.STATE,.CONF,$GET(TREE("uploadId")),.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_upload_status_failed",$GET(ERR("error")),.CTX)
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
FSUPCOMMIT(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,STATE,OUT
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fsup_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	IF '$$COMMIT^MIOOSFSUP(.STATE,.CONF,$GET(TREE("uploadId")),.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_upload_commit_failed",$GET(ERR("error")),.CTX)
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
FSUPABORT(DEV,CONF,REQ,CTX)
	NEW TREE,ERR,STATE,OUT
	IF '$$PARSEBODY(.REQ,.TREE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"invalid_json",$GET(ERR("error")),.CTX)
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fsup_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	IF '$$ABORT^MIOOSFSUP(.STATE,.CONF,$GET(TREE("uploadId")),.OUT,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_upload_abort_failed",$GET(ERR("error")),.CTX)
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OUT,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
FSBLOB(DEV,CONF,REQ,CTX)
	NEW STATE,ERR,ID,RID,HEAD,SIZE,MIME,NAME,DL,RS,RE,RLEN,RNG,OK,ETAG,METHOD,H304,H416,H206,H200,SERR,STREAM,MEDIAINIT
	IF '$$LOAD^MIOOSST(.CONF,.REQ,.CTX,.STATE,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,500,"fsblob_state_error",$GET(ERR("error")),.CTX)
	IF '$$REQUIREAUTH(.DEV,.CONF,.CTX,.STATE) QUIT
	SET ID=$SELECT($GET(REQ("query","id"))'="":$GET(REQ("query","id")),1:$GET(REQ("query","path")))
	IF '$$RESOLVE^MIOOSFS(ID,.RID,.ERR) DO  QUIT
	. DO RESPERR(.DEV,.CONF,404,"fs_blob_failed",$GET(ERR("error")),.CTX)
	IF '$$CAN^MIOOSFS(RID,.STATE,"read") DO  QUIT
	. DO RESPERR(.DEV,.CONF,403,"fs_blob_failed","access_denied",.CTX)
	IF $$FIELD^MIOOSFS(RID,1)'="file" DO  QUIT
	. DO RESPERR(.DEV,.CONF,400,"fs_blob_failed","not_file",.CTX)
	SET SIZE=+$$FIELD^MIOOSFS(RID,5)
	SET MIME=$$FIELD^MIOOSFS(RID,4)
	IF MIME="" SET MIME="application/octet-stream"
	SET NAME=$$FIELD^MIOOSFS(RID,3)
	SET DL=$$ISTRUE($GET(REQ("query","download")))
	SET METHOD=$$LOW^MIOHTTP($GET(REQ("method"),"GET"))
	SET STREAM=$$LOW^MIOHTTP($GET(REQ("query","stream")))
	SET MEDIAINIT=+$GET(CONF("mioos","download","mediaInitialBytes"),1048576)
	IF MEDIAINIT<65536 SET MEDIAINIT=65536
	SET HEAD("Content-Type")=MIME
	SET HEAD("X-Content-Type-Options")="nosniff"
	SET HEAD("Accept-Ranges")="bytes"
	SET HEAD("Cache-Control")="private, max-age=60"
	SET HEAD("Content-Disposition")=$$DISPHDR(NAME,DL)
	SET ETAG=$GET(^MIO("MIOOS","FS","HASH",RID))
	IF ETAG'="" SET HEAD("ETag")=$CHAR(34)_ETAG_$CHAR(34)
	IF $GET(REQ("hdr","if-none-match"))'="",$GET(HEAD("ETag"))'="",$GET(REQ("hdr","if-none-match"))[$GET(HEAD("ETag")) DO  QUIT
	. MERGE H304=HEAD
	. SET H304("Content-Length")=0
	. DO RESPHEAD^MIOSTATIC(.DEV,.CONF,304,.H304,$GET(CTX("request_id")))
	. SET CTX("status")=304
	SET RNG=$GET(REQ("hdr","range"))
	IF RNG'="" DO  QUIT
	. SET OK=$$PARSERANGE^MIOSTATIC(RNG,SIZE,.RS,.RE)
	. IF 'OK DO  QUIT
	. . MERGE H416=HEAD
	. . SET H416("Content-Range")="bytes */"_SIZE
	. . SET H416("Content-Length")=0
	. . DO RESPHEAD^MIOSTATIC(.DEV,.CONF,416,.H416,$GET(CTX("request_id")))
	. . SET CTX("status")=416
	. SET RLEN=(RE-RS)+1
	. MERGE H206=HEAD
	. SET H206("Content-Range")="bytes "_RS_"-"_RE_"/"_SIZE
	. SET H206("Content-Length")=RLEN
	. DO RESPHEAD^MIOSTATIC(.DEV,.CONF,206,.H206,$GET(CTX("request_id")))
	. IF METHOD'="head" DO SENDVFS(.DEV,.CONF,RID,RS,RLEN,.SERR)
	. SET CTX("status")=206
	IF RNG="",METHOD="get",STREAM="media",$$ISMEDIAMIME(MIME),SIZE>MEDIAINIT DO  QUIT
	. SET RS=0,RE=MEDIAINIT-1
	. IF RE<SIZE SET RE=SIZE-1 ;IF RE'>=SIZE SET RE=SIZE-1
	. SET RLEN=(RE-RS)+1
	. MERGE H206=HEAD
	. SET H206("Content-Range")="bytes "_RS_"-"_RE_"/"_SIZE
	. SET H206("Content-Length")=RLEN
	. DO RESPHEAD^MIOSTATIC(.DEV,.CONF,206,.H206,$GET(CTX("request_id")))
	. DO SENDVFS(.DEV,.CONF,RID,RS,RLEN,.SERR)
	. SET CTX("status")=206
	MERGE H200=HEAD
	SET H200("Content-Length")=SIZE
	DO RESPHEAD^MIOSTATIC(.DEV,.CONF,200,.H200,$GET(CTX("request_id")))
	IF METHOD'="head" DO SENDVFS(.DEV,.CONF,RID,0,SIZE,.SERR)
	SET CTX("status")=200
	QUIT
	;
SENDVFS(DEV,CONF,RID,OFFSET,LEN,ERR)
	NEW CHSZ,POS,END,IDX,SEG,OFFINSEG,TAKE,PART,SEND,TOTAL
	SET ERR("routine")="MIOOSAPI"
	SET TOTAL=+$$FIELD^MIOOSFS(RID,5)
	SET CHSZ=$$STORECHUNK^MIOOSFS(RID,.CONF)
	IF CHSZ<2048 SET CHSZ=2048
	SET POS=+$GET(OFFSET)
	IF POS<0 SET POS=0
	SET LEN=+$GET(LEN)
	IF LEN<1 QUIT
	SET END=POS+LEN-1
	IF END'<TOTAL SET END=TOTAL-1
	FOR  QUIT:POS>END  DO  QUIT:$DATA(ERR("error"))
	. SET IDX=(POS\CHSZ)+1
	. SET SEG=$GET(^MIO("MIOOS","FS","DATA",RID,IDX))
	. IF SEG="" SET ERR("error")="fs_blob_read_failed",ERR("detail")=IDX QUIT
	. SET OFFINSEG=(POS#CHSZ)+1
	. SET TAKE=($LENGTH(SEG)-OFFINSEG)+1
	. IF TAKE>(END-POS+1) SET TAKE=(END-POS+1)
	. IF TAKE<1 SET ERR("error")="fs_blob_read_stalled",ERR("detail")=POS QUIT
	. SET PART=$SELECT(OFFINSEG=1&(TAKE=$LENGTH(SEG)):SEG,1:$EXTRACT(SEG,OFFINSEG,OFFINSEG+TAKE-1))
	. SET SEND=$LENGTH(PART)
	. IF SEND<1 SET ERR("error")="fs_blob_read_stalled",ERR("detail")=POS QUIT
	. DO WOUT^MIOSTATIC(.DEV,$GET(PART))
	. SET POS=POS+SEND
	QUIT
	;
ISTRUE(X)
	NEW V
	SET V=$$LOW^MIOUTIL($GET(X))
	QUIT $SELECT(V="1":1,V="true":1,V="yes":1,V="y":1,1:0)
	;
DISPHDR(NAME,DL)
	NEW SAFE,MODE
	SET SAFE=$$SAFENAME($GET(NAME))
	IF SAFE="" SET SAFE="download.bin"
	SET MODE=$SELECT(+$GET(DL)=1:"attachment",1:"inline")
	QUIT MODE_"; filename="_$CHAR(34)_SAFE_$CHAR(34)
	;
SAFENAME(NAME)
	NEW X,I,C,OUT
	SET X=$PIECE($GET(NAME),"/",$L($GET(NAME),"/"))
	SET X=$PIECE(X,"\\",$L(X,"\\"))
	SET OUT=""
	FOR I=1:1:$L(X) SET C=$E(X,I) DO
	. IF $A(C)<32 QUIT
	. IF C=":"!(C="*")!(C="?")!(C=$CHAR(34))!(C="<")!(C=">")!(C="|") QUIT
	. SET OUT=OUT_C
	QUIT OUT
	;
ISMEDIAMIME(MIME)
	NEW X
	SET X=$$LOW^MIOHTTP($GET(MIME))
	QUIT $SELECT($EXTRACT(X,1,6)="audio/":1,$EXTRACT(X,1,6)="video/":1,1:0)
	;
	;