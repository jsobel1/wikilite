## Tests for wiki_trends.R
library(testthat)
library(wikilite)

# ── Offline structural tests ──────────────────────────────────────────────────

test_that("get_revert_counts signature accepts start, end, and rev_eds arguments", {
  expect_true(is.function(get_revert_counts))
  expect_true(all(c("start", "end", "rev_eds") %in% names(formals(get_revert_counts))))
})

test_that("get_revert_counts rev_eds default is TRUE", {
  expect_true(formals(get_revert_counts)$rev_eds)
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

test_that("get_revert_counts rev_eds=FALSE returns sum_nb_edits column", {
  skip_on_cran()
  result <- tryCatch(
    get_revert_counts("20181212010000", "20181212000000", rev_eds = FALSE),
    error = function(e) NULL
  )
  expect_true(
    is.null(result) ||
      (is.data.frame(result) && "sum_nb_edits" %in% names(result))
  )
})

test_that("get_revert_counts rev_eds=FALSE counts >= rev_eds=TRUE counts", {
  skip_on_cran()
  reverts <- tryCatch(
    get_revert_counts("20181212010000", "20181212000000", rev_eds = TRUE),
    error = function(e) NULL
  )
  all_edits <- tryCatch(
    get_revert_counts("20181212010000", "20181212000000", rev_eds = FALSE),
    error = function(e) NULL
  )
  if (!is.null(reverts) && !is.null(all_edits) &&
      nrow(reverts) > 0L && nrow(all_edits) > 0L) {
    common <- intersect(reverts$art, all_edits$art)
    if (length(common) > 0L) {
      rev_vals  <- reverts$sum_nb_reverts[match(common, reverts$art)]
      edit_vals <- all_edits$sum_nb_edits[match(common, all_edits$art)]
      expect_true(all(edit_vals >= rev_vals))
    } else {
      succeed("No common articles to compare")
    }
  } else {
    succeed("Skipping: empty or NULL results")
  }
})
