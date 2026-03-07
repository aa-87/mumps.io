MIOROUTEU ; MIOROUTE user guide (short sentences).;
;
; This routine is documentation only.;
; It contains no production logic.;
;
; Run:
;   YDB>D SHOW^MIOROUTEU
;
; ------------------------------------------------------------------------------
	;
SHOW ;
	NEW I,LINE
	FOR I=1:1 DO  QUIT:LINE="***END***"
	. SET LINE=$P($T(DOC+I),";;",2,999)
	. IF LINE="***END***" QUIT
	. WRITE LINE,!
	QUIT
	;
DOC ;;
;;MIOROUTE - User Guide
;;
;;What it does
;;- It matches URLs.;
;;- It picks a handler.;
;;- It extracts params.;
;;
;;How to add a route
;;- Use ADD.;
;;- Example:
;;  DO ADD^MIOROUTE("GET","/users/:id","SHOW^MYAPI")
;;
;;How to add a route with metadata
;;- Use ADDM.;
;;- Example:
;;  NEW META SET META("authRequired")=1
;;  DO ADDM^MIOROUTE("GET","/admin","ADMIN^MYAPI",.META)
;;
;;How to add a WebSocket route
;;- Use ADDWS.;
;;- Example:
;;  DO ADDWS^MIOROUTE("/ws","ACCEPT^MIOWS")
;;
;;Compile routes
;;- Call COMPILE after adding routes.;
;;- Example:
;;  DO COMPILE^MIOROUTE
;;
;;Route patterns
;;- Use '/' to separate segments.;
;;- Static segment:
;;  /about
;;- Param segment:
;;  /users/:id
;;- Wildcard segment:
;;  /static/*path
;;- Wildcard must be last.;
;;
;;Params
;;- Params are decoded.;
;;- Params are stored in REQ("params").;
;;- Example:
;;  /users/123
;;  REQ("params","id")="123"
;;
;;404 responses
;;- You get JSON.;
;;- It includes rtn="MIOROUTE".;
;;
;;405 responses
;;- You get JSON.;
;;- It includes rtn="MIOROUTE".;
;;- It includes an Allow header.;
;;
;;Common settings
;;- ignoreTrailingSlash
;;  - Default is 1.;
;;  - /a and /a/ match the same route.;
;;- plusAsSpaceInPath
;;  - Default is 1.;
;;  - '+' becomes space in the path.;
;;
;;Troubleshooting
;;- Check ^MIO("ROUTE","COMPILE").;
;;- Look at ^MIO("ROUTE","COMPILE","err").;
;;- Each error shows routine="MIOROUTE".;
;;
;;***END***
	;