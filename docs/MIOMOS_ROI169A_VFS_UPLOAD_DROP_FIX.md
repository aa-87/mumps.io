# MIOMOS ROI 169A — Native file drop into VFS folders

This hotfix turns browser file drops into real uploads for MIOMOS folder targets.

## Scope
- prevent native browser navigation on file drop
- add authenticated `POST /api/miomos/vfs/upload`
- store uploaded file metadata and content in per-user globals
- allow drops into upload-enabled VFS folders and custom `folder-*` desktop folders
- keep current terminal multi-window behavior unchanged

## Notes
- uploads are stored in globals under the per-user MIOMOS VFS tree
- custom desktop folders are materialized in the VFS on first upload
- client updates the live VFS list immediately and then refreshes the view
- new UI continues inheriting the active shell font family and size
