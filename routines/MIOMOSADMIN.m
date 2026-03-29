MIOMOSADMIN ; MIOMOS admin helpers
	QUIT
	;
COUNTS(OUT)
	NEW U,I,R,NOWD,NOWS
	KILL OUT
	SET (OUT("users"),OUT("enabled"),OUT("disabled"),OUT("locked"),OUT("invites"),OUT("resets"))=0
	SET NOWD=+$PIECE($HOROLOG,",",1),NOWS=+$PIECE($HOROLOG,",",2)
	SET U=""
	FOR  SET U=$ORDER(^MIO("MIOMOS","USER",U)) QUIT:U=""  DO
	. SET OUT("users")=OUT("users")+1
	. IF +$GET(^MIO("MIOMOS","USER",U,"enabled"),1)=1 SET OUT("enabled")=OUT("enabled")+1
	. IF +$GET(^MIO("MIOMOS","USER",U,"enabled"),1)'=1 SET OUT("disabled")=OUT("disabled")+1
	. IF $$AGESEC(NOWD,NOWS,+$GET(^MIO("MIOMOS","USER",U,"lockedUntilDay")),+$GET(^MIO("MIOMOS","USER",U,"lockedUntilSec")))>0 SET OUT("locked")=OUT("locked")+1
	SET I=""
	FOR  SET I=$ORDER(^MIO("MIOMOS","AUTH","INVITE",I)) QUIT:I=""  DO
	. IF $GET(^MIO("MIOMOS","AUTH","INVITE",I,"usedAt"))="" SET OUT("invites")=OUT("invites")+1
	SET R=""
	FOR  SET R=$ORDER(^MIO("MIOMOS","AUTH","RESET",R)) QUIT:R=""  DO
	. IF $GET(^MIO("MIOMOS","AUTH","RESET",R,"usedAt"))="" SET OUT("resets")=OUT("resets")+1
	QUIT
	;
USERLIST(LIMIT,OUT)
	NEW U,N,NOWD,NOWS,STATE
	KILL OUT
	SET LIMIT=+$GET(LIMIT,20) IF LIMIT<1 SET LIMIT=20
	SET N=0,NOWD=+$PIECE($HOROLOG,",",1),NOWS=+$PIECE($HOROLOG,",",2)
	SET U=""
	FOR  SET U=$ORDER(^MIO("MIOMOS","USER",U)) QUIT:U=""  DO  QUIT:N'<LIMIT
	. SET N=N+1
	. SET OUT(N,"principal")=U
	. SET OUT(N,"userName")=$GET(^MIO("MIOMOS","USER",U,"userName"),U)
	. SET OUT(N,"displayName")=$GET(^MIO("MIOMOS","USER",U,"userName"),U)
	. SET OUT(N,"roles")=$GET(^MIO("MIOMOS","USER",U,"roles"))
	. SET OUT(N,"primaryRole")=$$PRIMARYROLE^MIOMOSPERM($GET(OUT(N,"roles")))
	. SET OUT(N,"roleLabel")=$$ROLELABEL^MIOMOSPERM($GET(OUT(N,"primaryRole")))
	. SET OUT(N,"enabled")=+$GET(^MIO("MIOMOS","USER",U,"enabled"),1)
	. SET OUT(N,"failedCount")=+$GET(^MIO("MIOMOS","USER",U,"failedCount"))
	. SET OUT(N,"createdAt")=$GET(^MIO("MIOMOS","USER",U,"createdAt"))
	. SET OUT(N,"updatedAt")=$GET(^MIO("MIOMOS","USER",U,"updatedAt"))
	. SET OUT(N,"lastFailedAt")=$GET(^MIO("MIOMOS","USER",U,"lastFailedAt"))
	. SET OUT(N,"source")=$GET(^MIO("MIOMOS","USER",U,"source"),"manual")
	. SET OUT(N,"bootstrapPersona")=$GET(^MIO("MIOMOS","USER",U,"bootstrapPersona"))
	. SET OUT(N,"locked")=$SELECT($$AGESEC(NOWD,NOWS,+$GET(^MIO("MIOMOS","USER",U,"lockedUntilDay")),+$GET(^MIO("MIOMOS","USER",U,"lockedUntilSec")))>0:1,1:0)
	. SET STATE=$$USERSTATE(U,+$GET(OUT(N,"enabled")),+$GET(OUT(N,"locked")))
	. SET OUT(N,"state")=STATE
	. SET OUT(N,"status")=STATE
	QUIT
	;
