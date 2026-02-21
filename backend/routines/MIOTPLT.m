MIOTPLT
	K ^MIO("TPL","CACHE")
	D MIOTF121,MIOTF122,MIOTF123,MIOTF124,MIOTF125
	D MIOTF126,MIOTF126B,MIOTF127,MIOTF128,MIOTF129
	D MIOTF130,MIOTF131,MIOTF132,MIOTF133
	D TEST265,TEST266,TEST267
	D MIOTF200,MIOTF201,MIOTF202,MIOTF203,MIOTF204
	D MIOTF205,MIOTF206,MIOTF207
	;	
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
	Q
MIOTF204 ;Comments
	; Comment tags represent content that should never appear in the resulting
	; output.The tag's content may contain any substring (including newlines) 
	; EXCEPT the closing delimiter. Comment tags SHOULD be treated as
	D RUNJSONSPECS("./tests/data/comments.json") ;This is the same as below.;
	; Each test is run two different ways
	;  standalone when appropriate.;
	D TEST111,TEST112,TEST113,TEST114,TEST115,TEST116,TEST117
	D TEST118,TEST119,TEST120,TEST121,TEST122
	Q
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
	Q
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
	D RUNJSONSPECSPART("./tests/data/_inheritance.json") ;This is the same as below.;
	; Each test is run two different ways
	D TEST138,TEST139,TEST140,TEST141,TEST142,TEST143,TEST144
	D TEST145,TEST146,TEST147,TEST148,TEST149,TEST150,TEST151
	D TEST152,TEST153,TEST154,TEST155,TEST156,TEST157,TEST158
	D TEST159,TEST160,TEST161,TEST162,TEST163,TEST164
	;	
	Q
