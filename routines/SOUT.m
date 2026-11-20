SOUT ; Coming-soon landing page and early-access signup
 ;
 ; Optional application module for the MUMPS.IO web server.
 ; Register with REG^SOUT(.CONF) after INIT^MIOROUTE and before
 ; COMPILE^MIOROUTE. Public page: GET /sout.
 ;
 ; Waitlist storage:
 ; ^MIO("SOUT","WAITLIST","email",normalizedEmail)=id
 ; ^MIO("SOUT","WAITLIST","entry",id,"email")=email
 ; ^MIO("SOUT","WAITLIST","entry",id,"interest")=interest
 ; ^MIO("SOUT","WAITLIST","entry",id,"createdH")=$H
 ;
 QUIT
 ;
REG(CONF)
 NEW META
 KILL META
 SET META("authRequired")=0
 DO ADDM^MIOROUTE("GET","/sout","HOME^SOUT",.META)
 DO ADDM^MIOROUTE("POST","/sout/waitlist","WAITLIST^SOUT",.META)
 DO ADDM^MIOROUTE("GET","/public/sout/*path","SOUTSTATIC^SOUT",.META)
 DO ADDM^MIOROUTE("HEAD","/public/sout/*path","SOUTSTATIC^SOUT",.META)
 QUIT
 ;
HOME(DEV,CONF,REQ,CTX)
 NEW TCTX,OUT,ERR,HEAD
 KILL TCTX,ERR
 SET TCTX("joined")=0
 IF $FIND($GET(REQ("uri")),"joined=1") SET TCTX("joined")=1
 DO RENDERPAGE^MIOTPL("pages/sout_home.html","layouts/sout_layout.html",.CONF,.TCTX,.OUT,.ERR)
 IF $DATA(ERR) DO RESPERR(.DEV,.CONF,.CTX,500,"template_error",$GET(ERR("error"),"render_failed")) QUIT
 SET HEAD("Content-Type")="text/html; charset=utf-8"
 DO RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,OUT,$GET(CTX("request_id")),.CTX)
 QUIT
 ;
SOUTSTATIC(DEV,CONF,REQ,CTX)
 ; Isolated static mount; does not change the application's other mounts.
 SET CONF("server","static","mount")="/public/sout"
 SET CONF("server","static","root")="public"
 DO STATIC^MIOSTATIC(.DEV,.CONF,.REQ,.CTX)
 QUIT
 ;
WAITLIST(DEV,CONF,REQ,CTX)
 NEW BODY,POST,EMAIL,INTEREST,WEBSITE,ID
 KILL POST
 SET BODY=$GET(REQ("body"))
 IF $LENGTH(BODY)>8192 DO RESPERR(.DEV,.CONF,.CTX,413,"form_too_large","The signup form is too large.") QUIT
 DO DECODEFORM^MIOFNC(BODY,.POST)
 SET WEBSITE=$GET(POST("website"))
 ; Honeypot: silently accept automated submissions without storing them.
 IF WEBSITE'="" DO REDIRECT(.DEV,.CONF,.CTX) QUIT
 SET EMAIL=$ZCONVERT($$TRIM($GET(POST("email"))),"L")
 IF '$$VALIDMAIL(EMAIL) DO RESPERR(.DEV,.CONF,.CTX,400,"invalid_email","Please enter a valid email address.") QUIT
 SET INTEREST=$GET(POST("interest"),"both")
 IF (INTEREST'="both"),(INTEREST'="artist"),(INTEREST'="learning") SET INTEREST="both"
 ;
 ; Idempotent signup: one record per normalized email address.
 SET ID=$GET(^MIO("SOUT","WAITLIST","email",EMAIL))
 IF ID="" DO
 . SET ID=$INCREMENT(^MIO("SOUT","WAITLIST","nextId"))
 . SET ^MIO("SOUT","WAITLIST","email",EMAIL)=ID
 . SET ^MIO("SOUT","WAITLIST","entry",ID,"email")=EMAIL
 . SET ^MIO("SOUT","WAITLIST","entry",ID,"createdH")=$H
 SET ^MIO("SOUT","WAITLIST","entry",ID,"interest")=INTEREST
 DO REDIRECT(.DEV,.CONF,.CTX)
 QUIT
 ;
REDIRECT(DEV,CONF,CTX)
 NEW HEAD
 SET HEAD("Location")="/sout?joined=1#early-access"
 SET HEAD("Content-Type")="text/plain; charset=utf-8"
 DO RESPX^MIOHTTP(.DEV,.CONF,303,.HEAD,"",$GET(CTX("request_id")),.CTX)
 QUIT
 ;
VALIDMAIL(EMAIL)
 NEW AT,DOMAIN
 IF EMAIL="" QUIT 0
 IF $LENGTH(EMAIL)>254 QUIT 0
 IF EMAIL'[$CHAR(64) QUIT 0
 IF EMAIL[$CHAR(32) QUIT 0
 IF EMAIL[$CHAR(9) QUIT 0
 IF $LENGTH(EMAIL,"@")'=2 QUIT 0
 SET AT=$FIND(EMAIL,"@")
 IF AT<3 QUIT 0
 SET DOMAIN=$EXTRACT(EMAIL,AT,$LENGTH(EMAIL))
 IF DOMAIN="" QUIT 0
 IF DOMAIN'["." QUIT 0
 IF $EXTRACT(DOMAIN,1)="."!($EXTRACT(DOMAIN,$LENGTH(DOMAIN))=".") QUIT 0
 QUIT 1
 ;
TRIM(X)
 NEW Y
 SET Y=$GET(X)
 FOR  QUIT:$EXTRACT(Y,1)'=" "  SET Y=$EXTRACT(Y,2,$LENGTH(Y))
 FOR  QUIT:$EXTRACT(Y,$LENGTH(Y))'=" "  SET Y=$EXTRACT(Y,1,$LENGTH(Y)-1)
 QUIT Y
 ;
RESPERR(DEV,CONF,CTX,STATUS,CODE,MESSAGE)
 NEW OBJ
 SET OBJ("ok")=0,OBJ("error")=CODE,OBJ("message")=MESSAGE
 DO RESPJSONX^MIOHTTP(.DEV,.CONF,STATUS,.OBJ,$GET(CTX("request_id")),.CTX)
 QUIT
