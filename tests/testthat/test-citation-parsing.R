## Tests for citation_parsing.R
library(testthat)
library(wikilite)

# ── 1. pkg.env ────────────────────────────────────────────────────────────────

test_that("pkg.env contains all expected regexp entries", {
  expected <- c("doi_regexp", "isbn_regexp", "url_regexp", "pmid_regexp",
                "journal_regexp", "cite_regexp", "ref_regexp",
                "wikihyperlink_regexp")
  for (nm in expected) {
    expect_true(nm %in% ls(pkg.env),
                label = paste("pkg.env should contain", nm))
  }
})

test_that("pkg.env$regexp_list is a named character vector", {
  expect_type(pkg.env$regexp_list, "character")
  expect_named(pkg.env$regexp_list)
  expect_gte(length(pkg.env$regexp_list), 10L)
})

# ── 2. Count helpers ──────────────────────────────────────────────────────────

test_that("get_doi_count returns correct count", {
  text <- "DOI 10.1038/nature12373 and 10.1016/j.cell.2020.01.001"
  expect_equal(get_doi_count(text), 2L)
})

test_that("get_doi_count returns 0 when no DOI present", {
  expect_equal(get_doi_count("No DOIs here."), 0L)
})

test_that("get_refCount counts <ref> tags correctly", {
  text <- "<ref>ref one</ref> some text <ref name='r2'>ref two</ref>"
  expect_equal(get_refCount(text), 2L)
})

test_that("get_refCount returns 0 when no refs present", {
  expect_equal(get_refCount("No references."), 0L)
})

test_that("get_hyperlinkCount counts [[...]] links", {
  text <- "[[Article one]] and [[Article two|display]]"
  expect_equal(get_hyperlinkCount(text), 2L)
})

test_that("get_hyperlinkCount returns 0 for plain text", {
  expect_equal(get_hyperlinkCount("No links here."), 0L)
})

test_that("get_urlCount counts http/https URLs", {
  text <- "See https://example.com and http://test.org for details."
  expect_gte(get_urlCount(text), 2L)
})

test_that("get_ISBN_count detects isbn= prefixed ISBN", {
  text <- "Book isbn=978-0-06-112008-4 and ISBN: 0-06-112008-9"
  expect_gte(get_ISBN_count(text), 1L)
})

test_that("get_anyCount works with custom regexp", {
  expect_equal(get_anyCount("foo bar baz foo", "foo"), 2L)
})

test_that("get_anyCount returns 0 when no match", {
  expect_equal(get_anyCount("bar baz", "foo"), 0L)
})

# ── 3. Citation extraction ────────────────────────────────────────────────────

test_that("extract_citations returns character vector with CS1 templates", {
  text   <- make_fake_table()$`*`
  result <- extract_citations(text)
  expect_type(result, "character")
  expect_gte(length(result), 1L)
})

test_that("extract_citations returns empty vector when no templates", {
  expect_equal(length(extract_citations("Plain text, no templates.")), 0L)
})

test_that("extract_wikihypelinks returns all [[...]] links", {
  text   <- "[[Link one]] and [[Link two|display text]]"
  result <- extract_wikihypelinks(text)
  expect_length(result, 2L)
})

test_that("replace_wikihypelinks removes bracket syntax and keeps display text", {
  text   <- "See [[Zeitgeber|the article]] for details."
  result <- replace_wikihypelinks(text)
  expect_false(grepl("\\[\\[", result))
  expect_true(grepl("Zeitgeber", result))
})

# ── 4. Citation type parsing ──────────────────────────────────────────────────

test_that("parse_cite_type returns lowercase type for journal", {
  expect_equal(parse_cite_type("{{cite journal | author = Smith }}"), "journal")
})

test_that("parse_cite_type handles Cite (capital C) book", {
  expect_equal(parse_cite_type("{{Cite book | title = My Book }}"), "book")
})

