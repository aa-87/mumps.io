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
