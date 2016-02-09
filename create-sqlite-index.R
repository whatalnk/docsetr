# in Rlibs.docset/Contents/Resources/Documents
library(RSQLite)
library(pipeR)
library(XML)

create.sqlite.index <- function(pkg, conn) {
  dbBegin(conn)
  doc <- htmlTreeParse(file.path("library", pkg, "html", "00Index.html"), useInternal = TRUE)
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
    dbGetQuery(conn, sprintf("insert into searchIndex(name, type, path, package, version) values('%s', '%s', '%s', '%s', '%s')", name, type, path, pkg, packageVersion(pkg)))
  }
  dbGetQuery(conn, sprintf("insert into searchIndex(name, type, path, package, version) values('%s', 'Package', '%s', '%s', '%s')", pkg, file.path("library", pkg, "html", "00Index.html"), pkg , packageVersion(pkg)))
  dbCommit(conn)
}

con <- dbConnect(SQLite(), dbname = "../docSet.dsidx")
dbGetQuery(con, "CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT, package TEXT, version TEXT)")
dbListTables(con)
dbGetQuery(con, "select * from searchIndex")

pkgs %>>% lapply(function(x){
  create.sqlite.index(x, con)
})

dbDisconnect(con)
