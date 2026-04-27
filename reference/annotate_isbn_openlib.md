# Annotate a single ISBN using the Open Library API

Annotate a single ISBN using the Open Library API

## Usage

``` r
annotate_isbn_openlib(isbn_nb)
```

## Arguments

- isbn_nb:

  ISBN-10 or ISBN-13 string; hyphens and spaces are removed
  automatically.

## Value

A data frame with Open Library metadata, or `NULL` if the ISBN is not
found.

## Examples

``` r
if (FALSE) { # \dontrun{
annotate_isbn_openlib("9780156031356")
} # }
```
