#' Reverse Dependency Check
#'
#' Run a reverse dependency check similar to CRAN.
#'
#' @export
#' @rdname recheck
#' @param sourcepkg path to a source package tarball
#' @param which passed to `tools::check_packages_in_dir`
revdep_check <- function(sourcepkg, which = "strong"){
  pkg <- sub("_.*", "", basename(sourcepkg))
  if(grepl("Linux", Sys.info()[['sysname']])){
    preinstall_linux_binaries(pkg, which = which)
  }
  checkdir <- dirname(sourcepkg)
  cran <- utils::available.packages(repos = 'https://cloud.r-project.org')
  revdeps <- tools::package_dependencies(pkg, db = cran, reverse = TRUE)[[pkg]]
  utils::setRepositories(ind = 1:4) #adds bioc
  tools::check_packages_in_dir(checkdir, basename(sourcepkg), reverse = TRUE, which = which,
                               Ncpus = parallel::detectCores(), check_args = c('--no-manual'))
  tools::summarize_check_packages_in_dir_results(checkdir)
  tools::check_packages_in_dir_details(checkdir)
}

test_revdep_check <- function(){
  unlink('qpdf_recheck', recursive = TRUE)
  dir.create('qpdf_recheck')
  utils::download.packages('qpdf', 'qpdf_recheck')
  revdep_check(list.files('revdep_check', pattern = 'qpdf.*gz', full.names = TRUE))
}
