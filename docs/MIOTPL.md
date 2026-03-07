# MIOTPL template engine

MIOTPL is a Mustache template engine written in MUMPS.

It aims to match moustache.js behavior for the Mustache core.

It is designed for web pages and internal tools.

It is deterministic.

It is heavily tested.

The test harness is `MIOTPLT`.

---

## Quick start

The simplest render looks like this.

```mumps
N CONF,CTX,OUT,ERR
M CONF=^MIO("CONF")
S CONF("server","templateDir")="templates"
S CTX("name")="World"
D RENDER^MIOTPL("hello",.CONF,.CTX,.OUT,.ERR)
I $D(ERR) W "ERR=",ERR("error"),! Q
W OUT,!
```

You can also precompile templates at startup.

```mumps
N CONF
M CONF=^MIO("CONF")
D START^MIOTPL(.CONF)
D PRECOMPILE^MIOTPL(.CONF)
```

---

## Template discovery

Templates are loaded from a directory.

Most deployments use `CONF("server","templateDir")`.

Example:

```mumps
S ^MIO("CONF","server","templateDir")="templates"
```

A template name usually maps to a file under that directory.

For example, `hello` typically maps to `templates/hello.html`.

---

## Core Mustache features

### Variables

Template:

```mustache
Hello {{name}}!
```

Context:

```mumps
S CTX("name")="World"
```

Output:

```
Hello World!
```

### HTML escaping

Double braces escape HTML.

Triple braces do not escape.

Template:

```mustache
<p>{{name}}</p>
<p>{{{name}}}</p>
```

Context:

```mumps
S CTX("name")="<b>Alice</b>"
```

Output:

```html
<p>&lt;b&gt;Alice&lt;/b&gt;</p>
<p><b>Alice</b></p>
```

### Sections

A section renders when the value is truthy.

Template:

```mustache
{{#user}}Hello {{name}}!{{/user}}
```

Context:

```mumps
S CTX("user","name")="Sam"
```

Output:

```
Hello Sam!
```

### Inverted sections

An inverted section renders when the value is missing or false.

Template:

```mustache
{{^items}}No items.{{/items}}
```

Output:

```
No items.
```

### Lists and iteration

If a section value is a list, the block repeats.

Template:

```mustache
{{#items}}- {{.}}
{{/items}}
```

Context:

```mumps
S CTX("items",1)="one"
S CTX("items",2)="two"
```

Output:

```
- one
- two
```

### Dotted names

Template:

```mustache
User: {{user.name}}
```

Context:

```mumps
S CTX("user","name")="Rita"
```

Output:

```
User: Rita
```

### Partials

Partials let you reuse templates.

Main template:

```mustache
<h1>{{title}}</h1>
{{> card}}
```

Partial `card`:

```mustache
<div class="card">{{text}}</div>
```

Context:

```mumps
S CTX("title")="Home"
S CTX("text")="Welcome"
```

Output:

```html
<h1>Home</h1>
<div class="card">Welcome</div>
```

---

## Indentation rules

Mustache has indentation rules for partials.

If you indent the partial tag, the partial lines are indented.

Example:

```mustache
<ul>
  {{> item}}
</ul>
```

Partial:

```mustache
<li>{{name}}</li>
```

Output:

```html
<ul>
  <li>...</li>
</ul>
```

---

## Delimiter changes

Mustache supports delimiter changes.

This is useful when your text contains `{{`.

Example:

```mustache
{{=<% %>=}}
Hello <%name%>!
<%={{ }}=%>
Bye {{name}}!
```

---

## Lambdas

MIOTPL supports Mustache-style lambdas.

A lambda is a callable value in the context.

In this implementation, it is represented as a string that starts with `$$`.

Example context:

```mumps
S CTX("name")="$$NAME^MYLAM"
```

Example lambda routine:

```mumps
MYLAM ;
NAME() Q "World"
```

Example template:

```mustache
Hello {{name}}!
```

This calls `$$NAME^MYLAM()` at render time.

---

## Layouts and pages

MIOTPL exposes helper entry points for pages and layouts.

These entry points are listed in the routine header.

A common pattern uses a layout and a page.

Layout template example:

```mustache
<!doctype html>
<html>
  <head>
    <title>{{title}}</title>
  </head>
  <body>
    {{> body}}
  </body>
</html>
```

Body template example:

```mustache
<h1>{{title}}</h1>
<p>{{message}}</p>
```

---

## Performance and caching

MIOTPL caches compiled templates in globals.

This makes repeated renders fast.

If you change templates on disk, you may need to clear the cache.

Your test suites show the correct patterns.

---

## moustache.js compatibility checklist

This checklist is a practical guide.

It helps you verify compatibility during releases.

| Feature | Status in MIOTPL | Notes |
|---|---|---|
| Variables `{{name}}` | Supported | Escapes HTML by default. |
| Unescaped `{{{name}}}` | Supported | Renders raw text. |
| Sections `{{#name}}` | Supported | Works with truthy values and lists. |
| Inverted sections `{{^name}}` | Supported | Runs when false or missing. |
| Dotted names `a.b.c` | Supported | Uses nested context lookup. |
| Partials `{{> name}}` | Supported | Includes indentation rules. |
| Set delimiters `{{=<% %>=}}` | Supported | Verify with `MIOTPLT`. |
| Comments `{{! ... }}` | Supported | Comments should not render output. |
| Lambdas | Supported | Uses `$$LABEL^ROUTINE` call style. |
| Layout helpers | Supported | Uses `RENDERPAGE` and `RENDERLAYOUT`. |
| Caching | Supported | Uses globals cache. |

The source of truth is always the test suite.

Run `^MIOTPLT` after every change.

---

## Practical patterns

### Render HTML in a handler

This is a common pattern.

```mumps
PAGE(DEV,CONF,REQ,CTX)
  N TCTX,OUT,ERR
  M TCTX=CTX
  S TCTX("title")="Home"
  D RENDER^MIOTPL("home",.CONF,.TCTX,.OUT,.ERR)
  I $D(ERR) D RESPJSON^MIOHTTP(.DEV,500,"ERR","{\"error\":\"template\"}",.CTX) Q
  D RESP^MIOHTTP(.DEV,200,"OK","text/html; charset=utf-8",OUT,.CTX)
  Q
```

