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
	DO TOKSTATUS^MIOOSAUTH(.CONF,TOKEN,$NAME(OBJ("tokenStatus")))
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
	DO TOKSTATUS^MIOOSAUTH(.CONF,TOKEN,$NAME(OBJ("tokenStatus")))
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
	IF '''$$GUESTSIGNIN^MIOOSAUTH(.CONF,.TOKEN,.ERR) DO  QUIT
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
