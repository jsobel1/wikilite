# Compute citation latency between Wikipedia insertion and first publication

Joins a DOI history data frame with EuropePMC annotation to compute, for
each citation, how many days elapsed between the paper's first
publication and its first appearance in the Wikipedia article. Also
flags preprints by DOI prefix (`10.1101/`).

## Usage

``` r
compute_citation_latency(doi_history_df, epmc_annotation_df)
```

## Arguments

- doi_history_df:

  Data frame from
  [`get_regex_citations_in_wiki_table`](https://jsobel1.github.io/wikilite/reference/get_regex_citations_in_wiki_table.md)
  with columns `art`, `revid`, `timestamp` (optional), and
  `citation_fetched`.

- epmc_annotation_df:

  Data frame from
  [`annotate_doi_list_europmc`](https://jsobel1.github.io/wikilite/reference/annotate_doi_list_europmc.md)
  with columns `doi` and `firstPublicationDate`.

## Value

A joined data frame with additional columns `latency_days` (numeric) and
`is_preprint` (logical).

## Examples

``` r
# \donttest{
recent  <- get_article_most_recent_table("Zeitgeber")
doi_df  <- get_regex_citations_in_wiki_table(recent, pkg.env$doi_regexp)
epmc_df <- annotate_doi_list_europmc(unique(doi_df$citation_fetched))
latency <- compute_citation_latency(doi_df, epmc_df)
# }
```
