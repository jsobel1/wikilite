# Annotation of DOIs and ISBNs using external bibliographic databases

#' Annotate a list of DOIs using EuropePMC
#'
#' Queries the EuropePMC REST API for each DOI and returns a data frame with
#' bibliographic metadata.  Rows for DOIs not found in EuropePMC are silently
#' skipped.
#'
#' @param doi_list Character vector of DOIs.
#' @return A data frame with columns \code{id}, \code{source}, \code{pmid},
#'   \code{pmcid}, \code{doi}, \code{title}, \code{authorString},
#'   \code{journalTitle}, \code{pubYear}, \code{pubType},
#'   \code{isOpenAccess}, \code{citedByCount}, and
#'   \code{firstPublicationDate}.
#' @export
#' @examples
#' \dontrun{
#' art_test <- get_article_most_recent_table("Zeitgeber")
#' dois <- unique(unlist(stringr::str_match_all(
#'   art_test$`*`, "10\\.\\d{4,9}/[-._;()/:a-z0-9A-Z]+"
#' )))
#' annotate_doi_list_europmc(dois[1:3])
#' }
annotate_doi_list_europmc <- function(doi_list) {
  annotated_doi_df <- NULL
  for (i in seq_along(doi_list)) {
    message("Querying EuropePMC for DOI ", i, "/", length(doi_list),
            ": ", doi_list[i])
    load <- tryCatch(
      europepmc::epmc_search(paste0("DOI:", doi_list[i])),
      error = function(e) NULL
    )
    if (is.null(load)) {
      load <- tryCatch(
        europepmc::epmc_search(doi_list[i]),
        error = function(e) NULL
      )
    }
    if (is.null(load) || nrow(load) == 0L) next
    if (nrow(load) == 1L) {
      required_cols <- c(
        "id", "source", "pmid", "pmcid", "doi", "title",
        "authorString", "journalTitle", "pubYear", "pubType",
        "isOpenAccess", "citedByCount", "firstPublicationDate"
      )
      for (col in required_cols) {
        if (!col %in% names(load)) load[[col]] <- NA
      }
      load <- tryCatch(
        dplyr::select(load, dplyr::all_of(required_cols)),
        error = function(e) NULL
      )
      if (is.null(load)) next
      annotated_doi_df <- rbind(annotated_doi_df, load)
    }
  }
  data.frame(annotated_doi_df)
}


#' Annotate a list of DOIs using CrossRef
#'
#' Queries the CrossRef API for each DOI and returns a data frame of
#' bibliographic metadata merged with CrossRef citation counts.
#'
#' @param doi_list Character vector of DOIs.
#' @return A data frame of CrossRef metadata merged with citation counts.
#' @export
#' @examples
#' \dontrun{
#' annotate_doi_list_cross_ref(c("10.1038/nature12373"))
#' }
annotate_doi_list_cross_ref <- function(doi_list) {
  doi_bib <- rcrossref::cr_cn(dois = doi_list, "bibentry", .progress = "text")
  non_empty <- doi_bib[lengths(doi_bib) > 0]
  doi_bib_df <- reshape2::dcast(
    reshape2::melt(non_empty),
    L1 ~ L2
  )
  citation_countdf <- rcrossref::cr_citation_count(doi = doi_bib_df$doi)
  doi_bib_df <- dplyr::left_join(doi_bib_df, citation_countdf, by = "doi")
  doi_bib_df
}


#' Retrieve BibTeX entries for a list of DOIs via CrossRef
#'
#' @param doi_list Character vector of DOIs.
#' @return A list of BibTeX character strings, one per DOI.
#' @export
#' @examples
#' \dontrun{
#' annotate_doi_to_bibtex_cross_ref("10.1038/nature12373")
#' }
annotate_doi_to_bibtex_cross_ref <- function(doi_list) {
  rcrossref::cr_cn(dois = doi_list, "bibtex", .progress = "text")
}


