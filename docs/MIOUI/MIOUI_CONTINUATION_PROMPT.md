# MIOUI Continuation Prompt

You are continuing a real, production-minded MUMPS.IO project inside an existing repo.

The repo is attached.
Assume **all current tests are passing** at the start of this new chat.
Assume the repo already contains a large, evolving **MIOUI** package built on top of my existing MUMPS web stack.

Your job is to continue development **carefully, methodically, and incrementally**.
Do not reset, rewrite, or simplify the project.
Do not replace working foundations with generic abstractions.
Extend the current architecture.
Preserve passing behavior.

---

# 1. Core project context

I have built a high-performance web server in MUMPS.
This repo includes:

- the **MIO** web server stack under routines prefixed with `MIO*`
- a billing-oriented product/application under `EFUZY*`
- a product/marketing/public surface under `FUZ*`
- a server-side rendering template engine under `MIOTPL*`
- tests for most routines, usually with names ending in `T`
- a large in-progress UI system named **MIOUI**

The front end is rendered with **MIOTPL**.
The UI system is being built on top of **Tailwind CSS**.
The goal is a dense, high-performance, reusable UI layer optimized for:

- billing software
- data-intensive applications
- queue-heavy operator workflows
- review screens
- diagnostics
- trace/audit screens
- large tables
- dense multi-pane workspaces
- auth/forms
- reusable layout systems

This is **SSR-first**, **MUMPS-first**, and **high-performance-first**.

---

# 2. Technical stack and assumptions

Assume the repo contains and uses these modules and patterns:

## Core server stack
- `MIOHTTP` for HTTP parsing / response handling
- `MIOROUTE` for route registration / matching
- `MIOMW` for middleware
- `MIOTPL` for Mustache/MIOTPL rendering
- route/page rendering patterns already used in `MIO`, `EFUZY`, `FUZ`, and `MIOUI`

## Rendering model
- SSR-first
- minimal browser JS
- MIOTPL templates and partials
- dense Tailwind-based shells and page patterns
- reusable partials, not page-specific duplication

## Testing model
- quiet on success
- failures printed explicitly
- numbered `MIOUIT###` test routines exist for MIOUI
- current state is **passing** before any new work starts

---

# 3. Critical working style requirements

These are not optional.
Follow them exactly.

## 3.1 Preserve working state
- Assume current repo state is good and passing.
- Do not “clean up” by rewriting working routines.
- Do not replace working route registration or registry logic unless absolutely necessary.
- Do not break old pages to add new pages.

## 3.2 Always work incrementally
- Add the next ROI as a **layer**, not a reset.
- Reuse the current MIOUI architecture.
- Extend existing registries, runners, pages, partials, and docs.

## 3.3 Be careful with generated files
In a prior chat, some “delta” files were generated as incomplete stubs.
That caused routine replacement problems.
To avoid that:

- when changing an existing routine, provide a **full replacement** of that routine, not a fragment
- when changing an existing template, provide a **full replacement** of that template, not a fragment
- new files can be added normally
- avoid partial routine snippets that omit labels, helper functions, or formal parameter lists

## 3.4 Output discipline
Unless I explicitly ask otherwise:

- **only provide changed files and new files**
- prefer **changes-only bundles**
- keep docs updated as ongoing living documentation
- namespace MIOUI tests under `MIOUIT###`

## 3.5 Test discipline
- every new component/page/combined surface needs test coverage
- every new ROI must include:
  - updated registry coverage if needed
  - render smoke coverage if needed
  - numbered `MIOUIT###` coverage
- do not lower test quality just to make tests pass
- if a test assumption is stale because a component moved from planned to implemented, update the test honestly and clearly

---

# 4. Current MIOUI project shape

MIOUI already exists and has been extended through many ROI passes.
You should inspect the attached repo to confirm exact file contents, but assume the current MIOUI package already includes:

## Foundation / general UI
- app shell and layout system
- page headers
- panels, cards, badges, buttons
- form primitives
- stat strips
- empty states
- navigation helpers
- theme/density ideas

## Dense data / workflow surfaces
- table-related components
- dense data grid work
- detailed data-table work
- large-table and million-row table components
- selection summaries
- table insights
- filter surfaces
- sort/order/paging contracts
- row expansion and related table patterns

## Billing / review / trace / workflow
- billing review surfaces
- diagnostics and artifact group surfaces
- trace and audit surfaces
- workflow polish surfaces
- export/profile editor related work

## Layout systems
A large amount of work has already been done on layout systems for dense data applications, including multiple families of layouts.
Do not duplicate them blindly.
Inspect and extend them.

## Auth / forms
The roadmap has now shifted toward:
- login/signup
- reset/forgot password
- MFA
- multi-step onboarding
- dense advanced filter forms
- inline validation summaries
- reusable auth/form shells and combinations

---

# 5. MIOUI architectural principles

Preserve these principles.

## 5.1 MIOUI is SSR-first
Do not turn this into a SPA framework.
Do not create heavy client-side state machines unless explicitly required.

## 5.2 MIOUI is view-model driven
The MUMPS routines should build the context.
The MIOTPL templates should render that context.
The browser should do minimal enhancement only.

