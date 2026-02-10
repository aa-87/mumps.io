MIOTPLT
	D MIOTF200,MIOTF201
	Q
MIOTF201 ;Sections
	;Section tags and End Section tags are used in combination to wrap a section
	;of the template for iteration.;
	;These tags' content MUST be a non-whitespace character sequence NOT
	;containing the current closing delimiter; each Section tag MUST be followed
	;by an End Section tag with the same content within the same section.;
	;This tag's content names the data to replace the tag.  
	;Name resolution is as
	;follows:
	;  1) If the name is a single period (.), the data is the item currently
	;     sitting atop the context stack. Skip the rest of these steps.;
	;  2) Split the name on periods; the first part is the name to resolve, any
	;    remaining parts should be retained.;
	;  3) Walk the context stack from top to bottom, finding the first context
	;     that is 
	;         a) a hash containing the name as a key OR 
	;         b) an object responding to a method with the given name.;
	;  4) If the context is a hash, the data is the value associated with the name.;
	;  5) If the context is an object and the method with the given name has an
	;     arity of 1, the method SHOULD be called with a String containing the
	;     unprocessed contents of the sections; the data is the value returned.;
	;  6) Otherwise, the data is the value returned by calling the method with the given name.;
	;  7) If any name parts were retained in step 1, each should be resolved
	;     against a context stack containing only the result from the former resolution.;
	;     If any part fails resolution, the result should be considered
	;     falsey, and should interpolate as the empty string.;
	;     If the data is not of a list type, it is coerced into a list as follows: if
	;     the data is truthy (e.g. `!!data == true`), use a single-element list
	;      containing the data, otherwise use an empty list.;
	;      For each element in the data list, the element MUST be pushed onto the
	;      context stack, the section MUST be rendered, and the element MUST be popped
	;      off the context stack.;
	;      Section and End Section tags SHOULD be treated as standalone when appropriate."
	D TEST043,TEST044,TEST045,TEST046,TEST047,TEST048,TEST049,TEST050
	Q
MIOTF200 ;Interpolation
	; Interpolation tags are used to integrate dynamic content into the template.;
	; The tag's content MUST be a non-whitespace character sequence NOT containing
	; the current closing delimiter.;
	; This tag's content names and the data to replace the tag.  A single period (`.`)
	; indicates that the item currently sitting atop the context stack should be used; 
	; otherwise, name resolution is as follows:
	;   1) Split the name on periods; the first part is the name to resolve, 
	;      any remaining parts should be retained.;
	;   2) Walk the context stack from top to bottom, finding the first context
	;      that is: 
	;           a) a hash containing the name as a key OR 
	;           b) an object responding to a method with the given name.;
	;   3) If the context is a hash, the data is the value associated with the name.;
	;   4) If the context is an object, the data is the value returned by the method
	;      with the given name.;
	;   5) If any name parts were retained in step 1, each should be resolved against
	;      a context stack containing only the result from the former resolution.;
	;      If any part fails resolution, the result should be considered falsey, and
	;      should interpolate as the empty string. Data should be coerced into a string
	;      (and escaped, if appropriate) before interpolation. The Interpolation tags
	;      MUST NOT be treated as standalone
	D TEST001,TEST002,TEST003,TEST004,TEST005,TEST006,TEST007
	D TEST008,TEST009,TEST010,TEST011,TEST012,TEST013,TEST014
	D TEST015,TEST016,TEST017,TEST018,TEST019,TEST020,TEST021
	D TEST022,TEST023,TEST024,TEST025,TEST026,TEST027,TEST028
	D TEST029,TEST030,TEST031,TEST032,TEST033,TEST034,TEST035
	D TEST036,TEST037,TEST038,TEST039,TEST040,TEST041,TEST042
	Q
