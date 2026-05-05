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

## Checkpoint stabilization 2026-05-05 upload encoding contract

Explorer uploads must persist bytes, not DataURLs. HTTP binary chunk upload is the preferred route. WebSocket fallback for binary files uses `encoding=base64`, stores raw byte counts for transfer accounting, and decodes base64 chunks before committing the file into `^MIO("MIOOS","FS","DATA",...)`. Legacy DataURL read encodings may still exist for old API compatibility, but new upload and persisted image paths must not depend on DataURLs.
