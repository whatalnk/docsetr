update.help.html <- function(pkg) {
  # cleanup
  ## help html files
  htmldir <- file.path("library", pkg, "html")
  htmllist <- list.files(htmldir, "*.html")
  file.remove(file.path(htmldir, htmllist))
  
  ## DESCRIPTION, NEWS
  c("DESCRIPTION", "NEWS") %>>% lapply(function(x){
    if (file.exists(file.path("library", pkg, x))) {
      file.remove(file.path("library", pkg, x))
    }
  })

  ## doc files
  if (file.exists(file.path("library", "dplyr", "doc"))) {
    docdir <- file.path("library", "dplyr", "doc")
    docfiles <- list.files(docdir)
    file.remove(file.path(docdir, docfiles))
  }
  
  # 00index.html
  file.copy(file.path(find.package(pkg), 'html', "00Index.html"), file.path("library", pkg, "html"))
  doc <- htmlTreeParse(file.path("library", pkg, "html", "00Index.html"), useInternal = TRUE)
  replace.logo(doc)
  remove.navigation(doc)
  replace.link.to.description(doc)
  saveXML(doc, file.path("library", pkg, "html", "00Index.html"))
  
  # DESCRIPTION, NEWS
  c("DESCRIPTION", "NEWS") %>>% lapply(function(x){
    if (file.exists(system.file(x, package = pkg))) {
      file.copy(system.file(x, package = pkg), f <- file.path("library", pkg, x), copy.date = TRUE)
      writeLines(c("<pre>", readLines(f), "</pre>"), paste0(f, ".html"))
      file.remove(f)
    }
  })
  
  # doc dir
  if (system.file("doc", package = pkg) != "") {
    file.copy(system.file("doc", package = pkg), file.path("library", pkg), recursive = TRUE, copy.date = TRUE)
    ## index.html
    if (file.exists(file.path("library", pkg, "doc", "index.html"))) {
      doc <- htmlTreeParse(file.path("library", pkg, "doc", "index.html"), useInternal = TRUE)
      replace.logo(doc)
      remove.navigation(doc)
      getNodeSet(doc, "/html/head/link") %>>% lapply(function(x){
        oldNode <- newNode <- x
        xmlAttrs(newNode)["href"] <- "../../../doc/html/R.css"
        replaceNodes(oldNode, newNode)
      })
      saveXML(doc, file.path("library", pkg, "doc", "index.html"))
    } else {
      list.of.dir(pkg, file.path("library", pkg, "doc", "index.html"))
    }
  }
  # Help pages
  generate.help.from.Rd(pkg)
}

# Package list
create.package.list(){
  make.packages.html(temp = TRUE)
  file.copy(from = file.path(tempdir(), ".R/doc/html/packages.html"), to = file.path("doc", "html"), overwrite = TRUE, copy.date = TRUE)
  
  doc <- htmlTreeParse(file.path("doc", "html", "packages.html"), useInternal = TRUE)
  
  oldNode <- newNode <- querySelector(doc, ".toplogo")
  xmlAttrs(newNode)["src"] <- "logo.png"
  addAttributes(newNode, width = "100", height = "78")
  replaceNodes(oldNode, newNode)
  
  remove.navigation(doc)
  saveXML(doc, file.path("doc", "html", "packages.html"))
}


