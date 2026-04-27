# Retrieve the creation revision for multiple Wikipedia articles

Calls
[`get_article_initial_table`](https://jsobel1.github.io/wikilite/reference/get_article_initial_table.md)
for each element of `list_art` and row-binds the results.

## Usage

``` r
get_category_articles_creation(list_art)
```

## Arguments

- list_art:

  Character vector of English Wikipedia article titles.

## Value

A combined data frame of first revisions, or `NULL` if all requests
fail.

## Examples

``` r
if (FALSE) { # \dontrun{
get_category_articles_creation(
  c("Zeitgeber", "Advanced sleep phase disorder", "Sleep deprivation")
)
} # }
```
