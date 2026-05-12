# Plot a static timeline of article creation dates

Plot a static timeline of article creation dates

## Usage

``` r
plot_static_timeline(article_initial_table_sel)
```

## Arguments

- article_initial_table_sel:

  A data frame of initial revisions as returned by
  [`get_article_initial_table`](https://jsobel1.github.io/wikilite/reference/get_article_initial_table.md)
  or
  [`get_category_articles_creation`](https://jsobel1.github.io/wikilite/reference/get_category_articles_creation.md).

## Value

A `ggplot2` object (invisibly).

## Examples

``` r
# \donttest{
initial <- get_category_articles_creation(
  c("Zeitgeber", "Advanced sleep phase disorder")
)
plot_static_timeline(initial)
# }
```
