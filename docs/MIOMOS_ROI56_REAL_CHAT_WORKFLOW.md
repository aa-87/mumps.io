# MIOMOS ROI56 — Real chat workflow with moderation and unread shell badges

## Goal
Turn the collaboration surface into a real user workflow instead of a single shared placeholder feed.

## Delivered
- direct-message room model keyed by user principals
- unread counters per principal and room
- server-authored chat metadata for rooms, directs, roster, and moderation state
- moderator delete flow with deleted markers preserved in history
- collaboration UI sidebar for channels and directs
- unread badges on collaboration quick launch and taskbar buttons

## Backend notes
- unread state is stored under `^MIO("MIOMOS","CHAT","READ",principal,room)`
- shared and direct room history remain under `^MIO("MIOMOS","CHAT",room,...)`
- websocket events now emit `chat.meta` after `hello`, `chat.fetch`, `chat.send`, and `chat.delete`

## Guardrails
- no second transport layer
- access control remains MUMPS-authored
- direct-message access is limited to participants or moderators
- guest stays shared-chat only
