MIOMOSPERM ; MIOMOS roles and permissions
	QUIT
	;
HAS(STATE,PERM)
	NEW ROLES
	SET ROLES=$GET(STATE("roles"))
	QUIT $$HASCSV(ROLES,$GET(PERM))
	;
HASCSV(ROLES,PERM)
	NEW I,R,OK
	IF $GET(PERM)="" QUIT 0
	SET OK=0
	FOR I=1:1:$LENGTH($GET(ROLES),",") DO  QUIT:OK
	. SET R=$$TRIM($PIECE(ROLES,",",I))
	. IF R="" QUIT
	. IF R="admin" SET OK=1 QUIT
	. IF $$ROLEHAS(R,PERM) SET OK=1
	QUIT OK
	;
ROLEHAS(ROLE,PERM)
	IF $GET(ROLE)="admin" QUIT 1
	IF $GET(ROLE)="guest" QUIT $SELECT((PERM="workspace.use")!(PERM="theme.self")!(PERM="settings.self")!(PERM="chat.use"):1,1:0)
	IF $GET(PERM)="workspace.use" QUIT 1
	IF $GET(PERM)="theme.self" QUIT 1
	IF $GET(PERM)="settings.self" QUIT 1
	IF $GET(PERM)="chat.use" QUIT 1
	IF $GET(PERM)="terminal.use" QUIT 1
	IF $GET(PERM)="editor.use" QUIT 1
	IF $GET(ROLE)="developer",((PERM="logs.view")!(PERM="audit.view")!(PERM="logs.export")!(PERM="audit.export")!(PERM="digest.export")!(PERM="retention.manage")!(PERM="permissions.view")!(PERM="theme.manage")!(PERM="user.manage")!(PERM="admin.users.view")!(PERM="admin.users.manage")!(PERM="admin.invites.manage")!(PERM="admin.reset.manage")) QUIT 1
	IF $GET(ROLE)="operator",((PERM="queue.manage")!(PERM="exports.view")) QUIT 1
	IF $GET(ROLE)="auditor",((PERM="logs.view")!(PERM="audit.view")!(PERM="logs.export")!(PERM="audit.export")!(PERM="digest.export")!(PERM="permissions.view")!(PERM="admin.users.view")) QUIT 1
	IF $GET(ROLE)="support",((PERM="logs.view")!(PERM="logs.export")!(PERM="digest.export")!(PERM="chat.moderate")!(PERM="admin.users.view")) QUIT 1
	IF $GET(ROLE)="security",((PERM="logs.view")!(PERM="audit.view")!(PERM="logs.export")!(PERM="audit.export")!(PERM="digest.export")!(PERM="retention.manage")!(PERM="permissions.view")!(PERM="admin.users.view")!(PERM="admin.reset.manage")) QUIT 1
	QUIT 0
	;
PRIMARYROLE(ROLES)
	NEW I,R
	IF $$HASCSV($GET(ROLES),"admin.users.view") QUIT "admin"
	FOR I=1:1:$LENGTH($GET(ROLES),",") DO  QUIT:$GET(R)'=""
	. SET R=$$TRIM($PIECE(ROLES,",",I))
	. IF R="" SET R="" QUIT
	. IF R="admin" SET R="" QUIT
	IF $GET(R)'="" QUIT R
	IF $$HASCSV($GET(ROLES),"workspace.use") QUIT "operator"
	QUIT "guest"
	;
