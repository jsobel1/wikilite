# Retrieve initial, most-recent, info, and full-history tables for a set of articles

A convenience wrapper that calls
[`get_article_initial_table`](https://jsobel1.github.io/wikilite/reference/get_article_initial_table.md),
[`get_article_most_recent_table`](https://jsobel1.github.io/wikilite/reference/get_article_most_recent_table.md),
[`get_article_info_table`](https://jsobel1.github.io/wikilite/reference/get_article_info_table.md),
and
[`get_article_full_history_table`](https://jsobel1.github.io/wikilite/reference/get_article_full_history_table.md)
for every title in `all_art` and returns the four tables as a named
list.

## Usage

``` r
get_tables_initial_most_recent_full_info(all_art, lang = "en")
```

## Arguments

- all_art:

  Character vector of Wikipedia article titles.

- lang:

  Two-letter language code (default: `"en"`).

## Value

A named list with elements `article_initial_table`,
`article_most_recent_table`, `article_info_table`, and
`article_full_history_table`.

## Examples

``` r
# \donttest{
res <- get_tables_initial_most_recent_full_info(
  c("Zeitgeber", "Sleep deprivation")
)
# }
```
