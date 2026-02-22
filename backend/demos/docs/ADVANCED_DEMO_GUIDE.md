# Advanced demo (“wow factor”) guide

The advanced demo is an example app that shows off MIOTPL’s strongest features:

- Layout + block inheritance
- Component partials (cards, metrics, tables)
- Dynamic partial selection (`{{> *component}}`)
- A “Template Playground” page concept (server renders user templates **without** enabling lambdas)

## Files

- `advanced-demo/routines/MIOWOW.m` – route registration + handlers
- `advanced-demo/templates/*` – layouts/pages/partials

## How to integrate

1) Copy templates into your `templates/` folder (keep the same subfolders).

2) Copy `MIOWOW.m` into your routine path.

3) In your startup routine, call:

```mumps
D REG^MIOWOW(.CONF)
```

This registers routes like:

- `GET /wow` – dashboard
- `GET /wow/playground` – playground UI
- `POST /wow/api/render` – render endpoint

## Safety notes

- The render endpoint must **never** accept lambda values from users.
- If you accept user templates, enforce size limits and recursion limits.
- For large pages, prefer `RENDERX^MIOTPL` mode `AUTO`.
