# Retrieve article content, history/revisions, and metadata

# ── Internal helpers ────────────────────────────────────────────────────────────

#' @noRd
.wiki_api_get <- function(url) {
  httr2::request(url) |>
    httr2::req_retry(max_tries = 3, backoff = ~ 2^.x) |>
    httr2::req_perform() |>
    httr2::resp_body_string()
}

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
#' Queries the Wikipedia MediaWiki API and returns a data frame where
#' each row is one revision of the given article, ordered chronologically.
#'
#' @param article_name Character string giving the Wikipedia article title
#'   (e.g. \code{"Zeitgeber"}).
#' @param date_an Character string — upper date limit for revisions in ISO 8601
#'   format.  Default: current UTC time.
#' @param lang Two-letter language code for the Wikipedia edition to query
#'   (default: \code{"en"} for English).
#' @param use_cache Logical.  When \code{TRUE} (default), results are cached to
#'   disk and reused on repeated calls with the same arguments.
#' @return A data frame with columns \code{art}, \code{revid},
#'   \code{parentid}, \code{user}, \code{userid}, \code{timestamp},
#'   \code{size}, \code{comment}, and \code{*} (raw wikitext).
#' @export
#' @examples
#' \dontrun{
#' zeitgeber_history <- get_article_full_history_table("Zeitgeber")
#' french_history    <- get_article_full_history_table("COVID-19", lang = "fr")
#' }
get_article_full_history_table <- function(article_name,
                                            date_an   = NULL,
                                            lang      = "en",
                                            use_cache = TRUE) {
  if (is.null(date_an))
    date_an <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

  if (use_cache) {
    key    <- .cache_key(article_name, date_an, lang, "full")
    cached <- .cache_get(key)
    if (!is.null(cached)) return(cached)
  }

  what           <- "ids|timestamp|comment|user|userid|size|content"
  article_name_c <- utils::URLencode(article_name, reserved = TRUE)
  base           <- paste0("https://", lang, ".wikipedia.org/w/api.php")
  output_table   <- NULL

  cmd <- paste0(
    base, "?action=query&titles=", article_name_c,
    "&prop=revisions&rvprop=", what,
    "&rvstart=01012001&rvdir=newer&rvend=", date_an,
    "&format=json&rvlimit=max"
  )
  parsed       <- jsonlite::fromJSON(.wiki_api_get(cmd), simplifyVector = TRUE)
  output_table <- .parse_revisions(parsed, article_name)

  while (length(parsed$continue$rvcontinue) == 1L) {
    rvc <- parsed$continue$rvcontinue
    cmd <- paste0(
      base, "?action=query&titles=", article_name_c,
      "&prop=revisions&rvprop=", what,
      "&rvstart=01012001&rvdir=newer&rvend=", date_an,
      "&format=json&rvlimit=max&rvcontinue=", rvc
    )
    parsed <- jsonlite::fromJSON(.wiki_api_get(cmd), simplifyVector = TRUE)
    batch  <- .parse_revisions(parsed, article_name)
    if (is.null(batch)) break
    output_table <- tryCatch(rbind(output_table, batch),
                             error = function(e) output_table)
  }

  if (use_cache && !is.null(output_table))
    .cache_set(key, output_table)

  output_table
}


#' Retrieve the first revision of a Wikipedia article
#'
#' @param article_name Character string giving the Wikipedia article title.
#' @param lang Two-letter language code (default: \code{"en"}).
#' @return A single-row data frame with the same columns as
#'   \code{\link{get_article_full_history_table}}.
#' @export
#' @examples
#' \dontrun{
#' get_article_initial_table("Zeitgeber")
#' }
get_article_initial_table <- function(article_name, lang = "en") {
  what           <- "ids|timestamp|comment|user|userid|size|content"
  article_name_c <- utils::URLencode(article_name, reserved = TRUE)
  base           <- paste0("https://", lang, ".wikipedia.org/w/api.php")

  cmd <- paste0(
    base, "?action=query&titles=", article_name_c,
    "&prop=revisions&rvprop=", what,
    "&rvstart=01012001&rvdir=newer&format=json&rvlimit=1"
  )
  parsed <- jsonlite::fromJSON(.wiki_api_get(cmd), simplifyVector = TRUE)
  .parse_revisions(parsed, article_name)
}


