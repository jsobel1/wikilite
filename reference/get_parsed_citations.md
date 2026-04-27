# Parse all CS1 citations across a Wikipedia revision table

Applies
[`parse_article_ALL_citations`](https://jsobel1.github.io/wikilite/reference/parse_article_ALL_citations.md)
to every row of `article_most_recent_table` and returns a combined tidy
data frame.

## Usage

``` r
get_parsed_citations(article_most_recent_table)
```

## Arguments

- article_most_recent_table:

  A Wikipedia revision data frame (e.g. from
  [`get_category_articles_most_recent`](https://jsobel1.github.io/wikilite/reference/get_category_articles_most_recent.md)).

## Value

A data frame with columns `art`, `revid`, `type`, `id_cite`, `variable`,
and `value`.

## Examples

``` r
if (FALSE) { # \dontrun{
recent <- get_category_articles_most_recent(
  c("Zeitgeber", "Advanced sleep phase disorder", "Sleep deprivation")
)
parsed <- get_parsed_citations(recent)
} # }
```