## 5.3 MIOUI is reusable
Keep business-specific logic out of generic UI primitives when possible.
Use reusable components and reusable page/layout surfaces.

## 5.4 MIOUI is dense and professional
Optimize for:
- high information density
- scanability
- operator speed
- clear status hierarchy
- fast SSR
- stable table behavior

## 5.5 MIOUI must remain compatible with the existing stack
Do not introduce frameworks or assumptions that fight:
- MUMPS
- MIOTPL
- MIOROUTE
- MIO server routing/init patterns
- quiet-on-success testing

---

# 6. Important implementation guardrails

## 6.1 Route registration
Be extremely careful when touching route registration.
Past failures came from:
- missing formal parameter lists
- calling labels that did not exist
- registry/build naming mismatches
- page routes added without matching test smoke render support

Whenever you add a new page/route:
- make sure the registration label exists
- make sure the formal parameter list matches how it is called
- make sure the route handler exists
- make sure `MIOUIT008` or the equivalent smoke prep renders and caches the page if tests expect it

## 6.2 Registry consistency
Past failures also came from registry drift.
Whenever you add a new component/page:
- add or update the `MIOUIREG` entry
- make sure ids match the test expectations exactly
- make sure `status`, `phase`, and target template/page metadata are correct
- do not invent slightly different ids than the test suite expects

## 6.3 Template safety
Past failures also came from MIOTPL recursion and render limits.
Avoid:
- page/partial naming collisions
- recursive includes
- deep nested partial recursion
- overly heavy nested loops that stress MIOTPL

If a component is large, precompute heavy fragments in MUMPS and render them safely.

## 6.4 Full replacements for changed files
If you modify a routine or a template, provide the full file, not a patch fragment.

---

# 7. Current expectations for your work in this new chat

When I ask for the next ROI or a new feature, do the following:

1. **Inspect the attached repo first**
   - confirm the current MIOUI files
   - confirm the current registry state
   - confirm the current runner/test structure
   - confirm current route/page patterns

2. **Build on the actual repo state**
   - do not assume a generic scaffold
   - do not regenerate MIOUI from scratch

3. **Produce only changed/new files unless I explicitly ask otherwise**

4. **Provide full replacement contents for any file you change**

5. **Add tests under `MIOUIT###`**

6. **Update ongoing docs**
   Keep docs living and cumulative.

7. **Be honest about what you did and did not validate**
   If you did not run YottaDB here, say so clearly.

---

# 8. Recommended response format for implementation work

When you implement an ROI or fix, use this style:

## 8.1 Give a short, accurate summary
Example:
- what the ROI implements
- whether this is a changes-only bundle
- whether files are full replacements

## 8.2 Provide files cleanly
Prefer:
- changed file list
- new file list
- docs updated
- tests added/updated

## 8.3 If delivering a bundle, keep it coherent
It must:
- not omit dependencies
- not include half-finished stubs
- not replace core files with fragments

---

# 9. What to inspect in the repo before doing anything substantial

Please inspect at least these areas before major implementation:

## Routines
- `MIO*.m`
- `MIOTPL*.m`
- `EFUZY*.m`
- `FUZ*.m`
- `MIOUI*.m`
- `MIOUIT*.m`

## Templates
- `templates/layouts/*`
- `templates/pages/*`
- `templates/partials/*`
- especially any `mioui_*` files already present

## Docs
- MIOUI docs already created in `/docs`
- any roadmap / ROI / plan docs for MIOUI

## Tests
- current numbered MIOUI test suites
- any render smoke helper patterns
- registry coverage tests

---

# 10. Current handoff summary

At the start of this new chat, assume all tests are passing.
The repo already contains a substantial MIOUI package.
The next phase should continue methodically from that working state.

The current strategic focus is now:

## Primary focus
- login/signup UX
- auth-related forms
- reusable form combinations
- dense filter forms
- validation and onboarding form systems
- continued production-quality MIOUI evolution

## Secondary focus
- continue broadening reusable UI and page systems
- preserve previous dense-layout and data-intensive work
- keep the system suitable for billing and operational software

---

# 11. Immediate instruction for the new chat

Start by doing the following:

1. Inspect the attached repo carefully.
2. Summarize the current MIOUI state as it actually exists in the repo.
3. Confirm the current auth/forms files, routes, registry entries, and tests.
4. Identify the next highest-ROI auth/forms enhancement that fits the current architecture.
5. Implement it incrementally.
6. Provide only changed/new files.
7. Use full replacement contents for changed files.
8. Add or update `MIOUIT###` tests.
9. Update ongoing MIOUI docs.

Do not start from scratch.
Do not simplify the existing system.
Do not leave room for registry drift, route-label mismatches, or incomplete stub routines.
Be exact.

---

# 12. Optional guidance for feature style

The kinds of auth/form surfaces that are desirable next include:

- polished login shells
- signup variants
- organization/workspace invitation flows
- password reset variants
- MFA challenge variants
- account recovery flows
- profile completion forms
- dense preferences forms
- multi-column admin forms
- validation summaries
- progressive disclosure forms
- wizard/stepper forms
- approval/consent forms
- billing-oriented filter and search forms

These should all remain:
- SSR-first
- reusable
- dense
- professional
- test-covered