TEST043 ;
	NEW HDR S HDR="[MIOTPL][TEST043][Truthy]"
	NEW DESC S DESC=HDR_"[Truthy sections should have their contents rendered.]"
	NEW TEMPLATE S TEMPLATE="""{{#boolean}}This should be rendered.{{/boolean}}"""
	NEW EXPECTED S EXPECTED="""This should be rendered."""
	NEW CTX
	S CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST044
	NEW HDR S HDR="[MIOTPL][TEST044][Falsey]"
	NEW DESC S DESC=HDR_"[Falsey sections should have their contents omitted.]"
	NEW TEMPLATE S TEMPLATE="""{{#boolean}}This should not be rendered.{{/boolean}}"""
	NEW EXPECTED S EXPECTED=""""""
	NEW CTX 
	S CTX("boolean")="false"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST045
	NEW HDR S HDR="[MIOTPL][TEST045][Null is false]"
	NEW DESC S DESC=HDR_"[Null is falsey.]"
	NEW TEMPLATE S TEMPLATE="""{{#null}}This should not be rendered.{{/null}}"""
	NEW EXPECTED S EXPECTED=""""""
	NEW CTX 
	S CTX("null")=""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST046 
	NEW HDR S HDR="[MIOTPL][TEST046][Context]"
	NEW DESC S DESC=HDR_"[Objects and hashes should be pushed onto the context stack.]"
	NEW TEMPLATE S TEMPLATE="""{{#context}}Hi {{name}}.{{/context}}"""
	NEW EXPECTED S EXPECTED="""Hi Joe."""
	NEW CTX 
	S CTX("context")=1
	S CTX("name")="Joe"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST047
	NEW HDR S HDR="[MIOTPL][TEST047][Parent context]"
	NEW DESC S DESC=HDR_"[Names missing in the current context are looked up in the stack.]"
	NEW TEMPLATE S TEMPLATE="""{{#sec}}{{a}}, {{b}}, {{c.d}}{{/sec}}"""
	NEW EXPECTED S EXPECTED="""foo, bar, baz"""
	NEW CTX 
	S CTX("sec")=1
	S CTX("a")="foo"
	S CTX("b")="wrong"
	S CTX("sec","b")="bar"
	S CTX("c","d")="baz"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST048
	NEW HDR S HDR="[MIOTPL][TEST048][Variable test]"
	NEW DESC S DESC=HDR_"[Non-false sections have their value at the top of context,accessible as {{.}} or" 
	S DESC=DESC_"through the parent context. This gives a simple way to display content conditionally if a variable exists.]"
	NEW TEMPLATE S TEMPLATE="""{{#foo}}{{.}} is {{foo}}{{/foo}}"""
	NEW EXPECTED S EXPECTED="""bar is bar"""
	NEW CTX 
	SET CTC("foo")=1
	SET CTX("foo")="bar"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST049
	NEW HDR S HDR="[MIOTPL][TEST049][List Contexts]"
	NEW DESC S DESC=HDR_"[All elements on the context stack should be accessible within lists.]" 
	NEW TEMPLATE S TEMPLATE="{{#tops}}{{#middles}}{{tname.lower}}{{mname}}.{{#bottoms}}{{tname.upper}}{{mname}}{{bname}}.{{/bottoms}}{{/middles}}{{/tops}}"
	NEW EXPECTED S EXPECTED="a1.A1x.A1y."
	NEW CTX 
	SET CTX("tops",1,"middles",1,"bottoms",1,"bname")="x"
	SET CTX("tops",1,"middles",1,"bottoms",2,"bname")="y"
	SET CTX("tops",1,"middles",1,"mname")=1
	SET CTX("tops",1,"tname","lower")="a"
	SET CTX("tops",1,"tname","upper")="A"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST050
	NEW HDR S HDR="[MIOTPL][TEST050][Deeply Nested Contexts] "
	NEW DESC S DESC=HDR_"[All elements on the context stack should be accessible.]"
	NEW TEMPLATE S TEMPLATE="{{#a}}\n{{one}}\n{{#b}}\n{{one}}{{two}}{{one}}\n{{#c}}\n{{one}}{{two}}{{three}}{{two}}{{one}}\n{{#d}}\n{{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}\n{{#five}}\n{{one}}{{two}}{{three}}{{four}}{{five}}{{four}}{{three}}{{two}}{{one}}\n{{one}}{{two}}{{three}}{{four}}{{.}}6{{.}}{{four}}{{three}}{{two}}{{one}}\n{{one}}{{two}}{{three}}{{four}}{{five}}{{four}}{{three}}{{two}}{{one}}\n{{/five}}\n{{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}\n{{/d}}\n{{one}}{{two}}{{three}}{{two}}{{one}}\n{{/c}}\n{{one}}{{two}}{{one}}\n{{/b}}\n{{one}}\n{{/a}}\n"
	NEW EXPECTED S EXPECTED="1\n121\n12321\n1234321\n123454321\n12345654321\n123454321\n1234321\n12321\n121\n1\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	NEW CTX 
	SET CTX("a","one")=1
	SET CTX("b","two")=2
	SET CTX("c","d","five")=5
	SET CTX("c","d","four")=4
	SET CTX("c","three")=3
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
UNESCNL(S) Q $$UES^MIOJSON2(S) ; Enescape string from json/js -> M
	;
