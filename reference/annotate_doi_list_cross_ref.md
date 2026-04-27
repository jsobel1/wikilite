# Annotate a list of DOIs using CrossRef

Queries the CrossRef API for each DOI and returns a data frame of
bibliographic metadata merged with CrossRef citation counts.

## Usage

``` r
annotate_doi_list_cross_ref(doi_list)
```

## Arguments

- doi_list:

  Character vector of DOIs.

## Value

A data frame of CrossRef metadata merged with citation counts.

## Examples

``` r
if (FALSE) { # \dontrun{
annotate_doi_list_cross_ref(c("10.1038/nature12373"))
} # }
```
