# Plot the top 20 values for a given citation field

Plot the top 20 values for a given citation field

## Usage

``` r
plot_top_source(df_cite_parsed_revid_art, source_type)
```

## Arguments

- df_cite_parsed_revid_art:

  Parsed citation data frame as returned by
  [`get_parsed_citations`](https://jsobel1.github.io/wikilite/reference/get_parsed_citations.md).

- source_type:

  Character string — the citation field to summarise (e.g.
  `"publisher"`, `"journal"`).

## Value

A `ggplot2` object (invisibly).

## Examples

``` r
# \donttest{
recent <- get_article_most_recent_table("Zeitgeber")
df     <- get_parsed_citations(recent)
plot_top_source(df, "publisher")
# }
```
