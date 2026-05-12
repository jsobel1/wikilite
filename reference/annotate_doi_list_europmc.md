# Annotate a list of DOIs using EuropePMC

Queries the EuropePMC REST API for each DOI and returns a data frame
with bibliographic metadata. Rows for DOIs not found in EuropePMC are
silently skipped.

## Usage

``` r
annotate_doi_list_europmc(doi_list, batch_size = 25L)
```

## Arguments

- doi_list:

  Character vector of DOIs.

- batch_size:

  Integer. Number of DOIs to request per EuropePMC batch query (default
  `25`). Larger values reduce the number of HTTP calls but increase
  per-request payload size.

## Value

A data frame with columns `id`, `source`, `pmid`, `pmcid`, `doi`,
`title`, `authorString`, `journalTitle`, `pubYear`, `pubType`,
`isOpenAccess`, `citedByCount`, and `firstPublicationDate`.

## Examples

``` r
# \donttest{
art_test <- get_article_most_recent_table("Zeitgeber")
dois <- unique(unlist(stringr::str_match_all(
  art_test$`*`, "10\\.\\d{4,9}/[-._;()/:a-z0-9A-Z]+"
)))
annotate_doi_list_europmc(dois[1:3])
# }
```
