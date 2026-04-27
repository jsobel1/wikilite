## Tests for analysis_viz.R
library(testthat)
library(wikilite)

# ── Helper: fake history table ────────────────────────────────────────────────

make_fake_history <- function(n = 5L) {
  ts <- as.character(
    seq(as.POSIXct("2019-01-01", tz = "UTC"),
        by = "6 months", length.out = n)
  )
  ts <- gsub(" ", "T", ts)
  ts <- paste0(ts, "Z")
  data.frame(
    art       = "Zeitgeber",
    revid     = seq_len(n),
    parentid  = c(0L, seq_len(n - 1L)),
    user      = paste0("User", seq_len(n)),
    userid    = seq_len(n),
    timestamp = ts,
    size      = seq(1000L, by = 200L, length.out = n),
    comment   = c("initial", rep("edit", n - 1L)),
    `*`       = rep("some wikitext", n),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}

make_fake_doi_df <- function() {
  data.frame(
    art              = c("Zeitgeber", "Zeitgeber"),
    revid            = c(1L, 2L),
    citation_fetched = c("10.1038/nature12373", "10.1101/2020.01.01.900001"),
    timestamp        = c("2020-01-15T00:00:00Z", "2021-06-10T00:00:00Z"),
    stringsAsFactors = FALSE
  )
}

make_fake_epmc_df <- function() {
  data.frame(
    doi                  = c("10.1038/nature12373", "10.1101/2020.01.01.900001"),
    firstPublicationDate = c("2013-07-01", "2020-01-01"),
    stringsAsFactors = FALSE
  )
}

# ── get_edits_vs_time_plot ────────────────────────────────────────────────────

test_that("get_edits_vs_time_plot returns a ggplot object", {
  hist_df <- make_fake_history()
  p <- get_edits_vs_time_plot(hist_df, "Zeitgeber")
  expect_s3_class(p, "gg")
})

# ── get_size_vs_time_plot ─────────────────────────────────────────────────────

test_that("get_size_vs_time_plot returns a ggplot object", {
  hist_df <- make_fake_history()
  p <- get_size_vs_time_plot(hist_df, "Zeitgeber")
  expect_s3_class(p, "gg")
})

# ── get_closest_date ──────────────────────────────────────────────────────────

test_that("get_closest_date returns the nearest date", {
  dates  <- as.Date(c("2020-01-01", "2020-06-01", "2021-01-01"))
  result <- get_closest_date(as.Date("2020-04-15"), dates)
  expect_equal(result, as.Date("2020-06-01"))
})

test_that("get_closest_date works with exact match", {
  dates  <- as.Date(c("2020-01-01", "2021-01-01"))
  result <- get_closest_date(as.Date("2020-01-01"), dates)
  expect_equal(result, as.Date("2020-01-01"))
})

# ── compute_citation_latency ──────────────────────────────────────────────────

test_that("compute_citation_latency returns latency_days and is_preprint columns", {
  doi_df  <- make_fake_doi_df()
  epmc_df <- make_fake_epmc_df()
  result  <- compute_citation_latency(doi_df, epmc_df)
  expect_s3_class(result, "data.frame")
  expect_true("latency_days" %in% names(result))
  expect_true("is_preprint"  %in% names(result))
})

test_that("compute_citation_latency identifies preprints correctly", {
  doi_df  <- make_fake_doi_df()
  epmc_df <- make_fake_epmc_df()
  result  <- compute_citation_latency(doi_df, epmc_df)
  pp_row  <- result[result$citation_fetched == "10.1101/2020.01.01.900001", ]
  expect_true(pp_row$is_preprint)
  jr_row  <- result[result$citation_fetched == "10.1038/nature12373", ]
  expect_false(jr_row$is_preprint)
})

test_that("compute_citation_latency latency_days is numeric", {
  doi_df  <- make_fake_doi_df()
  epmc_df <- make_fake_epmc_df()
  result  <- compute_citation_latency(doi_df, epmc_df)
  expect_type(result$latency_days, "double")
})

# ── plot_latency_distribution ─────────────────────────────────────────────────

test_that("plot_latency_distribution returns a ggplot object (pooled)", {
  doi_df  <- make_fake_doi_df()
  epmc_df <- make_fake_epmc_df()
  lat     <- compute_citation_latency(doi_df, epmc_df)
  p <- plot_latency_distribution(lat)
  expect_s3_class(p, "gg")
})

test_that("plot_latency_distribution stratifies by is_preprint", {
  doi_df  <- make_fake_doi_df()
  epmc_df <- make_fake_epmc_df()
  lat     <- compute_citation_latency(doi_df, epmc_df)
  p <- plot_latency_distribution(lat, stratify_by = "is_preprint")
  expect_s3_class(p, "gg")
})

# ── get_segment_history_doi_plot ──────────────────────────────────────────────

test_that("get_segment_history_doi_plot returns a ggplot object", {
  doi_df  <- make_fake_doi_df()
  epmc_df <- make_fake_epmc_df()
  lat     <- compute_citation_latency(doi_df, epmc_df)
  p <- get_segment_history_doi_plot(lat, "Zeitgeber")
  expect_s3_class(p, "gg")
})

# ── get_dotplot_history ───────────────────────────────────────────────────────

test_that("get_dotplot_history returns a ggplot object", {
  doi_df  <- make_fake_doi_df()
  epmc_df <- make_fake_epmc_df()
  lat     <- compute_citation_latency(doi_df, epmc_df)
  p <- get_dotplot_history(lat, "Zeitgeber")
  expect_s3_class(p, "gg")
})