INVITELIST(LIMIT,OUT)
	NEW I,N
	KILL OUT
	SET LIMIT=+$GET(LIMIT,10) IF LIMIT<1 SET LIMIT=10
	SET I="",N=0
	FOR  SET I=$ORDER(^MIO("MIOMOS","AUTH","INVITE",I),-1) QUIT:I=""  DO  QUIT:N'<LIMIT
	. IF '$DATA(^MIO("MIOMOS","AUTH","INVITE",I)) QUIT
	. SET N=N+1
	. SET OUT(N,"token")=I
	. SET OUT(N,"label")=$GET(^MIO("MIOMOS","AUTH","INVITE",I,"label"))
	. SET OUT(N,"roles")=$GET(^MIO("MIOMOS","AUTH","INVITE",I,"roles"))
	. SET OUT(N,"createdBy")=$GET(^MIO("MIOMOS","AUTH","INVITE",I,"createdBy"))
	. SET OUT(N,"createdAt")=$GET(^MIO("MIOMOS","AUTH","INVITE",I,"createdAt"))
	. SET OUT(N,"usedBy")=$GET(^MIO("MIOMOS","AUTH","INVITE",I,"usedBy"))
	QUIT
	;
RESETLIST(LIMIT,OUT)
	NEW I,N
	KILL OUT
	SET LIMIT=+$GET(LIMIT,10) IF LIMIT<1 SET LIMIT=10
	SET I="",N=0
	FOR  SET I=$ORDER(^MIO("MIOMOS","AUTH","RESET",I),-1) QUIT:I=""  DO  QUIT:N'<LIMIT
	. IF '$DATA(^MIO("MIOMOS","AUTH","RESET",I)) QUIT
	. SET N=N+1
	. SET OUT(N,"token")=I
	. SET OUT(N,"principal")=$GET(^MIO("MIOMOS","AUTH","RESET",I,"principal"))
	. SET OUT(N,"createdBy")=$GET(^MIO("MIOMOS","AUTH","RESET",I,"createdBy"))
	. SET OUT(N,"createdAt")=$GET(^MIO("MIOMOS","AUTH","RESET",I,"createdAt"))
	. SET OUT(N,"usedAt")=$GET(^MIO("MIOMOS","AUTH","RESET",I,"usedAt"))
	QUIT
	;
