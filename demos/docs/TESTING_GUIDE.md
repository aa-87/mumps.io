# MIOTPL Testing Guide

## Run suite

```mumps
ZL "MIOTPL.m","MIOTPLT.m"
K ^MIO("TPL","CACHE")
D MIOTEST^MIOTPL
```

If available:

```mumps
D MIOTESTMODES^MIOTPL
```

## Benchmark

```mumps
ZL "MIOTPLB.m"
D RUN^MIOTPLB
```

Tune:

```mumps
S CONF("bench","iters","compile")=50
S CONF("bench","iters","render")=200
D RUN^MIOTPLB(.CONF)
```
