# Retrieve pages in a Wikipedia category

Retrieve pages in a Wikipedia category

## Usage

``` r
get_pages_in_cat_table(catname, replecement = "_")
```

## Arguments

- catname:

  Character string — category name, with or without the `"Category:"`
  prefix.

- replecement:

  Character used to replace spaces (default: `"_"`).

## Value

A data frame of page metadata with an additional column `parent_cat`.

## Examples

``` r
if (FALSE) { # \dontrun{
get_pages_in_cat_table("Category:Biology")
} # }
```
