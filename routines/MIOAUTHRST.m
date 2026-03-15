MIOAUTHRST ; RS256 OpenSSL default verifier tests for MIOAUTHRS / MIOAUTHJWT
	;
	QUIT
	;
START
	DO T001
	DO T002
	DO T003
	DO T004
	DO T005
	DO T006
	DO T007
	DO T008
	QUIT
	;
RESET
	KILL ^MIO("ROUTE")
	QUIT
	;
READALL(PATH,OUT)
	NEW OIO SET OIO=$IO
	SET OUT=""
	NEW DEV SET DEV=PATH
	OPEN DEV:(readonly:stream:nowrap)
	USE DEV
	NEW X
	FOR  READ X#16384  QUIT:$ZEOF  SET OUT=OUT_X
	CLOSE DEV
	USE OIO
	QUIT
	;
RSNOW() ; fixed verifier clock for hard-coded RS256 fixtures
	; These fixtures carry a fixed exp value. Pinning "now" keeps the
	; tests deterministic under MIOAUTHJWT's existing claim-time model.
	QUIT 4102441200
	;
T001 ; INITJWT installs default verifier when RS256 key config exists
	DO RESET
	NEW CONF,ERR
	KILL CONF,ERR
	SET CONF("auth","jwt","rs256PublicKeyPem")=$$PUB1()
	DO EQ^MIOTASSERT($$INITJWT^MIOAUTH(.CONF,.ERR),1,"[MIOAUTHRST][T001][init ok]")
	DO EQ^MIOTASSERT($GET(CONF("auth","jwt","rs256Verify")),"VERIFYOSSL^MIOAUTHRS","[MIOAUTHRST][T001][default verifier]")
	QUIT
	;
T002 ; explicit verifier entry is preserved by INITJWT
	DO RESET
	NEW CONF,ERR
	KILL CONF,ERR
	SET CONF("auth","jwt","rs256PublicKeyPem")=$$PUB1()
	SET CONF("auth","jwt","rs256Verify")="VRFYOK^MIOAUTHZT"
	DO EQ^MIOTASSERT($$INITJWT^MIOAUTH(.CONF,.ERR),1,"[MIOAUTHRST][T002][init ok]")
	DO EQ^MIOTASSERT($GET(CONF("auth","jwt","rs256Verify")),"VRFYOK^MIOAUTHZT","[MIOAUTHRST][T002][preserve verifier]")
	QUIT
	;
T003 ; RS256 verify succeeds with default OpenSSL verifier and direct PEM
	DO RESET
	NEW CONF,REQ,CTX,ERR,OK
	KILL CONF,REQ,CTX,ERR
	SET CONF("auth","jwt","rs256PublicKeyPem")=$$PUB1()
	SET CONF("auth","jwt","now")=$$RSNOW()
	SET REQ("hdr","authorization")="Bearer "_$$TOK1()
	SET OK=$$VERIFY^MIOAUTHJWT(.CONF,.REQ,.CTX,.ERR)
	DO EQ^MIOTASSERT(OK,1,"[MIOAUTHRST][T003][verify ok]")
	DO EQ^MIOTASSERT($GET(CTX("auth","sub")),"rs-user","[MIOAUTHRST][T003][sub]")
	DO EQ^MIOTASSERT($GET(CTX("auth","roles","admin")),1,"[MIOAUTHRST][T003][role]")
	QUIT
	;
T004 ; RS256 verify succeeds with kid PEM map
	DO RESET
	NEW CONF,REQ,CTX,ERR,OK
	KILL CONF,REQ,CTX,ERR
	SET CONF("auth","jwt","rs256PublicKeyPemByKid","k1")=$$PUB1()
	SET CONF("auth","jwt","now")=$$RSNOW()
	SET REQ("hdr","authorization")="Bearer "_$$TOK2()
	SET OK=$$VERIFY^MIOAUTHJWT(.CONF,.REQ,.CTX,.ERR)
	DO EQ^MIOTASSERT(OK,1,"[MIOAUTHRST][T004][verify ok]")
	DO EQ^MIOTASSERT($GET(CTX("auth","sub")),"rs-user","[MIOAUTHRST][T004][sub]")
	QUIT
	;
