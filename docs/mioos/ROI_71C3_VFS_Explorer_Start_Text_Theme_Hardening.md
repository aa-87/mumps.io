# ROI 71C3 — VFS blob, Explorer windows, Start menu, text viewer, and Theme CSS hardening

## Goal

Fix the remaining persisted-background `ERR_CONTENT_LENGTH_MISMATCH`, keep login public image behavior safe, stop folder launches from reusing the same Explorer window, improve dark Start menu readability/defaults, prevent text viewers from hanging, and add custom CSS entry points for common Theme Studio surfaces.

## Implemented

- `/api/mioos/fs/blob` now repairs VFS file-size metadata from actual stored chunk byte length before sending `Content-Length`.
- VFS multipart writes now use byte length/extract operations, preventing new binary uploads from storing character-length metadata.
- Blob streaming uses repaired byte size for range and full responses.
- Public login image assets are served only through a dedicated public-login asset endpoint and normal theme assets remain protected.
- Opening a folder creates a new Explorer window, enabling side-by-side folder-to-folder workflows.
- Start menu Language, Themes, and System groups are open by default.
- Dark Start menu folder headings use readable text and dark-compatible surfaces.
- Text viewer falls back to the blob endpoint when command-based reads are unavailable or empty and always exits loading state.
- Theme Studio accepts custom CSS declarations for active titlebar, inactive titlebar, window body, taskbar, and start menu surfaces. Pasting declarations like `background: radial-gradient(...)` maps the background declaration to the corresponding live CSS variable.

## Validation

Static tests were added in `T076` to lock down the VFS size repair helper, FSBLOB repaired size usage, public login route preservation, separate Explorer folder windows, Start menu default groups, dark Start folder CSS, text viewer fallback, and Theme Studio custom CSS controls.

## Regression follow-up — direct file opens, viewer loop, dark/RTL hardening

This follow-up locks down the current source after the ROI 71C3/72C stabilization pass.

- The server default desktop theme is `glow` so a clean database and the shell state agree on first boot.
- Desktop VFS file entries route through `openFileViewerWindow()`, which dispatches images, media, PDF, structured text, and plain text directly to the matching viewer instead of opening Explorer for the file.
- Text and structured file viewers are WebSocket-first through `fs.read.range`/`fs.read`; the HTTP blob path is retained only when the socket command helper is unavailable.
- Media viewer chrome no longer displays nonfunctional File/Edit/Help menu buttons or repeats the file name. The viewer keeps native media controls and adds a functional Loop toggle.
- Stored VFS blobs whose first chunk is larger than the recorded default chunk size repair the chunk-size metadata before streaming, preventing short bodies under a larger `Content-Length`.
- Login warning images render as full-width banners instead of avatar-sized thumbnails.
- Theme Studio includes a Desktop background custom CSS textarea. Supported declarations include `background`, `background-image`, and `background-color`; these map to the active desktop wallpaper/background CSS variables.
- Dark theme overrides cover Theme Studio tabs, Explorer toolbars/panes/icon view/details view, Start Menu folder text, transfer overview text, and system modal titlebar contrast.
- Locale changes immediately apply `lang`, `dir`, `is-rtl`, and locale data attributes to the document/shell so RTL layout state no longer depends only on a page reload.

Regression coverage lives in `T077`; source-contract table coverage remains in `T078`.
