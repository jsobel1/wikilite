# Retrieve pages for multiple Wikipedia categories

Retrieve pages for multiple Wikipedia categories

## Usage

``` r
get_page_in_cat_multiple(catlist, replecement = "_")
```

## Arguments

- catlist:

  Character vector of category names.

- replecement:

  Character used to replace spaces (default: `"_"`).

## Value

A combined data frame of page metadata.

## Examples

``` r
if (FALSE) { # \dontrun{
get_page_in_cat_multiple(c("Category:Biology", "Category:Medicine"))
} # }
```
