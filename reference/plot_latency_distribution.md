# Plot the distribution of citation latency

Produces a ggplot2 density or violin plot of the number of days between
paper publication and Wikipedia citation insertion. Optionally
stratifies by preprint status and annotates with a KS test p-value.

## Usage

``` r
plot_latency_distribution(latency_df, stratify_by = NULL)
```

## Arguments

- latency_df:

  Data frame as returned by
  [`compute_citation_latency`](https://jsobel1.github.io/wikilite/reference/compute_citation_latency.md)
  with columns `latency_days` and optionally `is_preprint`.

- stratify_by:

  Character string or `NULL`. Use `"is_preprint"` to compare preprints
  vs. journal articles; any other value or `NULL` plots the pooled
  distribution.

## Value

A `ggplot2` object (invisibly).

## Examples

``` r
# \donttest{
recent  <- get_article_most_recent_table("Zeitgeber")
doi_df  <- get_regex_citations_in_wiki_table(recent, pkg.env$doi_regexp)
epmc_df <- annotate_doi_list_europmc(unique(doi_df$citation_fetched))
latency <- compute_citation_latency(doi_df, epmc_df)
plot_latency_distribution(latency)
plot_latency_distribution(latency, stratify_by = "is_preprint")
# }
```
