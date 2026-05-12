# Build an interactive article-publication bipartite network

Fetches the most recent wikitext for each article, extracts all DOIs,
and renders a visNetwork bipartite graph in which:

- Blue square nodes represent Wikipedia articles.

- Orange circular nodes represent cited publications (DOIs).

- Edges connect each article to the publications it cites.

- Node size is proportional to the number of DOIs cited (articles) or
  the number of citing articles (publications).

Clicking a publication node opens its DOI page in a new tab. Clicking an
article node opens its Wikipedia page.

## Usage

``` r
plot_article_publication_network(
  articles,
  date_an = NULL,
  lang = "en",
  top_n_dois = 50L,
  min_wiki_count = 2L,
  annotate = FALSE
)
```

## Arguments

- articles:

  Character vector of English Wikipedia article titles.

- date_an:

  Character string. Upper date limit in ISO 8601 format (default:
  current UTC time).

- lang:

  Two-letter Wikipedia language code (default `"en"`).

- top_n_dois:

  Maximum number of publication nodes to display (default: 50). The most
  widely cited DOIs are retained.

- min_wiki_count:

  Minimum number of articles that must cite a DOI for it to be shown
  (default: 2).

- annotate:

  Logical. If `TRUE`, publication node labels are enriched with titles
  from EuropePMC (requires a live internet connection; slow for large
  DOI lists). Default: `FALSE`.

## Value

A `visNetwork` htmlwidget.

## Examples

``` r
# \donttest{
articles <- c("Zeitgeber", "Advanced sleep phase disorder",
              "Sleep deprivation", "Circadian rhythm")
plot_article_publication_network(articles)

# With EuropePMC annotation for paper titles
plot_article_publication_network(articles, annotate = TRUE)
# }
```
