# Retrieve subcategories for multiple Wikipedia categories

Retrieve subcategories for multiple Wikipedia categories

## Usage

``` r
get_subcat_multiple(catlist, replecement = "_")
```

## Arguments

- catlist:

  Character vector of category names.

- replecement:

  Character used to replace spaces (default: `"_"`).

## Value

A combined data frame of subcategory metadata.

## Examples

``` r
if (FALSE) { # \dontrun{
get_subcat_multiple(c("Category:Biology", "Category:Medicine"))
} # }
```
