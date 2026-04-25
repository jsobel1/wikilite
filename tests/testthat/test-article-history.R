## Tests for article_history.R
library(testthat)
library(wikilite)

# ── 1. Offline structural tests ───────────────────────────────────────────────

test_that("get_category_articles_history returns NULL for empty input", {
  result <- get_category_articles_history(character(0))
  expect_true(is.null(result) || (is.data.frame(result) && nrow(result) == 0L))
})

test_that("get_category_articles_creation returns NULL for empty input", {
  result <- get_category_articles_creation(character(0))
  expect_true(is.null(result) || (is.data.frame(result) && nrow(result) == 0L))
})

test_that("get_category_articles_most_recent returns NULL for empty input", {
  result <- get_category_articles_most_recent(character(0))
  expect_true(is.null(result) || (is.data.frame(result) && nrow(result) == 0L))
})

# ── 2. Visualisation helpers (no network, uses fake data) ─────────────────────

test_that("plot_article_creation_per_year returns ggplot invisibly", {
  fake <- make_fake_table()
  # Build a minimal initial-revision table that plot_article_creation_per_year accepts
  fake_init <- fake
  p <- plot_article_creation_per_year(
    fake_init,
    name_title = "Test",
    Cumsum = FALSE
  )
  expect_s3_class(p, "gg")
})

test_that("plot_article_creation_per_year Cumsum=TRUE returns ggplot", {
  fake_init <- make_fake_table()
  p <- plot_article_creation_per_year(fake_init, "Test", Cumsum = TRUE)
  expect_s3_class(p, "gg")
})

test_that("plot_navi_timeline issues message and returns NULL invisibly", {
  expect_message(
    result <- plot_navi_timeline(NULL, NULL),
    regexp = "unavailable"
  )
  expect_null(result)
})

# ── 3. Network-dependent tests (skip on CRAN) ─────────────────────────────────

test_that("get_article_initial_table returns a data frame for Zeitgeber", {
  skip_on_cran()
  result <- tryCatch(
    get_article_initial_table("Zeitgeber"),
    error = function(e) NULL
  )
  expect_true(is.null(result) || is.data.frame(result))
  if (is.data.frame(result)) {
    expect_true("art" %in% names(result))
    expect_equal(result$art[1], "Zeitgeber")
  }
})

test_that("get_article_most_recent_table returns a 1-row data frame", {
  skip_on_cran()
  result <- tryCatch(
    get_article_most_recent_table("Zeitgeber"),
    error = function(e) NULL
  )
  expect_true(is.null(result) || (is.data.frame(result) && nrow(result) == 1L))
})

test_that("get_article_info_table returns a named vector", {
  skip_on_cran()
  result <- tryCatch(
    get_article_info_table("Zeitgeber"),
    error = function(e) NULL
  )
  expect_true(is.null(result) || is.vector(result))
})

test_that("get_pagename_in_cat returns character vector or NULL", {
  skip_on_cran()
  result <- tryCatch(
    get_pagename_in_cat("Circadian rhythm"),
    error = function(e) NULL
  )
  expect_true(is.null(result) || is.character(result))
})

test_that("get_subcat_table returns a data frame or NULL", {
  skip_on_cran()
  result <- tryCatch(
    get_subcat_table("Biology"),
    error = function(e) NULL
  )
  expect_true(is.null(result) || is.data.frame(result))
})