MIOTF207 ;Dynamic Names
	 ;  Rationale: this special notation was introduced primarily to allow the dynamic
	;   loading of partials. The main advantage that this notation offers is to allow
	;   dynamic loading of partials, which is particularly useful in cases where
	;   polymorphic data needs to be rendered in different ways. Such cases would
	;   otherwise be possible to render only with solutions that are convoluted,
	;   inefficient, or both.;
	; 
	;   Example.;
	;   Let's consider the following data:
	; 
	;       items: [
	;         { content: 'Hello, World!' },
	;         { url: 'http://example.com/foo.jpg' },
	;         { content: 'Some text' },
	;         { content: 'Some other text' },
	;         { url: 'http://example.com/bar.jpg' },
	;         { url: 'http://example.com/baz.jpg' },
	;         { content: 'Last text here' }
	;       ]
	; 
	;   The goal is to render the different types of items in different ways. The
	;   items having a key named `content` should be rendered with the template
	;   `text.mustache`:
	; 
	;       {{!text.mustache}}
	;       {{content}}
	; 
	;   And the items having a key named `url` should be rendered with the template
	;   `image.mustache`:
	; 
	;       {{!image.mustache}}
	;       <img src="{{url}}"/>
	; 
	;   There are already several ways to achieve this goal, here below are
	;   illustrated and discussed the most significant solutions to this problem.;
	; 
	;   Using Pre-Processing
	; 
	;   The idea is to use a secondary templating mechanism to dynamically generate
	;   the template that will be rendered.;
	;   The template that our secondary templating mechanism generates might look
	;   like this:
	; 
	;       {{!template.mustache}}
	;       {{items.1.content}}
	;       <img src="{{items.2.url}}"/>
	;       {{items.3.content}}
	;       {{items.4.content}}
	;       <img src="{{items.5.url}}"/>
	;       <img src="{{items.6.url}}"/>
	;       {{items.7.content}}
	; 
	;   This solutions offers the advantages of having more control over the template
	;   and minimizing the template blocks to the essential ones.;
	;   The drawbacks are the rendering speed and the complexity that the secondary
	;   templating mechanism requires.;
	; 
	;   Using Lambdas
	; 
	;   The idea is to inject functions into the data that will be later called from
	;   the template.;
	;   This way the data will look like this:
	; 
	;       items: [
	;         {
	;           content: 'Hello, World!',
	;           html: function() { return '{{>text}}'; }
	;         },
	;         {
	;           url: 'http://example.com/foo.jpg',
	;           html: function() { return '{{>image}}'; }
	;         },
	;         {
	;           content: 'Some text',
	;           html: function() { return '{{>text}}'; }
	;         },
	;         {
	;           content: 'Some other text',
	;           html: function() { return '{{>text}}'; }
	;         },
	;         {
	;           url: 'http://example.com/bar.jpg',
	;           html: function() { return '{{>image}}'; }
	;         },
	;         {
	;           url: 'http://example.com/baz.jpg',
	;           html: function() { return '{{>image}}'; }
	;         },
	;         {
	;           content: 'Last text here',
	;           html: function() { return '{{>text}}'; }
	;         }
	;       ]
	; 
	;   And the template will look like this:
	; 
	;       {{!template.mustache}}
	;       {{#items}}
	;       {{{html}}}
	;       {{/items}}
	; 
	;   The advantage this solution offers is to have a light main template.;
	;   The drawback is that the data needs to embed logic and template tags in
	;   it.;
	; 
	;   Using If-Else Blocks
	; 
	;   The idea is to put some logic into the main template so it can select the
	;   templates at rendering time:
	; 
	;       {{!template.mustache}}
	;       {{#items}}
	;       {{#url}}
	;       {{>image}}
	;       {{/url}}
	;       {{#content}}
	;       {{>text}}
	;       {{/content}}
	;       {{/items}}
	; 
	;   The main advantage of this solution is that it works without adding any
	;   overhead fields to the data. It also documents which external templates are
	;   appropriate for expansion in this position.;
	;   The drawback is that this solution isn't optimal for heterogeneous data sets
	;   as the main template grows linearly with the number of polymorphic variants.;
	; 
	;   Using Dynamic Names
	; 
	;   This is the solution proposed by this spec.;
	;   The idea is to load partials dynamically.;
	;   This way the data items have to be tagged with the corresponding partial name:
	; 
	;       items: [
	;         { content: 'Hello, World!',          dynamic: 'text' },
	;         { url: 'http://example.com/foo.jpg', dynamic: 'image' },
	;         { content: 'Some text',              dynamic: 'text' },
	;         { content: 'Some other text',        dynamic: 'text' },
	;         { url: 'http://example.com/bar.jpg', dynamic: 'image' },
	;         { url: 'http://example.com/baz.jpg', dynamic: 'image' },
	;         { content: 'Last text here',         dynamic: 'text' }
	;       ]
	; 
	;   And the template would simple look like this:
	; 
	;       {{!template.mustache}}
	;       {{#items}}
	;       {{>*dynamic}}
	;       {{/items}}
	; 
	;   Summary:
	; 
	;     +----------------+---------------------+-----------------------------------+
	;     |    Approach    |        Pros         |               Cons                |
	;     +----------------+---------------------+-----------------------------------+
	;     | Pre-Processing | Essential template, | Secondary templating system       |
	;     |                | more control        | needed, slower rendering          |
	;     | Lambdas        | Slim template       | Data tagging, logic in data       |
	;     | If Blocks      | No data overhead,   | Template linear growth            |
	;     |                | self-documenting    |                                   |
	;     | Dynamic Names  | Slim template       | Data tagging                      |
	;     +----------------+---------------------+-----------------------------------+
	; 
	;   Dynamic Names are a special notation to dynamically determine a tag's content.;
	; 
	;   Dynamic Names MUST be a non-whitespace character sequence NOT containing
	;   the current closing delimiter. A Dynamic Name consists of an asterisk,
	;   followed by a dotted name. The dotted name follows the same notation as in an
	;   Interpolation tag.;
	; 
	;   This tag's dotted name, which is the Dynamic Name excluding the
	;   leading asterisk, references a key in the context whose value will be used in
	;   place of the Dynamic Name itself as content of the tag. The dotted name
	;   resolution produces the same value as an Interpolation tag and does not affect
	;   the context for further processing.;
	; 
	;   Set Delimiter tags MUST NOT affect the resolution of a Dynamic Name. The
	;   Dynamic Names MUST be resolved against the context stack local to the tag.;
	;   Failed resolution of the dynamic name SHOULD result in nothing being rendered.;
	; 
	;   Engines that implement Dynamic Names MUST support their use in Partial tags.;
	;   In engines that also implement the optional inheritance spec, Dynamic Names
	;   inside Parent tags SHOULD be supported as well. Dynamic Names cannot be
	;   resolved more than once (Dynamic Names cannot be nested).;
	;	
	;D RUNJSONSPECSPART("./tests/data/_inheritance.json") ;This is the same as below.;
	; Each test is run two different ways
	D TEST165,TEST166,TEST167,TEST168,TEST169,TEST170,TEST171
	D TEST172,TEST173,TEST174,TEST175
	;	
	Q 
MIOTF121 ; Full suite test 121 - TPL_SECTION_CTA.;
	N TOK,ERR,CONF,CTX,OUT
	D COMPILE^MIOTPL2("{{#cta}}X{{/cta}}",.TOK,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"compile")
	SET CTX("cta")=1
	DO EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"eval")
	DO EQ^MIOTASSERT(OUT,"X","section render")
	Q
MIOTF122 ; Full suite test 122 - TPL_BLOCK_TITLE.;
	N TOK,ERR,CONF,CTX,OUT
	DO COMPILE^MIOTPL2("{{#block:title}}Hello{{/block:title}}",.TOK,.ERR) I $D(ERR) ZWR ERR
	DO OK^MIOTASSERT('$D(ERR),"compile")  I $D(ERR) ZWR ERR
	DO EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"eval")
	DO EQ^MIOTASSERT(OUT,"Hello","block captured")
	Q
MIOTF123 ; Full suite test 123 - TPL_DOTTED_LIST.;
	N TOK,ERR,CONF,CTX,OUT
	SET CTX("cats","items",1)="Core"
	SET CTX("cats","items",2)="Tools"
	DO COMPILE^MIOTPL2("{{#cats.items}}{{.}};{{/cats.items}}",.TOK,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"compile")
	DO EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"eval")
	DO EQ^MIOTASSERT(OUT,"Core;Tools;","dotted list") 
	Q
MIOTF124 ; Full suite test 124 - TPL_PACKAGES_OBJECT.;
	N TOK,ERR,CONF,CTX,OUT
	SET CTX("packages",1,"slug")="mio-web"
	SET CTX("packages",1,"name")="Web Server"
	DO COMPILE^MIOTPL2("{{#packages}}{{slug}}-{{name}};{{/packages}}",.TOK,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"compile")
	DO EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"eval")
	DO EQ^MIOTASSERT(OUT,"mio-web-Web Server;","packages obj")
	Q
MIOTF125 ; Full suite test 125 - TPL_INVERTED_NORESULTS.;
	N TOK,ERR,CONF,CTX,OUT,RES
	; Template: show "NONE" only when packages is falsey/empty.;
	DO COMPILE^MIOTPL2("{{^packages}}NONE{{/packages}}{{#packages}}YES{{/packages}}",.TOK,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"compile")
	; Case A: packages has an item => inverted must NOT render, normal must render.;
	KILL CTX
	SET CTX("packages",1,"name")="Pkg1"
	DO EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"eval A")
	DO EQ^MIOTASSERT(OUT,"YES","inverted suppressed when list has items") 
	; Case B: packages empty => inverted MUST render, normal must NOT render.;
	KILL OUT,ERR,CTX
	DO EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"eval B")
	DO EQ^MIOTASSERT(OUT,"NONE","inverted renders when list empty")
	Q
MIOTF126 ; Full suite test 126 - TPL_DEEP_NESTED_CONTEXT.;
	N TOK,ERR,CONF,CTX,OUT,RES,TPL
	; This template expects:
	; CTX("groups","items",g,"name") = group name
	; CTX("groups","items",g,"members",m,"name") = member name
	; If no members, inverted section prints "EMPTY"
	SET TPL="{{#groups.items}}"
	SET TPL=TPL_"G={{name}}:["
	SET TPL=TPL_"{{#members}}{{name}},{{/members}}"
	SET TPL=TPL_"{{^members}}EMPTY{{/members}}"
	SET TPL=TPL_"];"
	SET TPL=TPL_"{{/groups.items}}"
	DO COMPILE^MIOTPL2(TPL,.TOK,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"compile")
	; Build deep context with two groups:
	; Group 1 has 2 members, Group 2 has none.;
	KILL CTX
	SET CTX("groups","items",1,"name")="Core"
	SET CTX("groups","items",1,"members",1,"name")="Alice"
	SET CTX("groups","items",1,"members",2,"name")="Bob"
	SET CTX("groups","items",2,"name")="Tools"
	; No members under group 2 => should show EMPTY
	DO EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"eval")
	DO EQ^MIOTASSERT(OUT,"G=Core:[Alice,Bob,];G=Tools:[EMPTY];","deep nested render")
	Q
MIOTF126B ; Full suite test 126B - TPL_DEEP_NESTED_CONTEXT_SCALARS.;
	N TOK,ERR,CONF,CTX,OUT,RES,TPL
	; Scalar member list variant:
	; CTX("groups","items",g,"name") = group name
	; CTX("groups","items",g,"members",m) = member scalar (e.g., "Alice")
	; Uses {{.}} inside members loop.;
	; If no members, inverted section prints "EMPTY"
	SET TPL="{{#groups.items}}"
	SET TPL=TPL_"G={{name}}:["
	SET TPL=TPL_"{{#members}}{{.}},{{/members}}"
	SET TPL=TPL_"{{^members}}EMPTY{{/members}}"
	SET TPL=TPL_"];"
	SET TPL=TPL_"{{/groups.items}}"
	DO COMPILE^MIOTPL2(TPL,.TOK,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"compile")
	; Two groups: one with scalar members, one empty.;
	KILL CTX
	SET CTX("groups","items",1,"name")="Core"
	SET CTX("groups","items",1,"members",1)="Alice"
	SET CTX("groups","items",1,"members",2)="Bob"
	SET CTX("groups","items",2,"name")="Tools"
	; No members under group 2 => should show EMPTY
	DO EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	DO OK^MIOTASSERT('$D(ERR),"eval")
	DO EQ^MIOTASSERT(OUT,"G=Core:[Alice,Bob,];G=Tools:[EMPTY];","deep nested scalars render")
	Q
	;
MIOTF127 ;
	K ERR,OUT,CONF,CTX
	M CONF=^MIO("CONF")
	;
	S ROOT="templates/test127-"_$J_"/"
	D MKDIR(ROOT),MKDIR(ROOT_"partials/")
	;
	S CONF("templates","root")=ROOT
	S CONF("templates","ext")=""
	; Write layout + page templates
	D WRFILE(ROOT_"layout.html","L0<title>{{{blocks.title}}}</title>|D={{desc}}|{{{content}}}|L9",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write layout") K ERR
	;
	N T,OK S OK=$$READFILE^MIOTPL2(ROOT_"layout.html",.T,.ERR) 
	D EQ^MIOTASSERT($E(T,1,9),"L0<title>","layout file prefix")
	;
	D WRFILE(ROOT_"page.html","{{#block:title}}T{{year}}{{/block:title}}P{{year}}",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write page") K ERR
	;
	; Clear cache entries for these exact filepaths (defensive)
	K ^MIO("TPL","CACHE",ROOT_"layout.html")
	K ^MIO("TPL","CACHE",ROOT_"page.html")
	;	
	;
	; Context
	S CTX("year")=2026
	S CTX("desc")="DESC"
	;
	;
	D RENDERPAGE^MIOTPL2("page.html","layout.html",.CONF,.CTX,.OUT,.ERR)
	D OK^MIOTASSERT('$D(ERR),"renderpage") ZWR:$D(ERR) ERR
	;
	; Expected output
	D EQ^MIOTASSERT(OUT,"L0<title>T2026</title>|D=DESC|P2026|L9","layout+page output")
	D EQ^MIOTASSERT($G(CTX("blocks","title")),"T2026","block title captured")
	;
	; Cleanup best-effort
	D RMDIR(ROOT)
	Q
	;
MIOTF128 ; Full suite test 128 - TPL_PARTIALS_INCLUDE
	K ERR,OUT,CONF,CTX
	N ROOT
	;
	; Pull base config first (if you want it), THEN override root/ext
	M CONF=^MIO("CONF")
	;
	S ROOT="templates/test128-"_$J_"/"
	D MKDIR(ROOT)
	D MKDIR(ROOT_"partials/")
	;
	S CONF("templates","root")=ROOT
	S CONF("templates","ext")=""
	;
	; --- write partials ---
	D WRFILE(ROOT_"partials/app1.html","APP1",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write app1") K ERR
	;
	D WRFILE(ROOT_"partials/p.html","PP",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write p") K ERR
	;
	; --- write main (includes both partials) ---
	D WRFILE(ROOT_"main.html","{{> partials/app1.html}}{{> partials/p.html}}",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write main") K ERR
	;
	; --- render main by logical name (NO ROOT PREFIX) ---
	D RENDER^MIOTPL2("main.html",.CONF,.CTX,.OUT,.ERR)
	D OK^MIOTASSERT('$D(ERR),"render main") I $D(ERR) ZWR ERR
	;
	D EQ^MIOTASSERT(OUT,"APP1PP","partials include output")
	;
	D RMDIR(ROOT)
	Q
	;
MIOTF129 ;
	N TOK,ERR,CONF,CTX,OUT
	D COMPILE^MIOTPL2("{{#x}}Y{{/x}}{{^x}}N{{/x}}",.TOK,.ERR)
	S CTX("x")="false"
	D EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	D EQ^MIOTASSERT(OUT,"N","false string is falsey")
	K OUT,ERR
	S CTX("x")="true"
	D EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	D EQ^MIOTASSERT(OUT,"Y","true string is truthy")
	Q
	;
MIOTF130 ;
	N TOK,ERR,CONF,CTX,OUT
	D COMPILE^MIOTPL2("{{#x}}Y{{/x}}{{^x}}N{{/x}}",.TOK,.ERR)
	S CTX("x")="FALSE"
	D EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	D EQ^MIOTASSERT(OUT,"N","FALSE is falsey")
	Q
MIOTF131 ; CRLF output (scalar) + safe CRLF values
	N TOK,ERR,CONF,CTX,OUT,CRLF,TPL,EXP
	S CRLF=$C(13,10)
	; template uses CRLF newlines
	S TPL="A"_CRLF_"B"_CRLF_"{{x}}"_CRLF
	D COMPILE^MIOTPL2(TPL,.TOK,.ERR)
	D OK^MIOTASSERT('$D(ERR),"compile")
	; value already contains CRLF -> must NOT become \r\r\n
	S CTX("x")="X"_CRLF_"Y"
	D EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	D OK^MIOTASSERT('$D(ERR),"eval")
	S EXP="A"_CRLF_"B"_CRLF_"X"_CRLF_"Y"_CRLF
	D EQ^MIOTASSERT(OUT,EXP,"crlf scalar + safe")
	Q
	;
MIOTF132 ; CRLF output (ref mode) + safe CRLF values
	N TOK,ERR,CONF,CTX,CRLF,TPL,EXP
	N O,OUT,I
	S CRLF=$C(13,10)
	S TPL="A"_CRLF_"B"_CRLF_"{{x}}"_CRLF
	D COMPILE^MIOTPL2(TPL,.TOK,.ERR)
	D OK^MIOTASSERT('$D(ERR),"compile")
	S CTX("x")="X"_CRLF_"Y"
	D EVALREF^MIOTPL2(.TOK,.CONF,.CTX,$NA(O),.ERR)
	D OK^MIOTASSERT('$D(ERR),"evalref")
	S OUT="",I=0
	F  S I=$O(O(I)) Q:'I  S OUT=OUT_O(I)
	S EXP="A"_CRLF_"B"_CRLF_"X"_CRLF_"Y"_CRLF
	D EQ^MIOTASSERT(OUT,EXP,"crlf ref + safe")
	Q
	;
MIOTF133 ; CRLF detected across chunk boundary (COMPREF/COMPILEA path)
	N ARR,TOK,ERR,CONF,CTX,OUT,EXP
	; chunk boundary: ends with CR then next chunk starts with LF
	S ARR(1)="A"_$C(13)
	S ARR(2)=$C(10)_"B"_$C(10)
	D COMPILEA^MIOTPL2(.ARR,.TOK,.ERR)
	D OK^MIOTASSERT('$D(ERR),"compileA")
	D EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	D OK^MIOTASSERT('$D(ERR),"eval")
	S EXP="A"_$C(13,10)_"B"_$C(13,10)
	D EQ^MIOTASSERT(OUT,EXP,"crlf boundary detect")
	Q 	 		
TEST001
	N HDR S HDR="[TEST001][No Interpolation]"
	N DESC S DESC=HDR_"[Mustache-free templates should render as-is]"
	S TEMPLATE="Hello from {Mustache}!\n"
	S EXPECTED="Hello from {Mustache}!\n"
	N CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST002
	N HDR S HDR="[TEST002][Basic Interpolation]"
	N DESC S DESC=HDR_"[Unadorned tags should interpolate content into the template.]"
	S TEMPLATE="Hello, {{subject}}!\n"
	S EXPECTED="Hello, world!\n"
	N CTX
	SET CTX("subject")="world"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST003
	N HDR S HDR="[TEST003][No Re-interpolation]"
	N DESC S DESC=HDR_"[Interpolated tag output should not be re-interpolated.]"
	S TEMPLATE="{{template}}: {{planet}}"
	S EXPECTED="{{planet}}: Earth"
	N CTX
	SET CTX("template")="{{planet}}"
	SET CTX("planet")="Earth"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST004
	N HDR S HDR="[TEST004][HTML Escaping]"
	N DESC S DESC=HDR_"[Basic interpolation should be HTML escaped..]"
	S TEMPLATE="These characters should be HTML escaped: {{forbidden}}"
	S EXPECTED="These characters should be HTML escaped: &amp; &quot; &lt; &gt;"
	N CTX SET CTX("forbidden")="& "" < >"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST005
	N HDR S HDR="[TEST005][Triple Mustache]"
	N DESC S DESC=HDR_"[Triple mustaches should interpolate without HTML escaping.]"
	S TEMPLATE="These characters should not be HTML escaped: {{{forbidden}}}"
	S EXPECTED="These characters should not be HTML escaped: & "" < >"
	N CTX SET CTX("forbidden")="& "" < >"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST006
	N HDR S HDR="[TEST006][Ampersand]"
	N DESC S DESC=HDR_"[Ampersand should interpolate without HTML escaping.]"
	S TEMPLATE="These characters should not be HTML escaped: {{{forbidden}}}"
	S EXPECTED="These characters should not be HTML escaped: & "" < >"
	N CTX SET CTX("forbidden")="& "" < >"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST007
	N HDR S HDR="[TEST007][Basic Integer Interpolation]"
	N DESC S DESC=HDR_"[Integers should interpolate seamlessly.]"
	S TEMPLATE="""{{mph}} miles an hour!"""
	S EXPECTED="""85 miles an hour!"""
	N CTX 
	SET CTX("mph")=85
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST008
	N HDR S HDR="[TEST008][Triple Mustache Integer Interpolation]"
	N DESC S DESC=HDR_"[Integers should interpolate seamlessly.]"
	S TEMPLATE="""{{{mph}}} miles an hour!"""
	S EXPECTED="""85 miles an hour!"""
	N CTX 
	SET CTX("mph")=85
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST009
	N HDR S HDR="[TEST009][Ampersand Integer Interpolation]"
	N DESC S DESC=HDR_"[Integers should interpolate seamlessly.]"
	S TEMPLATE="""{{&mph}} miles an hour!"""
	S EXPECTED="""85 miles an hour!"""
	N CTX 
	SET CTX("mph")=85
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST010
	N HDR S HDR="[TEST010[Basic Decimal Interpolation]"
	N DESC S DESC=HDR_"[Decimals should interpolate seamlessly with proper significance.]"
	S TEMPLATE="""{{power}} jiggawatts!"""
	S EXPECTED="""1.21 jiggawatts!"""
	N CTX 
	SET CTX("power")=1.21
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST011
	N HDR S HDR="[TEST011][Triple Mustache Decimal Interpolation]"
	N DESC S DESC=HDR_"[Decimals should interpolate seamlessly with proper significance.]"
	S TEMPLATE="""{{{power}}} jiggawatts!"""
	S EXPECTED="""1.21 jiggawatts!"""
	N CTX 
	SET CTX("power")=1.21
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST012
	N HDR S HDR="[TEST012[Ampersand Decimal Interpolation]"
	N DESC S DESC=HDR_"[Decimals should interpolate seamlessly with proper significance.]"
	S TEMPLATE="""{{&power}} jiggawatts!"""
	S EXPECTED="""1.21 jiggawatts!"""
	N CTX 
	SET CTX("power")=1.21
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST013
	N HDR S HDR="[TEST013][Basic Null Interpolation]"
	N DESC S DESC=HDR_"[Nulls should interpolate as the empty string.]"
	S TEMPLATE="I ({{cannot}}) be seen!"
	S EXPECTED="I () be seen!"
	N CTX 
	SET CTX("cannot")=""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST014
	N HDR S HDR="[TEST014[Triple Mustache Null Interpolation]"
	N DESC S DESC=HDR_"[Nulls should interpolate as the empty string.]"
	S TEMPLATE="I ({{{cannot}}}) be seen!"
	S EXPECTED="I () be seen!"
	N CTX 
	SET CTX("cannot")=""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST015
	N HDR S HDR="[TEST015][Ampersand Null Interpolation]"
	N DESC S DESC=HDR_"[Nulls should interpolate as the empty string.]"
	S TEMPLATE="I ({{&cannot}}) be seen!"
	S EXPECTED="I () be seen!"
	N CTX 
	SET CTX("cannot")=""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST016
	N HDR S HDR="[TEST016[Basic Context Miss Interpolation]"
	N DESC S DESC=HDR_"[Failed context lookups should default to empty strings.]"
	S TEMPLATE="I ({{cannot}}) be seen!"
	S EXPECTED="I () be seen!"
	N CTX 
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST017
	N HDR S HDR="[TEST017][Triple Mustache Context Miss Interpolation]"
	N DESC S DESC=HDR_"[Failed context lookups should default to empty strings.]"
	S TEMPLATE="I ({{{cannot}}}) be seen!"
	S EXPECTED="I () be seen!"
	N CTX 
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST018
	N HDR S HDR="[TEST018[Ampersand Context Miss Interpolation]"
	N DESC S DESC=HDR_"[Failed context lookups should default to empty strings.]"
	S TEMPLATE="I ({{&cannot}}) be seen!"
	S EXPECTED="I () be seen!"
	N CTX 
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST019
	N HDR S HDR="[TEST019][Dotted Names - Basic Interpolation]"
	N DESC S DESC=HDR_"[Dotted names should be considered a form of shorthand for sections.]"
	S TEMPLATE="""{{person.name}}"" == ""{{#person}}{{name}}{{/person}}"""
	S EXPECTED="""Joe"" == ""Joe"""
	N CTX 
	SET CTX("person","name")="Joe"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST020
	N HDR S HDR="[TEST020][Dotted Names - Triple Mustache Interpolation]"
	N DESC S DESC=HDR_"[Dotted names should be considered a form of shorthand for sections.]"
	S TEMPLATE="""{{{person.name}}}"" == ""{{#person}}{{{name}}}{{/person}}""" 
	S EXPECTED="""Joe"" == ""Joe"""
	N CTX 
	SET CTX("person","name")="Joe"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST021
	N HDR S HDR="[TEST021][Dotted Names - Ampersand Interpolation]"
	N DESC S DESC=HDR_"[Dotted names should be considered a form of shorthand for sections.]"
	S TEMPLATE="""{{&person.name}}"" == ""{{#person}}{{&name}}{{/person}}"""
	S EXPECTED="""Joe"" == ""Joe"""
	N CTX 
	SET CTX("person","name")="Joe"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST022
	N HDR S HDR="[TEST022][Dotted Names - Arbitrary Depth]"
	N DESC S DESC=HDR_"[Dotted names should be functional to any level of nesting.]"
	S TEMPLATE="""{{a.b.c.d.e.name}}"" == ""Phil"""
	S EXPECTED="""Phil"" == ""Phil"""
	N CTX 
	SET CTX("a","b","c","d","e","name")="Phil"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST023
	N HDR S HDR="[TEST023][Dotted Names - Broken Chains]"
	N DESC S DESC=HDR_"[Any falsey value prior to the last part of the name should yield ''.]"
	S TEMPLATE="""{{a.b.c}}"" == """""
	S EXPECTED=""""" == """""
	N CTX 
	SET CTX("a")=""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST024
	N HDR S HDR="[TEST024][Dotted Names - Broken Chain Resolution]"
	N DESC S DESC=HDR_"[Each part of a dotted name should resolve only against its parent.]"
	S TEMPLATE="""{{a.b.c.name}}"" == """""
	S EXPECTED=""""" == """""
	N CTX 
	SET CTX("a","b")=""
	SET CTX("c","name")="Jim"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST025
	N HDR S HDR="[TEST025][Dotted Names - Initial Resolution]"
	N DESC S DESC=HDR_"[The first part of a dotted name should resolve as any other name.]"
	S TEMPLATE="""{{#a}}{{b.c.d.e.name}}{{/a}}"" == ""Phil"""
	S EXPECTED="""Phil"" == ""Phil"""
	N CTX 
	SET CTX("a","b","c","d","e","name")="Phil"
	SET CTX("b","c","d","e","name")="Wrong"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST026
	N HDR S HDR="[TEST026][Dotted Names - Context Precedence]"
	N DESC S DESC=HDR_"[Dotted names should be resolved against former resolutions.]"
	S TEMPLATE="{{#a}}{{b.c}}{{/a}}"
	S EXPECTED=""
	N CTX 
	SET CTX("a","b")=""
	SET CTX("b","c")="ERROR"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST027
	N HDR S HDR="[TEST027][Dotted Names are never single keys]"
	N DESC S DESC=HDR_"[Dotted names shall not be parsed as single, atomic keys]"
	S TEMPLATE="{{a.b}}"
	S EXPECTED=""
	N CTX 
	SET CTX("a.b")="c"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST028
	N HDR S HDR="[TEST028][Dotted Names - No Masking]"
	N DESC S DESC=HDR_"[Dotted Names in a given context are unvavailable due to dot splitting]"
	S TEMPLATE="{{a.b}}"
	S EXPECTED="d"
	N CTX 
	SET CTX("a.b")="c"
	SET CTX("a","b")="d"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
	;
TEST029
	N HDR S HDR="[TEST029][Implicit Iterators - Basic Interpolation]"
	N DESC S DESC=HDR_"[Unadorned tags should interpolate content into the template.]"
	S TEMPLATE="Hello, {{.}}!\n"
	S EXPECTED="Hello, world!\n"
	N CTX 
	SET CTX="world"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST030
	N HDR S HDR="[TEST030][Implicit Iterators - HTML Escaping]"
	N DESC S DESC=HDR_"[Basic interpolation should be HTML escaped.]"
	S TEMPLATE="These characters should be HTML escaped: {{.}}\n"
	S EXPECTED="These characters should be HTML escaped: &amp; &quot; &lt; &gt;\n"
	N CTX 
	SET CTX="& "" < >"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST031
	N HDR S HDR="[TEST031][Implicit Iterators - Triple Mustache]"
	N DESC S DESC=HDR_"[Implicit Iterators - Triple Mustache.]"
	S TEMPLATE="These characters should not be HTML escaped: {{{.}}}\n"
	S EXPECTED="These characters should not be HTML escaped: & "" < >\n"
	N CTX 
	SET CTX="& "" < >"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST032
	N HDR S HDR="[TEST032][Implicit Iterators - Ampersand]"
	N DESC S DESC=HDR_"[Ampersand should interpolate without HTML escaping.]"
	S TEMPLATE="These characters should not be HTML escaped: {{&.}}\n"
	S EXPECTED="These characters should not be HTML escaped: & "" < >\n"
	N CTX 
	SET CTX="& "" < >"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST033
	N HDR S HDR="[TEST033][Implicit Iterators - Basic Integer Interpolation]"
	N DESC S DESC=HDR_"[Integers should interpolate seamlessly.]"
	S TEMPLATE="""{{.}} miles an hour!"""
	S EXPECTED="""85 miles an hour!"""
	N CTX 
	SET CTX=85
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST034
	N HDR S HDR="[TEST034][Interpolation - Surrounding Whitespace]"
	N DESC S DESC=HDR_"[Interpolation should not alter surrounding whitespace.]"
	S TEMPLATE="| {{string}} |"
	S EXPECTED="| --- |"
	N CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST035
	N HDR S HDR="[TEST035][Triple Mustache - Surrounding Whitespace]"
	N DESC S DESC=HDR_"[Interpolation should not alter surrounding whitespace.]"
	S TEMPLATE="| {{{string}}} |"
	S EXPECTED="| --- |"
	N CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST036
	N HDR S HDR="[TEST036][Ampersand - Surrounding Whitespace]"
	N DESC S DESC=HDR_"[Interpolation should not alter surrounding whitespace.]"
	S TEMPLATE="| {{&string}} |"
	S EXPECTED="| --- |"
	N CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST037
	N HDR S HDR="[TEST037][Interpolation - Standalone]"
	N DESC S DESC=HDR_"[Standalone interpolation should not alter surrounding whitespace.]"
	S TEMPLATE="  {{string}}\n"
	S EXPECTED="  ---\n"
	N CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST038
	N HDR S HDR="[TEST038][Triple Mustache - Standalone]"
	N DESC S DESC=HDR_"[Standalone interpolation should not alter surrounding whitespace.]"
	S TEMPLATE="  {{{string}}}\n"
	S EXPECTED="  ---\n"
	N CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST039
	N HDR S HDR="[TEST039][Ampersand - Standalone]"
	N DESC S DESC=HDR_"[Standalone interpolation should not alter surrounding whitespace.]"
	S TEMPLATE="  {{&string}}\n"
	S EXPECTED="  ---\n"
	N CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST040
	N HDR S HDR="[TEST040][Interpolation With Paddin]"
	N DESC S DESC=HDR_"[Superfluous in-tag whitespace should be ignored.]"
	S TEMPLATE="|{{ string }}|"
	S EXPECTED="|---|"
	N CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST041
	N HDR S HDR="[TEST041][Triple Mustache With Padding]"
	N DESC S DESC=HDR_"[Superfluous in-tag whitespace should be ignored.]"
	S TEMPLATE="|{{{ string }}}|"
	S EXPECTED="|---|"
	N CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST042
	N HDR S HDR="[TEST042][Ampersand With Padding]"
	N DESC S DESC=HDR_"[Superfluous in-tag whitespace should be ignored.]"
	S TEMPLATE="|{{& string }}|"
	S EXPECTED="|---|"
	N CTX 
	SET CTX("string")="---"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST043 ;
	N HDR S HDR="[TEST043][Truthy]"
	N DESC S DESC=HDR_"[Truthy sections should have their contents rendered.]"
	S TEMPLATE="""{{#boolean}}This should be rendered.{{/boolean}}"""
	S EXPECTED="""This should be rendered."""
	N CTX
	S CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST044
	N HDR S HDR="[TEST044][Falsey]"
	N DESC S DESC=HDR_"[Falsey sections should have their contents omitted.]"
	S TEMPLATE="""{{#boolean}}This should not be rendered.{{/boolean}}"""
	S EXPECTED=""""""
	N CTX 
	S CTX("boolean")="false"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST045
	N HDR S HDR="[TEST045][Null is false]"
	N DESC S DESC=HDR_"[Null is falsey.]"
	S TEMPLATE="""{{#null}}This should not be rendered.{{/null}}"""
	S EXPECTED=""""""
	N CTX 
	S CTX("null")=""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST046 
	N HDR S HDR="[TEST046][Context]"
	N DESC S DESC=HDR_"[Objects and hashes should be pushed onto the context stack.]"
	S TEMPLATE="""{{#context}}Hi {{name}}.{{/context}}"""
	S EXPECTED="""Hi Joe."""
	N CTX 
	S CTX("context","name")="Joe"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST047
	N HDR S HDR="[TEST047][Parent context]"
	N DESC S DESC=HDR_"[Names missing in the current context are looked up in the stack.]"
	S TEMPLATE="""{{#sec}}{{a}}, {{b}}, {{c.d}}{{/sec}}"""
	S EXPECTED="""foo, bar, baz"""
	N CTX 
	S CTX("a")="foo"
	S CTX("b")="wrong"
	S CTX("sec","b")="bar"
	S CTX("c","d")="baz"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST048
	N HDR S HDR="[TEST048][Variable test]"
	N DESC S DESC=HDR_"[Non-false sections have their value at the top of context,accessible as {{.}} or" 
	S DESC=DESC_"through the parent context. This gives a simple way to display content conditionally if a variable exists.]"
	S TEMPLATE="""{{#foo}}{{.}} is {{foo}}{{/foo}}"""
	S EXPECTED="""bar is bar"""
	N CTX 
	SET CTX("foo")="bar"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST049
	N HDR S HDR="[TEST049][List Contexts]"
	N DESC S DESC=HDR_"[All elements on the context stack should be accessible within lists.]" 
	S TEMPLATE="{{#tops}}{{#middles}}{{tname.lower}}{{mname}}.{{#bottoms}}{{tname.upper}}{{mname}}{{bname}}.{{/bottoms}}{{/middles}}{{/tops}}"
	S EXPECTED="a1.A1x.A1y."
	N CTX 
	SET CTX("tops",1,"middles",1,"bottoms",1,"bname")="x"
	SET CTX("tops",1,"middles",1,"bottoms",2,"bname")="y"
	SET CTX("tops",1,"middles",1,"mname")=1
	SET CTX("tops",1,"tname","lower")="a"
	SET CTX("tops",1,"tname","upper")="A"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST050
	N HDR S HDR="[TEST050][Deeply Nested Contexts] "
	N DESC S DESC=HDR_"[All elements on the context stack should be accessible.]"
	S TEMPLATE="{{#a}}\n{{one}}\n{{#b}}\n{{one}}{{two}}{{one}}\n{{#c}}\n{{one}}{{two}}{{three}}{{two}}{{one}}\n{{#d}}\n{{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}\n{{#five}}\n{{one}}{{two}}{{three}}{{four}}{{five}}{{four}}{{three}}{{two}}{{one}}\n{{one}}{{two}}{{three}}{{four}}{{.}}6{{.}}{{four}}{{three}}{{two}}{{one}}\n{{one}}{{two}}{{three}}{{four}}{{five}}{{four}}{{three}}{{two}}{{one}}\n{{/five}}\n{{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}\n{{/d}}\n{{one}}{{two}}{{three}}{{two}}{{one}}\n{{/c}}\n{{one}}{{two}}{{one}}\n{{/b}}\n{{one}}\n{{/a}}\n"
	S EXPECTED="1\n121\n12321\n1234321\n123454321\n12345654321\n123454321\n1234321\n12321\n121\n1\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	SET CTX("a","one")=1
	SET CTX("b","two")=2
	SET CTX("c","d","five")=5
	SET CTX("c","d","four")=4
	SET CTX("c","three")=3
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST051
	N HDR S HDR="[TEST051][List]"
	N DESC S DESC=HDR_"[Lists should be iterated; list items should visit the context stack.]"
	S TEMPLATE="""{{#list}}{{item}}{{/list}}"""
	S EXPECTED="""123"""
	N CTX 
	SET CTX("list",1,"item")=1
	SET CTX("list",2,"item")=2
	SET CTX("list",3,"item")=3
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST052
	N HDR S HDR="[TEST052][Empty List]"
	N DESC S DESC=HDR_"[Empty lists should behave like falsey values.]"
	S TEMPLATE="""{{#list}}Yay lists!{{/list}}"""
	S EXPECTED=""""""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST053
	N HDR S HDR="[TEST053][Doubled]"
	N DESC S DESC=HDR_"[Multiple sections per template should be permitted.]"
	S TEMPLATE="{{#bool}}\n* first\n{{/bool}}\n* {{two}}\n{{#bool}}\n* third\n{{/bool}}\n"
	S EXPECTED="* first\n* second\n* third\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	SET CTX("bool")="true"
	SET CTX("two")="second"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST054
	N HDR S HDR="[TEST054][Nested (Truthy)]"
	N DESC S DESC=HDR_"[Nested truthy sections should have their contents rendered.]"
	S TEMPLATE="| A {{#bool}}B {{#bool}}C{{/bool}} D{{/bool}} E |"
	S EXPECTED="| A B C D E |"
	N CTX 
	SET CTX("bool")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST055
	N HDR S HDR="[TEST055][Nested (Falsey)]"
	N DESC S DESC=HDR_"[Nested falsey sections should be omitted.]"
	S TEMPLATE="| A {{#bool}}B {{#bool}}C{{/bool}} D{{/bool}} E |"
	S EXPECTED="| A  E |"
	N CTX 
	SET CTX("bool")="false"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST056
	N HDR S HDR="[TEST056][Context Misses]"
	N DESC S DESC=HDR_"[Failed context lookups should be considered falsey.]"
	S TEMPLATE="[{{#missing}}Found key 'missing'!{{/missing}}]"
	S EXPECTED="[]"
	N CTX 
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST057
	N HDR S HDR="[TEST057][Implicit Iterator - String]"
	N DESC S DESC=HDR_"[Implicit iterators should directly interpolate strings.]"
	S TEMPLATE="""{{#list}}({{.}}){{/list}}"""
	S EXPECTED="""(a)(b)(c)(d)(e)"""
	N CTX 
	SET CTX("list",1)="a"
	SET CTX("list",2)="b"
	SET CTX("list",3)="c"
	SET CTX("list",4)="d"
	SET CTX("list",5)="e"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST058
	N HDR S HDR="[TEST058][Implicit Iterator - Integer]"
	N DESC S DESC=HDR_"[Implicit iterators should cast integers to strings and interpolate.]"
	S TEMPLATE="""{{#list}}({{.}}){{/list}}"""
	S EXPECTED="""(1)(2)(3)(4)(5)"""
	N CTX 
	SET CTX("list",1)=1
	SET CTX("list",2)=2
	SET CTX("list",3)=3
	SET CTX("list",4)=4
	SET CTX("list",5)=5
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST059
	N HDR S HDR="[TEST059][Implicit Iterator - Decimal]"
	N DESC S DESC=HDR_"[Implicit iterators should cast decimals to strings and interpolate.]"
	S TEMPLATE="""{{#list}}({{.}}){{/list}}"""
	S EXPECTED="""(1.1)(2.2)(3.3)(4.4)(5.5)"""
	N CTX 
	SET CTX("list",1)=1.1
	SET CTX("list",2)=2.2
	SET CTX("list",3)=3.3
	SET CTX("list",4)=4.4
	SET CTX("list",5)=5.5
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST060
	N HDR S HDR="[TEST060][Implicit Iterator - Array]"
	N DESC S DESC=HDR_"[Implicit iterators should allow iterating over nested arrays.]"
	S TEMPLATE="""{{#list}}({{#.}}{{.}}{{/.}}){{/list}}"""
	S EXPECTED="""(123)(abc)"""
	N CTX 
	SET CTX("list",1,1)=1
	SET CTX("list",1,2)=2
	SET CTX("list",1,3)=3
	SET CTX("list",2,1)="a"
	SET CTX("list",2,2)="b"
	SET CTX("list",2,3)="c"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST061
	N HDR S HDR="[TEST061][Implicit Iterator - HTML Escaping]"
	N DESC S DESC=HDR_"[Implicit iterators with basic interpolation should be HTML escaped.]"
	S TEMPLATE="""{{#list}}({{.}}){{/list}}"""
	S EXPECTED="""(&amp;)(&quot;)(&lt;)(&gt;)"""
	N CTX 
	SET CTX("list",1)="&"
	SET CTX("list",2)=""""
	SET CTX("list",3)="<"
	SET CTX("list",4)=">"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST062
	N HDR S HDR="[TEST062][Implicit Iterator - Triple mustache]"
	N DESC S DESC=HDR_"[Implicit iterators in triple mustache should interpolate without HTML escaping.]"
	S TEMPLATE="""{{#list}}({{{.}}}){{/list}}"""
	S EXPECTED="""(&)("")(<)(>)"""
	N CTX 
	SET CTX("list",1)="&"
	SET CTX("list",2)=""""
	SET CTX("list",3)="<"
	SET CTX("list",4)=">"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST063
	N HDR S HDR="[TEST063][Implicit Iterator - Ampersand]"
	N DESC S DESC=HDR_"[Implicit iterators in an Ampersand tag should interpolate without HTML escaping.]"
	S TEMPLATE="""{{#list}}({{&.}}){{/list}}"""
	S EXPECTED="""(&)("")(<)(>)"""
	N CTX 
	SET CTX("list",1)="&"
	SET CTX("list",2)=""""
	SET CTX("list",3)="<"
	SET CTX("list",4)=">"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST064
	N HDR S HDR="[TEST064][Implicit Iterator - Root-level]"
	N DESC S DESC=HDR_"[Implicit iterators should work on root-level lists.]"
	S TEMPLATE="""{{#.}}({{value}}){{/.}}"""
	S EXPECTED="""(a)(b)"""
	N CTX 
	SET CTX(1,"value")="a"
	SET CTX(2,"value")="b"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST065
	N HDR S HDR="[TEST065][Dotted Names - Truthy]"
	N DESC S DESC=HDR_"[Dotted names should be valid for Section tags.]"
	S TEMPLATE="""{{#a.b.c}}Here{{/a.b.c}}"" == ""Here"""
	S EXPECTED="""Here"" == ""Here"""
	N CTX 
	SET CTX("a","b","c")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST066
	N HDR S HDR="[TEST066][Dotted Names - Falsey]"
	N DESC S DESC=HDR_"[Dotted names should be valid for Section tags.]"
	S TEMPLATE="""{{#a.b.c}}Here{{/a.b.c}}"" == """""
	S EXPECTED=""""" == """""
	N CTX 
	SET CTX("a","b","c")="false"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST067
	N HDR S HDR="[TEST067][Dotted Names - Broken Chains]"
	N DESC S DESC=HDR_"[Dotted names that cannot be resolved should be considered falsey.]"
	S TEMPLATE="""{{#a.b.c}}Here{{/a.b.c}}"" == """""
	S EXPECTED=""""" == """""
	N CTX 
	SET CTX("a")=""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST068
	N HDR S HDR="[TEST068][Surrounding Whitespace]"
	N DESC S DESC=HDR_"[Sections should not alter surrounding whitespace.]"
	S TEMPLATE=" | {{#boolean}}\t|\t{{/boolean}} | \n"
	S EXPECTED=" | \t|\t | \n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	SET CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST069
	N HDR S HDR="[TEST069][Internal Whitespace]"
	N DESC S DESC=HDR_"[Sections should not alter surrounding whitespace.]"
	S TEMPLATE=" | {{#boolean}} {{! Important Whitespace }}\n {{/boolean}} | \n"
	S EXPECTED=" |  \n  | \n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	SET CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST070
	N HDR S HDR="[TEST070][Indented Inline Sections]"
	N DESC S DESC=HDR_"[Single-line sections should not alter surrounding whitespace.]"
	S TEMPLATE=" {{#boolean}}YES{{/boolean}}\n {{#boolean}}GOOD{{/boolean}}\n"
	S EXPECTED=" YES\n GOOD\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	SET CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST071
	N HDR S HDR="[TEST071][Standalone Lines]"
	N DESC S DESC=HDR_"[Standalone lines should be removed from the template.]"
	S TEMPLATE="| This Is\n{{#boolean}}\n|\n{{/boolean}}\n| A Line\n"
	S EXPECTED="| This Is\n|\n| A Line\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	SET CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST072
	N HDR S HDR="[TEST072][Indented Standalone Lines]"
	N DESC S DESC=HDR_"[Indented standalone lines should be removed from the template.]"
	S TEMPLATE="| This Is\n  {{#boolean}}\n|\n  {{/boolean}}\n| A Line\n"
	S EXPECTED="| This Is\n|\n| A Line\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	SET CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST073
	N HDR S HDR="[TEST073][Standalone Line Endings]"
	N DESC S DESC=HDR_$$UNESCNL("[""\\r\\n"" should be considered a newline for standalone tags.]")
	S TEMPLATE="|\r\n{{#boolean}}\r\n{{/boolean}}\r\n|"
	S EXPECTED="|\r\n|"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	SET CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST074
	N HDR S HDR="[TEST074][Standalone Without Previous Line]"
	N DESC S DESC=HDR_"[Standalone tags should not require a newline to precede them.]"
	S TEMPLATE="  {{#boolean}}\n#{{/boolean}}\n/"
	S EXPECTED="#\n/"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	SET CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST075
	N HDR S HDR="[TEST075][Standalone Without Newline]"
	N DESC S DESC=HDR_"[Standalone tags should not require a newline to follow them.]"
	S TEMPLATE="#{{#boolean}}\n/\n  {{/boolean}}"
	S EXPECTED="#\n/\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	SET CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST076
	N HDR S HDR="[TEST076][Padding]"
	N DESC S DESC=HDR_"[Superfluous in-tag whitespace should be ignored.]"
	S TEMPLATE="|{{# boolean }}={{/ boolean }}|"
	S EXPECTED="|=|"
	N CTX 
	SET CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST077
	N HDR S HDR="[TEST077][Falsey]"
	N DESC S DESC=HDR_"[Falsey sections should have their contents rendered.]"
	S TEMPLATE="""{{^boolean}}This should be rendered.{{/boolean}}"""
	S EXPECTED="""This should be rendered."""
	N CTX 
	SET CTX("boolean")="false"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST078
	N HDR S HDR="[TEST078][Truthy]"
	N DESC S DESC=HDR_"[Truthy sections should have their contents omitted.]"
	S TEMPLATE="""{{^boolean}}This should be rendered.{{/boolean}}"""
	S EXPECTED=""""""
	N CTX 
	SET CTX("boolean")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST079
	N HDR S HDR="[TEST079][Null is falsey]"
	N DESC S DESC=HDR_"[Null is falsey.]"
	S TEMPLATE="""{{^null}}This should be rendered.{{/null}}"""
	S EXPECTED="""This should be rendered."""
	N CTX 
	SET CTX("null")="null"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST080
	N HDR S HDR="[TEST080][Context]"
	N DESC S DESC=HDR_"[Objects and hashes should behave like truthy values.]"
	S TEMPLATE="""{{^context}}Hi {{name}}.{{/context}}"""
	S EXPECTED=""""""
	N CTX 
	SET CTX("context","name")="Joe"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST081
	N HDR S HDR="[TEST080][List]"
	N DESC S DESC=HDR_"[Lists should behave like truthy values.]"
	S TEMPLATE="""{{^list}}{{n}}{{/list}}"""
	S EXPECTED=""""""
	N CTX 
	SET CTX("list",1,"n")=1
	SET CTX("list",2,"n")=2
	SET CTX("list",3,"n")=3
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST082
	N HDR S HDR="[TEST082][Empty List]"
	N DESC S DESC=HDR_"[Empty lists should behave like falsey values.]"
	S TEMPLATE="""{{^list}}Yay lists!{{/list}}"""
	S EXPECTED="""Yay lists!"""
	N CTX 
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST083
	N HDR S HDR="[TEST083][Doubled]"
	N DESC S DESC=HDR_"[Multiple inverted sections per template should be permitted.]"
	S TEMPLATE="{{^bool}}\n* first\n{{/bool}}\n* {{two}}\n{{^bool}}\n* third\n{{/bool}}\n"
	S EXPECTED="* first\n* second\n* third\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	SET CTX("bool")="false"
	SET CTX("two")="second"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST084
	N HDR S HDR="[TEST084][Nested (Falsey)]"
	N DESC S DESC=HDR_"[Nested falsey sections should have their contents rendered.]"
	S TEMPLATE="| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |"
	S EXPECTED="| A B C D E |"
	N CTX 
	SET CTX("bool")="false"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST085
	N HDR S HDR="[TEST085][Nested (Truthy)]"
	N DESC S DESC=HDR_"[Nested truthy sections should be omitted.]"
	S TEMPLATE="| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |"
	S EXPECTED="| A  E |"
	N CTX 
	SET CTX("bool")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST086
	N HDR S HDR="[TEST086][Context Misses]"
	N DESC S DESC=HDR_"[Failed context lookups should be considered falsey.]"
	S TEMPLATE="[{{^missing}}Cannot find key 'missing'!{{/missing}}]"
	S EXPECTED="[Cannot find key 'missing'!]"
	N CTX 
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST087
	N HDR S HDR="[TEST087][Dotted Names - Truthy]"
	N DESC S DESC=HDR_"[Dotted names should be valid for Inverted Section tags.]"
	S TEMPLATE="""{{^a.b.c}}Not Here{{/a.b.c}}"" == """""
	S EXPECTED=""""" == """""
	N CTX
	SET CTX("a","b","c")="true"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST088
	N HDR S HDR="[TEST088][Dotted Names - Falsey]"
	N DESC S DESC=HDR_"[Dotted names should be valid for Inverted Section tags.]"
	S TEMPLATE="""{{^a.b.c}}Not Here{{/a.b.c}}"" == ""Not Here"""
	S EXPECTED="""Not Here"" == ""Not Here"""
	N CTX
	SET CTX("a","b","c")="false"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST089
	N HDR S HDR="[TEST089][Dotted Names - Broken Chains]"
	N DESC S DESC=HDR_"[Dotted names that cannot be resolved should be considered falsey.]"
	S TEMPLATE="""{{^a.b.c}}Not Here{{/a.b.c}}"" == ""Not Here"""
	S EXPECTED="""Not Here"" == ""Not Here"""
	N CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST090
	N HDR S HDR="[TEST090][Surrounding Whitespace]"
	N DESC S DESC=HDR_"[Inverted sections should not alter surrounding whitespace.]"
	S TEMPLATE=" | {{^boolean}}\t|\t{{/boolean}} | \n"
	S EXPECTED=" | \t|\t | \n"
	N CTX
	SET CTX("booleanl")="false"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST091
	N HDR S HDR="[TEST091][Internal Whitespace]"
	N DESC S DESC=HDR_"[Inverted should not alter internal whitespace.]"
	S TEMPLATE=" | {{^boolean}} {{! Important Whitespace }}\n {{/boolean}} | \n"
	S EXPECTED=" |  \n  | \n"
	N CTX
	SET CTX("booleanl")="false"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST092
	N HDR S HDR="[TEST092][Indented Inline Sections]"
	N DESC S DESC=HDR_"[Single-line sections should not alter surrounding whitespace.]"
	S TEMPLATE=" {{^boolean}}NO{{/boolean}}\n {{^boolean}}WAY{{/boolean}}\n"
	S EXPECTED=" NO\n WAY\n"
	N CTX
	SET CTX("booleanl")="false"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST093
	N HDR S HDR="[TEST093][Standalone Lines]"
	N DESC S DESC=HDR_"[Standalone lines should be removed from the template.]"
	S TEMPLATE="| This Is\n{{^boolean}}\n|\n{{/boolean}}\n| A Line\n"
	S EXPECTED="| This Is\n|\n| A Line\n"
	N CTX
	SET CTX("booleanl")="false"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST094
	N HDR S HDR="[TEST094][Standalone Indented Lines]"
	N DESC S DESC=HDR_"[Standalone indented lines should be removed from the template.]"
	S TEMPLATE="| This Is\n  {{^boolean}}\n|\n  {{/boolean}}\n| A Line\n"
	S EXPECTED="| This Is\n|\n| A Line\n"
	N CTX
	SET CTX("booleanl")="false"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST095
	N HDR S HDR="[TEST095][Standalone Line Endings]"
	N DESC S DESC=HDR_"[""\""\\r\\n\"" should be considered a newline for standalone tags.""]"
	S TEMPLATE="|\r\n{{^boolean}}\r\n{{/boolean}}\r\n|"
	S EXPECTED="|\r\n|"
	N CTX
	SET CTX("booleanl")="false"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST096
	N HDR S HDR="[TEST096][Standalone Without Previous Line]"
	N DESC S DESC=HDR_"[Standalone tags should not require a newline to precede them.]"
	S TEMPLATE="{{^boolean}}\n^{{/boolean}}\n/"
	S EXPECTED="^\n/"
	N CTX
	SET CTX("booleanl")="false"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST097
	N HDR S HDR="[TEST097][Standalone Without Newline]"
	N DESC S DESC=HDR_"[Standalone tags should not require a newline to follow them.]"
	S TEMPLATE="^{{^boolean}}\n/\n  {{/boolean}}"
	S EXPECTED="^\n/\n"
	N CTX
	SET CTX("booleanl")="false"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST098
	N HDR S HDR="[TEST098][Padding]"
	N DESC S DESC=HDR_"[Superfluous in-tag whitespace should be ignored.]"
	S TEMPLATE="|{{^ boolean }}={{/ boolean }}|"
	S EXPECTED="|=|"
	N CTX
	SET CTX("booleanl")="false"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST099
	N HDR S HDR="[TEST099][Basic Behavior]"
	N DESC S DESC=HDR_"[The greater-than operator should expand to the named partial.]"
	S TEMPLATE="""{{>text}}"""
	S EXPECTED="""from partial"""
	N CONF,ROOT D SETUPPART(.CONF,.ROOT) 
	K ERR  D WRFILE(ROOT_"text","from partial",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR	
	S CONF("templates","root")=ROOT
	S CONF("templates","ext")=""
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST100
	N HDR S HDR="[TEST100][Failed Lookup]"
	N DESC S DESC=HDR_"[The empty string should be used when the named partial is not found.]"
	;
	S TEMPLATE="""{{>text}}"""
	;
	S EXPECTED=""""""
	N CONF
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST101
	N HDR S HDR="[TEST101][Context]"
	N DESC S DESC=HDR_"[The greater-than operator should operate within the current context.]"
	S TEMPLATE="""{{>partial}}"""
	S EXPECTED="""*content*"""
	N CONF,ROOT,CTX D SETUPPART(.CONF,.ROOT)
	N ERR 
	D WRFILE(ROOT_"partial","*{{text}}*",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	SET CTX("text")="content"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST102
	N HDR S HDR="[TEST102][Recursion]"
	N DESC S DESC=HDR_"[The greater-than operator should properly recurse.]"
	S TEMPLATE="{{>node}}"
	S EXPECTED="X<Y<>>"
	N CONF,ROOT,CTX D SETUPPART(.CONF,.ROOT)
	N ERR 
	D WRFILE(ROOT_"node","{{content}}<{{#nodes}}{{>node}}{{/nodes}}>",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	SET CTX("content")="X"
	SET CTX("nodes",1,"content")="Y"
	SET CTX("nodes",1,"nodes")=""   ; to match and pass the test (An issue with the JSON parser)
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST103
	N HDR S HDR="[TEST103][Nested]"
	N DESC S DESC=HDR_"[The greater-than operator should work from within partials.]"
	S TEMPLATE="{{>outer}}"
	S EXPECTED="*hello world!*"
	N CONF,ROOT,CTX D SETUPPART(.CONF,.ROOT)
	N ERR 
	D WRFILE(ROOT_"outer","*{{a}} {{>inner}}*",.ERR)
	D WRFILE(ROOT_"inner","{{b}}!",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	SET CTX("a")="hello"
	SET CTX("b")="world"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST104
	N HDR S HDR="[TEST104][Surrounding Whitespace]"
	N DESC S DESC=HDR_"[The greater-than operator should not alter surrounding whitespace.]"
	S TEMPLATE="| {{>partial}} |"
	S EXPECTED="| \t|\t |"
	N CONF,ROOT,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial","\t|\t",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST105
	N HDR S HDR="[TEST105][Inline Indentation]"
	N DESC S DESC=HDR_"[Whitespace should be left untouched.]"
	S TEMPLATE="  {{data}}  {{> partial}}\n"
	S EXPECTED="  |  >\n>\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial",$$UNESCNL(">\n>"),.ERR) ;
	SET CTX("data")="|"
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST106
	N HDR S HDR="[TEST106][Standalone Line Endings]"
	N DESC S DESC=HDR_"[""\r\\n"" should be considered a newline for standalone tags.]"
	S TEMPLATE="|\r\n{{>partial}}\r\n|"
	S EXPECTED="|\r\n>|"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial",$$UNESCNL(">"),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST107
	N HDR S HDR="[TEST107][Standalone Without Previous Line]"
	N DESC S DESC=HDR_"[Standalone tags should not require a newline to precede them.]"
	S TEMPLATE="  {{>partial}}\n>"
	S EXPECTED="  >\n  >>"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial",$$UNESCNL(">\n>"),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST108
	N HDR S HDR="[TEST108][Standalone Without Newline]"
	N DESC S DESC=HDR_"[Standalone tags should not require a newline to follow them.]"
	S TEMPLATE=">\n  {{>partial}}"
	S EXPECTED=">\n  >\n  >"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial",$$UNESCNL(">\n>"),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST109
	N HDR S HDR="[TEST109][Standalone Indentation]"
	N DESC S DESC=HDR_"[Each line of the partial should be indented before rendering.]"
	S TEMPLATE="\\\n {{>partial}}\n/\n"
	S EXPECTED="\\\n |\n <\n->\n |\n/\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial",$$UNESCNL("|\n{{{content}}}\n|\n"),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	N CTX
	S CTX("content")=$$UNESCNL("<\n->")
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST110
	N HDR S HDR="[TEST110][Padding Whitespace]"
	N DESC S DESC=HDR_"[Superfluous in-tag whitespace should be ignored.]"
	S TEMPLATE="|{{> partial }}|"
	S EXPECTED="|[]|"
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
	Q
TEST111
	N HDR S HDR="[TEST111][Inline]"
	N DESC S DESC=HDR_"[Comment blocks should be removed from the template.]"
	S TEMPLATE="12345{{! Comment Block! }}67890"
	S EXPECTED="1234567890"
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST112
	N HDR S HDR="[TEST112][Multiline]"
	N DESC S DESC=HDR_"[Multiline comments should be permitted..]"
	S TEMPLATE="12345{{!\n  This is a\n  multi-line comment...\n}}67890\n"
	S EXPECTED="1234567890\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST113
	N HDR S HDR="[TEST113][Standalone]"
	N DESC S DESC=HDR_"[All standalone comment lines should be removed.]"
	S TEMPLATE="Begin.\n{{! Comment Block! }}\nEnd.\n"
	S EXPECTED="Begin.\nEnd.\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST114
	N HDR S HDR="[TEST114][Indented Standalone]"
	N DESC S DESC=HDR_"[All standalone comment lines should be removed.]"
	S TEMPLATE="Begin.\n  {{! Indented Comment Block! }}\nEnd.\n"
	S EXPECTED="Begin.\nEnd.\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST115
	N HDR S HDR="[TEST115][Standalone Line Endings]"
	N DESC S DESC=HDR_"""\\r\\n"" should be considered a newline for standalone tags."
	S TEMPLATE="|\r\n{{! Standalone Comment }}\r\n|"
	S EXPECTED="|\r\n|"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST116
	N HDR S HDR="[TEST116][Standalone Without Previous Line]"
	N DESC S DESC=HDR_"[Standalone tags should not require a newline to precede them.]"
	S TEMPLATE="  {{! I'm Still Standalone }}\n!"
	S EXPECTED="!"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST117
	N HDR S HDR="[TEST117][Standalone Without Newline]"
	N DESC S DESC=HDR_"[Standalone tags should not require a newline to follow them.]"
	S TEMPLATE="!\n  {{! I'm Still Standalone }}"
	S EXPECTED="!\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST118
	N HDR S HDR="[TEST118][Multiline Standalone]"
	N DESC S DESC=HDR_"[All standalone comment lines should be removed.]"
	S TEMPLATE="Begin.\n{{!\nSomething's going on here...\n}}\nEnd.\n"
	S EXPECTED="Begin.\nEnd.\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST119
	N HDR S HDR="[TEST119][Indented Multiline Standalone]"
	N DESC S DESC=HDR_"[All standalone comment lines should be removed.]"
	S TEMPLATE="Begin.\n  {{!\n    Something's going on here...\n  }}\nEnd.\n"
	S EXPECTED="Begin.\nEnd.\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST120
	N HDR S HDR="[TEST120][Indented Inline]"
	N DESC S DESC=HDR_"[Inline comments should not strip whitespace]"
	S TEMPLATE="  12 {{! 34 }}\n"
	S EXPECTED="  12 \n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST121
	N HDR S HDR="[TEST121][Surrounding Whitespace]"
	N DESC S DESC=HDR_"[Comment removal should preserve surrounding whitespace.]"
	S TEMPLATE="12345 {{! Comment Block! }} 67890"
	S EXPECTED="12345  67890"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST122
	N HDR S HDR="[TEST122][Variable Name Collision]"
	N DESC S DESC=HDR_"[Comments must never render, even if variable with same name exists.]"
	S TEMPLATE="comments never show: >{{! comment }}<"
	S EXPECTED="comments never show: ><"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	N CTX
	S CTX("! comment")=1
	S CTX("! comment ")=2
	S CTX("!comment")=3
	S CTX("comment")=4
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST123
	N HDR S HDR="[TEST123][Pair Behavior]"
	N DESC S DESC=HDR_"[The equals sign (used on both sides) should permit delimiter changes.]"
	S TEMPLATE="{{=<% %>=}}(<%text%>)"
	S EXPECTED="(Hey!)"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	N CTX
	S CTX("text")="Hey!"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST124
	N HDR S HDR="[TEST124][Special Characters]"
	N DESC S DESC=HDR_"[Characters with special meaning regexen should be valid delimiters.]"
	S TEMPLATE="({{=[ ]=}}[text])"
	S EXPECTED="(It worked!)"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	N CTX
	S CTX("text")="It worked!"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST125
	N HDR S HDR="[TEST125][Sections]"
	N DESC S DESC=HDR_"[Delimiters set outside sections should persist.]"
	S TEMPLATE="[\n{{#section}}\n  {{data}}\n  |data|\n{{/section}}\n\n{{= | | =}}\n|#section|\n  {{data}}\n  |data|\n|/section|\n]\n"
	S EXPECTED="[\n  I got interpolated.\n  |data|\n\n  {{data}}\n  I got interpolated.\n]\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	N CTX
	S CTX("section")="true"
	S CTX("data")="I got interpolated."
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST126
	N HDR S HDR="[TEST126][Inverted Sections]"
	N DESC S DESC=HDR_"[Delimiters set outside inverted sections should persist.]"
	S TEMPLATE="[\n{{^section}}\n  {{data}}\n  |data|\n{{/section}}\n\n{{= | | =}}\n|^section|\n  {{data}}\n  |data|\n|/section|\n]\n"
	S EXPECTED="[\n  I got interpolated.\n  |data|\n\n  {{data}}\n  I got interpolated.\n]\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CON,CTX
	N CTX
	S CTX("section")="false"
	S CTX("data")="I got interpolated."
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST127
	N HDR S HDR="[TEST127][Partial Inheritence]"
	N DESC S DESC=HDR_"[Delimiters set in a parent template should not affect a partial.]"
	S TEMPLATE="[ {{>include}} ]\n{{= | | =}}\n[ |>include| ]\n"
	S EXPECTED="[ .yes. ]\n[ .yes. ]\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"include",$$UNESCNL(".{{value}}."),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	N CTX
	S CTX("value")="yes"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST128
	N HDR S HDR="[TEST128][Partial Inheritence]"
	N DESC S DESC=HDR_"[Delimiters set in a parent template should not affect a partial.]"
	S TEMPLATE="[ {{>include}} ]\n{{= | | =}}\n[ |>include| ]\n"
	S EXPECTED="[ .yes. ]\n[ .yes. ]\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"include",$$UNESCNL(".{{value}}."),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	N CTX
	S CTX("value")="yes"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST129
	N HDR S HDR="[TEST129][Post-Partial Behavior]"
	N DESC S DESC=HDR_"[Delimiters set in a partial should not affect the parent template.]"
	S TEMPLATE="[ {{>include}} ]\n[ .{{value}}.  .|value|. ]\n"
	S EXPECTED="[ .yes.  .yes. ]\n[ .yes.  .|value|. ]\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"include",$$UNESCNL(".{{value}}. {{= | | =}} .|value|."),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	N CTX
	S CTX("value")="yes"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST130
	N HDR S HDR="[TEST130][Surrounding Whitespace]"
	N DESC S DESC=HDR_"[Surrounding whitespace should be left untouched.]"
	S TEMPLATE="| {{=@ @=}} |"
	S EXPECTED="|  |"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST131
	N HDR S HDR="[TEST131][Outlying Whitespace (Inline)]"
	N DESC S DESC=HDR_"[Whitespace should be left untouched.]"
	S TEMPLATE=" | {{=@ @=}}\n"
	S EXPECTED=" | \n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST132
	N HDR S HDR="[TEST132][Standalone Tag]"
	N DESC S DESC=HDR_"[Standalone lines should be removed from the template.]"
	S TEMPLATE="Begin.\n{{=@ @=}}\nEnd.\n"
	S EXPECTED="Begin.\nEnd.\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST133
	N HDR S HDR="[TEST133][Indented Standalone Tag]"
	N DESC S DESC=HDR_"[Indented standalone lines should be removed from the template.]"
	S TEMPLATE="Begin.\n  {{=@ @=}}\nEnd.\n"
	S EXPECTED="Begin.\nEnd.\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST134
	N HDR S HDR="[TEST134][Standalone Line Endings]"
	N DESC S DESC=HDR_"[""\\r\\n"" should be considered a newline for standalone tags.]"
	S TEMPLATE="|\r\n{{= @ @ =}}\r\n|"
	S EXPECTED="|\r\n|"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST135
	N HDR S HDR="[TEST135][Standalone Without Previous Line]"
	N DESC S DESC=HDR_"[Standalone tags should not require a newline to precede them.]"
	S TEMPLATE="  {{=@ @=}}\n="
	S EXPECTED="="
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST136
	N HDR S HDR="[TEST136][Standalone Without Newline]"
	N DESC S DESC=HDR_"[Standalone tags should not require a newline to follow them.]"
	S TEMPLATE="=\n  {{=@ @=}}"
	S EXPECTED="=\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST137
	N HDR S HDR="[TEST137][Pair with Padding]"
	N DESC S DESC=HDR_"[Superfluous in-tag whitespace should be ignored.]"
	S TEMPLATE="|{{= @   @ =}}|"
	S EXPECTED="||"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST138
	N HDR S HDR="[TEST138][Default]"
	N DESC S DESC=HDR_"[Default content should be rendered if the block isn't overridden.]"
	S TEMPLATE="{{$title}}Default title{{/title}}\n"
	S EXPECTED="Default title\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST139
	N HDR S HDR="[TEST139][Variable]"
	N DESC S DESC=HDR_"[Default content renders variables]"
	S TEMPLATE="{{$foo}}default {{bar}} content{{/foo}}\n"
	S EXPECTED="default baz content\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	S CTX("bar")="baz"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST140
	N HDR S HDR="[TEST140][Triple Mustache]"
	N DESC S DESC=HDR_"[Default content renders triple mustache variables]"
	S TEMPLATE="{{$foo}}default {{{bar}}} content{{/foo}}\n"
	S EXPECTED="default <baz> content\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	S CTX("bar")="<baz>"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST141
	N HDR S HDR="[TEST141][Sections]"
	N DESC S DESC=HDR_"[Default content renders sections]"
	S TEMPLATE="{{$foo}}default {{#bar}}{{baz}}{{/bar}} content{{/foo}}\n"
	S EXPECTED="default qux content\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	S CTX("bar","baz")="qux"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST142
	N HDR S HDR="[TEST142][Negative Sections]"
	N DESC S DESC=HDR_"[Default content renders negative sections]"
	S TEMPLATE="{{$foo}}default {{^bar}}{{baz}}{{/bar}} content{{/foo}}\n"
	S EXPECTED="default three content\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	S CTX("baz")="three"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST143
	N HDR S HDR="[TEST143][Mustache Injection]"
	N DESC S DESC=HDR_"[Mustache injection in default content]"
	S TEMPLATE="{{$foo}}default {{#bar}}{{baz}}{{/bar}} content{{/foo}}\n"
	S EXPECTED="default {{qux}} content\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	S CTX("bar","baz")="{{qux}}"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
TEST144
	N HDR S HDR="[TEST144][Inherit]"
	N DESC S DESC=HDR_"[Default content rendered inside inherited templates]"
	S TEMPLATE="{{<include}}{{/include}}\n"
	S EXPECTED="default content"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"include",$$UNESCNL("{{$foo}}default content{{/foo}}"),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST145
	N HDR S HDR="[TEST145][Overridden content]"
	N DESC S DESC=HDR_"[Overridden content]"
	S TEMPLATE="{{<super}}{{$title}}sub template title{{/title}}{{/super}}"
	S EXPECTED="...sub template title..."
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"super",$$UNESCNL("...{{$title}}Default title{{/title}}..."),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST146
	N HDR S HDR="[TEST146][Data does not override block]"
	N DESC S DESC=HDR_"[Context does not override argument passed into parent]"
	S TEMPLATE="{{<include}}{{$var}}var in template{{/var}}{{/include}}"
	S EXPECTED="var in template"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	S CTX("var")="var in data"
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"include",$$UNESCNL("{{$var}}var in include{{/var}}"),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST147
	N HDR S HDR="[TEST147][Data does not override block default]"
	N DESC S DESC=HDR_"[Context does not override default content of block]"
	S TEMPLATE="{{<include}}{{/include}}"
	S EXPECTED="var in include"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	S CTX("var")="var in data"
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"include",$$UNESCNL("{{$var}}var in include{{/var}}"),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST148
	N HDR S HDR="[TEST148][Overridden parent]"
	N DESC S DESC=HDR_"[Overridden parent]"
	S TEMPLATE="test {{<parent}}{{$stuff}}override{{/stuff}}{{/parent}}"
	S EXPECTED="test override"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"parent",$$UNESCNL("{{$stuff}}...{{/stuff}}"),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST149
	N HDR S HDR="[TEST149][Two overridden parents]"
	N DESC S DESC=HDR_"[Two overridden parents with different content]"
	S TEMPLATE="test {{<parent}}{{$stuff}}override1{{/stuff}}{{/parent}} {{<parent}}{{$stuff}}override2{{/stuff}}{{/parent}}\n"
	S EXPECTED="test |override1 default| |override2 default|\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"parent",$$UNESCNL("|{{$stuff}}...{{/stuff}}{{$default}} default{{/default}}|"),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST150
	N HDR S HDR="[TEST150][Override parent with newlines]"
	N DESC S DESC=HDR_"[Override parent with newlines]"
	S TEMPLATE="{{<parent}}{{$ballmer}}\npeaked\n\n:(\n{{/ballmer}}{{/parent}}"
	S EXPECTED="peaked\n\n:(\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"parent",$$UNESCNL("{{$ballmer}}peaking{{/ballmer}}"),.ERR) ;
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST151
	N HDR S HDR="[TEST151][Override parent with newlines]"
	N DESC S DESC=HDR_"[Inherit indentation when overriding a parents]"
	S TEMPLATE="{{<parent}}{{$nineties}}hammer time{{/nineties}}{{/parent}}"
	S EXPECTED="stop:\n  hammer time\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"parent",$$UNESCNL("stop:\n  {{$nineties}}collaborate and listen{{/nineties}}\n"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST152
	N HDR S HDR="[TEST152][Only one override]"
	N DESC S DESC=HDR_"[Override one parameter but not the other]"
	S TEMPLATE="{{<parent}}{{$stuff2}}override two{{/stuff2}}{{/parent}}"
	S EXPECTED="new default one, override two"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"parent",$$UNESCNL("{{$stuff}}new default one{{/stuff}}, {{$stuff2}}new default two{{/stuff2}}"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST153
	N HDR S HDR="[TEST153][Parent template]"
	N DESC S DESC=HDR_"[Parent templates behave identically to partials when called with no parameters]"
	S TEMPLATE="{{>parent}}|{{<parent}}{{/parent}}"
	S EXPECTED="default content|default content"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"parent",$$UNESCNL("{{$foo}}default content{{/foo}}"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST154
	N HDR S HDR="[TEST154][Recursion]"
	N DESC S DESC=HDR_"[Recursion in inherited templates]"
	S TEMPLATE="{{<parent}}{{$foo}}override{{/foo}}{{/parent}}"
	S EXPECTED="override override override don't recurse"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"parent",$$UNESCNL("{{$foo}}default content{{/foo}} {{$bar}}{{<parent2}}{{/parent2}}{{/bar}}"),.ERR)
	N ERR D WRFILE(ROOT_"parent2",$$UNESCNL("{{$foo}}parent2 default content{{/foo}} {{<parent}}{{$bar}}don't recurse{{/bar}}{{/parent}}"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST155
	N HDR S HDR="[TEST155][Multi-level inheritance]"
	N DESC S DESC=HDR_"[Top-level substitutions take precedence in multi-level inheritance]"
	S TEMPLATE="{{<parent}}{{$a}}c{{/a}}{{/parent}}"
	S EXPECTED="c"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"parent",$$UNESCNL("{{<older}}{{$a}}p{{/a}}{{/older}}"),.ERR)
	N ERR D WRFILE(ROOT_"older",$$UNESCNL("{{<grandParent}}{{$a}}o{{/a}}{{/grandParent}}"),.ERR)
	N ERR D WRFILE(ROOT_"grandParent",$$UNESCNL("{{$a}}g{{/a}}"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST156
	N HDR S HDR="[TEST156][Multi-level inheritance, no sub child]"
	N DESC S DESC=HDR_"[Top-level substitutions take precedence in multi-level inheritance]"
	S TEMPLATE="{{<parent}}{{/parent}}"
	S EXPECTED="p"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"parent",$$UNESCNL("{{<older}}{{$a}}p{{/a}}{{/older}}"),.ERR)
	N ERR D WRFILE(ROOT_"older",$$UNESCNL("{{<grandParent}}{{$a}}o{{/a}}{{/grandParent}}"),.ERR)
	N ERR D WRFILE(ROOT_"grandParent",$$UNESCNL("{{$a}}g{{/a}}"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST157
	N HDR S HDR="[TEST157][Text inside parent]"
	N DESC S DESC=HDR_"[Ignores text inside parent templates, but does parse $ tags]"
	S TEMPLATE="{{<parent}} asdfasd {{$foo}}hmm{{/foo}} asdfasdfasdf {{/parent}}"
	S EXPECTED="hmm"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"parent",$$UNESCNL("{{$foo}}default content{{/foo}}"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST158
	N HDR S HDR="[TEST158][Text inside parent]"
	N DESC S DESC=HDR_"[Allows text inside a parent tag, but ignores it]"
	S TEMPLATE="{{<parent}} asdfasd asdfasdfasdf {{/parent}}"
	S EXPECTED="default content"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF,CTX D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"parent",$$UNESCNL("{{$foo}}default content{{/foo}}"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST159
	N HDR S HDR="[TEST159][Block scope]"
	N DESC S DESC=HDR_"[Scope of a substituted block is evaluated in the context of the parent template]"
	S TEMPLATE="{{<parent}}{{$block}}I say {{fruit}}.{{/block}}{{/parent}}"
	S EXPECTED="I say bananas."
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	S CTX("fruit")="apples"
	S CTX("nested","fruit")="bananas"
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"parent",$$UNESCNL("{{#nested}}{{$block}}You say {{fruit}}.{{/block}}{{/nested}}"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST160
	N HDR S HDR="[TEST160][Standalone parent]"
	N DESC S DESC=HDR_"[A parent's opening and closing tags need not be on separate lines in order to be standalone]"
	S TEMPLATE="Hi,\n  {{<parent}}{{/parent}}\n"
	S EXPECTED="Hi,\n  one\n  two\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"parent",$$UNESCNL("one\ntwo\n"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST161
	N HDR S HDR="[TEST161][Standalone block]"
	N DESC S DESC=HDR_"[A block's opening and closing tags need not be on separate lines in order to be standalone]"
	S TEMPLATE="{{<parent}}{{$block}}\none\ntwo{{/block}}\n{{/parent}}\n"
	S EXPECTED="Hi,\n  one\n  two\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"parent",$$UNESCNL("Hi,\n  {{$block}}{{/block}}\n"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST162
	N HDR S HDR="[TEST162][Block reindentation]"
	N DESC S DESC=HDR_"[Block indentation is removed at the site of definition and added at the site of expansion]"
	S TEMPLATE="{{<parent}}{{$block}}\n    one\n    two\n{{/block}}{{/parent}}\n"
	S EXPECTED="Hi,\n  one\n  two\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"parent",$$UNESCNL("Hi,\n  {{$block}}\n  {{/block}}\n"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST163
	N HDR S HDR="[TEST163][Intrinsic indentation]"
	N DESC S DESC=HDR_"[When the block opening tag is standalone, indentation is determined by default content]"
	S TEMPLATE="{{<parent}}{{$block}}\none\ntwo\n{{/block}}{{/parent}}\n"
	S EXPECTED="Hi,\n  one\n  two\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"parent",$$UNESCNL("Hi,\n{{$block}}\n  default\n{{/block}}\n"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST164
	N HDR S HDR="[TEST164][Nested block reindentation]"
	N DESC S DESC=HDR_"[Nested blocks are reindented relative to the surrounding block]"
	S TEMPLATE="{{<parent}}{{$nested}}\nthree\n{{/nested}}{{/parent}}\n"
	S EXPECTED="one\n  three\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"parent",$$UNESCNL("{{<grandparent}}{{$block}}\n  one\n  {{$nested}}\n    two\n  {{/nested}}\n{{/block}}{{/grandparent}}\n"),.ERR)
	N ERR D WRFILE(ROOT_"grandparent",$$UNESCNL("{{$block}}default{{/block}}"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST165
	N HDR S HDR="[TEST165][Basic Behavior - Partial]"
	N DESC S DESC=HDR_"[The asterisk operator is used for dynamic partials.]"
	S TEMPLATE="""{{>*dynamic}}"""
	S EXPECTED="""Hello, world!"""
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX S CTX("dynamic")="content"
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"content",$$UNESCNL("Hello, world!"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST166
	N HDR S HDR="[TEST166][Basic Behavior - Name Resolution]"
	N DESC S DESC=HDR_"[The asterisk is not part of the name that will be resolved in the context.]"
	S TEMPLATE="""{{>*dynamic}}"""
	S EXPECTED="""Hello, world!"""
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	S CTX("dynamic")="content"
	S CTX("*dynamic")="wrong"
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"content",$$UNESCNL("Hello, world!"),.ERR)
	N ERR D WRFILE(ROOT_"wrong",$$UNESCNL("Invisible"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST167
	N HDR S HDR="[TEST167][Context Misses - Partial]"
	N DESC S DESC=HDR_"[Failed context lookups should be considered falsey.]"
	S TEMPLATE="""{{>*missing}}"""
	S EXPECTED=""""""
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"missing",$$UNESCNL("Hello, world!"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST168
	N HDR S HDR="[TEST168][Failed Lookup - Partial.]"
	N DESC S DESC=HDR_"[The empty string should be used when the named partial is not found.]"
	S TEMPLATE="""{{>*dynamic}}"""
	S EXPECTED=""""""
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	S CTX("dynamic")="content"
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"foobar",$$UNESCNL("Hello, world!"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST169
	N HDR S HDR="[TEST169][Context]"
	N DESC S DESC=HDR_"[The dynamic partial should operate within the current context.]"
	S TEMPLATE="""{{>*example}}"""
	S EXPECTED="""*Hello, world!*"""
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	S CTX("text")="Hello, world!"
	S CTX("example")="partial"
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial",$$UNESCNL("*{{text}}*"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST170
	N HDR S HDR="[TEST170][Dotted Names]"
	N DESC S DESC=HDR_"[The dynamic partial should operate within the current context.]"
	S TEMPLATE="""{{>*foo.bar.baz}}"""
	S EXPECTED="""*Hello, world!*"""
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	S CTX("text")="Hello, world!"
	S CTX("foo","bar","baz")="partial"
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial",$$UNESCNL("*{{text}}*"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST171
	N HDR S HDR="[TEST171][Dotted Names - Operator Precedence]"
	N DESC S DESC=HDR_"[The dotted name should be resolved entirely before being dereferenced.]"
	S TEMPLATE="""{{>*foo.bar.baz}}"""
	S EXPECTED=""""""
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	S CTX("text")="Hello, world!"
	S CTX("foo")="test"
	S CTX("test","bar","baz")="partial"
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial",$$UNESCNL("*{{text}}*"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST172
	N HDR S HDR="[TEST172][Dotted Names - Failed Lookup]"
	N DESC S DESC=HDR_"[The dynamic partial should operate within the current context.]"
	S TEMPLATE="""{{>*foo.bar.baz}}"""
	S EXPECTED="""**"""
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	S CTX("foo","bar","baz")="partial"
	S CTX("foo","text")="Hello, world!"
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial",$$UNESCNL("*{{text}}*"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST173
	N HDR S HDR="[TEST173][Dotted names - Context Stacking]"
	N DESC S DESC=HDR_"[Dotted names should not push a new frame on the context stack.]"
	S TEMPLATE="{{#section1}}{{>*section2.dynamic}}{{/section1}}"
	S EXPECTED="""section1"""
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	S CTX("section1","value")="section1"
	S CTX("section2","dynamic")="partial"
	S CTX("section2","value")="section2"
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial",$$UNESCNL("""{{value}}"""),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST174
	N HDR S HDR="[TEST174][Dotted names - Context Stacking Under Repetition]"
	N DESC S DESC=HDR_"[Dotted names should not push a new frame on the context stack.]"
	S TEMPLATE="{{#section1}}{{>*section2.dynamic}}{{/section1}}"
	S EXPECTED="testtest"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	S CTX("section1",1)=1
	S CTX("section1",2)=2
	S CTX("section2","dynamic")="partial"
	S CTX("section2","value")="section2"
	S CTX("value")="test"
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial",$$UNESCNL("{{value}}"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST175
	N HDR S HDR="[TEST175][Dotted names - Context Stacking Failed Lookup]"
	N DESC S DESC=HDR_"[Dotted names should resolve against the proper context stack.]"
	S TEMPLATE="{{#section1}}{{>*section2.dynamic}}{{/section1}}"
	S EXPECTED=""""""""""
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	S CTX("section1",1)=1
	S CTX("section1",2)=2
	S CTX("section2","dynamic")="partial"
	S CTX("section2","value")="section2"
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial",$$UNESCNL("""{{value}}"""),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST176
	N HDR S HDR="[TEST176][Recursion]"
	N DESC S DESC=HDR_"[Dynamic partials should properly recurse.]"
	S TEMPLATE="{{>*template}}"
	S EXPECTED="X<Y<>>"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	S CTX("content")="X"
	S CTX("nodes",1,"content")="Y"
	S CTX("nodes",1,"nodes")="" ; 
	S CTX("template")="node"
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"node",$$UNESCNL("{{content}}<{{#nodes}}{{>*template}}{{/nodes}}>"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST177
	N HDR S HDR="[TEST177][Dynamic Names - Double Dereferencing]"
	N DESC S DESC=HDR_"[Dynamic Names can't be dereferenced more than once.]"
	S TEMPLATE="""{{>**dynamic}}"""
	S EXPECTED=""""""
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	S CTX("dynamic")="test"
	S CTX("test")="content"
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"node",$$UNESCNL("Hello, world!"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST178
	N HDR S HDR="[TEST178][Dynamic Names - Composed Dereferencing]"
	N DESC S DESC=HDR_"[Dotted Names are resolved entirely before dereferencing begins.]"
	S TEMPLATE="""{{>*foo.*bar}}"""
	S EXPECTED=""""""
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	S CTX("bar")="buzz"
	S CTX("fizz","buzz","content")="null"
	S CTX("foo")="fizz"
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"content",$$UNESCNL("Hello, world!"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST179
	N HDR S HDR="[TEST179][Surrounding Whitespace]"
	N DESC S DESC=HDR_"[whitespace preceding the tag should be treated as indentation while any"
	S DESC=DESC="whitespace succeding the tag should be left untouched"
	S DESC=DESC="whitespace succeding the tag should be left untouched.]"
	S TEMPLATE="| {{>*partial}} |"
	S EXPECTED="| \t|\t |"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	S CTX("partial")="foobar"
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"foobar",$$UNESCNL("\t|\t"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST180
	N HDR S HDR="[TEST180][Inline Indentation]"
	N DESC S DESC=HDR_"Whitespace should be left untouched: whitespaces preceding the tag"
	S DESC=DESC="whitespace succeding the tag should be left untouched]"
	S TEMPLATE="  {{data}}  {{>*dynamic}}\n"
	S EXPECTED="  |  >\n>\n"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	S CTX("dynamic")="partial"
	S CTX("data")="|"
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial",$$UNESCNL(">\n>"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST181
	N HDR S HDR="[TEST181][Standalone Line Endings]"
	N DESC S DESC=HDR_"Whitespace should be left untouched: whitespaces preceding the tag"
	S DESC=DESC_"whitespace succeding the tag should be left untouched]"
	S TEMPLATE="|\r\n{{>*dynamic}}\r\n|"
	S EXPECTED="|\r\n>|"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	S CTX("dynamic")="partial"
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial",$$UNESCNL(">"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q
TEST182
	N HDR S HDR="[TEST182][Standalone Without Previous Line]"
	N DESC S DESC=HDR_"[Standalone tags should not require a newline to precede them.]"
	S DESC=DESC_"whitespace succeding the tag should be left untouched]"
	S TEMPLATE="  {{>*dynamic}}\n>"
	S EXPECTED="  >\n  >>"
	S TEMPLATE=$$UNESCNL(TEMPLATE)
	S EXPECTED=$$UNESCNL(EXPECTED)
	N CTX 
	S CTX("dynamic")="partial"
	N CONF D SETUPPART(.CONF,.ROOT)
	N ERR D WRFILE(ROOT_"partial",$$UNESCNL(">\n>"),.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	D RMDIR(ROOT)
	Q	
TEST265 ;
	N CONF,CTX,TOK,OUT,ERR,S
	D START^MIOTPL2(.CONF)
	S CTX("meta","captureBlocks")=1
	S S="Body"_$C(10)_"  {{#block:head}}"_$C(10)_"  X"_$C(10)_"  {{/block:head}}"_$C(10)_"End"_$C(10)
	D COMPILE^MIOTPL2(S,.TOK,.ERR) I $D(ERR) W "FAIL TEST165 compile",! Q
	D EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR) I $D(ERR) W "FAIL TEST165 eval",! Q
	I OUT'=("Body"_$C(10)_"End"_$C(10)) W "FAIL TEST165 OUT=",OUT,! Q
	I $G(CTX("blocks","head"))'=("X"_$C(10)) W "FAIL TEST165 BLOCK=",CTX("blocks","head"),! Q
	Q
TEST266
	N CONF,CTX,TOK,OUT,ERR,S
	D START^MIOTPL2(.CONF)
	K CTX("blocks")
	S CTX("meta","captureBlocks")=0
	S S="S"_$C(10)_"  {{#block:head}}"_$C(10)_"  D"_$C(10)_"  {{/block:head}}"_$C(10)_"E"_$C(10)
	D COMPILE^MIOTPL2(S,.TOK,.ERR) I $D(ERR) W "FAIL TEST166 compile",! Q
	D EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR) I $D(ERR) W "FAIL TEST166 eval",! Q
	S EXPECTED=("S"_$C(10)_"  D"_$C(10)_"E"_$C(10))
	I OUT'=EXPECTED W "FAIL TEST166 OUT=",OUT,! Q
	Q
TEST267
	N CONF,CTX,TOK,OUT,ERR,S
	D START^MIOTPL2(.CONF)
	S CTX("blocks","head")="X"_$C(10)
	S CTX("meta","captureBlocks")=0
	S S="S"_$C(10)_"  {{#block:head}}"_$C(10)_"  D"_$C(10)_"  {{/block:head}}"_$C(10)_"E"_$C(10)
	D COMPILE^MIOTPL2(S,.TOK,.ERR) I $D(ERR) W "FAIL TEST167 compile",! Q
	D EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR) I $D(ERR) W "FAIL TEST167 eval",! Q
	I OUT'=("S"_$C(10)_"  X"_$C(10)_"E"_$C(10)) W "FAIL TEST167 OUT=",OUT,! Q
	I $G(CTX("blocks","head"))'=("X"_$C(10)) W "FAIL TEST167 BLOCK OVERWRITTEN=",CTX("blocks","head"),! Q
	Q
TEST000
	N HDR S HDR="[TEST000][]"
	N DESC S DESC=HDR_"[]"
	S TEMPLATE="""{{>text}}"""
	S EXPECTED=""
	N CONF,ROOT D SETUPPART(.CONF,.ROOT)
	N ERR 
	D WRFILE(ROOT_"text","from partial",.ERR)
	D OK^MIOTASSERT('$D(ERR),"write "_HDR) K ERR
	N CTX 
	SET CTX("text")="content"
	D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,CTX)
	; Run each spec test twice:
	;  1) Scalar template -> scalar output (existing high-perf path)
	;  2) Reference template OREF(n) -> reference output OREF(n) (GB-safe path)
	;N TOK,ERR,OUT
	;K TOK,ERR,OUT
	D COMPILE^MIOTPL2($G(TEMPLATE),.TOK,.ERR)
	D OK^MIOTASSERT('$D(ERR),"[COMPILE]"_HDR)
	D EVAL^MIOTPL2(.TOK,.CONF,.CTX,.OUT,.ERR)
	D OK^MIOTASSERT('$D(ERR),"[EVAL]"_DESC)
	D EQ^MIOTASSERT(OUT,$G(EXPECTED),"[RENDER]"_DESC)
	;I OUT=$G(EXPECTED) Q 
	;K CONF,HDR,DESC
	;W !
	;ZWR EXPECTED W !
	;W "     " ZWR OUT W !
	;ZWR TEMPLATE W !
	;ZWR TOK 
	;W "************************************",!
	;Q
	; Reference mode: build input chunks, compile+eval into output chunks
	;	
	N TOKR,ERRR,INROOT,OUTROOT,CHSZ,L,P,N,OUT2
	S INROOT=$NA(^TMP($J,"MIOTPLT","IN"))
	S OUTROOT=$NA(^TMP($J,"MIOTPLT","OUT"))
	K @INROOT K @OUTROOT
	S CHSZ=17  ; small chunk to stress boundary logic
	S L=$L($G(TEMPLATE))
	S N=0
	F P=1:CHSZ:L D
	. S N=N+1
	. S @($$APPREF^MIOTPL2(INROOT,N))=$E(TEMPLATE,P,P+CHSZ-1)
	K TOKR,ERRR
	D COMPREF^MIOTPL2(INROOT,.TOKR,.ERRR)
	D OK^MIOTASSERT('$D(ERRR),"[COMPREF]"_HDR)
	D EVALREF^MIOTPL2(.TOKR,.CONF,.CTX,OUTROOT,.ERRR)
	D OK^MIOTASSERT('$D(ERRR),"[EVALREF]"_DESC)
	S OUT2=""
	S N=0
	F  S N=$O(@($$APPREF^MIOTPL2(OUTROOT,N))) Q:'N  D
	. S OUT2=OUT2_$G(@($$APPREF^MIOTPL2(OUTROOT,N)))
	D EQ^MIOTASSERT(OUT2,$G(EXPECTED),"[RENDERREF]"_DESC)
	Q
RUNJSONSPECS(FP)
	N OK,TXT,ERR,TESTS,TXT
	N T,OK S OK=$$READFILE^MIOTPL2(FP,.TXT,.ERR)
	D DECODE^MIOJSON2($NA(TXT),$NA(TESTS))
	N A S A="" F  S A=$O(TESTS("tests",A)) Q:A=""  D
	. N HDR S HDR="["_TESTS("tests",A,"name")_"]"
	. N DESC S DESC=HDR_"["_TESTS("tests",A,"desc")_"]"
	. S TEMPLATE=TESTS("tests",A,"template")
	. S EXPECTED=TESTS("tests",A,"expected")
	. N CTX M CTX=TESTS("tests",A,"data")
	. D RUNTEST1(HDR,DESC,TEMPLATE,EXPECTED,.CTX)
	Q
RUNJSONSPECSPART(FP)
	N OK,TXT,ERR,TESTS,TXT
	N T,OK S OK=$$READFILE^MIOTPL2(FP,.TXT,.ERR)
	D DECODE^MIOJSON2($NA(TXT),$NA(TESTS))
	N A S A="" F  S A=$O(TESTS("tests",A)) Q:A=""  D
	. N HDR S HDR="["_TESTS("tests",A,"name")_"]"
	. N DESC S DESC=HDR_"["_TESTS("tests",A,"desc")_"]"
	. S TEMPLATE=TESTS("tests",A,"template")
	. S EXPECTED=TESTS("tests",A,"expected")
	. N CTX M CTX=TESTS("tests",A,"data") 
	. I TESTS("tests",A,"name")="Recursion",TESTS("tests",A,"desc")="The greater-than operator should properly recurse." D
	. . SET CTX("nodes",1,"nodes")=""  ; to match and pass test 102 
	. . ;(work around the JSON, as it is not able to process empty objects)
	. I TESTS("tests",A,"name")="Recursion",TESTS("tests",A,"desc")="Dynamic partials should properly recurse." D 
	. . SET CTX("nodes",1,"nodes")=""  ; to match and pass test 176
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
	N CMD
	S CMD="mkdir -p "_$$SHQ(PATH)
	ZSY CMD
	Q
RMDIR(PATH) ; rm -rf PATH (best-effort)
	N CMD
	S CMD="rm -rf "_$$SHQ(PATH)
	ZSY CMD
	Q
SHQ(S) ; shell-quote
	; Wrap in single quotes; escape single quotes safely: ' -> '\'' (close, escape, reopen)
	N X S X=$G(S)
	I X["'" S X=$$REPLQ(X)
	Q "'"_X_"'"
REPLQ(S) ; replace ' with '\'' for shell single-quote context
	N OUT,P,F
	S OUT="",P=1
	F  D  Q:P>$L(S)
	. S F=$F(S,"'",P)
	. I 'F S OUT=OUT_$E(S,P,$L(S)),P=$L(S)+1 Q
	. S OUT=OUT_$E(S,P,F-2)_"'\''"
	. S P=F
	Q OUT
	;