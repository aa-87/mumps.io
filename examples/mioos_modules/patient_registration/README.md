# Patient Registration Module Sample

This sample demonstrates a MIOOS module backed by `MIOOSTBL` with HTTP-first table data and mutation routes.

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
