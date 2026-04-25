# Retrieve article content, history/revisions, and metadata

# ── Internal helper ────────────────────────────────────────────────────────────

#' Build a tidy revision data frame from a parsed MediaWiki JSON response
#'
#' @param parsed List returned by \code{jsonlite::fromJSON()}.
#' @param article_name Character string — article title.
#' @return A data frame or \code{NULL} if the response contains no revisions.
#' @noRd
.parse_revisions <- function(parsed, article_name) {
  page_key <- names(parsed$query$pages)[1]
  revs <- parsed$query$pages[[page_key]]$revisions
  if (is.null(revs) || nrow(revs) == 0L) return(NULL)
  cols <- intersect(
    c("revid", "parentid", "user", "userid", "timestamp", "size", "comment", "*"),
    names(revs)
  )
  cbind(art = rep(article_name, nrow(revs)), revs[, cols, drop = FALSE])
}


# ── Core article-history functions ────────────────────────────────────────────

#' Retrieve the full revision history of a Wikipedia article
#'
#' Queries the English Wikipedia MediaWiki API and returns a data frame where
#' each row is one revision of the given article, ordered chronologically.
#'
#' @param article_name Character string giving the English Wikipedia article
#'   title (e.g. \code{"Zeitgeber"}).
#' @param date_an Character string — upper date limit for revisions in ISO 8601
#'   format (default: \code{"2020-05-01T00:00:00Z"}).
#' @return A data frame with columns \code{art}, \code{revid},
#'   \code{parentid}, \code{user}, \code{userid}, \code{timestamp},
#'   \code{size}, \code{comment}, and \code{*} (raw wikitext).
#' @export
#' @examples
#' \dontrun{
#' zeitgeber_history <- get_article_full_history_table("Zeitgeber")
#' }
get_article_full_history_table <- function(
    article_name,
    date_an = "2020-05-01T00:00:00Z") {

  what <- "ids|timestamp|comment|user|userid|size|content"
  article_name_c <- utils::URLencode(article_name, reserved = TRUE)
  output_table <- NULL

  cmd <- paste0(
    "https://en.wikipedia.org/w/api.php?action=query&titles=", article_name_c,
    "&prop=revisions&rvprop=", what,
    "&rvstart=01012001&rvdir=newer&rvend=", date_an,
    "&format=json&rvlimit=max"
  )
  resp   <- httr::GET(cmd)
  parsed <- jsonlite::fromJSON(
    httr::content(resp, "text", encoding = "UTF-8"),
    simplifyVector = TRUE
  )
  output_table <- .parse_revisions(parsed, article_name)

  while (length(parsed$continue$rvcontinue) == 1L) {
    rvc <- parsed$continue$rvcontinue
    cmd <- paste0(
      "https://en.wikipedia.org/w/api.php?action=query&titles=", article_name_c,
      "&prop=revisions&rvprop=", what,
      "&rvstart=01012001&rvdir=newer&rvend=", date_an,
      "&format=json&rvlimit=max&rvcontinue=", rvc
    )
    resp   <- httr::GET(cmd)
    parsed <- jsonlite::fromJSON(
      httr::content(resp, "text", encoding = "UTF-8"),
      simplifyVector = TRUE
    )
    batch <- .parse_revisions(parsed, article_name)
    if (is.null(batch)) break
    output_table <- tryCatch(
      rbind(output_table, batch),
      error = function(e) output_table
    )
  }
  output_table
}


#' Retrieve the first revision of a Wikipedia article
#'
#' @param article_name Character string giving the English Wikipedia article
#'   title.
#' @return A single-row data frame with the same columns as
#'   \code{\link{get_article_full_history_table}}.
#' @export
#' @examples
#' \dontrun{
#' get_article_initial_table("Zeitgeber")
#' }
get_article_initial_table <- function(article_name) {
  what <- "ids|timestamp|comment|user|userid|size|content"
  article_name_c <- utils::URLencode(article_name, reserved = TRUE)

  cmd <- paste0(
    "https://en.wikipedia.org/w/api.php?action=query&titles=", article_name_c,
    "&prop=revisions&rvprop=", what,
    "&rvstart=01012001&rvdir=newer&format=json&rvlimit=1"
  )
  resp   <- httr::GET(cmd)
  parsed <- jsonlite::fromJSON(
    httr::content(resp, "text", encoding = "UTF-8"),
    simplifyVector = TRUE
  )
  .parse_revisions(parsed, article_name)
}


