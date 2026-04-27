# Retrieve the full revision history for multiple Wikipedia articles

Calls
[`get_article_full_history_table`](https://jsobel1.github.io/wikilite/reference/get_article_full_history_table.md)
for each element of `list_art` and row-binds the results.

## Usage

``` r
get_category_articles_history(list_art)
```

## Arguments

- list_art:

  Character vector of English Wikipedia article titles.

## Value

A combined data frame with the same columns as
[`get_article_full_history_table`](https://jsobel1.github.io/wikilite/reference/get_article_full_history_table.md),
or `NULL` if all requests fail.

## Examples

``` r
if (FALSE) { # \dontrun{
get_category_articles_history(
  c("Zeitgeber", "Advanced sleep phase disorder", "Sleep deprivation")
)
} # }
```