#' Retrieve metadata for a Wikipedia article
#'
#' Returns a named vector containing the page ID, title, and byte length of
#' the current revision of the article.
#'
#' @param article_name Character string giving the Wikipedia article title.
#' @param date_an Character string — reference date in ISO 8601 format.
#'   Default: current UTC time.
#' @param lang Two-letter language code (default: \code{"en"}).
#' @return A named character vector with at least \code{pageid}, \code{title},
#'   and \code{length} elements.
#' @export
#' @examples
#' \dontrun{
#' get_article_info_table("Zeitgeber")
#' }
get_article_info_table <- function(article_name,
                                   date_an = NULL,
                                   lang    = "en") {
  if (is.null(date_an))
    date_an <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

  what           <- "pageid|title|length"
  article_name_c <- utils::URLencode(article_name, reserved = TRUE)
  base           <- paste0("https://", lang, ".wikipedia.org/w/api.php")

  cmd <- paste0(
    base, "?action=query&titles=", article_name_c,
    "&prop=info&inprop=", what,
    "&rvstart=", date_an, "&rvdir=older&format=json"
  )
  parsed   <- jsonlite::fromJSON(.wiki_api_get(cmd), simplifyVector = TRUE)
  page_key <- names(parsed$query$pages)[1]
  unlist(parsed$query$pages[[page_key]])
}


#' Retrieve the most recent revision of a Wikipedia article
#'
#' @param article_name Character string giving the Wikipedia article title.
#' @param date_an Character string — upper date limit in ISO 8601 format.
#'   Default: current UTC time.
#' @param lang Two-letter language code (default: \code{"en"}).
#' @param use_cache Logical.  When \code{TRUE} (default), results are cached
#'   to disk.
#' @return A single-row data frame with the same columns as
#'   \code{\link{get_article_full_history_table}}.
#' @export
#' @examples
#' \dontrun{
#' get_article_most_recent_table("Zeitgeber")
#' get_article_most_recent_table("COVID-19", lang = "fr")
#' }
get_article_most_recent_table <- function(article_name,
                                          date_an   = NULL,
                                          lang      = "en",
                                          use_cache = TRUE) {
  if (is.null(date_an))
    date_an <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

  if (use_cache) {
    key    <- .cache_key(article_name, date_an, lang, "recent")
    cached <- .cache_get(key)
    if (!is.null(cached)) return(cached)
  }

  what           <- "ids|timestamp|comment|user|userid|size|content"
  article_name_c <- utils::URLencode(article_name, reserved = TRUE)
  base           <- paste0("https://", lang, ".wikipedia.org/w/api.php")

  cmd <- paste0(
    base, "?action=query&titles=", article_name_c,
    "&prop=revisions&rvprop=", what,
    "&rvstart=", date_an, "&rvdir=older&format=json&rvlimit=1"
  )
  parsed <- jsonlite::fromJSON(.wiki_api_get(cmd), simplifyVector = TRUE)
  result <- .parse_revisions(parsed, article_name)

  if (use_cache && !is.null(result))
    .cache_set(key, result)

  result
}


# ── Multi-article wrappers ────────────────────────────────────────────────────

