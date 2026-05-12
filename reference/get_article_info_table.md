# Retrieve metadata for a Wikipedia article

Returns a named vector containing the page ID, title, and byte length of
the current revision of the article.

## Usage

``` r
get_article_info_table(article_name, date_an = NULL, lang = "en")
```

## Arguments

- article_name:

  Character string giving the Wikipedia article title.

- date_an:

  Character string — reference date in ISO 8601 format. Default: current
  UTC time.

- lang:

  Two-letter language code (default: `"en"`).

## Value

A named character vector with at least `pageid`, `title`, and `length`
elements.

## Examples

``` r
# \donttest{
get_article_info_table("Zeitgeber")
# }
```