T005 ; wrong public key denies as bad signature
	DO RESET
	NEW CONF,REQ,CTX,ERR,OK
	KILL CONF,REQ,CTX,ERR
	SET CONF("auth","jwt","rs256PublicKeyPem")=$$PUBWRONG()
	SET CONF("auth","jwt","now")=$$RSNOW()
	SET REQ("hdr","authorization")="Bearer "_$$TOK1()
	SET OK=$$VERIFY^MIOAUTHJWT(.CONF,.REQ,.CTX,.ERR)
	DO EQ^MIOTASSERT(OK,0,"[MIOAUTHRST][T005][verify denied]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"jwt_bad_signature","[MIOAUTHRST][T005][error]")
	QUIT
	;
T006 ; missing key config still denies cleanly on RS256 token
	DO RESET
	NEW CONF,REQ,CTX,ERR,OK
	KILL CONF,REQ,CTX,ERR
	SET CONF("auth","jwt","now")=$$RSNOW()
	SET REQ("hdr","authorization")="Bearer "_$$TOK1()
	SET OK=$$VERIFY^MIOAUTHJWT(.CONF,.REQ,.CTX,.ERR)
	DO EQ^MIOTASSERT(OK,0,"[MIOAUTHRST][T006][verify denied]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"jwt_rs256_no_verifier","[MIOAUTHRST][T006][error]")
	QUIT
	;
T007 ; bad OpenSSL path is reported by INIT
	DO RESET
	NEW CONF,ERR
	KILL CONF,ERR
	SET CONF("auth","jwt","rs256PublicKeyPem")=$$PUB1()
	SET CONF("auth","jwt","rs256OpenSSLPath")="/definitely/not/openssl"
	DO EQ^MIOTASSERT($$INITJWT^MIOAUTH(.CONF,.ERR),0,"[MIOAUTHRST][T007][init denied]")
	DO EQ^MIOTASSERT($GET(ERR("error")),"jwt_rs256_openssl_missing","[MIOAUTHRST][T007][error]")
	QUIT
	;
T008 ; route RBAC still works through default OpenSSL verifier
	DO RESET
	NEW META
	SET META("authRequired")=1
	SET META("roles")="admin"
	DO ADDM^MIOROUTE("GET","/rs/secure","HOK^MIOAUTHRST",.META)
	DO COMPILE^MIOROUTE
	NEW CONF,REQ,CTX,DEV,OUT,OP
	KILL CONF,REQ,CTX
	SET CONF("auth","protectMode")="route"
	SET CONF("auth","mode")="jwt"
	SET CONF("auth","jwt","rs256PublicKeyPem")=$$PUB1()
	SET CONF("auth","jwt","now")=$$RSNOW()
	DO ENSURE^MIOMW(.CONF)
	SET REQ("method")="GET",REQ("path")="/rs/secure",REQ("hdr","authorization")="Bearer "_$$TOK1()
	SET CTX("request_id")="rst008",CTX("ran")=0
	SET OP="tmp/mio_authrst_t008.out"
	OPEN OP:(newversion:stream:nowrap) SET DEV=OP USE DEV
	DO DISPATCH^MIOROUTE(.DEV,.CONF,.REQ,.CTX)
	CLOSE DEV USE $PRINCIPAL
	DO READALL(OP,.OUT)
	DO EQ^MIOTASSERT($SELECT(OUT["200":1,1:0),1,"[MIOAUTHRST][T008][status]")
	DO EQ^MIOTASSERT($GET(CTX("auth","roles","admin")),1,"[MIOAUTHRST][T008][role]")
	QUIT
	;
HOK(DEV,CONF,REQ,CTX)
	NEW OBJ
	SET CTX("ran")=1
	SET OBJ("ok")=1
	DO RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$GET(CTX("request_id")),.CTX)
	SET CTX("status")=200
	QUIT
	;
PUB1()
	QUIT "-----BEGIN PUBLIC KEY-----"_$C(10)_"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAjgkngSd+SZOoK+qQF9qH"_$C(10)_"GFlorU9c5p+gLX6r/V/VVacga4NqCWbRWt9BO4xNfmY5ABrOYxbm4AALD7IRhnxi"_$C(10)_"zW1BZ9xVQPB1qkjvhdWPNvnsxXhcNyud4wiGoPGJL5hJmU7ein6fJmi5qKlDa7S/"_$C(10)_"+/rJLZXFi1tgGE/os/C/C3p9iMW4vDy49y0OhDfjW8qVxlpMx+pcPBMWIchKVEct"_$C(10)_"Are0atrsyI4oZvHAlsmpxjm8NRIMmhvze/Tlfs7JNGfnem0rt5TfDTre+oGIx2d3"_$C(10)_"PI0rGfnPVGXtvLJVqyUi5LsXrJrUTxaanu5zNG928+BzIteACn1rgqaZ7iFS5DMq"_$C(10)_"wwIDAQAB"_$C(10)_"-----END PUBLIC KEY-----"_$C(10)
	;
PUBWRONG()
	QUIT "-----BEGIN PUBLIC KEY-----"_$C(10)_"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAu/pyTMlHNGJ68aeH6tk+"_$C(10)_"H/KOxtx12lpVVdR+mQ1eDW/OUeIGS9+TToW9oimTyoNgCr4WROYYhmvzz6TZEnQB"_$C(10)_"UrFa/7CfBKZV49tYHlDrPPdWqnJDw4upK0W3U7pbVyFvlm6bdo6D+DWZTvRNyqot"_$C(10)_"Fb7mbqxduwFA0zbEkNw+tE8RZHbmBC968gbzNmV8xLHbegQtw0fK0FSoCVV0OZkQ"_$C(10)_"s+/izRzKK12aUjCHX25s43j3pXQblg1Q/00lWM78LqTT4Y5exk24KVP00RCZPGcl"_$C(10)_"YzGiP6iJuJx0OS9hglNNVolWqyrKWKZP/7MMsvV94Ahw+uXDr0LKmcY/N8M1grFe"_$C(10)_"GQIDAQAB"_$C(10)_"-----END PUBLIC KEY-----"_$C(10)
	;
TOK1()
	QUIT "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJycy11c2VyIiwicm9sZXMiO"_"iJhZG1pbix1c2VyIiwiaXNzIjoiaXNzdWVyLWEiLCJhdWQiOiJhdWQtYSIsImV4cCI6NDE"_"wMjQ0NDgwMH0.IRk_DUoIOOS7i14v1B4auPCLr5xjxO_RlgtNfX2gWXHPId_C_2H7u7O7V"_"78hHWGgirAJopC5jZVuwA1WZrwPVfjcGU5sSe1uQm5WpD_j6fkbazfFzbqoskXXvz9AN9r"_"7qbWGorgzWZw4kEhW7NU4ogYe2BSkuKSgs3nw6VyqFzojSunBQ5Q9TLYxpEezAFlknrv2G"_"phtj8qxN-xVhGmJaiUfkPpD5VkerVeE2yKREsbFurtZllRUnzEODEIuQID5_GBQZS8v2s9"_"pqLDbTlF_RAyTC4bc9AcGJ1qWKOzXZ1aG45FeT8qS1lA81TzOrX9Fvv9ZA5whJUkT_PRnG"_"6Gk0w"
	;
TOK2()
	QUIT "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImsxIn0.eyJzdWIiOiJycy11c2"_"VyIiwicm9sZXMiOiJhZG1pbix1c2VyIiwiaXNzIjoiaXNzdWVyLWEiLCJhdWQiOiJhdWQt"_"YSIsImV4cCI6NDEwMjQ0NDgwMH0.XurhKa95iY7oOFnUT-dtUvp-Yqowc5Ye9Y47trq9bq"_"W8ML-9fgCPdSlYXT1-dKY7XSLX3rBJ9l_GR7TqOAjVpduzaf8CgZwpAFzts3sEhjYVmdqS"_"TuajSXi6Yob3OZAhrRwTSkHBbb25dEv3vL0GI4ARh-3m9gLpTYFryAb2TPzp0SrKOFeN7x"_"1s0sQfwb0IcH9QfxN10lPidA-TWJ_gsY9b2IiIymqS7RTPChIQyLxmhTQOGZFQFPMezD7y"_"hPd9-tRY_ukggi3nlT22Uc0_FEgN7JBL0eXt0CFdMMDcdok2CJtZ3LdZg56_AEIImWi3pZ"_"ulMw4dSMUtox7FAQYKGQ"
	;
