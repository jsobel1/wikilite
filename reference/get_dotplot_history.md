# Dot plot of DOI citation edits over time

Plots each DOI citation insertion as a point on a timeline, providing a
fine-grained view of when citations were added to the article.

## Usage

``` r
get_dotplot_history(df_doi, art_name)
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
get_dotplot_history(latency, "Zeitgeber")
# }
```
