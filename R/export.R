# Export functions for revision tables, citations, and bibliographic data

#' Write an article revision table to an xlsx file
#'
#' Writes a Wikipedia revision table (as returned by
#' \code{\link{get_article_full_history_table}} or similar functions) to an
#' Excel file in the current working directory.
#'
#' @param wiki_hist A data frame of Wikipedia revisions with at least the
#'   columns \code{art}, \code{revid}, \code{parentid}, \code{user},
#'   \code{userid}, \code{timestamp}, \code{size}, \code{comment}, and
#'   \code{*} (raw wikitext).
#' @param file_name Character string used as a prefix for the output file name.
#'   The file will be saved as \code{<file_name>_wiki_table.xlsx}.
#' @return Invisibly returns \code{NULL}. Called for its side effect of writing
#'   a file.
#' @export
#' @examples
#' \dontrun{
#' tmpwikitable <- get_article_initial_table("Zeitgeber")
#' write_wiki_history_to_xlsx(tmpwikitable, "Zeitgeber")
#' }
write_wiki_history_to_xlsx <- function(wiki_hist, file_name) {
  wiki_hist[is.na(wiki_hist)] <- "-"
  df <- data.frame(
    art       = wiki_hist$art,
    revid     = wiki_hist$revid,
    parentid  = wiki_hist$parentid,
    user      = wiki_hist$user,
    userid    = wiki_hist$userid,
    timestamp = wiki_hist$timestamp,
    size      = wiki_hist$size,
    comment   = wiki_hist$comment,
    content   = wiki_hist$`*`,
    stringsAsFactors = FALSE
  )
  openxlsx::write.xlsx(df, file = paste0(file_name, "_wiki_table.xlsx"))
  invisible(NULL)
}


#' Export all built-in regex matches to separate xlsx files
#'
#' Applies every regular expression in \code{\link{pkg.env}}\code{$regexp_list}
#' to \code{article_most_recent_table} and saves the results as individual
#' \code{.xlsx} files in the working directory.
#'
#' @param article_most_recent_table A Wikipedia revision data frame (e.g. from
#'   \code{\link{get_category_articles_most_recent}}).
#' @param name_file_prefix Character prefix used for all output file names.
#' @return Invisibly returns \code{NULL}. Called for its side effect of writing
#'   files.
#' @export
#' @examples
#' \dontrun{
#' category_most_recent <- get_category_articles_most_recent(
#'   c("Zeitgeber", "Advanced sleep phase disorder")
#' )
#' export_extracted_citations_xlsx(category_most_recent, "sleep_articles")
#' }
export_extracted_citations_xlsx <- function(article_most_recent_table,
                                            name_file_prefix) {
  for (i in seq_along(pkg.env$regexp_list)) {
    tmp_table <- get_regex_citations_in_wiki_table(
      article_most_recent_table,
      as.character(pkg.env$regexp_list[i])
    )
    out_file <- paste0(
      name_file_prefix, "_",
      names(pkg.env$regexp_list)[i],
      "_extracted_citations.xlsx"
    )
    tryCatch(
      openxlsx::write.xlsx(tmp_table, file = out_file),
      error = function(e) {
        message("Could not write ", out_file, ": ", conditionMessage(e))
      }
    )
  }
  invisible(NULL)
}


#' Annotate a DOI list and export as a BibTeX file
#'
#' Queries CrossRef for each DOI in \code{doi_list}, then writes the results
#' to a BibTeX file.
#'
#' @param doi_list Character vector of DOIs.
#' @param file_name Output file name (default: \code{"file.bib"}).
#' @return Invisibly returns \code{NULL}. Called for its side effect of writing
#'   a file.
#' @export
#' @examples
#' \dontrun{
#' category_recent <- get_category_articles_most_recent(
#'   c("Zeitgeber", "Advanced sleep phase disorder")
#' )
#' extracted <- get_regex_citations_in_wiki_table(
#'   category_recent,
#'   "10\\.\\d{4,9}/[-._;()/:a-z0-9A-Z]+"
#' )
#' export_doi_to_bib(unique(extracted$citation_fetched)[1:5], "output.bib")
#' }
export_doi_to_bib <- function(doi_list, file_name = "file.bib") {
  dfa <- annotate_doi_to_bibtex_cross_ref(doi_list)
  lapply(dfa, function(x) {
    write.table(x, file_name, append = TRUE, sep = "\n\n",
                quote = FALSE, col.names = FALSE, row.names = FALSE)
  })
  invisible(NULL)
}