#' Retrieve the full revision history for multiple Wikipedia articles
#'
#' Calls \code{\link{get_article_full_history_table}} for each element of
#' \code{list_art} and row-binds the results.
#'
#' @param list_art Character vector of Wikipedia article titles.
#' @param lang Two-letter language code (default: \code{"en"}).
#' @param workers Integer.  Number of parallel workers when \pkg{furrr} is
#'   installed (default: \code{1L} — sequential).
#' @return A combined data frame, or \code{NULL} if all requests fail.
#' @export
#' @examples
#' \dontrun{
#' get_category_articles_history(
#'   c("Zeitgeber", "Advanced sleep phase disorder", "Sleep deprivation")
#' )
#' }
get_category_articles_history <- function(list_art, lang = "en", workers = 1L) {
  if (length(list_art) == 0L) return(NULL)

  # Parallel branch can't share a serial progress bar, so we only wire one
  # in for the (default) sequential path.
  if (workers > 1L && requireNamespace("furrr", quietly = TRUE) &&
      requireNamespace("future", quietly = TRUE)) {
    fetch_one <- function(art) {
      message("Fetching history: ", art)
      tryCatch(get_article_full_history_table(art, lang = lang),
               error = function(e) NULL)
    }
    future::plan(future::multisession, workers = workers)
    on.exit(future::plan(future::sequential), add = TRUE)
    results <- furrr::future_map(list_art, fetch_one,
                                  .options = furrr::furrr_options(seed = TRUE))
  } else {
    p <- .progress_start("Fetching article histories", total = length(list_art))
    on.exit(.progress_done(p), add = TRUE)
    results <- lapply(list_art, function(art) {
      out <- tryCatch(get_article_full_history_table(art, lang = lang),
                      error = function(e) NULL)
      .progress_update(p)
      out
    })
  }

  dplyr::bind_rows(Filter(Negate(is.null), results))
}


#' Retrieve the creation revision for multiple Wikipedia articles
#'
#' Calls \code{\link{get_article_initial_table}} for each element of
#' \code{list_art} and row-binds the results.
#'
#' @param list_art Character vector of Wikipedia article titles.
#' @param lang Two-letter language code (default: \code{"en"}).
#' @return A combined data frame of first revisions, or \code{NULL} if all
#'   requests fail.
#' @export
#' @examples
#' \dontrun{
#' get_category_articles_creation(
#'   c("Zeitgeber", "Advanced sleep phase disorder", "Sleep deprivation")
#' )
#' }
get_category_articles_creation <- function(list_art, lang = "en") {
  if (length(list_art) == 0L) return(NULL)
  p <- .progress_start("Fetching creation revisions", total = length(list_art))
  on.exit(.progress_done(p), add = TRUE)
  results <- lapply(list_art, function(art) {
    out <- tryCatch(get_article_initial_table(art, lang = lang),
                    error = function(e) NULL)
    .progress_update(p)
    out
  })
  dplyr::bind_rows(Filter(Negate(is.null), results))
}


#' Retrieve the most recent revision for multiple Wikipedia articles
#'
#' Calls \code{\link{get_article_most_recent_table}} for each element of
#' \code{list_art} and row-binds the results.
#'
#' @param list_art Character vector of Wikipedia article titles.
#' @param date_an Character string — upper date limit in ISO 8601 format.
#'   Default: current UTC time.
#' @param lang Two-letter language code (default: \code{"en"}).
#' @return A combined data frame of most recent revisions, or \code{NULL} if
#'   all requests fail.
#' @export
#' @examples
#' \dontrun{
#' get_category_articles_most_recent(
#'   c("Zeitgeber", "Advanced sleep phase disorder", "Sleep deprivation")
#' )
#' }
get_category_articles_most_recent <- function(list_art,
                                              date_an = NULL,
                                              lang    = "en") {
  if (length(list_art) == 0L) return(NULL)
  p <- .progress_start("Fetching most-recent revisions", total = length(list_art))
  on.exit(.progress_done(p), add = TRUE)
  results <- lapply(list_art, function(art) {
    out <- tryCatch(get_article_most_recent_table(art, date_an = date_an, lang = lang),
                    error = function(e) NULL)
    .progress_update(p)
    out
  })
  dplyr::bind_rows(Filter(Negate(is.null), results))
}


