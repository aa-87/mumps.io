MIOTPLT
	;
	D TEST001,TEST002,TEST003,TEST004,TEST005,TEST006,TEST007
	D TEST008,TEST009,TEST010,TEST011,TEST012,TEST013,TEST014
	D TEST015,TEST016,TEST017,TEST018,TEST019,TEST020,TEST021
	D TEST022,TEST023,TEST024,TEST025,TEST026,TEST027,TEST028
	;	
	Q
TEST001
	NEW HDR S HDR="[MIOTPL][TEST001][No Interpolation]"
	NEW DESC S DESC=HDR_"[Mustache-free templates should render as-is]"
	NEW TEMPLATE S TEMPLATE=$$UES("Hello from {Mustache}!\n")
	NEW EXPECTED S EXPECTED=$$UES("Hello from {Mustache}!\n")
	NEW CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST002
	NEW HDR S HDR="[MIOTPL][TEST002][Basic Interpolation]"
	NEW DESC S DESC=HDR_"[Unadorned tags should interpolate content into the template.]"
	NEW TEMPLATE S TEMPLATE=$$UES("Hello, {{subject}}!\n")
	NEW EXPECTED S EXPECTED=$$UES("Hello, world!\n")
	NEW CTX
	SET CTX("subject")="world"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST003
	NEW HDR S HDR="[MIOTPL][TEST003][No Re-interpolation]"
	NEW DESC S DESC=HDR_"[Interpolated tag output should not be re-interpolated.]"
	NEW TEMPLATE S TEMPLATE="{{template}}: {{planet}}"
	NEW EXPECTED S EXPECTED="{{planet}}: Earth"
	NEW CTX
	SET CTX("template")="{{planet}}"
	SET CTX("planet")="Earth"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST004
	NEW HDR S HDR="[MIOTPL][TEST004][HTML Escaping]"
	NEW DESC S DESC=HDR_"[Basic interpolation should be HTML escaped..]"
	NEW TEMPLATE S TEMPLATE="These characters should be HTML escaped: {{forbidden}}"
	NEW EXPECTED S EXPECTED="These characters should be HTML escaped: &amp; &quot; &lt; &gt;"
	NEW CTX SET CTX("forbidden")="& "" < >"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST005
	NEW HDR S HDR="[MIOTPL][TEST005][Triple Mustache]"
	NEW DESC S DESC=HDR_"[Triple mustaches should interpolate without HTML escaping.]"
	NEW TEMPLATE S TEMPLATE="These characters should not be HTML escaped: {{{forbidden}}}"
	NEW EXPECTED S EXPECTED="These characters should not be HTML escaped: & "" < >"
	NEW CTX SET CTX("forbidden")="& "" < >"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST006
	NEW HDR S HDR="[MIOTPL][TEST006][Ampersand]"
	NEW DESC S DESC=HDR_"[Ampersand should interpolate without HTML escaping.]"
	NEW TEMPLATE S TEMPLATE="These characters should not be HTML escaped: {{{forbidden}}}"
	NEW EXPECTED S EXPECTED="These characters should not be HTML escaped: & "" < >"
	NEW CTX SET CTX("forbidden")="& "" < >"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST007
	NEW HDR S HDR="[MIOTPL][TEST007][Basic Integer Interpolation]"
	NEW DESC S DESC=HDR_"[Integers should interpolate seamlessly.]"
	NEW TEMPLATE S TEMPLATE="""{{mph}} miles an hour!"""
	NEW EXPECTED S EXPECTED="""85 miles an hour!"""
	NEW CTX 
	SET CTX("mph")=85
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST008
	NEW HDR S HDR="[MIOTPL][TEST008][Triple Mustache Integer Interpolation]"
	NEW DESC S DESC=HDR_"[Integers should interpolate seamlessly.]"
	NEW TEMPLATE S TEMPLATE="""{{{mph}}} miles an hour!"""
	NEW EXPECTED S EXPECTED="""85 miles an hour!"""
	NEW CTX 
	SET CTX("mph")=85
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST009
	NEW HDR S HDR="[MIOTPL][TEST009][Ampersand Integer Interpolation]"
	NEW DESC S DESC=HDR_"[Integers should interpolate seamlessly.]"
	NEW TEMPLATE S TEMPLATE="""{{&mph}} miles an hour!"""
	NEW EXPECTED S EXPECTED="""85 miles an hour!"""
	NEW CTX 
	SET CTX("mph")=85
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST010
	NEW HDR S HDR="[MIOTPL][TEST010[Basic Decimal Interpolation]"
	NEW DESC S DESC=HDR_"[Decimals should interpolate seamlessly with proper significance.]"
	NEW TEMPLATE S TEMPLATE="""{{power}} jiggawatts!"""
	NEW EXPECTED S EXPECTED="""1.21 jiggawatts!"""
	NEW CTX 
	SET CTX("power")=1.21
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST011
	NEW HDR S HDR="[MIOTPL][TEST011][Triple Mustache Decimal Interpolation]"
	NEW DESC S DESC=HDR_"[Decimals should interpolate seamlessly with proper significance.]"
	NEW TEMPLATE S TEMPLATE="""{{{power}}} jiggawatts!"""
	NEW EXPECTED S EXPECTED="""1.21 jiggawatts!"""
	NEW CTX 
	SET CTX("power")=1.21
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST012
	NEW HDR S HDR="[MIOTPL][TEST012[Ampersand Decimal Interpolation]"
	NEW DESC S DESC=HDR_"[Decimals should interpolate seamlessly with proper significance.]"
	NEW TEMPLATE S TEMPLATE="""{{&power}} jiggawatts!"""
	NEW EXPECTED S EXPECTED="""1.21 jiggawatts!"""
	NEW CTX 
	SET CTX("power")=1.21
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST013
	NEW HDR S HDR="[MIOTPL][TEST013][Basic Null Interpolation]"
	NEW DESC S DESC=HDR_"[Nulls should interpolate as the empty string.]"
	NEW TEMPLATE S TEMPLATE="I ({{cannot}}) be seen!"
	NEW EXPECTED S EXPECTED="I () be seen!"
	NEW CTX 
	SET CTX("cannot")=""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST014
	NEW HDR S HDR="[MIOTPL][TEST014[Triple Mustache Null Interpolation]"
	NEW DESC S DESC=HDR_"[Nulls should interpolate as the empty string.]"
	NEW TEMPLATE S TEMPLATE="I ({{{cannot}}}) be seen!"
	NEW EXPECTED S EXPECTED="I () be seen!"
	NEW CTX 
	SET CTX("cannot")=""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST015
	NEW HDR S HDR="[MIOTPL][TEST015][Ampersand Null Interpolation]"
	NEW DESC S DESC=HDR_"[Nulls should interpolate as the empty string.]"
	NEW TEMPLATE S TEMPLATE="I ({{&cannot}}) be seen!"
	NEW EXPECTED S EXPECTED="I () be seen!"
	NEW CTX 
	SET CTX("cannot")=""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST016
	NEW HDR S HDR="[MIOTPL][TEST016[Basic Context Miss Interpolation]"
	NEW DESC S DESC=HDR_"[Failed context lookups should default to empty strings.]"
	NEW TEMPLATE S TEMPLATE="I ({{cannot}}) be seen!"
	NEW EXPECTED S EXPECTED="I () be seen!"
	NEW CTX 
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST017
	NEW HDR S HDR="[MIOTPL][TEST017][Triple Mustache Context Miss Interpolation]"
	NEW DESC S DESC=HDR_"[Failed context lookups should default to empty strings.]"
	NEW TEMPLATE S TEMPLATE="I ({{{cannot}}}) be seen!"
	NEW EXPECTED S EXPECTED="I () be seen!"
	NEW CTX 
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST018
	NEW HDR S HDR="[MIOTPL][TEST018[Ampersand Context Miss Interpolation]"
	NEW DESC S DESC=HDR_"[Failed context lookups should default to empty strings.]"
	NEW TEMPLATE S TEMPLATE="I ({{&cannot}}) be seen!"
	NEW EXPECTED S EXPECTED="I () be seen!"
	NEW CTX 
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST019
	NEW HDR S HDR="[MIOTPL][TEST019][Dotted Names - Basic Interpolation]"
	NEW DESC S DESC=HDR_"[Dotted names should be considered a form of shorthand for sections.]"
	NEW TEMPLATE S TEMPLATE="""{{person.name}}"" == ""{{#person}}{{name}}{{/person}}"""
	NEW EXPECTED S EXPECTED="""Joe"" == ""Joe"""
	NEW CTX 
	SET CTX("person","name")="Joe"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST020
	NEW HDR S HDR="[MIOTPL][TEST020][Dotted Names - Triple Mustache Interpolation]"
	NEW DESC S DESC=HDR_"[Dotted names should be considered a form of shorthand for sections.]"
	NEW TEMPLATE S TEMPLATE="""{{{person.name}}}"" == ""{{#person}}{{{name}}}{{/person}}""" 
	NEW EXPECTED S EXPECTED="""Joe"" == ""Joe"""
	NEW CTX 
	SET CTX("person","name")="Joe"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST021
	NEW HDR S HDR="[MIOTPL][TEST021][Dotted Names - Ampersand Interpolation]"
	NEW DESC S DESC=HDR_"[Dotted names should be considered a form of shorthand for sections.]"
	NEW TEMPLATE S TEMPLATE="""{{&person.name}}"" == ""{{#person}}{{&name}}{{/person}}"""
	NEW EXPECTED S EXPECTED="""Joe"" == ""Joe"""
	NEW CTX 
	SET CTX("person","name")="Joe"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST022
	NEW HDR S HDR="[MIOTPL][TEST022][Dotted Names - Arbitrary Depth]"
	NEW DESC S DESC=HDR_"[Dotted names should be functional to any level of nesting.]"
	NEW TEMPLATE S TEMPLATE="""{{a.b.c.d.e.name}}"" == ""Phil"""
	NEW EXPECTED S EXPECTED="""Phil"" == ""Phil"""
	NEW CTX 
	SET CTX("a","b","c","d","e","name")="Phil"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST023
	NEW HDR S HDR="[MIOTPL][TEST023][Dotted Names - Broken Chains]"
	NEW DESC S DESC=HDR_"[Any falsey value prior to the last part of the name should yield ''.]"
	NEW TEMPLATE S TEMPLATE="""{{a.b.c}}"" == """""
	NEW EXPECTED S EXPECTED=""""" == """""
	NEW CTX 
	SET CTX("a")=""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST024
	NEW HDR S HDR="[MIOTPL][TEST024][Dotted Names - Broken Chain Resolution]"
	NEW DESC S DESC=HDR_"[Each part of a dotted name should resolve only against its parent.]"
	NEW TEMPLATE S TEMPLATE="""{{a.b.c.name}}"" == """""
	NEW EXPECTED S EXPECTED=""""" == """""
	NEW CTX 
	SET CTX("a","b")=""
	SET CTX("c","name")="Jim"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST025
	NEW HDR S HDR="[MIOTPL][TEST025][Dotted Names - Initial Resolution]"
	NEW DESC S DESC=HDR_"[The first part of a dotted name should resolve as any other name.]"
	NEW TEMPLATE S TEMPLATE="""{{#a}}{{b.c.d.e.name}}{{/a}}"" == ""Phil"""
	NEW EXPECTED S EXPECTED="""Phil"" == ""Phil"""
	NEW CTX 
	SET CTX("a","b","c","d","e","name")="Phil"
	SET CTX("b","c","d","e","name")="Wrong"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST026
	NEW HDR S HDR="[MIOTPL][TEST026][Dotted Names - Context Precedence]"
	NEW DESC S DESC=HDR_"[Dotted names should be resolved against former resolutions.]"
	NEW TEMPLATE S TEMPLATE="{{#a}}{{b.c}}{{/a}}"
	NEW EXPECTED S EXPECTED=""
	NEW CTX 
	SET CTX("a","b")=""
	SET CTX("b","c")="ERROR"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST027
	NEW HDR S HDR="[MIOTPL][TEST027][Dotted Names are never single keys]"
	NEW DESC S DESC=HDR_"[Dotted names shall not be parsed as single, atomic keys]"
	NEW TEMPLATE S TEMPLATE="{{a.b}}"
	NEW EXPECTED S EXPECTED=""
	NEW CTX 
	SET CTX("a.b")="c"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST028
	NEW HDR S HDR="[MIOTPL][TEST028][Dotted Names - No Masking]"
	NEW DESC S DESC=HDR_"[Dotted Names in a given context are unvavailable due to dot splitting]"
	NEW TEMPLATE S TEMPLATE="{{a.b}}"
	NEW EXPECTED S EXPECTED="d"
	NEW CTX 
	SET CTX("a.b")="c"
	SET CTX("a","b")="d"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
	;