test_that("parse_article_ALL_citations returns tidy data frame", {
  text   <- make_fake_table()$`*`
  result <- parse_article_ALL_citations(text)
  expect_s3_class(result, "data.frame")
  expect_true(all(c("type", "variable", "value") %in% names(result)))
  expect_gte(nrow(result), 1L)
})

# ── 5. SciScore ───────────────────────────────────────────────────────────────

test_that("get_sci_score returns numeric in [0, 1]", {
  text  <- make_fake_table()$`*`
  score <- get_sci_score(text)
  expect_type(score, "double")
  expect_gte(score, 0)
  expect_lte(score, 1)
})

test_that("get_sci_score returns 0 for text with no citations", {
  expect_equal(get_sci_score("No citations at all."), 0)
})

# ── 6. get_source_type_counts ─────────────────────────────────────────────────

test_that("get_source_type_counts returns data frame or NA", {
  text   <- make_fake_table()$`*`
  result <- get_source_type_counts(text)
  expect_true(is.data.frame(result) || is.na(result))
})

test_that("get_source_type_counts data frame has cite_type and Freq columns", {
  text   <- make_fake_table()$`*`
  result <- get_source_type_counts(text)
  if (is.data.frame(result)) {
    expect_true("cite_type" %in% names(result))
    expect_true("Freq" %in% names(result))
  }
})

# ── 7. Multi-article wrappers ─────────────────────────────────────────────────

test_that("get_regex_citations_in_wiki_table returns data frame", {
  tbl    <- make_fake_table()
  result <- get_regex_citations_in_wiki_table(tbl, pkg.env$doi_regexp)
  expect_s3_class(result, "data.frame")
  expect_true("citation_fetched" %in% names(result))
})

test_that("get_regex_citations_in_wiki_table returns 0-row df when no match", {
  tbl    <- make_fake_table("No citations here at all.")
  result <- get_regex_citations_in_wiki_table(tbl, pkg.env$doi_regexp)
  expect_equal(nrow(result), 0L)
})

test_that("extract_citations_regexp returns named list of length == regexp_list", {
  tbl    <- make_fake_table()
  result <- extract_citations_regexp(tbl)
  expect_type(result, "list")
  expect_named(result)
  expect_equal(length(result), length(pkg.env$regexp_list))
})

test_that("get_citation_type returns data frame with art column", {
  tbl    <- make_fake_table()
  result <- get_citation_type(tbl)
  expect_s3_class(result, "data.frame")
  expect_true("art" %in% names(result))
})

test_that("get_parsed_citations returns data frame with type/variable/value", {
  tbl    <- make_fake_table()
  result <- get_parsed_citations(tbl)
  expect_s3_class(result, "data.frame")
  if (nrow(result) > 0L) {
    expect_true(all(c("art", "type", "variable", "value") %in% names(result)))
  }
})

# ── 8. classify_cite_type ─────────────────────────────────────────────────────

test_that("classify_cite_type maps journal / article → Journal", {
  expect_equal(classify_cite_type("journal"), "Journal")
  expect_equal(classify_cite_type("article"), "Journal")
})

test_that("classify_cite_type maps preprint types → Preprint", {
  expect_equal(classify_cite_type("arxiv"),   "Preprint")
  expect_equal(classify_cite_type("ssrn"),    "Preprint")
  expect_equal(classify_cite_type("biorxiv"), "Preprint")
})

test_that("classify_cite_type maps book variants → Book", {
  expect_equal(classify_cite_type("book"),         "Book")
  expect_equal(classify_cite_type("encyclopaedia"), "Book")
  expect_equal(classify_cite_type("encyclopedia"),  "Book")
  expect_equal(classify_cite_type("encyclop"),      "Book")
})

test_that("classify_cite_type maps web → Web", {
  expect_equal(classify_cite_type("web"), "Web")
})

test_that("classify_cite_type maps news / magazine / newspaper → News/Magazine", {
  expect_equal(classify_cite_type("news"),      "News/Magazine")
  expect_equal(classify_cite_type("magazine"),  "News/Magazine")
  expect_equal(classify_cite_type("newspaper"), "News/Magazine")
})

