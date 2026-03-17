# MIOUI Layout Diversity Plan

ROI 21 expands MIOUI with a diverse set of dense layout structures for high-intensive data applications.

## Goal

Ship reusable layout surfaces that cover very different operator workflows without forcing one shell style on every product.

## New layout patterns

1. **Master-detail cockpit**
   - left queue
   - center detail canvas
   - right context rail
   - best for claim review, queue triage, and exception handling

2. **Queue board matrix**
   - card lanes with compact metrics
   - dense header controls
   - quick movement between stages
   - best for work distribution and status control

3. **Ledger tape layout**
   - fixed summary tape
   - dense tabular middle pane
   - audit strip below
   - best for finance, remittance, and billing ledgers

4. **Document review theater**
   - large center document pane
   - synchronized evidence sidebar
   - decision footer
   - best for audits, attachments, and coding review

5. **Map-table context fusion**
   - list and map-like context side by side
   - useful even when the right pane is not a literal map, but a contextual surface
   - best for routing, regional workloads, and network operations

6. **Escalation ring layout**
   - urgent center stack
   - surrounding support rails
   - incident and supervisor use

## Contracts

All layout surfaces are view-model driven.

- `TCTX("layoutDiversity","title")`
- `TCTX("layoutDiversity","pattern",n,...)`
- `TCTX("layoutDiversity","callback",...)`
- `TCTX("layoutDiversity","metric",...)`

## Test shape

- smoke render from `pages/mioui_layout_diversity.html`
- component token coverage in `MIOUIT008`
- ROI contract tests in `MIOUIT031`

## Next likely ROI

- temporal layouts
- operator handoff timelines
- cross-application shell federation
