# Build an interactive article-article wikilink network

Extracts `[[...]]`-style wikilinks from the wikitext of each article and
renders a directed visNetwork graph. Nodes represent Wikipedia articles
and directed edges represent hyperlinks from one article to another.

## Usage

``` r
plot_article_wikilink_network(
  articles,
  date_an = "2024-01-01T00:00:00Z",
  only_internal = TRUE,
  top_n_links = 80L
)
```

## Arguments

- articles:

  Character vector of English Wikipedia article titles.

- date_an:

  Character string. Upper date limit in ISO 8601 format (default:
  `"2024-01-01T00:00:00Z"`).

- only_internal:

  Logical. If `TRUE` (default), only wikilinks pointing to another
  article in `articles` are shown.

- top_n_links:

  When `only_internal = FALSE`, the maximum number of external link
  targets to include, chosen by link frequency (default: 80).

## Value

A `visNetwork` htmlwidget, or `NULL` (invisibly) if no qualifying links
are found.

## Details

By default (`only_internal = TRUE`) only links between articles in the
input set are drawn, making the graph useful for understanding how a
topic cluster cross-references itself. Set `only_internal = FALSE` to
also include the most-linked-to external Wikipedia pages (capped at
`top_n_links`).

Node size reflects in-degree (number of incoming links). Clicking any
node opens the corresponding Wikipedia article in a new browser tab.

## Examples

``` r
if (FALSE) { # \dontrun{
articles <- c("Zeitgeber", "Advanced sleep phase disorder",
              "Sleep deprivation", "Circadian rhythm")
# Internal links only
plot_article_wikilink_network(articles)

# Include top 40 external link targets
plot_article_wikilink_network(articles,
                              only_internal = FALSE,
                              top_n_links   = 40)
} # }
```
