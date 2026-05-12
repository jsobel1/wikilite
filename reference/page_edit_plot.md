# Plot weekly edit counts for a Wikipedia article

Retrieves the full revision history and plots the number of edits per
week as an area chart.

## Usage

``` r
page_edit_plot(
  article_name,
  ymax = NA,
  start = "2020010100",
  end = "2020050100",
  lang = "en"
)
```

## Arguments

- article_name:

  Character string — Wikipedia article title.

- ymax:

  Optional numeric upper limit for the y-axis.

- start:

  Start date in `"YYYYMMDDHH"` format (default: `"2020010100"`).

- end:

  End date in `"YYYYMMDDHH"` format (default: `"2020050100"`).

- lang:

  Two-letter language code (default: `"en"`).

## Value

A `ggplot2` object (invisibly).

## Examples

``` r
# \donttest{
page_edit_plot("Zeitgeber", start = "2019010100", end = "2021010100")
# }
```