#' Retrieve metadata for a Wikipedia article
#'
#' Returns a named vector containing the page ID, title, and byte length of
#' the current revision of the article.
#'
#' @param article_name Character string giving the English Wikipedia article
#'   title.
#' @param date_an Character string — reference date in ISO 8601 format
#'   (default: \code{"2020-05-01T00:00:00Z"}).
#' @return A named character vector with at least \code{pageid}, \code{title},
#'   and \code{length} elements.
#' @export
#' @examples
#' \dontrun{
#' get_article_info_table("Zeitgeber")
#' }
get_article_info_table <- function(article_name,
                                   date_an = "2020-05-01T00:00:00Z") {
  what <- "pageid|title|length"
  article_name_c <- utils::URLencode(article_name, reserved = TRUE)

  cmd <- paste0(
    "https://en.wikipedia.org/w/api.php?action=query&titles=", article_name_c,
    "&prop=info&inprop=", what,
    "&rvstart=", date_an, "&rvdir=older&format=json"
  )
  resp   <- httr::GET(cmd)
  parsed <- jsonlite::fromJSON(
    httr::content(resp, "text", encoding = "UTF-8"),
    simplifyVector = TRUE
  )
  page_key <- names(parsed$query$pages)[1]
  unlist(parsed$query$pages[[page_key]])
}


#' Retrieve the most recent revision of a Wikipedia article
#'
#' @param article_name Character string giving the English Wikipedia article
#'   title.
#' @param date_an Character string — upper date limit in ISO 8601 format
#'   (default: \code{"2020-05-01T00:00:00Z"}).
#' @return A single-row data frame with the same columns as
#'   \code{\link{get_article_full_history_table}}.
#' @export
#' @examples
#' \dontrun{
#' get_article_most_recent_table("Zeitgeber")
#' }
get_article_most_recent_table <- function(article_name,
                                          date_an = "2020-05-01T00:00:00Z") {
  what <- "ids|timestamp|comment|user|userid|size|content"
  article_name_c <- utils::URLencode(article_name, reserved = TRUE)

  cmd <- paste0(
    "https://en.wikipedia.org/w/api.php?action=query&titles=", article_name_c,
    "&prop=revisions&rvprop=", what,
    "&rvstart=", date_an, "&rvdir=older&format=json&rvlimit=1"
  )
  resp   <- httr::GET(cmd)
  parsed <- jsonlite::fromJSON(
    httr::content(resp, "text", encoding = "UTF-8"),
    simplifyVector = TRUE
  )
  .parse_revisions(parsed, article_name)
}


# ── Multi-article wrappers ────────────────────────────────────────────────────

#' Retrieve the full revision history for multiple Wikipedia articles
#'
#' Calls \code{\link{get_article_full_history_table}} for each element of
#' \code{list_art} and row-binds the results.
#'
#' @param list_art Character vector of English Wikipedia article titles.
#' @return A combined data frame with the same columns as
#'   \code{\link{get_article_full_history_table}}, or \code{NULL} if all
#'   requests fail.
#' @export
#' @examples
#' \dontrun{
#' get_category_articles_history(
#'   c("Zeitgeber", "Advanced sleep phase disorder", "Sleep deprivation")
#' )
#' }
get_category_articles_history <- function(list_art) {
  if (length(list_art) == 0L) return(NULL)
  dfn_art <- NULL
  for (art in seq_along(list_art)) {
    message("Fetching history: ", list_art[art])
    dfn_load <- tryCatch(
      get_article_full_history_table(list_art[art]),
      error = function(e) NULL
    )
    if (!is.null(dfn_load) && length(dfn_load) > 1L) {
      dfn_art <- rbind(dfn_art, dfn_load)
    }
  }
  dfn_art
}


