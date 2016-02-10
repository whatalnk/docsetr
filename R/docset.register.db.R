#' Register SQLite index
#' 
#' @param docsetroot path to `Documents` dir of docset
#' 
#' @export
docset.register.db <- function(docsetroot, new = TRUE) {
  con <- dbConnect(SQLite(), dbname = file.path(docsetroot, "..", "docSet.dsidx"))
  if (new) {
    dbGetQuery(con, "CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT, package TEXT, version TEXT)")
  }
  pkgs %>>% sapply(function(x){
    create.sqlite.index(x, con)
  })
  dbDisconnect(con)
}

#' 