# Revert-based edit trend analysis across all Wikipedia articles

#' Count revert-tagged (or all) edits per article for a time window
#'
#' Queries the English Wikipedia MediaWiki API for all revisions whose
#' timestamps fall between \code{start} (newer) and \code{end} (older),
#' counts revisions tagged as \code{"mw-undo"} or \code{"mw-rollback"}
#' (revert-type edits) when \code{rev_eds = TRUE}, or counts all revisions
#' when \code{rev_eds = FALSE}.  Handles pagination automatically.
#'
#' @param start Character string — newer boundary of the query window in
#'   MediaWiki API timestamp format \code{"YYYYMMDDHHmmss"}
#'   (e.g. \code{"20181212010000"}).
#' @param end Character string — older boundary in the same format
#'   (e.g. \code{"20181212000000"}).
#' @param rev_eds Logical.  If \code{TRUE} (default), only revert-tagged edits
#'   (\code{"mw-undo"} or \code{"mw-rollback"}) are counted and the result
#'   column is named \code{sum_nb_reverts}.  If \code{FALSE}, all revisions
#'   are counted and the result column is named \code{sum_nb_edits}.
#' @return A data frame with columns:
#'   \describe{
#'     \item{\code{art}}{Article title.}
#'     \item{\code{sum_nb_reverts} or \code{sum_nb_edits}}{Total edit count
#'       within the time window (mode-dependent).}
#'   }
#'   Rows are ordered descending.  Articles with zero counts are excluded.
#' @export
#' @examples
#' \dontrun{
#' # Count revert edits for a one-hour window on 12 December 2018
#' get_revert_counts("20181212010000", "20181212000000")
#'
#' # Count ALL edits for the same window
#' get_revert_counts("20181212010000", "20181212000000", rev_eds = FALSE)
#' }
get_revert_counts <- function(start, end, rev_eds = TRUE) {

  if (rev_eds) {
    .count_fn <- function(rev) {
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
    count_col <- "sum_nb_reverts"
  } else {
    .count_fn <- function(rev) {
      if (!is.data.frame(rev) || nrow(rev) == 0L) 0L else as.integer(nrow(rev))
    }
    count_col <- "sum_nb_edits"
  }

  base_url <- paste0(
    "https://en.wikipedia.org/w/api.php?action=query&list=allrevisions",
    "&arvprop=ids|timestamp|flags|comment|user|size|tags",
    "&arvdir=older&arvlimit=max&format=json",
    "&arvend=", end, "&arvstart=", start
  )

  parsed <- jsonlite::fromJSON(
    httr2::request(base_url) |>
      httr2::req_retry(max_tries = 3, backoff = ~ 2^.x) |>
      httr2::req_perform() |>
      httr2::resp_body_string(),
    simplifyVector = TRUE
  )

  .extract_batch <- function(p) {
    ar <- p$query$allrevisions
    if (is.null(ar) || nrow(ar) == 0L) return(NULL)
    data.frame(
      art    = ar$title,
      nb_cnt = vapply(ar$revisions, .count_fn, integer(1L)),
      stringsAsFactors = FALSE
    )
  }

  output_table <- .extract_batch(parsed)

  while (length(parsed$continue$arvcontinue) == 1L) {
    rvc <- parsed$continue$arvcontinue
    cmd <- paste0(base_url, "&arvcontinue=", rvc)
    parsed <- jsonlite::fromJSON(
      httr2::request(cmd) |>
        httr2::req_retry(max_tries = 3, backoff = ~ 2^.x) |>
        httr2::req_perform() |>
        httr2::resp_body_string(),
      simplifyVector = TRUE
    )
    batch <- .extract_batch(parsed)
    if (is.null(batch)) break
    output_table <- tryCatch(rbind(output_table, batch),
                             error = function(e) output_table)
  }

  empty_df <- stats::setNames(
    data.frame(character(0), integer(0), stringsAsFactors = FALSE),
    c("art", count_col)
  )
  if (is.null(output_table)) return(empty_df)

  result <- output_table |>
    dplyr::group_by(art) |>
    dplyr::summarise(cnt = sum(nb_cnt), .groups = "drop") |>
    dplyr::arrange(dplyr::desc(cnt)) |>
    dplyr::filter(cnt > 0) |>
    as.data.frame()

  names(result)[names(result) == "cnt"] <- count_col
  result
}