TEST000
	NEW HDR S HDR="[MIOTPL][TEST000][]"
	NEW DESC S DESC=HDR_"[]"
	NEW TEMPLATE S TEMPLATE=""
	NEW EXPECTED S EXPECTED=""
	NEW CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
	;
TEST001
	NEW HDR S HDR="[MIOTPL][TEST001][No Interpolation]"
	NEW DESC S DESC=HDR_"[Mustache-free templates should render as-is]"
	NEW TEMPLATE S TEMPLATE="Hello from {Mustache}!\n"
	NEW EXPECTED S EXPECTED="Hello from {Mustache}!\n"
	NEW CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST002
	NEW HDR S HDR="[MIOTPL][TEST002][Basic Interpolation]"
	NEW DESC S DESC=HDR_"[Unadorned tags should interpolate content into the template.]"
	NEW TEMPLATE S TEMPLATE="Hello, {{subject}}!\n"
	NEW EXPECTED S EXPECTED="Hello, world!\n"
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
TEST029
	NEW HDR S HDR="[MIOTPL][TEST029][Implicit Iterators - Basic Interpolation]"
	NEW DESC S DESC=HDR_"[Unadorned tags should interpolate content into the template.]"
	NEW TEMPLATE S TEMPLATE="Hello, {{.}}!\n"
	NEW EXPECTED S EXPECTED="Hello, world!\n"
	NEW CTX 
	SET CTX="world"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST030
	NEW HDR S HDR="[MIOTPL][TEST030][Implicit Iterators - HTML Escaping]"
	NEW DESC S DESC=HDR_"[Basic interpolation should be HTML escaped.]"
	NEW TEMPLATE S TEMPLATE="These characters should be HTML escaped: {{.}}\n"
	NEW EXPECTED S EXPECTED="These characters should be HTML escaped: &amp; &quot; &lt; &gt;\n"
	NEW CTX 
	SET CTX="& "" < >"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST031
	NEW HDR S HDR="[MIOTPL][TEST031][Implicit Iterators - Triple Mustache]"
	NEW DESC S DESC=HDR_"[Implicit Iterators - Triple Mustache.]"
	NEW TEMPLATE S TEMPLATE="These characters should not be HTML escaped: {{{.}}}\n"
	NEW EXPECTED S EXPECTED="These characters should not be HTML escaped: & "" < >\n"
	NEW CTX 
	SET CTX="& "" < >"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST032
	NEW HDR S HDR="[MIOTPL][TEST032][Implicit Iterators - Ampersand]"
	NEW DESC S DESC=HDR_"[Ampersand should interpolate without HTML escaping.]"
	NEW TEMPLATE S TEMPLATE="These characters should not be HTML escaped: {{&.}}\n"
	NEW EXPECTED S EXPECTED="These characters should not be HTML escaped: & "" < >\n"
	NEW CTX 
	SET CTX="& "" < >"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST033
	NEW HDR S HDR="[MIOTPL][TEST033][Implicit Iterators - Basic Integer Interpolation]"
	NEW DESC S DESC=HDR_"[Integers should interpolate seamlessly.]"
	NEW TEMPLATE S TEMPLATE="""{{.}} miles an hour!"""
	NEW EXPECTED S EXPECTED="""85 miles an hour!"""
	NEW CTX 
	SET CTX=85
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST034
	NEW HDR S HDR="[MIOTPL][TEST034][Interpolation - Surrounding Whitespace]"
	NEW DESC S DESC=HDR_"[Interpolation should not alter surrounding whitespace.]"
	NEW TEMPLATE S TEMPLATE="| {{string}} |"
	NEW EXPECTED S EXPECTED="| --- |"
	NEW CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST035
	NEW HDR S HDR="[MIOTPL][TEST035][Triple Mustache - Surrounding Whitespace]"
	NEW DESC S DESC=HDR_"[Interpolation should not alter surrounding whitespace.]"
	NEW TEMPLATE S TEMPLATE="| {{{string}}} |"
	NEW EXPECTED S EXPECTED="| --- |"
	NEW CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST036
	NEW HDR S HDR="[MIOTPL][TEST036][Ampersand - Surrounding Whitespace]"
	NEW DESC S DESC=HDR_"[Interpolation should not alter surrounding whitespace.]"
	NEW TEMPLATE S TEMPLATE="| {{&string}} |"
	NEW EXPECTED S EXPECTED="| --- |"
	NEW CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST037
	NEW HDR S HDR="[MIOTPL][TEST037][Interpolation - Standalone]"
	NEW DESC S DESC=HDR_"[Standalone interpolation should not alter surrounding whitespace.]"
	NEW TEMPLATE S TEMPLATE="  {{string}}\n"
	NEW EXPECTED S EXPECTED="  ---\n"
	NEW CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST038
	NEW HDR S HDR="[MIOTPL][TEST038][Triple Mustache - Standalone]"
	NEW DESC S DESC=HDR_"[Standalone interpolation should not alter surrounding whitespace.]"
	NEW TEMPLATE S TEMPLATE="  {{{string}}}\n"
	NEW EXPECTED S EXPECTED="  ---\n"
	NEW CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST039
	NEW HDR S HDR="[MIOTPL][TEST039][Ampersand - Standalone]"
	NEW DESC S DESC=HDR_"[Standalone interpolation should not alter surrounding whitespace.]"
	NEW TEMPLATE S TEMPLATE="  {{&string}}\n"
	NEW EXPECTED S EXPECTED="  ---\n"
	NEW CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST040
	NEW HDR S HDR="[MIOTPL][TEST040][Interpolation With Paddin]"
	NEW DESC S DESC=HDR_"[Superfluous in-tag whitespace should be ignored.]"
	NEW TEMPLATE S TEMPLATE="|{{ string }}|"
	NEW EXPECTED S EXPECTED="|---|"
	NEW CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST041
	NEW HDR S HDR="[MIOTPL][TEST041][Triple Mustache With Padding]"
	NEW DESC S DESC=HDR_"[Superfluous in-tag whitespace should be ignored.]"
	NEW TEMPLATE S TEMPLATE="|{{{ string }}}|"
	NEW EXPECTED S EXPECTED="|---|"
	NEW CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST042
	NEW HDR S HDR="[MIOTPL][TEST042][Ampersand With Padding]"
	NEW DESC S DESC=HDR_"[Superfluous in-tag whitespace should be ignored.]"
	NEW TEMPLATE S TEMPLATE="|{{& string }}|"
	NEW EXPECTED S EXPECTED="|---|"
	NEW CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,CTX)
	NEW TOK,ERR,CONF,OUT
	D COMPILE^MIOTPL2(TEMPLATE,.TOK,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"[COMPILE]"_HDR)
	DO EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"[EVAL]"_DESC)
	DO EQ^MIOTASSERT(OUT,EXPECTED,"[RENDER]"_DESC)
	Q