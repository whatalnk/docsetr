#' Generate help html files for all packages
#'
#' @param docsetroot path to `Documents` dir of docset
#'
#' @export
docset.create.html <- function(docsetroot, ignored = c()) {
  ignored <- c("translations", ignored)
  pkgs <- installed.packages()[,"Package"]
  pkgs <- pkgs[!pkgs %in% ignored]
  pkgs %>>% sapply(function(x){
    generate.help.html(x)
  })
}
