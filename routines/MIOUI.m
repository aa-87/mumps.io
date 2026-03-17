MIOUI ; MIOUI - SSR-first Tailwind UI package bootstrap
	;
	; Public entry points
	;   CONFDEF(.CONF)
	;   INIT(.CONF)
	;   REG(.CONF)
	;   VERSION()
	;
	Q
	;
CONFDEF(CONF)
	D DEFAULTS^MIOUITHEME(.CONF)
	I $G(CONF("server","templateDir"))="" S CONF("server","templateDir")="templates"
	I $G(CONF("templates","root"))="" S CONF("templates","root")=$G(CONF("server","templateDir"))_"/"
	I $G(CONF("templates","ext"))="" S CONF("templates","ext")=""
	Q
	;
INIT(CONF)
	D CONFDEF(.CONF)
	D START^MIOTPL(.CONF)
	Q
	;
REG(CONF)
	D REG^MIOUIDEMO(.CONF)
	D REG^MIOUIDTGD(.CONF)
	D REG^MIOUITWB(.CONF)
	D REG^MIOUITMX(.CONF)
	D REG^MIOUITSX(.CONF)
	D REG^MIOUILYT(.CONF)
	D REG^MIOUIADL(.CONF)
	D REG^MIOUILST(.CONF)
	D REG^MIOUILOV(.CONF)
	D REG^MIOUICLY(.CONF)
	D REG^MIOUIMMR(.CONF)
	D REG^MIOUICTR(.CONF)
	D REG^MIOUILDV(.CONF)
	D REG^MIOUILTP(.CONF)
	D REG^MIOUIAFM(.CONF)
	D REG^MIOUIPRF(.CONF)
	D REG^MIOUIBILLD(.CONF)
	Q
	;
VERSION()
	Q "0.2.6"
	;
BUILD()
	Q "2026-03-17 billing patient dense workspace"
	;
BANNER()
	Q "MIOUI "_$$VERSION()_" ("_$$BUILD()_")"
	;
	;