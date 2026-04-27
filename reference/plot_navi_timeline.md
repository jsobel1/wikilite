# Plot an interactive timeline of article creation dates

Currently a stub — the timevis package is not available on CRAN. The
function issues an informative message and returns `NULL` invisibly. Use
[`plot_static_timeline`](https://jsobel1.github.io/wikilite/reference/plot_static_timeline.md)
for a static equivalent.

## Usage

``` r
plot_navi_timeline(article_initial_table_sel, article_info_table)
```

## Arguments

- article_initial_table_sel:

  A data frame of initial revisions.

- article_info_table:

  A data frame of article metadata as returned by
  [`get_article_info_table`](https://jsobel1.github.io/wikilite/reference/get_article_info_table.md).

## Value

`NULL`, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
initial <- get_article_initial_table("Zeitgeber")
info    <- get_article_info_table("Zeitgeber")
plot_navi_timeline(initial, info)
} # }
```
