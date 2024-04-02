#' Reverse Dependency Check
#'
#' Run a reverse dependency check similar to CRAN.
#'
#' @export
#' @rdname recheck
#' @param sourcepkg path or URL to a source package tarball
#' @param repos vector of repos to look for reverse dependencies
#' @param which passed to `tools::package_dependencies`; set to "most" to
#' also check reverse suggests.
recheck <- function(sourcepkg, which = "strong", repos = 'https://cloud.r-project.org'){
  if(grepl('^https:', sourcepkg)){
    curl::curl_download(sourcepkg, basename(sourcepkg))
    sourcepkg <- basename(sourcepkg)
  }
  pkg <- sub("_.*", "", basename(sourcepkg))
  checkdir <- dirname(sourcepkg)
  cran <- utils::available.packages(repos = repos)
  packages <- c(pkg, tools::package_dependencies(pkg, db = cran, which = which, reverse = TRUE)[[pkg]])
  group_output("Preparing dependencies", {
    oldtimeout <- options(timeout = 600)
    if(grepl("Linux", Sys.info()[['sysname']])){
      preinstall_linux_binaries(packages)
    } else {
      utils::install.packages(packages, dependencies = TRUE)
    }
  })
  group_output("Running checks", {
    Sys.setenv('_R_CHECK_FORCE_SUGGESTS_' = 'false')
    oldrepos <- set_official_repos()
    on.exit(options(c(oldrepos, oldtimeout)), add = TRUE)
    tools::check_packages_in_dir(checkdir, basename(sourcepkg),
                                 reverse = list(repos = repos, which = which),
                                 Ncpus = parallel::detectCores(),
                                 check_args = c('--no-manual'))
  })
  group_output("Check results details", {
    tools::check_packages_in_dir_details(checkdir)
  })
  tools::summarize_check_packages_in_dir_results(checkdir)
}

set_official_repos <- function(){
  old <- options(repos = c(CRAN = 'https://cloud.r-project.org'))
  utils::setRepositories(ind = 1:4) #adds bioc
  return(old)
}

group_output<- function(title, expr){
  if(Sys.getenv('CI') != ""){
    cat("::group::", title, "\n", sep = "")
    on.exit(cat("::endgroup::\n"))
  }
  cat("===========", title, "===========\n")
  eval(expr)
}

test_recheck <- function(pkg, which = 'strong'){
  checkdir <- paste(pkg, 'recheck', sep = '_')
  unlink(checkdir, recursive = TRUE)
  dir.create(checkdir)
  utils::download.packages(pkg, checkdir, repos = 'https://cloud.r-project.org')
  recheck(list.files(checkdir, pattern = 'tar.gz$', full.names = TRUE), which = which)
}
