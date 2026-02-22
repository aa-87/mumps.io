# MIOTPL “5-minute success”

This is the smallest, fastest path to seeing MIOTPL render a real page with a layout, partials, and list data.

## 1) Copy files

Copy the starter kit templates:

- `starter-kit/templates/*` → your project `templates/` folder
- `starter-kit/routines/MIOTPL5MIN.m` → your `routines/` folder

Ensure `MIOTPL.m` is available in your routine path.

## 2) Run in YottaDB / GT.M

In a M prompt:

```mumps
ZL "MIOTPL","MIOTPL5MIN"
D RUN^MIOTPL5MIN
```

Expected: a full HTML page printed to stdout.

## 3) What you just proved

- Layout + page composition (`RENDERPAGE^MIOTPL`)
- Blocks (`{{#block:title}}...`) set by the page and expanded by the layout
- Partials (`{{> ui_card}}`)
- Lists + inverted sections

Next step: copy `MIOTPL5MIN` patterns into your web server route handlers.
