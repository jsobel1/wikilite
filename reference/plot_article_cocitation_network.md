# Build an interactive article co-citation network

Constructs an undirected weighted network where nodes are Wikipedia
articles and an edge between two articles indicates that they both cite
at least `min_shared_dois` of the same DOIs. Edge thickness scales with
the number of shared citations; node size scales with connectivity.

## Usage

``` r
plot_article_cocitation_network(
  articles,
  date_an = "2024-01-01T00:00:00Z",
  min_shared_dois = 1L
)
```

## Arguments

- articles:

  Character vector of English Wikipedia article titles.

- date_an:

  Character string. Upper date limit in ISO 8601 format (default:
  `"2024-01-01T00:00:00Z"`).

- min_shared_dois:

  Minimum number of shared DOIs required to draw an edge (default: 1).
  Increase this to focus on the most strongly connected pairs.

## Value

A `visNetwork` htmlwidget, or `NULL` (invisibly) if no article pairs
share enough DOIs.

## Details

Hovering over an edge lists the top shared DOIs. Clicking a node opens
the Wikipedia article in a new tab.

## Examples

``` r
if (FALSE) { # \dontrun{
articles <- c("Zeitgeber", "Advanced sleep phase disorder",
              "Sleep deprivation", "Circadian rhythm",
              "Non-24-hour sleep-wake disorder")
plot_article_cocitation_network(articles, min_shared_dois = 2)
} # }
```
