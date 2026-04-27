# Plot article creation dates over time

Displays either the per-year count or the cumulative count of article
creation dates.

## Usage

``` r
plot_article_creation_per_year(
  article_initial_table,
  name_title,
  Cumsum = TRUE
)
```

## Arguments

- article_initial_table:

  A data frame of initial revisions as returned by
  [`get_article_initial_table`](https://jsobel1.github.io/wikilite/reference/get_article_initial_table.md)
  or
  [`get_category_articles_creation`](https://jsobel1.github.io/wikilite/reference/get_category_articles_creation.md).

- name_title:

  Character string used as the plot title.

- Cumsum:

  Logical. If `TRUE` (default) a cumulative curve is plotted; if `FALSE`
  annual counts are plotted instead.

## Value

A `ggplot2` object (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
initial <- get_category_articles_creation(
  c("Zeitgeber", "Advanced sleep phase disorder")
)
plot_article_creation_per_year(initial, "Sleep articles")
} # }
```
