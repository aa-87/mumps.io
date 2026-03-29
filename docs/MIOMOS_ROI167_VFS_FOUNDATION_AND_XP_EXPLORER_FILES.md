# MIOMOS ROI 167 — Per-user VFS foundation and XP Explorer file surfaces

## Goal
Lay the first production-minded virtual filesystem layer under the XP shell without touching local server disk. Files, folders, and metadata are now seeded per user in globals and exposed into Explorer windows as server-authored data.

## What this ROI adds
- `MIOMOSVFS` routine for per-user globals-backed virtual filesystem seeding
- boot contract metadata for VFS storage, ownership, and roadmap
- view-model exposure for VFS roots, entries, summary counts, and permissions
- XP Explorer windows now show seeded virtual folders and files under:
  - My Documents
  - My Computer
  - My Network Places
  - UI Samples
- explicit shell copy for the next transfer wave

## Storage model
- globals only
- per user
- no server local disk dependency
- metadata-first foundation so upload/download can be added without reworking the desktop shell

## Why this comes before upload/download
Local upload and browser download need a stable target model first:
- which folders accept uploads
- which artifacts are downloadable
- which actions are permission-gated
- how Explorer represents files vs folders

This ROI answers that first, then stages transport work next.

## Next ROI wave
- ROI 168 — browser drag/drop + picker upload into VFS
- ROI 169 — browser save/download and drag-out bridge from VFS
- ROI 170 — shell verbs for copy, cut, paste, and move within VFS
- ROI 171 — MUMPS development platform assets inside the VFS (routines, globals snapshots, exports)
