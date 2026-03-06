MIOSJWTT ; Tests for MIOSJWT
	;
	; Run:
	;   D ^MIOSJWTT
	;
	;
START ;
	D EN
	Q
	;
EN ;
	N FAIL,TOTAL,NOW,SECRET,PAY,TOK,OK
	S FAIL=0,TOTAL=0
	W !,"MIOSJWT test suite",!
	;
	D T("B64URL encode abc",$$B64URLE^MIOSJWT("abc"),"YWJj",.TOTAL,.FAIL)
	D T("B64URL decode abc",$$B64URLD^MIOSJWT("YWJj"),"abc",.TOTAL,.FAIL)
	;
	; RFC 7515 Appendix A.1 signing input example header/payload
	D T("HS256 sig known vector",$$SIGNHS256^MIOSJWT("eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ","your-256-bit-secret"),"GuoUe6tw79bJlbU1HU0ADX0pr0u2kf3r_4OdrDufSfQ",.TOTAL,.FAIL)
	;
	; round trip success
	S SECRET="super-secret-key"
	S NOW=$$NOW^MIOSJWT()
	S PAY=$$PAYLOAD^MIOSJWT("123","Ahmed","admin",NOW+3600,NOW,0)
	S TOK=$$MAKEHS256^MIOSJWT(PAY,SECRET)
	S OK=$$VERIFY1(TOK,SECRET,.TOTAL,.FAIL)
	;
	; wrong secret
	D T("verify wrong secret",$$VERIFYTOK(TOK,"wrong-secret"),0,.TOTAL,.FAIL)
	;
	; expired token
	S PAY=$$PAYLOAD^MIOSJWT("123","Ahmed","admin",NOW-10,NOW-3600,0)
	S TOK=$$MAKEHS256^MIOSJWT(PAY,SECRET)
	D T("verify expired token",$$VERIFYTOK(TOK,SECRET),0,.TOTAL,.FAIL)
	D T("expired err",$$GETERR(TOK,SECRET),"token_expired",.TOTAL,.FAIL)
	;
	; nbf in future
	S PAY=$$PAYLOAD^MIOSJWT("123","Ahmed","admin",NOW+3600,NOW,NOW+600)
	S TOK=$$MAKEHS256^MIOSJWT(PAY,SECRET)
	D T("verify nbf future",$$VERIFYTOK(TOK,SECRET),0,.TOTAL,.FAIL)
	D T("nbf err",$$GETERR(TOK,SECRET),"token_not_yet_valid",.TOTAL,.FAIL)
	;
	; malformed token
	D T("verify malformed",$$VERIFYTOK("abc.def",SECRET),0,.TOTAL,.FAIL)
	D T("malformed err",$$GETERR("abc.def",SECRET),"token_format",.TOTAL,.FAIL)
	;
	; tamper payload
	S PAY=$$PAYLOAD^MIOSJWT("123","Ahmed","admin",NOW+3600,NOW,0)
	S TOK=$$MAKEHS256^MIOSJWT(PAY,SECRET)
	S TOK=$P(TOK,".",1)_"."_$$B64URLE^MIOSJWT("{""sub"":""999"",""role"":""admin"",""exp"":"_(NOW+3600)_"}")_"."_$P(TOK,".",3)
	D T("verify tampered payload",$$VERIFYTOK(TOK,SECRET),0,.TOTAL,.FAIL)
	D T("tampered err",$$GETERR(TOK,SECRET),"bad_signature",.TOTAL,.FAIL)
	;
	W !
	W "Total: ",TOTAL,!
	W "Failed: ",FAIL,!
	I 'FAIL W "ALL TESTS PASSED",!
	E  W "TEST FAILURES DETECTED",!
	Q
	;
VERIFY1(TOK,SECRET,TOTAL,FAIL) ;
	N OUT,OK
	S OK=$$VERIFYHS256^MIOSJWT(TOK,SECRET,.OUT)
	D T("verify roundtrip",OK,1,.TOTAL,.FAIL)
	I OK D
	. D T("verify ok flag",$G(OUT("ok")),1,.TOTAL,.FAIL)
	. D T("verify payload present",$L($G(OUT("payload")))>0,1,.TOTAL,.FAIL)
	. D T("verify header present",$L($G(OUT("header")))>0,1,.TOTAL,.FAIL)
	Q OK
	;
VERIFYTOK(TOK,SECRET) ;
	N OUT
	Q $$VERIFYHS256^MIOSJWT($G(TOK),$G(SECRET),.OUT)
	;
GETERR(TOK,SECRET) ;
	N OUT,X
	S X=$$VERIFYHS256^MIOSJWT($G(TOK),$G(SECRET),.OUT)
	Q $G(OUT("err"))
	;
T(NAME,ACT,EXP,TOTAL,FAIL) ;
	S TOTAL=$G(TOTAL)+1
	I $G(ACT)=$G(EXP) W "OK:   ",NAME,!
	E  D
	. S FAIL=$G(FAIL)+1
	. W "FAIL: ",NAME,!
	. W "  got: ",$G(ACT),!
	. W "  exp: ",$G(EXP),!
	Q
	;