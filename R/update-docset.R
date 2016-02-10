pkgs <- c("RSQLite", "pipeR", "XML", "selectr", "dplyr")
sapply(pkgs, library, character.only = TRUE)
create.package.list()

con <- dbConnect(SQLite(), dbname = "../docSet.dsidx")
dbListTables(con)
dbGetQuery(con, "select package, version from searchIndex") %>>% head()

# old
pkgs.docset <- dbGetQuery(con, "select distinct package, version from searchIndex")

# latest
installed.packages() %>>% 
  data.frame(stringsAsFactors = FALSE) %>>% 
  select(Package) %>>% 
  filter(Package != "translations") %>>% 
  rowwise() %>>% 
  mutate(version = as.character(packageVersion(Package))) %>>% 
  rename(package = Package) -> pkgs.lib

# diff
dplyr::full_join(pkgs.lib, pkgs.docset, by = "package") %>>% 
  filter(is.na(version.y) | version.x != version.y) -> pkgs.updated
## outdated
pkgs.updated %>>% filter(!is.na(version.y)) -> pkgs.outdated
## new
pkgs.updated %>>% filter(is.na(version.y)) -> pkgs.new

# help html
## update outdated packages
pkgs.outdated$package %>>% sapply(function(x){
  update.help.html(x)
})

## new packages
pkgs.new$package %>>% sapply(function(x){
  generate.help.html(x)
})

# SQLite index
## delete outdated packages

dbBegin(conn)
dbGetQuery(con, sprintf("delete from searchIndex where package in (%s)", str_c(sprintf("'%s'", pkgs.outdated$package), collapse = ", ")))
dbCommit(conn)

# register updated and new packages
pkgs.updated$package %>>% sapply(function(x){
  create.sqlite.index(x, con)
})

dbDisconnect(con)
