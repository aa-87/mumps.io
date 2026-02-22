# Release polish

## Version banner

Recommended labels to add to MIOTPL:

```mumps
VERSION() Q "MIOTPL v1.0.0 (2026-02-21)"
BANNER()  W !,$$VERSION^MIOTPL(),!
```

Use:

```mumps
D BANNER^MIOTPL
```
