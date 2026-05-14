# wikilite

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/wikilite)](https://CRAN.R-project.org/package=wikilite)
[![R-CMD-check](https://github.com/jsobel1/wikilite/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jsobel1/wikilite/actions/workflows/R-CMD-check.yaml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html)
<!-- badges: end -->

**wikilite** is an R toolkit for mining Wikipedia article revision history and citations via the public [MediaWiki API](https://www.mediawiki.org/wiki/API:Main_page). It provides a complete pipeline — from raw wikitext retrieval through citation extraction, bibliographic annotation, quality scoring, and publication-ready visualisation — in a single CRAN-ready package.

---

## Table of Contents

1. [Why wikilite?](#why-wikilite)
2. [Installation](#installation)
3. [Quick start](#quick-start)
4. [Core workflow](#core-workflow)
   - [Retrieve article history](#1-retrieve-article-history)
   - [Navigate categories](#2-navigate-categories)
   - [Extract citations](#3-extract-citations)
   - [Parse Citation Style 1 templates](#4-parse-citation-style-1-templates)
   - [Quality metrics — SciScore](#5-quality-metrics--sciscore)
   - [Annotate DOIs](#6-annotate-dois)
   - [Annotate ISBNs](#7-annotate-isbns)
   - [Visualise](#8-visualise)
   - [Detect revert trends](#9-detect-revert-trends)
   - [Interactive timeline and networks](#10-interactive-timeline-and-networks)
   - [Export results](#11-export-results)
5. [Function reference](#function-reference)
6. [Built-in regular expressions](#built-in-regular-expressions)
7. [Data model](#data-model)
8. [Dependencies](#dependencies)
9. [Contributing](#contributing)
10. [Citation](#citation)
11. [License](#license)

---

## Why wikilite?

Wikipedia is the world's largest encyclopaedia and a primary reference point for hundreds of millions of readers. Understanding *how* it cites scientific literature — which papers are referenced, how those citations evolve over time, and how scientifically sourced different topic areas are — requires programmatic access to revision history and structured citation data.

**wikilite** makes this research straightforward:

- Pull the **complete edit history** of any English Wikipedia article with a single function call.
- **Extract every citation** type (DOIs, ISBNs, PMIDs, URLs, CS1 templates) using battle-tested regular expressions or your own patterns.
- **Annotate** extracted identifiers against EuropePMC, CrossRef, Google Books, and Open Library.
- Compute **SciScore** — a reproducible metric for how scientifically sourced an article is.
- Identify **revert-tagged edits** to detect disputed or vandalism-prone articles.
- Generate **ggplot2 visualisations** — timelines, edit-activity charts, and citation distributions — with one line of code.
- Build **interactive htmlwidgets** — Plotly timelines and three types of visNetwork graphs — directly from a list of article titles.

---

## Installation

```r
# Stable release from CRAN
install.packages("wikilite")

# Development version from GitHub
# install.packages("remotes")
remotes::install_github("jsobel1/wikilite")
```

**System requirements:** R ≥ 4.1.0 (for the native pipe operator `|>`). No Java or compiled-code dependencies.

---

## Quick start

```r
library(wikilite)

# 1. Fetch the most recent revision of an article
recent <- get_article_most_recent_table("Zeitgeber")

# 2. Count citations in the raw wikitext
text <- recent$`*`
get_doi_count(text)        #> 12
get_refCount(text)         #> 38
get_sci_score(text)        #> 0.76  (76% of CS1 citations are journal citations)

# 3. Annotate the DOIs via EuropePMC
doi_df   <- get_regex_citations_in_wiki_table(recent, pkg.env$doi_regexp)
annotated <- annotate_doi_list_europmc(unique(doi_df$citation_fetched))
head(annotated[, c("title", "journalTitle", "pubYear", "citedByCount")])
```

---

## Core workflow

### 1. Retrieve article history

#### Single article

| Function | Description |
|----------|-------------|
| `get_article_full_history_table(article, date_an)` | All revisions up to `date_an`, ordered chronologically |
| `get_article_initial_table(article)` | First revision only (article creation) |
| `get_article_most_recent_table(article, date_an)` | Most recent revision before `date_an` |
| `get_article_info_table(article, date_an)` | Page metadata: ID, title, byte size |
| `get_tables_initial_most_recent_full_info(articles)` | All four tables as a named list |

```r
# Full revision history (every edit ever made)
history <- get_article_full_history_table("Zeitgeber",
                                          date_an = "2023-01-01T00:00:00Z")
nrow(history)   # one row per revision
names(history)  # art, revid, parentid, user, userid, timestamp, size, comment, *

# First and most recent revisions
first  <- get_article_initial_table("Zeitgeber")
latest <- get_article_most_recent_table("Zeitgeber")

# Convenience wrapper: fetch all four table types for a list of articles
res <- get_tables_initial_most_recent_full_info(
  c("Zeitgeber", "Sleep deprivation")
)
names(res)
# [1] "article_initial_table"      "article_most_recent_table"
# [3] "article_info_table"         "article_full_history_table"
```

#### Multiple articles at once

```r
articles <- c("Zeitgeber", "Advanced sleep phase disorder", "Sleep deprivation")

history_all <- get_category_articles_history(articles)
creation    <- get_category_articles_creation(articles)
recent_all  <- get_category_articles_most_recent(articles)
```

---

### 2. Navigate categories

Wikipedia's category tree lets you discover related articles automatically.

```r
# All articles in a category (up to 500)
sleep_articles <- get_pagename_in_cat("Circadian rhythm")
head(sleep_articles)

# Direct subcategories of a category
subcats <- get_subcat_table("Category:Biology")

# Pages in a category (alternative to get_pagename_in_cat)
pages <- get_pages_in_cat_table("Category:Neuroscience")

# Recurse N levels deep
deep_subcats <- get_subcat_with_depth("Category:Medicine", depth = 2)

# Batch wrappers for multiple categories
all_subcats <- get_subcat_multiple(c("Category:Biology", "Category:Medicine"))
all_pages   <- get_page_in_cat_multiple(c("Category:Biology", "Category:Medicine"))
```

---

### 3. Extract citations

#### Using the pre-built pattern store

All regular expressions live in `pkg.env`:

```r
# Inspect available patterns
names(pkg.env$regexp_list)
#  [1] "doi_regexp"           "isbn_regexp"          "url_regexp"
#  [4] "wikihyperlink_regexp" "tweet_regexp"         "news_regexp"
#  [7] "journal_regexp"       "web_regexp"           "article_regexp"
# [10] "report_regexp"        "court_regexp"         "press_release_regexp"
# [13] "book_regexp"          "pmid_regexp"          "ref_in_text_regexp"
# [16] "ref_regexp"           "cite_regexp"          "template_regexp"

# Extract DOIs from a revision table
doi_df <- get_regex_citations_in_wiki_table(recent, pkg.env$doi_regexp)
#   art      revid  citation_fetched
#   Zeitgeber 9812345 10.1007/s00359-002-0315-4
#   ...

# Apply ALL patterns at once — returns a named list of data frames
all_results <- extract_citations_regexp(recent)
sapply(all_results, nrow)
```

#### Using a custom pattern

```r
# Example: extract PubMed Central IDs
pmc_regexp <- "PMC\\d{5,8}"
pmc_df <- get_regex_citations_in_wiki_table(recent, pmc_regexp)
```

#### Count helpers (fast scalar summaries)

```r
text <- recent$`*`

get_doi_count(text)         # number of DOIs
get_refCount(text)          # number of <ref>...</ref> blocks
get_urlCount(text)          # number of http(s):// URLs
get_hyperlinkCount(text)    # number of [[...]] wikilinks
get_ISBN_count(text)        # number of ISBNs
get_anyCount(text, "PMID")  # custom pattern count
```

---

### 4. Parse Citation Style 1 templates

CS1 templates (`{{cite journal}}`, `{{cite book}}`, etc.) are the structured citation markup used throughout English Wikipedia.

```r
# Determine the type of a single citation
parse_cite_type("{{cite journal | author = Smith | year = 2020 }}")
#> [1] "journal"

# Extract all CS1 templates from wikitext as raw strings
citations_raw <- extract_citations(recent$`*`)

# Parse a single article into a tidy long data frame
parsed_one <- parse_article_ALL_citations(recent$`*`)
#   type    id_cite variable  value
#   journal 1       author    Smith J
#   journal 1       year      2020
#   journal 1       doi       10.1038/...
#   web     2       url       https://...
#   ...

# Parse multiple articles at once
parsed_all <- get_parsed_citations(recent_all)

# Summarise citation type frequencies per article
type_counts <- get_citation_type(recent_all)
```

#### Working with wikilinks inside citations

```r
# Extract all [[...]] links
links <- extract_wikihypelinks(recent$`*`)

# Replace wikilink markup with plain text before further parsing
clean_text <- replace_wikihypelinks(recent$`*`)
```

---

### 5. Quality metrics — SciScore

**SciScore** quantifies how scientifically sourced a Wikipedia article is.

| Metric | Formula | Range | Interpretation |
|--------|---------|-------|---------------|
| `get_sci_score()` | (journal citations) / (all CS1 citations) | 0 – 1 | 1 = all citations are to peer-reviewed journals |

```r
text <- recent$`*`

get_sci_score(text)   #> 0.76

# Compare across multiple articles
scores <- vapply(seq_len(nrow(recent_all)),
                 function(i) get_sci_score(recent_all$`*`[i]),
                 numeric(1))
names(scores) <- recent_all$art
sort(scores, decreasing = TRUE)
```

---

### 6. Annotate DOIs

| Function | Source | Returns |
|----------|--------|---------|
| `annotate_doi_list_europmc(doi_list)` | EuropePMC | title, authors, journal, year, open-access status, citation count |
| `annotate_doi_list_cross_ref(doi_list)` | CrossRef | full bibliographic metadata + citation count |
| `annotate_doi_to_bibtex_cross_ref(doi_list)` | CrossRef | list of BibTeX strings |
| `get_top_cited_wiki_papers(doi_df)` | EuropePMC + CrossRef | top 40 most-cited DOIs across your article set |

```r
doi_list <- unique(doi_df$citation_fetched)

# EuropePMC (open-access, fast)
epmc <- annotate_doi_list_europmc(doi_list[1:10])
head(epmc[, c("doi", "title", "journalTitle", "pubYear", "citedByCount")])

# CrossRef (richer metadata)
cr <- annotate_doi_list_cross_ref(doi_list[1:10])

# BibTeX entries
bibtex <- annotate_doi_to_bibtex_cross_ref(doi_list[1:5])
cat(bibtex[[1]])

# Top 40 most-cited papers across all articles
top40 <- get_top_cited_wiki_papers(doi_df)
head(top40[, c("title", "journalTitle", "pubYear", "wiki_count", "count")])
```

---

### 7. Annotate ISBNs

```r
isbn_df   <- get_regex_citations_in_wiki_table(recent, pkg.env$isbn_regexp)
isbn_list <- unique(isbn_df$citation_fetched)

# Google Books
gb <- annotate_isbn_google(isbn_list[1])
gb[, c("title", "publisher", "publishedDate", "categories")]

# Open Library
ol <- annotate_isbn_openlib(isbn_list[1])
```

---

### 8. Visualise

All plotting functions return a `ggplot2` object invisibly so you can further customise them with standard `+` syntax.

#### Article creation timeline

```r
initial <- get_category_articles_creation(sleep_articles)

# Cumulative creation curve
plot_article_creation_per_year(initial, name_title = "Sleep articles")

# Annual counts instead
plot_article_creation_per_year(initial, name_title = "Sleep articles",
                               Cumsum = FALSE)

# Static labelled timeline (one point per article)
plot_static_timeline(initial)
```

#### Page views and edit activity

```r
# Daily page views (Wikimedia pageviews API)
page_view_plot("Zeitgeber", start = "2020010100", end = "2021010100")

# Weekly edit counts
page_edit_plot("Zeitgeber", start = "2020010100", end = "2021010100")
```

#### Citation-type distributions

```r
type_counts <- get_citation_type(recent_all)

# Boxplot of journal / web / news / book citation counts
plot_distribution_source_type(type_counts)

# Bar chart for a single citation field
plot_top_source(parsed_all, "journal")     # top 20 journal names
plot_top_source(parsed_all, "publisher")   # top 20 publishers

# Bar charts for multiple fields at once
get_pdfs_top20source(parsed_all,
  source_types_list = c("journal", "publisher", "author", "website"))
```

---

### 9. Detect revert trends

`get_revert_counts()` queries all Wikipedia revisions in a time window and ranks articles by the number of revert-tagged edits (`mw-undo` or `mw-rollback`). This is useful for identifying disputed, controversial, or frequently vandalised articles.

```r
# One-hour window on 12 December 2018
reverts <- get_revert_counts(
  start = "20181212010000",   # newer boundary (YYYYMMDDHHmmss)
  end   = "20181212000000"    # older boundary
)

head(reverts, 10)
#    art                       sum_nb_reverts
#  1 Climate change            14
#  2 COVID-19 pandemic         11
#  3 Israel                     9
#  ...
```

The function handles pagination automatically and excludes articles with zero revert-tagged edits from the output.

---

### 10. Interactive timeline and networks

All four functions return self-contained **htmlwidgets** that render in the
RStudio Viewer, R Markdown documents, Quarto reports, and Shiny apps.
Nodes are clickable — clicking an article opens its Wikipedia page; clicking a
publication opens its DOI page.

#### Interactive Gantt timeline

```r
articles <- c("Zeitgeber", "Advanced sleep phase disorder",
              "Sleep deprivation", "Circadian rhythm")

# Colour bars by SciScore (default)
plot_interactive_timeline(articles)

# Colour by current article size
plot_interactive_timeline(articles, color_by = "size")
```

Each article appears as a horizontal bar spanning its edit lifetime.  Creation
and latest-revision markers are plotted separately.  Hover text shows creation
date, first editor, and byte sizes.

#### Article–publication bipartite network

```r
plot_article_publication_network(articles,
                                  min_wiki_count = 2)   # only DOIs cited by ≥ 2 articles
```

Blue square nodes are articles; orange circle nodes are cited publications.
Node size is proportional to citation degree.  Set `annotate = TRUE` to enrich
publication labels with EuropePMC paper titles (requires internet; slower):

```r
plot_article_publication_network(articles, annotate = TRUE, top_n_dois = 30)
```

#### Article co-citation network

```r
# Edge = articles share ≥ 3 DOIs; edge thickness ∝ shared count
plot_article_cocitation_network(articles, min_shared_dois = 3)
```

Hover over any edge to see the list of shared papers.  Useful for identifying
which articles cover overlapping scientific ground.

#### Article wikilink network

```r
# Show only links within the supplied article set (default)
plot_article_wikilink_network(articles)

# Also include the 40 most-linked-to external pages
plot_article_wikilink_network(articles,
                               only_internal = FALSE,
                               top_n_links   = 40)
```

Arrow direction follows the `[[...]]` hyperlink direction in the wikitext.
Input articles are shown as blue boxes; external targets as grey ellipses.

---

### 11. Export results

```r
# Revision table → Excel
write_wiki_history_to_xlsx(recent, file_name = "zeitgeber")
# → writes "zeitgeber_wiki_table.xlsx"

# All regex match results → one xlsx file per pattern
export_extracted_citations_xlsx(recent_all, name_file_prefix = "sleep_articles")
# → writes "sleep_articles_doi_regexp_extracted_citations.xlsx", etc.

# DOIs → BibTeX file
export_doi_to_bib(doi_list[1:20], file_name = "references.bib")
```

---

## Function reference

### Article history

| Function | Description |
|----------|-------------|
| `get_article_full_history_table()` | All revisions of one article |
| `get_article_initial_table()` | First revision only |
| `get_article_most_recent_table()` | Most recent revision |
| `get_article_info_table()` | Page metadata (ID, title, size) |
| `get_tables_initial_most_recent_full_info()` | All four tables in one call |
| `get_category_articles_history()` | Full history for multiple articles |
| `get_category_articles_creation()` | Creation revisions for multiple articles |
| `get_category_articles_most_recent()` | Most recent revisions for multiple articles |

### Category navigation

| Function | Description |
|----------|-------------|
| `get_pagename_in_cat()` | Article titles in a category |
| `get_subcat_table()` | Direct subcategories of a category |
| `get_pages_in_cat_table()` | Pages in a category |
| `get_subcat_multiple()` | Subcategories of multiple categories |
| `get_page_in_cat_multiple()` | Pages of multiple categories |
| `get_subcat_with_depth()` | Recursive subcategory traversal |

### Citation extraction & counting

| Function | Description |
|----------|-------------|
| `get_regex_citations_in_wiki_table()` | Apply any regexp to a revision table |
| `extract_citations_regexp()` | Apply all built-in patterns at once |
| `extract_citations()` | Extract raw CS1 template strings |
| `extract_wikihypelinks()` | Extract `[[...]]` links |
| `replace_wikihypelinks()` | Strip wikilink markup |
| `get_doi_count()` | Count DOIs |
| `get_refCount()` | Count `<ref>` tags |
| `get_urlCount()` | Count URLs |
| `get_hyperlinkCount()` | Count wikilinks |
| `get_ISBN_count()` | Count ISBNs |
| `get_anyCount()` | Count custom pattern matches |

### Citation parsing

| Function | Description |
|----------|-------------|
| `parse_cite_type()` | Determine CS1 citation type |
| `parse_article_ALL_citations()` | Parse all CS1 templates → tidy long data frame |
| `get_parsed_citations()` | Parse CS1 templates for multiple articles |
| `get_citation_type()` | Frequency table of citation types per article |
| `get_source_type_counts()` | Citation type counts for a single wikitext |

### Quality metrics

| Function | Description |
|----------|-------------|
| `get_sci_score()` | Proportion of journal citations (0–1) |

### DOI annotation

| Function | Description |
|----------|-------------|
| `annotate_doi_list_europmc()` | EuropePMC metadata |
| `annotate_doi_list_cross_ref()` | CrossRef metadata + citation counts |
| `annotate_doi_to_bibtex_cross_ref()` | CrossRef BibTeX entries |
| `get_top_cited_wiki_papers()` | Top 40 most-cited DOIs with full annotation |

### ISBN annotation

| Function | Description |
|----------|-------------|
| `annotate_isbn_google()` | Google Books metadata |
| `annotate_isbn_openlib()` | Open Library metadata |

### Revert trend analysis

| Function | Description |
|----------|-------------|
| `get_revert_counts()` | Revert-tagged edits per article in a time window |

### Visualisation

| Function | Description |
|----------|-------------|
| `plot_article_creation_per_year()` | Cumulative or annual creation timeline |
| `plot_static_timeline()` | Static labelled timeline |
| `plot_navi_timeline()` | Interactive timeline (stub — see note below) |
| `page_view_plot()` | Daily page views area chart |
| `page_edit_plot()` | Weekly edit counts area chart |
| `plot_top_source()` | Top 20 values for a citation field |
| `get_pdfs_top20source()` | Top-20 charts for multiple citation fields |
| `plot_distribution_source_type()` | Boxplot of citation type distributions |

> **Note:** `plot_navi_timeline()` is currently a stub — the `timevis` package is not on CRAN. Use `plot_static_timeline()` instead.

### Interactive timeline and networks

| Function | Description |
|----------|-------------|
| `plot_interactive_timeline()` | Plotly Gantt timeline of article edit lifetimes, coloured by SciScore, size, or uniform |
| `plot_article_publication_network()` | Bipartite visNetwork: article nodes → cited DOI nodes |
| `plot_article_cocitation_network()` | Article–article visNetwork weighted by shared DOI count |
| `plot_article_wikilink_network()` | Directed visNetwork of `[[...]]` wikilinks between articles |

### Export

| Function | Description |
|----------|-------------|
| `write_wiki_history_to_xlsx()` | Revision table → Excel |
| `export_extracted_citations_xlsx()` | All regex matches → Excel files |
| `export_doi_to_bib()` | DOIs → BibTeX file |

---

## Built-in regular expressions

Access all patterns via `pkg.env`:

```r
# List all available patterns
names(pkg.env$regexp_list)

# Use a specific pattern
pkg.env$doi_regexp
#> [1] "10\\.\\d{4,9}/[-._;()/:a-z0-9A-Z]+"

pkg.env$isbn_regexp
pkg.env$url_regexp
pkg.env$pmid_regexp
pkg.env$ref_regexp
pkg.env$cite_regexp        # any CS1 template
pkg.env$journal_regexp     # {{cite journal ...}}
pkg.env$book_regexp        # {{cite book ...}}
pkg.env$web_regexp         # {{cite web ...}}
pkg.env$news_regexp        # {{cite news ...}}
pkg.env$wikihyperlink_regexp  # [[...]]
pkg.env$template_regexp    # {{pp...}} protection templates
```

---

## Data model

The core data structure returned by all history functions is a **revision data frame**:

| Column | Type | Description |
|--------|------|-------------|
| `art` | `character` | Article title |
| `revid` | `integer` | Revision ID |
| `parentid` | `integer` | ID of the previous revision |
| `user` | `character` | Editor username |
| `userid` | `integer` | Editor user ID |
| `timestamp` | `character` | ISO 8601 timestamp (`"2020-03-15T14:22:01Z"`) |
| `size` | `integer` | Article size in bytes |
| `comment` | `character` | Edit summary |
| `*` | `character` | Raw wikitext (backtick-quoted in R: `` table$`*` ``) |

The **parsed citation data frame** (from `get_parsed_citations()`) adds:

| Column | Type | Description |
|--------|------|-------------|
| `type` | `character` | CS1 citation type (`"journal"`, `"book"`, `"web"`, …) |
| `id_cite` | `integer` | Citation index within the article |
| `variable` | `character` | Field name (`"author"`, `"doi"`, `"title"`, …) |
| `value` | `character` | Field value |

---

## Dependencies

### Required (Imports)

| Package | Purpose |
|---------|---------|
| `dplyr` ≥ 1.0.0 | Data manipulation |
| `europepmc` | EuropePMC API |
| `ggplot2` ≥ 3.3.0 | Visualisation |
| `ggrepel` | Non-overlapping labels on timelines |
| `httr` | HTTP requests to MediaWiki API |
| `jsonlite` | JSON parsing |
| `lubridate` | Date handling for page-view data |
| `openxlsx` | Excel export (no Java required) |
| `purrr` | Functional programming helpers |
| `rcrossref` | CrossRef API |
| `reshape2` | Long-to-wide reshaping for CrossRef results |
| `stringr` | Regular expression matching |
| `textclean` | Multi-string substitution |
| `WikipediR` | Wikipedia category API and pageviews |

### Suggested (only needed for specific tasks)

| Package | Purpose |
|---------|---------|
| `testthat` ≥ 3.0.0 | Running the test suite |
| `knitr` / `rmarkdown` | Building vignettes |
| `httptest2` | Offline HTTP fixture testing |
| `covr` | Code coverage |

---

## Contributing

Bug reports and feature requests are welcome at the [issue tracker](https://github.com/jsobel1/wikilite/issues).

For pull requests:

1. Fork the repository and create a descriptive branch.
2. Add or update tests in `tests/testthat/` — all network-dependent tests must include `skip_on_cran()`.
3. Wrap any new API-calling examples in `\dontrun{}`.
4. Run `devtools::check(args = "--as-cran")` and ensure **0 errors, 0 warnings**.
5. Update `NEWS.md` with a brief description of your change.

---

## Citation

If you use **wikilite** in published research, please cite:

```bibtex
@misc{sobel2026wikilite,
  author = {Sobel, Jonathan Aryeh},
  title  = {{wikilite}: Retrieve, Parse, and Analyse Wikipedia Article History and Citations},
  year   = {2026},
  note   = {R package version 0.1.0},
  url    = {https://github.com/jsobel1/wikilite}
}
```

This package implements and extends the methods described in:

> Benjakob O, Aviram R, Sobel JA. (2022). *Citation needed? Wikipedia bibliometrics
> during the first wave of the COVID-19 pandemic.* GigaScience, 11, giab095.
> doi:10.1093/gigascience/giab095

---

## Related tools

| Tool | Description |
|------|-------------|
| [**wikiliteApp**](https://github.com/jsobel1/wikiliteApp) | Interactive Shiny application built on this package. Top-level **Single Article** mode (History Flow, Citations, Authorship, Stability with SciScore-over-time, Vandalism & Wars, Revision Inspector with WikiWho token-level authorship) and **Corpus Analysis** mode (named/categorised article lists with cross-corpus timeline, citations panel including per-article + per-corpus SciScore, and three networks — co-citation, publication, wikilink — all with clickable nodes). Batched EuropePMC + Google Books annotation, multi-sheet XLSX exports. |
| [**wikicitation-mcp**](https://github.com/jsobel1/wikicitation-mcp) | MCP server exposing wikilite tools to Claude and other LLM assistants — pure Python, ~40 tools covering history, citation extraction, SciScore, and DOI / ISBN annotation |

---

## License

GPL-3 © Jonathan Sobel

See the [GPL-3 license](https://www.gnu.org/licenses/gpl-3.0) for full details.
