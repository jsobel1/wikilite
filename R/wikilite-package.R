#' wikilite: Retrieve, Parse, and Analyse Wikipedia Article History and Citations
#'
#' @description
#' **wikilite** is a toolkit for mining Wikipedia article revision history and
#' citations via the public MediaWiki API.  Core capabilities:
#'
#' \describe{
#'   \item{History retrieval}{Full or partial revision histories for one or
#'     many articles via \code{\link{get_article_full_history_table}},
#'     \code{\link{get_article_initial_table}},
#'     \code{\link{get_article_most_recent_table}}.}
#'   \item{Category navigation}{\code{\link{get_pagename_in_cat}},
#'     \code{\link{get_subcat_table}},
#'     \code{\link{get_subcat_with_depth}} and related helpers.}
#'   \item{Citation extraction}{Built-in regular expressions for DOIs, ISBNs,
#'     PMIDs, URLs, and all Citation Style 1 templates, accessible via
#'     \code{\link{get_regex_citations_in_wiki_table}} or
#'     \code{\link{extract_citations_regexp}}.}
#'   \item{Citation parsing}{\code{\link{parse_article_ALL_citations}} parses
#'     every CS1 template into a tidy long data frame; counting helpers
#'     (\code{\link{get_doi_count}}, \code{\link{get_refCount}}, …) provide
#'     fast scalar summaries.}
#'   \item{Quality metrics}{\code{\link{get_sci_score}} (proportion of
#'     journal citations) and \code{\link{get_sci_score2}} (DOI-to-ref ratio).}
#'   \item{Annotation}{\code{\link{annotate_doi_list_europmc}},
#'     \code{\link{annotate_doi_list_cross_ref}},
#'     \code{\link{annotate_doi_list_altmetrics}},
#'     \code{\link{annotate_isbn_google}},
#'     \code{\link{annotate_isbn_openlib}}.}
#'   \item{Revert trends}{\code{\link{get_revert_counts}} retrieves the
#'     count of revert-tagged edits across all Wikipedia articles for a
#'     given time window.}
#'   \item{Visualisation}{Timelines, edit-activity plots, and citation
#'     distribution charts built on \pkg{ggplot2}.}
#' }
#'
#' @section Built-in regular expressions:
#' The package-level environment \code{\link{pkg.env}} contains all pre-built
#' patterns.  Access via \code{pkg.env$doi_regexp},
#' \code{pkg.env$regexp_list}, etc.
#'
#' @docType package
#' @name wikilite-package
#' @aliases wikilite
"_PACKAGE"

## Suppress R CMD check NOTEs for bare column names used in dplyr/ggplot2 NSE
utils::globalVariables(c(
  # article history / category tables
  "art", "tsc", "first", "count", "date",
  "ts", "revid", "variable", "value",
  # citation parsing
  "cite_type", "Freq", "citation_fetched", "doi",
  "firstPublicationDate",
  # edit trends
  "nb_reverts", "sum_nb_reverts", "tags", "cnt",
  # interactive visualisation
  "n_articles", "n_dois", "color_val", "created",
  "updated", "size_first", "size_last",
  "first_editor", "y_pos", "wiki_url", "views",
  # analysis / latency visualisation
  "year", "edit_type", "size",
  "latency_days", "is_preprint", "is_preprint_f",
  "group", "pub_date", "wiki_date"
))

#' @importFrom stats reorder
#' @importFrom utils write.table
NULL
