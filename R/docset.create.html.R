#' Generate help html files for all packages
#' 
#' @param docsetroot path to `Documents` dir of docset
#' 
#' @export
docset.create.html <- function(docsetroot) {
  pkgs <- installed.packages()[,"Package"]
  pkgs <- pkgs[!pkgs %in% c("translations")]
  pkgs %>>% sapply(function(x){
    generate.help.html(x)
  })
}
