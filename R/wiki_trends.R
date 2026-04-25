# Revert-based edit trend analysis across all Wikipedia articles

#' Count revert-tagged edits per article for a time window
#'
#' Queries the English Wikipedia MediaWiki API for all revisions whose
#' timestamps fall between \code{start} (newer) and \code{end} (older),
#' counts revisions tagged as \code{"mw-undo"} or \code{"mw-rollback"}
#' (revert-type edits), and returns a sorted data frame of articles with
#' at least one such edit.
#'
#' The function handles pagination automatically — it follows all
#' \code{arvcontinue} tokens until the full time window has been fetched.
#'
#' @param start Character string — newer boundary of the query window in
#'   MediaWiki API timestamp format \code{"YYYYMMDDHHmmss"}
#'   (e.g. \code{"20181212010000"}).
#' @param end Character string — older boundary in the same format
#'   (e.g. \code{"20181212000000"}).
#' @return A data frame with columns:
#'   \describe{
#'     \item{\code{art}}{Article title.}
#'     \item{\code{sum_nb_reverts}}{Total number of revert-tagged edits
#'       within the time window.}
#'   }
#'   Rows are ordered by \code{sum_nb_reverts} descending.  Articles with
#'   zero reverts are excluded.
#' @export
#' @examples
#' \dontrun{
#' # Count revert edits for a one-hour window on 12 December 2018
#' get_revert_counts("20181212010000", "20181212000000")
#' }
get_revert_counts <- function(start, end) {

  .count_reverts <- function(rev) {
    if (!is.data.frame(rev) || nrow(rev) == 0L) return(0L)
    tags_col <- rev$tags
    if (is.list(tags_col)) {
      as.integer(sum(vapply(
        tags_col,
        function(t) any(t %in% c("mw-undo", "mw-rollback")),
        logical(1L)
      )))
    } else if (is.character(tags_col)) {
      as.integer(sum(tags_col %in% c("mw-undo", "mw-rollback")))
    } else {
      0L
    }
  }

  base_url <- paste0(
    "https://en.wikipedia.org/w/api.php?action=query&list=allrevisions",
    "&arvprop=ids|timestamp|flags|comment|user|size|tags",
    "&arvdir=older&arvlimit=max&format=json",
    "&arvend=", end, "&arvstart=", start
  )

  resp   <- httr::GET(base_url)
  parsed <- jsonlite::fromJSON(
    httr::content(resp, "text", encoding = "UTF-8"),
    simplifyVector = TRUE
  )

  .extract_batch <- function(p) {
    ar <- p$query$allrevisions
    if (is.null(ar) || nrow(ar) == 0L) return(NULL)
    data.frame(
      art        = ar$title,
      nb_reverts = vapply(ar$revisions, .count_reverts, integer(1L)),
      stringsAsFactors = FALSE
    )
  }

  output_table <- .extract_batch(parsed)

  while (length(parsed$continue$arvcontinue) == 1L) {
    rvc <- parsed$continue$arvcontinue
    cmd <- paste0(base_url, "&arvcontinue=", rvc)
    resp   <- httr::GET(cmd)
    parsed <- jsonlite::fromJSON(
      httr::content(resp, "text", encoding = "UTF-8"),
      simplifyVector = TRUE
    )
    batch <- .extract_batch(parsed)
    if (is.null(batch)) break
    output_table <- tryCatch(
      rbind(output_table, batch),
      error = function(e) output_table
    )
  }

  if (is.null(output_table)) return(data.frame(art = character(0),
                                               sum_nb_reverts = integer(0)))

  output_table |>
    dplyr::group_by(art) |>
    dplyr::summarise(sum_nb_reverts = sum(nb_reverts), .groups = "drop") |>
    dplyr::arrange(dplyr::desc(sum_nb_reverts)) |>
    dplyr::filter(sum_nb_reverts > 0) |>
    as.data.frame()
}
