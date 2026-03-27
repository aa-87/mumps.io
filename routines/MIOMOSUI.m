MIOMOSUI ; MIOMOS UI helpers
	QUIT
	;
DESKCTX(STATE,CONF,DATA)
	KILL DATA
	SET DATA("page","title")=$GET(STATE("brandTitle"),"MIOMOS")_" Desktop"
	SET DATA("page","subtitle")=$GET(STATE("brandSubtitle"),"MUMPS-first clinical workspace")
	SET DATA("brandTitle")=$GET(STATE("brandTitle"),"MIOMOS")
	SET DATA("brandSubtitle")=$GET(STATE("brandSubtitle"),"MUMPS-first clinical workspace")
	SET DATA("userName")=$GET(STATE("userName"))
	SET DATA("profile")=$GET(STATE("profile"),"dev")
	SET DATA("sessionId")=$GET(STATE("sessionId"))
	SET DATA("desktopPath")=$GET(STATE("desktopPath"))
	SET DATA("bootstrapPath")=$GET(STATE("bootstrapPath"))
	SET DATA("wsPath")=$GET(STATE("wsPath"))
	SET DATA("wallpaper")=$GET(STATE("wallpaper"))
	SET DATA("accent")=$GET(STATE("accent"),"#2f6fed")
	SET DATA("bootJson")=$$BOOTJSON^MIOMOSST(.STATE,.CONF)
	SET DATA("vueScript")="https://unpkg.com/vue@3/dist/vue.global.prod.js"
	SET DATA("osjsClientScript")="https://cdn.jsdelivr.net/npm/@osjs/client/dist/main.js"
	SET DATA("sevenCssHref")="https://unpkg.com/7.css/dist/7.scoped.css"
	DO APPSSR(.DATA)
	DO WINSSR(.DATA)
	QUIT
	;
APPSSR(DATA)
	KILL DATA("apps")
	SET DATA("apps",1,"key")="workspace"
	SET DATA("apps",1,"title")="Workspace"
	SET DATA("apps",1,"subtitle")="Queues, intake, review, and export"
	SET DATA("apps",1,"icon")="W"
	SET DATA("apps",1,"badge")="Live"
	SET DATA("apps",2,"key")="operations"
	SET DATA("apps",2,"title")="Operations"
	SET DATA("apps",2,"subtitle")="Throughput, latency, and batch posture"
	SET DATA("apps",2,"icon")="O"
	SET DATA("apps",2,"badge")="Ops"
	SET DATA("apps",3,"key")="security"
	SET DATA("apps",3,"title")="Audit"
	SET DATA("apps",3,"subtitle")="Sessions, controls, and privileged actions"
	SET DATA("apps",3,"icon")="A"
	SET DATA("apps",3,"badge")="Audit"
	QUIT
	;
WINSSR(DATA)
	DO WIN(.DATA,1,"win-workspace","workspace","Workspace",18,18,1104,660,4,"normal")
	SET DATA("windows",1,"isWorkspace")=1
	DO WIN(.DATA,2,"win-operations","operations","Operations",1136,18,280,320,3,"minimized")
	SET DATA("windows",2,"isOperations")=1
	DO WIN(.DATA,3,"win-security","security","Audit",1136,350,280,268,2,"minimized")
	SET DATA("windows",3,"isSecurity")=1
	QUIT
	;
WIN(DATA,N,ID,APPKEY,TITLE,LEFT,TOP,WIDTH,HEIGHT,Z,STATE)
	SET DATA("windows",N,"id")=ID
	SET DATA("windows",N,"appKey")=APPKEY
	SET DATA("windows",N,"title")=TITLE
	SET DATA("windows",N,"left")=LEFT
	SET DATA("windows",N,"top")=TOP
	SET DATA("windows",N,"width")=WIDTH
	SET DATA("windows",N,"height")=HEIGHT
	SET DATA("windows",N,"z")=Z
	SET DATA("windows",N,"state")=STATE
	SET DATA("windows",N,"glyph")=$EXTRACT(TITLE,1)
	SET DATA("windows",N,"stateClass")=$SELECT(STATE="minimized":"is-minimized",1:"")
	QUIT
	;
