#' Reverse Dependency Check
#'
#' Run checks on known dependents of a package.
#'
#' @export
#' @rdname recheck
#' @param pkg name of a package
#' @param checkdir directory where revdeps are downloaded and checked.
#' @param which passed to `tools::package_dependencies`
#' @param recursive passed to `tools::package_dependencies`
revdep_check <- function(pkg, checkdir = "recheck", which = "strong", recursive = FALSE){
  download_revdeps_sources(pkg = pkg, checkdir = checkdir, which = which, recursive = recursive)
  prepare_revdeps(checkdir)
  tools::check_packages_in_dir(checkdir, Ncpus = parallel::detectCores(), check_args = c('--no-manual'))
  tools::summarize_check_packages_in_dir_results(checkdir)
  tools::check_packages_in_dir_details(checkdir)
}

download_revdeps_sources <- function(pkg, checkdir, which, recursive){
  mirror <- 'https://cloud.r-project.org'
  unlink(checkdir, recursive = TRUE)
  dir.create(checkdir)
  olddir <- setwd(checkdir)
  on.exit(setwd(olddir))
  db <- utils::available.packages(repos = mirror)
  packages <- tools::package_dependencies(pkg, db = db, reverse = TRUE,
    which = which, recursive = recursive)[[pkg]]
  versions <- db[packages, 'Version']
  urls <- sprintf("%s/src/contrib/%s_%s.tar.gz", mirror, packages,  versions)
  res <- curl::multi_download(urls)
  stopifnot(all.equal(unname(tools::md5sum(res$destfile)), unname(db[packages, 'MD5sum'])))
}

# We use pak now because install.packages() is so slow
prepare_revdeps <- function(checkdir = 'revdeps'){
  pkgs <- sub("_.*", "", list.files(checkdir))
  pak::pak(pkgs, dependencies = TRUE, upgrade = TRUE)
}
