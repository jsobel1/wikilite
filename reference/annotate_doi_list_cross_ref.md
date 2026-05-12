# Annotate a list of DOIs using CrossRef

Queries the CrossRef `/works` API for each DOI and returns a tidy data
frame of bibliographic metadata. Column names are aligned with those
returned by
[`annotate_doi_list_europmc`](https://jsobel1.github.io/wikilite/reference/annotate_doi_list_europmc.md)
to allow easy `coalesce`-based merging.

## Usage

``` r
annotate_doi_list_cross_ref(doi_list, batch_size = 50L)
```

## Arguments

- doi_list:

  Character vector of DOIs.

- batch_size:

  Integer. Number of DOIs per `cr_works` request (default 50).

## Value

A data frame with columns `doi`, `title`, `authorString`,
`journalTitle`, `pubYear`, `pubType`, `publisher`, `issn`, `volume`,
`issue`, `page`, and `citedByCount`.

## Examples

``` r
# \donttest{
annotate_doi_list_cross_ref(c("10.1038/nature16961"))
# }
```
