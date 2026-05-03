# ROI 64H — Table Module Finalization and Server-Side Module Library

ROI 64H turns table-backed modules into a server-side module library. The implementation follows the existing MIOOS architecture: MUMPS owns persistence, validation, export/import, revisions, rollback, and registry installation; the browser is a thin editor and launcher.

## Contract

Server API route:

```text
POST /api/mioos/modules/table
```

WebSocket commands:

```text
module.table.list
module.table.preview
module.table.save
module.table.export
module.table.import
module.table.revisions
module.table.rollback
```

All responses use the contract:

```text
mioos-table-module-library-v1
```

## Storage

Definitions are stored per user:

```mumps
^MIO("MIOOS","TABLEMOD","USER",user,moduleKey,...)
^MIO("MIOOS","TABLEMOD","REV",user,moduleKey,revisionId,...)
```

A successful save installs the launchable module and table dataset:

```mumps
^MIO("MIOOS","MODULE","USER",user,moduleKey,...)
^MIO("MIOOS","TABLE",user,dataset,...)
```

## Supported actions

### list

Returns searchable table module summaries for the App Catalogue.

### preview

Validates the definition and returns a dry-run module manifest plus a compact sample table query shape without writing globals.

### save

Validates the definition, snapshots the previous definition when overwriting, stores the new definition, installs the table dataset, and registers the launchable module.

### export

Returns the stored definition as deterministic JSON so it can be copied, reviewed, or committed.

### import

Validates imported JSON and then saves/registers it through the same server path.

### revisions

Lists server-side snapshots captured before overwrites and rollbacks.

### rollback

Snapshots the current definition, restores a selected revision, reinstalls the table dataset, and re-registers the module.

## Minimal definition

```json
{
  "action": "save",
  "definition": {
    "key": "example_table",
    "title": "Example Table",
    "dataset": "example_table",
    "category": "Operations",
    "icon": "▤",
    "description": "Server-authored table module",
    "schema": {
      "columns": [
        { "key": "name", "label": "Name", "type": "text", "width": 220 },
        { "key": "status", "label": "Status", "type": "select", "width": 140 },
        { "key": "updated", "label": "Updated", "type": "date", "width": 150 },
        { "key": "notes", "label": "Notes", "type": "textarea", "width": 260 }
      ]
    },
    "validation": {
      "fields": {
        "name": { "required": 1, "maxLength": 120 },
        "status": { "required": 1, "enum": ["Active", "Pending", "Review"] },
        "updated": { "date": 1 },
        "notes": { "maxLength": 2048 }
      }
    },
    "rows": [
      { "id": "example-1", "name": "Demo row", "status": "Active", "updated": "2026-05-02", "notes": "Created from ROI 64H." }
    ]
  }
}
```

## MUMPS-first save path

MUMPS code can call the service directly:

```mumps
NEW STATE,CONF,IN,OUT,ERR
SET STATE("principal")="developer"
SET IN("action")="save"
SET IN("definition","key")="ops_queue"
SET IN("definition","title")="Operations Queue"
SET IN("definition","dataset")="ops_queue"
SET IN("definition","category")="Operations"
SET IN("definition","icon")="▤"
SET IN("definition","schema","columns",1,"key")="name"
SET IN("definition","schema","columns",1,"label")="Name"
SET IN("definition","schema","columns",1,"type")="text"
SET IN("definition","schema","columns",2,"key")="status"
SET IN("definition","schema","columns",2,"label")="Status"
SET IN("definition","schema","columns",2,"type")="select"
SET IN("definition","validation","fields","name","required")=1
SET IN("definition","validation","fields","status","enum",1)="Active"
SET IN("definition","validation","fields","status","enum",2)="Pending"
SET IN("definition","rows",1,"id")="ops-1"
SET IN("definition","rows",1,"name")="First item"
SET IN("definition","rows",1,"status")="Active"
DO HANDLE^MIOOSMTBL(.STATE,.CONF,.IN,.OUT,.ERR)
```

After save, the App Catalogue shows the module and opening it launches `mioos-surface-table` for the saved dataset.

## Validation

Invalid keys, missing titles, missing columns, duplicate column keys, and malformed column keys fail before registry or table globals are changed. API failures return `fieldErrors` for the thin browser editor.

## Reload and test

```mumps
ZLINK "MIOOSMTBL"
ZLINK "MIOOSMOD"
ZLINK "MIOOSAPI"
ZLINK "MIOOSWS"
ZLINK "MIOOS"
ZLINK "MIOOSST"
ZLINK "MIOOST"
DO ^MIOOST
```
