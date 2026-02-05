
the following tests are failing:
test123-{{#cats.items}}{{.}};{{/cats.items}}-FAIL: dotted list: got=; expected=Core;Tools;
test124-{{#packages}}{{slug}}-{{name}};{{/packages}} [CTX("packages",1,"slug")="mio-web",CTX("packages",1,"name")="Web Server"]- FAIL: packages obj: got=-; expected=mio-web-Web Server;
test125-{{^packages}}NONE{{/packages}}{{#packages}}YES{{/packages}}-[SET CTX("packages",1,"name")="Pkg1"] - FAIL: inverted suppressed when list has items: got= expected=YES
test126-{{#groups.items}}G={{name}}:[{{#members}}{{name}},{{/members}}{{^members}}EMPTY{{/members}}];"{{/groups.items}}- [SET CTX("groups","items",1,"name")="Core",SET CTX("groups","items",1,"members",1,"name")="Alice",SET CTX("groups","items",1,"members",2,"name")="Bob",SET CTX("groups","items",2,"name")="Tools" - FAIL: deep nested render: got=G=:[, expected=G=Core:[Alice,Bob,];G=Tools:[EMPTY];  ERR("code")="TPL_LIMIT"
ERR("msg")="Render exceeded safety frame limit."
