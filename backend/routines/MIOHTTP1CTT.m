MIOHTTP1CTT ; Tests for Expect: 100-continue helpers (MIOHTTP)
 ;
 ; Run:
 ;   YDB>ZL "MIOHTTP.m","MIOHTTP1CTT.m","MIOTASSERT.m"
 ;   YDB>D ^MIOHTTP1CTT
 ;
 D T001,T002
 QUIT
 ;
T001 ;
 NEW CONF,REQ,ERR,OK
 KILL CONF,REQ,ERR
 SET CONF("server","limits","maxBodyBytes")=100
 SET REQ("hdr","expect")="100-continue"
 SET REQ("hdr","content-length")=50
 SET OK=$$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR)
 DO EQ^MIOTASSERT(OK,1,"[T001][expect allow]")
 QUIT
 ;
T002 ;
 NEW CONF,REQ,ERR,OK
 KILL CONF,REQ,ERR
 SET CONF("server","limits","maxBodyBytes")=10
 SET REQ("hdr","expect")="100-continue"
 SET REQ("hdr","content-length")=50
 SET OK=$$EXPECTDECIDE^MIOHTTP(.CONF,.REQ,.ERR)
 DO EQ^MIOTASSERT(OK,0,"[T002][expect reject]")
 DO EQ^MIOTASSERT($GET(ERR("error")),"payload_too_large","[T002][err]")
 DO EQ^MIOTASSERT($GET(ERR("routine")),"MIOHTTP","[T002][routine]")
 QUIT
