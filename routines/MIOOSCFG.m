MIOOSCFG ; MIOOS server-backed system settings registry
	QUIT
	;
APPLY(CONF)
	NEW KEY,DEF,VAL
	SET KEY=""
	FOR  SET KEY=$ORDER(^MIO("MIOOS","SETTING","VALUE",KEY)) QUIT:KEY=""  DO
	. KILL DEF
	. IF '$$DEFKEY(KEY,.DEF) QUIT
	. SET VAL=$GET(^MIO("MIOOS","SETTING","VALUE",KEY,"value"),$GET(DEF("default")))
	. DO SETCONF(.CONF,.DEF,VAL)
	QUIT
	;
EXPORT(CONF,STATE,OUT)
	NEW DEFS,I,KEY,CUR
	KILL OUT,DEFS
	DO DEFS(.DEFS)
	SET OUT("ok")=1
	SET OUT("contract")="mioos-system-settings-v1"
	SET OUT("adminRequired")=1
	SET OUT("canSave")=+$GET(STATE("authAdmin"),0)
	SET OUT("description")="Server-side MIOOS settings. Values are sanitized and persisted in globals; no browser-only setting is authoritative."
	DO GROUPS(.OUT)
	SET I=0
	FOR  SET I=$ORDER(DEFS("settings",I)) QUIT:'I  DO
	. SET KEY=$GET(DEFS("settings",I,"key"))
	. MERGE OUT("settings",I)=DEFS("settings",I)
	. SET CUR=$$CUR(.CONF,.DEFS,I)
	. SET OUT("settings",I,"value")=CUR
	. SET OUT("values",KEY)=CUR
	. SET OUT("settings",I,"stored")=+$DATA(^MIO("MIOOS","SETTING","VALUE",KEY,"value"))
	. SET OUT("settings",I,"updatedAt")=$GET(^MIO("MIOOS","SETTING","VALUE",KEY,"updatedAt"))
	QUIT 1
	;
SAVE(CONF,STATE,IN,OUT,ERR)
	NEW KEY,RAW,DEF,VAL,CHANGED,ROOT,WHEN,WHO,CLEAN
	KILL OUT,ERR,CLEAN
	IF '+$GET(STATE("authAdmin"),0) SET ERR("error")="settings_admin_required" QUIT 0
	SET ROOT=$NAME(IN("values"))
	IF '$DATA(@ROOT) SET ROOT=$NAME(IN("settings"))
	IF '$DATA(@ROOT),$GET(IN("key"))'="" SET @ROOT@($GET(IN("key")))=$GET(IN("value"))
	IF '$DATA(@ROOT) SET ERR("error")="settings_payload_missing" QUIT 0
	SET KEY=""
	FOR  SET KEY=$ORDER(@ROOT@(KEY)) QUIT:KEY=""  DO  QUIT:$GET(ERR("error"))'=""
	. KILL DEF
	. IF '+$$DEFKEY(KEY,.DEF) SET ERR("error")="unknown_setting",ERR("key")=KEY QUIT
	. SET RAW=$GET(@ROOT@(KEY))
	. IF '+$$SAN(.DEF,RAW,.VAL,.ERR) SET ERR("key")=KEY QUIT
	. SET CLEAN(KEY)=VAL
	IF $GET(ERR("error"))'="" QUIT 0
	SET WHEN=$$NOWISO^MIOUTIL(),WHO=$GET(STATE("principal"),"system"),CHANGED=0
	SET KEY=""
	FOR  SET KEY=$ORDER(CLEAN(KEY)) QUIT:KEY=""  DO
	. KILL DEF
	. DO DEFKEY(KEY,.DEF)
	. SET VAL=CLEAN(KEY)
	. SET ^MIO("MIOOS","SETTING","VALUE",KEY,"value")=VAL
	. SET ^MIO("MIOOS","SETTING","VALUE",KEY,"updatedAt")=WHEN
	. SET ^MIO("MIOOS","SETTING","VALUE",KEY,"updatedBy")=WHO
	. DO SETCONF(.CONF,.DEF,VAL)
	. SET CHANGED=CHANGED+1
	SET OUT("changed")=CHANGED
	DO EXPORT(.CONF,.STATE,.OUT)
	SET OUT("saved")=1
	QUIT 1
	;
