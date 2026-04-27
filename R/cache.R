# Disk-caching layer for wikilite API calls

#' Return (and create if needed) the wikilite user cache directory
#'
#' @return Character string path to the cache directory.
#' @export
wiki_cache_dir <- function() {
  d <- tools::R_user_dir("wikilite", which = "cache")
  if (!dir.exists(d)) dir.create(d, recursive = TRUE)
  d
}

.cache_key <- function(...) digest::digest(list(...), algo = "md5")

.cache_get <- function(key) {
  path <- file.path(wiki_cache_dir(), paste0(key, ".rds"))
  if (file.exists(path)) readRDS(path) else NULL
}

.cache_set <- function(key, value) {
  saveRDS(value, file.path(wiki_cache_dir(), paste0(key, ".rds")))
  invisible(value)
}

#' Clear the wikilite disk cache
#'
#' Deletes all cached API responses stored by \pkg{wikilite}.
#'
#' @return \code{NULL} invisibly.
#' @export
#' @examples
#' \dontrun{
#' wiki_clear_cache()
#' }
wiki_clear_cache <- function() {
  unlink(wiki_cache_dir(), recursive = TRUE)
  invisible(NULL)
}
