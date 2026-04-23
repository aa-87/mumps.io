# MIOOS Transfer Manager

## Purpose
Transfers is the operational surface for active, queued, completed, retriable, and failed file movement work.

## UX model
- Summary stats at the top
- In-progress list with progress bars and actions
- History list with state and recovery actions
- Source/destination context on each transfer

## States
- queued
- running
- paused
- verifying
- completed
- failed
- canceled

## Actions
- Pause
- Resume
- Cancel
- Retry
- Clear finished

## Data points
- processed bytes
- total bytes
- progress percentage
- source path
- destination path
- current stage
- error detail when present

## Platform note
The transfer manager is intentionally more operational and enterprise-oriented than the previous utility-style presentation.