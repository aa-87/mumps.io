# Patient Registration Module Sample

This sample demonstrates a MIOOS module backed by `MIOOSTBL` with WebSocket-first table data and mutation commands with authenticated HTTP fallback routes.

Dataset: `patient-registration`

Implemented capabilities:

- Server-side query through `/api/mioos/table/query`
- Server-side mutations through `/api/mioos/table/mutate`
- Patient row add/edit/delete
- Column add/edit/delete/resize
- Select all visible rows
- Bulk delete selected rows
- Grouping, search, pagination, and sorting

The sample is intentionally table-backed so future developers can copy the module manifest and replace the dataset or backend routine while preserving the shell integration contract.

## ROI 63 patient registration target

ROI 68 will turn this into a full end-to-end patient registration sample using the redesigned App Catalogue, table, and form systems. Required capabilities include authenticated module launch, backend CRUD persistence, row create/edit/delete, search/filter/sort, validation for required demographics and contact fields, audit-friendly status messages, and no PHI leakage before authentication.

This remains a developer sample. It may demonstrate a HIPAA-ready architecture pattern, but deployment and operations controls are still required before handling real PHI.
