#' Reverse Dependency Check
#'
#' Run a reverse dependency check similar to CRAN.
#'
#' @export
#' @rdname recheck
#' @param sourcepkg path to a source package tarball
#' @param repos vector of repos to find reverse dependencies
#' @param which passed to `tools::check_packages_in_dir`. Set "most" to
#' also check reverse suggests.
revdep_check <- function(sourcepkg, which = "strong", repos = 'https://cloud.r-project.org'){
  if(grepl('^https:', sourcepkg)){
    curl::curl_download(sourcepkg, basename(sourcepkg))
    sourcepkg <- basename(sourcepkg)
  }
  pkg <- sub("_.*", "", basename(sourcepkg))
  checkdir <- dirname(sourcepkg)
  cran <- utils::available.packages(repos = repos)
  packages <- c(pkg, tools::package_dependencies(pkg, db = cran, which = which, reverse = TRUE)[[pkg]])
  cat("::group::Preparing dependencies\n")
  if(grepl("Linux", Sys.info()[['sysname']])){
    preinstall_linux_binaries(packages)
  } else {
    install.packages(packages, dependencies = TRUE)
  }
  cat("::endgroup::\n")
  cat("::group::Running checks\n")
  Sys.setenv('_R_CHECK_FORCE_SUGGESTS_' = 'false')
  old <- set_official_repos()
  on.exit(options(repos = old), add = TRUE)
  tools::check_packages_in_dir(checkdir, basename(sourcepkg),
                               reverse = repos,
                               which = which,
                               Ncpus = parallel::detectCores(),
                               check_args = c('--no-manual'))
  cat("::endgroup::\n")
  tools::summarize_check_packages_in_dir_results(checkdir)
  tools::check_packages_in_dir_details(checkdir)
}

set_official_repos <- function(){
  old <- options(repos = c(CRAN = 'https://cloud.r-project.org'))
  utils::setRepositories(ind = 1:4) #adds bioc
  return(old)
}

test_revdep_check <- function(pkg){
  checkdir <- paste(pkg, 'recheck', sep = '_')
  unlink(checkdir, recursive = TRUE)
  dir.create(checkdir)
  utils::download.packages(pkg, checkdir, repos = 'https://cloud.r-project.org')
  revdep_check(list.files(checkdir, pattern = 'tar.gz$', full.names = TRUE))
}