#' Retrieve the creation revision for multiple Wikipedia articles
#'
#' Calls \code{\link{get_article_initial_table}} for each element of
#' \code{list_art} and row-binds the results.
#'
#' @param list_art Character vector of English Wikipedia article titles.
#' @return A combined data frame of first revisions, or \code{NULL} if all
#'   requests fail.
#' @export
#' @examples
#' \dontrun{
#' get_category_articles_creation(
#'   c("Zeitgeber", "Advanced sleep phase disorder", "Sleep deprivation")
#' )
#' }
get_category_articles_creation <- function(list_art) {
  if (length(list_art) == 0L) return(NULL)
  dfn_art <- NULL
  for (art in seq_along(list_art)) {
    message("Fetching creation: ", list_art[art])
    dfn_load <- tryCatch(
      get_article_initial_table(list_art[art]),
      error = function(e) NULL
    )
    if (!is.null(dfn_load) && length(dfn_load) > 1L) {
      dfn_art <- rbind(dfn_art, dfn_load)
    }
  }
  dfn_art
}


#' Retrieve the most recent revision for multiple Wikipedia articles
#'
#' Calls \code{\link{get_article_most_recent_table}} for each element of
#' \code{list_art} and row-binds the results.
#'
#' @param list_art Character vector of English Wikipedia article titles.
#' @return A combined data frame of most recent revisions, or \code{NULL} if
#'   all requests fail.
#' @export
#' @examples
#' \dontrun{
#' get_category_articles_most_recent(
#'   c("Zeitgeber", "Advanced sleep phase disorder", "Sleep deprivation")
#' )
#' }
get_category_articles_most_recent <- function(list_art) {
  if (length(list_art) == 0L) return(NULL)
  dfn_art <- NULL
  for (art in seq_along(list_art)) {
    message("Fetching most recent: ", list_art[art])
    dfn_load <- tryCatch(
      get_article_most_recent_table(list_art[art]),
      error = function(e) NULL
    )
    if (!is.null(dfn_load) && length(dfn_load) > 1L) {
      dfn_art <- rbind(dfn_art, dfn_load)
    }
  }
  dfn_art
}


#' Retrieve the names of pages belonging to a Wikipedia category
#'
#' Wraps \code{WikipediR::pages_in_category} and filters out user and
#' category pages.
#'
#' @param category Character string — Wikipedia category name
#'   (e.g. \code{"Circadian rhythm"}).
#' @return Character vector of article titles, or \code{NULL} on error.
#' @export
#' @examples
#' \dontrun{
#' get_pagename_in_cat("Circadian rhythm")
#' # Multiple categories:
#' unique(unlist(sapply(c("Circadian rhythm", "Sleep"), get_pagename_in_cat)))
#' }
get_pagename_in_cat <- function(category) {
  tryCatch({
    cats2 <- WikipediR::pages_in_category(
      "en", "wikipedia",
      categories = category,
      limit = 500
    )
    art_of_int <- character(0)
    for (i in seq_along(cats2$query$categorymembers)) {
      title <- cats2$query$categorymembers[[i]]$title
      if (grepl("^User:|^Category:", title)) next
      art_of_int <- c(art_of_int, title)
    }
    unlist(art_of_int)
  }, error = function(e) NULL)
}


