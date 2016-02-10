#' Generate help html files for a package
#' 
#' Replace path to R logo, adjust size
#' 
#' @param doc 
replace.logo <- function(doc) {
  oldNode <- newNode <- querySelector(doc, ".toplogo")
  xmlAttrs(newNode)["src"] <- "../../../doc/html/logo.png"
  addAttributes(newNode, width = "100", height = "78")
  replaceNodes(oldNode, newNode)
}

#' Remove navigation
#' 
#' @param doc
remove.navigation <- function(doc) {
  removeNodes(xmlParent(xmlParent(querySelector(doc, ".arrow"))))
}

#' Replace link
#' 
#' @param doc
replace.link.to.description <- function(doc) {
  nodes <- getNodeSet(doc, "/html/body/ul/li/a")
  nodes %>>% lapply(function(x){
    oldNode <- newNode <- x
    xmlAttrs(newNode)["href"] <- ifelse(tools::file_ext(xmlAttrs(oldNode)["href"]) != "html", paste0(xmlAttrs(oldNode)["href"], ".html"), xmlAttrs(oldNode)["href"])
    replaceNodes(oldNode, newNode)
  })
}

#' List of files of doc dir (used when index.html is not exist)
#' 
#' @param docsetroot path to `Documents` dir
#' @param pkg packagename
#' @param path path to pkg/doc/index.html
list.of.dir <- function(docsetroot, pkg, path) {
  viganettes <- list.files(file.path(docsetroot, "library", pkg, "doc"))
  write("<html><head></head><body>", path)
  write(sprintf("<h1>Listing of directory %s</h1><hr><dl>", file.path("library", pkg, "doc")), path, append = TRUE)
  for (l in viganettes) {
    write(sprintf("<dt></dt><dd><a href=%s>%s</a></dd>", l, l), path, append = TRUE)
  }
  write("</dl></body></html>", path, append = TRUE)
}

#' Generate help html from Rd for each topic
#' 
#' @docsetroot path to `Documents` dir
#' @param pkg package name
generate.help.from.Rd <- function(docsetroot, pkg) {
  pkgRdDB <- tools:::fetchRdDB(file.path(find.package(pkg), 'help', pkg))
  topics <- names(pkgRdDB)
  as.list(topics) %>>% lapply(function(x){
    tools::Rd2HTML(pkgRdDB[[x]], out = file.path(docsetroot, "library", pkg, "html", paste(x, ".html", sep = "")), package = pkg, Links = tools::findHTMLlinks())
  })
}

#' Generate help html for a package
#' @param docsetroot path to `Documents` dir
#' @param pkg package name
#' @export
generate.help.html <- function(docsetroot, pkg) {
  dir.create(file.path(docsetroot, "library", pkg, "html"), recursive = TRUE)
  
  # R.css of knitr package
  file.copy(system.file('misc', 'R.css', package = 'knitr'), file.path(docsetroot, "library", pkg, "html"))
  
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
