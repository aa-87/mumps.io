# ROI 64C redo 2 — Advanced table hardening and WebSocket-first table transport

This ROI redoes the previous advanced table work from the attached source and addresses the reported production blockers directly.

## Fixes delivered

1. **Mutation no longer leaves the editor hanging on HTTP 403.**
   - Table mutations are WebSocket-first through `table.mutate`.
   - HTTP remains a fallback route for environments where WebSocket commands are unavailable.
   - Domain-level table mutation failures now return a JSON payload that the table can render as an inline error instead of leaving the UI in a permanent saving state.
   - Read-only datasets such as `massive` and `vfs` publish server feature flags that disable row/column mutation controls.

2. **The edit-row panel no longer gets cut off.**
   - The row/column editor is now a modal dialog with a fixed viewport backdrop.
   - The editor uses `max-height: calc(100vh - 54px)` and internal scrolling so it remains usable in short windows.

3. **Massive dataset performance is server-side and page-materialized.**
   - `massive` no longer builds and copies all 10,000 rows before paging.
   - `MIOOSTBL` now generates schema, totals, sort keys, and only the requested page rows for the current query.
   - The dataset remains read-only so mutations cannot accidentally force a synthetic large dataset into per-user persistent globals.

4. **The table is denser for data-intensive screens.**
   - Default table density is now `compact`.
   - Toolbar, cells, pager, and actions use smaller spacing while retaining readable contrast.

5. **The Actions column is resizable.**
   - The table now has an `actionsWidth` config value.
   - The Actions header includes its own resize grip.

6. **The unexplained Timeline group row is removed by default.**
   - Column group headers are now behind `features.columnGroups` and default to disabled.
   - The normal header row only shows actual fields plus Actions.

7. **Debug noise is removed from the visible UI.**
   - The footer no longer shows draw numbers or last-response timestamps.
   - Draw/start/length remain internal protocol fields only.

8. **Table API variations are now visible and documented.**
   - `mioos-surface-table-showcase` provides simple, dense, editable, patient-registration, and massive read-only table examples.
   - Each variation includes copyable `MIOOSTable.createConfig(...)` code.

## Current contract

The client-visible contract is now:

```text
mioos-advanced-table-v5
```

The preferred transport is WebSocket command mode:

```text
table.query
table.mutate
```

HTTP remains available as fallback:

```text
POST /api/mioos/table/query
POST /api/mioos/table/mutate
```

## Example

```javascript
this.openBackendTableWindow({
  title: 'Dense Operations',
  dataset: 'demo',
  config: MIOOSTable.createConfig({
    density: 'compact',
    transport: 'websocket',
    defaultPageSize: 50,
    actionsWidth: 132,
    features: {
      search: true,
      filters: true,
      rowCrud: true,
      columnCrud: true,
      selection: true,
      bulkActions: true,
      resizeColumns: true,
      columnGroups: false
    }
  })
});
```

## Guardrails

- WebSocket is preferred for table query/mutation because the user requested high-performance table communication over the existing socket architecture.
- VFS uploads already have WebSocket upload commands (`fs.upload.begin`, `fs.upload.chunk`, `fs.upload.batch`, `fs.upload.commit`) and are not rewritten in this ROI.
- HTTP routes remain for compatibility, diagnostics, and fallback.
- Synthetic massive rows are read-only and generated page-by-page.
