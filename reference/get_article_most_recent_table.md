# Retrieve the most recent revision of a Wikipedia article

Retrieve the most recent revision of a Wikipedia article

## Usage

``` r
get_article_most_recent_table(article_name, date_an = "2020-05-01T00:00:00Z")
```

## Arguments

- article_name:

  Character string giving the English Wikipedia article title.

- date_an:

  Character string — upper date limit in ISO 8601 format (default:
  `"2020-05-01T00:00:00Z"`).

## Value

A single-row data frame with the same columns as
[`get_article_full_history_table`](https://jsobel1.github.io/wikilite/reference/get_article_full_history_table.md).

## Examples

``` r
if (FALSE) { # \dontrun{
get_article_most_recent_table("Zeitgeber")
} # }
```
