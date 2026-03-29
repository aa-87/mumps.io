# MIOMOS ROI37 terminal cursor default-off and CSS-safe xterm

This pass keeps the working YottaDB/xterm terminal runtime intact and narrows the remaining polish issue to cursor behavior.

## Changes
- Default terminal cursor blink is now off.
- xterm terminal subtree is exempted from MIOMOS reduced-motion animation compression.
- xterm cursor blink animation, when enabled in settings, keeps a normal 1 second cadence.
- Smoke test token added for terminal cursor policy.
- T011 aligned to the YottaDB-direct terminal contract using `write 123,!`.

## Rationale
The MIOMOS desktop applies broad reduced-motion rules to all descendants of the desktop root. That can unintentionally compress xterm cursor animation timings and cause visibly incorrect blink behavior. The terminal subtree now opts out of that compression, and the default user-facing cursor blink preference is off.
