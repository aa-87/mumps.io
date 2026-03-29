# MIOMOS — Terminal multi-window launch restore

## Goal

Restore classic desktop terminal behavior so launching Terminal from the shell creates a fresh desktop window and a fresh backend terminal session each time.

## What changed

- launching Terminal now creates a new window instead of reusing a single terminal surface
- each terminal window keeps its own terminal state in the browser
- each terminal launch requests a fresh backend session using the existing `__new__` terminal id sentinel
- closing a terminal window closes only that window's terminal session
- shell actions that say "Focus terminal" now focus the most recent open terminal window instead of always spawning another one

## Scope

This patch intentionally does not change auth, websocket ownership, or the command bus contract. It only restores terminal window/session behavior in the desktop shell.