GROUPS(OUT)
	SET OUT("groups",1,"key")="modules"
	SET OUT("groups",1,"title")="Modules and App Catalogue"
	SET OUT("groups",1,"description")="Enable the App Catalogue, module launcher, and dynamic module windows."
	SET OUT("groups",2,"key")="transport"
	SET OUT("groups",2,"title")="Transport, uploads, and VFS"
	SET OUT("groups",2,"description")="HTTP-first bulk transfer settings with WebSocket controls. Numeric values are clamped server-side."
	SET OUT("groups",3,"key")="websocket"
	SET OUT("groups",3,"title")="WebSocket pool"
	SET OUT("groups",3,"description")="Session socket pool, heartbeat, diagnostics, and inflight behavior."
	SET OUT("groups",4,"key")="desktop"
	SET OUT("groups",4,"title")="Desktop shell"
	SET OUT("groups",4,"description")="User-facing shell presentation defaults safe to change from the GUI."
	SET OUT("groups",5,"key")="security"
	SET OUT("groups",5,"title")="Security and audit"
	SET OUT("groups",5,"description")="Operational audit and protected management limits."
	SET OUT("groups",6,"key")="developer"
	SET OUT("groups",6,"title")="Developer diagnostics"
	SET OUT("groups",6,"description")="Developer-only diagnostics and snapshot sizes. Keep production defaults conservative."
	QUIT
	;
