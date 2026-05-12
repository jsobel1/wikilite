# Annotate a list of ISBNs using Altmetric

Annotate a list of ISBNs using Altmetric

## Usage

``` r
annotate_isbn_list_altmetrics(isbn_list)
```

## Arguments

- isbn_list:

  A *list* of ISBN character strings.

## Value

A data frame of Altmetric scores for the supplied ISBNs.

## Examples

``` r
if (FALSE) { # \dontrun{
# Requires the optional 'rAltmetric' package (not on CRAN):
#   remotes::install_github('ropensci/rAltmetric')
annotate_isbn_list_altmetrics(list(c("9780156031356")))
} # }
```
