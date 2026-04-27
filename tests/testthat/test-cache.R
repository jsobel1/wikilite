## Tests for cache.R
library(testthat)
library(wikilite)

test_that("wiki_cache_dir() returns an existing directory", {
  d <- wiki_cache_dir()
  expect_true(is.character(d))
  expect_true(dir.exists(d))
})

test_that(".cache_set() and .cache_get() round-trip correctly", {
  key   <- wikilite:::.cache_key("test_article", "2021-01-01", "en")
  value <- data.frame(art = "test", revid = 1L, stringsAsFactors = FALSE)
  wikilite:::.cache_set(key, value)
  retrieved <- wikilite:::.cache_get(key)
  expect_equal(retrieved, value)
  # clean up
  unlink(file.path(wiki_cache_dir(), paste0(key, ".rds")))
})

test_that(".cache_get() returns NULL for unknown key", {
  key <- wikilite:::.cache_key("definitely_not_cached_xyz987", "2000-01-01", "en")
  expect_null(wikilite:::.cache_get(key))
})

test_that("wiki_clear_cache() removes all cached files", {
  key   <- wikilite:::.cache_key("clear_test", "2022-01-01", "en")
  wikilite:::.cache_set(key, list(x = 1))
  wiki_clear_cache()
  expect_null(wikilite:::.cache_get(key))
})
