MIOIDEWS ; MIOIDE WebSocket routes and simple event helpers
	Q
	;
REG(CONF)
	N META
	K META
	S META("authRequired")=+$G(CONF("mioide","authRequired"),1)
	S META("roles")=$G(CONF("mioide","roles"),"developer,admin")
	S META("wsPersistent")=1
	D ADDM^MIOROUTE("WS",$G(CONF("mioide","ws","eventsPath"),"/mioide/ws/events"),"EVENTS^MIOIDEWS",.META)
	D ADDM^MIOROUTE("WS",$G(CONF("mioide","ws","terminalPath"),"/mioide/ws/terminal"),"TERMINAL^MIOIDEWS",.META)
	Q
	;
EVENTS(DEV,CONF,REQ,CTX)
	Q
	;
TERMINAL(DEV,CONF,REQ,CTX)
	Q
	;
PUBREQ(REQ,KIND,RTN,STATUS,MESSAGE,PAYLOAD)
	Q
	;
	;