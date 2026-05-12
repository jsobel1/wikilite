# Retrieve the most recent revision of a Wikipedia article

Retrieve the most recent revision of a Wikipedia article

## Usage

``` r
get_article_most_recent_table(
  article_name,
  date_an = NULL,
  lang = "en",
  use_cache = TRUE
)
```

## Arguments

- article_name:

  Character string giving the Wikipedia article title.

- date_an:

  Character string — upper date limit in ISO 8601 format. Default:
  current UTC time.

- lang:

  Two-letter language code (default: `"en"`).

- use_cache:

  Logical. When `TRUE` (default), results are cached to disk.

## Value

A single-row data frame with the same columns as
[`get_article_full_history_table`](https://jsobel1.github.io/wikilite/reference/get_article_full_history_table.md).

## Examples

``` r
# \donttest{
get_article_most_recent_table("Zeitgeber")
get_article_most_recent_table("COVID-19", lang = "fr")
# }
```
