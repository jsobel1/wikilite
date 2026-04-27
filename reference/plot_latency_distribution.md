# Plot the distribution of citation latency

Produces a ggplot2 density plot of the number of days between paper
publication and Wikipedia citation insertion. Optionally stratifies by
preprint status (bioRxiv/medRxiv DOIs, prefix `10.1101/`) and annotates
with a KS-test p-value.

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
  vs. journal articles with a two-colour density plot and a
  Kolmogorov-Smirnov p-value annotation; any other value or `NULL` plots
  the pooled distribution.

## Value

A `ggplot2` object (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
plot_latency_distribution(latency_df)
plot_latency_distribution(latency_df, stratify_by = "is_preprint")
} # }
```
