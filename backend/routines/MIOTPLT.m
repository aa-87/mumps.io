MIOTPLT
	D MIOTF200,MIOTF201,MIOTF202,MIOTF203
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
	D RUNJSONSPECS("./tests/data/interpolation.json") ;This is the same as below.;
	; Each test is run two different ways
	D TEST001,TEST002,TEST003,TEST004,TEST005,TEST006,TEST007
	D TEST008,TEST009,TEST010,TEST011,TEST012,TEST013,TEST014
	D TEST015,TEST016,TEST017,TEST018,TEST019,TEST020,TEST021
	D TEST022,TEST023,TEST024,TEST025,TEST026,TEST027,TEST028
	D TEST029,TEST030,TEST031,TEST032,TEST033,TEST034,TEST035
	D TEST036,TEST037,TEST038,TEST039,TEST040,TEST041,TEST042
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
	D RUNJSONSPECS("./tests/data/sections.json") ;This is the same as below.;
	; Each test is run two different ways
	D TEST043,TEST044,TEST045,TEST046,TEST047,TEST048,TEST049
	D TEST050,TEST051,TEST052,TEST053,TEST054,TEST055,TEST056
	D TEST057,TEST058,TEST059,TEST060,TEST061,TEST062,TEST063
	D TEST064,TEST065,TEST066,TEST067,TEST068,TEST069,TEST070
	D TEST071,TEST072,TEST073,TEST074,TEST075,TEST076
	Q
MIOTF202 ;Inverted
	; Inverted Section tags and End Section tags are used in combination to wrap a
	; section of the template.;
	; These tags' content MUST be a non-whitespace character sequence NOT
	; containing the current closing delimiter; each Inverted Section tag MUST be
	; followed by an End Section tag with the same content within the same section.;
	; This tag's content names the data to replace the tag.  
	; Name resolution is as follows:
	;   1) Split the name on periods; the first part is the name to resolve, any
	;       remaining parts should be retained.;
	;   2) Walk the context stack from top to bottom, finding the first context that is 
	;       a) a hash containing the name as a key OR 
	;       b) an object responding to a method with the given name. ;
	;   3) If the context is a hash, the data is the value associated with the name.;
	;   4) If the context is an object and the method with the given name has an arity of 1, 
	;      the method SHOULD be called with a String containing the
	;     unprocessed contents of the sections; the data is the value returned.;
	;   5) Otherwise, the data is the value returned by calling the method with
	;      the given name.;
	;   6) If any name parts were retained in step 1, each should be resolved
	;      against a context stack containing only the result from the former resolution.;
	;      If any part fails resolution, the result should be considered falsey, and 
	;      should interpolate as the empty string.If the data is not of a list type,
	;      it is coerced into a list as follows: 
	;          if the data is truthy (e.g. `!!data == true`), use a single-element list
	;          containing the data, otherwise use an empty list.;
	;   This section MUST NOT be rendered unless the data list is empty.;
	;   Inverted Section and End Section tags SHOULD be treated as standalone when appropriate.;
	D RUNJSONSPECS("./tests/data/inverted.json") ;This is the same as below.;
	; Each test is run two different ways
	D TEST077,TEST078,TEST079,TEST080,TEST081,TEST082,TEST083
	D TEST084,TEST085,TEST086,TEST087,TEST088,TEST089,TEST090
	D TEST091,TEST091,TEST092,TEST093,TEST094,TEST095,TEST096
	D TEST097,TEST098
	Q
MIOTF203 ;Partials
	;  Partial tags are used to expand an external template into the current
	;  template.The tag's content MUST be a non-whitespace character sequence
	;  NOT containing the current closing delimiter. This tag's content names
	;  the partial to inject. Set Delimiter tags MUST NOT affect the parsing
	;  of a partial. The partial MUST be rendered against the context stack 
	;  local to the tag. If the named partial cannot be found, the
	;  empty string SHOULD be used instead, as in interpolations. Partial tags
	;  SHOULD be treated as standalone when appropriate. If this tag is used
	;  standalone, any whitespace preceding the tag should treated as indentation, 
	;  and prepended to each line of the partial before rendering.;
	D RUNJSONSPECSPART("./tests/data/partials.json") ;This is the same as below.;
	; Each test is run two different ways
	D TEST099,TEST100,TEST101,TEST102,TEST103,TEST104,TEST105
	D TEST106,TEST107,TEST108,TEST109,TEST110
	QUIT
MIOTF204 ;Comments
	; Comment tags represent content that should never appear in the resulting
	; output.The tag's content may contain any substring (including newlines) 
	; EXCEPT the closing delimiter. Comment tags SHOULD be treated as
	D RUNJSONSPECS("./tests/data/comments.json") ;This is the same as below.;
	; Each test is run two different ways
	;  standalone when appropriate.;
	D TEST111,TEST112,TEST113,TEST114,TEST115,TEST116,TEST117
	D TEST118,TEST119,TEST120,TEST121,TEST122
	QUIT
MIOTF205 ;Delimiters
	; Set Delimiter tags are used to change the tag delimiters for all content
	; following the tag in the current compilation unit.;
	; The tag's content MUST be any two non-whitespace sequences 
	; (separated by\nwhitespace) EXCEPT an equals sign ('=') followed
	;  by the current closing\ndelimiter.\n\nSet Delimiter tags
	;  SHOULD be treated as standalone when appropriate.\n"
	D RUNJSONSPECSPART("./tests/data/delimiters.json") ;This is the same as below.;
	; Each test is run two different ways
	D TEST123,TEST124,TEST125,TEST126,TEST127,TEST128,TEST129
	D TEST130,TEST131,TEST132,TEST133,TEST134,TEST135,TEST136
	D TEST137
	QUIT 	 
MIOTF206 ;Inheritance
	; Like partials, Parent tags are used to expand an external template into the
	; current template. Unlike partials, Parent tags may contain optional
	; arguments delimited by Block tags. For this reason, Parent tags may also be
	; referred to as Parametric Partials.\n\nThe Parent tags' 
	; content MUST be a non-whitespace character sequence NOT
	; containing the current closing delimiter; each Parent tag MUST be followed by
	; an End Section tag with the same content within the matching Parent tag.;
	; This tag's content names the Parent template to inject. Set Delimiter tags
	; Preceding a Parent tag MUST NOT affect the parsing of the injected external
	; template. The Parent MUST be rendered against the context stack local to the
	; tag. If the named Parent cannot be found, the empty string SHOULD be used
	; instead, as in interpolations.Parent tags SHOULD be treated as standalone when
	;  appropriate. If this tag is used standalone, any whitespace preceding
	; the tag should be treated as indentation, and prepended to each line of 
	; the Parent before rendering. The Block tags' content MUST be a 
	; non-whitespace character sequence NOT containing the current closing delimiter.;
	; Each Block tag MUST be followed by an End Section tag with the same content within
	;  the matching Block tag. This tag's content determines the parameter or argument name.;
	; Block tags may appear both inside and outside of Parent tags. In both cases,
	; they specify a position within the template that can be overridden; it is a
	; parameter of the containing template. The template text between the Block tag
	; and its matching End Section tag defines the default content to render when
	; the parameter is not overridden from outside. In addition, when used inside of
	; a Parent tag, the template text between a Block tag and its matching
	; End Section tag defines content that replaces the default defined in
	; the Parent template. This content is the argument passed to the Parent template.;
	; The practice of injecting an external template using a Parent tag is referred
	; to as inheritance. If the Parent tag includes a Block tag that overrides a
	; parameter of the Parent template, this may also be referred to as
	; substitution.Parent templates are taken from the same namespace as regular
	; Partial templates and in fact, injecting a regular Partial is
	;  exactly equivalent to injecting a Parent without making
	; any substitutions. Parameter and arguments names live in a namespace
	; that is distinct from both Partials and the context.	
	D TEST138,TEST139,TEST140,TEST141,TEST142,TEST143,TEST144
	D TEST145,TEST146,TEST147,TEST148,TEST149
	QUIT 		
