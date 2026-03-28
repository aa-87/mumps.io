# MIOMOS ROI36 test isolation for T010

## Why this change was needed
`^MIOMOST` test `T010` validates observability export ordering by seeding one access log entry, one error log entry, and one audit entry, then asserting that the first exported records are `error_probe` and `audit_probe`.

That assumption was only valid while no earlier tests or startup helpers emitted observability records. Once websocket command/audit work started producing legitimate earlier audit activity, `T010` became order-dependent and could fail with an earlier event like `ws_command_error` appearing ahead of the probe record.

## Change
Before seeding the `T010` probe entries, the test now clears:

- `^MIO("MIOMOS","LOG","ACCESS")`
- `^MIO("MIOMOS","LOG","ERROR")`
- `^MIO("MIOMOS","AUDIT")`

## Result
`T010` now verifies the export behavior in isolation instead of depending on the absence of earlier unrelated audit/access events. This keeps the test deterministic while preserving the newer websocket observability behavior.
