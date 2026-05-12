# Annotate a list of DOIs using Altmetric

Retrieves Altmetric attention scores and social-media metrics for the
supplied DOIs.

## Usage

``` r
annotate_doi_list_altmetrics(doi_list)
```

## Arguments

- doi_list:

  A *list* of DOI character strings (as expected by
  [`purrr::pmap_df`](https://purrr.tidyverse.org/reference/map_dfr.html)).

## Value

A data frame of Altmetric scores and attention metrics.

## Examples

``` r
if (FALSE) { # \dontrun{
# Requires the optional 'rAltmetric' package (not on CRAN):
#   remotes::install_github('ropensci/rAltmetric')
art_test <- get_article_most_recent_table("Zeitgeber")
dois <- unique(unlist(stringr::str_match_all(
  art_test$`*`, "10\\.\\d{4,9}/[-._;()/:a-z0-9A-Z]+"
)))
annotate_doi_list_altmetrics(list(dois[1:3]))
} # }
```
