# Annotate a single ISBN using the Google Books API

Annotate a single ISBN using the Google Books API

## Usage

``` r
annotate_isbn_google(isbn_nb)
```

## Arguments

- isbn_nb:

  ISBN-10 or ISBN-13 string; hyphens and spaces are removed
  automatically.

## Value

A data frame with columns `title`, `publisher`, `publishedDate`,
`description`, `categories`, and `authors`, or `NULL` if the ISBN is not
found.

## Examples

``` r
if (FALSE) { # \dontrun{
annotate_isbn_google("978-0-15-603135-6")
} # }
```
