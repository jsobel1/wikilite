# Recursively retrieve subcategories up to a given depth

Recursively retrieve subcategories up to a given depth

## Usage

``` r
get_subcat_with_depth(catname, depth, replecement = "_")
```

## Arguments

- catname:

  Character string — root category name.

- depth:

  Integer — number of levels to descend.

- replecement:

  Character used to replace spaces (default: `"_"`).

## Value

A data frame of all unique subcategories up to `depth` levels below
`catname`.

## Examples

``` r
if (FALSE) { # \dontrun{
get_subcat_with_depth("Category:Biology", depth = 2)
} # }
```