TEST001
	NEW HDR S HDR="[TEST001][No Interpolation]"
	NEW DESC S DESC=HDR_"[Mustache-free templates should render as-is]"
	NEW TEMPLATE S TEMPLATE="Hello from {Mustache}!\n"
	NEW EXPECTED S EXPECTED="Hello from {Mustache}!\n"
	NEW CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST002
	NEW HDR S HDR="[TEST002][Basic Interpolation]"
	NEW DESC S DESC=HDR_"[Unadorned tags should interpolate content into the template.]"
	NEW TEMPLATE S TEMPLATE="Hello, {{subject}}!\n"
	NEW EXPECTED S EXPECTED="Hello, world!\n"
	NEW CTX
	SET CTX("subject")="world"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST003
	NEW HDR S HDR="[TEST003][No Re-interpolation]"
	NEW DESC S DESC=HDR_"[Interpolated tag output should not be re-interpolated.]"
	NEW TEMPLATE S TEMPLATE="{{template}}: {{planet}}"
	NEW EXPECTED S EXPECTED="{{planet}}: Earth"
	NEW CTX
	SET CTX("template")="{{planet}}"
	SET CTX("planet")="Earth"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST004
	NEW HDR S HDR="[TEST004][HTML Escaping]"
	NEW DESC S DESC=HDR_"[Basic interpolation should be HTML escaped..]"
	NEW TEMPLATE S TEMPLATE="These characters should be HTML escaped: {{forbidden}}"
	NEW EXPECTED S EXPECTED="These characters should be HTML escaped: &amp; &quot; &lt; &gt;"
	NEW CTX SET CTX("forbidden")="& "" < >"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST005
	NEW HDR S HDR="[TEST005][Triple Mustache]"
	NEW DESC S DESC=HDR_"[Triple mustaches should interpolate without HTML escaping.]"
	NEW TEMPLATE S TEMPLATE="These characters should not be HTML escaped: {{{forbidden}}}"
	NEW EXPECTED S EXPECTED="These characters should not be HTML escaped: & "" < >"
	NEW CTX SET CTX("forbidden")="& "" < >"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST006
	NEW HDR S HDR="[TEST006][Ampersand]"
	NEW DESC S DESC=HDR_"[Ampersand should interpolate without HTML escaping.]"
	NEW TEMPLATE S TEMPLATE="These characters should not be HTML escaped: {{{forbidden}}}"
	NEW EXPECTED S EXPECTED="These characters should not be HTML escaped: & "" < >"
	NEW CTX SET CTX("forbidden")="& "" < >"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST007
	NEW HDR S HDR="[TEST007][Basic Integer Interpolation]"
	NEW DESC S DESC=HDR_"[Integers should interpolate seamlessly.]"
	NEW TEMPLATE S TEMPLATE="""{{mph}} miles an hour!"""
	NEW EXPECTED S EXPECTED="""85 miles an hour!"""
	NEW CTX 
	SET CTX("mph")=85
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST008
	NEW HDR S HDR="[TEST008][Triple Mustache Integer Interpolation]"
	NEW DESC S DESC=HDR_"[Integers should interpolate seamlessly.]"
	NEW TEMPLATE S TEMPLATE="""{{{mph}}} miles an hour!"""
	NEW EXPECTED S EXPECTED="""85 miles an hour!"""
	NEW CTX 
	SET CTX("mph")=85
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST009
	NEW HDR S HDR="[TEST009][Ampersand Integer Interpolation]"
	NEW DESC S DESC=HDR_"[Integers should interpolate seamlessly.]"
	NEW TEMPLATE S TEMPLATE="""{{&mph}} miles an hour!"""
	NEW EXPECTED S EXPECTED="""85 miles an hour!"""
	NEW CTX 
	SET CTX("mph")=85
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST010
	NEW HDR S HDR="[TEST010[Basic Decimal Interpolation]"
	NEW DESC S DESC=HDR_"[Decimals should interpolate seamlessly with proper significance.]"
	NEW TEMPLATE S TEMPLATE="""{{power}} jiggawatts!"""
	NEW EXPECTED S EXPECTED="""1.21 jiggawatts!"""
	NEW CTX 
	SET CTX("power")=1.21
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST011
	NEW HDR S HDR="[TEST011][Triple Mustache Decimal Interpolation]"
	NEW DESC S DESC=HDR_"[Decimals should interpolate seamlessly with proper significance.]"
	NEW TEMPLATE S TEMPLATE="""{{{power}}} jiggawatts!"""
	NEW EXPECTED S EXPECTED="""1.21 jiggawatts!"""
	NEW CTX 
	SET CTX("power")=1.21
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST012
	NEW HDR S HDR="[TEST012[Ampersand Decimal Interpolation]"
	NEW DESC S DESC=HDR_"[Decimals should interpolate seamlessly with proper significance.]"
	NEW TEMPLATE S TEMPLATE="""{{&power}} jiggawatts!"""
	NEW EXPECTED S EXPECTED="""1.21 jiggawatts!"""
	NEW CTX 
	SET CTX("power")=1.21
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST013
	NEW HDR S HDR="[TEST013][Basic Null Interpolation]"
	NEW DESC S DESC=HDR_"[Nulls should interpolate as the empty string.]"
	NEW TEMPLATE S TEMPLATE="I ({{cannot}}) be seen!"
	NEW EXPECTED S EXPECTED="I () be seen!"
	NEW CTX 
	SET CTX("cannot")=""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST014
	NEW HDR S HDR="[TEST014[Triple Mustache Null Interpolation]"
	NEW DESC S DESC=HDR_"[Nulls should interpolate as the empty string.]"
	NEW TEMPLATE S TEMPLATE="I ({{{cannot}}}) be seen!"
	NEW EXPECTED S EXPECTED="I () be seen!"
	NEW CTX 
	SET CTX("cannot")=""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST015
	NEW HDR S HDR="[TEST015][Ampersand Null Interpolation]"
	NEW DESC S DESC=HDR_"[Nulls should interpolate as the empty string.]"
	NEW TEMPLATE S TEMPLATE="I ({{&cannot}}) be seen!"
	NEW EXPECTED S EXPECTED="I () be seen!"
	NEW CTX 
	SET CTX("cannot")=""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST016
	NEW HDR S HDR="[TEST016[Basic Context Miss Interpolation]"
	NEW DESC S DESC=HDR_"[Failed context lookups should default to empty strings.]"
	NEW TEMPLATE S TEMPLATE="I ({{cannot}}) be seen!"
	NEW EXPECTED S EXPECTED="I () be seen!"
	NEW CTX 
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST017
	NEW HDR S HDR="[TEST017][Triple Mustache Context Miss Interpolation]"
	NEW DESC S DESC=HDR_"[Failed context lookups should default to empty strings.]"
	NEW TEMPLATE S TEMPLATE="I ({{{cannot}}}) be seen!"
	NEW EXPECTED S EXPECTED="I () be seen!"
	NEW CTX 
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST018
	NEW HDR S HDR="[TEST018[Ampersand Context Miss Interpolation]"
	NEW DESC S DESC=HDR_"[Failed context lookups should default to empty strings.]"
	NEW TEMPLATE S TEMPLATE="I ({{&cannot}}) be seen!"
	NEW EXPECTED S EXPECTED="I () be seen!"
	NEW CTX 
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST019
	NEW HDR S HDR="[TEST019][Dotted Names - Basic Interpolation]"
	NEW DESC S DESC=HDR_"[Dotted names should be considered a form of shorthand for sections.]"
	NEW TEMPLATE S TEMPLATE="""{{person.name}}"" == ""{{#person}}{{name}}{{/person}}"""
	NEW EXPECTED S EXPECTED="""Joe"" == ""Joe"""
	NEW CTX 
	SET CTX("person","name")="Joe"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST020
	NEW HDR S HDR="[TEST020][Dotted Names - Triple Mustache Interpolation]"
	NEW DESC S DESC=HDR_"[Dotted names should be considered a form of shorthand for sections.]"
	NEW TEMPLATE S TEMPLATE="""{{{person.name}}}"" == ""{{#person}}{{{name}}}{{/person}}""" 
	NEW EXPECTED S EXPECTED="""Joe"" == ""Joe"""
	NEW CTX 
	SET CTX("person","name")="Joe"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST021
	NEW HDR S HDR="[TEST021][Dotted Names - Ampersand Interpolation]"
	NEW DESC S DESC=HDR_"[Dotted names should be considered a form of shorthand for sections.]"
	NEW TEMPLATE S TEMPLATE="""{{&person.name}}"" == ""{{#person}}{{&name}}{{/person}}"""
	NEW EXPECTED S EXPECTED="""Joe"" == ""Joe"""
	NEW CTX 
	SET CTX("person","name")="Joe"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST022
	NEW HDR S HDR="[TEST022][Dotted Names - Arbitrary Depth]"
	NEW DESC S DESC=HDR_"[Dotted names should be functional to any level of nesting.]"
	NEW TEMPLATE S TEMPLATE="""{{a.b.c.d.e.name}}"" == ""Phil"""
	NEW EXPECTED S EXPECTED="""Phil"" == ""Phil"""
	NEW CTX 
	SET CTX("a","b","c","d","e","name")="Phil"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST023
	NEW HDR S HDR="[TEST023][Dotted Names - Broken Chains]"
	NEW DESC S DESC=HDR_"[Any falsey value prior to the last part of the name should yield ''.]"
	NEW TEMPLATE S TEMPLATE="""{{a.b.c}}"" == """""
	NEW EXPECTED S EXPECTED=""""" == """""
	NEW CTX 
	SET CTX("a")=""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST024
	NEW HDR S HDR="[TEST024][Dotted Names - Broken Chain Resolution]"
	NEW DESC S DESC=HDR_"[Each part of a dotted name should resolve only against its parent.]"
	NEW TEMPLATE S TEMPLATE="""{{a.b.c.name}}"" == """""
	NEW EXPECTED S EXPECTED=""""" == """""
	NEW CTX 
	SET CTX("a","b")=""
	SET CTX("c","name")="Jim"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST025
	NEW HDR S HDR="[TEST025][Dotted Names - Initial Resolution]"
	NEW DESC S DESC=HDR_"[The first part of a dotted name should resolve as any other name.]"
	NEW TEMPLATE S TEMPLATE="""{{#a}}{{b.c.d.e.name}}{{/a}}"" == ""Phil"""
	NEW EXPECTED S EXPECTED="""Phil"" == ""Phil"""
	NEW CTX 
	SET CTX("a","b","c","d","e","name")="Phil"
	SET CTX("b","c","d","e","name")="Wrong"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST026
	NEW HDR S HDR="[TEST026][Dotted Names - Context Precedence]"
	NEW DESC S DESC=HDR_"[Dotted names should be resolved against former resolutions.]"
	NEW TEMPLATE S TEMPLATE="{{#a}}{{b.c}}{{/a}}"
	NEW EXPECTED S EXPECTED=""
	NEW CTX 
	SET CTX("a","b")=""
	SET CTX("b","c")="ERROR"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST027
	NEW HDR S HDR="[TEST027][Dotted Names are never single keys]"
	NEW DESC S DESC=HDR_"[Dotted names shall not be parsed as single, atomic keys]"
	NEW TEMPLATE S TEMPLATE="{{a.b}}"
	NEW EXPECTED S EXPECTED=""
	NEW CTX 
	SET CTX("a.b")="c"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST028
	NEW HDR S HDR="[TEST028][Dotted Names - No Masking]"
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
	NEW HDR S HDR="[TEST029][Implicit Iterators - Basic Interpolation]"
	NEW DESC S DESC=HDR_"[Unadorned tags should interpolate content into the template.]"
	NEW TEMPLATE S TEMPLATE="Hello, {{.}}!\n"
	NEW EXPECTED S EXPECTED="Hello, world!\n"
	NEW CTX 
	SET CTX="world"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST030
	NEW HDR S HDR="[TEST030][Implicit Iterators - HTML Escaping]"
	NEW DESC S DESC=HDR_"[Basic interpolation should be HTML escaped.]"
	NEW TEMPLATE S TEMPLATE="These characters should be HTML escaped: {{.}}\n"
	NEW EXPECTED S EXPECTED="These characters should be HTML escaped: &amp; &quot; &lt; &gt;\n"
	NEW CTX 
	SET CTX="& "" < >"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST031
	NEW HDR S HDR="[TEST031][Implicit Iterators - Triple Mustache]"
	NEW DESC S DESC=HDR_"[Implicit Iterators - Triple Mustache.]"
	NEW TEMPLATE S TEMPLATE="These characters should not be HTML escaped: {{{.}}}\n"
	NEW EXPECTED S EXPECTED="These characters should not be HTML escaped: & "" < >\n"
	NEW CTX 
	SET CTX="& "" < >"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST032
	NEW HDR S HDR="[TEST032][Implicit Iterators - Ampersand]"
	NEW DESC S DESC=HDR_"[Ampersand should interpolate without HTML escaping.]"
	NEW TEMPLATE S TEMPLATE="These characters should not be HTML escaped: {{&.}}\n"
	NEW EXPECTED S EXPECTED="These characters should not be HTML escaped: & "" < >\n"
	NEW CTX 
	SET CTX="& "" < >"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST033
	NEW HDR S HDR="[TEST033][Implicit Iterators - Basic Integer Interpolation]"
	NEW DESC S DESC=HDR_"[Integers should interpolate seamlessly.]"
	NEW TEMPLATE S TEMPLATE="""{{.}} miles an hour!"""
	NEW EXPECTED S EXPECTED="""85 miles an hour!"""
	NEW CTX 
	SET CTX=85
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST034
	NEW HDR S HDR="[TEST034][Interpolation - Surrounding Whitespace]"
	NEW DESC S DESC=HDR_"[Interpolation should not alter surrounding whitespace.]"
	NEW TEMPLATE S TEMPLATE="| {{string}} |"
	NEW EXPECTED S EXPECTED="| --- |"
	NEW CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST035
	NEW HDR S HDR="[TEST035][Triple Mustache - Surrounding Whitespace]"
	NEW DESC S DESC=HDR_"[Interpolation should not alter surrounding whitespace.]"
	NEW TEMPLATE S TEMPLATE="| {{{string}}} |"
	NEW EXPECTED S EXPECTED="| --- |"
	NEW CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST036
	NEW HDR S HDR="[TEST036][Ampersand - Surrounding Whitespace]"
	NEW DESC S DESC=HDR_"[Interpolation should not alter surrounding whitespace.]"
	NEW TEMPLATE S TEMPLATE="| {{&string}} |"
	NEW EXPECTED S EXPECTED="| --- |"
	NEW CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST037
	NEW HDR S HDR="[TEST037][Interpolation - Standalone]"
	NEW DESC S DESC=HDR_"[Standalone interpolation should not alter surrounding whitespace.]"
	NEW TEMPLATE S TEMPLATE="  {{string}}\n"
	NEW EXPECTED S EXPECTED="  ---\n"
	NEW CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST038
	NEW HDR S HDR="[TEST038][Triple Mustache - Standalone]"
	NEW DESC S DESC=HDR_"[Standalone interpolation should not alter surrounding whitespace.]"
	NEW TEMPLATE S TEMPLATE="  {{{string}}}\n"
	NEW EXPECTED S EXPECTED="  ---\n"
	NEW CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST039
	NEW HDR S HDR="[TEST039][Ampersand - Standalone]"
	NEW DESC S DESC=HDR_"[Standalone interpolation should not alter surrounding whitespace.]"
	NEW TEMPLATE S TEMPLATE="  {{&string}}\n"
	NEW EXPECTED S EXPECTED="  ---\n"
	NEW CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST040
	NEW HDR S HDR="[TEST040][Interpolation With Paddin]"
	NEW DESC S DESC=HDR_"[Superfluous in-tag whitespace should be ignored.]"
	NEW TEMPLATE S TEMPLATE="|{{ string }}|"
	NEW EXPECTED S EXPECTED="|---|"
	NEW CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST041
	NEW HDR S HDR="[TEST041][Triple Mustache With Padding]"
	NEW DESC S DESC=HDR_"[Superfluous in-tag whitespace should be ignored.]"
	NEW TEMPLATE S TEMPLATE="|{{{ string }}}|"
	NEW EXPECTED S EXPECTED="|---|"
	NEW CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST042
	NEW HDR S HDR="[TEST042][Ampersand With Padding]"
	NEW DESC S DESC=HDR_"[Superfluous in-tag whitespace should be ignored.]"
	NEW TEMPLATE S TEMPLATE="|{{& string }}|"
	NEW EXPECTED S EXPECTED="|---|"
	NEW CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST043 ;
	NEW HDR S HDR="[TEST043][Truthy]"
	NEW DESC S DESC=HDR_"[Truthy sections should have their contents rendered.]"
	NEW TEMPLATE S TEMPLATE="""{{#boolean}}This should be rendered.{{/boolean}}"""
	NEW EXPECTED S EXPECTED="""This should be rendered."""
	NEW CTX
	S CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST044
	NEW HDR S HDR="[TEST044][Falsey]"
	NEW DESC S DESC=HDR_"[Falsey sections should have their contents omitted.]"
	NEW TEMPLATE S TEMPLATE="""{{#boolean}}This should not be rendered.{{/boolean}}"""
	NEW EXPECTED S EXPECTED=""""""
	NEW CTX 
	S CTX("boolean")="false"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST045
	NEW HDR S HDR="[TEST045][Null is false]"
	NEW DESC S DESC=HDR_"[Null is falsey.]"
	NEW TEMPLATE S TEMPLATE="""{{#null}}This should not be rendered.{{/null}}"""
	NEW EXPECTED S EXPECTED=""""""
	NEW CTX 
	S CTX("null")=""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST046 
	NEW HDR S HDR="[TEST046][Context]"
	NEW DESC S DESC=HDR_"[Objects and hashes should be pushed onto the context stack.]"
	NEW TEMPLATE S TEMPLATE="""{{#context}}Hi {{name}}.{{/context}}"""
	NEW EXPECTED S EXPECTED="""Hi Joe."""
	NEW CTX 
	S CTX("context","name")="Joe"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST047
	NEW HDR S HDR="[TEST047][Parent context]"
	NEW DESC S DESC=HDR_"[Names missing in the current context are looked up in the stack.]"
	NEW TEMPLATE S TEMPLATE="""{{#sec}}{{a}}, {{b}}, {{c.d}}{{/sec}}"""
	NEW EXPECTED S EXPECTED="""foo, bar, baz"""
	NEW CTX 
	S CTX("a")="foo"
	S CTX("b")="wrong"
	S CTX("sec","b")="bar"
	S CTX("c","d")="baz"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST048
	NEW HDR S HDR="[TEST048][Variable test]"
	NEW DESC S DESC=HDR_"[Non-false sections have their value at the top of context,accessible as {{.}} or" 
	S DESC=DESC_"through the parent context. This gives a simple way to display content conditionally if a variable exists.]"
	NEW TEMPLATE S TEMPLATE="""{{#foo}}{{.}} is {{foo}}{{/foo}}"""
	NEW EXPECTED S EXPECTED="""bar is bar"""
	NEW CTX 
	SET CTX("foo")="bar"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST049
	NEW HDR S HDR="[TEST049][List Contexts]"
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
	NEW HDR S HDR="[TEST050][Deeply Nested Contexts] "
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
TEST051
	NEW HDR S HDR="[TEST051][List]"
	NEW DESC S DESC=HDR_"[Lists should be iterated; list items should visit the context stack.]"
	NEW TEMPLATE S TEMPLATE="""{{#list}}{{item}}{{/list}}"""
	NEW EXPECTED S EXPECTED="""123"""
	NEW CTX 
	SET CTX("list",1,"item")=1
	SET CTX("list",2,"item")=2
	SET CTX("list",3,"item")=3
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST052
	NEW HDR S HDR="[TEST052][Empty List]"
	NEW DESC S DESC=HDR_"[Empty lists should behave like falsey values.]"
	NEW TEMPLATE S TEMPLATE="""{{#list}}Yay lists!{{/list}}"""
	NEW EXPECTED S EXPECTED=""""""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST053
	NEW HDR S HDR="[TEST053][Doubled]"
	NEW DESC S DESC=HDR_"[Multiple sections per template should be permitted.]"
	NEW TEMPLATE S TEMPLATE="{{#bool}}\n* first\n{{/bool}}\n* {{two}}\n{{#bool}}\n* third\n{{/bool}}\n"
	NEW EXPECTED S EXPECTED="* first\n* second\n* third\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	NEW CTX 
	SET CTX("bool")="true"
	SET CTX("two")="second"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST054
	NEW HDR S HDR="[TEST054][Nested (Truthy)]"
	NEW DESC S DESC=HDR_"[Nested truthy sections should have their contents rendered.]"
	NEW TEMPLATE S TEMPLATE="| A {{#bool}}B {{#bool}}C{{/bool}} D{{/bool}} E |"
	NEW EXPECTED S EXPECTED="| A B C D E |"
	NEW CTX 
	SET CTX("bool")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST055
	NEW HDR S HDR="[TEST055][Nested (Falsey)]"
	NEW DESC S DESC=HDR_"[Nested falsey sections should be omitted.]"
	NEW TEMPLATE S TEMPLATE="| A {{#bool}}B {{#bool}}C{{/bool}} D{{/bool}} E |"
	NEW EXPECTED S EXPECTED="| A  E |"
	NEW CTX 
	SET CTX("bool")="false"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST056
	NEW HDR S HDR="[TEST056][Context Misses]"
	NEW DESC S DESC=HDR_"[Failed context lookups should be considered falsey.]"
	NEW TEMPLATE S TEMPLATE="[{{#missing}}Found key 'missing'!{{/missing}}]"
	NEW EXPECTED S EXPECTED="[]"
	NEW CTX 
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST057
	NEW HDR S HDR="[TEST057][Implicit Iterator - String]"
	NEW DESC S DESC=HDR_"[Implicit iterators should directly interpolate strings.]"
	NEW TEMPLATE S TEMPLATE="""{{#list}}({{.}}){{/list}}"""
	NEW EXPECTED S EXPECTED="""(a)(b)(c)(d)(e)"""
	NEW CTX 
	SET CTX("list",1)="a"
	SET CTX("list",2)="b"
	SET CTX("list",3)="c"
	SET CTX("list",4)="d"
	SET CTX("list",5)="e"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST058
	NEW HDR S HDR="[TEST058][Implicit Iterator - Integer]"
	NEW DESC S DESC=HDR_"[Implicit iterators should cast integers to strings and interpolate.]"
	NEW TEMPLATE S TEMPLATE="""{{#list}}({{.}}){{/list}}"""
	NEW EXPECTED S EXPECTED="""(1)(2)(3)(4)(5)"""
	NEW CTX 
	SET CTX("list",1)=1
	SET CTX("list",2)=2
	SET CTX("list",3)=3
	SET CTX("list",4)=4
	SET CTX("list",5)=5
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST059
	NEW HDR S HDR="[TEST059][Implicit Iterator - Decimal]"
	NEW DESC S DESC=HDR_"[Implicit iterators should cast decimals to strings and interpolate.]"
	NEW TEMPLATE S TEMPLATE="""{{#list}}({{.}}){{/list}}"""
	NEW EXPECTED S EXPECTED="""(1.1)(2.2)(3.3)(4.4)(5.5)"""
	NEW CTX 
	SET CTX("list",1)=1.1
	SET CTX("list",2)=2.2
	SET CTX("list",3)=3.3
	SET CTX("list",4)=4.4
	SET CTX("list",5)=5.5
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST060
	NEW HDR S HDR="[TEST060][Implicit Iterator - Array]"
	NEW DESC S DESC=HDR_"[Implicit iterators should allow iterating over nested arrays.]"
	NEW TEMPLATE S TEMPLATE="""{{#list}}({{#.}}{{.}}{{/.}}){{/list}}"""
	NEW EXPECTED S EXPECTED="""(123)(abc)"""
	NEW CTX 
	SET CTX("list",1,1)=1
	SET CTX("list",1,2)=2
	SET CTX("list",1,3)=3
	SET CTX("list",2,1)="a"
	SET CTX("list",2,2)="b"
	SET CTX("list",2,3)="c"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST061
	NEW HDR S HDR="[TEST061][Implicit Iterator - HTML Escaping]"
	NEW DESC S DESC=HDR_"[Implicit iterators with basic interpolation should be HTML escaped.]"
	NEW TEMPLATE S TEMPLATE="""{{#list}}({{.}}){{/list}}"""
	NEW EXPECTED S EXPECTED="""(&amp;)(&quot;)(&lt;)(&gt;)"""
	NEW CTX 
	SET CTX("list",1)="&"
	SET CTX("list",2)=""""
	SET CTX("list",3)="<"
	SET CTX("list",4)=">"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST062
	NEW HDR S HDR="[TEST062][Implicit Iterator - Triple mustache]"
	NEW DESC S DESC=HDR_"[Implicit iterators in triple mustache should interpolate without HTML escaping.]"
	NEW TEMPLATE S TEMPLATE="""{{#list}}({{{.}}}){{/list}}"""
	NEW EXPECTED S EXPECTED="""(&)("")(<)(>)"""
	NEW CTX 
	SET CTX("list",1)="&"
	SET CTX("list",2)=""""
	SET CTX("list",3)="<"
	SET CTX("list",4)=">"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST063
	NEW HDR S HDR="[TEST063][Implicit Iterator - Ampersand]"
	NEW DESC S DESC=HDR_"[Implicit iterators in an Ampersand tag should interpolate without HTML escaping.]"
	NEW TEMPLATE S TEMPLATE="""{{#list}}({{&.}}){{/list}}"""
	NEW EXPECTED S EXPECTED="""(&)("")(<)(>)"""
	NEW CTX 
	SET CTX("list",1)="&"
	SET CTX("list",2)=""""
	SET CTX("list",3)="<"
	SET CTX("list",4)=">"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST064
	NEW HDR S HDR="[TEST064][Implicit Iterator - Root-level]"
	NEW DESC S DESC=HDR_"[Implicit iterators should work on root-level lists.]"
	NEW TEMPLATE S TEMPLATE="""{{#.}}({{value}}){{/.}}"""
	NEW EXPECTED S EXPECTED="""(a)(b)"""
	NEW CTX 
	SET CTX(1,"value")="a"
	SET CTX(2,"value")="b"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST065
	NEW HDR S HDR="[TEST065][Dotted Names - Truthy]"
	NEW DESC S DESC=HDR_"[Dotted names should be valid for Section tags.]"
	NEW TEMPLATE S TEMPLATE="""{{#a.b.c}}Here{{/a.b.c}}"" == ""Here"""
	NEW EXPECTED S EXPECTED="""Here"" == ""Here"""
	NEW CTX 
	SET CTX("a","b","c")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST066
	NEW HDR S HDR="[TEST066][Dotted Names - Falsey]"
	NEW DESC S DESC=HDR_"[Dotted names should be valid for Section tags.]"
	NEW TEMPLATE S TEMPLATE="""{{#a.b.c}}Here{{/a.b.c}}"" == """""
	NEW EXPECTED S EXPECTED=""""" == """""
	NEW CTX 
	SET CTX("a","b","c")="false"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST067
	NEW HDR S HDR="[TEST067][Dotted Names - Broken Chains]"
	NEW DESC S DESC=HDR_"[Dotted names that cannot be resolved should be considered falsey.]"
	NEW TEMPLATE S TEMPLATE="""{{#a.b.c}}Here{{/a.b.c}}"" == """""
	NEW EXPECTED S EXPECTED=""""" == """""
	NEW CTX 
	SET CTX("a")=""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST068
	NEW HDR S HDR="[TEST068][Surrounding Whitespace]"
	NEW DESC S DESC=HDR_"[Sections should not alter surrounding whitespace.]"
	NEW TEMPLATE S TEMPLATE=" | {{#boolean}}\t|\t{{/boolean}} | \n"
	NEW EXPECTED S EXPECTED=" | \t|\t | \n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	NEW CTX 
	SET CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST069
	NEW HDR S HDR="[TEST069][Internal Whitespace]"
	NEW DESC S DESC=HDR_"[Sections should not alter surrounding whitespace.]"
	NEW TEMPLATE S TEMPLATE=" | {{#boolean}} {{! Important Whitespace }}\n {{/boolean}} | \n"
	NEW EXPECTED S EXPECTED=" |  \n  | \n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	NEW CTX 
	SET CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST070
	NEW HDR S HDR="[TEST070][Indented Inline Sections]"
	NEW DESC S DESC=HDR_"[Single-line sections should not alter surrounding whitespace.]"
	NEW TEMPLATE S TEMPLATE=" {{#boolean}}YES{{/boolean}}\n {{#boolean}}GOOD{{/boolean}}\n"
	NEW EXPECTED S EXPECTED=" YES\n GOOD\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	NEW CTX 
	SET CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST071
	NEW HDR S HDR="[TEST071][Standalone Lines]"
	NEW DESC S DESC=HDR_"[Standalone lines should be removed from the template.]"
	NEW TEMPLATE S TEMPLATE="| This Is\n{{#boolean}}\n|\n{{/boolean}}\n| A Line\n"
	NEW EXPECTED S EXPECTED="| This Is\n|\n| A Line\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	NEW CTX 
	SET CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST072
	NEW HDR S HDR="[TEST072][Indented Standalone Lines]"
	NEW DESC S DESC=HDR_"[Indented standalone lines should be removed from the template.]"
	NEW TEMPLATE S TEMPLATE="| This Is\n  {{#boolean}}\n|\n  {{/boolean}}\n| A Line\n"
	NEW EXPECTED S EXPECTED="| This Is\n|\n| A Line\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	NEW CTX 
	SET CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST073
	NEW HDR S HDR="[TEST073][Standalone Line Endings]"
	NEW DESC S DESC=HDR_$$UNESCNL("[""\\r\\n"" should be considered a newline for standalone tags.]")
	NEW TEMPLATE S TEMPLATE="|\r\n{{#boolean}}\r\n{{/boolean}}\r\n|"
	NEW EXPECTED S EXPECTED="|\r\n|"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	NEW CTX 
	SET CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST074
	NEW HDR S HDR="[TEST074][Standalone Without Previous Line]"
	NEW DESC S DESC=HDR_"[Standalone tags should not require a newline to precede them.]"
	NEW TEMPLATE S TEMPLATE="  {{#boolean}}\n#{{/boolean}}\n/"
	NEW EXPECTED S EXPECTED="#\n/"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	NEW CTX 
	SET CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST075
	NEW HDR S HDR="[TEST075][Standalone Without Newline]"
	NEW DESC S DESC=HDR_"[Standalone tags should not require a newline to follow them.]"
	NEW TEMPLATE S TEMPLATE="#{{#boolean}}\n/\n  {{/boolean}}"
	NEW EXPECTED S EXPECTED="#\n/\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	NEW CTX 
	SET CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST076
	NEW HDR S HDR="[TEST076][Padding]"
	NEW DESC S DESC=HDR_"[Superfluous in-tag whitespace should be ignored.]"
	NEW TEMPLATE S TEMPLATE="|{{# boolean }}={{/ boolean }}|"
	NEW EXPECTED S EXPECTED="|=|"
	NEW CTX 
	SET CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST077
	NEW HDR S HDR="[TEST077][Falsey]"
	NEW DESC S DESC=HDR_"[Falsey sections should have their contents rendered.]"
	NEW TEMPLATE S TEMPLATE="""{{^boolean}}This should be rendered.{{/boolean}}"""
	NEW EXPECTED S EXPECTED="""This should be rendered."""
	NEW CTX 
	SET CTX("boolean")="false"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST078
	NEW HDR S HDR="[TEST078][Truthy]"
	NEW DESC S DESC=HDR_"[Truthy sections should have their contents omitted.]"
	NEW TEMPLATE S TEMPLATE="""{{^boolean}}This should be rendered.{{/boolean}}"""
	NEW EXPECTED S EXPECTED=""""""
	NEW CTX 
	SET CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST079
	NEW HDR S HDR="[TEST079][Null is falsey]"
	NEW DESC S DESC=HDR_"[Null is falsey.]"
	NEW TEMPLATE S TEMPLATE="""{{^null}}This should be rendered.{{/null}}"""
	NEW EXPECTED S EXPECTED="""This should be rendered."""
	NEW CTX 
	SET CTX("null")="null"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST080
	NEW HDR S HDR="[TEST080][Context]"
	NEW DESC S DESC=HDR_"[Objects and hashes should behave like truthy values.]"
	NEW TEMPLATE S TEMPLATE="""{{^context}}Hi {{name}}.{{/context}}"""
	NEW EXPECTED S EXPECTED=""""""
	NEW CTX 
	SET CTX("context","name")="Joe"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST081
	NEW HDR S HDR="[TEST080][List]"
	NEW DESC S DESC=HDR_"[Lists should behave like truthy values.]"
	NEW TEMPLATE S TEMPLATE="""{{^list}}{{n}}{{/list}}"""
	NEW EXPECTED S EXPECTED=""""""
	NEW CTX 
	SET CTX("list",1,"n")=1
	SET CTX("list",2,"n")=2
	SET CTX("list",3,"n")=3
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST082
	NEW HDR S HDR="[TEST082][Empty List]"
	NEW DESC S DESC=HDR_"[Empty lists should behave like falsey values.]"
	NEW TEMPLATE S TEMPLATE="""{{^list}}Yay lists!{{/list}}"""
	NEW EXPECTED S EXPECTED="""Yay lists!"""
	NEW CTX 
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST083
	NEW HDR S HDR="[TEST083][Doubled]"
	NEW DESC S DESC=HDR_"[Multiple inverted sections per template should be permitted.]"
	NEW TEMPLATE S TEMPLATE="{{^bool}}\n* first\n{{/bool}}\n* {{two}}\n{{^bool}}\n* third\n{{/bool}}\n"
	NEW EXPECTED S EXPECTED="* first\n* second\n* third\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	NEW CTX 
	SET CTX("bool")="false"
	SET CTX("two")="second"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST084
	NEW HDR S HDR="[TEST084][Nested (Falsey)]"
	NEW DESC S DESC=HDR_"[Nested falsey sections should have their contents rendered.]"
	NEW TEMPLATE S TEMPLATE="| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |"
	NEW EXPECTED S EXPECTED="| A B C D E |"
	NEW CTX 
	SET CTX("bool")="false"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST085
	NEW HDR S HDR="[TEST085][Nested (Truthy)]"
	NEW DESC S DESC=HDR_"[Nested truthy sections should be omitted.]"
	NEW TEMPLATE S TEMPLATE="| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |"
	NEW EXPECTED S EXPECTED="| A  E |"
	NEW CTX 
	SET CTX("bool")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST086
	NEW HDR S HDR="[TEST086][Context Misses]"
	NEW DESC S DESC=HDR_"[Failed context lookups should be considered falsey.]"
	NEW TEMPLATE S TEMPLATE="[{{^missing}}Cannot find key 'missing'!{{/missing}}]"
	NEW EXPECTED S EXPECTED="[Cannot find key 'missing'!]"
	NEW CTX 
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST087
	NEW HDR S HDR="[TEST087][Dotted Names - Truthy]"
	NEW DESC S DESC=HDR_"[Dotted names should be valid for Inverted Section tags.]"
	NEW TEMPLATE S TEMPLATE="""{{^a.b.c}}Not Here{{/a.b.c}}"" == """""
	NEW EXPECTED S EXPECTED=""""" == """""
	NEW CTX
	SET CTX("a","b","c")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST088
	NEW HDR S HDR="[TEST088][Dotted Names - Falsey]"
	NEW DESC S DESC=HDR_"[Dotted names should be valid for Inverted Section tags.]"
	NEW TEMPLATE S TEMPLATE="""{{^a.b.c}}Not Here{{/a.b.c}}"" == ""Not Here"""
	NEW EXPECTED S EXPECTED="""Not Here"" == ""Not Here"""
	NEW CTX
	SET CTX("a","b","c")="false"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST089
	NEW HDR S HDR="[TEST089][Dotted Names - Broken Chains]"
	NEW DESC S DESC=HDR_"[Dotted names that cannot be resolved should be considered falsey.]"
	NEW TEMPLATE S TEMPLATE="""{{^a.b.c}}Not Here{{/a.b.c}}"" == ""Not Here"""
	NEW EXPECTED S EXPECTED="""Not Here"" == ""Not Here"""
	NEW CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST090
	NEW HDR S HDR="[TEST090][Surrounding Whitespace]"
	NEW DESC S DESC=HDR_"[Inverted sections should not alter surrounding whitespace.]"
	NEW TEMPLATE S TEMPLATE=" | {{^boolean}}\t|\t{{/boolean}} | \n"
	NEW EXPECTED S EXPECTED=" | \t|\t | \n"
	NEW CTX
	SET CTX("booleanl")="false"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST091
	NEW HDR S HDR="[TEST091][Internal Whitespace]"
	NEW DESC S DESC=HDR_"[Inverted should not alter internal whitespace.]"
	NEW TEMPLATE S TEMPLATE=" | {{^boolean}} {{! Important Whitespace }}\n {{/boolean}} | \n"
	NEW EXPECTED S EXPECTED=" |  \n  | \n"
	NEW CTX
	SET CTX("booleanl")="false"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST092
	NEW HDR S HDR="[TEST092][Indented Inline Sections]"
	NEW DESC S DESC=HDR_"[Single-line sections should not alter surrounding whitespace.]"
	NEW TEMPLATE S TEMPLATE=" {{^boolean}}NO{{/boolean}}\n {{^boolean}}WAY{{/boolean}}\n"
	NEW EXPECTED S EXPECTED=" NO\n WAY\n"
	NEW CTX
	SET CTX("booleanl")="false"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST093
	NEW HDR S HDR="[TEST093][Standalone Lines]"
	NEW DESC S DESC=HDR_"[Standalone lines should be removed from the template.]"
	NEW TEMPLATE S TEMPLATE="| This Is\n{{^boolean}}\n|\n{{/boolean}}\n| A Line\n"
	NEW EXPECTED S EXPECTED="| This Is\n|\n| A Line\n"
	NEW CTX
	SET CTX("booleanl")="false"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST094
	NEW HDR S HDR="[TEST094][Standalone Indented Lines]"
	NEW DESC S DESC=HDR_"[Standalone indented lines should be removed from the template.]"
	NEW TEMPLATE S TEMPLATE="| This Is\n  {{^boolean}}\n|\n  {{/boolean}}\n| A Line\n"
	NEW EXPECTED S EXPECTED="| This Is\n|\n| A Line\n"
	NEW CTX
	SET CTX("booleanl")="false"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST095
	NEW HDR S HDR="[TEST095][Standalone Line Endings]"
	NEW DESC S DESC=HDR_"[""\""\\r\\n\"" should be considered a newline for standalone tags.""]"
	NEW TEMPLATE S TEMPLATE="|\r\n{{^boolean}}\r\n{{/boolean}}\r\n|"
	NEW EXPECTED S EXPECTED="|\r\n|"
	NEW CTX
	SET CTX("booleanl")="false"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST096
	NEW HDR S HDR="[TEST096][Standalone Without Previous Line]"
	NEW DESC S DESC=HDR_"[Standalone tags should not require a newline to precede them.]"
	NEW TEMPLATE S TEMPLATE="{{^boolean}}\n^{{/boolean}}\n/"
	NEW EXPECTED S EXPECTED="^\n/"
	NEW CTX
	SET CTX("booleanl")="false"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST097
	NEW HDR S HDR="[TEST097][Standalone Without Newline]"
	NEW DESC S DESC=HDR_"[Standalone tags should not require a newline to follow them.]"
	NEW TEMPLATE S TEMPLATE="^{{^boolean}}\n/\n  {{/boolean}}"
	NEW EXPECTED S EXPECTED="^\n/\n"
	NEW CTX
	SET CTX("booleanl")="false"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST098
	NEW HDR S HDR="[TEST098][Padding]"
	NEW DESC S DESC=HDR_"[Superfluous in-tag whitespace should be ignored.]"
	NEW TEMPLATE S TEMPLATE="|{{^ boolean }}={{/ boolean }}|"
	NEW EXPECTED S EXPECTED="|=|"
	NEW CTX
	SET CTX("booleanl")="false"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST099
	NEW HDR S HDR="[TEST099][Basic Behavior]"
	NEW DESC S DESC=HDR_"[The greater-than operator should expand to the named partial.]"
	NEW TEMPLATE S TEMPLATE="""{{>text}}"""
	NEW EXPECTED S EXPECTED="""from partial"""
	N CONF,ROOT D SETUPPART(.CONF,.ROOT) 
	K ERR  D WRFILE(ROOT_"text","from partial",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR	
	S CONF("templates","root")=ROOT
	S CONF("templates","ext")=""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	QUIT
TEST100
	NEW HDR S HDR="[TEST100][Failed Lookup]"
	NEW DESC S DESC=HDR_"[The empty string should be used when the named partial is not found.]"
	NEW TEMPLATE S TEMPLATE="""{{>text}}"""
	NEW EXPECTED S EXPECTED=""""""
	N CONF
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST101
	NEW HDR S HDR="[TEST101][Context]"
	NEW DESC S DESC=HDR_"[The greater-than operator should operate within the current context.]"
	NEW TEMPLATE S TEMPLATE="""{{>partial}}"""
	NEW EXPECTED S EXPECTED="""*content*"""
	N CONF,ROOT,CTX D SETUPPART(.CONF,.ROOT)
	N ERR 
	D WRFILE(ROOT_"partial","*{{text}}*",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	SET CTX("text")="content"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	QUIT
TEST102
	NEW HDR S HDR="[TEST102][Recursion]"
	NEW DESC S DESC=HDR_"[The greater-than operator should properly recurse.]"
	NEW TEMPLATE S TEMPLATE="{{>node}}"
	NEW EXPECTED S EXPECTED="X<Y<>>"
	N CONF,ROOT,CTX D SETUPPART(.CONF,.ROOT)
	N ERR 
	D WRFILE(ROOT_"node","{{content}}<{{#nodes}}{{>node}}{{/nodes}}>",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	SET CTX("content")="X"
	SET CTX("nodes",1,"content")="Y"
	SET CTX("nodes",1,"nodes")=""   ; to match and pass the test
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	QUIT
TEST103
	NEW HDR S HDR="[TEST103][Nested]"
	NEW DESC S DESC=HDR_"[The greater-than operator should work from within partials.]"
	NEW TEMPLATE S TEMPLATE="{{>outer}}"
	NEW EXPECTED S EXPECTED="*hello world!*"
	N CONF,ROOT,CTX D SETUPPART(.CONF,.ROOT)
	N ERR 
	D WRFILE(ROOT_"outer","*{{a}} {{>inner}}*",.ERR)
	D WRFILE(ROOT_"inner","{{b}}!",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	SET CTX("a")="hello"
	SET CTX("b")="world"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	QUIT
TEST104
	NEW HDR S HDR="[TEST104][Surrounding Whitespace]"
	NEW DESC S DESC=HDR_"[The greater-than operator should not alter surrounding whitespace.]"
	NEW TEMPLATE S TEMPLATE="| {{>partial}} |"
	NEW EXPECTED S EXPECTED="| \t|\t |"
	N CONF,ROOT,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial","\t|\t",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	QUIT
TEST105
	NEW HDR S HDR="[TEST105][Inline Indentation]"
	NEW DESC S DESC=HDR_"[Whitespace should be left untouched.]"
	NEW TEMPLATE S TEMPLATE="  {{data}}  {{> partial}}\n"
	NEW EXPECTED S EXPECTED="  |  >\n>\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial",$$UNESCNL(">\n>"),.ERR) ;
	SET CTX("data")="|"
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	QUIT
TEST106
	NEW HDR S HDR="[TEST106][Standalone Line Endings]"
	NEW DESC S DESC=HDR_"[""\r\\n"" should be considered a newline for standalone tags.]"
	NEW TEMPLATE S TEMPLATE="|\r\n{{>partial}}\r\n|"
	NEW EXPECTED S EXPECTED="|\r\n>|"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial",$$UNESCNL(">"),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	QUIT
TEST107
	NEW HDR S HDR="[TEST107][Standalone Without Previous Line]"
	NEW DESC S DESC=HDR_"[Standalone tags should not require a newline to precede them.]"
	NEW TEMPLATE S TEMPLATE="  {{>partial}}\n>"
	NEW EXPECTED S EXPECTED="  >\n  >>"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial",$$UNESCNL(">\n>"),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	QUIT
TEST108
	NEW HDR S HDR="[TEST108][Standalone Without Newline]"
	NEW DESC S DESC=HDR_"[Standalone tags should not require a newline to follow them.]"
	NEW TEMPLATE S TEMPLATE=">\n  {{>partial}}"
	NEW EXPECTED S EXPECTED=">\n  >\n  >"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial",$$UNESCNL(">\n>"),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	QUIT
TEST109
	NEW HDR S HDR="[TEST109][Standalone Indentation]"
	NEW DESC S DESC=HDR_"[Each line of the partial should be indented before rendering.]"
	NEW TEMPLATE S TEMPLATE="\\\n {{>partial}}\n/\n"
	NEW EXPECTED S EXPECTED="\\\n |\n <\n->\n |\n/\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial",$$UNESCNL("|\n{{{content}}}\n|\n"),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	N CTX
	S CTX("content")=$$UNESCNL("<\n->")
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	QUIT
TEST110
	NEW HDR S HDR="[TEST110][Padding Whitespace]"
	NEW DESC S DESC=HDR_"[Superfluous in-tag whitespace should be ignored.]"
	NEW TEMPLATE S TEMPLATE="|{{> partial }}|"
	NEW EXPECTED S EXPECTED="|[]|"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial",$$UNESCNL("[]"),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	N CTX
	S CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	D RMDIR(ROOT)
	QUIT
TEST111
	NEW HDR S HDR="[TEST111][Inline]"
	NEW DESC S DESC=HDR_"[Comment blocks should be removed from the template.]"
	NEW TEMPLATE S TEMPLATE="12345{{! Comment Block! }}67890"
	NEW EXPECTED S EXPECTED="1234567890"
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST112
	NEW HDR S HDR="[TEST112][Multiline]"
	NEW DESC S DESC=HDR_"[Multiline comments should be permitted..]"
	NEW TEMPLATE S TEMPLATE="12345{{!\n  This is a\n  multi-line comment...\n}}67890\n"
	NEW EXPECTED S EXPECTED="1234567890\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST113
	NEW HDR S HDR="[TEST113][Standalone]"
	NEW DESC S DESC=HDR_"[All standalone comment lines should be removed.]"
	NEW TEMPLATE S TEMPLATE="Begin.\n{{! Comment Block! }}\nEnd.\n"
	NEW EXPECTED S EXPECTED="Begin.\nEnd.\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST114
	NEW HDR S HDR="[TEST114][Indented Standalone]"
	NEW DESC S DESC=HDR_"[All standalone comment lines should be removed.]"
	NEW TEMPLATE S TEMPLATE="Begin.\n  {{! Indented Comment Block! }}\nEnd.\n"
	NEW EXPECTED S EXPECTED="Begin.\nEnd.\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST115
	NEW HDR S HDR="[TEST115][Standalone Line Endings]"
	NEW DESC S DESC=HDR_"""\\r\\n"" should be considered a newline for standalone tags."
	NEW TEMPLATE S TEMPLATE="|\r\n{{! Standalone Comment }}\r\n|"
	NEW EXPECTED S EXPECTED="|\r\n|"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST116
	NEW HDR S HDR="[TEST116][Standalone Without Previous Line]"
	NEW DESC S DESC=HDR_"[Standalone tags should not require a newline to precede them.]"
	NEW TEMPLATE S TEMPLATE="  {{! I'm Still Standalone }}\n!"
	NEW EXPECTED S EXPECTED="!"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST117
	NEW HDR S HDR="[TEST117][Standalone Without Newline]"
	NEW DESC S DESC=HDR_"[Standalone tags should not require a newline to follow them.]"
	NEW TEMPLATE S TEMPLATE="!\n  {{! I'm Still Standalone }}"
	NEW EXPECTED S EXPECTED="!\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST118
	NEW HDR S HDR="[TEST118][Multiline Standalone]"
	NEW DESC S DESC=HDR_"[All standalone comment lines should be removed.]"
	NEW TEMPLATE S TEMPLATE="Begin.\n{{!\nSomething's going on here...\n}}\nEnd.\n"
	NEW EXPECTED S EXPECTED="Begin.\nEnd.\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST119
	NEW HDR S HDR="[TEST119][Indented Multiline Standalone]"
	NEW DESC S DESC=HDR_"[All standalone comment lines should be removed.]"
	NEW TEMPLATE S TEMPLATE="Begin.\n  {{!\n    Something's going on here...\n  }}\nEnd.\n"
	NEW EXPECTED S EXPECTED="Begin.\nEnd.\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST120
	NEW HDR S HDR="[TEST120][Indented Inline]"
	NEW DESC S DESC=HDR_"[Inline comments should not strip whitespace]"
	NEW TEMPLATE S TEMPLATE="  12 {{! 34 }}\n"
	NEW EXPECTED S EXPECTED="  12 \n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST121
	NEW HDR S HDR="[TEST121][Surrounding Whitespace]"
	NEW DESC S DESC=HDR_"[Comment removal should preserve surrounding whitespace.]"
	NEW TEMPLATE S TEMPLATE="12345 {{! Comment Block! }} 67890"
	NEW EXPECTED S EXPECTED="12345  67890"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST122
	NEW HDR S HDR="[TEST122][Variable Name Collision]"
	NEW DESC S DESC=HDR_"[Comments must never render, even if variable with same name exists.]"
	NEW TEMPLATE S TEMPLATE="comments never show: >{{! comment }}<"
	NEW EXPECTED S EXPECTED="comments never show: ><"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	N CTX
	S CTX("! comment")=1
	S CTX("! comment ")=2
	S CTX("!comment")=3
	S CTX("comment")=4
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST123
	NEW HDR S HDR="[TEST123][Pair Behavior]"
	NEW DESC S DESC=HDR_"[The equals sign (used on both sides) should permit delimiter changes.]"
	NEW TEMPLATE S TEMPLATE="{{=<% %>=}}(<%text%>)"
	NEW EXPECTED S EXPECTED="(Hey!)"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	N CTX
	S CTX("text")="Hey!"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST124
	NEW HDR S HDR="[TEST124][Special Characters]"
	NEW DESC S DESC=HDR_"[Characters with special meaning regexen should be valid delimiters.]"
	NEW TEMPLATE S TEMPLATE="({{=[ ]=}}[text])"
	NEW EXPECTED S EXPECTED="(It worked!)"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	N CTX
	S CTX("text")="It worked!"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST125
	NEW HDR S HDR="[TEST125][Sections]"
	NEW DESC S DESC=HDR_"[Delimiters set outside sections should persist.]"
	NEW TEMPLATE S TEMPLATE="[\n{{#section}}\n  {{data}}\n  |data|\n{{/section}}\n\n{{= | | =}}\n|#section|\n  {{data}}\n  |data|\n|/section|\n]\n"
	NEW EXPECTED S EXPECTED="[\n  I got interpolated.\n  |data|\n\n  {{data}}\n  I got interpolated.\n]\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	N CTX
	S CTX("section")="true"
	S CTX("data")="I got interpolated."
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST126
	NEW HDR S HDR="[TEST126][Inverted Sections]"
	NEW DESC S DESC=HDR_"[Delimiters set outside inverted sections should persist.]"
	NEW TEMPLATE S TEMPLATE="[\n{{^section}}\n  {{data}}\n  |data|\n{{/section}}\n\n{{= | | =}}\n|^section|\n  {{data}}\n  |data|\n|/section|\n]\n"
	NEW EXPECTED S EXPECTED="[\n  I got interpolated.\n  |data|\n\n  {{data}}\n  I got interpolated.\n]\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	N CTX
	S CTX("section")="false"
	S CTX("data")="I got interpolated."
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST127
	NEW HDR S HDR="[TEST127][Partial Inheritence]"
	NEW DESC S DESC=HDR_"[Delimiters set in a parent template should not affect a partial.]"
	NEW TEMPLATE S TEMPLATE="[ {{>include}} ]\n{{= | | =}}\n[ |>include| ]\n"
	NEW EXPECTED S EXPECTED="[ .yes. ]\n[ .yes. ]\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"include",$$UNESCNL(".{{value}}."),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	N CTX
	S CTX("value")="yes"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	QUIT
TEST128
	NEW HDR S HDR="[TEST128][Partial Inheritence]"
	NEW DESC S DESC=HDR_"[Delimiters set in a parent template should not affect a partial.]"
	NEW TEMPLATE S TEMPLATE="[ {{>include}} ]\n{{= | | =}}\n[ |>include| ]\n"
	NEW EXPECTED S EXPECTED="[ .yes. ]\n[ .yes. ]\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"include",$$UNESCNL(".{{value}}."),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	N CTX
	S CTX("value")="yes"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	QUIT
TEST129
	NEW HDR S HDR="[TEST129][Post-Partial Behavior]"
	NEW DESC S DESC=HDR_"[Delimiters set in a partial should not affect the parent template.]"
	NEW TEMPLATE S TEMPLATE="[ {{>include}} ]\n[ .{{value}}.  .|value|. ]\n"
	NEW EXPECTED S EXPECTED="[ .yes.  .yes. ]\n[ .yes.  .|value|. ]\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"include",$$UNESCNL(".{{value}}. {{= | | =}} .|value|."),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	N CTX
	S CTX("value")="yes"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	QUIT
TEST130
	NEW HDR S HDR="[TEST130][Surrounding Whitespace]"
	NEW DESC S DESC=HDR_"[Surrounding whitespace should be left untouched.]"
	NEW TEMPLATE S TEMPLATE="| {{=@ @=}} |"
	NEW EXPECTED S EXPECTED="|  |"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST131
	NEW HDR S HDR="[TEST131][Outlying Whitespace (Inline)]"
	NEW DESC S DESC=HDR_"[Whitespace should be left untouched.]"
	NEW TEMPLATE S TEMPLATE=" | {{=@ @=}}\n"
	NEW EXPECTED S EXPECTED=" | \n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST132
	NEW HDR S HDR="[TEST132][Standalone Tag]"
	NEW DESC S DESC=HDR_"[Standalone lines should be removed from the template.]"
	NEW TEMPLATE S TEMPLATE="Begin.\n{{=@ @=}}\nEnd.\n"
	NEW EXPECTED S EXPECTED="Begin.\nEnd.\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST133
	NEW HDR S HDR="[TEST133][Indented Standalone Tag]"
	NEW DESC S DESC=HDR_"[Indented standalone lines should be removed from the template.]"
	NEW TEMPLATE S TEMPLATE="Begin.\n  {{=@ @=}}\nEnd.\n"
	NEW EXPECTED S EXPECTED="Begin.\nEnd.\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST134
	NEW HDR S HDR="[TEST134][Standalone Line Endings]"
	NEW DESC S DESC=HDR_"[""\\r\\n"" should be considered a newline for standalone tags.]"
	NEW TEMPLATE S TEMPLATE="|\r\n{{= @ @ =}}\r\n|"
	NEW EXPECTED S EXPECTED="|\r\n|"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST135
	NEW HDR S HDR="[TEST135][Standalone Without Previous Line]"
	NEW DESC S DESC=HDR_"[Standalone tags should not require a newline to precede them.]"
	NEW TEMPLATE S TEMPLATE="  {{=@ @=}}\n="
	NEW EXPECTED S EXPECTED="="
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST136
	NEW HDR S HDR="[TEST136][Standalone Without Newline]"
	NEW DESC S DESC=HDR_"[Standalone tags should not require a newline to follow them.]"
	NEW TEMPLATE S TEMPLATE="=\n  {{=@ @=}}"
	NEW EXPECTED S EXPECTED="=\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST137
	NEW HDR S HDR="[TEST137][Pair with Padding]"
	NEW DESC S DESC=HDR_"[Superfluous in-tag whitespace should be ignored.]"
	NEW TEMPLATE S TEMPLATE="|{{= @   @ =}}|"
	NEW EXPECTED S EXPECTED="||"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST138
	NEW HDR S HDR="[TEST138][Default]"
	NEW DESC S DESC=HDR_"[Default content should be rendered if the block isn't overridden.]"
	NEW TEMPLATE S TEMPLATE="{{$title}}Default title{{/title}}\n"
	NEW EXPECTED S EXPECTED="Default title\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST139
	NEW HDR S HDR="[TEST139][Variable]"
	NEW DESC S DESC=HDR_"[Default content renders variables]"
	NEW TEMPLATE S TEMPLATE="{{$foo}}default {{bar}} content{{/foo}}\n"
	NEW EXPECTED S EXPECTED="default baz content\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	S CTX("bar")="baz"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST140
	NEW HDR S HDR="[TEST140][Triple Mustache]"
	NEW DESC S DESC=HDR_"[Default content renders triple mustache variables]"
	NEW TEMPLATE S TEMPLATE="{{$foo}}default {{{bar}}} content{{/foo}}\n"
	NEW EXPECTED S EXPECTED="default <baz> content\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	S CTX("bar")="<baz>"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST141
	NEW HDR S HDR="[TEST141][Sections]"
	NEW DESC S DESC=HDR_"[Default content renders sections]"
	NEW TEMPLATE S TEMPLATE="{{$foo}}default {{#bar}}{{baz}}{{/bar}} content{{/foo}}\n"
	NEW EXPECTED S EXPECTED="default qux content\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	S CTX("bar","baz")="qux"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST142
	NEW HDR S HDR="[TEST142][Negative Sections]"
	NEW DESC S DESC=HDR_"[Default content renders negative sections]"
	NEW TEMPLATE S TEMPLATE="{{$foo}}default {{^bar}}{{baz}}{{/bar}} content{{/foo}}\n"
	NEW EXPECTED S EXPECTED="default three content\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	S CTX("baz")="three"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST143
	NEW HDR S HDR="[TEST143][Mustache Injection]"
	NEW DESC S DESC=HDR_"[Mustache injection in default content]"
	NEW TEMPLATE S TEMPLATE="{{$foo}}default {{#bar}}{{baz}}{{/bar}} content{{/foo}}\n"
	NEW EXPECTED S EXPECTED="default {{qux}} content\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	S CTX("bar","baz")="{{qux}}"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
TEST144
	NEW HDR S HDR="[TEST144][Inherit]"
	NEW DESC S DESC=HDR_"[Default content rendered inside inherited templates]"
	NEW TEMPLATE S TEMPLATE="{{<include}}{{/include}}\n"
	NEW EXPECTED S EXPECTED="default content"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"include",$$UNESCNL("{{$foo}}default content{{/foo}}"),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	QUIT
TEST145
	NEW HDR S HDR="[TEST145][Overridden content]"
	NEW DESC S DESC=HDR_"[Overridden content]"
	NEW TEMPLATE S TEMPLATE="{{<super}}{{$title}}sub template title{{/title}}{{/super}}"
	NEW EXPECTED S EXPECTED="...sub template title..."
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"super",$$UNESCNL("...{{$title}}Default title{{/title}}..."),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	QUIT
TEST146
	NEW HDR S HDR="[TEST146][Data does not override block]"
	NEW DESC S DESC=HDR_"[Context does not override argument passed into parent]"
	NEW TEMPLATE S TEMPLATE="{{<include}}{{$var}}var in template{{/var}}{{/include}}"
	NEW EXPECTED S EXPECTED="var in template"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	S CTX("var")="var in data"
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"include",$$UNESCNL("{{$var}}var in include{{/var}}"),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	QUIT
TEST147
	NEW HDR S HDR="[TEST147][Data does not override block default]"
	NEW DESC S DESC=HDR_"[Context does not override default content of block]"
	NEW TEMPLATE S TEMPLATE="{{<include}}{{/include}}"
	NEW EXPECTED S EXPECTED="var in include"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	S CTX("var")="var in data"
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"include",$$UNESCNL("{{$var}}var in include{{/var}}"),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	QUIT
TEST148
	NEW HDR S HDR="[TEST148][Overridden parent]"
	NEW DESC S DESC=HDR_"[Overridden parent]"
	NEW TEMPLATE S TEMPLATE="test {{<parent}}{{$stuff}}override{{/stuff}}{{/parent}}"
	NEW EXPECTED S EXPECTED="test override"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"parent",$$UNESCNL("{{$stuff}}...{{/stuff}}"),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	QUIT
TEST149
	NEW HDR S HDR="[TEST149][Two overridden parents]"
	NEW DESC S DESC=HDR_"[Two overridden parents with different content]"
	NEW TEMPLATE S TEMPLATE="test {{<parent}}{{$stuff}}override1{{/stuff}}{{/parent}} {{<parent}}{{$stuff}}override2{{/stuff}}{{/parent}}\n"
	NEW EXPECTED S EXPECTED="test |override1 default| |override2 default|\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"parent",$$UNESCNL("|{{$stuff}}...{{/stuff}}{{$default}} default{{/default}}|"),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	QUIT
TEST150
	NEW HDR S HDR="[TEST150][Override parent with newlines]"
	NEW DESC S DESC=HDR_"[Override parent with newlines]"
	;NEW TEMPLATE 
	S TEMPLATE="{{<parent}}{{$ballmer}}\npeaked\n\n:(\n{{/ballmer}}{{/parent}}"
	;NEW EXPECTED 
	S EXPECTED="peaked\n\n:(\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"parent",$$UNESCNL("{{$ballmer}}peaking{{/ballmer}}"),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	QUIT
TEST000
	NEW HDR S HDR="[TEST000][]"
	NEW DESC S DESC=HDR_"[]"
	NEW TEMPLATE S TEMPLATE="""{{>text}}"""
	NEW EXPECTED S EXPECTED=""
	N CONF,ROOT D SETUPPART(.CONF,.ROOT)
	N ERR 
	D WRFILE(ROOT_"text","from partial",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	NEW CTX 
	SET CTX("text")="content"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	QUIT
RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,CTX)
	;NEW TOK,ERR,OUT ;,CONF
	;M CONF=^MIO("CONF")
	D COMPILE^MIOTPL2(TEMPLATE,.TOK,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"[COMPILE]"_HDR)
	DO EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"[EVAL]"_DESC)
	DO EQ^MIOTASSERT(OUT,EXPECTED,"[RENDER]"_DESC)
	Q
RUNJSONSPECS(FP)
	N OK,TXT,ERR,TESTS,TXT
	N T,OK S OK=$$READFILE^MIOTPL2(FP,.TXT,.ERR)
	D DECODE^MIOJSON2($NA(TXT),$NA(TESTS))
	N A S A="" F  S A=$O(TESTS("tests",A)) Q:A=""  D
	. NEW HDR S HDR="["_TESTS("tests",A,"name")_"]"
	. NEW DESC S DESC=HDR_"["_TESTS("tests",A,"desc")_"]"
	. NEW TEMPLATE S TEMPLATE=TESTS("tests",A,"template")
	. NEW EXPECTED S EXPECTED=TESTS("tests",A,"expected")
	. NEW CTX M CTX=TESTS("tests",A,"data")
	. D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
RUNJSONSPECSPART(FP)
	N OK,TXT,ERR,TESTS,TXT
	N T,OK S OK=$$READFILE^MIOTPL2(FP,.TXT,.ERR)
	D DECODE^MIOJSON2($NA(TXT),$NA(TESTS))
	N A S A="" F  S A=$O(TESTS("tests",A)) Q:A=""  D
	. NEW HDR S HDR="["_TESTS("tests",A,"name")_"]"
	. NEW DESC S DESC=HDR_"["_TESTS("tests",A,"desc")_"]"
	. NEW TEMPLATE S TEMPLATE=TESTS("tests",A,"template")
	. NEW EXPECTED S EXPECTED=TESTS("tests",A,"expected")
	. NEW CTX M CTX=TESTS("tests",A,"data") 
	. I TESTS("tests",A,"name")="Recursion" D 
	. . SET CTX("nodes",1,"nodes")=""  ; to match and pass the test 
	. . ;(work around the JSON, as it is not able to process empty objects)
	. K CONF,TOK,OUT,ERR
	. I $D(TESTS("tests",A,"partials"))  D
	. . N B S B="" F  S B=$O(TESTS("tests",A,"partials",B)) Q:B=""  D
	. . . D SETUPPART(.CONF,.ROOT)
	. . . N ERR D WRFILE(ROOT_B,TESTS("tests",A,"partials",B),.ERR) ;
	. . . D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	. D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
	;
ReadFile(file,return)
	new source,line,counter,currentdevice
	set source=file,currentdevice=$io
	open source:(readonly:chset="m")
	for  use source read line:2 quit:$zeof  quit:'$test  do
	. if $zextract(line,$zlength(line))=$char(13) set line=$zextract(line,1,$zlength(line)-1)
	. if $zextract(line,$zlength(line))=$char(10) set line=$zextract(line,1,$zlength(line)-1)
	. set return($increment(counter))=line
	close source use currentdevice
	quit	
UNESCNL(S) Q $$UES^MIOJSON2(S) ; Enescape string from json/js -> M
; =============================================================================
; WRFILE(FILE,TEXT,ERR)
; Write TEXT exactly as-is (preserve embedded $C(10)/$C(13)).;
; =============================================================================
WRFILE(FILE,TEXT,ERR)
	K ERR
	N USEIO
	S USEIO=$IO
	O FILE:(newversion:stream:exception="G WRFILEERR")
	U FILE
	W $G(TEXT)
	C FILE
	U USEIO
	Q
WRFILEERR
	S ERR("code")="TPL_IO"
	S ERR("msg")="I/O error writing template: "_FILE
	C FILE
	U USEIO
	Q
SETUPPART(CONF,ROOT)
	M CONF=^MIO("CONF")
	S ROOT="templates/test-MIOTPL-"_$J_"/"
	D MKDIR(ROOT)
	D MKDIR(ROOT_"partials/")
	S CONF("templates","root")=ROOT
	S CONF("templates","ext")=""
	Q
MKDIR(PATH) ; mkdir -p PATH (best-effort)
	NEW CMD
	S CMD="mkdir -p "_$$SHQ(PATH)
	ZSY CMD
	Q
RMDIR(PATH) ; rm -rf PATH (best-effort)
	NEW CMD
	S CMD="rm -rf "_$$SHQ(PATH)
	ZSY CMD
	Q
SHQ(S) ; shell-quote
	; Wrap in single quotes; escape single quotes safely: ' -> '\'' (close, escape, reopen)
	NEW X S X=$G(S)
	I X["'" S X=$$REPLQ(X)
	Q "'"_X_"'"
REPLQ(S) ; replace ' with '\'' for shell single-quote context
	NEW OUT,P,F
	S OUT="",P=1
	F  D  Q:P>$L(S)
	. S F=$F(S,"'",P)
	. I 'F S OUT=OUT_$E(S,P,$L(S)),P=$L(S)+1 Q
	. S OUT=OUT_$E(S,P,F-2)_"'\''"
	. S P=F
	Q OUT