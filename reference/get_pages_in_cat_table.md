# Retrieve pages in a Wikipedia category

Retrieve pages in a Wikipedia category

## Usage

``` r
get_pages_in_cat_table(catname, replacement = "_", lang = "en")
```

## Arguments

- catname:

  Character string — category name, with or without the `"Category:"`
  prefix.

- replacement:

  Character used to replace spaces (default: `"_"`).

- lang:

  Two-letter language code (default: `"en"`).

## Value

A data frame of page metadata with an additional column `parent_cat`.

## Examples

``` r
# \donttest{
get_pages_in_cat_table("Category:Biology")
# }
```
