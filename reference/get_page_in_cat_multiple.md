# Retrieve pages for multiple Wikipedia categories

Retrieve pages for multiple Wikipedia categories

## Usage

``` r
get_page_in_cat_multiple(catlist, replacement = "_", lang = "en")
```

## Arguments

- catlist:

  Character vector of category names.

- replacement:

  Character used to replace spaces (default: `"_"`).

- lang:

  Two-letter language code (default: `"en"`).

## Value

A combined data frame of page metadata.

## Examples

``` r
# \donttest{
get_page_in_cat_multiple(c("Category:Biology", "Category:Medicine"))
# }
```
