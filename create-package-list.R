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