test_that("classify_cite_type maps thesis → Thesis", {
  expect_equal(classify_cite_type("thesis"), "Thesis")
})

test_that("classify_cite_type maps conference → Conference", {
  expect_equal(classify_cite_type("conference"), "Conference")
})

test_that("classify_cite_type maps report types → Report", {
  expect_equal(classify_cite_type("report"),       "Report")
  expect_equal(classify_cite_type("press release"), "Report")
  expect_equal(classify_cite_type("pressrelease"),  "Report")
})

test_that("classify_cite_type maps multimedia types → Multimedia", {
  expect_equal(classify_cite_type("av media"), "Multimedia")
  expect_equal(classify_cite_type("avmedia"),  "Multimedia")
  expect_equal(classify_cite_type("episode"),  "Multimedia")
  expect_equal(classify_cite_type("podcast"),  "Multimedia")
  expect_equal(classify_cite_type("video"),    "Multimedia")
})

test_that("classify_cite_type maps legal types → Legal/Patent", {
  expect_equal(classify_cite_type("patent"), "Legal/Patent")
  expect_equal(classify_cite_type("court"),  "Legal/Patent")
})

test_that("classify_cite_type maps social media → Social Media", {
  expect_equal(classify_cite_type("tweet"),  "Social Media")
  expect_equal(classify_cite_type("reddit"), "Social Media")
})

test_that("classify_cite_type returns Other for unknown types", {
  expect_equal(classify_cite_type("unknown_type_xyz"), "Other")
  expect_equal(classify_cite_type(""),                 "Other")
})

test_that("classify_cite_type is case-insensitive", {
  expect_equal(classify_cite_type("JOURNAL"),    "Journal")
  expect_equal(classify_cite_type("ArXiV"),      "Preprint")
  expect_equal(classify_cite_type("Book"),       "Book")
  expect_equal(classify_cite_type("WEB"),        "Web")
  expect_equal(classify_cite_type("Conference"), "Conference")
})

test_that("classify_cite_type trims leading/trailing whitespace", {
  expect_equal(classify_cite_type("  journal  "), "Journal")
  expect_equal(classify_cite_type("\tweb\n"),     "Web")
})

# ── 9. parse_cite_type: new template coverage ─────────────────────────────────

test_that("parse_cite_type handles {{cite thesis}}", {
  expect_equal(parse_cite_type("{{cite thesis | author = Smith }}"), "thesis")
})

test_that("parse_cite_type handles {{cite conference}}", {
  expect_equal(parse_cite_type("{{cite conference | title = Proc }}"), "conference")
})

test_that("parse_cite_type handles {{cite report}}", {
  expect_equal(parse_cite_type("{{cite report | title = Report }}"), "report")
})

test_that("parse_cite_type handles {{cite news}}", {
  expect_equal(parse_cite_type("{{cite news | title = Article }}"), "news")
})

test_that("parse_cite_type handles {{cite magazine}}", {
  expect_equal(parse_cite_type("{{cite magazine | title = Mag }}"), "magazine")
})

test_that("parse_cite_type handles {{cite arxiv}}", {
  expect_equal(parse_cite_type("{{cite arxiv | eprint = 2101.00001 }}"), "arxiv")
})

test_that("parse_cite_type handles {{Cite book}} (capital C)", {
  expect_equal(parse_cite_type("{{Cite book | title = My Book }}"), "book")
})

test_that("parse_cite_type returns non-cite token for sfn/harvnb (classify_cite_type maps them to Other)", {
  r_sfn    <- parse_cite_type("{{sfn | Smith | 2020 }}")
  r_harvnb <- parse_cite_type("{{harvnb | Jones | 2018 }}")
  # Not a recognised cite type
  expect_equal(classify_cite_type(r_sfn),    "Other")
  expect_equal(classify_cite_type(r_harvnb), "Other")
})
