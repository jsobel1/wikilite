# Retrieve the first revision of a Wikipedia article

Retrieve the first revision of a Wikipedia article

## Usage

``` r
get_article_initial_table(article_name, lang = "en")
```

## Arguments

- article_name:

  Character string giving the Wikipedia article title.

- lang:

  Two-letter language code (default: `"en"`).

## Value

A single-row data frame with the same columns as
[`get_article_full_history_table`](https://jsobel1.github.io/wikilite/reference/get_article_full_history_table.md).

## Examples

``` r
# \donttest{
get_article_initial_table("Zeitgeber")
# }
```
