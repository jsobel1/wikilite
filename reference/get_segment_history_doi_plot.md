# Plot DOI latency as horizontal segments

Produces a segment plot showing, for each DOI, the gap between paper
publication date (navy dot) and first Wikipedia citation insertion (red
triangle). DOIs are ordered by publication date.

## Usage

``` r
get_segment_history_doi_plot(df_doi, art_name)
```

## Arguments

- df_doi:

  A data frame as returned by
  [`compute_citation_latency`](https://jsobel1.github.io/wikilite/reference/compute_citation_latency.md)
  with columns `citation_fetched`, `firstPublicationDate`, and
  `latency_days`.

- art_name:

  Character string used as the plot title.

## Value

A `ggplot2` object (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
get_segment_history_doi_plot(latency_df, "Zeitgeber")
} # }
```
