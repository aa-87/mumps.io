# MIOMOS User Guide (ongoing)

## Shell reliability indicators
The taskbar and launcher now show:
- socket state
- in-flight command count
- reconnect count

## What the reliability banner means
A banner may appear when:
- a command fails
- the socket is reconnecting
- socket activity becomes stale

You can dismiss the current banner state. If the condition changes, it may appear again.

## Persisted shell behavior
MIOMOS now remembers some shell state locally, including:
- whether the menu was open
- the active window
- the last shell command name

## Operator guidance
- Avoid repeatedly clicking the same action while it is already running.
- Use the taskbar indicators to confirm whether the shell is connected and idle.
- Use terminal and settings as usual; this ROI does not change their core contracts.
