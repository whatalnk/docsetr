#' Update help html
#'
#' @param docsetroot path to `Documents` dir
#' @param pkg package name
#'
#' @export
update.help.html <- function(docsetroot, pkg) {
  # cleanup
  ## help html files
  htmldir <- file.path(docsetroot, "library", pkg, "html")
  htmllist <- list.files(htmldir, "*.html")
  file.remove(file.path(htmldir, htmllist))

  ## DESCRIPTION, NEWS
  c("DESCRIPTION", "NEWS") %>>% lapply(function(x){
    if (file.exists(file.path(docsetroot, "library", pkg, x))) {
      file.remove(file.path(docsetroot, "library", pkg, x))
    }
  })

  ## doc files
  if (file.exists(file.path(docsetroot, "library", pkg, "doc"))) {
    docdir <- file.path(docsetroot, "library", pkg, "doc")
    docfiles <- list.files(docdir)
    file.remove(file.path(docdir, docfiles))
  }

  # 00index.html
  file.copy(file.path(find.package(pkg), 'html', "00Index.html"), file.path(docsetroot, "library", pkg, "html"))
  doc <- htmlTreeParse(file.path(docsetroot, "library", pkg, "html", "00Index.html"), useInternal = TRUE)
  replace.logo(doc)
  remove.navigation(doc)
  replace.link.to.description(doc)
  saveXML(doc, file.path(docsetroot, "library", pkg, "html", "00Index.html"))

  # DESCRIPTION, NEWS
  c("DESCRIPTION", "NEWS") %>>% lapply(function(x){
    if (file.exists(system.file(x, package = pkg))) {
      file.copy(system.file(x, package = pkg), f <- file.path(docsetroot, "library", pkg, x), copy.date = TRUE)
      writeLines(c("<pre>", readLines(f), "</pre>"), paste0(f, ".html"))
      file.remove(f)
    }
  })

  # doc dir
  if (system.file("doc", package = pkg) != "") {
    file.copy(system.file("doc", package = pkg), file.path(docsetroot, "library", pkg), recursive = TRUE, copy.date = TRUE)
    ## index.html
    if (file.exists(file.path(docsetroot, "library", pkg, "doc", "index.html"))) {
      doc <- htmlTreeParse(file.path(docsetroot, "library", pkg, "doc", "index.html"), useInternal = TRUE)
      replace.logo(doc)
      remove.navigation(doc)
      getNodeSet(doc, "/html/head/link") %>>% lapply(function(x){
        oldNode <- newNode <- x
        xmlAttrs(newNode)["href"] <- "../../../doc/html/R.css"
        replaceNodes(oldNode, newNode)
      })
      saveXML(doc, file.path(docsetroot, "library", pkg, "doc", "index.html"))
    } else {
      list.of.dir(docsetroot, pkg, file.path(docsetroot, "library", pkg, "doc", "index.html"))
    }
  }
  # Help pages
  generate.help.from.Rd(docsetroot, pkg)
}
