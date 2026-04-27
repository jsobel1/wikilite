# Plot daily Wikipedia page views for an article

Queries the Wikimedia pageviews API and plots daily view counts as an
area chart.

## Usage

``` r
page_view_plot(
  article_name,
  ymax = NA,
  start = "2020010100",
  end = "2020050100"
)
```

## Arguments

- article_name:

  Character string — English Wikipedia article title.

- ymax:

  Optional numeric upper limit for the y-axis.

- start:

  Start date in `"YYYYMMDDHH"` format (default: `"2020010100"`).

- end:

  End date in `"YYYYMMDDHH"` format (default: `"2020050100"`).

## Value

A `ggplot2` object (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
page_view_plot("Zeitgeber", start = "2020010100", end = "2020050100")
} # }
```
