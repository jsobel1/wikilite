# Recursively retrieve subcategories up to a given depth

Recursively retrieve subcategories up to a given depth

## Usage

``` r
get_subcat_with_depth(catname, depth, replacement = "_", lang = "en")
```

## Arguments

- catname:

  Character string — root category name.

- depth:

  Integer — number of levels to descend.

- replacement:

  Character used to replace spaces (default: `"_"`).

- lang:

  Two-letter language code (default: `"en"`).

## Value

A data frame of all unique subcategories up to `depth` levels below
`catname`.

## Examples

``` r
# \donttest{
get_subcat_with_depth("Category:Biology", depth = 2)
# }
```