DEFS(OUT)
	KILL OUT
	DO ADD(.OUT,"mioos.modules.enabled","modules","Module system","boolean",1,"","","","mioos|modules|enabled","Enables server-authored MIOOS UI modules in boot state and the module catalogue API.","Next bootstrap refreshes launch entries.")
	DO ADD(.OUT,"mioos.modules.appCatalogEnabled","modules","App Catalogue visible","boolean",1,"","","","mioos|modules|appCatalogEnabled","Shows the App Catalogue launcher and the catalogue window when the module system is enabled.","Immediate after refresh.")
	DO ADD(.OUT,"mioos.modules.dynamicWindows","modules","Dynamic module windows","boolean",1,"","","","mioos|modules|dynamicWindows","Allows registered modules to open in reusable shell windows instead of static placeholders.","Immediate for newly opened windows.")
	DO ADD(.OUT,"mioos.modules.launcher","modules","Module launcher mode","enum","desktop-icons-and-menu","","","desktop-icons-and-menu,start-menu-only,hidden","mioos|modules|launcher","Controls where module launchers appear. Hidden keeps APIs enabled but removes launcher surfaces.","Next bootstrap refreshes launcher surfaces.")
	DO ADD(.OUT,"mioos.fs.transport","transport","File transfer transport","enum","http-and-websocket","","","http-and-websocket,http-only","mioos|fs|transport","Bulk file data stays HTTP-first. WebSockets are reserved for control and realtime state.","Applies to new transfer operations.")
	DO ADD(.OUT,"mioos.upload.chunkBytes","transport","HTTP upload chunk bytes","integer",860000,131072,4194304,"","mioos|upload|chunkBytes","Chunk size for HTTP upload slices. The server clamps values to avoid MAXSTRING and memory pressure.","Applies to new uploads.")
	DO ADD(.OUT,"mioos.upload.concurrency","transport","HTTP upload concurrency","integer",3,1,8,"","mioos|upload|concurrency","Number of parallel HTTP chunk uploads per transfer.","Applies to new uploads.")
	DO ADD(.OUT,"mioos.upload.batchSize","transport","Upload batch size","integer",2,1,16,"","mioos|upload|batchSize","Controls how many chunks are grouped for transfer center bookkeeping.","Applies to new uploads.")
	DO ADD(.OUT,"mioos.upload.maxInflightChunks","transport","Max inflight upload chunks","integer",6,1,32,"","mioos|upload|maxInflightChunks","Upper bound for chunks queued or in flight for one upload.","Applies to new uploads.")
	DO ADD(.OUT,"mioos.websocket.maxSocketsPerSession","websocket","Max sockets per session","integer",9,1,24,"","mioos|websocket|maxSocketsPerSession","Total WebSocket pool cap for one authenticated shell session.","Applies to new sockets.")
	DO ADD(.OUT,"mioos.websocket.coreSockets","websocket","Core sockets","integer",1,1,8,"","mioos|websocket|coreSockets","Reserved sockets for shell control, refresh, and status events.","Applies to new sockets.")
	DO ADD(.OUT,"mioos.websocket.fsSockets","websocket","File-service sockets","integer",1,1,16,"","mioos|websocket|fsSockets","Reserved sockets for VFS control messages. Bulk file bytes still use HTTP.","Applies to new sockets.")
	DO ADD(.OUT,"mioos.websocket.heartbeatSeconds","websocket","Heartbeat seconds","integer",15,5,120,"","mioos|websocket|heartbeatSeconds","Server-advertised heartbeat cadence for session health checks.","Applies to new socket sessions.")
	DO ADD(.OUT,"mioos.websocket.diagnosticsEnabled","websocket","Socket diagnostics","boolean",1,"","","","mioos|websocket|diagnosticsEnabled","Enables the transport diagnostics surface and health summaries.","Immediate after refresh.")
	DO ADD(.OUT,"mioos.desktop.density","desktop","Desktop density","enum","comfortable","","","compact,comfortable,spacious","mioos|desktop|density","Default shell density used by boot state and theme profile generation.","Next bootstrap refreshes shell defaults.")
	DO ADD(.OUT,"mioos.desktop.startMenuStyle","desktop","Start menu style","enum","launcher-foundation","","","launcher-foundation,xp-two-column,classic,popup","mioos|desktop|startMenuStyle","Server-authored start menu style token for shell first paint and future theme defaults.","Next bootstrap refreshes first paint.")
	DO ADD(.OUT,"mioos.audit.enabled","security","Audit enabled","boolean",1,"","","","mioos|audit|enabled","Keeps audit capture and reporting surfaces enabled for protected shell operations.","Immediate after refresh.")
	DO ADD(.OUT,"mioos.audit.retainDays","security","Audit retention days","integer",365,7,2555,"","mioos|audit|retainDays","Retention horizon advertised to the audit subsystem. Deployment policy still controls backups and storage.","Applies to future retention jobs.")
	DO ADD(.OUT,"mioos.audit.reportLimit","security","Audit report limit","integer",20,1,500,"","mioos|audit|reportLimit","Maximum rows returned by the audit export route by default.","Immediate.")
	DO ADD(.OUT,"mioos.auth.management.sessionLimit","security","Session admin row limit","integer",20,1,500,"","mioos|auth|management|sessionLimit","Maximum session rows returned in authenticated management views.","Immediate.")
	DO ADD(.OUT,"mioos.auth.management.accountLimit","security","Account admin row limit","integer",20,1,500,"","mioos|auth|management|accountLimit","Maximum account rows returned in authenticated management views.","Immediate.")
	DO ADD(.OUT,"mioos.debug.enabled","developer","Debug center enabled","boolean",0,"","","","mioos|debug|enabled","Enables developer debug snapshots. Keep off in production unless troubleshooting.","Immediate after refresh.")
	DO ADD(.OUT,"mioos.debug.eventLimit","developer","Debug event limit","integer",50,10,1000,"","mioos|debug|eventLimit","Maximum debug events retained in the client-facing debug snapshot.","Immediate.")
	QUIT
	;
