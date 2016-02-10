#' Create new directory for docset
#' 
#' @param path where to create
#' @export
docset.init <- function(path = getwd()) {
  docsetroot <- file.path(path, "Rlibs.docset", "Contents", "Resources", "Documents")
  ret <- dir.create(docsetroot, recursive = TRUE)
  if (ret) {
    cat("Initialised at", file.path(tools::file_path_as_absolute(path)), "\n")
    cat("docsetroot is", tools::file_path_as_absolute(docsetroot), "\n")
  } else {
    return(FALSE)
  }
  dir.create(file.path(docsetroot, "doc", "html"), recursive = TRUE)
  create.package.list(docsetroot)
  file.copy(from = file.path(R.home("doc"), "html", "R.css"), to = file.path(docsetroot, "doc", "html"), copy.date = TRUE)
  download.file(url = "https://www.r-project.org/Rlogo.png", destfile = file.path(docsetroot, "doc", "html", "logo.png"), mode = "wb")
  file.copy(system.file("info.plist", "docsetr"), file.path(path, "Rlibs.docset", "Contents"))
}
