# MIOOS VFS Metadata Model

## Folder metadata fields
- `attributes.readOnly`
- `attributes.hidden`
- `attributes.shared`
- `sharing.scope` (`users` or `everyone`)
- `sharing.users` (CSV list)
- `customize.background`
- `customize.icon`
- `viewMode`
- `sortBy`
- `sortDirection`

## Derived metadata
- `sizeLabel`
- `contains.files`
- `contains.folders`
- `containsLabel`

## Semantics
- `readOnly` disables write/delete through metadata-aware permission checks.
- `shared` allows controlled read access based on scope and users.
- Customize data is persisted per folder and used by folder properties and explorer rendering.

## API and command contract
- HTTP: `/api/mioos/fs/setmeta`
- Websocket command: `fs.setmeta`

## Supported operations
- Folder property save
- Folder appearance persistence
- Sharing scope update
- View/sort preference persistence