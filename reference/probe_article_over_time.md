# Probe a Wikipedia article at multiple time points

For each timestamp in `dates_to_probe`, fetches the article snapshot and
computes the requested quality metrics. This implements the monthly
probing approach used in COVID-19 citation analysis.

## Usage

``` r
probe_article_over_time(
  article_name,
  dates_to_probe,
  lang = "en",
  metrics = c("sci_score", "doi_count", "ref_count", "size")
)
```

## Arguments

- article_name:

  Character string — Wikipedia article title.

- dates_to_probe:

  Character vector of ISO 8601 timestamps (e.g.
  `"2021-01-01T00:00:00Z"`).

- lang:

  Two-letter language code (default: `"en"`).

- metrics:

  Character vector of metrics to compute. Any subset of
  `c("sci_score", "doi_count", "ref_count", "size")`.

## Value

A data frame with one row per successfully fetched date and columns
`date`, `art`, and one column per requested metric.

## Examples

``` r
# \donttest{
dates <- paste0(2018:2023, "-01-01T00:00:00Z")
probe_article_over_time("Zeitgeber", dates)
# }
```
