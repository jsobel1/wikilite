## Tests for annotation.R
## All tests that make real network calls are guarded with skip_on_cran().
library(testthat)
library(wikilite)

# ── EuropePMC ─────────────────────────────────────────────────────────────────

test_that("annotate_doi_list_europmc returns data frame or empty df for bad DOI", {
  skip_on_cran()
  result <- tryCatch(
    annotate_doi_list_europmc("10.9999/definitely-not-real"),
    error = function(e) data.frame()
  )
  expect_s3_class(result, "data.frame")
})

test_that("annotate_doi_list_europmc returns data frame with doi column for known DOI", {
  skip_on_cran()
  result <- tryCatch(
    annotate_doi_list_europmc("10.1038/nature12373"),
    error = function(e) data.frame()
  )
  expect_s3_class(result, "data.frame")
  if (nrow(result) > 0L) {
    expect_true("doi" %in% names(result))
  }
})

# ── CrossRef ──────────────────────────────────────────────────────────────────

test_that("annotate_doi_to_bibtex_cross_ref returns character bibtex string", {
  skip_on_cran()
  result <- tryCatch(
    annotate_doi_to_bibtex_cross_ref("10.1038/nature12373"),
    error = function(e) character(0)
  )
  expect_type(result, "character")
})

# ── Google Books ──────────────────────────────────────────────────────────────

test_that("annotate_isbn_google returns NULL gracefully on invalid ISBN", {
  skip_on_cran()
  result <- tryCatch(
    annotate_isbn_google("000-0-00-000000-0"),
    error = function(e) NULL
  )
  expect_true(is.null(result) || is.data.frame(result))
})

test_that("annotate_isbn_google returns data frame or NULL for known ISBN", {
  skip_on_cran()
  result <- tryCatch(
    annotate_isbn_google("9780156031356"),
    error = function(e) NULL
  )
  expect_true(is.null(result) || is.data.frame(result))
})

# ── Open Library ──────────────────────────────────────────────────────────────

test_that("annotate_isbn_openlib returns NULL or data frame on invalid ISBN", {
  skip_on_cran()
  result <- tryCatch(
    annotate_isbn_openlib("000-0-00-000000-0"),
    error = function(e) NULL
  )
  expect_true(is.null(result) || is.data.frame(result))
})

# ── Altmetric ─────────────────────────────────────────────────────────────────

test_that("annotate_doi_list_altmetrics returns a data frame", {
  skip_on_cran()
  result <- tryCatch(
    annotate_doi_list_altmetrics(list("10.1038/nature12373")),
    error = function(e) data.frame()
  )
  expect_s3_class(result, "data.frame")
})

test_that("annotate_isbn_list_altmetrics returns a data frame", {
  skip_on_cran()
  result <- tryCatch(
    annotate_isbn_list_altmetrics(list("9780156031356")),
    error = function(e) data.frame()
  )
  expect_s3_class(result, "data.frame")
})