ACTIONS(CONF,OUT)
	KILL OUT
	SET OUT(1,"key")="disable",OUT(1,"label")="Disable account",OUT(1,"copy")="Stop sign-in without deleting the identity.",OUT(1,"route")=$GET(CONF("miomos","route","adminDisable"),"/api/miomos/admin/users/disable"),OUT(1,"permission")="admin.users.manage"
	SET OUT(2,"key")="enable",OUT(2,"label")="Enable account",OUT(2,"copy")="Restore sign-in after review.",OUT(2,"route")=$GET(CONF("miomos","route","adminEnable"),"/api/miomos/admin/users/enable"),OUT(2,"permission")="admin.users.manage"
	SET OUT(3,"key")="lock",OUT(3,"label")="Lock account",OUT(3,"copy")="Force a temporary hold for risk or support review.",OUT(3,"route")=$GET(CONF("miomos","route","adminLock"),"/api/miomos/admin/users/lock"),OUT(3,"permission")="admin.users.manage"
	SET OUT(4,"key")="unlock",OUT(4,"label")="Unlock account",OUT(4,"copy")="Clear lockout after verification.",OUT(4,"route")=$GET(CONF("miomos","route","adminUnlock"),"/api/miomos/admin/users/unlock"),OUT(4,"permission")="admin.users.manage"
	SET OUT(5,"key")="invite",OUT(5,"label")="Create invite",OUT(5,"copy")="Issue an invite-only onboarding token.",OUT(5,"route")=$GET(CONF("miomos","route","adminInviteCreate"),"/api/miomos/admin/invites/create"),OUT(5,"permission")="admin.invites.manage"
	SET OUT(6,"key")="reset",OUT(6,"label")="Issue reset token",OUT(6,"copy")="Create a temporary password reset token.",OUT(6,"route")=$GET(CONF("miomos","route","adminResetRequest"),"/api/miomos/admin/users/reset/request"),OUT(6,"permission")="admin.reset.manage"
	SET OUT(7,"key")="roles",OUT(7,"label")="Update roles",OUT(7,"copy")="Apply a new role set and refresh effective permissions.",OUT(7,"route")=$GET(CONF("miomos","route","adminUserRoles"),"/api/miomos/admin/users/roles"),OUT(7,"permission")="admin.users.manage"
	SET OUT(8,"key")="guestToggle",OUT(8,"label")="Guest quick login",OUT(8,"copy")="Control whether the access page offers guest quick login.",OUT(8,"route")=$GET(CONF("miomos","route","adminGuestToggle"),"/api/miomos/admin/config/guest-login"),OUT(8,"permission")="admin.users.manage"
	QUIT
	;
GUESTLOGIN(CONF)
	NEW OVR
	SET OVR=$GET(^MIO("MIOMOS","ADMIN","CONFIG","guestLoginEnabled"),"")
	IF OVR'="" QUIT +OVR
	QUIT +$GET(CONF("miomos","localAuth","guestLoginEnabled"),1)
	;
SETGUESTLOGIN(VALUE,OUT)
	SET ^MIO("MIOMOS","ADMIN","CONFIG","guestLoginEnabled")=$SELECT(+VALUE:1,1:0)
	SET ^MIO("MIOMOS","ADMIN","CONFIG","guestLoginUpdatedAt")=$$NOWISO^MIOUTIL()
	KILL OUT
	SET OUT("guestLoginEnabled")=+$GET(^MIO("MIOMOS","ADMIN","CONFIG","guestLoginEnabled"))
	SET OUT("updatedAt")=$GET(^MIO("MIOMOS","ADMIN","CONFIG","guestLoginUpdatedAt"))
	SET OUT("managedRuntime")=1
	QUIT
	;
