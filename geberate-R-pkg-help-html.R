library(XML)
library(selectr)
library(pipeR)

docsetroot <- "~/Desktop/Rlibs.docset/Contents/Resources/Documents"

# Package list
dir.create(file.path("doc", "html"), recursive = TRUE)

make.packages.html(temp = TRUE)
file.copy(from = file.path(tempdir(), ".R/doc/html/packages.html"), to = file.path("doc", "html"), copy.date = TRUE)
file.copy(from = file.path(R.home("doc"), "html", "R.css"), to = file.path("doc", "html"), copy.date = TRUE)
download.file(url = "https://www.r-project.org/Rlogo.png", destfile = file.path("doc", "html", "logo.png"), mode = "wb")

doc <- htmlTreeParse(file.path("doc", "html", "packages.html"), useInternal = TRUE)

oldNode <- newNode <- querySelector(doc, ".toplogo")
xmlAttrs(newNode)["src"] <- "logo.png"
addAttributes(newNode, width = "100", height = "78")
replaceNodes(oldNode, newNode)

removeNodes(xmlParent(querySelector(doc, ".arrow")))

saveXML(doc, file.path("doc", "html", "packages.html"))

# for package in packages
pkg <- "readr"
dir.create(file.path("library", pkg, "html"), recursive = TRUE)

# R.css of knitr package
file.copy(system.file('misc', 'R.css', package = 'knitr'), file.path("library", pkg, "html"))

# 00index.html
file.copy(file.path(find.package(pkg), 'html', "00Index.html"), file.path("library", pkg, "html"))

doc <- htmlTreeParse(file.path("library", pkg, "html", "00Index.html"), useInternal = TRUE)
oldNode <- newNode <- querySelector(doc, ".toplogo")
xmlAttrs(newNode)["src"] <- "../../../doc/html/logo.png"
addAttributes(newNode, width = "100", height = "78")
replaceNodes(oldNode, newNode)
removeNodes(xmlParent(xmlParent(querySelector(doc, ".arrow"))))

nodes <- getNodeSet(doc, "/html/body/ul/li/a")

nodes %>>% lapply(function(x){
  basename(xmlAttrs(x)["href"])
}) %>>% lapply(function(x){
  system.file(x, package = pkg)
  }) %>>% lapply(function(x){
    file.copy(x, file.path("library", pkg), copy.date = TRUE)
  })

list("DESCRIPTION", "NEWS") %>>% lapply(function(x){
  if (file.exists(f <- file.path("library", pkg, x))){
  writeLines(c("<pre>", readLines(f), "</pre>"), paste0(f, ".html"))
    # readLines(f)
  file.remove(f)
  }
})

nodes %>>% lapply(function(x){
  oldNode <- newNode <- x
  xmlAttrs(newNode)["href"] <- ifelse(tools::file_ext(xmlAttrs(oldNode)["href"]) != "html", paste0(xmlAttrs(oldNode)["href"], ".html"), xmlAttrs(oldNode)["href"])
  replaceNodes(oldNode, newNode)
})

saveXML(doc, file.path("library", pkg, "html", "00Index.html"))


pkgRdDB <- tools:::fetchRdDB(file.path(find.package(pkg), 'help', pkg))
links <- tools::findHTMLlinks(find.package(pkg), level = 0)
topics <- names(pkgRdDB)
as.list(topics) %>>% lapply(function(x){
  tools::Rd2HTML(pkgRdDB[[x]], out = file.path("library", pkg, "html", paste(x, ".html", sep = "")))
})

if (system.file("doc", package = pkg) != ""){
  file.copy(system.file("doc", package = pkg), file.path("library", pkg), recursive = TRUE, copy.date = TRUE)
  
  doc <- htmlTreeParse(file.path("library", pkg, "doc", "index.html"), useInternal = TRUE)
  
  oldNode <- newNode <- querySelector(doc, ".toplogo")
  xmlAttrs(newNode)["src"] <- "../../../doc/html/logo.png"
  addAttributes(newNode, width = "100", height = "78")
  replaceNodes(oldNode, newNode)
  
  removeNodes(xmlParent(xmlParent(querySelector(doc, ".arrow"))))
  
  oldNode <- newNode <- getNodeSet(doc, "/html/head/link")
  xmlAttrs(newNode[[1]])["href"] <- "../../../doc/html/R.css"
  replaceNodes(oldNode[[1]], newNode[[1]])
  
  saveXML(doc, file.path("library", pkg, "doc", "index.html"))
}
