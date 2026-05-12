# Retrieve subcategories for multiple Wikipedia categories

Retrieve subcategories for multiple Wikipedia categories

## Usage

``` r
get_subcat_multiple(catlist, replacement = "_", lang = "en")
```

## Arguments

- catlist:

  Character vector of category names.

- replacement:

  Character used to replace spaces (default: `"_"`).

- lang:

  Two-letter language code (default: `"en"`).

## Value

A combined data frame of subcategory metadata.

## Examples

``` r
# \donttest{
get_subcat_multiple(c("Category:Biology", "Category:Medicine"))
# }
```
