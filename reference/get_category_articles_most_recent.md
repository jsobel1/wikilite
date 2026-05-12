# Retrieve the most recent revision for multiple Wikipedia articles

Calls
[`get_article_most_recent_table`](https://jsobel1.github.io/wikilite/reference/get_article_most_recent_table.md)
for each element of `list_art` and row-binds the results.

## Usage

``` r
get_category_articles_most_recent(list_art, date_an = NULL, lang = "en")
```

## Arguments

- list_art:

  Character vector of Wikipedia article titles.

- date_an:

  Character string — upper date limit in ISO 8601 format. Default:
  current UTC time.

- lang:

  Two-letter language code (default: `"en"`).

## Value

A combined data frame of most recent revisions, or `NULL` if all
requests fail.

## Examples

``` r
# \donttest{
get_category_articles_most_recent(
  c("Zeitgeber", "Advanced sleep phase disorder", "Sleep deprivation")
)
# }
```