#' Retrieve initial, most-recent, info, and full-history tables for a set of articles
#'
#' A convenience wrapper that calls
#' \code{\link{get_article_initial_table}},
#' \code{\link{get_article_most_recent_table}},
#' \code{\link{get_article_info_table}}, and
#' \code{\link{get_article_full_history_table}} for every title in
#' \code{all_art} and returns the four tables as a named list.
#'
#' @param all_art Character vector of English Wikipedia article titles.
#' @return A named list with elements \code{article_initial_table},
#'   \code{article_most_recent_table}, \code{article_info_table}, and
#'   \code{article_full_history_table}.
#' @export
#' @examples
#' \dontrun{
#' res <- get_tables_initial_most_recent_full_info(
#'   c("Zeitgeber", "Sleep deprivation")
#' )
#' }
get_tables_initial_most_recent_full_info <- function(all_art) {
  article_initial_table      <- NULL
  article_most_recent_table  <- NULL
  article_info_table         <- NULL
  article_full_history_table <- NULL

  for (i in seq_along(all_art)) {
    message("Processing: ", all_art[i])
    tryCatch({
      article_initial_table <- rbind(
        article_initial_table,
        get_article_initial_table(all_art[i])
      )
      article_most_recent_table <- rbind(
        article_most_recent_table,
        get_article_most_recent_table(all_art[i])
      )
      article_info_table <- rbind(
        article_info_table,
        get_article_info_table(all_art[i])
      )
      article_full_history_table <- rbind(
        article_full_history_table,
        get_article_full_history_table(all_art[i])
      )
    }, error = function(e) {
      message("  Error for ", all_art[i], ": ", conditionMessage(e))
    })
  }
  list(
    article_initial_table      = article_initial_table,
    article_most_recent_table  = article_most_recent_table,
    article_info_table         = article_info_table,
    article_full_history_table = article_full_history_table
  )
}


# ── Category / subcategory helpers ────────────────────────────────────────────

#' Retrieve subcategories of a Wikipedia category
#'
#' @param catname Character string — category name, with or without the
#'   \code{"Category:"} prefix.
#' @param replecement Character used to replace spaces in the category name
#'   for the API query (default: \code{"_"}).
#' @return A data frame of subcategory metadata with an additional column
#'   \code{parent_cat}.
#' @export
#' @examples
#' \dontrun{
#' get_subcat_table("Category:Biology")
#' }
get_subcat_table <- function(catname, replecement = "_") {
  cat_table <- NULL
  catname <- gsub("^Category:", "", catname)
  catname <- gsub(" ", replecement, catname)

  cmd <- paste0(
    "https://en.wikipedia.org/w/api.php?action=query&list=categorymembers",
    "&cmtitle=Category:", catname,
    "&cmlimit=500&cmprop=ids|title|type|timestamp",
    "&format=json&cmtype=subcat"
  )
  resp   <- httr::GET(cmd)
  parsed <- jsonlite::fromJSON(
    httr::content(resp, "text", encoding = "UTF-8"),
    simplifyVector = TRUE
  )
  cat_table <- rbind(cat_table, parsed$query$categorymembers)

  tryCatch({
    while (length(parsed$continue$cmcontinue) == 1L) {
      rvc <- parsed$continue$cmcontinue
      cmd <- paste0(
        "https://en.wikipedia.org/w/api.php?action=query&list=categorymembers",
        "&cmtitle=Category:", catname,
        "&cmlimit=500&cmprop=ids|title|type|timestamp",
        "&format=json&cmtype=subcat&cmcontinue=", rvc
      )
      resp   <- httr::GET(cmd)
      parsed <- jsonlite::fromJSON(
        httr::content(resp, "text", encoding = "UTF-8"),
        simplifyVector = TRUE
      )
      cat_table <- rbind(cat_table, parsed$query$categorymembers)
    }
  }, error = function(e) NULL)

  cat_table$parent_cat <- rep(paste0("Category:", catname), nrow(cat_table))
  cat_table
}


#' Retrieve pages in a Wikipedia category
#'
#' @param catname Character string — category name, with or without the
#'   \code{"Category:"} prefix.
#' @param replecement Character used to replace spaces (default: \code{"_"}).
#' @return A data frame of page metadata with an additional column
#'   \code{parent_cat}.
#' @export
#' @examples
#' \dontrun{
#' get_pages_in_cat_table("Category:Biology")
#' }
get_pages_in_cat_table <- function(catname, replecement = "_") {
  cat_table <- NULL
  catname <- gsub("^Category:", "", catname)
  catname <- gsub(" ", replecement, catname)

  cmd <- paste0(
    "https://en.wikipedia.org/w/api.php?action=query&list=categorymembers",
    "&cmtitle=Category:", catname,
    "&cmlimit=500&cmprop=ids|title|type|timestamp",
    "&format=json&cmtype=page"
  )
  resp   <- httr::GET(cmd)
  parsed <- jsonlite::fromJSON(
    httr::content(resp, "text", encoding = "UTF-8"),
    simplifyVector = TRUE
  )
  cat_table <- rbind(cat_table, parsed$query$categorymembers)

  tryCatch({
    while (length(parsed$continue$cmcontinue) == 1L) {
      rvc <- parsed$continue$cmcontinue
      cmd <- paste0(
        "https://en.wikipedia.org/w/api.php?action=query&list=categorymembers",
        "&cmtitle=Category:", catname,
        "&cmlimit=500&cmprop=ids|title|type|timestamp",
        "&format=json&cmtype=page&cmcontinue=", rvc
      )
      resp   <- httr::GET(cmd)
      parsed <- jsonlite::fromJSON(
        httr::content(resp, "text", encoding = "UTF-8"),
        simplifyVector = TRUE
      )
      cat_table <- rbind(cat_table, parsed$query$categorymembers)
    }
  }, error = function(e) NULL)

  cat_table$parent_cat <- rep(paste0("Category:", catname), nrow(cat_table))
  cat_table
}


