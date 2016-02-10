#' Create sqlite index for a package
#' 
#' @param docsetroot path to `Documents` dir of docset
#' @param pkg package name
#' @param con SQLiteConnection
#' 
#' @export
create.sqlite.index <- function(docsetroot, pkg, con) {
  dbBegin(con)
  doc <- htmlTreeParse(file.path(docsetroot, "library", pkg, "html", "00Index.html"), useInternal = TRUE)
  nodes.tr <- getNodeSet(doc, "//table/tr")
  for (n in nodes.tr) {
    nodes.tr.a <- xmlChildren(n)$td %>>% getNodeSet("./a")
    nodes.tr.a.attr <- nodes.tr.a[[1]] %>>% xmlAttrs()
    name <- xmlValue(nodes.tr.a[[1]])
    path <- file.path("library", pkg, "html", nodes.tr.a.attr["href"])
    if (name == paste(pkg, "-package", sep = "")) {
      type <- "Instruction"
    } else {
      type <- "Function"
    }
    name <- sub(pattern = "'", replacement = "''", x = name)
    dbGetQuery(con, sprintf("insert into searchIndex(name, type, path, package, version) values('%s', '%s', '%s', '%s', '%s')", name, type, path, pkg, packageVersion(pkg)))
  }
  dbGetQuery(con, sprintf("insert into searchIndex(name, type, path, package, version) values('%s', 'Package', '%s', '%s', '%s')", pkg, file.path("library", pkg, "html", "00Index.html"), pkg , packageVersion(pkg)))
  dbCommit(con)
}
