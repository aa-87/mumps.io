MIOSHA1T
	;
	;
	;
TEST1
	N $ET S $ET="G ETSOCK^MIOWS"
	S %WTCP=""
	N secKey,expect,got
	S secKey="dGhlIHNhbXBsZSBub25jZQ=="
	S expect="s3pPLMBiTxaQ9kYGzzhZRbK+xOo="
	S got=$$WSACCEPT^MIOSHA1(secKey)
	;W !,"Expected: ",expect,!
	;W "Got     : ",got,!
	W:(got'=expect) "MIOSHA1T-1 PASS?   : ",$S(got=expect:"YES",1:"NO"),!
	Q
TEST2
	N secKey,expect,got
	S secKey="dGhlIHNhbXBsZSBub25jZQ=="
	S expect="s3pPLMBiTxaQ9kYGzzhZRbK+xOo="
	S got=$$WSACCEPT^MIOSHA1(secKey)
	;W !,"Expected: ",expect,!
	;W "Got     : ",got,!
	W:(got'=expect) "MIOSHA1T-2 PASS?   : ",$S(got=expect:"YES",1:"NO"),!
	Q