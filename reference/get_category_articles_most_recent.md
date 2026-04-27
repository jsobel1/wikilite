# Retrieve the most recent revision for multiple Wikipedia articles

Calls
[`get_article_most_recent_table`](https://jsobel1.github.io/wikilite/reference/get_article_most_recent_table.md)
for each element of `list_art` and row-binds the results.

## Usage

``` r
get_category_articles_most_recent(list_art, date_an = NULL)
```

## Arguments

- list_art:

  Character vector of English Wikipedia article titles.

- date_an:

  Reserved for future use; currently ignored. Pass `NULL` (default).

## Value

A combined data frame of most recent revisions, or `NULL` if all
requests fail.

## Examples

``` r
if (FALSE) { # \dontrun{
get_category_articles_most_recent(
  c("Zeitgeber", "Advanced sleep phase disorder", "Sleep deprivation")
)
} # }
```