ADD(OUT,KEY,GROUP,TITLE,TYPE,DEFAULT,MIN,MAX,ENUM,PATH,DESC,APPLIES)
	NEW N,I,P
	SET N=+$GET(OUT("count"))+1,OUT("count")=N
	SET OUT("settings",N,"key")=KEY
	SET OUT("settings",N,"group")=GROUP
	SET OUT("settings",N,"title")=TITLE
	SET OUT("settings",N,"type")=TYPE
	SET OUT("settings",N,"default")=DEFAULT
	IF $GET(MIN)'="" SET OUT("settings",N,"min")=MIN
	IF $GET(MAX)'="" SET OUT("settings",N,"max")=MAX
	IF $GET(ENUM)'="" DO
	. FOR I=1:1:$LENGTH(ENUM,",") SET OUT("settings",N,"enum",I)=$PIECE(ENUM,",",I)
	SET OUT("settings",N,"path")=PATH
	SET OUT("settings",N,"description")=DESC
	SET OUT("settings",N,"applies")=APPLIES
	SET OUT("settings",N,"safe")=1
	SET OUT("byKey",KEY)=N
	FOR I=1:1:$LENGTH(PATH,"|") SET OUT("settings",N,"pathParts",I)=$PIECE(PATH,"|",I)
	QUIT
	;
DEFKEY(KEY,DEF)
	NEW DEFS,I
	KILL DEF,DEFS
	DO DEFS(.DEFS)
	SET I=+$GET(DEFS("byKey",$GET(KEY)))
	IF I<1 QUIT 0
	MERGE DEF=DEFS("settings",I)
	QUIT 1
	;
CUR(CONF,DEFS,I)
	NEW P1,P2,P3,P4,P5,DEF
	MERGE DEF=DEFS("settings",I)
	SET P1=$GET(DEF("pathParts",1)),P2=$GET(DEF("pathParts",2)),P3=$GET(DEF("pathParts",3)),P4=$GET(DEF("pathParts",4)),P5=$GET(DEF("pathParts",5))
	IF P5'="" QUIT $GET(CONF(P1,P2,P3,P4,P5),$GET(DEF("default")))
	IF P4'="" QUIT $GET(CONF(P1,P2,P3,P4),$GET(DEF("default")))
	IF P3'="" QUIT $GET(CONF(P1,P2,P3),$GET(DEF("default")))
	IF P2'="" QUIT $GET(CONF(P1,P2),$GET(DEF("default")))
	QUIT $GET(CONF(P1),$GET(DEF("default")))
	;
SETCONF(CONF,DEF,VAL)
	NEW P1,P2,P3,P4,P5
	SET P1=$GET(DEF("pathParts",1)),P2=$GET(DEF("pathParts",2)),P3=$GET(DEF("pathParts",3)),P4=$GET(DEF("pathParts",4)),P5=$GET(DEF("pathParts",5))
	IF P5'="" SET CONF(P1,P2,P3,P4,P5)=VAL QUIT
	IF P4'="" SET CONF(P1,P2,P3,P4)=VAL QUIT
	IF P3'="" SET CONF(P1,P2,P3)=VAL QUIT
	IF P2'="" SET CONF(P1,P2)=VAL QUIT
	SET CONF(P1)=VAL
	QUIT
	;
SAN(DEF,RAW,VAL,ERR)
	NEW TYPE,X,LOW,MIN,MAX,I,OK
	KILL ERR SET TYPE=$GET(DEF("type")),X=$$TRIM^MIOUTIL($GET(RAW))
	IF TYPE="boolean" DO  QUIT 1
	. SET LOW=$ZCONVERT(X,"L")
	. SET VAL=$SELECT(LOW="1":1,LOW="true":1,LOW="yes":1,LOW="on":1,LOW="enabled":1,LOW="0":0,LOW="false":0,LOW="no":0,LOW="off":0,LOW="disabled":0,1:+X)
	. SET VAL=$SELECT(+VAL'=0:1,1:0)
	IF TYPE="integer" DO  QUIT 1
	. SET VAL=+X
	. SET MIN=$GET(DEF("min")),MAX=$GET(DEF("max"))
	. IF MIN'="",VAL<MIN SET VAL=+MIN
	. IF MAX'="",VAL>MAX SET VAL=+MAX
	IF TYPE="enum" DO  QUIT OK
	. SET OK=0,I=0,VAL=""
	. FOR  SET I=$ORDER(DEF("enum",I)) QUIT:'I  DO  QUIT:OK
	. . IF X=$GET(DEF("enum",I)) SET VAL=X,OK=1
	. IF 'OK SET ERR("error")="invalid_setting_value",ERR("allowed")="enum"
	SET ERR("error")="invalid_setting_type"
	QUIT 0
	;
