# in Rlibs.docset/Contents/Resources/Documents
library(RSQLite)
library(pipeR)
library(XML)
library(selectr)

docsetroot <- "~/Rlibs.docset/Contents/Resources/Documents"
setwd(docsetroot)

# Package list
dir.create(file.path("doc", "html"), recursive = TRUE)

make.packages.html(temp = TRUE)
file.copy(from = file.path(tempdir(), ".R/doc/html/packages.html"), to = file.path("doc", "html"), copy.date = TRUE)
file.copy(from = file.path(R.home("doc"), "html", "R.css"), to = file.path("doc", "html"), copy.date = TRUE)
download.file(url = "https://www.r-project.org/Rlogo.png", destfile = file.path("doc", "html", "logo.png"), mode = "wb")

doc <- htmlTreeParse(file.path("doc", "html", "packages.html"), useInternal = TRUE)
replace.logo(doc)
remove.navigation(doc)
saveXML(doc, file.path("doc", "html", "packages.html"))

pkgs <- installed.packages()[,"Package"]
pkgs <- pkgs[!pkgs %in% c("translations")]

# for package in packages
pkgs %>>% sapply(function(x){
  generate.help.html(x)
})

con <- dbConnect(SQLite(), dbname = "../docSet.dsidx")
dbGetQuery(con, "CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT, package TEXT, version TEXT)")
dbListTables(con)
dbGetQuery(con, "select * from searchIndex")

pkgs %>>% sapply(function(x){
  create.sqlite.index(x, con)
})

dbDisconnect(con)
