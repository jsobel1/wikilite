# Retrieve subcategories of a Wikipedia category

Retrieve subcategories of a Wikipedia category

## Usage

``` r
get_subcat_table(catname, replecement = "_")
```

## Arguments

- catname:

  Character string — category name, with or without the `"Category:"`
  prefix.

- replecement:

  Character used to replace spaces in the category name for the API
  query (default: `"_"`).

## Value

A data frame of subcategory metadata with an additional column
`parent_cat`.

## Examples

``` r
if (FALSE) { # \dontrun{
get_subcat_table("Category:Biology")
} # }
```
