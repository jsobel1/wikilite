# Plot the distribution of citation source types

Displays a horizontal boxplot of citation-type counts for the four main
CS1 types: journal, news, web, and book.

## Usage

``` r
plot_distribution_source_type(df_cite_count_revid_art)
```

## Arguments

- df_cite_count_revid_art:

  Data frame of citation type counts as returned by
  [`get_citation_type`](https://jsobel1.github.io/wikilite/reference/get_citation_type.md).

## Value

A `ggplot2` object (invisibly).

## Examples

``` r
# \donttest{
recent <- get_article_most_recent_table("Zeitgeber")
df     <- get_citation_type(recent)
plot_distribution_source_type(df)
# }
```