BOOTSTATUS(CONF,OUT)
	NEW MAP,N,ROLE,USER
	KILL OUT
	SET OUT("localAuthEnabled")=+$$LOCALAUTHEN^MIOMOS(.CONF)
	SET OUT("guestLoginConfigured")=+$GET(CONF("miomos","localAuth","guestLoginEnabled"),1)
	SET OUT("guestLoginEnabled")=+$$GUESTLOGIN(.CONF)
	SET OUT("guestLoginManaged")=$SELECT($DATA(^MIO("MIOMOS","ADMIN","CONFIG","guestLoginEnabled")):1,1:0)
	SET OUT("seedIfMissing")=+$GET(CONF("miomos","bootstrapAuth","seedIfMissing"),1)
	SET OUT("syncOnBoot")=+$GET(CONF("miomos","bootstrapAuth","syncOnBoot"),1)
	SET OUT("showSeededCredentials")=+$GET(CONF("miomos","bootstrapAuth","showSeededCredentials"),1)
	SET OUT("bootstrapEnabled")=+$GET(CONF("miomos","bootstrapAuth","enabled"),1)
	SET OUT("lastBootstrapAt")=$GET(^MIO("MIOMOS","AUTH","BOOTSTRAP","lastRunAt"))
	SET MAP(1)="admin",MAP(2)="user",MAP(3)="guest"
	SET N=0 FOR  SET N=$ORDER(MAP(N)) QUIT:N=""  DO
	. SET ROLE=MAP(N)
	. SET USER=$$CANON^MIOMOSAUTH($GET(CONF("miomos","bootstrapAuth",ROLE,"username"),ROLE))
	. SET OUT("seeded",N,"key")=ROLE
	. SET OUT("seeded",N,"username")=USER
	. SET OUT("seeded",N,"displayName")=$GET(CONF("miomos","bootstrapAuth",ROLE,"displayName"),$$TITLE^MIOMOSAUTH(ROLE))
	. SET OUT("seeded",N,"configuredRoles")=$GET(CONF("miomos","bootstrapAuth",ROLE,"roles"),$SELECT(ROLE="admin":"admin",ROLE="user":"operator",1:"guest"))
	. SET OUT("seeded",N,"configuredEnabled")=+$GET(CONF("miomos","bootstrapAuth",ROLE,"enabled"),1)
	. SET OUT("seeded",N,"exists")=$SELECT($DATA(^MIO("MIOMOS","USER",USER)):1,1:0)
	. SET OUT("seeded",N,"runtimeRoles")=$GET(^MIO("MIOMOS","USER",USER,"roles"))
	. SET OUT("seeded",N,"runtimeEnabled")=+$GET(^MIO("MIOMOS","USER",USER,"enabled"),1)
	. SET OUT("seeded",N,"source")=$GET(^MIO("MIOMOS","USER",USER,"source"))
	. SET OUT("seeded",N,"bootstrapPersona")=$GET(^MIO("MIOMOS","USER",USER,"bootstrapPersona"))
	QUIT
	;
SETROLES(USER,ROLECSV,OUT,ERR)
	NEW CSV
	KILL ERR,OUT
	SET ERR("routine")="MIOMOSADMIN"
	SET USER=$$CANON^MIOMOSAUTH($GET(USER))
	IF USER="" SET ERR("error")="username_missing" QUIT 0
	IF '$DATA(^MIO("MIOMOS","USER",USER)) SET ERR("error")="user_not_found" QUIT 0
	DO NORMALIZE^MIOMOSPERM($GET(ROLECSV),.CSV)
	IF CSV="" SET ERR("error")="roles_invalid" QUIT 0
	SET ^MIO("MIOMOS","USER",USER,"roles")=CSV
	SET ^MIO("MIOMOS","USER",USER,"updatedAt")=$$NOWISO^MIOUTIL()
	DO SYNCAUTH(USER,CSV)
	SET OUT("principal")=USER
	SET OUT("roles")=CSV
	NEW TT M TT=OUT("permissions") DO PREVIEW^MIOMOSPERM(CSV,.TT) M OUT("permissions")=TT K TT
	QUIT 1
	;
SYNCAUTH(USER,ROLES)
	NEW T,SID
	SET T=""
	FOR  SET T=$ORDER(^MIO("MIOMOS","AUTH","TOKEN",T)) QUIT:T=""  DO
	. IF $GET(^MIO("MIOMOS","AUTH","TOKEN",T,"principal"))'=$GET(USER) QUIT
	. SET ^MIO("MIOMOS","AUTH","TOKEN",T,"roles")=$GET(ROLES)
	SET SID=$GET(^MIO("MIOMOS","SESSION","BYKEY",$GET(USER)))
	IF SID'="" SET ^MIO("MIOMOS","SESSION",SID,"roles")=$GET(ROLES)
	QUIT
	;
USERSTATE(USER,ENABLED,LOCKED)
	IF +$GET(ENABLED)'=1 QUIT "Disabled"
	IF +$GET(LOCKED)=1 QUIT "Locked"
	QUIT "Active"
	;
AGESEC(D1,S1,D2,S2)
	IF (+$GET(D2)=0),(+$GET(S2)=0) QUIT 999999999
	QUIT (((+$GET(D2)-+$GET(D1))*86400)+(+$GET(S2)-+$GET(S1)))
	;
	;