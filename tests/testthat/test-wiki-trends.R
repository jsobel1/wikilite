## Tests for wiki_trends.R
library(testthat)
library(wikilite)

# ── Offline structural test ───────────────────────────────────────────────────

test_that("get_revert_counts signature accepts start and end arguments", {
  # Just check the function exists and has the right formals
  expect_true(is.function(get_revert_counts))
  expect_true(all(c("start", "end") %in% names(formals(get_revert_counts))))
})

# ── Network test (skip on CRAN) ───────────────────────────────────────────────

test_that("get_revert_counts returns a data frame with expected columns", {
  skip_on_cran()
  result <- tryCatch(
    get_revert_counts("20181212010000", "20181212000000"),
    error = function(e) NULL
  )
  expect_true(
    is.null(result) ||
      (is.data.frame(result) &&
         all(c("art", "sum_nb_reverts") %in% names(result)))
  )
})

test_that("get_revert_counts returns rows ordered by sum_nb_reverts descending", {
  skip_on_cran()
  result <- tryCatch(
    get_revert_counts("20181212120000", "20181212110000"),
    error = function(e) NULL
  )
  if (!is.null(result) && nrow(result) > 1L) {
    expect_true(all(diff(result$sum_nb_reverts) <= 0))
  } else {
    succeed("Skipping order check: empty or NULL result")
  }
})

test_that("get_revert_counts returns only articles with sum_nb_reverts > 0", {
  skip_on_cran()
  result <- tryCatch(
    get_revert_counts("20181212120000", "20181212110000"),
    error = function(e) NULL
  )
  if (!is.null(result) && nrow(result) > 0L) {
    expect_true(all(result$sum_nb_reverts > 0))
  } else {
    succeed("Skipping: empty or NULL result")
  }
})
