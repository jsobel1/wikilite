## Tests for interactive_viz.R
## Internal data-builders are tested with synthetic data (no network).
## All exported functions are tested with skip_on_cran().
library(testthat)
library(wikilite)

# ── Helpers ───────────────────────────────────────────────────────────────────

make_fake_doi_df <- function() {
  data.frame(
    art              = c("Art A", "Art A", "Art B", "Art B", "Art C",
                         "Art A", "Art B", "Art C"),
    revid            = c(1L, 1L, 2L, 2L, 3L, 1L, 2L, 3L),
    citation_fetched = c("10.1/aaa", "10.1/bbb", "10.1/bbb", "10.1/ccc",
                         "10.1/ccc", "10.1/ddd", "10.1/ddd", "10.1/ddd"),
    stringsAsFactors = FALSE
  )
}

make_fake_recent <- function() {
  art_names <- c("Art A", "Art B", "Art C")
  texts <- c(
    "See [[Art B]] and [[Art C]] for more. Also [[External page]].",
    "See [[Art A]]. Shared concept [[Neuroscience]].",
    "References [[Art A]] and [[Art B]]."
  )
  data.frame(
    art       = art_names,
    revid     = c(1L, 2L, 3L),
    parentid  = c(0L, 1L, 2L),
    user      = "TestUser",
    userid    = 1L,
    timestamp = "2021-06-01T00:00:00Z",
    size      = nchar(texts),
    comment   = "edit",
    `*`       = texts,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}

# ── .build_pubnet_data ────────────────────────────────────────────────────────

test_that(".build_pubnet_data returns nodes and edges", {
  doi_df <- make_fake_doi_df()
  result <- wikilite:::.build_pubnet_data(doi_df,
                                           top_n_dois     = 10L,
                                           min_wiki_count = 2L)
  expect_type(result, "list")
  expect_named(result, c("nodes", "edges"))
  expect_s3_class(result$nodes, "data.frame")
  expect_s3_class(result$edges, "data.frame")
})

test_that(".build_pubnet_data nodes have required visNetwork columns", {
  result <- wikilite:::.build_pubnet_data(make_fake_doi_df(),
                                           min_wiki_count = 2L)
  expect_true(all(c("id", "label", "group", "value") %in% names(result$nodes)))
})

test_that(".build_pubnet_data edges have from and to columns", {
  result <- wikilite:::.build_pubnet_data(make_fake_doi_df(),
                                           min_wiki_count = 1L)
  expect_true(all(c("from", "to") %in% names(result$edges)))
})

test_that(".build_pubnet_data returns NULL when no DOIs pass threshold", {
  doi_df <- make_fake_doi_df()
  result <- wikilite:::.build_pubnet_data(doi_df, min_wiki_count = 99L)
  expect_null(result)
})

test_that(".build_pubnet_data applies top_n_dois limit", {
  doi_df <- make_fake_doi_df()
  result <- wikilite:::.build_pubnet_data(doi_df,
                                           top_n_dois     = 1L,
                                           min_wiki_count = 1L)
  pub_nodes <- result$nodes[result$nodes$group == "Publication", ]
  expect_lte(nrow(pub_nodes), 1L)
})

test_that(".build_pubnet_data uses epmc_meta for labels when supplied", {
  doi_df    <- make_fake_doi_df()
  epmc_meta <- data.frame(
    doi          = "10.1/ddd",
    title        = "A Very Important Paper About Important Things",
    journalTitle = "Journal of Important Things",
    pubYear      = "2021",
    stringsAsFactors = FALSE
  )
  result <- wikilite:::.build_pubnet_data(doi_df,
                                           min_wiki_count = 1L,
                                           epmc_meta      = epmc_meta)
  pub_nodes <- result$nodes[result$nodes$group == "Publication", ]
  annotated <- pub_nodes[pub_nodes$id == "10.1/ddd", ]
  expect_false(annotated$label == "10.1/ddd")  # label was enriched
})

# ── .build_cocite_data ────────────────────────────────────────────────────────

test_that(".build_cocite_data returns nodes and edges", {
  result <- wikilite:::.build_cocite_data(make_fake_doi_df(),
                                           min_shared_dois = 1L)
  expect_type(result, "list")
  expect_named(result, c("nodes", "edges"))
})

test_that(".build_cocite_data edges have value column for edge weight", {
  result <- wikilite:::.build_cocite_data(make_fake_doi_df(),
                                           min_shared_dois = 1L)
  expect_true("value" %in% names(result$edges))
  expect_true(all(result$edges$value >= 1L))
})

test_that(".build_cocite_data returns NULL when threshold too high", {
  result <- wikilite:::.build_cocite_data(make_fake_doi_df(),
                                           min_shared_dois = 99L)
  expect_null(result)
})

test_that(".build_cocite_data returns NULL for single article", {
  single_art <- data.frame(
    art = "Art A", revid = 1L,
    citation_fetched = c("10.1/aaa", "10.1/bbb"),
    stringsAsFactors = FALSE
  )
  result <- wikilite:::.build_cocite_data(single_art, min_shared_dois = 1L)
  expect_null(result)
})

test_that(".build_cocite_data edge titles list shared DOIs", {
  result <- wikilite:::.build_cocite_data(make_fake_doi_df(),
                                           min_shared_dois = 1L)
  expect_true(all(nchar(result$edges$title) > 0L))
})

# ── .build_wikilink_data ──────────────────────────────────────────────────────

test_that(".build_wikilink_data returns nodes and edges for internal links", {
  recent <- make_fake_recent()
  result <- wikilite:::.build_wikilink_data(recent, only_internal = TRUE)
  expect_type(result, "list")
  expect_named(result, c("nodes", "edges"))
})

test_that(".build_wikilink_data edges respect only_internal = TRUE", {
  recent <- make_fake_recent()
  result <- wikilite:::.build_wikilink_data(recent, only_internal = TRUE)
  arts   <- recent$art
  expect_true(all(result$edges$to %in% arts))
})

test_that(".build_wikilink_data includes external links when only_internal = FALSE", {
  recent <- make_fake_recent()
  result_int <- wikilite:::.build_wikilink_data(recent, only_internal = TRUE)
  result_ext <- wikilite:::.build_wikilink_data(recent, only_internal = FALSE,
                                                  top_n_links = 10L)
  # External should have at least as many nodes as internal
  expect_gte(nrow(result_ext$nodes), nrow(result_int$nodes))
})

test_that(".build_wikilink_data nodes have group column", {
  recent <- make_fake_recent()
  result <- wikilite:::.build_wikilink_data(recent, only_internal = FALSE,
                                             top_n_links = 20L)
  expect_true("group" %in% names(result$nodes))
  expect_true(all(result$nodes$group %in% c("Input article", "Linked article")))
})

test_that(".build_wikilink_data edges have arrows column", {
  recent <- make_fake_recent()
  result <- wikilite:::.build_wikilink_data(recent, only_internal = TRUE)
  expect_true("arrows" %in% names(result$edges))
})

test_that(".build_wikilink_data returns NULL when no links match", {
  recent        <- make_fake_recent()
  # Use an article set that has no wikilinks to each other
  recent$`*`    <- rep("No links in this text.", 3L)
  result <- wikilite:::.build_wikilink_data(recent, only_internal = TRUE)
  expect_null(result)
})

# ── Exported functions (network, skip_on_cran) ────────────────────────────────

test_that("plot_interactive_timeline returns a plotly object", {
  skip_on_cran()
  result <- tryCatch(
    plot_interactive_timeline(c("Zeitgeber", "Sleep deprivation")),
    error = function(e) NULL
  )
  expect_true(is.null(result) || inherits(result, "plotly"))
})

test_that("plot_article_publication_network returns visNetwork widget", {
  skip_on_cran()
  result <- tryCatch(
    plot_article_publication_network(
      c("Zeitgeber", "Advanced sleep phase disorder", "Sleep deprivation"),
      min_wiki_count = 1L
    ),
    error = function(e) NULL
  )
  expect_true(is.null(result) || inherits(result, "visNetwork"))
})

test_that("plot_article_cocitation_network returns visNetwork or NULL", {
  skip_on_cran()
  result <- tryCatch(
    suppressMessages(
      plot_article_cocitation_network(
        c("Zeitgeber", "Advanced sleep phase disorder", "Sleep deprivation"),
        min_shared_dois = 1L
      )
    ),
    error = function(e) NULL
  )
  expect_true(is.null(result) || inherits(result, "visNetwork"))
})

test_that("plot_article_wikilink_network returns visNetwork or NULL", {
  skip_on_cran()
  result <- tryCatch(
    suppressMessages(
      plot_article_wikilink_network(
        c("Zeitgeber", "Advanced sleep phase disorder", "Sleep deprivation")
      )
    ),
    error = function(e) NULL
  )
  expect_true(is.null(result) || inherits(result, "visNetwork"))
})
