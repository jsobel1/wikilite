# Retrieve the full revision history for multiple Wikipedia articles

Calls
[`get_article_full_history_table`](https://jsobel1.github.io/wikilite/reference/get_article_full_history_table.md)
for each element of `list_art` and row-binds the results.

## Usage

``` r
get_category_articles_history(list_art, lang = "en", workers = 1L)
```

## Arguments

- list_art:

  Character vector of Wikipedia article titles.

- lang:

  Two-letter language code (default: `"en"`).

- workers:

  Integer. Number of parallel workers when furrr is installed (default:
  `1L` — sequential).

## Value

A combined data frame, or `NULL` if all requests fail.

## Examples

``` r
# \donttest{
get_category_articles_history(
  c("Zeitgeber", "Advanced sleep phase disorder", "Sleep deprivation")
)
# }
```
