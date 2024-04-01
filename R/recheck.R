#' Reverse Dependency Check
#'
#' Run a reverse dependency check similar to CRAN.
#'
#' @export
#' @rdname recheck
#' @param sourcepkg path to a source package tarball
#' @param which passed to `tools::check_packages_in_dir`. Set "most" to
#' also check reverse suggests.
revdep_check <- function(sourcepkg, which = "strong"){
  if(grepl('^https:', sourcepkg)){
    curl::curl_download(sourcepkg, basename(sourcepkg))
    sourcepkg <- basename(sourcepkg)
  }
  pkg <- sub("_.*", "", basename(sourcepkg))
  if(grepl("Linux", Sys.info()[['sysname']])){
    preinstall_linux_binaries(pkg, which = which)
  }
  checkdir <- dirname(sourcepkg)
  cran <- utils::available.packages(repos = 'https://cloud.r-project.org')
  revdeps <- tools::package_dependencies(pkg, db = cran, reverse = TRUE)[[pkg]]
  set_source_repos()
  cat("::group::Running checks\n")
  tools::check_packages_in_dir(checkdir, basename(sourcepkg),
                               reverse = 'https://cloud.r-project.org',
                               which = which,
                               Ncpus = parallel::detectCores(),
                               check_args = c('--no-manual'))
  cat("::endgroup::\n")
  tools::summarize_check_packages_in_dir_results(checkdir)
  tools::check_packages_in_dir_details(checkdir)
}

set_source_repos <- function(){
  options(repos = c(CRAN = 'https://cloud.r-project.org'))
  utils::setRepositories(ind = 1:4) #adds bioc
}

test_revdep_check <- function(pkg){
  checkdir <- paste(pkg, 'recheck', sep = '_')
  unlink(checkdir, recursive = TRUE)
  dir.create(checkdir)
  utils::download.packages(pkg, checkdir, repos = 'https://cloud.r-project.org')
  revdep_check(list.files(checkdir, pattern = 'tar.gz$', full.names = TRUE))
}
