# Plot DOI latency segments

Produces a segment plot showing, for each DOI, the gap between paper
publication date and first Wikipedia citation insertion.

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
# \donttest{
recent  <- get_article_most_recent_table("Zeitgeber")
doi_df  <- get_regex_citations_in_wiki_table(recent, pkg.env$doi_regexp)
epmc_df <- annotate_doi_list_europmc(unique(doi_df$citation_fetched))
latency <- compute_citation_latency(doi_df, epmc_df)
get_segment_history_doi_plot(latency, "Zeitgeber")
# }
```
