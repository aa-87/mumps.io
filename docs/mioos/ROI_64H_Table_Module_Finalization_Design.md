# ROI 64H — Table Module Finalization and Server-Side Module Library

This is a design document only. Do not implement ROI 64H until the table stabilization fixes are confirmed by `ZLINK` and `D ^MIOOST`.

## Reference

Use the existing server-side patterns in `MIOPLGD` as the reference for module completeness. The important patterns are server-authored and MUMPS-first:

- save/update APIs that validate payloads before persistence;
- search and filtered listing APIs;
- import/export APIs;
- revision snapshots before overwrite;
- revision lookup and rollback;
- compact JSON transport with deterministic error payloads;
- server-side metadata rather than frontend-only state.

ROI 64H should apply those patterns to table-backed module definitions and the App Catalogue/module registry. It should not introduce a SPA build step, TypeScript, or a frontend-only authoring model.

## Goal

Finalize table-backed modules so a MUMPS developer can define, validate, preview, export, import, version, roll back, and register a table module without writing frontend code.

## Proposed backend scope

1. Add a table-module definition service, likely in `MIOOSMOD` or a dedicated routine such as `MIOOSMTBL`.
2. Persist table-backed module definitions server-side with deterministic IDs.
3. Validate dataset key, module key, title, icon, category, surface, component key, schema, validation rules, and sample rows before save.
4. Add server-side preview/dry-run endpoint that returns the table manifest and sample query response without committing data.
5. Add export/import for table module definitions, including schema, validation, module metadata, and optional sample rows.
6. Add revision snapshots before overwrite and rollback to an earlier module definition.
7. Add search/filter/list APIs for table-backed modules in the App Catalogue.
8. Add audit metadata for module definition changes.
9. Keep frontend work thin: the browser should call server APIs and render server-authored state.

## Proposed UI scope

1. App Catalogue view for table-backed modules.
2. Module definition editor using existing system draggable windows.
3. Preview table before save.
4. Import/export actions.
5. Revision list and rollback confirmation.
6. Clear validation errors with field-level messages.

## Acceptance criteria

- A table-backed module can be created entirely from MUMPS globals or through the module editor.
- Invalid metadata cannot corrupt the registry.
- A module definition can be exported, imported, versioned, and rolled back server-side.
- The App Catalogue can search/filter table modules.
- The implementation follows MIOOS server-authored architecture and uses existing `MIOPLGD` server-side completeness patterns as reference.
- `D ^MIOOST` includes tests for validation, save, export, import, revision, rollback, and catalogue listing.
