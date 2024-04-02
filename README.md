# recheck

Some helpers to run a reverse dependency check using the same tools as CRAN.

## Please read this

A reverse dependency check is not a red/green test. You should see it more as a
diagnostic tool to identify potential issues to look investigate.

Checks results from other packages may be influenced by all kind of factors, 
related to the platform, hardware, network, system setup, or plain random.
We try to get results close to CRAN, but we need to make some trade offs to keep
this practical.


## Supported platfroms

In theory you can do this on any platform, however there is an important caveat:

To be able check some reverse dependencies, we first need to install all dependencies
(including Suggests) for each package. Many CRAN packages indirectly depend on 100+
other packages, so this quickly adds up. 

Even if your package only has a handful of revdeps, you may need to install over a 
thousand packages before even starting the revdep check. For this reason it is
only practical to do this on platforms for which precompiled R binary packages 
are available.

CRAN runs revdep checks on r-devel on a server with debian:testing but there are 
no public binary packages available for this platform. Our containers are based on
ubuntu:latest and run r-release, for which public binary packages are available 
via https://p3m.dev and https://r-universe.dev. This is one reason results might 
be slighlty different from what CRAN would show, though in practice it is rarely 
an issue.

## How to use

This will check your package and reverse dependencies from CRAN:

```r
recheck::recheck("mypackage_1.0.tar.gz")
```

To run this on GitHub actions use:


