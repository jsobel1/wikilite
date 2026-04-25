# Extraction and counting of various citation objects from Wikipedia wikitext

# ── Package-level regexp environment ──────────────────────────────────────────

#' Built-in regular expressions for citation extraction
#'
#' A package-level environment that stores all pre-built regular expression
#' patterns used by \pkg{wikilite}.  Access individual patterns by name (e.g.
#' \code{pkg.env$doi_regexp}) or iterate over \code{pkg.env$regexp_list} to
#' apply all patterns at once.
#'
#' \describe{
#'   \item{\code{doi_regexp}}{Matches DOIs: \code{10.XXXX/...}}
#'   \item{\code{isbn_regexp}}{Matches ISBNs following an \code{isbn=} or
#'     \code{ISBN:} prefix.}
#'   \item{\code{url_regexp}}{Matches \code{http://} and \code{https://} URLs.}
#'   \item{\code{pmid_regexp}}{Matches PubMed identifiers.}
#'   \item{\code{cite_regexp}}{Matches any Citation Style 1 template.}
#'   \item{\code{journal_regexp}, \code{news_regexp}, \code{web_regexp},
#'     \code{book_regexp}, ...}{Type-specific CS1 patterns.}
#'   \item{\code{ref_regexp}}{Matches \code{<ref>...</ref>} blocks.}
#'   \item{\code{wikihyperlink_regexp}}{Matches \code{[[...]]}-style links.}
#'   \item{\code{regexp_list}}{Named character vector of all patterns above,
#'     suitable for iterating with
#'     \code{\link{extract_citations_regexp}}.}
#' }
#'
#' @format An \code{environment}.
#' @export
pkg.env <- new.env(parent = emptyenv())

pkg.env$doi_regexp <- "10\\.\\d{4,9}/[-._;()/:a-z0-9A-Z]+"

pkg.env$isbn_regexp <- "(?<=(isbn|ISBN)\\s?[=:]?\\s?)[-0-9X ]{13,20}"

pkg.env$url_regexp <- "http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+"

pkg.env$tweet_regexp         <- "\\{\\{cite tweet.*?\\}\\}"
pkg.env$news_regexp          <- "\\{\\{cite news.*?\\}\\}"
pkg.env$journal_regexp       <- "\\{\\{cite journal.*?\\}\\}"
pkg.env$web_regexp           <- "\\{\\{cite web.*?\\}\\}"
pkg.env$article_regexp       <- "\\{\\{cite article.*?\\}\\}"
pkg.env$report_regexp        <- "\\{\\{cite report.*?\\}\\}"
pkg.env$court_regexp         <- "\\{\\{cite court.*?\\}\\}"
pkg.env$press_release_regexp <- "\\{\\{cite press release.*?\\}\\}"
pkg.env$book_regexp          <- "\\{\\{cite book .*?\\}\\}"
pkg.env$pmid_regexp          <- "(?<=(pmid|PMID)\\s?[=:]\\s?)\\d{5,9}"
pkg.env$ref_in_text_regexp   <- "<ref>\\{\\{.*?\\}\\}</ref>"
pkg.env$ref_regexp           <- "<ref.*?</ref>"
pkg.env$cite_regexp          <- "\\{\\{[cC]ite.*?\\}\\}"
pkg.env$wikihyperlink_regexp <- "\\[\\[.*?\\]\\]"
pkg.env$template_regexp      <- "\\{\\{pp.*?\\}\\}"

pkg.env$regexp_list <- c(
  doi_regexp           = "10\\.\\d{4,9}/[-._;()/:a-z0-9A-Z]+",
  isbn_regexp          = "(?<=(isbn|ISBN)\\s?[=:]?\\s?)[-0-9X ]{13,17}",
  url_regexp           = "http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+",
  wikihyperlink_regexp = "\\[\\[.*?\\]\\]",
  tweet_regexp         = "\\{\\{cite tweet.*?\\}\\}",
  news_regexp          = "\\{\\{cite news.*?\\}\\}",
  journal_regexp       = "\\{\\{cite journal.*?\\}\\}",
  web_regexp           = "\\{\\{cite web.*?\\}\\}",
  article_regexp       = "\\{\\{cite article.*?\\}\\}",
  report_regexp        = "\\{\\{cite report.*?\\}\\}",
  court_regexp         = "\\{\\{cite court.*?\\}\\}",
  press_release_regexp = "\\{\\{cite press release.*?\\}\\}",
  book_regexp          = "\\{\\{cite book .*?\\}\\}",
  pmid_regexp          = "(?<=(pmid|PMID)\\s?[=:]\\s?)\\d{5,9}",
  ref_in_text_regexp   = "<ref>\\{\\{.*?\\}\\}</ref>",
  ref_regexp           = "<ref.*?</ref>",
  cite_regexp          = "\\{\\{[cC]ite.*?\\}\\}",
  template_regexp      = "\\{\\{pp.*?\\}\\}"
)


# ── Core extraction helpers ───────────────────────────────────────────────────

#' Extract regex matches from a Wikipedia revision table
#'
#' Applies \code{citation_regexp} to the wikitext column (\code{*}) of
#' \code{article_wiki_table} and returns a tidy data frame mapping each
#' revision to its matched strings.
#'
#' Available built-in regular expressions are stored in
#' \code{\link{pkg.env}}\code{$regexp_list}.
#'
#' @param article_wiki_table A data frame of Wikipedia revisions with columns
#'   \code{art}, \code{revid}, and \code{*} (wikitext).
#' @param citation_regexp A regular expression string.
#' @return A data frame with columns \code{art}, \code{revid}, and
#'   \code{citation_fetched}.
#' @export
#' @examples
#' \dontrun{
#' history <- get_article_full_history_table("Zeitgeber")
#' dois    <- get_regex_citations_in_wiki_table(history,
#'              "10\\.\\d{4,9}/[-._;()/:a-z0-9A-Z]+")
#' }
get_regex_citations_in_wiki_table <- function(article_wiki_table,
                                              citation_regexp) {
  citation_fetched <- stringr::str_match_all(
    article_wiki_table$`*`, citation_regexp
  )
  df_citation <- data.frame(
    revid            = rep(article_wiki_table$revid,
                           vapply(citation_fetched, length, integer(1L))),
    citation_fetched = unlist(citation_fetched),
    stringsAsFactors = FALSE
  )
  dplyr::select(article_wiki_table, art, revid) |>
    dplyr::right_join(df_citation, by = "revid")
}


#' Determine the type of a Citation Style 1 template
#'
#' Extracts the citation type keyword (e.g. \code{"journal"}, \code{"book"},
#' \code{"web"}) from a raw CS1 citation string.
#'
#' @param citation Character string containing a CS1 template.
#' @return Lowercase character string giving the citation type.
#' @export
#' @examples
#' parse_cite_type("{{cite journal | author = Smith | year = 2020 }}")
#' parse_cite_type("{{Cite book | title = My Book }}")
parse_cite_type <- function(citation) {
  get_cite      <- gsub("\\{\\{[cC]ite", "", as.character(citation))
  get_cite_type <- unlist(strsplit(get_cite, "\\|"))[1]
  get_cite_type <- gsub("\\s", "", get_cite_type)
  tolower(get_cite_type)
}


#' Extract all Citation Style 1 templates from wikitext
#'
#' @param art_text Character string of raw wikitext.
#' @return Character vector of matched CS1 templates.
#' @export
#' @examples
#' \dontrun{
#' art <- get_article_most_recent_table("Zeitgeber")
#' extract_citations(art$`*`)
#' }
extract_citations <- function(art_text) {
  as.character(unlist(
    stringr::str_match_all(art_text, pkg.env$cite_regexp)
  ))
}


#' Extract Wikipedia hyperlinks from wikitext
#'
#' @param art_text Character string of raw wikitext.
#' @return Character vector of matched \code{[[...]]}-style links.
#' @export
#' @examples
#' extract_wikihypelinks("See [[Zeitgeber|the article]] and [[Sleep]].")
extract_wikihypelinks <- function(art_text) {
  as.character(unlist(
    stringr::str_match_all(art_text, pkg.env$wikihyperlink_regexp)
  ))
}


#' Replace Wikipedia hyperlinks with plain text
#'
#' Removes \code{[[...]]}-style wikitext markup, keeping the display text
#' (the part after \code{|}, if present) or the link target.
#'
#' @param art_text Character string of raw wikitext.
#' @return The input string with all hyperlinks replaced by plain text.
#' @export
#' @examples
#' replace_wikihypelinks("[[Zeitgeber|the article]] was described in [[Biology]].")
replace_wikihypelinks <- function(art_text) {
  whl         <- extract_wikihypelinks(art_text)
  whl_cleaned <- gsub("\\[\\[|\\]\\]", "", whl)
  whl_cleaned <- sapply(
    whl_cleaned,
    function(x) as.character(unlist(strsplit(x, "\\|")))[1]
  )
  textclean::mgsub(art_text, whl, whl_cleaned)
}


#' Parse all Citation Style 1 templates in a wikitext string
#'
#' Extracts every CS1 citation, replaces hyperlinks, and returns a tidy long
#' data frame where each row is one field of one citation.
#'
#' @param art_text Character string of raw wikitext.
#' @return A data frame with columns \code{type}, \code{id_cite},
#'   \code{variable}, and \code{value}.
#' @export
#' @examples
#' \dontrun{
#' art <- get_article_most_recent_table("Zeitgeber")
#' parse_article_ALL_citations(art$`*`)
#' }
parse_article_ALL_citations <- function(art_text) {
  get_cite <- as.character(
    sapply(extract_citations(art_text), replace_wikihypelinks)
  )
  cite_types <- sapply(get_cite, parse_cite_type)

  get_cite <- gsub("\\{\\{[cC]ite|\\{\\{|\\}\\}", "", get_cite)

  get_cite_subfield <- sapply(
    get_cite,
    function(x) unlist(strsplit(x, "\\|"))[-1]
  )

  data.frame(
    type    = rep(as.character(unlist(cite_types)),
                  vapply(get_cite_subfield, length, integer(1L))),
    id_cite = rep(seq_along(get_cite),
                  vapply(get_cite_subfield, length, integer(1L))),
    reshape2::colsplit(
      string  = unlist(get_cite_subfield),
      pattern = "=",
      names   = c("variable", "value")
    )
  ) |>
    dplyr::mutate(variable = gsub(" ", "", variable))
}


# ── Count helpers ─────────────────────────────────────────────────────────────

#' Count \code{<ref>} tags in wikitext
#'
#' @param art_text Character string of raw wikitext.
#' @return Integer count of reference tags.
#' @export
#' @examples
#' get_refCount("<ref>one</ref> text <ref name='r2'>two</ref>")
get_refCount <- function(art_text) {
  length(as.character(unlist(
    stringr::str_match_all(art_text, pkg.env$ref_regexp)
  )))
}


#' Count URLs in wikitext
#'
#' @param art_text Character string of raw wikitext.
#' @return Integer count of matched URLs.
#' @export
#' @examples
#' get_urlCount("See https://example.com and http://test.org.")
get_urlCount <- function(art_text) {
  length(as.character(unlist(
    stringr::str_match_all(art_text, pkg.env$url_regexp)
  )))
}


#' Count Wikipedia hyperlinks in wikitext
#'
#' @param art_text Character string of raw wikitext.
#' @return Integer count of \code{[[...]]}-style links.
#' @export
#' @examples
#' get_hyperlinkCount("[[Article one]] and [[Article two|display]]")
get_hyperlinkCount <- function(art_text) {
  length(as.character(unlist(
    stringr::str_match_all(art_text, pkg.env$wikihyperlink_regexp)
  )))
}


#' Count DOIs in wikitext
#'
#' @param art_text Character string of raw wikitext.
#' @return Integer count of matched DOIs.
#' @export
#' @examples
#' get_doi_count("See 10.1038/nature12373 and 10.1016/j.cell.2020.01.001.")
get_doi_count <- function(art_text) {
  length(as.character(unlist(
    stringr::str_match_all(art_text, pkg.env$doi_regexp)
  )))
}


#' Count ISBNs in wikitext
#'
#' @param art_text Character string of raw wikitext.
#' @return Integer count of matched ISBNs.
#' @export
#' @examples
#' get_ISBN_count("Book isbn=978-0-06-112008-4")
get_ISBN_count <- function(art_text) {
  length(as.character(unlist(
    stringr::str_match_all(art_text, pkg.env$isbn_regexp)
  )))
}


#' Count matches of an arbitrary regular expression in wikitext
#'
#' @param art_text Character string of raw wikitext.
#' @param regexp A regular expression string.
#' @return Integer count of matches.
#' @export
#' @examples
#' get_anyCount("foo bar baz foo", "foo")
get_anyCount <- function(art_text, regexp) {
  length(as.character(unlist(
    stringr::str_match_all(art_text, regexp)
  )))
}


# ── SciScore ──────────────────────────────────────────────────────────────────

#' Compute SciScore for a Wikipedia article
#'
#' SciScore is the proportion of CS1-template citations that are journal
#' citations (\code{cite journal}).  A score of 1 means all citations are
#' to peer-reviewed journals; 0 means none are.
#'
#' @param art_text Character string of raw wikitext.
#' @return Numeric value between 0 and 1, or \code{0} if there are no
#'   citations.
#' @export
#' @examples
#' \dontrun{
#' art <- get_article_most_recent_table("Zeitgeber")
#' get_sci_score(art$`*`)
#' }
get_sci_score <- function(art_text) {
  extracted_cite <- tryCatch(extract_citations(art_text), error = function(e) character(0))
  if (length(extracted_cite) == 0L) return(0)
  cite_type      <- sapply(extracted_cite, parse_cite_type)
  all_cite_sum   <- tryCatch(sum(table(cite_type)),   error = function(e) 0)
  journal_cite   <- tryCatch(
    table(cite_type)[which(names(table(cite_type)) == "journal")],
    error = function(e) NA
  )
  if (length(journal_cite) == 0L) return(0)
  as.numeric(journal_cite / all_cite_sum)
}


#' Compute SciScore2 for a Wikipedia article
#'
#' SciScore2 is the ratio of DOIs to \code{<ref>} tags in the article.  A
#' ratio close to 1 indicates that most references include a DOI (likely
#' peer-reviewed sources).
#'
#' @param art_text Character string of raw wikitext.
#' @return Numeric value, or \code{NA} when there are no reference tags.
#' @export
#' @examples
#' \dontrun{
#' art <- get_article_most_recent_table("Zeitgeber")
#' get_sci_score2(art$`*`)
#' }
get_sci_score2 <- function(art_text) {
  ref_count <- get_refCount(art_text)
  doi_count <- get_doi_count(art_text)
  if (ref_count == 0L) return(NA_real_)
  as.numeric(doi_count / ref_count)
}


#' Count citations by CS1 source type
#'
#' @param art_text Character string of raw wikitext.
#' @return A data frame with columns \code{cite_type} and \code{Freq}, or
#'   \code{NA} if no citations are found.
#' @export
#' @examples
#' \dontrun{
#' art <- get_article_most_recent_table("Zeitgeber")
#' get_source_type_counts(art$`*`)
#' }
get_source_type_counts <- function(art_text) {
  extracted_cite    <- tryCatch(extract_citations(art_text), error = function(e) 0)
  cite_type         <- sapply(extracted_cite, parse_cite_type)
  cite_source_count <- tryCatch(table(cite_type), error = function(e) NA)
  if (length(cite_source_count) == 0L) return(NA)
  as.data.frame(cite_source_count)
}


# ── Multi-article wrappers ────────────────────────────────────────────────────

#' Parse all CS1 citations across a Wikipedia revision table
#'
#' Applies \code{\link{parse_article_ALL_citations}} to every row of
#' \code{article_most_recent_table} and returns a combined tidy data frame.
#'
#' @param article_most_recent_table A Wikipedia revision data frame (e.g. from
#'   \code{\link{get_category_articles_most_recent}}).
#' @return A data frame with columns \code{art}, \code{revid}, \code{type},
#'   \code{id_cite}, \code{variable}, and \code{value}.
#' @export
#' @examples
#' \dontrun{
#' recent <- get_category_articles_most_recent(
#'   c("Zeitgeber", "Advanced sleep phase disorder", "Sleep deprivation")
#' )
#' parsed <- get_parsed_citations(recent)
#' }
get_parsed_citations <- function(article_most_recent_table) {
  df_cite_clean <- NULL

  for (i in seq_len(nrow(article_most_recent_table))) {
    message("Parsing citations: ", article_most_recent_table$art[i])
    dfctmp <- tryCatch(
      parse_article_ALL_citations(article_most_recent_table$`*`[i]),
      error = function(e) NULL
    )
    if (is.null(dfctmp) || nrow(dfctmp) < 1L) next
    dfctmp$revid  <- article_most_recent_table$revid[i]
    df_cite_clean <- rbind(df_cite_clean, dfctmp)
  }

  dplyr::select(article_most_recent_table, art, revid) |>
    dplyr::right_join(df_cite_clean, by = "revid")
}


#' Summarise citation types across a Wikipedia revision table
#'
#' @param article_most_recent_table A Wikipedia revision data frame (e.g. from
#'   \code{\link{get_category_articles_most_recent}}).
#' @return A data frame with columns \code{art}, \code{revid},
#'   \code{cite_type}, and \code{Freq}.
#' @export
#' @examples
#' \dontrun{
#' recent <- get_article_most_recent_table("Zeitgeber")
#' get_citation_type(recent)
#' }
get_citation_type <- function(article_most_recent_table) {
  df_cite_type_clean <- NULL

  for (i in seq_len(nrow(article_most_recent_table))) {
    message("Counting citation types: ", article_most_recent_table$art[i])
    dfctmp <- tryCatch(
      get_source_type_counts(article_most_recent_table$`*`[i]),
      error = function(e) NULL
    )
    if (is.null(dfctmp) || !is.data.frame(dfctmp) || nrow(dfctmp) < 1L) next
    dfctmp$revid       <- article_most_recent_table$revid[i]
    df_cite_type_clean <- rbind(df_cite_type_clean, dfctmp)
  }

  dplyr::select(article_most_recent_table, art, revid) |>
    dplyr::right_join(df_cite_type_clean, by = "revid")
}


#' Apply all built-in regular expressions to a Wikipedia revision table
#'
#' Iterates over every pattern in \code{\link{pkg.env}}\code{$regexp_list}
#' and returns a named list of data frames, one per pattern.
#'
#' @param article_most_recent_table A Wikipedia revision data frame (e.g. from
#'   \code{\link{get_category_articles_most_recent}}).
#' @return A named list of data frames, one per entry in
#'   \code{pkg.env$regexp_list}.  Each element has columns \code{art},
#'   \code{revid}, and \code{citation_fetched}.
#' @export
#' @examples
#' \dontrun{
#' recent       <- get_article_most_recent_table("Zeitgeber")
#' all_citations <- extract_citations_regexp(recent)
#' names(all_citations)
#' }
extract_citations_regexp <- function(article_most_recent_table) {
  extracted_citation_list <- vector("list", length(pkg.env$regexp_list))
  for (i in seq_along(pkg.env$regexp_list)) {
    extracted_citation_list[[i]] <- get_regex_citations_in_wiki_table(
      article_most_recent_table,
      as.character(pkg.env$regexp_list[i])
    )
  }
  names(extracted_citation_list) <- names(pkg.env$regexp_list)
  extracted_citation_list
}


# ── Visualisations ────────────────────────────────────────────────────────────

#' Plot the top 20 values for a given citation field
#'
#' @param df_cite_parsed_revid_art Parsed citation data frame as returned by
#'   \code{\link{get_parsed_citations}}.
#' @param source_type Character string — the citation field to summarise
#'   (e.g. \code{"publisher"}, \code{"journal"}).
#' @return A \code{ggplot2} object (invisibly).
#' @export
#' @examples
#' \dontrun{
#' recent <- get_article_most_recent_table("Zeitgeber")
#' df     <- get_parsed_citations(recent)
#' plot_top_source(df, "publisher")
#' }
plot_top_source <- function(df_cite_parsed_revid_art, source_type) {
  p <- df_cite_parsed_revid_art |>
    dplyr::filter(variable == source_type) |>
    dplyr::mutate(value = gsub(" ", "", value)) |>
    dplyr::filter(value != "") |>
    dplyr::group_by(value) |>
    dplyr::summarise(count = dplyr::n(), .groups = "drop") |>
    dplyr::arrange(dplyr::desc(count)) |>
    dplyr::slice_head(n = 20) |>
    ggplot2::ggplot(ggplot2::aes(reorder(value, count), count)) +
    ggplot2::geom_bar(stat = "identity") +
    ggplot2::coord_flip() +
    ggplot2::ggtitle(paste("Top 20", source_type))
  print(p)
  invisible(p)
}


#' Plot bar charts of the top 20 values for all citation source types
#'
#' Calls \code{\link{plot_top_source}} for every type listed in
#' \code{source_types_list}.
#'
#' @param df_cite_parsed_revid_art Parsed citation data frame as returned by
#'   \code{\link{get_parsed_citations}}.
#' @param source_types_list Character vector of citation field names to
#'   summarise (default: \code{c("publisher", "journal", "author",
#'   "website", "newspaper")}).
#' @return Invisibly returns \code{NULL}.
#' @export
#' @examples
#' \dontrun{
#' recent <- get_article_most_recent_table("Zeitgeber")
#' df     <- get_parsed_citations(recent)
#' get_pdfs_top20source(df)
#' }
get_pdfs_top20source <- function(
    df_cite_parsed_revid_art,
    source_types_list = c("publisher", "journal", "author",
                          "website", "newspaper")) {
  for (i in seq_along(source_types_list)) {
    plot_top_source(df_cite_parsed_revid_art,
                   as.character(source_types_list[i]))
  }
  invisible(NULL)
}


#' Plot the distribution of citation source types
#'
#' Displays a horizontal boxplot of citation-type counts for the four main
#' CS1 types: journal, news, web, and book.
#'
#' @param df_cite_count_revid_art Data frame of citation type counts as
#'   returned by \code{\link{get_citation_type}}.
#' @return A \code{ggplot2} object (invisibly).
#' @export
#' @examples
#' \dontrun{
#' recent <- get_article_most_recent_table("Zeitgeber")
#' df     <- get_citation_type(recent)
#' plot_distribution_source_type(df)
#' }
plot_distribution_source_type <- function(df_cite_count_revid_art) {
  p <- df_cite_count_revid_art |>
    dplyr::filter(cite_type %in% c("journal", "news", "web", "book")) |>
    dplyr::group_by(revid, cite_type, Freq) |>
    ggplot2::ggplot(ggplot2::aes(cite_type, Freq)) +
    ggplot2::geom_boxplot(width = 0.6) +
    ggplot2::coord_flip()
  print(p)
  invisible(p)
}


#' Identify the most-cited DOIs across a set of Wikipedia articles
#'
#' Finds the 40 most frequently cited DOIs, annotates them via EuropePMC and
#' CrossRef, and adds per-article citation counts.
#'
#' @param df_doi_revid_art Data frame of DOI matches as returned by
#'   \code{\link{get_regex_citations_in_wiki_table}} with the DOI regexp.
#' @return A data frame of the top cited DOIs with bibliographic annotations
#'   and Wikipedia citation counts.
#' @export
#' @examples
#' \dontrun{
#' doi_df <- get_regex_citations_in_wiki_table(
#'   get_article_most_recent_table("Zeitgeber"),
#'   "10\\.\\d{4,9}/[-._;()/:a-z0-9A-Z]+"
#' )
#' get_top_cited_wiki_papers(doi_df)
#' }
get_top_cited_wiki_papers <- function(df_doi_revid_art) {
  top_dois <- names(
    utils::tail(sort(table(unique(df_doi_revid_art)$citation_fetched)), 40)
  )
  wikicount <- data.frame(
    utils::tail(sort(table(unique(df_doi_revid_art)$citation_fetched)), 40)
  )
  colnames(wikicount) <- c("citation", "wiki_count")

  top_annotated <- annotate_doi_list_europmc(top_dois)
  top_annotated <- dplyr::inner_join(
    top_annotated, wikicount,
    by = c("doi" = "citation")
  )

  citation_counts <- rcrossref::cr_citation_count(doi = top_annotated$doi)
  top_annotated   <- dplyr::left_join(top_annotated, citation_counts, by = "doi")

  top20_cited_in_arts <- df_doi_revid_art |>
    dplyr::filter(citation_fetched %in% top_annotated$doi) |>
    unique() |>
    dplyr::select(citation_fetched, art) |>
    dplyr::group_by(citation_fetched) |>
    dplyr::summarise(
      cited_in_wiki_art = paste(art, collapse = ", "),
      .groups = "drop"
    )

  dplyr::left_join(
    top_annotated, top20_cited_in_arts,
    by = c("doi" = "citation_fetched")
  )
}
