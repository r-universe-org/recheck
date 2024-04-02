# recheck

Some helpers to run a reverse dependency check using the same tools as CRAN.

## Goals and limitations

A reverse dependency check is not a red/green CI test. You should see it more as a
diagnostic tool to identify potential issues that may need further investigation.

Checks from other packages are influenced by all sorts of factors 
specific to the platform, hardware, network, system setup, or just plain random.
We try to create a setup similar to CRAN, but we need to make trade offs to
keep this practical.

The goal of to provide a simple tool that can run on free infrastructure to quickly
check for potential problems with reverse dependencies of your package. It is still
up to you to interpret the results, and possibly compare them with results shown 
on CRAN to identify regressions.

You can also run the tool twice with two different versions of your package but we
do not do this by default right now.

## Supported platfroms

In theory this works on any platform but in practice there is an important caveat:

To be able check some reverse dependencies, we first need to install all dependencies
(including Suggests) for each package. Many CRAN packages indirectly depend on 100+
other packages, so this quickly adds up. 

Even if your package only has a handful of revdeps, you may need to install over a 
thousand other packages, before even starting the revdep check. For this reason it is
only practical to do this on platforms for which precompiled R binary packages 
are available.

CRAN runs revdep checks on r-devel on a server with debian:testing but there are 
no public binary packages available for this platform. Our containers are based on
ubuntu:latest and run r-release, for which public binary packages are available 
via https://p3m.dev and https://r-universe.dev. This is one reason results might 
be slighlty different from what CRAN would show, though in practice it is rarely 
an issue.

## On rcheckserver

On GitHub actions we run the check inside the [rcheckserver](https://github.com/r-devel/rcheckserver)
container. This container has exactly the same system libraries installed as the
CRAN Debian server. Therefore we do not need to worry about system requirements: 
if the package can be built on CRAN, it can also build in the rcheckserver containers.


## How to run locally

This will check your package and reverse dependencies from CRAN in your local R:

```r
recheck::recheck("mypackage_1.0.tar.gz")
```

Alternatively to run it in the Ubuntu container, you need to mount a local source package in the container and then pass the path as an argument. For example:

```sh
# Download some example file:
# curl -OL "https://ropensci.r-universe.dev/src/contrib/qpdf_1.3.3.tar.gz"
docker run -it \
  -v "qpdf_1.3.3.tar.gz:/qpdf_1.3.3.tar.gz" \
  ghcr.io/r-universe-org/recheck "/qpdf_1.3.3.tar.gz"
```

Or you can pass a URL to a public source package:

```sh
docker run -it ghcr.io/r-universe-org/recheck \
  "https://ropensci.r-universe.dev/src/contrib/qpdf_1.3.3.tar.gz"
```

## How to run on GitHub Actions

It is possible to run a reverse dependency check on GitHub actions, but note that their hardware can be slow and has limited disk space. Also there is an overall time limit of 6 hours per run. But if your package has less than 100 reverse dependencies this should usually not be an issue.