#' Retrieve subcategories for multiple Wikipedia categories
#'
#' @param catlist Character vector of category names.
#' @param replecement Character used to replace spaces (default: \code{"_"}).
#' @return A combined data frame of subcategory metadata.
#' @export
#' @examples
#' \dontrun{
#' get_subcat_multiple(c("Category:Biology", "Category:Medicine"))
#' }
get_subcat_multiple <- function(catlist, replecement = "_") {
  cat_table_list <- NULL
  for (i in seq_along(catlist)) {
    tryCatch({
      cat_table_list <- rbind(
        cat_table_list,
        get_subcat_table(catlist[i], replecement)
      )
    }, error = function(e) NULL)
  }
  cat_table_list
}


#' Retrieve pages for multiple Wikipedia categories
#'
#' @param catlist Character vector of category names.
#' @param replecement Character used to replace spaces (default: \code{"_"}).
#' @return A combined data frame of page metadata.
#' @export
#' @examples
#' \dontrun{
#' get_page_in_cat_multiple(c("Category:Biology", "Category:Medicine"))
#' }
get_page_in_cat_multiple <- function(catlist, replecement = "_") {
  cat_table_list <- NULL
  for (i in seq_along(catlist)) {
    tryCatch({
      cat_table_list <- rbind(
        cat_table_list,
        get_pages_in_cat_table(catlist[i], replecement)
      )
    }, error = function(e) NULL)
  }
  cat_table_list
}


#' Recursively retrieve subcategories up to a given depth
#'
#' @param catname Character string — root category name.
#' @param depth Integer — number of levels to descend.
#' @param replecement Character used to replace spaces (default: \code{"_"}).
#' @return A data frame of all unique subcategories up to \code{depth} levels
#'   below \code{catname}.
#' @export
#' @examples
#' \dontrun{
#' get_subcat_with_depth("Category:Biology", depth = 2)
#' }
get_subcat_with_depth <- function(catname, depth, replecement = "_") {
  table_out <- get_subcat_table(catname)
  while (depth > 0L) {
    table_out <- rbind(
      table_out,
      get_subcat_multiple(table_out$title, replecement)
    )
    depth <- depth - 1L
  }
  unique(table_out)
}


# ── Visualisations ─────────────────────────────────────────────────────────────