#' Retrieve the names of pages belonging to a Wikipedia category
#'
#' Wraps \code{WikipediR::pages_in_category} and filters out user and
#' category pages.
#'
#' @param category Character string — Wikipedia category name
#'   (e.g. \code{"Circadian rhythm"}).
#' @param lang Two-letter language code (default: \code{"en"}).
#' @return Character vector of article titles, or \code{NULL} on error.
#' @export
#' @examples
#' \dontrun{
#' get_pagename_in_cat("Circadian rhythm")
#' get_pagename_in_cat("Rythme_circadien", lang = "fr")
#' }
get_pagename_in_cat <- function(category, lang = "en") {
  tryCatch({
    cats2 <- WikipediR::pages_in_category(
      lang, "wikipedia",
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
#' @param all_art Character vector of Wikipedia article titles.
#' @param lang Two-letter language code (default: \code{"en"}).
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
get_tables_initial_most_recent_full_info <- function(all_art, lang = "en") {
  article_initial_table      <- NULL
  article_most_recent_table  <- NULL
  article_info_table         <- NULL
  article_full_history_table <- NULL

  for (i in seq_along(all_art)) {
    message("Processing: ", all_art[i])
    tryCatch({
      article_initial_table <- rbind(
        article_initial_table,
        get_article_initial_table(all_art[i], lang = lang)
      )
      article_most_recent_table <- rbind(
        article_most_recent_table,
        get_article_most_recent_table(all_art[i], lang = lang)
      )
      article_info_table <- rbind(
        article_info_table,
        get_article_info_table(all_art[i], lang = lang)
      )
      article_full_history_table <- rbind(
        article_full_history_table,
        get_article_full_history_table(all_art[i], lang = lang)
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
#' @param replacement Character used to replace spaces in the category name
#'   for the API query (default: \code{"_"}).
#' @param lang Two-letter language code (default: \code{"en"}).
#' @return A data frame of subcategory metadata with an additional column
#'   \code{parent_cat}.
#' @export
#' @examples
#' \dontrun{
#' get_subcat_table("Category:Biology")
#' }
get_subcat_table <- function(catname, replacement = "_", lang = "en") {
  cat_table <- NULL
  catname   <- gsub("^Category:", "", catname)
  catname   <- gsub(" ", replacement, catname)
  base      <- paste0("https://", lang, ".wikipedia.org/w/api.php")

  cmd <- paste0(
    base, "?action=query&list=categorymembers",
    "&cmtitle=Category:", catname,
    "&cmlimit=500&cmprop=ids|title|type|timestamp",
    "&format=json&cmtype=subcat"
  )
  parsed    <- jsonlite::fromJSON(.wiki_api_get(cmd), simplifyVector = TRUE)
  cat_table <- rbind(cat_table, parsed$query$categorymembers)

  tryCatch({
    while (length(parsed$continue$cmcontinue) == 1L) {
      rvc <- parsed$continue$cmcontinue
      cmd <- paste0(
        base, "?action=query&list=categorymembers",
        "&cmtitle=Category:", catname,
        "&cmlimit=500&cmprop=ids|title|type|timestamp",
        "&format=json&cmtype=subcat&cmcontinue=", rvc
      )
      parsed    <- jsonlite::fromJSON(.wiki_api_get(cmd), simplifyVector = TRUE)
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
#' @param replacement Character used to replace spaces (default: \code{"_"}).
#' @param lang Two-letter language code (default: \code{"en"}).
#' @return A data frame of page metadata with an additional column
#'   \code{parent_cat}.
#' @export
#' @examples
#' \dontrun{
#' get_pages_in_cat_table("Category:Biology")
#' }
get_pages_in_cat_table <- function(catname, replacement = "_", lang = "en") {
  cat_table <- NULL
  catname   <- gsub("^Category:", "", catname)
  catname   <- gsub(" ", replacement, catname)
  base      <- paste0("https://", lang, ".wikipedia.org/w/api.php")

  cmd <- paste0(
    base, "?action=query&list=categorymembers",
    "&cmtitle=Category:", catname,
    "&cmlimit=500&cmprop=ids|title|type|timestamp",
    "&format=json&cmtype=page"
  )
  parsed    <- jsonlite::fromJSON(.wiki_api_get(cmd), simplifyVector = TRUE)
  cat_table <- rbind(cat_table, parsed$query$categorymembers)

  tryCatch({
    while (length(parsed$continue$cmcontinue) == 1L) {
      rvc <- parsed$continue$cmcontinue
      cmd <- paste0(
        base, "?action=query&list=categorymembers",
        "&cmtitle=Category:", catname,
        "&cmlimit=500&cmprop=ids|title|type|timestamp",
        "&format=json&cmtype=page&cmcontinue=", rvc
      )
      parsed    <- jsonlite::fromJSON(.wiki_api_get(cmd), simplifyVector = TRUE)
      cat_table <- rbind(cat_table, parsed$query$categorymembers)
    }
  }, error = function(e) NULL)

  cat_table$parent_cat <- rep(paste0("Category:", catname), nrow(cat_table))
  cat_table
}


#' Retrieve subcategories for multiple Wikipedia categories
#'
#' @param catlist Character vector of category names.
#' @param replacement Character used to replace spaces (default: \code{"_"}).
#' @param lang Two-letter language code (default: \code{"en"}).
#' @return A combined data frame of subcategory metadata.
#' @export
#' @examples
#' \dontrun{
#' get_subcat_multiple(c("Category:Biology", "Category:Medicine"))
#' }
get_subcat_multiple <- function(catlist, replacement = "_", lang = "en") {
  dplyr::bind_rows(lapply(catlist, function(cat) {
    tryCatch(get_subcat_table(cat, replacement, lang = lang),
             error = function(e) NULL)
  }))
}


#' Retrieve pages for multiple Wikipedia categories
#'
#' @param catlist Character vector of category names.
#' @param replacement Character used to replace spaces (default: \code{"_"}).
#' @param lang Two-letter language code (default: \code{"en"}).
#' @return A combined data frame of page metadata.
#' @export
#' @examples
#' \dontrun{
#' get_page_in_cat_multiple(c("Category:Biology", "Category:Medicine"))
#' }
get_page_in_cat_multiple <- function(catlist, replacement = "_", lang = "en") {
  dplyr::bind_rows(lapply(catlist, function(cat) {
    tryCatch(get_pages_in_cat_table(cat, replacement, lang = lang),
             error = function(e) NULL)
  }))
}


#' Recursively retrieve subcategories up to a given depth
#'
#' @param catname Character string — root category name.
#' @param depth Integer — number of levels to descend.
#' @param replacement Character used to replace spaces (default: \code{"_"}).
#' @param lang Two-letter language code (default: \code{"en"}).
#' @return A data frame of all unique subcategories up to \code{depth} levels
#'   below \code{catname}.
#' @export
#' @examples
#' \dontrun{
#' get_subcat_with_depth("Category:Biology", depth = 2)
#' }
get_subcat_with_depth <- function(catname, depth, replacement = "_", lang = "en") {
  table_out <- get_subcat_table(catname, lang = lang)
  while (depth > 0L) {
    table_out <- dplyr::bind_rows(
      table_out,
      get_subcat_multiple(table_out$title, replacement, lang = lang)
    )
    depth <- depth - 1L
  }
  unique(table_out)
}


# ── Time-series probing ────────────────────────────────────────────────────────

#' Probe a Wikipedia article at multiple time points
#'
#' For each timestamp in \code{dates_to_probe}, fetches the article snapshot
#' and computes the requested quality metrics.  This implements the monthly
#' probing approach used in COVID-19 citation analysis.
#'
#' @param article_name Character string — Wikipedia article title.
#' @param dates_to_probe Character vector of ISO 8601 timestamps
#'   (e.g. \code{"2021-01-01T00:00:00Z"}).
#' @param lang Two-letter language code (default: \code{"en"}).
#' @param metrics Character vector of metrics to compute.  Any subset of
#'   \code{c("sci_score", "doi_count", "ref_count", "size")}.
#' @return A data frame with one row per successfully fetched date and columns
#'   \code{date}, \code{art}, and one column per requested metric.
#' @export
#' @examples
#' \dontrun{
#' dates <- paste0(2018:2023, "-01-01T00:00:00Z")
#' probe_article_over_time("Zeitgeber", dates)
#' }
probe_article_over_time <- function(article_name,
                                     dates_to_probe,
                                     lang    = "en",
                                     metrics = c("sci_score", "doi_count",
                                                 "ref_count", "size")) {
  results <- lapply(dates_to_probe, function(d) {
    snap <- tryCatch(
      get_article_most_recent_table(article_name, date_an = d, lang = lang),
      error = function(e) NULL
    )
    if (is.null(snap) || nrow(snap) == 0L) return(NULL)
    txt <- snap$`*`
    row <- list(date = d, art = article_name)
    if ("sci_score" %in% metrics) row$sci_score  <- get_sci_score(txt)
    if ("doi_count" %in% metrics) row$doi_count  <- get_doi_count(txt)
    if ("ref_count" %in% metrics) row$ref_count  <- get_refCount(txt)
    if ("size"      %in% metrics) row$size       <- nchar(txt)
    as.data.frame(row, stringsAsFactors = FALSE)
  })
  dplyr::bind_rows(Filter(Negate(is.null), results))
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
  start_date <- as.Date(as.POSIXlt(start, format = "%Y%m%d%H", tz = "GMT"))
  end_date   <- as.Date(as.POSIXlt(end,   format = "%Y%m%d%H", tz = "GMT"))

  art_enc <- utils::URLencode(gsub(" ", "_", article_name), reserved = TRUE)
  url <- paste0(
    "https://wikimedia.org/api/rest_v1/metrics/pageviews/per-article/",
    "en.wikipedia/all-access/all-agents/", art_enc, "/daily/", start, "/", end
  )
  resp <- tryCatch(
    httr2::request(url) |>
      httr2::req_user_agent("wikilite R package") |>
      httr2::req_retry(max_tries = 3, backoff = ~ 2^.x) |>
      httr2::req_error(is_error = function(resp) FALSE) |>
      httr2::req_perform(),
    error = function(e) NULL
  )
  if (is.null(resp) || httr2::resp_status(resp) != 200L) {
    message("No pageview data returned for: ", article_name)
    return(invisible(NULL))
  }
  parsed    <- jsonlite::fromJSON(httr2::resp_body_string(resp))
  page_view <- as.data.frame(parsed$items)
  page_view$date <- as.Date(substr(page_view$timestamp, 1L, 8L), format = "%Y%m%d")

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
#' @param article_name Character string — Wikipedia article title.
#' @param ymax Optional numeric upper limit for the y-axis.
#' @param start Start date in \code{"YYYYMMDDHH"} format
#'   (default: \code{"2020010100"}).
#' @param end End date in \code{"YYYYMMDDHH"} format
#'   (default: \code{"2020050100"}).
#' @param lang Two-letter language code (default: \code{"en"}).
#' @return A \code{ggplot2} object (invisibly).
#' @export
#' @examples
#' \dontrun{
#' page_edit_plot("Zeitgeber", start = "2019010100", end = "2021010100")
#' }
page_edit_plot <- function(article_name, ymax = NA,
                           start = "2020010100", end = "2020050100",
                           lang  = "en") {
  history    <- get_article_full_history_table(article_name, lang = lang)
  history$ts <- as.Date(
    sapply(history$timestamp, function(x) unlist(strsplit(x, "T"))[1])
  )
  start_date <- as.Date(as.POSIXlt(start, format = "%Y%m%d%H", tz = "GMT"))
  end_date   <- as.Date(as.POSIXlt(end,   format = "%Y%m%d%H", tz = "GMT"))

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
