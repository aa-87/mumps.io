# MIOMOS ROI31 — Shell Behavior Hardening

## Goal

Tighten the MIOMOS shell so it behaves more like a real desktop and less like a reactive demo.

This ROI focuses on:

- stable taskbar ordering
- predictable Start menu section ordering
- separating taskbar order from window z-order
- preserving taskbar slots through focus, minimize, restore, and layout persistence

## What changed

### Taskbar order

The taskbar no longer sorts items by live `z` value.

Instead, each window now carries a dedicated `taskOrder` slot that is:

- seeded from server-authored default windows
- restored from saved layouts
- normalized on boot/load if missing or duplicated
- preserved when windows are focused, minimized, restored, or reopened

This fixes the undesirable behavior where clicking one taskbar item could reshuffle the rest of the strip.

### Start menu predictability

Start menu sections now sort their entries by the server-authored `order` field inside each section bucket.

This keeps Programs / Directories / Applications / System / Planned sections more predictable and muscle-memory-friendly.

### Boot and test contract

The boot payload now exposes:

- `desktop.taskbarBehavior = stable-order`
- `desktop.taskbarFocusPolicy = focus-without-reorder`
- `desktop.startMenuBehavior = predictable-sections`

The SSR output also includes explicit render tokens describing the new shell behavior so it stays test-backed.

## Why this ROI matters

The shell is now far enough along that correctness bugs in everyday interaction matter more than adding another visual feature.

Stable taskbar behavior is one of those core correctness expectations.