#' Plot article creation dates over time
#'
#' Displays either the per-year count or the cumulative count of article
#' creation dates.
#'
#' @param article_initial_table A data frame of initial revisions as returned
#'   by \code{\link{get_article_initial_table}} or
#'   \code{\link{get_category_articles_creation}}.
#' @param name_title Character string used as the plot title.
#' @param Cumsum Logical.  If \code{TRUE} (default) a cumulative curve is
#'   plotted; if \code{FALSE} annual counts are plotted instead.
#' @return A \code{ggplot2} object (invisibly).
#' @export
#' @examples
#' \dontrun{
#' initial <- get_category_articles_creation(
#'   c("Zeitgeber", "Advanced sleep phase disorder")
#' )
#' plot_article_creation_per_year(initial, "Sleep articles")
#' }
plot_article_creation_per_year <- function(article_initial_table,
                                           name_title,
                                           Cumsum = TRUE) {
  data_edit_pattern <- article_initial_table
  data_edit_pattern$tsc <- as.Date(
    matrix(
      unlist(strsplit(as.character(data_edit_pattern$timestamp), "T")),
      byrow = TRUE, ncol = 2
    )[, 1]
  )

  dfcr <- data_edit_pattern |>
    dplyr::group_by(art) |>
    dplyr::mutate(first = dplyr::first(tsc)) |>
    as.data.frame() |>
    dplyr::select(art, tsc) |>
    unique()

  dfcr_bin <- data.frame(
    count = as.numeric(table(cut(dfcr$tsc, breaks = "1 year"))),
    date  = as.Date(names(table(cut(dfcr$tsc, breaks = "1 year"))))
  )

  if (Cumsum) {
    p <- ggplot2::ggplot(dfcr_bin, ggplot2::aes(x = date, y = cumsum(count))) +
      ggplot2::scale_x_date() +
      ggplot2::geom_point() +
      ggplot2::geom_line() +
      ggplot2::ggtitle(name_title) +
      ggplot2::theme_classic()
  } else {
    p <- ggplot2::ggplot(dfcr_bin, ggplot2::aes(x = date, y = count)) +
      ggplot2::scale_x_date() +
      ggplot2::geom_point() +
      ggplot2::geom_line() +
      ggplot2::ggtitle(name_title) +
      ggplot2::theme_classic()
  }
  print(p)
  invisible(p)
}


#' Plot a static timeline of article creation dates
#'
#' @param article_initial_table_sel A data frame of initial revisions as
#'   returned by \code{\link{get_article_initial_table}} or
#'   \code{\link{get_category_articles_creation}}.
#' @return A \code{ggplot2} object (invisibly).
#' @export
#' @examples
#' \dontrun{
#' initial <- get_category_articles_creation(
#'   c("Zeitgeber", "Advanced sleep phase disorder")
#' )
#' plot_static_timeline(initial)
#' }
plot_static_timeline <- function(article_initial_table_sel) {
  article_initial_table_sel$tsc <- as.Date(
    matrix(
      unlist(strsplit(as.character(article_initial_table_sel$timestamp), "T")),
      byrow = TRUE, ncol = 2
    )[, 1]
  )

  dfcr <- article_initial_table_sel |>
    dplyr::group_by(art) |>
    dplyr::mutate(first = dplyr::first(tsc)) |>
    as.data.frame() |>
    dplyr::select(art, tsc) |>
    unique()

  sel_tmp <- article_initial_table_sel[, c("revid", "art", "user", "size", "timestamp")]
  dfcr    <- dplyr::inner_join(dfcr, sel_tmp, by = "art")

  p <- ggplot2::ggplot(dfcr, ggplot2::aes(x = tsc, y = 0)) +
    ggplot2::geom_point() +
    ggrepel::geom_label_repel(
      ggplot2::aes(label = art),
      nudge_y       = 1,
      direction     = "y",
      angle         = 0,
      vjust         = 0,
      segment.alpha = 0.2,
      size          = 3,
      segment.size  = 0.5
    ) +
    ggplot2::scale_x_date() +
    ggplot2::theme_minimal() +
    ggplot2::ylim(0, 1) +
    ggplot2::scale_colour_brewer("type", palette = "Dark2") +
    ggplot2::scale_fill_brewer("type", palette = "Dark2") +
    ggplot2::theme(legend.position = "bottom")

  print(p)
  invisible(p)
}


#' Plot an interactive timeline of article creation dates
#'
#' Currently a stub — the \pkg{timevis} package is not available on CRAN.
#' The function issues an informative message and returns \code{NULL}
#' invisibly.  Use \code{\link{plot_static_timeline}} for a static equivalent.
#'
#' @param article_initial_table_sel A data frame of initial revisions.
#' @param article_info_table A data frame of article metadata as returned by
#'   \code{\link{get_article_info_table}}.
#' @return \code{NULL}, invisibly.
#' @export
#' @examples
#' \dontrun{
#' initial <- get_article_initial_table("Zeitgeber")
#' info    <- get_article_info_table("Zeitgeber")
#' plot_navi_timeline(initial, info)
#' }
plot_navi_timeline <- function(article_initial_table_sel, article_info_table) {
  message(
    "plot_navi_timeline() is currently unavailable: the 'timevis' package ",
    "is not on CRAN. Use plot_static_timeline() for a static equivalent."
  )
  invisible(NULL)
}


