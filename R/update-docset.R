#' Update docset
#'
#' @param docsetroot path to `Documents` dir
#'
#' @return list outdated package,new package
#'
#' @export
docset.outdated <- function(docsetroot) {
  con <- dbConnect(SQLite(), dbname = file.path(docsetroot, "..", "docSet.dsidx"))

  # old
  dbGetQuery(con, "select distinct package, version from searchIndex") %>>%
    rename(version.doc = version) -> pkgs.doc

  # latest
  installed.packages() %>>%
    data.frame(stringsAsFactors = FALSE) %>>%
    select(Package) %>>%
    filter(Package != "translations") %>>%
    rowwise() %>>%
    mutate(version.lib = as.character(packageVersion(Package))) %>>%
    rename(package = Package) -> pkgs.lib

  # diff
  dplyr::full_join(pkgs.lib, pkgs.doc, by = "package") %>>%
    filter(is.na(version.doc) | version.lib != version.doc) -> pkgs.updated

  ## outdated
  pkgs.updated %>>% filter(!is.na(version.doc)) -> pkgs.outdated

  ## new
  pkgs.updated %>>% filter(is.na(version.doc)) -> pkgs.new

  return(list(pkgs.ourdated = pkgs.outdated, pkgs.new = pkgs.new))
}

#' Update docset
#'
#' @param docsetroot path to `Documents` dir
#'
#' @export
docset.update <- function(docsetroot) {
  create.package.list(docsetroot, overwrite = TRUE)

  con <- dbConnect(SQLite(), dbname = dbname = file.path(docsetroot, "..", "docSet.dsidx"))

  # help html
  pkgs.updated <- docset.outdated(docsetroot)
  pkgs.outdated <- pkgs.updated$pkgs.outdated
  pkgs.new <- pkgs.updated$pkgs.new
  ## update outdated packages

  pkgs.outdated$package %>>% sapply(function(x){
    update.help.html(docsetroot, x)
  })
  ## new packages
  pkgs.new$package %>>% sapply(function(x){
    generate.help.html(docsetroot, x)
  })

  # SQLite index
  ## delete outdated packages
  dbBegin(con)
  dbGetQuery(con, sprintf("delete from searchIndex where package in (%s)", str_c(sprintf("'%s'", pkgs.outdated$package), collapse = ", ")))
  dbCommit(con)

  # register updated and new packages
  pkgs.updated$package %>>% sapply(function(x){
    create.sqlite.index(docsetroot, x, con)
  })
  dbDisconnect(con)
}
