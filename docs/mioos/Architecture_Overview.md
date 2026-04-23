# MIOOS Architecture Overview

## Product shape
MIOOS is a secure application workspace and runtime shell for MUMPS modernization.

## Active runtime surfaces
- Home explorer
- Terminal
- Transfers
- Customize
- Folder Properties
- File viewers

## Frontend architecture
- SSR-authored shell markup
- Thin Vue runtime
- Window manager module
- Explorer/VFS module
- Transfer manager module
- Customization engine
- Shared shell primitives

## Server contract
The server remains the authority for boot state, routes, auth/session data, VFS roots, theme catalog, workspaces, and launcher entries.

## Styling architecture
- Base shell styles: `public/mioos/mioos.css`
- Focused rewrite layer: `public/mioos/mioos_reset.css`
- Transitional `7.scoped.css`: removed from active runtime loading

## Security architecture
- Least-privilege VFS checks
- Session-aware auth model
- Audit hooks for sensitive operations
- Explicit sharing metadata for folders

## Migration strategy
Incremental migration without destabilizing the websocket/VFS/auth core. The product surface is narrowed first, then internal cleanup continues in follow-on work.