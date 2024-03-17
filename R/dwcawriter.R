#' @title DwC-A writer
#'
#' @description
#' DwC-A writer
#'
#' @docType package
#' @name dwcawriter
#' @import dplyr xml2 glue
#' @author Pieter Provoost, \email{pieterprovoost@gmail.com}
NULL

generate_table <- function(table, core = TRUE) {

  if (core) {
    element <- "core"
    element_id <- "id"
  } else {
    element <- "extension"
    element_id <- "coreid"
  }

  table_type <- read_xml(table$type)
  table_type_fields <- table_type %>%
    xml_ns_strip() %>%
    xml_find_all(".//property") %>%
    xml_attrs() %>%
    bind_rows()
  table_fields <- names(table$data)
  qualnames <- table_type_fields[match(table_fields, table_type_fields$name),]$qualName

  root <- read_xml(glue("<{element}></{element}>"))
  xml_attrs(root) <- c(
    encoding = "UTF-8",
    fieldsTerminatedBy = "\\t",
    linesTerminatedBy = "\\n",
    fieldsEnclosedBy = "",
    ignoreHeaderLines = "1",
    rowType = table$type
  )

  field <- read_xml(glue("<{element_id} />"))
  xml_attrs(field) <- c(
    index = as.character(table$index)
  )
  xml_add_child(root, field)

  for (i in 1:length(qualnames)) {
    qualname <- qualnames[i]
    if (!is.na(qualname)) {
      field <- read_xml(glue("<field />"))
      xml_attrs(field) <- c(
        index = as.character(i),
        term = qualname
      )
      xml_add_child(root, field)
    }
  }

  root
}

#' @export
write_dwca <- function(archive, file) {

  tmp <- tempdir()
  files <- c()

  root <- read_xml('<archive xmlns="http://rs.tdwg.org/dwc/text/" metadata="eml.xml"></archive>')

  # process core

  stopifnot(is.list(archive$core))
  node <- generate_table(archive$core, TRUE)
  xml_add_child(root, node)
  write.table(archive$core$data, file.path(tmp, paste0(archive$core$name, ".txt")), sep = "\t", row.names = FALSE, na = "", quote = FALSE)
  files <- c(files, file.path(tmp, paste0(archive$core$name, ".txt")))

  # process extensions

  for (extension in archive$extensions) {
    node <- generate_table(extension, FALSE)
    xml_add_child(root, node)
    write.table(extension$data, file.path(tmp, paste0(extension$name, ".txt")), sep = "\t", row.names = FALSE, na = "", quote = FALSE)
    files <- c(files, file.path(tmp, paste0(extension$name, ".txt")))
  }

  # write meta

  write_xml(root, file.path(tmp, "meta.xml"))
  files <- c(files, file.path(tmp, "meta.xml"))

  # write eml

  writeLines(archive$eml, file.path(tmp, "eml.xml"))
  files <- c(files, file.path(tmp, "eml.xml"))

  # create zip

  zip(zipfile = file, files = files, extras = "-j")
  file.remove(files)

}
