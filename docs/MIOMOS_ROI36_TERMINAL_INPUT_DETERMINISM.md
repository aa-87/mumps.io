# MIOMOS ROI36 follow-up: terminal input determinism

## Problem

After the websocket helper and PIPE-terminal rewrite, the remaining failing assertion in `^MIOMOST` was:

- `[MIOMOST][T016][ws term write]`

The websocket command path was succeeding, but the PIPE terminal could return from `terminal.input` before YottaDB had emitted readable stdout for the submitted line.

## Fix

The stabilization patch does two things:

1. Normalizes `line` input into a newline-terminated payload before it reaches the PIPE terminal.
2. Adds a bounded post-write drain retry in `MIOMOSTPIPE` so `terminal.input` is more likely to return with stdout on the same command round trip.

Raw `data` passthrough remains unchanged.

## Files changed

- `routines/MIOMOSTPIPE.m`
- `routines/MIOMOSCMD.m`
- `routines/MIOMOSWS.m`
- `miomos_llm.md`

## Expected impact

This should eliminate the last `T016` failure without changing the broader websocket command contract or reintroducing split terminal ownership.
