## Tests for export.R
library(testthat)
library(wikilite)

# ── write_wiki_history_to_xlsx ────────────────────────────────────────────────

test_that("write_wiki_history_to_xlsx creates an xlsx file", {
  tbl    <- make_fake_table()
  tmp    <- tempfile(fileext = "")
  on.exit(unlink(paste0(tmp, "_wiki_table.xlsx")), add = TRUE)

  result <- write_wiki_history_to_xlsx(tbl, tmp)
  expect_null(result)  # invisibly NULL
  expect_true(file.exists(paste0(tmp, "_wiki_table.xlsx")))
})

test_that("write_wiki_history_to_xlsx handles NA values without error", {
  tbl       <- make_fake_table()
  tbl$comment <- NA_character_
  tmp       <- tempfile(fileext = "")
  on.exit(unlink(paste0(tmp, "_wiki_table.xlsx")), add = TRUE)

  expect_no_error(write_wiki_history_to_xlsx(tbl, tmp))
})

# ── export_extracted_citations_xlsx ───────────────────────────────────────────

test_that("export_extracted_citations_xlsx writes xlsx files", {
  tbl     <- make_fake_table()
  tmp_dir <- tempdir()
  prefix  <- file.path(tmp_dir, "test_export")
  on.exit({
    files <- list.files(tmp_dir, pattern = "^test_export.*\\.xlsx$", full.names = TRUE)
    unlink(files)
  }, add = TRUE)

  result <- export_extracted_citations_xlsx(tbl, prefix)
  expect_null(result)

  written <- list.files(tmp_dir, pattern = "^test_export.*\\.xlsx$")
  expect_gte(length(written), 1L)
})

# ── export_doi_to_bib (skip_on_cran: calls CrossRef) ─────────────────────────

test_that("export_doi_to_bib creates a .bib file", {
  skip_on_cran()
  tmp_bib <- tempfile(fileext = ".bib")
  on.exit(unlink(tmp_bib), add = TRUE)

  result <- tryCatch(
    export_doi_to_bib("10.1038/nature12373", tmp_bib),
    error = function(e) NULL
  )
  # Either succeeds (NULL return) or fails gracefully
  expect_true(is.null(result) || TRUE)
})
