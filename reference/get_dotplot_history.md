# Dot plot of DOI citation insertions over time

Plots each DOI citation insertion as a point on a scatter chart: x-axis
is Wikipedia insertion date, y-axis is latency in days. Points are
coloured by source type (journal vs. preprint).

## Usage

``` r
get_dotplot_history(df_doi, art_name)
```

## Arguments

- df_doi:

  A data frame as returned by
  [`compute_citation_latency`](https://jsobel1.github.io/wikilite/reference/compute_citation_latency.md)
  with columns `citation_fetched`, `firstPublicationDate`,
  `latency_days`, and `is_preprint`.

- art_name:

  Character string used as the plot title.

## Value

A `ggplot2` object (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
get_dotplot_history(latency_df, "Zeitgeber")
} # }
```
