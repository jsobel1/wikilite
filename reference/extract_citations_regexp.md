# Apply all built-in regular expressions to a Wikipedia revision table

Iterates over every pattern in
[`pkg.env`](https://jsobel1.github.io/wikilite/reference/pkg.env.md)`$regexp_list`
and returns a named list of data frames, one per pattern.

## Usage

``` r
extract_citations_regexp(article_most_recent_table)
```

## Arguments

- article_most_recent_table:

  A Wikipedia revision data frame (e.g. from
  [`get_category_articles_most_recent`](https://jsobel1.github.io/wikilite/reference/get_category_articles_most_recent.md)).

## Value

A named list of data frames, one per entry in `pkg.env$regexp_list`.
Each element has columns `art`, `revid`, and `citation_fetched`.

## Examples

``` r
# \donttest{
recent       <- get_article_most_recent_table("Zeitgeber")
all_citations <- extract_citations_regexp(recent)
names(all_citations)
# }
```
