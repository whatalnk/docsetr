#' Create package list
#'
#' @param docsetroot path to `Documents` dir
#' @param overwrite wherether overwrite or not
#'
create.package.list <- function(docsetroot, overwrite = FALSE){
  make.packages.html(temp = TRUE)
  file.copy(from = file.path(tempdir(), ".R/doc/html/packages.html"), to = file.path(docsetroot, "doc", "html"), overwrite = overwrite, copy.date = TRUE)

  doc <- htmlTreeParse(file.path(docsetroot, "doc", "html", "packages.html"), useInternal = TRUE)

  oldNode <- newNode <- querySelector(doc, ".toplogo")

  xmlAttrs(newNode)["src"] <- "logo.png"
  addAttributes(newNode, width = "100", height = "78")
  replaceNodes(oldNode, newNode)

  remove.navigation(doc)
  saveXML(doc, file.path(docsetroot, "doc", "html", "packages.html"))
}
