MIOIDEWS ; MIO IDE WebSocket RPC (transport-facing entrypoints + dispatcher)
 ;
 ; Copyright (c) MUMPS.IO
 ; SPDX-License-Identifier: MIT
 ;
 ; ---------------------------------------------------------------------------
 ; PURPOSE
 ; ---------------------------------------------------------------------------
 ; This routine is the single "glue" point between your MUMPS WebSocket server
 ; and the IDE UI. Your WS server should call these entry points:
 ;
 ;   S sid=$$ONOPEN^MIOIDEWS(.conn)
 ;   S reply=$$ONMESSAGE^MIOIDEWS(sid,frameText)
 ;   D ONCLOSE^MIOIDEWS(sid)
 ;
 ; The IDE uses JSON request/response frames. This routine:
 ;   - validates envelopes
 ;   - dispatches RPC methods
 ;   - returns a JSON response (or "" for notifications)
 ;   - tracks lightweight session state in ^MIOIDE("ws",...)
 ;
 ; ---------------------------------------------------------------------------
 ; SESSION STORAGE
 ; ---------------------------------------------------------------------------
 ; ^MIOIDE("ws","sess",sid,"created")   = ISO timestamp
 ; ^MIOIDE("ws","sess",sid,"lastSeen")  = ISO timestamp
 ; ^MIOIDE("ws","sess",sid,"ip")        = optional
 ; ^MIOIDE("ws","sess",sid,"name")      = optional client name
 ; ^MIOIDE("ws","sess",sid,"auth")      = 1/0 (optional)
 ;
 ; ---------------------------------------------------------------------------
 ; RPC ENVELOPE
 ; ---------------------------------------------------------------------------
 ; Request:
 ;   { "type":"rpc", "id":"<string>", "method":"<string>", "params":{...} }
 ;
 ; Notification (no reply expected):
 ;   { "type":"notify", "method":"<string>", "params":{...} }
 ;
 ; Response:
 ;   { "type":"rpc", "id":"<string>", "ok":1, "result":{...} }
 ;   { "type":"rpc", "id":"<string>", "ok":0, "error":{"code":"...","message":"..."} }
 ;
 ; ---------------------------------------------------------------------------
 ; INITIAL METHODS
 ; ---------------------------------------------------------------------------
 ;  ping
 ;  hello                     -> server version/capabilities
 ;  ide/setClientInfo          -> store client name/version
 ;  mumps/diagnostics          -> markers
 ;  mumps/completion           -> completion items
 ;  mumps/hover                -> hover info
 ;  mumps/documentSymbols      -> outline
 ;  mumps/definition           -> goto def
 ;  mumps/references           -> find refs
 ;  mumps/format               -> format document
 ;
 Q
 ;
ONOPEN(CONN) ; -> sid
 N sid,now
 S sid=$$UUID^MIOIDEUTIL()
 S now=$$NOWISO^MIOIDEUTIL()
 S ^MIOIDE("ws","sess",sid,"created")=now
 S ^MIOIDE("ws","sess",sid,"lastSeen")=now
 I $D(CONN("ip")) S ^MIOIDE("ws","sess",sid,"ip")=$G(CONN("ip"))
 Q sid
 ;
ONCLOSE(SID) ;
 K ^MIOIDE("ws","sess",SID)
 Q
 ;
ONMESSAGE(SID,JSON) ; -> reply JSON or "" (for notifications)
 N now S now=$$NOWISO^MIOIDEUTIL()
 S ^MIOIDE("ws","sess",SID,"lastSeen")=now
 Q $$DISPATCH(SID,JSON)
 ;
DISPATCH(SID,JSON) ; -> JSON response (or "" for notify)
 N $ETRAP S $ETRAP="Q $$TRAP^MIOIDEWS("""_$G(SID)_""")"
 N req,typ,id,method,params
 K req
 I '$$PARSE(JSON,.req) Q $$ERR("","parse_failed","Invalid JSON")
 S typ=$G(req("type"))
 S method=$G(req("method"))
 M params=req("params")
 I typ="notify" D  Q ""
 . D NOTIFY(SID,method,.params)
 I typ'="rpc" Q $$ERR("","bad_request","Missing type=rpc")
 S id=$G(req("id"))
 I id="" Q $$ERR("","bad_request","Missing id")
 I method="" Q $$ERR(id,"bad_request","Missing method")
 ;
 N result K result
 I method="ping" D  Q $$OK(id,.result)
 . S result("pong")=1
 I method="hello" D  Q $$OK(id,.result)
 . S result("server")="MIOIDE"
 . S result("version")="0.1"
 . S result("time")=$$NOWISO^MIOIDEUTIL()
 . S result("capabilities","mumps")=1
 . S result("capabilities","format")=1
 . S result("capabilities","definition")=1
 . S result("capabilities","references")=1
 I method="ide/setClientInfo" D  Q $$OK(id,.result)
 . S ^MIOIDE("ws","sess",SID,"name")=$G(params("name"))
 . S ^MIOIDE("ws","sess",SID,"clientVersion")=$G(params("version"))
 . S result("saved")=1
 I method="mumps/diagnostics" D  Q $$OK(id,.result)
 . D DIAG^MIOIDEMP(.params,.result)
 I method="mumps/completion" D  Q $$OK(id,.result)
 . D COMP^MIOIDEMP(.params,.result)
 I method="mumps/hover" D  Q $$OK(id,.result)
 . D HOVER^MIOIDEMP(.params,.result)
 I method="mumps/documentSymbols" D  Q $$OK(id,.result)
 . D SYMBOLS^MIOIDEMP(.params,.result)
 I method="mumps/definition" D  Q $$OK(id,.result)
 . D DEF^MIOIDEMP(.params,.result)
 I method="mumps/references" D  Q $$OK(id,.result)
 . D REFS^MIOIDEMP(.params,.result)
 I method="mumps/format" D  Q $$OK(id,.result)
 . D FORMAT^MIOIDEMP(.params,.result)
 Q $$ERR(id,"method_not_found","Unknown method: "_method)
 ;
NOTIFY(SID,method,params) ;
 I method="ide/telemetry" Q
 Q
 ;
TRAP(SID) ;
 N msg S msg=$G($ZE,$G($ZERROR,"error"))
 Q $$ERR("","server_error","Unhandled error: "_msg)
 ;
OK(id,result) ;
 N res
 S res("type")="rpc"
 S res("id")=id
 S res("ok")=1
 M res("result")=result
 Q $$ENCODE(.res)
 ;
ERR(id,code,message)
 N res
 S res("type")="rpc"
 S res("id")=$G(id)
 S res("ok")=0
 S res("error","code")=code
 S res("error","message")=message
 Q $$ENCODE(.res)
 ;
PARSE(JSON,OBJ) ; -> 1/0
 N ok S ok=0
 I $T(DECODE^MIOJSON)'="" D  Q ok
 . D DECODE^MIOJSON(JSON,.OBJ) S ok=1
 I $T(DECODE^%JSON)'="" D  Q ok
 . D DECODE^%JSON(JSON,.OBJ) S ok=1
 Q ok
 ;
ENCODE(OBJ) ; -> JSON
 I $T(ENCODE^MIOJSON)'="" Q $$ENCODE^MIOJSON(.OBJ)
 I $T(ENCODE^%JSON)'="" Q $$ENCODE^%JSON(.OBJ)
 Q "{""type"":""rpc"",""id"":"""",""ok"":0,""error"":{""code"":""json_encoder_missing"",""message"":""No JSON encoder configured""}}"