#' Annotate a list of DOIs using Altmetric
#'
#' Retrieves Altmetric attention scores and social-media metrics for the
#' supplied DOIs.
#'
#' @param doi_list A \emph{list} of DOI character strings (as expected by
#'   \code{purrr::pmap_df}).
#' @return A data frame of Altmetric scores and attention metrics.
#' @export
#' @examples
#' \dontrun{
#' art_test <- get_article_most_recent_table("Zeitgeber")
#' dois <- unique(unlist(stringr::str_match_all(
#'   art_test$`*`, "10\\.\\d{4,9}/[-._;()/:a-z0-9A-Z]+"
#' )))
#' annotate_doi_list_altmetrics(list(dois[1:3]))
#' }
annotate_doi_list_altmetrics <- function(doi_list) {
  if (!requireNamespace("rAltmetric", quietly = TRUE)) {
    stop("Package 'rAltmetric' is required. Install it with: ",
         "remotes::install_github('ropensci/rAltmetric')", call. = FALSE)
  }
  alm <- function(x) {
    tryCatch(
      rAltmetric::altmetric_data(rAltmetric::altmetrics(doi = x)),
      error = function(e) NULL
    )
  }
  results <- purrr::pmap_df(doi_list, alm)
  keep_cols <- intersect(
    c("title", "doi", "pmid", "altmetric_jid", "issns", "journal",
      "authors1", "type", "altmetric_id", "is_oa",
      "cited_by_fbwalls_count", "cited_by_posts_count",
      "cited_by_tweeters_count", "cited_by_videos_count",
      "cited_by_feeds_count", "cited_by_accounts_count",
      "score", "published_on", "added_on", "url"),
    names(results)
  )
  dplyr::select(results, dplyr::all_of(keep_cols))
}


#' Annotate a single ISBN using the Google Books API
#'
#' @param isbn_nb ISBN-10 or ISBN-13 string; hyphens and spaces are removed
#'   automatically.
#' @return A data frame with columns \code{title}, \code{publisher},
#'   \code{publishedDate}, \code{description}, \code{categories}, and
#'   \code{authors}, or \code{NULL} if the ISBN is not found.
#' @export
#' @examples
#' \dontrun{
#' annotate_isbn_google("978-0-15-603135-6")
#' }
annotate_isbn_google <- function(isbn_nb) {
  isbn_nb <- gsub("[-[:space:]]", "", isbn_nb)
  cmd <- paste0("https://www.googleapis.com/books/v1/volumes?q=isbn:", isbn_nb)
  resp   <- httr::GET(cmd)
  parsed <- jsonlite::fromJSON(
    httr::content(resp, "text", encoding = "UTF-8"),
    simplifyVector = TRUE
  )
  tryCatch({
    if (parsed$totalItems != 0L) {
      output_df <- parsed$items$volumeInfo[,
        c("title", "publisher", "publishedDate", "description")]
      output_df$categories <- paste(
        unlist(parsed$items$volumeInfo$categories), collapse = ", ")
      output_df$authors <- paste(
        unlist(parsed$items$volumeInfo$authors), collapse = ", ")
      return(output_df)
    }
    NULL
  }, error = function(e) NULL)
}


#' Annotate a single ISBN using the Open Library API
#'
#' @param isbn_nb ISBN-10 or ISBN-13 string; hyphens and spaces are removed
#'   automatically.
#' @return A data frame with Open Library metadata, or \code{NULL} if the
#'   ISBN is not found.
#' @export
#' @examples
#' \dontrun{
#' annotate_isbn_openlib("9780156031356")
#' }
annotate_isbn_openlib <- function(isbn_nb) {
  isbn_nb <- gsub("[-[:space:]]", "", isbn_nb)
  cmd <- paste0(
    "https://openlibrary.org/api/books?bibkeys=ISBN", isbn_nb, "&format=json"
  )
  resp   <- httr::GET(cmd)
  parsed <- jsonlite::fromJSON(
    httr::content(resp, "text", encoding = "UTF-8"),
    simplifyVector = TRUE
  )
  tryCatch(as.data.frame(parsed), error = function(e) NULL)
}


#' Annotate a list of ISBNs using Altmetric
#'
#' @param isbn_list A \emph{list} of ISBN character strings.
#' @return A data frame of Altmetric scores for the supplied ISBNs.
#' @export
#' @examples
#' \dontrun{
#' annotate_isbn_list_altmetrics(list(c("9780156031356")))
#' }
annotate_isbn_list_altmetrics <- function(isbn_list) {
  if (!requireNamespace("rAltmetric", quietly = TRUE)) {
    stop("Package 'rAltmetric' is required. Install it with: ",
         "remotes::install_github('ropensci/rAltmetric')", call. = FALSE)
  }
  alm <- function(x) {
    tryCatch(
      rAltmetric::altmetric_data(rAltmetric::altmetrics(isbn = x)),
      error = function(e) NULL
    )
  }
  purrr::pmap_df(isbn_list, alm)
}
