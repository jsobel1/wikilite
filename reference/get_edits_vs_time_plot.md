# Plot yearly edit counts for a Wikipedia article

Produces a ggplot2 bar chart of edit counts grouped by year, optionally
coloured by edit type (revert vs. other).

## Usage

``` r
get_edits_vs_time_plot(art_history_full, art_name)
```

## Arguments

- art_history_full:

  A full revision history data frame as returned by
  [`get_article_full_history_table`](https://jsobel1.github.io/wikilite/reference/get_article_full_history_table.md).

- art_name:

  Character string used as the plot title.

## Value

A `ggplot2` object (invisibly).

## Examples

``` r
# \donttest{
hist_df <- get_article_full_history_table("Zeitgeber")
get_edits_vs_time_plot(hist_df, "Zeitgeber")
# }
```
