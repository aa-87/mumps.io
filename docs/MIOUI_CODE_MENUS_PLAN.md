# MIOUI code menus plan

## Current implemented surfaces

The code-menu lab now covers these SSR-first variants on `/mioui/code-menus`:

- master catalog
- hierarchy control
- crosswalk workspace
- custom field studio
- effective dating studio
- dependency rules
- import staging workspace
- retirement and delete control
- inline row editor
- side-drawer editor
- compare and merge review
- approval queue
- change history
- variant matrix

## Current workflow coverage

The current page explicitly renders callback tokens for:

- addCodeRow
- editSelectedCode
- deleteSelectedCodes
- searchCodeCatalog
- reorderCodeSet
- saveCodeCustomFields
- openCodeChangeHistory
- exportCodeMenuView
- scheduleCodeEffectiveDate
- publishFutureCodeVersion
- saveCodeDependencyRules
- previewDeleteImpact
- archiveRetiredCodes
- importCodeSetSpreadsheet
- validateImportedCodeRows
- commitImportedCodes
- openInlineCodeEditor
- saveInlineCodeRow
- openCodeSideDrawer
- createCodeMenuEntry
- compareIncomingCodeSet
- mergeSelectedCodeDiffs
- submitCodeApprovalBatch
- approveCodeChangeSet
- rejectCodeChangeSet

## Why this ROI matters

Typical billing and operator software needs many code-menu shapes, not one flat CRUD table.
This ROI expands the page into the next common production variants:

- spreadsheet-like inline editing
- contextual side-drawer add/edit forms
- controlled compare-and-merge review for imported or promoted code sets
- approval queues for governed code changes

These are common in payer mapping, denial routing, reason-code maintenance, and multi-role setup workflows.

## Next high-ROI code-menu work

Good next steps after this ROI:

1. drag-and-drop hierarchy reorder surfaces
2. saved-view and pagination variants for large code menus
3. multi-lingual and alias label maintenance
4. formula/default-rule editors
5. effective-date timeline visualization
6. row-level permission and ownership overlays
