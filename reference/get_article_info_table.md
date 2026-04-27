# Retrieve metadata for a Wikipedia article

Returns a named vector containing the page ID, title, and byte length of
the current revision of the article.

## Usage

``` r
get_article_info_table(article_name, date_an = "2020-05-01T00:00:00Z")
```

## Arguments

- article_name:

  Character string giving the English Wikipedia article title.

- date_an:

  Character string — reference date in ISO 8601 format (default:
  `"2020-05-01T00:00:00Z"`).

## Value

A named character vector with at least `pageid`, `title`, and `length`
elements.

## Examples

``` r
if (FALSE) { # \dontrun{
get_article_info_table("Zeitgeber")
} # }
```
