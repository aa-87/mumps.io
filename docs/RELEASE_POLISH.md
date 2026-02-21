# Release polish

## Version banner

Recommended labels to add to MIOTPL2:

```mumps
VERSION() Q "MIOTPL2 v1.0.0 (2026-02-21)"
BANNER()  W !,$$VERSION^MIOTPL2(),!
```

Use:

```mumps
D BANNER^MIOTPL2
```