#' Plot daily Wikipedia page views for an article
#'
#' Queries the Wikimedia pageviews API and plots daily view counts as an area
#' chart.
#'
#' @param article_name Character string — English Wikipedia article title.
#' @param ymax Optional numeric upper limit for the y-axis.
#' @param start Start date in \code{"YYYYMMDDHH"} format
#'   (default: \code{"2020010100"}).
#' @param end End date in \code{"YYYYMMDDHH"} format
#'   (default: \code{"2020050100"}).
#' @return A \code{ggplot2} object (invisibly).
#' @export
#' @examples
#' \dontrun{
#' page_view_plot("Zeitgeber", start = "2020010100", end = "2020050100")
#' }
page_view_plot <- function(article_name, ymax = NA,
                           start = "2020010100", end = "2020050100") {
  page_view      <- data.frame(
    WikipediR::article_pageviews(
      project = "en.wikipedia",
      article = article_name,
      start   = start,
      end     = end
    )
  )
  page_view$date <- lubridate::ymd(page_view$date)
  start_date     <- as.Date(as.POSIXlt(start, format = "%Y%m%d%H", tz = "GMT"))
  end_date       <- as.Date(as.POSIXlt(end,   format = "%Y%m%d%H", tz = "GMT"))

  p <- ggplot2::ggplot(page_view, ggplot2::aes(date, views)) +
    ggplot2::geom_area(fill = "darkgreen") +
    ggplot2::theme_classic() +
    ggplot2::ggtitle(paste(article_name, "daily views")) +
    ggplot2::scale_y_continuous(limits = c(0, ymax), expand = c(0, 0)) +
    ggplot2::scale_x_date(limits = c(start_date, end_date))

  print(p)
  invisible(p)
}


#' Plot weekly edit counts for a Wikipedia article
#'
#' Retrieves the full revision history and plots the number of edits per week
#' as an area chart.
#'
#' @param article_name Character string — English Wikipedia article title.
#' @param ymax Optional numeric upper limit for the y-axis.
#' @param start Start date in \code{"YYYYMMDDHH"} format
#'   (default: \code{"2020010100"}).
#' @param end End date in \code{"YYYYMMDDHH"} format
#'   (default: \code{"2020050100"}).
#' @return A \code{ggplot2} object (invisibly).
#' @export
#' @examples
#' \dontrun{
#' page_edit_plot("Zeitgeber", start = "2019010100", end = "2021010100")
#' }
page_edit_plot <- function(article_name, ymax = NA,
                           start = "2020010100", end = "2020050100") {
  history     <- get_article_full_history_table(article_name)
  history$ts  <- as.Date(
    sapply(history$timestamp, function(x) unlist(strsplit(x, "T"))[1])
  )
  start_date  <- as.Date(as.POSIXlt(start, format = "%Y%m%d%H", tz = "GMT"))
  end_date    <- as.Date(as.POSIXlt(end,   format = "%Y%m%d%H", tz = "GMT"))

  df_edits <- dplyr::select(history, ts) |>
    dplyr::filter(ts > start_date & ts < end_date)

  df_edits_bin <- data.frame(
    count = as.numeric(table(cut(df_edits$ts, breaks = "1 week"))),
    date  = as.Date(names(table(cut(df_edits$ts, breaks = "1 week"))))
  )

  p <- ggplot2::ggplot(df_edits_bin, ggplot2::aes(date, count)) +
    ggplot2::geom_area(fill = "darkred") +
    ggplot2::theme_classic() +
    ggplot2::ggtitle(paste(article_name, "weekly edits")) +
    ggplot2::scale_y_continuous(limits = c(0, ymax), expand = c(0, 0)) +
    ggplot2::scale_x_date(limits = c(start_date, end_date))

  print(p)
  invisible(p)
}