TEST000
	NEW HDR S HDR="[MIOTPL][TEST000][]"
	NEW DESC S DESC=HDR_""
	NEW TEMPLATE S TEMPLATE=""
	NEW EXPECTED S EXPECTED=""
	NEW CTX 
	SET CTX("")=""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
UES(X)
	N POS,Y,START
	S POS=0,Y=""
	F  S START=POS+1 D  Q:START>$L(X)
	. S POS=$F(X,"\",POS+1)
	. I 'POS S Y=Y_$E(X,START,$L(X)),POS=$L(X) I 1
	. E  S Y=Y_$E(X,START,POS-2)_$$REALCHAR($E(X,POS),X,.POS)
	Q Y
RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,CTX)
	NEW TOK,ERR,CONF,OUT
	D COMPILE^MIOTPL2(TEMPLATE,.TOK,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"[COMPILE]"_HDR)
	DO EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"[EVAL]"_DESC)
	DO EQ^MIOTASSERT(OUT,EXPECTED,"[RENDER]"_DESC)
	Q
	;
REALCHAR(C,X,POS)
	N OPOS
	I C="""" Q """"
	I C="/" Q "/"
	I C="\" Q "\"
	I C="b" Q $C(8)
	I C="f" Q $C(12)
	I C="n" Q $C(10)
	I C="r" Q $C(13)
	I C="t" Q $C(9)
	I C="u" S OPOS=POS S POS=POS+4 Q $C($$FUNC^%HD($E(X,OPOS+1,OPOS+4)))
	Q C
	;
	;