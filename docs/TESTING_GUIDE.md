# MIOTPL2 Testing Guide

## Run suite

```mumps
ZL "MIOTPL2.m","MIOTPLT.m"
K ^MIO("TPL","CACHE")
D MIOTEST^MIOTPL2
```

If available:

```mumps
D MIOTESTMODES^MIOTPL2
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
