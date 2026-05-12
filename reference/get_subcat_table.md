# Retrieve subcategories of a Wikipedia category

Retrieve subcategories of a Wikipedia category

## Usage

``` r
get_subcat_table(catname, replacement = "_", lang = "en")
```

## Arguments

- catname:

  Character string — category name, with or without the `"Category:"`
  prefix.

- replacement:

  Character used to replace spaces in the category name for the API
  query (default: `"_"`).

- lang:

  Two-letter language code (default: `"en"`).

## Value

A data frame of subcategory metadata with an additional column
`parent_cat`.

## Examples

``` r
# \donttest{
get_subcat_table("Category:Biology")
# }
```
