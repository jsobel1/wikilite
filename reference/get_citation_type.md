# Summarise citation types across a Wikipedia revision table

Summarise citation types across a Wikipedia revision table

## Usage

``` r
get_citation_type(article_most_recent_table)
```

## Arguments

- article_most_recent_table:

  A Wikipedia revision data frame (e.g. from
  [`get_category_articles_most_recent`](https://jsobel1.github.io/wikilite/reference/get_category_articles_most_recent.md)).

## Value

A data frame with columns `art`, `revid`, `cite_type`, and `Freq`.

## Examples

``` r
if (FALSE) { # \dontrun{
recent <- get_article_most_recent_table("Zeitgeber")
get_citation_type(recent)
} # }
```
