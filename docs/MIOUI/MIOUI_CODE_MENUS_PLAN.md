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

## Why this ROI matters

Typical billing and operator software needs many code-menu shapes, not one flat CRUD table.
This ROI expands the page into the most common production variants:

- single-table maintenance
- nested hierarchy maintenance
- payer/local crosswalks
- extensible custom fields
- future-dated versions
- conditional rule management
- spreadsheet-driven bulk updates
- governed retirement and delete review
- audit recovery

## Next high-ROI code-menu work

Good next steps after this ROI:

1. inline row editor variants
2. side-drawer add/edit forms
3. compare-and-merge code set review
4. code-set approval queue variants
5. drag-and-drop hierarchy reorder surfaces
6. large code-menu pagination and saved views
