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
	IF $GET(PERM)="chat.direct" QUIT $SELECT($GET(ROLE)="guest":0,1:1)
	IF $GET(PERM)="terminal.use" QUIT 1
	IF $GET(PERM)="editor.use" QUIT 1
	IF $GET(ROLE)="developer",((PERM="logs.view")!(PERM="audit.view")!(PERM="logs.export")!(PERM="audit.export")!(PERM="digest.export")!(PERM="retention.manage")!(PERM="permissions.view")!(PERM="theme.manage")!(PERM="user.manage")!(PERM="admin.users.view")!(PERM="admin.users.manage")!(PERM="admin.invites.manage")!(PERM="admin.reset.manage")) QUIT 1
	IF $GET(ROLE)="operator",((PERM="queue.manage")!(PERM="exports.view")) QUIT 1
	IF $GET(ROLE)="auditor",((PERM="logs.view")!(PERM="audit.view")!(PERM="logs.export")!(PERM="audit.export")!(PERM="digest.export")!(PERM="permissions.view")!(PERM="admin.users.view")) QUIT 1
	IF $GET(ROLE)="support",((PERM="logs.view")!(PERM="logs.export")!(PERM="digest.export")!(PERM="chat.moderate")!(PERM="admin.users.view")) QUIT 1
	IF $GET(ROLE)="security",((PERM="logs.view")!(PERM="audit.view")!(PERM="logs.export")!(PERM="audit.export")!(PERM="digest.export")!(PERM="retention.manage")!(PERM="permissions.view")!(PERM="admin.users.view")!(PERM="admin.reset.manage")) QUIT 1
	QUIT 0
	;
LIST(ROLES,OUT)
	NEW ALL,P,N
	KILL OUT
	SET ALL("workspace.use")="Workspace"
	SET ALL("theme.self")="Theme selection"
	SET ALL("settings.self")="Desktop settings"
	SET ALL("chat.use")="User chat"
	SET ALL("chat.direct")="Direct messages"
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
	;
PRIMARYROLE(ROLES)
	NEW I,R
	FOR I=1:1:$LENGTH($GET(ROLES),",") DO  QUIT:$GET(R)'=""
	. SET R=$$TRIM($PIECE(ROLES,",",I))
	. IF R'="" QUIT
	QUIT $SELECT($GET(R)'="":R,1:"guest")
	;
ROLELABEL(ROLES)
	NEW R
	SET R=$$PRIMARYROLE($GET(ROLES))
	IF R="admin" QUIT "Administrator"
	IF R="developer" QUIT "Developer"
	IF R="operator" QUIT "Operator"
	IF R="auditor" QUIT "Auditor"
	IF R="support" QUIT "Support"
	IF R="security" QUIT "Security"
	IF R="guest" QUIT "Guest"
	QUIT "User"
	;
