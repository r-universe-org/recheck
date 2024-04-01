preinstall_linux_binaries <- function(pkg, which = 'strong'){
  rver <- getRversion()
  distro <- system2('lsb_release', '-sc', stdout = TRUE)
  options(HTTPUserAgent = sprintf("R/%s R (%s); r-universe (%s)", rver, paste(rver, R.version$platform, R.version$arch, R.version$os), distro))
  bioc <- sprintf("https://bioc.r-universe.dev/bin/linux/%s/4/", distro)
  cran <- sprintf("https://p3m.dev/cran/__linux__/%s/latest", distro)
  repos <- c(cran, bioc)
  db <- utils::available.packages(repos = repos)
  revdeps <- c(pkg, tools::package_dependencies(pkg, db = db, reverse = TRUE, which = which)[[pkg]])
  strongdeps <- tools::package_dependencies(revdeps, db = db, recursive = TRUE)
  strongpkgs <- unlist(lapply(revdeps, function(x){
    c(rev(strongdeps[[x]]), x)
  }))
  softdeps <- tools::package_dependencies(revdeps, db = db, which = 'most')
  packages <- unique(c(strongpkgs, unlist(unname(softdeps))))
  packages <- intersect(packages, row.names(db))
  packages <- setdiff(packages, loadedNamespaces())
  versions <- db[packages, 'Version']
  mirrors <- db[packages, 'Repository']
  urls <- sprintf("%s/%s_%s.tar.gz", mirrors, packages,  versions)
  destdir <- tempfile()
  dir.create(destdir)
  pwd <- setwd(destdir)
  on.exit(setwd(pwd), add = TRUE)
  on.exit(unlink(destdir, recursive = TRUE), add = TRUE)
  res <- curl::multi_download(urls)
  res$ok <- res$success & res$status_code == 200
  failures <- res$destfile[!res$ok]
  if(length(failures)){
    warning("Failed downloads for: ", paste(failures, collapse = ', '))
    unlink(failures)
    res <- res[res$ok,]
  }
  utils::install.packages(res$destfile, repos = NULL, Ncpus = parallel::detectCores())
}