ROLELABEL(ROLE)
	SET ROLE=$$TRIM($GET(ROLE))
	IF ROLE="admin" QUIT "Administrator"
	IF ROLE="operator" QUIT "User"
	IF ROLE="guest" QUIT "Guest"
	IF ROLE="developer" QUIT "Developer"
	IF ROLE="auditor" QUIT "Auditor"
	IF ROLE="support" QUIT "Support"
	IF ROLE="security" QUIT "Security"
	QUIT $SELECT(ROLE'="":$$TITLE^MIOMOSAUTH(ROLE),1:"User")
	;
ROLECAT(OUT)
	KILL OUT
	SET OUT(1,"key")="admin",OUT(1,"label")="Administrator",OUT(1,"copy")="Full MIOMOS administration and desktop oversight.",OUT(1,"recommended")=1
	SET OUT(2,"key")="developer",OUT(2,"label")="Developer",OUT(2,"copy")="Operational power user with terminal, logs, and admin visibility.",OUT(2,"recommended")=0
	SET OUT(3,"key")="operator",OUT(3,"label")="User",OUT(3,"copy")="Standard workspace operator with terminal and settings access.",OUT(3,"recommended")=1
	SET OUT(4,"key")="auditor",OUT(4,"label")="Auditor",OUT(4,"copy")="Read-focused audit and log reviewer.",OUT(4,"recommended")=0
	SET OUT(5,"key")="support",OUT(5,"label")="Support",OUT(5,"copy")="Support visibility for troubleshooting and guided operations.",OUT(5,"recommended")=0
	SET OUT(6,"key")="security",OUT(6,"label")="Security",OUT(6,"copy")="Security-focused oversight, retention, and reset control.",OUT(6,"recommended")=0
	SET OUT(7,"key")="guest",OUT(7,"label")="Guest",OUT(7,"copy")="Limited workspace and settings access without privileged tools.",OUT(7,"recommended")=0
	QUIT
	;
VALIDROLE(ROLE)
	NEW CAT,N,OK
	SET ROLE=$$TRIM($GET(ROLE))
	IF ROLE="" QUIT 0
	DO ROLECAT(.CAT)
	SET (N,OK)=0
	FOR  SET N=$ORDER(CAT(N)) QUIT:N=""  DO  QUIT:OK
	. IF $GET(CAT(N,"key"))=ROLE SET OK=1
	QUIT OK
	;
NORMALIZE(ROLES,OUTCSV)
	NEW CAT,N,KEY,I,X,SEEN
	SET OUTCSV=""
	DO ROLECAT(.CAT)
	SET N=0
	FOR  SET N=$ORDER(CAT(N)) QUIT:N=""  DO
	. SET KEY=$GET(CAT(N,"key"))
	. IF KEY="" QUIT
	. FOR I=1:1:$LENGTH($GET(ROLES),",") DO  QUIT:$DATA(SEEN(KEY))
	. . SET X=$$TRIM($PIECE(ROLES,",",I))
	. . IF X'=KEY QUIT
	. . SET SEEN(KEY)=1
	. . IF OUTCSV'="" SET OUTCSV=OUTCSV_","
	. . SET OUTCSV=OUTCSV_KEY
	QUIT
	;
PREVIEW(ROLES,OUT)
	DO LIST($GET(ROLES),.OUT)
	QUIT
	;
APPPERM(KEY)
	SET KEY=$$TRIM($GET(KEY))
	IF KEY="workspace" QUIT "workspace.use"
	IF KEY="settings" QUIT "settings.self"
	IF KEY="ui-library" QUIT "workspace.use"
	IF KEY="jobs" QUIT "workspace.use"
	IF KEY="exports" QUIT "workspace.use"
	IF KEY="profiles" QUIT "settings.self"
	IF KEY="terminal" QUIT "terminal.use"
	IF KEY="collaboration" QUIT "chat.use"
	IF KEY="security" QUIT "audit.view"
	IF KEY="admin" QUIT "admin.users.view"
	IF KEY="logs" QUIT "logs.view"
	IF KEY="ui-samples" QUIT "workspace.use"
	QUIT ""
	;
APPALLOWED(ROLES,KEY)
	NEW PERM
	SET PERM=$$APPPERM($GET(KEY))
	IF PERM="" QUIT 1
	QUIT $$HASCSV($GET(ROLES),PERM)
	;
LIST(ROLES,OUT)
	NEW ALL,P,N
	KILL OUT
	SET ALL("workspace.use")="Workspace"
	SET ALL("theme.self")="Theme selection"
	SET ALL("settings.self")="Desktop settings"
	SET ALL("chat.use")="User chat"
	SET ALL("terminal.use")="Terminal access"
	SET ALL("editor.use")="Code studio access"
	SET ALL("queue.manage")="Queue operations"
	SET ALL("exports.view")="Export visibility"
	SET ALL("logs.view")="Access and error logs"
	SET ALL("logs.export")="Export access and error logs"
	SET ALL("audit.view")="Audit trail"
	SET ALL("audit.export")="Export audit trail"
	SET ALL("digest.export")="Download security digest"
	SET ALL("retention.manage")="Run retention pruning"
	SET ALL("permissions.view")="Permission matrix"
	SET ALL("theme.manage")="Theme administration"
	SET ALL("user.manage")="User administration"
	SET ALL("chat.moderate")="Chat moderation"
	SET ALL("admin.users.view")="View user administration"
	SET ALL("admin.users.manage")="Manage user lifecycle"
	SET ALL("admin.invites.manage")="Create and review invites"
	SET ALL("admin.reset.manage")="Issue reset tokens"
	SET N=0,P=""
	FOR  SET P=$ORDER(ALL(P)) QUIT:P=""  DO
	. IF '$$HASCSV($GET(ROLES),P) QUIT
	. SET N=N+1,OUT(N,"key")=P,OUT(N,"label")=ALL(P)
	QUIT
	;
TRIM(X)
	QUIT $$TRIM^MIOUTIL($GET(X))
	;
