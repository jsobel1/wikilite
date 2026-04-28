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
  required_cols <- c(
    "id", "source", "pmid", "pmcid", "doi", "title",
    "authorString", "journalTitle", "pubYear", "pubType",
    "isOpenAccess", "citedByCount", "firstPublicationDate"
  )

  p <- .progress_start("Annotating DOIs (EuropePMC)", total = length(doi_list))
  on.exit(.progress_done(p), add = TRUE)

  rows <- lapply(seq_along(doi_list), function(i) {
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
    .progress_update(p)
    if (is.null(load) || nrow(load) == 0L) return(NULL)

    # Guard: EuropePMC occasionally returns results without a `doi` column
    if (!"doi" %in% names(load)) load$doi <- NA_character_

    # Select the row whose DOI exactly matches; fall back to the first hit
    exact <- load[!is.na(load$doi) & tolower(load$doi) == tolower(doi_list[i]), ,
                  drop = FALSE]
    if (nrow(exact) == 0L) exact <- load[1L, , drop = FALSE]
    load <- exact[1L, , drop = FALSE]

    for (col in required_cols) {
      if (!col %in% names(load)) load[[col]] <- NA
    }
    tryCatch(
      dplyr::select(load, dplyr::all_of(required_cols)),
      error = function(e) NULL
    )
  })

  data.frame(dplyr::bind_rows(Filter(Negate(is.null), rows)))
}


#' Annotate a list of DOIs using CrossRef
#'
#' Queries the CrossRef \code{/works} API for each DOI and returns a tidy data
#' frame of bibliographic metadata.  Column names are aligned with those
#' returned by \code{\link{annotate_doi_list_europmc}} to allow easy
#' \code{coalesce}-based merging.
#'
#' @param doi_list Character vector of DOIs.
#' @param batch_size Integer.  Number of DOIs per \code{cr_works} request
#'   (default 50).
#' @return A data frame with columns \code{doi}, \code{title},
#'   \code{authorString}, \code{journalTitle}, \code{pubYear},
#'   \code{pubType}, \code{publisher}, \code{issn}, \code{volume},
#'   \code{issue}, \code{page}, and \code{citedByCount}.
#' @export
#' @examples
#' \dontrun{
#' annotate_doi_list_cross_ref(c("10.1038/nature16961"))
#' }
annotate_doi_list_cross_ref <- function(doi_list, batch_size = 50L) {
  # Internal helper: extract a 4-digit year from a list-column cell
  .cr_year <- function(x) {
    v <- unlist(x)
    if (length(v) == 0L || all(is.na(v))) return(NA_integer_)
    suppressWarnings(as.integer(substr(as.character(v[!is.na(v)][1L]), 1L, 4L)))
  }

  batches <- split(doi_list, ceiling(seq_along(doi_list) / batch_size))

  p <- .progress_start("Annotating DOIs (CrossRef)", total = length(doi_list))
  on.exit(.progress_done(p), add = TRUE)

  rows <- lapply(batches, function(batch) {
    out <- tryCatch({
      res <- rcrossref::cr_works(dois = batch)
      d   <- res$data
      if (is.null(d) || nrow(d) == 0L) return(NULL)

      lapply(seq_len(nrow(d)), function(i) {
        # Authors: "Family, G; ..." — graceful if author list is missing
        au_df  <- tryCatch(d$author[[i]], error = function(e) NULL)
        au_str <- if (is.data.frame(au_df) && "family" %in% names(au_df)) {
          given  <- if ("given" %in% names(au_df)) au_df$given else rep(NA_character_, nrow(au_df))
          paste(ifelse(is.na(given), au_df$family,
                       paste(au_df$family, given, sep = ", ")),
                collapse = "; ")
        } else NA_character_

        # Year: published.print > issued
        yr <- .cr_year(d$published.print[i])
        if (is.na(yr)) yr <- .cr_year(d$issued[i])

        data.frame(
          doi          = tolower(trimws(as.character(d$doi[i]))),
          title        = paste(unlist(d$title[i]),            collapse = ""),
          authorString = au_str,
          journalTitle = paste(unlist(d[["container.title"]][i]), collapse = ""),
          pubYear      = yr,
          pubType      = paste(unlist(d$type[i]),             collapse = ""),
          publisher    = paste(unlist(d$publisher[i]),        collapse = ""),
          issn         = paste(unlist(d$issn[i]),             collapse = "; "),
          volume       = paste(unlist(d$volume[i]),           collapse = ""),
          issue        = paste(unlist(d$issue[i]),            collapse = ""),
          page         = paste(unlist(d$page[i]),             collapse = ""),
          citedByCount = suppressWarnings(
            as.integer(d$is.referenced.by.count[i])),
          stringsAsFactors = FALSE
        )
      }) |> dplyr::bind_rows()
    }, error = function(e) {
      warning("CrossRef batch failed: ", conditionMessage(e))
      NULL
    })
  })

  dplyr::bind_rows(Filter(Negate(is.null), rows))
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
  url     <- paste0("https://www.googleapis.com/books/v1/volumes?q=isbn:", isbn_nb)
  body    <- tryCatch(.wiki_api_get(url), error = function(e) NULL)
  if (is.null(body)) return(NULL)
  parsed  <- jsonlite::fromJSON(body, simplifyVector = TRUE)
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
  url     <- paste0(
    "https://openlibrary.org/api/books?bibkeys=ISBN", isbn_nb, "&format=json"
  )
  body   <- tryCatch(.wiki_api_get(url), error = function(e) NULL)
  if (is.null(body)) return(NULL)
  parsed <- jsonlite::fromJSON(body, simplifyVector = TRUE)
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
